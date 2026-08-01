-------------------------------------------------------------------------------
-- Dungeon Champions v1.0.16
-------------------------------------------------------------------------------
--
-- Updated by @Gadget's 2021, 2022
--
-- Update and Changers for Dungeon Champions by Scott123 2022
-- The Changes are in Copyright by MerlinGer
--
-- Copyright (c) 2014, 2015 Ales Machat (Garkin)
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

--Libraries--------------------------------------------------------------------
local LAM = LibAddonMenu2
local LMP = LibMapPins

--Local constants -------------------------------------------------------------
local ADDON_NAME = "DungeonChampions"
local ADDON_VERSION = "1.0.16"
local PINS_UNKNOWN = "DCSMapPin_unknown"
local PINS_COLLECTED = "DCSMapPin_collected"
local PINS_COMPASS_UNKNOWN = "DCSCompassPin_unknown"
local PINS_COMPASS_KNOWN = "DCSCompassPin_known"


--Local variables -------------------------------------------------------------
local updatePins = {}
local updating = false
local savedVariables
local INFORMATION_TOOLTIP

local defaults = {         -- default settings for saved variables
   compassMaxDistance = 0.05,
   pinTexture = {
      type = 1,
      size = 38,
      level = 40,
   },
   completeColor = { 0, 1, 0, .70 },
   incompleteColor = { 1, 0, 0, .70 }, 
   filters = {
      [PINS_COMPASS_UNKNOWN] = true,
      [PINS_COMPASS_KNOWN] = true,
      [PINS_UNKNOWN] = true,
      [PINS_COLLECTED] = true,
   },
}

-- Local functions ------------------------------------------------------------
local function MyPrint(...)
   CHAT_SYSTEM:AddMessage(...)
end

-- Gamepad Switch -------------------------------------------------------------
local function OnGamepadPreferredModeChanged()
    if IsInGamepadPreferredMode() then
        INFORMATION_TOOLTIP = ZO_MapLocationTooltip_Gamepad
    else
        INFORMATION_TOOLTIP = InformationTooltip
    end
end

-- Pins -----------------------------------------------------------------------
local pinTexturesList = {
   [1] = GetString(DCS_BOSS_TEXTURE_1),
   [2] = GetString(DCS_BOSS_TEXTURE_2),
}

local pinTextures = {
   unknown = {
      [1] = "/esoui/art/icons/poi/poi_groupboss_incomplete.dds",
      [2] = "/esoui/art/icons/poi/poi_groupboss_incomplete.dds",
   },
   collected = {
      [1] = "/esoui/art/icons/poi/poi_groupboss_complete.dds",
      [2] = "/esoui/art/icons/poi/poi_groupboss_complete.dds",
   },
}

--tooltip creator
local pinTooltipCreator = {}
pinTooltipCreator.tooltip = 1 --TOOLTIP_MODE.INFORMATION
pinTooltipCreator.creator = function(pin)
   local _, pinTag = pin:GetPinTypeAndTag()
   local name = GetAchievementInfo(pinTag[3])
   local description, numCompleted = GetAchievementCriterion(pinTag[3], pinTag[4])
   local info = {}
 
   if pinTag[5] ~= nil then
      table.insert(info, "[" .. GetString("DCS_MOREINFO", pinTag[5]) .. "]")
   end
   if numCompleted == 1 then
      table.insert(info, "[" .. GetString(DCS_KNOWN) .. "]")
   end
 
   if IsInGamepadPreferredMode() then
      INFORMATION_TOOLTIP:LayoutIconStringLine(INFORMATION_TOOLTIP.tooltip, nil, zo_strformat(name), INFORMATION_TOOLTIP.tooltip:GetStyle("mapTitle"))
      INFORMATION_TOOLTIP:LayoutIconStringLine(INFORMATION_TOOLTIP.tooltip, pinTextures.unknown[1], zo_strformat("(<<1>>) <<2>>", pinTag[4], description), {fontSize = 27, fontColorField = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_3})
      if info[1] then
         INFORMATION_TOOLTIP:LayoutIconStringLine(INFORMATION_TOOLTIP.tooltip, nil, table.concat(info, " / "), INFORMATION_TOOLTIP.tooltip:GetStyle("worldMapTooltip"))
      end
   else
      INFORMATION_TOOLTIP:AddLine(zo_strformat("<<1>>", name), "ZoFontGameOutline", ZO_SELECTED_TEXT:UnpackRGB())
      ZO_Tooltip_AddDivider(INFORMATION_TOOLTIP)
      INFORMATION_TOOLTIP:AddLine(zo_strformat("(<<1>>) <<2>>", pinTag[4], description), "", ZO_HIGHLIGHT_TEXT:UnpackRGB())
      if info[1] then
         INFORMATION_TOOLTIP:AddLine(table.concat(info, " / "), "", ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB())
      end
   end
