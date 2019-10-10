# Mobile Services Installer

This repo contains ansible playbook for installing Mobile Services into existing OpenShift 3.11 instance.
It also contains scripts for local development of Mobile Services (using `Minishift` or `oc cluster up`).

## Prerequisites:

* Ansible version 2.7.6 and above
* Running instance of OpenShift 3.11
  * If you are using minishift, it is recommended to allocate at least 6 vCPUs and 6GB of memory to it.
* Cluster-admin access to targeted OpenShift instance
* `oc` client v3.11
* If you are using minishift, or if the OpenShift cluster doesn't already have a secret to access `https://registry.redhat.io`, then a service account is required to access `https://registry.redhat.io`.
  * This is because IDM service uses productized images that are stored in this registry.
  * To get a service account, go to `https://registry.redhat.io`, then click on `Service Accounts` tab on the top right corner, and then login using your Red Hat developer account. Click on `New Service Account` to create a new one. Take note of the username and password.
  * For more information, please check [Accessing and Configuring the Red Hat Registry](https://docs.openshift.com/container-platform/3.11/install_config/configuring_red_hat_registry.html).

## Installation

1. Open a terminal and make sure you are logged in to the target OpenShift cluster as a cluster-admin using `oc`
2. Use `git` to clone https://github.com/aerogear/mobile-services-installer and `cd` into the repo.
3. Run the installation playbook:
  
    ```
    ansible-playbook install-mobile-services.yml -e registry_username="<registry_service_account_username>" -e registry_password="<registry_service_account_password>" -e openshift_master_url="<public_url_of_openshift_master>"
    ```
    
    If the cluster can already access the Red Hat container registry, you can skip the part that sets up the pull secrets:

    ```
    ansible-playbook install-mobile-services.yml -e openshift_master_url="<public_url_of_openshift_master>" --skip-tags "pullsecret"
    ```
4. You will also need to update the CORS configuration of the OpenShift cluster to allow the mobile developer console to communicate with the OpenShift API server (you only need to do this once). 
    * If you are using minishift, you should run [this script](./scripts/minishift-cors.sh).
    * Otherwise, you should run [this playbook](./update-master-cors-config.yml) to update the master config of the OpenShift cluster. To run this playbook, you need to:
        1. Get the host names of the master nodes by running `oc get nodes`. Take notes of the host names.
        2. Copy [the sample hosts inventory file](./inventories/hosts.template), and update it to add the correct host names for master nodes.
        3. You should also make sure that you can ssh into the master nodes from the workstation.
        4. Run the playbook and specify the inventory file:
            ```
            ansible-playbook -i ./inventories/hosts update-master-cors-config.yml
            ```
            Please note that this playbook will restart the api and controller servers of the OpenShift cluster.

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
export REGISTRY_USERNAME=<registry_service_account_username>
export REGISTRY_PASSWORD=<registry_service_account_password>
./scripts/oc-cluster-up.sh
```

See [OpenShift documentation](https://github.com/openshift/origin/blob/master/docs/cluster_up_down.md) for more details.

:apple: Mac

Since `oc cluster up` is causing problems for users using Mac OS (since OpenShift version 3.10), it is advised to use Minishift as an alternative.

To spin up OpenShift 3.11 cluster locally, run:

```
export REGISTRY_USERNAME=<registry_service_account_username>
export REGISTRY_PASSWORD=<registry_service_account_password>
./scripts/minishift.sh
```

Once the setup is complete, it is possible to stop the cluster with `minishift stop` and then run it again with `minishift start`.

See [Minishift](https://docs.okd.io/latest/minishift/getting-started/index.html) documentation for more details.
