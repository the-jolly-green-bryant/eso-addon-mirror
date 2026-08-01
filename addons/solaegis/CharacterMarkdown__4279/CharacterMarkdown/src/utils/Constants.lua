-- CharacterMarkdown - Constants
-- Centralized location for static data, lookups, and configuration constants

local CM = CharacterMarkdown

-- Define CM.constants (legacy lowercase) and alias CM.Constants (new uppercase) to it
CM.constants = CM.constants or {}
CM.Constants = CM.constants

-- =====================================================
-- CHUNKING CONSTANTS
-- =====================================================
--
-- ESO EditBox copy/display limits - based on real-world testing:
-- - EditBox is configured with SetMaxInputChars(22000) in Window.lua
-- - With chunking + 550 newline padding, ~21,500 chars per chunk copies reliably
-- - MAX_DATA_CHARS reserves room for chunk marker (~60 bytes) + padding (550 newlines)
--
-- Historical note: Early testing (2025-11) showed truncation at ~6.5k without padding.
-- Current limits reflect later validation at ~21.5k with markers and sacrificial newlines.
--
CM.constants.CHUNKING = {
    EDITBOX_LIMIT = 21500, -- Trigger chunking when content exceeds COPY_LIMIT (matches actual chunk size limit)
    COPY_LIMIT = 21500, -- Safe copy limit confirmed by testing
    MAX_DATA_CHARS = 20350, -- Maximum data characters per chunk (leaves room for ~60 byte HTML comment marker + 550 newlines + buffer)
    DISABLE_PADDING = false, -- **PADDING ENABLED** - sacrificial newlines absorb paste truncation
    MIN_FINAL_CHUNK_PADDING = 50, -- Minimum padding for final chunk
    MAX_FINAL_CHUNK_PADDING = 300, -- Maximum padding for final chunk
    SPACE_PADDING_SIZE = 550, -- Number of NEWLINES to add as padding - safe if truncated, works in any markdown context
    PADDING_FALLBACK = 550, -- Redundant fallback when SPACE_PADDING_SIZE is nil - must match
    CHUNK_MARKER_SIZE = 60, -- Reserve for HTML comment marker "<!-- Chunk N (XXXXX bytes before padding) -->\n\n"
    MERMAID_HEADER_RESERVE = 350, -- Conservative estimate for large mermaid init configs
    STRUCTURE_OVERRIDE_HTML = 5000, -- Allow overage for complete HTML blocks
    STRUCTURE_OVERRIDE_TABLE = 1500, -- Allow overage for complete tables
    BACKTRACK_WINDOW = 5000, -- Search window for backtracking to safe split points
}

-- =====================================================
-- STRING LIMITS (Restored)
-- =====================================================

CM.constants.LIMITS = {
    MAX_CUSTOM_NOTES_SIZE = 1900, -- Maximum custom notes size (~2000 char ESO SavedVariables limit per string)
    MAX_STRING_TRUNCATE = 1000, -- Maximum string length before truncation warning
    ESO_SAVEDVAR_STRING_LIMIT = 2000, -- ESO's hard limit for individual string values in SavedVariables
}

-- =====================================================
-- FORMAT NAMES (Restored)
-- =====================================================

CM.constants.FORMATS = {
    MARKDOWN = "markdown",
}

-- =====================================================
-- CHAMPION POINTS CONSTANTS (Restored)
-- =====================================================

CM.constants.CP = {
    MIN_CP_FOR_SYSTEM = 10, -- Minimum CP required for Champion Point system
    MAX_CP_PER_DISCIPLINE = 660, -- Maximum CP per discipline
    PROGRESS_BAR_LENGTH = 12, -- Length of progress bar in characters
}

-- =====================================================
-- DEFAULT VALUES (Restored)
-- =====================================================

CM.constants.DEFAULTS = {
    EDITBOX_LIMIT_FALLBACK = 10000, -- Fallback EditBox limit if CHUNKING constant not available
}

-- =====================================================
-- GAME CONSTANTS & LOOKUPS (New)
-- =====================================================

