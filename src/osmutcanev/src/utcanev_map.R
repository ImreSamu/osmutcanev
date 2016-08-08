#
#
#  Map generate 
#
#

library(RPostgreSQL)
library(postGIStools)
library(RColorBrewer)
library(sp)
library(grid)
library(ggplot2)

pngname    <- "./output/web/pics/osmhu_streetname_latest.png"

#maplabel1  <- "OpenStreetMap Hungary - Street Name Completeness Statistics "
#maplabel2  <- "Experimental! "

maplabel1 <- Sys.getenv("MAPLABEL1") 
maplabel2 <- Sys.getenv("MAPLABEL2")
runtimelabel <- paste( "Runtime:", Sys.getenv("RUNTIME") )
lastosmtimelabel <- paste ("  LastOsmTimestamp:", Sys.getenv("LASTOSMTIMESTAMP")  )

con <- dbConnect(PostgreSQL())

#con <- dbConnect(PostgreSQL(), dbname = "osm", user = "osm",
#                 host = "172.18.0.2", password = "osm")

hun_city_percent <- get_postgis_query(con, 
 "SELECT name
     ,OSM_allapot_szazalek
     ,db_egyezo
     ,db_hasonlo
     ,db_nincs_hasonlo_osm 
     ,db_bazis   
     ,db_nincs_hasonlo_baz   
     ,wkb_geometry 
   FROM hun_city_percent",
   geom_name = "wkb_geometry")
class(hun_city_percent)


hun_stat     = dbGetQuery(con, " 
      SELECT 
          db_egyezo  / db_bazis                             AS equal_percent
        , db_hasonlo / db_bazis                             AS similar_percent
        , db_bazis-db_hasonlo-db_egyezo                     AS db_hianyzo
        ,(db_bazis-db_hasonlo-db_egyezo  )  / db_bazis      AS missing_percent
        , * 
      FROM hun_stat_percent;
     ")

hun_stat

sprintf("%8.5f%%", hun_stat$equal_percent*100 )  
sprintf("%8.5f%%", hun_stat$similar_percent*100 )  
sprintf("%8.5f%% / %6d %s", hun_stat$equal_percent*100   , hun_stat$db_egyezo  , "exact name" ) 
sprintf("%8.5f%% / %6d %s", hun_stat$similar_percent*100 , hun_stat$db_hasonlo , "similar name") 


hun_stat_e_str0="  exact:"
hun_stat_s_str0="similar:"
hun_stat_m_str0="missing:" 
hun_stat_e_str0
hun_stat_s_str0
hun_stat_m_str0

hun_stat_e_str1=sprintf("%6d",hun_stat$db_egyezo   ) 
hun_stat_s_str1=sprintf("%6d",hun_stat$db_hasonlo  ) 
hun_stat_m_str1=sprintf("%6d",hun_stat$db_hianyzo  ) 
hun_stat_e_str1
hun_stat_s_str1
hun_stat_m_str1

hun_stat_e_str2=sprintf("(%08.5f%%)",hun_stat$equal_percent*100   ) 
hun_stat_s_str2=sprintf("(%08.5f%%)",hun_stat$similar_percent*100 ) 
hun_stat_m_str2=sprintf("(%08.5f%%)",hun_stat$missing_percent*100 ) 
hun_stat_e_str2
hun_stat_s_str2
hun_stat_m_str2

png(filename=pngname, width = 1200, height = 760,  units = "px")
clrs <- colorRampPalette(brewer.pal(7, "Greens")) 
spplot( hun_city_percent,"osm_allapot_szazalek",
        col.regions =   clrs(100),
        main=list(label=maplabel1 ,cex=2,col="midnightblue" )
      )

grid.text("Completeness (percent)", x=unit(0.95, "npc"), y=unit(0.50, "npc"), rot=-90, , gp=gpar( col="Black"))
grid.text( lastosmtimelabel , x=unit(0.72, "npc"), y=unit(0.06, "npc"), rot=0, gp=gpar(fontsize=20,col="midnightblue",fontface="bold"))
grid.text( runtimelabel     , x=unit(0.84, "npc"), y=unit(0.04, "npc"), rot=0, gp=gpar(fontsize=10,col="darkblue"))

grid.text(hun_stat_e_str0 , x=unit(0.10, "npc"), y=unit(0.91, "npc"), rot=0, , gp=gpar(fontsize=28,col="darkgreen",fontface="bold",family="mono") )
grid.text(hun_stat_s_str0 , x=unit(0.10, "npc"), y=unit(0.86, "npc"), rot=0, , gp=gpar(fontsize=28,col="darkgoldenrod1",fontface="bold",family="mono") )
grid.text(hun_stat_m_str0 , x=unit(0.10, "npc"), y=unit(0.81, "npc"), rot=0, , gp=gpar(fontsize=28,col="firebrick1",fontface="bold",family="mono") )

grid.text(hun_stat_e_str1 , x=unit(0.20, "npc"), y=unit(0.91, "npc"), rot=0, , gp=gpar(fontsize=28,col="darkgreen",fontface="bold",family="mono") )
grid.text(hun_stat_s_str1 , x=unit(0.20, "npc"), y=unit(0.86, "npc"), rot=0, , gp=gpar(fontsize=28,col="darkgoldenrod1",fontface="bold",family="mono") )
grid.text(hun_stat_m_str1 , x=unit(0.20, "npc"), y=unit(0.81, "npc"), rot=0, , gp=gpar(fontsize=28,col="firebrick1",fontface="bold",family="mono") )

grid.text(hun_stat_e_str2 , x=unit(0.34, "npc"), y=unit(0.91, "npc"), rot=0, , gp=gpar(fontsize=28,col="darkgreen",fontface="bold",family="mono") )
grid.text(hun_stat_s_str2 , x=unit(0.34, "npc"), y=unit(0.86, "npc"), rot=0, , gp=gpar(fontsize=28,col="darkgoldenrod1",fontface="bold",family="mono") )
grid.text(hun_stat_m_str2 , x=unit(0.34, "npc"), y=unit(0.81, "npc"), rot=0, , gp=gpar(fontsize=28,col="firebrick1",fontface="bold",family="mono") )

grid.text( maplabel2 , x=unit(0.80, "npc"), y=unit(0.32, "npc"), rot=45, , gp=gpar(fontsize=32,col="darkmagenta",fontface="bold") )

dev.off()

## Closes the connection
dbDisconnect(con)

