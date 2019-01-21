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

occupations = ["actor", "politician", "athlete", "musician", "sing", "songwriter", "prince"]


for entry in json_filtered:
    Occupation_g = []
    entry["Occupation_g"]=Occupation_g
    for occupation in occupations:
        if "occupation_label" in entry:
            if occupation not in Occupation_g:
                if occupation in entry["occupation_label"].lower():
                    Occupation_g.append(occupation) 
        if "occupation" in entry:
            if occupation in entry["occupation"].lower():
                if occupation not in Occupation_g:
                    Occupation_g.append(occupation) 
        if "title" in entry:
            if occupation not in Occupation_g:
                if occupation in entry["title"].lower():
                    Occupation_g.append(occupation) 

with open("json_test.json",'w') as file:
    json.dump(json_filtered, file, indent=4)