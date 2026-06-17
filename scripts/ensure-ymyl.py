#!/usr/bin/env python3
"""Ensure YMYL front-matter fields (lastReviewed / reviewedBy) on published Jekyll pages.

Idempotent: only inserts fields that are missing. Operates only on files that already
have a YAML front-matter block (first line '---'). Build-excluded Extractor raw-data
docs are intentionally NOT handled here — they have no front matter and are consumed by
update.sh via `head -1` / `head -20`, so injecting front matter would corrupt the
Qdrant title/embedding pipeline.

Usage: ensure-ymyl.py <file.md> [<file.md> ...]
"""
import sys
import re

REVIEWED_BY = "全球貿易情報 AI 編輯"
DEFAULT_DATE = "2026-06-17"


def process(path):
    with open(path, encoding="utf-8") as fh:
        text = fh.read()
    if not text.startswith("---\n"):
        return False  # no front matter -> skip (not a published page)
    end = text.find("\n---", 4)
    if end == -1:
        return False
    fm = text[4:end]  # front-matter body (between the --- fences)
    rest = text[end:]

    has_reviewed = re.search(r"^\s*lastReviewed\s*:", fm, re.M)
    has_by = re.search(r"^\s*reviewedBy\s*:", fm, re.M)
    if has_reviewed and has_by:
        return False  # already complete

    # derive review date from existing last_modified_at / date if present
    m = re.search(r"^last_modified_at\s*:\s*['\"]?(\d{4}-\d{2}-\d{2})", fm, re.M) or \
        re.search(r"^date\s*:\s*['\"]?(\d{4}-\d{2}-\d{2})", fm, re.M)
    review_date = m.group(1) if m else DEFAULT_DATE

    additions = []
    if not has_reviewed:
        additions.append(f"lastReviewed: '{review_date}'")
    if not has_by:
        additions.append(f"reviewedBy: '{REVIEWED_BY}'")

    new_fm = fm.rstrip("\n") + "\n" + "\n".join(additions) + "\n"
    with open(path, "w", encoding="utf-8") as fh:
        fh.write("---\n" + new_fm + rest)
    return True


def main():
    changed = 0
    for p in sys.argv[1:]:
        try:
            if process(p):
                changed += 1
                print(f"  + {p}")
        except Exception as e:  # noqa
            print(f"  ! {p}: {e}", file=sys.stderr)
    print(f"ensure-ymyl: {changed} file(s) updated")


if __name__ == "__main__":
    main()
