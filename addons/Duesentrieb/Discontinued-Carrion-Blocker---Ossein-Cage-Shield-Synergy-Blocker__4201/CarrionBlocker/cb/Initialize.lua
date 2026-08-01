local CB = CarrionBlocker
local display = GetControl("CarrionBlockerDisplay")
local displayLabel = GetControl("CarrionBlockerDisplayLabel")
local displayBackdrop = GetControl("CarrionBlockerDisplayBackdrop")

function CB:Initialize()
	CB.sVar = ZO_SavedVars:NewAccountWide(CB.sVarName, CB.sVarVersion, nil, CB.default)

	display:SetHidden(true)
	displayBackdrop:SetHidden(true)
	displayLabel:SetText(CB.sVar.displayText)
	displayLabel:SetColor(unpack(CB.sVar.fontColor))
	CB.setFontSize(display, displayLabel, CB.sVar.fontSize)

	if (CB.sVar.offsetX == CB.default.offsetX and CB.sVar.offsetY == CB.default.offsetY) then
		CB.setDefaultPosition()
	else
		display:ClearAnchors()
		display:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, CB.sVar.offsetX, CB.sVar.offsetY)
	end

	if CB.sVar.isEnabled then CB.Enable() end

	CB.createSettingsWindow()
	CB.isLoaded = true
end

function CB.addOnLoaded(_, name)
	if name == CB.name then
		CB:Initialize()
		EVENT_MANAGER:UnregisterForEvent(CB.name, EVENT_ADD_ON_LOADED)
	end
end

EVENT_MANAGER:RegisterForEvent(CB.name, EVENT_ADD_ON_LOADED, CB.addOnLoaded)