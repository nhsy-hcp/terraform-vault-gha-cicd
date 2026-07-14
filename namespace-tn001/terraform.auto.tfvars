vault_address = "https://vault-training-cluster-pegasus-public-vault-f6816f27.65ed0d62.z1.hashicorp.cloud:8200"

pki_roles = {
  server = {
    allowed_domains    = ["helloworld.example.com"]
    allow_bare_domains = true
    allow_subdomains   = false
    max_ttl            = "24h"
    key_type           = "ec"
    key_bits           = 256
  }
}
