local LAM2 = LibAddonMenu2

LZD_ALWAYS    = 1
LZD_NEVER     = 2
LZD_LEVELLING = 3
LZD_SMART     = 3

local LZD = {
    name = "LazyDecon",
    version = "0.6.1",

    researchSaved = {},

    defaults = {
        general = {
            spam = false,
            researchable = LZD_SMART,
        },
        glyphs = {
            when = LZD_ALWAYS,
            crafted = true,
            extraction = 0,
            minQuality = ITEM_FUNCTIONAL_QUALITY_NORMAL,
            maxQuality = ITEM_FUNCTIONAL_QUALITY_ARTIFACT,
        },
        equip = {
            when = LZD_ALWAYS,
            extraction = 0,
            price = 1000,
            trashMinQuality = ITEM_FUNCTIONAL_QUALITY_NORMAL,
            trashMaxQuality = ITEM_FUNCTIONAL_QUALITY_ARTIFACT,
            exemplary = false,
            intricates = LZD_LEVELLING,
            ornates = false,
            sets = false,
            setMinQuality = ITEM_FUNCTIONAL_QUALITY_NORMAL,
            setMaxQuality = ITEM_FUNCTIONAL_QUALITY_ARTIFACT,
            setTraits = {
                [ARMORTYPE_HEAVY] = {
                    [ITEM_TRAIT_TYPE_ARMOR_STURDY] = false,
                    [ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE] = false,
                    [ITEM_TRAIT_TYPE_ARMOR_REINFORCED] = false,
                    [ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED] = false,
                    [ITEM_TRAIT_TYPE_ARMOR_TRAINING] = true,
                    [ITEM_TRAIT_TYPE_ARMOR_INFUSED] = false,
                    [ITEM_TRAIT_TYPE_ARMOR_PROSPEROUS] = true, -- Invigorating
                    [ITEM_TRAIT_TYPE_ARMOR_DIVINES] = false,
                    [ITEM_TRAIT_TYPE_ARMOR_NIRNHONED] = false,
                },
                [ARMORTYPE_MEDIUM] = {
                    [ITEM_TRAIT_TYPE_ARMOR_STURDY] = true,
                    [ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE] = false,
                    [ITEM_TRAIT_TYPE_ARMOR_REINFORCED] = false,
                    [ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED] = false,
                    [ITEM_TRAIT_TYPE_ARMOR_TRAINING] = true,
                    [ITEM_TRAIT_TYPE_ARMOR_INFUSED] = false,
                    [ITEM_TRAIT_TYPE_ARMOR_PROSPEROUS] = true, -- Invigorating
                    [ITEM_TRAIT_TYPE_ARMOR_DIVINES] = false,
                    [ITEM_TRAIT_TYPE_ARMOR_NIRNHONED] = false,
                },
                [ARMORTYPE_LIGHT] = {
                    [ITEM_TRAIT_TYPE_ARMOR_STURDY] = true,
                    [ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE] = false,
                    [ITEM_TRAIT_TYPE_ARMOR_REINFORCED] = false,
                    [ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED] = false,
                    [ITEM_TRAIT_TYPE_ARMOR_TRAINING] = true,
                    [ITEM_TRAIT_TYPE_ARMOR_INFUSED] = false,
                    [ITEM_TRAIT_TYPE_ARMOR_PROSPEROUS] = true, -- Invigorating
                    [ITEM_TRAIT_TYPE_ARMOR_DIVINES] = false,
                    [ITEM_TRAIT_TYPE_ARMOR_NIRNHONED] = false,
                },
                [ARMORTYPE_NONE] = {
                    [ITEM_TRAIT_TYPE_WEAPON_POWERED] = false,
                    [ITEM_TRAIT_TYPE_WEAPON_CHARGED] = false,
                    [ITEM_TRAIT_TYPE_WEAPON_PRECISE] = false,
                    [ITEM_TRAIT_TYPE_WEAPON_INFUSED] = false,
                    [ITEM_TRAIT_TYPE_WEAPON_DEFENDING] = true,
                    [ITEM_TRAIT_TYPE_WEAPON_TRAINING] = true,
                    [ITEM_TRAIT_TYPE_WEAPON_SHARPENED] = true,
                    [ITEM_TRAIT_TYPE_WEAPON_DECISIVE] = true,
                    [ITEM_TRAIT_TYPE_WEAPON_NIRNHONED] = false,
                },
            },
        },
        jewelry = {
            when = LZD_ALWAYS,
            extraction = 3,
            price = 2500,
            trashMinQuality = ITEM_FUNCTIONAL_QUALITY_NORMAL,
            trashMaxQuality = ITEM_FUNCTIONAL_QUALITY_ARTIFACT,
            exemplary = false,
            intricates = LZD_LEVELLING,
            ornates = false,
            sets = false,
            setMinQuality = ITEM_FUNCTIONAL_QUALITY_NORMAL,
            setMaxQuality = ITEM_FUNCTIONAL_QUALITY_ARCANE,
            setTraits = {
                [ARMORTYPE_NONE] = {
                    [ITEM_TRAIT_TYPE_JEWELRY_ARCANE] = true,
                    [ITEM_TRAIT_TYPE_JEWELRY_HEALTHY] = true,
                    [ITEM_TRAIT_TYPE_JEWELRY_ROBUST] = true,
                    [ITEM_TRAIT_TYPE_JEWELRY_TRIUNE] = false,
                    [ITEM_TRAIT_TYPE_JEWELRY_INFUSED] = false,
                    [ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE] = false,
                    [ITEM_TRAIT_TYPE_JEWELRY_SWIFT] = false,
                    [ITEM_TRAIT_TYPE_JEWELRY_HARMONY] = false,
                    [ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY] = false,
                },
            },
        },
    },
}

