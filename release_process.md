# Overview

This document covers how to release AeroGear services/libraries upstream.

## Guidelines

* Each service/library can be released on its own upstream
* Release early, release often

## Steps

1. Release the service/library on its own first. It's up to the maintainers of each service to decide how and when to do a release and what level of testing needs to be performed against each release.
2. Once the new version of a service/library is released, the [version vector](./versions.yml) file should be updated to refect the latest release version of that service/library. The version number for `aerogear-mobile-services` in that file should be updated as well to reflect the new overarching version of the services/libraries.
3. Create a new PR for the updated release version, and merge.
4. Create a new tag for the new version of `aerogear-mobile-services`.