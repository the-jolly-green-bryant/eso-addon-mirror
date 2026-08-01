local SU = StaggerUptime
local display = GetControl("StaggerUptimeDisplay")
local displayLabel = GetControl("StaggerUptimeDisplayLabel")
local displayBackdrop = GetControl("StaggerUptimeDisplayBackdrop")

---------------------------------------
-- INITIALIZE OF SVAR, DISPLAY AND MENU
---------------------------------------
function SU:Initialize()
	SU.sVar = ZO_SavedVars:NewAccountWide(SU.sVarName, SU.sVarVersion, nil, SU.default)
	display:SetHidden(true)
	displayBackdrop:SetHidden(true)
	displayLabel:SetText(SU.displayText)
	displayLabel:SetColor(unpack(SU.fontColor))
	SU.setFontSize(display, displayLabel, SU.sVar.fontSize)
	if (SU.sVar.offsetX == SU.default.offsetX and SU.sVar.offsetY == SU.default.offsetY) then
		SU.setDefaultPosition()
	else
		display:ClearAnchors()
		display:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, SU.sVar.offsetX, SU.sVar.offsetY)
	end
	SU.createSettingsWindow()
	if SU.sVar.isEnabled then
		SU.Enable()
	end
end

-----------------------------
-- EVENT MANAGER INITIAL CALL
-----------------------------
function SU.addOnLoaded(_, name)
	if name == SU.name then
		SU:Initialize()
		EVENT_MANAGER:UnregisterForEvent(SU.name, EVENT_ADD_ON_LOADED)
	end
end
EVENT_MANAGER:RegisterForEvent(SU.name, EVENT_ADD_ON_LOADED, SU.addOnLoaded)