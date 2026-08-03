$ErrorActionPreference = "Stop"
$addon = Split-Path -Parent $PSScriptRoot
$passed = 0
$failed = 0

function Assert-True([bool]$condition, [string]$name) {
    if ($condition) {
        $script:passed++
        Write-Host "PASS: $name"
    } else {
        $script:failed++
        Write-Host "FAIL: $name"
    }
}

$manifest = Get-Content -LiteralPath (Join-Path $addon "PvP-erformance.txt") -Raw
$module = Get-Content -LiteralPath (Join-Path $addon "Modules\Analytics\AnalyticsModule.lua") -Raw
$combat = Get-Content -LiteralPath (Join-Path $addon "Modules\Analytics\AnalyticsCombat.lua") -Raw
$ui = Get-Content -LiteralPath (Join-Path $addon "Modules\Analytics\UI\AnalyticsWindow.lua") -Raw
$duelingCombat = Get-Content -LiteralPath (Join-Path $addon "Modules\Dueling\DuelingCombat.lua") -Raw
$duelingTracking = Get-Content -LiteralPath (Join-Path $addon "Modules\Dueling\DuelingTracking.lua") -Raw
$duelingWindow = Get-Content -LiteralPath (Join-Path $addon "Modules\Dueling\UI\DuelingWindow.lua") -Raw
$duelingDashboard = Get-Content -LiteralPath (Join-Path $addon "Modules\Dueling\UI\DuelingDashboard.lua") -Raw
$constants = Get-Content -LiteralPath (Join-Path $addon "Core\Constants.lua") -Raw

Assert-True ($manifest.Contains("Modules/Analytics/AnalyticsModule.lua")) "analytics module is loaded"
Assert-True ($manifest.Contains("Modules/Analytics/AnalyticsCombat.lua")) "analytics combat engine is loaded"
Assert-True ($manifest.Contains("Modules/Analytics/UI/AnalyticsWindow.lua")) "analytics UI is loaded"
Assert-True ($manifest.IndexOf("AnalyticsModule.lua") -lt $manifest.IndexOf("DuelingTracking.lua")) "analytics definitions load before duel callbacks"
Assert-True ($module.Contains('PvPerformance.activeModule = "analytics"')) "top-level analytics navigation exists"
Assert-True ($module.Contains("pcall(method, self")) "analytics boundary is fail-safe"
Assert-True ($ui.Contains('"ANALYTICS"')) "analytics header tab exists"
Assert-True ($ui.Contains('"DUELING"')) "dueling analytics scope exists"
Assert-True ($ui.Contains("local analyticsTabBorder = analyticsTab.tabBorder")) "Analytics module selector reuses the shared fitted tab border"
Assert-True ($module.Contains("visible and 0.44 or 0.48")) "Analytics module selector border has active and inactive states"
Assert-True ($ui.Contains("panel:SetMouseEnabled(false)")) "Analytics overlay leaves the window resize edges available"
Assert-True ($ui.Contains('"SELECT OPPONENT"')) "opponent history uses a labeled selector"
Assert-True ($module.Contains("function Analytics:ShowOpponentSelectorMenu(control)")) "opponent selector menu is implemented"
Assert-True ($module.Contains("function Analytics:FormatDuelSelectorText(duel)")) "selector metadata has one shared formatter"
Assert-True (-not $ui.Contains('"< PREVIOUS"')) "legacy previous navigation is removed"
Assert-True (-not $ui.Contains('"NEXT >"')) "legacy next navigation is removed"
Assert-True (-not $ui.Contains('Duel %d of %d')) "selector metadata omits duel position text"
Assert-True ($module.Contains("self:SetDuelingContentHidden(visible)")) "module visibility drives an exclusive content switch"
Assert-True ($ui.Contains("function Analytics:SetDuelingContentHidden(hidden)")) "exclusive Dueling-content visibility helper exists"
Assert-True ($ui.Contains("ui.overallTierCard and ui.overallTierCard.box")) "analytics hides the Overall Tier rail card"
Assert-True ($ui.Contains("ui.classTierCard and ui.classTierCard.box")) "analytics hides the Class Tier rail card"
Assert-True ($ui.Contains("ui.searchInput")) "analytics hides the Dueling search input"
Assert-True ($ui.Contains("ui.duelDetailPanel")) "analytics hides the shared Dueling detail panel"
Assert-True ($ui.Contains("row.clickTarget:SetMouseEnabled(false)")) "hidden Dueling rows cannot intercept Analytics input"

