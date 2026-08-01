-- RdK Group Tool Camp Preview
-- By @s0rdrak (PC / EU)

--local libMapPins = LibStub("LibMapPins-1.0")
local libMapPins = LibMapPins

RdKGTool.toolbox = RdKGTool.toolbox or {}
local RdKGToolTB = RdKGTool.toolbox
RdKGToolTB.camp = RdKGToolTB.camp or {}
local RdKGToolCamp = RdKGToolTB.camp
RdKGTool.menu = RdKGTool.menu or {}
local RdKGToolMenu = RdKGTool.menu

RdKGToolCamp.constants = RdKGToolCamp.constants or {}

RdKGToolCamp.callbackName = RdKGTool.addonName .. "CampPreview"

RdKGToolCamp.config = {}
RdKGToolCamp.config.pinType = "RdKGToolToolboxCampPreviewPinType"
RdKGToolCamp.config.pinTag = "RdKGToolToolboxCampPreviewPinTag"
RdKGToolCamp.config.updateInterval = 50
RdKGToolCamp.config.zoneRadius = 0.026000000536442
RdKGToolCamp.config.subZoneRadius = 0.52204173803329
RdKGToolCamp.config.worldRadius = 0.0046799997799098

RdKGToolCamp.state = {}
RdKGToolCamp.state.initialized = false
RdKGToolCamp.state.alreadyEnabled = false
RdKGToolCamp.state.registredActivationConsumers = false
RdKGToolCamp.state.campId = 0
RdKGToolCamp.state.campPreviewUp = false
RdKGToolCamp.state.previousCoordinates = {}
RdKGToolCamp.state.previousCoordinates.x = 0
RdKGToolCamp.state.previousCoordinates.y = 0
RdKGToolCamp.state.pinLayoutData = {}
RdKGToolCamp.state.pinLayoutData.level = 111
RdKGToolCamp.state.pinLayoutData.texture = nil -- "/art/fx/texture/aoe_circle_hollow.dds"
RdKGToolCamp.state.pinLayoutData.size = 0 -- 0.026000000536442
RdKGToolCamp.state.pinLayoutData.tint = nil
--RdKGToolCamp.state.pinLayoutData.color = {r=1,g=0,b=0,a=1}
RdKGToolCamp.state.pinLayoutData.grayscale = false
RdKGToolCamp.state.pinLayoutData.insetX = 0
RdKGToolCamp.state.pinLayoutData.insetY = 0
RdKGToolCamp.state.pinLayoutData.minSize = 0
RdKGToolCamp.state.pinLayoutData.minAreaSize = nil
RdKGToolCamp.state.pinLayoutData.showsPinAndArea = true
RdKGToolCamp.state.pinLayoutData.isAnimated = false
RdKGToolCamp.state.updateLoopRunning = false
--[[
/script d("|t50:50:/art/fx/texture/aoe_circle_hollow.dds|t")
/script d("|t50:50:/art/fx/texture/aoe_circle_hollow_thinouter.dds|t")
]]

