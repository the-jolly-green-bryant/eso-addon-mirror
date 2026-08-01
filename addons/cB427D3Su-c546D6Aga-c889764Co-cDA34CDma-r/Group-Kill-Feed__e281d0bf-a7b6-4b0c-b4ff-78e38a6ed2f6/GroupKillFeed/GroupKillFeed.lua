-- GroupKillFeed.lua
-- Author: SugaComa
-- Version: 1.4.6
-- PvP kill feed filtered to only you and your group (console safe)

GroupKillFeed = GroupKillFeed or {}
GroupKillFeed.name = "GroupKillFeed"
GroupKillFeed.version = "1.4.6"

-- Default state
GroupKillFeed.enabled = true
GroupKillFeed.mode = "group" -- "group" or "solo"
GroupKillFeed.useCustomSettings = true
GroupKillFeed.funKillFeedEnabled = false
GroupKillFeed.thisOneTeachesEnabled = false
GroupKillFeed.popupXOffset = 0
GroupKillFeed.popupYOffset = 0
GroupKillFeed.popupDurationMs = 6000
GroupKillFeed.popupDurationSec = 6.0
GroupKillFeed.totOutputMode = "fancy" -- "fancy" | "chat" | "both"

local DEFAULTS = {
    popupXOffset = 0,
    popupYOffset = 0,
    popupDurationMs = 6000,
    popupDurationSec = 6.0,
    totOutputMode = "fancy",
    enabled = true,
    mode = "group",
    useCustomSettings = true,
    funKillFeedEnabled = false,
    thisOneTeachesEnabled = false,
}

local MODE_ITEMS = {
    { name = "Group", data = "group" },
    { name = "Solo",  data = "solo"  },
}

local TOT_OUTPUT_ITEMS = {
    { name = "Fancy Popup", data = "fancy" },
    { name = "Chat",        data = "chat"  },
    { name = "Both",        data = "both"  },
}

local function ModeToName(mode)
    return (mode == "solo") and "Solo" or "Group"
end

local function NameOrDataToMode(value)
    value = tostring(value or "group")
    if value == "Solo" or value == "solo" then return "solo" end
    return "group"
end

local function GetDropdownValue(control, itemName, itemData)
    if type(itemData) == "table" then
        return itemData.data or itemData.name or itemName
    end
    return itemData or itemName or control
end

local function ToTOutputToName(mode)
    mode = string.lower(tostring(mode or "fancy"))
    if mode == "chat" then return "Chat" end
    if mode == "both" then return "Both" end
    return "Fancy Popup"
end

local function NameOrDataToToTOutput(value)
    value = string.lower(tostring(value or "fancy"))
    if value == "chat" then return "chat" end
    if value == "both" then return "both" end
    if value:find("chat") then return "chat" end
    if value:find("both") then return "both" end
    return "fancy"
end

local SV_VERSION = 1
local SV = nil

--------------------------------------------------------
-- PS5 SavedVars Commit Helper
--------------------------------------------------------
local function ForceSave()
    if SetCVar then
        SetCVar("Language.2", GetCVar("Language.2"))
    end
end

--------------------------------------------------------
-- Utility: Shared kill-feed chat output
-- [KF] is the common VCAP2 identity for GroupKillFeed,
-- FunKillFeed and ThisOneTeaches. The tag remains visible
-- in chat; VCAP2 can independently strip it from narration.
--------------------------------------------------------
GroupKillFeed.chatTag = "[KF]"

function GroupKillFeed.Print(msg)
    local text = tostring(msg or "")
    local tag = GroupKillFeed.chatTag or "[KF]"

    -- Keep the helper safe if a caller already supplied the tag.
    if string.sub(text, 1, string.len(tag)) ~= tag then
        if text == "" then
            text = tag
        else
            text = tag .. " " .. text
        end
    end

    if CHAT_SYSTEM and CHAT_SYSTEM.AddMessage then
        CHAT_SYSTEM:AddMessage(text)
    else
        d(text)
    end
end

local Print = GroupKillFeed.Print

--------------------------------------------------------
-- Utility: Faction Colors (Pastel shades)
--------------------------------------------------------
local FACTION_COLORS = {
    [ALLIANCE_ALDMERI_DOMINION]     = "|cE6E68A", -- pastel yellow
    [ALLIANCE_DAGGERFALL_COVENANT] = "|c8AAAE6", -- pastel blue
    [ALLIANCE_EBONHEART_PACT]      = "|cE68A8A", -- pastel red
    [ALLIANCE_NONE]                = "|cFFFFFF", -- fallback white
}

