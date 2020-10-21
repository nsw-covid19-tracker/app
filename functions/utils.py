import arrow
import hashlib

from firebase_admin import db


def add_location(postcode, suburb):
    locations_ref = db.reference("locations")
    location_ref = locations_ref.child(postcode)

    if location_ref.get() is None:
        location_ref.set({"suburb": suburb})
        logs_ref = db.reference("logs")
        logs_ref.update({"locationsUpdatedAt": int(arrow.utcnow().timestamp * 1000)})


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
        case_ref.update(
            {
                "dateTimes": result_datetimes,
                "isExpired": is_case_expired(result_datetimes),
            }
        )


def is_case_expired(datetimes):
    tmp_list = [arrow.get(x["end"] / 1000) for x in datetimes]
    last_datetime = sorted(tmp_list)[-1].shift(days=14)
    curr_datetime = arrow.utcnow()

    return last_datetime < curr_datetime
