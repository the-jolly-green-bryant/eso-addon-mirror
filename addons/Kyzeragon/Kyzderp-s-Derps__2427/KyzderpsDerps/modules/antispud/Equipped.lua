KyzderpsDerps = KyzderpsDerps or {}
KyzderpsDerps.AntiSpud = KyzderpsDerps.AntiSpud or {}
local Spud = KyzderpsDerps.AntiSpud

-- Some stuff yoinked from LibEquipmentBonus in Cooldowns by g4rr3t

-- Slots to monitor
local ITEM_SLOTS_FRONTBAR = {
    EQUIP_SLOT_HEAD,
    EQUIP_SLOT_NECK,
    EQUIP_SLOT_CHEST,
    EQUIP_SLOT_SHOULDERS,
    EQUIP_SLOT_MAIN_HAND,
    EQUIP_SLOT_OFF_HAND,
    EQUIP_SLOT_WAIST,
    EQUIP_SLOT_LEGS,
    EQUIP_SLOT_FEET,
    EQUIP_SLOT_RING1,
    EQUIP_SLOT_RING2,
    EQUIP_SLOT_HAND,
}

local ITEM_SLOTS_BACKBAR = {
    EQUIP_SLOT_HEAD,
    EQUIP_SLOT_NECK,
    EQUIP_SLOT_CHEST,
    EQUIP_SLOT_SHOULDERS,
    EQUIP_SLOT_WAIST,
    EQUIP_SLOT_LEGS,
    EQUIP_SLOT_FEET,
    EQUIP_SLOT_RING1,
    EQUIP_SLOT_RING2,
    EQUIP_SLOT_HAND,
    EQUIP_SLOT_BACKUP_MAIN,
    EQUIP_SLOT_BACKUP_OFF,
}

local ITEM_SLOTS_MAIN = {
    [EQUIP_SLOT_HEAD] = "a hat",
    [EQUIP_SLOT_CHEST] = "a chest",
    [EQUIP_SLOT_SHOULDERS] = "shoulders",
    [EQUIP_SLOT_LEGS] = "panties",
    [EQUIP_SLOT_WAIST] = "a belt",
    [EQUIP_SLOT_HAND] = "gloves",
    [EQUIP_SLOT_FEET] = "shoes",
    [EQUIP_SLOT_NECK] = "an amulet",
    [EQUIP_SLOT_RING1] = "ring 1",
    [EQUIP_SLOT_RING2] = "ring 2",
}

-------------------------------------------------------------------------------
local function GetNumSetBonuses(itemLink)
    local _, _, _, equipType = GetItemLinkInfo(itemLink)
    -- 2H weapons, staves, bows count as two set pieces
    if equipType == EQUIP_TYPE_TWO_HAND then
        return 2
    else
        return 1
    end
end

