#!/usr/bin/env python3
"""Shared schema, naming, and archive-safety helpers."""

from __future__ import annotations

import hashlib
import html
import json
import re
import shutil
import unicodedata
import zipfile
from pathlib import Path, PurePosixPath
from typing import Any

SCHEMA_VERSION = 2
SHARD_COUNT = 16
AUTHOR_RE = re.compile(r"^##\s*Author:\s*(.+?)\s*$", re.IGNORECASE | re.MULTILINE)


def slug(value: str, fallback: str = "Unknown", maximum: int = 80) -> str:
    normalized = unicodedata.normalize("NFKC", html.unescape(value or ""))
    pieces: list[str] = []
    previous_dash = False
    for character in normalized:
        if character.isalnum() or character in "._-":
            pieces.append(character)
            previous_dash = False
        elif not previous_dash:
            pieces.append("-")
            previous_dash = True
    return ("".join(pieces).strip(" .-_")[:maximum].rstrip(" .-_") or fallback)


def canonical_id(source: str, source_id: str) -> str:
    return f"{source.lower()}:{source_id.lower()}"


def shard_for(identifier: str) -> str:
    bucket = hashlib.sha256(identifier.encode("utf-8")).digest()[0] % SHARD_COUNT
    return f"{bucket:02x}"


def archive_path(author: str, title: str, source_id: str) -> str:
    return f"addons/{slug(author)}/{slug(title)}__{slug(source_id, 'id', 64)}"


def archive_repository(shard: str) -> str:
    return f"the-jolly-green-bryant/eso-addon-mirror-shard-{shard}"


def stable_fingerprint(value: Any) -> str:
    encoded = json.dumps(value, sort_keys=True, separators=(",", ":")).encode()
    return hashlib.sha256(encoded).hexdigest()


def author_from_tree(root: Path, fallback: str = "Unknown") -> str:
    for manifest in sorted(root.rglob("*.addon")):
        try:
            match = AUTHOR_RE.search(manifest.read_text(encoding="utf-8", errors="replace"))
        except OSError:
            continue
        if match and match.group(1).strip():
            return html.unescape(match.group(1).strip())
    return fallback


def safe_extract(archive: Path, destination: Path, maximum_bytes: int) -> None:
    with zipfile.ZipFile(archive) as bundle:
        entries = [entry for entry in bundle.infolist() if not entry.is_dir()]
        total = sum(entry.file_size for entry in entries)
        if total > maximum_bytes:
            raise RuntimeError(f"{archive.name} expands to {total} bytes; limit is {maximum_bytes}")
        for entry in entries:
            relative = PurePosixPath(entry.filename.replace("\\", "/"))
            if relative.is_absolute() or ".." in relative.parts:
                raise RuntimeError(f"Unsafe archive path: {entry.filename!r}")
            mode = entry.external_attr >> 16
            if (mode & 0o170000) == 0o120000:
                raise RuntimeError(f"Symlink rejected: {entry.filename!r}")
            output = destination.joinpath(*relative.parts)
            output.parent.mkdir(parents=True, exist_ok=True)
            with bundle.open(entry) as source, output.open("wb") as target:
                shutil.copyfileobj(source, target)


def write_json(target: Path, value: Any) -> None:
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(json.dumps(value, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def write_unified_catalog(root: Path) -> None:
    addons: dict[str, Any] = {}
    sources: dict[str, int] = {}
    for source in ("bethesda", "esoui"):
        source_path = root / "catalogs" / f"{source}.json"
        if not source_path.exists():
            continue
        body = json.loads(source_path.read_text(encoding="utf-8"))
        records = body.get("addons", {})
        if not isinstance(records, dict):
            raise RuntimeError(f"Invalid {source_path}")
        addons.update(records)
        sources[source] = len(records)
    write_json(
        root / "catalog.json",
        {"schema": SCHEMA_VERSION, "sources": sources, "addons": addons},
    )
    listing_fields = (
        "archive_path",
        "archive_repository",
        "author",
        "canonical_id",
        "content_id",
        "deleted",
        "download_url",
        "downloads",
        "published",
        "source",
        "title",
        "version",
    )
    listing_addons = {
        canonical: {
            field: record[field]
            for field in listing_fields
            if field in record
        }
        for canonical, record in addons.items()
    }
    (root / "catalog-index.json").write_text(
        json.dumps(
            {
                "schema": SCHEMA_VERSION,
                "sources": sources,
                "addons": listing_addons,
            },
            separators=(",", ":"),
            sort_keys=True,
        )
        + "\n",
        encoding="utf-8",
    )
