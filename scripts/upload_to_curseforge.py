import requests
import os
import sys

CF_API_URL = "https://api.curseforge.com/v1/projects/<PROJECT_ID>/upload-file"
CF_API_KEY = os.getenv("CF_API_KEY")
FILE_PATH = sys.argv[1]

def upload_file(file_path):
    headers = {"x-api-key": CF_API_KEY}
    files = {"file": open(file_path, "rb")}
    data = {
        "changelog": "Daily automated update",
        "displayName": "Dungeon Honor Daily Update"
    }
    response = requests.post(CF_API_URL, headers=headers, files=files, data=data)
    if response.status_code == 200:
        print("Upload successful!")
    else:
        print(f"Failed to upload: {response.content}")

if __name__ == "__main__":
    upload_file(FILE_PATH)
