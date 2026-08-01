local CB = CarrionBlocker
local display = GetControl("CarrionBlockerDisplay")
local displayLabel = GetControl("CarrionBlockerDisplayLabel")

--------------------------------------
-- SET FONT SIZE FOR NOTIFICATION TEXT
--------------------------------------
function CB.setFontSize(control, label, size)
	label:SetFont("$(BOLD_FONT)|" .. size .. "|soft-shadow-thick")
	CB.setDimensions()
end

-----------------------------------------------------------------------
-- SET DIMENSION OF THE TEXT BOX DEPENDING ON FONT SIZE AND TEXT LENGHT
-----------------------------------------------------------------------
function CB.setDimensions()
	local stringWidth = displayLabel:GetStringWidth(displayLabel:GetText())
	local textHeight = displayLabel:GetTextHeight()
	display:SetDimensions(stringWidth, textHeight)
end

---------------------------------------------------------------------------
-- ENABLES THE NOTIFICATION TEXT AND SHOWS COMBATALERTS SCREEN BORDER COLOR
---------------------------------------------------------------------------
function CB.showNotification(colorHex, duration, string)
	if not colorHex or colorHex == "" then return end
	if not duration or duration == 0 then return end
	if not string or string == "" then return end
	local r, g, b = CB.hexToRgba(colorHex)
	local a = 1.0
	displayLabel:SetText(string)
	CB.setDimensions()
	displayLabel:SetColor(r,g,b,a)
	display:SetHidden(false)
	if CombatAlerts and CB.sVar.isShowBorderColor then CombatAlerts.ScreenBorderEnable(colorHex, duration, "CarrionBlocker") end
end

---------------------------------------------------------------
-- HIDES NOTIFICATION TEXT AND COMBATALERTS SCREEN BORDER COLOR
---------------------------------------------------------------
function CB.hideNotification()
	if CB.isForceShow then return end
	display:SetHidden(true)
	if CombatAlerts then CombatAlerts.ScreenBorderDisable("CarrionBlocker") end
end

---------------------------------------------------------------------
-- ELEMENT WILL SNAP TO CENTER X OR CENTER Y WHEN LESS THEN 50PX AWAY
---------------------------------------------------------------------
function CB.snapToGrid()
	display:ClearAnchors()
	display:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)

	local centerX = display:GetLeft()
	local centerY = display:GetTop()
	local offsetX = CB.sVar.offsetX - centerX
	local offsetY = CB.sVar.offsetY - centerY
	if offsetX < 100 and offsetX > -100 then
		offsetX = 0
	end
	if offsetY < 50 and offsetY > -50 then
		offsetY = 0
	end
	display:ClearAnchors()
	display:SetAnchor(CENTER, GuiRoot, CENTER, offsetX, offsetY)
	CB.sVar.offsetX = display:GetLeft()
	CB.sVar.offsetY = display:GetTop()
end

------------------------------------------------------------------------
-- element:SetAnchor(point, relativeTo, relativePoint, offsetX, offsetY)
------------------------------------------------------------------------
function CB.centerHorizontally()
	display:ClearAnchors()
	display:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
	local centerY = display:GetTop()
	local offsetY = CB.sVar.offsetY - centerY
	display:ClearAnchors()
	display:SetAnchor(CENTER, GuiRoot, CENTER, 0, offsetY)
	CB.savePosition()
end

------------------------------
-- CENTER MIDDLE OF THE SCREEN
------------------------------
function CB.setDefaultPosition()
	display:ClearAnchors()
	display:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
	CB.savePosition()
end

--------------------------------
-- SAVE IN sVar AND SNAP TO GRID
--------------------------------
function CB.savePosition()
	CB.sVar.offsetX = display:GetLeft()
	CB.sVar.offsetY = display:GetTop()
	if CB.sVar.isSnapToGrid then CB.snapToGrid() end
end