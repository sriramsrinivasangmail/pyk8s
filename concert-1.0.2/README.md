
./toolkit.sh "app-sbom --app-config /pyk8s/concert-1.0.2/tester-app-cfg.yaml"

./toolkit.sh build-sbom --build-config /pyk8s/concert-1.0.2/tester-build-cfg.yaml

./toolkit.sh code-scan --src /pyk8s --output-file pyk8s-src-packages.json

cat generated/pyk8s-src-packages.json | jq  '.metadata.component.name = "pyk8s" | .metadata.component.version = "2.0.1"' > generated/pyk8s-src-packages-2.0.1.json

syft myregistry:5000/sector7g/pyk8s:v2 -o cyclonedx-json > generated/pyk8s-img-packages.json

---

trivy fs --output=./pyk8s/concert-1.0.2/generated/pyk8s-vuln-src.json --format=cyclonedx --scanners vuln ./pyk8s/

---

`####trivy image --format cyclonedx --output=./generated/pyk8s-vuln-images.json myregistry:5000/sector7g/pyk8s:v2`

grype myregistry:5000/sector7g/pyk8s:v2 -o cyclonedx-json > generated/pyk8s-vuln-images.json


---

export CONCERT_API_KEY="C_API_KEY <key>"

./push.sh push_app_sbom

./push.sh push_build_sbom

./push.sh push_pkg_sbom_for_src

./push.sh push_pkg_sbom_for_img

./push.sh push_vdr_for_src

./push.sh push_vdr_for_img
