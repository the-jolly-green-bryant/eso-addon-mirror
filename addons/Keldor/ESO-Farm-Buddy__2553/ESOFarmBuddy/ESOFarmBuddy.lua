--- ESO Farm-Buddy AddOn written by Keldor

----
--- Initialize global Variables
----
ESOFarmBuddy = {}

ESOFarmBuddy.DISPLAY_MODE_SESSION = 1
ESOFarmBuddy.DISPLAY_MODE_TOTAL = 2
ESOFarmBuddy.PROGRESS_DISPLAY_MODE_FULL = 1
ESOFarmBuddy.PROGRESS_DISPLAY_MODE_COUNT = 2
ESOFarmBuddy.PROGRESS_DISPLAY_MODE_PERCENT = 3
ESOFarmBuddy.SORT_BY_NAME = 1
ESOFarmBuddy.SORT_BY_COUNT = 2
ESOFarmBuddy.SORT_BY_GOAL = 3
ESOFarmBuddy.SORT_BY_PROGRESS = 4
ESOFarmBuddy.SORT_ASC = 1
ESOFarmBuddy.SORT_DESC = 2
ESOFarmBuddy.BONUS_DISPLAY_MODE_PERCENT = 1
ESOFarmBuddy.BONUS_DISPLAY_MODE_COUNT = 2
ESOFarmBuddy.PROGRESS_STYLE_MATERIAL = 1
ESOFarmBuddy.PROGRESS_STYLE_TEXTURE = 2

ESOFarmBuddy.Name = "ESOFarmBuddy"
ESOFarmBuddy.DisplayName = "ESO Farm-Buddy"
ESOFarmBuddy.AddonVersion = "1.0.36"
ESOFarmBuddy.AddonVersionInt = 1036
ESOFarmBuddy.SavedVariablesName = "ESOFarmBuddySV"
ESOFarmBuddy.LAMPanelName = "ESOFarmBuddySettingsPanel"
ESOFarmBuddy.DonationUrl = "https://www.patreon.com/c/eso_database_com"
ESOFarmBuddy.VariableVersion = 44
ESOFarmBuddy.Default = {
	FirstStart = true,
	ItemList = {},
	Settings = {
		DisplayMode = ESOFarmBuddy.DISPLAY_MODE_SESSION,
		ProgressDisplayMode = ESOFarmBuddy.PROGRESS_DISPLAY_MODE_FULL,
		ProgressStyle = ESOFarmBuddy.PROGRESS_STYLE_MATERIAL,
		HideWindow = false,
		ShowWindowInSettings = false,
		HideWindowInCombat = true,
		HideWindowInDungeonAndTrial = true,
		HideWindowInPvP = true,
		HideWindowInHomes = true,
		LockWindow = false,
		ClampedToScreen = true,
		ShowTitle = true,
		ShowItemName = true,
		ShowProgressBar = true,
		ShowGoalBonus = true,
		ShowGoalNotifications = true,
		PlayGoalNotificationSound = true,
		GoalNotificationSound = "Ability_MorphPurchased",
		IncludeBank = false,
		IncludeCraftBag = true,
		BackgroundAlpha = 30,
		SortBy = ESOFarmBuddy.SORT_BY_PROGRESS,
		SortDirection = ESOFarmBuddy.SORT_DESC,
		GoalBonusDisplayType = ESOFarmBuddy.BONUS_DISPLAY_MODE_PERCENT,
		WindowPosition = {
			offsetX = 0,
			offsetY = 0,
		},
		ProgressbarColors = {
			NotComleted = { r = 0, g = 0.5137255192, b = 1, a = 1 },
			Comleted = { r = 0.2509804070, g = 0.7254902124, b = 0, a = 1 },
		},
		ProgressTextColors = {
			NotComleted = { r = 1, g = 1, b = 1, a = 1 },
			Comleted = { r = 1, g = 1, b = 1, a = 1 },
		},
	},
}
ESOFarmBuddy.SV = nil
ESOFarmBuddy.OffsetYPerItem = 65
ESOFarmBuddy.SessionItemCounts = {}
ESOFarmBuddy.NotificationItemList = {}
ESOFarmBuddy.CtrlsItemList = {}
ESOFarmBuddy.LastAddedItemCtrl = nil
ESOFarmBuddy.Window = nil

----
--- Initialize local Variables
----
---
local settings
local fragment
local pool


