local panelData = {
	type = "panel",
	displayName         = '|cFACC2E' .. GetString( CE_Addon_DisplayName ) .. '|r',
	name                = CraftingExperience.name,
	author              = CraftingExperience.author,
	version             = CraftingExperience.version,
	slashCommand        = "/ce",
	registerForRefresh  = true,
	registerForDefaults = true,
}

local optionsTable = {
	[1] = {
		type  = "header",
		name  = GetString( CE_Panel_Heading ),
		width = "full",
	},
	[2] = {
		type = "description",
		title = nil,
		text = GetString( CE_Panel_Description ),
		width = "full",
	},
	[3] = {
		type = "dropdown",
		name = GetString( CE_Panel_Feedback_Label ),
		tooltip = GetString( CE_Panel_Feedback_Tooltip ),
		choices = {'Default','Chat'},
		getFunc = function() return CraftingExperience.settings.feedback end,
		setFunc = function( savedValue ) CraftingExperience.settings.feedback = savedValue end,
		width = "full",
		default = CraftingExperience.defaults.feedback,
	},
	[4] = {
		type = "editbox",
		name = GetString( CE_Pending_Description ),
		tooltip = GetString( CE_Pending_Tooltip ),
		getFunc = function() return CraftingExperience.settings.pending end,
		setFunc = function(text) CraftingExperience.settings.pending = text end,
		isMultiline = false,	--boolean
		width = "full",	--or "half" (optional)
		--warning = "Will need to reload the UI.", -- if this stays, should switch to lang string
		default = GetString( CE_Pending_Craft_Message ),
	},
	[5] = {
		type = "description",
		title = nil,
		text = GetString( CE_Panel_Tip ),
		width = "full",
	},
}

function CraftingExperience.CreateSettingsPanel()

	local LAM = LibStub("LibAddonMenu-2.0")
	
	LAM:RegisterAddonPanel( CraftingExperience.name .. 'Config', panelData )
	LAM:RegisterOptionControls( CraftingExperience.name .. 'Config', optionsTable )

end