local HARDCORE = HARDCORE

local ID = "BarefootPilgrim"
local NS = "HARDCORE_BarefootPilgrim"

local ICON_BAREFOOT = "/esoui/art/tradinghouse/tradinghouse_apparel_feet_up.dds"

local Rule = {
    id = ID,
    title = "Barefoot Pilgrim: no boots equipped",
    icon = ICON_BAREFOOT,
    defaultEnabled = false
}

Rule.active = false
Rule._lastAlertMs = 0

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
            "HARDCORE: Barefoot Pilgrim forbids equipped boots.")
        Rule._lastAlertMs = now
    end
end

local function UnequipFeet()
    local hasItem, _icon, _heldSlot, _heldNow, locked = GetWornItemInfo(BAG_WORN, EQUIP_SLOT_FEET)
    if hasItem and not locked then
        RequestUnequipItem(BAG_WORN, EQUIP_SLOT_FEET)
        return true
    end
    return false
end

local function EnforceBarefootPilgrim()
    if not (Rule.active and IsHardcoreActive()) then
        return
    end
    if not CanUnequipNow() then
        return
    end

    if UnequipFeet() then
        Alert()
    end
end

local function OnInventoryChange(_, bagId)
    if Rule.active and bagId == BAG_WORN then
        zo_callLater(EnforceBarefootPilgrim, 50)
    end
end

local function RegisterEvents()
    EVENT_MANAGER:UnregisterForEvent(NS .. "_INV", EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    EVENT_MANAGER:UnregisterForEvent(NS .. "_ACTIVATED", EVENT_PLAYER_ACTIVATED)
    EVENT_MANAGER:UnregisterForEvent(NS .. "_COMBAT", EVENT_PLAYER_COMBAT_STATE)

    EVENT_MANAGER:RegisterForEvent(NS .. "_INV", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnInventoryChange)
    EVENT_MANAGER:AddFilterForEvent(NS .. "_INV", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN)
    EVENT_MANAGER:RegisterForEvent(NS .. "_ACTIVATED", EVENT_PLAYER_ACTIVATED, function()
        zo_callLater(EnforceBarefootPilgrim, 200)
    end)
    EVENT_MANAGER:RegisterForEvent(NS .. "_COMBAT", EVENT_PLAYER_COMBAT_STATE, function(_, inCombat)
        if not inCombat then
            zo_callLater(EnforceBarefootPilgrim, 120)
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
    zo_callLater(EnforceBarefootPilgrim, 100)
end

function Rule:OnDisable()
    self.active = false
    UnregisterEvents()
end

HARDCORE.RuleManager:RegisterRule(Rule)
