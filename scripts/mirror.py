#!/usr/bin/env python3
"""Synchronize Bethesda console add-ons into the canonical repository."""

from __future__ import annotations

import hashlib
import html
import json
import os
import shutil
import subprocess
import tempfile
from datetime import UTC, datetime
from pathlib import Path
from typing import Any

from archive_common import (
    SCHEMA_VERSION,
    archive_path,
    canonical_id,
    safe_extract as extract_zip,
    write_json,
    write_unified_catalog,
)

ROOT = Path(__file__).resolve().parents[1]
ADDONS = ROOT / "addons"
CATALOG = ROOT / "catalogs" / "bethesda.json"
CLI = os.environ.get("ESO_CLI", "ESOAddOnUploaderCli")
PAGE_SIZE = 50
MAX_UNPACKED_BYTES = int(os.environ.get("MAX_UNPACKED_BYTES", str(512 * 1024 * 1024)))
MAX_REPOSITORY_FILE_BYTES = 95 * 1024 * 1024
MAIN_REPOSITORY = "the-jolly-green-bryant/eso-addon-mirror"


def run(*args: str) -> None:
    subprocess.run(args, cwd=ROOT, check=True)


def read_catalog() -> dict[str, Any]:
    if not CATALOG.exists():
        return {"schema": SCHEMA_VERSION, "source": "bethesda", "addons": {}}
    data = json.loads(CATALOG.read_text(encoding="utf-8"))
    if data.get("schema") != SCHEMA_VERSION or not isinstance(data.get("addons"), dict):
        raise RuntimeError("catalogs/bethesda.json has an unsupported shape")
    return data


def list_page(page: int, destination: Path) -> dict[str, Any] | list[Any]:
    run(
        CLI,
        "list",
        "--all",
        "--page",
        str(page),
        "--page-size",
        str(PAGE_SIZE),
        "--output-json",
        str(destination),
        "--session",
        str(ROOT / ".session.json"),
    )
    return json.loads(destination.read_text(encoding="utf-8"))


def page_items(payload: dict[str, Any] | list[Any]) -> list[dict[str, Any]]:
    if isinstance(payload, list):
        return [item for item in payload if isinstance(item, dict)]
    for key in ("data", "addons", "results", "items"):
        value = payload.get(key)
        if isinstance(value, list):
            return [item for item in value if isinstance(item, dict)]
    for key in ("response", "platform"):
        value = payload.get(key)
        if isinstance(value, dict):
            try:
                return page_items(value)
            except RuntimeError:
                pass
    raise RuntimeError("Could not find the add-on list in CLI JSON output")


def addon_id(item: dict[str, Any]) -> str:
    for key in ("content_id", "contentId", "addon_id", "addonId", "id"):
        value = item.get(key)
        if isinstance(value, str) and len(value) == 36:
            return value.lower()
    raise RuntimeError(f"Add-on entry has no content UUID: {item!r}")


def title(item: dict[str, Any], fallback: str) -> str:
    for key in ("title", "name"):
        value = item.get(key)
        if isinstance(value, str) and value.strip():
            return html.unescape(value.strip())
    return fallback


def author(item: dict[str, Any], fallback: str = "Unknown") -> str:
    for key in ("author_displayname", "author_display_name", "author", "username"):
        value = item.get(key)
        if isinstance(value, str) and value.strip():
            return html.unescape(value.strip())
        if isinstance(value, dict):
            for nested in ("displayname", "display_name", "username", "name"):
                candidate = value.get(nested)
                if isinstance(candidate, str) and candidate.strip():
                    return html.unescape(candidate.strip())
    return fallback


def stable_fingerprint(item: dict[str, Any]) -> str:
    """Hash release metadata while ignoring counters and other noisy fields."""
    volatile = {
        "download_count",
        "downloads",
        "favorites",
        "rating",
        "ratings",
        "stats",
        "views",
    }

    def clean(value: Any) -> Any:
        if isinstance(value, dict):
            return {key: clean(nested) for key, nested in sorted(value.items()) if key not in volatile}
        if isinstance(value, list):
            return [clean(nested) for nested in value]
        return value

    encoded = json.dumps(clean(item), sort_keys=True, separators=(",", ":")).encode()
    return hashlib.sha256(encoded).hexdigest()


def safe_extract(archive: Path, destination: Path) -> None:
    extract_zip(archive, destination, MAX_UNPACKED_BYTES)


def selected_ids() -> set[str] | None:
    scope = os.environ.get("MIRROR_SCOPE", "all").lower()
    if scope == "all":
        return None
    if scope != "allowlist":
        raise RuntimeError("MIRROR_SCOPE must be 'all' or 'allowlist'")
    return {
        line.split("#", 1)[0].strip().lower()
        for line in (ROOT / "allowlist.txt").read_text(encoding="utf-8").splitlines()
        if line.split("#", 1)[0].strip()
    }


def existing_addon_path(identifier: str, old: dict[str, Any]) -> Path | None:
    recorded = old.get("archive_path")
    if isinstance(recorded, str) and (ROOT / recorded).is_dir():
        return ROOT / recorded
    matches = list(ADDONS.glob(f"*/*__{identifier}"))
    return matches[0] if matches else None