----
--- Pool handling
----
function ESOFarmBuddy.AddScenes()
	SCENE_MANAGER:GetScene("hud"):AddFragment(fragment)
	SCENE_MANAGER:GetScene("hudui"):AddFragment(fragment)
	SCENE_MANAGER:GetScene("loot"):AddFragment(fragment)
end

function ESOFarmBuddy.RemoveScenes()
	SCENE_MANAGER:GetScene("hud"):RemoveFragment(fragment)
	SCENE_MANAGER:GetScene("hudui"):RemoveFragment(fragment)
	SCENE_MANAGER:GetScene("loot"):RemoveFragment(fragment)
end

function ESOFarmBuddy.Create(poolObj)
	return ZO_ObjectPool_CreateControl("ESOFarmBuddyItemTemplate", poolObj, ESOFarmBuddyWindowItemList)
end

function ESOFarmBuddy.OnMoveStop(self)
	settings.WindowPosition.offsetX = self:GetLeft()
	settings.WindowPosition.offsetY = self:GetTop()
end

function ESOFarmBuddy.ResetWindowPosition()
	ESOFarmBuddy.Window:ClearAnchors()
	ESOFarmBuddy.Window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 25, 45)
	ESOFarmBuddy.OnMoveStop(ESOFarmBuddy.Window)
end

function ESOFarmBuddy.Remove(control)
	control.itemId = nil
	control:SetHidden(true)
end


----
--- Toggle functions
----

function ESOFarmBuddy.ToggleAddOnTitle()
	ESOFarmBuddy.Window:GetNamedChild("AddOnName"):SetHidden(not settings.ShowTitle)
end

function ESOFarmBuddy.ToggleClampedToScreen()
	ESOFarmBuddy.Window:SetClampedToScreen(settings.ClampedToScreen)
end

function ESOFarmBuddy.ToggleHideWindowInCombat(state)

	settings.HideWindowInCombat = state

	EVENT_MANAGER:UnregisterForEvent(ESOFarmBuddy.Name, EVENT_PLAYER_COMBAT_STATE)

	if state == true then
		EVENT_MANAGER:RegisterForEvent(ESOFarmBuddy.Name, EVENT_PLAYER_COMBAT_STATE, ESOFarmBuddy.EventPlayerCombatState)
	end
end

function ESOFarmBuddy.ToggleHideWindow(inCombat)

	local hide = false
	local isInDungeon = IsUnitInDungeon("player")
	local isInAvAZone = IsInAvAZone("player")
	local isInBattleground = IsActiveWorldBattleground("player")
	local currentHouseId = GetCurrentZoneHouseId()

	if settings.HideWindow == true then
		hide = true

	elseif isInDungeon == true then
		if settings.HideWindowInDungeonAndTrial == true then
			hide = true
		end

	elseif (isInAvAZone == true or isInBattleground == true) then
		if settings.HideWindowInPvP == true then
			hide = true
		end

	elseif currentHouseId > 0 then
		if settings.HideWindowInHomes == true then
			hide = true
		end

	elseif inCombat == true then
		if settings.HideWindowInCombat == true then
			hide = true
		end
	end

	if hide == true then
		ESOFarmBuddy.RemoveScenes()
	else
		ESOFarmBuddy.AddScenes()
	end
end

function ESOFarmBuddy.ToggleShowWindowInSettings()

	if settings.ShowWindowInSettings == true then
		SCENE_MANAGER:GetScene("gameMenuInGame"):AddFragment(fragment)
	else
		SCENE_MANAGER:GetScene("gameMenuInGame"):RemoveFragment(fragment)
	end
end

function ESOFarmBuddy.ToggleWindowLock()

	ESOFarmBuddy.Window:SetMouseEnabled(not settings.LockWindow)

	local numChildren = ESOFarmBuddy.CtrlsItemList:GetNumChildren()
	if numChildren > 0 then
		for i = 1, numChildren do
			local ctrl = ESOFarmBuddy.CtrlsItemList:GetChild(i)
			ctrl:GetNamedChild("ActionButton"):SetHidden(not settings.LockWindow)
		end
	end
end


----
--- Getter
----

