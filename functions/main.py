import datetime as dt
import firebase_admin
import json
import requests
import sys

from firebase_admin import credentials
from loguru import logger
from requests_html import HTMLSession

import utils

cred = credentials.Certificate("keyfile.json")
firebase_admin.initialize_app(
    cred, {"databaseURL": f"https://{cred.project_id}.firebaseio.com"}
)


def main():
    logger.remove()
    logger.add(
        sys.stdout,
        format=(
            "<green>{time:YYYY-MM-DD HH:mm:ss}</green> | "
            "<level>{level: <8}</level> | <level>{message}</level>"
        ),
    )

    r = requests.get(
        "https://data.nsw.gov.au/data/dataset/"
        "0a52e6c1-bc0b-48af-8b45-d791a6d8e289/resource/"
        "f3a28eed-8c2a-437b-8ac1-2dab3cf760f9/download/venue-data.json"
    )
    json_str = r.text.replace("var venue_data =", "")
    data = json.loads(json_str)["data"]
    postcodes = {}

    for key in data:
        for result in data[key]:
            suburb = result["Suburb"]
            venue = result["Venue"]

            if suburb in postcodes:
                postcode = postcodes[suburb]
            else:
                postcode = get_postcode(suburb)
                postcodes[suburb] = postcode

            if postcode is None:
                suburb, venue = venue, suburb
                if suburb in postcodes:
                    postcode = postcodes[suburb]
                else:
                    postcode = get_postcode(suburb)
                    postcodes[suburb] = postcode

                if postcode is None:
                    logger.warning(f"Failed to find postcode for {suburb}")
                    continue

            utils.add_location(postcode, suburb)
            venue += f", {suburb} NSW {postcode}"
            venue = venue.strip()
            datetimes = [get_datetime(result)]
            case_dict = get_case_dict(postcode, suburb, venue, result, datetimes)
            utils.add_case(venue, case_dict, datetimes)


def get_postcode(suburb):
    postcode = None
    session = HTMLSession()
    query = suburb.replace("'", "")
    r = session.get(
        f"http://www.geonames.org/postalcode-search.html?q={query}&country=AU"
    )
    r.html.render()
    table = r.html.find("table.restable", first=True)

    if table is not None:
        trs = table.find("tr")

        for tr in trs[1:-1]:
            tds = tr.find("td")
            if len(tds) == 7 and tds[2].text.startswith("2"):
                postcode = tds[2].text
                break

    return postcode


def get_datetime(result):
    date = result["Date"]
    start_time, end_time = result["Time"].split(" to ")
    start = f"{date} {start_time}"
    end = f"{date} {end_time}"

    return {"start": parse_datetime(start), "end": parse_datetime(end)}


def parse_datetime(datetime):
    try:
        return dt.datetime.strptime(datetime, "%A %d %B %Y %I:%M%p").isoformat()
    except ValueError:
        return dt.datetime.strptime(datetime, "%A %d %B %Y %I.%M%p").isoformat()


def get_case_dict(postcode, suburb, venue, result, datetimes):
    return {
        "postcode": postcode,
        "suburb": suburb,
        "venue": venue,
        "latitude": float(result["Lat"]),
        "longitude": float(result["Lon"]),
        "dateTimes": datetimes,
        "action": result["Alert"],
        "isExpired": False,
    }


if __name__ == "__main__":
    main()