-----------------------------------------------------------------------------
-- Utilities
-----------------------------------------------------------------------------

local function LZD_IsTradeSkillFullyLevelled(tradeskill)
    local skillData = SKILLS_DATA_MANAGER:GetCraftingSkillLineData(tradeskill)
    local _, skillLineIndex = skillData:GetIndices()
    local lastRankXP, nextRankXP, curXP = GetSkillLineXPInfo(SKILL_TYPE_TRADESKILL, skillLineIndex)
    return nextRankXP == curXP
end

local function LZD_ExtractionPassiveRank(tradeskill)
    local passiveIndex = {
        [CRAFTING_TYPE_BLACKSMITHING] = 4, -- Metal Extraction
        [CRAFTING_TYPE_CLOTHIER] = 4, -- Unraveling
        [CRAFTING_TYPE_WOODWORKING] = 4, -- Wood Extraction
        [CRAFTING_TYPE_ENCHANTING] = 5, -- Runestone Extraction
        [CRAFTING_TYPE_JEWELRYCRAFTING] = 3, -- Jewelry Extraction
    }
    local skillLine = SKILLS_DATA_MANAGER:GetCraftingSkillLineData(tradeskill)
    local skillData = skillLine:GetSkillDataByIndex(passiveIndex[tradeskill])
    -- Can print skillData:GetRankData(1).name to verify indices
    assert(skillData:IsPassive())
    assert(skillData.numRanks == 3)
    return skillData:GetNumPointsAllocated()
end

-----------------------------------------------------------------------------
-- Settings UI Panel
-----------------------------------------------------------------------------

