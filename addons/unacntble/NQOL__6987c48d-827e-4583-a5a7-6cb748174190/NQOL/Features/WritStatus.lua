NQOL = NQOL or {}
NQOL.Features = NQOL.Features or {}

local WritStatus = {}

local ALPHABET = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ $%*+-./:"
local BASE = #ALPHABET
local CHECKSUM_MODULUS = BASE * BASE
local DISPLAY_DURATION_MS = 10000
local DISPLAY_SIZE_MIN = 360
local DISPLAY_SIZE_MAX = 600
local MAX_PAYLOAD_LENGTH = 2200
local MAX_JOURNAL_QUESTS_FALLBACK = 25
local PAYLOAD_PREFIX = "NQWS2"
local QUEST_MAIN_STEP = 1

local control
local displayRevision = 0
local generation = -1
local lastPayload

local Floor = math.floor
local StringByte = string.byte
local StringFind = string.find
local StringFormat = string.format
local StringGsub = string.gsub
local StringSub = string.sub

local function Clamp(value, minimum, maximum)
    return math.max(minimum, math.min(maximum, value))
end

local function AlphabetIndex(character)
    local index = StringFind(ALPHABET, character, 1, true)
    return index and index - 1 or nil
end

local function EncodeFixed(value, width)
    value = tonumber(value)
    if not value or value < 0 or value ~= Floor(value) or value >= BASE ^ width then
        return nil
    end

    local encoded = {}
    for index = width, 1, -1 do
        local digit = value % BASE
        encoded[index] = StringSub(ALPHABET, digit + 1, digit + 1)
        value = Floor(value / BASE)
    end
    return table.concat(encoded)
end

local function DecodeFixed(encoded)
    local value = 0
    for index = 1, #encoded do
        local digit = AlphabetIndex(StringSub(encoded, index, index))
        if digit == nil then
            return nil
        end
        value = value * BASE + digit
    end
    return value
end

local function CalculateChecksum(payload)
    local checksum = 0
    for index = 1, #payload do
        checksum = (checksum * 33 + StringByte(payload, index)) % CHECKSUM_MODULUS
    end
    return checksum
end

local function NormalizeSubject(value)
    value = tostring(value or "")
    if type(zo_strformat) == "function" then
        value = zo_strformat("<<t:1>>", value)
    end
    value = StringGsub(value, "|c%x%x%x%x%x%x", "")
    value = StringGsub(value, "|r", "")
    value = StringGsub(value, "%s+", " ")
    value = StringGsub(value, "^%s+", "")
    return StringGsub(value, "%s+$", "")
end

local function EscapeSubject(value)
    value = NormalizeSubject(value)
    value = StringGsub(value, "%%", "%%25")
    value = StringGsub(value, "|", "%%7C")
    value = StringGsub(value, ",", "%%2C")
    value = StringGsub(value, ";", "%%3B")
    return StringGsub(value, "[%z\1-\31\127]", function(character)
        return StringFormat("%%%02X", StringByte(character))
    end)
end

local function ItemLink(itemId)
    return getItemLinkFromItemId(itemId)
end

local function ItemName(itemId)
    return GetItemLinkName(ItemLink(itemId))
end

local function StackCount(link)
    local backpack, bank, craftBag = GetItemLinkStacks(link)
    return (backpack or 0) + (bank or 0) + (craftBag or 0)
end

local function AddFailure(failures, code, subject, owned, required)
    failures[#failures + 1] = {
        code = tostring(code or "probe"),
        subject = NormalizeSubject(subject),
        owned = tonumber(owned) or 0,
        required = tonumber(required) or 0,
    }
end

local function TableIndex(values, target)
    for index, value in ipairs(values) do
        if value == target then
            return index
        end
    end
    return nil
end

