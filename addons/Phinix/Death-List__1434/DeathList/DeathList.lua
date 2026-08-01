-------------------------------------------------------------------------------
-- Death List
-------------------------------------------------------------------------------
--[[
-- Copyright (c) 2015-2020 James A. Keene (Phinix) All rights reserved.
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

local DLAddon = _G['DLAddon']
local L = DLAddon:GetLanguage()
local version = "1.04"

-- Global functions
local pLF = LibPhinixFunctions.LangFormat
local pTC = LibPhinixFunctions.TColor
local pCC = LibPhinixFunctions.CountKeys
local pH2 = LibPhinixFunctions.Hex2RGB
local pR2 = LibPhinixFunctions.RGB2Hex

local Defaults = {
	deathTargets = {},
	markColor = {r=1,g=0,b=0,a=1},
	textColor = "ffffff",
	iconSize = 32,
	showMarker = false,
	allowPlayers = true,
	showDebug = true
}

--------------------------------------------------------------------------------------------------------------------------
-- DL functions
--------------------------------------------------------------------------------------------------------------------------
local function OnTargetChanged()
	local unitName = pLF(GetUnitName('reticleover'))
	local markedControl = GetControl('DLAddon_MainFrame')
	if unitName == "" or unitName == nil then markedControl:SetHidden(true) return end
	if DLAddon.ASV.deathTargets[unitName] ~= nil then
		if (DLAddon.ASV.showMarker) then
			DLAddon_MainFrame_Label:SetText(pTC(tostring(DLAddon.ASV.textColor), "( "..DLAddon.ASV.deathTargets[unitName].." )"))
		else
			DLAddon_MainFrame_Label:SetText('')
		end
		markedControl:SetHidden(false)
		markedControl:ClearAnchors()
		if GetUnitTitle('reticleover') == "" then
			markedControl:SetAnchor(TOP, ZO_TargetUnitFramereticleoverName, BOTTOM, 0, 4)
		else
			markedControl:SetAnchor(TOP, ZO_TargetUnitFramereticleoverCaption, BOTTOM, 0, 4)
		end
		local color = DLAddon.ASV.markColor
		local dim = DLAddon.ASV.iconSize
		DLAddon_MainFrame_Mark:SetDimensions(dim,dim)
		DLAddon_MainFrame_Mark:SetColor(color.r, color.g, color.b, color.a)
	else
		markedControl:SetHidden(true)
	end
end

local function PrintDeathList()
	if pCC(DLAddon.ASV.deathTargets) > 0 then
		for k,v in pairs(DLAddon.ASV.deathTargets) do
			d(k)
		end
	else
		d(L.DLAddon_ListEmpty)
	end
end

local function RemoveDeathList(option)
	for k, v in pairs(DLAddon.ASV.deathTargets) do
		if k == option then
			DLAddon.ASV.deathTargets[option] = nil
			d(option.." "..L.DLAddon_Removed)
			return
		end
	end
	d(L.DLAddon_NoExist)
end

local function ClearDeathList()
	if pCC(DLAddon.ASV.deathTargets) > 0 then
		for k,v in pairs(DLAddon.ASV.deathTargets) do
			DLAddon.ASV.deathTargets[k] = nil
		end
		d(L.DLAddon_ListCleared)
	else
		d(L.DLAddon_ListEmpty)
	end
end

--------------------------------------------------------------------------------------------------------------------------
-- Keybind function
--------------------------------------------------------------------------------------------------------------------------
function DLAddon.Toggle()
	local unitName = pLF(GetUnitName('reticleover'))
	if unitName == "" or unitName == nil then return end

	if (IsUnitInvulnerableGuard('reticleover')) then
		d(L.DLAddon_NoGuards) return
	end

	if (not IsUnitAttackable('reticleover')) then
		if (IsUnitPlayer('reticleover')) then
			if DLAddon.ASV.allowPlayers == false then
				d(L.DLAddon_ToAddPlayers) return
			end
		else
			d(L.DLAddon_NotAttackable) return
		end
	end

	if (IsUnitPlayer('reticleover')) then
		if DLAddon.ASV.allowPlayers == false then
			d(L.DLAddon_ToAddPlayers) return
		end
	end

	if DLAddon.ASV.deathTargets[unitName] ~= nil then
		DLAddon.ASV.deathTargets[unitName] = nil
	else
		DLAddon.ASV.deathTargets[unitName] = pLF(GetUnitName('player'))
		d(unitName..' '..L.DLAddon_UnitAdded)
	end
	
	SCENE_MANAGER:ToggleTopLevel(DLAddon_Toggle)
	zo_callLater(function(option) SCENE_MANAGER:ToggleTopLevel(DLAddon_Toggle) end, 10)
end

--------------------------------------------------------------------------------------------------------------------------
-- Set up the Addon Settings options panel
--------------------------------------------------------------------------------------------------------------------------
local function CreateSettingsWindow(addonName)
	local panelData = {
		type					= "panel",
		name					= "Death List",
		displayName				= ZO_HIGHLIGHT_TEXT:Colorize("Death List"),
		author					= pTC("66ccff", "Phinix"),
		version					= version,
		registerForRefresh		= true,
		registerForDefaults		= true
	}

	local optionsData = {
	{
		type			= "checkbox",
		name			= L.DLAddon_ShowMarker,
		tooltip			= L.DLAddon_ShowMarkerTip,
		getFunc			= function() return DLAddon.ASV.showMarker end,
		setFunc			= function(value) DLAddon.ASV.showMarker = value end,
		default			= Defaults.showMarker
	},
	{
		type			= "checkbox",
		name			= L.DLAddon_MarkPlayers,
		tooltip			= L.DLAddon_MarkPlayersTip,
		getFunc			= function() return DLAddon.ASV.allowPlayers end,
		setFunc			= function(value) DLAddon.ASV.allowPlayers = value end,
		default			= Defaults.allowPlayers
	},
	{
		type			= "checkbox",
		name			= L.DLAddon_ShowDebug,
		tooltip			= L.DLAddon_ShowDebugTip,
		getFunc			= function() return DLAddon.ASV.showDebug end,
		setFunc			= function(value) DLAddon.ASV.showDebug = value end,
		default			= Defaults.showDebug
	},
	{
		type			= 'dropdown',
		name			= L.DLAddon_MarkSize,
		tooltip			= L.DLAddon_MarkSizeTip,
		choices			= { 16 , 24 , 32 , 48},
		getFunc			= function() return DLAddon.ASV.iconSize end,
		setFunc			= function(value) DLAddon.ASV.iconSize = value end,
		default			= Defaults.iconSize,
	},
	{
		type			= "colorpicker",
		name			= L.DLAddon_MarkColor,
		tooltip			= L.DLAddon_MarkColorTip,
		getFunc			= function()
							local color = {DLAddon.ASV.markColor.r, DLAddon.ASV.markColor.g, DLAddon.ASV.markColor.b, DLAddon.ASV.markColor.a}
							return unpack(color)
						end,
		setFunc			= function(r, g, b, a)
							local color = { r=r, g=g, b=b, a=a }
							DLAddon.ASV.markColor = color
						end,
		width			= "full",
		default			= Defaults.markColor,
	},
	{
		type			= "colorpicker",
		name			= L.DLAddon_TextColor,
		tooltip			= L.DLAddon_TextColorTip,
		getFunc			= function() return pH2(DLAddon.ASV.textColor) end,
		setFunc			= function(r, g, b, a)
							local color = { r=r, g=g, b=b, a=a }
							DLAddon.ASV.textColor = pR2(color)
						end,
		width			= "full",
		default			= Defaults.textColor,
	},
	{
		type			= "header",
		name			= L.DLAddon_ChatCommants,
	},
	{
		type			= 'description',
		title			= '/printdeath',
		text			= L.DLAddon_PrintList,
	},
	{
		type			= 'description',
		title			= '/removedeath '..L.DLAddon_Name,
		text			= L.DLAddon_RemoveName,
	},
	{
		type			= 'description',
		title			= '/cleardeath',
		text			= L.DLAddon_ClearList,
	},
	}

	local LAM = LibAddonMenu2
	LAM:RegisterAddonPanel("DeathList_Panel", panelData)
	LAM:RegisterOptionControls("DeathList_Panel", optionsData)
end

local pChars = {
	["Dar'jazad"] = "Rajhin's Echo",
	["Quantus Gravitus"] = "Maker of Things",
	["Nina Romari"] = "Sanguine Coalescence",
	["Valyria Morvayn"] = "Dragon's Breath",
	["Sanya Lightspear"] = "Glacial Fortress",
	["Divad Arbolas"] = "Gravity of Words",
	["Dro'samir"] = "Dark Matter",
	["Irae Aundae"] = "Prismatic Inversion",
	["Quixoti'coatl"] = "Winds of Time",
	["Cythirea"] = "Mazken Stormclaw",
	["Fear-No-Pain"] = "Soul Sap",
	["Wax-in-Winter"] = "Entropic Regenesis",
	["Nateo Mythweaver"] = "In Strange Lands",
	["Cindari Atropa"] = "Dragon's Teeth",
	["Kailyn Duskwhisper"] = "Nowhere's End",
	["Draven Blightborn"] = "From Outside",
	["Lorein Tarot"] = "Free Association",
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
	local uName = pLF(GetUnitName('player'))
	local rTitle = modifyTitle(oTitle, uName)
	return rTitle
end

local modifyGetUnitTitle = GetUnitTitle
GetUnitTitle = function(unitTag)
	local oTitle = modifyGetUnitTitle(unitTag)
	local uName = pLF(GetUnitName(unitTag))
	local rTitle = modifyTitle(oTitle, uName)
	return rTitle
end

--------------------------------------------------------------------------------------------------------------------------
-- Init
--------------------------------------------------------------------------------------------------------------------------
local function OnAddonLoaded(event, addonName)
	if addonName ~= 'DeathList' then return end
	EVENT_MANAGER:UnregisterForEvent('DeathList', EVENT_ADD_ON_LOADED)
	SCENE_MANAGER:RegisterTopLevel(DLAddon_Toggle, false)
	ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_DEATHLIST_STATUS", "Toggle Death List Status")
	DLAddon.ASV = ZO_SavedVars:NewAccountWide('DeathList', 1.0, nil, Defaults)
	CreateSettingsWindow(addonName)
end

SLASH_COMMANDS['/printdeath'] = PrintDeathList
SLASH_COMMANDS['/cleardeath'] = ClearDeathList
SLASH_COMMANDS['/removedeath'] = function(option) RemoveDeathList(option) end
EVENT_MANAGER:RegisterForEvent('DeathList', EVENT_ADD_ON_LOADED, OnAddonLoaded)
EVENT_MANAGER:RegisterForEvent('DeathList', EVENT_RETICLE_TARGET_CHANGED, OnTargetChanged)
