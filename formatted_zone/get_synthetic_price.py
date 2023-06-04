import pandas as pd
import numpy as np
pd.set_option('display.max_columns', None)

### Since no real data on dynamic delivery fees, 
### here we generate ourselves the data based on the existing attributes

city_distances = pd.read_csv("city_distances.csv")
dhl_price = pd.read_csv("dhl_price.csv")
dhl_zone = pd.read_csv("dhl_zone.csv")
flights = pd.read_csv("flights.csv")
products = pd.read_csv("products.csv")
requests = pd.read_csv("requests.csv")
travels = pd.read_csv("travels.csv")
users = pd.read_csv("users.csv")

## Match requests with dhl fee

new_requests = requests.copy()

new_requests["startCity"] = new_requests["pickUpAddress"].apply(lambda x: users.loc[users["user_id"] == x]["city"].values[0])

new_requests["endCity"] = new_requests["collectionAddress"].apply(lambda x: users.loc[users["user_id"] == x]["city"].values[0])

def get_distance(start_city,end_city,parameter):
    return city_distances.loc[((city_distances["name1"] == start_city) & (city_distances["name2"] == end_city)) | 
                             ((city_distances["name1"] == end_city) & (city_distances["name2"] == start_city))][parameter].values[0]

# calculate distance between cities and the corresponding prices for fuel

new_requests["Distance"] = new_requests.apply(lambda x: get_distance(x["startCity"],x["endCity"],"distance_km"),axis = 1)
new_requests["lpg_price"] = new_requests.apply(lambda x: get_distance(x["startCity"],x["endCity"],"lpg_price"),axis = 1)
new_requests["diesel_price"] = new_requests.apply(lambda x: get_distance(x["startCity"],x["endCity"],"diesel_price"),axis = 1)
new_requests["gasoline_price"] = new_requests.apply(lambda x: get_distance(x["startCity"],x["endCity"],"gasoline_price"),axis = 1)

def get_product_character(productID,parameter):
    return products.loc[products["product_id"] == productID][parameter].values[0]

# join with product information    
new_requests["product_weight_g"] = new_requests["productId"].apply((lambda x: get_product_character(x,"product_weight_g")))
new_requests["product_length_cm"] = new_requests["productId"].apply((lambda x: get_product_character(x,"product_length_cm")))
new_requests["product_height_cm"] = new_requests["productId"].apply((lambda x: get_product_character(x,"product_height_cm")))
new_requests["product_width_cm"] = new_requests["productId"].apply((lambda x: get_product_character(x,"product_width_cm")))


def get_dhl_fee(startCity,endCity, product_weight_g):
    calculate_way = dhl_zone.loc[(dhl_zone["Region_start"] == startCity) & (dhl_zone["Region_end"] == endCity)]["Type"].values[0]
    
    weight = np.ceil(product_weight_g/1000)
    price = 0
    if weight <= 30:
        price = dhl_price.loc[dhl_price["Weight"] == weight][calculate_way].values[0]
    else:
        price = dhl_price.loc[dhl_price["Weight"] >= weight].reset_index(drop = True).iloc[0][calculate_way].values[0]
        
    return price

new_requests["dhl_fee"] = new_requests.apply(lambda x: get_dhl_fee(x["startCity"],x["endCity"],x["product_weight_g"]), axis = 1)

def estimate_delivery_fee(requests):
    return 0.001 *np.round( requests["Distance"],decimals=3) + \
        0.01*(np.round(requests["lpg_price"],decimals=3) + \
            np.round(requests["diesel_price"],decimals=3) + \
            np.round(requests["gasoline_price"],decimals=3)) + \
        0.0005 * np.round(requests["product_weight_g"],decimals=3) + \
        0.001 * (np.round(requests["product_length_cm"],decimals=3) + \
                np.round(requests["product_height_cm"],decimals=3) +
                np.round(products["product_width_cm"],decimals=3)) + \
        0.1 * np.round(requests["dhl_fee"],decimals=3)

new_requests["deliveryFee"] = estimate_delivery_fee(new_requests)


new_requests = new_requests.drop(
    ["startCity", "endCity", "Distance", "lpg_price", "diesel_price", "gasoline_price", 
     "product_weight_g", "product_length_cm", "product_height_cm", "product_width_cm"], axis=1)
new_requests.to_csv("requests.csv",index=False, encoding="utf_8_sig")