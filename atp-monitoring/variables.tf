# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "tenancy_ocid" {
  type        = string
  description = "The OCID of the tenancy."
}

variable "compartment_ocid" {
  type        = string
  description = "The compartment OCID where all new resources will be created"
}

variable "region" {
  type        = string
  description = "OCI region"
}

variable "instance_name" {
  type        = string
  description = "Display name for compute instance"
  default     = "ATP-MgmtAgent"
}

variable "availability_domain" {
  type        = string
  description = "The availability domain of the instance"
}

variable "instance_shape" {
  type        = string
  description = "The shape of an instance. The shape determines the number of CPUs, amount of memory, and other resources allocated to the instance."
}

variable "vcn_ocid" {
  type        = string
  description = "The OCID of the VCN to create the instance in."
}

variable "subnet_ocid" {
  type        = string
  description = "The OCID of the subnet to create the VNIC in."
}

variable "user_ssh_secret" {
  description = "Public SSH keys to be included in the ~/.ssh/authorized_keys file for the default user on the instance. "
}

variable "atp" {
  type        = string
  description = "ATP OCID to monitor"
}

variable "atp_credentials" {
  type        = string
  description = "OCID of secret in vault to use for connecting to ATP"
}

variable "atp_username" {
  type        = string
  description = "Username for connecting to ATP"
}

variable "atp_level" {
  type        = string
  default     = "medium"
  description = "Level of performance and concurrency for Autonomous Database."
}

variable "log_group_ocid" {
  type        = string
  description = "The unique identifier of the log group to use when auto-associting the log source to eligible entities."
}

variable "setup_policies" {
  type        = bool
  default     = true
  description = "Setup IAM policies or not"
}