BSCTauntCounter = BSCTauntCounter or {}
local BSCTC = BSCTauntCounter


local s_sounds = { }
local s_choices = { }
------------------------------------------------------------------------------
-- Soundlist 
------------------------------------------------------------------------------
BSCTC.SOUNDLIST = {
	NONE                           				= "No_Sound",
	VOICE_CHAT_ALERT_CHANNEL_MADE_ACTIVE        = "Voice_Chat_Alert_Channel_Made_Active",
	VOICE_CHAT_MENU_CHANNEL_MADE_ACTIVE         = "Voice_Chat_Menu_Channel_Made_Active",
	SCRIPTED_WORLD_EVENT_INVITED    			= "Quest_Shared",
	CLOTHIER_EXTRACTED_BOOSTER             	 	= "Clothier_Extracted_Booster",
	DIALOG_DECLINE                 				= "Dialog_Decline",
	RAID_TRIAL_COMPLETED                    	= "Raid_Trial_Completed",
	RETRAITING_RETRAIT_TOOLTIP_GLOW_SUCCESS 	= "Retraiting_Retrait_Tooltip_Glow_Success",
	CONSOLE_GAME_ENTER 							= "Console_Game_Enter",
	AVA_GATE_CLOSED 							= "AvA_Gate_Closed",
	DISPLAY_ANNOUNCEMENT                   	 	= "Display_Announcement",
	BOOK_ACQUIRED                   			= "Book_Acquired",
	KEYBIND_BUTTON_DISABLED                 	= "Keybind_Button_Disabled",
	TELVAR_LOST                     			= "Telvar_Lost",
	TELVAR_GAINED                   			= "Telvar_Gained",
	TELVAR_MULTIPLIERMAX            			= "Telvar_MultiplierMax",
	TELVAR_MULTIPLIERUP             			= "Telvar_MultiplierUp",
	DUEL_INVITE_RECEIVED                        = "Duel_InviteReceived",
    DUEL_ACCEPTED                               = "Duel_Accepted",
    DUEL_START                                  = "Duel_Start",
    DUEL_WON                                    = "Duel_Won",
    DUEL_FORFEIT                                = "Duel_Forfeit",
    DUEL_BOUNDARY_WARNING                       = "Duel_Boundary_Warning",
}

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
		name = "Enable Addon",
		tooltip = "",
		getFunc = function() return BSCTC.SV_ACC.bEnableAddon end,
		setFunc = function(value) 
			BSCTC.SV_ACC.bEnableAddon = value
			BSCTC:EnableAddon()
		end,
	})	
	table.insert(optionsTable, {
		type = "checkbox",
		name = "Show only on Boss",
		tooltip = "",
		getFunc = function() return BSCTC.SV_ACC.bOnlyBoss end,
		setFunc = function(value) 
			BSCTC.SV_ACC.bOnlyBoss = value
			BSCTC:EnableAddon()
		end,
	})	
	table.insert(optionsTable, {
		type = "checkbox",
		name = "Show only when needed",
		tooltip = "The addon will show if you increasing the Taunt Count buff above 1 (max 5)",
		getFunc = function() return BSCTC.SV_ACC.bOnlyShowWhenNeed end,
		setFunc = function(value) 
			BSCTC.SV_ACC.bOnlyShowWhenNeed = value
			BSCTC:EnableAddon()
		end,
	})		
	table.insert( optionsTable, { 
		type = "dropdown", 
		name = "Sount for Increase Spot count 2", 
		choices = s_choices,
		getFunc = function()
			for i = 1, #s_sounds do
				if s_sounds[i] == BSCTC.SV_ACC.S_SOUND_2 then return s_choices[i] end
			end
			return "No_Sound"
		end,
		setFunc = function(value)
			for i = 1, #s_choices do
				if s_choices[i] == value then
					BSCTC.SV_ACC.S_SOUND_2 = s_sounds[i]
					BSCTC:PlaySound(2, BSCTC.SV_ACC.S_SOUND_2)
					return
				end
			end
		end,
		scrollable = 12,
		default = "No_Sound",
	})	
	table.insert( optionsTable, { 
		type = "dropdown", 
		name = "Sount for Increase Spot count 3", 
		choices = s_choices,
		getFunc = function()
			for i = 1, #s_sounds do
				if s_sounds[i] == BSCTC.SV_ACC.S_SOUND_3 then return s_choices[i] end
			end
			return "No_Sound"
		end,
		setFunc = function(value)
			for i = 1, #s_choices do
				if s_choices[i] == value then
					BSCTC.SV_ACC.S_SOUND_3 = s_sounds[i]
					BSCTC:PlaySound(3, BSCTC.SV_ACC.S_SOUND_3)
					return
				end
			end
		end,
		scrollable = 12,
		default = "No_Sound",
	})	
	table.insert( optionsTable, { 
		type = "dropdown", 
		name = "Sount for Increase Spot count 4", 
		choices = s_choices,
		getFunc = function()
			for i = 1, #s_sounds do
				if s_sounds[i] == BSCTC.SV_ACC.S_SOUND_4 then return s_choices[i] end
			end
			return "No_Sound"
		end,
		setFunc = function(value)
			for i = 1, #s_choices do
				if s_choices[i] == value then
					BSCTC.SV_ACC.S_SOUND_4 = s_sounds[i]
					BSCTC:PlaySound(4, BSCTC.SV_ACC.S_SOUND_4)
					return
				end
			end
		end,
		scrollable = 12,
		default = "No_Sound",
	})
	table.insert( optionsTable, { 
		type = "dropdown", 
		name = "Sount for Increase Spot count 5", 
		choices = s_choices,
		getFunc = function()
			for i = 1, #s_sounds do
				if s_sounds[i] == BSCTC.SV_ACC.S_SOUND_5 then return s_choices[i] end
			end
			return "No_Sound"
		end,
		setFunc = function(value)
			for i = 1, #s_choices do
				if s_choices[i] == value then
					BSCTC.SV_ACC.S_SOUND_5 = s_sounds[i]
					BSCTC:PlaySound(5, BSCTC.SV_ACC.S_SOUND_5)
					return
				end
			end
		end,
		scrollable = 12,
		default = "No_Sound",
	})	
	AddDivider(optionsTable)
	table.insert(optionsTable, {
		type = "slider",
		name = "UI Set Alpha Value",
		tooltip = "",
		min = 0.1,
		max = 1,
		step = 0.1,
		default = 1,	
		getFunc = function() return BSCTC.SV_ACC.UI_ALPHA end,
		setFunc = function(value)
			BSCTC.SV_ACC.UI_ALPHA = value
			BSCTC:SetPosition()
		end,
	})
	
end
--
function BSCTC:InitMenu()
	-- the panel for the addons menu
	local panelData = {
		type = "panel",
		name = BSCTC.Name,
		displayName = BSCTC.Name,
		author = BSCTC.Author,
		version = BSCTC.VersionDisplay,
		registerForRefresh = true,
	}	
	
	for k, v in pairs(BSCTC.SOUNDLIST) do
	--for k, v in pairs(SOUNDS) do	
		table.insert(s_choices, v)
		table.insert(s_sounds, k)
	end
	
	AddSendFeedBack()
	AddSettings()		
    local addonpanel = LibAddonMenu2:RegisterAddonPanel(BSCTC.Name, panelData)
    LibAddonMenu2:RegisterOptionControls(BSCTC.Name, optionsTable)

	CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", function(currentpanel) if addonpanel == currentpanel then BSCTauntCounterUI:SetHidden(false) end end )
	CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", function(currentpanel) if addonpanel == currentpanel then BSCTauntCounterUI:SetHidden(true) end end )
end