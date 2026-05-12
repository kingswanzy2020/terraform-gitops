# Enable the built-in Terraform plugin with recommended rules
plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

# Enable the AWS-specific ruleset for provider-level checks
plugin "aws" {
  enabled = true
  version = "0.47.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}
