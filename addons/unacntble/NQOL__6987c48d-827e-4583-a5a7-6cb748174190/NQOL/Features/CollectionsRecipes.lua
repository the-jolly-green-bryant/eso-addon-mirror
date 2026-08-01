NQOL = NQOL or {}
NQOL.Features = NQOL.Features or {}

local CollectionsRecipes = {}
local USE_LETTER_GROUPS = NQOL.Util.UsesCollectionLetterGroups()

local C = {
    SEARCH_DIALOG_NAME = "NQOL_COLLECTIONS_RECIPE_SEARCH",
    DRAW_LEVEL = 240,
    SCALE_MIN = 50,
    SCALE_MAX = 150,
    BACKGROUND_OPACITY_MIN = 0,
    BACKGROUND_OPACITY_MAX = 100,
    SCREEN_MARGIN = 24,
    PADDING = 16,
    HEADER_HEIGHT = 66,
    FOOTER_HEIGHT = 44,
    PANE_HEADER_HEIGHT = 34,
    PANE_GAP = 18,
    ROW_GAP = 4,
    INPUT_DEADZONE = 0.34,
    INPUT_INITIAL_DELAY_MS = 330,
    INPUT_REPEAT_DELAY_MS = 95,
    MIN_WIDTH = 860,
    MAX_WIDTH = 1280,
    MAX_CARD_WIDTH = 1580,
    MIN_HEIGHT = 500,
    MAX_HEIGHT = 760,
}

local COLORS = {
    background = { 0.018, 0.028, 0.045 },
    panel = { 0.035, 0.055, 0.085 },
    panelAlt = { 0.055, 0.08, 0.12 },
    selected = { 0.07, 0.31, 0.52 },
    selectedEdge = { 0.35, 0.78, 1 },
    accent = { 0.30, 0.76, 1 },
    accentSoft = { 0.12, 0.45, 0.68 },
    complete = { 0.36, 0.92, 0.62 },
    missing = { 0.95, 0.28, 0.30 },
    text = { 0.94, 0.97, 1 },
    textMuted = { 0.63, 0.72, 0.82 },
    divider = { 0.25, 0.48, 0.68 },
    cardGold = { 0.93, 0.76, 0.16 },
    cardMuted = { 0.70, 0.69, 0.59 },
    cardText = { 0.82, 0.82, 0.78 },
    cardLegend = { 0.52, 0.52, 0.52 },
}

local TEXTURES = {
    progress = "EsoUI/Art/Miscellaneous/progressbar_genericFill.dds",
    upArrow = "EsoUI/Art/Buttons/Gamepad/gp_upArrow.dds",
    downArrow = "EsoUI/Art/Buttons/Gamepad/gp_downArrow.dds",
}

local INGREDIENT_COUNT_ICON_MARKUP = "|t20:20:EsoUI/Art/HUD/Gamepad/gp_lootHistory_icon_craftBag.dds|t"
local INGREDIENT_PRICE_ICON_MARKUP = "|t20:20:EsoUI/Art/currency/currency_gold.dds|t"
local INGREDIENT_COUNT_AVAILABLE_COLOR = "5CEB9E"
local INGREDIENT_COUNT_MISSING_COLOR = "F2474D"

local FILTERS = {
    { prefix = "All" },
    { prefix = "Known" },
    { prefix = "Unknown" },
}

local FURNISHING_CRAFT_GROUPS = {
    { craftingType = CRAFTING_TYPE_WOODWORKING, label = NQOL.L("features.collections_recipes.blueprints_f169a8b"), order = 1 },
    { craftingType = CRAFTING_TYPE_BLACKSMITHING, label = NQOL.L("features.collections_recipes.diagrams_ecf4d50"), order = 2 },
    { craftingType = CRAFTING_TYPE_CLOTHIER, label = NQOL.L("features.collections_recipes.patterns_4d34f7a"), order = 3 },
    { craftingType = CRAFTING_TYPE_ALCHEMY, label = NQOL.L("features.collections_recipes.formulae_c656eb8"), order = 4 },
    { craftingType = CRAFTING_TYPE_ENCHANTING, label = NQOL.L("features.collections_recipes.praxis_87dec93"), order = 5 },
    { craftingType = CRAFTING_TYPE_PROVISIONING, label = NQOL.L("features.collections_recipes.designs_fdeaaf8"), order = 6 },
    { craftingType = CRAFTING_TYPE_JEWELRYCRAFTING, label = NQOL.L("features.collections_recipes.sketches_f3b8596"), order = 7 },
}
NQOL.Lexicon.RegisterTableField(FURNISHING_CRAFT_GROUPS, "label", {
    "features.collections_recipes.blueprints_f169a8b", "features.collections_recipes.diagrams_ecf4d50",
    "features.collections_recipes.patterns_4d34f7a", "features.collections_recipes.formulae_c656eb8",
    "features.collections_recipes.praxis_87dec93", "features.collections_recipes.designs_fdeaaf8",
    "features.collections_recipes.sketches_f3b8596",
})

local PAGE_ORDER = { "food", "drink", "plans" }
local PAGE_DEFINITIONS = {
    food = {
        label = NQOL.L("features.collections_recipes.food_recipes_ccd936f"),
        itemSingular = "recipe",
        itemPlural = "recipes",
        specialIngredientType = PROVISIONER_SPECIAL_INGREDIENT_TYPE_SPICES,
    },
    drink = {
        label = NQOL.L("features.collections_recipes.drink_recipes_3128a30"),
        itemSingular = "recipe",
        itemPlural = "recipes",
        specialIngredientType = PROVISIONER_SPECIAL_INGREDIENT_TYPE_FLAVORING,
    },
    plans = {
        label = NQOL.L("features.collections_recipes.plans_cf2e5f2"),
        itemSingular = "plan",
        itemPlural = "plans",
    },
}
NQOL.Lexicon.RegisterRefreshCallback(function()
    PAGE_DEFINITIONS.food.label = NQOL.L("features.collections_recipes.food_recipes_ccd936f")
    PAGE_DEFINITIONS.drink.label = NQOL.L("features.collections_recipes.drink_recipes_3128a30")
    PAGE_DEFINITIONS.plans.label = NQOL.L("features.collections_recipes.plans_cf2e5f2")
    PAGE_DEFINITIONS.food.itemSingular = NQOL.Util.Lower(NQOL.L("collections.recipes.recipe"))
    PAGE_DEFINITIONS.drink.itemSingular = PAGE_DEFINITIONS.food.itemSingular
    PAGE_DEFINITIONS.plans.itemSingular = NQOL.Util.Lower(NQOL.L("collections.recipes.plan"))
end)

local DEFAULT_FONT_SIZE = 26
local DEFAULT_SCALE = 100
local defaults = {
    collections = {
        recipes = {
            recipeCard = true,
            horizontalPosition = 50,
            verticalPosition = 50,
            font = NQOL.Util.GetDefaultFont(),
            scale = DEFAULT_SCALE,
            backgroundOpacity = 90,
            selectedCategories = {
                food = 1,
                drink = 1,
                plans = 1,
            },
            selectedRecipeIds = {
                food = 0,
                drink = 0,
                plans = 0,
            },
        },
    },
}

local savedVariables
local initialized = false
local settingsPanelVisible = false
local dataReady = false
local hud
local recipePages = {}
local activePageKey = "food"
local activePage
local categories = {}
local filteredRecords = {}
local letterGroups = {}
local letterGroupPool = {}
local listEntries = {}
local recipeEntryIndices = {}
local selectedCategoryIndex = 1
local selectedRecipeIndex = 0
local visibleFirstIndex = 1
local filterIndex = 1
local searchTextByPage = { food = "", drink = "", plans = "" }
local searchNeedleByPage = { food = "", drink = "", plans = "" }
local searchDialogOpen = false
local searchDialogRegistered = false
local fontStringCache = {}
local layoutCache = {}
local inputHintTextCache = {}
local ingredientLines = {}
local ingredientIndicatorLines = {}
local hudKeybindGroup
local hudKeybindsActive = false
local Refresh
local ApplyPosition
local RefreshInputActivation
local RefreshHudKeybinds

local Clamp = NQOL.Util.Clamp
local Round = NQOL.Util.Round

local function ClearTable(values)
    for key in pairs(values) do
        values[key] = nil
    end
end

local function GetSettings()
    local collections = NQOL.Settings.GetSection(savedVariables, defaults, "collections")
    if type(collections.recipes) ~= "table" then
        collections.recipes = {}
    end

    local settings = collections.recipes
    for key, value in pairs(defaults.collections.recipes) do
        if settings[key] == nil then
            settings[key] = value
        end
    end

    settings.recipeCard = settings.recipeCard == true
    settings.horizontalPosition = Clamp(tonumber(settings.horizontalPosition) or defaults.collections.recipes.horizontalPosition, 0, 100)
    settings.verticalPosition = Clamp(tonumber(settings.verticalPosition) or defaults.collections.recipes.verticalPosition, 0, 100)
    settings.scale = Clamp(Round(tonumber(settings.scale) or DEFAULT_SCALE), C.SCALE_MIN, C.SCALE_MAX)
    settings.backgroundOpacity = Clamp(Round(tonumber(settings.backgroundOpacity) or defaults.collections.recipes.backgroundOpacity), C.BACKGROUND_OPACITY_MIN, C.BACKGROUND_OPACITY_MAX)
    if type(settings.selectedCategories) ~= "table" then settings.selectedCategories = {} end
    if type(settings.selectedRecipeIds) ~= "table" then settings.selectedRecipeIds = {} end
    for _, pageKey in ipairs(PAGE_ORDER) do
        settings.selectedCategories[pageKey] = math.max(Round(tonumber(settings.selectedCategories[pageKey]) or 1), 1)
        settings.selectedRecipeIds[pageKey] = tonumber(settings.selectedRecipeIds[pageKey]) or 0
    end
    if not NQOL.Util.IsFontChoice(settings.font) then
        settings.font = NQOL.Util.GetDefaultFont()
    end
    return settings
end

local function GetFont(offset)
    local settings = GetSettings()
    local size = Clamp(DEFAULT_FONT_SIZE + (offset or 0), 9, 36)
    local key = tostring(settings.font) .. "|" .. tostring(size)
    if not fontStringCache[key] then
        fontStringCache[key] = string.format("%s|%d|soft-shadow-thin", settings.font, size)
    end
    return fontStringCache[key]
end

local function SetColor(control, color, alpha)
    control:SetColor(color[1], color[2], color[3], alpha or 1)
end

local function MoveAbove(control, level)
    if control.SetDrawTier and DT_HIGH then control:SetDrawTier(DT_HIGH) end
    if control.SetDrawLayer and DL_CONTROLS then control:SetDrawLayer(DL_CONTROLS) end
    if control.SetDrawLevel then control:SetDrawLevel(level or C.DRAW_LEVEL) end
end

local function CreateLabel(parent, fontOffset, color, alignment)
    local label = WINDOW_MANAGER:CreateControl(nil, parent, CT_LABEL)
    label:SetFont(GetFont(fontOffset))
    SetColor(label, color or COLORS.text)
    label:SetHorizontalAlignment(alignment or TEXT_ALIGN_LEFT)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    if label.SetWrapMode and TEXT_WRAP_MODE_ELLIPSIS then
        label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    end
    MoveAbove(label, C.DRAW_LEVEL + 5)
    return label
