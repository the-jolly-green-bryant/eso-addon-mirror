local addon = { name = "AchievementBar" }
local em = GetEventManager()

function addon:AddToContextMenu(achievement)
    local achievementId = achievement:GetId()
    local trackedAchievement = self.trackedAchievement
    if #trackedAchievement == 1 and trackedAchievement[1].id == achievementId then
        d("1")

        AddCustomMenuItem("Stop Tracking", function()
            trackedAchievement[1] = nil
            self:ResetAchievementBar()
        end)
    else
        local name, _, _, _, completed, _, _ = GetAchievementInfo(achievementId)
        if not completed then
            d("2")
            AddCustomMenuItem("Track", function()
                trackedAchievement[1] = {id = achievementId, name = name}
                d("3")
                self:SetUpAchievementBar(trackedAchievement[1])
                d("4")
            end)
        end
    end
end

function addon:SetUpAchievements()
    ZO_PreHook("ShowMenu", function(control)
        local name = control and control.GetName and control:GetName()
        if not name then return false end
        if control and control.achievement then
            addon:AddToContextMenu(control.achievement)
        end
        return false
    end)
end

function addon:RefreshAchievementBarVisibility()
    if ACHIEVEMENT_BAR.achievementBarShows then
        local hudFragment = HUD_FRAGMENT
        local hudUiFragment = HUD_UI_FRAGMENT

        local hudVisible = false
        if hudFragment and hudFragment.IsShowing and hudFragment:IsShowing() then
            hudVisible = true
        elseif hudUiFragment and hudUiFragment.IsShowing and hudUiFragment:IsShowing() then
            hudVisible = true
        end

        local visible = hudVisible and not IsUnitInCombat("player")
        AchievementBarGUI:SetHidden(not visible)
    end
end

local function OnAchievementUpdated(_, achievementId)
    if #addon.trackedAchievement == 1 and addon.trackedAchievement[1].id == achievementId then
        addon:SetUpAchievementBar(addon.trackedAchievement[1])
    end
end

local function OnAchievementAwarded(eventCode, _, _, achievementId)
    OnAchievementUpdated(eventCode, achievementId)
end


function addon:SetUpAchievementBar(achievementInfo)
    local totalCompleted = 0
    local totalRequired = 0
    local achievementId = achievementInfo.id
    local achievementName = achievementInfo.name
    local numCriteria = GetAchievementNumCriteria(achievementId)
    for i = 1, numCriteria, 1 do
        local _, numCompleted, numRequired = GetAchievementCriterion(achievementId, i)
        totalCompleted = totalCompleted + numCompleted
        totalRequired = totalRequired + numRequired
    end

    local percentComplete = math.floor((totalCompleted / totalRequired) * 100)

    if percentComplete >= 100 then
        self:ResetAchievementBar()
        d(string.format("Achievement bar: %s completed.", achievementName))
        local nextAchievementId = GetNextAchievementInLine(achievementId)
        if nextAchievementId > 0 then
            d("Achievement bar: Showing the followup achievement.")
            local nextAchievementName = GetAchievementInfo(nextAchievementId)
            self.trackedAchievement[1] = {id = nextAchievementId, name = nextAchievementName}
            addon:SetUpAchievementBar(self.trackedAchievement[1])
        else
            d("Achievement bar: No followup achievement, removing the bar.")
            self.achievementBarShows = false
        end
    else
        AchievementBarGUIBarContainerBarLabel:SetText(string.format("%s: %d / %d (%d%%)", achievementName, totalCompleted, totalRequired, percentComplete))
        AchievementBarGUIBarContainerBarBG:SetColor(0,0,0, 0)

        AchievementBarGUIBarContainerBarFill:SetMinMax(0, 100)
        AchievementBarGUIBarContainerBarFill:SetValue(percentComplete)

        if percentComplete > 66 then
            AchievementBarGUIBarContainerBarFill:SetColor(0.808, 0.722, 0.263, 1) -- gold
        elseif percentComplete < 33 then
            AchievementBarGUIBarContainerBarFill:SetColor(0.804, 0.498, 0.196, 1) -- bronze
        else
            AchievementBarGUIBarContainerBarFill:SetColor(0.753, 0.753, 0.753, 1) -- silver
        end

        if not self.achievementBarShows then
            self.achievementBarShows = true
        end
    end
    self:RefreshAchievementBarVisibility()
end

function addon:ResetAchievementBar()
    self.achievementBarShows = false
    AchievementBarGUI:SetHidden(true)
end

function addon:Initialize()
    local defaults = { trackedAchievement = {} }
    self.trackedAchievement = ZO_SavedVars:New("AchievementBar_Data", 1, nil, defaults).trackedAchievement
    self.achievementBarShows = false
    -- Check if trackedAchievement is empty
    if #self.trackedAchievement == 1 then
        self:SetUpAchievementBar(self.trackedAchievement[1])
    end
    self:SetUpAchievements()
end

--https://wiki.esoui.com/Events
local function OnAddOnLoaded(_, addonName)
    if addonName ~= addon.name then return end
    em:UnregisterForEvent(addon.name, EVENT_ADD_ON_LOADED)
    addon:Initialize()
    em:RegisterForEvent("AchievementBarCombat", EVENT_PLAYER_COMBAT_STATE, addon.RefreshAchievementBarVisibility)
    HUD_SCENE:RegisterCallback("StateChange", addon.RefreshAchievementBarVisibility)
    em:RegisterForEvent("AchievementBar_Update", EVENT_ACHIEVEMENT_UPDATED, OnAchievementUpdated)
    em:RegisterForEvent("AchievementBar_Awarded", EVENT_ACHIEVEMENT_AWARDED, OnAchievementAwarded)
end
em:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

ACHIEVEMENT_BAR = addon