end

local function GetZoneAndSubZone(alternative)
	if alternative then
		return select(3,(GetMapTileTexture()):lower():gsub("ui_map_", ""):find("maps/([%w%-]+/[%w%-]+_[%w%-]+)"))
	end

	return select(3,(GetMapTileTexture()):lower():gsub("ui_map_", ""):find("maps/([%w%-]+)/([%w%-]+_[%w%-]+)"))
end

--add callbacks

local function CompassCallback_unknown()
	if GetMapType() <= MAPTYPE_ZONE and savedVariables.filters[PINS_COMPASS_UNKNOWN] then
		local zone, subzone = GetZoneAndSubZone()
		local mapid = GetCurrentMapId()
		local DungeonChampions = DungeonChampions_GetLocalData(zone, subzone, mapid)
		if DungeonChampions then
			for _, pinData in ipairs(DungeonChampions) do
				local _, numCompleted = GetAchievementCriterion(pinData[3], pinData[4])
				if numCompleted == 0 then
					COMPASS_PINS.pinManager:CreatePin(PINS_COMPASS_UNKNOWN, pinData, pinData[1], pinData[2])
				end
			end
		end
	end
end

local function CompassCallback_known()
	if GetMapType() <= MAPTYPE_ZONE and savedVariables.filters[PINS_COMPASS_KNOWN] then
		local zone, subzone = GetZoneAndSubZone()
		local mapid = GetCurrentMapId()
		local DungeonChampions = DungeonChampions_GetLocalData(zone, subzone, mapid)
		if DungeonChampions then
			for _, pinData in ipairs(DungeonChampions) do
				local _, numCompleted = GetAchievementCriterion(pinData[3], pinData[4])
				if numCompleted == 0 then
					COMPASS_PINS.pinManager:CreatePin(PINS_COMPASS_KNOWN, pinData, pinData[1], pinData[2])
				end
			end
		end
	end
end

local function CreatePins()
   local zone, subzone = GetZoneAndSubZone()
   local mapid = GetCurrentMapId()
   local DungeonChampions = DungeonChampions_GetLocalData(zone, subzone, mapid)

   if DungeonChampions ~= nil then
      for _, pinData in ipairs(DungeonChampions) do
         local _, numCompleted = GetAchievementCriterion(pinData[3], pinData[4])
         if numCompleted == 1 then
            if updatePins[PINS_COLLECTED] and LMP:IsEnabled(PINS_COLLECTED) then
               LMP:CreatePin(PINS_COLLECTED, pinData, pinData[1], pinData[2])
            end
            if updatePins[PINS_COMPASS_KNOWN] and savedVariables.filters[PINS_COMPASS_KNOWN] then
               COMPASS_PINS.pinManager:CreatePin(PINS_COMPASS_KNOWN, pinData, pinData[1], pinData[2])
            end
         elseif numCompleted == 0 then
            if updatePins[PINS_UNKNOWN] and LMP:IsEnabled(PINS_UNKNOWN) then
               LMP:CreatePin(PINS_UNKNOWN, pinData, pinData[1], pinData[2])
            end
            if updatePins[PINS_COMPASS_UNKNOWN] and savedVariables.filters[PINS_COMPASS_UNKNOWN] then
               COMPASS_PINS.pinManager:CreatePin(PINS_COMPASS_UNKNOWN, pinData, pinData[1], pinData[2])
            end
         end
      end
   end

   updatePins = {}
   updating = false
