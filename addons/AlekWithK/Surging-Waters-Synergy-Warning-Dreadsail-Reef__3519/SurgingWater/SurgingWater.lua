SurgingWater = SurgingWater or {}
SurgingWater.name = "SurgingWater"
SurgingWater.author = "|c1cf9e4A|r|c39f3cal|r|c55eeb1e|r|c71e897k|r|c8ee27dW|r|caadc63i|r|cc6d74at|r|ce3d130h|r|cffcb16K|r"
SurgingWater.version = "1.0.0"

--User setting defaults, note to self: struct next time
SurgingWater.unlockedUI = true
SurgingWater.isVet = false
SurgingWater.warnText = "BEWARE SYNERGY!"
SurgingWater.threshold = 15
SurgingWater.warnColor = {1, 0, 0, 1} --Red
SurgingWater.warnSize = 40
SurgingWater.xOffSet = 1000
SurgingWater.yOffSet = 500

local IN_PORTAL = false

--SurgingWater.isVet = IsGroupUsingVeteranDifficulty()

--Initialize post-load events
function SurgingWater.Init()
	--Call menu creation function in SurgingWaterMenu.lua
	SurgingWater.AddonMenu()	
	--Register the two events needed, POWER_UPDATE for continous health check, and RETICLE for toggling on screen warning on/off
	EVENT_MANAGER:RegisterForEvent(SurgingWater.name, EVENT_POWER_UPDATE, SurgingWater.WarningTrigger)
	EVENT_MANAGER:RegisterForEvent(SurgingWater.name, EVENT_RETICLE_TARGET_CHANGED, SurgingWater.PortalStatus)

	--Initialize saved variables file
	SurgingWater.savedVariables = ZO_SavedVars:NewAccountWide("SurgingWaterSavedVariables", 1, nil, {})
	
	--Initialize constants with saved variables, if they exist
	SurgingWater.warnText = SurgingWater.savedVariables.warnText or SurgingWater.warnText
	SurgingWater.threshold = SurgingWater.savedVariables.threshold or SurgingWater.threshold	
	SurgingWater.warnColor = SurgingWater.savedVariables.warnColor or SurgingWater.warnColor
	SurgingWater.warnSize = SurgingWater.savedVariables.warnSize or SurgingWater.warnSize

	SurgingWater.RestorePos()
end

--Set a flag so we know when looking at a reef heart
function SurgingWater.PortalStatus()
	local target = GetUnitNameHighlightedByReticle()

	--Check for reef heart and toggle warning off when looking away/upstairs
	if target == "Reef Heart" then
		IN_PORTAL = true
	else 
		IN_PORTAL = false
		SurgingWaterIndicator:SetHidden(true)
	end
end

--Check Reef Heart health on combat action
function SurgingWater.WarningTrigger()
	local curr_hp, max_hp = GetUnitPower("reticleover", POWERTYPE_HEALTH)

	--Toggle warning on when threshold reached and target == reef heart
	if (curr_hp / max_hp < (SurgingWater.threshold / 100) and IN_PORTAL) then
		SurgingWaterIndicatorLabel:SetText(SurgingWater.warnText)
		SurgingWaterIndicatorLabel:SetColor(unpack(SurgingWater.warnColor))		
    	SurgingWaterIndicator:SetHidden(false)
	end
end 

--Unregister events
function SurgingWater.UnInit()
	EVENT_MANAGER:UnregisterForEvent(SurgingWater.name, EVENT_POWER_UPDATE, SurgingWater.WarningTrigger)
	EVENT_MANAGER:UnregisterForEvent(SurgingWater.name, EVENT_RETICLE_TARGET_CHANGED, SurgingWater.PortalStatus)	
end

--User position settings
function SurgingWater.OnIndicatorMoveStop()
	SurgingWater.savedVariables.left = SurgingWaterIndicator:GetLeft()
	SurgingWater.savedVariables.top = SurgingWaterIndicator:GetTop()
end

--Restore saved positions from saved variables on addon init (or default if no saved var)
function SurgingWater.RestorePos()
	local left = SurgingWater.savedVariables.left or SurgingWater.xOffSet
	local top = SurgingWater.savedVariables.top or SurgingWater.yOffSet

	SurgingWaterIndicator:ClearAnchors()
	SurgingWaterIndicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

--Move Warning
function SurgingWater.MoveWarning()
	--Display warning so it's moveable
	if SurgingWater.unlockedUI then
		SurgingWaterIndicatorLabel:SetText(SurgingWater.warnText)
		SurgingWaterIndicatorLabel:SetColor(unpack(SurgingWater.warnColor))
		SurgingWaterIndicator:SetHidden(false)
	else
		SurgingWaterIndicator:SetHidden(true)
	end
end

--Save user variables
function SurgingWater.EditWarning(text)
	SurgingWater.savedVariables.warnText = text
end
function SurgingWater.EditThreshold(value)
	SurgingWater.savedVariables.threshold = value
end
function SurgingWater.WarnColor(r, g, b, a)
	SurgingWater.savedVariables.warnColor = {r, g, b, a}
end
function SurgingWater.EditSize(size)
	SurgingWater.savedVariables.warnSize = size
	SurgingWaterIndicatorLabel:SetFont(string.format('%s|%d|%s', '$(BOLD_FONT)', size, 'soft-shadow-thick'))
end

--Addon initializer
function SurgingWater.OnAddOnLoaded(event, addonName)
    if addonName == SurgingWater.name then
		  SurgingWater.Init()
		  EVENT_MANAGER:UnregisterForEvent(SurgingWater.name, EVENT_ADD_ON_LOADED) 
    end
end

EVENT_MANAGER:RegisterForEvent(SurgingWater.name, EVENT_ADD_ON_LOADED, SurgingWater.OnAddOnLoaded)