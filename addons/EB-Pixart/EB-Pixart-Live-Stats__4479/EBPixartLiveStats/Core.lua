EBPixartLiveStats = EBPixartLiveStats or {}

local Addon = EBPixartLiveStats

Addon.name = "EBPixartLiveStats"
Addon.displayName = "EB-Pixart Live Stats"
Addon.version = "0.1.0"
Addon.savedVariablesName = "EBPixartLiveStats_SV"
Addon.eventNamespace = Addon.name .. "_Events"
Addon.statsEventNamespace = Addon.name .. "_Stats"
Addon.sessionEventNamespace = Addon.name .. "_Session"
Addon.statsDebounceNamespace = Addon.name .. "_StatsDebounce"
Addon.statsRefreshIntervalMs = 1000
Addon.defaultOffsetX = 200
Addon.defaultOffsetY = 200
Addon.defaultHealWindowOffsetX = 560
Addon.defaultHealWindowOffsetY = 200
Addon.defaultAppearance = {
    fontSizeLabels = 18,
    fontSizeValues = 18,
    windowWidth = 320,
    windowHeight = 300,
    labelColorR = 0.82,
    labelColorG = 0.82,
    labelColorB = 0.82,
    labelColorA = 0.95,
    valueColorR = 1,
    valueColorG = 1,
    valueColorB = 1,
    valueColorA = 1,
    titleColorR = 1,
    titleColorG = 1,
    titleColorB = 1,
    titleColorA = 0.98,
}
Addon.defaultHealWindowAppearance = {
    fontSizeLabels = 16,
    fontSizeValues = 16,
    width = 420,
    height = 360,
    labelColorR = 0.82,
    labelColorG = 0.82,
    labelColorB = 0.82,
    labelColorA = 0.95,
    valueColorR = 1,
    valueColorG = 1,
    valueColorB = 1,
    valueColorA = 1,
    titleColorR = 1,
    titleColorG = 1,
    titleColorB = 1,
    titleColorA = 0.98,
}

Addon.defaults = {
    debug = false,
    unlocked = false,
    healAnalysisAutoTracking = false,
    autoResetEnabled = true,
    autoResetDelaySeconds = 10,
    showDps = true,
    showDamage = true,
    showHealing = true,
    showCombatState = false,
    showSpellCrit = false,
    showWeaponCrit = false,
    showSpellPower = false,
    showWeaponPower = false,
    showSpellPen = false,
    showWeaponPen = false,
    showIncomingHealingPercent = false,
    showBlockPercent = false,
    showBlockCost = false,
    showPhysicalResistance = false,
    showSpellResistance = false,
    showCriticalResistance = false,
    defaultOffsetX = Addon.defaultOffsetX,
    defaultOffsetY = Addon.defaultOffsetY,
    fontSizeLabels = Addon.defaultAppearance.fontSizeLabels,
    fontSizeValues = Addon.defaultAppearance.fontSizeValues,
    windowWidth = Addon.defaultAppearance.windowWidth,
    windowHeight = Addon.defaultAppearance.windowHeight,
    labelColorR = Addon.defaultAppearance.labelColorR,
    labelColorG = Addon.defaultAppearance.labelColorG,
    labelColorB = Addon.defaultAppearance.labelColorB,
    labelColorA = Addon.defaultAppearance.labelColorA,
    valueColorR = Addon.defaultAppearance.valueColorR,
    valueColorG = Addon.defaultAppearance.valueColorG,
    valueColorB = Addon.defaultAppearance.valueColorB,
    valueColorA = Addon.defaultAppearance.valueColorA,
    titleColorR = Addon.defaultAppearance.titleColorR,
    titleColorG = Addon.defaultAppearance.titleColorG,
    titleColorB = Addon.defaultAppearance.titleColorB,
    titleColorA = Addon.defaultAppearance.titleColorA,
    ui = {
        hidden = false,
        offsetX = Addon.defaultOffsetX,
        offsetY = Addon.defaultOffsetY,
        width = Addon.defaultAppearance.windowWidth,
        height = Addon.defaultAppearance.windowHeight,
    },
    healWindow = {
        hidden = false,
        unlocked = false,
        offsetX = Addon.defaultHealWindowOffsetX,
        offsetY = Addon.defaultHealWindowOffsetY,
        width = Addon.defaultHealWindowAppearance.width,
        height = Addon.defaultHealWindowAppearance.height,
        fontSizeLabels = Addon.defaultHealWindowAppearance.fontSizeLabels,
        fontSizeValues = Addon.defaultHealWindowAppearance.fontSizeValues,
        labelColorR = Addon.defaultHealWindowAppearance.labelColorR,
        labelColorG = Addon.defaultHealWindowAppearance.labelColorG,
        labelColorB = Addon.defaultHealWindowAppearance.labelColorB,
        labelColorA = Addon.defaultHealWindowAppearance.labelColorA,
        valueColorR = Addon.defaultHealWindowAppearance.valueColorR,
        valueColorG = Addon.defaultHealWindowAppearance.valueColorG,
        valueColorB = Addon.defaultHealWindowAppearance.valueColorB,
        valueColorA = Addon.defaultHealWindowAppearance.valueColorA,
        titleColorR = Addon.defaultHealWindowAppearance.titleColorR,
        titleColorG = Addon.defaultHealWindowAppearance.titleColorG,
        titleColorB = Addon.defaultHealWindowAppearance.titleColorB,
        titleColorA = Addon.defaultHealWindowAppearance.titleColorA,
    },
    stats = {
        totalDamage = 0,
        totalHealing = 0,
        combatStartAt = 0,
        lastCombatEndAt = 0,
    },
    lastSessionSnapshot = nil,
}

