GuildSalesJournal = GuildSalesJournal or {}
GuildSalesJournal.Journal = GuildSalesJournal.Journal or {}

local GSJ = GuildSalesJournal
local Journal = GSJ.Journal

local SCENE_NAME = "guildSalesJournalGamepad"
local MENU_ENTRY_ID = 998
local SALES_ICON = "EsoUI/Art/Guild/History/Gamepad/gp_guildHistory_purchases.dds"
local LISTED_ICON = "EsoUI/Art/Guild/History/Gamepad/gp_guildHistory_trader.dds"

local Q1_SALES = 1
local Q1_LISTED = 2

local LEDGER_SUBPAGE_INCOME = 0
local LEDGER_SUBPAGE_SESSION = 1
local LEDGER_SUBPAGE_PURCHASES = 2
local LEDGER_SUBPAGE_CHARGES = 3
local LEDGER_SUBPAGE_COUNT = 4
local LEDGER_VISIBLE_TRANSACTIONS = 2
local SESSION_TRANSACTION_LIMIT = 500

local SALES_PAGE_LEDGER = 0
local SALES_PAGE_ALL = 1
local SALES_PAGE_FIRST_GUILD = 2
local SALES_PAGE_LAST_GUILD = 6
local SALES_PAGE_COUNT = 7

local HISTORY_DATA_TYPE = 1
local LISTING_DATA_TYPE = 2
local ROW_HEIGHT = 70
local LISTING_ROW_HEIGHT = 96
local ENTRIES_PER_PAGE = 100
local LISTING_SLOT_LIMIT = 30

local function FormatNumber(value)
    value = math.floor(tonumber(value) or 0)
    return ZO_CommaDelimitNumber and ZO_CommaDelimitNumber(value) or tostring(value)
end

local function Financials(total, quantity)
    total = math.floor(tonumber(total) or 0)
    quantity = math.max(1, math.floor(tonumber(quantity) or 1))
    local fee = math.floor(total * 0.01)
    local cut = math.floor(total * 0.07)
    return math.floor(total / quantity), fee, cut, total - fee - cut
end


local function IsAny(value, ...)
    for index = 1, select("#", ...) do
        local candidate = select(index, ...)
        if candidate ~= nil and value == candidate then
            return true
        end
    end
    return false
end

local function ContainsAny(text, ...)
    text = string.lower(tostring(text or ""))
    for index = 1, select("#", ...) do
        local needle = string.lower(tostring(select(index, ...) or ""))
        if needle ~= "" and string.find(text, needle, 1, true) then
            return true
        end
    end
    return false
end

local function NowMilliseconds()
    if GetFrameTimeMilliseconds then return GetFrameTimeMilliseconds() end
    return (GetTimeStamp and GetTimeStamp() or 0) * 1000
end

local function ProbeBool(value)
    return value and "Y" or "N"
end

local function ProbeClock()
    if GetTimeString then return GetTimeString() end
    local stamp = GetTimeStamp and GetTimeStamp() or 0
    return os and os.date and os.date("%H:%M:%S", stamp) or tostring(stamp)
end

local function Id64String(value)
    if value == nil then return "" end
    if Id64ToString then
        local ok, result = pcall(Id64ToString, value)
        if ok and result then return tostring(result) end
    end
    return tostring(value)
end

local function TradingHouseResultName(value)
    local names = {
        [TRADING_HOUSE_RESULT_SUCCESS] = "SUCCESS",
        [TRADING_HOUSE_RESULT_AWAITING_INITIAL_STATUS] = "AWAITING_INITIAL_STATUS",
        [TRADING_HOUSE_RESULT_LISTINGS_PENDING] = "LISTINGS_PENDING",
        [TRADING_HOUSE_RESULT_NOT_OPEN] = "NOT_OPEN",
        [TRADING_HOUSE_RESULT_CANT_SWITCH_GUILDS_WHILE_AWAITING_RESPONSE] = "GUILD_SWITCH_BLOCKED",
        [TRADING_HOUSE_RESULT_SEARCH_RATE_EXCEEDED] = "RATE_EXCEEDED",
    }
    return names[value] or tostring(value or "nil")
end

local function ClassifyPurchaseItem(itemLink, itemName, entryType, soundCategory)
    local itemType, specializedItemType
    if itemLink and itemLink ~= "" and GetItemLinkItemType then
        itemType, specializedItemType = GetItemLinkItemType(itemLink)
    end

    if IsAny(itemType, ITEMTYPE_MOUNT)
        or ContainsAny(itemName, "research scroll", "research lesson", "riding lesson", "mount training") then
        return "characterUpgrades"
    end

    if IsAny(itemType,
            ITEMTYPE_FURNISHING,
            ITEMTYPE_FURNISHING_MATERIAL,
            ITEMTYPE_RACIAL_STYLE_MOTIF,
            ITEMTYPE_RECIPE,
            ITEMTYPE_ADDITIVE,
            ITEMTYPE_BLACKSMITHING_BOOSTER,
            ITEMTYPE_BLACKSMITHING_MATERIAL,
            ITEMTYPE_BLACKSMITHING_RAW_MATERIAL,
            ITEMTYPE_CLOTHIER_BOOSTER,
            ITEMTYPE_CLOTHIER_MATERIAL,
            ITEMTYPE_CLOTHIER_RAW_MATERIAL,
            ITEMTYPE_ENCHANTING_RUNE_ASPECT,
            ITEMTYPE_ENCHANTING_RUNE_ESSENCE,
            ITEMTYPE_ENCHANTING_RUNE_POTENCY,
            ITEMTYPE_ENCHANTMENT_BOOSTER,
            ITEMTYPE_FLAVORING,
            ITEMTYPE_INGREDIENT,
            ITEMTYPE_JEWELRYCRAFTING_BOOSTER,
            ITEMTYPE_JEWELRYCRAFTING_MATERIAL,
            ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER,
            ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL,
            ITEMTYPE_RAW_MATERIAL,
            ITEMTYPE_REAGENT,
            ITEMTYPE_SPICE,
            ITEMTYPE_STYLE_MATERIAL,
            ITEMTYPE_WOODWORKING_BOOSTER,
            ITEMTYPE_WOODWORKING_MATERIAL,
            ITEMTYPE_WOODWORKING_RAW_MATERIAL)
        or IsAny(specializedItemType,
            SPECIALIZED_ITEMTYPE_COLLECTIBLE_STYLE_PAGE,
            SPECIALIZED_ITEMTYPE_CONTAINER_STYLE_PAGE,
            SPECIALIZED_ITEMTYPE_FURNISHING_ATTUNABLE_STATION,
            SPECIALIZED_ITEMTYPE_FURNISHING_CRAFTING_STATION)
        or ContainsAny(itemName,
            "style page", "motif", "blueprint", "diagram", "pattern",
            "formula", "design", "sketch", "furnishing", "furniture") then
        return "homeImprovements"
    end

    if IsAny(itemType,
            ITEMTYPE_CONSUMABLE_ABILITY,
            ITEMTYPE_DRINK,
            ITEMTYPE_FOOD,
            ITEMTYPE_POISON,
            ITEMTYPE_POISON_BASE,
            ITEMTYPE_POTION,
            ITEMTYPE_POTION_BASE)
        or IsAny(soundCategory,
            ITEM_SOUND_CATEGORY_DRINK,
            ITEM_SOUND_CATEGORY_FOOD,
            ITEM_SOUND_CATEGORY_POTION,
            ITEM_SOUND_CATEGORY_SCROLL)
        or ContainsAny(itemName, "experience scroll", "xp scroll", "ambrosia") then
        return "consumables"
    end

    return nil
end

local function RelativeTime(timestamp)
    timestamp = tonumber(timestamp) or 0
    local now = GetTimeStamp and GetTimeStamp() or timestamp
    local seconds = math.max(0, now - timestamp)
    local days = math.floor(seconds / 86400)
    if days > 0 then return string.format("%d day%s ago", days, days == 1 and "" or "s") end
    local hours = math.floor(seconds / 3600)
    if hours > 0 then return string.format("%d hour%s ago", hours, hours == 1 and "" or "s") end
    local minutes = math.floor(seconds / 60)
    if minutes > 0 then return string.format("%d min ago", minutes) end
    return "just now"
end

local function AddToJournalMenu()
    if Journal.menuAdded or not ZO_MENU_ENTRIES or not ZO_MENU_MAIN_ENTRIES then return false end

    local journalEntry
    for _, entry in ipairs(ZO_MENU_ENTRIES) do
        if entry.id == ZO_MENU_MAIN_ENTRIES.JOURNAL then
            journalEntry = entry
            break
        end
    end
    if not journalEntry then return false end

    local menuData = {
        name = "Personal Finance Journal",
        icon = SALES_ICON,
        scene = SCENE_NAME,
    }

    local entry = ZO_GamepadEntryData:New(menuData.name, menuData.icon)
    entry:SetIconTintOnSelection(true)
    if entry.SetIconDisabledTintOnSelection then
        entry:SetIconDisabledTintOnSelection(true)
    end
    entry.data = menuData
    entry.id = MENU_ENTRY_ID

    if journalEntry.subMenu then
        table.insert(journalEntry.subMenu, entry)
    else
        table.insert(ZO_MENU_ENTRIES, entry)
    end

    if MAIN_MENU_GAMEPAD then
        MAIN_MENU_GAMEPAD:RefreshLists()
        MAIN_MENU_GAMEPAD:UpdateEntryEnabledStates()
    end

    Journal.menuAdded = true
    return true
end

----------------------------------------------------------------
-- Native-style Guild History list using ZOS's own gamepad row
-- template and ZO_SortFilterList_Gamepad input handling.
----------------------------------------------------------------
PFJ_HistoryList_Gamepad = ZO_SortFilterList_Gamepad:Subclass()

function PFJ_HistoryList_Gamepad:New(control, owner)
    local object = ZO_Object.New(self)
    object.owner = owner
    object:Initialize(control)
    return object
end

function PFJ_HistoryList_Gamepad:Initialize(control)
    self.control = control
    self.list = control:GetNamedChild("List")
    self.footer = ZO_PagedListFooter:New(control:GetNamedChild("Footer"))
    self.loadingIcon = control:GetNamedChild("LoadingIcon")
    self.currentPage = 1
    self.hasNextPage = false
    self.scopeGuildId = nil
    self.masterList = {}

    ZO_SortFilterList_Gamepad.Initialize(self, control)
end

function PFJ_HistoryList_Gamepad:InitializeSortFilterList(...)
    ZO_SortFilterList_Gamepad.InitializeSortFilterList(self, ...)
    ZO_ScrollList_AddDataType(
        self.list,
        HISTORY_DATA_TYPE,
        "PFJHistoryRow",
        ROW_HEIGHT,
        function(control, data) self:SetupHistoryRow(control, data) end
    )
end

function PFJ_HistoryList_Gamepad:SetScope(guildId)
    self.scopeGuildId = guildId
    self.currentPage = 1
    self:RefreshData()
    self:ResetToTop()
end

function PFJ_HistoryList_Gamepad:BuildMasterList()
    self.masterList = GSJ:GetSortedRecords(self.scopeGuildId)
    local cumulativeFee, cumulativeCut, cumulativeProfit = 0, 0, 0
    for index, sale in ipairs(self.masterList) do
        local _, fee, cut, profit = Financials(sale.price, sale.quantity)
        cumulativeFee = cumulativeFee + fee
        cumulativeCut = cumulativeCut + cut
        cumulativeProfit = cumulativeProfit + profit
        sale.pfjIndex = index
        sale.cumulativeFee = cumulativeFee
        sale.cumulativeCut = cumulativeCut
        sale.cumulativeProfit = cumulativeProfit
    end
end

function PFJ_HistoryList_Gamepad:FilterScrollList()
    local scrollData = ZO_ScrollList_GetDataList(self.list)
    ZO_ClearNumericallyIndexedTable(scrollData)

    local total = #self.masterList
    local startIndex = ((self.currentPage - 1) * ENTRIES_PER_PAGE) + 1
    local endIndex = math.min(total, startIndex + ENTRIES_PER_PAGE - 1)
    self.hasNextPage = endIndex < total

    for index = startIndex, endIndex do
        scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(HISTORY_DATA_TYPE, self.masterList[index])
    end

    self.footer:SetPageText(self.currentPage)
    self:RefreshFooter()
end

function PFJ_HistoryList_Gamepad:SortScrollList()
    -- Records are already newest-first in GSJ:GetSortedRecords.
end

function PFJ_HistoryList_Gamepad:SetupHistoryRow(control, sale)
    ZO_SortFilterList_Gamepad.SetupRow(self, control, sale)

    local quantity = math.max(1, tonumber(sale.quantity) or 1)
    local description = string.format(
        "Sold %s x%s for %s gold",
        sale.itemLink or "Unknown item",
        FormatNumber(quantity),
        FormatNumber(sale.price)
    )

    control.descriptionLabel:SetText(description)
    control.timeLabel:SetText(RelativeTime(sale.timestamp))

    local shade = control:GetNamedChild("CumulativeShade")
    if shade then
        local alpha = 0
        if self.selectedGlobalIndex and sale.pfjIndex then
            if sale.pfjIndex < self.selectedGlobalIndex then
                alpha = 0.05
            elseif sale.pfjIndex == self.selectedGlobalIndex then
                alpha = 0.10
            end
        end
        shade:SetColor(0, 0, 0, alpha)
    end
end

function PFJ_HistoryList_Gamepad:OnSelectionChanged(oldData, newData)
    ZO_SortFilterList_Gamepad.OnSelectionChanged(self, oldData, newData)
    self.selectedGlobalIndex = newData and newData.pfjIndex or nil
    ZO_ScrollList_RefreshVisible(self.list)
    if self.owner then
        self.owner:UpdateSaleDetails(newData)
    end
end

function PFJ_HistoryList_Gamepad:ResetToTop()
    local NO_CALLBACK = nil
    local ANIMATE_INSTANTLY = true
    ZO_SortFilterList_Gamepad.ResetToTop(self, NO_CALLBACK, ANIMATE_INSTANTLY)
end

function PFJ_HistoryList_Gamepad:ShowPreviousPage()
    if self.currentPage > 1 then
        self.currentPage = self.currentPage - 1
        self:RefreshFilters()
        self:ResetToTop()
    end
end

function PFJ_HistoryList_Gamepad:ShowNextPage()
    if self.hasNextPage then
        self.currentPage = self.currentPage + 1
        self:RefreshFilters()
        self:ResetToTop()
    end
end

function PFJ_HistoryList_Gamepad:RefreshFooter()
    local showFooter = self:IsActivated() and (self.currentPage > 1 or self.hasNextPage)
    self.footer:SetHidden(not showFooter)
    if showFooter then
        self.footer.previousButton:SetEnabled(self.currentPage > 1)
        self.footer.nextButton:SetEnabled(self.hasNextPage)
    end
end

function PFJ_HistoryList_Gamepad:HasEntries()
    return #self.masterList > 0
end

----------------------------------------------------------------
-- Native gamepad scroll list for current guild-store listings.
-- One row per listing; no artificial item pagination.
----------------------------------------------------------------
PFJ_ListedItemsList_Gamepad = ZO_SortFilterList_Gamepad:Subclass()

function PFJ_ListedItemsList_Gamepad:New(control, owner)
    local object = ZO_Object.New(self)
    object.owner = owner
    object:Initialize(control)
    return object
