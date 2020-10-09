from firebase_admin import db


def set_location(postcode, suburb):
    locations_ref = db.reference("locations")
    location_ref = locations_ref.child(postcode)

    if location_ref.get() is None:
        location_ref.set({"suburb": suburb})
