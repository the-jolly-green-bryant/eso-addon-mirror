local HARDCORE = HARDCORE

local ID = "HandsFree"
local NS = "HARDCORE_HandsFree"

local ICON_HANDS_FREE = "/esoui/art/inventory/inventory_tabicon_weapons_up.dds"

local Rule = {
    id = ID,
    title = "Hands Free: no weapons equipped",
    icon = ICON_HANDS_FREE,
    defaultEnabled = false
}

Rule.active = false
Rule._lastAlertMs = 0

local WEAPON_SLOTS = {
    EQUIP_SLOT_MAIN_HAND,
    EQUIP_SLOT_OFF_HAND,
    EQUIP_SLOT_BACKUP_MAIN,
    EQUIP_SLOT_BACKUP_OFF
}

local function IsHardcoreActive()
    return HARDCORE and HARDCORE.saved and HARDCORE.saved.isActive
end

local function CanUnequipNow()
    return not (IsUnitInCombat and IsUnitInCombat("player"))
end

local function HasWornItem(equipSlot)
    local hasItem = GetWornItemInfo(BAG_WORN, equipSlot)
    return hasItem == true
end

local function Alert()
    local now = GetFrameTimeMilliseconds()
    if now - Rule._lastAlertMs > 1500 then
        HARDCORE.ShowAlertNoSuppression(UI_ALERT_CATEGORY_ALERT, SOUNDS.NEGATIVE_CLICK,
            "HARDCORE: Hands Free forbids equipped weapons.")
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

local function EnforceHandsFree()
    if not (Rule.active and IsHardcoreActive()) then
        return
    end
    if not CanUnequipNow() then
        return
    end

    local changed = false
    for _, equipSlot in ipairs(WEAPON_SLOTS) do
        if HasWornItem(equipSlot) and UnequipSlot(equipSlot) then
            changed = true
        end
    end

    if changed then
        Alert()
    end
end

local function OnInventoryChange(_, bagId)
    if Rule.active and bagId == BAG_WORN then
        zo_callLater(EnforceHandsFree, 50)
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
        zo_callLater(EnforceHandsFree, 50)
    end)
    EVENT_MANAGER:RegisterForEvent(NS .. "_ACTIVATED", EVENT_PLAYER_ACTIVATED, function()
        zo_callLater(EnforceHandsFree, 200)
    end)
    EVENT_MANAGER:RegisterForEvent(NS .. "_COMBAT", EVENT_PLAYER_COMBAT_STATE, function(_, inCombat)
        if not inCombat then
            zo_callLater(EnforceHandsFree, 120)
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
    zo_callLater(EnforceHandsFree, 100)
end

function Rule:OnDisable()
    self.active = false
    UnregisterEvents()
end

function Rule:DebugStatus()
    d("Hands Free active=" .. tostring(Rule.active) ..
        " hardcoreActive=" .. tostring(IsHardcoreActive()))
end

function HARDCORE.DebugHandsFreeStatus()
    Rule:DebugStatus()
end

function HARDCORE.DebugHandsFreeCommand(action)
    action = action or "help"

    if action == "help" then
        d("Hands Free debug:")
        d("/hc debug handsfree status")
        d("/hc debug handsfree enforce")
        return
    end

    if action == "status" then
        Rule:DebugStatus()
        return
    end

    if action == "enforce" then
        EnforceHandsFree()
        Rule:DebugStatus()
        return
    end

    d("Unknown Hands Free debug action: " .. tostring(action))
end

HARDCORE.RuleManager:RegisterRule(Rule)
