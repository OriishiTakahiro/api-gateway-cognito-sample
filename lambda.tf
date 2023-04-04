locals {
  function_name  = "demo-function"
  file_path      = "backend/dist"
  publickey_path = "./publickey.txt"

}

resource "aws_iam_role" "lambda_role" {
  name = "demo-lambda-role"
  path = "/demo/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

/* --- コンテナ指定の場合 ---
resource "aws_ecr_repository" "demo" {
  name                 = "demo-lambda-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "demo" {
  name                 = "demo-lambda-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_lambda_function" "demo_app" {
  function_name = local.function_name
  package_type  = "Image"
  role          = aws_iam_role.lambda_role.arn
  timeout       = 10
  image_uri     = aws_ecr_repository.demo.repository_url
  // https://github.com/pyca/cryptography/issues/3051
  architectures = ["arm64"]
  // ファイル名.関数名
  handler = "main.lambda_handler"

  environment {
    variables = {
      JWKS_HOST = "https://cognito-idp.${local.region}.amazonaws.com/${aws_cognito_user_pool.demo.id}",
      CLIENT_ID = aws_cognito_user_pool_client.demo.id
    }
  }

  lifecycle {
    ignore_changes = [image_uri]
  }
}
*/

/* --- ZIPファイルアップロードの場合 --- */
data "archive_file" "function_source" {
  type        = "zip"
  source_dir  = local.file_path
  output_path = "dist/demo-app.zip"
}

resource "aws_lambda_function" "demo_app" {
  function_name = local.function_name
  role          = aws_iam_role.lambda_role.arn
  // https://github.com/pyca/cryptography/issues/3051
  architectures = ["arm64"]
  runtime       = "python3.9"
  // ファイル名.関数名
  handler = "main.lambda_handler"

  filename         = data.archive_file.function_source.output_path
  source_code_hash = data.archive_file.function_source.output_base64sha256

  environment {
    variables = {
      JWKS_HOST = "https://cognito-idp.${local.region}.amazonaws.com/${aws_cognito_user_pool.demo.id}",
      CLIENT_ID = aws_cognito_user_pool_client.demo.id
    }
  }
}

