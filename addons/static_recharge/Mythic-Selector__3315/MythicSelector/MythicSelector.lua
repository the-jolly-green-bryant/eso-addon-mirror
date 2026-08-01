--[[----------------------------------------------
Title: Mythic Selector
Author: Static_Recharge
Version: 1.1.0
Description: Allows for fast switching between Mythic jewelry and regular jewelry.
----------------------------------------------]]--


--[[----------------------------------------------
Addon Information
----------------------------------------------]]--
local MS = _G["MS"] -- Global access to table
MS.addonName = "MythicSelector"
MS.addonVersion = "1.1.0"
MS.author = "|CFF0000Static_Recharge|r"


--[[----------------------------------------------
Libraries and Aliases
----------------------------------------------]]--
local CS = CHAT_SYSTEM
local EM = EVENT_MANAGER
local WM = WINDOW_MANAGER
local LCM = LibCustomMenu
local SM = SCENE_MANAGER


--[[----------------------------------------------
Constant and Variable Declarations
----------------------------------------------]]--
MS.Const = {
	chatPrefix = "|cFF8C1A[Mythic Selector]:|r ",
	chatTextColor = "|cFFFFFF",
	chatSuffix = "|r",
}

MS.EquipSlots = {
	EQUIP_SLOT_BACKUP_MAIN,
	EQUIP_SLOT_BACKUP_OFF,
	EQUIP_SLOT_CHEST,
	EQUIP_SLOT_FEET,
	EQUIP_SLOT_HAND,
	EQUIP_SLOT_HEAD,
	EQUIP_SLOT_LEGS,
	EQUIP_SLOT_MAIN_HAND,
	EQUIP_SLOT_NECK,
	EQUIP_SLOT_OFF_HAND,
	EQUIP_SLOT_RING1,
	EQUIP_SLOT_RING2,
	EQUIP_SLOT_SHOULDERS,
	EQUIP_SLOT_WAIST
}

MS.SavedVars = {}
MS.varsVersion = 1

MS.AccountWideDefaults = {
	chatMessages = true,
  panelLeft = nil,
  panelTop = nil,
	indLeft = nil,
	indTop = nil,
	indicatorBGAlpha = 100,
	indicatorShowOnChange = false,
	indicatorFadeDelay = 2,
	CharacterList = {},
	CharacterIDList = {},
	fontSize = 13,
	width = 150,
	rightAlign = false,
}

MS.ProfileDefaults = {
	useAccountWide = false,
	characterName = nil,
	Necklaces = {},
	Rings = {},
	neckIndicator = true,
	ringIndicator = true,
}

MS.ListPool = {}
MS.indicatorHidden = false


--[[----------------------------------------------
General Functions
----------------------------------------------]]--
--[[ SendToChat(inputString, ...)
Formats chat output with Mythic Selector and color wrappers.
Requires at least one string input, but can take as many extra inputs as needed.
Each new input will be placed on a separate line.
Only the first line will get the Mythic Selector prefix. ]]--
function MS.SendToChat(inputString, ...)
	if not MS.SavedVars.chatMessages or inputString == false then return end
	local Args = {...}
	local Output = {}
	table.insert(Output, MS.Const.chatPrefix)
	table.insert(Output, MS.Const.chatTextColor)
	table.insert(Output, inputString) 
	table.insert(Output, MS.Const.chatSuffix)
	if #Args > 0 then
		for i,v in ipairs(Args) do
		  table.insert(Output, "\n")
			table.insert(Output, MS.Const.chatTextColor)
	    table.insert(Output, v) 
	    table.insert(Output, MS.Const.chatSuffix)
		end
	end
	CS:AddMessage(table.concat(Output))
end

function MS.Test()
end

function MS.InCombat()
	return IsUnitInCombat("player")
end