local function Chat(message)
    d(string.format("[|c00C853%s|r] %s", Addon.displayName, message))
end

function Addon:Print(message)
    Chat(message)
end

function Addon:InitializeSavedVariables()
    -- Stockage account-wide pour partager les reglages entre personnages.
    self.sv = ZO_SavedVars:NewAccountWide(self.savedVariablesName, 1, nil, self.defaults)
end

function Addon:InitializeModules()
    -- Les modules sont initialises apres les SavedVariables pour qu'ils puissent les lire.
    if self.Combat and self.Combat.Initialize then
        self.Combat:Initialize()
    end

    if self.Session and self.Session.Initialize then
        self.Session:Initialize()
    end

    if self.Share and self.Share.Initialize then
        self.Share:Initialize()
    end

    if self.UI and self.UI.Initialize then
        self.UI:Initialize()
    end

    if self.HealUI and self.HealUI.Initialize then
        self.HealUI:Initialize()
    end

    if self.Stats and self.Stats.Initialize then
        self.Stats:Initialize()
    end

    if self.Settings and self.Settings.Initialize then
        self.Settings:Initialize()
    end
end

function Addon:ToggleWindow()
    if self.UI and self.UI.ToggleVisibility then
        self.UI:ToggleVisibility()
    else
        self:Print(GetString(EBPXLIVESTATS_CHAT_NOT_READY))
    end
end

function Addon:ToggleHealWindow()
    if self.HealUI and self.HealUI.ToggleVisibility then
        self.HealUI:ToggleVisibility()
    else
        self:Print(GetString(EBPXLIVESTATS_CHAT_NOT_READY))
    end
end

function Addon:ManualResetSession()
    if self.Session and self.Session.ManualResetNow then
        self.Session:ManualResetNow()
    else
        self:Print(GetString(EBPXLIVESTATS_CHAT_NOT_READY))
    end
end

function Addon:ShareCurrentSession()
    if self.Share and self.Share.ShareCurrentSessionSummary then
        self.Share:ShareCurrentSessionSummary()
    else
        self:Print(GetString(EBPXLIVESTATS_CHAT_NOT_READY))
    end
end

function Addon:ShareLastSession()
    if self.Share and self.Share.ShareLastSnapshotSummary then
        self.Share:ShareLastSnapshotSummary()
    else
        self:Print(GetString(EBPXLIVESTATS_CHAT_NOT_READY))
    end
end

function Addon:ShareCurrentHeals()
    if self.Share and self.Share.ShareCurrentHealSummary then
        self.Share:ShareCurrentHealSummary()
    else
        self:Print(GetString(EBPXLIVESTATS_CHAT_NOT_READY))
    end
end

function Addon:ShareLastHeals()
    if self.Share and self.Share.ShareLastSnapshotHealSummary then
        self.Share:ShareLastSnapshotHealSummary()
    else
        self:Print(GetString(EBPXLIVESTATS_CHAT_NOT_READY))
    end
end

