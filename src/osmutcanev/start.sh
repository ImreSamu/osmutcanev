#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

mkdir -p ./input/osmdata
mkdir -p ./input/osmadmin
mkdir -p ./input/csv

mkdir -p ./output/log
mkdir -p ./output/web/pics
mkdir -p ./output/web/reports/telepulesek


function dataprocess {
 echo ' --- OSM IMPORT start --- ' 
 time ./src/import_osm_data.sh
 echo ' --- SQL PREPROCESS OSM DATA start --- ' 
 time psql  -f "./src/preprocess.sql"
 echo ' --- BASE DATA IMPORT start --- ' 
 time ./src/import_bazisutcanev.sh
 echo ' --- OSM and BASE COMPARE start --- ' 
 time psql  -f "./src/compare.sql"
}

dataprocess


echo ' ---Export XLS start --- ' 
rm -f ./output/web/reports/osm_utcanev_export.xlsx
function expxls {
time   /tools/latest/pgclimb --host $PGHOST \
                         --dbname   $PGDATABASE \
                         --username $PGUSER \
                         --password $PGPASSWORD \
                         -o ./output/web/reports/osm_utcanev_export.xlsx \
                         -c "SELECT * FROM ${expname}" \
                         xlsx \
                         --sheet "${expname}"     
}
expname=par_telep_utca_percent   expxls



echo ' --- utcanev_report.R start --- ' 
time Rscript ./src/utcanev_riport.R
echo ' --- utcanev_map.R start --- ' 
time Rscript ./src/utcanev_map.R

