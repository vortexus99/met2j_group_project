from analysis_func import json_filter
from csvConverter import read_header, process_csv
import json

headers = read_header("h.txt")

keys = ["rdf-schema#label","deathDate","birthDate","birthYear","occupation","occupation_label","title"]
values = ["actor"]

json_raw = []

for year in range(2000,2005):
    json_raw.extend(process_csv(f"data/years/{year}", headers))

json_filtered = json_filter(json_raw, keys)


'''counter = 0
for indx, entry in enumerate(test):
    for key in entry:
        if key == "occupation_label":
            print(f'Entry no. {indx} has occupation {entry[key]}')
            counter +=1

print(counter)'''

occupations = ["actor", "politician", "athlete", "musician"]

for entry in json_filtered:
    for occupation in occupations:
        if "occupation_label" in entry:
            if occupation in entry["occupation_label"].lower():
                entry["Occupation_g"]=occupation 
        if "occupation" in entry:
            if occupation in entry["occupation"].lower():
                entry["Occupation_g"]=occupation 


with open("json_test.json",'w') as file:
    json.dump(json_filtered, file, indent=4)