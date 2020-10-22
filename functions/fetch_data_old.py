import datetime as dt
import firebase_admin
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

    suburbs_dict = utils.load_suburbs_dict()
    base_url = "https://data.nsw.gov.au/data"
    url = (
        "https://data.nsw.gov.au/data/api/3/action/datastore_search?"
        "resource_id=5200e552-0afb-4bde-b20f-f8dd4feff3d7&limit=100"
    )
    page = 1

    while True:
        logger.info(f"Fetching page {page} data")
        r = requests.get(url)
        result = r.json()["result"]
        records = result["records"]

        if not records:
            break

        for record in records:
            address = record["Address"]
            if not address:
                continue

            venue = record["Location"]
            suburb = venue.split(":")[0]
            postcode = re.search(r"\d{4}", address)

            if suburb == "Brighton Le Sands":
                suburb = "Brighton-Le-Sands"
            elif suburb == "Cambelltown":
                suburb = "Campbelltown"
            elif suburb == "Rouse Hill Town Centre, including Target":
                suburb = "Rouse Hill"
            elif suburb == "Rushcutter's Bay":
                suburb = "Rushcutters Bay"

            if postcode is None:
                logger.warning(f"Failed to find postcode in {address}")
            else:
                postcode = postcode[0]
                postcode = utils.add_suburb(suburbs_dict, postcode, suburb)

            datetimes = get_datetimes(venue, record)
            case_dict = {
                "postcode": postcode,
                "suburb": suburb,
                "venue": venue,
                "address": address,
                "latitude": float(record["Latitude"]),
                "longitude": float(record["Longitude"]),
                "dateTimes": datetimes,
                "action": record["Action"],
                "isExpired": record["Status"].lower() == "expired",
            }
            utils.add_case(case_dict, datetimes)

        url = base_url + result["_links"]["next"]
        page += 1


def get_datetimes(case_loc, record):
    datetimes = []
    for i in range(1, 16):
        if case_loc == "Mount Pritchard: Mounties, 101 Meadows Road" and (
            i == 11 or i == 12 or i == 14 or i == 15
        ):
            continue

        start_date = end_date = record.get(f"Date_{i}")
        if start_date is not None:
            start_datetime = parse_date(start_date)
            end_datetime = parse_date(end_date)

            if case_loc == "Mount Pritchard: Mounties, 101 Meadows Road" and i == 10:
                start_time = record["Date_11"]
                end_time = record["Date_12"]
            elif case_loc == "Mount Pritchard: Mounties, 101 Meadows Road" and i == 13:
                start_time = record["Date_14"]
                end_time = record["Date_15"]
            else:
                start_time = record.get(f"Time_start_{i}")
                end_time = record.get(f"Time_end_{i}")

            if start_time is not None:
                start_datetime = parse_datetime(start_datetime, start_time)

            if end_time is not None:
                end_datetime = parse_datetime(end_datetime, end_time)

            datetimes.append(
                {
                    "start": int(start_datetime.timestamp() * 1000),
                    "end": int(end_datetime.timestamp() * 1000),
                }
            )

    return datetimes


def parse_date(date):
    datetime = None
    try:
        datetime = dt.datetime.strptime(date, "%A %d %B")
    except ValueError:
        try:
            datetime = dt.datetime.strptime(date, "%d-%m")
        except ValueError:
            datetime = dt.datetime.strptime(date, "%d-%b")

    return datetime.replace(year=2020)


def parse_datetime(date, time):
    datetime = date
    try:
        hour, minute = map(int, time.split(":"))
        datetime = date.replace(hour=hour, minute=minute)
    except ValueError:
        pass

    return datetime


if __name__ == "__main__":
    main()
