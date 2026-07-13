pki_roles = {
  server = {
    allowed_domains  = ["helloworld.example.com"]
    allow_subdomains = false
    max_ttl          = "24h"
    key_type         = "ec"
    key_bits         = 256
  }
}