--------------------------------------------------------
-- Utility: Strip @ from display names
--------------------------------------------------------
local function CleanName(name)
    if not name or name == "" then return "Unknown" end
    if string.sub(name, 1, 1) == "@" then
        return string.sub(name, 2)
    end
    return name
end

--------------------------------------------------------
-- Utility: Group or Player Check
--------------------------------------------------------
local function IsMe(displayName)
    if not displayName or displayName == "" then return false end
    return displayName == CleanName(GetUnitDisplayName("player"))
end

local function IsMeOrGroup(displayName)
    if not displayName or displayName == "" then return false end
    if IsMe(displayName) then
        return true
    end
    for i = 1, GetGroupSize() do
        local tag = GetGroupUnitTagByIndex(i)
        if tag and DoesUnitExist(tag) then
            if CleanName(GetUnitDisplayName(tag)) == displayName then
                return true
            end
        end
    end
    return false
end

--------------------------------------------------------
-- Utility: Get refined location (POI > Zone fallback)
--------------------------------------------------------
local function GetRefinedLocation()
    local location = GetPlayerLocationName()
    if not location or location == "" then
        location = GetUnitZone("player")
    end
    if not location or location == "" then
        location = "Unknown Location"
    end
    return location
end

--------------------------------------------------------
-- Environment helpers
--------------------------------------------------------
local function IsInBattlegroundSafe()
    if type(IsActiveWorldBattleground) == "function" then
        return IsActiveWorldBattleground()
    end
    if type(IsInBattleground) == "function" then
        return IsInBattleground()
    end
    if type(IsUnitInBattleground) == "function" then
        return IsUnitInBattleground("player")
    end
    if type(GetCurrentBattlegroundId) == "function" then
        local id = GetCurrentBattlegroundId()
        if id and id ~= 0 then return true end
    end
    if type(GetCurrentBattlegroundState) == "function" then
        local state = GetCurrentBattlegroundState()
        if state and state ~= BATTLEGROUND_STATE_NONE then return true end
    end
    return false
end

local function IsInCyrodiilSafe()
    if type(IsInCyrodiil) == "function" then
        return IsInCyrodiil()
    end
    if type(IsInCampaign) == "function" then
        return IsInCampaign()
    end
    return false
end

local function IsInImperialCitySafe()
    if type(IsInImperialCity) == "function" then
        return IsInImperialCity()
    end
    return false
end

local function GetAutoMode()
    if IsInBattlegroundSafe() then
        return "solo"
    end
    if IsInCyrodiilSafe() or IsInImperialCitySafe() then
        return "group"
    end
    return "group"
end

function GroupKillFeed.GetEffectiveMode()
    if GroupKillFeed.useCustomSettings then
        return GroupKillFeed.mode
    end
    return GetAutoMode()
end

local function SaveState()
    if not SV then return end
    SV.enabled = GroupKillFeed.enabled
    SV.mode = GroupKillFeed.mode
    SV.useCustomSettings = GroupKillFeed.useCustomSettings
    SV.funKillFeedEnabled = GroupKillFeed.funKillFeedEnabled
    SV.thisOneTeachesEnabled = GroupKillFeed.thisOneTeachesEnabled
    SV.popupXOffset = GroupKillFeed.popupXOffset
    SV.popupYOffset = GroupKillFeed.popupYOffset
    SV.popupDurationMs = GroupKillFeed.popupDurationMs
    SV.popupDurationSec = GroupKillFeed.popupDurationSec
    SV.totOutputMode = GroupKillFeed.totOutputMode
end

local function ApplyDefaults()
    GroupKillFeed.enabled = DEFAULTS.enabled
    GroupKillFeed.mode = DEFAULTS.mode
    GroupKillFeed.useCustomSettings = DEFAULTS.useCustomSettings
    GroupKillFeed.funKillFeedEnabled = DEFAULTS.funKillFeedEnabled
    GroupKillFeed.thisOneTeachesEnabled = DEFAULTS.thisOneTeachesEnabled
    GroupKillFeed.popupXOffset = DEFAULTS.popupXOffset
    GroupKillFeed.popupYOffset = DEFAULTS.popupYOffset
    GroupKillFeed.popupDurationSec = DEFAULTS.popupDurationSec
    GroupKillFeed.totOutputMode = DEFAULTS.totOutputMode
    GroupKillFeed.popupDurationMs = math.floor((GroupKillFeed.popupDurationSec or DEFAULTS.popupDurationSec) * 1000 + 0.5)
    SaveState()
