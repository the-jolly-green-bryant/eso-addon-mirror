-- Common Works -- color themes
--
-- Every colour the panel draws comes from a palette slot. UI.SyncTheme darkens
-- footerLabel with Dim() for empty-state text and ages.

CommonWorksUI = CommonWorksUI or {}
local CW = CommonWorksUI

local function Hex(s, alpha)
    return {
        tonumber(s:sub(1, 2), 16) / 255,
        tonumber(s:sub(3, 4), 16) / 255,
        tonumber(s:sub(5, 6), 16) / 255,
        alpha or 1,
    }
end

-- Divider alpha is the fourth color component, shared with the picker.
-- Use accentBright to keep the tint visible at 10% opacity on dark panels.
local DIVIDER_ALPHA = 0.10
local function Rule(s)
    return Hex(s, DIVIDER_ALPHA)
end

-- Where each slot lands:
--
--   accent       section headers and the queue name
--   accentSoft   Weekly / Seasonal and Tracked Quests sub-headers
--   accentBright a quest title or tome filter under the cursor
--   rule         the rule above every header
--   title        focused quest name
--   count        focused progress counter
--   footerLabel  the "Siege:" label on a keep row
--   body         objective rows and other plain text
--
-- Keep done green, repeatables distinct and danger warm, adjusting for each palette.
--
--   finished     an objective already met, and every green check
--   recurring    daily and weekly: blended into the quest title, and the section icons
--   pvpBad       keep is cut off, or a temple's scroll is stolen
CW.PALETTES = {
    {
        id = "monochrome", label = "Monochrome",
        accent = Hex("FFFFFF"), accentSoft = Hex("EBE4B8"), accentBright = Hex("E8E8E8"),
        rule = Hex("FFFFFF", 0.205),
        title = Hex("FFFFFF"), count = Hex("20F4FF"), footerLabel = Hex("94969B"),
        body = Hex("E5E5E5"),
        finished = Hex("74C48A"), recurring = Hex("5FAFC2"),
        pvpBad = Hex("D97A62"),
    },
    {
        id = "ocean", label = "Ocean",
        accent = Hex("7FB8C9"), accentSoft = Hex("9A8CC0"), accentBright = Hex("CFE3E8"),
        rule = Rule("CFE3E8"),
        title = Hex("DCE7EC"), count = Hex("4FD6F2"), footerLabel = Hex("7E8A99"),
        body = Hex("CBD9E0"),
        finished = Hex("7FD1A4"), recurring = Hex("A78BD0"),
        pvpBad = Hex("D98374"),
    },
    {
        id = "desert", label = "Desert",
        accent = Hex("D9A05B"), accentSoft = Hex("C98F63"), accentBright = Hex("EFD3A8"),
        rule = Rule("EFD3A8"),
        title = Hex("EBD9BE"), count = Hex("FFC43D"), footerLabel = Hex("A08A6E"),
        body = Hex("DFD2BC"),
        finished = Hex("A9C47A"), recurring = Hex("7FB8A6"),
        pvpBad = Hex("D98A5B"),
    },
    {
        id = "air", label = "Air",
        accent = Hex("A8CBE0"), accentSoft = Hex("7FA3C4"), accentBright = Hex("DCEAF3"),
        rule = Rule("DCEAF3"),
        title = Hex("E3EDF4"), count = Hex("5CC8FF"), footerLabel = Hex("7E8E9C"),
        body = Hex("D3E1EC"),
        finished = Hex("9FD4B0"), recurring = Hex("C9A97E"),
        pvpBad = Hex("DE8F7A"),
    },
    {
        id = "forest", label = "Forest",
        accent = Hex("A3B87C"), accentSoft = Hex("C4B896"), accentBright = Hex("DCE4C4"),
        rule = Rule("DCE4C4"),
        title = Hex("E0E4D0"), count = Hex("EBC84A"), footerLabel = Hex("8C8A72"),
        body = Hex("D6DCC4"),
        finished = Hex("A3D18A"), recurring = Hex("8FB6C9"),
        pvpBad = Hex("D18A6B"),
    },
    {
        id = "plum", label = "Plum",
        accent = Hex("B394B8"), accentSoft = Hex("C49AA6"), accentBright = Hex("E6D5E8"),
        rule = Rule("E6D5E8"),
        title = Hex("E4DAE6"), count = Hex("E283F5"), footerLabel = Hex("8E7F92"),
        body = Hex("DACFDD"),
        finished = Hex("9FD1A8"), recurring = Hex("8FC2B4"),
        pvpBad = Hex("D98495"),
    },
    {
        id = "ash", label = "Ash",
        accent = Hex("C8503C"), accentSoft = Hex("B8683F"), accentBright = Hex("E88A6E"),
        rule = Rule("E88A6E"),
        title = Hex("D4D4D4"), count = Hex("E0673A"), footerLabel = Hex("7C7C7C"),
        body = Hex("B4B4B4"),
        finished = Hex("A8C48C"), recurring = Hex("8FB4C4"),
        pvpBad = Hex("FF4A3D"),
    },
}

CW.DEFAULT_PALETTE = "monochrome"

-- Dropdown choices, in table order.
CW.PALETTE_NAMES = {}
local byId, byLabel = {}, {}
for _, p in ipairs(CW.PALETTES) do
    CW.PALETTE_NAMES[#CW.PALETTE_NAMES + 1] = p.label
    byId[p.id] = p
    byLabel[p.label] = p
end

function CW.GetPalette(id)
    return byId[id] or byId[CW.DEFAULT_PALETTE]
end

function CW.GetPaletteLabel(id)
    return CW.GetPalette(id).label
end

function CW.GetPaletteIdByLabel(label)
    local p = byLabel[label]
    return p and p.id or CW.DEFAULT_PALETTE
end

-- Pickers, and the slot each takes its value from. A theme switch and "Reset to
-- defaults" both clear a stale custom color through this list.
CW.PALETTE_PICKER_KEYS = {
    headerColor             = "accent",
    activeTitleColor        = "title",
    activeCountColor        = "count",
    trackedTomeHeaderColor  = "accentSoft",
    dividerColor            = "rule",
    activeObjColor          = "body",
    activeDoneColor         = "finished",
}

-- Fresh table every call: these land in saved variables, and a shared one would make
-- editing one key edit another.
function CW.GetPaletteColor(paletteId, pickerKey)
    local c = CW.GetPalette(paletteId)[CW.PALETTE_PICKER_KEYS[pickerKey]]
    return { c[1], c[2], c[3], c[4] }
end

-- Overwrites every picker by design: hand-set colors left in place would give a
-- half-applied theme with no obvious way back.
function CW.ApplyPreset(paletteId)
    local t = CW.SavedVars.appearance
    t.preset = CW.GetPalette(paletteId).id
    for key in pairs(CW.PALETTE_PICKER_KEYS) do
        t[key] = CW.GetPaletteColor(t.preset, key)
    end
end
