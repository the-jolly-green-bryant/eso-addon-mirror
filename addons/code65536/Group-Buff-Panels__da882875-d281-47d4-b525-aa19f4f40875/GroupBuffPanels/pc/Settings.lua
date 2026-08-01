local LCA = LibCombatAlerts
local GBP = GroupBuffPanels


--------------------------------------------------------------------------------
-- Frontend
--------------------------------------------------------------------------------

local CFE = GBP.CommonFrontend
GBP.CommonFrontend = nil

local function BuildCommonPanelSettings( selected )
	return {
		------------------------------------------------------------------------
		{
			type = "checkbox",
			name = SI_GBP_SETTING_LOCK,
			getFunc = function() return GBP.GetPanelSetting("lock", selected.abilityId) end,
			setFunc = function(enabled) GBP.SetPanelSetting("lock", selected.abilityId, enabled, "RefreshLockStates") end,
		},
		--------------------
		{
			type = "slider",
			name = SI_GBP_SETTING_SNAP,
			tooltip = SI_GBP_SETTING_SNAP_TT,
			min = 0,
			max = 40,
			step = 2,
			getFunc = function() return GBP.GetPanelSetting("snap", selected.abilityId) end,
			setFunc = function(snap) GBP.SetPanelSetting("snap", selected.abilityId, snap, "RefreshSnapStates") end,
		},
		--------------------
		{
			type = "slider",
			name = SI_GBP_SETTING_COLUMNS,
			min = 1,
			max = 4,
			step = 1,
			getFunc = function() return GBP.GetPanelSetting("columns", selected.abilityId) end,
			setFunc = function(columns) GBP.SetPanelSetting("columns", selected.abilityId, columns, "ReloadPanels") end,
		},
		--------------------
		{
			type = "slider",
			name = SI_GBP_SETTING_COLUMN_WIDTH,
			min = 100,
			max = 200,
			step = 2,
			getFunc = function() return GBP.GetPanelSetting("columnWidth", selected.abilityId) end,
			setFunc = function(width) GBP.SetPanelSetting("columnWidth", selected.abilityId, width, "ReloadPanels") end,
		},
		--------------------
		{
			type = "slider",
			name = SI_GBP_SETTING_SCALE,
			min = 50,
			max = 200,
			step = 10,
			getFunc = function() return zo_round(GBP.GetPanelSetting("scale", selected.abilityId) * 10) * 10 end,
			setFunc = function(scale) GBP.SetPanelSetting("scale", selected.abilityId, zo_round(scale) / 100, "ReloadPanels") end,
		},
		--------------------
		{
			type = "checkbox",
			name = SI_GBP_SETTING_SHOW_TANK,
			getFunc = CFE.GetBitfieldFunction("filter", selected, LCA.GROUP_PANEL_SHOW_TANK),
			setFunc = CFE.GetBitfieldFunction("filter", selected, LCA.GROUP_PANEL_SHOW_TANK, "ReloadPanels"),
		},
		--------------------
		{
			type = "checkbox",
			name = SI_GBP_SETTING_SHOW_HEALER,
			getFunc = CFE.GetBitfieldFunction("filter", selected, LCA.GROUP_PANEL_SHOW_HEALER),
			setFunc = CFE.GetBitfieldFunction("filter", selected, LCA.GROUP_PANEL_SHOW_HEALER, "ReloadPanels"),
		},
		--------------------
		{
			type = "checkbox",
			name = SI_GBP_SETTING_SHOW_DAMAGE,
			getFunc = CFE.GetBitfieldFunction("filter", selected, LCA.GROUP_PANEL_SHOW_DAMAGE),
			setFunc = CFE.GetBitfieldFunction("filter", selected, LCA.GROUP_PANEL_SHOW_DAMAGE, "ReloadPanels"),
		},
		--------------------
		{
			type = "checkbox",
			name = SI_GBP_SETTING_STRIKE_DEAD,
			getFunc = function() return GBP.GetPanelSetting("strikeDead", selected.abilityId) end,
			setFunc = function(enabled) GBP.SetPanelSetting("strikeDead", selected.abilityId, enabled, "ReloadPanels") end,
		},
		--------------------
		{
			type = "checkbox",
			name = SI_GBP_SETTING_DIM_DISTANT,
			getFunc = function() return GBP.GetPanelSetting("dimDistant", selected.abilityId) end,
			setFunc = function(enabled) GBP.SetPanelSetting("dimDistant", selected.abilityId, enabled, "ReloadPanels") end,
		},
		--------------------
		{
			type = "checkbox",
			name = SI_GBP_SETTING_HIDE_HEADER,
			getFunc = function() return GBP.GetPanelSetting("hideHeader", selected.abilityId) end,
			setFunc = function(enabled) GBP.SetPanelSetting("hideHeader", selected.abilityId, enabled, "ReloadPanels") end,
		},
		--------------------
		{
			type = "header",
			name = SI_LCA_COLOR,
		},
		--------------------
		{
			type = "colorpicker",
			name = SI_GBP_SETTING_COLOR_TIMER,
			getFunc = function() return LCA.UnpackRGBA(GBP.GetPanelSetting("colorTimer", selected.abilityId)) end,
			setFunc = function(...) GBP.SetPanelSetting("colorTimer", selected.abilityId, LCA.PackRGBA(...), "ReloadPanels") end,
		},
		--------------------
		{
			type = "colorpicker",
			name = SI_GBP_SETTING_COLOR_START,
			getFunc = function() return LCA.UnpackRGBA(GBP.GetPanelSetting("colorStart", selected.abilityId)) end,
			setFunc = function(...) GBP.SetPanelSetting("colorStart", selected.abilityId, LCA.PackRGBA(...), "ClearColorCache") end,
		},
		--------------------
		{
			type = "colorpicker",
			getFunc = function() return GBP.GetColorUnpacked(selected.abilityId, 1, 2) end,
			disabled = true,
		},
		--------------------
		{
			type = "colorpicker",
			name = SI_GBP_SETTING_COLOR_END,
			getFunc = function() return LCA.UnpackRGBA(GBP.GetPanelSetting("colorEnd", selected.abilityId)) end,
			setFunc = function(...) GBP.SetPanelSetting("colorEnd", selected.abilityId, LCA.PackRGBA(...), "ClearColorCache") end,
		},
		--------------------
		{
			type = "checkbox",
			name = SI_GBP_SETTING_COLOR_REVERSE,
			getFunc = function() return GBP.GetPanelSetting("colorReverse", selected.abilityId) end,
			setFunc = function(enabled) GBP.SetPanelSetting("colorReverse", selected.abilityId, enabled, "ClearColorCache") end,
		},
	}
