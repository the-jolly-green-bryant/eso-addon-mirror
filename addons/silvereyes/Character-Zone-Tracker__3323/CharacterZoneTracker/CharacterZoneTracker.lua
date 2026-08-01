-- Character Zone Tracker Addon for Elder Scrolls Online
-- Author: silvereyes

CharacterZoneTracker = {
    name = "CharacterZoneTracker",
    title = "Character Zone Tracker",
    version = "1.3.0",
    author = "silvereyes",
    debugMode = false,
}

-- Local declarations
local addon = CharacterZoneTracker
local onAddonLoaded
local COMPLETION_TYPES



---------------------------------------
--
--          Public Members
-- 
---------------------------------------

if LibChatMessage then
    addon.Chat = LibChatMessage(addon.name, "CZT")
end

function CharacterZoneTracker_OnKeyboardLoadAccountButtonClick(control)
    local worldMap = addon.WorldMap -- get singleton
    worldMap:OnKeyboardLoadAccountButtonClick(control)
end

function CharacterZoneTracker_OnKeyboardResetButtonClick(control)
    local worldMap = addon.WorldMap -- get singleton
    worldMap:OnKeyboardResetButtonClick(control)
end

function CharacterZoneTracker:GetCompletionTypes()
    return COMPLETION_TYPES
end

function CharacterZoneTracker:IsCompletionTypeTracked(completionType)
    return COMPLETION_TYPES[completionType]
end


---------------------------------------
--
--          Private Members
-- 
---------------------------------------

function onAddonLoaded(event, name)
    if name ~= addon.name then return end
    EVENT_MANAGER:UnregisterForEvent(addon.name, EVENT_ADD_ON_LOADED)
    
    addon.SubzoneMap:Initialize()
    addon.Data:Initialize()
    addon.Compass:Initialize()
    addon.WorldMap:Initialize()
    addon.TargetTracker:Initialize()
    addon.Events:Initialize()
end

COMPLETION_TYPES = {
    [ZONE_COMPLETION_TYPE_DELVES] = true,
    [ZONE_COMPLETION_TYPE_GROUP_DELVES] = true,
    [ZONE_COMPLETION_TYPE_GROUP_BOSSES] = true,
    [ZONE_COMPLETION_TYPE_WORLD_EVENTS] = true,
}



-- Register addon
EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, onAddonLoaded)