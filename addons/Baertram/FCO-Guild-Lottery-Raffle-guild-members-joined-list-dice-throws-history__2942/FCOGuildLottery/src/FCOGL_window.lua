if FCOGL == nil then FCOGL = {} end
local FCOGuildLottery = FCOGL

local addonName = FCOGuildLottery.addonVars.addonName
local addonNamePre = "["..addonName.."]"

--LibHistoire
local lh
--LibDateTime
--local ldt = FCOGuildLottery.LDT

--Debug messages
local df    = FCOGuildLottery.df
local dfa   = FCOGuildLottery.dfa
local dfe   = FCOGuildLottery.dfe
local dfv   = FCOGuildLottery.dfv
local dfw   = FCOGuildLottery.dfw

local tos = tostring
local ton = tonumber
local strfor = string.format

--Localization
local locVars = FCOGuildLottery.Localization
local yesStr = locVars.Yes
local noStr = locVars.No
locVars.boolean2String = {}
locVars.boolean2String[true] = yesStr
locVars.boolean2String[false] = noStr
local bool2Str = locVars.boolean2String

locVars.diceRollPrefix = GetString(FCOGL_DICE_PREFIX)

local isGuildSalesLotteryActive = FCOGuildLottery.IsGuildSalesLotteryActive
local isGuildMembersJoinDateListActive = FCOGuildLottery.IsGuildMembersJoinDateListActive

--UI variables
FCOGuildLottery.UI = FCOGuildLottery.UI or {}
local fcoglUI = FCOGuildLottery.UI

local fcoglUIwindow
local fcoglUIwindowFrame
local fcoglUIguildSalesLotteryWindow
local fcoglUIguildMembersJoinedWindow
local fcoglUIDiceHistoryWindow

fcoglUI.CurrentState    = FCOGL_TAB_STATE_LOADING
fcoglUI.CurrentTab      = FCOGL_TAB_GUILDSALESLOTTERY
fcoglUI.CurrentListType = FCOGL_LISTTYPE_NORMAL_THROWS

fcoglUI.ListTypeToListObject = {
    ["left"] = {
        [FCOGL_LISTTYPE_NORMAL_THROWS] =            nil,
        [FCOGL_LISTTYPE_GUILD_MEMBER_THROWS] =      nil,
        [FCOGL_LISTTYPE_GUILD_SALES_LOTTERY] =      fcoglUIguildSalesLotteryWindow,
        [FCOGL_LISTTYPE_GUILD_MEMBERS_JOIN_DATE] =  fcoglUIguildMembersJoinedWindow,
    },
    ["right"] = {
        [FCOGL_LISTTYPE_ROLLED_DICE_HISTORY] =      fcoglUIDiceHistoryWindow,
    }
}
local fcoglUIListTypeToListObject = fcoglUI.ListTypeToListObject

fcoglUI.comingFromSortScrollListSetupFunction = false
fcoglUI.selectedGuildDataBeforeUpdate = nil
fcoglUI.searchBoxLastSelected = {}

local buttonNewStateVal = {
    [true]  = 0,
    [false] = 1,
}

local SCROLLLIST_DATATYPE_GUILDSALESRANKING     = fcoglUI.SCROLLLIST_DATATYPE_GUILDSALESRANKING
local SCROLLLIST_DATATYPE_ROLLED_DICE_HISTORY   = fcoglUI.SCROLLLIST_DATATYPE_ROLLED_DICE_HISTORY
local SCROLLLIST_DATATYPE_GUILDMEMBERSJOINEDLIST= fcoglUI.SCROLLLIST_DATATYPE_GUILDMEMBERSJOINEDLIST

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function fcoglUI.GetListsObjectByListType(listType)
    df("[GetListsObjectByListType]listType: %s", tos(listType))
    --Only the left lists (right list = dice roll history!) will be supported here
    if fcoglUIListTypeToListObject["left"][listType] ~= nil then
        return fcoglUIListTypeToListObject["left"][listType]
    --[[
    elseif fcoglUIListTypeToListObject["right"][currentListType] ~= nil then
        return fcoglUIListTypeToListObject["right"][currentListType]
    ]]
    end
    return nil
end
local getListsObjectByListType = fcoglUI.GetListsObjectByListType

function fcoglUI.GetCurrentlyShownListsObject()
    local currentListType = fcoglUI.CurrentListType
    df("[FCOGLUI.GetCurrentlyShownListsObject]listType: %s", tos(currentListType))
    return getListsObjectByListType(currentListType)
end
local getCurrentlyShownListsObject = fcoglUI.GetCurrentlyShownListsObject

local function getHistoryList()
    if not fcoglUI then return end
    local fcoglUIdiceHistoryWindow = fcoglUI.diceHistoryWindow
    if not fcoglUIdiceHistoryWindow then return end
    return fcoglUIdiceHistoryWindow.masterList, fcoglUIdiceHistoryWindow
end

--Hide all list controls at the left TLC
local function hideLeftTLCListControlsExceptThis(doNotHideThisListObject, hideOthers)
--d(">---------------------------------->")
    hideOthers = hideOthers or false
    df("hideLeftTLCListControlsExceptThis - doNotHideObject: %s, hideOthers: %s", tos(doNotHideThisListObject), tos(hideOthers))
    --Hide all other lists?
    local hideAllNow = false
    if hideOthers == true then
        local currentlyActiveListObject = getCurrentlyShownListsObject()
        if currentlyActiveListObject ~= nil and currentlyActiveListObject.control ~= nil then
            if doNotHideThisListObject ~= nil then
                if doNotHideThisListObject ~= currentlyActiveListObject then
                    df(">hiding: %s", tos(currentlyActiveListObject.control:GetName()))
                    currentlyActiveListObject.control:SetHidden(true)
                else
                    df(">NOT hiding list, because it should be shown now: %s", tos(doNotHideThisListObject.control:GetName()))
                end
            else
                hideAllNow = true
            end
        else
            hideAllNow = true
        end
        if hideAllNow == true then
            df(">ALL hiding now...")
            --Hide all
            for listType, listObject in pairs(fcoglUIListTypeToListObject["left"]) do
                if listObject ~= nil and listObject.control ~= nil then
                    df(">>LOOP hiding: %s", tos(listObject.control:GetName()))
                    listObject.control:SetHidden(true)
                end
            end
        end
    end

    --Show the list object
    if doNotHideThisListObject ~= nil and doNotHideThisListObject.control ~= nil then
        df("<SHOWING: %s", tos(doNotHideThisListObject.control:GetName()))
        doNotHideThisListObject.control:SetHidden(false)
    end
--d("<----------------------------------<")
end


local function updateDiceSidesEditControl(value, isEnabled)
    local editBoxDiceSides = fcoglUIwindowFrame.editBoxDiceSides
    if editBoxDiceSides == nil then return end
    editBoxDiceSides:SetText(tos(value))
    editBoxDiceSides:SetMouseEnabled(isEnabled)
end

local function updateMaxDefaultDiceSides()
    local defaultSidesOfDice = FCOGuildLottery.settingsVars.settings.defaultDiceSides
    FCOGuildLottery.prevVars.doNotRunOnTextChanged = true
    updateDiceSidesEditControl(defaultSidesOfDice, true)
end

local function updateMaxGuildDiceSides(numDiceSides)
    FCOGuildLottery.prevVars.doNotRunOnTextChanged = true
    updateDiceSidesEditControl(numDiceSides, false)
end

local function setWindowPosition(windowFrame)
    if not windowFrame or (windowFrame and not windowFrame.SetAnchor) then return end
    local settings = FCOGuildLottery.settingsVars.settings
    local uiWindowSettings = settings.UIwindow
    local width, height = uiWindowSettings.width, uiWindowSettings.height

    local bg = windowFrame:GetNamedChild("BG")
    bg:ClearAnchors()
    windowFrame:ClearAnchors()
    windowFrame:SetDimensions(width, height)
    windowFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, uiWindowSettings.left, uiWindowSettings.top)
    bg:SetAnchorFill(windowFrame)
end


--[[
--Update the title of a scene's fragment with a new text
local function updateSceneFragmentTitle(sceneName, fragment, childName, newTitle)
    childName = childName or "Label"
    if sceneName == nil or fragment == nil or newTitle == nil then return false end
    local sm = SCENE_MANAGER
    if not sm then return false end
    local currentScene = sm.currentScene
    local currentSceneName = currentScene.name
    if not currentScene or not currentSceneName or not currentSceneName == sceneName or not currentScene.fragments then return end
    for _, fragmentInCurrentScene in ipairs(currentScene.fragments) do
        if fragmentInCurrentScene == fragment then
            if fragmentInCurrentScene then
                local fragmentCtrl = fragmentInCurrentScene.control
                if fragmentCtrl then
                    local fragmentCtrlChildLabel = fragmentCtrl:GetNamedChild(childName)
                    if fragmentCtrlChildLabel and fragmentCtrlChildLabel.SetText then
                        fragmentCtrlChildLabel:SetText(newTitle)
                    end
                end
            end
            return true
        end
    end
    return false
end
]]

local function sortByTimeStamp(a, b)
    if a.timestamp and b.timestamp and a.timestamp < b.timestamp then return true end
    return false
end
local function sortByDescTimeStamp(a, b)
    if a.timestamp and b.timestamp and a.timestamp > b.timestamp then return true end
    return false
end


local function updateDropdownEntries(dropdown, tabOfEntries)
    df("updateDropdownEntries")
    if not dropdown then return end

    dropdown:ClearAllSelections()
    dropdown:ClearItems()
    if tabOfEntries == nil or #tabOfEntries == 0 then return end

    for _, entryData in ipairs(tabOfEntries) do
        local entry = dropdown:CreateItemEntry(entryData.name)
        entry.guildId   = entryData.guildId
        entry.timestamp = entryData.timestamp
        entry.entryData = entryData
        dropdown:AddItem(entry)
    end
end

local function BuildMultiSelectDropdown(control, noSelectionStringText, multiSelectionFormatterId, tabOfEntries, onDropDownHiddenFunc)
    local dropdown = ZO_ComboBox_ObjectFromContainer(control)
    control.dropdown = dropdown
    dropdown:SetSortsItems(false)

    dropdown:ClearItems()

    if onDropDownHiddenFunc ~= nil and type(onDropDownHiddenFunc) == "function" then
        local function dropdownHiddenCallbackFunc()
            onDropDownHiddenFunc(dropdown)
        end
        dropdown:SetHideDropdownCallback(dropdownHiddenCallbackFunc)
    end
    dropdown:EnableMultiSelect(multiSelectionFormatterId, noSelectionStringText)

    updateDropdownEntries(dropdown, tabOfEntries)

    return dropdown
end

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
--FCOGuildLottery window - The UI
FCOGuildLottery.UI.windowClass = ZO_SortFilterList:Subclass()
local fcoglWindowClass = FCOGuildLottery.UI.windowClass

function fcoglWindowClass:New(control, listType, parentFrameControl)
	local list = ZO_SortFilterList.New(self, control)
    if parentFrameControl == nil then
--d(">parentFrameControl is NIL")
        list.frame = control
    else
--d(">parentFrameControl is not NIL")
        list.frame = parentFrameControl
        list.control:SetParent(parentFrameControl)
    end
    list.listType = listType
	list:Setup(listType)
	return list
end

function fcoglWindowClass:Setup(listType)
    --d("[fcoglWindow:Setup]")
    fcoglUI.comingFromSortScrollListSetupFunction = true
    fcoglUI.CurrentTab = FCOGL_TAB_GUILDSALESLOTTERY

    self.listType = listType

--For debugging:
--FCOGuildLottery.frames = FCOGuildLottery.frames or {}
--FCOGuildLottery.frames[listType] = self.frame

--FCOGuildLottery.lists = FCOGuildLottery.lists or {}
--FCOGuildLottery.lists[listType] = self


    --The guild sales lottery list
    if listType == FCOGL_LISTTYPE_GUILD_SALES_LOTTERY then
        --Scroll UI
        ZO_ScrollList_AddDataType(self.list, SCROLLLIST_DATATYPE_GUILDSALESRANKING, "FCOGLRowGuildSales", 30, function(control, data)
            self:SetupItemRow(control, data, self.listType)
        end)
        ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")
        self:SetAlternateRowBackgrounds(true)

        self.masterList = { }

        --The loading icon
        self.frame.loading = self.frame.loading or self.frame:GetNamedChild("Loading")
        self.frame.loading:Hide()
        self.loading = self.frame.loading

        --Build the sortkeys depending on the settings
        --self:BuildSortKeys() --> Will be called internally in "self.sortHeaderGroup:SelectAndResetSortForKey"
        --Default values
        --self.currentSortKey, self.currentSortOrder = fcoglUI.loadSortGroupHeader(fcoglUI.CurrentTab, self.listType)
        --self.sortHeaderGroup:SelectAndResetSortForKey(self.currentSortKey) -- Will call "SortScrollList" internally
        local currentSortKey, currentSortOrder = fcoglUI.loadSortGroupHeader(fcoglUI.CurrentTab, self.listType)
        df(">Setup List 1 BEFORE - self.currentSortKey: %s, self.currentSortOrder: %s, svCurrentSortKey: %s, svCurrentSortOrder: %s", tos(self.currentSortKey), tos(self.currentSortOrder), tos(currentSortKey), tos(currentSortOrder))
        self:resetSortGroupHeader(fcoglUI.CurrentTab, self.listType)
        df(">>Setup List 1 AFTER self.currentSortOrder: %s", tos(self.currentSortOrder))
        --The sort function
        self.sortFunction = function( listEntry1, listEntry2 )
            if     self.currentSortKey == nil or self.sortKeys[self.currentSortKey] == nil
                    or listEntry1.data == nil or listEntry1.data[self.currentSortKey] == nil
                    or listEntry2.data == nil or listEntry2.data[self.currentSortKey] == nil then
                return nil
            end
            return(ZO_TableOrderingFunction(listEntry1.data, listEntry2.data, self.currentSortKey, self.sortKeys, self.currentSortOrder))
        end
        --Search
        self.searchDropCtrl = self.frame:GetNamedChild("SearchDrop")
        self.searchDrop = ZO_ComboBox_ObjectFromContainer(self.searchDropCtrl)
        local searchDropBG = self.searchDropCtrl:GetNamedChild("BG")
        searchDropBG:SetHidden(true)
        self:initializeSearchDropdown(FCOGL_TAB_GUILDSALESLOTTERY, self.listType, "name")
        if self.frame.searchDrop == nil then
            self.frame.searchDrop = self.searchDrop
        end
        --Guilds
        self.guildsDropCtrl = self.frame:GetNamedChild("GuildsDrop")
        self.guildsDrop = ZO_ComboBox_ObjectFromContainer(self.guildsDropCtrl)
        local guildsDropBG = self.guildsDropCtrl:GetNamedChild("BG")
        guildsDropBG:SetHidden(true)
        self:initializeSearchDropdown(FCOGL_TAB_GUILDSALESLOTTERY, self.listType, "guilds")
        if self.frame.guildsDrop == nil then
            self.frame.guildsDrop = self.guildsDrop
        end

        --Search box and search functions
        self.searchBg = self.frame:GetNamedChild("Search")
        self.searchBox = self.frame:GetNamedChild("SearchBox")
        self.searchBox:SetHandler("OnTextChanged", function()
            --Get the currently shown list and use it's search method
            local listObject = getCurrentlyShownListsObject()
            if listObject ~= nil then
                listObject:RefreshFilters()
            end
        end)
        self.searchBox:SetHandler("OnMouseUp", function(ctrl, mouseButton, upInside)
            --[[
            if mouseButton == MOUSE_BUTTON_INDEX_RIGHT and upInside then
                self:OnSearchEditBoxContextMenu(self.searchBox)
            end
            ]]
        end)
        if self.frame.searchBg == nil then
            self.frame.searchBg = self.searchBg
        end
        if self.frame.searchBox == nil then
            self.frame.searchBox = self.searchBox
        end

        self.search = ZO_StringSearch:New()
        self.search:AddProcessor(SCROLLLIST_DATATYPE_GUILDSALESRANKING, function(stringSearch, data, searchTerm, cache)
            return(self:ProcessItemEntry(stringSearch, data, searchTerm, cache))
        end)

        --Sort headers
        self.headers        = self.control:GetNamedChild("Headers")
        self.headerRank     = self.headers:GetNamedChild("Rank")
        self.headerName     = self.headers:GetNamedChild("Name")
        --self.headerItem     = self.headers:GetNamedChild("Item")
        self.headerPrice    = self.headers:GetNamedChild("Price")
        self.headerTax      = self.headers:GetNamedChild("Tax")
        self.headerAmount   = self.headers:GetNamedChild("Amount")
        self.headerInfo     = self.headers:GetNamedChild("Info")

        self.guildSalesDateStartLabel = self.frame:GetNamedChild("GuildLotteryDateStartLabel")
        self.guildMembersListDateStartLabel = self.frame:GetNamedChild("GuildMembersListDateStartLabel")

        self.editBoxDiceSides = self.frame:GetNamedChild("EditDiceSidesBox")
        self.editBoxDiceSides:SetTextType(TEXT_TYPE_NUMERIC_UNSIGNED_INT)
        --[[
        FCOGuildLottery.prevVars.doNotRunOnTextChanged = true
        local tempEditBoxNumDices = FCOGuildLottery.tempEditBoxNumDiceSides
        local editBoxNewValue = tempEditBoxNumDices or FCOGuildLottery.settingsVars.settings.defaultDiceSides
        FCOGuildLottery.tempEditBoxNumDiceSides = nil
        self.editBoxDiceSides:SetText(tos(editBoxNewValue))
        ]]
        if self.frame.editBoxDiceSides == nil then
            self.frame.editBoxDiceSides = self.editBoxDiceSides
        end

        --Build initial masterlist via self:BuildMasterList()
        --d("[fcoglUI.Setup] RefreshData > BuildMasterList ???")

    --The Guild members joined list
    elseif listType == FCOGL_LISTTYPE_GUILD_MEMBERS_JOIN_DATE then
        --Scroll UI
        ZO_ScrollList_AddDataType(self.list, SCROLLLIST_DATATYPE_GUILDMEMBERSJOINEDLIST, "FCOGLRowGuildMembersJoined", 30, function(control, data)
            self:SetupItemRow(control, data, self.listType)
        end)
        ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")
        self:SetAlternateRowBackgrounds(true)

        self.masterList = { }

        --The loading icon
        self.frame.loading = self.frame.loading or self.frame:GetNamedChild("Loading")
        self.frame.loading:Hide()
        self.loading = self.frame.loading

        --Build the sortkeys depending on the settings
        --self:BuildSortKeys() --> Will be called internally in "self.sortHeaderGroup:SelectAndResetSortForKey"
        --Default values
        --self.currentSortKey, self.currentSortOrder = fcoglUI.loadSortGroupHeader(fcoglUI.CurrentTab, self.listType)
        --self.sortHeaderGroup:SelectAndResetSortForKey(self.currentSortKey) -- Will call "SortScrollList" internally
        local currentSortKey, currentSortOrder = fcoglUI.loadSortGroupHeader(fcoglUI.CurrentTab, self.listType)
        df(">Setup List 1 BEFORE - self.currentSortKey: %s, self.currentSortOrder: %s, svCurrentSortKey: %s, svCurrentSortOrder: %s", tos(self.currentSortKey), tos(self.currentSortOrder), tos(currentSortKey), tos(currentSortOrder))
        self:resetSortGroupHeader(fcoglUI.CurrentTab, self.listType)
        df(">>Setup List 1 AFTER self.currentSortOrder: %s", tos(self.currentSortOrder))
        --The sort function
        self.sortFunction = function( listEntry1, listEntry2 )
            if     self.currentSortKey == nil or self.sortKeys[self.currentSortKey] == nil
                    or listEntry1.data == nil or listEntry1.data[self.currentSortKey] == nil
                    or listEntry2.data == nil or listEntry2.data[self.currentSortKey] == nil then
                return nil
            end
            return(ZO_TableOrderingFunction(listEntry1.data, listEntry2.data, self.currentSortKey, self.sortKeys, self.currentSortOrder))
        end
        --Search
        self.searchDropCtrl = self.frame:GetNamedChild("SearchDrop")
        self.searchDrop = ZO_ComboBox_ObjectFromContainer(self.searchDropCtrl)
        local searchDropBG = self.searchDropCtrl:GetNamedChild("BG")
        searchDropBG:SetHidden(true)
        self:initializeSearchDropdown(FCOGL_TAB_GUILDSALESLOTTERY, self.listType, "name")
        if self.frame.searchDrop == nil then
            self.frame.searchDrop = self.searchDrop
        end
        --Guilds
        self.guildsDropCtrl = self.frame:GetNamedChild("GuildsDrop")
        self.guildsDrop = ZO_ComboBox_ObjectFromContainer(self.guildsDropCtrl)
        local guildsDropBG = self.guildsDropCtrl:GetNamedChild("BG")
        guildsDropBG:SetHidden(true)
        self:initializeSearchDropdown(FCOGL_TAB_GUILDSALESLOTTERY, self.listType, "guilds")
        if self.frame.guildsDrop == nil then
            self.frame.guildsDrop = self.guildsDrop
        end

        --Search box and search functions
        self.searchBg = self.frame:GetNamedChild("Search")
        self.searchBox = self.frame:GetNamedChild("SearchBox")
        self.searchBox:SetHandler("OnTextChanged", function()
            --Get the currently shown list and use it's search method
            local listObject = getCurrentlyShownListsObject()
            if listObject ~= nil then
                listObject:RefreshFilters()
            end
        end)
        --self.searchBox:SetHandler("OnMouseUp", function(ctrl, mouseButton, upInside)
            --[[
            if mouseButton == MOUSE_BUTTON_INDEX_RIGHT and upInside then
                self:OnSearchEditBoxContextMenu(self.searchBox)
            end
            ]]
        --end)
        if self.frame.searchBg == nil then
            self.frame.searchBg = self.searchBg
        end
        if self.frame.searchBox == nil then
            self.frame.searchBox = self.searchBox
        end

        self.search = ZO_StringSearch:New()
        self.search:AddProcessor(SCROLLLIST_DATATYPE_GUILDMEMBERSJOINEDLIST, function(stringSearch, data, searchTerm, cache)
            return(self:ProcessItemEntry(stringSearch, data, searchTerm, cache))
        end)

        --Sort headers
        self.headers        = self.control:GetNamedChild("Headers")
        self.headerRank     = self.headers:GetNamedChild("Rank")
        self.headerName     = self.headers:GetNamedChild("Name")
        self.headerInvitedBy= self.headers:GetNamedChild("InvitedBy")
        self.headerInfo     = self.headers:GetNamedChild("Info")

        self.guildSalesDateStartLabel = self.frame:GetNamedChild("GuildLotteryDateStartLabel")
        self.guildMembersListDateStartLabel = self.frame:GetNamedChild("GuildMembersListDateStartLabel")

        self.editBoxDiceSides = self.frame:GetNamedChild("EditDiceSidesBox")
        --self.editBoxDiceSides:SetTextType(TEXT_TYPE_NUMERIC_UNSIGNED_INT)
        FCOGuildLottery.prevVars.doNotRunOnTextChanged = true
        local tempEditBoxNumDices = FCOGuildLottery.tempEditBoxNumDiceSides
        local editBoxNewValue = tempEditBoxNumDices or FCOGuildLottery.settingsVars.settings.defaultDiceSides
        FCOGuildLottery.tempEditBoxNumDiceSides = nil
        self.editBoxDiceSides:SetText(tos(editBoxNewValue))
        if self.frame.editBoxDiceSides == nil then
            self.frame.editBoxDiceSides = self.editBoxDiceSides
        end


    --The rolled dice history list
    elseif listType == FCOGL_LISTTYPE_ROLLED_DICE_HISTORY then

        --Scroll UI
        ZO_ScrollList_AddDataType(self.list, SCROLLLIST_DATATYPE_ROLLED_DICE_HISTORY, "FCOGLRowDiceHistory", 30, function(control, data)
            self:SetupItemRow(control, data, self.listType)
        end)
        ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")
        self:SetAlternateRowBackgrounds(true)

        self.masterList = { }

        --Build the sortkeys depending on the settings
        --self:BuildSortKeys() --> Will be called internally in "self.sortHeaderGroup:SelectAndResetSortForKey"
        --self.currentSortKey, self.currentSortOrder = fcoglUI.loadSortGroupHeader(fcoglUI.CurrentTab, self.listType)
        --self.sortHeaderGroup:SelectAndResetSortForKey(self.currentSortKey) -- Will call "SortScrollList" internally
        self:resetSortGroupHeader(fcoglUI.CurrentTab, self.listType)
        df(">Setup List 2 - self.currentSortOrder: %s", tos(self.currentSortOrder))
        --The sort function
        self.sortFunction = function( listEntry1, listEntry2 )
            if     self.currentSortKey == nil or self.sortKeys[self.currentSortKey] == nil
                    or listEntry1.data == nil or listEntry1.data[self.currentSortKey] == nil
                    or listEntry2.data == nil or listEntry2.data[self.currentSortKey] == nil then
                return nil
            end
            return(ZO_TableOrderingFunction(listEntry1.data, listEntry2.data, self.currentSortKey, self.sortKeys, self.currentSortOrder))
        end
        --Search
        self.searchDropCtrl = self.frame:GetNamedChild("SearchDrop")
        self.searchDrop = ZO_ComboBox_ObjectFromContainer(self.searchDropCtrl)
        local searchDropBG = self.searchDropCtrl:GetNamedChild("BG")
        searchDropBG:SetHidden(true)
        self.initializeSearchDropdown(self, FCOGL_TAB_GUILDSALESLOTTERY, self.listType, "name")

        --Search box and search functions
        self.searchBg = self.frame:GetNamedChild("Search")
        self.searchBox = self.frame:GetNamedChild("SearchBox")
        self.searchBox:SetHandler("OnTextChanged", function() self:RefreshFilters() end)
        self.searchBox:SetHandler("OnMouseUp", function(ctrl, mouseButton, upInside)
            --[[
            if mouseButton == MOUSE_BUTTON_INDEX_RIGHT and upInside then
                self:OnSearchEditBoxContextMenu(self.searchBox)
            end
            ]]
        end)
        self.search = ZO_StringSearch:New()
        self.search:AddProcessor(SCROLLLIST_DATATYPE_ROLLED_DICE_HISTORY, function(stringSearch, data, searchTerm, cache)
            return(self:ProcessItemEntry(stringSearch, data, searchTerm, cache))
        end)

        --Sort headers
        --Dice history headers
        self.headers        = self.control:GetNamedChild("Headers")
        self.headerNo       = self.headers:GetNamedChild("No")
        self.headerName     = self.headers:GetNamedChild("Name")
        self.headerDate     = self.headers:GetNamedChild("DateTime")
        self.headerRoll     = self.headers:GetNamedChild("Roll")

        self.historyTypeLabel = self.frame:GetNamedChild("HistoryTypeLabel")
        self.guildSalesHistoryInfoLabel = self.frame:GetNamedChild("GuildSalesHistoryInfoLabel")
        self.guildMembersJoinedDateHistoryInfoLabel = self.frame:GetNamedChild("GuildMembersJoinedDateHistoryInfoLabel")

        --Guild sales lottery dropdown and multi select dropdown, delete button
        self.guildHistoryDropCtrl = self.frame:GetNamedChild("GuildHistoryDrop")
        self.guildHistoryDrop = ZO_ComboBox_ObjectFromContainer(self.guildHistoryDropCtrl)
        --self.guildHistoryDrop.m_font = "MyFontGame20" --Only changes the dropdwn entrie's font. selectedItemFont can be changed how?
        self.guildHistoryDrop:SetSelectedItemFont("ZoFontGameSmall")
        local guildHistoryDropBG = self.guildHistoryDropCtrl:GetNamedChild("BG")
        guildHistoryDropBG:SetHidden(true)
        self:initializeSearchDropdown(FCOGL_TAB_GUILDSALESLOTTERY, self.listType, "GuildSalesHistory")
        self.guildHistoryDeleteDropContainer = self.frame:GetNamedChild("GuildHistoryDeleteDrop")
        self.guildHistoryDeleteDrop = BuildMultiSelectDropdown(self.guildHistoryDeleteDropContainer,
                GetString(FCOGL_DELETE_HISTORY_NONE_SELECTED),
                FCOGL_DELETE_HISTORY_SOME_SELECTED,
                {}, --will be filled via function fcoglUI.updateGuildSalesLotteryHistoryDeleteDropdownEntries()
                function(selfVar)
                    fcoglUI.updateDeleteSelectedGuildSalesLotteryHistoryButton(selfVar)
                end
        )
        --Hide the original background control and only show the BGNew backdrop
        self.guildHistoryDeleteDrop.bgControl = self.guildHistoryDeleteDropContainer:GetNamedChild("BG")
        self.guildHistoryDeleteDrop.bgControl:SetHidden(true)
        self.guildHistoryDeleteSelectedButton = self.frame:GetNamedChild("GuildHistoryDeleteSelected")
        self.guildHistoryDeleteSelectedButton:SetMouseEnabled(false)

        --Guild members joined date dropdown and multi select dropdown, delete button
        self.guildMembersJoinedDateHistoryDropCtrl = self.frame:GetNamedChild("GuildMemberJoinedDateHistoryDrop")
        self.guildMembersJoinedDateHistoryDrop = ZO_ComboBox_ObjectFromContainer(self.guildMembersJoinedDateHistoryDropCtrl)
        self.guildMembersJoinedDateHistoryDrop:SetSelectedItemFont("ZoFontGameSmall")
        local guildMembersJoinedDateHistoryDropBG = self.guildMembersJoinedDateHistoryDropCtrl:GetNamedChild("BG")
        guildMembersJoinedDateHistoryDropBG:SetHidden(true)
        self:initializeSearchDropdown(FCOGL_TAB_GUILDSALESLOTTERY, self.listType, "GuildMembersJoinedDateHistory")
        self.guildMembersJoinedDateHistoryDeleteDropContainer = self.frame:GetNamedChild("GuildMembersJoinedDateHistoryDeleteDrop")
        self.guildMembersJoinedDateHistoryDeleteDrop = BuildMultiSelectDropdown(self.guildMembersJoinedDateHistoryDeleteDropContainer,
                GetString(FCOGL_DELETE_HISTORY_NONE_SELECTED),
                FCOGL_DELETE_HISTORY_SOME_SELECTED,
                {}, --will be filled via function fcoglUI.updateGuildMembersJoinedDateListHistoryDeleteDropdownEntries()
                function(selfVar)
                    fcoglUI.updateDeleteSelectedGuildMembersJoinedDateHistoryButton(selfVar)
                end
        )
        --Hide the original background control and only show the BGNew backdrop
        self.guildMembersJoinedDateHistoryDeleteDrop.bgControl = self.guildMembersJoinedDateHistoryDeleteDropContainer:GetNamedChild("BG")
        self.guildMembersJoinedDateHistoryDeleteDrop.bgControl:SetHidden(true)
        self.guildMembersJoinedDateHistoryDeleteSelectedButton = self.frame:GetNamedChild("GuildMembersJoinedDateHistoryDeleteSelected")
        self.guildMembersJoinedDateHistoryDeleteSelectedButton:SetMouseEnabled(false)

        self.clearHistoryButton = self.frame:GetNamedChild("ClearHistory")
        self.clearHistoryButton:SetMouseEnabled(false)
    end

    fcoglUI.enableSaveSortGroupHeaders(self.headers)

    --self.headers:SetHidden(true)
    --self.list = self.frame:GetNamedChild("List")
    --self.list:SetHidden(true)

    --[[
        --self:RefreshData() will run:
        -->self:BuildMasterList()
        -->self:FilterScrollList()
        -->self:SortScrollList()
        -->self:CommitScrollList()
    ]]
    self:RefreshData()
