VestigeMirror = VestigeMirror or {}
VestigeMirror.Data = {}

local PLAYER_ACTOR_CATEGORY = GAMEPLAY_ACTOR_CATEGORY_PLAYER
local DEFAULT_MATERIAL_INDEX = 1

local ARMOR_SLOTS =
{
    { label = "Head", outfitSlot = OUTFIT_SLOT_HEAD, equipSlot = EQUIP_SLOT_HEAD, icon = "EsoUI/Art/CharacterWindow/gearSlot_head.dds" },
    { label = "Chest", outfitSlot = OUTFIT_SLOT_CHEST, equipSlot = EQUIP_SLOT_CHEST, icon = "EsoUI/Art/CharacterWindow/gearSlot_chest.dds" },
    { label = "Shoulders", outfitSlot = OUTFIT_SLOT_SHOULDERS, equipSlot = EQUIP_SLOT_SHOULDERS, icon = "EsoUI/Art/CharacterWindow/gearSlot_shoulders.dds" },
    { label = "Hands", outfitSlot = OUTFIT_SLOT_HANDS, equipSlot = EQUIP_SLOT_HAND, icon = "EsoUI/Art/CharacterWindow/gearSlot_hands.dds" },
    { label = "Waist", outfitSlot = OUTFIT_SLOT_WAIST, equipSlot = EQUIP_SLOT_WAIST, icon = "EsoUI/Art/CharacterWindow/gearSlot_belt.dds" },
    { label = "Legs", outfitSlot = OUTFIT_SLOT_LEGS, equipSlot = EQUIP_SLOT_LEGS, icon = "EsoUI/Art/CharacterWindow/gearSlot_legs.dds" },
    { label = "Feet", outfitSlot = OUTFIT_SLOT_FEET, equipSlot = EQUIP_SLOT_FEET, icon = "EsoUI/Art/CharacterWindow/gearSlot_feet.dds" },
}

local WEAPON_SLOTS =
{
    { label = "Main Hand", outfitSlot = OUTFIT_SLOT_WEAPON_MAIN_HAND, equipSlot = EQUIP_SLOT_MAIN_HAND, icon = "EsoUI/Art/Dye/outfitSlot_mainHand.dds" },
    { label = "Off Hand", outfitSlot = OUTFIT_SLOT_WEAPON_OFF_HAND, equipSlot = EQUIP_SLOT_OFF_HAND, icon = "EsoUI/Art/Dye/outfitSlot_offHand.dds" },
    { label = "Two Handed", outfitSlot = OUTFIT_SLOT_WEAPON_TWO_HANDED, equipSlot = EQUIP_SLOT_MAIN_HAND, icon = "EsoUI/Art/Dye/outfitSlot_twoHanded.dds" },
    { label = "Staff", outfitSlot = OUTFIT_SLOT_WEAPON_STAFF, equipSlot = EQUIP_SLOT_MAIN_HAND, icon = "EsoUI/Art/Dye/outfitSlot_staff.dds" },
    { label = "Bow", outfitSlot = OUTFIT_SLOT_WEAPON_BOW, equipSlot = EQUIP_SLOT_MAIN_HAND, icon = "EsoUI/Art/Dye/outfitSlot_bow.dds" },
    { label = "Shield", outfitSlot = OUTFIT_SLOT_SHIELD, equipSlot = EQUIP_SLOT_OFF_HAND, icon = "EsoUI/Art/Dye/outfitSlot_shield.dds" },
    { label = "Backup Main", outfitSlot = OUTFIT_SLOT_WEAPON_MAIN_HAND_BACKUP, equipSlot = EQUIP_SLOT_BACKUP_MAIN, icon = "EsoUI/Art/Dye/outfitSlot_mainHand.dds" },
    { label = "Backup Off", outfitSlot = OUTFIT_SLOT_WEAPON_OFF_HAND_BACKUP, equipSlot = EQUIP_SLOT_BACKUP_OFF, icon = "EsoUI/Art/Dye/outfitSlot_offHand.dds" },
    { label = "Backup Two Handed", outfitSlot = OUTFIT_SLOT_WEAPON_TWO_HANDED_BACKUP, equipSlot = EQUIP_SLOT_BACKUP_MAIN, icon = "EsoUI/Art/Dye/outfitSlot_twoHanded.dds" },
    { label = "Backup Staff", outfitSlot = OUTFIT_SLOT_WEAPON_STAFF_BACKUP, equipSlot = EQUIP_SLOT_BACKUP_MAIN, icon = "EsoUI/Art/Dye/outfitSlot_staff.dds" },
    { label = "Backup Bow", outfitSlot = OUTFIT_SLOT_WEAPON_BOW_BACKUP, equipSlot = EQUIP_SLOT_BACKUP_MAIN, icon = "EsoUI/Art/Dye/outfitSlot_bow.dds" },
    { label = "Backup Shield", outfitSlot = OUTFIT_SLOT_SHIELD_BACKUP, equipSlot = EQUIP_SLOT_BACKUP_OFF, icon = "EsoUI/Art/Dye/outfitSlot_shield.dds" },
}

