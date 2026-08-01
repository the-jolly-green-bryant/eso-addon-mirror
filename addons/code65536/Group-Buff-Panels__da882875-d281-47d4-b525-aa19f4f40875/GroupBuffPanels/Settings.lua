local LCA = LibCombatAlerts
local GBP = GroupBuffPanels


--------------------------------------------------------------------------------
-- Constants
--------------------------------------------------------------------------------

local DEFAULT_EFFECTS = "61747, 93109, 93123, 109966, 147417, 61745, 61744, 61694, 61693, 61665, 61662, 61687, 61685, 61709, 61708, 61716, 61715, 61736, 61735, 61666, 61691, 61704, 61706, 88490, 61771, 163401, -172056, 40079, 61506, 40224, 32948+29230, 61737, -234295"

local DEFAULT_SETTINGS = {
	profiles = { },
	global = {
		defaults = {
			lock = false,
			snap = ZO_IsConsoleOrGameCoreUI() and 20 or 4,
			columns = 1,
			columnWidth = 160,
			scale = 1,
			filter = LCA.GROUP_PANEL_SHOW_ALL,
			strikeDead = true,
			dimDistant = true,
			hideHeader = false,
			colorTimer = 0xFFFF00FF,
			colorStart = 0x66CC6699,
			colorEnd = 0xCC666699,
			colorReverse = false,
		},
	},
}

local DEFAULT_POSITION = {
	left = 1200,
	top = 600,
}

local PANEL_SPECIFIC_SETTINGS = { "enabled", "overrideDefaults", "pos" }
local ENABLEMENT_FLAGS = { E = 1, P = 2, O = 4, C = 8, ANY = 7 }
local SV_VERSION = 2


--------------------------------------------------------------------------------
-- Backend
--------------------------------------------------------------------------------

local SV -- Root SV table
local CHARID = GetCurrentCharacterId()
local CurrentProfile, CurrentProfileId

local function IsSettingPanelSpecific( settingName )
	for _, name in ipairs(PANEL_SPECIFIC_SETTINGS) do
		if (name == settingName) then
			return true
		end
	end
	return false
end

local function ProcessMultipleIds( idString )
	local results = { zo_strsplit("+", idString) }
	if (results[2]) then
		for i = 1, #results do
			results[i] = tonumber(results[i])
			if (not results[i]) then
				return nil
			elseif (i > 1) then
				results[i] = zo_abs(results[i])
			end
		end
		return results[1], results
	else
		return tonumber(idString)
	end
end

local function GetSupportedEffectsString( param )
	if (type(param) == "string") then
		-- Clean up user input: filter out duplicates and invalid IDs
		local ids = { }
		local added = { }
		for _, id in ipairs({ zo_strsplit(",", param) }) do
			local id, multi = ProcessMultipleIds(id)
			local realId = id and zo_abs(id)
			if (realId and not added[realId] and GetAbilityName(realId) ~= "") then
				table.insert(ids, multi and table.concat(multi, "+") or id)
				added[realId] = true
			end
		end
		return table.concat(ids, ", ")
	else
		-- Retrieve user-defined string, falling back to the default string if
		-- there is none; passing true will always get the default
		return not param and SV.effects or DEFAULT_EFFECTS
	end
end

local function IsValidUserProfile( profileId )
	if (profileId == "profiles" or profileId == "global") then
		return false
	elseif (type(profileId) == "string" and profileId ~= "" and type(SV[profileId]) == "table") then
		return true
	else
		return false
	end
end

local function IsValidNonGlobalProfile( profileId )
	return IsValidUserProfile(profileId) or profileId == "disabled"
end

local function RefreshProfileSelection( suppressPanelReload )
	local id = SV.profiles[CHARID]
	if (IsValidNonGlobalProfile(id)) then
		CurrentProfile = LCA.PopulateOptions(SV[id], DEFAULT_SETTINGS.global, true)
		CurrentProfileId = id
	else
		CurrentProfile = SV.global
		CurrentProfileId = "global"
		SV.profiles[CHARID] = nil
	end
	if (not suppressPanelReload) then
		GBP.ReloadPanels()
	end