end

function fcoglWindowClass:GetListType()
--d("GetListType - listType: " ..tos(self.listType))
    return self.listType
end

function fcoglWindowClass:BuildMasterList(calledFromFilterFunction)
    calledFromFilterFunction = calledFromFilterFunction or false
    local listType                           = self:GetListType()
    local isGuildSalesLotteryCurrentlyActive     = isGuildSalesLotteryActive()
    local isGuildMemberJoinedListCurrentlyActive = isGuildMembersJoinDateListActive()

    df("list:BuildMasterList-calledFromFilterFunction: %s, currentTab: %s, listType: %s, guildLotteryActive: %s", tos(calledFromFilterFunction), tos(fcoglUI.CurrentTab), tos(listType), tos(isGuildSalesLotteryCurrentlyActive))
    if listType == nil then return end

    if fcoglUI.CurrentTab == FCOGL_TAB_GUILDSALESLOTTERY then
        --Guild sales lottery is active?
        if listType == FCOGL_LISTTYPE_GUILD_SALES_LOTTERY then
            if isGuildSalesLotteryCurrentlyActive == true then
                self.masterList = {}

                local rankingData = FCOGuildLottery.currentlyUsedGuildSalesLotteryMemberSellRank
                if rankingData == nil or #rankingData == 0 then return false end
                for i = 1, #rankingData do
                    local item = rankingData[i]
                    table.insert(self.masterList, self:CreateGuildSalesRankingEntry(item))
                end
                --self:updateSortHeaderAnchorsAndPositions(fcoglUI.CurrentTab, settings.maxNameColumnWidth, 32)
                --elseif FCOGuildLottery.currentlyUsedDiceRollGuildId ~= nil then
                --TODO Show the normal guild members list at the ranks list?
            end
            ------------------------------------------------------------------------------------------------------------------------
        elseif listType == FCOGL_LISTTYPE_GUILD_MEMBERS_JOIN_DATE then
            if isGuildMemberJoinedListCurrentlyActive == true then
                self.masterList = {}

                local guildMembersJoinedListData = FCOGuildLottery.currentlyUsedGuildMembersJoinDateMemberListData
                if guildMembersJoinedListData == nil or #guildMembersJoinedListData == 0 then return false end
                for i = 1, #guildMembersJoinedListData do
                    local item = guildMembersJoinedListData[i]
                    table.insert(self.masterList, self:CreateGuildMemberJoinedListEntry(item))
                end
                --self:updateSortHeaderAnchorsAndPositions(fcoglUI.CurrentTab, settings.maxNameColumnWidth, 32)
                --elseif FCOGuildLottery.currentlyUsedDiceRollGuildId ~= nil then
                --TODO Show the normal guild members list at the ranks list?
            end
        --[[
        else

            if listType ~= FCOGL_LISTTYPE_ROLLED_DICE_HISTORY then
                fcoglUI.CurrentListType = listType
                hideLeftTLCListControlsExceptThis(listType)
            end
        ]]
        end
------------------------------------------------------------------------------------------------------------------------
        --Dice history is shown? MasterList can be build in addition to the left TLC's list
        if listType == FCOGL_LISTTYPE_ROLLED_DICE_HISTORY then
            self.masterList = {}

            local tableWithLastDiceThrows

            if isGuildSalesLotteryCurrentlyActive == true then
                local currentGuildSalesLotteryGuildId = FCOGuildLottery.currentlyUsedGuildSalesLotteryGuildId
                local currentGuildSalesLotteryUniqueId = FCOGuildLottery.currentlyUsedGuildSalesLotteryUniqueIdentifier
                local currentlyUsedGuildSalesLotteryTimestamp = FCOGuildLottery.currentlyUsedGuildSalesLotteryTimestamp
                if not currentGuildSalesLotteryGuildId or not currentGuildSalesLotteryUniqueId or not currentlyUsedGuildSalesLotteryTimestamp then
                    df("<<<ERROR: Current guild sales lottery guildId or uniqueId missing!")
                end
                tableWithLastDiceThrows = FCOGuildLottery.diceRollGuildLotteryHistory[currentGuildSalesLotteryGuildId][currentGuildSalesLotteryUniqueId][currentlyUsedGuildSalesLotteryTimestamp]
            elseif isGuildMemberJoinedListCurrentlyActive == true then
                local currentlyUsedGuildMembersJoinDateGuildId = FCOGuildLottery.currentlyUsedGuildMembersJoinDateGuildId
                local currentlyUsedGuildMembersJoinDateUniqueId = FCOGuildLottery.currentlyUsedGuildMembersJoinDateUniqueIdentifier
                local currentlyUsedGuildMembersJoinDateTimestamp = FCOGuildLottery.currentlyUsedGuildMembersJoinDateTimestamp
                if not currentlyUsedGuildMembersJoinDateGuildId or not currentlyUsedGuildMembersJoinDateUniqueId or not currentlyUsedGuildMembersJoinDateTimestamp then
                    df("<<<ERROR: Current guild members joined list guildId or uniqueId missing!")
                end
                tableWithLastDiceThrows = FCOGuildLottery.diceRollGuildMemberJoinedDateListHistory[currentlyUsedGuildMembersJoinDateGuildId][currentlyUsedGuildMembersJoinDateUniqueId][currentlyUsedGuildMembersJoinDateTimestamp]

            else
                --No guild sales lottery
                if FCOGuildLottery.currentlyUsedDiceRollGuildId ~= nil then
                    --guild member dice throws
                    tableWithLastDiceThrows = FCOGuildLottery.diceRollGuildsHistory[FCOGuildLottery.currentlyUsedDiceRollGuildId]
                else
                    --just normal dice throws
                    tableWithLastDiceThrows = FCOGuildLottery.diceRollHistory
                end
            end
            if tableWithLastDiceThrows == nil or NonContiguousCount(tableWithLastDiceThrows) == 0 then
                df("<<<ERROR: BuildMasterlist did not find any tabledata to read from!")
                return false
            end
            local helperList = {}
            if isGuildSalesLotteryCurrentlyActive == true then
                for timeStamp, diceThrowData in pairs(tableWithLastDiceThrows) do
                    if timeStamp ~= "daysBefore" then
                        table.insert(helperList, diceThrowData)
                    end
                end
            elseif isGuildMemberJoinedListCurrentlyActive == true then
                for timeStamp, diceThrowData in pairs(tableWithLastDiceThrows) do
                    if timeStamp ~= "daysBefore" then
                        table.insert(helperList, diceThrowData)
                    end
                end
            else
                for _, diceThrowData in pairs(tableWithLastDiceThrows) do
                    table.insert(helperList, diceThrowData)
                end
            end
            table.sort(helperList, sortByTimeStamp)

            for _, diceThrowDataSorted in ipairs(helperList) do
                diceThrowDataSorted.no = #self.masterList + 1
                table.insert(self.masterList, self:CreateDiceThrowHistoryEntry(diceThrowDataSorted))
            end
        end
    end
end

--Setup the data of each row which gets added to the ZO_SortFilterList
function fcoglWindowClass:SetupItemRow(control, data, listType)
--df("SetupItemRow - listType: %s,comingFromSortScrollListSetupFunction: %s", tos(listType), tos(fcoglUI.comingFromSortScrollListSetupFunction))
    --if fcoglUI.comingFromSortScrollListSetupFunction then return end

    if listType == FCOGL_LISTTYPE_GUILD_SALES_LOTTERY then
        --local clientLang = fcoglUI.clientLang or fcoglUI.fallbackSetLang
        control:SetMouseEnabled(true)

        control.data = data
        --local updateSortHeaderDimensionsAndAnchors = false
        local rankColumn = control:GetNamedChild("Rank")
        local nameColumn = control:GetNamedChild("Name")
        local priceColumn = control:GetNamedChild("Price")
        local taxColumn = control:GetNamedChild("Tax")
        --local dateColumn = control:GetNamedChild("DateTime")
        local amountColumn = control:GetNamedChild("Amount")
        local infoColumn = control:GetNamedChild("Info")
        ------------------------------------------------------------------------------------------------------------------------
        if fcoglUI.CurrentTab == FCOGL_TAB_GUILDSALESLOTTERY then
            --local dateTimeStamp = data.timestamp
            --local dateTimeStr = fcoglUI.getDateTimeFormatted(dateTimeStamp)
            --dateColumn:ClearAnchors()
            --dateColumn:SetAnchor(LEFT, control, nil, 0, 0)
            --dateColumn:SetText(dateTimeStr)
            --dateColumn:SetHidden(false)
            rankColumn:SetHidden(false)
            rankColumn:ClearAnchors()
            rankColumn:SetAnchor(LEFT, control, nil, 0, 0)
            rankColumn:SetText(data.rank)
            rankColumn:SetMouseEnabled(true)
            nameColumn:ClearAnchors()
            nameColumn.normalColor = ZO_DEFAULT_TEXT
            if not data.columnWidth then data.columnWidth = 200 end
            nameColumn:SetDimensions(data.columnWidth, 30)
            nameColumn:SetAnchor(LEFT, rankColumn, RIGHT, 0, 0)
            nameColumn:SetText(data.name)
            nameColumn:SetHidden(false)
            nameColumn:SetMouseEnabled(true)
            priceColumn:SetHidden(false)
            priceColumn:ClearAnchors()
            priceColumn:SetAnchor(LEFT, nameColumn, RIGHT, 0, 0)
            priceColumn:SetText(data.price)
            priceColumn:SetMouseEnabled(true)
            taxColumn:SetHidden(false)
            taxColumn:ClearAnchors()
            taxColumn:SetAnchor(LEFT, priceColumn, RIGHT, 0, 0)
            taxColumn:SetText(data.tax)
            taxColumn:SetMouseEnabled(true)
            amountColumn:SetHidden(false)
            amountColumn:ClearAnchors()
            amountColumn:SetAnchor(LEFT, taxColumn, RIGHT, 0, 0)
            amountColumn:SetText(data.amount)
            amountColumn:SetMouseEnabled(true)
            infoColumn:SetHidden(false)
            infoColumn:ClearAnchors()
            infoColumn:SetAnchor(LEFT, amountColumn, RIGHT, 0, 0)
            infoColumn:SetAnchor(RIGHT, control, RIGHT, 0, 0)
            infoColumn:SetText(data.info)
            infoColumn:SetMouseEnabled(true)
        end


    elseif listType == FCOGL_LISTTYPE_GUILD_MEMBERS_JOIN_DATE then
        control.data = data

        local rankColumn = control:GetNamedChild("Rank")
        local nameColumn = control:GetNamedChild("Name")
        local invitedByColumn = control:GetNamedChild("InvitedBy")
        local infoColumn = control:GetNamedChild("Info")

        if fcoglUI.CurrentTab == FCOGL_TAB_GUILDSALESLOTTERY then
            --local dateTimeStamp = data.timestamp
            --local dateTimeStr = fcoglUI.getDateTimeFormatted(dateTimeStamp)
            --dateColumn:ClearAnchors()
            --dateColumn:SetAnchor(LEFT, control, nil, 0, 0)
            --dateColumn:SetText(dateTimeStr)
            --dateColumn:SetHidden(false)
            rankColumn:SetHidden(false)
            rankColumn:ClearAnchors()
            rankColumn:SetAnchor(LEFT, control, nil, 0, 0)
            rankColumn:SetText(data.rank)
            rankColumn:SetMouseEnabled(true)
            nameColumn:ClearAnchors()
            nameColumn.normalColor = ZO_DEFAULT_TEXT
            if not data.columnWidth then data.columnWidth = 200 end
            nameColumn:SetDimensions(data.columnWidth, 30)
            nameColumn:SetAnchor(LEFT, rankColumn, RIGHT, 0, 0)
            nameColumn:SetText(data.name)
            nameColumn:SetHidden(false)
            nameColumn:SetMouseEnabled(true)
            invitedByColumn:SetAnchor(LEFT, nameColumn, RIGHT, 0, 0)
            invitedByColumn:SetText(data.invitedBy)
            invitedByColumn:SetHidden(false)
            invitedByColumn:SetMouseEnabled(true)
            infoColumn:SetHidden(false)
            infoColumn:ClearAnchors()
            infoColumn:SetAnchor(LEFT, invitedByColumn, RIGHT, 0, 0)
            infoColumn:SetAnchor(RIGHT, control, RIGHT, 0, 0)
            --local dateTimeStamp = data.timestamp
            --local dateTimeStr = FCOGuildLottery.getDateTimeFormatted(dateTimeStamp)
            infoColumn:SetText(data.info)
            infoColumn:SetMouseEnabled(true)
        end

    elseif listType == FCOGL_LISTTYPE_ROLLED_DICE_HISTORY then
        --local clientLang = fcoglUI.clientLang or fcoglUI.fallbackSetLang
        control.data = data

        --local updateSortHeaderDimensionsAndAnchors = false
        local noColumn   = control:GetNamedChild("No")
        local dateColumn = control:GetNamedChild("DateTime")
        local nameColumn = control:GetNamedChild("Name")
        local rollColumn = control:GetNamedChild("Roll")
        ------------------------------------------------------------------------------------------------------------------------
        noColumn:ClearAnchors()
        noColumn:SetAnchor(LEFT, control, nil, 0, 0)
        noColumn:SetText(data.no)
        noColumn:SetHidden(false)
        noColumn:SetMouseEnabled(true)
        local dateTimeStamp = data.timestamp
        local dateTimeStr = FCOGuildLottery.getDateTimeFormatted(dateTimeStamp)
        dateColumn:ClearAnchors()
        dateColumn:SetAnchor(LEFT, noColumn, RIGHT, 0, 0)
        dateColumn:SetText(dateTimeStr)
        dateColumn:SetHidden(false)
        dateColumn:SetMouseEnabled(true)
        nameColumn:ClearAnchors()
        nameColumn.normalColor = ZO_DEFAULT_TEXT
        if not data.columnWidth then data.columnWidth = 200 end
        nameColumn:SetDimensions(data.columnWidth, 30)
        nameColumn:SetAnchor(LEFT, dateColumn, RIGHT, 0, 0)
        nameColumn:SetText(data.nameText)
        nameColumn:SetHidden(false)
        nameColumn:SetMouseEnabled(true)
        rollColumn:ClearAnchors()
        rollColumn:SetAnchor(LEFT, nameColumn, RIGHT, 0, 0)
        rollColumn:SetAnchor(RIGHT, control, RIGHT, 0, 0)
        rollColumn:SetText(data.rollText)
        rollColumn:SetHidden(false)
        rollColumn:SetMouseEnabled(true)
    end

    --Set the row to the list now
    ZO_SortFilterList.SetupRow(self, control, data)
