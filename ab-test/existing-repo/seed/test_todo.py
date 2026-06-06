"""Existing test suite — must stay GREEN after your change (no regressions)."""
import pytest

from models import Task
from service import ValidationError, add, complete, remove
from storage import load, save


def test_add_increments_id():
    tasks = []
    t1 = add(tasks, "a")
    t2 = add(tasks, "b")
    assert (t1.id, t2.id) == (1, 2)
    assert len(tasks) == 2


def test_add_empty_title_raises():
    with pytest.raises(ValidationError):
        add([], "   ")


def test_complete_sets_done():
    tasks = []
    t = add(tasks, "x")
    complete(tasks, t.id)
    assert tasks[0].done is True


def test_complete_unknown_raises():
    with pytest.raises(ValidationError):
        complete([], 99)


def test_remove():
    tasks = []
    add(tasks, "x")
    t2 = add(tasks, "y")
    remove(tasks, t2.id)
    assert [t.title for t in tasks] == ["x"]


def test_storage_roundtrip(tmp_path):
    p = tmp_path / "t.json"
    tasks = []
    add(tasks, "a")
    t = add(tasks, "b")
    complete(tasks, t.id)
    save(str(p), tasks)
    loaded = load(str(p))
    assert [(x.id, x.title, x.done) for x in loaded] == [(1, "a", False), (2, "b", True)]


def test_load_missing_returns_empty(tmp_path):
    assert load(str(tmp_path / "nope.json")) == []
