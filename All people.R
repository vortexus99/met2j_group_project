library('tidyverse')  #import package
library('plotly')
library('dplyr')
library('gganimate')

pol_act_ath_raw_1 <- read.csv('D:/UCU/Labs/Intro to Data/met2j_group_project/act_pol_ath_1900_1950_death_cause.csv', stringsAsFactors = FALSE)
pol_act_ath_raw_2 <- read.csv('D:/UCU/Labs/Intro to Data/met2j_group_project/act_pol_ath_1950_1980_death_cause.csv', stringsAsFactors = FALSE)

allthree_raw <- bind_rows(pol_act_ath_raw_1, pol_act_ath_raw_2)

allthree <- allthree_raw
allthree$birthDate <- as.Date(allthree$birthDate, format = "%Y-%m-%d")
allthree$birthYear <- as.Date(allthree$birthYear, format = "%Y")
allthree$deathDate <- as.Date(allthree$deathDate, format = "%Y-%m-%d")

allthree_death_age <- allthree %>%
  mutate(
    death_age = deathDate - birthDate,
    death_age = as.numeric(death_age),
    death_age = death_age/365.242,
    Actor = as.logical(Actor),
    Politician = as.logical(Politician),
    Athlete = as.logical(Athlete),
    birthYear = as.numeric(format(birthDate, format = "%Y"))
  )

actor <- allthree_death_age %>% filter(Actor==TRUE)
politician <- allthree_death_age %>% filter(Politician==TRUE)
athlete <- allthree_death_age %>% filter(Athlete==TRUE)

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

bound_data <- subset(bound_data, death_age>0)
bound_data_decades <-bound_data %>%
  mutate(
    decade = 10*floor(birthYear/10)
  )

violin_all <- bound_data_decades %>%
  plot_ly(
    x= ~occupation_new,
    y= ~death_age,
    type = 'violin',
    split = ~occupation_new,
    frame = ~decade,
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

ggplotly(violin_all)