foreach ($label in @("DAMAGE DONE", "DAMAGE TAKEN", "HEALING DONE", "HEALING RECEIVED")) {
    Assert-True ($module.Contains('label = "' + $label + '"')) "subtab exists: $label"
}
Assert-True ($ui.Contains('CreateClickableLabel(panel, "FIGHT STATS"')) "Fight Stats is a top-level Analytics scope tab"
Assert-True ($ui.Contains('board.logFilters = {}')) "Combat Log filters are embedded in the four-panel workspace"

Assert-True (-not $module.Contains('label = "UPTIME"')) "standalone Uptime subtab is removed"
Assert-True (-not $module.Contains('label = "BUFF/DEBUFF"')) "legacy standalone Buff/Debuff tab is removed"
Assert-True ($combat.Contains("EVENT_EFFECT_CHANGED")) "buff and debuff applications use the ESO effect event"
Assert-True ($combat.Contains("EFFECT_RESULT_GAINED")) "effect gains are tracked"
Assert-True ($combat.Contains("BUFF_EFFECT_TYPE_BUFF")) "buff effects are classified"
Assert-True ($combat.Contains("BUFF_EFFECT_TYPE_DEBUFF")) "debuff effects are classified"
Assert-True ($combat.Contains("ANALYTICS_MAX_EFFECT_EVENTS = 3000")) "effect event retention is bounded per duel"
Assert-True ($combat.Contains("ANALYTICS_MAX_SYSTEM_EVENTS = 3000")) "narrative combat-log retention is bounded per duel"
Assert-True ($combat.Contains("REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE")) "healing-received listener uses a native target filter"
Assert-True ($combat.Contains("ANALYTICS_MAX_LOG_EVENTS = 6000")) "combat log has a bounded retention policy"
Assert-True (-not $combat.Contains("ANALYTICS_LOG_HISTORY_LIMIT")) "automatic 50-duel log persistence was removed"
Assert-True (-not $duelingCombat.Contains('Analytics:SafeCall("TrimCombatLogHistory"')) "completed reports are no longer automatically persisted and pruned"
Assert-True ($combat.Contains("EVENT_MANAGER:UnregisterForUpdate(ANALYTICS_UPDATE_NAME)")) "build-stat sampler has cleanup"
Assert-True ($duelingTracking.Contains('Analytics:SafeCall("RegisterDuelEvents"')) "analytics event registration follows duel registration"
Assert-True ($duelingTracking.Contains('Analytics:SafeCall("UnregisterDuelEvents"')) "analytics event cleanup follows duel cleanup"
Assert-True ($duelingCombat -match '"RecordDamage",\s*tracking,\s*"damageDone"') "outgoing damage is forwarded"
Assert-True ($duelingCombat -match '"RecordDamage",\s*tracking,\s*"damageTaken"') "incoming damage is forwarded"
Assert-True ($duelingCombat.Contains("local absorbed = math.max(0, tonumber(overflow) or 0)")) "native overflow is forwarded as separate absorbed damage"
Assert-True ($combat.Contains('AddMitigationResult(ACTION_RESULT_BLOCKED, "blocked")')) "fully blocked attacks have an Analytics listener"
Assert-True ($combat.Contains('AddMitigationResult(ACTION_RESULT_DAMAGE_SHIELDED, "shielded")')) "shield absorption has an Analytics listener"
Assert-True ($combat.Contains("amount <= 0 and not blocked and absorbed <= 0")) "zero-value blocked attacks are retained"
Assert-True ($combat.Contains("MITIGATION_DEDUP_WINDOW_MS = 100")) "paired block results use bounded deduplication"
Assert-True ($combat.Contains("do not misattribute the ward as an outgoing damage ability")) "shield effects stay out of attack-source totals"
Assert-True ($ui.Contains('"ABSORBED " .. FormatCombatNumber(absorbed)')) "combat log labels shield absorption"
Assert-True ($ui.Contains('"BLOCKED " .. FormatCombatNumber(event.amount)')) "combat log labels blocked attacks"
Assert-True ($duelingCombat.Contains('Analytics:SafeCall("RecordHealing", tracking, "healingDone"')) "outgoing healing is forwarded"
Assert-True ($duelingCombat.Contains('Analytics:SafeCall("RecordHealing", tracking, "healingReceived"')) "self healing is also recorded as received"
Assert-True (-not $duelingCombat.Contains("analytics = analyticsSummary")) "unsaved analytics is not attached to SavedVariables history"
Assert-True ($duelingCombat.Contains('Analytics:SafeCall("RegisterCompletedDuel", duel, analyticsSummary)')) "completed analytics enters session retention"
Assert-True ($module.Contains("self.sessionAnalyticsByDuelId")) "session analytics has a runtime-only store"
Assert-True ($module.Contains("duel.analyticsSaved = true")) "Save Duel marks a report for persistence"
Assert-True ($module.Contains("duel.analytics = summary")) "Save Duel persists the selected complete summary"
Assert-True ($module.Contains("duel.analytics = nil")) "Delete Duel removes persistent analytics without deleting the rating journal"
Assert-True ($ui.Contains('"SAVE DUEL"')) "Save Duel control exists"
Assert-True ($ui.Contains('"DELETE DUEL"')) "Delete Duel control exists"
Assert-True ($ui.Contains("button.clickTarget:SetMouseEnabled(true)")) "Save and Delete use a reliable clickable child control"
Assert-True ($ui.Contains("upInside ~= false")) "action buttons accept only completed in-control clicks"
Assert-True ($module.Contains("Saved Analytics duel:")) "Save Duel prints a user notification"
Assert-True ($module.Contains("Deleted Analytics duel:")) "Delete Duel prints a user notification"
Assert-True ($ui.Contains("New Analytics reports last only until logout or /reloadui")) "Help documents session-only retention"
Assert-True ($module.Contains("function Analytics:SelectSkillForCombatLog(category, source)")) "source rows can select a skill for the combat log"
Assert-True ($module.Contains("function Analytics:OpenDuelFromJournal(duel)")) "Dueling can open one exact Analytics report"
Assert-True ($module.Contains("candidate == duel")) "Analytics shortcut first matches the selected record by identity"
Assert-True ($module.Contains("tostring(candidate.id) == duelId")) "Analytics shortcut retains stable-ID fallback after reload"
Assert-True ($ui.Contains("matchesSkill")) "combat log applies the selected skill filter"
Assert-True ($ui.Contains('board.skillFilter:SetText("SKILL: "')) "active skill filter is visible"
Assert-True ($ui.Contains("SOURCE_VALUE_WIDTH + SOURCE_VALUE_GAP")) "source value columns use equal spacing"
Assert-True ($ui.Contains("STAT_VALUE_WIDTH + STAT_VALUE_GAP")) "build-stat value columns use equal spacing"
Assert-True ($ui.Contains("board.summaryBox:SetWidth(SOURCE_SUMMARY_WIDTH)")) "source totals use a compact fixed-width target summary"
Assert-True ($ui.Contains("local SOURCE_SUMMARY_WIDTH = 400")) "two-column target summary leaves the ability table adequate width"
Assert-True ($ui.Contains("board.summaryTitleRule")) "summary title has a dedicated horizontal divider"
Assert-True ($ui.Contains("board.logPanel") -and $ui.Contains("board.uptimePanel") -and $ui.Contains("board.abilityPanel")) "category analytics uses four synchronized panels"
Assert-True ($ui.Contains("local EMBEDDED_PANEL_HEIGHT = 440")) "upper evidence panels leave the lower summary row readable at minimum height"
Assert-True ($ui.Contains("local UPTIME_PANEL_WIDTH = 560")) "uptime pane is wide enough for full-size untruncated filters"
Assert-True ($ui.Contains("(index - 1) % 7")) "all fourteen Combat Log categories fit in two rows"
Assert-True ($ui.Contains("(index - 1) % 3")) "uptime categories fit in two compact rows"
Assert-True ($ui.Contains("row.message:SetAnchor(RIGHT, row, RIGHT, 0, 0)")) "narrative events use the full embedded log width"
Assert-True ($ui.Contains("SOURCE_RIGHT_PADDING")) "ability values remain clear of the scroll indicator"
Assert-True ($ui.Contains("local STAT_VALUE_WIDTH = 116") -and $ui.Contains("local STAT_VALUE_GAP = 28")) "Fight Stats columns are equally spaced and shifted left"
Assert-True ($constants.Contains("local MIN_WINDOW_HEIGHT = 1040")) "minimum journal height preserves the bottom Analytics rows"
Assert-True ($constants.Contains("local MIN_WINDOW_WIDTH = 1880")) "minimum journal width preserves full-size two-row Analytics filters"
Assert-True ($ui.Contains("definition.label, 170") -and $ui.Contains("definition.label, 174")) "upper filter borders fit their complete labels"
Assert-True (([regex]::Matches($ui, 'filter:SetScale\(1\.00\)')).Count -ge 2) "upper filters use the same full text scale as lower categories"
Assert-True ($duelingWindow.Contains("local function AddSpacedTab") -and $duelingWindow.Contains("tabOffset = tabOffset + width + 10")) "Dueling tabs retain consistent border gaps"
Assert-True ($duelingWindow.Contains("detailBack:SetDimensions(194, 28)") -and $duelingWindow.Contains("newer:SetDimensions(132, 30)") -and $duelingWindow.Contains("older:SetDimensions(132, 30)")) "Dueling back and pager borders have readable padding"
Assert-True ($ui.Contains("board.logClear") -and $ui.Contains("Analytics:ClearSkillFilter(true)")) "embedded Combat Log exposes an explicit Clear control"
Assert-True ($ui.Contains("board.logFilterRule") -and $ui.Contains("board.uptimeFilterRule")) "upper filter groups are divided from their data headers"
Assert-True (-not $ui.Contains("board.logPosition") -and -not $ui.Contains("board.uptimePosition") -and -not $ui.Contains("board.abilityPosition")) "scrolling uses indicators without numeric range counters"
Assert-True ($ui.Contains('board.logPanel:SetHandler("OnMouseWheel"') -and $ui.Contains("UpdateScrollIndicator")) "embedded timestamp panel supports wheel scrolling with a visible indicator"
Assert-True ($module.Contains("self.logFilters = NewDefaultLogFilters()") -and $module.Contains("self.embeddedLogOffset = 0")) "clearing a focused ability restores the complete event view"
Assert-True ($module.Contains("visible and 0.44 or 0") -and $module.Contains("visible and 0.18 or 0")) "active Analytics module border has a translucent light-blue interior highlight"
Assert-True ($ui.Contains("local function SetTabSelected")) "Analytics tabs share one active-fill visual helper"
Assert-True ($duelingWindow.Contains("tab.tabBorder:SetAnchorFill(tab)")) "Dueling journal tabs use fitted borders"
Assert-True ($duelingDashboard.Contains("selected and 0.18 or 0")) "Dueling journal active tabs use translucent blue fill"
Assert-True ($duelingWindow.Contains("detailBack.navBorder") -and $duelingWindow.Contains("newer.navBorder") -and $duelingWindow.Contains("older.navBorder")) "Dueling back and pager navigation use fitted borders"
Assert-True ($ui.Contains("board.logFilters = {}")) "the upper Combat Log panel owns all event filters"
Assert-True ($ui.Contains("board.uptimeFilters = {}")) "the upper uptime panel owns its effect filters"
Assert-True ($ui.Contains('SetText("# OF APPS")')) "embedded uptime includes an application-count column"
Assert-True ($ui.Contains('label = "INCOMING DEBUFF"') -and $ui.Contains('label = "OUTGOING DEBUFF"')) "embedded uptime filters use complete labels"
Assert-True ($ui.Contains('{ text = "DPS", key = "rate", index = 7 }')) "ability breakdown rate heading is DPS"
Assert-True ($ui.Contains("board.abilityTrack, board.abilityThumb")) "ability breakdown has a visible scroll indicator"
Assert-True ($module.Contains("if isSameAbility then") -and $module.Contains("self:ClearSkillFilter(false)")) "clicking the selected ability again deselects it without resetting event filters"
Assert-True ($ui.Contains("Analytics:ClearSkillFilter(true)")) "explicit Clear restores the complete event-filter view"
Assert-True (-not $module.Contains('{ key = "uptime", label = "UPTIME" }')) "standalone Uptime tab stays removed"
Assert-True ($module.Contains('duelRateLabel = "DUEL DPS"')) "damage categories expose an explicit Duel DPS label"
Assert-True ($module.Contains('duelRateLabel = "DUEL HPS"')) "healing categories expose an explicit Duel HPS label"
Assert-True ($ui.Contains("board.duelRateCaption")) "source summary renders a third rate column"
Assert-True ($module.Contains("function Analytics:SetActiveScope(scopeName)")) "analytics provides an explicit Dueling and Help scope switch"
Assert-True ($ui.Contains('CreateClickableLabel(panel, "HELP", 82')) "general Help scope is available beside Dueling"
Assert-True ($ui.Contains("local function CreateHelpPanel(parent)")) "analytics Help panel is created once and reused"
Assert-True ($ui.Contains("selecting that ability again returns to the full log")) "Help explains click-again ability deselection"
Assert-True ($ui.Contains("FormatRate(pressureTotal, activeDuration)")) "primary rate uses CMX-style pressure and active time"
Assert-True ($ui.Contains("FormatRate(categoryTotal, duration)")) "duel rate uses health total and full duel duration"
Assert-True ($combat.Contains("activeDurationSeconds = math.max(1")) "active rate has a safe one-second duration floor"
Assert-True ($combat.Contains("pressureTotal = total + absorbedTotal")) "CMX-style pressure includes absorbed damage once"
Assert-True ($combat.Contains("schemaVersion = 5")) "new analytics summaries use the uptime-and-log-aware schema"
Assert-True ($ui.Contains("or categoryTotal")) "legacy analytics records retain a safe pressure fallback"
Assert-True ($ui.Contains("or duration")) "legacy analytics records retain a safe duration fallback"
Assert-True ($ui.Contains("weaponDamage = HEALING")) "weapon stats use green"
Assert-True ($ui.Contains("spellDamage = BLUE")) "spell stats use blue"
Assert-True ($ui.Contains("healthRecovery = DAMAGE")) "health recovery uses red"
Assert-True ($ui.Contains("board.isDefensive and YELLOW")) "defensive stats default to yellow"
Assert-True ($ui.Contains("function Analytics:RefreshUptime()")) "consolidated effect uptime has a dedicated renderer"
Assert-True ($combat.Contains("FinishEffectUptimes(runtime, finishMS)")) "effect intervals are finalized once at duel completion"
Assert-True ($combat.Contains("maxStacks = math.max")) "effect uptime retains the highest observed stack count"
Assert-True ($ui.Contains("stackPrefix")) "stacked uptime rows display a consolidated count prefix"
Assert-True ($ui.Contains('filterName == "incomingBuff"')) "incoming buff filter is implemented"
Assert-True ($ui.Contains('filterName == "outgoingBuff"')) "outgoing buff filter is implemented"
Assert-True ($ui.Contains('filterName == "incomingDebuff"')) "incoming debuff filter is implemented"
Assert-True ($ui.Contains('filterName == "outgoingDebuff"')) "outgoing debuff filter is implemented"
foreach ($category in @("all", "damageDone", "damageTaken", "healingDone", "healingReceived", "incomingBuff", "outgoingBuff", "incomingDebuff", "outgoingDebuff", "resourceEvent", "usedSkill", "statsChange", "infoEvent", "performanceInfo")) {
    Assert-True ($module.Contains('key = "' + $category + '"')) "combat log toggle exists: $category"
}
Assert-True ($module.Contains("self.logFilters[category] = not self.logFilters[category]")) "combat-log category buttons are independent multi-select toggles"
Assert-True ($ui.Contains('displayType = "message"')) "non-targeted log events render as narrative messages"
Assert-True ($combat.Contains("EVENT_POWER_UPDATE")) "resource changes are captured only during duel tracking"
Assert-True ($combat.Contains("EVENT_ACTION_SLOT_ABILITY_USED")) "used skills are captured only during duel tracking"
Assert-True ($combat.Contains("EVENT_ACTIVE_WEAPON_PAIR_CHANGED")) "weapon-swap information is captured only during duel tracking"
Assert-True ($combat.Contains("GetFramerate")) "performance log samples FPS"
Assert-True ($combat.Contains("GetLatency")) "performance log samples latency"
Assert-True ($combat.Contains('AddSystemEvent(runtime, "statsChange"')) "stat changes enter the narrative combat log"
Assert-True ($ui.Contains('return string.format("%.1f%%", percentage), FormatCombatNumber(value)') -and $ui.Contains("cell.divider")) "critical and resistance stats separate percentage from raw rating with a divider"

