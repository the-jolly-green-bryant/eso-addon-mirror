TomesTracker = {}

local TT = TomesTracker
local EM = EVENT_MANAGER
local WM = WINDOW_MANAGER

ZO_CreateStringId("SI_BINDING_NAME_TOMES_TRACKER_TOGGLE", "Toggle Tomes Tracker")

TT.name = "TomesTracker"

TT.SV = {}
TT.areWeeklyCollapsed = false
TT.areSeasonalCollapsed = false

TT.pendingProgressUpdates = {}

TT.Defaults = {
  panelLeft = nil,
  panelTop = nil,
  isHidden = true,
  chatUpdates = true,
  HideCompleted = false,
  panelOpacity = 0.8,
  uiScale = 1.0,
  hideInCombat = false,
  hideRerollsZero = false,
}

function TT.RefreshPanel()
    local newScale = TT.SV.uiScale or 1.0
    
    if TT.SV.panelLeft ~= nil and TT.SV.panelTop ~= nil then
        TT_Panel:ClearAnchors()
        TT_Panel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, TT.SV.panelLeft * newScale, TT.SV.panelTop * newScale)
    else
        local oldScale = TT_Panel:GetScale()
        local left = TT_Panel:GetLeft() / oldScale
        local top = TT_Panel:GetTop() / oldScale
        TT.SV.panelLeft = left
        TT.SV.panelTop = top
    end
    
    TT_Panel:SetScale(newScale)

    local bg = TT_PanelBG
    if bg then
        local opacity = TT.SV.panelOpacity or 0.8
        bg:SetAlpha(opacity)
    end   
end

function TT.TogglePanel()
  TT_Panel:ToggleHidden()
  TT.SV.isHidden = TT_Panel:IsHidden()
  return TT.SV.isHidden
end

function TT.IsTaskCompleted(index)
    local claimed = GetTimedActivityNumTimesClaimed(index)
    local claimable = GetTimedActivityTotalNumTimesClaimable(index)
    return claimed >= claimable
end

function TT_Toggle_Panel()
  TT.TogglePanel()
end

function TT.ToggleSection(sectionType, setting)
    if sectionType == "weekly" then
        TT.areWeeklyCollapsed = setting
        TT_PanelWeeklySectionCollapseButton:SetHidden(setting)
        TT_PanelWeeklySectionExpandButton:SetHidden(not setting)
    elseif sectionType == "seasonal" then
        TT.areSeasonalCollapsed = setting
        TT_PanelSeasonalSectionCollapseButton:SetHidden(setting)
        TT_PanelSeasonalSectionExpandButton:SetHidden(not setting)
    end
    TT.RefreshTasksPositions()
end

function TT.OnCombatStateChanged(event, inCombat)   
    if inCombat then
        TT_Panel:SetHidden(true)
    else
        TT_Panel:SetHidden(TT.SV.isHidden)
    end
end

function TT.GetTimeRemainingForTaskType(activityType)
  local currentTime = GetTimeStamp()
  
  if activityType == TIMED_ACTIVITY_TYPE_WEEKLY then
    local resetTimeS = GetTimedActivityTypeResetTimeS(activityType)
    if resetTimeS then
      local timeRemaining = resetTimeS - currentTime
      return math.max(0, timeRemaining)
    end
  end
  
  if activityType == TIMED_ACTIVITY_TYPE_SEASONAL then
    local numActivities = GetNumTimedActivities()
    for index = 1, numActivities do
      if GetTimedActivityType(index) == activityType then
        local endTimeS = GetTimedActivityEndTimeS(index)
        if endTimeS then
          local timeRemaining = endTimeS - currentTime
          return math.max(0, timeRemaining)
        end
      end
    end
  end
  
  return 0
end

function TT.IsTaskTypeCompleted(activityType)
  local numActivities = GetNumTimedActivities()
  local allClaimed = true
  for index = 1, numActivities do
    if GetTimedActivityType(index) == activityType then
      local claimed = GetTimedActivityNumTimesClaimed(index)
      local claimable = GetTimedActivityTotalNumTimesClaimable(index)
      if claimed < claimable then
        allClaimed = false
        break
      end
    end
  end
  return allClaimed
