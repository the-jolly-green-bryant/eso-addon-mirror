local addonId = "UnknownInsight"
local class = ZO_DeferredInitializingObject:Subclass()

local texturePath = "EsoUI/Art/Inventory/inventory_can_learn_icon.dds"

local KNOWLEDGE_ALL = -1
local KNOWLEDGE_KNOWN = 1
local KNOWLEDGE_UNKNOWN = 2
local CATEGORY_ALL = -1

local SEARCH_TYPE = "SEARCH_TYPE_UNKNOWN_INSIGHT_ITEM"

UI_KNOWLEDGE_TYPE_ALL = 1
UI_KNOWLEDGE_TYPE_PARTIAL = 2
UI_KNOWLEDGE_TYPE_CURRENT = 3

local ownerDisplayNames = {
    ["@zelenin"] = true,
    ["@zelenin_av"] = true,
}

local function iter(start, finish)
    local counter = start - 1

    return function()
        counter = counter + 1

        if counter > finish then
            return nil
        end

        return counter
    end
end

function class:Initialize(name)
    self.name = name
    self.currentAccount = GetDisplayName()
    self.currentCharacterId = GetCurrentCharacterId()
    self.addonData = self:getAddonData()
    self.texturePath = self.addonData.resolveFilePath("assets/tick.dds")
    self.migrationData = LibSimpleSavedVars:NewInstallationWide(string.format("%sMigration", self.name), 1, {
        version = 0,
    })

    if self.migrationData.version < 3 then
        _G[string.format("%sDatabase", self.name)] = nil
        _G[string.format("%sCharacterData", self.name)] = nil
        _G[string.format("%sFilterData", self.name)] = nil

        self.migrationData.version = 3
    end

    --self.database = LibSimpleSavedVars:NewInstallationWide(string.format("%sDatabase", self.name), 1, {
    --    items = {},
    --    version = nil,
    --})
    --self.characterData = LibSimpleSavedVars:NewInstallationWide(string.format("%sCharacterData", self.name), 1, {
    --    characters = {}
    --})
    self.filterData = LibSimpleSavedVars:NewInstallationWide(string.format("%sFilterData", self.name), 1, {
        search = "",
        character = self.currentCharacterId,
        category = CATEGORY_ALL,
        knowledge = KNOWLEDGE_ALL,
    })

    self.settings = unknownInsightSettings:New(self)

    self.filterData.character = self.currentCharacterId

    self.categories = {
        {
            name = "Motives (books and chapters)",
            filter = function(itemData)
                return itemData.specializedItemType == SPECIALIZED_ITEMTYPE_RACIAL_STYLE_MOTIF_BOOK or
                        itemData.specializedItemType == SPECIALIZED_ITEMTYPE_RACIAL_STYLE_MOTIF_CHAPTER
            end,
            getData = function(itemData)
                local itemLink = string.format("|H1:item:%d:%d:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h", itemData.id, 364)
                local quality = GetItemLinkFunctionalQuality(itemLink)
                return {
                    id = itemData.id,
                    name = itemData.name,
                    itemLink = itemLink,
                    quality = quality,
                }
            end,
            isKnown = function(itemData)
                return IsItemLinkBookKnown(itemData.itemLink)
            end,
            accountWide = false
        },
        {
            name = "Style pages",
            filter = function(itemData)
                if itemData.specializedItemType ~= SPECIALIZED_ITEMTYPE_COLLECTIBLE_STYLE_PAGE then
                    return false
                end

                local itemLink = string.format("|H1:item:%d:%d:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h", itemData.id, 364)
                local collectibleId = GetItemLinkContainerCollectibleId(itemLink)
                return collectibleId > 0
            end,
            getData = function(itemData)
                local itemLink = string.format("|H1:item:%d:%d:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h", itemData.id, 364)
                local quality = GetItemLinkFunctionalQuality(itemLink)
                local collectibleId = GetItemLinkContainerCollectibleId(itemLink)
                return {
                    id = itemData.id,
                    name = itemData.name,
                    itemLink = itemLink,
                    quality = quality,
                    collectibleId = collectibleId
                }
            end,
            isKnown = function(itemData)
                return IsCollectibleOwnedByDefId(itemData.collectibleId)
            end,
            accountWide = true
        },
        {
            name = "Recipes (food and drink)",
            filter = function(itemData)
                return itemData.specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_FOOD or
                        itemData.specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_DRINK
            end,
            getData = function(itemData)
                local itemLink = string.format("|H1:item:%d:%d:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h", itemData.id, 364)
                local quality = GetItemLinkFunctionalQuality(itemLink)
                return {
                    id = itemData.id,
                    name = itemData.name,
                    itemLink = itemLink,
                    quality = quality
                }
            end,
            isKnown = function(itemData)
                return IsItemLinkRecipeKnown(itemData.itemLink)
            end,
            accountWide = false
        },
        {
            name = "Recipes (furnishing)",
            filter = function(itemData)
                return itemData.specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_BLACKSMITHING_DIAGRAM_FURNISHING or
                        itemData.specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_CLOTHIER_PATTERN_FURNISHING or
                        itemData.specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_ENCHANTING_SCHEMATIC_FURNISHING or
                        itemData.specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_ALCHEMY_FORMULA_FURNISHING or
                        itemData.specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_DESIGN_FURNISHING or
                        itemData.specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_WOODWORKING_BLUEPRINT_FURNISHING or
                        itemData.specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_JEWELRYCRAFTING_SKETCH_FURNISHING
            end,
            getData = function(itemData)
                local itemLink = string.format("|H1:item:%d:%d:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h", itemData.id, 364)
                local quality = GetItemLinkFunctionalQuality(itemLink)
                return {
                    id = itemData.id,
                    name = itemData.name,
                    itemLink = itemLink,
                    quality = quality
                }
            end,
            isKnown = function(itemData)
                return IsItemLinkRecipeKnown(itemData.itemLink)
            end,
            accountWide = false
        },
        {
            name = "Runeboxes",
            filter = function(itemData)
                if itemData.specializedItemType ~= SPECIALIZED_ITEMTYPE_CONTAINER then
                    return false
                end

                local itemLink = string.format("|H1:item:%d:%d:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h", itemData.id, 364)
                local collectibleId = GetItemLinkContainerCollectibleId(itemLink)
                return collectibleId > 0
            end,
            getData = function(itemData)
                local itemLink = string.format("|H1:item:%d:%d:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h", itemData.id, 364)
                local quality = GetItemLinkFunctionalQuality(itemLink)
                local collectibleId = GetItemLinkContainerCollectibleId(itemLink)
                return {
                    id = itemData.id,
                    name = itemData.name,
                    itemLink = itemLink,
                    quality = quality,
                    collectibleId = collectibleId
                }
            end,
            isKnown = function(itemData)
                return IsCollectibleOwnedByDefId(itemData.collectibleId)
            end,
            accountWide = true
        },
        {
            name = "Fragments",
            filter = function(itemData)
                if itemData.specializedItemType ~= SPECIALIZED_ITEMTYPE_TROPHY_RUNEBOX_FRAGMENT and
                        itemData.specializedItemType ~= SPECIALIZED_ITEMTYPE_TROPHY_COLLECTIBLE_FRAGMENT then
                    return false
                end

                local itemLink = string.format("|H1:item:%d:%d:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h", itemData.id, 364)
                local collectibleId = GetItemLinkContainerCollectibleId(itemLink)
                return collectibleId > 0
            end,
            getData = function(itemData)
                local itemLink = string.format("|H1:item:%d:%d:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h", itemData.id, 364)
                local quality = GetItemLinkFunctionalQuality(itemLink)
                local collectibleId = GetItemLinkContainerCollectibleId(itemLink)
                local collectibleCategoryType = GetCollectibleCategoryType(collectibleId)
                return {
                    id = itemData.id,
                    name = itemData.name,
                    itemLink = itemLink,
                    quality = quality,
                    collectibleId = collectibleId,
                    collectibleCategoryType = collectibleCategoryType,
                }
            end,
            isKnown = function(itemData)
                if IsCollectibleOwnedByDefId(itemData.collectibleId) then
                    return true
                end
                if itemData.collectibleCategoryType == COLLECTIBLE_CATEGORY_TYPE_COMBINATION_FRAGMENT and not CanCombinationFragmentBeUnlocked(itemData.collectibleId) then
                    return true
                end

                return false
            end,
            accountWide = true
        },
        {
            name = "Scribing (grimoires)",
            filter = function(itemData)
                return itemData.itemType == ITEMTYPE_CRAFTED_ABILITY
            end,
            getData = function(itemData)
                local itemLink = string.format("|H1:item:%d:%d:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h", itemData.id, 364)
                local quality = GetItemLinkFunctionalQuality(itemLink)
                local refId = GetItemLinkItemUseReferenceId(itemLink)
                return {
                    id = itemData.id,
                    name = itemData.name,
                    itemLink = itemLink,
                    quality = quality,
                    refId = refId,
                }
            end,
            isKnown = function(itemData)
                return IsCraftedAbilityUnlocked(itemData.refId)
            end,
            accountWide = false
        },
        {
            name = "Scribing (scripts)",
            filter = function(itemData)
                return itemData.itemType == ITEMTYPE_CRAFTED_ABILITY_SCRIPT
            end,
            getData = function(itemData)
                local itemLink = string.format("|H1:item:%d:%d:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h", itemData.id, 124)
                local quality = GetItemLinkFunctionalQuality(itemLink)
                local refId = GetItemLinkItemUseReferenceId(itemLink)
                return {
                    id = itemData.id,
                    name = itemData.name,
                    itemLink = itemLink,
                    quality = quality,
                    refId = refId,
                }
            end,
            isKnown = function(itemData)
                return IsCraftedAbilityScriptUnlocked(itemData.refId)
            end,
            accountWide = false
        },
    }

    self.provider = unknownInsightDataProvider:New(self)
    self.provider:AddOnEndOfScanCallback(function()
        ZO_ScrollList_RefreshVisible(ZO_PlayerInventoryList)
        ZO_ScrollList_RefreshVisible(ZO_PlayerBankBackpack)
        ZO_ScrollList_RefreshVisible(ZO_HouseBankBackpack)
        ZO_ScrollList_RefreshVisible(ZO_GuildBankBackpack)
        ZO_ScrollList_RefreshVisible(ZO_SmithingTopLevelDeconstructionPanelInventoryBackpack)
        ZO_ScrollList_RefreshVisible(ZO_SmithingTopLevelImprovementPanelInventoryBackpack)

        self:createCharacterCombobox(self.control:GetNamedChild("CharacterDropdown"))
    end)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_OPEN_TRADING_HOUSE, function(eventCode)
        self:hookTradingHouse()
    end)

    self.control = UnknownInsightContainer
    --self.list = self:createList(self.control)
    --
    --self:createCategoryCombobox(self.control:GetNamedChild("CategoryDropdown"))
    --self:createKnowledgeCombobox(self.control:GetNamedChild("KnowledgeDropdown"))
    --self:createCharacterCombobox(self.control:GetNamedChild("CharacterDropdown"))
    --self:createSearchBox(self.control:GetNamedChild("SearchBox"))

    self.scene = self:createScene(string.format("%sScene", self.name), self.control)
    ZO_DeferredInitializingObject.Initialize(self, self.scene)
    self.scene:RegisterCallback("StateChange", function(oldState, newState)
        if newState == SCENE_SHOWING then
            self.list:RefreshFilters()
        end
    end)

    self.searcher = ZO_StringSearch:New()
    self.searcher:AddProcessor(SEARCH_TYPE, function(stringSearch, data, searchTerm, cache)
        return zo_plainstrfind(data.name:lower(), searchTerm:lower())
    end)

    local slashCommands = {
        "/ui",
        "/unknown-insight"
    }

    for _, slashCommand in ipairs(slashCommands) do
        SLASH_COMMANDS[slashCommand] = function(cmd)
            if cmd == "rescan" then
                self.provider.data.version = nil
                self.provider.data.lang = nil
                self.provider:Scan()
            end
            if cmd == "" then
                self:Toggle()
            end
        end
    end

    self:hookInventory()
    self:tooltipHooks()
    self:hookAdvancedFilters()
    self:chatHook(self.settings.data.chatIcon)
    self.thirdParty = unknownInsightThirdParty:New(self)
    self.vendorTracker = unknownInsightVendorTracker:New(self)
