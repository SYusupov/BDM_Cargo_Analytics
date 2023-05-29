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

    return users, travels

def transform_data(users, travels):
    user_nodes = [{'user_id': row[0], 'gender': row[1], 'nationality': row[2], 'dob': row[3], 'is_traveller': row[4]} for row in users]
    travel_nodes = [{'userId': row[0], 'departureAirportFsCode': row[1], 'arrivalAirportFsCode': row[2]} for row in travels]

    return user_nodes, travel_nodes

def connect_neo4j():
    uri = "bolt://localhost:7687"
    driver = GraphDatabase.driver(uri, auth=("neo4j", "password"))
    return driver

def import_data_to_neo4j(driver, user_nodes, travel_nodes):
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

def main():
    conn = connect_postgres()
    users, travels = fetch_data_from_postgres(conn)

    user_nodes, travel_nodes = transform_data(users, travels)
    # print(user_nodes[0])

    driver = connect_neo4j()
    import_data_to_neo4j(driver, user_nodes, travel_nodes)

if __name__ == "__main__":
    main()