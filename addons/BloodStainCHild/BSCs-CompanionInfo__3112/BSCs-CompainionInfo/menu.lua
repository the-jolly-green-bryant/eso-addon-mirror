BSCCompainionInfo = BSCCompainionInfo or {}
local BSCCOIN = BSCCompainionInfo

local optionsTable = {}

local function AddDivider(control)
	table.insert(control, {
		type = "divider",
	})
end

local function AddHPBarSettings()
	table.insert(optionsTable, {
        type = "header",
		name = "Healt Bar Settings",
    })	
	table.insert(optionsTable, {
		type = "slider",
		name = "UI HP Bar Hight",
		min = 30,
		max = 100,
		step = 1,
		getFunc = function() return BSCCOIN.SV.UI_HIGHT_HPBAR end,
		setFunc = function(v)
			BSCCOIN.SV.UI_HIGHT_HPBAR = v
			BSCCOIN:UpdateUISettings()
		end,
		default = 36,
	})
	AddDivider(optionsTable)
	table.insert(optionsTable, {
		type = "slider",
		name = "Font Size",
		min = 3,
		max = 54,
		step = 1,
		getFunc = function() return BSCCOIN.SV.HPBAR_FONT_SIZE end,
		setFunc = function(v)
			BSCCOIN.SV.HPBAR_FONT_SIZE = v
			BSCCOIN:UpdateUISettings()
		end,
		default = 23,
	})
	table.insert(optionsTable, {
		type = "dropdown",
		name = "Font", 
		tooltip = "",
        choices = {"MEDIUM_FONT", "BOLD_FONT", "CHAT_FONT", "GAMEPAD_LIGHT_FONT", "GAMEPAD_MEDIUM_FONT", "GAMEPAD_BOLD_FONT", "ANTIQUE_FONT", "HANDWRITTEN_FONT", "STONE_TABLET_FONT"},		
		getFunc = function()
			return BSCCOIN.SV.HPBAR_FONT 
		end,
		setFunc = function(v) 
			BSCCOIN.SV.HPBAR_FONT = v
			BSCCOIN:UpdateUISettings()
		end,
        width = "full",
	})
	table.insert(optionsTable, {
		type = "dropdown",
		name = "Font Style", 
		tooltip = "",
        choices = { "soft-shadow-thick", "soft-shadow-thin", "soft-shadow-thick", "thick-outline", "shadow" },		
		getFunc = function()
			return BSCCOIN.SV.HPBAR_FONT_STYLE 
		end,
		setFunc = function(v) 
			BSCCOIN.SV.HPBAR_FONT_STYLE = v
			BSCCOIN:UpdateUISettings()
		end,
        width = "full",
	})
	table.insert(optionsTable, {
		type = "colorpicker",
		name = "Font Color",
		tooltip = "",
		getFunc = function() return unpack(BSCCOIN.SV.HPBAR_FONT_COLOR) end,	--(alpha is optional)
		setFunc = function(r,g,b,a) 
			BSCCOIN.SV.HPBAR_FONT_COLOR = {r, g, b, a}
			BSCCOIN:UpdateUISettings()
		end,	--(alpha is optional)
        width = "full",
	})
	AddDivider(optionsTable)
	table.insert(optionsTable, {
		type = "colorpicker",
		name = "Bar Start Color",
		tooltip = "",
		getFunc = function() return BSCCOIN.SV.HPBAR_BAR_COLORS[1].r, BSCCOIN.SV.HPBAR_BAR_COLORS[1].g, BSCCOIN.SV.HPBAR_BAR_COLORS[1].b, BSCCOIN.SV.HPBAR_BAR_COLORS[1].a end,	--(alpha is optional)
		setFunc = function(r,g,b,a) 
			BSCCOIN.SV.HPBAR_BAR_COLORS[1].r = r
			BSCCOIN.SV.HPBAR_BAR_COLORS[1].g = g
			BSCCOIN.SV.HPBAR_BAR_COLORS[1].b = b
			BSCCOIN.SV.HPBAR_BAR_COLORS[1].a = a
			BSCCOIN:UpdateUISettings()
		end,	--(alpha is optional)
        width = "full",
	})
	table.insert(optionsTable, {
		type = "colorpicker",
		name = "Bar End Color",
		tooltip = "",
		getFunc = function() return BSCCOIN.SV.HPBAR_BAR_COLORS[2].r, BSCCOIN.SV.HPBAR_BAR_COLORS[2].g, BSCCOIN.SV.HPBAR_BAR_COLORS[2].b, BSCCOIN.SV.HPBAR_BAR_COLORS[2].a end,	--(alpha is optional)
		setFunc = function(r,g,b,a) 
			BSCCOIN.SV.HPBAR_BAR_COLORS[2].r = r
			BSCCOIN.SV.HPBAR_BAR_COLORS[2].g = g
			BSCCOIN.SV.HPBAR_BAR_COLORS[2].b = b
			BSCCOIN.SV.HPBAR_BAR_COLORS[2].a = a
			BSCCOIN:UpdateUISettings()
		end,	--(alpha is optional)
        width = "full",
	})
