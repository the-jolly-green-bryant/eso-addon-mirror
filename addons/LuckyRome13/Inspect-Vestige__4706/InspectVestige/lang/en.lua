-- Inspect Vestige by LuckyRome13
-- Localization (English / default), namespace bootstrap, and shared data tables.
-- This file is loaded first, so it creates the global namespace.

InspectVestige = InspectVestige or {}
local IV = InspectVestige

IV.name    = "InspectVestige"
IV.version = "1.4.0"
IV.author  = "LuckyRome13"

-- Keybind + binding-category display names (referenced by Bindings.xml).
ZO_CreateStringId("SI_BINDING_NAME_INSPECT_VESTIGE_RETICLE", "Inspect reticle target")
ZO_CreateStringId("SI_BINDING_CATEGORY_INSPECT_VESTIGE", "Inspect Vestige")

--------------------------------------------------------------------------------
-- Localized strings
--------------------------------------------------------------------------------
IV.L = {
    TITLE              = "Inspect Vestige",
    MENU_INSPECT       = "Inspect Vestige",

    SLASH_USAGE        = "|cFFD700Inspect Vestige|r: /iv (self) | /iv settings | /iv @Account",

    SOURCE_SELF        = "Your character",
    SOURCE_PEER        = "Live from player (shared)",
    SOURCE_CACHE       = "Cached %s",           -- %s = relative time
    SOURCE_PUBLIC      = "Public info only",

    STATUS_SYNCING     = "Requesting loadout from player\226\128\166",
    STATUS_NOT_SHARING = "No loadout data. Full inspect needs the target to be in your group and also running Inspect Vestige.",
    STATUS_FRIENDS_ONLY = "This player only shares their loadout with friends.",
    STATUS_UNAVAILABLE = "Gear, skills and attributes are not available for this player.",
    STATUS_NO_TARGET   = "No player targeted.",

    LABEL_GEAR         = "Equipment",
    LABEL_COSMETICS    = "Cosmetics",                -- Equipment header toggles Equipment / Cosmetics
    SETS_TITLE         = "Item Sets",                -- set-summary popup title (hover the Equipment header)
    ARMOR_LABEL        = "Armor",                    -- armor-weight line, e.g. "Armor: 5 Light \194\183 2 Heavy"
    LABEL_FRONT_BAR    = "Front bar",
    LABEL_BACK_BAR     = "Back bar",
    LABEL_WEREWOLF_BAR = "Werewolf",           -- back-bar row toggles to the werewolf form bar
    LABEL_ATTRS        = "Attributes",
    LABEL_MUNDUS       = "Mundus",
    LABEL_CP           = "Champion Points",
    LABEL_FOOD         = "Food / Drink",
    LABEL_POTION       = "Potion",                   -- active quickslot potion (row under Food / Drink)
    LABEL_CURSE        = "Curse",
    LINK_TO_CHAT       = "Link to Chat",             -- CP star + dye swatch right-click menu
    LABEL_CLASS_MASTERY = "Class Mastery",           -- pure class: the equipped mastery passives
    LABEL_SUBCLASS      = "Subclass",                -- subclassing: the 3 chosen class skill lines
    LABEL_NONE         = "\226\128\148",            -- em dash
    SLOT_EMPTY         = "None",                     -- shown for an unequipped gear slot
    GEAR_NO_SET        = "Non-set item",             -- fallback when a piece has no set + no name
    SET_PIECES         = "Set pieces",               -- appended per-bar set-count line (Front N/M \194\183 Back K/M)
    SKILL_TARGET_LEVEL = "Target's skill level:",    -- appended to a peer's skill tooltip (rank I-IV)

    CURSE_WEREWOLF     = "Werewolf",
    CURSE_VAMPIRE_STAGE = "Vampire (Stage %d)",


    ATTR_MAGICKA       = "Magicka",
    ATTR_HEALTH        = "Health",
    ATTR_STAMINA       = "Stamina",

    LABEL_STATS        = "Stats",
    LABEL_FRONT_STATS  = "Front bar stats",   -- header above the front-bar stat block (beside the Front bar)
    LABEL_BACK_STATS   = "Back bar stats",    -- header above the back-bar stat block (beside the Back bar)
    STAT_DMG           = "Spell/Weapon Dmg",  -- hybridized: weapon == spell
    STAT_MAX_MAG       = "Max Mag",
    STAT_MAX_STAM      = "Max Stam",
    STAT_MAX_HP        = "Max HP",
    STAT_CRIT          = "Crit Chance",       -- crit CHANCE (% of hits that crit)
    STAT_CRIT_DMG      = "Crit Heal/Dmg",     -- crit DAMAGE (% extra a crit deals/heals)
    STAT_PEN           = "Spell/Phys Pen",    -- hybridized: physical == spell
    STAT_BAR_FRONT     = "Front",             -- Stats-row front/back bar toggle
    STAT_BAR_BACK      = "Back",
    STAT_BAR_HINT_SELF = "Weapon-swap once to capture this bar",  -- selected bar not yet read
    STAT_BAR_HINT_PEER = "This bar hasn't been saved. Ask the player to weapon-swap, then inspect again.",
}