local function SmithingPattern(craftingType, itemId)
    local link = ItemLink(itemId)
    local armorPatterns = {
        EQUIP_TYPE_CHEST, EQUIP_TYPE_FEET, EQUIP_TYPE_HAND,
        EQUIP_TYPE_HEAD, EQUIP_TYPE_LEGS, EQUIP_TYPE_SHOULDERS,
        EQUIP_TYPE_WAIST,
    }
    if craftingType == CRAFTING_TYPE_BLACKSMITHING then
        local weaponPatterns = {
            WEAPONTYPE_AXE, WEAPONTYPE_HAMMER, WEAPONTYPE_SWORD,
            WEAPONTYPE_TWO_HANDED_AXE, WEAPONTYPE_TWO_HANDED_HAMMER,
            WEAPONTYPE_TWO_HANDED_SWORD, WEAPONTYPE_DAGGER,
        }
        local weapon = TableIndex(weaponPatterns, GetItemLinkWeaponType(link))
        if weapon then
            return weapon
        end
        local armor = TableIndex(armorPatterns, GetItemLinkEquipType(link))
        if armor and GetItemLinkArmorType(link) == ARMORTYPE_HEAVY then
            return armor + 7
        end
    elseif craftingType == CRAFTING_TYPE_CLOTHIER then
        local armor = TableIndex(armorPatterns, GetItemLinkEquipType(link))
        local weight = GetItemLinkArmorType(link)
        if armor and weight == ARMORTYPE_LIGHT then
            if armor == 1 then
                return IsItemLinkRobe(link) and 1 or 2
            end
            return armor + 1
        elseif armor and weight == ARMORTYPE_MEDIUM then
            return armor + 8
        end
    elseif craftingType == CRAFTING_TYPE_WOODWORKING then
        return TableIndex({
            WEAPONTYPE_BOW, WEAPONTYPE_SHIELD, WEAPONTYPE_FIRE_STAFF,
            WEAPONTYPE_FROST_STAFF, WEAPONTYPE_LIGHTNING_STAFF,
            WEAPONTYPE_HEALING_STAFF,
        }, GetItemLinkWeaponType(link))
    elseif craftingType == CRAFTING_TYPE_JEWELRYCRAFTING then
        return TableIndex(
            { EQUIP_TYPE_RING, EQUIP_TYPE_NECK },
            GetItemLinkEquipType(link)
        )
    end
    return nil
end

local function SmithingMaterialIndex(craftingType)
    local bonusTypes = {
        [CRAFTING_TYPE_BLACKSMITHING] = NON_COMBAT_BONUS_BLACKSMITHING_LEVEL,
        [CRAFTING_TYPE_CLOTHIER] = NON_COMBAT_BONUS_CLOTHIER_LEVEL,
        [CRAFTING_TYPE_WOODWORKING] = NON_COMBAT_BONUS_WOODWORKING_LEVEL,
        [CRAFTING_TYPE_JEWELRYCRAFTING] = NON_COMBAT_BONUS_JEWELRYCRAFTING_LEVEL,
    }
    local rank = GetNonCombatBonus(bonusTypes[craftingType])
    if craftingType == CRAFTING_TYPE_JEWELRYCRAFTING then
        return ({ 1, 13, 26, 33, 40 })[rank]
    end
    return ({ 1, 8, 13, 18, 23, 26, 29, 32, 34, 40 })[rank]
end

local function IsDailyCraftingQuest(questIndex)
    return GetJournalQuestRepeatType(questIndex) == QUEST_REPEAT_DAILY
        and GetJournalQuestType(questIndex) == QUEST_TYPE_CRAFTING
end

