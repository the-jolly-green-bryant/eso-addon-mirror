--[[
=============================================================================
 AuctionHouse - UI
 All EditBox controls created in Lua to avoid XML mouse interaction issues.
=============================================================================
]]--

local AH = AuctionHouse
local Utils = AH.Utils
local SE = AH.SearchEngine
local DM = AH.DataManager

AH.UI = {}
local UI = AH.UI

local resultRowType = 1
local currentResults = {}
local columnHeaders = {}
local selectedListing = nil
local selectedRow = nil
local activeTab = "browse"

local function C(name) return GetControl(name) end

-- Column definitions computed from AH.SortColumns
local COL_DEFS = nil
local function GetColumnDefs()
    if COL_DEFS then return COL_DEFS end
    COL_DEFS = {}
    local x = 40
    for _, col in ipairs(AH.SortColumns) do
        table.insert(COL_DEFS, {
            key = col.key, header = col.header, width = col.width, offsetX = x,
            align = (col.key == "unitPrice" or col.key == "totalPrice") and TEXT_ALIGN_RIGHT
                    or (col.key == "quantity" or col.key == "level" or col.key == "timeRemaining") and TEXT_ALIGN_CENTER
                    or TEXT_ALIGN_LEFT,
        })
        x = x + col.width
    end
    return COL_DEFS
end

---------------------------------------------------------------------------
--  Helper: Create an EditBox in Lua with backdrop
---------------------------------------------------------------------------

local function CreateEditBox(name, parent, x, y, w, h, font, defaultText, maxChars)
    -- Backdrop
    local bg = WINDOW_MANAGER:CreateControl(name .. "BG", parent, CT_BACKDROP)
    bg:SetDimensions(w, h)
    bg:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)
    bg:SetCenterColor(0, 0, 0, 0.8)
    bg:SetEdgeColor(0.4, 0.4, 0.4, 1)
    bg:SetEdgeTexture("", 1, 1, 1)

    -- EditBox
    local edit = WINDOW_MANAGER:CreateControlFromVirtual(name, parent, "ZO_DefaultEditForBackdrop")
    edit:SetAnchor(TOPLEFT, bg, TOPLEFT, 4, 2)
    edit:SetAnchor(BOTTOMRIGHT, bg, BOTTOMRIGHT, -4, -2)
    edit:SetFont(font or "ZoFontGame")
    edit:SetMaxInputChars(maxChars or 100)
    if defaultText then
        ZO_EditDefaultText_Initialize(edit, defaultText)
    end

    return edit, bg
end

---------------------------------------------------------------------------
--  Initialization
---------------------------------------------------------------------------

function UI.Initialize()
    Utils.Debug("UI: Initializing")

    local window = C("AuctionHouseWindow")
    if not window then Utils.PrintError("UI: Window not found!") return end
    UI.window = window

    local closeBtn = C("AuctionHouseWindowTitleBarClose")
    if closeBtn then
        closeBtn:SetHandler("OnClicked", function() UI.Hide() end)
        closeBtn:SetHandler("OnMouseEnter", function(self)
            ZO_Tooltips_ShowTextTooltip(self, BOTTOM, "Close Auction House")
        end)
        closeBtn:SetHandler("OnMouseExit", function() ZO_Tooltips_HideTextTooltip() end)
    end

    -- Refresh button
    local refreshBtn = C("AuctionHouseWindowStatusBarRefreshBtn")
    if refreshBtn then
        refreshBtn:SetHandler("OnClicked", function()
            -- Turn off batch mode if active
            local LM = AH.ListingManager
            if LM and LM.batchMode then
                LM.SetBatchMode(false)
                if UI.batchBtn then
                    UI.batchBtn:SetText("Batch Buy/Sell")
                    UI.batchBtn:SetNormalFontColor(1, 1, 1, 1)
                end
            end
            Utils.Print("Refreshing auction data...")
            ReloadUI("ingame")
        end)
        refreshBtn:SetHandler("OnMouseEnter", function(self)
            ZO_Tooltips_ShowTextTooltip(self, TOP,
                "Reloads the UI to fetch the latest\nlisting data from the server.\n\nAlso disables Batch mode if active.")
        end)
        refreshBtn:SetHandler("OnMouseExit", function()
            ZO_Tooltips_HideTextTooltip()
        end)
    end

    -- Help button
    local helpBtn = C("AuctionHouseWindowStatusBarHelpBtn")
    if helpBtn then
        helpBtn:SetHandler("OnClicked", function() UI.ShowHelp() end)
        helpBtn:SetHandler("OnMouseEnter", function(self)
            ZO_Tooltips_ShowTextTooltip(self, TOP, "Show help and keybinds")
        end)
        helpBtn:SetHandler("OnMouseExit", function() ZO_Tooltips_HideTextTooltip() end)
    end

    UI.SetupTabBar()
    UI.CreateSearchBar()
    UI.CreateFilterBar()
    UI.SetupColumnHeaders()
    UI.SetupScrollList()
    UI.SetupActionBar()
    UI.RestoreWindowState()
    UI.RegisterCallbacks()

    local titleBar = C("AuctionHouseWindowTitleBar")
    if titleBar then
        titleBar:SetHandler("OnMouseDown", function() window:StartMoving() end)
        titleBar:SetHandler("OnMouseUp", function()
            window:StopMovingOrResizing()
            UI.SaveWindowState()
        end)
    end
    window:SetHandler("OnResizeStop", function() UI.SaveWindowState() end)

    EVENT_MANAGER:RegisterForUpdate(AH.name .. "_GoldUpdate", 5000, function()
        if UI.IsVisible() then UI.UpdateGoldDisplay() end
    end)

    Utils.Debug("UI: Initialized")
end

---------------------------------------------------------------------------
--  Show / Hide / Toggle
---------------------------------------------------------------------------

function UI.Show()
    local w = C("AuctionHouseWindow")
    if w then
        w:SetHidden(false)
        UI.UpdateGoldDisplay()
        UI.RefreshStatusBar()
        UI.SwitchTab(activeTab)
        SetGameCameraUIMode(true)
    end
end

function UI.Hide()
    local w = C("AuctionHouseWindow")
    if w then w:SetHidden(true) UI.SaveWindowState() end
end

function UI.Toggle()
    local w = C("AuctionHouseWindow")
    if w and w:IsHidden() then UI.Show() else UI.Hide() end
end

function UI.IsVisible()
    local w = C("AuctionHouseWindow")
    return w and not w:IsHidden()
end

---------------------------------------------------------------------------
--  Tab Bar
---------------------------------------------------------------------------