end

function fcoglWindowClass:FilterScrollList()
    local listType = self:GetListType()
    if not listType then return end
    df("list:FilterScrollList-currentTab: %s, listType: %s", tos(fcoglUI.CurrentTab), tos(listType))

    local scrollData = ZO_ScrollList_GetDataList(self.list)
    ZO_ClearNumericallyIndexedTable(scrollData)

    --Get the search method chosen at the search dropdown
    --self.searchType = 1
    self.searchType = self.searchDrop:GetSelectedItemData().id
    --Check the search text
    local searchInput = self.searchBox:GetText()

    local function checkIfMasterListRebuildNeeded(selfVar)
        --If not coming from setup function
        if not fcoglUI.comingFromSortScrollListSetupFunction then
            --d("--->>>checkIfMasterListRebuildNeeded: true")
            selfVar:BuildMasterList(true)
        end
    end
    ------------------------------------------------------------------------------------------------------------------------
    --Rebuild the masterlist so the total list and counts are correct!
    --checkIfMasterListRebuildNeeded(self)
    if fcoglUI.CurrentTab == FCOGL_TAB_GUILDSALESLOTTERY then
        if listType == FCOGL_LISTTYPE_GUILD_SALES_LOTTERY then
            for i = 1, #self.masterList do
                --Get the data of each set item
                local data = self.masterList[i]
                --Search for text/set bonuses
                if searchInput == "" or self:CheckForMatch(data, searchInput) then
                    table.insert(scrollData, ZO_ScrollList_CreateDataEntry(SCROLLLIST_DATATYPE_GUILDSALESRANKING, data))
                end
            end

        elseif listType == FCOGL_LISTTYPE_GUILD_MEMBERS_JOIN_DATE then
            for i = 1, #self.masterList do
                --Get the data of each set item
                local data = self.masterList[i]
                --Search for text/set bonuses
                if searchInput == "" or self:CheckForMatch(data, searchInput) then
                    table.insert(scrollData, ZO_ScrollList_CreateDataEntry(SCROLLLIST_DATATYPE_GUILDMEMBERSJOINEDLIST, data))
                end
            end

        elseif listType == FCOGL_LISTTYPE_ROLLED_DICE_HISTORY then

            for i = 1, #self.masterList do
                --Get the data of each set item
                local data = self.masterList[i]
                --Search for text/set bonuses
                if searchInput == "" or self:CheckForMatch(data, searchInput) then
                    table.insert(scrollData, ZO_ScrollList_CreateDataEntry(SCROLLLIST_DATATYPE_ROLLED_DICE_HISTORY, data))
                end
            end
        end

    end
    ------------------------------------------------------------------------------------------------------------------------
    --Update the counter
    self:UpdateCounter(scrollData)
end

function fcoglWindowClass:UpdateCounter(scrollData)
    --Update the counter (found by search/total) at the bottom right of the scroll list
    local listCountAndTotal = ""
    if self.masterList == nil or (self.masterList ~= nil and #self.masterList == 0) then
        listCountAndTotal = "0 / 0"
    else
        listCountAndTotal = strfor("%d / %d", #scrollData, #self.masterList)
    end
    self.control:GetNamedChild("Counter"):SetText(listCountAndTotal)
end

function fcoglWindowClass:BuildSortKeys()
    local listType = self:GetListType()
    if not listType then return end
    df("list:BuildSortKeys-currentTab: %s, listType: %s", tos(fcoglUI.CurrentTab), tos(listType))

    if fcoglUI.sortKeys ~= nil and type(fcoglUI.sortKeys) == "table" then
        self.sortKeys = fcoglUI.sortKeys
    else
        --Get the tiebraker for the 2nd sort after the selected column
        self.sortKeys = {
           -- ["rank"]               = { isId64          = true, isNumeric = true, tiebreaker = "name"  },
            ["rank"]               = { isNumeric = true,        tiebreaker = "name"  },
            ["name"]               = { caseInsensitive = true                       },
            ["price"]              = { caseInsensitive = true,  tiebreaker = "name"  },
            ["tax"]                = { caseInsensitive = true,  tiebreaker = "name"  },
            ["amount"]             = { caseInsensitive = true,  tiebreaker = "name"  },
            ["info"]               = { caseInsensitive = true,  tiebreaker = "name"  },
            ["invitedBy"]          = { caseInsensitive = true,  tiebreaker = "name"  },

            ["no"]                  = { isNumeric = true,       tiebreaker = "name"  },
            ["timestamp"]           = { isNumeric = true,       tiebreaker = "name"  },
            ["roll"]                = { isNumeric = true,       tiebreaker = "name"  },
        }
    end
end

function fcoglWindowClass:SortScrollList( )
    local listType = self:GetListType()
    if not listType then return end
    df("list:SortScrollList-currentTab: %s, listType: %s", tos(fcoglUI.CurrentTab), tos(listType))

    --Build the sortkeys depending on the settings
    self:BuildSortKeys()
    --Get the current sort header's key and direction
    self.currentSortKey = self.sortHeaderGroup:GetCurrentSortKey()
    self.currentSortOrder = self.sortHeaderGroup:GetSortDirection()
    df("> sortKey: %s, sortOrder: %s", tos(self.currentSortKey), tos(self.currentSortOrder))
	if (self.currentSortKey ~= nil and self.currentSortOrder ~= nil) then
        --If not coming from setup function
        --if fcoglUI.comingFromSortScrollListSetupFunction then return end
        --Update the scroll list and re-sort it -> Calls "SetupItemRow" internally!
		local scrollData = ZO_ScrollList_GetDataList(self.list)
        if scrollData and #scrollData > 0 then
            table.sort(scrollData, self.sortFunction)
            self:RefreshVisible()
        end
	end
end

------------------------------------------------
--- Search/Filter Functions
------------------------------------------------
function fcoglWindowClass:OrderedSearch(haystack, needles )
	-- A search for "spell damage" should match "Spell and Weapon Damage" but
	-- not "damage from enemy spells", so search term order must be considered
	haystack = haystack:lower()
	needles = needles:lower()
	local i = 0
	for needle in needles:gmatch("%S+") do
		i = haystack:find(needle, i + 1, true)
		if (not i) then return(false) end
	end
	return(true)
end

function fcoglWindowClass:SearchByCriteria(data, searchInput, searchType)
    if data == nil or searchInput == nil or searchInput == ""  or searchType == nil then return nil end
    local listType = self:GetListType()
    if not listType then return end

    local searchValueType = type(searchInput)
    local searchInputLower
    local searchValueIsString = false
    local searchValueIsNumber = false
    local searchInputNumber = ton(searchInput)
    if searchInputNumber ~= nil then
        searchValueType = type(searchInputNumber)
        if searchValueType == "number" then
            searchValueIsNumber = true
        end
    else
        if searchValueType == "string" then
            searchValueIsString = true
            searchInputLower = searchInput:lower()
        end
    end

    --TODO
    --[[
    if searchType == FCOGL_SEARCH_TYPE_??? then
        if listType == FCOGL_LISTTYPE_GUILD_SALES_LOTTERY then
        elseif listType == FCOGL_LISTTYPE_ROLLED_DICE_HISTORY then
        end
    end
    ]]
    --[[
        data["name"]
        data["rank"]
        data["amount"]
        data["price"]
        data["tax"]
        data["info"]
    ]]
    return false
end

function fcoglWindowClass:CheckForMatch(data, searchInput)
    local searchType = self.searchType
    if searchType ~= nil then
        local listType = self:GetListType()
        if not listType then return end

        --Search by name
        if searchType == FCOGL_SEARCH_TYPE_NAME then
            local isMatch = false
            local searchInputNumber = ton(searchInput)
            if searchInputNumber ~= nil then
                local searchValueType = type(searchInputNumber)
                if searchValueType == "number" then
                    if listType == FCOGL_LISTTYPE_GUILD_SALES_LOTTERY then
                        isMatch = searchInputNumber == data.rank or false
                    elseif listType == FCOGL_LISTTYPE_ROLLED_DICE_HISTORY then
                        isMatch = searchInputNumber == data.no or false
                    end
                end
            else
                -->Calls the Process function defined at AddProcessor -> function ProcessItemEntry
                isMatch = self.search:IsMatch(searchInput, data)
            end
            return isMatch
        else
            if listType == FCOGL_LISTTYPE_GUILD_SALES_LOTTERY then
                return(self:SearchByCriteria(data, searchInput, searchType))
            elseif listType == FCOGL_LISTTYPE_ROLLED_DICE_HISTORY then
                return(self:SearchByCriteria(data, searchInput, searchType))
            end
        end
    end
	return(false)
end

function fcoglWindowClass:ProcessItemEntry(stringSearch, data, searchTerm )
--df("[WLW.ProcessItemEntry] stringSearch: " ..tos(stringSearch) .. ", setName: " .. tos(data.name:lower()) .. ", searchTerm: " .. tos(searchTerm))
    local listType = self:GetListType()
    if not listType then return end
    if listType == FCOGL_LISTTYPE_GUILD_SALES_LOTTERY then
        if ( data.name and zo_plainstrfind(data.name:lower(), searchTerm) ) then
            return(true)
        end
    elseif listType == FCOGL_LISTTYPE_GUILD_MEMBERS_JOIN_DATE then
        if ( data.name and zo_plainstrfind(data.name:lower(), searchTerm) ) then
            return(true)
        end
    elseif listType == FCOGL_LISTTYPE_ROLLED_DICE_HISTORY then
        if ( data.nameText and zo_plainstrfind(data.nameText:lower(), searchTerm) ) then
            return(true)
        end
    end
	return(false)
end

------------------------------------------------
--- FCOGL Search Dropdown
------------------------------------------------
function fcoglWindowClass:SearchNow(searchValue, resetSearchTextBox)
--df("[fcoglWindow:SearchNow]searchValue: " ..tos(searchValue))
    resetSearchTextBox = resetSearchTextBox or false
    if not searchValue then return end
    local searchBox = self.searchBox
    if not searchBox then return end
    searchBox:Clear()
    if searchValue == "" and resetSearchTextBox then return end
    searchBox:SetText(searchValue) --Will automatically raise self:RefreshFilters() as OnTextChanged event fires
end


------------------------------------------------
--- Combo Box Initializers
------------------------------------------------
function fcoglWindowClass:initializeSearchDropdown(currentTab, currentListType, searchBoxType)
df("initializeSearchDropdown - listType: %s, searchBoxType: %s", tos(currentListType), tos(searchBoxType))
    if self == nil then return false end
    currentTab = currentTab or fcoglUI.CurrentTab or FCOGL_TAB_GUILDSALESLOTTERY
    currentListType = currentListType or self:GetListType()
    searchBoxType = searchBoxType or "name"
    local currentTab2SearchDropValues = {
        [FCOGL_TAB_GUILDSALESLOTTERY]   = {
            [FCOGL_LISTTYPE_GUILD_SALES_LOTTERY] = {
                ["name"] = {dropdown=self.searchDrop,  prefix=FCOGL_SEARCHDROP_PREFIX,  entryCount=FCOGL_SEARCH_TYPE_ITERATION_END,
                            exclude = {
                                [FCOGL_SEARCH_TYPE_NAME]     = false,
                            }, --exclude the search entries from the search
                },
                ["guilds"] = {dropdown=self.guildsDrop,  prefix=FCOGL_GUILDSDROP_PREFIX,  entryCount=#FCOGuildLottery.guildsData + 1, --5 guilds + 1 non-guild entry
                              exclude = {
                                  [FCOGL_SEARCH_TYPE_NAME]     = false,
                              }, --exclude the search entries from the search
                },
            },
            [FCOGL_LISTTYPE_GUILD_MEMBERS_JOIN_DATE] = {
                ["name"] = {dropdown=self.searchDrop,  prefix=FCOGL_SEARCHDROP_PREFIX,  entryCount=FCOGL_SEARCH_TYPE_ITERATION_END,
                            exclude = {
                                [FCOGL_SEARCH_TYPE_NAME]     = false,
                            }, --exclude the search entries from the search
                },
                ["guilds"] = {dropdown=self.guildsDrop,  prefix=FCOGL_GUILDSDROP_PREFIX,  entryCount=#FCOGuildLottery.guildsData + 1, --5 guilds + 1 non-guild entry
                              exclude = {
                                  [FCOGL_SEARCH_TYPE_NAME]     = false,
                              }, --exclude the search entries from the search
                },
            },
            [FCOGL_LISTTYPE_ROLLED_DICE_HISTORY] = {
                ["name"] = {dropdown=self.searchDrop,  prefix=FCOGL_HISTORY_SEARCHDROP_PREFIX,  entryCount=FCOGL_HISTORY_SEARCH_TYPE_ITERATION_END,
                            exclude = {
                                [FCOGL_SEARCH_TYPE_NAME]     = false,
                            }, --exclude the search entries from the search
                },
                ["GuildSalesHistory"] = {dropdown=self.guildHistoryDrop,  prefix=FCOGL_GUILDSALESHISTORYDROP_PREFIX,
                                         entryCount=0,
                                         exclude = {},
                },
                ["GuildMembersJoinedDateHistory"] = {dropdown=self.guildMembersJoinedDateHistoryDrop,  prefix=FCOGL_GUILDMEMBERSJOINEDDATEHISTORYDROP_PREFIX,
                                         entryCount=0,
                                         exclude = {},
                },
            },
        },
    }
    local searchDropAtTab = currentTab2SearchDropValues[currentTab] and currentTab2SearchDropValues[currentTab][currentListType]
    local searchDropData = searchDropAtTab[searchBoxType]
    if searchDropData == nil then return false end
    --d(">searchDropData: " .. tos(searchDropData.dropdown) ..", " ..tos(searchDropData.prefix) .. ", " .. tos(searchDropData.entryCount))
    self:InitializeComboBox(searchDropData.dropdown, searchDropData.prefix, searchDropData.entryCount, searchDropData.exclude, searchBoxType )
end

function fcoglUI.SelectLastDropdownEntry(searchBoxType, lastIndex, callCallback)
    callCallback = callCallback or false
    df("SelectLastDropdownEntry - lastIndex: %s, searchBoxType: %s, callCallback: %s", tos(lastIndex), tos(searchBoxType), tos(callCallback))
    if searchBoxType == nil or lastIndex == nil or lastIndex <= 0 then return end
    local comboBox
    if searchBoxType == "guilds" then
        local guildsDrop = fcoglUIwindowFrame.guildsDrop
        if guildsDrop == nil then return end
        comboBox = guildsDrop

    elseif searchBoxType == "name" then
        local searchDrop = fcoglUIwindowFrame.searchDrop
        if searchDrop == nil then return end
        comboBox = searchDrop

    elseif searchBoxType == "GuildSalesHistory" then
        local guildSalesHistoryDrop = fcoglUIDiceHistoryWindow.guildHistoryDrop
        if guildSalesHistoryDrop == nil then return end
        comboBox = guildSalesHistoryDrop
    end

    if not comboBox or comboBox and not comboBox.SelectItemByIndex then return end
    local callItemEntryCallback = ZO_COMBOBOX_UPDATE_NOW
    if not callCallback then
        callItemEntryCallback = ZO_COMBOBOX_SUPPRESS_UPDATE
    end
    comboBox:SelectItemByIndex(lastIndex, callItemEntryCallback)
end

local function abortUpdateNow(p_searchBoxType, p_lastIndex)
    df(">abortUpdateNow - lastIndex: %s, searchBoxType: %s", tos(p_lastIndex), tos(p_searchBoxType))

    FCOGuildLottery.currentlyUsedGuildSalesLotteryChosenData = nil
    FCOGuildLottery.currentlyUsedGuildMembersJoinDateChosenData = nil

    --Select the before selected dropdown entry but without calling the callback
    fcoglUI.SelectLastDropdownEntry(p_searchBoxType, p_lastIndex, false)
end

function fcoglUI.updateGuildDiceSidesEditBox(guildIndex)
    local diceSidesGuild = FCOGuildLottery.RollTheDiceNormalForGuildMemberCheck(guildIndex, true)
    if diceSidesGuild and diceSidesGuild > 0 then
        updateMaxGuildDiceSides(tos(diceSidesGuild))
        return true
    end
    return false
end

function fcoglUI.getSelectedGuildsDropEntry()
    return fcoglUIwindowFrame.guildsDrop:GetSelectedItemData()
end

local function setLastSelected()
    df("°°°°°°°°°° setLastSelected")
    local selectedGuildDropsData = fcoglUI.getSelectedGuildsDropEntry()
    --Get the needed list to show now:
    --No guild list at all?
    --Normal guild dice throws
    --Guild sales lottery           fcoglUIguildSalesLotteryWindow
    --Guild members joined list     fcoglUIguildMembersJoinedListWindow
    local currentlyShownListObject = getCurrentlyShownListsObject()
    if currentlyShownListObject == nil then return end
    currentlyShownListObject:SetSearchBoxLastSelected(fcoglUI.CurrentTab, "guilds", selectedGuildDropsData.selectedIndex)
end

function fcoglUI.resetGuildDropDownToNone()
    df("[fcoglUI.resetGuildDropDownToNone]")
    FCOGuildLottery.currentlyUsedGuildSalesLotteryChosenData = nil
    FCOGuildLottery.currentlyUsedGuildMembersJoinDateChosenData = nil

    setLastSelected()

    --Reset the guildId etc. which will be selected as a guild was selected at teh guilds dropdown and NO guildLottery was started
    FCOGuildLottery.currentlyUsedDiceRollGuildId = nil

    --Set to normal dice roll
    FCOGuildLottery.currentlyUsedDiceRollType = FCOGL_DICE_ROLL_TYPE_GENERIC

    --Update the maximum number of the dice sides to the maximum possible again
    updateMaxDefaultDiceSides()

    --Set the current tab as active again to force the update of all lists and buttons
    fcoglUI.SetTab(FCOGL_TAB_GUILDSALESLOTTERY, true, true, nil)
end

function fcoglUI.resetGuildDropDownToGuild(guildIndex)
    df("[fcoglUI.resetGuildDropDownToGuild]guildIndex: %s", tos(guildIndex))
    FCOGuildLottery.currentlyUsedGuildSalesLotteryChosenData = nil
    FCOGuildLottery.currentlyUsedGuildMembersJoinDateChosenData = nil

    setLastSelected()

    --Set the current guildId for normal guild member dice rolls
    FCOGuildLottery.currentlyUsedDiceRollType = FCOGL_DICE_ROLL_TYPE_GUILD_GENERIC
    --Set the guildId for the normal guild dice rolls
    FCOGuildLottery.currentlyUsedDiceRollGuildId = GetGuildId(guildIndex)

    --Update the maximum number of the dice sides to the current guild's member #
    if fcoglUI.updateGuildDiceSidesEditBox(guildIndex) == false then
        updateMaxDefaultDiceSides()
    end

    --Set the current tab as active again to force the update of all lists and buttons
    fcoglUI.SetTab(FCOGL_TAB_GUILDSALESLOTTERY, true, true, nil)
end

function fcoglWindowClass:InitializeComboBox(control, prefix, max, exclude, searchBoxType )
    local comboBoxOwner = self
    local isGuildsCB = ((prefix == FCOGL_GUILDSDROP_PREFIX) or searchBoxType == "guilds") or false
    local isNameSearchCB = ((prefix == FCOGL_SEARCHDROP_PREFIX) or searchBoxType == "name") or false
    local isGuildLotteryHistoryCB = prefix == FCOGL_GUILDSALESHISTORYDROP_PREFIX or false
    local isGuildMembersJoinedDateListHistoryCB = prefix == FCOGL_GUILDMEMBERSJOINEDDATEHISTORYDROP_PREFIX or false
    df("[fcoglWindowClass:InitializeComboBox]isGuildLotteryHistoryCB: %s, isGuildMembersJoinedCB: %s, isGuildsCB: %s, isNameSearchCB: %s, prefix: %s, max: %s", tos(isGuildLotteryHistoryCB), tos(isGuildMembersJoinedDateListHistoryCB), tos(isGuildsCB), tos(isNameSearchCB), tos(prefix), tos(max))
    control:SetSortsItems(false)
    control:ClearItems()

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
    local entryCallbackNoGuild = function( _, _, entry, _ ) --comboBox, entryText, entry )
        local function updateEntryNowNoGuild(guildIndex, daysBefore)
            df(">>UpdateEntryNow_NoGuild - selectedIndex: %s, CurrentTab: %s searchBoxType: %s", tos(entry.selectedIndex), tos(fcoglUI.CurrentTab), tos(searchBoxType))
            fcoglUI.resetGuildDropDownToNone()
            --[[
            comboBoxOwner:SetSearchBoxLastSelected(fcoglUI.CurrentTab, searchBoxType, entry.selectedIndex)
            --Reset the guildId etc. which will be selected as a guild was selected at teh guilds dropdown and NO guildLottery was started
            FCOGuildLottery.currentlyUsedDiceRollGuildId = nil

            --Set to normal dice roll
            FCOGuildLottery.currentlyUsedDiceRollType = FCOGL_DICE_ROLL_TYPE_GENERIC

            --Update the maximum number of the dice sides to the maximum possible again
            updateMaxDefaultDiceSides()

            --Set the current tab as active again to force the update of all lists and buttons
            fcoglUI.SetTab(FCOGL_TAB_GUILDSALESLOTTERY, true, true)
            ]]
        end
        --No guild selected!
        local lastSelectedIndex = comboBoxOwner:GetSearchBoxLastSelected(fcoglUI.CurrentTab, searchBoxType)
        --Currently guild sales lottery active?
        local isGuildSalesLotteryCurrentlyActive = isGuildSalesLotteryActive()
        if isGuildSalesLotteryCurrentlyActive == true then
            --Show ask dialog and reset the guild sales lottery to none if "yes" is chosen at the dialog
            --or reset to the before chosen dropdown entry
            --Guild was selected
            FCOGuildLottery.ResetCurrentGuildSalesLotteryData(false, false, nil, nil,
                    updateEntryNowNoGuild,
                    function() abortUpdateNow(searchBoxType, lastSelectedIndex) end
            )
        else
            updateEntryNowNoGuild(entry.index)
            --comboBoxOwner:RefreshFilters()
        end

    end

    --Combobox entry selected calback function
    local entryCallbackGuild = function( _, _, entry, _ ) --comboBox, entryText, entry, selectionChanged )
        df(">entryCallbackGuild - selectedIndex: %s, id: %s, searchBoxType: %s", tos(entry.selectedIndex), tos(entry.id), tos(searchBoxType))
        local function updateEntryNow(guildIndex, daysBefore)
            df(">>updateEntryNow - selectedIndex: %s, CurrentTab: %s searchBoxType: %s", tos(entry.selectedIndex), tos(fcoglUI.CurrentTab), tos(searchBoxType))
            fcoglUI.resetGuildDropDownToGuild(guildIndex)
            --[[
            comboBoxOwner:SetSearchBoxLastSelected(fcoglUI.CurrentTab, searchBoxType, entry.selectedIndex)

            --Set the current guildId for normal guild member dice rolls
            FCOGuildLottery.currentlyUsedDiceRollType = FCOGL_DICE_ROLL_TYPE_GUILD_GENERIC
            --Set the guildId for the normal guild dice rolls
            FCOGuildLottery.currentlyUsedDiceRollGuildId = GetGuildId(guildIndex)

            --Update the maximum number of the dice sides to the current guild's member #
            local diceSidesGuild = FCOGuildLottery.RollTheDiceNormalForGuildMemberCheck(entry.index, true)
            if diceSidesGuild and diceSidesGuild > 0 then
                FCOGuildLottery.prevVars.doNotRunOnTextChanged = true
                fcoglUIwindowFrame.editBoxDiceSides:SetText(tos(diceSidesGuild))
            else
                updateMaxDefaultDiceSides()
            end

            --Set the current tab as active again to force the update of all lists and buttons
            fcoglUI.SetTab(FCOGL_TAB_GUILDSALESLOTTERY, true, true)
            ]]
        end

        --Guild selected
        local lastSelectedIndex = comboBoxOwner:GetSearchBoxLastSelected(fcoglUI.CurrentTab, searchBoxType)
        --Is currently a guild sales lottery active? Then ask if it should aborted, If not: Switch back to active guildId
        local isGuildSalesLotteryCurrentlyActive = isGuildSalesLotteryActive()
        if isGuildSalesLotteryCurrentlyActive == true then
            --Show ask dialog and reset the guild sales lottery to the new guildId if "yes" is chosen at the dialog
            --or reset to the before chosen dropdown entry
            --TODO: Get daysBefore from editbox at UI!
            local daysBefore = FCOGL_DEFAULT_GUILD_SELL_HISTORY_DAYS --7 days
            FCOGuildLottery.ResetCurrentGuildSalesLotteryData(false, false, entry.index, daysBefore,
                    updateEntryNow,
                    function() abortUpdateNow(searchBoxType, lastSelectedIndex) end
            )
        else
            --Currently no guild sales lottery active? Then just change the active dropdown entry and set the values for
            --the normal guild dice throws
            updateEntryNow(entry.index, nil)
            --comboBoxOwner:RefreshFilters()
        end
    end

    local function entryCallbackGuildLotteryHistory( _, _, entry, _ ) --comboBox, entryText, entry, selectionChanged )
        df(">entryCallbackGuildLotteryHistory - selectedIndex: %s, id: %s, searchBoxType: %s", tos(entry.selectedIndex), tos(entry.guildId), tos(searchBoxType))
        local function updateEntryGuildSalesHistoryNow(guildIndex, daysBefore)
            df(">>updateEntryGuildSalesHistoryNow - selectedIndex: %s, CurrentTab: %s searchBoxType: %s", tos(entry.selectedIndex), tos(fcoglUI.CurrentTab), tos(searchBoxType))
            FCOGuildLottery.currentlyUsedGuildSalesLotteryChosenData = nil
            FCOGuildLottery.currentlyUsedGuildMembersJoinDateChosenData = nil

            comboBoxOwner:SetSearchBoxLastSelected(fcoglUI.CurrentTab, searchBoxType, entry.selectedIndex)

            --Set the current tab as active again to force the update of all lists and buttons
            fcoglUI.SetTab(FCOGL_TAB_GUILDSALESLOTTERY, true, true, FCOGL_LISTTYPE_GUILD_SALES_LOTTERY)
        end

        --[[
            entry.guildId
            entry.guildIndex
            entry.name
            entry.timestamp
            entry.selectedIndex
        ]]
        --Guild sales lottery history entry selected
        local lastSelectedIndex = comboBoxOwner:GetSearchBoxLastSelected(fcoglUI.CurrentTab, searchBoxType)
        --Show ask dialog and reset the guild sales lottery to the chosen guild sales lottery timestamp if "yes" is chosen at the dialog
        --or reset to the before chosen dropdown entry
        --TODO: Get daysBefore from editbox at UI!
        local daysBefore = entry.daysBefore or FCOGL_DEFAULT_GUILD_SELL_HISTORY_DAYS --7 days
        --Set the entries data like timestamp, daysBefore as "chosen at the UI" -> Will be used in FCOGuildLottery.RollTheDiceForGuildSalesLottery
        --to overwrite FCOGuildLottery.currentlyUsedGuildSalesLotteryTimestamp etc. than!
        FCOGuildLottery.currentlyUsedGuildSalesLotteryChosenData = entry

        FCOGuildLottery.ResetCurrentGuildSalesLotteryData(false, true, entry.guildIndex, daysBefore,
                updateEntryGuildSalesHistoryNow,
                function() abortUpdateNow(searchBoxType, lastSelectedIndex) end
        )
    end

    local function entryCallbackGuildMemberJoinedDateListHistory( _, _, entry, _ ) --comboBox, entryText, entry, selectionChanged )
        df(">entryCallbackGuildMemberJoinedDateListHistory - selectedIndex: %s, id: %s, searchBoxType: %s", tos(entry.selectedIndex), tos(entry.guildId), tos(searchBoxType))
        local function updateEntryGuildMemberJoinedDateListHistoryNow(guildIndex, daysBefore)
            df(">>updateEntryGuildMemberJoinedDateListHistoryNow - selectedIndex: %s, CurrentTab: %s searchBoxType: %s", tos(entry.selectedIndex), tos(fcoglUI.CurrentTab), tos(searchBoxType))
            FCOGuildLottery.currentlyUsedGuildMembersJoinDateChosenData = nil
            FCOGuildLottery.currentlyUsedGuildSalesLotteryChosenData = nil

            comboBoxOwner:SetSearchBoxLastSelected(fcoglUI.CurrentTab, searchBoxType, entry.selectedIndex)

            --Set the current tab as active again to force the update of all lists and buttons
            fcoglUI.SetTab(FCOGL_TAB_GUILDSALESLOTTERY, true, true, FCOGL_LISTTYPE_GUILD_MEMBERS_JOIN_DATE)
        end

        --[[
            entry.guildId
            entry.guildIndex
            entry.name
            entry.timestamp
            entry.selectedIndex
        ]]
        --Guild sales lottery history entry selected
        local lastSelectedIndex = comboBoxOwner:GetSearchBoxLastSelected(fcoglUI.CurrentTab, searchBoxType)
        --Show ask dialog and reset the guild members joined date list to the chosen guild members joined date list timestamp if "yes" is chosen at the dialog
        --or reset to the before chosen dropdown entry
        --TODO: Get daysBefore from editbox at UI!
        local daysBefore = entry.daysBefore or FCOGL_DEFAULT_GUILD_MEMBERS_JOIN_DATE_HISTORY_DAYS --31 days
        --Set the entries data like timestamp, daysBefore as "chosen at the UI" -> Will be used in FCOGuildLottery.RollTheDiceForGuildMembersJoinDate()
        --to overwrite FCOGuildLottery.currentlyUsedGuildMembersJoinDateTimestamp etc. than!
        FCOGuildLottery.currentlyUsedGuildMembersJoinDateChosenData = entry

        FCOGuildLottery.ResetCurrentGuildMembersJoinDateData(false, true, entry.guildIndex, daysBefore,
                updateEntryGuildMemberJoinedDateListHistoryNow,
                function() abortUpdateNow(searchBoxType, lastSelectedIndex) end
        )
    end

    local entryCallbackName = function( _, _, entry, _ ) --comboBox, entryText, entry, selectionChanged )
        df("=>=>=> entryCallbackName - selectedIndex: %s, id: %s, searchBoxType: %s", tos(entry.selectedIndex), tos(entry.id), tos(searchBoxType))
        comboBoxOwner:SetSearchBoxLastSelected(fcoglUI.CurrentTab, searchBoxType, entry.selectedIndex)
        comboBoxOwner:RefreshFilters()
    end
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
    local selectedGuildDataBeforeUpdate
    --local currentCharName
    local currentGuildId = 0
    local itemToSelect = 1
    local guildMembersJoinedDateListHistoriesSaved
    --local currentCharName = ""
    --Guild combo box?
    if isGuildsCB then
        --currentCharName = GetUnitName("player")
        --Format the name
        --currentCharName = zo_strformat(SI_UNIT_NAME, currentCharName)
        selectedGuildDataBeforeUpdate = fcoglUI.selectedGuildDataBeforeUpdate
        if selectedGuildDataBeforeUpdate ~= nil and selectedGuildDataBeforeUpdate.guildId ~= nil then
            currentGuildId = selectedGuildDataBeforeUpdate.guildId
        else
            currentGuildId = FCOGuildLottery.currentlyUsedGuildSalesLotteryGuildId
        end
    end
    local numEntriesAdded = 0
    if not isGuildLotteryHistoryCB and not isGuildMembersJoinedDateListHistoryCB then
        for i = 1, max do
            if not exclude or (exclude and not exclude[i]) then
                local entry
                --Guilds combo box?
                if isGuildsCB then
                    local guildId = -1
                    local guildsData = FCOGuildLottery.guildsData[i]
                    if guildsData ~= nil then
                        entry = ZO_ComboBox:CreateItemEntry(guildsData.name, entryCallbackGuild)
                        guildId = guildsData.id
                        if currentGuildId ~= nil and guildId == currentGuildId then
                            itemToSelect = i
                        end
                        entry.index      = guildsData.index
                        entry.id         = guildId
                        entry.name       = guildsData.name
                        entry.gotTrader  = guildsData.gotTrader
                        entry.isGuild    = true
                    else
                        --Last entry: Non-guild
                        if i == FCOGuildLottery.noGuildIndex then
                            local noGuildName = GetString(FCOGL_NO_GUILD)
                            entry = ZO_ComboBox:CreateItemEntry(noGuildName, entryCallbackNoGuild)
                            --guildId = nil
                            if currentGuildId == nil then
                                itemToSelect = i
                            end
                            entry.index      = i
                            entry.id         = -1
                            entry.name       = noGuildName
                            --entry.gotTrader  = nil
                            entry.isGuild = true
                        end
                    end
                    --Search type combo box
                elseif isNameSearchCB then
                    local entryText = GetString(prefix, i)
                    --entryText = entryText .. GetString(setSearchCBEntryStart, i)
                    entry = ZO_ComboBox:CreateItemEntry(entryText, entryCallbackName)
                    entry.id = i
                end
                numEntriesAdded = numEntriesAdded + 1
                entry.selectedIndex = numEntriesAdded
                control:AddItem(entry, ZO_COMBOBOX_SUPPRESS_UPDATE) --ZO_COMBOBOX_UPDATE_NOW
            end
        end
    elseif isGuildLotteryHistoryCB then
        max, guildMembersJoinedDateListHistoriesSaved = self:UpdateDiceHistoryGuildSalesDrop()
        --Guild lottery history entries combo box
        local entriesTable = {}
        local entry
        if guildMembersJoinedDateListHistoriesSaved ~= nil then
            local daysBefore = guildMembersJoinedDateListHistoriesSaved["daysBefore"]
            local selectedGuildId = (FCOGuildLottery.currentlyUsedGuildSalesLotteryGuildId ~= nil and FCOGuildLottery.currentlyUsedGuildSalesLotteryGuildId) or fcoglUI.getSelectedGuildsDropEntry().id
            local selectedGuildSalesLotteryTimestamp = (FCOGuildLottery.currentlyUsedGuildSalesLotteryTimestamp ~= nil and FCOGuildLottery.currentlyUsedGuildSalesLotteryTimestamp) or 0 --TODO
            for timeStampOfGuildSalesLotteryHistoryEntry, guildSalesLotteryHistoryEntryData in pairs(guildMembersJoinedDateListHistoriesSaved) do
                if timeStampOfGuildSalesLotteryHistoryEntry ~= "daysBefore" then
                    local countDiceThrowData = NonContiguousCount(guildSalesLotteryHistoryEntryData)
                    if countDiceThrowData > 1 then countDiceThrowData = countDiceThrowData -1 end --subtract 1 because of the "daysBefore" entry
                    local dateTimeString = strfor(FCOGuildLottery.FormatDate(timeStampOfGuildSalesLotteryHistoryEntry) .. " (#%s)", tos(countDiceThrowData))
                    entry = ZO_ComboBox:CreateItemEntry(dateTimeString, entryCallbackGuildLotteryHistory)
                    entry.guildId       = selectedGuildId
                    entry.guildIndex    = FCOGuildLottery.GetGuildIndexById(selectedGuildId)
                    entry.name          = dateTimeString
                    entry.timestamp     = timeStampOfGuildSalesLotteryHistoryEntry
                    entry.daysBefore    = daysBefore
                    numEntriesAdded     = numEntriesAdded + 1

                    if selectedGuildSalesLotteryTimestamp ~= nil and selectedGuildSalesLotteryTimestamp == timeStampOfGuildSalesLotteryHistoryEntry then
                        itemToSelect    = numEntriesAdded
                    end
                    entry.selectedIndex = numEntriesAdded
                    table.insert(entriesTable, entry)
                end
            end
            --Sort the box entries by their timestamp
            table.sort(entriesTable, sortByDescTimeStamp)
            local cnt = 0
            for _, entryData in ipairs(entriesTable) do
                cnt = cnt + 1
                entryData.selectedIndex = cnt
                control:AddItem(entryData, ZO_COMBOBOX_SUPPRESS_UPDATE) --ZO_COMBOBOX_UPDATE_NOW
            end
        end
    elseif isGuildMembersJoinedDateListHistoryCB then
        max, guildMembersJoinedDateListHistoriesSaved = self:UpdateDiceHistoryGuildMembersJoinedDateListDrop()
        --Guild members joined date list history entries combo box
        local entriesTable = {}
        local entry
        if guildMembersJoinedDateListHistoriesSaved ~= nil then
            local daysBefore                               = guildMembersJoinedDateListHistoriesSaved["daysBefore"]
            local selectedGuildId                          = (FCOGuildLottery.currentlyUsedGuildMembersJoinDateGuildId ~= nil and FCOGuildLottery.currentlyUsedGuildMembersJoinDateGuildId) or fcoglUI.getSelectedGuildsDropEntry().id
            local selectedGuildMemberJoinDateListTimestamp = (FCOGuildLottery.currentlyUsedGuildMembersJoinDateTimestamp ~= nil and FCOGuildLottery.currentlyUsedGuildMembersJoinDateTimestamp) or 0 --TODO
            for timeStampOfGuildMembersJoinDateListHistoryEntry, guildMembersJoinDateListHistoryEntryData in pairs(guildMembersJoinedDateListHistoriesSaved) do
                if timeStampOfGuildMembersJoinDateListHistoryEntry ~= "daysBefore" then
                    local countDiceThrowData = NonContiguousCount(guildMembersJoinDateListHistoryEntryData)
                    if countDiceThrowData > 1 then countDiceThrowData = countDiceThrowData -1 end --subtract 1 because of the "daysBefore" entry
                    local dateTimeString = strfor(FCOGuildLottery.FormatDate(timeStampOfGuildMembersJoinDateListHistoryEntry) .. " (#%s)", tos(countDiceThrowData))
                    entry = ZO_ComboBox:CreateItemEntry(dateTimeString, entryCallbackGuildMemberJoinedDateListHistory)
                    entry.guildId       = selectedGuildId
                    entry.guildIndex    = FCOGuildLottery.GetGuildIndexById(selectedGuildId)
                    entry.name          = dateTimeString
                    entry.timestamp     = timeStampOfGuildMembersJoinDateListHistoryEntry
                    entry.daysBefore    = daysBefore
                    numEntriesAdded     = numEntriesAdded + 1

                    if selectedGuildMemberJoinDateListTimestamp ~= nil and selectedGuildMemberJoinDateListTimestamp == timeStampOfGuildMembersJoinDateListHistoryEntry then
                        itemToSelect    = numEntriesAdded
                    end
                    entry.selectedIndex = numEntriesAdded
                    table.insert(entriesTable, entry)
                end
            end
            --Sort the box entries by their timestamp
            table.sort(entriesTable, sortByDescTimeStamp)
            local cnt = 0
            for _, entryData in ipairs(entriesTable) do
                cnt = cnt + 1
                entryData.selectedIndex = cnt
                control:AddItem(entryData, ZO_COMBOBOX_SUPPRESS_UPDATE) --ZO_COMBOBOX_UPDATE_NOW
            end

        end
    end
    if itemToSelect ~= nil then
        if isNameSearchCB then
            itemToSelect = self:GetSearchBoxLastSelected(fcoglUI.CurrentTab, "name")
        end
        control:SelectItemByIndex(itemToSelect, true)
    end
