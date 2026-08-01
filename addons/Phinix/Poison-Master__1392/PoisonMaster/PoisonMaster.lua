-------------------------------------------------------------------------------
-- Poison Master
-------------------------------------------------------------------------------
--[[
-- Copyright (c) 2015-2021 James A. Keene (Phinix) All rights reserved.
--
-- Permission is hereby granted, free of charge, to any person obtaining
-- a copy of this software and associated documentation (the "Software"),
-- to operate the Software for personal use only. Permission is NOT granted
-- to modify, merge, publish, distribute, sublicense, re-upload, and/or sell
-- copies of the Software. Additionally, licensed use of the Software
-- will be subject to the following:
--
-- The above copyright notice and this permission notice shall be
-- included in all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
-- HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
-- WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
-- OTHER DEALINGS IN THE SOFTWARE.
--
-------------------------------------------------------------------------------
--
-- DISCLAIMER:
--
-- This Add-on is not created by, affiliated with or sponsored by ZeniMax
-- Media Inc. or its affiliates. The Elder Scrolls® and related logos are
-- registered trademarks or trademarks of ZeniMax Media Inc. in the United
-- States and/or other countries. All rights reserved.
--
-- You can read the full terms at:
-- https://account.elderscrollsonline.com/add-on-terms
--]]

local PMAddon = _G['PMAddon']
local L = PMAddon:GetLanguage()
local PF = LibPhinixFunctions
local version = "1.16"

-- Global functions:
local pTC = PF.TColor

local slotControls = { [1] = {control = nil}, [2] = {control = nil}, [3] = {control = nil}, [4] = {control = nil} }
local stackControls = { [1] = {control = nil}, [2] = {control = nil}, [3] = {control = nil}, [4] = {control = nil} }
local borderControls = { [1] = {wAb = nil, wOb = nil}, [2] = {wAb = nil, wOb = nil}, [3] = {wAb = nil, wOb = nil}, [4] = {wAb = nil, wOb = nil} }
local checkControls = { [1] = {wAc = nil, wOc = nil}, [2] = {wAc = nil, wOc = nil}, [3] = {wAc = nil, wOc = nil}, [4] = {wAc = nil, wOc = nil} }
local equipOptionTooltips = { [1] = L.PMAddon_STYLE1, [2] = L.PMAddon_STYLE2 }
local equipOptions = { [1] = '/PoisonMaster/bin/borderOpt.dds', [2] = '/PoisonMaster/bin/equipOpt.dds' }
local defaultIcon = "/esoui/art/characterwindow/gearslot_poison.dds"
local PoisonTooltipControl
local InitDone

local CharacterDefaults = {
	poisonStacks = { [1] = {stack = 0}, [2] = {stack = 0}, [3] = {stack = 0}, [4] = {stack = 0} },
	poisonLinks = { [1] = {link = ""}, [2] = {link = ""}, [3] = {link = ""}, [4] = {link = ""} },
	poisonIcons = {
		[1] = {icon = "/esoui/art/characterwindow/gearslot_poison.dds"},
		[2] = {icon = "/esoui/art/characterwindow/gearslot_poison.dds"},
		[3] = {icon = "/esoui/art/characterwindow/gearslot_poison.dds"},
		[4] = {icon = "/esoui/art/characterwindow/gearslot_poison.dds"},
	}
}
local AccountDefaults = {
	xpos = 0,
	ypos = 0,
	dbversion = 0,
	locked = false,
	hideBackground = false,
	showIcons = true,
	iconStyle = 1,
	showDebug = true,
}

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- GUI functions
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function ShowIcons()
	for hide = 1, 4 do
		borderControls[hide].wAb:SetHidden(true) checkControls[hide].wAc:SetHidden(true)
		borderControls[hide].wOb:SetHidden(true) checkControls[hide].wOc:SetHidden(true)
	end
	if PMAddon.ASV.showIcons == false then return end
	if GetControl('PMAddon_MainFrame'):IsHidden() then return end
	
	for slot = 1, 4 do
		local link = PMAddon.SV.poisonLinks[slot].link
		local weapon = GetActiveWeaponPairInfo()
		if link ~= "" then
			if weapon == 1 then
				if GetItemLink(BAG_WORN, EQUIP_SLOT_POISON) == link then
					if PMAddon.ASV.iconStyle == 1 then borderControls[slot].wAb:SetHidden(false) else checkControls[slot].wAc:SetHidden(false) end
				elseif GetItemLink(BAG_WORN, EQUIP_SLOT_BACKUP_POISON) == link then
					if PMAddon.ASV.iconStyle == 1 then borderControls[slot].wOb:SetHidden(false) else checkControls[slot].wOc:SetHidden(false) end
				end
			elseif weapon == 2 then
				if GetItemLink(BAG_WORN, EQUIP_SLOT_BACKUP_POISON) == link then
					if PMAddon.ASV.iconStyle == 1 then borderControls[slot].wAb:SetHidden(false) else checkControls[slot].wAc:SetHidden(false) end
				elseif GetItemLink(BAG_WORN, EQUIP_SLOT_POISON) == link then
					if PMAddon.ASV.iconStyle == 1 then borderControls[slot].wOb:SetHidden(false) else checkControls[slot].wOc:SetHidden(false) end
				end
			end
		end
	end
