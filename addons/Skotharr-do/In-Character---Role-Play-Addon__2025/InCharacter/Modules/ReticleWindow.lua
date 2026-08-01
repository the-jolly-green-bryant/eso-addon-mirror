--[[
Title:   Reticle Window
Version: 1.1.3
Author:  @Skotharr-do [PC/EU]
--]]

IC.ReticleWindow = {}

local reticleWindow = {
		MARGIN = 10,
		ID = 'ic.reticle',
		open = false
	}

function IC.ReticleWindow.SetEnabled(enabled)
	IC.CharacterWide.GetReticleWindow().enabled = enabled
	IC.ReticleWindow.UpdateVisibilityAndContent()
end

function IC.ReticleWindow.IsEnabled()
	return IC.CharacterWide.GetReticleWindow().enabled
end

function IC.ReticleWindow.SetAlwaysVisible(alwaysVisible)
	IC.CharacterWide.GetReticleWindow().alwaysVisible = alwaysVisible
	IC.ReticleWindow.UpdateVisibilityAndContent()
end

function IC.ReticleWindow.IsAlwaysVisible()
	return IC.CharacterWide.GetReticleWindow().alwaysVisible
end

function IC.ReticleWindow.SetAnchor(anchor)
	local savedReticleWindow = IC.CharacterWide.GetReticleWindow()
	savedReticleWindow.anchor = anchor
	local offsetX = savedReticleWindow.offsetX
	local offsetY
	if anchor == BOTTOM then
		offsetY = reticleWindow.window:GetBottom() - GuiRoot:GetHeight()
	else
		anchor = TOP
		offsetY = reticleWindow.window:GetTop()
	end
	savedReticleWindow.offsetY = offsetY
	reticleWindow.window:ClearAnchors()
	reticleWindow.window:SetAnchor(anchor + LEFT, GuiRoot, anchor + LEFT, offsetX, offsetY)
end

function IC.ReticleWindow.GetAnchor()
	return IC.CharacterWide.GetReticleWindow().anchor
end

function IC.ReticleWindow.SetWidth(width)
	IC.CharacterWide.GetReticleWindow().width = width
	reticleWindow.window:SetWidth(width)
	reticleWindow.title:SetWidth(width)
	reticleWindow.text:SetWidth(width - 2 * reticleWindow.MARGIN)
	IC.ReticleWindow.UpdateVisibilityAndContent()
end

function IC.ReticleWindow.GetWidth()
	return IC.CharacterWide.GetReticleWindow().width
end

function IC.ReticleWindow.SetAlpha(alpha)
	IC.CharacterWide.GetReticleWindow().alpha = alpha
	reticleWindow.window:SetAlpha(alpha)
end

function IC.ReticleWindow.GetAlpha()
	return IC.CharacterWide.GetReticleWindow().alpha
end

function IC.ReticleWindow.SetBackgroundAlpha(backgroundAlpha)
	IC.CharacterWide.GetReticleWindow().backgroundAlpha = backgroundAlpha
	reticleWindow.backdrop:SetAlpha(backgroundAlpha)
end

function IC.ReticleWindow.GetBackgroundAlpha()
	return IC.CharacterWide.GetReticleWindow().backgroundAlpha
end

function IC.ReticleWindow.SetTimestampVisible(visible)
	IC.CharacterWide.GetReticleWindow().timestampVisible = visible
	IC.ReticleWindow.UpdateVisibilityAndContent()
end

function IC.ReticleWindow.IsTimestampVisible()
	return IC.CharacterWide.GetReticleWindow().timestampVisible
end

local function SetContents(character)
	if character ~= nil then
		reticleWindow.title:SetText(zo_strformat(GetString(SI_INCHARACTER_UI_RETICLE_WINDOW_TITLE), character.name))
		reticleWindow.text:SetText(zo_strformat(GetString(SI_INCHARACTER_UI_RETICLE_WINDOW_TEXT), character.description))
		if IC.ReticleWindow.IsTimestampVisible() then
			reticleWindow.timestamp:SetText(zo_strformat(GetString(SI_INCHARACTER_UI_RETICLE_WINDOW_TIMESTAMP), os.date(GetString(SI_INCHARACTER_GENERAL_DATE_FORMAT), character.time)))
		end
	end
end

local function OnWindowMoveStop(window)
	local savedReticleWindow = IC.CharacterWide.GetReticleWindow()
	savedReticleWindow.offsetX = window:GetLeft()
	if savedReticleWindow.anchor == BOTTOM then
		savedReticleWindow.offsetY = window:GetBottom() - GuiRoot:GetHeight()
	else
		savedReticleWindow.offsetY = window:GetTop()
	end