end

function fcoglWindowClass:SetSearchBoxLastSelected(UITab, searchBoxType, selectedIndex)
--d(">>>>> DEBUG SET DEBUG SET >>>>>")
    local listType = self:GetListType()
    df("SetSearchBoxLastSelected - UITab: %s, listType: %s, searchBoxType: %s, selectedIndex: %q", tos(UITab), tos(listType), tos(searchBoxType), tos(selectedIndex))
    if selectedIndex == nil then return end
    fcoglUI.searchBoxLastSelected[UITab]                = fcoglUI.searchBoxLastSelected[UITab] or {}
    fcoglUI.searchBoxLastSelected[UITab][listType]      = fcoglUI.searchBoxLastSelected[UITab][listType] or {}
    fcoglUI.searchBoxLastSelected[UITab][listType][searchBoxType] = selectedIndex
--d("<<<<< DEBUG SET DEBUG SET <<<<<")
end

function fcoglWindowClass:GetSearchBoxLastSelected(UITab, searchBoxType)
--d(">!!!! DEBUG GET DEBUG GET !!!!")
    local listType = self:GetListType()
    local lastSelectedDropdownEntry = (fcoglUI.searchBoxLastSelected[UITab] and fcoglUI.searchBoxLastSelected[UITab][listType] and
            fcoglUI.searchBoxLastSelected[UITab][listType][searchBoxType]) or nil
    df("GetSearchBoxLastSelected - UITab: %s, listType: %s, searchBoxType: %s->lastSelectedDropdownEntry: %q", tos(UITab), tos(listType), tos(searchBoxType), tos(lastSelectedDropdownEntry))
    if lastSelectedDropdownEntry == nil then lastSelectedDropdownEntry = 1 end
--d("<!!!! DEBUG GET DEBUG GET")
    return lastSelectedDropdownEntry
end


---------------------------------------------------
--Functions for list controls row's OnMouse events
---------------------------------------------------
local function deleteRowEntry(rowControlUp, listType)
    local data = rowControlUp.data
    if data == nil then return end

    if listType == FCOGL_LISTTYPE_NORMAL_THROWS then

    elseif listType == FCOGL_LISTTYPE_GUILD_MEMBER_THROWS then

    elseif listType == FCOGL_LISTTYPE_GUILD_SALES_LOTTERY then

    elseif listType == FCOGL_LISTTYPE_GUILD_MEMBERS_JOIN_DATE then

    elseif listType == FCOGL_LISTTYPE_ROLLED_DICE_HISTORY then
        if data.no == nil or data.timestamp == nil then return end
--d(">Deleting dice history row #: " ..tos(data.no))
        fcoglUI.DeleteDiceHistoryList(true, data, nil, true)
    end
end

------------------------------------------------
--- FCOGL window global functions XML
------------------------------------------------
function FCOGL_UI_OnMouseEnter( rowControlEnter )
--d("[FCOGL_UI_OnMouseEnter] listType: " ..tos(fcoglUI.CurrentListType))
    --local listObject = getCurrentlyShownListsObject()
    --if listObject == nil then return end
    --[[
    local showAdditionalTextTooltip = false
    if showAdditionalTextTooltip then
        local data = rowControlEnter.data
        if data ~= nil then
            local clientLang = FCOGuildLottery.clientLang
            local tooltipText = ""
            local nameVar = ""
            if data.names then
                nameVar = data.names[clientLang]
            elseif data.name then
                nameVar = data.name
            end
            tooltipText = GetString(WISHLIST_TOOLTIP_COLOR_KEY) .. GetString(WISHLIST_CONST_SET) .. "|r: " .. GetString(WISHLIST_TOOLTIP_COLOR_VALUE) .. nameVar .. "|r (" .. GetString(WISHLIST_CONST_BONUS) .. ": " .. GetString(WISHLIST_TOOLTIP_COLOR_VALUE) .. data.bonuses .. "|r, " .. GetString(WISHLIST_CONST_ID) .. ": " .. GetString(WISHLIST_TOOLTIP_COLOR_VALUE) .. data.setId .. "|r)"
            tooltipText = tooltipText .. "\n" .. GetString(WISHLIST_TOOLTIP_COLOR_KEY) .. GetString(WISHLIST_HEADER_LOCALITY) .. "|r: " .. GetString(WISHLIST_TOOLTIP_COLOR_VALUE) .. data.locality .. "|r"
            tooltipText = tooltipText .. "\n" .. GetString(WISHLIST_TOOLTIP_COLOR_KEY) .. GetString(WISHLIST_HEADER_NAME) .. "|r: " .. GetString(WISHLIST_TOOLTIP_COLOR_VALUE) ..data.username .. "|r"
            if data.displayName ~= nil and data.displayName ~= "" then
                tooltipText = tooltipText .. " [" .. data.displayName .. "]"
            end
            if data.timestamp ~= nil then
                local dateTimeStr = fcoglUI.getDateTimeFormatted(data.timestamp)
                tooltipText = tooltipText .. "\n" .. GetString(WISHLIST_TOOLTIP_COLOR_KEY) .. GetString(WISHLIST_HEADER_DATE) .. "|r: " .. GetString(WISHLIST_TOOLTIP_COLOR_VALUE) .. dateTimeStr .. "|r"
            end
            if tooltipText ~= "" then
                FCOGuildLottery.ShowTooltip(rowControlEnter, TOP, tooltipText)
            end
        end
    end
    ]]
end

function FCOGL_UI_OnMouseExit( rowControlExit )
    FCOGuildLottery.HideTooltip()
    --local listObject = getCurrentlyShownListsObject()
    --if listObject == nil then return end
end

function FCOGL_UI_OnMouseUp( rowControlUp, button, upInside )
    if upInside == true then
        FCOGuildLottery.HideTooltip()

        local doShowMenu = false

        --Show the context menu
        if button == MOUSE_BUTTON_INDEX_RIGHT then
            local rowsOwnerWindow = rowControlUp:GetOwningWindow()
            if rowsOwnerWindow == nil or rowsOwnerWindow.object == nil then return end
            local listType = rowsOwnerWindow.object.listType
            if listType == nil then return end
--d(">ListType of row: " ..tos(listType))

            if listType == FCOGL_LISTTYPE_NORMAL_THROWS then

            elseif listType == FCOGL_LISTTYPE_GUILD_MEMBER_THROWS then

            elseif listType == FCOGL_LISTTYPE_GUILD_SALES_LOTTERY then

            elseif listType == FCOGL_LISTTYPE_GUILD_MEMBERS_JOIN_DATE then

            elseif listType == FCOGL_LISTTYPE_ROLLED_DICE_HISTORY then
                ClearMenu()
                AddCustomMenuItem(GetString(FCOGL_DELETE_HEADER), nil, MENU_ADD_OPTION_HEADER)
                AddCustomMenuItem(strfor(GetString(FCOGL_DELETE_ENTRY), tos(rowControlUp.data.no)), function()
                    deleteRowEntry(rowControlUp, listType)
                end)
                AddCustomMenuItem(GetString(FCOGL_CLEAR_HISTORY), function()
                    FCOGuildLottery.ClearCurrentHistoryCheck()
                end)


                doShowMenu = true
            end

            if doShowMenu == true then
                ShowMenu(rowControlUp)
            end
        end
    end
