#  Example data ingest with Concert v1.0.2


---

- [Example data ingest with Concert v1.0.2](#example-data-ingest-with-concert-v102)
  - [Introduction](#introduction)
    - [Utility scripts](#utility-scripts)
    - [Terminology](#terminology)
      - [The Application entity](#the-application-entity)
      - [The Environment entity](#the-environment-entity)
    - [Software Bill of Materials (SBOM) for the App360 view](#software-bill-of-materials-sbom-for-the-app360-view)
    - [Data ingestion types](#data-ingestion-types)
  - [Generating ConcertDef and CycloneDX files](#generating-concertdef-and-cyclonedx-files)
    - [Generate the App SBOM](#generate-the-app-sbom)
    - [Generate the Build SBOM](#generate-the-build-sbom)
    - [Generate the inventory of Packages from source code](#generate-the-inventory-of-packages-from-source-code)
    - [Generate the inventory of Packages from the docker image](#generate-the-inventory-of-packages-from-the-docker-image)
    - [Generate a VDR from the source code](#generate-a-vdr-from-the-source-code)
    - [Generate a VDR from the docker image](#generate-a-vdr-from-the-docker-image)
  - [Ingestion](#ingestion)
    - [upload the App ConcertDef SBOM](#upload-the-app-concertdef-sbom)
    - [upload the Build SBOM](#upload-the-build-sbom)
    - [upload the CycloneDX inventory of packages from source code](#upload-the-cyclonedx-inventory-of-packages-from-source-code)
    - [upload the CycloneDX inventory of packages found in the image](#upload-the-cyclonedx-inventory-of-packages-found-in-the-image)
    - [upload the VDR from source code scan](#upload-the-vdr-from-source-code-scan)
    - [upload the VDR from image scan](#upload-the-vdr-from-image-scan)


---

## Introduction

This document describes the semantics behind the ConcertDef and CycloneDX formats with regards to correlating package dependencies with applications in IBM Concert. We will also generate VDR files for vulnerabilities found in source code and the Docker image built from that source code. We will then look at how Concert correlates such data and provides for prioritization & risk scores.

This git repository includes SBOM and other related files for the ['pyk8s'](https://github.com/sriramsrinivasangmail/pyk8s) example app. 

### Utility scripts

[toolkit.sh](./toolkit.sh): a script to simplify launching the Concert toolkit utilities inside of its Docker container with the source code and contents in this git repo mounted.  
- the utilities will generate content [`toolkit-data` mount] in the [./generated](./generated/) directory. We will then push (via the upload API) the SBOMs and other content from this location.
**Note**: pre-pull the toolkit image and alter the image reference appropriately in this script.

[push.sh](./push.sh): a collection of utility functions that use the Concert `/ingestion/api/v1/upload_files` endpoint. to push the SBOMs and VDRs.  
**Note**:  modify the script to point to your Concert server co-ordinates or set the appropriate environment variables such as the CONCERT_API_KEY prior to running this script (and avoid storing it in plaintext )

[../build.sh](../build.sh): a script to build a Docker image for the `pyk8s` python application.  
- For this example, we will not push this image to a Docker registry but rather just tag the image appropriately to simulate the use of a Docker registry.

```
(cd ../ && ./build.sh)

docker tag pyk8s:v1 myregistry:5000/sector7g/pyk8s:v2

```

**A note on vulnerabilities in the example**: the python [requirements.txt](../requirements.txt) file includes specific older versions of packages known to have vulnerabilities just to illustrate how vulnerabilities from source code is identified & processed by Concert.  Similarly, the [Dockerfile](../Dockerfile) refers to an older base image that is known to have vulnerabilities. 


###  Terminology

#### The Application entity

An Application is defined to include references to:

•	Source code repositories

•	Packages used in that Application

•	Images (such as Docker images) and other binaries that get deployed for that Application

•	Environments where the Application gets deployed

•	Access Points (such as API services etc.) 

#### The Environment entity

An Environment is defined to include references to:

•	Applications it hosts

•	Access points that it exposes – either private (within a specific network domain) or public (accessible outside the domain)

•	Resources  - these could be Nodes (machines),  Deployments/Pods etc. (inside Kubernetes) that are present inside that environment

### Software Bill of Materials (SBOM) for the App360 view

- Software Bill of Materials , as a standardized exchange format, play a critical role in describing Applications in the enterprise across the lifecycle.  SBOMs also have gained regulatory prominence as part of an overall Security of the Software Supply Chain. 

- Many enterprises have already started maintaining SBOMs and the expectation is that their existing CI/CD pipelines become the way to share such information with IBM Concert on a continuous basis.
 quick intros: https://www.ntia.gov/sites/default/files/publications/sbom_at_a_glance_apr2021_0.pdf    https://www.ntia.gov/sites/default/files/publications/sbom_faq_-_20201116_0.pdf 

(version 1.6:  https://cyclonedx.org/docs/1.6/json/
https://cyclonedx.org/guides/OWASP_CycloneDX-Authoritative-Guide-to-SBOM-en.pdf ) 

- IBM Concert uses the CycloneDX standard to ingest SBOMs as well as extends it for the 'ConcertDef' format for additional information and relationships. To understand more about the ConcertDef format, see [the documentation around ConcertDef](https://www.ibm.com/docs/en/concert?topic=topology-generating-concert-defined-sbom)

### Data ingestion types

1) **Application SBOM**:  (ConcertDef format)

The application SBOM  defines the application in Concert.  It includes the application's source code locations, the container images,libraries and binaries that are built from its source, what its service dependencies are etc.  For each application you need to onboard, you will need to create an application SBOM

2)	**Package SBOM**  (CycloneDX format) 

This is the inventory of packages present in a source code location and/or inside a container image. 

3)  **Build SBOM**  (ConcertDef format)

This is the inventory generated as part of building the software for a release (e.g., Docker images, executables, libraries or other packages in general). This SBOM reflects the actual components assembled into the final product during the build phase.

4)	**Deployment SBOM**  (ConcertDef format)

This SBOM identifies how an Application & its components are to be deployed on a target environment, including Configuration information.  For example, this could be as elaborate as identifying namespaces in a Kubernetes cluster or as simple as a single Machine (VM) in an environment.  This SBOM manifest would typically also identify dependencies, such as databases or other Services that the application connects to or leverages, as well as Access Points that the App exposes. 

-	SBOMs are, rich in terms of describing the end-to-end aspect of an Application and its relationships.  
-	Given that, in most Enterprises, the information needed to build SBOMs are present in existing automation pipelines, the best source to getting the APP360 data would be these existing CI/CD pipelines and other DevOps SRE automation.

5) **Vulnerability Disclosure Report (VDR)** (CycloneDX format) 

The VDR itemizes the lists of vulnerabilities found in scanning the source code and/or container images etc.  See the [CycloneDX site](https://cyclonedx.org/capabilities/vdr/) for more details about VDRs.

---

## Generating ConcertDef and CycloneDX files

While there are multiple techniques for generating such content, in this example, we will use a set of common open source utilities as well as the Concert toolkit to illustrate different ways to generate appropriate data prior to loading into Concert.

a) Concert toolkit utilities are used to generate the Application and Build SBOMs in ConcertDef formats.

b) A minimal version of the [cdxgen](https://github.com/CycloneDX/cdxgen) utility included inside the Concert toolkit is used to generate an inventory of packages in the `pyk8s` example python application's source.
- _Note_: you may want to use the full blown [cdxgen utility](https://cyclonedx.github.io/cdxgen/#/CLI?id=installing), such as the docker image `ghcr.io/cyclonedx/cdxgen:v8.6.0` from opensource as that covers many more package managers and other options.  

c) [syft](https://github.com/anchore/syft) is used to inspect the Docker image produced after [building](../build.sh) the example and generate an inventory of packages found in that image in CycloneDX format.

d) [trivy](https://github.com/aquasecurity/trivy) is used to scan the source code to produce the list of vulnerabilities in VDR format.

e) [grype](https://github.com/anchore/grype) is used to scan the Docker image and produce the list of vulnerabilities in VDR format.

### Generate the App SBOM

To generate Application ConcertDef SBOMs easily, the [Concert toolkit](https://www.ibm.com/docs/en/concert?topic=started-using-concert-toolkit#using_the_concert_toolkit__title__3) includes a utility called ["app-sbom"](https://www.ibm.com/docs/en/concert?topic=toolkit-list-utilities#toolkit_utilities_list__title__7) that uses a simple .yaml file as input. 

For this 'pyk8s' example, the [app-config yaml file](./tester-app-cfg.yaml) includes metadata about the App being onboarded. It also identifies the `environment_targets` to describe where the App has been or is being deployed. The example shows a set of API endpoints that are exposed by this app. 

To generate the App SBOM using the toolkit, run:
 
`./toolkit.sh "app-sbom --app-config /toolkit-data/tester-app-cfg.yaml"`

The output file [./generated/tester-app.json](./generated/tester-app.json) is the ConcertDef SBOM. 


### Generate the Build SBOM

Similarly, for the build SBOM, the [build-sbom utility](https://www.ibm.com/docs/en/concert?topic=toolkit-list-utilities#toolkit_utilities_list__title__5) can be used.

[tester-build-cfg.yaml](./tester-build-cfg.yaml) is an example yaml file for the 'pyk8s' application.  It identifies the build number to identify the build as well as git repository branches and commit sha.

`./toolkit.sh build-sbom --build-config /pyk8s/concert-1.0.2/tester-build-cfg.yaml`

The output file [./generated/pyk8s-build.json](./generated/pyk8s-build.json) is the generated ConcertDef SBOM. 

### Generate the inventory of Packages from source code 

The toolkit [code-scan](https://www.ibm.com/docs/en/concert?topic=toolkit-list-utilities#toolkit_utilities_list__title__2) utility invokes cdxgen to generate the inventory of packages from the source code in CycloneDX format.
  
`./toolkit.sh code-scan --src /pyk8s --output-file pyk8s-src-packages.json`

The CycloneDX file [pyk8s-src-packages.json](./generated/pyk8s-src-packages.json) is the result of the cdxgen run.

### Generate the inventory of Packages from the docker image

Use the syft utility to generate a CycloneDX SBOM inventory of packages found in the Docker image.

`syft myregistry:5000/sector7g/pyk8s:v2 -o cyclonedx-json > generated/pyk8s-img-packages.json`

The [./generated/pyk8s-img-packages.json](./generated/pyk8s-img-packages.json) is generated.

### Generate a VDR from the source code

Use the trivy utility to scan and generate a list of vulnerabilities found in the source code.

`(cd ../../; trivy fs --output=./pyk8s/concert-1.0.2/generated/pyk8s-vuln-src.json --format=cyclonedx --scanners vuln ./pyk8s/)`

The [./generated/pyk8s-vuln-src.json](./generated/pyk8s-vuln-src.json) file is the VDR in CycloneDX format.

### Generate a VDR from the docker image

We will use grype to scan the docker image and generate the list of vulnerabilities.

`grype myregistry:5000/sector7g/pyk8s:v2 -o cyclonedx-json > generated/pyk8s-vuln-images.json` 

The [./generated/](./generated/pyk8s-vuln-images.json) is the VDR in CycloneDX format.


---


## Ingestion 

In this section, we will push the generated data files to Concert using one of Concert's [ingestion endpoint](https://www.ibm.com/docs/en/concert?topic=concert-importing-data-using-api#ingesting_data_via_api__title__3) using the helper functions in 
[push.sh](./push.sh).

Remember to change the script and set the coordinates including the API Key to connect to your Concert instance.

See [Generating an API key](https://www.ibm.com/docs/en/concert?topic=api-generating-key) for instructions on generating your API Key.

for example:

```
export CONCERT_URL="https://myconcert.example.com:<port>"
export CONCERT_API_KEY="C_API_KEY <key>"
```

You may also need to change the `InstanceId: ` header in the script to point to your specific instance as needed.

We will now look at how to upload each generated file into your Concert instance. The videos provide an idea of how these entities will be represented inside Concer.

**Note**: After a load, you may need to **reload** the browser page to get the latest data to show up.

### upload the App ConcertDef SBOM

`./push.sh push_app_sbom`

Concert should now show this one application and one environment.


https://github.com/user-attachments/assets/d6a95705-3b37-4f76-b62a-5652f8464afc



### upload the Build SBOM

`./push.sh push_build_sbom`

You should see the image and source code referenced in the Build SBOM now



https://github.com/user-attachments/assets/4f8e1daf-06e8-496d-9418-84a5161a627e




### upload the CycloneDX inventory of packages from source code

`./push.sh push_pkg_sbom_for_src`

- **NOTE** the use of the `repo_url` metadata parameter in the [curl command](./push.sh#L28) to indicate that the generated CycloneDX content is for the same source code repository specified in the [Build SBOM](./generated/pyk8s-build.json#L26). If you specify a repository url in App SBOM)too, it should be the same identifier used everywhere.  This is because the [generated CycloneDX content](./generated/pyk8s-src-packages.json#L38) usually does not include a unique identifier about the source repository that was scanned. In many cases, just a subdirectory name may be used as a reference, which could also be the same name used in other repositories. The `version` tag may not match what you might expect either. 



https://github.com/user-attachments/assets/140b4c4a-2bad-4d8d-bdba-8c9d75a39402



### upload the CycloneDX inventory of packages found in the image

`./push.sh push_pkg_sbom_for_img`

It is not necessary to provide the `repo_url` metadata parameter in this case because the generated CycloneDX content is able to uniquely identify the image that the scan was run against, with a 'type' set to 'container' as well.

You should see packages now visible and associated with the Application.



https://github.com/user-attachments/assets/293bc315-e38c-483b-ab9a-ef550d291ebd



### upload the VDR from source code scan

`./push.sh push_vdr_for_src`

**NOTE** the use of the `repo_url` metadata parameter in the [curl command](./push.sh#L59)

Once the upload completes, you should be able to see the vulnerabilities listed in the Dimension page as well as associated with the Application. 



https://github.com/user-attachments/assets/95a94cf4-6817-466e-858f-4d7e860ee5e4



### upload the VDR from image scan

`./push.sh push_vdr_for_img`

The uploaded list of vulnerabilities should show up in the Dimensions view and associated with the Application as well.


https://github.com/user-attachments/assets/713ad741-2931-4fc5-950a-6506aca21fba