local function LZD_CreateSettingsPanel()
    local panelData = {
        type = "panel",
        name = "Lazy Deconstructor",
        displayName = "Lazy Deconstructor",
        author = "StorybookTerror",
        version = LZD.version,
        registerForDefaults = true,
        website = "http://github.com/storybookterror/lazydecon"
    }
    LAM2:RegisterAddonPanel(LZD.name, panelData)

    local qualityNames = {}
    local qualityEnums = {}
    for i = 0, ITEM_FUNCTIONAL_QUALITY_LEGENDARY do
        local color = GetItemQualityColor(i)
        local name = color:Colorize(GetString("SI_ITEMQUALITY", i))
        qualityNames[i] = name
        qualityEnums[name] = i
    end

    local function qualityMenu(name, category, option)
        return {
            type = "dropdown",
            name = name,
            choices = qualityNames,
            default = qualityNames[LZD.defaults[category][option]],
            getFunc = function() return qualityNames[LZD.vars[category][option]] end,
            setFunc = function(value) LZD.vars[category][option] = qualityEnums[value] end,
        }
    end

    local function dropdown(name, choices, category, option, bias, tooltip)
        bias = bias or 0
        return {
            type = "dropdown",
            name = name,
            tooltip = tooltip,
            choices = choices,
            default = LZD.defaults[category][option],
            getFunc = function() return choices[LZD.vars[category][option] + bias] end,
            setFunc = function(value) for i, s in ipairs(choices) do if value == s then LZD.vars[category][option] = i - bias break end end end,
        }
    end

    local function whenToDeconMenu(name, category, option)
        local choices = {
            [LZD_ALWAYS]    = GetString(SI_YES),
            [LZD_NEVER]     = GetString(SI_NO),
            [LZD_LEVELLING] = "Only if Levelling",
        }
        return dropdown(name, choices, category, option)
    end

    local function rankMenu(category, option)
        local choices = { "Any", "At least rank 1", "At least rank 2", "Max" }
        return dropdown("Only with Extraction Passive Rank", choices,
                        category, option, 1,
                        "Intricates used when levelling ignore this setting.")
    end

    local function researchMenu()
        local choices = {
            [LZD_ALWAYS] = GetString(SI_YES),
            [LZD_NEVER]  = GetString(SI_NO),
            [LZD_LEVELLING] = "Smart",
        }
        return dropdown("Include Researchable Items", choices, "general", "researchable", 0,
                        "'Smart' retains only as many items as you can simultaneously research.  Prefers saving lower quality, non-set, more useful trait, less expensive items.")
    end

    local function checkbox(name, category, option, tooltip)
        return {
            type = "checkbox",
            name = name,
            tooltip = tooltip,
            default = LZD.defaults[category][option],
            getFunc = function() return LZD.vars[category][option] end,
            setFunc = function(value) LZD.vars[category][option] = value end,
        }
    end

    local function craftSubMenu(category)
        return {
            whenToDeconMenu(GetString("SI_TRADESKILLTYPE", CRAFTING_TYPE_BLACKSMITHING), category, CRAFTING_TYPE_BLACKSMITHING),
            whenToDeconMenu(GetString("SI_TRADESKILLTYPE", CRAFTING_TYPE_CLOTHIER), category, CRAFTING_TYPE_CLOTHIER),
            whenToDeconMenu(GetString("SI_TRADESKILLTYPE", CRAFTING_TYPE_WOODWORKING), category, CRAFTING_TYPE_WOODWORKING),
            whenToDeconMenu(GetString("SI_TRADESKILLTYPE", CRAFTING_TYPE_JEWELRYCRAFTING), category, CRAFTING_TYPE_JEWELRYCRAFTING),
        }
    end

    local function traitOption(category, armorType, trait)
        local name = GetString("SI_ITEMTRAITTYPE", trait)
        return {
            type = "checkbox",
            name = name,
            default = LZD.defaults[category].setTraits[armorType][trait],
            getFunc = function() return LZD.vars[category].setTraits[armorType][trait] end,
            setFunc = function(value) LZD.vars[category].setTraits[armorType][trait] = value end,
        }
    end

    local function armorTraitOptions(armorType)
        local armorWeightName = GetString("SI_ARMORTYPE", armorType)
        return {
            type = "submenu",

            name = "Set Traits: " .. armorWeightName .. " Armor",
            controls =
            {
                {
                    type = "description",
                    text = "Only include " .. armorWeightName .. " set armor with these traits:",
                },
                traitOption("equip", armorType, ITEM_TRAIT_TYPE_ARMOR_STURDY),
                traitOption("equip", armorType, ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE),
                traitOption("equip", armorType, ITEM_TRAIT_TYPE_ARMOR_REINFORCED),
                traitOption("equip", armorType, ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED),
                traitOption("equip", armorType, ITEM_TRAIT_TYPE_ARMOR_TRAINING),
                traitOption("equip", armorType, ITEM_TRAIT_TYPE_ARMOR_INFUSED),
                traitOption("equip", armorType, ITEM_TRAIT_TYPE_ARMOR_PROSPEROUS),
                traitOption("equip", armorType, ITEM_TRAIT_TYPE_ARMOR_DIVINES),
                traitOption("equip", armorType, ITEM_TRAIT_TYPE_ARMOR_NIRNHONED),
            },
        }
    end

    local function priceMenu(category)
        if LibPrice then
            return {
                type = "slider",
                name = "Exclude if price is at least...",
                tooltip = "This uses LibPrice to estimate the value of the item, which sources data from Master Merchant, Arkadius' Trade Tools, Tamriel Trade Centre, and more.",
                min = 50,
                max = 5000,
                step = 50,
                clampInput = false,
                default = LZD.defaults[category].price,
                getFunc = function() return LZD.vars[category].price end,
                setFunc = function(value) LZD.vars[category].price = math.max(0, value) end,
            }
        else
            return {
                type = "description",
                text = "(Install LibPrice to support price-based exclusions.)",
                tooltip = "Lazy Deconstructor can exclude items based on the estimated value of the items if you install LibPrice and trading add-ons.",
            }
        end
    end

    local options = {
        checkbox("Print selected items to Chat", "general", "spam",
                 "Print \"LazyDecon added [Item]\" in chatbox for each selected item so you can sanity check it.  (Currently may double post, this is a known issue.)"),
        researchMenu(),
        {
            type = "header",
            name = "Glyphs",
        },
        whenToDeconMenu("Include Glyphs", "glyphs", "when"),
        checkbox("Crafted For Levelling", "glyphs", "crafted",
                 "Glyphs crafted by another character will be marked for deconstruction if the current character isn't fully levelled in enchanting."),
        rankMenu("glyphs", "extraction"),
        qualityMenu("Minimum Quality", "glyphs", "minQuality"),
        qualityMenu("Maximum Quality", "glyphs", "maxQuality"),

        {
            type = "header",
            name = "Weapons & Armor",
        },
        whenToDeconMenu("Include Weapons and Armor", "equip", "when"),
        rankMenu("equip", "extraction"),
        priceMenu("equip"),
        qualityMenu("Basic Items: Minimum Quality", "equip", "trashMinQuality"),
        qualityMenu("Basic Items: Maximum Quality", "equip", "trashMaxQuality"),
        checkbox("Include Exemplary Items", "equip", "exemplary", nil),
        whenToDeconMenu("Include Intricates", "equip", "intricates"),
        checkbox("Include Ornates", "equip", "ornates", nil),
        checkbox("Include Easily Reconstructed Sets", "equip", "sets",
                 "Set items with a reconstruction cost of 50 transmutation crystals or less will be marked for deconstruction."),
        qualityMenu("Set Items: Minimum Quality", "equip", "setMinQuality"),
        qualityMenu("Set Items: Maximum Quality", "equip", "setMaxQuality"),
        armorTraitOptions(ARMORTYPE_HEAVY),
        armorTraitOptions(ARMORTYPE_MEDIUM),
        armorTraitOptions(ARMORTYPE_LIGHT),
        {
            type = "submenu",

            name = "Set Traits: Weapons",
            controls =
            {
                {
                    type = "description",
                    text = "Only include set weapons with these traits:",
                },
                traitOption("equip", ARMORTYPE_NONE, ITEM_TRAIT_TYPE_WEAPON_POWERED),
                traitOption("equip", ARMORTYPE_NONE, ITEM_TRAIT_TYPE_WEAPON_CHARGED),
                traitOption("equip", ARMORTYPE_NONE, ITEM_TRAIT_TYPE_WEAPON_PRECISE),
                traitOption("equip", ARMORTYPE_NONE, ITEM_TRAIT_TYPE_WEAPON_INFUSED),
                traitOption("equip", ARMORTYPE_NONE, ITEM_TRAIT_TYPE_WEAPON_DEFENDING),
                traitOption("equip", ARMORTYPE_NONE, ITEM_TRAIT_TYPE_WEAPON_TRAINING),
                traitOption("equip", ARMORTYPE_NONE, ITEM_TRAIT_TYPE_WEAPON_SHARPENED),
                traitOption("equip", ARMORTYPE_NONE, ITEM_TRAIT_TYPE_WEAPON_DECISIVE),
                traitOption("equip", ARMORTYPE_NONE, ITEM_TRAIT_TYPE_WEAPON_NIRNHONED),
            }
        },
        {
            type = "header",
            name = "Jewelry",
        },
        whenToDeconMenu("Include Jewelry", "jewelry", "when"),
        rankMenu("jewelry", "extraction"),
        priceMenu("jewelry"),
        qualityMenu("Basic Jewelry: Minimum Quality", "jewelry", "trashMinQuality"),
        qualityMenu("Basic Jewelry: Maximum Quality", "jewelry", "trashMaxQuality"),
        checkbox("Include Exemplary Items", "jewelry", "exemplary", nil),
        whenToDeconMenu("Include Intricates", "jewelry", "intricates"),
        checkbox("Include Ornates", "jewelry", "ornates", nil),
        checkbox("Include Easily Reconstructed Sets", "jewelry", "sets",
                 "Set items with a reconstruction cost of 50 transmutation crystals or less will be marked for deconstruction."),
        qualityMenu("Set Jewelry: Minimum Quality", "jewelry", "setMinQuality"),
        qualityMenu("Set Jewelry: Maximum Quality", "jewelry", "setMaxQuality"),
        {
            type = "submenu",

            name = "Set Traits: Jewelry",
            controls =
            {
                {
                    type = "description",
                    text = "Only include set jewelry with these traits:",
                },
                traitOption("jewelry", ARMORTYPE_NONE, ITEM_TRAIT_TYPE_JEWELRY_ARCANE),
                traitOption("jewelry", ARMORTYPE_NONE, ITEM_TRAIT_TYPE_JEWELRY_HEALTHY),
                traitOption("jewelry", ARMORTYPE_NONE, ITEM_TRAIT_TYPE_JEWELRY_ROBUST),
                traitOption("jewelry", ARMORTYPE_NONE, ITEM_TRAIT_TYPE_JEWELRY_TRIUNE),
                traitOption("jewelry", ARMORTYPE_NONE, ITEM_TRAIT_TYPE_JEWELRY_INFUSED),
                traitOption("jewelry", ARMORTYPE_NONE, ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE),
                traitOption("jewelry", ARMORTYPE_NONE, ITEM_TRAIT_TYPE_JEWELRY_SWIFT),
                traitOption("jewelry", ARMORTYPE_NONE, ITEM_TRAIT_TYPE_JEWELRY_HARMONY),
                traitOption("jewelry", ARMORTYPE_NONE, ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY),
            }
        },
    }

    LAM2:RegisterOptionControls(LZD.name, options)
