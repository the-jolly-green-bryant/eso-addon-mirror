OSICrutchBridge = {
    name = "OSICrutchBridge",
    version = "1.0.0",
    OSI = {
        isFakeOSIStub = true, -- So other addons can check it? idk
    }
}
local OCB = OSICrutchBridge

local defaultOptions = {
    size = 128,
    opacity = 0.7,
}


---------------------------------------------------------------------
-- Informational message, including ones that happen during load
local queuedMessages = {}

local function msg(text)
    if (not text) then return end
    text = "|c3bdb5e[OSI-Crutch Bridge] |caaaaaa" .. tostring(text) .. "|r"
    if (CHAT_ROUNTER) then
        CHAT_ROUTER:AddSystemMessage(text)
    else
        table.insert(queuedMessages, text)
    end
end

local function PrintQueuedMessages()
    while #queuedMessages > 0 do
        local text = table.remove(queuedMessages, 1)
        CHAT_ROUTER:AddSystemMessage("[preload] " .. text)
    end
end

---------------------------------------------------------------------
-- Core
local isBridging = false

local function BuildBridge()
    if (not isBridging) then
        if (OSI) then
            msg("|r|cFF0000UNEXPECTED ERROR: |r|caaaaaaOSI already exists? Exiting early. Please send your enabled addon list to Kyzer to help debug.")
            return
        end

        OSI = OCB.OSI
        isBridging = true
        msg("Bridge has been built. Addons that optionally use OdySupportIcons will be redirected to CrutchAlerts' icon drawing system.")
    end
end

local function BurnBridge()
    -- TODO: is there possibility of addon doing something on player activation, and OCB only deactivates later?
    if (isBridging) then
        OSI = nil
        isBridging = false
        msg("Bridge has been burned. Addons that use OdySupportIcons will not show their in-world icons.")
    end
end


---------------------------------------------------------------------
-- Stuff
local function OnPlayerActivated()
    -- Show queued messages
    zo_callLater(PrintQueuedMessages, 2000)

    -- Exclude Rockgrove because I don't want to deal with QRH labels
    local zoneId = GetZoneId(GetUnitZoneIndex("player"))
    if (zoneId == 1263) then
        BurnBridge()
    else
        BuildBridge()
    end
end

local function Initialize()
    OCB.savedOptions = ZO_SavedVars:NewAccountWide("OSICrutchBridgeSavedVariables", 1, "Options", defaultOptions)
    OCB.CreateSettingsMenu()

    if (OSI) then
        msg("You already have OdySupportIcons! ... or another OSI spoofer. OSI-Crutch Bridge will not be activated at all.")
        return
    end

    EVENT_MANAGER:RegisterForEvent(OCB.name .. "PlayerActivated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
end

local function OnAddOnLoaded(_, addonName)
    if addonName == OCB.name then
        EVENT_MANAGER:UnregisterForEvent(OCB.name, EVENT_ADD_ON_LOADED)
        Initialize()
    end
end
 
EVENT_MANAGER:RegisterForEvent(OCB.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