function Addon:RegisterSlashCommands()
    SLASH_COMMANDS["/ebstats"] = function()
        self:ToggleWindow()
    end

    SLASH_COMMANDS["/ebhealdump"] = function()
        if self.Combat and self.Combat.DumpHealingDebug then
            self.Combat:DumpHealingDebug()
        end
    end

    SLASH_COMMANDS["/ebhealreset"] = function()
        if self.Combat and self.Combat.ResetHealAnalysis then
            self.Combat:ResetHealAnalysis(false)
            if self.HealUI and self.HealUI.RefreshAll then
                self.HealUI:RefreshAll()
            end
            self:Print("Heal Analysis reset.")
        end
    end

    SLASH_COMMANDS["/ebhealstart"] = function()
        if self.Combat and self.Combat.StartHealAnalysisTracking then
            self.Combat:StartHealAnalysisTracking()
            if self.HealUI and self.HealUI.RefreshAll then
                self.HealUI:RefreshAll()
            end
            self:Print("Heal Analysis tracking started.")
        end
    end

    SLASH_COMMANDS["/ebhealstop"] = function()
        if self.Combat and self.Combat.StopHealAnalysisTracking then
            self.Combat:StopHealAnalysisTracking()
            if self.HealUI and self.HealUI.RefreshAll then
                self.HealUI:RefreshAll()
            end
            self:Print("Heal Analysis tracking stopped.")
        end
    end

    SLASH_COMMANDS["/ebhealstartreset"] = function()
        if self.Combat and self.Combat.ResetHealAnalysis then
            self.Combat:ResetHealAnalysis(true)
            if self.HealUI and self.HealUI.RefreshAll then
                self.HealUI:RefreshAll()
            end
            self:Print("Heal Analysis tracking started from a clean state.")
        end
    end

    SLASH_COMMANDS["/ebhealwindow"] = function()
        self:ToggleHealWindow()
    end

    SLASH_COMMANDS["/eblock"] = function()
        if self.UI and self.UI.SetUnlocked then
            self.UI:SetUnlocked(false)
            self:Print("Fenetre verrouillee.")
        end
    end

    SLASH_COMMANDS["/ebunlock"] = function()
        if self.UI and self.UI.SetUnlocked then
            self.UI:SetUnlocked(true)
            self:Print("Fenetre deverrouillee.")
        end
    end

    SLASH_COMMANDS["/ebresetui"] = function()
        if self.UI and self.UI.ResetPosition then
            self.UI:ResetPosition()
            self:Print("Position de la fenetre reinitialisee.")
        end
    end

    SLASH_COMMANDS["/ebuidump"] = function()
        self:DumpUIState()
    end

    SLASH_COMMANDS["/ebresetnow"] = function()
        self:ManualResetSession()
    end

    SLASH_COMMANDS["/ebsharecurrent"] = function()
        self:ShareCurrentSession()
    end

    SLASH_COMMANDS["/ebsharelast"] = function()
        self:ShareLastSession()
    end

    SLASH_COMMANDS["/ebshareheals"] = function()
        self:ShareCurrentHeals()
    end

    SLASH_COMMANDS["/ebsharelastheals"] = function()
        self:ShareLastHeals()
    end
end

function Addon:RefreshUI()
    if self.UI and self.UI.RefreshAll then
        self.UI:RefreshAll()
    end

    if self.HealUI and self.HealUI.RefreshAll then
        self.HealUI:RefreshAll()
    end
end

function Addon:DumpUIState()
    if not self.UI or not self.UI.rows then
        self:Print("UI not ready.")
        return
    end

    local desired = self.UI.GetDesiredVisibilityState and self.UI:GetDesiredVisibilityState() or {}
    self:Print(string.format("hiddenWindow=%s", tostring(self.sv.ui.hidden)))
    self:Print(string.format("showDps=%s", tostring(self.sv.showDps)))
    self:Print(string.format("showDamage=%s", tostring(self.sv.showDamage)))
    self:Print(string.format("showHealing=%s", tostring(self.sv.showHealing)))
    self:Print(string.format("showCombatState=%s", tostring(self.sv.showCombatState)))
    self:Print(string.format("showSpellCrit=%s", tostring(self.sv.showSpellCrit)))
    self:Print(string.format("showWeaponCrit=%s", tostring(self.sv.showWeaponCrit)))
    self:Print(string.format("showSpellPower=%s", tostring(self.sv.showSpellPower)))
    self:Print(string.format("showWeaponPower=%s", tostring(self.sv.showWeaponPower)))
    self:Print(string.format("showSpellPen=%s", tostring(self.sv.showSpellPen)))
    self:Print(string.format("showWeaponPen=%s", tostring(self.sv.showWeaponPen)))
    self:Print(string.format("showOutgoingHealingPercent=%s", tostring(self.sv.showOutgoingHealingPercent)))
    self:Print(string.format("showIncomingHealingPercent=%s", tostring(self.sv.showIncomingHealingPercent)))
    self:Print(string.format("showBlockPercent=%s", tostring(self.sv.showBlockPercent)))
    self:Print(string.format("showBlockCost=%s", tostring(self.sv.showBlockCost)))
    self:Print(string.format("showMoveSpeedPercent=%s", tostring(self.sv.showMoveSpeedPercent)))
    self:Print(string.format("showPhysicalResistance=%s", tostring(self.sv.showPhysicalResistance)))
    self:Print(string.format("showSpellResistance=%s", tostring(self.sv.showSpellResistance)))
    self:Print(string.format("showCriticalResistance=%s", tostring(self.sv.showCriticalResistance)))
    self:Print(string.format("healAnalysisAutoTracking=%s", tostring(self.sv.healAnalysisAutoTracking)))
    self:Print(string.format("autoResetEnabled=%s", tostring(self.sv.autoResetEnabled)))
    self:Print(string.format("autoResetDelaySeconds=%s", tostring(self.sv.autoResetDelaySeconds)))
    if self.Combat and self.Combat.IsHealAnalysisTracking then
        self:Print(string.format("healAnalysisTracking=%s", tostring(self.Combat:IsHealAnalysisTracking())))
    end

    local orderedRows = {
        "dps",
        "damage",
        "healing",
        "combat",
        "spellCrit",
        "weaponCrit",
        "spellPower",
        "weaponPower",
        "spellPen",
        "weaponPen",
        "outgoingHealingPercent",
        "incomingHealingPercent",
        "blockPercent",
        "blockCost",
        "moveSpeedPercent",
        "physicalResistance",
        "spellResistance",
        "criticalResistance",
    }

    for _, rowKey in ipairs(orderedRows) do
        local row = self.UI.rows[rowKey]
        local actualHidden = row and row.container and row.container:IsHidden()
        self:Print(string.format("%s desired=%s actualHidden=%s", rowKey, tostring(desired[rowKey]), tostring(actualHidden)))
    end
