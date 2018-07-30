#!/bin/bash -eu

tile_metadata=$(unzip -l pivnet-product/*.pivotal | grep "metadata" | grep "ml$" | awk '{print $NF}')
STEMCELL_VERSION_FROM_TILE=$(unzip -p pivnet-product/*.pivotal $tile_metadata | grep -A5 stemcell_criteria:  \
                                  | grep version: | grep -Ei "[0-9]+{2}" | awk '{print $NF}' | sed "s/'//g" )

echo "Stemcell required: $STEMCELL_VERSION_FROM_TILE"

SC_FILE_PATH=$(find . -name bosh*.tgz | sort | head -1 || true)
if [ "$SC_FILE_PATH" != "" ]; then
  echo "Uploading cached stemcell: $SC_FILE_PATH to Ops Mgr"
  om-linux -t https://$OPSMAN_DOMAIN_OR_IP_ADDRESS \
           -u $OPSMAN_USERNAME \
           -p $OPSMAN_PASSWORD \
           -k --request-timeout 3600 \
           upload-stemcell -s $SC_FILE_PATH
else
  source nsx-t-ci-pipeline/functions/upload_stemcell.sh
  echo "No cached stemcell; Will download and then upload stemcell: $SC_FILE_PATH to Ops Mgr"
  upload_stemcells "$STEMCELL_VERSION_FROM_TILE $STEMCELL_VERSION_FROM_PRODUCT_METADATA"
fi