
local Research = {
    queue = {},
    isResearching = false,
    keybindStripDescriptor =
    {
        {
            name = "Research",
            keybind = "LEOTRAINER_RESEARCH",
            callback = function() LeoTrainer.research.ResearchNext() end--,
        },
        alignment = KEYBIND_STRIP_ALIGN_CENTER,
    }
}

function Research.GetResearchData(link)
    if not link then return false end

    local craftSkill, line
    local trait = GetItemLinkTraitInfo(link)
    local equipType = GetItemLinkEquipType(link)

    if trait == ITEM_TRAIT_TYPE_NONE or trait == ITEM_TRAIT_TYPE_ARMOR_INTRICATE or trait == ITEM_TRAIT_TYPE_ARMOR_ORNATE
        or trait == ITEM_TRAIT_TYPE_WEAPON_INTRICATE or trait == ITEM_TRAIT_TYPE_WEAPON_ORNATE
        or trait == ITEM_TRAIT_TYPE_JEWELRY_INTRICATE or trait == ITEM_TRAIT_TYPE_JEWELRY_ORNATE then return false end

    local armorType = GetItemLinkArmorType(link)
    local weaponType = GetItemLinkWeaponType(link)
    if trait == ITEM_TRAIT_TYPE_ARMOR_NIRNHONED then trait = 19 end
    if trait == ITEM_TRAIT_TYPE_WEAPON_NIRNHONED then trait = 9 end
    if weaponType == WEAPONTYPE_AXE then craftSkill = CRAFTING_TYPE_BLACKSMITHING; line = 1;
    elseif weaponType == WEAPONTYPE_HAMMER then craftSkill = CRAFTING_TYPE_BLACKSMITHING; line = 2;
    elseif weaponType == WEAPONTYPE_SWORD then craftSkill = CRAFTING_TYPE_BLACKSMITHING; line = 3
    elseif weaponType == WEAPONTYPE_TWO_HANDED_AXE then craftSkill = CRAFTING_TYPE_BLACKSMITHING; line = 4;
    elseif weaponType == WEAPONTYPE_TWO_HANDED_HAMMER then craftSkill = CRAFTING_TYPE_BLACKSMITHING; line = 5;
    elseif weaponType == WEAPONTYPE_TWO_HANDED_SWORD then craftSkill = CRAFTING_TYPE_BLACKSMITHING; line = 6;
    elseif weaponType == WEAPONTYPE_DAGGER then craftSkill = CRAFTING_TYPE_BLACKSMITHING; line = 7;
    elseif weaponType == WEAPONTYPE_BOW then craftSkill = CRAFTING_TYPE_WOODWORKING; line = 1;
    elseif weaponType == WEAPONTYPE_FIRE_STAFF then craftSkill = CRAFTING_TYPE_WOODWORKING; line = 2;
    elseif weaponType == WEAPONTYPE_FROST_STAFF then craftSkill = CRAFTING_TYPE_WOODWORKING; line = 3;
    elseif weaponType == WEAPONTYPE_LIGHTNING_STAFF then craftSkill = CRAFTING_TYPE_WOODWORKING; line = 4;
    elseif weaponType == WEAPONTYPE_HEALING_STAFF then craftSkill = CRAFTING_TYPE_WOODWORKING; line = 5;
    elseif weaponType == WEAPONTYPE_SHIELD then craftSkill = CRAFTING_TYPE_WOODWORKING; line = 6;trait=trait-10;
    elseif equipType == EQUIP_TYPE_CHEST then line = 1
    elseif equipType == EQUIP_TYPE_FEET then line = 2
    elseif equipType == EQUIP_TYPE_HAND then line = 3
    elseif equipType == EQUIP_TYPE_HEAD then line = 4
    elseif equipType == EQUIP_TYPE_LEGS then line = 5
    elseif equipType == EQUIP_TYPE_SHOULDERS then line = 6
    elseif equipType == EQUIP_TYPE_WAIST then line = 7
    end

    if equipType == EQUIP_TYPE_NECK or equipType == EQUIP_TYPE_RING then
        craftSkill = CRAFTING_TYPE_JEWELRYCRAFTING
        line = equipType == EQUIP_TYPE_NECK and 1 or 2
        if trait == ITEM_TRAIT_TYPE_JEWELRY_ARCANE then trait = 1
        elseif trait == ITEM_TRAIT_TYPE_JEWELRY_HEALTHY then trait = 2
        elseif trait == ITEM_TRAIT_TYPE_JEWELRY_ROBUST then trait = 3
        elseif trait == ITEM_TRAIT_TYPE_JEWELRY_TRIUNE then trait = 4
        elseif trait == ITEM_TRAIT_TYPE_JEWELRY_INFUSED then trait = 5
        elseif trait == ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE then trait = 6
        elseif trait == ITEM_TRAIT_TYPE_JEWELRY_SWIFT then trait = 7
        elseif trait == ITEM_TRAIT_TYPE_JEWELRY_HARMONY then trait = 8
        elseif trait == ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY then trait = 9
        end
    else
        if armorType == ARMORTYPE_HEAVY then craftSkill = CRAFTING_TYPE_BLACKSMITHING; line = line + 7; trait = trait - 10; end
        if armorType == ARMORTYPE_MEDIUM then craftSkill = CRAFTING_TYPE_CLOTHIER; line = line + 7; trait = trait - 10; end
        if armorType == ARMORTYPE_LIGHT then craftSkill = CRAFTING_TYPE_CLOTHIER; trait = trait - 10; end
    end
    if craftSkill and line and trait then return craftSkill, line, trait
    else return false end
