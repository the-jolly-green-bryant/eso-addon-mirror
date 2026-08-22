CogsAssistants = CogsAssistants or {}
local CogsAssistants = CogsAssistants

local ADDON_NAME = "CogsAssistants"
local DEV_ADDON_NAME = "cogs-assistants"
local EVENT_NAMESPACE = "CogsAssistants"
local ADDON_VERSION = "0.1.5"
local SAVED_VARIABLES_NAME = "CogsAssistantsSavedVariables"
local SAVED_VARIABLES_VERSION = 1
local PREFERENCES_NAMESPACE = "Preferences"
local CHAT_PREFIX = "|c9ac7ffCogs Assistants|r"
local RANDOM_MODE = "random"
local STATIC_MODE = "static"
local RANDOM_CHOICE = "Random"
local CLEAR_CHOICE = "Clear"
local CROW_COLLECTIBLE_IDS =
{
    [8994] = true,
    [8995] = true,
}

local TYPE_ORDER =
{
    "merchant",
    "banker",
    "deconstructor",
    "fence",
    "armorer",
    "companion",
}

local TYPE_LABELS =
{
    merchant = "Merchant",
    banker = "Banker",
    deconstructor = "Deconstructor",
    fence = "Fence",
    armorer = "Armorer",
    companion = "Companion",
}

local ASSISTANT_KEYWORDS =
{
    merchant =
    {
        "merchant", "trader", "vendor", "shopkeeper", "commerce", "delegate", "peddler", "pedlar", "nuzhimeh", "fezez", "factotum commerce delegate", "hoarfrost", "terilorne", "xyn",
    },
    banker =
    {
        "banker", "bank", "tythis", "ezabi", "pyroclast", "factotum property steward", "jangleplume", "celia", "eri",
    },
    deconstructor =
    {
        "deconstruct", "deconstruction", "ragpicker", "giladil", "alezeld", "aderene", "remus", "siluruz", "tzozabrar",
    },
    fence =
    {
        "fence", "smuggler", "pirharri", "cambio zammes",
    },
    armorer =
    {
        "armorer", "armourer", "armory", "armoury", "ghrasharog", "drinweth", "voko", "zuqoth",
    },
}

local KNOWN_COMPANION_ALIASES =
{
    azandar = "azandar",
    ["azandar al-cybiades"] = "azandar",
    bastian = "bastian",
    ["bastian hallix"] = "bastian",
    ember = "ember",
    isobel = "isobel",
    ["isobel veloise"] = "isobel",
    mirri = "mirri",
    ["mirri elendis"] = "mirri",
    sharp = "sharp",
    ["sharp-as-night"] = "sharp",
    ["sharp as night"] = "sharp",
    tanlorin = "tanlorin",
    zerith = "zerith",
    ["zerith-var"] = "zerith",
    ["zerith var"] = "zerith",
}

local DEFAULTS =
{
    selections =
    {
        merchant = { mode = RANDOM_MODE, collectibleId = nil },
        banker = { mode = RANDOM_MODE, collectibleId = nil },
        deconstructor = { mode = RANDOM_MODE, collectibleId = nil },
        fence = { mode = RANDOM_MODE, collectibleId = nil },
        armorer = { mode = RANDOM_MODE, collectibleId = nil },
        companion = { mode = RANDOM_MODE, collectibleId = nil },
    },
    companionSlots = {},
    assistantOverrides = {},
    debug = false,
    dismissActiveOnReuse = true,
}

local DEFAULT_PREFERENCES =
{
    characterSettingsEnabled = {},
}

local function Chat(message)
    d(string.format("%s %s", CHAT_PREFIX, message))
end

local function Normalize(value)
    value = tostring(value or ""):lower()
    value = value:gsub("|c%x%x%x%x%x%x", ""):gsub("|r", "")
    value = value:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
    return value
end

local function ContainsAny(haystack, needles)
    for _, needle in ipairs(needles) do
        if haystack:find(needle, 1, true) then
            return true
        end
    end
    return false
end

local function GetCollectibleNameSafe(collectibleId)
    local name = GetCollectibleName(collectibleId)
    if name and name ~= "" then
        return zo_strformat(SI_COLLECTIBLE_NAME_FORMATTER, name)
    end
    return string.format("#%s", tostring(collectibleId))
end

local function FormatChoiceName(collectibleId)
    if not collectibleId then
        return RANDOM_CHOICE
    end
    return string.format("%s (%d)", GetCollectibleNameSafe(collectibleId), collectibleId)
end

local function StripChoiceId(choice)
    local collectibleId = tostring(choice or ""):match("%((%d+)%)%s*$")
    return collectibleId and tonumber(collectibleId) or nil
end

local function GetCollectibleDataId(collectibleData)
    if collectibleData.GetId then
        return collectibleData:GetId()
    end
    return collectibleData.collectibleId
