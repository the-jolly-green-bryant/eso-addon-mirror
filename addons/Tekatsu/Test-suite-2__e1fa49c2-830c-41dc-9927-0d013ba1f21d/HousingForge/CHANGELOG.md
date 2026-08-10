# Changelog

## 1.4.0

- Added a controller-first precision workspace with multi-select, axis alignment, equal distribution, mirroring, group rotation, exact movement, named per-house groups, paced requests, cancellation, and one-step undo.
- Added controller dashboard/main-menu controls for pausing, resuming, safely canceling, and retrying housing queues.
- Added automatic, bounded recovery layouts before clean and clean-then-apply operations.
- Safety-enabled cleanup now blocks when furnishing links or paths are detected, because 1.4 records those relationships but does not restore them yet; disabling cleanup safety is the explicit destructive override.
- Added strict layout/current-house matching and rebuilt furnishing ownership data after cleanup.
- Added object-state restoration after successful placement while preserving the existing apply queue controls.
- Expanded snapshots and HFv2 export with source/parent furnishing IDs and path metadata.
- Added validated HFv2 local import with collision-safe IDs.
- Fixed missing-marker re-enable behavior and added distance-aware size/opacity fading.
- Removed the expired default export tunnel and reject missing or invalid endpoints.
- Added optional record/copy names, local rename, manual recovery snapshots, clearer recovery/import labels, and updated gamepad/main-menu actions.
- Preserved SavedVariables storage version 1 while migrating the internal schema to version 2, so existing layouts are not reset.
