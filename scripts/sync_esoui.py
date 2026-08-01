#!/usr/bin/env python3
"""Synchronize ESOUI PC metadata and optionally archive changed releases."""

from __future__ import annotations

import argparse
import hashlib
import json
import shutil
import tempfile
import time
import urllib.error
import urllib.request
import zipfile
from datetime import UTC, datetime
from pathlib import Path
from typing import Any

from archive_common import (
    SCHEMA_VERSION,
    archive_path,
    archive_repository,
    canonical_id,
    safe_extract,
    shard_for,
    stable_fingerprint,
    write_json,
    write_unified_catalog,
)

FEED_URL = "https://api.mmoui.com/v3/game/ESO/filelist.json"
DOWNLOAD_URL = "https://www.esoui.com/downloads/dl{source_id}/"
MAX_UNPACKED_BYTES = 512 * 1024 * 1024
MAX_REPOSITORY_FILE_BYTES = 95 * 1024 * 1024
DOWNLOAD_ATTEMPTS = 4
MAIN_REPOSITORY = "the-jolly-green-bryant/eso-addon-mirror"
ARCHIVE_STATE_FIELDS = (
    "archive_error",
    "archive_format",
    "archive_status",
    "omitted_files",
)


class UnavailableReleaseError(RuntimeError):
    """The upstream listing exists but currently has no downloadable payload."""


def read_feed(feed_path: Path | None) -> list[dict[str, Any]]:
    if feed_path:
        body = json.loads(feed_path.read_text(encoding="utf-8"))
    else:
        request = urllib.request.Request(FEED_URL, headers={"User-Agent": "ESO-Addon-Mirror/2"})
        with urllib.request.urlopen(request, timeout=60) as response:
            body = json.load(response)
    if not isinstance(body, list):
        raise RuntimeError("ESOUI feed did not return a list")
    return [entry for entry in body if isinstance(entry, dict)]


def release_fingerprint(entry: dict[str, Any]) -> str:
    return stable_fingerprint(
        {
            "id": entry.get("UID"),
            "version": entry.get("UIVersion"),
            "date": entry.get("UIDate"),
            "name": entry.get("UIName"),
            "author": entry.get("UIAuthorName"),
            "directories": entry.get("UIDir"),
            "compatibility": entry.get("UICompatibility"),
        }
    )


def record_from_entry(
    entry: dict[str, Any],
    old: dict[str, Any] | None,
    main_repository: bool = False,
) -> dict[str, Any]:
    source_id = str(entry["UID"])
    identifier = canonical_id("esoui", source_id)
    title = str(entry.get("UIName") or source_id)
    author = str(entry.get("UIAuthorName") or "Unknown")
    shard = shard_for(identifier)
    relative_path = archive_path(author, title, source_id)
    record = {
        "canonical_id": identifier,
        "content_id": identifier,
        "source": "esoui",
        "source_id": source_id,
        "platform": "pc",
        "title": title,
        "author": author,
        "published": True,
        "deleted": False,
        "version": entry.get("UIVersion"),
        "updated_at": entry.get("UIDate"),
        "category_id": entry.get("UICATID"),
        "directories": entry.get("UIDir") or [],
        "compatibility": entry.get("UICompatibility") or [],
        "images": entry.get("UIIMGs") or [],
        "stats": {
            "downloads": int(entry.get("UIDownloadTotal") or 0),
            "monthly_downloads": int(entry.get("UIDownloadMonthly") or 0),
            "favorites": int(entry.get("UIFavoriteTotal") or 0),
        },
        "fingerprint": release_fingerprint(entry),
        "source_url": entry.get("UIFileInfoURL"),
        "download_url": DOWNLOAD_URL.format(source_id=source_id),
        "archive_repository": (
            MAIN_REPOSITORY if main_repository else archive_repository(shard)
        ),
        "archive_path": relative_path,
        "archived": bool(old and old.get("archived")),
    }
    if not main_repository:
        record["shard"] = shard
    return record


