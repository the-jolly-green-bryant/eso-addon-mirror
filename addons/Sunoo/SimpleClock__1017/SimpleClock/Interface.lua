sc.ui = {
	styles = {
		'normal',
		'outline',
		'thick-outline',
		'shadow',
		'soft-shadow-thick',
		'soft-shadow-thin'
	}
}

function sc.ui:create()

	self.clock = CreateControlFromVirtual('SimpleClock', GuiRoot, 'SimpleClock')

	-- Allow the clock to go outside the screen's boundaries
	self.clock:SetClampedToScreen(false)

	-- Load the text alignment setting
	sc.ui:setAlignment(sc.sv.align)

	sc.ui:updateLabel()

end

function sc.ui:show()
	SimpleClock:SetAlpha(1)
end

function sc.ui:hide()
	SimpleClock:SetAlpha(0)
end

function sc.ui.toggleSetting(settingName)

	sc.sv[settingName] = not sc.sv[settingName]
	sc.ui:updateLabel()

	-- If the setting was hideWithOverlay, we need to show or hide the clock.
	if (sc.sv.hideWithOverlay == true) then
		sc.ui:hide()
	else
		sc.ui:show()
	end

end

function sc.ui.updateSetting(settingName, settingVal)

	sc.sv[settingName] = settingVal
	sc.ui:updateLabel()

end

function sc.ui:setAlignment(val)

	local x = sc.sv.offset.x
	local y = sc.sv.offset.y

	local alignMap = {
		Left   = { text = TEXT_ALIGN_LEFT,   anchor = LEFT },
		Right  = { text = TEXT_ALIGN_RIGHT,  anchor = RIGHT },
		Center = { text = TEXT_ALIGN_CENTER, anchor = CENTER }
	}

	SimpleClockLabel:SetHorizontalAlignment(alignMap[val].text)

	-- Need to clear anchors, since SetAnchor() will just keep adding new ones.
	self.clock:ClearAnchors();
	self.clock:SetAnchor(alignMap[val].anchor, GuiRoot, TOPLEFT, x, y)

	sc.sv.align = val

	sc:savePositions()

end

function sc.ui:getFontString()

	local fontPath = LMP:Fetch('font', sc.sv.fontFamily)
	local fontString = string.format('%s|%u|%s', fontPath, sc.sv.fontSize, sc.sv.fontStyle)

	return fontString

end

---
-- Applies any custom settings to the clock's label control.
function sc.ui:updateLabel(buffered)

	if ((sc.sv.hideWithOverlay == true) and ZO_Compass:IsHidden()) then
		sc.ui.hide()
	else
		sc.ui.show()
	end

	if buffered == true and not sc:bufferReached('clockUpdateBuffer', 1) then
		return
	end

	SimpleClockLabel:SetText(sc:getTimeString())

	local color = sc.sv.fontColor

	-- Update the label's font and colour, and then...
	SimpleClockLabel:SetFont(sc.ui:getFontString())
	SimpleClockLabel:SetColor(color.r, color.g, color.b, color.a)

	-- Need to reset dimensions to 0 (unlimited) otherwise the text could get
	-- truncated if the previous font size's bounding box was smaller. Then,
	-- when we want to use the TextDimensions, the width would be smaller since
	-- it was broken up in to separate lines! Computers, pfeh.
	self.clock:SetDimensions(0, 0)

	-- NOW set the TopLevelControl to the new dimensions.
	self.clock:SetDimensions(SimpleClockLabel:GetTextDimensions())

end