end

function class:OnDeferredInitialize()
    self.list = self:createList(self.control)

    self:createCategoryCombobox(self.control:GetNamedChild("CategoryDropdown"))
    self:createKnowledgeCombobox(self.control:GetNamedChild("KnowledgeDropdown"))
    self:createCharacterCombobox(self.control:GetNamedChild("CharacterDropdown"))
    self:createSearchBox(self.control:GetNamedChild("SearchBox"))
end

function class:Toggle()
    self:createCharacterCombobox(self.control:GetNamedChild("CharacterDropdown"))
    SCENE_MANAGER:Toggle(self.scene:GetName())
end

function class:createScene(name, control)
    ZO_CreateStringId("SI_UNKNOWN_INSIGHT_TITLE", self.addonData.title)

    local scene = ZO_Scene:New(name, SCENE_MANAGER)
    scene:AddFragment(ZO_SetTitleFragment:New(SI_UNKNOWN_INSIGHT_TITLE))
    scene:AddFragment(ZO_FadeSceneFragment:New(control))
    scene:AddFragment(TITLE_FRAGMENT)
    --scene:AddFragment(WIDE_RIGHT_BG_FRAGMENT)
    scene:AddFragment(RIGHT_BG_FRAGMENT)
    scene:AddFragment(FRAME_EMOTE_FRAGMENT_JOURNAL)
    scene:AddFragment(CODEX_WINDOW_SOUNDS)
    scene:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW)
    scene:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_STANDARD_RIGHT_PANEL)

    return scene
