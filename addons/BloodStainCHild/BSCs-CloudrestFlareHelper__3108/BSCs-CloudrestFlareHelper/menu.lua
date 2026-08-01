BSCCRHelper = BSCCRHelper or {}
local BSCCH = BSCCRHelper

-- AddonInfo
BSCCH.NameMenu = "BSCs-RoaringFlare"
BSCCH.NameSpaced = "BSCRoaringFlare"
BSCCH.Author = "(EU) @BloodStainChild666"
BSCCH.VersionDisplay = "1.1.0"

local optionsTable = {}

local function AddDivider(control)
	table.insert(control, {
		type = "divider",
	})
end

local function AddBasicSetting()
	table.insert(optionsTable, {
        type = "header",
		name = "UI Settings",
    })	
	--
	table.insert(optionsTable, {
		type = "checkbox",
		name = "Use Display Name? (@Name)",
		getFunc = function() return BSCCH.SV.USE_DISPLAYNAME end,
		setFunc = function(v) 
			BSCCH.SV.USE_DISPLAYNAME = v
		end,
	})
	
	table.insert(optionsTable, {
		type = "checkbox",
		name = "Enable SkillName Info: ("..zo_strformat("<<1>>", GetAbilityName(103531))..")",
		getFunc = function() return BSCCH.SV.UI_BUFF_NAME_ENABLED end,
		setFunc = function(v) 
			BSCCH.SV.UI_BUFF_NAME_ENABLED = v
			BSCCH.UpdateUISettings()
		end,
	})	
	table.insert(optionsTable, {
		type = "slider",
		disabled = function() return not BSCCH.SV.UI_BUFF_NAME_ENABLED end,
		name = "UI SkillName Size",
		min = 15,
		max = 100,
		step = 1,
		getFunc = function() return BSCCH.SV.UI_BUFF_NAME_SIZE end,
		setFunc = function(v)
			BSCCH.SV.UI_BUFF_NAME_SIZE = v
			BSCCH.UpdateUISettings()
		end,
		default = 35,
	})
	--
	AddDivider(optionsTable)
	table.insert(optionsTable, {
		type = "checkbox",
		name = "Flare Player Names Info",
		getFunc = function() return BSCCH.SV.UI_FLAREON_ENABLED end,
		setFunc = function(v) 
			BSCCH.SV.UI_FLAREON_ENABLED = v
			BSCCH.UpdateUISettings()
		end,
	})	
	table.insert(optionsTable, {
		type = "slider",
		disabled = function() return not BSCCH.SV.UI_FLAREON_ENABLED end,
		name = "UI Player Names Info Size",
		min = 15,
		max = 100,
		step = 1,
		getFunc = function() return BSCCH.SV.UI_FLAREON_SIZE end,
		setFunc = function(v)
			BSCCH.SV.UI_FLAREON_SIZE = v
			BSCCH.UpdateUISettings()
		end,
		default = 35,
	})
	--
	AddDivider(optionsTable)
	table.insert(optionsTable, {
		type = "checkbox",
		name = "Flare Info (Stay/Move)",
		getFunc = function() return BSCCH.SV.UI_FLARE_INFO_ENABLED end,
		setFunc = function(v) 
			BSCCH.SV.UI_FLARE_INFO_ENABLED = v
			BSCCH.UpdateUISettings()
		end,
	})	
	table.insert(optionsTable, {
		type = "slider",
		disabled = function() return not BSCCH.SV.UI_FLARE_INFO_ENABLED end,
		name = "UI Flare Info Info Size",
		min = 15,
		max = 100,
		step = 1,
		getFunc = function() return BSCCH.SV.UI_FLARE_INFO_SIZE end,
		setFunc = function(v)
			BSCCH.SV.UI_FLARE_INFO_SIZE = v
			BSCCH.UpdateUISettings()
		end,
		default = 35,
	})
	-- Next Flare
	AddDivider(optionsTable)
	table.insert(optionsTable, {
		type = "checkbox",
		name = "Enable Next Flare Countdown",
		getFunc = function() return BSCCH.SV.UI_NEXT_FLARE_ENABLED end,
		setFunc = function(v) 
			BSCCH.SV.UI_NEXT_FLARE_ENABLED = v
			BSCCH.UpdateUISettings()
		end,
	})
	table.insert(optionsTable, {
		type = "slider",
		disabled = function() return not BSCCH.SV.UI_NEXT_FLARE_ENABLED end,
		name = "Next Flare UI Size",
		min = 15,
		max = 100,
		step = 1,
		getFunc = function() return BSCCH.SV.UI_NEXT_FLARE_SIZE end,
		setFunc = function(v)
			BSCCH.SV.UI_NEXT_FLARE_SIZE = v
			BSCCH.UpdateUISettings()
		end,
		default = 40,
	})
end

function BSCCH.InitMenu()
	-- the panel for the addons menu
	local panelData = {
		type = "panel",
		name = BSCCH.NameMenu,
		displayName = BSCCH.NameSpaced,
		author = BSCCH.Author,
		version = BSCCH.VersionDisplay,
		registerForRefresh = true,
	}	
	
	AddBasicSetting()
	
    local addonpanel = LibAddonMenu2:RegisterAddonPanel(BSCCH.NameSpaced, panelData)
    LibAddonMenu2:RegisterOptionControls(BSCCH.NameSpaced, optionsTable)
		
	CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", 
		function(currentpanel) 
			if addonpanel == currentpanel then 				
				BSCCRHelperUI:SetHidden(false) 
				BSCCRHelperUI:SetMovable(true)
				BSCCRHelperUINextFlare:SetHidden(false) 				
				BSCCRHelperUINextFlare:SetMovable(true)
			end 
		end )
	CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", 
		function(currentpanel) 
			if addonpanel == currentpanel then 								
				BSCCRHelperUI:SetHidden(true) 
				BSCCRHelperUI:SetMovable(false)
				BSCCRHelperUINextFlare:SetHidden(true) 				
				BSCCRHelperUINextFlare:SetMovable(false)
			end 
		end )
end