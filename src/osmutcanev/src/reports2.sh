#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

repdir=/osm/output/web/reports/telepulesek2
ajaxdir=/osm/output/web/ajax
telep_html=/osm/output/web/reports/telepulesek2.html

template_dir=/osm/output/web/template
template_html=/osm/output/web/template/temp_debrecen_ajax.html

mkdir -p ${repdir}
mkdir -p ${ajaxdir}

rm -f -r ${ajaxdir}/*.ajax
rm -f -r ${repdir}/*.html 
rm -f  ${telep_html} 



IFS=$'\n'

DB_PASS=osm /tools/latest/pgclimb --host $PGHOST -U osm -d osm  -c "SELECT distinct telepules FROM par_telep_utca_all  ORDER BY telepules" csv  > /tmp/telepules.txt

while read telepules; do
  echo $telepules

  ajaxfilename=${ajaxdir}/${telepules}.ajax
  echo '{"data": '  > $ajaxfilename
  DB_PASS=osm /tools/latest/pgclimb --host $PGHOST -U osm -d osm -c "SELECT * FROM par_telep_utca_all  WHERE telepules='${telepules}' " json >> $ajaxfilename
  echo '}'  >> $ajaxfilename

  telepuleshtml=${repdir}/${telepules}.html
  cat ${template_html} |  sed -e "s#temp_debrecen.ajax#/ajax/${telepules}.ajax#g" >  ${telepuleshtml}

done </tmp/telepules.txt


DB_PASS=osm /tools/latest/pgclimb --host $PGHOST -U osm -d osm  -o ${telep_html}  -c "SELECT * FROM par_telep_utca_percent ORDER BY telepules" template ${template_dir}/telepuleslista.tpl


