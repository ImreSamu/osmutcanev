
#Magyar nyelvű tutorial

###Step0

győződj meg, hogy a gépeden telepítve van-e:
* `docker -v`          ( 1.11.1 -re tesztelve)
* `docker-compose -v`  ( 1.7.1 -re tesztelve )


###Step1
```
git clone https://github.com/ImreSamu/osmutcanev.git
cd osmutcanev

# kontérek építése  ( kb ~ 15 - 30 perc ) , de csak 1x kell!
make build

# futtatás
make start

# helyi webserver elinditása, ami a localhost:2015  porton érhető el
make startweb
```


Ellenörizd, hogy megjelenik-e:
* http://localhost:2015/  ( grafika az aznapi dátummal )
* http://localhost:2015/reports/telepulesek/Debrecen.html


###Step2
```
#  tölsd le a legfrisebb OSM adatokat
./download_osmlatest.sh

# Ellenörizd le,hogy jó volt-e a letöltés 
ls ./input/osmdata/* -la

#másold be a saját utcanévadataiadat  
# -> ./input/csv/budapest_utcanev_kerulet.csv
#          ( utcanév  + ";" + Budapesti Kerületnevek - a Wikipédia cimke alapján )
# -> ./input/csv/videk_utcanev_telepules.csv
#          ( utcanév  + ";" + Magyar Településnevek - Budapest kivételével ) 
#
#
# Ha szükséges - módosítsd a feliratokat ( jelenleg csak a MAPLABEL12 működik! )
# --> docker-compose.yml
#
# Ezek nincsenek implementálva még ..
#     - BASENAME=Posta                      
#     - BASENAMELONG=Posta_adatbázis        
#  
# Ezeknek működnie kell:
#     - MAPLABEL1="OpenStreetMap Hungary vs. Hungarian Post  -  Street Name Completeness Statistics "  
#     - MAPLABEL2="---  Experimental!  ---"                                            
#

# futtatás
make start

```

Ellenörizd, hogy megjelenik-e:
* http://localhost:2015/  ( grafika az aznapi dátummal -és a MAPLABEL1/2 felirattal! )




#FAQ / GYÍK 

### OSM mappingkonfiguráció

Ez OSM címkézés elég jellegzetes, emiatt néha testre kell szabni.
Ennek a teendője:
* config file helye: src/osmutcanev/src/osmutcanev.yml
* Leirás: http://imposm.org/docs/imposm3/latest/mapping.html#mapping
* Figyeljünk a YML szintaktikára, a space-ek számítanak!
* módosítás után egy `make buld` et adjunk ki.
* és utána jöhet a `make start`

### Bármi technikai hiba.

Ha a Travis státusz : "build-passing", 
* https://travis-ci.org/ImreSamu/osmutcanev
Akkor az utolsó teszt időpontjában még müködött ...



 



