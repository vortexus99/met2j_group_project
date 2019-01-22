library('tidyverse')  #import package

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
    Athlete = as.logical(Athlete)
  )

#removes impossible values for death_age (like -2000) and entries without values (e.g. person stll alive)
updated_pol_act_ath_death_age <- subset(pol_act_ath_death_age, death_age>0)

#make new datasets with actors, politicians or athletes (if two of these are true, entry counts in both places)
actor <- updated_pol_act_ath_death_age %>% filter(Actor==TRUE)
politician <- updated_pol_act_ath_death_age %>% filter(Politician==TRUE)
athlete <- updated_pol_act_ath_death_age %>% filter(Athlete==TRUE)

#plot the data
ggplot() + 
  geom_violin(data = actor, mapping = aes(x = "Actors", y = death_age), fill = "hotpink", stat = "ydensity", 
              position = "dodge", trim = TRUE, draw_quantiles = c(0.25, 0.5, 0.75),
              scale = "area", na.rm = FALSE, show.legend  = NA) +
  geom_violin(data = politician, mapping = aes(x = "Politicians", y = death_age), fill = "lightblue", stat = "ydensity", 
              position = "dodge", trim = TRUE, draw_quantiles = c(0.25, 0.5, 0.75),
              scale = "area", na.rm = FALSE, show.legend = NA) +
  geom_violin(data = athlete, mapping = aes(x = "Athlete", y = death_age), fill = "lightgreen", stat = "ydensity", 
              position = "dodge", trim = TRUE, draw_quantiles = c(0.25, 0.5, 0.75),
              scale = "area", na.rm = FALSE, show.legend = NA) +
  ggtitle("Age of death distribution for different occupations") +
  xlab("Occupation") + ylab("Age of death") 