local APPEARANCE_COLLECTIBLES =
{
    { label = "Hair Style", typeNames = { "COLLECTIBLE_CATEGORY_TYPE_HAIR" } },
    { label = "Head Markings", typeNames = { "COLLECTIBLE_CATEGORY_TYPE_HEAD_MARKING" } },
    { label = "Major Adornments", typeNames = { "COLLECTIBLE_CATEGORY_TYPE_FACIAL_ACCESSORY", "COLLECTIBLE_CATEGORY_TYPE_MAJOR_ADORNMENT" } },
    { label = "Minor Adornments", typeNames = { "COLLECTIBLE_CATEGORY_TYPE_PIERCING_JEWELRY", "COLLECTIBLE_CATEGORY_TYPE_MINOR_ADORNMENT" } },
    { label = "Body Marking", typeNames = { "COLLECTIBLE_CATEGORY_TYPE_BODY_MARKING" } },
    { label = "Skin", typeNames = { "COLLECTIBLE_CATEGORY_TYPE_SKIN" } },
    { label = "Personality", typeNames = { "COLLECTIBLE_CATEGORY_TYPE_PERSONALITY" } },
}

local function FormatName(name)
    if name and name ~= "" then
        if ZO_CachedStrFormat then
            return ZO_CachedStrFormat("<<C:1>>", name)
        end
        return name
    end
    return "Empty"
end
local function ResolveFirstConstant(typeNames)
    for _, typeName in ipairs(typeNames) do
        local value = _G[typeName]
        if value ~= nil then
            return value
        end
    end

    return nil
end

local function BuildDye(dyeId)
    if not dyeId or dyeId == 0 then
        return { id = 0, name = "No Dye", r = 0.08, g = 0.08, b = 0.08, empty = true }
    end

    local dyeName, known, rarity, hueCategory, achievementId, r, g, b = GetDyeInfoById(dyeId)
    return
    {
        id = dyeId,
        name = FormatName(dyeName),
        known = known,
        rarity = rarity,
        r = r or 0.08,
        g = g or 0.08,
        b = b or 0.08,
        empty = false,
    }
end
local function BuildDyes(primaryDyeId, secondaryDyeId, accentDyeId)
    return
    {
        BuildDye(primaryDyeId),
        BuildDye(secondaryDyeId),
        BuildDye(accentDyeId),
    }
end

local function GetCollectibleDisplay(collectibleId, itemMaterialIndex)
    local name, _, icon = GetCollectibleInfo(collectibleId)
    local materialName = nil

    if itemMaterialIndex and itemMaterialIndex ~= DEFAULT_MATERIAL_INDEX then
        materialName = string.format("Material %d", itemMaterialIndex)
    end

    return FormatName(name), materialName, icon
end

local function GetActiveHeadCollectibleDisplay()
    if not GetActiveCollectibleByType or not COLLECTIBLE_CATEGORY_TYPE_HAT then
        return nil
    end

    local collectibleId = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_HAT)
    if not collectibleId or collectibleId <= 0 then
        return nil
    end

    local name, _, icon = GetCollectibleInfo(collectibleId)
    return
    {
        collectibleId = collectibleId,
        name = FormatName(name),
        icon = icon,
    }
end

local function GetActiveHeadCollectibleDyes()
    if not GetRestyleSlotCurrentDyes or not RESTYLE_MODE_COLLECTIBLE or not COLLECTIBLE_CATEGORY_TYPE_HAT then
        return BuildDyes(0, 0, 0)
    end

    local restyleSetIndex = ZO_RESTYLE_DEFAULT_SET_INDEX or 1
    local primaryDyeId, secondaryDyeId, accentDyeId = GetRestyleSlotCurrentDyes(RESTYLE_MODE_COLLECTIBLE, restyleSetIndex, COLLECTIBLE_CATEGORY_TYPE_HAT)
    return BuildDyes(primaryDyeId, secondaryDyeId, accentDyeId)
end

local function BuildActiveAppearanceCollectibles()
    local collectibles = {}

    for _, collectibleDef in ipairs(APPEARANCE_COLLECTIBLES) do
        local collectible =
        {
            label = collectibleDef.label,
            name = "None",
            icon = nil,
            collectibleId = nil,
            isEmpty = true,
        }

        local categoryType = ResolveFirstConstant(collectibleDef.typeNames)
        if GetActiveCollectibleByType and categoryType then
            local collectibleId = GetActiveCollectibleByType(categoryType)
            if collectibleId and collectibleId > 0 then
                local name, _, icon = GetCollectibleInfo(collectibleId)
                collectible.name = FormatName(name)
                collectible.icon = icon
                collectible.collectibleId = collectibleId
                collectible.isEmpty = false
            end
        end

        if not collectible.isEmpty then
            table.insert(collectibles, collectible)
        end
    end

    return collectibles
end

