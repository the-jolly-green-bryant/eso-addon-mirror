local ADDON_NAME  = "Q_Q"

local ADDON_ICONS_PATH = "/Q_Q/icons/"

local ADDON_ICONS = {
	--Dual wield
	"ability_dualwield_004_a.dds",
	--Destro
	"ability_destructionstaff_011b.dds",
	--Fighter's Guild
	"ability_fightersguild_002_b.dds",
	--Resto
	"ability_restorationstaff_001_a.dds",
	"ability_restorationstaff_001_b.dds",
	"ability_restorationstaff_002a.dds",
	"ability_restorationstaff_002b.dds",
	"ability_restorationstaff_003_a.dds",
	"ability_restorationstaff_003_b.dds",
	"ability_restorationstaff_004a.dds",
	"ability_restorationstaff_004b.dds",
	"ability_restorationstaff_005_b.dds",
	--Arcanist
	"ability_arcanist_001_a.dds",
	"ability_arcanist_001_b.dds",
	"ability_arcanist_002_a.dds",
	"ability_arcanist_002_b.dds",
	"ability_arcanist_003_a.dds",
	"ability_arcanist_003_b.dds",
	"ability_arcanist_004_a.dds",
	"ability_arcanist_004_b.dds",
	"ability_arcanist_005_a.dds",
	"ability_arcanist_005_b.dds",
	"ability_arcanist_006_b.dds",

	--DK
	"ability_dragonknight_003_a.dds",
	"ability_dragonknight_003_b.dds",
	"ability_dragonknight_013_stonefist_b.dds",
	"ability_dragonknight_004_a.dds",
	"ability_dragonknight_004_b.dds",
	--Necro
	"ability_necromancer_008_a.dds",
	--Templar
	"ability_templar_extended_ritual.dds";
	--Sorc
	--NB
	"ability_nightblade_017_a.dds",
	--Warden
	"ability_warden_001_a.dds",
	--Undaunted
	"ability_undaunted_001.dds",
	"ability_undaunted_001_a.dds",
	"ability_undaunted_001_b.dds",
	"ability_undaunted_002_b.dds",
	"ability_undaunted_004.dds",
	"ability_undaunted_004_a.dds",
	"ability_undaunted_004b.dds",
	
	--Assault
	"ability_ava_001_a.dds",
	"ability_ava_001_b.dds",
	"ability_ava_006_a.dds",
	"ability_ava_006_b.dds",
	"ability_ava_resolving_vigor.dds",
	"ability_ava_echoing_vigor.dds",
	--Support
}

-- Function to initialize icons
local function InitializeIcons()
    if AbilityIconsFramework and AbilityIconsFramework.AddCustomIconPack then
        -- Add the custom icon pack
        AbilityIconsFramework.AddCustomIconPack(ADDON_ICONS_PATH, ADDON_ICONS)
    else
        d("AbilityIconsFramework not found or incompatible!")
    end
end


-- Initialize icons when the addon is loaded
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, function(_, addonName)
    if addonName ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
    InitializeIcons()
end) 
