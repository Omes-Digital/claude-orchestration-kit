"""Business logic. Pure functions over a list[Task] — no I/O, no printing."""
from models import Task


class ValidationError(Exception):
    """Raised on invalid input; the CLI maps this to a non-zero exit + stderr message."""


def add(tasks: list, title: str) -> Task:
    title = (title or "").strip()
    if not title:
        raise ValidationError("title must not be empty")
    next_id = max((t.id for t in tasks), default=0) + 1
    task = Task(id=next_id, title=title)
    tasks.append(task)
    return task


def complete(tasks: list, task_id: int) -> Task:
    for t in tasks:
        if t.id == task_id:
            t.mark_done()
            return t
    raise ValidationError(f"no task with id {task_id}")


def remove(tasks: list, task_id: int) -> Task:
    for i, t in enumerate(tasks):
        if t.id == task_id:
            return tasks.pop(i)
    raise ValidationError(f"no task with id {task_id}")