def omit_oversized_files(root: Path, record: dict[str, Any]) -> list[dict[str, Any]]:
    omitted: list[dict[str, Any]] = []
    for file_path in sorted(root.rglob("*")):
        if not file_path.is_file() or file_path.stat().st_size <= MAX_REPOSITORY_FILE_BYTES:
            continue
        digest = hashlib.sha256()
        with file_path.open("rb") as source:
            for chunk in iter(lambda: source.read(1024 * 1024), b""):
                digest.update(chunk)
        omitted.append(
            {
                "path": file_path.relative_to(root).as_posix(),
                "bytes": file_path.stat().st_size,
                "sha256": digest.hexdigest(),
                "reason": "exceeds the mirror's 95 MiB per-file Git limit",
                "download_url": record["download_url"],
            }
        )
        file_path.unlink()
    if omitted:
        write_json(root / ".mirror-omitted.json", {"files": omitted})
    return omitted


def archive_destination(root: Path, record: dict[str, Any], sharded: bool) -> Path:
    prefix = Path(str(record["shard"])) if sharded else Path()
    return root / prefix / record["archive_path"]


def write_unavailable_release(
    record: dict[str, Any], archive_root: Path, reason: str, sharded: bool = True
) -> None:
    destination = archive_destination(archive_root, record, sharded)
    if destination.exists():
        return
    destination.mkdir(parents=True, exist_ok=True)
    metadata = record | {
        "archived": False,
        "archive_status": "unavailable",
        "archive_error": reason,
    }
    write_json(destination / "addon.json", metadata)
    (destination / "ARCHIVE_UNAVAILABLE.md").write_text(
        "# Archive unavailable\n\n"
        "ESOUI lists this add-on, but its download endpoint returned an empty response "
        "after multiple attempts. The mirror will retry if ESOUI publishes a changed release.\n",
        encoding="utf-8",
    )


