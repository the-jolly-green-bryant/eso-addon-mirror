LootTrackerSolution.LootStatisticsWindow = {}

local LSW = LootTrackerSolution.LootStatisticsWindow
local ShowOnlyMaterials

function LSW:CreateOrToggleWindow()
    if not LSW.window then
        LSW:CreateWindow()
        ShowOnlyMaterials = LootTrackerSolution.LootStorageModule:GetStatisticSetting("ShowOnlyMaterials") or false
    else
        LSW.window:SetHidden(not LSW.window:IsHidden())
    end

    if LSW.window:IsHidden() then
        return
    end

    LSW:UpdateScrollParameters()

    local totalGoldAverage = LootTrackerSolution.LootStorageModule:GetTotalGold()["TTC"]["Average"]
    LSW.window.totalGoldLabelAmount:SetText(string.format("|t20:20:EsoUI/Art/currency/currency_gold.dds|t %s", totalGoldAverage))

end

function LSW:UpdateScrollParameters()
    local lootStorageModule = LootTrackerSolution.LootStorageModule
    local logicModule = LootTrackerSolution.LogicModule

    local sortType = lootStorageModule:GetStatisticSetting("SortType")
    local sortDirection = lootStorageModule:GetStatisticSetting("SortDirection")
    local selectedCategory = lootStorageModule:GetStatisticSetting("SelectedCategory")
    local searchText = lootStorageModule:GetStatisticSetting("SearchText")

    local categoryName = {
        "All", "Alchemy", "Blacksmithing", "Clothing", "Enchanting",
        "Jewelry Crafting", "Provisioning", "Woodworking", "Other"
    }

    local localization = LootTrackerSolution.Localization.translation

    local window = LSW.window
    window.CategoryName:SetText(localization["CategoryNames"][selectedCategory])
    window.goldLabel:SetHidden(selectedCategory == 1)
    window.goldLabelProfessionAmount:SetHidden(selectedCategory == 1)

    if selectedCategory ~= 1 then
        window.goldLabelProfessionAmount:SetText(string.format("|t20:20:EsoUI/Art/currency/currency_gold.dds|t %s", lootStorageModule:GetCategoryGold(categoryName[selectedCategory])["TTC"]["Average"]))
    end

    local itemsTable = {}

    for itemCategoryName, category in pairs(lootStorageModule:GetLoot()) do
        for itemLink, item in pairs(category) do
            table.insert(itemsTable, {
                itemLink = itemLink,
                itemCategory = itemCategoryName,
                itemQuantity = item["Amount"],
                lastPrice = item["Price"],
            })
        end
    end

    window.ScrollList.scrollData = logicModule.SortTableByParams(itemsTable, sortDirection, sortType, categoryName[selectedCategory], searchText, ShowOnlyMaterials)

    LootTrackerSolution.SolutionScrollList.UpdateScrollList(window.ScrollList, window.ScrollList.scrollData, 1)
end

