-- IngredientHunter
-- ESO Alchemy Recipe Browser & Ingredient Tracker
---------------------------------------------------------

local ADDON_NAME = "IngredientHunter"
IngredientHunter = {}
local IH = IngredientHunter

local BAGS_TO_SCAN = { BAG_BACKPACK, BAG_BANK }

-- Saved variables defaults
local SV_DEFAULTS = {
    posX = nil,
    posY = nil,
    trackerPosX = nil,
    trackerPosY = nil,
    trackerVisible = false,
    trackerRecipeIndex = nil,
    trackerComboIndex = 1,
    selectedSolventType = "potion",
    selectedSolventIndex = nil,
    lastRecipeIndex = nil,
    lang = nil,  -- nil = auto-detect from ESO client locale
}

-- Localization shortcut (set in Initialize)
IH.L = {}

-- Translate a data name (reagent / solvent / effect / recipe)
-- Returns the localized display name, or the original if no translation found.
function IH:TR(category, name)
    local map = self.L[category]
    if map then return map[name] or name end
    return name
end

-- State
IH.sv = nil
IH.inventoryCache = {}
IH.recipeRows = {}
IH.ingredientRows = {}
IH.selectedRecipe = nil
IH.selectedCombo = 1
IH.reagentLookup = {}
IH.filteredRecipes = {}
IH.trackerRows = {}
IH.trackerRecipe = nil
IH.trackerContainer = nil
IH.trackerCombo = 1
IH.controlId = 0
IH.recipeListBuilt = false
IH.iconCache = {}  -- itemId -> реальный путь иконки из ESO

---------------------------------------------------------
-- Utility
---------------------------------------------------------

local function HexColor(hex)
    local r = tonumber(hex:sub(1,2), 16) / 255
    local g = tonumber(hex:sub(3,4), 16) / 255
    local b = tonumber(hex:sub(5,6), 16) / 255
    local a = #hex >= 8 and (tonumber(hex:sub(7,8), 16) / 255) or 1
    return r, g, b, a
end

local function UniqueName(prefix)
    IH.controlId = IH.controlId + 1
    return prefix .. IH.controlId
end

---------------------------------------------------------
-- Inventory Scanning
---------------------------------------------------------

function IH:ScanInventory()
    self.inventoryCache = {}

    -- Обычные сумки: рюкзак, банк, банк подписки
    for _, bagId in ipairs(BAGS_TO_SCAN) do
        local slots = GetBagSize(bagId)
        for slot = 0, slots - 1 do
            local itemId = GetItemId(bagId, slot)
            if itemId and itemId > 0 then
                local stack = GetSlotStackSize(bagId, slot)
                if not self.inventoryCache[itemId] then
                    self.inventoryCache[itemId] = { backpack = 0, bank = 0, craftBag = 0, total = 0 }
                end
                local entry = self.inventoryCache[itemId]
                if bagId == BAG_BACKPACK then
                    entry.backpack = entry.backpack + stack
                else
                    entry.bank = entry.bank + stack
                end
                entry.total = entry.total + stack
                -- Захватываем реальный путь иконки из ESO
                if not self.iconCache[itemId] then
                    local link = GetItemLink(bagId, slot, LINK_STYLE_BRACKETS)
                    if link and link ~= "" then
                        local icon = GetItemLinkIcon(link)
                        if icon and icon ~= "" then
                            self.iconCache[itemId] = icon
                        end
                    end
                end
            end
        end
    end

    -- Ремесленная сумка: в BAG_VIRTUAL слот-индекс == itemId предмета,
    -- поэтому проверяем только наши известные реагенты и растворители напрямую
    self:ScanCraftBagKnownItems()
end

