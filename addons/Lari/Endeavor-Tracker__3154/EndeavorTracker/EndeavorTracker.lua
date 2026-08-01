local ET = _G["ET"]

local WM = WINDOW_MANAGER

local isETPanelHidden = true

function ET.SetToolTip(control, position, text)
  control:SetHandler("onMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, position, text) end)
  control:SetHandler("OnMouseExit", function(self) ZO_Tooltips_HideTextTooltip() end)
end

---------------------------------
-- POSITIONING AND DISPLAY --
---------------------------------

function ET.ButtonOnMoveStop()
  ET.SavedVars.buttonLeft = ET_ShortcutBG:GetLeft()
  ET.SavedVars.buttonTop = ET_ShortcutBG:GetTop()
end

function ET.PanelOnMoveStop()
  ET.SavedVars.panelLeft = ET_Panel:GetLeft()
  ET.SavedVars.panelTop = ET_Panel:GetTop()
  ET.SavedVars.panelBottom = ET_Panel:GetBottom()
  ET.RefreshEndeavorList()      -- Update tooltip locations
end

function ET.RestoreButtonPosition()
  local buttonLeft = ET.SavedVars.buttonLeft
  local buttonTop = ET.SavedVars.buttonTop

  if buttonLeft ~= nil and buttonTop ~= nil then
    ET_ShortcutBG:ClearAnchors()
    ET_ShortcutBG:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, buttonLeft, buttonTop)
  end
end

function ET.RestorePanelPosition()
  local panelLeft = ET.SavedVars.panelLeft
  local panelTop = ET.SavedVars.panelTop
  local panelBottom = ET.SavedVars.panelBottom

  if panelLeft ~= nil and panelTop ~= nil then
    ET_Panel:ClearAnchors()

    if ET.SavedVars.anchorPanelSetting == false then
      ET_Panel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, panelLeft, panelTop)
    else
      ET_Panel:SetAnchor(BOTTOMLEFT, GuiRoot, TOPLEFT, panelLeft, panelBottom)
    end
  end
end

function ET.ResetPositions()
  ET_ShortcutBG:ClearAnchors()
  ET_ShortcutBG:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, 10, -10)
  ET_Panel:ClearAnchors()
  ET_Panel:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, 10, 80)
  ET.SavedVars.buttonLeft = nil
  ET.SavedVars.buttonTop = nil
  ET.SavedVars.panelLeft = nil
  ET.SavedVars.panelTop = nil
end

function ET.TogglePanel()
  ET_Panel:ToggleHidden()
  isETPanelHidden = ET_Panel:IsHidden()
  return isETPanelHidden
end

function ET_Toggle_Panel()
  ET.TogglePanel()
end

function ET.ToggleDailies(setting)
  ET.SavedVars.areDailiesCollapsed = setting
  ET_Panel_DailyCollapseButton:SetHidden(setting)
  ET_Panel_DailyExpandButton:SetHidden(not setting)
  ET.RefreshEndeavorPositions()
end

function ET.ToggleWeeklies(setting)
  ET.SavedVars.areWeekliesCollapsed = setting
  ET_Panel_WeeklyCollapseButton:SetHidden(setting)
  ET_Panel_WeeklyExpandButton:SetHidden(not setting)
  ET.RefreshEndeavorPositions()
end

function ET.ToggleCheckboxes(setting)
  local numActivities = GetNumTimedActivities()
  for index = 1, numActivities do
    local listEntryCheckbox = WM:GetControlByName(string.format("ET_Endeavor_Index_%i_Checkbox", index))
    listEntryCheckbox:SetHidden(not setting)
  end
  ET.SavedVars.checkedEntries = {}
end

function ET.DisplayPanelBySetting(setting)

  if ET.SavedVars.displayInDungeons == false then
    if IsUnitInDungeon("player") and GetCurrentZoneDungeonDifficulty() ~= DUNGEON_DIFFICULTY_NONE then
      ET_Panel:SetHidden(true)
      isETPanelHidden = true
      return isETPanelHidden
    end
  end

  if ET.SavedVars.displayInCyroAndBGs == false then
    if IsPlayerInAvAWorld() or IsActiveWorldBattleground() then
      ET_Panel:SetHidden(true)
      isETPanelHidden = true
      return isETPanelHidden
    end
  end

  if ET.SavedVars.displayInCombat == false then
    if IsUnitInCombat("player") then
      ET_Panel:SetHidden(true)
      isETPanelHidden = true
      return isETPanelHidden
    end
  end

  if setting == ET.DisplaySettings[1] then -- Never
    return -- do nothing
  end

  local dailiesCompleted = ET.IsEndeavorTypeCompleted(TIMED_ACTIVITY_TYPE_DAILY)
  local weekliesCompleted = ET.IsEndeavorTypeCompleted(TIMED_ACTIVITY_TYPE_WEEKLY)

  isETPanelHidden = true

  if setting == ET.DisplaySettings[2] then -- Missing endeavors
    if dailiesCompleted == false or weekliesCompleted == false then
      isETPanelHidden = false
    end
  elseif setting == ET.DisplaySettings[3] then -- Missing dailies
    if dailiesCompleted == false then
      isETPanelHidden = false
    end
  elseif setting == ET.DisplaySettings[4] then -- Missing weeklies
    if weekliesCompleted == false then
      isETPanelHidden = false
    end
  elseif setting == ET.DisplaySettings[5] then -- Always
    isETPanelHidden = false
  end

  local scene = SCENE_MANAGER:GetCurrentScene():GetName()
  if scene == "hud" or scene == "hudui" then
    ET_Panel:SetHidden(isETPanelHidden)
  end

  return isETPanelHidden
