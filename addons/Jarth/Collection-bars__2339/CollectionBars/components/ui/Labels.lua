--[[
Author: Jarth
Filename: Labels.lua
]] --
-------------------------------------------------------------------------------------------------
-- VARIABLES --
-------------------------------------------------------------------------------------------------
local base = CollectionBars
local texts = base.Texts

-------------------------------------------------------------------------------------------------
-- FUNCTIONS --
-------------------------------------------------------------------------------------------------
function base:SetupLabel(category)
	base:Debug("SetupLabel", category)

	local hideAllId = string.format(texts.FormatAbbreviationLowDash, "HideAll")
	local hideAllCategory = string.format("%s%s", hideAllId, category.Name)

	if category.Frames.Label == nil then
		category.Frames.Label = GetControl(hideAllCategory)

		if category.Frames.Label == nil then
			category.Frames.Label = base.WM:CreateControlFromVirtual(hideAllId, category.Frames.Frame, hideAllId, category.Name)
		end
	end

	category.Frames.Label:SetHidden(not category.Saved.Label.Show and not category.Saved.Bar.IsCombined)

	category.Frames.ToggleSettings = GetControl(string.format("%sToggleSettings", hideAllCategory))
	category.Frames.LabelButton = GetControl(string.format("%sButton", hideAllCategory))

	if category.Frames.LabelButton ~= nil then
		category.Frames.LabelButton:SetHandler("OnClicked", function(_, button)
			if button == MOUSE_BUTTON_INDEX_RIGHT then
				base:ToggleEnableSettings()
			elseif button == MOUSE_BUTTON_INDEX_LEFT and category.Saved.Label.EnableHideAll or category.Saved.Bar.IsCombined then
				category.Saved.Bar.HideAll = not category.Saved.Bar.HideAll

				if category.Saved.Bar.IsCombined then
					base:HideOthers(category)
				end

				base:RestoreFrame(category)
				base:RestoreCombine()
			end
		end)
	end

	base:SetupToggleSettings(category)
end

function base:RestoreLabel(category)
	base:Debug("RestoreLabel", category)

	local label = category.Saved.Label
	local frameLabel = category.Frames.Label

	if frameLabel ~= nil then
		frameLabel:ClearAnchors()
		frameLabel:SetHeight(label.Height)
		frameLabel:SetWidth(label.Width)

		if not category.Saved.Bar.IsCombined then
			frameLabel:SetAnchor(label.Position, category.Frames.Frame, label.PositionTarget, label.Offset.X, label.Offset.Y)
		end

		frameLabel:SetHidden(not category.Saved.Label.Show and not category.Saved.Bar.IsCombined and not base.Global.EnableSettings)
	end

	local frameLabelButton = category.Frames.LabelButton

	if frameLabelButton ~= nil then
		frameLabelButton:SetHidden(false)
		frameLabelButton:SetFont(label.Font)
		frameLabelButton:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
		frameLabelButton:SetVerticalAlignment(TOP)
		frameLabelButton:SetText(string.format("%s%s", tostring(category.Saved.Label.Display), base:GetLabelPostFix(category)))
	end

	local frameLabelToggleSettings = category.Frames.ToggleSettings

	if frameLabelToggleSettings ~= nil then
		frameLabelToggleSettings:SetHidden(false)
	end
end

function base:RemoveLabel(category)
	base:Debug("RemoveLabel", category)

	if category.Frames.Label ~= nil then
		category.Frames.Label:ClearAnchors()
		category.Frames.Label:SetHidden(true)
	end

	if category.Frames.LabelButton ~= nil then
		category.Frames.LabelButton:SetHidden(true)
	end

	if category.Frames.ToggleSettings ~= nil then
		category.Frames.ToggleSettings:SetHidden(true)
	end
end

function base:RestoreCombineLabels()
	base:Debug("RestoreCombineLabels")

	local combineLabel = base.Saved.Combine.Label
	local width = 0
	local height = 0

	for _, category in ipairs(base.CategoriesOrdered) do
		if category.Saved.Enabled and category.Saved.Bar.IsCombined and category.Frames.Label then
			if (not category.IsEmpty or base.Global.EnableSettings) then
				local hasSelected = not base:HasAny(category.Saved.Selected)
				category.Frames.Label:ClearAnchors()
				category.Frames.Label:SetHidden(not hasSelected and not category.Saved.Label.Show and not base.Global.EnableSettings)

				if not category.Frames.Label:IsHidden() or (category.Saved.Label.Show and hasSelected) or base.Global.EnableSettings then
					width = width + category.Saved.Label.Offset.X
					local offsetY = category.Saved.Label.Offset.Y + combineLabel.Offset.Y
					category.Frames.Label:SetAnchor(TOPLEFT, base.Global.Combine.Frames.HideAll, TOPLEFT, width, offsetY)
					width = width + category.Frames.Label:GetWidth()
					local labelHeight = category.Frames.Label:GetHeight()

					if labelHeight > height then
						height = labelHeight
					end
				end
			end
		end
	end

	local frame = base.Global.Combine.Frames.HideAll

	if frame ~= nil and base.Global.Combine.Frames.Frame ~= nil then
		frame:ClearAnchors()
		frame:SetWidth(width)
		frame:SetHeight(height)
		frame:SetAnchor(combineLabel.Position, base.Global.Combine.Frames.Frame, combineLabel.PositionTarget, combineLabel.Offset.X, combineLabel.Offset.Y)
	end
end
