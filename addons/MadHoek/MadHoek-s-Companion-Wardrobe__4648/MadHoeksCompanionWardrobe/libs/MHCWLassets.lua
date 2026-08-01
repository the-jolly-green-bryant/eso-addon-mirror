-- ============================================================================
-- Companion Wardrobe
-- Asset Registry
--
-- Responsibilities:
-- - Define texture paths used by the addon.
-- - Define button texture sets.
-- - Centralize visual asset references for UI construction.
-- ============================================================================
if MHCWL == nil then MHCWL = {} end
local MHCWL = MHCWL

MHCWL.BUTTONS = {
    cw = {
        up = "/MadHoeksCompanionWardrobe/assets/cw_up.dds",
        over = "/MadHoeksCompanionWardrobe/assets/cw_over.dds",
        down = "/MadHoeksCompanionWardrobe/assets/cw_down.dds",
    },
    close = {
        up = "/esoui/art/buttons/decline_up.dds",
        over = "/esoui/art/buttons/decline_over.dds",
        down = "/esoui/art/buttons/decline_down.dds",
    },
    settings = {
        up = "/esoui/art/skillsadvisor/advisor_tabicon_settings_up.dds",
        over = "/esoui/art/skillsadvisor/advisor_tabicon_settings_over.dds",
        down = "/esoui/art/skillsadvisor/advisor_tabicon_settings_down.dds",
    },
    add = {
        up = "/esoui/art/tutorial/minimap_zoomplus_up.dds",
        over = "/esoui/art/tutorial/minimap_zoomplus_up.dds",
        down = "/esoui/art/tutorial/minimap_zoomplus_up.dds",
    },
    save = {
        up = "/esoui/art/tutorial/tutorial_illo_saveedit.dds",
        over = "/esoui/art/tutorial/tutorial_illo_saveedit.dds",
        down = "/esoui/art/tutorial/tutorial_illo_saveedit.dds",
    },
    delete = {
        up = "/esoui/art/tutorial/minimap_zoomminus_up.dds",
        over = "/esoui/art/tutorial/minimap_zoomminus_up.dds",
        down = "/esoui/art/tutorial/minimap_zoomminus_up.dds",
    },
    inspect = {
        up = "/esoui/art/tutorial/lfg_tabicon_grouptools_up.dds",
        over = "/esoui/art/tutorial/lfg_tabicon_grouptools_up.dds",
        down = "/esoui/art/tutorial/lfg_tabicon_grouptools_up.dds",
    },
    rename = {
        up = "/esoui/art/market/keyboard/giftmessageicon_up.dds",
        over = "/esoui/art/market/keyboard/giftmessageicon_up.dds",
        down = "/esoui/art/market/keyboard/giftmessageicon_up.dds",
    },
    sort = {
        up = "/esoui/art/addons/gamepad/gp_mod_listing_category_beta.dds",
        over = "/esoui/art/addons/gamepad/gp_mod_listing_category_beta.dds",
        down = "/esoui/art/addons/gamepad/gp_mod_listing_category_beta.dds",
    },
    locked = {
        up = "/esoui/art/miscellaneous/locked_up.dds",
        over = "/esoui/art/miscellaneous/locked_over.dds",
        down = "/esoui/art/miscellaneous/locked_down.dds",
    },
    unlocked = {
        up = "/esoui/art/miscellaneous/unlocked_up.dds",
        over = "/esoui/art/miscellaneous/unlocked_over.dds",
        down = "/esoui/art/miscellaneous/unlocked_down.dds",
    },
    checkbox = {
        checked = "/esoui/art/buttons/checkbox_white_checked.dds",
        unchecked = "/esoui/art/buttons/checkbox_white_unchecked.dds",
        over = "/esoui/art/buttons/checkbox_white_indeterminate.dds",
    },
    pageLeft = {
        up = "/esoui/art/buttons/leftarrow_up.dds",
        over = "/esoui/art/buttons/leftarrow_over.dds",
        down = "/esoui/art/buttons/leftarrow_down.dds",
    },
    pageRight = {
        up = "/esoui/art/buttons/rightarrow_up.dds",
        over = "/esoui/art/buttons/rightarrow_over.dds",
        down = "/esoui/art/buttons/rightarrow_down.dds",
    },
    favorite = {
        up = "/esoui/art/collections/favorite_staronly.dds",
        over = "/esoui/art/collections/favorite_staronly.dds",
        down = "/esoui/art/collections/favorite_staronly.dds",
    },
    warning = {
        up = "/esoui/art/miscellaneous/eso_icon_warning.dds",
        over = "/esoui/art/miscellaneous/eso_icon_warning.dds",
        down = "/esoui/art/miscellaneous/eso_icon_warning.dds",
    },
    loadoutFilterNormal = {
        up = "/esoui/art/treeicons/collection_indexicon_weapons_up.dds",
        over = "/esoui/art/treeicons/collection_indexicon_weapons_up.dds",
        down = "/esoui/art/treeicons/collection_indexicon_weapons_up.dds",
    },
    dye = {
        up = "/esoui/art/dye/dyes_categoryicon_up.dds",
        over = "/esoui/art/dye/dyes_categoryicon_over.dds",
        down = "/esoui/art/dye/dyes_categoryicon_down.dds",
    },
    view = {
        up = "/esoui/art/miscellaneous/keyboard/visible_up.dds",
        over = "/esoui/art/miscellaneous/keyboard/visible_over.dds",
        down = "/esoui/art/miscellaneous/keyboard/visible_down.dds",
    },
    inspectArmor = {
        up = "/esoui/art/crafting/smithing_tabicon_armorset_up.dds",
        over = "/esoui/art/crafting/smithing_tabicon_armorset_over.dds",
        down = "/esoui/art/crafting/smithing_tabicon_armorset_down.dds",
    },
    inspectWeapons = {
        up = "/esoui/art/crafting/smithing_tabicon_weaponset_up.dds",
        over = "/esoui/art/crafting/smithing_tabicon_weaponset_over.dds",
        down = "/esoui/art/crafting/smithing_tabicon_weaponset_down.dds",
    },
    inspectSkills = {
        up = "/esoui/art/mainmenu/menubar_skills_up.dds",
        over = "/esoui/art/mainmenu/menubar_skills_over.dds",
        down = "/esoui/art/mainmenu/menubar_skills_down.dds",
    },
    squareButton = {
        up = "/esoui/art/tribute/tributeendturnbutton_normal.dds",
        over = "/esoui/art/tribute/tributeendturnbutton_mouseover.dds",
        down = "/esoui/art/tribute/tributeendturnbutton_pressed.dds",
    },
}