end

function ET.SetCustomFontSize(fontSize)
  local titleFont = string.format("$(BOLD_FONT)|$(KB_%i)|soft-shadow-thin", fontSize + 2)
  local headerFont = string.format("$(BOLD_FONT)|$(KB_%i)|soft-shadow-thin", fontSize)
  local entryFont = string.format("$(MEDIUM_FONT)|$(KB_%i)|soft-shadow-thin", fontSize)

  ET_PanelTitle:SetFont(titleFont)
  ET_PanelEndeavorTotal:SetFont(titleFont)

  ET_Panel_DailyHeader:SetFont(headerFont)
  ET_Panel_DailyStatus:SetFont(headerFont)
  ET_Panel_WeeklyHeader:SetFont(headerFont)
  ET_Panel_WeeklyStatus:SetFont(headerFont)

  for index = 1, GetNumTimedActivities() do
    local listEntryName = WM:GetControlByName(string.format("ET_Endeavor_Index_%i_Name", index))
    local listEntryProgress = WM:GetControlByName(string.format("ET_Endeavor_Index_%i_Progress", index))
    listEntryName:SetFont(entryFont)
    listEntryProgress:SetFont(entryFont)
  end
end

----------------------------------
-- HELPER FUNCTIONS --
----------------------------------

function ET.GetTimeRemainingForEndeavorType(activityType)
  local numActivities = GetNumTimedActivities()
  for index = 1, numActivities do
    if GetTimedActivityType(index) == activityType then
      return GetTimedActivityTimeRemainingSeconds(index)
    end
  end
end

function ET.IsEndeavorTypeInProgress(activityType)
  local numActivities = GetNumTimedActivities()
  for index = 1, numActivities do
    if GetTimedActivityType(index) == activityType and GetTimedActivityProgress(index) > 0 then
      return true
    end
  end
  return false
end

function ET.IsEndeavorTypeCompleted(activityType)
  local completed = GetNumTimedActivitiesCompleted(activityType)
  local limit = GetTimedActivityTypeLimit(activityType)
  if completed == limit then
    return true
  end
  return false
end

function ET.OnEndeavorCheckboxClicked(listEntryCheckbox, checked)
  local index = listEntryCheckbox:GetId()
  local endeavorName = GetTimedActivityName(index)
  local checkedEntries = ET.SavedVars.checkedEntries

  for i = 1, #checkedEntries do
    if endeavorName == checkedEntries[i] then
      if checked == true then
        return
      else
        table.remove(checkedEntries, i)
        ET.RefreshEndeavorPositions()
        return
      end
    end
  end

  table.insert(checkedEntries, endeavorName)
  table.sort(checkedEntries)
end

function ET.IsCheckedEntryCurrentEndeavor(i)
  local checkedEntries = ET.SavedVars.checkedEntries
  local numActivities = GetNumTimedActivities()
  for index = 1, numActivities do
    if checkedEntries[i] == GetTimedActivityName(index) then
      local listEntryCheckbox = WM:GetControlByName(string.format("ET_Endeavor_Index_%i_Checkbox", index))
      ZO_CheckButton_SetChecked(listEntryCheckbox)
      return
    end
  end
  table.remove(checkedEntries, i)
end

function ET.GetEndeavorRewardsAsText(index)
  local rewardText = ""
  for rewardIndex = 1, GetNumTimedActivityRewards(index) do
    local rewardId, quantity = GetTimedActivityRewardInfo(index, rewardIndex)
    local rewardType = GetRewardType(rewardId)
    if rewardType == REWARD_ENTRY_TYPE_ADD_CURRENCY then
      local currencyType = GetAddCurrencyRewardInfo(rewardId)
      local currencyIcon =  GetCurrencyLootKeyboardIcon(currencyType)
      rewardText = string.format("%s|cFFFFFF+%i|r |t20:20:%s|t ", rewardText, quantity, currencyIcon)
    elseif rewardType == REWARD_ENTRY_TYPE_EXPERIENCE then
      rewardText = string.format("%s|cFFFFFF+%i XP|r ", rewardText, quantity)
    end
  end
  return rewardText
