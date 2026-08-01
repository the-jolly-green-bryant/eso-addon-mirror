BSCUDPoints = BSCUDPoints or {}
local BSCUDP = BSCUDPoints

local optionsTable = {}

local function AddSendFeedBack()
    table.insert(optionsTable, {
        type = "button",
        name = "Donate",
        tooltip = "Main - EU Server",
        func = function()
              local function PrefillMail()
                ZO_MailSendToField:SetText(BSCUDP.Author)
                ZO_MailSendSubjectField:SetText(BSCUDP.NameSpaced)
                ZO_MailSendBodyField:TakeFocus()
              end
                SCENE_MANAGER:Show('mailSend')
                zo_callLater(PrefillMail, 250)
        end,
        width = "half",
    })
end

local function AddTexture(control, strIcon, strDesciption)
	table.insert(control, {
        type = "texture",
        image =  strIcon,
		tooltip = strDesciption,
        imageWidth = 32,
        imageHeight = 32,
        width = "half",
	})
end

local function AddDivider(control)
	table.insert(control, {
		type = "divider",
	})
end

local function AddSetting()
	table.insert(optionsTable, {
        type = "header",
        name = "Passive Ability Tracking",
    })	
	table.insert(optionsTable, {
		type = "checkbox",
		name = "Enable Passive Tracking UI",
		getFunc = function() return BSCUDP.SV_ACC.UI_ENABLE end,
		setFunc = function(value) 
			BSCUDP.SV_ACC.UI_ENABLE = value
			BSCUDP:UpdatePassiveUI()
		end,
	})
	table.insert(optionsTable, {
		type = "checkbox",
		name = "Hide Passive Tracking UI when Active",
		tooltip = "UI will only be visible when the passive can be Triggered",
		getFunc = function() return BSCUDP.SV_ACC.UI_ALLWAYS end,
		setFunc = function(value) 
			BSCUDP.SV_ACC.UI_ALLWAYS = value
		end,
	})
	table.insert(optionsTable, {
		type = "checkbox",
		name = "Lock UI",
		getFunc = function() return BSCUDP.SV_ACC.UI_LOCK end,
		setFunc = function(value) 
			BSCUDP.SV_ACC.UI_LOCK = value
			BSCUDP:UpdateSettings()
		end,
	})
	table.insert(optionsTable, {
		type = "slider",
		name = "Set Transparency",
		tooltip = "",
		min = 0.1,
		max = 1,
		step = 0.1,
		default = 1,	
		getFunc = function() return BSCUDP.SV_ACC.UI_ALPHA end,
		setFunc = function(value)
			BSCUDP.SV_ACC.UI_ALPHA = value
			BSCUDP:UpdateSettings()
		end,
	})	
	table.insert(optionsTable, {
        type = "header",
		name = "Ulti Points Base UI (LA/HA/DODGED)",
    })
	table.insert(optionsTable, {
		type = "checkbox",
		name = "Enable Ult Points Base Generate UI",
		getFunc = function() return BSCUDP.SV_ACC.UI_ENABLE_BASE end,
		setFunc = function(value) 
			BSCUDP.SV_ACC.UI_ENABLE_BASE = value
			BSCUDP:UpdateEnableBase()
		end,
	})
	table.insert(optionsTable, {
		type = "checkbox",
		name = "Hide Base Ult Points Tracking UI when Active",
		tooltip = "UI will only be visible when the Base Ult Points can be Triggered",
		getFunc = function() return BSCUDP.SV_ACC.UI_ALLWAYS_BASE end,
		setFunc = function(value) 
			BSCUDP.SV_ACC.UI_ALLWAYS_BASE = value
		end,
	})
	table.insert(optionsTable, {
		type = "checkbox",
		name = "Lock UI",
		getFunc = function() return BSCUDP.SV_ACC.UI_LOCK_BASE end,
		setFunc = function(value) 
			BSCUDP.SV_ACC.UI_LOCK_BASE = value
			BSCUDP:UpdateSettings()
		end,
	})
	table.insert(optionsTable, {
		type = "slider",
		name = "Set Transparency",
		tooltip = "",
		min = 0.1,
		max = 1,
		step = 0.1,
		default = 1,	
		getFunc = function() return BSCUDP.SV_ACC.UI_ALPHA_BASE end,
		setFunc = function(value)
			BSCUDP.SV_ACC.UI_ALPHA_BASE = value
			BSCUDP:UpdateSettings()
		end,
	})	
	table.insert(optionsTable, {
        type = "header",
		name = "Ulti Points Info UI",
    })
	table.insert(optionsTable, {
		type = "checkbox",
		name = "Enable Ult Points Info UI",
		getFunc = function() return BSCUDP.SV_ACC.UI_ENABLE_UP end,
		setFunc = function(value) 
			BSCUDP.SV_ACC.UI_ENABLE_UP = value
			BSCUDP:UpdateEnableUP()
		end,
	})
	table.insert(optionsTable, {
		type = "checkbox",
		name = "Lock UI",
		getFunc = function() return BSCUDP.SV_ACC.UI_LOCK_UP end,
		setFunc = function(value) 
			BSCUDP.SV_ACC.UI_LOCK_UP = value
			BSCUDP:UpdateSettings()
		end,
	})
	table.insert(optionsTable, {
		type = "slider",
		name = "Set Transparency",
		tooltip = "",
		min = 0.1,
		max = 1,
		step = 0.1,
		default = 1,	
		getFunc = function() return BSCUDP.SV_ACC.UI_ALPHA_UP end,
		setFunc = function(value)
			BSCUDP.SV_ACC.UI_ALPHA_UP = value
			BSCUDP:UpdateSettings()
		end,
	})	
	table.insert(optionsTable, {
		type = "dropdown",
		name =  "Choose The Ult you want to track",
        choices = {"Active One", "PRIMARY", "BACKUP"},		
		getFunc = function()
			if BSCUDP.SV_ACC.UI_HOTBAR_UP == HOTBAR_CATEGORY_PRIMARY then
				return "PRIMARY" 
			elseif BSCUDP.SV_ACC.UI_HOTBAR_UP == HOTBAR_CATEGORY_BACKUP then
				return "BACKUP"
			else			
				return "Active One" 
			end
		end,
		setFunc = function(v) 
			if v == "PRIMARY" then
				BSCUDP.SV_ACC.UI_HOTBAR_UP = HOTBAR_CATEGORY_PRIMARY 
			elseif v == "BACKUP" then
				BSCUDP.SV_ACC.UI_HOTBAR_UP = HOTBAR_CATEGORY_BACKUP 
			else
				BSCUDP.SV_ACC.UI_HOTBAR_UP = -1 
			end
			BSCUDP:UpdateSettings()
		end,
        width = "full",
	})	
	table.insert(optionsTable, {
        type = "header",
		name = "Font Settings",
    })
	table.insert(optionsTable, {
		type = "slider",
		name = "Font Size",
		min = 8,
		max = 60,
		step = 1,
		getFunc = function() return BSCUDP.SV_ACC.FONT_SIZE end,
		setFunc = function(v)
			BSCUDP.SV_ACC.FONT_SIZE = v
			BSCUDP.UpdateSettings()
		end,
		default = 28,
	})
	table.insert(optionsTable, {
		type = "dropdown",
		name = "Font", 
		tooltip = "",
        choices = {"MEDIUM_FONT", "BOLD_FONT", "CHAT_FONT", "GAMEPAD_LIGHT_FONT", "GAMEPAD_MEDIUM_FONT", "GAMEPAD_BOLD_FONT", "ANTIQUE_FONT", "HANDWRITTEN_FONT", "STONE_TABLET_FONT"},		
		getFunc = function()
			return BSCUDP.SV_ACC.UI_FONT 
		end,
		setFunc = function(v) 
			BSCUDP.SV_ACC.UI_FONT = v	
			BSCUDP:UpdateSettings()
		end,
        width = "full",
	})
	table.insert(optionsTable, {
		type = "dropdown",
		name = "Font Style", 
		tooltip = "",
        choices = { "soft-shadow-thick", "soft-shadow-thin", "thick-outline", "shadow" },		
		getFunc = function()
			return BSCUDP.SV_ACC.UI_FONT_STYLE 
		end,
		setFunc = function(v) 
			BSCUDP.SV_ACC.UI_FONT_STYLE = v
			BSCUDP:UpdateSettings()
		end,
        width = "full",
	})
	table.insert(optionsTable, {
		type = "colorpicker",
		name = "Color Ready",
		tooltip = "",
		getFunc = function() return unpack(BSCUDP.SV_ACC.UI_FONT_COLOR_N) end,
		setFunc = function(r,g,b,a) 
			BSCUDP.SV_ACC.UI_FONT_COLOR_N = {r, g, b, a}
			BSCUDP:UpdateSettings()
		end,
        width = "full",
	})
	table.insert(optionsTable, {
		type = "colorpicker",
		name = "Color not Ready",
		tooltip = "",
		getFunc = function() return unpack(BSCUDP.SV_ACC.UI_FONT_COLOR_C) end,
		setFunc = function(r,g,b,a) 
			BSCUDP.SV_ACC.UI_FONT_COLOR_C = {r, g, b, a}
			BSCUDP:UpdateSettings()
		end,
        width = "full",
	})
