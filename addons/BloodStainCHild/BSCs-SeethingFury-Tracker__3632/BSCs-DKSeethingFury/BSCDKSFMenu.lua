BSCDKSFury = BSCDKSFury or {}
local BSCDKSF = BSCDKSFury

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
        name = "Testing",
    })	
	table.insert(optionsTable, {
		type = "slider",
		name = "UI Set Alpha Value",
		tooltip = "",
		min = 0.1,
		max = 1,
		step = 0.1,
		default = 1,	
		getFunc = function() return BSCDKSF.SV_ACC.UI_ALPHA end,
		setFunc = function(value)
			BSCDKSF.SV_ACC.UI_ALPHA = value
			BSCDKSF:SetPosition()
		end,
	})
	table.insert(optionsTable, {
		type = "checkbox",
		name = "Show Only in Combat",
		tooltip = "",
		getFunc = function() return BSCDKSF.SV_ACC.UI_ONLYCOMBAT end,
		setFunc = function(value) 
			BSCDKSF.SV_ACC.UI_ONLYCOMBAT = value
		end,
	})	
end

--
function BSCDKSF:InitMenu()
	-- the panel for the addons menu
	local panelData = {
		type = "panel",
		name = BSCDKSF.NameMenu,
		displayName = BSCDKSF.NameSpaced,
		author = BSCDKSF.Author,
		version = BSCDKSF.VersionDisplay,
		registerForRefresh = true,
	}	
	
	AddSendFeedBack()
	AddSettings()	
		
    local addonpanel = LibAddonMenu2:RegisterAddonPanel(BSCDKSF.NameSpaced, panelData)
    LibAddonMenu2:RegisterOptionControls(BSCDKSF.NameSpaced, optionsTable)
			
	CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", function(currentpanel) if addonpanel == currentpanel then BSCDKSeethingFuryUI:SetHidden(false) end end )
	CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", function(currentpanel) if addonpanel == currentpanel then BSCDKSeethingFuryUI:SetHidden(true) end end )
end