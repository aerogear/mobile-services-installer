#!/usr/bin/env bash

cd "$(dirname "$0")" || exit 1

minishift delete -f

minishift start || exit 1

oc login -u system:admin

ansible-playbook ../install-mobile-services.yml -e registry_service_account_username=$REGISTRY_USERNAME -e registry_password=$REGISTRY_PASSWORD -e openshift_master_url="https://$(minishift ip)"

export ROUTING_SUFFIX=$(minishift ip).nip.io
export MINISHIFT=true

./setup-router-certs.sh
