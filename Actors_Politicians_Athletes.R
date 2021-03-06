install.packages('plotly')
install.packages('dplyr')
install.packages("wesanderson")
library('wesanderson')
library('tidyverse')  #import package
library('plotly')
library('dplyr')
library('RColorBrewer')

#import data
pol_act_ath_raw <- read.csv('actors_politicians_athletes_1900_1950.csv', stringsAsFactors = FALSE)

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
    birthYear = as.numeric(format(birthDate, format = "%Y"))
  )

#removes impossible values for death_age (like -2000) and entries without values (e.g. person stll alive)
updated_pol_act_ath_death_age <- subset(pol_act_ath_death_age, death_age>0)

#make new datasets with actors, politicians or athletes (if two of these are true, entry counts in both places)
actor <- updated_pol_act_ath_death_age %>% filter(Actor==TRUE)
politician <- updated_pol_act_ath_death_age %>% filter(Politician==TRUE)
athlete <- updated_pol_act_ath_death_age %>% filter(Athlete==TRUE)
business <- updated_pol_act_ath_death_age %>% filter(Business_person==TRUE)

#plot the data
violinplots <- ggplot() + 
  geom_violin(data = actor, mapping = aes(x = "Actor", y = death_age), fill = "hotpink", stat = "ydensity", 
              position = "dodge", trim = TRUE, draw_quantiles = c(0.25, 0.5, 0.75),
              scale = "area", na.rm = FALSE, show.legend  = NA) +
  geom_violin(data = politician, mapping = aes(x = "Politicians", y = death_age), fill = "lightblue", stat = "ydensity", 
               position = "dodge", trim = TRUE, draw_quantiles = c(0.25, 0.5, 0.75),
               scale = "area", na.rm = FALSE, show.legend = NA) +
  geom_violin(data = athlete, mapping = aes(x = "Athlete", y = death_age), fill = "lightgreen", stat = "ydensity", 
               position = "dodge", trim = TRUE, draw_quantiles = c(0.25, 0.5, 0.75),
               scale = "area", na.rm = FALSE, show.legend = NA) +
  geom_violin(data = business, mapping = aes(x = "Business_person", y = death_age), fill = "yellow", stat = "ydensity", 
              position = "dodge", trim = TRUE, draw_quantiles = c(0.25, 0.5, 0.75),
              scale = "area", na.rm = FALSE, show.legend = NA) +
  ggtitle("Age of Death Distribution for Different Occupations") +
  xlab("Occupation") + ylab("Age of death") 
  
ggplotly(violinplots)

#to calcualte exact average age of death
occupations_barplot <- c('Actor', 'Athlete', 'Politician')
average_death_barplot <- c(mean(actor$death_age), mean(athlete$death_age), mean(politician$death_age))
sd_death_barplot <- c(sd(actor$death_age), c(sd(athlete$death_age), c(sd(politician$death_age))))
averages_for_barplot <- data.frame(occupation = occupations_barplot, average_death_age = average_death_barplot, standard_deviation = sd_death_barplot)

ggplot(data = averages_for_barplot, aes(x=occupation, y=average_death_age, fill=occupation)) +
  geom_col() +
  geom_errorbar(aes(ymin=average_death_age-sd_death_barplot, ymax=average_death_age+sd_death_barplot), width=.2, position=position_dodge(.9)) +
  #coord_cartesian(ylim = c(60, 80)) +
  ggtitle("Average Age of Death per Occupation") +
  theme_minimal() + 
  theme(legend.position = 'none', plot.title = element_text(hjust = 0.5)) + 
  xlab("Occupation") + ylab("Average age of death") +
  scale_fill_manual(values = wes_palette(n=3, name="GrandBudapest2")) 
