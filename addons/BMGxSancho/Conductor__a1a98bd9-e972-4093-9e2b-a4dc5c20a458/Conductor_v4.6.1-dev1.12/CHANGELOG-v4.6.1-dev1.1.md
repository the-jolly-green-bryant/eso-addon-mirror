# Conductor v4.6.1-dev1.1

## Startup hotfix

- Fixed a startup UI error in `Display:RenderDashboard()` during the v4.6.1 stabilization migration.
- Runtime assignment reset may execute before dashboard controls are created; display clearing now safely defers rendering until `Display:Initialize()` completes.
- Added defensive initialization for module state storage during early hard-reset paths.
- No encounter, assignment, network, Timeline, or SavedVariables behavior was otherwise changed.