end

function class:createCategoryCombobox(control)
    local comboBox = ZO_ComboBox_ObjectFromContainer(control)
    comboBox:ClearItems()
    comboBox:SetSortsItems(false)

    local callback = function(row, itemName, item, selectionChanged, oldItem)
        self.filterData.category = item.category
        self.list:RefreshFilters()
    end

    local selectedIndex = 1

    local entry = comboBox:CreateItemEntry("All", callback)
    entry.category = CATEGORY_ALL
    comboBox:AddItem(entry, ZO_COMBOBOX_SUPRESS_UPDATE)

    if entry.category == self.filterData.category then
        selectedIndex = comboBox:GetNumItems()
    end

    for categoryId, category in ipairs(self.categories) do
        local entry = comboBox:CreateItemEntry(category.name, callback)
        entry.category = categoryId
        comboBox:AddItem(entry, ZO_COMBOBOX_SUPRESS_UPDATE)

        if entry.category == self.filterData.category then
            selectedIndex = comboBox:GetNumItems()
        end
    end

    comboBox:SelectItemByIndex(selectedIndex, true)

    return comboBox
end

function class:createKnowledgeCombobox(control)
    local comboBox = ZO_ComboBox_ObjectFromContainer(control)
    comboBox:ClearItems()
    comboBox:SetSortsItems(false)

    local knowledges = {
        [KNOWLEDGE_ALL] = "All",
        [KNOWLEDGE_UNKNOWN] = "Unknown",
        [KNOWLEDGE_KNOWN] = "Known",
    }

    local callback = function(row, itemName, item, selectionChanged, oldItem)
        self.filterData.knowledge = item.knowledge
        self.list:RefreshFilters()
    end

    local selectedIndex = 1

    for id, name in pairs(knowledges) do
        local entry = comboBox:CreateItemEntry(name, callback)
        entry.knowledge = id
        comboBox:AddItem(entry, ZO_COMBOBOX_SUPRESS_UPDATE)

        if entry.knowledge == self.filterData.knowledge then
            selectedIndex = comboBox:GetNumItems()
        end
    end

    comboBox:SelectItemByIndex(selectedIndex, true)

    return comboBox