end


--------------------------------------------------------
-- FunKillFeed integration
--------------------------------------------------------
local function IsFunKillFeedInstalled()
    return FunKillFeed ~= nil
end

local function SetFunKillFeedEnabled(state)
    if GroupKillFeed.thisOneTeachesEnabled then
        -- Lock out FKF while This One Teaches is active
        if FunKillFeed and FunKillFeed.enabled then
            FunKillFeed.enabled = false
        end
        GroupKillFeed.funKillFeedEnabled = false
        SaveState()
        return
    end
    if not IsFunKillFeedInstalled() then
        GroupKillFeed.funKillFeedEnabled = false
        SaveState()
        return
    end

    if type(FunKillFeed.SetEnabled) == "function" then
        FunKillFeed.SetEnabled(state)
    else
        FunKillFeed.enabled = (state == true)
        if _G.FKF and _G.FKF.saved then
            _G.FKF.saved.enabled = FunKillFeed.enabled
        end
        ForceSave()
    end

    GroupKillFeed.funKillFeedEnabled = (state == true)
    SaveState()
end

local function IsThisOneTeachesInstalled()
    return ThisOneTeaches ~= nil
end

local function SetThisOneTeachesEnabled(state)
    if not IsThisOneTeachesInstalled() then
        GroupKillFeed.thisOneTeachesEnabled = false
        SaveState()
        return
    end

    local enable = (state == true)

    if enable then
        GroupKillFeed.useCustomSettings = true
        GroupKillFeed.mode = "solo"
        GroupKillFeed.funKillFeedEnabled = false
        SetFunKillFeedEnabled(false)
    end

    if type(ThisOneTeaches.SetEnabled) == "function" then
        ThisOneTeaches.SetEnabled(enable)
    else
        ThisOneTeaches.enabled = enable
        ForceSave()
    end

    GroupKillFeed.thisOneTeachesEnabled = enable
    SaveState()
end

-- Slash commands removed; handled via settings menu

--------------------------------------------------------
-- This One Teaches: Popup output + settings bridge
--------------------------------------------------------
function GroupKillFeed.GetToTOutputMode()
    return GroupKillFeed.totOutputMode or (SV and SV.totOutputMode) or DEFAULTS.totOutputMode or "fancy"
end

local function GetToTOutputMode()
    return GroupKillFeed.GetToTOutputMode()
end


function GroupKillFeed.GetPopupSettings()
    -- Values used by ThisOneTeaches embedded popup
    local sec = tonumber(GroupKillFeed.popupDurationSec) or (SV and tonumber(SV.popupDurationSec)) or DEFAULTS.popupDurationSec or 6.0
    if sec < 0.5 then sec = 0.5 end
    return {
        xOffset = tonumber(GroupKillFeed.popupXOffset) or 0,
        yOffset = tonumber(GroupKillFeed.popupYOffset) or 0,
        durationMs = math.floor(sec * 1000 + 0.5),
    }
end

local function ApplyToTPopupSettings()
    if not IsThisOneTeachesInstalled() then return end

    -- Duration: store seconds in SV, but keep ms for compatibility
    local sec = tonumber(GroupKillFeed.popupDurationSec) or (SV and tonumber(SV.popupDurationSec)) or DEFAULTS.popupDurationSec or 6.0
    if sec < 0.5 then sec = 0.5 end
    local ms = math.floor(sec * 1000 + 0.5)

    GroupKillFeed.popupDurationSec = sec
    GroupKillFeed.popupDurationMs = ms

    -- Push into ThisOneTeaches if it exposes fields/functions
    ThisOneTeaches.popupXOffset = tonumber(GroupKillFeed.popupXOffset) or 0
    ThisOneTeaches.popupYOffset = tonumber(GroupKillFeed.popupYOffset) or 0
    ThisOneTeaches.popupDurationMs = ms
    ThisOneTeaches.outputMode = GetToTOutputMode()

    if type(ThisOneTeaches.SetPopupSettings) == "function" then
        pcall(ThisOneTeaches.SetPopupSettings, ThisOneTeaches,
            ThisOneTeaches.popupXOffset, ThisOneTeaches.popupYOffset, ms, ThisOneTeaches.outputMode)
    end
