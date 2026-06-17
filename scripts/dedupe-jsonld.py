#!/usr/bin/env python3
"""De-duplicate a report's `seo.json_ld`: keep ONLY conditional schemas.

head_custom.html always renders the 5 mandatory schemas (WebPage, Article, Person,
Organization, BreadcrumbList) + WebSite for every layout: default page. When a report's
seo.json_ld ALSO contains those, they render twice. This strips the mandatory/WebSite
nodes from seo.json_ld's @graph, leaving only conditional extras (FAQPage, ItemList,
Table, ...) that head_custom does not provide. Idempotent.

Usage: dedupe-jsonld.py <file.md> [...]
"""
import sys
import re
import json

MANDATORY = {"WebPage", "WebSite", "Article", "Person", "Organization", "BreadcrumbList"}


def _node_is_mandatory(node):
    t = node.get("@type") if isinstance(node, dict) else None
    if isinstance(t, str):
        return t in MANDATORY
    if isinstance(t, list):
        return any(x in MANDATORY for x in t)
    return False


def process(path):
    text = open(path, encoding="utf-8").read()
    if not text.startswith("---"):
        return "skip (no front matter)"
    end = text.find("\n---", 3)
    fm = text[3:end]

    # locate `  json_ld: |` block scalar and its indented body
    m = re.search(r"^(?P<ind>[ \t]*)json_ld:[ \t]*\|[ \t]*\n", fm, re.M)
    if not m:
        return "skip (no json_ld | block)"
    base_indent = len(m.group("ind"))
    body_start = m.end()
    lines = fm[body_start:].split("\n")
    block, consumed = [], 0
    for ln in lines:
        if ln.strip() == "":
            block.append(ln); consumed += 1; continue
        cur = len(ln) - len(ln.lstrip(" "))
        if cur <= base_indent:
            break
        block.append(ln); consumed += 1
    child_indent = min((len(b) - len(b.lstrip(" ")) for b in block if b.strip()),
                       default=base_indent + 2)
    json_text = "\n".join(b[child_indent:] if b.strip() else "" for b in block)
    data = json.loads(json_text)

    graph = data.get("@graph")
    if not isinstance(graph, list):
        return "skip (no @graph list)"
    kept = [n for n in graph if not _node_is_mandatory(n)]
    if len(kept) == len(graph):
        return "ok (already conditional-only)"
    data["@graph"] = kept

    new_json = json.dumps(data, ensure_ascii=False, indent=2)
    pad = " " * child_indent
    new_block = "\n".join((pad + l) if l else "" for l in new_json.split("\n"))

    # rebuild front matter: replace the old block lines with the new block
    consumed_text = "\n".join(lines[:consumed])
    new_fm = fm[:body_start] + new_block + fm[body_start + len(consumed_text):]
    new_text = "---" + new_fm + text[end:]
    # validate the rewritten JSON round-trips
    json.loads(new_json)
    open(path, "w", encoding="utf-8").write(new_text)
    return f"deduped ({len(graph)} -> {len(kept)} nodes; kept={[n.get('@type') for n in kept]})"


def main():
    n = 0
    for p in sys.argv[1:]:
        try:
            r = process(p)
            print(f"  {p}: {r}")
            if r.startswith("deduped"):
                n += 1
        except Exception as e:  # noqa
            print(f"  ERROR {p}: {e}", file=sys.stderr)
    print(f"dedupe-jsonld: {n} file(s) changed")


if __name__ == "__main__":
    main()