end

function class:createCharacterCombobox(control)
    local comboBox = ZO_ComboBox_ObjectFromContainer(control)
    comboBox:ClearItems()
    comboBox:SetSortsItems(false)

    local callback = function(row, itemName, item, selectionChanged, oldItem)
        self.filterData.character = item.character
        self.list:RefreshFilters()
    end

    local selectedIndex = 1

    for _, character in ipairs(LibCharacter:GetCharacters()) do
        if self.settings.data.characters[character.id] and self.provider.data.characters[character.id] ~= nil then
            local entry = comboBox:CreateItemEntry(character.name, callback)
            entry.character = character.id
            comboBox:AddItem(entry, ZO_COMBOBOX_SUPRESS_UPDATE)

            if entry.character == self.filterData.character then
                selectedIndex = comboBox:GetNumItems()
            end
        end
    end

    if ownerDisplayNames[GetDisplayName()] then
        local entry = comboBox:CreateItemEntry("Any", callback)
        entry.character = "-1"
        comboBox:AddItem(entry, ZO_COMBOBOX_SUPRESS_UPDATE)

        if entry.character == self.filterData.character then
            selectedIndex = comboBox:GetNumItems()
        end
    end

    comboBox:SelectItemByIndex(selectedIndex, true)

    return comboBox
end

function class:createSearchBox(control)
    control:SetText(self.filterData.search)
    control:SetHandler("OnTextChanged", function(control)
        ZO_EditDefaultText_OnTextChanged(control)
        self.filterData.search = control:GetText()
        self.list:RefreshFilters()
    end)
end

local UNKNOWN_INSIGHT_DATA_TYPE = 50

function class:createList(control)
    local list = ZO_SortFilterList:New(control)

    list.owner = self

    ZO_ScrollList_EnableHighlight(list.list, "ZO_ThinListHighlight")

    list:SetAlternateRowBackgrounds(true)
    list:SetEmptyText("No data")

    list.currentSortKey = "id"
    list.currentSortOrder = ZO_SORT_ORDER_UP

    list.sortFunction = function(row1, row2)
        return ZO_TableOrderingFunction(
                row1.data, row2.data,
                list.currentSortKey,
                {
                    ["id"] = {},
                    ["name"] = {},
                },
                list.currentSortOrder
        )
    end

    local colorText = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_VALUE))
    ZO_ScrollList_AddDataType(list.list, UNKNOWN_INSIGHT_DATA_TYPE, "UnknownInsightListRow", 30, function(row, data)
        list:SetupRow(row, data)

        row.data = data

        row.id = row:GetNamedChild("Id")
        row.name = row:GetNamedChild("Name")
        row.category = row:GetNamedChild("Category")
        row.isKnown = row:GetNamedChild("IsKnown")

        row.id:SetText(data.id)
        row.name:SetText(GetItemQualityColor(data.quality):Colorize(data.name))
        row.category:SetText(data.category)
        row.isKnown:SetText(data.isKnown and "Yes" or "No")

        for i = 1, row:GetNumChildren() do
            local child = row:GetChild(i)
            if child and child:GetType() == CT_LABEL then
                child.normalColor = colorText
            end
        end
    end)

    list.masterList = {}
    function list:BuildMasterList()
    end

    function list:FilterScrollList()
        local count = 0

        local scrollData = ZO_ScrollList_GetDataList(self.list)
        ZO_ClearNumericallyIndexedTable(scrollData)

        for categoryId, bitSet in pairs(self.owner.provider.data.items) do
            for itemId, _ in LibBitSetIterator(bitSet, 1) do
                local itemData = self.owner.provider:GetItemData(itemId)
                if self.owner:filter(itemData, categoryId) then
                    local isKnown
                    if self.owner.filterData.character == "-1" then
                        isKnown = self.owner:IsUnknownByAnyone(itemData.itemLink) == false
                    else
                        isKnown = self.owner.provider.data.characters[self.owner.filterData.character]:GetBit(itemData.id) == 1
                    end

                    table.insert(scrollData, ZO_ScrollList_CreateDataEntry(UNKNOWN_INSIGHT_DATA_TYPE, {
                        id = itemData.id,
                        name = itemData.name,
                        itemLink = itemData.itemLink,
                        quality = itemData.quality,
                        category = self.owner.categories[categoryId].name,
                        isKnown = isKnown
                    }))

                    count = count + 1
                end
            end
        end

        self.owner.control:GetNamedChild("InfoBarTotal"):SetText(string.format("Total: |cffffff%d", count))
    end

    function list:SortScrollList()
        local scrollData = ZO_ScrollList_GetDataList(self.list)
        table.sort(scrollData, self.sortFunction)
    end

    return list
