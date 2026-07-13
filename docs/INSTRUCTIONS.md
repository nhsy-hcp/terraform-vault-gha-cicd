# Instructions

## Adding the PKI engine to `namespace-tn001`

The `admin/tn001` tenant uses the **offline-root CA** pattern: the root CA is
generated and kept outside Vault (with OpenSSL), while Vault manages only the
intermediate CA mounted at `pki-int`. Terraform provisions the mount and
generates the intermediate CSR; the CSR is signed offline by the root CA and
imported back into Vault.

### Prerequisites

- `VAULT_ADDR` and `VAULT_TOKEN` set with rights in the `admin/tn001` namespace.
  Run `eval "$(task bootstrap:env)"` to export both from the bootstrap state, or
  set them manually:
  ```sh
  export VAULT_ADDR=$(task bootstrap:vault-addr)
  export VAULT_TOKEN=$(task bootstrap:vault-token)   # also copies to clipboard
  ```
- `terraform`, `vault`, `openssl`, and `jq` available on your `PATH`.

### Steps

1. **Generate the offline root CA** — self-signed RSA-4096, valid for 2 years.
   The key is unencrypted and stored in `.tmp/` (gitignored); protect it
   accordingly.

   ```sh
   task pki:root:generate
   task pki:root:view      # optional: inspect the root certificate
   ```

   Writes `namespace-tn001/.tmp/root-ca.{key,crt}`.

2. **Apply Terraform via CI** — push to `main` (or trigger the
   `namespace-tn001` workflow manually via `workflow_dispatch`) to create the
   `pki-int` mount, generate the intermediate private key and CSR, and configure
   CRL/OCSP. The apply runs in GitHub Actions; it cannot be run locally.

3. **Retrieve the CSR** that Terraform generated from the remote state.

   ```sh
   task pki:int:csr   # writes .tmp/intermediate.csr
   ```

4. **Sign the CSR** with the offline root CA. The intermediate is valid for
   1 year with `pathlen:0` and CA key-usage constraints.

   ```sh
   task pki:int:sign
   task pki:int:verify   # optional: verify the chain against the root
   ```

5. **Import the signed intermediate** back into Vault and build the local CA
   chain bundle used for certificate verification.

   ```sh
   task pki:int:import   # imports cert + fetches chain → .tmp/ca-chain.pem
   ```

6. **Define issuing roles** — add entries to `namespace-tn001/terraform.tfvars`
   under `pki_roles`, commit, and push to `main` to apply via CI.

   ```hcl
   pki_roles = {
     server = {
       allowed_domains  = ["example.com"]
       allow_subdomains = false
       ttl              = "24h"
       max_ttl          = "168h"
       generate_lease   = false
       no_store         = false
       key_type         = "ec"
       key_bits         = 256
       issuer_ref       = "default"
     }
   }
   ```

   > Set `allow_subdomains = true` to also permit `*.example.com`.

### Testing the PKI endpoints

After steps 1–5 and once at least one role exists (step 6 applied), run:

```sh
task pki:test           # runs both issue and sign tests
task pki:test:issue     # test issue endpoint only
task pki:test:sign      # test sign endpoint only (generates throwaway EC key + CSR)
```

Override defaults with task variables:

```sh
task pki:test:issue ROLE=server CN=myapp.example.com TTL=30m
```

Test output is written to `namespace-tn001/.tmp/` (gitignored).

### Issuing a certificate (manual)

```sh
vault write -namespace=admin/tn001 pki-int/issue/server \
  common_name=helloworld.example.com \
  ttl=1h
```

### Signing a CSR (manual)

```sh
vault write -namespace=admin/tn001 pki-int/sign/server \
  csr=@/path/to/server.csr \
  common_name=helloworld.example.com \
  ttl=1h
```

### Notes

- The intermediate CA cannot issue certificates until step 5 (`set-signed`)
  completes.
- `pki_roles` only depend on the mount, so they may be included in the first
  CI apply (step 2) rather than a separate step 6 apply.
- The root CA private key never enters Vault; protect
  `namespace-tn001/.tmp/root-ca.key` accordingly.
- All PKI material (keys, CSRs, certs, chain bundle) lives in
  `namespace-tn001/.tmp/` which is gitignored — nothing is committed.
