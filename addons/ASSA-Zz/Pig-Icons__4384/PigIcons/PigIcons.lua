local ADDON_NAME  = "PigIcons"
local LAM2 = LibAddonMenu2

local SAVEDVARS_VERSION = 1
local DEFAULTS = {
	resolutionChoice = "256", -- "Flat", "64", "128", "256"
}

local PigIcons_SV = nil

local function GetIconsResolution()
	if PigIcons_SV and PigIcons_SV.resolutionChoice and PigIcons_SV.resolutionChoice ~= "Flat" then
		return tostring(PigIcons_SV.resolutionChoice)
	end
	return nil
end

local function GetAddOnIconsPath()
	local res = GetIconsResolution()
	if res == nil then
		return "/PigIcons/icons/"
	end
	return "/PigIcons/icons/" .. res .. "/"
end

local ADDON_ICONS = {
    "ability_2handed_002_a.dds",
    "ability_2handed_003_a.dds",
    "ability_arcanist_003_a.dds",
    "ability_arcanist_004_b.dds",
    "ability_arcanist_005_a.dds",
    "ability_arcanist_006_b.dds",
    "ability_arcanist_007_a.dds",
    "ability_arcanist_008_b.dds",
    "ability_arcanist_011_b.dds",
    "ability_arcanist_012_a.dds",
    "ability_ava_001_a.dds",
    "ability_ava_003_a.dds",
	"ability_ava_005_a.dds",
    "ability_ava_006_a.dds",
    "ability_ava_echoing_vigor.dds",
    "ability_ava_proximity_detonation.dds",
    "ability_ava_resolving_vigor.dds",
    "ability_ava_revealing_flare.dds",
    "ability_bow_002_b.dds",
    "ability_bow_003_a.dds",
    "ability_destructionstaff_001a.dds",
    "ability_destructionstaff_002b.dds",
    "ability_destructionstaff_003_b.dds",
    "ability_destructionstaff_004_b.dds",
    "ability_destructionstaff_008_b.dds",
    "ability_destructionstaff_011b.dds",
    "ability_destructionstaff_013_b.dds",
    "ability_destructionstaff_015_b.dds",
    "ability_dragonknight_001_b.dds",
    "ability_dragonknight_002_a.dds",
    "ability_dragonknight_003_a.dds",
    "ability_dragonknight_004_b.dds",
    "ability_dragonknight_006_b.dds",
    "ability_dragonknight_007_b.dds",
    "ability_dragonknight_015_a.dds",
    "ability_dragonknight_016a.dds",
    "ability_dragonknight_016b.dds",
    "ability_dragonknight_017b.dds",
    "ability_dragonknight_018_a.dds",
    "ability_dualwield_004_a.dds",
	"ability_dualwield_004_b.dds",
    "ability_dualwield_005_a.dds",
    "ability_fightersguild_002_b.dds",
    "ability_fightersguild_004_a.dds",
    "ability_fightersguild_005_a.dds",
    "ability_grimoire_support_magic.dds",
    "ability_grimoire_support_flame.dds",
    "ability_grimoire_support_shock.dds",
    "ability_mageguild_001_b.dds",
    "ability_mageguild_002_b.dds",
    "ability_mageguild_005_a.dds",
    "ability_mageguild_005_b.dds",
    "ability_necromancer_002_a.dds",
    "ability_necromancer_002_a_blackedout.dds",
    "ability_necromancer_003_b.dds",
    "ability_necromancer_004_a.dds",
    "ability_necromancer_005_b.dds",
    "ability_necromancer_006_a.dds",
    "ability_necromancer_007_a.dds",
    "ability_necromancer_011_b.dds",
	"ability_necromancer_002_b.dds",
	"ability_necromancer_002_b_blackedout.dds",
    "ability_nightblade_005_a.dds",
	"ability_nightblade_018_b.dds",
    "ability_nightblade_007_a.dds",
    "ability_nightblade_007_b.dds",
    "ability_nightblade_007_c.dds",
    "ability_nightblade_008_b.dds",
    "ability_restorationstaff_002a.dds",
    "ability_restorationstaff_003_a.dds",
    "ability_restorationstaff_003_b.dds",
    "ability_restorationstaff_004b.dds",
    "ability_sorcerer_boundless_storm.dds",
    "ability_sorcerer_endless_atronachs.dds",
    "ability_sorcerer_explosive_curse.dds",
    "ability_sorcerer_lightning_matriarch.dds",
    "ability_sorcerer_lightning_matriarch_summoned.dds",
    "ability_sorcerer_speedy_familiar.dds",
    "ability_sorcerer_speedy_familiar_summoned.dds",
    "ability_sorcerer_storm_prey.dds",
    "ability_sorcerer_storm_prey_summoned.dds",
    "ability_sorcerer_streak.dds",
    "ability_sorcerer_thundering_presence.dds",
    "ability_sorcerer_unstable_fimiliar.dds",
    "ability_sorcerer_unstable_fimiliar_summoned.dds",
    "ability_templar_extended_ritual.dds",
    "ability_templar_over_exposure.dds",
    "ability_templar_power_of_the_light.dds",
    "ability_templar_purifying_light.dds",
    "ability_templar_solar_power.dds",
    "ability_templar_under_exposure.dds",
    "ability_templar_vampire_bane.dds",
    "ability_u26_vampire_03_b.dds",
    "ability_undaunted_001_a.dds",
    "ability_undaunted_002_b.dds",
    "ability_undaunted_004_a.dds",
    "ability_undaunted_004b.dds",
    "ability_warden_001_a.dds",
    "ability_warden_003_a.dds",
    "ability_warden_007_b.dds",
    "ability_warden_017.dds",
    "ability_warden_017_a.dds",
    "ability_warden_017_b.dds",
    "ability_warden_018_b.dds",
    "ability_warden_018_c.dds",
    "u38_ability_armor_ultimatetransfer.dds",
	"ability_grimoire_assault_physical.dds",
	"ability_nightblade_014_a.dds",
	"ability_arcanist_002_a.dds",
	"ability_arcanist_002_b.dds",
	"ability_arcanist_003_b.dds",
	"ability_arcanist_001_a.dds",
	"ability_arcanist_001_b.dds",
	"ability_dragonknight_004_a.dds",
	"ability_grimoire_assault_frost.dds",
	"ability_grimoire_dualwield_multitarget.dds",
	"ability_grimoire_soulmagic2_flame.dds",
	"ability_necromancer_003_a.dds",
	"ability_nightblade_017_a.dds",
	"ability_templar_breath_of_life.dds",
	"ability_templar_ritual_of_rebirth.dds",
	"ability_ava_006_b.dds"
}

