-- Transmute Set Crafter — Trait / Quality / Enchant dropdowns
--
-- Four ZO_ComboBox-backed pickers shown beneath the queue list:
--   • Trait + Quality (left row): the reconstruction target settings.
--   • Enchant + Enchant-quality (right row): planning note for the glyph
--     that will be applied later at the Enchanting Station (LLC).
--
-- The current picks live on the shared TSC._UI table so other modules
-- (UI.lua add/edit flow) can read them.

local TSC = TransmuteSetCrafter
local UI  = TSC._UI

-- ComboBox object handles, populated by SetupDropdowns().
local traitComboBox, qualityComboBox, enchantComboBox, enchantQualityComboBox

-- ── Enchantment options by trait category ─────────────────
-- Curated lists of common enchantment glyphs. Displayed in the queue as a
-- planning note only; the reconstruction API doesn't apply enchantments.

local ENCHANTMENTS_WEAPON = {
    "Absorb Health",
    "Absorb Magicka",
    "Absorb Stamina",
    "Crushing",
    "Decrease Health",
    "Flame",
    "Foulness (Disease)",
    "Frost",
    "Hardening",
    "Poison",
    "Prismatic Onslaught",
    "Shock",
    "Weakening",
    "Weapon Damage",
}

local ENCHANTMENTS_ARMOR = {
    "Health",
    "Magicka",
    "Prismatic Defense",
    "Stamina",
}

local ENCHANTMENTS_JEWELRY = {
    "Bashing",
    "Decrease Physical Harm",
    "Decrease Spell Harm",
    "Disease Resist",
    "Flame Resist",
    "Frost Resist",
    "Health Recovery",
    "Increase Weapon Damage",
    "Magicka Recovery",
    "Poison Resist",
    "Potion Boost",
    "Potion Speed",
    "Prismatic Recovery",
    "Reduce Feat Cost",
    "Reduce Magicka Cost",
    "Reduce Spell Cost",
    "Shielding",
    "Shock Resist",
    "Spell Damage",
    "Stamina Recovery",
}

local function GetEnchantmentsForCategory(category)
    if     category == ITEM_TRAIT_TYPE_CATEGORY_WEAPON  then return ENCHANTMENTS_WEAPON
    elseif category == ITEM_TRAIT_TYPE_CATEGORY_ARMOR   then return ENCHANTMENTS_ARMOR
    elseif category == ITEM_TRAIT_TYPE_CATEGORY_JEWELRY then return ENCHANTMENTS_JEWELRY
    end
    return {}
end

-- ── Trait dropdown ─────────────────────────────────────────

function TSC.PopulateTraitDropdown(itemData, preselectTrait)
    if not traitComboBox then return end
    traitComboBox:ClearItems()
    UI.selectedTrait = nil

    local prompt = traitComboBox:CreateItemEntry(
                       GetString(SI_TSC_SELECT_TRAIT_PROMPT), function() UI.selectedTrait = nil end)
    traitComboBox:AddItem(prompt)
    traitComboBox:SelectFirstItem()

    local pieceId       = itemData.pieceId
    local pieceTraitCat = itemData.traitCategory
    local allTraits     = ZO_CraftingUtils_GetSmithingTraitItemInfo()

    local preselectEntry = nil
    for _, traitData in ipairs(allTraits) do
        -- Skip "no trait" — reconstruction always requires a real trait pick.
        if traitData.type ~= ITEM_TRAIT_TYPE_NONE
           and pieceTraitCat == GetItemTraitTypeCategory(traitData.type) then
            local known = IsTraitKnownForItem(pieceId, traitData.type)
            local label = GetString("SI_ITEMTRAITTYPE", traitData.type)
            if not known then
                label = label .. GetString(SI_TSC_TRAIT_NOT_RESEARCHED)
            end
            local capturedTrait = traitData.type
            local entry = traitComboBox:CreateItemEntry(label, function()
                UI.selectedTrait = capturedTrait
                TSC.UpdateTransmuteButton()
            end)
            traitComboBox:AddItem(entry)
            if preselectTrait and traitData.type == preselectTrait then
                preselectEntry = entry
            end
        end
    end

    if preselectEntry then
        traitComboBox:SelectItem(preselectEntry)
        UI.selectedTrait = preselectTrait
    end
end

-- ── Quality dropdown ───────────────────────────────────────