local function ActiveConditions()
    local byCraftingType = { {}, {}, {}, {}, {}, {}, {} }
    local states, reasons = {}, {}
    local unknownQuest = false
    for craftingType = 1, 7 do states[craftingType] = "A" end
    local maximum = tonumber(MAX_JOURNAL_QUESTS) or MAX_JOURNAL_QUESTS_FALLBACK
    for questIndex = 1, maximum do
        if IsValidQuestIndex(questIndex) and IsDailyCraftingQuest(questIndex) then
            local questType, ready, conditionCount = NQOL.GPSAdvancedData.GetWritQuestInfo(questIndex)
            if not questType then
                unknownQuest = true
            elseif ready then
                states[questType] = "R"
            else
                states[questType] = "C"
            end
            for conditionIndex = 1, ready and 0 or conditionCount do
                local itemId, materialId, craftingType, quality = GetQuestConditionItemInfo(
                    questIndex,
                    QUEST_MAIN_STEP,
                    conditionIndex
                )
                local _, current, required = GetJournalQuestConditionInfo(
                    questIndex,
                    QUEST_MAIN_STEP,
                    conditionIndex
                )
                if type(craftingType) == "number"
                    and craftingType >= 1
                    and craftingType <= 7
                    and craftingType == questType
                    and type(itemId) == "number"
                    and itemId > 0
                    and type(current) == "number"
                    and type(required) == "number"
                    and current < required
                then
                    local conditions = byCraftingType[craftingType]
                    conditions[#conditions + 1] = {
                        item = itemId,
                        material = materialId,
                        quality = quality,
                        amount = required - current,
                    }
                elseif questType
                    and (type(current) ~= "number" or type(required) ~= "number"
                        or (current < required and (craftingType ~= questType
                            or type(itemId) ~= "number" or itemId <= 0)))
                then
                    states[questType] = "U"
                    reasons[questType] = "incomplete item condition metadata"
                end
            end
        end
    end
    for craftingType = 1, 7 do
        if states[craftingType] == "C" and #byCraftingType[craftingType] == 0 then
            states[craftingType] = "U"
            reasons[craftingType] = "active writ has no readable unfinished item objectives"
        elseif states[craftingType] == "A" and unknownQuest then
            states[craftingType] = "U"
            reasons[craftingType] = "daily crafting quest type unavailable"
        end
    end
    return byCraftingType, states, reasons
end

local function SmithingFailures(craftingType, conditions, sharedStyles)
    local failures, requirements, patterns = {}, {}, {}
    for _, condition in ipairs(conditions) do
        local pattern, materialIndex = GetSmithingPatternInfoForItemId(
            condition.item,
            condition.material,
            craftingType
        )
        pattern = pattern or SmithingPattern(craftingType, condition.item)
        materialIndex = materialIndex or SmithingMaterialIndex(craftingType)
        if not pattern or not materialIndex then
            AddFailure(failures, "resolution", ItemName(condition.item), 0, condition.amount)
        else
            local quantity = LibLazyCrafting.functionTable.GetMatRequirements(
                pattern,
                materialIndex,
                craftingType
            )
            local request = {
                type = "smithing",
                pattern = pattern,
                materialIndex = materialIndex,
                materialQuantity = quantity,
                style = LLC_FREE_STYLE_CHOICE,
                trait = 1,
                station = craftingType,
                quality = ITEM_FUNCTIONAL_QUALITY_NORMAL,
            }
            local itemRequirements = LLC_Global:getMatRequirements(request)
            for materialId, needed in pairs(itemRequirements or {}) do
                if type(materialId) == "number" and materialId > 0 then
                    requirements[materialId] = (requirements[materialId] or 0)
                        + needed * condition.amount
                end
            end
            patterns[#patterns + 1] = {
                pattern = pattern,
                item = condition.item,
                amount = condition.amount,
            }
        end
    end

    for materialId, required in pairs(requirements) do
        local link = ItemLink(materialId)
        local owned = StackCount(link)
        if owned < required then
            AddFailure(failures, "material", GetItemLinkName(link), owned, required)
        end
    end
    if #failures == 0 and craftingType ~= CRAFTING_TYPE_JEWELRYCRAFTING then
        local trialStyles = {}
        for styleId, count in pairs(sharedStyles) do
            trialStyles[styleId] = count
        end
        for _, requested in ipairs(patterns) do
            local missingStyles = 0
            for _ = 1, requested.amount do
                local selected, available = nil, 0
                for styleId, count in pairs(trialStyles) do
                    if count > available and IsSmithingStyleKnown(styleId, requested.pattern) then
                        selected, available = styleId, count
                    end
                end
                if selected then
                    trialStyles[selected] = trialStyles[selected] - 1
                else
                    missingStyles = missingStyles + 1
                end
            end
            if missingStyles > 0 then
                AddFailure(
                    failures,
                    "style",
                    "known enabled style material for " .. ItemName(requested.item),
                    0,
                    missingStyles
                )
            end
        end
        if #failures == 0 then
            for styleId, count in pairs(trialStyles) do
                sharedStyles[styleId] = count
            end
        end
    end
    return failures