end

local function canIResearchItem(itemLink)
    local craftSkill, line, trait = Research.GetResearchData(itemLink)

    if craftSkill == nil then return false end

    local isKnown, isResearching = LeoAltholic.ResearchStatus(craftSkill, line, trait)
    if isKnown then
        -- LeoTrainer.debug('already known')
        return false
    end

    if isResearching then
        -- LeoTrainer.debug('is researching')
        return false
    end

    return true
end

function Research.CanItemBeResearched(bagId, slotIndex, itemLink, craftSkill)
    if not FCOIS then return false end

    if itemLink == nil then itemLink = GetItemLink(bagId, slotIndex) end

    local type = GetItemType(bagId, slotIndex)
    if type ~= ITEMTYPE_ARMOR and type ~= ITEMTYPE_WEAPON then return false end

    if FCOIS.IsIconEnabled(FCOIS_CON_ICON_RESEARCH) and not FCOIS.IsMarked(bagId, slotIndex, FCOIS_CON_ICON_RESEARCH) then
        -- LeoTrainer.debug(itemLink .. " not marked for research")
        return false
    end

    if LeoTrainer.settings.research.allowCrafted and GetItemCreatorName(bagId, slotIndex) == nil then
        -- LeoTrainer.debug(itemLink .. " not crafted")
        return false
    end

    local hasSet, setName = GetItemLinkSetInfo(itemLink)
    if not LeoTrainer.settings.research.allowSets and hasSet then
        -- LeoTrainer.debug(itemLink .. " is from set " .. setName)
        return false
    end

    if craftSkill ~= nil and craftSkill > 0 and LeoTrainer.settings.research.maxQuality[craftSkill] < GetItemQuality(bagId, slotIndex) then
        -- LeoTrainer.debug(itemLink .. " is with higher quality")
        return false
    end

    return true
end

function Research.ScanBags()
    local list = {}
    local items = SHARED_INVENTORY:GenerateFullSlotData(nil, BAG_BACKPACK, BAG_BANK, BAG_SUBSCRIBER_BANK)
    for _, data in pairs(items) do
        local itemLink = GetItemLink(data.bagId, data.slotIndex, LINK_STYLE_BRACKETS)
        local craftSkill, line, trait = LeoTrainer.research.GetResearchData(itemLink)
        if LeoTrainer.research.CanItemBeResearched(data.bagId, data.slotIndex, itemLink, craftSkill) then
            table.insert(list, {
                bagId = data.bagId,
                slotIndex = data.slotIndex,
                itemLink = itemLink,
                craftSkill = craftSkill,
                line = line,
                trait = trait,
                selected = false
            })
        end
    end

    return list