end

local function CreateBackdrop(parent, color, edgeColor)
    local backdrop = WINDOW_MANAGER:CreateControl(nil, parent, CT_BACKDROP)
    backdrop:SetCenterColor(color[1], color[2], color[3], color[4] or 1)
    local edge = edgeColor or color
    backdrop:SetEdgeColor(edge[1], edge[2], edge[3], edge[4] or 1)
    MoveAbove(backdrop, C.DRAW_LEVEL + 1)
    return backdrop
end

local function FormatName(name)
    if zo_strformat and SI_TOOLTIP_ITEM_NAME then
        return zo_strformat(SI_TOOLTIP_ITEM_NAME, name or "")
    end
    return name or NQOL.L("collections.recipes.unknown_recipe")
end

local function GetItemLinkFromItemId(itemId)
    return string.format("|H1:item:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", itemId)
end

local function GetResultItemIcon(resultItemId, fallbackIcon)
    if resultItemId and resultItemId ~= 0 and GetItemLinkIcon then
        local itemLink = GetItemLinkFromItemId(resultItemId)
        local icon = GetItemLinkIcon(itemLink)
        if icon and icon ~= "" then
            return icon
        end
    end
    return fallbackIcon
end

local function GetLibRecipe()
    local lib = rawget(_G, "LibRecipe")
    if type(lib) == "table" and type(lib.GetRecipeItemLink) == "function" then
        return lib
    end
    return nil
end

local function GetRecipeItemLink(record)
    if not record or not record.resultItemId or record.resultItemId == 0 then return nil end
    local lib = GetLibRecipe()
    if not lib then return nil end

    local succeeded, recipeItemLink = pcall(
        lib.GetRecipeItemLink,
        lib,
        GetItemLinkFromItemId(record.resultItemId)
    )
    if succeeded and type(recipeItemLink) == "string" and recipeItemLink ~= "" then
        return recipeItemLink
    end
    return nil
end

local function GetRecipeResultLink(record)
    if not record then return nil end
    if GetRecipeResultItemLink and record.listIndex and record.recipeIndex then
        local itemLink = GetRecipeResultItemLink(record.listIndex, record.recipeIndex, LINK_STYLE_DEFAULT)
        if itemLink and itemLink ~= "" then return itemLink end
    end
    if record.resultItemId and record.resultItemId ~= 0 then
        return GetItemLinkFromItemId(record.resultItemId)
    end
    return nil
end

local function Uppercase(text)
    text = tostring(text or "")
    return NQOL.Util.Upper(text)
end

local function GetFurnishingCraftGroup(craftingType)
    for _, group in ipairs(FURNISHING_CRAFT_GROUPS) do
        if group.craftingType == craftingType then
            return group
        end
    end
    return nil
end

local function CompareRecipes(left, right)
    local leftName = NQOL.Util.Lower(left.name)
    local rightName = NQOL.Util.Lower(right.name)
    if leftName ~= rightName then
        return leftName < rightName
    end
    if left.listIndex ~= right.listIndex then
        return left.listIndex < right.listIndex
    end
    return left.recipeIndex < right.recipeIndex
end

local function GetFilterLabel()
    local definition = activePage and PAGE_DEFINITIONS[activePage.key]
    return string.format("%s %s", FILTERS[filterIndex].prefix, definition and definition.itemPlural or NQOL.L("common.items"))
end

local function RecordMatchesFilter(record)
    if filterIndex == 2 and not record.known then return false end
    if filterIndex == 3 and record.known then return false end
    local searchNeedle = searchNeedleByPage[activePageKey] or ""
    if searchNeedle ~= "" then
        local recipeName = NQOL.Util.Lower(record.name)
        if not string.find(recipeName, searchNeedle, 1, true) then return false end
    end
    return true
end

local function GetRecordKey(record)
    return string.format("%d:%d", record.listIndex, record.recipeIndex)
end

local function GetSelectedRecord()
    return filteredRecords[selectedRecipeIndex]
end

