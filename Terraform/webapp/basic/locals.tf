 
# in tags section: tags = local.common_tags

locals {
    common_tags = {
        company = var.company
        business_unit = "$(var.company}-${var.business_unit}"
    }

}
