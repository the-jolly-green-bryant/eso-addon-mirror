local ADDON_NAME = "NextTryUltimateTracker"
local Addon = {}
_G[ADDON_NAME] = Addon

Addon.name = ADDON_NAME
Addon.displayName = "NextTry Ultimate Tracker"
Addon.version = "1.2.0"

local EVENT_NAMESPACE = ADDON_NAME .. "_Events"
local ULTIMATE_SLOT = ACTION_BAR_ULTIMATE_SLOT_INDEX + 1
local ULTIMATE_POWER_TYPE = COMBAT_MECHANIC_FLAGS_ULTIMATE
local WEREWOLF_POWER_TYPE = COMBAT_MECHANIC_FLAGS_WEREWOLF
local ACTION_BUTTON_TRACEBACK_PATTERN = 'keybind = ".*ACTION_BUTTON_(%d+)'
local WEREWOLF_REVERT_ABILITY_IDS = {
    [28292] = true, -- Werewolf Transformation / revert base id
    [32455] = true, -- Werewolf Transformation
    [32457] = true, -- Werewolf Transformation morph / revert id
    [39075] = true, -- Pack Leader
    [39076] = true, -- Werewolf Berserker
}
local WEREWOLF_BLOCK_MESSAGE_DEBOUNCE_MS = 1200
local werewolfBlockLastMessageAt = 0
local werewolfBlockLastButtonUpAt = 0
local ULTIMATE_BLOCK_MESSAGE_DEBOUNCE_MS = 1200
local ultimateBlockLastMessageAt = 0
local ultimateBlockLastButtonUpAt = 0
local TEXT_MAX_WIDTH = 720
local TEXT_PADDING_HORIZONTAL = 24
local TEXT_PADDING_TOP = 8
local TEXT_PADDING_BOTTOM = 8

local ZONE_CATEGORY = {
    OVERLAND = "overland",
    DELVE_PUBLIC = "delvePublic",
    DUNGEON = "dungeon",
    TRIAL = "trial",
    ARENA = "arena",
    ENDLESS_ARCHIVE = "endlessArchive",
    PVP = "pvp",
    HOUSING = "housing",
    UNKNOWN = "unknown",
}
local ARENA_ZONE_IDS = {
    [635] = true, -- Dragonstar Arena
    [677] = true, -- Maelstrom Arena
    [1082] = true, -- Blackrose Prison
    [1227] = true, -- Vateshran Hollows
}
local ARENA_PARENT_ZONE_IDS = {
    [1207] = true, -- Vateshran Hollows parent
}
local ENDLESS_ARCHIVE_ZONE_IDS = {
    [1436] = true,
    [1438] = true,
}
local ENDLESS_ARCHIVE_PARENT_ZONE_IDS = {
    [1413] = true,
    [1438] = true,
}

Addon.soundOptions = {
    { label = "ABILITY_COMPANION_ULTIMATE_READY", value = SOUNDS and SOUNDS.ABILITY_COMPANION_ULTIMATE_READY or "ABILITY_COMPANION_ULTIMATE_READY" },
    { label = "ABILITY_SYNERGY_READY", value = SOUNDS and SOUNDS.ABILITY_SYNERGY_READY or "ABILITY_SYNERGY_READY" },
    { label = "ABILITY_ULTIMATE_READY", value = SOUNDS and SOUNDS.ABILITY_ULTIMATE_READY or "ABILITY_ULTIMATE_READY" },
    { label = "ACHIEVEMENT_AWARDED", value = SOUNDS and SOUNDS.ACHIEVEMENT_AWARDED or "ACHIEVEMENT_AWARDED" },
    { label = "ACTIVE_SKILL_MORPH_CHOSEN", value = SOUNDS and SOUNDS.ACTIVE_SKILL_MORPH_CHOSEN or "ACTIVE_SKILL_MORPH_CHOSEN" },
    { label = "ANTIQUITIES_FANFARE_COMPLETED", value = SOUNDS and SOUNDS.ANTIQUITIES_FANFARE_COMPLETED or "ANTIQUITIES_FANFARE_COMPLETED" },
    { label = "ANTIQUITIES_FANFARE_FRAGMENT_FOUND", value = SOUNDS and SOUNDS.ANTIQUITIES_FANFARE_FRAGMENT_FOUND or "ANTIQUITIES_FANFARE_FRAGMENT_FOUND" },
    { label = "AVA_GATE_OPENED", value = SOUNDS and SOUNDS.AVA_GATE_OPENED or "AVA_GATE_OPENED" },
    { label = "AVA_GATE_CLOSED", value = SOUNDS and SOUNDS.AVA_GATE_CLOSED or "AVA_GATE_CLOSED" },
    { label = "BATTLEGROUND_CAPTURE_AREA_CAPTURED_OTHER_TEAM", value = SOUNDS and SOUNDS.BATTLEGROUND_CAPTURE_AREA_CAPTURED_OTHER_TEAM or "BATTLEGROUND_CAPTURE_AREA_CAPTURED_OTHER_TEAM" },
    { label = "BATTLEGROUND_CAPTURE_AREA_MOVED", value = SOUNDS and SOUNDS.BATTLEGROUND_CAPTURE_AREA_MOVED or "BATTLEGROUND_CAPTURE_AREA_MOVED" },
    { label = "BATTLEGROUND_CAPTURE_AREA_SPAWNED", value = SOUNDS and SOUNDS.BATTLEGROUND_CAPTURE_AREA_SPAWNED or "BATTLEGROUND_CAPTURE_AREA_SPAWNED" },
    { label = "BATTLEGROUND_COUNTDOWN_FINISH", value = SOUNDS and SOUNDS.BATTLEGROUND_COUNTDOWN_FINISH or "BATTLEGROUND_COUNTDOWN_FINISH" },
    { label = "BATTLEGROUND_ONE_MINUTE_WARNING", value = SOUNDS and SOUNDS.BATTLEGROUND_ONE_MINUTE_WARNING or "BATTLEGROUND_ONE_MINUTE_WARNING" },
    { label = "BLACKSMITH_IMPROVE_TOOLTIP_GLOW_SUCCESS", value = SOUNDS and SOUNDS.BLACKSMITH_IMPROVE_TOOLTIP_GLOW_SUCCESS or "BLACKSMITH_IMPROVE_TOOLTIP_GLOW_SUCCESS" },
    { label = "CROWN_CRATES_GAIN_GEMS", value = SOUNDS and SOUNDS.CROWN_CRATES_GAIN_GEMS or "CROWN_CRATES_GAIN_GEMS" },
    { label = "INSTANCE_SHUTDOWN", value = SOUNDS and SOUNDS.INSTANCE_SHUTDOWN or "INSTANCE_SHUTDOWN" },
    { label = "NEW_TIMED_NOTIFICATION", value = SOUNDS and SOUNDS.NEW_TIMED_NOTIFICATION or "NEW_TIMED_NOTIFICATION" },
    { label = "RAID_TRIAL_COUNTER_UPDATE", value = SOUNDS and SOUNDS.RAID_TRIAL_COUNTER_UPDATE or "RAID_TRIAL_COUNTER_UPDATE" },
    { label = "RETRAITING_RETRAIT_TOOLTIP_GLOW_SUCCESS", value = SOUNDS and SOUNDS.RETRAITING_RETRAIT_TOOLTIP_GLOW_SUCCESS or "RETRAITING_RETRAIT_TOOLTIP_GLOW_SUCCESS" },
    { label = "TRIBUTE_AGENT_DAMAGED", value = SOUNDS and SOUNDS.TRIBUTE_AGENT_DAMAGED or "TRIBUTE_AGENT_DAMAGED" },
    { label = "LEVEL_UP_REWARD_CLAIM", value = SOUNDS and SOUNDS.LEVEL_UP_REWARD_CLAIM or "LEVEL_UP_REWARD_CLAIM" },
    { label = "JUSTICE_PICKPOCKET_BONUS", value = SOUNDS and SOUNDS.JUSTICE_PICKPOCKET_BONUS or "JUSTICE_PICKPOCKET_BONUS" },
}

Addon.defaultSound = SOUNDS and SOUNDS.ABILITY_ULTIMATE_READY or "ABILITY_ULTIMATE_READY"

Addon.globalDefaults = {
    enabled = true,
}

Addon.profileDefaults = {
    onlyCombat = true,
    targetBars = "bothFixed",
    testMode = false,
    debug = false,
    soundEnabled = true,
    sound = Addon.defaultSound,
    zoneFilter = {
        enabled = true,
        allowOverland = false,
        allowDelvePublic = false,
        allowDungeonTrial = true,
        allowArena = true,
        allowEndlessArchive = true,
        allowPvp = true,
        allowHousing = true,
    },
    ultimateBlock = {
        mode = "off",
        showMessage = false,
    },
    werewolf = {
        blockRevertInCombat = false,
        showBlockMessage = true,
        playBlockSound = false,
    },
    box = {
        show = true, unlocked = true, x = 500, y = 500,
        width = 60, height = 60, color = { 0.08, 0.08, 0.08 },
        alpha = 1, blinkColor = { 1, 0.5764706135, 0 }, blinkSpeed = 750,
        drawLayer = DL_BACKGROUND, drawLevel = 0, drawTier = DT_HIGH,
    },
    text = {
        show = true, unlocked = true, x = 800, y = 450, fontSize = 30,
        mode = "compact",
        color = { 1, 1, 1 }, backgroundColor = { 0.035, 0.035, 0.045 }, backgroundAlpha = 0.92,
    },
}


Addon.state = {
    inCombat = false,
    currentPower = 0,
    currentWerewolfPower = 0,
    currentWerewolfMax = 0,
    currentWerewolfEffectiveMax = 0,
    activeHotbar = HOTBAR_CATEGORY_PRIMARY,
    werewolfActive = false,
    ready = false,
    readyEntries = {},
    readyByHotbar = {},
    warningActive = false,
    soundReady = false,
    initialized = false,
    currentScan = {},
    scanPool = {},
    configuredHotbars = {},
    orderedReadyEntries = {},
    textDetails = {},
    zoneAllowed = true,
    currentZoneCategory = ZONE_CATEGORY.UNKNOWN,
    currentZoneInfo = nil,
}

