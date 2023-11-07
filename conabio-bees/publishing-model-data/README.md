# CONABIO Bees data set for the biotic interactions publishing model

Original data are shared in https://github.com/gbif/model-material/tree/master/conabio-bees/original-data.

A original data set restructured for the Unified Model version 4.5 is shared in https://github.com/gbif/model-material/tree/master/conabio-bees/data-products. A copy of that was made into ../original-data/data-products.

The latter is the direct source for the data create a version of the data set to populate the biotic interactions publishing model. The process to create the data set for the publishing model follows:

## Create a postgreSQL database for the restructured Unified Model data:
```cd model-interactions/gbif```

(First time) ```createdb gum_material && psql gum_material -f schema_gum_material.sql```

(Subsequent times) ```dropdb gum_material && createdb gum_material && psql gum_material -f schema_gum_material.sql```

## Load the restructured Unified Model data into the gum_material database:
```psql gum_material -f 01-load-conabio-bees-material.sql```

## Run the script to produce the biotic interactions publishing model tables within the same database and export them as CSV files:
```psql gum_material -f 02-create-conabio-bees-interactions.sql```

## Create a postgreSQL database for the restructured Unified Model data:

(First time) ```createdb pub_bi && psql pub_bi -f schema_publishing_bi.sql```

(Subsequent times) ```dropdb pub_bi && createdb pub_bi && psql pub_bi -f schema_publishing_bi.sql```

## Load the biotic interactions publishing model data into the pub_bi database:
```psql pub_bi -f 03-load-conabio-bees-interactions.sql```

