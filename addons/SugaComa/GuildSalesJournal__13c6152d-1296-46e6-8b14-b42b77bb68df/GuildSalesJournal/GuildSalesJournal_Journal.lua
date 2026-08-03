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

local SALES_PAGE_LEDGER = 0
local SALES_PAGE_ALL = 1
local SALES_PAGE_FIRST_GUILD = 2
local SALES_PAGE_LAST_GUILD = 6
local SALES_PAGE_COUNT = 7

local HISTORY_DATA_TYPE = 1
local ROW_HEIGHT = 70
local ENTRIES_PER_PAGE = 100

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
    self.sessionStartedAt = GetTimeStamp and GetTimeStamp() or 0
    self.sessionTransactions = {}
    self.lastKnownTotal = nil
    self.currencyRefreshToken = 0

    self:ApplyContentFrameAnchors()

    self.fragment = ZO_FadeSceneFragment:New(control)
    self.fragment:RegisterCallback("StateChange", function(_, newState)
        if newState == SCENE_FRAGMENT_SHOWING then
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
            self:RemoveAllKeybinds()
            if self.historyList then self.historyList:Deactivate() end
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
    local outer = self.ledgerPage:GetNamedChild("OuterCard")
    outer:ClearAnchors(); outer:SetAnchor(TOPLEFT,self.ledgerPage,TOPLEFT,10,106); outer:SetDimensions(contentWidth-20,contentHeight-122)

    local balancesHeading=self.ledgerPage:GetNamedChild("BalancesHeading")
    balancesHeading:ClearAnchors(); balancesHeading:SetAnchor(TOP,outer,TOP,0,12); balancesHeading:SetDimensions(contentWidth-70,42)
    local balancesCard=self.ledgerPage:GetNamedChild("BalancesCard")
    balancesCard:ClearAnchors(); balancesCard:SetAnchor(TOPLEFT,outer,TOPLEFT,30,56); balancesCard:SetDimensions(contentWidth-80,122)

    local col=(contentWidth-80)/3
    local function placeTop(name,index,y,h)
        local c=self.ledgerPage:GetNamedChild(name); c:ClearAnchors(); c:SetAnchor(TOPLEFT,balancesCard,TOPLEFT,(index-1)*col,y); c:SetDimensions(col,h)
    end
    placeTop("BankLabel",1,8,34); placeTop("CharacterLabel",2,8,34); placeTop("TotalLabel",3,8,34)
    placeTop("BankValue",1,42,66); placeTop("CharacterValue",2,42,66); placeTop("TotalValue",3,42,66)

    local sessionHeading=self.ledgerPage:GetNamedChild("SessionHeading")
    sessionHeading:ClearAnchors(); sessionHeading:SetAnchor(TOP,balancesCard,BOTTOM,0,20); sessionHeading:SetDimensions(contentWidth-70,42)
    local sessionCard=self.ledgerPage:GetNamedChild("SessionCard")
    sessionCard:ClearAnchors(); sessionCard:SetAnchor(TOPLEFT,outer,TOPLEFT,55,242); sessionCard:SetDimensions(contentWidth-130,270)

    local scol=(contentWidth-130)/3
    local function placeSession(name,index,y,h)
        local c=self.ledgerPage:GetNamedChild(name); c:ClearAnchors(); c:SetAnchor(TOPLEFT,sessionCard,TOPLEFT,(index-1)*scol,y); c:SetDimensions(scol,h)
    end
    placeSession("EarnedHeader",1,10,38); placeSession("SpentHeader",2,10,38); placeSession("BalanceHeader",3,10,38)
    placeSession("Row1Earned",1,62,72); placeSession("Row1Spent",2,62,72); placeSession("Row1Balance",3,62,72)
    placeSession("Row2Earned",1,145,72); placeSession("Row2Spent",2,145,72); placeSession("Row2Balance",3,145,72)

    local footer=self.ledgerPage:GetNamedChild("FooterCard")
    footer:ClearAnchors(); footer:SetAnchor(BOTTOMLEFT,outer,BOTTOMLEFT,30,-20); footer:SetDimensions(contentWidth-80,72)
    local sessionTime=self.ledgerPage:GetNamedChild("SessionTimeLabel")
    sessionTime:ClearAnchors(); sessionTime:SetAnchor(LEFT,footer,LEFT,22,0); sessionTime:SetDimensions((contentWidth-120)*0.48,54)
    local profitLoss=self.ledgerPage:GetNamedChild("ProfitLossLabel")
    profitLoss:ClearAnchors(); profitLoss:SetAnchor(RIGHT,footer,RIGHT,-22,0); profitLoss:SetDimensions((contentWidth-120)*0.48,54)

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
    local listedCard = self.listedPage:GetNamedChild("Card")
    local listedBody = self.listedPage:GetNamedChild("Body")
    listedCard:ClearAnchors()
    listedCard:SetAnchor(TOPLEFT, self.listedPage, TOPLEFT, 10, 112)
    listedCard:SetDimensions(contentWidth - 20, 440)
    listedBody:ClearAnchors()
    listedBody:SetAnchor(TOPLEFT, listedCard, TOPLEFT, 28, 28)
    listedBody:SetDimensions(contentWidth - 76, 380)
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

    if self.currentQ1Page == Q1_LISTED then
        self:RefreshListedPage()
    else
        self:RefreshSalesPage()
    end
end

function GuildSalesJournal_Gamepad:RefreshSalesPage()
    if self.salesPageIndex == SALES_PAGE_LEDGER then
        self.historyPage:SetHidden(true)
        self.listedPage:SetHidden(true)
        self.ledgerPage:SetHidden(false)
        self:RefreshLedgerHoldingPage()
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

function GuildSalesJournal_Gamepad:StartSessionTracking()
    local _, _, total = self:GetGoldBalances()
    if self.lastKnownTotal == nil then
        self.lastKnownTotal = total
        self.sessionStartTotal = total
    end

    EVENT_MANAGER:UnregisterForEvent("PFJ_Currency", EVENT_CURRENCY_UPDATE)
    EVENT_MANAGER:RegisterForEvent("PFJ_Currency", EVENT_CURRENCY_UPDATE, function()
        self.currencyRefreshToken = self.currencyRefreshToken + 1
        local token = self.currencyRefreshToken
        zo_callLater(function()
            if token ~= self.currencyRefreshToken then return end
            self:CaptureCurrencyChange()
        end, 180)
    end)

    EVENT_MANAGER:UnregisterForUpdate("PFJ_SessionClock")
    EVENT_MANAGER:RegisterForUpdate("PFJ_SessionClock", 1000, function()
        if self.salesPageIndex == SALES_PAGE_LEDGER and self.currentQ1Page == Q1_SALES then
            self:RefreshLedgerHoldingPage()
        end
    end)
end

function GuildSalesJournal_Gamepad:CaptureCurrencyChange()
    local _, _, total = self:GetGoldBalances()
    if self.lastKnownTotal == nil then
        self.lastKnownTotal = total
        self.sessionStartTotal = total
        return
    end
    local delta = total - self.lastKnownTotal
    if delta ~= 0 then
        table.insert(self.sessionTransactions, 1, {
            delta = delta,
            balance = total,
            timestamp = GetTimeStamp and GetTimeStamp() or 0,
        })
        while #self.sessionTransactions > 20 do
            table.remove(self.sessionTransactions)
        end
        self.lastKnownTotal = total
        if self.salesPageIndex == SALES_PAGE_LEDGER and self.currentQ1Page == Q1_SALES then
            self:RefreshLedgerHoldingPage()
        end
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

function GuildSalesJournal_Gamepad:SetLedgerTransactionRow(rowNumber, transaction, fallbackBalance)
    local earned = self.ledgerPage:GetNamedChild("Row" .. rowNumber .. "Earned")
    local spent = self.ledgerPage:GetNamedChild("Row" .. rowNumber .. "Spent")
    local balance = self.ledgerPage:GetNamedChild("Row" .. rowNumber .. "Balance")
    earned:SetText("")
    spent:SetText("")
    balance:SetText(FormatNumber(transaction and transaction.balance or fallbackBalance))
    if transaction then
        if transaction.delta > 0 then
            earned:SetText("|c78D878+" .. FormatNumber(transaction.delta) .. " ↑|r")
        else
            spent:SetText("|cC56B6B-" .. FormatNumber(math.abs(transaction.delta)) .. " ↓|r")
        end
    end
end

function GuildSalesJournal_Gamepad:RefreshLedgerHoldingPage()
    local bank, character, total = self:GetGoldBalances()
    if self.lastKnownTotal == nil then
        self.lastKnownTotal = total
        self.sessionStartTotal = total
    end

    self.ledgerPage:GetNamedChild("Title"):SetText("Sales Ledger")
    self.ledgerPage:GetNamedChild("Subtitle"):SetText("Current balances and session movement")

    local coin = " |t30:30:EsoUI/Art/Currency/currency_gold.dds|t"
    self.ledgerPage:GetNamedChild("BankValue"):SetText(FormatNumber(bank) .. coin)
    self.ledgerPage:GetNamedChild("CharacterValue"):SetText(FormatNumber(character) .. coin)
    self.ledgerPage:GetNamedChild("TotalValue"):SetText(FormatNumber(total) .. coin)

    self:SetLedgerTransactionRow(1, self.sessionTransactions[2], self.sessionStartTotal or total)
    self:SetLedgerTransactionRow(2, self.sessionTransactions[1], total)

    local profitLoss = total - (self.sessionStartTotal or total)
    local colour = profitLoss > 0 and "|c78D878+" or (profitLoss < 0 and "|cC56B6B" or "|cB8B8B8")
    local sign = profitLoss > 0 and "" or ""
    self.ledgerPage:GetNamedChild("SessionTimeLabel"):SetText("|t28:28:EsoUI/Art/Miscellaneous/timer_32.dds|t  SESSION TIME  " .. self:FormatSessionTime())
    self.ledgerPage:GetNamedChild("ProfitLossLabel"):SetText("TOTAL PROFIT/LOSS  " .. colour .. sign .. FormatNumber(profitLoss) .. "|r" .. coin)
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

function GuildSalesJournal_Gamepad:RefreshListedPage()
    self.ledgerPage:SetHidden(true)
    self.historyPage:SetHidden(true)
    self.listedPage:SetHidden(false)

    self.listedPage:GetNamedChild("Title"):SetText("Listed Items")
    self.listedPage:GetNamedChild("Subtitle"):SetText("Active guild-store listings and expiry tracking")
    self.listedPage:GetNamedChild("Body"):SetText(table.concat({
        "|cD8C37AData source not connected in this build.|r",
        "",
        "This page remains reserved while the correct Trading House source and capture flow are confirmed.",
    }, "\n"))
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

function GuildSalesJournal_Gamepad:InitializeKeybindDescriptors()
    self.q1Keybinds = {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
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
end

function GuildSalesJournal_Gamepad:RemoveAllKeybinds()
    if not KEYBIND_STRIP then return end
    if self.q1Keybinds then
        pcall(function() KEYBIND_STRIP:RemoveKeybindButtonGroup(self.q1Keybinds) end)
    end
    if self.historyKeybinds then
        pcall(function() KEYBIND_STRIP:RemoveKeybindButtonGroup(self.historyKeybinds) end)
    end
end

function GuildSalesJournal_Gamepad:FocusQ1()
    self.focusInHistory = false
    self:RemoveAllKeybinds()

    if self.historyList then
        self.historyList:Deactivate()
        self.historyList:RefreshFooter()
    end

    GAMEPAD_NAV_QUADRANT_1_BACKGROUND_FRAGMENT:TakeFocus()
    self:SetCurrentList(self.mainList)
    self.mainList:Activate()

    if KEYBIND_STRIP then
        KEYBIND_STRIP:AddKeybindButtonGroup(self.q1Keybinds)
    end
end

function GuildSalesJournal_Gamepad:FocusHistoryList()
    if not self.historyList or not self.historyList:HasEntries() then return end

    self.focusInHistory = true
    self:RemoveAllKeybinds()

    GAMEPAD_NAV_QUADRANT_1_BACKGROUND_FRAGMENT:ClearFocus()
    self.mainList:Deactivate()
    self.historyList:Activate()
    self.historyList:RefreshFooter()

    if KEYBIND_STRIP then
        KEYBIND_STRIP:AddKeybindButtonGroup(self.historyKeybinds)
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