--------------------------------------------------------------------------------
-- Shared data tables
--------------------------------------------------------------------------------

-- Equipment slots we read/display, in visual order (armor, jewelry, weapons, poisons).
IV.GEAR_SLOTS = {
    EQUIP_SLOT_HEAD,
    EQUIP_SLOT_SHOULDERS,
    EQUIP_SLOT_CHEST,
    EQUIP_SLOT_HAND,
    EQUIP_SLOT_WAIST,
    EQUIP_SLOT_LEGS,
    EQUIP_SLOT_FEET,
    EQUIP_SLOT_NECK,
    EQUIP_SLOT_RING1,
    EQUIP_SLOT_RING2,
    EQUIP_SLOT_MAIN_HAND,
    EQUIP_SLOT_OFF_HAND,
    EQUIP_SLOT_BACKUP_MAIN,
    EQUIP_SLOT_BACKUP_OFF,
    EQUIP_SLOT_POISON,
    EQUIP_SLOT_BACKUP_POISON,
}

-- Short human labels for each slot (fallback text / tooltips).
IV.GEAR_SLOT_NAMES = {
    [EQUIP_SLOT_HEAD]          = "Head",
    [EQUIP_SLOT_SHOULDERS]     = "Shoulders",
    [EQUIP_SLOT_CHEST]         = "Chest",
    [EQUIP_SLOT_HAND]          = "Hands",
    [EQUIP_SLOT_WAIST]         = "Waist",
    [EQUIP_SLOT_LEGS]          = "Legs",
    [EQUIP_SLOT_FEET]          = "Feet",
    [EQUIP_SLOT_NECK]          = "Necklace",
    [EQUIP_SLOT_RING1]         = "Ring 1",
    [EQUIP_SLOT_RING2]         = "Ring 2",
    [EQUIP_SLOT_MAIN_HAND]     = "Main (front)",
    [EQUIP_SLOT_OFF_HAND]      = "Off (front)",
    [EQUIP_SLOT_BACKUP_MAIN]   = "Main (back)",
    [EQUIP_SLOT_BACKUP_OFF]    = "Off (back)",
    [EQUIP_SLOT_POISON]        = "Poison (front)",
    [EQUIP_SLOT_BACKUP_POISON] = "Poison (back)",
}

-- Mundus boon buff names. Mundus stones show up as a permanent (no-duration) buff
-- on the player; we match by name so we don't depend on hard-coded ability ids.
-- NOTE: names are English; a future localization pass would localize this set.
IV.MUNDUS_NAMES = {
    ["The Warrior"]    = true,
    ["The Mage"]       = true,
    ["The Serpent"]    = true,
    ["The Thief"]      = true,
    ["The Lady"]       = true,
    ["The Steed"]      = true,
    ["The Lord"]       = true,
    ["The Apprentice"] = true,
    ["The Ritual"]     = true,
    ["The Lover"]      = true,
    ["The Atronach"]   = true,
    ["The Shadow"]     = true,
    ["The Tower"]      = true,
}

-- Fallback heuristic for food/drink detection: provisioning buff icons live under
-- .../ability_provisioning_*  . We treat a long/permanent player-cast buff with a
-- provisioning icon as the active food/drink. (A curated ability-id set could be
-- added here later for exactness.)
IV.FOOD_ICON_HINT = "provisioning"
