import importlib.util
import io
import json
import sys
import tempfile
import unittest
import zipfile
from pathlib import Path
from unittest.mock import patch

SCRIPTS = Path(__file__).parents[1] / "scripts"
sys.path.insert(0, str(SCRIPTS))
SPEC = importlib.util.spec_from_file_location("sync_esoui", SCRIPTS / "sync_esoui.py")
sync_esoui = importlib.util.module_from_spec(SPEC)
assert SPEC.loader
SPEC.loader.exec_module(sync_esoui)


class FakeResponse(io.BytesIO):
    def __enter__(self):
        return self

    def __exit__(self, *args):
        self.close()


class SyncEsouiTests(unittest.TestCase):
    def test_invalid_download_retries_without_replacing_existing_archive(self):
        record = {
            "source_id": "7",
            "title": "Example",
            "download_url": "https://example.invalid/addon",
            "shard": "00",
            "archive_path": "addons/Author/Example__7",
        }
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            destination = root / "00" / record["archive_path"]
            destination.mkdir(parents=True)
            (destination / "existing.lua").write_text("keep", encoding="utf-8")

            with (
                patch.object(
                    sync_esoui.urllib.request,
                    "urlopen",
                    side_effect=lambda *args, **kwargs: FakeResponse(
                        b"<html>try later</html>"
                    ),
                ) as urlopen,
                patch.object(sync_esoui.time, "sleep") as sleep,
            ):
                with self.assertRaisesRegex(RuntimeError, "failed after 4 attempts"):
                    sync_esoui.archive_release(record, None, root)

            self.assertEqual(urlopen.call_count, 4)
            self.assertEqual(sleep.call_count, 3)
            self.assertEqual((destination / "existing.lua").read_text(), "keep")

    def test_legacy_rar_is_preserved_as_original_archive(self):
        record = {
            "source_id": "7",
            "title": "Legacy",
            "download_url": "https://example.invalid/addon",
            "shard": "00",
            "archive_path": "addons/Author/Legacy__7",
        }
        payload = b"Rar!\x1a\x07\x00legacy"
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            with patch.object(
                sync_esoui.urllib.request,
                "urlopen",
                return_value=FakeResponse(payload),
            ):
                sync_esoui.archive_release(record, None, root)

            destination = root / "00" / record["archive_path"]
            self.assertEqual((destination / "release.rar").read_bytes(), payload)
            metadata = json.loads((destination / "addon.json").read_text())
            self.assertEqual(metadata["archive_format"], "rar")
            self.assertTrue(metadata["archived"])

    def test_oversized_files_are_replaced_by_checksum_manifest(self):
        record = {"download_url": "https://example.invalid/addon"}
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            oversized = root / "generated.lang"
            oversized.write_bytes(b"large")
            with patch.object(sync_esoui, "MAX_REPOSITORY_FILE_BYTES", 4):
                omitted = sync_esoui.omit_oversized_files(root, record)

            self.assertFalse(oversized.exists())
            self.assertEqual(omitted[0]["path"], "generated.lang")
            self.assertEqual(omitted[0]["bytes"], 5)
            self.assertTrue((root / ".mirror-omitted.json").exists())

    def test_empty_release_gets_stable_unavailable_marker(self):
        record = {
            "source_id": "7",
            "title": "Missing",
            "download_url": "https://example.invalid/addon",
            "shard": "00",
            "archive_path": "addons/Author/Missing__7",
        }
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            sync_esoui.write_unavailable_release(record, root, "empty response")
            metadata = json.loads(
                (root / "00" / record["archive_path"] / "addon.json").read_text()
            )
            self.assertEqual(metadata["archive_status"], "unavailable")
            self.assertFalse(metadata["archived"])

    def test_release_fingerprint_ignores_download_counters(self):
        entry = {
            "UID": 7,
            "UIVersion": "1",
            "UIDate": 1,
            "UIName": "Example",
            "UIAuthorName": "Author",
            "UIDir": ["Example"],
            "UICompatibility": [101048],
            "UIDownloadTotal": 1,
        }
        changed = json.loads(json.dumps(entry))
        changed["UIDownloadTotal"] = 999
        self.assertEqual(
            sync_esoui.release_fingerprint(entry),
            sync_esoui.release_fingerprint(changed),
        )


if __name__ == "__main__":
    unittest.main()