end

function ET.GetEndeavorRewardsAsTable(index)
  local rewardsTable = {}
  for rewardIndex = 1, GetNumTimedActivityRewards(index) do
    local rewardId, quantity = GetTimedActivityRewardInfo(index, rewardIndex)
    rewardsTable[rewardIndex] = {}
    rewardsTable[rewardIndex][rewardId] = quantity
  end
  return rewardsTable
end

-- Check the lowest endeavor reward value
function ET.GetMinEndeavorReward(activityType)
  local minReward
  local numActivities = GetNumTimedActivities()
  for index = 1, numActivities do
    if GetTimedActivityType(index) == activityType then
      local _, quantity = GetTimedActivityRewardInfo(index, 1)
      if minReward ~= nil then
        minReward = math.min(minReward, quantity)
      else
        minReward = quantity
      end
    end
  end
  return minReward
end

-- Check if an endeavor has an additional secondary reward
function ET.DoesEndeavorHaveExtraSecondaryRewards(index)
  local numRewards = GetNumTimedActivityRewards(index)
  local activityType = GetTimedActivityType(index)
  local numActivities = GetNumTimedActivities()
  for i = 1, numActivities do
    if GetTimedActivityType(i) == activityType then
      if numRewards > GetNumTimedActivityRewards(i) then
        return true
      end
    end
  end
  return false
end

---------------------------------------
-- UPDATE ENDEAVORS BY INDEX --
---------------------------------------

function ET.UpdateEndeavorEntry(index, minRewardInfo)
  local activityType = GetTimedActivityType(index)
  local _, quantity = GetTimedActivityRewardInfo(index, 1)

  local listEntryName = WM:GetControlByName(string.format("ET_Endeavor_Index_%i_Name", index))
  local listEntryProgress = WM:GetControlByName(string.format("ET_Endeavor_Index_%i_Progress", index))
  local listEntryCheckbox = WM:GetControlByName(string.format("ET_Endeavor_Index_%i_Checkbox", index))

  local description = GetTimedActivityDescription(index)
  local rewardText = ET.GetEndeavorRewardsAsText(index)
  local lootTexture = "|t20:20:esoui/art/icons/justice_stolen_wax_sealed_heavy_sack.dds|t"
  
  local listEntryText = GetTimedActivityName(index)
  local tooltipText = string.format("%s\n\n%s: %s", description, GetString(ENDEAVOR_TRACKER_Misc_Rewards), rewardText)

  -- Check if an endeavor has additional secondary rewards and display an icon on the endeavor entry
  if ET.DoesEndeavorHaveExtraSecondaryRewards(index) then
    local rewardIcons = ""
    for rewardIndex = 2, GetNumTimedActivityRewards(index) do
      local rewardId,_ = GetTimedActivityRewardInfo(index, rewardIndex)
      local rewardType = GetRewardType(rewardId)
      if rewardType == REWARD_ENTRY_TYPE_ADD_CURRENCY then
        local currencyType = GetAddCurrencyRewardInfo(rewardId)
        currencyIcon = GetCurrencyLootKeyboardIcon(currencyType)
        rewardIcons = string.format("%s|t20:20:%s|t", rewardIcons, currencyIcon)
      elseif rewardType == REWARD_ENTRY_TYPE_EXPERIENCE then
        rewardIcons = string.format("%s|t20:20:%s|t", rewardIcons, "esoui/art/icons/icon_experience.dds")
      end
    end
    listEntryText = string.format("%s %s", rewardIcons, listEntryText)
  end

  -- If some endeavors have higher values than others, then this will display an icon next to the endeavor so that players can prioritise that endeavor
  if quantity > minRewardInfo[activityType] then
    listEntryText = string.format("%s %s", lootTexture, listEntryText)
    tooltipText = string.format("%s |cFFFFFF%s|r %s\n\n%s", lootTexture, GetString(ENDEAVOR_TRACKER_Misc_HighEndeavorReward), lootTexture, tooltipText)
  end

  listEntryName:SetText(listEntryText)

  if ET_Panel:GetLeft() < 400 then
    listEntryName:SetHandler("onMouseEnter", function(self) InitializeTooltip(InformationTooltip, listEntryProgress, LEFT, 10, 0, RIGHT)
                                                        SetTooltipText(InformationTooltip, tooltipText) end)
  else
    listEntryName:SetHandler("onMouseEnter", function(self) InitializeTooltip(InformationTooltip, listEntryCheckbox, RIGHT, -10, 0, LEFT)
                                                        SetTooltipText(InformationTooltip, tooltipText) end)
  end
  listEntryName:SetHandler("OnMouseExit", function(self) ClearTooltip(InformationTooltip) end)
