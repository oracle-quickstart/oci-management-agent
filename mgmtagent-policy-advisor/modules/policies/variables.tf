# Copyright (c) 2024, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "policy_name" {
  type        = string
  description = "The name you assign to the policy during creation."
}

variable "policy_description" {
  type        = string
  description = "The description you assign to the policy."
}

variable "policy_statements" {
  type        = list(string)
  description = "Consists of one or more policy statements. "
}

variable "policy_compartment_id" {
  type        = string
  description = "The compartment id to assign this policy to."
}