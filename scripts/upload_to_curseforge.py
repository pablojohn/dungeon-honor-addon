import requests
import os
import sys
import json

def fetch_game_version_ids(api_key, game_version_list):
    url = "https://addons-uploads.curseforge.com/api/game/wow/versions"
    headers = {
        "x-api-token": api_key
    }
    response = requests.get(url, headers=headers)

    if response.status_code != 200:
        print(f"Failed to fetch game versions. Status Code: {response.status_code}")
        print(response.text)
        sys.exit(1)

    game_versions_data = response.json()
    matched_ids = []

    for version_name in game_version_list:
        for version in game_versions_data:
            if version_name == version["name"]:
                matched_ids.append(version["id"])
                break

    if not matched_ids:
        print("Error: No matching game version IDs found.")
        sys.exit(1)

    return matched_ids

def upload_to_curseforge(api_key, project_id, file_path, changelog, game_version_ids, release_type, version):
    url = f"https://addons-uploads.curseforge.com/api/projects/{project_id}/upload-file"
    headers = {
        "x-api-token": api_key
    }

    metadata = {
        "changelog": changelog,
        "changelogType": "text",
        "displayName": f"DungeonHonor.{version}",
        "gameVersions": game_version_ids,
        "releaseType": release_type
    }

    with open(file_path, 'rb') as addon_file:
        files = {
            "metadata": (None, json.dumps(metadata), "application/json"),
            "file": (os.path.basename(file_path), addon_file)
        }

        print("Uploading addon...")
        response = requests.post(url, headers=headers, files=files)

    if response.status_code == 200:
        print("Addon uploaded successfully!")
        print(response.json())
    else:
        print(f"Failed to upload addon. Status Code: {response.status_code}")
        print(response.text)
        sys.exit(1)

if __name__ == "__main__":
    # Environment variables from GitHub Actions
    API_KEY = os.getenv("CURSEFORGE_API_KEY")
    PROJECT_ID = os.getenv("CURSEFORGE_PROJECT_ID")
    FILE_PATH = os.getenv("FILE_PATH")
    CHANGELOG = os.getenv("CHANGELOG")  # Should be passed dynamically or generated
    GAME_VERSIONS = os.getenv("GAME_VERSION")  # Updated to GAME_VERSION
    RELEASE_TYPE = os.getenv("RELEASE_TYPE", "release")
    VERSION = os.getenv("VERSION")

    if not all([API_KEY, PROJECT_ID, FILE_PATH, GAME_VERSIONS, VERSION]):
        print("Error: Missing one or more required environment variables.")
        sys.exit(1)

    game_version_list = GAME_VERSIONS.split(";")
    print(f"Game Versions to match: {game_version_list}")

    game_version_ids = fetch_game_version_ids(API_KEY, game_version_list)
    print(f"Matched Game Version IDs: {game_version_ids}")

    upload_to_curseforge(API_KEY, PROJECT_ID, FILE_PATH, CHANGELOG, game_version_ids, RELEASE_TYPE, VERSION)