function ESOFarmBuddy.GetProgressText(count, goalCount)

	local format

	if goalCount > 0 then

		local percent = 0
		local goalBonus = 0
		local showGoal = false

		if settings.ProgressDisplayMode ~= ESOFarmBuddy.PROGRESS_DISPLAY_MODE_COUNT then
			percent = ESOFarmBuddyUtils:GetPercent(count, goalCount)

			if settings.ShowGoalBonus == true then
				if percent > 100 then

					if settings.GoalBonusDisplayType == ESOFarmBuddy.BONUS_DISPLAY_MODE_PERCENT then
						goalBonus = tostring(percent - 100) .. "%"
					else
						goalBonus = count - goalCount
					end

					showGoal = true
					percent = 100
				end
			end

		end

		if settings.ProgressDisplayMode == ESOFarmBuddy.PROGRESS_DISPLAY_MODE_COUNT then
			format = string.format("%i / %i", count, goalCount)
		elseif settings.ProgressDisplayMode == ESOFarmBuddy.PROGRESS_DISPLAY_MODE_PERCENT then

			if settings.ShowGoalBonus == true and showGoal == true then
				format = string.format("%s (+%s)", percent .. "%", goalBonus)
			else
				format = string.format("%s", percent .. "%")
			end
		else

			if settings.ShowGoalBonus == true and showGoal == true then
				format = string.format("%i / %i (%s) +%s", count, goalCount, percent .. "%", goalBonus)
			else
				format = string.format("%i / %i (%s)", count, goalCount, percent .. "%")
			end
		end
	else
		format = "x" .. count
	end

	return format
end

function ESOFarmBuddy.GetGoalCountForItemId(itemId)

	local count = 0

	if #ESOFarmBuddy.SV.ItemList > 0 then
		for _, itemTable in pairs(ESOFarmBuddy.SV.ItemList) do
			if itemTable.ItemID == itemId then
				count = itemTable.GoalCount
				break
			end
		end
	end

	return count
end

function ESOFarmBuddy.GetItemLinkFromItemId(itemId)

	local itemLink

	if #ESOFarmBuddy.SV.ItemList > 0 then
		for _, itemTable in pairs(ESOFarmBuddy.SV.ItemList) do
			if itemTable.ItemID == itemId then
				itemLink = itemTable.ItemLink
			end
		end
	end

	return itemLink
end


----
--- Setter
----

function ESOFarmBuddy.SetGoalCount(itemId, itemLink)

	local tableIndex = ESOFarmBuddyUtils:GetTableIndexByFieldValue(ESOFarmBuddy.SV.ItemList, "ItemID", itemId)
	local button = ESOFarmBuddyGoalSetter:GetNamedChild("SetButton")

	button.itemId = itemId
	button.itemLink = itemLink
	button:SetText(GetString(ESOFB_CONTEXT_MENU_SAVE))
	button:SetHandler("OnClicked", ESOFarmBuddy.SaveGoalCount)

	ESOFarmBuddyGoalSetter:GetNamedChild("Title"):SetText(GetString(ESOFB_CONTEXT_MENU_SET_GOAL))
	ESOFarmBuddyGoalSetter:GetNamedChild("EditBoxLabel"):SetText(GetString(ESOFB_SORT_BY_GOAL))
	ESOFarmBuddyGoalSetter:GetNamedChild("GoalCount"):SetText(ESOFarmBuddy.SV.ItemList[tableIndex].GoalCount)
	ESOFarmBuddyGoalSetter:SetHidden(false)
end

function ESOFarmBuddy.SetBackgroundOpacity()

	local r, g, b = ESOFarmBuddy.Window:GetNamedChild("BG"):GetCenterColor()
	local alpha = settings.BackgroundAlpha / 100

	ESOFarmBuddy.Window:GetNamedChild("BG"):SetCenterColor(r, g, b, alpha)
end


----
--- Other
----

function ESOFarmBuddy.RestoreWindowPosition()

	if ESOFarmBuddy.SV.FirstStart == true then
		ESOFarmBuddy.SV.FirstStart = false
		ESOFarmBuddy.OnMoveStop(ESOFarmBuddy.Window)
	else
		ESOFarmBuddy.Window:ClearAnchors()
		ESOFarmBuddy.Window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, settings.WindowPosition.offsetX, settings.WindowPosition.offsetY)
	end
end

function ESOFarmBuddy.AddSessionItem(itemId)
	table.insert(ESOFarmBuddy.SessionItemCounts, {
		ItemID = itemId,
		Count = 0
	})
end

function ESOFarmBuddy.SetupDisplayMode()

	for _, itemTable in pairs(ESOFarmBuddy.SV.ItemList) do
		ESOFarmBuddy.AddSessionItem(itemTable.ItemID)
	end
end

function ESOFarmBuddy.ResetItemList()

	ESOFarmBuddy.SV.ItemList = {}
	ESOFarmBuddy.SessionItemCounts = {}
	ESOFarmBuddy.RefreshItemList()
