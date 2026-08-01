local ADDON_NAME = "ReloadUITimer"
local PLAYER_ACTIVATED_SUBSCRIPTION = ADDON_NAME .. "_PlayerActivated"

local ReloadUITimer = {}

function ReloadUITimer.GetSavedVariables()
    ReloadUITimer_SavedVariables = ReloadUITimer_SavedVariables or {}

    local worldName = GetWorldName()
    local savedVariables = ReloadUITimer_SavedVariables

    savedVariables[worldName] = savedVariables[worldName] or {}

    return savedVariables[worldName]
end

function ReloadUITimer.OnPlayerActivated()
    ReloadUITimer.ReportMeasurement()
end

function ReloadUITimer.ReportMeasurement()
    local savedVariables = ReloadUITimer.GetSavedVariables()

    if not savedVariables.startTime then
        return
    end

    local duration = GetGameTimeMilliseconds() - savedVariables.startTime

    savedVariables.startTime = nil

    CHAT_ROUTER:AddSystemMessage(
        string.format(
            GetString(SI_RELOADUITIMER_MESSAGE),
            duration / 1000
        )
    )
end

function ReloadUITimer.SaveReloadStart()
    ReloadUITimer.GetSavedVariables().startTime = GetGameTimeMilliseconds()
end

ZO_PreHook("ReloadUI", ReloadUITimer.SaveReloadStart)

EVENT_MANAGER:RegisterForEvent(
    PLAYER_ACTIVATED_SUBSCRIPTION,
    EVENT_PLAYER_ACTIVATED,
    ReloadUITimer.OnPlayerActivated,
    true
)
