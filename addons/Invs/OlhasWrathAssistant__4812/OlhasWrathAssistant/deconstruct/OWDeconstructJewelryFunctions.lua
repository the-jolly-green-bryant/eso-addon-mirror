local owa = OWAssistant
local deconstruct = owa.Deconstruct

local function IsJewelryStation()
    if deconstruct.IsUniversalStation() then
        return true
    end

    return deconstruct.currentCraftingType
        == CRAFTING_TYPE_JEWELRYCRAFTING
end

local function IsJewelryItem(itemLink)
    local equipType =
        GetItemLinkEquipType(itemLink)

    return equipType == EQUIP_TYPE_RING
        or equipType == EQUIP_TYPE_NECK
end

local function IsJewelryTradeable(
    bagId,
    slotIndex
)
    return IsItemBoPAndTradeable(
        bagId,
        slotIndex
    )
end

local function IsOrnateJewelry(
    itemLink,
    traitInformation
)
    local traitType =
        GetItemLinkTraitType(itemLink)

    return traitInformation
        == ITEM_TRAIT_INFORMATION_ORNATE
        or traitType
        == ITEM_TRAIT_TYPE_JEWELRY_ORNATE
end

local function IsIntricateJewelry(
    itemLink,
    traitInformation
)
    local traitType =
        GetItemLinkTraitType(itemLink)

    return traitInformation
        == ITEM_TRAIT_INFORMATION_INTRICATE
        or traitType
        == ITEM_TRAIT_TYPE_JEWELRY_INTRICATE
end

local function IsBasicJewelryTrait(
    traitType
)
    return traitType
        == ITEM_TRAIT_TYPE_JEWELRY_ROBUST
        or traitType
        == ITEM_TRAIT_TYPE_JEWELRY_ARCANE
        or traitType
        == ITEM_TRAIT_TYPE_JEWELRY_HEALTHY
end

local function IsResearchableJewelryTrait(
    traitType
)
    return traitType
        == ITEM_TRAIT_TYPE_JEWELRY_ROBUST
        or traitType
        == ITEM_TRAIT_TYPE_JEWELRY_ARCANE
        or traitType
        == ITEM_TRAIT_TYPE_JEWELRY_HEALTHY
        or traitType
        == ITEM_TRAIT_TYPE_JEWELRY_TRIUNE
        or traitType
        == ITEM_TRAIT_TYPE_JEWELRY_INFUSED
        or traitType
        == ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE
        or traitType
        == ITEM_TRAIT_TYPE_JEWELRY_SWIFT
        or traitType
        == ITEM_TRAIT_TYPE_JEWELRY_HARMONY
        or traitType
        == ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY
end

local function CanExtractJewelry(
    bagId,
    slotIndex
)
    return CanItemBeSmithingExtractedOrRefined(
        bagId,
        slotIndex,
        CRAFTING_TYPE_JEWELRYCRAFTING
    )
end

local function GetBagItemQuality(
    bagId,
    slotIndex
)
    local _, _, _, _, _, _, _, quality =
        GetItemInfo(bagId, slotIndex)

    return quality
end

local function MatchesJewelryResearchFilter(
    profile,
    itemLink,
    traitType
)
    if profile.researchMode
        == "basic_traits"
    then
        return IsBasicJewelryTrait(
            traitType
        )
    end

    if profile.researchMode == "all"
        or profile.researchMode
        == "keep_lowest_unresearched"
    then
        return IsResearchableJewelryTrait(
            traitType
        )
    end

    return false
end

