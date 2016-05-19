﻿
CREATE EXTENSION IF NOT EXISTS fuzzystrmatch ;
CREATE EXTENSION IF NOT EXISTS pg_trgm ;
CREATE EXTENSION IF NOT EXISTS btree_gist;
SELECT set_limit(0.36);

--
CREATE OR REPLACE FUNCTION  UTCANEV_TISZTIT(utcanev text) RETURNS text as $$
BEGIN 
 RETURN   translate( regexp_replace(
     translate( lower( ( utcanev)) , 'őúáűéíó-.,','öuaüeio')  ,
  '[[:<:]](dr|utca|ut|utja)[[:>:]]',
  ' ',
  'gi'
),' ','');
END ;
$$ LANGUAGE plpgsql IMMUTABLE;

delete  from osm_addressname where name ='';

-- ALTER TABLE hun_city CLUSTER ON hun_city_geom_geohash;

--Magyar települések
drop table if exists admin_level8 cascade;
create table admin_level8 as 
select a.id , a.name , a.admin_level,  a.geometry 
from osm_admin a
JOIN osm_admin hun
ON   st_intersects ( ST_PointOnSurface(a.geometry), hun.geometry) 
    and  hun.admin_level=2 and hun.name='Magyarország'
    and    a.admin_level=8
    and    a.name != 'Budapest'
    and    a.type='administrative'
    and  hun.type='administrative'     
;
-- select * from admin_level8 where name like 'Budapest%';


-- Bp kerületek
drop table if exists admin_level9 cascade;
create table admin_level9 as 
select a.id , substr(a.wikipedia,4) as name , a.admin_level, a.geometry 
from osm_admin a
JOIN osm_admin hun
ON   st_intersects ( ST_PointOnSurface(a.geometry), hun.geometry) 
    and  hun.admin_level=8 and hun.name='Budapest'
    and    a.admin_level=9
    and    a.type='administrative'
    and  hun.type='administrative'    
order by a.name    
;
-- select * from admin_level9 ;


drop table if exists hun_city cascade;
create table hun_city as 
           select  a8.*  from admin_level8 as a8
union all  select  a9.*  from admin_level9 as a9
;    
CREATE INDEX hun_city_geom  ON hun_city USING gist  (geometry);
DROP INDEX IF exists  hun_city_geom_geohash;
CREATE INDEX hun_city_geom_geohash
  ON hun_city
  USING btree
  (st_geohash(st_transform(st_setsrid(box2d(geometry)::geometry, 3857), 4326)) COLLATE pg_catalog."default");
  
ALTER TABLE hun_city CLUSTER ON hun_city_geom_geohash;
ANALYZE  hun_city;






Drop table IF EXISTS osm_telep_utca CASCADE;
Create table         osm_telep_utca as
select telepules
      ,utcanev 
      ,UTCANEV_TISZTIT(utcanev) as utcanev_t
      ,alt_name
      ,array_agg(osm_id) as arri_osm_id
      ,array_agg(         osmkey||'_'||osmvalue) as arri_osmkey
      ,array_agg(distinct osmkey||'_'||osmvalue) as arrd_osmkey
      ,count(*)      as osm_line_count
from 
(
t
SELECT 
        city.name      as telepules 
       ,pline.name     as utcanev
       ,pline.alt_name as alt_name
       ,pline.key      as osmkey
       ,pline.value    as osmvalue
       ,pline.id       as osm_id    
FROM hun_city            AS city
JOIN osm_addressname     AS pline
ON   st_intersects (city.geometry, pline.geometry ) 

) t

GROUP BY telepules,utcanev,utcanev_t,alt_name
ORDER BY telepules,utcanev,utcanev_t,alt_name
;

CREATE INDEX  osm_telep_utca_telepules    ON osm_telep_utca (telepules);
CREATE INDEX  osm_telep_utca_trgm_idxt_t  ON osm_telep_utca     USING gist (telepules  , utcanev_t   gist_trgm_ops);
CREATE INDEX  osm_telep_utca_trgm_idxt_a  ON osm_telep_utca     USING gist (telepules  , alt_name    gist_trgm_ops);
ANALYZE  osm_telep_utca;

-- select * from osm_telep_utca;
-- select * from osm_telep_utca where telepules like 'Budapest%';
