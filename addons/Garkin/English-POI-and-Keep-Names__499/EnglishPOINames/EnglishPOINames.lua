-------------------------------------------------------------------------------
-- English POI and Keep Names v8
-------------------------------------------------------------------------------
--
-- Copyright (c) 2014, 2020 Ales Machat (Garkin)
--
-- Permission is hereby granted, free of charge, to any person
-- obtaining a copy of this software and associated documentation
-- files (the "Software"), to deal in the Software without
-- restriction, including without limitation the rights to use,
-- copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the
-- Software is furnished to do so, subject to the following
-- conditions:
--
-- The above copyright notice and this permission notice shall be
-- included in all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
-- OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
-- NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
-- HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
-- WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
-- OTHER DEALINGS IN THE SOFTWARE.
--
-------------------------------------------------------------------------------
-- Local variables ------------------------------------------------------------
local ADDON_VERSION = "8"
local ADDON_NAME = "EnglishPOINames"
local ADDON_WEBSITE = "http://www.esoui.com/downloads/info499-EnglishPOIandKeepNames.html"
local db
local defaults = {
	colorKeep = STAT_BATTLE_LEVEL_COLOR:ToHex(),
	colorPOI = ZO_HIGHLIGHT_TEXT:ToHex(),
	newLine = true,
	hideAlliance = false,
	needUpdateData = false,
	Data = {
--		APIVersion = 0,
		POI = {},
		Keep = {},
		Shrine = {}
	}
}
local POI_COLOR, KEEP_COLOR, INFORMATION_TOOLTIP


-- Name operators -------------------------------------------------------------
-- POI
local function GetEnglishPOIName(zoneId, poiIndex)
	local fullId = ""
	if db.Data.POI[zoneId] then
		return db.Data.POI[zoneId][poiIndex] or fullId
	end
	return fullId
end

local function SetEnglishPOIName(zoneId, poiIndex, name)
	if db.Data.POI[zoneId] == nil then
		db.Data.POI[zoneId] = {}
	end
	db.Data.POI[zoneId][poiIndex] = name
end

-- Shrines
local function GetEnglishShrineName(nodeIndex)
	return db.Data.Shrine[nodeIndex]
end

local function SetEnglishShrineName(nodeIndex, name)
	db.Data.Shrine[nodeIndex] = name
end

-- Keeps
local function GetEnglishKeepName(keepId)
	return db.Data.Keep[keepId]
end

local function SetEnglishKeepName(keepId, name)
	db.Data.Keep[keepId] = name
end

-- Hooks ----------------------------------------------------------------------
-- POI
local function HookPoiTooltips()
	local function AddEnglishName(pin)
		local poiIndex = pin:GetPOIIndex()
		local zoneId = GetZoneId(pin:GetPOIZoneIndex())
		local localizedName = ZO_WorldMapMouseoverName:GetText()
		local englishName = GetEnglishPOIName(zoneId, poiIndex)
		local locString = zo_strformat("<<1>>\n<<2>>", localizedName, POI_COLOR:Colorize(englishName))
		ZO_WorldMapMouseoverName:SetText(locString)
	end

	-- hook functions
	local CreatorPOISeen = ZO_MapPin.TOOLTIP_CREATORS[MAP_PIN_TYPE_POI_SEEN].creator
	ZO_MapPin.TOOLTIP_CREATORS[MAP_PIN_TYPE_POI_SEEN].creator = function(...)
		CreatorPOISeen(...) --original tooltip creator
		AddEnglishName(...)
	end
	local CreatorPOIComplete = ZO_MapPin.TOOLTIP_CREATORS[MAP_PIN_TYPE_POI_COMPLETE].creator
	ZO_MapPin.TOOLTIP_CREATORS[MAP_PIN_TYPE_POI_COMPLETE].creator = function(...)
		CreatorPOIComplete(...) --original tooltip creator
		AddEnglishName(...)
	end
end

-- Shrines
local function hookWayShrineTootltips()
	local function addWayShrineName(pin)
		local localizedName = ZO_WorldMapMouseoverName:GetText()
		local nodeIndex = pin:GetFastTravelNodeIndex()
		local englishName = GetEnglishShrineName(nodeIndex)
		local locString = zo_strformat("<<1>>\n<<2>>", localizedName, POI_COLOR:Colorize(englishName))
		ZO_WorldMapMouseoverName:SetText(locString)
	end

	local creatorFTWS = ZO_MapPin.TOOLTIP_CREATORS[MAP_PIN_TYPE_FAST_TRAVEL_WAYSHRINE].creator
	ZO_MapPin.TOOLTIP_CREATORS[MAP_PIN_TYPE_FAST_TRAVEL_WAYSHRINE].creator = function(...)
		creatorFTWS(...)--inherited constructor
		addWayShrineName(...)
	end

	-- Hacking [MAP_PIN_TYPE_FAST_TRAVEL_WAYSHRINE_CURRENT_LOC].creator
	-- seems to be useless as previous one already does the job
end

