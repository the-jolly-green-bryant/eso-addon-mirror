BSCPillagers = BSCPillagers or {}
local BSCPIPO = BSCPillagers

local optionsTable = {}

local function AddSendFeedBack()
    table.insert(optionsTable, {
        type = "button",
        name = "Donate",
        tooltip = "Main - EU Server",
        func = function()
              local function PrefillMail()
                ZO_MailSendToField:SetText(BSCPIPO.Author)
                ZO_MailSendSubjectField:SetText(BSCPIPO.NameSpaced)
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
		type = "checkbox",
		name = "Always Enable", --GetString(SI_SYNERGY_NAME_USEPVP),
		getFunc = function() return BSCPIPO.SV_ACC.ENABLED end,
		setFunc = function(value) 
			BSCPIPO.SV_ACC.ENABLED = value 
			BSCPIPO:SetPosition()
		end,
	})
	table.insert(optionsTable, {
		type = "checkbox",
		name = "Track Only My CD",
		getFunc = function() return BSCPIPO.SV_ACC.OMCD end,
		setFunc = function(value) 
			BSCPIPO.SV_ACC.OMCD = value 
		end,
	})
	table.insert(optionsTable, {
		type = "slider",
		--disabled = function() return not BSCPIPO.SV_ACC.ENABLED end,
		name = "UI Set Alpha Value",
		tooltip = "",
		min = 0.1,
		max = 1,
		step = 0.1,
		default = 1,	
		getFunc = function() return BSCPIPO.SV_ACC.UI_ALPHA end,
		setFunc = function(value)
			BSCPIPO.SV_ACC.UI_ALPHA = value
			BSCPIPO:SetPosition()
		end,
	})
	table.insert(optionsTable, {
		type = "checkbox",
		name = "Play Sound ON Cooldown Finish (PP)", --GetString(SI_SYNERGY_NAME_USEPVP),
		getFunc = function() return BSCPIPO.SV_ACC.bPlaySound end,
		setFunc = function(value) 
			BSCPIPO.SV_ACC.bPlaySound = value
		end,
	})
	table.insert(optionsTable, {
		type = "checkbox",
		name = "Lock UI", --GetString(SI_SYNERGY_NAME_USEPVP),
		getFunc = function() return BSCPIPO.SV_ACC.LOCK_UI end,
		setFunc = function(value) 
			BSCPIPO.SV_ACC.LOCK_UI = value
			BSCPIPO:SetPosition()
		end,
	})
end

--
function BSCPIPO:InitMenu()
	-- the panel for the addons menu
	local panelData = {
		type = "panel",
		name = BSCPIPO.NameMenu,
		displayName = BSCPIPO.NameSpaced,
		author = BSCPIPO.Author,
		version = BSCPIPO.VersionDisplay,
		registerForRefresh = true,
	}		
	AddSendFeedBack()
	AddSettings()			
    LibAddonMenu2:RegisterAddonPanel(BSCPIPO.NameSpaced, panelData)
    LibAddonMenu2:RegisterOptionControls(BSCPIPO.NameSpaced, optionsTable)
end