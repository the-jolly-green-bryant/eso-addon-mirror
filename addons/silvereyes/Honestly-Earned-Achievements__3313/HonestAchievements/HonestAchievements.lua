-- Honestly-Earned Achievements Addon for Elder Scrolls Online
-- Author: silvereyes

HonestAchievements = {
    name = "HonestAchievements",
    title = "Honestly-Earned Achievements",
    version = "1.0.0",
    author = "silvereyes",
}

-- Local declarations
local addon = HonestAchievements
local COLOR_TOOLTIP = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_NORMAL))
local U33_RELEASE_TIMESTAMP = StringToId64((GetWorldName() == "PTS" and "1644865200") or "1647234000")
local onAddonLoaded, prehookGetCharIdForCompletedAchievement, prehookShowAchievementTooltip, posthookZOTooltipOnCleared



---------------------------------------
--
--          Public Methods
-- 
---------------------------------------
--[[
   Adds details for a completed account-wide achivement to a given tooltip.
   This function assumes achievementId refers to an account-wide achievement that is already completed.
  ]]--
function HonestAchievements:SetCompletedAccountAchievementTooltip(tooltip, achievementId)
    
    -- Get achievement details
    local achievementName, description, points, icon, completed, date, time = GetAchievementInfo(achievementId)
    
    -- Completed status
    local statusText = GetString(SI_ACHIEVEMENTS_TOOLTIP_COMPLETE)
    tooltip:AddHeaderLine(statusText, "ZoFontWinT2", 1, TOOLTIP_HEADER_SIDE_LEFT, COLOR_TOOLTIP:UnpackRGB())
    
    -- Date
    tooltip:AddHeaderLine(date, "ZoFontWinT2", 1, TOOLTIP_HEADER_SIDE_RIGHT, COLOR_TOOLTIP:UnpackRGB())
    
    tooltip:AddVerticalPadding(-5)
    
    -- Title
    local title = zo_strformat(SI_ACHIEVEMENTS_NAME, achievementName)
    local r, g, b = ZO_SELECTED_TEXT:UnpackRGB()
    local FULL_WIDTH = true
    tooltip:AddLine(title, "ZoFontWinH2", r, g, b, TOPLEFT, MODIFY_TEXT_TYPE_UPPERCASE, TEXT_ALIGN_CENTER, FULL_WIDTH)
    
    -- Divider
    tooltip:AddVerticalPadding(-10)
    ZO_Tooltip_AddDivider(tooltip)
    
    -- Points
    if not tooltip.honestAchievementsTooltipPointsPool then
        tooltip.honestAchievementsTooltipPointsPool = ZO_ControlPool:New("HonestAchievementsTooltipPointsBase", tooltip, "Points")
    end
    local pointsControl = tooltip.honestAchievementsTooltipPointsPool:AcquireObject()
    if pointsControl then
        local pointsContainer = pointsControl:GetNamedChild("Container")
        local label = pointsContainer:GetNamedChild("Label")
        label:SetText(GetString(SI_ACHIEVEMENTS_POINTS_STATIC))
        local value = pointsContainer:GetNamedChild("Value")
        value:SetText(points)
        tooltip:AddVerticalPadding(-12)
        tooltip:AddControl(pointsControl)
        pointsControl:SetAnchor(CENTER)
    end
    
    -- Body
    tooltip:AddVerticalPadding(5)
    r, g, b = ZO_NORMAL_TEXT:UnpackRGB()
    tooltip:AddLine(zo_strformat(SI_ACHIEVEMENTS_DESCRIPTION, description), "", r, g, b, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, SET_TO_FULL_SIZE)
end

--[[
   Hooks up this addon's functionality to the base game achievement functions and tooltips.
  ]]--
function HonestAchievements:SetupHooks()
    ZO_PreHook("GetCharIdForCompletedAchievement", prehookGetCharIdForCompletedAchievement)
    ZO_PreHook(AchievementTooltip, "SetAchievement", prehookShowAchievementTooltip)
    SecurePostHook("ZO_Tooltip_OnCleared", posthookZOTooltipOnCleared)
end

--[[
   Returns true if the given achivement id should have it's "Earned by" tooltips suppressed. Otherwise, returns nil.
   A true value will be returned for achievements with the following qualities:
     * Multiple criteria or requirements
     * Achivement date is after the release of Update 33
  ]]--
function HonestAchievements:SuppressEarnedByForAchievementId(achievementId)
    if not achievementId then
        return
    end
    -- Always display achievements earned before Update 33
    if self:WasAchievementEarnedBeforeUpdate33(achievementId) then
        return
    end
    local isCharacterPersistent = GetAchievementPersistenceLevel(achievementId) == ACHIEVEMENT_PERSISTENCE_CHARACTER
    if isCharacterPersistent then
        return
    end
    local numCriteria = GetAchievementNumCriteria(achievementId)
    local hasMultipleCriteria = (numCriteria > 1)
    -- Hide any achievements earned after Update 33 that have multiple criteria
    if hasMultipleCriteria then
        return true
    end
    local _, _, numRequirements = GetAchievementCriterion(achievementId, 1)
    local hasMultipleRequirements = (numRequirements > 1)
    if hasMultipleRequirements then
        return true
    end
end

--[[
   Returns true if the given achivement id was completed before the release of account-wide achievements in Update 33.
  ]]--
function HonestAchievements:WasAchievementEarnedBeforeUpdate33(achievementId)
    local timestamp = GetAchievementTimestamp(achievementId)
    if timestamp and CompareId64ToNumber(timestamp, 0) > 0 and CompareId64s(timestamp, U33_RELEASE_TIMESTAMP) < 0 then
        return true
    end
end


---------------------------------------
--
--          Private Methods
-- 
---------------------------------------

function onAddonLoaded(event, name)
    if name ~= addon.name then return end
    EVENT_MANAGER:UnregisterForEvent(addon.name, EVENT_ADD_ON_LOADED)
    addon:SetupHooks()
end

--[[
   Prehook method for GetCharIdForCompletedAchievement(achievementId) calls.
   This suppresses the small mouseover tooltips that appear to the left of achievements in the quest journal list.
  ]]--
function prehookGetCharIdForCompletedAchievement(achievementId)
    return addon:SuppressEarnedByForAchievementId(achievementId)
end

--[[
   Prehook method for AchievementTooltip:SetAchievement(achievementId) calls.
   This suppresses the "Earned by" text in the larger detailed tooltips that show when you hover over individual
   achievement links or steps in the quest journal list.
  ]]--
function prehookShowAchievementTooltip(tooltip, achievementId)
    if addon:SuppressEarnedByForAchievementId(achievementId) then
        addon:SetCompletedAccountAchievementTooltip(tooltip, achievementId)
        return true
    end
end

--[[
   Prehook method for ZO_Tooltip_OnCleared(tooltipControl) calls.
   This frees up resources associated with the custom control used for displaying points values on detailed
   tooltips for completed account-wide achievements.
  ]]--
function posthookZOTooltipOnCleared(tooltip)
    if tooltip.honestAchievementsTooltipPointsPool then
        tooltip.honestAchievementsTooltipPointsPool:ReleaseAllObjects()
    end
end

-- Register addon
EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, onAddonLoaded)