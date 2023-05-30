import psycopg2
from neo4j import GraphDatabase

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

    cur.execute("SELECT * FROM users")
    users = cur.fetchall()

    cur.execute("SELECT * FROM travels")
    travels = cur.fetchall()

    cur.execute("SELECT * FROM requests")
    requests = cur.fetchall()

    cur.execute("SELECT * FROM products")
    products = cur.fetchall()

    return users, travels, requests, products

def transform_data(users, travels, requests, products):
    user_nodes = [{'user_id': row[0], 'gender': row[1], 'nationality': row[2], 'dob': row[3], 'is_traveller': row[4]} for row in users]
    travel_nodes = [{'userId': row[0], 'departureAirportFsCode': row[1], 'arrivalAirportFsCode': row[2]} for row in travels]
    request_nodes = [{'initializationUserId': row[0], 'collectionUserId': row[1], 'productId': row[3]} for row in requests]
    product_nodes = [{'product_id': row[0]} for row in products]

    return user_nodes, travel_nodes, request_nodes, product_nodes

def connect_neo4j():
    uri = "bolt://localhost:7687"
    driver = GraphDatabase.driver(uri, auth=("neo4j", "password"))
    return driver

def import_data_to_neo4j(driver, user_nodes, travel_nodes, request_nodes, product_nodes):
    with driver.session() as session:
        for node in user_nodes:
            session.run("CREATE (:User {user_id: $user_id, gender: $gender, nationality: $nationality, dob: $dob, is_traveller: $is_traveller})", node)
        
        for node in travel_nodes:
            session.run("""
            CREATE (t:Travel {departureAirportFsCode: $departureAirportFsCode, arrivalAirportFsCode: $arrivalAirportFsCode})
            WITH t
            MATCH (u:User {user_id: $userId})
            CREATE (u)-[:MAKES]->(t)
            """, node)
        
        for node in request_nodes:
            session.run("""
            CREATE (r:Request {initializationUserId: $initializationUserId, collectionUserId: $collectionUserId, productId: $productId})
            WITH r
            MATCH (iu:User {user_id: $initializationUserId})
            MATCH (cu:User {user_id: $collectionUserId})
            CREATE (iu)-[:INITIALIZE]->(r)
            CREATE (cu)-[:COLLECT]->(r)
            """, node)
        
        for node in product_nodes:
            session.run("""
            CREATE (p:Product {product_id: $product_id})
            WITH p
            MATCH (r:Request {productId: $product_id})
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