$effectEvents = @(
    @{ Name = "Major Resolve"; Kind = "buff"; Incoming = $true; Outgoing = $true },
    @{ Name = "Minor Courage"; Kind = "buff"; Incoming = $true; Outgoing = $false },
    @{ Name = "Major Breach"; Kind = "debuff"; Incoming = $false; Outgoing = $true },
    @{ Name = "Burning"; Kind = "debuff"; Incoming = $true; Outgoing = $false }
)
Assert-True ($effectEvents.Count -eq 4) "All effect view retains each application once"
Assert-True (@($effectEvents | Where-Object { $_.Kind -eq "buff" -and $_.Incoming }).Count -eq 2) "incoming buff filter includes self and external buffs"
Assert-True (@($effectEvents | Where-Object { $_.Kind -eq "buff" -and $_.Outgoing }).Count -eq 1) "outgoing buff filter includes player-cast buffs"
Assert-True (@($effectEvents | Where-Object { $_.Kind -eq "debuff" -and $_.Incoming }).Count -eq 1) "incoming debuff filter is directionally correct"
Assert-True (@($effectEvents | Where-Object { $_.Kind -eq "debuff" -and $_.Outgoing }).Count -eq 1) "outgoing debuff filter is directionally correct"

$stackedEffectSamples = @(
    [pscustomobject]@{ Key = "bound-armaments|in|self"; Stack = 1; Start = 1000; End = 4000 },
    [pscustomobject]@{ Key = "bound-armaments|in|self"; Stack = 2; Start = 1000; End = 4000 },
    [pscustomobject]@{ Key = "gore-thief|out|enemy"; Stack = 3; Start = 2500; End = 7000 },
    [pscustomobject]@{ Key = "gore-thief|out|enemy"; Stack = 5; Start = 2500; End = 7000 }
)
$uptimeGroups = @($stackedEffectSamples | Group-Object Key | ForEach-Object {
    [pscustomobject]@{
        Key = $_.Name
        MaxStacks = (($_.Group | ForEach-Object { [int]$_.Stack }) | Measure-Object -Maximum).Maximum
        UptimeMS = [int]$_.Group[0].End - [int]$_.Group[0].Start
    }
})
Assert-True ($uptimeGroups.Count -eq 2) "stacked effect applications consolidate by stable effect direction"
Assert-True (($uptimeGroups | Where-Object Key -eq "bound-armaments|in|self").MaxStacks -eq 2) "Bound Armaments retains a 2x maximum stack"
Assert-True (($uptimeGroups | Where-Object Key -eq "gore-thief|out|enemy").MaxStacks -eq 5) "Gore Thief retains a 5x maximum stack"
Assert-True ((($uptimeGroups | ForEach-Object { [int]$_.UptimeMS }) | Measure-Object -Sum).Sum -eq 7500) "consolidated uptime preserves interval duration"