end

function ESOFarmBuddy.TrackItemFromLink(link)

	local itemId = GetItemLinkItemId(link)
	if ESOFarmBuddyUtils:GetTableIndexByFieldValue(ESOFarmBuddy.SV.ItemList, "ItemID", itemId) == false then
		table.insert(ESOFarmBuddy.SV.ItemList, {
			ItemLink = link,
			ItemName = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName(link)),
			ItemID = itemId,
			GoalCount = 0
		})

		ESOFarmBuddy.AddSessionItem(itemId)
		ESOFarmBuddy.RefreshItemList()

		ESOFarmBuddyUtils:ChatMsg(string.format(GetString(ESOFB_ADDED_MSG), link))
	else
		ESOFarmBuddyUtils:ChatMsg(string.format(GetString(ESOFB_ALREADY_ADDED_MSG), link))
	end
end

function ESOFarmBuddy.RemoveItemFromLink(link)

	local itemId = GetItemLinkItemId(link)
	if ESOFarmBuddyUtils:GetTableIndexByFieldValue(ESOFarmBuddy.SV.ItemList, "ItemID", itemId) ~= false then
		ESOFarmBuddyUtils:RemoveItemFromList(itemId)
		ESOFarmBuddyUtils:ChatMsg(string.format(GetString(ESOFB_REMOVED_MSG), link))
	else
		ESOFarmBuddyUtils:ChatMsg(string.format(GetString(ESOFB_NOT_IN_LIST_MSG), link))
	end
end

function ESOFarmBuddy.AddItemControl(itemLink)

	local itemId = GetItemLinkItemId(itemLink)
	local ctrl = pool:AcquireObject(itemId)

	ctrl.itemId = itemId
	ctrl:GetNamedChild("Icon"):SetTexture(GetItemLinkIcon(itemLink))
	ctrl:GetNamedChild("ProgressMaterial"):SetText("")
	ctrl:GetNamedChild("ProgressBarTextured"):GetNamedChild("Progress"):SetText("")

	ctrl:GetNamedChild("Name"):SetText("")
	ctrl:SetHidden(false)

	ESOFarmBuddy.UpdateItemControl(itemId, itemLink)

	ctrl:SetAnchor(TOPLEFT, ESOFarmBuddy.LastAddedItemCtrl, BOTTOMLEFT, 0, 0)
	ctrl:SetAnchor(TOPRIGHT, ESOFarmBuddy.LastAddedItemCtrl, BOTTOMRIGHT, 0, 0)

	ESOFarmBuddy.LastAddedItemCtrl = ctrl
end

