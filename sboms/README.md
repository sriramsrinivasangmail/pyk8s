

# IBM Concert SBOM ingestion with example

---

- [IBM Concert SBOM ingestion with example](#ibm-concert-sbom-ingestion-with-example)
  - [Introduction](#introduction)
    - [The Application entity](#the-application-entity)
    - [The Environment entity](#the-environment-entity)
    - [Software Bill of Materials (SBOM) for the App360 view](#software-bill-of-materials-sbom-for-the-app360-view)
    - [Types of SBOMs](#types-of-sboms)
  - [Generating ConcertDef format SBOMs](#generating-concertdef-format-sboms)
  - [Ingesting CycloneDX format Package SBOMs](#ingesting-cyclonedx-format-package-sboms)


---

## Introduction

This document describes the semantics behind the ConcertDef and CycloneDX formats with regards to correlating package dependencies with applications in IBM Concert.

This git repository includes SBOM related files for the 'pyk8s' example app here: https://github.com/sriramsrinivasangmail/pyk8s/tree/main/sboms and those files are referenced in appropriate sections below.

### The Application entity

An Application is defined to include references to:
•	Source code repositories
•	Packages used in that Application
•	Images (such as Docker images) and other binaries that get deployed for that Application
•	Environments where the Application gets deployed
•	Access Points (such as API services etc.) 

### The Environment entity

An Environment is defined to include references to:

•	Applications it hosts
•	Access points that it exposes – either private (within a specific network domain) or public (accessible outside the domain)
•	Resources  - these could be Nodes (machines),  Deployments/Pods etc. (inside Kubernetes) that are present inside that environment

### Software Bill of Materials (SBOM) for the App360 view

- 	Software Bill of Materials , as a standardized exchange format, play a critical role in describing Applications in the enterprise across the lifecycle.  SBOMs also have gained regulatory prominence as part of an overall Security of the Software Supply Chain. 

-  Many enterprises have already started maintaining SBOMs and the expectation is that their existing CI/CD pipelines become the way to share such information with IBM Concert on a continuous basis.
 quick intros: https://www.ntia.gov/sites/default/files/publications/sbom_at_a_glance_apr2021_0.pdf    https://www.ntia.gov/sites/default/files/publications/sbom_faq_-_20201116_0.pdf 

(version 1.6:  https://cyclonedx.org/docs/1.6/json/
https://cyclonedx.org/guides/OWASP_CycloneDX-Authoritative-Guide-to-SBOM-en.pdf ) 

- IBM Concert uses the CycloneDX standard to ingest SBOMs as well as extends it for the 'ConcertDef' format for additional information and relationships.

### Types of SBOMs

1) **Application SBOM**:  (ConcertDef format)

The application SBOM  defines the application in Concert.  It includes the application's source code locations, the container images,libraries and binaries that are built from its source, what its service dependencies are etc.  For each application you need to onboard, you will need to create an application SBOM

2)	**Package SBOM**  (CycloneDX format) 

This is the inventory of packages present in a source code location or inside a container image. 

3)  **Build SBOM**  (ConcertDef format)

This is the inventory generated as part of building the software for a release (e.g., Docker images, executables, libraries or other packages in general). This SBOM reflects the actual components assembled into the final product during the build phase.

4)	**Deployment SBOM**  (ConcerDef format)

This SBOM identifies how an Application & its components are to be deployed on a target environment, including Configuration information.  For example, this could be as elaborate as identifying namespaces in a Kubernetes cluster or as simple as a single Machine (VM) in an environment.  This SBOM manifest would typically also identify dependencies, such as databases or other Services that the application connects to or leverages, as well as Access Points that the App exposes. 

•	SBOMs are, rich in terms of describing the end-to-end aspect of an Application and its relationships.  
.	Given that, in most Enterprises, the information needed to build SBOMs are present in existing automation pipelines, the best source to getting the APP360 data would be these existing CI/CD pipelines and other DevOps SRE automation.


## Generating ConcertDef format SBOMs

ConcertDef SBOMs derived from CycloneDX standard, but includes a few extensions.  To understand more about the ConcertDef format, see [the documentation around ConcertDef](https://www.ibm.com/docs/en/concert?topic=topology-generating-concert-defined-sbom)

1) To generate Application ConcertDef SBOMs easily, the [Concert toolkit](https://www.ibm.com/docs/en/concert?topic=started-using-concert-toolkit#using_the_concert_toolkit__title__3) includes a utility called ["app-sbom"](https://www.ibm.com/docs/en/concert?topic=toolkit-list-utilities#toolkit_utilities_list__title__7) that uses a simple .yaml file as input. 

For this 'pyk8s' example, the [app-config yaml file](./tester-app-cfg.yaml) includes metadata about the App being onboarded, describes the source code repository locations and a docker image. It also identifies the `environment_targets` to describe where the App has been or is being deployed. The example shows a set of API endpoints that are exposed by this app. 

To generate the App SBOM using the toolkit, run:
 
`${TOOLKIT_PREFIX_CMD} "app-sbom --app-config /toolkit-data/tester-app-cfg.yaml"`

The output file [./tester-app.json](./tester-app.json) is the SBOM. 

> However, you can **directly generate** this SBOM. It is not mandatory to use this yaml file and the toolkit. 

 - To Upload the ConcertDef App SBOM via the UI (the API is also an option)

  -	Login to the Concert UI
  -	Navigate to the Arena view
  -	click on “Define and upload”->”Define application”->”From SBOM”. 
  -	The File Type should be “ConcertDef SBOM”. Choose the [./tester-app.json](./tester-app.json) file to upload.


2) Similarly, for the build SBOM, the [build-sbom utility](https://www.ibm.com/docs/en/concert?topic=toolkit-list-utilities#toolkit_utilities_list__title__5) can be used.

[tester-build-cfg.yaml](./tester-build-cfg.yaml) is an example yaml file for the 'pyk8s' application.  It identifies the build number to identify the build as well as git repository branches and commit sha.

`${TOOLKIT_PREFIX_CMD} "build-sbom --build-config /toolkit-data/tester-build-cfg.yaml"` 

The output file [pyk8s-build.json](./pyk8s-build.json) is the generated ConcertDef SBOM. 

**Note**: there is a defect in Concert v1.0.1 that does not correctly link the repository source with the application. (Expected to fix in 1.0.2)

To workaround this - the build-config yaml needs to use the _component name_ for the `url`

```
    repository:
      name: "pyk8s"
      url: "pyk8s"
```

instead of `url: "git@github.com:sriramsrinivasangmail/pyk8s.git"`.

In the build SBOM, you will see this section:

```
            "bom-ref": "repository:coderepo:github:pyk8s",
            "type": "code",
            "name": "pyk8s",
            "purl": "pyk8s",
```

While in the application SBOM, you will see this section:

```
                {
                    "bom-ref": "repository:coderepo:github:pyk8s",
                    "type": "code",
                    "name": "pyk8s",
                    "purl": "git@github.com:sriramsrinivasangmail/pyk8s.git"
                }
```

---

- The Package SBOM can be uploaded via “Define and upload”->”Define application”->”From SBOM” from the Arena view as well.

## Ingesting CycloneDX format Package SBOMs

You can use any utility that generates CycloneDX content. The Concert toolkit includes a utility called [code-scan](https://www.ibm.com/docs/en/concert?topic=toolkit-list-utilities#toolkit_utilities_list__title__2) which is a reduced packaging of the open source cdxgen utility. 

_Note_: you may want to use the full blown [cdxgen utility](https://cyclonedx.github.io/cdxgen/#/CLI?id=installing), such as the docker image `ghcr.io/cyclonedx/cdxgen:v8.6.0` from opensource as that covers many more package dependencies and other variations  

For example, with the `code-scan` utility:

1) git clone the repository (this one)

2) cd to the pyk8s directory

3) generate the package SBOM

`${TOOLKIT_PREFIX_CMD} "code-scan --src /data/src/pyk8s --output-file pyk8s.json"  resulted in https://github.com/sriramsrinivasangmail/pyk8s/blob/main/sboms/pyk8s.json`

- Upload the package SBOM via the UI
  -	Login to the Concert UI
  -	navigate to Dimensions->Software Composition
  -	Go to the SBOMs tab
  -	click on Upload SBOM.
  - The File Type should be “CycloneDX SBOM”. Choose the json file generated in the step above and click upload.