def archive_release(
    record: dict[str, Any],
    old: dict[str, Any] | None,
    archive_root: Path,
    sharded: bool = True,
) -> None:
    destination = archive_destination(archive_root, record, sharded)
    old_destination = (
        archive_destination(archive_root, old, sharded)
        if old
        and old.get("archive_path")
        and (not sharded or old.get("shard"))
        else None
    )
    with tempfile.TemporaryDirectory(prefix="esoui-addon-") as temporary:
        temporary_path = Path(temporary)
        archive = temporary_path / f"{record['source_id']}.zip"
        unpacked = temporary_path / "unpacked"
        last_error: Exception | None = None
        archive_format = "zip"
        for attempt in range(1, DOWNLOAD_ATTEMPTS + 1):
            try:
                request = urllib.request.Request(
                    str(record["download_url"]),
                    headers={"User-Agent": "ESO-Addon-Mirror/2"},
                )
                with urllib.request.urlopen(request, timeout=120) as response:
                    archive.write_bytes(response.read())
                if archive.stat().st_size == 0:
                    raise UnavailableReleaseError("ESOUI returned an empty response")
                if unpacked.exists():
                    shutil.rmtree(unpacked)
                unpacked.mkdir()
                if zipfile.is_zipfile(archive):
                    safe_extract(archive, unpacked, MAX_UNPACKED_BYTES)
                    archive_format = "zip"
                elif archive.read_bytes()[:8].startswith(b"Rar!"):
                    shutil.copy2(archive, unpacked / "release.rar")
                    archive_format = "rar"
                else:
                    raise zipfile.BadZipFile("ESOUI response is not a ZIP archive")
                break
            except (OSError, RuntimeError, urllib.error.URLError, zipfile.BadZipFile) as error:
                last_error = error
                if attempt < DOWNLOAD_ATTEMPTS:
                    time.sleep(2 ** (attempt - 1))
        else:
            assert last_error is not None
            if isinstance(last_error, UnavailableReleaseError):
                raise last_error
            raise RuntimeError(
                f"ESOUI {record['source_id']} ({record['title']}) failed after "
                f"{DOWNLOAD_ATTEMPTS} attempts: {type(last_error).__name__}: {last_error}"
            ) from last_error
        omitted = omit_oversized_files(unpacked, record)
        record["archive_format"] = archive_format
        if omitted:
            record["omitted_files"] = omitted
        if destination.exists():
            shutil.rmtree(destination)
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copytree(unpacked, destination)
        write_json(destination / "addon.json", record | {"archived": True})
        if old_destination and old_destination != destination and old_destination.exists():
            shutil.rmtree(old_destination)
            parent = old_destination.parent
            if parent.is_dir() and not any(parent.iterdir()):
                parent.rmdir()
    record["archived"] = True


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument("--feed", type=Path)
    parser.add_argument("--shard-root", type=Path)
    parser.add_argument("--shard", choices=[f"{value:02x}" for value in range(16)])
    parser.add_argument(
        "--main-repository",
        action="store_true",
        help="Archive directly into the canonical repository instead of shards.",
    )
    parser.add_argument("--limit", type=int)
    parser.add_argument("--metadata-only", action="store_true")
    args = parser.parse_args()
    if args.main_repository and (args.shard or args.shard_root):
        parser.error("--main-repository cannot be combined with shard options")
    root = args.root.resolve()
    catalog_path = root / "catalogs" / "esoui.json"
    previous = (
        json.loads(catalog_path.read_text(encoding="utf-8")).get("addons", {})
        if catalog_path.exists()
        else {}
    )
    next_catalog = dict(previous)
    discovered: set[str] = set()
    archived = 0
    unavailable = 0
    failures: list[str] = []
    selected = read_feed(args.feed)
    if args.limit:
        selected = selected[: args.limit]

    for entry in selected:
        if entry.get("UID") is None:
            continue
        identifier = canonical_id("esoui", str(entry["UID"]))
        discovered.add(identifier)
        old = previous.get(identifier)
        record = record_from_entry(entry, old, args.main_repository)
        if args.shard and record["shard"] != args.shard:
            continue
        local_metadata = None
        archive_root = root if args.main_repository else args.shard_root
        if archive_root:
            local_path = (
                archive_destination(
                    archive_root.resolve(), record, not args.main_repository
                )
                / "addon.json"
            )
            if local_path.exists():
                try:
                    local_metadata = json.loads(local_path.read_text(encoding="utf-8"))
                except (OSError, json.JSONDecodeError):
                    local_metadata = None
        should_archive = not args.metadata_only and archive_root and (
            not local_metadata
            or local_metadata.get("fingerprint") != record["fingerprint"]
            or local_metadata.get("archive_path") != record["archive_path"]
        )
        if not should_archive and old:
            for field in ARCHIVE_STATE_FIELDS:
                if field in old:
                    record[field] = old[field]
        if should_archive:
            try:
                archive_release(
                    record,
                    old,
                    archive_root.resolve(),
                    sharded=not args.main_repository,
                )
                archived += 1
            except UnavailableReleaseError as error:
                write_unavailable_release(
                    record,
                    archive_root.resolve(),
                    str(error),
                    sharded=not args.main_repository,
                )
                record["archive_status"] = "unavailable"
                record["archive_error"] = str(error)
                unavailable += 1
                print(f"::notice title=ESOUI archive unavailable::{identifier}: {error}")
            except (OSError, RuntimeError, urllib.error.URLError, zipfile.BadZipFile) as error:
                failure = f"{identifier}: {error}"
                failures.append(failure)
                print(f"::warning title=ESOUI archive skipped::{failure}")
                if old:
                    record = dict(old)
        next_catalog[identifier] = record

    if not args.shard and not args.limit:
        for identifier in previous.keys() - discovered:
            removed = dict(previous[identifier])
            if removed.get("deleted") is not True:
                removed["deleted"] = True
                removed["deleted_at"] = datetime.now(UTC).isoformat()
            next_catalog[identifier] = removed

    write_json(
        catalog_path,
        {"schema": SCHEMA_VERSION, "source": "esoui", "addons": next_catalog},
    )
    write_unified_catalog(root)
    print(
        f"Indexed {len(next_catalog)} ESOUI add-ons; archived {archived} releases; "
        f"{unavailable} unavailable; {len(failures)} failures"
    )
    if failures:
        raise SystemExit(1)


if __name__ == "__main__":
    main()
