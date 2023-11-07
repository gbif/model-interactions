-- foreign key checking deferred due to circular dependencies
BEGIN;
DROP TABLE bi_pub_location;
DROP TABLE bi_pub_assertion;
DROP TABLE bi_pub_organism_interaction;
DROP TABLE bi_pub_event;
DROP TABLE bi_pub_organism;
DROP TABLE bi_pub_material_entity;

-- Create the bi_pub_location table
SELECT
location.location_id,
parent_location_id,
higher_geography_id,
higher_geography,
continent,
water_body,
island_group,
island,
country,
country_code,
state_province,
county,
municipality,
locality,
minimum_elevation_in_meters,
maximum_elevation_in_meters,
minimum_distance_above_surface_in_meters,
maximum_distance_above_surface_in_meters,
minimum_depth_in_meters,
maximum_depth_in_meters,
vertical_datum,
location_according_to,
location_remarks,
decimal_latitude,
decimal_longitude,
geodetic_datum,
coordinate_uncertainty_in_meters,
coordinate_precision,
point_radius_spatial_fit,
footprint_wkt,
footprint_srs,
footprint_spatial_fit,
georeferenced_by,
georeferenced_date,
georeference_protocol,
georeference_sources,
georeference_remarks,
preferred_spatial_representation
INTO TABLE bi_pub_location
FROM
location LEFT OUTER JOIN georeference on location.location_id = georeference.location_id;

-- Export the bi_pub_location table
COPY
(
SELECT *
FROM bi_pub_location
)
TO '/Users/johnwieczorek/Projects/model-interactions/conabio-bees/publishing-model-data/location.csv' 
WITH CSV 
DELIMITER ',' 
HEADER;

-- Create the bi_pub_assertion table with the first assertion_type
SELECT 
organism_id AS assertion_target_id,
'ORGANISM' AS assertion_target_type,
'sex' AS assertion_type,
sex AS assertion_value,
NULL AS assertion_value_numeric,
NULL AS assertion_unit,
NULL AS assertion_made_date,
event_date AS assertion_effective_date,
NULL AS assertion_by_agent_name,
NULL AS assertion_by_agent_id,
NULL AS assertion_protocol,
NULL AS assertion_protocol_id,
NULL AS assertion_citation,
NULL AS assertion_remarks
INTO TABLE bi_pub_assertion
FROM
occurrence,
event
WHERE
occurrence_id=event_id;

-- Append to the bi_pub_assertion table with the next assertion_type
INSERT INTO bi_pub_assertion (assertion_target_id, assertion_target_type, assertion_type, assertion_value, assertion_value_numeric, assertion_unit, assertion_made_date, assertion_effective_date, assertion_by_agent_name, assertion_by_agent_id, assertion_protocol, assertion_protocol_id, assertion_citation, assertion_remarks)
SELECT 
organism_id AS assertion_target_id,
'ORGANISM' AS assertion_target_type,
'organism_quantity' AS assertion_type,
NULL AS assertion_value,
organism_quantity AS assertion_value_numeric,
organism_quantity_type AS assertion_unit,
event_date AS assertion_made_date,
event_date AS assertion_effective_date,
NULL AS assertion_by_agent_name,
NULL AS assertion_by_agent_id,
NULL AS assertion_protocol,
NULL AS assertion_protocol_id,
NULL AS assertion_citation,
NULL AS assertion_remarks
FROM
occurrence,
event
WHERE
occurrence_id=event_id;

-- Export the bi_pub_assertion table
COPY
(
SELECT *
FROM bi_pub_assertion
)
TO '/Users/johnwieczorek/Projects/model-interactions/conabio-bees/publishing-model-data/assertion.csv' 
WITH CSV 
DELIMITER ',' 
HEADER;

-- Create the bi_pub_organism_interaction table
SELECT
occurrence_id AS event_id,
subject_entity_id AS subject_organism_id,
entity_relationship_type AS interaction_type,
'http://purl.obolibrary.org/obo/RO_0002622' AS interaction_type_id,
object_entity_id AS object_organism_id
INTO TABLE bi_pub_organism_interaction
FROM
entity_relationship,
occurrence
WHERE 
entity_relationship.subject_entity_id=occurrence.organism_id;

-- Export the bi_pub_assertion table
COPY
(
SELECT *
FROM bi_pub_organism_interaction
)
TO '/Users/johnwieczorek/Projects/model-interactions/conabio-bees/publishing-model-data/organism_interaction.csv' 
WITH CSV 
DELIMITER ',' 
HEADER;

-- Create the bi_pub_event table
SELECT
event.event_id,
parent_event_id,
dataset_id,
location_id,
protocol_id,
'ORGANISM_INTERACTION' AS event_type,
event_name,
recorded_by,
recorded_by_id,
field_number,
event_date,
year,
month,
day,
verbatim_event_date,
verbatim_locality,
verbatim_elevation,
verbatim_depth,
verbatim_coordinates,
verbatim_latitude,
verbatim_longitude,
verbatim_coordinate_system,
verbatim_srs,
habitat,
protocol_description,
sample_size_value,
sample_size_unit,
event_effort,
field_notes,
NULL AS event_citation,
event_remarks
INTO TABLE bi_pub_event
FROM
event,
occurrence,
bi_pub_organism_interaction
WHERE
event.event_id=bi_pub_organism_interaction.event_id AND
event.event_id=occurrence_id;

-- Export the bi_pub_event table
COPY
(
SELECT *
FROM bi_pub_event
)
TO '/Users/johnwieczorek/Projects/model-interactions/conabio-bees/publishing-model-data/event.csv' 
WITH CSV 
DELIMITER ',' 
HEADER;

-- Create the bi_pub_organism table
SELECT 
organism.organism_id,
'individual' AS organism_scope,
NULL AS organism_name,
NULL AS organism_remarks,
scientific_name AS verbatim_identification,
scientific_name,
kingdom,
taxon_rank
INTO TABLE bi_pub_organism
FROM
organism,
taxon_identification,
taxon
WHERE
organism.accepted_identification_id=taxon_identification.identification_id AND
taxon_identification.taxon_id=taxon.taxon_id;

-- Export the bi_pub_organism table
COPY
(
SELECT *
FROM bi_pub_organism
)
TO '/Users/johnwieczorek/Projects/model-interactions/conabio-bees/publishing-model-data/organism.csv' 
WITH CSV 
DELIMITER ',' 
HEADER;

-- Create the bi_pub_material_entity table
SELECT
material_entity_id,
material_entity_type,
preparations,
disposition,
institution_code,
institution_id,
collection_code,
collection_id,
owner_institution_code,
catalog_number,
record_number,
recorded_by AS collected_by,
recorded_by_id AS collected_by_id,
associated_references,
associated_sequences,
other_catalog_numbers,
NULL AS material_citation,
NULL AS material_entity_remarks
INTO TABLE bi_pub_material_entity
FROM material_entity;

-- Export the bi_pub_material_entity table
COPY
(
SELECT *
FROM bi_pub_material_entity
)
TO '/Users/johnwieczorek/Projects/model-interactions/conabio-bees/publishing-model-data/material_entity.csv' 
WITH CSV 
DELIMITER ',' 
HEADER;

COMMIT;