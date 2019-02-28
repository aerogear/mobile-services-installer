Here are the steps to release an APB:

1. Check the apb.yml file inside the APB repo to make sure it is up to date. 
    - To change the icon for the APB, change the value in `metadata.imageUrl`. NOTE: you can also use base64 encoded value. For example: `imageUrl: "data:image/png;base64,<based64 encoded content>".
2. Update the Dockerfile by running `apb build`. NOTE: some repos also have mutliple docker files for productisation process, you need to manualy copy changes over from one to another, espeically the value for `com.redhat.apb.spec`. It is base64 encoded content.
3. Verify the APB by building an image and deploy it somewhere. If `apb push` works for you, you should be easily verify it locally. Otherwise you may need to build an image with the docker file, and push it to a remote registry. Then change the registry in [aerogearcatalog_registry.yaml.j2](./roles/ansible-service-broker-setup/templates/aerogearcatalog_registry.yaml.j2), and ran the installer. To force the service catalog to be refreshed, ran the following command:
    ```
    oc get clusterservicebroker ansible-service-broker -o=json > broker.json
    oc delete clusterservicebroker ansible-service-broker
    oc create -f broker.json
    ```
Then you should be able to run the APB from the service catalog.
4. Once the changes is verified yourself, create a new PR to get it reviewed.
5. Once the PR is merged to master, create a new tag for the repo. It should follow the semver convention to bump the version.
6. Once the tag is created, there should be a docker build triggered for the apb. Wait until the tag is showing up in dockerhub.
7. Once the tag is in dockerhub, update the [versions.yml](./version.yml) file to bump the version of the apb. Create a PR and once reviewed, merge it. 
8. Done.