-- Race ID to name mapping (fallback if API fails)
-- ESO Race IDs: 1=Altmer, 2=Argonian, 3=Bosmer, 4=Breton, 5=Dunmer, 6=Imperial, 7=Khajiit, 8=Nord, 9=Orc, 10=Redguard
CM.constants.RACE_NAMES = {
    [1] = "Altmer",
    [2] = "Argonian",
    [3] = "Bosmer",
    [4] = "Breton",
    [5] = "Dunmer",
    [6] = "Imperial",
    [7] = "Khajiit",
    [8] = "Nord",
    [9] = "Orc",
    [10] = "Redguard",
}

-- Class ID to name mapping (fallback if API fails)
-- ESO Class IDs: 1=Dragonknight, 2=Sorcerer, 3=Nightblade, 4=Templar, 5=Warden, 6=Necromancer, 7=Arcanist
CM.constants.CLASS_NAMES = {
    [1] = "Dragonknight",
    [2] = "Sorcerer",
    [3] = "Nightblade",
    [4] = "Templar",
    [5] = "Warden",
    [6] = "Necromancer",
    [7] = "Arcanist",
}

-- Skill Type Names (Standard ESO Types)
CM.constants.SKILL_TYPE_NAMES = {
    [1] = "Class",
    [2] = "Weapon",
    [3] = "Armor",
    [4] = "World",
    [5] = "Guild",
    [6] = "Alliance War",
    [7] = "Racial",
    [8] = "Craft",
    [9] = "Champion",
}

-- Skill Type Emojis for Markdown Generation
CM.constants.SKILL_TYPE_EMOJIS = {
    ["Class"] = "⚔️",
    ["Weapon"] = "⚔️",
    ["Armor"] = "🛡️",
    ["World"] = "🌍",
    ["Guild"] = "🏰",
    ["Alliance War"] = "⚔️",
    ["Racial"] = "⭐",
    ["Craft"] = "⚒️",
    ["Champion"] = "⭐",
}

-- Default Emoji Fallback
CM.constants.DEFAULT_SKILL_EMOJI = "📜"

-- =====================================================
-- FILTERING & VALIDATION (New)
-- =====================================================

-- Invalid Skill Types to skip in processing
CM.constants.INVALID_SKILL_TYPES = {
    ["Vengeance"] = true,
    ["Racial"] = true, -- Often handled separately or hidden
}

-- Invalid Skill Lines to skip in processing
CM.constants.INVALID_SKILL_LINES = {
    ["Vengeance"] = true,
    ["Crown Store"] = true,
    [""] = true,
}

-- Class Skill Lines Mapping (Fallback / Reference)
-- Used if dynamic detection fails or for validation
CM.constants.CLASS_SKILL_LINES = {
    ["Dragonknight"] = {
        ["Ardent Flame"] = true,
        ["Draconic Power"] = true,
        ["Earthen Heart"] = true,
    },
    ["Nightblade"] = {
        ["Assassination"] = true,
        ["Shadow"] = true,
        ["Siphoning"] = true,
    },
    ["Sorcerer"] = {
        ["Daedric Summoning"] = true,
        ["Dark Magic"] = true,
        ["Storm Calling"] = true,
    },
    ["Templar"] = {
        ["Aedric Spear"] = true,
        ["Dawn's Wrath"] = true,
        ["Restoring Light"] = true,
    },
    ["Warden"] = {
        ["Animal Companions"] = true,
        ["Green Balance"] = true,
        ["Winter's Embrace"] = true,
    },
    ["Necromancer"] = {
        ["Grave Lord"] = true,
        ["Bone Tyrant"] = true,
        ["Living Death"] = true,
    },
    ["Arcanist"] = {
        ["Herald of the Tome"] = true,
        ["Apocryphal Soldier"] = true,
        ["Curative Runeforms"] = true,
    },
}

-- Order for displaying skill types
CM.constants.SKILL_TYPE_ORDER = {
    "Class",
    "Weapon",
    "Armor",
    "World",
    "Guild",
    "Alliance War",
    "Racial",
    "Craft",
}

-- =====================================================
-- UI / DISPLAY CONSTANTS (New)
-- =====================================================

CM.constants.BAR_NAMES = {
    PRIMARY = "⚔️ Front Bar (Main Hand)",
    BACKUP = "🔮 Back Bar (Backup)",
}

CM.DebugPrint("UTILS", "Constants module loaded")