end

local function AddXPBarSettings()
	table.insert(optionsTable, {
        type = "header",
		name = "Experience Bar Settings",
    })	
	-- XP Info
	table.insert(optionsTable, {
		type = "checkbox",
		name = "UI Enable XP Bar",
		getFunc = function() return BSCCOIN.SV.DISPLAY_EXPBAR end,
		setFunc = function(v) 
			BSCCOIN.SV.DISPLAY_EXPBAR = v
			BSCCOIN:UpdateUISettings()
		end,
	})
	table.insert(optionsTable, {
		type = "slider",
		disabled = function() return not BSCCOIN.SV.DISPLAY_EXPBAR end,
		name = "UI XP Bar Hight",
		min = 15,
		max = 100,
		step = 1,
		getFunc = function() return BSCCOIN.SV.UI_HIGHT_XPBAR end,
		setFunc = function(v)
			BSCCOIN.SV.UI_HIGHT_XPBAR = v
			BSCCOIN:UpdateUISettings()
		end,
		default = 20,
	})
	AddDivider(optionsTable)
	table.insert(optionsTable, {
		type = "slider",
		disabled = function() return not BSCCOIN.SV.DISPLAY_EXPBAR end,
		name = "Font Size",
		min = 3,
		max = 54,
		step = 1,
		getFunc = function() return BSCCOIN.SV.XPBAR_FONT_SIZE end,
		setFunc = function(v)
			BSCCOIN.SV.XPBAR_FONT_SIZE = v
			BSCCOIN:UpdateUISettings()
		end,
		default = 23,
	})
	table.insert(optionsTable, {
		type = "dropdown",
		disabled = function() return not BSCCOIN.SV.DISPLAY_EXPBAR end,
		name = "Font", 
		tooltip = "",
        choices = {"MEDIUM_FONT", "BOLD_FONT", "CHAT_FONT", "GAMEPAD_LIGHT_FONT", "GAMEPAD_MEDIUM_FONT", "GAMEPAD_BOLD_FONT", "ANTIQUE_FONT", "HANDWRITTEN_FONT", "STONE_TABLET_FONT"},		
		getFunc = function()
			return BSCCOIN.SV.XPBAR_FONT 
		end,
		setFunc = function(v) 
			BSCCOIN.SV.XPBAR_FONT = v
			BSCCOIN:UpdateUISettings()
		end,
        width = "full",
	})
	table.insert(optionsTable, {
		type = "dropdown",
		disabled = function() return not BSCCOIN.SV.DISPLAY_EXPBAR end,
		name = "Font Style", 
		tooltip = "",
        choices = { "soft-shadow-thick", "soft-shadow-thin", "soft-shadow-thick", "thick-outline", "shadow" },		
		getFunc = function()
			return BSCCOIN.SV.XPBAR_FONT_STYLE 
		end,
		setFunc = function(v) 
			BSCCOIN.SV.XPBAR_FONT_STYLE = v
			BSCCOIN:UpdateUISettings()
		end,
        width = "full",
	})
	table.insert(optionsTable, {
		type = "colorpicker",
		disabled = function() return not BSCCOIN.SV.DISPLAY_EXPBAR end,
		name = "Font Color",
		tooltip = "",
		getFunc = function() return unpack(BSCCOIN.SV.XPBAR_FONT_COLOR) end,	--(alpha is optional)
		setFunc = function(r,g,b,a) 
			BSCCOIN.SV.XPBAR_FONT_COLOR = {r, g, b, a}
			BSCCOIN:UpdateUISettings()
		end,	--(alpha is optional)
        width = "full",
	})
	AddDivider(optionsTable)
	table.insert(optionsTable, {
		type = "colorpicker",
		disabled = function() return not BSCCOIN.SV.DISPLAY_EXPBAR end,
		name = "Bar Start Color",
		tooltip = "",
		getFunc = function() return BSCCOIN.SV.XPBAR_BAR_COLORS[1].r, BSCCOIN.SV.XPBAR_BAR_COLORS[1].g, BSCCOIN.SV.XPBAR_BAR_COLORS[1].b, BSCCOIN.SV.XPBAR_BAR_COLORS[1].a end,	--(alpha is optional)
		setFunc = function(r,g,b,a) 
			BSCCOIN.SV.XPBAR_BAR_COLORS[1].r = r
			BSCCOIN.SV.XPBAR_BAR_COLORS[1].g = g
			BSCCOIN.SV.XPBAR_BAR_COLORS[1].b = b
			BSCCOIN.SV.XPBAR_BAR_COLORS[1].a = a
			BSCCOIN:UpdateUISettings()
		end,	--(alpha is optional)
        width = "full",
	})
	table.insert(optionsTable, {
		type = "colorpicker",
		disabled = function() return not BSCCOIN.SV.DISPLAY_EXPBAR end,
		name = "Bar End Color",
		tooltip = "",
		getFunc = function() return BSCCOIN.SV.XPBAR_BAR_COLORS[2].r, BSCCOIN.SV.XPBAR_BAR_COLORS[2].g, BSCCOIN.SV.XPBAR_BAR_COLORS[2].b, BSCCOIN.SV.XPBAR_BAR_COLORS[2].a end,	--(alpha is optional)
		setFunc = function(r,g,b,a) 
			BSCCOIN.SV.XPBAR_BAR_COLORS[2].r = r
			BSCCOIN.SV.XPBAR_BAR_COLORS[2].g = g
			BSCCOIN.SV.XPBAR_BAR_COLORS[2].b = b
			BSCCOIN.SV.XPBAR_BAR_COLORS[2].a = a
			BSCCOIN:UpdateUISettings()
		end,	--(alpha is optional)
        width = "full",
	})