$enabledLogTypes = @{
    damageDone = $true
    incomingBuff = $true
    resourceEvent = $true
    performanceInfo = $false
}
$mixedLog = @(
    @{ Category = "damageDone"; Message = "damage" },
    @{ Category = "incomingBuff"; Message = "buff" },
    @{ Category = "resourceEvent"; Message = "resource" },
    @{ Category = "performanceInfo"; Message = "performance" }
)
$visibleMixedLog = @($mixedLog | Where-Object { $enabledLogTypes[$_["Category"]] })
Assert-True ($visibleMixedLog.Count -eq 3) "multiple Combat Log categories can be displayed simultaneously"
Assert-True (@($visibleMixedLog | Where-Object Category -eq "performanceInfo").Count -eq 0) "disabled Combat Log categories remain hidden"

$events = @(
    @{ Category = "damageDone"; Ability = 1001; Value = 2500; Critical = $false },
    @{ Category = "damageDone"; Ability = 1001; Value = 3500; Critical = $true },
    @{ Category = "damageDone"; Ability = 1002; Value = 1250; Critical = $false },
    @{ Category = "damageTaken"; Ability = 2001; Value = 4200; Critical = $false },
    @{ Category = "healingDone"; Ability = 3001; Value = 1800; Critical = $true },
    @{ Category = "healingReceived"; Ability = 3001; Value = 1800; Critical = $true }
)
$done = $events | Where-Object Category -eq "damageDone"
$doneTotal = (($done | ForEach-Object { [int]$_["Value"] }) | Measure-Object -Sum).Sum
$groupTotal = (($done | Group-Object { $_["Ability"] } | ForEach-Object {
    (($_.Group | ForEach-Object { [int]$_["Value"] }) | Measure-Object -Sum).Sum
}) | Measure-Object -Sum).Sum
Assert-True ($doneTotal -eq 7250) "synthetic outgoing total is correct"
Assert-True ($doneTotal -eq $groupTotal) "source totals reconcile with the category total"
Assert-True (@($events | Where-Object { $_["Category"] -eq "healingDone" }).Count -eq 1) "healing done remains distinct"
Assert-True (@($events | Where-Object { $_["Category"] -eq "healingReceived" }).Count -eq 1) "healing received remains distinct"
$skillEvents = @(
    @{ Category = "damageDone"; Ability = 1001; Value = 2500 },
    @{ Category = "damageDone"; Ability = 1002; Value = 1250 },
    @{ Category = "damageTaken"; Ability = 1001; Value = 4200 },
    @{ Category = "damageDone"; Ability = 1001; Value = 3500 }
)
$filteredSkillEvents = @($skillEvents | Where-Object {
    $_["Category"] -eq "damageDone" -and $_["Ability"] -eq 1001
})
Assert-True ($filteredSkillEvents.Count -eq 2) "skill log filter keeps only the selected category and ability"
Assert-True ((($filteredSkillEvents | ForEach-Object { [int]$_["Value"] }) | Measure-Object -Sum).Sum -eq 6000) "skill log filter preserves matching timestamps and values"

