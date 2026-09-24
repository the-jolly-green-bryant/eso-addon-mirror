ShardVolleyAlert = {}
local SV = ShardVolleyAlert

function SV.OnCombatEvent(...)
    -- Filter in event, no need for arguments in the function, we can use the abilityID for that later in lifecycle hook
    
    CENTER_SCREEN_ANNOUNCE:AddMessage(
        EVENT_BROADCAST,
        CSA_CATEGORY_LARGE_TEXT,   -- this also has a UI-timeout according to online info
        SOUNDS.QUEST_OBJECTIVE_COMPLETE,
        "|cFF0000GTFO - SHARD VOLLEY!|r"
    )
    
    PlaySound(SOUNDS.DUEL_START)
end

function SV.OnAddOnLoaded(event, addonName)
    -- Skip the rest of the code when the game is loading another add-on
    if addonName ~= "ShardVolleyAlert" then return end
    
    -- Unregister the load event so it doesn't run again on general add-on load
    EVENT_MANAGER:UnregisterForEvent("ShardVolleyAlert", EVENT_ADD_ON_LOADED)
    
    -- Setting up the ShardVolleyAler_Combat pipeline and adding it to the previous declared SV.onCombatEvent
    EVENT_MANAGER:RegisterForEvent(
        "ShardVolleyAlert_Combat", 
        EVENT_COMBAT_EVENT, 
        SV.OnCombatEvent
    )
    
    -- now attaching the filters to the previous declared event without the need to overwrite something
    -- we look for a combat event type. It should only fire on action start (not on action end), and we only check for ability_id 213900
    EVENT_MANAGER:AddFilterForEvent(
        "ShardVolleyAlert_Combat", 
        EVENT_COMBAT_EVENT, 
        -- these are the filters of your combat event which state what the game has to look for when listening
        REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BEGIN, 
        REGISTER_FILTER_ABILITY_ID, 213900
    )
    
    d("|c00FF00Shard Volley Alert loaded!|r")
end

EVENT_MANAGER:RegisterForEvent("ShardVolleyAlert", EVENT_ADD_ON_LOADED, SV.OnAddOnLoaded)