-------------------------------------------------------------------------------
local function CheckEmptySlots()
    local missing = {}
    for slot, name in pairs(ITEM_SLOTS_MAIN) do
        local itemLink = GetItemLink(BAG_WORN, slot)
        if (itemLink == "") then
            table.insert(missing, name)
        end
    end

    local frontMainLink = GetItemLink(BAG_WORN, EQUIP_SLOT_MAIN_HAND)
    local frontOffLink = GetItemLink(BAG_WORN, EQUIP_SLOT_OFF_HAND)
    local backMainLink = GetItemLink(BAG_WORN, EQUIP_SLOT_BACKUP_MAIN)
    local backOffLink = GetItemLink(BAG_WORN, EQUIP_SLOT_BACKUP_OFF)

    if (frontMainLink == "" or (frontOffLink == "" and GetNumSetBonuses(frontMainLink) == 1)) then
        -- Nothing in main hand, or nothing in offhand when 1hander
        table.insert(missing, "a frontbar weapon")
    end

    if (GetUnitLevel("player") >= GetWeaponSwapUnlockedLevel()) then
        if (backMainLink == "" or (backOffLink == "" and GetNumSetBonuses(backMainLink) == 1)) then
            table.insert(missing, "a backbar weapon")
        end
    end

    if (#missing > 3) then
        return Spud.Display("You are nekkid", Spud.MISSING)
    elseif (#missing > 0) then
        return Spud.Display("You have not slotted\n" .. table.concat(missing, ", "), Spud.MISSING)
    else
        return Spud.Display(nil, Spud.MISSING)
    end
end

-------------------------------------------------------------------------------
local function CheckSlotsSets(isFrontbar)
    local slots = ITEM_SLOTS_FRONTBAR
    local extraText = " on frontbar"
    if (not isFrontbar) then
        slots = ITEM_SLOTS_BACKBAR
        extraText = " on backbar"
    end

    local equippedSets = {}
    for index, slot in pairs(slots) do
        local itemLink = GetItemLink(BAG_WORN, slot)

        if (itemLink ~= "") then
            local hasSet, setName, numBonuses, _, maxEquipped = GetItemLinkSetInfo(itemLink, true)
            setName = string.gsub(setName, "^Perfected ", "")
            setName = string.gsub(setName, "^Perfect ", "")
            if (hasSet) then
                if (not equippedSets[setName]) then
                    equippedSets[setName] = {}
                    equippedSets[setName].numEquipped = 0
                    equippedSets[setName].numBonuses = numBonuses
                    equippedSets[setName].maxEquipped = maxEquipped
                end
                equippedSets[setName].numEquipped = equippedSets[setName].numEquipped + GetNumSetBonuses(itemLink)
            end
        end
    end

    local result = {}
    local error
    for setName, data in pairs(equippedSets) do
        local color = "|c0000FF"
        if (data.numEquipped == data.maxEquipped) then
            -- Maximum number equipped, also covers mythics
            color = ""
        elseif (data.maxEquipped == 2) then
            -- Monster sets are ok. This would also include arena weapons, but I can't reliably
            -- detect whether only 1 piece is equipped without using something like LibSets maybe.
            -- Or more complicated stuff so cba
            color = ""
        elseif (KyzderpsDerps.savedOptions.antispud.equipped.fourPieceExceptions[setName]) then
            -- The var is called fourPiece but it now means general exception. This was before
            -- Druid's Braid came out, and while I could only ignore Druid's Braid, I think it's
            -- simpler for the user to just add a set as an exception entirely.
            color = ""
        elseif (data.maxEquipped == 3 and data.maxEquipped == data.numBonuses) then
            -- This probably only applies to Armor of the Trainee, because monster sets and mythics already handled
            color = "|cFFFF00"
        elseif (data.maxEquipped == 3 and data.numEquipped == 2) then
            -- 3pc sets like Willpower, Endurance, are probably ok with 2 pieces
            color = "|cFFFF00"
        elseif (data.numEquipped == 1) then
            -- If wearing 1 piece of a 3 or 5 pc this is probably wrong
            color = "|cFF0000"
            error = zo_strformat("You are wearing <<1>> piece of\n<<2>>", data.numEquipped, setName)
        elseif (data.numEquipped == 2) then
            -- If wearing 2 pieces of a 5 pc this is probably wrong
            color = "|cFF0000"
            error = zo_strformat("You are wearing <<1>> pieces of\n<<2>>", data.numEquipped, setName)
        elseif (data.numEquipped > data.maxEquipped) then
            -- Too many pieces
            color = "|cFF0000"
            error = zo_strformat("You are wearing <<1>> pieces of\n<<2>>", data.numEquipped, setName)
        elseif (data.numEquipped == 3) then
            -- 3 pieces is probably ok
            color = "|cFFFF00"
        elseif (data.numEquipped == 4) then
            -- 4 pieces is probably not correct
            color = "|cFF0000"
            error = zo_strformat("You are wearing <<1>> pieces of\n<<2>>", data.numEquipped, setName)
        end
        table.insert(result, zo_strformat("<<1>><<2>><<3>> <<C:4>>", color, data.numEquipped, (color == "") and "" or "|cAAAAAA", setName))
    end

    local resultString = table.concat(result, " / ")
    if (KyzderpsDerps.savedOptions.antispud.equipped.printToChat) then
        KyzderpsDerps:msg("Equipped" .. extraText .. ": " .. resultString)
    end
    Spud.UpdateBuffTheGroup(equippedSets)
    Spud.Display(error and (error .. extraText) or nil, isFrontbar and Spud.FRONTBAR or Spud.BACKBAR)
end

local function CheckAllSlots()
    EVENT_MANAGER:UnregisterForUpdate(KyzderpsDerps.name .. "SpudEquippedTimeout")

    CheckEmptySlots()
    CheckSlotsSets(true)
    if (GetUnitLevel("player") >= GetWeaponSwapUnlockedLevel()) then
        CheckSlotsSets(false)
    end
end

-- EVENT_INVENTORY_SINGLE_SLOT_UPDATE (number eventCode, Bag bagId, number slotId, boolean isNewItem, ItemUISoundCategory itemSoundCategory, number inventoryUpdateReason, number stackCountChange)
local function OnSlotUpdated(_, bagId, slotId)
    -- Ignore costume updates, poison updates
    if (slotId == EQUIP_SLOT_COSTUME or slotId == EQUIP_SLOT_POISON or slotId == EQUIP_SLOT_BACKUP_POISON) then return end

    -- 1000ms would cover the double firing due to barswap swap gear or whatever it is, but it feels too sluggish
    EVENT_MANAGER:RegisterForUpdate(KyzderpsDerps.name .. "SpudEquippedTimeout", 500, CheckAllSlots)
end

function Spud.InitializeEquipped()
    KyzderpsDerps:dbg("    Initializing AntiSpud Equipped...")

    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "SpudEquipped", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnSlotUpdated)
    EVENT_MANAGER:AddFilterForEvent(KyzderpsDerps.name .. "SpudEquipped", EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
        REGISTER_FILTER_BAG_ID, BAG_WORN,
        REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)

    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "ArmoryEquipped", EVENT_ARMORY_BUILD_RESTORE_RESPONSE, CheckAllSlots)

    Spud.InitializeBTG()

    zo_callLater(CheckAllSlots, 1000)
end

function Spud.UninitializeEquipped()
    EVENT_MANAGER:UnregisterForEvent(KyzderpsDerps.name .. "SpudEquipped", EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    Spud.Display(nil, Spud.MISSING)
    Spud.Display(nil, Spud.FRONTBAR)
    Spud.Display(nil, Spud.BACKBAR)
    AntiSpudEquipped:SetHidden(true)
end
