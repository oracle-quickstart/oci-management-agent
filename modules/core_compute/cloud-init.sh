Content-Type: multipart/mixed; boundary=MIMEBOUNDARY
MIME-Version: 1.0

--MIMEBOUNDARY
Content-Transfer-Encoding: 7bit
Content-Type: text/cloud-config
Mime-Version: 1.0

#cloud-config

output: {all: '| tee -a /var/log/cloud-init-output.log'}

logcfg: |
  [formatters]
  format=%(levelname)s %(asctime)s::: %(message)s


--MIMEBOUNDARY
Content-Transfer-Encoding: 7bit
Content-Type: text/x-shellscript
Mime-Version: 1.0

#!/bin/bash

# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

set -e
set -o pipefail

TMP_DIR=`pwd`/cloud_init_tmp
mkdir $TMP_DIR

BASE_DIR="/var/lib/oracle-cloud-agent/plugins/oci-managementagent"
CREDS_JSON_FILE=$TMP_DIR/upsertCreds.json
PLUGIN_OCID_FILE=$TMP_DIR/plugin.ocid
AGENT_OCID_FILE=$TMP_DIR/agent.ocid
LOG_GROUP_OCID_FILE=$TMP_DIR/loggroup.ocid
ATP_WALLET_ZIP="$BASE_DIR/atp_wallet.zip"
ATP_WALLET_DIR="$BASE_DIR/${db_name}_wallet"

startTime=10#$(date +"%M")
while true
do
    sleep 10s

    if [[ -d "$BASE_DIR/polaris/agent_inst/discovery/PrometheusEmitter" && ! -f "$BASE_DIR/polaris/agent_inst/config/security/resource/agent.lifecycle" ]]; then
        echo "Agent is available now"
        break
    else
        echo "Waiting for agent to become available..."
    fi

    diff=$((endTime - startTime))

    #Wait for max 5 mins
    if (( $diff >= 5 )); then
        echo "Timeout: $diff mins, timedout!"
        break
    fi
done

echo "Installing oci-cli for fetching secrets"

yum -y install python36-oci-cli

# Read agent ocid file
source $BASE_DIR/polaris/agent_inst/config/security/resource/agent.ocid

# Create agent.ocid file for CLI
cat > $AGENT_OCID_FILE <<EOF
[
"$agent"
]
EOF

# Get plugin ocid and create plugin.ocid
oci --auth instance_principal management-agent plugin list --compartment-id ${compartment_ocid} --query "data[?name == 'logan'].id" > $PLUGIN_OCID_FILE

# Deploy logan plugin
oci --auth instance_principal management-agent agent deploy-plugins --agent-compartment-id "${compartment_ocid}" --agent-ids file://$AGENT_OCID_FILE --plugin-ids file://$PLUGIN_OCID_FILE --wait-for-state SUCCEEDED

echo "Successfully deployed logan plugin"

# Get secret from vault
password=$(oci secrets secret-bundle get --auth instance_principal --raw-output --secret-id ${secret_ocid} --query "data.\"secret-bundle-content\".content" | base64 -d )

# Random 15 char password for wallet
randomPass=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c15)
# Make sure it contains atleast one number
randomPass="$randomPass$((RANDOM%10))"
# Shuffle it
randomPass=$( echo $randomPass | fold -w1 | shuf | tr -d '\n')

# Get ATP wallet for single DB instance
oci --auth instance_principal db autonomous-database generate-wallet --autonomous-database-id ${db_ocid} --file $ATP_WALLET_ZIP --password $randomPass --generate-type SINGLE

# Get SSL Server Cert DN
serverCertDn=$(oci --auth instance_principal db autonomous-database get --raw-output --autonomous-database-id ${db_ocid} --query "data.\"connection-strings\".\"profiles\"[?\"display-name\" == '${level}'].value | [0]" | grep -oP 'ssl_server_cert_dn="\K[^"]+')

# Unzip downloaded wallet and fix permissions
unzip $ATP_WALLET_ZIP -d $ATP_WALLET_DIR
chown -R oracle-cloud-agent:oracle-cloud-agent $ATP_WALLET_DIR
chmod 600 $ATP_WALLET_DIR/*
chmod 700 $ATP_WALLET_DIR

# Create upsertCreds.json for cred utility
cat > $CREDS_JSON_FILE <<EOF
{
"source": "lacollector.la_database_sql",
"name": "LCAgentDBCreds.${db_name}",
"type": "DBTCPSCreds",
"description":"This is a TCPS credential used to connect to ATP",
"usage": "LOGANALYTICS",
"disabled": "false",
"properties":[
        {"name":"DBUserName","value":"CLEAR[${username}]"},
        {"name":"DBPassword","value":"CLEAR[$password]"},
        {"name":"ssl_trustStoreType","value":"JKS"},
        {"name":"ssl_trustStoreLocation","value":"$ATP_WALLET_DIR/truststore.jks"},
        {"name":"ssl_trustStorePassword","value":"CLEAR[$randomPass]"},
        {"name":"ssl_keyStoreType","value":"JKS"},
        {"name":"ssl_keyStoreLocation","value":"$ATP_WALLET_DIR/keystore.jks"},
        {"name":"ssl_keyStorePassword","value":"CLEAR[$randomPass]"},
        {"name":"ssl_server_cert_dn","value":"$serverCertDn"}]
}
EOF

# Add creds in agent wallet
sudo -u oracle-cloud-agent bash -c "cat $CREDS_JSON_FILE | bash /var/lib/oracle-cloud-agent/plugins/oci-managementagent/polaris/agent_inst/bin/credential_mgmt.sh -s logan -o upsertCredentials"

echo "Successfully added secrets to agent wallet"

# Create log group ocid file for auto association
cat > $LOG_GROUP_OCID_FILE <<EOF
[
  {
    "logGroupId": "${log_group_ocid}"
  }
]
EOF

# Enable auto association
oci log-analytics --auth instance_principal source enable-auto-assoc --namespace-name ${namespace} --source-name "unifieddbauditlogfromdbsource122" --items file://$LOG_GROUP_OCID_FILE
echo "Successfully enabled auto association"

# Delete temporarily create files
rm -rf $TMP_DIR
rm $ATP_WALLET_ZIP

echo "Deleted temporary files"

--MIMEBOUNDARY--