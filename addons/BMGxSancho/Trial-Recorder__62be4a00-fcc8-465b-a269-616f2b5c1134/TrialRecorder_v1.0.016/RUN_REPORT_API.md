# Trial Recorder Run Report API v1

Trial Recorder v1.0.015 introduces a versioned, transport-agnostic Run Report API.

## Ownership boundary

Trial Recorder owns authoritative run metadata and report creation. It does not upload, transport, aggregate, or post reports. External transport and Discord systems consume the API without becoming part of Trial Recorder.

## Schema

`schema`: `BMG_TRIAL_RUN_REPORT`

`schemaVersion`: `1`

A report contains:

- `reportId` / `runId`
- `createdAt`
- `identity`
  - `accountName`
  - `characterId`
  - `characterName`
  - `worldName`
- `trial`
  - `key`
  - `name`
  - `short`
  - `raidId` when available
  - `currentWeekly` when ESO exposes it
- `result`
  - `veteran`
  - `hardMode`
  - `completionType`
  - `configuration`
  - `classificationSource`
  - `score`
  - `durationMs`
  - `completedAt`
  - `vitality.remaining`
  - `vitality.starting`
  - `deaths`
  - `newFastest`
  - `newHighest`
- `roster`
  - completion-time snapshot only
  - `size`
  - `capturedAt`
  - `members[]`
    - `accountName`
    - `characterName`
    - `classId`
    - `isGroupLeader`
- `provenance`
  - Trial Recorder producer/version
  - source mapping for authoritative fields
  - optional extension provider versions
- `extensions`
  - namespaced optional provider summaries

## Public API

```lua
local API = TrialRecorder.RunReportAPI

local schemaVersion = API:GetSchemaVersion()
local latest = API:GetLatestReport()
local report = API:GetReport(reportId)
```

Returned reports are copied before being handed to consumers so external code cannot directly mutate Trial Recorder's stored report.

## Optional provider registration

Compatible addons may register a summary provider without becoming a Trial Recorder dependency:

```lua
TrialRecorder.RunReportAPI:RegisterProvider("BetterBuffs", {
    version = "0.3.10",

    IsAvailable = function(self)
        return true
    end,

    GetSummary = function(self, context)
        return {
            -- provider-owned immutable summary data
        }
    end,
})
```

`context` contains only stable run identity fields:

- `reportId`
- `runId`
- `trialKey`
- `trialName`
- `completionType`
- `configuration`
- `completedAt`
- `durationMs`

Provider errors are isolated with `pcall` and cannot prevent the clear itself from being recorded.

## Retention

Trial Recorder keeps the 50 most recent structured Run Reports in a separate SavedVariables container. Existing trial clear history remains unchanged and retains its existing limits.

## v1 limitations

- The roster is a completion-time group snapshot, not a complete join/leave history for the run.
- Optional combat/effect analytics require a compatible provider to register with the API.
- The API intentionally contains no transport state, Discord state, guild database state, upload queue, or network protocol.
- Historical clears recorded before v1.0.015 are not automatically backfilled into Run Reports.
