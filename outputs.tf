# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "host_ocid" {
  value = module.create_compute_instance.host_details.id
}

output "dashboard" {
  value = "https://cloud.oracle.com/loganalytics/explorer?viz=records_histogram&query=Entity%20%3D%20${local.db_name}%20%7C%20timestats%20count(Action)%20by%20%27User%20Name%20(Originating)%27&vizOptions=%7B%22customVizOpt%22%3A%7B%22primaryFieldIname%22%3A%22mbody%22%7D%7D&scopeFilters=lg%3Aroot%2Ctrue%3Brs%3A${var.compartment_ocid}%2Ctrue&timeNum=7&timeUnit=DAYS"
}

output "agent_dashboard" {
  value = format("https://cloud.oracle.com/macs/%s?dashId=agent_dashboard_100",module.macs_interactions.agent_details.id)
}

output "entity_dashboard" {
  value = format("https://cloud.oracle.com/loganalytics/entityDetails/%s",module.la_entity.entity_details.id)
}
