-- Single source of truth for the add-on version string.
--
-- The `## Version:` line in ValknarrUIE.addon must match this value;
-- tools/validate_addon_manifests.sh fails the build if they drift. Everything
-- else in the add-on reads ValknarrUIEVersion rather than repeating a literal.

ValknarrUIEVersion = "1.0.7"

return ValknarrUIEVersion
