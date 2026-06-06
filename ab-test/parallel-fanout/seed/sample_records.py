"""Edge-case sample data shared by every formatter's tests. Read-only.

Each row deliberately exercises a different escaping/alignment hazard:
comma, embedded double-quote, pipe, HTML specials, tab, big-amount alignment.
"""
from record import Record

SAMPLES = [
    Record("Coffee, large", 4.5, "2026-01-02", "food", ("morning", "cash")),
    Record('Quote "special"', 1200.0, "2026-01-15", "equipment", ()),
    Record("Pipe | char", 33.33, "2026-02-01", "misc", ("a|b",)),
    Record("HTML <b>&</b>", 7.0, "2026-02-14", "web", ("<x>",)),
    Record("Tab\tinside", 999999.99, "2026-03-03", "big", ()),
    Record("plain", 0.5, "2026-03-30", "food", ()),
]