function MS.FormatItemDisplay(icon, displayName, size)
	local formattedString
	if MS.SavedVars.rightAlign then 
		formattedString = displayName .. "|t" .. size .. ":" .. size .. ":" .. icon .. "|t "
	else
		formattedString = "|t" .. size .. ":" .. size .. ":" .. icon .. "|t " .. displayName
	end
	return formattedString
end

function MS.CopyProfile(ID)
	if ID == nil or ID == MS.characterID then return end
	ZO_DeepTableCopy(MS.SavedVars[ID], MS.SavedVars[MS.characterID])
	ReloadUI("ingame")
end

function MS.DeleteProfile(ID)
	if ID == nil or ID == MS.characterID then return end
	local name = MS.SavedVars[ID].characterName
	local found = nil
	MS.SavedVars[ID] = nil
	for i,v in ipairs(MS.SavedVars.CharacterIDList) do
		if v == ID then
			found = i
			break
		end
	end
	if found ~= nil then table.remove(MS.SavedVars.CharacterIDList, found) found = nil end
	for i,v in ipairs(MS.SavedVars.CharacterList) do
		if v == name then
			found = i
			break
		end
	end
	if found ~= nil then table.remove(MS.SavedVars.CharacterList, found) end
	ReloadUI("ingame")
end


--[[----------------------------------------------
Inventory and Equipment Functions
----------------------------------------------]]--
-- Find what, if any, is already equipped from the 2 Queues and set the current indexes to those item(s).
function MS.SetQueIndexes()
	MS.neckIndex = nil
	MS.ringIndex = nil
	if #MS.SavedVars[MS.nameSpace].Necklaces > 0 then
		for i,v in ipairs(MS.SavedVars[MS.nameSpace].Necklaces) do
			if v.itemLink == GetItemLink(BAG_WORN, EQUIP_SLOT_NECK, LINK_STYLE_BRACKETS) then
				MS.neckIndex = i
				break
			end
		end
	end
	if #MS.SavedVars[MS.nameSpace].Rings > 0 then
		for i,v in ipairs(MS.SavedVars[MS.nameSpace].Rings) do
			if v.itemLink == GetItemLink(BAG_WORN, EQUIP_SLOT_RING1, LINK_STYLE_BRACKETS) then
				MS.ringIndex = i
				break
			end
		end
	end
	-- If the equipped item is not in the saved list then start the Queue at 1.
	if MS.neckIndex == nil then MS.neckIndex = 0 end
	if MS.ringIndex == nil then MS.ringIndex = 0 end
end

function MS.OtherMythicEquipped(equipType)
	local otherMythicFound = false
	local itemLink = nil
	for i,v in pairs(MS.EquipSlots) do
		if GetItemDisplayQuality(BAG_WORN, i) == ITEM_DISPLAY_QUALITY_MYTHIC_OVERRIDE then
			if GetItemEquipType(BAG_WORN, i) ~= equipType then
				otherMythicFound = true
				itemLink = GetItemLink(BAG_WORN, i, LINK_STYLE_BRACKETS)
			elseif GetItemEquipType(BAG_WORN, i) == EQUIP_TYPE_RING and i == EQUIP_SLOT_RING2 then
				otherMythicFound = true
				itemLink = GetItemLink(BAG_WORN, i, LINK_STYLE_BRACKETS)
			end
			break
		end
	end
	return otherMythicFound, itemLink
end

function MS.GetInventoryIndex(item)
	local bag, style = BAG_BACKPACK, LINK_STYLE_BRACKETS
	local slot = ZO_GetNextBagSlotIndex(bag)
	while slot do
		if HasItemInSlot(bag, slot)	and item.itemLink == GetItemLink(bag, slot, style) then
			return slot
		end
		slot = ZO_GetNextBagSlotIndex(bag, slot)
	end
end

