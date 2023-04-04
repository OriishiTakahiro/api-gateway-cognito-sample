locals {
  frontend_url = "http://localhost:3000"
}

resource "aws_cognito_user_pool" "demo" {
  name = "demo-user-pool"

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }
}

resource "aws_cognito_user_pool_client" "demo" {
  name                = "demo-local-client"
  user_pool_id        = aws_cognito_user_pool.demo.id
  explicit_auth_flows = ["ALLOW_USER_PASSWORD_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]
}
