#!/usr/bin/env python3
"""Convert a report's `seo.json_ld` YAML *mapping* into a `| ` block scalar of valid JSON.

head_custom.html renders the schema via `{{ page.seo.json_ld }}` (no jsonify filter),
so json_ld MUST be a literal JSON *string* (YAML `|` block scalar). When it is a YAML
mapping, Liquid emits a Ruby-hash string (`=>`) → invalid JSON-LD in production.
This standardises the mapping form onto the working `|` form. Idempotent.

Usage: fix-jsonld-blockscalar.py <file.md> [...]
"""
import sys
import re
import json
import yaml


def convert(path):
    text = open(path, encoding="utf-8").read()
    if not text.startswith("---"):
        return False
    m = re.match(r"^---\n(.*?)\n---", text, re.S)
    if not m:
        return False
    fm_text = m.group(1)

    # locate the `  json_ld:` line (mapping form = nothing meaningful after the colon)
    lines = fm_text.split("\n")
    jl = None
    for i, ln in enumerate(lines):
        mm = re.match(r"^(\s*)json_ld:\s*(\S?.*)$", ln)
        if mm:
            jl = (i, len(mm.group(1)), mm.group(2).strip())
            break
    if jl is None:
        return False
    idx, indent, after = jl
    if after in ("|", "|-", ">", ">-") or after.startswith("|"):
        return False  # already a block scalar

    # gather the indented child block (indent strictly greater than json_ld:'s)
    body = []
    j = idx + 1
    while j < len(lines):
        ln = lines[j]
        if ln.strip() == "":
            body.append(ln)
            j += 1
            continue
        cur = len(ln) - len(ln.lstrip(" "))
        if cur <= indent:
            break
        body.append(ln)
        j += 1
    if not body:
        return False

    # dedent the child block and parse as YAML mapping
    child_indent = min(
        (len(b) - len(b.lstrip(" ")) for b in body if b.strip()), default=indent + 2
    )
    dedented = "\n".join(b[child_indent:] if b.strip() else "" for b in body)
    data = yaml.safe_load(dedented)
    if not isinstance(data, (dict, list)):
        return False

    # emit json_ld as a `|` block scalar of pretty JSON
    json_str = json.dumps(data, ensure_ascii=False, indent=2)
    pad = " " * (indent + 2)
    block = " " * indent + "json_ld: |\n" + "\n".join(
        (pad + l) if l else "" for l in json_str.split("\n")
    )
    new_lines = lines[:idx] + block.split("\n") + lines[j:]
    new_fm = "\n".join(new_lines)
    new_text = text[: m.start(1)] + new_fm + text[m.end(1):]

    with open(path, "w", encoding="utf-8") as fh:
        fh.write(new_text)
    return True


def main():
    n = 0
    for p in sys.argv[1:]:
        try:
            if convert(p):
                n += 1
                print(f"  converted: {p}")
            else:
                print(f"  skipped (already block scalar / no mapping): {p}")
        except Exception as e:  # noqa
            print(f"  ERROR {p}: {e}", file=sys.stderr)
    print(f"fix-jsonld-blockscalar: {n} file(s) converted")


if __name__ == "__main__":
    main()
