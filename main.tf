# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

data "oci_objectstorage_namespace" "os-namespace" {
  compartment_id = var.compartment_ocid
}

data "oci_database_autonomous_database" "autonomous_database" {
  autonomous_database_id = var.atp
}

locals {
  namespace                    = data.oci_objectstorage_namespace.os-namespace.namespace
  db_displayname               = data.oci_database_autonomous_database.autonomous_database.display_name
  db_name                      = data.oci_database_autonomous_database.autonomous_database.db_name
  service_name                 = lower("${local.db_name}_${var.atp_level}")
  timestamp                    = formatdate("YYYYMMDDhhmmss", timestamp())
  instance_dynamic_group_name  = "Mgmtagent_Compute_Dynamicgroup_${local.timestamp}"
  instance_policy_name         = "Mgmtagent_Compute_Policies_${local.timestamp}"
  instance_tenancy_policy_name = "Mgmtagent_Tenancy_Policies_${local.timestamp}"
  mgmtagent_dynamic_group_name = "Mgmtagent_Dynamicgroup_${local.timestamp}"
  mgmtagent_policy_name        = "Mgmtagent_Policies_${local.timestamp}"
}

# Compute instance dynamic group and policies
module "create_instance_dynamicgroup" {
  source = "./modules/identity"

  count = var.setup_policies ? 1 : 0

  providers = {
    oci = oci.home
  }

  tenancy_ocid              = var.tenancy_ocid
  dynamic_group_name        = local.instance_dynamic_group_name
  dynamic_group_description = "This is the compute instance dynamic group created by Agent stack"
  matching_rule             = "ANY {instance.compartment.id = '${var.compartment_ocid}'}"

  policy_name           = local.instance_policy_name
  policy_description    = "This policy allows compute instances to manage Management agents"
  policy_compartment_id = var.compartment_ocid
  policy_statements = [
    "ALLOW DYNAMIC-GROUP ${local.instance_dynamic_group_name} TO MANAGE management-agents IN COMPARTMENT ID ${var.compartment_ocid}",
    "ALLOW DYNAMIC-GROUP ${local.instance_dynamic_group_name} TO READ secret-family in COMPARTMENT ID ${var.compartment_ocid} where target.secret.id = '${var.atp_credentials}'",
    "Allow DYNAMIC-GROUP ${local.instance_dynamic_group_name} to READ autonomous-database in COMPARTMENT ID ${var.compartment_ocid} where target.workloadType = 'OLTP'"
  ]
}

# Create policies for compute dynamic group at tenancy level
module "instance_tenancy_policies" {

  depends_on = [
    module.create_instance_dynamicgroup, module.create_mgmtagent_dynamicgroup
  ]

  source = "./modules/identity"

  count = var.setup_policies ? 1 : 0

  providers = {
    oci = oci.home
  }
  create_dynamicgroup   = false
  policy_name           = local.instance_tenancy_policy_name
  policy_description    = "These polices allow compute instances to enable entity auto association and Agents to upload logs to Log Analytics"
  policy_compartment_id = var.tenancy_ocid
  policy_statements = [
    "Allow DYNAMIC-GROUP ${local.instance_dynamic_group_name} to {LOG_ANALYTICS_SOURCE_ENABLE_AUTOASSOC} in tenancy",
    "Allow DYNAMIC-GROUP ${local.mgmtagent_dynamic_group_name} to {LOG_ANALYTICS_LOG_GROUP_UPLOAD_LOGS} in tenancy"
  ]

}

# Management agent dynamic group and policies
module "create_mgmtagent_dynamicgroup" {
  source = "./modules/identity"

  count = var.setup_policies ? 1 : 0

  providers = {
    oci = oci.home
  }

  tenancy_ocid              = var.tenancy_ocid
  dynamic_group_name        = local.mgmtagent_dynamic_group_name
  dynamic_group_description = "This is a Management Agent dynamic group created by Agent stack"
  matching_rule             = "ALL {resource.type='managementagent', resource.compartment.id='${var.compartment_ocid}'}"

  policy_name           = local.mgmtagent_policy_name
  policy_description    = "These are the required policies for Management Agent functionality"
  policy_compartment_id = var.compartment_ocid
  policy_statements = [
    "ALLOW DYNAMIC-GROUP ${local.mgmtagent_dynamic_group_name} TO MANAGE management-agents IN COMPARTMENT ID ${var.compartment_ocid}",
    "ALLOW DYNAMIC-GROUP ${local.mgmtagent_dynamic_group_name} TO USE METRICS IN COMPARTMENT ID ${var.compartment_ocid}"
  ]
}

module "create_compute_instance" {

  depends_on = [
    module.create_mgmtagent_dynamicgroup, module.create_instance_dynamicgroup, module.instance_tenancy_policies
  ]

  source = "./modules/core_compute"

  compartment_ocid    = var.compartment_ocid
  availability_domain = var.availability_domain
  display_name        = var.instance_name
  compute_shape       = var.instance_shape
  subnet_id           = var.subnet_ocid
  public_key          = var.user_ssh_secret
  db_secret_ocid      = var.atp_credentials
  db_user             = var.atp_username
  db_ocid             = var.atp
  db_name             = local.db_name
  service_name        = local.service_name
  namespace           = local.namespace
  log_group_ocid      = var.log_group_ocid
}

# This creates a 2 minutes delay that is required in further execution
module "wait_until_agent_is_ready" {
  depends_on = [
    module.create_compute_instance
  ]

  source          = "./modules/time_delay"
  wait_in_minutes = 2
}

module "macs_interactions" {
  # Wait for some time as agent creation might take time and might not be available immediately
  depends_on = [
    module.wait_until_agent_is_ready
  ]

  source = "./modules/macs"

  instance_ocid    = module.create_compute_instance.host_details.id
  compartment_ocid = var.compartment_ocid
}


# Creates Log Analytics entity
module "la_entity" {

  depends_on = [
    module.macs_interactions
  ]

  source = "./modules/logan_entity"

  compartment_id      = var.compartment_ocid
  namespace           = local.namespace
  entity_type_name    = "Autonomous Transaction Processing"
  name                = local.db_name
  management_agent_id = module.macs_interactions.agent_details.id
  properties          = tomap({ "service_name" = "${local.service_name}" })
  cloud_resource_id   = var.atp
}