end

function PFJ_ListedItemsList_Gamepad:Initialize(control)
    self.control = control
    self.list = control:GetNamedChild("List")
    self.guild = nil
    self.masterList = {}
    self.selectedData = nil
    ZO_SortFilterList_Gamepad.Initialize(self, control)
end

function PFJ_ListedItemsList_Gamepad:InitializeSortFilterList(...)
    ZO_SortFilterList_Gamepad.InitializeSortFilterList(self, ...)
    ZO_ScrollList_AddDataType(
        self.list,
        LISTING_DATA_TYPE,
        "PFJListedItemRow",
        LISTING_ROW_HEIGHT,
        function(control, data) self:SetupListedRow(control, data) end
    )
end

function PFJ_ListedItemsList_Gamepad:SetGuild(guild)
    self.guild = guild
    self.selectedData = nil
    self:RefreshData()
    self:ResetToTop()
end

function PFJ_ListedItemsList_Gamepad:BuildMasterList()
    self.masterList = {}
    local snapshot = self.guild and self.guild.snapshot or nil
    for index, item in ipairs(snapshot and snapshot.items or {}) do
        self.masterList[#self.masterList + 1] = {
            pfjIndex = index,
            uniqueId = tostring(item[1] or ""),
            itemLink = tostring(item[2] or ""),
            itemName = tostring(item[3] or "Unknown Item"),
            quantity = math.max(1, tonumber(item[4]) or 1),
            salePrice = math.max(0, tonumber(item[5]) or 0),
            unitPrice = math.max(0, tonumber(item[6]) or 0),
            expiresAt = tonumber(item[7]) or 0,
        }
    end
end

function PFJ_ListedItemsList_Gamepad:FilterScrollList()
    local scrollData = ZO_ScrollList_GetDataList(self.list)
    ZO_ClearNumericallyIndexedTable(scrollData)
    for _, listing in ipairs(self.masterList) do
        scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(LISTING_DATA_TYPE, listing)
    end
end

function PFJ_ListedItemsList_Gamepad:SortScrollList()
    -- Native listing order is retained.
end

function PFJ_ListedItemsList_Gamepad:SetupListedRow(control, listing)
    ZO_SortFilterList_Gamepad.SetupRow(self, control, listing)

    local description = control.descriptionLabel
    local timeLabel = control.timeLabel
    local priceLabel = control:GetNamedChild("Price")

    if description then
        description:ClearAnchors()
        description:SetAnchor(TOPLEFT, control, TOPLEFT, 22, 8)
        description:SetAnchor(TOPRIGHT, control, TOPRIGHT, -250, 8)
        description:SetFont("ZoFontGamepadCondensed34")
        description:SetMaxLineCount(1)
        local itemText = listing.itemLink ~= "" and listing.itemLink or listing.itemName
        description:SetText(string.format("%s  |cB8C8D8x%s|r", itemText, FormatNumber(listing.quantity)))
    end

    if timeLabel then
        timeLabel:ClearAnchors()
        timeLabel:SetAnchor(TOPRIGHT, control, TOPRIGHT, -18, 12)
        timeLabel:SetDimensions(224, 34)
        timeLabel:SetFont("ZoFontGamepadCondensed30")
        timeLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        timeLabel:SetText(self.owner and self.owner:FormatListingRemaining(listing.expiresAt) or "")
    end

    if priceLabel then
        priceLabel:ClearAnchors()
        priceLabel:SetAnchor(BOTTOMLEFT, control, BOTTOMLEFT, 22, -10)
        priceLabel:SetAnchor(BOTTOMRIGHT, control, BOTTOMRIGHT, -18, -10)
        priceLabel:SetHeight(34)
        priceLabel:SetFont("ZoFontGamepadCondensed30")
        local text = string.format("|cFFFFFF%s gold|r", FormatNumber(listing.salePrice))
        if listing.quantity > 1 and listing.unitPrice > 0 then
            text = text .. string.format("  |c8FAED8%s each|r", FormatNumber(listing.unitPrice))
        end
        priceLabel:SetText(text)
    end
end

function PFJ_ListedItemsList_Gamepad:OnSelectionChanged(oldData, newData)
    ZO_SortFilterList_Gamepad.OnSelectionChanged(self, oldData, newData)
    self.selectedData = newData
    if self.owner then
        self.owner:UpdateListingDetails(newData)
    end
end

function PFJ_ListedItemsList_Gamepad:ResetToTop()
    local NO_CALLBACK = nil
    local ANIMATE_INSTANTLY = true
    ZO_SortFilterList_Gamepad.ResetToTop(self, NO_CALLBACK, ANIMATE_INSTANTLY)
end

function PFJ_ListedItemsList_Gamepad:HasEntries()
    return #self.masterList > 0
end

function PFJ_ListedItemsList_Gamepad:RefreshVisibleRows()
    ZO_ScrollList_RefreshVisible(self.list)
end

----------------------------------------------------------------
-- Personal Finance Journal shell: STARS-style Q1 plus
-- Chronicle-style page 0..6 sequence.
----------------------------------------------------------------
GuildSalesJournal_Gamepad = ZO_Gamepad_ParametricList_Screen:Subclass()

function GuildSalesJournal_Gamepad:New(control)
    local object = ZO_Object.New(self)
    object:Initialize(control)
    return object
end

function GuildSalesJournal_Gamepad:Initialize(control)
    self.control = control
    self.contentFrame = control:GetNamedChild("ContentFrame")
    self.ledgerPage = self.contentFrame:GetNamedChild("LedgerPage")
    self.historyPage = self.contentFrame:GetNamedChild("HistoryPage")
    self.listedPage = self.contentFrame:GetNamedChild("ListedPage")
    self.salesPageIndex = SALES_PAGE_LEDGER
    self.currentQ1Page = Q1_SALES
    self.focusInHistory = false
    self.focusInListed = false
    self.sessionStartedAt = nil
    self.sessionTransactions = {}
    self.ledgerSubpageIndex = LEDGER_SUBPAGE_SESSION
    self.lastKnownTotal = nil
    self.currencyRefreshToken = 0
    self.pendingCurrencyEvents = {}
    self.pendingPurchaseContext = nil
    self.pendingIncomeContext = nil
    self.pendingLootContext = nil
    self.activeFinanceSession = nil
    self.tradingHouseOpen = false
    self.tradingHouseListingsHooked = false
    self.tradingHouseCloseHooked = false
    self.tradingHouseListingsVisible = false
    self.listingRefreshArmed = false
    self.listingRefreshRunning = false
    self.listingRefreshCloseAfter = false
    self.listingRefreshRepeatPending = false
    self.listingRefreshQueue = {}
    self.listingRefreshIndex = 0
    self.listingRefreshToken = 0
    self.listingRefreshActiveGuildId = 0
    self.listingRefreshOriginalGuildId = 0
    self.listingRefreshAwaitingResponse = false
    self.listingRefreshResponseSucceeded = false
    self.listingRefreshActiveCaptured = false
    self.listedGuildIndex = 1
    self.listingStatusMessage = ""

    self:RestoreOrStartSession()
    self:RegisterSessionLifecycleHooks()
    self:RegisterTradingHouseListings()
    self:ApplyContentFrameAnchors()

    self.fragment = ZO_FadeSceneFragment:New(control)
    self.fragment:RegisterCallback("StateChange", function(_, newState)
        if newState == SCENE_FRAGMENT_SHOWING then
            self.salesPageIndex = SALES_PAGE_LEDGER
            self.ledgerSubpageIndex = LEDGER_SUBPAGE_SESSION
            self:ApplyContentFrameAnchors()
            if GSJ.settings.refreshMode == "AUTO" then
                GSJ:RefreshTraderHistory(true)
            end
            self:StartSessionTracking()
            if self.mainList then
                self:SetCurrentList(self.mainList)
                self:RefreshQ1List()
                self:ShowQ1Page(self.currentQ1Page)
                self:FocusQ1()
            end
        elseif newState == SCENE_FRAGMENT_HIDDEN then
            EVENT_MANAGER:UnregisterForUpdate("PFJ_SessionClock")
            EVENT_MANAGER:UnregisterForUpdate("PFJ_ListedCountdown")
            self:RemoveAllKeybinds()
            if self.historyList then self.historyList:Deactivate() end
            if self.listedList then self.listedList:Deactivate() end
        end
    end)

    self.scene = ZO_Scene:New(SCENE_NAME, SCENE_MANAGER)
    self.scene:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
    self.scene:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_GAMEPAD)
    self.scene:AddFragment(GAMEPAD_NAV_QUADRANT_1_BACKGROUND_FRAGMENT)
    if GAMEPAD_NAV_QUADRANT_2_3_4_BACKGROUND_FRAGMENT then
        self.scene:AddFragment(GAMEPAD_NAV_QUADRANT_2_3_4_BACKGROUND_FRAGMENT)
    elseif GAMEPAD_NAV_QUADRANT_2_3_BACKGROUND_FRAGMENT then
        self.scene:AddFragment(GAMEPAD_NAV_QUADRANT_2_3_BACKGROUND_FRAGMENT)
    end
    self.scene:AddFragment(GAMEPAD_GENERIC_FOOTER_FRAGMENT)
    self.scene:AddFragment(GAMEPAD_MENU_SOUND_FRAGMENT)
    self.scene:AddFragment(self.fragment)

    ZO_Gamepad_ParametricList_Screen.Initialize(
        self,
        control,
        ZO_GAMEPAD_HEADER_TABBAR_CREATE,
        true,
        self.scene
    )
    self:SetListsUseTriggerKeybinds(false)
end

function GuildSalesJournal_Gamepad:ApplyContentFrameAnchors()
    if not self.contentFrame or not GuiRoot then return end

    local width = GuiRoot:GetWidth() or 1920
    local height = GuiRoot:GetHeight() or 1080
    local left = tonumber(ZO_GAMEPAD_QUADRANT_2_LEFT_OFFSET) or 535
    local right = width + (tonumber(ZO_GAMEPAD_QUADRANT_4_RIGHT_OFFSET) or -40)

    self.contentFrame:ClearAnchors()
    self.contentFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left + 20, 135)
    self.contentFrame:SetAnchor(BOTTOMRIGHT, GuiRoot, TOPLEFT, right - 20, height - 110)

    local contentWidth = self.contentFrame:GetWidth() or 1300
    local contentHeight = self.contentFrame:GetHeight() or 760

    local function LayoutHeading(page)
        local title = page:GetNamedChild("Title")
        local subtitle = page:GetNamedChild("Subtitle")
        title:ClearAnchors()
        title:SetAnchor(TOPLEFT, page, TOPLEFT, 10, 0)
        title:SetDimensions(contentWidth - 20, 58)
        subtitle:ClearAnchors()
        subtitle:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 2, 0)
        subtitle:SetDimensions(contentWidth - 20, 36)
    end

    LayoutHeading(self.ledgerPage)
    local subpageLabel = self.ledgerPage:GetNamedChild("SubpageLabel")
    subpageLabel:ClearAnchors()
    subpageLabel:SetAnchor(TOPRIGHT, self.ledgerPage, TOPRIGHT, -12, 18)
    subpageLabel:SetDimensions(230, 36)

    local outer = self.ledgerPage:GetNamedChild("OuterCard")
    outer:ClearAnchors()
    outer:SetAnchor(TOPLEFT, self.ledgerPage, TOPLEFT, 10, 106)
    outer:SetDimensions(contentWidth - 20, contentHeight - 122)

    local balancesHeading = self.ledgerPage:GetNamedChild("BalancesHeading")
    balancesHeading:ClearAnchors()
    balancesHeading:SetAnchor(TOP, outer, TOP, 0, 8)
    balancesHeading:SetDimensions(contentWidth - 70, 36)

    local balancesCard = self.ledgerPage:GetNamedChild("BalancesCard")
    balancesCard:ClearAnchors()
    balancesCard:SetAnchor(TOPLEFT, outer, TOPLEFT, 30, 46)
    balancesCard:SetDimensions(contentWidth - 80, 108)

    local col = (contentWidth - 80) / 3
    local function placeTop(name, index, y, h)
        local control = self.ledgerPage:GetNamedChild(name)
        control:ClearAnchors()
        control:SetAnchor(TOPLEFT, balancesCard, TOPLEFT, (index - 1) * col, y)
        control:SetDimensions(col, h)
    end
    placeTop("BankLabel", 1, 5, 30)
    placeTop("CharacterLabel", 2, 5, 30)
    placeTop("TotalLabel", 3, 5, 30)
    placeTop("BankValue", 1, 34, 64)
    placeTop("CharacterValue", 2, 34, 64)
    placeTop("TotalValue", 3, 34, 64)

    local sessionHeading = self.ledgerPage:GetNamedChild("SessionHeading")
    sessionHeading:ClearAnchors()
    sessionHeading:SetAnchor(TOP, balancesCard, BOTTOM, 0, 10)
    sessionHeading:SetDimensions(contentWidth - 70, 36)

    local sessionCard = self.ledgerPage:GetNamedChild("SessionCard")
    sessionCard:ClearAnchors()
    sessionCard:SetAnchor(TOPLEFT, outer, TOPLEFT, 55, 200)
    sessionCard:SetDimensions(contentWidth - 130, 220)

    local sessionColumn = (contentWidth - 130) / 3
    local function placeSession(name, index, y, h)
        local control = self.ledgerPage:GetNamedChild(name)
        control:ClearAnchors()
        control:SetAnchor(TOPLEFT, sessionCard, TOPLEFT, (index - 1) * sessionColumn, y)
        control:SetDimensions(sessionColumn, h)
    end
    placeSession("EarnedHeader", 1, 8, 36)
    placeSession("SpentHeader", 2, 8, 36)
    placeSession("BalanceHeader", 3, 8, 36)
    for row = 1, 2 do
        local y = 52 + ((row - 1) * 72)
        placeSession("Row" .. row .. "Earned", 1, y, 62)
        placeSession("Row" .. row .. "Spent", 2, y, 62)
        placeSession("Row" .. row .. "Balance", 3, y, 62)
    end
    for row = 3, 6 do
        self.ledgerPage:GetNamedChild("Row" .. row .. "Earned"):SetHidden(true)
        self.ledgerPage:GetNamedChild("Row" .. row .. "Spent"):SetHidden(true)
        self.ledgerPage:GetNamedChild("Row" .. row .. "Balance"):SetHidden(true)
    end

    self.categoryView = self.ledgerPage:GetNamedChild("CategoryView")
    local categoryHeading = self.categoryView:GetNamedChild("Heading")
    categoryHeading:ClearAnchors()
    categoryHeading:SetAnchor(TOP, outer, TOP, 0, 16)
    categoryHeading:SetDimensions(contentWidth - 70, 40)

    local categoryCard = self.categoryView:GetNamedChild("Card")
    categoryCard:ClearAnchors()
    categoryCard:SetAnchor(TOP, outer, TOP, 0, 62)
    local categoryCardWidth = math.min(contentWidth - 150, 980)
    categoryCard:SetDimensions(categoryCardWidth, 472)

    local nameWidth = math.floor(categoryCardWidth * 0.50)
    local countWidth = math.floor(categoryCardWidth * 0.23)
    local totalWidth = categoryCardWidth - nameWidth - countWidth
    local function placeCategory(name, column, y, h)
        local control = self.categoryView:GetNamedChild(name)
        control:ClearAnchors()
        local x = 0
        local width = nameWidth
        if column == 2 then
            x = nameWidth
            width = countWidth
        elseif column == 3 then
            x = nameWidth + countWidth
            width = totalWidth
        end
        control:SetAnchor(TOPLEFT, categoryCard, TOPLEFT, x + (column == 1 and 18 or 0), y)
        control:SetDimensions(width - (column == 1 and 18 or 0), h)
    end
    placeCategory("CategoryHeader", 1, 8, 38)
    placeCategory("CountHeader", 2, 8, 38)
    placeCategory("TotalHeader", 3, 8, 38)
    for row = 1, 8 do
        local y = 52 + ((row - 1) * 50)
        placeCategory("Row" .. row .. "Name", 1, y, 48)
        placeCategory("Row" .. row .. "Count", 2, y, 48)
        placeCategory("Row" .. row .. "Total", 3, y, 48)
    end
    for row = 9, 12 do
        self.categoryView:GetNamedChild("Row" .. row .. "Name"):SetHidden(true)
        self.categoryView:GetNamedChild("Row" .. row .. "Count"):SetHidden(true)
        self.categoryView:GetNamedChild("Row" .. row .. "Total"):SetHidden(true)
    end

    local footer = self.ledgerPage:GetNamedChild("FooterCard")
    footer:ClearAnchors()
    footer:SetAnchor(BOTTOMLEFT, outer, BOTTOMLEFT, 30, -18)
    footer:SetDimensions(contentWidth - 80, 66)
    local sessionTime = self.ledgerPage:GetNamedChild("SessionTimeLabel")
    sessionTime:ClearAnchors()
    sessionTime:SetAnchor(LEFT, footer, LEFT, 22, 0)
    sessionTime:SetDimensions((contentWidth - 120) * 0.48, 50)
    local profitLoss = self.ledgerPage:GetNamedChild("ProfitLossLabel")
    profitLoss:ClearAnchors()
    profitLoss:SetAnchor(RIGHT, footer, RIGHT, -22, 0)
    profitLoss:SetDimensions((contentWidth - 120) * 0.48, 50)

    LayoutHeading(self.historyPage)
    local detailWidth = math.max(380, math.floor(contentWidth * 0.32))
    local gap = 22
    local historyWidth = contentWidth - detailWidth - gap - 20
    local historyControl = self.historyPage:GetNamedChild("HistoryControl")
    local detailCard = self.historyPage:GetNamedChild("DetailCard")
    local detailBody = self.historyPage:GetNamedChild("DetailBody")

    historyControl:ClearAnchors()
    historyControl:SetAnchor(TOPLEFT, self.historyPage, TOPLEFT, 10, 106)
    historyControl:SetDimensions(historyWidth, contentHeight - 116)
    detailCard:ClearAnchors()
    detailCard:SetAnchor(TOPLEFT, historyControl, TOPRIGHT, gap, 0)
    detailCard:SetDimensions(detailWidth, contentHeight - 116)
    detailBody:ClearAnchors()
    detailBody:SetAnchor(TOPLEFT, detailCard, TOPLEFT, 24, 24)
    detailBody:SetDimensions(detailWidth - 48, contentHeight - 164)

    LayoutHeading(self.listedPage)
    local listedHeader = self.listedPage:GetNamedChild("Header")
    local listedControl = self.listedPage:GetNamedChild("ListedControl")
    local listedDetailCard = self.listedPage:GetNamedChild("DetailCard")
    local listedDetailBody = self.listedPage:GetNamedChild("DetailBody")

    listedHeader:ClearAnchors()
    listedHeader:SetAnchor(TOPLEFT, self.listedPage, TOPLEFT, 10, 104)
    listedHeader:SetDimensions(contentWidth - 20, 64)

    listedControl:ClearAnchors()
    listedControl:SetAnchor(TOPLEFT, self.listedPage, TOPLEFT, 10, 178)
    listedControl:SetDimensions(historyWidth, contentHeight - 188)

    listedDetailCard:ClearAnchors()
    listedDetailCard:SetAnchor(TOPLEFT, listedControl, TOPRIGHT, gap, 0)
    listedDetailCard:SetDimensions(detailWidth, contentHeight - 188)

    listedDetailBody:ClearAnchors()
    listedDetailBody:SetAnchor(TOPLEFT, listedDetailCard, TOPLEFT, 24, 24)
    listedDetailBody:SetDimensions(detailWidth - 48, contentHeight - 236)
