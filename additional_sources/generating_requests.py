import pandas as pd
import random
import datetime
from datetime import timedelta
import numpy as np

def random_date(start, end):
    """
    This function will return a random datetime between two datetime 
    objects.
    """
    delta = end - start
    int_delta = (delta.days * 24 * 60 * 60) + delta.seconds
    random_second = random.randrange(int_delta)
    return start + timedelta(seconds=random_second)

def generate_requests(products_csv, users_csv, nToGen, start_date, end_date, notFulfilled=False):
    """
    Generating requests based on the list of products.
    Origin and Destination are one of the target cities

    Number of records to generate - 200

    For each record
    - randomly decide collectionUserID [20-39] and initializationUserId [20-39], shouldn't be the same city (maybe 50% wihtout initializationId)
    - randomly decide the traveler
    - dateToDeliver - random between 3 to 10 days
    - requestDate - random within the last 6 months before April 19
    - deliveryFee - do more research for estimation

    """
    products = pd.read_csv(products_csv)
    users = pd.read_csv(users_csv)
    # distances = pd.read_csv(distances_csv)

    product_ids = products['product_id'].values

    requests = pd.DataFrame(columns=[
        'requestId','initializationUserId', 'collectionUserId', 'travellerId', 'productId', 'dateToDeliver', 
        'dateDelivered', 'requestDate', 'pickUpAddress', 'collectionAddress', 'description', 'deliveryFee'])

    initUser = []
    collectUser = []
    travellerId = []
    productId = []
    dateToDeliver = []
    dateDelivered = []
    requestDate = []

    # 159*random(0.02,0.025)+0.6*random(2,2.5)
    # distanceFactor = 0.02
    # distanceFactor_diff = 0.005
    # weightFactor = 2
    # weightFacotor_diff = 0.5

    for _ in range(nToGen):
        initUser.append(random.randrange(20,40))

        initUser_city = users.loc[users['user_id'] == initUser[-1]].city.values[0]
        valid_userIds = users.loc[(users['city'] != initUser_city) & (users['user_id'] > 19)].user_id.values
        collectUser.append(random.choice(valid_userIds))

        if notFulfilled:
            travellerId.append(np.nan)
        else:
            travellerId.append(random.randrange(0,20))

        productId.append(random.choice(product_ids))

        # getting all the dates
        requestD = random_date(start_date, end_date)
        requestDate.append(requestD.strftime('%m/%d/%Y %I:%M %p'))

        randDays = random.randrange(6, 14)
        toDeliver = requestD + timedelta(days=randDays)
        dateToDeliver.append(toDeliver.strftime('%m/%d/%Y %I:%M %p'))

        if notFulfilled:
            dateDelivered.append(np.nan)
        else:
            randHours = random.randrange(2*24*60, randDays*24*60)
            delivered = requestD + timedelta(minutes=randHours)
            dateDelivered.append(delivered.strftime('%m/%d/%Y %I:%M %p'))
    
    requests['initializationUserId'] = initUser
    requests['collectionUserId'] = collectUser
    requests['travellerId'] = travellerId
    requests['productId'] = productId
    requests['dateToDeliver'] = dateToDeliver
    requests['requestDate'] = requestDate
    requests['pickUpAddress'] = initUser
    requests['collectionAddress'] = collectUser
    requests['description'] = ''
    
    if notFulfilled:
        requests['deliveryFee'] = np.nan
        requests['Satisfactory'] = np.nan
    else:
        requests['dateDelivered'] = dateDelivered
        requests["Satisfactory"] = np.random.choice([True,False],size = requests.shape[0],p = [0.9,0.1])

        # TODO: add formula for deliveryFee price
        requests['deliveryFee'] = 0

    return requests

if __name__ == "__main__":
    products_csv = "products.csv"
    users_csv = "users.csv"
    end_date = datetime.datetime.strptime('09/30/2023', '%m/%d/%Y')
    start_date = datetime.datetime.strptime('03/31/2023', '%m/%d/%Y')

    requests1 = generate_requests(products_csv, users_csv, 200, start_date, end_date, False)

    start_date = datetime.datetime.strptime('04/10/2023', '%m/%d/%Y')
    end_date = datetime.datetime.strptime('04/17/2023', '%m/%d/%Y')
    requests2 = generate_requests(products_csv, users_csv, 20, start_date, end_date, True)

    requests1 = pd.concat([requests1, requests2])
    requests1['requestId'] = list(range(requests1.shape[0]))

    requests1.to_csv('requests.csv', index=False)
