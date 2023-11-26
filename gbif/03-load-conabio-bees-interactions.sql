-- foreign key checking deferred due to circular dependencies
BEGIN;
SET CONSTRAINTS ALL DEFERRED;

-- Populate the database with the data CONABIO mapped to the publishing model for biotic interactions.
-- psql requires the following meta commands to be presented on a single line
\copy public.event FROM '../conabio-bees/publishing-model-data/event.csv' WITH DELIMITER ',' CSV HEADER;
\copy public.material_entity FROM '../conabio-bees/publishing-model-data/material_entity.csv' WITH DELIMITER ',' CSV HEADER;
\copy public.organism FROM '../conabio-bees/publishing-model-data/organism.csv' WITH DELIMITER ',' CSV HEADER;
\copy public.organism_assertion FROM '../conabio-bees/publishing-model-data/organism_assertion.csv' WITH DELIMITER ',' CSV HEADER;
\copy public.organism_interaction FROM '../conabio-bees/publishing-model-data/organism_interaction.csv' WITH DELIMITER ',' CSV HEADER;
COMMIT;