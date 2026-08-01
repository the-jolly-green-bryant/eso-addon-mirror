NGI = NGI or {}
NGI.name = "No Green Incap"
NGI.version = 1
NGI.saved = {}
NGI.default = {
	selection = "NoGreenIncap/img/incap_sharpen.dds"
}
local icons = {
	["Original"] = "NoGreenIncap/img/incap_original.dds",
	["Saturated"] = "NoGreenIncap/img/incap_saturate.dds",
	["Blurred"] = "NoGreenIncap/img/incap_blur.dds",
	["Vignette"] = "NoGreenIncap/img/incap_vignette.dds",
	["Glow"] = "NoGreenIncap/img/incap_glow.dds",
	["Flip"] = "NoGreenIncap/img/incap_flip.dds",
	["Sharpen"] = "NoGreenIncap/img/incap_sharpen.dds",
	["Noise"] = "NoGreenIncap/img/incap_noise.dds",
	["Orange"] = "NoGreenIncap/img/incap_orange.dds",
	["Pink"] = "NoGreenIncap/img/incap_pink.dds",
	["Blue"] = "NoGreenIncap/img/incap_blue.dds",
	["Inverted"] = "NoGreenIncap/img/incap_invert.dds",
	["Red Background"] = "NoGreenIncap/img/incap_redbg.dds",
	["Black Background"] = "NoGreenIncap/img/incap_blackbg.dds",
	["White Background"] = "NoGreenIncap/img/incap_whitebg.dds",
	["Gradient Background"] = "NoGreenIncap/img/incap_gradientbg.dds",
}
local names = { "Original", "Saturated", "Blurred", "Vignette", 
"Glow", "Flip", "Sharpen", "Noise", 
"Orange", "Pink", "Blue", "Inverted", 
"Red Background", "Black Background", "White Background", "Gradient Background" }


function NGI.OnLoaded(_, name)
	if name == "NoGreenIncap" then 
		NGI.saved = ZO_SavedVars:NewAccountWide("NoGreenIncap_SavedVariables", 3, nil, NGI.default)
		RedirectTexture("esoui/art/icons/ability_nightblade_007_c.dds", NGI.saved.selection)
		NGI.CreateSettings()
		EVENT_MANAGER:UnregisterForEvent(NGI.name, EVENT_ADD_ON_LOADED)
	end
end

function NGI.GetChoices()
	local r = {}
	for i = 1, #names do
		r[i] = icons[names[i]]
	end
	return r
end


function NGI.CreateSettings()
	
	local LAM2 = LibStub:GetLibrary("LibAddonMenu-2.0")
	local panel = {
			type = "panel",
			name = NGI.name,
			displayName = NGI.name,
			author = "Acer",
			version = tostring(NGI.version),
			slashCommand = "/incap",
	}
	LAM2:RegisterAddonPanel("NoGreenIncap", panel)
	
	local options = {
		{
			type = "header",
			name = "Icon Settings",
		},
		{
			type = "description",
			text = "Replace the green incap texture with another one. \nUse /incap to open this settings window.",
		},
		{
			type = "iconpicker",
			name = "Icon",
			tooltip = "Which icon to replace the green incap texture with.",
			choices = NGI.GetChoices(),
			choicesTooltips = names,
			getFunc = function() return NGI.saved.selection end,
			setFunc = function(x) NGI.saved.selection = x end,
			maxColumns = 4,
			visibleRows = 4,
			iconSize = 64,
			default = NGI.default.selection,
			warning = "Requires a full game restart to update!",
		},
		{
			type = "button",
			name = "Preview",
			tooltip = "Will set the ultimate texture on the current bar to the selected icon. This is reset when the active bar is switched or the ultimate is changed.",
			func = function()
				ActionButton8Icon:SetTexture(NGI.saved.selection)
			end,
		},
	}
	LAM2:RegisterOptionControls("NoGreenIncap", options)
end

SLASH_COMMANDS["/rl"] = function(x) ReloadUI() end
EVENT_MANAGER:RegisterForEvent(NGI.name, EVENT_ADD_ON_LOADED, NGI.OnLoaded)