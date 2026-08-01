local LCA = LibCombatAlerts
local GBP = GroupBuffPanels
local LHAS = LibHarvensAddonSettings


--------------------------------------------------------------------------------
-- Frontend
--------------------------------------------------------------------------------

local CFE = GBP.CommonFrontend
GBP.CommonFrontend = nil

local function BuildCommonPanelSettings( selected )
	local disable = function( )
		return GBP.IsDisabled() or (selected.abilityId and not GBP.GetPanelSetting("overrideDefaults", selected.abilityId))
	end

	return {
		------------------------------------------------------------------------
		{
			type = LHAS.ST_SLIDER,
			label = GetString(SI_GBP_SETTING_SNAP),
			tooltip = SI_GBP_SETTING_SNAP_TT,
			min = 0,
			max = 40,
			step = 2,
			getFunction = function() return GBP.GetPanelSetting("snap", selected.abilityId) end,
			setFunction = function(snap) GBP.SetPanelSetting("snap", selected.abilityId, snap, "RefreshSnapStates") end,
			disable = disable,
		},
		--------------------
		{
			type = LHAS.ST_SLIDER,
			label = GetString(SI_GBP_SETTING_COLUMNS),
			min = 1,
			max = 4,
			step = 1,
			getFunction = function() return GBP.GetPanelSetting("columns", selected.abilityId) end,
			setFunction = function(columns) GBP.SetPanelSetting("columns", selected.abilityId, columns, "ReloadPanels") end,
			disable = disable,
		},
		--------------------
		{
			type = LHAS.ST_SLIDER,
			label = GetString(SI_GBP_SETTING_COLUMN_WIDTH),
			min = 100,
			max = 200,
			step = 2,
			getFunction = function() return GBP.GetPanelSetting("columnWidth", selected.abilityId) end,
			setFunction = function(width) GBP.SetPanelSetting("columnWidth", selected.abilityId, width, "ReloadPanels") end,
			disable = disable,
		},
		--------------------
		{
			type = LHAS.ST_SLIDER,
			label = GetString(SI_GBP_SETTING_SCALE),
			min = 50,
			max = 200,
			step = 10,
			unit = "%",
			getFunction = function() return zo_round(GBP.GetPanelSetting("scale", selected.abilityId) * 10) * 10 end,
			setFunction = function(scale) GBP.SetPanelSetting("scale", selected.abilityId, zo_round(scale) / 100, "ReloadPanels") end,
			disable = disable,
		},
		--------------------
		{
			type = LHAS.ST_CHECKBOX,
			label = GetString(SI_GBP_SETTING_SHOW_TANK),
			getFunction = CFE.GetBitfieldFunction("filter", selected, LCA.GROUP_PANEL_SHOW_TANK),
			setFunction = CFE.GetBitfieldFunction("filter", selected, LCA.GROUP_PANEL_SHOW_TANK, "ReloadPanels"),
			disable = disable,
		},
		--------------------
		{
			type = LHAS.ST_CHECKBOX,
			label = GetString(SI_GBP_SETTING_SHOW_HEALER),
			getFunction = CFE.GetBitfieldFunction("filter", selected, LCA.GROUP_PANEL_SHOW_HEALER),
			setFunction = CFE.GetBitfieldFunction("filter", selected, LCA.GROUP_PANEL_SHOW_HEALER, "ReloadPanels"),
			disable = disable,
		},
		--------------------
		{
			type = LHAS.ST_CHECKBOX,
			label = GetString(SI_GBP_SETTING_SHOW_DAMAGE),
			getFunction = CFE.GetBitfieldFunction("filter", selected, LCA.GROUP_PANEL_SHOW_DAMAGE),
			setFunction = CFE.GetBitfieldFunction("filter", selected, LCA.GROUP_PANEL_SHOW_DAMAGE, "ReloadPanels"),
			disable = disable,
		},
		--------------------
		{
			type = LHAS.ST_CHECKBOX,
			label = GetString(SI_GBP_SETTING_STRIKE_DEAD),
			getFunction = function() return GBP.GetPanelSetting("strikeDead", selected.abilityId) end,
			setFunction = function(enabled) GBP.SetPanelSetting("strikeDead", selected.abilityId, enabled, "ReloadPanels") end,
			disable = disable,
		},
		--------------------
		{
			type = LHAS.ST_CHECKBOX,
			label = GetString(SI_GBP_SETTING_DIM_DISTANT),
			getFunction = function() return GBP.GetPanelSetting("dimDistant", selected.abilityId) end,
			setFunction = function(enabled) GBP.SetPanelSetting("dimDistant", selected.abilityId, enabled, "ReloadPanels") end,
			disable = disable,
		},
		--------------------
		{
			type = LHAS.ST_COLOR,
			label = string.format("%s: %s", GetString(SI_LCA_COLOR), GetString(SI_GBP_SETTING_COLOR_TIMER)),
			getFunction = function() return LCA.UnpackRGBA(GBP.GetPanelSetting("colorTimer", selected.abilityId)) end,
			setFunction = function(...) GBP.SetPanelSetting("colorTimer", selected.abilityId, LCA.PackRGBA(...), "ReloadPanels") end,
			disable = disable,
		},
		--------------------
		{
			type = LHAS.ST_COLOR,
			label = string.format("%s: %s", GetString(SI_LCA_COLOR), GetString(SI_GBP_SETTING_COLOR_START)),
			getFunction = function() return LCA.UnpackRGBA(GBP.GetPanelSetting("colorStart", selected.abilityId)) end,
			setFunction = function(...) GBP.SetPanelSetting("colorStart", selected.abilityId, LCA.PackRGBA(...), "ClearColorCache") end,
			disable = disable,
		},
		--------------------
		{
			type = LHAS.ST_COLOR,
			label = string.format("%s: %s", GetString(SI_LCA_COLOR), GetString(SI_GBP_SETTING_COLOR_END)),
			getFunction = function() return LCA.UnpackRGBA(GBP.GetPanelSetting("colorEnd", selected.abilityId)) end,
			setFunction = function(...) GBP.SetPanelSetting("colorEnd", selected.abilityId, LCA.PackRGBA(...), "ClearColorCache") end,
			disable = disable,
		},
	}
