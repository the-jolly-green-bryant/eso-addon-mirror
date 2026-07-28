import importlib.util
import tempfile
import unittest
import zipfile
from pathlib import Path

SPEC = importlib.util.spec_from_file_location(
    "mirror", Path(__file__).parents[1] / "scripts" / "mirror.py"
)
mirror = importlib.util.module_from_spec(SPEC)
assert SPEC.loader
SPEC.loader.exec_module(mirror)


class MirrorTests(unittest.TestCase):
    def test_page_items_under_platform_response(self):
        payload = {"platform": {"response": {"data": [{"content_id": "x"}]}}}
        self.assertEqual(mirror.page_items(payload), [{"content_id": "x"}])

    def test_fingerprint_ignores_download_counters(self):
        left = {"title": "A", "download_count": 1, "stats": {"views": 2}}
        right = {"title": "A", "download_count": 999, "stats": {"views": 800}}
        self.assertEqual(mirror.stable_fingerprint(left), mirror.stable_fingerprint(right))

    def test_safe_extract_rejects_parent_traversal(self):
        with tempfile.TemporaryDirectory() as temp:
            archive = Path(temp) / "bad.zip"
            destination = Path(temp) / "out"
            destination.mkdir()
            with zipfile.ZipFile(archive, "w") as bundle:
                bundle.writestr("../escape.lua", "no")
            with self.assertRaises(RuntimeError):
                mirror.safe_extract(archive, destination)

    def test_safe_extract_writes_normal_files(self):
        with tempfile.TemporaryDirectory() as temp:
            archive = Path(temp) / "good.zip"
            destination = Path(temp) / "out"
            destination.mkdir()
            with zipfile.ZipFile(archive, "w") as bundle:
                bundle.writestr("Example/Example.lua", "ok")
            mirror.safe_extract(archive, destination)
            self.assertEqual((destination / "Example/Example.lua").read_text(), "ok")

    def test_addon_record_marks_unpublished_content(self):
        record = mirror.addon_record(
            "00000000-0000-4000-8000-000000000000",
            {"title": "No Release"},
            "fingerprint",
            False,
        )
        self.assertFalse(record["published"])
        self.assertEqual(record["title"], "No Release")

    def test_title_decodes_html_entities(self):
        self.assertEqual(mirror.title({"title": "Votan&#39;s Addon"}, "x"), "Votan's Addon")

    def test_directory_name_is_readable_and_safe(self):
        identifier = "00000000-0000-4000-8000-000000000000"
        self.assertEqual(
            mirror.directory_name("Votan's Fisherman / Console", identifier),
            f"Votan-s-Fisherman-Console__{identifier}",
        )


if __name__ == "__main__":
    unittest.main()
