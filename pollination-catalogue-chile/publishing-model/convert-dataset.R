library(dplyr)
library(sp)
library(tidyverse)
library(snakecase)

data <- read.csv('../original-data/pollination_catalogue.csv', sep = ';', header = T, stringsAsFactors = F)
summary(data)
head(data)

# Create location.tsv
# location_cols <- c('location_id',
#                    'parent_location_id',
#                    'higher_geography_id',
#                    'higher_geography',
#                    'continent',
#                    'water_body',
#                    'island_group',
#                    'island',
#                    'country',
#                    'country_code',
#                    'state_province',
#                    'county',
#                    'municipality',
#                    'locality',
#                    'minimum_elevation_in_meters',
#                    'maximum_elevation_in_meters',
#                    'minimum_distance_above_surface_in_meters',
#                    'maximum_distance_above_surface_in_meters',
#                    'minimum_depth_in_meters',
#                    'maximum_depth_in_meters',
#                    'vertical_datum',
#                    'location_according_to',
#                    'location_remarks',
#                    'decimal_latitude',
#                    'decimal_longitude',
#                    'geodetic_datum',
#                    'coordinate_uncertainty_in_meters',
#                    'coordinate_precision',
#                    'point_radius_spatial_fit',
#                    'footprint_wkt',
#                    'footprint_srs',
#                    'footprint_spatial_fit',
#                    'georeferenced_by',
#                    'georeferenced_date',
#                    'georeference_protocol',
#                    'georeference_sources',
#                    'georeference_remarks',
#                    'preferred_spatial_representation')
# location <- data
# names(location) <- to_snake_case(names(location), sep_out = '_')
# names(location)
# location[,location_cols[which(!(location_cols %in% names(location)))]] <- NA
# location <- location %>%
#   dplyr::distinct(decimal_latitude, decimal_longitude, .keep_all=T) %>%
#   mutate(location_id=stringr::str_c('loc_', row_number())) %>%
#   select(location_id,
#          parent_location_id,
#          higher_geography_id,
#          higher_geography,
#          continent,
#          water_body,
#          island_group,
#          island,
#          country,
#          country_code,
#          state_province,
#          county,
#          municipality,
#          locality,
#          minimum_elevation_in_meters,
#          maximum_elevation_in_meters,
#          minimum_distance_above_surface_in_meters,
#          maximum_distance_above_surface_in_meters,
#          minimum_depth_in_meters,
#          maximum_depth_in_meters,
#          vertical_datum,
#          location_according_to,
#          location_remarks,
#          decimal_latitude,
#          decimal_longitude,
#          geodetic_datum,
#          coordinate_uncertainty_in_meters,
#          coordinate_precision,
#          point_radius_spatial_fit,
#          footprint_wkt,
#          footprint_srs,
#          footprint_spatial_fit,
#          georeferenced_by,
#          georeferenced_date,
#          georeference_protocol,
#          georeference_sources,
#          georeference_remarks,
#          preferred_spatial_representation)
# 
# dim(location)
# location$country_code <- 'CH'
# write.table(location, file = 'location.tsv', sep = '\t', row.names = F, col.names = T,na="")

# OrganismInteraction.tsv

interactions_cols <- c('eventId',
                       'subjectOrganismId',
                       'interactionType',
                       'interactionTypeId',
                       'objectOrganismId')
interactions <- data  
interactions[,interactions_cols] <- NA
interactions <- interactions %>%
  mutate(eventId=stringr::str_c('evt_', row_number()), 
         subjectOrganismId=stringr::str_c('sub_', row_number()), 
         interactionType=interactionType,
         interactionTypeId=interactionTypeIRI, 
         objectOrganismId=stringr::str_c('obj_', row_number())) %>%
  select(interactions_cols)
head(interactions)

write.table(interactions, file = 'organism-interaction.tsv', sep = '\t', row.names = F, col.names = T,na="")


# Event.tsv
event_cols <- c('eventId',
                'parentEventId',
                'datasetId',
                'locationId',
                'protocolId',
                'eventType',
                'eventName',
                'recordedBy',
                'recordedById',
                'fieldNumber',
                'eventDate',
                'year',
                'month',
                'day',
                'verbatimEventDate',
                'verbatimLocality',
                'verbatimElevation',
                'verbatimDepth',
                'verbatimCoordinates',
                'verbatimLatitude',
                'verbatimLongitude',
                'verbatimCoordinateSystem',
                'verbatimSrs',
                'habitat',
                'protocolDescription',
                'sampleSizeValue',
                'sampleSizeUnit',
                'eventEffort',
                'fieldNotes',
                'eventCitation',
                'eventRemarks',
                'higherGeographyId',
                'higherGeography',
                'continent',
                'waterBody',
                'islandGroup',
                'island',
                'country',
                'countryCode',
                'stateProvince',
                'county',
                'municipality',
                'locality',
                'minimumElevationInMeters',
                'maximumElevationInMeters',
                'minimumDistanceAboveSurfaceInMeters',
                'maximumDistanceAboveSurfaceInMeters',
                'minimumDepthInMeters',
                'maximumDepthInMeters',
                'verticalDatum',
                'locationAccordingTo',
                'locationRemarks',
                'decimalLatitude',
                'decimalLongitude',
                'geodeticDatum',
                'coordinateUncertaintyInMeters',
                'coordinatePrecision',
                'pointRadiusSpatialFit',
                'footprintWkt',
                'footprintSrs',
                'footprintSpatialFit',
                'georeferencedBy',
                'georeferencedDate',
                'georeferenceProtocol',
                'georeferenceSources',
                'georeferenceRemarks',
                'preferredSpatialRepresentation')
