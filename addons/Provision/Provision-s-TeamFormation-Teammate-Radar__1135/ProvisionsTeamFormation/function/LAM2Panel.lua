local function colorizePseudo(rgb, pseudo)
	local color = ZO_ColorDef:New(unpack(rgb))
	return "|c" .. color:ToHex() .. "|t24:24:EsoUI/Art/Miscellaneous/Gamepad/gp_charNameIcon.dds:inheritcolor|t " .. pseudo
end

local function TeamFormation_mapChoices(func, array)
	local new_array = {}

	if not array then return array end

	for k, v in pairs(array) do
		table.insert(new_array, func(v, k))
	end

	return new_array
end

local function TeamFormation_mapJRULES()
	return TeamFormation_mapChoices(colorizePseudo, ProvTF.vars.jRules)
end

local function TeamFormation_reset()
	ProvTF.vars = {}
	ProvTF.vars.enabled = ProvTF.defaults.enabled

	ProvTF.vars.posx = ProvTF.defaults.posx
	ProvTF.vars.posy = ProvTF.defaults.posy
	ProvTF.vars.width = ProvTF.defaults.width
	ProvTF.vars.height = ProvTF.defaults.height

	ProvTF.vars.refreshRate = ProvTF.defaults.refreshRate

	ProvTF.vars.circle = ProvTF.defaults.circle
	ProvTF.vars.camRotation = ProvTF.defaults.camRotation

	ProvTF.vars.scale = ProvTF.defaults.scale
	ProvTF.vars.logdist = ProvTF.defaults.logdist
	ProvTF.vars.cardinal = ProvTF.defaults.cardinal

	ProvTF.vars.siege = ProvTF.defaults.siege

	ProvTF.vars.myAlpha = ProvTF.defaults.myAlpha
	ProvTF.vars.roleIcon = ProvTF.defaults.roleIcon
	
	-- Don't pass default's jRules reference.
	ProvTF.vars.jRules = {}
	
	ProvTF.UI:SetAnchor(CENTER, GuiRoot, CENTER, ProvTF.vars.posx, ProvTF.vars.posy)
	TeamFormation_SetHidden(not ProvTF.vars.enabled)
	TeamFormation_ResetRefreshRate()
end

