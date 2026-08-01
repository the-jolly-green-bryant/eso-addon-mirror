BSCAllianceRanking = BSCAllianceRanking or {}
local BSCARI = BSCAllianceRanking

local optionsTable = {}

local function AddSendFeedBack()
    table.insert(optionsTable, {
        type = "button",
        name = "Donate",
        tooltip = "Main - EU Server",
        func = function()
              local function PrefillMail()
                ZO_MailSendToField:SetText(BSCARI.Author)
                ZO_MailSendSubjectField:SetText(BSCARI.NameSpaced)
                ZO_MailSendBodyField:TakeFocus()
              end
                SCENE_MANAGER:Show('mailSend')
                zo_callLater(PrefillMail, 250)
        end,
        width = "half",
        warning = "",	
    })
end

local function AddTexture(control, Iwidth, strIcon, strDesciption)
	table.insert(control, {
        type = "texture",
        image =  strIcon,
		tooltip = strDesciption,
        imageWidth = 32,
        imageHeight = 32,
        width = Iwidth,
	})
end

local function AddDivider(control)
	table.insert(control, {
		type = "divider",
	})
end

local function AddChar()
	for Index = 1, GetNumCharacters() do	
		local c_name, _, _, _, _, alliance, id, _ = GetCharacterInfo(Index)		
		for CurrentCharID, v in pairs(BSCARI.SVA.SETTING) do
			if BSCARI.CurrentCharID == id and CurrentCharID == id then
				local m_name = GetAllianceColor(alliance):Colorize(zo_strformat("<<1>>", c_name))
				table.insert(optionsTable, {
					type = "checkbox",
					name = "AP Tier Alert ["..m_name.."]",
					getFunc = function() return BSCARI.SVA.SETTING[CurrentCharID].bAlert end,
					setFunc = function(value) 
						BSCARI.SVA.SETTING[CurrentCharID].bAlert = value 
						if BSCARI.CurrentCharID == id then
							ZO_CheckButton_SetCheckState(BSCARI.CboxControl, value)
						end
					end,
					--reference = "BSCARI_CB_ATA",
				})		
				table.insert(optionsTable, {
					type = "checkbox",
					name = "AP Buff Reminder ["..m_name.."]",
					getFunc = function() return BSCARI.SVA.SETTING[CurrentCharID].bAlertBuff end,
					setFunc = function(value) 
						BSCARI.SVA.SETTING[CurrentCharID].bAlertBuff = value 	
					end,
					reference = "BSCARI_CB_ABR",
				})						
				table.insert(optionsTable, {
					type = "checkbox",
					name = "Show BUFF UI ["..m_name.."]",
					getFunc = function() return BSCARI.SVA.SETTING[CurrentCharID].bEnableUI end,
					setFunc = function(value) 
						BSCARI.SVA.SETTING[CurrentCharID].bEnableUI = value
					end,
					--reference = "BSCARI_CB_SUI",
				})
				table.insert(optionsTable, {
					type = "checkbox",
					name = "Show Total AP Bar UI ["..m_name.."]",
					getFunc = function() 
							local value = BSCARI.SVA.SETTING[CurrentCharID].ARO_H
							if value == nil then
								return true
							end
							return value
						end,
					setFunc = function(value) 
						BSCARI.SVA.SETTING[CurrentCharID].ARO_H = value
						BSCARI:UpdateUISettingsBAR()
					end,
					--reference = "BSCARI_CB_SUI",
				})				
				table.insert(optionsTable, {
					type = "checkbox",
					name = "Show Next Level AP Bar UI ["..m_name.."]",
					getFunc = function() 
							local value = BSCARI.SVA.SETTING[CurrentCharID].CRO_H
							if value == nil then
								return true
							end
							return value
						end,
					setFunc = function(value) 
						BSCARI.SVA.SETTING[CurrentCharID].CRO_H = value
						BSCARI:UpdateUISettingsBAR()
					end,
					--reference = "BSCARI_CB_SUI",
				})
				table.insert(optionsTable, {
					type = "checkbox",
					name = "Show Tier AP Bar UI ["..m_name.."]",
					getFunc = function() 
							local value = BSCARI.SVA.SETTING[CurrentCharID].TRO_H
							if value == nil then
								return true
							end
							return value
						end,
					setFunc = function(value) 
						BSCARI.SVA.SETTING[CurrentCharID].TRO_H = value
						BSCARI:UpdateUISettingsBAR()
					end,
					--reference = "BSCARI_CB_SUI",
				})
				table.insert(optionsTable, {
					type = "checkbox",
					name = "Lock UI ["..m_name.."]",
					getFunc = function() return BSCARI.SVA.SETTING[CurrentCharID].LOCK_UI end,
					setFunc = function(value) 
						BSCARI.SVA.SETTING[CurrentCharID].LOCK_UI = value 	
						BSCAllianceRankingBuffInfoUI:SetMovable(not value)
						BSCARI:UpdateUISettingsBAR()
					end,
					--reference = "BSCARI_CB_LUI",
				})
				table.insert(optionsTable, {
					type = "checkbox",
					name = "Print AP gain to Chat ["..m_name.."]",
					getFunc = function() return BSCARI.SVA.SETTING[CurrentCharID].bAPInfoChat end,
					setFunc = function(value) 
						BSCARI.SVA.SETTING[CurrentCharID].bAPInfoChat = value 	
					end,
					--reference = "BSCARI_CB_PAC",
				})
				table.insert(optionsTable, {
					type = "checkbox",
					name = "Play Sound on Buff End ["..m_name.."]",
					getFunc = function() return BSCARI.SVA.SETTING[CurrentCharID].PLAY_SOUND end,
					setFunc = function(value) 
						BSCARI.SVA.SETTING[CurrentCharID].PLAY_SOUND = value 	
					end,
					--reference = "BSCARI_CB_PSB",
				})
				table.insert(optionsTable, {
					type = "checkbox",
					name = "Alert LowPoP/Score AP Bonus ["..m_name.."]",
					getFunc = function() return BSCARI.SVA.SETTING[CurrentCharID].bAlertLowPop end,
					setFunc = function(value) 
						BSCARI.SVA.SETTING[CurrentCharID].bAlertLowPop = value 	
					end,
					--reference = "BSCARI_CB_PSA",
				})
			else
				-- diff char
			end
		end
	end
end
local function AddBaseSetting()
	--
	table.insert(optionsTable, {
        type = "header",
        name = "Alert Settings",
    })	
end
function BSCARI:InitMenu()
	-- the panel for the addons menu
	local panelData = {
		type = "panel",
		name = BSCARI.NameMenu,
		displayName = BSCARI.NameSpaced,
		author = BSCARI.Author,
		version = BSCARI.VersionDisplay,
		registerForRefresh = true,
	}	
		
	AddSendFeedBack()
	AddBaseSetting()
	AddChar()
	
    local addonpanel = LibAddonMenu2:RegisterAddonPanel(BSCARI.NameSpaced, panelData)
    LibAddonMenu2:RegisterOptionControls(BSCARI.NameSpaced, optionsTable)
	
	CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", function(currentpanel) if addonpanel == currentpanel then BSCAllianceRankingBuffInfoUI:SetHidden(false) end end )
	CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", function(currentpanel) if addonpanel == currentpanel then BSCAllianceRankingBuffInfoUI:SetHidden(true) end end )
end