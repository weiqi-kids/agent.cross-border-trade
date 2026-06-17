#!/usr/bin/env python3
"""Validate JSON-LD <script> blocks in a rendered HTML file.

Checks that every <script type="application/ld+json"> block parses as valid JSON,
and (optionally) that a set of required schema @types is present across all blocks.

Usage:
    check-jsonld.py <file.html> [RequiredType ...]

Exit code 0 = all blocks valid AND all required types present.
Exit code 1 = invalid JSON in a block, or a required type missing, or no block found
              when required types were requested.
Prints a one-line summary to stdout (machine-friendly: "OK ..." or "FAIL ...").
"""
import sys
import re
import json

SCRIPT_RE = re.compile(
    r'<script[^>]*type=["\']application/ld\+json["\'][^>]*>(.*?)</script>',
    re.S | re.I,
)


def collect_types(node, out):
    if isinstance(node, dict):
        t = node.get("@type")
        if isinstance(t, str):
            out.add(t)
        elif isinstance(t, list):
            out.update(x for x in t if isinstance(x, str))
        for v in node.values():
            collect_types(v, out)
    elif isinstance(node, list):
        for v in node:
            collect_types(v, out)


def main():
    if len(sys.argv) < 2:
        print("FAIL usage: check-jsonld.py <file.html> [RequiredType ...]")
        return 1
    path = sys.argv[1]
    required = set(sys.argv[2:])

    try:
        html = open(path, encoding="utf-8").read()
    except Exception as e:  # noqa
        print(f"FAIL cannot read {path}: {e}")
        return 1

    blocks = SCRIPT_RE.findall(html)
    if not blocks:
        if required:
            print(f"FAIL {path}: no application/ld+json block found")
            return 1
        print(f"OK {path}: no ld+json (none required)")
        return 0

    found = set()
    for i, raw in enumerate(blocks):
        try:
            data = json.loads(raw)
        except Exception as e:  # noqa
            print(f"FAIL {path}: ld+json block #{i} is invalid JSON: {e}")
            return 1
        collect_types(data, found)

    missing = required - found
    if missing:
        print(f"FAIL {path}: missing @types {sorted(missing)} (found {sorted(found)})")
        return 1

    print(f"OK {path}: {len(blocks)} valid block(s), @types={sorted(found)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