end

function GuildSalesJournal_Gamepad:OnDeferredInitialize()
    self.headerData = {
        titleText = "Personal Finance Journal",
        subtitleText = "Your gold, clearly accounted for",
        tabBarEntries = nil,
    }
    ZO_GamepadGenericHeader_Refresh(self.header, self.headerData, true)

    self.mainList = self:AddList("Pages", function(list)
        list:AddDataTemplate(
            "ZO_GamepadItemSubEntryTemplate",
            ZO_SharedGamepadEntry_OnSetup,
            ZO_GamepadMenuEntryTemplateParametricListFunction
        )
        list:SetNoItemText("No Personal Finance Journal pages available")
    end)

    self.mainList:SetOnTargetDataChangedCallback(function(_, targetData)
        if targetData and targetData.pfjPage then
            self:ShowQ1Page(targetData.pfjPage)
        end
    end)

    self.historyList = PFJ_HistoryList_Gamepad:New(
        self.historyPage:GetNamedChild("HistoryControl"),
        self
    )
    self.listedList = PFJ_ListedItemsList_Gamepad:New(
        self.listedPage:GetNamedChild("ListedControl"),
        self
    )

    self:InitializeKeybindDescriptors()
    self:RefreshQ1List()
    self:ShowQ1Page(Q1_SALES)
end

function GuildSalesJournal_Gamepad:RefreshQ1List()
    if not self.mainList then return end

    self.mainList:Clear()

    local sales = ZO_GamepadEntryData:New("Sales History", SALES_ICON)
    sales.pfjPage = Q1_SALES
    sales:SetIconTintOnSelection(true)
    self.mainList:AddEntry("ZO_GamepadItemSubEntryTemplate", sales)

    local listed = ZO_GamepadEntryData:New("Listed Items", LISTED_ICON)
    listed.pfjPage = Q1_LISTED
    listed:SetIconTintOnSelection(true)
    self.mainList:AddEntry("ZO_GamepadItemSubEntryTemplate", listed)

    self.mainList:Commit()
end

function GuildSalesJournal_Gamepad:GetGuildSources()
    return GSJ:GetGuildSources() or {}
end

function GuildSalesJournal_Gamepad:GetSalesPageCount()
    return math.min(SALES_PAGE_COUNT, #self:GetGuildSources() + 2)
end

function GuildSalesJournal_Gamepad:ChangeSalesPage(delta)
    if self.currentQ1Page ~= Q1_SALES then return end

    local pageCount = self:GetSalesPageCount()
    local index = self.salesPageIndex
    index = ((index + delta) % pageCount)
    self.salesPageIndex = index
    self:RefreshSalesPage()

    if self.q1Keybinds and KEYBIND_STRIP then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(self.q1Keybinds)
    end
    if self.historyKeybinds and KEYBIND_STRIP and self.focusInHistory then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(self.historyKeybinds)
    end
end

function GuildSalesJournal_Gamepad:SetLedgerSubpage(subpageIndex)
    if self.currentQ1Page ~= Q1_SALES or self.salesPageIndex ~= SALES_PAGE_LEDGER then return end
    self.ledgerSubpageIndex = subpageIndex or LEDGER_SUBPAGE_SESSION
    self:RefreshLedgerPage()
    if self.q1Keybinds and KEYBIND_STRIP then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(self.q1Keybinds)
    end
end

function GuildSalesJournal_Gamepad:ToggleLedgerSubpage(subpageIndex)
    if self.ledgerSubpageIndex == subpageIndex then
        self:SetLedgerSubpage(LEDGER_SUBPAGE_SESSION)
    else
        self:SetLedgerSubpage(subpageIndex)
    end
end

function GuildSalesJournal_Gamepad:GetScopeForPage(pageIndex)
    if pageIndex == SALES_PAGE_ALL then
        return nil, "All Guilds"
    end

    if pageIndex >= SALES_PAGE_FIRST_GUILD then
        local sourceIndex = pageIndex - 1
        local source = self:GetGuildSources()[sourceIndex]
        if source then
            return source.guildId, source.name
        end
    end

    return nil, "Ledger"
end

function GuildSalesJournal_Gamepad:ShowQ1Page(page)
    self.currentQ1Page = page or Q1_SALES
    self.ledgerPage:SetHidden(true)
    self.historyPage:SetHidden(true)
    self.listedPage:SetHidden(true)

    EVENT_MANAGER:UnregisterForUpdate("PFJ_ListedCountdown")
    if self.currentQ1Page == Q1_LISTED then
        self:RefreshListedPage()
        EVENT_MANAGER:RegisterForUpdate("PFJ_ListedCountdown", 30000, function()
            if self.currentQ1Page == Q1_LISTED and self.listedPage and not self.listedPage:IsHidden() then
                self:RefreshListedCountdowns()
            end
        end)
    else
        self:RefreshSalesPage()
    end
    self:RefreshQ1KeybindGroup()
end

function GuildSalesJournal_Gamepad:RefreshSalesPage()
    if self.salesPageIndex == SALES_PAGE_LEDGER then
        self.historyPage:SetHidden(true)
        self.listedPage:SetHidden(true)
        self.ledgerPage:SetHidden(false)
        self:RefreshLedgerPage()
    else
        self.ledgerPage:SetHidden(true)
        self.listedPage:SetHidden(true)
        self.historyPage:SetHidden(false)
        self:RefreshHistoryPage()
    end
end

function GuildSalesJournal_Gamepad:GetGoldBalances()
    local character = 0
    local bank = 0
    if GetCurrencyAmount and CURT_MONEY then
        if CURRENCY_LOCATION_CHARACTER then
            character = tonumber(GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER)) or 0
        end
        if CURRENCY_LOCATION_BANK then
            bank = tonumber(GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_BANK)) or 0
        end
    end
    return bank, character, bank + character
end

function GuildSalesJournal_Gamepad:GetCurrentCharacterKey()
    local characterId = GetCurrentCharacterId and GetCurrentCharacterId()
    if characterId and tostring(characterId) ~= "0" then
        return tostring(characterId)
    end
    return tostring((GetUnitName and GetUnitName("player")) or "")
end

function GuildSalesJournal_Gamepad:SyncActiveSession()
    local session = self.activeFinanceSession
    if not session then return end
    if session.active == nil then session.active = true end
    session.characterKey = self:GetCurrentCharacterKey()
    session.characterName = (GetUnitName and GetUnitName("player")) or session.characterName or ""
    session.startedAt = tonumber(self.sessionStartedAt) or (GetTimeStamp and GetTimeStamp() or 0)
    session.openingTotal = tonumber(self.sessionStartTotal) or 0
    session.lastKnownTotal = tonumber(self.lastKnownTotal) or session.openingTotal
    session.transactions = self.sessionTransactions or {}
end

function GuildSalesJournal_Gamepad:StartNewPersistedSession(total)
    total = tonumber(total) or select(3, self:GetGoldBalances())
    local now = GetTimeStamp and GetTimeStamp() or 0
    local baselineConfirmed = not IsPlayerActivated or IsPlayerActivated()
    local session = {
        active = true,
        baselineConfirmed = baselineConfirmed,
        characterKey = self:GetCurrentCharacterKey(),
        characterName = (GetUnitName and GetUnitName("player")) or "",
        startedAt = now,
        openingTotal = total,
        lastKnownTotal = total,
        transactions = {},
        logoutRequested = false,
        logoutRequestedAt = 0,
        logoutType = nil,
        completed = false,
        endedAt = 0,
    }
    GSJ.finance.activeSession = session
    self.activeFinanceSession = session
    self.sessionStartedAt = now
    self.sessionStartTotal = total
    self.lastKnownTotal = total
    self.sessionTransactions = session.transactions
end

function GuildSalesJournal_Gamepad:RestoreOrStartSession()
    local _, _, total = self:GetGoldBalances()
    local stored = GSJ.finance and GSJ.finance.activeSession or nil
    local characterKey = self:GetCurrentCharacterKey()
    local canResume = type(stored) == "table"
        and stored.active == true
        and stored.characterKey == characterKey
        and not stored.logoutRequested
        and not stored.completed

    if not canResume then
        self:StartNewPersistedSession(total)
        return
    end

    stored.transactions = type(stored.transactions) == "table" and stored.transactions or {}
    if stored.baselineConfirmed == nil then stored.baselineConfirmed = true end
    self.activeFinanceSession = stored
    self.sessionStartedAt = tonumber(stored.startedAt) or (GetTimeStamp and GetTimeStamp() or 0)
    self.sessionStartTotal = tonumber(stored.openingTotal) or total
    self.lastKnownTotal = tonumber(stored.lastKnownTotal) or total
    self.sessionTransactions = stored.transactions
    self:SyncActiveSession()
end

function GuildSalesJournal_Gamepad:ReconcilePersistedSessionTotal(total)
    total = tonumber(total) or select(3, self:GetGoldBalances())
    if self.lastKnownTotal == nil then
        self.lastKnownTotal = total
        self.sessionStartTotal = self.sessionStartTotal or total
        self:SyncActiveSession()
        return
    end

    local delta = total - self.lastKnownTotal
    if delta ~= 0 then
        local direction = delta > 0 and "income" or "expense"
        local category = delta > 0 and "otherIncome" or "otherExpenses"
        table.insert(self.sessionTransactions, 1, {
            delta = delta,
            balance = total,
            timestamp = GetTimeStamp and GetTimeStamp() or 0,
            direction = direction,
            category = category,
            subcategory = nil,
            label = "Session balance adjustment",
            reason = nil,
            supplementaryInfo = nil,
        })
        while #self.sessionTransactions > SESSION_TRANSACTION_LIMIT do
            table.remove(self.sessionTransactions)
        end
    end
    self.lastKnownTotal = total
    self:SyncActiveSession()
end

function GuildSalesJournal_Gamepad:MarkIntentionalSessionEnd(logoutType)
    local session = self.activeFinanceSession
    if not session then return end
    session.logoutRequested = true
    session.logoutRequestedAt = GetTimeStamp and GetTimeStamp() or 0
    session.logoutType = logoutType or "logout"
    self:SyncActiveSession()
end

function GuildSalesJournal_Gamepad:ClearIntentionalSessionEnd()
    local session = self.activeFinanceSession
    if not session or session.completed then return end
    session.logoutRequested = false
    session.logoutRequestedAt = 0
    session.logoutType = nil
    self:SyncActiveSession()
end

function GuildSalesJournal_Gamepad:CompleteIntentionalSessionEnd()
    local session = self.activeFinanceSession
    if not session or not session.logoutRequested then return end
    session.completed = true
    session.active = false
    session.endedAt = GetTimeStamp and GetTimeStamp() or 0
    self:SyncActiveSession()
end

