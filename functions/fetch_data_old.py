import datetime as dt
import firebase_admin
import hashlib
import re
import requests
import sys

from firebase_admin import credentials, db
from loguru import logger

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
            if not record["Address"]:
                continue

            case_loc = record["Location"]
            suburb = case_loc.split(":")[0]
            postcode = re.search(r"\d{4}", record["Address"])

            if postcode is None:
                continue

            postcode = postcode[0]
            set_location(postcode, suburb)
            set_case(postcode, suburb, case_loc, record)

        url = base_url + result["_links"]["next"]
        page += 1


def set_location(postcode, suburb):
    locations_ref = db.reference("locations")
    location_ref = locations_ref.child(postcode)

    if location_ref.get() is None:
        location_ref.set({"suburb": suburb})


def set_case(postcode, suburb, case_loc, record):
    datetimes = get_datetimes(case_loc, record)
    case_dict = {
        "postcode": postcode,
        "suburb": suburb,
        "location": case_loc,
        "latitude": float(record["Latitude"]),
        "longitude": float(record["Longitude"]),
        "dateTimes": datetimes,
        "action": record["Action"],
        "isExpired": record["Status"].lower() == "expired",
    }

    m = hashlib.sha384()
    m.update(case_loc.encode("utf-8"))
    key = m.hexdigest()

    cases_ref = db.reference("cases")
    case_ref = cases_ref.child(key)
    snapshot = case_ref.get()

    if snapshot is None:
        case_ref.set(case_dict)
    else:
        old_datetimes = set((x["start"], x["end"]) for x in snapshot["dateTimes"])
        new_datetimes = set((x["start"], x["end"]) for x in datetimes)
        new_datetimes.update(old_datetimes)
        case_ref.update(
            {"dateTimes": [{"start": x[0], "end": x[1]} for x in new_datetimes]}
        )


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
                {"start": start_datetime.isoformat(), "end": end_datetime.isoformat()}
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
