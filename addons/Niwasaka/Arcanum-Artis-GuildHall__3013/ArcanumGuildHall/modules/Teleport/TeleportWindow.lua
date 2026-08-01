local ArcanumGuildHall = _G["ArcanumGuildHall"]
local UI = ArcanumGuildHallTeleportUI
local Teleport = ArcanumGuildHall.Teleport
local LAM2 = LibAddonMenu2
local res = ArcanumGuildHallMediaRes

UI.TeleportWindow = UI.TeleportWindow or {}
UI.TeleportDetails = UI.TeleportDetails or {}
UI.TeleportList = UI.TeleportList or {}

local Window = UI.TeleportWindow
local Details = UI.TeleportDetails
local List = UI.TeleportList

Window.DOUBLE_CLICK_MS = 400

Window.FONT_TITLE = "$(BOLD_FONT)|22|soft-shadow-thin"
Window.FONT_SUBTITLE = "$(MEDIUM_FONT)|16|soft-shadow-thin"
Window.FONT_SECTION = "$(BOLD_FONT)|17|soft-shadow-thin"
Window.FONT_LABEL = "$(BOLD_FONT)|17|soft-shadow-thin"
Window.FONT_PRIMARY = "$(BOLD_FONT)|19|soft-shadow-thin"
Window.FONT_VALUE = "$(MEDIUM_FONT)|16|soft-shadow-thin"
Window.FONT_FILTER = "$(BOLD_FONT)|17|soft-shadow-thin"
Window.FONT_LOADING = "$(MEDIUM_FONT)|14|soft-shadow-thin"
Window.FONT_HINT = "$(MEDIUM_FONT)|15|soft-shadow-thin"

Window.STYLE = Window.STYLE or {
    tabs = {
        active = 1.00,
        inactive = 0.48,
        hover = 0.76,
        spacing = 8,
    },
    filters = {
        iconSize = 24,
        spacing = 6,

        bgCenter = { 0.08, 0.08, 0.09, 0.22 },
        bgEdge = { 0.42, 0.42, 0.46, 0.16 },

        activeCenter = { 0.24, 0.38, 0.62, 0.24 },
        activeEdge = { 0.78, 0.89, 1.00, 0.28 },

        hoverCenter = { 1.00, 1.00, 1.00, 0.04 },
        hoverEdge = { 1.00, 1.00, 1.00, 0.06 },
    },
    rows = {
        height = 28,
        iconOffsetX = 6,
        textOffsetX = 8,

        selectedCenter = { 0.20, 0.34, 0.58, 0.30 },
        selectedEdge = { 0.78, 0.89, 1.00, 0.14 },

        hoverCenter = { 1.00, 1.00, 1.00, 0.035 },
        hoverEdge = { 1.00, 1.00, 1.00, 0.03 },
    },
    hint = {
        height = 24,
        bgCenter = { 0.08, 0.08, 0.09, 0.16 },
        bgEdge = { 0.42, 0.42, 0.46, 0.10 },
        text = { 0.78, 0.78, 0.78, 0.92 },
    },
    search = {
        placeholder = { 0.66, 0.66, 0.66, 0.68 },
    },
    text = {
        normal = { 0.95, 0.95, 0.95, 1.00 },
        dimmed = { 0.72, 0.72, 0.72, 1.00 },
        disabled = { 0.55, 0.55, 0.55, 1.00 },
        divider = { 0.65, 0.65, 0.65, 1.00 },

        filterOn = { 1.00, 1.00, 1.00, 1.00 },
        filterOff = { 0.72, 0.72, 0.72, 1.00 },
        filterOver = { 0.88, 0.88, 0.88, 1.00 },
    },
}

Window.CATEGORY_ICONS = {
    [Teleport.CATEGORY.ZONE] = res.IconPortCategoryZone,
    [Teleport.CATEGORY.DUNGEON] = res.IconPortCategoryDungeon,
    [Teleport.CATEGORY.TRIAL] = res.IconPortCategoryTrial,
    [Teleport.CATEGORY.ARENA] = res.IconPortCategoryArena,
    [Teleport.CATEGORY.HOUSE] = res.IconPortCategoryHouse,
}

Window.FILTER_ICONS = {
    all = res.IconPortFilterAll,
    zone = res.IconPortFilterZone,
    dungeon = res.IconPortFilterDungeon,
    trial = res.IconPortFilterTrial,
    arena = res.IconPortFilterArena,
}

local TAB_KEYS = {
    "network",
    "wayshrines",
    "unknown",
    "houses",
    "guildhouses",
}

local FILTER_KEYS = {
    "all",
    "zone",
    "dungeon",
    "trial",
    "arena",
}

