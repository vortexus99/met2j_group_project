from analysis_func import json_filter
from csvConverter import read_header, process_csv
import json
import csv

headers = read_header("h.txt")

keys = ["deathDate","birthDate","birthYear"]

json_raw = []

for year in range(1900,1950):
    json_raw.extend(process_csv(f"data/years/{year}", headers))

#Create filtered json with keys
json_filtered = json_filter(json_raw, keys)


#writing headers from keys
header = []
for person in json_filtered:
    for key in person.keys():
        if key not in header:
            header.append(key)

#Creating file
with open("all_people_1900_1950.csv", 'w',encoding="utf-8") as file:
    writer = csv.DictWriter(file, fieldnames=header, lineterminator='\n', delimiter=',')
    writer.writeheader()
    for person in json_filtered:
        writer.writerow(person)