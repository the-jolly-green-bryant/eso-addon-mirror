-- Character Achievements Addon for Elder Scrolls Online
-- Author: silvereyes

CharacterAchievements = {
    name = "CharacterAchievements",
    title = "Character Achievements",
    version = "1.0.2",
    author = "silvereyes",
}

-- Local declarations
local addon = CharacterAchievements
local onAddonLoaded



---------------------------------------
--
--          Public Members
-- 
---------------------------------------

if LibChatMessage then
    addon.Chat = LibChatMessage(addon.name, "CharAchvmts")
end



---------------------------------------
--
--          Private Methods
-- 
---------------------------------------

function onAddonLoaded(event, name)
    if name ~= addon.name then return end
    EVENT_MANAGER:UnregisterForEvent(addon.name, EVENT_ADD_ON_LOADED)
    
    addon.Data:Initialize()
end





-- Register addon
EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, onAddonLoaded)