end

function class:filter(itemData, category)
    local filterSearch = self.filterData.search
    local filterKnowledge = self.filterData.knowledge
    local filterCategory = self.filterData.category
    local filterCharacter = self.filterData.character

    local isKnown
    if filterCharacter == "-1" then
        isKnown = self:IsUnknownByAnyone(itemData.itemLink) == false
    else
        isKnown = self.provider.data.characters[filterCharacter]:GetBit(itemData.id) == 1
    end

    if filterSearch ~= "" and not self.searcher:IsMatch(filterSearch, { type = SEARCH_TYPE, name = itemData.name }) then
        return false
    end

    if filterCategory ~= CATEGORY_ALL and category ~= filterCategory then
        return false
    end

    if filterKnowledge == KNOWLEDGE_ALL then
        return true
    end

    if filterKnowledge == KNOWLEDGE_KNOWN and isKnown then
        return true
    end

    if filterKnowledge == KNOWLEDGE_UNKNOWN and not isKnown then
        return true
    end

    return false
end

function class:IsUnknownByCurrentCharacter(itemLink)
    return self:IsUnknownByCharacter(itemLink, self.currentCharacterId)
end

function class:IsUnknownByCharacter(itemLink, characterId)
    if self.provider.data.characters[characterId] == nil then
        return true
    end

    local itemId = GetItemLinkItemId(itemLink)

    return self.provider.data.characters[characterId]:GetBit(itemId) == 0
end

function class:IsUnknownByAnyone(itemLink)
    local itemId = GetItemLinkItemId(itemLink)

    for _, character in ipairs(LibCharacter:GetAccountCharacters(nil, LibCharacter.SORT_NAME)) do
        local bitSet = self.provider.data.characters[character.id]
        if bitSet ~= nil then
            if bitSet:GetBit(itemId) == 0 then
                return true
            end
        end
    end

    return false
end

function class:MouseEnter(control)
    local data = control.data

    self.list:Row_OnMouseEnter(control)

    InitializeTooltip(ItemTooltip, self.control, TOPRIGHT, -100, 0, TOPLEFT)
    ItemTooltip:SetLink(data.itemLink)
end

function class:MouseExit(control)
    self.list:Row_OnMouseExit(control)
    ItemTooltip:SetHidden(true)
end

local function urlEncode(str)
    if str then
        str = str:gsub("\n", "\r\n")
        str = str:gsub("([^%w %-%_%.%~])", function(c)
            return ("%%%02X"):format(string.byte(c))
        end)
        str = str:gsub(" ", "+")
    end
    return str
end

function class:MouseUp(control, button, upInside)
    local data = control.data

    if upInside and button == MOUSE_BUTTON_INDEX_LEFT then
        StartChatInput(CHAT_SYSTEM.textEntry:GetText() .. data.itemLink)
    end

    if upInside and button == MOUSE_BUTTON_INDEX_RIGHT then
        ClearMenu()

        AddMenuItem(GetString(SI_ITEM_ACTION_LINK_TO_CHAT), function()
            ZO_LinkHandler_InsertLink(zo_strformat(SI_TOOLTIP_ITEM_NAME, data.itemLink))
        end)

        AddMenuItem("Tamriel Trade Centre", function()
            LibCopyWindow:Show(string.format("https://%s.tamrieltradecentre.com/pc/Trade/SearchResult?SearchType=Sell&ItemNamePattern=%s", GetWorldName() == "EU Megaserver" and "eu" or "us", urlEncode(zo_strformat("<<t:1>>", data.name))))
        end)

        AddMenuItem("ESO-Hub", function()
            LibCopyWindow:Show(string.format("https://eso-hub.com/en/trading?query=%s&sort=last_seen_at&sortdir=desc&server=%s", urlEncode(zo_strformat("<<t:1>>", data.name)), GetWorldName() == "EU Megaserver" and "EU" or "NA"))
        end)

        ShowMenu(control)
    end