function MS.EquipNextItem(equipType)
	if MS.InCombat() then MS.SendToChat("Cannot swap items while in combat.") return end
	local otherMythicFound, itemLink = MS.OtherMythicEquipped(equipType)

	if equipType == EQUIP_TYPE_NECK and #MS.SavedVars[MS.nameSpace].Necklaces > 0 then
		if MS.neckIndex == #MS.SavedVars[MS.nameSpace].Necklaces then MS.neckIndex = 1 else MS.neckIndex = MS.neckIndex + 1 end
		if otherMythicFound and MS.SavedVars[MS.nameSpace].Necklaces[MS.neckIndex].isMythic then
			MS.SendToChat("Only one type of Mythic item can be equipped at a time. Please remove " .. itemLink .. " before switching to " .. MS.SavedVars[MS.nameSpace].Necklaces[MS.neckIndex].itemLink .. ".")
			MS.neckIndex = MS.neckIndex - 1
			if MS.neckIndex <= 0 then MS.neckIndex = #MS.SavedVars[MS.nameSpace].Necklaces end
			return
		end
		if GetItemLink(BAG_WORN, EQUIP_SLOT_NECK, LINK_STYLE_BRACKETS) == MS.SavedVars[MS.nameSpace].Necklaces[MS.neckIndex].itemLink then
			MS.SendToChat(MS.SavedVars[MS.nameSpace].Necklaces[MS.neckIndex].itemLink .. " is already equipped.")
			return
		end
		local itemBagIndex = MS.GetInventoryIndex(MS.SavedVars[MS.nameSpace].Necklaces[MS.neckIndex])
		if itemBagIndex == nil then MS.SendToChat("Can't find " ..  MS.SavedVars[MS.nameSpace].Necklaces[MS.neckIndex].itemLink .." in inventory.") return end
		RequestEquipItem(BAG_BACKPACK, itemBagIndex, BAG_WORN, EQUIP_SLOT_NECK)

	elseif equipType == EQUIP_TYPE_RING and #MS.SavedVars[MS.nameSpace].Rings > 0 then
		if MS.ringIndex == #MS.SavedVars[MS.nameSpace].Rings then MS.ringIndex = 1 else MS.ringIndex = MS.ringIndex + 1 end
		if otherMythicFound and MS.SavedVars[MS.nameSpace].Rings[MS.ringIndex].isMythic then
			MS.SendToChat("Only one type of Mythic item can be equipped at a time. Please remove " .. itemLink .. " before switching to " .. MS.SavedVars[MS.nameSpace].Rings[MS.ringIndex].itemLink .. ".")
			MS.ringIndex = MS.ringIndex - 1
			if MS.ringIndex <= 0 then MS.ringIndex = #MS.SavedVars[MS.nameSpace].Rings end
			return
		end
		if GetItemLink(BAG_WORN, EQUIP_SLOT_RING1, LINK_STYLE_BRACKETS) == MS.SavedVars[MS.nameSpace].Rings[MS.ringIndex].itemLink then
			MS.SendToChat(MS.SavedVars[MS.nameSpace].Rings[MS.ringIndex].itemLink .. " is already equipped.")
			return
		end
		local itemBagIndex = MS.GetInventoryIndex(MS.SavedVars[MS.nameSpace].Rings[MS.ringIndex])
		if itemBagIndex == nil then MS.SendToChat("Can't find " ..  MS.SavedVars[MS.nameSpace].Rings[MS.ringIndex].itemLink .." in inventory.") return end
		RequestEquipItem(BAG_BACKPACK, itemBagIndex, BAG_WORN, EQUIP_SLOT_RING1)
	end
end


--[[----------------------------------------------
Main Window Control Functions
----------------------------------------------]]--
function MS_ON_MOVE_STOP()
  MS.SavedVars.panelLeft = MS_Panel:GetLeft()
	MS.SavedVars.panelTop = MS_Panel:GetTop()
end

function MS_UPDATE_SCROLL_LIST(equipType)
	MS.UpdateScrollList(equipType)
end