function UI.SetupTabBar()
    local tabs = {
        { ctrl = "AuctionHouseWindowTabBarBrowseTab",     id = "browse",
          tip = "Browse all active listings on the market" },
        { ctrl = "AuctionHouseWindowTabBarMyListingsTab", id = "mylistings",
          tip = "View and manage your active listings" },
        { ctrl = "AuctionHouseWindowTabBarPurchasesTab",  id = "purchases",
          tip = "Track items you've purchased" },
        { ctrl = "AuctionHouseWindowTabBarCODQueueTab",   id = "codqueue",
          tip = "Send COD mails for items you've sold" },
        { ctrl = "AuctionHouseWindowTabBarWatchlistTab",  id = "watchlist",
          tip = "Items you're watching — get notified when listed" },
        { ctrl = "AuctionHouseWindowTabBarDealsTab",      id = "deals",
          tip = "Items listed below market average — great deals!" },
        { ctrl = "AuctionHouseWindowTabBarHistoryTab",    id = "history",
          tip = "Your sale & purchase history with 7-day stats" },
    }
    for _, t in ipairs(tabs) do
        local btn = C(t.ctrl)
        if btn then
            btn:SetHandler("OnClicked", function() UI.SwitchTab(t.id) end)
            btn:SetHandler("OnMouseEnter", function(self)
                ZO_Tooltips_ShowTextTooltip(self, BOTTOM, t.tip)
            end)
            btn:SetHandler("OnMouseExit", function() ZO_Tooltips_HideTextTooltip() end)
        end
    end
end

function UI.SwitchTab(tabName)
    activeTab = tabName
    selectedListing = nil
    selectedRow = nil

    local tabButtons = {
        { ctrl = "AuctionHouseWindowTabBarBrowseTab",     id = "browse" },
        { ctrl = "AuctionHouseWindowTabBarMyListingsTab", id = "mylistings" },
        { ctrl = "AuctionHouseWindowTabBarPurchasesTab",  id = "purchases" },
        { ctrl = "AuctionHouseWindowTabBarCODQueueTab",   id = "codqueue" },
        { ctrl = "AuctionHouseWindowTabBarWatchlistTab",  id = "watchlist" },
        { ctrl = "AuctionHouseWindowTabBarDealsTab",      id = "deals" },
        { ctrl = "AuctionHouseWindowTabBarHistoryTab",    id = "history" },
    }
    for _, t in ipairs(tabButtons) do
        local btn = C(t.ctrl)
        if btn then btn:SetFont(t.id == tabName and "ZoFontGameBold" or "ZoFontGame") end
    end

    local searchBar = C("AuctionHouseWindowSearchBar")
    local filterBar = C("AuctionHouseWindowFilterBar")
    if searchBar then searchBar:SetHidden(tabName ~= "browse" and tabName ~= "storefront") end
    if filterBar then filterBar:SetHidden(tabName ~= "browse") end

    UI.UpdateActionBarForTab(tabName)
    UI.UpdateHeadersForTab(tabName)

    if tabName == "browse" then UI.ExecuteSearch()
    elseif tabName == "mylistings" then UI.ShowMyListings()
    elseif tabName == "purchases" then UI.ShowPurchases()
    elseif tabName == "codqueue" then UI.ShowCODQueue()
    elseif tabName == "watchlist" then UI.ShowWatchlist()
    elseif tabName == "deals" then UI.ShowDeals()
    elseif tabName == "history" then UI.ShowSaleHistory()
    end
end

function UI.UpdateActionBarForTab(tabName)
    local buyBtn  = C("AuctionHouseWindowActionBarBuyBtn")
    local linkBtn = C("AuctionHouseWindowActionBarLinkBtn")
    if tabName == "browse" then
        if buyBtn then buyBtn:SetText("Buy Selected") buyBtn:SetHidden(false) end
        if linkBtn then linkBtn:SetHidden(false) end
    elseif tabName == "mylistings" then
        if buyBtn then buyBtn:SetText("Cancel Selected") buyBtn:SetHidden(false) end
        if linkBtn then linkBtn:SetText("Relist") linkBtn:SetHidden(false) end
    elseif tabName == "codqueue" then
        if buyBtn then buyBtn:SetText("Send COD") buyBtn:SetHidden(false) end
        if linkBtn then linkBtn:SetText("Release") linkBtn:SetHidden(false) end
    elseif tabName == "purchases" then
        if buyBtn then buyBtn:SetText("Cancel Purchase") buyBtn:SetHidden(false) end
        if linkBtn then linkBtn:SetHidden(false) end
    elseif tabName == "watchlist" then
        if buyBtn then buyBtn:SetText("Remove Watch") buyBtn:SetHidden(false) end
        if linkBtn then linkBtn:SetText("Set Max Price") linkBtn:SetHidden(false) end
    elseif tabName == "deals" then
        if buyBtn then buyBtn:SetText("Buy Selected") buyBtn:SetHidden(false) end
        if linkBtn then linkBtn:SetText("Watch Item") linkBtn:SetHidden(false) end
    elseif tabName == "history" then
        if buyBtn then buyBtn:SetText("Relist") buyBtn:SetHidden(false) end
        if linkBtn then linkBtn:SetHidden(true) end
    elseif tabName == "storefront" then
        if buyBtn then buyBtn:SetText("Buy Selected") buyBtn:SetHidden(false) end
        if linkBtn then linkBtn:SetText("Trust Seller") linkBtn:SetHidden(false) end
    else
        if buyBtn then buyBtn:SetHidden(true) end
        if linkBtn then linkBtn:SetHidden(true) end
    end
end

---------------------------------------------------------------------------
--  Create Search Bar (all in Lua)
---------------------------------------------------------------------------

function UI.CreateSearchBar()
    local parent = C("AuctionHouseWindowSearchBar")
    if not parent then return end

    -- Search input
    UI.searchInput = CreateEditBox("AH_SearchInput", parent, 0, 6, 450, 32,
        "ZoFontGame", "Search items...", 100)

    UI.searchInput:SetHandler("OnEnter", function()
        if activeTab == "browse" then UI.ExecuteSearch() end
    end)

    local debouncedSearch = Utils.Debounce(function()
        if activeTab == "browse" then UI.ExecuteSearch() end
    end, AH.UIConfig.SEARCH_DEBOUNCE)
    UI.searchInput:SetHandler("OnTextChanged", function() debouncedSearch() end)

    -- Category dropdown
    local catDD = WINDOW_MANAGER:CreateControlFromVirtual("AH_CategoryDD", parent, "ZO_ComboBox")
    catDD:SetDimensions(180, 32)
    catDD:SetAnchor(LEFT, C("AH_SearchInputBG"), RIGHT, 8, 0)
    UI.categoryDropdown = ZO_ComboBox_ObjectFromContainer(catDD)
    if UI.categoryDropdown then
        UI.categoryDropdown:ClearItems()
        for i, category in ipairs(AH.CategoryFilters) do
            local entry = UI.categoryDropdown:CreateItemEntry(category.name, function()
                AH.savedVars.ui.filters.category = i
                if SE then SE.InvalidateCache() end
                if activeTab == "browse" then UI.ExecuteSearch() end
            end)
            UI.categoryDropdown:AddItem(entry)
        end
        UI.categoryDropdown:SelectFirstItem()
    end

    -- Search button
    local searchBtn = WINDOW_MANAGER:CreateControl("AH_SearchGoBtn", parent, CT_BUTTON)
    searchBtn:SetDimensions(100, 32)
    searchBtn:SetAnchor(LEFT, catDD, RIGHT, 8, 0)
    searchBtn:SetFont("ZoFontGameBold")
    searchBtn:SetText("Search")
    searchBtn:SetNormalTexture("EsoUI/Art/Buttons/positiveButton_up.dds")
    searchBtn:SetPressedTexture("EsoUI/Art/Buttons/positiveButton_down.dds")
    searchBtn:SetMouseOverTexture("EsoUI/Art/Buttons/positiveButton_over.dds")
    searchBtn:SetClickSound(SOUNDS.DEFAULT_CLICK)
    searchBtn:SetHandler("OnClicked", function()
        if activeTab == "browse" then UI.ExecuteSearch() end
    end)
    searchBtn:SetHandler("OnMouseEnter", function(self)
        ZO_Tooltips_ShowTextTooltip(self, BOTTOM, "Search listings by name and filters")
    end)
    searchBtn:SetHandler("OnMouseExit", function() ZO_Tooltips_HideTextTooltip() end)
