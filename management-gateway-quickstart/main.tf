# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  timestamp                    = formatdate("YYYYMMDDhhmmss", timestamp())
  mgmtgateway_dynamic_group_name = "Management_Gateway_Dynamic_Group_${local.timestamp}"
  mgmtgateway_credential_group_name = "Credential_Dynamic_Group_${local.timestamp}"
  mgmtgateway_policy_name        = "Management_Gateway_Policies_${local.timestamp}"
}

# Create gateway dynamic group
module "create_mgmt_gateway_dynamicgroup" {
  source = "./modules/dynamicgroup"

  providers = {
    oci = oci.home
  }

  tenancy_ocid              = var.tenancy_ocid
  dynamic_group_name        = local.mgmtgateway_dynamic_group_name
  dynamic_group_description = "This is the dynamic group created by Gateway stack"
  matching_rule             = "ALL {resource.type='managementagent', resource.compartment.id = '${var.policy_compartment_id}'}"
}

# Create credential dynamic group
module "create_mgmt_gateway_credential_dynamicgroup" {
  source = "./modules/dynamicgroup"

  providers = {
    oci = oci.home
  }

  tenancy_ocid              = var.tenancy_ocid
  dynamic_group_name        = local.mgmtgateway_credential_group_name
  dynamic_group_description = "This is the credential dynamic group created by Gateway stack"
  matching_rule             = "ALL {resource.type='certificateauthority', resource.compartment.id = '${var.policy_compartment_id}'}"
}

# Create policies
module "create_mgmt_gateway_policies" {
  depends_on = [
    module.create_mgmt_gateway_dynamicgroup, module.create_mgmt_gateway_credential_dynamicgroup
  ]

  source = "./modules/policy"

  providers = {
    oci = oci.home
  }

  policy_name           = local.mgmtgateway_policy_name
  policy_description    = "This policy allows to manage Management Gateways"
  policy_compartment_id = var.policy_compartment_id
  policy_statements = [
    "ALLOW DYNAMIC-GROUP ${local.mgmtgateway_dynamic_group_name} TO MANAGE vaults IN COMPARTMENT ID ${var.policy_compartment_id} where any{request.permission='VAULT_CREATE', request.permission='VAULT_INSPECT', request.permission='VAULT_READ', request.permission='VAULT_CREATE_KEY',request.permission='VAULT_IMPORT_KEY',request.permission= 'VAULT_CREATE_SECRET'}",
    "ALLOW DYNAMIC-GROUP ${local.mgmtgateway_dynamic_group_name} TO MANAGE keys IN COMPARTMENT ID ${var.policy_compartment_id} where any{request.permission='KEY_CREATE', request.permission='KEY_INSPECT', request.permission='KEY_READ'}",
    "ALLOW DYNAMIC-GROUP ${local.mgmtgateway_dynamic_group_name} TO USE key-delegate IN COMPARTMENT ID ${var.policy_compartment_id}",
    "ALLOW DYNAMIC-GROUP ${local.mgmtgateway_dynamic_group_name} TO READ leaf-certificate-bundle IN COMPARTMENT ID ${var.policy_compartment_id}",
    "ALLOW DYNAMIC-GROUP ${local.mgmtgateway_dynamic_group_name} TO READ certificate-authority-bundle IN COMPARTMENT ID ${var.policy_compartment_id}",
    "ALLOW DYNAMIC-GROUP ${local.mgmtgateway_dynamic_group_name} TO MANAGE certificate-authorities IN COMPARTMENT ID ${var.policy_compartment_id} where any{request.permission='CERTIFICATE_AUTHORITY_CREATE', request.permission='CERTIFICATE_AUTHORITY_INSPECT', request.permission='CERTIFICATE_AUTHORITY_READ'}",
    "ALLOW DYNAMIC-GROUP ${local.mgmtgateway_dynamic_group_name} TO USE certificate-authority-delegates IN COMPARTMENT ID ${var.policy_compartment_id}",
    "ALLOW DYNAMIC-GROUP ${local.mgmtgateway_dynamic_group_name} TO MANAGE leaf-certificates IN COMPARTMENT ID ${var.policy_compartment_id} where any{request.permission='CERTIFICATE_CREATE', request.permission = 'CERTIFICATE_INSPECT', request.permission = 'CERTIFICATE_UPDATE', request.permission = 'CERTIFICATE_READ'}",
    "ALLOW DYNAMIC-GROUP ${local.mgmtgateway_dynamic_group_name} TO MANAGE leaf-certificates IN COMPARTMENT ID ${var.policy_compartment_id} where all{request.permission='CERTIFICATE_DELETE', target.leaf-certificate.name=request.principal.id}",
    "ALLOW DYNAMIC-GROUP ${local.mgmtgateway_credential_group_name} TO USE certificate-authority-delegates in COMPARTMENT ID ${var.policy_compartment_id}",
    "ALLOW DYNAMIC-GROUP ${local.mgmtgateway_credential_group_name} TO USE vaults in COMPARTMENT ID ${var.policy_compartment_id}",
    "ALLOW DYNAMIC-GROUP ${local.mgmtgateway_credential_group_name} TO USE keys in COMPARTMENT ID ${var.policy_compartment_id}"
  ]
}
