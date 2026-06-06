"""Command-line interface. Parses args, calls the service, renders output,
and maps ValidationError to a non-zero exit code with a stderr message."""
import argparse
import sys

from service import ValidationError, add, complete, remove
from storage import load, save

DEFAULT_PATH = "tasks.json"


def format_task(t) -> str:
    mark = "x" if t.done else " "
    return f"[{mark}] {t.id}: {t.title}"


def main(argv=None) -> int:
    p = argparse.ArgumentParser(prog="todo")
    p.add_argument("--file", default=DEFAULT_PATH)
    sub = p.add_subparsers(dest="cmd", required=True)
    a = sub.add_parser("add")
    a.add_argument("title")
    c = sub.add_parser("complete")
    c.add_argument("id", type=int)
    r = sub.add_parser("remove")
    r.add_argument("id", type=int)
    sub.add_parser("list")

    args = p.parse_args(argv)
    tasks = load(args.file)
    try:
        if args.cmd == "add":
            t = add(tasks, args.title)
            save(args.file, tasks)
            print(f"added {t.id}: {t.title}")
        elif args.cmd == "complete":
            t = complete(tasks, args.id)
            save(args.file, tasks)
            print(f"completed {t.id}")
        elif args.cmd == "remove":
            t = remove(tasks, args.id)
            save(args.file, tasks)
            print(f"removed {t.id}")
        elif args.cmd == "list":
            for t in tasks:
                print(format_task(t))
    except ValidationError as e:
        print(f"error: {e}", file=sys.stderr)
        return 1
    return 0
