BaitPings = BaitPings or {}
local BP = BaitPings

local ADDON_NAME  = "BaitPings"
local LAM2 = LibAddonMenu2

local LocalCallbackManager = ZO_CallbackObject:Subclass()

local EVENT_PING_CREATED = 4207843

local lockout = false
local lockoutNames = {}

function BP.DebugAction()

	d(GetUnitName("reticleover"))
	AssignTargetMarkerToReticleTarget(1)

end

function BP.FindPing()

	if lockout then
		return
	end
	
	local cX, cY, cZ = GuiRender3DPositionToWorldPosition( OSI.ctrl:Get3DRenderSpaceOrigin() )
    local fX, fY, fZ = OSI.ctrl:Get3DRenderSpaceForward()
    local rX, rY, rZ = OSI.ctrl:Get3DRenderSpaceRight()
    local uX, uY, uZ = OSI.ctrl:Get3DRenderSpaceUp()
	
	local _, wX, wY, wZ = GetUnitWorldPosition("player")
	wX, wY, wZ = WorldPositionToGuiRender3DPosition(wX, wY, wZ)
	camX, camY, camZ = WorldPositionToGuiRender3DPosition(cX, cY, cZ)
	
	scalar = (camY-wY)/fY
	
	tX = -1 * fX * scalar
	tY = -1 * fY * scalar
	tZ = -1 * fZ * scalar
	
	eX = camX + tX
	eY = camY + tY
	eZ = camZ + tZ
	
	endX, endY, endZ = GuiRender3DPositionToWorldPosition(eX, eY, eZ)
	
	local localX, localY = Lib3D:WorldToLocal(endX/100,endZ/100)
	local globalX, globalY = LibGPS3:LocalToGlobal(localX, localY)
	
	LocalCallbackManager:FireCallbacks(EVENT_PING_CREATED, _, globalX, globalY)
	dataX = math.floor(globalX*100000) 
	dataY = math.floor(globalY*100000)
	sign = (2 * ((dataX < 0) and 1 or 0) + 1 * ((dataY < 0) and 1 or 0))
	dataX = string.format("%05d", math.abs(dataX))
	dataY = string.format("%05d", math.abs(dataY))
	data = sign .. dataX .. dataY
	share:QueueData(tonumber(data))
	
	lockout = true
	
	local Reset = function()
		lockout = false
	end
	
	zo_callLater(Reset, 500)
end

function BP.CreateNewPing(eventCode, globalX, globalY)

	PlaySound(BP.SV.Sound)
	
	local localX, localY = LibGPS3:GlobalToLocal(globalX, globalY)
	
	worldX, worldZ = Lib3D:GlobalToWorld(globalX,globalY)
	worldX = 100*worldX
	worldZ = 100*worldZ
	
	local _, wX, wY, wZ = GetUnitWorldPosition("player")
	
	local icon = OSI.CreatePositionIcon(worldX, wY, worldZ, 
										BP.SV.TexturePath,
										OSI.GetIconSize() * 1.5 * BP.SV.IconSize, 
										{ 1, 1, 1 },
										2.5,
										function( data )
											-- simple bounce animation along the y-axis
											data.offset = BP.SV.IconOffset + math.sin( GetGameTimeMilliseconds() / 1000 * 2 )
										end)
	
	local Color = ZO_ColorDef:New(unpack(BP.SV.BeamColor))
	local ColorHex = Color:ToHex()
	
	local rallyPointData = {
		depthBuffer = false,
		arrowMagnitude = 5,
		arrowScale = 1,
		arrowHeight = 1,
		arrowColour = "FF0000",

		distanceDigits = 4,
		distanceScale = 25,
		distanceColour = "FFFFFF",

		markerColour = ColorHex,
		markerScale = BP.SV.BeamScale,
	}
	local rally = Lib3DArrow:CreateArrow(rallyPointData)
	rally.arrow:SetHidden(true)
	rally.distance:SetHidden(true)
	
	rally:SetTarget(localX,localY)
	
	local Remove = function()
		OSI.DiscardPositionIcon(icon)
		rally.marker:SetHidden(true)
	end
	
	local t = 5000
	
	zo_callLater(Remove, t)
end

function HandleData(tag, data)

	if (not IsUnitGroupLeader(tag)) and BP.SV.CrownOnly then
		return
	end
	
	if lockoutNames[tag] then
		return
	end
	
	lockoutNames[tag] = true
	
	local Reset = function()
		lockoutNames[tag] = false
	end
	
	zo_callLater(Reset, 500)

	z = tostring(data)
	if string.len(z) < 11 then
		while string.len(z) < 11 do
			z = "0" .. z
		end
	end
	globalX = tonumber(string.sub(z, 2, 6))/100000
	globalY = tonumber(string.sub(z, 7, 11))/100000
	sign = tonumber(string.sub(z, 1, 1))
	globalX = ((sign - 2 >= 0) and -1 or 1) * globalX
	globalY = ((sign % 2 == 1) and -1 or 1) * globalY
	LocalCallbackManager:FireCallbacks(EVENT_PING_CREATED, _, globalX, globalY)
