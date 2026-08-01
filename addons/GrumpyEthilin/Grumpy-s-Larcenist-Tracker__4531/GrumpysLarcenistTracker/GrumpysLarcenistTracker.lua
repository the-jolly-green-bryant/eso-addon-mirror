-- 1. Localize API functions at the top
local GetAchievementInfo = GetAchievementInfo
local GetAchievementNumCriteria = GetAchievementNumCriteria
local GetAchievementCriterion = GetAchievementCriterion
local GetWorldName = GetWorldName
local architecture = GetWorldName
local tostring = tostring
local ipairs = ipairs
local stringFormat = string.format

-- 2. Define the global table
GrumpysLarcenistTracker = GrumpysLarcenistTracker or {}
local GLT = GrumpysLarcenistTracker

GLT.name = "GrumpysLarcenistTracker"
GLT.cache = {}

-- 3. Internal Cache Builder
local function BuildAchievementCache()
    GLT.cache = {}
    for i = 1, 16000 do
        local name = GetAchievementInfo(i)
        if name and name ~= "" then
            GLT.cache[name:lower()] = i
        end
    end
end

-- 4. Main display function
function GLT.CheckAchievements()
    if not GLT.db or not GLT.db.achievementNames then return end

    d(stringFormat("|cAAAAAA[GLT Status: %s]|r", GetWorldName()))

    for _, searchName in ipairs(GLT.db.achievementNames) do
        local achId = GLT.cache[searchName:lower()]
        
        if achId then
            local aName, _, _, _, _, aCompleted = GetAchievementInfo(achId)
            
            if aName then
                local current, maximum = 0, 0
                local numCriteria = GetAchievementNumCriteria(achId)
                
                if numCriteria and numCriteria > 0 then
                    local _, nDone, nReq = GetAchievementCriterion(achId, 1)
                    current = nDone or 0
                    maximum = nReq or 0
                end
                
                -- FIXED COLOR LOGIC: 
                -- If it's a progress bar, check if current matches maximum.
                -- If it's a simple achievement, use the aCompleted boolean.
                local isDone = false
                if maximum > 0 then
                    isDone = (current >= maximum)
                else
                    isDone = aCompleted
                end

                local color = isDone and "|c00FF00" or "|cFFFF00"
                d(stringFormat("|cFFFFFF%s|r: %s[%s/%s]|r", aName, color, tostring(current), tostring(maximum)))
            end
        end
    end
end

-- 5. Event Handler
local function OnAddOnLoaded(event, addonName)
    if addonName ~= GLT.name then return end
    
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
    
    GLT.db = ZO_SavedVars:NewAccountWide("GrumpysLarcenistTracker_DB", 1, GetWorldName(), defaults)
    BuildAchievementCache()
    SLASH_COMMANDS["/glt"] = GLT.CheckAchievements
    EVENT_MANAGER:UnregisterForEvent(GLT.name, EVENT_ADD_ON_LOADED)
end

-- 6. Initial Registration
EVENT_MANAGER:RegisterForEvent(GLT.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)