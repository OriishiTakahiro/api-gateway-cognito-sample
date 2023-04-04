locals {
  http_statuses = ["200", "500"]
}

// === IAM Role === //
resource "aws_iam_role" "invocation_role" {
  name = "demo-api-gateway-auth-invocation"
  path = "/demo/"

  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : "sts:AssumeRole",
          "Principal" : {
            "Service" : "apigateway.amazonaws.com"
          },
          "Effect" : "Allow",
          "Sid" : ""
        }
      ]
    }
  )
}

resource "aws_iam_role_policy" "invocation_policy" {
  name = "demo-api-gateway-invocation-policy"
  role = aws_iam_role.invocation_role.id

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : [
            "lambda:InvokeFunction"
          ],
          "Effect" : "Allow",
          "Resource" : "${aws_lambda_function.demo_app.arn}",
          "Sid" : ""
        }
      ]
    }
  )
}

resource "aws_iam_role_policy" "cloudwatch_log_policy" {
  name = "demo-api-gateway-cloudwatch-log-policy"
  role = aws_iam_role.invocation_role.id

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:DescribeLogGroups",
            "logs:DescribeLogStreams",
            "logs:PutLogEvents",
            "logs:GetLogEvents",
            "logs:FilterLogEvents"
          ],
          "Effect" : "Allow",
          "Resource" : "*",
          "Sid" : ""
        }
      ]
    }
  )
}
//"Resource" : "${aws_cloudwatch_log_group.demo.arn}/*",

// === CloudWatch === //
resource "aws_cloudwatch_log_group" "demo" {
  name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.demo.id}/${aws_api_gateway_stage.demo.stage_name}"
  retention_in_days = 1
}


// === API Gateway === //
resource "aws_api_gateway_account" "demo" {
  cloudwatch_role_arn = aws_iam_role.invocation_role.arn
}

resource "aws_api_gateway_rest_api" "demo" {
  name       = "demo-gateway"
  depends_on = [aws_api_gateway_account.demo]
}

resource "aws_lambda_permission" "demo" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.demo_app.function_name
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_rest_api.demo.execution_arn}/*/*"
}

resource "aws_api_gateway_resource" "demo" {
  rest_api_id = aws_api_gateway_rest_api.demo.id
  parent_id   = aws_api_gateway_rest_api.demo.root_resource_id
  path_part   = "demo"
}

resource "aws_api_gateway_authorizer" "demo" {
  name                   = "demo-gateway-authorizer"
  type                   = "COGNITO_USER_POOLS"
  provider_arns          = [aws_cognito_user_pool.demo.arn]
  rest_api_id            = aws_api_gateway_rest_api.demo.id
  authorizer_uri         = aws_lambda_function.demo_app.invoke_arn
  authorizer_credentials = aws_iam_role.invocation_role.arn
}

resource "aws_api_gateway_method" "demo_api_method" {
  rest_api_id = aws_api_gateway_rest_api.demo.id
  resource_id = aws_api_gateway_resource.demo.id
  // ANYにしてlambda_handlerで出し分けるのもあり
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.demo.id

  request_parameters = {
    "method.request.path.proxy" = true,
  }
}

resource "aws_api_gateway_integration" "demo" {
  rest_api_id = aws_api_gateway_rest_api.demo.id
  resource_id = aws_api_gateway_resource.demo.id
  http_method = aws_api_gateway_method.demo_api_method.http_method
  // Required if type is AWS, AWS_PROXY, HTTP or HTTP_PROXY. Not all methods are compatible with all AWS integrations. e.g., Lambda function can only be invoked via POST.
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.demo_app.invoke_arn
}

resource "aws_api_gateway_method_response" "demo" {
  for_each    = toset(local.http_statuses)
  rest_api_id = aws_api_gateway_rest_api.demo.id
  resource_id = aws_api_gateway_resource.demo.id
  http_method = aws_api_gateway_method.demo_api_method.http_method
  status_code = each.value
}

resource "aws_api_gateway_deployment" "demo" {
  rest_api_id = aws_api_gateway_rest_api.demo.id
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "demo" {
  deployment_id = aws_api_gateway_deployment.demo.id
  rest_api_id   = aws_api_gateway_rest_api.demo.id
  stage_name    = "demo-stage"
}

resource "aws_api_gateway_method_settings" "demo" {
  rest_api_id = aws_api_gateway_rest_api.demo.id
  stage_name  = aws_api_gateway_stage.demo.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled        = true
    data_trace_enabled     = true
    logging_level          = "INFO"
    throttling_rate_limit  = 100
    throttling_burst_limit = 50
  }
}