end

local function MigrateSettings( )
	if (SV.version == nil or SV.version == 1) then
		for i = 1, GetNumCharacters() do
			local name, _, _, _, _, _, id = GetCharacterInfo(i)
			local profile = SV[id]
			if (type(profile) == "table") then
				if (not profile.name) then
					profile.name = zo_strformat("<<1>>'s profile", name)
				end
				if (profile.overrideGlobal) then
					profile.overrideGlobal = nil
					SV.profiles[id] = id
				end
			end
		end
		local migrationIncomplete = false
		for profileId, profile in pairs(SV) do
			if (IsValidUserProfile(profileId) and not profile.name) then
				migrationIncomplete = true
			end
		end
		SV.version = migrationIncomplete and 1 or SV_VERSION
	end
end

function GBP.LoadSettings( )
	GroupBuffPanelsSavedVariables = LCA.PopulateOptions(GroupBuffPanelsSavedVariables, DEFAULT_SETTINGS, true)
	SV = GroupBuffPanelsSavedVariables

	GBP.EFFECTS = { zo_strsplit(",", GetSupportedEffectsString()) }
	GBP.ALTMODE = { }
	GBP.MULTIID = { }
	for i = 1, #GBP.EFFECTS do
		local id, multi = ProcessMultipleIds(GBP.EFFECTS[i])
		local realId = zo_abs(id)
		GBP.EFFECTS[i] = realId
		GBP.ALTMODE[realId] = id ~= realId
		GBP.MULTIID[realId] = multi
	end

	MigrateSettings()
	RefreshProfileSelection(true)
end


--------------------------------------------------------------------------------
-- APIs for profiles
--------------------------------------------------------------------------------

function GBP.GetProfiles( )
	local userProfiles = { }
	for profileId in pairs(SV) do
		if (IsValidUserProfile(profileId)) then
			table.insert(userProfiles, profileId)
		end
	end
	table.sort(userProfiles, function(a, b) return GBP.GetProfileName(a) < GBP.GetProfileName(b) end)
	return LCA.ConcatTables({ "disabled", "global" }, userProfiles)
end

function GBP.GetCurrentProfile( )
	return CurrentProfileId
end

function GBP.SetCurrentProfile( profileId )
	if (CurrentProfileId ~= profileId) then
		SV.profiles[CHARID] = IsValidNonGlobalProfile(profileId) and profileId or nil
		RefreshProfileSelection()
	end
end

function GBP.GetProfileName( profileId )
	-- Assume current profile if profileId is omitted
	profileId = profileId or CurrentProfileId
	if (profileId == "disabled") then
		return GetString(SI_CHECK_BUTTON_DISABLED)
	elseif (profileId == "global") then
		return GetString(SI_CAMERA_OPTIONS_GLOBAL)
	elseif (IsValidUserProfile(profileId)) then
		return SV[profileId].name or profileId
	else
		return ""
	end
end

function GBP.SetProfileName( profileId, name )
	-- Assume current profile if profileId is omitted
	profileId = profileId or CurrentProfileId
	if (type(name) == "string" and name ~= "" and IsValidUserProfile(profileId)) then
		SV[profileId].name = name
	end
end

function GBP.CreateProfile( )
	-- While collisions are theoretically possible, the likelihood is vanishingly small
	local profileId = string.format("%08X", HashString(string.format("%s_%d", CHARID, GetGameTimeMilliseconds())))
	-- Empty profiles are populated by defaults when loaded by RefreshProfileSelection
	SV[profileId] = { name = GetString(SI_GBP_PROFILE_DEFAULT_NAME) }
	if (not GBP.IsDisabled()) then
		LCA.PopulateOptions(SV[profileId], CurrentProfile, true)
	end
	return profileId
end

function GBP.DeleteProfile( profileId )
	-- Assume current profile if profileId is omitted
	profileId = profileId or CurrentProfileId
	if (IsValidUserProfile(profileId)) then
		SV[profileId] = nil
		if (CurrentProfileId == profileId) then
			RefreshProfileSelection()
		end
	end
