DolmenRunner = {
    name = "DolmenRunner",
    displayName = "Dolmen Runner",
    version = "1.1.0",
    chatPrefix = "|c39B027DolmenRunner|r: ",
    defaults = {
        hasSeenIntro = false,
        runner = {
            autoTravel = true,
            autoDismiss = true,
            reapplyBuff = true,
        },
    },
}

local DR = DolmenRunner
local SAVED_VARS_VERSION = 2
local LastUpdateTimestamp = GetTimeStamp()

function DR:Log(message)
    if self.utils then
        self.utils:Log(message)
    else
        d(self.chatPrefix .. message)
    end
end

function DR:RefreshSettings()
    if self.ui and self.ui.RefreshSettings then
        self.ui:RefreshSettings()
    end
end

function DR:Update()
    local currentTimestamp = GetTimeStamp()
    local tick = 1
    if GetDiffBetweenTimeStamps(currentTimestamp, LastUpdateTimestamp) >= 5 then
        tick = 5
        LastUpdateTimestamp = currentTimestamp
    end

    self.runner:Update(tick)
end

function DR:ToggleRunnerSetting(key)
    if not self.settings or not self.settings.runner then
        return
    end
    self.settings.runner[key] = not self.settings.runner[key]
    self:Log(zo_strformat("<<1>>: <<2>>", key, self.settings.runner[key] and "on" or "off"))
    self:RefreshSettings()
end

function DR:Initialize()
    self.runner:Initialize()
    self.ui:Initialize()
    if self.addonMenu and self.addonMenu.Initialize then
        self.addonMenu:Initialize()
    end
    if self.pauseMenu and self.pauseMenu.Initialize then
        self.pauseMenu:Initialize()
    end

    EVENT_MANAGER:RegisterForUpdate(DolmenRunner.name, 1000, function()
        DR:Update()
    end)
end

local function OnAddOnLoaded(event, addonName)
    if addonName ~= DR.name then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(DR.name, EVENT_ADD_ON_LOADED)

    DR.settings = ZO_SavedVars:NewAccountWide("DolmenRunner_Data", SAVED_VARS_VERSION, nil, DR.defaults)
    DR:Initialize()

    EVENT_MANAGER:RegisterForEvent(DR.name, EVENT_START_FAST_TRAVEL_INTERACTION, function(eventId, ...)
        DR.runner:OnFastTravelInteraction(...)
    end)
    EVENT_MANAGER:RegisterForEvent(DR.name, EVENT_EXPERIENCE_GAIN, function(eventId, ...)
        DR.runner:OnExperienceGain(...)
    end)
    EVENT_MANAGER:RegisterForEvent(DR.name, EVENT_PLAYER_COMBAT_STATE, function(eventId, ...)
        DR.runner:OnCombatState(...)
    end)

    DR:Log(GetString(DR_WINDOW_INIT))
    if IsConsoleUI() and not DR.settings.hasSeenIntro then
        DR.settings.hasSeenIntro = true
        zo_callLater(function()
            DR:Log(GetString(DR_CONSOLE_INTRO))
        end, 1500)
    end
end

EVENT_MANAGER:RegisterForEvent(DR.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