end

function class:addUnknownIndicatorToSlot(control, itemLink)
    --local iconName = "UnknownInsightIcon"
    --
    --local indicatorControl = control:GetNamedChild(iconName)
    --if indicatorControl == nil then
    --    indicatorControl = WINDOW_MANAGER:CreateControl(control:GetName() .. iconName, control, CT_TEXTURE)
    --
    --    indicatorControl:ClearAnchors()
    --    indicatorControl:SetDrawTier(DT_HIGH)
    --    indicatorControl:SetTexture(self.texturePath)
    --    indicatorControl:SetDimensions(self.settings.data.iconSize, self.settings.data.iconSize)
    --    indicatorControl:SetHidden(true)
    --end
    --indicatorControl:SetHidden(true)

    if self:isValid(itemLink) == false then
        return
    end

    --indicatorControl:SetAnchor(LEFT, control, LEFT, self.settings.data.iconXOffset, self.settings.data.iconYOffset)

    local colors = self:getColors()

    local knowledgeType = self:getKnowledgeType(itemLink)
    local color = colors[knowledgeType]
    --indicatorControl:SetColor(color.r, color.g, color.b)
    --indicatorControl:SetHidden(false)

    local statusControl = control:GetNamedChild("Status")
    if statusControl then
        statusControl:SetHidden(false) -- ZO_StoreWindowList
    end

    local iconControl = control:GetNamedChild("StatusTexture")
    if not iconControl then
        iconControl = control:GetNamedChild("StatusIcon") -- INVENTORY_GUILD_BANK
    end

    iconControl:ClearIcons()
    iconControl:AddIcon(texturePath, ZO_ColorDef:New(self:rgbToHex(color.r, color.g, color.b)))
    --iconControl:SetColor(color.r, color.g, color.b)
    iconControl:Show()
end

function class:hookInventory()
    local inventoryLists = {
        [PLAYER_INVENTORY.inventories[INVENTORY_BACKPACK].listView] = function(slot)
            return GetItemLink(slot.bagId, slot.slotIndex)
        end,
        [PLAYER_INVENTORY.inventories[INVENTORY_BANK].listView] = function(slot)
            return GetItemLink(slot.bagId, slot.slotIndex)
        end,
        [PLAYER_INVENTORY.inventories[INVENTORY_HOUSE_BANK].listView] = function(slot)
            return GetItemLink(slot.bagId, slot.slotIndex)
        end,
        [PLAYER_INVENTORY.inventories[INVENTORY_GUILD_BANK].listView] = function(slot)
            return GetItemLink(slot.bagId, slot.slotIndex)
        end,
        [ZO_StoreWindowList] = function(slot)
            return GetStoreItemLink(slot.slotIndex)
        end,
        [ZO_BuyBackList] = function(slot)
            return GetBuybackItemLink(slot.slotIndex)
        end,
    }

    for inventoryList, itemLinkGetter in pairs(inventoryLists) do
        if inventoryList and inventoryList.dataTypes and inventoryList.dataTypes[1] then
            local hooked = inventoryList.dataTypes[1].setupCallback
            inventoryList.dataTypes[1].setupCallback = function(rowControl, slot)
                hooked(rowControl, slot)

                local itemLink = itemLinkGetter(slot)
                self:addUnknownIndicatorToSlot(rowControl, itemLink)
            end
        end
    end
end

function class:hookTradingHouse()
    local inventoryLists = {
        [ZO_TradingHouseBrowseItemsRightPaneSearchResults] = function(slot)
            return GetTradingHouseSearchResultItemLink(slot.slotIndex)
        end,
    }

    for inventoryList, itemLinkGetter in pairs(inventoryLists) do
        if inventoryList and inventoryList.dataTypes and inventoryList.dataTypes[1] then
            local hookedFunctions = inventoryList.dataTypes[1].setupCallback
            inventoryList.dataTypes[1].setupCallback = function(rowControl, slot)
                hookedFunctions(rowControl, slot)

                local itemLink = itemLinkGetter(slot)
                self:addUnknownIndicatorToSlot(rowControl, itemLink)
            end
        end
    end
end

