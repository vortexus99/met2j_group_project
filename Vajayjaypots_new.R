install.packages('plotly')
install.packages('dplyr')
install.packages('gganimate')

library('tidyverse')  #import package
library('plotly')
library('dplyr')
library('gganimate')

#import data
pol_act_ath_raw <- read.csv('D:/UCU/Labs/Intro to Data/met2j_group_project/actors_politicians_athletes_1900_1950.csv', stringsAsFactors = FALSE)

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

#make new datasets with actors, politicians or athletes (if two of these are true, entry counts in both places)
actor <- updated_pol_act_ath_death_age %>% filter(Actor==TRUE)
politician <- updated_pol_act_ath_death_age %>% filter(Politician==TRUE)
athlete <- updated_pol_act_ath_death_age %>% filter(Athlete==TRUE)


#create new dataframe that binds all the rows
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

#make fancier plot
violin <- bound_data %>%
  plot_ly(
    x= ~occupation_new,
    y= ~death_age,
    type = 'violin',
    split = ~occupation_new,
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


#to calcualte exact average age of death
occupations_barplot <- c('Actor', 'Athlete', 'Politician')
average_death_barplot <- c(mean(actor$death_age), mean(athlete$death_age), mean(politician$death_age))
averages_for_barplot <- data.frame(occupation = occupations_barplot, average_death_age = average_death_barplot)

ggplot(data = averages_for_barplot) +
  geom_col(mapping=aes(x=occupation, y=average_death_age, fill=occupation)) +
  coord_cartesian(ylim = c(60, 80)) +
  ggtitle("Average Age of Death per Occupation") +
  xlab("Occupation") + ylab("Average age of death")