function MS.RestorePanel()
  local left = MS.SavedVars.panelLeft
	local top = MS.SavedVars.panelTop

	if left ~= nil and top ~= nil then
		MS_Panel:ClearAnchors()
		MS_Panel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
	end
end

function MS.ShowPanel()
  MS_Panel:SetHidden(not MS_Panel:IsHidden())
end

function MS.UpdateScrollList(equipType)	
	for i,v in pairs(MS.ListPool) do
		v:SetHidden(true)
	end
	local Data = {}
	if equipType == EQUIP_TYPE_NECK then
		Data = MS.SavedVars[MS.nameSpace].Necklaces
	elseif equipType == EQUIP_TYPE_RING then
		Data = MS.SavedVars[MS.nameSpace].Rings
	end
	local parent = MS_PanelScrollBox
	local name = "MSListEntry"
	local template = "MSListTemplate"
	for i,v in ipairs(Data) do
		local c = {}
		if MS.ListPool[i] then
			c = MS.ListPool[i]
		else
			c = WM:CreateControlFromVirtual(name, parent, template, i)
			c:SetParent(parent:GetNamedChild("ScrollChild"))
			table.insert(MS.ListPool, c)
			c:ClearAnchors()
			c:SetAnchor(TOPLEFT, ScrollBoxScrollChild, TOPLEFT, 0, (i-1) * 32)
		end
		c:SetText(MS.FormatItemDisplay(v.icon, v.displayName, 32))
		c:SetHidden(false)
		c:SetHandler("OnMouseUp", function(self, button) if button == 1 then MS.MoveUp(i, equipType) elseif button == 2 then MS.RemoveItem(i, equipType) end end)
		c:SetHandler("OnMouseEnter", function(self) MS.ShowTooltip(i, equipType) end)
		c:SetHandler("OnMouseExit", function(self) MS.HideTooltip() end)
	end
end

function MS.RemoveItem(index, equipType)
	if equipType == EQUIP_TYPE_NECK then
		table.remove(MS.SavedVars[MS.nameSpace].Necklaces, index)
	elseif equipType == EQUIP_TYPE_RING then
		table.remove(MS.SavedVars[MS.nameSpace].Rings, index)
	end
	MS.UpdateScrollList(equipType)
end

function MS.MoveUp(index, equipType)
	if index == 1 then return end
	local Temp = {}
	if equipType == EQUIP_TYPE_NECK then
		Temp = table.remove(MS.SavedVars[MS.nameSpace].Necklaces, index - 1)
		table.insert(MS.SavedVars[MS.nameSpace].Necklaces, index, Temp)
	elseif equipType == EQUIP_TYPE_RING then
		Temp = table.remove(MS.SavedVars[MS.nameSpace].Rings, index - 1)
		table.insert(MS.SavedVars[MS.nameSpace].Rings, index, Temp)
	end
	MS.UpdateScrollList(equipType)
	MS.SetQueIndexes()
end

function MS.ShowTooltip(index, equipType)
	local itemLink
	if equipType == EQUIP_TYPE_NECK then
		itemLink = MS.SavedVars[MS.nameSpace].Necklaces[index].itemLink
	else
		itemLink = MS.SavedVars[MS.nameSpace].Rings[index].itemLink
	end
	InitializeTooltip(ItemTooltip, MS_Panel, RIGHT, -5, 0, LEFT)
	ItemTooltip:SetLink(itemLink)
end

function MS.HideTooltip()
	ClearTooltip(ItemTooltip)
end


--[[----------------------------------------------
Indicator Window Control Functions
----------------------------------------------]]--
function MS_IND_ON_MOVE_STOP()
	MS.SavedVars.indLeft = MS_Indicator:GetLeft()
	MS.SavedVars.indTop = MS_Indicator:GetTop()
end

