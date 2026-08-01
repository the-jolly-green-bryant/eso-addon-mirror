-- i18n/en.lua

-- loaded
ZO_CreateStringId("ZMS_LOADED",        "|c87CEEBZone Mount Switcher loaded.|r Type /zms for help.")

-- help
ZO_CreateStringId("ZMS_HELP_TITLE",      "|c87CEEBZone Mount Switcher|r commands:")
ZO_CreateStringId("ZMS_HELP_SETMOUNT",   "/zms setmount <Group>   — add the |c87CEEBcurrently active|r mount to the group's pool.")
ZO_CreateStringId("ZMS_HELP_CLEARMOUNT", "/zms clearmount <Group> — clear all mounts for the group.")
ZO_CreateStringId("ZMS_HELP_SETPET",     "/zms setpet <Group>     — add the |c87CEEBcurrently active|r non-combat pet to the group's pool.")
ZO_CreateStringId("ZMS_HELP_CLEARPET",   "/zms clearpet <Group>   — clear all pets for the group.")
ZO_CreateStringId("ZMS_HELP_SETALL",     "/zms setall <Group>     — add both active mount and pet to the group.")
ZO_CreateStringId("ZMS_HELP_CLEARALL",   "/zms clearall <Group>   — clear both mounts and pets for the group.")
ZO_CreateStringId("ZMS_HELP_TEST",       "/zms test               — force apply for the current zone.")
ZO_CreateStringId("ZMS_HELP_DEBUG",      "/zms debug              — toggle debug mode.")
ZO_CreateStringId("ZMS_HELP_LIST",       "/zms list [Group]       — show associated zones and pooled mounts/pets (all or a group).")
ZO_CreateStringId("ZMS_HELP_RESETDEFAULTS","/zms resetdefaults     — reset zones to the default pack.")
ZO_CreateStringId("ZMS_HELP_GROUPS",     "Available groups: %s")

-- words / common
ZO_CreateStringId("ZMS_WORD_MOUNT",      "Mount")
ZO_CreateStringId("ZMS_WORD_PET",        "Pet")
ZO_CreateStringId("ZMS_EMPTY",           "empty")
ZO_CreateStringId("ZMS_NONE",            "none")

-- ok / errors (mount)
ZO_CreateStringId("ZMS_ERR_UNKNOWN",     "Unknown group: %s")
ZO_CreateStringId("ZMS_ERR_READMOUNT",   "Unable to read the active mount. Open |c87CEEBCollections > Mounts|r, set the one you want, then run the command again.")
ZO_CreateStringId("ZMS_OK_SETMOUNT",     "OK: “%s” → added mount id %d")
ZO_CreateStringId("ZMS_OK_CLEARMOUNT",   "All mounts cleared for “%s”.")
ZO_CreateStringId("ZMS_NO_CLEARMOUNT",   "No mounts to clear for “%s”.")
ZO_CreateStringId("ZMS_DEBUG_TOGGLE",    "Debug = %s")

-- ok / errors (pet)
ZO_CreateStringId("ZMS_ERR_READPET",     "Unable to read the active pet. Open |c87CEEBCollections > Non-Combat Pets|r, activate the one you want, then run the command again.")
ZO_CreateStringId("ZMS_OK_SETPET",       "OK: “%s” → added pet %s")
ZO_CreateStringId("ZMS_OK_CLEARPET",     "All pets cleared for “%s”.")
ZO_CreateStringId("ZMS_NO_CLEARPET",     "No pets to clear for “%s”.")

-- ok / errors (setall/clearall)
ZO_CreateStringId("ZMS_OK_SETALL",       "OK: “%s” → added Mount=%s, Pet=%s")
ZO_CreateStringId("ZMS_OK_CLEARALL",     "All mounts and pets cleared for “%s”.")
ZO_CreateStringId("ZMS_ERR_READALL",     "Unable to read active mount or pet. Open |c87CEEBCollections|r, set what you want, then retry.")

-- reset defaults
ZO_CreateStringId("ZMS_OK_RESETDEFAULTS","Zones reset to default pack (v%s).")
ZO_CreateStringId("ZMS_ERR_NODEFAULTS",  "No default pack available.")

-- logs around groups/zones
ZO_CreateStringId("ZMS_LOG_NOGROUP_FOR_ZONE", "No group for zone %s (%d)")
ZO_CreateStringId("ZMS_LOG_APPLY_MOUNT",      "Apply MOUNT: %s → %s (id %d)")
ZO_CreateStringId("ZMS_LOG_PET_LOCKED",       "SetActivePet: collectible %d not unlocked")
ZO_CreateStringId("ZMS_LOG_APPLY_PET",        "Apply PET: %s → %s (id %d)")
ZO_CreateStringId("ZMS_LOG_PET_ALREADY",      "Pet already active")
ZO_CreateStringId("ZMS_LOG_ALREADY",          "Mount already active")
ZO_CreateStringId("ZMS_LOG_UNLOCKED",         "SetActiveMount: mount %d not unlocked")
ZO_CreateStringId("ZMS_LOG_NOAPI",            "No API available to activate a mount")
ZO_CreateStringId("ZMS_LOG_NOMOUNT",          "No mount configured for group “%s”.")
ZO_CreateStringId("ZMS_LOG_NOPET",            "No pet configured for group “%s”.")
ZO_CreateStringId("ZMS_LOG_ALREADY_BOUND",    "Zone %d already bound to %s")
ZO_CreateStringId("ZMS_LOG_BOUND",            "Bind zone %d (%s) → %s")
ZO_CreateStringId("ZMS_LOG_UNBOUND",          "Unbind zone %d from %s")

-- list outputs
ZO_CreateStringId("ZMS_LIST_HEADER",          "|c87CEEBCurrent bindings (zones per group):|r")
ZO_CreateStringId("ZMS_LIST_MOUNTSPETS",      "|c87CEEBConfigured Mounts / Pets pools:|r")
ZO_CreateStringId("ZMS_LIST_GROUP_HEADER",    "|c87CEEBZones linked to %s:|r")

-- localized display names for groups
ZO_CreateStringId("ZMS_GROUP_NORDIC",    "Nordic")
ZO_CreateStringId("ZMS_GROUP_TEMPERATE", "Temperate")
ZO_CreateStringId("ZMS_GROUP_COASTAL",   "Coastal")
ZO_CreateStringId("ZMS_GROUP_FOREST",    "Forest")
ZO_CreateStringId("ZMS_GROUP_ARID",      "Arid")
ZO_CreateStringId("ZMS_GROUP_MARSH",     "Marsh")
ZO_CreateStringId("ZMS_GROUP_VOLCANIC",  "Volcanic")
ZO_CreateStringId("ZMS_GROUP_OBLIVION",  "Oblivion")
