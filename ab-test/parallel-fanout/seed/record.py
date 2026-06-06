"""Shared, read-only record type for the formatter fan-out task. Do NOT modify."""
from dataclasses import dataclass


@dataclass(frozen=True)
class Record:
    name: str
    amount: float          # currency amount; format to 2 decimals where the spec says so
    date: str              # ISO 8601 "YYYY-MM-DD"
    category: str
    tags: tuple[str, ...] = ()