function Window.InitRefs()
    if UI.refs then
        return UI.refs
    end

    local refs = {}

    refs.tabsContainer = ArcanumGuildHallTeleportWindow_TabsContainer

    refs.tabs = {}

    refs.tabs.network = {
        control = ArcanumGuildHallTeleportWindow_TabsContainer_TabNetwork,
        icon = ArcanumGuildHallTeleportWindow_TabsContainer_TabNetwork_Icon,
        label = ArcanumGuildHallTeleportWindow_TabsContainer_TabNetwork_Label,
    }

    refs.tabs.wayshrines = {
        control = ArcanumGuildHallTeleportWindow_TabsContainer_TabWayshrines,
        icon = ArcanumGuildHallTeleportWindow_TabsContainer_TabWayshrines_Icon,
        label = ArcanumGuildHallTeleportWindow_TabsContainer_TabWayshrines_Label,
    }

    refs.tabs.unknown = {
        control = ArcanumGuildHallTeleportWindow_TabsContainer_TabUnknown,
        icon = ArcanumGuildHallTeleportWindow_TabsContainer_TabUnknown_Icon,
        label = ArcanumGuildHallTeleportWindow_TabsContainer_TabUnknown_Label,
    }

    refs.tabs.houses = {
        control = ArcanumGuildHallTeleportWindow_TabsContainer_TabHouses,
        icon = ArcanumGuildHallTeleportWindow_TabsContainer_TabHouses_Icon,
        label = ArcanumGuildHallTeleportWindow_TabsContainer_TabHouses_Label,
    }

    refs.tabs.guildhouses = {
        control = ArcanumGuildHallTeleportWindow_TabsContainer_TabGuildHouses,
        icon = ArcanumGuildHallTeleportWindow_TabsContainer_TabGuildHouses_Icon,
        label = ArcanumGuildHallTeleportWindow_TabsContainer_TabGuildHouses_Label,
    }

    refs.filters = {}

    refs.filters.all = {
        control = ArcanumGuildHallTeleportWindow_FilterGrid_FilterCategoryAll,
        icon = ArcanumGuildHallTeleportWindow_FilterGrid_FilterCategoryAll_Icon,
        label = ArcanumGuildHallTeleportWindow_FilterGrid_FilterCategoryAll_Label,
        bg = ArcanumGuildHallTeleportWindow_FilterGrid_FilterCategoryAll_Bg,
        active = ArcanumGuildHallTeleportWindow_FilterGrid_FilterCategoryAll_Active,
        hover = ArcanumGuildHallTeleportWindow_FilterGrid_FilterCategoryAll_Hover,
    }

    refs.filters.zone = {
        control = ArcanumGuildHallTeleportWindow_FilterGrid_FilterCategoryZone,
        icon = ArcanumGuildHallTeleportWindow_FilterGrid_FilterCategoryZone_Icon,
        label = ArcanumGuildHallTeleportWindow_FilterGrid_FilterCategoryZone_Label,
        bg = ArcanumGuildHallTeleportWindow_FilterGrid_FilterCategoryZone_Bg,
        active = ArcanumGuildHallTeleportWindow_FilterGrid_FilterCategoryZone_Active,
        hover = ArcanumGuildHallTeleportWindow_FilterGrid_FilterCategoryZone_Hover,
    }

    refs.filters.dungeon = {
        control = ArcanumGuildHallTeleportWindow_FilterGrid_FilterCategoryDungeon,
        icon = ArcanumGuildHallTeleportWindow_FilterGrid_FilterCategoryDungeon_Icon,
        label = ArcanumGuildHallTeleportWindow_FilterGrid_FilterCategoryDungeon_Label,
        bg = ArcanumGuildHallTeleportWindow_FilterGrid_FilterCategoryDungeon_Bg,
        active = ArcanumGuildHallTeleportWindow_FilterGrid_FilterCategoryDungeon_Active,
        hover = ArcanumGuildHallTeleportWindow_FilterGrid_FilterCategoryDungeon_Hover,
    }

    refs.filters.trial = {
        control = ArcanumGuildHallTeleportWindow_FilterGrid_FilterCategoryTrial,
        icon = ArcanumGuildHallTeleportWindow_FilterGrid_FilterCategoryTrial_Icon,
        label = ArcanumGuildHallTeleportWindow_FilterGrid_FilterCategoryTrial_Label,
        bg = ArcanumGuildHallTeleportWindow_FilterGrid_FilterCategoryTrial_Bg,
        active = ArcanumGuildHallTeleportWindow_FilterGrid_FilterCategoryTrial_Active,
        hover = ArcanumGuildHallTeleportWindow_FilterGrid_FilterCategoryTrial_Hover,
    }

    refs.filters.arena = {
        control = ArcanumGuildHallTeleportWindow_FilterGrid_FilterCategoryArena,
        icon = ArcanumGuildHallTeleportWindow_FilterGrid_FilterCategoryArena_Icon,
        label = ArcanumGuildHallTeleportWindow_FilterGrid_FilterCategoryArena_Label,
        bg = ArcanumGuildHallTeleportWindow_FilterGrid_FilterCategoryArena_Bg,
        active = ArcanumGuildHallTeleportWindow_FilterGrid_FilterCategoryArena_Active,
        hover = ArcanumGuildHallTeleportWindow_FilterGrid_FilterCategoryArena_Hover,
    }

    refs.searchContainer = ArcanumGuildHallTeleportWindow_SearchContainer
    refs.searchBox = ArcanumGuildHallTeleportWindow_SearchContainer_Box
    refs.searchHint = ArcanumGuildHallTeleportWindow_SearchContainer_Placeholder
    refs.list = ArcanumGuildHallTeleportWindow_List

    UI.refs = refs
    return refs