end

function GBP.RegisterSettingsPanel( )
	local panel = LHAS:AddAddon(GetString(SI_GBP_TITLE), {
		allowRefresh = true,
	})

	panel:AddSettings({
		------------------------------------------------------------------------
		{
			type = LHAS.ST_LABEL,
			label = GetString(SI_GBP_PROFILES),
		},
		--------------------
		{
			type = LHAS.ST_DROPDOWN,
			label = zo_strformat(SI_GBP_PROFILE_CURRENT, GetUnitName("player")),
			tooltip = SI_GBP_PROFILES_TT,
			items = function( )
				local profileIds = GBP.GetProfiles()
				local entries = { }
				for i, profileId in ipairs(profileIds) do
					local name = GBP.GetProfileName(profileId)
					entries[i] = {
						name = GBP.IsNotUserProfile(profileId) and string.format("<%s>", name) or name,
						data = profileId,
					}
				end
				return entries
			end,
			getFunction = function() return { data = GBP.GetCurrentProfile() } end,
			setFunction = function(_, _, entry) GBP.SetCurrentProfile(entry.data) end,
		},
		--------------------
		{
			type = LHAS.ST_EDIT,
			label = GetString(SI_GBP_PROFILE_RENAME),
			getFunction = GBP.GetProfileName,
			setFunction = function(name) GBP.SetProfileName(nil, name) end,
			disable = GBP.IsNotUserProfile,
		},
		--------------------
		{
			type = LHAS.ST_BUTTON,
			buttonText = GetString(SI_GBP_PROFILE_DELETE),
			clickHandler = function() GBP.DeleteProfile() end,
			disable = GBP.IsNotUserProfile,
		},
		--------------------
		{
			type = LHAS.ST_BUTTON,
			buttonText = GetString(SI_GBP_PROFILE_CREATE),
			tooltip = SI_GBP_PROFILE_CREATE_TT,
			clickHandler = GBP.CreateProfile,
		},
		--------------------
		{
			type = LHAS.ST_LABEL,
			label = string.format("|c%s%s|r", ZO_NORMAL_TEXT:ToHex(), string.rep("_", 16)),
		},
		--------------------
		{
			type = LHAS.ST_SECTION,
			label = GetString(SI_GBP_PLACEMENT_PREVIEW),
		},
		--------------------
		{
			type = LHAS.ST_CHECKBOX,
			label = GetString(SI_ADDON_MANAGER_ENABLED),
			getFunction = GBP.GetPlacementPreview,
			setFunction = function( enabled )
				GBP.SetPlacementPreview(enabled)
			end,
			disable = GBP.IsDisabled,
		},
		--------------------
		{
			type = LHAS.ST_CHECKBOX,
			label = GetString(SI_GBP_PLACEMENT_PREVIEW_4MAN),
			getFunction = function() return select(2, GBP.GetPlacementPreview()) end,
			setFunction = function( enabled )
				GBP.SetPlacementPreview(true, enabled)
			end,
			disable = function() return GBP.IsDisabled() or not GBP.GetPlacementPreview() end,
		},
		--------------------
		{
			type = LHAS.ST_SECTION,
			label = GetString(SI_GBP_SETTING_DEFAULT_PANEL),
		},
	})

	panel:AddSettings(BuildCommonPanelSettings({}))

	panel:AddSettings({
		------------------------------------------------------------------------
		{
			type = LHAS.ST_SECTION,
			label = GetString(SI_GBP_SETTING_PANELS),
		},
		--------------------
		{
			type = LHAS.ST_DROPDOWN,
			label = GetString(SI_GBP_SETTING_PANELS_CHOICE),
			items = CFE.GetAbilityDropdownChoices,
			getFunction = function() return { data = CFE.abilityId } end,
			setFunction = function(_, _, entry) CFE.abilityId = entry.data end,
			disable = GBP.IsDisabled,
		},
		--------------------
		{
			type = LHAS.ST_BUTTON,
			buttonText = GetString(SI_GBP_SETTING_REPOSITION),
			tooltip = zo_strformat(SI_GBP_SETTING_REPOSITION_TT, zo_iconFormat(GetGamepadRightStickScrollIcon(), "100%", "100%")),
			clickHandler = function( )
				GBP.ToggleVisibilityInSettings(true)
				GBP.GetActivePanels()[CFE.abilityId]:ToggleGamepadMove(true)
			end,
			disable = function() return GBP.GetActivePanels()[CFE.abilityId or 0] == nil end,
		},
		--------------------
		{
			type = LHAS.ST_CHECKBOX,
			label = GetString(SI_GBP_SETTING_ENABLED_E),
			tooltip = SI_GBP_SETTING_GROUP_NOTE,
			getFunction = CFE.GetBitfieldFunction("enabled", CFE, "E"),
			setFunction = CFE.GetBitfieldFunction("enabled", CFE, "E", "RefreshEnablementStates"),
			disable = GBP.IsDisabled,
		},
		--------------------
		{
			type = LHAS.ST_CHECKBOX,
			label = GetString(SI_GBP_SETTING_ENABLED_P),
			tooltip = SI_GBP_SETTING_GROUP_NOTE,
			getFunction = CFE.GetBitfieldFunction("enabled", CFE, "P"),
			setFunction = CFE.GetBitfieldFunction("enabled", CFE, "P", "RefreshEnablementStates"),
			disable = GBP.IsDisabled,
		},
		--------------------
		{
			type = LHAS.ST_CHECKBOX,
			label = GetString(SI_GBP_SETTING_ENABLED_O),
			tooltip = SI_GBP_SETTING_GROUP_NOTE,
			getFunction = CFE.GetBitfieldFunction("enabled", CFE, "O"),
			setFunction = CFE.GetBitfieldFunction("enabled", CFE, "O", "RefreshEnablementStates"),
			disable = GBP.IsDisabled,
		},
		--------------------
		{
			type = LHAS.ST_CHECKBOX,
			label = CFE.GetConditionalEnablementText,
			tooltip = SI_GBP_SETTING_GROUP_NOTE,
			getFunction = CFE.GetBitfieldFunction("enabled", CFE, "C"),
			setFunction = CFE.GetBitfieldFunction("enabled", CFE, "C", "RefreshEnablementStates"),
			disable = CFE.IsConditionalEnablementDisabled,
		},
		--------------------
		{
			type = LHAS.ST_CHECKBOX,
			label = GetString(SI_GBP_SETTING_OVERRIDE_PANEL),
			getFunction = function() return GBP.GetPanelSetting("overrideDefaults", CFE.abilityId) end,
			setFunction = function(enabled) GBP.SetPanelSetting("overrideDefaults", CFE.abilityId, enabled, "ReloadPanels") end,
			disable = GBP.IsDisabled,
		},
	})

	panel:AddSettings(BuildCommonPanelSettings(CFE))

	local effectsString = CFE.GetSupportedEffectsString()
	panel:AddSettings({
		------------------------------------------------------------------------
		{
			type = LHAS.ST_SECTION,
			label = GetString(SI_GBP_SETTING_EFFECTS),
		},
		--------------------
		{
			type = LHAS.ST_EDIT,
			label = GetString(SI_GBP_SETTING_EFFECTS_EDITBOX),
			getFunction = function() return effectsString end,
			setFunction = function(text) effectsString = CFE.GetSupportedEffectsString(text) end,
		},
		--------------------
		{
			type = LHAS.ST_BUTTON,
			buttonText = GetString(SI_OPTIONS_DEFAULTS),
			clickHandler = function() effectsString = CFE.GetSupportedEffectsString(true) end,
		},
		--------------------
		{
			type = LHAS.ST_BUTTON,
			buttonText = GetString(SI_APPLY),
			tooltip = SI_OPTIONS_APPLY_WARNING,
			clickHandler = function( )
				GroupBuffPanelsSavedVariables.effects = (effectsString ~= CFE.GetSupportedEffectsString(true)) and effectsString or nil
				ReloadUI()
			end,
			disable = function() return effectsString == CFE.GetSupportedEffectsString() end,
		},
	})
end

function GBP.ToggleVisibilityInSettings( enable, noDelay )
	local name = "GBP_VisibilityInSettings"
	EVENT_MANAGER:UnregisterForUpdate(name)
	if (enable or noDelay) then
		for _, panel in pairs(GBP.GetActivePanels()) do
			panel:ToggleAdditionalScene("LibHarvensAddonSettingsScene", enable)
		end
	elseif (not enable and not noDelay) then
		EVENT_MANAGER:RegisterForUpdate(name, 2000, function() GBP.ToggleVisibilityInSettings(false, true) end)
	end
end

function GBP.SavePanelPositionFollowup( )
	GBP.ToggleVisibilityInSettings(false)
end