end

---------------------------------------------------------------------------
--  Create Filter Bar (all in Lua)
---------------------------------------------------------------------------

function UI.CreateFilterBar()
    local parent = C("AuctionHouseWindowFilterBar")
    if not parent then return end

    local offsetX = 0

    -- Quality dropdown
    local qualDD = WINDOW_MANAGER:CreateControlFromVirtual("AH_QualityDD", parent, "ZO_ComboBox")
    qualDD:SetDimensions(140, 28)
    qualDD:SetAnchor(LEFT, parent, LEFT, offsetX, 0)
    UI.qualityDropdown = ZO_ComboBox_ObjectFromContainer(qualDD)
    if UI.qualityDropdown then
        UI.qualityDropdown:ClearItems()
        local allQualEntry = UI.qualityDropdown:CreateItemEntry("All Qualities", function()
            AH.savedVars.ui.filters.quality = -1
            if SE then SE.InvalidateCache() end
            UI.ExecuteSearch()
        end)
        UI.qualityDropdown:AddItem(allQualEntry)
        -- Add qualities in sorted order
        local sortedQualities = {}
        for quality, name in pairs(AH.QualityNames) do
            table.insert(sortedQualities, { quality = quality, name = name })
        end
        table.sort(sortedQualities, function(a, b) return a.quality < b.quality end)
        for _, entry in ipairs(sortedQualities) do
            local color = AH.QualityColors[entry.quality] or "FFFFFF"
            UI.qualityDropdown:AddItem(UI.qualityDropdown:CreateItemEntry(
                Utils.Colorize(entry.name, color), function()
                    AH.savedVars.ui.filters.quality = entry.quality
                    if SE then SE.InvalidateCache() end
                    UI.ExecuteSearch()
                end))
        end
        -- Force "All Qualities" as the selected item
        UI.qualityDropdown:SelectItem(allQualEntry)
        AH.savedVars.ui.filters.quality = -1
    end
    offsetX = 140 + 12

    -- Level label
    local lvlLabel = WINDOW_MANAGER:CreateControl("AH_LvlLabel", parent, CT_LABEL)
    lvlLabel:SetFont("ZoFontGameSmall")
    lvlLabel:SetText("Level:")
    lvlLabel:SetColor(0.8, 0.8, 0.8, 1)
    lvlLabel:SetAnchor(LEFT, parent, LEFT, offsetX, 0)
    offsetX = offsetX + 40

    -- Level min
    UI.levelMinInput = CreateEditBox("AH_LvlMin", parent, offsetX, 3, 45, 28,
        "ZoFontGameSmall", "0", 3)
    UI.levelMinInput:SetHandler("OnEnter", function() UI.ApplyFilters() end)
    offsetX = offsetX + 45 + 4

    local dash1 = WINDOW_MANAGER:CreateControl("AH_LvlDash", parent, CT_LABEL)
    dash1:SetFont("ZoFontGameSmall"); dash1:SetText("-"); dash1:SetColor(0.8,0.8,0.8,1)
    dash1:SetAnchor(LEFT, parent, LEFT, offsetX, 0)
    offsetX = offsetX + 10

    -- Level max
    UI.levelMaxInput = CreateEditBox("AH_LvlMax", parent, offsetX, 3, 45, 28,
        "ZoFontGameSmall", "50", 3)
    UI.levelMaxInput:SetHandler("OnEnter", function() UI.ApplyFilters() end)
    offsetX = offsetX + 45 + 16

    -- Price label
    local prcLabel = WINDOW_MANAGER:CreateControl("AH_PrcLabel", parent, CT_LABEL)
    prcLabel:SetFont("ZoFontGameSmall"); prcLabel:SetText("Price:"); prcLabel:SetColor(0.8,0.8,0.8,1)
    prcLabel:SetAnchor(LEFT, parent, LEFT, offsetX, 0)
    offsetX = offsetX + 40

    -- Price min
    UI.priceMinInput = CreateEditBox("AH_PrcMin", parent, offsetX, 3, 70, 28,
        "ZoFontGameSmall", "0", 10)
    UI.priceMinInput:SetHandler("OnEnter", function() UI.ApplyFilters() end)
    offsetX = offsetX + 70 + 4

    local dash2 = WINDOW_MANAGER:CreateControl("AH_PrcDash", parent, CT_LABEL)
    dash2:SetFont("ZoFontGameSmall"); dash2:SetText("-"); dash2:SetColor(0.8,0.8,0.8,1)
    dash2:SetAnchor(LEFT, parent, LEFT, offsetX, 0)
    offsetX = offsetX + 10

    -- Price max
    UI.priceMaxInput = CreateEditBox("AH_PrcMax", parent, offsetX, 3, 70, 28,
        "ZoFontGameSmall", "Max", 10)
    UI.priceMaxInput:SetHandler("OnEnter", function() UI.ApplyFilters() end)
    offsetX = offsetX + 70 + 12

    -- Reset button
    local resetBtn = WINDOW_MANAGER:CreateControl("AH_ResetBtn", parent, CT_BUTTON)
    resetBtn:SetDimensions(60, 28)
    resetBtn:SetAnchor(LEFT, parent, LEFT, offsetX, 0)
    resetBtn:SetFont("ZoFontGameSmall"); resetBtn:SetText("Reset")
    resetBtn:SetNormalTexture("EsoUI/Art/Buttons/decline_up.dds")
    resetBtn:SetPressedTexture("EsoUI/Art/Buttons/decline_down.dds")
    resetBtn:SetMouseOverTexture("EsoUI/Art/Buttons/decline_over.dds")
    resetBtn:SetClickSound(SOUNDS.DEFAULT_CLICK)
    resetBtn:SetHandler("OnClicked", function() UI.ResetFilters() end)
    resetBtn:SetHandler("OnMouseEnter", function(self)
        ZO_Tooltips_ShowTextTooltip(self, BOTTOM, "Clear all search filters")
    end)
    resetBtn:SetHandler("OnMouseExit", function() ZO_Tooltips_HideTextTooltip() end)
end

---------------------------------------------------------------------------
--  Filters
---------------------------------------------------------------------------

function UI.ApplyFilters()
    local f = AH.savedVars.ui.filters
    if UI.levelMinInput then f.levelMin = tonumber(UI.levelMinInput:GetText()) or 0 end
    if UI.levelMaxInput then f.levelMax = tonumber(UI.levelMaxInput:GetText()) or 0 end
    if UI.priceMinInput then f.priceMin = tonumber(UI.priceMinInput:GetText()) or 0 end
    if UI.priceMaxInput then
        local t = UI.priceMaxInput:GetText()
        f.priceMax = (t == "" or t == "Max") and 0 or (tonumber(t) or 0)
    end
    if SE then SE.InvalidateCache() end
    UI.ExecuteSearch()
