import os

def get_player_data():
    players = {
        "PlayerOne": {b"score": b"95", b"votes": b"10"},
        "PlayerTwo": {b"score": b"80", b"votes": b"5"},
        "PlayerThree": {b"score": b"60", b"votes": b"8"},
        "PlayerFour": {b"score": b"70", b"votes": b"6"},
        "PlayerFive": {b"score": b"85", b"votes": b"12"},
    }
    return players

def write_data_file(players):
    with open("../src/DungeonHonorData_Temp.lua", "w") as lua_file:
        lua_file.write("HonorData = {\n")
        for player, data in players.items():
            lua_file.write(f'  ["{player}"] = {{ score = {data[b"score"].decode()}, votes = {data[b"votes"].decode()} }},\n')
        lua_file.write("}\n")

player_data = get_player_data()
write_data_file(player_data)
