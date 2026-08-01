local MPL = MPL


CRAFTING_SKILLS = {
    CRAFTING_TYPE_BLACKSMITHING,
    CRAFTING_TYPE_CLOTHIER,
    CRAFTING_TYPE_WOODWORKING,
    CRAFTING_TYPE_JEWELRYCRAFTING,
}

-- == TODO: POSSIBLE LOCALIZATION ISSUE? BETTER WAY TO HANDLE NAMES? ==

CRAFTING_SKILL_NAMES = {
        [CRAFTING_TYPE_BLACKSMITHING]   = "Blacksmithing",
        [CRAFTING_TYPE_CLOTHIER]        = "Clothing",
        [CRAFTING_TYPE_WOODWORKING]     = "Woodworking",
        [CRAFTING_TYPE_JEWELRYCRAFTING] = "Jewelry",
}

local TRAIT_TYPE_NAMES = {

    [ITEM_TRAIT_TYPE_NONE] = "ITEM_TRAIT_TYPE_NONE",

    [ITEM_TRAIT_TYPE_ARMOR_DIVINES]        = "Divines",
    [ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE]   = "Impenetrable",
    [ITEM_TRAIT_TYPE_ARMOR_INFUSED]        = "Infused",
    [ITEM_TRAIT_TYPE_ARMOR_NIRNHONED]      = "Nirnhoned",
    [ITEM_TRAIT_TYPE_ARMOR_PROSPEROUS]     = "Invigorating",
    [ITEM_TRAIT_TYPE_ARMOR_REINFORCED]     = "Reinforced",
    [ITEM_TRAIT_TYPE_ARMOR_STURDY]         = "Sturdy",
    [ITEM_TRAIT_TYPE_ARMOR_TRAINING]       = "Training",
    [ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED]    = "Well-Fitted",

    [ITEM_TRAIT_TYPE_JEWELRY_ARCANE]       = "Arcane",
    [ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY] = "Bloodthirsty",
    [ITEM_TRAIT_TYPE_JEWELRY_HARMONY]      = "Harmony",
    [ITEM_TRAIT_TYPE_JEWELRY_HEALTHY]      = "Healthy",
    [ITEM_TRAIT_TYPE_JEWELRY_INFUSED]      = "Infused",
    [ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE]   = "Protective",
    [ITEM_TRAIT_TYPE_JEWELRY_ROBUST]       = "Robust",
    [ITEM_TRAIT_TYPE_JEWELRY_SWIFT]        = "Swift",
    [ITEM_TRAIT_TYPE_JEWELRY_TRIUNE]       = "Triune",

    [ITEM_TRAIT_TYPE_WEAPON_CHARGED]       = "Charged",
    [ITEM_TRAIT_TYPE_WEAPON_DECISIVE]      = "Decisive",
    [ITEM_TRAIT_TYPE_WEAPON_DEFENDING]     = "Defending",
    [ITEM_TRAIT_TYPE_WEAPON_INFUSED]       = "Infused",
    [ITEM_TRAIT_TYPE_WEAPON_NIRNHONED]     = "Nirnhoned",
    [ITEM_TRAIT_TYPE_WEAPON_POWERED]       = "Powered",
    [ITEM_TRAIT_TYPE_WEAPON_PRECISE]       = "Precise",
    [ITEM_TRAIT_TYPE_WEAPON_SHARPENED]     = "Sharpened",
    [ITEM_TRAIT_TYPE_WEAPON_TRAINING]      = "Training",
}

