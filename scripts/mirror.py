#!/usr/bin/env python3
"""Mirror the latest published Bethesda ESO add-ons into a Git repository."""

from __future__ import annotations

import hashlib
import json
import os
import re
import shutil
import subprocess
import tempfile
import zipfile
from pathlib import Path, PurePosixPath
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
ADDONS = ROOT / "addons"
CATALOG = ROOT / "catalog.json"
CLI = os.environ.get("ESO_CLI", "ESOAddOnUploaderCli")
PAGE_SIZE = 50
MAX_UNPACKED_BYTES = int(os.environ.get("MAX_UNPACKED_BYTES", str(512 * 1024 * 1024)))
UUID_RE = re.compile(
    r"^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$",
    re.IGNORECASE,
)


def run(*args: str) -> None:
    subprocess.run(args, cwd=ROOT, check=True)


def read_catalog() -> dict[str, Any]:
    if not CATALOG.exists():
        return {"schema": 1, "addons": {}}
    data = json.loads(CATALOG.read_text(encoding="utf-8"))
    if data.get("schema") != 1 or not isinstance(data.get("addons"), dict):
        raise RuntimeError("catalog.json has an unsupported shape")
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
    response = payload.get("response")
    if isinstance(response, dict):
        return page_items(response)
    platform = payload.get("platform")
    if isinstance(platform, dict):
        return page_items(platform)
    raise RuntimeError("Could not find the add-on list in CLI JSON output")


def addon_id(item: dict[str, Any]) -> str:
    for key in ("content_id", "contentId", "addon_id", "addonId", "id"):
        value = item.get(key)
        if isinstance(value, str) and UUID_RE.fullmatch(value):
            return value.lower()
    raise RuntimeError(f"Add-on entry has no UUID: {item!r}")


def title(item: dict[str, Any], fallback: str) -> str:
    for key in ("title", "name"):
        value = item.get(key)
        if isinstance(value, str) and value.strip():
            return value.strip()
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
            return {k: clean(v) for k, v in sorted(value.items()) if k not in volatile}
        if isinstance(value, list):
            return [clean(v) for v in value]
        return value

    encoded = json.dumps(clean(item), sort_keys=True, separators=(",", ":")).encode()
    return hashlib.sha256(encoded).hexdigest()


def safe_extract(archive: Path, destination: Path) -> None:
    with zipfile.ZipFile(archive) as bundle:
        files = [entry for entry in bundle.infolist() if not entry.is_dir()]
        total = sum(entry.file_size for entry in files)
        if total > MAX_UNPACKED_BYTES:
            raise RuntimeError(f"{archive.name} expands to {total} bytes; safety limit exceeded")
        for entry in files:
            path = PurePosixPath(entry.filename.replace("\\", "/"))
            if path.is_absolute() or ".." in path.parts:
                raise RuntimeError(f"Unsafe path in {archive.name}: {entry.filename!r}")
            mode = entry.external_attr >> 16
            if (mode & 0o170000) == 0o120000:
                raise RuntimeError(f"Symlink rejected in {archive.name}: {entry.filename!r}")
            output = destination.joinpath(*path.parts)
            output.parent.mkdir(parents=True, exist_ok=True)
            with bundle.open(entry) as source, output.open("wb") as target:
                shutil.copyfileobj(source, target)


def selected_ids() -> set[str] | None:
    scope = os.environ.get("MIRROR_SCOPE", "allowlist").lower()
    if scope == "all":
        return None
    if scope != "allowlist":
        raise RuntimeError("MIRROR_SCOPE must be 'all' or 'allowlist'")
    path = ROOT / "allowlist.txt"
    ids = {
        line.split("#", 1)[0].strip().lower()
        for line in path.read_text(encoding="utf-8").splitlines()
        if line.split("#", 1)[0].strip()
    }
    invalid = sorted(value for value in ids if not UUID_RE.fullmatch(value))
    if invalid:
        raise RuntimeError(f"Invalid UUID(s) in allowlist.txt: {', '.join(invalid)}")
    return ids


def main() -> None:
    if not os.environ.get("BNET_USERNAME") or not os.environ.get("BNET_PASSWORD"):
        raise RuntimeError("BNET_USERNAME and BNET_PASSWORD are required")

    ADDONS.mkdir(exist_ok=True)
    (ROOT / ".session.json").write_text("{}\n", encoding="utf-8")
    previous = read_catalog()["addons"]
    wanted = selected_ids()
    discovered: dict[str, dict[str, Any]] = {}

    try:
        with tempfile.TemporaryDirectory(prefix="eso-mirror-") as temp:
            work = Path(temp)
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

            next_catalog: dict[str, Any] = {}
            for identifier, item in sorted(discovered.items()):
                fingerprint = stable_fingerprint(item)
                old = previous.get(identifier, {})
                target = ADDONS / identifier
                if old.get("fingerprint") != fingerprint or not target.is_dir():
                    archive = work / f"{identifier}.zip"
                    staged = work / f"unpacked-{identifier}"
                    staged.mkdir()
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
                    safe_extract(archive, staged)
                    shutil.rmtree(target, ignore_errors=True)
                    shutil.copytree(staged, target)
                    print(f"Updated {identifier}: {title(item, identifier)}")
                next_catalog[identifier] = {
                    "title": title(item, identifier),
                    "fingerprint": fingerprint,
                    "source": (
                        "https://mods.bethesda.net/en/elderscrollsonline/details/"
                        f"{identifier}"
                    ),
                }

            # Only remove entries when doing a complete mirror. An allowlist may be
            # edited intentionally, but deleting content should remain explicit.
            if wanted is None:
                for identifier in previous.keys() - next_catalog.keys():
                    shutil.rmtree(ADDONS / identifier, ignore_errors=True)
                    print(f"Removed unpublished add-on {identifier}")

            CATALOG.write_text(
                json.dumps({"schema": 1, "addons": next_catalog}, indent=2, sort_keys=True)
                + "\n",
                encoding="utf-8",
            )
    finally:
        (ROOT / ".session.json").unlink(missing_ok=True)


if __name__ == "__main__":
    main()
