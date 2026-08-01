--[[
    AchievementInfo
    @author Asto, @Astarax
]]



AchievementInfo             = {}
AchievementInfo.name        = "AchievementInfo"
AchievementInfo.author      = "Asto, @Astarax"
AchievementInfo.version     = 4.17
AchievementInfo.savedVars   = nil
AchievementInfo.LangStore   = {}

local clrPrefix = "|c"
AchievementInfo.clrDefault            = clrPrefix .. "87B7CC"
AchievementInfo.clrCriteriaFar        = clrPrefix .. "F27C7C"
AchievementInfo.clrCriteriaMedi       = clrPrefix .. "EDE858"
AchievementInfo.clrCriteriaClose      = clrPrefix .. "CCF048"
AchievementInfo.clrCriteriaComplete   = clrPrefix .. "71DE73"
AchievementInfo.clrSettingsHeader     = clrPrefix .. "F0C91A"




-- Load the correct language
function AchievementInfo.loadLanguage()
    local lang = GetCVar("language.2")

    if lang == "de" then
        return LANG_STORE.DE
    elseif lang == "fr" then
        return LANG_STORE.FR
    else
        return LANG_STORE.EN
    end
end



-- Event Registration Shortcut
function AchievementInfo.registerEvent(event, handler)
    EVENT_MANAGER:RegisterForEvent(AchievementInfo.name, event, handler)
end



-- Message Output Shortcut
function AchievementInfo.echo(message)
    -- addOn enabled?
    if AchievementInfo.settingGet("genEnabled") == false then return end

    if message ~= nil then
        CHAT_SYSTEM:AddMessage(AchievementInfo.clrDefault..message.."|r")
    end
end



-- Helper method to count a lua table
function AchievementInfo.tableLength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end
