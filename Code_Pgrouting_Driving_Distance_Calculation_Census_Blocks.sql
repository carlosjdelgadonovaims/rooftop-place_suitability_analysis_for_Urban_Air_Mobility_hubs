#######################################
/*Creation of the catchment table*/

CREATE TABLE public.manhattan_catchment_nodes as
(
WITH 
nodes AS (
SELECT array_agg(n_id) AS nodes from census_blocks.closest_block_man_node where b_id<= 4000)
SELECT from_v as start_node, node as end_node, agg_cost as cost from nodes, pgr_drivingdistance(
	'SELECT gid as id, source as source, target as target, length_m as cost FROM public.ways'::text, nodes, 2000, false)
)


/*Adding the field node_id to the original table of census blocks*/

ALTER TABLE census_blocks.f_manh_blocks_pop_4326
ADD column node_id bigint;
UPDATE census_blocks.f_manh_blocks_pop_4326
set node_id= (SELECT n_id from (
(SELECT n_id, res.id
FROM census_blocks.f_manh_blocks_pop_4326 as res
LEFT JOIN census_blocks.closest_block_man_node
ON res.id = census_blocks.closest_block_man_node.b_id))c
WHERE c.id = census_blocks.f_manh_blocks_pop_4326.id)


/*Creation of the closest nodes for each entitie*/


CREATE TABLE poi.closest_hcenters_node as
SELECT
  hc.id as b_id,
  nodes.id as n_id,
  ST_Distance(geography(hc.geom), geography(nodes.the_geom)) as distance
FROM
  (SELECT DISTINCT ON (id, geom) *
   FROM poi.f_health_centers_4326
   WHERE id IS NOT NULL) AS hc
CROSS JOIN LATERAL
  (SELECT id, the_geom
   FROM public.ways_vertices_pgr
   ORDER BY hc.geom <-> the_geom
   LIMIT 1) AS nodes
   
   
   
CREATE TABLE poi.closest_government_node as
SELECT
  gov.id as b_id,
  nodes.id as n_id,
  ST_Distance(geography(gov.geom), geography(nodes.the_geom)) as distance
FROM
  (SELECT DISTINCT ON (id, geom) *
   FROM poi.f_government_facilities_4326
   WHERE id IS NOT NULL) AS gov
CROSS JOIN LATERAL
  (SELECT id, the_geom
   FROM public.ways_vertices_pgr
   ORDER BY gov.geom <-> the_geom
   LIMIT 1) AS nodes
   
   
CREATE TABLE poi.closest_embassies_node as
SELECT
  e.id as b_id,
  nodes.id as n_id,
  ST_Distance(geography(e.geom), geography(nodes.the_geom)) as distance
FROM
  (SELECT DISTINCT ON (id, geom) *
   FROM poi."f_embassies_point_4326_Int"
   WHERE id IS NOT NULL) AS e
CROSS JOIN LATERAL
  (SELECT id, the_geom
   FROM public.ways_vertices_pgr
   ORDER BY e.geom <-> the_geom
   LIMIT 1) AS nodes   


CREATE TABLE poi.closest_park_node as
SELECT
  p.id as b_id,
  nodes.id as n_id,
  ST_Distance(geography(p.geom), geography(nodes.the_geom)) as distance
FROM
  (SELECT DISTINCT ON (id, geom) *
   FROM poi."f_parks_points_4326_Int"
   WHERE id IS NOT NULL) AS p
CROSS JOIN LATERAL
  (SELECT id, the_geom
   FROM public.ways_vertices_pgr
   ORDER BY p.geom <-> the_geom
   LIMIT 1) AS nodes
   
   
CREATE TABLE poi.closest_malls_node as
SELECT
  m.id as b_id,
  nodes.id as n_id,
  ST_Distance(geography(m.geom), geography(nodes.the_geom)) as distance
FROM
  (SELECT DISTINCT ON (id, geom) *
   FROM poi."f_plazas_malls_4326_Int"
   WHERE id IS NOT NULL) AS m
