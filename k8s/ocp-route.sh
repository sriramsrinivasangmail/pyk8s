#!/bin/bash

echo "passthrough route.."

oc delete route pyhttp 
oc create route passthrough pyhttp --service=py-http-svc

oc annotate route pyhttp router.openshift.io/cookie_name="pyhttp-route-cookie"

echo "re-encrypt route.."

oc delete route pyhttp -re
oc create route reencrypt pyhttp-re --service=py-http-svc --cert=src/tls/certificate.crt --key=src/tls/certificate.key --dest-ca-cert=src/tls/certificate.crt --ca-cert=src/tls/certificate.crt

oc get route pyhttp
