#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

readonly OSM_ADMIN_BASE=hungary-160101

cd ./input/osmadmin
rm -f *.osm.pbf
wget http://download.geofabrik.de/europe/${OSM_ADMIN_BASE}.osm.pbf

