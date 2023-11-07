---
-- Schema for the biotic interactions data publishing exploration.
-- 
--  To aid readability, this file is structured as:
-- 
--   Material Entity
--   Organism (are MaterialEntities) table
--   Location table
--   Event table
--   Organism Interaction table (Event subtype, subjects and objects indicate Occurrences)
--   Digital Entity
--   Assertions for all relevant content
---


-- MaterialEntity (https://dwc.tdwg.org/terms/#materialentity)
--   A subtype of Entity
--   An entity that can be identified, exists for some period of time, and consists in 
--   whole or in part of physical matter while it exists.

CREATE TABLE material_entity (
  material_entity_id TEXT PRIMARY KEY,
  material_entity_type TEXT NOT NULL,
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
  material_citation TEXT,
  material_entity_remarks TEXT
);


-- Organism (https://dwc.tdwg.org/terms/#organism)
--   A subtype of MaterialEntity
--   A particular organism or defined group of organisms considered to be taxonomically 
--   homogeneous.

CREATE TABLE organism (
  organism_id TEXT PRIMARY KEY REFERENCES material_entity ON DELETE CASCADE DEFERRABLE,
  organism_scope TEXT,
  organism_name TEXT,
  organism_remarks TEXT,
  verbatim_identification TEXT,
  scientific_name TEXT,
  kingdom TEXT,
  taxon_rank TEXT
);


-- Location (https://dwc.tdwg.org/terms/#Location)
--   Information about a place
--   Zero or one parent Location per Location

CREATE TABLE location (
  location_id TEXT PRIMARY KEY,
  parent_location_id TEXT REFERENCES location ON DELETE CASCADE DEFERRABLE,
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
  minimum_elevation_in_meters NUMERIC CHECK (minimum_elevation_in_meters BETWEEN -430 AND 8850),
  maximum_elevation_in_meters NUMERIC CHECK (maximum_elevation_in_meters BETWEEN -430 AND 8850),
  minimum_distance_above_surface_in_meters NUMERIC,
  maximum_distance_above_surface_in_meters NUMERIC,
  minimum_depth_in_meters NUMERIC CHECK (minimum_depth_in_meters BETWEEN 0 AND 11000),
  maximum_depth_in_meters NUMERIC CHECK (maximum_depth_in_meters BETWEEN 0 AND 11000),
  vertical_datum TEXT,
  location_according_to TEXT,
  location_remarks TEXT,
  decimal_latitude NUMERIC NOT NULL CHECK (decimal_latitude BETWEEN -90 AND 90),
  decimal_longitude NUMERIC NOT NULL CHECK (decimal_longitude BETWEEN -180 AND 180),
  geodetic_datum TEXT NOT NULL,
  coordinate_uncertainty_in_meters NUMERIC CHECK (coordinate_uncertainty_in_meters > 0 AND coordinate_uncertainty_in_meters <= 20037509),
  coordinate_precision NUMERIC CHECK (coordinate_precision BETWEEN 0 AND 90),
  point_radius_spatial_fit NUMERIC CHECK (point_radius_spatial_fit = 0 OR point_radius_spatial_fit >= 1),
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
CREATE INDEX ON location(parent_location_id);


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
  location_id TEXT REFERENCES location ON DELETE CASCADE DEFERRABLE,
  protocol_id TEXT,
  event_type TEXT NOT NULL,
  event_name TEXT,
  recorded_by TEXT,
  recorded_by_id TEXT,
  field_number TEXT,
  event_date TEXT,
  year SMALLINT,
  month SMALLINT CHECK (month BETWEEN 1 AND 12),
  day SMALLINT CHECK (day BETWEEN 1 and 31), 
  verbatim_event_date TEXT,
  verbatim_locality TEXT,
  verbatim_elevation TEXT,
  verbatim_depth TEXT,
  verbatim_coordinates TEXT,
  verbatim_latitude TEXT,
  verbatim_longitude TEXT,
  verbatim_coordinate_system TEXT,
  verbatim_srs TEXT,
  habitat TEXT,
  protocol_description TEXT,
  sample_size_value TEXT,
  sample_size_unit TEXT,
  event_effort TEXT,
  field_notes TEXT,
  event_citation TEXT,
  event_remarks TEXT
);
CREATE INDEX ON event(parent_event_id);
CREATE INDEX ON event(location_id);


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
CREATE INDEX ON organism_interaction(subject_organism_id);
CREATE INDEX ON organism_interaction(object_organism_id);


CREATE TYPE DIGITAL_ENTITY_TYPE AS ENUM (
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

-- DigitalEntity
--   A subtype of Entity
--   An Entity that is digital in nature.

CREATE TABLE digital_entity (
  digital_entity_id TEXT,
  digital_entity_type DIGITAL_ENTITY_TYPE NOT NULL,
  access_uri TEXT NOT NULL,
  web_statement TEXT,
  format TEXT,
  license TEXT,
  rights TEXT,
  rights_uri TEXT,
  access_rights TEXT,
  rights_holder TEXT,
  source TEXT,
  source_uri TEXT,
  creator TEXT,
  created TIMESTAMPTZ,
  modified TIMESTAMPTZ,
  language TEXT,
  bibliographic_citation TEXT
);
CREATE INDEX ON digital_entity(digital_entity_type);


-- Target types for the common tables (Assertion, Identifier etc)
CREATE TYPE COMMON_TARGETS AS ENUM (
  'ENTITY',
  'MATERIAL_ENTITY',
  'ORGANISM',
  'DIGITAL_ENTITY',
  'GENETIC_SEQUENCE',
  'EVENT',
  'ORGANISM_INTERACTION',
  'LOCATION',
  'ASSERTION'
);

---
--   Assertions for all relevant content
---

-- Assertion
--    An observation, measurement, or other statement made by an Agent with respect to a 
--    thing.

CREATE TABLE "assertion" (
  assertion_target_id TEXT NOT NULL,
  assertion_target_type COMMON_TARGETS NOT NULL,
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
CREATE INDEX ON "assertion"(assertion_target_type, assertion_target_id);
CREATE INDEX ON "assertion"(assertion_target_type);