function GuildSalesJournal_Gamepad:HandlePlayerActivated()
    local characterKey = self:GetCurrentCharacterKey()
    local session = self.activeFinanceSession
    local _, _, total = self:GetGoldBalances()
    if not session
        or session.characterKey ~= characterKey
        or session.logoutRequested
        or session.completed then
        self:StartNewPersistedSession(total)
    elseif session.baselineConfirmed == false then
        local now = GetTimeStamp and GetTimeStamp() or 0
        session.baselineConfirmed = true
        self.sessionStartedAt = now
        self.sessionStartTotal = total
        self.lastKnownTotal = total
        self.sessionTransactions = {}
        session.transactions = self.sessionTransactions
        self:SyncActiveSession()
    else
        self:ReconcilePersistedSessionTotal(total)
    end
end

function GuildSalesJournal_Gamepad:RegisterSessionLifecycleHooks()
    if self.sessionLifecycleHooksRegistered then return end
    self.sessionLifecycleHooksRegistered = true

    if SecurePostHook then
        pcall(SecurePostHook, "Logout", function()
            self:MarkIntentionalSessionEnd("logout")
        end)
        pcall(SecurePostHook, "Quit", function()
            self:MarkIntentionalSessionEnd("quit")
        end)
        pcall(SecurePostHook, "CancelLogout", function()
            self:ClearIntentionalSessionEnd()
        end)
    end

    if EVENT_LOGOUT_DISALLOWED then
        EVENT_MANAGER:UnregisterForEvent("PFJ_LogoutDisallowed", EVENT_LOGOUT_DISALLOWED)
        EVENT_MANAGER:RegisterForEvent("PFJ_LogoutDisallowed", EVENT_LOGOUT_DISALLOWED, function()
            self:ClearIntentionalSessionEnd()
        end)
    end

    if EVENT_LOGOUT_SUCCESSFUL then
        EVENT_MANAGER:UnregisterForEvent("PFJ_LogoutSuccessful", EVENT_LOGOUT_SUCCESSFUL)
        EVENT_MANAGER:RegisterForEvent("PFJ_LogoutSuccessful", EVENT_LOGOUT_SUCCESSFUL, function()
            self:CompleteIntentionalSessionEnd()
        end)
    end

    EVENT_MANAGER:UnregisterForEvent("PFJ_PlayerActivated", EVENT_PLAYER_ACTIVATED)
    EVENT_MANAGER:RegisterForEvent("PFJ_PlayerActivated", EVENT_PLAYER_ACTIVATED, function()
        zo_callLater(function()
            self:HandlePlayerActivated()
            self:StartSessionTracking()
        end, 500)
    end)
end