end

local function ShowCenterScreenMessage(title, message)
    local textMsg = (title and title ~= "" and (title .. ": ") or "") .. (message or "")

    -- On console, ZO_Alert is the most consistently visible "center" output.
    -- Some CENTER_SCREEN_ANNOUNCE calls can succeed without visibly showing anything.
    if type(ZO_Alert) == "function" then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, textMsg)
        return
    end

    -- Console-safe path: avoid params objects where methods may be unavailable.
    if CENTER_SCREEN_ANNOUNCE and type(CENTER_SCREEN_ANNOUNCE.AddMessage) == "function" then
        -- Signature varies; we try safest common forms.
        local ok = pcall(function()
            -- Common: AddMessage(category, soundId, message)
            CENTER_SCREEN_ANNOUNCE:AddMessage(CSA_CATEGORY_LARGE_TEXT, nil, textMsg)
        end)
        if ok then return end

        ok = pcall(function()
            -- Alternative: AddMessage(category, message)
            CENTER_SCREEN_ANNOUNCE:AddMessage(CSA_CATEGORY_LARGE_TEXT, textMsg)
        end)
        if ok then return end
    end

    Print(textMsg)
end

local function TryShowFancyPopup(title, message)
    -- Prefer embedded popup inside ThisOneTeaches (no external libs)
    if IsThisOneTeachesInstalled() and ThisOneTeaches and type(ThisOneTeaches.ShowFancyPopup) == "function" then
        local ok = pcall(function()
            ThisOneTeaches:ShowFancyPopup("victory", title or "NOTICE", message or "")
        end)
        if ok then return true end
    end
    return false
end

local function ShowToTExample()
    local title = "NOTICE"
    local message = "This is an example 'This One Teaches' popup.\nAdjust X/Y offsets to center it on your crosshair."
    local mode = GetToTOutputMode()

    if mode == "chat" then
        Print(title .. ": " .. message)
        return
    elseif mode == "both" then
        Print(title .. ": " .. message)
        if not TryShowFancyPopup(title, message) then
            ShowCenterScreenMessage(title, message)
        end
        return
    else
        if not TryShowFancyPopup(title, message) then
            -- fallback
            ShowCenterScreenMessage(title, message)
        end
    end
end



--------------------------------------------------------
-- Recurrence tracker (prevents double posts)
--------------------------------------------------------
local g_killRecurrenceTracker = ZO_RecurrenceTracker:New(5000, 5000)

--------------------------------------------------------
-- Message Builder / extension dispatcher
--
-- GroupKillFeed is the ONLY owner of EVENT_PVP_KILL_FEED_DEATH.
-- FunKillFeed and ThisOneTeaches no longer wrap BuildMessage.
-- This prevents wrapper recursion when both optional modes are disabled.
--------------------------------------------------------
function GroupKillFeed.BuildBaseMessage(killerDisplayName, killerAlliance, victimDisplayName, victimAlliance, location)
    local playerName     = CleanName(GetUnitDisplayName("player"))
    local playerAlliance = GetUnitAlliance("player")
    local playerColor    = FACTION_COLORS[playerAlliance] or "|cFFFFFF"

    local killerColor = FACTION_COLORS[killerAlliance] or "|cFFFFFF"
    local victimColor = FACTION_COLORS[victimAlliance] or "|cFFFFFF"

    if killerDisplayName == playerName then
        return playerColor .. "You|r killed " .. victimColor .. victimDisplayName .. "|r near " .. location
    elseif victimDisplayName == playerName then
        return playerColor .. "You|r died to " .. killerColor .. killerDisplayName .. "|r near " .. location
    else
        return killerColor .. killerDisplayName .. "|r → " .. victimColor .. victimDisplayName .. "|r near " .. location
    end
end

