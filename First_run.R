library('tidyverse')

politicians_actors_raw <- read.csv('D:/UCU/Labs/Intro to Data/met2j_group_project/actors_politicians_1900_1950.csv', stringsAsFactors = FALSE)

politicians_actors_date <- politicians_actors_raw

#turn birth and death into dates
politicians_actors_date$birthDate <- as.Date(politicians_actors_date$birthDate, format = "%Y-%m-%d")
politicians_actors_date$deathDate <- as.Date(politicians_actors_date$deathDate, format = "%Y-%m-%d")

#ccalculates death age and turns actor politician into boolean values
politicians_actors_death_age <- politicians_actors_date %>%
  mutate(
    death_age = deathDate - birthDate,
    death_age = as.numeric(death_age),
    death_age = death_age/365.242,
    Actor = as.logical(Actor),
    Politician = as.logical(Politician)
  )

#make new datasets with actors, politicians or both
actors <- politicians_actors_death_age %>% filter(Actor==TRUE)
politician <- politicians_actors_death_age %>% filter(Politician==TRUE)
both <- politicians_actors_death_age %>% filter(Actor==TRUE & Politician==TRUE)

#plot the data
ggplot() + 
  geom_violin(data = actors, mapping = aes(x = "Actors", y = death_age), fill = "hotpink", stat = "ydensity", 
              position = "dodge", trim = TRUE, draw_quantiles = c(0.25, 0.5, 0.75),
              scale = "area", na.rm = FALSE, show.legend = NA) +
  geom_violin(data = politician, mapping = aes(x = "Politicians", y = death_age), fill = "lightblue", stat = "ydensity", 
            position = "dodge", trim = TRUE, draw_quantiles = c(0.25, 0.5, 0.75),
            scale = "area", na.rm = FALSE, show.legend = NA)