function ESOFarmBuddy.UpdateItemControl(itemId, itemLink)

	local numChildren = ESOFarmBuddy.CtrlsItemList:GetNumChildren()
	if numChildren > 0 then
		for i = 1, numChildren do
			local ctrl = ESOFarmBuddy.CtrlsItemList:GetChild(i)
			if ctrl.itemId == itemId then

				-- Set window lock status
				ctrl:GetNamedChild("ActionButton"):SetHidden(not settings.LockWindow)

				local itemInfo = ESOFarmBuddyUtils:GetItemData(itemLink)
				local goalCount = ESOFarmBuddy.GetGoalCountForItemId(itemId)
				local count = 0

				if settings.DisplayMode == ESOFarmBuddy.DISPLAY_MODE_SESSION then
					local tableIndex = ESOFarmBuddyUtils:GetTableIndexByFieldValue(ESOFarmBuddy.SessionItemCounts, "ItemID", itemId)
					count = ESOFarmBuddy.SessionItemCounts[tableIndex].Count
				else
					count = itemInfo.DisplayCount
				end

				local progressColors = settings.ProgressTextColors.NotComleted
				local nameCtrl = ctrl:GetNamedChild("Name")
				local progressBarCtrl
				local progressTextCtrl = ctrl:GetNamedChild("ProgressText")
				local progressBarMaterialCtrl = ctrl:GetNamedChild("ProgressBarMaterial")
				local progressBarTexturedCtrl = ctrl:GetNamedChild("ProgressBarTextured")
				local progressCtrl

				if settings.ProgressStyle == ESOFarmBuddy.PROGRESS_STYLE_MATERIAL then
					progressBarCtrl = progressBarMaterialCtrl
					progressBarTexturedCtrl:SetHidden(true)
				else
					progressBarCtrl = progressBarTexturedCtrl
					progressBarMaterialCtrl:SetHidden(true)
				end

				---
				--- Get the correct progress control element
				---
				if settings.ProgressStyle == ESOFarmBuddy.PROGRESS_STYLE_MATERIAL then
					progressCtrl = ctrl:GetNamedChild("ProgressMaterial")
				else
					progressCtrl = progressBarCtrl:GetNamedChild("Progress")
				end

				progressCtrl:SetText(ESOFarmBuddy.GetProgressText(count, goalCount))
				progressTextCtrl:SetText(ESOFarmBuddy.GetProgressText(count, goalCount))

				---
				--- Add item to goal notification trigger list if the count is bigger then the goal
				---
				if count >= goalCount then
					if ESOFarmBuddyUtils:GetTableIndexByFieldValue(ESOFarmBuddy.NotificationItemList, "ItemId", itemId) == false then
						table.insert(ESOFarmBuddy.NotificationItemList, {
							ItemId = itemId
						})
					end
				end

				if goalCount > 0 and settings.ShowProgressBar == true then

					local barColors

					if count < goalCount then
						barColors = settings.ProgressbarColors.NotComleted
						progressColors = settings.ProgressTextColors.NotComleted
					else
						barColors = settings.ProgressbarColors.Comleted
						progressColors = settings.ProgressTextColors.Comleted
					end

					progressBarCtrl:SetMinMax(0, goalCount)
					progressBarCtrl:SetValue(count)
					progressBarCtrl:SetColor(barColors.r, barColors.g, barColors.b, barColors.a)
					progressBarCtrl:SetHidden(false)
					progressTextCtrl:SetHidden(true)
				else
					progressBarCtrl:SetHidden(true)
					progressTextCtrl:SetHidden(false)
				end

				progressCtrl:SetColor(progressColors.r, progressColors.g, progressColors.b, progressColors.a)

				if settings.ShowItemName == true then
					nameCtrl:SetHidden(false)
					nameCtrl:SetText(itemInfo.Name)
					nameCtrl:SetColor(itemInfo.QualityColors.r, itemInfo.QualityColors.g, itemInfo.QualityColors.b, itemInfo.QualityColors.a)
				else
					nameCtrl:SetHidden(true)
				end

				return
			end
		end
	end
end

function ESOFarmBuddy.SortItemList(a, b)

	local sort = false
	local dir = settings.SortDirection
	local tableIndexA = 0
	local tableIndexB = 0
	local itemInfoA = 0
	local itemInfoB = 0
	local countA = 0
	local countB = 0

	if settings.SortBy == ESOFarmBuddy.SORT_BY_COUNT or settings.SortBy == ESOFarmBuddy.SORT_BY_PROGRESS then
		tableIndexA = ESOFarmBuddyUtils:GetTableIndexByFieldValue(ESOFarmBuddy.SessionItemCounts, "ItemID", a.ItemID)
		tableIndexB = ESOFarmBuddyUtils:GetTableIndexByFieldValue(ESOFarmBuddy.SessionItemCounts, "ItemID", b.ItemID)
		itemInfoA = ESOFarmBuddyUtils:GetItemData(a.ItemLink)
		itemInfoB = ESOFarmBuddyUtils:GetItemData(b.ItemLink)
		countA = 0
		countB = 0

		if settings.DisplayMode == ESOFarmBuddy.DISPLAY_MODE_SESSION then
			countA = ESOFarmBuddy.SessionItemCounts[tableIndexA].Count
			countB = ESOFarmBuddy.SessionItemCounts[tableIndexB].Count
		else
			countA = itemInfoA.DisplayCount
			countB = itemInfoB.DisplayCount
		end
	end

	if settings.SortBy == ESOFarmBuddy.SORT_BY_NAME then

		if a.ItemName:lower() == b.ItemName:lower() then
			sort = false
		elseif dir == ESOFarmBuddy.SORT_ASC then
			sort = a.ItemName:lower() < b.ItemName:lower()
		else
			sort = a.ItemName:lower() > b.ItemName:lower()
		end

	elseif settings.SortBy == ESOFarmBuddy.SORT_BY_COUNT then

		if countA == countB then
			sort = a.ItemName:lower() < b.ItemName:lower()
		elseif dir == ESOFarmBuddy.SORT_ASC then
			sort = countA < countB
		else
			sort = countA > countB
		end

	elseif settings.SortBy == ESOFarmBuddy.SORT_BY_GOAL then
		if tonumber(a.GoalCount) == tonumber(b.GoalCount) then
			sort = a.ItemName:lower() < b.ItemName:lower()
		elseif dir == ESOFarmBuddy.SORT_ASC then
			sort = tonumber(a.GoalCount) < tonumber(b.GoalCount)
		else
			sort = tonumber(a.GoalCount) > tonumber(b.GoalCount)
		end

	elseif settings.SortBy == ESOFarmBuddy.SORT_BY_PROGRESS then

		local percentA = ESOFarmBuddyUtils:GetPercent(countA, a.GoalCount)
		local percentB = ESOFarmBuddyUtils:GetPercent(countB, b.GoalCount)

		if percentA == percentB then
			sort = a.ItemName:lower() < b.ItemName:lower()
		elseif dir == ESOFarmBuddy.SORT_ASC then
			sort = percentA < percentB
		else
			sort = percentA > percentB
		end
	end

	return sort
