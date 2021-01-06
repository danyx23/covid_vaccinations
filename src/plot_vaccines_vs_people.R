library(arrow)
library(dplyr)
library(ggplot2)
library(hrbrthemes)


deliveries <- arrow::read_parquet(here::here('data/processed/deliveries.parquet'))
stiko_groups <- arrow::read_parquet(here::here('data/processed/stiko_groups.parquet'))


stiko_summ <- stiko_groups %>% group_by(stufe) %>% summarise(pop = sum(N, na.rm = T)) %>% mutate(pop = cumsum(pop))

deliveries %>% 
  group_by(vaccine_name, delivery_date) %>% 
  summarize(cumulative_doses = sum(cumulative_doses)) %>% 
  mutate(vaccines = cumulative_doses / 2) %>% 
  ggplot(aes(delivery_date, vaccines, fill=vaccine_name)) +
  geom_area() +
  geom_hline(
    data=stiko_summ,
    aes(yintercept = pop),
    linetype = 'dotted'
  ) +
  geom_text(
    data=stiko_summ,
    x=max(deliveries$delivery_date) - 2,
    aes(y=pop + 1.5e6, label=paste0('StIKo Stufe ', stufe)),
    inherit.aes = FALSE
  ) +
  scale_y_continuous(limits=c(0, 90e6), expand = c(0, 0), breaks=c(0,20,40,60,80)*1e6, labels = scales::unit_format(unit = "M", scale = 1e-6)) +
  scale_fill_discrete(name=NULL) +
  theme_ipsum_rc() +
  theme(
    legend.position = 'bottom',
    plot.caption = element_text(hjust = 0)
  ) + 
  xlab(NULL) + ylab('Volle Impfungen') +
  labs(
    title = "Angekündigte Lieferungen zugelassener Impfstoffe",
    caption = paste0(
      "Quellen:\n",
      "- Impflieferungen: BmG (https://twitter.com/BMG_Bund/status/1345012835252887552)\n",
      "- StIKo Gruppen: StIKo (https://www.rki.de/DE/Content/Infekt/EpidBull/Archiv/2021/Ausgaben/02_21.pdf?__blob=publicationFile)",
      "",
      "Annahme: Impfung nach aktuellem Plan, insb. 2 Dosen / Bürger"
    )
  ) -> vaccines_vs_people

vaccines_vs_people

dir.create(here::here('out/plots'), recursive = TRUE, showWarnings = FALSE)
ggsave(
  vaccines_vs_people,
  filename = here::here('out/plots/vaccines_vs_people.png'),
  width=25,
  height=25/sqrt(2),
  units = 'cm'
)