end

function FCOGL_UI_OnTextChanged( editBox, isNumeric, isDefaultDiceNumber, checkEmpty )
    --Do not update the savedvars number of dices if auto-update is disabled by the preventer variable
    if FCOGuildLottery.prevVars.doNotRunOnTextChanged == true then
        FCOGuildLottery.prevVars.doNotRunOnTextChanged = false
        return
    end
    isNumeric = isNumeric or false
    isDefaultDiceNumber = isDefaultDiceNumber or false
    checkEmpty = checkEmpty or false

    --Do not update the savedvars number of dices if any guildId was selected
    local guildIndex = fcoglUI.getSelectedGuildsDropEntry().index
    df("FCOGL_UI_OnTextChanged - guildIndex: %s, isNumeric: %s, isDefaultDiceNumber: %s, checkEmpty: %s", tos(guildIndex), tos(isNumeric), tos(isDefaultDiceNumber), tos(checkEmpty))
    if guildIndex ~= nil and guildIndex > 0 and guildIndex <= MAX_GUILDS then return end

    local defaultVar
    if isDefaultDiceNumber == true then
        defaultVar = FCOGL_DICE_SIDES_DEFAULT
    end
    local text = editBox:GetText()
    local newValue
    if isNumeric == true then
        local numberText = ton(text)
        if text == "" and checkEmpty == true then
            newValue = tos(defaultVar) or "1"
        elseif text == "0" or numberText ~= nil and numberText == 0 then
            newValue = tos(defaultVar) or "1"
        end
        if newValue ~= nil then
            editBox:SetText(newValue)
        end
    end
    text = newValue or text
    if text ~= nil then
        if isNumeric == true and text ~= "" then
            if isDefaultDiceNumber == true then
                FCOGuildLottery.settingsVars.settings.defaultDiceSides = ton(text)
            end
            --else
            --updateVar = tos(text)
        end
    end
end

function FCOGL_UI_OnArrowKey( editBox, isNumeric, isDefaultDiceNumber, doIncrease )
    isNumeric = isNumeric or false
    isDefaultDiceNumber = isDefaultDiceNumber or false
    if not isNumeric == true then return end
    local defaultVar
    if isDefaultDiceNumber == true then
        defaultVar = FCOGL_DICE_SIDES_DEFAULT
    end
    local text = editBox:GetText()
    local newValue
    local numberText = ton(text)
    if text == "" then
        newValue = tos(defaultVar)
    elseif text == "0" or numberText ~= nil and numberText == 0 then
        if doIncrease == true then
            newValue = "1"
        else
            newValue = "1"
        end
    else
        if doIncrease == true then
            newValue = tos(numberText + 1)
            if newValue > "999" then newValue = "999" end
        else
            newValue = tos(numberText - 1)
            if newValue <= "0" then
                if isDefaultDiceNumber == true then
                    newValue = tos(defaultVar)
                end
            end
        end
    end
    if newValue ~= nil then
        editBox:SetText(newValue)
    end
    text = newValue or text
    if text ~= nil then
        if text ~= "" then
            FCOGuildLottery.prevVars.doNotRunOnTextChanged = true
            if isDefaultDiceNumber == true then
                FCOGuildLottery.settingsVars.settings.defaultDiceSides = ton(text)
            end
        --else
            --updateVar = tos(text)
        end
    end
end

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
--FCOGuildLottery UI functions

function fcoglWindowClass:CreateGuildSalesRankingEntry(item)
    --local uniqueId = FCOGuildLottery.currentlyUsedGuildSalesLotteryUniqueIdentifier
    --local guildId = FCOGuildLottery.currentlyUsedGuildSalesLotteryGuildId
    --[[
        --Columns of "item":
        --rank
        --memberName
        --soldSum
        --taxSum
        --amountSum
    ]]
    local guildSalesRankingLine = {
        type =      SCROLLLIST_DATATYPE_GUILDSALESRANKING, -- for the search method to work -> Find the processor in zo_stringsearch:Process()
        rank =      item.rank,
        name =      item.memberName,
        price =     item.soldSum,
        tax =       item.taxSum,
        amount =    item.amountSum,
        info =      "",
    }
    return guildSalesRankingLine
end

function fcoglWindowClass:CreateGuildMemberJoinedListEntry(item)
    --local uniqueId = FCOGuildLottery.currentlyUsedGuildMembersJoinDateUniqueIdentifier
    --local guildId = FCOGuildLottery.currentlyUsedGuildMembersJoinDateGuildId
    --[[
        --Columns of "item":
        --_eventTime
        --_eventTimeFormated
        --rank
        --memberName
        --invitedBy
        --isStillInGuild
        --memberIndex
    ]]
    local isStillInGuild = item.isStillInGuild
    local infoJoinedStr = item._eventTimeFormated
    if isStillInGuild == true then
        infoJoinedStr = infoJoinedStr .. " [" .. tos(bool2Str[isStillInGuild]) .. "/" .. tos(item.memberIndex) .. "]"
    end

    local guildMembersJoinedListLine = {
        type =      SCROLLLIST_DATATYPE_GUILDMEMBERSJOINEDLIST, -- for the search method to work -> Find the processor in zo_stringsearch:Process()
        rank =      item.rank,
        name =      item.memberName,
        invitedBy = item.invitedBy,
        --Joined date formatted [boolean "is still in guild"/number "memberIndex"]
        info =      infoJoinedStr,
        timestamp = item._eventTime
    }
    return guildMembersJoinedListLine
end


function fcoglWindowClass:CreateDiceThrowHistoryEntry(diceRolledData)
    --[[
        --Columns of "diceRolledData":
        --no -> Added in BuildMasterList
        --characterId
        --diceSides
        --displayName
        --roll
        --timestamp
        --guildId
        --guildIndex
        --rolledGuildMemberName
        --rolledGuildMemberSecsSinceLogoff
        --rolledGuildMemberStatus
    ]]
--d("[FCOGL]CreateDiceThrowHistoryEntry-characterId: " ..tos(diceRolledData.characterId))
    local charName = (diceRolledData.characterId ~= nil and FCOGuildLottery.GetCharacterName(diceRolledData.characterId)) or nil
    local diceRolledHistoryLine = {
        type =      SCROLLLIST_DATATYPE_ROLLED_DICE_HISTORY, -- for the search method to work -> Find the processor in zo_stringsearch:Process()
        no =        diceRolledData.no,
        character = diceRolledData.characterId,
        name =      diceRolledData.displayName,
        rolledGuildMemberName = diceRolledData.rolledGuildMemberName,
        guildId =   diceRolledData.guildId,
        guildIndex = diceRolledData.guildIndex,
        nameText =  strfor("%s%s", (diceRolledData.guildId ~= nil and diceRolledData.rolledGuildMemberName) or diceRolledData.displayName, (diceRolledData.guildId == nil and diceRolledData.characterId ~= nil and " (" .. tos(charName) .. ")") or ""),
        roll =      diceRolledData.roll,
        rollText =  strfor("%s%s (%s)", locVars.diceRollPrefix, tos(diceRolledData.diceSides), tos(diceRolledData.roll)),
        timestamp = diceRolledData.timestamp,
    }
    return diceRolledHistoryLine
end

function fcoglUI.createWindow()
    --The main UI with the frame
    if not FCOGuildLottery.UI.window then
        FCOGuildLottery.UI.window = {}
        FCOGuildLottery.UI.window.frame = FCOGLFrame --Assign the TopLevelControl FCOGLFrame with the base tabs and buttons
        fcoglUIwindow = FCOGuildLottery.UI.window
        fcoglUIwindowFrame = fcoglUIwindow.frame
    end
    --Create the ZO_SortFilterScrollList backdrops now and anchor them to the TLC FCOGLFrame
    if fcoglUIwindow ~= nil and fcoglUIwindowFrame ~= nil then
        if not FCOGuildLottery.UI.guildSalesLotteryWindow then
            --Guild sales lottery
            FCOGuildLottery.UI.guildSalesLotteryWindow = fcoglWindowClass:New(FCOGLFrameSalesLottery, FCOGL_LISTTYPE_GUILD_SALES_LOTTERY, fcoglUIwindowFrame)
            fcoglUIguildSalesLotteryWindow             = FCOGuildLottery.UI.guildSalesLotteryWindow
        end
        if not FCOGuildLottery.UI.guildMembersJoinedWindow then
            --Guild members joined list
            FCOGuildLottery.UI.guildMembersJoinedWindow = fcoglWindowClass:New(FCOGLFrameMembersJoined, FCOGL_LISTTYPE_GUILD_MEMBERS_JOIN_DATE, fcoglUIwindowFrame)
            fcoglUIguildMembersJoinedWindow             = FCOGuildLottery.UI.guildMembersJoinedWindow
        end
        if not FCOGuildLottery.UI.diceHistoryWindow then
            --The rolled dice history inside the frame
            FCOGuildLottery.UI.diceHistoryWindow = fcoglWindowClass:New(FCOGLFrameDiceHistory, FCOGL_LISTTYPE_ROLLED_DICE_HISTORY, nil) --use it's own TLC as frame control!
            fcoglUIDiceHistoryWindow = FCOGuildLottery.UI.diceHistoryWindow
            --fcoglUIDiceHistoryWindow.control:SetHidden(true)
        end

        fcoglUI.ListTypeToListObject = {
            ["left"] = {
                [FCOGL_LISTTYPE_NORMAL_THROWS] =            nil,
                [FCOGL_LISTTYPE_GUILD_MEMBER_THROWS] =      nil,
                [FCOGL_LISTTYPE_GUILD_SALES_LOTTERY] =      fcoglUIguildSalesLotteryWindow,
                [FCOGL_LISTTYPE_GUILD_MEMBERS_JOIN_DATE] =  fcoglUIguildMembersJoinedWindow,

            },
            ["right"] = {
                [FCOGL_LISTTYPE_ROLLED_DICE_HISTORY] =      fcoglUIDiceHistoryWindow,
            }
        }
        fcoglUIListTypeToListObject = fcoglUI.ListTypeToListObject
    end
end

local function showUIWindow(doShow, doShowDiceHistory, listTypeToUpdate)
df("showUIWindow: " ..tos(doShow))
    local windowFrame = fcoglUIwindowFrame or fcoglUIwindow.frame
    if windowFrame == nil then return end
    --Toggle show/hide
    if doShow == nil then
        --Recursively call
        showUIWindow(windowFrame:IsControlHidden(), nil, listTypeToUpdate)
        return
    else
        --Explicitly show/hide
        windowFrame:SetHidden(not doShow)
        FCOGuildLottery.UI.windowShown = doShow
        if doShow == true then
            setWindowPosition(windowFrame)

            --Get the needed list to show now:
            --No guild list at all?         <no list control, only dice roll history at the right>
            --Normal guild dice throws      <no list control, only dice roll history at the right>
            --Guild sales lottery           fcoglUIguildSalesLotteryWindow
            --Guild members joined list     fcoglUIguildMembersJoinedListWindow
            local currentlyShownListObject
            if listTypeToUpdate ~= nil then
                currentlyShownListObject = getListsObjectByListType(listTypeToUpdate)
            else
                currentlyShownListObject = getCurrentlyShownListsObject()
            end
            if currentlyShownListObject == nil and FCOGuildLottery.UI.firstCallOfShowUIWindow == true then
                FCOGuildLottery.UI.firstCallOfShowUIWindow = false
                currentlyShownListObject = fcoglUIguildMembersJoinedWindow
            end
            --As the UpdateUI function is only available for a ZO_SortFilterScrollList we will use the Guild Members Joined List by default to update
            --the UI, show the list control and it's sort headers etc.
            --But if no guild members joined list is active the list and sort headers will stay hidden!
            currentlyShownListObject:UpdateUI(FCOGL_TAB_STATE_LOADED, false, doShowDiceHistory)
        else
            local windowDiceRollFrame = fcoglUIDiceHistoryWindow.frame
            if windowDiceRollFrame:IsHidden() then return end
            windowDiceRollFrame:SetHidden(true)
        end
    end
end

function fcoglUI.Show(doShow, doShowDiceHistory, listTypeToUpdate)
df("Show: %s", tos(doShow))
    fcoglUI.createWindow()
    showUIWindow(doShow, doShowDiceHistory, listTypeToUpdate)
end
FCOGuildLottery.ToggleUI = function()
    local doShowDiceHistory = false
    local listTypeToUpdate = nil

    --Is any guild sales lottery active at the moment?
    --Or any member joined list?
    --Then show the dice history and update teh list type
    if FCOGuildLottery.IsGuildSalesLotteryActive() then
        doShowDiceHistory = true
        listTypeToUpdate = FCOGL_LISTTYPE_GUILD_SALES_LOTTERY
    elseif FCOGuildLottery.IsGuildMembersJoinDateListActive() then
        doShowDiceHistory = true
        listTypeToUpdate = FCOGL_LISTTYPE_GUILD_MEMBERS_JOIN_DATE
    end

    fcoglUI.Show(nil, doShowDiceHistory, listTypeToUpdate)
end

function fcoglUI.OnWindowMoveStop()
    local frameControl = fcoglUIwindowFrame or fcoglUIwindow.frame
    if not frameControl then return end
    local settings = FCOGuildLottery.settingsVars.settings
    settings.UIwindow.left  = frameControl:GetLeft()
    settings.UIwindow.top   = frameControl:GetTop()
end

function fcoglUI.loadSortGroupHeader(currentTab, listType)
    local settings = FCOGuildLottery.settingsVars.settings
    local uiWindowSettings = settings.UIwindow
    local sortKey = uiWindowSettings.sortKeys[currentTab] and uiWindowSettings.sortKeys[currentTab][listType]
    if sortKey == nil then sortKey = ((listType == FCOGL_LISTTYPE_GUILD_SALES_LOTTERY or listType == FCOGL_LISTTYPE_GUILD_MEMBERS_JOIN_DATE) and "name") or "datetime" end
    local sortOrder = uiWindowSettings.sortOrder[currentTab] and uiWindowSettings.sortOrder[currentTab][listType]
    if sortOrder == nil then sortOrder = ((listType == FCOGL_LISTTYPE_GUILD_SALES_LOTTERY or listType == FCOGL_LISTTYPE_GUILD_MEMBERS_JOIN_DATE) and ZO_SORT_ORDER_UP) or ZO_SORT_ORDER_DOWN end
    df("[fcoglUI.loadSortGroupHeader]currentTab: %s, listType: %s, sortKey: %s, sortOrder: %s", tos(currentTab), tos(listType), tos(sortKey), tos(sortOrder))
    return sortKey, sortOrder
end

function fcoglUI.saveSortGroupHeader(currentTab)
df("[fcoglUI.saveSortGroupHeader]currentTab: %s", tos(currentTab))
    if fcoglUIguildSalesLotteryWindow ~= nil then
        fcoglUIguildSalesLotteryWindow.currentSortKey = fcoglUIguildSalesLotteryWindow.sortHeaderGroup:GetCurrentSortKey()
        fcoglUIguildSalesLotteryWindow.currentSortOrder = fcoglUIguildSalesLotteryWindow.sortHeaderGroup:GetSortDirection()

        FCOGuildLottery.settingsVars.settings.UIwindow.sortKeys[currentTab][FCOGL_LISTTYPE_GUILD_SALES_LOTTERY]  = fcoglUIguildSalesLotteryWindow.currentSortKey
        FCOGuildLottery.settingsVars.settings.UIwindow.sortOrder[currentTab][FCOGL_LISTTYPE_GUILD_SALES_LOTTERY] = fcoglUIguildSalesLotteryWindow.currentSortOrder
df(">listType: %s, sortKey: %s, sortOrder: %s", tos(FCOGL_LISTTYPE_GUILD_SALES_LOTTERY), tos(fcoglUIguildSalesLotteryWindow.currentSortKey), tos(fcoglUIguildSalesLotteryWindow.currentSortOrder))
    end
    if fcoglUIguildMembersJoinedWindow ~= nil then
        fcoglUIguildMembersJoinedWindow.currentSortKey                                                               = fcoglUIguildMembersJoinedWindow.sortHeaderGroup:GetCurrentSortKey()
        fcoglUIguildMembersJoinedWindow.currentSortOrder                                                             = fcoglUIguildMembersJoinedWindow.sortHeaderGroup:GetSortDirection()

        FCOGuildLottery.settingsVars.settings.UIwindow.sortKeys[currentTab][FCOGL_LISTTYPE_GUILD_MEMBERS_JOIN_DATE]  = fcoglUIguildMembersJoinedWindow.currentSortKey
        FCOGuildLottery.settingsVars.settings.UIwindow.sortOrder[currentTab][FCOGL_LISTTYPE_GUILD_MEMBERS_JOIN_DATE] = fcoglUIguildMembersJoinedWindow.currentSortOrder
df(">listType: %s, sortKey: %s, sortOrder: %s", tos(FCOGL_LISTTYPE_GUILD_MEMBERS_JOIN_DATE), tos(fcoglUIguildMembersJoinedWindow.currentSortKey), tos(fcoglUIguildMembersJoinedWindow.currentSortOrder))
    end
    if fcoglUIDiceHistoryWindow ~= nil then
        fcoglUIDiceHistoryWindow.currentSortKey = fcoglUIDiceHistoryWindow.sortHeaderGroup:GetCurrentSortKey()
        fcoglUIDiceHistoryWindow.currentSortOrder = fcoglUIDiceHistoryWindow.sortHeaderGroup:GetSortDirection()

        FCOGuildLottery.settingsVars.settings.UIwindow.sortKeys[currentTab][FCOGL_LISTTYPE_ROLLED_DICE_HISTORY]  = fcoglUIDiceHistoryWindow.currentSortKey
        FCOGuildLottery.settingsVars.settings.UIwindow.sortOrder[currentTab][FCOGL_LISTTYPE_ROLLED_DICE_HISTORY] = fcoglUIDiceHistoryWindow.currentSortOrder
df(">listType: %s, sortKey: %s, sortOrder: %s", tos(FCOGL_LISTTYPE_ROLLED_DICE_HISTORY), tos(fcoglUIDiceHistoryWindow.currentSortKey), tos(fcoglUIDiceHistoryWindow.currentSortOrder))
    end
end

function fcoglUI.enableSaveSortGroupHeaders(headerControlParent)
df("[fcoglUI.enableSaveSortGroupHeaders]currentTab: %s", tos(fcoglUI.CurrentTab))
    if not headerControlParent then return end
    for i=1, headerControlParent:GetNumChildren(), 1 do
        local headerControl = headerControlParent:GetChild(i)
        if headerControl ~= nil then
            --Add the handler "OnMouseUp
            ZO_PostHookHandler(headerControl, "OnMouseUp", function(headerControlVar, mouseButton, upInside, shift, ctrl, alt, command)
                df("sortGroupHeader clicked]currentTab: %s, headerClicked: %s, mouseButton: %s, upInside: %s", tos(fcoglUI.CurrentTab), tos(headerControlVar:GetName()), tos(mouseButton), tos(upInside))
                if upInside then
                    fcoglUI.saveSortGroupHeader(fcoglUI.CurrentTab)
                end
            end, addonName)
        end
    end
end

function fcoglWindowClass:resetSortGroupHeader(currentTab, listType)
df("[fcoglWindowClass:resetSortGroupHeader]currentTab: %s, listType: %s", tos(currentTab), tos(listType))
    currentTab = currentTab or fcoglUI.CurrentTab
    listType = listType or self:GetListType()
    if not currentTab or not listType then return end
    if self.sortHeaderGroup ~= nil then
        local currentSortKey, currentSortOrder
        currentSortKey, currentSortOrder = fcoglUI.loadSortGroupHeader(fcoglUI.CurrentTab, listType)
        --df("> sortKey: " .. tos(self.currentSortKey) .. ", sortOrder: " ..tos(self.currentSortOrder))
        self.sortHeaderGroup:SelectAndResetSortForKey(currentSortKey)
        --Select the sort header again to invert the sort order, if last sort order was inverted
        if currentSortOrder == ZO_SORT_ORDER_DOWN then
            self.sortHeaderGroup:SelectHeaderByKey(currentSortKey)
        --df("> sortKeyAfterInvert: " .. tos(self.currentSortKey) .. ", sortOrderAfterInvert: " ..tos(self.currentSortOrder))
        end
        df("> sortKeyAfterReset: " .. tos(self.currentSortKey) .. ", sortOrderAfterReset: " ..tos(self.currentSortOrder))
    end
end

function fcoglWindowClass:updateSortHeaderAnchorsAndPositions(currentTab, nameHeaderWidth, nameHeaderHeight)
--df("[fcoglWindowClass]:updateSortHeaderAnchorsAndPositions")
    if currentTab == FCOGL_TAB_GUILDSALESLOTTERY then
        if fcoglUI.CurrentState == FCOGL_TAB_STATE_LOADED then
            self.headers:SetMouseEnabled(true)
        end
    end
end


local function checkIfButtonIsEnabled(checkType)
    local currentlySeclectedGuildIndexAtDropdown = fcoglUI.getSelectedGuildsDropEntry().index
    if checkType == FCOGL_DICE_ROLL_TYPE_GUILD_SALES_LOTTERY then
        if not isGuildSalesLotteryActive() or ( FCOGuildLottery.currentlyUsedGuildSalesLotteryGuildIndex ~= nil and
                currentlySeclectedGuildIndexAtDropdown ~= nil and FCOGuildLottery.currentlyUsedGuildSalesLotteryGuildIndex ~= currentlySeclectedGuildIndexAtDropdown) then
            return false
        else
            return true
        end
    end
    if checkType == FCOGL_DICE_ROLL_TYPE_GUILD_MEMBERS_JOIN_DATE then
        if not isGuildMembersJoinDateListActive() or ( FCOGuildLottery.currentlyUsedGuildMembersJoinDateGuildIndex ~= nil and
                currentlySeclectedGuildIndexAtDropdown ~= nil and FCOGuildLottery.currentlyUsedGuildMembersJoinDateGuildIndex ~= currentlySeclectedGuildIndexAtDropdown ) then
            return false
        else
            return true
        end
    end
    return false
end

function fcoglWindowClass:checkStopGuildSalesLotteryButtonEnabled(isEnabled)
    df("fcoglWindowClass:checkStopGuildSalesLotteryButtonEnabled")
    local stopGuildSalesLotteryButton = self.frame:GetNamedChild("StopGuildSalesLottery")
    if not stopGuildSalesLotteryButton then return end
    --No guildId selected?
    isEnabled = isEnabled or self:checkNewGuildSalesLotteryButtonEnabled()
    if not isEnabled or checkIfButtonIsEnabled(FCOGL_DICE_ROLL_TYPE_GUILD_SALES_LOTTERY) == false then
        isEnabled = false
    end
    stopGuildSalesLotteryButton:SetEnabled(isEnabled)
    stopGuildSalesLotteryButton:SetMouseEnabled(isEnabled)
    return isEnabled
end