end

function ET.UpdateEndeavorProgress(index)
  local listEntryName = WM:GetControlByName(string.format("ET_Endeavor_Index_%i_Name", index))
  local listEntryProgress = WM:GetControlByName(string.format("ET_Endeavor_Index_%i_Progress", index))

  local progress = GetTimedActivityProgress(index)
  local maxProgress = GetTimedActivityMaxProgress(index)
  local progressText = string.format("%i/%i", progress, maxProgress)

  listEntryProgress:SetText(progressText)
  if listEntryProgress:WasTruncated() then
    ET.SetToolTip(listEntryProgress, RIGHT, progressText)
  end

  if progress == maxProgress then
    listEntryName:SetColor(ET.SavedVars.green.r, ET.SavedVars.green.g, ET.SavedVars.green.b, ET.SavedVars.green.a)
    listEntryProgress:SetColor(ET.SavedVars.green.r, ET.SavedVars.green.g, ET.SavedVars.green.b, ET.SavedVars.green.a)
  elseif progress ~= 0 then
    listEntryName:SetColor(ET.SavedVars.orange.r, ET.SavedVars.orange.g, ET.SavedVars.orange.b, ET.SavedVars.orange.a)
    listEntryProgress:SetColor(ET.SavedVars.orange.r, ET.SavedVars.orange.g, ET.SavedVars.orange.b, ET.SavedVars.orange.a)
  else
    listEntryName:SetColor(ET.SavedVars.white.r, ET.SavedVars.white.g, ET.SavedVars.white.b, ET.SavedVars.white.a)
    listEntryProgress:SetColor(ET.SavedVars.white.r, ET.SavedVars.white.g, ET.SavedVars.white.b, ET.SavedVars.white.a)
  end
end

function ET.UpdateEndeavorHeader(activityType, controlHeader, controlProgress, stringId)
  local completed = GetNumTimedActivitiesCompleted(activityType)
  local limit = GetTimedActivityTypeLimit(activityType)
  local progress = string.format("%i/%i", completed, limit)

  local endeavorTypeInProgress = ET.IsEndeavorTypeInProgress(activityType)
  local string = GetString(stringId)
  local text

  if completed >= limit then
    controlHeader:SetColor(ET.SavedVars.green.r, ET.SavedVars.green.g, ET.SavedVars.green.b, ET.SavedVars.green.a)
    controlProgress:SetColor(ET.SavedVars.green.r, ET.SavedVars.green.g, ET.SavedVars.green.b, ET.SavedVars.green.a)
    text = zo_strformat(GetString(ENDEAVOR_TRACKER_HeaderEndeavorsCompleted), string)
  elseif endeavorTypeInProgress == true then
    controlHeader:SetColor(ET.SavedVars.orange.r, ET.SavedVars.orange.g, ET.SavedVars.orange.b, ET.SavedVars.orange.a)
    controlProgress:SetColor(ET.SavedVars.orange.r, ET.SavedVars.orange.g, ET.SavedVars.orange.b, ET.SavedVars.orange.a)
    text = zo_strformat(GetString(ENDEAVOR_TRACKER_HeaderEndeavorsInProgress), string)
  elseif endeavorTypeInProgress == false then
    controlHeader:SetColor(ET.SavedVars.red.r, ET.SavedVars.red.g, ET.SavedVars.red.b, ET.SavedVars.red.a)
    controlProgress:SetColor(ET.SavedVars.red.r, ET.SavedVars.red.g, ET.SavedVars.red.b, ET.SavedVars.red.a)
    text = zo_strformat(GetString(ENDEAVOR_TRACKER_HeaderEndeavorsNotStarted), string)
  end

  if ET.SavedVars.displayTimeRemaining == true then
    local timeRemainingS = ET.GetTimeRemainingForEndeavorType(activityType)
    local timeRemainingFormatted = ZO_FormatTime(timeRemainingS, TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_TWELVE_HOUR_NO_SECONDS, TIME_FORMAT_DIRECTION_DESCENDING)
    text = string.format("%s (%s)", text, timeRemainingFormatted)
  end

  controlHeader:SetText(text)
  controlProgress:SetText(progress)
end