local function IsJewelryAllowed(
    profile,
    bagId,
    slotIndex
)
    local itemLink =
        GetItemLink(bagId, slotIndex)

    if not itemLink or itemLink == "" then
        return false
    end

    if not IsJewelryItem(itemLink) then
        return false
    end

    if IsItemPlayerLocked(
        bagId,
        slotIndex
    ) then
        return false
    end

    if bagId ~= BAG_BACKPACK
        and not profile.fromBank
    then
        return false
    end

    if not CanExtractJewelry(
        bagId,
        slotIndex
    ) then
        return false
    end

    local quality =
        GetBagItemQuality(
            bagId,
            slotIndex
        )

    local maxQuality =
        deconstruct.GetMaxQuality(profile)

    if not quality
        or quality > maxQuality
    then
        return false
    end

    local traitType =
        GetItemLinkTraitType(itemLink)

    local traitInformation =
        GetItemTraitInformationFromItemLink(
            itemLink
        )

    local matchesFilter = false

    if IsItemReconstructed(
        bagId,
        slotIndex
    ) and profile.reconstructed
    then
        matchesFilter = true
    end

    if IsJewelryTradeable(
        bagId,
        slotIndex
    ) and profile.tradable
    then
        matchesFilter = true
    end

    if IsItemLinkCrafted(itemLink)
        and profile.crafted
    then
        matchesFilter = true
    end

    if IsOrnateJewelry(
        itemLink,
        traitInformation
    ) and profile.ornate
    then
        matchesFilter = true
    end

    if IsIntricateJewelry(
        itemLink,
        traitInformation
    ) and profile.intricate
    then
        matchesFilter = true
    end

    if MatchesJewelryResearchFilter(
        profile,
        itemLink,
        traitType
    ) then
        matchesFilter = true
    end

    if traitType == ITEM_TRAIT_TYPE_NONE
        and profile.noTrait
    then
        matchesFilter = true
    end

    return matchesFilter
end

local function CreateJewelryCandidate(
    bagId,
    slotIndex
)
    local itemLink = GetItemLink(
        bagId,
        slotIndex,
        LINK_STYLE_BRACKETS
    )

    return {
        bagId = bagId,
        slotIndex = slotIndex,
        itemLink = itemLink,

        quality = GetBagItemQuality(
            bagId,
            slotIndex
        ),

        traitType =
            GetItemLinkTraitType(itemLink),

        equipType =
            GetItemLinkEquipType(itemLink),

        unresearched =
            CanItemLinkBeTraitResearched(
                itemLink
            ),
    }
end

local function GetJewelryResearchKey(
    candidate
)
    return tostring(candidate.equipType)
        .. ":"
        .. tostring(candidate.traitType)
end

local function RemoveLowestResearchJewelry(
    candidates,
    profile
)
    if profile.researchMode
        ~= "keep_lowest_unresearched"
    then
        return candidates
    end

    local lowestItemByTrait = {}

    -- Знаходимо предмет найнижчої якості
    -- для кожного невивченого трейту.
    for _, candidate in ipairs(candidates) do
        if candidate.unresearched then
            local key =
                GetJewelryResearchKey(
                    candidate
                )

            local current =
                lowestItemByTrait[key]

            if not current
                or candidate.quality
                < current.quality
            then
                lowestItemByTrait[key] =
                    candidate
            end
        end
    end

    local filteredCandidates = {}

    for _, candidate in ipairs(candidates) do
        local shouldKeepForResearch =
            candidate.unresearched
            and lowestItemByTrait[
                GetJewelryResearchKey(candidate)
            ] == candidate

        -- Уже вивчені трейти розбираються.
        -- Для невивченого трейту залишається
        -- один предмет найнижчої якості.
        if not shouldKeepForResearch then
            table.insert(
                filteredCandidates,
                candidate
            )
        end
    end

    return filteredCandidates
end

local function ScanJewelryBag(
    bagId,
    profile,
    candidates
)
    local bagSize = GetBagSize(bagId)

    for slotIndex = 0, bagSize - 1 do
        if IsJewelryAllowed(
            profile,
            bagId,
            slotIndex
        ) then
            table.insert(
                candidates,
                CreateJewelryCandidate(
                    bagId,
                    slotIndex
                )
            )
        end
    end
end

local function CollectJewelryCandidates(
    allCandidates
)
    if not IsJewelryStation() then
        return
    end

    local profiles =
        owa.savedVariables
        and owa.savedVariables.deconstructProfiles

    local profile =
        profiles and profiles.jewelry

    if not profile or not profile.enabled then
        return
    end

    local jewelryCandidates = {}

    ScanJewelryBag(
        BAG_BACKPACK,
        profile,
        jewelryCandidates
    )

    if profile.fromBank then
        ScanJewelryBag(
            BAG_BANK,
            profile,
            jewelryCandidates
        )

        if IsESOPlusSubscriber() then
            ScanJewelryBag(
                BAG_SUBSCRIBER_BANK,
                profile,
                jewelryCandidates
            )
        end
    end

    jewelryCandidates =
        RemoveLowestResearchJewelry(
            jewelryCandidates,
            profile
        )

    for _, candidate in ipairs(
        jewelryCandidates
    ) do
        table.insert(
            allCandidates,
            candidate
        )
    end
end

deconstruct.RegisterCollector(
    "jewelry",
    CollectJewelryCandidates
)
