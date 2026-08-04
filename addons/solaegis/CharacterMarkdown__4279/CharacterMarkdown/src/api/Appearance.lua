-- CharacterMarkdown - API Layer - Appearance
-- Player outfit, dyes, active mount, active collectibles

local CM = CharacterMarkdown
CM.api = CM.api or {}
CM.api.appearance = {}

local api = CM.api.appearance

local function CleanName(name)
    if not name or type(name) ~= "string" then
        return name or "Unknown"
    end
    return name:gsub("%^%w+$", "")
end

local function GetActorCategory()
    return GAMEPLAY_ACTOR_CATEGORY_PLAYER or 0
end

function api.GetEquippedOutfit()
    local actorCategory = GetActorCategory()
    local outfitIndex = CM.SafeCall(GetEquippedOutfitIndex, actorCategory) or 0
    local outfitName = nil
    if outfitIndex and outfitIndex > 0 then
        outfitName = CM.SafeCall(GetOutfitName, actorCategory, outfitIndex)
    end
    return {
        index = outfitIndex or 0,
        name = CleanName(outfitName or (outfitIndex > 0 and ("Outfit " .. tostring(outfitIndex)) or "Default")),
    }
end

function api.GetOutfitSlots()
    local actorCategory = GetActorCategory()
    local outfit = api.GetEquippedOutfit()
    local slots = {}
    if not outfit.index or outfit.index <= 0 or not GetOutfitSlotInfo then
        return slots
    end

    -- Common outfit slots (enum values vary; iterate a safe range)
    for outfitSlot = 0, 31 do
        local success, collectibleId, itemLink, primaryDye, secondaryDye, accentDye =
            CM.SafeCallMulti(GetOutfitSlotInfo, actorCategory, outfit.index, outfitSlot)
        if success and collectibleId and collectibleId > 0 then
            local name = CleanName(CM.SafeCall(GetCollectibleName, collectibleId) or "")
            local dyes = {}
            if GetRestyleSlotCurrentDyes and RESTYLE_MODE_OUTFIT then
                local ok, d1, d2, d3 =
                    CM.SafeCallMulti(GetRestyleSlotCurrentDyes, RESTYLE_MODE_OUTFIT, outfit.index, outfitSlot)
                if ok then
                    for _, dyeId in ipairs({ d1, d2, d3 }) do
                        if dyeId and dyeId > 0 then
                            local dyeName = nil
                            if GetDyeInfoById then
                                local ds, dn = CM.SafeCallMulti(GetDyeInfoById, dyeId)
                                if ds and dn then
                                    dyeName = CleanName(dn)
                                end
                            end
                            table.insert(dyes, dyeName or ("Dye " .. tostring(dyeId)))
                        end
                    end
                end
            elseif primaryDye or secondaryDye or accentDye then
                for _, dyeId in ipairs({ primaryDye, secondaryDye, accentDye }) do
                    if dyeId and dyeId > 0 then
                        table.insert(dyes, "Dye " .. tostring(dyeId))
                    end
                end
            end
            table.insert(slots, {
                slot = outfitSlot,
                collectibleId = collectibleId,
                name = name ~= "" and name or ("Collectible " .. tostring(collectibleId)),
                dyes = dyes,
            })
        end
    end

    return slots
end

function api.GetDyeCollectionSummary()
    local total = CM.SafeCall(GetNumDyes) or 0
    local known = 0
    if IsDyeIndexKnown and total > 0 then
        for i = 1, total do
            if CM.SafeCall(IsDyeIndexKnown, i) then
                known = known + 1
            end
        end
    end
    return {
        known = known,
        total = total,
        percent = total > 0 and math.floor((known / total) * 100) or 0,
    }
end

function api.GetActiveMount()
    local actorCategory = GetActorCategory()
    local mountId = nil
    local name = nil

    if GetActiveCollectibleByType and COLLECTIBLE_CATEGORY_TYPE_MOUNT then
        mountId = CM.SafeCall(GetActiveCollectibleByType, COLLECTIBLE_CATEGORY_TYPE_MOUNT, actorCategory)
        if mountId and mountId > 0 then
            name = CleanName(CM.SafeCall(GetCollectibleName, mountId) or "")
        end
    end

    local skinId = nil
    local skinName = nil
    if HasMountSkin and CM.SafeCall(HasMountSkin) and GetMountSkinId then
        skinId = CM.SafeCall(GetMountSkinId)
        if skinId and skinId > 0 then
            skinName = CleanName(CM.SafeCall(GetCollectibleName, skinId) or "")
        end
    end

    return {
        collectibleId = mountId,
        name = (name and name ~= "") and name or nil,
        skinId = skinId,
        skinName = (skinName and skinName ~= "") and skinName or nil,
        isMounted = CM.SafeCall(IsMounted) or false,
    }
end

function api.GetActiveCollectibles()
    local actorCategory = GetActorCategory()
    local categories = {
        { key = "costume", type = COLLECTIBLE_CATEGORY_TYPE_COSTUME },
        { key = "personality", type = COLLECTIBLE_CATEGORY_TYPE_PERSONALITY },
        { key = "polymorph", type = COLLECTIBLE_CATEGORY_TYPE_POLYMORPH },
        { key = "skin", type = COLLECTIBLE_CATEGORY_TYPE_SKIN },
        { key = "hat", type = COLLECTIBLE_CATEGORY_TYPE_HAT },
        { key = "hair", type = COLLECTIBLE_CATEGORY_TYPE_HAIR },
    }

    local active = {}
    for _, cat in ipairs(categories) do
        if cat.type then
            local total = CM.SafeCall(GetTotalCollectiblesByCategoryType, cat.type) or 0
            for i = 1, total do
                local id = CM.SafeCall(GetCollectibleIdFromType, cat.type, i)
                if id and CM.SafeCall(IsCollectibleActive, id, actorCategory) then
                    active[cat.key] = {
                        id = id,
                        name = CleanName(CM.SafeCall(GetCollectibleName, id) or "Unknown"),
                    }
                    break
                end
            end
        end
    end
    return active
end

CM.DebugPrint("API", "Appearance API module loaded")