--[[
pinLayoutData: table which can contain the following keys:
   level =     number > 2, pins with higher level are drawn on the top of pins
               with lower level.
               Examples: Points of interest 50, quests 110, group members 130,
               wayshrine 140, player 160.
   texture =   string or function(pin). Function can return just one texture
               or overlay, pulse and glow textures.
   size =      texture will be resized to size*size, if not specified size is 20.
   tint  =     ZO_ColorDef object or function(pin) which returns this object.
               If defined, color of background texture is set to this color.
   grayscale = true/false, could be function(pin). If defined and not false,
               background texure will be converted to grayscale (http://en.wikipedia.org/wiki/Colorfulness)
   insetX =    size of transparent texture border, used to handle mouse clicks
   insetY =    dtto
   minSize =   if not specified, default value is 18
   minAreaSize = used for area pins
   showsPinAndArea = true/false
   isAnimated = true/false
  ]]

function RdKGToolCamp.Initialize()
	RdKGTool.profile.AddProfileChangeListener(RdKGToolCamp.callbackName, RdKGToolCamp.OnProfileChanged)
	RdKGToolCamp.state.campId = RdKGToolCamp.GetCampId()
	libMapPins:AddPinType(RdKGToolCamp.config.pinType, function() end, function() end, RdKGToolCamp.state.pinLayoutData, nil)
	RdKGToolCamp.state.initialized = true
	RdKGToolCamp.SetEnabled(RdKGToolCamp.cpVars.enabled)
end

function RdKGToolCamp.GetDefaults()
	local defaults = {}
	defaults.enabled = true
	return defaults
end

function RdKGToolCamp.SetEnabled(value)
	if RdKGToolCamp.state.initialized == true and value ~= nil then
		RdKGToolCamp.cpVars.enabled = value
		if value == true then
			if RdKGToolCamp.state.alreadyEnabled == false then
				EVENT_MANAGER:RegisterForEvent(RdKGToolCamp.callbackName, EVENT_PLAYER_ACTIVATED, RdKGToolCamp.OnPlayerActivated)
				EVENT_MANAGER:RegisterForEvent(RdKGToolCamp.callbackName, EVENT_PLAYER_DEACTIVATED, RdKGToolCamp.OnPlayerDeactivated)
				RdKGToolCamp.state.alreadyEnabled = true
			end
		else
			if RdKGToolCamp.state.alreadyEnabled == true then
				EVENT_MANAGER:UnregisterForEvent(RdKGToolCamp.callbackName, EVENT_PLAYER_ACTIVATED)
				EVENT_MANAGER:UnregisterForEvent(RdKGToolCamp.callbackName, EVENT_PLAYER_DEACTIVATED)
				RdKGToolCamp.state.alreadyEnabled = false
			end
		end
		RdKGToolCamp.OnPlayerActivated()
	end
end

function RdKGToolCamp.GetCampId()
	local alliance = GetUnitAlliance("player")
	local campId = 0
	if alliance == ALLIANCE_ALDMERI_DOMINION then
		campId = 29533
	elseif alliance == ALLIANCE_DAGGERFALL_COVENANT then
		campId = 29535
	elseif alliance == ALLIANCE_EBONHEART_PACT then
		campId = 29534
	end
	return campId
end

function RdKGToolCamp.ShowCamp()
	--d("show loop")
	local updatePosition = true
	local x, y, _ = GetMapPlayerPosition("player")
	if RdKGToolCamp.state.campPreviewUp == true then
		if RdKGToolCamp.state.previousCoordinates.x == x and RdKGToolCamp.state.previousCoordinates.y == y then
			updatePosition = false
		else
			RdKGToolCamp.HideCamp()
		end
	end
	if updatePosition == true then
		local radius = RdKGToolCamp.config.zoneRadius
		if GetMapType() == MAPTYPE_SUBZONE then
			radius = RdKGToolCamp.config.subZoneRadius
		elseif GetMapType() == MAPTYPE_WORLD then
			radius = RdKGToolCamp.config.worldRadius
		end
		libMapPins:CreatePin(RdKGToolCamp.config.pinType, RdKGToolCamp.config.pinTag, x, y, radius)
		--[[
			GetForwardCampPinInfo(number BattlegroundQueryContextType battlegroundContext, number index)
			Returns: number pinType, number normalizedX, number normalizedY, number normalizedRadius (0.026000000536442), boolean useable
			zone:    0.026000000536442
			subZone: 0.52204173803329
		]]
		RdKGToolCamp.state.previousCoordinates.x = x
		RdKGToolCamp.state.previousCoordinates.y = y
		RdKGToolCamp.state.campPreviewUp = true
		--libMapPins:RefreshPins(RdKGToolCamp.config.pinType)
	end
end

function RdKGToolCamp.HideCamp()
	libMapPins:RemoveCustomPin(RdKGToolCamp.config.pinType, RdKGToolCamp.config.pinTag)
	RdKGToolCamp.state.campPreviewUp = false
	--libMapPins:RefreshPins(RdKGToolCamp.config.pinType)
end

--callbacks
function RdKGToolCamp.OnProfileChanged(currentProfile)
	if currentProfile ~= nil then
		RdKGToolCamp.cpVars = currentProfile.toolbox.camp
		RdKGToolCamp.SetEnabled(RdKGToolCamp.cpVars.enabled)
	end
end

function RdKGToolCamp.OnPlayerActivated(eventCode, initial)
	if RdKGToolCamp.cpVars.enabled == true and IsInCyrodiil() == true then
		--d("activated")
		if RdKGToolCamp.state.registredActivationConsumers == false then
			EVENT_MANAGER:RegisterForEvent(RdKGToolCamp.callbackName, EVENT_ACTIVE_QUICKSLOT_CHANGED, RdKGToolCamp.OnQuickSlotChanged)
			RdKGToolCamp.state.registredActivationConsumers = true
		end
		RdKGToolCamp.OnQuickSlotChanged(EVENT_ACTIVE_QUICKSLOT_CHANGED, GetCurrentQuickslot())
	else
		if RdKGToolCamp.state.registredActivationConsumers == true then
			EVENT_MANAGER:UnregisterForEvent(RdKGToolCamp.callbackName, EVENT_ACTIVE_QUICKSLOT_CHANGED)
			RdKGToolCamp.state.registredActivationConsumers = false
		end
		if RdKGToolCamp.state.updateLoopRunning == true then
			EVENT_MANAGER:UnregisterForUpdate(RdKGToolCamp.callbackName)
			RdKGToolCamp.state.updateLoopRunning = false
		end
		RdKGToolCamp.HideCamp()
	end
end

function RdKGToolCamp.OnPlayerDeactivated()
	if RdKGToolCamp.state.updateLoopRunning == true then
		--d("deactivated")
		EVENT_MANAGER:UnregisterForUpdate(RdKGToolCamp.callbackName)
		RdKGToolCamp.state.updateLoopRunning = false
	end
	RdKGToolCamp.HideCamp()
end

function RdKGToolCamp.OnQuickSlotChanged(eventCode, slotId)
	--d("quickslot changed")
	--local itemLink = GetSlotItemLink(slotId + 1)
	local itemLink = GetSlotItemLink(slotId)
	if itemLink ~= nil then
		local _, _, _, itemId = ZO_LinkHandler_ParseLink(itemLink)
		--d(itemId)
		if itemId ~= nil and tonumber(itemId) == RdKGToolCamp.state.campId then
			if RdKGToolCamp.state.updateLoopRunning == false then
				--d("register for update")
				EVENT_MANAGER:RegisterForUpdate(RdKGToolCamp.callbackName, RdKGToolCamp.config.updateInterval, RdKGToolCamp.ShowCamp)
				RdKGToolCamp.state.updateLoopRunning = true
			end
		else
			if RdKGToolCamp.state.updateLoopRunning == true then
				EVENT_MANAGER:UnregisterForUpdate(RdKGToolCamp.callbackName)
				RdKGToolCamp.state.updateLoopRunning = false
			end
			RdKGToolCamp.HideCamp()
		end
	else
		if RdKGToolCamp.state.updateLoopRunning == true then
			EVENT_MANAGER:UnregisterForUpdate(RdKGToolCamp.callbackName)
			RdKGToolCamp.state.updateLoopRunning = false
		end
		RdKGToolCamp.HideCamp()
	end
end

--menu interactions
function RdKGToolCamp.GetMenu()
	local menu = {
		[1] = {
			type = "submenu",
			name = RdKGToolMenu.constants.CP_HEADER,
			controls = {
				[1] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.CP_ENABLED,
					getFunc = RdKGToolCamp.GetCampEnabled,
					setFunc = RdKGToolCamp.SetCampEnabled
				}
			}
		}
	}
	return menu
end

function RdKGToolCamp.GetCampEnabled()
	return RdKGToolCamp.cpVars.enabled
end

function RdKGToolCamp.SetCampEnabled(value)
	RdKGToolCamp.SetEnabled(value)
end