function TSC.PopulateQualityDropdown(preselectQuality)
    if not qualityComboBox then return end
    qualityComboBox:ClearItems()
    local target = preselectQuality or ITEM_FUNCTIONAL_QUALITY_ARTIFACT
    UI.selectedQuality = target

    local targetEntry = nil
    for quality = ITEM_FUNCTIONAL_QUALITY_NORMAL, ITEM_FUNCTIONAL_QUALITY_LEGENDARY do
        local label           = GetString("SI_ITEMQUALITY", quality)
        local capturedQuality = quality
        local entry = qualityComboBox:CreateItemEntry(label, function()
            UI.selectedQuality = capturedQuality
            TSC.UpdateTransmuteButton()
        end)
        qualityComboBox:AddItem(entry)
        if quality == target then
            targetEntry = entry
        end
    end

    if targetEntry then
        qualityComboBox:SelectItem(targetEntry)
    end
end

-- ── Enchantment quality dropdown ──────────────────────────

function TSC.PopulateEnchantQualityDropdown(preselectQuality)
    if not enchantQualityComboBox then return end
    enchantQualityComboBox:ClearItems()
    local target = preselectQuality or ITEM_FUNCTIONAL_QUALITY_LEGENDARY
    UI.selectedEnchantQuality = target

    local targetEntry = nil
    for quality = ITEM_FUNCTIONAL_QUALITY_NORMAL, ITEM_FUNCTIONAL_QUALITY_LEGENDARY do
        local label    = GetString("SI_ITEMQUALITY", quality)
        local captured = quality
        local entry    = enchantQualityComboBox:CreateItemEntry(label, function()
            UI.selectedEnchantQuality = captured
        end)
        enchantQualityComboBox:AddItem(entry)
        if quality == target then
            targetEntry = entry
        end
    end

    if targetEntry then
        enchantQualityComboBox:SelectItem(targetEntry)
    end
end

-- ── Enchantment dropdown ──────────────────────────────────

function TSC.PopulateEnchantDropdown(itemData, preselectName)
    if not enchantComboBox then return end
    enchantComboBox:ClearItems()
    UI.selectedEnchant = ""

    local noneEntry = enchantComboBox:CreateItemEntry(GetString(SI_TSC_LABEL_NONE), function()
        UI.selectedEnchant = ""
    end)
    enchantComboBox:AddItem(noneEntry)
    enchantComboBox:SelectFirstItem()

    local preselectEntry = nil
    for _, name in ipairs(GetEnchantmentsForCategory(itemData.traitCategory)) do
        local captured = name
        local entry = enchantComboBox:CreateItemEntry(name, function()
            UI.selectedEnchant = captured
        end)
        enchantComboBox:AddItem(entry)
        if preselectName and preselectName ~= "" and name == preselectName then
            preselectEntry = entry
        end
    end

    if preselectEntry then
        enchantComboBox:SelectItem(preselectEntry)
        UI.selectedEnchant = preselectName
    end
end

-- ── Lifecycle ─────────────────────────────────────────────

-- Called once from UI.lua SetupUI: bind to the four XML ZO_ComboBox containers.
function TSC.SetupDropdowns()
    traitComboBox = ZO_ComboBox_ObjectFromContainer(TransmuteSetCrafterWindowTraitDropdown)
    traitComboBox:SetSortsItems(false)

    qualityComboBox = ZO_ComboBox_ObjectFromContainer(TransmuteSetCrafterWindowQualityDropdown)
    qualityComboBox:SetSortsItems(false)

    enchantComboBox = ZO_ComboBox_ObjectFromContainer(TransmuteSetCrafterWindowEnchantDropdown)
    enchantComboBox:SetSortsItems(false)

    enchantQualityComboBox = ZO_ComboBox_ObjectFromContainer(TransmuteSetCrafterWindowEnchantQualityDropdown)
    enchantQualityComboBox:SetSortsItems(false)
end

-- Called from UI.lua ClearPieceSelection to wipe all four dropdowns at once.
function TSC.ClearAllDropdowns()
    if traitComboBox          then traitComboBox:ClearItems()          end
    if qualityComboBox        then qualityComboBox:ClearItems()        end
    if enchantComboBox        then enchantComboBox:ClearItems()        end
    if enchantQualityComboBox then enchantQualityComboBox:ClearItems() end
end
