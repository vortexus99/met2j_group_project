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
for year in range(1900,1950):
    json_raw.extend(process_csv(f"data/years/{year}", headers))

json_filtered = json_filter(json_raw, keys)

occupations = ["actor", "politician", "athlete", "musician", "sing", "songwriter", "prince", "senator"]
athletes = ["player", "ball", "swimmer", "gymnist", "dancer", "cycl", "race", "sports"]
politics = ["senator", "parliament", "government", "politician"]

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
    for element in athletes: 
        if "occupation_label" in entry and "athlete" not in Occupation_g and element in entry["occupation_label"].lower():
            Occupation_g.append("athlete") 
        if "occupation" in entry and element in entry["occupation"].lower() and "athlete" not in Occupation_g:
            Occupation_g.append("athlete") 
        if "title" in entry and "athlete" not in Occupation_g and element in entry["title"].lower():
            Occupation_g.append("athlete") 
        if "rdf-schema#label" in entry and element in entry["rdf-schema#label"].lower() and "athlete" not in Occupation_g:
            Occupation_g.append("athlete") 
    for element in politics: 
        if "occupation_label" in entry and "politician" not in Occupation_g and element in entry["occupation_label"].lower():
            Occupation_g.append("politician") 
        if "occupation" in entry and element in entry["occupation"].lower() and "politician" not in Occupation_g:
            Occupation_g.append("athlete") 
        if "title" in entry and "politician" not in Occupation_g and element in entry["title"].lower():
            Occupation_g.append("politician") 
        if "rdf-schema#label" in entry and element in entry["rdf-schema#label"].lower() and "politician" not in Occupation_g:
            Occupation_g.append("politician") 


#selecting actors athletes and politicians 
for entry in json_filtered:
    entry["Actor"]="actor" in entry["Occupation_g"]
    entry["Politician"]="politician" in entry["Occupation_g"]
    entry["Athlete"]=element in entry["Occupation_g"]

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


#Leading causes of death 
#heart disease, cancer, stroke, accident, influenza/pneumonia 
#lists of keywords to look for: 
#counting in the key deathCause_label, if not already found in deathCause

#Making leading death causes into categories
for person in actorspoliticiansathletes: 
    #searching in the key deathCause
    if "deathCause" in person:
        if "heart" in person["deathCause"].lower():
            person["Cause_of_Death_cat"] = "Heart disease"
        if "cancer" in person["deathCause"].lower():
            person["Cause_of_Death_cat"] = "Cancer"
        if "stroke" in person["deathCause"].lower():
            person["Cause_of_Death_cat"] = "Stroke"
        if "accident" in person["deathCause"].lower():
            person["Cause_of_Death_cat"] = "Accident"
        if "influenza" in person["deathCause"].lower() or "pneumonia" in person["deathCause"].lower():
            person["Cause_of_Death_cat"] = "Influenza/Pneumonia"
    #counting in the key deathCause_label, if not already found in deathCause
    if "deathCause_label" in person: 
        if "heart" in person["deathCause"].lower() and "heart" not in person["deathCause"]:
            person["Cause_of_Death_cat"] = "Heart disease"
        if "cancer" in person["deathCause_label"].lower() and "cancer" not in person["deathCause"]:
            person["Cause_of_Death_cat"] = "Cancer"
        if "stroke" in person["deathCause_label"].lower() and "stroke" not in person["deathCause"]:
            person["Cause_of_Death_cat"] = "Stroke"
        if "accident" in person["deathCause_label"].lower() and "accident" not in person["deathCause"]:
            person["Cause_of_Death_cat"] = "Accident"
        if "influenza" in person["deathCause"].lower() or "pneumonia" in person["deathCause"].lower() and "influenze" not in person["deathCause"] and "pneumonia" not in person["deathCause"]:
            person["Cause_of_Death_cat"] = "Influenza/Pneumonia"
    if "Cause_of_Death_cat" not in person: 
        person["Cause_of_Death_cat"] = "Unknown"

#making a json with all entries containing a key for cause of death
leading_deathcauses = []
for person in actorspoliticiansathletes: 
    if "deathCause" in person: 
        leading_deathcauses.append(person)
    if "deathCause_label" in person and "deathCause" not in person:
        leading_deathcauses.append(person)

with open ('leading_deathcauses.json', 'w') as file:
    json.dump(leading_deathcauses, file, indent=4)


#writing actors politicians athletes with cause of death into csv
#headers of the csv
header = []
for person in actorspoliticiansathletes:
    for key in person.keys():
        if key not in header: 
            header.append(key)
#writing the csv
with open("met2j_group_project/act_pol_ath_00-50_leading_causes.csv", 'w') as file:
    writer = csv.DictWriter(file, fieldnames=header, lineterminator='\n', delimiter=',')
    writer.writeheader()
    for person in actorspoliticiansathletes:
        writer.writerow(person)