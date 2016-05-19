#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

mkdir -p ./log
mkdir -p ./sandbox
mkdir -p ./inputosmdata
mkdir -p ./inputosmadmin


cd ./inputosmadmin
rm -f *.osm.pbf
wget http://download.geofabrik.de/europe/hungary-160101.osm.pbf


cd ../inputosmdata
rm -f hungary-latest.osm.pbf
wget http://download.geofabrik.de/europe/hungary-latest.osm.pbf











