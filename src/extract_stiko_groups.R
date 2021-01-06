library(dplyr)
library(pdftools)

pdf_text(here::here('doc/StIKo/02_21.pdf'))[[46]] %>% 
  # split filecontent by newline character
  stringr::str_split("\n") %>% 
  .[[1]] %>% 
  .[3:42] %>% 
  # convert to tibble and assign unique column names
  as_tibble(.name_repair = make.names) %>%
  # extract the data of each column by position
  mutate(
    stufe = stringr::str_sub(value, 0, 15),
    group = stringr::str_sub(value, 16, 134),
    N = stringr::str_sub(value, 135, 145),
  ) %>%
  # remove original string
  select(-value) %>%
  # remove white spaces around values
  mutate_all(stringr::str_trim) %>% 
  filter(group != 'Summe') %>% 
  mutate(group_id = cumsum(stringr::str_detect(group, '▶▶ '))) %>%
  group_by(group_id) %>%
  summarise_all(list(~ toString(na.omit(.)))) %>% 
  mutate(stufe = as.integer(stufe)) %>% 
  tidyr::fill(stufe) %>% 
  mutate(group = stringr::str_replace(group, '▶▶ ', '')) %>% 
  mutate(group = stringr::str_replace_all(group, '[\\*~°>\\?]', '')) %>%
  mutate(N_clean = stringr::str_replace(N, ',', '.')) %>% 
  mutate(N_clean = stringr::str_replace_all(N_clean, '[\\*~°>\\?, §\\.#/&$%]*$', '')) %>% 
  mutate(N_clean = as.numeric(stringr::str_replace(N_clean, '^> ', '')) * 1e6) %>%
  select(group_id, stufe, group, N=N_clean) -> stiko_groups

stiko_groups %>%
  arrow::write_parquet(here::here('data/processed/stiko_groups.parquet'))