function ET.OnEndeavorProgressUpdated(event, index, previousProgress, currentProgress, complete)
  local maxProgress = GetTimedActivityMaxProgress(index)
  local name = GetTimedActivityName(index)
  local progress = string.format("(%i/%i)", currentProgress, maxProgress)

  local activityType = GetTimedActivityType(index)
  local activityTypeName
  if activityType == TIMED_ACTIVITY_TYPE_DAILY then
    activityTypeName = GetString(SI_TIMEDACTIVITYTYPE0)
  elseif activityType == TIMED_ACTIVITY_TYPE_WEEKLY then
    activityTypeName = GetString(SI_TIMEDACTIVITYTYPE1)
  end

  if complete == false and ET.SavedVars.progressUpdatesEnabled == true then
    local prefixText = zo_strformat(GetString(ENDEAVOR_TRACKER_ChatMsgEndeavorProgress), activityTypeName)
    CHAT_SYSTEM:AddMessage(string.format("|cE7B416%s:|r %s %s", prefixText, name, progress))
  elseif complete == true and ET.SavedVars.completionMessageEnabled == true then
    local completed = GetNumTimedActivitiesCompleted(activityType)
    local limit = GetTimedActivityTypeLimit(activityType)
    local numCompleted = string.format("(%i/%i)", completed, limit)
    local rewardText = ET.GetEndeavorRewardsAsText(index)
    local prefixText = zo_strformat(GetString(ENDEAVOR_TRACKER_ChatMsgEndeavorCompleted), activityTypeName)
    CHAT_SYSTEM:AddMessage(string.format("|c33A532%s %s:|r %s %s %s", prefixText, numCompleted, name, progress, rewardText))
  end

  if complete == true then
    local id = GetTimedActivityId(index)
    local rewardsTable = ET.GetEndeavorRewardsAsTable(index)
    local totalEndeavors = GetCurrencyAmount(CURT_ENDEAVOR_SEALS, CURRENCY_LOCATION_ACCOUNT)
    ET.UpdateHistory(id, name, activityType, rewardsTable, totalEndeavors)
    ET.RefreshHistory(activityType)
    ET.RefreshHistoryStats()
  end

  -- Refresh all after each event because endeavor indices are stupidly arranged
  ET.RefreshAll()
  ET.DisplayPanelBySetting(ET.SavedVars.displayPanelSetting)
end

function ET.UpdateTotalEndeavors()
  local totalEndeavors = GetCurrencyAmount(CURT_ENDEAVOR_SEALS, CURRENCY_LOCATION_ACCOUNT)
  local texture = " |t20:20:esoui/art/currency/currency_seals_of_endeavor_64.dds|t"
  ET_PanelEndeavorTotal:SetText(string.format("%i%s", totalEndeavors, texture))
  ET_HistoryEndeavorTotal:SetText(string.format("%i%s", totalEndeavors, texture))
end

---------------------------------------
-- REFRESH FULL ENDEAVOR LIST --
---------------------------------------

function ET.RefreshEndeavorHeaders()
  ET.UpdateEndeavorHeader(TIMED_ACTIVITY_TYPE_DAILY, ET_Panel_DailyHeader, ET_Panel_DailyStatus, SI_TIMEDACTIVITYTYPE0)
  ET.UpdateEndeavorHeader(TIMED_ACTIVITY_TYPE_WEEKLY, ET_Panel_WeeklyHeader, ET_Panel_WeeklyStatus, SI_TIMEDACTIVITYTYPE1)
end

function ET.RefreshEndeavorList()
  local numActivities = GetNumTimedActivities()

  -- Check lowest endeavor reward value for daily and weekly endeavors
  local minRewardInfo = {}
  minRewardInfo[TIMED_ACTIVITY_TYPE_DAILY] = ET.GetMinEndeavorReward(TIMED_ACTIVITY_TYPE_DAILY)
  minRewardInfo[TIMED_ACTIVITY_TYPE_WEEKLY] = ET.GetMinEndeavorReward(TIMED_ACTIVITY_TYPE_WEEKLY)

  for index = 1, numActivities do
    ET.UpdateEndeavorEntry(index, minRewardInfo)
    ET.UpdateEndeavorProgress(index)
  end
end

function ET.RefreshEndeavorCheckboxes()
  local checkedEntries = ET.SavedVars.checkedEntries
  local numActivities = GetNumTimedActivities()
  for i = 1, #checkedEntries do
    ET.IsCheckedEntryCurrentEndeavor(i)
  end
end

