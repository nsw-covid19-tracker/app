import argparse
import hashlib
import requests


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("venue")
    args = parser.parse_args()

    r = requests.get(
        "https://data.nsw.gov.au/data/dataset/"
        "0a52e6c1-bc0b-48af-8b45-d791a6d8e289/resource/"
        "f3a28eed-8c2a-437b-8ac1-2dab3cf760f9/download/venue-data.json"
    )
    json = r.json()
    data = json["data"]

    for key in data:
        for result in data[key]:
            if result["Venue"] == args.venue:
                m = hashlib.sha384()
                venue = result["Venue"]
                suburb = result["Suburb"]
                m.update(f"{suburb}: {venue}".encode("utf-8"))
                m.update(str(result["Lat"]).encode("utf-8"))
                m.update(str(result["Lon"]).encode("utf-8"))
                print(m.hexdigest())


if __name__ == "__main__":
    main()