end

local function OnMoveStop()
	PMAddon.ASV.xpos = PMAddon_MainFrame:GetLeft()
	PMAddon.ASV.ypos = PMAddon_MainFrame:GetTop()
end

local function RestorePosition()
	local left = PMAddon.ASV.xpos
	local top = PMAddon.ASV.ypos
	PMAddon_MainFrame:ClearAnchors()
	PMAddon_MainFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
	ShowIcons()
end

local function ButtonTooltip(slot, button, var1)
	local link = PMAddon.SV.poisonLinks[slot].link

	if var1 == 1 then
		if link ~= "" then
			local PoisonItemTooltip = PoisonTooltipControl
			InitializeTooltip(PoisonItemTooltip, slotControls[slot].control, LEFT, 0, 0, RIGHT)
			PopupTooltip.SetLink(PoisonItemTooltip, link)
		else
			InitializeTooltip(InformationTooltip, button, TOPLEFT, -12, 8, BOTTOMRIGHT)
			SetTooltipText(InformationTooltip, L.PMAddon_Tooltip)
		end
	elseif var1 == 2 then
		local PoisonItemTooltip = PoisonTooltipControl
		if PoisonItemTooltip then ClearTooltip(PoisonItemTooltip) end
		if InformationTooltip then ClearTooltip(InformationTooltip) end
	end
end

local function ShowMain()
	for slot = 1, 4 do
		local iconFile = PMAddon.SV.poisonIcons[slot].icon
		slotControls[slot].control:SetNormalTexture(iconFile)
		slotControls[slot].control:SetPressedTexture(iconFile)
		slotControls[slot].control:SetMouseOverTexture(iconFile)
		slotControls[slot].control:SetDisabledTexture(iconFile)
	end
	local control = GetControl('PMAddon_MainFrame')
	if ( control:IsHidden() ) then
		PMAddon_MainFrame:SetHidden(false)
		RestorePosition()
	else
		PMAddon_MainFrame:SetHidden(true)
	end
	if (PMAddon.ASV.locked) then PMAddon_MainFrame:SetMovable(false) else PMAddon_MainFrame:SetMovable(true) end
	if (PMAddon.ASV.hideBackground) then PMAddon_MainFrameBG:SetHidden(true) else PMAddon_MainFrameBG:SetHidden(false) end
end

