#!/bin/bash
set -euo pipefail

# Creates the bootstrap HCP Terraform workspace via REST API and sets
# execution mode to local. Must be run before `terraform init` in bootstrap/.
#
# Required environment variables:
#   TFE_TOKEN       - HCP Terraform API token
#
# Optional environment variables (defaults match bootstrap/variables.tf):
#   TF_CLOUD_ORGANIZATION  - HCP Terraform organization (default: nhsy-hcp-org)
#   TF_CLOUD_PROJECT       - HCP Terraform project name (default: terraform-vault-gha-cicd)
#   TF_CLOUD_HOSTNAME      - HCP Terraform hostname (default: app.terraform.io)

ORGANIZATION="${TF_CLOUD_ORGANIZATION:-nhsy-hcp-org}"
PROJECT_NAME="${TF_CLOUD_PROJECT:-terraform-vault-gha-cicd}"
HOSTNAME="${TF_CLOUD_HOSTNAME:-app.terraform.io}"
WORKSPACE_NAME="bootstrap"
BASE_URL="https://${HOSTNAME}/api/v2"

if [[ -z "${TFE_TOKEN:-}" ]]; then
  echo "ERROR: TFE_TOKEN environment variable is not set" >&2
  exit 1
fi

AUTH_HEADER="Authorization: Bearer ${TFE_TOKEN}"
CONTENT_HEADER="Content-Type: application/vnd.api+json"

echo "==> Looking up project '${PROJECT_NAME}' in organization '${ORGANIZATION}'..."
PROJECT_ID=$(curl -sf \
  -H "${AUTH_HEADER}" \
  "${BASE_URL}/organizations/${ORGANIZATION}/projects?q=${PROJECT_NAME}" \
  | jq -r ".data[] | select(.attributes.name == \"${PROJECT_NAME}\") | .id")

if [[ -z "${PROJECT_ID}" ]]; then
  echo "ERROR: Project '${PROJECT_NAME}' not found in organization '${ORGANIZATION}'" >&2
  exit 1
fi
echo "    project id: ${PROJECT_ID}"

echo "==> Checking if workspace '${WORKSPACE_NAME}' already exists..."
EXISTING=$(curl -sf \
  -H "${AUTH_HEADER}" \
  "${BASE_URL}/organizations/${ORGANIZATION}/workspaces/${WORKSPACE_NAME}" \
  -o /dev/null -w "%{http_code}" || true)

if [[ "${EXISTING}" == "200" ]]; then
  echo "    workspace '${WORKSPACE_NAME}' already exists, skipping creation."
else
  echo "==> Creating workspace '${WORKSPACE_NAME}'..."
  curl -sf \
    -X POST \
    -H "${AUTH_HEADER}" \
    -H "${CONTENT_HEADER}" \
    "${BASE_URL}/organizations/${ORGANIZATION}/workspaces" \
    -d @- <<EOF
{
  "data": {
    "type": "workspaces",
    "attributes": {
      "name": "${WORKSPACE_NAME}",
      "execution-mode": "local"
    },
    "relationships": {
      "project": {
        "data": {
          "type": "projects",
          "id": "${PROJECT_ID}"
        }
      }
    }
  }
}
EOF
  echo ""
  echo "    workspace '${WORKSPACE_NAME}' created."
fi

echo "==> Ensuring execution mode is set to 'local'..."
WORKSPACE_ID=$(curl -sf \
  -H "${AUTH_HEADER}" \
  "${BASE_URL}/organizations/${ORGANIZATION}/workspaces/${WORKSPACE_NAME}" \
  | jq -r ".data.id")

curl -sf \
  -X PATCH \
  -H "${AUTH_HEADER}" \
  -H "${CONTENT_HEADER}" \
  "${BASE_URL}/workspaces/${WORKSPACE_ID}" \
  -d @- <<EOF
{
  "data": {
    "type": "workspaces",
    "attributes": {
      "execution-mode": "local"
    }
  }
}
EOF
echo ""
echo "==> Done. Workspace '${WORKSPACE_NAME}' (id: ${WORKSPACE_ID}) is ready with execution-mode=local."
