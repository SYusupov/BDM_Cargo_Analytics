import psycopg2
from neo4j import GraphDatabase
from datetime import datetime

def connect_postgres():
    conn = psycopg2.connect(
        dbname="formatted_zone",
        user="",
        password="",
        host="localhost",
        port="5432"
    )
    return conn

def fetch_data_from_postgres(conn):
    cur = conn.cursor()

    cur.execute("SELECT user_id, is_traveller, city FROM users")
    users = cur.fetchall()

    cur.execute("SELECT userId, departureAirportFsCode, arrivalAirportFsCode, departureTime, arrivalTime, extraLuggage FROM travels")
    travels = cur.fetchall()

    cur.execute("SELECT initializationUserId, collectionUserId, travellerId, productId, dateToDeliver, dateDelivered, requestDate, requestid FROM requests")
    requests = cur.fetchall()

    cur.execute("SELECT product_id, product_weight_g, product_category_name_english, product_name FROM products")
    products = cur.fetchall()

    return users, travels, requests, products

def transform_data(users, travels, requests, products):
    user_nodes = [{'user_id': row[0], 'is_traveller': row[1], 'city': row[2]} for row in users]
    travel_nodes = [{'userId': row[0], 'departureAirportFsCode': row[1], 'arrivalAirportFsCode': row[2], 'departureTime': row[3], 'arrivalTime': row[4], 'extraLuggage': row[5]} for row in travels]
    request_nodes = [{'initializationUserId': row[0], 'collectionUserId': row[1], 'travellerId': row[2], 'productId': row[3], 'dateToDeliver': row[4], 'dateDelivered': row[5], 'requestDate': row[6], 'requestid': row[7]} for row in requests]
    product_nodes = [{'product_id': row[0], 'product_weight_g': row[1], 'product_category_name_english': row[2], 'product_name': row[3]} for row in products]

    return user_nodes, travel_nodes, request_nodes, product_nodes

def connect_neo4j():
    uri = "bolt://localhost:7687"
    driver = GraphDatabase.driver(uri, auth=("neo4j", "password"))
    return driver

def import_data_to_neo4j(driver, user_nodes, travel_nodes, request_nodes, product_nodes):
    with driver.session() as session:
        for node in user_nodes:
            session.run("CREATE (:User {user_id: $user_id, is_traveller: $is_traveller, city: $city})", node)

        for node in travel_nodes:
            session.run("""
            CREATE (t:Travel {departureAirportFsCode: $departureAirportFsCode, arrivalAirportFsCode: $arrivalAirportFsCode, departureTime: datetime($departureTime), arrivalTime: datetime($arrivalTime), extraLuggage: $extraLuggage})
            WITH t
            MATCH (u:User {user_id: $userId})
            CREATE (u)-[:MAKES]->(t)
            """, node)
        
        for node in product_nodes:
            session.run("""
            CREATE (p:Product {product_id: $product_id, product_weight_g: $product_weight_g, product_category_name_english: $product_category_name_english, product_name: $product_name})
            """, node)

        for node in request_nodes:
            session.run("""
            CREATE (r:Request {dateToDeliver: datetime($dateToDeliver), requestid: $requestid})
            WITH r
            MATCH (iu:User {user_id: $initializationUserId})
            MATCH (cu:User {user_id: $collectionUserId})
            MATCH (tu:User {user_id: $travellerId})
            MATCH (p:Product {product_id: $productId})
            CREATE (iu)-[:INITIALIZE {date: datetime($requestDate)}]->(r)
            CREATE (cu)-[:COLLECT]->(r)
            CREATE (tu)-[:DELIVER {date: datetime($dateDelivered)}]->(r)
            CREATE (r)-[:CONTAIN]->(p)
            """, node)   

def main():
    conn = connect_postgres()
    users, travels, requests, products = fetch_data_from_postgres(conn)

    user_nodes, travel_nodes, request_nodes, product_nodes = transform_data(users, travels, requests, products)

    driver = connect_neo4j()
    import_data_to_neo4j(driver, user_nodes, travel_nodes, request_nodes, product_nodes)

if __name__ == "__main__":
    main()