end

function GBP.RegisterSettingsPanel( )
	local LAM = LCA.GetLibAddonMenu()
	if (not LAM) then return end

	local panelId = "GroupBuffPanelsSettingsPanel"

	GBP.settingsPanel = LAM:RegisterAddonPanel(panelId, {
		type = "panel",
		name = GetString(SI_GBP_TITLE),
		version = LCA.FormatVersion(LCA.GetAddOnVersion(GBP.ID)),
		author = "@code65536",
		website = GBP.URL,
		donation = GBP.URL .. "#donate",
		registerForRefresh = true,
	})

	local profileSelector = {
		type = "dropdown",
		name = zo_strformat(SI_GBP_PROFILE_CURRENT, GetUnitName("player")),
		tooltip = SI_GBP_PROFILES_TT,
		getFunc = GBP.GetCurrentProfile,
		setFunc = GBP.SetCurrentProfile,
		reference = "GBP_ProfileSelector",
	}

	local updateProfiles = function( )
		local profileIds = GBP.GetProfiles()
		local profileNames = { }
		for i, profileId in ipairs(profileIds) do
			local name = GBP.GetProfileName(profileId)
			profileNames[i] = GBP.IsNotUserProfile(profileId) and string.format("<%s>", name) or name
		end
		profileSelector.choices = profileNames
		profileSelector.choicesValues = profileIds
		if (GBP_ProfileSelector) then
			GBP_ProfileSelector:UpdateChoices()
			GBP_ProfileSelector:UpdateValue()
		end
	end

	updateProfiles()

	local choices, choicesValues = CFE.GetAbilityDropdownChoices(true)
	local effectsString = CFE.GetSupportedEffectsString()

	LAM:RegisterOptionControls(panelId, {
		------------------------------------------------------------------------
		{
			type = "header",
			name = SI_GBP_PROFILES,
		},
		--------------------
		profileSelector,
		--------------------
		{
			type = "editbox",
			name = SI_GBP_PROFILE_RENAME,
			getFunc = GBP.GetProfileName,
			setFunc = function( name )
				GBP.SetProfileName(nil, name)
				updateProfiles()
			end,
			disabled = GBP.IsNotUserProfile,
		},
		--------------------
		{
			type = "button",
			name = SI_GBP_PROFILE_CREATE,
			tooltip = SI_GBP_PROFILE_CREATE_TT,
			width = "half",
			func = function( )
				GBP.SetCurrentProfile(GBP.CreateProfile())
				updateProfiles()
			end,
		},
		--------------------
		{
			type = "button",
			name = SI_GBP_PROFILE_DELETE,
			width = "half",
			func = function( )
				GBP.DeleteProfile()
				updateProfiles()
			end,
			disabled = GBP.IsNotUserProfile,
			isDangerous = true,
		},
		--------------------
		{
			type = "header",
			name = SI_GBP_SETTING_PANELS,
		},
		--------------------
		{
			type = "description",
			text = SI_GBP_SETTING_GROUP_NOTE,
		},
		--------------------
		{
			type = "submenu",
			icon = "/esoui/art/icons/mapkey/mapkey_areaofinterest.dds",
			name = SI_GBP_PLACEMENT_PREVIEW,
			controls = {
				----------------------------------------------------------------
				{
					type = "checkbox",
					name = SI_ADDON_MANAGER_ENABLED,
					getFunc = GBP.GetPlacementPreview,
					setFunc = function( enabled )
						GBP.SetPlacementPreview(enabled)
					end,
				},
				--------------------
				{
					type = "checkbox",
					name = SI_GBP_PLACEMENT_PREVIEW_4MAN,
					getFunc = function() return select(2, GBP.GetPlacementPreview()) end,
					setFunc = function( enabled )
						GBP.SetPlacementPreview(true, enabled)
					end,
					disabled = function() return not GBP.GetPlacementPreview() end,
				},
			},
			disabled = GBP.IsDisabled,
		},
		--------------------
		{
			type = "submenu",
			icon = LCA.GetTexture("misc-check"),
			name = SI_OPTIONS_DEFAULTS,
			controls = BuildCommonPanelSettings({}),
			disabled = GBP.IsDisabled,
		},
		--------------------
		{
			type = "dropdown",
			name = SI_GBP_SETTING_PANELS_CHOICE,
			choices = choices,
			choicesValues = choicesValues,
			getFunc = function() return CFE.abilityId end,
			setFunc = function( abilityId )
				CFE.abilityId = abilityId
				local control = GBP_ConditionalEnablementToggle and GBP_ConditionalEnablementToggle.label
				if (control) then
					control:SetText(CFE.GetConditionalEnablementText())
				end
			end,
			disabled = GBP.IsDisabled,
			reference = "GBP_EffectsSelector",
		},
		--------------------
		{
			type = "checkbox",
			name = SI_GBP_SETTING_ENABLED_E,
			getFunc = CFE.GetBitfieldFunction("enabled", CFE, "E"),
			setFunc = CFE.GetBitfieldFunction("enabled", CFE, "E", "RefreshEnablementStates"),
			disabled = GBP.IsDisabled,
		},
		--------------------
		{
			type = "checkbox",
			name = SI_GBP_SETTING_ENABLED_P,
			getFunc = CFE.GetBitfieldFunction("enabled", CFE, "P"),
			setFunc = CFE.GetBitfieldFunction("enabled", CFE, "P", "RefreshEnablementStates"),
			disabled = GBP.IsDisabled,
		},
		--------------------
		{
			type = "checkbox",
			name = SI_GBP_SETTING_ENABLED_O,
			getFunc = CFE.GetBitfieldFunction("enabled", CFE, "O"),
			setFunc = CFE.GetBitfieldFunction("enabled", CFE, "O", "RefreshEnablementStates"),
			disabled = GBP.IsDisabled,
		},
		--------------------
		{
			type = "checkbox",
			name = CFE.GetConditionalEnablementText,
			getFunc = CFE.GetBitfieldFunction("enabled", CFE, "C"),
			setFunc = CFE.GetBitfieldFunction("enabled", CFE, "C", "RefreshEnablementStates"),
			disabled = CFE.IsConditionalEnablementDisabled,
			reference = "GBP_ConditionalEnablementToggle",
		},
		--------------------
		{
			type = "checkbox",
			name = SI_GBP_SETTING_OVERRIDE_PANEL,
			getFunc = function() return GBP.GetPanelSetting("overrideDefaults", CFE.abilityId) end,
			setFunc = function(enabled) GBP.SetPanelSetting("overrideDefaults", CFE.abilityId, enabled, "ReloadPanels") end,
			disabled = GBP.IsDisabled,
		},
		--------------------
		{
			type = "submenu",
			name = SI_GAME_MENU_SETTINGS,
			controls = BuildCommonPanelSettings(CFE),
			disabled = function() return GBP.IsDisabled() or not GBP.GetPanelSetting("overrideDefaults", CFE.abilityId) end,
		},
		--------------------
		{
			type = "description",
			text = CFE.GetAbilityIdText,
		},
		--------------------
		{
			type = "header",
			name = SI_GBP_SETTING_EFFECTS,
		},
		--------------------
		{
			type = "submenu",
			icon = "/esoui/art/lfg/gamepad/gp_lfg_groupfinder_editlisting.dds",
			name = SI_GROUP_FINDER_EDIT_GROUP,
			controls = {
				----------------------------------------------------------------
				{
					type = "editbox",
					name = SI_GBP_SETTING_EFFECTS_EDITBOX,
					isMultiline = true,
					isExtraWide = true,
					maxChars = 0xFFFF,
					textType = TEXT_TYPE_ALL,
					reference = "GBP_EffectsEditor",
					getFunc = function() return effectsString end,
					setFunc = function( text )
						effectsString = CFE.GetSupportedEffectsString(text)
						if (GBP_EffectsEditor) then
							GBP_EffectsEditor:UpdateValue()
						end
					end,
				},
				--------------------
				{
					type = "button",
					name = SI_OPTIONS_DEFAULTS,
					width = "half",
					func = function() effectsString = CFE.GetSupportedEffectsString(true) end,
				},
				--------------------
				{
					type = "button",
					name = SI_APPLY,
					width = "half",
					warning = SI_OPTIONS_APPLY_WARNING,
					func = function( )
						GroupBuffPanelsSavedVariables.effects = (effectsString ~= CFE.GetSupportedEffectsString(true)) and effectsString or nil
						ReloadUI()
					end,
					disabled = function() return effectsString == CFE.GetSupportedEffectsString() end,
				},
			},
		},
	})

	CFE.FixDropdownHeight = function( panel )
		if (panel == GBP.settingsPanel) then
			CALLBACK_MANAGER:UnregisterCallback("LAM-PanelControlsCreated", CFE.FixDropdownHeight)
			local vanillaHeight = 31 -- /esoui/libraries/zo_combobox/zo_combobox.xml
			local control = GBP_EffectsSelector and GBP_EffectsSelector.combobox
			if (control and control:GetHeight() < vanillaHeight) then
				control:SetHeight(vanillaHeight)
			end
		end
	end
	CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", CFE.FixDropdownHeight)
end
