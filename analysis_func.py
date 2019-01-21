#File contains all the python functions with use for 
#analysing and processing our data.

from csvConverter import read_header, process_csv
import json

#Passing this function a csv to convert and the keys
#we want to filter for will produce a filtered json
def json_filter(file, keys):

    #Int list
    json_filtered = []

    for entry in file:
        jf_entry = {}
        for key in entry:
            if key in keys:
                jf_entry[key] = entry[key]
        
        json_filtered.append(jf_entry)
    return json_filtered



    




