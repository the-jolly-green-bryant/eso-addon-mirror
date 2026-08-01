
---

## 5. `ChangeLog.md`

```md
# Changelog

## 1.0.1

- Added clear **AI assisted addon** disclosure.
- Updated manifest version to `1.0.1` and `AddOnVersion` to `100001`.
- Reworked SavedVariables to use `ZO_SavedVars:NewAccountWide`.
- Saved account-wide settings separately per server using `GetWorldName()`.
- Added one-time migration from the previous root-level `hidden` saved variable where available.
- Removed addon-load chat spam.
- Removed `pcall` / SafeCall-style wrappers.
- Removed unnecessary checks for ESO API functions and global API tables.
- Removed repeated delayed `zo_callLater` calls.
- Reworked hook tracking to use the control object as the table key instead of the control name string.
- Kept chat output only for explicit user actions: toggle, hide, and show.

## 1.0.0

- Initial release.
- Hides `ZO_AdvZoneHUDTrackerContainer`.
- Hides `ZO_AdvZoneHUD_TopLevel`.
- Adds toggle keybind.
- Adds slash commands:
  - `/nmfsh`
  - `/nmfshhide`
  - `/nmfshshow`
- Remembers hidden/shown state.