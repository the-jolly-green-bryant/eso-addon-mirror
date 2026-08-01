SynergyCooldown = {
    name = "SynergyCooldown",
    version = "2.1.0",
}
local SynCool = SynergyCooldown

local defaultOptions = {
    display = {
        x = GuiRoot:GetWidth() / 5,
        y = 0,
        growth = "down", -- "up"
        enabled = true,
        showBar = true,
    },
    othersDisplay = {
        x = GuiRoot:GetWidth() * 2 / 5,
        y = 0,
        growth = "down", -- "up"
        enabled = false,
        showBar = true,
    },
    showOnlyInCombat = false,
    debug = false,
}
SynCool.unlocked = false

---------------------------------------------------------------------
-- Collect messages for displaying later when addon is not fully loaded
SynCool.messages = {}
function SynCool.dbg(msg)
    if (not SynCool.savedOptions.debug) then return end
    if (not msg) then return end
    if (CHAT_ROUTER) then
        d("|c66FF66[SC]|r " .. tostring(msg))
    else
        SynCool.messages[#SynCool.messages + 1] = msg
    end
end

---------------------------------------------------------------------
-- Save position after moving
function SynCool:SavePosition()
    local x, y = SynCoolContainer:GetCenter()
    local oX, oY = GuiRoot:GetCenter()
    -- x is the offset from the center
    SynCool.savedOptions.display.x = x - oX
    SynCool.savedOptions.display.y = y - oY

    x, y = SynCoolOthers:GetCenter()
    -- x is the offset from the center
    SynCool.savedOptions.othersDisplay.x = x - oX
    SynCool.savedOptions.othersDisplay.y = y - oY
end

---------------------------------------------------------------------
-- Combat state
local function OnCombatStateChanged(_, inCombat)
    if (SynCool.savedOptions.showOnlyInCombat and not inCombat) then
        SynCoolContainer:SetHidden(true)
        SynCoolOthers:SetHidden(true)
    else
        SynCoolContainer:SetHidden(false)
        SynCoolOthers:SetHidden(false)
    end
end
SynCool.OnCombatStateChanged = OnCombatStateChanged

---------------------------------------------------------------------
-- Post Load (player loaded)
local function OnPlayerActivated(_, initial)
    -- Soft dependency on pChat because its chat restore will overwrite
    for i = 1, #SynCool.messages do
        d("|c66FF66[SCdelay]|r " .. SynCool.messages[i])
    end
    SynCool.messages = {}

    SynCool.ClearCache()
    OnCombatStateChanged(_, IsUnitInCombat("player"))
end

---------------------------------------------------------------------
-- Initialize
local function Initialize()
    SynCool.savedOptions = ZO_SavedVars:NewAccountWide("SynergyCooldownSavedVariables", 1, "Options", defaultOptions)

    SynCool.CreateSettingsMenu()

    SynCoolContainer:SetAnchor(CENTER, GuiRoot, CENTER, SynCool.savedOptions.display.x, SynCool.savedOptions.display.y)
    SynCoolOthers:SetAnchor(CENTER, GuiRoot, CENTER, SynCool.savedOptions.othersDisplay.x, SynCool.savedOptions.othersDisplay.y)

    SLASH_COMMANDS["/scunlock"] = function()
        SynCool.unlocked = true
        SynCoolContainer:SetMouseEnabled(true)
        SynCoolContainer:SetMovable(true)
        SynCoolContainerBackdrop:SetHidden(false)

        SynCoolOthers:SetMouseEnabled(true)
        SynCoolOthers:SetMovable(true)
        SynCoolOthersBackdrop:SetHidden(false)
    end

    SLASH_COMMANDS["/sclock"] = function()
        SynCool.unlocked = false
        SynCoolContainer:SetMouseEnabled(false)
        SynCoolContainer:SetMovable(false)
        SynCoolContainerBackdrop:SetHidden(true)

        SynCoolOthers:SetMouseEnabled(false)
        SynCoolOthers:SetMovable(false)
        SynCoolOthersBackdrop:SetHidden(true)
    end

    SLASH_COMMANDS["/sctest"] = SynCool.Test

    SLASH_COMMANDS["/scwatch"] = function(arg)
        SynCool.Watch(arg)
    end

    SynCool.InitializeStyles()
    SynCool:InitializeCore()
    EVENT_MANAGER:RegisterForEvent(SynCool.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
    EVENT_MANAGER:RegisterForEvent(SynCool.name .. "CombatState", EVENT_PLAYER_COMBAT_STATE, OnCombatStateChanged)
end

function SynCool.Test()
    local toActivate = {"Shard/Orb", "Blood Altar", "Ritual", "Conduit", "Shard/Orb"}
    for i, name in ipairs(toActivate) do
        EVENT_MANAGER:RegisterForUpdate(SynCool.name .. "Test" .. tostring(i), (i - 1) * 1000, function()
                SynCool.OnSynergyActivated(name)
                SynCool.OnSynergyOthers(name, "@Kyzeragon", nil, true)
                EVENT_MANAGER:UnregisterForUpdate(SynCool.name .. "Test" .. tostring(i))
            end)
    end
end

---------------------------------------------------------------------
-- On load
local function OnAddOnLoaded(_, addonName)
    if (addonName == SynCool.name) then
        EVENT_MANAGER:UnregisterForEvent(SynCool.name, EVENT_ADD_ON_LOADED)
        Initialize()
    end
end

EVENT_MANAGER:RegisterForEvent(SynCool.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
