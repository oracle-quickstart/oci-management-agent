<!--
# Copyright (c) 2024, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.
-->

# **OCI Management Agent Quick Start**

Management Agent is a service that provides low latency interactive communication and data collection between Oracle Cloud Infrastructure and any other sources.

This Github repository is a collection of various quick start applications offered by Management Agent. Each project under this repository has its own individual README.md which describes it in more detail.

At a high level we have following quick start apps:

> [!CAUTION]
   Management Agent helm charts for Kubernetes Monitoring are no longer maintained and monitored. Oracle Management Agent helm charts are now part of the OCI Kubernetes Monitoring Solution. Please use the helm charts from [Oracle QuickStart for OCI Kubernetes Monitoring](https://github.com/oracle-quickstart/oci-kubernetes-monitoring).

- [Kubernetes Monitoring](./kubernetes-monitoring/mgmtagent_helm/README.md):

    Oracle Management Agent helm charts are now part of the OCI Kubernetes Monitoring Solution. Please use the helm charts from [Oracle QuickStart for OCI Kubernetes Monitoring](https://github.com/oracle-quickstart/oci-kubernetes-monitoring).

- [ATP Monitoring](./atp-monitoring/README.md):

    This terraform app for monitoring audit logs from an Autonomous Database for transaction processing (ATP),automates the configuration needed to start processing ATP audit logs for analysis in the OCI Logging Analytics.

- [Managment Gateway Quick Start](./management-gateway-quickstart/README.md):

  This terraform app is for creating dynamic groups and policies required for Management Gateway before its installation.

- [Ansible Playbooks](./deployment/ansible-playbooks/README.md):

    This provides the automated agent deployment on multiple target hosts, where monitoring is required.<br>
    The current playbooks works for linux based hosts, but this can be extended to other operating systems as well.
    
- [Management Agent Policy Advisor](./mgmtagent-policy-advisor/README.md):

    This terraform app helps to setup the required IAM policies for management agents and agent install keys.
    
- [Sample Dashboards](./sample-dashboards/README.md):

    Sample Dashboards are provided to illustrate how metrics collected by Management Agent appear in the Management Dashboard.  