end

local function IsUnlockedAndListable(collectibleId, actorCategory)
    return IsCollectibleUnlocked(collectibleId)
        and IsCollectibleValidForPlayer(collectibleId)
        and not IsCollectibleBlocked(collectibleId, actorCategory)
end

local function IsUnlockedAndUsable(collectibleId, actorCategory)
    return IsUnlockedAndListable(collectibleId, actorCategory)
        and IsCollectibleUsable(collectibleId, actorCategory)
end

local function SortByName(left, right)
    return Normalize(GetCollectibleNameSafe(left)) < Normalize(GetCollectibleNameSafe(right))
end

local function CloneDefaults()
    local clone =
    {
        selections = {},
        companionSlots = {},
        assistantOverrides = {},
        debug = DEFAULTS.debug,
        dismissActiveOnReuse = DEFAULTS.dismissActiveOnReuse,
    }
    for typeKey, setting in pairs(DEFAULTS.selections) do
        clone.selections[typeKey] = { mode = setting.mode, collectibleId = setting.collectibleId }
    end
    return clone
end

local function DeepCopy(source)
    if type(source) ~= "table" then
        return source
    end

    local target = {}
    for key, value in pairs(source) do
        target[key] = DeepCopy(value)
    end
    return target
end

local function CopySavedVariables(source, target)
    if not source or not target then
        return
    end

    for key, value in pairs(source) do
        target[key] = DeepCopy(value)
    end
end

local function GetLegacySavedVariables(namespace, useCharacterSettings)
    local savedVariables = _G[SAVED_VARIABLES_NAME]
    local namespaceTable = savedVariables and savedVariables[namespace or "Default"]
    local displayName = GetDisplayName and GetDisplayName()
    local accountTable = displayName and namespaceTable and namespaceTable[displayName]

    if not accountTable then
        return nil
    end

    if useCharacterSettings then
        local characterId = GetCurrentCharacterId()
        return accountTable[tostring(characterId)] or accountTable[characterId]
    end

    return accountTable["$AccountWide"]
end

local function GetSelection(typeKey)
    local selection = CogsAssistants.savedVariables.selections[typeKey]
    if not selection then
        selection = { mode = RANDOM_MODE, collectibleId = nil }
        CogsAssistants.savedVariables.selections[typeKey] = selection
    end
    return selection
end

local function EnsureSavedVariableShape()
    CogsAssistants.savedVariables.selections = CogsAssistants.savedVariables.selections or {}
    CogsAssistants.savedVariables.companionSlots = CogsAssistants.savedVariables.companionSlots or {}
    CogsAssistants.savedVariables.assistantOverrides = CogsAssistants.savedVariables.assistantOverrides or {}
    if CogsAssistants.savedVariables.dismissActiveOnReuse == nil then
        CogsAssistants.savedVariables.dismissActiveOnReuse = DEFAULTS.dismissActiveOnReuse
    end

    for typeKey, setting in pairs(DEFAULTS.selections) do
        if not CogsAssistants.savedVariables.selections[typeKey] then
            CogsAssistants.savedVariables.selections[typeKey] = { mode = setting.mode, collectibleId = setting.collectibleId }
        end
    end

    CogsAssistants.savedVariables.settingsInitialized = true
end

local function GetCurrentCharacterPreferenceKey()
    return tostring(GetCurrentCharacterId())
end

local function EnsurePreferenceShape()
    CogsAssistants.preferences.characterSettingsEnabled = CogsAssistants.preferences.characterSettingsEnabled or {}
end

function CogsAssistants:LoadSavedVariables(copyCurrentSettings)
    local currentSettings = CogsAssistants.savedVariables
    local useCharacterSettings = CogsAssistants:IsUsingCharacterSettings()
    local legacySettings
    local targetSettings

    if useCharacterSettings then
        legacySettings = GetLegacySavedVariables(nil, true)
        targetSettings = ZO_SavedVars:NewCharacterIdSettings(SAVED_VARIABLES_NAME, SAVED_VARIABLES_VERSION, nil, CloneDefaults(), GetWorldName())
        CogsAssistants.settingsScope = "character"
    else
        legacySettings = GetLegacySavedVariables(nil, false)
        targetSettings = ZO_SavedVars:NewAccountWide(SAVED_VARIABLES_NAME, SAVED_VARIABLES_VERSION, nil, CloneDefaults(), GetWorldName())
        CogsAssistants.settingsScope = "account"
    end

    if copyCurrentSettings and currentSettings and not targetSettings.settingsInitialized then
        CopySavedVariables(currentSettings, targetSettings)
    elseif legacySettings and legacySettings.settingsInitialized and not targetSettings.settingsInitialized then
        CopySavedVariables(legacySettings, targetSettings)
    end

    CogsAssistants.savedVariables = targetSettings
    EnsureSavedVariableShape()
