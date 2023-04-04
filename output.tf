output "app_url" {
  value       = aws_api_gateway_stage.demo.invoke_url
  description = "API Gateway invoke URL"
}

output "cognito_user_pool_id" {
  value       = aws_cognito_user_pool.demo.id
  description = "Cognito user pool ID"
}

output "cognito_user_pool_endpoint" {
  value       = aws_cognito_user_pool.demo.endpoint
  description = "Login endpoint"
}

output "cognito_user_pool_demo_client_id" {
  value       = aws_cognito_user_pool_client.demo.id
  description = "Client ID"
}