end

local function AddNameIconSettings()
	table.insert(optionsTable, {
        type = "header",
		name = "Comanion Name Settings",
    })
	table.insert(optionsTable, {
		type = "checkbox",
		name = "Show Comanion Name",
		getFunc = function() return BSCCOIN.SV.DISPLAY_NAME end,
		setFunc = function(v) 
			BSCCOIN.SV.DISPLAY_NAME = v
			BSCCOIN:UpdateUISettings()
		end,
	})
	table.insert(optionsTable, {
		type = "checkbox",
		name = "Show Comanion Icon",
		disabled = function() return not BSCCOIN.SV.DISPLAY_NAME end,
		getFunc = function() return BSCCOIN.SV.DISPLAY_ICON end,
		setFunc = function(v) 
			BSCCOIN.SV.DISPLAY_ICON = v
			BSCCOIN:UpdateUISettings()
		end,
	})	
	table.insert(optionsTable, {
		type = "slider",
		disabled = function() return not BSCCOIN.SV.DISPLAY_NAME end,
		name = "Icon Size",
		min = 3,
		max = 54,
		step = 1,
		getFunc = function() return BSCCOIN.SV.ICON_SIZE end,
		setFunc = function(v)
			BSCCOIN.SV.ICON_SIZE = v
			BSCCOIN:UpdateUISettings()
		end,
		default = 23,
	})
	AddDivider(optionsTable)
	table.insert(optionsTable, {
		type = "slider",
		disabled = function() return not BSCCOIN.SV.DISPLAY_NAME end,
		name = "Font Size",
		min = 3,
		max = 54,
		step = 1,
		getFunc = function() return BSCCOIN.SV.NAME_FONT_SIZE end,
		setFunc = function(v)
			BSCCOIN.SV.NAME_FONT_SIZE = v
			BSCCOIN:UpdateUISettings()
		end,
		default = 23,
	})
	table.insert(optionsTable, {
		type = "dropdown",
		disabled = function() return not BSCCOIN.SV.DISPLAY_NAME end,
		name = "Font", 
		tooltip = "",
        choices = {"MEDIUM_FONT", "BOLD_FONT", "CHAT_FONT", "GAMEPAD_LIGHT_FONT", "GAMEPAD_MEDIUM_FONT", "GAMEPAD_BOLD_FONT", "ANTIQUE_FONT", "HANDWRITTEN_FONT", "STONE_TABLET_FONT"},		
		getFunc = function()
			return BSCCOIN.SV.NAME_FONT 
		end,
		setFunc = function(v) 
			BSCCOIN.SV.NAME_FONT = v
			BSCCOIN:UpdateUISettings()
		end,
        width = "full",
	})
	table.insert(optionsTable, {
		type = "dropdown",
		disabled = function() return not BSCCOIN.SV.DISPLAY_NAME end,
		name = "Font Style", 
		tooltip = "",
        choices = { "soft-shadow-thick", "soft-shadow-thin", "soft-shadow-thick", "thick-outline", "shadow" },		
		getFunc = function()
			return BSCCOIN.SV.NAME_FONT_STYLE 
		end,
		setFunc = function(v) 
			BSCCOIN.SV.NAME_FONT_STYLE = v
			BSCCOIN:UpdateUISettings()
		end,
        width = "full",
	})
	table.insert(optionsTable, {
		type = "colorpicker",
		disabled = function() return not BSCCOIN.SV.DISPLAY_NAME end,
		name = "Font Color",
		tooltip = "",
		getFunc = function() return unpack(BSCCOIN.SV.NAME_FONT_COLOR) end,	--(alpha is optional)
		setFunc = function(r,g,b,a) 
			BSCCOIN.SV.NAME_FONT_COLOR = {r, g, b, a}
			BSCCOIN:UpdateUISettings()
		end,	--(alpha is optional)
        width = "full",
	})