function MS.RestoreIndicator()
  local left = MS.SavedVars.indLeft
	local top = MS.SavedVars.indTop

	if left ~= nil and top ~= nil then
		MS_Indicator:ClearAnchors()
		MS_Indicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
	end

	MS_IndicatorBG:SetAlpha(MS.SavedVars.indicatorBGAlpha / 100)

	local neckIcon = GetItemInfo(BAG_WORN, EQUIP_SLOT_NECK)
	local neckDisplayName = GetItemLink(BAG_WORN, EQUIP_SLOT_NECK, LINK_STYLE_NO_BRACKETS)
	local ringIcon = GetItemInfo(BAG_WORN, EQUIP_SLOT_RING1)
	local ringDisplayName = GetItemLink(BAG_WORN, EQUIP_SLOT_RING1, LINK_STYLE_NO_BRACKETS)

	MS_IndicatorNecklaceLabel:SetText(MS.FormatItemDisplay(neckIcon, neckDisplayName, MS_IndicatorNecklaceLabel:GetFontHeight()))
	MS_IndicatorRingLabel:SetText(MS.FormatItemDisplay(ringIcon, ringDisplayName, MS_IndicatorRingLabel:GetFontHeight()))
	MS_Indicator:SetWidth(MS.SavedVars.width + 10)
	MS.SetFontSize()
	MS.ShowIndicator()
	MS.ChangeAlignment()
end

function MS.UpdateIndicator()
	local neckIcon = GetItemInfo(BAG_WORN, EQUIP_SLOT_NECK)
	local neckDisplayName = GetItemLink(BAG_WORN, EQUIP_SLOT_NECK, LINK_STYLE_NO_BRACKETS)
	local ringIcon = GetItemInfo(BAG_WORN, EQUIP_SLOT_RING1)
	local ringDisplayName = GetItemLink(BAG_WORN, EQUIP_SLOT_RING1, LINK_STYLE_NO_BRACKETS)

	MS_IndicatorNecklaceLabel:SetText(MS.FormatItemDisplay(neckIcon, neckDisplayName, MS_IndicatorNecklaceLabel:GetFontHeight()))
	MS_IndicatorRingLabel:SetText(MS.FormatItemDisplay(ringIcon, ringDisplayName, MS_IndicatorNecklaceLabel:GetFontHeight()))

	if MS.SavedVars.indicatorShowOnChange then
		MS.ShowIndicatorOnChange(true)
	end
end

function MS.ShowIndicator()
  MS_IndicatorNecklaceLabel:SetHidden(not MS.SavedVars[MS.nameSpace].neckIndicator)
	MS_IndicatorRingLabel:SetHidden(not MS.SavedVars[MS.nameSpace].ringIndicator)
	local neckHidden = not MS.SavedVars[MS.nameSpace].neckIndicator
	local ringHidden = not MS.SavedVars[MS.nameSpace].ringIndicator

	if not neckHidden and not ringHidden then
		MS.indicatorHidden = false
		MS_Indicator:SetHidden(false)

	elseif neckHidden and ringHidden then
		MS.indicatorHidden = true
		MS_Indicator:SetHidden(true)

	elseif neckHidden or ringHidden then
		MS.indicatorHidden = false
		MS_Indicator:SetHidden(false)
	end

	if MS.SavedVars.indicatorShowOnChange then
		MS.indicatorHidden = true
		MS_Indicator:SetHidden(true)
	end

	MS.SetFontSize()
end

function MS.ShowIndicatorOnChange(show)
	if show then
		MS.indicatorHideTime = os.rawclock() + (MS.SavedVars.indicatorFadeDelay * 1000)
		MS.indicatorHidden = false
		MS_Indicator:SetHidden(false)
		zo_callLater(function() MS.ShowIndicatorOnChange(false) end, MS.SavedVars.indicatorFadeDelay * 1000)
	elseif os.rawclock() >= MS.indicatorHideTime then
		MS.indicatorHidden = true
		MS_Indicator:SetHidden(true)
	end
