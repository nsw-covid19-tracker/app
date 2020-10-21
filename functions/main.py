import arrow
import firebase_admin
import json
import re
import requests
import sys

from firebase_admin import credentials, db
from loguru import logger

import utils

cred = credentials.Certificate("keyfile.json")
firebase_admin.initialize_app(
    cred, {"databaseURL": f"https://{cred.project_id}.firebaseio.com"}
)


def main(data, context):
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

    logs_ref = db.reference("logs")
    logs_ref.update({"casesUpdatedAt": int(arrow.utcnow().timestamp * 1000)})


def get_datetimes(result):
    datetimes = []
    dates = split_datetimes(result["Date"])
    times = split_datetimes(result["Time"])

    for i in range(len(dates)):
        if i < len(times):
            time = times[i]
        else:
            time = times[0]

        date = dates[i].replace("-", "to").strip()
        if " to " in date:
            start_date, end_date = [x.strip() for x in date.split(" to ")]
        else:
            start_date = end_date = date

        time = time.replace("-", " - ").replace("-", "to").strip()
        if time.lower() == "all day":
            start = parse_datetime(start_date).floor("day")
            end = parse_datetime(end_date).ceil("day")
        else:
            start_time, end_time = [x.strip() for x in time.split(" to ")]
            start = parse_datetime(f"{start_date} {start_time}")
            end = parse_datetime(f"{end_date} {end_time}")

        datetimes.append(
            {
                "start": datetime_milliseconds(start),
                "end": datetime_milliseconds(end),
            }
        )

    return datetimes


def split_datetimes(datetimes):
    return [
        x.strip() for x in datetimes.replace(",", ";").replace("and", ";").split(";")
    ]


def parse_datetime(datetime_str):
    datetime = None
    datetime_str = datetime_str.replace("Setpember", "September")
    formats = [
        "dddd D MMMM YYYY h:mmA",
        "dddd D MMMM YYYY h.mmA",
        "dddd D MMMM YYYY hA",
        "dddd D MMMM h:mmA",
        "dddd D MMMM hA",
        "dddd D MMMM",
        "D MMMM",
    ]

    for datetime_format in formats:
        try:
            datetime = arrow.get(datetime_str, datetime_format)
            break
        except ValueError:
            continue

    if datetime is None:
        raise ValueError(f"Failed to parse {datetime_str}")

    return datetime.replace(year=2020)


def datetime_milliseconds(datetime):
    return int(datetime.timestamp * 1000)


if __name__ == "__main__":
    main("data", "context")