end

-----------------------------------------------------------------------------
-- Utility Functions
-----------------------------------------------------------------------------

-- Make an Item object for easier storing/passing
local function LZD_Item(bagId, slotIndex, link)
    return {["bag"] = bagId, ["slot"] = slotIndex, ["link"] = link}
end


-----------------------------------------------------------------------------
-- What to Deconstruct
-----------------------------------------------------------------------------
local function LZD_SaveForCrows(link)
    -- Quest 6024, "Glitter and Gleam", requires you to collect 3 pieces of
    -- ornate armor for the Bursar of Tributes (Blackfeather Court) in the
    -- Brass Fortress (Clockwork City).
    return GetItemLinkArmorType(link) ~= ARMORTYPE_NONE and HasQuest(6024)
end

local function LZD_IsExemplary(bagId, slotIndex, link)
    local tradeskill = GetItemLinkCraftingSkillType(link)
    local quality = GetItemLinkQuality(link)
    return quality < ITEM_FUNCTIONAL_QUALITY_LEGENDARY and
           not CanItemBeSmithingImproved(bagId, slotIndex, tradeskill)
end

local function LZD_ShouldDeconCraft(tristate, tradeskill)
    return tristate == LZD_ALWAYS or
           (tristate == LZD_LEVELLING and
            not LZD_IsTradeSkillFullyLevelled(tradeskill))
