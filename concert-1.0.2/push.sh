#!/bin/bash -e

concert_url=${CONCERT_URL:-"https://concert-dev-01.fyre.ibm.com:12443"}
auth_hdr="Authorization: ${CONCERT_API_KEY}"
inst_hdr='InstanceId: 0000-0000-0000-0000'


CURL=${CURL:-"curl -k"}


## App ConcertDef SBOM

push_app_sbom()
{
    echo === $0 ====

    $DRY_RUN ${CURL} --request POST --url "${concert_url}/ingestion/api/v1/upload_files"  -H "${auth_hdr}" -H "${inst_hdr}" --header "Content-Type: multipart/form-data" \
   --form data_type=application_sbom --form filename=@./generated/tester-app.json

   echo
}

push_pkg_sbom_for_src()
{
    echo === $0 ====

    $DRY_RUN ${CURL} --request POST --url "${concert_url}/ingestion/api/v1/upload_files"  -H "${auth_hdr}" -H "${inst_hdr}" --header "Content-Type: multipart/form-data" \
   --form 'metadata={"repo_url" : "git@github.com:sriramsrinivasangmail/pyk8s.git" }' \
   --form data_type=package_sbom --form filename=@./generated/pyk8s-src-packages.json
   echo
}

push_pkg_sbom_for_img()
{
    echo === $0 ====

    $DRY_RUN ${CURL} --request POST --url "${concert_url}/ingestion/api/v1/upload_files"  -H "${auth_hdr}" -H "${inst_hdr}" --header "Content-Type: multipart/form-data" \
   --form data_type=package_sbom --form filename=@./generated/pyk8s-img-packages.json
   echo
}



push_build_sbom()
{
    echo === $0 ====

    $DRY_RUN ${CURL} --request POST --url "${concert_url}/ingestion/api/v1/upload_files"  -H "${auth_hdr}" -H "${inst_hdr}" --header "Content-Type: multipart/form-data" \
   --form data_type=application_sbom --form filename=@./generated/pyk8s-build.json 
   echo
}

push_vdr_for_src()
{
    echo === $0 ====

    $DRY_RUN ${CURL} --request POST --url "${concert_url}/ingestion/api/v1/upload_files"  -H "${auth_hdr}" -H "${inst_hdr}" --header "Content-Type: multipart/form-data" \
   --form data_type=code_scan --form filename=@./generated/pyk8s-vuln-src.json \
   --form 'metadata={"repo_url" : "git@github.com:sriramsrinivasangmail/pyk8s.git" }'
   echo
}

push_vdr_for_img()
{
    echo === $0 ====

    $DRY_RUN ${CURL} --request POST --url "${concert_url}/ingestion/api/v1/upload_files"  -H "${auth_hdr}" -H "${inst_hdr}" --header "Content-Type: multipart/form-data" \
   --form data_type=image_scan --form filename=@./generated/pyk8s-vuln-images.json
   echo
}

$*