end

local function ProvisioningFailures(conditions)
    local failures = {}
    for _, condition in ipairs(conditions) do
        local _, listIndex, recipeIndex = GetRecipeInfoFromItemId(condition.item)
        if not listIndex or not recipeIndex then
            AddFailure(failures, "resolution", ItemName(condition.item), 0, 1)
        else
            local known, name, ingredients, levelRequired, qualityRequired =
                GetRecipeInfo(listIndex, recipeIndex)
            if not known then
                AddFailure(failures, "recipe", name, 0, 1)
            else
                local level = GetNonCombatBonus(NON_COMBAT_BONUS_PROVISIONING_LEVEL)
                local quality = GetNonCombatBonus(NON_COMBAT_BONUS_PROVISIONING_RARITY_LEVEL)
                if level < levelRequired then
                    AddFailure(failures, "skill", "Provisioning for " .. name, level, levelRequired)
                end
                if qualityRequired > 0 and quality < qualityRequired then
                    AddFailure(
                        failures,
                        "skill",
                        "Recipe Improvement for " .. name,
                        quality,
                        qualityRequired
                    )
                end
                local iterations = condition.amount
                for ingredient = 1, ingredients do
                    local link = GetRecipeIngredientItemLink(
                        listIndex,
                        recipeIndex,
                        ingredient,
                        LINK_STYLE_DEFAULT
                    )
                    local required = GetRecipeIngredientRequiredQuantity(
                        listIndex,
                        recipeIndex,
                        ingredient
                    ) * iterations
                    local owned = StackCount(link)
                    if owned < required then
                        AddFailure(failures, "material", GetItemLinkName(link), owned, required)
                    end
                end
            end
        end
    end
    return failures
end

local function EnchantingFailures(conditions)
    local failures, requirements = {}, {}
    for _, condition in ipairs(conditions) do
        local potency, essence, aspect = GetRunesForItemIdIfKnown(
            condition.item,
            condition.material,
            condition.quality
        )
        if not potency then
            AddFailure(failures, "knowledge", "runes for " .. ItemName(condition.item), 0, 1)
        else
            for _, runeId in ipairs({ potency, essence, aspect }) do
                requirements[runeId] = (requirements[runeId] or 0) + condition.amount
            end
        end
    end
    for runeId, required in pairs(requirements) do
        local link = ItemLink(runeId)
        local owned = StackCount(link)
        if owned < required then
            AddFailure(failures, "material", GetItemLinkName(link), owned, required)
        end
    end
    return failures
end

local function AlchemyInventory()
    local items = PLAYER_INVENTORY:GenerateListOfVirtualStackedItems(
        INVENTORY_BACKPACK,
        ZO_Alchemy_IsAlchemyItem
    )
    PLAYER_INVENTORY:GenerateListOfVirtualStackedItems(
        INVENTORY_BANK,
        ZO_Alchemy_IsAlchemyItem,
        items
    )
    PLAYER_INVENTORY:GenerateListOfVirtualStackedItems(
        INVENTORY_CRAFT_BAG,
        ZO_Alchemy_IsAlchemyItem,
        items
    )
    return items
end

