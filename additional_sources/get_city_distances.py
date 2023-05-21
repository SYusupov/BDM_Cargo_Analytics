"""
Getting distances between all pairs of cities for all target cities
Used for estimating the delivery price
"""

import geopy.distance
import pandas as pd
from itertools import combinations

df = pd.read_csv("cities.csv")

target_cities = [0, 1, 3, 58, 24]
cities_combs = list(combinations(target_cities, 2))

city_pairs_df = pd.DataFrame(columns=['country1', 'latitude1', 'longitude1', 'name1', 'country2', 'latitude2', 'longitude2', 'name2', 'distance_km'])

for comb in cities_combs:
    row = df.loc[comb[0]]['country':'name'].tolist()
    row.extend(df.loc[comb[1]]['country':'name'].tolist())
    row.append(geopy.distance.geodesic((row[1],row[2]), (row[5],row[6])).km)
    city_pairs_df.loc[len(city_pairs_df)+1] = row

city_pairs_df.to_csv('cities_distances.csv')