function GroupKillFeed.BuildMessage(killerDisplayName, killerAlliance, victimDisplayName, victimAlliance, location)
    local mode = GroupKillFeed.GetEffectiveMode()

    -- This One Teaches has first priority and is solo-only.
    -- It performs its own popup/chat output and returns true when handled.
    if GroupKillFeed.thisOneTeachesEnabled == true
        and mode == "solo"
        and ThisOneTeaches
        and type(ThisOneTeaches.HandleKill) == "function"
    then
        local ok, handled = pcall(
            ThisOneTeaches.HandleKill,
            killerDisplayName, killerAlliance,
            victimDisplayName, victimAlliance,
            location
        )
        if ok and handled == true then
            return ""
        elseif not ok and not GroupKillFeed._totErrorReported then
            GroupKillFeed._totErrorReported = true
            Print("This One Teaches failed to process a kill; using the basic kill feed instead.")
        end
    end

    -- FunKillFeed is only consulted when its mode is actually enabled.
    if GroupKillFeed.funKillFeedEnabled == true
        and FunKillFeed
        and type(FunKillFeed.BuildMessage) == "function"
    then
        local ok, message = pcall(
            FunKillFeed.BuildMessage,
            killerDisplayName, killerAlliance,
            victimDisplayName, victimAlliance,
            location
        )
        if ok and message and message ~= "" then
            return message
        elseif not ok and not GroupKillFeed._fkfErrorReported then
            GroupKillFeed._fkfErrorReported = true
            Print("Fun Kill Feed failed to process a kill; using the basic kill feed instead.")
        end
    end

    -- Default path: no optional addon processing at all.
    return GroupKillFeed.BuildBaseMessage(
        killerDisplayName, killerAlliance,
        victimDisplayName, victimAlliance,
        location
    )
end

--------------------------------------------------------
-- Main event: PvP kill feed
--------------------------------------------------------
local function OnKillFeed(_, killLocation, killerDisplayName, killerCharacterName, killerAlliance, killerRank,
                          victimDisplayName, victimCharacterName, victimAlliance, victimRank, isKillLocation)

    if not GroupKillFeed.enabled then return end

    killerDisplayName = CleanName(killerDisplayName)
    victimDisplayName = CleanName(victimDisplayName)

    -- Deduplicate local vs killLocation events
    local messageKeySuffix = string.format("%s___%s", killerDisplayName, victimDisplayName)
    local messageKeyLocal = "L" .. messageKeySuffix
    local messageKeyKillLocation = "B" .. messageKeySuffix

    if isKillLocation then
        if g_killRecurrenceTracker:RemoveValue(messageKeyLocal) ~= nil then return end
        g_killRecurrenceTracker:AddValue(messageKeyKillLocation)
    else
        if g_killRecurrenceTracker:RemoveValue(messageKeyKillLocation) ~= nil then return end
        g_killRecurrenceTracker:AddValue(messageKeyLocal)
    end

    -- Filter by effective mode
    local mode = GroupKillFeed.GetEffectiveMode()
    if mode == "solo" then
        if not (IsMe(killerDisplayName) or IsMe(victimDisplayName)) then return end
    else
        local killerRelevant = IsMeOrGroup(killerDisplayName)
        local victimRelevant = IsMeOrGroup(victimDisplayName)
        if not (killerRelevant or victimRelevant) then return end
    end

    -- Location
    local location = killLocation
    if not location or location == "" then
        location = GetRefinedLocation()
    end

    -- Message
    local msg = GroupKillFeed.BuildMessage(
        killerDisplayName, killerAlliance, 
        victimDisplayName, victimAlliance, 
        location
    )

    if msg and msg ~= "" then
        Print(msg)
    end
end

