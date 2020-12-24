import arrow
import firebase_admin
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

    suburbs_dict = utils.load_suburbs_dict()
    r = requests.get(
        "https://data.nsw.gov.au/data/dataset/"
        "0a52e6c1-bc0b-48af-8b45-d791a6d8e289/resource/"
        "f3a28eed-8c2a-437b-8ac1-2dab3cf760f9/download/venue-data.json"
    )
    json = r.json()
    data = json["data"]
    data_updated_at = arrow.get(json["date"], "YYYY-MM-DD")
    updated_keys = set()

    for key in data:
        for result in data[key]:
            try:
                address = result["Address"]
            except KeyError:
                address = result["Adress"]

            venue = result["Venue"]
            suburb = result["Suburb"]
            postcode = re.search(r"\d{4}", address.split(", ")[-1])

            if suburb == "Avalon":
                suburb = "Avalon Beach"
            elif venue == "Warriewood Square" and suburb == "Nails":
                suburb = "Warriewood"

            if postcode is not None:
                postcode = postcode[0]
            else:
                postcode = get_postcode_from_dict(suburb, suburbs_dict)
                if postcode is None:
                    venue, suburb = suburb, venue
                    postcode = get_postcode_from_dict(suburb, suburbs_dict)

                    if postcode is None:
                        venue, suburb = suburb, venue
                        logger.warning(
                            f"Failed to find postcode in '{address}' and "
                            f"failed to retrieve postcode for '{suburb}'"
                        )

            if postcode is not None:
                postcode = utils.add_suburb(suburbs_dict, postcode, suburb)

            datetimes = get_datetimes(result)
            try:
                latitude = float(result["Lat"])
            except KeyError:
                latitude = float(result["Latitude"])
            try:
                longitude = float(result["Lon"])
            except KeyError:
                longitude = float(result["Longitude"])

            case_dict = {
                "postcode": postcode,
                "suburb": suburb,
                "venue": f"{suburb}: {venue}",
                "address": address,
                "latitude": latitude,
                "longitude": longitude,
                "dateTimes": datetimes,
                "action": result["Alert"],
                "isExpired": False,
            }
            case_key = utils.add_case(case_dict, datetimes)
            updated_keys.add(case_key)

    update_expired_cases(updated_keys)
    logs_ref = db.reference("logs")
    logs_ref.update(
        {
            "dataUpdatedAt": datetime_milliseconds(data_updated_at),
            "casesUpdatedAt": datetime_milliseconds(arrow.utcnow()),
        }
    )


def get_postcode_from_dict(suburb, suburbs_dict):
    postcode = None
    postcodes = suburbs_dict.get(suburb)

    if postcodes is not None:
        postcode = list(postcodes.keys())[0]

    return postcode


def get_datetimes(result):
    datetimes = []
    dates = split_datetimes(result["Date"], is_date=True)

    if result["Time"] == "Strength and Conditioning Class":
        times = [""]
    else:
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

        time = time.replace("-", " - ").replace("-", "to").strip().lower()
        if "all day" in time or time == "":
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


def split_datetimes(datetimes, is_date=False):
    if is_date:
        datetimes = datetimes.replace("December2020", "December 2020")
        for day in [
            "Monday",
            "Tuesday",
            "Wednesday",
            "Thursday",
            "Friday",
            "Saturday",
            "Sunday",
        ]:
            datetimes = datetimes.replace(f"{day},", day)

    return [
        re.sub(r"\s+", " ", x.strip())
        for x in datetimes.replace("<br/>", ";")
        .replace(",", ";")
        .replace("and", ";")
        .split(";")
    ]


def parse_datetime(datetime_str):
    datetime = None
    datetime_str = datetime_str.replace("Setpember", "September")
    formats = [
        "dddd D MMMM YYYY h:mmA",
        "dddd D MMMM YYYY h.mmA",
        "dddd D MMMM YYYY hA",
        "dddd D MMM YYYY h:mmA",
        "dddd D MMM YYYY h.mmA",
        "dddd D MMM YYYY hA",
        "dddd D MMMM h:mmA",
        "dddd D MMMM h.mmA",
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


def update_expired_cases(updated_keys):
    ref = db.reference("cases")
    snapshot = ref.order_by_child("isExpired").equal_to(False).get()

    for key in snapshot:
        if key not in updated_keys:
            ref.child(key).update({"isExpired": True})


if __name__ == "__main__":
    main("data", "context")