end

local function QueueCreatePins(pinType)
   updatePins[pinType] = true

   if not updating then
      updating = true
      if IsPlayerActivated() then
        CreatePins()
      else
         EVENT_MANAGER:RegisterForEvent("DungeonChampions_PinUpdate", EVENT_PLAYER_ACTIVATED,
            function(event)
               EVENT_MANAGER:UnregisterForEvent("DungeonChampions_PinUpdate", event)
               CreatePins()
            end)
      end
   end
end

local function MapCallback_unknown()
   if not LMP:IsEnabled(PINS_UNKNOWN) or (GetMapType() > MAPTYPE_ZONE) then return end
   QueueCreatePins(PINS_UNKNOWN)
end

local function MapCallback_collected()
   if not LMP:IsEnabled(PINS_COLLECTED) or (GetMapType() > MAPTYPE_ZONE) then return end
   QueueCreatePins(PINS_COLLECTED)
end

local function CompassCallback_unknown()
   if not savedVariables.filters[PINS_COMPASS_UNKNOWN] or (GetMapType() > MAPTYPE_ZONE) then return end
   QueueCreatePins(PINS_COMPASS_UNKNOWN)
end

local function CompassCallback_known()
   if not savedVariables.filters[PINS_COMPASS_KNOWN] or (GetMapType() > MAPTYPE_ZONE) then return end
   QueueCreatePins(PINS_COMPASS_KNOWN)
end

-- Slash commands -------------------------------------------------------------
local function ShowMyPosition()

	if SetMapToPlayerLocation() == SET_MAP_RESULT_MAP_CHANGED then
		CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")
	end

	local x, y = GetMapPlayerPosition("player")

	local locX = ("%05.02f"):format(zo_round(x*10000)/100)
	local locY = ("%05.02f"):format(zo_round(y*10000)/100)

	MyPrint(zo_strformat("<<1>>: <<2>>\195\151<<3>> (<<4>>)", GetMapName(), locX, locY, GetZoneAndSubZone(true)))
	
end
local function ShowMyPosition2()

	if SetMapToPlayerLocation() == SET_MAP_RESULT_MAP_CHANGED then
		CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")
	end

	local x, y = GetMapPlayerPosition("player")

	local locX = ("%05.02f"):format(zo_round(x*10000)/100)
	local locY = ("%05.02f"):format(zo_round(y*10000)/100)

	MyPrint(zo_strformat("<<1>>: <<2>>\195\151<<3>> (<<4>>)", GetCurrentMapId(), locX, locY, GetZoneAndSubZone(true)))
	
end
SLASH_COMMANDS["/dc_mypos"] = ShowMyPosition
SLASH_COMMANDS["/dc_mypos2"] = ShowMyPosition2

