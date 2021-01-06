library(dplyr)
library(readxl)
library(arrow)

raw_data_dir <- here::here('data/raw/rki_vaccinations')

read_raw_file <- function(filename) {
  sheet_name <- readxl::excel_sheets(filename)[[2]]
  ref_date <- lubridate::dmy(stringr::str_extract(sheet_name, '[0-9]{2}\\.[0-9]{2}\\.[0-9]{2}'))
  
  readxl::read_xlsx(
    filename,
    sheet = 2
    ) %>% 
    head(16) %>% 
    purrr::set_names(~sub('*', '', ., fixed = TRUE)) %>%  
    select(
      Bundesland,
      "Impfungen kumulativ",
      "Differenz zum Vortag",
      `Impfungen pro 1.000 Einwohner`,
      "Indikation nach Alter",
      "Berufliche Indikation",
      "Medizinische Indikation",
      "Pflegeheim-bewohnerIn") %>% 
    mutate(dt = ref_date) -> df
  
  df
}


dir(raw_data_dir, full.names = TRUE) %>% 
  purrr::map_df(read_raw_file) %>% 
  arrange(Bundesland, dt) -> vaccinations

vaccinations %>%
  arrow::write_parquet(here::here('data/processed/rki_vaccinations.parquet'))
