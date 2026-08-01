local HARDCORE = HARDCORE

local ID = "OathboundWeapon"
local NS = "HARDCORE_OathboundWeapon"

local ICON_OATHBOUND_WEAPON = "/esoui/art/crafting/smithing_tabicon_weaponset_up.dds"

local Rule = {
    id = ID,
    title = "Oathbound Weapon: one weapon type only",
    icon = ICON_OATHBOUND_WEAPON,
    defaultEnabled = false
}

Rule.active = false
Rule._lastAlertMs = 0
Rule._lastBindAlertMs = 0

local WEAPON_SLOTS = {
    EQUIP_SLOT_MAIN_HAND,
    EQUIP_SLOT_BACKUP_MAIN,
    EQUIP_SLOT_OFF_HAND,
    EQUIP_SLOT_BACKUP_OFF
}

local WEAPON_TYPE_NAMES = {
    [WEAPONTYPE_AXE] = "Axe",
    [WEAPONTYPE_BOW] = "Bow",
    [WEAPONTYPE_DAGGER] = "Dagger",
    [WEAPONTYPE_FIRE_STAFF] = "Fire Staff",
    [WEAPONTYPE_FROST_STAFF] = "Frost Staff",
    [WEAPONTYPE_HAMMER] = "Hammer",
    [WEAPONTYPE_HEALING_STAFF] = "Restoration Staff",
    [WEAPONTYPE_LIGHTNING_STAFF] = "Lightning Staff",
    [WEAPONTYPE_RUNE] = "Rune",
    [WEAPONTYPE_SHIELD] = "Shield",
    [WEAPONTYPE_SWORD] = "Sword",
    [WEAPONTYPE_TWO_HANDED_AXE] = "Two-Handed Axe",
    [WEAPONTYPE_TWO_HANDED_HAMMER] = "Two-Handed Hammer",
    [WEAPONTYPE_TWO_HANDED_SWORD] = "Two-Handed Sword"
}

local function GetSV()
    HARDCORE = HARDCORE or {}
    if not HARDCORE.oathboundWeaponSaved then
        HARDCORE.oathboundWeaponSaved = ZO_SavedVars:NewCharacterIdSettings(
            "HARDCORE_OATHBOUND_WEAPON_SV", 1, nil, {
                weaponType = nil
            }, GetWorldName())
    end

    local sv = HARDCORE.oathboundWeaponSaved
    if not WEAPON_TYPE_NAMES[sv.weaponType] then
        sv.weaponType = nil
    end
    return sv
end

local function IsHardcoreActive()
    return HARDCORE and HARDCORE.saved and HARDCORE.saved.isActive
end

local function CanUnequipNow()
    return not (IsUnitInCombat and IsUnitInCombat("player"))
end

local function GetWornLink(equipSlot)
    local link = GetItemLink(BAG_WORN, equipSlot)
    if link and link ~= "" then
        return link
    end
    return nil
end

local function GetWornWeaponType(equipSlot)
    local link = GetWornLink(equipSlot)
    if not link then
        return nil
    end

    local weaponType = GetItemLinkWeaponType(link)
    if WEAPON_TYPE_NAMES[weaponType] then
        return weaponType
    end
    return nil
end

local function FindFirstWornWeaponType()
    for _, equipSlot in ipairs(WEAPON_SLOTS) do
        local weaponType = GetWornWeaponType(equipSlot)
        if weaponType then
            return weaponType
        end
    end
    return nil
end

local function Alert(message)
    local now = GetFrameTimeMilliseconds()
    if now - Rule._lastAlertMs > 1500 then
        HARDCORE.ShowAlertNoSuppression(UI_ALERT_CATEGORY_ALERT, SOUNDS.NEGATIVE_CLICK, message)
        Rule._lastAlertMs = now
    end
end

local function AlertBound(weaponType)
    local now = GetFrameTimeMilliseconds()
    if now - Rule._lastBindAlertMs > 1500 then
        HARDCORE.ShowAlertNoSuppression(UI_ALERT_CATEGORY_ALERT, SOUNDS.QUEST_ACCEPTED,
            "HARDCORE: Oathbound Weapon bound to " .. WEAPON_TYPE_NAMES[weaponType] .. ".")
        Rule._lastBindAlertMs = now
    end
