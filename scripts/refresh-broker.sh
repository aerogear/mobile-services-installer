#!/usr/bin/env bash

set -e

cd "$(dirname "$0")"

defaultbroker="openshift-automation-service-broker"

broker=${broker:-$defaultbroker}

echo "refreshing broker $broker"

oc get clusterservicebroker $broker -o=json > broker.json
oc delete clusterservicebroker $broker
oc create -f broker.json
rm broker.json