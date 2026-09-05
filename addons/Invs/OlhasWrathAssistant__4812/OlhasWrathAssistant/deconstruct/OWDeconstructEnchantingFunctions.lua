local owa = OWAssistant
local deconstruct = owa.Deconstruct

local function IsEnchantingStation()
    if deconstruct.IsUniversalStation() then
        return true
    end

    return deconstruct.currentCraftingType
        == CRAFTING_TYPE_ENCHANTING
end

local function IsGlyph(itemLink)
    local itemType =
        GetItemLinkItemType(itemLink)

    return itemType == ITEMTYPE_GLYPH_ARMOR
        or itemType == ITEMTYPE_GLYPH_JEWELRY
        or itemType == ITEMTYPE_GLYPH_WEAPON
end

local function CanExtractGlyph(
    bagId,
    slotIndex
)
    return CanItemBeSmithingExtractedOrRefined(
        bagId,
        slotIndex,
        CRAFTING_TYPE_ENCHANTING
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

local function IsGlyphAllowed(
    profile,
    bagId,
    slotIndex
)
    local itemLink =
        GetItemLink(
            bagId,
            slotIndex
        )

    if not itemLink or itemLink == "" then
        return false
    end

    if not IsGlyph(itemLink) then
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

    if not CanExtractGlyph(
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

    -- Некрафчені гліфи дозволені завжди.
    -- Скрафчені дозволяються лише
    -- відповідним чекбоксом.
    if IsItemLinkCrafted(itemLink)
        and not profile.crafted
    then
        return false
    end

    return true
end

local function CreateGlyphCandidate(
    bagId,
    slotIndex
)
    return {
        bagId = bagId,
        slotIndex = slotIndex,

        itemLink = GetItemLink(
            bagId,
            slotIndex,
            LINK_STYLE_BRACKETS
        ),

        quality = GetBagItemQuality(
            bagId,
            slotIndex
        ),

        craftingType =
            CRAFTING_TYPE_ENCHANTING,
    }
end

local function ScanGlyphBag(
    bagId,
    profile,
    candidates
)
    local bagSize = GetBagSize(bagId)

    for slotIndex = 0, bagSize - 1 do
        if IsGlyphAllowed(
            profile,
            bagId,
            slotIndex
        ) then
            table.insert(
                candidates,
                CreateGlyphCandidate(
                    bagId,
                    slotIndex
                )
            )
        end
    end
end

local function CollectEnchantingCandidates(
    allCandidates
)
    if not IsEnchantingStation() then
        return
    end

    local profiles =
        owa.savedVariables
        and owa.savedVariables.deconstructProfiles

    local profile =
        profiles and profiles.enchanting

    if not profile
        or not profile.enabled
    then
        return
    end

    local glyphCandidates = {}

    ScanGlyphBag(
        BAG_BACKPACK,
        profile,
        glyphCandidates
    )

    if profile.fromBank then
        ScanGlyphBag(
            BAG_BANK,
            profile,
            glyphCandidates
        )

        if IsESOPlusSubscriber() then
            ScanGlyphBag(
                BAG_SUBSCRIBER_BANK,
                profile,
                glyphCandidates
            )
        end
    end

    for _, candidate in ipairs(
        glyphCandidates
    ) do
        table.insert(
            allCandidates,
            candidate
        )
    end
end

deconstruct.RegisterCollector(
    "enchanting",
    CollectEnchantingCandidates
)