end

function MS.SetFontSize()
	local window, neck, ring = WM:GetControlByName("MS_Indicator"), WM:GetControlByName("MS_IndicatorNecklaceLabel"), WM:GetControlByName("MS_IndicatorRingLabel")
	neck:SetFont(string.format("$(BOLD_FONT)|$(KB_%d)|soft-shadow-thin", MS.SavedVars.fontSize))
	ring:SetFont(string.format("$(BOLD_FONT)|$(KB_%d)|soft-shadow-thin", MS.SavedVars.fontSize))
	local neckHidden = not MS.SavedVars[MS.nameSpace].neckIndicator
	local ringHidden = not MS.SavedVars[MS.nameSpace].ringIndicator
	local height = neck:GetFontHeight()
	if not neckHidden and not ringHidden then
		height = height * 2
	end
	window:SetHeight(height + 2)
	MS.UpdateIndicator()
end

function MS.ChangeAlignment()
	local neck, ring = WM:GetControlByName("MS_IndicatorNecklaceLabel"), WM:GetControlByName("MS_IndicatorRingLabel")
	if MS.SavedVars.rightAlign then
		neck:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
		ring:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
	else
		neck:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
		ring:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
	end
	MS.UpdateIndicator()
end


--[[----------------------------------------------
Keybind Functions
----------------------------------------------]]--
function MS_HOTKEY_RING()
  MS.EquipNextItem(EQUIP_TYPE_RING)
end

function MS_HOTKEY_NECKLACE()
  MS.EquipNextItem(EQUIP_TYPE_NECK)
end

function MS_HOTKEY_TOGGLE()
	MS.ShowPanel()
end


--[[----------------------------------------------
Context Menu
----------------------------------------------]]--
function MS.AddItem(bagID, index)
	local itemLink = GetItemLink(bagID, index, LINK_STYLE_BRACKETS)
	local name = GetItemLinkName(itemLink)
	local displayName = GetItemLink(bagID, index, LINK_STYLE_NO_BRACKETS)
	local texture, _, _, _, _, equipType, _, _, displayQuality = GetItemInfo(bagID, index)
	local isMythic = false
	if displayQuality == ITEM_DISPLAY_QUALITY_MYTHIC_OVERRIDE then isMythic = true end
	local Info = {
		icon = texture,
		displayQuality = displayQuality,
		name = name,
		itemLink = itemLink,
		displayName = displayName,
		isMythic = isMythic
	}
	if equipType == EQUIP_TYPE_NECK then
		table.insert(MS.SavedVars[MS.nameSpace].Necklaces, Info)
	elseif equipType == EQUIP_TYPE_RING then
		table.insert(MS.SavedVars[MS.nameSpace].Rings, Info)
	end
	MS.UpdateScrollList(equipType)
	if MS_Panel:IsHidden() then
		MS.ShowPanel()
	end
end

function MS.ShowContextMenu(rowControl, slotActions)
	local bagID = rowControl.bagId
	local index = rowControl.slotIndex
	local equipType = GetItemEquipType(bagID, index)
	if bagID == BAG_BACKPACK or bagID == BAG_WORN then
		if (equipType == EQUIP_TYPE_NECK) or (equipType == EQUIP_TYPE_RING) then
			AddCustomMenuItem("Add to Mythic Selector" , function() MS.AddItem(bagID, index) end, MENU_ADD_OPTION_LABEL)
			ShowMenu(rowControl)
		end
	end
end


