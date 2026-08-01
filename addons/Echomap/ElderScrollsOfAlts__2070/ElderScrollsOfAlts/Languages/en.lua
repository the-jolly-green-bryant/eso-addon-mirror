-- Every variable must start with this addon's unique ID, as each is a global.
local localization_strings = {
  --
  SI_ESOA_MESSAGE  = " addon is loaded",
  SI_ESOA_SHOW     = "Display ESOA",
  
  -- Keybindings
  SI_BINDING_NAME_ESOA_DISPLAY     = "Display ESOA",
  SI_BINDING_NAME_ESOA_DISPLAY2    = "Show Home",
  SI_BINDING_NAME_ESOA_DISPLAY3    = "Show Equip",
  SI_BINDING_NAME_ESOA_DISPLAY_NEXTVIEW = "Next View",
  
  --
  ESOA_NAME    = "name",
  ESOA_BAGS    = "Bags",
  ESOA_Unknown = "Unknown",
  --
  ESOA_MSG_PAUSED = "ESOA paused (per settings)",
  ESOA_MSG_ACTIVE = "ESOA saving player data",
  
  --Views
  ESOA_VIEW_HOME     ="Home",
  ESOA_VIEW_EQUIP    ="Equip",
  ESOA_VIEW_RESEARCH ="Research",
  ESOA_VIEW_SKILLS   ="Skills",
  --ESOA_VIEW_OTHER    ="Other",
  
  ESOA_GENDER_MALE   = "Male",
  ESOA_GENDER_FEMALE = "Female",
  ESOA_GENDER_OTHER  = "Other",
  ESOA_GENDER_MALE_S   = "M",
  ESOA_GENDER_FEMALE_S = "F",
  ESOA_GENDER_OTHER_S  = "O",

  ESOA_CLASS_DEFAULT      = "UK",
  ESOA_CLASS_DRAGONKNIGHT = "Dragonknight",
  ESOA_CLASS_SORCERER     = "Sorcerer",
  ESOA_CLASS_NIGHTBLADE   = "Nightblade",
  ESOA_CLASS_TEMPLAR      = "Templar",
  ESOA_CLASS_WARDEN       = "Warden",
  ESOA_CLASS_NECRO        = "Necromancer",
  ESOA_CLASS_ARCANIST     = "Arcanist",
  
  ESOA_CLASS_DEFAULT_ABBREV      = "UK",
  ESOA_CLASS_DRAGONKNIGHT_ABBREV = "DK",
  ESOA_CLASS_SORCERER_ABBREV     = "Sorc",
  ESOA_CLASS_NIGHTBLADE_ABBREV   = "Night",
  ESOA_CLASS_TEMPLAR_ABBREV      = "Temp",
  ESOA_CLASS_WARDEN_ABBREV       = "Ward",
  ESOA_CLASS_NECRO_ABBREV        = "Necr",
  ESOA_CLASS_ARCANIST_ABBREV     = "Arch",

  ESOA_RACE_UNKNOWN  = "UK",
  ESOA_RACE_HIGHELF  = "High Elf",    
  ESOA_RACE_WOODELF  = "Wood Elf",
  ESOA_RACE_KHAJIIT  = "Khajiit",
  ESOA_RACE_ARGONIAN = "Argonian",
  ESOA_RACE_DARKELF  = "Dark Elf",
  ESOA_RACE_NORD     = "Nord",
  ESOA_RACE_BRETON   = "Breton",
  ESOA_RACE_ORC      = "Orc",
  ESOA_RACE_REDGUARD = "Redguard",
  
  ESOA_RACE_HIGHELF_ABBREV   = "H.Elf",
  ESOA_RACE_HIGHELF_ABBREV2  = "High",
  ESOA_RACE_WOODELF_ABBREV   = "W.Elf",
  ESOA_RACE_WOODELF_ABBREV2  = "Wood",
  ESOA_RACE_KHAJIIT_ABBREV   = "Kaji",
  ESOA_RACE_KHAJIIT_ABBREV2  = "Kaj",
  ESOA_RACE_ARGONIAN_ABBREV  = "Argon",
  ESOA_RACE_ARGONIAN_ABBREV2 = "Argo",
  ESOA_RACE_NORD_ABBREV      = "Nord",
  ESOA_RACE_DARKELF_ABBREV   = "D.Elf",      
  ESOA_RACE_DARKELF_ABBREV2  = "Dark",
  ESOA_RACE_BRETON_ABBREV    = "Breton",
  ESOA_RACE_ORC_ABBREV       = "Orc",
  ESOA_RACE_REDGUARD_ABBREV  = "Red",
   
  --Abbrevs
  ESOA_ABBR_ALLY = "Aly",
  ESOA_ABBR_CLASS="Class",
  ESOA_ABBR_LVL  ="Lvl",
  ESOA_ABBR_G    ="G",
  ESOA_ABBR_RACE ="Race",
  ESOA_ABBR_ALC  ="Alc",
  ESOA_ABBR_SMTH ="Smth",
  ESOA_ABBR_CLTH ="Clth",
  ESOA_ABBR_ENCH ="Ench",
  ESOA_ABBR_JC   ="JC",
  ESOA_ABBR_PROV ="Prov",
  ESOA_ABBR_WOOD ="Wood",
  
  -- Trade Skills
  ESOA_FULL_SMTH = "Blacksmithing",
  ESOA_FULL_ALC  = "Alchemy",
  ESOA_FULL_WOOD = "Woodworking",
  ESOA_FULL_JC   = "Jewelry Crafting",
  ESOA_FULL_ENCH = "Enchanting",
  ESOA_FULL_PROV = "Provisioning",
  ESOA_FULL_CLTH = "Clothing",
  -- Skills
  ESOA_FULL_ASSAULT   = "Assault",
  ESOA_FULL_SUPPORT   = "Support",
  ESOA_FULL_LEGER     = "Legerdemain",
  ESOA_FULL_SOUL      = "Soul Magic",
  ESOA_FULL_WERE      = "Werewolf",
  ESOA_FULL_VAMP      = "Vampire",
  ESOA_FULL_FIGHT     = "Fighters Guild",
  ESOA_FULL_MAGE      = "Mages Guild",
  ESOA_FULL_UNDAUNTED = "Undaunted",
  ESOA_FULL_THIEF     = "Thieves Guild",
  ESOA_FULL_DARK      = "Dark Brotherhood",
  ESOA_FULL_PSIJ      = "Psijic Order",
  ESOA_FULL_SCRY      = "Scrying",
  ESOA_FULL_EXCAV     = "Excavation",
  -- Sub Skills
  ESOA_FULL_SUB_SOLV    = "Solvent Proficiency",
  ESOA_FULL_SUB_METAL   = "Metalworking",
  ESOA_FULL_SUB_TAIL    = "Tailoring",
  ESOA_FULL_SUB_ASPIMP  = "Aspect Improvement",
  ESOA_FULL_SUB_RECQUA  = "Recipe Quality",
  ESOA_FULL_SUB_WOOD    = "Woodworking",
  ESOA_FULL_SUB_ENGRAV  = "Engraver",
  ESOA_FULL_SUB_POTIMPR = "Potency Improvement",
  ESOA_FULL_SUB_RECIMPR = "Recipe Improvement",
  --
  
  ESOA_INFAMY_DISREPUTABLE = "Dispreputable",
  ESOA_INFAMY_FUGITIVE     = "Fugitive",
  ESOA_INFAMY_NOTORIOUS    = "Notorious",
  ESOA_INFAMY_UPSTANDING   = "Upstanding",

  ESOA_BITE_WERE_ABILITY  = "Bloodmoon",
  ESOA_BITE_WERE_COOLDOWN = "Bloodmoon Cooldown",
  ESOA_BITE_VAMP_ABILITY  = "Blood Ritual",
  ESOA_BITE_VAMP_COOLDOWN = "Blood Ritual Cooldown",

  ESOA_RESEARCH_AVAIL = "[avail]",
  ESOA_CRAFTING_QUEST_PREV = "Prev",
  
  ESOA_RAPPORT_1 = "Disdainful",
  ESOA_RAPPORT_2 = "Irritated",
  ESOA_RAPPORT_3 = "Wary",
  ESOA_RAPPORT_4 = "Cordial",
  ESOA_RAPPORT_5 = "Friendly",
  ESOA_RAPPORT_6 = "Close",
  ESOA_RAPPORT_7 = "Allied",
  ESOA_RAPPORT_8 = "Companion",
  --
  ESOA_ALLIANCE_NOTREADY = "Alliance rank wasn't loaded/saved, try again",
  ESOA_ALLIANCE_READY    = "Alliance rank WAS loaded/saved",
  --
  ESOA_KEY_SETTINGS_NOCONFIRM       = "No confirmation if you do this!",
  --
  ESOA_KEY_SETTINGS_SAVE_TITLE      = "Save these settings",
  ESOA_KEY_SETTINGS_SAVE_MSG        = "Save these as settings so they can be used later? (options/colors/views)",
  ESOA_KEY_SETTINGS_LOAD_TITLE      = "Load saved settings",
  ESOA_KEY_SETTINGS_LOAD_MSG        = "Load settings from saved profile? (options/colors/views)",
  --
  ESOA_SETTINGS_DD_VIEWENTRIES1_NAME   = "Select Entry(1)",
  ESOA_SETTINGS_DD_VIEWENTRIES2_NAME   = "Select Entry(2)",
  ESOA_SETTINGS_DD_VIEWENTRIES3_NAME   = "Select Entry(3)",
  ESOA_SETTINGS_DD_VIEWENTRIES_TT      = "Selected entry from (1) or (2) or (3) is copied to the nearby text field where you can copy and paste into a view.",
  ESOA_SETTINGS_ED_VIEWENTRIES_NAME    = "Copyable Entry for View",
  ESOA_SETTINGS_ED_VIEWENTRIES_TT      = "For easy copy and paste this into a the 'Edit View Data' field above.",
  ESOA_SETTINGS_ED_ALLVIEWENTRIES_NAME = "All Allowable Entries List",
  
  ESOA_SETTINGS_VIEW_CUSTOMCOLWIDTH_NAME = "Custom Column Widths",
  ESOA_SETTINGS_VIEW_CUSTOMCOLWIDTH_TT = "Use the name shown in the tooltip of the header you wish to set a width for, ie: Note:25. Each entry should be on it's own line. (Caps Matter)",
  ESOA_SETTINGS_VIEW_CUSTOMCOLWIDTH_SAVE_NAME = "Save Widths",
  ESOA_SETTINGS_VIEW_CUSTOMCOLWIDTH_SAVE_TT   = "Save Widths",
  
  ESOA_SETTINGS_SAVEBUTTON_NAME = "Save",
  ESOA_SETTINGS_SAVEBUTTON_TT   = "Save selected View!",
  ESOA_SETTINGS_TESTBUTTON_NAME = "Test",
  ESOA_SETTINGS_TESTBUTTON_TT   = "Test selected View",
  
  ESOA_SETTINGS_EDITVIEWDATA_NAME = "Edit View Data",
  ESOA_SETTINGS_EDITVIEWDATA_TT   = "Edit selected View's data here.",
  ESOA_SETTINGS_EDITVIEWNAME_NAME = "Edit View Name",
  ESOA_SETTINGS_EDITVIEWNAME_TT   = "Edit selected View's name here.",
  ESOA_SETTINGS_EDITVIEWSAVEALLOWODD_NM = "Allow Saving of odd {view items}",
  ESOA_SETTINGS_EDITVIEWSAVEALLOWODD_TT = "Allow none specific and checked view names, do not set to ON if you don't know what you are doing.",
  ESOA_SETTINGS_EDITVIEWDELETE_NAME = "Delete",
  ESOA_SETTINGS_EDITVIEWDELETE_TT = "Press to delete the selected 'Select View'!",
  ESOA_SETTINGS_EDITVIEWEDIT_NAME = "Edit",
  ESOA_SETTINGS_EDITVIEWEDIT_TT   = "Press to edit the selected 'Select View'!",
  ESOA_SETTINGS_EDITVIEWSELECT_NAME = "Select View for 'Edit' or 'Delete':",
  ESOA_SETTINGS_EDITVIEWSELECT_TT = "Select a View to edit or delete here.",
  ESOA_SETTINGS_NFT_NAME          = "New From Template",
  ESOA_SETTINGS_NFT_TT            = "Create a new View based on the template selected.",
  ESOA_SETTINGS_NFT_SELECT_NAME   = "Select View Name for 'New from Template':",
  ESOA_SETTINGS_NFT_SELECT_TT     = "Select a View to do 'New from Template' .",
  ESOA_SETTINGS_DELETE_NAME       = "Delete",
  ESOA_SETTINGS_DELETE_NTT        = "Delete selected Character's Data!",
  ESOA_SETTINGS_CHAR_NAME         = "Character",
  ESOA_SETTINGS_CHAR_TT           = "Select Character.",
  ESOA_SETTINGS_SELECT            = "Select",
  ESOA_SETTINGS_RESET_VIEWS_BTN_NT = "RESET all views to defaults",
  ESOA_SETTINGS_RESET_VIEWS_BTN_TT = "Will remove all views and replace them with the defaults",
  
  ESOA_SETTINGS_ACCOUNTWIDEONLY_NAME = "AccountWideOnly",
  ESOA_SETTINGS_ACCOUNTWIDEONLY_TT = "Will use the same settings for all characters settings, from color to view ",
  ESOA_SETTINGS_CLEARNONACCOUNTWIDE_NAME = "Clear Specific Data",
  ESOA_SETTINGS_CLEARNONACCOUNTWIDE_TT = "Will DELETE this character specific settings for THIS character's settings to color and view data!! (NON-reversable) And should help with memory and load times.",
  
  ESOA_SETTINGS_SHOWPERCENTS_NAME  = "Show Partial Numbers",
  ESOA_SETTINGS_SHOWPERCENTS_TT    = "Show skills partial numbers?",
  ESOA_SETTINGS_SHOWBETA_NAME      = "Show Beta Settings",
  ESOA_SETTINGS_SHOWBETA_TT        = "I can not confirm or deny destruction of the world",
  
  ESOA_SETTINGS_MAINT_HDR_NAME    = "Character Maintanance",
  ESOA_SETTINGS_MAINT_HDR_TEXT    = "Character Maintanance",
  ESOA_SETTINGS_MAINT_HDR_TT      = "Character Maintanance Utils",
    
  ESOA_SETTINGS_SKILLCOLOR_NearMax_NAME = "Skill at nearly MAX Color",
  ESOA_SETTINGS_SKILLCOLOR_NearMax_TT   = "What Color to use when a skill is near the current MAX.",
  
  ESOA_SETTINGS_SKILLCOLOR_Max_NAME = "Skill at MAX Color",
  ESOA_SETTINGS_SKILLCOLOR_Max_TT   = "What Color to use when a skill is at the current MAX.",
  
  ESOA_SETTINGS_SKILLCOLOR_na_NAME = "Timer N/A or not set Color",
  ESOA_SETTINGS_SKILLCOLOR_na_TT   = "What Color to use when a timer is NOT set or n/a.",
  
  ESOA_SETTINGS_SKILLCOLOR_done_NAME = "Timer Done Color",
  ESOA_SETTINGS_SKILLCOLOR_done_TT   = "What Color to use when a timer is at completion.",
    
  ESOA_SETTINGS_SKILLCOLOR_sooner_NAME = "Timer Done Sooner Color",
  ESOA_SETTINGS_SKILLCOLOR_sooner_TT   = "What Color to use when a timer is nearer(!) to completion.",
  
  ESOA_SETTINGS_SKILLCOLOR_soon_NAME = "Timer Done Soon Color",
  ESOA_SETTINGS_SKILLCOLOR_soon_TT   = "What Color to use when a timer is near to completion.",
  
  ESOA_SETTINGS_ACCOUNTWIDE   = "Account Wide Settings",
  ESOA_SETTINGS_CHAR_SETTINGS = "Per Character Settings (below)",
  ESOA_SETTINGS_UI_SETTINGS   = "UI Settings",
  ESOA_SETTINGS_VIEW_SETTINGS   = "Data/Temp Settings",
  ESOA_SETTINGS_OPTIONS       = "Color Options",
  ESOA_SETTINGS_CHAR_HDR_TT   = "Use the save button to store some default settings that you can later use on another character using the load button.",
  
  ESOA_SETTINGS_MOUSEHIGHLIGHT_NAME = "Mouse Hightlight On/Off",
  ESOA_SETTINGS_MOUSEHIGHLIGHT_TT   = "On or off.",
  ESOA_SETTINGS_SHOWBUTTON_NAME = "Show Button",
  ESOA_SETTINGS_SHOWBUTTON_TT   = "On or off.",
  ESOA_SETTINGS_HIDEUIMENUS_NM = "Hide ESOA when menues are opened?",
  ESOA_SETTINGS_HIDEUIMENUS_TT   = "On to hide when things like the map or character screen are opened.",
  
  ESOA_SETTINGS_AUTOUSEDEF_NM   = "Automatically use saved settings on new character?",
  ESOA_SETTINGS_AUTOUSEDEF_TT   = "If checked, this addon will use the saved default settings when a new character is loaded.",
  
  ESOA_SETTINGS_CHARNAMEFIELD_NAME = "Char name field width",
  ESOA_SETTINGS_CHARNAMEFIELD_TT   = "Width of Name field displayed.",
  ESOA_SETTINGS_CHARNAMEFIELD_WARNING = "Don't set this to a negative number or too big, that's on you!",

  ESOA_SETTINGS_VIEWBUTTONSSHOWMAX_NAME = "Num View Tabs To Show",
  ESOA_SETTINGS_VIEWBUTTONSSHOWMAX_TT   = "How many View Tabs To show in GUI header.",
  ESOA_SETTINGS_VIEWBUTTONSSHOWMAX_WARNING = "Don't set this to a negative number or too big, that's on you!",

  
  ESOA_SETTINGS_CPACTIVEBAR1_NM = "Show champion active bar #1?",
  ESOA_SETTINGS_CPACTIVEBAR1_TT = "A simple ESOA created bar that will show your active champion passives after opening/closing the champion screen.",
  ESOA_SETTINGS_CPACTIVEBAR2_NM = "Show champion active bar? #2?",
  ESOA_SETTINGS_CPACTIVEBAR2_TT = "A simple ESOA created bar that will show your active champion passives after opening/closing the champion screen.",
    
  ESOA_SETTINGS_PVPWARNING_NM = "Show PVP alliance loading errors?",
  ESOA_SETTINGS_PVPWARNING_TT = "PVP alliance rank/endings might not load, this setting will warn you if that's the case.",
  
  
  ESOA_SETTINGS_STOPACTIVE_NAME    = "Stop data collection",
  ESOA_SETTINGS_STOPACTIVE_TT      = "Check to temporarily stop active collection of data and saving",
  ESOA_SETTINGS_STOPINSTANCE_NAME  = "Off in Instance",
  ESOA_SETTINGS_STOPINSTANCE_TT    = "Stop collecting data in instances/dungeons",
  ESOA_SETTINGS_STOPPVP_NAME       = "Off in PVP",
  ESOA_SETTINGS_STOPPVP_TT         = "Stop collecting data in PVP",
  ESOA_SETTINGS_STOPCOMBAT_NAME    = "Off in Combat",
  ESOA_SETTINGS_STOPCOMBAT_TT      = "Stop collecting data in Combat",
  
  ESOA_SETTINGS_TEST_FAIL 		   	= "Failed test: entry failed as k=",
  ESOA_SETTINGS_TEST_SUCCESS 		= "Testing entries: succeeded",
  --
  --
  --
  --
}

for stringId, stringValue in pairs(localization_strings) do
   ZO_CreateStringId(stringId, stringValue)
   SafeAddVersion(stringId, 1)
end
