library(dplyr)
library(readxl)

raw_data_dir <- here::here('data/raw/rki_vaccinations')

read_raw_file <- function(filename) {
  sheet_name <- readxl::excel_sheets(filename)[[2]]
  ref_date <- lubridate::mdy(stringr::str_extract(sheet_name, '[0-9]{2}\\.[0-9]{2}\\.[0-9]{2}'))
  
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
  arrange(Bundesland, dt) -> df

# from https://twitter.com/BMG_Bund/status/1345012835252887552
deliveries <- tibble(
  doses = c(
    rep(1.3e6/3, 3),
    rep(2.8e6/4, 4)
  ),
  delivery_date = lubridate::dmy(c(
    paste0(c('26.12.', '28.12.', '30.12.'), '2020'),
    paste0(c('8.1.', '18.1.', '25.1.', '1.2.'), '2021')
  ))
)

library(ggplot2)

df %>% ggplot(aes(dt, `Impfungen pro 1.000 Einwohner`, color=Bundesland)) + geom_line()