--[[----------------------------------------------
Setup, Initialization and Event Callbacks
----------------------------------------------]]--
function MS.Initialize()
	MS.characterID = GetCurrentCharacterId()
	MS.SavedVars = ZO_SavedVars:NewAccountWide("MythicSelectorVars", MS.varsVersion, nil, MS.AccountWideDefaults, GetWorldName())
	if MS.SavedVars[MS.characterID] == nil then
		MS.nameSpace = MS.characterID
		MS.SavedVars[MS.nameSpace] = {}
		MS.SavedVars[MS.nameSpace] = MS.ProfileDefaults
		MS.SavedVars[MS.nameSpace].characterName = GetUnitName("player")
		table.insert(MS.SavedVars.CharacterList, GetUnitName("player"))
		table.insert(MS.SavedVars.CharacterIDList, MS.characterID)
	elseif MS.SavedVars[MS.characterID].useAccountWide then
		MS.nameSpace = "AccountWide"
		if MS.SavedVars[MS.nameSpace] == nil then
			MS.SavedVars[MS.nameSpace] = {}
			MS.SavedVars[MS.nameSpace] = MS.ProfileDefaults
			MS.SavedVars[MS.nameSpace].characterName = "Account Wide"
			table.insert(MS.SavedVars.CharacterList, "Account Wide")
			table.insert(MS.SavedVars.CharacterIDList, "AccountWide")
		end
	else
		MS.nameSpace = MS.characterID
	end

	if MS.SavedVars[MS.characterID].characterName ~= GetUnitName("player") then
		MS.SavedVars[MS.characterID].characterName = GetUnitName("player")
		for i,v in ipairs(MS.SavedVars.CharacterIDList) do
			if v == MS.characterID then
				found = i
				break
			end
		end
		if found ~= nil then MS.SavedVars.CharacterList[found] = GetUnitName("player") end
	end

  MS.RestorePanel()
	MS.UpdateScrollList(EQUIP_TYPE_RING)
	MS.RestoreIndicator()
	MS.SetQueIndexes()
	MS.CreateSettingsWindow()

  ZO_CreateStringId("SI_BINDING_NAME_MS_HOTKEY_TOGGLE", "Show/Hide")
	ZO_CreateStringId("SI_BINDING_NAME_MS_HOTKEY_RING", "Ring Toggle")
  ZO_CreateStringId("SI_BINDING_NAME_MS_HOTKEY_NECKLACE", "Necklace Toggle")

  SLASH_COMMANDS["/ms"] = MS.ShowPanel
	SLASH_COMMANDS["/mstest"] = MS.Test

	LCM:RegisterContextMenu(MS.ShowContextMenu)

	local scene = SM:GetScene("hud")
  scene:RegisterCallback("StateChange", MS.HUDSceneChange)
  local scene = SM:GetScene("hudui")
  scene:RegisterCallback("StateChange", MS.HUDUISceneChange)

	EM:RegisterForEvent(MS.addonName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, MS.OnInventoryChanged)
	EM:AddFilterForEvent(MS.addonName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN)
	EM:AddFilterForEvent(MS.addonName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)

  EM:UnregisterForEvent(MS.addonName, EVENT_ADD_ON_LOADED)
end

function MS.OnAddonLoaded(event, addonName)
	if addonName == MS.addonName then
		MS.Initialize()
	end
end

function MS.HUDSceneChange(oldState, newState)
  if (newState == SCENE_SHOWN) and not MS.indicatorHidden then
    MS_Indicator:SetHidden(false)
  elseif (newState == SCENE_HIDDEN) then
    MS_Indicator:SetHidden(true)
  end
end

function MS.HUDUISceneChange(oldState, newState)
  if (newState == SCENE_SHOWN) and not MS.indicatorHidden then
    MS_Indicator:SetHidden(false)
  elseif (newState == SCENE_HIDDEN) then
    MS_Indicator:SetHidden(true)
  end
end

function MS.OnInventoryChanged(eventCode, bagId, slotId, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange)
	if slotId == EQUIP_SLOT_NECK or slotId == EQUIP_SLOT_RING1 then
		MS.UpdateIndicator()
		MS.SetQueIndexes()
	end
end

EM:RegisterForEvent(MS.addonName, EVENT_ADD_ON_LOADED, MS.OnAddonLoaded)