function IH:ScanCraftBagKnownItems()
    local function addCraftStack(itemId)
        -- BAG_VIRTUAL — виртуальный суммарный вид всех материалов (рюкзак+банк+крафт-сумка).
        -- Если предмет уже найден в физических сумках — пропускаем, иначе получим двойной счёт.
        if self.inventoryCache[itemId] then return end
        local stack = GetSlotStackSize(BAG_VIRTUAL, itemId)
        if stack and stack > 0 then
            self.inventoryCache[itemId] = { backpack = 0, bank = 0, craftBag = stack, total = stack }
            -- В BAG_VIRTUAL slot == itemId
            if not self.iconCache[itemId] then
                local link = GetItemLink(BAG_VIRTUAL, itemId, LINK_STYLE_BRACKETS)
                if link and link ~= "" then
                    local icon = GetItemLinkIcon(link)
                    if icon and icon ~= "" then
                        self.iconCache[itemId] = icon
                    end
                end
            end
        end
    end

    for _, reagent in ipairs(IngredientHunter_Data.reagents) do
        addCraftStack(reagent.itemId)
    end
    for _, solvent in ipairs(IngredientHunter_Data.solvents) do
        addCraftStack(solvent.itemId)
    end
end

function IH:GetItemCount(itemId)
    if self.inventoryCache[itemId] then
        return self.inventoryCache[itemId]
    end
    return { backpack = 0, bank = 0, craftBag = 0, total = 0 }
end

function IH:OnInventoryChanged()
    self:ScanInventory()
    if self.trackerRecipe and not IngredientHunterTracker:IsHidden() then
        self:RefreshTracker()
    end
    if self.selectedRecipe and IngredientHunterWindow and not IngredientHunterWindow:IsHidden() then
        self:RefreshIngredientPanel()
    end
end

function IH:UpdateSingleSlot(bagId, slotIndex)
    self:OnInventoryChanged()
end

---------------------------------------------------------
-- Reagent Lookup
---------------------------------------------------------

local function MakeItemLink(itemId)
    -- Минимальная ссылка на предмет: ESO хранит иконки клиентски для всех известных предметов
    return string.format("|H1:item:%d:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", itemId)
end

function IH:BuildReagentLookup()
    self.reagentLookup = {}
    for _, reagent in ipairs(IngredientHunter_Data.reagents) do
        -- Заполняем кэш иконок через ссылку на предмет (не нужно иметь предмет в инвентаре)
        if not self.iconCache[reagent.itemId] then
            local icon = GetItemLinkIcon(MakeItemLink(reagent.itemId))
            if icon and icon ~= "" then
                self.iconCache[reagent.itemId] = icon
            end
        end
        self.reagentLookup[reagent.name] = reagent
    end
    -- Заполняем кэш иконок для растворителей
    for _, solvent in ipairs(IngredientHunter_Data.solvents) do
        if not self.iconCache[solvent.itemId] then
            local icon = GetItemLinkIcon(MakeItemLink(solvent.itemId))
            if icon and icon ~= "" then
                self.iconCache[solvent.itemId] = icon
            end
        end
    end
end

---------------------------------------------------------
-- Solvent Helpers
---------------------------------------------------------

function IH:GetSolventsForType(solventType)
    local result = {}
    for _, s in ipairs(IngredientHunter_Data.solvents) do
        if s.type == solventType then
            table.insert(result, s)
        end
    end
    return result
end

