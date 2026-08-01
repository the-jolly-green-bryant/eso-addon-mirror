local HARDCORE = HARDCORE

local ID = "SelfMade"
local NS = "HARDCORE_SelfMade"

local ICON_SELF_MADE = "/esoui/art/tradinghouse/gamepad/gp_tradinghouse_materials_trait_armortrait.dds"

local Rule = {
    id = ID,
    title = "Self Made: only self-crafted gear equipped",
    icon = ICON_SELF_MADE,
    defaultEnabled = false
}

Rule.active = false
Rule._lastAlertMs = 0

local WORN_SLOTS = {
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
    EQUIP_SLOT_BACKUP_OFF
}

local SELF_MADE_CRAFTING_TYPES = {
    [CRAFTING_TYPE_BLACKSMITHING] = true,
    [CRAFTING_TYPE_CLOTHIER] = true,
    [CRAFTING_TYPE_WOODWORKING] = true,
    [CRAFTING_TYPE_JEWELRYCRAFTING] = true
}

local SELF_MADE_CRAFTING_MODES = {
    [CRAFTING_INTERACTION_MODE_STANDARD_STATION] = true,
    [CRAFTING_INTERACTION_MODE_CONSOLIDATED_STATION] = true
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

local function Alert()
    local now = GetFrameTimeMilliseconds()
    if now - Rule._lastAlertMs > 1500 then
        HARDCORE.ShowAlertNoSuppression(UI_ALERT_CATEGORY_ALERT, SOUNDS.NEGATIVE_CLICK,
            "HARDCORE: Self Made allows only gear crafted by this character.")
        Rule._lastAlertMs = now
    end
end

local function IsSelfMadeWornItem(equipSlot)
    local link = GetWornLink(equipSlot)
    if not link or not IsItemLinkCrafted(link) then
        return false
    end

    local creatorName = GetItemCreatorName(BAG_WORN, equipSlot)
    return creatorName ~= nil and creatorName ~= "" and creatorName == GetUnitName("player")
end

local function UnequipSlot(equipSlot)
    local hasItem, _icon, _heldSlot, _heldNow, locked = GetWornItemInfo(BAG_WORN, equipSlot)
    if hasItem and not locked then
        RequestUnequipItem(BAG_WORN, equipSlot)
        return true
    end
    return false
end

local function EnforceSelfMade()
    if not (Rule.active and IsHardcoreActive()) then
        return
    end
    if not CanUnequipNow() then
        return
    end

    local changed = false
    for _, equipSlot in ipairs(WORN_SLOTS) do
        if GetWornLink(equipSlot) and not IsSelfMadeWornItem(equipSlot) and UnequipSlot(equipSlot) then
            changed = true
        end
    end

    if changed then
        Alert()
    end
end

local function OnInventoryChange(_, bagId)
    if Rule.active and bagId == BAG_WORN then
        zo_callLater(EnforceSelfMade, 50)
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
        zo_callLater(EnforceSelfMade, 50)
    end)
    EVENT_MANAGER:RegisterForEvent(NS .. "_ACTIVATED", EVENT_PLAYER_ACTIVATED, function()
        zo_callLater(EnforceSelfMade, 200)
    end)
    EVENT_MANAGER:RegisterForEvent(NS .. "_COMBAT", EVENT_PLAYER_COMBAT_STATE, function(_, inCombat)
        if not inCombat then
            zo_callLater(EnforceSelfMade, 120)
        end
    end)
end

local function UnregisterEvents()
    EVENT_MANAGER:UnregisterForEvent(NS .. "_INV", EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    EVENT_MANAGER:UnregisterForEvent(NS .. "_SWAP", EVENT_ACTIVE_WEAPON_PAIR_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(NS .. "_ACTIVATED", EVENT_PLAYER_ACTIVATED)
    EVENT_MANAGER:UnregisterForEvent(NS .. "_COMBAT", EVENT_PLAYER_COMBAT_STATE)
end

function HARDCORE.IsSelfMadeFeatActive()
    return Rule.active and IsHardcoreActive()
end

function HARDCORE.CanSelfMadeUseCraftingStation(craftSkill, craftMode)
    if not HARDCORE.IsSelfMadeFeatActive() then
        return false
    end
    craftMode = craftMode or GetCraftingInteractionMode()
    return SELF_MADE_CRAFTING_TYPES[craftSkill] == true and SELF_MADE_CRAFTING_MODES[craftMode] == true
end

function Rule:OnEnable()
    self.active = true
    RegisterEvents()
    zo_callLater(EnforceSelfMade, 100)
end

function Rule:OnDisable()
    self.active = false
    UnregisterEvents()
end

function Rule:DebugStatus()
    d("Self Made active=" .. tostring(Rule.active) ..
        " hardcoreActive=" .. tostring(IsHardcoreActive()))
end

function HARDCORE.DebugSelfMadeStatus()
    Rule:DebugStatus()
end

function HARDCORE.DebugSelfMadeCommand(action)
    action = action or "help"

    if action == "help" then
        d("Self Made debug:")
        d("/hc debug selfmade status")
        d("/hc debug selfmade enforce")
        return
    end

    if action == "status" then
        Rule:DebugStatus()
        return
    end

    if action == "enforce" then
        EnforceSelfMade()
        Rule:DebugStatus()
        return
    end

    d("Unknown Self Made debug action: " .. tostring(action))
end

HARDCORE.RuleManager:RegisterRule(Rule)
