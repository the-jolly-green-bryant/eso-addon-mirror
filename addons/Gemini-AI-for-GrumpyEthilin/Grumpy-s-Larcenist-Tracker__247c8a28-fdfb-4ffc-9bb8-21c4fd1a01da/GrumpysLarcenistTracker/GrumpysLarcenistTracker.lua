-- Namespace defined to avoid global collisions
GET_LarcenistTracker = {
    name = "GrumpysLarcenistTracker",
    cache = {}
}

-- Localize the cache builder so it's not a global function
local function BuildAchievementCache()
    GET_LarcenistTracker.cache = {}
    -- Scanning range for current game version
    for i = 1, 15000 do
        local resultName = GetAchievementInfo(i)
        if resultName and resultName ~= "" then
            GET_LarcenistTracker.cache[resultName:lower()] = i
        end
    end
end

-- Main function for the slash command
function GET_LarcenistTracker.CheckAchievements()
    d(string.format("|cAAAAAA[GLT Status: %s]|r", GetWorldName()))
    
    if not GET_LarcenistTracker.db or not GET_LarcenistTracker.db.achievementNames then return end

    for _, searchName in ipairs(GET_LarcenistTracker.db.achievementNames) do
        local achId = GET_LarcenistTracker.cache[searchName:lower()]
        
        if achId then
            local success, aName, _, _, _, aCompleted = pcall(GetAchievementInfo, achId)
            
            if success then
                local current, maximum = 0, 0
                local numCriteria = GetAchievementNumCriteria(achId)
                
                if numCriteria and numCriteria > 0 then
                    -- GetAchievementCriterion is the approved method for progress
                    local _, nDone, nReq = GetAchievementCriterion(achId, 1)
                    current = nDone or 0
                    maximum = nReq or 0
                end
                
                local color = aCompleted and "|c00FF00" or "|cFFFF00"
                d(string.format("|cFFFFFF%s|r: %s[%s/%s]|r", tostring(aName), color, tostring(current), tostring(maximum)))
            end
        else
            -- Optional: Comment this out for the "Public" version to keep chat clean
            -- d(string.format("|c808080'%s': [Not Found]|r", tostring(searchName)))
        end
    end
end

-- Addon Loaded Event
function GET_LarcenistTracker.OnAddOnLoaded(event, addonName)
    if addonName ~= GET_LarcenistTracker.name then return end
    
    local defaults = {
        achievementNames = {
            "Magnanimous Magnate", "Dragon's Hoard", "Eagle's Nest-Egg", 
            "Lion's Golden Pride", "Merchant Lord's Coffers", "Wrothgar Larcenist", 
            "Gold Coast Larcenist", "Vvardenfell Larcenist", "Clockwork City Larcenist", 
            "Summerset Larcenist", "Murkmire Larcenist", "Northern Elsweyr Larcenist", 
            "Southern Elsweyr Larcenist", "Western Skyrim Larcenist", "The Reach Larcenist", 
            "Blackwood Larcenist", "Fargrave Larcenist", "High Isle Larcenist", 
            "Galen Larcenist", "Necrom Larcenist", "West Weald Larcenist", "Solstice Larcenist"
        }
    }
    
    -- SavedVars initialized with unique AccountWide name
    GET_LarcenistTracker.db = ZO_SavedVars:NewAccountWide("GET_LarcenistTracker_Vars", 1, GetWorldName(), defaults)
    BuildAchievementCache()
    
    EVENT_MANAGER:UnregisterForEvent(GET_LarcenistTracker.name, EVENT_ADD_ON_LOADED)
end

-- Slash command registration
SLASH_COMMANDS["/glt"] = function() GET_LarcenistTracker.CheckAchievements() end

-- Event registration
EVENT_MANAGER:RegisterForEvent(GET_LarcenistTracker.name, EVENT_ADD_ON_LOADED, function(e, a) GET_LarcenistTracker.OnAddOnLoaded(e, a) end)