local function GetTextureId(texturePath)
	for k, v in pairs(equipOptions) do
		if	v == texturePath then
			return k
		end
	end
	return 0
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Equip/unequip functions
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function CheckStacks()
	local stackTotal
	for slot = 1, 4 do
		if PMAddon.SV.poisonLinks[slot].link ~= "" then
			stackTotal = 0
			local link = PMAddon.SV.poisonLinks[slot].link
			if GetItemLink(BAG_WORN, EQUIP_SLOT_POISON) == link then
				local _, poisonCount = GetItemPairedPoisonInfo(EQUIP_SLOT_MAIN_HAND)
				stackTotal = stackTotal + poisonCount
			end
			if GetItemLink(BAG_WORN, EQUIP_SLOT_BACKUP_POISON) == link then
				local _, poisonCount = GetItemPairedPoisonInfo(EQUIP_SLOT_BACKUP_MAIN)
				stackTotal = stackTotal + poisonCount
			end
			for i = 0, GetBagSize(BAG_BACKPACK) do
				local search = GetItemLink(BAG_BACKPACK,i)
				if search == link then
					local _, stackSize, _, _, _, _, _, _ = GetItemInfo(BAG_BACKPACK, i)
					stackTotal = stackTotal + stackSize
				end
			end
			if stackTotal > 0 then
				PMAddon.SV.poisonStacks[slot].stack = stackTotal
				stackControls[slot].control:SetText(stackTotal)
				stackControls[slot].control:SetHidden(false)
			else
				PMAddon.SV.poisonStacks[slot].stack = 0
				stackControls[slot].control:SetText(0)
				stackControls[slot].control:SetHidden(false)
			end
		else
			PMAddon.SV.poisonStacks[slot].stack = 0
			stackControls[slot].control:SetText(0)
			stackControls[slot].control:SetHidden(true)
		end
	end
end

local function EquipSlot(slot, link)
	local weapon = GetActiveWeaponPairInfo()

	if GetItemLink(BAG_WORN, EQUIP_SLOT_POISON) == link then
		if weapon == 1 then
			UnequipItem(EQUIP_SLOT_POISON)
		else
			RequestEquipItem(BAG_WORN, EQUIP_SLOT_POISON, BAG_WORN, EQUIP_SLOT_BACKUP_POISON)
		end
		ShowIcons()
		return
	elseif GetItemLink(BAG_WORN, EQUIP_SLOT_BACKUP_POISON) == link then
		if weapon == 1 then
			RequestEquipItem(BAG_WORN, EQUIP_SLOT_BACKUP_POISON, BAG_WORN, EQUIP_SLOT_POISON)
		else
			UnequipItem(EQUIP_SLOT_BACKUP_POISON)
		end
		ShowIcons()
		return
	else
		for i = 0, GetBagSize(BAG_BACKPACK) do
			if GetItemLink(BAG_BACKPACK,i) == link then
				if weapon == 1 then
					RequestEquipItem(BAG_BACKPACK, i, BAG_WORN, EQUIP_SLOT_POISON)
				else
					RequestEquipItem(BAG_BACKPACK, i, BAG_WORN, EQUIP_SLOT_BACKUP_POISON)
				end
				ShowIcons() return
			end
		end
	end
	if (PMAddon.ASV.showDebug) then
		d(L.PMAddon_PNE)
	end
end

