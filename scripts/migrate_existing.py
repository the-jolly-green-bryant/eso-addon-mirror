#!/usr/bin/env python3
"""Move the current Bethesda snapshot into stable-ID archive shards."""

from __future__ import annotations

import argparse
import json
import shutil
from pathlib import Path

from archive_common import (
    SCHEMA_VERSION,
    archive_path,
    archive_repository,
    author_from_tree,
    canonical_id,
    shard_for,
    write_json,
    write_unified_catalog,
)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument("--shard-root", type=Path, required=True)
    args = parser.parse_args()
    root = args.root.resolve()
    shard_root = args.shard_root.resolve()
    old = json.loads((root / "catalog.json").read_text(encoding="utf-8"))
    migrated: dict[str, dict[str, object]] = {}

    for source_id, old_record in sorted(old["addons"].items()):
        source_path = root / old_record["path"]
        if not source_path.is_dir():
            raise RuntimeError(f"Missing source tree for {source_id}: {source_path}")
        identifier = canonical_id("bethesda", source_id)
        author = author_from_tree(source_path)
        title = old_record.get("title") or source_id
        shard = shard_for(identifier)
        relative_path = archive_path(author, title, source_id)
        destination = shard_root / shard / relative_path
        if destination.exists():
            shutil.rmtree(destination)
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copytree(source_path, destination)
        record: dict[str, object] = {
            "canonical_id": identifier,
            "content_id": source_id,
            "source": "bethesda",
            "source_id": source_id,
            "platform": "console",
            "title": title,
            "author": author,
            "published": old_record.get("published", True),
            "deleted": old_record.get("deleted", False),
            "fingerprint": old_record.get("fingerprint"),
            "source_url": old_record.get("source"),
            "archive_repository": archive_repository(shard),
            "archive_path": relative_path,
            "shard": shard,
            "archived": True,
        }
        if old_record.get("deleted_at"):
            record["deleted_at"] = old_record["deleted_at"]
        write_json(destination / "addon.json", record)
        migrated[identifier] = record

    write_json(
        root / "catalogs" / "bethesda.json",
        {"schema": SCHEMA_VERSION, "source": "bethesda", "addons": migrated},
    )
    write_unified_catalog(root)
    print(f"Migrated {len(migrated)} Bethesda add-ons into {16} shards")


if __name__ == "__main__":
    main()
