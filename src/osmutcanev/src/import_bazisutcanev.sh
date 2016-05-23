#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

psql  <<OELSQL
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

psql  -c "\copy bazis_budapest  FROM './input/csv/budapest_utcanev_kerulet.csv' DELIMITER ';' CSV;"
psql  -c "\copy bazis_videk     FROM './input/csv/videk_utcanev_telepules.csv'  DELIMITER ';' CSV;"