local RESEARCHABLE_TRAITS = {

    [ITEM_TRAIT_TYPE_ARMOR_DIVINES]        = true,
    [ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE]   = true,
    [ITEM_TRAIT_TYPE_ARMOR_INFUSED]        = true,
    [ITEM_TRAIT_TYPE_ARMOR_NIRNHONED]      = true,
    [ITEM_TRAIT_TYPE_ARMOR_PROSPEROUS]     = true,
    [ITEM_TRAIT_TYPE_ARMOR_REINFORCED]     = true,
    [ITEM_TRAIT_TYPE_ARMOR_STURDY]         = true,
    [ITEM_TRAIT_TYPE_ARMOR_TRAINING]       = true,
    [ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED]    = true,

    [ITEM_TRAIT_TYPE_JEWELRY_ARCANE]       = true,
    [ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY] = true,
    [ITEM_TRAIT_TYPE_JEWELRY_HARMONY]      = true,
    [ITEM_TRAIT_TYPE_JEWELRY_HEALTHY]      = true,
    [ITEM_TRAIT_TYPE_JEWELRY_INFUSED]      = true,
    [ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE]   = true,
    [ITEM_TRAIT_TYPE_JEWELRY_ROBUST]       = true,
    [ITEM_TRAIT_TYPE_JEWELRY_SWIFT]        = true,
    [ITEM_TRAIT_TYPE_JEWELRY_TRIUNE]       = true,

    [ITEM_TRAIT_TYPE_WEAPON_CHARGED]       = true,
    [ITEM_TRAIT_TYPE_WEAPON_DECISIVE]      = true,
    [ITEM_TRAIT_TYPE_WEAPON_DEFENDING]     = true,
    [ITEM_TRAIT_TYPE_WEAPON_INFUSED]       = true,
    [ITEM_TRAIT_TYPE_WEAPON_NIRNHONED]     = true,
    [ITEM_TRAIT_TYPE_WEAPON_POWERED]       = true,
    [ITEM_TRAIT_TYPE_WEAPON_PRECISE]       = true,
    [ITEM_TRAIT_TYPE_WEAPON_SHARPENED]     = true,
    [ITEM_TRAIT_TYPE_WEAPON_TRAINING]      = true,
}

local KNOWN_ICON   = "|t24:24:esoui/art/hud/gamepad/gp_radialicon_accept_down.dds|t"
local UNKNOWN_ICON = "|t24:24:esoui/art/hud/gamepad/gp_radialicon_cancel_down.dds|t"
local RESEARCH_ICON = "|t24:24:/esoui/art/miscellaneous/timer_32.dds|t"
local INVENTORY_AVAILABLE_ICON = "|t24:24:/esoui/art/tutorial/gamepad/gp_inventory_icon_all.dds|t"
local BANK_AVAILABLE_ICON = "|t24:24:/esoui/art/icons/servicemappins/servicepin_bank.dds|t"

local function GetTraitConstantName(traitType)
    return TRAIT_TYPE_NAMES[traitType] or ("UNKNOWN_TRAIT_TYPE_" .. tostring(traitType))
end

local function FormatResearchTime(seconds)
    local days    = math.floor(seconds / 86400)
    seconds       = seconds % 86400

    local hours   = math.floor(seconds / 3600)
    seconds       = seconds % 3600

    local minutes = math.floor(seconds / 60)
    local secs    = seconds % 60

    local parts = {}

    if days > 0 then
        table.insert(parts, string.format("%dd", days))
    end
    if hours > 0 or days > 0 then
        table.insert(parts, string.format("%dh", hours))
    end
    if minutes > 0 or hours > 0 or days > 0 then
        table.insert(parts, string.format("%dm", minutes))
    end

    table.insert(parts, string.format("%ds", secs))

    return table.concat(parts, " ")
end

-- == RESEARCH INVENTORY MAPPING ==

local BS_WEAP_LINES = {
    [1] = WEAPONTYPE_AXE,
    [2] = WEAPONTYPE_HAMMER,
    [3] = WEAPONTYPE_SWORD,
    [4] = WEAPONTYPE_TWO_HANDED_AXE,
    [5] = WEAPONTYPE_TWO_HANDED_HAMMER,
    [6] = WEAPONTYPE_TWO_HANDED_SWORD,
    [7] = WEAPONTYPE_DAGGER,
}

local BS_ARMOR_LINES = {
    [8] = EQUIP_TYPE_CHEST,
    [9] = EQUIP_TYPE_FEET,
    [10] = EQUIP_TYPE_HAND,
    [11] = EQUIP_TYPE_HEAD,
    [12] = EQUIP_TYPE_LEGS,
    [13] = EQUIP_TYPE_SHOULDERS,
    [14] = EQUIP_TYPE_WAIST,
}

local CL_LIGHT_LINES = {
    [1] = EQUIP_TYPE_CHEST,
    [2] = EQUIP_TYPE_FEET,
    [3] = EQUIP_TYPE_HAND,
    [4] = EQUIP_TYPE_HEAD,
    [5] = EQUIP_TYPE_LEGS,
    [6] = EQUIP_TYPE_SHOULDERS,
    [7] = EQUIP_TYPE_WAIST,
}

