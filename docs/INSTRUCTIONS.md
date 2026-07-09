# Instructions

## Adding the PKI engine to `namespace-tn001`

The `admin/tn001` tenant uses the **offline-root CA** pattern: the root CA is
generated and kept outside Vault (with OpenSSL), while Vault manages only the
intermediate CA mounted at `pki-int`. Terraform provisions the mount and
generates the intermediate CSR; the CSR is signed offline by the root CA and
imported back into Vault.

### Prerequisites

- Vault authentication configured (`VAULT_ADDR` and a `VAULT_TOKEN` with rights
  in the `admin/tn001` namespace). From `bootstrap`, `task bootstrap:env` prints
  the export commands.
- `terraform`, `vault`, and `openssl` available on your `PATH`.

### Steps

1. **Generate the offline root CA** (self-signed, kept outside Vault). Prompts
   for a passphrase (`-aes256`); the certificate is valid for 2 years.

   ```sh
   task pki:root:generate
   task pki:root:view      # optional: inspect the root certificate
   ```

   Writes `namespace-tn001/.pki/root-ca.{key,crt}` (gitignored).

2. **Apply Terraform** — creates the `pki-int` mount, generates the intermediate
   private key and CSR, and configures CRL/OCSP.

   ```sh
   task namespace-tn001:init
   task namespace-tn001:plan
   task namespace-tn001:apply   # or via CI on merge to main
   ```

3. **Retrieve the CSR** that Terraform generated.

   ```sh
   task pki:int:csr   # terraform output -raw pki_intermediate_csr > .pki/intermediate.csr
   ```

4. **Sign the CSR** with the offline root CA. Prompts for the root key
   passphrase; the intermediate is valid for 1 year with `pathlen:0` and CA
   key-usage constraints.

   ```sh
   task pki:int:sign
   task pki:int:verify   # optional: verify the chain against the root
   ```

5. **Import the signed intermediate** back into Vault.

   ```sh
   task pki:int:import   # vault write pki-int/intermediate/set-signed
   ```

6. **Define issuing roles** — add entries to `namespace-tn001/terraform.tfvars`
   under `pki_roles`, then re-apply.

   ```hcl
   pki_roles = {
     server = {
       allowed_domains  = ["helloworld.example.com"]
       allow_subdomains = false
       max_ttl          = "24h"
       key_type         = "ec"
       key_bits         = 256
     }
   }
   ```

   ```sh
   task namespace-tn001:apply
   ```

### Issuing a certificate

```sh
vault write -namespace=admin/tn001 pki-int/issue/server common_name=helloworld.example.com
```

### Notes

- The intermediate CA cannot issue certificates until step 5 (`set-signed`)
  completes.
- `pki_roles` only depend on the mount, so they may be included in the first
  apply (step 2) instead of a second apply in step 6.
- The root CA private key never enters Vault; protect
  `namespace-tn001/.pki/root-ca.key` accordingly.
