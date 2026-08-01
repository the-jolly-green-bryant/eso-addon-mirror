local strings = {
    -- Binding Menu
    SI_ESOPIE_TITLE                             = "|c66bbffESOPie|r Quickslots",
    SI_BINDING_NAME_ESOPIE_OPEN_RING_1          = "Ring 1",
    SI_BINDING_NAME_ESOPIE_OPEN_RING_2          = "Ring 2",
    SI_BINDING_NAME_ESOPIE_OPEN_RING_3          = "Ring 3",
    SI_BINDING_NAME_ESOPIE_OPEN_RING_4          = "Ring 4",
    SI_BINDING_NAME_ESOPIE_OPEN_RING_5          = "Ring 5",
    SI_BINDING_NAME_ESOPIE_OPEN_RING_6          = "Ring 6",
    ESOPIE_SI_LAYER_INTERACTION                 = "Ring Interaction",
    SI_BINDING_NAME_ESOPIE_NAVIGATE_INTERACT    = "Navigate to Subring",
    SI_BINDING_NAME_ESOPIE_CANCEL_INTERACT      = "Cancel",

    -- Defaults
    ESOPIE_SI_DEFAULT_RINGNAME                  = "New Ring",
    ESOPIE_SI_DEFAULT_ACTIONNAME                = "New Slot",

    -- Demo
    ESOPIE_SI_DEFAULT_ROOT                      = "Root",
    ESOPIE_SI_DEFAULT_SOCIAL                    = "Social",
    ESOPIE_SI_DEFAULT_SHOWOFF                   = "Show Off",
    ESOPIE_SI_DEFAULT_MUSIC                     = "Music",
    ESOPIE_SI_DEFAULT_LUTE                      = "Lute",
    ESOPIE_SI_DEFAULT_FLUTE                     = "Flute",
    ESOPIE_SI_DEFAULT_DRUM                      = "Drum",
    ESOPIE_SI_DEFAULT_SCORCH                    = "Scorch",
    ESOPIE_SI_DEFAULT_FLEX                      = "Flex",
    ESOPIE_SI_DEFAULT_GREET                     = "Greet",
    ESOPIE_SI_DEFAULT_CLAP                      = "Clap",
    ESOPIE_SI_DEFAULT_CONGRATULATE              = "Congratulate",

    -- Actions
    ESOPIE_SI_ACTION_NOOP                       = "No Action",
    ESOPIE_SI_ACTION_SUBRING                    = "Navigate to Subring",
    ESOPIE_SI_ACTION_CHATEXEC                   = "Execute Chat Command",
    ESOPIE_SI_ACTION_CODEEXEC                   = "Execute Lua Code",
    ESOPIE_SI_ACTION_GOTOHOME                   = "Teleport to Primary Home",
    ESOPIE_SI_ACTION_PLAYEMOTE                  = "Do Emote",
    ESOPIE_SI_ACTION_PLAYMOMENTO                = "Use Momento/Tool",
    ESOPIE_SI_ACTION_SUMMONALLY                 = "Summon Ally",
    ESOPIE_SI_ACTION_SETMOUNT                   = "Change Mount",
    ESOPIE_SI_ACTION_SETNCPET                   = "Change Non-Combat Pet",
    ESOPIE_SI_ACTION_SETCOSTUME                 = "Change Costume",
    ESOPIE_SI_ACTION_SETPOLYMORPH               = "Change Polymorph",
    ESOPIE_SI_ACTION_SETDRSLOT                  = "Change Dressing Room Slot",

    -- Notifications
    ESOPIE_SI_CHAT_NOCOMMAND                    = "Slot <<1>> has no chat command to execute.",
    ESOPIE_SI_CHAT_INVALIDFIRSTCHAR             = "First character of command for slot <<1>> must be '/'.",
    ESOPIE_SI_CHAT_COMMANDNOTSUPPORTED          = "ESOPie currently does not support this chat command. Hopefully soon!",
    ESOPIE_SI_CHAT_UNKNOWNCOMMAND               = "Unknown chat command '<<1>>'. Is it spelled correctly?",
    ESOPIE_SI_LUA_NOCODE                        = "Slot <<1>> has no code to execute.",
    ESOPIE_SI_COLLECTIBLE_NOTUNLOCKED           = "<<1>> is not unlocked.",
    ESOPIE_SI_FASTTRAVELUNAVAILABLE             = "Fast travel is not available right now.",
    ESOPIE_SI_PRIMARYHOUSENOTSET                = "Primary house has not been set.",

    -- Settings Menu
    ESOPIE_SI_SETTINGS_PANEL_NAME               = "ESOPie",
    ESOPIE_SI_SETTINGS_NOBINDINGSDETECTED       = "|cffff00Warning:|r No ring bindings have been detected. In order to use ESOPie at least one ring binding must be assigned.\nGo to the Controls settings and assign a key or button to at least one ESOPie ring.",
    ESOPIE_SI_SETTINGS_GENERALMENU_NAME         = "General Options",
    ESOPIE_SI_SETTINGS_CONFIGUREHEADER_NAME     = "Rings and Slots",

    ESOPIE_SI_SETTINGS_BINDINGSHEADER           = "Ring Bindings",
    ESOPIE_SI_SETTINGS_RINGBINDING1             = "Ring Binding 1",
    ESOPIE_SI_SETTINGS_RINGBINDING2             = "Ring Binding 2",
    ESOPIE_SI_SETTINGS_RINGBINDING3             = "Ring Binding 3",
    ESOPIE_SI_SETTINGS_RINGBINDING4             = "Ring Binding 4",
    ESOPIE_SI_SETTINGS_RINGBINDING5             = "Ring Binding 5",
    ESOPIE_SI_SETTINGS_RINGBINDING6             = "Ring Binding 6",
    ESOPIE_SI_SETTINGS_BINDINGDISABLED          = "Disabled",
    ESOPIE_SI_SETTINGS_CONTROLSHEADER           = "Controls",
    ESOPIE_SI_SETTINGS_KEYBOARDINTERACTMODE     = "Keyboard Interaction Mode",
    ESOPIE_SI_SETTINGS_GAMEPADINTERACTMODE      = "Gamepad Interaction Mode",
    ESOPIE_SI_SETTINGS_INTERACTMODEHOLD         = "Hold",
    ESOPIE_SI_SETTINGS_INTERACTMODETOGGLE       = "Toggle",

    ESOPIE_SI_SETTINGS_NEWRING                  = "New Ring",
    ESOPIE_SI_SETTINGS_NEWRING_TT               = "Add a new ring.\nNote: You will need to either set a binding or create a sub-ring slot to access the new ring.",
    ESOPIE_SI_SETTINGS_ENTRYSELECT              = "Entry to Edit",
    ESOPIE_SI_SETTINGS_ENTRYSELECT_TT           = "Select the ring or slot to edit.",
    ESOPIE_SI_SETTINGS_ENTRYNAME                = "Name",
    ESOPIE_SI_SETTINGS_ENTRYNAME_TT             = "Enter the display name of the selected entry.",
    ESOPIE_SI_SETTINGS_NEWSLOT                  = "New Slot",
    ESOPIE_SI_SETTINGS_NEWSLOT_TT               = "Add a new slot to this ring. (Maximum of <<1>> per ring)",
    ESOPIE_SI_SETTINGS_DUPLICATEENTRY           = "Duplicate",
    ESOPIE_SI_SETTINGS_DUPLICATEENTRY_TT        = "Duplicate the selected entry.",
    ESOPIE_SI_SETTINGS_REMOVE                   = "Remove",
    ESOPIE_SI_SETTINGS_REMOVE_TT                = "Remove the selected entry",
    ESOPIE_SI_SETTINGS_CONFIRMREMOVE            = "Are you sure you want to |cff0000permanently remove|r <<1>>?",
    ESOPIE_SI_SETTINGS_CONFIRMADDITIONAL        = "Removing this ring will also remove the following slots;",
    ESOPIE_SI_SETTINGS_CONFIRMPERMANENCE        = "This cannot be undone.",
    ESOPIE_SI_SETTINGS_CONFIRMREMOVE_TITLE      = "Remove Entry",
    ESOPIE_SI_SETTINGS_CONFIRMCHANGEACTION      = "Are you sure you want to change the action of <<1>> to <<2>>?\n\nYou will lose any settings associated with the current <<3>> action.",
    ESOPIE_SI_SETTINGS_CONFIRMCHANGEACTION_TITLE= "Change Slot Action",

    ESOPIE_SI_SETTINGS_CONFIGURESLOTMENU        = "Slot Options",
    ESOPIE_SI_SETTINGS_CONF_ENTRYEDITHEADER     = "Edit Entry",
    ESOPIE_SI_SETTINGS_CONF_RINGEDITHEADER      = "Editing <<1>>",
    ESOPIE_SI_SETTINGS_CONF_SLOTEDITHEADER      = "Editing <<1>> in <<2>>",
    ESOPIE_SI_SETTINGS_CONF_ICONHEADER          = "Slot Icon",
    ESOPIE_SI_SETTINGS_BROWSEICON               = "Browse for Icon",
    ESOPIE_SI_SETTINGS_BROWSEICON_TT            = "Select an icon for the slot.",
    ESOPIE_SI_SETTINGS_ICONPATH                 = "Icon Path",
    ESOPIE_SI_SETTINGS_ICONPATH_TT              = "Any icon can be used if you know the path.",
    ESOPIE_SI_SETTINGS_ICONFROMCOLLECTIBLE      = "From Collectible",
    ESOPIE_SI_SETTINGS_ICONFROMCOLLECTIBLE_TT   = "Set the path to the currently selected collectible's icon. This is useful for finding icon paths for subrings.",
    ESOPIE_SI_SETTINGS_RESETICON                = "Reset",
    ESOPIE_SI_SETTINGS_RESETICON_TT             = "Reset to automatic icon, if available.",
    ESOPIE_SI_SETTINGS_MAGICICONDESC            = "Tip: Select the first icon in the list or remove the path below to use an automatic icon. ESOPie will use the icon of the collection item instead.",
    ESOPIE_SI_SETTINGS_CONF_ACTIONHEADER        = "Slot Action",
    ESOPIE_SI_SETTINGS_SLOTACTION               = "Action",
    ESOPIE_SI_SETTINGS_SLOTACTION_TT            = "Select the action that should occur when this slot is activated.",

    ESOPIE_SI_SETTINGS_SUBRINGMENU              = "Subring",
    ESOPIE_SI_SETTINGS_SUBRING                  = "Subring",
    ESOPIE_SI_SETTINGS_SUBRING_TT               = "Subring to open",

    ESOPIE_SI_SETTINGS_COLLECTIONMENU           = "Collection",
    ESOPIE_SI_SETTINGS_COLLECTIONCATEGORY       = "Category",
    ESOPIE_SI_SETTINGS_COLLECTIONCATEGORY_TT    = "Collectable category to select from.",
    ESOPIE_SI_SETTINGS_COLLECTIBLE              = "Collectable",
    ESOPIE_SI_SETTINGS_COLLECTIBLE_TT           = "Collectable to use when activated.",

    ESOPIE_SI_SETTINGS_COMMANDMENU              = "Command",
    ESOPIE_SI_SETTINGS_COMMAND                  = "Command",
    ESOPIE_SI_SETTINGS_COMMAND_TT               = "Chat command or Lua code to execute when activated.",

    ESOPIE_SI_SETTINGS_ORG_HEADER               = "Slot Organization",
    ESOPIE_SI_SETTINGS_ORG_SLOTORDER            = "Slot Priority",
    ESOPIE_SI_SETTINGS_ORG_SLOTORDERHINT        = "Note: Entries will be sorted from the lowest value to highest. Slots are filled counter-clockwise from the bottom-right.",
    ESOPIE_SI_SETTINGS_ORG_MOVETORING           = "Move To",
    ESOPIE_SI_SETTINGS_ORG_MOVETORING_TT        = "Select the ring to move this slot to.",

    ESOPIE_SI_SETTINGS_ORG_CONFIRMMOVESLOT      = "Are you sure you want to move <<1>> from <<2>> to <<3>>?",
    ESOPIE_SI_SETTINGS_ORG_CONFIRMMOVESLOT_TITLE= "Move Slot",

    ESOPIE_SI_SETTINGS_EXT_DRMENU               = "Dressing Room",
    ESOPIE_SI_SETTINGS_EXT_DRSLOTSELECT         = "Outfit",
    ESOPIE_SI_SETTINGS_EXT_DRSLOTSELECT_TT      = "Dressing Room outfit slot to switch to when activated.",
    ESOPIE_SI_SETTINGS_EXT_DRSLOT               = "Outfit <<1>>",

    -- Collection Tooltips
    ESOPIE_SI_TOOLTIP_DOEMOTE                   = "Do the <<1>> emote.",
}

for stringId, stringValue in pairs(strings) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(stringId, 1)
end