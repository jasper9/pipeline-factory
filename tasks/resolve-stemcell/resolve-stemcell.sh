#!/bin/bash -eu

# all bash code here borrow from Sabha's task at:
#		https://github.com/sparameswaran/nsx-t-ci-pipeline/blob/master/tasks/upload-product-and-stemcell/task.sh
#		and
#		https://github.com/sparameswaran/nsx-t-ci-pipeline/blob/master/functions/upload_stemcell.sh


tile_metadata=$(unzip -l */*.pivotal | grep "metadata" | grep "ml$" | awk '{print $NF}')
STEMCELL_VERSION_FROM_TILE=$(unzip -p */*.pivotal $tile_metadata | grep -A5 stemcell_criteria:  \
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
  #source nsx-t-ci-pipeline/functions/upload_stemcell.sh
  echo "No cached stemcell; Will download and then upload stemcell: $SC_FILE_PATH to Ops Mgr"
  
  #upload_stemcells "$STEMCELL_VERSION_FROM_TILE"

#  local stemcell_versions="$1"
local stemcell_versions = $STEMCELL_VERSION_FROM_TILE

  for stemcell_version_reqd in $stemcell_versions
  do

    if [ -n "$stemcell_version_reqd" ]; then
      diagnostic_report=$(
        om-linux \
          --target https://$OPSMAN_DOMAIN_OR_IP_ADDRESS \
          --username $OPSMAN_USERNAME \
          --password $OPSMAN_PASSWORD \
          --skip-ssl-validation \
          curl --silent --path "/api/v0/diagnostic_report"
      )

      stemcell=$(
        echo $diagnostic_report |
        jq \
          --arg version "$stemcell_version_reqd" \
          --arg glob "$IAAS" \
        '.stemcells[] | select(contains($version) and contains($glob))'
      )

      if [[ -z "$stemcell" ]]; then
        echo "Downloading stemcell $stemcell_version_reqd"

        product_slug=$(
          jq --raw-output \
            '
            if any(.Dependencies[]; select(.Release.Product.Name | contains("Stemcells for PCF (Windows)"))) then
              "stemcells-windows-server"
            else
              "stemcells"
            end
            ' < pivnet-product/metadata.json
        )

        pivnet-cli login --api-token="$PIVNET_API_TOKEN"
    set +e
        pivnet-cli download-product-files -p "$product_slug" -r $stemcell_version_reqd -g "*${IAAS}*" --accept-eula
        if [ $? != 0 ]; then
          min_version=$(echo $stemcell_version_reqd | awk -F '.' '{print $2}')
          if [ "$min_version" == "" ]; then
            for min_version in $(seq 0  100)
            do
               pivnet-cli download-product-files -p "$product_slug" -r $stemcell_version_reqd.$min_version -g "*${IAAS}*" --accept-eula && break
            done
          else
            echo "Stemcell version $stemcell_version_reqd not found !!, giving up"
            exit 1
          fi
        fi
    set -e

        SC_FILE_PATH=`find ./ -name *.tgz`

        if [ ! -f "$SC_FILE_PATH" ]; then
          echo "Stemcell file not found!"
          exit 1
        fi

        om-linux -t https://$OPSMAN_DOMAIN_OR_IP_ADDRESS -u $OPSMAN_USERNAME -p $OPSMAN_PASSWORD -k upload-stemcell -s $SC_FILE_PATH
      fi
    fi

  done

fi