end

function Research.HandleItem(bagId, slotIndex, itemLink, craftSkill)

    local itemCraftSkill, line, trait = Research.GetResearchData(itemLink)

    if itemCraftSkill ~= craftSkill then return false end

    if not Research.CanItemBeResearched(bagId, slotIndex, itemLink, craftSkill) then return false end

    if not canIResearchItem(itemLink) then return false end

    if LeoTrainer.settings.research.listInChat then
        LeoTrainer.log("Can be researched: " .. itemLink)
    end

    table.insert(Research.queue, {
        bagId = bagId,
        slotIndex = slotIndex,
        itemLink = itemLink,
        craftSkill = craftSkill,
        line = line,
        trait = trait,
        selected = false,
        isResearching = false
    })

    return true
end

function Research.OnResearchComplete(_, craftSkill)
    EVENT_MANAGER:UnregisterForUpdate(LeoTrainer.name .. ".ResearchTimeout")
    EVENT_MANAGER:UnregisterForEvent(LeoTrainer.name, EVENT_CRAFT_COMPLETED)

    if not Research.isResearching then
        LeoTrainer.nextStage(true)
        return
    end

    local myName = GetUnitName("player")
    local researching, total = LeoAltholic.GetResearchCounters(craftSkill)
    for j, data in pairs(Research.queue) do
        if data.isResearching == true then
            table.remove(Research.queue, j)
            break
        end
    end
    Research.isResearching = false

    if researching >= total then
        LeoTrainer.debug("No empty research slots.")
        LeoTrainer.nextStage(true)
        return
    end

    if #Research.queue > 0 then
        zo_callLater(function() Research.ResearchNext(craftSkill) end, 200)
        return
    end

    LeoTrainer.nextStage(true)
end

local function OnResearchTimeout(craftSkill)
    return function()
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, "Timeout during research")
        EVENT_MANAGER:UnregisterForEvent(LeoTrainer.name, EVENT_CRAFT_COMPLETED)
        LeoTrainer.nextStage()
    end
end

local function get(tbl, k, ...)
    if tbl == nil or tbl[k] == nil then return nil end
    if select('#', ...) == 0 then return tbl[k] end
    return get(tbl[k], ...)
end

local lineList

function Research.ResearchNext(craftSkill)
    Research.isResearching = false

    if craftSkill == nil then craftSkill = GetCraftingInteractionType() end

    if #Research.queue == 0 then
        LeoTrainer.debug("Nothing on research queue")
        LeoTrainer.nextStage()
        return
    end

    if not LeoTrainer.IsInUsableStation() or not LeoAltholic.HasStillResearchFor(craftSkill) then
        LeoTrainer.debug("Nothing to research here.")
        LeoTrainer.nextStage()
        return
    end

    local myName = GetUnitName("player")
    local researching, total = LeoAltholic.GetResearchCounters(craftSkill, myName)
    if researching >= total then
        LeoTrainer.debug("No empty research slots.")
        LeoTrainer.nextStage()
        return
    end
    if IsPerformingCraftProcess() == true then
        LeoTrainer.debug("Still crafting")
        Research.isResearching = true
        zo_callLater(function() Research.ResearchNext(craftSkill) end, 500)
        return
    end

    -- loop through the priority list and items to find a match
    if lineList == nil then lineList = LeoTrainer.GetPriorityLineList(myName, craftSkill) end
    for i, lineData in ipairs(lineList[myName][craftSkill]) do
        if not lineData.added and not lineData.isResearching then
            for j, data in pairs(Research.queue) do
                if lineData.line == data.line then
                    lineList[myName][craftSkill][i].added = true
                    local itemLink = GetItemLink(data.bagId, data.slotIndex, LINK_STYLE_BRACKETS)
                    local traitType = GetItemLinkTraitInfo(itemLink)
                    local traitName = GetString("SI_ITEMTRAITTYPE", traitType)
                    local message = zo_strformat("<<1>> <<2>> (<<3>>)",
                        GetString(SI_GAMEPAD_SMITHING_CURRENT_RESEARCH_HEADER),
                        itemLink,
                        traitName)
                    LeoTrainer.log(message)

                    EVENT_MANAGER:RegisterForUpdate(LeoTrainer.name .. ".ResearchTimeout", 2000, OnResearchTimeout(craftSkill))
                    EVENT_MANAGER:RegisterForEvent(LeoTrainer.name, EVENT_CRAFT_COMPLETED, Research.OnResearchComplete) -- normal craft is handled by LLC

                    Research.isResearching = true
                    Research.queue[j].isResearching = true
                    ResearchSmithingTrait(data.bagId, data.slotIndex)
                    return
                end
            end
        end
    end

    LeoTrainer.debug("No item found for research")
    LeoTrainer.nextStage()
