library(dplyr)
library(sp)
library(tidyverse)


data <- read.csv('Predator_and_prey_body_sizes_in_marine_food_webs_vsn4.tsv', sep = '\t', header = T, stringsAsFactors = F, fileEncoding='ISO-8859-1')
summary(data)
head(data)

# Create location.tsv
location_cols <- c('location_id',
                   'parent_location_id',
                   'higher_geography_id',
                   'higher_geography',
                   'continent',
                   'water_body',
                   'island_group',
                   'island',
                   'country',
                   'country_code',
                   'state_province',
                   'county',
                   'municipality',
                   'locality',
                   'minimum_elevation_in_meters',
                   'maximum_elevation_in_meters',
                   'minimum_distance_above_surface_in_meters',
                   'maximum_distance_above_surface_in_meters',
                   'minimum_depth_in_meters',
                   'maximum_depth_in_meters',
                   'vertical_datum',
                   'location_according_to',
                   'location_remarks',
                   'decimal_latitude',
                   'decimal_longitude',
                   'geodetic_datum',
                   'coordinate_uncertainty_in_meters',
                   'coordinate_precision',
                   'point_radius_spatial_fit',
                   'footprint_wkt',
                   'footprint_srs',
                   'footprint_spatial_fit',
                   'georeferenced_by',
                   'georeferenced_date',
                   'georeference_protocol',
                   'georeference_sources',
                   'georeference_remarks',
                   'preferred_spatial_representation')
location <- data
location[,location_cols] <- NA
location <- location %>%
  dplyr::distinct(Geographic.location, Latitude, Longitude, Depth, .keep_all=T) %>%
  mutate(location_id=stringr::str_c('loc_', row_number())) %>%
  select(location_id,
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
         preferred_spatial_representation, Geographic.location, Latitude, Longitude, Depth) %>%
  mutate(locality=Geographic.location, minimum_depth_in_meters=Depth) %>%
  mutate(decimal_latitude=as.numeric.DMS(char2dms(Latitude,chd='º', chm="'")), 
         decimal_longitude=as.numeric.DMS(char2dms(Longitude,chd='º', chm="'"))) %>%
  select(-Geographic.location, -Latitude, -Longitude, -Depth)

dim(location)
write.table(location, file = 'location.tsv', sep = '\t', row.names = F, col.names = T)

# OrganismInteraction.tsv

interactions_cols <- c('event_id', 'subject_organism_id', 'interaction_type', 'interaction_type_id', 'object_organism_id')
interactions <- data  
interactions[,interactions_cols] <- NA
interactions <- interactions %>%
  mutate(event_id=stringr::str_c('evt_', row_number()), 
         subject_organism_id=if_else(Individual.ID!='n/a', Individual.ID, stringr::str_c('sub_', row_number())), 
         interaction_type='preys on', 
         interaction_type_id='http://purl.obolibrary.org/obo/RO_0002439', 
         object_organism_id=stringr::str_c('obj_', row_number())) %>%
  select(interactions_cols)
head(interactions)

write.table(interactions, file = 'organism-interaction.tsv', sep = '\t', row.names = F, col.names = T)
  

# Event.tsv
event_cols <- c('event_id',
                'parent_event_id',
                'dataset_id',
                'location_id',
                'protocol_id',
                'event_type',
                'event_name',
                'recorded_by',
                'recorded_by_id',
                'field_number',
                'event_date',
                'year',
                'month',
                'day',
                'verbatim_event_date',
                'verbatim_locality',
                'verbatim_elevation',
                'verbatim_depth',
                'verbatim_coordinates',
                'verbatim_latitude',
                'verbatim_longitude',
                'verbatim_coordinate_system',
                'verbatim_srs',
                'habitat',
                'protocol_description',
                'sample_size_value',
                'sample_size_unit',
                'event_effort',
                'field_notes',
                'event_citation',
                'event_remarks')
events <- data
events[,event_cols] <- NA
events <- events %>% 
  mutate(event_id=stringr::str_c('evt_', row_number()), habitat=Specific.habitat,
                                 event_type='organism_interaction',
                                 verbatim_locality=Geographic.location, 
                                 verbatim_latitude=Latitude,
                                 verbatim_longitude=Longitude) %>%
  select(-location_id) %>%
  inner_join(location, by = c('verbatim_locality' = 'locality', 'Depth' = 'minimum_depth_in_meters'))  %>%
  select(event_cols)