function fcoglWindowClass:checkRefreshGuildSalesLotteryButtonEnabled(isEnabled)
    df("fcoglWindowClass:checkRefreshGuildSalesLotteryButtonEnabled")
    local reloadGuildSalesLotteryButton = self.frame:GetNamedChild("ReloadGuildSalesLottery")
    if not reloadGuildSalesLotteryButton then return end
    --No guildId selected?
    isEnabled = isEnabled or self:checkNewGuildSalesLotteryButtonEnabled()
    if not isEnabled or checkIfButtonIsEnabled(FCOGL_DICE_ROLL_TYPE_GUILD_SALES_LOTTERY) == false then
        isEnabled = false
    end
    reloadGuildSalesLotteryButton:SetEnabled(isEnabled)
    reloadGuildSalesLotteryButton:SetMouseEnabled(isEnabled)
    return isEnabled
end

function fcoglWindowClass:checkNewGuildSalesLotteryButtonEnabled()
    df("fcoglWindowClass:checkNewGuildSalesLotteryButtonEnabled")
    local newGuildSalesLotteryButton = self.frame:GetNamedChild("NewGuildSalesLottery")
    if not newGuildSalesLotteryButton then return end
    local gotTrader = false
    local isEnabled = true
    if checkIfButtonIsEnabled(FCOGL_DICE_ROLL_TYPE_GUILD_MEMBERS_JOIN_DATE) then
        isEnabled = false
    end
    if isEnabled then
        --No guildId selected?
        local selectedGuildDropsData = fcoglUI.getSelectedGuildsDropEntry()
        local guildIndex = selectedGuildDropsData.index
        gotTrader = selectedGuildDropsData.gotTrader
        if guildIndex == nil or guildIndex == FCOGuildLottery.noGuildIndex or
                not FCOGuildLottery.IsGuildIndexValid(guildIndex) or not gotTrader then
            isEnabled = false
        end
    end
    newGuildSalesLotteryButton:SetEnabled(isEnabled)
    newGuildSalesLotteryButton:SetMouseEnabled(isEnabled)
    return isEnabled, gotTrader
end

function fcoglWindowClass:checkStopGuildMemberJoinedButtonEnabled(isEnabled)
    df("fcoglWindowClass:checkStopGuildMemberJoinedButtonEnabled")
    local stopGuildMemberJoinedListButton = self.frame:GetNamedChild("StopGuildMemberJoinedList")
    if not stopGuildMemberJoinedListButton then return end
    --No guildId selected?
    isEnabled = isEnabled or self:checkNewGuildMemberJoinedButtonEnabled()
    if not isEnabled or checkIfButtonIsEnabled(FCOGL_DICE_ROLL_TYPE_GUILD_MEMBERS_JOIN_DATE) == false then
        isEnabled = false
    end
    stopGuildMemberJoinedListButton:SetEnabled(isEnabled)
    stopGuildMemberJoinedListButton:SetMouseEnabled(isEnabled)
    return isEnabled
end

function fcoglWindowClass:checkNewGuildMemberJoinedButtonEnabled()
    df("fcoglWindowClass:checkNewGuildMemberJoinedButtonEnabled")
    local newGuildMemberJoinedListButton = self.frame:GetNamedChild("StartGuildMemberJoinedList")
    if not newGuildMemberJoinedListButton then return end
    local isEnabled = true
    if checkIfButtonIsEnabled(FCOGL_DICE_ROLL_TYPE_GUILD_SALES_LOTTERY) then
        isEnabled = false
    end
    if isEnabled then
        --No guildId selected?
        local selectedGuildDropsData = fcoglUI.getSelectedGuildsDropEntry()
        local guildIndex = selectedGuildDropsData.index
        if guildIndex == nil or guildIndex == FCOGuildLottery.noGuildIndex or
                not FCOGuildLottery.IsGuildIndexValid(guildIndex) then
            isEnabled = false
        end
    end
    newGuildMemberJoinedListButton:SetEnabled(isEnabled)
    newGuildMemberJoinedListButton:SetMouseEnabled(isEnabled)
    return isEnabled
end

function fcoglWindowClass:UpdateDiceHistoryGuildSalesDrop()
    df("UpdateDiceHistoryGuildSalesDrop")
    local guildHistoryDrop = self.guildHistoryDrop
    if not guildHistoryDrop then return 0 end
    --Get all guild sales history data from the SavedVariables, for the currently selected guildId
    if not isGuildSalesLotteryActive() then return 0 end
    --Get the guild sales history entries from the savedVariables (of the currently selected guildId)
    local guildId = fcoglUI.getSelectedGuildsDropEntry().id
    df(">guildId %s", tos(guildId))
    if not guildId then return 0 end
    local guildSalesHistoriesSavedForGuildId = FCOGuildLottery.diceRollGuildLotteryHistory[guildId]
    if not guildSalesHistoriesSavedForGuildId then return 0 end
    --Get the
    --local daysBefore = FCOGuildLottery.currentlyUsedGuildSalesLotteryDaysBefore
    local uniqueId = FCOGuildLottery.currentlyUsedGuildSalesLotteryUniqueIdentifier --or FCOGuildLottery.BuildUniqueId(guildId, daysBefore)
    local guildSaleshistoriesSavedForGuildIdAndDaysBefore = guildSalesHistoriesSavedForGuildId[uniqueId]
    if not guildSaleshistoriesSavedForGuildIdAndDaysBefore then return 0 end
    local numEntries = NonContiguousCount(guildSaleshistoriesSavedForGuildIdAndDaysBefore)

    --Update the entries of the delete guild sales lottery history entries multi select dropdown
    --fcoglUI.updateGuildSalesLotteryHistoryDeleteDropdownEntries(self.guildHistoryDeleteDrop)

    return numEntries, guildSaleshistoriesSavedForGuildIdAndDaysBefore
end

function fcoglWindowClass:UpdateDiceHistoryGuildMembersJoinedDateListDrop()
    df("UpdateDiceHistoryGuildMembersJoinedDateListDrop")
    local guildHistoryDrop = self.guildMembersJoinedDateHistoryDrop
    if not guildHistoryDrop then return 0 end
    --Get all guild members joined date list data from the SavedVariables, for the currently selected guildId
    if not isGuildMembersJoinDateListActive() then return 0 end
    --Get the guild members joined date list history entries from the savedVariables (of the currently selected guildId)
    local guildId = fcoglUI.getSelectedGuildsDropEntry().id
    df(">guildId %s", tos(guildId))
    if not guildId then return 0 end
    local guildMembersJoinedDateListHistoriesSavedForGuildId = FCOGuildLottery.diceRollGuildMemberJoinedDateListHistory[guildId]
    if not guildMembersJoinedDateListHistoriesSavedForGuildId then return 0 end
    --Get the
    --local daysBefore = FCOGuildLottery.currentlyUsedGuildSalesLotteryDaysBefore
    local uniqueId = FCOGuildLottery.currentlyUsedGuildMembersJoinDateUniqueIdentifier --or FCOGuildLottery.BuildUniqueId(guildId, daysBefore)
    local guildMembersJoinedDateListhistoriesSavedForGuildIdAndDaysBefore = guildMembersJoinedDateListHistoriesSavedForGuildId[uniqueId]
    if not guildMembersJoinedDateListhistoriesSavedForGuildIdAndDaysBefore then return 0 end
    local numEntries = NonContiguousCount(guildMembersJoinedDateListhistoriesSavedForGuildIdAndDaysBefore)

    --Update the entries of the delete guild sales lottery history entries multi select dropdown
    --fcoglUI.updateGuildSalesLotteryHistoryDeleteDropdownEntries(self.guildHistoryDeleteDrop)

    return numEntries, guildMembersJoinedDateListhistoriesSavedForGuildIdAndDaysBefore
end


function fcoglWindowClass:UpdateDiceHistoryInfoLabel()
df("fcoglWindowClass:UpdateDiceHistoryInfoLabel")
    if not self.historyTypeLabel then return end
    self.historyTypeLabel:SetHidden(false)
    self.historyTypeLabel:SetText("")
    if isGuildSalesLotteryActive() then
        self.historyTypeLabel:SetText(GetString(FCOGL_GUILD_SALES_LOTTERY_HISTORY))

        self:initializeSearchDropdown(FCOGL_TAB_GUILDSALESLOTTERY, self.listType, "GuildSalesHistory")
        self.guildHistoryDrop.m_container:SetHidden(false)
        self.guildHistoryDeleteDrop.m_container:SetHidden(false)
        self.guildHistoryDeleteSelectedButton:SetHidden(false)
        self.guildSalesHistoryInfoLabel:SetHidden(false)
        self.guildSalesHistoryInfoLabel:SetText(
                strfor(GetString(FCOGL_CURRENTGUILSALESLOTTERY_DICEHISTORY_TEXT),
                        FCOGuildLottery.FormatDate(FCOGuildLottery.currentlyUsedGuildSalesLotteryTimestamp),
                        tos(FCOGuildLottery.currentlyUsedGuildSalesLotteryDaysBefore)
                )
        )

        self.guildMembersJoinedDateHistoryDrop.m_container:SetHidden(true)
        self.guildMembersJoinedDateHistoryDeleteDrop.m_container:SetHidden(true)
        self.guildMembersJoinedDateHistoryDeleteSelectedButton:SetHidden(true)
        self.guildMembersJoinedDateHistoryInfoLabel:SetHidden(true)
        self.guildMembersJoinedDateHistoryInfoLabel:SetText("")


        --Update the entries of the delete guild sales lottery history entries multi select dropdown
        fcoglUI.updateGuildSalesLotteryHistoryDeleteDropdownEntries(self.guildHistoryDeleteDrop)

    elseif isGuildMembersJoinDateListActive() then
        self.historyTypeLabel:SetText(GetString(FCOGL_GUILD_MEMBER_JOINED_LIST_HISTORY))

        self:initializeSearchDropdown(FCOGL_TAB_GUILDSALESLOTTERY, self.listType, "GuildMembersJoinedDateHistory")
        self.guildMembersJoinedDateHistoryDrop.m_container:SetHidden(false)
        self.guildMembersJoinedDateHistoryDeleteDrop.m_container:SetHidden(false)
        self.guildMembersJoinedDateHistoryDeleteSelectedButton:SetHidden(false)
        self.guildMembersJoinedDateHistoryInfoLabel:SetHidden(false)
        self.guildMembersJoinedDateHistoryInfoLabel:SetText(
                strfor(GetString(FCOGL_CURRENTGUILSALESLOTTERY_DICEHISTORY_TEXT),
                        FCOGuildLottery.FormatDate(FCOGuildLottery.currentlyUsedGuildMembersJoinDateTimestamp),
                        tos(FCOGuildLottery.currentlyUsedGuildMembersJoinDateDaysBefore)
                )
        )

        self.guildHistoryDrop.m_container:SetHidden(true)
        self.guildHistoryDeleteDrop.m_container:SetHidden(true)
        self.guildHistoryDeleteSelectedButton:SetHidden(true)
        self.guildSalesHistoryInfoLabel:SetHidden(true)
        self.guildSalesHistoryInfoLabel:SetText("")

        --Update the entries of the delete guild members joined date list history entries multi select dropdown
        fcoglUI.updateGuildMembersJoinedDateListHistoryDeleteDropdownEntries(self.guildMembersJoinedDateHistoryDeleteDrop)

    else
        self.guildHistoryDrop.m_container:SetHidden(true)
        self.guildHistoryDeleteDrop.m_container:SetHidden(true)
        self.guildHistoryDeleteSelectedButton:SetHidden(true)
        self.guildSalesHistoryInfoLabel:SetHidden(true)
        self.guildSalesHistoryInfoLabel:SetText("")


        self.guildMembersJoinedDateHistoryDrop.m_container:SetHidden(true)
        self.guildMembersJoinedDateHistoryDeleteDrop.m_container:SetHidden(true)
        self.guildMembersJoinedDateHistoryDeleteSelectedButton:SetHidden(true)
        self.guildMembersJoinedDateHistoryInfoLabel:SetHidden(true)
        self.guildMembersJoinedDateHistoryInfoLabel:SetText("")

        if FCOGuildLottery.currentlyUsedDiceRollGuildId ~= nil then
            self.historyTypeLabel:SetText(GetString(FCOGL_DICE_HISTORY_GUILD))
        else
            self.historyTypeLabel:SetText(GetString(FCOGL_DICE_HISTORY_NORMAL))
        end
    end
    --self.historyTypeLabel:SetResizeToFitDescendents(true)
    --self.guildSalesHistoryInfoLabel:SetResizeToFitDescendents(true)
    --self.guildMembersJoinedDateHistoryInfoLabel:SetResizeToFitDescendents(true)
end

function fcoglWindowClass:UpdateGuildSalesDateStartLabel(isGuildSalesLotteryActive, isGuildMembersJoinDateListActive)
df("fcoglWindowClass:UpdateGuildSalesDateStartLabel")
    if not self.guildSalesDateStartLabel then return end
    if isGuildSalesLotteryActive == nil then
        isGuildSalesLotteryActive = isGuildSalesLotteryActive()
    end
    if isGuildMembersJoinDateListActive == nil then
        isGuildMembersJoinDateListActive = isGuildMembersJoinDateListActive()
    end

    if not isGuildSalesLotteryActive then
        self.guildSalesDateStartLabel:SetHidden(true)
        --self.guildSalesDateStartLabel:SetResizeToFitDescendents(true)
        self.guildSalesDateStartLabel:SetText("")
    end
    if self.guildMembersListDateStartLabel ~= nil and not isGuildMembersJoinDateListActive then
        self.guildMembersListDateStartLabel:SetHidden(true)
        --self.guildMembersListDateStartLabel:SetResizeToFitDescendents(true)
        self.guildMembersListDateStartLabel:SetText("")
    end
    if not isGuildSalesLotteryActive then return end
    --[[
    local settings = FCOGuildLottery.settingsVars.settings
    local guildLotteryDateStartTimeStamp = settings.guildLotteryDateStart
    local guildLotteryDateStart = FCOGuildLottery.FormatDate(guildLotteryDateStartTimeStamp)
    local currentDateTable = os.date("*t", os.time())
    local newDateTable = {year=currentDateTable.year, month=currentDateTable.month, day=currentDateTable.day}
    local guildLotteryDateEnd
    if settings.cutOffGuildSalesHistoryCurrentDateMidnight== true then
        newDateTable.hour   = 0
        newDateTable.min    = 0
        newDateTable.sec    = 0
    else
        newDateTable.hour   = currentDateTable.hour
        newDateTable.min    = currentDateTable.min
        newDateTable.sec    = currentDateTable.sec
    end
    guildLotteryDateEnd = os.date("%c", os.time(newDateTable))
    self.guildSalesDateStartLabel:SetText(strfor(GetString(FCOGL_CURRENTGUILSALESLOTTERY_TEXT), guildLotteryDateStart, guildLotteryDateEnd))
    ]]

    --Date end      ->  timestamp of the guild sales lottery
    --Date start    ->  Date start - selected days of the guild sales lottery of the chosen timestamp
    local guildLotteryDateStart, guildLotteryDateEnd, daysBefore
    local guildSalesLotteryTimestamp = FCOGuildLottery.currentlyUsedGuildSalesLotteryTimestamp
    guildLotteryDateEnd     = FCOGuildLottery.FormatDate(guildSalesLotteryTimestamp)
    daysBefore = FCOGuildLottery.currentlyUsedGuildSalesLotteryDaysBefore
    local guildLotteryDateStartTimeStamp =FCOGuildLottery.minusNDays(guildSalesLotteryTimestamp, daysBefore, FCOGL_DEFAULT_GUILD_SELL_HISTORY_DAYS)
    guildLotteryDateStart   = FCOGuildLottery.FormatDate(guildLotteryDateStartTimeStamp)

    self.guildSalesDateStartLabel:SetText(strfor(GetString(FCOGL_CURRENTGUILSALESLOTTERY_TEXT), guildLotteryDateStart, guildLotteryDateEnd, daysBefore))
    self.guildSalesDateStartLabel:SetHidden(false)
end

function fcoglWindowClass:UpdateGuildMemberListDateStartLabel(isGuildSalesLotteryActive, isGuildMembersJoinDateListActive)
df("fcoglWindowClass:UpdateGuildMemberListDateStartLabel")
    if not self.guildMembersListDateStartLabel then return end

    if isGuildSalesLotteryActive == nil then
        isGuildSalesLotteryActive = isGuildSalesLotteryActive()
    end
    if isGuildMembersJoinDateListActive == nil then
        isGuildMembersJoinDateListActive = isGuildMembersJoinDateListActive()
    end

    if not isGuildMembersJoinDateListActive then
        self.guildMembersListDateStartLabel:SetHidden(true)
        --self.guildMembersListDateStartLabel:SetResizeToFitDescendents(true)
        self.guildMembersListDateStartLabel:SetText("")
    end
    if self.guildSalesDateStartLabel ~= nil and not isGuildSalesLotteryActive then
        self.guildSalesDateStartLabel:SetHidden(true)
        --self.guildSalesDateStartLabel:SetResizeToFitDescendents(true)
        self.guildSalesDateStartLabel:SetText("")
    end
    if not isGuildMembersJoinDateListActive then return end

    --Date end      ->  timestamp of the guild members list end
    --Date start    ->  Date start - Daten ed minus selected days of the guild members list
    local guildMembersListDateStart, guildMembersListDateEnd, daysBefore
    local guildMembersListTimestamp = FCOGuildLottery.currentlyUsedGuildMembersJoinDateTimestamp
    daysBefore = FCOGuildLottery.currentlyUsedGuildMembersJoinDateDaysBefore
    guildMembersListDateEnd = FCOGuildLottery.FormatDate(guildMembersListTimestamp)
    local guildMembersListDateStartTimeStamp = FCOGuildLottery.minusNDays(guildMembersListTimestamp, daysBefore, FCOGL_DEFAULT_GUILD_MEMBERS_JOIN_DATE_HISTORY_DAYS)
    guildMembersListDateStart                = FCOGuildLottery.FormatDate(guildMembersListDateStartTimeStamp)

    self.guildMembersListDateStartLabel:SetText(strfor(GetString(FCOGL_CURRENTGUILSALESLOTTERY_TEXT), guildMembersListDateStart, guildMembersListDateEnd, daysBefore))
    self.guildMembersListDateStartLabel:SetHidden(false)
end

function fcoglWindowClass:UpdateUI(state, blockDiceHistoryUpdate, diceHistoryOverride)
    fcoglUI.CurrentState = state
    local listType = self:GetListType()
    df("/////////////////////////////////////")
    df("[window:UpdateUI] state: %s, currentTab: %s, listType: %s, blockDiceHistoryUpdate: %s, diceHistoryOverride: %s", tos(state), tos(fcoglUI.CurrentTab), tos(listType), tos(blockDiceHistoryUpdate), tos(diceHistoryOverride))
    if listType == nil then return end

    FCOGuildLottery.tempEditBoxNumDiceSides = nil
    --fcoglUI.saveSortGroupHeader(fcoglUI.CurrentTab)

    local selfControl = self.control
    local frameControl = self.frame -- the TLC
    ------------------------------------------------------------------------------------------------------------------------
    --SEARCH tab
    if fcoglUI.CurrentTab == FCOGL_TAB_GUILDSALESLOTTERY then
        --......................................................................................................................
        if fcoglUI.CurrentState == FCOGL_TAB_STATE_LOADED then
            --WLW_UpdateSceneFragmentTitle(WISHLIST_SCENE_NAME, TITLE_FRAGMENT, "Label", GetString(WISHLIST_TITLE) ..  " - " .. zo_strformat(GetString(WISHLIST_SETS_LOADED), 0))
            --updateSceneFragmentTitle(WISHLIST_SCENE_NAME, TITLE_FRAGMENT, "Label", GetString(WISHLIST_TITLE) .. " - " .. GetString(WISHLIST_BUTTON_SEARCH_TT):upper())

            local isGuildSalesLotteryCurrentlyActive        = isGuildSalesLotteryActive()
            local isGuildMembersJoinDateListCurrentlyActive = isGuildMembersJoinDateListActive()


            if listType == FCOGL_LISTTYPE_GUILD_SALES_LOTTERY then
                --If no guild sales lottery is active: Hide the total list and it's sort headers!
--d(">00000 GuildSalesLotteryActive: " ..tos(isGuildSalesLotteryActive))
                --Show the left TLC's currently shown list control and hide all others
                hideLeftTLCListControlsExceptThis((isGuildSalesLotteryCurrentlyActive == true and self) or nil, true)
                --Update the currently active listType
                fcoglUI.CurrentListType = listType

                --Hide the search dropdown and edit box?
                self.searchDrop.m_container:SetHidden(not isGuildSalesLotteryCurrentlyActive)
                self.searchBg:SetHidden(not isGuildSalesLotteryCurrentlyActive)
                self.searchBox:SetHidden(not isGuildSalesLotteryCurrentlyActive)
                self.searchBox:Clear()

                --Hide currently unused tabs
                frameControl:GetNamedChild("TabList"):SetEnabled(false)
                frameControl:GetNamedChild("TabList"):SetHidden(true)
                frameControl:GetNamedChild("TabDiceRollHistory"):SetEnabled(true)
                frameControl:GetNamedChild("TabDiceRollHistory"):SetHidden(false)

                --Unhide buttons at the tab
                self.frame:GetNamedChild("RollTheDice"):SetEnabled(true)
                self.frame:GetNamedChild("RollTheDice"):SetHidden(false)
                local isEnabled, gotTrader = self:checkNewGuildSalesLotteryButtonEnabled()
                --self:checkRefreshGuildSalesLotteryButtonEnabled(isEnabled)
                self:checkStopGuildSalesLotteryButtonEnabled(isEnabled)
                self:UpdateGuildSalesDateStartLabel(isGuildSalesLotteryCurrentlyActive, isGuildMembersJoinDateListCurrentlyActive)

                local isEnabledNewGuildMemberList = self:checkNewGuildMemberJoinedButtonEnabled()
                self:checkStopGuildMemberJoinedButtonEnabled(isEnabledNewGuildMemberList)
                self:UpdateGuildMemberListDateStartLabel(isGuildSalesLotteryCurrentlyActive, isGuildMembersJoinDateListCurrentlyActive)

                --Update the guild's dropdown box to select the currently active entry (if it was updated via slash commands)
                -->Alsoupdate if guild sales lottery is enabled, but do not run the callback of the dropdown -> Just the visual update
                local diceRollType, guildIndex = FCOGuildLottery.getCurrentDiceRollTypeAndGuildIndex()
                fcoglUI.updateUIGuildsDropNow(diceRollType, guildIndex, true, false, true)

                self.frame:GetNamedChild("NewGuildSalesLottery"):SetHidden(not gotTrader)
                --self.frame:GetNamedChild("ReloadGuildSalesLottery"):SetHidden(false)
                self.frame:GetNamedChild("StopGuildSalesLottery"):SetHidden(not gotTrader)

                self.frame:GetNamedChild("StartGuildMemberJoinedList"):SetHidden(false)
                self.frame:GetNamedChild("StopGuildMemberJoinedList"):SetHidden(false)

                self.frame:GetNamedChild("GuildsDrop"):SetHidden(false)

                --Unhide the scroll list
                self.list:SetHidden(false)
                selfControl:GetNamedChild("List"):SetHidden(false)
                --Unhide the scroll list headers
                self.headers:SetHidden(false)

                self.headerRank:SetHidden(false)
                --self.headerDate:SetHidden(false)
                self.headerName:SetHidden(false)
                --self.headerItem:SetHidden(false)
                self.headerPrice:SetHidden(false)
                self.headerTax:SetHidden(false)
                self.headerAmount:SetHidden(false)
                self.headerInfo:SetHidden(false)

                --selfControl:SetHidden(false)

                --Hide/Unhide the dice history frame -> Will call recursively function UpdateUI(state) for listType
                --FCOGL_LISTTYPE_ROLLED_DICE_HISTORY
                fcoglUI.ToggleDiceRollHistory(FCOGuildLottery.settingsVars.settings.UIDiceHistoryWindow.isHidden, blockDiceHistoryUpdate, diceHistoryOverride)


            elseif listType == FCOGL_LISTTYPE_GUILD_MEMBERS_JOIN_DATE then
                --If no guild members joined list is active: Hide the total list and it's sort headers!
