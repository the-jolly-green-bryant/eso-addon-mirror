local CoordsAndHeading = {
name = "CoordsAndHeading",
last_worldX = 0,
last_worldY = 0,
last_heading = 0,
last_camHeading = 0,
}
CoordsAndHeading.SavedVars = {
		offSetX = 0,
		offSetY = 0,
		point = TOPLEFT,
		relativePoint = TOPLEFT,
		moveable = true,
		alpha = 0,
}


function CoordsAndHeading.Reset()
	CoordsAndHeadingUI:ClearAnchors()
	CoordsAndHeadingUI:SetAnchor(TOPLEFT,GuiRoot,TOPLEFT,0,0)
	CoordsAndHeading.Unlock()
	d("reseted")
end


function CoordsAndHeading.OnAddOnLoaded( eventCode, addOnName )
	if ( addOnName ~= CoordsAndHeading.name ) then return end
	
	EVENT_MANAGER:UnregisterForEvent(CoordsAndHeading.name, EVENT_ADD_ON_LOADED)
	
    local accountSavedVars = ZO_SavedVars:NewAccountWide(CoordsAndHeading.name, 1, nil, CoordsAndHeading.SavedVars)

    if accountSavedVars ~= nil then
        CoordsAndHeading.SavedVars = accountSavedVars
    end
	
--[[
SetAnchor
AnchorPosition  	point	The position of the anchor on the control that is set.
object				anchorTargetControl  	The control this control shall anchor to.
AnchorPosition  	relativePoint	The position of the anchor on the anchorTargetControl.
number				offsetX	The horizontal offset relative to the point position.
number				offsetY	The vertical offset relative to the point position.
]]--


	CoordsAndHeadingUI:ClearAnchors()
	CoordsAndHeadingUI:SetAnchor(CoordsAndHeading.SavedVars.point,
	nil,
	CoordsAndHeading.SavedVars.relativePoint,
	CoordsAndHeading.SavedVars.offSetX,
	CoordsAndHeading.SavedVars.offSetY)
	
	CoordsAndHeadingUI:SetMovable(CoordsAndHeading.SavedVars.moveable)
	CoordsAndHeadingUI_Backdrop:SetAlpha(CoordsAndHeading.SavedVars.alpha)
	
	CoordsAndHeadingUI:SetClampedToScreen(true)
    CoordsAndHeadingUI:SetResizeToFitDescendents(true)
    CoordsAndHeadingUI:SetMouseEnabled(true)
    CoordsAndHeadingUI:SetHidden(false)
	
	
    
	CoordsAndHeadingUI:SetHandler("OnMoveStop", CoordsAndHeading.OnMoveStop)
	CoordsAndHeadingUI:SetHandler("OnUpdate",   CoordsAndHeading.OnUpdate)
	
    SLASH_COMMANDS["/coh"] = CoordsAndHeading.Slash
	
	
end
EVENT_MANAGER:RegisterForEvent( CoordsAndHeading.name, EVENT_ADD_ON_LOADED, CoordsAndHeading.OnAddOnLoaded )

function CoordsAndHeading.Slash(text)
	text = string.lower(text)
	if text == "transparent" then
		CoordsAndHeading.SavedVars.alpha = 0
		CoordsAndHeadingUI_Backdrop:SetAlpha(0)
		--CoordsAndHeadingUI_Backdrop:SetEdgeColor(1,1,1)
		--CoordsAndHeadingUI_Backdrop:SetCenterColor(1,1,1)
	elseif text == "fontwhite" then
		CoordsAndHeadingUI_Label:SetColor(255,255,255) -- sets font color to white
	elseif text == "fontblack" then
		CoordsAndHeadingUI_Label:SetColor(0,0,0) -- sets font color to black
	elseif text == "nottransparent" then
		CoordsAndHeading.SavedVars.alpha = 1
		CoordsAndHeadingUI_Backdrop:SetAlpha(1)
	elseif text == "lock" then
		CoordsAndHeading.SavedVars.moveable = false
		CoordsAndHeadingUI:SetMovable(false)
	elseif text == "unlock" then
		CoordsAndHeading.SavedVars.moveable = true
		CoordsAndHeadingUI:SetMovable(true)
	else
		d("CoordsAndHeading doesn't know command: "..text)
		d("available args: transparent | nottransparent | Lock | Unlock | fontwhite | fontblack")
	end
end

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
function CoordsAndHeading.OnMoveStop(self)
	--d("OnMoveStop")
		--bool isValidAnchor, integer point, object relativeTo, integer relativePoint, number offsetX, number offsetY
		local validAnchor,point,relativeTo, relativePoint, offSetX, offSetY = self:GetAnchor()
		
		if validAnchor then
				CoordsAndHeading.SavedVars.offSetX = offSetX
				CoordsAndHeading.SavedVars.offSetY = offSetY
				CoordsAndHeading.SavedVars.point 		= point
				CoordsAndHeading.SavedVars.relativePoint = relativePoint
		end
end
