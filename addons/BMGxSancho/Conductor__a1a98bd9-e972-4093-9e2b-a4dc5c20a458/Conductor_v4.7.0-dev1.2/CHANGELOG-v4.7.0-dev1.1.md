# Conductor v4.7.0-dev1.1

## Network protocol stabilization

- Moved Conductor capability discovery from protocol ID 236 to 238.
- Moved Public Raid Context from protocol ID 236 to 239.
- Removed the internal collision where capability discovery and Public Raid Context both declared protocol ID 236.
- Avoided the external collision with the installed Icon Selection protocol using ID 236.
- Made Network, Run Sync, and Public Raid Context initialization idempotent so repeated initialization cannot register duplicate protocols or duplicate update handlers.
- Added retained protocol declaration errors for Public Raid Context diagnostics.

## Expected validation

After Reload UI, Performance / Network should show:

- Discovery channel: available
- No protocol ID 236 error
- No repeated initialization registration error
- Remote Conductor clients detectable when grouped