end

function Addon:RegisterStatsRefresh()
    EVENT_MANAGER:UnregisterForEvent(self.statsEventNamespace, EVENT_STATS_UPDATED)
    EVENT_MANAGER:UnregisterForEvent(self.statsEventNamespace, EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(self.statsEventNamespace, EVENT_ACTIVE_WEAPON_PAIR_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(self.statsEventNamespace, EVENT_MOUNTED_STATE_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(self.statsEventNamespace, EVENT_PLAYER_ACTIVATED)
    EVENT_MANAGER:UnregisterForUpdate(self.statsEventNamespace)
    EVENT_MANAGER:UnregisterForUpdate(self.statsDebounceNamespace)

    local function RequestRefresh(delayMs)
        self:QueueStatsRefresh(delayMs)
    end

    EVENT_MANAGER:RegisterForEvent(self.statsEventNamespace, EVENT_STATS_UPDATED, function(_, unitTag)
        RequestRefresh(50)
    end)
    EVENT_MANAGER:AddFilterForEvent(self.statsEventNamespace, EVENT_STATS_UPDATED, REGISTER_FILTER_UNIT_TAG, "player")

    EVENT_MANAGER:RegisterForEvent(self.statsEventNamespace, EVENT_EFFECT_CHANGED, function(_, changeType, effectSlot, effectName, unitTag)
        RequestRefresh(75)
    end)
    EVENT_MANAGER:AddFilterForEvent(self.statsEventNamespace, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")

    EVENT_MANAGER:RegisterForEvent(self.statsEventNamespace, EVENT_ACTIVE_WEAPON_PAIR_CHANGED, function()
        RequestRefresh(50)
    end)

    EVENT_MANAGER:RegisterForEvent(self.statsEventNamespace, EVENT_MOUNTED_STATE_CHANGED, function()
        RequestRefresh(50)
    end)

    EVENT_MANAGER:RegisterForEvent(self.statsEventNamespace, EVENT_PLAYER_ACTIVATED, function()
        RequestRefresh(50)
    end)

    -- Fallback leger pour couvrir les cas ou l'evenement manque une mise a jour.
    EVENT_MANAGER:RegisterForUpdate(self.statsEventNamespace, self.statsRefreshIntervalMs, function()
        self:RefreshUI()
    end)
end

function Addon:QueueStatsRefresh(delayMs)
    local delay = zo_max(25, tonumber(delayMs) or 75)

    EVENT_MANAGER:UnregisterForUpdate(self.statsDebounceNamespace)
    EVENT_MANAGER:RegisterForUpdate(self.statsDebounceNamespace, delay, function()
        EVENT_MANAGER:UnregisterForUpdate(self.statsDebounceNamespace)
        self:RefreshUI()
    end)
end

function Addon:Initialize()
    self:InitializeSavedVariables()
    self:InitializeModules()
    self:RegisterSlashCommands()
    self:RegisterStatsRefresh()
    self:RefreshUI()
    self:Print(zo_strformat(GetString(EBPXLIVESTATS_CHAT_LOADED), self.displayName, self.version))
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= Addon.name then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(Addon.name, EVENT_ADD_ON_LOADED)
    Addon:Initialize()
end

EVENT_MANAGER:RegisterForEvent(Addon.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
