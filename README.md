# **OCI Management Agent Quick Start**

[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/myrepo/mydirectory/master.zip)


## Introduction

This stack automates the following:

* Creating Dynamic group and adding required policies for Management Agent
* Spinning up new Compute Instance 
* Enabling Management Agent on the created instance
* Deploying Logging Analytics Plugin on the Management Agent
* Configuration for monitoring Unified DB Audit Logs of ATP Instance

## Using this stack

1. Click on above Deploy to Oracle Cloud button which will redirect you to OCI console and prompt a dialogue box with further steps on deploying this application.
2. Configure the variables for the infrastructure resources that this stack will create when you run the apply job for this execution plan.
3. This stack contains cloud-init scripts which runs after instance is created (which means terraform has completed). Due to this, it might take some time until you can see agent been registered with Logging Analaytics on UI. 
4. Note that this stack assumes that you have already on-boarded your tenancy to Logging Analytics. If you have not already done that please follow [these](https://docs.oracle.com/en-us/iaas/logging-analytics/doc/configure-your-service.html) steps to on-board your tenancy

Note: For more details on Management Agent please refer
https://docs.oracle.com/en-us/iaas/management-agents/index.html
