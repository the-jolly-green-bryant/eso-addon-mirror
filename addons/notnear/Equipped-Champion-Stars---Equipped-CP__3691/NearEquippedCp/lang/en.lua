local warfare              = GetChampionDisciplineName(1)
local fitness              = GetChampionDisciplineName(2)
local craft                = GetChampionDisciplineName(3)

local strings = {

    NEAREC_Toggle               = 'Toggle window',
    NEAREC_Toggle_a             = 'Toggle show all',
    NEAREC_Toggle_c             = 'Toggle show ' .. craft,
    NEAREC_Toggle_w             = 'Toggle show ' .. warfare,
    NEAREC_Toggle_f             = 'Toggle show ' .. fitness,
    NEAREC_Toggle_inCombat      = 'Toggle hide in combat',
    NEAREC_Toggle_inMenu        = 'Toggle hide in menus',
    NEAREC_Toggle_align         = 'Toggle text alignment (left/right)',
    NEAREC_Toggle_lockui        = 'Toggle lock UI',

    NEAREC_am_type_name                 = "Account wide settings",

    NEAREC_am_show_all_name             = 'Show all',
    NEAREC_am_show_craft_name           = 'Show ' .. craft,
    NEAREC_am_show_warfare_name         = 'Show ' .. warfare,
    NEAREC_am_show_fitness_name         = 'Show ' .. fitness,

    NEAREC_am_hide_inMenu_name          = 'Hide in menus',
    NEAREC_am_hide_inCombat_name        = 'Hide in combat',

    NEAREC_am_align_name                = 'Text alignment',
    NEAREC_am_align_left                = 'Left',
    NEAREC_am_align_right               = 'Right',

    NEAREC_am_lock_name                 = 'Lock UI',
    NEAREC_am_resetpos_name             = 'Reset position',
    NEAREC_am_resetpos_warning          = 'Will reset the window\'s position but keep on the left/right side',

    NEAREC_am_profile_toggle_name       = "Enable profile editing",
    NEAREC_am_profile_toggle_tooltip    = "Currently disabled since there is no other data available.",
    NEAREC_am_profile_selector_name     = "Profile selector",
    NEAREC_am_profile_copy_name         = "Copy data",
    NEAREC_am_profile_copy_warning      = "Will overwrite data for current profile with the selected one and reload the UI",
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
