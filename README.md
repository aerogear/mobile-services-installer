# Mobile Services Installer

This repo contains ansible playbook for installing Mobile Services into existing OpenShift 3.11 instance. 

It also contains scripts for local development of Mobile Services (using `Minishift` or `oc cluster up`).

### Prerequisites:
* Ansible 2.7.6
* Running instance of OpenShift 3.11 with Ansible Service Broker
* Cluster-admin access to targeted OpenShift instance
* `oc` client v3.11

## Installation

1. Make sure you are targeting OpenShift instance with installed Ansible Service Broker (run `oc projects` and search for `openshift-automation-service-broker` or `openshift-ansible-service-broker`)
2. Run the installation playbook:
    
    If you want to use the community releases, run the following command:

    ```
    ansible-playbook install-mobile-services.yml
    ```

    If you want to use the productized releases from Red Hat Container Catalog, please use the following command:

    ```
    ansible-playbook install-mobile-services.yml -e "ansible_playbookbundle_registry_type=rhcc"
    ```

    If authentication is required, you can set them via these variables: `rhcc_registry_auth_name` and `rhcc_registry_auth_type`. For more information about these variables, please check [this document](https://github.com/openshift/ansible-service-broker/blob/master/docs/config.md#registry-configuration).

3. It will take a few minutes to redeploy and load all Mobile Services to Service Catalog. If you want to force the service catalog to refresh, run the following command:

    ```
    oc get clusterservicebroker ansible-service-broker -o=json > broker.json
    oc delete clusterservicebroker ansible-service-broker
    oc create -f broker.json
    ```

4. Verify that installation was successful by navigating to https://your-openshift-instance-url.com/console/catalog. A new tab `Mobile` should appear in the catalog.

## Local development

By following next steps, you can spin up your local OpenShift instance with Mobile Services already installed.

:penguin: Linux

You may need to configure your firewall first:

```
sudo firewall-cmd --permanent --add-port=8443/tcp
sudo firewall-cmd --permanent --add-port=8053/tcp
sudo firewall-cmd --permanent --add-port=53/udp
sudo firewall-cmd --permanent --add-port=443/tcp
sudo firewall-cmd --permanent --add-port=80/tcp
sudo firewall-cmd --reload
```

Download [archive with oc client binary](https://github.com/openshift/origin/releases/tag/v3.11.0), extract it, add it to your `$PATH` and run:

```
./scripts/oc-cluster-up.sh
```

See [OpenShift documentation](https://github.com/openshift/origin/blob/master/docs/cluster_up_down.md) for more details.

:apple: Mac

Since `oc cluster up` is causing problems for users using Mac OS (since OpenShift version 3.10), it is advised to use Minishift as an alternative.

To spin up OpenShift 3.11 cluster locally, run:

```
./scripts/minishift.sh
```

Once the setup is complete, it is possible to stop the cluster with `minishift stop` and then run it again with `minishift start`.

See [Minishift](https://docs.okd.io/latest/minishift/getting-started/index.html) documentation for more details.
