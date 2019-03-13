Here are the steps to release an APB:

1. Check the apb.yml file inside the APB repo to make sure it is up to date. 
    - To change the icon for the APB, change the value in `metadata.imageUrl`. NOTE: you can also use base64 encoded value. For example: `imageUrl: "data:image/png;base64,<based64 encoded content>".
2. Update the Dockerfile by running 
    ````
    apb bundle prepare -c Dockerfile
    apb bundle prepare -c Dockerfile.rhel7
    ````
3. Verify the APB by building an image and deploy it somewhere. If `apb build` and `apb push` works for you, you should be easily verify it locally. Otherwise you may need to build an image with the docker file, and push it to a remote registry. Then change the registry in [aerogearcatalog_registry.yaml.j2](./roles/ansible-service-broker-setup/templates/aerogearcatalog_registry.yaml.j2), and ran the installer. To force the service catalog to be refreshed, ran the following command:
    ```
    ./scripts/refresh-broker.sh
    ```
    Then you should be able to run the APB from the service catalog. If you see the following error:
    ```
    Error from server (NotFound): clusterservicebrokers.servicecatalog.k8s.io "openshift-automation-service-broker" not found
    ```
    It's most likely you are using an older version of OpenShift where the broker is still called `ansible-service-broker`. You can run the following command.
    ```
    broker=ansible-service-broker ./scripts/refresh-broker.sh
    ```
4. Once the changes is verified yourself, create a new PR to get it reviewed.
5. Once the PR is merged to master, create a new tag for the repo. It should follow the semver convention to bump the version.
6. Once the tag is created, there should be a docker build triggered for the apb. Wait until the tag is showing up in dockerhub.
7. Once the tag is in dockerhub, update the [versions.yml](./version.yml) file to bump the version of the apb. Create a PR and once reviewed, merge it. 
8. Done.