local CL_MED_LINES = {
    [8] = EQUIP_TYPE_CHEST,
    [9] = EQUIP_TYPE_FEET,
    [10] = EQUIP_TYPE_HAND,
    [11] = EQUIP_TYPE_HEAD,
    [12] = EQUIP_TYPE_LEGS,
    [13] = EQUIP_TYPE_SHOULDERS,
    [14] = EQUIP_TYPE_WAIST,
}

local WW_LINES = {
    [1] = WEAPONTYPE_BOW,
    [2] = WEAPONTYPE_FIRE_STAFF,
    [3] = WEAPONTYPE_FROST_STAFF,
    [4] = WEAPONTYPE_LIGHTNING_STAFF,
    [5] = WEAPONTYPE_HEALING_STAFF,
    [6] = WEAPONTYPE_SHIELD,
}

local JW_LINES = {
    [1] = EQUIP_TYPE_RING,
    [2] = EQUIP_TYPE_NECK,
}

-- == RESEARCH INVENTORY CHECKING ==

local BAG_SOURCES = {
    BAG_BACKPACK,
    BAG_BANK,
    BAG_SUBSCRIBER_BANK,
}

function MPL.GetAllTraitItems()
    local results = {}

    for _, bag in ipairs(BAG_SOURCES) do
        if bag ~= BAG_WORN then
            local slotCount = GetBagSize(bag)

            for slot = 0, slotCount - 1 do
                if not IsItemPlayerLocked(bag, slot) then
                    local traitType = GetItemTrait(bag, slot)

                    if RESEARCHABLE_TRAITS[traitType] then
                        local itemType   = GetItemType(bag, slot)
                        local weaponType = GetItemWeaponType(bag, slot)
                        local armorType  = GetItemArmorType(bag, slot)

                        table.insert(results, {
                            bag        = bag,
                            slot       = slot,
                            traitType  = traitType,
                            itemType   = itemType,
                            weaponType = weaponType,
                            armorType  = armorType,
                        })
                    end
                end
            end
        end
    end

    return results
end

function MPL.DoesItemMatchResearchLine(item, craftingSkill, lineIndex)
    local equipType  = GetItemEquipType(item.bag, item.slot)
    local armorType  = item.armorType
    local weaponType = item.weaponType

    if craftingSkill == CRAFTING_TYPE_BLACKSMITHING then
        if item.itemType == ITEMTYPE_WEAPON then
            return BS_WEAP_LINES[lineIndex] == weaponType
        elseif item.itemType == ITEMTYPE_ARMOR and armorType == ARMORTYPE_HEAVY then
            return BS_ARMOR_LINES[lineIndex] == equipType
        end
        return false
    end

    if craftingSkill == CRAFTING_TYPE_CLOTHIER then
        if item.itemType == ITEMTYPE_ARMOR and  armorType == ARMORTYPE_LIGHT then
            return CL_LIGHT_LINES[lineIndex] == equipType
        elseif item.itemType == ITEMTYPE_ARMOR and  armorType == ARMORTYPE_MEDIUM
        then
            return CL_MED_LINES[lineIndex] == equipType
        end
    end

    if craftingSkill == CRAFTING_TYPE_WOODWORKING then
        return WW_LINES[lineIndex] == weaponType
    end

    if craftingSkill == CRAFTING_TYPE_JEWELRYCRAFTING then
        if item.itemType ~= ITEMTYPE_ARMOR then return false end
        return JW_LINES[lineIndex] == equipType
    end

    return false
end

local function GetResearchLineAndTraitIndex(craftingSkill, traitType)
    local numLines = GetNumSmithingResearchLines(craftingSkill)

    for lineIndex = 1, numLines do
        local _, _, numTraits = GetSmithingResearchLineInfo(craftingSkill, lineIndex)

        for traitIndex = 1, numTraits do
            local researchTraitType = select(1,
                GetSmithingResearchLineTraitInfo(craftingSkill, lineIndex, traitIndex)
            )

            if researchTraitType == traitType then
                return lineIndex, traitIndex
            end
        end
    end

    return nil, nil
end

