-- CharacterMarkdown - Quality and Emoji Utilities
-- Item quality, slot emojis, etc.

local CM = CharacterMarkdown

-- =====================================================
-- QUALITY HELPERS
-- =====================================================

-- Get quality name from quality constant (ESO standard names)
local function GetQualityColor(quality)
    local colors = {
        [ITEM_QUALITY_TRASH] = "Trash",
        [ITEM_QUALITY_NORMAL] = "Normal", -- White
        [ITEM_QUALITY_MAGIC] = "Fine", -- Green
        [ITEM_QUALITY_ARCANE] = "Superior", -- Blue
        [ITEM_QUALITY_ARTIFACT] = "Epic", -- Purple
        [ITEM_QUALITY_LEGENDARY] = "Legendary", -- Gold
    }
    return colors[quality] or "Unknown"
end

CM.utils.GetQualityColor = GetQualityColor

-- Get quality constant from quality string name (inverse of GetQualityColor)
-- Uses ESO standard names as primary, with old names as aliases for backward compatibility
local function GetQualityConstantFromString(qualityString)
    if not qualityString then
        return ITEM_QUALITY_NORMAL
    end

    local stringLower = qualityString:lower()
    local mapping = {
        -- ESO standard names (primary)
        normal = ITEM_QUALITY_NORMAL, -- White
        fine = ITEM_QUALITY_MAGIC, -- Green
        superior = ITEM_QUALITY_ARCANE, -- Blue
        epic = ITEM_QUALITY_ARTIFACT, -- Purple
        legendary = ITEM_QUALITY_LEGENDARY, -- Gold
        -- Old names (aliases for backward compatibility)
        trash = ITEM_QUALITY_TRASH,
        magic = ITEM_QUALITY_MAGIC, -- Alias for Fine
        arcane = ITEM_QUALITY_ARCANE, -- Alias for Superior
        artifact = ITEM_QUALITY_ARTIFACT, -- Alias for Epic
    }

    return mapping[stringLower] or ITEM_QUALITY_NORMAL
end

CM.utils.GetQualityConstantFromString = GetQualityConstantFromString

-- Get quality emoji from quality constant
local function GetQualityEmoji(quality)
    local emojis = {
        [ITEM_QUALITY_TRASH] = "⚪",
        [ITEM_QUALITY_NORMAL] = "⚪",
        [ITEM_QUALITY_MAGIC] = "⚡",
        [ITEM_QUALITY_ARCANE] = "🔮",
        [ITEM_QUALITY_ARTIFACT] = "⭐",
        [ITEM_QUALITY_LEGENDARY] = "👑",
    }
    return emojis[quality] or "⚪"
end

CM.utils.GetQualityEmoji = GetQualityEmoji

-- =====================================================
-- EQUIPMENT SLOT HELPERS
-- =====================================================

-- Get equipment slot name from slot index
local function GetEquipSlotName(slotIndex)
    local slots = {
        [EQUIP_SLOT_HEAD] = "Head",
        [EQUIP_SLOT_NECK] = "Neck",
        [EQUIP_SLOT_CHEST] = "Chest",
        [EQUIP_SLOT_SHOULDERS] = "Shoulders",
        [EQUIP_SLOT_MAIN_HAND] = "Main Hand",
        [EQUIP_SLOT_OFF_HAND] = "Off Hand",
        [EQUIP_SLOT_WAIST] = "Waist",
        [EQUIP_SLOT_LEGS] = "Legs",
        [EQUIP_SLOT_FEET] = "Feet",
        [EQUIP_SLOT_COSTUME] = "Costume",
        [EQUIP_SLOT_RING1] = "Ring 1",
        [EQUIP_SLOT_RING2] = "Ring 2",
        [EQUIP_SLOT_HAND] = "Hands",
        [EQUIP_SLOT_BACKUP_MAIN] = "Backup Main Hand",
        [EQUIP_SLOT_BACKUP_OFF] = "Backup Off Hand",
    }
    return slots[slotIndex] or "Unknown"
end

CM.utils.GetEquipSlotName = GetEquipSlotName

-- Get emoji for equipment slot
-- Using widely-supported Unicode emojis (no newer/variant emojis for better compatibility)
local function GetSlotEmoji(slotIndex)
    local emojis = {
        [EQUIP_SLOT_HEAD] = "⛑️", -- Changed from 🪖 (newer emoji) to ⛑️ (widely supported)
        [EQUIP_SLOT_NECK] = "💎", -- Changed from 📿 (may not render) to 💎 (widely supported)
        [EQUIP_SLOT_CHEST] = "🛡️",
        [EQUIP_SLOT_SHOULDERS] = "👑",
        [EQUIP_SLOT_MAIN_HAND] = "⚔️",
        [EQUIP_SLOT_OFF_HAND] = "🛡️",
        [EQUIP_SLOT_WAIST] = "⚡",
        [EQUIP_SLOT_LEGS] = "👖", -- Changed from 🦵 (newer emoji) to 👖 (widely supported)
        [EQUIP_SLOT_FEET] = "👟", -- Changed from 👢 (may not render) to 👟 (widely supported)
        [EQUIP_SLOT_RING1] = "💍",
        [EQUIP_SLOT_RING2] = "💍",
        [EQUIP_SLOT_HAND] = "✋", -- Changed from 🧤 (newer emoji) to ✋ (widely supported)
        [EQUIP_SLOT_BACKUP_MAIN] = "🔮",
        [EQUIP_SLOT_BACKUP_OFF] = "🛡️",
    }
    return emojis[slotIndex] or "📦"
end

CM.utils.GetSlotEmoji = GetSlotEmoji
