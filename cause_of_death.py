from analysis_func import json_filter
from csvConverter import read_header, process_csv
import json
import csv

#filtering the json and selecting variables
headers = read_header("h.txt")

#these are the variables we want
keys = ["rdf-schema#label","deathDate","birthDate","birthYear","occupation","occupation_label","title","salary","deathCause","deathCause_label"]

json_raw = []

#Here we enter the range of years 
for year in range(1950,1980):
    json_raw.extend(process_csv(f"data/years/{year}", headers))

json_filtered = json_filter(json_raw, keys)

#making a variable for occupation in the filtered json
#the occupations we want to look for
occupations = ["actor", "politician", "athlete", "musician", "sing", "songwriter", "prince", "senator"]
#we look through the different variables that could contain the occupation
#and make them into one variable 
for entry in json_filtered:
    Occupation_g = []
    entry["Occupation_g"]=Occupation_g
    for occupation in occupations:
        if "occupation_label" in entry and occupation not in Occupation_g and occupation in entry["occupation_label"].lower():
            Occupation_g.append(occupation) 
        if "occupation" in entry and occupation in entry["occupation"].lower() and occupation not in Occupation_g:
            Occupation_g.append(occupation) 
        if "title" in entry and occupation not in Occupation_g and occupation in entry["title"].lower():
            Occupation_g.append(occupation) 
        if "rdf-schema#label" in entry and occupation in entry["rdf-schema#label"].lower() and occupation not in Occupation_g:
            Occupation_g.append(occupation) 

#selecting actors athletes and politicians 
for entry in json_filtered:
    entry["Actor"]="actor" in entry["Occupation_g"]
    entry["Politician"]="politician" in entry["Occupation_g"]
    entry["Athlete"]="athlete" in entry["Occupation_g"]

with open("json_test.json",'w') as file:
    json.dump(json_filtered, file, indent=4)

#making list of all actors athletes and politicians
actorspoliticiansathletes = []
for entry in json_filtered:
    if entry["Politician"]==True:
        actorspoliticiansathletes.append(entry)
    elif entry["Actor"]==True:
        actorspoliticiansathletes.append(entry) 
    elif entry["Athlete"]==True:
        actorspoliticiansathletes.append(entry) 


#seeing how many people have deathCause as entry 
counterraw = 0 
for person in json_raw: 
    if "deathCause" in person:
        counterraw += 1
    if "deathCause_label" in person and "deathCause" not in person:
        counterraw += 1
print(f'amount of people with death cause listed in raw file: {counterraw}')
#and for our specific occupation groups 
counteractpolath = 0 
for person in actorspoliticiansathletes: 
    if "deathCause" in person:
        counteractpolath += 1
    if "deathCause_label" in person and "deathCause" not in person:
        counteractpolath += 1
print(f'amount of actors, politicians, and athletes with death cause listed: {counteractpolath}')


#Exploration of death causes 
#lists of keywords to look for: 
diseases = ["cancer", "disease", "illness", "infection", "heart", "infarction", "stroke", "aneurysm", "leukemia", "pneumonia", "occlusion", "failure", "hemorrhage", "asphyxia", "pyelonephritis", "myasthenia gravis", "aids"]
crimes = ["drug", "murder", "shoot", "shot", "knife", "stab", "crime", "gang", "violen", "holocaust", "attack"]
natural = ["natural", "old", "age"]
suicides = ["suicide", "overdose"]
#counters for each category
diseasescounter = 0 
crimecounter = 0 
naturalcounter = 0
suicidecounter = 0 
for person in actorspoliticiansathletes: 
    #counting in the key deathCause
    if "deathCause" in person: 
        for disease in diseases: 
            if disease in person["deathCause"].lower():
                diseasescounter += 1
        for crime in crimes:
            if crime in person["deathCause"].lower():
                crimecounter += 1
        for nature in natural:
            if nature in person["deathCause"].lower():
                naturalcounter += 1
        for suicide in suicides:
            if suicide in person["deathCause"].lower():
                suicidecounter += 1
    #counting in the key deathCause_label, if not already found in deathCause
    if "deathCause_label" in person: 
        for disease in diseases: 
            if disease in person["deathCause_label"].lower() and disease not in person["deathCause"]:
                diseasescounter += 1
        for crime in crimes:
            if crime in person["deathCause_label"].lower() and crime not in person["deathCause"]:
                crimecounter += 1
        for nature in natural:
            if nature in person["deathCause_label"].lower() and nature not in person["deathCause"]:
                naturalcounter += 1
        for suicide in suicides: 
            if suicide in person["deathCause_label"].lower() and suicide not in person["deathCause"]:
                suicidecounter += 1
#printing results
print(f'diseases: {diseasescounter}')
print(f'crimes: {crimecounter}')
print(f'natural deaths: {crimecounter}')
print(f'suicides: {crimecounter}')

#Making death causes into categories
for person in actorspoliticiansathletes: 
    #searching in the key deathCause
    if "deathCause" in person: 
        for disease in diseases: 
            if disease in person["deathCause"].lower():
                person["Cause_of_Death_cat"] = "Disease"
        for crime in crimes:
            if crime in person["deathCause"].lower():
                person["Cause_of_Death_cat"] = "Crime"
        for nature in natural:
            if nature in person["deathCause"].lower():
                person["Cause_of_Death_cat"] = "Natural"
        for suicide in suicides:
            if suicide in person["deathCause"].lower():
                person["Cause_of_Death_cat"] = "Suicide"
    #counting in the key deathCause_label, if not already found in deathCause
    if "deathCause_label" in person: 
        for disease in diseases: 
            if disease in person["deathCause_label"].lower() and disease not in person["deathCause"]:
                person["Cause_of_Death_cat"] = "Disease"
        for crime in crimes:
            if crime in person["deathCause_label"].lower() and crime not in person["deathCause"]:
                person["Cause_of_Death_cat"] = "Crime"
        for nature in natural:
            if nature in person["deathCause_label"].lower() and nature not in person["deathCause"]:
                person["Cause_of_Death_cat"] = "Natural"
        for suicide in suicides: 
            if suicide in person["deathCause_label"].lower() and suicide not in person["deathCause"]:
                person["Cause_of_Death_cat"] = "Suicide"

#making a json with all entries containing a key for cause of death
deathcauses = []
for person in actorspoliticiansathletes: 
    if "deathCause" in person: 
        deathcauses.append(person)
    if "deathCause_label" in person and "deathCause" not in person:
        deathcauses.append(person)

with open ('deathcauses.json', 'w') as file:
    json.dump(deathcauses, file, indent=4)


#writing actors politicians athletes with cause of death into csv
#headers of the csv
header = []
for person in actorspoliticiansathletes:
    for key in person.keys():
        if key not in header: 
            header.append(key)
#writing the csv
with open("met2j_group_project/act_pol_ath_1950_1980_death_cause.csv", 'w') as file:
    writer = csv.DictWriter(file, fieldnames=header, lineterminator='\n', delimiter=',')
    writer.writeheader()
    for person in actorspoliticiansathletes:
        writer.writerow(person)