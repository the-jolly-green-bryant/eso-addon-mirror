local addon = NEAR_SB

local function cmdMessageTypeExample()
	local sv = NEAR_SB.ASV

	local str = "Example message"

	if sv.cmdMessageType == 1 then
		addon.AddMessage(str)
	elseif sv.cmdMessageType == 2 then
		ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.GENERAL_ALERT_ERROR, str)
	end
end

local function GetCustomAbilityName(id)
    local string = _G["NEARSB_abilityName_" .. id]
    return GetString(string)
end

local function FormatAbilityName(id)
	if addon.hasCustomName[id] then
		return GetCustomAbilityName(id)
	else
		return zo_strformat("<<C:1>>", GetAbilityName(id))
	end
end

local function FormatSkilLineName(id)
	return zo_strformat("<<C:1>>", GetSkillLineNameById(id))
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Addon settings panel
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
function NEAR_SB.SetupSettings()
	local LAM2 = LibAddonMenu2
	local sv = NEAR_SB.ASV

	local libSkillBlockUpdateNeeded = false

	local choice = ''
	local choice_class = 'dk'
	local class_name = NEAR_SB.classdata.name

	local function UpdateVars()
		libSkillBlockUpdateNeeded = true
	end

	local control_options = {}

	local function createDropdown(skillLine, sv_skillLine)
		local dropdown = {
			type = 'dropdown',
			name = FormatSkilLineName(skillLine.id),
			choices = {},
			choicesValues = {},
			getFunc = function() return choice end,
			setFunc = function(v) choice = v end,
			scrollable = 21,
		}

		for ability in ipairs(skillLine) do
			if type(ability) == 'number' then
				for morph = 0, 2 do
					table.insert(dropdown.choices, FormatAbilityName(skillLine[ability][morph].id) )
					table.insert(dropdown.choicesValues, sv_skillLine[ability][morph])
				end
			end
		end

		return dropdown
	end

	local classes = {
		{ class = 'dk', "Flame",    "Draconic", "Earth" },
		{ class = 'sc', "Dark",     "Daedric",  "Storm" },
		{ class = 'nb', "Assassin", "Shadow",   "Siphon" },
		{ class = 'wa', "Animal",   "Green",    "Winter" },
		{ class = 'nm', "Grave",    "Bone",     "Living" },
		{ class = 'tp', "Spear",    "Dawn",     "Resto" },
		{ class = 'ar', "Herald",   "Soldier",  "Curative" }
	}

	for _, skillLine in ipairs(classes) do
		control_options[skillLine.class] = {}
		for i = 1, 3 do
			control_options[skillLine.class][i] = createDropdown(addon.skilldata['class'][(skillLine[i])],
				addon.ASV.skilldata["class"][(skillLine[i])])
		end
	end

	for _, skillType in ipairs({ 'weapon', 'armor', 'world', 'guild', 'ava' }) do
		control_options[skillType] = {}
		local i = 0
		local sortedSkillLineIndices = {} -- Create a table to store the sorted indices

		for skillLineIndex, _ in pairs(addon.skilldata[skillType]) do
			table.insert(sortedSkillLineIndices, skillLineIndex)
		end

		table.sort(sortedSkillLineIndices) -- Sort the indices

		for _, skillLineIndex in ipairs(sortedSkillLineIndices) do
			i = i + 1
			control_options[skillType][i] = createDropdown(addon.skilldata[skillType][skillLineIndex],
				addon.ASV.skilldata[skillType][skillLineIndex])
		end
	end

	local additional_control_options = {
		b_cast = {
			type = 'checkbox',
			name = GetString(NEARSB_LAM_co_bcast_name),
			tooltip = GetString(NEARSB_LAM_co_bcast_tooltip),
			getFunc = function() return (choice).block end,
			setFunc = function(v)
				(choice).block, (choice).msg.re_cast = v, true
				UpdateVars()
			end,
			disabled = function()
				if not (choice == '') then
					return false
				else
					return true
				end
			end
		},
		b_recast = {
			type = 'checkbox',
			name = GetString(NEARSB_LAM_co_brecast_name),
			tooltip = GetString(NEARSB_LAM_co_brecast_tooltip),
			warning = GetString(NEARSB_LAM_co_brecast_warning),
			getFunc = function() return (choice).block_recast end,
			setFunc = function(v)
				(choice).block_recast, (choice).msg.re_cast = v, true
				UpdateVars()
			end,
			disabled = function()
				if not (choice == '') then
					return false
				else
					return true
				end
			end
		},
		b_notInCombat = {
			type = 'checkbox',
			name = GetString(NEARSB_LAM_co_bnotInCombat_name),
			tooltip = GetString(NEARSB_LAM_co_bnotInCombat_tooltip),
			getFunc = function() return (choice).block_notInCombat end,
			setFunc = function(v)
				(choice).block_notInCombat, (choice).msg.re_cast = v, true
				if (choice).block_inCombat == true then (choice).block_inCombat = false end
				UpdateVars()
			end,
			disabled = function()
				if not (choice == '') then
					return false
				else
					return true
				end
			end
		},
		b_inCombat = {
			type = 'checkbox',
			name = GetString(NEARSB_LAM_co_binCombat_name),
			tooltip = GetString(NEARSB_LAM_co_binCombat_tooltip),
			getFunc = function() return (choice).block_inCombat end,
			setFunc = function(v)
				(choice).block_inCombat, (choice).msg.re_cast = v, true
				if (choice).block_notInCombat == true then (choice).block_notInCombat = false end
				UpdateVars()
			end,
			disabled = function()
				if not (choice == '') then
					return false
				else
					return true
				end
			end
		},
		b_isBracing = {
			type = 'checkbox',
			name = GetString(NEARSB_LAM_co_bisBracing_name),
			tooltip = GetString(NEARSB_LAM_co_bisBracing_tooltip),
			getFunc = function() return (choice).block_isBracing end,
			setFunc = function(v)
				(choice).block_isBracing, (choice).msg.re_cast = v, true
				UpdateVars()
			end,
			disabled = function()
				if not (choice == '') then
					return false
				else
					return true
				end
			end
		},
		b_pvp = {
			type = 'checkbox',
			name = GetString(NEARSB_LAM_co_bpvp_name),
			tooltip = GetString(NEARSB_LAM_co_bpvp_tooltip),
			getFunc = function() return (choice).pvp end,
			setFunc = function(v)
				(choice).pvp, (choice).msg.pvp = v, true
				UpdateVars()
			end,
			disabled = function()
				if not (choice == '') then
					return false
				else
					return true
				end
			end
		},

		b_onMaxCrux = {
			type = 'checkbox',
			name = GetString(NEARSB_LAM_co_bonMaxCrux_name),
			tooltip = GetString(NEARSB_LAM_co_bonMaxCrux_tooltip),
			getFunc = function() return (choice).block_onMaxCrux end,
			setFunc = function(v)
				(choice).block_onMaxCrux, (choice).msg.re_cast = v, true
				if (choice).block_onNotMaxCrux == true then (choice).block_onNotMaxCrux = false end
				UpdateVars()
			end,
			disabled = function()
				if not (choice == '') and choice_class == 'ar' and (choice).block_onMaxCrux ~= nil then
					return false
				else
					return true
				end
			end
		},
		b_onNotMaxCrux = {
			type = 'checkbox',
			name = GetString(NEARSB_LAM_co_bonNotMaxCrux_name),
			tooltip = GetString(NEARSB_LAM_co_bonNotMaxCrux_tooltip),
			getFunc = function() return (choice).block_onNotMaxCrux end,
			setFunc = function(v)
				(choice).block_onNotMaxCrux, (choice).msg.re_cast = v, true
				if (choice).block_onMaxCrux == true then (choice).block_onMaxCrux = false end
				UpdateVars()
			end,
			disabled = function()
				if not (choice == '') and choice_class == 'ar' and (choice).block_onNotMaxCrux ~= nil then
					return false
				else
					return true
				end
			end
		},

		b_onStacksEqual = {
			type = 'checkbox',
			name = GetString(NEARSB_LAM_co_bonStacksEqual_name),
			tooltip = GetString(NEARSB_LAM_co_bonStacksEqual_tooltip),
			getFunc = function() return (choice).block_onStacksEqual end,
			setFunc = function(v)
				(choice).block_onStacksEqual, (choice).msg.re_cast = v, true
				UpdateVars()
			end,
			disabled = function()
				if not (choice == '') and (choice).block_onStacksEqual ~= nil then
					return false
				else
					return true
				end
			end
		},

		s_onStacksEqual = {
			type = 'slider',
			name = GetString(NEARSB_LAM_co_sonStacksEqual_name),
			getFunc = function() return (choice).stacks end,
			setFunc = function(v) (choice).stacks = v end,
			min = 1,
			max = 4,
			disabled = function()
				if not (choice == '') and (choice).block_onStacksEqual ~= nil then
					return false
				else
					return true
				end
			end
		},
	}

	-- Merge the existing control_options and the additional_control_options
	for key, value in pairs(additional_control_options) do
		control_options[key] = value
	end


	local panelData = {
		type = 'panel',
		name = addon.title,
		displayName = addon.title,
		author = addon.author,
		version = addon.version,
		slashCommand = '/skillblocker',
		registerForRefresh = true,
		registerForDefaults = true,
	}

	-- Check if the pannel of this addon closes and register/unregister the needed skill blocks with LibSkillBocker "once"
	NEAR_SB.LAM2SettingsPanel = LAM2:RegisterAddonPanel(addon.name, panelData)
	local function OnLamPanelClosed(panel)
		if panel ~= NEAR_SB.LAM2SettingsPanel or not libSkillBlockUpdateNeeded then return end
		libSkillBlockUpdateNeeded = false
		addon.Initialize()
	end

	local optionsTable = {
		{
			type = 'checkbox',
			name = GetString(NEARSB_LAM_supb_name),
			tooltip = GetString(NEARSB_LAM_supb_tooltip),
			getFunc = function() return sv.suppressBlock end,
			setFunc = function(v) sv.suppressBlock = v end,
			default = addon.defaults.suppressBlock,
		},
		{
			type = 'checkbox',
			name = GetString(NEARSB_LAM_supbr_name),
			tooltip = GetString(NEARSB_LAM_supbr_tooltip),
			getFunc = function() return sv.suppressBlockReset end,
			setFunc = function(v) sv.suppressBlockReset = v end,
			default = addon.defaults.suppressBlockReset,
		},
		{
			type = 'checkbox',
			name = GetString(NEARSB_LAM_bpvp_name),
			tooltip = GetString(NEARSB_LAM_bpvp_tooltip),
			getFunc = function() return sv.blockPvP end,
			setFunc = function(v) sv.blockPvP = v end,
			default = addon.defaults.blockPvP,
		},
		{
			type = 'dropdown',
			name = GetString(NEARSB_LAM_cmdmsgt_name),
			tooltip = GetString(NEARSB_LAM_cmdmsgt_tooltip),
			choices = { GetString(NEARSB_LAM_cmdmsgt_choices1), GetString(NEARSB_LAM_cmdmsgt_choices2), GetString(NEARSB_LAM_cmdmsgt_choices3) },
			choicesValues = { 1, 2, 3 },
			getFunc = function() return sv.cmdMessageType end,
			setFunc = function(v)
				sv.cmdMessageType = v
				cmdMessageTypeExample()
			end,
			default = addon.defaults.cmdMessageType,
		},
		{
			type = 'checkbox',
			name = GetString(NEARSB_LAM_cmdmsgs_name),
			tooltip = GetString(NEARSB_LAM_cmdmsgs_tooltip),
			getFunc = function() return sv.cmdMessageSound end,
			setFunc = function(v) sv.cmdMessageSound = v end,
			default = addon.defaults.cmdMessageSound,
		},
		{
			type = 'checkbox',
			name = GetString(NEARSB_LAM_msg_name),
			getFunc = function() return sv.message end,
			setFunc = function(v) sv.message = v end,
			default = addon.defaults.message,
		},
		{
			type = 'checkbox',
			name = GetString(NEARSB_LAM_showE_name),
			tooltip = GetString(NEARSB_LAM_showE_tooltip),
			getFunc = function() return sv.showError end,
			setFunc = function(v)
				sv.showError = v
				libSkillBlockUpdateNeeded = true
			end,
			default = addon.defaults.showError,
		},
		{
			type = 'checkbox',
			name = GetString(NEARSB_LAM_abHideTimers_name),
			tooltip = GetString(NEARSB_LAM_abHideTimers_tooltip),
			getFunc = function() return sv.abilityBarHideTimers end,
			setFunc = function(v)
				sv.abilityBarHideTimers = v
				addon.AbilityBarTimers.Init()
			end,
			default = addon.defaults.abilityBarHideTimers,
		},
		{
			type = 'slider',
			name = GetString(NEARSB_LAM_recastThreshold_name),
			tooltip = GetString(NEARSB_LAM_recastThreshold_tooltip),
			getFunc = function() return sv.recastTimeRemainingThreshold end,
			setFunc = function(v) sv.recastTimeRemainingThreshold = v end,
			step = 0.1,
			decimals = 1,
			min = 0,
			max = 10,
		},
		---------------------------------------------------------------------------------
		{
			type = 'header',
			name = GetString(NEARSB_LAM_skillsel_name),
		},
		---------------------------------------------------------------------------------
		-- Class
		---------------------------------------------------------------------------------
		{
			type = 'submenu',
			name = GetString(SI_SKILLTYPE1),
			controls = {
				{
					type = 'dropdown',
					name = GetString(NEARSB_LAM_classsel_name),
					choices = { class_name[1], class_name[2], class_name[3], class_name[4], class_name[5], class_name[6], class_name[7] },
					choicesValues = { 'dk', 'sc', 'nb', 'wa', 'nm', 'tp', 'ar' },
					getFunc = function() return choice_class end,
					setFunc = function(v)
						choice_class = v

						NEARSB_LAM_DROPDOWN_CLASS1:UpdateChoices(control_options[choice_class][1].choices,
							control_options[choice_class][1].choicesValues)
						NEARSB_LAM_DROPDOWN_CLASS1.label:SetText(control_options[choice_class][1].name)

						NEARSB_LAM_DROPDOWN_CLASS2:UpdateChoices(control_options[choice_class][2].choices,
							control_options[choice_class][2].choicesValues)
						NEARSB_LAM_DROPDOWN_CLASS2.label:SetText(control_options[choice_class][2].name)

						NEARSB_LAM_DROPDOWN_CLASS3:UpdateChoices(control_options[choice_class][3].choices,
							control_options[choice_class][3].choicesValues)
						NEARSB_LAM_DROPDOWN_CLASS3.label:SetText(control_options[choice_class][3].name)
					end,
				},
				{
					type = 'dropdown',
					reference = 'NEARSB_LAM_DROPDOWN_CLASS1',
					name = control_options[choice_class][1].name,
					choices = control_options[choice_class][1].choices,
					choicesValues = control_options[choice_class][1].choicesValues,
					getFunc = function() return choice end,
					setFunc = function(v) choice = v end,
				},
				{
					type = 'dropdown',
					reference = 'NEARSB_LAM_DROPDOWN_CLASS2',
					name = control_options[choice_class][2].name,
					choices = control_options[choice_class][2].choices,
					choicesValues = control_options[choice_class][2].choicesValues,
					getFunc = function() return choice end,
					setFunc = function(v) choice = v end,
				},
				{
					type = 'dropdown',
					reference = 'NEARSB_LAM_DROPDOWN_CLASS3',
					name = control_options[choice_class][3].name,
					choices = control_options[choice_class][3].choices,
					choicesValues = control_options[choice_class][3].choicesValues,
					getFunc = function() return choice end,
					setFunc = function(v) choice = v end,
				},
				control_options.b_pvp,
				control_options.b_cast,
				control_options.b_recast,
				control_options.b_notInCombat,
				control_options.b_inCombat,
				control_options.b_isBracing,
				{
					type = 'divider',
					height = '5',
				},
				control_options.b_onMaxCrux,
				control_options.b_onNotMaxCrux,
				{
					type = 'divider',
					height = '5',
				},
				control_options.b_onStacksEqual,
				control_options.s_onStacksEqual,
			},
		},
		---------------------------------------------------------------------------------
		-- Weapon
		---------------------------------------------------------------------------------
		{
			type = 'submenu',
			name = GetString(SI_SKILLTYPE2),
			controls = {
				control_options.weapon[1],
				control_options.weapon[2],
				control_options.weapon[3],
				control_options.weapon[4],
				control_options.weapon[5],
				control_options.weapon[6],
				control_options.b_pvp,
				control_options.b_cast,
				control_options.b_recast,
				control_options.b_notInCombat,
				control_options.b_inCombat,
				control_options.b_isBracing,
			},
		},
		---------------------------------------------------------------------------------
		-- Armor
		---------------------------------------------------------------------------------
		{
			type = 'submenu',
			name = GetString(SI_SKILLTYPE3),
			controls = {
				control_options.armor[1],
				control_options.armor[2],
				control_options.armor[3],
				control_options.b_pvp,
				control_options.b_cast,
				control_options.b_recast,
				control_options.b_notInCombat,
				control_options.b_inCombat,
				control_options.b_isBracing,
			},
		},
		---------------------------------------------------------------------------------
		-- World
		---------------------------------------------------------------------------------
		{
			type = 'submenu',
			name = GetString(SI_SKILLTYPE4),
			controls = {
				control_options.world[1],
				control_options.world[2],
				control_options.world[3],
				control_options.b_pvp,
				control_options.b_cast,
				control_options.b_recast,
				control_options.b_notInCombat,
				control_options.b_inCombat,
				control_options.b_isBracing,
			},
		},
		---------------------------------------------------------------------------------
		-- Guild
		---------------------------------------------------------------------------------
		{
			type = 'submenu',
			name = GetString(SI_SKILLTYPE5),
			controls = {
				control_options.guild[1],
				control_options.guild[2],
				control_options.guild[3],
				control_options.guild[4],
				control_options.b_pvp,
				control_options.b_cast,
				control_options.b_recast,
				control_options.b_notInCombat,
				control_options.b_inCombat,
				control_options.b_isBracing,
			},
		},
		---------------------------------------------------------------------------------
		-- AvA
		---------------------------------------------------------------------------------
		{
			type = 'submenu',
			name = GetString(SI_SKILLTYPE6),
			controls = {
				control_options.ava[1],
				control_options.ava[2],
				control_options.b_pvp,
				control_options.b_cast,
				control_options.b_recast,
				control_options.b_notInCombat,
				control_options.b_inCombat,
				control_options.b_isBracing,
			},
		},
		---------------------------------------------------------------------------------
		{
			type = 'divider',
			width = 'full',
		},
		{
			type = 'submenu',
			name = GetString(NEARSB_LAM_reglist_name),
			controls = {
				{
					type = 'description',
					text = function() return NEAR_SB.registeredAbilityNames end,
				},
			},
		},
		{
			type = 'divider',
			width = 'full',
		},
		{
			type = 'description',
			text = GetString(NEARSB_LAM_cmd_text),
		},
	}
	LAM2:RegisterOptionControls(addon.name, optionsTable)

	CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", OnLamPanelClosed)
end