end

function TT.GetTaskRewardsAsText(index)
  local rewardText = ""
  
  local currencyType, quantity = GetTimedActivityCurrencyRewardInfo(index)
  if currencyType and quantity then
    local currencyIcon = GetCurrencyLootKeyboardIcon(currencyType)
    rewardText = string.format("%s|cFFFFFF+%i|r |t20:20:%s|t ", rewardText, quantity, currencyIcon)
  end
  
  for rewardIndex = 1, GetNumTimedActivityRewards(index) do
    local rewardId, qty = GetTimedActivityRewardInfo(index, rewardIndex)
    local rewardType = GetRewardType(rewardId)
    if rewardType == REWARD_ENTRY_TYPE_EXPERIENCE then
      rewardText = string.format("%s|cFFFFFF+%i XP|r ", rewardText, qty)
    end
  end
  
  return rewardText
end

function TT.ClaimAllAvailableRewards()
  if HasAnyUnclaimedTimedActivityRewards() then
    ClaimAllTimedActivityRewards()
  end
end

local COLORS = {
  green = { r = 0.5, g = 0.5, b = 0.5, a = 1 },
  orange = { r = 0.9, g = 0.7, b = 0.08, a = 1 },
  orangeHex = "E5B214",
  red = { r = 0.8, g = 0.2, b = 0.2, a = 1 },
  white = { r = 1, g = 1, b = 1, a = 1 },
}

function TT.UpdateProgressBar()
    local container = TT_PanelProgressContainer
    if not container then return end

    local fill = container:GetNamedChild("Fill")
    local label = container:GetNamedChild("Text")
    if not fill or not label then return end

    fill:SetColor(0, 1, 0, 1)

    local pageLabel = TT_PanelPageLabel
    local containerWidth = container:GetWidth()  -- Moved here once

    local tomeId = TAMRIEL_TOMES_MANAGER:GetActiveTomeId()
    if not tomeId or tomeId == 0 then
        fill:SetWidth(0)
        label:SetText("")
        if pageLabel then pageLabel:SetText("") end
        return
    end

    local tomeData = ZO_TamrielTomeData:New(tomeId)
    if not tomeData then
        fill:SetWidth(0)
        label:SetText("")
        if pageLabel then pageLabel:SetText("") end
        return
    end

    local currentTier = tomeData:GetCurrentTier() or 0
    local numTiers = tomeData:GetNumTotalTiers() or 0

    if currentTier >= numTiers then
        fill:SetWidth(containerWidth - 4)
        label:SetText("")
        if pageLabel then pageLabel:SetText("|t20:20:TomesTracker/Textures/success.dds|t") end
        return
    end

    local nextTier = currentTier + 1
    local remainingPoints = tomeData:GetCostToProgressToTier(nextTier) or 0
    local PAGE_COST = 2000
    local percent = ((PAGE_COST - remainingPoints) / PAGE_COST) * 100

    local fillMaxWidth = containerWidth - 4 
    local fillWidth = math.floor((math.min(percent, 100) / 100) * fillMaxWidth)
    fill:SetWidth(fillWidth)

    label:SetText("+" .. tostring(remainingPoints))

    if pageLabel then
        local nextPage = math.min(currentTier + 1, 12)
        pageLabel:SetText(tostring(nextPage) .. " |t20:20:/esoui/art/miscellaneous/gamepad/gp_icon_locked32.dds|t")
    end
end

