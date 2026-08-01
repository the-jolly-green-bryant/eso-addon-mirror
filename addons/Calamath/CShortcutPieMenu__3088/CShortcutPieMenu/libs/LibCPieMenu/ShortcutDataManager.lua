--
-- CPieMenuManager [LCPM] : (LibCPieMenu)
--
-- Copyright (c) 2022 Calamath
--
-- This software is released under the Artistic License 2.0
-- https://opensource.org/licenses/Artistic-2.0
--

if not LibCPieMenu then return end
local LCPM = LibCPieMenu:SetSharedEnvironment()
-- ---------------------------------------------------------------------------------------
local L = GetString

-- ---------------------------------------------------------------------------------------
-- Shortcut Data Manager Class
-- ---------------------------------------------------------------------------------------
local LCPM_ShortcutDataManager_Singleton = ZO_InitializingObject:Subclass()
function LCPM_ShortcutDataManager_Singleton:Initialize()
	self.name = "LCPM_ShortcutDataManager"
	self.shortcutList = {}
	self.externalShortcutCategory = {}
	self.externalShortcutCategoryList = {}
	self:RegisterInternalShortcuts()
end

function LCPM_ShortcutDataManager_Singleton:RegisterInternalShortcuts()
	self.shortcutList["!LCPM_invalid_slot"] = {
		name = L(SI_QUICKSLOTS_EMPTY), 
		icon = "EsoUI/Art/Quickslots/quickslot_emptySlot.dds", 
		callback = function() return end, 
		category = CATEGORY_NOTHING, 
		showSlotLabel = false, 
	}
	self.shortcutList["!LCPM_cancel_slot"] = {
		name = L(SI_RADIAL_MENU_CANCEL_BUTTON), 
		icon = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_cancel_down.dds", 
		callback = function() return end, 
		category = CATEGORY_NOTHING, 
		showSlotLabel = false, 
	}
end

function LCPM_ShortcutDataManager_Singleton:IsExternalShortcutCategory(categoryId)
	return type(categoryId) == "string" and self.externalShortcutCategory[categoryId]
end

function LCPM_ShortcutDataManager_Singleton:GetShortcutData(shortcutId)
	return self.shortcutList[shortcutId]
end

function LCPM_ShortcutDataManager_Singleton:GetShortcutInfo(shortcutDataOrId)
	local shortcutData = type(shortcutDataOrId) == "table" and shortcutDataOrId or self:GetShortcutData(shortcutDataOrId) or {}
	return GetValue(shortcutData.name), GetValue(shortcutData.tooltip), GetValue(shortcutData.icon), shortcutData.callback, GetValue(shortcutData.nameColor)
end

function LCPM_ShortcutDataManager_Singleton:EncodeMenuEntry(shortcutDataOrId, desiredIndex)
	local shortcutData = type(shortcutDataOrId) == "table" and shortcutDataOrId or self:GetShortcutData(shortcutDataOrId) or {}
	local data = {
		index = desiredIndex or shortcutData.index or 1, 
		showIconFrame = GetValue(shortcutData.showIconFrame), 
		showSlotLabel = GetValue(shortcutData.showSlotLabel), 
		showGlow = GetValue(shortcutData.showGlow), 
		itemCount = GetValue(shortcutData.itemCount), 
		name = GetValue(shortcutData.name) or "", 
		nameColor = GetValue(shortcutData.nameColor), 
		tooltip = GetValue(shortcutData.tooltip), 
		icon = GetValue(shortcutData.icon) or "EsoUI/Art/Icons/crafting_dwemer_shiny_gear.dds", 
		iconAttributes = GetValue(shortcutData.iconAttributes), 
		resizeIconToFitFile = GetValue(shortcutData.resizeIconToFitFile), 
		callback = shortcutData.callback or function() end, 
		statusIcon = GetValue(shortcutData.statusIcon), 
		activeStatusIcon = GetValue(shortcutData.activeStatusIcon), 
		cooldownRemaining = GetValue(shortcutData.cooldownRemaining), 
		cooldownDuration = GetValue(shortcutData.cooldownDuration), 
		disabled = GetValue(shortcutData.disabled), 
		slotData = {}, 
		category = shortcutData.category, 
	}
	data.activeIcon = GetValue(shortcutData.activeIcon) or data.icon
	if data.disabled == true then
		data.nameColor = UI_Color.BLOCKED	-- red color-coded
		data.activeIcon = data.icon					-- not using activeIcon
	end
	return data
end

function LCPM_ShortcutDataManager_Singleton:GetShortcutCategoryList()
	return self.externalShortcutCategoryList
end

function LCPM_ShortcutDataManager_Singleton:GetShortcutListByCategory(categoryId)
	local list = {}
	for k, v in pairs(self.shortcutList) do
		if v.category == categoryId then
			list[#list + 1] = k
		end
	end
	return list
end

function LCPM_ShortcutDataManager_Singleton:RegisterShortcutData(shortcutId, shortcutData)
	if not shortcutId or type(shortcutData) ~= "table" or self.shortcutList[shortcutId] then
		return false
	else
		self.shortcutList[shortcutId] = shortcutData
		local categoryId = GetValue(shortcutData.category)
		if type(categoryId) == "string" then
			if not self.externalShortcutCategory[categoryId] then
				self.externalShortcutCategory[categoryId] = true
				table.insert(self.externalShortcutCategoryList, categoryId)
			end
		end
		LCPM.LDL:Debug("ShortcutRegistered : %s (%s)", shortcutId, self.shortcutList[shortcutId].category)
		LCPM:FireCallbacks("LCPM-ShortcutRegistered", shortcutId, self.shortcutList[shortcutId].category)
		return true
	end
end

function LCPM_ShortcutDataManager_Singleton:RegisterExternalShortcutData(shortcutId, shortcutData)
	if type(shortcutId) ~= "string" or zo_strsub(shortcutId, 1, 1) == "!" then
		return false
	else
		return self:RegisterShortcutData(shortcutId, shortcutData)
	end
end

-- ---------------------------------------------------------------------------------------

local LCPM_SHORTCUT_DATA_MANAGER = LCPM_ShortcutDataManager_Singleton:New()	-- Never do this more than once!

-- global API --
local function GetShortcutDataManager() return LCPM_SHORTCUT_DATA_MANAGER end
LCPM:RegisterSharedObject("GetShortcutDataManager", GetShortcutDataManager)

local function GetShortcutData(shortcutId) return LCPM_SHORTCUT_DATA_MANAGER:GetShortcutData(shortcutId) end
LCPM:RegisterSharedObject("GetShortcutData", GetShortcutData)

local function GetShortcutInfo(shortcutDataOrId) return LCPM_SHORTCUT_DATA_MANAGER:GetShortcutInfo(shortcutDataOrId) end
LCPM:RegisterSharedObject("GetShortcutInfo", GetShortcutInfo)

