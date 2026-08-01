--------------------------------------------------
-- SilentSynergy
-- Version 1.1
--------------------------------------------------

SilentSynergy = {}
SilentSynergy.name = "SilentSynergy"

local ORIGINAL_SOUND = SOUNDS["ABILITY_SYNERGY_READY"]

local defaults =
{
    enabled = true,
    showMessages = true,
}

--------------------------------------------------
-- Notifications
--------------------------------------------------

local function Notify(message)

    if not SilentSynergy.saved.showMessages then
        return
    end

    d(message)

end

--------------------------------------------------
-- Apply Current Setting
--------------------------------------------------

local function Apply()

    if SilentSynergy.saved.enabled then
        SOUNDS["ABILITY_SYNERGY_READY"] = SOUNDS["NONE"]
    else
        SOUNDS["ABILITY_SYNERGY_READY"] = ORIGINAL_SOUND
    end

end

--------------------------------------------------
-- Toggle
--------------------------------------------------

function SilentSynergy:Toggle()

    self.saved.enabled = not self.saved.enabled

    Apply()

    local color = self.saved.enabled and "00FF00" or "FFFF00"
    local state = self.saved.enabled
        and "Synergy Prompt Audio Muted"
        or "Synergy Prompt Audio Restored"

    Notify(string.format(
        "|c66CCFF[SilentSynergy]|r |c%s%s|r",
        color,
        state
    ))

end

--------------------------------------------------
-- Toggle Messages
--------------------------------------------------

function SilentSynergy:ToggleMessages()

    self.saved.showMessages = not self.saved.showMessages

    if self.saved.showMessages then
        d("|c66CCFF[SilentSynergy]|r |c00FF00Notifications Enabled|r")
    else
        d("|c66CCFF[SilentSynergy]|r |cFFFF00Notifications Disabled|r")
    end

end

--------------------------------------------------
-- Keybind Callback
--------------------------------------------------

function SilentSynergy_Toggle()
    SilentSynergy:Toggle()
end

--------------------------------------------------
-- Slash Commands
--------------------------------------------------

SLASH_COMMANDS["/silentsynergy"] = function()
    SilentSynergy:Toggle()
end

SLASH_COMMANDS["/silentsynergy-notifications"] = function()
    SilentSynergy:ToggleMessages()
end

--------------------------------------------------
-- Addon Loaded
--------------------------------------------------

local function OnAddonLoaded(eventCode, addonName)

    if addonName ~= SilentSynergy.name then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(
        SilentSynergy.name,
        EVENT_ADD_ON_LOADED
    )

    SilentSynergy.saved = ZO_SavedVars:NewAccountWide(
        "SilentSynergySaved",
        1,
        nil,
        defaults
    )

    Apply()

    Notify("|c66CCFF[SilentSynergy]|r Loaded")

end

EVENT_MANAGER:RegisterForEvent(
    SilentSynergy.name,
    EVENT_ADD_ON_LOADED,
    OnAddonLoaded
)