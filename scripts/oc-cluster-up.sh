#!/usr/bin/env bash

set -e

__FILENAME="$0"
__DIRNAME="$(cd "$(dirname "$__FILENAME")" && pwd)"

if [[ -L "$__FILENAME" ]]; then
    echo "warn: because '$__FILENAME' is a symlink it could cause unexpected failures" >&2
fi

function ipv4() {
    ifconfig "$(
        netstat -nr |
            awk '{if (($1 == "0.0.0.0" || $1 == "default") && $2 != "0.0.0.0" && $2 ~ /[0-9\.]+{4}/){print $NF;} }' |
            head -n1
    )" |
        grep 'inet ' |
        awk '{print $2}'
}

BASE_DIR="$__DIRNAME/../openshift.local.clusterup"
PUBLIC_IP="$(ipv4)"
REGISTRY_USERNAME="${REGISTRY_USERNAME:-}"
REGISTRY_PASSWORD="${REGISTRY_PASSWORD:-}"

function help() {
    echo "$__FILENAME OPTIONS"
    echo
    echo "Options:"
    echo "  --base-dir                  (default: $BASE_DIR)"
    echo "  --public-ip ipv4            (default: $PUBLIC_IP)"
    echo "  --registry-username string  Username for registry.redhat.io (env: REGISTRY_USERNAME)"
    echo "  --registry-password string  Password for registry.redhat.io (env: REGISTRY_PASSWORD)"
}

while [[ $# -gt 0 ]]; do
    case "$1" in
    -h | --help)
        help
        exit 0
        ;;
    --base-dir)
        BASE_DIR="$2"
        shift
        shift
        ;;
    --public-ip)
        PUBLIC_IP="$2"
        shift
        shift
        ;;
    --registry-username)
        REGISTRY_USERNAME="$2"
        shift
        shift
        ;;
    --registry-password)
        REGISTRY_PASSWORD="$2"
        shift
        shift
        ;;
    *)
        echo "error: invalid option '$1'"
        exit 1
        ;;
    esac
done

if [[ -z "$REGISTRY_USERNAME" ]] || [[ -z "$REGISTRY_PASSWORD" ]]; then
    echo "error: REGISTRY_USERNAME and/or REGISTRY_PASSWORD are not defined" >&2
    exit 1
fi

function clusterup() {

    local args=(
        --base-dir "$BASE_DIR"
        --public-hostname "$PUBLIC_IP.nip.io"
        --routing-suffix "$PUBLIC_IP.nip.io"
        --no-proxy "$PUBLIC_IP"
    )

    local post
    if [[ ! -f "$BASE_DIR/components.json" ]]; then
        post="true"

        # only write the configuration but don't start the cluster
        oc cluster up \
            --write-config \
            "${args[@]}"

        # allow all origins '.*'
        for a in \
            kube-apiserver \
            openshift-apiserver \
            openshift-controller-manager; do

            sed -i 's/^\(corsAllowedOrigins:\)$/\1\n- .*/' "$BASE_DIR/$a/master-config.yaml"
        done

    else
        echo "warn: using existing configuration" >&2
    fi

    # start the cluster
    oc cluster up "${args[@]}"

    if [[ "$post" == "true" ]]; then

        # add additional components
        for c in \
            service-catalog \
            template-service-broker \
            automation-service-broker; do

            oc cluster add --base-dir "$BASE_DIR" "$c"
        done

        # generate self signed certificate
        ROUTING_SUFFIX="$PUBLIC_IP.nip.io" \
            CONTROLLER_MANAGER_DIR="$BASE_DIR/openshift-controller-manager" \
            "$__DIRNAME/setup-router-certs.sh"
    fi
}

if ! curl -k "https://$PUBLIC_IP.nip.io:8443" >/dev/null 2>&1; then
    clusterup
else
    echo "warn: skipping oc cluster up because it's already running" >&2
fi

oc login -u system:admin

# install mobile services
ansible-playbook "$__DIRNAME/../install-mobile-services.yml" \
    -e registry_username="$REGISTRY_USERNAME" \
    -e registry_password="$REGISTRY_PASSWORD" \
    -e openshift_master_url="https://$PUBLIC_IP.nip.io:8443"
