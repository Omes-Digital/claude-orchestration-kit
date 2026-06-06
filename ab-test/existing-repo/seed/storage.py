"""JSON persistence. Tasks are (de)serialized field-by-field here — so any new
field on Task must be added in BOTH _to_dict and _from_dict to survive a round-trip."""
import json
import os

from models import Task


def _to_dict(t: Task) -> dict:
    return {"id": t.id, "title": t.title, "done": t.done}


def _from_dict(d: dict) -> Task:
    return Task(id=d["id"], title=d["title"], done=d.get("done", False))


def load(path: str) -> list:
    if not os.path.exists(path):
        return []
    with open(path) as f:
        raw = f.read().strip()
    if not raw:
        return []
    return [_from_dict(d) for d in json.loads(raw)]


def save(path: str, tasks: list) -> None:
    with open(path, "w") as f:
        json.dump([_to_dict(t) for t in tasks], f, indent=2)