CROSS JOIN LATERAL
  (SELECT id, the_geom
   FROM public.ways_vertices_pgr
   ORDER BY m.geom <-> the_geom
   LIMIT 1) AS nodes
   
   
CREATE TABLE poi.closest_psafety_node as
SELECT
  ps.id as b_id,
  nodes.id as n_id,
  ST_Distance(geography(ps.geom), geography(nodes.the_geom)) as distance
FROM
  (SELECT DISTINCT ON (id, geom) *
   FROM poi.f_public_safety_4326
   WHERE id IS NOT NULL) AS ps
CROSS JOIN LATERAL
  (SELECT id, the_geom
   FROM public.ways_vertices_pgr
   ORDER BY ps.geom <-> the_geom
   LIMIT 1) AS nodes
   
   
CREATE TABLE poi.closest_touristp_node as
SELECT
  tp.id as b_id,
  nodes.id as n_id,
  ST_Distance(geography(tp.geom), geography(nodes.the_geom)) as distance
FROM
  (SELECT DISTINCT ON (id, geom) *
   FROM poi.f_tourism_places_nyc_4326
   WHERE id IS NOT NULL) AS tp
CROSS JOIN LATERAL
  (SELECT id, the_geom
   FROM public.ways_vertices_pgr
   ORDER BY tp.geom <-> the_geom
   LIMIT 1) AS nodes
   
   
CREATE TABLE poi.closest_schools_uni_node as
SELECT
  sch.id as b_id,
  nodes.id as n_id,
  ST_Distance(geography(sch.geom), geography(nodes.the_geom)) as distance
FROM
  (SELECT DISTINCT ON (id, geom) *
   FROM poi.f_schools_uni_points_4326
   WHERE id IS NOT NULL) AS sch
CROSS JOIN LATERAL
  (SELECT id, the_geom
   FROM public.ways_vertices_pgr
   ORDER BY sch.geom <-> the_geom
   LIMIT 1) AS nodes
   
   
   
CREATE TABLE poi.closest_graveyards_node as
SELECT
  gr.id as b_id,
  nodes.id as n_id,
  ST_Distance(geography(gr.geom), geography(nodes.the_geom)) as distance
FROM
  (SELECT DISTINCT ON (id, geom) *
   FROM poi."f_graveyards_points_4326_Int"
   WHERE id IS NOT NULL) AS gr
CROSS JOIN LATERAL
  (SELECT id, the_geom
   FROM public.ways_vertices_pgr
   ORDER BY gr.geom <-> the_geom
   LIMIT 1) AS nodes
   
   
CREATE TABLE transport.closest_bus_node as
SELECT
  bus.id as b_id,
  nodes.id as n_id,
  ST_Distance(geography(bus.geom), geography(nodes.the_geom)) as distance
FROM
  (SELECT DISTINCT ON (id, geom) *
   FROM transport."f_bus_stop_shelters_4326_Int"
   WHERE id IS NOT NULL) AS bus
CROSS JOIN LATERAL
  (SELECT id, the_geom
   FROM public.ways_vertices_pgr
   ORDER BY bus.geom <-> the_geom
   LIMIT 1) AS nodes
   
   
CREATE TABLE transport.closest_subway_node as
SELECT
  sub.id as b_id,
  nodes.id as n_id,
  ST_Distance(geography(sub.geom), geography(nodes.the_geom)) as distance
FROM
  (SELECT DISTINCT ON (id, geom) *
   FROM transport."f_subway_stations_4326_Int"
   WHERE id IS NOT NULL) AS sub
CROSS JOIN LATERAL
  (SELECT id, the_geom
   FROM public.ways_vertices_pgr
   ORDER BY sub.geom <-> the_geom
   LIMIT 1) AS nodes
   
   
CREATE TABLE poi.closest_hospital_node as
SELECT
  ho.id as b_id,
  nodes.id as n_id,
  ST_Distance(geography(ho.geom), geography(nodes.the_geom)) as distance
