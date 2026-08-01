local HARDCORE = HARDCORE

local Rule = {
    id = "LimitedGear",
    title = "Humble Gear Only",
    icon = "/esoui/art/inventory/inventory_tabicon_armor_up.dds",
    defaultEnabled = true
}

local NS = "HARDCORE_LimitedGear"
Rule.active = false
Rule._installed = false
Rule._lastAlert = 0

local function canActNow()
    return not IsUnitInCombat("player")
end

local function alertOnce()
    local now = GetFrameTimeMilliseconds()
    if now - Rule._lastAlert > 1500 then
        HARDCORE.ShowAlert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NEGATIVE_CLICK, "HARDCORE: Only white/green/blue gear allowed.")
        Rule._lastAlert = now
    end
end

local WORN_SLOTS = {EQUIP_SLOT_HEAD, EQUIP_SLOT_SHOULDERS, EQUIP_SLOT_CHEST, EQUIP_SLOT_HAND, EQUIP_SLOT_WAIST,
                    EQUIP_SLOT_LEGS, EQUIP_SLOT_FEET, EQUIP_SLOT_NECK, EQUIP_SLOT_RING1, EQUIP_SLOT_RING2,
                    EQUIP_SLOT_MAIN_HAND, EQUIP_SLOT_OFF_HAND, EQUIP_SLOT_BACKUP_MAIN, EQUIP_SLOT_BACKUP_OFF}

local function isAboveBlueEquipped(slot)
    local link = GetItemLink(BAG_WORN, slot)
    if not link or link == "" then
        return false
    end
    local q = GetItemLinkFunctionalQuality(link)
    return q and q > ITEM_FUNCTIONAL_QUALITY_ARCANE
end

local function enforceMaxBlue()
    if not Rule.active then
        return
    end
    if not canActNow() then
        return
    end

    local changed = false
    for _, slot in ipairs(WORN_SLOTS) do
        if isAboveBlueEquipped(slot) then
            RequestUnequipItem(BAG_WORN, slot)
            changed = true
        end
    end

    if changed then
        alertOnce()
    end
end

local function onInventoryChange(_, bagId, slotIndex, isNewItem, itemSoundCategory, updateReason, stackCountChange)
    if not Rule.active then
        return
    end
    if bagId ~= BAG_WORN then
        return
    end
    zo_callLater(enforceMaxBlue, 50)
end

local function onWeaponSwap()
    if not Rule.active then
        return
    end
    zo_callLater(enforceMaxBlue, 50)
end

local function Install()
    if Rule._installed then
        return
    end

    EVENT_MANAGER:RegisterForEvent(NS .. "_ACTIVATED", EVENT_PLAYER_ACTIVATED, function()
        zo_callLater(enforceMaxBlue, 200)
    end)

    EVENT_MANAGER:RegisterForEvent(NS .. "_LEVEL", EVENT_LEVEL_UPDATE, function()
        zo_callLater(enforceMaxBlue, 200)
    end)
    EVENT_MANAGER:AddFilterForEvent(NS .. "_LEVEL", EVENT_LEVEL_UPDATE, REGISTER_FILTER_UNIT_TAG, "player")

    EVENT_MANAGER:RegisterForEvent(NS .. "_INV", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, onInventoryChange)
    EVENT_MANAGER:AddFilterForEvent(NS .. "_INV", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN)

    EVENT_MANAGER:RegisterForEvent(NS .. "_SWAP", EVENT_ACTIVE_WEAPON_PAIR_CHANGED, onWeaponSwap)

    EVENT_MANAGER:RegisterForEvent(NS .. "_OOC", EVENT_PLAYER_COMBAT_STATE, function(_, inCombat)
        if not inCombat then
            zo_callLater(enforceMaxBlue, 120)
        end
    end)

    Rule._installed = true
end

function Rule:OnEnable()
    self.active = true
    Install()
    zo_callLater(enforceMaxBlue, 100)
end

function Rule:OnDisable()
    self.active = false
end

HARDCORE.RuleManager:RegisterRule(Rule)
