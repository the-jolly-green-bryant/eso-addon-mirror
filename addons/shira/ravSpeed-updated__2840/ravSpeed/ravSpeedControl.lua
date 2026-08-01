------------------------
-- ravSpeed
-- original addon by rav
-- https://www.esoui.com/downloads/info423-ravSpeed.html
--
-- Control.lua


-----------------------
-- whether to display or not

function ravSpeed.OnActionLayerChange(_, _, activeLayerIndex)
	ravSpeedCtrl:SetHidden(activeLayerIndex > 2 and not ravSpeed.SV.forceShow)
end


-----------------------
-- OnMouseUp

function ravSpeed.saveWindowPos()
	local isValidAnchor, point, relativeTo, relativePoint, offsetX, offsetY = ravSpeedCtrl:GetAnchor()

	if (isValidAnchor) then
		ravSpeed.SV.ctrlPos = {point, relativePoint, offsetX, offsetY}
	end
end


-----------------------
-- init

function ravSpeed.setFont()
	ravSpeedCtrlUps:SetFont(string.format("$(%s)|$(KB_%s)|%s", ravSpeed.SV.fontName, ravSpeed.SV.fontSize, ravSpeed.SV.fontStyle))
	ravSpeedCtrlUps:SetColor(unpack(ravSpeed.SV.fontColor))
	ravSpeedCtrlPct:SetFont(string.format("$(%s)|$(KB_%s)|%s", ravSpeed.SV.fontName, ravSpeed.SV.fontSize, ravSpeed.SV.fontStyle))
	ravSpeedCtrlPct:SetColor(unpack(ravSpeed.SV.fontColor))
end


function ravSpeed.setLock()
	ravSpeedCtrl:SetMovable(not ravSpeed.SV.isLocked)
end


function ravSpeed.setPosition()
	local point, relativePoint, offsetX, offsetY = unpack(ravSpeed.SV.ctrlPos)
	ravSpeedCtrl:ClearAnchors()
	ravSpeedCtrl:SetAnchor(point, ravSpeedCtrl.parent, relativePoint, offsetX, offsetY)
end


function ravSpeed.setDisplay()

	local coef

	if ravSpeed.SV.displayStyle == "UPS %" then
		coef = -1
	elseif ravSpeed.SV.displayStyle == "% UPS" then
		coef = 1
	else
		coef = 0
	end

	ravSpeedCtrlPct:ClearAnchors()
	ravSpeedCtrlUps:ClearAnchors()
	ravSpeedCtrlPct:SetAnchor(CENTER, ravSpeedCtrl, CENTER, (-coef)*ravSpeed.SV.fontSize*1.66, 0)
	ravSpeedCtrlUps:SetAnchor(CENTER, ravSpeedCtrl, CENTER, coef*ravSpeed.SV.fontSize*1.66, 0)


	ravSpeedCtrlPct:SetHidden(not ravSpeed.SV.showPct)
	ravSpeedCtrlUps:SetHidden(not ravSpeed.SV.showUps)

end


-----------------------
-- call in main

function ravSpeed.initControl()
	ravSpeed.setDisplay()
	ravSpeed.setFont()
	ravSpeed.setLock()
	ravSpeed.setPosition()
end