end

function Window.GetTab(tabKey)
    return Window.InitRefs().tabs[tabKey]
end

function Window.GetFilter(filterKey)
    return Window.InitRefs().filters[filterKey]
end

function Window.GetTabsContainer()
    return Window.InitRefs().tabsContainer
end

function Window.GetSearchContainer()
    return Window.InitRefs().searchContainer
end

function Window.GetSearchBox()
    return Window.InitRefs().searchBox
end

function Window.GetSearchHint()
    return Window.InitRefs().searchHint
end

function Window.GetList()
    return Window.InitRefs().list
end

function Window.GetTeleportButton()
    return ArcanumGuildHallTeleportWindow_TopActions_ButtonTeleport
end

function Window.UsesCategoryFilter()
    return UI.activeTab == "network" or UI.activeTab == "wayshrines" or UI.activeTab == "unknown"
end

function Window.UsesHouseFilter()
    return UI.activeTab == "houses"
end

function Window.SupportsFavorites()
    return UI.activeTab ~= "unknown" and UI.activeTab ~= "guildhouses"
end

function Window.GetFilterKey()
    if UI.activeTab ~= "houses" then
        return UI.filters.category or "all"
    end

    local houseFilter = UI.filters.house or "all"

    if houseFilter == "owned" then
        return "zone"
    end

    if houseFilter == "unowned" then
        return "dungeon"
    end

    return "all"
end

function Window.UpdateTeleportButton(entry)
    local button = Window.GetTeleportButton()
    local canTeleport = entry and entry.callback ~= nil
    local blockedByAvA = canTeleport and Teleport.IsBlockedByAvA()

    local text = ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_BUTTON_TELEPORT")
    if blockedByAvA then
        text = (res.Ccolor3 or "") .. text .. "|r"
    end

    button:SetText(text)
    button:SetEnabled(canTeleport and not blockedByAvA)
end

local function getFilterText(filterKey)
    if Window.UsesHouseFilter() then
        if filterKey == "all" then
            return ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_FILTER_ALL")
        end

        if filterKey == "zone" then
            return ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_FILTER_HOUSE_OWNED")
        end

        if filterKey == "dungeon" then
            return ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_FILTER_HOUSE_UNOWNED")
        end

        return ""
    end

    if filterKey == "all" then
        return ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_FILTER_ALL")
    end

    if filterKey == "zone" then
        return ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_FILTER_ZONE")
    end

    if filterKey == "dungeon" then
        return ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_FILTER_DUNGEON")
    end

    if filterKey == "trial" then
        return ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_FILTER_TRIAL")
    end

    if filterKey == "arena" then
        return ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_FILTER_ARENA")
    end

    return ""
end

function Window.CenterFilterText(filterKey)
    local filter = Window.GetFilter(filterKey)
    local control = filter.control
    local icon = filter.icon
    local label = filter.label

    local controlWidth = control:GetWidth() or 93
    local controlHeight = control:GetHeight() or 32
    local iconWidth = Window.STYLE.filters.iconSize
    local spacing = Window.STYLE.filters.spacing
    local minPad = 4

    local text = label:GetText() or ""
    local textWidth = 0

    if label.GetStringWidth then
        textWidth = math.floor(label:GetStringWidth() or 0)
    end

    if textWidth <= 0 then
        textWidth = zo_strlen(text) * 8
    end

    local totalWidth = iconWidth + spacing + textWidth
    local availableWidth = controlWidth - (minPad * 2)

    if totalWidth > availableWidth then
        spacing = 3
        totalWidth = iconWidth + spacing + textWidth
    end

    local startX = math.floor((controlWidth - totalWidth) / 2)
    if startX < minPad then
        startX = minPad
    end

    icon:ClearAnchors()
    icon:SetDimensions(iconWidth, iconWidth)
    icon:SetAnchor(LEFT, control, LEFT, startX, 0)
    icon:SetHidden(false)

    label:ClearAnchors()
    label:SetDimensions(textWidth + 2, controlHeight)
    label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    label:SetAnchor(LEFT, icon, RIGHT, spacing, 0)
    label:SetHidden(false)
