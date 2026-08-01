local SU = StaggerUptime
local display = GetControl("StaggerUptimeDisplay")
local displayLabel = GetControl("StaggerUptimeDisplayLabel")

--------------------------------------
-- SET FONT SIZE FOR NOTIFICATION TEXT
--------------------------------------
function SU.setFontSize(control, label, size)
	label:SetFont("$(BOLD_FONT)|" .. size .. "|soft-shadow-thick")
	SU.setDimensions()
end

-----------------------------------------------------------------------
-- SET DIMENSION OF THE TEXT BOX DEPENDING ON FONT SIZE AND TEXT LENGHT
-----------------------------------------------------------------------
function SU.setDimensions()
	local stringWidth = displayLabel:GetStringWidth(displayLabel:GetText())
	local textHeight = displayLabel:GetTextHeight()
	display:SetDimensions(stringWidth, textHeight)
end

---------------------------------------------------------------------------
-- ENABLES THE NOTIFICATION TEXT AND SHOWS COMBATALERTS SCREEN BORDER COLOR
---------------------------------------------------------------------------
function SU.showNotification()
	displayLabel:SetText(SU.displayText)
	displayLabel:SetColor(unpack(SU.fontColor))
	SU.setFontSize(display, displayLabel, SU.sVar.fontSize)
	SU.setDimensions()
	display:SetHidden(false)
end

---------------------------------------------------------------
-- HIDES NOTIFICATION TEXT AND COMBATALERTS SCREEN BORDER COLOR
---------------------------------------------------------------
function SU.hideNotification()
	if SU.isForceShow then return end
	display:SetHidden(true)
end

------------------------------
-- CENTER MIDDLE OF THE SCREEN
------------------------------
function SU.setDefaultPosition()
	display:ClearAnchors()
	display:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
	SU.savePosition()
end

----------------------------
-- SAVE NEW POSITION IN sVar
----------------------------
function SU.savePosition()
	SU.sVar.offsetX = display:GetLeft()
	SU.sVar.offsetY = display:GetTop()
	display:ClearAnchors()
	display:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, SU.sVar.offsetX, SU.sVar.offsetY)
end