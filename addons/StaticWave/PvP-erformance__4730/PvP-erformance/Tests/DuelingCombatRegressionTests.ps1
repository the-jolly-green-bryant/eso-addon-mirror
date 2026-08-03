param(
    [string]$AddonRoot = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = "Stop"
$script:Passed = 0
$script:Failed = 0

function Assert-True {
    param([bool]$Condition, [string]$Name)
    if ($Condition) {
        $script:Passed++
        Write-Host "PASS: $Name"
    } else {
        $script:Failed++
        Write-Host "FAIL: $Name"
    }
}

function Format-CombatNumberForExpectation {
    param([double]$Value)
    $whole = [math]::Floor([math]::Max(0, $Value))
    return $whole.ToString("N0", [Globalization.CultureInfo]::InvariantCulture)
}

$constantsPath = Join-Path $AddonRoot "Core\Constants.lua"
$combatPath = Join-Path $AddonRoot "Modules\Dueling\DuelingCombat.lua"
$historyPath = Join-Path $AddonRoot "Modules\Dueling\DuelingHistory.lua"
$detailsPath = Join-Path $AddonRoot "Modules\Dueling\UI\DuelingDetails.lua"
$windowPath = Join-Path $AddonRoot "Modules\Dueling\UI\DuelingWindow.lua"
$dashboardPath = Join-Path $AddonRoot "Modules\Dueling\UI\DuelingDashboard.lua"

$constants = Get-Content -LiteralPath $constantsPath -Raw
$combat = Get-Content -LiteralPath $combatPath -Raw
$history = Get-Content -LiteralPath $historyPath -Raw
$details = Get-Content -LiteralPath $detailsPath -Raw
$window = Get-Content -LiteralPath $windowPath -Raw
$dashboard = Get-Content -LiteralPath $dashboardPath -Raw

$numberCases = @{
    0 = "0"
    694 = "694"
    2400 = "2,400"
    7200 = "7,200"
    10700 = "10,700"
    32200 = "32,200"
    1234567 = "1,234,567"
}
foreach ($case in $numberCases.GetEnumerator()) {
    Assert-True ((Format-CombatNumberForExpectation ([double]$case.Key)) -eq $case.Value) "full number formatting: $($case.Key)"
}

$formatterMatch = [regex]::Match(
    $constants,
    'local function FormatCombatNumber\(value\)(?<body>[\s\S]*?)\r?\nend'
)
Assert-True $formatterMatch.Success "shared FormatCombatNumber helper exists"
Assert-True ($formatterMatch.Groups['body'].Value -match 'gsub\("\^\(%d\+\)\(%d%d%d\)"') "formatter inserts comma groups"
Assert-True ($details -notmatch 'FormatDamage\(') "detailed summary contains no compact FormatDamage calls"
Assert-True (([regex]::Matches($details, 'FormatCombatNumber\(')).Count -ge 5) "summary totals and source metrics use exact formatter"
Assert-True ($history -match 'return FormatCombatNumber\(value / duration\)') "DPS and HPS use exact formatter"
Assert-True ($window.Contains("moduleTabBorder:SetAnchorFill(moduleTab)")) "Dueling module selector has a fitted border"
Assert-True ($dashboard.Contains("self.ui.moduleTabBorder:SetEdgeColor")) "Dueling module selector border has active and inactive states"
Assert-True ($dashboard.Contains("isDuelingActive and 0.18 or 0")) "active Dueling module border has a translucent light-blue interior highlight"
Assert-True ($window.Contains('duelDetailAnalyticsButton.label:SetText("GO TO ANALYTICS")')) "duel summary provides a Go to Analytics action"
Assert-True ($window.Contains("Analytics:OpenDuelFromJournal")) "duel summary action forwards the selected duel to Analytics"
Assert-True ($details.Contains("Analytics:GetAnalyticsForDuel(duel)")) "duel summary detects whether Analytics data is available"

$resultsMatch = [regex]::Match(
    $constants,
    'local DAMAGE_COMBAT_RESULTS = \{(?<body>[\s\S]*?)\r?\n\}'
)
Assert-True $resultsMatch.Success "damage result list exists"
$resultNames = @([regex]::Matches($resultsMatch.Groups['body'].Value, 'ACTION_RESULT_[A-Z_]+') | ForEach-Object Value)
$legitimateResults = @(
    'ACTION_RESULT_DAMAGE',
    'ACTION_RESULT_CRITICAL_DAMAGE',
    'ACTION_RESULT_DOT_TICK',
    'ACTION_RESULT_DOT_TICK_CRITICAL',
    'ACTION_RESULT_BLOCKED_DAMAGE'
)
foreach ($result in $legitimateResults) {
    Assert-True ($resultNames -contains $result) "legitimate result retained: $result"
}
Assert-True ($resultNames -notcontains 'ACTION_RESULT_DAMAGE_SHIELDED') "shield absorption excluded from damage registration"
Assert-True ($resultNames -notcontains 'ACTION_RESULT_CRITICAL_DAMAGE_SHIELDED') "critical shield absorption excluded from damage registration"
Assert-True ($combat -match 'if not IsDamageCombatResult\(result\) then\s*return') "combat callback has fail-safe result guard"

$events = @(
    [pscustomobject]@{ Result = 'ACTION_RESULT_DAMAGE_SHIELDED'; Source = 'Calculated Defense'; Value = 8000 },
    [pscustomobject]@{ Result = 'ACTION_RESULT_DAMAGE'; Source = 'Light Attack'; Value = 1000 },
    [pscustomobject]@{ Result = 'ACTION_RESULT_CRITICAL_DAMAGE'; Source = 'Crystal Fragments'; Value = 2200 },
    [pscustomobject]@{ Result = 'ACTION_RESULT_DOT_TICK'; Source = 'Burning'; Value = 3300 },
    [pscustomobject]@{ Result = 'ACTION_RESULT_BLOCKED_DAMAGE'; Source = 'Bound Armaments'; Value = 4400 }
)
$sources = @{}
foreach ($event in $events) {
    if ($resultNames -contains $event.Result) {
        $currentValue = 0
        if ($sources.ContainsKey($event.Source)) {
            $currentValue = [double]$sources[$event.Source]
        }
        $sources[$event.Source] = $currentValue + $event.Value
    }
}
Assert-True (-not $sources.ContainsKey('Calculated Defense')) "Calculated Defense does not enter Damage Done"
foreach ($name in @('Light Attack', 'Crystal Fragments', 'Burning', 'Bound Armaments')) {
    Assert-True $sources.ContainsKey($name) "legitimate source remains: $name"
}
$sourceTotal = [double](($sources.Values | Measure-Object -Sum).Sum)
Assert-True ($sourceTotal -eq 10900) "accepted damage total reconciles with source rows"
Assert-True ($combat -match 'total = total \+ entry\.total') "production summary derives total from accepted source rows"

Write-Host "RESULT: $script:Passed passed, $script:Failed failed"
if ($script:Failed -gt 0) {
    exit 1
}