end

local function applyTabAlpha(tabKey, alpha)
    local tab = Window.GetTab(tabKey)

    tab.control:SetAlpha(alpha)
    tab.icon:SetAlpha(alpha)
    tab.icon:SetHidden(false)
    tab.label:SetHidden(true)
end

function Window.RefreshTabs()
    for i = 1, #TAB_KEYS do
        local tabKey = TAB_KEYS[i]
        local tab = Window.GetTab(tabKey)

        if not tab.control:IsHidden() then
            local alpha = UI.activeTab == tabKey and Window.STYLE.tabs.active or Window.STYLE.tabs.inactive
            applyTabAlpha(tabKey, alpha)
        end
    end
end

local function initTabTip(tabKey, text)
    local tab = Window.GetTab(tabKey)

    tab.control:SetMouseEnabled(true)

    tab.control:SetHandler("OnMouseEnter", function(selfControl)
        local alpha = UI.activeTab == tabKey and Window.STYLE.tabs.active or Window.STYLE.tabs.hover
        applyTabAlpha(tabKey, alpha)
        ZO_Tooltips_ShowTextTooltip(selfControl, BOTTOM, text)
    end)

    tab.control:SetHandler("OnMouseExit", function()
        ZO_Tooltips_HideTextTooltip()
        local alpha = UI.activeTab == tabKey and Window.STYLE.tabs.active or Window.STYLE.tabs.inactive
        applyTabAlpha(tabKey, alpha)
    end)
end

local function initTabIcon(tabKey)
    local tab = Window.GetTab(tabKey)

    tab.icon:ClearAnchors()
    tab.icon:SetAnchor(CENTER, tab.control, CENTER, 0, 0)
    tab.icon:SetHidden(false)

    tab.label:SetText("")
    tab.label:SetAlpha(0)
    tab.label:SetHidden(true)
end

local function setFilterText(filterKey)
    local filter = Window.GetFilter(filterKey)

    filter.icon:SetTexture(Window.FILTER_ICONS[filterKey] or "")
    filter.icon:SetHidden(false)

    filter.label:SetText(getFilterText(filterKey))
    filter.label:SetHidden(false)

    Window.CenterFilterText(filterKey)
end

local function refreshFilterText()
    for i = 1, #FILTER_KEYS do
        setFilterText(FILTER_KEYS[i])
    end
end

local function initFilterBackdrop(filterKey)
    local filter = Window.GetFilter(filterKey)
    local style = Window.STYLE.filters

    filter.bg:SetCenterColor(style.bgCenter[1], style.bgCenter[2], style.bgCenter[3], style.bgCenter[4])
    filter.bg:SetEdgeColor(style.bgEdge[1], style.bgEdge[2], style.bgEdge[3], style.bgEdge[4])
    filter.bg:SetHidden(false)

    filter.active:SetCenterColor(style.activeCenter[1], style.activeCenter[2], style.activeCenter[3], style.activeCenter[4])
    filter.active:SetEdgeColor(style.activeEdge[1], style.activeEdge[2], style.activeEdge[3], style.activeEdge[4])
    filter.active:SetHidden(true)

    filter.hover:SetCenterColor(style.hoverCenter[1], style.hoverCenter[2], style.hoverCenter[3], style.hoverCenter[4])
    filter.hover:SetEdgeColor(style.hoverEdge[1], style.hoverEdge[2], style.hoverEdge[3], style.hoverEdge[4])
    filter.hover:SetHidden(true)
end

local function initFilterBackdrops()
    for i = 1, #FILTER_KEYS do
        initFilterBackdrop(FILTER_KEYS[i])
    end
end

local function updateFilterState(filterKey, active)
    local filter = Window.GetFilter(filterKey)

    filter.icon:SetAlpha(active and 1 or 0.45)
    filter.icon:SetHidden(false)

    filter.label:SetAlpha(active and 1 or 0.65)

    local color = active and Window.STYLE.text.filterOn or Window.STYLE.text.filterOff
    filter.label:SetColor(color[1], color[2], color[3], color[4])

    filter.active:SetHidden(not active)
    filter.hover:SetHidden(true)
end

