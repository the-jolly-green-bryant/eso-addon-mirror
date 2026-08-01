# GoronDev RezBot Harness Changelog

## Unreleased
- Reduce UI updates by adding a dirty-flag so `RefreshUI()` only runs when state changes.
- Add stale-entry cleanup to remove group members who leave and reset the color cache.
- Fix “Disable UI” checkbox logic so it matches the saved setting.
- Prevent repeated debug spam when group role APIs are unavailable.
- Add sandbox guard for RezBotSync to mark installed users correctly and self-register the local account.
- Added Harven settings toggle to allow whitelisted friends to load the GoronDev RezBot build.
- Store RezBot dev settings inside `GoronDevSV` under a dedicated namespace.

## 1.9.4
- Existing release contents (see previous notes).