end

function UI.ResetFilters()
    local f = AH.savedVars.ui.filters
    f.quality = -1; f.levelMin = 0; f.levelMax = 0; f.priceMin = 0; f.priceMax = 0
    if UI.levelMinInput then UI.levelMinInput:SetText("") end
    if UI.levelMaxInput then UI.levelMaxInput:SetText("") end
    if UI.priceMinInput then UI.priceMinInput:SetText("") end
    if UI.priceMaxInput then UI.priceMaxInput:SetText("") end
    if UI.searchInput then UI.searchInput:SetText("") end
    if UI.qualityDropdown then
        UI.qualityDropdown:SetSelectedItemText("All Qualities")
    end
    if UI.categoryDropdown then UI.categoryDropdown:SelectFirstItem() end
    if SE then SE.InvalidateCache() end
    UI.ExecuteSearch()
end

---------------------------------------------------------------------------
--  Column Headers
---------------------------------------------------------------------------

function UI.SetupColumnHeaders()
    local headersControl = C("AuctionHouseWindowHeaders")
    if not headersControl then return end
    local cols = GetColumnDefs()
    for _, col in ipairs(cols) do
        local header = WINDOW_MANAGER:CreateControl("AH_Header_" .. col.key, headersControl, CT_LABEL)
        header:SetFont("ZoFontGameSmall"); header:SetColor(0.8,0.8,0.8,1)
        header:SetDimensions(col.width, 28)
        header:SetAnchor(LEFT, headersControl, LEFT, col.offsetX, 0)
        header:SetText(col.header)
        header:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        header:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        header:SetMouseEnabled(true)
        header:SetHandler("OnMouseUp", function() UI.OnSortHeaderClicked(col.key) end)
        header:SetHandler("OnMouseEnter", function(s) s:SetColor(1, 0.84, 0, 1) end)
        header:SetHandler("OnMouseExit", function(s) s:SetColor(0.8, 0.8, 0.8, 1) end)
        columnHeaders[col.key] = header
    end
end

function UI.OnSortHeaderClicked(columnKey)
    local ui = AH.savedVars.ui
    if ui.sortColumn == columnKey then ui.sortAscending = not ui.sortAscending
    else ui.sortColumn = columnKey; ui.sortAscending = true end
    if SE then SE.InvalidateCache() end
    UI.ExecuteSearch()
end

-- Update column headers based on active tab
function UI.UpdateHeadersForTab(tabName)
    -- All tabs use the same column headers
    for _, col in ipairs(AH.SortColumns) do
        if columnHeaders[col.key] then
            columnHeaders[col.key]:SetText(col.header)
        end
    end
end

---------------------------------------------------------------------------
--  Scroll List
---------------------------------------------------------------------------

function UI.SetupScrollList()
    local scrollList = C("AuctionHouseWindowResultsList")
    if not scrollList then return end
    UI.scrollList = scrollList
    ZO_ScrollList_AddDataType(scrollList, resultRowType,
        "AuctionHouseResultRow", AH.UIConfig.ROW_HEIGHT, UI.SetupResultRow)
    ZO_ScrollList_EnableHighlight(scrollList, "ZO_ThinListHighlight")
end

function UI.SetupResultRow(control, data)
    local listing = data.data
    local playerName = Utils.GetPlayerName()
    local cols = GetColumnDefs()
    local rowName = control:GetName()

    local icon = control:GetNamedChild("Icon")
    if icon then
        icon:SetTexture((listing.icon and listing.icon ~= "")
            and listing.icon or "EsoUI/Art/Icons/icon_missing.dds")
    end

    for _, col in ipairs(cols) do
        local labelName = rowName .. "_" .. col.key
        local label = C(labelName)
        if not label then
            label = WINDOW_MANAGER:CreateControl(labelName, control, CT_LABEL)
            label:SetDimensions(col.width, 36)
            label:SetAnchor(LEFT, control, LEFT, col.offsetX, 0)
            label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        end

        if col.key == "seller" or col.key == "timeRemaining" then
            label:SetFont("ZoFontGameSmall"); label:SetColor(0.67,0.67,0.67,1)
        else
            label:SetFont("ZoFontGame"); label:SetColor(1,1,1,1)
        end
        label:SetHorizontalAlignment(col.align)

        local text = ""
        if col.key == "name" then
            local quality = listing.quality or ITEM_DISPLAY_QUALITY_NORMAL
            local color = AH.QualityColors[quality] or AH.Colors.WHITE
            local name = listing.itemName or "Unknown"
            if listing.seller == playerName then name = name .. " (yours)" end
            -- Show discount badge for deals
            if listing.source == "deal" and listing.discountPct and listing.discountPct > 0 then
                name = name .. Utils.Colorize(
                    string.format(" -%d%%", math.floor(listing.discountPct)), AH.Colors.POSITIVE)
            end
            text = Utils.Colorize(name, color)
        elseif col.key == "unitPrice" then
            local v = listing.unitPrice
            text = (v and v > 0) and Utils.FormatGold(math.floor(v)) or ""
            -- Show discount for deals
            if listing.discountPct and listing.discountPct > 0 then
                text = text .. Utils.Colorize(string.format(" -%d%%", listing.discountPct), AH.Colors.POSITIVE)
            end
        elseif col.key == "totalPrice" then
            local v = listing.price
            text = (v and v > 0) and Utils.FormatGold(math.floor(v)) or ""
        elseif col.key == "quantity" then
            local v = listing.quantity
            text = (v and v > 0) and tostring(v) or ""
        elseif col.key == "quality" then
            local qn = AH.QualityNames[listing.quality] or ""
            local qc = AH.QualityColors[listing.quality] or AH.Colors.WHITE
            text = Utils.Colorize(qn, qc)
        elseif col.key == "level" then
            local cp = listing.championPoints or 0
            local lvl = listing.level
            if cp > 0 then text = "CP" .. tostring(cp)
            elseif lvl and lvl > 0 then text = tostring(lvl) end
        elseif col.key == "seller" then
            local sellerName = listing.seller or ""
            local isOnline = listing.sellerOnline
            local isMe = sellerName == Utils.GetPlayerName()
            -- You're always online to yourself
            if isMe then isOnline = true end

            -- On My Listings / COD Queue, show character name instead of @account
            if isMe and listing.characterName and listing.characterName ~= "" and
               (activeTab == "mylistings" or activeTab == "codqueue" or activeTab == "history") then
                text = Utils.Colorize(listing.characterName, AH.Colors.HIGHLIGHT)
            else
                local prefix = isOnline
                    and Utils.Colorize("● Online", AH.Colors.POSITIVE)
                    or  Utils.Colorize("● Offline", AH.Colors.NEUTRAL)
                -- Trusted seller badge
                local F = AH.Features
                local trustBadge = ""
                if F and F.IsTrustedSeller and F.IsTrustedSeller(sellerName) then
                    trustBadge = " " .. Utils.Colorize("[T]", "FFD700")
                end
                text = prefix .. "  " .. sellerName .. trustBadge
            end
        elseif col.key == "timeRemaining" then
            local left = 0
            if listing.expiresAt and listing.expiresAt > 0 then
                left = listing.expiresAt - Utils.GetTimestamp()
            elseif listing.timeRemaining and listing.timeRemaining > 0 then
                left = listing.timeRemaining
            end
            local States = AH.ListingManager and AH.ListingManager.States or {}
            if left > 0 then
                text = Utils.FormatDuration(left)
            elseif listing.state == (States.AWAITING_COD or "awaiting_cod") then
                text = Utils.Colorize("Awaiting COD", AH.Colors.YELLOW)
            elseif listing.state == (States.COD_SENT or "cod_sent") then
                text = Utils.Colorize("COD Sent", AH.Colors.HIGHLIGHT)
            elseif listing.state == (States.COMPLETED or "completed") then
                text = Utils.Colorize("Completed", AH.Colors.POSITIVE)
            elseif listing.state == (States.CANCELLED or "cancelled") then
                text = Utils.Colorize("Cancelled", AH.Colors.NEUTRAL)
            elseif listing.state and listing.state ~= "" and listing.state ~= "listed" then
                text = listing.state
            else
                text = Utils.Colorize("Expired", AH.Colors.NEGATIVE)
            end
        end
        label:SetText(text)
    end

    local isSelected = (selectedListing and selectedListing.id == listing.id)
    local hl = control:GetNamedChild("Highlight")
    if hl then
        if isSelected then
            hl:SetHidden(false)
            hl:SetAlpha(0.35)
            hl:SetColor(0.8, 0.7, 0.2, 1)  -- Gold tint for selected
        else
            hl:SetHidden(true)
        end
    end

    control:SetHandler("OnMouseEnter", function()
        if listing.itemLink and listing.itemLink ~= "" then
            -- Use PopupTooltip with SetLink - this is the same approach ESO's
            -- guild trading house uses, and what addons like TTC/MM hook into
            -- to append their pricing data.
            InitializeTooltip(PopupTooltip, control, RIGHT, -5, 0)
            PopupTooltip:SetLink(listing.itemLink)
        end
        if hl and not (selectedListing and selectedListing.id == listing.id) then
            hl:SetAlpha(0.15)
            hl:SetColor(1, 1, 1, 1)
            hl:SetHidden(false)
        end
    end)
    control:SetHandler("OnMouseExit", function()
        ClearTooltip(PopupTooltip)
        if hl and not (selectedListing and selectedListing.id == listing.id) then
            hl:SetHidden(true)
        end
    end)
    control:SetHandler("OnMouseUp", function(_, button, upInside)
        if not upInside then return end
        if button == MOUSE_BUTTON_INDEX_LEFT then
            UI.SelectListing(listing, control)
        elseif button == MOUSE_BUTTON_INDEX_RIGHT then UI.ShowContextMenu(listing) end
    end)
    control:SetHandler("OnMouseDoubleClick", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT and activeTab == "browse" then UI.OnActionClicked() end
    end)
