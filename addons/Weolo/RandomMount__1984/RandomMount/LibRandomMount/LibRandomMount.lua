--[[prettyboxData = {
	type = "prettybox",
	name = "My pretty box", -- or string id or function returning a string
	getFunc = function() return db.var end,
	setFunc = function(value) db.var = value doStuff() end,
	tooltip = "Prettybox's tooltip text.", -- or string id or function returning a string (optional)
	width = "full", -- or "half" (optional)
	disabled = function() return db.someBooleanSetting end, -- or boolean (optional)
	warning = "May cause permanent awesomeness.", -- or string id or function returning a string (optional)
	requiresReload = false, -- boolean, if set to true, the warning text will contain a notice that changes are only applied after an UI reload and any change to the value will make the "Apply Settings" button appear on the panel which will reload the UI when pressed (optional)
	default = defaults.var, -- a boolean or function that returns a boolean (optional)
	reference = "MyAddonPrettybox", -- unique global reference to control (optional)
} ]]

-- Metro colours https://www.w3schools.com/colors/colors_metro.asp
-- 25% alpha = 40, 50% alpha = 80, 75% alpha = BF
-- local debugColours = {
-- 	[1] = ZO_ColorDef:New("99b43380"),
-- 	[2] = ZO_ColorDef:New("ff009780"),
-- 	[3] = ZO_ColorDef:New("9f00a780"),
-- 	[4] = ZO_ColorDef:New("7e387880"),
-- 	[5] = ZO_ColorDef:New("603cba80"),
-- 	[6] = ZO_ColorDef:New("eff4ff80"),
-- 	[7] = ZO_ColorDef:New("2d89ef80"),
-- 	[8] = ZO_ColorDef:New("2b579780"),
-- 	[9] = ZO_ColorDef:New("ffc40d80"),
-- 	[10]= ZO_ColorDef:New("e3a21a80"),
-- 	[11]= ZO_ColorDef:New("da532c80"),
-- 	[12]= ZO_ColorDef:New("ee111180"),
-- 	[13]= ZO_ColorDef:New("b91d4780")
-- }
-- local debugCurrentColour = 0

-- local function DebugNextColour()
-- 	debugCurrentColour = debugCurrentColour + 1
-- 	if debugCurrentColour > #debugColours then debugCurrentColour = 1 end
-- 	return debugColours[debugCurrentColour]
-- end

-- local function DebugBackdrop(parent)
-- 	local edgeSize = 2
-- 	local bg = parent:CreateControl("", CT_BACKDROP)
-- 	bg:SetAnchorFill()
-- 	bg:SetAlpha(1)
-- 	bg:SetCenterColor(DebugNextColour():UnpackRGBA())
-- 	bg:SetEdgeColor(1, 0, 0, 0.8)
-- 	bg:SetEdgeTexture(nil, 2, 2, edgeSize, 0)
-- end

-- local sf = string.format

function LAMCreateControl.prettybox(parent, prettyboxData)
	local imageHeight = 64

	-- Custom control
	local customData = {
		type = "custom",
		reference = prettyboxData.reference,
		createFunc = function(customControl)
			--d(sf("RandomMount DEBUG: createFunc %s", customControl:GetName()))
		end,
		refreshFunc = function(customControl)
			--d(sf("RandomMount DEBUG: refreshFunc %s", customControl:GetName()))
		end,
		width = prettyboxData.width,
		minHeight = imageHeight
	}
	local custom = LAMCreateControl.custom(parent, customData)
	
	-- Texture
	local textureData = {
		type = "texture",
		image = prettyboxData.image,
		imageWidth = imageHeight,
		imageHeight = imageHeight,
		tooltip = prettyboxData.tooltip,
		width = prettyboxData.width
	}
	local texture = LAMCreateControl.texture(custom, textureData, "$(parent)Texture")
	custom.texture = texture
	texture:ClearAnchors()
	texture:SetAnchor(TOPLEFT)
	texture:SetDimensionConstraints(imageHeight, imageHeight, imageHeight, imageHeight)

	-- Checkbox
	local checkboxData = {
		type = "checkbox",
		name = prettyboxData.name,
		getFunc = prettyboxData.getFunc,
		setFunc = prettyboxData.setFunc,
		tooltip = prettyboxData.tooltip,
		width = prettyboxData.width,
		disabled = prettyboxData.disabled,
		warning = prettyboxData.warning,
		requiresReload = prettyboxData.requiresReload,
		default = prettyboxData.default
	}
	local checkbox = LAMCreateControl.checkbox(custom, checkboxData, "$(parent)Checkbox")
	custom.checkbox = checkbox
	checkbox:ClearAnchors()
	checkbox:SetAnchor(TOPLEFT, custom, TOPLEFT, imageHeight)
	checkbox:SetAnchor(BOTTOMRIGHT, custom, BOTTOMRIGHT)

	-- Checkbox ON OFF
	checkbox.container:ClearAnchors()
	checkbox.container:SetAnchor(TOPLEFT, checkbox, TOPLEFT, 5)
	checkbox.container:SetAnchor(TOPRIGHT, custom, TOPRIGHT)

	-- Checkbox label
	checkbox.label:ClearAnchors()
	checkbox.label:SetAnchor(TOPLEFT, checkbox.container, BOTTOMLEFT)
	checkbox.label:SetAnchor(TOPRIGHT, checkbox.container, BOTTOMRIGHT)
	local height = checkbox.label:GetTextHeight()
	if checkbox.label:WasTruncated() then height = height * 2 end
	checkbox.label:SetHeight(height + 2)

	-- Warning icon
	if checkbox.warning then
		checkbox.warning:SetDrawLayer(DL_OVERLAY)
		checkbox.warning:SetDrawTier(DT_MEDIUM)
	end

	return custom
end

local widgetVersion = 1
local ADDON_NAME = "LibRandomMount"
local LAM = LibAddonMenu2

local function onLoaded(addonName)
	if addonName ~= ADDON_NAME then return end
	EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
	if not LAM:RegisterWidget("prettybox", widgetVersion) then return end
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, function(_, addonName) onLoaded(addonName) end)