end

local function UpdateHeight()
	local height = reticleWindow.title:GetHeight() + reticleWindow.text:GetHeight() + 2 * reticleWindow.MARGIN
	if IC.ReticleWindow.IsTimestampVisible() then
		height = height + reticleWindow.timestamp:GetHeight()
	end
	reticleWindow.window:SetHeight(height)
end

function IC.ReticleWindow.UpdateVisibilityAndContent(causerCharacterName)
	if not IC.ReticleWindow.IsEnabled() then
		reticleWindow.window:SetHidden(true)
		return
	end

	reticleWindow.timestamp:SetHidden(not IC.ReticleWindow.IsTimestampVisible())

	local characterName = GetUnitNameHighlightedByReticle()

	-- no character under the reticle
	if characterName == nil or characterName:len() == 0 then
		-- If game reticle is visible, update visibility of the window. Otherwise keep it as it was.
		if not IC.UI.reticleHidden then
			reticleWindow.open = false

		-- If game reticle is hidden, check if character info that was last displayed was updated
		elseif causerCharacterName == reticleWindow.title:GetText() then
			local character = IC.AccountWide.ReadCharacter(nil, causerCharacterName)
			if character ~= nil then
				SetContents(character)
			end
		end

	-- character under game reticle that is a player
	elseif IsUnitPlayer('reticleover') then
		local character = IC.AccountWide.ReadCharacter(nil, characterName)
		if character ~= nil then
			SetContents(character)
			reticleWindow.open = true
		else
			reticleWindow.open = false
		end
	end
	-- When NPC under game reticle, do not change it. So we prevent NPCs interrupting displayed information.
	reticleWindow.window:SetHidden(not IC.ReticleWindow.IsAlwaysVisible() and (IC.UI.menuVisible or not reticleWindow.open))

	if not reticleWindow.window:IsHidden() then
		UpdateHeight()
	end
end

function IC.ReticleWindow.Create()
	local savedReticleWindow = IC.CharacterWide.GetReticleWindow()
	local windowWidth = savedReticleWindow.width
	local childWidth = windowWidth - 2 * reticleWindow.MARGIN

	local window = WINDOW_MANAGER:CreateTopLevelWindow(reticleWindow.ID..'.window')
	window:SetHidden(true)
	window:SetResizeToFitDescendents(true)
	if savedReticleWindow.anchor == BOTTOM then
		window:SetAnchor(BOTTOMLEFT, GuiRoot, BOTTOMLEFT, savedReticleWindow.offsetX, savedReticleWindow.offsetY)
	else
		window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, savedReticleWindow.offsetX, savedReticleWindow.offsetY)
	end
	window:SetClampedToScreen(true)
	window:SetMovable(true)
	window:SetMouseEnabled(true)
	window:SetWidth(windowWidth)
	window:SetAlpha(savedReticleWindow.alpha)
	window:SetHandler('OnMoveStop', OnWindowMoveStop)
	reticleWindow.window = window

	local backdrop = WINDOW_MANAGER:CreateControlFromVirtual(reticleWindow.ID..'.backdrop', window, 'ZO_DefaultBackdrop')
	backdrop:SetAnchorFill(window)
	backdrop:SetAlpha(savedReticleWindow.backgroundAlpha)
	reticleWindow.backdrop = backdrop

	local title = WINDOW_MANAGER:CreateControl(reticleWindow.ID..'.title', window, CT_LABEL)
	title:SetAnchor(TOP, window, TOP, 0, reticleWindow.MARGIN)
	title:SetWidth(windowWidth)
	title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
	title:SetFont('ZoFontWinH3')
	reticleWindow.title = title

	local text = WINDOW_MANAGER:CreateControl(reticleWindow.ID..'.text', window, CT_LABEL)
	text:SetAnchor(TOP, title, BOTTOM, 0, 0)
	text:SetWidth(childWidth)
	text:SetFont('ZoFontChat')
	reticleWindow.text = text

	local timestamp = WINDOW_MANAGER:CreateControl(reticleWindow.ID..'.timestamp', window, CT_LABEL)
	timestamp:SetHidden(not savedReticleWindow.timestampVisible)
	timestamp:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -reticleWindow.MARGIN, -reticleWindow.MARGIN)
	timestamp:SetFont('ZoFontGameSmall')
	reticleWindow.timestamp = timestamp

	IC.ReticleWindow.UpdateVisibilityAndContent()
end