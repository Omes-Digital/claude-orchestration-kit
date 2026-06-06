"""Domain model. A Task is the core entity the whole app revolves around."""
from dataclasses import dataclass


@dataclass
class Task:
    id: int
    title: str
    done: bool = False

    def mark_done(self) -> None:
        self.done = True