end

local function EnsureWeaponOath()
    local sv = GetSV()
    if sv.weaponType then
        return sv.weaponType
    end

    local weaponType = FindFirstWornWeaponType()
    if weaponType then
        sv.weaponType = weaponType
        AlertBound(weaponType)
    end
    return sv.weaponType
end

local function UnequipSlot(equipSlot)
    local hasItem, _icon, _heldSlot, _heldNow, locked = GetWornItemInfo(BAG_WORN, equipSlot)
    if hasItem and not locked then
        RequestUnequipItem(BAG_WORN, equipSlot)
        return true
    end
    return false
end

local function EnforceOathboundWeapon()
    if not (Rule.active and IsHardcoreActive()) then
        return
    end
    if not CanUnequipNow() then
        return
    end

    local allowedWeaponType = EnsureWeaponOath()
    if not allowedWeaponType then
        return
    end

    local changed = false
    for _, equipSlot in ipairs(WEAPON_SLOTS) do
        local weaponType = GetWornWeaponType(equipSlot)
        if weaponType and weaponType ~= allowedWeaponType and UnequipSlot(equipSlot) then
            changed = true
        end
    end

    if changed then
        Alert("HARDCORE: Oathbound Weapon allows only " .. WEAPON_TYPE_NAMES[allowedWeaponType] .. ".")
    end
end

local function OnInventoryChange(_, bagId)
    if Rule.active and bagId == BAG_WORN then
        zo_callLater(EnforceOathboundWeapon, 50)
    end
end

local function RegisterEvents()
    EVENT_MANAGER:UnregisterForEvent(NS .. "_INV", EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    EVENT_MANAGER:UnregisterForEvent(NS .. "_SWAP", EVENT_ACTIVE_WEAPON_PAIR_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(NS .. "_ACTIVATED", EVENT_PLAYER_ACTIVATED)
    EVENT_MANAGER:UnregisterForEvent(NS .. "_COMBAT", EVENT_PLAYER_COMBAT_STATE)

    EVENT_MANAGER:RegisterForEvent(NS .. "_INV", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnInventoryChange)
    EVENT_MANAGER:AddFilterForEvent(NS .. "_INV", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN)
    EVENT_MANAGER:RegisterForEvent(NS .. "_SWAP", EVENT_ACTIVE_WEAPON_PAIR_CHANGED, function()
        zo_callLater(EnforceOathboundWeapon, 50)
    end)
    EVENT_MANAGER:RegisterForEvent(NS .. "_ACTIVATED", EVENT_PLAYER_ACTIVATED, function()
        zo_callLater(EnforceOathboundWeapon, 200)
    end)
    EVENT_MANAGER:RegisterForEvent(NS .. "_COMBAT", EVENT_PLAYER_COMBAT_STATE, function(_, inCombat)
        if not inCombat then
            zo_callLater(EnforceOathboundWeapon, 120)
        end
    end)
end

local function UnregisterEvents()
    EVENT_MANAGER:UnregisterForEvent(NS .. "_INV", EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    EVENT_MANAGER:UnregisterForEvent(NS .. "_SWAP", EVENT_ACTIVE_WEAPON_PAIR_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(NS .. "_ACTIVATED", EVENT_PLAYER_ACTIVATED)
    EVENT_MANAGER:UnregisterForEvent(NS .. "_COMBAT", EVENT_PLAYER_COMBAT_STATE)
end

function Rule:OnEnable()
    self.active = true
    GetSV()
    RegisterEvents()
    zo_callLater(EnforceOathboundWeapon, 100)
end

function Rule:OnDisable()
    self.active = false
    UnregisterEvents()
end

function Rule:GetSelectedWeaponType()
    return GetSV().weaponType
end

function HARDCORE.GetOathboundWeaponType()
    return GetSV().weaponType
end

HARDCORE.RuleManager:RegisterRule(Rule)