end

function ESOFarmBuddy.RefreshItemList()

	ESOFarmBuddyControlUtils:ClearItemList()

	local numItems = 0
	if #ESOFarmBuddy.SV.ItemList > 0 then

		table.sort(ESOFarmBuddy.SV.ItemList, ESOFarmBuddy.SortItemList)

		ESOFarmBuddy.Window:GetNamedChild("NoItemsInfo"):SetHidden(true)

		for _, itemTable in ipairs(ESOFarmBuddy.SV.ItemList) do

			if ESOFarmBuddyControlUtils:IsItemIdInCtrlList(itemTable.ItemID) == false then
				ESOFarmBuddy.AddItemControl(itemTable.ItemLink)
			else
				ESOFarmBuddy.UpdateItemControl(itemTable.ItemID, itemTable.ItemLink)
			end

			local ctrl = ESOFarmBuddyControlUtils:GetCtrlByItemId(itemTable.ItemID)
			if ctrl ~= nil then
				ctrl:SetAnchor(TOPLEFT, nil, BOTTOMLEFT, 0, (numItems * ESOFarmBuddy.OffsetYPerItem))
				ctrl:SetAnchor(TOPRIGHT, nil, BOTTOMRIGHT, 0, (numItems * ESOFarmBuddy.OffsetYPerItem))
			end

			numItems = numItems + 1
		end
	else
		local width = ESOFarmBuddy.Window:GetDimensions()
		ESOFarmBuddy.Window:SetDimensions(width, 60)
		ESOFarmBuddy.Window:GetNamedChild("NoItemsInfo"):SetHidden(false)
	end

	local minWidth, _, maxWidth = ESOFarmBuddy.Window:GetDimensionConstraints()
	local height = (numItems * ESOFarmBuddy.OffsetYPerItem)

	if numItems == 0 then
		height = ESOFarmBuddy.OffsetYPerItem
	end

	ESOFarmBuddy.Window:SetDimensionConstraints(minWidth, height, maxWidth, height)
end

function ESOFarmBuddy.RemoveItemIdFromNotificationList(itemId)
	local tableIndex = ESOFarmBuddyUtils:GetTableIndexByFieldValue(ESOFarmBuddy.NotificationItemList, "ItemId", itemId)
	if tableIndex ~= false then
		table.remove(ESOFarmBuddy.NotificationItemList, tableIndex)
	end
end

function ESOFarmBuddy.SaveGoalCount()

	local button = ESOFarmBuddyGoalSetter:GetNamedChild("SetButton")
	ESOFarmBuddy.SetGoalCountValue(button.itemLink, ESOFarmBuddyGoalSetter:GetNamedChild("GoalCount"):GetText())
end

function ESOFarmBuddy.SetGoalCountValue(itemLink, count)

	count = tonumber(count)
	if count < 0 then
		count = 0
	end

	local itemId = GetItemLinkItemId(itemLink)
	local tableIndexGoal = ESOFarmBuddyUtils:GetTableIndexByFieldValue(ESOFarmBuddy.SV.ItemList, "ItemID", itemId)
	ESOFarmBuddy.SV.ItemList[tableIndexGoal].GoalCount = tonumber(count)
	ESOFarmBuddy.UpdateItemControl(itemId, itemLink)
	ESOFarmBuddyGoalSetter:SetHidden(true)

	ESOFarmBuddy.RemoveItemIdFromNotificationList(itemId)

	ESOFarmBuddy.RefreshItemList()
end

function ESOFarmBuddy.ResetSessionForItem(itemId, itemLink)

	local tableIndex = ESOFarmBuddyUtils:GetTableIndexByFieldValue(ESOFarmBuddy.SessionItemCounts, "ItemID", itemId)
	ESOFarmBuddy.SessionItemCounts[tableIndex].Count = 0

	ESOFarmBuddy.UpdateItemControl(itemId, itemLink)