function IH:GetHighestSolvent(solventType)
    local solvents = self:GetSolventsForType(solventType)
    if #solvents > 0 then
        return solvents[#solvents]
    end
    return nil
end

---------------------------------------------------------
-- UI: Recipe List (Left Panel)
---------------------------------------------------------

function IH:BuildRecipeList()
    local data = IngredientHunter_Data.recipes
    local leftPanel = IngredientHunterWindowLeftPanel
    if not leftPanel then return end

    -- Create scroll container once
    if not self.recipeScroll then
        local scroll = CreateControlFromVirtual("IH_RecipeScroll", leftPanel, "ZO_ScrollContainer")
        scroll:SetAnchor(TOPLEFT, leftPanel, TOPLEFT, 0, 0)
        scroll:SetAnchor(BOTTOMRIGHT, leftPanel, BOTTOMRIGHT, 0, 0)
        self.recipeScroll = scroll
        self.recipeScrollChild = scroll:GetNamedChild("ScrollChild")
    end

    local scrollChild = self.recipeScrollChild

    -- Clear old rows
    for _, row in ipairs(self.recipeRows) do
        row:SetHidden(true)
        row:SetParent(GuiRoot)
    end
    self.recipeRows = {}

    for i, recipe in ipairs(data) do
        local row = CreateControlFromVirtual(UniqueName("IH_RR_"), scrollChild, "IngredientHunter_RecipeRow")
        local nameLabel = row:GetNamedChild("Name")
        nameLabel:SetText(recipe.name)

        if recipe.solventType == "poison" then
            nameLabel:SetColor(HexColor("AA4A4A"))
        else
            nameLabel:SetColor(HexColor("C8B99A"))
        end

        nameLabel:SetText(IH:TR("recipe", recipe.name))
        row:SetWidth(scrollChild:GetWidth() > 0 and scrollChild:GetWidth() or 210)
        row:SetAnchor(TOPLEFT, scrollChild, TOPLEFT, 0, (i - 1) * 28)

        row:SetHandler("OnMouseEnter", function(control)
            local hl = control:GetNamedChild("Highlight")
            if hl then hl:SetHidden(false) end
        end)

        row:SetHandler("OnMouseExit", function(control)
            local hl = control:GetNamedChild("Highlight")
            if hl and IH.selectedRecipe ~= i then hl:SetHidden(true) end
        end)

        local recipeIndex = i
        row:SetHandler("OnMouseUp", function(control, mouseButton, upInside)
            if upInside and mouseButton == MOUSE_BUTTON_INDEX_LEFT then
                IH:SelectRecipe(recipeIndex)
            end
        end)

        self.recipeRows[i] = row
    end

    local totalHeight = #data * 28
    scrollChild:SetHeight(totalHeight)

    self.filteredRecipes = {}
    for i = 1, #data do
        table.insert(self.filteredRecipes, i)
    end
    self.recipeListBuilt = true
end

function IH:FilterRecipes(searchText)
    searchText = searchText:lower()
    local data = IngredientHunter_Data.recipes
    if not self.recipeScrollChild then return end

    local scrollChild = self.recipeScrollChild
    self.filteredRecipes = {}
    local visibleCount = 0

    for i, recipe in ipairs(data) do
        local row = self.recipeRows[i]
        if row then
            local match = searchText == "" or recipe.name:lower():find(searchText, 1, true)
            row:SetHidden(not match)
            if match then
                row:ClearAnchors()
                row:SetAnchor(TOPLEFT, scrollChild, TOPLEFT, 0, visibleCount * 28)
                visibleCount = visibleCount + 1
                table.insert(self.filteredRecipes, i)
            end
        end
    end

    scrollChild:SetHeight(math.max(visibleCount * 28, 1))
end

---------------------------------------------------------
-- UI: Ingredient Panel (Right Panel)
---------------------------------------------------------

function IH:ClearIngredientRows()
    for _, row in ipairs(self.ingredientRows) do
        row:SetHidden(true)
    end
    self.ingredientRows = {}
end

function IH:SelectRecipe(index)
    local recipe = IngredientHunter_Data.recipes[index]
    if not recipe then return end

    self.selectedRecipe = index
    self.selectedCombo = 1
    self.sv.lastRecipeIndex = index

    -- Highlight selected row
    for i, row in ipairs(self.recipeRows) do
        local hl = row:GetNamedChild("Highlight")
        if hl then
            if i == index then
                hl:SetHidden(false)
                hl:SetCenterColor(HexColor("C89B3C40"))
            else
                hl:SetHidden(true)
            end
        end
    end

    self:RefreshIngredientPanel()
end

function IH:RefreshIngredientPanel()
    local recipe = IngredientHunter_Data.recipes[self.selectedRecipe]
    if not recipe then return end

    -- Recipe name
    IngredientHunterWindowRightPanelRecipeName:SetText(IH:TR("recipe", recipe.name))

    -- Effects
    local translatedEffects = {}
    for _, eff in ipairs(recipe.effects) do
        table.insert(translatedEffects, IH:TR("effect", eff))
    end
    IngredientHunterWindowRightPanelEffects:SetText(
        IH.L.EFFECTS_LABEL .. table.concat(translatedEffects, ", "))

    -- Solvent
    local solvent = self:GetHighestSolvent(recipe.solventType)
    if solvent then
        local counts = self:GetItemCount(solvent.itemId)
        local colorTag = counts.total > 0 and "|c7DA85A" or "|cAA4444"
        IngredientHunterWindowRightPanelSolvent:SetText(
            string.format("%s%s  %s(%d)|r",
                IH.L.SOLVENT_LABEL, IH:TR("solvent", solvent.name), colorTag, counts.total))
    else
        IngredientHunterWindowRightPanelSolvent:SetText(IH.L.SOLVENT_UNKNOWN)
    end

    -- Combo label
    local numCombos = #recipe.reagentSets
    if numCombos > 1 then
        IngredientHunterWindowRightPanelComboLabel:SetText(
            string.format(IH.L.COMBO_FORMAT, self.selectedCombo, numCombos))
    else
        IngredientHunterWindowRightPanelComboLabel:SetText("")
    end

    -- Clear old ingredient rows
    self:ClearIngredientRows()

    local combo = recipe.reagentSets[self.selectedCombo]
    if not combo then return end

    -- Parent ingredient rows directly to the IngredientScroll control
    local rightScroll = IngredientHunterWindowRightPanelIngredientScroll
    if not rightScroll then return end

    local yOffset = 0

    -- Combo navigation buttons
    if numCombos > 1 then
        self:CreateComboNav(rightScroll, yOffset, numCombos)
        yOffset = yOffset + 32
    end

    -- Reagent rows
    for i, reagentName in ipairs(combo) do
        local reagent = self.reagentLookup[reagentName]
        if reagent then
            self:CreateIngredientRow(rightScroll, i, reagent, yOffset)
            yOffset = yOffset + 36
        end
    end

    -- All combos list
    if numCombos > 1 then
        yOffset = yOffset + 10
        local allCombosLabel = CreateControl(UniqueName("IH_AC_"), rightScroll, CT_LABEL)
        allCombosLabel:SetFont("ZoFontGameSmall")
        allCombosLabel:SetColor(HexColor("5A4A32"))
        allCombosLabel:SetText(IH.L.ALL_COMBOS_HDR)
        allCombosLabel:SetAnchor(TOPLEFT, rightScroll, TOPLEFT, 4, yOffset)
        allCombosLabel:SetDimensions(360, 18)
        table.insert(self.ingredientRows, allCombosLabel)
        yOffset = yOffset + 22

        for ci, c in ipairs(recipe.reagentSets) do
            local prefix = (ci == self.selectedCombo) and "|cC89B3C> " or "  "
            local suffix = (ci == self.selectedCombo) and "|r" or ""
            local translatedC = {}
            for _, rn in ipairs(c) do table.insert(translatedC, IH:TR("reagent", rn)) end
            local comboText = prefix .. table.concat(translatedC, " + ") .. suffix

            local label = CreateControl(UniqueName("IH_CL_"), rightScroll, CT_LABEL)
            label:SetFont("ZoFontGameSmall")
            label:SetColor(HexColor("9A8A6A"))
            label:SetText(comboText)
            label:SetAnchor(TOPLEFT, rightScroll, TOPLEFT, 4, yOffset)
            label:SetDimensions(360, 18)
            label:SetMouseEnabled(true)

            local comboIndex = ci
            label:SetHandler("OnMouseUp", function(control, mouseButton, upInside)
                if upInside and mouseButton == MOUSE_BUTTON_INDEX_LEFT then
                    IH.selectedCombo = comboIndex
                    IH:RefreshIngredientPanel()
                end
            end)
            label:SetHandler("OnMouseEnter", function(control)
                control:SetColor(HexColor("C89B3C"))
            end)
            label:SetHandler("OnMouseExit", function(control)
                control:SetColor(HexColor("9A8A6A"))
            end)

            table.insert(self.ingredientRows, label)
            yOffset = yOffset + 20
        end
    end
end

function IH:CreateComboNav(parent, yOffset, numCombos)
    local prevBtn = CreateControl(UniqueName("IH_PB_"), parent, CT_LABEL)
    prevBtn:SetFont("ZoFontGameBold")
    prevBtn:SetColor(HexColor("C89B3C"))
    prevBtn:SetText(IH.L.PREV_COMBO)
    prevBtn:SetAnchor(TOPLEFT, parent, TOPLEFT, 4, yOffset)
    prevBtn:SetDimensions(80, 28)
    prevBtn:SetMouseEnabled(true)
    prevBtn:SetHandler("OnMouseUp", function(_, mouseButton, upInside)
        if upInside and mouseButton == MOUSE_BUTTON_INDEX_LEFT then
            IH.selectedCombo = IH.selectedCombo - 1
            if IH.selectedCombo < 1 then IH.selectedCombo = numCombos end
            IH:RefreshIngredientPanel()
        end
    end)
    prevBtn:SetHandler("OnMouseEnter", function(c) c:SetColor(HexColor("FFFFFF")) end)
    prevBtn:SetHandler("OnMouseExit", function(c) c:SetColor(HexColor("C89B3C")) end)
    table.insert(self.ingredientRows, prevBtn)

    local nextBtn = CreateControl(UniqueName("IH_NB_"), parent, CT_LABEL)
    nextBtn:SetFont("ZoFontGameBold")
    nextBtn:SetColor(HexColor("C89B3C"))
    nextBtn:SetText(IH.L.NEXT_COMBO)
    nextBtn:SetAnchor(TOPLEFT, parent, TOPLEFT, 100, yOffset)
    nextBtn:SetDimensions(80, 28)
    nextBtn:SetMouseEnabled(true)
    nextBtn:SetHandler("OnMouseUp", function(_, mouseButton, upInside)
        if upInside and mouseButton == MOUSE_BUTTON_INDEX_LEFT then
            IH.selectedCombo = IH.selectedCombo + 1
            if IH.selectedCombo > numCombos then IH.selectedCombo = 1 end
            IH:RefreshIngredientPanel()
        end
    end)
    nextBtn:SetHandler("OnMouseEnter", function(c) c:SetColor(HexColor("FFFFFF")) end)
    nextBtn:SetHandler("OnMouseExit", function(c) c:SetColor(HexColor("C89B3C")) end)
    table.insert(self.ingredientRows, nextBtn)
end

function IH:CreateIngredientRow(parent, index, reagent, yOffset)
    local row = CreateControlFromVirtual(UniqueName("IH_IR_"), parent, "IngredientHunter_IngredientRow")
    row:ClearAnchors()
    row:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, yOffset)

    local icon = row:GetNamedChild("Icon")
    local iconPath = self.iconCache[reagent.itemId] or ""
    if iconPath ~= "" then
        icon:SetTexture(iconPath)
    end

    local nameLabel = row:GetNamedChild("Name")
    nameLabel:SetText(IH:TR("reagent", reagent.name))

    local countLabel = row:GetNamedChild("Count")
    local counts = self:GetItemCount(reagent.itemId)
    local clr = counts.total > 0 and "7DA85A" or "AA4444"

    -- Compact format: total in color + short breakdown
    local detail
    if counts.craftBag > 0 then
        detail = string.format(IH.L.BAG_FMT_3, counts.backpack, counts.bank, counts.craftBag)
    else
        detail = string.format(IH.L.BAG_FMT_2, counts.backpack, counts.bank)
    end
    countLabel:SetText(string.format("|c%s%d|r %s", clr, counts.total, detail))

    if counts.total > 0 then
        nameLabel:SetColor(HexColor("C8B99A"))
    else
        nameLabel:SetColor(HexColor("A05050"))
    end

    table.insert(self.ingredientRows, row)
    return row
