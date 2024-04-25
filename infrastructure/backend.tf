data "aws_iam_policy_document" "lambda_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "lamda_iam_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_role_policy.json
}

data "archive_file" "python_lambda_package" {
  type        = "zip"
  source_file = "/app/main.py"
  output_path = "main.zip"
}

resource "aws_lambda_function" "test_lambda_function" {
  function_name    = "lambdaTest"
  filename         = "main.zip"
  source_code_hash = data.archive_file.python_lambda_package.output_base64sha256
  role             = aws_iam_role.lambda_role.arn
  runtime          = "python3.9"
  handler          = "main.handler"
  timeout          = 10
}

output "lambda_function_url" {
  value = aws_lambda_function.test_lambda_function.invoke_arn
}