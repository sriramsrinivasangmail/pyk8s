#!/bin/bash -e

concert_url="https://concert-dev-01.fyre.ibm.com:12443"
auth_hdr="Authorization: C_API_KEY aWJtY29uY2VydDo0NjM4MmNhNi04MzM1LTRiZjctOGJkMC02NWVjNzgzZmFhOGM="
inst_hdr='InstanceId: 0000-0000-0000-0000'


CURL=${CURL:-"curl -k"}


## App ConcertDef SBOM

push_app_sbom()
{
    echo === $0 ====

    $DRY_RUN ${CURL} --request POST --url "${concert_url}/ingestion/api/v1/upload_files"  -H "${auth_hdr}" -H "${inst_hdr}" --header "Content-Type: multipart/form-data" \
   --form data_type=application_sbom --form filename=@./sboms/tester-app.json

   echo
}


push_app_sbom