local function SetSlot(slot, button)
	if button == 1 then
		if IsShiftKeyDown() then
			local weapon = GetActiveWeaponPairInfo()
			local iconFile, slotHasItem
			local poisonSlot
			if weapon == 1 then
				iconFile, slotHasItem = GetEquippedItemInfo(EQUIP_SLOT_POISON)
				poisonSlot = EQUIP_SLOT_POISON
			elseif weapon == 2 then
				iconFile, slotHasItem = GetEquippedItemInfo(EQUIP_SLOT_BACKUP_POISON)
				poisonSlot = EQUIP_SLOT_BACKUP_POISON
			end
			if slotHasItem then
				local clicked = GetItemLink(BAG_WORN, poisonSlot)
				for i = 1, 4 do
					if PMAddon.SV.poisonLinks[i].link == clicked then
						slotControls[i].control:SetNormalTexture(defaultIcon)
						slotControls[i].control:SetPressedTexture(defaultIcon)
						slotControls[i].control:SetMouseOverTexture(defaultIcon)
						slotControls[i].control:SetDisabledTexture(defaultIcon)
						PMAddon.SV.poisonLinks[i].link = ""
						PMAddon.SV.poisonIcons[i].icon = defaultIcon
						PMAddon.SV.poisonStacks[i].stack = 0
						stackControls[i].control:SetText(0)
						stackControls[i].control:SetHidden(true)
					end
				end
				slotControls[slot].control:SetNormalTexture(iconFile)
				slotControls[slot].control:SetPressedTexture(iconFile)
				slotControls[slot].control:SetMouseOverTexture(iconFile)
				slotControls[slot].control:SetDisabledTexture(iconFile)
				PMAddon.SV.poisonLinks[slot].link = GetItemLink(BAG_WORN, poisonSlot)
				PMAddon.SV.poisonIcons[slot].icon = iconFile
				if InformationTooltip then ClearTooltip(InformationTooltip) end
				PlaySound("Alchemy_Solvent_Placed")
				CheckStacks()
				ShowIcons()
			else
				if (PMAddon.ASV.showDebug) then
					d(L.PMAddon_NPE)
				end
			end
		else
			local link = PMAddon.SV.poisonLinks[slot].link
			if link ~= "" then EquipSlot(slot, link) end
		end
	elseif button == 2 then
		slotControls[slot].control:SetNormalTexture(defaultIcon)
		slotControls[slot].control:SetPressedTexture(defaultIcon)
		slotControls[slot].control:SetMouseOverTexture(defaultIcon)
		slotControls[slot].control:SetDisabledTexture(defaultIcon)
		PMAddon.SV.poisonLinks[slot].link = ""
		PMAddon.SV.poisonIcons[slot].icon = defaultIcon
		local PoisonItemTooltip = PoisonTooltipControl
		if PoisonItemTooltip then ClearTooltip(PoisonItemTooltip) end
		PMAddon.SV.poisonStacks[slot].stack = 0
		stackControls[slot].control:SetText(0)
		stackControls[slot].control:SetHidden(true)
		PlaySound("Alchemy_Reagent_Removed")
		ShowIcons()
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Set up the Addon Settings options panel
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function CreateSettingsWindow(addonName)
	local panelData = {
		type					= 'panel',
		name					= 'Poison Master',
		displayName				= ZO_HIGHLIGHT_TEXT:Colorize('Poison Master'),
		author					= pTC("66ccff", "Phinix"),
		version					= version,
		registerForRefresh		= true,
		registerForDefaults		= true,
	}

	local optionsData = {
	{
		type = 'header',
		name = ZO_HIGHLIGHT_TEXT:Colorize(L.PMAddon_GLOBAL),
	},
	{
		type			= 'checkbox',
		name			= L.PMAddon_LOCK,
		tooltip			= L.PMAddon_LOCKTIP,
		getFunc			= function() return PMAddon.ASV.locked end,
		setFunc			= function(value)
							PMAddon.ASV.locked = value
							if value == true then
								PMAddon_MainFrame:SetMovable(true)
							else
								PMAddon_MainFrame:SetMovable(false)
							end
						end,
		default			= AccountDefaults.locked,
	},
	{
		type			= 'checkbox',
		name			= L.PMAddon_BACK,
		tooltip			= L.PMAddon_BACKTIP,
		getFunc			= function() return PMAddon.ASV.hideBackground end,
		setFunc			= function(value)
							PMAddon.ASV.hideBackground = value
							if value == true then
								PMAddon_MainFrameBG:SetHidden(true)
							else
								PMAddon_MainFrameBG:SetHidden(false)
							end
						end,
		default			= AccountDefaults.hideBackground,
	},
	{
		type			= 'checkbox',
		name			= L.PMAddon_DEBUG,
		tooltip			= L.PMAddon_DEBUGTIP,
		getFunc			= function() return PMAddon.ASV.showDebug end,
		setFunc			= function(value)
							PMAddon.ASV.showDebug = value
						end,
		default			= AccountDefaults.showDebug,
	},
	{
		type			= 'checkbox',
		name			= L.PMAddon_ICONS,
		tooltip			= L.PMAddon_ICONSTIP,
		getFunc			= function() return PMAddon.ASV.showIcons end,
		setFunc			= function(value)
							PMAddon.ASV.showIcons = value
							ShowIcons()
						end,
		default			= AccountDefaults.showIcons,
	},
	{
		type			= 'iconpicker',
		name			= L.PMAddon_THEME,
		tooltip			= L.PMAddon_THEMETIP,
		choices			= equipOptions,
		choicesTooltips	= equipOptionTooltips,
		getFunc			= function() return equipOptions[PMAddon.ASV.iconStyle] end,
		setFunc			= function(texturePath)
							local textureId = GetTextureId(texturePath)
							if textureId ~= 0 then
								PMAddon.ASV.iconStyle = textureId
							end
						end,
		maxColumns		= 2,
		visibleRows		= 1,
		iconSize		= 64,
		default			= AccountDefaults.iconStyle,
		disabled		= function() return not PMAddon.ASV.showIcons end,
	}
	}

	local LAM = LibAddonMenu2
	LAM:RegisterAddonPanel('PMAddon_Panel', panelData)
	LAM:RegisterOptionControls('PMAddon_Panel', optionsData)
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Init and XML handler.
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function OnUpdate(eventCode, bagId, slotId, isNewItem, itemSoundCategory, inventoryUpdateReason, stackSizeChange)
	if GetItemType(bagId, slotId) ~= 30 then return end
	CheckStacks()
	ShowIcons()
