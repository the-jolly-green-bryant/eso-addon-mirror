---------------------------------
-- SETTINGS, GLOBALS AND DEFAULTS
---------------------------------
FightingDisplay = {
	name = "FightingDisplay",
	author = "@Duesentrieb",
	version = "20250909-1138",

	------------------------------------------------------------
	-- 1) TEXT OF THE NOTIFICATION WHEN ENTERING COMBAT
	displayText = "Fighting!",
	------------------------------------------------------------
	-- 2) COLOR OF THE TEXT NOTIFICATION IN RGBA {r, g, b, a}
	fontColor = {1, 0, 0, 1},
	------------------------------------------------------------
	-- 3) FONT SIZE OF THE TEXT NOTIFICATION
	fontSize = 36,
	------------------------------------------------------------
	-- 4) ENABLE SNAP TO HORIZONTAL / VERTICAL CENTER WHEN CLOSE
	isSnapToGrid = true,
	------------------------------------------------------------

	default = {
		offsetX = 0,
		offsetY = 0,
	},

	sVar = {},
	sVarVersion = 1,
	sVarName = "FightingDisplayVariables",
}

local display = GetControl("FightingDisplayControl")
local displayLabel = GetControl("FightingDisplayControlLabel")
local displayBackdrop = GetControl("FightingDisplayControlBackdrop")

--------------------------------
-- ENABLES THE NOTIFICATION TEXT
--------------------------------
function FightingDisplay.showNotification()
	displayLabel:SetText(FightingDisplay.displayText)
	displayLabel:SetColor(unpack(FightingDisplay.fontColor))
	displayLabel:SetFont("$(BOLD_FONT)|" .. FightingDisplay.fontSize .. "|soft-shadow-thick")

	local width = displayLabel:GetStringWidth(displayLabel:GetText())
	local height = displayLabel:GetTextHeight()
	display:SetDimensions(width, height)

	display:SetHidden(false)
end

--------------------------
-- HIDES NOTIFICATION TEXT
--------------------------
function FightingDisplay.hideNotification()
	displayBackdrop:SetHidden(true)
	display:SetHidden(true)
end

--------------------------------
-- SNAP TO GRID AND SAVE TO SVAR
--------------------------------
function FightingDisplay.savePosition()
    local centerX, centerY = display:GetCenter()

    local screenCenterX = GuiRoot:GetWidth() / 2
    local screenCenterY = GuiRoot:GetHeight() / 2

    local offsetX = centerX - screenCenterX
    local offsetY = centerY - screenCenterY

    if FightingDisplay.isSnapToGrid then
        if math.abs(offsetX) < GuiRoot:GetWidth() / 20 then offsetX = 0 end
        if math.abs(offsetY) < GuiRoot:GetHeight() / 20 then offsetY = 0 end
    end

    FightingDisplay.sVar.offsetX = offsetX
    FightingDisplay.sVar.offsetY = offsetY

    display:ClearAnchors()
    display:SetAnchor(CENTER, GuiRoot, CENTER, FightingDisplay.sVar.offsetX , FightingDisplay.sVar.offsetY)
end

----------------------------------------------------
-- CENTER OF THE SCREEN (SLIGHTLY OFFSET VERTICALLY)
----------------------------------------------------
function FightingDisplay.setDefaultPosition()
	local offsetY = GuiRoot:GetHeight() / 4

	display:ClearAnchors()
	display:SetAnchor(CENTER, GuiRoot, CENTER, 0, -offsetY)

	FightingDisplay.savePosition()
end

---------------------------------------------------------------------------------------------------------------
-- EVENT_MANAGER:RegisterForEvent(FightingDisplay.name, EVENT_PLAYER_COMBAT_STATE, FightingDisplay.combatState)
-- EVENT_MANAGER:RegisterForEvent(FightingDisplay.name, EVENT_PLAYER_ACTIVATED, FightingDisplay.combatState)
---------------------------------------------------------------------------------------------------------------
function FightingDisplay.combatState()
	local isCombat = IsUnitInCombat("player")

	if isCombat then FightingDisplay.showNotification()
	else FightingDisplay.hideNotification() end
end

-----------------------
-- ENABLE EVENT_MANAGER
-----------------------
function FightingDisplay.Enable()
	EVENT_MANAGER:RegisterForEvent(FightingDisplay.name, EVENT_PLAYER_COMBAT_STATE, FightingDisplay.combatState)
	EVENT_MANAGER:RegisterForEvent(FightingDisplay.name, EVENT_PLAYER_ACTIVATED, FightingDisplay.combatState)
end

-----------------------------------------
-- INITIALIZE OF SVAR, DISPLAY AND ENABLE
-----------------------------------------
function FightingDisplay.Initialize()
	FightingDisplay.sVar = ZO_SavedVars:NewAccountWide(FightingDisplay.sVarName, FightingDisplay.sVarVersion, nil, FightingDisplay.default)

	if (FightingDisplay.sVar.offsetX == FightingDisplay.default.offsetX and FightingDisplay.sVar.offsetY == FightingDisplay.default.offsetY) then
		FightingDisplay.setDefaultPosition()
	else
		display:ClearAnchors()
		display:SetAnchor(CENTER, GuiRoot, CENTER, FightingDisplay.sVar.offsetX , FightingDisplay.sVar.offsetY)
	end

	FightingDisplay.Enable()
	FightingDisplay.hideNotification()
end

-------------------------------------------------
-- EVENT MANAGER INITIAL CALL EVENT_ADD_ON_LOADED
-------------------------------------------------
function FightingDisplay.addOnLoaded(event, addonName)
	if addonName == FightingDisplay.name then
		FightingDisplay.Initialize()

		EVENT_MANAGER:UnregisterForEvent(FightingDisplay.name, EVENT_ADD_ON_LOADED)
	end
end

EVENT_MANAGER:RegisterForEvent(FightingDisplay.name, EVENT_ADD_ON_LOADED, FightingDisplay.addOnLoaded)