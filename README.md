# osmutcanev
OSM HUN Streetname compare

Work in progress ....
 
###Req:
* linux, git, make, wget
* docker, docker-compose  https://docs.docker.com/

###Install:

```bash
git clone https://github.com/ImreSamu/osmutcanev.git
cd osmutcanev
make build
```

##Run:
```bash    
make start
```

###Start webserver - to see outputs
```bash    
make startweb
```
and start a web browser  -->  http://localhost:2015/


### Download Latest OSM data ( hungary-latest.osm.pbf )
```bash
./download_osmlatest.sh
```

### Download OSM Admin data ( hungary-20160101.osm.pbf )

```bash
./download_osmadmin.sh
```



##Directories:

### input data
* ./input/osmdata
 * hungary-latest.osm.pbf 
  * Latest OSM data. download with `./download_osmlatest.sh`
* ./input/osmadmin
 * old and tested OSMfile for the admin polygons!  
 * download only once ..  see `./download_osmadmin.sh`
* ./input/src
 * budapest_utcanev_kerulet.csv  ( utcanev ';' kerületnév (wikipedia név szerinti ) formában ) 
 * videk_utcanev_telepules.csv   ( utcanév ';' településnév formában )
 
### output data
* ./output/web
* ./output/web/pics
 * osmhu_streetname_latest.png  ( Lefedettségi térkép )
* ./output/web/reports/      Összesített riportok  
 * osm_utcanev_export.xlsx
 * 00_TELEPÜLÉS_LFEDETTSÉG.html
 * 00_HASONLÓ.html
 * ...
* ./output/web/reports/telepulesek   településenkénti lista
 * ...
 * Budapest I. kerülete.html
 * Budapest II. kerülete.html
 * ...
 * Debrecen.html



