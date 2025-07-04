## VPN

data "azuread_application" "vpn_app" {
  display_name = "dx-${var.env_short}-app-vpn"
}

module "vpn" {
  source = "github.com/pagopa/terraform-azurerm-v4//vpn_gateway?ref=v1.9.0"

  name                  = "${var.project}-vgw-01"
  location              = var.location
  resource_group_name   = var.resource_group_name
  sku                   = "VpnGw1"
  pip_sku               = "Standard"
  pip_allocation_method = "Static"
  subnet_id             = var.vpn_subnet_id

  vpn_client_configuration = [
    {
      address_space         = ["172.16.2.0/24"],
      vpn_client_protocols  = ["OpenVPN"],
      aad_audience          = data.azuread_application.vpn_app.client_id
      aad_issuer            = "https://sts.windows.net/${var.tenant_id}/"
      aad_tenant            = "https://login.microsoftonline.com/${var.tenant_id}"
      radius_server_address = null
      radius_server_secret  = null
      revoked_certificate   = []
      root_certificate      = []
    }
  ]

  tags = var.tags
}

## DNS FORWARDR
module "dns_forwarder" {
  source              = "github.com/pagopa/terraform-azurerm-v4//dns_forwarder?ref=v1.9.0"
  name                = "${var.project}-dns-forwarder-ci-01"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.dnsforwarder_subnet_id

  tags = var.tags
}
