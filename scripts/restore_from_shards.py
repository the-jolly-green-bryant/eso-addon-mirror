#!/usr/bin/env python3
"""Restore the current shard snapshots into the canonical repository."""

from __future__ import annotations

import argparse
import json
import shutil
from pathlib import Path
from typing import Any

from archive_common import SCHEMA_VERSION, write_json, write_unified_catalog

MAIN_REPOSITORY = "the-jolly-green-bryant/eso-addon-mirror"


def restore_catalog(root: Path, shard_root: Path, source: str) -> int:
    catalog_path = root / "catalogs" / f"{source}.json"
    body = json.loads(catalog_path.read_text(encoding="utf-8"))
    addons: dict[str, dict[str, Any]] = body["addons"]
    restored = 0
    for record in addons.values():
        shard = record.get("shard")
        archive_path = record.get("archive_path")
        if not shard or not archive_path:
            raise RuntimeError(f"Incomplete {source} archive record: {record!r}")
        source_path = shard_root / str(shard) / str(archive_path)
        destination = root / str(archive_path)
        if not source_path.is_dir():
            raise RuntimeError(f"Missing shard snapshot: {source_path}")
        if destination.exists():
            shutil.rmtree(destination)
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copytree(source_path, destination)
        record["archive_repository"] = MAIN_REPOSITORY
        record.pop("shard", None)
        write_json(destination / "addon.json", record)
        restored += 1

    write_json(
        catalog_path,
        {"schema": SCHEMA_VERSION, "source": source, "addons": addons},
    )
    return restored


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument("--shard-root", type=Path, required=True)
    args = parser.parse_args()
    root = args.root.resolve()
    shard_root = args.shard_root.resolve()
    restored = sum(
        restore_catalog(root, shard_root, source) for source in ("bethesda", "esoui")
    )
    write_unified_catalog(root)
    print(f"Restored {restored} add-ons into {MAIN_REPOSITORY}")


if __name__ == "__main__":
    main()