FROM
  (SELECT DISTINCT ON (id, geom) *
   FROM poi."f_hospitals_points_4326_Int"
   WHERE id IS NOT NULL) AS ho
CROSS JOIN LATERAL
  (SELECT id, the_geom
   FROM public.ways_vertices_pgr
   ORDER BY ho.geom <-> the_geom
   LIMIT 1) AS nodes
   

CREATE TABLE public.closest_b_node as
SELECT
  blocks.id as b_id,
  nodes.id as n_id,
  ST_Distance(geography(blocks.geom), geography(nodes.the_geom)) as distance
FROM
  (SELECT DISTINCT ON (id, geom) *
   FROM census_blocks.f_nyc_blocks_pop_4326
   WHERE id IS NOT NULL) AS blocks
CROSS JOIN LATERAL
  (SELECT id, the_geom
   FROM public.ways_vertices_pgr
   ORDER BY blocks.geom <-> the_geom
   LIMIT 1) AS nodes   
   

CREATE TABLE poi.closest_parking_lots_node as
SELECT
  pl.id as b_id,
  nodes.id as n_id,
  ST_Distance(geography(pl.geom), geography(nodes.the_geom)) as distance
FROM
  (SELECT DISTINCT ON (id, geom) *
   FROM poi.f_parking_points_4326
   WHERE id IS NOT NULL) AS pl
CROSS JOIN LATERAL
  (SELECT id, the_geom
   FROM public.ways_vertices_pgr
   ORDER BY pl.geom <-> the_geom
   LIMIT 1) AS nodes
   
   
/*Creation and feeding of the table minimum cost when considering all the entities*/

CREATE TABLE poi.mom_minimum_cost AS
(select '1' as poi_type, start_node, min(cost) as cost from 
(select fee.start_node, fee.end_node, cost from public.manhattan_catchment_nodes as fee
	WHERE (start_node, end_node) in
	(select node_id, pe.n_id from census_blocks.f_manh_blocks_pop_4326, poi.closest_hospital_node as pe))d GROUP BY d.start_node)

INSERT INTO poi.mom_minimum_cost
(select '2' as poi_type, start_node, min(cost) as cost from 
(select fee.start_node, fee.end_node, cost from public.manhattan_catchment_nodes as fee
	WHERE (start_node, end_node) in
	(select node_id, pe.n_id from census_blocks.f_manh_blocks_pop_4326, poi.closest_hcenters_node as pe))d GROUP BY d.start_node)
	
INSERT INTO poi.mom_minimum_cost
(select '3' as poi_type, start_node, min(cost) as cost from 
(select fee.start_node, fee.end_node, cost from public.manhattan_catchment_nodes as fee
	WHERE (start_node, end_node) in
	(select node_id, pe.n_id from census_blocks.f_manh_blocks_pop_4326, poi.closest_government_node as pe))d GROUP BY d.start_node)
	
INSERT INTO poi.mom_minimum_cost
(select '4' as poi_type, start_node, min(cost) as cost from 
(select fee.start_node, fee.end_node, cost from public.manhattan_catchment_nodes as fee
	WHERE (start_node, end_node) in
	(select node_id, pe.n_id from census_blocks.f_manh_blocks_pop_4326, poi.closest_embassies_node as pe))d GROUP BY d.start_node)
	
INSERT INTO poi.mom_minimum_cost
(select '5' as poi_type, start_node, min(cost) as cost from 
(select fee.start_node, fee.end_node, cost from public.manhattan_catchment_nodes as fee
	WHERE (start_node, end_node) in
	(select node_id, pe.n_id from census_blocks.f_manh_blocks_pop_4326, poi.closest_park_node as pe))d GROUP BY d.start_node)
	
INSERT INTO poi.mom_minimum_cost
(select '6' as poi_type, start_node, min(cost) as cost from 
(select fee.start_node, fee.end_node, cost from public.manhattan_catchment_nodes as fee
	WHERE (start_node, end_node) in
	(select node_id, pe.n_id from census_blocks.f_manh_blocks_pop_4326, poi.closest_malls_node as pe))d GROUP BY d.start_node)
	
