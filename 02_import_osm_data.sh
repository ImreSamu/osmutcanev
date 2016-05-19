#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

mkdir -p ./log
mkdir -p ./sandbox
mkdir -p ./inputosmdata
mkdir -p ./inputosmadmin


if  ! pg_isready  
then
  echo "Start -> PostgreSQL" 
  nohup /docker-entrypoint.sh postgres  &
else
  echo "PostgreSQL is running"  
fi


while ! pg_isready 
do
    echo "$(date) - waiting for PG database to start"
    sleep 2
done

#ENV POSTGRES_USER osm
#ENV POSTGRES_PASSWORD osm
#ENV POSTGRES_DB osm

readonly PG_CONNECT="postgis://${POSTGRES_USER}:${POSTGRES_PASSWORD}@localhost/${POSTGRES_DB}"

function import_admin {
 echo "============ Start import_admin ================"
 for input_osm_pbf in "./inputosmadmin/*.pbf"; do
  /tools/latest/imposm3 import \
   -mapping osmadmin.yml  \
   -read $input_osm_pbf \
   -write    \
   -optimize  \
   -overwritecache \
   -deployproduction \
   -connection $PG_CONNECT
  break
 done
}
import_admin


function import_osmdata {
 echo "============ Start import_data ================"
 for input_osm_pbf in "./inputosmdata/*.pbf"; do
  /tools/latest/imposm3 import \
   -mapping osmutcanev.yml  \
   -read $input_osm_pbf \
   -write    \
   -optimize  \
   -overwritecache \
   -deployproduction \
   -connection $PG_CONNECT
  break
 done
}
import_osmdata
psql -d ${POSTGRES_DB} -U ${POSTGRES_USER}  -f preprocess.sql

exit


psql -d ${POSTGRES_DB} -U ${POSTGRES_USER}  -f compare.sql