local function L(stringId)
    return GetString(stringId)
end

local function FormatAbilityName(abilityId)
    if not abilityId or abilityId <= 0 then return "" end
    local rawName = GetAbilityName(abilityId) or ""
    if rawName == "" then return "" end
    return tostring(ZO_CachedStrFormat(SI_ABILITY_NAME, rawName) or "")
end

function Addon:Print(message)
    if NextTryShared and NextTryShared.Chat and NextTryShared.Chat.Print then
        local handled = NextTryShared.Chat.Print(self.displayName, tostring(message))
        if handled then return end
    end
    local text = string.format("[%s] %s", self.displayName, tostring(message))
    if CHAT_ROUTER and CHAT_ROUTER.AddSystemMessage then
        CHAT_ROUTER:AddSystemMessage(text)
    elseif d then
        d(text)
    end
end

function Addon:Debug(message)
    if self.sv and self.sv.debug then self:Print("DEBUG: " .. tostring(message)) end
end

local function Clamp(value, minimum, maximum)
    return zo_clamp(tonumber(value) or minimum, minimum, maximum)
end

local function ClearTable(target)
    if type(target) ~= "table" then return {} end
    for key in pairs(target) do
        target[key] = nil
    end
    return target
end

local function GetPooledTable(pool, index)
    if type(pool) ~= "table" then return {} end
    local target = pool[index]
    if type(target) ~= "table" then
        target = {}
        pool[index] = target
    else
        ClearTable(target)
    end
    return target
end

local function HotbarName(hotbarCategory)
    if hotbarCategory == HOTBAR_CATEGORY_PRIMARY then return L(NEXTTRYULTIMATETRACKER_FRONTBAR) end
    if hotbarCategory == HOTBAR_CATEGORY_BACKUP then return L(NEXTTRYULTIMATETRACKER_BACKBAR) end
    if hotbarCategory == HOTBAR_CATEGORY_WEREWOLF then return L(NEXTTRYULTIMATETRACKER_WEREWOLF_BAR) end
    return tostring(hotbarCategory)
end

local function BoolText(value)
    if value == nil then return "n/a" end
    return value and "yes" or "no"
end

local function CleanZoneValue(value)
    value = tonumber(value)
    if not value or value <= 0 then return nil end
    return value
end

local function SafeFormatZoneName(rawName)
    if not rawName or rawName == "" then return "" end
    if zo_strformat and SI_ZONE_NAME then
        local ok, formatted = pcall(zo_strformat, SI_ZONE_NAME, rawName)
        if ok and formatted and formatted ~= "" then return formatted end
    end
    return rawName
end

local function GetZoneDataEnglishName(zoneData)
    if type(zoneData) ~= "table" then return nil end
    local directKeys = { "nameEn", "nameEN", "englishName", "nameEnglish", "zoneNameEn", "zoneNameEN" }
    for _, key in ipairs(directKeys) do
        local value = zoneData[key]
        if type(value) == "string" and value ~= "" then return value end
    end
    local nested = zoneData.names or zoneData.name
    if type(nested) == "table" then
        local value = nested.en or nested.EN or nested.english
        if type(value) == "string" and value ~= "" then return value end
    end
    return nil
end

local function GetZoneIdentifiers()
    local zoneIndex = GetUnitZoneIndex and GetUnitZoneIndex("player") or nil
    local zoneId
    if zoneIndex and GetZoneId then
        zoneId = CleanZoneValue(GetZoneId(zoneIndex))
    end
    local parentZoneId
    if zoneId and GetParentZoneId then
        parentZoneId = CleanZoneValue(GetParentZoneId(zoneId))
    end
    local rawZoneName = ""
    if zoneIndex and GetZoneNameByIndex then
        rawZoneName = GetZoneNameByIndex(zoneIndex) or ""
    end
    return {
        zoneIndex = zoneIndex,
        zoneId = zoneId,
        parentZoneId = parentZoneId,
        rawZoneName = rawZoneName,
        zoneName = SafeFormatZoneName(rawZoneName),
    }
end

local function SafeLibZoneCall(libZone, methodName, ...)
    if type(libZone) ~= "table" or type(libZone[methodName]) ~= "function" then
        return false, nil, nil, nil, nil, "missing"
    end
    local ok, first, second, third, fourth = pcall(libZone[methodName], libZone, ...)
    if not ok then
        return false, nil, nil, nil, nil, "error: " .. tostring(first)
    end
    return true, first, second, third, fourth, nil
end

local function GetZoneData(libZone, zoneId, parentZoneId)
    if type(libZone) ~= "table" or type(libZone.zoneData) ~= "table" then return nil end
    return (zoneId and libZone.zoneData[zoneId]) or (parentZoneId and libZone.zoneData[parentZoneId])
end

local function IsKnownArenaZone(zoneId, parentZoneId)
    return (zoneId and ARENA_ZONE_IDS[zoneId] == true)
        or (parentZoneId and ARENA_PARENT_ZONE_IDS[parentZoneId] == true)
end

local function IsKnownEndlessArchiveZone(zoneId, parentZoneId)
    return (zoneId and ENDLESS_ARCHIVE_ZONE_IDS[zoneId] == true)
        or (parentZoneId and ENDLESS_ARCHIVE_PARENT_ZONE_IDS[parentZoneId] == true)
end

local function ZoneSettingKey(category)
    if category == ZONE_CATEGORY.OVERLAND then return "allowOverland" end
    if category == ZONE_CATEGORY.DELVE_PUBLIC then return "allowDelvePublic" end
    if category == ZONE_CATEGORY.DUNGEON or category == ZONE_CATEGORY.TRIAL then return "allowDungeonTrial" end
    if category == ZONE_CATEGORY.ARENA then return "allowArena" end
    if category == ZONE_CATEGORY.ENDLESS_ARCHIVE then return "allowEndlessArchive" end
    if category == ZONE_CATEGORY.PVP then return "allowPvp" end
    if category == ZONE_CATEGORY.HOUSING then return "allowHousing" end
    return nil
end

local function IsWerewolfActive()
    if IsPlayerInWerewolfForm and IsPlayerInWerewolfForm() == true then return true end
    return GetActiveHotbarCategory and GetActiveHotbarCategory() == HOTBAR_CATEGORY_WEREWOLF
end

local function IsWerewolfAlertMode()
    return Addon.state.werewolfActive
end

local function GetWerewolfPower()
    local current, maximum, effectiveMax = GetUnitPower("player", WEREWOLF_POWER_TYPE)
    return current or 0, maximum or 0, effectiveMax or maximum or 0
end

local function GetNowMilliseconds()
    if GetGameTimeMilliseconds then
        return GetGameTimeMilliseconds()
    end
    if GetFrameTimeMilliseconds then
        return GetFrameTimeMilliseconds()
    end
    return 0
end

local function IsWerewolfFuryActionHighlighted()
    if not ActionSlotHasActivationHighlight then return false end

    local ok, result = pcall(ActionSlotHasActivationHighlight, ULTIMATE_SLOT, HOTBAR_CATEGORY_WEREWOLF)
    if ok and result == true then return true end

    if GetActiveHotbarCategory and GetActiveHotbarCategory() == HOTBAR_CATEGORY_WEREWOLF then
        ok, result = pcall(ActionSlotHasActivationHighlight, ULTIMATE_SLOT)
        if ok and result == true then return true end
    end

    return false
end

local function IsWerewolfFuryPowerReady(current, maximum, effectiveMax)
    local threshold = effectiveMax and effectiveMax > 0 and effectiveMax or maximum
    return threshold ~= nil and threshold > 0 and current ~= nil and current >= threshold, threshold or 0
end

local function GetActiveSlotBoundAbilityId(slotNum)
    if not slotNum then return nil end
    local hotbarCategory = GetActiveHotbarCategory and GetActiveHotbarCategory() or nil
    local abilityId
    if hotbarCategory then
        abilityId = GetSlotBoundId(slotNum, hotbarCategory)
    end
    if not abilityId or abilityId == 0 then
        abilityId = GetSlotBoundId(slotNum)
    end
    return abilityId
end

local function IsWerewolfRevertAbilityId(abilityId)
    return abilityId ~= nil and WEREWOLF_REVERT_ABILITY_IDS[abilityId] == true
end