local function GetItemDisplay(bagId, equipSlot)
    local icon = GetItemInfo(bagId, equipSlot)
    local itemLink = GetItemLink(bagId, equipSlot, LINK_STYLE_DEFAULT)

    if not itemLink or itemLink == "" then
        return nil
    end

    local styleId = GetItemLinkItemStyle(itemLink)
    local styleName = styleId and styleId > 0 and FormatName(GetItemStyleName(styleId)) or FormatName(itemLink)
    local primaryDyeId, secondaryDyeId, accentDyeId = GetCurrentItemDyes(bagId, equipSlot)

    return
    {
        name = styleName,
        source = "Equipped Item",
        icon = icon,
        dyes = BuildDyes(primaryDyeId, secondaryDyeId, accentDyeId),
        isEmpty = false,
    }
end

function VestigeMirror.Data:Initialize()
    self.actorCategory = PLAYER_ACTOR_CATEGORY
end

function VestigeMirror.Data:GetSlotGroups()
    return ARMOR_SLOTS, WEAPON_SLOTS
end

function VestigeMirror.Data:GetAllOutfitSlotDefs()
    local slots = {}

    for _, slotDef in ipairs(ARMOR_SLOTS) do
        table.insert(slots, slotDef)
    end

    for _, slotDef in ipairs(WEAPON_SLOTS) do
        table.insert(slots, slotDef)
    end

    return slots
end

function VestigeMirror.Data:BuildSlot(slotDef, outfitIndex, wornBag)
    local slot =
    {
        label = slotDef.label,
        icon = slotDef.icon,
        source = "Unavailable",
        name = "Empty",
        materialName = nil,
        dyes = BuildDyes(0, 0, 0),
        outfitSlot = slotDef.outfitSlot,
        equipSlot = slotDef.equipSlot,
        isEmpty = true,
    }

    if slotDef.outfitSlot == OUTFIT_SLOT_HEAD then
        local activeHeadCollectible = GetActiveHeadCollectibleDisplay()
        if activeHeadCollectible then
            slot.name = activeHeadCollectible.name
            slot.source = "Head Collectible"
            slot.icon = activeHeadCollectible.icon or slot.icon
            slot.collectibleId = activeHeadCollectible.collectibleId
            slot.dyes = GetActiveHeadCollectibleDyes()
            slot.isEmpty = false
            return slot
        end
    end

    if outfitIndex then
        local collectibleId, itemMaterialIndex, primaryDyeId, secondaryDyeId, accentDyeId = GetOutfitSlotInfo(self.actorCategory, outfitIndex, slotDef.outfitSlot)
        if collectibleId and collectibleId > 0 then
            local name, materialName, icon = GetCollectibleDisplay(collectibleId, itemMaterialIndex)
            slot.name = name
            slot.materialName = materialName
            slot.source = "Outfit Style"
            slot.icon = icon or slot.icon
            slot.dyes = BuildDyes(primaryDyeId, secondaryDyeId, accentDyeId)
            slot.collectibleId = collectibleId
            slot.itemMaterialIndex = itemMaterialIndex
            slot.isEmpty = false
            return slot
        end
    end

    local itemSlot = GetItemDisplay(wornBag, slotDef.equipSlot)
    if itemSlot then
        slot.name = itemSlot.name
        slot.source = itemSlot.source
        slot.icon = itemSlot.icon or slot.icon
        slot.dyes = itemSlot.dyes
        slot.isEmpty = false
    end

    return slot
end

function VestigeMirror.Data:BuildAppearance()
    local wornBag = GetWornBagForGameplayActorCategory(self.actorCategory)
    local outfitIndex = GetEquippedOutfitIndex(self.actorCategory)
    if not outfitIndex or outfitIndex == 0 then
        outfitIndex = nil
    end

    local outfitName = outfitIndex and FormatName(GetOutfitName(self.actorCategory, outfitIndex)) or "No Outfit Equipped"
    local mainHandOutfitSlot, offHandOutfitSlot = GetOutfitSlotsForCurrentlyHeldWeapons(self.actorCategory)
    local equippedWeaponOutfitSlots = {}
    if mainHandOutfitSlot then equippedWeaponOutfitSlots[mainHandOutfitSlot] = true end
    if offHandOutfitSlot then equippedWeaponOutfitSlots[offHandOutfitSlot] = true end

    local armorSlots = {}
    for _, slotDef in ipairs(ARMOR_SLOTS) do
        table.insert(armorSlots, self:BuildSlot(slotDef, outfitIndex, wornBag))
    end

    local weaponSlots = {}
    for _, slotDef in ipairs(WEAPON_SLOTS) do
        if equippedWeaponOutfitSlots[slotDef.outfitSlot] then
            local slot = self:BuildSlot(slotDef, outfitIndex, wornBag)
            table.insert(weaponSlots, slot)
        end
    end

    return
    {
        actorCategory = self.actorCategory,
        outfitIndex = outfitIndex,
        outfitName = outfitName,
        armorSlots = armorSlots,
        weaponSlots = weaponSlots,
        appearanceCollectibles = BuildActiveAppearanceCollectibles(),
    }
end
