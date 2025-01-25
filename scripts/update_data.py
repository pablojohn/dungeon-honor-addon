import os
from collections import defaultdict
from upstash_redis import Redis

def calculate_score(behavior_data_keys, rejoin_data_keys):
    # Initialize category scores
    category_scores = {"big_dam": 0, "uses_defensives": 0, "good_comms": 0, "giga_heals": 0}

    # Parse behavior data keys
    for key in behavior_data_keys:
        # Split the key
        segments = key.split(":")
        behavior_name = segments[-2].replace(" ", "_").lower()
        value = int(segments[-1])

        # Add value to the appropriate category
        if behavior_name in category_scores:
            category_scores[behavior_name] += value

    # Calculate total category score
    total_category_score = sum(category_scores.values()) / 4

    # Normalize the score
    normalized_category_score = ((total_category_score + 1) / 2) * 100

    # Calculate rejoin score
    rejoin_score = sum(1 for key in rejoin_data_keys if key.endswith(":yes"))
    rejoin_rate = rejoin_score / len(rejoin_data_keys) if rejoin_data_keys else 0

    # Final score
    return normalized_category_score + (rejoin_rate * 10)

def get_player_data():
    # Retrieve Redis credentials from environment variables
    redis_url = os.getenv("REDIS_URL")
    redis_token = os.getenv("REDIS_TOKEN")

    if not redis_url or not redis_token:
        raise ValueError("Redis URL or token is missing. Ensure REDIS_URL and REDIS_TOKEN are set in the environment.")

    redis = Redis(url=redis_url, token=redis_token)

    # Fetch behavior and rejoin data keys
    behavior_data_keys = redis.keys("wowbehave:behavior:*")
    rejoin_data_keys = redis.keys("wowbehave:rejoin:*")

    # Create dictionaries to store votes and scores
    votes_count = defaultdict(int)
    player_scores = {}

    # Process data per character
    for key in behavior_data_keys:
        # Split the key
        parts = key.split(":")
        if len(parts) < 7:
            continue  # Skip invalid keys

        character_name = parts[2]
        character_realm = parts[3]
        character_id = f"{character_name}-{character_realm}"

        # Increment votes
        votes_count[character_id] += 1

    # Calculate scores for each character
    for character_id in votes_count:
        # Extract character name and realm
        character_name, character_realm = character_id.rsplit("-", maxsplit=1)

        # Filter data for the character
        behavior_keys = [
            key for key in behavior_data_keys 
            if f":{character_name}:{character_realm}:" in key
        ]
        rejoin_keys = [
            key for key in rejoin_data_keys 
            if f":{character_name}:{character_realm}:" in key
        ]

        # Calculate score
        score = calculate_score(behavior_keys, rejoin_keys)
        player_scores[character_id] = {
            "score": str(round(score, 2)),
            "votes": str(votes_count[character_id])
        }

    return player_scores

import os

def write_data_file(players):
    # Use GITHUB_WORKSPACE or default to the current directory
    base_path = os.getenv("GITHUB_WORKSPACE", ".")
    file_path = os.path.join(base_path, "src/DungeonHonorData.lua")

    # Ensure the directory exists
    os.makedirs(os.path.dirname(file_path), exist_ok=True)

    # Write the Lua data file
    with open(file_path, "w") as lua_file:
        lua_file.write("DungeonHonorData = {\n")
        for player, data in players.items():
            lua_file.write(f'  ["{player}"] = {{ score = {data["score"]}, votes = {data["votes"]} }},\n')
        lua_file.write("}\n")

player_data = get_player_data()
write_data_file(player_data)
