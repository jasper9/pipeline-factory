#!/bin/bash -eu

STEMCELL_VERSION_FROM_TILE=$(unzip -p p-healthwatch-s3/*.pivotal $tile_metadata | grep -A5 stemcell_criteria:  \
                                  | grep version: | grep -Ei "[0-9]+{2}" | awk '{print $NF}' | sed "s/'//g" )

echo $STEMCELL_VERSION_FROM_TILE