local function RebuildFilteredList(preferredRecipeId)
    ClearTable(filteredRecords)
    ClearTable(letterGroups)
    ClearTable(listEntries)
    ClearTable(recipeEntryIndices)

    local category = categories[selectedCategoryIndex]
    local previousLetter
    for _, record in ipairs(category and category.records or {}) do
        if RecordMatchesFilter(record) then
            local groupKey, groupLabel = NQOL.Util.GetCollectionLetterGroup(record.name)
            if USE_LETTER_GROUPS and groupKey ~= previousLetter then
                local groupIndex = #letterGroups + 1
                local group = letterGroupPool[groupIndex]
                if not group then
                    group = {}
                    letterGroupPool[groupIndex] = group
                end
                group.letter = groupLabel
                group.startIndex = #filteredRecords + 1
                letterGroups[groupIndex] = group
                listEntries[#listEntries + 1] = {
                    isHeader = true,
                    label = groupLabel,
                }
                group.entryIndex = #listEntries
                previousLetter = groupKey
            end
            filteredRecords[#filteredRecords + 1] = record
            record.groupIndex = USE_LETTER_GROUPS and #letterGroups or nil
            listEntries[#listEntries + 1] = record
            recipeEntryIndices[GetRecordKey(record)] = #listEntries
        end
    end

    selectedRecipeIndex = 0
    local settings = GetSettings()
    local requestedId = preferredRecipeId or settings.selectedRecipeIds[activePageKey]
    if requestedId and requestedId ~= 0 then
        for index, record in ipairs(filteredRecords) do
            if record.resultItemId == requestedId then
                selectedRecipeIndex = index
                break
            end
        end
    end
    if selectedRecipeIndex == 0 and #filteredRecords > 0 then
        selectedRecipeIndex = 1
    end

    local selectedRecord = GetSelectedRecord()
    if selectedRecord then
        settings.selectedRecipeIds[activePageKey] = selectedRecord.resultItemId
        visibleFirstIndex = math.max((recipeEntryIndices[GetRecordKey(selectedRecord)] or 1) - 2, 1)
    else
        visibleFirstIndex = 1
    end
end

local function AddCategory(page, key, label, order)
    local category = page.categoryByKey[key]
    if category then return category end
    category = {
        key = key,
        label = label,
        order = order,
        records = {},
        known = 0,
        total = 0,
    }
    page.categoryByKey[key] = category
    page.categories[#page.categories + 1] = category
    return category
end

local function ActivatePage(pageKey)
    activePageKey = PAGE_DEFINITIONS[pageKey] and pageKey or "food"
    activePage = recipePages[activePageKey]
    categories = activePage and activePage.categories or {}
    local settings = GetSettings()
    selectedCategoryIndex = Clamp(settings.selectedCategories[activePageKey], 1, math.max(#categories, 1))
    settings.selectedCategories[activePageKey] = selectedCategoryIndex
    RebuildFilteredList(settings.selectedRecipeIds[activePageKey])
end

local function BuildRecipeRecords()
    ClearTable(recipePages)
    dataReady = false

    local pageKeyBySpecialIngredient = {}
    for _, pageKey in ipairs(PAGE_ORDER) do
        local definition = PAGE_DEFINITIONS[pageKey]
        recipePages[pageKey] = {
            key = pageKey,
            label = definition.label,
            categories = {},
            categoryByKey = {},
            known = 0,
            total = 0,
        }
        if definition.specialIngredientType then
            pageKeyBySpecialIngredient[definition.specialIngredientType] = pageKey
        end
    end
    for _, group in ipairs(FURNISHING_CRAFT_GROUPS) do
        AddCategory(recipePages.plans, group.order, group.label, group.order)
    end
    local allCategoryByPage = {}
    for _, pageKey in ipairs(PAGE_ORDER) do
        allCategoryByPage[pageKey] = AddCategory(recipePages[pageKey], "all", "All", 0)
    end

    if not GetNumRecipeLists or not GetRecipeListInfo or not GetRecipeInfo then
        ActivatePage(activePageKey)
        return
    end

    for listIndex = 1, GetNumRecipeLists() do
        local listName, numRecipes = GetRecipeListInfo(listIndex)
        listName = FormatName(listName)
        for recipeIndex = 1, (numRecipes or 0) do
            local known, recipeName, numIngredients, provisionerLevelReq, qualityReq, specialIngredientType, requiredCraftingStationType, resultItemId =
                GetRecipeInfo(listIndex, recipeIndex)
            local isFurnishingPlan = listIndex >= 17
            local furnishingGroup = isFurnishingPlan and GetFurnishingCraftGroup(requiredCraftingStationType) or nil
            local pageKey = isFurnishingPlan and "plans" or pageKeyBySpecialIngredient[specialIngredientType]
            local includeRecipe = furnishingGroup ~= nil or (
                not isFurnishingPlan
                and pageKey ~= nil
                and requiredCraftingStationType == CRAFTING_TYPE_PROVISIONING
            )
            if includeRecipe then
                local resultName, icon, _, _, displayQuality
                if GetRecipeResultItemInfo then
                    resultName, icon, _, _, displayQuality = GetRecipeResultItemInfo(listIndex, recipeIndex)
                end
                local page = recipePages[pageKey]
                local category = isFurnishingPlan
                    and page.categoryByKey[furnishingGroup.order]
                    or AddCategory(page, listIndex, listName, listIndex)
                local record = {
                    listIndex = listIndex,
                    recipeIndex = recipeIndex,
                    listName = listName,
                    name = FormatName((resultName and resultName ~= "" and resultName) or recipeName),
                    known = known == true,
                    numIngredients = numIngredients or 0,
                    provisionerLevelReq = provisionerLevelReq or 0,
                    qualityReq = qualityReq,
                    displayQuality = displayQuality,
                    resultItemId = resultItemId or 0,
                    icon = GetResultItemIcon(resultItemId, icon),
                    categoryLabel = category.label,
                    isPlan = isFurnishingPlan,
                }
                category.records[#category.records + 1] = record
                category.total = category.total + 1
                local allCategory = allCategoryByPage[pageKey]
                allCategory.records[#allCategory.records + 1] = record
                allCategory.total = allCategory.total + 1
                if record.known then allCategory.known = allCategory.known + 1 end
                page.total = page.total + 1
                if record.known then
                    category.known = category.known + 1
                    page.known = page.known + 1
                end
            end
        end
    end

    for _, pageKey in ipairs(PAGE_ORDER) do
        local page = recipePages[pageKey]
        local allCategory = page.categoryByKey.all
        if allCategory then
            for categoryIndex, category in ipairs(page.categories) do
                if category == allCategory then
                    table.remove(page.categories, categoryIndex)
                    break
                end
            end
        end
        table.sort(page.categories, function(left, right)
            local leftLabel = NQOL.Util.Lower(left.label)
            local rightLabel = NQOL.Util.Lower(right.label)
            if leftLabel ~= rightLabel then return leftLabel < rightLabel end
            return left.order < right.order
        end)
        if allCategory then table.insert(page.categories, 1, allCategory) end
        for _, category in ipairs(page.categories) do
            table.sort(category.records, CompareRecipes)
        end
    end

    ActivatePage(activePageKey)
    dataReady = true
end

local function GetScreenDimensions()
    local width, height
    if GuiRoot and GuiRoot.GetDimensions then width, height = GuiRoot:GetDimensions() end
    if (not width or width <= 0) and GetScreenWidth then width = GetScreenWidth() end
    if (not height or height <= 0) and GetScreenHeight then height = GetScreenHeight() end
    return width or 1920, height or 1080
end

local function GetLayout()
    local screenWidth, screenHeight = GetScreenDimensions()
    local settings = GetSettings()
    local recipeCard = settings.recipeCard
    local scale = settings.scale / 100
    local widthLimit = recipeCard and C.MAX_CARD_WIDTH or C.MAX_WIDTH
    local widthRatio = recipeCard and 0.78 or 0.60
    local maximumWidth = math.max(math.min(widthLimit, (screenWidth - (C.SCREEN_MARGIN * 2)) / scale), 360)
    local maximumHeight = math.max(math.min(C.MAX_HEIGHT, (screenHeight - (C.SCREEN_MARGIN * 2)) / scale), 300)
    local width = Clamp(Round(screenWidth * widthRatio), math.min(C.MIN_WIDTH, maximumWidth), maximumWidth)
    local height = Clamp(Round(screenHeight * 0.64), math.min(C.MIN_HEIGHT, maximumHeight), maximumHeight)
    local innerWidth = width - (C.PADDING * 2)
    local typeWidth = Round(innerWidth * (recipeCard and 0.22 or 0.28))
    local cardWidth = recipeCard and Round(innerWidth * 0.40) or 0
    local gapsWidth = C.PANE_GAP * (recipeCard and 2 or 1)
    local recipeWidth = innerWidth - typeWidth - cardWidth - gapsWidth
    local contentTop = C.PADDING + C.HEADER_HEIGHT
    local contentHeight = height - contentTop - C.FOOTER_HEIGHT - C.PADDING
    local viewportHeight = contentHeight - C.PANE_HEADER_HEIGHT
    local rowHeight = math.max(DEFAULT_FONT_SIZE + 24, 44)

    layoutCache.screenWidth = screenWidth
    layoutCache.screenHeight = screenHeight
    layoutCache.width = width
    layoutCache.height = height
    layoutCache.innerWidth = innerWidth
    layoutCache.typeWidth = typeWidth
    layoutCache.recipeWidth = recipeWidth
    layoutCache.cardWidth = cardWidth
    layoutCache.recipeCard = recipeCard
    layoutCache.scale = scale
    layoutCache.contentTop = contentTop
    layoutCache.contentHeight = contentHeight
    layoutCache.viewportHeight = viewportHeight
    layoutCache.rowHeight = rowHeight
    layoutCache.visibleRows = math.max(math.floor((viewportHeight + C.ROW_GAP) / (rowHeight + C.ROW_GAP)), 5)
    return layoutCache
end

local function EnsureHud()
    if hud or not WINDOW_MANAGER or not GuiRoot then return hud end

    hud = { inputDirection = 0, nextInputAt = 0 }
    hud.control = WINDOW_MANAGER:CreateTopLevelWindow("NQOLCollectionsRecipes")
    hud.control:SetHidden(true)
    MoveAbove(hud.control, C.DRAW_LEVEL)
    hud.UpdateDirectionalInput = function()
        CollectionsRecipes.UpdateDirectionalInput()
    end

    local opacity = GetSettings().backgroundOpacity / 100
    hud.background = CreateBackdrop(hud.control, { COLORS.background[1], COLORS.background[2], COLORS.background[3], opacity }, { COLORS.divider[1], COLORS.divider[2], COLORS.divider[3], math.min(opacity + 0.12, 1) })
    hud.background:SetAnchorFill(hud.control)
    hud.title = CreateLabel(hud.control, 5, COLORS.text)
    hud.headerDivider = WINDOW_MANAGER:CreateControl(nil, hud.control, CT_TEXTURE)
    SetColor(hud.headerDivider, COLORS.divider, 0.72)
    MoveAbove(hud.headerDivider, C.DRAW_LEVEL + 3)

    hud.typeHeader = CreateLabel(hud.control, -3, COLORS.accent)
    hud.recipeHeader = CreateLabel(hud.control, 1, COLORS.text)
    hud.recipeSubheader = CreateLabel(hud.control, -4, COLORS.textMuted, TEXT_ALIGN_RIGHT)
    hud.typeViewport = WINDOW_MANAGER:CreateControl(nil, hud.control, CT_CONTROL)
    hud.recipeViewport = WINDOW_MANAGER:CreateControl(nil, hud.control, CT_CONTROL)
    if hud.typeViewport.SetClipsChildren then hud.typeViewport:SetClipsChildren(true) end
    if hud.recipeViewport.SetClipsChildren then hud.recipeViewport:SetClipsChildren(true) end
    MoveAbove(hud.typeViewport, C.DRAW_LEVEL + 2)
    MoveAbove(hud.recipeViewport, C.DRAW_LEVEL + 2)

    hud.verticalDivider = WINDOW_MANAGER:CreateControl(nil, hud.control, CT_TEXTURE)
    SetColor(hud.verticalDivider, COLORS.divider, 0.55)
    MoveAbove(hud.verticalDivider, C.DRAW_LEVEL + 3)
    hud.upArrow = WINDOW_MANAGER:CreateControl(nil, hud.control, CT_TEXTURE)
    hud.upArrow:SetTexture(TEXTURES.upArrow)
    SetColor(hud.upArrow, COLORS.accent)
    MoveAbove(hud.upArrow, C.DRAW_LEVEL + 6)
    hud.downArrow = WINDOW_MANAGER:CreateControl(nil, hud.control, CT_TEXTURE)
    hud.downArrow:SetTexture(TEXTURES.downArrow)
    SetColor(hud.downArrow, COLORS.accent)
    MoveAbove(hud.downArrow, C.DRAW_LEVEL + 6)
    hud.empty = CreateLabel(hud.recipeViewport, -1, COLORS.textMuted, TEXT_ALIGN_CENTER)
    hud.footerDivider = WINDOW_MANAGER:CreateControl(nil, hud.control, CT_TEXTURE)
    SetColor(hud.footerDivider, COLORS.divider, 0.65)
    MoveAbove(hud.footerDivider, C.DRAW_LEVEL + 3)
    hud.hint = CreateLabel(hud.control, -4, COLORS.textMuted, TEXT_ALIGN_RIGHT)
    return hud
end

local function EnsureRecipeCard()
    if not hud or hud.cardViewport then return end
    hud.cardViewport = WINDOW_MANAGER:CreateControl(nil, hud.control, CT_CONTROL)
    if hud.cardViewport.SetClipsChildren then hud.cardViewport:SetClipsChildren(true) end
    MoveAbove(hud.cardViewport, C.DRAW_LEVEL + 2)
    hud.cardBackground = CreateBackdrop(hud.cardViewport, { 0.008, 0.009, 0.008, 0.93 }, { COLORS.cardGold[1], COLORS.cardGold[2], COLORS.cardGold[3], 0.34 })
    hud.cardBackground:SetAnchorFill(hud.cardViewport)
    hud.cardEyebrow = CreateLabel(hud.cardViewport, -7, COLORS.cardMuted)
    hud.cardTitle = CreateLabel(hud.cardViewport, 1, COLORS.cardGold)
    hud.cardTitle:SetVerticalAlignment(TEXT_ALIGN_TOP)
    if hud.cardTitle.SetMaxLineCount then hud.cardTitle:SetMaxLineCount(2) end
    hud.cardIcon = WINDOW_MANAGER:CreateControl(nil, hud.cardViewport, CT_TEXTURE)
    MoveAbove(hud.cardIcon, C.DRAW_LEVEL + 5)
    hud.cardIconLoading = CreateLabel(hud.cardViewport, -8, COLORS.cardMuted, TEXT_ALIGN_CENTER)
    NQOL.Util.ConfigureContentTexture(hud.cardIcon, hud.cardIconLoading)
    hud.cardMeta = CreateLabel(hud.cardViewport, -7, COLORS.cardMuted, TEXT_ALIGN_CENTER)
    hud.cardInfoColumn = WINDOW_MANAGER:CreateControl(nil, hud.cardViewport, CT_CONTROL)
    hud.cardDescription = CreateLabel(hud.cardViewport, -4, COLORS.cardText)
    hud.cardDescription:SetVerticalAlignment(TEXT_ALIGN_TOP)
    hud.cardColumnRule = WINDOW_MANAGER:CreateControl(nil, hud.cardViewport, CT_TEXTURE)
    SetColor(hud.cardColumnRule, COLORS.cardGold, 0.22)
    MoveAbove(hud.cardColumnRule, C.DRAW_LEVEL + 4)
    hud.cardRule = WINDOW_MANAGER:CreateControl(nil, hud.cardViewport, CT_TEXTURE)
    SetColor(hud.cardRule, COLORS.cardGold, 0.42)
    MoveAbove(hud.cardRule, C.DRAW_LEVEL + 4)
    hud.cardIngredientsHeader = CreateLabel(hud.cardViewport, -4, COLORS.cardText)
    hud.cardIngredients = CreateLabel(hud.cardViewport, -4, COLORS.cardText)
    hud.cardIngredients:SetVerticalAlignment(TEXT_ALIGN_TOP)
    hud.cardIngredientIndicators = CreateLabel(hud.cardViewport, -6, COLORS.cardText, TEXT_ALIGN_RIGHT)
    hud.cardIngredientIndicators:SetVerticalAlignment(TEXT_ALIGN_TOP)
    if hud.cardIngredientIndicators.SetLineSpacing and hud.cardIngredients.GetFontHeight and hud.cardIngredientIndicators.GetFontHeight then
        hud.cardIngredientIndicators:SetLineSpacing(math.max(hud.cardIngredients:GetFontHeight() - hud.cardIngredientIndicators:GetFontHeight(), 0))
    end
    hud.cardPriceLegendIcon = WINDOW_MANAGER:CreateControl(nil, hud.cardViewport, CT_TEXTURE)
    hud.cardPriceLegendIcon:SetTexture("EsoUI/Art/currency/currency_gold.dds")
    if hud.cardPriceLegendIcon.SetDesaturation then hud.cardPriceLegendIcon:SetDesaturation(1) end
    SetColor(hud.cardPriceLegendIcon, COLORS.cardLegend)
    MoveAbove(hud.cardPriceLegendIcon, C.DRAW_LEVEL + 5)
    hud.cardPriceLegend = CreateLabel(hud.cardViewport, -8, COLORS.cardLegend, TEXT_ALIGN_RIGHT)
end

local function EnsureTypeRow(index)
    hud.typeRows = hud.typeRows or {}
    if hud.typeRows[index] then return hud.typeRows[index] end
    local row = {}
    row.control = WINDOW_MANAGER:CreateControl(nil, hud.typeViewport, CT_CONTROL)
    row.background = CreateBackdrop(row.control, { COLORS.panelAlt[1], COLORS.panelAlt[2], COLORS.panelAlt[3], 0.68 })
    row.background:SetAnchorFill(row.control)
    row.accent = WINDOW_MANAGER:CreateControl(nil, row.control, CT_TEXTURE)
    SetColor(row.accent, COLORS.selectedEdge)
    MoveAbove(row.accent, C.DRAW_LEVEL + 3)
    row.name = CreateLabel(row.control, -1, COLORS.text)
    row.count = CreateLabel(row.control, -4, COLORS.textMuted, TEXT_ALIGN_RIGHT)
    row.progressBackground = WINDOW_MANAGER:CreateControl(nil, row.control, CT_TEXTURE)
    SetColor(row.progressBackground, COLORS.panel, 0.95)
    MoveAbove(row.progressBackground, C.DRAW_LEVEL + 3)
    row.progress = WINDOW_MANAGER:CreateControl(nil, row.control, CT_STATUSBAR)
    row.progress:SetTexture(TEXTURES.progress)
    SetColor(row.progress, COLORS.accentSoft)
    MoveAbove(row.progress, C.DRAW_LEVEL + 4)
    hud.typeRows[index] = row
    return row
end

local function EnsureRecipeRow(index)
    hud.recipeRows = hud.recipeRows or {}
    if hud.recipeRows[index] then return hud.recipeRows[index] end
    local row = {}
    row.control = WINDOW_MANAGER:CreateControl(nil, hud.recipeViewport, CT_CONTROL)
    row.background = CreateBackdrop(row.control, { COLORS.panelAlt[1], COLORS.panelAlt[2], COLORS.panelAlt[3], 0.68 })
    row.background:SetAnchorFill(row.control)
    row.accent = WINDOW_MANAGER:CreateControl(nil, row.control, CT_TEXTURE)
    SetColor(row.accent, COLORS.selectedEdge)
    MoveAbove(row.accent, C.DRAW_LEVEL + 3)
    row.header = CreateLabel(row.control, 1, COLORS.accent)
    row.icon = WINDOW_MANAGER:CreateControl(nil, row.control, CT_TEXTURE)
    MoveAbove(row.icon, C.DRAW_LEVEL + 5)
    row.iconLoading = CreateLabel(row.control, -10, COLORS.textMuted, TEXT_ALIGN_CENTER)
    NQOL.Util.ConfigureContentTexture(row.icon, row.iconLoading)
    row.name = CreateLabel(row.control, -2, COLORS.text)
    row.status = CreateLabel(row.control, -6, COLORS.textMuted, TEXT_ALIGN_RIGHT)
    hud.recipeRows[index] = row
    return row
end

local function ApplyBackground()
    if not hud then return end
    local opacity = GetSettings().backgroundOpacity / 100
    hud.background:SetCenterColor(COLORS.background[1], COLORS.background[2], COLORS.background[3], opacity)
    hud.background:SetEdgeColor(COLORS.divider[1], COLORS.divider[2], COLORS.divider[3], math.min(opacity + 0.12, 1))
end

local function ApplyFonts()
    if not hud then return end
    hud.title:SetFont(GetFont(5))
    hud.typeHeader:SetFont(GetFont(-3))
    hud.recipeHeader:SetFont(GetFont(1))
    hud.recipeSubheader:SetFont(GetFont(-4))
    hud.empty:SetFont(GetFont(-1))
    hud.hint:SetFont(GetFont(-4))
    for _, row in ipairs(hud.typeRows or {}) do
        row.name:SetFont(GetFont(-1))
        row.count:SetFont(GetFont(-4))
    end
    for _, row in ipairs(hud.recipeRows or {}) do
        row.header:SetFont(GetFont(1))
        row.iconLoading:SetFont(GetFont(-10))
        row.name:SetFont(GetFont(-2))
        row.status:SetFont(GetFont(-6))
    end
    if hud.cardViewport then
        hud.cardEyebrow:SetFont(GetFont(-7))
        hud.cardTitle:SetFont(GetFont(1))
        hud.cardIconLoading:SetFont(GetFont(-8))
        hud.cardMeta:SetFont(GetFont(-7))
        hud.cardDescription:SetFont(GetFont(-4))
        hud.cardIngredientsHeader:SetFont(GetFont(-4))
        hud.cardIngredients:SetFont(GetFont(-4))
        hud.cardIngredientIndicators:SetFont(GetFont(-6))
        hud.cardPriceLegend:SetFont(GetFont(-8))
        if hud.cardIngredientIndicators.SetLineSpacing and hud.cardIngredients.GetFontHeight and hud.cardIngredientIndicators.GetFontHeight then
            hud.cardIngredientIndicators:SetLineSpacing(math.max(hud.cardIngredients:GetFontHeight() - hud.cardIngredientIndicators:GetFontHeight(), 0))
        end
    end
end

local function LayoutHud(layout)
    if not EnsureHud() then return end
    local control = hud.control
    if layout.recipeCard then EnsureRecipeCard() end
    control:SetDimensions(layout.width, layout.height)
    if control.SetScale then control:SetScale(layout.scale) end

    hud.title:ClearAnchors()
    hud.title:SetDimensions(layout.innerWidth, C.HEADER_HEIGHT - 8)
    hud.title:SetAnchor(TOPLEFT, control, TOPLEFT, C.PADDING, C.PADDING - 2)
    hud.headerDivider:ClearAnchors()
    hud.headerDivider:SetDimensions(layout.innerWidth, 1)
    hud.headerDivider:SetAnchor(TOPLEFT, control, TOPLEFT, C.PADDING, C.PADDING + C.HEADER_HEIGHT - 7)

    hud.typeHeader:ClearAnchors()
    hud.typeHeader:SetDimensions(layout.typeWidth, C.PANE_HEADER_HEIGHT)
    hud.typeHeader:SetAnchor(TOPLEFT, control, TOPLEFT, C.PADDING, layout.contentTop)
    hud.recipeHeader:ClearAnchors()
    hud.recipeHeader:SetDimensions(layout.recipeWidth * 0.58, C.PANE_HEADER_HEIGHT)
    hud.recipeHeader:SetAnchor(TOPLEFT, control, TOPLEFT, C.PADDING + layout.typeWidth + C.PANE_GAP, layout.contentTop)
    hud.recipeSubheader:ClearAnchors()
    hud.recipeSubheader:SetDimensions(layout.recipeWidth * 0.40, C.PANE_HEADER_HEIGHT)
    hud.recipeSubheader:SetAnchor(TOPRIGHT, hud.recipeViewport, TOPRIGHT, 0, -C.PANE_HEADER_HEIGHT)

    hud.typeViewport:ClearAnchors()
    hud.typeViewport:SetDimensions(layout.typeWidth, layout.viewportHeight)
    hud.typeViewport:SetAnchor(TOPLEFT, control, TOPLEFT, C.PADDING, layout.contentTop + C.PANE_HEADER_HEIGHT)
    hud.recipeViewport:ClearAnchors()
    hud.recipeViewport:SetDimensions(layout.recipeWidth, layout.viewportHeight)
    hud.recipeViewport:SetAnchor(TOPLEFT, control, TOPLEFT, C.PADDING + layout.typeWidth + C.PANE_GAP, layout.contentTop + C.PANE_HEADER_HEIGHT)
    hud.verticalDivider:ClearAnchors()
    hud.verticalDivider:SetDimensions(1, layout.contentHeight)
    hud.verticalDivider:SetAnchor(TOPLEFT, control, TOPLEFT, C.PADDING + layout.typeWidth + math.floor(C.PANE_GAP / 2), layout.contentTop)

    if hud.cardViewport then
        hud.cardViewport:SetHidden(not layout.recipeCard)
        if layout.recipeCard then
            local cardX = C.PADDING + layout.typeWidth + C.PANE_GAP + layout.recipeWidth + C.PANE_GAP
            local cardIconTop = 108
            local cardContentWidth = layout.cardWidth - 32
            local cardColumnGap = 18
            local cardColumnWidth = math.floor((cardContentWidth - cardColumnGap) / 2)
            local verticalIconLimit = math.max(layout.viewportHeight - 300, 72)
            local cardIconSize = Clamp(Round(math.min(cardColumnWidth * 0.68, verticalIconLimit)), 72, 176)
            local cardMetaTop = cardIconTop + cardIconSize + 6
            local cardRuleTop = math.max(cardMetaTop + 50, Clamp(Round(layout.viewportHeight * 0.52), 280, layout.viewportHeight - 190))
            local ingredientsHeaderTop = cardRuleTop + 14
            local ingredientsTop = ingredientsHeaderTop + 34
            hud.cardViewport:ClearAnchors()
            hud.cardViewport:SetDimensions(layout.cardWidth, layout.viewportHeight)
            hud.cardViewport:SetAnchor(TOPLEFT, control, TOPLEFT, cardX, layout.contentTop + C.PANE_HEADER_HEIGHT)
            hud.cardEyebrow:ClearAnchors()
            hud.cardEyebrow:SetDimensions(layout.cardWidth - 32, 25)
            hud.cardEyebrow:SetAnchor(TOPLEFT, hud.cardViewport, TOPLEFT, 16, 13)
            hud.cardTitle:ClearAnchors()
            hud.cardTitle:SetDimensions(layout.cardWidth - 32, 66)
            hud.cardTitle:SetAnchor(TOPLEFT, hud.cardViewport, TOPLEFT, 16, 40)
            hud.cardInfoColumn:ClearAnchors()
            hud.cardInfoColumn:SetDimensions(cardColumnWidth, cardRuleTop - cardIconTop)
            hud.cardInfoColumn:SetAnchor(TOPLEFT, hud.cardViewport, TOPLEFT, 16, cardIconTop)
            hud.cardIcon:ClearAnchors()
            hud.cardIcon:SetDimensions(cardIconSize, cardIconSize)
            hud.cardIcon:SetAnchor(TOP, hud.cardInfoColumn, TOP, 0, 0)
            hud.cardIconLoading:ClearAnchors()
            hud.cardIconLoading:SetDimensions(cardIconSize, cardIconSize)
            hud.cardIconLoading:SetAnchor(TOP, hud.cardInfoColumn, TOP, 0, 0)
            hud.cardMeta:ClearAnchors()
            hud.cardMeta:SetDimensions(cardColumnWidth, 44)
            hud.cardMeta:SetAnchor(TOPLEFT, hud.cardInfoColumn, TOPLEFT, 0, cardIconSize + 6)
            hud.cardDescription:ClearAnchors()
            hud.cardDescription:SetDimensions(cardColumnWidth, cardRuleTop - cardIconTop - 8)
            hud.cardDescription:SetAnchor(TOPRIGHT, hud.cardViewport, TOPRIGHT, -16, cardIconTop)
            hud.cardColumnRule:ClearAnchors()
            hud.cardColumnRule:SetDimensions(1, cardRuleTop - cardIconTop - 8)
            hud.cardColumnRule:SetAnchor(TOP, hud.cardViewport, TOP, 0, cardIconTop)
            hud.cardRule:ClearAnchors()
            hud.cardRule:SetDimensions(layout.cardWidth - 32, 1)
            hud.cardRule:SetAnchor(TOPLEFT, hud.cardViewport, TOPLEFT, 16, cardRuleTop)
            hud.cardIngredientsHeader:ClearAnchors()
            hud.cardIngredientsHeader:SetDimensions(layout.cardWidth - 32, 28)
            hud.cardIngredientsHeader:SetAnchor(TOPLEFT, hud.cardViewport, TOPLEFT, 16, ingredientsHeaderTop)
            hud.cardIngredients:ClearAnchors()
            hud.cardIngredients:SetDimensions(layout.cardWidth - 32, math.max(layout.viewportHeight - ingredientsTop - 42, 40))
            hud.cardIngredients:SetAnchor(TOPLEFT, hud.cardViewport, TOPLEFT, 16, ingredientsTop)
            hud.cardIngredientIndicators:ClearAnchors()
            hud.cardIngredientIndicators:SetDimensions(layout.cardWidth - 32, math.max(layout.viewportHeight - ingredientsTop - 42, 40))
            hud.cardIngredientIndicators:SetAnchor(TOPRIGHT, hud.cardViewport, TOPRIGHT, -16, ingredientsTop)
            hud.cardPriceLegend:ClearAnchors()
            hud.cardPriceLegend:SetDimensions(layout.cardWidth - 32, 24)
            hud.cardPriceLegend:SetAnchor(BOTTOMRIGHT, hud.cardViewport, BOTTOMRIGHT, -16, -10)
            hud.cardPriceLegendIcon:SetDimensions(18, 18)
            hud.cardIngredientsContentWidth = layout.cardWidth - 32
        end
    end

    hud.upArrow:ClearAnchors()
    hud.upArrow:SetDimensions(24, 24)
    hud.upArrow:SetAnchor(RIGHT, hud.recipeHeader, RIGHT, -3, 0)
    hud.downArrow:ClearAnchors()
    hud.downArrow:SetDimensions(24, 24)
    hud.downArrow:SetAnchor(BOTTOMRIGHT, hud.recipeViewport, BOTTOMRIGHT, -3, -1)
    hud.footerDivider:ClearAnchors()
    hud.footerDivider:SetDimensions(layout.innerWidth, 1)
    hud.footerDivider:SetAnchor(BOTTOMLEFT, control, BOTTOMLEFT, C.PADDING, -(C.FOOTER_HEIGHT + 1))
    hud.hint:ClearAnchors()
    hud.hint:SetDimensions(layout.innerWidth, C.FOOTER_HEIGHT)
    hud.hint:SetAnchor(BOTTOMRIGHT, control, BOTTOMRIGHT, -C.PADDING, 0)
end

local function RenderTypeList(layout)
    local categoryCount = math.max(#categories, 1)
    local rowHeight = math.min(82, math.floor((layout.viewportHeight - (C.ROW_GAP * (categoryCount - 1))) / categoryCount))
    for index, category in ipairs(categories) do
        local row = EnsureTypeRow(index)
        local selected = index == selectedCategoryIndex
        row.control:SetHidden(false)
        row.control:ClearAnchors()
        row.control:SetDimensions(layout.typeWidth, rowHeight)
        row.control:SetAnchor(TOPLEFT, hud.typeViewport, TOPLEFT, 0, (index - 1) * (rowHeight + C.ROW_GAP))
        row.background:SetCenterColor(selected and COLORS.selected[1] or COLORS.panelAlt[1], selected and COLORS.selected[2] or COLORS.panelAlt[2], selected and COLORS.selected[3] or COLORS.panelAlt[3], selected and 0.92 or 0.68)
        row.accent:SetHidden(not selected)
        row.accent:ClearAnchors()
        row.accent:SetDimensions(5, rowHeight)
        row.accent:SetAnchor(TOPLEFT, row.control, TOPLEFT, 0, 0)
        row.name:ClearAnchors()
        row.name:SetDimensions(layout.typeWidth - 90, rowHeight - 15)
        row.name:SetAnchor(TOPLEFT, row.control, TOPLEFT, 12, 1)
        row.name:SetText(category.label)
        row.count:ClearAnchors()
        row.count:SetDimensions(72, rowHeight - 15)
        row.count:SetAnchor(TOPRIGHT, row.control, TOPRIGHT, -10, 1)
        row.count:SetText(string.format("%d/%d", category.known, category.total))
        row.progressBackground:ClearAnchors()
        row.progressBackground:SetDimensions(layout.typeWidth - 24, 3)
        row.progressBackground:SetAnchor(BOTTOMLEFT, row.control, BOTTOMLEFT, 12, -8)
        row.progress:ClearAnchors()
        row.progress:SetDimensions(layout.typeWidth - 24, 3)
        row.progress:SetAnchor(BOTTOMLEFT, row.control, BOTTOMLEFT, 12, -8)
        row.progress:SetMinMax(0, math.max(category.total, 1))
        row.progress:SetValue(category.known)
        SetColor(row.progress, category.total > 0 and category.known >= category.total and COLORS.complete or COLORS.accentSoft)
    end
    for index = #categories + 1, #(hud.typeRows or {}) do
        hud.typeRows[index].control:SetHidden(true)
    end
end

local function KeepSelectionVisible(layout)
    local previousFirstIndex = visibleFirstIndex
    local selectedRecord = GetSelectedRecord()
    local selectedEntryIndex = selectedRecord and recipeEntryIndices[GetRecordKey(selectedRecord)] or 1
    if selectedEntryIndex < visibleFirstIndex then
        visibleFirstIndex = selectedEntryIndex
        if listEntries[visibleFirstIndex - 1] and listEntries[visibleFirstIndex - 1].isHeader then
            visibleFirstIndex = visibleFirstIndex - 1
        end
    elseif selectedEntryIndex >= visibleFirstIndex + layout.visibleRows then
        visibleFirstIndex = selectedEntryIndex - layout.visibleRows + 1
    end
    visibleFirstIndex = Clamp(visibleFirstIndex, 1, math.max(#listEntries - layout.visibleRows + 1, 1))
    return visibleFirstIndex ~= previousFirstIndex
end

local function SetRecipeRowSelected(row, selected)
    row.accent:SetHidden(not selected)
    row.background:SetCenterColor(
        selected and COLORS.selected[1] or COLORS.panelAlt[1],
        selected and COLORS.selected[2] or COLORS.panelAlt[2],
        selected and COLORS.selected[3] or COLORS.panelAlt[3],
        selected and 0.92 or 0.68
    )
end

local function SetRecipeNameColor(control, record)
    if record and GetItemQualityColor and record.displayQuality then
        control:SetColor(GetItemQualityColor(record.displayQuality):UnpackRGBA())
    else
        SetColor(control, COLORS.cardGold)
    end
end

local function RenderRecipeList(layout)
    KeepSelectionVisible(layout)
    local selectedRecord = GetSelectedRecord()
    local selectedKey = selectedRecord and GetRecordKey(selectedRecord)
    hud.selectedRecipeRow = nil
    for displayIndex = 1, layout.visibleRows do
        local row = EnsureRecipeRow(displayIndex)
        local entry = listEntries[visibleFirstIndex + displayIndex - 1]
        row.entry = entry
        if not entry then
            NQOL.Util.ReleaseContentTexture(row.icon)
            row.control:SetHidden(true)
        else
            local isHeader = entry.isHeader == true
            local selected = not isHeader and GetRecordKey(entry) == selectedKey
            if selected then hud.selectedRecipeRow = row end
            row.control:SetHidden(false)
            row.control:ClearAnchors()
            row.control:SetDimensions(layout.recipeWidth, layout.rowHeight)
            row.control:SetAnchor(TOPLEFT, hud.recipeViewport, TOPLEFT, 0, (displayIndex - 1) * (layout.rowHeight + C.ROW_GAP))
            row.background:SetHidden(isHeader)
            row.accent:SetHidden(not selected)
            row.header:SetHidden(not isHeader)
            local showIcon = not isHeader and entry.icon and entry.icon ~= ""
            row.name:SetHidden(isHeader)
            row.status:SetHidden(isHeader)
            if isHeader then
                NQOL.Util.ReleaseContentTexture(row.icon)
                row.header:ClearAnchors()
                row.header:SetDimensions(layout.recipeWidth - 16, layout.rowHeight)
                row.header:SetAnchor(LEFT, row.control, LEFT, 8, 0)
                row.header:SetText(entry.label)
            else
                SetRecipeRowSelected(row, selected)
                row.accent:ClearAnchors()
                row.accent:SetDimensions(5, layout.rowHeight)
                row.accent:SetAnchor(TOPLEFT, row.control, TOPLEFT, 0, 0)
                if showIcon then
                    row.icon:ClearAnchors()
                    row.icon:SetDimensions(layout.rowHeight - 12, layout.rowHeight - 12)
                    row.icon:SetAnchor(LEFT, row.control, LEFT, 9, 0)
                    row.iconLoading:ClearAnchors()
                    row.iconLoading:SetDimensions(layout.rowHeight - 12, layout.rowHeight - 12)
                    row.iconLoading:SetAnchor(LEFT, row.control, LEFT, 9, 0)
                    if row.icon.SetDesaturation then row.icon:SetDesaturation(0) end
                    if row.icon.nqolRequestedTexturePath ~= entry.icon then
                        NQOL.Util.LoadContentTexture(row.icon, entry.icon)
                    end
                else
                    NQOL.Util.ReleaseContentTexture(row.icon)
                end
                local iconOffset = showIcon and layout.rowHeight or 12
                row.name:ClearAnchors()
                row.name:SetDimensions(layout.recipeWidth - iconOffset - 94, layout.rowHeight)
                row.name:SetAnchor(LEFT, row.control, LEFT, iconOffset, 0)
                row.name:SetText(entry.name)
                SetRecipeNameColor(row.name, entry)
                row.status:ClearAnchors()
                row.status:SetDimensions(80, layout.rowHeight)
                row.status:SetAnchor(RIGHT, row.control, RIGHT, -10, 0)
                row.status:SetText(entry.known and NQOL.L("common.known") or NQOL.L("common.unknown"))
                SetColor(row.status, entry.known and COLORS.complete or COLORS.missing)
            end
        end
    end
    hud.upArrow:SetHidden(visibleFirstIndex <= 1)
    hud.downArrow:SetHidden(visibleFirstIndex + layout.visibleRows - 1 >= #listEntries)
    hud.empty:SetHidden(#filteredRecords > 0)
    if #filteredRecords == 0 then
        local definition = activePage and PAGE_DEFINITIONS[activePage.key]
        local searchText = searchTextByPage[activePageKey] or ""
        if searchText ~= "" then
            hud.empty:SetText(NQOL.L("collections.no_search_results", definition and definition.itemPlural or NQOL.L("common.items"), searchText))
        else
            hud.empty:SetText(NQOL.L("collections.no_filter_results", definition and definition.itemPlural or NQOL.L("common.items")))
        end
        hud.empty:ClearAnchors()
        hud.empty:SetDimensions(layout.recipeWidth - 30, 80)
        hud.empty:SetAnchor(CENTER, hud.recipeViewport, CENTER, 0, 0)
    end
end

local function RenderRecipeListSelection(layout)
    if KeepSelectionVisible(layout) then
        RenderRecipeList(layout)
        return
    end
    local selectedRecord = GetSelectedRecord()
    local selectedRow
    for _, row in ipairs(hud.recipeRows or {}) do
        if row.entry == selectedRecord then
            selectedRow = row
            break
        end
    end
    if hud.selectedRecipeRow and hud.selectedRecipeRow ~= selectedRow then SetRecipeRowSelected(hud.selectedRecipeRow, false) end
    if selectedRow and hud.selectedRecipeRow ~= selectedRow then SetRecipeRowSelected(selectedRow, true) end
    hud.selectedRecipeRow = selectedRow
end

local function GetQualityName(quality, fallback)
    if quality and GetString then
        local name = GetString("SI_ITEMDISPLAYQUALITY", quality)
        if name and name ~= "" then return name end
    end
    return fallback or NQOL.L("collections.recipes.recipe")
end

local function GetIngredientDisplayInfo(record, ingredientIndex)
    local ingredientName
    local ingredientItemLink
    local requiredQuantity
    if GetRecipeIngredientItemInfo then
        ingredientName, _, requiredQuantity = GetRecipeIngredientItemInfo(record.listIndex, record.recipeIndex, ingredientIndex)
    end

    if GetRecipeIngredientItemLink then
        ingredientItemLink = GetRecipeIngredientItemLink(record.listIndex, record.recipeIndex, ingredientIndex, LINK_STYLE_DEFAULT)
        if ingredientItemLink == "" then ingredientItemLink = nil end
        if (not ingredientName or ingredientName == "") and ingredientItemLink and GetItemLinkName then
            ingredientName = GetItemLinkName(ingredientItemLink)
        end
    end

    if GetRecipeIngredientRequiredQuantity then
        local quantity = GetRecipeIngredientRequiredQuantity(record.listIndex, record.recipeIndex, ingredientIndex)
        if quantity and quantity > 0 then
            requiredQuantity = quantity
        end
    end

    if not ingredientItemLink or not ingredientName or ingredientName == "" or not requiredQuantity or requiredQuantity <= 0 then
        local recipeItemLink = GetRecipeItemLink(record)
        if recipeItemLink then
            if GetItemLinkRecipeIngredientInfo then
                local linkedName, _, linkedQuantity = GetItemLinkRecipeIngredientInfo(recipeItemLink, ingredientIndex)
                if linkedName and linkedName ~= "" then
                    ingredientName = linkedName
                end
                if linkedQuantity and linkedQuantity > 0 then
                    requiredQuantity = linkedQuantity
                end
            end

            if not ingredientItemLink and GetItemLinkRecipeIngredientItemLink then
                ingredientItemLink = GetItemLinkRecipeIngredientItemLink(recipeItemLink, ingredientIndex, LINK_STYLE_DEFAULT)
                if ingredientItemLink == "" then ingredientItemLink = nil end
                if (not ingredientName or ingredientName == "") and ingredientItemLink and GetItemLinkName then
                    ingredientName = GetItemLinkName(ingredientItemLink)
                end
            end
        end
    end

    if not ingredientName or ingredientName == "" then
        ingredientName = NQOL.L("collections.recipes.unknown_ingredient")
    end
    return FormatName(ingredientName), tonumber(requiredQuantity) or 0, ingredientItemLink
end

local function GetIngredientInventoryCount(itemLink)
    if not itemLink or not GetItemLinkStacks then return 0 end
    local backpackCount, bankCount, craftBagCount = GetItemLinkStacks(itemLink)
    return (tonumber(backpackCount) or 0) + (tonumber(bankCount) or 0) + (tonumber(craftBagCount) or 0)
end

local function FormatIngredientNumber(value)
    value = math.max(math.floor((tonumber(value) or 0) + 0.5), 0)
    return ZO_CommaDelimitNumber and ZO_CommaDelimitNumber(value) or tostring(value)
end

local function FormatIngredientInventoryCount(count)
    count = math.max(math.floor((tonumber(count) or 0) + 0.5), 0)
    local color = count > 0 and INGREDIENT_COUNT_AVAILABLE_COLOR or INGREDIENT_COUNT_MISSING_COLOR
    return string.format("|c%s%s %s|r", color, INGREDIENT_COUNT_ICON_MARKUP, FormatIngredientNumber(count))
end

local function GetTSCPriceAPI()
    local priceApi = rawget(_G, "TSCPriceDataAPI")
    if type(priceApi) == "table" and type(priceApi.GetItemData) == "function" then
        return priceApi
    end
    return nil
end

local function FormatIngredientPrice(priceApi, itemLink)
    if not priceApi or not itemLink then return nil end
    local succeeded, itemData = pcall(priceApi.GetItemData, priceApi, itemLink)
    if not succeeded or itemData == priceApi.LOADING or type(itemData) ~= "table" then return nil end
    local minimum = tonumber(itemData.commonMin or itemData.legacyMin)
    local average = tonumber(itemData.avgPrice or itemData.legacyAvg)
    local maximum = tonumber(itemData.commonMax or itemData.legacyMax)
    if not minimum or not average or not maximum then return nil end

    return string.format(
        "%s %s/%s/%s",
        INGREDIENT_PRICE_ICON_MARKUP,
        FormatIngredientNumber(minimum),
        FormatIngredientNumber(average),
        FormatIngredientNumber(maximum)
    )
end

local function RenderRecipeIngredients(record)
    local definition = activePage and PAGE_DEFINITIONS[activePage.key] or PAGE_DEFINITIONS.food
    local priceApi = GetTSCPriceAPI()
    local hasPriceData = false
    ClearTable(ingredientLines)
    ClearTable(ingredientIndicatorLines)
    if record and record.known ~= true and not GetLibRecipe() then
        ingredientLines[1] = NQOL.L("collections.recipes.librecipe_required")
    elseif record then
        for ingredientIndex = 1, record.numIngredients do
            local ingredientName, requiredQuantity, ingredientItemLink = GetIngredientDisplayInfo(record, ingredientIndex)
            local inventoryCount = GetIngredientInventoryCount(ingredientItemLink)
            local indicatorText = FormatIngredientInventoryCount(inventoryCount)
            local priceText = FormatIngredientPrice(priceApi, ingredientItemLink)
            if priceText then
                indicatorText = string.format("%s  %s", indicatorText, priceText)
                hasPriceData = true
            end
            ingredientLines[#ingredientLines + 1] = string.format("• %s  ×%d", ingredientName, requiredQuantity)
            ingredientIndicatorLines[#ingredientIndicatorLines + 1] = indicatorText
        end
    end
    if #ingredientLines == 0 then
        ingredientLines[1] = record and NQOL.L("collections.recipes.no_ingredients") or NQOL.L("collections.recipes.select_ingredients", definition.itemSingular)
    end
    hud.cardIngredients:SetText(table.concat(ingredientLines, "\n"))
    hud.cardIngredientIndicators:SetText(table.concat(ingredientIndicatorLines, "\n"))
    hud.cardPriceLegend:SetText(NQOL.L("features.collections_recipes.price_legend"))
    local legendTextWidth = hud.cardPriceLegend.GetTextWidth and math.ceil(hud.cardPriceLegend:GetTextWidth()) or 120
    hud.cardPriceLegendIcon:ClearAnchors()
    hud.cardPriceLegendIcon:SetAnchor(RIGHT, hud.cardPriceLegend, RIGHT, -(legendTextWidth + 5), 0)
    hud.cardPriceLegendIcon:SetHidden(not hasPriceData)
    hud.cardPriceLegend:SetHidden(not hasPriceData)
    local contentWidth = math.max(tonumber(hud.cardIngredientsContentWidth) or 1, 1)
    if #ingredientIndicatorLines > 0 then
        local measuredWidth = hud.cardIngredientIndicators.GetTextWidth and math.ceil(hud.cardIngredientIndicators:GetTextWidth()) or math.floor(contentWidth * 0.45)
        local indicatorWidth = Clamp(measuredWidth + 8, 72, math.floor(contentWidth * 0.58))
        hud.cardIngredients:SetWidth(math.max(contentWidth - indicatorWidth - 8, 1))
        hud.cardIngredientIndicators:SetWidth(indicatorWidth)
        hud.cardIngredientIndicators:SetHidden(false)
    else
        hud.cardIngredients:SetWidth(contentWidth)
        hud.cardIngredientIndicators:SetHidden(true)
    end
end

local function GetRecipeResultDescription(record)
    local itemLink = GetRecipeResultLink(record)
    if not itemLink then return "" end
    local descriptionParts = {}
    if GetItemLinkOnUseAbilityInfo then
        local hasAbility, abilityHeader, abilityDescription, cooldown = GetItemLinkOnUseAbilityInfo(itemLink)
        if hasAbility and abilityDescription and abilityDescription ~= "" then
            if abilityHeader and abilityHeader ~= "" and zo_strformat and SI_ABILITY_TOOLTIP_DESCRIPTION_HEADER then
                descriptionParts[#descriptionParts + 1] = zo_strformat(SI_ABILITY_TOOLTIP_DESCRIPTION_HEADER, abilityHeader)
            end
            if zo_strformat and SI_ITEM_FORMAT_STR_ON_USE then
                if (tonumber(cooldown) or 0) > 0 and SI_ITEM_FORMAT_STR_ON_USE_COOLDOWN and ZO_FormatTimeMilliseconds then
                    local cooldownText = ZO_FormatTimeMilliseconds(cooldown, TIME_FORMAT_STYLE_DESCRIPTIVE_MINIMAL_HIDE_ZEROES, TIME_FORMAT_PRECISION_SECONDS)
                    abilityDescription = zo_strformat(SI_ITEM_FORMAT_STR_ON_USE_COOLDOWN, abilityDescription, cooldownText)
                else
                    abilityDescription = zo_strformat(SI_ITEM_FORMAT_STR_ON_USE, abilityDescription)
                end
            end
            descriptionParts[#descriptionParts + 1] = abilityDescription
        end
    end
    if GetItemLinkFlavorText then
        local flavorText = GetItemLinkFlavorText(itemLink)
        if flavorText and flavorText ~= "" then
            descriptionParts[#descriptionParts + 1] = flavorText
        end
    end
    return table.concat(descriptionParts, "\n\n")
end

local function RenderRecipeCard(record)
    if not hud.cardViewport then return end
    if not GetSettings().recipeCard then
        NQOL.Util.ReleaseContentTexture(hud.cardIcon)
        return
    end
    local definition = activePage and PAGE_DEFINITIONS[activePage.key] or PAGE_DEFINITIONS.food
    local itemName = NQOL.Util.Upper(definition.itemSingular)
    hud.cardEyebrow:SetText(record and ((record.known and NQOL.L("common.known") or NQOL.L("common.unknown")) .. " " .. itemName) or NQOL.L("collections.recipes.no_selection", itemName))
    SetColor(hud.cardEyebrow, record and (record.known and COLORS.complete or COLORS.missing) or COLORS.cardMuted)
    hud.cardTitle:SetText(Uppercase(record and record.name or NQOL.L("collections.recipes.no_selected", definition.itemSingular)))
    SetRecipeNameColor(hud.cardTitle, record)
    local showIcon = record and record.icon and record.icon ~= ""
    if showIcon then
        if hud.cardIcon.SetDesaturation then hud.cardIcon:SetDesaturation(0) end
        if hud.cardIcon.nqolRequestedTexturePath ~= record.icon then
            NQOL.Util.LoadContentTexture(hud.cardIcon, record.icon)
        end
    else
        NQOL.Util.ReleaseContentTexture(hud.cardIcon)
    end
    local categoryText = record and record.isPlan and string.format("%s  •  %s", record.categoryLabel, record.listName) or (record and record.listName)
    local qualityText = record and GetQualityName(record.displayQuality, record.isPlan and NQOL.L("collections.recipes.plan") or NQOL.L("collections.recipes.recipe"))
    hud.cardMeta:SetText(record and string.format("%s  •  %s", categoryText, qualityText) or "")
    hud.cardDescription:SetText(GetRecipeResultDescription(record))
    hud.cardIngredientsHeader:SetText(NQOL.L("features.collections_recipes.ingredients_6a78277"))
    RenderRecipeIngredients(record)
end

local function GetBindingIcon(actionName, fallback)
    if ZO_Keybindings_GetHighestPriorityBindingStringFromAction and KEYBIND_TEXT_OPTIONS_FULL_NAME and KEYBIND_TEXTURE_OPTIONS_EMBED_MARKUP then
        return ZO_Keybindings_GetHighestPriorityBindingStringFromAction(actionName, KEYBIND_TEXT_OPTIONS_FULL_NAME, KEYBIND_TEXTURE_OPTIONS_EMBED_MARKUP, true, false, 100) or fallback
    end
    return fallback
end

local function GetInputHint()
    local cacheKey = string.format("%s:%d", activePageKey, filterIndex)
    if inputHintTextCache[cacheKey] then return inputHintTextCache[cacheKey] end
    local stickIcon = NQOL.L("common.right_stick")
    if GetGamepadRightStickScrollIcon and zo_iconFormat then
        stickIcon = zo_iconFormat(GetGamepadRightStickScrollIcon(), 30, 30)
    end
    local leftShoulder = GetBindingIcon("UI_SHORTCUT_LEFT_SHOULDER", "L1")
    local rightShoulder = GetBindingIcon("UI_SHORTCUT_RIGHT_SHOULDER", "R1")
    local leftTrigger = GetBindingIcon("UI_SHORTCUT_LEFT_TRIGGER", "L2")
    local rightTrigger = GetBindingIcon("UI_SHORTCUT_RIGHT_TRIGGER", "R2")
    local rightStickClick = GetBindingIcon("UI_SHORTCUT_RIGHT_STICK", "R3")
    local leftStickClick = GetBindingIcon("UI_SHORTCUT_LEFT_STICK", "L3")
    local definition = activePage and PAGE_DEFINITIONS[activePage.key] or PAGE_DEFINITIONS.food
    if USE_LETTER_GROUPS then
        inputHintTextCache[cacheKey] = NQOL.L("collections.recipes.input_hint", leftShoulder, rightShoulder, leftTrigger, rightTrigger, leftStickClick, rightStickClick, GetFilterLabel(), stickIcon, definition.itemPlural)
    else
        inputHintTextCache[cacheKey] = NQOL.L("collections.recipes.input_hint_flat", leftShoulder, rightShoulder, leftStickClick, rightStickClick, GetFilterLabel(), stickIcon, definition.itemPlural)
    end
    return inputHintTextCache[cacheKey]
end

local function RenderHud()
    if not EnsureHud() then return end
    local control = hud.control
    if not dataReady then BuildRecipeRecords() end
    local layout = GetLayout()
    LayoutHud(layout)
    ApplyPosition(layout)

    local category = categories[selectedCategoryIndex]
    local pageTitle = Uppercase(activePage and activePage.label or NQOL.L("collections.recipes.items"))
    local searchText = searchTextByPage[activePageKey] or ""
    if searchText ~= "" then
        pageTitle = string.format("%s (%s)", pageTitle, searchText)
    end
    hud.title:SetText(pageTitle)
    hud.typeHeader:SetText(NQOL.L("features.collections_recipes.categories_e520869"))
    hud.recipeHeader:SetText(category and Uppercase(category.label) or NQOL.L("collections.recipes.items"))
    hud.recipeSubheader:SetText(NQOL.L("common.shown", #filteredRecords))
    hud.hint:SetText(GetInputHint())
    RenderTypeList(layout)
    RenderRecipeList(layout)
    RenderRecipeCard(GetSelectedRecord())
    control:SetHidden(false)
    RefreshInputActivation()
    RefreshHudKeybinds()
end

local function RenderSelection()
    if not hud or not hud.layout then
        RenderHud()
        return
    end
    RenderRecipeListSelection(hud.layout)
    RenderRecipeCard(GetSelectedRecord())
end

local function HideHud()
    if not hud then return end
    for _, row in ipairs(hud.recipeRows or {}) do
        NQOL.Util.ReleaseContentTexture(row.icon)
    end
    if hud.cardIcon then NQOL.Util.ReleaseContentTexture(hud.cardIcon) end
    hud.control:SetHidden(true)
    hud.inputDirection = 0
    hud.nextInputAt = 0
    if DIRECTIONAL_INPUT and DIRECTIONAL_INPUT.IsListening and DIRECTIONAL_INPUT:IsListening(hud) then
        DIRECTIONAL_INPUT:Deactivate(hud)
    end
    RefreshHudKeybinds()
end

ApplyPosition = function(layout)
    if not hud or not hud.control then return end
    layout = layout or GetLayout()
    local settings = GetSettings()
    local maxX = math.max(layout.screenWidth - (layout.width * layout.scale), 0)
    local maxY = math.max(layout.screenHeight - (layout.height * layout.scale), 0)
    hud.control:ClearAnchors()
    hud.control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, maxX * (settings.horizontalPosition / 100), maxY * (settings.verticalPosition / 100))
end

RefreshInputActivation = function()
    if not hud or not DIRECTIONAL_INPUT then return end
    local listening = DIRECTIONAL_INPUT.IsListening and DIRECTIONAL_INPUT:IsListening(hud)
    local shouldListen = not hud.control:IsHidden() and not searchDialogOpen and #filteredRecords > 1
    if shouldListen and not listening then
        DIRECTIONAL_INPUT:Activate(hud, hud.control)
    elseif not shouldListen and listening then
        DIRECTIONAL_INPUT:Deactivate(hud)
    end
end

local function MoveSelection(delta)
    if #filteredRecords == 0 then return end
    local nextIndex = Clamp(selectedRecipeIndex + (delta > 0 and 1 or -1), 1, #filteredRecords)
    if nextIndex == selectedRecipeIndex then return end
    selectedRecipeIndex = nextIndex
    GetSettings().selectedRecipeIds[activePageKey] = filteredRecords[selectedRecipeIndex].resultItemId
    RenderSelection()
    if PlaySound and SOUNDS and SOUNDS.GAMEPAD_MENU_DOWN then
        PlaySound(delta > 0 and SOUNDS.GAMEPAD_MENU_DOWN or SOUNDS.GAMEPAD_MENU_UP)
    end
end

local function ChangeCategory(delta)
    local nextCategoryIndex = Clamp(selectedCategoryIndex + delta, 1, #categories)
    if nextCategoryIndex == selectedCategoryIndex then return end
    selectedCategoryIndex = nextCategoryIndex
    local settings = GetSettings()
    settings.selectedCategories[activePageKey] = selectedCategoryIndex
    RebuildFilteredList(settings.selectedRecipeIds[activePageKey])
    RenderHud()
    if PlaySound and SOUNDS and SOUNDS.GAMEPAD_MENU_DOWN then
        PlaySound(delta > 0 and SOUNDS.GAMEPAD_MENU_DOWN or SOUNDS.GAMEPAD_MENU_UP)
    end
end

local function ChangeLetterGroup(delta)
    local record = GetSelectedRecord()
    if not record or #letterGroups < 2 then return end
    local nextGroupIndex = Clamp((record.groupIndex or 1) + delta, 1, #letterGroups)
    if nextGroupIndex == record.groupIndex then return end
    local group = letterGroups[nextGroupIndex]
    selectedRecipeIndex = group.startIndex
    visibleFirstIndex = group.entryIndex
    GetSettings().selectedRecipeIds[activePageKey] = filteredRecords[selectedRecipeIndex].resultItemId
    RenderHud()
    if PlaySound and SOUNDS and SOUNDS.GAMEPAD_MENU_DOWN then
        PlaySound(delta > 0 and SOUNDS.GAMEPAD_MENU_DOWN or SOUNDS.GAMEPAD_MENU_UP)
    end
end

local function CycleFilter()
    local selectedRecord = GetSelectedRecord()
    local preferredRecipeId = selectedRecord and selectedRecord.resultItemId or GetSettings().selectedRecipeIds[activePageKey]
    filterIndex = (filterIndex % #FILTERS) + 1
    RebuildFilteredList(preferredRecipeId)
    RenderHud()
    if PlaySound and SOUNDS and SOUNDS.GAMEPAD_MENU_DOWN then PlaySound(SOUNDS.GAMEPAD_MENU_DOWN) end
end

local function TrimSearchText(value)
    local text = tostring(value or "")
    if zo_strtrim then return zo_strtrim(text) end
    return string.match(text, "^%s*(.-)%s*$") or ""
end

local function ApplySearch(pageKey, value)
    if not PAGE_DEFINITIONS[pageKey] then return end
    local selectedRecord = GetSelectedRecord()
    local preferredRecipeId = selectedRecord and selectedRecord.resultItemId or GetSettings().selectedRecipeIds[pageKey]
    local searchText = TrimSearchText(value)
    searchTextByPage[pageKey] = searchText
    searchNeedleByPage[pageKey] = NQOL.Util.Lower(searchText)
    if activePageKey == pageKey then
        RebuildFilteredList(preferredRecipeId)
        Refresh()
    end
end

local function ReleaseSearchDialog()
    if ZO_Dialogs_ReleaseDialogOnButtonPress then
        ZO_Dialogs_ReleaseDialogOnButtonPress(C.SEARCH_DIALOG_NAME)
    elseif ZO_Dialogs_ReleaseDialog then
        ZO_Dialogs_ReleaseDialog(C.SEARCH_DIALOG_NAME)
    end
end

local function SetupSearchAction(control, data, selected, reselectingDuringRebuild, enabled, active)
    if ZO_SharedGamepadEntry_OnSetup then
        ZO_SharedGamepadEntry_OnSetup(control, data, selected, reselectingDuringRebuild, enabled, active)
    end
end

local function RegisterSearchDialog()
    if searchDialogRegistered or not ZO_Dialogs_RegisterCustomDialog or not GAMEPAD_DIALOGS then return end
    searchDialogRegistered = true
    ZO_Dialogs_RegisterCustomDialog(C.SEARCH_DIALOG_NAME, {
        gamepadInfo = {
            dialogType = GAMEPAD_DIALOGS.PARAMETRIC,
        },
        title = {
            text = function(dialog)
                local definition = dialog.data and PAGE_DEFINITIONS[dialog.data.pageKey]
                return NQOL.L("collections.recipes.search", definition and definition.label or NQOL.L("common.items"))
            end,
        },
        setup = function(dialog)
            dialog.data = dialog.data or {}
            local definition = PAGE_DEFINITIONS[dialog.data.pageKey] or PAGE_DEFINITIONS.food
            dialog.info.parametricList = {
                {
                    template = "ZO_Gamepad_GenericDialog_Parametric_TextFieldItem",
                    templateData = {
                        nameField = true,
                        textChangedCallback = function(editBox)
                            dialog.data.searchText = editBox:GetText()
                        end,
                        setup = function(control, data, selected)
                            if control.highlight then control.highlight:SetHidden(not selected) end
                            local editBox = control.editBoxControl
                            editBox.textChangedCallback = data.textChangedCallback
                            if editBox.SetMaxInputChars then editBox:SetMaxInputChars(50) end
                            if editBox.SetDefaultText then editBox:SetDefaultText(NQOL.L("collections.search_name_placeholder", definition.itemSingular)) end
                            editBox:SetText(dialog.data.searchText or "")
                            data.control = control
                        end,
                        callback = function(dialogRef)
                            local targetData = dialogRef.entryList:GetTargetData()
                            local editBox = targetData and targetData.control and targetData.control.editBoxControl
                            if editBox and editBox.TakeFocus then editBox:TakeFocus() end
                        end,
                        narrationText = ZO_GetDefaultParametricListEditBoxNarrationText,
                    },
                },
                {
                    template = "ZO_GamepadTextFieldSubmitItem",
                    templateData = {
                        text = NQOL.L("features.collections_recipes.apply_search_96b8b79"),
                        setup = SetupSearchAction,
                        callback = function(dialogRef)
                            local data = dialogRef.data or {}
                            ApplySearch(data.pageKey, data.searchText or "")
                            ReleaseSearchDialog()
                        end,
                    },
                },
                {
                    template = "ZO_GamepadTextFieldSubmitItem",
                    templateData = {
                        text = NQOL.L("features.collections_recipes.clear_search_87e328d"),
                        setup = SetupSearchAction,
                        callback = function(dialogRef)
                            ApplySearch(dialogRef.data and dialogRef.data.pageKey, "")
                            ReleaseSearchDialog()
                        end,
                    },
                },
            }
            dialog:setupFunc()
        end,
        blockDialogReleaseOnPress = true,
        finishedCallback = function()
            searchDialogOpen = false
            RefreshInputActivation()
            RefreshHudKeybinds()
        end,
        buttons = {
            {
                keybind = "DIALOG_PRIMARY",
                text = SI_GAMEPAD_SELECT_OPTION,
                callback = function(dialog)
                    local targetData = dialog.entryList:GetTargetData()
                    if targetData and targetData.callback then targetData.callback(dialog) end
                end,
            },
            {
                keybind = "DIALOG_NEGATIVE",
                text = SI_DIALOG_CANCEL,
                callback = ReleaseSearchDialog,
            },
        },
    })
end

local function OpenSearchDialog()
    if not PAGE_DEFINITIONS[activePageKey] or not ZO_Dialogs_ShowGamepadDialog then return end
    RegisterSearchDialog()
    if not searchDialogRegistered then return end
    searchDialogOpen = true
    RefreshInputActivation()
    RefreshHudKeybinds()
    ZO_Dialogs_ShowGamepadDialog(C.SEARCH_DIALOG_NAME, {
        pageKey = activePageKey,
        searchText = searchTextByPage[activePageKey] or "",
    })
end

hudKeybindGroup = {
    {
        keybind = "UI_SHORTCUT_LEFT_SHOULDER",
        ethereal = true,
        callback = function() ChangeCategory(-1) end,
    },
    {
        keybind = "UI_SHORTCUT_RIGHT_SHOULDER",
        ethereal = true,
        callback = function() ChangeCategory(1) end,
    },
    {
        keybind = "UI_SHORTCUT_LEFT_TRIGGER",
        ethereal = true,
        visible = function() return USE_LETTER_GROUPS end,
        callback = function() ChangeLetterGroup(-1) end,
    },
    {
        keybind = "UI_SHORTCUT_RIGHT_TRIGGER",
        ethereal = true,
        visible = function() return USE_LETTER_GROUPS end,
        callback = function() ChangeLetterGroup(1) end,
    },
    {
        keybind = "UI_SHORTCUT_RIGHT_STICK",
        ethereal = true,
        callback = CycleFilter,
    },
    {
        name = function() return NQOL.L("common.search") end,
        keybind = "UI_SHORTCUT_LEFT_STICK",
        ethereal = true,
        callback = OpenSearchDialog,
    },
}

RefreshHudKeybinds = function()
    if not KEYBIND_STRIP or not hudKeybindGroup then return end
    local shouldBeActive = hud and hud.control and not hud.control:IsHidden() and not searchDialogOpen
    if shouldBeActive and not hudKeybindsActive then
        KEYBIND_STRIP:AddKeybindButtonGroup(hudKeybindGroup)
        hudKeybindsActive = true
    elseif shouldBeActive and hudKeybindsActive and KEYBIND_STRIP.UpdateKeybindButtonGroup then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(hudKeybindGroup)
    elseif not shouldBeActive and hudKeybindsActive then
        KEYBIND_STRIP:RemoveKeybindButtonGroup(hudKeybindGroup)
        hudKeybindsActive = false
    end
end

function CollectionsRecipes.UpdateDirectionalInput()
    if not hud or hud.control:IsHidden() or not DIRECTIONAL_INPUT or not ZO_DI_RIGHT_STICK then return end
    local stickY = DIRECTIONAL_INPUT:GetY(ZO_DI_RIGHT_STICK) or 0
    if math.abs(stickY) <= C.INPUT_DEADZONE then
        hud.inputDirection = 0
        hud.nextInputAt = 0
        return
    end

    local direction = stickY < 0 and 1 or -1
    local now = GetFrameTimeMilliseconds and GetFrameTimeMilliseconds() or 0
    if direction ~= hud.inputDirection then
        hud.inputDirection = direction
        hud.nextInputAt = now + C.INPUT_INITIAL_DELAY_MS
        MoveSelection(direction)
    elseif now >= (hud.nextInputAt or 0) then
        hud.nextInputAt = now + C.INPUT_REPEAT_DELAY_MS
        MoveSelection(direction)
    end
    if DIRECTIONAL_INPUT.Consume then DIRECTIONAL_INPUT:Consume(ZO_DI_RIGHT_STICK) end
end

Refresh = function()
    if not settingsPanelVisible then
        HideHud()
        return
    end
    RenderHud()
end

local function ClearRecipeData()
    dataReady = false
    ClearTable(recipePages)
    activePage = nil
    categories = {}
    ClearTable(filteredRecords)
    ClearTable(letterGroups)
    ClearTable(letterGroupPool)
    ClearTable(listEntries)
    ClearTable(recipeEntryIndices)
    ClearTable(ingredientLines)
    ClearTable(ingredientIndicatorLines)
    selectedCategoryIndex = 1
    selectedRecipeIndex = 0
    visibleFirstIndex = 1
    if hud then
        hud.selectedRecipeRow = nil
        for _, row in ipairs(hud.recipeRows or {}) do
            row.entry = nil
        end
    end
end

function CollectionsRecipes.InitializeSavedVariables()
    savedVariables = NQOL.Settings.NewAccountWide(defaults)
    GetSettings()
end

function CollectionsRecipes.Initialize()
    if initialized then return end
    initialized = true
end

function CollectionsRecipes.SetSettingsPanelVisible(pageKey)
    local showing = PAGE_DEFINITIONS[pageKey] ~= nil
    if showing then
        if settingsPanelVisible and activePageKey == pageKey then return end
        settingsPanelVisible = true
        activePageKey = pageKey
        BuildRecipeRecords()
        Refresh()
        return
    end
    if not settingsPanelVisible then return end
    settingsPanelVisible = false
    if searchDialogOpen then ReleaseSearchDialog() end
    HideHud()
    ClearRecipeData()
end

function CollectionsRecipes.GetRecipeCard() return GetSettings().recipeCard end
function CollectionsRecipes.SetRecipeCard(value) GetSettings().recipeCard = value == true; Refresh() end
function CollectionsRecipes.GetHorizontalPosition() return GetSettings().horizontalPosition end
function CollectionsRecipes.SetHorizontalPosition(value) GetSettings().horizontalPosition = Clamp(value, 0, 100); ApplyPosition() end
function CollectionsRecipes.GetVerticalPosition() return GetSettings().verticalPosition end
function CollectionsRecipes.SetVerticalPosition(value) GetSettings().verticalPosition = Clamp(value, 0, 100); ApplyPosition() end
function CollectionsRecipes.GetFontChoices() return NQOL.Util.GetFontChoices() end
function CollectionsRecipes.GetFontChoiceNames() return NQOL.Util.GetFontChoiceNames() end
function CollectionsRecipes.GetFont() return GetSettings().font end
function CollectionsRecipes.SetFont(value) if not NQOL.Util.IsFontChoice(value) then value = NQOL.Util.GetDefaultFont() end; GetSettings().font = value; fontStringCache = {}; ApplyFonts(); Refresh() end
function CollectionsRecipes.GetScale() return GetSettings().scale end
function CollectionsRecipes.SetScale(value) GetSettings().scale = Clamp(Round(value), C.SCALE_MIN, C.SCALE_MAX); Refresh() end
function CollectionsRecipes.GetScaleMin() return C.SCALE_MIN end
function CollectionsRecipes.GetScaleMax() return C.SCALE_MAX end
function CollectionsRecipes.GetBackgroundOpacity() return GetSettings().backgroundOpacity end
function CollectionsRecipes.SetBackgroundOpacity(value) GetSettings().backgroundOpacity = Clamp(Round(value), C.BACKGROUND_OPACITY_MIN, C.BACKGROUND_OPACITY_MAX); ApplyBackground() end
function CollectionsRecipes.GetBackgroundOpacityMin() return C.BACKGROUND_OPACITY_MIN end
function CollectionsRecipes.GetBackgroundOpacityMax() return C.BACKGROUND_OPACITY_MAX end

function CollectionsRecipes.GetRecipeCardLabel() return NQOL.L("features.collections_recipes.recipe_card_label") end
function CollectionsRecipes.GetRecipeCardTooltip() return NQOL.L("features.collections_recipes.recipe_card_tooltip") end
function CollectionsRecipes.GetHorizontalPositionLabel() return NQOL.L("features.collections_recipes.horizontal_position_label") end
function CollectionsRecipes.GetHorizontalPositionTooltip() return NQOL.L("features.collections_recipes.horizontal_position_tooltip") end
function CollectionsRecipes.GetVerticalPositionLabel() return NQOL.L("features.collections_recipes.vertical_position_label") end
function CollectionsRecipes.GetVerticalPositionTooltip() return NQOL.L("features.collections_recipes.vertical_position_tooltip") end
function CollectionsRecipes.GetFontLabel() return NQOL.L("features.collections_recipes.font_label") end
function CollectionsRecipes.GetFontTooltip() return NQOL.L("features.collections_recipes.font_tooltip") end
function CollectionsRecipes.GetScaleLabel() return NQOL.L("features.collections_recipes.scale_label") end
function CollectionsRecipes.GetScaleTooltip() return NQOL.L("features.collections_recipes.scale_tooltip") end
function CollectionsRecipes.GetBackgroundOpacityLabel() return NQOL.L("features.collections_recipes.background_opacity_label") end
function CollectionsRecipes.GetBackgroundOpacityTooltip() return NQOL.L("features.collections_recipes.background_opacity_tooltip") end

NQOL.Features.CollectionsRecipes = CollectionsRecipes
