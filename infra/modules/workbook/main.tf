# ------------------------------------------------------------------------------------------------------
# DEPLOY WORKBOOK
# ------------------------------------------------------------------------------------------------------
resource "random_uuid" "workbook_name" {
}

resource "azurerm_application_insights_workbook" "workbook" {
  name                = random_uuid.workbook_name.result
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
  display_name        = "Azure OpenAI Monitoring Workbook"
  data_json           = file("${path.module}/workbook.json")
}
