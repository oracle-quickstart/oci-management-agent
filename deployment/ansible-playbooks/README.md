# **OCI Management Agent - Ansible Playbooks**

## About
This provides the automated agent deployment on multiple target hosts, where monitoring is required.<br>
Following sections will walk you through the pre-requisites, configuration and executing the playbooks.<br>
The current playbooks works for linux based hosts, but this can be extended to other operating systems as well.
<br/><br/>
## Pre-requisites
- Make sure ansible (version 2.9 or above version) is installed on localhost from where the deployment is to be initiated.
refer: https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html
- Make sure python3 (version 3.6 or above version) is installed in all target hosts and localhost from where the deployment is initiated
refer: https://docs.python.org/3/using/unix.html#getting-and-installing-the-latest-version-of-python
- Make sure you have SSH capability on the target hosts and the user connecting through SSH has the capability to become root.
- You need to have OCI CLI installed and OCI configuration created only on the localhost from where the deployment is initiated.<br/>
refer: https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm#Quickstart

- You need ansible collection to execute playbooks and configured with OCI CLI on the localhost from where the deployment is initiated.<br/>
refer: https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/ansiblegetstarted.htm#Getting_Started_with_Oracle_Cloud_Infrastructure_and_Ansible
<br/><br/>
## Configuration
### Hosts file
- The hosts file contains the configurations for the playbooks.
  - target_hosts = where you want to install the agent
  - target_hosts:vars = target host specific variables
  - all:vars = global variables, which are applicable to all, including localhost

  Refer the hosts file for detailed information.

### Environment variables
- compartment_ocid: This specifies the compartment for the Management Agent. This needs to be set as environment variable.
<br>e.g.
```
export compartment_ocid=<your_compartment_ocid_goes_here> 
```
<br/><br/>
## Execution
### Installing agent
```
ansible-playbook -i hosts mgmt_agent_install.yaml -kK
```

### Upgrading agent
```
ansible-playbook -i hosts mgmt_agent_upgrade.yaml -kK
```

### Uninstalling agent
```
ansible-playbook -i hosts mgmt_agent_uninstall.yaml -kK
```

Note: 
- The -kK option is the shorthand of --ask-pass and  --ask-become-pass

- SSH password: The ssh user password<br>
- BECOME password[defaults to SSH password]: The password to become the root user.
<br/><br/>
## Verifying the execution of playbooks
- At the end of each playbook run, you should be able to see something similar like this for a successful execution

```
PLAY RECAP ***************************************************************************************************************************************************************
host1.subnetxyz.regionaplh1.oraclevcn.com : ok=10   changed=5    unreachable=0    failed=0    skipped=5    rescued=0    ignored=0   
localhost                  : ok=12   changed=1    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0    
```

- Go to oracle cloud - Observability & Management -  Management Agents - Agents
  - select the compartment and verify the installed agents
<br/><br/>
## Copyright
Copyright (c) 2022 Oracle and/or its affiliates.