INSERT INTO poi.mom_minimum_cost
(select '7' as poi_type, start_node, min(cost) as cost from 
(select fee.start_node, fee.end_node, cost from public.manhattan_catchment_nodes as fee
	WHERE (start_node, end_node) in
	(select node_id, pe.n_id from census_blocks.f_manh_blocks_pop_4326, poi.closest_psafety_node as pe))d GROUP BY d.start_node)
	
INSERT INTO poi.mom_minimum_cost
(select '8' as poi_type, start_node, min(cost) as cost from 
(select fee.start_node, fee.end_node, cost from public.manhattan_catchment_nodes as fee
	WHERE (start_node, end_node) in
	(select node_id, pe.n_id from census_blocks.f_manh_blocks_pop_4326, poi.closest_touristp_node as pe))d GROUP BY d.start_node)
	
INSERT INTO poi.mom_minimum_cost
(select '9' as poi_type, start_node, min(cost) as cost from 
(select fee.start_node, fee.end_node, cost from public.manhattan_catchment_nodes as fee
	WHERE (start_node, end_node) in
	(select node_id, pe.n_id from census_blocks.f_manh_blocks_pop_4326, poi.closest_schools_uni_node as pe))d GROUP BY d.start_node)
	
	
INSERT INTO poi.mom_minimum_cost
(select '10' as poi_type, start_node, min(cost) as cost from 
(select fee.start_node, fee.end_node, cost from public.manhattan_catchment_nodes as fee
	WHERE (start_node, end_node) in
	(select node_id, pe.n_id from census_blocks.f_manh_blocks_pop_4326, poi.closest_graveyards_node as pe))d GROUP BY d.start_node)
	
	
INSERT INTO poi.mom_minimum_cost
(select '11' as poi_type, start_node, min(cost) as cost from 
(select fee.start_node, fee.end_node, cost from public.manhattan_catchment_nodes as fee
	WHERE (start_node, end_node) in
	(select node_id, pe.n_id from census_blocks.f_manh_blocks_pop_4326, transport.closest_bus_node as pe))d GROUP BY d.start_node)
	
INSERT INTO poi.mom_minimum_cost
(select '12' as poi_type, start_node, min(cost) as cost from 
(select fee.start_node, fee.end_node, cost from public.manhattan_catchment_nodes as fee
	WHERE (start_node, end_node) in
	(select node_id, pe.n_id from census_blocks.f_manh_blocks_pop_4326, transport.closest_subway_node as pe))d GROUP BY d.start_node)
	
INSERT INTO poi.mom_minimum_cost
(select '13' as poi_type, start_node, min(cost) as cost from 
(select fee.start_node, fee.end_node, cost from public.manhattan_catchment_nodes as fee
	WHERE (start_node, end_node) in
	(select node_id, pe.n_id from census_blocks.f_manh_blocks_pop_4326, poi.closest_parking_lots_node as pe))d GROUP BY d.start_node)


/*Creation and feeding of the table which has the number of entities within 2km when considering all the entities*/

CREATE TABLE poi.mom_counts_2km AS 
(select '1' as poi_type, f.start_node, count(f.start_node) as cnts from (				 
select distinct fee.start_node, fee.end_node, cost from public.manhattan_catchment_nodes as fee
	WHERE (start_node, end_node) in
	(select node_id, n_id from census_blocks.f_manh_blocks_pop_4326, poi.closest_hospital_node))f group by start_node)

INSERT INTO poi.mom_counts_2km
(select '2' as poi_type, f.start_node, count(f.start_node) as cnts from (				 
select distinct fee.start_node, fee.end_node, cost from public.manhattan_catchment_nodes as fee
	WHERE (start_node, end_node) in
	(select node_id, n_id from census_blocks.f_manh_blocks_pop_4326, poi.closest_hcenters_node))f group by start_node)
	
