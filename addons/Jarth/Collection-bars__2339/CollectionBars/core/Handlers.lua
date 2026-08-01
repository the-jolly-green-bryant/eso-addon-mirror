--[[
Author: Jarth
Filename: Handlers.lua
]] --
-------------------------------------------------------------------------------------------------
-- VARIABLES --
-------------------------------------------------------------------------------------------------
local base = CollectionBars
local texts = base.Texts

-------------------------------------------------------------------------------------------------
-- FUNCTIONS --
-------------------------------------------------------------------------------------------------
function base.GetCharacterSettingsDisabledState()
	base:Debug("GetCharacterSettingsDisabledState")

	local result = BSTATE_DISABLED

	if base.Saved.UseAccountSettings and _G[texts.CharacterKey] ~= nil then
		result = BSTATE_NORMAL
	end

	return result == BSTATE_DISABLED
end

function base:GetLocationValue(value)
	base:Debug("GetLocationValue", value)

	local result

	if value == texts.Location.Bottom then
		result = BOTTOM
	elseif value == texts.Location.BottomLeft then
		result = BOTTOMLEFT
	elseif value == texts.Location.BottomRight then
		result = BOTTOMRIGHT
	elseif value == texts.Location.Center then
		result = CENTER
	elseif value == texts.Location.Left then
		result = LEFT
	elseif value == texts.Location.Right then
		result = RIGHT
	elseif value == texts.Location.Top then
		result = TOP
	elseif value == texts.Location.TopLeft then
		result = TOPLEFT
	elseif value == texts.Location.TopRight then
		result = TOPRIGHT
	end

	return result
end

function base:GetLocationText(value)
	base:Debug("GetLocationText", value)

	local result

	if value == BOTTOM then
		result = texts.Location.Bottom
	elseif value == BOTTOMLEFT then
		result = texts.Location.BottomLeft
	elseif value == BOTTOMRIGHT then
		result = texts.Location.BottomRight
	elseif value == CENTER then
		result = texts.Location.Center
	elseif value == LEFT then
		result = texts.Location.Left
	elseif value == RIGHT then
		result = texts.Location.Right
	elseif value == TOP then
		result = texts.Location.Top
	elseif value == TOPLEFT then
		result = texts.Location.TopLeft
	elseif value == TOPRIGHT then
		result = texts.Location.TopRight
	end

	return result
end

function base:RestorePosition(frame, saved)
	base:Debug("RestorePosition", frame, frame.Name, saved)

	frame:ClearAnchors()
	local combineFrame = base.Global.Combine.Frames.Frame

	if not saved.Bar.IsCombined or not combineFrame then
		frame:SetAnchor(saved.Label.PositionTarget, GuiRoot, TOPLEFT, saved.Bar.Offset.X, saved.Bar.Offset.Y)
	elseif saved.Bar.IsCombined then
		if not saved.Bar.HideAll then
			frame:SetAnchorFill(combineFrame)
		else
			frame:SetAnchor(TOPLEFT, combineFrame, TOPLEFT, 0, 0)
		end
	end
end

function base:GetLabelPostFix(category)
	base:Debug("GetLabelPostFix", category)

	local postFix = ""

	if category.Saved.Label.EnableHideAll then
		if not category.Saved.Bar.HideAll then
			postFix = " -"
		else
			postFix = " +"
		end
	end
	return postFix
end

function base:IsAllSelected(category)
	base:Debug("IsAllSelected", category)

	local isAllSelected = true

	for _, collectible in pairs(category.Collection) do
		if category.Saved.Selected[collectible.Id] == nil then
			isAllSelected = false
			break
		end
	end

	return isAllSelected
end

function base:AutoSelectAll(category, newValue)
	base:Debug("AutoSelectAll", category, newValue)

	if newValue then
		category.Saved.Selected = {}
	end

end

function base:SelectAll(category, newValue)
	base:Debug("SelectAll", category, newValue)

	for _, collectible in pairs(category.Collection) do
		if newValue == true then
			category.Saved.Selected[collectible.Id] = newValue
		else
			category.Saved.Selected[collectible.Id] = nil
		end
	end