end

function Research.ShouldResearch(craftSkill)
    return LeoAltholic.HasStillResearchFor(craftSkill)
end

function Research.OnStationEnter(craftSkill)
    lineList = nil
    if craftSkill == CRAFTING_TYPE_ENCHANTING or not LeoAltholic.HasStillResearchFor(craftSkill) then
        LeoTrainer.nextStage()
        return
    end

    if #Research.queue > 0 then
        KEYBIND_STRIP:AddKeybindButtonGroup(Research.keybindStripDescriptor)
    end

    if #Research.queue == 0 or not LeoTrainer.settings.research.auto then
        LeoTrainer.nextStage()
        return
    end

    Research.ResearchNext(craftSkill)
end

function Research.OnStationExit(craftSkill)
    EVENT_MANAGER:UnregisterForUpdate(LeoTrainer.name .. ".ResearchTimeout")
    EVENT_MANAGER:UnregisterForEvent(LeoTrainer.name, EVENT_CRAFT_COMPLETED)
    KEYBIND_STRIP:RemoveKeybindButtonGroup(Research.keybindStripDescriptor)
    Research.isResearching = false
    lineList = nil
    Research.queue = {}
end

function Research.Initialize()
    local charList = LeoAltholic.ExportCharacters()

    LeoTrainer.knowledge = {}
    LeoTrainer.missingKnowledge = {}

    for _, char in pairs(charList) do
        if LeoTrainer.data.trackedTraits[char.bio.name] == nil then
            LeoTrainer.data.trackedTraits[char.bio.name] = {}
        end
        if not LeoTrainer.data.fillSlot[char.bio.name] then
            LeoTrainer.data.fillSlot[char.bio.name] = {}
        end
        for _, craftId in pairs(LeoAltholic.craftResearch) do
            LeoTrainer.data.trackedTraits[char.bio.name][craftId] = LeoTrainer.data.trackedTraits[char.bio.name][craftId] or false
            LeoTrainer.data.fillSlot[char.bio.name][craftId] = LeoTrainer.data.fillSlot[char.bio.name][craftId] or false
        end

        for _,craft in pairs(LeoAltholic.craftResearch) do
            if LeoTrainer.knowledge[craft] == nil then LeoTrainer.knowledge[craft] = {} end
            if LeoTrainer.missingKnowledge[craft] == nil then LeoTrainer.missingKnowledge[craft] = {} end
            for line = 1, GetNumSmithingResearchLines(craft) do
                if LeoTrainer.knowledge[craft][line] == nil then LeoTrainer.knowledge[craft][line] = {} end
                if LeoTrainer.missingKnowledge[craft][line] == nil then LeoTrainer.missingKnowledge[craft][line] = {} end
                local _, _, numTraits = GetSmithingResearchLineInfo(craft, line)
                for trait = 1, numTraits do
                    if LeoTrainer.knowledge[craft][line][trait] == nil then LeoTrainer.knowledge[craft][line][trait] = {} end
                    if LeoTrainer.missingKnowledge[craft][line][trait] == nil then LeoTrainer.missingKnowledge[craft][line][trait] = {} end
                    if char.research.done[craft][line][trait] == true then
                        table.insert(LeoTrainer.knowledge[craft][line][trait], char.bio.name)
                    else
                        table.insert(LeoTrainer.missingKnowledge[craft][line][trait], char.bio.name)
                    end
                end
            end
        end
    end
end

LeoTrainer.research = Research
