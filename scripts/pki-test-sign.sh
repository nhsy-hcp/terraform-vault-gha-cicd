#!/bin/bash
set -euo pipefail

# Tests the Vault PKI sign endpoint for a given role.
# Generates a throwaway EC P-256 key and CSR locally, submits the CSR to Vault
# for signing, then verifies the chain and key/certificate match.
#
# Required environment variables:
#   VAULT_ADDR      - Vault server address
#   VAULT_TOKEN     - Vault token with permission to sign certificates
#
# Optional environment variables (override via Taskfile vars):
#   ROLE            - PKI role name (default: server)
#   CN              - Common name for the certificate (default: helloworld.example.com)
#   TTL             - Certificate TTL (default: 1h)
#   NAMESPACE       - Vault namespace (default: admin/tn001)
#   PKI_MOUNT       - PKI mount path (default: pki-int)
#   ROOT_CA_CERT    - Path to root CA certificate for chain verification (default: .pki/root-ca.crt)
#   OUT_DIR         - Directory for output files (default: .tmp)

ROLE="${ROLE:-server}"
CN="${CN:-helloworld.example.com}"
TTL="${TTL:-1h}"
NAMESPACE="${NAMESPACE:-admin/tn001}"
PKI_MOUNT="${PKI_MOUNT:-pki-int}"
ROOT_CA_CERT="${ROOT_CA_CERT:-.tmp/ca-chain.pem}"
OUT_DIR="${OUT_DIR:-.tmp}"

mkdir -p "${OUT_DIR}"

echo "==> Generating throwaway EC P-256 key and CSR"
openssl req -newkey ec -pkeyopt ec_paramgen_curve:P-256 -nodes \
  -keyout "${OUT_DIR}/pki-test.key" \
  -out "${OUT_DIR}/pki-test.csr" \
  -subj "/CN=${CN}"

echo "==> Testing ${PKI_MOUNT}/sign/${ROLE} (cn=${CN} ttl=${TTL})"
vault write \
  -namespace="${NAMESPACE}" \
  -format=json \
  "${PKI_MOUNT}/sign/${ROLE}" \
  csr="@${OUT_DIR}/pki-test.csr" \
  common_name="${CN}" \
  ttl="${TTL}" | tee "${OUT_DIR}/pki-sign.json" | jq -r '.data.certificate' > "${OUT_DIR}/pki-sign.pem"

echo "==> Verifying certificate chain"
openssl verify -CAfile "${ROOT_CA_CERT}" "${OUT_DIR}/pki-sign.pem"

echo "==> Certificate details"
openssl x509 -noout -subject -issuer -dates -in "${OUT_DIR}/pki-sign.pem"

echo "==> Verifying key matches signed certificate"
cert_pub=$(openssl x509 -noout -pubkey -in "${OUT_DIR}/pki-sign.pem")
key_pub=$(openssl pkey -pubout -in "${OUT_DIR}/pki-test.key")
if [ "${cert_pub}" = "${key_pub}" ]; then
  echo "Key/certificate match confirmed"
else
  echo "ERROR: key does not match signed certificate" && exit 1
fi

echo "==> pki:test:sign passed"
