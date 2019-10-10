#!/usr/bin/env bash

cd "$(dirname "$0")"

oc cluster down

if [ -z "${DEFAULT_CLUSTER_IP}" ]; then
    export DEFAULT_CLUSTER_IP=$(ifconfig $(netstat -nr | awk '{if (($1 == "0.0.0.0" || $1 == "default") && $2 != "0.0.0.0" && $2 ~ /[0-9\.]+{4}/){print $NF;} }' | head -n1) | grep 'inet ' | awk '{print $2}')
fi

oc cluster up \
    --public-hostname=$DEFAULT_CLUSTER_IP.nip.io \
    --routing-suffix=$DEFAULT_CLUSTER_IP.nip.io \
    --no-proxy=$DEFAULT_CLUSTER_IP || exit 1

oc cluster add service-catalog
oc cluster add automation-service-broker
oc cluster add template-service-broker

oc login -u system:admin

chcon -Rt svirt_sandbox_file_t .

ansible-playbook ../install-mobile-services.yml -e registry_service_account_username=$REGISTRY_USERNAME -e registry_password=$REGISTRY_PASSWORD -e openshift_master_url="https://$(minishift ip)"

export ROUTING_SUFFIX=$DEFAULT_CLUSTER_IP.nip.io
export CONTROLLER_MANAGER_DIR="$(pwd)/openshift.local.clusterup/openshift-controller-manager"

./setup-router-certs.sh
