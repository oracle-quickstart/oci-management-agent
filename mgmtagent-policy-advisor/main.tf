# Copyright (c) 2024, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

data "oci_identity_group" "usergroup_data" {
    group_id = var.user_group_id
}

data "oci_identity_compartment" "compartment_data" {
    id = var.resource_compartment_id
}


locals{
    currentDateTime          = formatdate("YYYYMMDDhhmmss", timestamp())
    mgmtagent_policy_name    = var.policy_name != "" && var.policy_name != "ManagementAgent_Policy" ? var.policy_name : "ManagementAgent_Policy_${local.currentDateTime}"
    user_group_name          = data.oci_identity_group.usergroup_data.name
    policy_location          = var.resource_compartment_id == var.tenancy_ocid ? "TENANCY" : data.oci_identity_compartment.compartment_data.compartment_id == var.tenancy_ocid ? "COMPARTMENT ${data.oci_identity_compartment.compartment_data.name}" : "COMPARTMENT ID ${var.resource_compartment_id}"
    policy_statements_root   = [
        "ALLOW GROUP ${local.user_group_name} TO MANAGE management-agents IN ${local.policy_location}",
        "ALLOW GROUP ${local.user_group_name} TO MANAGE management-agent-install-keys IN ${local.policy_location}",
        "ALLOW GROUP ${local.user_group_name} TO READ METRICS IN ${local.policy_location}",
        "ALLOW GROUP ${local.user_group_name} TO READ ALARMS IN ${local.policy_location}",
        "ALLOW GROUP ${local.user_group_name} TO READ USERS IN TENANCY"
    ]
    policy_statements_nonroot = [
        "ALLOW GROUP ${local.user_group_name} TO MANAGE management-agents IN ${local.policy_location}",
        "ALLOW GROUP ${local.user_group_name} TO MANAGE management-agent-install-keys IN ${local.policy_location}",
        "ALLOW GROUP ${local.user_group_name} TO READ METRICS IN ${local.policy_location}",
        "ALLOW GROUP ${local.user_group_name} TO READ ALARMS IN ${local.policy_location}"
    ]
}


module "mgmtagent_policy_creation" {

    source = "./modules/policies"

    policy_name           = local.mgmtagent_policy_name
    policy_description    = "This policy allows to manage management agents"
    policy_compartment_id = var.policy_compartment_id
    policy_statements     = var.resource_compartment_id == var.tenancy_ocid ? local.policy_statements_root : local.policy_statements_nonroot

}