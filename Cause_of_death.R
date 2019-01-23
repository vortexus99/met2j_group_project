install.packages('plotly')
install.packages('dplyr')

library('tidyverse')  #import package
library('plotly')
library('dplyr')
library('RColorBrewer')

#import data
pol_act_ath_raw <- read.csv('act_pol_ath_1900_1950_death_cause.csv', stringsAsFactors = FALSE)

#make new dataframe so we don't change anything in raw
pol_act_ath_date <- pol_act_ath_raw

#turn birth and death into date format
pol_act_ath_date$birthDate <- as.Date(pol_act_ath_date$birthDate, format = "%Y-%m-%d")
pol_act_ath_date$deathDate <- as.Date(pol_act_ath_date$deathDate, format = "%Y-%m-%d")

#ccalculates death age and turns actor, politician and athlete into boolean values
pol_act_ath_death_age <- pol_act_ath_date %>%
  mutate(
    death_age = deathDate - birthDate,
    death_age = as.numeric(death_age), #default calculation is with days as units
    death_age = death_age/365.242,     #calculates age in years
    Actor = as.logical(Actor),
    Politician = as.logical(Politician),
    Athlete = as.logical(Athlete),
    birthYear = as.numeric(format(birthDate, format = "%Y"))
  )

#removes impossible values for death_age (like -2000) and entries without values (e.g. person stll alive)
updated_pol_act_ath_death_age <- subset(pol_act_ath_death_age, death_age>0)

#making cause of death into a factor
updated_pol_act_ath_death_age$Cause_of_Death_cat <- as.factor(updated_pol_act_ath_death_age$Cause_of_Death_cat)
print(levels(bound_data$Cause_of_Death_cat))

#make new datasets with actors, politicians or athletes (if two of these are true, entry counts in both places)
actor <- updated_pol_act_ath_death_age %>% filter(Actor==TRUE)
politician <- updated_pol_act_ath_death_age %>% filter(Politician==TRUE)
athlete <- updated_pol_act_ath_death_age %>% filter(Athlete==TRUE)


actor_new <- actor %>%
  mutate(
    occupation_new = "Actor"
  )
athlete_new <- athlete %>%
  mutate(
    occupation_new = "Athlete"
  )
politician_new <- politician %>%
  mutate(
    occupation_new = "Politician"
  )

bound_data <- bind_rows(actor_new, athlete_new, politician_new)

#Plot for different causes of death 
violin <- bound_data %>%
  filter(Cause_of_Death_cat == c("Unknown", "Disease", "Crime")) %>%
  plot_ly(
    x= ~occupation_new,
    y= ~death_age,
    type = 'violin',
    split = ~Cause_of_Death_cat,
    box = list(
      visible = TRUE
    ),
    meanline = list(
      visible = TRUE
    )
  ) %>%
  layout(
    xaxis = list(
      title = "Occupation"
    ),
    yaxis = list(
      title = "Age of death",
      zeroline = FALSE
    )
  )


ggplotly(violin)

ggplot(data=bound_data) + 
  geom_bar(aes(x=occupation_new, fill=Cause_of_Death_cat), stat='count', position = 'stack') +
  theme_classic() + 
  scale_fill_brewer() + 
  labs(x='Occupation', y='Count', fill='Cause of Death')

