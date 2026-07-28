# ESO Add-on Mirror

ESO add-ons are small pieces of community history. They represent years of
experimentation, accessibility work, interface design, and shared knowledge,
yet their continued availability depends on a single distribution platform and
the ongoing attention of individual authors.

This repository exists to give the public ESO console add-on catalog a second,
plainly inspectable home.

## Why mirror the catalog?

### Preservation

An add-on can disappear when an author moves on, an account changes, or a
platform removes an entry. A Git history preserves the evolution of the
catalog instead of exposing only whatever happens to be available today.

### Transparency

Console players normally receive add-ons through an in-game interface. Keeping
the source in a public repository makes changes visible, searchable, and easy
for the community to review.

### Research and accountability

A chronological, file-level record helps maintainers investigate regressions,
compare releases, recognize copied work, and study how the ESO add-on ecosystem
changes over time.

### Independence

The mirror is deliberately simple: ordinary directories, ordinary files, and
ordinary Git commits. It does not require a custom database or a permanently
running service, making the archive inexpensive to maintain and straightforward
to reproduce elsewhere.

## What the repository represents

Each Bethesda catalog entry lives at:

```text
addons/NAME__CONTENT_ID/
```

The readable name makes browsing and searching pleasant; the immutable Bethesda
content ID prevents ambiguity when names collide or change.

Every entry contains an `addon.json` describing its source and publication
state. Published entries also contain the unpacked add-on files. Unpublished
entries remain visible as metadata-only records, preserving their place in the
catalog without implying that downloadable code exists.

When an entry disappears from Bethesda's complete listing, the mirror retains
its files and marks its catalog record with `deleted: true` and `deleted_at`.
This tombstone distinguishes an upstream deletion from an ordinary unpublished
draft while keeping the final observed release inspectable and recoverable.

Each changed add-on receives its own commit. That makes the history meaningful:
a commit corresponds to one catalog entry changing, rather than an opaque daily
bulk snapshot. Work is pushed incrementally so one malformed or unavailable
entry cannot erase progress made earlier in the run.

## Stewardship

This is an unofficial preservation project and is not endorsed by Bethesda
Softworks or ZeniMax Online Studios. Add-ons remain the work of their respective
authors. The repository's MIT license applies to the mirroring utility itself,
not automatically to mirrored add-on content.

Public preservation carries responsibility. Takedown and attribution concerns
should be handled promptly, and the archive should never be treated as evidence
that every add-on shares the same redistribution license.

The mirror refreshes daily using a standard public GitHub Actions runner. There
is no always-on server and no paid infrastructure by design.