events <- data

events[,event_cols[!(event_cols %in% names(events))]] <- NA
events <- events %>% 
  mutate(eventId=stringr::str_c('evt_', row_number()), 
         eventDate = eventDate,
         samplingSizeUnit = samplingSizeUnit,
         samplingSizeProtocol = samplingProtocol,
         samplingSizeValue = sampleSizeValue,
         eventType='ORGANISM_INTERACTION',
         locality=verbatimSite,
         verbatimLocality=verbatimSite, 
         verbatimLatitude=decimalLatitude,
         verbatimLongitude=decimalLongitude) %>%
  select(event_cols)

head(events)
write.table(events, file = 'event.tsv', sep = '\t', row.names = F, col.names = T,na="")

# Organism.tsv
organism_cols <- c('organismId',
                   'organismScope',
                   'organismName',
                   'organismRemarks',
                   'verbatimIdentification',
                   'scientificName',
                   'kingdom',
                   'taxonRank')
organism <- data %>%
  select(scientificNamePlants, taxonRankPlants) %>%
  rename(scientificName=scientificNamePlants, taxonRank=taxonRankPlants) %>%
  mutate(kingdom='Plantae', organismScope='invidivual') %>%
  bind_rows(data %>%
              select(scientificNameAnimals, taxonRemarksAnimals) %>%
              rename(scientificName=scientificNameAnimals, taxonRank=taxonRemarksAnimals) %>%
              mutate(kingdom='Animalia', organismScope='invidivual'))
organism[,organism_cols[!(organism_cols %in% names(organism))]] <- NA
organism$organismId <- c(interactions$subjectOrganismId, interactions$objectOrganismId)
organism$verbatimIdentification <- organism$scientificName
head(organism)

organism  <- organism %>%
  distinct(organismId, .keep_all = T) %>%
  select(organism_cols)
head(organism)
write.table(organism, file = 'organism.tsv', sep = '\t', row.names = F, col.names = T,na="")

# Assertion.tsv
assertion_cols <- c('assertionTargetId',
                    'assertionTargetType',
                    'assertionType',
                    'assertionValue',
                    'assertionValueNumeric',
                    'assertionUnit',
                    'assertionMadeDate',
                    'assertionEffectiveDate',
                    'assertionByAgentName',
                    'assertionByAgentId',
                    'assertionProtocol',
                    'assertionProtocolId',
                    'assertionCitation',
                    'assertionRemarks')

assertions_plants <- data %>%
  select(organismQuantityPlants, establishmentMeansPlants, habitPlants, selfIncompatabilityPlants) %>%
  mutate(across(everything(), as.character)) %>%
  rename_with(~ stringr::str_remove(. ,"Plants")) %>%
  mutate(assertionTargetType='ORGANISM')
head(assertions_plants)

assertions_animals <- data %>%
  select(organismQuantityAnimals) %>%
  mutate(across(everything(), as.character)) %>%
  rename_with(~ stringr::str_remove(. ,"Animals")) %>%
  mutate(assertionTargetType='ORGANISM')
head(assertions_animals)

assertions_events <- data %>%
  select(resourceCollected) %>%
  mutate(across(everything(), as.character)) %>%
  mutate(assertioTargetType='EVENT')
head(assertions_events)

assertions_plants$assertionTargetId <- interactions$subjectOrganismId
assertions_animals$assertionTargetId <- interactions$objectOrganismId
assertions_events$assertionTargetId <-interactions$eventId

assertions <- assertions_plants %>%
  distinct(assertionTargetId, .keep_all = T) %>%
  pivot_longer(cols=c(organismQuantity, establishmentMeans, habit, selfIncompatability), names_to='assertionType', values_to='assertionValue') %>%
  bind_rows(assertions_animals %>%
              distinct(assertionTargetId, .keep_all = T) %>%
              pivot_longer(cols=c(organismQuantity), names_to='assertionType', values_to='assertionValue')) %>%
  bind_rows(assertions_events %>%
              distinct(assertionTargetId, .keep_all = T) %>%
              pivot_longer(cols=c(resourceCollected), names_to='assertionType', values_to='assertionValue'))
head(assertions)

assertions <- assertions %>%
  mutate(assertionValueNumeric=assertionValue) 
assertions$assertionValueNumeric[sapply(assertions$assertionValueNumeric, function(x) { is.na(as.numeric(x))})] <- ""
assertions$assertionValue[sapply(assertions$assertionValue, function(x) { !is.na(as.numeric(x))})] <- ""


assertions[,assertion_cols[which(!(assertion_cols %in% names(assertions)))]] <- NA
assertions <- assertions %>% select(assertion_cols)
head(assertions)
write.table(assertions, 'assertion.tsv', sep='\t', row.names = F, col.names = T,na="")