end

local function AddSkillSettings()
	table.insert(optionsTable, {
        type = "header",
		name = "Skill Icon Settings",
		tooltip = "Warning this is still in Testing!",
    })
	-- Skill Info
	table.insert(optionsTable, {
		type = "checkbox",
		name = "Enable Skill Icon's",
		tooltip = "Warning this is still in Testing!",
		getFunc = function() return BSCCOIN.SV.DISPLAY_SKILLS end,
		setFunc = function(v) 
			BSCCOIN.SV.DISPLAY_SKILLS = v
			BSCCOIN:UpdateUISettings()
		end,
	})
	table.insert(optionsTable, {
		type = "slider",
		disabled = function() return not BSCCOIN.SV.DISPLAY_SKILLS end,
		name = "Skill Icon Size",
		min = 15,
		max = 100,
		step = 1,
		getFunc = function() return BSCCOIN.SV.UI_HIGHT_SKILLBAR end,
		setFunc = function(v)
			BSCCOIN.SV.UI_HIGHT_SKILLBAR = v
			BSCCOIN:UpdateUISettings()
		end,
		default = 30,
	})	
	table.insert(optionsTable, {
		type = "slider",
		disabled = function() return not BSCCOIN.SV.DISPLAY_SKILLS end,
		name = "Font Size",
		min = 3,
		max = 54,
		step = 1,
		getFunc = function() return BSCCOIN.SV.SKILLS_FONT_SIZE end,
		setFunc = function(v)
			BSCCOIN.SV.SKILLS_FONT_SIZE = v
			BSCCOIN:UpdateUISettings()
		end,
		default = 14,
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
		name = "Lock UI",
		getFunc = function() return BSCCOIN.SV.UI_LOCK end,
		setFunc = function(v) 
			BSCCOIN.SV.UI_LOCK = v
			BSCCOIN:UpdateUISettings()
		end,
	})
	table.insert(optionsTable, {
		type = "checkbox",
		name = "Print Rapport Info Into Chat",
		getFunc = function() return BSCCOIN.SV.PRINT_RAPPORT_CHAT end,
		setFunc = function(v) 
			BSCCOIN.SV.PRINT_RAPPORT_CHAT = v
		end,
	})
	table.insert(optionsTable, {
		type = "slider",
		name = "UI Width",
		min = 200,
		max = 800,
		step = 1,
		getFunc = function() return BSCCOIN.SV.UI_WIDTH end,
		setFunc = function(v)
			BSCCOIN.SV.UI_WIDTH = v
			BSCCOIN:UpdateUISettings()
		end,
		default = 250,
	})
	table.insert(optionsTable, {
		type = "dropdown",
		name = "Digit decimal replacer", 
		tooltip = "",
        choices = { ".", ",", ":", "-", "" },		
		getFunc = function()
			return BSCCOIN.SV.DIGIT_DECIMAL_REPLACER 
		end,
		setFunc = function(v) 
			BSCCOIN.SV.DIGIT_DECIMAL_REPLACER = v
			d(zo_strformat('(<<1>> / <<2>>)', BSCCOIN:FormatNumer(BSCCOIN.RAPPORT_MIN), BSCCOIN:FormatNumer(BSCCOIN.RAPPORT_MAX)))
			BSCCOIN:UpdateUISettings()
		end,
        width = "full",
	})	
