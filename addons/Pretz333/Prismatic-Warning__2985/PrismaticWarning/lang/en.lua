local strings = {

  -- Alert --
  PRISMATICWARNING_ALERT = "Prismatic",
  PRISMATICWARNING_EQUIP_NOW = "Equip one now",
  PRISMATICWARNING_UNEQUIP_NOW = "Unequip it now",
  PRISMATICWARNING_AUTO_SWAP_FAILED = "Failed to auto-equip, should ",
  
  -- Chat Only --
  PRISMATICWARNING_AUTO_SWAP_SUCCESS = "Successfully auto-equipped",
  PRISMATICWARNING_NO_PRISMATIC_IN_INV = "There is no prismatic in your inventory",
  PRISMATICWARNING_WATCHING = "You will need a prismatic weapon, you should grab one now",
  PRISMATICWARNING_DONE_WATCHING = "There are no more changes this dungeon",
  
  -- Menu --
  PRISMATICWARNING_MENU_OSA = "On-Screen Alert",
  PRISMATICWARNING_MENU_HIDE_OSA = "Hide On-Screen Alert",
  PRISMATICWARNING_MENU_HIDE_OSA_TT = "When selected, the on-screen alert will never display",
  PRISMATICWARNING_MENU_SHOW_OSA = "Show On-Screen Alert Right Now",
  PRISMATICWARNING_MENU_SHOW_OSA_TT = "When selected, the on-screen alert will pop up so you can reposition it and test other settings",
  PRISMATICWARNING_MENU_OSA_IN_COMBAT = "Hide On-Screen Alert In Combat",
  PRISMATICWARNING_MENU_OSA_IN_COMBAT_TT = "When selected, the on-screen alert will not display while in combat",
  PRISMATICWARNING_MENU_LOCK_OSA = "Lock Alert Position",
  PRISMATICWARNING_MENU_LOCK_OSA_TT = "When selected, you will be unable to move the alert",
  PRISMATICWARNING_MENU_FONT = "Font Name",
  PRISMATICWARNING_MENU_FONT_TT = "Font name for the alert",
  PRISMATICWARNING_MENU_FONT_SIZE = "Alert Font Size",
  PRISMATICWARNING_MENU_FONT_SIZE_TT = 'Font size for the word "Prismatic"',
  PRISMATICWARNING_MENU_INFO_FONT_SIZE = "Info Font Size",
  PRISMATICWARNING_MENU_INFO_FONT_SIZE_TT = 'Font Size for the text under the word "Prismatic", typically "EQUIP ONE NOW" or "UNEQUIP IT NOW"',
  PRISMATICWARNING_MENU_OUTLINE = "Outline",
  PRISMATICWARNING_MENU_OUTLINE_TT = "Font Outline to be used on the on-screen alert",
  PRISMATICWARNING_MENU_COLOR = "On-Screen Alert Color",
  PRISMATICWARNING_MENU_COLOR_TT = "Changes the color of the on-screen alert",
  
  PRISMATICWARNING_MENU_WHEN = "When to Alert",
  PRISMATICWARNING_MENU_VET = "Only Alert On Veteran Difficulty",
  PRISMATICWARNING_MENU_VET_TT = "When selected, you will only be alerted to equip and unequip a prismatic when on veteran difficulty",
  PRISMATICWARNING_MENU_DUNGEONS = "Alert in Dungeons",
  PRISMATICWARNING_MENU_DUNGEONS_TT = "When selected, you will be alerted to equip and unequip a prismatic in dungeons",
  PRISMATICWARNING_MENU_P_DUNGEONS = "Alert in Partial Dungeons",
  PRISMATICWARNING_MENU_P_DUNGEONS_TT = "When selected, you will be alerted to equip and unequip a prismatic in dungeons where you use a prismatic for some, but not all, of the dungeon",
  PRISMATICWARNING_MENU_ARENAS = "Alert in Arenas",
  PRISMATICWARNING_MENU_ARENAS_TT = "When selected, you will be alerted to equip and unequip a prismatic in arenas",
  PRISMATICWARNING_MENU_TRIALS = "Alert in Trials",
  PRISMATICWARNING_MENU_TRIALS_TT = "When selected, you will be alerted to equip and unequip a prismatic in trials",
  PRISMATICWARNING_MENU_MAGDD = "Alert if Magicka Damage Dealer",
  PRISMATICWARNING_MENU_MAGDD_TT = "When selected, you will be alerted to equip and unequip a prismatic when your LFG role is set to a damage dealer and your maximum magicka is greater than your stamina",
  PRISMATICWARNING_MENU_STAMDD = "Alert if Stamina Damage Dealer",
  PRISMATICWARNING_MENU_STAMDD_TT = "When selected, you will be alerted to equip and unequip a prismatic when your LFG role is set to a damage dealer and your maximum stamina is greater than your magicka",
  PRISMATICWARNING_MENU_TANK = "Alert if Tank",
  PRISMATICWARNING_MENU_TANK_TT = "When selected, you will be alerted to equip and unequip a prismatic when your LFG role is set to a tank",
  PRISMATICWARNING_MENU_HEAL = "Alert if Healer",
  PRISMATICWARNING_MENU_HEAL_TT = "When selected, you will be alerted to equip and unequip a prismatic when your LFG role is set to a healer",
  PRISMATICWARNING_MENU_UNDER_FIFTY = "Alert if Under Level 50",
  PRISMATICWARNING_MENU_UNDER_FIFTY_TT = "When selected, you will be alerted to equip and unequip a prismatic when on characters under level 50",
  
  PRISMATICWARNING_MENU_OTHER = "Other Settings",
  PRISMATICWARNING_MENU_CHAT = "Alert to Chat",
  PRISMATICWARNING_MENU_CHAT_TT = "When selected, you will be alerted to equip and unequip a prismatic in the active chat tab",
  PRISMATICWARNING_MENU_RR = "Refresh Rate",
  PRISMATICWARNING_MENU_RR_TT = "Changes how often (in milliseconds) the addon checks if you should equip a prismatic weapon",
  PRISMATICWARNING_MENU_RR_WARN = "Lower numbers may affect performance and higher numbers may tell you to equip a prismatic too late",
  PRISMATICWARNING_MENU_AUTO_SWAP = "Auto-Equip To",
  PRISMATICWARNING_MENU_AUTO_SWAP_TT = 'The addon will attempt to automatically equip the prismatic weapon to the bar you choose. "Don\'t" will not attempt to auto-equip',
  PRISMATICWARNING_MENU_AUTO_SWAP_WARN = "In order for auto-equipping to work, the prismatic weapon must be in your inventory",
  PRISMATICWARNING_MENU_FRONT_BAR = "Front bar",
  PRISMATICWARNING_MENU_BACK_BAR = "Back bar",
  PRISMATICWARNING_MENU_DONT = "Don't",
  PRISMATICWARNING_MENU_DEBUG = "Debug Alerts",
  PRISMATICWARNING_MENU_DEBUG_TT = "When selected, debug alerts will be printed to chat",
}

for id, val in pairs(strings) do
  ZO_CreateStringId(id, val)
  SafeAddVersion(id, 1)
end