end

function CogsAssistants:IsUsingCharacterSettings()
    if not CogsAssistants.preferences then
        return false
    end

    EnsurePreferenceShape()
    return CogsAssistants.preferences.characterSettingsEnabled[GetCurrentCharacterPreferenceKey()] or false
end

function CogsAssistants:SetUseCharacterSettings(useCharacterSettings)
    useCharacterSettings = useCharacterSettings and true or false
    EnsurePreferenceShape()

    local characterPreferenceKey = GetCurrentCharacterPreferenceKey()
    if (CogsAssistants.preferences.characterSettingsEnabled[characterPreferenceKey] or false) == useCharacterSettings then
        return
    end

    CogsAssistants.preferences.characterSettingsEnabled[characterPreferenceKey] = useCharacterSettings or nil
    CogsAssistants:LoadSavedVariables(true)
    CogsAssistants:RefreshCollectibles()
    Chat(string.format("Settings are now %s.", useCharacterSettings and "character-specific" or "account-wide"))
end

local function GetActorCategoryForType(typeKey)
    if typeKey == "companion" then
        return GAMEPLAY_ACTOR_CATEGORY_PLAYER
    end
    return GAMEPLAY_ACTOR_CATEGORY_PLAYER
end

local function Debug(message)
    if CogsAssistants.savedVariables and CogsAssistants.savedVariables.debug then
        Chat(message)
    end
end

local function BuildCollectibleList(categoryType, actorCategory)
    local results = {}

    if ZO_COLLECTIBLE_DATA_MANAGER and ZO_COLLECTIBLE_DATA_MANAGER.GetAllCollectibleDataObjects then
        local collectibleDataObjects = ZO_COLLECTIBLE_DATA_MANAGER:GetAllCollectibleDataObjects(nil, { ZO_CollectibleData.IsUnlocked, ZO_CollectibleData.IsValidForPlayer })
        for _, collectibleData in ipairs(collectibleDataObjects) do
            local collectibleId = GetCollectibleDataId(collectibleData)
            if collectibleId and GetCollectibleCategoryType(collectibleId) == categoryType and IsUnlockedAndListable(collectibleId, actorCategory) then
                table.insert(results, collectibleId)
            end
        end
    else
        local total = GetTotalCollectiblesByCategoryType(categoryType)
        for index = 1, total do
            local collectibleId = GetCollectibleIdFromType(categoryType, index)
            if collectibleId and collectibleId ~= 0 and IsUnlockedAndListable(collectibleId, actorCategory) then
                table.insert(results, collectibleId)
            end
        end
    end

    table.sort(results, SortByName)
    return results
end