end

---------------------------------------------------------
-- Window Management
---------------------------------------------------------

function IH.ToggleWindow()
    local window = IngredientHunterWindow
    if window then
        window:SetHidden(not window:IsHidden())
        if not window:IsHidden() then
            IH:ScanInventory()
            if not IH.recipeListBuilt then
                IH:BuildRecipeList()
                if IH.sv and IH.sv.lastRecipeIndex then
                    IH:SelectRecipe(IH.sv.lastRecipeIndex)
                end
            end
            if IH.selectedRecipe then
                IH:RefreshIngredientPanel()
            end
        end
    end
end

function IH.OnWindowMoveStop()
    local window = IngredientHunterWindow
    if window and IH.sv then
        local _, _, _, _, offsetX, offsetY = window:GetAnchor(0)
        IH.sv.posX = offsetX
        IH.sv.posY = offsetY
    end
end

function IH:RestorePosition()
    local window = IngredientHunterWindow
    if window and self.sv and self.sv.posX and self.sv.posY then
        window:ClearAnchors()
        window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self.sv.posX, self.sv.posY)
    end
end

---------------------------------------------------------
-- Search
---------------------------------------------------------

function IH.OnSearchTextChanged()
    local searchBox = IngredientHunterWindowSearchBox
    if searchBox then
        local text = searchBox:GetText() or ""
        IH:FilterRecipes(text)
    end
