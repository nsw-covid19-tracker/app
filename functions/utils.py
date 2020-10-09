import hashlib

from firebase_admin import db


def add_location(postcode, suburb):
    locations_ref = db.reference("locations")
    location_ref = locations_ref.child(postcode)

    if location_ref.get() is None:
        location_ref.set({"suburb": suburb})


def add_case(venue, case_dict, datetimes):
    m = hashlib.sha384()
    m.update(venue.encode("utf-8"))
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
