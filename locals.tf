#############################
# LOCALS — SAFE NAMING
#############################

locals {
  safe_prefix = substr(replace("${var.project}-${var.environment}", "-", ""), 0, 18)

  name_prefix = "${var.project}-${var.environment}"

  tags = {
    project     = var.project
    environment = var.environment
    managed_by  = "terraform"
  }
}
