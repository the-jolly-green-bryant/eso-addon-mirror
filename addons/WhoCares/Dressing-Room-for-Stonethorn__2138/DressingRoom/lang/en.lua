ZO_CreateStringId("SI_BINDING_NAME_DRESSINGROOM_TOGGLE", "Show/Hide Window")
for i = 1, 24 do
  ZO_CreateStringId("SI_BINDING_NAME_DRESSINGROOM_SET_"..i, "Use Set "..i)
end
ZO_CreateStringId("SI_BINDING_NAME_DRESSINGROOM_UNDRESS", "Unequip All Gear")
ZO_CreateStringId("SI_BINDING_NAME_DRESSINGROOM_PAGE_SELECT_PREVIOUS", "Select Previous Page")
ZO_CreateStringId("SI_BINDING_NAME_DRESSINGROOM_PAGE_SELECT_NEXT", "Select Next Page")
ZO_CreateStringId("SI_BINDING_NAME_DRESSINGROOM_CANCEL_PENDING_LOAD", "Cancel Pending Load")
ZO_CreateStringId("SI_BINDING_NAME_DRESSINGROOM_TOGGLE_GROUP_ROLE", "Toggle Group Role")

DressingRoom._msg = {
  weaponType = {
    [WEAPONTYPE_AXE] = "Axe",
    [WEAPONTYPE_BOW] = "Bow",
    [WEAPONTYPE_DAGGER] = "Dagger",
    [WEAPONTYPE_FIRE_STAFF] = "Fire Staff",
    [WEAPONTYPE_FROST_STAFF] = "Frost Staff",
    [WEAPONTYPE_HAMMER] = "Hammer",
    [WEAPONTYPE_HEALING_STAFF] = "Healing Staff",
    [WEAPONTYPE_LIGHTNING_STAFF] = "Lightning Staff",
    [WEAPONTYPE_NONE] = "None",
    [WEAPONTYPE_RUNE] = "Rune",
    [WEAPONTYPE_SHIELD] = "Shield",
    [WEAPONTYPE_SWORD] = "Sword",
    [WEAPONTYPE_TWO_HANDED_AXE] = "Battle Axe",
    [WEAPONTYPE_TWO_HANDED_HAMMER] = "Maul",
    [WEAPONTYPE_TWO_HANDED_SWORD] = "Greatsword",
  },
  
  loadingSet = "Loading set %s...",
  skillBarSaved = "Skill set %d bar %d saved",
  skillBarLoaded = "Skill set %d bar %d loaded",
  skillBarDeleted = "Skill set %d bar %d deleted",
  gearSetSaved = "Gear set %d saved",
  gearSetLoaded = "Gear set %d loaded",
  gearSetDeleted = "Gear set %d deleted",
  noGearSaved = "No gear saved for set %d",

  options = {
    reloadUIWarning = "reload UI required",
    autoReloadUIWarning = "This option will reload your UI automatically!",
    reloadUI = "Reload UI",
    accountWideSettings = {
      name = "Account-wide settings",
      tooltip = "Use the same behaviour and UI settings for each character\nChanging this will not affect your saved presets",
    },
    sectionBehaviour = "Behaviour settings",
    autoRechargeWeapons = {
      name = "Automatically recharge weapons",
      tooltip = "When your weapon enchantment runs out, automatically use a soul gem to recharge it",
    },
    clearEmptyGear = {
      name = "Unequip empty gear slots",
      tooltip = "When loading a gear set with empty slots, unequip previously used items",
    },
    clearEmptyPoisons = {
      name = "Unequip empty poison slots",
      tooltip = "When loading a gear set with weapons but no poisons, unequip previously used poisons",
    },
    clearEmptySkill = {
      name = "Clear empty skill slots",
      tooltip = "When loading a skill set with empty slots, unequip previously used skills",
    },
    ignoreAppearanceSlot = {
      name = "Ignore appearance slot",
      tooltip = "Do not equip or unequip disguises or guild tabards",
    },
    enableOutfits = {
      name = "Save/load outfits",
      tooltip = "Save and load the active outfit with gear presets",
    },
    disableInCombat = {
      name = "Disable in combat",
      tooltip = "Disable loading skill and/or gear sets while in combat, instead of postponing the action until combat has ended",
    },
    sectionUI = "UI settings",
    showNotificationArea = {
      name = "Show notification area",
      tooltip = "Display the notification area and the name of the currently loaded preset",
    },
    lockNotificationArea = {
      name = "Lock notification area",
      tooltip = "Lock the UI position of the notification area",
    },
    activeBarOnly = {
      name = "Skill set buttons for active bar only",
      tooltip = "Only shows the skill set buttons for the currently active bar",
    },
    lockWindowPosition = {
      name = "Lock Window Position",
      tooltip = "Lock the window position so it can't be dragged",
    },
    fontSize = {
      name = "Font Size",
      tooltip = "Interface font size",
    },
    btnSize = {
      name = "Skill icon size",
      tooltip = "Size of skill icons",
    },
    columnMajorOrder = {
      name = "Sort sets by column first",
      tooltip = "Use column major (vertical) order instead of row major (horizontal) order for sets in the interface",
    },
    openWithSkillsWindow = {
      name = "Show with Skills window",
      tooltip = "Automatically show the interface when opening the Skills window",
    },
    openWithInventoryWindow = {
      name = "Show with Inventory window",
      tooltip = "Automatically show the interface when opening the Inventory window",
    },
    numRows = {
      name = "Number of rows",
      tooltip = "Number of sets in a column of the window",
    },
    numCols = {
      name = "Number of columns",
      tooltip = "Number of sets in a row of the window",
    },
    showChatMessages = {
      name = "Show chat messages",
      tooltip = "Show a message in chat when saving, equipping or deleting a gear set or an action bar",
    },
    singleBarToCurrent = {
      name = "Load single bar sets to active bar",
      tooltip = "Loading a set with a single action bar and no gear will update the active action bar and ignore the empty bar",
    },
    autoCloseOnMovement = {
      name = "Auto close on movement",
      tooltip = "Automatically close the Dressing Room window if you start moving",
    },
    enablePages = {
      name = "Enable pages",
      tooltip = "Disabling this will not clear your existing pages, they will only be hidden until you enable this again",
    },
    confirmPageDelete = {
      name = "Confirm page delete",
      tooltip = "Display a confirmation prompt when deleting a page",
    },
    alwaysChangePageOnZoneChanged = {
      name = "Always change page on zone change",
      tooltip = "If there is no preset with the name of the new zone that you arrived in, load the default (first) page",
    },
    useOldUI = {
      name = "Use old UI",
      tooltip = "Use the original page picker",
    },
    roleSpecificPresets = {
      name = "Enable role-specific pages",
      tooltip = "Display separate alternative pages for each group role",
    },
    roleFromLFGTool = {
      name = "Auto-select role by LFG tool",
      tooltip = "Select the appropriate alternative page automatically upon changing your group role in the LFG tool",
    },
    autoSaveChangesOnClose = {
      name = "Auto save changes on window close",
      tooltip = "Automatically save all your changes when you close the Dressing Room window.\n|cff8000Note that you always need to reload UI or log out to save data to disk.|r",
    },
    expertFeatures = "Expert features",
    enableExpertFeatures = {
      name = "Enable expert features",
      tooltip = "I have read all warnings, and made a backup of my Dressing Room SavedVariables",
    },
    changeDefaultRole = {
      name = "Change default role",
      tooltip = "You can use this if you selected a wrong default role.",
    },
    exchangePages = {
      name = "Exchange pages",
      tooltip = "This will *swap* all your \"%s\" presets with the selected one.",
    },
    purgeCharacterData = {
      name = "|cff0000Purge character data|r",
      tooltip = "Delete all pages and presets, and reset all settings for this character\n\nKey bindings will not be changed",
    },
    importPresetsFromCharacter = {
      name = "Import presets from character",
      tooltip = "This will not delete your current presets if the option below isn't enabled, only add the new pages to the end of the list.",
    },
    purgePresetsBeforeImporting = {
      name = "Purge presets before importing",
      tooltip = "Copy presets from another character without keeping the old ones.",
    },
    importAlphaGear = "|cff0000Import from AlphaGear|r",
    importAlphaGearWarning = "|cff0000WARNING - EXPERIMENTAL FEATURE! - read carefully before pressing this button!|r\n\nThis will delete ALL your existing Dressing Room pages and overwrite ALL your existing Dressing Room presets (and key bindings if you choose the option below). If you have already been using this addon, please backup your saved variables file before using this. All your current Dressing Room data WILL be overwritten.\n\nThis version is compatible with '|cFFAA33AlphaGear 2 %s|r', and it is not guaranteed to work with any other version. Use at your own risk.%s\n\nThis option will also reload your UI automatically.",
    importAlphaGearVersionMismatchWarning = "Your installed version:",
    importAlphaGearNotDetected = "AlphaGear not detected, please enable it in order to use this option",
    importAlphaGearRebindKeys = {
      name = "Rebind keys",
      tooltip = "It is recommended leaving this OFF and manually checking your presets first, before setting it to ON",
    },
  },

  setupWindowText = "Select this character's preferred role:",
  setupWindowText2 = "This can be changed later in the add-on settings.",

  confirmDeletePagePromptOld = "Really delete page?",
  confirmDeletePagePrompt = "Really delete page \"<<1>>\"?",
  editPageNamePrompt = "Enter new name for \"<<1>>\":",

  changesSave = "Confirm Changes",
  changesUndo = "Cancel All Changes",

  barBtnText = "Click to load this single skill bar\nShift + Click to save\nCtrl + Click to delete",
  gearBtnText = "Click to dress this gear-set\nShift + Click to save\nCtrl + Click to delete",
  setBtnText = "Click to dress this gear-set and load both skill bars",

  bttnUndressText = "Undress",
  undressClicked = "Unequipping all gear",

  set = "Set",
  usedBy = "Used by:",

  rechargedWeapon = "Recharged |cff0000%s|r using |c00ff00%s|r",

  waitingForWeaponSwap = "Waiting for bar swap",
  waitingForOutOfCombat = "Waiting for out of combat",
}