INSERT INTO poi.mom_counts_2km
(select '3' as poi_type, f.start_node, count(f.start_node) as cnts from (				 
select distinct fee.start_node, fee.end_node, cost from public.manhattan_catchment_nodes as fee
	WHERE (start_node, end_node) in
	(select node_id, n_id from census_blocks.f_manh_blocks_pop_4326, poi.closest_government_node))f group by start_node)	
	
	
INSERT INTO poi.mom_counts_2km
(select '4' as poi_type, f.start_node, count(f.start_node) as cnts from (				 
select distinct fee.start_node, fee.end_node, cost from public.manhattan_catchment_nodes as fee
	WHERE (start_node, end_node) in
	(select node_id, n_id from census_blocks.f_manh_blocks_pop_4326, poi.closest_embassies_node))f group by start_node)
	
INSERT INTO poi.mom_counts_2km
(select '5' as poi_type, f.start_node, count(f.start_node) as cnts from (				 
select distinct fee.start_node, fee.end_node, cost from public.manhattan_catchment_nodes as fee
	WHERE (start_node, end_node) in
	(select node_id, n_id from census_blocks.f_manh_blocks_pop_4326, poi.closest_park_node))f group by start_node)
	
	
INSERT INTO poi.mom_counts_2km
(select '6' as poi_type, f.start_node, count(f.start_node) as cnts from (				 
select distinct fee.start_node, fee.end_node, cost from public.manhattan_catchment_nodes as fee
	WHERE (start_node, end_node) in
	(select node_id, n_id from census_blocks.f_manh_blocks_pop_4326, poi.closest_malls_node))f group by start_node)
	
INSERT INTO poi.mom_counts_2km
(select '7' as poi_type, f.start_node, count(f.start_node) as cnts from (				 
select distinct fee.start_node, fee.end_node, cost from public.manhattan_catchment_nodes as fee
	WHERE (start_node, end_node) in
	(select node_id, n_id from census_blocks.f_manh_blocks_pop_4326, poi.closest_psafety_node))f group by start_node)
	
INSERT INTO poi.mom_counts_2km
(select '8' as poi_type, f.start_node, count(f.start_node) as cnts from (				 
select distinct fee.start_node, fee.end_node, cost from public.manhattan_catchment_nodes as fee
	WHERE (start_node, end_node) in
	(select node_id, n_id from census_blocks.f_manh_blocks_pop_4326, poi.closest_touristp_node))f group by start_node)
	
	
INSERT INTO poi.mom_counts_2km
(select '9' as poi_type, f.start_node, count(f.start_node) as cnts from (				 
select distinct fee.start_node, fee.end_node, cost from public.manhattan_catchment_nodes as fee
	WHERE (start_node, end_node) in
	(select node_id, n_id from census_blocks.f_manh_blocks_pop_4326, poi.closest_schools_uni_node))f group by start_node)
	
	
INSERT INTO poi.mom_counts_2km
(select '10' as poi_type, f.start_node, count(f.start_node) as cnts from (				 
select distinct fee.start_node, fee.end_node, cost from public.manhattan_catchment_nodes as fee
	WHERE (start_node, end_node) in
	(select node_id, n_id from census_blocks.f_manh_blocks_pop_4326, poi.closest_graveyards_node))f group by start_node)
	
INSERT INTO poi.mom_counts_2km
(select '11' as poi_type, f.start_node, count(f.start_node) as cnts from (				 
select distinct fee.start_node, fee.end_node, cost from public.manhattan_catchment_nodes as fee
	WHERE (start_node, end_node) in
	(select node_id, n_id from census_blocks.f_manh_blocks_pop_4326, transport.closest_bus_node))f group by start_node)
	
	
INSERT INTO poi.mom_counts_2km
(select '12' as poi_type, f.start_node, count(f.start_node) as cnts from (				 
select distinct fee.start_node, fee.end_node, cost from public.manhattan_catchment_nodes as fee
	WHERE (start_node, end_node) in
	(select node_id, n_id from census_blocks.f_manh_blocks_pop_4326, transport.closest_subway_node))f group by start_node)
	