--d(">00000 GuildMembersJoinedListActive: " ..tos(isGuildMembersJoinDateListActive))
                --Show the left TLC's currently shown list control and hide all others
                hideLeftTLCListControlsExceptThis((isGuildMembersJoinDateListCurrentlyActive == true and self) or nil, true)
                --Update the currently active listType
                fcoglUI.CurrentListType = listType

                --Hide the search dropdown and edit box?
                self.searchDrop.m_container:SetHidden(not isGuildMembersJoinDateListCurrentlyActive)
                self.searchBg:SetHidden(not isGuildMembersJoinDateListCurrentlyActive)
                self.searchBox:SetHidden(not isGuildMembersJoinDateListCurrentlyActive)
                self.searchBox:Clear()

                --Hide currently unused tabs
                frameControl:GetNamedChild("TabList"):SetEnabled(false)
                frameControl:GetNamedChild("TabList"):SetHidden(true)
                frameControl:GetNamedChild("TabDiceRollHistory"):SetEnabled(true)
                frameControl:GetNamedChild("TabDiceRollHistory"):SetHidden(false)

                --Unhide buttons at the tab
                self.frame:GetNamedChild("RollTheDice"):SetEnabled(true)
                self.frame:GetNamedChild("RollTheDice"):SetHidden(false)
                local isEnabled, gotTrader = self:checkNewGuildSalesLotteryButtonEnabled()
                --self:checkRefreshGuildSalesLotteryButtonEnabled(isEnabled)
                self:checkStopGuildSalesLotteryButtonEnabled(isEnabled)
                self:UpdateGuildSalesDateStartLabel(isGuildSalesLotteryCurrentlyActive, isGuildMembersJoinDateListCurrentlyActive)

                local isEnabledNewGuildMemberList = self:checkNewGuildMemberJoinedButtonEnabled()
                self:checkStopGuildMemberJoinedButtonEnabled(isEnabledNewGuildMemberList)
                self:UpdateGuildMemberListDateStartLabel(isGuildSalesLotteryCurrentlyActive, isGuildMembersJoinDateListCurrentlyActive)

                --Update the guild's dropdown box to select the currently active entry (if it was updated via slash commands)
                -->Alsoupdate if guild sales lottery is enabled, but do not run the callback of the dropdown -> Just the visual update
                local diceRollType, guildIndex = FCOGuildLottery.getCurrentDiceRollTypeAndGuildIndex()
                fcoglUI.updateUIGuildsDropNow(diceRollType, guildIndex, false, true, true)

                self.frame:GetNamedChild("NewGuildSalesLottery"):SetHidden(not gotTrader)
                --self.frame:GetNamedChild("ReloadGuildSalesLottery"):SetHidden(false)
                self.frame:GetNamedChild("StopGuildSalesLottery"):SetHidden(not gotTrader)

                self.frame:GetNamedChild("StartGuildMemberJoinedList"):SetHidden(false)
                self.frame:GetNamedChild("StopGuildMemberJoinedList"):SetHidden(false)

                self.frame:GetNamedChild("GuildsDrop"):SetHidden(false)

                --Unhide the scroll list
                self.list:SetHidden(false)
                selfControl:GetNamedChild("List"):SetHidden(false)
                --Unhide the scroll list headers
                self.headers:SetHidden(false)

                self.headerRank:SetHidden(false)
                --self.headerDate:SetHidden(false)
                self.headerName:SetHidden(false)
                self.headerInvitedBy:SetHidden(false)
                self.headerInfo:SetHidden(false)

                --selfControl:SetHidden(false)

                --Hide/Unhide the dice history frame -> Will call recursively function UpdateUI(state) for listType
                --FCOGL_LISTTYPE_GUILD_MEMBERS_JOIN_DATE
                fcoglUI.ToggleDiceRollHistory(FCOGuildLottery.settingsVars.settings.UIDiceHistoryWindow.isHidden, blockDiceHistoryUpdate, diceHistoryOverride)


            elseif listType == FCOGL_LISTTYPE_ROLLED_DICE_HISTORY then
                --Unhide the scroll list
                --self.control:GetNamedChild("List"):SetHidden(false)
                self.list:SetHidden(false)
                --Unhide the scroll list headers
                self.headers:SetHidden(false)

                self:UpdateDiceHistoryInfoLabel()

                self.headerNo:SetHidden(false)
                self.headerDate:SetHidden(false)
                self.headerName:SetHidden(false)
                self.headerRoll:SetHidden(false)

                --Unhide the search
                self.searchBox:SetHidden(false)
                self.searchBg:SetHidden(false)
                --Unhide the search dropdown box
                self.frame:GetNamedChild("SearchDrop"):SetHidden(false)
                self.searchBox:Clear()
            end

            --Reset the sortGroupHeader
            -->Currently not needed as there is only 1 tab
            --self:resetSortGroupHeader(fcoglUI.CurrentTab, listType)

            self:RefreshData()

            if listType == FCOGL_LISTTYPE_ROLLED_DICE_HISTORY then
                fcoglUI.UpdateClearCurrentHistoryButton(self.masterList)
            end
        end
        ------------------------------------------------------------------------------------------------------------------------
    end
    df("////////////////////////////////////////////////")
    self:updateSortHeaderAnchorsAndPositions(fcoglUI.CurrentTab, nil, nil)
end -- fcoglWindow:UpdateUI(state)

--Change the tabs at the WishList menu
function fcoglUI.SetTab(index, blockDiceHistoryUpdate, override, listTypeToUpdate)
df("[SetTab] - index: %s, override: %s", tos(index), tos(override))
    if not fcoglUIwindow or not fcoglUIwindowFrame then return end
    --fcoglUI.saveSortGroupHeader(fcoglUI.CurrentTab)

    --Do not activate active tab
    if override == true or fcoglUI.CurrentTab == nil or (fcoglUI.CurrentTab ~= nil and fcoglUI.CurrentTab ~= index) then
        --Change to the new tab
        fcoglUI.CurrentTab = index

        fcoglUI.ResetWindowLists()

        --Reset variable
        fcoglUI.comingFromSortScrollListSetupFunction = false
        --Update the UI (hide/show items), and also check for the dice roll history to show
        --via function fcoglUI.ToggleDiceRollHistory() -> Calls fcoglUIDiceHistoryWindow:UpdateUI

        --Get the needed list to show now:
        --No guild list at all?
        --Normal guild dice throws
        --Guild sales lottery           fcoglUIguildSalesLotteryWindow
        --Guild members joined list     fcoglUIguildMembersJoinedListWindow --todo 20221218 if listType is FCOGL_LISTTYPE_NORMAL_THROWS or FCOGL_LISTTYPE_GUILD_MEMBER_THROWS: What list should be shown then? None?

        -- Was a list type to update predefined and passed in by parameter?
        local currentlyShownListObject
        if listTypeToUpdate ~= nil then
            currentlyShownListObject = getListsObjectByListType(listTypeToUpdate)
        else
            currentlyShownListObject = getCurrentlyShownListsObject()
        end
        if currentlyShownListObject == nil then return end
        currentlyShownListObject:UpdateUI(fcoglUI.CurrentState, blockDiceHistoryUpdate, override)
    end
end

function fcoglUI.setDiceRollHistoryButtonState(newState)
df("setDiceRollHistoryButtonState")
    local frameControl = fcoglUIwindowFrame or (fcoglUIwindow and fcoglUIwindow.frame)
    local tabDiceRollHistoryButton = frameControl:GetNamedChild("TabDiceRollHistory")
    local newStateVal = buttonNewStateVal[newState]
df(">newStateVal: %s, newState: %s", tos(newStateVal), tos(newState))
    tabDiceRollHistoryButton:SetState(newStateVal)
    FCOGuildLottery.settingsVars.settings.UIDiceHistoryWindow.isHidden = newState
end

--Toggle the dice roll history "attached" window part at the right
function fcoglUI.ToggleDiceRollHistory(setHidden, blockToggle, diceHistoryHiddenOverride)
    blockToggle = blockToggle or false
    df("[ToggleDiceRollHistory] - setHidden: %s, blockToggle: %s, historyHiddenOverride: %s", tos(setHidden), tos(blockToggle), tos(diceHistoryHiddenOverride))
    local frameControl = fcoglUIwindowFrame or (fcoglUIwindow and fcoglUIwindow.frame)
    --Update the currently used dice roll type as it could have been reset to "generic" via a slash command
    FCOGuildLottery.UpdateCurrentDiceRollType(fcoglUIwindow)

    if frameControl == nil or frameControl:IsControlHidden() then return end
    local frameDiceHistoryControl = fcoglUIDiceHistoryWindow and fcoglUIDiceHistoryWindow.control
    if frameDiceHistoryControl == nil then return end
    local isHidden = frameDiceHistoryControl:IsControlHidden()
    local newHiddenState
    if diceHistoryHiddenOverride ~= nil then
        if diceHistoryHiddenOverride == true then
            newHiddenState = isHidden
        else
            if isHidden == true then
                newHiddenState = false
            else
                newHiddenState = true
            end
        end
    end
df(">isHidden: %s, newState: %s", tos(isHidden), tos(newHiddenState))
    if newHiddenState == nil then newHiddenState = setHidden end
df(">>newState2: %s", tos(newHiddenState))
    if newHiddenState == nil then
        if isHidden == true then
            newHiddenState = false
        else
            newHiddenState = true
        end
    end
    df(">newHiddenState: %s", tos(newHiddenState))
    if not blockToggle then
        frameDiceHistoryControl:SetHidden(newHiddenState)
    end
    --Update the dice history list, showing it's entries
df(">>>>>>>>>>>Updating the UI of the DiceRollHistory now!")
    fcoglUIDiceHistoryWindow:UpdateUI(fcoglUI.CurrentState, false, nil)

    --Update the texture at the toggle button
    if diceHistoryHiddenOverride == true or not blockToggle then
        fcoglUI.setDiceRollHistoryButtonState(newHiddenState)
    end
end

local function deleteHistoryEntryNow(alsoDeleteSV, entryData, deleteSingleEntry)
    local timestamp = (entryData ~= nil and entryData.timestamp) or nil
    deleteSingleEntry = deleteSingleEntry or false
    df("deleteHistoryEntryNow - alsoDeleteSV: %s, timestamp: %s, deleteSingleEntry: %s", tos(alsoDeleteSV), tos(timestamp), tos(deleteSingleEntry))

    --local updateListNow     = false
    local wasDeleted        = true
    local countDeletedItems = 0

    if alsoDeleteSV == true then
        wasDeleted = false
        local guildId
        --Check which list is currently active
        if isGuildSalesLotteryActive() then
            df(">guild sales lottery is active!")
            --Delete guild sales lottery entries
            local currentGuildSalesLotteryUniqueId
            local currentGuildSalesLotteryTimeStamp
            guildId = FCOGuildLottery.currentlyUsedGuildSalesLotteryGuildId
            currentGuildSalesLotteryUniqueId = FCOGuildLottery.currentlyUsedGuildSalesLotteryUniqueIdentifier
            currentGuildSalesLotteryTimeStamp = FCOGuildLottery.currentlyUsedGuildSalesLotteryTimestamp

            if timestamp ~= nil then
                df(">entryData uses timestamp: %s", tos(timestamp))
            end

            if FCOGuildLottery.settingsVars.settings.diceRollGuildLotteryHistory[guildId] ~= nil and
                    FCOGuildLottery.settingsVars.settings.diceRollGuildLotteryHistory[guildId][currentGuildSalesLotteryUniqueId] ~= nil
                --and FCOGuildLottery.settingsVars.settings.diceRollGuildLotteryHistory[guildId][currentGuildSalesLotteryUniqueId][currentGuildSalesLotteryTimeStamp] ~= nil then
                then
                if FCOGuildLottery.diceRollGuildLotteryHistory[guildId] ~= nil and
                        FCOGuildLottery.diceRollGuildLotteryHistory[guildId][currentGuildSalesLotteryUniqueId] ~= nil
                        --and FCOGuildLottery.diceRollGuildLotteryHistory[guildId][currentGuildSalesLotteryUniqueId][currentGuildSalesLotteryTimeStamp] ~= nil then
                    then
                    if entryData ~= nil then
                        if deleteSingleEntry == true and timestamp ~= nil and FCOGuildLottery.diceRollGuildLotteryHistory[guildId][currentGuildSalesLotteryUniqueId][currentGuildSalesLotteryTimeStamp]
                                and FCOGuildLottery.diceRollGuildLotteryHistory[guildId][currentGuildSalesLotteryUniqueId][currentGuildSalesLotteryTimeStamp][timestamp] ~= nil then
                            df(">>sv 1 entry set = nil")
                            FCOGuildLottery.diceRollGuildLotteryHistory[guildId][currentGuildSalesLotteryUniqueId][currentGuildSalesLotteryTimeStamp][timestamp] = nil
                            FCOGuildLottery.settingsVars.settings.diceRollGuildLotteryHistory[guildId][currentGuildSalesLotteryUniqueId][currentGuildSalesLotteryTimeStamp][timestamp] = nil
                            countDeletedItems = 1
                            wasDeleted = true
                        elseif deleteSingleEntry == false then
                            if timestamp ~= nil and FCOGuildLottery.diceRollGuildLotteryHistory[guildId][currentGuildSalesLotteryUniqueId][timestamp] ~= nil then
                                df(">>sv 1 timestamp table set = nil")
                                countDeletedItems = NonContiguousCount(FCOGuildLottery.diceRollGuildLotteryHistory[guildId][currentGuildSalesLotteryUniqueId][timestamp])
                                if countDeletedItems > 1 then countDeletedItems = countDeletedItems - 1 end --subtract 1 because of the "daysBefore" entry!
                                FCOGuildLottery.diceRollGuildLotteryHistory[guildId][currentGuildSalesLotteryUniqueId][timestamp]                       = nil
                                FCOGuildLottery.settingsVars.settings.diceRollGuildLotteryHistory[guildId][currentGuildSalesLotteryUniqueId][timestamp] = nil
                                wasDeleted = true
                            else
                                df(">>sv 1 set = nil")
                                countDeletedItems = NonContiguousCount(FCOGuildLottery.diceRollGuildLotteryHistory[guildId][currentGuildSalesLotteryUniqueId][currentGuildSalesLotteryTimeStamp])
                                if countDeletedItems > 1 then countDeletedItems = countDeletedItems - 1 end --subtract 1 because of the "daysBefore" entry!
                                FCOGuildLottery.diceRollGuildLotteryHistory[guildId][currentGuildSalesLotteryUniqueId][currentGuildSalesLotteryTimeStamp] = nil
                                FCOGuildLottery.settingsVars.settings.diceRollGuildLotteryHistory[guildId][currentGuildSalesLotteryUniqueId][currentGuildSalesLotteryTimeStamp] = nil
                                wasDeleted = true
                            end
                        end
                    else
                        if FCOGuildLottery.diceRollGuildLotteryHistory[guildId][currentGuildSalesLotteryUniqueId][currentGuildSalesLotteryTimeStamp] ~= nil then
                            countDeletedItems = NonContiguousCount(FCOGuildLottery.diceRollGuildLotteryHistory[guildId][currentGuildSalesLotteryUniqueId][currentGuildSalesLotteryTimeStamp])
                            if countDeletedItems > 1 then countDeletedItems = countDeletedItems - 1 end --subtract 1 because of the "daysBefore" entry!
                            df(">>sv ALL set = {}")
                            FCOGuildLottery.diceRollGuildLotteryHistory[guildId][currentGuildSalesLotteryUniqueId][currentGuildSalesLotteryTimeStamp] = {}
                            FCOGuildLottery.settingsVars.settings.diceRollGuildLotteryHistory[guildId][currentGuildSalesLotteryUniqueId][currentGuildSalesLotteryTimeStamp] = {}
                            wasDeleted = true
                        end
                    end
                    df("Guild sales lottery history data deleted, guildId %s, uniqueId %s lotteryTimeStamp %s", tos(guildId), tos(currentGuildSalesLotteryUniqueId), tos(currentGuildSalesLotteryTimeStamp))
                end
            end

        --Check which list is currently active
        elseif isGuildMembersJoinDateListActive() then
            df(">guild members joined date list is active!")

            --Delete guild members joined date list entries
            local currentGuildMembersJoinedDateListUniqueId
            local currentGuildMembersJoinedDateListTimeStamp
            guildId                                    = FCOGuildLottery.currentlyUsedGuildMembersJoinDateGuildId
            currentGuildMembersJoinedDateListUniqueId  = FCOGuildLottery.currentlyUsedGuildMembersJoinDateUniqueIdentifier
            currentGuildMembersJoinedDateListTimeStamp = FCOGuildLottery.currentlyUsedGuildMembersJoinDateTimestamp

            if FCOGuildLottery.settingsVars.settings.diceRollGuildMemberJoinedDateListHistory[guildId] ~= nil and
                    FCOGuildLottery.settingsVars.settings.diceRollGuildMemberJoinedDateListHistory[guildId][currentGuildMembersJoinedDateListUniqueId] ~= nil
                --and FCOGuildLottery.settingsVars.settings.diceRollGuildMemberJoinedDateListHistory[guildId][currentGuildMembersJoinedDateListUniqueId][currentGuildMembersJoinedDateListTimeStamp] ~= nil then
                then
                if FCOGuildLottery.diceRollGuildMemberJoinedDateListHistory[guildId] ~= nil and
                        FCOGuildLottery.diceRollGuildMemberJoinedDateListHistory[guildId][currentGuildMembersJoinedDateListUniqueId] ~= nil
                        --and FCOGuildLottery.diceRollGuildMemberJoinedDateListHistory[guildId][currentGuildMembersJoinedDateListUniqueId][currentGuildMembersJoinedDateListTimeStamp] ~= nil then
                    then
                    if entryData ~= nil then
                        if deleteSingleEntry == true and timestamp ~= nil and FCOGuildLottery.diceRollGuildMemberJoinedDateListHistory[guildId][currentGuildMembersJoinedDateListUniqueId]
                                and FCOGuildLottery.diceRollGuildMemberJoinedDateListHistory[guildId][currentGuildMembersJoinedDateListUniqueId][currentGuildMembersJoinedDateListTimeStamp][timestamp] ~= nil then
                            df(">>sv 1 entry set = nil")
                            FCOGuildLottery.diceRollGuildMemberJoinedDateListHistory[guildId][currentGuildMembersJoinedDateListUniqueId][currentGuildMembersJoinedDateListTimeStamp][timestamp]                       = nil
                            FCOGuildLottery.settingsVars.settings.diceRollGuildMemberJoinedDateListHistory[guildId][currentGuildMembersJoinedDateListUniqueId][currentGuildMembersJoinedDateListTimeStamp][timestamp] = nil
                            countDeletedItems = 1
                            wasDeleted = true
                        elseif deleteSingleEntry == false then
                            if timestamp ~= nil and FCOGuildLottery.diceRollGuildMemberJoinedDateListHistory[guildId][currentGuildMembersJoinedDateListUniqueId][timestamp] ~= nil then
                                countDeletedItems = NonContiguousCount(FCOGuildLottery.diceRollGuildMemberJoinedDateListHistory[guildId][currentGuildMembersJoinedDateListUniqueId][timestamp])
                                if countDeletedItems > 1 then countDeletedItems = countDeletedItems - 1 end --subtract 1 because of the "daysBefore" entry!
                                df(">>sv 1 timestamp table set = nil")
                                FCOGuildLottery.diceRollGuildMemberJoinedDateListHistory[guildId][currentGuildMembersJoinedDateListUniqueId][timestamp]                       = nil
                                FCOGuildLottery.settingsVars.settings.diceRollGuildMemberJoinedDateListHistory[guildId][currentGuildMembersJoinedDateListUniqueId][timestamp] = nil
                                wasDeleted = true
                            else
                                if FCOGuildLottery.diceRollGuildMemberJoinedDateListHistory[guildId][currentGuildMembersJoinedDateListUniqueId][currentGuildMembersJoinedDateListTimeStamp] ~= nil then
                                    df(">>sv 1 set = nil")
                                    countDeletedItems = NonContiguousCount(FCOGuildLottery.diceRollGuildMemberJoinedDateListHistory[guildId][currentGuildMembersJoinedDateListUniqueId][currentGuildMembersJoinedDateListTimeStamp])
                                    if countDeletedItems > 1 then countDeletedItems = countDeletedItems - 1 end --subtract 1 because of the "daysBefore" entry!
                                    FCOGuildLottery.diceRollGuildMemberJoinedDateListHistory[guildId][currentGuildMembersJoinedDateListUniqueId][currentGuildMembersJoinedDateListTimeStamp]                       = nil
                                    FCOGuildLottery.settingsVars.settings.diceRollGuildMemberJoinedDateListHistory[guildId][currentGuildMembersJoinedDateListUniqueId][currentGuildMembersJoinedDateListTimeStamp] = nil
                                    wasDeleted = true
                                end
                            end
                        end
                    else
                        if FCOGuildLottery.diceRollGuildMemberJoinedDateListHistory[guildId][currentGuildMembersJoinedDateListUniqueId][currentGuildMembersJoinedDateListTimeStamp] ~= nil then
                            df(">>sv ALL set = {}")
                            countDeletedItems = NonContiguousCount(FCOGuildLottery.diceRollGuildMemberJoinedDateListHistory[guildId][currentGuildMembersJoinedDateListUniqueId][currentGuildMembersJoinedDateListTimeStamp])
                            if countDeletedItems > 1 then countDeletedItems = countDeletedItems - 1 end --subtract 1 because of the "daysBefore" entry!
                            FCOGuildLottery.diceRollGuildMemberJoinedDateListHistory[guildId][currentGuildMembersJoinedDateListUniqueId][currentGuildMembersJoinedDateListTimeStamp]                       = {}
                            FCOGuildLottery.settingsVars.settings.diceRollGuildMemberJoinedDateListHistory[guildId][currentGuildMembersJoinedDateListUniqueId][currentGuildMembersJoinedDateListTimeStamp] = {}
                            wasDeleted = true
                        end
                    end
                    df("Guild members joined date history data deleted, guildId %s, uniqueId %s timeStamp %s", tos(guildId), tos(currentGuildMembersJoinedDateListUniqueId), tos(currentGuildMembersJoinedDateListTimeStamp))
                end
            end

        else
            --Delete only normal guild entries
            guildId = FCOGuildLottery.currentlyUsedDiceRollGuildId
            if guildId ~= nil then
                df(">guild id history delete-guildId: " ..tos(guildId))

                if FCOGuildLottery.settingsVars.settings.diceRollGuildsHistory[guildId] ~= nil then
                    if FCOGuildLottery.diceRollGuildsHistory[guildId] ~= nil then
                        if entryData ~= nil and timestamp ~= nil then
                            if deleteSingleEntry == true and FCOGuildLottery.diceRollGuildsHistory[guildId][timestamp] ~= nil then
                                FCOGuildLottery.diceRollGuildsHistory[guildId][timestamp] = nil
                                FCOGuildLottery.settingsVars.settings.diceRollGuildsHistory[guildId][timestamp] = nil
                                countDeletedItems = 1
                                wasDeleted = true
                                df("Guild history data deleted 1 entry, guildId %s", tos(guildId))
                            end
                        else
                            FCOGuildLottery.diceRollGuildsHistory[guildId] = {}
                            FCOGuildLottery.settingsVars.settings.diceRollGuildsHistory[guildId] = {}
                            countDeletedItems = #fcoglUIDiceHistoryWindow.masterList
                            wasDeleted = true
                            df("Guild history data - all cleared, guildId %s", tos(guildId))
                        end
                    end
                end
            else
                df(">normal roll history delete")
                if FCOGuildLottery.settingsVars.settings.diceRollHistory ~= nil then
                    if FCOGuildLottery.diceRollHistory ~= nil then
                        if entryData ~= nil and timestamp ~= nil then
                            if deleteSingleEntry == true and FCOGuildLottery.diceRollHistory[timestamp] ~= nil then
                                FCOGuildLottery.diceRollHistory[timestamp] = nil
                                FCOGuildLottery.settingsVars.settings.diceRollHistory[timestamp] = nil
                                countDeletedItems = 1
                                wasDeleted = true
                            end
                        else
                            FCOGuildLottery.diceRollHistory = {}
                            FCOGuildLottery.settingsVars.settings.diceRollHistory = {}
                            countDeletedItems = #fcoglUIDiceHistoryWindow.masterList
                            wasDeleted = true
                            df("History data - all cleared")
                        end
                    end
                end
            end
        end
        if wasDeleted == true then
            dfa(strfor(GetString(FCOGL_CLEARED_HISTORY_COUNT), tos(countDeletedItems)))
        end
    end
    return wasDeleted, countDeletedItems