--------------------------------------------------------
-- Settings Menu (LibHarvensAddonSettings)
--------------------------------------------------------
local function SetupSettingsMenu()
    if not LibHarvensAddonSettings then
        Print("LibHarvensAddonSettings not found; settings menu disabled.")
        return
    end

    local options = {
        allowDefaults = true,
        allowRefresh = true,
        defaultsFunction = function()
            ApplyDefaults()
            ForceSave()
        end,
    }

    local settings = LibHarvensAddonSettings:AddAddon("Group Kill Feed", options)
    if not settings then return end

    -- Core
    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Enable Group Kill Feed",
        tooltip = "Master toggle for the kill feed.",
        default = DEFAULTS.enabled,
        getFunction = function() return GroupKillFeed.enabled == true end,
        setFunction = function(state)
            GroupKillFeed.enabled = (state == true)
            SaveState()
            ForceSave()
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_DROPDOWN,
        label = "Mode",
        tooltip = "Choose whether to show kills for you + group, or only you.",
        default = ModeToName(DEFAULTS.mode),
        items = MODE_ITEMS,
        getFunction = function()
            return ModeToName(GroupKillFeed.mode)
        end,
        setFunction = function(control, itemName, itemData)
            local selected = GetDropdownValue(control, itemName, itemData)
            GroupKillFeed.mode = NameOrDataToMode(selected)
            GroupKillFeed.useCustomSettings = true
            SaveState()
            ForceSave()
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Enable Fun Kill Feed",
        tooltip = "Uses funnier kill feed messages when FunKillFeed is installed. Works in Group or Solo mode. Disabled automatically if This One Teaches is enabled.",
        default = DEFAULTS.funKillFeedEnabled,
        getFunction = function()
            return GroupKillFeed.funKillFeedEnabled == true
        end,
        setFunction = function(state)
            SetFunKillFeedEnabled(state == true)
            SaveState()
            ForceSave()
        end,
        disable = function()
            return GroupKillFeed.thisOneTeachesEnabled == true or not IsFunKillFeedInstalled()
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Enable This One Teaches",
        tooltip = "Solo-only teaching popup mode. Enabling this switches Mode to Solo and disables Fun Kill Feed.",
        default = DEFAULTS.thisOneTeachesEnabled,
        getFunction = function()
            return GroupKillFeed.thisOneTeachesEnabled == true
        end,
        setFunction = function(state)
            SetThisOneTeachesEnabled(state == true)
            SaveState()
            ApplyToTPopupSettings()
            ForceSave()
        end,
        disable = function()
            return not IsThisOneTeachesInstalled()
        end,
    })

    -- This One Teaches popup controls
    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SECTION,
        label = "This One Teaches Popup",
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_LABEL,
        label = [[Controls the on-screen popup position and duration for This One Teaches.
(Only used when This One Teaches is enabled.)]],
    })

    
    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_DROPDOWN,
        label = "Popup Output",
        tooltip = "Where This One Teaches messages should be shown.",
	        -- Follow the same dropdown pattern as FoodReminder + our "Mode" dropdown:
	        -- items are { name=..., data=... }
	        -- getFunction returns the *name* string
	        -- setFunction stores the *data* string
	        default = ToTOutputToName(DEFAULTS.totOutputMode),
            items = TOT_OUTPUT_ITEMS,
            getFunction = function()
                return ToTOutputToName(GroupKillFeed.totOutputMode or (SV and SV.totOutputMode) or DEFAULTS.totOutputMode)
            end,
            setFunction = function(control, itemName, itemData)
                local selected = GetDropdownValue(control, itemName, itemData)
                GroupKillFeed.totOutputMode = NameOrDataToToTOutput(selected)
                SaveState()
                ApplyToTPopupSettings()
                ForceSave()
            end,
        disable = function() return not (IsThisOneTeachesInstalled() and ThisOneTeaches and ThisOneTeaches.enabled) end,
    })


settings:AddSetting({
        type = LibHarvensAddonSettings.ST_BUTTON,
        label = "Show Example Popup",
        tooltip = "Shows a test message using your selected output and current position/duration.",
        buttonText = "Show",
        clickHandler = function()
            ShowToTExample()
        end,
        disable = function() return not (IsThisOneTeachesInstalled() and ThisOneTeaches and ThisOneTeaches.enabled) end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Popup X Offset",
        tooltip = "Horizontal offset from screen center. Negative = left, positive = right.",
        min = -800,
        max = 800,
        step = 10,
        default = DEFAULTS.popupXOffset,
        getFunction = function() return tonumber(GroupKillFeed.popupXOffset) or DEFAULTS.popupXOffset end,
        setFunction = function(v)
            GroupKillFeed.popupXOffset = tonumber(v) or DEFAULTS.popupXOffset
            SaveState()
            ApplyToTPopupSettings()
            ForceSave()
        end,
        disable = function() return not (IsThisOneTeachesInstalled() and ThisOneTeaches and ThisOneTeaches.enabled) end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Popup Y Offset",
        tooltip = "Vertical offset from screen center. Negative = up, positive = down.",
        min = -600,
        max = 600,
        step = 10,
        default = DEFAULTS.popupYOffset,
        getFunction = function() return tonumber(GroupKillFeed.popupYOffset) or DEFAULTS.popupYOffset end,
        setFunction = function(v)
            GroupKillFeed.popupYOffset = tonumber(v) or DEFAULTS.popupYOffset
            SaveState()
            ApplyToTPopupSettings()
            ForceSave()
        end,
        disable = function() return not (IsThisOneTeachesInstalled() and ThisOneTeaches and ThisOneTeaches.enabled) end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Popup Duration (seconds)",
        tooltip = "How long the popup stays on screen.",
        min = 0.5,
        max = 10.0,
        step = 0.5,
        default = DEFAULTS.popupDurationSec,
        getFunction = function() return tonumber(GroupKillFeed.popupDurationSec) or DEFAULTS.popupDurationSec end,
        setFunction = function(v)
            local sec = tonumber(v) or DEFAULTS.popupDurationSec
            GroupKillFeed.popupDurationSec = sec
            GroupKillFeed.popupDurationMs = math.floor(sec * 1000)
            SaveState()
            ApplyToTPopupSettings()
            ForceSave()
        end,
        disable = function() return not (IsThisOneTeachesInstalled() and ThisOneTeaches and ThisOneTeaches.enabled) end,
    })