end

local function AddFeedBackButton()
	table.insert(optionsTable, {
		type = "button",
		name = "Send Feedback",
        func = function()              
		  local function PrefillMail()
			ZO_MailSendToField:SetText(BSCCOIN.Author)
			ZO_MailSendSubjectField:SetText(BSCCOIN.NameSpaced.." "..BSCCOIN.VersionDisplay)
			ZO_MailSendBodyField:TakeFocus()
		  end
			SCENE_MANAGER:Show('mailSend')
			zo_callLater(PrefillMail, 250)
        end,
	})
end

function BSCCOIN:InitMenu()
	-- the panel for the addons menu
	local panelData = {
		type = "panel",
		name = BSCCOIN.NameMenu,
		displayName = BSCCOIN.NameSpaced,
		author = BSCCOIN.Author,
		version = BSCCOIN.VersionDisplay,
		registerForRefresh = true,
	}	
	
	if GetWorldName() == "EU Megaserver" then
		AddFeedBackButton()
	end
	
	AddBasicSetting()
	AddNameIconSettings()
	AddHPBarSettings()
	AddXPBarSettings()
	AddSkillSettings()	
	
    local addonpanel = LibAddonMenu2:RegisterAddonPanel(BSCCOIN.NameSpaced, panelData)
    LibAddonMenu2:RegisterOptionControls(BSCCOIN.NameSpaced, optionsTable)
		
	CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", 
		function(currentpanel) 
			if addonpanel == currentpanel then 				
				BSCCompainionInfoUI:SetHidden(false) 
			end 
		end )
	CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", 
		function(currentpanel) 
			if addonpanel == currentpanel then 								
				BSCCompainionInfoUI:SetHidden(true) 
			end 
		end )
end