end

local function LZD_ShouldDeconEquipment(bagId, slotIndex, link, category)
    local isSet, setName, _, _, _, setId = GetItemLinkSetInfo(link, false)
    local researchable = CanItemLinkBeTraitResearched(link)
    local quality = GetItemLinkQuality(link)
    local craft = GetItemLinkCraftingSkillType(link)
    local traitInfo = GetItemTraitInformationFromItemLink(link)
    local traitType = GetItemLinkTraitType(link)

    if IsItemLinkCrafted(link) then
        return false
    end

    if not LZD_ShouldDeconCraft(LZD.vars[category].when, craft) then
        return false
    end

    if LibPrice then
       local price = LibPrice.ItemLinkToPriceGold(link)
       -- d("LazyDecon estimated " .. link .. " to be worth " .. tostring(price) .. " gold")
       if price and price >= LZD.vars[category].price then
           return false
       end
    end

    if LZD_ExtractionPassiveRank(craft) < LZD.vars[category].extraction and
       not (traitInfo == ITEM_TRAIT_INFORMATION_INTRICATE and
            LZD.vars[category].intricates == LZD_LEVELLING) then
        -- We skip the extraction skill check when levelling with intricates
        return false
    end

    if traitInfo == ITEM_TRAIT_INFORMATION_INTRICATE then
       return LZD_ShouldDeconCraft(LZD.vars[category].intricates, craft)
    end

    if traitInfo == ITEM_TRAIT_INFORMATION_ORNATE and
       (not LZD.vars[category].ornates or LZD_SaveForCrows(link)) then
       return false
    end

    if researchable and LZD.vars.general.researchable == LZD_NEVER then
        return false
    end

    if LZD_IsExemplary(bagId, slotIndex, link) and not LZD.vars[category].exemplary then
        return false
    end

    if not isSet then
        return quality >= LZD.vars[category].trashMinQuality and
               quality <= LZD.vars[category].trashMaxQuality
    end

    local reconCost =
       GetItemReconstructionCurrencyOptionCost(setId, CURT_CHAOTIC_CREATIA)

    -- Exclude craftable set items.  Although we already exclude crafted
    -- items, there are quest reward items like Spellbreaker's Staff which
    -- are non-crafted items which are part of a craftable set.  Some of
    -- those require a lot of trait research to craft, so we skip them.
    if not reconCost then
        return false
    end

    local armorType = GetItemLinkArmorType(link)

    return LZD.vars[category].sets and
           LZD.vars[category].setTraits[armorType][traitType] and
           quality >= LZD.vars[category].setMinQuality and
           quality <= LZD.vars[category].setMaxQuality and
           reconCost <= 50