local function initFilterHover(filterKey)
    local filter = Window.GetFilter(filterKey)

    filter.control:SetMouseEnabled(true)

    filter.control:SetHandler("OnMouseEnter", function()
        local active = Window.GetFilterKey() == filterKey

        filter.icon:SetAlpha(active and 1 or 0.76)
        filter.icon:SetHidden(false)

        filter.label:SetAlpha(active and 1 or 0.85)

        local color = active and Window.STYLE.text.filterOn or Window.STYLE.text.filterOver
        filter.label:SetColor(color[1], color[2], color[3], color[4])

        filter.hover:SetHidden(false)
    end)

    filter.control:SetHandler("OnMouseExit", function()
        updateFilterState(filterKey, Window.GetFilterKey() == filterKey)
    end)
end

local function stripButton(control)
    control:SetNormalTexture("")
    control:SetMouseOverTexture("")
    control:SetPressedTexture("")
    control:SetDisabledTexture("")
end

local function refreshWindowState(onlyWhenVisible)
    if onlyWhenVisible and ArcanumGuildHallTeleportWindow:IsHidden() then
        return
    end

    Window.RefreshTabs()
    Window.RefreshSearchHint()
    Window.RefreshFilters(UI)

    Details.UpdateLoading(UI)
    Details.RefreshHint()
    Details.UpdateFavorites(UI)
end

local function isOwnedHouseEntry(entry)
    local details = entry and entry.details or nil

    return UI.activeTab == "houses"
            and entry
            and entry.entryType == "action"
            and details
            and details.category == Teleport.CATEGORY.HOUSE
            and details.houseId
            and details.houseId > 0
            and details.isOwnedHouse ~= false
            and not details.isPreviewHouse
end

local function execHouseTravel(entry, travelOutside)
    local details = entry.details
    if not details or not details.houseId or details.houseId <= 0 then
        return
    end

    if details.isPrimaryHouse then
        Teleport.TravelToPrimaryHouse(travelOutside, details.target or entry.text or "")
    else
        Teleport.TravelToKnownHouse(details.houseId, travelOutside, details.target or entry.text or "")
    end

    ArcanumGuildHall:HideTeleportWindow()
end

function Window.ShowHouseMenu(entry, anchorControl)
    if not isOwnedHouseEntry(entry) then
        return false
    end

    ClearMenu()

    AddMenuItem(ArcanumGuildHall.GetDefaultLocaleString("PORT_IN_HOUSE"), function()
        execHouseTravel(entry, false)
    end)

    AddMenuItem(ArcanumGuildHall.GetDefaultLocaleString("PORT_FRONT_HOUSE"), function()
        execHouseTravel(entry, true)
    end)

    ShowMenu(anchorControl or ArcanumGuildHallTeleportWindow_TopActions_ButtonTeleport)
    return true
end

function Window.GetEntries()
    if UI.activeTab == "network" then
        return Teleport.GetPlayerTargets()
    end

    if UI.activeTab == "wayshrines" then
        return Teleport.GetKnownWayshrines()
    end

    if UI.activeTab == "unknown" then
        return Teleport.GetUnknownWayshrines()
    end

    if UI.activeTab == "houses" then
        return Teleport.GetHouseEntries()
    end

    if UI.activeTab == "guildhouses" then
        if not ArcanumGuildHall:IsInArcanumGuild() then
            return {}
        end

        return ArcanumGuildHall:GetGuildHouseEntries()
    end

    return {}
end

function Window.RefreshGuildTab()
    local guildTab = Window.GetTab("guildhouses")
    local showGuildTab = ArcanumGuildHall:IsInArcanumGuild()

    guildTab.control:SetHidden(not showGuildTab)

    if not showGuildTab and UI.activeTab == "guildhouses" then
        Window.SetTab(UI, "network")
        return
    end

    Window.RefreshTabs()
end