-- Stupid endeavors don't have fixed indices, so each control needs to be repositioned each time something gets updated
function ET.RefreshEndeavorPositions()
  local numActivities = GetNumTimedActivities()
  for index = 1, numActivities do
    local listEntry = WM:GetControlByName(string.format("ET_Endeavor_Index_%i", index))
    local listEntryCheckbox = WM:GetControlByName(string.format("ET_Endeavor_Index_%i_Checkbox", index))
    listEntry:SetParent(ET_Panel)
    listEntry:ClearAnchors()
    listEntry:SetHidden(true)
    ZO_CheckButton_SetUnchecked(listEntryCheckbox)
  end

  -- Load checkboxes before endeavors are positioned
  ET.RefreshEndeavorCheckboxes()

  for index = 1, numActivities do
    local listEntry = WM:GetControlByName(string.format("ET_Endeavor_Index_%i", index))
    local listEntryCheckbox = WM:GetControlByName(string.format("ET_Endeavor_Index_%i_Checkbox", index))
    local activityType = GetTimedActivityType(index)

    if activityType == TIMED_ACTIVITY_TYPE_DAILY then
      if ET.SavedVars.areDailiesCollapsed == false or ZO_CheckButton_IsChecked(listEntryCheckbox) == true then
        local parentControl = WM:GetControlByName("ET_DailyActivities")
        local relativeControl = parentControl:GetChild(parentControl:GetNumChildren())
        listEntry:SetParent(parentControl)
        listEntry:SetAnchor(TOPLEFT, relativeControl, BOTTOMLEFT, 0, 5)
        listEntry:SetHidden(false)
      end
    end

    if activityType == TIMED_ACTIVITY_TYPE_WEEKLY then
      if ET.SavedVars.areWeekliesCollapsed == false or ZO_CheckButton_IsChecked(listEntryCheckbox) == true then
        local parentControl = WM:GetControlByName("ET_WeeklyActivities")
        local relativeControl = parentControl:GetChild(parentControl:GetNumChildren())
        listEntry:SetParent(parentControl)
        listEntry:SetAnchor(TOPLEFT, relativeControl, BOTTOMLEFT, 0, 5)
        listEntry:SetHidden(false)
      end
    end
  end
end

function ET.RefreshAll()
  -- Autocollapse completed endeavor types if setting is ON
  if ET.SavedVars.collapseCompletedEndeavors == true then
    ET.SavedVars.areDailiesCollapsed = ET.IsEndeavorTypeCompleted(TIMED_ACTIVITY_TYPE_DAILY)
    ET_Panel_DailyCollapseButton:SetHidden(ET.SavedVars.areDailiesCollapsed)
    ET_Panel_DailyExpandButton:SetHidden(not ET.SavedVars.areDailiesCollapsed)

    ET.SavedVars.areWeekliesCollapsed = ET.IsEndeavorTypeCompleted(TIMED_ACTIVITY_TYPE_WEEKLY)
    ET_Panel_WeeklyCollapseButton:SetHidden(ET.SavedVars.areWeekliesCollapsed)
    ET_Panel_WeeklyExpandButton:SetHidden(not ET.SavedVars.areWeekliesCollapsed)
  end

  ET.RefreshEndeavorHeaders()
  ET.RefreshEndeavorList()
  ET.RefreshEndeavorPositions()
  ET.UpdateTotalEndeavors()
  ET.RestorePanelPosition()
end

function ET.OnEndeavorReset(event)
  EVENT_MANAGER:RegisterForUpdate("ET_LoadNewEndeavors", 1000, ET.LoadNewEndeavors)
end

function ET.LoadNewEndeavors()
  local numActivities = GetNumTimedActivities()
  if numActivities > 0 then
    ET.RefreshAll()
    EVENT_MANAGER:UnregisterForUpdate("ET_LoadNewEndeavors")
    CHAT_SYSTEM:AddMessage(string.format("|c33A532Endeavor Tracker:|r %s", GetString(ENDEAVOR_TRACKER_ChatMsgNewEndeavorsAvailable)))
  end
end

----------------------------------
-- INIT ENDEAVOR LISTS --
----------------------------------

function ET.CreateEndeavorEntry(index)
  local controlName = string.format("ET_Endeavor_Index_%i", index)
  local control = WM:CreateControlFromVirtual(controlName, ET_Panel, "ET_EndeavorTemplate")

  local listEntryCheckbox = WM:GetControlByName(string.format("ET_Endeavor_Index_%i_Checkbox", index))
  listEntryCheckbox:SetId(index)
end

function ET.InitEndeavorList()
  -- Create an empty control to anchor the first Endeavor label to
  local emptyControl = WM:CreateControl("ET_DailyActivities_Empty", ET_DailyActivities)
  emptyControl:SetAnchor(TOPLEFT, ET_DailyActivities, TOPLEFT, 0, 5)

  local emptyControl = WM:CreateControl("ET_WeeklyActivities_Empty", ET_WeeklyActivities)
  emptyControl:SetAnchor(TOPLEFT, ET_WeeklyActivities, TOPLEFT, 0, 5)

  local numActivities = GetNumTimedActivities() or 8
  for index = 1, numActivities do
    ET.CreateEndeavorEntry(index)
  end
end

