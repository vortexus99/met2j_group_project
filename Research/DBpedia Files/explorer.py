import json

stars = {}

with open('star_magnitude') as file:
    stars = json.load(file)

print(len(stars))