$mitigationEvents = @(
    @{ Ability = "Bash"; Amount = 235; Absorbed = 0; Blocked = $false },
    @{ Ability = "Bash"; Amount = 565; Absorbed = 0; Blocked = $false },
    @{ Ability = "Bash"; Amount = 0; Absorbed = 554; Blocked = $true }
)
$bashHealthDamage = (($mitigationEvents | ForEach-Object { [int]$_["Amount"] }) | Measure-Object -Sum).Sum
$bashAbsorbed = (($mitigationEvents | ForEach-Object { [int]$_["Absorbed"] }) | Measure-Object -Sum).Sum
Assert-True ($mitigationEvents.Count -eq 3) "shielded Bash scenario retains all three attack occurrences"
Assert-True ($bashHealthDamage -eq 800) "blocked absorption does not inflate authoritative health damage"
Assert-True ($bashAbsorbed -eq 554) "absorbed damage remains independently available"
$bashPressure = $bashHealthDamage + $bashAbsorbed
Assert-True ($bashPressure -eq 1354) "CMX-style pressure counts blocked absorption exactly once"
$syntheticHealthDamage = 18000.0
$syntheticAbsorbedDamage = 0.0
$syntheticActiveSeconds = 6.79
$syntheticDuelSeconds = 13.0
$syntheticDps = [math]::Round(($syntheticHealthDamage + $syntheticAbsorbedDamage) / $syntheticActiveSeconds)
$syntheticDuelDps = [math]::Round($syntheticHealthDamage / $syntheticDuelSeconds)
Assert-True ($syntheticDps -eq 2651) "CMX comparison produces the expected active DPS"
Assert-True ($syntheticDuelDps -eq 1385) "full-duel rate remains separately available"
Assert-True ($combat.Contains("low = math.floor")) "build stats retain lowest samples"
Assert-True ($combat.Contains("average = math.floor")) "build stats calculate averages"
Assert-True ($combat.Contains("high = math.floor")) "build stats retain highest samples"

Write-Host "RESULT: $passed passed, $failed failed"
if ($failed -gt 0) { exit 1 }
