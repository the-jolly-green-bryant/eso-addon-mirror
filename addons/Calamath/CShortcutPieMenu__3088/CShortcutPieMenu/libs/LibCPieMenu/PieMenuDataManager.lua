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
-- Pie Menu Data Manager Class
-- ---------------------------------------------------------------------------------------
local LCPM_PieMenuDataManager_Singleton = ZO_InitializingObject:Subclass()
function LCPM_PieMenuDataManager_Singleton:Initialize()
	self.name = "LCPM_PieMenuDataManager"
	self.pieMenuList = {}
	self.userPieMenuList = {}
	self.isUserPieMenuAvailable = false
end

function LCPM_PieMenuDataManager_Singleton:RegisterUserPieMenuPresetTable(userPieMenuPresetTable)
	if self.isUserPieMenuAvailable or type(userPieMenuPresetTable) ~= "table" then
		return false
	else
		self.userPieMenuList = userPieMenuPresetTable
		self.isUserPieMenuAvailable  = true
		return true
	end
end

function LCPM_PieMenuDataManager_Singleton:IsUserPieMenu(presetId)
	return type(presetId) == "number"
end

function LCPM_PieMenuDataManager_Singleton:IsExternalPieMenu(presetId)
	return type(presetId) == "string"
end

function LCPM_PieMenuDataManager_Singleton:DoesPieMenuDataExist(presetId)
	return self.pieMenuList[presetId] ~= nil or self.userPieMenuList[presetId] ~= nil
end

function LCPM_PieMenuDataManager_Singleton:GetPieMenuData(presetId)
	return self:IsUserPieMenu(presetId) and self.userPieMenuList[presetId] or self.pieMenuList[presetId]
end

function LCPM_PieMenuDataManager_Singleton:GetPieMenuInfo(pieMenuDataOrPresetId)
	local pieMenuData = type(pieMenuDataOrPresetId) == "table" and pieMenuDataOrPresetId or self:GetPieMenuData(pieMenuDataOrPresetId) or {}
	return GetValue(pieMenuData.name), GetValue(pieMenuData.tooltip), GetValue(pieMenuData.icon)
end

--[[
function LCPM_PieMenuDataManager_Singleton:GetUserPieMenuList()
	local idList = {}
	for presetId, _ in pairs(self.userPieMenuList) do
		if self:IsUserPieMenu(presetId) then
			table.insert(idList, presetId)
		end
	end
	return list
end
]]

function LCPM_PieMenuDataManager_Singleton:GetExternalPieMenuPresetIdList()
	local idList = {}
	for presetId, pieMenuData in pairs(self.pieMenuList) do
		if self:IsExternalPieMenu(presetId) and not pieMenuData.hidden then
			table.insert(idList, presetId)
		end
	end
	return idList
end

function LCPM_PieMenuDataManager_Singleton:RegisterPieMenu(presetId, pieMenuData)
	if not presetId or type(pieMenuData) ~= "table" or self.pieMenuList[presetId] then
		return false
	else
		self.pieMenuList[presetId] = pieMenuData
		LCPM:FireCallbacks("LCPM-PieMenuRegistered", presetId)
		return true
	end
end

function LCPM_PieMenuDataManager_Singleton:RegisterExternalPieMenu(presetId, pieMenuData)
	if type(presetId) ~= "string" or zo_strsub(presetId, 1, 1) == "!" then
		return false
	else
		return self:RegisterPieMenu(presetId, pieMenuData)
	end
end

-- ---------------------------------------------------------------------------------------

local LCPM_PIE_MENU_DATA_MANAGER = LCPM_PieMenuDataManager_Singleton:New()	-- Never do this more than once!

-- global API --
local function GetPieMenuDataManager() return LCPM_PIE_MENU_DATA_MANAGER end
LCPM:RegisterSharedObject("GetPieMenuDataManager", GetPieMenuDataManager)

local function IsUserPieMenu(presetId) return LCPM_PIE_MENU_DATA_MANAGER:IsUserPieMenu(presetId) end
LCPM:RegisterSharedObject("IsUserPieMenu", IsUserPieMenu)

local function IsExternalPieMenu(presetId) return LCPM_PIE_MENU_DATA_MANAGER:IsExternalPieMenu(presetId) end
LCPM:RegisterSharedObject("IsExternalPieMenu", IsExternalPieMenu)

local function DoesPieMenuDataExist(presetId) return LCPM_PIE_MENU_DATA_MANAGER:DoesPieMenuDataExist(presetId) end
LCPM:RegisterSharedObject("DoesPieMenuDataExist", DoesPieMenuDataExist)

local function GetPieMenuData(presetId) return LCPM_PIE_MENU_DATA_MANAGER:GetPieMenuData(presetId) end
LCPM:RegisterSharedObject("GetPieMenuData", GetPieMenuData)

local function GetPieMenuInfo(pieMenuDataOrPresetId) return LCPM_PIE_MENU_DATA_MANAGER:GetPieMenuInfo(pieMenuDataOrPresetId) end
LCPM:RegisterSharedObject("GetPieMenuInfo", GetPieMenuInfo)

