import arrow
import datetime as dt
import firebase_admin
import json
import re
import requests
import sys

from firebase_admin import credentials
from loguru import logger

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

    for key in data:
        for result in data[key]:
            address = result["Address"]
            suburb = result["Suburb"]
            postcode = re.search(r"\d{4}", address.split(", ")[-1])

            if postcode is None:
                logger.warning(f"Failed to find postcode in {address}")
            else:
                postcode = postcode[0]
                utils.add_location(postcode, suburb)

            datetimes = get_datetimes(result)
            case_dict = {
                "postcode": postcode,
                "suburb": suburb,
                "venue": f"{suburb}: {result['Venue']}",
                "address": address,
                "latitude": float(result["Lat"]),
                "longitude": float(result["Lon"]),
                "dateTimes": datetimes,
                "action": result["Alert"],
                "isExpired": utils.is_case_expired(datetimes),
            }
            utils.add_case(case_dict, datetimes)


def get_datetimes(result):
    datetimes = []
    dates = result["Date"].replace(", ", "; ").replace(" and ", "; ").split("; ")
    times = result["Time"].replace(", ", "; ").replace(" and ", "; ").split("; ")

    for i in range(len(dates)):
        date = dates[i].replace(" - ", " to ").strip()
        if i < len(times):
            time = times[i]
        else:
            time = times[0]

        time = time.replace(" - ", " to ").strip()

        if " to " in date:
            start_date, end_date = date.split(" to ")
        else:
            start_date = end_date = date

        if time.lower() == "all day":
            date_format = "dddd D MMMM"
            start = arrow.get(start_date, date_format).replace(year=2020).floor("day")
            end = arrow.get(end_date, date_format).replace(year=2020).ceil("day")
            datetimes.append(
                {"start": int(start.timestamp * 1000), "end": int(end.timestamp * 1000)}
            )
        else:
            start_time, end_time = [x.strip() for x in time.split(" to ")]
            start = f"{start_date} {start_time}"
            end = f"{end_date} {end_time}"

            datetimes.append(
                {"start": parse_datetime(start), "end": parse_datetime(end)}
            )

    return datetimes


def parse_datetime(datetime_str):
    formats = [
        "%A %d %B %Y %I:%M%p",
        "%A %d %B %I:%M%p",
        "%A %d %B %Y %I%p",
        "%A %d %B %Y %I.%M%p",
        "%A %d %B %I%p",
    ]
    datetime = None

    for datetime_format in formats:
        try:
            datetime = dt.datetime.strptime(datetime_str, datetime_format)
        except ValueError:
            continue

    if datetime is None:
        raise ValueError(f"Failed to parse {datetime_str}")

    return int(datetime.replace(year=2020).timestamp() * 1000)


if __name__ == "__main__":
    main()
