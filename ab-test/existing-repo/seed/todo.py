#!/usr/bin/env python3
"""Entry point. Usage: python todo.py [--file PATH] {add,complete,remove,list} ..."""
import sys

from cli import main

if __name__ == "__main__":
    sys.exit(main())