-- Keeps ----------------------------------------------------------------------
local function HookKeepTooltips()
	local function AnchorTo(control, anchorTo)
		local isValid, point, _, relPoint, offsetX, offsetY = control:GetAnchor(0)
		if isValid then
			control:ClearAnchors()
			control:SetAnchor(point, anchorTo, relPoint, offsetX, offsetY)
		end
	end
	local function ModifyKeepTooltip(self, keepId)
		local keepName = GetKeepName(keepId)
		local englishKeepName = GetEnglishKeepName(keepId)
		local nameLabel = self:GetNamedChild("Name")
		local allianceLabel, guildLabel, englishLabel, lineHeight
		if self.lastLine and nameLabel then
			local lastLine = self.lastLine
			local previousLine
			while lastLine or lastLine ~= nameLabel do
				local anchoredTo = select(3,lastLine:GetAnchor(0))
				if anchoredTo == nameLabel then
					allianceLabel = lastLine
					guildLabel = previousLine
					break
				end
				previousLine = lastLine
				lastLine = anchoredTo
			end
		end
		if englishKeepName and db.newLine then
			englishLabel = self.linePool:AcquireObject()
			englishLabel:SetHidden(false)
			englishLabel:SetText(KEEP_COLOR:Colorize(englishKeepName))
			englishLabel:SetAnchor(TOPLEFT, nameLabel, BOTTOMLEFT, 0, 3)
			lineHeight = englishLabel:GetHeight()
			if db.hideAlliance and allianceLabel then
				allianceLabel:SetHidden(true)
				if guildLabel then
					AnchorTo(guildLabel, englishLabel)
				end
			elseif allianceLabel then
				AnchorTo(allianceLabel, englishLabel)
				self.height = self.height + lineHeight + 3
			else
				self.height = self.height + lineHeight + 3
			end
			local width = englishLabel:GetTextWidth() + 16
			if width > self.width then
				self.width = width
			end
		elseif englishKeepName then
			nameLabel:SetText(zo_strformat("<<1>> (<<2>>)", keepName, KEEP_COLOR:Colorize(englishKeepName)))
			local width = nameLabel:GetTextWidth() + 16
			if width > self.width then
				self.width = width
			end
		end
		if db.hideAlliance and allianceLabel and not englishLabel then
			lineHeight = allianceLabel:GetHeight()
			allianceLabel:SetHidden(true)
			if guildLabel then
				AnchorTo(guildLabel, nameLabel)
			end
			self.height = self.height - lineHeight - 3
		end
		self:SetDimensions(self.width, self.height)
	end

	-- hook functions
	local SetKeep = ZO_KeepTooltip.SetKeep
	ZO_KeepTooltip.SetKeep = function(self, keepId, ...)
		SetKeep(self, keepId, ...) --original function
		ModifyKeepTooltip(self, keepId)
	end
	local RefreshKeep = ZO_KeepTooltip.RefreshKeepInfo
	ZO_KeepTooltip.RefreshKeepInfo = function(self, ...)
		RefreshKeep(self, ...)  --original function
		if(self.keepId and self.battlegroundContext and self.historyPercent) then
			ModifyKeepTooltip(self, self.keepId)
		end
	end

	local mystyle = { fontSize = 34, fontColorField = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_1, }
	local function AddInfo_Gamepad(tooltip, itemLink)
		if itemLink then
			tooltip:AddLine("Whatever text you want to add", mystyle, tooltip:GetStyle("bodySection"))
		end
	end
	local function TooltipHook_Gamepad(tooltipControl, method, linkFunc)
		local origMethod = tooltipControl[method]
		tooltipControl[method] = function(self, ...)
			origMethod(self, ...)
			AddInfo_Gamepad(self, linkFunc(...))
		end
	end

	-- This helper function is just there in case the position of the item-link will change
	local function ReturnItemLink(itemLink)
		return itemLink
	end
	
	local function HookBagTips()
		TooltipHook_Gamepad(GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_RIGHT_TOOLTIP), "SetKeep", ReturnItemLink)
	end	

end

-- Gamepad Switch -------------------------------------------------------------
local function OnGamepadPreferredModeChanged()
	if IsInGamepadPreferredMode() then
		INFORMATION_TOOLTIP = ZO_MapLocationTooltip_Gamepad
	else
		INFORMATION_TOOLTIP = InformationTooltip
	end
end


-- Auto Update -------------------------------------------------------------
local function UpdatePOIs()
	local zoneNumber = GetNumZones()
	for zoneIndex = 1, zoneNumber do
		local zoneId = GetZoneId(zoneIndex)
		local poiNumber = GetNumPOIs(zoneIndex)
		for poiIndex = 1, poiNumber do
			local poiName = GetPOIInfo(zoneIndex, poiIndex)
			if poiName ~= nil and poiName ~= '' then
				SetEnglishPOIName(zoneId, poiIndex, poiName)
			end
		end
	end
end

