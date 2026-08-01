DoItAll = DoItAll or {}
DoItAll.AddOnName = "DoItAll"
DoItAll.AddOnVersion = 1.75
DoItAll.extractionActive = false

local addonName = DoItAll.AddOnName

local function Initialize()
	DoItAll.Settings.Initialize()
end

local function addonLoaded(_, loadedAddon)
    if addonName ~= loadedAddon then return end

    --LibAddonMenu-2.0
    DoItAll.LAM = LibAddonMenu2
    Initialize()
end

--[[
local function PlayerActivated()
end
]]

ZO_CreateStringId("SI_BINDING_NAME_SC_BANK_ALL", "Do It All") -- use BANK_ALL to keep the existing key binding
EVENT_MANAGER:RegisterForEvent(addonName .. "_EVENT_ADD_ON_LOADED", EVENT_ADD_ON_LOADED, addonLoaded)
--EVENT_MANAGER:RegisterForEvent(DoItAll.AddOnName, EVENT_PLAYER_ACTIVATED, PlayerActivated) -- for debugging
