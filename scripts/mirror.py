#!/usr/bin/env python3
"""Mirror the latest published Bethesda ESO add-ons into a Git repository."""

from __future__ import annotations

import hashlib
import html
import json
import os
import re
import shutil
import subprocess
import tempfile
import unicodedata
import zipfile
from pathlib import Path, PurePosixPath
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
ADDONS = ROOT / "addons"
CATALOG = ROOT / "catalog.json"
CLI = os.environ.get("ESO_CLI", "ESOAddOnUploaderCli")
PAGE_SIZE = 50
PUSH_EVERY = int(os.environ.get("PUSH_EVERY", "10"))
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
            return html.unescape(value.strip())
    return fallback


def directory_name(name: str, identifier: str) -> str:
    """Return a readable, cross-platform-safe NAME__ID directory name."""
    normalized = unicodedata.normalize("NFKC", html.unescape(name))
    pieces: list[str] = []
    previous_dash = False
    for character in normalized:
        allowed = character.isalnum() or character in "._-"
        if allowed:
            pieces.append(character)
            previous_dash = False
        elif not previous_dash:
            pieces.append("-")
            previous_dash = True
    readable = "".join(pieces).strip(" .-_")[:100].rstrip(" .-_") or "Addon"
    return f"{readable}__{identifier}"


def existing_addon_path(identifier: str, old: dict[str, Any]) -> Path | None:
    recorded = old.get("path")
    if isinstance(recorded, str):
        candidate = ROOT / recorded
        if candidate.is_dir():
            return candidate
    legacy = ADDONS / identifier
    if legacy.is_dir():
        return legacy
    matches = list(ADDONS.glob(f"*__{identifier}"))
    return matches[0] if matches else None


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


def addon_record(
    identifier: str, item: dict[str, Any], fingerprint: str, published: bool
) -> dict[str, Any]:
    name = title(item, identifier)
    return {
        "content_id": identifier,
        "title": name,
        "published": published,
        "fingerprint": fingerprint,
        "path": f"addons/{directory_name(name, identifier)}",
        "source": (
            "https://mods.bethesda.net/en/elderscrollsonline/details/"
            f"{identifier}"
        ),
    }


def write_addon_metadata(target: Path, record: dict[str, Any]) -> None:
    target.mkdir(parents=True, exist_ok=True)
    (target / "addon.json").write_text(
        json.dumps(record, indent=2, sort_keys=True) + "\n", encoding="utf-8"
    )


def write_catalog(addons: dict[str, Any]) -> None:
    CATALOG.write_text(
        json.dumps({"schema": 1, "addons": addons}, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )


def commit_addon(identifier: str, name: str) -> bool:
    # Stage the full add-ons tree so Git records directory renames cleanly.
    # Only one add-on is mutated between commits.
    run("git", "add", "-A", "--", "addons", "catalog.json")
    changed = subprocess.run(
        ("git", "diff", "--cached", "--quiet"), cwd=ROOT, check=False
    ).returncode
    if changed == 0:
        return False
    safe_name = " ".join(name.split())[:120]
    run("git", "commit", "-m", f"mirror: {safe_name} ({identifier})")
    return True


def push() -> None:
    run("git", "push")


def main() -> None:
    if not os.environ.get("BNET_USERNAME") or not os.environ.get("BNET_PASSWORD"):
        raise RuntimeError("BNET_USERNAME and BNET_PASSWORD are required")

    ADDONS.mkdir(exist_ok=True)
    (ROOT / ".session.json").write_text("{}\n", encoding="utf-8")
    previous = read_catalog()["addons"]
    next_catalog = dict(previous)
    wanted = selected_ids()
    discovered: dict[str, dict[str, Any]] = {}
    unpushed = 0

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

            for identifier, item in sorted(discovered.items()):
                fingerprint = stable_fingerprint(item)
                old = previous.get(identifier, {})
                name = title(item, identifier)
                target = ADDONS / directory_name(name, identifier)
                existing = existing_addon_path(identifier, old)
                refresh_content = old.get("fingerprint") != fingerprint or existing is None
                path_changed = existing is not None and existing != target

                if path_changed:
                    if target.exists():
                        raise RuntimeError(f"Cannot rename {existing} over existing {target}")
                    existing.rename(target)
                    existing = target

                if refresh_content:
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
                    shutil.rmtree(target, ignore_errors=True)
                    published = archive.is_file()
                    if published:
                        safe_extract(archive, staged)
                        shutil.copytree(staged, target)
                else:
                    published = bool(old.get("published", True))

                record = addon_record(identifier, item, fingerprint, published)
                if refresh_content or path_changed or old.get("path") != record["path"]:
                    write_addon_metadata(target, record)
                    next_catalog[identifier] = record
                    write_catalog(next_catalog)
                    if commit_addon(identifier, record["title"]):
                        unpushed += 1
                        state = "published" if published else "unpublished metadata"
                        print(f"Committed {identifier}: {record['title']} ({state})")
                    if unpushed >= PUSH_EVERY:
                        push()
                        unpushed = 0
                elif identifier not in next_catalog:
                    next_catalog[identifier] = old

            # Entries absent from a complete listing are removed one commit at a
            # time. Allowlist removals remain explicit operator actions.
            if wanted is None:
                for identifier in previous.keys() - discovered.keys():
                    old_path = existing_addon_path(identifier, previous[identifier])
                    if old_path is not None:
                        shutil.rmtree(old_path, ignore_errors=True)
                    removed = next_catalog.pop(identifier, previous[identifier])
                    write_catalog(next_catalog)
                    if commit_addon(identifier, removed.get("title", identifier)):
                        unpushed += 1
                    if unpushed >= PUSH_EVERY:
                        push()
                        unpushed = 0
    finally:
        (ROOT / ".session.json").unlink(missing_ok=True)
        if unpushed:
            push()


if __name__ == "__main__":
    main()