write.table(events, file = 'event.tsv', sep = '\t', row.names = F, col.names = T)

# Organism.tsv
organism_cols <- c('organism_id',
                   'organism_scope',
                   'organism_name',
                   'organism_remarks',
                   'verbatim_identification',
                   'scientific_name',
                   'kingdom',
                   'taxon_rank')
organism <- data %>%
  select(Predator) %>%
  rename(name=Predator) %>%
  mutate(group='predator') %>%
  bind_rows(data %>%
              select(Prey) %>%
              rename(name=Prey) %>%
              mutate(group='prey'))
organism
organism[,organism_cols] <- NA
organism$organism_id <- c(interactions$subject_organism_id, interactions$object_organism_id)
organism$verbatim_identification <- organism$name
organism$scientific_name <- organism$name
organism$kingdom <- 'Animalia'
organism$taxon_rank <- 'species'
organism$organism_scope <- 'individual'
organism  <- organism %>%
  select(-name) %>%
  distinct(organism_id, .keep_all = T)

write.table(organism %>% select(-group), file = 'organism.tsv', sep = '\t', row.names = F, col.names = T)

# Assertion.tsv
assertion_cols <- c(
                    'assertion_target_type',
                    'assertion_unit',
                    'assertion_made_date',
                    'assertion_effective_date',
                    'assertion_by_agent_name',
                    'assertion_by_agent_id',
                    'assertion_protocol',
                    'assertion_protocol_id',
                    'assertion_citation',
                    'assertion_remarks')

predator_assertion <- data %>%
  select(Predator.lifestage, Predator.fork.length, Predator.standard.length, Predator.total.length,
         Predator.mass, Predator.ratio.mass.mass) %>%
  mutate(across(everything(), as.character))
prey_assertion <- data %>%
  select(Prey.length, Prey.mass, Prey.ratio.mass.mass) %>%
  mutate(across(everything(), as.character))
predator_assertion$assertion_target_id <- interactions$subject_organism_id
prey_assertion$assertion_target_id <- interactions$object_organism_id

predator_assertion <- predator_assertion %>%
  select(-Predator.lifestage) %>%
  distinct(assertion_target_id, .keep_all = T) %>%
  pivot_longer(cols=c(Predator.fork.length, Predator.standard.length, Predator.total.length,
                      Predator.mass, Predator.ratio.mass.mass), names_to='assertion_type', values_to='assertion_value_numeric') %>%
  bind_rows(predator_assertion %>% select(assertion_target_id, Predator.lifestage) %>%
              distinct(assertion_target_id, .keep_all = T) %>%
              pivot_longer(cols=c(Predator.lifestage), names_to='assertion_type', values_to='assertion_value'))

prey_assertion <- prey_assertion %>%
  distinct(assertion_target_id, .keep_all = T) %>%
  pivot_longer(cols=c(Prey.length, Prey.mass, Prey.ratio.mass.mass), names_to='assertion_type', values_to='assertion_value_numeric')
prey_assertion  

predator_assertion_values <- data %>%
  select(Predator.lifestage) %>%
  mutate(assertion_value=Predator.lifestage, assertion_type='lifestage') %>% 
  data$Diet.coverage, data$Predator.length.mass.conversion.method) 
prey_assertion_values <- c(data$Prey.conversion.to.mass.method, data$Prey.conversion.to.mass.reference)
predator_assertion_values_numeric <- c(data$Predator.standard.length, data$Predator.fork.length, data$Predator.total.length, 
                                       data$Standardised.predator.length, data$Predator.quality.of.length.mass.conversion, 
                                       data$Predator.mass, data$Predator.mass.check, data$Predator.mass.check.diff, 
                                       data$Predator.ratio.mass.mass, data$SI.predator.mass)
prey_assertion_values_numeric <- c(data$Prey.length, data$SI.prey.length, data$Prey.mass, data$Prey.mass.check, data$Prey.mass.check.diff,
                                   data$Prey.ratio.mass.mass, data$SI.prey.mass, data$Prey.quality.of.conversion.to.mass)

predator_assertions <- rep(organism %>% filter(group=='predator') %>% select(organism_id), lenght.out=length(predator_assertion_values))
predator_assertions$assertion_value <- predator_assertion_values
predator_assertions$assertion_type <- 

assertion <- data %>%
  distinct(Individual.ID)
assertion[,assertion_cols] <- NA
