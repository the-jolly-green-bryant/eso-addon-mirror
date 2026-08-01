-- Localize frequently-used globals for faster access (avoids repeated
-- global table lookups on every hook invocation).
local ZO_ShouldPreferUserId = ZO_ShouldPreferUserId
local zo_strformat = zo_strformat
local DoesCampaignHaveEmperor = DoesCampaignHaveEmperor
local GetCampaignEmperorInfo = GetCampaignEmperorInfo
local ZO_Tooltips_ShowTextTooltip = ZO_Tooltips_ShowTextTooltip
local ZO_Tooltips_HideTextTooltip = ZO_Tooltips_HideTextTooltip
local InitializeTooltip = InitializeTooltip
local ZO_ScrollList_GetData = ZO_ScrollList_GetData
local SetTooltipText = SetTooltipText

local groupEntryPostHook
groupEntryPostHook = function(self, control, data)
  if not ZO_ShouldPreferUserId() then
    return false
  end
  control.characterNameLabel:SetText(zo_strformat(SI_GROUP_LIST_PANEL_CHARACTER_NAME, data.index, data.displayName))
  return true
end

local leaderboardEntryPostHook
leaderboardEntryPostHook = function(self, control, data)
  if not ZO_ShouldPreferUserId() then
    return false
  end
  control.nameLabel:SetText(data.displayName)
  return false
end

-- Shared mouse handlers for the emperor name label. Defined once instead of
-- being recreated as new closures on every RefreshEmperor call.
local function emperorName_OnMouseEnter(emperorName)
  ZO_Tooltips_ShowTextTooltip(emperorName, TOP, emperorName.GroupUserId_characterName)
end

local function emperorName_OnMouseExit(emperorName)
  ZO_Tooltips_HideTextTooltip()
end

local refreshEmperorPostHook
refreshEmperorPostHook = function(self, control, data)
  if not ZO_ShouldPreferUserId() then
    return false
  end

  local emperorName = self.emperorName
  if not emperorName then
    return false
  end

  if DoesCampaignHaveEmperor(self.campaignId) then -- when there is no emperor we do nothing
    local alliance, characterName, displayName = GetCampaignEmperorInfo(self.campaignId)
    emperorName:SetText(displayName)

    -- Stash the characterName on the control instead of building new
    -- closures every refresh; register the handlers only once.
    emperorName.GroupUserId_characterName = characterName
    if not emperorName.userIdHandlersSet then
      emperorName:SetMouseEnabled(true)
      emperorName:SetHandler("OnMouseEnter", emperorName_OnMouseEnter)
      emperorName:SetHandler("OnMouseExit", emperorName_OnMouseExit)
      emperorName.userIdHandlersSet = true
    end
  end

  return false
end

local socialListOnMouseEnterPostHook
socialListOnMouseEnterPostHook = function(self, control)
  if not ZO_ShouldPreferUserId() then
    return false
  end
  local row = control:GetParent()
  local data = ZO_ScrollList_GetData(row)
  InitializeTooltip(InformationTooltip)
  local textwidth = control:GetTextDimensions()
  InformationTooltip:ClearAnchors()
  InformationTooltip:SetAnchor(BOTTOM, control, TOPLEFT, textwidth * 0.5, 0)
  if data.characterName then
      SetTooltipText(InformationTooltip, data.characterName)
  else
      SetTooltipText(InformationTooltip, data.name)
  end

  return false
end

local GroupUserId
do
  local _class_0
  local _base_0 = {
    name = "GroupUserId",
    hookUI = function(self)
      ZO_PostHook(GROUP_LIST, "SetupGroupEntry", groupEntryPostHook)
      ZO_PostHook(ZO_LeaderboardsManager_Shared, "SetupLeaderboardPlayerEntry", leaderboardEntryPostHook)
      ZO_PostHook(CampaignEmperor_Shared, "SetupLeaderboardEntry", leaderboardEntryPostHook)
      ZO_PostHook(CampaignEmperor_Shared, "RefreshEmperor", refreshEmperorPostHook)
      return ZO_PostHook(ZO_SocialListKeyboard, "CharacterName_OnMouseEnter", socialListOnMouseEnterPostHook)
    end,
    onAddonLoaded = function(_, addonName)
      if addonName == GroupUserId.name then
        EVENT_MANAGER:UnregisterForEvent(GroupUserId.name, EVENT_ADD_ON_LOADED)
        return GroupUserId:hookUI()
      end
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function() end,
    __base = _base_0,
    __name = "GroupUserId"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  GroupUserId = _class_0
end

return EVENT_MANAGER:RegisterForEvent(GroupUserId.name, EVENT_ADD_ON_LOADED, GroupUserId.onAddonLoaded)
