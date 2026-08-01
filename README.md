# ESO Add-on Mirror

A public, GitHub-browsable catalog and preservation mirror for Elder Scrolls Online add-ons from Bethesda and ESOUI.

## Browse add-ons

**[Browse every Console and PC / Mac add-on A–Z](addons/README.md).** Each listing links directly to the add-on's unpacked source in this repository. The index and current total are regenerated automatically when catalog metadata changes.

## Architecture

This is the canonical archive: normalized metadata, synchronization software, and the current unpacked source for every mirrored Console and PC / Mac add-on live together. The former 16 shard repositories remain available as compatibility snapshots, but catalog links and daily updates point here.

```text
catalog.json                         unified searchable catalog
catalog-index.json                   compact catalog for web/API browsing
catalogs/bethesda.json               Bethesda source records
catalogs/esoui.json                  official ESOUI/MMOUI feed records
addons/AUTHOR/TITLE__SOURCE_ID/       unpacked GitHub-browsable source
addons/*.md                           generated A–Z browsing indexes
```

Every add-on has an immutable canonical ID: `bethesda:UUID` or `esoui:NUMBER`. Human-readable folders use:

```text
addons/AUTHOR/TITLE__SOURCE_ID/
```

If an author or title changes, synchronization moves that one stable record to its new readable path instead of creating a duplicate. Bethesda's content model is the canonical record shape; ESOUI metadata is normalized into that model.

## Performance

One daily GitHub Actions runner refreshes the complete Bethesda and ESOUI catalogs. CI uses a blobless sparse checkout containing catalogs and `addon.json` metadata, then downloads and commits only releases whose stable fingerprint changed. Unchanged source blobs are never fetched by the runner.

`catalog-index.json` contains only fields used for search, paging, source labels,
downloads, and detail links. It stays below common server-rendering cache limits,
while `catalog.json` remains the complete metadata source of truth.

ZIP releases are safely unpacked. The handful of legacy ESOUI RAR releases are preserved in their original format, and a listing with no downloadable payload gets an explicit `ARCHIVE_UNAVAILABLE.md` marker. Individual files that would approach GitHub's 100 MiB hard limit are excluded from Git at 95 MiB and recorded in `.mirror-omitted.json` with their byte size, SHA-256 checksum, and official download URL. All other mirrored files are marked `-text` so Git preserves the exact upstream bytes and line endings.

Because the complete unpacked snapshot is large, use a blobless partial clone and sparse checkout unless you truly want every source file:

```bash
git clone --filter=blob:none --no-checkout \
  https://github.com/the-jolly-green-bryant/eso-addon-mirror.git
cd eso-addon-mirror
git sparse-checkout set --no-cone \
  '/README.md' '/LICENSE' '/catalog.json' '/catalog-index.json' '/catalogs/' \
  '/addons/*.md' '/addons/*/*/addon.json' \
  '/addons/*/*/.mirror-omitted.json' '/addons/*/*/ARCHIVE_UNAVAILABLE.md'
git checkout main
```

That keeps the complete searchable catalog and per-add-on metadata locally. Materialize one add-on without downloading the rest:

```bash
git sparse-checkout add --no-cone \
  '/addons/AUTHOR/TITLE__SOURCE_ID/'
```

Or select a whole platform from the catalog while retaining the lightweight metadata set:

```bash
{
  printf '%s\n' '/README.md' '/LICENSE' '/catalog.json' '/catalog-index.json' \
    '/catalogs/' '/addons/*.md' '/addons/*/*/addon.json'
  jq -r '.addons[] | select(.source == "esoui") | "/" + .archive_path + "/"' \
    catalog-index.json
} | git sparse-checkout set --no-cone --stdin
```

Change `esoui` to `bethesda` for Console add-ons. Blob filtering means Git downloads the selected current source only when the sparse patterns request it.

To expand a selective clone into the complete Console and PC / Mac archive later:

```bash
git sparse-checkout disable
```

That command materializes every current add-on; the blobless clone still avoids downloading unreachable historical blobs.

## Stewardship

This is an unofficial preservation project and is not endorsed by Bethesda Softworks, ZeniMax Online Studios, ESOUI, or MMOUI. Add-ons remain the work of their authors and retain their own licenses. The repository's transparency-only license applies to the synchronization utility, not automatically to mirrored content. Please report attribution or takedown concerns through this repository.
