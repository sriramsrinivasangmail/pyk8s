#!/bin/bash
oc create route edge pyhttp --service=py-http-svc

oc annotate route pyhttp router.openshift.io/cookie_name="pyhttp-route-cookie"

oc get route pyhttp