function CogsAssistants:RefreshCollectibles()
    CogsAssistants.collectibles =
    {
        merchant = {},
        banker = {},
        deconstructor = {},
        fence = {},
        armorer = {},
        companion = {},
    }

    local assistants = BuildCollectibleList(COLLECTIBLE_CATEGORY_TYPE_ASSISTANT, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
    for _, collectibleId in ipairs(assistants) do
        local normalizedName = Normalize(GetCollectibleNameSafe(collectibleId))
        local overrideType = CogsAssistants.savedVariables
            and CogsAssistants.savedVariables.assistantOverrides
            and CogsAssistants.savedVariables.assistantOverrides[collectibleId]
        if overrideType and TYPE_LABELS[overrideType] and overrideType ~= "companion" then
            table.insert(CogsAssistants.collectibles[overrideType], collectibleId)
        else
            local matched = false
            for typeKey, keywords in pairs(ASSISTANT_KEYWORDS) do
                if ContainsAny(normalizedName, keywords) then
                    table.insert(CogsAssistants.collectibles[typeKey], collectibleId)
                    matched = true
                end
            end
            if not matched then
                Debug(string.format("Unclassified assistant: %s (%d)", GetCollectibleNameSafe(collectibleId), collectibleId))
            end
        end
    end

    CogsAssistants.companionAliases = {}
    local companions = BuildCollectibleList(COLLECTIBLE_CATEGORY_TYPE_COMPANION, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
    for _, collectibleId in ipairs(companions) do
        table.insert(CogsAssistants.collectibles.companion, collectibleId)
        local normalizedName = Normalize(GetCollectibleNameSafe(collectibleId))
        CogsAssistants.companionAliases[normalizedName] = collectibleId
        for alias, canonical in pairs(KNOWN_COMPANION_ALIASES) do
            if normalizedName:find(alias, 1, true) or normalizedName:find(canonical, 1, true) then
                CogsAssistants.companionAliases[canonical] = collectibleId
                CogsAssistants.companionAliases[alias] = collectibleId
            end
        end
    end
end

function CogsAssistants:FindAssistant(searchText)
    CogsAssistants:RefreshCollectibles()

    local normalizedSearch = Normalize(searchText)
    local numericId = tonumber(normalizedSearch)
    local assistants = BuildCollectibleList(COLLECTIBLE_CATEGORY_TYPE_ASSISTANT, GAMEPLAY_ACTOR_CATEGORY_PLAYER)

    for _, collectibleId in ipairs(assistants) do
        if numericId and collectibleId == numericId then
            return collectibleId
        end

        local normalizedName = Normalize(GetCollectibleNameSafe(collectibleId))
        if normalizedName == normalizedSearch or normalizedName:find(normalizedSearch, 1, true) then
            return collectibleId
        end
    end
end

function CogsAssistants:GetRandomCollectible(typeKey)
    local list = CogsAssistants.collectibles[typeKey] or {}
    local candidates = list

    if IsWerewolf() then
        candidates = {}
        for _, collectibleId in ipairs(list) do
            if not CROW_COLLECTIBLE_IDS[collectibleId] then
                candidates[#candidates + 1] = collectibleId
            end
        end
    end

    if #candidates == 0 then
        return nil
    end

    if #candidates == 1 then
        return candidates[1]
    end

    local activeCollectibleId = GetActiveCollectibleByType(typeKey == "companion" and COLLECTIBLE_CATEGORY_TYPE_COMPANION or COLLECTIBLE_CATEGORY_TYPE_ASSISTANT, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
    if activeCollectibleId and activeCollectibleId ~= 0 and CogsAssistants.savedVariables.dismissActiveOnReuse then
        for _, collectibleId in ipairs(candidates) do
            if collectibleId == activeCollectibleId then
                return activeCollectibleId
            end
        end
    end

    local pick = candidates[zo_random(1, #candidates)]
    if activeCollectibleId and activeCollectibleId ~= 0 then
        for _ = 1, 5 do
            if pick ~= activeCollectibleId then
                break
            end
            pick = candidates[zo_random(1, #candidates)]
        end
    end
    return pick
end

function CogsAssistants:ResolveCollectibleForType(typeKey)
    CogsAssistants:RefreshCollectibles()

    local selection = GetSelection(typeKey)
    local collectibleId = selection.collectibleId
    if selection.mode == STATIC_MODE and collectibleId and IsUnlockedAndListable(collectibleId, GetActorCategoryForType(typeKey)) then
        return collectibleId
    end

    if selection.mode == STATIC_MODE and collectibleId then
        Chat(string.format("%s is no longer available; choosing a random %s.", GetCollectibleNameSafe(collectibleId), TYPE_LABELS[typeKey]:lower()))
    end

    return CogsAssistants:GetRandomCollectible(typeKey)
end

function CogsAssistants:UseCollectible(collectibleId, typeKey)
    if not collectibleId then
        Chat(string.format("No unlocked %s was found.", TYPE_LABELS[typeKey]:lower()))
        return
    end

    local actorCategory = GetActorCategoryForType(typeKey)
    local blockReason = GetCollectibleBlockReason(collectibleId, actorCategory)
    if blockReason ~= COLLECTIBLE_USAGE_BLOCK_REASON_NOT_BLOCKED then
        Chat(string.format("%s cannot be summoned right now.", GetCollectibleNameSafe(collectibleId)))
        return
    end

    UseCollectible(collectibleId, actorCategory)
end

function CogsAssistants:SummonType(typeKey)
    if not TYPE_LABELS[typeKey] then
        Chat("Unknown assistant type.")
        return
    end

    local collectibleId = CogsAssistants:ResolveCollectibleForType(typeKey)
    CogsAssistants:UseCollectible(collectibleId, typeKey)
end

function CogsAssistants:SummonCompanionSlot(slotIndex)
    CogsAssistants:RefreshCollectibles()

    local collectibleId = CogsAssistants.savedVariables.companionSlots[slotIndex]
    if collectibleId and IsUnlockedAndListable(collectibleId, GAMEPLAY_ACTOR_CATEGORY_PLAYER) then
        CogsAssistants:UseCollectible(collectibleId, "companion")
        return
    end

    local list = CogsAssistants.collectibles.companion or {}
    collectibleId = list[slotIndex]
    if collectibleId then
        CogsAssistants:UseCollectible(collectibleId, "companion")
        return
    end

    Chat(string.format("Companion slot %d has no unlocked companion assigned.", slotIndex))
end

function CogsAssistants:SummonCompanionNamed(alias)
    CogsAssistants:RefreshCollectibles()

    local collectibleId = CogsAssistants.companionAliases[Normalize(alias)]
    if collectibleId then
        CogsAssistants:UseCollectible(collectibleId, "companion")
    else
        Chat(string.format("That companion is not unlocked or was not found: %s.", alias))
    end
end

function CogsAssistants:FindCollectible(typeKey, searchText)
    CogsAssistants:RefreshCollectibles()

    local normalizedSearch = Normalize(searchText)
    local numericId = tonumber(normalizedSearch)
    local list = CogsAssistants.collectibles[typeKey] or {}

    if numericId then
        for _, collectibleId in ipairs(list) do
            if collectibleId == numericId then
                return collectibleId
            end
        end
    end

    local exactMatch
    local partialMatch
    for _, collectibleId in ipairs(list) do
        local normalizedName = Normalize(GetCollectibleNameSafe(collectibleId))
        if normalizedName == normalizedSearch then
            exactMatch = collectibleId
            break
        elseif normalizedName:find(normalizedSearch, 1, true) then
            partialMatch = partialMatch or collectibleId
        end
    end

    return exactMatch or partialMatch
end

function CogsAssistants:GetCollectibleChoices(typeKey, includeClear)
    CogsAssistants:RefreshCollectibles()

    local choices = {}
    if includeClear then
        table.insert(choices, CLEAR_CHOICE)
    else
        table.insert(choices, RANDOM_CHOICE)
    end

    for _, collectibleId in ipairs(CogsAssistants.collectibles[typeKey] or {}) do
        table.insert(choices, FormatChoiceName(collectibleId))
    end

    return choices
end

function CogsAssistants:GetSelectionChoice(typeKey)
    local selection = GetSelection(typeKey)
    if selection.mode ~= STATIC_MODE or not selection.collectibleId then
        return RANDOM_CHOICE
    end
    return FormatChoiceName(selection.collectibleId)
end

function CogsAssistants:SetSelectionChoice(typeKey, choice)
    if choice == RANDOM_CHOICE then
        CogsAssistants:SetTypeSelection(typeKey, RANDOM_MODE)
        return
    end

    local collectibleId = StripChoiceId(choice)
    if collectibleId then
        CogsAssistants:SetTypeSelection(typeKey, tostring(collectibleId))
    end
end

function CogsAssistants:GetCompanionSlotChoice(slotIndex)
    local collectibleId = CogsAssistants.savedVariables.companionSlots[slotIndex]
    if collectibleId then
        return FormatChoiceName(collectibleId)
    end
    return CLEAR_CHOICE
end

function CogsAssistants:SetCompanionSlotChoice(slotIndex, choice)
    if choice == CLEAR_CHOICE then
        CogsAssistants:SetCompanionSlot(slotIndex, "clear")
        return
    end

    local collectibleId = StripChoiceId(choice)
    if collectibleId then
        CogsAssistants:SetCompanionSlot(slotIndex, tostring(collectibleId))
    end
end

function CogsAssistants:SetTypeMode(typeKey, mode)
    if not TYPE_LABELS[typeKey] then
        Chat("Unknown type. Use merchant, banker, deconstructor, fence, armorer, or companion.")
        return
    end

    mode = Normalize(mode)
    if mode ~= RANDOM_MODE and mode ~= STATIC_MODE then
        Chat("Mode must be random or static.")
        return
    end

    local selection = GetSelection(typeKey)
    selection.mode = mode
    Chat(string.format("%s mode set to %s.", TYPE_LABELS[typeKey], mode))
end

function CogsAssistants:SetTypeSelection(typeKey, searchText)
    if not TYPE_LABELS[typeKey] then
        Chat("Unknown type. Use merchant, banker, deconstructor, fence, armorer, or companion.")
        return
    end

    if Normalize(searchText) == RANDOM_MODE then
        local selection = GetSelection(typeKey)
        selection.mode = RANDOM_MODE
        selection.collectibleId = nil
        Chat(string.format("%s set to random.", TYPE_LABELS[typeKey]))
        return
    end

    local collectibleId = CogsAssistants:FindCollectible(typeKey, searchText)
    if not collectibleId then
        Chat(string.format("Could not find an unlocked %s matching '%s'.", TYPE_LABELS[typeKey]:lower(), searchText))
        return
    end

    local selection = GetSelection(typeKey)
    selection.mode = STATIC_MODE
    selection.collectibleId = collectibleId
    Chat(string.format("%s set to %s.", TYPE_LABELS[typeKey], GetCollectibleNameSafe(collectibleId)))
end

function CogsAssistants:SetCompanionSlot(slotIndex, searchText)
    slotIndex = tonumber(slotIndex)
    if not slotIndex or slotIndex < 1 or slotIndex > 12 then
        Chat("Companion slot must be a number from 1 to 12.")
        return
    end

    if Normalize(searchText) == RANDOM_MODE or Normalize(searchText) == "clear" then
        CogsAssistants.savedVariables.companionSlots[slotIndex] = nil
        Chat(string.format("Companion slot %d will use the sorted unlocked companion at that position.", slotIndex))
        return
    end

    local collectibleId = CogsAssistants:FindCollectible("companion", searchText)
    if not collectibleId then
        Chat(string.format("Could not find an unlocked companion matching '%s'.", searchText))
        return
    end

    CogsAssistants.savedVariables.companionSlots[slotIndex] = collectibleId
    Chat(string.format("Companion slot %d set to %s.", slotIndex, GetCollectibleNameSafe(collectibleId)))
end

function CogsAssistants:ClassifyAssistant(typeKey, searchText)
    if not TYPE_LABELS[typeKey] or typeKey == "companion" then
        Chat("Assistant classification type must be merchant, banker, deconstructor, fence, or armorer.")
        return
    end

    local collectibleId = CogsAssistants:FindAssistant(searchText)
    if not collectibleId then
        Chat(string.format("Could not find an unlocked assistant matching '%s'.", searchText))
        return
    end

    CogsAssistants.savedVariables.assistantOverrides[collectibleId] = typeKey
    CogsAssistants:RefreshCollectibles()
    Chat(string.format("%s classified as %s.", GetCollectibleNameSafe(collectibleId), TYPE_LABELS[typeKey]:lower()))
end

function CogsAssistants:ClearAssistantClassification(searchText)
    local collectibleId = CogsAssistants:FindAssistant(searchText)
    if not collectibleId then
        Chat(string.format("Could not find an unlocked assistant matching '%s'.", searchText))
        return
    end

    CogsAssistants.savedVariables.assistantOverrides[collectibleId] = nil
    CogsAssistants:RefreshCollectibles()
    Chat(string.format("%s classification cleared.", GetCollectibleNameSafe(collectibleId)))
end

function CogsAssistants:PrintList(typeKey)
    CogsAssistants:RefreshCollectibles()

    if typeKey and typeKey ~= "" then
        if not TYPE_LABELS[typeKey] then
            Chat("Unknown type. Use merchant, banker, deconstructor, fence, armorer, or companion.")
            return
        end
        Chat(TYPE_LABELS[typeKey] .. ":")
        for _, collectibleId in ipairs(CogsAssistants.collectibles[typeKey] or {}) do
            Chat(string.format("  %d - %s", collectibleId, GetCollectibleNameSafe(collectibleId)))
        end
        return
    end

    for _, orderedTypeKey in ipairs(TYPE_ORDER) do
        local list = CogsAssistants.collectibles[orderedTypeKey] or {}
        Chat(string.format("%s: %d found", TYPE_LABELS[orderedTypeKey], #list))
    end
end

function CogsAssistants:PrintStatus()
    CogsAssistants:RefreshCollectibles()
    Chat(string.format("Status (%s settings):", CogsAssistants.settingsScope == "character" and "character-specific" or "account-wide"))
    for _, typeKey in ipairs(TYPE_ORDER) do
        local selection = GetSelection(typeKey)
        local value = "random"
        if selection.mode == STATIC_MODE and selection.collectibleId then
            value = GetCollectibleNameSafe(selection.collectibleId)
        end
        Chat(string.format("  %s: %s (%d available)", TYPE_LABELS[typeKey], value, #(CogsAssistants.collectibles[typeKey] or {})))
    end
    Chat(string.format("  Dismiss active random assistant on reuse: %s", CogsAssistants.savedVariables.dismissActiveOnReuse and "on" or "off"))
end

function CogsAssistants:PrintHelp()
    Chat("Commands:")
    Chat("  /cogsassistants list [type]")
    Chat("  /cogsassistants set <type> <name|id|random>")
    Chat("  /cogsassistants mode <type> <random|static>")
    Chat("  /cogsassistants slot <1-12> <companion name|id|clear>")
    Chat("  /cogsassistants classify <type> <assistant name|id>")
    Chat("  /cogsassistants unclassify <assistant name|id>")
    Chat("  /cogsassistants scope <account|character>")
    Chat("  /cogsassistants dismiss [on|off]")
    Chat("  /cogsassistants summon <type>")
    Chat("  /cogsassistants debug")
end

function CogsAssistants:SetDismissActiveOnReuse(value)
    value = Normalize(value)
    if value == "" then
        Chat(string.format("Dismiss active random assistant on reuse is %s.", CogsAssistants.savedVariables.dismissActiveOnReuse and "on" or "off"))
        return
    end

    if value == "on" or value == "true" or value == "1" then
        CogsAssistants.savedVariables.dismissActiveOnReuse = true
    elseif value == "off" or value == "false" or value == "0" then
        CogsAssistants.savedVariables.dismissActiveOnReuse = false
    else
        Chat("Dismiss must be on or off.")
        return
    end

    Chat(string.format("Dismiss active random assistant on reuse is now %s.", CogsAssistants.savedVariables.dismissActiveOnReuse and "on" or "off"))
end

function CogsAssistants:SetSettingsScope(scope)
    scope = Normalize(scope)
    if scope == "account" or scope == "accountwide" or scope == "account-wide" then
        CogsAssistants:SetUseCharacterSettings(false)
    elseif scope == "character" or scope == "character-specific" or scope == "char" then
        CogsAssistants:SetUseCharacterSettings(true)
    else
        Chat("Scope must be account or character.")
    end
end

function CogsAssistants:RegisterSettingsPanel()
    local LAM = LibAddonMenu2
    if not LAM or CogsAssistants.settingsPanelRegistered then
        return
    end

    CogsAssistants.settingsPanelRegistered = true
    CogsAssistants:RefreshCollectibles()

    local typeChoices = {}
    for _, typeKey in ipairs(TYPE_ORDER) do
        typeChoices[typeKey] = CogsAssistants:GetCollectibleChoices(typeKey, false)
    end
    local companionSlotChoices = CogsAssistants:GetCollectibleChoices("companion", true)

    LAM:RegisterAddonPanel("CogsAssistantsOptions", {
        type = "panel",
        name = "Cogs Assistants",
        displayName = "Cogs Assistants",
        author = "Cogs",
        version = ADDON_VERSION,
        registerForRefresh = true,
        registerForDefaults = false,
    })

    local options = {
        {
            type = "description",
            text = "Assign assistant types and companion slots. Keybinds are under Controls > Keybindings > Cogs Assistants.",
        },
        {
            type = "header",
            name = "Settings Scope",
        },
        {
            type = "checkbox",
            name = "Use character-specific settings",
            tooltip = "Off by default. When first enabled on a character, the current account-wide settings are copied to that character.",
            getFunc = function() return CogsAssistants:IsUsingCharacterSettings() end,
            setFunc = function(value) CogsAssistants:SetUseCharacterSettings(value) end,
        },
        {
            type = "checkbox",
            name = "Debug unclassified assistants",
            getFunc = function() return CogsAssistants.savedVariables.debug end,
            setFunc = function(value) CogsAssistants.savedVariables.debug = value end,
        },
        {
            type = "checkbox",
            name = "Dismiss active random assistant on reuse",
            tooltip = "When enabled, using a random type binding while an assistant of that type is active dismisses it instead of selecting another. With only one assistant available, reusing it may dismiss it regardless of this setting.",
            getFunc = function() return CogsAssistants.savedVariables.dismissActiveOnReuse end,
            setFunc = function(value) CogsAssistants.savedVariables.dismissActiveOnReuse = value end,
        },
        {
            type = "header",
            name = "Assistant Types",
        },
    }

    for _, typeKey in ipairs(TYPE_ORDER) do
        table.insert(options, {
            type = "dropdown",
            name = TYPE_LABELS[typeKey],
            choices = typeChoices[typeKey],
            getFunc = function() return CogsAssistants:GetSelectionChoice(typeKey) end,
            setFunc = function(choice) CogsAssistants:SetSelectionChoice(typeKey, choice) end,
            width = "full",
        })
    end

    table.insert(options, {
        type = "header",
        name = "Companion Slots",
    })

    for slotIndex = 1, 12 do
        table.insert(options, {
            type = "dropdown",
            name = string.format("Companion Slot %d", slotIndex),
            choices = companionSlotChoices,
            getFunc = function() return CogsAssistants:GetCompanionSlotChoice(slotIndex) end,
            setFunc = function(choice) CogsAssistants:SetCompanionSlotChoice(slotIndex, choice) end,
            width = "full",
        })
    end

    table.insert(options, {
        type = "header",
        name = "Help",
    })
    table.insert(options, {
        type = "description",
        text = "If a newly added assistant does not appear under the right type, use /ca classify <type> <assistant name or id> once. The override is saved in the active settings scope.",
    })

    LAM:RegisterOptionControls("CogsAssistantsOptions", options)
end

local function SplitCommand(text)
    local args = {}
    for token in string.gmatch(text or "", "%S+") do
        table.insert(args, token)
    end
    return args
end

local function Remainder(args, startIndex)
    local parts = {}
    for index = startIndex, #args do
        table.insert(parts, args[index])
    end
    return table.concat(parts, " ")
end

function CogsAssistants:HandleSlashCommand(text)
    local args = SplitCommand(text)
    local command = Normalize(args[1])

    if command == "" or command == "help" then
        CogsAssistants:PrintHelp()
    elseif command == "list" then
        CogsAssistants:PrintList(Normalize(args[2]))
    elseif command == "status" then
        CogsAssistants:PrintStatus()
    elseif command == "set" then
        CogsAssistants:SetTypeSelection(Normalize(args[2]), Remainder(args, 3))
    elseif command == "mode" then
        CogsAssistants:SetTypeMode(Normalize(args[2]), args[3])
    elseif command == "slot" then
        CogsAssistants:SetCompanionSlot(args[2], Remainder(args, 3))
    elseif command == "classify" then
        CogsAssistants:ClassifyAssistant(Normalize(args[2]), Remainder(args, 3))
    elseif command == "unclassify" then
        CogsAssistants:ClearAssistantClassification(Remainder(args, 2))
    elseif command == "scope" then
        CogsAssistants:SetSettingsScope(args[2])
    elseif command == "dismiss" then
        CogsAssistants:SetDismissActiveOnReuse(args[2])
    elseif command == "summon" then
        CogsAssistants:SummonType(Normalize(args[2]))
    elseif command == "debug" then
        CogsAssistants.savedVariables.debug = not CogsAssistants.savedVariables.debug
        Chat(string.format("Debug is now %s.", CogsAssistants.savedVariables.debug and "on" or "off"))
    else
        CogsAssistants:PrintHelp()
    end
end

local function CreateBindingStrings()
    ZO_CreateStringId("SI_BINDING_NAME_COGS_ASSISTANTS_SUMMON_MERCHANT", "Summon Random/Static Merchant")
    ZO_CreateStringId("SI_BINDING_NAME_COGS_ASSISTANTS_SUMMON_BANKER", "Summon Random/Static Banker")
    ZO_CreateStringId("SI_BINDING_NAME_COGS_ASSISTANTS_SUMMON_DECONSTRUCTOR", "Summon Random/Static Deconstructor")
    ZO_CreateStringId("SI_BINDING_NAME_COGS_ASSISTANTS_SUMMON_FENCE", "Summon Random/Static Fence")
    ZO_CreateStringId("SI_BINDING_NAME_COGS_ASSISTANTS_SUMMON_ARMORER", "Summon Random/Static Armorer")
    ZO_CreateStringId("SI_BINDING_NAME_COGS_ASSISTANTS_SUMMON_COMPANION", "Summon Random/Static Companion")

    for slotIndex = 1, 12 do
        ZO_CreateStringId(string.format("SI_BINDING_NAME_COGS_ASSISTANTS_COMPANION_SLOT_%d", slotIndex), string.format("Summon Companion Slot %d", slotIndex))
    end

    ZO_CreateStringId("SI_BINDING_NAME_COGS_ASSISTANTS_COMPANION_BASTIAN", "Summon Bastian Hallix")
    ZO_CreateStringId("SI_BINDING_NAME_COGS_ASSISTANTS_COMPANION_MIRRI", "Summon Mirri Elendis")
    ZO_CreateStringId("SI_BINDING_NAME_COGS_ASSISTANTS_COMPANION_EMBER", "Summon Ember")
    ZO_CreateStringId("SI_BINDING_NAME_COGS_ASSISTANTS_COMPANION_ISOBEL", "Summon Isobel Veloise")
    ZO_CreateStringId("SI_BINDING_NAME_COGS_ASSISTANTS_COMPANION_AZANDAR", "Summon Azandar al-Cybiades")
    ZO_CreateStringId("SI_BINDING_NAME_COGS_ASSISTANTS_COMPANION_SHARP", "Summon Sharp-as-Night")
    ZO_CreateStringId("SI_BINDING_NAME_COGS_ASSISTANTS_COMPANION_TANLORIN", "Summon Tanlorin")
    ZO_CreateStringId("SI_BINDING_NAME_COGS_ASSISTANTS_COMPANION_ZERITH_VAR", "Summon Zerith-var")
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= ADDON_NAME and addonName ~= DEV_ADDON_NAME then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_ADD_ON_LOADED)
    local legacyPreferences = GetLegacySavedVariables(PREFERENCES_NAMESPACE, false)
    CogsAssistants.preferences = ZO_SavedVars:NewAccountWide(SAVED_VARIABLES_NAME, SAVED_VARIABLES_VERSION, PREFERENCES_NAMESPACE, DEFAULT_PREFERENCES, GetWorldName())
    if legacyPreferences
        and legacyPreferences.characterSettingsEnabled
        and next(legacyPreferences.characterSettingsEnabled) ~= nil
        and next(CogsAssistants.preferences.characterSettingsEnabled or {}) == nil then
        CopySavedVariables(legacyPreferences, CogsAssistants.preferences)
    end
    EnsurePreferenceShape()
    CogsAssistants:LoadSavedVariables(false)
    CogsAssistants:RefreshCollectibles()
    CogsAssistants:RegisterSettingsPanel()
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_COLLECTIBLE_UPDATED, function() CogsAssistants:RefreshCollectibles() end)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_COLLECTION_UPDATED, function() CogsAssistants:RefreshCollectibles() end)
    SLASH_COMMANDS["/cogsassistants"] = function(text) CogsAssistants:HandleSlashCommand(text) end
    SLASH_COMMANDS["/ca"] = SLASH_COMMANDS["/cogsassistants"]
end

CreateBindingStrings()
EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