function TT.UpdateTaskEntry(index)
  local listEntryName = WM:GetControlByName(string.format("TT_Task_Index_%i_Name", index))
  local listEntryProgress = WM:GetControlByName(string.format("TT_Task_Index_%i_Progress", index))
  local listEntryRerollButton = WM:GetControlByName(string.format("TT_Task_Index_%i_RerollButton", index))
  
  if not listEntryName then
    TT.CreateTaskEntry(index)
    listEntryName = WM:GetControlByName(string.format("TT_Task_Index_%i_Name", index))
    listEntryProgress = WM:GetControlByName(string.format("TT_Task_Index_%i_Progress", index))
    listEntryRerollButton = WM:GetControlByName(string.format("TT_Task_Index_%i_RerollButton", index))
    
    if not listEntryName then
      return
    end
  end

  local description = GetTimedActivityDescription(index)
  local rewardText = TT.GetTaskRewardsAsText(index)
  
  local progress = GetTimedActivityProgress(index)
  local maxProgress = GetTimedActivityMaxProgress(index)
  local isFullyClaimed = TT.IsTaskCompleted(index)
    
  local taskName = GetTimedActivityName(index)
  
  local shouldColorProgressOrange = (progress > 0) and not isFullyClaimed
  
  local taskProgressText = ""
  if not isFullyClaimed and maxProgress > 1 then
    if shouldColorProgressOrange then
      taskProgressText = string.format(" (|c%s%d|r/%d)", COLORS.orangeHex, progress, maxProgress)
    else
      taskProgressText = string.format(" (%d/%d)", progress, maxProgress)
    end
  elseif maxProgress <= 1 and not isFullyClaimed then
    taskProgressText = ""
  end
  
  local inlineRewardText = ""
  if not isFullyClaimed then
    local currencyType, quantity = GetTimedActivityCurrencyRewardInfo(index)
    if currencyType and quantity then
      local currencyIcon = GetCurrencyLootKeyboardIcon(CURT_TOME_POINTS)
      inlineRewardText = string.format(" |cFFFFFF+%i|r |t16:16:%s|t", quantity, currencyIcon)
    end
  end
  
  local listEntryText = string.format("%s%s%s", taskName, taskProgressText, inlineRewardText)
  local tooltipText = string.format("%s\n\n%s", description, rewardText)

  listEntryName:SetText(listEntryText)

  if TT_Panel:GetLeft() < 400 then
    listEntryName:SetHandler("OnMouseEnter", function(self) 
        InitializeTooltip(InformationTooltip, listEntryProgress, LEFT, 10, 0, RIGHT)
        SetTooltipText(InformationTooltip, tooltipText) 
    end)
  else
    listEntryName:SetHandler("OnMouseEnter", function(self) 
        InitializeTooltip(InformationTooltip, listEntryRerollButton, RIGHT, -10, 0, LEFT)
        SetTooltipText(InformationTooltip, tooltipText) 
    end)
  end
  listEntryName:SetHandler("OnMouseExit", function(self) ClearTooltip(InformationTooltip) end)
end

function TT.UpdateTaskProgress(index)
  local listEntryName = WM:GetControlByName(string.format("TT_Task_Index_%i_Name", index))
  local listEntryProgress = WM:GetControlByName(string.format("TT_Task_Index_%i_Progress", index))

	local progress = GetTimedActivityProgress(index)
	local maxProgress = GetTimedActivityMaxProgress(index)
	local claimed = GetTimedActivityNumTimesClaimed(index)
	local claimable = GetTimedActivityTotalNumTimesClaimable(index)

	local progressText = string.format("%i/%i", claimed, claimable)

  if TT.IsTaskCompleted(index) then
    listEntryName:SetColor(COLORS.green.r, COLORS.green.g, COLORS.green.b, COLORS.green.a)
    listEntryProgress:SetColor(COLORS.green.r, COLORS.green.g, COLORS.green.b, COLORS.green.a)
    progressText = "|t20:20:TomesTracker/Textures/success.dds|t"
  elseif (progress > 0 or claimed > 0) and claimed < claimable then
    listEntryName:SetColor(COLORS.white.r, COLORS.white.g, COLORS.white.b, COLORS.white.a)
    listEntryProgress:SetColor(COLORS.orange.r, COLORS.orange.g, COLORS.orange.b, COLORS.orange.a)
  else
    listEntryName:SetColor(COLORS.white.r, COLORS.white.g, COLORS.white.b, COLORS.white.a)
    listEntryProgress:SetColor(COLORS.white.r, COLORS.white.g, COLORS.white.b, COLORS.white.a)
  end

  listEntryProgress:SetText(progressText)
	if listEntryProgress:WasTruncated() then
		listEntryProgress:SetHandler("OnMouseEnter", function(self) 
			ZO_Tooltips_ShowTextTooltip(self, RIGHT, progressText) 
		end)
		listEntryProgress:SetHandler("OnMouseExit", function(self) 
			ZO_Tooltips_HideTextTooltip() 
		end)
	end
