# Copyright (c) 2024, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "policy_name" {
  description = "Name of the policy created"
  value       = "${local.mgmtagent_policy_name}"
}