end

---------------------------------------------------------
-- Tracker Widget
---------------------------------------------------------

function IH.TrackSelectedRecipe()
    if not IH.selectedRecipe then
        d(IH.L.MSG_PREFIX .. " " .. IH.L.MSG_SELECT_RECIPE)
        return
    end
    IH.trackerRecipe = IH.selectedRecipe
    IH.trackerCombo = IH.selectedCombo
    IH.sv.trackerRecipeIndex = IH.trackerRecipe
    IH.sv.trackerComboIndex = IH.trackerCombo
    IH.sv.trackerVisible = true
    IH:RefreshTracker()
    IngredientHunterTracker:SetHidden(false)
end

function IH.HideTracker()
    IngredientHunterTracker:SetHidden(true)
    IH.sv.trackerVisible = false
end

function IH.OnTrackerMoveStop()
    local tracker = IngredientHunterTracker
    if tracker and IH.sv then
        local _, _, _, _, offsetX, offsetY = tracker:GetAnchor(0)
        IH.sv.trackerPosX = offsetX
        IH.sv.trackerPosY = offsetY
    end
end

function IH:RestoreTrackerPosition()
    local tracker = IngredientHunterTracker
    if tracker and self.sv and self.sv.trackerPosX and self.sv.trackerPosY then
        tracker:ClearAnchors()
        tracker:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self.sv.trackerPosX, self.sv.trackerPosY)
    end