end

function UI.SelectListing(listing, control)
    if selectedRow then
        local old = selectedRow:GetNamedChild("Highlight")
        if old then old:SetHidden(true); old:SetColor(1, 1, 1, 1) end
    end
    selectedListing = listing; selectedRow = control
    local hl = control:GetNamedChild("Highlight")
    if hl then
        hl:SetAlpha(0.35)
        hl:SetColor(0.8, 0.7, 0.2, 1)  -- Gold tint
        hl:SetHidden(false)
    end
end

function UI.ShowContextMenu(listing)
    ClearMenu()
    local F = AH.Features
    if listing.itemLink then
        AddMenuItem("Link in Chat", function() ZO_LinkHandler_InsertLink(listing.itemLink) end)
    end
    if activeTab == "browse" or activeTab == "deals" or activeTab == "storefront" then
        if listing.seller ~= Utils.GetPlayerName() then
            AddMenuItem("Buy", function() selectedListing = listing; UI.OnActionClicked() end)
        end
        -- Watch item by ID (not specific listing)
        if F and listing.itemId and listing.itemId ~= "" then
            if AH.savedVars.watchlist and AH.savedVars.watchlist[listing.itemId] then
                AddMenuItem("Unwatch Item", function()
                    F.WatchlistRemove(listing.itemId)
                end)
            else
                AddMenuItem("Watch Item", function()
                    F.WatchlistAdd(listing.itemName, listing.itemId, 0)
                end)
            end
        end
        -- View seller storefront
        if listing.seller and listing.seller ~= "" then
            AddMenuItem("View Seller", function()
                UI.ShowStorefront(listing.seller)
            end)
            -- Trust/untrust seller
            if F then
                if F.IsTrustedSeller(listing.seller) then
                    AddMenuItem("Untrust Seller", function()
                        F.UntrustSeller(listing.seller)
                    end)
                else
                    AddMenuItem("Trust Seller", function()
                        F.TrustSeller(listing.seller)
                    end)
                end
            end
        end
    elseif activeTab == "mylistings" then
        if listing.state == "listed" then
            AddMenuItem("Cancel", function()
                if AH.ListingManager then AH.ListingManager.CancelListing(listing.id); UI.ShowMyListings() end
            end)
        end
        if listing.state == "expired" or listing.state == "cancelled" then
            AddMenuItem("Quick Relist", function()
                if F then F.QuickRelist(listing.id); UI.ShowMyListings() end
            end)
        end
    elseif activeTab == "codqueue" then
        AddMenuItem("Send COD", function()
            if AH.ListingManager then AH.ListingManager.SendCOD(listing.listingId or listing.id) end
        end)
    elseif activeTab == "watchlist" then
        AddMenuItem("Remove from Watchlist", function()
            if F and listing.watchlistKey then F.WatchlistRemove(listing.watchlistKey); UI.ShowWatchlist() end
        end)
    elseif activeTab == "history" then
        if F and listing.itemLink then
            AddMenuItem("Quick Relist", function()
                F.QuickRelist(listing.id)
            end)
        end
    end
    ShowMenu()
end

---------------------------------------------------------------------------
--  Action Bar
---------------------------------------------------------------------------

