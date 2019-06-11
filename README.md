# Mobile Services Installer

This repo contains ansible playbook for installing Mobile Services into existing OpenShift 3.11 instance.
It also contains scripts for local development of Mobile Services (using `Minishift` or `oc cluster up`).

### Prerequisites:
* Ansible 2.7.6
* Running instance of OpenShift 3.11 with Ansible Service Broker
* Cluster-admin access to targeted OpenShift instance
* `oc` client v3.11

## Installation

1. Open a terminal and log in to an OpenShift target.
2. To ensure you are targeting an OpenShift instance with the Ansible Service Broker installed, run `oc projects` and search for `openshift-automation-service-broker` or `openshift-ansible-service-broker`.
3. Use `git` to clone https://github.com/aerogear/mobile-services-installer and `cd` into the repo.
4. Run the installation playbook:

    If you want to use the community releases, run the following command:

    ```
    ansible-playbook install-mobile-services.yml
    ```

    If you want to use the productized releases from Red Hat Container Catalog, please make sure you first follow the instructions on [this page](https://docs.openshift.com/container-platform/3.11/install_config/configuring_red_hat_registry.html) to ensure that your OpenShift cluster is configured to be able to pull from registry.redhat.io.

    Additionally, create a secret that will store the credentials, as described [here](https://docs.openshift.com/container-platform/3.11/install_config/oab_broker_configuration.html#oab-config-registry-storing-creds), and then use the following command:

    ```
    ansible-playbook install-mobile-services.yml -e "ansible_playbookbundle_registry_type=rhcc" -e "rhcc_registry_auth_name=<name of the secret>"
    ```

5. It will take a few minutes to redeploy and load all Mobile Services to Service Catalog. If you want to force the service catalog to refresh, run the following command:

    ```
    oc get clusterservicebroker ansible-service-broker -o=json > broker.json
    oc delete clusterservicebroker ansible-service-broker
    oc create -f broker.json
    ```

6. Verify that installation was successful by navigating to https://your-openshift-instance-url.com/console/catalog. A new tab `Mobile` should appear in the catalog.

## Setup services for demo

If you want to also setup all the required services for a demo, you can run this playbook:

```
ansible-playbook setup-demo.yml
```

This playbook will:

* Provision all the mobile services into a namespace, including showcase server.
* Create a mobile client for the showcase app.
* Bind all the available services to the showcase app (if no push information is provided, then push service won't be bound)
* Make sure the showcase server app is protected by the IDM service, and supports file upload.
* Setup the following users in the IDM service
  * User 1:
    * username: admin
    * password: admin
    * realm role: admin
    * client role for the showcase app: admin
  * User 2:
    * username: developer
    * password: developer
    * realm role: developer
    * client role for the showcase app: developer

You can then login to the Mobile Developer Console and copy the configuration for the showcase app, and paste it into the `mobile-services.json` file for the showcase client app.

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