end

function IH:ClearTrackerRows()
    -- Скрываем весь контейнер целиком — гарантированно скрывает все дочерние элементы
    if self.trackerContainer then
        self.trackerContainer:SetHidden(true)
        self.trackerContainer = nil
    end
    self.trackerRows = {}
end

function IH:RefreshTracker()
    if not self.trackerRecipe then return end
    local recipe = IngredientHunter_Data.recipes[self.trackerRecipe]
    if not recipe then return end

    local tracker = IngredientHunterTracker

    local title = tracker:GetNamedChild("Title")
    title:SetText(IH:TR("recipe", recipe.name))

    local solventLabel = tracker:GetNamedChild("Solvent")
    local solvent = self:GetHighestSolvent(recipe.solventType)
    if solvent then
        local counts = self:GetItemCount(solvent.itemId)
        local colorTag = counts.total > 0 and "|c7DA85A" or "|cAA4444"
        local solventIcon = self.iconCache[solvent.itemId] or ""
        local iconStr = solventIcon ~= "" and string.format("|t16:16:%s|t ", solventIcon) or ""
        solventLabel:SetText(string.format("%s%s: %s%d|r",
            iconStr, IH:TR("solvent", solvent.name), colorTag, counts.total))
    end

    self:ClearTrackerRows()

    local combo = recipe.reagentSets[self.trackerCombo]
    if not combo then
        combo = recipe.reagentSets[1]
        self.trackerCombo = 1
    end

    local listControl = tracker:GetNamedChild("List")

    -- Каждый раз создаём новый контейнер: старые строки остаются скрытыми в своём контейнере
    local container = CreateControl(UniqueName("IH_TC_"), listControl, CT_CONTROL)
    container:SetAnchor(TOPLEFT, listControl, TOPLEFT, 0, 0)
    container:SetAnchor(BOTTOMRIGHT, listControl, BOTTOMRIGHT, 0, 0)
    self.trackerContainer = container

    local yOffset = 0

    for i, reagentName in ipairs(combo) do
        local reagent = self.reagentLookup[reagentName]
        if reagent then
            local row = CreateControl(UniqueName("IH_TR_"), container, CT_CONTROL)
            row:SetDimensions(248, 24)
            row:SetAnchor(TOPLEFT, container, TOPLEFT, 0, yOffset)

            local iconPath = self.iconCache[reagent.itemId] or ""
            local iconPrefix = iconPath ~= "" and string.format("|t20:20:%s|t ", iconPath) or ""

            local nameLabel = CreateControl(UniqueName("IH_TN_"), row, CT_LABEL)
            nameLabel:SetFont("ZoFontGameSmall")
            nameLabel:SetDimensions(160, 22)
            nameLabel:SetAnchor(TOPLEFT, row, TOPLEFT, 0, 1)

            local countLabel = CreateControl(UniqueName("IH_TC2_"), row, CT_LABEL)
            countLabel:SetFont("ZoFontGameSmall")
            countLabel:SetDimensions(80, 22)
            countLabel:SetAnchor(TOPRIGHT, row, TOPRIGHT, 0, 1)
            countLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)

            local counts = self:GetItemCount(reagent.itemId)
            nameLabel:SetText(iconPrefix .. IH:TR("reagent", reagent.name))

            if counts.total > 0 then
                nameLabel:SetColor(HexColor("C8B99A"))
                countLabel:SetColor(HexColor("7DA85A"))
                countLabel:SetText(tostring(counts.total))
            else
                nameLabel:SetColor(HexColor("A05050"))
                countLabel:SetColor(HexColor("AA4444"))
                countLabel:SetText("0")
            end

            table.insert(self.trackerRows, row)
            yOffset = yOffset + 24
        end
    end

    local totalHeight = 52 + yOffset + 8
    tracker:SetHeight(totalHeight)
