--Name Space
PsijicBreachHelper = {}
local PBH = PsijicBreachHelper

local LMP = LibMapPins
local CCP = COMPASS_PINS

--Basic Info
PBH.Name = "PsijicBreachHelper"
PBH.Author = "@Saranicole1980"

local TimeBreach={
summerset_base={{.587,.543,2},{.226,.599,2},{.292,.373,2},{.621,.322,2},{.561,.432,2},{.676,.62,2},{.479,.743,2},{.339,.424,2},{.738,.713,2}},
glenumbra_base={{.735,.199,2},{.336,.509,2},{.436,.807,2}},
stormhaven_base={{.516,.343,2},{.634,.361,2},{.13,.533,2}},	--{.84,.45,7}},
alikr_base={{.436,.472,2},{.717,.579,2},{.249,.632,2}},	--{.61,.467,4}},
eastmarch_base={{.5,.53,3},{.332,.482,3},{.327,.687,3}},
therift_base={{.737,.367,3},{.078,.259,3},{.318,.23,3}},
stonefalls_base={{.41,.523,3},{.52,.636,3},{.777,.504,3}},	--{.541,.628,7}},
--bangkorai_base={{.37,.456,4}},
grahtwood_base={{.291,.506,5},{.682,.463,5},{.23,.219,5}},
greenshade_base={{.127,.505,5},{.274,.1,5},{.584,.78,5}},	--{.537,.81,7}},
malabaltor_base={{.492,.346,5},{.647,.727,5},{.81,.242,5}},
shadowfen_base={{.748,.724,6},{.291,.777,6},{.552,.361,6},{.256,.236,6}},	--{.535,.524,4}},
deshaan_base={{.338,.572,6},{.1,.58,6},{.594,.44,6},{.78,.396,6},{.79,.57,6}},	--{.734,.616,4}},
rivenspire_base={{.157,.645,8},{.658,.626,8},{.823,.311,8},{.713,.471,8},{.61,.417,8},{.81,.117,8},{.216,.686,8},{.5,.677,8},{.201,.541,8}},
craglorn_base={{.177,.222,9},{.394,.383,9},{.242,.579,9},{.77,.687,9},{.654,.604,9},{.383,.7,9}},	--{.639,.566,7}}
}

PBH.pinData = {
   ["summerset/summerset_base"] = {
      { x = 0.587, y = 0.543 },
      { x = 0.226, y = 0.599 },
      { x = 0.292, y = 0.373 },
      { x = 0.621, y = 0.322 },
      { x = 0.561, y = 0.432 },
      { x = 0.676, y = 0.620 },
      { x = 0.479, y = 0.743 },
      { x = 0.339, y = 0.424 },
      { x = 0.738, y = 0.713 },
   },
   ["glenumbra/glenumbra_base"] = {
      { x = 0.735, y = 0.199 },
      { x = 0.336, y = 0.509 },
      { x = 0.436, y = 0.807 },
   },
   ["stormhaven/stormhaven_base"] = {
      { x = 0.516, y = 0.343 },
      { x = 0.634, y = 0.361 },
      { x = 0.130, y = 0.533 },
   },
   ["alikr/alikr_base"] = {
      { x = 0.436, y = 0.472 },
      { x = 0.717, y = 0.579 },
      { x = 0.249, y = 0.632 },
   },
   ["eastmarch/eastmarch_base"] = {
      { x = 0.500, y = 0.530 },
      { x = 0.332, y = 0.482 },
      { x = 0.327, y = 0.687 },
   },
   ["therift/therift_base"] = {
      { x = 0.737, y = 0.367 },
      { x = 0.078, y = 0.259 },
      { x = 0.318, y = 0.230 },
   },
   ["stonefalls/stonefalls_base"] = {
      { x = 0.410, y = 0.523 },
      { x = 0.520, y = 0.636 },
      { x = 0.777, y = 0.504 },
   },
   ["grahtwood/grahtwood_base"] = {
      { x = 0.291, y = 0.506 },
      { x = 0.682, y = 0.463 },
      { x = 0.230, y = 0.219 },
   },
   ["greenshade/greenshade_base"] = {
      { x = 0.127, y = 0.505 },
      { x = 0.274, y = 0.100 },
      { x = 0.584, y = 0.780 },
   },
   ["malabaltor/malabaltor_base"] = {
      { x = 0.492, y = 0.346 },
      { x = 0.647, y = 0.727 },
      { x = 0.810, y = 0.242 },
   },
   ["shadowfen/shadowfen_base"] = {
      { x = 0.748, y = 0.724 },
      { x = 0.291, y = 0.777 },
      { x = 0.552, y = 0.361 },
      { x = 0.256, y = 0.236 },
   },
   ["deshaan/deshaan_base"] = {
      { x = 0.338, y = 0.572 },
      { x = 0.100, y = 0.580 },
      { x = 0.594, y = 0.440 },
      { x = 0.780, y = 0.396 },
      { x = 0.790, y = 0.570 },
   },
   ["rivenspire/rivenspire_base"] = {
      { x = 0.157, y = 0.645 },
      { x = 0.658, y = 0.626 },
      { x = 0.823, y = 0.311 },
      { x = 0.713, y = 0.471 },
      { x = 0.610, y = 0.417 },
      { x = 0.810, y = 0.117 },
      { x = 0.216, y = 0.686 },
      { x = 0.500, y = 0.677 },
      { x = 0.201, y = 0.541 },
   },
   ["craglorn/craglorn_base"] = {
      { x = 0.177, y = 0.222 },
      { x = 0.394, y = 0.383 },
      { x = 0.242, y = 0.579 },
      { x = 0.770, y = 0.687 },
      { x = 0.654, y = 0.604 },
      { x = 0.383, y = 0.700 },
   },
}