function ET.InitToolTips()
  ET.SetToolTip(ET_ShortcutButton, RIGHT, "Endeavor Tracker")
  ET.SetToolTip(ET_PanelRefresh, TOP, GetString(ENDEAVOR_TRACKER_TooltipRefresh))
  ET.SetToolTip(ET_PanelHistoryButton, TOP, GetString(ENDEAVOR_TRACKER_TooltipHistoryButton))
  ET.SetToolTip(ET_PanelEndeavorTotal, TOP, GetString(ENDEAVOR_TRACKER_TooltipEndeavorTotal))
  ET.SetToolTip(ET_Panel_DailyExpandButton, TOP, GetString(ENDEAVOR_TRACKER_TooltipDailyExpandButton))
  ET.SetToolTip(ET_Panel_DailyCollapseButton, TOP, GetString(ENDEAVOR_TRACKER_TooltipDailyCollapseButton))
  ET.SetToolTip(ET_Panel_WeeklyExpandButton, TOP, GetString(ENDEAVOR_TRACKER_TooltipWeeklyExpandButton))
  ET.SetToolTip(ET_Panel_WeeklyCollapseButton, TOP, GetString(ENDEAVOR_TRACKER_TooltipWeeklyCollapseButton))

  ET.SetToolTip(ET_HistoryCloseButton, TOP, GetString(SI_DIALOG_CLOSE))
  ET.SetToolTip(ET_HistoryEndeavorTotal, TOP, GetString(ENDEAVOR_TRACKER_TooltipEndeavorTotal))
end

function ET.InitHandlers()
  ET_ShortcutBG:SetHandler("OnMouseEnter", function() WM:SetMouseCursor(MOUSE_CURSOR_PAN) end)
  ET_ShortcutBG:SetHandler("OnMouseExit", function() WM:SetMouseCursor(MOUSE_CURSOR_DO_NOT_CARE) end)
  ET_ShortcutBG:SetHandler("OnMoveStop", function() ET.ButtonOnMoveStop() end)
  ET_ShortcutButton:SetHandler("OnMouseDown", function(self) self:SetDimensions(40, 40) end)
  ET_ShortcutButton:SetHandler("OnMouseUp", function(self) self:SetDimensions(45, 45) end)
  ET_ShortcutButton:SetHandler("OnClicked", function() ET.TogglePanel() end)
  ET_Panel:SetHandler("OnMoveStop", function() ET.PanelOnMoveStop() end)
  ET_PanelRefresh:SetHandler("OnMouseDown", function(self) self:SetDimensions(20, 20) end)
  ET_PanelRefresh:SetHandler("OnMouseUp", function(self) self:SetDimensions(22, 22) end)
  ET_PanelRefresh:SetHandler("OnClicked", function() ET.RefreshAll() CHAT_SYSTEM:AddMessage(string.format("|c33A532Endeavor Tracker:|r %s", GetString(ENDEAVOR_TRACKER_ChatMsgListRefreshed))) end)
  ET_PanelHistoryButton:SetHandler("OnMouseDown", function(self) self:SetDimensions(20, 20) end)
  ET_PanelHistoryButton:SetHandler("OnMouseUp", function(self) self:SetDimensions(22, 22) end)
  ET_PanelHistoryButton:SetHandler("OnClicked", function() ET_History:ToggleHidden() end)
  ET_PanelEndeavorTotal:SetHandler("OnClicked", function(self) ZO_ShowSealStore() end)
  ET_Panel_DailyExpandButton:SetHandler("OnClicked", function() ET.ToggleDailies(false) end)
  ET_Panel_DailyCollapseButton:SetHandler("OnClicked", function() ET.ToggleDailies(true) end)
  ET_Panel_WeeklyExpandButton:SetHandler("OnClicked", function() ET.ToggleWeeklies(false) end)
  ET_Panel_WeeklyCollapseButton:SetHandler("OnClicked", function() ET.ToggleWeeklies(true) end)

  ET_HistoryEndeavorTotal:SetHandler("OnClicked", function(self) ZO_ShowSealStore() end)
  ET_HistoryCloseButton:SetHandler("OnClicked", function() ET_History:ToggleHidden() end)
end

function ET.InitUserSettings()
  ET.DisplayPanelBySetting(ET.SavedVars.displayPanelSetting)
  ET_ShortcutBG:SetHidden(not ET.SavedVars.isShortcutButtonVisible)
  ET_ShortcutButton:SetHidden(not ET.SavedVars.isShortcutButtonVisible)
  ET_Panel_DailyExpandButton:SetHidden(not ET.SavedVars.areDailiesCollapsed)
  ET_Panel_DailyCollapseButton:SetHidden(ET.SavedVars.areDailiesCollapsed)
  ET_Panel_WeeklyExpandButton:SetHidden(not ET.SavedVars.areWeekliesCollapsed)
  ET_Panel_WeeklyCollapseButton:SetHidden(ET.SavedVars.areWeekliesCollapsed)
  ET_PanelBG:SetHidden(not ET.SavedVars.isBackdropVisible)
  ET_PanelBG:SetAlpha(ET.SavedVars.backdropAlpha)
  ET.ToggleCheckboxes(ET.SavedVars.displayCheckboxes)
  ET.SetCustomFontSize(ET.SavedVars.fontSize)
