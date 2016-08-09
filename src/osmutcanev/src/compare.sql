---
---
---
---
\set ON_ERROR_STOP 1
;;;;;
DROP TABLE IF EXISTS bazis_telep_utca CASCADE;
create table bazis_telep_utca
   as
             select telepules, utcanev, UTCANEV_TISZTIT(utcanev) as utcanev_t ,''::text as alt_name from bazis_budapest
   union all select telepules, utcanev, UTCANEV_TISZTIT(utcanev) as utcanev_t ,''::text as alt_name from bazis_videk
;
---
CREATE INDEX  bazis_telep_utca_telepules    ON bazis_telep_utca (telepules);
CREATE INDEX  bazis_telep_utca_trgm_idxt_t  ON bazis_telep_utca     USING gist (telepules  , utcanev_t   gist_trgm_ops);
CREATE INDEX  bazis_telep_utca_trgm_idxt_a  ON bazis_telep_utca     USING gist (telepules  , alt_name    gist_trgm_ops);
ANALYZE  bazis_telep_utca;

-- 

Drop table IF EXISTS par_telep_utca_simil;
Create         table par_telep_utca_simil as
-- explain
 select * from
(
SELECT 
       COALESCE(b.telepules ,o.telepules )     as telepules 
     , COALESCE(b.utcanev   ,o.utcanev   )     as utcanev  
     , b.utcanev              as b_utcanev 
     , o.utcanev              as o_utcanev 
     , o.alt_name             as o_utcanev_alt_name 
     , similarity ( o.utcanev   ,b.utcanev )   as  o_similarity
     , similarity ( o.utcanev_t ,b.utcanev_t ) as  t_similarity
     , similarity ( o.alt_name  ,b.utcanev )   as  o_similarity_alt_name
     , o.arri_shortid         as o_arri_shortid
     , o.arri_osm_id_url      as o_arri_osm_id_url
FROM osm_telep_utca  as o  INNER JOIN  bazis_telep_utca  as b
on
      o.telepules =  b.telepules
 and
      ( o.utcanev_t %  b.utcanev_t ) 

union all

SELECT 
       COALESCE(b.telepules ,o.telepules )     as telepules 
     , COALESCE(b.utcanev   ,o.utcanev   )     as utcanev  
     , b.utcanev              as b_utcanev 
     , o.utcanev              as o_utcanev 
     , o.alt_name             as o_utcanev_alt_name 
     , similarity ( o.utcanev   ,b.utcanev )   as  o_similarity
     , similarity ( o.utcanev_t ,b.utcanev_t ) as  t_similarity
     , similarity ( o.alt_name  ,b.utcanev )   as  o_similarity_alt_name
     , o.arri_shortid         as o_arri_shortid
     , o.arri_osm_id_url      as o_arri_osm_id_url     
FROM osm_telep_utca  as o  INNER JOIN  bazis_telep_utca  as b
on  
      o.telepules =  b.telepules
 and  o.alt_name  <> ''    
 and  ( o.alt_name   %  b.utcanev  )
) p
ORDER BY telepules , utcanev    
;


-- 

Drop table IF EXISTS par_telep_utca_simil_f;
Create         table par_telep_utca_simil_f
 as
select distinct on (telepules, o_utcanev) 
   * from
( 
select distinct on (telepules, utcanev) 
   * from par_telep_utca_simil  
 order by telepules, utcanev  , GREATEST( o_similarity, t_similarity, o_similarity_alt_name ) DESC ,  o_similarity DESC,  t_similarity DESC , o_similarity_alt_name DESC
) t
 order by telepules, o_utcanev, GREATEST( o_similarity, t_similarity, o_similarity_alt_name ) DESC ,  o_similarity DESC,  t_similarity DESC , o_similarity_alt_name DESC
 ;
 
CREATE INDEX par_telep_sf_o_utcanev   ON par_telep_utca_simil_f USING gist (o_utcanev );
CREATE INDEX par_telep_sf_b_utcanev   ON par_telep_utca_simil_f USING gist (b_utcanev );


Drop table IF EXISTS par_telep_utca_all;
Create         table par_telep_utca_all
 as
select * from 
(

select telepules,utcanev,b_utcanev,o_utcanev ,o_utcanev_alt_name 
      ,o_similarity,t_similarity, o_similarity_alt_name
      ,o_arri_shortid,o_arri_osm_id_url
   ,case when o_similarity = 1         then   'EGYEZŐ'
        when o_similarity_alt_name = 1 then   'EGYEZŐ_ALT_NAME' 
        when o_similarity_alt_name > greatest(o_similarity,t_similarity) 
            then 'HASONLÓ_ALT_NAME'||to_char( o_similarity_alt_name  *10,'S00')||'p' 
        else  'HASONLÓ'||to_char( (greatest(o_similarity,t_similarity)-0.1) *10,'S00')||'p'
   end            as  checktype
   from  par_telep_utca_simil_f 
   
UNION ALL 

select telepules
     , utcanev
     , ''        as b_utcanev
     , utcanev   as o_utcanev
     , alt_name  as o_utcanev_alt_name 
     , 0         as o_similarity
     , 0         as t_similarity
     , 0         as o_similarity_alt_name
     , o.arri_shortid         as o_arri_shortid
     , o.arri_osm_id_url      as o_arri_osm_id_url     
     , 'NINCS_HASONLO_BAZ'  as checktype
from osm_telep_utca o 
where not exists ( select * from par_telep_utca_simil_f f 
                   where f.telepules=o.telepules and f.o_utcanev=o.utcanev 
                   )  

UNION ALL 

select telepules
     , utcanev     
     , utcanev   as b_utcanev
     , ''        as o_utcanev
     , ''        as o_utcanev_alt_name 
     , 0         as o_similarity
     , 0         as t_similarity
     , 0         as o_similarity_alt_name
     , ''        as o_arri_shortid
     , ''        as o_arri_osm_id_url        
     , 'NINCS_HASONLO_OSM'  as checktype
from bazis_telep_utca  b 
where not exists ( select * from par_telep_utca_simil_f f 
                   where f.telepules=b.telepules and f.b_utcanev=b.utcanev 
                   )           
                     
) qqq
order by  telepules  , utcanev , b_utcanev , o_utcanev
;

