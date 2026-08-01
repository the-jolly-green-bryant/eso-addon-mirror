local VPP 					= VisiblePickpocketPing

local function getSettings()
	return VisiblePickpocketPing.settings
end
local function getControl()
	return VisiblePickpocketingIndicator
end
local function getLockButton()
	return getControl():GetNamedChild("LockButton")
end



 function VPP.get(key)
 	if nil == key then return end
 	return getSettings()[key]
 end

 function VPP.set(key, value)
 	if nil == key then return end
 	getSettings()[key] = value
 end
 
function VPP.SaveControl()	
	getSettings().width 	 = getControl():GetWidth()
	getSettings().height  	 = getControl():GetHeight()
	getSettings().offsetX = getControl():GetLeft()
	getSettings().offsetY = getControl():GetTop()
end

function VPP.LoadControlPosition()
	getControl():SetWidth(getSettings().width)
	getControl():SetHeight(getSettings().height)
end 
 

function VPP.LoadControlSize()
	getControl():SetAnchor(TOPLEFT, GUI_ROOT, TOPLEFT, getSettings().offsetX, getSettings().offsetY)
end
 
 function VPP.SetLocked(value)
	getLockButton():SetHidden(value)
	getSettings().locked = value
	getControl():SetMovable(not value)
	getControl():SetHidden(not value)
	getControl():SetMouseEnabled(not value)
	local bgAlpha = (value and "0.0") or "1.0"
	getControl():GetNamedChild("Bg"):SetAlpha(bgAlpha)
 end
 
 function VPP.SetColor(r, g, b, a)
	getSettings().r = r
	getSettings().g = g
	getSettings().b = b
	getSettings().a = a
	getControl():GetNamedChild("Tex"):SetColor(r, g, b, a)
 end
 
 function VPP.SetColorVisible(r, g, b, a)
	getSettings().rVisible = r
	getSettings().gVisible = g
	getSettings().bVisible = b
	getSettings().aVisible = a
	getControl():GetNamedChild("Tex"):SetColor(r, g, b, a)
 end
 
 function VPP.DeactivateWarningColor(value)
	getSettings().noWarning = value
 end
 

 function VPP.SetIcon(tex)
	getSettings().icon = tex
	getControl():GetNamedChild("Tex"):SetTexture(tex)
 end