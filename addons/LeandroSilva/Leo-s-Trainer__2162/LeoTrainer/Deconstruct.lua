local Deconstruct = {
    queue = {},
    keybindStripDescriptor =
    {
        {
            name = "Deconstruct",
            keybind = "LEOTRAINER_DECON",
            callback = function() LeoTrainer.deconstruct.DoDeconstruct() end--,
        },
        alignment = KEYBIND_STRIP_ALIGN_CENTER,
    }
}

function Deconstruct.CanItemBeDeconstructed(bagId, slotIndex, itemLink, craftSkill)
    if not FCOIS then return false end

    if itemLink == nil then itemLink = GetItemLink(bagId, slotIndex) end

    -- local type = GetItemType(bagId, slotIndex)
    -- if type ~= ITEMTYPE_ARMOR and type ~= ITEMTYPE_WEAPON then return false end

    local markedDecon = true
    if FCOIS.IsIconEnabled(FCOIS_CON_ICON_DECONSTRUCTION) then
        markedDecon = FCOIS.IsMarked(bagId, slotIndex, FCOIS_CON_ICON_DECONSTRUCTION)
    end

    local markedIntri = true
    if FCOIS.IsIconEnabled(FCOIS_CON_ICON_INTRICATE) then
        markedIntri = FCOIS.IsMarked(bagId, slotIndex, FCOIS_CON_ICON_INTRICATE)
    end

    if not markedDecon and not markedIntri then
        -- LeoTrainer.debug(itemLink .. " not marked for deconstruct nor intricate")
        return false
    end

    local hasSet, setName = GetItemLinkSetInfo(itemLink)
    if not LeoTrainer.settings.deconstruct.allowSets and hasSet then
        -- LeoTrainer.debug(itemLink .. " is from set " .. setName)
        return false
    end

    if craftSkill > 0 and LeoTrainer.settings.deconstruct.maxQuality[craftSkill] < GetItemQuality(bagId, slotIndex) then
        -- LeoTrainer.debug(itemLink .. " is with higher quality")
        return false
    end

    if bagId ~= BAG_BACKPACK then
        local line = LeoTrainer.CraftToLineSkill(craftSkill)
        local craftLevel = select(8, GetSkillAbilityInfo(SKILL_TYPE_TRADESKILL, line, 1))
        local itemLevel = GetItemLinkRequiredLevel(itemLink)
        -- LeoTrainer.debug(itemLink .. " CraftLvel " .. tostring(craftLevel) .. " itemLevel " .. tostring(itemLevel))
        if LeoTrainer.settings.deconstruct.onlyClosestLevel and craftLevel > 0 and
            (itemLevel / 5 < craftLevel - 3 or itemLevel / 5 > craftLevel + 6) then
                -- LeoTrainer.debug(itemLink .. " is with level too far")
                return false
        end
    end

    return true
end

function Deconstruct.HandleItem(bagId, slotIndex, itemLink, craftSkill)
    if bagId ~= BAG_BACKPACK and not LeoTrainer.settings.deconstruct.allowBank then return false end

    if not Deconstruct.CanItemBeDeconstructed(bagId, slotIndex, itemLink, craftSkill) then return false end

    if LeoTrainer.settings.deconstruct.listInChat then
        local bagName = "Backpack"
        if bagId == BAG_BANK or bagId == BAG_SUBSCRIBER_BANK then bagName = "Bank" end
        LeoTrainer.log("Can be deconstructed: " .. itemLink .. " (" .. bagName .. ")")
    end

    table.insert(Deconstruct.queue, {
        bagId = bagId,
        slotIndex = slotIndex,
        itemLink = itemLink,
        craftSkill = craftSkill,
        selected = false
    })

    return true
end

function Deconstruct.DoDeconstruct(fromBags)
    if fromBags == nil then
        fromBags = {BAG_BACKPACK}
        if LeoTrainer.settings.deconstruct.allowBank then
            fromBags = {BAG_BACKPACK,BAG_BANK,BAG_SUBSCRIBER_BANK}
        end
    end

    KEYBIND_STRIP:RemoveKeybindButtonGroup(Deconstruct.keybindStripDescriptor)
    if #Deconstruct.queue > 0 then
        if ENCHANTING.enchantingMode ~= ENCHANTING_MODE_EXTRACTION then
            ZO_MenuBar_SelectDescriptor(ENCHANTING.modeBar, ENCHANTING_MODE_EXTRACTION)
        end
        PrepareDeconstructMessage()
        for i, itemData in pairs(Deconstruct.queue) do
            for _, bagId in pairs(fromBags) do
                if itemData.bagId == bagId then
                    LeoTrainer.log("Deconstructing " .. itemData.itemLink)
                    AddItemToDeconstructMessage(itemData.bagId, itemData.slotIndex, 1)
                end
            end
        end
        SendDeconstructMessage()
        Deconstruct.queue = {}
        return true
    end
    return false
end

function Deconstruct.ShouldDeconstruct(craftSkill)
    local line = LeoTrainer.CraftToLineSkill(craftSkill)
    return GetSkillLineDynamicInfo(SKILL_TYPE_TRADESKILL, line) < 50
end

function Deconstruct.OnStationEnter(craftSkill)
    local line = LeoTrainer.CraftToLineSkill(craftSkill)
    local maxLevel = GetSkillLineDynamicInfo(SKILL_TYPE_TRADESKILL, line) == 50
    if #Deconstruct.queue > 0 and not maxLevel then
        KEYBIND_STRIP:AddKeybindButtonGroup(Deconstruct.keybindStripDescriptor)
    end
    local done = false
    if LeoTrainer.settings.deconstruct.auto then
        done = Deconstruct.DoDeconstruct()
    end
    LeoTrainer.nextStage(done)
end

function Deconstruct.OnStationExit(craftSkill)
    KEYBIND_STRIP:RemoveKeybindButtonGroup(Deconstruct.keybindStripDescriptor)
    Deconstruct.queue = {}
end

function Deconstruct.Initialize()
end

LeoTrainer.deconstruct = Deconstruct