MHCWL.TEXTURES = {
    logo = "/MadHoeksCompanionWardrobe/assets/mh.dds",
    listActive = "/esoui/art/dye/gamepad/listitem_highlight.dds",
    -- silhouettes
    silhouetteHumanMale = "/esoui/art/characterwindow/silhouette_human_male.dds",
    silhouetteHumanFemale = "/esoui/art/characterwindow/silhouette_human_female.dds",
    silhouetteKhajiitMale = "/esoui/art/characterwindow/silhouette_khajiit_male.dds",
    silhouetteKhajiitFemale = "/esoui/art/characterwindow/silhouette_khajiit_female.dds",
    silhouetteArgonianMale = "/esoui/art/characterwindow/silhouette_argonian_male.dds",
    silhouetteArgonianFemale = "/esoui/art/characterwindow/silhouette_argonian_female.dds",
    -- gear UI
    gearHead = "/esoui/art/characterwindow/gearslot_head.dds",
    gearShoulders = "/esoui/art/characterwindow/gearslot_shoulders.dds",
    gearChest = "/esoui/art/characterwindow/gearslot_chest.dds",
    gearHands = "/esoui/art/characterwindow/gearslot_hands.dds",
    gearWaist = "/esoui/art/characterwindow/gearslot_belt.dds",
    gearLegs = "/esoui/art/characterwindow/gearslot_legs.dds",
    gearFeet = "/esoui/art/characterwindow/gearslot_feet.dds",
    gearNeck = "/esoui/art/characterwindow/gearslot_neck.dds",
    gearRing = "/esoui/art/characterwindow/gearslot_ring.dds",
    gearMainHand = "/esoui/art/characterwindow/gearslot_mainhand.dds",
    gearOffHand = "/esoui/art/characterwindow/gearslot_offhand.dds",
    -- skill UI
    skillBarBG = "/esoui/art/tutorial/examples/help-abilitybar_empty.dds",
    ultimateFrameBG = "/esoui/art/actionbar/ability_ultimate_framedecobg.dds",
    ultimateLockedBG = "/esoui/art/progression/abilityframe_empty.dds",
    ultimateLockedOverlay = "/esoui/art/characterwindow/weaponswap_locked.dds",
}