function UI.SetupActionBar()
    local buyBtn = C("AuctionHouseWindowActionBarBuyBtn")
    if buyBtn then
        buyBtn:SetHandler("OnClicked", function() UI.OnActionClicked() end)
        buyBtn:SetHandler("OnMouseEnter", function(self)
            local tips = {
                browse = "Purchase the selected listing.\nSeller will send you a COD mail.\n\nNote: Cancelling purchases counts as\na strike. 5 strikes in 24 hours will\ntemporarily lock you out of buying.",
                mylistings = "Cancel the selected listing\nand remove it from the market.\nNo penalty for cancelling your own listings.",
                codqueue = "Open the mail window to send\na COD for this sale.",
                purchases = "Cancel your purchase and\nrelease the listing back.\n\nWarning: This counts as a buyer strike.",
                watchlist = "Remove the selected item\nfrom your watchlist.",
            }
            local tip = tips[activeTab] or "Perform action on selected item"
            ZO_Tooltips_ShowTextTooltip(self, TOP, tip)
        end)
        buyBtn:SetHandler("OnMouseExit", function() ZO_Tooltips_HideTextTooltip() end)
    end

    local batchBtn = C("AuctionHouseWindowActionBarBatchBtn")
    UI.batchBtn = batchBtn
    if batchBtn then
        batchBtn:SetHandler("OnClicked", function()
            local LM = AH.ListingManager
            if LM then
                LM.SetBatchMode(not LM.batchMode)
                if LM.batchMode then
                    batchBtn:SetText("Batch: ON")
                    batchBtn:SetNormalFontColor(1, 0.84, 0, 1)  -- Gold
                else
                    batchBtn:SetText("Batch Buy/Sell")
                    batchBtn:SetNormalFontColor(1, 1, 1, 1)
                end
            end
        end)
        batchBtn:SetHandler("OnMouseEnter", function(self)
            ZO_Tooltips_ShowTextTooltip(self, TOP,
                "Toggle batch mode ON/OFF.\n\nWhen ON, buying and listing items\nwill NOT auto-reload the UI.\n\nClick Refresh when you're done\nto sync everything at once.")
        end)
        batchBtn:SetHandler("OnMouseExit", function()
            ZO_Tooltips_HideTextTooltip()
        end)
    end

    local linkBtn = C("AuctionHouseWindowActionBarLinkBtn")
    if linkBtn then
        linkBtn:SetHandler("OnClicked", function()
            local F = AH.Features
            if activeTab == "codqueue" then
                -- Release button behavior
                if not selectedListing then Utils.Print("Select a listing first.") return end
                local listingId = selectedListing.listingId or selectedListing.id
                if AH.ListingManager then
                    AH.ListingManager.ReleaseListing(listingId)
                    UI.ShowCODQueue()
                end
            elseif activeTab == "mylistings" then
                -- Relist button
                if not selectedListing then Utils.Print("Select a listing first.") return end
                if F and (selectedListing.state == "expired" or selectedListing.state == "cancelled") then
                    F.QuickRelist(selectedListing.id)
                    UI.ShowMyListings()
                elseif selectedListing.itemLink then
                    ZO_LinkHandler_InsertLink(selectedListing.itemLink)
                end
            elseif activeTab == "watchlist" then
                -- Set max price dialog (simple chat prompt)
                if not selectedListing or not selectedListing.watchlistKey then
                    Utils.Print("Select a watchlist item first.")
                    return
                end
                Utils.Print("Set max price with: /ah watch %s",
                    selectedListing.itemName or "item name")
            elseif activeTab == "deals" or activeTab == "browse" then
                -- Watch item
                if selectedListing and F and selectedListing.itemId then
                    F.WatchlistAdd(selectedListing.itemName, selectedListing.itemId, 0)
                elseif selectedListing and selectedListing.itemLink then
                    ZO_LinkHandler_InsertLink(selectedListing.itemLink)
                end
            elseif activeTab == "storefront" then
                -- Trust/untrust seller toggle
                if F and UI._storefrontSeller then
                    if F.IsTrustedSeller(UI._storefrontSeller) then
                        F.UntrustSeller(UI._storefrontSeller)
                    else
                        F.TrustSeller(UI._storefrontSeller)
                    end
                    UI.ShowStorefront(UI._storefrontSeller)
                end
            else
                -- Normal link behavior
                if selectedListing and selectedListing.itemLink then
                    ZO_LinkHandler_InsertLink(selectedListing.itemLink)
                else Utils.Print("Select an item first.") end
            end
        end)
        linkBtn:SetHandler("OnMouseEnter", function(self)
            local tip
            if activeTab == "codqueue" then
                tip = "Release this sale back to the market.\nThe buyer's reservation will be cancelled."
            elseif activeTab == "mylistings" then
                tip = "Relist an expired/cancelled listing\nat the same price.\nOr link selected item to chat."
            elseif activeTab == "watchlist" then
                tip = "Set maximum price alert\nfor the selected watchlist item."
            elseif activeTab == "deals" or activeTab == "browse" then
                tip = "Add this item to your watchlist.\nYou'll be notified when it's listed."
            elseif activeTab == "storefront" then
                tip = "Add or remove this seller\nfrom your trusted sellers list."
            else
                tip = "Post the selected item's link\ninto your chat window."
            end
            ZO_Tooltips_ShowTextTooltip(self, TOP, tip)
        end)
        linkBtn:SetHandler("OnMouseExit", function() ZO_Tooltips_HideTextTooltip() end)
    end
end

function UI.OnActionClicked()
    if not selectedListing then Utils.Print("Select an item first.") return end
    local F = AH.Features
    if activeTab == "browse" then
        if selectedListing.seller == Utils.GetPlayerName() then Utils.Print("Can't buy your own listing.") return end
        if AH.ListingManager then AH.ListingManager.BuyItem(selectedListing) end
    elseif activeTab == "mylistings" then
        if selectedListing.state == "expired" or selectedListing.state == "cancelled" then
            -- Quick relist expired/cancelled listings
            if F then F.QuickRelist(selectedListing.id); UI.ShowMyListings() end
        else
            if AH.ListingManager then AH.ListingManager.CancelListing(selectedListing.id); UI.ShowMyListings() end
        end
    elseif activeTab == "codqueue" then
        if AH.ListingManager then AH.ListingManager.SendCOD(selectedListing.listingId or selectedListing.id) end
    elseif activeTab == "purchases" then
        local lid = selectedListing.listingId or selectedListing.id
        if selectedListing.state ~= "awaiting_cod" then
            Utils.Print("Can only cancel purchases that are awaiting COD.")
            return
        end
        if AH.ListingManager then AH.ListingManager.CancelPurchase(lid); UI.ShowPurchases() end
    elseif activeTab == "watchlist" then
        if F and selectedListing.watchlistKey then
            F.WatchlistRemove(selectedListing.watchlistKey)
            UI.ShowWatchlist()
        end
    elseif activeTab == "deals" then
        if selectedListing.seller == Utils.GetPlayerName() then return end
        if AH.ListingManager then AH.ListingManager.BuyItem(selectedListing) end
    elseif activeTab == "history" then
        if F then F.QuickRelist(selectedListing.id) end
    elseif activeTab == "storefront" then
        if selectedListing.seller == Utils.GetPlayerName() then return end
        if AH.ListingManager then AH.ListingManager.BuyItem(selectedListing) end
    end
end

function UI.UpdateGoldDisplay()
    local goldLabel = C("AuctionHouseWindowActionBarGoldDisplay")
    if goldLabel then
        goldLabel:SetText(Utils.FormatGold(GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER)))
    end
end

---------------------------------------------------------------------------
--  Browse
---------------------------------------------------------------------------

