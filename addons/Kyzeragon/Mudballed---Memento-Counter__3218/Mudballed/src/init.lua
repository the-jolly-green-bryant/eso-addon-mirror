Mudballed = Mudballed or {}
local Mud = Mudballed
Mud.name = "Mudballed"
Mud.version = "1.0.2"

local defaultOptions = {
    chat = true,
    capLines = 10,
    sourceTally = { -- Tally for user hitting other players
        mudball = {},
        snowball = {},
        pie = {},
        blossom = {},
        crow = {},
    },
    targetTally = { -- Tally for getting hit by other players
        mudball = {},
        snowball = {},
        pie = {},
        blossom = {},
        crow = {},
    },
    sourceDisplay = {
        x = 0,
        y = 500,
        mudball = true,
        snowball = true,
        pie = true,
        blossom = true,
        crow = true,
        all = false,
        show = true,
    },
    targetDisplay = {
        x = 220,
        y = 500,
        mudball = true,
        snowball = true,
        pie = true,
        blossom = true,
        crow = true,
        all = false,
        show = true,
    },
}
Mud.unlocked = false

---------------------------------------------------------------------
-- Collect messages for displaying later if addon is not fully loaded
Mud.messages = {}
function Mud.msg(msg)
    if (not msg) then return end
    if (CHAT_SYSTEM.primaryContainer) then
        CHAT_SYSTEM:AddMessage("|c3bdb5e[Mudballed]|caaaaaa " .. tostring(msg) .. "|r")
    else
        Mud.messages[#Mud.messages + 1] = msg
    end
end

---------------------------------------------------------------------
-- Save position after moving
function Mud.SavePosition()
    Mud.savedOptions.sourceDisplay.x = MudballedSourceTally:GetLeft()
    Mud.savedOptions.sourceDisplay.y = MudballedSourceTally:GetTop()
    MudballedSourceTally:ClearAnchors()
    MudballedSourceTally:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, Mud.savedOptions.sourceDisplay.x, Mud.savedOptions.sourceDisplay.y)

    Mud.savedOptions.targetDisplay.x = MudballedTargetTally:GetLeft()
    Mud.savedOptions.targetDisplay.y = MudballedTargetTally:GetTop()
    MudballedTargetTally:ClearAnchors()
    MudballedTargetTally:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, Mud.savedOptions.targetDisplay.x, Mud.savedOptions.targetDisplay.y)
end

---------------------------------------------------------------------
-- Post Load (player loaded)
local function OnPlayerActivated(_, initial)
    for i = 1, #Mud.messages do
        CHAT_SYSTEM:AddMessage("|c3bdb5e[Mudballed]|caaaaaa " .. tostring(Mud.messages[i]) .. "|r")
    end
    Mud.messages = {}

    EVENT_MANAGER:UnregisterForEvent(Mud.name .. "PlayerActivated", EVENT_PLAYER_ACTIVATED)
end

---------------------------------------------------------------------
-- Initialize
local function Initialize()
    Mud.savedOptions = ZO_SavedVars:NewAccountWide("MudballedSavedVariables", 1, "Options", defaultOptions)
    Mud.sessionSourceTally = {
        mudball = {},
        snowball = {},
        pie = {},
        blossom = {},
        crow = {},
    }
    Mud.sessionTargetTally = {
        mudball = {},
        snowball = {},
        pie = {},
        blossom = {},
        crow = {},
    }

    Mud.CreateSettingsMenu()

    Mud.InitializeCore()
    Mud.InitializeDisplay()

    EVENT_MANAGER:RegisterForEvent(Mud.name .. "PlayerActivated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
end

---------------------------------------------------------------------
-- On load
local function OnAddOnLoaded(_, addonName)
    if (addonName == Mud.name) then
        EVENT_MANAGER:UnregisterForEvent(Mud.name, EVENT_ADD_ON_LOADED)
        Initialize()
    end
end

EVENT_MANAGER:RegisterForEvent(Mud.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
