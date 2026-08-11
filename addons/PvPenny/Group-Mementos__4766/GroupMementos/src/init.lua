GroupMementos = GroupMementos or {}
local GroupMementos = GroupMementos
GroupMementos.name = "GroupMementos"
GroupMementos.version = "2.3.3"

local DEFAULT_DISPLAY_X = 0
local DEFAULT_DISPLAY_Y = 300

local defaultOptions = {
    chat = true,
    showPanel = true,
    locked = false, -- when true, the tally window can't be dragged around
    nameDisplay = "character", -- "character" or "userid" (the @Handle account name)
    sortBy = "name", -- "name" or "total"
    leaderboardChannel = "party", -- "party", "guild", or "say" - which channel /gm leader targets
    trackMemento = {
        mudball = true,
        snowball = true,
        blossom = true,
        crow = true,
        pie = true,
    },
    displayX = DEFAULT_DISPLAY_X,
    displayY = DEFAULT_DISPLAY_Y,
    sessionTally = {}, -- [characterName] = { mudball = n, snowball = n, blossom = n, crow = n }
}

---------------------------------------------------------------------
-- Collect messages for displaying later if chat isn't ready yet
GroupMementos.messages = {}
function GroupMementos.msg(msg)
    if (not msg) then return end
    if (CHAT_SYSTEM.primaryContainer) then
        CHAT_SYSTEM:AddMessage("|c3bdb5e[Group Mementos]|caaaaaa " .. tostring(msg) .. "|r")
    else
        GroupMementos.messages[#GroupMementos.messages + 1] = msg
    end
end

---------------------------------------------------------------------
-- Save panel position after moving
function GroupMementos.SavePosition()
    GroupMementos.savedOptions.displayX = GroupMementosPanel:GetLeft()
    GroupMementos.savedOptions.displayY = GroupMementosPanel:GetTop()
    GroupMementosPanel:ClearAnchors()
    GroupMementosPanel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, GroupMementos.savedOptions.displayX, GroupMementos.savedOptions.displayY)
end

---------------------------------------------------------------------
-- Puts the tally window back at its default position - a safety net for
-- when it's been dragged off-screen, or a resolution/UI scale change moved
-- it somewhere no longer visible. Works even while locked, since locking
-- only disables dragging, not repositioning.
function GroupMementos.ResetWindowPosition()
    GroupMementos.savedOptions.displayX = DEFAULT_DISPLAY_X
    GroupMementos.savedOptions.displayY = DEFAULT_DISPLAY_Y
    GroupMementosPanel:ClearAnchors()
    GroupMementosPanel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, DEFAULT_DISPLAY_X, DEFAULT_DISPLAY_Y)
end

---------------------------------------------------------------------
local function OnPlayerActivated(_, initial)
    for i = 1, #GroupMementos.messages do
        CHAT_SYSTEM:AddMessage("|c3bdb5e[Group Mementos]|caaaaaa " .. tostring(GroupMementos.messages[i]) .. "|r")
    end
    GroupMementos.messages = {}

    GroupMementos.RefreshGroupMembers()
    GroupMementos.UpdateDisplay()

    EVENT_MANAGER:UnregisterForEvent(GroupMementos.name .. "PlayerActivated", EVENT_PLAYER_ACTIVATED)
end

---------------------------------------------------------------------
-- Initialize
local function Initialize()
    GroupMementos.savedOptions = ZO_SavedVars:NewAccountWide("GroupMementosSavedVariables", 1, "Options", defaultOptions)
    GroupMementos.groupMembers = {}

    GroupMementos.CreateSettingsMenu()

    GroupMementos.InitializeCore()
    GroupMementos.InitializeDisplay()

    EVENT_MANAGER:RegisterForEvent(GroupMementos.name .. "PlayerActivated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
end

---------------------------------------------------------------------
-- On load
local function OnAddOnLoaded(_, addonName)
    if (addonName == GroupMementos.name) then
        EVENT_MANAGER:UnregisterForEvent(GroupMementos.name, EVENT_ADD_ON_LOADED)
        Initialize()
    end
end

EVENT_MANAGER:RegisterForEvent(GroupMementos.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
-- Filters this event at the engine level so our handler only runs once,
-- for our own addon's load, instead of firing (and being checked in Lua)
-- for every other addon's load too.
EVENT_MANAGER:AddFilterForEvent(GroupMementos.name, EVENT_ADD_ON_LOADED, REGISTER_FILTER_ADD_ON_NAME, GroupMementos.name)