end

function ESOFarmBuddy.CheckGoalStatus(itemId, itemLink, sessionTableIndex, goalCount)

	local exists = ESOFarmBuddyUtils:GetTableIndexByFieldValue(ESOFarmBuddy.NotificationItemList, "ItemId", itemId)
	local count = 0

	if settings.DisplayMode == ESOFarmBuddy.DISPLAY_MODE_SESSION then
		count = ESOFarmBuddy.SessionItemCounts[sessionTableIndex].Count
	else
		local itemInfo = ESOFarmBuddyUtils:GetItemData(itemLink)
		count = itemInfo.DisplayCount
	end

	if exists == false and count >= goalCount then
		table.insert(ESOFarmBuddy.NotificationItemList, {
			ItemId = itemId
		})
		ESOFarmBuddyNotification:CenterScreenMessage(itemLink, goalCount, GetItemLinkIcon(itemLink))
	end
end

function ESOFarmBuddy.NotificationTest()

	local itemLink = "|H0:item:45854:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
	ESOFarmBuddyNotification:CenterScreenMessage(itemLink, 100, GetItemLinkIcon(itemLink))
end


---
--- Menus
---

function ESOFarmBuddy.InventoryContextMenuClick(inventorySlot)

	local bagId, slotIndex = ZO_Inventory_GetBagAndIndex(inventorySlot)
	local itemLink = GetItemLink(bagId, slotIndex, LINK_STYLE_DEFAULT)

	ESOFarmBuddy.TrackItemFromLink(itemLink)
end

function ESOFarmBuddy.InventoryContextMenu(inventorySlot, slotActions)

	local valid = ZO_Inventory_GetBagAndIndex(inventorySlot)
	if not valid then return end

	slotActions:AddCustomSlotAction(ESOFB_MENU_TRACK, function() ESOFarmBuddy.InventoryContextMenuClick(inventorySlot) end, "")
end

function ESOFarmBuddy.LinkContextMenu(link, button, _, _, linkType, ...)
	if button == MOUSE_BUTTON_INDEX_RIGHT and linkType == ITEM_LINK_TYPE then
		zo_callLater(
			function()
				AddCustomMenuItem(GetString(ESOFB_MENU_TRACK), function() ESOFarmBuddy.TrackItemFromLink(link) end, MENU_ADD_OPTION_LABEL)
				ShowMenu()
			end
		, 4)
	end
end

function ESOFarmBuddy.TradingHouseContextMenu(searchResultSlot, button)
	if button == MOUSE_BUTTON_INDEX_RIGHT then
		local inventorySlot = ZO_InventorySlot_GetInventorySlotComponents(searchResultSlot)
		local tradingHouseIndex = ZO_Inventory_GetSlotIndex(inventorySlot)
		if tradingHouseIndex ~= nil then
			local itemLink = GetTradingHouseSearchResultItemLink(tradingHouseIndex)
			AddCustomMenuItem(GetString(ESOFB_MENU_TRACK), function() ESOFarmBuddy.TrackItemFromLink(itemLink) end, MENU_ADD_OPTION_LABEL)
			ShowMenu()
		end
	end
end

function ESOFarmBuddy.OnItemRightClick(control, button, upInside)

	if button ~= MOUSE_BUTTON_INDEX_RIGHT or upInside == false then
		return
	end

	local itemId = control:GetParent().itemId
	local itemLink = ESOFarmBuddy.GetItemLinkFromItemId(itemId)

	ClearMenu()
	AddCustomMenuItem(GetString(ESOFB_CONTEXT_MENU_SET_GOAL), function() ESOFarmBuddy.SetGoalCount(itemId, itemLink) end)
	AddCustomMenuItem("-")
	if settings.DisplayMode == ESOFarmBuddy.DISPLAY_MODE_SESSION then
		AddCustomMenuItem(GetString(ESOFB_CONTEXT_MENU_RESET_COUNT), function() ESOFarmBuddy.ResetSessionForItem(itemId, itemLink) end)
	end
	AddCustomMenuItem(GetString(ESOFB_CONTEXT_MENU_REMOVE_ITEM), function() ESOFarmBuddyUtils:RemoveItemFromList(itemId) end)
	ShowMenu(control)
end

---
--- Events
---

function ESOFarmBuddy.EventPlayerActivated()
	ESOFarmBuddy.ToggleHideWindow(nil)
	ESOFarmBuddy.RefreshItemList()
