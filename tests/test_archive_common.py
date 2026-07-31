import tempfile
import unittest
import zipfile
from pathlib import Path

from scripts.archive_common import archive_path, canonical_id, safe_extract, shard_for, slug


class ArchiveCommonTests(unittest.TestCase):
    def test_stable_identifier_controls_shard(self):
        identifier = canonical_id("esoui", "7")
        self.assertEqual(shard_for(identifier), shard_for(identifier))
        self.assertRegex(shard_for(identifier), r"^0[0-9a-f]$")

    def test_author_and_title_are_readable_but_id_is_stable(self):
        self.assertEqual(
            archive_path("Votan", "Votan's Fisherman", "123"),
            "addons/Votan/Votan-s-Fisherman__123",
        )

    def test_slug_is_cross_platform_safe(self):
        self.assertEqual(slug("A/B:C*D?"), "A-B-C-D")

    def test_safe_extract_rejects_parent_traversal(self):
        with tempfile.TemporaryDirectory() as temporary:
            archive = Path(temporary) / "bad.zip"
            destination = Path(temporary) / "out"
            destination.mkdir()
            with zipfile.ZipFile(archive, "w") as bundle:
                bundle.writestr("../escape.lua", "no")
            with self.assertRaises(RuntimeError):
                safe_extract(archive, destination, 1024)


if __name__ == "__main__":
    unittest.main()
