import pandas as pd
from itertools import combinations
from datetime import datetime, timedelta
import random

def generate_luggage(avr, sigma=2):
    """random generation of luggage"""
    extraLuggage = 0
    while extraLuggage == 0:
        extraLuggage = round(random.normalvariate(avr, 2))
    return extraLuggage

def main(flights_csv, start_date, end_date, avg_stay, travelers_idx, airports, avr_luggage):
    """Assuming that Travelers are returning back from their trips, so we generate pairs of round trips
    Also includes the amount of extra luggage, different for each trip"""

    flights = pd.read_csv(flights_csv)

    flights['departureTime'] = pd.to_datetime(flights['departureTime'])
    flights['arrivalTime'] = pd.to_datetime(flights['arrivalTime'])
    airport_combs = list(combinations(airports,2))

    ## Randomly choose the dates of going and returning
    # Initialize lists for arrival and departure dates
    arrivals = []
    departures = []

    # Generate random arrival and departure dates for each traveler
    for i in range(len(travelers_idxs)):
        # Generate a random number of days to stay
        stay_duration = round(random.normalvariate(avg_stay, 0.5))
        
        # Generate a random arrival date within the specified range
        arrival_date = random.uniform(start_date, end_date - timedelta(days=stay_duration-1))
        
        # Calculate departure date
        departure_date = arrival_date + timedelta(days=stay_duration)
        
        # Add arrival and departure dates to the respective lists
        arrivals.append(arrival_date.date())
        departures.append(departure_date.date())

    travels = pd.DataFrame(columns=['userId', 'departureAirportFsCode', 'arrivalAirportFsCode', 'departureTime', 'arrivalTime', 'extraLuggage'])

    ## Choose the origin and destination randomly and appending pairs of trips to a new pd df
    for i in range(len(travelers_idxs)):
        row=[travelers_idx[i]]
        comb = random.choice(airport_combs)
        row.extend(comb)
        chosen_flight = flights.loc[(flights['departureAirportFsCode']==comb[0]) & (flights['arrivalAirportFsCode']==comb[1]) & (flights['departureTime'].dt.date == arrivals[i])].sample()
        row.append(chosen_flight['departureTime'].values[0])
        row.append(chosen_flight['arrivalTime'].values[0])
        
        extraLuggage = generate_luggage(avr_luggage)
        row.append(extraLuggage)
        
        travels.loc[len(travels)] = row
        
        row[1], row[2] = comb[1], comb[0]
        chosen_flight = flights.loc[(flights['departureAirportFsCode']==comb[1]) & (flights['arrivalAirportFsCode']==comb[0]) & (flights['departureTime'].dt.date == departures[i])].sample()
        row[3] = chosen_flight['departureTime'].values[0]
        row[4] = chosen_flight['arrivalTime'].values[0]
        
        extraLuggage = generate_luggage(avr_luggage)
        row[5] = extraLuggage
        travels.loc[len(travels)] = row
    
    travels = travels.loc[:, ~travels.columns.str.contains('^Unnamed')]

    ## Save the file
    travels.to_csv("travels.csv", index=False)

if __name__ == "__main__":
    flights_csv = "scheduledFlights_4dirs.csv"
    start_date = datetime(2023, 4, 19)
    end_date = datetime(2023, 4, 25)
    avg_stay = 3.33
    travelers_idxs = list(range(20))
    airports = ['MAD','BCN','PMI','AGP']
    avr_luggage = 4

    main(flights_csv, start_date, end_date, avg_stay, travelers_idxs, airports, avr_luggage)