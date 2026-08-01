local HARDCORE = HARDCORE

local ID = "SingleArmorDiscipline"
local NS = "HARDCORE_SingleArmorDiscipline"

local ICON_SINGLE_ARMOR = "/esoui/art/crafting/smithing_tabicon_armorset_up.dds"

local Rule = {
    id = ID,
    title = "Single Armor Discipline: one armor weight only",
    icon = ICON_SINGLE_ARMOR,
    defaultEnabled = false
}

Rule.active = false
Rule._lastAlertMs = 0
Rule._lastBindAlertMs = 0

local ARMOR_SLOTS = {
    EQUIP_SLOT_HEAD,
    EQUIP_SLOT_SHOULDERS,
    EQUIP_SLOT_CHEST,
    EQUIP_SLOT_HAND,
    EQUIP_SLOT_WAIST,
    EQUIP_SLOT_LEGS,
    EQUIP_SLOT_FEET
}

local ARMOR_TYPE_NAMES = {
    [ARMORTYPE_LIGHT] = "Light",
    [ARMORTYPE_MEDIUM] = "Medium",
    [ARMORTYPE_HEAVY] = "Heavy"
}

local function GetSV()
    HARDCORE = HARDCORE or {}
    if not HARDCORE.singleArmorDisciplineSaved then
        HARDCORE.singleArmorDisciplineSaved = ZO_SavedVars:NewCharacterIdSettings(
            "HARDCORE_SINGLE_ARMOR_DISCIPLINE_SV", 1, nil, {
                armorType = nil
            }, GetWorldName())
    end

    local sv = HARDCORE.singleArmorDisciplineSaved
    if not ARMOR_TYPE_NAMES[sv.armorType] then
        sv.armorType = nil
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

local function GetWornArmorType(equipSlot)
    local link = GetWornLink(equipSlot)
    if not link then
        return nil
    end

    local armorType = GetItemLinkArmorType(link)
    if ARMOR_TYPE_NAMES[armorType] then
        return armorType
    end
    return nil
end

local function FindFirstWornArmorType()
    for _, equipSlot in ipairs(ARMOR_SLOTS) do
        local armorType = GetWornArmorType(equipSlot)
        if armorType then
            return armorType
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

local function AlertBound(armorType)
    local now = GetFrameTimeMilliseconds()
    if now - Rule._lastBindAlertMs > 1500 then
        HARDCORE.ShowAlertNoSuppression(UI_ALERT_CATEGORY_ALERT, SOUNDS.QUEST_ACCEPTED,
            "HARDCORE: Single Armor Discipline bound to " .. ARMOR_TYPE_NAMES[armorType] .. " armor.")
        Rule._lastBindAlertMs = now
    end
end

local function EnsureArmorDiscipline()
    local sv = GetSV()
    if sv.armorType then
        return sv.armorType
    end

    local armorType = FindFirstWornArmorType()
    if armorType then
        sv.armorType = armorType
        AlertBound(armorType)
        if HARDCORE.RefreshFeatAcceptButtons then
            HARDCORE.RefreshFeatAcceptButtons()
        end
    end
    return sv.armorType
end

local function UnequipSlot(equipSlot)
    local hasItem, _icon, _heldSlot, _heldNow, locked = GetWornItemInfo(BAG_WORN, equipSlot)
    if hasItem and not locked then
        RequestUnequipItem(BAG_WORN, equipSlot)
        return true
    end
    return false
end

local function EnforceSingleArmorDiscipline()
    if not (Rule.active and IsHardcoreActive()) then
        return
    end
    if not CanUnequipNow() then
        return
    end

    local allowedArmorType = EnsureArmorDiscipline()
    if not allowedArmorType then
        return
    end

    local changed = false
    for _, equipSlot in ipairs(ARMOR_SLOTS) do
        local armorType = GetWornArmorType(equipSlot)
        if armorType and armorType ~= allowedArmorType and UnequipSlot(equipSlot) then
            changed = true
        end
    end

    if changed then
        Alert("HARDCORE: Single Armor Discipline allows only " .. ARMOR_TYPE_NAMES[allowedArmorType] .. " armor.")
    end
end

local function OnInventoryChange(_, bagId)
    if Rule.active and bagId == BAG_WORN then
        zo_callLater(EnforceSingleArmorDiscipline, 50)
    end
end

local function RegisterEvents()
    EVENT_MANAGER:UnregisterForEvent(NS .. "_INV", EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    EVENT_MANAGER:UnregisterForEvent(NS .. "_ACTIVATED", EVENT_PLAYER_ACTIVATED)
    EVENT_MANAGER:UnregisterForEvent(NS .. "_COMBAT", EVENT_PLAYER_COMBAT_STATE)

    EVENT_MANAGER:RegisterForEvent(NS .. "_INV", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnInventoryChange)
    EVENT_MANAGER:AddFilterForEvent(NS .. "_INV", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN)
    EVENT_MANAGER:RegisterForEvent(NS .. "_ACTIVATED", EVENT_PLAYER_ACTIVATED, function()
        zo_callLater(EnforceSingleArmorDiscipline, 200)
    end)
    EVENT_MANAGER:RegisterForEvent(NS .. "_COMBAT", EVENT_PLAYER_COMBAT_STATE, function(_, inCombat)
        if not inCombat then
            zo_callLater(EnforceSingleArmorDiscipline, 120)
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
    GetSV()
    RegisterEvents()
    zo_callLater(EnforceSingleArmorDiscipline, 100)
end

function Rule:OnDisable()
    self.active = false
    UnregisterEvents()
end

function Rule:GetSelectedArmorType()
    return GetSV().armorType
end

function HARDCORE.GetSingleArmorDisciplineArmorType()
    return GetSV().armorType
end

HARDCORE.RuleManager:RegisterRule(Rule)