end

function TT.UpdateCurrency()
    local totalTomePoints = GetCurrencyAmount(CURT_TOME_POINTS, CURRENCY_LOCATION_ACCOUNT)
    local texture = "|t20:20:/esoui/art/currency/u49_tt_tomepoints_mipmap.dds|t"
    local formattedPoints = tonumber(totalTomePoints) and string.format("%d", totalTomePoints):reverse():gsub("(%d%d%d)", "%1,"):gsub(",(%-?)$", "%1"):reverse() or "0"
    TT_PanelPointsTotal:SetText(string.format("%s %s", formattedPoints, texture))
    
    local rerollAmount = GetCurrencyAmount(CURT_TOME_CHALLENGE_REROLLS, CURRENCY_LOCATION_ACCOUNT)
    local rerollCount = rerollAmount or 0
    local rerollTexture = "|t28:28:/esoui/art/currency/u49_tt_reroll_mipmaps.dds|t"
    TT_PanelRerollCount:SetText(string.format("%s %d", rerollTexture, rerollCount))
    
    if TT.SV.hideRerollsZero then
        TT_PanelRerollCount:SetAlpha(rerollCount == 0 and 0.0 or 1.0)
    else
        TT_PanelRerollCount:SetAlpha(1.0)
    end
end

function TT.UpdateTaskEntryAnchors(index)
    local controlName = string.format("TT_Task_Index_%i", index)
    local activityType = GetTimedActivityType(index)

    local rerollButton = WM:GetControlByName(controlName .. "_RerollButton")
    local nameLabel = WM:GetControlByName(controlName .. "_Name")
    local progressLabel = WM:GetControlByName(controlName .. "_Progress")

    local claimed = GetTimedActivityNumTimesClaimed(index)

    if activityType == TIMED_ACTIVITY_TYPE_WEEKLY then
        rerollButton:SetHidden(false)
        if claimed > 0 then
            rerollButton:SetMouseEnabled(false)
            rerollButton:SetAlpha(0.4)
            rerollButton:SetHandler("OnClicked", nil)
        else
            rerollButton:SetMouseEnabled(true)
            rerollButton:SetAlpha(1)
            rerollButton:SetHandler("OnClicked", function()
                TT.RerollTask(index)
            end)
        end

        nameLabel:ClearAnchors()
        nameLabel:SetAnchor(TOPLEFT, rerollButton, TOPRIGHT, 5, 0)
    else
        rerollButton:SetHidden(true)
        nameLabel:ClearAnchors()
        nameLabel:SetAnchor(TOPLEFT, nameLabel:GetParent(), TOPLEFT, 5, 0)
    end

    progressLabel:ClearAnchors()
    progressLabel:SetAnchor(TOPLEFT, nameLabel, TOPRIGHT, 5, 0)
end

function TT.RegisterRerollDialog()
    ZO_CreateStringId("TT_REROLL_DIALOG_HEADER", "Reroll Tome Challenge")

    ESO_Dialogs["TT_REROLL_CONFIRMATION_DIALOG"] = {
        gamepadInfo = {
            dialogType = GAMEPAD_DIALOGS.BASIC,
        },
        title = {
            text = TT_REROLL_DIALOG_HEADER,
        },
        mainText = {
            text = function(dialog)
                return dialog.data.mainText
            end,
        },
        mustChoose = true,
        buttons = {
            [1] = {
                text = SI_DIALOG_ACCEPT,
                callback = function(dialog)
                    dialog.data.callback()
                end,
            },
            [2] = {
                text = SI_DIALOG_CANCEL,
            },
        },
    }