end

local function LZD_IsSelfCrafted(bagId, slotIndex)
    return GetItemCreatorName(bagId, slotIndex) == GetUnitName("player")
end

local function LZD_ShouldDeconGlyphs(bagId, slotIndex, link)
    local quality = GetItemLinkQuality(link)

    if IsItemLinkCrafted(link) then
        -- Players frequently craft glyphs on one character and share them
        -- with another character or friend to help level their enchanting.
        -- So we may want to allow this in some cases.
        if not LZD.vars.glyphs.crafted then
            return false
        end

        -- We don't want to deconstruct any items crafted by the current
        -- character.  The XP returns for that are poor, and these are
        -- more likely glyphs meant for actual use, or for writ quests.
        if LZD_IsSelfCrafted(bagId, slotIndex) then
            return false
        end

        -- If we aren't levelling crafting, deconstruction isn't desirable
        local tradeskill = GetItemLinkCraftingSkillType(link)
        if LZD_IsTradeSkillFullyLevelled(tradeskill) then
            return false
        end

        -- Allow this crafted glyph, assuming it meets the usual conditions
    end

    return quality >= LZD.vars.glyphs.minQuality and
           quality <= LZD.vars.glyphs.maxQuality and
           LZD_ShouldDeconCraft(LZD.vars.glyphs.when, CRAFTING_TYPE_ENCHANTING)
end

local function LZD_IsGlyph(link)
    local itemType = GetItemLinkItemType(link)
    return itemType == ITEMTYPE_GLYPH_ARMOR or
           itemType == ITEMTYPE_GLYPH_JEWELRY or
           itemType == ITEMTYPE_GLYPH_WEAPON
end

local function LZD_ShouldDecon(bagId, slotIndex)
    if IsItemBoPAndTradeable(bagId, slotIndex) and GetGroupSize() > 0 then
        return false
    end

    -- FCOItemSaver support (thanks to Baertram!)
    if FCOIS and FCOIS.IsDeconstructionLocked(bagId, slotIndex, nil) then
        return false
    end

    if IsItemInArmory(bagId, slotIndex) then
        return false
    end

    if IsItemPlayerLocked(bagId, slotIndex) then
        return false
    end

    local link = GetItemLink(bagId, slotIndex, LINK_STYLE_BRACKETS)

    -- Exclude unique items like "Grievous Leeching Ward"
    if IsItemLinkUnique(link) then
        return false
    end

    local equipType = GetItemLinkEquipType(link)

    if equipType == EQUIP_TYPE_RING or equipType == EQUIP_TYPE_NECK then
        return LZD_ShouldDeconEquipment(bagId, slotIndex, link, "jewelry")
    elseif equipType ~= EQUIP_TYPE_INVALID then
        return LZD_ShouldDeconEquipment(bagId, slotIndex, link, "equip")
    elseif LZD_IsGlyph(link) then
        return LZD_ShouldDeconGlyphs(bagId, slotIndex, link)
    end
end

