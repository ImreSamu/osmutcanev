#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

cd ./input/osmdata

cd ../osmdata
rm -f *.pbf
rm -f *.md5
wget http://download.geofabrik.de/europe/hungary-latest.osm.pbf
wget http://download.geofabrik.de/europe/hungary-latest.osm.pbf.md5

md5sum -c *.md5
