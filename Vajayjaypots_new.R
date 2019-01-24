install.packages('plotly')
install.packages('dplyr')
install.packages('gganimate')

library('tidyverse')  #import package
library('plotly')
library('dplyr')
library('gganimate')
library("wesanderson")

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
    Business_person = as.logical(Business_person),
    birthYear = as.numeric(format(birthDate, format = "%Y")),
    Cause_of_Death_cat = as.factor(Cause_of_Death_cat)
  )

#removes impossible values for death_age (like -2000) and entries without values (e.g. person stll alive)
updated_pol_act_ath_death_age <- subset(pol_act_ath_death_age, death_age>0)

#make new datasets with actors, politicians or athletes (if two of these are true, entry counts in both places)
actor <- updated_pol_act_ath_death_age %>% filter(Actor==TRUE)
politician <- updated_pol_act_ath_death_age %>% filter(Politician==TRUE)
athlete <- updated_pol_act_ath_death_age %>% filter(Athlete==TRUE)
business <- updated_pol_act_ath_death_age %>% filter(Business_person==TRUE)

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
business_new <- business %>%
  mutate(
    occupation_new = "Business"
  )

bound_data <- bind_rows(actor_new, athlete_new, politician_new, business_new)

#make fancier plot
violin <- bound_data %>%
  plot_ly(
    x= ~occupation_new,
    y= ~death_age,
    type = 'violin',
    split = ~occupation_new,
    frame = ~birthYear,
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


#making the pots by decade
decades <- bound_data %>%
  mutate(
    decade = 10*floor(birthYear/10)
  )


violin_decades <- decades %>%
  plot_ly(
    x= ~occupation_new,
    y= ~death_age,
    type = 'violin',
    split = ~occupation_new,
    frame = ~decades,
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

ggplotly(violin_decades)


#to calcualte exact average age of death
occupations_barplot <- c('Actor', 'Athlete', 'Politician', 'Business person')
average_death_barplot <- c(mean(actor$death_age), mean(athlete$death_age), mean(politician$death_age), mean(business$death_age))
sd_death_barplot <- c(sd(actor$death_age), c(sd(athlete$death_age), c(sd(politician$death_age)), c(sd(business$death_age))))
averages_for_barplot <- data.frame(occupation = occupations_barplot, average_death_age = average_death_barplot, standard_deviation = sd_death_barplot)

ggplot(data = averages_for_barplot, aes(x=occupation, y=average_death_age, fill=occupation)) +
  geom_col() +
  geom_errorbar(aes(ymin=average_death_age-sd_death_barplot, ymax=average_death_age+sd_death_barplot), width=.2, position=position_dodge(.9)) +
  #coord_cartesian(ylim = c(60, 80)) +
  ggtitle("Average Age of Death per Occupation") +
  theme_minimal() + 
  theme(legend.position = 'none', plot.title = element_text(hjust = 0.5)) + 
  xlab("Occupation") + ylab("Average age of death") +
  scale_fill_manual(values = wes_palette(n=4, name="GrandBudapest2")) 