function Window.RefreshTexts()
    ArcanumGuildHallTeleportWindow_Title:SetText(ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_WINDOW_TITLE"))
    Window.GetSearchHint():SetText(ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_SEARCH_PLACEHOLDER"))
    ArcanumGuildHallTeleportWindow_DetailsTitle:SetText(ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_DETAILS_TITLE"))
    ArcanumGuildHallTeleportWindow_DetailsSubtitle:SetText(ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_DETAILS_SUBTITLE"))
    ArcanumGuildHallTeleportWindow_FilterCategoryLabel:SetText(ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_FILTER_LABEL"))
    ArcanumGuildHallTeleportWindow_TopActions_ButtonRefresh:SetText(ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_BUTTON_REFRESH"))
    ArcanumGuildHallTeleportWindow_TopActions_ButtonTeleport:SetText(ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_BUTTON_TELEPORT"))
    ArcanumGuildHallTeleportWindow_LoadingLabel:SetText(ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_LOADING_PLAYERS"))

    Details.RefreshHint()
    Window.UpdateTeleportButton(UI.selectedData)
end

function Window.RefreshSearchHint()
    local placeholder = Window.GetSearchHint()
    local searchBox = Window.GetSearchBox()

    placeholder:SetHidden((searchBox:GetText() or "") ~= "")
end

function Window.HideSearchHint()
    Window.GetSearchHint():SetHidden(true)
end

function Window.RefreshFilters(self)
    local showFilters = Window.UsesCategoryFilter() or Window.UsesHouseFilter()
    local houseTab = Window.UsesHouseFilter()
    local currentFilterKey = Window.GetFilterKey()

    ArcanumGuildHallTeleportWindow_FilterCategoryLabel:SetHidden(not showFilters)
    ArcanumGuildHallTeleportWindow_FilterGrid:SetHidden(not showFilters)

    refreshFilterText()

    Window.GetFilter("all").control:SetHidden(not showFilters)
    Window.GetFilter("zone").control:SetHidden(not showFilters)
    Window.GetFilter("dungeon").control:SetHidden(not showFilters)
    Window.GetFilter("trial").control:SetHidden(houseTab or not showFilters)
    Window.GetFilter("arena").control:SetHidden(houseTab or not showFilters)

    for i = 1, #FILTER_KEYS do
        local key = FILTER_KEYS[i]
        updateFilterState(key, currentFilterKey == key)
    end
end

function Window.SetFilter(self, filterKey)
    if Window.UsesHouseFilter() then
        if filterKey == "all" then
            self.filters.house = "all"
        elseif filterKey == "zone" then
            self.filters.house = "owned"
        elseif filterKey == "dungeon" then
            self.filters.house = "unowned"
        else
            return
        end

        if ArcanumGuildHall.db then
            ArcanumGuildHall.db.lastTeleportHouseFilter = self.filters.house
        end
    else
        self.filters.category = filterKey

        if ArcanumGuildHall.db then
            ArcanumGuildHall.db.lastTeleportCategoryFilter = self.filters.category
        end
    end

    Window.RefreshFilters(self)
    List.RefreshList(self)
end

function Window.SetTab(self, tabName)
    if tabName == "guildhouses" and not ArcanumGuildHall:IsInArcanumGuild() then
        tabName = "network"
    end

    self.activeTab = tabName
    self.selectionKey = nil

    if ArcanumGuildHall.db then
        ArcanumGuildHall.db.lastTeleportTab = tabName
    end

    Window.RefreshTabs()
    Window.RefreshFilters(self)
    Details.UpdateView(self)
    List.RefreshList(self)
    Details.RefreshHint()
end

function Window.ApplySearch(self)
    local text = Window.GetSearchBox():GetText() or ""
    self.searchText = text
    self.pendingSearchText = text
    List.RefreshList(self)
end

function Window.SoftRefresh(self)
    if self.activeTab == "network" then
        Teleport.MarkPlayerCacheDirty()
    elseif self.activeTab == "guildhouses" then
        ArcanumGuildHall.guildHouseDataCache = nil
        Teleport.MarkNodeCacheDirty()
    else
        Teleport.MarkNodeCacheDirty()
    end

    local text = Window.GetSearchBox():GetText() or ""
    self.searchText = text
    self.pendingSearchText = text
    List.RefreshList(self)
end

function Window.TeleportSelected(self)
    if not self.selectedData then
        return
    end

    if Window.ShowHouseMenu(self.selectedData, ArcanumGuildHallTeleportWindow_TopActions_ButtonTeleport) then
        return
    end

    if self.selectedData.callback then
        self.selectedData.callback()
        ArcanumGuildHall:HideTeleportWindow()
    end
end

function ArcanumGuildHall:CityTeleport(node)
    if Teleport.CheckAvARestriction() then
        return
    end

    if not node or not node.id or not node.name or node.name == "" then
        Teleport.PrintInvalidTargetMessage()
        return
    end

    local displayName = Teleport.CleanText(
            node.displayName or Teleport.FormatTargetDisplayName(node.name, node.category, node.zoneId, node.id)
    )

    if not HasCompletedFastTravelNodePOI(node.id) then
        Teleport.PrintWayshrineUnknownMessage()
        return
    end

    local goldCost = Teleport.GetRecallCostSafe(node.id)

    Teleport.pendingNodeRefreshAfterTravel = true
    FastTravelToNode(node.id)
    Teleport.PrintTravelMessage(displayName ~= "" and displayName or node.name, goldCost)
end

function ArcanumGuildHall:InitializeTeleportModule()
    if UI.initialized then
        return
    end

    Window.InitRefs()

    Teleport.RegisterInvalidationEvents()
    Teleport.MigrateFavoriteKeys()
    Window.RefreshTexts()
    refreshFilterText()
    initFilterBackdrops()

    stripButton(Window.GetFilter("all").control)
    stripButton(Window.GetFilter("zone").control)
    stripButton(Window.GetFilter("dungeon").control)
    stripButton(Window.GetFilter("trial").control)
    stripButton(Window.GetFilter("arena").control)
    stripButton(ArcanumGuildHallTeleportWindow_ButtonSettings)

    initFilterHover("all")
    initFilterHover("zone")
    initFilterHover("dungeon")
    initFilterHover("trial")
    initFilterHover("arena")

    initTabIcon("network")
    initTabIcon("wayshrines")
    initTabIcon("unknown")
    initTabIcon("houses")
    initTabIcon("guildhouses")

    Window.GetTab("network").icon:SetTexture(res.IconPortTabNetwork)
    Window.GetTab("wayshrines").icon:SetTexture(res.IconPortTabWayshrines)
    Window.GetTab("unknown").icon:SetTexture(res.IconPortTabUnknown)
    Window.GetTab("houses").icon:SetTexture(res.IconPortTabHouses)
    Window.GetTab("guildhouses").icon:SetTexture(res.IconPortTabGuildHouses)

    ArcanumGuildHallTeleportWindow_ButtonClose:SetNormalTexture(res.IconPortCloseButtonN)
    ArcanumGuildHallTeleportWindow_ButtonClose:SetMouseOverTexture(res.IconPortCloseButtonO)
    ArcanumGuildHallTeleportWindow_ButtonClose:SetPressedTexture(res.IconPortCloseButtonD)

    ArcanumGuildHallTeleportWindow_ButtonSettings_Icon:SetTexture(res.IconOptTexture)

    initTabTip("network", ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_TAB_NETWORK_TOOLTIP"))
    initTabTip("wayshrines", ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_TAB_WAYSHRINES_TOOLTIP"))
    initTabTip("unknown", ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_TAB_UNKNOWN_TOOLTIP"))
    initTabTip("houses", ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_TAB_HOUSES_TOOLTIP"))
    initTabTip("guildhouses", ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_TAB_GUILDHOUSES_TOOLTIP"))

    Window.GetTab("network").control:SetHandler("OnClicked", function()
        Window.SetTab(UI, "network")
    end)

    Window.GetTab("wayshrines").control:SetHandler("OnClicked", function()
        Window.SetTab(UI, "wayshrines")
    end)

    Window.GetTab("unknown").control:SetHandler("OnClicked", function()
        Window.SetTab(UI, "unknown")
    end)

    Window.GetTab("houses").control:SetHandler("OnClicked", function()
        Window.SetTab(UI, "houses")
    end)

    Window.GetTab("guildhouses").control:SetHandler("OnClicked", function()
        Window.SetTab(UI, "guildhouses")
    end)

    Window.GetFilter("all").control:SetHandler("OnClicked", function()
        Window.SetFilter(UI, "all")
    end)

    Window.GetFilter("zone").control:SetHandler("OnClicked", function()
        Window.SetFilter(UI, "zone")
    end)

    Window.GetFilter("dungeon").control:SetHandler("OnClicked", function()
        Window.SetFilter(UI, "dungeon")
    end)

    Window.GetFilter("trial").control:SetHandler("OnClicked", function()
        Window.SetFilter(UI, "trial")
    end)

    Window.GetFilter("arena").control:SetHandler("OnClicked", function()
        Window.SetFilter(UI, "arena")
    end)

    ArcanumGuildHallTeleportWindow_TopActions_ButtonRefresh:SetHandler("OnClicked", function()
        Window.SoftRefresh(UI)
    end)

    ArcanumGuildHallTeleportWindow_TopActions_ButtonTeleport:SetHandler("OnClicked", function()
        Window.TeleportSelected(UI)
    end)

    ArcanumGuildHallTeleportWindow_ButtonClose:SetHandler("OnClicked", function()
        ArcanumGuildHall:HideTeleportWindow()
    end)

    ArcanumGuildHallTeleportWindow_ButtonSettings_Icon:SetAlpha(0.86)

    ArcanumGuildHallTeleportWindow_ButtonSettings:SetHandler("OnMouseEnter", function()
        ArcanumGuildHallTeleportWindow_ButtonSettings_Icon:SetAlpha(1.0)
    end)

    ArcanumGuildHallTeleportWindow_ButtonSettings:SetHandler("OnMouseExit", function()
        ArcanumGuildHallTeleportWindow_ButtonSettings_Icon:SetAlpha(0.86)
    end)

    ArcanumGuildHallTeleportWindow_ButtonSettings:SetHandler("OnClicked", function()
        if LAM2 and self.panel then
            LAM2:OpenToPanel(self.panel)
        end
    end)

    local searchContainer = Window.GetSearchContainer()
    local searchBox = Window.GetSearchBox()
    local searchHint = Window.GetSearchHint()
    local searchHintColor = Window.STYLE.search.placeholder

    searchHint:SetColor(searchHintColor[1], searchHintColor[2], searchHintColor[3], searchHintColor[4])

    searchContainer:SetMouseEnabled(true)
    searchContainer:SetHandler("OnMouseDown", function()
        searchBox:TakeFocus()
        Window.HideSearchHint()
    end)

    searchBox:SetMouseEnabled(true)
    searchBox:SetHandler("OnMouseDown", function(selfControl)
        selfControl:TakeFocus()
        Window.HideSearchHint()
    end)

    searchBox:SetHandler("OnTextChanged", function(selfControl)
        UI.pendingSearchText = selfControl:GetText() or ""

        if UI.pendingSearchText ~= "" then
            Window.HideSearchHint()
        else
            Window.RefreshSearchHint()
        end
    end)

    searchBox:SetHandler("OnFocusLost", function()
        Window.RefreshSearchHint()
    end)

    searchBox:SetHandler("OnEnter", function(selfControl)
        Window.ApplySearch(UI)
        selfControl:LoseFocus()
        Window.RefreshSearchHint()
    end)

    searchBox:SetHandler("OnEscape", function(selfControl)
        selfControl:LoseFocus()
        Window.RefreshSearchHint()
        ArcanumGuildHall:HideTeleportWindow()
        return true
    end)

    EVENT_MANAGER:RegisterForEvent(Teleport.EVENT_NAMESPACE .. "_GUILD_SELF_JOINED", EVENT_GUILD_SELF_JOINED, function()
        Window.RefreshGuildTab()
    end)

    EVENT_MANAGER:RegisterForEvent(Teleport.EVENT_NAMESPACE .. "_GUILD_SELF_LEFT", EVENT_GUILD_SELF_LEFT, function()
        Window.RefreshGuildTab()
    end)

    List.InitScrollList()
    Details.InitHintBox()
    Details.InitFavoriteButtons()
    Details.ApplyFonts()

    ArcanumGuildHallTeleportWindow_DetailsZoneValue:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    ArcanumGuildHallTeleportWindow_DetailsAccountValue:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    ArcanumGuildHallTeleportWindow_DetailsSourceValue:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    ArcanumGuildHallTeleportWindow_DetailsCostValue:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)

    Window.RefreshGuildTab()
    Window.UpdateTeleportButton(nil)
    Details.Clear(UI)
    Window.RefreshFilters(UI)
    Details.UpdateView(UI)
    Details.UpdateLoading(UI)
    Window.RefreshSearchHint()
    Details.RefreshHint()
    Details.UpdateFavorites(UI)

    UI.initialized = true

    refreshWindowState(false)

    zo_callLater(function()
        if UI.initialized then
            refreshWindowState(false)
        end
    end, 1)
end

function ArcanumGuildHall:RefreshTeleportWindow()
    if not UI.initialized then
        self:InitializeTeleportModule()
    end

    List.RefreshList(UI)
end

function ArcanumGuildHall:ToggleTeleportWindow()
    if ArcanumGuildHallTeleportWindow:IsHidden() then
        self:ShowTeleportWindow()
    else
        self:HideTeleportWindow()
    end
end

function ArcanumGuildHall:ShowTeleportWindow()
    if not UI.initialized then
        self:InitializeTeleportModule()
    end

    Window.RefreshTexts()
    Window.RefreshGuildTab()

    if self.db then
        UI.filters.category = self.db.lastTeleportCategoryFilter or "all"
        UI.filters.house = self.db.lastTeleportHouseFilter or "all"
        UI.filters.favoriteOnly = self.db.lastTeleportFavoriteOnly or false
    else
        UI.filters.category = UI.filters.category or "all"
        UI.filters.house = UI.filters.house or "all"
        UI.filters.favoriteOnly = UI.filters.favoriteOnly or false
    end

    local savedTab = self.db and self.db.lastTeleportTab or "network"

    Window.SetTab(UI, savedTab)
    ArcanumGuildHallTeleportWindow:SetHidden(false)

    Details.UpdateLoading(UI)
    Details.RefreshDetails(UI)
    refreshWindowState(true)

    zo_callLater(function()
        if not ArcanumGuildHallTeleportWindow:IsHidden() then
            refreshWindowState(true)
        end
    end, 10)
end

function ArcanumGuildHall:HideTeleportWindow()
    Teleport.CancelPlayerBuild()
    ArcanumGuildHallTeleportWindow:SetHidden(true)
end