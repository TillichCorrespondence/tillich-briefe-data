import requests

data = requests.get(
    "https://github.com/TillichCorrespondence/tillich-entities/raw/refs/heads/main/json_dumps/bibls.json"  # noqa:
).json()

print(data)