end

function BP.TestData(data)
	z = tostring(data)
	if string.len(z) < 11 then
		while string.len(z) < 11 do
			z = "0" .. z
		end
	end
	globalX = tonumber(string.sub(z, 2, 6))/100000
	globalY = tonumber(string.sub(z, 7, 11))/100000
	sign = tonumber(string.sub(z, 1, 1))
	globalX = ((sign - 2 >= 0) and -1 or 1) * globalX
	globalY = ((sign % 2 == 1) and -1 or 1) * globalY
	LocalCallbackManager:FireCallbacks(EVENT_PING_CREATED, _, globalX, globalY)
end

function BP.CreateSettingsWindow()
	local panelData = {
		type = "panel",
		name = "Bait Pings",
		displayName = "Bait Pings",
		author = "DaedricDoge",
		version = "1.0",
		slashCommand = "/baitping",
		registerForRefresh = true,
		registerForDefaults = true,
	}
	
	local controlOptionPanel = LAM2:RegisterAddonPanel("BaitPingsPanel", panelData)
	
	local optionsData = {
		[1] = {
			type = "header",
			name = "Bait Pings Settings"
		},
		[2] = {
			type = "description",
			text = "Change stuff for pings here"
		},
		[3] = {	type = 'colorpicker', name = 'Highlight color',
			default = {0, 0, 1, 1},
			getFunc = function() return unpack(BP.SV.BeamColor) end,
			setFunc = function(r, g, b, a)
				BP.SV.BeamColor = {r, g, b, a}
			end
        },
		[4] = {
			type = "slider",
			name = "Beam Scale",
			tooltip = "Adjusts the size of the beam.",
			min = 0,
			max = 5,
			step = 0.1,
			default = 1,
			decimals = 1,
			getFunc = function() return BP.SV.BeamScale end,
			setFunc = function(newValue) 
						BP.SV.BeamScale = newValue
						end,
		},
		[5] = {
			type = "editbox",
			name = "Icon Texture Path",
			tooltip = "Path to texture for icon used in Ping",
			isMultiline = false,
			default = "odysupporticons/icons/arrow.dds",
			getFunc = function() return BP.SV.TexturePath end,
			setFunc = function(newValue)
						if newValue == "" then
							newValue = "odysupporticons/icons/arrow.dds"
						end
						BP.SV.TexturePath = newValue
						end,
		},
		[6] = {
			type = "slider",
			name = "Icon Offset",
			tooltip = "Adjusts the height of where the icon starts",
			min = 0,
			max = 10,
			step = 0.1,
			default = 2.5,
			decimals = 1,
			getFunc = function() return BP.SV.IconOffset end,
			setFunc = function(newValue) 
						BP.SV.IconOffset = newValue
						end,
		},
		[7] = {
			type = "slider",
			name = "Icon Size",
			tooltip = "Adjusts the size of where the icon",
			min = 0,
			max = 10,
			step = 0.1,
			default = 2,
			decimals = 1,
			getFunc = function() return BP.SV.IconSize end,
			setFunc = function(newValue) 
						BP.SV.IconSize = newValue
						end,
		},
		[8] = {
			type = "editbox",
			name = "Sound Effect",
			tooltip = "Name of sound effect to play when a ping is made.",
			isMultiline = false,
			default = "Duel_Accepted",
			getFunc = function() return BP.SV.Sound end,
			setFunc = function(newValue)
						if newValue == "" then
							newValue = "Duel_Accepted"
						end
						BP.SV.Sound = newValue
						end,
		},
		[9] = {
			type = "checkbox",
			name = "Only see group leader pings.",
			getFunc = function() return BP.SV.CrownOnly end,
			setFunc = function(value) BP.SV.CrownOnly = value end,
			default = false,
		}
	}
	
	LAM2:RegisterOptionControls("BaitPingsPanel", optionsData)
	d("test")
end

EVENT_MANAGER:RegisterForEvent( ADDON_NAME, EVENT_ADD_ON_LOADED, function( _, addonName )
    if addonName ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent( ADDON_NAME, EVENT_ADD_ON_LOADED )
	
	BP.CreateSettingsWindow()
	ZO_CreateStringId("SI_BINDING_NAME_BP_CREATE_PING", "Create Ping")
	--ZO_CreateStringId("SI_BINDING_NAME_BP_DEBUG", "Debug")
	BP.Default = {
		BeamColor = {0, 0, 1, 1},
		BeamScale = 1,
		TexturePath = "odysupporticons/icons/arrow.dds",
		IconOffset = 2.5,
		IconSize = 2,
		Sound = "Duel_Accepted",
		CrownOnly = false
	}
	BP.SV = ZO_SavedVars:NewAccountWide("BaitPingsVars", "1.0", nil, BP.Default)
end )

LocalCallbackManager:RegisterCallback(EVENT_PING_CREATED, function(...) BP.CreateNewPing(...) end)
share = LibDataShare:RegisterMap(ADDON_NAME, 31, HandleData)