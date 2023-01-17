<!--
# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.
-->

# **OCI Management Agent Quick Start**

Management Agent is a service that provides low latency interactive communication and data collection between Oracle Cloud Infrastructure and any other sources.

This Github repository is a collection of various quick start applications offered by Management Agent. Each project under this repository has its own individual README.md which describes it in more detail.

At a high level we have following quick start apps:

- [ATP Monitoring](./atp-monitoring/README.md):

    This terraform app for monitoring audit logs from an Autonomous Database for transaction processing (ATP),automates the configuration needed to start processing ATP audit logs for analysis in the OCI Logging Analytics.

- [Kubernetes Monitoring](./kubernetes-monitoring/mgmtagent_helm/README.md):

    Oracle Management Agent is now available to be deployed as a Docker Container. This helm chart application provides easy deployment way of Management Agent and offers out-of-box monitoring of Kubernetes Cluster.

- [Managment Gateway Quick Start](./management-gateway-quickstart/README.md):

  This terraform app is for creating dynamic groups and policies required for Management Gateway before its installation.

- [Ansible Playbooks](./deployment/ansible-playbooks/README.md):

    This provides the automated agent deployment on multiple target hosts, where monitoring is required.<br>
    The current playbooks works for linux based hosts, but this can be extended to other operating systems as well.
    