local function GetConfiguredHotbars(targetTable)
    local hotbars = ClearTable(targetTable)
    local target = Addon.sv.targetBars
    if target == "primary" then
        hotbars[#hotbars + 1] = HOTBAR_CATEGORY_PRIMARY
    elseif target == "backup" then
        hotbars[#hotbars + 1] = HOTBAR_CATEGORY_BACKUP
    elseif target == "bothFixed" then
        hotbars[#hotbars + 1] = HOTBAR_CATEGORY_PRIMARY
        hotbars[#hotbars + 1] = HOTBAR_CATEGORY_BACKUP
    elseif target == "active" then
        hotbars[#hotbars + 1] = Addon.state.activeHotbar
    elseif target == "inactive" then
        hotbars[#hotbars + 1] = Addon.state.activeHotbar == HOTBAR_CATEGORY_PRIMARY
            and HOTBAR_CATEGORY_BACKUP or HOTBAR_CATEGORY_PRIMARY
    else
        -- Defensive fallback for invalid or stale SavedVariables values.
        hotbars[#hotbars + 1] = HOTBAR_CATEGORY_BACKUP
    end
    return hotbars
end

local function IsHudScene()
    return NextTryShared and NextTryShared.WindowVisibility
        and NextTryShared.WindowVisibility.IsHudSceneActive()
end

local function OrderReadyEntries(readyEntries)
    local ordered = ClearTable(Addon.state.orderedReadyEntries)
    for _, entry in ipairs(readyEntries or {}) do
        if entry.hotbarCategory == HOTBAR_CATEGORY_BACKUP then ordered[#ordered + 1] = entry end
    end
    for _, entry in ipairs(readyEntries or {}) do
        if entry.hotbarCategory == HOTBAR_CATEGORY_PRIMARY then ordered[#ordered + 1] = entry end
    end
    for _, entry in ipairs(readyEntries or {}) do
        if entry.hotbarCategory ~= HOTBAR_CATEGORY_BACKUP
            and entry.hotbarCategory ~= HOTBAR_CATEGORY_PRIMARY then
            ordered[#ordered + 1] = entry
        end
    end
    return ordered
end

local function Anchor(control, position)
    control:ClearAnchors()
    control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, position.x, position.y)
end

local function SavePosition(control, position)
    local left, top = control:GetLeft(), control:GetTop()
    if left and top then position.x, position.y = zo_round(left), zo_round(top) end
end

local function PrepareBackdrop(control)
    control:SetAnchorFill()
    control:SetCenterTexture("")
    control:SetEdgeTexture("", 1, 1, 0)
    control:SetEdgeColor(0, 0, 0, 0)
    control:SetInsets(0, 0, 0, 0)
end

local function SetBackdropColor(control, color, alpha)
    control:SetCenterColor(color[1] or 1, color[2] or 1, color[3] or 1, alpha)
end

local function DeepCopy(value)
    if type(value) ~= "table" then return value end
    local copy = {}
    for key, item in pairs(value) do
        copy[key] = DeepCopy(item)
    end
    return copy
end

local function RepairSavedValues(saved, defaults)
    if type(saved) ~= "table" then saved = {} end
    for key, defaultValue in pairs(defaults) do
        local savedValue = saved[key]
        if type(defaultValue) == "table" then
            saved[key] = RepairSavedValues(savedValue, defaultValue)
        elseif type(savedValue) ~= type(defaultValue) then
            saved[key] = defaultValue
        end
    end
    return saved
end

local function IsKnownSound(value)
    if not value or type(Addon.soundOptions) ~= "table" then return false end
    for _, option in ipairs(Addon.soundOptions) do
        if option.value == value then return true end
    end
    return false
end

local function RestoreDefaultValues(saved, defaults)
    for key, defaultValue in pairs(defaults) do
        if type(defaultValue) == "table" then
            if type(saved[key]) ~= "table" then saved[key] = {} end
            RestoreDefaultValues(saved[key], defaultValue)
        else
            saved[key] = defaultValue
        end
    end
end

local function TrimProfileName(name)
    return zo_strtrim(tostring(name or ""))
end

local function NormalizeProfileName(name)
    return zo_strlower(TrimProfileName(name))
end

local function GetCharacterProfileKey()
    if GetCurrentCharacterId then
        local id = GetCurrentCharacterId()
        if id and id ~= 0 then return tostring(id) end
    end
    local name = GetUnitName and GetUnitName("player") or nil
    if name and name ~= "" then return tostring(name) end
    return "account"
end

local function EnsureProfileSettings(profile)
    if type(profile.settings) ~= "table" then profile.settings = {} end
    profile.settings = RepairSavedValues(profile.settings, Addon.profileDefaults)
    if not IsKnownSound(profile.settings.sound) then
        profile.settings.sound = Addon.profileDefaults.sound
    end
    if profile.settings.targetBars == "front" then profile.settings.targetBars = "primary" end
    if profile.settings.targetBars == "back" then profile.settings.targetBars = "backup" end
    if profile.settings.targetBars == "both" then profile.settings.targetBars = "bothFixed" end
    local targetBars = profile.settings.targetBars
    if targetBars ~= "primary" and targetBars ~= "backup" and targetBars ~= "bothFixed"
        and targetBars ~= "active" and targetBars ~= "inactive" then
        profile.settings.targetBars = Addon.profileDefaults.targetBars
    end
    if profile.settings.text.mode ~= "compact" and profile.settings.text.mode ~= "names"
        and profile.settings.text.mode ~= "details" then
        profile.settings.text.mode = Addon.profileDefaults.text.mode
    end
    return profile.settings
end

local function CreateProfile(displayName, sourceSettings)
    return {
        displayName = TrimProfileName(displayName) ~= "" and TrimProfileName(displayName) or "Profile",
        settings = RepairSavedValues(DeepCopy(sourceSettings or Addon.profileDefaults), Addon.profileDefaults),
    }
end

local function SafeCallControlMethod(control, methodName, ...)
    local method = control and control[methodName]
    if type(method) ~= "function" then return false end
    local ok = pcall(method, control, ...)
    return ok == true
end

local function RefreshLamControl(control, forceDefault, value)
    if not control then return end
    if not SafeCallControlMethod(control, "UpdateValue", forceDefault, value) then
        SafeCallControlMethod(control, "updateValue", forceDefault, value)
    end
    if not SafeCallControlMethod(control, "UpdateDisabled") then
        SafeCallControlMethod(control, "updateDisabled")
    end
end

local function RefreshDropdownChoices(control, choices, choiceValues, selectedValue)
    if not control then return end
    if control.data then
        control.data.choices = choices
        control.data.choicesValues = choiceValues
    end
    if not SafeCallControlMethod(control, "UpdateChoices", choices, choiceValues) then
        SafeCallControlMethod(control, "updateChoices", choices, choiceValues)
    end
    RefreshLamControl(control, false, selectedValue)
end

local function BuildLegacyProfileSettings(account)
    local profileSettings = {}
    for key in pairs(Addon.profileDefaults) do
        if type(account[key]) == "table" then
            profileSettings[key] = DeepCopy(account[key])
        elseif account[key] ~= nil then
            profileSettings[key] = account[key]
        end
    end
    return RepairSavedValues(profileSettings, Addon.profileDefaults)
end

local function EnsureProfileOrder(account)
    if type(account.profileOrder) ~= "table" then account.profileOrder = {} end
    local seen = {}
    local order = {}
    for _, profileId in ipairs(account.profileOrder) do
        if type(profileId) == "string" and account.profiles[profileId] and not seen[profileId] then
            table.insert(order, profileId)
            seen[profileId] = true
        end
    end
    if account.profiles.global and not seen.global then
        table.insert(order, 1, "global")
        seen.global = true
    end
    for profileId in pairs(account.profiles) do
        if type(profileId) == "string" and not seen[profileId] then
            table.insert(order, profileId)
            seen[profileId] = true
        end
    end
    account.profileOrder = order
end

function Addon:GetActiveProfileId()
    if not self.accountSv then return "global" end
    local characterKey = self.characterProfileKey or GetCharacterProfileKey()
    local profileId = self.accountSv.activeProfileByCharacter
        and self.accountSv.activeProfileByCharacter[characterKey]
        or nil
    if not profileId or not self.accountSv.profiles or not self.accountSv.profiles[profileId] then
        profileId = "global"
    end
    return profileId
end

function Addon:GetActiveProfile()
    local profileId = self:GetActiveProfileId()
    return self.accountSv and self.accountSv.profiles and self.accountSv.profiles[profileId], profileId
end

function Addon:GetActiveProfileName()
    local profile = self:GetActiveProfile()
    return profile and profile.displayName or self:GetDefaultProfileName()
end

function Addon:IsProfileNameInUse(name, ignoredProfileId)
    local normalized = NormalizeProfileName(name)
    if normalized == "" then return false end
    for profileId, profile in pairs(self.accountSv.profiles or {}) do
        if profileId ~= ignoredProfileId and NormalizeProfileName(profile.displayName) == normalized then
            return true
        end
    end
    return false
end

function Addon:GenerateProfileId()
    self.accountSv.nextProfileIndex = tonumber(self.accountSv.nextProfileIndex) or 1
    local profileId
    repeat
        profileId = string.format("profile_%03d", self.accountSv.nextProfileIndex)
        self.accountSv.nextProfileIndex = self.accountSv.nextProfileIndex + 1
    until not self.accountSv.profiles[profileId]
    return profileId
end

function Addon:GetDefaultProfileName()
    local name = L(NEXTTRYULTIMATETRACKER_PROFILE_DEFAULT)
    if not name or name == "" then return "Default" end
    return name
end

function Addon:GenerateDefaultNewProfileName()
    self.accountSv.nextProfileNameIndex = tonumber(self.accountSv.nextProfileNameIndex) or 1
    local format = L(NEXTTRYULTIMATETRACKER_PROFILE_DEFAULT_NAME_FORMAT)
    if not format or format == "" then format = "Profile %d" end
    local name
    repeat
        name = string.format(format, self.accountSv.nextProfileNameIndex)
        self.accountSv.nextProfileNameIndex = self.accountSv.nextProfileNameIndex + 1
    until not self:IsProfileNameInUse(name)
    return name
end

function Addon:SetActiveProfile(profileId)
    if not self.accountSv or not self.accountSv.profiles or not self.accountSv.profiles[profileId] then
        return false
    end
    self.characterProfileKey = self.characterProfileKey or GetCharacterProfileKey()
    self.accountSv.activeProfileByCharacter[self.characterProfileKey] = profileId
    local profile = self.accountSv.profiles[profileId]
    self.sv = EnsureProfileSettings(profile)
    self.profileNameInput = profile.displayName
    self:RefreshZoneFilterState()
    self:ApplyAppearance()
    self:UpdateUltimateState(true)
    return true
end

function Addon:GetProfileChoices()
    if self.accountSv and self.accountSv.profiles then
        EnsureProfileOrder(self.accountSv)
    end
    local choices = {}
    for _, profileId in ipairs(self.accountSv.profileOrder or {}) do
        local profile = self.accountSv.profiles and self.accountSv.profiles[profileId]
        if profile then table.insert(choices, profile.displayName or profileId) end
    end
    return choices
end

function Addon:GetProfileChoiceValues()
    if self.accountSv and self.accountSv.profiles then
        EnsureProfileOrder(self.accountSv)
    end
    local values = {}
    for _, profileId in ipairs(self.accountSv.profileOrder or {}) do
        if self.accountSv.profiles and self.accountSv.profiles[profileId] then
            table.insert(values, profileId)
        end
    end
    return values
end

function Addon:RequestSettingsRefresh()
    if self.settingsControlRefreshActive then return end

    self.settingsControlRefreshActive = true

    if self.accountSv and self.accountSv.profiles then
        EnsureProfileOrder(self.accountSv)
    end
    if self.RefreshProfileOptionChoices then self:RefreshProfileOptionChoices() end

    local activeProfileId = self:GetActiveProfileId()
    local choices = self.profileChoices or self:GetProfileChoices()
    local choiceValues = self.profileChoiceValues or self:GetProfileChoiceValues()
    RefreshDropdownChoices(_G[self.profileDropdownReference or ""],
        choices, choiceValues, activeProfileId)

    RefreshLamControl(_G[self.profileNameEditboxReference or ""], false, self:GetActiveProfileName())
    RefreshLamControl(_G[self.profileDeleteButtonReference or ""])

    if LibAddonMenu2 and LibAddonMenu2.util and LibAddonMenu2.util.RequestRefreshIfNeeded
        and self.settingsPanel then
        LibAddonMenu2.util.RequestRefreshIfNeeded(self.settingsPanel)
    end

    self.settingsControlRefreshActive = false
end

function Addon:QueueSettingsRefresh()
    if self.settingsRefreshQueued then return end
    self.settingsRefreshQueued = true
    if zo_callLater then
        zo_callLater(function()
            self.settingsRefreshQueued = false
            self:RequestSettingsRefresh()
        end, 50)
    else
        self.settingsRefreshQueued = false
        self:RequestSettingsRefresh()
    end
end

function Addon:CreateProfileFromDefaults()
    local name = self:GenerateDefaultNewProfileName()
    local profileId = self:GenerateProfileId()
    self.accountSv.profiles[profileId] = CreateProfile(name, self.profileDefaults)
    table.insert(self.accountSv.profileOrder, profileId)
    self:SetActiveProfile(profileId)
    self:RequestSettingsRefresh()
    self:QueueSettingsRefresh()
    self:Print(string.format(L(NEXTTRYULTIMATETRACKER_PROFILE_CREATED), name))
end

function Addon:SetActiveProfileName(name)
    local profile, profileId = self:GetActiveProfile()
    if not profile then return end
    if profileId == "global" then
        profile.displayName = self:GetDefaultProfileName()
        self.profileNameInput = profile.displayName
        self:RequestSettingsRefresh()
        self:QueueSettingsRefresh()
        self:Print(L(NEXTTRYULTIMATETRACKER_PROFILE_GLOBAL_PROTECTED))
        return
    end
    name = TrimProfileName(name)
    if name == "" then
        self.profileNameInput = profile.displayName
        self:RequestSettingsRefresh()
        self:QueueSettingsRefresh()
        self:Print(L(NEXTTRYULTIMATETRACKER_PROFILE_NAME_REQUIRED))
        return
    end
    if self:IsProfileNameInUse(name, profileId) then
        self.profileNameInput = profile.displayName
        self:RequestSettingsRefresh()
        self:QueueSettingsRefresh()
        self:Print(string.format(L(NEXTTRYULTIMATETRACKER_PROFILE_NAME_EXISTS), name))
        return
    end
    if profile.displayName == name then return end
    profile.displayName = name
    self.profileNameInput = name
    self:RequestSettingsRefresh()
    self:QueueSettingsRefresh()
    self:Print(string.format(L(NEXTTRYULTIMATETRACKER_PROFILE_RENAMED), name))
end

function Addon:DeleteActiveProfile()
    local profile, profileId = self:GetActiveProfile()
    if not profile then return end
    if profileId == "global" then
        self:Print(L(NEXTTRYULTIMATETRACKER_PROFILE_GLOBAL_PROTECTED))
        return
    end
    local deletedName = profile.displayName or profileId
    self.accountSv.profiles[profileId] = nil
    for index = #self.accountSv.profileOrder, 1, -1 do
        if self.accountSv.profileOrder[index] == profileId then table.remove(self.accountSv.profileOrder, index) end
    end
    for characterKey, activeProfileId in pairs(self.accountSv.activeProfileByCharacter or {}) do
        if activeProfileId == profileId then self.accountSv.activeProfileByCharacter[characterKey] = "global" end
    end
    EnsureProfileOrder(self.accountSv)
    if self.accountSv.profiles.global then
        self.accountSv.profiles.global.displayName = self:GetDefaultProfileName()
    end
    self:SetActiveProfile("global")
    self:RequestSettingsRefresh()
    self:QueueSettingsRefresh()
    self:Print(string.format(L(NEXTTRYULTIMATETRACKER_PROFILE_DELETED), deletedName))
end

function Addon:InitializeSavedVariables()
    self.accountSv = ZO_SavedVars:NewAccountWide("NextTryUltimateTrackerSavedVariables", 1, nil, {})
    if type(self.accountSv.profiles) ~= "table" then
        local legacySettings = BuildLegacyProfileSettings(self.accountSv)
        self.accountSv.profiles = {
            global = CreateProfile(self:GetDefaultProfileName(), legacySettings),
        }
        self.accountSv.profileOrder = { "global" }
        self.accountSv.activeProfileByCharacter = {}
        self.accountSv.nextProfileIndex = 1
        self.accountSv.nextProfileNameIndex = 1
        self.accountSv.enabled = self.accountSv.enabled ~= false
    end

    self.accountSv.enabled = self.accountSv.enabled ~= false
    if type(self.accountSv.nextProfileIndex) ~= "number" then self.accountSv.nextProfileIndex = 1 end
    if type(self.accountSv.nextProfileNameIndex) ~= "number" then self.accountSv.nextProfileNameIndex = 1 end
    if type(self.accountSv.activeProfileByCharacter) ~= "table" then self.accountSv.activeProfileByCharacter = {} end
    if type(self.accountSv.profiles.global) ~= "table" then
        self.accountSv.profiles.global = CreateProfile(self:GetDefaultProfileName(), Addon.profileDefaults)
    end
    self.accountSv.profiles.global.displayName = self:GetDefaultProfileName()
    for _, profile in pairs(self.accountSv.profiles) do
        EnsureProfileSettings(profile)
    end
    EnsureProfileOrder(self.accountSv)

    self.characterProfileKey = GetCharacterProfileKey()
    local activeProfileId = self.accountSv.activeProfileByCharacter[self.characterProfileKey]
    if not activeProfileId or not self.accountSv.profiles[activeProfileId] then
        activeProfileId = "global"
        self.accountSv.activeProfileByCharacter[self.characterProfileKey] = activeProfileId
    end
    self.sv = EnsureProfileSettings(self.accountSv.profiles[activeProfileId])
    self.profileNameInput = self.accountSv.profiles[activeProfileId].displayName
    self:RefreshZoneCache()
end

function Addon:IsLibZoneAvailable()
    return type(LibZone) == "table"
end

function Addon:GetCurrentZoneCategory()
    local info = GetZoneIdentifiers()
    info.libZoneAvailable = self:IsLibZoneAvailable()
    info.category = ZONE_CATEGORY.UNKNOWN
    info.reason = "unknown-or-error"
    info.englishZoneName = "n/a"

    if not info.zoneId then
        info.reason = "zone-id-unavailable"
        return info
    end

    if not info.libZoneAvailable then
        info.reason = "libzone-missing-fail-open"
        return info
    end

    local libZone = LibZone
    local zoneData = GetZoneData(libZone, info.zoneId, info.parentZoneId)
    info.libZoneHasZoneData = type(libZone.zoneData) == "table"
    info.libZoneZoneDataMatched = type(zoneData) == "table"
    info.libZoneDungeonType = info.libZoneZoneDataMatched and zoneData.dungeonType or nil
    info.englishZoneName = GetZoneDataEnglishName(zoneData) or "n/a"

    local okHouse, isHouse, houseSecond, houseThird, houseFourth, houseError = SafeLibZoneCall(libZone, "IsInHouse")
    if houseError and houseError ~= "missing" then
        info.reason = "libzone-house-error-fail-open"
        info.libZoneError = houseError
        return info
    end
    info.libZoneIsInHouse = okHouse and (isHouse == true)
    if okHouse and isHouse == true then
        info.category = ZONE_CATEGORY.HOUSING
        info.reason = "libzone-house"
        return info
    end

    local okPvp, isPvp, pvpSecond, pvpThird, pvpFourth, pvpError = SafeLibZoneCall(libZone, "IsInPVP")
    if pvpError and pvpError ~= "missing" then
        info.reason = "libzone-pvp-error-fail-open"
        info.libZoneError = pvpError
        return info
    end
    info.libZoneIsInPvp = okPvp and (isPvp == true)
    if okPvp and isPvp == true then
        info.category = ZONE_CATEGORY.PVP
        info.reason = "libzone-pvp"
        return info
    end

    local dungeonType = info.libZoneDungeonType
    if dungeonType == 4 then
        info.category = ZONE_CATEGORY.TRIAL
        info.reason = "libzone-dungeon-type-trial"
        return info
    end

    if IsKnownEndlessArchiveZone(info.zoneId, info.parentZoneId) then
        info.category = ZONE_CATEGORY.ENDLESS_ARCHIVE
        info.reason = "known-endless-archive-zone-id"
        return info
    end

    if dungeonType == 3 then
        if IsKnownArenaZone(info.zoneId, info.parentZoneId) then
            info.category = ZONE_CATEGORY.ARENA
            info.reason = "known-arena-zone-id"
        else
            info.category = ZONE_CATEGORY.DUNGEON
            info.reason = "libzone-dungeon-type-dungeon"
        end
        return info
    end

    if dungeonType == 1 or dungeonType == 2 then
        info.category = ZONE_CATEGORY.DELVE_PUBLIC
        info.reason = "libzone-dungeon-type-delve-public"
        return info
    end

    local okDungeon, isInDelve, isInPublicDungeon, isInGroupDungeon, isInRaid, dungeonError =
        SafeLibZoneCall(libZone, "GetCurrentDungeonType")
    if dungeonError and dungeonError ~= "missing" then
        info.reason = "libzone-current-dungeon-type-error-fail-open"
        info.libZoneError = dungeonError
        return info
    end
    info.libZoneCurrentDungeonTypeAvailable = okDungeon == true
    info.libZoneCurrentIsDelve = okDungeon and (isInDelve == true)
    info.libZoneCurrentIsPublicDungeon = okDungeon and (isInPublicDungeon == true)
    info.libZoneCurrentIsGroupDungeon = okDungeon and (isInGroupDungeon == true)
    info.libZoneCurrentIsRaid = okDungeon and (isInRaid == true)

    if okDungeon and isInRaid == true then
        info.category = ZONE_CATEGORY.TRIAL
        info.reason = "libzone-current-dungeon-type-trial"
        return info
    end

    if okDungeon and isInGroupDungeon == true then
        if IsKnownArenaZone(info.zoneId, info.parentZoneId) then
            info.category = ZONE_CATEGORY.ARENA
            info.reason = "known-arena-zone-id"
        else
            info.category = ZONE_CATEGORY.DUNGEON
            info.reason = "libzone-current-dungeon-type-dungeon"
        end
        return info
    end

    if okDungeon and (isInDelve == true or isInPublicDungeon == true) then
        info.category = ZONE_CATEGORY.DELVE_PUBLIC
        info.reason = "libzone-current-dungeon-type-delve-public"
        return info
    end

    if not okDungeon and not info.libZoneZoneDataMatched then
        info.category = ZONE_CATEGORY.UNKNOWN
        info.reason = "libzone-zone-data-missing-fail-open"
        return info
    end

    info.category = ZONE_CATEGORY.OVERLAND
    info.reason = "fallback-overland"
    return info
end

function Addon:RefreshZoneCache()
    self.state.currentZoneInfo = self:GetCurrentZoneCategory()
    return self:RefreshZoneFilterState()
end

function Addon:RefreshZoneFilterState()
    local settings = self.sv and self.sv.zoneFilter
    local info = self.state.currentZoneInfo
    if type(info) ~= "table" then
        info = self:GetCurrentZoneCategory()
        self.state.currentZoneInfo = info
    end

    info.filterEnabled = settings and settings.enabled == true or false

    if not settings or not settings.enabled then
        info.settingKey = nil
        info.categoryAllowed = true
        info.alertAllowed = true
        info.filterReason = "zone-filter-disabled"
    elseif not info.libZoneAvailable then
        info.settingKey = nil
        info.categoryAllowed = true
        info.alertAllowed = true
        info.filterReason = "libzone-missing-fail-open"
    else
        local settingKey = ZoneSettingKey(info.category)
        if not settingKey then
            info.settingKey = nil
            info.categoryAllowed = true
            info.alertAllowed = true
            info.filterReason = "zone-category-unknown-fail-open"
        else
            info.settingKey = settingKey
            info.categoryAllowed = settings[settingKey] ~= false
            info.alertAllowed = info.categoryAllowed
            info.filterReason = info.categoryAllowed
                and "zone-category-allowed"
                or "zone-category-disabled"
        end
    end

    self.state.zoneAllowed = info.alertAllowed == true
    self.state.currentZoneCategory = info.category or ZONE_CATEGORY.UNKNOWN
    return self.state.zoneAllowed, info
end

function Addon:IsCurrentZoneAllowedForAlerts()
    return self:RefreshZoneFilterState()
end

function Addon:PrintZoneInfo()
    local allowed, info = self:RefreshZoneCache()
    local lines = {
        "Zone info",
        string.format("Zone index: %s", tostring(info.zoneIndex or "n/a")),
        string.format("Zone ID: %s", tostring(info.zoneId or "n/a")),
        string.format("Parent zone ID: %s", tostring(info.parentZoneId or "n/a")),
        string.format("Zone name: %s", info.zoneName ~= "" and info.zoneName or "n/a"),
        string.format("Raw zone name: %s", info.rawZoneName ~= "" and info.rawZoneName or "n/a"),
        string.format("English zone name: %s", tostring(info.englishZoneName or "n/a")),
        string.format("LibZone available: %s", BoolText(info.libZoneAvailable)),
        string.format("LibZone error: %s", tostring(info.libZoneError or "n/a")),
        string.format("LibZone IsInHouse: %s", BoolText(info.libZoneIsInHouse)),
        string.format("LibZone IsInPVP: %s", BoolText(info.libZoneIsInPvp)),
        string.format("LibZone zoneData matched: %s", BoolText(info.libZoneZoneDataMatched)),
        string.format("LibZone dungeonType: %s", tostring(info.libZoneDungeonType or "n/a")),
        string.format("LibZone current type: delve=%s public=%s dungeon=%s trial=%s",
            BoolText(info.libZoneCurrentIsDelve), BoolText(info.libZoneCurrentIsPublicDungeon),
            BoolText(info.libZoneCurrentIsGroupDungeon), BoolText(info.libZoneCurrentIsRaid)),
        string.format("Detected category: %s", tostring(info.category)),
        string.format("Detection reason: %s", tostring(info.reason)),
        string.format("Zone filter enabled: %s", BoolText(info.filterEnabled)),
        string.format("Setting key: %s", tostring(info.settingKey or "n/a")),
        string.format("Category allowed: %s", BoolText(info.categoryAllowed)),
        string.format("Alert allowed by zone filter: %s", BoolText(allowed)),
        string.format("Filter reason: %s", tostring(info.filterReason or "n/a")),
    }
    for _, line in ipairs(lines) do
        self:Print(line)
    end
end

function Addon:IsWerewolfFuryReady()
    local scan = ClearTable(self.state.currentScan)
    local readyEntries = ClearTable(self.state.readyEntries)
    local entry = GetPooledTable(self.state.scanPool, 1)
    local current = self.state.currentWerewolfPower or 0
    local maximum = self.state.currentWerewolfMax or 0
    local effectiveMax = self.state.currentWerewolfEffectiveMax or maximum
    local highlightReady = IsWerewolfFuryActionHighlighted() == true
    local powerReady, powerThreshold = IsWerewolfFuryPowerReady(current, maximum, effectiveMax)

    entry.hotbarCategory = HOTBAR_CATEGORY_WEREWOLF
    entry.abilityId = 0
    entry.abilityName = L(NEXTTRYULTIMATETRACKER_WEREWOLF_FURY)
    entry.cost = powerThreshold
    entry.costSource = highlightReady and "activation-highlight" or "werewolf-power"
    entry.power = current
    entry.isWerewolf = true
    entry.werewolfPowerCurrent = current
    entry.werewolfPowerMax = maximum
    entry.werewolfPowerEffectiveMax = effectiveMax
    entry.werewolfPowerThreshold = powerThreshold
    entry.activationReady = highlightReady
    entry.powerReady = powerReady
    entry.isReady = highlightReady or powerReady

    scan[#scan + 1] = entry
    self.state.werewolfFuryReady = entry.isReady
    if entry.isReady then
        readyEntries[#readyEntries + 1] = entry
        return true, readyEntries
    end
    if self.sv.debug then
        self:Debug(string.format("Werewolf Fury not ready: highlight=%s powerReady=%s power=%d/%d effective=%d threshold=%d.",
            tostring(highlightReady), tostring(powerReady), current, maximum, effectiveMax, powerThreshold))
    end
    return false, readyEntries
end

function Addon:IsUltimateReadyForConfiguredBars()
    if IsWerewolfAlertMode() then
        return self:IsWerewolfFuryReady()
    end

    local scan = ClearTable(self.state.currentScan)
    local readyEntries = ClearTable(self.state.readyEntries)
    local configuredHotbars = GetConfiguredHotbars(self.state.configuredHotbars)
    for index, category in ipairs(configuredHotbars) do
        local abilityId = GetSlotBoundId(ULTIMATE_SLOT, category)
        local cost = GetSlotAbilityCost(ULTIMATE_SLOT, ULTIMATE_POWER_TYPE, category)
        local entry = GetPooledTable(self.state.scanPool, index)
        entry.hotbarCategory = category
        entry.abilityId = abilityId
        entry.abilityName = FormatAbilityName(abilityId)
        entry.cost = cost
        entry.costSource = cost and cost > 0 and "api" or "unavailable"
        entry.power = self.state.currentPower
        entry.isReady = abilityId ~= nil and abilityId > 0
            and cost ~= nil and cost > 0 and self.state.currentPower >= cost
        scan[#scan + 1] = entry
        if entry.isReady then
            readyEntries[#readyEntries + 1] = entry
        elseif self.sv.debug and (not cost or cost <= 0) then
            self:Debug(string.format("%s Ultimate cost unavailable; alert suppressed.", HotbarName(category)))
        end
    end
    self.state.werewolfFuryReady = false
    return #readyEntries > 0, readyEntries
end

function Addon:IsAddonEnabled()
    return self.accountSv ~= nil and self.accountSv.enabled ~= false
end

function Addon:BuildWarningState()
    local warningState = self.state.warningState or {}
    self.state.warningState = warningState
    warningState.warningActive = false
    warningState.boxVisible = false
    warningState.textVisible = false
    warningState.zoneAllowed = false
    warningState.combatAllowed = false
    warningState.hasVisibleComponent = false
    if not self:IsAddonEnabled() then return warningState end

    local hudActive = IsHudScene()
    local settingsPreview = self.settingsPreviewActive == true
    if not hudActive and not settingsPreview then return warningState end

    local hasVisibleComponent = self.sv.box.show or self.sv.text.show
    local combatAllowed = not self.sv.onlyCombat or self.state.inCombat
    local zoneAllowed = self:IsCurrentZoneAllowedForAlerts()
    warningState.zoneAllowed = zoneAllowed
    warningState.combatAllowed = combatAllowed
    warningState.hasVisibleComponent = hasVisibleComponent
    warningState.warningActive = hudActive and combatAllowed and zoneAllowed
        and self.state.ready and hasVisibleComponent

    local previewActive = settingsPreview or self.sv.testMode
    warningState.boxVisible = self.sv.box.show
        and (warningState.warningActive or previewActive)
    warningState.textVisible = self.sv.text.show
        and (warningState.warningActive or previewActive)
    return warningState
end

function Addon:BuildSoundReadyState(warningState)
    if not self:IsAddonEnabled() then return false end
    if warningState then
        return warningState.warningActive == true
    end
    local hasVisibleComponent = self.sv.box.show or self.sv.text.show
    local combatAllowed = not self.sv.onlyCombat or self.state.inCombat
    local zoneAllowed = self:IsCurrentZoneAllowedForAlerts()
    return combatAllowed and zoneAllowed and self.state.ready and hasVisibleComponent
end

function Addon:PlayAlertSound()
    local sound = self.sv and self.sv.sound or self.defaultSound
    if not IsKnownSound(sound) then sound = self.defaultSound end
    if sound then PlaySound(sound) end
end

function Addon:ShouldShowAlert()
    local warningState = self:BuildWarningState()
    return warningState.boxVisible or warningState.textVisible
end

function Addon:ApplyAppearance()
    if not self.boxWindow or not self.textWindow then return end
    local box, text = self.sv.box, self.sv.text
    self.boxWindow:SetDimensions(Clamp(box.width, 40, 1000), Clamp(box.height, 20, 1000))
    self.boxWindow:SetDrawLayer(box.drawLayer)
    self.boxWindow:SetDrawLevel(Clamp(box.drawLevel, 0, 200))
    self.boxWindow:SetDrawTier(box.drawTier)
    self.boxWindow:SetMouseEnabled(box.unlocked)
    self.boxWindow:SetMovable(box.unlocked)
    Anchor(self.boxWindow, box)
    SetBackdropColor(self.boxBackground, box.color, 1)
    SetBackdropColor(self.boxBlink, box.blinkColor, 1)
    self.boxWindow:SetAlpha(Clamp(box.alpha, 0, 1))

    self.textWindow:SetMouseEnabled(text.unlocked)
    self.textWindow:SetMovable(text.unlocked)
    Anchor(self.textWindow, text)
    self.textCompactLabel:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thick",
        Clamp(text.fontSize, 12, 72)))
    self.textCompactLabel:SetColor(text.color[1], text.color[2], text.color[3], 1)
    self.textLabel:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thick", Clamp(text.fontSize, 12, 72)))
    self.textLabel:SetColor(text.color[1], text.color[2], text.color[3], 1)
    self.textDetailLabel:SetFont(string.format("$(MEDIUM_FONT)|%d|soft-shadow-thin",
        Clamp(zo_round(text.fontSize * 0.55), 12, 40)))
    self.textDetailLabel:SetColor(text.color[1], text.color[2], text.color[3], 0.82)
    SetBackdropColor(self.textBackground, text.backgroundColor, Clamp(text.backgroundAlpha, 0, 1))
end

local function SetAlertText(title, detail)
    local hasDetail = detail ~= nil and detail ~= ""
    Addon.textWindow:SetResizeToFitDescendents(false)
    Addon.textWindow:SetDimensions(0, 0)

    -- Compact and wrapped layouts use separate labels so no old width or height
    -- survives a mode change. ESO derives the window size from the visible descendants.
    if hasDetail then
        Addon.textCompactLabel:SetText("")
        Addon.textCompactLabel:SetHidden(true)
        Addon.textLabel:SetText(title or "")
        Addon.textLabel:SetHidden(false)
        Addon.textDetailLabel:SetText(detail)
        Addon.textDetailLabel:SetHidden(false)
        Addon.textTitleExtent:SetHidden(false)
    else
        Addon.textLabel:SetText("")
        Addon.textLabel:SetHidden(true)
        Addon.textDetailLabel:SetText("")
        Addon.textDetailLabel:SetHidden(true)
        Addon.textCompactLabel:SetText(title or "")
        Addon.textCompactLabel:SetHidden(false)
        Addon.textTitleExtent:SetHidden(true)
    end

    Addon.textTitleExtent:ClearAnchors()
    if hasDetail then
        Addon.textTitleExtent:SetAnchor(TOPLEFT, Addon.textLabel, TOPRIGHT,
            TEXT_PADDING_HORIZONTAL, 0)
    end
    Addon.textExtent:ClearAnchors()
    Addon.textExtent:SetAnchor(TOPLEFT,
        hasDetail and Addon.textDetailLabel or Addon.textCompactLabel,
        BOTTOMRIGHT, TEXT_PADDING_HORIZONTAL, TEXT_PADDING_BOTTOM)
    Addon.textWindow:SetResizeToFitDescendents(true)
end

function Addon:UpdateAlertText()
    local readyEntries = self.state.readyEntries or {}
    if self.sv.testMode or self.settingsPreviewActive then
        SetAlertText(L(NEXTTRYULTIMATETRACKER_TEST_TEXT), self.displayName)
        return
    end
    local ordered = OrderReadyEntries(readyEntries)
    if #ordered == 0 then
        SetAlertText(L(NEXTTRYULTIMATETRACKER_READY_GENERIC), "")
        return
    end

    local mode = self.sv.text.mode
    if mode == "compact" then
        local first = ordered[1]
        if #ordered == 1 and first and first.isWerewolf then
            SetAlertText(L(NEXTTRYULTIMATETRACKER_WEREWOLF_FURY_READY), "")
        else
            SetAlertText(#ordered > 1
                and L(NEXTTRYULTIMATETRACKER_READY_BOTH)
                or L(NEXTTRYULTIMATETRACKER_READY_GENERIC), "")
        end
        return
    end

    if #ordered == 1 then
        local entry = ordered[1]
        if entry.isWerewolf then
            if mode == "names" then
                SetAlertText(L(NEXTTRYULTIMATETRACKER_WEREWOLF_FURY_READY), HotbarName(entry.hotbarCategory))
            else
                SetAlertText(L(NEXTTRYULTIMATETRACKER_WEREWOLF_FURY_READY),
                    string.format(L(NEXTTRYULTIMATETRACKER_WEREWOLF_FURY_FORMAT),
                        entry.power or 0, entry.cost or 0))
            end
            return
        end
        local name = entry.abilityName ~= "" and entry.abilityName
            or L(NEXTTRYULTIMATETRACKER_UNKNOWN_ULTIMATE)
        local title = string.format(L(NEXTTRYULTIMATETRACKER_READY_NAME_FORMAT), name)
        if mode == "names" then
            SetAlertText(title, HotbarName(entry.hotbarCategory))
        else
            SetAlertText(title, string.format("%s  |  %d / %d",
                HotbarName(entry.hotbarCategory), entry.cost or 0, self.state.currentPower))
        end
        return
    end

    local details = ClearTable(self.state.textDetails)
    for _, entry in ipairs(ordered) do
        if entry.isWerewolf then
            if mode == "names" then
                details[#details + 1] = string.format("%s: %s",
                    HotbarName(entry.hotbarCategory), L(NEXTTRYULTIMATETRACKER_WEREWOLF_FURY))
            else
                details[#details + 1] = string.format("%s: %s",
                    HotbarName(entry.hotbarCategory),
                    string.format(L(NEXTTRYULTIMATETRACKER_WEREWOLF_FURY_FORMAT),
                        entry.power or 0, entry.cost or 0))
            end
        else
            local name = entry.abilityName ~= "" and entry.abilityName
                or L(NEXTTRYULTIMATETRACKER_UNKNOWN_ULTIMATE)
            if mode == "names" then
                details[#details + 1] = string.format("%s: %s", HotbarName(entry.hotbarCategory), name)
            else
                details[#details + 1] = string.format("%s: %s %d/%d",
                    HotbarName(entry.hotbarCategory), name, entry.cost or 0, self.state.currentPower)
            end
        end
    end
    SetAlertText(L(NEXTTRYULTIMATETRACKER_READY_BOTH), table.concat(details, "  |  "))
end

function Addon:ApplyVisibility(warningState)
    if not self.boxWindow or not self.textWindow then return end
    warningState = warningState or self:BuildWarningState()
    self.boxWindow:SetHidden(not warningState.boxVisible)
    self.textWindow:SetHidden(not warningState.textVisible)
    if self.blinkAnimation then
        self.blinkAnimation:Stop(ZO_ALPHA_ANIMATION_OPTION_PREVENT_CALLBACK)
    end
    local maximumAlpha = Clamp(self.sv.box.alpha, 0, 1)
    self.boxWindow:SetAlpha(maximumAlpha)
    if warningState.boxVisible and self.blinkAnimation then
        self.blinkAnimation:PingPong(0, maximumAlpha,
            Clamp(self.sv.box.blinkSpeed, 150, 3000) / 2, LOOP_INDEFINITELY)
    end
    self:UpdateAlertText()
end

function Addon:UpdateUltimateState(suppressSound, overridePower)
    if not self.sv then return end
    if not self:IsAddonEnabled() then
        self.state.ready = false
        ClearTable(self.state.readyEntries)
        ClearTable(self.state.readyByHotbar)
        ClearTable(self.state.currentScan)
        self.state.warningActive = false
        self.state.soundReady = false
        self:ApplyVisibility(self:BuildWarningState())
        return
    end
    self.state.activeHotbar = GetActiveHotbarCategory()
    self.state.werewolfActive = IsWerewolfActive()
    self.state.currentPower = overridePower ~= nil and overridePower
        or select(1, GetUnitPower("player", ULTIMATE_POWER_TYPE)) or 0
    local currentWerewolf, maxWerewolf, effectiveWerewolf = GetWerewolfPower()
    self.state.currentWerewolfPower = currentWerewolf
    self.state.currentWerewolfMax = maxWerewolf
    self.state.currentWerewolfEffectiveMax = effectiveWerewolf

    local isReady, readyEntries = self:IsUltimateReadyForConfiguredBars()
    self.state.ready = isReady
    self.state.readyEntries = readyEntries
    local warningState = self:BuildWarningState()
    self.state.warningActive = warningState.warningActive

    local currentReady = ClearTable(self.state.readyByHotbar)
    for _, entry in ipairs(readyEntries) do
        currentReady[entry.hotbarCategory] = true
    end

    local previousSoundReady = self.state.soundReady == true
    local currentSoundReady = self:BuildSoundReadyState(warningState)
    if not suppressSound and self.sv.soundEnabled and warningState.warningActive
        and currentSoundReady and not previousSoundReady
        and not self.sv.testMode and not self.settingsPreviewActive then
        self:PlayAlertSound()
    end
    self.state.soundReady = currentSoundReady
    self:ApplyVisibility(warningState)
end

function Addon:PrintDebugSummary()
    if not self.sv or not self.sv.debug then return end
    self:UpdateUltimateState(true)
    local zoneAllowed, zoneInfo = self:IsCurrentZoneAllowedForAlerts()
    self:Print(string.format("active=%s power=%d target=%s ready=%s werewolf=%s fury=%d/%d effective=%d furyReady=%s blockWW=%s zone=%s zoneAllowed=%s reason=%s",
        HotbarName(self.state.activeHotbar), self.state.currentPower,
        tostring(self.sv.targetBars), tostring(self.state.ready),
        tostring(self.state.werewolfActive), self.state.currentWerewolfPower or 0,
        self.state.currentWerewolfMax or 0, self.state.currentWerewolfEffectiveMax or 0,
        tostring(self.state.werewolfFuryReady),
        tostring(self.sv.werewolf and self.sv.werewolf.blockRevertInCombat),
        tostring(zoneInfo and zoneInfo.category), tostring(zoneAllowed),
        tostring(zoneInfo and zoneInfo.filterReason or zoneInfo and zoneInfo.reason)))
    for _, entry in ipairs(self.state.currentScan) do
        self:Print(string.format("%s id=%s name=%s cost=%s source=%s power=%s ready=%s highlight=%s powerReady=%s",
            HotbarName(entry.hotbarCategory), tostring(entry.abilityId),
            tostring(entry.abilityName), tostring(entry.cost), tostring(entry.costSource),
            tostring(entry.power), tostring(entry.isReady), tostring(entry.activationReady), tostring(entry.powerReady)))
    end
end

function Addon:DebugWerewolfBlockDecision(decision, reason, slotNum, abilityId,
    isKnownRevertAbility, actionHighlight, powerReady)
    if not self.sv or not self.sv.debug then return end
    self:Debug(string.format(
        "Werewolf block decision=%s reason=%s slot=%s activeHotbar=%s werewolf=%s combat=%s abilityId=%s knownRevert=%s actionHighlight=%s powerReady=%s",
        tostring(decision), tostring(reason), tostring(slotNum), tostring(GetActiveHotbarCategory()),
        tostring(IsWerewolfActive()), tostring(IsUnitInCombat("player")), tostring(abilityId),
        tostring(isKnownRevertAbility), tostring(actionHighlight), tostring(powerReady)))
end

function Addon:ShouldBlockWerewolfRevert(slotNum)
    if not self:IsAddonEnabled() then return false end
    if not self.sv or not self.sv.werewolf or not self.sv.werewolf.blockRevertInCombat then
        self:DebugWerewolfBlockDecision("allow", "option-disabled", slotNum)
        return false
    end
    if slotNum ~= ULTIMATE_SLOT then
        self:DebugWerewolfBlockDecision("allow", "not-ultimate-slot", slotNum)
        return false
    end
    if not IsUnitInCombat("player") then
        self:DebugWerewolfBlockDecision("allow", "not-in-combat", slotNum)
        return false
    end
    if not IsWerewolfActive() then
        self:DebugWerewolfBlockDecision("allow", "not-werewolf", slotNum)
        return false
    end
    if GetActiveHotbarCategory() ~= HOTBAR_CATEGORY_WEREWOLF then
        self:DebugWerewolfBlockDecision("allow", "not-werewolf-hotbar", slotNum)
        return false
    end

    local abilityId = GetActiveSlotBoundAbilityId(slotNum)
    local isKnownRevertAbility = IsWerewolfRevertAbilityId(abilityId)
    local highlightReady = IsWerewolfFuryActionHighlighted() == true
    local current, maximum, effectiveMax = GetWerewolfPower()
    local powerReady = IsWerewolfFuryPowerReady(current, maximum, effectiveMax)

    if highlightReady or powerReady then
        self:DebugWerewolfBlockDecision("allow", highlightReady and "allow-highlight-ready" or "allow-power-ready",
            slotNum, abilityId, isKnownRevertAbility, highlightReady, powerReady)
        return false
    end

    if isKnownRevertAbility then
        self:DebugWerewolfBlockDecision("block", "block-known-revert-not-ready",
            slotNum, abilityId, isKnownRevertAbility, highlightReady, powerReady)
        return true
    end

    -- Unknown and non-revert abilities must fail open so the Fury action is never
    -- blocked merely because the activation highlight is delayed in this hook.
    self:DebugWerewolfBlockDecision("allow", "allow-not-known-revert",
        slotNum, abilityId, isKnownRevertAbility, highlightReady, powerReady)
    return false
end

function Addon:DebugUltimateBlockDecision(decision, reason, slotNum, activeHotbar, mode)
    if not self.sv or not self.sv.debug then return end
    self:Debug(string.format(
        "Ultimate block slotNum=%s activeHotbarCategory=%s mode=%s decision=%s reason=%s",
        tostring(slotNum), tostring(activeHotbar), tostring(mode), tostring(decision), tostring(reason)))
end

function Addon:ShouldBlockUltimateByBar(slotNum)
    if not self:IsAddonEnabled() then return false end
    if slotNum ~= ULTIMATE_SLOT then return false end

    local settings = self.sv and self.sv.ultimateBlock
    local mode = settings and settings.mode or "off"
    local activeHotbar = GetActiveHotbarCategory()

    if mode == "off" then
        self:DebugUltimateBlockDecision("allow", "ultimate-block-mode-off",
            slotNum, activeHotbar, mode)
        return false
    end

    if activeHotbar ~= HOTBAR_CATEGORY_PRIMARY and activeHotbar ~= HOTBAR_CATEGORY_BACKUP then
        self:DebugUltimateBlockDecision("allow", "ultimate-block-not-normal-hotbar",
            slotNum, activeHotbar, mode)
        return false
    end

    if mode == "primary" and activeHotbar == HOTBAR_CATEGORY_PRIMARY then
        self:DebugUltimateBlockDecision("block", "ultimate-block-primary",
            slotNum, activeHotbar, mode)
        return true
    end
    if mode == "backup" and activeHotbar == HOTBAR_CATEGORY_BACKUP then
        self:DebugUltimateBlockDecision("block", "ultimate-block-backup",
            slotNum, activeHotbar, mode)
        return true
    end
    if mode == "bothFixed" then
        self:DebugUltimateBlockDecision("block", "ultimate-block-both",
            slotNum, activeHotbar, mode)
        return true
    end

    self:DebugUltimateBlockDecision("allow", "ultimate-block-allow-current-bar",
        slotNum, activeHotbar, mode)
    return false
end

local function ExtractActionButtonSlotFromTraceback()
    if not debug or not debug.traceback then return nil end
    local trace = debug.traceback()
    if not trace then return nil end
    return tonumber(trace:match(ACTION_BUTTON_TRACEBACK_PATTERN))
end

function Addon:HandleBlockedWerewolfRevert(slotNum)
    if not self:IsAddonEnabled() then return end
    local now = GetNowMilliseconds()

    if self.sv.werewolf.showBlockMessage then
        if werewolfBlockLastMessageAt == 0
            or now == 0
            or (now - werewolfBlockLastMessageAt) >= WEREWOLF_BLOCK_MESSAGE_DEBOUNCE_MS then
            self:Print(L(NEXTTRYULTIMATETRACKER_WEREWOLF_REVERT_BLOCKED))
            werewolfBlockLastMessageAt = now
        end
    end

    if self.sv.werewolf.playBlockSound then
        local sounds = SOUNDS
        local sound = sounds and (sounds.NEGATIVE_CLICK or sounds.GENERAL_ALERT_ERROR or sounds.ABILITY_ULTIMATE_READY)
        if sound then PlaySound(sound) end
    end

    -- Match LibSkillBlocker's safe reset, but never let this create persistent
    -- blocker state. If ESO asks CanUseActionSlots more than once for the same
    -- key press, the block decision is recalculated every time instead of
    -- relying on a latched flag that can get stuck.
    if ZO_ActionBar_OnActionButtonUp and slotNum then
        local shouldResetButton = werewolfBlockLastButtonUpAt == 0
            or now == 0
            or (now - werewolfBlockLastButtonUpAt) >= 100
        if shouldResetButton then
            werewolfBlockLastButtonUpAt = now
            ZO_ActionBar_OnActionButtonUp(slotNum)
        end
    end
end

function Addon:HandleBlockedUltimateByBar(slotNum)
    if not self:IsAddonEnabled() then return end
    local now = GetNowMilliseconds()

    if self.sv.ultimateBlock.showMessage ~= false
        and (ultimateBlockLastMessageAt == 0
            or now == 0
            or (now - ultimateBlockLastMessageAt) >= ULTIMATE_BLOCK_MESSAGE_DEBOUNCE_MS) then
        self:Print(L(NEXTTRYULTIMATETRACKER_ULTIMATE_BLOCKED))
        ultimateBlockLastMessageAt = now
    end

    if ZO_ActionBar_OnActionButtonUp and slotNum then
        local shouldResetButton = ultimateBlockLastButtonUpAt == 0
            or now == 0
            or (now - ultimateBlockLastButtonUpAt) >= 100
        if shouldResetButton then
            ultimateBlockLastButtonUpAt = now
            ZO_ActionBar_OnActionButtonUp(slotNum)
        end
    end
end

function Addon:HookUltimateBlockers()
    if self.ultimateBlockHooked then return end
    if not ZO_PreHook then
        self:Debug("ZO_PreHook unavailable; Ultimate blocking is disabled.")
        return
    end

    -- Important: do not latch a previous block decision. A missing button-up can
    -- otherwise leave the addon blocking future ultimate presses after combat or
    -- after leaving werewolf form. Always recalculate the full block condition.
    ZO_PreHook("ZO_ActionBar_CanUseActionSlots", function()
        if not Addon:IsAddonEnabled() then return false end
        local slotNum = ExtractActionButtonSlotFromTraceback()
        if slotNum ~= ULTIMATE_SLOT then return false end

        local activeHotbar = GetActiveHotbarCategory()
        if activeHotbar == HOTBAR_CATEGORY_WEREWOLF then
            if Addon:ShouldBlockWerewolfRevert(slotNum) then
                Addon:HandleBlockedWerewolfRevert(slotNum)
                return true
            end
            return false
        end

        if Addon:ShouldBlockUltimateByBar(slotNum) then
            Addon:HandleBlockedUltimateByBar(slotNum)
            return true
        end
        return false
    end)
    self.ultimateBlockHooked = true
end

function Addon:ToggleWerewolfRevertLock()
    self.sv.werewolf.blockRevertInCombat = not self.sv.werewolf.blockRevertInCombat
    self:Print(string.format(L(NEXTTRYULTIMATETRACKER_WEREWOLF_LOCK_STATE),
        tostring(self.sv.werewolf.blockRevertInCombat)))
end

function Addon:SetLocked(locked)
    self.sv.box.unlocked = not locked
    self.sv.text.unlocked = not locked
    self:ApplyAppearance()
    self:UpdateUltimateState(true)
    self:Print(locked and L(NEXTTRYULTIMATETRACKER_LOCKED) or L(NEXTTRYULTIMATETRACKER_UNLOCKED))
end

function Addon:CreateUI()
    local wm = WINDOW_MANAGER
    self.boxWindow = wm:CreateTopLevelWindow(ADDON_NAME .. "Box")
    self.boxWindow:SetClampedToScreen(true)
    self.boxWindow:SetHandler("OnMoveStop", function(control) SavePosition(control, self.sv.box) end)
    self.boxBackground = wm:CreateControl(ADDON_NAME .. "BoxBackground", self.boxWindow, CT_BACKDROP)
    PrepareBackdrop(self.boxBackground)
    self.boxBlink = wm:CreateControl(ADDON_NAME .. "BoxBlink", self.boxWindow, CT_BACKDROP)
    PrepareBackdrop(self.boxBlink)
    self.boxBlink:SetAlpha(1)
    self.blinkAnimation = ZO_AlphaAnimation:New(self.boxWindow)

    self.textWindow = wm:CreateTopLevelWindow(ADDON_NAME .. "Text")
    self.textWindow:SetResizeToFitDescendents(true)
    self.textWindow:SetClampedToScreen(true)
    self.textWindow:SetHandler("OnMoveStop", function(control) SavePosition(control, self.sv.text) end)
    self.textBackground = wm:CreateControl(ADDON_NAME .. "TextBackground", self.textWindow, CT_BACKDROP)
    PrepareBackdrop(self.textBackground)
    self.textCompactLabel = wm:CreateControl(ADDON_NAME .. "TextCompactLabel", self.textWindow, CT_LABEL)
    self.textCompactLabel:SetAnchor(TOPLEFT, self.textWindow, TOPLEFT,
        TEXT_PADDING_HORIZONTAL, TEXT_PADDING_TOP)
    self.textCompactLabel:SetMaxLineCount(1)
    self.textCompactLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.textCompactLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.textLabel = wm:CreateControl(ADDON_NAME .. "TextLabel", self.textWindow, CT_LABEL)
    self.textLabel:SetAnchor(TOPLEFT, self.textWindow, TOPLEFT,
        TEXT_PADDING_HORIZONTAL, TEXT_PADDING_TOP)
    self.textLabel:SetDimensionConstraints(0, 0, TEXT_MAX_WIDTH, 0)
    self.textLabel:SetWrapMode(TEXT_WRAP_MODE_WORD_WRAP)
    self.textLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.textLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.textDetailLabel = wm:CreateControl(ADDON_NAME .. "TextDetailLabel", self.textWindow, CT_LABEL)
    self.textDetailLabel:SetAnchor(TOPLEFT, self.textLabel, BOTTOMLEFT, 0, 2)
    self.textDetailLabel:SetDimensionConstraints(0, 0, TEXT_MAX_WIDTH, 0)
    self.textDetailLabel:SetWrapMode(TEXT_WRAP_MODE_WORD_WRAP)
    self.textDetailLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.textDetailLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.textTitleExtent = wm:CreateControl(ADDON_NAME .. "TextTitleExtent", self.textWindow, CT_CONTROL)
    self.textTitleExtent:SetDimensions(1, 1)
    self.textExtent = wm:CreateControl(ADDON_NAME .. "TextExtent", self.textWindow, CT_CONTROL)
    self.textExtent:SetDimensions(1, 1)
    self:ApplyAppearance()
    self:ApplyVisibility()
end

local function ParseSlashCommand(arguments)
    local first
    for argument in string.gmatch(tostring(arguments or ""), "%S+") do
        first = argument
        break
    end
    return zo_strlower(first or "")
end

function Addon:HandleSlashCommand(arguments)
    local command = ParseSlashCommand(arguments)
    if command == "lock" then
        self:SetLocked(true)
    elseif command == "unlock" then
        self:SetLocked(false)
    elseif command == "test" then
        self.sv.testMode = not self.sv.testMode
        self:UpdateUltimateState(true)
        self:Print(string.format(L(NEXTTRYULTIMATETRACKER_TEST_STATE), tostring(self.sv.testMode)))
    elseif command == "debug" then
        self.sv.debug = not self.sv.debug
        self:Print(string.format(L(NEXTTRYULTIMATETRACKER_DEBUG_STATE), tostring(self.sv.debug)))
        if self.sv.debug then self:PrintDebugSummary() end
    elseif command == "wwlock" or command == "werewolflock" then
        self:ToggleWerewolfRevertLock()
    elseif command == "zone" or command == "zoneinfo" then
        self:PrintZoneInfo()
    else
        self:Print(L(NEXTTRYULTIMATETRACKER_COMMAND_HELP))
        if self.sv.debug then self:PrintDebugSummary() end
    end
end

function Addon:RegisterEvents()
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_ACTIVATED, function()
        self.state.inCombat = IsUnitInCombat("player")
        self:RefreshZoneCache()
        self:UpdateUltimateState(not self.state.initialized)
        self.state.initialized = true
    end)
    if EVENT_ZONE_CHANGED then
        EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_ZONE_CHANGED,
            function()
                self:RefreshZoneCache()
                self:UpdateUltimateState(false)
            end)
    end
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_COMBAT_STATE, function(_, inCombat)
        self.state.inCombat = inCombat
        self:UpdateUltimateState(false)
    end)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_POWER_UPDATE, function(_, _, _, _, powerValue)
        self:UpdateUltimateState(false, powerValue)
    end)
    EVENT_MANAGER:AddFilterForEvent(EVENT_NAMESPACE, EVENT_POWER_UPDATE,
        REGISTER_FILTER_POWER_TYPE, ULTIMATE_POWER_TYPE,
        REGISTER_FILTER_UNIT_TAG, "player")
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_WerewolfPower", EVENT_POWER_UPDATE,
        function() self:UpdateUltimateState(false) end)
    EVENT_MANAGER:AddFilterForEvent(EVENT_NAMESPACE .. "_WerewolfPower", EVENT_POWER_UPDATE,
        REGISTER_FILTER_POWER_TYPE, WEREWOLF_POWER_TYPE,
        REGISTER_FILTER_UNIT_TAG, "player")
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_WEREWOLF_STATE_CHANGED,
        function() self:UpdateUltimateState(false) end)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED,
        function(_, didActiveHotbarChange)
            self:UpdateUltimateState(false)
            if didActiveHotbarChange then
                self:Debug("active hotbar updated: " .. HotbarName(self.state.activeHotbar))
            end
        end)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED,
        function() self:UpdateUltimateState(false) end)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_HOTBAR_SLOT_UPDATED,
        function(_, actionSlotIndex, hotbarCategory)
            if actionSlotIndex == ULTIMATE_SLOT
                and (hotbarCategory == HOTBAR_CATEGORY_PRIMARY
                    or hotbarCategory == HOTBAR_CATEGORY_BACKUP
                    or hotbarCategory == HOTBAR_CATEGORY_WEREWOLF) then
                self:UpdateUltimateState(false)
            end
        end)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_ULTIMATE_ABILITY_COST_CHANGED,
        function() self:UpdateUltimateState(false) end)
    if NextTryShared and NextTryShared.WindowVisibility then
        NextTryShared.WindowVisibility.RegisterSceneCallbacks(self,
            "SceneStateChanged", function() self:UpdateUltimateState(false) end)
    end
end

function Addon:Initialize()
    self:InitializeSavedVariables()
    self.state.inCombat = IsUnitInCombat("player")
    self.state.activeHotbar = GetActiveHotbarCategory()
    self:CreateUI()
    self:CreateSettings()
    self:RegisterEvents()
    self:HookUltimateBlockers()
    SLASH_COMMANDS["/ntut"] = function(arguments) self:HandleSlashCommand(arguments) end
    self:UpdateUltimateState(true)
    self:Print(L(NEXTTRYULTIMATETRACKER_LOADED))
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
    Addon:Initialize()
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