end

local function OnSwap(isHotbarSwap)
	if InitDone == 1 then if (isHotbarSwap) then ShowIcons() end end
end

local function HookInventory()
	local InventoryScene = SCENE_MANAGER.scenes.inventory
	InventoryScene:RegisterCallback("StateChange", function(oldState, newState)
		local control = GetControl('PMAddon_MainFrame')
		if (newState == "showing") then
			if ( control:IsHidden() ) then
				ShowMain()
			end
		elseif (newState == "hiding") then
			if not ( control:IsHidden() ) then
				ShowMain()
			end
		end
		PMAddon_MainFrameCloseButton:SetHidden(true)
	end)
end

local function Init()
	if InitDone ~= 1 then InitDone = 1 ShowIcons() end
end

local function InitPoisonTooltip(button)
	if not button then return end
	PoisonTooltipControl = button
	button:SetParent(PopupTooltipTopLevel)
end

local function InitControls()
	if PMAddon.ASV.dbversion < 1.09 then
		PMAddon.ASV.xpos = 0
		PMAddon.ASV.ypos = 0
		PMAddon.ASV.dbversion = 1.09
	end
	slotControls[1].control = PMAddon_MainFramePoisonSlot01
	slotControls[2].control = PMAddon_MainFramePoisonSlot02
	slotControls[3].control = PMAddon_MainFramePoisonSlot03
	slotControls[4].control = PMAddon_MainFramePoisonSlot04
	stackControls[1].control = PMAddon_MainFramePoisonSlot01_Stack
	stackControls[2].control = PMAddon_MainFramePoisonSlot02_Stack
	stackControls[3].control = PMAddon_MainFramePoisonSlot03_Stack
	stackControls[4].control = PMAddon_MainFramePoisonSlot04_Stack
	borderControls[1].wAb = PMAddon_MainFramePoisonSlot01_EquipAb
	borderControls[1].wOb = PMAddon_MainFramePoisonSlot01_EquipOb
	borderControls[2].wAb = PMAddon_MainFramePoisonSlot02_EquipAb
	borderControls[2].wOb = PMAddon_MainFramePoisonSlot02_EquipOb
	borderControls[3].wAb = PMAddon_MainFramePoisonSlot03_EquipAb
	borderControls[3].wOb = PMAddon_MainFramePoisonSlot03_EquipOb
	borderControls[4].wAb = PMAddon_MainFramePoisonSlot04_EquipAb
	borderControls[4].wOb = PMAddon_MainFramePoisonSlot04_EquipOb
	checkControls[1].wAc = PMAddon_MainFramePoisonSlot01_EquipAc
	checkControls[1].wOc = PMAddon_MainFramePoisonSlot01_EquipOc
	checkControls[2].wAc = PMAddon_MainFramePoisonSlot02_EquipAc
	checkControls[2].wOc = PMAddon_MainFramePoisonSlot02_EquipOc
	checkControls[3].wAc = PMAddon_MainFramePoisonSlot03_EquipAc
	checkControls[3].wOc = PMAddon_MainFramePoisonSlot03_EquipOc
	checkControls[4].wAc = PMAddon_MainFramePoisonSlot04_EquipAc
	checkControls[4].wOc = PMAddon_MainFramePoisonSlot04_EquipOc
	CheckStacks()
	InitDone = 1
end