local function InitializeSettings()
	PigIcons_SV = ZO_SavedVars:NewAccountWide("PigIcons_SavedVariables", SAVEDVARS_VERSION, nil, DEFAULTS)

	if not LAM2 then return end

	local panelData = {
		type = "panel",
		name = "Pig Icons",
		displayName = "|cFAACF4Pig|r Icons",
		author = "|c1072E3ASSA-Zz|r",
		version = tostring(GetAddOnVersion and GetAddOnVersion(ADDON_NAME) or ""),
		registerForRefresh = true,
		registerForDefaults = true,
	}

	LAM2:RegisterAddonPanel("PigIcons_Panel", panelData)

	local optionsData = {
		{
			type = "dropdown",
			name = "Icon pack resolution",
			tooltip = "Select which resolution folder Pig icons should use.",
			choices = { "64", "128", "256" },
			getFunc = function() return tostring(PigIcons_SV.resolutionChoice) end,
			setFunc = function(value) PigIcons_SV.resolutionChoice = value end,
			default = DEFAULTS.resolutionChoice,
			warning = "Requires /reloadui to apply the changes",
		},
		{
			type = "button",
			name = "Reload UI",
			width = "full",
			func = function() ReloadUI("ingame") end,
		},
	}

	LAM2:RegisterOptionControls("PigIcons_Panel", optionsData)
end

-- Function to initialize icons
local function InitializeIcons()
    if AbilityIconsFramework and AbilityIconsFramework.AddCustomIconPack then
        -- Add the custom icon pack
        AbilityIconsFramework.AddCustomIconPack(GetAddOnIconsPath(), ADDON_ICONS)
    else
        d("PigIcons: AbilityIconsFramework not found or incompatible!")
    end
end


-- Initialize icons when the addon is loaded
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, function(_, addonName)
	if addonName ~= ADDON_NAME then return end
	EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
	InitializeSettings()
	InitializeIcons()
end)