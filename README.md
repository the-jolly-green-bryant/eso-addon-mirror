# ESO Add-on Mirror

A low-cost, serverless mirror of the latest published Elder Scrolls Online
console add-ons from Bethesda.net. A daily GitHub Actions job discovers add-ons,
downloads only entries whose stable metadata changed, safely unpacks them, and
creates one commit per changed add-on. Progress is pushed every ten commits and
again on exit, so a later bad entry does not discard completed work.

Every discovered entry gets an `addon.json`. Published entries also contain the
unpacked add-on code; unpublished entries intentionally contain metadata only.

## Cost model

The intended deployment is a **public GitHub repository**. GitHub-hosted Actions
usage is free for standard runners in public repositories, so there is no
always-on service or cloud bill. The practical costs are repository storage,
bandwidth, and Git history growth. GitHub recommends repositories remain small;
if the mirror grows substantially, split it by add-on or move binary snapshots
to object storage.

## Deploy

1. Create a public GitHub repository named `eso-addon-mirror` and push these
   files to its default branch.
2. In **Settings → Secrets and variables → Actions**, add:
   - `BNET_USERNAME`
   - `BNET_PASSWORD`
3. Keep the workflow's `MIRROR_SCOPE: all` to discover every published add-on,
   or change it to `allowlist` and put approved Bethesda content UUIDs in
   `allowlist.txt`.
4. Run **Mirror Bethesda ESO add-ons** once from the Actions tab. It will then
   run daily at approximately 04:23 UTC.

The workflow needs only `contents: write`. Credentials and the short-lived
session file are never committed. Concurrent runs are serialized.

## Local use

Install version 1.4.0 of
[ESOAddOnUploaderCLI](https://github.com/sirinsidiator/ESOAddOnUploaderCLI/releases/tag/1.4.0),
then run:

```sh
export BNET_USERNAME="your Bethesda username"
export BNET_PASSWORD="your Bethesda password"
export MIRROR_SCOPE=allowlist
python3 scripts/mirror.py
```

Run the dependency-free test suite with:

```sh
python3 -m unittest discover -s tests -v
```

## Security and redistribution

The downloader rejects absolute paths, parent-directory traversal, symlinks,
and archives expanding beyond 512 MiB by default. Mirrored code is untrusted;
do not execute it in the workflow.

The MIT license in this repository applies only to the mirror utility. Add-ons
remain copyrighted by their respective authors and may have different
licenses. Before operating a public mirror, confirm that redistribution of
every included add-on is permitted. `MIRROR_SCOPE=allowlist` is the safer
default for an authorization-based mirror.

This project is unofficial and is not endorsed by Bethesda Softworks or
ZeniMax Online Studios.