def addon_record(
    identifier: str,
    item: dict[str, Any],
    fingerprint: str,
    published: bool,
    old: dict[str, Any] | None = None,
) -> dict[str, Any]:
    name = title(item, identifier)
    creator = author(item, str((old or {}).get("author") or "Unknown"))
    return {
        "archive_path": archive_path(creator, name, identifier),
        "archive_repository": MAIN_REPOSITORY,
        "archived": published or bool(old and old.get("archived")),
        "author": creator,
        "canonical_id": canonical_id("bethesda", identifier),
        "content_id": identifier,
        "deleted": False,
        "fingerprint": fingerprint,
        "platform": "console",
        "published": published,
        "source": "bethesda",
        "source_id": identifier,
        "source_url": f"https://mods.bethesda.net/en/elderscrollsonline/details/{identifier}",
        "title": name,
    }


def omit_oversized_files(root: Path, record: dict[str, Any]) -> None:
    omitted: list[dict[str, Any]] = []
    for file_path in sorted(root.rglob("*")):
        if not file_path.is_file() or file_path.stat().st_size <= MAX_REPOSITORY_FILE_BYTES:
            continue
        digest = hashlib.sha256(file_path.read_bytes()).hexdigest()
        omitted.append(
            {
                "path": file_path.relative_to(root).as_posix(),
                "bytes": file_path.stat().st_size,
                "sha256": digest,
                "reason": "exceeds the mirror's 95 MiB per-file Git limit",
                "source_url": record["source_url"],
            }
        )
        file_path.unlink()
    if omitted:
        write_json(root / ".mirror-omitted.json", {"files": omitted})


def download_release(identifier: str, record: dict[str, Any], destination: Path) -> bool:
    with tempfile.TemporaryDirectory(prefix="bethesda-addon-") as temporary:
        work = Path(temporary)
        archive = work / f"{identifier}.zip"
        unpacked = work / "unpacked"
        unpacked.mkdir()
        run(
            CLI,
            "download",
            identifier,
            "--platform",
            "windows",
            "--output",
            str(archive),
            "--no-progress",
            "--session",
            str(ROOT / ".session.json"),
        )
        if not archive.is_file():
            return False
        safe_extract(archive, unpacked)
        omit_oversized_files(unpacked, record)
        if destination.exists():
            shutil.rmtree(destination)
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copytree(unpacked, destination)
    return True


def remove_archive(path: Path) -> None:
    shutil.rmtree(path)
    parent = path.parent
    if parent.is_dir() and not any(parent.iterdir()):
        parent.rmdir()


def main() -> None:
    if not os.environ.get("BNET_USERNAME") or not os.environ.get("BNET_PASSWORD"):
        raise RuntimeError("BNET_USERNAME and BNET_PASSWORD are required")

    ADDONS.mkdir(exist_ok=True)
    (ROOT / ".session.json").write_text("{}\n", encoding="utf-8")
    previous = read_catalog()["addons"]
    next_catalog = dict(previous)
    wanted = selected_ids()
    discovered: dict[str, dict[str, Any]] = {}
    failures: list[str] = []
    changed = 0

    try:
        with tempfile.TemporaryDirectory(prefix="bethesda-catalog-") as temporary:
            work = Path(temporary)
            page = 1
            while True:
                items = page_items(list_page(page, work / f"page-{page}.json"))
                for item in items:
                    identifier = addon_id(item)
                    if wanted is None or identifier in wanted:
                        discovered[identifier] = item
                if len(items) < PAGE_SIZE:
                    break
                page += 1

            for identifier, item in sorted(discovered.items()):
                key = canonical_id("bethesda", identifier)
                old = previous.get(key, {})
                fingerprint = stable_fingerprint(item)
                record = addon_record(
                    identifier,
                    item,
                    fingerprint,
                    bool(old.get("published", True)),
                    old,
                )
                destination = ROOT / record["archive_path"]
                existing = existing_addon_path(identifier, old)
                refresh = old.get("fingerprint") != fingerprint or existing is None
                try:
                    if refresh:
                        record["published"] = download_release(identifier, record, destination)
                        record["archived"] = record["published"] or bool(old.get("archived"))
                        if record["published"] and existing and existing != destination:
                            remove_archive(existing)
                        elif not record["published"] and existing and existing != destination:
                            if destination.exists():
                                raise RuntimeError(f"Cannot move {existing} over {destination}")
                            destination.parent.mkdir(parents=True, exist_ok=True)
                            existing.rename(destination)
                    elif existing != destination:
                        if destination.exists():
                            raise RuntimeError(f"Cannot move {existing} over {destination}")
                        destination.parent.mkdir(parents=True, exist_ok=True)
                        existing.rename(destination)
                    write_json(destination / "addon.json", record)
                    if record != old:
                        changed += 1
                    next_catalog[key] = record
                except (OSError, RuntimeError, subprocess.CalledProcessError) as error:
                    failures.append(f"{key}: {error}")
                    print(f"::warning title=Bethesda archive skipped::{key}: {error}")

            if wanted is None:
                for key in previous.keys() - {
                    canonical_id("bethesda", identifier) for identifier in discovered
                }:
                    removed = dict(previous[key])
                    if removed.get("deleted") is not True:
                        removed["deleted"] = True
                        removed["deleted_at"] = datetime.now(UTC).isoformat()
                        destination = ROOT / removed["archive_path"]
                        if destination.is_dir():
                            write_json(destination / "addon.json", removed)
                        changed += 1
                    next_catalog[key] = removed
    finally:
        (ROOT / ".session.json").unlink(missing_ok=True)

    write_json(
        CATALOG,
        {"schema": SCHEMA_VERSION, "source": "bethesda", "addons": next_catalog},
    )
    write_unified_catalog(ROOT)
    print(
        f"Indexed {len(next_catalog)} Bethesda add-ons; {changed} changed; "
        f"{len(failures)} failures"
    )
    if failures:
        raise SystemExit(1)


if __name__ == "__main__":
    main()