end

function TT.RerollTask(index)
    local taskName = GetTimedActivityName(index)
    local taskDesc = GetTimedActivityDescription(index)
    local goldCost = GetGoldCostOfNextTimedActivityReroll()
    local rerollCount = GetCurrencyAmount(CURT_TOME_CHALLENGE_REROLLS, CURRENCY_LOCATION_ACCOUNT)

    local goldIcon = "|t24:24:/esoui/art/currency/currency_gold_64.dds|t"
    local rerollIcon = "|t28:28:/esoui/art/currency/u49_tt_reroll_mipmaps.dds|t"

    local mainText = string.format("Do you want to reroll the following challenge?\n\n|cFFFFFF%s|r\n\n|c888888%s|r", taskName, taskDesc)

    if rerollCount == 0 then
        mainText = mainText .. string.format("\n\nYou are out of %s. Reroll price: |cFFCC33%d|r%s", rerollIcon, goldCost, goldIcon)
    else
        mainText = mainText .. string.format("\n\nThis will consume 1 %s", rerollIcon)
    end

    local dialogParams = {
        callback = function()
            RerollTimedActivity(index)
            TT.RefreshTasks()
        end,
        mainText = mainText
    }

    ZO_Dialogs_ShowDialog("TT_REROLL_CONFIRMATION_DIALOG", dialogParams)
end


function TT.UpdateTasksHeader(activityType, controlHeader, controlProgress, iconPath)
  local numActivities = GetNumTimedActivities()
  local totalCompleted = 0
  local totalClaimable = 0
  local hasAnyProgressOrComplete = false
  local hasAnyClaimed = false
  
  for index = 1, numActivities do
    if GetTimedActivityType(index) == activityType then
      local claimed = GetTimedActivityNumTimesClaimed(index)
      local claimable = GetTimedActivityTotalNumTimesClaimable(index)
      local progress = GetTimedActivityProgress(index)
      local maxProgress = GetTimedActivityMaxProgress(index)
      
      totalCompleted = totalCompleted + claimed
      totalClaimable = totalClaimable + claimable
      
      if claimed > 0 then
        hasAnyClaimed = true
      end
      
      if progress > 0 or (progress >= maxProgress and claimed < claimable) then
        hasAnyProgressOrComplete = true
      end
    end
  end
  
  local progress = string.format("%i/%i", totalCompleted, totalClaimable)
  
  local timeRemainingS = TT.GetTimeRemainingForTaskType(activityType)
  local timeText = ""
  if timeRemainingS and timeRemainingS > 0 then
    timeText = ZO_FormatTime(timeRemainingS, TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_TWELVE_HOUR_NO_SECONDS, TIME_FORMAT_DIRECTION_DESCENDING)
  end
  
  local color
  if totalCompleted >= totalClaimable and totalClaimable > 0 then
    color = COLORS.green
  elseif hasAnyProgressOrComplete == true or hasAnyClaimed == true then
    color = COLORS.orange
  else
    color = COLORS.red
  end
  
  local icon = string.format("|t25:25:%s|t", iconPath)
  local coloredTime = string.format("|c%02x%02x%02x(%s)|r", 
    color.r * 255, color.g * 255, color.b * 255, timeText)
  
  local headerText = string.format("%s %s", icon, coloredTime)
  controlHeader:SetText(headerText)
  controlHeader:SetColor(color.r, color.g, color.b, color.a)
  
  controlProgress:SetText(progress)
  controlProgress:SetColor(color.r, color.g, color.b, color.a)
end

