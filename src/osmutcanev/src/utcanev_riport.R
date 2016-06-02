
## install.packages('SortableHTMLTables')
## install.packages('RPostgreSQL')
## install.packages('gtools')

library(RPostgreSQL)
library(SortableHTMLTables)
library(gtools)

basename     <- Sys.getenv("BASENAME") 
print ( c("basename=",basename) )

exportdirtelepules     <- "./output/web/reports/telepulesek/"
exportdir              <- "./output/web/reports/"


## loads the PostgreSQL driver
drv <- dbDriver("PostgreSQL")

## Open a connection
con <- dbConnect(drv)

## Telepulesk reports
rtelepules <- dbGetQuery(con, "select 
                       distinct telepules 
                       from par_telep_utca_all
                       order by telepules 
                    ")


mtelepules <- function (nev ) {
  htmlfile <-sprintf('%s.html',nev)
  s<-sprintf("select 
                       telepules as Település
                     , utcanev   as Képzett_utcanév
                     , b_utcanev as Bázis_utcanév
                     , o_utcanev as OpenStreetMap_utcanév 
                     , checktype as Párosítás_típusa
                     , o_utcanev_alt_name as OpenStreetMap_alt_name 
                    from   par_telep_utca_all
                    WHERE  telepules = '%s'
                    order by telepules, utcanev 
                    ",  nev )
  s <- gsub("Bázis",basename,s)
                    
  rs <- dbGetQuery(con, s )  
  sortable.html.table(rs, htmlfile , exportdirtelepules,  nev )
} 

apply( rtelepules,1, mtelepules) 


##  HASONLÓ

s<- "               SELECT
                       telepules AS település
                     , utcanev   AS képzett_utcanév
                     , b_utcanev AS Bázis_utcanév
                     , o_utcanev AS OpenStreetMap_utcanév 
                     , checktype AS Párosítás_típusa
                     , o_utcanev_alt_name AS OpenStreetMap_alt_name
                    FROM par_telep_utca_all
                    WHERE  checktype LIKE 'HASON%'
                    ORDER BY telepules, utcanev 
                    "
s <- gsub("Bázis",basename,s)                    
rs <- dbGetQuery(con, s )  
sortable.html.table(rs, '00_HASONLÓ.html' , exportdir, '00_HASONLÓ de nem pontosan ugyanaz' )


##  HASONLÓ

s<- "select 
                       telepules as település
                     , utcanev   as képzett_utcanév
                     , b_utcanev as Bázis_utcanév
                     , o_utcanev as OpenStreetMap_utcanév 
                     , checktype as Párosítás_típusa
                     , o_utcanev_alt_name as OpenStreetMap_alt_name
                    from par_telep_utca_all
                    WHERE  checktype like 'HASON%'
                    order by telepules, utcanev 
                    "
  s <- gsub("Bázis",basename,s)                    
rs <- dbGetQuery(con, s )  
sortable.html.table(rs, '00_HASONLÓ2.html' , exportdir, '00_HASONLÓ de nem pontosan ugyanaz' )



## NINCS_HASONLO_OSM
s<- "select 
                       telepules as település
                     , utcanev   as képzett_utcanév
                     , b_utcanev as Bázis_utcanév
                     , o_utcanev as OpenStreetMap_utcanév 
                     , checktype as Párosítás_típusa
                    from   par_telep_utca_all
                    WHERE  checktype = 'NINCS_HASONLO_OSM'
                    order by telepules, utcanev 
                    "
s <- gsub("Bázis",basename,s)
                    
rs <- dbGetQuery(con, s )  
sortable.html.table(rs, '00_NINCS_HASONLO_OSM.html' , exportdir, '00_NINCS_HASONLO_OSM,  nincs OSM párja' )

##   par_telep_utca_percent
s<- "select 
                       telepules as település
                     , OSM_allapot_szazalek    as OSM_utcanév_lefedettség_százalék
                     , _db_egyezo              as egyező_utcanév_db
                     , _db_hasonlo             as hasonló_utcanév_db
                     , _db_nincs_hasonlo_osm   as OSM_ből_hiányzó_utcanév_db
                    from   par_telep_utca_percent
                    order by OSM_allapot_szazalek desc
                    "
s <- gsub("Bázis",basename,s)
                    
rs <- dbGetQuery(con, s )  
sortable.html.table(rs, '00_TELEPÜLÉS_LFEDETTSÉG.html' , exportdir
                      ,  gsub("Bázis",basename, '00_TELEPÜLÉS_LFEDETTSÉG - OSM utcanevek lefedettsége a Bázis utcanevek alapján' ))

## Closes the connection
dbDisconnect(con)

## Frees all the resources on the driver
dbUnloadDriver(drv)