function class:hookAdvancedFilters()
    if AdvancedFilters_RegisterFilter == nil then
        return
    end

    local callbacks = {}
    table.insert(callbacks, {
        name = "Unknown by current character",
        filterCallback = function(slotData, slotIndex)
            local itemLink = GetItemLink(slotData.bagId, slotData.slotIndex)

            return self:IsUnknownByCurrentCharacter(itemLink)
        end
    })
    table.insert(callbacks, {
        name = "Unknown by any character",
        filterCallback = function(slotData, slotIndex)
            local itemLink = GetItemLink(slotData.bagId, slotData.slotIndex)

            return self:IsUnknownByAnyone(itemLink)
        end
    })
    table.insert(callbacks, {
        name = "Known by all characters",
        filterCallback = function(slotData, slotIndex)
            local itemLink = GetItemLink(slotData.bagId, slotData.slotIndex)

            return not self:IsUnknownByAnyone(itemLink)
        end
    })

    local filterData = {
        submenuName = self:getAddonData().title,
        callbackTable = callbacks,
        filterType = {},
        subfilters = {},
        enStrings = {
            ["Unknown Insight"] = "Unknown Insight",
            ["Unknown by current character"] = "Unknown by current character",
            ["Unknown by any character"] = "Unknown by any character",
            ["Known by all characters"] = "Known by all characters",
            -- ["All"] = "All",
        },
    }

    --filterData.filterType = {ITEMFILTERTYPE_ALL}
    --filterData.subfilters = {AF_CONST_ALL}
    --AdvancedFilters_RegisterFilter(filterData)

    filterData.filterType = { ITEMFILTERTYPE_CONSUMABLE }
    filterData.subfilters = { "Recipe", "Motif", "Container" }
    AdvancedFilters_RegisterFilter(filterData)
end

function class:getColors()
    return {
        [UI_KNOWLEDGE_TYPE_ALL] = self.settings.data.colorKnown,
        [UI_KNOWLEDGE_TYPE_PARTIAL] = self.settings.data.colorSemiUnknown,
        [UI_KNOWLEDGE_TYPE_CURRENT] = self.settings.data.colorUnknown,
    }
end

function class:tooltipHooks()
    if not self.settings.data.tooltip then
        return
    end

    self:tooltipHook(ItemTooltip, "SetBagItem", GetItemLink)
    self:tooltipHook(ItemTooltip, "SetTradeItem", GetTradeItemLink)
    self:tooltipHook(ItemTooltip, "SetBuybackItem", GetBuybackItemLink)
    self:tooltipHook(ItemTooltip, "SetStoreItem", GetStoreItemLink)
    self:tooltipHook(ItemTooltip, "SetAttachedMailItem", GetAttachedItemLink)
    self:tooltipHook(ItemTooltip, "SetLootItem", GetLootItemLink)
    self:tooltipHook(ItemTooltip, "SetTradingHouseItem", GetTradingHouseSearchResultItemLink)
    self:tooltipHook(ItemTooltip, "SetTradingHouseListing", GetTradingHouseListingItemLink)
    self:tooltipHook(ItemTooltip, "SetLink", function(...)
        return ...
    end)
    self:tooltipHook(PopupTooltip, "SetLink", function(...)
        return ...
    end)
end

function class:tooltipHook(control, method, itemLinkFunction)
    local addonSelf = self

    local hooked = control[method]
    control[method] = function(self, ...)
        hooked(self, ...)
        addonSelf:setTooltip(self, itemLinkFunction(...))
    end
end

