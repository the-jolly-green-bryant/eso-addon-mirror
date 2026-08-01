local LAM = LibAddonMenu2

local CoordsAndHeading = {
name = "CoordsAndHeading",
last_worldX = 0,
last_worldY = 0,
last_heading = 0,
last_camHeading = 0,
}

CoordsAndHeading.Default = {
		offSetX = 0,
		offSetY = 0,
		point = TOPLEFT,
		relativePoint = TOPLEFT,
		alpha = 1,
		r = 0,
		g = 0,
		b = 0,
		Show =  false,
		isMovable = false,
		FontColor = {255,255,255,1},
		scale = 1,
}

CoordsAndHeading.name = "CoordsAndHeading"
CoordsAndHeading.variableVerison = 3

function CoordsAndHeading:Initialize()

	-- Saving Defaults Account Wide
	CoordsAndHeading.SavedVariables = ZO_SavedVars:NewAccountWide("CoordsAndHeadingVars", CoordsAndHeading.variableVerison, nil, CoordsAndHeading.Default)

	-- Creating Settings Menu and Calling OnMoveStop & Update methods
	CoordsAndHeading.CreateSettingsWindow()
	CoordsAndHeadingUI:SetHandler("OnMoveStop", CoordsAndHeading.OnMoveStop)
	CoordsAndHeadingUI:SetHandler("OnUpdate",  CoordsAndHeading.OnUpdate)


	-- Setting Up Initial Default Values
	CoordsAndHeadingUI:SetHidden(CoordsAndHeading.SavedVariables.Show)
	CoordsAndHeadingUI:SetMovable(CoordsAndHeading.SavedVariables.isMoveable)
	CoordsAndHeadingUI_Label:SetColor(unpack(CoordsAndHeading.SavedVariables.FontColor))
	CoordsAndHeadingUI_Label:SetScale(CoordsAndHeading.SavedVariables.scale)

	
	-- Not sure exactly what this does but something to do with XML positing
	CoordsAndHeadingUI:ClearAnchors();
	CoordsAndHeadingUI:SetAnchor(CoordsAndHeading.SavedVariables.point,
	nil,
	CoordsAndHeading.SavedVariables.relativePoint,
	CoordsAndHeading.SavedVariables.offSetX,
	CoordsAndHeading.SavedVariables.offSetY)

	-- Unregistering from the Event
	EVENT_MANAGER:UnregisterForEvent(CoordsAndHeading.name, EVENT_ADD_ON_LOADED)

end

function CoordsAndHeading.OnAddOnLoaded( eventCode, addOnName )
	if ( addOnName ~= CoordsAndHeading.name ) then return end
	CoordsAndHeading:Initialize()
end

-- Calculates the plaers position and updates it constantly

function CoordsAndHeading.OnUpdate()
	--d("OnUpdate")
	
	local unitID = "player"
	local _x, _y, heading, isShownInCurrentMap = GetMapPlayerPosition(unitID)
	
	local coeffz = 359/628 * 100
	heading = heading * coeffz
	heading = zo_round(heading)
	local camHeading = GetPlayerCameraHeading() * coeffz
	camHeading = zo_round(camHeading)
	
	local zoneId, worldX, worldZ, worldY = GetUnitWorldPosition(unitID)
	
	if (CoordsAndHeading.last_worldX == worldX and 
		CoordsAndHeading.last_worldY == worldY and 
		CoordsAndHeading.last_heading == heading and
		CoordsAndHeading.last_camHeading == camHeading) then return end


	CoordsAndHeading.last_worldX = worldX
	CoordsAndHeading.last_worldY = worldY
	CoordsAndHeading.last_heading = heading
	CoordsAndHeading.last_camHeading = camHeading

	local result= "X:  "
	if ( worldX ~= nil ) then
	   result = result..worldX
	end
	result=result.."\nY:  "
	if ( worldY ~= nil ) then
	   result = result..worldY
	end
	result=result.."\nZ:  "
	if ( worldZ ~= nil ) then
	   result = result..worldZ
	end
	result=result.."\nZoneId:  "
	if ( zoneId ~= nil ) then
	   result = result..zoneId
	end
	local mainZone = ZO_CachedStrFormat(SI_ZONE_NAME, GetUnitZone(unitID))
	result=result.."\nMainZone: "
	if ( mainZone ~= nil ) then
	   result = result..mainZone
	end
	local subZone = ZO_CachedStrFormat(SI_ZONE_NAME, GetPlayerLocationName())
	result=result.."\nSubZone:   "
	if ( subZone ~= nil ) then
	   result = result..subZone
	end
	result=result.."\nCharHeading:  "
	if ( heading ~= nil ) then
	   result = string.format(result.."%.0f°", heading)
	end
	result=result.."\nCameraHeading:  "
	if ( camHeading ~= nil ) then
	   result = string.format(result.."%.0f°", camHeading)
	end

	CoordsAndHeadingUI_Label:SetText(result)
	
