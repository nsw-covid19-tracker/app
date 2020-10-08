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
    locations_ref = db.reference("locations")
    cases_ref = db.reference("cases")
    new_loc_count = new_case_count = updated_count = 0

    while True:
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
            location_ref = locations_ref.child(postcode)

            if location_ref.get() is None:
                new_loc_count += 1
                location_ref.set({"suburb": suburb})

            case_dict = {
                "postcode": postcode,
                "suburb": suburb,
                "location": case_loc,
                "latitude": float(record["Latitude"]),
                "longitude": float(record["Longitude"]),
                "dates": record["Dates"],
                "action": record["Action"],
                "isExpired": record["Status"].lower() == "expired",
            }

            m = hashlib.sha384()
            m.update(case_loc.encode("utf-8"))
            key = m.hexdigest()
            case_ref = cases_ref.child(key)
            snapshot = case_ref.get()

            if snapshot is None:
                new_case_count += 1
                case_ref.set(case_dict)
            elif (
                snapshot["dates"] != case_dict["dates"]
                or snapshot["isExpired"] != case_dict["isExpired"]
            ):
                updated_count += 1
                case_ref.update(case_dict)
                logger.info(f"Updating {case_loc}")

        url = base_url + result["_links"]["next"]

    logger.info(f"Added {new_loc_count} suburb(s)")
    logger.info(f"Added {new_case_count} cases")
    logger.info(f"Updated {updated_count} cases")


if __name__ == "__main__":
    main()
