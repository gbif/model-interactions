---
-- Schema for the biotic interactions data publishing exploration.
-- 
--  To aid readability, this file is structured as:
-- 
--   COMMON TARGETS ENUM
--   Material Entity
--   Organism (MaterialEntity subtype) table
--   Event table
--   Organism Interaction table (Event subtype, subjects and objects indicate Occurrences)
--   Digital Entity
--   Genetic Sequence
--   Assertions
---

-- Target types for the common tables (Assertion, Identifier etc)
CREATE TYPE COMMON_TARGETS AS ENUM (
  'ASSERTION',
  'DIGITAL_MEDIA',
  'EVENT',
  'GENETIC_SEQUENCE',
  'LOCATION',
  'MATERIAL_ENTITY',
  'ORGANISM',
  'ORGANISM_INTERACTION'
);

-- MaterialEntity (https://dwc.tdwg.org/terms/#materialentity)
--   A subtype of Entity
--   An entity that can be identified, exists for some period of time, and consists in 
--   whole or in part of physical matter while it exists.

CREATE TABLE material_entity (
  material_entity_id TEXT PRIMARY KEY,
  material_entity_type TEXT NOT NULL,
  source_material_entity_id TEXT,
  source_digital_media_id TEXT,
  gathering_event_id TEXT,
  preparations TEXT,
  disposition TEXT,
  institution_code TEXT,
  institution_id TEXT, 
  collection_code TEXT,
  collection_id TEXT,
  owner_institution_code TEXT,
  catalog_number TEXT,
  record_number TEXT,
  collected_by TEXT,
  collected_by_id TEXT,
  associated_references TEXT,
  associated_sequences TEXT,
  other_catalog_numbers TEXT,
  material_entity_remarks TEXT
);
CREATE INDEX ON material_entity(source_material_entity_id);
CREATE INDEX ON material_entity(source_digital_media_id);
CREATE INDEX ON material_entity(gathering_event_id);
CREATE INDEX ON material_entity(material_entity_type);


-- Organism (https://dwc.tdwg.org/terms/#organism)
--   A subtype of MaterialEntity
--     However, in the publishing model it is not necessary to create a MaterialEntity 
--     parent of an Organism if not material was collected.
--   A particular organism or defined group of organisms considered to be taxonomically 
--   homogeneous.

CREATE TABLE organism (
  organism_id TEXT PRIMARY KEY,
  organism_scope TEXT,
  organism_name TEXT,
  organism_remarks TEXT,
  verbatim_identification TEXT,
  scientific_name TEXT,
  kingdom TEXT,
  taxon_rank TEXT
);


---
-- Event and support tables
--
-- Each Event subtype has a foreign key to its immediate parent type, enforcing the
-- following inheritance model:
--
--   Event
--     OrganismInteraction
---

-- Event (https://dwc.tdwg.org/terms/#event)
--   Something that happened at a place and time
--   Zero or one parent Event per Event
--   Zero or one Location per Event

CREATE TABLE event (
  event_id TEXT PRIMARY KEY,
  parent_event_id TEXT REFERENCES event ON DELETE CASCADE DEFERRABLE,
  dataset_id TEXT NOT NULL,
  location_id TEXT,
  protocol_id TEXT,
  event_type TEXT NOT NULL,
  event_name TEXT,
  recorded_by TEXT,
  recorded_by_id TEXT,
  field_number TEXT,
  event_date TEXT,
  event_time TEXT,
  year SMALLINT,
  month SMALLINT CHECK (month BETWEEN 1 AND 12),
  day SMALLINT CHECK (day BETWEEN 1 and 31), 
  verbatim_event_date TEXT,
  habitat TEXT,
  protocol_description TEXT,
  sample_size_value TEXT,
  sample_size_unit TEXT,
  event_effort TEXT,
  field_notes TEXT,
  event_citation TEXT,
  event_remarks TEXT,
  higher_geography_id TEXT,
  higher_geography TEXT,
  continent TEXT,
  water_body TEXT,
  island_group TEXT,
  island TEXT,
  country TEXT,
  country_code CHAR(2),
  state_province TEXT,
  county TEXT,
  municipality TEXT,
  locality TEXT,
  verbatim_locality TEXT,
  minimum_elevation_in_meters NUMERIC CHECK (minimum_elevation_in_meters BETWEEN -430 AND 8850),
  maximum_elevation_in_meters NUMERIC CHECK (maximum_elevation_in_meters BETWEEN -430 AND 8850),
  verbatim_elevation TEXT,
  minimum_distance_above_surface_in_meters NUMERIC,
  maximum_distance_above_surface_in_meters NUMERIC,
  minimum_depth_in_meters NUMERIC CHECK (minimum_depth_in_meters BETWEEN 0 AND 11000),
  maximum_depth_in_meters NUMERIC CHECK (maximum_depth_in_meters BETWEEN 0 AND 11000),
  verbatim_depth TEXT,
  vertical_datum TEXT,
  location_according_to TEXT,
  location_remarks TEXT,
  decimal_latitude NUMERIC NOT NULL CHECK (decimal_latitude BETWEEN -90 AND 90),
  decimal_longitude NUMERIC NOT NULL CHECK (decimal_longitude BETWEEN -180 AND 180),
  geodetic_datum TEXT NOT NULL,
  coordinate_uncertainty_in_meters NUMERIC CHECK (coordinate_uncertainty_in_meters > 0 AND coordinate_uncertainty_in_meters <= 20037509),
  coordinate_precision NUMERIC CHECK (coordinate_precision BETWEEN 0 AND 90),
  point_radius_spatial_fit NUMERIC CHECK (point_radius_spatial_fit = 0 OR point_radius_spatial_fit >= 1),
  verbatim_coordinates TEXT,
  verbatim_latitude TEXT,
  verbatim_longitude TEXT,
  verbatim_coordinate_system TEXT,
  verbatim_srs TEXT,
  footprint_wkt TEXT,
  footprint_srs TEXT,
  footprint_spatial_fit NUMERIC CHECK (footprint_spatial_fit >= 0),
  georeferenced_by TEXT,
  georeferenced_date TEXT,
  georeference_protocol TEXT,
  georeference_sources TEXT,
  georeference_remarks TEXT,
  preferred_spatial_representation TEXT
);
CREATE INDEX ON event(parent_event_id);


-- OrganismInteraction 
--   (subject Organism interaction with object Organism,
--   interaction from the perspective of subject to object)
--   A subtype of Event
--   An Event in which an interaction between two Organisms at a place and time are observed.
--   One subject Organism per OrganismInteraction
--   One object Organism per OrganismInteraction

CREATE TABLE organism_interaction (
  event_id TEXT PRIMARY KEY REFERENCES event ON DELETE CASCADE DEFERRABLE,
  subject_organism_id TEXT REFERENCES organism ON DELETE CASCADE DEFERRABLE,
  interaction_type TEXT,
  interaction_type_id TEXT,
  object_organism_id TEXT REFERENCES organism ON DELETE CASCADE DEFERRABLE
);
CREATE INDEX ON organism_interaction(event_id);
CREATE INDEX ON organism_interaction(subject_organism_id);
CREATE INDEX ON organism_interaction(object_organism_id);
CREATE INDEX ON organism_interaction(interaction_type);


CREATE TYPE DIGITAL_MEDIA_TYPE AS ENUM (
  'DATASET',
  'INTERACTIVE_RESOURCE',
  'MOVING_IMAGE',
  'SERVICE',
  'SOFTWARE',
  'SOUND',
  'STILL_IMAGE',
  'TEXT',
  'GENETIC_SEQUENCE'
);

-- DigitalMedia
--   A subtype of Entity
--   An Entity that is digital in nature.

CREATE TABLE digital_media (
  digital_media_id TEXT PRIMARY KEY,
  digital_media_type DIGITAL_MEDIA_TYPE NOT NULL,
  event_id TEXT,
  access_uri TEXT NOT NULL,
  web_statement TEXT,
  format TEXT,
  license TEXT,
  rights TEXT,
  rights_uri TEXT,
  access_rights TEXT,
  owner TEXT,
  source TEXT,
  source_uri TEXT,
  creator TEXT,
  created TIMESTAMPTZ,
  modified TIMESTAMPTZ,
  language TEXT,
  bibliographic_citation TEXT
);
CREATE INDEX ON digital_media(digital_media_type);
CREATE INDEX ON digital_media(event_id);

-- DigitalMedia
--   A subtype of Entity
--   An Entity that is digital in nature.

CREATE TABLE genetic_sequence (
  genetic_sequence_id TEXT PRIMARY KEY,
  source_material_entity_id TEXT REFERENCES material_entity ON DELETE CASCADE DEFERRABLE,
  genetic_sequence_type TEXT,
  genetic_sequence TEXT,
  genetic_sequence_citation TEXT,
  genetic_sequence_reamrks TEXT
);
CREATE INDEX ON genetic_sequence(source_material_entity_id);
CREATE INDEX ON genetic_sequence(genetic_sequence_type);

---
--   Assertions for all relevant content
---

-- Assertion
--    An observation, measurement, or other statement made by an Agent with respect to a 
--    thing. In the Unified model, Assertions can be attached to any other table that has 
--    a primary key. In this publishing model, distinct Assertion tables are added for 
--    each table they can be attached to.

CREATE TABLE digital_media_assertion (
  assertion_id TEXT PRIMARY KEY,
  parent_assertion_id TEXT,
  digital_media_id TEXT NOT NULL,
  assertion_type TEXT NOT NULL,
  assertion_value TEXT,
  assertion_value_numeric NUMERIC,
  assertion_unit TEXT,
  assertion_made_date TEXT,
  assertion_effective_date TEXT,
  assertion_by_agent_name TEXT, 
  assertion_by_agent_id TEXT,
  assertion_protocol TEXT,
  assertion_protocol_id TEXT,
  assertion_citation TEXT,
  assertion_remarks TEXT
);
CREATE INDEX ON digital_media_assertion(digital_media_id);
CREATE INDEX ON digital_media_assertion(assertion_type);

CREATE TABLE event_assertion (
  assertion_id TEXT PRIMARY KEY,
  parent_assertion_id TEXT,
  event_id TEXT NOT NULL,
  assertion_type TEXT NOT NULL,
  assertion_value TEXT,
  assertion_value_numeric NUMERIC,
  assertion_unit TEXT,
  assertion_made_date TEXT,
  assertion_effective_date TEXT,
  assertion_by_agent_name TEXT, 
  assertion_by_agent_id TEXT,
  assertion_protocol TEXT,
  assertion_protocol_id TEXT,
  assertion_citation TEXT,
  assertion_remarks TEXT
);
CREATE INDEX ON event_assertion(event_id);
CREATE INDEX ON event_assertion(assertion_type);

CREATE TABLE genetic_sequence_assertion (
  assertion_id TEXT PRIMARY KEY,
  parent_assertion_id TEXT,
  genetic_sequence_id TEXT NOT NULL,
  assertion_type TEXT NOT NULL,
  assertion_value TEXT,
  assertion_value_numeric NUMERIC,
  assertion_unit TEXT,
  assertion_made_date TEXT,
  assertion_effective_date TEXT,
  assertion_by_agent_name TEXT, 
  assertion_by_agent_id TEXT,
  assertion_protocol TEXT,
  assertion_protocol_id TEXT,
  assertion_citation TEXT,
  assertion_remarks TEXT
);
CREATE INDEX ON genetic_sequence_assertion(genetic_sequence_id);
CREATE INDEX ON genetic_sequence_assertion(assertion_type);

CREATE TABLE material_entity_assertion (
  assertion_id TEXT PRIMARY KEY,
  parent_assertion_id TEXT,
  material_entity_id TEXT NOT NULL,
  assertion_type TEXT NOT NULL,
  assertion_value TEXT,
  assertion_value_numeric NUMERIC,
  assertion_unit TEXT,
  assertion_made_date TEXT,
  assertion_effective_date TEXT,
  assertion_by_agent_name TEXT, 
  assertion_by_agent_id TEXT,
  assertion_protocol TEXT,
  assertion_protocol_id TEXT,
  assertion_citation TEXT,
  assertion_remarks TEXT
);
CREATE INDEX ON material_entity_assertion(material_entity_id);
CREATE INDEX ON material_entity_assertion(assertion_type);

CREATE TABLE organism_assertion (
  assertion_id TEXT PRIMARY KEY,
  parent_assertion_id TEXT,
  organism_id TEXT NOT NULL,
  assertion_type TEXT NOT NULL,
  assertion_value TEXT,
  assertion_value_numeric NUMERIC,
  assertion_unit TEXT,
  assertion_made_date TEXT,
  assertion_effective_date TEXT,
  assertion_by_agent_name TEXT, 
  assertion_by_agent_id TEXT,
  assertion_protocol TEXT,
  assertion_protocol_id TEXT,
  assertion_citation TEXT,
  assertion_remarks TEXT
);
CREATE INDEX ON organism_assertion(organism_id);
CREATE INDEX ON organism_assertion(assertion_type);

CREATE TABLE organism_interaction_assertion (
  assertion_id TEXT PRIMARY KEY,
  parent_assertion_id TEXT,
  event_id TEXT NOT NULL,
  assertion_type TEXT NOT NULL,
  assertion_value TEXT,
  assertion_value_numeric NUMERIC,
  assertion_unit TEXT,
  assertion_made_date TEXT,
  assertion_effective_date TEXT,
  assertion_by_agent_name TEXT, 
  assertion_by_agent_id TEXT,
  assertion_protocol TEXT,
  assertion_protocol_id TEXT,
  assertion_citation TEXT,
  assertion_remarks TEXT
);
CREATE INDEX ON organism_interaction_assertion(event_id);
CREATE INDEX ON organism_interaction_assertion(assertion_type);