function TT.OnTaskProgressUpdated(event, index, previousProgress, currentProgress, complete)

    TT.ClaimAllAvailableRewards()
   
    local name = GetTimedActivityName(index)
    local claimed = GetTimedActivityNumTimesClaimed(index)
    local claimable = GetTimedActivityTotalNumTimesClaimable(index)
    local maxProgress = GetTimedActivityMaxProgress(index)

	local iconTomePoints = "|t20:20:esoui/art/currency/gamepad/gp_currency_tomepoints.dds|t "
	 
    if currentProgress >= maxProgress then
        local successTexture = "|t20:20:TomesTracker/Textures/success.dds|t"
        local suffix = string.format(" |cFFFFFF(|r|cFFFF00%d|r|cFFFFFF / %d)|r", claimed + 1, claimable)

        if TT.SV.chatUpdates then
            CHAT_SYSTEM:AddMessage(string.format("|cFFFFFF%s%s|r %s%s", iconTomePoints, name, successTexture, suffix))
        end

    elseif currentProgress > previousProgress then
        if TT.SV.chatUpdates then
            CHAT_SYSTEM:AddMessage(string.format("|cFFFFFF%s%s (|r|cFFFF00%d|r|cFFFFFF / %d)|r", iconTomePoints, name, currentProgress, maxProgress))
        end
    end
	
    TT.RefreshTasks()
end

function TT.RefreshTasksList()
  local numActivities = GetNumTimedActivities()
  
  local existingCount = 0
  for index = 1, numActivities do
    local controlName = string.format("TT_Task_Index_%i", index)
    local control = WM:GetControlByName(controlName)
    if control then
      existingCount = existingCount + 1
    else
      break
    end
  end
  
  if existingCount < numActivities then
    for index = existingCount + 1, numActivities do
      TT.CreateTaskEntry(index)
    end
  end

  for index = 1, numActivities do
    local control = WM:GetControlByName(string.format("TT_Task_Index_%i", index))
    if control then 
      TT.UpdateTaskEntry(index)
      TT.UpdateTaskProgress(index)
    end
  end
end

function TT.RefreshTasksPositions()
    local numActivities = GetNumTimedActivities()
    local lastWeeklyEntry = nil
    local lastSeasonalEntry = nil
    
    local parentWeekly = TT_WeeklyActivities
    local parentSeasonal = TT_SeasonalActivities

    for index = 1, numActivities do
        local controlName = string.format("TT_Task_Index_%i", index)
        local listEntry = WM:GetControlByName(controlName) or TT.CreateTaskEntry(index)
        
        if listEntry then
            local activityType = GetTimedActivityType(index)
            
            if TT.SV.HideCompleted and TT.IsTaskCompleted(index) then
                listEntry:SetHidden(true)
            elseif activityType == TIMED_ACTIVITY_TYPE_WEEKLY then
                if not TT.areWeeklyCollapsed then
                    listEntry:SetParent(parentWeekly)
                    listEntry:ClearAnchors()
                    if lastWeeklyEntry then
                        listEntry:SetAnchor(TOPLEFT, lastWeeklyEntry, BOTTOMLEFT, 0, 5)
                    else
                        listEntry:SetAnchor(TOPLEFT, parentWeekly, TOPLEFT, 0, 5)
                    end
                    listEntry:SetHidden(false)
                    TT.UpdateTaskEntryAnchors(index)
                    lastWeeklyEntry = listEntry
                else
                    listEntry:SetHidden(true)
                end
            elseif activityType == TIMED_ACTIVITY_TYPE_SEASONAL then
                if not TT.areSeasonalCollapsed then
                    listEntry:SetParent(parentSeasonal)
                    listEntry:ClearAnchors()
                    if lastSeasonalEntry then
                        listEntry:SetAnchor(TOPLEFT, lastSeasonalEntry, BOTTOMLEFT, 0, 5)
                    else
                        listEntry:SetAnchor(TOPLEFT, parentSeasonal, TOPLEFT, 0, 5)
                    end
                    listEntry:SetHidden(false)
                    TT.UpdateTaskEntryAnchors(index)
                    lastSeasonalEntry = listEntry
                else
                    listEntry:SetHidden(true)
                end
            end
        end
    end
end

