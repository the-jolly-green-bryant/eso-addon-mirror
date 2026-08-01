--[[
Author: Jarth
Filename: Settings.lua
]] --
-------------------------------------------------------------------------------------------------
-- VARIABLES --
-------------------------------------------------------------------------------------------------
local base = CollectionBars
local texts = base.Texts

-------------------------------------------------------------------------------------------------
-- FUNCTIONS --
-------------------------------------------------------------------------------------------------
function base:InitializeSettingsSlash()
	base:Debug("InitializeSettingsSlash")

	SLASH_COMMANDS[base.Addon.SettingsSlash] = function()
		base:ToggleEnableSettings(base.ShowSettings())
	end
end

function base:ToggleEnableSettings(forceShow)
	base:Debug("ToggleEnableSettings", forceShow)

	base.Global.EnableSettings = forceShow or not base.Global.EnableSettings

	base:RestoreFrames()
	base:RestoreCombineLabels()
end

function base:SetupToggleSettings(category)
	base:Debug("SetupToggleSettings", category)

	local toggleSettings = GetControl(string.format(texts.FormatAbbreviationLowDash .. "%sToggleSettings", "HideAll", category.Name))

	if toggleSettings then
		toggleSettings:SetHandler("OnClicked", function()
			base:ShowSettings(category)
		end)
	end
end

function base:UpdateToggleSettings(category)
	base:Debug("UpdateToggleSettings", category)

	local offsetX = 0

	if base.Global.EnableSettings then
		offsetX = -19
	end

	if category.Frames.Label and category.Frames.ToggleSettings then
		category.Frames.ToggleSettings:ClearAnchors()
		category.Frames.ToggleSettings:SetAnchor(TOPLEFT, category.Frames.Label, TOPRIGHT, offsetX, 0)
		category.Frames.ToggleSettings:SetAnchor(BOTTOMRIGHT, category.Frames.Label, BOTTOMRIGHT, 0, 0)
	end

	if category.Frames.Label and category.Frames.LabelButton then
		category.Frames.LabelButton:ClearAnchors()
		category.Frames.LabelButton:SetAnchor(TOPLEFT, category.Frames.Label, TOPLEFT, 0, 0)
		category.Frames.LabelButton:SetAnchor(BOTTOMRIGHT, category.Frames.Label, BOTTOMRIGHT, offsetX, 0)
	end
end

function base:SetupSettingsFrameHandlers(control, text, onClicked)
	base:Debug("SetupSettingsFrameHandlers", control, text, onClicked)

	control.tooltipText = text
	control:SetHandler("OnClicked", onClicked)
	control:SetHandler("OnMouseEnter", function(_control)
		ZO_Tooltips_ShowTextTooltip(_control, BOTTOM, _control.tooltipText)
	end)
	control:SetHandler("OnMouseExit", function()
		ZO_Tooltips_HideTextTooltip()
	end)
end

function base:SetupSetttingsFrame(category)
	base:Debug("SetupSetttingsFrame", category)

	local selector = string.format(texts.FormatAbbreviationLowDash, "Settings")
	base.Global.Settings.Frame = base.WM:CreateControlFromVirtual(selector, GuiRoot, selector)
	base.Global.SettingsLabel = GetControl(string.format("%sLabel", selector))
	base.Global.Settings.List = CBs_Settings_List:New(category, base.Global.Settings.Frame)

	local titleControl = GetControl(string.format("%sTitle", selector))
	titleControl:SetText(string.format("%s Settings", base.Addon.DisplayName))

	if base.Global.Settings.Frame.closeFrame == nil then
		base.Global.Settings.Frame.closeFrame = GetControl(base.Global.Settings.Frame, "Close")
	end

	if base.Global.Settings.Frame.closeFrame then
		base:SetupSettingsFrameHandlers(base.Global.Settings.Frame.closeFrame, "Close", function(buttonControl)
			buttonControl:GetParent():SetHidden(true)
		end)
	end

	if base.Global.Settings.Frame.moveFrame == nil then
		base.Global.Settings.Frame.moveFrame = GetControl(base.Global.Settings.Frame, "Move")
	end

	if base.Global.Settings.Frame.moveFrame then
		base:SetupSettingsFrameHandlers(base.Global.Settings.Frame.moveFrame, texts.Settings.ToggleMoveFrameText, function()
			base.Global.IsMoveEnabled = not base.Global.IsMoveEnabled
			base.Global.Settings.List:RefreshData()
			base:RestoreFrames()
		end)
	end

	if base.Global.Settings.Frame.refreshFrame == nil then
		base.Global.Settings.Frame.refreshFrame = GetControl(base.Global.Settings.Frame, "Refresh")
	end

	if base.Global.Settings.Frame.refreshFrame then
		base:SetupSettingsFrameHandlers(base.Global.Settings.Frame.refreshFrame, texts.Settings.ReloadText, function()
			if base.Global.Settings.List.category ~= nil then
				base:CreateCategory(base.Global.Settings.List.category)
				base:RestoreFrame(base.Global.Settings.List.category)
			end
			base:RestoreCombineLabels()
			base.Global.Settings.List:RefreshData()
		end)
	end

	for controlName, displayName in pairs(base.Global.Settings.Filters) do
		base:SetupSettingsFilter(base.Global.Settings.Frame, controlName, displayName)
	end
end

function base:SetupSettingsFilter(control, controlName, displayName)
	base:Debug("SetupSettingsFilter", control, controlName, displayName)

	local filterControl = GetControl(control, controlName)

	if filterControl then
		base:SetControlText(filterControl, displayName)
		filterControl:SetHandler("OnClicked", function()
			base.Global.Settings.List.masterListType = controlName
			base.Global.Settings.List:RefreshFilters()
		end)
	end
end

function base:ShowSettings(category)
	base:Debug("ShowSettings", category)

	local show = base.Global.Settings.Frame == nil

	if show then
		base:SetupSetttingsFrame(category)
	end

	show = show or base.Global.Settings.Frame:IsHidden() or category ~= base.Global.Settings.List.category
	base.Global.Settings.Frame:SetHidden(not show)
	base:UpdateSettingsType(show, category)

	if show then
		base.Global.Settings.List.category = show and category or nil
		base.Global.Settings.List:RefreshData()
	end

	return show
end

function base:UpdateSettingsType(show, category)
	base:Debug("UpdateSettingsType", show, category)

	if base.Global.Settings.List ~= nil then
		base.Global.Settings.List.category = category
	end

	if base.Global.SettingsLabel ~= nil then
		base.Global.SettingsLabel:SetText(show and category and category.Name or "Global")
	end
end