-----------------------------------------------------------------------------
-- Research limit helpers
-----------------------------------------------------------------------------
local function LZD_ResetResearch()
    LZD.researchSaved[CRAFTING_TYPE_BLACKSMITHING] = {}
    LZD.researchSaved[CRAFTING_TYPE_CLOTHIER] = {}
    LZD.researchSaved[CRAFTING_TYPE_WOODWORKING] = {}
    LZD.researchSaved[CRAFTING_TYPE_ENCHANTING] = {}
    LZD.researchSaved[CRAFTING_TYPE_JEWELRYCRAFTING] = {}
end

-- Assign a score for how desirable an item is to deconstruct vs. keep
-- Higher values = better to decon / Lower values = better to research
local function LZD_ResearchScore(item)
    local link = item["link"]

    -- Prefer to deconstruct higher quality items and research lower ones
    local score = GetItemLinkQuality(link) * 1000000

    -- Prefer to deconstruct non-set items and save set ones
    if not GetItemLinkSetInfo(link, false) then
        score = score + 100000
    end

    -- Prefer to deconstruct invigorating (greatly), non-divines (slightly)
    local trait = GetItemLinkTraitType(link)
    if trait == ITEM_TRAIT_TYPE_ARMOR_PROSPEROUS then
        score = score + 90000
    elseif trait ~= ITEM_TRAIT_TYPE_ARMOR_DIVINES then
        score = score + 10000
    end

    -- Prefer to deconstruct lower value items
    if LibPrice then
        local price = LibPrice.ItemLinkToPriceGold(link)
        score = score + math.min(9999 - price, 0)
    end

    return score
end

local function LZD_AddItem(item)
    LZD.station:AddItemToCraft(item["bag"], item["slot"])
    if LZD.vars.general.spam then
        d("LazyDecon added " .. item["link"])
    end
end

-- Return true if item should be deconstructed
local function LZD_ShouldDeconResearchable(item)
    local craft = GetItemLinkCraftingSkillType(item["link"])
    local max = GetMaxSimultaneousSmithingResearch(craft)

    -- HACK: Ignore if item is already in the list (because our hook gets
    --       called twice for every item for some reason)
    for i, other in ipairs(LZD.researchSaved[craft]) do
        if item["bag"] == other["bag"] and item["slot"] == other["slot"] then
            return false
        end
    end

    --d(zo_strformat("Considering <<1>> item: <<2>>", GetString("SI_TRADESKILLTYPE", craft), item["link"]))

    local count = #LZD.researchSaved[craft]
    if count < max then
        -- We are still saving items for research.  Keep this one for now.
        --d(zo_strformat("Appending <<1>> item #<<2>>: <<3>>", GetString("SI_TRADESKILLTYPE", craft), count + 1, item["link"]))
        LZD.researchSaved[craft][count + 1] = item
        return false
    else
        -- Compare against the list of things currently saved for research
        score = LZD_ResearchScore(item)
        for i, other in ipairs(LZD.researchSaved[craft]) do
            --d(zo_strformat("<<1>> score <<2>> vs. <<3>> score <<4>>", item["link"], score, other["link"], LZD_ResearchScore(other)))
            -- If 'other' is more valuable to deconstruct...then add it
            -- instead and save this one.
            if LZD_ResearchScore(other) > score then
                --d(zo_strformat("Deconstructing <<1>> item #<<2>> <<3>> instead of <<4>>", GetString("SI_TRADESKILLTYPE", craft), i, other["link"], item["link"]))
                LZD_AddItem(other)
                LZD.researchSaved[craft][i] = item
                return false
            end
        end
    end
    --d(zo_strformat("Deconstructing <<1>> item <<2>>", GetString("SI_TRADESKILLTYPE", craft), item["link"]))
    return true
end

-----------------------------------------------------------------------------
-- Deconstruction Panel Hooks
-----------------------------------------------------------------------------
local function LZD_SelectItem(self, bagId, slotIndex, ...)
    local name = GetItemName(bagId, slotIndex)
    local link = GetItemLink(bagId, slotIndex, LINK_STYLE_BRACKETS)
    local item = LZD_Item(bagId, slotIndex, link)
    if LZD_ShouldDecon(bagId, slotIndex) and
       (LZD.vars.general.researchable ~= LZD_SMART or
        not CanItemLinkBeTraitResearched(link) or
        LZD_ShouldDeconResearchable(item)) then

        LZD_AddItem(item)

        -- Adding multiple items would trigger the "select an item" sound
        -- multiple times.  Disable the sound temporarily (after the first
        -- one) and re-enable it after we finish enumerating items.
        SOUNDS.SMITHING_ITEM_TO_EXTRACT_PLACED = SOUNDS.NONE
        SOUNDS.ENCHANTING_ARMOR_GLYPH_PLACED = SOUNDS.NONE
        SOUNDS.ENCHANTING_WEAPON_GLYPH_PLACED = SOUNDS.NONE
        SOUNDS.ENCHANTING_JEWELRY_GLYPH_PLACED = SOUNDS.NONE
    end