INSERT INTO poi.mom_counts_2km
(select '13' as poi_type, f.start_node, count(f.start_node) as cnts from (				 
select distinct fee.start_node, fee.end_node, cost from public.manhattan_catchment_nodes as fee
	WHERE (start_node, end_node) in
	(select node_id, n_id from census_blocks.f_manh_blocks_pop_4326, poi.closest_parking_lots_node))f group by start_node)
	
	
/* Altering the tables with the new fields */

ALTER TABLE census_blocks.f_manh_blocks_pop_4326
ADD column hosp_min_dist_m double precision;
UPDATE census_blocks.f_manh_blocks_pop_4326
set hosp_min_dist_m = (SELECT cost from (SELECT poi_type, start_node, cost from poi.mom_minimum_cost WHERE poi_type='1')f 
				   WHERE f.start_node = census_blocks.f_manh_blocks_pop_4326.node_id)

	
ALTER TABLE census_blocks.f_manh_blocks_pop_4326
ADD column n_hospital_2km bigint;
UPDATE census_blocks.f_manh_blocks_pop_4326
SET n_hospital_2km = (SELECT cnts from (SELECT poi_type, start_node, cnts from poi.mom_counts_2km WHERE poi_type='1')f
				 WHERE f.start_node = census_blocks.f_manh_blocks_pop_4326.node_id)	

ALTER TABLE census_blocks.f_manh_blocks_pop_4326
ADD column hcent_min_dist_m double precision;
UPDATE census_blocks.f_manh_blocks_pop_4326
set hcent_min_dist_m = (SELECT cost from (SELECT poi_type, start_node, cost from poi.mom_minimum_cost WHERE poi_type='2')f 
				   WHERE f.start_node = census_blocks.f_manh_blocks_pop_4326.node_id)
				   
ALTER TABLE census_blocks.f_manh_blocks_pop_4326
ADD column n_hcent_2km bigint;
UPDATE census_blocks.f_manh_blocks_pop_4326
SET n_hcent_2km = (SELECT cnts from (SELECT poi_type, start_node, cnts from poi.mom_counts_2km WHERE poi_type='2')f
				 WHERE f.start_node = census_blocks.f_manh_blocks_pop_4326.node_id)
				 
	
ALTER TABLE census_blocks.f_manh_blocks_pop_4326
ADD column govf_min_dist_m double precision;
UPDATE census_blocks.f_manh_blocks_pop_4326
set govf_min_dist_m = (SELECT cost from (SELECT poi_type, start_node, cost from poi.mom_minimum_cost WHERE poi_type='3')f 
				   WHERE f.start_node = census_blocks.f_manh_blocks_pop_4326.node_id)
				   
ALTER TABLE census_blocks.f_manh_blocks_pop_4326
ADD column n_govf_2km bigint;
UPDATE census_blocks.f_manh_blocks_pop_4326
SET n_govf_2km = (SELECT cnts from (SELECT poi_type, start_node, cnts from poi.mom_counts_2km WHERE poi_type='3')f
				 WHERE f.start_node = census_blocks.f_manh_blocks_pop_4326.node_id)
				 
				 
ALTER TABLE census_blocks.f_manh_blocks_pop_4326
ADD column emb_min_dist_m double precision;
UPDATE census_blocks.f_manh_blocks_pop_4326
set emb_min_dist_m = (SELECT cost from (SELECT poi_type, start_node, cost from poi.mom_minimum_cost WHERE poi_type='4')f 
				   WHERE f.start_node = census_blocks.f_manh_blocks_pop_4326.node_id)
				   
ALTER TABLE census_blocks.f_manh_blocks_pop_4326
ADD column n_emb_2km bigint;
UPDATE census_blocks.f_manh_blocks_pop_4326
SET n_emb_2km = (SELECT cnts from (SELECT poi_type, start_node, cnts from poi.mom_counts_2km WHERE poi_type='4')f
				 WHERE f.start_node = census_blocks.f_manh_blocks_pop_4326.node_id)
				 
				 
