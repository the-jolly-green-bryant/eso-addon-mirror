local APM = APMeter
local Theme = {}
local selected = {}
local themeList = {}
local previewList = {}

function Theme.Initialize()
	
    Theme.SetSelected(APM.db.settings.selectedTheme)

	local selectedName = Theme.Selected().name
	local locations = APM.db.settings.locations

	if not locations[selectedName] then
		locations[selectedName] = { x = 0, y = 0 }
		APMeterContainer:ClearAnchors()
		APMeterContainer:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
	else

		local location = APM.db.settings.locations[selectedName]

		if location.x == -0 then location.x = 1 end
		if location.y == -0 then location.y = 1 end

		if location.x ~= 0 and location.y ~= 0 then
			APMeterContainer:ClearAnchors()
			APMeterContainer:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, location.x, location.y)
		end

	end

	CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", function(panel)
		if panel ~= APM.LAMSettings then return end

		local previewContainerWidth = GuiRoot:GetWidth() - (LAMAddonSettingsWindow:GetLeft() + LAMAddonSettingsWindow:GetWidth())

		Theme.SetPreview(APM.db.settings.selectedTheme)
		APMeterPreviewContainer:ClearAnchors()
		APMeterPreviewContainer:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, 0, 0)
		APMeterPreviewContainer:SetWidth(previewContainerWidth)
		APMeterPreviewContainer:SetHeight(GuiRoot:GetHeight())
		APMeterPreviewContainer:SetParent(LAMAddonSettingsWindowPanelContainer)
		APMeterPreviewContainer:SetHidden(false)
		Theme.Preview:StartPreview()
	end)

	CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", function(panel)
		if panel ~= APM.LAMSettings then return end
		APMeterPreviewContainer:SetHidden(true)
		Theme.Preview:ResetPreview()
	end)

	--IsInGamepadPreferredMode()
	-- Check if in gamepad mode to disable preview?
end

function Theme.SetSelected( name )
	local _theme = themeList[name]
	selected = _theme:New(APMeterContainer, 'APMeterContainer_SelectedTheme', false)
	APMeterContainer:SetWidth(_theme.containerWidth)
	APMeterContainer:SetHeight(_theme.containerHeight)
end

function Theme.Selected()
	return selected
end

function Theme.SetPreview( name )

	if not previewList[name] then
		previewList[name] = themeList[name]:New(APMeterPreviewContainer, 'APMeterPreviewContainer_SelectedTheme_'..name, true)
	end

	if Theme.Preview then
		Theme.Preview:ResetPreview()
		APMeterPreviewContainer:GetNamedChild('_SelectedTheme_'..Theme.Preview.name):SetHidden(true)
	end

	Theme.Preview = previewList[name]
	APMeterPreviewContainer:GetNamedChild('_SelectedTheme_'..Theme.Preview.name):SetHidden(false)
end

function Theme.Register( context )
	themeList[ context.name ] = context
end

function Theme.GetTheme( name )
	return themeList[ name ]
end

function Theme.GetList()

	local list = {}
	local i = 1

	for k,v in pairs(themeList) do
		list[i] = k
		i = i+1
	end

	return list
end

APM.Theme = Theme