function TeamFormation_createLAM2Panel()
	local panelData =
	{
		type = "panel",
		name = ProvTF.namePublic,
		displayName = ProvTF.nameColor,
		author = ProvTF.author,
		version = ProvTF.version,
		slashCommand = "/tf",
		registerForRefresh = true,
		registerForDefaults = true,
		resetFunc = TeamFormation_reset,
	}

	local optionsData =
	{
		{
			type = "description",
			text = GetString(SI_TF_DESC_TEAMFORMATION),
		},
		{
			type = "checkbox",
			name = GetString(SI_TF_SETTING_ENABLED),
			tooltip = GetString(SI_TF_SETTING_ENABLED_TOOLTIP),
			getFunc = function() return ProvTF.vars.enabled end,
			setFunc = function(value)
				ProvTF.vars.enabled = value
				TeamFormation_SetHidden(not ProvTF.vars.enabled)
			end,
			width = "full",
		},
		{
			type = "description",
			text = GetString(SI_TF_SETTING_SHOWNOW_TOOLTIP),
			width = "half",
		},
		{
			type = "button",
			name = GetString(SI_TF_SETTING_SHOWNOW),
			tooltip = GetString(SI_TF_SETTING_SHOWNOW_TOOLTIP),
			func = function()
				if ProvTF.vars.enabled then
					TeamFormation_SetHidden(false)
				end
			end,
			width = "half"
		},
		{
			type = "submenu",
			name = GetString(SI_TF_SETTING_SIZEOPTIONS),
			controls =
			{
				[1] = {
					type = "description",
					text = GetString(SI_TF_SETTING_SIZEOPTIONS_TOOLTIP),
				},
				[2] = {
					type = "slider",
					name = GetString(SI_TF_SETTING_X),
					tooltip = GetString(SI_TF_SETTING_X_TOOLTIP),
					min = -zo_round(GuiRoot:GetWidth() / 2), max = zo_round(GuiRoot:GetWidth() / 2), step = 1,
					getFunc = function() return ProvTF.vars.posx end,
					setFunc = function(value)
						ProvTF.vars.posx = value
						ProvTF.UI:SetAnchor(CENTER, GuiRoot, CENTER, ProvTF.vars.posx, ProvTF.vars.posy)
					end,
					width = "half",
				},
				[3] = {
					type = "slider",
					name = GetString(SI_TF_SETTING_Y),
					tooltip = GetString(SI_TF_SETTING_Y_TOOLTIP),
					min = -zo_round(GuiRoot:GetHeight() / 2), max = zo_round(GuiRoot:GetHeight() / 2), step = 1,
					getFunc = function() return ProvTF.vars.posy end,
					setFunc = function(value)
						ProvTF.vars.posy = value
						ProvTF.UI:SetAnchor(CENTER, GuiRoot, CENTER, ProvTF.vars.posx, ProvTF.vars.posy)
					end,
					width = "half",
				},
				[4] = {
					type = "slider",
					name = GetString(SI_TF_SETTING_WIDTH),
					tooltip = GetString(SI_TF_SETTING_WIDTH_TOOLTIP),
					min = 20, max = zo_round(GuiRoot:GetWidth()), step = 1,
					getFunc = function() return ProvTF.vars.width end,
					setFunc = function(value)
						ProvTF.vars.width = value
						ProvTF.UI:SetDimensions(ProvTF.vars.width, ProvTF.vars.height)
					end,
					width = "half",
				},
				[5] = {
					type = "slider",
					name = GetString(SI_TF_SETTING_HEIGHT),
					tooltip = GetString(SI_TF_SETTING_HEIGHT_TOOLTIP),
					min = 20, max = zo_round(GuiRoot:GetHeight()), step = 1,
					getFunc = function() return ProvTF.vars.height end,
					setFunc = function(value)
						ProvTF.vars.height = value
						ProvTF.UI:SetDimensions(ProvTF.vars.width, ProvTF.vars.height)
					end,
					width = "half",
				}
			},
		},
		{
			type = "submenu",
			name = GetString(SI_TF_SETTING_FOCUSOPTIONS),
			controls =
			{
				[1] = {
					type = "description",
					text = GetString(SI_TF_SETTING_FOCUSOPTIONS_TOOLTIP),
				},
				[2] = {
					type = "slider",
					name = GetString(SI_TF_SETTING_REFRESHRATE),
					tooltip = GetString(SI_TF_SETTING_REFRESHRATE_TOOLTIP),
					warning = GetString(SI_TF_SETTING_REFRESHRATE_WARNING),
					min = 10, max = 100, step = 1,
					getFunc = function() return ProvTF.vars.refreshRate end,
					setFunc = function(value)
						ProvTF.vars.refreshRate = value

						TeamFormation_ResetRefreshRate()
					end,
					width = "full",
				},
				[3] = {
					type = "dropdown",
					name = GetString(SI_TF_SETTING_SHAPE),
					tooltip = GetString(SI_TF_SETTING_SHAPE_TOOLTIP),
					choices = { GetString(SI_TF_SETTING_SHAPE_RECTANGULAR), GetString(SI_TF_SETTING_SHAPE_CIRCULAR) },
					getFunc = function()
						return (ProvTF.vars.circle and GetString(SI_TF_SETTING_SHAPE_CIRCULAR) or GetString(SI_TF_SETTING_SHAPE_RECTANGULAR))
					end,
					setFunc = function(var)
						ProvTF.vars.circle = (var == GetString(SI_TF_SETTING_SHAPE_CIRCULAR))
					end,
				},
				[4] =
				{
					type = "checkbox",
					name = GetString(SI_TF_SETTING_CAMROTATION),
					tooltip = GetString(SI_TF_SETTING_CAMROTATION_TOOLTIP),
					getFunc = function() return ProvTF.vars.camRotation end,
					setFunc = function(value)
						ProvTF.vars.camRotation = value
					end,
					width = "full",
				},
				[5] = {
					type = "slider",
					name = GetString(SI_TF_SETTING_SCALE),
					tooltip = GetString(SI_TF_SETTING_SCALE_TOOLTIP),
					min = 10, max = 200, step = 1,
					getFunc = function() return ProvTF.vars.scale end,
					setFunc = function(value)
						ProvTF.vars.scale = value
					end,
					width = "full",
				},
				[6] = {
					type = "slider",
					name = GetString(SI_TF_SETTING_LOGDIST) .. " (%)",
					tooltip = GetString(SI_TF_SETTING_LOGDIST_TOOLTIP),
					min = 0, max = 100, step = 1,
					getFunc = function() return ProvTF.vars.logdist * 100 end,
					setFunc = function(value)
						ProvTF.vars.logdist = value / 100
					end,
					width = "full",
				},
				[7] = {
					type = "slider",
					name = GetString(SI_TF_SETTING_CARDINAL) .. " (%)",
					tooltip = GetString(SI_TF_SETTING_CARDINAL_TOOLTIP),
					min = 0, max = 100, step = 1,
					getFunc = function() return ProvTF.vars.cardinal * 100 end,
					setFunc = function(value)
						ProvTF.vars.cardinal = value / 100
					end,
					width = "full",
				},
				[8] =
				{
					type = "checkbox",
					name = GetString(SI_TF_SETTING_SIEGE),
					tooltip = GetString(SI_TF_SETTING_SIEGE_TOOLTIP),
					getFunc = function() return ProvTF.vars.siege end,
					setFunc = function(value)
						ProvTF.vars.siege = value
					end,
					width = "full",
				},
			},
		},
		{
			type = "submenu",
			name = GetString(SI_TF_SETTING_PLAYERICON),
			controls =
			{
				[1] = {
					type = "description",
					text = GetString(SI_TF_SETTING_PLAYERICON_TOOLTIP),
				},
				[2] = {
					type = "slider",
					name = GetString(SI_TF_SETTING_YOURALPHA) .. " (%)",
					tooltip = GetString(SI_TF_SETTING_YOURALPHA_TOOLTIP),
					min = 0, max = 100, step = 1,
					getFunc = function() return ProvTF.vars.myAlpha * 100 end,
					setFunc = function(value)
						ProvTF.vars.myAlpha = value / 100
					end,
					width = "full",
				},
				[3] = {
					type = "checkbox",
					name = GetString(SI_TF_SETTING_ROLE),
					tooltip = GetString(SI_TF_SETTING_ROLE_TOOLTIP),
					getFunc = function() return ProvTF.vars.roleIcon end,
					setFunc = function(value)
						ProvTF.vars.roleIcon = value
					end,
					width = "full",
				},
			},
		},
		{
			type = "description",
			text = GetString(SI_TF_SETTING_HRADDON),
		},
		{
			type = "submenu",
			name = GetString(SI_TF_SETTING_COLOROPTIONS),
			controls =
			{
				[1] = {
					type = "description",
					text = GetString(SI_TF_SETTING_COLOROPTIONS_TOOLTIP),
				},
				[2] = {
					type = "description",
					text = GetString(SI_TF_SETTING_COLORRESET_TOOLTIP),
					width = "half",
				},
				[3] = {
					type = "button",
					name = GetString(SI_TF_SETTING_COLORRESET),
					tooltip = GetString(SI_TF_SETTING_COLORRESET_TOOLTIP),
					func = function()
						ProvTF.vars.jRules = {}
						WINDOW_MANAGER:GetControlByName("ProvTF#jRulesList"):UpdateChoices({})
					end,
					width = "half"
				},
				[4] = {
					type = "header",
					name = GetString(SI_TF_SETTING_JRULES),
					width = "full",
				},
				[5] = {
					type = "editbox",
					name = GetString(SI_TF_SETTING_JRULES_PSEUDOADD), -- or string id or function returning a string
					tooltip = GetString(SI_TF_SETTING_JRULES_PSEUDOADD_TOOLTIP),
					getFunc = function()
						return WINDOW_MANAGER:GetControlByName("ProvTF#jRulesBox").editbox:GetText()
					end,
					setFunc = function(pseudo)
						if not ProvTF.vars.jRules then ProvTF.vars.jRules = {} end
						if pseudo == "" then return end

						ProvTF.vars.jRules[pseudo] = {1, 1, 1}

						WINDOW_MANAGER:GetControlByName("ProvTF#jRulesBox").editbox:SetText("")

						local ctrl_dropdown = WINDOW_MANAGER:GetControlByName("ProvTF#jRulesList")
						ctrl_dropdown:UpdateChoices(TeamFormation_mapJRULES())
						ctrl_dropdown.dropdown:SetSelectedItem(colorizePseudo({1, 1, 1}, pseudo))
					end,
					isMultiline = false,
					isExtraWide = false,
					width = "full",
					reference = "ProvTF#jRulesBox",
				},
				[6] = {
					type = "button",
					name = GetString(SI_TF_SETTING_JRULES_ADD),
					tooltip = GetString(SI_TF_SETTING_JRULES_PSEUDOADD_TOOLTIP),
					func = function()
						local editbox = WINDOW_MANAGER:GetControlByName("ProvTF#jRulesBox").editbox
						local pseudo = editbox:GetText()
						if pseudo ~= "" then
							ProvTF.vars.jRules[pseudo] = {1, 1, 1}

							editbox:SetText("")

							local ctrl_dropdown = WINDOW_MANAGER:GetControlByName("ProvTF#jRulesList")
							ctrl_dropdown:UpdateChoices(TeamFormation_mapJRULES())
							ctrl_dropdown.dropdown:SetSelectedItem(colorizePseudo({1, 1, 1}, pseudo))
						end
					end,
					width = "half",
				},
				[7] = {
					type = "slider",
					name = GetString(SI_TF_SETTING_JRULES_PICKPSEUDO),
					tooltip = GetString(SI_TF_SETTING_JRULES_PICKPSEUDO_TOOLTIP),
					min = 1, max = 24, step = 1,
					getFunc = function()
						return 0
					end,
					setFunc = function(value)
						local control = WINDOW_MANAGER:GetControlByName("ZO_GroupListList1Row" .. value .. "CharacterName")
						local text = control and control:GetText() or ""
						local pseudo = string.match(text, "^[0-9]+\. [^ ]+ (.+)$") or GetUnitName("group" .. value)
						if pseudo ~= "" then
							WINDOW_MANAGER:GetControlByName("ProvTF#jRulesBox").editbox:SetText(pseudo)
						end
					end,
					width = "half",
					disabled = function() return not IsUnitGrouped("player") end,
				},
				[8] = {
					type = "dropdown",
					name = GetString(SI_TF_SETTING_JRULES_PSEUDOCHOICE),
					tooltip = GetString(SI_TF_SETTING_JRULES_PSEUDOCHOICE_TOOLTIP),
					choices = TeamFormation_mapJRULES(),
					getFunc = function()
						local selected = WINDOW_MANAGER:GetControlByName("ProvTF#jRulesList").combobox.m_comboBox:GetSelectedItem()
						return selected
					end,
					setFunc = function(var) end,
					width = "half",
					reference = "ProvTF#jRulesList",
				},
				[9] = {
					type = "colorpicker",
					name = GetString(SI_TF_SETTING_JRULES_COLORCHOICE) .. " (RGB)",
					tooltip = GetString(SI_TF_SETTING_JRULES_COLORCHOICE_TOOLTIP),
					getFunc = function()
						local ctrl_dropdown = WINDOW_MANAGER:GetControlByName("ProvTF#jRulesList")
						local selected = ctrl_dropdown.combobox.m_comboBox:GetSelectedItem()
						if selected ~= "" then
							local pseudo = string.match(selected, "^.+\|t (.+)$")
							return unpack(ProvTF.vars.jRules[pseudo])
						else
							return unpack({1, 1, 1, 1})
						end
						ctrl_dropdown:UpdateChoices(TeamFormation_mapJRULES())
					end,
					setFunc = function(r, g, b, a)
						local ctrl_dropdown = WINDOW_MANAGER:GetControlByName("ProvTF#jRulesList")
						local selected = ctrl_dropdown.combobox.m_comboBox:GetSelectedItem()
						if selected == "" then return end

						local pseudo = string.match(selected, "^.+\|t (.+)$")
						if value == 0 then
							r, g, b = 1, 1, 1
						end
						ProvTF.vars.jRules[pseudo] = {r, g, b}

						ctrl_dropdown:UpdateChoices(TeamFormation_mapJRULES())
						ctrl_dropdown.dropdown:SetSelectedItem(colorizePseudo({r, g, b}, pseudo))
					end,
					width = "half",
					disabled = function()
						local selected = WINDOW_MANAGER:GetControlByName("ProvTF#jRulesList").combobox.m_comboBox:GetSelectedItem()
						return selected == ""
					end,
				},
				[10] = {
					type = "slider",
					name = GetString(SI_TF_SETTING_JRULES_COLORCHOICE) .. " (HSL)",
					tooltip = GetString(SI_TF_SETTING_JRULES_COLORCHOICE_TOOLTIP),
					min = 0, max = 360, step = 1,
					getFunc = function()
						local ctrl_dropdown = WINDOW_MANAGER:GetControlByName("ProvTF#jRulesList")
						local selected = ctrl_dropdown.combobox.m_comboBox:GetSelectedItem()
						local pseudo = string.match(selected, "^.+\|t (.+)$")
						if selected ~= "" and ProvTF.vars.jRules[pseudo] then
							local r, g, b = unpack(ProvTF.vars.jRules[pseudo])
							if r == 1 and g == 1 and b == 1 then
								return 0
							end
							return zo_floor(RGB2HSL(r, g, b) * 360)
						else
							return 0
						end
						ctrl_dropdown:UpdateChoices(TeamFormation_mapJRULES())
					end,
					setFunc = function(value)
						local r, g, b, a = HSL2RGB(value / 360, 1, .5)

						local ctrl_dropdown = WINDOW_MANAGER:GetControlByName("ProvTF#jRulesList")
						local selected = ctrl_dropdown.combobox.m_comboBox:GetSelectedItem()
						if selected == "" then return end

						local pseudo = string.match(selected, "^.+\|t (.+)$")
						if value == 0 then
							r, g, b = 1, 1, 1
						end
						ProvTF.vars.jRules[pseudo] = {r, g, b}

						ctrl_dropdown:UpdateChoices(TeamFormation_mapJRULES())
						ctrl_dropdown.dropdown:SetSelectedItem(colorizePseudo({r, g, b}, pseudo))
					end,
					width = "half",
					disabled = function()
						local selected = WINDOW_MANAGER:GetControlByName("ProvTF#jRulesList").combobox.m_comboBox:GetSelectedItem()
						return selected == ""
					end,
				},
			},
		},
	}

	SLASH_COMMANDS["/tfrainbow"] = function()
		for i = 1, 24 do
			local pseudo = GetUnitName("group" .. i)
			if pseudo ~= "" then
				local r, g, b = HSV2RGB(0.1 * ((i - 1) % 10), 0.5, 1.0)
				ProvTF.vars.jRules[pseudo] = { r, g, b }
				d(colorizePseudo({ r, g, b }, pseudo))
			end
		end

		local ctrl_dropdown = WINDOW_MANAGER:GetControlByName("ProvTF#jRulesList")
		if ctrl_dropdown then
			ctrl_dropdown:UpdateChoices(TeamFormation_mapJRULES())
		end
	end

	if GetUnitName("player") == "Elium" or GetUnitName("player") == "Elena d'Alizarine" then -- Just for me ;) (Prevent crash)
		table.insert(optionsData, {
			type = "submenu",
			name = "Espace de développement",
			controls =
			{
				[1] =
				{
					type = "checkbox",
					name = "Activer",
					getFunc = function() return ProvTF.debug.enabled end,
					setFunc = function(value) ProvTF.debug.enabled = value end,
					width = "full",
				},
				[2] = {
					type = "slider",
					name = "Numéro",
					min = 1, max = 24, step = 1,
					getFunc = function() return zo_round(ProvTF.debug.pos.num) end,
					setFunc = function(value) ProvTF.debug.pos.num = value end,
					width = "half",
				},
				[3] = {
					type = "button",
					name = "Définir emplacement",
					func = function()
						local x, y, heading = GetMapPlayerPosition("player")

						ProvTF.debug.pos.x = x
						ProvTF.debug.pos.y = y
						ProvTF.debug.pos.zone = GetUnitZone("player")
						ProvTF.debug.pos.heading = heading
					end,
					width = "half",
				},
				[4] = {
					type = "description",
					text = "Où utiliser /tfdebug à la position voulue.",
				},
			},
		})

		SLASH_COMMANDS["/tfdebug"] = function()
			local x, y, heading = GetMapPlayerPosition("player")

			ProvTF.debug.enabled = true
			ProvTF.debug.pos.x = x
			ProvTF.debug.pos.y = y
			ProvTF.debug.pos.zone = GetUnitZone("player")
			ProvTF.debug.pos.heading = heading

			for n = 1, GetGroupSize() do
				if GetUnitName("group" .. n) ~= GetUnitName("player") then
					ProvTF.debug.pos.num = n
					break
				end
			end
		end
	end

	ProvTF.CPL = LAM2:RegisterAddonPanel(ProvTF.name .. "LAM2Panel", panelData)
	LAM2:RegisterOptionControls(ProvTF.name .. "LAM2Panel", optionsData)
end