end

function base:GetAccountsettings()
	base:Debug("GetAccountsettings")

	return ZO_SavedVars:NewAccountWide(texts.AccountKey, base.Addon.Version, nil, base.Default)
end

function base:GetCharactersettings(useAccountSettings)
	base:Debug("GetCharactersettings", useAccountSettings)

	local characterSettings = nil

	if not useAccountSettings then
		characterSettings = ZO_SavedVars:NewCharacterNameSettings(texts.CharacterKey, base.Addon.Version, nil, base.Default)
		characterSettings.UseAccountSettings = false
	end

	return characterSettings
end

function base:SetSavedSettings()
	base:Debug("SetSavedSettings")

	local accountSettings = base:GetAccountsettings()
	local characterSettings = base:GetCharactersettings(accountSettings.UseAccountSettings)
	base.Saved = characterSettings or accountSettings
end

function base:UpdateUseAccountSettings(useAccountSettings)
	base:Debug("UpdateUseAccountSettings", useAccountSettings)

	local accountSettings = base:GetAccountsettings()
	accountSettings.UseAccountSettings = useAccountSettings
	local characterSettings = base:GetCharactersettings(accountSettings.UseAccountSettings)
	base.Saved = characterSettings or accountSettings
end

function base:ResetSavedSettings()
	base:Debug("ResetSavedSettings")

	local useAccountSettings = base.Saved.UseAccountSettings

	if useAccountSettings then
		_G[texts.AccountKey] = nil
		base.Saved = base:GetAccountsettings()
	else
		_G[texts.CharacterKey] = nil
		base.Saved = base:GetCharactersettings(useAccountSettings)
	end
end

function base:RemoveCharacterSettings()
	base:Debug("RemoveCharacterSettings")

	if base.Saved.UseAccountSettings then
		_G[texts.CharacterKey] = nil
	end
end

function base:GetMaxBarSize(category, constraint, count)
	local maxBarSize
	if category.Saved.Bar.IsCombined then
		maxBarSize = base.Saved.Combine.Bar[constraint]
	else
		maxBarSize = category.Saved.Bar[constraint]
	end

	if maxBarSize == 0 then
		maxBarSize = base.Saved.Bar[constraint]
	end
	if count < maxBarSize then
		maxBarSize = count
	end

	return maxBarSize
end

function base:GetBarWidthHeight(category)
	base:Debug("GetBarWidthHeight", category)

	local width, height, count = 0, 0, 0

	if not category.Saved.Bar.HideAll then
		for key, button in pairs(category.Buttons) do
			if not button:IsHidden() then
				count = count + 1
			end
		end
	end

	if count > 0 then
		category.Bar.Depth, category.Bar.Width = base:GetMaxBarSize(category, "Depth", count), base:GetMaxBarSize(category, "Width", count)

		local barWidth = zo_ceil(count / category.Bar.Depth)
		local maxBarWidth = category.Bar.Width

		if maxBarWidth > 0 and maxBarWidth < barWidth then
			barWidth = maxBarWidth
		end

		local isHorizontal = category.Saved.Bar.Horizontal
		width = base.Saved.Button.Size * (not isHorizontal and barWidth or category.Bar.Depth)
		height = base.Saved.Button.Size * (isHorizontal and barWidth or category.Bar.Depth)
	end

	return width, height
end

function base:SetFrameSizeIfExists(frame, width, height)
	base:Debug("SetFrameSizeIfExists", frame, width, height)

	if frame ~= nil then
		frame:SetWidth(width)
		frame:SetHeight(height)
	end
end

function base:HasAny(array)
	base:Debug("HasAny", array)

	local hasAny = false

	if array ~= nil then
		for _ in pairs(array) do
			hasAny = true
			break
		end
	end

	return hasAny
end

function base:SetControlText(control, text)
	base:Debug("SetControlText", control, text)

	control.SetText(control, text)
end
