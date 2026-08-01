-- BuildTracker_Constants.lua
-- Shared constants and the addon's global namespace table.
-- Every other file hangs its functions off BuildTracker so we never pollute
-- the global namespace beyond this one table.

BuildTracker = BuildTracker or {}
BuildTracker.name = "BuildTracker"
BuildTracker.displayName = "Arry's Set Build Tracking"
BuildTracker.version = "0.1.0"
BuildTracker.savedVarsVersion = 1

-- Internal event/message namespace prefix, used for CALLBACK_MANAGER events
-- the (future) UI and notification system can listen to.
BuildTracker.EVENTS = {
    BUILD_CREATED   = "BuildTracker_BuildCreated",
    BUILD_DELETED   = "BuildTracker_BuildDeleted",
    BUILD_RENAMED   = "BuildTracker_BuildRenamed",
    BUILD_CHANGED   = "BuildTracker_BuildChanged", -- any slot/notes change
    SLOT_SET        = "BuildTracker_SlotSet",
    SLOT_CLEARED    = "BuildTracker_SlotCleared",
    BUILDS_IMPORTED = "BuildTracker_BuildsImported",
}

-- The ordered list of equip slots we track per build. EQUIP_SLOT_* constants
-- are provided by the ESO client itself, no need to define them.
-- We keep front bar + back bar weapons separate since they're frequently
-- different sets (e.g. monster set front bar, 2pc mythic back bar).
BuildTracker.SLOT_ORDER = {
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
}

-- Human readable slot names, used for slash command testing now and UI labels later.
BuildTracker.SLOT_NAMES = {
    [EQUIP_SLOT_HEAD]        = "Head",
    [EQUIP_SLOT_SHOULDERS]   = "Shoulders",
    [EQUIP_SLOT_CHEST]       = "Chest",
    [EQUIP_SLOT_HAND]        = "Hands",
    [EQUIP_SLOT_WAIST]       = "Waist",
    [EQUIP_SLOT_LEGS]        = "Legs",
    [EQUIP_SLOT_FEET]        = "Feet",
    [EQUIP_SLOT_NECK]        = "Neck",
    [EQUIP_SLOT_RING1]       = "Ring 1",
    [EQUIP_SLOT_RING2]       = "Ring 2",
    [EQUIP_SLOT_MAIN_HAND]   = "Main Hand",
    [EQUIP_SLOT_OFF_HAND]    = "Off Hand",
    [EQUIP_SLOT_BACKUP_MAIN] = "Backup Main Hand",
    [EQUIP_SLOT_BACKUP_OFF]  = "Backup Off Hand",
}

-- Reverse lookup so slash commands / future UI can accept "head" and resolve
-- to the EQUIP_SLOT_* constant.
BuildTracker.SLOT_NAME_TO_ID = {}
for slotId, slotName in pairs(BuildTracker.SLOT_NAMES) do
    BuildTracker.SLOT_NAME_TO_ID[slotName:lower()] = slotId
end
-- a couple of convenient aliases
BuildTracker.SLOT_NAME_TO_ID["hands"] = EQUIP_SLOT_HAND
BuildTracker.SLOT_NAME_TO_ID["ring"]  = EQUIP_SLOT_RING1

-- Jewelry/weapon slots need a target weapon or armor sub-type when resolving
-- a specific itemId from LibSets (e.g. "give me the sword version, not the axe").
-- Armor slots don't need this since armor weight is a player choice baked
-- into the set anyway (light/medium/heavy all share the same set bonus).
BuildTracker.WEAPON_SLOTS = {
    [EQUIP_SLOT_MAIN_HAND]   = true,
    [EQUIP_SLOT_OFF_HAND]    = true,
    [EQUIP_SLOT_BACKUP_MAIN] = true,
    [EQUIP_SLOT_BACKUP_OFF]  = true,
}

function BuildTracker.IsWeaponSlot(slotId)
    return BuildTracker.WEAPON_SLOTS[slotId] == true
end

-- Only Main Hand/Backup Main can ever hold a two-handed weapon - a 2H
-- weapon occupies both hand slots on its own bar, so Off Hand/Backup Off
-- must always resolve to a one-handed item. Used by GetItemIdForSlot/
-- SetSupportsSlot (BuildTracker_LibSetsAdapter.lua) and the set picker's
-- weapon-type disambiguation dropdown to enforce this.
BuildTracker.CAN_BE_TWO_HANDED_SLOTS = {
    [EQUIP_SLOT_MAIN_HAND]   = true,
    [EQUIP_SLOT_BACKUP_MAIN] = true,
}