function LSW.LayoutRow(rowControl, data)
    local itemPrice = LootTrackerSolution.TradeCenter.SelectPriceInfo(data.lastPrice) or 0
    local goldEarned = itemPrice * data.itemQuantity
    local itemIcon, _ = GetItemLinkInfo(data.itemLink)

    local function createLabel(name, anchor, dimensions, font, text, texture, textureAlignment)
        local label = WINDOW_MANAGER:GetControlByName(rowControl:GetName() .. name)
        label:SetAnchor(anchor[1], anchor[2], anchor[3], anchor[4], anchor[5])
        label:SetDimensions(dimensions[1], dimensions[2])
        label:SetFont(font)
        label:SetText(text)
        if texture then
            label:SetText(string.format("|t20:20:%s|t  %s", texture, text))
        end
        if textureAlignment then
            label:SetHorizontalAlignment(textureAlignment)
        end

        return label
    end

    local labelName = createLabel("Name", { TOPLEFT, rowControl, TOPLEFT, 0, 0 }, { 250, 30 }, "ZoFontWinH4", LootTrackerSolution.LogicModule.TrimItemLinkName(data.itemLink, 25), itemIcon, TEXT_ALIGN_LEFT)
    local labelCategory = createLabel("Category", { TOPLEFT, labelName, TOPRIGHT, 0, 0 }, { 240, 30 }, "ZoFontWinH4", data.itemCategory, nil, TEXT_ALIGN_CENTER)
    local labelAmount = createLabel("Amount", { TOPLEFT, labelCategory, TOPRIGHT, 0, 0 }, { 140, 30 }, "ZoFontWinH4", string.format("|t20:20:LootTrackerSolution/Textures/BagIcon.dds|t (%s)", data.itemQuantity), nil, TEXT_ALIGN_CENTER)
    local labelGold = createLabel("Gold", { TOPLEFT, labelAmount, TOPRIGHT, 0, 0 }, { 140, 30 }, "ZoFontWinH4", string.format("|t20:20:EsoUI/Art/currency/currency_gold.dds|t %s", goldEarned), nil, TEXT_ALIGN_CENTER)
    local labelGoldPerItem = createLabel("GoldPerItem", { TOPLEFT, labelGold, TOPRIGHT, 0, 0 }, { 140, 30 }, "ZoFontWinH4", string.format("|t20:20:EsoUI/Art/currency/currency_gold.dds|t %s", itemPrice), nil, TEXT_ALIGN_CENTER)

    labelName:SetHandler("OnMouseEnter", function(self)
        local pattern = "%|H0:.+%|h"
        local match = string.match(data.itemLink, pattern)

        if not match then return end

        InitializeTooltip(ItemTooltip, rowControl, CENTER, 0, 0, CENTER)
        ItemTooltip:SetLink(data.itemLink)
    end)
    labelName:SetHandler("OnMouseExit", function(self)
        ClearTooltip(ItemTooltip)
    end)
end

function LSW.OnRowSelect(rowControl, rowData)

end

