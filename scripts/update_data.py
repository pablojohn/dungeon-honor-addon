import upstash_redis
import os

# Initialize Redis Client
redis_url = os.getenv("UPSTASH_REDIS_URL")
redis_client = redis.StrictRedis.from_url(redis_url)

def fetch_player_data():
    keys = redis_client.keys("*")  # Adjust key pattern as needed
    players = {}
    for key in keys:
        players[key.decode()] = redis_client.hgetall(key)
    return players

def write_data_file(players):
    with open("src/DungeonHonorData.lua", "w") as lua_file:
        lua_file.write("local PlayerData = {\n")
        for player, data in players.items():
            lua_file.write(f'  ["{player}"] = {{ score = {data[b"score"].decode()}, votes = {data[b"votes"].decode()} }},\n')
        lua_file.write("}\n")
        lua_file.write("return PlayerData\n")

if __name__ == "__main__":
    player_data = fetch_player_data()
    write_data_file(player_data)
