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

export LASTOSMTIMESTAMP=_missing_

RUNTIME=UTC$(date -u --rfc-3339="seconds")
export RUNTIME=$RUNTIME


function dataprocess {
 echo ' --- OSM IMPORT start --- ' 
 . ./src/import_osm_data.sh
 echo ' --- SQL PREPROCESS OSM DATA start --- ' 
 time psql  -f "./src/preprocess.sql"
 echo ' --- BASE DATA IMPORT start --- ' 
 time ./src/import_bazisutcanev.sh
 echo ' --- OSM and BASE COMPARE start --- '
 
 cat "./src/compare.sql" |  sed -e "s/NINCS_HASONLO_BAZ/NINCS_HASONLO_${BASENAME}/g" >   ./src/compare_temp.sql
  
 time psql  -f "./src/compare_temp.sql"
 
 
}

dataprocess

echo ' --- EXPORT reports2  --- ' 
time ./src/reports2.sh

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