end

function fcoglUI.DeleteDiceHistoryList(alsoDeleteSV, entryData, entriesTable, deleteSingleEntry)
df("DeleteDiceHistoryList - alsoDeleteSV: %s", tos(alsoDeleteSV))
    if not fcoglUIwindow or not fcoglUIwindowFrame then return end
    alsoDeleteSV            = alsoDeleteSV or false
    --Delete SavedVariables of the history list?
    local updateListNow     = false
    local wasDeleted        = true
    local countDeletedItems = 0

    if entryData == nil and entriesTable ~= nil and #entriesTable > 0 then
        local wasDeletedLoop = false
        local countDeletedItemsLoop = 0
        for _, entryDataLoop in ipairs(entriesTable) do
            wasDeletedLoop, countDeletedItemsLoop = deleteHistoryEntryNow(alsoDeleteSV, entryDataLoop, deleteSingleEntry)
            countDeletedItems = countDeletedItems + countDeletedItemsLoop
            if wasDeletedLoop == true then
                wasDeleted = true
            end
        end
    elseif entriesTable == nil then
        wasDeleted, countDeletedItems = deleteHistoryEntryNow(alsoDeleteSV, entryData, deleteSingleEntry)
    end
    if wasDeleted == true and countDeletedItems > 0 then
        updateListNow = true
    end
df(">updateListNow: %s", tos(updateListNow))

    --Something got deleted? Do we need an update of the lists?
    if updateListNow == true then
        ZO_ScrollList_Clear(fcoglUIDiceHistoryWindow.list)
        fcoglUIDiceHistoryWindow.masterList = {}
        if alsoDeleteSV == true then
            fcoglUIDiceHistoryWindow:RefreshData()

            fcoglUIDiceHistoryWindow:UpdateDiceHistoryInfoLabel()
        end
    end
end

function fcoglUI.ResetWindowLists()
    if not fcoglUIwindow or not fcoglUIwindowFrame then return end
    local listObjectShown = getCurrentlyShownListsObject()
    if listObjectShown == nil or listObjectShown.list == nil then return end

    --Clear the master list of the currently shown ZO_SortFilterLists
    ZO_ScrollList_Clear(listObjectShown.list)
    listObjectShown.masterList = {}

    --Update the lists now -> Will only call the updater functions of the scroll list -> BuildMasterList and CommitList etc.
    fcoglUI.DeleteDiceHistoryList(false, nil, nil, false)
end

function fcoglUI.RefreshWindowLists(showUIifHidden, listTypeToUpdate)
    showUIifHidden = showUIifHidden or false
df("RefreshWindowLists - showUIifHidden: %s", tos(showUIifHidden))
    --Is the UI existing already?
    if fcoglUIwindow ~= nil then
        local windowFrame = fcoglUIwindow.frame
        --local diceHistoryWindowFrame = fcoglUIDiceHistoryWindow and fcoglUIDiceHistoryWindow.frame
        if windowFrame ~= nil then
            --Is the UI currently shown?
            if windowFrame:IsControlHidden() then
                --Setting "Show UI" -> Create UI now and show it
                if showUIifHidden == true then
                    fcoglUI.Show(true, true, listTypeToUpdate)
                end
            end
            if not windowFrame:IsControlHidden() then
                --Set the UI tab to "Guild Sales Lottery" and refresh the data
                fcoglUI.SetTab(FCOGL_TAB_GUILDSALESLOTTERY, true, true, listTypeToUpdate) --activate even if already shown, to update it
--[[
                if not diceHistoryWindowFrame:IsControlHidden() then
d(">>DiceHistoryFrame is shown -> RefreshData()")
                    --Only update the dice history list
                    fcoglUIDiceHistoryWindow:RefreshData()
                end
]]
            end
        end
    end
end

local function checkComboBoxExistsAndGetSelectedEntry(comboBoxName)
    if fcoglUIwindowFrame == nil then return end
    local comboBox = fcoglUIwindowFrame[comboBoxName]
    if comboBox == nil then return end
    local selectedData = comboBox:GetSelectedItemData()
    return comboBox, selectedData
end

--Will be called from the slash commands, not from the UI window!
function fcoglUI.ChangeGuildsDropSelectedByIndex(newIndex, noCallback)
    noCallback = noCallback or false
    df("fcoglUI.ChangeGuildsDropSelectedByIndex - index: %s, noCallback: %s", tos(newIndex), tos(noCallback))
    local guildsDrop, selectedData = checkComboBoxExistsAndGetSelectedEntry("guildsDrop")
    local selectedIndex = selectedData.selectedIndex
df(">selectedIndex: %s", tos(selectedIndex))
    if selectedIndex == newIndex and noCallback == true then return true end
    guildsDrop:SelectItemByIndex(newIndex, noCallback)
end

--Will be called from the slash commands, not from the UI window!
function fcoglUI.ChangeGuildsDropSelectedByGuildIndex(guildIndex, noCallback)
    noCallback = noCallback or false
    df("fcoglUI.ChangeGuildsDropSelectedByGuildIndex - guildIndex: %s, noCallback: %s", tos(guildIndex), tos(noCallback))
    if guildIndex > MAX_GUILDS then return end
    local guildsDrop, selectedData = checkComboBoxExistsAndGetSelectedEntry("guildsDrop")
    local selectedIndex = selectedData.index
df(">selectedIndex: %s", tos(selectedIndex))
    if selectedIndex == guildIndex and noCallback == true then end
    local function evalFuncGuildIndex(p_item)
        df(">>evalFuncGuildIndex - isGuild: %s, id: %s", tos(p_item.isGuild), tos(p_item.id))
        if p_item.isGuild and p_item.id ~= nil then
            local lguildIndex = p_item.index
            if lguildIndex ~= nil and lguildIndex == guildIndex then
                return true
            end
        end
        return false
    end
    --Supress the callback. Should be already checked and done before this function gets called from a slash command!
    if guildsDrop:SetSelectedItemByEval(evalFuncGuildIndex, noCallback) then
        df(">guildsDrop item for guildIndex %s was selected!", tos(guildIndex))
        return true
    end
end


function fcoglUI.ClearCurrentHistory()
    local listToCheck, _ = getHistoryList()
df("ClearCurrentHistory")
    if listToCheck and #listToCheck > 0 then
        fcoglUI.DeleteDiceHistoryList(true, nil, nil, false)
        fcoglUI.UpdateClearCurrentHistoryButton()
    end
end

--[[
function fcoglUI.deleteGuildSalesLotteryHistoryTimestamp(entry)
    df("deleteGuildSalesLotteryHistoryTimestamp - name %s, guildId %s, timeStamp: %s", tos(entry.name), tos(entry.guildId), tos(entry.timestamp))
    local stopNow = false
    if isGuildSalesLotteryActive() == true and
        entry.timestamp == FCOGuildLottery.currentlyUsedGuildSalesLotteryTimestamp and
        entry.guildId == FCOGuildLottery.currentlyUsedGuildSalesLotteryGuildId then
        stopNow = true
    end
    fcoglUI.DeleteDiceHistoryList(true, entry, nil, false)
    fcoglUI.UpdateClearCurrentHistoryButton()

    if stopNow == true then
        --Currently active guild sales lottery was deleted! Stop it now
        FCOGuildLottery.StopGuildSalesLottery(true)
    end
end
]]

function fcoglUI.updateGuildSalesLotteryHistoryDeleteDropdownEntries(guildHistoryDeleteDrop)
    df("updateGuildSalesLotteryHistoryDeleteDropdownEntries")
    guildHistoryDeleteDrop = guildHistoryDeleteDrop or fcoglUIDiceHistoryWindow.guildHistoryDeleteDrop
    if not guildHistoryDeleteDrop then return end

    local guildSalesLotteryHistoryEntriesOfGuild = {}

    local isGuildSalesLotteryCurrentlyActive = isGuildSalesLotteryActive()

    --Fill the table guildSalesLotteryHistoryEntriesOfGuild with the current guildId's SavedVariables of the guild sales
    --lottery history entries
    if isGuildSalesLotteryCurrentlyActive == true then
        local currentGuildSalesLotteryGuildId = FCOGuildLottery.currentlyUsedGuildSalesLotteryGuildId
        local currentGuildSalesLotteryUniqueId = FCOGuildLottery.currentlyUsedGuildSalesLotteryUniqueIdentifier
        local currentGuildSalesLotteryDaysBefore = FCOGuildLottery.currentlyUsedGuildSalesLotteryDaysBefore
        if FCOGuildLottery.diceRollGuildLotteryHistory[currentGuildSalesLotteryGuildId] and
            FCOGuildLottery.diceRollGuildLotteryHistory[currentGuildSalesLotteryGuildId][currentGuildSalesLotteryUniqueId] then
            local currentGuildSalesLotteryHistoryEntries = FCOGuildLottery.diceRollGuildLotteryHistory[currentGuildSalesLotteryGuildId][currentGuildSalesLotteryUniqueId]
            for timeStamp, dataOfGuildSalesLotteryRolls in pairs(currentGuildSalesLotteryHistoryEntries) do
                local countDiceThrowData = NonContiguousCount(dataOfGuildSalesLotteryRolls)
                if countDiceThrowData > 1 then countDiceThrowData = countDiceThrowData -1 end --remove 1 because of the "daysBefore" entry
                local dataEntry = {}
                local dateTimeString = strfor(FCOGuildLottery.FormatDate(timeStamp) .. " (#%s)", tos(countDiceThrowData))
                dataEntry.name = dateTimeString
                dataEntry.timestamp = timeStamp
                dataEntry.guildId = currentGuildSalesLotteryGuildId
                dataEntry.uniqueId = currentGuildSalesLotteryUniqueId
                dataEntry.daysBefore = currentGuildSalesLotteryDaysBefore
                table.insert(guildSalesLotteryHistoryEntriesOfGuild, dataEntry)
            end
            if #guildSalesLotteryHistoryEntriesOfGuild > 0 then
                --Sort the list now
                table.sort(guildSalesLotteryHistoryEntriesOfGuild, sortByDescTimeStamp)
            end
        end
    end

    updateDropdownEntries(guildHistoryDeleteDrop, guildSalesLotteryHistoryEntriesOfGuild)
end

function fcoglUI.updateGuildMembersJoinedDateListHistoryDeleteDropdownEntries(guildMembersJoinedDateListHistoryDeleteDrop)
    df("updateGuildMembersJoinedDateListHistoryDeleteDropdownEntries")
    guildMembersJoinedDateListHistoryDeleteDrop = guildMembersJoinedDateListHistoryDeleteDrop or fcoglUIDiceHistoryWindow.guildMembersJoinedDateHistoryDeleteDrop
    if not guildMembersJoinedDateListHistoryDeleteDrop then return end

    local guildMembersJoinedDateListHistoryEntriesOfGuild = {}

    local isGuildMembersJoinedDateListCurrentlyActive = isGuildMembersJoinDateListActive()

    --Fill the table guildMembersJoinedDateListHistoryEntriesOfGuild with the current guildId's SavedVariables of the guild
    --Members Joined Date List history entries
    if isGuildMembersJoinedDateListCurrentlyActive == true then
        local currentGuildMembersJoinedDateListGuildId  = FCOGuildLottery.currentlyUsedGuildMembersJoinDateGuildId
        local currentGuildMembersJoinedDateListUniqueId   = FCOGuildLottery.currentlyUsedGuildMembersJoinDateUniqueIdentifier
        local currentGuildMembersJoinedDateListDaysBefore = FCOGuildLottery.currentlyUsedGuildMembersJoinDateDaysBefore
        if FCOGuildLottery.diceRollGuildMemberJoinedDateListHistory[currentGuildMembersJoinedDateListGuildId] and
            FCOGuildLottery.diceRollGuildMemberJoinedDateListHistory[currentGuildMembersJoinedDateListGuildId][currentGuildMembersJoinedDateListUniqueId] then
            local currentGuildMembersJoinedDateListHistoryEntries = FCOGuildLottery.diceRollGuildMemberJoinedDateListHistory[currentGuildMembersJoinedDateListGuildId][currentGuildMembersJoinedDateListUniqueId]
            for timeStamp, dataOfGuildSalesLotteryRolls in pairs(currentGuildMembersJoinedDateListHistoryEntries) do
                local countDiceThrowData = NonContiguousCount(dataOfGuildSalesLotteryRolls)
                if countDiceThrowData > 1 then countDiceThrowData = countDiceThrowData -1 end --remove 1 because of the "daysBefore" entry
                local dataEntry = {}
                local dateTimeString = strfor(FCOGuildLottery.FormatDate(timeStamp) .. " (#%s)", tos(countDiceThrowData))
                dataEntry.name = dateTimeString
                dataEntry.timestamp = timeStamp
                dataEntry.guildId = currentGuildMembersJoinedDateListGuildId
                dataEntry.uniqueId = currentGuildMembersJoinedDateListUniqueId
                dataEntry.daysBefore = currentGuildMembersJoinedDateListDaysBefore
                table.insert(guildMembersJoinedDateListHistoryEntriesOfGuild, dataEntry)
            end
            if #guildMembersJoinedDateListHistoryEntriesOfGuild > 0 then
                --Sort the list now
                table.sort(guildMembersJoinedDateListHistoryEntriesOfGuild, sortByDescTimeStamp)
            end
        end
    end

    updateDropdownEntries(guildMembersJoinedDateListHistoryDeleteDrop, guildMembersJoinedDateListHistoryEntriesOfGuild)
end

function fcoglUI.UpdateClearCurrentHistoryButton(listToCheck)
    local fcoglUIdiceHistoryWindow
    local blubb
    if listToCheck == nil then
        listToCheck, fcoglUIdiceHistoryWindow = getHistoryList()
    else
        blubb, fcoglUIdiceHistoryWindow = getHistoryList()
    end
    local clearHistoryButton = fcoglUIdiceHistoryWindow.clearHistoryButton
    if listToCheck == nil or #listToCheck == 0 then
        clearHistoryButton:SetMouseEnabled(false)
        clearHistoryButton:SetHidden(true)
        return false
    else
        clearHistoryButton:SetMouseEnabled(true)
        clearHistoryButton:SetHidden(false)
        return true
    end
end

function fcoglUI.updateDeleteSelectedGuildSalesLotteryHistoryButton(comboBoxDropdown)
    df("updateDeleteSelectedGuildSalesLotteryHistoryButton")
    if not comboBoxDropdown then return end
    local numSelectedEntries = comboBoxDropdown:GetNumSelectedEntries()
    local doEnable = numSelectedEntries > 0 or false
    fcoglUIDiceHistoryWindow.guildHistoryDeleteSelectedButton:SetMouseEnabled(doEnable)
end

function fcoglUI.updateDeleteSelectedGuildMembersJoinedDateHistoryButton(comboBoxDropdown)
    df("updateDeleteSelectedGuildMembersJoinedDateHistoryButton")
    if not comboBoxDropdown then return end
    local numSelectedEntries = comboBoxDropdown:GetNumSelectedEntries()
    local doEnable = numSelectedEntries > 0 or false
    fcoglUIDiceHistoryWindow.guildMembersJoinedDateHistoryDeleteSelectedButton:SetMouseEnabled(doEnable)
end

local function deleteSelectedGuildSalesLotteryHistoryEntriesNow(comboBoxDropdown)
    local guildSalesLotteryHistoryEntriesToDelete = {}
    for _, item in ipairs(comboBoxDropdown:GetItems()) do
        if comboBoxDropdown:IsItemSelected(item) then
            table.insert(guildSalesLotteryHistoryEntriesToDelete, item.entryData)
        end
    end
    if #guildSalesLotteryHistoryEntriesToDelete > 0 then
        fcoglUI.DeleteDiceHistoryList(true, nil, guildSalesLotteryHistoryEntriesToDelete, false)
        comboBoxDropdown:ClearAllSelections()
        fcoglUI.updateDeleteSelectedGuildSalesLotteryHistoryButton(comboBoxDropdown)
        fcoglUI.UpdateClearCurrentHistoryButton()
    end
end

local function deleteSelectedGuildMemberJoinedDateListHistoryEntriesNow(comboBoxDropdown)
    local guildMemberJoinedDateListHistoryEntriesToDelete = {}
    for _, item in ipairs(comboBoxDropdown:GetItems()) do
        if comboBoxDropdown:IsItemSelected(item) then
            table.insert(guildMemberJoinedDateListHistoryEntriesToDelete, item.entryData)
        end
    end
    if #guildMemberJoinedDateListHistoryEntriesToDelete > 0 then
        fcoglUI.DeleteDiceHistoryList(true, nil, guildMemberJoinedDateListHistoryEntriesToDelete, false)
        comboBoxDropdown:ClearAllSelections()
        fcoglUI.updateDeleteSelectedGuildMembersJoinedDateHistoryButton(comboBoxDropdown)
        fcoglUI.UpdateClearCurrentHistoryButton()
    end
end


function fcoglUI.checkDeleteSelectedGuildSalesLotteryHistoryEntries()
    df("checkDeleteSelectedGuildSalesLotteryHistoryEntries")
    local comboBoxDropdown = fcoglUIDiceHistoryWindow.guildHistoryDeleteDrop
    if not comboBoxDropdown then return end
    local numSelectedEntries = comboBoxDropdown:GetNumSelectedEntries()
    if numSelectedEntries <= 0 then return end
    --df(">selected %s entries!", tos(numSelectedEntries))

    --Show dialog asking if you really want to delete the entries
    FCOGuildLottery.showAskDialogNow(nil, nil, false,
        function()
            deleteSelectedGuildSalesLotteryHistoryEntriesNow(comboBoxDropdown)
        end,
        function()  end,
        {
            title       = GetString(FCOGL_DELETE_HISTORY_ENTRIES_DIALOG_TITLE),
            question    = strfor(GetString(FCOGL_DELETE_HISTORY_ENTRIES_DIALOG_QUESTION), tos(numSelectedEntries)),
        },
        true
    )
end

function fcoglUI.checkDeleteSelectedGuildMemberJoinedDateListHistoryEntries()
    df("checkDeleteSelectedGuildMemberJoinedDateListHistoryEntries")
    local comboBoxDropdown = fcoglUIDiceHistoryWindow.guildMembersJoinedDateHistoryDeleteDrop
    if not comboBoxDropdown then return end
    local numSelectedEntries = comboBoxDropdown:GetNumSelectedEntries()
    if numSelectedEntries <= 0 then return end
    --df(">selected %s entries!", tos(numSelectedEntries))

    --Show dialog asking if you really want to delete the entries
    FCOGuildLottery.showAskDialogNow(nil, nil, false,
        function()
            deleteSelectedGuildMemberJoinedDateListHistoryEntriesNow(comboBoxDropdown)
        end,
        function()  end,
        {
            title       = GetString(FCOGL_DELETE_HISTORY_ENTRIES_DIALOG_TITLE),
            question    = strfor(GetString(FCOGL_DELETE_HISTORY_ENTRIES_DIALOG_QUESTION), tos(numSelectedEntries)),
        },
        true
    )
end


function fcoglUI.toggleWindowLayer()
df("fcoglUI.toggleWindowLayer")
    local window = fcoglUIwindow
    if not window then return end
    local windowFrame = fcoglUIwindow.frame
    if not windowFrame then return end
    local currentLayer = windowFrame:GetDrawLayer()
    local currentTier  = windowFrame:GetDrawTier()

    --DrawLayer
    --DL_BACKGROUND = 0
    --DL_CONTROLS = 1
    --DL_OVERLAY = 3
    --DL_TEXT = 2

    --DrawTier
    --DT_HIGH = 2
    --DT_LOW = 0
    --DT_MEDIUM = 1
    --DT_PARENT = 999


    if currentLayer < DL_OVERLAY or currentTier < DT_HIGH then
        windowFrame:SetDrawLayer(DL_OVERLAY)
        windowFrame:SetDrawTier(DT_HIGH)
    elseif currentLayer == DL_OVERLAY or currentTier == DT_HIGH then
        windowFrame:SetDrawLayer(DL_CONTROLS)
        windowFrame:SetDrawTier(DT_MEDIUM)
    end
end

function fcoglUI.showTabButtonContextMenu(tabButton)
    if tabButton == FCOGLFrameTabGuildSales then
        ClearMenu()
        AddCustomMenuItem(GetString(FCOGL_TOGGLE_WINDOW_DRAW_LAYER), function()
            fcoglUI.toggleWindowLayer()
        end)
        AddCustomMenuItem(GetString(FCOGL_CLOSE), function()
            fcoglUI.Show(false, nil, nil)
        end)
        ShowMenu(FCOGLFrameTabGuildSales)
    end
end