function PBH.SwitchSV()
  if PBH.CV.CV then
    PBH.SV = PBH.CV
  else
    PBH.SV = PBH.AV
  end
end

PBH.AV = ZO_SavedVars:NewAccountWide("PsijicBreachHelper_Vars", 1, nil, { filters = true })
PBH.CV = ZO_SavedVars:NewCharacterIdSettings("PsijicBreachHelper_Vars", 1, nil, { filters = true })
PBH.SwitchSV()

local PIN_TYPE = "PsijicBreachPin"
local COMPASS_PIN_TYPE = "PsijicBreachCompassPin"
local COMPASS_PIN_TYPE_HIGHLIGHT = "PsijicBreachCompassPinHighlight"
local pinTypeId1

local function equalish(a, b, epsilon)
    -- Default epsilon if none provided
    epsilon = epsilon or 1e-9
    if a and b then
      return math.abs(a - b) < epsilon
    else
      return false
    end
end

local function differ(a, b, epsilon)
    -- Default epsilon if none provided
    epsilon = epsilon or 1e-9
    if a and b then
      return math.abs(a - b) > epsilon
    else
      return true
    end
end

local pinLayoutData  = {
   level = 80,
   texture = "PsijicBreachHelper/Treasure_1-2.dds",
   size = 30,
}

local clickHandler = {
    [1] = {
      name = "Psijic Breach",
      gamepadName = "Psijic Breach",
      show = function(pin) return true end,
      callback = function(pin)
        PingMap(MAP_PIN_TYPE_PLAYER_WAYPOINT, MAP_TYPE_LOCATION_CENTERED, pin.normalizedX, pin.normalizedY)
        local icon = pin.backgroundControl

        if equalish(pin.normalizedX,PBH.SV.highlightX) and equalish(pin.normalizedY,PBH.SV.highlightY) then
          PBH.SV.highlightX = nil
          PBH.SV.highlightY = nil
          icon:SetTexture("PsijicBreachHelper/Treasure_1-2.dds")
        elseif PBH.SV.highlightX ~= nil and PBH.SV.highlightY ~= nil and differ(pin.normalizedX,PBH.SV.highlightX) and differ(pin.normalizedY,PBH.SV.highlightY) then
          if PBH.SV.highlightedPin then
            PBH.SV.highlightedPin.backgroundControl:SetTexture("PsijicBreachHelper/Treasure_1-2.dds")
          end
          PBH.SV.highlightedPin = pin
          PBH.SV.highlightX = pin.normalizedX
          PBH.SV.highlightY = pin.normalizedY
          icon:SetTexture("PsijicBreachHelper/Treasure_1-2_done.dds")
        else
          PBH.SV.highlightX = pin.normalizedX
          PBH.SV.highlightY = pin.normalizedY
          PBH.SV.highlightedPin = pin
          icon:SetTexture("PsijicBreachHelper/Treasure_1-2_done.dds")
        end
        CCP:RefreshPins(COMPASS_PIN_TYPE_HIGHLIGHT)
      end
    }
  }

local compassLayoutData  = {
   maxDistance = 1,
   sizeCallback = function(pin, angle, normalizedAngle, normalizedDistance)
     if zo_abs(normalizedAngle) > 0.25 then
       pin:SetDimensions(54 - 24 * zo_abs(normalizedAngle), 54 - 24 * zo_abs(normalizedAngle))
     else
       pin:SetDimensions(48, 48)
     end
   end,
   texture = "PsijicBreachHelper/Treasure_1-2.dds",
}