-- Settings menu --------------------------------------------------------------
local function CreateSettingsMenu()
   local panelData = {
      type = "panel",
      name = GetString(DCS_TITLE),
      displayName = "|cFFFFB0" .. GetString(DCS_TITLE) .. "|r",
      author = "Gadget & Scott123 & MerlinGer (featured by Garkin & Ayantir)",
      version = ADDON_VERSION,
      slashCommand = "/dc",
      registerForRefresh = true,
      registerForDefaults = true,
   }
   LAM:RegisterAddonPanel(ADDON_NAME, panelData)

   local CreateIcons, unknownIcon, collectedIcon
   CreateIcons = function(panel)
      if panel == DungeonChampions then
         unknownIcon = WINDOW_MANAGER:CreateControl(nil, panel.controlsToRefresh[1], CT_TEXTURE)
         unknownIcon:SetAnchor(RIGHT, panel.controlsToRefresh[2].dropdown:GetControl(), LEFT, -10, 0)
         unknownIcon:SetTexture(pinTextures.unknown[savedVariables.pinTexture.type])
         unknownIcon:SetDimensions(savedVariables.pinTexture.size, savedVariables.pinTexture.size)
         collectedIcon = WINDOW_MANAGER:CreateControl(nil, panel.controlsToRefresh[2], CT_TEXTURE)
         collectedIcon:SetAnchor(RIGHT, unknownIcon, LEFT, -5, 0)
         collectedIcon:SetTexture(pinTextures.collected[savedVariables.pinTexture.type])
         collectedIcon:SetDimensions(savedVariables.pinTexture.size, savedVariables.pinTexture.size)
         if savedVariables.pinTexture.type == 2 then
            unknownIcon:SetColor(unpack(savedVariables.incompleteColor))
            collectedIcon:SetColor(unpack(savedVariables.completeColor))
         end
         CALLBACK_MANAGER:UnregisterCallback("LAM-PanelControlsCreated", CreateIcons)
      end
   end
   CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", CreateIcons)

   local optionsTable = {
      {
         type = "header",
         name = GetString(DCS_MAPPINS_HEADER),
         width = "full",
      },
      {
         type = "dropdown",
         name = GetString(DCS_PIN_TEXTURE),
         tooltip = GetString(DCS_PIN_TEXTURE_DESC),
         choices = pinTexturesList,
         getFunc = function() return pinTexturesList[savedVariables.pinTexture.type] end,
         setFunc = function(selected)
               for index, name in ipairs(pinTexturesList) do
                  if name == selected then
                     savedVariables.pinTexture.type = index
                     LMP:SetLayoutKey(PINS_UNKNOWN, "texture", pinTextures.unknown[index])
                     LMP:SetLayoutKey(PINS_COLLECTED, "texture", pinTextures.collected[index])
                     COMPASS_PINS.pinLayouts[PINS_COMPASS_UNKNOWN].texture = pinTextures.unknown[index]
                     COMPASS_PINS.pinLayouts[PINS_COMPASS_KNOWN].texture = pinTextures.collected[index]
                     unknownIcon:SetTexture(pinTextures.unknown[index])
                     collectedIcon:SetTexture(pinTextures.collected[index])
                     if index == 2 then
                        LMP:SetLayoutKey(PINS_UNKNOWN, "tint", ZO_ColorDef:New(unpack(savedVariables.incompleteColor)))
                        LMP:SetLayoutKey(PINS_COLLECTED, "tint", ZO_ColorDef:New(unpack(savedVariables.completeColor)))
                        unknownIcon:SetColor(unpack(savedVariables.incompleteColor))
                        collectedIcon:SetColor(unpack(savedVariables.completeColor))
                     else
                        LMP:SetLayoutKey(PINS_UNKNOWN, "tint", nil)
                        LMP:SetLayoutKey(PINS_COLLECTED, "tint", nil)
                        unknownIcon:SetColor(1,1,1,1)
                        collectedIcon:SetColor(1,1,1,1)
                     end
                     LMP:RefreshPins(PINS_UNKNOWN)
                     LMP:RefreshPins(PINS_COLLECTED)
                     COMPASS_PINS:RefreshPins(PINS_COMPASS_UNKNOWN)
                     COMPASS_PINS:RefreshPins(PINS_COMPASS_KNOWN)
                     break
                  end
               end
            end,
         disabled = function() return not (savedVariables.filters[PINS_UNKNOWN] or savedVariables.filters[PINS_COLLECTED]) end,
         default = pinTexturesList[defaults.pinTexture.type],
      },
      --new items in the optionsTable
      {
         type = "colorpicker",
         name = GetString(DCS_KNOWN_COL),
         tooltip = GetString(DCS_KNOWN_COL_TIP),
         getFunc = function() return unpack(savedVariables.completeColor) end,
         setFunc = function( r, g, b, a )
               savedVariables.completeColor = { r, g, b, a }
               LMP:SetLayoutKey(PINS_COLLECTED, "tint", ZO_ColorDef:New( r, g, b, a ))
               collectedIcon:SetColor(r, g, b, a)
         end,
         disabled = function() return not (savedVariables.filters[PINS_COLLECTED] and savedVariables.pinTexture.type == 2) end,
         default = { r = defaults.completeColor[1], g = defaults.completeColor[2], b = defaults.completeColor[3], a = defaults.completeColor[4] }
      },
      {
         type = "colorpicker",
         name = GetString(DCS_UNKNOWN_COL),
         tooltip = GetString(DCS_UNKNOWN_COL_TIP),
         getFunc = function() return unpack(savedVariables.incompleteColor) end,
         setFunc = function(r, g, b, a)
               savedVariables.incompleteColor = { r, g, b, a }
               LMP:SetLayoutKey(PINS_UNKNOWN, "tint", ZO_ColorDef:New( r, g, b, a ))
               unknownIcon:SetColor(r, g, b, a)
         end,
         disabled = function() return not (savedVariables.filters[PINS_UNKNOWN] and savedVariables.pinTexture.type == 2) end,
         default = { r = defaults.incompleteColor[1], g = defaults.incompleteColor[2], b = defaults.incompleteColor[3], a = defaults.incompleteColor[4] }
      },
      {
         type = "slider",
         name = GetString(DCS_PIN_SIZE),
         tooltip = GetString(DCS_PIN_SIZE_DESC),
         min = 20,
         max = 70,
         getFunc = function() return savedVariables.pinTexture.size end,
         setFunc = function(size)
               savedVariables.pinTexture.size = size
               unknownIcon:SetDimensions(size, size)
               collectedIcon:SetDimensions(size, size)
               LMP:SetLayoutKey(PINS_UNKNOWN, "size", size)
               LMP:SetLayoutKey(PINS_COLLECTED, "size", size)
               LMP:RefreshPins(PINS_UNKNOWN)
               LMP:RefreshPins(PINS_COLLECTED)
            end,
         disabled = function() return not (savedVariables.filters[PINS_UNKNOWN] or savedVariables.filters[PINS_COLLECTED]) end,
         default = defaults.pinTexture.size
      },
      {
         type = "slider",
         name = GetString(DCS_PIN_LAYER),
         tooltip = GetString(DCS_PIN_LAYER_DESC),
         min = 10,
         max = 200,
         step = 5,
         getFunc = function() return savedVariables.pinTexture.level end,
         setFunc = function(level)
               savedVariables.pinTexture.level = level
               LMP:SetLayoutKey(PINS_UNKNOWN, "level", level)
               LMP:SetLayoutKey(PINS_COLLECTED, "level", level)
               LMP:RefreshPins(PINS_UNKNOWN)
               LMP:RefreshPins(PINS_COLLECTED)
            end,
         disabled = function() return not (savedVariables.filters[PINS_UNKNOWN] or savedVariables.filters[PINS_COLLECTED]) end,
         default = defaults.pinTexture.level,
      },
      {
         type = "checkbox",
         name = GetString(DCS_UNKNOWN),
         tooltip = GetString(DCS_UNKNOWN_DESC),
         getFunc = function() return savedVariables.filters[PINS_UNKNOWN] end,
         setFunc = function(state)
               savedVariables.filters[PINS_UNKNOWN] = state
               LMP:SetEnabled(PINS_UNKNOWN, state)
            end,
         default = defaults.filters[PINS_UNKNOWN],
      },
      {
         type = "checkbox",
         name = GetString(DCS_COLLECTED),
         tooltip = GetString(DCS_COLLECTED_DESC),
         getFunc = function() return savedVariables.filters[PINS_COLLECTED] end,
         setFunc = function(state)
               savedVariables.filters[PINS_COLLECTED] = state
               LMP:SetEnabled(PINS_COLLECTED, state)
            end,
         default = defaults.filters[PINS_COLLECTED]
      },
      {
         type = "header",
         name = GetString(DCS_COMPASS_HEADER),
         width = "full",
      },
      {
         type = "checkbox",
         name = GetString(DCS_COMPASS_KNOWN),
         tooltip = GetString(DCS_COMPASS_KNOWN_DESC),
         getFunc = function() return savedVariables.filters[PINS_COMPASS_KNOWN] end,
         setFunc = function(state)
               savedVariables.filters[PINS_COMPASS_KNOWN] = state
               COMPASS_PINS:RefreshPins(PINS_COMPASS_KNOWN)
            end,
         default = defaults.filters[PINS_COMPASS_KNOWN],
      },
      {
         type = "checkbox",
         name = GetString(DCS_COMPASS_UNKNOWN),
         tooltip = GetString(DCS_COMPASS_UNKNOWN_DESC),
         getFunc = function() return savedVariables.filters[PINS_COMPASS_UNKNOWN] end,
         setFunc = function(state)
               savedVariables.filters[PINS_COMPASS_UNKNOWN] = state
               COMPASS_PINS:RefreshPins(PINS_COMPASS_UNKNOWN)
            end,
         default = defaults.filters[PINS_COMPASS_UNKNOWN],
      },
      {
         type = "slider",
         name = GetString(DCS_COMPASS_DIST),
         tooltip = GetString(DCS_COMPASS_DIST_DESC),
         min = 1,
         max = 100,
         getFunc = function() return savedVariables.compassMaxDistance * 1000 end,
         setFunc = function(maxDistance)
               savedVariables.compassMaxDistance = maxDistance / 1000
               COMPASS_PINS.pinLayouts[PINS_COMPASS_KNOWN].maxDistance = maxDistance / 1000
               COMPASS_PINS:RefreshPins(PINS_COMPASS_KNOWN)
               COMPASS_PINS.pinLayouts[PINS_COMPASS_UNKNOWN].maxDistance = maxDistance / 1000
               COMPASS_PINS:RefreshPins(PINS_COMPASS_UNKNOWN)
            end,
         disabled = function() return not (savedVariables.filters[PINS_COMPASS_KNOWN] or savedVariables.filters[PINS_COMPASS_UNKNOWN]) end,
         default = defaults.compassMaxDistance * 1000,
      },
   }
   LAM:RegisterOptionControls(ADDON_NAME, optionsTable)
