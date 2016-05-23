#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset


cd ./input/osmdata

cd ../osmdata
rm -f hungary-latest.osm.pbf
wget http://download.geofabrik.de/europe/hungary-latest.osm.pbf