ALTER TABLE census_blocks.f_manh_blocks_pop_4326
ADD column park_min_dist_m double precision;
UPDATE census_blocks.f_manh_blocks_pop_4326
set park_min_dist_m = (SELECT cost from (SELECT poi_type, start_node, cost from poi.mom_minimum_cost WHERE poi_type='5')f 
				   WHERE f.start_node = census_blocks.f_manh_blocks_pop_4326.node_id)
				   
ALTER TABLE census_blocks.f_manh_blocks_pop_4326
ADD column n_park_2km bigint;
UPDATE census_blocks.f_manh_blocks_pop_4326
SET n_park_2km = (SELECT cnts from (SELECT poi_type, start_node, cnts from poi.mom_counts_2km WHERE poi_type='5')f
				 WHERE f.start_node = census_blocks.f_manh_blocks_pop_4326.node_id)
				 
				 
ALTER TABLE census_blocks.f_manh_blocks_pop_4326
ADD column mall_min_dist_m double precision;
UPDATE census_blocks.f_manh_blocks_pop_4326
set mall_min_dist_m = (SELECT cost from (SELECT poi_type, start_node, cost from poi.mom_minimum_cost WHERE poi_type='6')f 
				   WHERE f.start_node = census_blocks.f_manh_blocks_pop_4326.node_id)
				   
ALTER TABLE census_blocks.f_manh_blocks_pop_4326
ADD column n_mall_2km bigint;
UPDATE census_blocks.f_manh_blocks_pop_4326
SET n_mall_2km = (SELECT cnts from (SELECT poi_type, start_node, cnts from poi.mom_counts_2km WHERE poi_type='6')f
				 WHERE f.start_node = census_blocks.f_manh_blocks_pop_4326.node_id)
				 
				 
ALTER TABLE census_blocks.f_manh_blocks_pop_4326
ADD column psaf_min_dist_m double precision;
UPDATE census_blocks.f_manh_blocks_pop_4326
set psaf_min_dist_m = (SELECT cost from (SELECT poi_type, start_node, cost from poi.mom_minimum_cost WHERE poi_type='7')f 
				   WHERE f.start_node = census_blocks.f_manh_blocks_pop_4326.node_id)
				   
ALTER TABLE census_blocks.f_manh_blocks_pop_4326
ADD column n_psaf_2km bigint;
UPDATE census_blocks.f_manh_blocks_pop_4326
SET n_psaf_2km = (SELECT cnts from (SELECT poi_type, start_node, cnts from poi.mom_counts_2km WHERE poi_type='7')f
				 WHERE f.start_node = census_blocks.f_manh_blocks_pop_4326.node_id)
				 
				 
ALTER TABLE census_blocks.f_manh_blocks_pop_4326
ADD column tour_min_dist_m double precision;
UPDATE census_blocks.f_manh_blocks_pop_4326
set tour_min_dist_m = (SELECT cost from (SELECT poi_type, start_node, cost from poi.mom_minimum_cost WHERE poi_type='8')f 
				   WHERE f.start_node = census_blocks.f_manh_blocks_pop_4326.node_id)
				   
ALTER TABLE census_blocks.f_manh_blocks_pop_4326
ADD column n_tour_2km bigint;
UPDATE census_blocks.f_manh_blocks_pop_4326
SET n_tour_2km = (SELECT cnts from (SELECT poi_type, start_node, cnts from poi.mom_counts_2km WHERE poi_type='8')f
				 WHERE f.start_node = census_blocks.f_manh_blocks_pop_4326.node_id)
				 
				 
ALTER TABLE census_blocks.f_manh_blocks_pop_4326
ADD column suni_min_dist_m double precision;
UPDATE census_blocks.f_manh_blocks_pop_4326
set suni_min_dist_m = (SELECT cost from (SELECT poi_type, start_node, cost from poi.mom_minimum_cost WHERE poi_type='9')f 
				   WHERE f.start_node = census_blocks.f_manh_blocks_pop_4326.node_id)
				   