end

function GBP.IsNotUserProfile( profileId )
	-- Assume current profile if profileId is omitted
	return not IsValidUserProfile(profileId or CurrentProfileId)
end

function GBP.IsDisabled( )
	return CurrentProfileId == "disabled"
end


--------------------------------------------------------------------------------
-- APIs for panel settings
--------------------------------------------------------------------------------

function GBP.GetPanelSetting( settingName, abilityId )
	local panel = abilityId and CurrentProfile[abilityId]
	if (panel and (panel.overrideDefaults or IsSettingPanelSpecific(settingName)) and panel[settingName] ~= nil) then
		return panel[settingName]
	else
		return CurrentProfile.defaults[settingName]
	end
end

function GBP.SetPanelSetting( settingName, abilityId, value, refreshFunc )
	if (abilityId) then
		if (not CurrentProfile[abilityId]) then
			CurrentProfile[abilityId] = { }
		end
		CurrentProfile[abilityId][settingName] = value
		if (CurrentProfile[abilityId].overrideDefaults) then
			LCA.PopulateOptions(CurrentProfile[abilityId], CurrentProfile.defaults, true)
		end
	else
		CurrentProfile.defaults[settingName] = value
	end
	if (refreshFunc) then
		GBP[refreshFunc](abilityId)
	end
end

function GBP.GetPanelPosition( ... )
	return GBP.GetPanelSetting("pos", ...) or DEFAULT_POSITION
end

function GBP.SavePanelPosition( ... )
	GBP.SetPanelSetting("pos", ...)
	if (GBP.SavePanelPositionFollowup) then
		GBP.SavePanelPositionFollowup(...)
	end
end

function GBP.GetPanelEnablement( abilityId, key )
	return BitAnd(GBP.GetPanelSetting("enabled", abilityId) or 0, ENABLEMENT_FLAGS[key] or 0) > 0
end


--------------------------------------------------------------------------------
-- Common frontend UI bits
--------------------------------------------------------------------------------

GBP.CommonFrontend = { }
local CFE = GBP.CommonFrontend

function CFE.GetBitfieldFunction( settingName, selected, flag, refreshFunc )
	if (type(flag) == "string") then flag = ENABLEMENT_FLAGS[flag] end
	if (not refreshFunc) then
		return function( )
			return BitAnd(GBP.GetPanelSetting(settingName, selected.abilityId) or 0, flag) > 0
		end
	else
		return function( enabled )
			local flags = GBP.GetPanelSetting(settingName, selected.abilityId) or 0
			if (enabled) then
				flags = BitOr(flags, flag)
			else
				flags = BitAnd(flags, BitNot(flag, 8))
			end
			GBP.SetPanelSetting(settingName, selected.abilityId, flags, refreshFunc)
		end
	end
end

function CFE.GetAbilityDropdownChoices( isLAM )
	local choices = { }
	local choicesValues = (isLAM == true) and { } or nil

	for i, abilityId in ipairs(GBP.EFFECTS) do
		local name = zo_iconTextFormat(GBP.GetAbilityIcon(abilityId), "100%", "100%", LCA.GetAbilityName(abilityId))
		if (choicesValues) then
			choices[i] = name
			choicesValues[i] = abilityId
		else
			choices[i] = { name = name, data = abilityId }
		end
		if (i == 1 and not CFE.abilityId) then
			CFE.abilityId = abilityId
		end
	end

	return choices, choicesValues
end

function CFE.GetConditionalEnablementText( )
	local text = GBP.GetConditionalEnablement(CFE.abilityId)
	if (type(text) == "string") then
		return text
	elseif (type(text) == "number") then
		return GetString(text)
	else
		return GetString(SI_GBP_SETTING_ENABLED_C)
	end
end

function CFE.IsConditionalEnablementDisabled( )
	return GBP.IsDisabled() or not GBP.GetConditionalEnablement(CFE.abilityId)
end

function CFE.GetAbilityIdText( )
	return string.format("ID: %d", CFE.abilityId)
end

CFE.GetSupportedEffectsString = GetSupportedEffectsString
