#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

mkdir -p ./log
mkdir -p ./sandbox
mkdir -p ./inputosmdata
mkdir -p ./inputosmadmin

if  [ ! pg_isready ] 
then
  echo "Start -> PostgreSQL" 
  nohup ./docker-entrypoint.sh postgres  &
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

psql -d ${POSTGRES_DB} -U ${POSTGRES_USER}  <<OELSQL
drop table if exists bazis_budapest ;
create table  bazis_budapest 
(
   utcanev text
  ,telepules text
);

drop table if exists bazis_videk ;
create table  bazis_videk 
(
   utcanev text
  ,telepules text
);
OELSQL
psql -d ${POSTGRES_DB} -U ${POSTGRES_USER}  -c "\copy bazis_budapest  FROM './inputcsv/budapest_utcanev_kerulet.csv' DELIMITER ';' CSV;"
psql -d ${POSTGRES_DB} -U ${POSTGRES_USER}  -c "\copy bazis_videk     FROM './inputcsv/videk_utcanev_telepules.csv'  DELIMITER ';' CSV;"

psql -d ${POSTGRES_DB} -U ${POSTGRES_USER}  -f compare.sql


rm -f ./sandbox/osm_utcanev_export.xlsx
function expxls {
   /tools/latest/pgclimb  -d ${POSTGRES_DB} -U ${POSTGRES_USER}  -o ./sandbox/osm_utcanev_export.xlsx -c "SELECT * FROM ${expname}" xlsx --sheet "${expname}"
}
expname=par_telep_utca_percent        expxls

exit