end

function BSCUDP:InitMenu()
	-- the panel for the addons menu
	local panelData = {
		type = "panel",
		name = BSCUDP.NameMenu,
		displayName = BSCUDP.NameSpaced,
		author = BSCUDP.Author,
		version = BSCUDP.VersionDisplay,
		registerForRefresh = true,
	}	
	AddSendFeedBack()
	AddSetting()	
    local addonpanel = LibAddonMenu2:RegisterAddonPanel(BSCUDP.NameSpaced, panelData)
    LibAddonMenu2:RegisterOptionControls(BSCUDP.NameSpaced, optionsTable)		
	CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", function(currentpanel) 
		if addonpanel == currentpanel then 
			BSCUDULTPointsUI:SetHidden(false)
			--BSCUDPointsUI:SetHidden(false)
			for index = 1, GetNumClasses(), 1 do	
				local _classId_ = GetClassIdByIndex(index)		
				BSCUDP.frames[_classId_]:SetHidden(false)
			end
			BSCUDPointsUIBASE:SetHidden(false)
		end
	end)
	CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", function(currentpanel) 
		if addonpanel == currentpanel then 
			BSCUDULTPointsUI:SetHidden(true)
			--BSCUDPointsUI:SetHidden(true)
			for index = 1, GetNumClasses(), 1 do	
				local _classId_ = GetClassIdByIndex(index)		
				BSCUDP.frames[_classId_]:SetHidden(true)
			end
			BSCUDPointsUIBASE:SetHidden(true)
		end
	end)
end




