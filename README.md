# ESO Add-on Mirror

A public, GitHub-browsable catalog and preservation mirror for Elder Scrolls Online add-ons from Bethesda and ESOUI.

## Architecture

This lightweight control repository stores normalized metadata and synchronization software. Unpacked source lives in 16 public archive shards, so browsing one add-on never requires cloning the whole ecosystem.

```text
catalog.json                         unified searchable catalog
catalogs/bethesda.json               Bethesda source records
catalogs/esoui.json                  official ESOUI/MMOUI feed records
eso-addon-mirror-shard-00 … -0f      unpacked GitHub-browsable source
```

Every add-on has an immutable canonical ID: `bethesda:UUID` or `esoui:NUMBER`. A SHA-256-derived shard depends only on that ID. Human-readable folders use:

```text
addons/AUTHOR/TITLE__SOURCE_ID/
```

If an author or title changes, synchronization moves that one stable record to its new readable path. It does not create a duplicate or change shards. Bethesda's content model is the canonical record shape; ESOUI metadata is normalized into that model.

## Performance

Daily GitHub Actions first refresh the small official ESOUI feed, then fan out across the 16 shards. Each runner shallow-clones only one shard and downloads a release only when its local `addon.json` fingerprint changed. Code-only work in this repository never checks out archived source.

ZIP releases are safely unpacked. The handful of legacy ESOUI RAR releases are preserved in their original format, and a listing with no downloadable payload gets an explicit `ARCHIVE_UNAVAILABLE.md` marker. Individual generated files over 50 MiB are excluded from Git and recorded in `.mirror-omitted.json` with their byte size, SHA-256 checksum, and official download URL.

For a lightweight local metadata checkout, clone each shard with blob filtering and sparse checkout:

```bash
mkdir -p ../eso-addon-mirror-shards
for shard in 00 01 02 03 04 05 06 07 08 09 0a 0b 0c 0d 0e 0f; do
  target="../eso-addon-mirror-shards/$shard"
  git clone --filter=blob:none --no-checkout \
    "https://github.com/the-jolly-green-bryant/eso-addon-mirror-shard-$shard.git" \
    "$target"
  git -C "$target" sparse-checkout set --no-cone \
    '/README.md' '/.gitattributes' '/addons/*/*/addon.json' \
    '/addons/*/*/.mirror-omitted.json' '/addons/*/*/ARCHIVE_UNAVAILABLE.md'
  git -C "$target" checkout main
done
```

This keeps the complete, current metadata locally while downloading full add-on source blobs only when you explicitly request them.

## Stewardship

This is an unofficial preservation project and is not endorsed by Bethesda Softworks, ZeniMax Online Studios, ESOUI, or MMOUI. Add-ons remain the work of their authors and retain their own licenses. The MIT license applies to the synchronization utility, not automatically to mirrored content. Please report attribution or takedown concerns through this repository.
