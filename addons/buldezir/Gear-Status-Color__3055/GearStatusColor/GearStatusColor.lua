local NAME = 'GearStatusColor'

local CONTROL_NAME_PREFIX = 'CharacterEquipmentSlotsBg'

-- ref: esoui/ingame/characterwindow/keyboard/characterwindow_keyboard.lua:21
local SLOTS = {
    [EQUIP_SLOT_HEAD]           = ZO_CharacterEquipmentSlotsHead,
    [EQUIP_SLOT_NECK]           = ZO_CharacterEquipmentSlotsNeck,
    [EQUIP_SLOT_CHEST]          = ZO_CharacterEquipmentSlotsChest,
    [EQUIP_SLOT_SHOULDERS]      = ZO_CharacterEquipmentSlotsShoulder,
    [EQUIP_SLOT_MAIN_HAND]      = ZO_CharacterEquipmentSlotsMainHand,
    [EQUIP_SLOT_OFF_HAND]       = ZO_CharacterEquipmentSlotsOffHand,
    [EQUIP_SLOT_POISON]         = ZO_CharacterEquipmentSlotsPoison,
    [EQUIP_SLOT_WAIST]          = ZO_CharacterEquipmentSlotsBelt,
    [EQUIP_SLOT_LEGS]           = ZO_CharacterEquipmentSlotsLeg,
    [EQUIP_SLOT_FEET]           = ZO_CharacterEquipmentSlotsFoot,
    [EQUIP_SLOT_COSTUME]        = ZO_CharacterEquipmentSlotsCostume,
    [EQUIP_SLOT_RING1]          = ZO_CharacterEquipmentSlotsRing1,
    [EQUIP_SLOT_RING2]          = ZO_CharacterEquipmentSlotsRing2,
    [EQUIP_SLOT_HAND]           = ZO_CharacterEquipmentSlotsGlove,
    [EQUIP_SLOT_BACKUP_MAIN]    = ZO_CharacterEquipmentSlotsBackupMain,
    [EQUIP_SLOT_BACKUP_OFF]     = ZO_CharacterEquipmentSlotsBackupOff,
    [EQUIP_SLOT_BACKUP_POISON]  = ZO_CharacterEquipmentSlotsBackupPoison,
}

local function GetDurabilityColor(val, a)
    local r, g

    if val > 100 then
        val = 100
    end

    if val >= 50 then
        r = 100 - ((val - 50) * 2)
        g = 100
    else
        r = 100
        g = val * 2
    end

    return r / 100, g / 100, 0, a
end

local function UpdateCondition(_, bag, slot)
    if bag ~= BAG_WORN or slot == EQUIP_SLOT_COSTUME then
        return
    end

    local t = WINDOW_MANAGER:GetControlByName(CONTROL_NAME_PREFIX .. slot)
    local l = WINDOW_MANAGER:GetControlByName(CONTROL_NAME_PREFIX .. slot .. 'Condition')

    local p = t:GetParent()
    local s

    p:SetMouseOverTexture(not ZO_Character_IsReadOnly() and 'GearStatusColor/asset/mo.dds' or nil)
    p:SetPressedMouseOverTexture(not ZO_Character_IsReadOnly() and 'GearStatusColor/asset/mo.dds' or nil)

    s = p:GetNamedChild('DropCallout')
    s:ClearAnchors()
    s:SetAnchor(1, p, 1, 0, 2)
    s:SetDimensions(52, 52)
    s:SetTexture('GearStatusColor/asset/spot.dds')
    s:SetDrawLayer(0)

    s = p:GetNamedChild('Highlight')
    if s then
        s:ClearAnchors()
        s:SetAnchor(1, p, 1, 0, 2)
        s:SetDimensions(52, 52)
        s:SetTexture('GearStatusColor/asset/spot.dds')
    end

    if GetItemInstanceId(BAG_WORN, slot) then
        local itemLink = GetItemLink(BAG_WORN, slot)

        t:SetHidden(false)
        t:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, GetItemLinkDisplayQuality(itemLink)))

        if DoesItemHaveDurability(BAG_WORN, slot) then
            local con = GetItemLinkCondition(itemLink)
            l:SetText(con .. '%')
            l:SetColor(GetDurabilityColor(con, 0.9))
            l:SetHidden(false)
        elseif DoesItemLinkHaveEnchantCharges(itemLink) then
            local con = (GetItemLinkNumEnchantCharges(itemLink) / GetItemLinkMaxEnchantCharges(itemLink)) * 100
            l:SetText(zo_round(con) .. '%')
            l:SetColor(GetDurabilityColor(con, 0.9))
            l:SetHidden(false)
        else
            l:SetHidden(true)
        end
    else
        t:SetHidden(true)
        l:SetHidden(true)
    end
end

local function DrawInventory()

    for slotId, slotControl in pairs(SLOTS) do
        local s = WINDOW_MANAGER:CreateControl(CONTROL_NAME_PREFIX .. slotId, slotControl, CT_TEXTURE)
        s:SetHidden(true)
        s:SetDrawLevel(1)
        s:SetTexture('GearStatusColor/asset/hole.dds')
        s:SetAnchorFill()

        s = WINDOW_MANAGER:CreateControl(CONTROL_NAME_PREFIX .. slotId .. 'Condition', slotControl, CT_LABEL)
        s:SetFont('ZoFontGameSmall')
        s:SetAnchor(TOPRIGHT, slotControl, TOPRIGHT, 7, -8)
        s:SetDimensions(50, 10)
        s:SetHidden(true)
        s:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    end
end

local function updateAll()
    for slotId in pairs(SLOTS) do
        UpdateCondition(_, BAG_WORN, slotId)
    end
end

local function Initialize()

    DrawInventory()

    EVENT_MANAGER:RegisterForEvent(NAME, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, UpdateCondition)
    EVENT_MANAGER:AddFilterForEvent(NAME, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN)
    EVENT_MANAGER:RegisterForEvent(NAME, EVENT_ARMORY_BUILD_RESTORE_RESPONSE, updateAll)

    updateAll()
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= NAME then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(NAME, EVENT_ADD_ON_LOADED)

    Initialize()
end

EVENT_MANAGER:RegisterForEvent(NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
