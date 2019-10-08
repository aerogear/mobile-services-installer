# Mobile Services Installer

This repo contains ansible playbook for installing Mobile Services into existing OpenShift 3.11 instance.
It also contains scripts for local development of Mobile Services (using `Minishift` or `oc cluster up`).

### Prerequisites:
* Ansible 2.7.6
* Running instance of OpenShift 3.11
  * If you are using minishift, it is recommended to allocate at least 6 vCPUs and 6GB of memory to it.
* Cluster-admin access to targeted OpenShift instance
* `oc` client v3.11
* A service account to access `https://registry.redhat.io`.
  * This is because IDM service uses productized images that are stored in this registry.
  * To get a service account, go to `https://registry.redhat.io`, then click on `Service Account` tab on the top right corner, and then login using your Red Hat developer account. Click on `New Service Account` to create a new one. Take note of the username and password.
  * For more information, please check [Accessing and Configuring the Red Hat Registry](https://docs.openshift.com/container-platform/3.11/install_config/configuring_red_hat_registry.html).

## Installation

. Open a terminal and log in to an OpenShift target.
. Use `git` to clone https://github.com/aerogear/mobile-services-installer and `cd` into the repo.
. Run the installation playbook:
  
  ```
  ansible-playbook install-mobile-services.yml -e registry_username="<registry_service_account_username>" -e registry_password="<registry_service_account_password>"
  ```
. Once the installation is completed, wait for all the pods to be running in the `mobile-developer-services` namespace.
  ```
  oc get pods -w -n mobile-developer-services
  ```
. Once all the pods are running, you can then get the url of the mobile developer console and login.

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
