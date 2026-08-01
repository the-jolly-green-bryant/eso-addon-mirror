--[[
    AchievementInfo
    @author Asto, @Astarax
]]



-- Init
AchievementInfo.hijackedFirstLoad = false
function AchievementInfo.initialize(_, addOnName)
    if (addOnName ~= AchievementInfo.name) then return end

    --
    if AchievementInfo.hijackedFirstLoad == false then
        AchievementInfo.hijackedFirstLoad = true

        -- Load Saved Variables
        AchievementInfo.useAccountWideSettings = AchievementInfo.loadUseAccountWideSettings()
        AchievementInfo.savedVars = AchievementInfo.loadSavedVars()

        -- Load Language Data
        LANG = AchievementInfo.loadLanguage()

        -- Settings Panel
        AchievementInfo.createSettingsPanel()

        -- Register Events
        AchievementInfo.registerEvent(EVENT_ACHIEVEMENT_UPDATED, AchievementInfo.onAchievementUpdated)
    end

    -- Status Output (debug mode only)
    if AchievementInfo.settingGet("devDebug") then
        zo_callLater(function()
            AchievementInfo.echo(AchievementInfo.name .. " initialized in DEBUG MODE :)")
        end, 500)
    end
end



-- Register the Init Event
AchievementInfo.registerEvent(EVENT_ADD_ON_LOADED, AchievementInfo.initialize)