function LSW:CreateWindow()
    if LSW.window then
        return
    end

    local localization = LootTrackerSolution.Localization.translation

    LSW.window = WINDOW_MANAGER:CreateTopLevelWindow("LootTrackerSolution_LootStatisticsWindow")
    LSW.window:SetDimensions(1240, 800)
    LSW.window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    LSW.window:SetMovable(true)
    LSW.window:SetMouseEnabled(true)
    LSW.window:SetClampedToScreen(true)
    LSW.window:SetHidden(false)
    LSW.window:SetAlpha(1)
    LSW.window:SetDrawLayer(DL_OVERLAY)
    LSW.window:SetDrawLevel(1)

    local function createBackdropControl(name, dimensions, anchor, centerColor, edgeColor)
        local control = WINDOW_MANAGER:CreateControl(nil, LSW.window, CT_BACKDROP)
        control:SetDimensions(dimensions[1], dimensions[2])
        control:SetAnchor(anchor[1], anchor[2], anchor[3], anchor[4], anchor[5])
        control:SetEdgeTexture("EsoUI/Art/Miscellaneous/progressbar_ebb_divider.dds", 1, 1, 2)
        control:SetCenterColor(centerColor[1], centerColor[2], centerColor[3], centerColor[4])
        control:SetEdgeColor(edgeColor[1], edgeColor[2], edgeColor[3], edgeColor[4])
        return control
    end

    LSW.window.background = createBackdropControl("Background", {LSW.window:GetWidth(), LSW.window:GetHeight()}, {CENTER, LSW.window, CENTER, 0, 0}, {0, 0, 0, 0.7}, {0, 0, 0, 1})

    LSW.window.Title = WINDOW_MANAGER:CreateControlFromVirtual("Solution_LootWindowStatisticsTitle", LSW.window, "Solution_LootWindowStatisticsTitle")
    LSW.window.Title:SetDimensions(LSW.window:GetWidth() - 30, 30)
    LSW.window.Title:SetAnchor(TOPLEFT, LSW.window, TOPLEFT, 20, 20)

    LSW.window.Donate = WINDOW_MANAGER:CreateControl("Solution_LootStatisticsDonate", LSW.window, CT_BUTTON)
    LSW.window.Donate:SetDimensions(200, 30)
    LSW.window.Donate:SetAnchor(RIGHT, LSW.window, BOTTOMRIGHT, -15, -15)
    LSW.window.Donate:SetHandler("OnMouseUp", function()
        if MAIL_SEND:IsHidden() then
            MAIL_SEND:ComposeMailTo("@Solution_Lop")
          else
            MAIL_SEND:SetReply("@Solution_Lop")
          end
          LSW:CreateOrToggleWindow()
    end)

    LSW.window.Donate.label = WINDOW_MANAGER:CreateControl("Solution_LootStatisticsDonateLabel", LSW.window.Donate, CT_LABEL)
    LSW.window.Donate.label:SetAnchorFill()
    LSW.window.Donate.label:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    LSW.window.Donate.label:SetFont("ZoFontWinH5")
    LSW.window.Donate.label:SetText(string.format("%s |t20:20:LootTrackerSolution/Textures/LoveIcon.dds|t", localization["Donate"]))

    LSW.window.CategoryName = WINDOW_MANAGER:CreateControl("Solution_LootStatisticsCategoryName", LSW.window, CT_LABEL)
    LSW.window.CategoryName:SetDimensions(200, 30)
    LSW.window.CategoryName:SetAnchor(TOPLEFT, LSW.window.Title, TOPLEFT, LSW.window.Title:GetWidth() / 2, 0)
    LSW.window.CategoryName:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    LSW.window.CategoryName:SetFont("ZoFontWinH3")

    LSW.window.Close = WINDOW_MANAGER:CreateControlFromVirtual("Solution_LootStatisticsClose", LSW.window, "Solution_LootWindowStatisticsClose")
    LSW.window.Close:SetAnchor(TOPRIGHT, LSW.window, TOPRIGHT, -20, 20)
    LSW.window.Close:SetHandler("OnMouseUp", function()
        LSW.window:SetHidden(true)
    end)

    local function createLabelControl(name, dimensions, anchor, text, font, texture, textureAlignment)
        local control = WINDOW_MANAGER:CreateControl(name, LSW.window, CT_LABEL)
        control:SetDimensions(dimensions[1], dimensions[2])
        control:SetAnchor(anchor[1], anchor[2], anchor[3], anchor[4], anchor[5])
        control:SetHorizontalAlignment(textureAlignment or TEXT_ALIGN_CENTER)
        control:SetFont(font)
        control:SetText(texture and string.format("|t20:20:%s|t  %s", texture, text) or text)
        return control
    end

    LSW.window.totalGoldLabel = createLabelControl("Solution_LootStatisticsTotalLabel", {200, 30}, {TOPLEFT, LSW.window, TOPLEFT, 20, 70}, localization["TotalGold"] .. ":", "ZoFontWinH4")
    LSW.window.totalGoldLabelAmount = createLabelControl("Solution_LootStatisticsTotalLabelAmount", {200, 30}, {TOPLEFT, LSW.window.totalGoldLabel, TOPLEFT, 0, 25}, string.format("|t20:20:EsoUI/Art/currency/currency_gold.dds|t %s", LootTrackerSolution.LootStorageModule:GetTotalGold()["TTC"]["Average"]), "ZoFontWinH5")
    LSW.window.goldLabel = createLabelControl("Solution_LootStatisticsGoldLabel", {200, 30}, {TOPLEFT, LSW.window.totalGoldLabelAmount, TOPLEFT, 0, 35}, localization["CategoryGold"] .. ":", "ZoFontWinH4")
    LSW.window.goldLabelProfessionAmount = createLabelControl("Solution_LootStatisticsGoldLabelProfessionAmount", {200, 30}, {TOPLEFT, LSW.window.goldLabel, TOPLEFT, 0, 25}, "", "ZoFontWinH5")

    LSW.window.SearchTextBox = WINDOW_MANAGER:CreateControlFromVirtual("Solution_SearchTextBox", LSW.window.totalGoldLabelAmount, "Solution_SearchTextBox")
    LSW.window.SearchTextBox:SetDimensions(130, 30)
    LSW.window.SearchTextBox:SetAnchor(TOPLEFT, LSW.window.totalGoldLabelAmount, TOPLEFT, 20, 90)
    LSW.window.SearchTextBox.SearchBar = WINDOW_MANAGER:GetControlByName(LSW.window.SearchTextBox:GetName() .. "SearchBox")
    LSW.window.SearchTextBox.SearchButton = WINDOW_MANAGER:GetControlByName(LSW.window.SearchTextBox:GetName() .. "SearchButton")
    LSW.window.SearchTextBox.SearchBar:SetHandler("OnTextChanged", function(self)
        if(self:GetText() ~= "") then
            LSW.window.SearchTextBox.SearchButton:SetNormalTexture("LootTrackerSolution/Textures/CrossIcon.dds")
            LSW.window.SearchTextBox.SearchButton:SetDimensions(15, 15)
            LSW.window.SearchTextBox.SearchButton:SetHandler("OnMouseUp", function()
                LSW.window.SearchTextBox.SearchBar:SetText("")
                LSW.window.SearchTextBox.SearchButton:SetNormalTexture("LootTrackerSolution/Textures/LupaIcon.dds")
                LSW.window.SearchTextBox.SearchButton:SetDimensions(20, 20)
                LootTrackerSolution.LootStorageModule:SetStatisticSetting("SearchText", "")
                LSW:UpdateScrollParameters()
            end)
        elseif(self:GetText() == "") then
            LSW.window.SearchTextBox.SearchButton:SetNormalTexture("LootTrackerSolution/Textures/LupaIcon.dds")
            LSW.window.SearchTextBox.SearchButton:SetDimensions(20, 20)
        end
        LootTrackerSolution.LootStorageModule:SetStatisticSetting("SearchText", self:GetText())
        LSW:UpdateScrollParameters()
    end)

    local function createButtonControl(name, dimensions, anchor, text, font, handler, texture, textureAlignment)
        local control = WINDOW_MANAGER:CreateControl(name, LSW.window, CT_BUTTON)
        control:SetDimensions(dimensions[1], dimensions[2])
        control:SetAnchor(anchor[1], anchor[2], anchor[3], anchor[4], anchor[5])
        control:SetFont(font)
        control:SetHorizontalAlignment(textureAlignment or TEXT_ALIGN_CENTER)
        control:SetText(text)
        control:SetHandler("OnMouseUp", handler)
        return control
    end

    LSW.buttonAll = createButtonControl("Solution_LootStatisticsButtonAll", {200, 60}, {TOPLEFT, LSW.window.SearchTextBox, TOPLEFT, -20, 60}, localization["CategoryNames"]["All"], "ZoFontWinH3", function()
        LootTrackerSolution.LootStorageModule:SetStatisticSetting("SelectedCategory", 1)
        LSW:UpdateScrollParameters()
    end)

    LSW.buttonAlchemy = createButtonControl("Solution_LootStatisticsButtonAlchiemy", {200, 60}, {TOPLEFT, LSW.buttonAll, TOPLEFT, 0, 40}, localization["CategoryNames"]["Alchemy"], "ZoFontWinH3", function()
        LootTrackerSolution.LootStorageModule:SetStatisticSetting("SelectedCategory", 2)
        LSW:UpdateScrollParameters()
    end)

    LSW.buttonBlacksmithing = createButtonControl("Solution_LootStatisticsButtonBlacksmithing", {200, 60}, {TOPLEFT, LSW.buttonAlchemy, TOPLEFT, 0, 40}, localization["CategoryNames"]["Blacksmithing"], "ZoFontWinH3", function()
        LootTrackerSolution.LootStorageModule:SetStatisticSetting("SelectedCategory", 3)
        LSW:UpdateScrollParameters()
    end)

    LSW.buttonClothing = createButtonControl("Solution_LootStatisticsButtonClothing", {200, 60}, {TOPLEFT, LSW.buttonBlacksmithing, TOPLEFT, 0, 40}, localization["CategoryNames"]["Clothing"], "ZoFontWinH3", function()
        LootTrackerSolution.LootStorageModule:SetStatisticSetting("SelectedCategory", 4)
        LSW:UpdateScrollParameters()
    end)

    LSW.buttonEnchanting = createButtonControl("Solution_LootStatisticsButtonEnchanting", {200, 60}, {TOPLEFT, LSW.buttonClothing, TOPLEFT, 0, 40}, localization["CategoryNames"]["Enchanting"], "ZoFontWinH3", function()
        LootTrackerSolution.LootStorageModule:SetStatisticSetting("SelectedCategory", 5)
        LSW:UpdateScrollParameters()
    end)

    LSW.buttonJewelryCrafting = createButtonControl("Solution_LootStatisticsButtonJewelryCrafting", {200, 60}, {TOPLEFT, LSW.buttonEnchanting, TOPLEFT, 0, 40}, localization["CategoryNames"]["JewelryCrafting"], "ZoFontWinH3", function()
        LootTrackerSolution.LootStorageModule:SetStatisticSetting("SelectedCategory", 6)
        LSW:UpdateScrollParameters()
    end)

    LSW.buttonProvisioning = createButtonControl("Solution_LootStatisticsButtonProvisioning", {200, 60}, {TOPLEFT, LSW.buttonJewelryCrafting, TOPLEFT, 0, 40}, localization["CategoryNames"]["Provisioning"], "ZoFontWinH3", function()
        LootTrackerSolution.LootStorageModule:SetStatisticSetting("SelectedCategory", 7)
        LSW:UpdateScrollParameters()
    end)

    LSW.buttonWoodworking = createButtonControl("Solution_LootStatisticsButtonWoodworking", {200, 60}, {TOPLEFT, LSW.buttonProvisioning, TOPLEFT, 0, 40}, localization["CategoryNames"]["Woodworking"], "ZoFontWinH3", function()
        LootTrackerSolution.LootStorageModule:SetStatisticSetting("SelectedCategory", 8)
        LSW:UpdateScrollParameters()
    end)

    LSW.buttonOther = createButtonControl("Solution_LootStatisticsButtonOther", {200, 60}, {TOPLEFT, LSW.buttonWoodworking, TOPLEFT, 0, 40}, localization["CategoryNames"]["Other"], "ZoFontWinH3", function()
        LootTrackerSolution.LootStorageModule:SetStatisticSetting("SelectedCategory", 9)
        LSW:UpdateScrollParameters()
    end)

    LSW.buttonAll.Line = WINDOW_MANAGER:CreateControlFromVirtual(nil, LSW.buttonAll, "Solution_LootWindowStatisticsBackdrop")
    LSW.buttonAlchemy.Line = WINDOW_MANAGER:CreateControlFromVirtual(nil, LSW.buttonAlchemy, "Solution_LootWindowStatisticsBackdrop")
    LSW.buttonBlacksmithing.Line = WINDOW_MANAGER:CreateControlFromVirtual(nil, LSW.buttonBlacksmithing, "Solution_LootWindowStatisticsBackdrop")
    LSW.buttonClothing.Line = WINDOW_MANAGER:CreateControlFromVirtual(nil, LSW.buttonClothing, "Solution_LootWindowStatisticsBackdrop")
    LSW.buttonEnchanting.Line = WINDOW_MANAGER:CreateControlFromVirtual(nil, LSW.buttonEnchanting, "Solution_LootWindowStatisticsBackdrop")
    LSW.buttonJewelryCrafting.Line = WINDOW_MANAGER:CreateControlFromVirtual(nil, LSW.buttonJewelryCrafting, "Solution_LootWindowStatisticsBackdrop")
    LSW.buttonProvisioning.Line = WINDOW_MANAGER:CreateControlFromVirtual(nil, LSW.buttonProvisioning, "Solution_LootWindowStatisticsBackdrop")
    LSW.buttonWoodworking.Line = WINDOW_MANAGER:CreateControlFromVirtual(nil, LSW.buttonWoodworking, "Solution_LootWindowStatisticsBackdrop")

    local function OnlyMaterialsToggle()
        ShowOnlyMaterials = not ShowOnlyMaterials
        LootTrackerSolution.LootStorageModule:SetGeneralSetting("ShowOnlyMaterials", ShowOnlyMaterials)     
        LSW.buttonOnlyMaterials.checkBox:SetNormalTexture(ShowOnlyMaterials and "LootTrackerSolution/Textures/CheckBoxTrueIcon.dds" or "LootTrackerSolution/Textures/CheckBoxFalseIcon.dds")
        LSW:UpdateScrollParameters()
    end

    LSW.buttonOnlyMaterials = createButtonControl("Solution_LootStatisticsButtonOnlyMaterials", {200, 50}, {TOPLEFT, LSW.buttonOther, TOPLEFT, 0, 80}, localization["ShowMaterials"], "ZoFontWinH5", function()
        OnlyMaterialsToggle()
    end, nil, TEXT_ALIGN_LEFT)
    LSW.buttonOnlyMaterials.checkBox = WINDOW_MANAGER:CreateControlFromVirtual("Solution_LootStatisticsButtonOnlyMaterialsCheckBox", LSW.buttonOnlyMaterials, "CheckBoxControl")
    LSW.buttonOnlyMaterials.checkBox:SetAnchor(LEFT, LSW.buttonOnlyMaterials, RIGHT, -40, 0)
    LSW.buttonOnlyMaterials.checkBox:SetDimensions(24, 24)
    LSW.buttonOnlyMaterials.checkBox:SetHandler("OnMouseUp", function()
        OnlyMaterialsToggle()
    end)

    LSW.mainContainer = WINDOW_MANAGER:CreateControl(nil, LSW.window, CT_CONTROL)
    LSW.mainContainer:SetDimensions(840, 700)
    LSW.mainContainer:SetAnchor(TOPLEFT, LSW.window.totalGoldLabel, TOPLEFT, 210, 0)

    LSW.nameButtonSort = createButtonControl("Solution_LootStatisticsNameButtonSort", {250, 60}, {TOPLEFT, LSW.mainContainer, TOPLEFT, 0, 0}, localization["Name"], "ZoFontWinH3", function()
        LootTrackerSolution.LootStorageModule:SetStatisticSetting("SortType", 1)
        LootTrackerSolution.LootStorageModule:SetStatisticSetting("SortDirection", not LootTrackerSolution.LootStorageModule:GetStatisticSetting("SortDirection"))
        LSW:UpdateScrollParameters()
    end)

    LSW.categoryButtonSort = createButtonControl("Solution_LootStatisticsCategoryButtonSort", {240, 60}, {TOPLEFT, LSW.nameButtonSort, TOPRIGHT, 0, 0}, localization["Category"], "ZoFontWinH4", function()
        LootTrackerSolution.LootStorageModule:SetStatisticSetting("SortType", 2)
        LootTrackerSolution.LootStorageModule:SetStatisticSetting("SortDirection", not LootTrackerSolution.LootStorageModule:GetStatisticSetting("SortDirection"))
        LSW:UpdateScrollParameters()
    end)

    LSW.amountButtonSort = createButtonControl("Solution_LootStatisticsAmountButtonSort", {140, 60}, {TOPLEFT, LSW.categoryButtonSort, TOPRIGHT, 0, 0}, localization["Amount"], "ZoFontWinH4", function()
        LootTrackerSolution.LootStorageModule:SetStatisticSetting("SortType", 3)
        LootTrackerSolution.LootStorageModule:SetStatisticSetting("SortDirection", not LootTrackerSolution.LootStorageModule:GetStatisticSetting("SortDirection"))
        LSW:UpdateScrollParameters()
    end)

    LSW.priceButtonSort = createButtonControl("Solution_LootStatisticsPriceButtonSort", {140, 60}, {TOPLEFT, LSW.amountButtonSort, TOPRIGHT, 0, 0}, localization["Price"], "ZoFontWinH4", function()
        LootTrackerSolution.LootStorageModule:SetStatisticSetting("SortType", 4)
        LootTrackerSolution.LootStorageModule:SetStatisticSetting("SortDirection", not LootTrackerSolution.LootStorageModule:GetStatisticSetting("SortDirection"))
        LSW:UpdateScrollParameters()
    end)

    LSW.pricePerItemButtonSort = createButtonControl("Solution_LootStatisticsPricePerItemButtonSort", {140, 60}, {TOPLEFT, LSW.priceButtonSort, TOPRIGHT, 0, 0}, localization["Price/Item"], "ZoFontWinH4", function()
        LootTrackerSolution.LootStorageModule:SetStatisticSetting("SortType", 5)
        LootTrackerSolution.LootStorageModule:SetStatisticSetting("SortDirection", not LootTrackerSolution.LootStorageModule:GetStatisticSetting("SortDirection"))
        LSW:UpdateScrollParameters()
    end)

    LSW.window.ScrollList = LootTrackerSolution.SolutionScrollList.CreateScrollList("Solution_LootStatisticsList", LSW.window, LSW.LayoutRow, LSW.OnRowSelect, "Solution_RowStatistics", 30)
    LSW.window.ScrollList:SetDimensions(980, 650)
    LSW.window.ScrollList:SetAnchor(TOPLEFT, LSW.mainContainer, TOPLEFT, 0, 35)
end