#!/bin/bash
set -euo pipefail

# Tests the Vault PKI issue endpoint for a given role.
# Vault generates the private key and returns a signed certificate.
#
# Required environment variables:
#   VAULT_ADDR      - Vault server address
#   VAULT_TOKEN     - Vault token with permission to issue certificates
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

echo "==> Testing ${PKI_MOUNT}/issue/${ROLE} (cn=${CN} ttl=${TTL})"
vault write \
  -namespace="${NAMESPACE}" \
  -format=json \
  "${PKI_MOUNT}/issue/${ROLE}" \
  common_name="${CN}" \
  ttl="${TTL}" | tee "${OUT_DIR}/pki-issue.json" | jq -r '.data.certificate' > "${OUT_DIR}/pki-issue.pem"

echo "==> Verifying certificate chain"
openssl verify -CAfile "${ROOT_CA_CERT}" "${OUT_DIR}/pki-issue.pem"

echo "==> Certificate details"
openssl x509 -noout -subject -issuer -dates -in "${OUT_DIR}/pki-issue.pem"

echo "==> pki:test:issue passed"