end

-- Event handlers -------------------------------------------------------------
local function OnAchievementUpdate(_, achievementId)

	local ids = GetAchievementIDs()

	if ids[achievementId] then
       LMP:RefreshPins(PINS_UNKNOWN)
       LMP:RefreshPins(PINS_COLLECTED)
       COMPASS_PINS:RefreshPins(PINS_COMPASS_KNOWN)
       COMPASS_PINS:RefreshPins(PINS_COMPASS_UNKNOWN)
	end
end

local function OnAchievementAwarded(_, _, _, achievementId)
	OnAchievementUpdate(_, achievementId)
end

local function NamesToIDSavedVars()

	if not savedVariables.namesToIDSavedVars then
		
		local displayName = GetDisplayName()
		local name = GetUnitName("player")
		
		if DCS_SavedVariables.Default[displayName][name] then
			savedVariables = DCS_SavedVariables.Default[displayName][name]
			savedVariables.namesToIDSavedVars = true
		end	
	end
end

local function OnLoad(_, name)

   if name == ADDON_NAME then

   		EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
		
	    savedVariables = ZO_SavedVars:New("DCS_SavedVariables", 6, nil, defaults)
		NamesToIDSavedVars()
	   
	    --get pin layout from saved variables
        local pinTextureType = savedVariables.pinTexture.type
        local pinTextureLevel = savedVariables.pinTexture.level
        local pinTextureSize = savedVariables.pinTexture.size
        local compassMaxDistance = savedVariables.compassMaxDistance
        local completeColor = savedVariables.completeColor
        local incompleteColor = savedVariables.incompleteColor
		
		local pinLayout_unknown = { level = pinTextureLevel, texture = pinTextures.unknown[pinTextureType], size = pinTextureSize, tint = pinTextureType == 2 and ZO_ColorDef:New(unpack(incompleteColor)) or nil, }
		local pinLayout_collected = { level = pinTextureLevel, texture = pinTextures.collected[pinTextureType], size = pinTextureSize, tint = pinTextureType == 2 and ZO_ColorDef:New(unpack(completeColor)) or nil, }
		
		local pinLayout_compassknown = {
            maxDistance = compassMaxDistance,
            texture = pinTextures.collected[pinTextureType],
            sizeCallback = function(pin, angle, normalizedAngle, normalizedDistance)
                if zo_abs(normalizedAngle) > 0.25 then
                    pin:SetDimensions(54 - 24 * zo_abs(normalizedAngle), 54 - 24 * zo_abs(normalizedAngle))
                else
                    pin:SetDimensions(48, 48)
                end
            end,
            additionalLayout = {
                function(pin) --set function, color is by default 1,1,1,1, so change it only if texture type is 2
                    if savedVariables.pinTexture.type == 2 then
                        pin:GetNamedChild("Background"):SetColor(unpack(savedVariables.completeColor))
                    end
                end,
                function(pin) --reset function, change color back to default
                    pin:GetNamedChild("Background"):SetColor(1,1,1,1)
                end,
            },
        }
		
		local pinLayout_compassunknown = {
            maxDistance = compassMaxDistance,
            texture = pinTextures.unknown[pinTextureType],
            sizeCallback = function(pin, angle, normalizedAngle, normalizedDistance)
                if zo_abs(normalizedAngle) > 0.25 then
                    pin:SetDimensions(54 - 24 * zo_abs(normalizedAngle), 54 - 24 * zo_abs(normalizedAngle))
                else
                    pin:SetDimensions(48, 48)
                end
            end,
            additionalLayout = {
                function(pin)
                    if savedVariables.pinTexture.type == 2 then
                        pin:GetNamedChild("Background"):SetColor(unpack(savedVariables.incompleteColor))
                    end
                end,
                function(pin)
                    pin:GetNamedChild("Background"):SetColor(1,1,1,1)
                end,
            },
        }
        --initialize map pins
        LMP:AddPinType(PINS_UNKNOWN, MapCallback_unknown, nil, pinLayout_unknown, pinTooltipCreator)
        LMP:AddPinType(PINS_COLLECTED, MapCallback_collected, nil, pinLayout_collected, pinTooltipCreator)

        --add filter check boxex
        LMP:AddPinFilter(PINS_UNKNOWN, GetString(DCS_FILTER_UNKNOWN), nil, savedVariables.filters)
        LMP:AddPinFilter(PINS_COLLECTED, GetString(DCS_FILTER_COLLECTED), nil, savedVariables.filters)

        --initialize compass pins
        COMPASS_PINS:AddCustomPin(PINS_COMPASS_KNOWN, CompassCallback_known, pinLayout_compassknown)
        COMPASS_PINS:AddCustomPin(PINS_COMPASS_UNKNOWN, CompassCallback_unknown, pinLayout_compassunknown)
        COMPASS_PINS:RefreshPins(PINS_COMPASS_KNOWN)
        COMPASS_PINS:RefreshPins(PINS_COMPASS_UNKNOWN)

        -- addon menu
        CreateSettingsMenu()
		
		-- Set which tooltip must be used
        OnGamepadPreferredModeChanged()

        --events
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ACHIEVEMENT_UPDATED, OnAchievementUpdate)
		EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ACHIEVEMENT_AWARDED, OnAchievementAwarded)
		EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, OnGamepadPreferredModeChanged)
   end

end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnLoad)
