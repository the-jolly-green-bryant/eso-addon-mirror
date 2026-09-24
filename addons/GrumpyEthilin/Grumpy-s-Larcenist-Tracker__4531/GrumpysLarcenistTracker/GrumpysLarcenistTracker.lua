-- 1. Localize API functions at the top
local GetAchievementInfo = GetAchievementInfo
local GetAchievementNumCriteria = GetAchievementNumCriteria
local GetAchievementCriterion = GetAchievementCriterion
local GetWorldName = GetWorldName
local tostring = tostring
local ipairs = ipairs
local stringFormat = string.format

-- 2. Define global table
GrumpysLarcenistTracker = GrumpysLarcenistTracker or {}
local GLT = GrumpysLarcenistTracker

GLT.name = "GrumpysLarcenistTracker"
GLT.cache = {}

-- 3. Cache Builder
local function BuildAchievementCache()
    GLT.cache = {}
    for i = 1, 16000 do
        local name = GetAchievementInfo(i)
        if name and name ~= "" then
            GLT.cache[name:lower()] = i
        end
    end
end

-- 4. Main Display Function
function GLT.CheckAchievements()
    if not GLT.db or not GLT.db.achievementNames then return end

    local filterMode = GLT.db.hideCompleted and " (Uncompleted Only)" or ""
    d(stringFormat("|cAAAAAA[GLT Status: %s%s]|r", GetWorldName(), filterMode))

    for _, searchName in ipairs(GLT.db.achievementNames) do
        local achId = GLT.cache[searchName:lower()]
        
        if achId then
            local aName, _, _, _, _, aCompleted = GetAchievementInfo(achId)
            
            if aName then
                local numCriteria = GetAchievementNumCriteria(achId) or 0
                
                if numCriteria > 1 then
                    -- MULTI-CRITERIA ACHIEVEMENT (e.g. Dragon's Hoard, Magnanimous Magnate)
                    local totalDone, totalReq = 0, 0
                    local subResults = {}
                    local allSubComplete = true

                    for c = 1, numCriteria do
                        local critDescription, nDone, nReq = GetAchievementCriterion(achId, c)
                        nDone = nDone or 0
                        nReq = nReq or 0
                        
                        totalDone = totalDone + nDone
                        totalReq = totalReq + nReq
                        
                        local critDone = (nReq > 0 and nDone >= nReq)
                        if not critDone then
                            allSubComplete = false
                        end

                        table.insert(subResults, {
                            name = critDescription,
                            done = nDone,
                            req = nReq,
                            isDone = critDone
                        })
                    end

                    -- Rely strictly on allSubComplete for multi-part achievements
                    local isDone = allSubComplete

                    -- Skip printing if filtering completed achievements
                    if not (GLT.db.hideCompleted and isDone) then
                        local mainColor = isDone and "|c00FF00" or "|cFFFF00"
                        d(stringFormat("|cFFFFFF%s|r: %s[%s/%s]|r", aName, mainColor, tostring(totalDone), tostring(totalReq)))
                        
                        -- Print sub-criteria breakdown
                        for _, sub in ipairs(subResults) do
                            if not (GLT.db.hideCompleted and sub.isDone) then
                                local subColor = sub.isDone and "|c00FF00" or "|cFFFF00"
                                local cleanSubName = sub.name:gsub(" Outlaws Refuge", ""):gsub(" receive %d+ gold for fencing items%.", "")
                                d(stringFormat("  |cAAAAAA- %s|r: %s[%s/%s]|r", cleanSubName, subColor, tostring(sub.done), tostring(sub.req)))
                            end
                        end
                    end

                else
                    -- SINGLE-CRITERIA ACHIEVEMENT
                    local current, maximum = 0, 0
                    if numCriteria == 1 then
                        local _, nDone, nReq = GetAchievementCriterion(achId, 1)
                        current = nDone or 0
                        maximum = nReq or 0
                    end
                    
                    local isDone = false
                    if maximum > 0 then
                        isDone = (current >= maximum)
                    else
                        isDone = aCompleted
                    end

                    if not (GLT.db.hideCompleted and isDone) then
                        local color = isDone and "|c00FF00" or "|cFFFF00"
                        d(stringFormat("|cFFFFFF%s|r: %s[%s/%s]|r", aName, color, tostring(current), tostring(maximum)))
                    end
                end
            end
        end
    end
end

-- 5. Toggle Filter Command Handler
local function ToggleFilter()
    if not GLT.db then return end
    
    GLT.db.hideCompleted = not GLT.db.hideCompleted
    
    if GLT.db.hideCompleted then
        d("|cFFFF00[GLT]|r Now showing |c00FF00uncompleted|r achievements only.")
    else
        d("|cFFFF00[GLT]|r Now showing |cFFFFFFall|r achievements.")
    end
end

-- 6. Slash Command Router
local function SlashCommandRouter(option)
    local cleanOption = option and option:lower():match("^%s*(.-)%s*$")
    
    if cleanOption == "filter" or cleanOption == "toggle" then
        ToggleFilter()
    else
        GLT.CheckAchievements()
    end
end

-- 7. Event Handler
local function OnAddOnLoaded(event, addonName)
    if addonName ~= GLT.name then return end
    
    local defaults = {
        hideCompleted = false,
        achievementNames = {
            "Magnanimous Magnate", 
            "Dragon's Hoard", 
            "Eagle's Nest-Egg", 
            "Lion's Golden Pride", 
            "Merchant Lord's Coffers",
            "Wrothgar Larcenist", 
            "Gold Coast Larcenist", 
            "Vvardenfell Larcenist", 
            "Clockwork City Larcenist", 
            "Summerset Larcenist", 
            "Murkmire Larcenist", 
            "Northern Elsweyr Larcenist", 
            "Southern Elsweyr Larcenist", 
            "Western Skyrim Larcenist", 
            "The Reach Larcenist", 
            "Blackwood Larcenist", 
            "Fargrave Larcenist", 
            "High Isle Larcenist", 
            "Galen Larcenist", 
            "Necrom Larcenist", 
            "West Weald Larcenist", 
            "Solstice Larcenist"
        }
    }
    
    GLT.db = ZO_SavedVars:NewAccountWide("GrumpysLarcenistTracker_DB", 1, GetWorldName(), defaults)
    BuildAchievementCache()
    
    SLASH_COMMANDS["/glt"] = SlashCommandRouter
    EVENT_MANAGER:UnregisterForEvent(GLT.name, EVENT_ADD_ON_LOADED)
end

-- 8. Initial Registration
EVENT_MANAGER:RegisterForEvent(GLT.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)