local pChars = {
	["Dar'jazad"] = "Rajhin's Echo",
	["Quantus Gravitus"] = "Maker of Things",
	["Nina Romari"] = "Sanguine Coalescence",
	["Valyria Morvayn"] = "Dragon's Teeth",
	["Sanya Lightspear"] = "Thunderbird",
	["Divad Arbolas"] = "Gravity of Words",
	["Dro'samir"] = "Dark Matter",
	["Irae Aundae"] = "Prismatic Inversion",
	["Quixoti'coatl"] = "Time Toad",
	["Cythirea"] = "Mazken Stormclaw",
	["Fear-No-Pain"] = "Soul Sap",
	["Wax-in-Winter"] = "Cold Blooded",
	["Nateo Mythweaver"] = "In Strange Lands",
	["Cindari Atropa"] = "Dragon's Breath",
	["Kailyn Duskwhisper"] = "Nowhere's End",
	["Draven Blightborn"] = "From Outside",
	["Lorein Tarot"] = "Entanglement",
	["Koh-Ping"] = "Global Cooling",
}

local function modifyTitle(oTitle, uName)
	local tLang = {
		en = "Volunteer",
		fr = "Volontaire",
		de = "Freiwillige",
	}
	local client = GetCVar("Language.2")
	if oTitle == tLang[client] then
		return (pChars[uName] ~= nil) and pChars[uName] or oTitle
	end
	return oTitle
end

local modifyGetTitle = GetTitle
GetTitle = function(index)
	local oTitle = modifyGetTitle(index)
	local uName = GetUnitName('player')
	local rTitle = modifyTitle(oTitle, uName)
	return rTitle
end

local modifyGetUnitTitle = GetUnitTitle
GetUnitTitle = function(unitTag)
	local oTitle = modifyGetUnitTitle(unitTag)
	local uName = GetUnitName(unitTag)
	local rTitle = modifyTitle(oTitle, uName)
	return rTitle
end

function PMAddon.XMLNavigation(opt, slot, button, var1)
	if opt == 01 then
		PMAddon_MainFrameCloseButton:SetHidden(false)
		ShowMain()
	elseif opt == 02 then
		OnMoveStop()
	elseif opt == 03 then
		ButtonTooltip(slot, button, var1)
	elseif opt == 04 then
		InitPoisonTooltip(button)
	elseif opt == 11 then
		SetSlot(slot, button)
	elseif opt == 12 then
		local link = PMAddon.SV.poisonLinks[slot].link
		if link ~= "" then EquipSlot(slot, link) end
	end
end

local function OnAddonLoaded(event, addonName)
	if addonName ~= 'PoisonMaster' then return end
	EVENT_MANAGER:UnregisterForEvent('PoisonMaster', EVENT_ADD_ON_LOADED)
	PMAddon.SV = ZO_SavedVars:New('PoisonMaster', 1.01, nil, CharacterDefaults)
	PMAddon.ASV = ZO_SavedVars:NewAccountWide('PoisonMaster', 1.0, nil, AccountDefaults)
	ZO_CreateStringId('SI_BINDING_NAME_TOGGLE_POISON_WINDOW', L.PMAddon_KBT)
	ZO_CreateStringId('SI_BINDING_NAME_POISON_SLOT_1', L.PMAddon_KB1)
	ZO_CreateStringId('SI_BINDING_NAME_POISON_SLOT_2', L.PMAddon_KB2)
	ZO_CreateStringId('SI_BINDING_NAME_POISON_SLOT_3', L.PMAddon_KB3)
	ZO_CreateStringId('SI_BINDING_NAME_POISON_SLOT_4', L.PMAddon_KB4)
	CreateSettingsWindow(addonName)
	HookInventory()
	InitControls()
end

SLASH_COMMANDS['/poison'] = ShowMain
EVENT_MANAGER:RegisterForEvent('PoisonMaster', EVENT_ADD_ON_LOADED, OnAddonLoaded)
EVENT_MANAGER:RegisterForEvent('PoisonMaster', EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnUpdate)
EVENT_MANAGER:RegisterForEvent('PoisonMaster', EVENT_ACTION_SLOTS_FULL_UPDATE, OnSwap)
EVENT_MANAGER:RegisterForEvent('PoisonMaster', EVENT_PLAYER_ACTIVATED, Init)
