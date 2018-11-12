
provider "aws" {}

variable "rest_api_id" {}
variable "resource_id" {}

variable "ok_status_code" {
  default = "200"
}

variable "cors_allowed_methods" {
  default = "'POST,OPTIONS,GET,PUT,PATCH,DELETE'"
}

variable "cors_allowed_origin" {
  default = "'*'"
}


resource "aws_api_gateway_method" "options" {
  rest_api_id   = "${var.rest_api_id}"
  resource_id   = "${var.resource_id}"
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options-integration" {
  rest_api_id       = "${var.rest_api_id}"
  resource_id       = "${var.resource_id}"
  type              = "MOCK"
  http_method       = "${aws_api_gateway_method.options.http_method}"
  request_templates = {
    "application/json" = <<EOF
{ "statusCode": "${var.ok_status_code}" }
EOF
}
}

resource "aws_api_gateway_method_response" "options-response" {
  rest_api_id         = "${var.rest_api_id}"
  resource_id         = "${var.resource_id}"
  http_method         = "${aws_api_gateway_method.options.http_method}"
  status_code         = "${var.ok_status_code}"
  response_models     = { "application/json" = "Empty" }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration_response" "options-integration-response" {
  rest_api_id         = "${var.rest_api_id}"
  resource_id         = "${var.resource_id}"
  http_method         = "${aws_api_gateway_method.options.http_method}"
  status_code         = "${var.ok_status_code}"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "${var.cors_allowed_methods}",
    "method.response.header.Access-Control-Allow-Origin" = "${var.cors_allowed_origin}"
  }
  depends_on = [
    "aws_api_gateway_integration.options-integration",
    "aws_api_gateway_method_response.options-response"
  ]
}