function TT.RefreshTasksHeaders()
  TT.UpdateTasksHeader(TIMED_ACTIVITY_TYPE_WEEKLY, TT_PanelWeeklySectionHeader, TT_PanelWeeklySectionStatus, "/esoui/art/tamrieltomes/gamepad/gp_timedactivitycategory_weekly.dds")
  TT.UpdateTasksHeader(TIMED_ACTIVITY_TYPE_SEASONAL, TT_PanelSeasonalSectionHeader, TT_PanelSeasonalSectionStatus, "/esoui/art/tamrieltomes/gamepad/gp_timedactivitycategory_seasonal.dds")
end


function TT.RefreshTasks()
  TT.areWeeklyCollapsed = TT.IsTaskTypeCompleted(TIMED_ACTIVITY_TYPE_WEEKLY)
  TT_PanelWeeklySectionCollapseButton:SetHidden(TT.areWeeklyCollapsed)
  TT_PanelWeeklySectionExpandButton:SetHidden(not TT.areWeeklyCollapsed)

  TT.areSeasonalCollapsed = TT.IsTaskTypeCompleted(TIMED_ACTIVITY_TYPE_SEASONAL)
  TT_PanelSeasonalSectionCollapseButton:SetHidden(TT.areSeasonalCollapsed)
  TT_PanelSeasonalSectionExpandButton:SetHidden(not TT.areSeasonalCollapsed)
  
  TT.RefreshTasksHeaders()
  TT.RefreshTasksList()
  TT.RefreshTasksPositions()
  TT.UpdateCurrency()
  TT.UpdateProgressBar()
end

function TT.CreateTaskEntry(index)
    local controlName = string.format("TT_Task_Index_%i", index)
    local control = WM:CreateControlFromVirtual(controlName, TT_Panel, "TT_TaskTemplate")
    
    TT.UpdateTaskEntryAnchors(index)
end

function TT.CreateUI()
    local numActivities = GetNumTimedActivities()
    for index = 1, numActivities do
        TT.CreateTaskEntry(index)
    end

    local bg = TT_PanelBG
    if bg then
        bg:SetEdgeTexture("TomesTracker/Textures/centerscreen_floating_edge.dds", 256, 256, 30)
        bg:SetCenterTexture("TomesTracker/Textures/centerscreen_floating_center.dds")
        bg:SetInsets(30, 30, -30, -30)
        bg:SetIntegralWrapping(true)
        bg:SetCenterColor(0, 0, 0, 1)
        bg:SetEdgeColor(0, 0, 0, 1)
    end

    TT_Panel:SetHandler("OnMoveStop", function()
        local scale = TT_Panel:GetScale()
        TT.SV.panelLeft = TT_Panel:GetLeft() / scale
        TT.SV.panelTop = TT_Panel:GetTop() / scale
        TT.RefreshTasksList()
    end)

    TT_PanelWeeklySectionExpandButton:SetHandler("OnClicked", function() TT.ToggleSection("weekly", false) end)
    TT_PanelWeeklySectionCollapseButton:SetHandler("OnClicked", function() TT.ToggleSection("weekly", true) end)
    TT_PanelSeasonalSectionExpandButton:SetHandler("OnClicked", function() TT.ToggleSection("seasonal", false) end)
    TT_PanelSeasonalSectionCollapseButton:SetHandler("OnClicked", function() TT.ToggleSection("seasonal", true) end)
end

function TT.OnCurrencyUpdate(event, currencyType, currencyLocation, newAmount, oldAmount, reason)
    if currencyType == CURT_TOME_POINTS or currencyType == CURT_TOME_CHALLENGE_REROLLS then
        TT.UpdateCurrency()
    end
end

function TT.TweakTomesButton()
    local newSize = 64
    
    ZO_CATEGORY_LAYOUT_INFO[MENU_CATEGORY_TAMRIEL_TOMES].overrideNormalSize = newSize
    ZO_CATEGORY_LAYOUT_INFO[MENU_CATEGORY_TAMRIEL_TOMES].overrideDownSize = newSize
    
    local buttonObject = MAIN_MENU_KEYBOARD.categoryBar.m_object:ButtonObjectForDescriptor(MENU_CATEGORY_TAMRIEL_TOMES)
    buttonObject.m_buttonData.overrideNormalSize = newSize
    buttonObject.m_buttonData.overrideDownSize = newSize
    
    buttonObject.m_image:SetDimensions(newSize, newSize)
    buttonObject.m_highlight:SetDimensions(newSize, newSize)
    
    buttonObject:SetState(buttonObject:GetState(), true)
    MAIN_MENU_KEYBOARD.categoryBar.m_object:UpdateButtons(true)