CREATE INDEX par_telep_utca_all_telepules   ON par_telep_utca_all USING gist (telepules,utcanev );
ALTER TABLE par_telep_utca_all  CLUSTER ON par_telep_utca_all_telepules ;

-- 

;

Drop table IF EXISTS par_telep_utca_sum_napistat;
Create table         par_telep_utca_sum_napistat  as
SELECT
     checktype , count(*) as _db
FROM  par_telep_utca_all
GROUP BY checktype 
ORDER BY checktype 
;






Drop table IF EXISTS par_telep_utca_sum;
Create table         par_telep_utca_sum  as
SELECT
 telepules, checktype , count(*) as _db
 
FROM par_telep_utca_all
GROUP BY telepules,checktype 
ORDER BY telepules,checktype 
;




Drop table IF EXISTS par_telep_utca_percent;
Create table         par_telep_utca_percent  as
select 
    telepules 
  , round(
      case when _db_bazis <> 0 
         then ((_db_egyezo::real+_db_hasonlo::real) / _db_bazis::real) * 100
         else 0
      end ::numeric
     ,0 ) 
          as osm_allapot_szazalek
  , _db_egyezo
  , _db_hasonlo
  , _db_nincs_hasonlo_osm 
  , _db_bazis   
  , _db_nincs_hasonlo_baz
FROM
(
SELECT
 telepules 
 , sum((LEFT(checktype,6)='EGYEZŐ')::int)            as _db_egyezo
 , sum((LEFT(checktype,7)='HASONLÓ')::int)           as _db_hasonlo
 , sum((checktype        ='NINCS_HASONLO_OSM')::int) as _db_nincs_hasonlo_osm 
 , sum((checktype       <>'NINCS_HASONLO_BAZ')::int) as _db_bazis 
 , sum((checktype        ='NINCS_HASONLO_BAZ')::int) as _db_nincs_hasonlo_baz
 , count(*) as _db_all
 
FROM par_telep_utca_all
GROUP BY telepules 
ORDER BY telepules 
) pp
order by osm_allapot_szazalek desc
;


--------------------------------------------------
Drop table IF EXISTS hun_stat_percent;
Create table         hun_stat_percent  as
select * 
   , ( db_egyezo + db_hasonlo) / db_bazis  as eh_percent
   , ( db_egyezo   ) / db_bazis            as percent
from (
select sum(_db_egyezo)     as db_egyezo
      ,sum(_db_hasonlo)    as db_hasonlo
      ,sum(_db_bazis)      as db_bazis 
  from par_telep_utca_percent
) p
;


-------------------------------------------------
Drop table IF EXISTS hun_city_percent;
Create         table hun_city_percent as
SELECT 
 ROW_NUMBER()  OVER (ORDER BY name  ASC) as gid 
,name
,COALESCE(osm_allapot_szazalek,0)  as osm_allapot_szazalek
,COALESCE(db_egyezo,0)             as db_egyezo 
,COALESCE(db_hasonlo,0)            as db_hasonlo
,COALESCE(db_nincs_hasonlo_osm,0)  as db_nincs_hasonlo_osm 
,COALESCE(db_bazis,0)              as db_bazis
,COALESCE(db_nincs_hasonlo_baz,0)  as db_nincs_hasonlo_baz
--,wkt_geometry  
,wkb_geometry 
from (

select
 name
,percent.osm_allapot_szazalek  as osm_allapot_szazalek
,percent._db_egyezo            as db_egyezo
,percent._db_hasonlo           as db_hasonlo
,percent._db_nincs_hasonlo_osm as db_nincs_hasonlo_osm
,percent._db_bazis             as db_bazis
,percent._db_nincs_hasonlo_baz as db_nincs_hasonlo_baz
-- ,ST_AsText(st_transform(st_simplifyPreserveTopology(geometry ,50),4326))   as wkt_geometry  
,ST_Transform(  ST_RemoveRepeatedPoints( ST_SimplifyPreserveTopology(city.geometry,50),50) , 4326 )  as wkb_geometry

FROM  hun_city               as city
LEFT JOIN par_telep_utca_percent as percent ON city.name=percent.telepules

) as pp
ORDER BY name;


