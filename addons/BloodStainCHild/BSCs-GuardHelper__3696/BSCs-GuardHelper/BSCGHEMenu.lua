BSCGUardHelper = BSCGUardHelper or {}
local BSCGHE = BSCGUardHelper


local optionsTable = {}

local function AddSendFeedBack()
    table.insert(optionsTable, {
        type = "button",
        name = "Donate",
        tooltip = "Main - EU Server",
        func = function()
              local function PrefillMail()
                ZO_MailSendToField:SetText(BSCDKSF.Author)
                ZO_MailSendSubjectField:SetText(BSCDKSF.NameSpaced)
                ZO_MailSendBodyField:TakeFocus()
              end
                SCENE_MANAGER:Show('mailSend')
                zo_callLater(PrefillMail, 250)
        end,
        width = "half",
        warning = "",	
    })
end
--
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

local function AddSettings()
	table.insert(optionsTable, {
        type = "header",
        name = "Guard Info",
    })	
	table.insert(optionsTable, {
		type = "checkbox",
		name = "Play Sound On Give/Remove",
		tooltip = "",
		getFunc = function() return BSCGHE.SV_ACC.bPlaySound end,
		setFunc = function(value) 
			BSCGHE.SV_ACC.bPlaySound = value
		end,
	})	
	table.insert(optionsTable, {
		type = "slider",
		name = "UI Set Alpha Value",
		tooltip = "",
		min = 0.1,
		max = 1,
		step = 0.1,
		default = 1,	
		getFunc = function() return BSCGHE.SV_ACC.UI_ALPHA end,
		setFunc = function(value)
			BSCGHE.SV_ACC.UI_ALPHA = value
			BSCGHE:SetPosition()
		end,
	})
	AddDivider(optionsTable)
	table.insert(optionsTable, {
		type = "checkbox",
		name = "Show when you receive guard",
		tooltip = "",
		getFunc = function() return BSCGHE.SV_ACC.breceive end,
		setFunc = function(value) 
			BSCGHE.SV_ACC.breceive = value
		end,
	})	
	
end

--
function BSCGHE:InitMenu()
	-- the panel for the addons menu
	local panelData = {
		type = "panel",
		name = BSCGHE.NameMenu,
		displayName = BSCGHE.NameMenu,
		author = BSCGHE.Author,
		version = BSCGHE.VersionDisplay,
		registerForRefresh = true,
	}	
	
	AddSendFeedBack()
	AddSettings()	
		
    local addonpanel = LibAddonMenu2:RegisterAddonPanel(BSCGHE.NameMenu, panelData)
    LibAddonMenu2:RegisterOptionControls(BSCGHE.NameMenu, optionsTable)
			
	CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", function(currentpanel) if addonpanel == currentpanel then BSCGUardHelperUI:SetHidden(false) end end )
	CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", function(currentpanel) if addonpanel == currentpanel then BSCGUardHelperUI:SetHidden(true) end end )
end