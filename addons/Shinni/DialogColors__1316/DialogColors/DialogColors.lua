local DialogColors = {}

-- the code of the below two functions is directly taken from zenimax's original source code of the interaction window
-- i only changed the color that is passed to the :SetColor functions
function INTERACTION:RestoreOtherImportantOptions(chatterControl)
	for i, control in ipairs(self.importantOptions) do
		if control ~= chatterControl then
			if control.enabled then
				control:SetColor(unpack(DialogColors.settings.selectColor))
			else
				control:SetColor(ZO_ERROR_COLOR:UnpackRGBA())
			end
		end
	end
end

local oldFunction = INTERACTION.PopulateChatterOption
function INTERACTION:PopulateChatterOption(controlID, ...)
	oldFunction(self, controlID, ...)
	-- sets the color of the answer option, the color changes if the answer has been selected before
	local optionControl = self.optionControls[controlID]
	if optionControl.enabled then
		if(optionControl.chosenBefore) then
			optionControl:SetColor(unpack(DialogColors.settings.seenColor))
		else
			optionControl:SetColor(unpack(DialogColors.settings.selectColor))
		end
		GetControl(optionControl, "IconImage"):SetDesaturation(0)
	end
	-- set the shadow color of the answer
	optionControl:SetStyleColor(unpack(DialogColors.settings.shadowColor))
end

function DialogColors.OnAddonLoaded( _, addon )
	if addon ~= "DialogColors" then
		return
	end
	-- load saved settings
	DialogColors.settings = ZO_SavedVars:New("DialogColors_SavedVariables", 1, "settings", {
		bgColor = {0,0,0},
		textColor={1,1,1},
		selectColor={0.772549,0.760784,0.619607},
		seenColor={0.4,0.4,0.4},
		shadowColor={0,0,0},
	})
	-- set the backgrounds color
	ZO_InteractWindowTopBG:SetTexture("DialogColors/conversation_textbg.dds")
	ZO_InteractWindowTopBG:SetColor(unpack(DialogColors.settings.bgColor))
	ZO_InteractWindowBottomBG:SetTexture("DialogColors/conversation_textbg.dds")
	ZO_InteractWindowBottomBG:SetColor(unpack(DialogColors.settings.bgColor))
	-- set the text color of the dialog window (only the NPC's text and name)
	ZO_InteractWindowTargetAreaBodyText:SetColor(unpack(DialogColors.settings.textColor))
	ZO_InteractWindowTargetAreaTitle:SetColor(unpack(DialogColors.settings.textColor))
	-- this line would've set the shadow's color
	ZO_InteractWindowTargetAreaBodyText:SetStyleColor(unpack(DialogColors.settings.shadowColor))
	
	-- options
	local panelData = {
		type = "panel",
		name = "DialogColors",
		displayName = "DialogColors",
		author = "Shinni",
		version = "1",
		registerForRefresh = true,
		registerForDefaults = false,
	}

	local optionsTable = {
		{
			type = "colorpicker",
			name = "Background Color",
			tooltip = "Sets the color of the dialog window's background.",
			getFunc = function() return unpack(DialogColors.settings.bgColor) end,
			setFunc = function( r, g, b )
				DialogColors.settings.bgColor = {r, g, b}
				ZO_InteractWindowTopBG:SetColor(r, g, b, 1)
				ZO_InteractWindowBottomBG:SetColor(r, g, b, 1)
			end,
			--default = {0,0,0},
		},
		{
			type = "colorpicker",
			name = "NPC Text Color",
			tooltip = "Sets the color of the NPC's text and name.",
			getFunc = function() return unpack(DialogColors.settings.textColor) end,
			setFunc = function( r, g, b )
				DialogColors.settings.textColor = {r, g, b}
				ZO_InteractWindowTargetAreaBodyText:SetColor(r, g, b, 1)
				ZO_InteractWindowTargetAreaTitle:SetColor(r, g, b, 1)
			end,
			--default = {0,0,0},
		},
		{
			type = "colorpicker",
			name = "Shadow Color",
			tooltip = "Sets the color of the text's shadow effect.",
			getFunc = function() return unpack(DialogColors.settings.shadowColor) end,
			setFunc = function( r, g, b )
				DialogColors.settings.shadowColor = {r, g, b}
				ZO_InteractWindowTargetAreaBodyText:SetStyleColor(r, g, b, 1)
			end,
			--default = {0,0,0},
		},
		{
			type = "colorpicker",
			name = "Answer Color",
			tooltip = "Sets the color of your possible answers.",
			getFunc = function() return unpack(DialogColors.settings.selectColor) end,
			setFunc = function( r, g, b ) DialogColors.settings.selectColor = {r, g, b} end,
			--default = {0,0,0},
		},
		{
			type = "colorpicker",
			name = "Seen Color",
			tooltip = "Sets the color of your possible answers, that you have selected before.",
			getFunc = function() return unpack(DialogColors.settings.seenColor) end,
			setFunc = function( r, g, b ) DialogColors.settings.seenColor = {r, g, b} end,
			--default = {0,0,0},
		},
	}

	local LAM = LibStub("LibAddonMenu-2.0")

	LAM:RegisterAddonPanel("DialogColorsControl", panelData)
	LAM:RegisterOptionControls("DialogColorsControl", optionsTable)
	
end

EVENT_MANAGER:RegisterForEvent("DialogColors", EVENT_ADD_ON_LOADED , DialogColors.OnAddonLoaded)