end

---------------------------------------------------------
-- Language
---------------------------------------------------------

function IH:ApplyLanguage(lang)
    local strings = IngredientHunter_Strings
    -- Resolve "auto" to actual locale
    if not lang or lang == "auto" then
        lang = strings._auto or "en"
    end
    if lang ~= "ru" and lang ~= "en" then lang = "en" end

    self.L = strings[lang]
    self.sv.lang = lang

    -- Update window controls if already created
    if IngredientHunterWindowTitle then
        IngredientHunterWindowTitle:SetText(self.L.WINDOW_TITLE)
    end
    if IngredientHunterWindowTrackLabel then
        IngredientHunterWindowTrackLabel:SetText(self.L.TRACK_BTN)
    end
    if self.langBtn then
        self.langBtn:SetText(lang:upper())
    end

    -- Rebuild recipe list and refresh panels with new language
    if self.recipeListBuilt then
        self.recipeListBuilt = false
        self:BuildRecipeList()
        if self.selectedRecipe then
            self:SelectRecipe(self.selectedRecipe)
        end
    end
    if self.trackerRecipe then
        self:RefreshTracker()
    end
end

function IH:ToggleLanguage()
    local current = self.sv.lang or IngredientHunter_Strings._auto or "en"
    local next = (current == "ru") and "en" or "ru"
    self:ApplyLanguage(next)
end

---------------------------------------------------------
-- Initialization
---------------------------------------------------------

