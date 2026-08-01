local HARDCORE = HARDCORE

local ID = "NoTrinkets"
local NS = "HARDCORE_NoTrinkets"

local ICON_NO_TRINKETS = "/esoui/art/tradinghouse/tradinghouse_apparel_accessories_ring_up.dds"

local Rule = {
    id = ID,
    title = "No Trinkets: no jewelry equipped",
    icon = ICON_NO_TRINKETS,
    defaultEnabled = false
}

Rule.active = false
Rule._lastAlertMs = 0

local JEWELRY_SLOTS = {
    EQUIP_SLOT_NECK,
    EQUIP_SLOT_RING1,
    EQUIP_SLOT_RING2
}

local function IsHardcoreActive()
    return HARDCORE and HARDCORE.saved and HARDCORE.saved.isActive
end

local function CanUnequipNow()
    return not (IsUnitInCombat and IsUnitInCombat("player"))
end

local function Alert()
    local now = GetFrameTimeMilliseconds()
    if now - Rule._lastAlertMs > 1500 then
        HARDCORE.ShowAlertNoSuppression(UI_ALERT_CATEGORY_ALERT, SOUNDS.NEGATIVE_CLICK,
            "HARDCORE: No Trinkets forbids equipped jewelry.")
        Rule._lastAlertMs = now
    end
end

local function UnequipSlot(equipSlot)
    local hasItem, _icon, _heldSlot, _heldNow, locked = GetWornItemInfo(BAG_WORN, equipSlot)
    if hasItem and not locked then
        RequestUnequipItem(BAG_WORN, equipSlot)
        return true
    end
    return false
end

local function EnforceNoTrinkets()
    if not (Rule.active and IsHardcoreActive()) then
        return
    end
    if not CanUnequipNow() then
        return
    end

    local changed = false
    for _, equipSlot in ipairs(JEWELRY_SLOTS) do
        if UnequipSlot(equipSlot) then
            changed = true
        end
    end

    if changed then
        Alert()
    end
end

local function OnInventoryChange(_, bagId)
    if Rule.active and bagId == BAG_WORN then
        zo_callLater(EnforceNoTrinkets, 50)
    end
end

local function RegisterEvents()
    EVENT_MANAGER:UnregisterForEvent(NS .. "_INV", EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    EVENT_MANAGER:UnregisterForEvent(NS .. "_ACTIVATED", EVENT_PLAYER_ACTIVATED)
    EVENT_MANAGER:UnregisterForEvent(NS .. "_COMBAT", EVENT_PLAYER_COMBAT_STATE)

    EVENT_MANAGER:RegisterForEvent(NS .. "_INV", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnInventoryChange)
    EVENT_MANAGER:AddFilterForEvent(NS .. "_INV", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN)
    EVENT_MANAGER:RegisterForEvent(NS .. "_ACTIVATED", EVENT_PLAYER_ACTIVATED, function()
        zo_callLater(EnforceNoTrinkets, 200)
    end)
    EVENT_MANAGER:RegisterForEvent(NS .. "_COMBAT", EVENT_PLAYER_COMBAT_STATE, function(_, inCombat)
        if not inCombat then
            zo_callLater(EnforceNoTrinkets, 120)
        end
    end)
end

local function UnregisterEvents()
    EVENT_MANAGER:UnregisterForEvent(NS .. "_INV", EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    EVENT_MANAGER:UnregisterForEvent(NS .. "_ACTIVATED", EVENT_PLAYER_ACTIVATED)
    EVENT_MANAGER:UnregisterForEvent(NS .. "_COMBAT", EVENT_PLAYER_COMBAT_STATE)
end

function Rule:OnEnable()
    self.active = true
    RegisterEvents()
    zo_callLater(EnforceNoTrinkets, 100)
end

function Rule:OnDisable()
    self.active = false
    UnregisterEvents()
end

HARDCORE.RuleManager:RegisterRule(Rule)
