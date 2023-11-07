BEGIN;
-- foreign key checking deferred due to circular dependencies
SET CONSTRAINTS ALL DEFERRED;

-- Populate the database with the data CONABIO mapped to the Unified Model v4.5 to use as
-- the basis of mapping it to a publishing model for biotic interactions.
-- psql requires the following meta commands to be presented on a single line
\copy public.agent FROM '../conabio-bees/original-data/data-products/agent.csv' WITH DELIMITER ',' CSV HEADER;
\copy public.collection FROM '../conabio-bees/original-data/data-products/collection.csv' WITH DELIMITER ',' CSV HEADER;
\copy public.entity_relationship FROM '../conabio-bees/original-data/data-products/entity_relationship.csv' WITH DELIMITER ',' CSV HEADER;
\copy public.entity FROM '../conabio-bees/original-data/data-products/entity.csv' WITH DELIMITER ',' CSV HEADER;
\copy public.event FROM '../conabio-bees/original-data/data-products/event.csv' WITH DELIMITER ',' CSV HEADER;
\copy public.georeference FROM '../conabio-bees/original-data/data-products/georeference.csv' WITH DELIMITER ',' CSV HEADER;
\copy public.identification FROM '../conabio-bees/original-data/data-products/identification.csv' WITH DELIMITER ',' CSV HEADER;
\copy public.location FROM '../conabio-bees/original-data/data-products/location.csv' WITH DELIMITER ',' CSV HEADER;
\copy public.material_entity FROM '../conabio-bees/original-data/data-products/material_entity.csv' WITH DELIMITER ',' CSV HEADER;
\copy public.occurrence_evidence FROM '../conabio-bees/original-data/data-products/occurrence_evidence.csv' WITH DELIMITER ',' CSV HEADER;
\copy public.occurrence FROM '../conabio-bees/original-data/data-products/occurrence.csv' WITH DELIMITER ',' CSV HEADER;
\copy public.organism FROM '../conabio-bees/original-data/data-products/organism.csv' WITH DELIMITER ',' CSV HEADER;
\copy public.taxon_identification FROM '../conabio-bees/original-data/data-products/taxon_identification.csv' WITH DELIMITER ',' CSV HEADER;
\copy public.taxon FROM '../conabio-bees/original-data/data-products/taxon.csv' WITH DELIMITER ',' CSV HEADER;
COMMIT;