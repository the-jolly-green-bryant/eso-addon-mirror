-- Trait Scout
-- Checks items sitting in an open loot window and tells you, in chat, when
-- one has a trait you have NOT yet researched on that gear type.
--
-- Detection: GetNumLootItems / GetLootItemInfo / GetLootItemLink /
-- GetItemLinkTraitInfo are the same functions used by established, widely
-- used addons (BearLoot, Dolgubon's Lazy Writ Crafter) - not guesses.
--
-- The research CHECK itself is delegated to LibResearch, a mature, actively
-- maintained community library built specifically for this calculation
-- (including edge cases like ornate/intricate items). This addon does not
-- try to re-derive that logic itself.
--
-- The one piece built from general ESO game-design knowledge rather than a
-- single verified API call: mapping a weapon/armor TYPE to the numeric
-- "research line index" LibResearch expects. That ordering is stable,
-- public, documented crafting-system structure - not fragile internals -
-- but it's still the part most worth double-checking if something's ever
-- flagged wrong.

local ADDON_NAME = "TraitScout"

local defaults = {
    enabled = true,
    debug   = false,
    seen    = {},   -- [lootId] = true, so we don't re-announce the same item repeatedly
}
local sv

local function Dbg(msg) if sv and sv.debug then d("|c66FFCC[Trait Scout]|r " .. msg) end end
local function Msg(msg) d("|c66FFCC[Trait Scout]|r " .. msg) end

-- ---------------------------------------------------------------------------
-- Weapon/armor type -> (craftingSkillType, researchLineIndex)
-- Standard ESO crafting research line ordering. Jewelry and the two crafting
-- skill lines added later (jewelry crafting) are included.
-- ---------------------------------------------------------------------------
local WEAPON_LINES = {
    [WEAPONTYPE_AXE]          = 0,
    [WEAPONTYPE_HAMMER]       = 1,
    [WEAPONTYPE_SWORD]        = 2,
    [WEAPONTYPE_TWO_HANDED_SWORD]  = 3,
    [WEAPONTYPE_TWO_HANDED_AXE]    = 3,
    [WEAPONTYPE_TWO_HANDED_HAMMER] = 3,
    [WEAPONTYPE_BOW]          = 4,
    [WEAPONTYPE_FIRE_STAFF]   = 5,
    [WEAPONTYPE_FROST_STAFF]  = 5,
    [WEAPONTYPE_SHOCK_STAFF]  = 5,
    [WEAPONTYPE_HEALING_STAFF]= 5,
    [WEAPONTYPE_DAGGER]       = 6,
}

local ARMOR_LINES_LIGHT_MEDIUM_HEAVY = {
    -- Same relative ordering repeats per weight; EQUIP_TYPE determines slot.
    [EQUIP_TYPE_HEAD]    = 0,
    [EQUIP_TYPE_SHOULDERS] = 1,
    [EQUIP_TYPE_CHEST]   = 2,
    [EQUIP_TYPE_HAND]    = 3,
    [EQUIP_TYPE_WAIST]   = 4,
    [EQUIP_TYPE_LEGS]    = 5,
    [EQUIP_TYPE_FEET]    = 6,
    [EQUIP_TYPE_OFF_HAND] = 7,  -- shields (heavy line)
}

local JEWELRY_LINES = {
    [EQUIP_TYPE_NECK] = 0,
    [EQUIP_TYPE_RING] = 1,
}

-- Returns craftingSkillType, researchLineIndex or nil if this item isn't a
-- researchable-craft item type at all.
local function GetResearchCoordinates(itemLink)
    local itemType = GetItemLinkItemType(itemLink)

    if itemType == ITEMTYPE_WEAPON then
        local weaponType = GetItemLinkWeaponType and GetItemLinkWeaponType(itemLink)
        local line = weaponType and WEAPON_LINES[weaponType]
        if line then return CRAFTING_TYPE_BLACKSMITHING, line end
        return nil

    elseif itemType == ITEMTYPE_ARMOR then
        local equipType = GetItemLinkEquipType and GetItemLinkEquipType(itemLink)
        if equipType == EQUIP_TYPE_NECK or equipType == EQUIP_TYPE_RING then
            local line = JEWELRY_LINES[equipType]
            if line then return CRAFTING_TYPE_JEWELRYCRAFTING, line end
            return nil
        end

        local armorType = GetItemLinkArmorType and GetItemLinkArmorType(itemLink)
        local line = equipType and ARMOR_LINES_LIGHT_MEDIUM_HEAVY[equipType]
        if not line then return nil end

        if armorType == ARMORTYPE_LIGHT then return CRAFTING_TYPE_CLOTHIER, line
        elseif armorType == ARMORTYPE_MEDIUM then return CRAFTING_TYPE_CLOTHIER, line
        elseif armorType == ARMORTYPE_HEAVY then return CRAFTING_TYPE_BLACKSMITHING, line
        end
    end
    return nil
end

-- ---------------------------------------------------------------------------
-- Core check: does this item have a trait we haven't researched on this line?
-- ---------------------------------------------------------------------------
local function CheckItem(itemLink, displayName)
    if not LibResearch then
        return  -- handled once at load with a warning; stay quiet per-item
    end

    local traitType = GetItemLinkTraitInfo(itemLink)
    if not traitType or traitType == ITEM_TRAIT_TYPE_NONE then
        Dbg(displayName .. ": no trait")
        return
    end

    local craftingSkillType, researchLineIndex = GetResearchCoordinates(itemLink)
    if not craftingSkillType then
        Dbg(displayName .. ": not a mapped gear type")
        return
    end

    -- LibResearch wants a traitIndex (position within that research line),
    -- not the raw traitType id. GetTraitTypeToTraitIndex is the library's
    -- own documented helper for that conversion.
    local traitIndex = LibResearch.GetTraitTypeToTraitIndex
        and LibResearch:GetTraitTypeToTraitIndex(craftingSkillType, researchLineIndex, traitType)
    if not traitIndex then
        Dbg(displayName .. ": couldn't resolve trait index")
        return
    end

    local ok, traitKey, isResearchable, reason = pcall(function()
        return LibResearch:WillCharacterKnowTrait(craftingSkillType, researchLineIndex, traitIndex)
    end)
    if not ok then
        Dbg(displayName .. ": LibResearch call failed - " .. tostring(traitKey))
        return
    end

    Dbg(string.format("%s: traitKey=%s isResearchable=%s reason=%s",
        displayName, tostring(traitKey), tostring(isResearchable), tostring(reason)))

    if isResearchable then
        local traitName = GetString("SI_ITEMTRAITTYPE", traitType) or "trait"
        Msg(string.format("Unresearched %s on %s!", traitName, displayName))
    end
end

-- ---------------------------------------------------------------------------
-- Loot window scan
-- ---------------------------------------------------------------------------
local function ScanLoot()
    if not sv.enabled then return end

    for i = 1, GetNumLootItems() do
        local lootId, name = GetLootItemInfo(i)
        if lootId and not sv.seen[lootId] then
            sv.seen[lootId] = true
            local itemLink = GetLootItemLink(lootId, LINK_STYLE_DEFAULT)
            if itemLink and itemLink ~= "" then
                local ok, err = pcall(CheckItem, itemLink, name or "item")
                if not ok then Dbg("CheckItem error: " .. tostring(err)) end
            end
        end
    end
end

local function OnLootUpdated()
    ScanLoot()
end

local function OnLootClosed()
    sv.seen = {}  -- reset so the same item can be re-announced on a future loot
end

-- ---------------------------------------------------------------------------
-- Slash commands
-- ---------------------------------------------------------------------------
local function RegisterSlash()
    SLASH_COMMANDS["/traitscout"] = function(args)
        args = zo_strtrim(args or "")
        local cmd = zo_strlower(args)
        if cmd == "on" then
            sv.enabled = true; Msg("Enabled")
        elseif cmd == "off" then
            sv.enabled = false; Msg("Disabled")
        elseif cmd == "debug" then
            sv.debug = not sv.debug; Msg("debug=" .. tostring(sv.debug))
        else
            Msg("/traitscout on|off|debug")
        end
    end
end

-- ---------------------------------------------------------------------------
-- Optional LAM panel
-- ---------------------------------------------------------------------------
local panelBuilt = false
local function BuildSettingsPanel()
    local LAM = LibAddonMenu2
    if not LAM then return end
    panelBuilt = true

    LAM:RegisterAddonPanel("TraitScoutPanel", {
        type = "panel", name = "Trait Scout",
        author = "@Dicen95728", version = "1.0", registerForRefresh = true,
    })
    LAM:RegisterOptionControls("TraitScoutPanel", {
        { type = "checkbox", name = "Enabled",
          getFunc = function() return sv.enabled end,
          setFunc = function(v) sv.enabled = v end },
        { type = "description",
          text = LibResearch and "LibResearch found - fully active." or "LibResearch NOT found - install it for this addon to work." },
    })
end

-- ---------------------------------------------------------------------------
-- Init
-- ---------------------------------------------------------------------------
local function OnAddOnLoaded(_, addOnName)
    if addOnName ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    sv = ZO_SavedVars:NewAccountWide("TraitScoutSV", 1, nil, defaults)
    if type(sv.seen) ~= "table" then sv.seen = {} end

    if not LibResearch then
        Msg("LibResearch not found - this addon needs it to check trait research. Install LibResearch and reload.")
    end

    RegisterSlash()

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_LOOT_UPDATED, OnLootUpdated)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_LOOT_CLOSED, OnLootClosed)

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, function()
        EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED)
        if not panelBuilt then BuildSettingsPanel() end
    end)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