end

-- When ui has stopped moving then it saves the stopped position 
function CoordsAndHeading.OnMoveStop(self)
	--d("OnMoveStop")
		--bool isValidAnchor, integer point, object relativeTo, integer relativePoint, number offsetX, number offsetY
		local validAnchor,point,relativeTo, relativePoint, offSetX, offSetY = self:GetAnchor()
		
		if validAnchor then
				CoordsAndHeading.SavedVariables.offSetX = offSetX
				CoordsAndHeading.SavedVariables.offSetY = offSetY
				CoordsAndHeading.SavedVariables.point = point
				CoordsAndHeading.SavedVariables.relativePoint = relativePoint
		end
end

-- Settings Menu

function CoordsAndHeading.CreateSettingsWindow()
	local panelData = {
		type = "panel",
	    name = "CoordsAndHeading",
	    displayName = "CoordsAndHeading",
	    author = "Andre, TheNamesJT",
	    version = CoordsAndHeading.version,
	    slashCommand = "/coh",
	    registerForRefresh = false,
	    registerForDefaults = true,
	}
	local cntrlOptionsPanel = LAM:RegisterAddonPanel("Coords_AndHeading", panelData)
	local optionsData = {
		[1] = {
            type = "header",
            name = "CoordsAndHeading",

        },

        [2] = {
            type="description",
            text="Here you can adjust CoordsAndHeading",
		},
		
		[3] = {

            type ="checkbox",
            name = "Show/Hide CoordsAndHeading",
            tooltip = "When On CoordsAndHeading will be Hidden. When OFF CoordsAndHeading will be Visible",
            default = false,
            getFunc = function () return CoordsAndHeading.SavedVariables.Show end,
            setFunc = function (newValue)
                CoordsAndHeading.SavedVariables.Show = newValue
                CoordsAndHeadingUI:SetHidden(newValue) end,
		},

		[4] = {

            type ="checkbox",
            name = "Unlock/Lock",
            tooltip = "When Off CoordsAndHeading will be be not moveable.When On CoordsAndHeading will be moveable ",
            default = true,
            getFunc = function () return CoordsAndHeading.SavedVariables.Show end,
            setFunc = function (newValue)
                CoordsAndHeading.SavedVariables.isMovable = newValue
                CoordsAndHeadingUI:SetMovable(newValue) end,
		},

		[5] = {
			type = "slider",
	        name = "Select Scale",
	        tooltip = "Adjusts the scale of the font. Maye have issues with backdrop",
	        min = 0.75,
	        max = 2.5,
	        step = 0.25,
	        default = 1,
	        getFunc = function() return CoordsAndHeading.SavedVariables.scale end,
	        setFunc = function(newValue)
                CoordsAndHeading.SavedVariables.scale = newValue
                CoordsAndHeadingUI_Label:SetScale(newValue)
                end,
		},
		
		[6] = {
            type = "submenu",
            name = "Colors",
            tooltip = "Allows you to change colors.",
            controls = {
                    [1] = {
                        type = "colorpicker",
						name = "Color",
                        tooltip = "Changes the color of the font!",
                        getFunc = function () return unpack(CoordsAndHeading.SavedVariables.FontColor) end,
                        setFunc = function (r,g,b,a)
                            local alpha = CoordsAndHeadingUI_Label:GetAlpha()
                            CoordsAndHeading.SavedVariables.FontColor = {r,g,b,a}
                            CoordsAndHeadingUI_Label:SetColor(r,g,b,a)
                            end,
                },
            },
        },
	}
	LAM:RegisterOptionControls("Coords_AndHeading", optionsData)
end


-- Events

EVENT_MANAGER:RegisterForEvent( CoordsAndHeading.name, EVENT_ADD_ON_LOADED, CoordsAndHeading.OnAddOnLoaded )
