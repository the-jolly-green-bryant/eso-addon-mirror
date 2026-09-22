local moduleStrings = {
    REPAIR = "Repair, Recharge & Research",
    REPAIR_TOOLTIP = "Enables automatic repair, weapon recharging, and crafting trait research.",
    REPAIR_PANEL = "Universal Assistant Repair, Recharge & Research",
}

local strings = {

    AUTO_REPAIR = "Automatic repair",
    AUTO_REPAIR_TOOLTIP = "Settings for automatically repairing equipped items.",

    ENABLE_REPAIR = "Automatically repair equipped items",
    ENABLE_REPAIR_TOOLTIP = "Scans and repairs equipped items only.",

    REPAIR_THRESHOLD = "Repair at or below",
    REPAIR_THRESHOLD_TOOLTIP = "Repairs equipped items when their condition reaches this percentage or lower.",
    REPAIR_THRESHOLD_SET = "Equipment will be repaired at %d%%.",

    USE_CROWN_REPAIR_KITS_FIRST = "Use Crown Repair Kits first",
    USE_CROWN_REPAIR_KITS_FIRST_TOOLTIP = "When enabled, Crown Repair Kits are used first and standard Repair Kits are used after they run out. When disabled, only standard Repair Kits are used. Crown Repair Kits can only be used outside combat.",

    REPAIR_IN_COMBAT = "Repair during combat",
    REPAIR_IN_COMBAT_TOOLTIP = "Allows standard Repair Kits to be used during combat. The game only permits Crown Repair Kits to be used outside combat.",
    TRACK_REPAIR_KITS = "Track remaining Repair Kits",
    TRACK_REPAIR_KITS_TOOLTIP = "Enables separate warnings for low standard Repair Kit counts. Crown Repair Kits are not counted.",
    REPAIR_KIT_WARNING_THRESHOLD = "Show remaining Repair Kit warning",
    REPAIR_KIT_WARNING_THRESHOLD_TOOLTIP = "After repairing, shows the remaining Repair Kit count when it reaches this value or lower.",
    REPAIR_CHAT_MESSAGES = "Repair messages in chat",
    REPAIR_CHAT_MESSAGES_TOOLTIP = "Shows a chat message for every item repaired automatically.",

    ITEM_REPAIRED = "Repaired %s by %d%%.",
    REPAIR_KITS_REMAINING = "Repair Kits remaining: %d.",

    AUTO_RECHARGE = "Automatic weapon recharge",
    AUTO_RECHARGE_TOOLTIP = "Settings for automatically recharging equipped weapons.",

    ENABLE_RECHARGE = "Automatically recharge equipped weapons",
    ENABLE_RECHARGE_TOOLTIP = "Scans and recharges equipped weapons only.",

    RECHARGE_THRESHOLD = "Recharge at or below",
    RECHARGE_THRESHOLD_TOOLTIP = "Recharges equipped weapons when their enchantment charge reaches this percentage or lower.",
    RECHARGE_THRESHOLD_SET = "Weapons will be recharged at %d%%.",

    USE_CROWN_SOUL_GEMS_FIRST = "Use Crown Soul Gems first",
    USE_CROWN_SOUL_GEMS_FIRST_TOOLTIP = "When enabled, Crown Soul Gems are used first and standard filled Soul Gems are used after they run out. When disabled, only standard Soul Gems are used.",

    RECHARGE_IN_COMBAT = "Recharge during combat",
    RECHARGE_IN_COMBAT_TOOLTIP = "Allows equipped weapons to be recharged automatically during combat.",
    TRACK_SOUL_GEMS = "Track remaining Soul Gems",
    TRACK_SOUL_GEMS_TOOLTIP = "Enables separate warnings for low standard filled Soul Gem counts. Crown Soul Gems are not counted.",
    SOUL_GEM_WARNING_THRESHOLD = "Show remaining Soul Gem warning",
    SOUL_GEM_WARNING_THRESHOLD_TOOLTIP = "After recharging, shows the remaining filled Soul Gem count when it reaches this value or lower.",
    RECHARGE_CHAT_MESSAGES = "Recharge messages in chat",
    RECHARGE_CHAT_MESSAGES_TOOLTIP = "Shows a chat message for every weapon recharged automatically.",

    ITEM_RECHARGED = "Recharged %s by %d%%.",
    SOUL_GEMS_REMAINING = "Filled Soul Gems remaining: %d.",

    RESEARCH = "Research",
    RESEARCH_TOOLTIP = "Settings for crafting trait research.",
    RESEARCH_CHAT_MESSAGES = "Research messages in chat",
    RESEARCH_CHAT_MESSAGES_TOOLTIP = "Shows which item and trait Universal Assistant automatically started researching.",
    RESEARCH_STARTED = "Started researching %s with the %s trait.",
    RESEARCH_BLACKSMITHING = "Blacksmithing",
    RESEARCH_CLOTHING = "Clothing",
    RESEARCH_WOODWORKING = "Woodworking",
    RESEARCH_JEWELRY = "Jewelry",
    RESEARCH_SELECT_ALL = "Select all",
    RESEARCH_PRIORITY = "Research priority",
    RESEARCH_PRIORITY_TOOLTIP = "In order checks the options from top to bottom: the ring on the left, then the necklace on the right. Shortest research time prioritizes the available item whose trait will finish sooner.",
    RESEARCH_PRIORITY_SEQUENCE = "In order",
    RESEARCH_PRIORITY_SHORTEST = "Shortest research time",
}

local ua = UAssistant
ua.AddLanguageStrings("en", moduleStrings)
ua.AddLanguageStrings("en", strings, "REPAIR")