function UI.ExecuteSearch()
    if activeTab ~= "browse" then return end
    local searchText = UI.searchInput and (UI.searchInput:GetText() or "") or ""
    local allListings = {}
    if DM and DM.GetAllListings then
        local sv = DM.GetAllListings()
        if sv then for _, l in pairs(sv) do table.insert(allListings, l) end end
    end
    if AH.ListingManager then
        for _, listing in pairs(AH.savedVars.myListings or {}) do
            if listing.state == "listed" then
                local isDup = false
                for _, ex in ipairs(allListings) do if ex.id == listing.id then isDup = true break end end
                if not isDup then table.insert(allListings, listing) end
            end
        end
    end

    local filtered = {}
    local sl = searchText:lower()
    for _, l in ipairs(allListings) do
        if searchText == "" or (l.itemName or ""):lower():find(sl, 1, true)
           or (l.seller or ""):lower():find(sl, 1, true) then
            table.insert(filtered, l)
        end
    end

    local q = AH.savedVars.ui.filters.quality
    if q and q >= 0 then
        local tmp = {}
        for _, l in ipairs(filtered) do if (l.quality or 0) >= q then table.insert(tmp, l) end end
        filtered = tmp
    end

    local pMin, pMax = AH.savedVars.ui.filters.priceMin or 0, AH.savedVars.ui.filters.priceMax or 0
    if pMin > 0 or pMax > 0 then
        local tmp = {}
        for _, l in ipairs(filtered) do
            local up = l.unitPrice or l.price or 0
            if (pMin <= 0 or up >= pMin) and (pMax <= 0 or up <= pMax) then table.insert(tmp, l) end
        end
        filtered = tmp
    end

    local lMin, lMax = AH.savedVars.ui.filters.levelMin or 0, AH.savedVars.ui.filters.levelMax or 0
    if lMin > 0 or lMax > 0 then
        local tmp = {}
        for _, l in ipairs(filtered) do
            local lvl = l.level or 0
            if (lMin <= 0 or lvl >= lMin) and (lMax <= 0 or lvl <= lMax) then table.insert(tmp, l) end
        end
        filtered = tmp
    end

    local sortCol = AH.savedVars.ui.sortColumn or "unitPrice"
    local sortAsc = AH.savedVars.ui.sortAscending ~= false
    table.sort(filtered, function(a, b)
        local va, vb = a[sortCol] or 0, b[sortCol] or 0
        if type(va) == "string" then va = va:lower() end
        if type(vb) == "string" then vb = vb:lower() end
        if sortAsc then return va < vb else return va > vb end
    end)

    currentResults = filtered; selectedListing = nil; selectedRow = nil
    UI.PopulateScrollList(filtered)
    UI.UpdateResultCount(#filtered, #allListings)
end

---------------------------------------------------------------------------
--  Other Tabs
---------------------------------------------------------------------------

function UI.ShowMyListings()
    if not AH.ListingManager then return end
    local l = AH.ListingManager.GetMyListings()
    selectedListing = nil; selectedRow = nil
    UI.PopulateScrollList(l); UI.UpdateResultCount(#l, #l)
end

function UI.ShowPurchases()
    if not AH.ListingManager then return end
    local p = AH.ListingManager.GetMyPurchases()
    selectedListing = nil; selectedRow = nil
    UI.PopulateScrollList(p); UI.UpdateResultCount(#p, #p)
end

function UI.ShowCODQueue()
    if not AH.ListingManager then return end
    local q = AH.ListingManager.GetCODQueue()
    selectedListing = nil; selectedRow = nil
    UI.PopulateScrollList(q); UI.UpdateResultCount(#q, #q)
end

function UI.ShowWatchlist()
    local F = AH.Features
    local items = F and F.GetWatchlist() or {}
    selectedListing = nil; selectedRow = nil
    UI.PopulateScrollList(items); UI.UpdateResultCount(#items, #items)

    -- Show stats line
    local statsLabel = C("AuctionHouseWindowStatusBarResultCount")
    if statsLabel and F then
        local watchCount = 0
        for _ in pairs(AH.savedVars.watchlist or {}) do watchCount = watchCount + 1 end
        statsLabel:SetText(string.format("Watching %d items", watchCount))
    end
end

function UI.ShowDeals()
    local F = AH.Features
    local deals = F and F.GetDeals() or {}
    selectedListing = nil; selectedRow = nil
    UI.PopulateScrollList(deals); UI.UpdateResultCount(#deals, #deals)
end

function UI.ShowSaleHistory()
    local F = AH.Features
    local history = F and F.GetSaleHistory() or {}
    selectedListing = nil; selectedRow = nil
    UI.PopulateScrollList(history); UI.UpdateResultCount(#history, #history)

    -- Show stats summary in status bar
    local statsLabel = C("AuctionHouseWindowStatusBarResultCount")
    if statsLabel and F then
        statsLabel:SetText(F.GetSaleStatsText())
    end
end

function UI.ShowStorefront(sellerName)
    if not sellerName or sellerName == "" then return end
    local F = AH.Features
    local listings = F and F.GetSellerListings(sellerName) or {}
    UI._storefrontSeller = sellerName
    activeTab = "storefront"
    selectedListing = nil; selectedRow = nil
    UI.PopulateScrollList(listings); UI.UpdateResultCount(#listings, #listings)

    -- Update search bar to show seller name
    if UI.searchInput then
        UI.searchInput:SetText(sellerName .. "'s listings")
    end

    -- Show seller rating
    local statsLabel = C("AuctionHouseWindowStatusBarResultCount")
    if statsLabel and F then
        local rating = F.GetSellerRatingText(sellerName)
        local trusted = F.IsTrustedSeller(sellerName) and
            " " .. AH.Utils.Colorize("[Trusted]", "FFD700") or ""
        if rating then
            statsLabel:SetText(string.format("%s — %s%s", sellerName, rating, trusted))
        else
            statsLabel:SetText(string.format("%s — %d listings%s",
                sellerName, #listings, trusted))
        end
    end
end

---------------------------------------------------------------------------
--  Helpers
---------------------------------------------------------------------------

function UI.PopulateScrollList(results)
    if not UI.scrollList then return end
    local scrollData = ZO_ScrollList_GetDataList(UI.scrollList)
    ZO_ScrollList_Clear(UI.scrollList)
    for _, listing in ipairs(results) do
        table.insert(scrollData, ZO_ScrollList_CreateDataEntry(resultRowType, { data = listing }))
    end
    ZO_ScrollList_Commit(UI.scrollList)
end

function UI.UpdateResultCount(shown, total)
    local label = C("AuctionHouseWindowStatusBarResultCount")
    if label then
        if shown == total then label:SetText(string.format("%s results", Utils.FormatNumber(shown)))
        else label:SetText(string.format("%s of %s", Utils.FormatNumber(shown), Utils.FormatNumber(total))) end
    end
end

function UI.RefreshStatusBar()
    local syncLabel = C("AuctionHouseWindowStatusBarSyncStatus")
    if syncLabel and DM and DM.GetSyncStatus then
        local status = DM.GetSyncStatus()
        if status.isClientConnected then
            syncLabel:SetText(Utils.Colorize(string.format("Connected | %s listings",
                Utils.FormatNumber(status.totalListings)), AH.Colors.POSITIVE))
        elseif status.lastSync > 0 then
            syncLabel:SetText(Utils.Colorize(string.format("Last sync: %s",
                Utils.FormatTimestamp(status.lastSync)), AH.Colors.YELLOW))
        else
            syncLabel:SetText(Utils.Colorize("Desktop Client: Not connected", AH.Colors.NEUTRAL))
        end
    end
end

function UI.SaveWindowState()
    local w = C("AuctionHouseWindow"); if not w then return end
    local _, _, _, _, ox, oy = w:GetAnchor(0)
    AH.savedVars.ui.windowPosition = { x = ox, y = oy }
    local width, height = w:GetDimensions()
    AH.savedVars.ui.windowSize = { width = width, height = height }
end

function UI.RestoreWindowState()
    local w = C("AuctionHouseWindow"); if not w then return end
    local pos = AH.savedVars.ui.windowPosition
    if pos then w:ClearAnchors(); w:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, pos.x, pos.y) end
    local size = AH.savedVars.ui.windowSize
    if size then w:SetDimensions(size.width, size.height) end
end

function UI.RegisterCallbacks()
    CALLBACK_MANAGER:RegisterCallback(AH.Events.UI_REFRESH_NEEDED, function()
        if UI.IsVisible() then UI.SwitchTab(activeTab); UI.RefreshStatusBar() end
    end)
    CALLBACK_MANAGER:RegisterCallback(AH.Events.DATA_UPDATED, function()
        if UI.IsVisible() then UI.SwitchTab(activeTab) end
    end)
    EVENT_MANAGER:RegisterForUpdate(AH.name .. "_StatusRefresh", 10000, function()
        if UI.IsVisible() then UI.RefreshStatusBar() end
    end)
end

function UI.OnKeybind() UI.Toggle() end

---------------------------------------------------------------------------
--  Help Dialog
---------------------------------------------------------------------------

function UI.ShowHelp()
    local dialog = C("AuctionHouseHelpDialog")
    if not dialog then return end

    -- Get the scroll container's auto-created scroll child
    local scrollContainer = C("AuctionHouseHelpDialogScrollContainer")
    if not scrollContainer then return end
    local scrollChild = scrollContainer:GetNamedChild("ScrollChild")
    if not scrollChild then return end

    -- Create content label once, reuse on subsequent calls
    if not UI._helpLabel then
        UI._helpLabel = WINDOW_MANAGER:CreateControl("AH_HelpContentLabel", scrollChild, CT_LABEL)
        UI._helpLabel:SetFont("ZoFontGame")
        UI._helpLabel:SetColor(0.8, 0.8, 0.8, 1)
        UI._helpLabel:SetWidth(460)
        UI._helpLabel:SetAnchor(TOPLEFT, scrollChild, TOPLEFT, 5, 0)
        UI._helpLabel:SetText(
            "|cFFD700Getting Started|r\n" ..
            "Make sure the desktop client is running and shows\n" ..
            "\"Connected\" before using the auction house.\n\n" ..

            "|cFFD700Selling Items|r\n" ..
            "Right-click any item in your inventory and select\n" ..
            "\"List on Tamriel Auction House\". Set your price and\n" ..
            "duration, then confirm. The sell dialog shows the\n" ..
            "current lowest competing price - click it to\n" ..
            "automatically undercut by 1%%.\n\n" ..

            "|cFFD700Buying Items|r\n" ..
            "Browse or search for items, select one, and click\n" ..
            "Buy Selected. The seller will send you a COD mail.\n" ..
            "Accept it to complete the purchase.\n\n" ..

            "|cFFD700COD Queue|r\n" ..
            "When someone buys your item, it appears in the\n" ..
            "COD Queue tab. Send them a COD mail with the item\n" ..
            "at the listed price to complete the sale.\n\n" ..

            "|cFFD700Watchlist|r\n" ..
            "Watch items to get notified when they are listed.\n" ..
            "Right-click any listing and choose \"Watch Item\" or\n" ..
            "right-click items in your inventory and choose\n" ..
            "\"Watch on TAH\". The Watchlist tab shows your\n" ..
            "watched items and their current best prices.\n" ..
            "Use /ah watch <name> and /ah unwatch <name>.\n\n" ..

            "|cFFD700Trusted Sellers|r\n" ..
            "Mark sellers you trust for fast COD delivery.\n" ..
            "Right-click a listing and choose \"Trust Seller\".\n" ..
            "Trusted sellers show a gold |cFFD700[T]|r badge next\n" ..
            "to their name. Use /ah trust and /ah untrust.\n\n" ..

            "|cFFD700Seller Storefront|r\n" ..
            "Right-click any listing and choose \"View Seller\"\n" ..
            "to browse all of that seller's active listings.\n" ..
            "Also available via /ah storefront <name>.\n\n" ..

            "|cFFD700Daily Deals|r\n" ..
            "The Deals tab shows items listed significantly\n" ..
            "below their recent market average. Great for\n" ..
            "finding bargains! Discount %% shown in price.\n\n" ..

            "|cFFD700Sale History & Stats|r\n" ..
            "The History tab shows your completed sales.\n" ..
            "Use /ah stats for a 7-day summary of gold\n" ..
            "earned, items sold, purchases, and net profit.\n\n" ..

            "|cFFD700Quick Relist|r\n" ..
            "Expired or cancelled listings can be quickly\n" ..
            "relisted from the My Listings tab. Right-click\n" ..
            "and choose \"Quick Relist\" to relist at the same\n" ..
            "price, or use /ah relist <id>.\n\n" ..

            "|cFFD700Undercut Helper|r\n" ..
            "When listing an item, the sell dialog shows how\n" ..
            "many competing listings exist and the current\n" ..
            "lowest price. Click the blue undercut text to\n" ..
            "auto-fill a price 1%% below the competition.\n\n" ..

            "|cFFD700Refresh Button|r\n" ..
            "Reloads the UI to fetch the latest data from the\n" ..
            "server. Use after posting, buying, or cancelling.\n\n" ..

            "|cFFD700Useful Commands|r\n" ..
            "/ah  -  Toggle window\n" ..
            "/ah search <query>  -  Search items\n" ..
            "/ah watch <name>  -  Watch an item\n" ..
            "/ah unwatch <name>  -  Stop watching\n" ..
            "/ah trust <name>  -  Trust a seller\n" ..
            "/ah untrust <name>  -  Untrust a seller\n" ..
            "/ah storefront <name>  -  View seller\n" ..
            "/ah deals  -  Open deals tab\n" ..
            "/ah stats  -  7-day sale stats\n" ..
            "/ah relist <id>  -  Relist expired item\n" ..
            "/ah cancelall  -  Cancel all listings\n" ..
            "/ah status  -  Connection info\n" ..
            "/ah help  -  Full command list"
        )
    end

    -- Resize scroll child to fit text
    local textHeight = UI._helpLabel:GetTextHeight()
    UI._helpLabel:SetHeight(textHeight)
    scrollChild:SetHeight(textHeight + 10)

    -- Wire close buttons
    local closeBtn = C("AuctionHouseHelpDialogCloseBtn")
    if closeBtn then
        closeBtn:SetHandler("OnClicked", function() dialog:SetHidden(true) end)
    end
    local xBtn = C("AuctionHouseHelpDialogXBtn")
    if xBtn then
        xBtn:SetHandler("OnClicked", function() dialog:SetHidden(true) end)
    end

    dialog:SetHidden(false)
end
