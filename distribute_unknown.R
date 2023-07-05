
seafood_matrix <- read.csv(paste0(matrix_path, "20230420_nceas_consumption.csv"))

# Identify typologies of unknown 
unknown_types <- seafood_matrix %>%
  filter(source_country_iso3c == "unknown"|       
           nceas_group == "unknown"|
           habitat == "unknown"|
           method == "unknown") %>%
  select(source_country_iso3c, nceas_group, habitat, method) %>%
  mutate(
    source_country_iso3c = case_when(source_country_iso3c != "unknown" ~ "known",
                                     TRUE ~ "unknown"),
    nceas_group = case_when(nceas_group != "unknown" ~ "known",
                            TRUE ~ "unknown"),
    habitat = case_when(habitat != "unknown" ~ "known",
                        TRUE ~ "unknown"),
    method = case_when(method != "unknown" ~ "known",
                       TRUE ~ "unknown")
    ) %>%
  group_by(source_country_iso3c, nceas_group, habitat, method) %>%
  tally()

# Add typology group to source-consumption data frame
seafood_matrix <- seafood_matrix %>%
  mutate(unknown_type = case_when(
    (source_country_iso3c != "unknown" &
       nceas_group == "unknown" &
       habitat != "unknown" &
       method != "unknown") ~ "species_unknown",
    (source_country_iso3c == "unknown" &
     nceas_group == "unknown" &
     habitat != "unknown" &
     method == "unknown") ~ "habitat_only",
    (source_country_iso3c == "unknown" &
     nceas_group == "unknown" &
     habitat == "unknown" &
     method == "unknown") ~ "all_unknown",
    TRUE ~ "known"
  ))

# Unknown type 1: nothing known about source, habitat, method, or species group
# Use proportions of all known consumption
all_unknown_prop_df <- seafood_matrix %>%
  # Remove rows where any information is unknown
  filter(source_country_iso3c != "unknown",       
         nceas_group != "unknown",
         habitat != "unknown",
         method != "unknown") %>%
  # Get proportions for each consuming country
  group_by(consumer_iso3c) %>%
  mutate(all_unknown_prop = consumption_live_weight_t/sum(consumption_live_weight_t)) 

all_unknown <- all_unknown_prop_df %>% 
  left_join(seafood_matrix %>%
              # Filter to rows where all information is unknown
              filter(unknown_type == "all_unknown") %>%
              select(consumer_iso3c, "all_unknown_t" = "consumption_live_weight_t"),
            by = "consumer_iso3c") %>%
  mutate(consumption_live_weight_t = all_unknown_prop*all_unknown_t) %>%
  select(-all_unknown_prop, -all_unknown_t)

# Unknown type 2: only habitat known
# Use proportions of all known consumption by habitat
habitat_known_prop_df <- seafood_matrix %>%
  # Remove rows where habitat is unknown
  filter(habitat != "unknown") %>%
  # Get proportions for known habitats for each consuming country
  group_by(consumer_iso3c, habitat) %>%
  mutate(habitat_known_prop = consumption_live_weight_t/sum(consumption_live_weight_t)) 

habitat_known <- habitat_known_prop_df %>% 
  left_join(seafood_matrix %>%
              # Filter to rows where all information is unknown other than habitat
              filter(unknown_type == "habitat_only") %>%
              select(consumer_iso3c, habitat, "habitat_known_t" = "consumption_live_weight_t"),
            by = c("consumer_iso3c", "habitat")) %>%
  mutate(consumption_live_weight_t = habitat_known_prop*habitat_known_t) %>%
  select(-habitat_known_prop, -habitat_known_t)

# Unknown type 3: only species group is unknown
# Use proportions of all known consumption by source, habitat, and method
species_unknown_prop_df <- seafood_matrix %>%
  # Remove rows where nceas group  is unknown
  filter(nceas_group != "unknown") %>%
  # Get proportions each consuming country by source, habitat, and method
  group_by(consumer_iso3c, source_country_iso3c, habitat, method) %>%
  mutate(species_unknown_prop = consumption_live_weight_t/sum(consumption_live_weight_t)) 

species_unknown <- seafood_matrix %>% 
  # Filter to rows where only species information is unknown
  filter(unknown_type == "species_unknown") %>%
  select(consumer_iso3c, source_country_iso3c, habitat, method,
         "species_unknown_t" = "consumption_live_weight_t") %>%
  left_join(species_unknown_prop_df,
            by = c("consumer_iso3c", "source_country_iso3c", "habitat", "method")) %>%
  mutate(consumption_live_weight_t = species_unknown_prop*species_unknown_t) %>%
  select(-species_unknown_prop, -species_unknown_t)

# Join all together
seafood_matrix_new <- seafood_matrix %>%
  filter(unknown_type == "known") %>%
  bind_rows(all_unknown) %>%
  bind_rows(habitat_known) %>%
  bind_rows(species_unknown)

# Check consumption
seafood_check <- seafood_matrix %>%
  group_by(consumer_iso3c) %>%
  summarise(consumption_original = sum(consumption_live_weight_t, na.rm = TRUE)) %>%
  left_join(seafood_matrix_new %>%
              group_by(consumer_iso3c) %>%
              summarise(consumption_new = sum(consumption_live_weight_t, na.rm = TRUE)),
            by = "consumer_iso3c") %>%
  mutate(diff = consumption_new-consumption_original) %>%
  arrange(desc(abs(diff)))

# Final cleaning
seafood_matrix_new <- seafood_matrix_new %>%
  # Remove small values created by proportions
  filter(consumption_live_weight_t > 10^-9) %>%
  # Remove fmfo as this is handled separately
  filter(nceas_group != "fomf")
  