local function UpdateShrines()
	local fastTravelNodesCount = GetNumFastTravelNodes();
	for fastTravelNodeIndex = 1, fastTravelNodesCount do
		local _, name = GetFastTravelNodeInfo(fastTravelNodeIndex)
		if name ~= nil and name ~= '' then
			SetEnglishShrineName(fastTravelNodeIndex, name)
		end
	end
end

local function UpdateKeeps()
	local keepCount = GetNumKeeps()
	for keepIndex = 1, keepCount do
		local keepId = GetKeepKeysByIndex(keepIndex)
		local name = GetKeepName(keepId)
		if name ~= nil and name ~= '' then
			SetEnglishKeepName(keepId, name)
		end
	end
end

local function Update()
	if db.needUpdateData then
		UpdatePOIs()
		UpdateShrines()
		UpdateKeeps()

		db.needUpdateData = false

		local language = db.currentLanguage
		db.currentLanguage = ''
		SetCVar("language.2", language)
	end
end

-- Addon Settings Menu --------------------------------------------------------
local function CreateAddonMenu()
	local lib = LibAddonMenu2
	local panelData = {
		type = "panel",
		name = GetString(POINAMES_TITLE_SHORT),
		displayName = "|cFFFFB0" .. GetString(POINAMES_TITLE) .. "|r",
		author = "Garkin & Ayantir",
		version = ADDON_VERSION,
		slashCommand = "/poi",
		registerForRefresh = true,
		registerForDefaults = true,
		website = ADDON_WEBSITE,
	}
	lib:RegisterAddonPanel(ADDON_NAME, panelData)
	local optionsTable = {
		{
			type = "colorpicker",
			name = GetString(POINAMES_POI_COL),
			tooltip = GetString(POINAMES_POI_COL_DESC),
			getFunc = function() return POI_COLOR:UnpackRGBA() end,
			setFunc = function(...)
					POI_COLOR:SetRGBA(...)
					db.colorPOI = POI_COLOR:ToHex()
				end,
			width = "full",
			default = ZO_HIGHLIGHT_TEXT,
		},
		{
			type = "colorpicker",
			name = GetString(POINAMES_KEEP_COL),
			tooltip = GetString(POINAMES_KEEP_COL_DESC),
			getFunc = function() return KEEP_COLOR:UnpackRGBA() end,
			setFunc = function(...)
					KEEP_COLOR:SetRGBA(...)
					db.colorKeep = KEEP_COLOR:ToHex()
				end,
			width = "full",
			default = STAT_DIMINISHING_RETURNS_COLOR,
		},
		{
			type = "checkbox",
			name = GetString(POINAMES_HIDE_ALLI),
			tooltip = GetString(POINAMES_HIDE_ALLI_DESC),
			getFunc = function() return db.hideAlliance end,
			setFunc = function(value) db.hideAlliance = value end,
			width = "full",
			default = defaults.hideAlliance
		},
		{
			type = "checkbox",
			name = GetString(POINAMES_NEW_LIN),
			tooltip = GetString(POINAMES_NEW_LIN_DESC),
			getFunc = function() return db.newLine end,
			setFunc = function(value) db.newLine = value end,
			width = "full",
			default = defaults.newLine
		},
		{
			type = "button",
			name = GetString(POINAMES_UPDATE_DATA),
			tooltip = GetString(POINAMES_UPDATE_DATA_DESC),
			func = function()
				db.needUpdateData = true
				db.currentLanguage = GetCVar("language.2")
				SetCVar("language.2", "en")
			end,
			width = "full",
		}
	}
	lib:RegisterOptionControls(ADDON_NAME, optionsTable)
end
-- Initialization -------------------------------------------------------------

local function OnActivated(event)
	Update()

	if GetCVar("language.2") == "en" then
		CHAT_SYSTEM:AddMessage(ZO_HIGHLIGHT_TEXT:Colorize("English POI and Keep Names ") .. ZO_ERROR_COLOR:Colorize("disabled"))
	end

	EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, event)
end

local function OnLoad(eventCode, addonName)

	if addonName == ADDON_NAME then
		EVENT_MANAGER:RegisterForEvent(addonName, EVENT_PLAYER_ACTIVATED, OnActivated)

		db = ZO_SavedVars:NewAccountWide("POINAMES_SavedVariables", 1, settings, defaults)

		if not (db.Data.POI[347]) then -- Using Kenarthi as "should exist"
			db.needUpdateData = true
			db.currentLanguage = GetCVar("language.2")
			SetCVar("language.2", "en")
		end
		
                if GetCVar("language.2") == "en" then
			return                                                                                                                      
		end

		POI_COLOR = ZO_ColorDef:New(db.colorPOI)
		KEEP_COLOR = ZO_ColorDef:New(db.colorKeep)
		
		HookPoiTooltips()
		HookKeepTooltips()
		hookWayShrineTootltips()
		CreateAddonMenu()
		OnGamepadPreferredModeChanged()
		
		EVENT_MANAGER:UnregisterForEvent(addonName, eventCode)
		EVENT_MANAGER:RegisterForEvent(addonName, EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, OnGamepadPreferredModeChanged)
		
	end
	
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnLoad)
