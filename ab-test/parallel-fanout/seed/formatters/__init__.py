"""Formatters package. Each fmt_<name>.py is an INDEPENDENT unit implemented by the task.

Seed ships this empty on purpose — the six formatter modules and their tests are what
each A/B arm builds. No formatter depends on another; they share only the read-only
`record.Record` type and `sample_records.SAMPLES`.
"""
