# telegram_init_data.py
# Phase 1.2: Minimal parser to prevent import errors

def parse(init_data_string: str):
    """
    Temporary placeholder for Phase 1.2.
    Simply returns a dummy user object so the backend doesn't crash.
    """
    # In Phase 2.0, we will add real hmac-sha256 verification here.
    return {
        "user": {
            "id": 0,
            "first_name": "Nexus",
            "last_name": "Sovereign",
            "username": "nexus_user"
        },
        "auth_date": 0,
        "hash": "placeholder"
    }