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

Daily GitHub Actions first refresh the small official ESOUI feed, then fan out across the 16 shards. Each runner shallow-clones only one shard and downloads a ZIP only when its local `addon.json` release fingerprint changed. Code-only work in this repository never checks out archived source.

## Stewardship

This is an unofficial preservation project and is not endorsed by Bethesda Softworks, ZeniMax Online Studios, ESOUI, or MMOUI. Add-ons remain the work of their authors and retain their own licenses. The MIT license applies to the synchronization utility, not automatically to mirrored content. Please report attribution or takedown concerns through this repository.