function GuildSalesJournal_Gamepad:TryApplyPurchaseContext(context)
    if not context then return false end
    local now = GetTimeStamp and GetTimeStamp() or 0
    for index = 1, math.min(3, #self.sessionTransactions) do
        local transaction = self.sessionTransactions[index]
        local age = math.max(0, now - (tonumber(transaction.timestamp) or now))
        local amountMatches = context.amount == 0 or math.abs(math.abs(transaction.delta) - context.amount) <= 1
        if age <= 3 and transaction.delta < 0 and transaction.category == "otherExpenses" and amountMatches then
            if context.subcategory then
                transaction.category = context.source == "guildStore" and "guildStorePurchases" or "merchantPurchases"
                transaction.subcategory = context.subcategory
            end
            transaction.label = context.itemName or transaction.label
            self:SyncActiveSession()
            if self.salesPageIndex == SALES_PAGE_LEDGER and self.currentQ1Page == Q1_SALES then
                self:RefreshLedgerPage()
            end
            return true
        end
    end
    return false
end

function GuildSalesJournal_Gamepad:SetPurchaseContext(source, itemName, itemLink, amount, entryType, soundCategory)
    local context = {
        source = source,
        itemName = itemName,
        itemLink = itemLink,
        amount = math.abs(tonumber(amount) or 0),
        subcategory = ClassifyPurchaseItem(itemLink, itemName, entryType, soundCategory),
        expiresAt = NowMilliseconds() + 1800,
    }
    if not self:TryApplyPurchaseContext(context) then
        self.pendingPurchaseContext = context
    end
end

function GuildSalesJournal_Gamepad:SetGuildSaleContext(subject, attachedMoney)
    local amount = math.abs(tonumber(attachedMoney) or 0)
    local now = GetTimeStamp and GetTimeStamp() or 0
    for index = 1, math.min(3, #self.sessionTransactions) do
        local transaction = self.sessionTransactions[index]
        local age = math.max(0, now - (tonumber(transaction.timestamp) or now))
        local amountMatches = amount == 0 or math.abs(math.abs(transaction.delta) - amount) <= 1
        if age <= 3 and transaction.delta > 0 and transaction.category == "otherIncome" and amountMatches then
            transaction.category = "guildSales"
            transaction.label = subject or "Guild sale"
            self:SyncActiveSession()
            if self.salesPageIndex == SALES_PAGE_LEDGER and self.currentQ1Page == Q1_SALES then
                self:RefreshLedgerPage()
            end
            return
        end
    end
    self.pendingIncomeContext = {
        category = "guildSales",
        label = subject,
        amount = amount,
        expiresAt = NowMilliseconds() + 1800,
    }
end

function GuildSalesJournal_Gamepad:SetLootIncomeContext(itemName, amount, isPickpocketLoot, isStolen)
    local context = {
        itemName = itemName,
        amount = math.abs(tonumber(amount) or 0),
        isPickpocketLoot = isPickpocketLoot == true,
        isStolen = isStolen == true,
        expiresAt = NowMilliseconds() + 2200,
    }

    local now = GetTimeStamp and GetTimeStamp() or 0
    for index = 1, math.min(3, #self.sessionTransactions) do
        local transaction = self.sessionTransactions[index]
        local age = math.max(0, now - (tonumber(transaction.timestamp) or now))
        local amountMatches = context.amount == 0 or math.abs(math.abs(transaction.delta) - context.amount) <= 1
        if age <= 3 and transaction.delta > 0 and transaction.category == "otherIncome" and amountMatches then
            transaction.category = "lootedGold"
            transaction.label = context.itemName or "Looted gold"
            self:SyncActiveSession()
            if self.salesPageIndex == SALES_PAGE_LEDGER and self.currentQ1Page == Q1_SALES then
                self:RefreshLedgerPage()
            end
            return
        end
    end

    self.pendingLootContext = context
end

function GuildSalesJournal_Gamepad:RegisterTransactionContextEvents()
    if EVENT_BUY_RECEIPT then
        EVENT_MANAGER:UnregisterForEvent("PFJ_BuyReceipt", EVENT_BUY_RECEIPT)
        EVENT_MANAGER:RegisterForEvent("PFJ_BuyReceipt", EVENT_BUY_RECEIPT,
            function(_, entryName, entryType, entryQuantity, money,
                    specialCurrencyType1, specialCurrencyInfo1, specialCurrencyQuantity1,
                    specialCurrencyType2, specialCurrencyInfo2, specialCurrencyQuantity2,
                    itemSoundCategory)
                local itemLink
                if GetNumStoreItems and GetStoreEntryInfo and GetStoreItemLink then
                    local targetQuantity = math.max(1, tonumber(entryQuantity) or 1)
                    local targetMoney = math.abs(tonumber(money) or 0)
                    for storeIndex = 1, GetNumStoreItems() do
                        local icon, storeName, stack, price = GetStoreEntryInfo(storeIndex)
                        local expectedTotal = (tonumber(price) or 0) * targetQuantity
                        if storeName == entryName and (targetMoney == 0 or expectedTotal == targetMoney or price == targetMoney) then
                            itemLink = GetStoreItemLink(storeIndex, LINK_STYLE_DEFAULT or 0)
                            break
                        end
                    end
                end
                self:SetPurchaseContext("merchant", entryName, itemLink, money, entryType, itemSoundCategory)
            end)
    end

    if EVENT_TRADING_HOUSE_CONFIRM_ITEM_PURCHASE then
        EVENT_MANAGER:UnregisterForEvent("PFJ_TradingPurchase", EVENT_TRADING_HOUSE_CONFIRM_ITEM_PURCHASE)
        EVENT_MANAGER:RegisterForEvent("PFJ_TradingPurchase", EVENT_TRADING_HOUSE_CONFIRM_ITEM_PURCHASE,
            function(_, pendingPurchaseIndex)
                local itemName, purchasePrice, itemLink
                if pendingPurchaseIndex and GetTradingHouseSearchResultItemInfo then
                    local ok, icon, name, displayQuality, stackCount, sellerName, timeRemaining, price =
                        pcall(GetTradingHouseSearchResultItemInfo, pendingPurchaseIndex)
                    if ok then
                        itemName = name
                        purchasePrice = price
                    end
                end
                if pendingPurchaseIndex and GetTradingHouseSearchResultItemLink then
                    local ok, link = pcall(GetTradingHouseSearchResultItemLink, pendingPurchaseIndex, LINK_STYLE_DEFAULT or 0)
                    if ok then itemLink = link end
                end
                self:SetPurchaseContext("guildStore", itemName, itemLink, purchasePrice, nil, nil)
            end)
    end

    if EVENT_MAIL_TAKE_ATTACHED_MONEY_SUCCESS then
        EVENT_MANAGER:UnregisterForEvent("PFJ_MailMoney", EVENT_MAIL_TAKE_ATTACHED_MONEY_SUCCESS)
        EVENT_MANAGER:RegisterForEvent("PFJ_MailMoney", EVENT_MAIL_TAKE_ATTACHED_MONEY_SUCCESS,
            function(_, mailId)
                if not GetMailItemInfo then return end
                local senderDisplayName, senderCharacterName, subject, icon, unread, fromSystem,
                    fromCustomerService, returned, numAttachments, attachedMoney, codAmount,
                    expiresInDays, secsSinceReceived, category = GetMailItemInfo(mailId)
                if fromSystem and ContainsAny(subject, "sold", "sale", "guild store") then
                    self:SetGuildSaleContext(subject, attachedMoney)
                end
            end)
    end

    if EVENT_LOOT_RECEIVED then
        EVENT_MANAGER:UnregisterForEvent("PFJ_LootReceived", EVENT_LOOT_RECEIVED)
        EVENT_MANAGER:RegisterForEvent("PFJ_LootReceived", EVENT_LOOT_RECEIVED,
            function(_, receivedBy, itemName, quantity, soundCategory, lootType,
                    isSelf, isPickpocketLoot, questItemIcon, itemId, isStolen)
                if not isSelf or lootType ~= LOOT_TYPE_CURRENCY then return end
                local moneyName = GetCurrencyName and GetCurrencyName(CURT_MONEY, tonumber(quantity) == 1, false)
                if moneyName and moneyName ~= "" and not ContainsAny(itemName, moneyName) then return end
                self:SetLootIncomeContext(itemName, quantity, isPickpocketLoot, isStolen)
            end)
    end
end

function GuildSalesJournal_Gamepad:StartSessionTracking()
    local _, _, total = self:GetGoldBalances()
    self:ReconcilePersistedSessionTotal(total)

    self:RegisterTransactionContextEvents()

    EVENT_MANAGER:UnregisterForEvent("PFJ_Currency", EVENT_CURRENCY_UPDATE)
    EVENT_MANAGER:RegisterForEvent("PFJ_Currency", EVENT_CURRENCY_UPDATE,
        function(_, currencyType, currencyLocation, newAmount, oldAmount, reason, supplementaryInfo)
            if currencyType ~= CURT_MONEY then return end
            self.pendingCurrencyEvents[#self.pendingCurrencyEvents + 1] = {
                location = currencyLocation,
                newAmount = tonumber(newAmount) or 0,
                oldAmount = tonumber(oldAmount) or 0,
                reason = reason,
                supplementaryInfo = supplementaryInfo,
            }
            self.currencyRefreshToken = self.currencyRefreshToken + 1
            local token = self.currencyRefreshToken
            zo_callLater(function()
                if token ~= self.currencyRefreshToken then return end
                self:CaptureCurrencyChange()
            end, 250)
        end)

    EVENT_MANAGER:UnregisterForUpdate("PFJ_SessionClock")
    EVENT_MANAGER:RegisterForUpdate("PFJ_SessionClock", 1000, function()
        if self.salesPageIndex == SALES_PAGE_LEDGER and self.currentQ1Page == Q1_SALES then
            self:RefreshLedgerPage()
        end
    end)
end

function GuildSalesJournal_Gamepad:SelectCurrencyReason(events)
    local selectedReason
    local selectedSupplementaryInfo
    for index = #events, 1, -1 do
        local event = events[index]
        local reason = event.reason
        if not IsAny(reason,
                CURRENCY_CHANGE_REASON_BANK_DEPOSIT,
                CURRENCY_CHANGE_REASON_BANK_WITHDRAWAL,
                CURRENCY_CHANGE_REASON_GUILD_BANK_DEPOSIT,
                CURRENCY_CHANGE_REASON_GUILD_BANK_WITHDRAWAL,
                CURRENCY_CHANGE_REASON_PLAYER_INIT) then
            return reason, event.supplementaryInfo
        end
        selectedReason = selectedReason or reason
        selectedSupplementaryInfo = selectedSupplementaryInfo or event.supplementaryInfo
    end
    return selectedReason, selectedSupplementaryInfo
end

function GuildSalesJournal_Gamepad:ConsumePurchaseContext(source, delta)
    local context = self.pendingPurchaseContext
    if not context then return nil end
    if context.expiresAt < NowMilliseconds() then
        self.pendingPurchaseContext = nil
        return nil
    end
    if source and context.source ~= source then return nil end
    if context.amount > 0 and math.abs(math.abs(delta) - context.amount) > 1 then
        return nil
    end
    self.pendingPurchaseContext = nil
    return context
end

function GuildSalesJournal_Gamepad:ConsumeIncomeContext(delta)
    local context = self.pendingIncomeContext
    if not context then return nil end
    if context.expiresAt < NowMilliseconds() then
        self.pendingIncomeContext = nil
        return nil
    end
    if context.amount > 0 and math.abs(math.abs(delta) - context.amount) > 1 then
        return nil
    end
    self.pendingIncomeContext = nil
    return context
end

function GuildSalesJournal_Gamepad:ConsumeLootContext(delta)
    local context = self.pendingLootContext
    if not context then return nil end
    if context.expiresAt < NowMilliseconds() then
        self.pendingLootContext = nil
        return nil
    end
    if context.amount > 0 and math.abs(math.abs(delta) - context.amount) > 1 then
        return nil
    end
    self.pendingLootContext = nil
    return context
end

function GuildSalesJournal_Gamepad:ClassifyCurrencyTransaction(delta, reason)
    if delta > 0 then
        local incomeContext = self:ConsumeIncomeContext(delta)
        if incomeContext then
            self.pendingLootContext = nil
            return "income", incomeContext.category, nil, incomeContext.label or "Guild sale"
        end

        if reason == CURRENCY_CHANGE_REASON_QUESTREWARD then
            self.pendingLootContext = nil
            return "income", "questRewards", nil, "Quest reward"
        elseif IsAny(reason,
                CURRENCY_CHANGE_REASON_LOOT,
                CURRENCY_CHANGE_REASON_LOOT_CURRENCY_CONTAINER,
                CURRENCY_CHANGE_REASON_LOOT_STOLEN,
                CURRENCY_CHANGE_REASON_PICKPOCKET) then
            self.pendingLootContext = nil
            return "income", "lootedGold", nil, "Looted gold"
        elseif IsAny(reason,
                CURRENCY_CHANGE_REASON_KILL,
                CURRENCY_CHANGE_REASON_PVP_KILL_TRANSFER,
                CURRENCY_CHANGE_REASON_BATTLEGROUND,
                CURRENCY_CHANGE_REASON_MEDAL,
                CURRENCY_CHANGE_REASON_OFFENSIVE_KEEP_REWARD,
                CURRENCY_CHANGE_REASON_DEFENSIVE_KEEP_REWARD) then
            self.pendingLootContext = nil
            return "income", "combatIncome", nil, "Combat income"
        elseif reason == CURRENCY_CHANGE_REASON_SELL_STOLEN then
            self.pendingLootContext = nil
            return "income", "fencing", nil, "Fence income"
        elseif reason == CURRENCY_CHANGE_REASON_VENDOR then
            self.pendingLootContext = nil
            return "income", "merchantSales", nil, "Merchant sale"
        end

        local lootContext = self:ConsumeLootContext(delta)
        if lootContext then
            return "income", "lootedGold", nil, lootContext.itemName or "Looted gold"
        end

        return "income", "otherIncome", nil, "Other income"
    end

    self.pendingLootContext = nil
    if IsAny(reason,
            CURRENCY_CHANGE_REASON_BAGSPACE,
            CURRENCY_CHANGE_REASON_BANKSPACE,
            CURRENCY_CHANGE_REASON_CHARACTER_UPGRADE,
            CURRENCY_CHANGE_REASON_FEED_MOUNT,
            CURRENCY_CHANGE_REASON_STABLESPACE) then
        return "expense", "merchantPurchases", "characterUpgrades", "Character upgrade"
    elseif reason == CURRENCY_CHANGE_REASON_VENDOR then
        local context = self:ConsumePurchaseContext("merchant", delta)
        if context and context.subcategory then
            return "expense", "merchantPurchases", context.subcategory, context.itemName or "Merchant purchase"
        end
        return "expense", "otherExpenses", nil, context and context.itemName or "Merchant purchase"
    elseif reason == CURRENCY_CHANGE_REASON_TRADINGHOUSE_PURCHASE then
        local context = self:ConsumePurchaseContext("guildStore", delta)
        if context and context.subcategory then
            return "expense", "guildStorePurchases", context.subcategory, context.itemName or "Guild store purchase"
        end
        return "expense", "otherExpenses", nil, context and context.itemName or "Guild store purchase"
    elseif IsAny(reason, CURRENCY_CHANGE_REASON_VENDOR_REPAIR, CURRENCY_CHANGE_REASON_KEEP_REPAIR) then
        return "expense", "repairs", nil, "Repairs"
    elseif IsAny(reason,
            CURRENCY_CHANGE_REASON_BOUNTY_CONFISCATED,
            CURRENCY_CHANGE_REASON_BOUNTY_PAID_FENCE,
            CURRENCY_CHANGE_REASON_BOUNTY_PAID_GUARD) then
        return "expense", "finesBounties", nil, "Fine or bounty"
    elseif reason == CURRENCY_CHANGE_REASON_TRAVEL_GRAVEYARD then
        return "expense", "wayshrineFees", nil, "Wayshrine fee"
    else
        return "expense", "otherExpenses", nil, "Other expense"
    end
end

function GuildSalesJournal_Gamepad:CaptureCurrencyChange()
    local _, _, total = self:GetGoldBalances()
    local events = self.pendingCurrencyEvents
    self.pendingCurrencyEvents = {}

    if self.lastKnownTotal == nil then
        self.lastKnownTotal = total
        self.sessionStartTotal = total
        return
    end

    local delta = total - self.lastKnownTotal
    if delta == 0 then return end

    local reason, supplementaryInfo = self:SelectCurrencyReason(events)
    local direction, category, subcategory, label = self:ClassifyCurrencyTransaction(delta, reason)
    table.insert(self.sessionTransactions, 1, {
        delta = delta,
        balance = total,
        timestamp = GetTimeStamp and GetTimeStamp() or 0,
        direction = direction,
        category = category,
        subcategory = subcategory,
        label = label,
        reason = reason,
        supplementaryInfo = supplementaryInfo,
    })
    while #self.sessionTransactions > SESSION_TRANSACTION_LIMIT do
        table.remove(self.sessionTransactions)
    end
    self.lastKnownTotal = total
    self:SyncActiveSession()

    if self.salesPageIndex == SALES_PAGE_LEDGER and self.currentQ1Page == Q1_SALES then
        self:RefreshLedgerPage()
    end
end

function GuildSalesJournal_Gamepad:FormatSessionTime()
    local now = GetTimeStamp and GetTimeStamp() or self.sessionStartedAt
    local seconds = math.max(0, now - (self.sessionStartedAt or now))
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60
    return string.format("%02d:%02d:%02d", hours, minutes, secs)
end

function GuildSalesJournal_Gamepad:SetSessionSummaryRow(rowNumber, direction, amount, balanceValue)
    local earned = self.ledgerPage:GetNamedChild("Row" .. rowNumber .. "Earned")
    local spent = self.ledgerPage:GetNamedChild("Row" .. rowNumber .. "Spent")
    local balance = self.ledgerPage:GetNamedChild("Row" .. rowNumber .. "Balance")
    local coin = " |t26:26:EsoUI/Art/Currency/currency_gold.dds|t"
    amount = math.max(0, math.floor(tonumber(amount) or 0))
    balanceValue = math.floor(tonumber(balanceValue) or 0)

    earned:SetHidden(false)
    spent:SetHidden(false)
    balance:SetHidden(false)
    earned:SetText("")
    spent:SetText("")

    if direction == "expense" then
        if amount > 0 then
            spent:SetText("|cC56B6B-" .. FormatNumber(amount) .. "|r" .. coin)
            balance:SetText("|cC56B6B" .. FormatNumber(balanceValue) .. " ↓|r" .. coin)
        else
            spent:SetText("|cB8B8B80|r")
            balance:SetText("")
        end
    else
        if amount > 0 then
            earned:SetText("|c78D878+" .. FormatNumber(amount) .. "|r" .. coin)
            balance:SetText("|c78D878" .. FormatNumber(balanceValue) .. " ↑|r" .. coin)
        else
            earned:SetText("|cB8B8B80|r")
            balance:SetText("")
        end
    end
end

function GuildSalesJournal_Gamepad:SetLedgerControlsHidden(hidden)
    local controls = {
        "BalancesHeading", "BalancesCard", "BankLabel", "CharacterLabel", "TotalLabel",
        "BankValue", "CharacterValue", "TotalValue", "SessionHeading", "SessionCard",
        "EarnedHeader", "SpentHeader", "BalanceHeader",
    }
    for row = 1, 6 do
        controls[#controls + 1] = "Row" .. row .. "Earned"
        controls[#controls + 1] = "Row" .. row .. "Spent"
        controls[#controls + 1] = "Row" .. row .. "Balance"
    end
    for _, name in ipairs(controls) do
        self.ledgerPage:GetNamedChild(name):SetHidden(hidden)
    end
end

function GuildSalesJournal_Gamepad:GetCategorySummary()
    local summary = {
        guildSales = { count = 0, total = 0 },
        merchantSales = { count = 0, total = 0 },
        questRewards = { count = 0, total = 0 },
        lootedGold = { count = 0, total = 0 },
        combatIncome = { count = 0, total = 0 },
        fencing = { count = 0, total = 0 },
        otherIncome = { count = 0, total = 0 },
        merchantPurchases = { count = 0, total = 0 },
        merchantCharacterUpgrades = { count = 0, total = 0 },
        merchantHomeImprovements = { count = 0, total = 0 },
        merchantConsumables = { count = 0, total = 0 },
        guildStorePurchases = { count = 0, total = 0 },
        guildCharacterUpgrades = { count = 0, total = 0 },
        guildHomeImprovements = { count = 0, total = 0 },
        guildConsumables = { count = 0, total = 0 },
        repairs = { count = 0, total = 0 },
        finesBounties = { count = 0, total = 0 },
        wayshrineFees = { count = 0, total = 0 },
        otherExpenses = { count = 0, total = 0 },
    }

    local totalIncome = 0
    local totalExpenses = 0
    for _, transaction in ipairs(self.sessionTransactions) do
        local amount = math.abs(tonumber(transaction.delta) or 0)
        if transaction.direction == "income" then
            totalIncome = totalIncome + amount
            local bucket = summary[transaction.category] or summary.otherIncome
            bucket.count = bucket.count + 1
            bucket.total = bucket.total + amount
        else
            totalExpenses = totalExpenses + amount
            if transaction.category == "merchantPurchases" then
                summary.merchantPurchases.count = summary.merchantPurchases.count + 1
                summary.merchantPurchases.total = summary.merchantPurchases.total + amount
                local childKey = transaction.subcategory == "characterUpgrades" and "merchantCharacterUpgrades"
                    or transaction.subcategory == "homeImprovements" and "merchantHomeImprovements"
                    or transaction.subcategory == "consumables" and "merchantConsumables"
                if childKey then
                    summary[childKey].count = summary[childKey].count + 1
                    summary[childKey].total = summary[childKey].total + amount
                end
            elseif transaction.category == "guildStorePurchases" then
                summary.guildStorePurchases.count = summary.guildStorePurchases.count + 1
                summary.guildStorePurchases.total = summary.guildStorePurchases.total + amount
                local childKey = transaction.subcategory == "characterUpgrades" and "guildCharacterUpgrades"
                    or transaction.subcategory == "homeImprovements" and "guildHomeImprovements"
                    or transaction.subcategory == "consumables" and "guildConsumables"
                if childKey then
                    summary[childKey].count = summary[childKey].count + 1
                    summary[childKey].total = summary[childKey].total + amount
                end
            else
                local bucket = summary[transaction.category] or summary.otherExpenses
                bucket.count = bucket.count + 1
                bucket.total = bucket.total + amount
            end
        end
    end

    return summary, totalIncome, totalExpenses
end

function GuildSalesJournal_Gamepad:SetCategoryRow(rowNumber, name, bucket, isParent)
    local nameControl = self.categoryView:GetNamedChild("Row" .. rowNumber .. "Name")
    local countControl = self.categoryView:GetNamedChild("Row" .. rowNumber .. "Count")
    local totalControl = self.categoryView:GetNamedChild("Row" .. rowNumber .. "Total")
    if not name then
        nameControl:SetText("")
        countControl:SetText("")
        totalControl:SetText("")
        return
    end
    local colour = isParent and "|cFFFFFF" or "|cD0D0D0"
    nameControl:SetText(colour .. name .. "|r")
    countControl:SetText(FormatNumber(bucket.count))
    if (tonumber(bucket.total) or 0) > 0 then
        totalControl:SetText(FormatNumber(bucket.total) .. " |t20:20:EsoUI/Art/Currency/currency_gold.dds|t")
    else
        totalControl:SetText("-")
    end
end

function GuildSalesJournal_Gamepad:RefreshCategoryPage(subpageIndex)
    local summary, totalIncome, totalExpenses = self:GetCategorySummary()
    self:SetLedgerControlsHidden(true)
    self.categoryView:SetHidden(false)

    local rows = {}
    local footerText = ""
    if subpageIndex == LEDGER_SUBPAGE_INCOME then
        self.ledgerPage:GetNamedChild("Title"):SetText("Income")
        self.ledgerPage:GetNamedChild("Subtitle"):SetText("Gold received during the current session")
        self.ledgerPage:GetNamedChild("SubpageLabel"):SetText("PAGE 0.0")
        self.categoryView:GetNamedChild("Heading"):SetText("INCOME BY CATEGORY")
        rows = {
            { "Guild Sales", summary.guildSales, true },
            { "Merchant Sales", summary.merchantSales, true },
            { "Quest Rewards", summary.questRewards, true },
            { "Looted Gold", summary.lootedGold, true },
            { "Combat Income", summary.combatIncome, true },
            { "Fencing", summary.fencing, true },
            { "Other Income", summary.otherIncome, true },
        }
        footerText = "TOTAL INCOME  |c78D878+" .. FormatNumber(totalIncome) .. "|r |t28:28:EsoUI/Art/Currency/currency_gold.dds|t"
    elseif subpageIndex == LEDGER_SUBPAGE_PURCHASES then
        self.ledgerPage:GetNamedChild("Title"):SetText("Purchases")
        self.ledgerPage:GetNamedChild("Subtitle"):SetText("Gold exchanged for goods, upgrades and consumables")
        self.ledgerPage:GetNamedChild("SubpageLabel"):SetText("PAGE 0.2")
        self.categoryView:GetNamedChild("Heading"):SetText("PURCHASES BY SOURCE AND PURPOSE")
        rows = {
            { "Merchant Purchases", summary.merchantPurchases, true },
            { "   Character Upgrades", summary.merchantCharacterUpgrades, false },
            { "   Home Improvements", summary.merchantHomeImprovements, false },
            { "   Consumables", summary.merchantConsumables, false },
            { "Guild Store Purchases", summary.guildStorePurchases, true },
            { "   Character Upgrades", summary.guildCharacterUpgrades, false },
            { "   Home Improvements", summary.guildHomeImprovements, false },
            { "   Consumables", summary.guildConsumables, false },
        }
        local totalPurchases = summary.merchantPurchases.total + summary.guildStorePurchases.total
        footerText = "TOTAL PURCHASES  |cC56B6B" .. (totalPurchases > 0 and "-" or "") .. FormatNumber(totalPurchases) .. "|r"
        if totalPurchases > 0 then
            footerText = footerText .. " |t28:28:EsoUI/Art/Currency/currency_gold.dds|t"
        end
    else
        self.ledgerPage:GetNamedChild("Title"):SetText("Charges")
        self.ledgerPage:GetNamedChild("Subtitle"):SetText("Repairs, penalties, travel and other session costs")
        self.ledgerPage:GetNamedChild("SubpageLabel"):SetText("PAGE 0.3")
        self.categoryView:GetNamedChild("Heading"):SetText("CHARGES BY CATEGORY")
        rows = {
            { "Repairs", summary.repairs, true },
            { "Fines and Bounties", summary.finesBounties, true },
            { "Wayshrine Fees", summary.wayshrineFees, true },
            { "Other Charges", summary.otherExpenses, true },
        }
        local totalCharges = summary.repairs.total + summary.finesBounties.total + summary.wayshrineFees.total + summary.otherExpenses.total
        footerText = "TOTAL CHARGES  |cC56B6B" .. (totalCharges > 0 and "-" or "") .. FormatNumber(totalCharges) .. "|r"
        if totalCharges > 0 then
            footerText = footerText .. " |t28:28:EsoUI/Art/Currency/currency_gold.dds|t"
        end
    end

    for row = 1, 12 do
        local data = rows[row]
        local nameControl = self.categoryView:GetNamedChild("Row" .. row .. "Name")
        local countControl = self.categoryView:GetNamedChild("Row" .. row .. "Count")
        local totalControl = self.categoryView:GetNamedChild("Row" .. row .. "Total")
        local visible = row <= 8 and data ~= nil
        nameControl:SetHidden(not visible)
        countControl:SetHidden(not visible)
        totalControl:SetHidden(not visible)
        if visible then
            self:SetCategoryRow(row, data[1], data[2], data[3])
        else
            nameControl:SetText("")
            countControl:SetText("")
            totalControl:SetText("")
        end
    end
    self.ledgerPage:GetNamedChild("ProfitLossLabel"):SetText(footerText)
    self.ledgerPage:GetNamedChild("SessionTimeLabel"):SetText("|t28:28:EsoUI/Art/Miscellaneous/timer_32.dds|t  SESSION TIME  " .. self:FormatSessionTime())
end

function GuildSalesJournal_Gamepad:RefreshSessionLedgerPage()
    local bank, character, total = self:GetGoldBalances()
    if self.lastKnownTotal == nil then
        self.lastKnownTotal = total
        self.sessionStartTotal = total
    end

    self:SetLedgerControlsHidden(false)
    self.categoryView:SetHidden(true)
    self.ledgerPage:GetNamedChild("Title"):SetText("Session Ledger")
    self.ledgerPage:GetNamedChild("Subtitle"):SetText("Every incoming and outgoing gold movement this session")
    self.ledgerPage:GetNamedChild("SubpageLabel"):SetText("PAGE 0.1")

    local coin = " |t30:30:EsoUI/Art/Currency/currency_gold.dds|t"
    self.ledgerPage:GetNamedChild("BankValue"):SetText(FormatNumber(bank) .. coin)
    self.ledgerPage:GetNamedChild("CharacterValue"):SetText(FormatNumber(character) .. coin)
    self.ledgerPage:GetNamedChild("TotalValue"):SetText(FormatNumber(total) .. coin)
    self.ledgerPage:GetNamedChild("SessionHeading"):SetText("SESSION SUMMARY")

    local _, totalIncome, totalExpenses = self:GetCategorySummary()
    local openingBalance = self.sessionStartTotal or total
    local balanceAfterSpending = openingBalance - totalExpenses
    local balanceAfterIncome = balanceAfterSpending + totalIncome
    self:SetSessionSummaryRow(1, "expense", totalExpenses, balanceAfterSpending)
    self:SetSessionSummaryRow(2, "income", totalIncome, balanceAfterIncome)
    for row = 3, 6 do
        self.ledgerPage:GetNamedChild("Row" .. row .. "Earned"):SetHidden(true)
        self.ledgerPage:GetNamedChild("Row" .. row .. "Spent"):SetHidden(true)
        self.ledgerPage:GetNamedChild("Row" .. row .. "Balance"):SetHidden(true)
    end

    local profitLoss = total - openingBalance
    local colour = profitLoss > 0 and "|c78D878+" or (profitLoss < 0 and "|cC56B6B" or "|cB8B8B8")
    self.ledgerPage:GetNamedChild("SessionTimeLabel"):SetText("|t28:28:EsoUI/Art/Miscellaneous/timer_32.dds|t  SESSION TIME  " .. self:FormatSessionTime())
    self.ledgerPage:GetNamedChild("ProfitLossLabel"):SetText("TOTAL PROFIT/LOSS  " .. colour .. FormatNumber(profitLoss) .. "|r" .. coin)
end

function GuildSalesJournal_Gamepad:RefreshLedgerPage()
    if self.ledgerSubpageIndex == LEDGER_SUBPAGE_SESSION then
        self:RefreshSessionLedgerPage()
    else
        self:RefreshCategoryPage(self.ledgerSubpageIndex)
    end
end

function GuildSalesJournal_Gamepad:RefreshLedgerHoldingPage()
    self:RefreshLedgerPage()
end

function GuildSalesJournal_Gamepad:RefreshHistoryPage()
    local guildId, pageName = self:GetScopeForPage(self.salesPageIndex)
    local records = GSJ:GetSortedRecords(guildId)

    self.historyPage:GetNamedChild("Title"):SetText(pageName)
    self.historyPage:GetNamedChild("Subtitle"):SetText("Your completed guild-store sales")

    self.historyList:SetScope(guildId)

    if #records == 0 then
        self.historyPage:GetNamedChild("DetailBody"):SetText("No personal sales recorded for this account.")
    end
end


function GuildSalesJournal_Gamepad:GetListingsStore()
    GSJ.listings = GSJ.listings or {}
    GSJ.listings.guilds = GSJ.listings.guilds or {}
    GSJ.listings.guildOrder = GSJ.listings.guildOrder or {}
    GSJ.listings.lastRefreshAt = tonumber(GSJ.listings.lastRefreshAt) or 0
    return GSJ.listings
end

function GuildSalesJournal_Gamepad:GetGuildMemberCountSafe(guildId)
    if GetNumGuildMembers then
        local ok, value = pcall(GetNumGuildMembers, guildId)
        if ok then return tonumber(value) or 0 end
    end
    return 0
end

function GuildSalesJournal_Gamepad:GuildHasStore(guildId)
    local members = self:GetGuildMemberCountSafe(guildId)
    if DoesGuildHavePrivilege and GUILD_PRIVILEGE_TRADING_HOUSE then
        local ok, hasPrivilege = pcall(
            DoesGuildHavePrivilege,
            guildId,
            GUILD_PRIVILEGE_TRADING_HOUSE
        )
        if ok then
            return hasPrivilege == true, members, "PRIVILEGE"
        end
    end

    return members > 50, members, "MEMBER COUNT"
end

function GuildSalesJournal_Gamepad:SetListingStatus(message)
    -- Operational refresh messages are kept internally.  The Listed Items
    -- header is deliberately limited to one fixed-size "Last refresh" line
    -- so long status text can never force ESO to shrink the UI again.
    self.listingStatusMessage = tostring(message or "")
end

function GuildSalesJournal_Gamepad:MarkListingRefreshPending()
    if self.listingRefreshRunning then
        self.listingRefreshRepeatPending = true
        return
    end
    self.listingRefreshArmed = true
end

function GuildSalesJournal_Gamepad:GetNativeListingsCount()
    local listings = GAMEPAD_TRADING_HOUSE_LISTINGS
    if listings and listings.itemList and listings.itemList.GetNumItems then
        local ok, count = pcall(function() return listings.itemList:GetNumItems() end)
        if ok then return tonumber(count) or -1 end
    end
    return -1
end

function GuildSalesJournal_Gamepad:StoreNoGuildStoreSnapshot(guildId, guildName, memberCount)
    local store = self:GetListingsStore()
    store.guilds[tostring(guildId)] = {
        guildId = guildId,
        name = guildName,
        hasStore = false,
        memberCount = tonumber(memberCount) or 0,
        capturedAt = GetTimeStamp and GetTimeStamp() or 0,
        reportedCount = 0,
        items = {},
    }
end

function GuildSalesJournal_Gamepad:CaptureActiveGuildListings(reason)
    if not self.listingRefreshRunning or self.listingRefreshActiveCaptured then return end

    local selectedGuildId = 0
    if GetSelectedTradingHouseGuildId then
        local ok, value = pcall(GetSelectedTradingHouseGuildId)
        if ok then selectedGuildId = tonumber(value) or 0 end
    end
    if selectedGuildId ~= self.listingRefreshActiveGuildId then return end

    self.listingRefreshActiveCaptured = true

    local guildData = self.listingRefreshQueue[self.listingRefreshIndex]
    if not guildData then return end

    local cacheReady = true
    if HasTradingHouseListings then
        local ok, value = pcall(HasTradingHouseListings)
        cacheReady = ok and value == true
    end
    if not cacheReady then
        self.listingRefreshAwaitingResponse = false
        self.listingRefreshResponseSucceeded = false
        self:SetListingStatus("Listings were unavailable for " .. tostring(guildData.name) .. "; previous snapshot retained.")
        local token = self.listingRefreshToken
        zo_callLater(function()
            if self.listingRefreshRunning and token == self.listingRefreshToken then
                self:AdvanceListingRefresh()
            end
        end, 450)
        return
    end

    local apiCount = 0
    if GetNumTradingHouseListings then
        local ok, value = pcall(GetNumTradingHouseListings)
        if ok then apiCount = math.max(0, tonumber(value) or 0) end
    end

    local now = GetTimeStamp and GetTimeStamp() or 0
    local items = {}
    local maximum = math.min(apiCount, LISTING_SLOT_LIMIT)

    for index = 1, maximum do
        if GetTradingHouseListingItemInfo then
            local ok, _, itemName, _, stackCount, _, timeRemaining, salePrice, _, itemUniqueId, unitPrice =
                pcall(GetTradingHouseListingItemInfo, index)

            if ok then
                local itemLink = ""
                if GetTradingHouseListingItemLink then
                    local linkOk, value = pcall(
                        GetTradingHouseListingItemLink,
                        index,
                        LINK_STYLE_DEFAULT or 0
                    )
                    if linkOk and value then itemLink = tostring(value) end
                end

                local cleanName = tostring(itemName or "")
                if zo_strformat and cleanName ~= "" then
                    cleanName = zo_strformat(SI_TOOLTIP_ITEM_NAME, cleanName)
                end
                if cleanName == "" and itemLink ~= "" and GetItemLinkName then
                    local nameOk, value = pcall(GetItemLinkName, itemLink)
                    if nameOk and value then cleanName = tostring(value) end
                end
                if cleanName == "" then cleanName = "Unknown Item" end

                local remaining = math.max(0, tonumber(timeRemaining) or 0)
                items[#items + 1] = {
                    Id64String(itemUniqueId),
                    itemLink,
                    cleanName,
                    math.max(1, tonumber(stackCount) or 1),
                    math.max(0, tonumber(salePrice) or 0),
                    math.max(0, tonumber(unitPrice) or 0),
                    now + remaining,
                }
            end
        end
    end

    local store = self:GetListingsStore()
    store.guilds[tostring(guildData.id)] = {
        guildId = guildData.id,
        name = guildData.name,
        hasStore = true,
        memberCount = tonumber(guildData.memberCount) or 0,
        capturedAt = now,
        reportedCount = apiCount,
        nativeCount = self:GetNativeListingsCount(),
        items = items,
        captureReason = tostring(reason or ""),
    }

    self.listingRefreshAwaitingResponse = false
    self.listingRefreshResponseSucceeded = false

    local token = self.listingRefreshToken
    zo_callLater(function()
        if self.listingRefreshRunning and token == self.listingRefreshToken then
            self:AdvanceListingRefresh()
        end
    end, 450)
end

function GuildSalesJournal_Gamepad:SelectFirstGuildWithListings()
    local guilds = self:GetListedGuilds()
    for index, guild in ipairs(guilds) do
        local snapshot = guild.snapshot
        if snapshot and snapshot.hasStore and #(snapshot.items or {}) > 0 then
            self.listedGuildIndex = index
            return
        end
    end
end

function GuildSalesJournal_Gamepad:FinishListingRefresh(message)
    local originalGuildId = self.listingRefreshOriginalGuildId
    local totalItems = 0
    local store = self:GetListingsStore()
    local repeatPending = self.listingRefreshRepeatPending == true

    for _, snapshot in pairs(store.guilds or {}) do
        if snapshot and snapshot.hasStore then
            totalItems = totalItems + #(snapshot.items or {})
        end
    end

    self.listingRefreshRunning = false
    self.listingRefreshArmed = repeatPending
    self.listingRefreshCloseAfter = false
    self.listingRefreshRepeatPending = false
    self.listingRefreshAwaitingResponse = false
    self.listingRefreshResponseSucceeded = false
    self.listingRefreshActiveCaptured = false
    store.lastRefreshAt = GetTimeStamp and GetTimeStamp() or 0

    if originalGuildId and originalGuildId > 0 and SelectTradingHouseGuildId then
        pcall(SelectTradingHouseGuildId, originalGuildId)
    end

    self:SelectFirstGuildWithListings()
    local summary = message or string.format(
        "Refresh complete: %d stores, %d listings.",
        #self.listingRefreshQueue,
        totalItems
    )
    self:SetListingStatus(summary)
    GSJ:Message(summary)

    if self.currentQ1Page == Q1_LISTED and self.listedPage and not self.listedPage:IsHidden() then
        self:RefreshListedPage()
    end

end

function GuildSalesJournal_Gamepad:RequestActiveListingGuild(selectAttempt)
    if not self.listingRefreshRunning then return end
    local token = self.listingRefreshToken
    local guildData = self.listingRefreshQueue[self.listingRefreshIndex]
    if not guildData then
        self:FinishListingRefresh()
        return
    end

    local selectedGuildId = 0
    if GetSelectedTradingHouseGuildId then
        local ok, value = pcall(GetSelectedTradingHouseGuildId)
        if ok then selectedGuildId = tonumber(value) or 0 end
    end

    selectAttempt = tonumber(selectAttempt) or 1
    if selectedGuildId ~= guildData.id then
        if selectAttempt <= 12 then
            zo_callLater(function()
                if self.listingRefreshRunning and token == self.listingRefreshToken then
                    self:RequestActiveListingGuild(selectAttempt + 1)
                end
            end, 200)
        else
            self.listingRefreshActiveCaptured = true
            self:SetListingStatus("Could not select " .. tostring(guildData.name) .. "; moving on.")
            zo_callLater(function()
                if self.listingRefreshRunning and token == self.listingRefreshToken then
                    self:AdvanceListingRefresh()
                end
            end, 300)
        end
        return
    end

    if TRADING_HOUSE_SEARCH and TRADING_HOUSE_SEARCH.CanDoCommonOperation then
        local ok, canOperate = pcall(function() return TRADING_HOUSE_SEARCH:CanDoCommonOperation() end)
        if ok and not canOperate and selectAttempt <= 20 then
            zo_callLater(function()
                if self.listingRefreshRunning and token == self.listingRefreshToken then
                    self:RequestActiveListingGuild(selectAttempt + 1)
                end
            end, 250)
            return
        end
    end

    self.listingRefreshAwaitingResponse = true
    self.listingRefreshResponseSucceeded = false
    self.listingRefreshActiveCaptured = false
    self:SetListingStatus(string.format(
        "Refreshing %d/%d: %s",
        self.listingRefreshIndex,
        #self.listingRefreshQueue,
        tostring(guildData.name)
    ))

    local requestCalled = false
    if GAMEPAD_TRADING_HOUSE_LISTINGS and GAMEPAD_TRADING_HOUSE_LISTINGS.RequestListUpdate then
        requestCalled = pcall(function() GAMEPAD_TRADING_HOUSE_LISTINGS:RequestListUpdate() end)
    elseif RequestTradingHouseListings then
        requestCalled = pcall(RequestTradingHouseListings)
    end

    if not requestCalled then
        self:CaptureActiveGuildListings("REQUEST FAILED")
        return
    end

    local alreadyAvailable = false
    if HasTradingHouseListings then
        local ok, value = pcall(HasTradingHouseListings)
        alreadyAvailable = ok and value == true
    end
    if alreadyAvailable then
        zo_callLater(function()
            if self.listingRefreshRunning and token == self.listingRefreshToken and not self.listingRefreshActiveCaptured then
                if GAMEPAD_TRADING_HOUSE_LISTINGS and GAMEPAD_TRADING_HOUSE_LISTINGS.RefreshData then
                    pcall(function() GAMEPAD_TRADING_HOUSE_LISTINGS:RefreshData(true) end)
                end
                zo_callLater(function()
                    if self.listingRefreshRunning and token == self.listingRefreshToken then
                        self:CaptureActiveGuildListings("CACHE READY")
                    end
                end, 150)
            end
        end, 250)
    end

    zo_callLater(function()
        if self.listingRefreshRunning and token == self.listingRefreshToken and not self.listingRefreshActiveCaptured then
            self:CaptureActiveGuildListings("TIMEOUT")
        end
    end, 7000)
end

function GuildSalesJournal_Gamepad:AdvanceListingRefresh()
    if not self.listingRefreshRunning then return end

    self.listingRefreshIndex = self.listingRefreshIndex + 1
    if self.listingRefreshIndex > #self.listingRefreshQueue then
        self:FinishListingRefresh()
        return
    end

    local guildData = self.listingRefreshQueue[self.listingRefreshIndex]
    self.listingRefreshActiveGuildId = guildData.id
    self.listingRefreshAwaitingResponse = false
    self.listingRefreshResponseSucceeded = false
    self.listingRefreshActiveCaptured = false

    if SelectTradingHouseGuildId then
        pcall(SelectTradingHouseGuildId, guildData.id)
    end

    local token = self.listingRefreshToken
    zo_callLater(function()
        if self.listingRefreshRunning and token == self.listingRefreshToken then
            self:RequestActiveListingGuild(1)
        end
    end, 350)
end

function GuildSalesJournal_Gamepad:BuildListingRefreshQueue()
    local queue = {}
    local order = {}
    local count = 0
    if GetNumTradingHouseGuilds then
        local ok, value = pcall(GetNumTradingHouseGuilds)
        if ok then count = tonumber(value) or 0 end
    end

    if GetTradingHouseGuildDetails then
        for index = 1, count do
            local ok, guildId, guildName = pcall(GetTradingHouseGuildDetails, index)
            guildId = ok and tonumber(guildId) or 0
            if guildId > 0 then
                local name = (guildName and guildName ~= "")
                    and guildName
                    or (GetGuildName and GetGuildName(guildId))
                    or tostring(guildId)
                local hasStore, members = self:GuildHasStore(guildId)

                order[#order + 1] = guildId
                if hasStore then
                    queue[#queue + 1] = {
                        id = guildId,
                        name = name,
                        memberCount = members,
                    }
                else
                    self:StoreNoGuildStoreSnapshot(guildId, name, members)
                end
            end
        end
    end

    self:GetListingsStore().guildOrder = order
    return queue
end

function GuildSalesJournal_Gamepad:StartListingRefresh()
    if self.listingRefreshRunning then return end
    if not self.tradingHouseOpen or not self.tradingHouseListingsVisible then
        self:MarkListingRefreshPending()
        return
    end

    local queue = self:BuildListingRefreshQueue()
    if #queue == 0 then
        self.listingRefreshArmed = false
        self:SetListingStatus("No guild stores are currently available.")
        return
    end

    self.listingRefreshQueue = queue
    self.listingRefreshIndex = 0
    self.listingRefreshToken = self.listingRefreshToken + 1
    self.listingRefreshRunning = true
    self.listingRefreshArmed = false
    self.listingRefreshOriginalGuildId = 0
    if GetSelectedTradingHouseGuildId then
        local ok, value = pcall(GetSelectedTradingHouseGuildId)
        if ok then self.listingRefreshOriginalGuildId = tonumber(value) or 0 end
    end

    self:SetListingStatus("Starting listing refresh...")
    self:AdvanceListingRefresh()
end

function GuildSalesJournal_Gamepad:ArmListingRefresh()
    if self.listingRefreshRunning then
        self.listingRefreshRepeatPending = true
        self:SetListingStatus("A second listing refresh is queued.")
        return
    end

    self:MarkListingRefreshPending()
    self:SetListingStatus("Listing refresh pending.")
    if self.tradingHouseOpen and self.tradingHouseListingsVisible then
        self:StartListingRefresh()
    end
end

function GuildSalesJournal_Gamepad:BeginListingRefreshBeforeClose()
    -- 0.0.22 emergency safety rollback:
    -- never consume the player's Back action. Automatic refresh may arm on
    -- Guild Store open, but it only runs when the native Listings screen is
    -- explicitly shown.
    return false
end

function GuildSalesJournal_Gamepad:HookTradingHouseClose()
    -- Intentionally disabled. A pre-hook on OnBackButtonClicked in 0.0.21
    -- could retain control of the trading-house scene and trap the player at
    -- the banker.
    self.tradingHouseCloseHooked = false
    return false
end

function GuildSalesJournal_Gamepad:HookTradingHouseListingsScreen()
    if self.tradingHouseListingsHooked then
        return true
    end
    if not GAMEPAD_TRADING_HOUSE_LISTINGS or not ZO_PostHook then return false end

    self.tradingHouseListingsHooked = true
    ZO_PostHook(GAMEPAD_TRADING_HOUSE_LISTINGS, "OnShown", function()
        self.tradingHouseListingsVisible = true
        if self.listingRefreshArmed and not self.listingRefreshRunning then
            zo_callLater(function()
                if self.listingRefreshArmed and self.tradingHouseOpen and self.tradingHouseListingsVisible then
                    self:StartListingRefresh()
                end
            end, 700)
        end
    end)
    ZO_PostHook(GAMEPAD_TRADING_HOUSE_LISTINGS, "OnHiding", function()
        self.tradingHouseListingsVisible = false
    end)
    ZO_PostHook(GAMEPAD_TRADING_HOUSE_LISTINGS, "RefreshData", function()
        if self.listingRefreshRunning and self.listingRefreshResponseSucceeded and not self.listingRefreshActiveCaptured then
            local token = self.listingRefreshToken
            zo_callLater(function()
                if self.listingRefreshRunning and token == self.listingRefreshToken then
                    self:CaptureActiveGuildListings("NATIVE REFRESH")
                end
            end, 120)
        end
    end)

    return true
end

function GuildSalesJournal_Gamepad:RegisterTradingHouseListings()
    local prefix = "PFJ_Listings_"

    local function Register(name, eventCode, callback)
        if not eventCode then return end
        EVENT_MANAGER:UnregisterForEvent(prefix .. name, eventCode)
        EVENT_MANAGER:RegisterForEvent(prefix .. name, eventCode, callback)
    end

    Register("Open", EVENT_OPEN_TRADING_HOUSE, function()
        self.tradingHouseOpen = true
        self.listingRefreshCloseAfter = false
        self:MarkListingRefreshPending()
        self:HookTradingHouseListingsScreen()
    end)

    Register("Close", EVENT_CLOSE_TRADING_HOUSE, function()
        self.tradingHouseOpen = false
        self.tradingHouseListingsVisible = false
        self.listingRefreshCloseAfter = false
        if self.listingRefreshRunning then
            self.listingRefreshToken = self.listingRefreshToken + 1
            self.listingRefreshRunning = false
            self.listingRefreshArmed = true
            self.listingRefreshRepeatPending = false
            self:SetListingStatus("Refresh interrupted; it will retry next time a Guild Store opens.")
        end
    end)

    Register("Response", EVENT_TRADING_HOUSE_RESPONSE_RECEIVED, function(_, responseType, result)
        -- Posting or cancelling changes the player's live listings.  Rearm the
        -- automatic snapshot, but never switch guilds while the sale workflow
        -- is active.  The refresh waits for Listings or the safe Back action.
        if result == TRADING_HOUSE_RESULT_SUCCESS
            and (responseType == TRADING_HOUSE_RESULT_POST_PENDING
                or responseType == TRADING_HOUSE_RESULT_CANCEL_SALE_PENDING)
        then
            self:MarkListingRefreshPending()
        end

        if not self.listingRefreshRunning
            or not self.listingRefreshAwaitingResponse
            or responseType ~= TRADING_HOUSE_RESULT_LISTINGS_PENDING
        then
            return
        end

        if result == TRADING_HOUSE_RESULT_SUCCESS then
            self.listingRefreshResponseSucceeded = true
            local token = self.listingRefreshToken
            zo_callLater(function()
                if self.listingRefreshRunning and token == self.listingRefreshToken and not self.listingRefreshActiveCaptured then
                    if GAMEPAD_TRADING_HOUSE_LISTINGS and GAMEPAD_TRADING_HOUSE_LISTINGS.RefreshData then
                        pcall(function() GAMEPAD_TRADING_HOUSE_LISTINGS:RefreshData(true) end)
                    end
                    zo_callLater(function()
                        if self.listingRefreshRunning and token == self.listingRefreshToken then
                            self:CaptureActiveGuildListings("RESPONSE")
                        end
                    end, 180)
                end
            end, 220)
        else
            self:CaptureActiveGuildListings("RESPONSE ERROR")
        end
    end)

    Register("Timeout", EVENT_TRADING_HOUSE_RESPONSE_TIMEOUT, function(_, responseType)
        if self.listingRefreshRunning
            and self.listingRefreshAwaitingResponse
            and responseType == TRADING_HOUSE_RESULT_LISTINGS_PENDING
        then
            self:CaptureActiveGuildListings("EVENT TIMEOUT")
        end
    end)

    zo_callLater(function()
        self:HookTradingHouseListingsScreen()
    end, 1200)
end

function GuildSalesJournal_Gamepad:GetListedGuilds()
    local guilds = {}
    local store = self:GetListingsStore()
    local seen = {}

    for _, source in ipairs(self:GetGuildSources()) do
        local key = tostring(source.guildId)
        local snapshot = store.guilds[key]
        if not snapshot then
            local hasStore, members = self:GuildHasStore(source.guildId)
            snapshot = {
                guildId = source.guildId,
                name = source.name,
                hasStore = hasStore,
                memberCount = members,
                capturedAt = 0,
                reportedCount = 0,
                items = {},
            }
        end
        snapshot.name = source.name
        guilds[#guilds + 1] = {
            guildId = source.guildId,
            name = source.name,
            snapshot = snapshot,
        }
        seen[key] = true
    end

    for key, snapshot in pairs(store.guilds or {}) do
        if not seen[key] then
            guilds[#guilds + 1] = {
                guildId = tonumber(snapshot.guildId) or 0,
                name = snapshot.name or ("Guild " .. key),
                snapshot = snapshot,
            }
        end
    end

    return guilds
end

function GuildSalesJournal_Gamepad:GetCurrentListedGuild()
    local guilds = self:GetListedGuilds()
    if #guilds == 0 then return nil, guilds end
    self.listedGuildIndex = math.max(1, math.min(self.listedGuildIndex or 1, #guilds))
    return guilds[self.listedGuildIndex], guilds
end

function GuildSalesJournal_Gamepad:ChangeListedGuild(delta)
    local _, guilds = self:GetCurrentListedGuild()
    if #guilds == 0 then return end
    self.listedGuildIndex = ((self.listedGuildIndex - 1 + delta) % #guilds) + 1
    self:RefreshListedPage()
    if KEYBIND_STRIP and self.q1Keybinds and not self.focusInListed then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(self.q1Keybinds)
    end
    if KEYBIND_STRIP and self.listedKeybinds and self.focusInListed then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(self.listedKeybinds)
    end
end

function GuildSalesJournal_Gamepad:FormatListingRemaining(expiresAt)
    local now = GetTimeStamp and GetTimeStamp() or 0
    local remaining = math.floor((tonumber(expiresAt) or 0) - now)
    if remaining <= 0 then return "|cD86A6AExpired — refresh|r" end

    local days = math.floor(remaining / 86400)
    local hours = math.floor((remaining % 86400) / 3600)
    local minutes = math.floor((remaining % 3600) / 60)

    if days > 0 then
        return string.format("%dd %02dh remaining", days, hours)
    elseif hours > 0 then
        return string.format("%dh %02dm remaining", hours, minutes)
    end
    return string.format("%dm remaining", math.max(1, minutes))
end

function GuildSalesJournal_Gamepad:FormatSnapshotAge(capturedAt)
    capturedAt = tonumber(capturedAt) or 0
    if capturedAt <= 0 then return "Never" end

    local now = GetTimeStamp and GetTimeStamp() or 0
    local age = math.max(0, now - capturedAt)
    if age < 60 then return "just now" end
    if age < 3600 then return string.format("%dm ago", math.floor(age / 60)) end
    if age < 86400 then return string.format("%dh ago", math.floor(age / 3600)) end
    return string.format("%dd ago", math.floor(age / 86400))
end

function GuildSalesJournal_Gamepad:UpdateListedHeader(guild)
    local header = self.listedPage:GetNamedChild("Header")
    local capturedAt = guild and guild.snapshot and guild.snapshot.capturedAt or 0
    header:SetText("Last refresh: " .. self:FormatSnapshotAge(capturedAt))
end

function GuildSalesJournal_Gamepad:RefreshListedPage()
    self.ledgerPage:SetHidden(true)
    self.historyPage:SetHidden(true)
    self.listedPage:SetHidden(false)

    self.listedPage:GetNamedChild("Title"):SetText("Listed Items")
    self.listedPage:GetNamedChild("Subtitle"):SetText("Captured from your guild stores at a banker")

    local guild, guilds = self:GetCurrentListedGuild()
    self:UpdateListedHeader(guild)

    if self.listedList then
        self.listedList:SetGuild(guild)
    end

    local snapshot = guild and guild.snapshot or nil
    local items = snapshot and snapshot.items or {}
    if not guild then
        self:UpdateListingDetails(nil, "No guilds are available.")
    elseif snapshot.hasStore ~= true then
        self:UpdateListingDetails(nil, "This guild has no Guild Store and is skipped during refreshes.")
    elseif (tonumber(snapshot.capturedAt) or 0) <= 0 then
        self:UpdateListingDetails(nil, "No listing snapshot yet. Visit a Guild Store; the Journal will refresh automatically when you leave.")
    elseif #items == 0 then
        self:UpdateListingDetails(nil, "No active listings were found in this guild.")
    elseif self.listedList and self.listedList.selectedData then
        self:UpdateListingDetails(self.listedList.selectedData)
    else
        self:UpdateListingDetails(nil, "Press X to enter the list.\n\nPress Triangle before visiting the Guild Store, then open Listings to update.")
    end
end

function GuildSalesJournal_Gamepad:RefreshListedCountdowns()
    if self.currentQ1Page ~= Q1_LISTED or not self.listedPage or self.listedPage:IsHidden() then return end
    local guild, guilds = self:GetCurrentListedGuild()
    self:UpdateListedHeader(guild)
    if self.listedList then
        self.listedList:RefreshVisibleRows()
        if self.listedList.selectedData then
            self:UpdateListingDetails(self.listedList.selectedData)
        else
            local snapshot = guild and guild.snapshot or nil
            local items = snapshot and snapshot.items or {}
            if not guild then
                self:UpdateListingDetails(nil, "No guilds are available.")
            elseif snapshot.hasStore ~= true then
                self:UpdateListingDetails(nil, "This guild has no Guild Store and is skipped during refreshes.")
            elseif (tonumber(snapshot.capturedAt) or 0) <= 0 then
                self:UpdateListingDetails(nil, "No listing snapshot yet. Visit a Guild Store; the Journal will refresh automatically when you leave.")
            elseif #items == 0 then
                self:UpdateListingDetails(nil, "No active listings were found in this guild.")
            else
                self:UpdateListingDetails(nil, "Press X to enter the list.\n\nPress Triangle before visiting the Guild Store, then open Listings to update.")
            end
        end
    end
end

function GuildSalesJournal_Gamepad:UpdateListingDetails(listing, message)
    local body = self.listedPage:GetNamedChild("DetailBody")
    if not listing then
        body:SetText(message or "Select a listing.")
        return
    end

    local remaining = self:FormatListingRemaining(listing.expiresAt)
    local itemText = listing.itemLink ~= "" and listing.itemLink or listing.itemName
    local lines = {
        "|cFFFFFF" .. itemText .. "|r",
        "",
        "|cB8B8B8Quantity|r  |cFFFFFF" .. FormatNumber(listing.quantity) .. "|r",
        "|cB8B8B8Listed Price|r  |cFFFFFF" .. FormatNumber(listing.salePrice) .. " gold|r",
    }
    if listing.quantity > 1 and listing.unitPrice > 0 then
        lines[#lines + 1] = "|cB8B8B8Unit Price|r  |c8FAED8" .. FormatNumber(listing.unitPrice) .. " gold|r"
    end
    lines[#lines + 1] = ""
    lines[#lines + 1] = "|cB8B8B8Time Remaining|r"
    lines[#lines + 1] = remaining
    body:SetText(table.concat(lines, "\n"))
end

function GuildSalesJournal_Gamepad:UpdateSaleDetails(sale)
    local body = self.historyPage:GetNamedChild("DetailBody")
    if not sale then
        body:SetText("Select a sale.")
        return
    end

    local unit, fee, cut, profit = Financials(sale.price, sale.quantity)
    local coin = " |t28:28:EsoUI/Art/Currency/currency_gold.dds|t"
    local label = "|cB8B8B8"
    local buyer = "|c9EC9FF"
    local feeColour = "|cD8A65C"
    local cutColour = "|cC9825A"
    local profitColour = "|c78D878"

    body:SetText(table.concat({
        label .. "Buyer|r",
        buyer .. tostring(sale.buyer or "Unknown") .. "|r",
        "",
        label .. "Quantity|r  |cD8D8D8" .. FormatNumber(sale.quantity) .. "|r",
        label .. "Unit Price|r  |cD8D8D8" .. FormatNumber(unit) .. "|r" .. coin,
        label .. "Total Sale|r  |cFFFFFF" .. FormatNumber(sale.price) .. "|r" .. coin,
        "",
        feeColour .. "Listing Fee (1%)|r  " .. feeColour .. FormatNumber(fee) .. "|r" .. coin,
        cutColour .. "House Cut (7%)|r  " .. cutColour .. FormatNumber(cut) .. "|r" .. coin,
        profitColour .. "Profit|r  " .. profitColour .. FormatNumber(profit) .. "|r" .. coin,
        "",
        "|cFFFFFFAccumulated Earnings|r",
        "",
        feeColour .. "Listing Fees|r  " .. feeColour .. FormatNumber(sale.cumulativeFee or fee) .. "|r" .. coin,
        cutColour .. "House Cut|r  " .. cutColour .. FormatNumber(sale.cumulativeCut or cut) .. "|r" .. coin,
        profitColour .. "Profit|r  " .. profitColour .. FormatNumber(sale.cumulativeProfit or profit) .. "|r" .. coin,
    }, "\n"))
end

function GuildSalesJournal_Gamepad:GetLeftLedgerTarget()
    if self.ledgerSubpageIndex == LEDGER_SUBPAGE_SESSION then
        return LEDGER_SUBPAGE_INCOME, "Income"
    elseif self.ledgerSubpageIndex == LEDGER_SUBPAGE_INCOME then
        return LEDGER_SUBPAGE_SESSION, "Session Ledger"
    elseif self.ledgerSubpageIndex == LEDGER_SUBPAGE_PURCHASES then
        return LEDGER_SUBPAGE_INCOME, "Income"
    end
    return LEDGER_SUBPAGE_PURCHASES, "Purchases"
end

function GuildSalesJournal_Gamepad:GetRightLedgerTarget()
    if self.ledgerSubpageIndex == LEDGER_SUBPAGE_SESSION or self.ledgerSubpageIndex == LEDGER_SUBPAGE_INCOME then
        return LEDGER_SUBPAGE_PURCHASES, "Purchases"
    elseif self.ledgerSubpageIndex == LEDGER_SUBPAGE_PURCHASES then
        return LEDGER_SUBPAGE_CHARGES, "Charges"
    end
    return LEDGER_SUBPAGE_SESSION, "Session Ledger"
end

function GuildSalesJournal_Gamepad:InitializeKeybindDescriptors()
    -- Keep Sales History and Listed Items in separate top-level groups.
    -- KEYBIND_STRIP does not reliably fall back between multiple descriptors
    -- that reuse the same physical button inside one group.
    self.salesQ1Keybinds = {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
        {
            name = function()
                local _, label = self:GetLeftLedgerTarget()
                return label
            end,
            keybind = "UI_SHORTCUT_LEFT_TRIGGER",
            gamepadOrder = -2,
            visible = function()
                return self.currentQ1Page == Q1_SALES and self.salesPageIndex == SALES_PAGE_LEDGER
            end,
            callback = function()
                local target = self:GetLeftLedgerTarget()
                self:SetLedgerSubpage(target)
            end,
        },
        {
            name = function()
                local _, label = self:GetRightLedgerTarget()
                return label
            end,
            keybind = "UI_SHORTCUT_RIGHT_TRIGGER",
            gamepadOrder = -1,
            visible = function()
                return self.currentQ1Page == Q1_SALES and self.salesPageIndex == SALES_PAGE_LEDGER
            end,
            callback = function()
                local target = self:GetRightLedgerTarget()
                self:SetLedgerSubpage(target)
            end,
        },
        {
            name = "Previous Page",
            keybind = "UI_SHORTCUT_LEFT_SHOULDER",
            visible = function() return self.currentQ1Page == Q1_SALES end,
            callback = function() self:ChangeSalesPage(-1) end,
        },
        {
            name = "Next Page",
            keybind = "UI_SHORTCUT_RIGHT_SHOULDER",
            visible = function() return self.currentQ1Page == Q1_SALES end,
            callback = function() self:ChangeSalesPage(1) end,
        },
        {
            name = GetString(SI_GAMEPAD_SELECT_OPTION),
            keybind = "UI_SHORTCUT_PRIMARY",
            visible = function()
                return self.currentQ1Page == Q1_SALES
                    and self.salesPageIndex > SALES_PAGE_LEDGER
                    and self.historyList
                    and self.historyList:HasEntries()
            end,
            callback = function() self:FocusHistoryList() end,
        },
        {
            name = "Refresh",
            keybind = "UI_SHORTCUT_TERTIARY",
            visible = function()
                return self.currentQ1Page == Q1_SALES and GSJ.settings.refreshMode == "MANUAL"
            end,
            callback = function()
                GSJ:RefreshTraderHistory(false)
                self:RefreshSalesPage()
            end,
        },
        {
            name = GetString(SI_GAMEPAD_BACK_OPTION),
            keybind = "UI_SHORTCUT_NEGATIVE",
            callback = function() SCENE_MANAGER:HideCurrentScene() end,
        },
    }

    self.listedQ1Keybinds = {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
        {
            name = "Previous Guild",
            keybind = "UI_SHORTCUT_LEFT_SHOULDER",
            visible = function()
                return self.currentQ1Page == Q1_LISTED and #self:GetListedGuilds() > 1
            end,
            callback = function() self:ChangeListedGuild(-1) end,
        },
        {
            name = "Next Guild",
            keybind = "UI_SHORTCUT_RIGHT_SHOULDER",
            visible = function()
                return self.currentQ1Page == Q1_LISTED and #self:GetListedGuilds() > 1
            end,
            callback = function() self:ChangeListedGuild(1) end,
        },
        {
            name = GetString(SI_GAMEPAD_SELECT_OPTION),
            keybind = "UI_SHORTCUT_PRIMARY",
            visible = function()
                return self.currentQ1Page == Q1_LISTED
                    and self.listedList
                    and self.listedList:HasEntries()
            end,
            callback = function() self:FocusListedList() end,
        },
        {
            name = "Refresh Listings",
            keybind = "UI_SHORTCUT_TERTIARY",
            visible = function() return self.currentQ1Page == Q1_LISTED end,
            callback = function() self:ArmListingRefresh() end,
        },
        {
            name = GetString(SI_GAMEPAD_BACK_OPTION),
            keybind = "UI_SHORTCUT_NEGATIVE",
            callback = function() SCENE_MANAGER:HideCurrentScene() end,
        },
    }

    self.q1Keybinds = self.salesQ1Keybinds

    self.historyKeybinds = {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
        {
            name = "Previous Page",
            keybind = "UI_SHORTCUT_LEFT_SHOULDER",
            callback = function() self:ChangeSalesPage(-1) end,
        },
        {
            name = "Next Page",
            keybind = "UI_SHORTCUT_RIGHT_SHOULDER",
            callback = function() self:ChangeSalesPage(1) end,
        },
        {
            name = GetString(SI_GAMEPAD_PAGED_LIST_PAGE_LEFT_NARRATION),
            keybind = "UI_SHORTCUT_LEFT_TRIGGER",
            ethereal = true,
            enabled = function() return self.historyList.currentPage > 1 end,
            callback = function() self.historyList:ShowPreviousPage() end,
        },
        {
            name = GetString(SI_GAMEPAD_PAGED_LIST_PAGE_RIGHT_NARRATION),
            keybind = "UI_SHORTCUT_RIGHT_TRIGGER",
            ethereal = true,
            enabled = function() return self.historyList.hasNextPage end,
            callback = function() self.historyList:ShowNextPage() end,
        },
    }
    ZO_Gamepad_AddBackNavigationKeybindDescriptorsWithSound(
        self.historyKeybinds,
        GAME_NAVIGATION_TYPE_BUTTON,
        function() self:FocusQ1() end
    )

    self.listedKeybinds = {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
        {
            name = "Previous Guild",
            keybind = "UI_SHORTCUT_LEFT_SHOULDER",
            enabled = function() return #self:GetListedGuilds() > 1 end,
            callback = function() self:ChangeListedGuild(-1) end,
        },
        {
            name = "Next Guild",
            keybind = "UI_SHORTCUT_RIGHT_SHOULDER",
            enabled = function() return #self:GetListedGuilds() > 1 end,
            callback = function() self:ChangeListedGuild(1) end,
        },
        {
            name = "Refresh Listings",
            keybind = "UI_SHORTCUT_TERTIARY",
            callback = function() self:ArmListingRefresh() end,
        },
    }
    ZO_Gamepad_AddBackNavigationKeybindDescriptorsWithSound(
        self.listedKeybinds,
        GAME_NAVIGATION_TYPE_BUTTON,
        function() self:FocusQ1() end
    )
end

function GuildSalesJournal_Gamepad:GetQ1KeybindGroupForCurrentPage()
    if self.currentQ1Page == Q1_LISTED then
        return self.listedQ1Keybinds
    end
    return self.salesQ1Keybinds
end

function GuildSalesJournal_Gamepad:RefreshQ1KeybindGroup()
    local targetGroup = self:GetQ1KeybindGroupForCurrentPage()
    if not targetGroup then return end

    local oldGroup = self.q1Keybinds
    self.q1Keybinds = targetGroup

    if not KEYBIND_STRIP or self.focusInHistory or self.focusInListed then return end

    if oldGroup and oldGroup ~= targetGroup then
        pcall(function() KEYBIND_STRIP:RemoveKeybindButtonGroup(oldGroup) end)
        KEYBIND_STRIP:AddKeybindButtonGroup(targetGroup)
    end
    KEYBIND_STRIP:UpdateKeybindButtonGroup(targetGroup)
end

function GuildSalesJournal_Gamepad:RemoveAllKeybinds()
    if not KEYBIND_STRIP then return end
    if self.salesQ1Keybinds then
        pcall(function() KEYBIND_STRIP:RemoveKeybindButtonGroup(self.salesQ1Keybinds) end)
    end
    if self.listedQ1Keybinds then
        pcall(function() KEYBIND_STRIP:RemoveKeybindButtonGroup(self.listedQ1Keybinds) end)
    end
    if self.historyKeybinds then
        pcall(function() KEYBIND_STRIP:RemoveKeybindButtonGroup(self.historyKeybinds) end)
    end
    if self.listedKeybinds then
        pcall(function() KEYBIND_STRIP:RemoveKeybindButtonGroup(self.listedKeybinds) end)
    end
end

function GuildSalesJournal_Gamepad:FocusQ1()
    self.focusInHistory = false
    self.focusInListed = false
    self:RemoveAllKeybinds()

    if self.historyList then
        self.historyList:Deactivate()
        self.historyList:RefreshFooter()
    end
    if self.listedList then
        self.listedList:Deactivate()
    end

    GAMEPAD_NAV_QUADRANT_1_BACKGROUND_FRAGMENT:TakeFocus()
    self:SetCurrentList(self.mainList)
    self.mainList:Activate()
    self.q1Keybinds = self:GetQ1KeybindGroupForCurrentPage()

    if KEYBIND_STRIP then
        KEYBIND_STRIP:AddKeybindButtonGroup(self.q1Keybinds)
        zo_callLater(function()
            if not self.focusInHistory and not self.focusInListed and self.q1Keybinds then
                KEYBIND_STRIP:UpdateKeybindButtonGroup(self.q1Keybinds)
            end
        end, 50)
    end
end

function GuildSalesJournal_Gamepad:FocusHistoryList()
    if not self.historyList or not self.historyList:HasEntries() then return end

    self.focusInHistory = true
    self.focusInListed = false
    self:RemoveAllKeybinds()

    GAMEPAD_NAV_QUADRANT_1_BACKGROUND_FRAGMENT:ClearFocus()
    self.mainList:Deactivate()
    if self.listedList then self.listedList:Deactivate() end
    self.historyList:Activate()
    self.historyList:RefreshFooter()

    if KEYBIND_STRIP then
        KEYBIND_STRIP:AddKeybindButtonGroup(self.historyKeybinds)
    end
end

function GuildSalesJournal_Gamepad:FocusListedList()
    if not self.listedList or not self.listedList:HasEntries() then return end

    self.focusInHistory = false
    self.focusInListed = true
    self:RemoveAllKeybinds()

    GAMEPAD_NAV_QUADRANT_1_BACKGROUND_FRAGMENT:ClearFocus()
    self.mainList:Deactivate()
    if self.historyList then self.historyList:Deactivate() end
    self.listedList:Activate()

    if KEYBIND_STRIP then
        KEYBIND_STRIP:AddKeybindButtonGroup(self.listedKeybinds)
    end
end

function GuildSalesJournal_Gamepad:PerformUpdate()
    self.dirty = false
end

function GuildSalesJournal_Gamepad:Refresh()
    if not self.mainList then return end
    self:RefreshQ1List()
    self:ShowQ1Page(self.currentQ1Page or Q1_SALES)
end

function Journal:Refresh()
    if Journal.screen and Journal.screen.Refresh then
        Journal.screen:Refresh()
    end
end

function Journal:Initialize()
    if Journal.initialized then return end
    Journal.initialized = true

    local control = GuildSalesJournalGamepad
    if not control then
        GSJ:Message("Journal root control was not created.")
        return
    end

    Journal.screen = GuildSalesJournal_Gamepad:New(control)

    if not AddToJournalMenu() then
        EVENT_MANAGER:RegisterForEvent("GuildSalesJournal_Menu", EVENT_PLAYER_ACTIVATED, function()
            if AddToJournalMenu() then
                EVENT_MANAGER:UnregisterForEvent("GuildSalesJournal_Menu", EVENT_PLAYER_ACTIVATED)
            end
        end)
    end
end