local function AlchemyFailures(conditions)
    local failures, items = {}, AlchemyInventory()
    for _, condition in ipairs(conditions) do
        local solvent
        for _, item in pairs(items) do
            if IsAlchemySolventForItemAndMaterialId(
                item.bag,
                item.index,
                condition.item,
                condition.material
            ) then
                solvent = item
                break
            end
        end
        if not solvent then
            AddFailure(
                failures,
                "material",
                "required solvent for " .. ItemName(condition.item),
                0,
                condition.amount
            )
        else
            local iterations = condition.amount
            local solventLink = GetItemLink(solvent.bag, solvent.index)
            local solventOwned = StackCount(solventLink)
            if solventOwned < iterations then
                AddFailure(
                    failures,
                    "material",
                    GetItemLinkName(solventLink),
                    solventOwned,
                    iterations
                )
            end

            local desiredTrait = GetTraitIdFromBasePotion(condition.item)
            local reagents = {}
            for _, item in pairs(items) do
                if GetItemType(item.bag, item.index) == ITEMTYPE_REAGENT
                    and DoesAlchemyItemHaveKnownTrait(item.bag, item.index, desiredTrait)
                then
                    reagents[#reagents + 1] = item
                end
            end
            local usable, anyKnown
            for firstIndex, first in ipairs(reagents) do
                for secondIndex, second in ipairs(reagents) do
                    if firstIndex < secondIndex then
                        local result = GetAlchemyResultingItemIdIfKnown(
                            solvent.bag,
                            solvent.index,
                            first.bag,
                            first.index,
                            second.bag,
                            second.index,
                            nil,
                            nil,
                            nil
                        )
                        if result == condition.item then
                            anyKnown = anyKnown or { first, second }
                            local firstCount = StackCount(GetItemLink(first.bag, first.index))
                            local secondCount = StackCount(GetItemLink(second.bag, second.index))
                            if firstCount >= iterations and secondCount >= iterations then
                                usable = { first, second }
                                break
                            end
                        end
                    end
                end
                if usable then
                    break
                end
            end
            if not usable then
                if anyKnown then
                    for _, reagent in ipairs(anyKnown) do
                        local link = GetItemLink(reagent.bag, reagent.index)
                        local owned = StackCount(link)
                        if owned < iterations then
                            AddFailure(
                                failures,
                                "material",
                                GetItemLinkName(link),
                                owned,
                                iterations
                            )
                        end
                    end
                else
                    AddFailure(
                        failures,
                        "reagent_combo",
                        "known owned reagents for " .. ItemName(condition.item),
                        0,
                        iterations
                    )
                end
            end
        end
    end
    return failures
end

local function CheckType(craftingType, conditions, sharedStyles)
    if craftingType == CRAFTING_TYPE_BLACKSMITHING
        or craftingType == CRAFTING_TYPE_CLOTHIER
        or craftingType == CRAFTING_TYPE_WOODWORKING
        or craftingType == CRAFTING_TYPE_JEWELRYCRAFTING
    then
        return SmithingFailures(craftingType, conditions, sharedStyles)
    elseif craftingType == CRAFTING_TYPE_PROVISIONING then
        return ProvisioningFailures(conditions)
    elseif craftingType == CRAFTING_TYPE_ENCHANTING then
        return EnchantingFailures(conditions)
    elseif craftingType == CRAFTING_TYPE_ALCHEMY then
        return AlchemyFailures(conditions)
    end
    local failures = {}
    AddFailure(failures, "resolution", "crafting type", craftingType, 0)
    return failures
end

local function RequiredDependenciesAvailable()
    if type(LibLazyCrafting) ~= "table"
        or type(LibLazyCrafting.functionTable) ~= "table"
        or type(LibLazyCrafting.functionTable.GetMatRequirements) ~= "function"
        or type(LLC_Global) ~= "table"
        or type(LLC_Global.getMatRequirements) ~= "function"
        or LLC_FREE_STYLE_CHOICE == nil
    then
        return false, "LibLazyCrafting"
    end
    if type(WritCreater) ~= "table" or type(WritCreater.GetSettings) ~= "function" then
        return false, "DolgubonsLazyWritCreator"
    end
    local success, settings = pcall(WritCreater.GetSettings, WritCreater)
    if not success or type(settings) ~= "table" or type(settings.styles) ~= "table" then
        return false, "DolgubonsLazyWritCreator"
    end
    return true
end

local function EncodeFailure(failure)
    return table.concat({
        failure.code,
        EscapeSubject(failure.subject),
        tostring(Floor(failure.owned)),
        tostring(Floor(failure.required)),
    }, ",")
end

local function EncodeResult(craftingType, failures)
    if #failures == 0 then
        return tostring(craftingType) .. ",P"
    end
    local encoded = {}
    for index, failure in ipairs(failures) do
        encoded[index] = EncodeFailure(failure)
    end
    return tostring(craftingType) .. ",F," .. table.concat(encoded, ";")
end

local function NextGeneration()
    generation = (generation + 1) % CHECKSUM_MODULUS
    return EncodeFixed(generation, 2)
end

local function FinalizePayload(parts)
    local body = table.concat(parts, "|")
    return body .. "|" .. EncodeFixed(CalculateChecksum(body), 2)
end

local function FatalPayload(currentGeneration, code, subject)
    local payload = FinalizePayload({
        PAYLOAD_PREFIX,
        currentGeneration,
        "E," .. tostring(code) .. "," .. EscapeSubject(subject),
    })
    if #payload <= MAX_PAYLOAD_LENGTH then
        return payload
    end
    return FinalizePayload({
        PAYLOAD_PREFIX,
        currentGeneration,
        "E," .. tostring(code) .. ",unavailable",
    })
end

local function BuildNormalPayload(currentGeneration)
    local conditionsByType, states, reasons = ActiveConditions()
    local needsCrafting = false
    for craftingType = 1, 7 do
        if states[craftingType] == "C" then needsCrafting = true end
    end
    local freeSlots = 0
    local sharedStyles = {}
    if needsCrafting then
        local available, dependency = RequiredDependenciesAvailable()
        if not available then return FatalPayload(currentGeneration, "dependency", dependency) end
        freeSlots = GetNumBagFreeSlots(BAG_BACKPACK)
        local styleSettings = WritCreater:GetSettings().styles or {}
        for styleId, enabled in pairs(styleSettings) do
            if type(styleId) == "number" and enabled then
                sharedStyles[styleId] = GetCurrentSmithingStyleItemCount(styleId)
            end
        end
    end

    local parts = { PAYLOAD_PREFIX, currentGeneration }
    for craftingType = 1, 7 do
        local conditions = conditionsByType[craftingType]
        local slotsNeeded = 0
        local isEquipment = craftingType == CRAFTING_TYPE_BLACKSMITHING
            or craftingType == CRAFTING_TYPE_CLOTHIER
            or craftingType == CRAFTING_TYPE_WOODWORKING
            or craftingType == CRAFTING_TYPE_JEWELRYCRAFTING
        if isEquipment then
            for _, condition in ipairs(conditions) do
                slotsNeeded = slotsNeeded + condition.amount
            end
        end

        local failures
        if states[craftingType] ~= "C" then
            failures = {}
        elseif isEquipment and freeSlots < slotsNeeded then
            failures = {}
            AddFailure(failures, "inventory", "backpack slots", freeSlots, slotsNeeded)
        else
            failures = CheckType(craftingType, conditions, sharedStyles)
        end
        if states[craftingType] == "C" and #failures == 0 and isEquipment then
            freeSlots = freeSlots - slotsNeeded
        end
        if states[craftingType] == "U" then
            parts[#parts + 1] = tostring(craftingType) .. ",U," .. EscapeSubject(reasons[craftingType])
        elseif states[craftingType] ~= "C" then
            parts[#parts + 1] = tostring(craftingType) .. "," .. states[craftingType]
        else
            parts[#parts + 1] = EncodeResult(craftingType, failures)
        end
    end
    return FinalizePayload(parts)
end

local function BuildPayload()
    local currentGeneration = NextGeneration()
    local success, payload = pcall(BuildNormalPayload, currentGeneration)
    if not success then
        return FatalPayload(currentGeneration, "probe", tostring(payload))
    end
    if #payload > MAX_PAYLOAD_LENGTH then
        return FatalPayload(currentGeneration, "payload_too_large", tostring(#payload))
    end
    return payload
end

local function EnsureControl()
    if control or not WINDOW_MANAGER or not GuiRoot then
        return control
    end
    local root = WINDOW_MANAGER:CreateTopLevelWindow("NQOLWritStatus")
    root:SetHidden(true)
    root:SetMouseEnabled(false)
    root:SetClampedToScreen(true)
    root:SetDrawLayer(DL_OVERLAY)
    root:SetDrawTier(DT_HIGH)
    root:SetDrawLevel(231)

    local background = WINDOW_MANAGER:CreateControl(nil, root, CT_BACKDROP)
    background:SetAnchorFill(root)
    background:SetCenterColor(1, 1, 1, 1)
    background:SetEdgeColor(0, 0, 0, 1)
    background:SetEdgeTexture("EsoUI/Art/Tooltips/Gamepad/gp_tooltip_edge.dds", 32, 4)

    local qr = WINDOW_MANAGER:CreateControl("NQOLWritStatusQRCode", root, CT_TEXTURE)
    qr:SetAnchorFill(root)
    control = { root = root, qr = qr }
    return control
end

local function ApplySizeAndPosition(current)
    local width = (GetScreenWidth and GetScreenWidth()) or (GuiRoot.GetWidth and GuiRoot:GetWidth()) or 1920
    local height = (GetScreenHeight and GetScreenHeight()) or (GuiRoot.GetHeight and GuiRoot:GetHeight()) or 1080
    local size = Clamp(Floor(math.min(width, height) * 0.55), DISPLAY_SIZE_MIN, DISPLAY_SIZE_MAX)
    current.root:SetDimensions(size, size)
    current.qr:SetDimensions(size, size)
    current.root:ClearAnchors()
    current.root:SetAnchor(BOTTOM, GuiRoot, BOTTOM, 0, -12)
end

local function Hide()
    displayRevision = displayRevision + 1
    if control and control.root then
        control.root:SetHidden(true)
    end
end

local function Show()
    Hide()
    local library = _G.LibQRCode
    if type(library) ~= "table" or type(library.DrawQRCode) ~= "function" then
        return false, "LibQRC"
    end
    local current = EnsureControl()
    if not current then
        return false, "UI"
    end

    local payload = BuildPayload()
    ApplySizeAndPosition(current)
    local success = pcall(library.DrawQRCode, current.qr, payload)
    if not success then
        current.root:SetHidden(true)
        return false, "LibQRC"
    end
    local composite = WINDOW_MANAGER:GetControlByName("NQOLWritStatusQRCodeQRComposite")
    if composite and composite.GetNumSurfaces and composite.SetColor then
        for surfaceIndex = 1, composite:GetNumSurfaces() do
            composite:SetColor(surfaceIndex, 0, 0, 0, 1)
        end
    end
    current.root:SetHidden(false)
    lastPayload = payload

    displayRevision = displayRevision + 1
    local revision = displayRevision
    if type(zo_callLater) == "function" then
        zo_callLater(function()
            if displayRevision == revision and control and control.root then
                control.root:SetHidden(true)
            end
        end, DISPLAY_DURATION_MS)
    end
    return true, payload
end

function WritStatus.BuildPayload()
    return BuildPayload()
end

function WritStatus.DecodeFixed(value)
    return DecodeFixed(value)
end

function WritStatus.GetLastPayload()
    return lastPayload
end

function WritStatus.GetPayloadPrefix()
    return PAYLOAD_PREFIX .. "|"
end

function WritStatus.Hide()
    Hide()
end

function WritStatus.Show()
    return Show()
end

function WritStatus.VerifyPayload(payload)
    if type(payload) ~= "string" or StringSub(payload, 1, #PAYLOAD_PREFIX + 1) ~= PAYLOAD_PREFIX .. "|" then
        return false
    end
    local body, checksum = payload:match("^(.*)|([^|][^|])$")
    return body ~= nil
        and DecodeFixed(checksum) == CalculateChecksum(body)
        and #payload <= MAX_PAYLOAD_LENGTH
end

NQOL.Features.WritStatus = WritStatus