-- Maps an EQUIP_SLOT_* to the matching EQUIP_TYPE_* LibSets expects. This is
-- a simplification: real ESO equip types distinguish e.g. light/medium/heavy
-- armor, which the player chooses independently of the set. For armor slots
-- we default to EQUIP_TYPE_*; refine this once the UI lets the user pick
-- armor weight per slot.
-- Shared by the slash command handler and the paperdoll/set-picker UI so
-- there's one copy. All four weapon slots map to EQUIP_TYPE_ONE_HAND here,
-- but that's only a first-pass default now, not a hard requirement -
-- Sets.GetItemIdForSlot (BuildTracker_LibSetsAdapter.lua) derives the real
-- required equip type from the chosen weaponType once one is picked, so
-- two-handed weapons resolve correctly despite this table's literal value.
BuildTracker.SLOT_TO_EQUIP_TYPE = {
    [EQUIP_SLOT_HEAD]      = EQUIP_TYPE_HEAD,
    [EQUIP_SLOT_SHOULDERS] = EQUIP_TYPE_SHOULDERS,
    [EQUIP_SLOT_CHEST]     = EQUIP_TYPE_CHEST,
    [EQUIP_SLOT_HAND]      = EQUIP_TYPE_HAND,
    [EQUIP_SLOT_WAIST]     = EQUIP_TYPE_WAIST,
    [EQUIP_SLOT_LEGS]      = EQUIP_TYPE_LEGS,
    [EQUIP_SLOT_FEET]      = EQUIP_TYPE_FEET,
    [EQUIP_SLOT_NECK]      = EQUIP_TYPE_NECK,
    [EQUIP_SLOT_RING1]     = EQUIP_TYPE_RING,
    [EQUIP_SLOT_RING2]     = EQUIP_TYPE_RING,
    [EQUIP_SLOT_MAIN_HAND]   = EQUIP_TYPE_ONE_HAND, -- refine with weaponType arg (see IsWeaponSlot)
    [EQUIP_SLOT_OFF_HAND]    = EQUIP_TYPE_ONE_HAND,
    [EQUIP_SLOT_BACKUP_MAIN] = EQUIP_TYPE_ONE_HAND,
    [EQUIP_SLOT_BACKUP_OFF]  = EQUIP_TYPE_ONE_HAND,
}

-- Strips ESO's reserved "|" text-formatting escape character from any
-- free-text string before it's shown in a live UI control label. Build
-- names are user-entered free text and are never trusted to be safe.
function BuildTracker.SanitizeDisplayText(text)
    if not text then return "" end
    return (text:gsub("|", ""))
end

function BuildTracker.Debug(...)
    if BuildTracker.debugEnabled then
        d("|cFFA500[BT]|r " .. string.format(...))
    end
end

-- Shared header/button text color for the custom UI windows - ZO_SELECTED_TEXT
-- is the base game's own warm-gold highlight color object (the same one
-- used for e.g. selected list entries and highlighted names across the
-- native UI, and referenced the same way by other addons like LuiExtended),
-- used directly here instead of a hand-picked hex so this always matches
-- ESO's real theme rather than an approximation - per user request, after
-- two flat-hex guesses (a hand-picked warm gold, then #FDF5E6/Old Lace)
-- both read as too plain/washed-out in practice. White text (slot labels,
-- hover-highlight state) is untouched by this.
local goldR, goldG, goldB, goldA = ZO_SELECTED_TEXT:UnpackRGBA()
BuildTracker.UI_GOLD_TEXT = { goldR, goldG, goldB, goldA }

-- Border recipe - after two guessed attempts (EsoUI/Art/Tooltips/UI-Border.dds
-- with a manual SetInsets, which fixed a double-border gap bug but then
-- turned out to be a plain white/silver texture, not gold) both fell short
-- in-game, this is copied EXACTLY from LibSets' own SearchUI window - a
-- REAL, currently-installed, confirmed-good-looking reference the user
-- pointed at directly (LibSets_SearchUI_Shared.xml's "LibSetsSearchUIBackdrop"
-- virtual template) - rather than guessing a third time:
--   <Anchor point="TOPLEFT" offsetX="-4" offsetY="-4"/>
--   <Anchor point="BOTTOMRIGHT" offsetX="4" offsetY="4"/>
--   <Edge file="EsoUI/Art/Miscellaneous/dark_edgeFrame_8_thin.dds" edgeFileWidth="64" edgeFileHeight="8" />
-- The backdrop is outset 4px beyond whatever it's anchored to (rather than
-- flush-filled + inset, which is what produced the double-border gap) and
-- uses an 8px-tall edge instead of UI-Border.dds's 16px one - both likely
-- contributors to why the two earlier guesses didn't read as a clean
-- single-color frame at this window's scale.
--
-- anchorTarget is what the border should wrap - pass the control's own
-- window/popup to outset-anchor a full window border; omit it for a
-- control (like the paperdoll's own section cards) that's already
-- independently positioned/sized by its own anchor chain and shouldn't be
-- re-anchored relative to itself.
--
-- SetEdgeColor still tints with UI_GOLD_TEXT (the real ZO_SELECTED_TEXT
-- gold) rather than leaving this texture's own native color - unconfirmed
-- whether dark_edgeFrame_8_thin.dds renders gold on its own or needs the
-- same tint UI-Border.dds did; revisit if this also reads as the wrong
-- color in-game.
BuildTracker.UI_BORDER_TEXTURE = "EsoUI/Art/Miscellaneous/dark_edgeFrame_8_thin.dds"
function BuildTracker.ApplyWindowBorder(control, anchorTarget)
    if anchorTarget then
        control:SetAnchor(TOPLEFT, anchorTarget, TOPLEFT, -4, -4)
        control:SetAnchor(BOTTOMRIGHT, anchorTarget, BOTTOMRIGHT, 4, 4)
    end
    control:SetEdgeTexture(BuildTracker.UI_BORDER_TEXTURE, 64, 8)
    control:SetEdgeColor(unpack(BuildTracker.UI_GOLD_TEXT))
end

-- Display name for the (optional, unbound by default) paperdoll keybind
-- action defined in BuildTracker_Bindings.xml - shown under Controls >
-- Keybindings > "Arry's Set Build Tracking" so the user can assign a key.
-- ZO_CreateStringId is the standard base-game call for addons to register a
-- new localized string constant (confirmed via several other installed
-- addons doing exactly this for their own keybind names, e.g. CompsWBTimer).
-- Display text only - keeps saying "Paperdoll" internally (string id name,
-- code, comments) per user request; only what the user actually reads changed.
ZO_CreateStringId("SI_BINDING_NAME_BUILDTRACKER_TOGGLE_PAPERDOLL", "Toggle Build Tracker Build List")
