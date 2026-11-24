provider "aws" {
  region = "us-east-2"
}

module "invoices" {
  source      = "../modules/secure-bucket"
  bucket_name = "danar-lab-invoices-2026"
  tags        = { Team = "finance" }
}

module "reports" {
  source      = "../modules/secure-bucket"
  bucket_name = "danar-lab-reports-2026"
}

output "invoices_bucket_arn" {
  value = module.invoices.bucket_arn
}

output "reports_bucket_arn" {
  value = module.reports.bucket_arn
}