end
-----------------------------------
-- ON ADDON LOADED --
-----------------------------------

local isAddonInitialized = false

function ET.OnPlayerActivated(event, addonName)
  -- EVENT_MANAGER:UnregisterForEvent(ET.name, EVENT_PLAYER_ACTIVATED)

  if isAddonInitialized == false then
    ET.InitEndeavorList()
    ET.InitToolTips()
    ET.InitHandlers()
    ET.InitUserSettings()

    ET.RefreshAll()

    EVENT_MANAGER:RegisterForEvent(ET.name, EVENT_TIMED_ACTIVITY_SYSTEM_STATUS_UPDATED, ET.OnEndeavorReset)
    EVENT_MANAGER:RegisterForEvent(ET.name, EVENT_TIMED_ACTIVITY_PROGRESS_UPDATED, ET.OnEndeavorProgressUpdated)
    EVENT_MANAGER:RegisterForEvent(ET.name, EVENT_TIMED_ACTIVITIES_UPDATED, ET.RefreshAll)

    -- Update the time remaining for daily/weekly endeavors each minute
    EVENT_MANAGER:RegisterForUpdate("ET_RefreshCountdown", 60000, ET.RefreshEndeavorHeaders)

    if ET.SavedVars.History.LifetimeSealsInitialized == false then
      ET.SavedVars.History.TotalLifetimeSeals = GetCurrencyAmount(CURT_ENDEAVOR_SEALS, CURRENCY_LOCATION_ACCOUNT)
      ET.SavedVars.History.LifetimeSealsInitialized = true
      ET.SavedVars.History.LifetimeSealsInitDate = GetDate()
    end

    ET.InitHistory()

    isAddonInitialized = true
  end

  ET.OnZoneChanged()
end

function ET.OnCurrencyUpdate(event, currencyType, currencyLocation, newAmount, oldAmount, reason)
  -- CURRENCY_CHANGE_REASON_REWARD = 27
  -- CURRENCY_CHANGE_REASON_PURCHASED_WITH_ENDEAVOR_SEALS = 79
  -- CURT_ENDEAVOR_SEALS = 11
  if currencyType == CURT_ENDEAVOR_SEALS then
    ET.UpdateTotalEndeavors()
  end
end

function ET.OnCombatStateChanged(event)
  ET.DisplayPanelBySetting(ET.SavedVars.displayPanelSetting)
end

function ET.OnZoneChanged()
  ET.DisplayPanelBySetting(ET.SavedVars.displayPanelSetting)
end

function ET.OnAddOnLoaded(event, addonName)
  if addonName == ET.name then
    EVENT_MANAGER:UnregisterForEvent(ET.name, EVENT_ADD_ON_LOADED)
    ET.SavedVars = ZO_SavedVars:NewAccountWide("EndeavorTrackerSVs", 1, nil, ET.Defaults, GetWorldName())

    SLASH_COMMANDS["/et"] = ET.TogglePanel
    SLASH_COMMANDS["/etreset"] = ET.ResetPositions
    SLASH_COMMANDS["/ethistory"] = function() ET_History:ToggleHidden() end

    ET.RestoreButtonPosition()
    ET.RestorePanelPosition()
    ET.CreateSettingsMenu()

    local fragment = ZO_SimpleSceneFragment:New(ET_Panel, nil, 0)
    HUD_SCENE:AddFragment(fragment)
    HUD_UI_SCENE:AddFragment(fragment)

    SCENE_MANAGER:RegisterCallback("SceneStateChanged", function(oldState, newState) if isETPanelHidden == true then ET_Panel:SetHidden(true) end end)

    EVENT_MANAGER:RegisterForEvent(ET.name, EVENT_PLAYER_ACTIVATED, ET.OnPlayerActivated)
    EVENT_MANAGER:RegisterForEvent(ET.name, EVENT_PLAYER_COMBAT_STATE, ET.OnCombatStateChanged)
    EVENT_MANAGER:RegisterForEvent(ET.name, EVENT_CURRENCY_UPDATE, ET.OnCurrencyUpdate)
  end
end

EVENT_MANAGER:RegisterForEvent(ET.name, EVENT_ADD_ON_LOADED, ET.OnAddOnLoaded)