function MPL.BuildAvailableTraitLookup(craftingSkill)
    local items = MPL.GetAllTraitItems()
    local available = {}

    local numLines = GetNumSmithingResearchLines(craftingSkill)

    for lineIndex = 1, numLines do
        local _, _, numTraits = GetSmithingResearchLineInfo(craftingSkill, lineIndex)

        for traitIndex = 1, numTraits do
            local researchTraitType = select(1,
                GetSmithingResearchLineTraitInfo(craftingSkill, lineIndex, traitIndex)
            )

            for _, item in ipairs(items) do
                if MPL.DoesItemMatchResearchLine(item, craftingSkill, lineIndex) and item.traitType == researchTraitType then
                    available[lineIndex] = available[lineIndex] or {}
                    available[lineIndex][traitIndex] = {
                        inBank = (item.bag == BAG_BANK or item.bag == BAG_SUBSCRIBER_BANK),
                    }
                   break
                end
            end
        end
    end

    return available
end

-- == RESEARCH PANEL CALCULATING ==

function MPL.GetAllActiveResearchTimers(savedResearch, savedTimestamp)

    -- == NO SAVED DATA, FALLBACK TO CURRENT CHARACTER ==

    if not savedResearch or not savedTimestamp then
        local results = {
            [CRAFTING_TYPE_BLACKSMITHING]   = { header = "Blacksmithing",   lines = {}, active = 0, max = 0 },
            [CRAFTING_TYPE_CLOTHIER]        = { header = "Clothing",        lines = {}, active = 0, max = 0 },
            [CRAFTING_TYPE_WOODWORKING]     = { header = "Woodworking",     lines = {}, active = 0, max = 0 },
            [CRAFTING_TYPE_JEWELRYCRAFTING] = { header = "Jewelry",         lines = {}, active = 0, max = 0 },
        }

        for _, craftingSkill in ipairs(CRAFTING_SKILLS) do
            local craftData = results[craftingSkill]
            craftData.max = GetMaxSimultaneousSmithingResearch(craftingSkill)

            local numLines = GetNumSmithingResearchLines(craftingSkill)

            for lineIndex = 1, numLines do
                local lineName, _, numTraits =
                    GetSmithingResearchLineInfo(craftingSkill, lineIndex)

                if craftingSkill == CRAFTING_TYPE_WOODWORKING then
                    lineName = lineName:gsub("[Ss]taff", ""):gsub("%s+$", "")
                elseif craftingSkill == CRAFTING_TYPE_CLOTHIER and lineName == "Robe & Jerkin" then
                    lineName = "Robe"
                end

                for traitIndex = 1, numTraits do
                    local traitType = select(1, GetSmithingResearchLineTraitInfo(craftingSkill, lineIndex, traitIndex))
                    local duration, timeRemainingSecs =
                        GetSmithingResearchLineTraitTimes(craftingSkill, lineIndex, traitIndex)

                    if duration and timeRemainingSecs and timeRemainingSecs > 0 then
                        craftData.active = craftData.active + 1

                        table.insert(craftData.lines, string.format(
                            "|t24:24:/esoui/art/miscellaneous/timer_32.dds|t %s (%s): %s",
                            lineName,
                            GetTraitConstantName(traitType),
                            FormatResearchTime(timeRemainingSecs)
                        ))
                    end
                end
            end
        end

        local final = {}
        for _, craftingSkill in ipairs({
            CRAFTING_TYPE_BLACKSMITHING,
            CRAFTING_TYPE_CLOTHIER,
            CRAFTING_TYPE_WOODWORKING,
            CRAFTING_TYPE_JEWELRYCRAFTING,
        }) do
            local craft = results[craftingSkill]
            local header = string.format("%s (%d/%d)", craft.header, craft.active, craft.max)
            local body = (#craft.lines == 0) and "No active research." or table.concat(craft.lines, "\n")
            table.insert(final, { header = header, body = body })
        end

        return final
    end

    -- == IF SAVED DATA EXISTS USE BELOW, DEFAULT HANDLING ==

    local now = GetTimeStamp()
    local elapsed = now - savedTimestamp

    local results = {
        [CRAFTING_TYPE_BLACKSMITHING]   = { header = "Blacksmithing",   lines = {}, active = 0, max = 0 },
        [CRAFTING_TYPE_CLOTHIER]        = { header = "Clothing",        lines = {}, active = 0, max = 0 },
        [CRAFTING_TYPE_WOODWORKING]     = { header = "Woodworking",     lines = {}, active = 0, max = 0 },
        [CRAFTING_TYPE_JEWELRYCRAFTING] = { header = "Jewelry",         lines = {}, active = 0, max = 0 },
    }

    for _, craftingSkill in ipairs(CRAFTING_SKILLS) do
        local craftData = results[craftingSkill]

        local savedCraft = savedResearch[craftingSkill]

        if savedCraft then

        craftData.max = savedCraft.max or GetMaxSimultaneousSmithingResearch(craftingSkill)


            for _, lineData in ipairs(savedCraft.lines) do
                local lineName = lineData.lineName

                for _, traitInfo in ipairs(lineData.traits) do
                    if traitInfo.researching and traitInfo.timeRemainingSecs then
                        local remaining = math.max(0, traitInfo.timeRemainingSecs - elapsed)

                        if remaining > 0 then
                            craftData.active = craftData.active + 1

                            table.insert(craftData.lines, string.format(
                                "|t24:24:/esoui/art/miscellaneous/timer_32.dds|t %s (%s): %s",
                                lineName,
                                GetTraitConstantName(traitInfo.traitType),
                                FormatResearchTime(remaining)
                            ))
                        end
                    end
                end
            end
        end
    end

    local final = {}
    for _, craftingSkill in ipairs({
        CRAFTING_TYPE_BLACKSMITHING,
        CRAFTING_TYPE_CLOTHIER,
        CRAFTING_TYPE_WOODWORKING,
        CRAFTING_TYPE_JEWELRYCRAFTING,
    }) do
        local craft = results[craftingSkill]
        local header = string.format("%s (%d/%d)", craft.header, craft.active, craft.max)
        local body = (#craft.lines == 0) and "No active research." or table.concat(craft.lines, "\n")
        table.insert(final, { header = header, body = body })
    end

    return final
end

function MPL.UpdateResearchPanel()
    if MPL.GetAllHidden() then
        MPL_ResearchPanelTimerHeader1:SetText("Blacksmithing (0/1)")
        MPL_ResearchPanelTimerText1:SetText("")
        MPL_ResearchPanelTimerHeader2:SetText("Clothing (0/1)")
        MPL_ResearchPanelTimerText2:SetText("")
        MPL_ResearchPanelTimerHeader3:SetText("Woodworking (0/1)")
        MPL_ResearchPanelTimerText3:SetText("")
        MPL_ResearchPanelTimerHeader4:SetText("Jewelry (0/1)")
        MPL_ResearchPanelTimerText4:SetText("")
        return
    end

    local timers = MPL.GetAllActiveResearchTimers(MPL.loadedResearch, MPL.loadedTimeStamp)

    MPL_ResearchPanelTimerHeader1:SetText(timers[1].header)
    MPL_ResearchPanelTimerText1:SetText(timers[1].body)

    MPL_ResearchPanelTimerHeader2:SetText(timers[2].header)
    MPL_ResearchPanelTimerText2:SetText(timers[2].body)

    MPL_ResearchPanelTimerHeader3:SetText(timers[3].header)
    MPL_ResearchPanelTimerText3:SetText(timers[3].body)

    MPL_ResearchPanelTimerHeader4:SetText(timers[4].header)
    MPL_ResearchPanelTimerText4:SetText(timers[4].body)
end

function MPL.GetResearchColumns(craftingSkill, savedData)
    local columns = {}

    if savedData then
        local craft = savedData[craftingSkill]
        if not craft then return columns end

        local available = MPL.BuildAvailableTraitLookup(craftingSkill)

        for lineIndex, lineData in ipairs(craft.lines) do
            local lineName = lineData.lineName
            local traits = {}
            local knownCount = 0

            for traitIndex, traitInfo in ipairs(lineData.traits) do
                local traitName = TRAIT_TYPE_NAMES[traitInfo.traitType]
                local icon = UNKNOWN_ICON
                local color = "FF0000"

                if traitInfo.known then
                    knownCount = knownCount + 1
                    icon = KNOWN_ICON
                    table.insert(traits, string.format("%s |c00FF00%s|r", icon, traitName))

                elseif traitInfo.researching then
                    icon = RESEARCH_ICON
                    table.insert(traits, string.format("%s |c00FFFF%s|r", icon, traitName))

                else   
                    local traitData = available[lineIndex] and available[lineIndex][traitIndex]

                    if traitData then
                        icon = traitData.inBank and BANK_AVAILABLE_ICON or INVENTORY_AVAILABLE_ICON
                        color = "FFFF00"
                    end

                    table.insert(traits, string.format("%s |c%s%s|r", icon, color, traitName))
                end
            end

            columns[lineIndex] = {
                header = string.format("%s (%d)", lineName, knownCount),
                body = table.concat(traits, "\n"),
            }
        end

        return columns
    end
end

-- == RESEARCH MENU EVENT HANDLING ==

MPL.NotificationQueue = {}
MPL.NotificationDelay = 1500
MPL.NotificationActive = false

function MPL.QueueNotification(message)
    table.insert(MPL.NotificationQueue, message)
    MPL.ProcessNotificationQueue()
end

function MPL.ProcessNotificationQueue()
    if MPL.NotificationActive then return end
    if #MPL.NotificationQueue == 0 then return end

    MPL.NotificationActive = true

    local message = table.remove(MPL.NotificationQueue, 1)

    PlaySound(SOUNDS.ACHIEVEMENT_AWARDED)

    MPL.chat:Print(message)

    zo_callLater(function()
        MPL.NotificationActive = false
        MPL.ProcessNotificationQueue()
    end, MPL.NotificationDelay)
end

local function NotifyResearchComplete(charName, lineName, traitName)
    if not MPL.DoResearchNotification then return end

    local message = string.format("%s finished researching %s (%s)", charName, lineName, traitName)
    MPL.QueueNotification(message)
end

function MPL.UpdateExpiredResearch(charId, charName, savedResearch, savedTimestamp)
    local now = GetTimeStamp()
    local elapsed = now - savedTimestamp

    local changed = false

    for craftingSkill, craftData in pairs(savedResearch) do
        for _, lineData in ipairs(craftData.lines) do
            for _, traitInfo in ipairs(lineData.traits) do

                if traitInfo.researching and traitInfo.timeRemainingSecs then
                    local remaining = traitInfo.timeRemainingSecs - elapsed

                    if remaining <= 0 then
                        traitInfo.researching = false
                        traitInfo.timeRemainingSecs = nil
                        traitInfo.known = true

                        NotifyResearchComplete(charName or "Unknown Character", lineData.lineName, GetTraitConstantName(traitInfo.traitType))

                        changed = true
                    end
                end
            end
        end
    end
end

local function OnResearchStarted(_, craftingSkill, lineIndex, traitIndex)
    MPL.SaveResearchForCharacter()
end

local function OnResearchCanceled(_, craftingSkill, lineIndex, traitIndex)
    MPL.SaveResearchForCharacter()
end

local function OnInventoryChange()
    if not MPL_CraftingFragment:IsShowing() then return end

    MPL.LoadSavedResearch(MPL.currentCharacterIndex)
end

EVENT_MANAGER:RegisterForEvent("MPL_ResearchStarted", EVENT_SMITHING_TRAIT_RESEARCH_STARTED, OnResearchStarted)

EVENT_MANAGER:RegisterForEvent("MPL_ResearchCanceled", EVENT_SMITHING_TRAIT_RESEARCH_CANCELED, OnResearchCanceled)

EVENT_MANAGER:RegisterForEvent("MPL_SaveOnLogout", EVENT_PLAYER_DEACTIVATED, MPL.SaveResearchForCharacter)

MPL.openStation = CRAFTING_TYPE_INVALID

local researchCrafts = {
    [CRAFTING_TYPE_BLACKSMITHING] = true,
    [CRAFTING_TYPE_CLOTHIER] = true,
    [CRAFTING_TYPE_WOODWORKING] = true,
    [CRAFTING_TYPE_JEWELRYCRAFTING] = true,
}

EVENT_MANAGER:RegisterForEvent("MPL_ResearchStations", EVENT_CRAFTING_STATION_INTERACT, function(_, craftSkill)
    if researchCrafts[craftSkill] then
        MPL.openStation = craftSkill
    end
end)

EVENT_MANAGER:RegisterForEvent("MPL_InventoryChange", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnInventoryChange)