end
--------------------------------------------------------
-- On Addon Loaded
--------------------------------------------------------
local function OnAddonLoaded(_, addonName)
    if addonName ~= GroupKillFeed.name then return end

    local ok, sv = pcall(function()
        return ZO_SavedVars:NewAccountWide("GroupKillFeedSV", SV_VERSION, nil, DEFAULTS)
    end)

    if ok and type(sv) == "table" then
        SV = sv
        GroupKillFeed.enabled = (SV.enabled ~= false)
        GroupKillFeed.mode = SV.mode or DEFAULTS.mode
        GroupKillFeed.useCustomSettings = (SV.useCustomSettings == true)
        GroupKillFeed.funKillFeedEnabled = (SV.funKillFeedEnabled == true)
        GroupKillFeed.thisOneTeachesEnabled = (SV.thisOneTeachesEnabled == true)
        GroupKillFeed.popupXOffset = tonumber(SV.popupXOffset) or DEFAULTS.popupXOffset
        GroupKillFeed.popupYOffset = tonumber(SV.popupYOffset) or DEFAULTS.popupYOffset
        GroupKillFeed.popupDurationMs = tonumber(SV.popupDurationMs) or DEFAULTS.popupDurationMs
        GroupKillFeed.popupDurationSec = tonumber(SV.popupDurationSec) or (GroupKillFeed.popupDurationMs / 1000) or DEFAULTS.popupDurationSec
        GroupKillFeed.totOutputMode = SV.totOutputMode or DEFAULTS.totOutputMode
    else
        SV = nil
        ApplyDefaults()
        Print("GroupKillFeed: SavedVariables failed, using defaults.")
    end

    if IsFunKillFeedInstalled() then
        SetFunKillFeedEnabled(GroupKillFeed.funKillFeedEnabled)
    end
    if IsThisOneTeachesInstalled() then
        SetThisOneTeachesEnabled(GroupKillFeed.thisOneTeachesEnabled)
        ApplyToTPopupSettings()
    end

    SetupSettingsMenu()

    EVENT_MANAGER:RegisterForEvent(GroupKillFeed.name, EVENT_PVP_KILL_FEED_DEATH, OnKillFeed)
    EVENT_MANAGER:RegisterForEvent(GroupKillFeed.name .. "_FKF", EVENT_ADD_ON_LOADED, function(_, loadedName)
        if loadedName == "FunKillFeed" then
            zo_callLater(function()
                SetFunKillFeedEnabled(GroupKillFeed.funKillFeedEnabled)
            end, 0)
        end
    end)
    EVENT_MANAGER:RegisterForEvent(GroupKillFeed.name .. "_TOT", EVENT_ADD_ON_LOADED, function(_, loadedName)
        if loadedName == "ThisOneTeaches" then
            -- ThisOneTeaches initializes its own SavedVariables during the same
            -- EVENT_ADD_ON_LOADED dispatch. Sync once more on the next frame so
            -- GroupKillFeed remains the authoritative mode owner regardless of
            -- callback registration order.
            zo_callLater(function()
                SetThisOneTeachesEnabled(GroupKillFeed.thisOneTeachesEnabled)
                ApplyToTPopupSettings()
            end, 0)
        end
    end)
    EVENT_MANAGER:UnregisterForEvent(GroupKillFeed.name, EVENT_ADD_ON_LOADED)

    Print("GroupKillFeed v" .. GroupKillFeed.version .. " active.")
end

--------------------------------------------------------
-- Status Command (removed; handled via settings menu)
--------------------------------------------------------

EVENT_MANAGER:RegisterForEvent(GroupKillFeed.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
