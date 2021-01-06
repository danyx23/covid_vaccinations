library(dplyr)
library(readr)

# break deliveries down by state in proportion to population

# from https://twitter.com/BMG_Bund/status/1345012835252887552
deliveries <- tibble(
  doses = c(
    rep(1.3e6/3, 3),
    rep(2.8e6/4, 4)
  ),
  delivery_date = lubridate::dmy(c(
    paste0(c('26.12.', '28.12.', '30.12.'), '2020'),
    paste0(c('8.1.', '18.1.', '25.1.', '1.2.'), '2021')
  )),
  vaccine_name = 'Pfizer/BioNTech'
)

bundeslaender <- readr::read_delim(
  'https://www.datenportal.bmbf.de/portal/Tabelle-1.10.2.csv', 
  delim = ';',
  skip = 7,
  col_names = FALSE,
  locale=readr::locale(encoding = "latin1", decimal_mark=',', grouping_mark = '.')
)
bundeslaender <- bundeslaender[1:16,c(1,15)]
bundeslaender %>% 
  purrr::set_names('bundesland', 'population') %>% 
  mutate(population = population * 1000) %>% 
  mutate(population_share = population / sum(population)) -> bundeslaender

deliveries %>% 
  tidyr::crossing(bundeslaender) %>% 
  mutate(doses = doses * population_share) %>% 
  group_by(bundesland) %>% 
  mutate(cumulative_doses = cumsum(doses)) %>% 
  ungroup %>% 
  arrange(bundesland, delivery_date) -> deliveries_by_state


dir.create(here::here('data/processed'), showWarnings = FALSE)

deliveries_by_state %>%
  arrow::write_parquet(here::here('data/processed/deliveries.parquet'))
