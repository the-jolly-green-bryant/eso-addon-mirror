local HARDCORE = HARDCORE

local ID = "Barbarian"
local NS = "HARDCORE_Barbarian"

local ICON_BARBARIAN = "/esoui/art/inventory/inventory_tabicon_2handed_up.dds"

local Rule = {
    id = ID,
    title = "Barbarian: two-handed heavy armor only",
    icon = ICON_BARBARIAN,
    defaultEnabled = false
}

Rule.active = false
Rule._lastAlertMs = 0
Rule._lastReason = nil

local FORBIDDEN_ARMOR_SLOTS = {
    EQUIP_SLOT_HEAD,
    EQUIP_SLOT_CHEST
}

local HEAVY_ARMOR_SLOTS = {
    EQUIP_SLOT_SHOULDERS,
    EQUIP_SLOT_HAND,
    EQUIP_SLOT_WAIST,
    EQUIP_SLOT_LEGS,
    EQUIP_SLOT_FEET
}

local MAIN_HAND_SLOTS = {
    EQUIP_SLOT_MAIN_HAND,
    EQUIP_SLOT_BACKUP_MAIN
}

local OFF_HAND_SLOTS = {
    EQUIP_SLOT_OFF_HAND,
    EQUIP_SLOT_BACKUP_OFF
}

local TWO_HANDED_WEAPON_TYPES = {
    [WEAPONTYPE_TWO_HANDED_AXE] = true,
    [WEAPONTYPE_TWO_HANDED_HAMMER] = true,
    [WEAPONTYPE_TWO_HANDED_SWORD] = true
}

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

local function Alert(reason)
    local now = GetFrameTimeMilliseconds()
    if reason ~= Rule._lastReason or now - Rule._lastAlertMs > 1500 then
        HARDCORE.ShowAlertNoSuppression(UI_ALERT_CATEGORY_ALERT, SOUNDS.NEGATIVE_CLICK,
            "HARDCORE: Barbarian allows only two-handed weapons, heavy armor, and no head/chest armor.")
        Rule._lastAlertMs = now
        Rule._lastReason = reason
    end
end

local function IsTwoHandedWeapon(link)
    local weaponType = GetItemLinkWeaponType(link)
    return TWO_HANDED_WEAPON_TYPES[weaponType] == true
end

local function UnequipSlot(equipSlot)
    local hasItem, _icon, _heldSlot, _heldNow, locked = GetWornItemInfo(BAG_WORN, equipSlot)
    if hasItem and not locked then
        RequestUnequipItem(BAG_WORN, equipSlot)
        return true
    end
    return false
end

local function EnforceBarbarian()
    if not (Rule.active and IsHardcoreActive()) then
        return
    end
    if not CanUnequipNow() then
        return
    end

    local changed = false
    local reason = nil

    for _, equipSlot in ipairs(FORBIDDEN_ARMOR_SLOTS) do
        if GetWornLink(equipSlot) and UnequipSlot(equipSlot) then
            changed = true
            reason = reason or "bare"
        end
    end

    for _, equipSlot in ipairs(HEAVY_ARMOR_SLOTS) do
        local link = GetWornLink(equipSlot)
        if link and GetItemLinkArmorType(link) ~= ARMORTYPE_HEAVY and UnequipSlot(equipSlot) then
            changed = true
            reason = reason or "heavy"
        end
    end

    for _, equipSlot in ipairs(MAIN_HAND_SLOTS) do
        local link = GetWornLink(equipSlot)
        if link and not IsTwoHandedWeapon(link) and UnequipSlot(equipSlot) then
            changed = true
            reason = reason or "weapon"
        end
    end

    for _, equipSlot in ipairs(OFF_HAND_SLOTS) do
        if GetWornLink(equipSlot) and UnequipSlot(equipSlot) then
            changed = true
            reason = reason or "offhand"
        end
    end

    if changed then
        Alert(reason)
    end
end

local function OnInventoryChange(_, bagId)
    if Rule.active and bagId == BAG_WORN then
        zo_callLater(EnforceBarbarian, 50)
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
        zo_callLater(EnforceBarbarian, 50)
    end)
    EVENT_MANAGER:RegisterForEvent(NS .. "_ACTIVATED", EVENT_PLAYER_ACTIVATED, function()
        zo_callLater(EnforceBarbarian, 200)
    end)
    EVENT_MANAGER:RegisterForEvent(NS .. "_COMBAT", EVENT_PLAYER_COMBAT_STATE, function(_, inCombat)
        if not inCombat then
            zo_callLater(EnforceBarbarian, 120)
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
    RegisterEvents()
    zo_callLater(EnforceBarbarian, 100)
end

function Rule:OnDisable()
    self.active = false
    UnregisterEvents()
end

function Rule:DebugStatus()
    d("Barbarian active=" .. tostring(Rule.active) ..
        " hardcoreActive=" .. tostring(IsHardcoreActive()))
end

function HARDCORE.DebugBarbarianStatus()
    Rule:DebugStatus()
end

function HARDCORE.DebugBarbarianCommand(action)
    action = action or "help"

    if action == "help" then
        d("Barbarian debug:")
        d("/hc debug barbarian status")
        d("/hc debug barbarian enforce")
        return
    end

    if action == "status" then
        Rule:DebugStatus()
        return
    end

    if action == "enforce" then
        EnforceBarbarian()
        Rule:DebugStatus()
        return
    end

    d("Unknown Barbarian debug action: " .. tostring(action))
end

HARDCORE.RuleManager:RegisterRule(Rule)
