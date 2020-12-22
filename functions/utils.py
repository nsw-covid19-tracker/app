import arrow
import hashlib

from collections import defaultdict
from firebase_admin import db


def load_suburbs_dict():
    suburbs = defaultdict(dict)
    with open("data/au_postcodes.csv") as f:
        for line in f:
            parts = line.strip().split(",")
            postcode, suburb, _, state, latitude, longitude, _ = parts

            if postcode.startswith("2") and state.lower() == "nsw":
                suburbs[suburb][postcode] = (float(latitude), float(longitude))

    return suburbs


def add_suburb(suburbs_dict, postcode, suburb):
    postcodes = suburbs_dict[suburb]
    lat_lng = postcodes.get(postcode)

    if lat_lng is None:
        postcode, lat_lng = list(postcodes.items())[0]

    m = hashlib.sha384()
    m.update(postcode.encode("utf-8"))
    m.update(suburb.encode("utf-8"))
    key = m.hexdigest()

    suburbs_ref = db.reference("suburbs")
    suburb_ref = suburbs_ref.child(key)

    if suburb_ref.get() is None:
        suburb_ref.set(
            {
                "postcode": postcode,
                "name": suburb,
                "latitude": lat_lng[0],
                "longitude": lat_lng[1],
            }
        )
        logs_ref = db.reference("logs")
        logs_ref.update({"suburbsUpdatedAt": int(arrow.utcnow().timestamp * 1000)})

    return postcode


def add_case(case_dict, datetimes):
    m = hashlib.sha384()
    m.update(case_dict["venue"].encode("utf-8"))
    m.update(str(case_dict["latitude"]).encode("utf-8"))
    m.update(str(case_dict["longitude"]).encode("utf-8"))
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
        result_datetimes = [{"start": x[0], "end": x[1]} for x in new_datetimes]
        data = {
            "dateTimes": result_datetimes,
            "isExpired": snapshot["isExpired"] and case_dict["isExpired"],
        }

        if "postcode" not in snapshot:
            data["postcode"] = case_dict["postcode"]

        case_ref.update(data)

    return key
