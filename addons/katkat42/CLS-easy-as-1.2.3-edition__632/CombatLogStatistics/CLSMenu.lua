--[[----------------------------------------------------------
	FCL Menu Settings
 ]]-----------------------------------------------------------
 function FCL.InitMenu()
	FCL.SettingsHidden = false

	local panelData = {
		type = "panel",
		name = "CLS",
		displayName = "Combat Log Statistics Settings",
		author = "Zeakfury",
		version = "2.2.1",
		registerForRefresh = true,
		registerForDefaults = true,
	}
	FCL.LAM:RegisterAddonPanel("CLS", panelData)

	local optionsTable = {
		[1] = {
			type = "header",
			name = "|cF0C300Display Options",
		},
		[2] = {
			type = "checkbox",
			name = "Hide Main Window",
			tooltip = "Toggle Show/Hide the Main Window",
			getFunc = function() return FCL.CText.HiddenM end,
			setFunc = function(val)
				FCL.CText.HiddenM = val
				_G["CombatLog"]:SetHidden(false)
				if FCL.CText.HiddenM == false then
					_G["CombatLog"]:SetHidden(false)
				else
					_G["CombatLog"]:SetHidden(true)
				end
			end,
		},
		[3] = {
			type = "checkbox",
			name = "Hide DPS Window",
			tooltip = "Toggle Show/Hide the DPS Window",
			getFunc = function() return FCL.CText.HiddenD end,
			setFunc = function(val)
				FCL.CText.HiddenD = val
				if FCL.CText.HiddenD == false then
					_G["DPS"]:SetHidden(false)
				else
					_G["DPS"]:SetHidden(true)
				end
			end,
		},
		[4] = {
			type = "dropdown",
			name = "Display Combat in Chat",
			tooltip = "Show/Hide Combat Log Data in Chat Window",
			choices = {"None", "First Tab", "Own Tab", "Both"},
			getFunc = function() return FCL.CText.Chat end,
			setFunc = function(val)
				local old = FCL.CText.Chat
				FCL.CText.Chat = val 
				FCL.InitChatTab()
				-- it's stupid that we have to reload the UI when adding or removing a tab from
				-- the chat box -- I use the exact same functions from the command line and they
				-- appeared just fine. But not when I'm in the settings menu. Weird.
				if ((old == "None" or old == "First Tab") and (val == "Own Tab" or val == "Both"))
					or ((old == "Own Tab" or old == "Both") and (val == "None" or val == "First Tab")) then
					ReloadUI()
				end
			end,
			warning = "Can Reload UI",
		},
		[5] = {
			type = "checkbox",
			name = "Display TimeStamp",
			tooltip = "Toggle the TimeStamp in the Combat Log",
			getFunc = function() return FCL.CText.Time end,
			setFunc = function(val) FCL.CText.Time = val end,
		},
		[6] = {
			type = "dropdown",
			name = "Text Direction",
			tooltip = "Which Direction the text pops up in Main Window",
			choices = {"UP", "DOWN"},
			getFunc = function() return FCL.CText.Direction end,
			setFunc = function(direction)
				if FCL.CText.Direction ~= direction then
					FCL.CText.Direction = direction
					ReloadUI()
				end
			end,
			warning = "Reloads UI",
		},
		[7] = {
			type = "slider",
			name = "Max Lines Shown",
			tooltip = "Maximum number of lines shown in the main window",
			min = 0,
			max = 30,
			step = 1,
			getFunc = function() return FCL.CText.MaxLines end,
			setFunc = function(value)
				FCL.CText.MaxLines = value
				ReloadUI()
			end,
			warning = "Reloads UI",
		},
		[8] = {
			type = "slider",
			name = "Max Saved Lines",
			tooltip = "Maximum number of lines saved for scrolling (0 = unlimited)",
			min = 0,
			max = 1000,
			step = 1,
			getFunc = function() return FCL.CText.MaxLinesSaved end,
			setFunc = function(value) FCL.CText.MaxLinesSaved = value end,
		},
		[9] = {
			type = "checkbox",
			name = "Fade CLS when not in Combat",
			tooltip = "Fade/Don't Fade CLS window when not in combat",
			getFunc = function() return FCL.CText.FadesWithChat end,
			setFunc = function(val) FCL.CText.FadesWithChat = val end,
		},
		[10] = {
			type = "slider",
			name = "Fade Timer",
			tooltip = "How much time to stay visible after combat ends",
			min = 1,
			max = 60,
			step = 1,
			getFunc = function() return FCL.CText.FadeTimer end,
			setFunc = function(value) FCL.CText.FadeTimer = value end,
		},
		[11] = {
			type = "checkbox",
			name = "User Buffer for DPS Update",
			tooltip = "Will Decrease Performance if Off",
			getFunc = function() return FCL.CText.Buffer end, 
			setFunc = function(val) FCL.CText.Buffer = val end,
		}, 
		[12] = {
			type = "slider",
			name = "Buffer Update",
			tooltip = "Sets how long the buffer to update DPS window should be Value*0.1",
			min = 1,
			max = 30,
			step = 1,
			getFunc = function() return FCL.CText.BufferSpeed*10 end,
			setFunc = function(value) FCL.CText.BufferSpeed = value*0.1 end,
		},

		[13] = {
			type = "header",
			name = "|cF0C300Cosmetics",
		},
		[14] = {
			type = "checkbox",
			name = "Colors Menu",
			tooltip = "Show/Hide The Colors Menu",
			getFunc = function() return FCL.SettingsHidden end, 
			setFunc = function(val) 
				FCL.SettingsHidden = val
				if (val == false) then
					_G["FCLSettings"]:SetHidden(true)
				else
					_G["FCLSettings"]:SetHidden(false)
					--d("False")
				end
			end,
		},
		[15] = {
			type = "slider",
			title = "Font Size",
			tooltip = "Move to Change Font Size",
			min = 10,
			max = 40,
			step = 1,
			getFunc = function() return FCL.CText.FontSize end,
			setFunc = function(value)
				FCL.CText.FontSize = value
				for i = 1, #FCL.textbox , 1 do 
					FCL.textbox[i]:SetFont(FCL.Font .. "|" .. FCL.CText.FontSize .. "|" .. FCL.FontStyle)
					FCL.textbox[i]:SetDimensions(1000, FCL.CText.FontSize+1)
					FCL.textbutton[i]:SetDimensions(20, FCL.CText.FontSize+1)
					FCL.textbutton[i]:SetFont(FCL.Font .. "|" .. FCL.CText.FontSize .. "|" .. FCL.FontStyle)
				end	
				DPS_LabelTex:SetFont(FCL.Font .. "|" .. FCL.CText.FontSize .. "|" .. FCL.FontStyle)
				DPS_LabelVal:SetFont(FCL.Font .. "|" .. FCL.CText.FontSize .. "|" .. FCL.FontStyle)
				_G["AbilityFrame_Label"]:SetFont(FCL.Font .. "|" .. FCL.CText.FontSize .. "|" .. FCL.FontStyle)
			end,
		},
		[16] = {
			type = "checkbox",
			name = "Toggle Name Colors",
			tooltip = "Toggle the colors of Names",
			getFunc = function() return FCL.CText.NameColor end, 
			setFunc = function(val) FCL.CText.NameColor = val end,
		},
		[17] = {
			type = "checkbox",
			name = "Toggle Ability Colors",
			tooltip = "Toggles the colors of Abilities",
			getFunc = function() return FCL.CText.AbilityColor end, 
			setFunc = function(val) FCL.CText.AbilityColor = val end,
		},
		[18] = {
			type = "checkbox",
			name = "Toggle Buff Colors",
			tooltip = "Toggles the colors of Buffs",
			getFunc = function() return FCL.CText.BuffColor end, 
			setFunc = function(val) FCL.CText.BuffColor = val end,
		},

		[19] = {
			type = "header",
			name = "|cF0C300Various Tracking",
		},
		[20] = {
			type = "checkbox",
			name = "Show Damage in Log",
			tooltip = "Toggles Damage in Combat Log",
			getFunc = function() return FCL.CText.ShowDamage end,
			setFunc = function(val) FCL.CText.ShowDamage = val end,
		},
		[21] = {
			type = "checkbox",
			name = "Show Healing in Log",
			tooltip = "Toggles Healing in Combat Log",
			getFunc = function() return FCL.CText.ShowHeals end,
			setFunc = function(val) FCL.CText.ShowHeals = val end,
		},
		[22] = {
			type = "checkbox",
			name = "Show Buffs/Debuffs in Log",
			tooltip = "Toggles Buff/Debuff in Combat Log",
			getFunc = function() return FCL.CText.Buffs end,
			setFunc = function(val) FCL.CText.Buffs = val end,
		},
		[23] = {
			type = "checkbox",
			name = "Show AP Gains",
			tooltip = "Toggles Alliance Points Gains in Combat Log",
			getFunc = function() return FCL.CText.AP end,
			setFunc = function(val) FCL.CText.AP = val end,
		},
		[24] = {
			type = "checkbox",
			name = "Show Mag/Stam/Ult Gains",
			tooltip = "Toggles Stamina/Magicka/Ultimate Gains in Combat Log",
			getFunc = function() return FCL.CText.ShowPower end,
			setFunc = function(val) FCL.CText.ShowPower = val end,
		},
	}

	--------Skills----------
	for Category, Ntable in pairs(FCL.SkillXPNames) do
		for k, v in pairs(Ntable) do
			if (FCL.SkillXPNames[Category][k]) and (FCL.SkillXPNames[Category][k] ~= "") then
				local skill = {
					type = "checkbox",
					name = "Show |cc8ff3a" .. FCL.SkillXPNames[Category][k] .. "|r Skill Gains",
					tooltip = "Toggles " .. FCL.SkillXPNames[Category][k] .. " in Combat Log",
					getFunc = function() return FCL.CText.Skills[Category][k] end,
					setFunc = function(val) FCL.CText.Skills[Category][k] = val end,
				}
				table.insert(optionsTable, skill)
			else
				FCL.CText.Skills[Category][k] = false
			end
		end
	end 
	FCL.LAM:RegisterOptionControls("CLS", optionsTable)
 end
