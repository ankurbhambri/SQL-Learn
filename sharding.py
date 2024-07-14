import psycopg2

# Configuration for database shards
num_shards = 4
shards = {
    0: "dbname=shard1 user=your_user password=your_password host=your_host",
    1: "dbname=shard2 user=your_user password=your_password host=your_host",
    2: "dbname=shard3 user=your_user password=your_password host=your_host",
    3: "dbname=shard4 user=your_user password=your_password host=your_host"
}

# shard based on user_id
def get_shard(user_id):
    return user_id % num_shards

def execute_query(db_connection, query, params):
    conn = psycopg2.connect(db_connection)
    cur = conn.cursor()
    cur.execute(query, params)
    result = cur.fetchone() if query.strip().upper().startswith("SELECT") else None
    conn.commit()
    cur.close()
    conn.close()
    return result

def insert_user(user_id, username, email, password_hash):
    shard_id = get_shard(user_id)
    db_connection = shards[shard_id]
    query = "INSERT INTO users (user_id, username, email, password_hash) VALUES (%s, %s, %s, %s)"
    execute_query(db_connection, query, (user_id, username, email, password_hash))

print(insert_user(1, 'john_doe', 'john@example.com', 'hashed_password'))
