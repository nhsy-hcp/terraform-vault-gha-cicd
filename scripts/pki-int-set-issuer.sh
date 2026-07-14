#!/bin/bash
set -euo pipefail

# Sets the default issuer for the pki-int mount and links it to the
# Terraform-managed key (if not already linked).
#
# Must be run from the project root directory with VAULT_ADDR and VAULT_TOKEN set.
#
# Usage:
#   eval "$(task bootstrap:env)" && scripts/pki-int-set-issuer.sh

NAMESPACE="admin/tn001"
MOUNT="pki-int"

echo "==> Listing issuers on ${MOUNT}..."
ISSUER_LIST=$(vault list -namespace="${NAMESPACE}" -format=json "${MOUNT}/issuers" 2>/dev/null || echo "[]")
ISSUER_COUNT=$(echo "${ISSUER_LIST}" | jq 'length')

if [[ "${ISSUER_COUNT}" -eq 0 ]]; then
  echo "ERROR: No issuers found on ${MOUNT}. Run pki:int:import first." >&2
  exit 1
fi

ISSUER_ID=$(echo "${ISSUER_LIST}" | jq -r '.[0]')
echo "    Found issuer: ${ISSUER_ID}"

echo "==> Checking issuer key linkage..."
KEY_ID=$(vault read -namespace="${NAMESPACE}" -format=json "${MOUNT}/issuer/${ISSUER_ID}" \
  | jq -r '.data.key_id // empty')

if [[ -z "${KEY_ID}" ]]; then
  echo "    Issuer has no key_id. Attempting to link Terraform-managed key..."

  TF_KEY_ID=$(terraform -chdir=namespace-tn001 output -json 2>/dev/null \
    | jq -r '.pki_intermediate_key_id.value // empty' 2>/dev/null || true)

  if [[ -z "${TF_KEY_ID}" ]]; then
    echo "    No output 'pki_intermediate_key_id' found; fetching from state..."
    TF_KEY_ID=$(terraform -chdir=namespace-tn001 show -json 2>/dev/null \
      | jq -r '
          .values.root_module.child_modules[].resources[]
          | select(.address | test("cert_request"))
          | .values.key_id // empty
        ' 2>/dev/null | head -1 || true)
  fi

  if [[ -n "${TF_KEY_ID}" ]]; then
    echo "    Linking key ${TF_KEY_ID} to issuer ${ISSUER_ID}..."
    vault write -namespace="${NAMESPACE}" "${MOUNT}/issuer/${ISSUER_ID}" \
      key_id="${TF_KEY_ID}" 2>&1 || echo "    WARN: key link attempt returned an error (key may not exist in Vault)"
  else
    echo "    WARN: Could not determine Terraform key ID. Skipping key linkage."
    echo "    If issue/sign tests fail, run: task pki:int:regen"
  fi
else
  echo "    Issuer already linked to key: ${KEY_ID}"
fi

echo "==> Setting issuer ${ISSUER_ID} as default on ${MOUNT}..."
vault write -namespace="${NAMESPACE}" "${MOUNT}/config/issuers" \
  default="${ISSUER_ID}"

echo "==> Default issuer set successfully."
echo "    Issuer ID : ${ISSUER_ID}"
