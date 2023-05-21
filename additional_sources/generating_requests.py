import pandas as pd
import random
from itertools import combinations

def main(products_csv, cities):
    """
    Generating requests based on the list of products.
    Origin and Destination are one of the target cities

    """
    products = pd.read_csv(products_csv)
    product_ids = products['product_id'].values

    requests = pd.DataFrame(columns=['product_id', 'request_day', 'user_id', 'fromCity', 'toCity'])
    requests['user_id'] = [random.randrange(20,40) for _ in range(20)]
    requests['request_day'] = ['2023.04.'+str(random.randrange(10,17)) for _ in range(20)]

    cities_combs = list(combinations(cities,2))
    combs = [random.choice(cities_combs) for _ in range(20)]
    requests['fromCity'] = [comb[0] for comb in combs]
    requests['toCity'] = [comb[1] for comb in combs]

    requests['product_id'] = [random.choice(product_ids) for _ in range(20)]

    requests = requests.loc[:, ~requests.columns.str.contains('^Unnamed')]
    requests.to_csv('requests.csv', index=False)

if __name__ == "__main__":
    products_csv = "products.csv"
    cities = ["Madrid", "Barcelona", "Málaga", "Palma"]
    main(products_csv, cities)