local compassHighlightLayoutData  = {
   maxDistance = 1,
   sizeCallback = function(pin, angle, normalizedAngle, normalizedDistance)
     if zo_abs(normalizedAngle) > 0.25 then
       pin:SetDimensions(54 - 24 * zo_abs(normalizedAngle), 54 - 24 * zo_abs(normalizedAngle))
     else
       pin:SetDimensions(48, 48)
     end
   end,
   texture = "PsijicBreachHelper/Treasure_1-2_done.dds",
}

local pinTooltipCreator = {
   creator = function(pin)
      InformationTooltip:AddLine(zo_strformat("Psijic Breach"))
   end,
   tooltip = ZO_MAP_TOOLTIP_MODE.INFORMATION,
}

local pinTypeAddCallback = function(pinManager)
   --do not create pins if your pinType is not enabled
   if not LMP:IsEnabled(PIN_TYPE) then return end
   --do not create pins on world, alliance and cosmic maps
   if (GetMapType() > MAPTYPE_ZONE) then return end

   local mapname = LMP:GetZoneAndSubzone(true)
   local pins = PBH.pinData[mapname]
   --return if no data for the current map
   if not pins then return end
   for _, pinInfo in ipairs(pins) do
      if equalish(pinInfo.x,PBH.SV.highlightX) and equalish(pinInfo.y,PBH.SV.highlightY) then
        LMP:CreatePin(PIN_TYPE, pinInfo, pinInfo.x, pinInfo.y)
        local pin = LMP:FindCustomPin(PIN_TYPE, pinInfo)
        pin.backgroundControl:SetTexture("PsijicBreachHelper/Treasure_1-2_done.dds")
      else
        LMP:CreatePin(PIN_TYPE, pinInfo, pinInfo.x, pinInfo.y)
      end

   end
end

local compassAddCallback = function(pinManager)
   --do not create pins on world, alliance and cosmic maps
   if (GetMapType() > MAPTYPE_ZONE) then return end

   local mapname = LMP:GetZoneAndSubzone(true)
   local pins = PBH.pinData[mapname]
   --return if no data for the current map
   if not pins then return end
   for _, pinInfo in ipairs(pins) do
      if equalish(pinInfo.x,PBH.SV.highlightX) and equalish(pinInfo.y,PBH.SV.highlightY) then
        CCP.pinManager:CreatePin( COMPASS_PIN_TYPE_HIGHLIGHT, pinInfo, pinInfo.x, pinInfo.y )
      else
        CCP.pinManager:CreatePin( COMPASS_PIN_TYPE, pinInfo, pinInfo.x, pinInfo.y )
      end
   end
end

local pinTypeOnResizeCallback = function(pinManager, mapWidth, mapHeight)
   local visibleWidth, visibleHeight = ZO_WorldMapScroll:GetDimensions()
   local currentZoom = mapWidth / visibleWidth

   if currentZoom < 1.5 then
      LMP:SetLayoutData(pinTypeId1, pinLayoutData)
      LMP:RefreshPins(pinTypeId1)
   else
      LMP:SetLayoutData(pinTypeId1, {})
      LMP:RefreshPins(pinTypeId1)
   end
end

--When Loaded
local function OnAddOnLoaded(eventCode, addonName)
  if addonName ~= PBH.Name then return end
	EVENT_MANAGER:UnregisterForEvent(PBH.Name, EVENT_ADD_ON_LOADED)
	pinTypeId1 = LMP:AddPinType(PIN_TYPE, pinTypeAddCallback, pinTypeOnResizeCallback, pinLayoutData, pinTooltipCreator)
	CCP:AddCustomPin( COMPASS_PIN_TYPE, compassAddCallback, compassLayoutData )
	CCP:AddCustomPin( COMPASS_PIN_TYPE_HIGHLIGHT, compassAddCallback, compassHighlightLayoutData )
	CCP:SetCompassPinEnabled(COMPASS_PIN_TYPE, true)
	CCP:SetCompassPinEnabled(COMPASS_PIN_TYPE_HIGHLIGHT, true)
  CCP:RefreshPins(COMPASS_PIN_TYPE)
  CCP:RefreshPins(COMPASS_PIN_TYPE_HIGHLIGHT)
	LMP:AddPinFilter(pinTypeId1, "Psijic Breaches", nil, PBH.SV, "filters")
	LMP:SetClickHandlers(PIN_TYPE, clickHandler)
	LMP:SetEnabled(PIN_TYPE, true)
	LMP:SetPinFilterHidden(pinTypeId1, "pvp", true)
  LMP:SetPinFilterHidden(pinTypeId1, "imperialPvP", true)
  LMP:SetPinFilterHidden(pinTypeId1, "battleground", true)
  LMP:RefreshPins(PIN_TYPE)
end

EVENT_MANAGER:RegisterForEvent(PBH.Name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
