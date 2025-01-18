import requests
import os
import sys
import json

def upload_to_curseforge(api_key, project_id, file_path, changelog, game_version_id, release_type, version):
    url = f"https://addons-uploads.curseforge.com/api/projects/{project_id}/upload-file"
    headers = {
        "x-api-token": api_key
    }

    metadata = {
        "changelog": changelog,
        "changelogType": "text",
        "displayName": f"Version {version}",
        "gameVersion": game_version_id,
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
    GAME_VERSION_ID = os.getenv("GAME_VERSION_ID")
    RELEASE_TYPE = os.getenv("RELEASE_TYPE", "release")
    VERSION = os.getenv("VERSION")

    if not all([API_KEY, PROJECT_ID, FILE_PATH, GAME_VERSION_ID, VERSION]):
        print("Error: Missing one or more required environment variables.")
        sys.exit(1)

    upload_to_curseforge(API_KEY, PROJECT_ID, FILE_PATH, CHANGELOG, GAME_VERSION_ID, RELEASE_TYPE, VERSION)