ALTER TABLE census_blocks.f_manh_blocks_pop_4326
ADD column n_suni_2km bigint;
UPDATE census_blocks.f_manh_blocks_pop_4326
SET n_suni_2km = (SELECT cnts from (SELECT poi_type, start_node, cnts from poi.mom_counts_2km WHERE poi_type='9')f
				 WHERE f.start_node = census_blocks.f_manh_blocks_pop_4326.node_id)
				 
				 
ALTER TABLE census_blocks.f_manh_blocks_pop_4326
ADD column grav_min_dist_m double precision;
UPDATE census_blocks.f_manh_blocks_pop_4326
set grav_min_dist_m = (SELECT cost from (SELECT poi_type, start_node, cost from poi.mom_minimum_cost WHERE poi_type='10')f 
				   WHERE f.start_node = census_blocks.f_manh_blocks_pop_4326.node_id)
				   
ALTER TABLE census_blocks.f_manh_blocks_pop_4326
ADD column n_grav_2km bigint;
UPDATE census_blocks.f_manh_blocks_pop_4326
SET n_grav_2km = (SELECT cnts from (SELECT poi_type, start_node, cnts from poi.mom_counts_2km WHERE poi_type='10')f
				 WHERE f.start_node = census_blocks.f_manh_blocks_pop_4326.node_id)
				 
				 
ALTER TABLE census_blocks.f_manh_blocks_pop_4326
ADD column bus_min_dist_m double precision;
UPDATE census_blocks.f_manh_blocks_pop_4326
set bus_min_dist_m = (SELECT cost from (SELECT poi_type, start_node, cost from poi.mom_minimum_cost WHERE poi_type='11')f 
				   WHERE f.start_node = census_blocks.f_manh_blocks_pop_4326.node_id)
				   
ALTER TABLE census_blocks.f_manh_blocks_pop_4326
ADD column n_bus_2km bigint;
UPDATE census_blocks.f_manh_blocks_pop_4326
SET n_bus_2km = (SELECT cnts from (SELECT poi_type, start_node, cnts from poi.mom_counts_2km WHERE poi_type='11')f
				 WHERE f.start_node = census_blocks.f_manh_blocks_pop_4326.node_id)
				 
				 
ALTER TABLE census_blocks.f_manh_blocks_pop_4326
ADD column sub_min_dist_m double precision;
UPDATE census_blocks.f_manh_blocks_pop_4326
set sub_min_dist_m = (SELECT cost from (SELECT poi_type, start_node, cost from poi.mom_minimum_cost WHERE poi_type='12')f 
				   WHERE f.start_node = census_blocks.f_manh_blocks_pop_4326.node_id)
				   
ALTER TABLE census_blocks.f_manh_blocks_pop_4326
ADD column n_sub_2km bigint;
UPDATE census_blocks.f_manh_blocks_pop_4326
SET n_sub_2km = (SELECT cnts from (SELECT poi_type, start_node, cnts from poi.mom_counts_2km WHERE poi_type='12')f
				 WHERE f.start_node = census_blocks.f_manh_blocks_pop_4326.node_id)
				 
				 
ALTER TABLE census_blocks.f_manh_blocks_pop_4326
ADD column plot_min_dist_m double precision;
UPDATE census_blocks.f_manh_blocks_pop_4326
set plot_min_dist_m = (SELECT cost from (SELECT poi_type, start_node, cost from poi.mom_minimum_cost WHERE poi_type='13')f 
				   WHERE f.start_node = census_blocks.f_manh_blocks_pop_4326.node_id)
				   
ALTER TABLE census_blocks.f_manh_blocks_pop_4326
ADD column n_plot_2km bigint;
UPDATE census_blocks.f_manh_blocks_pop_4326
SET n_plot_2km = (SELECT cnts from (SELECT poi_type, start_node, cnts from poi.mom_counts_2km WHERE poi_type='13')f
				 WHERE f.start_node = census_blocks.f_manh_blocks_pop_4326.node_id)
				  