end

function ESOFarmBuddy.EventPlayerCombatState(_, inCombat)
	ESOFarmBuddy.ToggleHideWindow(inCombat)
end

function ESOFarmBuddy.EventLootRecived(_, _, itemLink, quantity, _, _, self, _, _, itemId)

	if self == false then
		return
	end

	if ESOFarmBuddyUtils:IsItemIdInSVList(itemId) then

		-- Update session counts
		local tableIndex = ESOFarmBuddyUtils:GetTableIndexByFieldValue(ESOFarmBuddy.SessionItemCounts, "ItemID", itemId)
		local goalCount = ESOFarmBuddy.GetGoalCountForItemId(itemId)

		ESOFarmBuddy.SessionItemCounts[tableIndex].Count = ESOFarmBuddy.SessionItemCounts[tableIndex].Count + quantity

		if settings.ShowGoalNotifications == true and goalCount > 0 then
			ESOFarmBuddy.CheckGoalStatus(itemId, itemLink, tableIndex, goalCount)
		end

		ESOFarmBuddy.RefreshItemList()
	end
end


----
--- OnAddOnLoaded
----
function ESOFarmBuddy.OnAddOnLoaded(_, addonName)

	if addonName ~= ESOFarmBuddy.Name then return end

	EVENT_MANAGER:UnregisterForEvent(ESOFarmBuddy.Name, EVENT_ADD_ON_LOADED)

	ESOFarmBuddy.SV = ZO_SavedVars:NewCharacterIdSettings(ESOFarmBuddy.SavedVariablesName , ESOFarmBuddy.VariableVersion, nil, ESOFarmBuddy.Default)

	LibCustomMenu:RegisterContextMenu(ESOFarmBuddy.InventoryContextMenu, LibCustomMenu.CATEGORY_QUATERNARY)
	LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_MOUSE_UP_EVENT, ESOFarmBuddy.LinkContextMenu)
	SecurePostHook("ZO_TradingHouse_OnSearchResultClicked", ESOFarmBuddy.TradingHouseContextMenu)

	-- Save refernces to global vars
	settings = ESOFarmBuddy.SV.Settings
	pool = ZO_ObjectPool:New(ESOFarmBuddy.Create, ESOFarmBuddy.Remove)
	fragment = ZO_SimpleSceneFragment:New(ESOFarmBuddyWindow)
	ESOFarmBuddy.Window = ESOFarmBuddyWindow
	ESOFarmBuddy.CtrlsItemList = ESOFarmBuddy.Window:GetNamedChild("ItemList")

	-- Set window handlers
	ESOFarmBuddy.Window:SetHandler("OnMoveStop", ESOFarmBuddy.OnMoveStop)
	ESOFarmBuddy.Window:SetHandler("OnShow", ESOFarmBuddy.RefreshItemList)

	ESOFarmBuddy.AddScenes()
	ESOFarmBuddy.ToggleShowWindowInSettings()

	ESOFarmBuddy.Window:GetNamedChild("NoItemsInfo"):SetText(GetString(ESOFB_NO_ITEMS_TRACKED))

	ESOFarmBuddy.ToggleClampedToScreen()
	ESOFarmBuddy.SetupDisplayMode()
	ESOFarmBuddy.RestoreWindowPosition()
	ESOFarmBuddy.ToggleAddOnTitle()
	ESOFarmBuddy.SetBackgroundOpacity()
	ESOFarmBuddySettings.InitSettingsPanel(ESOFarmBuddy)

	----
	---  Register Events
	----
	EVENT_MANAGER:RegisterForEvent(ESOFarmBuddy.Name, EVENT_PLAYER_ACTIVATED, ESOFarmBuddy.EventPlayerActivated)
	EVENT_MANAGER:RegisterForEvent(ESOFarmBuddy.Name, EVENT_LOOT_RECEIVED, ESOFarmBuddy.EventLootRecived)

	if settings.HideWindowInCombat == true then
		EVENT_MANAGER:RegisterForEvent(ESOFarmBuddy.Name, EVENT_PLAYER_COMBAT_STATE, ESOFarmBuddy.EventPlayerCombatState)
	end
end

----
--- AddOn init
----
EVENT_MANAGER:RegisterForEvent(ESOFarmBuddy.Name, EVENT_ADD_ON_LOADED, ESOFarmBuddy.OnAddOnLoaded)
SLASH_COMMANDS["/efb"] = ESOFarmBuddyCommands.Handle
