--[[

WhatBarAmIOn
by: @CyberOnEso

--]]


WhatBarAmIOn = {}

WhatBarAmIOn.name = "WhatBarAmIOn"
WhatBarAmIOn.version = 1
WhatBarAmIOn.bar = 1

 
WhatBarAmIOn.Default = {
	OffsetX = 20,
	OffsetY = 75
}
 
function BarUIUpdate()
    BarUIText:SetText(string.format("Bar: %d", WhatBarAmIOn.bar))
end
 
function BarUIInitialized()
	WhatBarAmIOn.savedVariables  = ZO_SavedVars:NewAccountWide("WhatBarAmIOn", WhatBarAmIOn.version, nil, WhatBarAmIOn.Default)
	BarUI:ClearAnchors()
	BarUI:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, WhatBarAmIOn.savedVariables.OffsetX, WhatBarAmIOn.savedVariables.OffsetY)
end

function BarUISaveLoc()
	WhatBarAmIOn.savedVariables.OffsetX = BarUI:GetLeft()
	WhatBarAmIOn.savedVariables.OffsetY = BarUI:GetTop()
end

function OnWeaponBarSwitch(eventcode, activeWeaponPair, locked)
	WhatBarAmIOn.bar = activeWeaponPair
end

EVENT_MANAGER:RegisterForEvent(WhatBarAmIOn.name, EVENT_ACTIVE_WEAPON_PAIR_CHANGED, OnWeaponBarSwitch)