function class:setTooltip(control, itemLink)
    if self:isValid(itemLink) == false then
        return
    end

    local colors = self:getColors()

    local textParts = {}

    if self:isAccountWide(itemLink) then
        local character = LibCharacter:GetCharacter(self.currentCharacterId)
        local color
        if self:IsUnknownByCharacter(itemLink, character.id) then
            color = colors[UI_KNOWLEDGE_TYPE_CURRENT]
        else
            color = colors[UI_KNOWLEDGE_TYPE_ALL]
        end
        table.insert(textParts, string.format("|c%s%s|r", self:rgbToHex(color.r, color.g, color.b), self.currentAccount))
    else
        for _, character in ipairs(LibCharacter:GetAccountCharacters(nil, LibCharacter.SORT_NAME)) do
            if self.settings.data.characters[character.id] == true then
                local color
                if self:IsUnknownByCharacter(itemLink, character.id) then
                    color = character.id == self.currentCharacterId and colors[UI_KNOWLEDGE_TYPE_CURRENT] or colors[UI_KNOWLEDGE_TYPE_PARTIAL]
                else
                    color = colors[UI_KNOWLEDGE_TYPE_ALL]
                end
                table.insert(textParts, string.format("|c%s%s|r", self:rgbToHex(color.r, color.g, color.b), character.name))
            end
        end
    end

    control:AddVerticalPadding(5)
    ZO_Tooltip_AddDivider(control)
    control:AddLine(string.upper(self.settings.data.tooltipHeader), "ZoFontGameBold", 1, 1, 1, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
    control:AddLine(table.concat(textParts, ", "), "", 1, 1, 1, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
end

function class:isValid(itemLink)
    local itemId = GetItemLinkItemId(itemLink)
    return self.provider:IsValid(itemId)
end

function class:isAccountWide(itemLink)
    local itemId = GetItemLinkItemId(itemLink)
    return self.provider:IsAccountWide(itemId)
end

function class:getKnowledgeType(itemLink)
    local itemId = GetItemLinkItemId(itemLink)
    return self.provider:GetKnowledgeType(itemId)
end

function class:rgbToHex(r, g, b)
    return string.format("%.2x%.2x%.2x", zo_floor(r * 255), zo_floor(g * 255), zo_floor(b * 255))
end

function class:chatHook(hook)
    if hook then
        local chatMessageFormatters = {}

        chatMessageFormatters[EVENT_CHAT_MESSAGE_CHANNEL] = CHAT_ROUTER:GetRegisteredMessageFormatters()[EVENT_CHAT_MESSAGE_CHANNEL]
        CHAT_ROUTER:RegisterMessageFormatter(EVENT_CHAT_MESSAGE_CHANNEL, function(messageType, fromName, text, isFromCustomerService, fromDisplayName)
            return chatMessageFormatters[EVENT_CHAT_MESSAGE_CHANNEL](messageType, fromName, self:replaceItemLinks(text), isFromCustomerService, fromDisplayName)
        end)
    end
end

function class:replaceItemLinks(message)
    local colors = self:getColors()

    local links = {}
    ZO_ExtractLinksFromText(message, { [ITEM_LINK_TYPE] = true }, links)

    local foundItemlinks = {}
    for _, originalItemLink in ipairs(links) do
        local messageParts = {}
        if self:isValid(originalItemLink.link) then
            local knowledgeType = self:getKnowledgeType(originalItemLink.link)
            if knowledgeType ~= UI_KNOWLEDGE_TYPE_ALL then
                local color = colors[knowledgeType]
                table.insert(messageParts, string.format("|c%s|t%d:%d:%s:inheritcolor|t|r", self:rgbToHex(color.r, color.g, color.b), 16, 16, texturePath))
            end
        end
        local itemLink = originalItemLink.link:gsub("^|H0", "|H1", 1)
        table.insert(messageParts, itemLink)
        foundItemlinks[originalItemLink.link] = table.concat(messageParts, "")
    end

    for itemLink, itemLinkWithIcon in pairs(foundItemlinks) do
        message = string.gsub(message, itemLink, itemLinkWithIcon)
    end

    return message
end

local highlightColor = ZO_ColorDef.FromInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_HIGHLIGHT)
local normalColor = ZO_ColorDef.FromInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_NORMAL)
local disabledColor = ZO_ColorDef.FromInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_DISABLED)
local selectedColor = ZO_ColorDef.FromInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_SELECTED)
local succeededColor = ZO_ColorDef.FromInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_SUCCEEDED)
local failedColor = ZO_ColorDef.FromInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_FAILED)
local hintColor = ZO_ColorDef.FromInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_HINT)
local defaultTextColor = ZO_ColorDef.FromInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_DEFAULT_TEXT)
local announcementsColor = ZO_ColorDef.FromInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_ANNOUNCEMENTS)
local gameRepresentativeColor = ZO_ColorDef.FromInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_GAME_REPRESENTATIVE)

function class:Success(message)
    CHAT_ROUTER:AddSystemMessage(string.format("|c%s[%s]|r |c%s%s|r", hintColor:ToHex(), self:Tag(), succeededColor:ToHex(), message))
end

function class:Error(message)
    CHAT_ROUTER:AddSystemMessage(string.format("|c%s[%s]|r |c%s%s|r", hintColor:ToHex(), self:Tag(), failedColor:ToHex(), message))
end

function class:Log(message)
    CHAT_ROUTER:AddSystemMessage(string.format("|c%s[%s]|r |c%s%s|r", hintColor:ToHex(), self:Tag(), gameRepresentativeColor:ToHex(), message))
end

function class:Tag()
    return self.addonData.title
end

function class:getAddonData()
    for index = 1, GetAddOnManager():GetNumAddOns() do
        local name, title, author, description, enabled, state, isOutOfDate, isLibrary = GetAddOnManager():GetAddOnInfo(index)
        if name == self.name then
            return {
                name = name,
                title = title,
                author = author,
                version = GetAddOnManager():GetAddOnVersion(index),
                directoryPath = GetAddOnManager():GetAddOnRootDirectoryPath(index),
                resolveFilePath = function(relativePath)
                    local str, _ = string.format("%s%s", GetAddOnManager():GetAddOnRootDirectoryPath(index), relativePath):gsub("user:/AddOns", "", 1)
                    return str
                end
            }
        end
    end

    return nil
end

EVENT_MANAGER:RegisterForEvent(addonId, EVENT_ADD_ON_LOADED, function(event, addonName)
    if addonName ~= addonId then
        return
    end
    assert(not _G[addonId], string.format("'%s' has already been loaded", addonId))
    _G[addonId] = class:New(addonId)
    EVENT_MANAGER:UnregisterForEvent(addonId, EVENT_ADD_ON_LOADED)
end)