end

local function LZD_FixSound(...)
    -- Restore the original sound effects once now that we're done iterating
    SOUNDS.SMITHING_ITEM_TO_EXTRACT_PLACED = LZD.savedSmithingSound
    SOUNDS.ENCHANTING_ARMOR_GLYPH_PLACED = LZD.savedArmorGlyphSound
    SOUNDS.ENCHANTING_WEAPON_GLYPH_PLACED = LZD.savedWeaponGlyphSound
    SOUNDS.ENCHANTING_JEWELRY_GLYPH_PLACED = LZD.savedJewelryGlyphSound
end

-----------------------------------------------------------------------------
-- Event Handlers
-----------------------------------------------------------------------------
local function LZD_SwitchDeconScreen(eventCode, craftingType, sameStation, craftingMode)
    if ZO_Smithing_IsUniversalDeconstructionCraftingMode(craftingMode) then
        LZD.station = UNIVERSAL_DECONSTRUCTION
    elseif craftingType == CRAFTING_TYPE_ENCHANTING then
        LZD.station = ENCHANTING
    else
        LZD.station = SMITHING
    end

    LZD_ResetResearch()
end

------------------------------------------------------------------------------
-- Basic Slash Commands
------------------------------------------------------------------------------
local function SlashBT(text)
    for _, item in pairs(SHARED_INVENTORY:GetOrCreateBagCache(BAG_BACKPACK)) do
        if IsItemBoPAndTradeable(item.bagId, item.slotIndex) then
            BindItem(item.bagId, item.slotIndex)
        end
    end
end

-----------------------------------------------------------------------------
-- Add-on initialization
-----------------------------------------------------------------------------
local function LZD_RegisterHooks(inventory)
    SecurePostHook(inventory, "AddItemData", LZD_SelectItem)
    SecurePostHook(inventory, "EnumerateInventorySlotsAndAddToScrollData", LZD_FixSound)
    SecurePostHook(inventory, "GetIndividualInventorySlotsAndAddToScrollData", LZD_FixSound)
end

local function LZD_Initialize()
    LZD.vars = ZO_SavedVars:NewAccountWide("LazyDeconVars", 2, GetWorldName(), LZD.defaults)

    LZD.vars.equip.researchable = nil
    LZD.vars.jewelry.researchable = nil

    LZD.savedSmithingSound = SOUNDS.SMITHING_ITEM_TO_EXTRACT_PLACED
    LZD.savedArmorGlyphSound = SOUNDS.ENCHANTING_ARMOR_GLYPH_PLACED
    LZD.savedWeaponGlyphSound = SOUNDS.ENCHANTING_WEAPON_GLYPH_PLACED
    LZD.savedJewelryGlyphSound = SOUNDS.ENCHANTING_JEWELRY_GLYPH_PLACED
    LZD_RegisterHooks(UNIVERSAL_DECONSTRUCTION.deconstructionPanel.inventory)
    LZD_RegisterHooks(SMITHING.deconstructionPanel.inventory)
    LZD_RegisterHooks(ENCHANTING.inventory)
    EVENT_MANAGER:RegisterForEvent(LZD.name, EVENT_CRAFTING_STATION_INTERACT, LZD_SwitchDeconScreen)
    LZD_CreateSettingsPanel()

    SLASH_COMMANDS["/bt"] = SlashBT
end

-----------------------------------------------------------------------------
-- Add-on loading callback
-----------------------------------------------------------------------------
local function OnAddonLoaded(_, AddonName)
    if AddonName ~= LZD.name then return end

    EVENT_MANAGER:UnregisterForEvent(LZD.name, EVENT_ADD_ON_LOADED)
    LZD_Initialize()
end

EVENT_MANAGER:RegisterForEvent(LZD.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
