from analysis_func import json_filter
from csvConverter import read_header, process_csv
import json
import csv

headers = read_header("h.txt")

keys = ["rdf-schema#label","deathDate","birthDate","birthYear","occupation","occupation_label","title", "salary", "gender_label", "gender"]
values = ["actor"]

json_raw = []

for year in range(1900,1950):
    json_raw.extend(process_csv(f"data/years/{year}", headers))

json_filtered = json_filter(json_raw, keys)


'''counter = 0
for indx, entry in enumerate(test):
    for key in entry:
        if key == "occupation_label":
            print(f'Entry no. {indx} has occupation {entry[key]}')
            counter +=1

print(counter)'''

#making a variable for occupation in the filtered json
occupations = ["actor", "politician", "athlete", "musician", "sing", "songwriter", "prince", "senator", "president"]

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


#selecting actors and politicians 
for entry in json_filtered:
    entry["Actor"]="actor" in entry["Occupation_g"]
    entry["Politician"]="politician" in entry["Occupation_g"] or "president" in entry["Occupation_g"]
    entry["Athlete"]="athlete" in entry["Occupation_g"]

with open("json_test.json",'w') as file:
    json.dump(json_filtered, file, indent=4)

#making list of all actors and politicians
actorspoliticiansathletes = []
for entry in json_filtered:
    if entry["Politician"]==True:
        actorspoliticiansathletes.append(entry)
    elif entry["Actor"]==True:
        actorspoliticiansathletes.append(entry) 
    elif entry["Athlete"]==True:
        actorspoliticiansathletes.append(entry) 

#writing actors politicians into csv
header = []
for person in actorspoliticiansathletes:
    for key in person.keys():
        if key not in header: 
            header.append(key)

with open("actors_politicians_athletes_1900_1950.csv", 'w') as file:
    writer = csv.DictWriter(file, fieldnames=header, lineterminator='\n', delimiter=',')
    writer.writeheader()
    for person in actorspoliticiansathletes:
        writer.writerow(person)