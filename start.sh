#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

cd /src

#./01_download_osm.sh

./02_import_osm_data.sh
psql -d ${POSTGRES_DB} -U ${POSTGRES_USER}  -f preprocess.sql
./03_import_bazisutcanev.sh
psql -d ${POSTGRES_DB} -U ${POSTGRES_USER}  -f compare.sql


echo ' ---Export XLS start --- ' 
rm -f ./sandbox/osm_utcanev_export.xlsx
function expxls {
   /tools/latest/pgclimb  -d ${POSTGRES_DB} -U ${POSTGRES_USER}  -o ./sandbox/osm_utcanev_export.xlsx -c "SELECT * FROM ${expname}" xlsx --sheet "${expname}"
}
expname=par_telep_utca_percent        expxls



echo ' --- R part start --- ' 
time R CMD BATCH ./utcanev_riport.R
cp utcanev_riport.Rout    ./log/osm$(date +%Y-%m-%d_%H:%M).Rlog