end

function TT.EarlyProgressCacheHandler(event, index, previousProgress, currentProgress, complete)
    table.insert(TT.pendingProgressUpdates, {
        event = event,
        index = index,
        previousProgress = previousProgress,
        currentProgress = currentProgress,
        complete = complete
    })
end

function TT.Initialize()
    EM:UnregisterForEvent(TT.name, EVENT_PLAYER_ACTIVATED)
    
    TT.SV = ZO_SavedVars:NewAccountWide("TomesTracker_SV", 1, nil, TT.Defaults)
		
	TT.CreateUI()
	TT.RefreshPanel()
	  
	EM:RegisterForEvent(TT.name, EVENT_TIMED_ACTIVITY_PROGRESS_UPDATED, TT.OnTaskProgressUpdated)  
	   	   	   	      
    local fragment = ZO_SimpleSceneFragment:New(TT_Panel, nil, 0)
    HUD_SCENE:AddFragment(fragment)
    HUD_UI_SCENE:AddFragment(fragment)

    fragment:RegisterCallback("StateChange", function(oldState, newState)
        if newState == SCENE_FRAGMENT_SHOWN then
            if TT.SV.isHidden then
                TT_Panel:SetHidden(true)
            end
        end
    end)

    TT_Panel:SetHidden(TT.SV.isHidden)
    
    
    EM:RegisterForEvent(TT.name, EVENT_CURRENCY_UPDATE, TT.OnCurrencyUpdate)
    EM:RegisterForEvent(TT.name, EVENT_TIMED_ACTIVITIES_UPDATED, TT.RefreshTasks)
	EM:RegisterForUpdate(TT.name .. "RefreshCountdown", 60000, TT.RefreshTasksHeaders)

    if TT.SV.hideInCombat then
        EM:RegisterForEvent(TT.name, EVENT_PLAYER_COMBAT_STATE, TT.OnCombatStateChanged)
    end
    
    TT_Panel:SetHidden(TT.SV.isHidden)

    TAMRIEL_TOMES_MANAGER:RegisterCallback("SelectedTomeChanged", TT.UpdateProgressBar)
    TAMRIEL_TOMES_MANAGER:RegisterCallback("AvailableTomesChanged", TT.UpdateProgressBar)
	
    TT.RegisterLAMPanel()
    TT.RegisterRerollDialog()
	TT.TweakTomesButton()
	
	TT.RefreshTasks()
	
	SLASH_COMMANDS["/tt"] = TT.TogglePanel
	
    for _, cachedEvent in ipairs(TT.pendingProgressUpdates) do
        TT.OnTaskProgressUpdated(
            cachedEvent.event, 
            cachedEvent.index, 
            cachedEvent.previousProgress, 
            cachedEvent.currentProgress, 
            cachedEvent.complete
        )
    end
    
    EM:UnregisterForEvent(TT.name .. "_EarlyCache", EVENT_TIMED_ACTIVITY_PROGRESS_UPDATED)
    TT.pendingProgressUpdates = {}
end

function TT.OnAddOnLoaded(event, addonName)
  if addonName == TT.name then
    EM:UnregisterForEvent(TT.name, EVENT_ADD_ON_LOADED)
	
	EM:RegisterForEvent(TT.name .. "_EarlyCache", EVENT_TIMED_ACTIVITY_PROGRESS_UPDATED, TT.EarlyProgressCacheHandler)
	
    EM:RegisterForEvent(TT.name, EVENT_PLAYER_ACTIVATED, TT.Initialize)
  end
end

EM:RegisterForEvent(TT.name, EVENT_ADD_ON_LOADED, TT.OnAddOnLoaded)