function IH:Initialize()
    self.sv = ZO_SavedVars:NewAccountWide("IngredientHunterSV", 1, nil, SV_DEFAULTS)

    -- Language toggle button in title bar (left side)
    local titleBar = IngredientHunterWindowTitleBar
    local langBtn = CreateControl(UniqueName("IH_LB_"), IngredientHunterWindow, CT_LABEL)
    langBtn:SetFont("ZoFontGameSmall")
    langBtn:SetDimensions(28, 22)
    langBtn:SetAnchor(TOPLEFT, IngredientHunterWindow, TOPLEFT, 8, 5)
    langBtn:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    langBtn:SetMouseEnabled(true)
    langBtn:SetHandler("OnMouseUp", function(_, btn, upInside)
        if upInside and btn == MOUSE_BUTTON_INDEX_LEFT then
            IH:ToggleLanguage()
        end
    end)
    langBtn:SetHandler("OnMouseEnter", function(c) c:SetColor(HexColor("C89B3C")) end)
    langBtn:SetHandler("OnMouseExit",  function(c) c:SetColor(HexColor("8A7860")) end)
    langBtn:SetColor(HexColor("8A7860"))
    self.langBtn = langBtn

    -- Apply language (from SavedVar or auto-detect)
    self:ApplyLanguage(self.sv.lang)

    SLASH_COMMANDS["/ih"] = function()
        IH.ToggleWindow()
    end
    SLASH_COMMANDS["/ingredienthunter"] = function()
        IH.ToggleWindow()
    end
    SLASH_COMMANDS["/ihicons"] = function()
        d("|cC89B3C[IH Icons]|r Диагностика иконок:")
        -- Тест 1: GetItemLinkIcon с ручной ссылкой
        local testId = 30156
        local link = MakeItemLink(testId)
        local icon = GetItemLinkIcon(link)
        d(string.format("  itemId %d -> GetItemLinkIcon: %s", testId, tostring(icon)))
        -- Тест 2: иконки из кэша
        local cacheCount = 0
        for id, path in pairs(IH.iconCache) do
            cacheCount = cacheCount + 1
            if cacheCount <= 3 then
                d(string.format("  cache[%d] = %s", id, tostring(path)))
            end
        end
        d(string.format("  Всего в кэше: %d", cacheCount))
        -- Тест 3: |t markup в чате
        if icon and icon ~= "" then
            d(string.format("  Тест иконки в чате: |t32:32:%s|t <- должна быть иконка", icon))
        end
    end
    SLASH_COMMANDS["/ihdbg"] = function()
        local craftSlots = GetBagSize(BAG_VIRTUAL)
        d(string.format("|cC89B3C[IH Debug]|r BAG_VIRTUAL=%s GetBagSize=%d", tostring(BAG_VIRTUAL), craftSlots or -1))
        local found = 0
        for slot = 0, math.min(craftSlots - 1, 4999) do
            local itemId = GetItemId(BAG_VIRTUAL, slot)
            if itemId and itemId > 0 then
                local stack = GetSlotStackSize(BAG_VIRTUAL, slot)
                d(string.format("  slot %d: itemId=%d stack=%d", slot, itemId, stack))
                found = found + 1
                if found >= 10 then d("  ... (showing first 10)") break end
            end
        end
        if found == 0 then d("  Ничего не найдено в BAG_VIRTUAL") end
    end

    self:BuildReagentLookup()
    self:RestorePosition()
    self:ScanInventory()
    self:RestoreTrackerPosition()

    if self.sv.trackerRecipeIndex then
        self.trackerRecipe = self.sv.trackerRecipeIndex
        self.trackerCombo = self.sv.trackerComboIndex or 1
        self:RefreshTracker()
        if self.sv.trackerVisible then
            IngredientHunterTracker:SetHidden(false)
        end
    end

    -- Обновление при изменении отдельного слота (поднял/использовал предмет)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function(_, bagId, slotIndex)
        IH:UpdateSingleSlot(bagId, slotIndex)
    end)

    -- Полное обновление инвентаря (смена зоны, загрузка персонажа и т.д.)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_FULL", EVENT_INVENTORY_FULL_UPDATE, function(_, bagId)
        IH:OnInventoryChanged()
    end)

    -- Пересканировать когда игрок в мире (ремесленная сумка доступна только после этого)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_ACTIVATED", EVENT_PLAYER_ACTIVATED, function()
        zo_callLater(function() IH:OnInventoryChanged() end, 200)
    end)

    d(self.L.MSG_PREFIX .. " " .. self.L.MSG_LOADED)
end

-- Addon loaded event
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, function(_, addonName)
    if addonName ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
    IH:Initialize()
end)
