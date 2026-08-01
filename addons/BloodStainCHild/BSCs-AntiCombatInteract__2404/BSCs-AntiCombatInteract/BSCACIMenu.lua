BSCACInteraction = BSCACInteraction or {}
local BSCACI = BSCACInteraction

--
function BSCACI.buildMenu()
	
    -- the panel for the addons menu
	local panelData = {
		type = "panel",
		name = ""..BSCACI.Name,
		displayName = ""..BSCACI.NameSpaced,
		author = ""..BSCACI.Author,
        version = ""..BSCACI.Version,
		registerForRefresh = true,
	}
	
	local optionsTable = {}

	table.insert(optionsTable, {
        type = "header",
        name = GetString(SI_BSCAI_NAME),
    })
	table.insert(optionsTable, {
		type = "checkbox",
		name = GetString(SI_BSCAI_ENABLED),
		getFunc = function() return BSCACI.SV.ENABLED end,
		setFunc = function(value) 
			BSCACI.SV.ENABLED = value 
		end,
	})
	table.insert(optionsTable, {
		type = "checkbox",
		name = GetString(SI_BSCAI_ENABLED_COMBAT),
		getFunc = function() return BSCACI.SV.ENABLED_ALWAYS_DISABLE end,
		setFunc = function(value) 
			BSCACI.SV.ENABLED_ALWAYS_DISABLE = value 
		end,
	})
	table.insert(optionsTable, {
		type = "checkbox",
		name = GetString(SI_BSCAI_ENABLED_PVP),
		getFunc = function() return BSCACI.SV.PVP_AREA_ENABLED end,
		setFunc = function(value) 
			BSCACI.SV.PVP_AREA_ENABLED = value 
		end,
	})
	
    LibAddonMenu2:RegisterAddonPanel(BSCACI.NameSpaced.."Options", panelData)
    LibAddonMenu2:RegisterOptionControls(BSCACI.NameSpaced.."Options", optionsTable)
end