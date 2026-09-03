if not IsConsoleUI() then return end

--------------------------------------------------
-- Config
--------------------------------------------------
local MENU_ID   = "WhereIsIt"
local ENTRY_ID  = 998
local LCM_SCENE = "LibConsoleMenuScene"

local ICON_INVENTORY = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_inventory.dds"
local ICON_BANK      = "EsoUI/Art/Bank/Gamepad/gp_bank_menuIcon_deposit.dds"
local ICON_CRAFTBAG  = "EsoUI/Art/Inventory/Gamepad/gp_inventory_icon_craftBag.dds"
local ICON_GUILD     = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_guilds.dds"
local ICON_HOUSE     = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_housing.dds"
local ICON_CURRENCY  = "/esoui/art/currency/gold_mipmap.dds"
local ICON_LIST      = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_activityFinder.dds"
local ICON_COMPANION = "EsoUI/Art/Companion/Gamepad/gp_companion_icon_inventory.dds"
local ICON_SETTINGS  = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_settings.dds"

local PAGE_SIZE = 50

local HIDE_FROM_ADDONS = true

local DIVIDER_TEXTURE = "EsoUI/Art/Windows/Gamepad/gp_nav1_horDivider.dds"
local DIVIDER_WIDTH   = 320
local DIVIDER_HEIGHT  = 8

local SECTION_DIVIDER = string.rep("-", 24)
if zo_iconFormat then
    SECTION_DIVIDER = zo_iconFormat(DIVIDER_TEXTURE, DIVIDER_WIDTH, DIVIDER_HEIGHT)
end

local SECTION_DIVIDER_2 = SECTION_DIVIDER .. "|c000000|r"

local MENU_COLOR = "D65AD6"
WHEREISIT_MENU_TITLE_COLORED = "|c" .. MENU_COLOR .. "Where Is It?|r"

local menu
local built           = false
local addedToMainMenu = false
local preselectHooked = false
local pendingSelect   = false

local pageState = {}

local activePageId  = nil
local pageKeybinds  = false

local searchQuery   = ""
local searchResults = {}

--------------------------------------------------
-- Helpers
--------------------------------------------------
local function LCM()
    return rawget(_G, "LibConsoleMenu")
end

local function SV()
    return WhereIsIt and WhereIsIt.savedVariables
end

local function FormatCount(n)
    n = tonumber(n) or 0
    if ZO_CommaDelimitNumber then return ZO_CommaDelimitNumber(n) end
    return tostring(n)
end

local function HasEntries(tbl)
    return type(tbl) == "table" and next(tbl) ~= nil
end

--------------------------------------------------
-- Tracked Sources
--------------------------------------------------
local TRACK_CHOICES = {
    { name = "Currencies",  value = "currencies" },
    { name = "Characters",  value = "characters" },
    { name = "Companions",  value = "companions" },
    { name = "Craft Bag",   value = "craftBag"   },
    { name = "Bank",        value = "bank"       },
    { name = "Guild Banks", value = "guildBanks" },
    { name = "Storage",     value = "storage"    },
}

local function IsTracked(key)
    if not (WhereIsIt and WhereIsIt.IsTracked) then return true end
    local ok, result = pcall(WhereIsIt.IsTracked, WhereIsIt, key)
    if not ok then return true end
    return result
end

local function TrackedValues()
    local selected = {}
    for i = 1, #TRACK_CHOICES do
        local key = TRACK_CHOICES[i].value
        if IsTracked(key) then selected[#selected + 1] = key end
    end
    return selected
end

local function SetTrackedValues(selected)
    local sv = SV()
    if not sv then return end

    sv.tracked = sv.tracked or {}

    local wanted = {}
    for i = 1, #(selected or {}) do
        wanted[selected[i]] = true
    end

    for i = 1, #TRACK_CHOICES do
        local key = TRACK_CHOICES[i].value
        local on  = wanted[key] == true
        local was = sv.tracked[key] ~= false

        sv.tracked[key] = on

        if was and not on and WhereIsIt and WhereIsIt.ClearTracked then
            pcall(WhereIsIt.ClearTracked, WhereIsIt, key)
        elseif on and not was and WhereIsIt and WhereIsIt.RescanTracked then
            pcall(WhereIsIt.RescanTracked, WhereIsIt, key)
        end
    end
end

--------------------------------------------------
-- Quality Colour
--------------------------------------------------
local QUALITY_HEX_FALLBACK = {
    [0] = "aaaaaa",
    [1] = "ffffff",
    [2] = "2dc50e",
    [3] = "3a92ff",
    [4] = "a02ee4",
    [5] = "e4c027",
}

local qualityHexCache = {}

local function QualityHex(quality)
    quality = quality or 1

    local cached = qualityHexCache[quality]
    if cached then return cached end

    local hex
    if GetItemQualityColor then
        local color = GetItemQualityColor(quality)
        if color and color.ToHex then
            local ok, result = pcall(color.ToHex, color)
            if ok and type(result) == "string" and result ~= "" then
                hex = result
            end
        end
    end

    hex = hex or QUALITY_HEX_FALLBACK[quality] or "ffffff"
    qualityHexCache[quality] = hex
    return hex
end

--------------------------------------------------
-- Currencies
--------------------------------------------------
local CURRENCIES = {
    {
        key = "gold", label = "Gold", hex = "FFCC00",
        currencyType = CURT_MONEY,
        icon = "/esoui/art/currency/gold_mipmap.dds",
    },
    {
        key = "alliancePoints", label = "Alliance Points", hex = "39FF14",
        currencyType = CURT_ALLIANCE_POINTS,
        icon = "/esoui/art/currency/alliancepoints.dds",
    },
    {
        key = "telVar", label = "Tel Var Stones", hex = "4499FF",
        currencyType = CURT_TELVAR_STONES,
        icon = "/esoui/art/currency/telvar_mipmap.dds",
    },
    {
        key = "writVouchers", label = "Writ Vouchers", hex = "FFFFFF",
        currencyType = CURT_WRIT_VOUCHERS,
        icon = "/esoui/art/icons/icon_writvoucher.dds",
    },
}

local function CurrencyIcon(currency)
    if currency.iconMarkup ~= nil then return currency.iconMarkup end

    local markup = ""
    if currency.icon and zo_iconFormat then
        markup = zo_iconFormat(currency.icon, "100%", "100%")
    end

    currency.iconMarkup = markup
    return markup
end

local function BankCurrencyAmount(currency)
    if not (GetCurrencyAmount and CURRENCY_LOCATION_BANK) then return 0 end
    return GetCurrencyAmount(currency.currencyType, CURRENCY_LOCATION_BANK) or 0
end

--------------------------------------------------
-- Alliance Colour
--------------------------------------------------
local allianceHexCache = {}

local function AllianceHex(alliance)
    if type(alliance) ~= "number" or not GetAllianceColor then return nil end

    local cached = allianceHexCache[alliance]
    if cached ~= nil then
        if cached == false then return nil end
        return cached
    end

    local hex
    local color = GetAllianceColor(alliance)
    if color and color.ToHex then
        local ok, result = pcall(color.ToHex, color)
        if ok and type(result) == "string" and result ~= "" then hex = result end
    end

    allianceHexCache[alliance] = hex or false
    return hex
end

local function AllianceColored(text, alliance)
    local hex = AllianceHex(alliance)
    if not hex then return text end
    return string.format("|c%s%s|r", hex, text)
end

local function GuildAlliance(guildId)
    if not GetGuildAlliance then return nil end
    local id = tonumber(guildId)
    if not id or id <= 0 then return nil end
    return GetGuildAlliance(id)
end

--------------------------------------------------
-- Item Collection
--------------------------------------------------
local CATEGORY_FILTER_BY_ORDER = {
    [2]  = ITEMFILTERTYPE_WEAPONS,
    [3]  = ITEMFILTERTYPE_ARMOR,
    [4]  = ITEMFILTERTYPE_CONSUMABLE,
    [5]  = ITEMFILTERTYPE_CRAFTING,
    [6]  = ITEMFILTERTYPE_FURNISHING,
    [7]  = ITEMFILTERTYPE_COMPANION,
    [8]  = ITEMFILTERTYPE_QUEST,
    [9]  = ITEMFILTERTYPE_JUNK,
    [10] = ITEMFILTERTYPE_MISCELLANEOUS,
}

local categoryLabelCache = {}

local function CategoryLabel(order)
    order = order or 10

    local cached = categoryLabelCache[order]
    if cached then return cached end

    local label
    if WhereIsIt and type(WhereIsIt.CategoryLabelForOrder) == "function" then
        local ok, result = pcall(WhereIsIt.CategoryLabelForOrder, order)
        if ok and type(result) == "string" and result ~= "" then
            label = result
        end
    end

    if not label then
        local filterType = CATEGORY_FILTER_BY_ORDER[order]
        if filterType then
            local resolved = GetString("SI_ITEMFILTERTYPE", filterType)
            if resolved and resolved ~= "" then label = resolved end
        end
    end

    label = label or "Miscellaneous"
    categoryLabelCache[order] = label
    return label
end

local WORN_LOCATIONS = {
    ["Worn"] = true,
    ["Companion Worn"] = true,
}

local function SortItems(list)
    table.sort(list, function(a, b)
        local orderA = a.catOrder or 10
        local orderB = b.catOrder or 10
        if orderA ~= orderB then return orderA < orderB end
        local nameA = zo_strlower(a.displayName or "")
        local nameB = zo_strlower(b.displayName or "")
        if nameA ~= nameB then return nameA < nameB end
        return (a.location or "") < (b.location or "")
    end)
end

local function CollectItems(tables, locationFilter)
    local list = {}
    for i = 1, #tables do
        local tbl = tables[i]
        if type(tbl) == "table" then
            for _, item in pairs(tbl) do
                if not locationFilter or item.location == locationFilter then
                    list[#list + 1] = item
                end
            end
        end
    end
    SortItems(list)
    return list
end

--------------------------------------------------
-- Tooltips
--------------------------------------------------
local function AddTooltipLine(parts, text)
    if text and text ~= "" then
        parts[#parts + 1] = text
    end
end

local pendingItem

local function BuildItemFallbackTooltip(item)
    local parts = {}

    AddTooltipLine(parts, string.format("|c%s%s|r",
        QualityHex(item.quality),
        item.displayName or ""))

    return table.concat(parts, "\n")
end

--------------------------------------------------
-- Centered Tooltip
--------------------------------------------------
local CENTER_STYLE = { horizontalAlignment = TEXT_ALIGN_CENTER }
local tooltipHooked = false

local function HookCenteredTooltip()
    if tooltipHooked then return end
    if not (ZO_Tooltip and ZO_PreHook) then return end
    tooltipHooked = true

    ZO_PreHook(ZO_Tooltip, "LayoutSettingTooltip", function(tooltip, tooltipText, warningText)
        local lcm = LCM()
        if not (menu and lcm and lcm.currentMenu == menu) then
            pendingItem = nil
            return false
        end

        local item = pendingItem
        pendingItem = nil

        if item and item.itemLink and item.itemLink ~= "" and tooltip.LayoutItem then
            local NOT_EQUIPPED = false
            local ok = pcall(function() tooltip:LayoutItem(item.itemLink, NOT_EQUIPPED) end)
            if ok then return true end
            tooltipText = BuildItemFallbackTooltip(item)
        end

        local bodySection = tooltip:AcquireSection(tooltip:GetStyle("bodySection"))
        bodySection:AddLine(tooltipText, tooltip:GetStyle("bodyDescription"), CENTER_STYLE)
        tooltip:AddSection(bodySection)

        if warningText and warningText ~= "" then
            local warningSection = tooltip:AcquireSection(tooltip:GetStyle("bodySection"))
            warningSection:AddLine(warningText, tooltip:GetStyle("bodyDescription"), tooltip:GetStyle("failed"), CENTER_STYLE)
            tooltip:AddSection(warningSection)
        end

        return true
    end)
end

--------------------------------------------------
-- Lazy Page Population
--------------------------------------------------
local function FindControlIndex(control)
    if not (menu and menu.controls and control) then return nil end
    for i = 1, #menu.controls do
        if menu.controls[i] == control then return i end
    end
    return nil
end

local function JumpToNextCategory(pageId)
    local state = pageState[pageId]
    if not (state and state.sectionStarts and #state.sectionStarts > 0) then return end

    local lcm  = LCM()
    local list = lcm and lcm.list
    if not (list and list.SetSelectedIndex) then return end

    local current = list.GetSelectedIndex and list:GetSelectedIndex() or 1
    local target

    for i = 1, #state.sectionStarts do
        if state.sectionStarts[i] > current then
            target = state.sectionStarts[i]
            break
        end
    end

    target = target or state.sectionStarts[1]

    list:SetSelectedIndex(target)
    if PlaySound and SOUNDS then PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD) end
end

local function SeedRow()
    return {
        type     = "button",
        name     = function() return "" end,
        disabled = true,
        func     = function() end,
    }
end

local function ApplyPageHeader(state)
    local config = state and state.headerConfig
    if not config then return end

    if (state.pageCount or 1) > 1 then
        config.titleText = string.format("%s  (%d/%d)", state.pageName or "", state.pageIndex or 1, state.pageCount)
    else
        config.titleText = state.pageName
    end

    if state.slotCount == 0 and state.wornCount > 0 then
        config.data1HeaderText = "Worn"
        config.data1Text       = FormatCount(state.wornCount)
        config.data2HeaderText = "Items"
        config.data2Text       = FormatCount(state.itemCount)
        config.data3HeaderText = nil
        config.data3Text       = nil

        local lcm = LCM()
        if lcm and lcm.RefreshSceneHeader then
            lcm:RefreshSceneHeader()
        end
        return
    end

    config.data1HeaderText = "Slots"
    config.data1Text       = FormatCount(state.slotCount)

    if state.wornCount > 0 then
        config.data2HeaderText = "Worn"
        config.data2Text       = FormatCount(state.wornCount)
        config.data3HeaderText = "Items"
        config.data3Text       = FormatCount(state.itemCount)
    else
        config.data2HeaderText = "Items"
        config.data2Text       = FormatCount(state.itemCount)
        config.data3HeaderText = nil
        config.data3Text       = nil
    end

    local lcm = LCM()
    if lcm and lcm.RefreshSceneHeader then
        lcm:RefreshSceneHeader()
    end
end

local function ClearPageHeader(state)
    local config = state and state.headerConfig
    if not config then return end

    config.titleText       = state.pageName
    config.data1HeaderText = nil
    config.data1Text       = nil
    config.data2HeaderText = nil
    config.data2Text       = nil
    config.data3HeaderText = nil
    config.data3Text       = nil
end

local GoToPage

local function BuildPageRows(pageId, state)
    local items     = state.items or {}
    local total     = #items
    local pageCount = state.pageCount or 1
    local pageIndex = state.pageIndex or 1

    local first = (pageIndex - 1) * PAGE_SIZE + 1
    local last  = first + PAGE_SIZE - 1
    if last > total then last = total end

    local options       = {}
    local sectionStarts = {}
    local leading       = 0

    if pageIndex > 1 and not pageKeybinds then
        local text = "|cFFCC00Previous Page|r"
        options[#options + 1] = {
            type    = "button",
            name    = function() return text end,
            tooltip = function()
                pendingItem = nil
                return ""
            end,
            func    = function() GoToPage(pageId, pageIndex - 1) end,
        }
        leading = leading + 1
    end

    local currentOrder, group

    for i = first, last do
        local item  = items[i]
        local order = item.catOrder or 10
        local label = string.format("|c%s%s|r  |c888888x%s|r",
            QualityHex(item.quality),
            item.displayName or "",
            FormatCount(item.count))

        if item.where then
            label = label .. "  |c777777" .. item.where .. "|r"
        end

        if order ~= currentOrder then
            currentOrder = order
            sectionStarts[#sectionStarts + 1] = leading + (i - first) + 1
            group = {
                type    = "section",
                name    = CategoryLabel(order),
                align   = "leftFlush",
                options = {},
            }
            options[#options + 1] = group
        end

        local rows = group.options
        rows[#rows + 1] = {
            type    = "button",
            name    = function() return label end,
            tooltip = function()
                pendingItem = item
                return ""
            end,
            func    = function() JumpToNextCategory(pageId) end,
        }
    end

    local hasNext = pageIndex < pageCount and not pageKeybinds
    if hasNext then
        local text = "|cFFCC00Next Page|r"
        options[#options + 1] = {
            type    = "button",
            name    = function() return text end,
            tooltip = function()
                pendingItem = nil
                return ""
            end,
            func    = function() GoToPage(pageId, pageIndex + 1) end,
        }
    end

    local compiled = LCM():ConvertOptions(options)
    for i = 1, #compiled do
        compiled[i].buttonText = "Next Category"
    end
    if leading > 0 and compiled[1] then
        compiled[1].buttonText = "Select"
    end
    if hasNext and compiled[#compiled] then
        compiled[#compiled].buttonText = "Select"
    end

    state.sectionStarts = sectionStarts
    state.firstShown    = first
    state.lastShown     = last

    return compiled
end

local function PopulatePage(submenu, pageId, getTables, locationFilter)
    local state = pageState[pageId]
    if not state or state.rowCount > 0 then return end

    local submenuIndex = FindControlIndex(submenu)
    if not submenuIndex then return end

    state.submenu = submenu

    local items = CollectItems(getTables() or {}, locationFilter)
    state.items      = items
    state.entryCount = #items

    local totalItems, bagSlots, wornSlots = 0, 0, 0
    for i = 1, #items do
        local item  = items[i]
        local slots = tonumber(item.slots) or 1
        totalItems = totalItems + (tonumber(item.count) or 0)
        if WORN_LOCATIONS[item.location or ""] then
            wornSlots = wornSlots + slots
        else
            bagSlots = bagSlots + slots
        end
    end
    state.itemCount = totalItems
    state.slotCount = bagSlots
    state.wornCount = wornSlots

    if #items == 0 then return end

    state.pageIndex = 1
    state.pageCount = math.ceil(#items / PAGE_SIZE)

    local compiled = BuildPageRows(pageId, state)

    local ok = pcall(function()
        menu:AddControls(compiled, submenuIndex + 2)
        menu:RemoveControls(submenuIndex + 1, 1)
    end)

    if ok then
        state.rowCount = #compiled
        state.seeded   = false
        activePageId   = pageId
        ApplyPageHeader(state)
        if menu.SelectFirstRow then
            pcall(function() menu:SelectFirstRow() end)
        end
    end
end

GoToPage = function(pageId, target)
    local state = pageState[pageId]
    if not state or state.rowCount == 0 then return end

    local pageCount = state.pageCount or 1
    if target < 1 then target = 1 end
    if target > pageCount then target = pageCount end
    if target == state.pageIndex then return end

    local submenuIndex = FindControlIndex(state.submenu)
    if not submenuIndex then return end

    local oldCount = state.rowCount
    state.pageIndex = target

    local compiled = BuildPageRows(pageId, state)
    local newCount = #compiled
    if newCount == 0 then return end

    local ok = pcall(function()
        menu:AddControls(compiled, submenuIndex + 1)
        menu:RemoveControls(submenuIndex + 1 + newCount, oldCount)
    end)

    if ok then
        state.rowCount = newCount
        ApplyPageHeader(state)

        local lcm = LCM()
        if lcm and lcm.scrollList and lcm.scrollList.RefreshKeybinds then
            pcall(function() lcm.scrollList:RefreshKeybinds() end)
        end

        if menu.SelectFirstRow then
            pcall(function() menu:SelectFirstRow() end)
        end
    end
end

local function DepopulatePage(submenu, pageId)
    local state = pageState[pageId]
    if not state or state.rowCount == 0 then return end

    if activePageId == pageId then activePageId = nil end

    local count = state.rowCount
    state.rowCount      = 0
    state.sectionStarts = nil
    state.items         = nil
    state.submenu       = nil
    state.pageIndex     = 1
    state.pageCount     = 1
    state.firstShown    = nil
    state.lastShown     = nil
    ClearPageHeader(state)

    zo_callLater(function()
        local submenuIndex = FindControlIndex(submenu)
        if not submenuIndex then return end
        local ok = pcall(function()
            menu:AddControls(LCM():ConvertOptions({ SeedRow() }), submenuIndex + 1)
            menu:RemoveControls(submenuIndex + 2, count)
        end)
        if ok then state.seeded = true end
    end, 0)
end

local function ItemPage(pageId, name, icon, getTables, locationFilter, label)
    local titleName    = (type(label) == "string" and label) or name
    local headerConfig = { titleText = titleName }

    pageState[pageId] = {
        rowCount = 0, itemCount = 0, entryCount = 0,
        slotCount = 0, wornCount = 0, seeded = true,
        pageIndex = 1, pageCount = 1, pageName = titleName,
        headerConfig = headerConfig,
    }

    return {
        type          = "submenu",
        name          = label or name,
        icon          = icon,
        childrenAlign = "leftFlush",
        header        = headerConfig,
        onEnter       = function(submenu) PopulatePage(submenu, pageId, getTables, locationFilter) end,
        onExit        = function(submenu) DepopulatePage(submenu, pageId) end,
        options       = { SeedRow() },
    }
end

--------------------------------------------------
-- Menu Sections
--------------------------------------------------
local function SortedCharacterIds()
    local sv = SV()
    if not sv or not sv.characters then return {} end

    local currentId = tostring(GetCurrentCharacterId and GetCurrentCharacterId() or "")
    local ids = {}
    for charId in pairs(sv.characters) do
        ids[#ids + 1] = charId
    end

    table.sort(ids, function(a, b)
        if a == currentId then return true end
        if b == currentId then return false end
        local nameA = sv.characters[a].name or a
        local nameB = sv.characters[b].name or b
        return zo_strlower(nameA) < zo_strlower(nameB)
    end)

    return ids
end

local function ApplyCurrencyHeader(currency, config)
    local sv = SV()
    if not (config and sv and sv.characters) then return end

    local total = BankCurrencyAmount(currency)
    for _, data in pairs(sv.characters) do
        total = total + ((data.currencies and data.currencies[currency.key]) or 0)
    end

    config.data1HeaderText = "Total"
    config.data1Text       = string.format("|c%s%s|r", currency.hex, FormatCount(total))

    local lcm = LCM()
    if lcm and lcm.RefreshSceneHeader then
        lcm:RefreshSceneHeader()
    end
end

--------------------------------------------------
-- Search
--------------------------------------------------
local setNameCache = {}

local function SetNameKey(itemLink)
    if not itemLink or itemLink == "" or not GetItemLinkSetInfo then return nil end

    local cached = setNameCache[itemLink]
    if cached ~= nil then
        if cached == false then return nil end
        return cached
    end

    local hasSet, setName = GetItemLinkSetInfo(itemLink)
    if hasSet and setName and setName ~= "" then
        if zo_strformat and SI_ITEM_FORMAT_STR_SET_NAME_NO_COUNT then
            setName = zo_strformat(SI_ITEM_FORMAT_STR_SET_NAME_NO_COUNT, setName)
        end
        setName = zo_strlower(setName)
        setNameCache[itemLink] = setName
        return setName
    end

    setNameCache[itemLink] = false
    return nil
end

local function AddMatches(results, tbl, where, query)
    if type(tbl) ~= "table" then return end

    for _, item in pairs(tbl) do
        local name = item.displayName
        local hit  = name ~= nil and zo_strlower(name):find(query, 1, true) ~= nil

        if not hit then
            local setName = SetNameKey(item.itemLink)
            hit = setName ~= nil and setName:find(query, 1, true) ~= nil
        end

        if name and hit then
            results[#results + 1] = {
                displayName = name,
                count       = item.count,
                quality     = item.quality,
                catOrder    = item.catOrder,
                itemLink    = item.itemLink,
                slots       = item.slots,
                location    = where,
                where       = where,
            }
        end
    end
end

local function RunSearch()
    searchResults = {}

    local query = zo_strlower(searchQuery or "")
    if query == "" then return end

    local sv = SV()
    if not sv then return end

    local ids = SortedCharacterIds()
    for i = 1, #ids do
        local data = sv.characters[ids[i]]
        if data then
            AddMatches(searchResults, data.items, data.name or ("Char " .. ids[i]), query)
        end
    end

    local account = sv.account
    if not account then return end

    for _, companion in pairs(account.companions or {}) do
        AddMatches(searchResults, companion.items, companion.name or "Companion", query)
    end

    AddMatches(searchResults, account.craftBag, "Craft Bag", query)
    AddMatches(searchResults, account.bank, "Bank", query)

    for _, guild in pairs(account.guildBanks or {}) do
        AddMatches(searchResults, guild.items, guild.name or "Guild Bank", query)
    end

    for _, chest in pairs(account.houseChests or {}) do
        local where = chest.name or "Chest"
        if chest.house then where = where .. " - " .. chest.house end
        AddMatches(searchResults, chest.items, where, query)
    end

    AddMatches(searchResults, account.furnitureVault, "Furniture Vault", query)
end

local function SearchResultsLabel()
    if searchQuery == "" then return "Results" end
    return string.format("Results  |c888888(%s)|r", FormatCount(#searchResults))
end

local function SetSearchQuery(text)
    searchQuery = text or ""
    RunSearch()

    local lcm = LCM()
    if menu and lcm and lcm.currentMenu == menu and menu.UpdateControls then
        pcall(function() menu:UpdateControls() end)
    end
end

local function BuildSearchSection()
    local searchRow = {
        type               = "editbox",
        name               = "Search",
        maxInputCharacters = 50,
        getFunc            = function() return searchQuery end,
        setFunc            = SetSearchQuery,
    }

    local resultsPage = ItemPage(
        "search",
        "Results",
        ICON_LIST,
        function() return { searchResults } end,
        nil,
        SearchResultsLabel)

    return searchRow, resultsPage
end

local function BuildCurrencySection()
    if not IsTracked("currencies") then return nil end
    local sv = SV()
    if not sv or not sv.characters then return nil end

    local currencySubmenus = {}

    for c = 1, #CURRENCIES do
        local currency = CURRENCIES[c]
        local rows = {}

        local bankAmount = BankCurrencyAmount(currency)
        if bankAmount > 0 then
            rows[#rows + 1] = {
                type    = "button",
                name    = function()
                    return string.format("%s |c%s%s|r  Bank",
                        CurrencyIcon(currency),
                        currency.hex,
                        FormatCount(BankCurrencyAmount(currency)))
                end,
                func    = function() end,
            }
        end

        local ids = SortedCharacterIds()
        for i = 1, #ids do
            local charId   = ids[i]
            local data     = sv.characters[charId]
            local charName = data.name or ("Char " .. charId)
            local amount   = (data.currencies and data.currencies[currency.key]) or 0

            if amount > 0 then
                rows[#rows + 1] = {
                    type    = "button",
                    name    = function()
                        local current = (sv.characters[charId] and sv.characters[charId].currencies
                                         and sv.characters[charId].currencies[currency.key]) or 0
                        return string.format("%s |c%s%s|r  %s",
                            CurrencyIcon(currency),
                            currency.hex,
                            FormatCount(current),
                            charName)
                    end,
                    func    = function() end,
                }
            end
        end

        if #rows > 0 then
            local headerConfig = {}
            currencySubmenus[#currencySubmenus + 1] = {
                type          = "submenu",
                name          = string.format("|c%s%s|r", currency.hex, currency.label),
                icon          = currency.icon,
                childrenAlign = "leftFlush",
                header        = headerConfig,
                onEnter       = function() ApplyCurrencyHeader(currency, headerConfig) end,
                options       = rows,
            }
        end
    end

    if #currencySubmenus == 0 then return nil end

    return {
        type    = "submenu",
        name    = "Currencies",
        icon    = ICON_CURRENCY,
        options = currencySubmenus,
    }
end

local function BuildCharacterSection()
    if not IsTracked("characters") then return nil end
    local sv = SV()
    if not sv or not sv.characters then return nil end

    local options = {}
    local ids     = SortedCharacterIds()

    for i = 1, #ids do
        local charId   = ids[i]
        local data     = sv.characters[charId]
        local charName = data.name or ("Char " .. charId)

        if HasEntries(data.items) then
            options[#options + 1] = ItemPage(
                "char:" .. charId,
                charName,
                ICON_INVENTORY,
                function()
                    local current = SV() and SV().characters and SV().characters[charId]
                    if not current then return {} end
                    return { current.items }
                end,
                nil,
                AllianceColored(charName, data.alliance))
        end
    end

    if #options == 0 then return nil end

    return {
        type    = "submenu",
        name    = "Characters",
        icon    = ICON_INVENTORY,
        options = options,
    }
end

local function BuildCompanionSection()
    if not IsTracked("companions") then return nil end
    local sv      = SV()
    local account = sv and sv.account
    if not (account and HasEntries(account.companions)) then return nil end

    local keys = {}
    for key in pairs(account.companions) do
        keys[#keys + 1] = key
    end

    table.sort(keys, function(a, b)
        local nameA = account.companions[a].name or a
        local nameB = account.companions[b].name or b
        return zo_strlower(nameA) < zo_strlower(nameB)
    end)

    local options = {}
    for i = 1, #keys do
        local key  = keys[i]
        local data = account.companions[key]
        if HasEntries(data.items) then
            options[#options + 1] = ItemPage(
                "companion:" .. key,
                data.name or key,
                ICON_COMPANION,
                function()
                    local current = SV() and SV().account and SV().account.companions
                    current = current and current[key]
                    if not current then return {} end
                    return { current.items }
                end)
        end
    end

    if #options == 0 then return nil end

    return {
        type    = "submenu",
        name    = "Companions",
        icon    = ICON_COMPANION,
        options = options,
    }
end

local function CurrentGuildIds()
    local ids = {}
    if not (GetNumGuilds and GetGuildId) then return ids end
    for i = 1, GetNumGuilds() do
        local guildId = GetGuildId(i)
        if guildId and guildId ~= 0 then
            ids[tostring(guildId)] = true
        end
    end
    return ids
end

local function BuildGuildSection()
    if not IsTracked("guildBanks") then return nil end
    if WhereIsIt and type(WhereIsIt.PruneLeftGuilds) == "function" then
        pcall(WhereIsIt.PruneLeftGuilds, WhereIsIt)
    end

    local sv = SV()
    local guildBanks = sv and sv.account and sv.account.guildBanks
    if not HasEntries(guildBanks) then return nil end

    local currentIds  = CurrentGuildIds()
    local filterStale = next(currentIds) ~= nil

    local guildIds = {}
    for guildId, guild in pairs(guildBanks) do
        if HasEntries(guild.items) and (not filterStale or currentIds[guildId]) then
            guildIds[#guildIds + 1] = guildId
        end
    end

    if #guildIds == 0 then return nil end

    table.sort(guildIds, function(a, b)
        local nameA = guildBanks[a].name or a
        local nameB = guildBanks[b].name or b
        return zo_strlower(nameA) < zo_strlower(nameB)
    end)

    local options = {}
    for i = 1, #guildIds do
        local guildId   = guildIds[i]
        local guildName = guildBanks[guildId].name or "Guild Bank"

        options[#options + 1] = ItemPage(
            "guild:" .. guildId,
            guildName,
            ICON_GUILD,
            function()
                local current = SV() and SV().account and SV().account.guildBanks
                                and SV().account.guildBanks[guildId]
                if not current then return {} end
                return { current.items }
            end,
            nil,
            AllianceColored(guildName, GuildAlliance(guildId)))
    end

    return {
        type    = "submenu",
        name    = "Guild Banks",
        icon    = ICON_GUILD,
        options = options,
    }
end

local function BuildChestPagesByHouse(chests)
    local houses, order = {}, {}

    for key, chest in pairs(chests) do
        if type(chest) == "table" and HasEntries(chest.items) then
            local houseName = chest.house or "Unknown House"
            if not houses[houseName] then
                houses[houseName] = {}
                order[#order + 1] = houseName
            end
            local list = houses[houseName]
            list[#list + 1] = { key = key, name = chest.name or "House Chest" }
        end
    end

    table.sort(order, function(a, b) return zo_strlower(a) < zo_strlower(b) end)

    local houseSubmenus = {}
    for i = 1, #order do
        local houseName = order[i]
        local list = houses[houseName]

        table.sort(list, function(a, b)
            local nameA, nameB = zo_strlower(a.name), zo_strlower(b.name)
            if nameA ~= nameB then return nameA < nameB end
            return a.key < b.key
        end)

        local chestPages = {}
        for j = 1, #list do
            local key = list[j].key
            chestPages[#chestPages + 1] = ItemPage(
                "chest:" .. key,
                list[j].name,
                ICON_HOUSE,
                function()
                    local current = SV() and SV().account and SV().account.houseChests
                    current = current and current[key]
                    if not current then return {} end
                    return { current.items }
                end)
        end

        houseSubmenus[#houseSubmenus + 1] = {
            type    = "submenu",
            name    = houseName,
            icon    = ICON_HOUSE,
            options = chestPages,
        }
    end

    return houseSubmenus
end

local function BuildStorageSection()
    if not IsTracked("storage") then return nil end
    local sv = SV()
    local account = sv and sv.account
    if not account then return nil end

    local options = {}

    if HasEntries(account.houseChests) then
        local houseSubmenus = BuildChestPagesByHouse(account.houseChests)
        if #houseSubmenus > 0 then
            options[#options + 1] = {
                type    = "submenu",
                name    = "Storage Chests",
                icon    = ICON_HOUSE,
                options = houseSubmenus,
            }
        end
    end

    if HasEntries(account.furnitureVault) then
        options[#options + 1] = ItemPage(
            "furnitureVault",
            "Furniture Vault",
            ICON_HOUSE,
            function() return { SV().account.furnitureVault } end)
    end

    if #options == 0 then return nil end

    return {
        type    = "submenu",
        name    = "Storage",
        icon    = ICON_HOUSE,
        options = options,
    }
end

local function BuildSettingsSection()
    return {
        type          = "submenu",
        name          = "Settings",
        icon          = ICON_SETTINGS,
        childrenAlign = "center",
        options       = {
            {
                type    = "checklist",
                name    = "Track",
                choices = TRACK_CHOICES,
                getFunc = TrackedValues,
                setFunc = SetTrackedValues,
                tooltip = "Choose what Where Is It? keeps track of.\n\n"
                       .. "Unticking something stops it being scanned AND deletes what has "
                       .. "already been saved for it, so it disappears from the list.\n\n"
                       .. "Tick it again and it comes back empty - you will need to visit it "
                       .. "once more (log in the character, open the bank, enter the guild "
                       .. "bank, visit the house) before anything shows up.\n\n"
                       .. "The list updates the next time you open Where Is It?.",
            },
            {
                type    = "button",
                name    = "Scan This Character",
                tooltip = "Rescans the character you are on right now - inventory, worn gear, "
                       .. "companion gear and currencies - plus the craft bag.\n\n"
                       .. "Everything else needs the container open: visit a bank, a guild bank "
                       .. "or a house and it saves itself.\n\n"
                       .. "The list updates the next time you open Where Is It?.",
                func    = function()
                    if not WhereIsIt then return end
                    if WhereIsIt.ScanCharacter then pcall(WhereIsIt.ScanCharacter, WhereIsIt) end
                    if WhereIsIt.ScanCraftBag  then pcall(WhereIsIt.ScanCraftBag,  WhereIsIt) end
                end,
            },
        },
    }
end

local function BuildOptions()
    local sv = SV()
    local account = sv and sv.account
    local options = {}
    local located = {}

    local function Append(section)
        if section then located[#located + 1] = section end
    end

    local searchRow, resultsPage = BuildSearchSection()
    options[#options + 1] = searchRow
    options[#options + 1] = resultsPage

    Append(BuildCurrencySection())
    Append(BuildCharacterSection())
    Append(BuildCompanionSection())

    if IsTracked("craftBag") and account and HasEntries(account.craftBag) then
        Append(ItemPage("craftBag", "Craft Bag", ICON_CRAFTBAG,
            function() return { SV().account.craftBag } end))
    end

    if IsTracked("bank") and account and HasEntries(account.bank) then
        Append(ItemPage("bank", "Bank", ICON_BANK,
            function() return { SV().account.bank } end))
    end

    Append(BuildGuildSection())
    Append(BuildStorageSection())

    if #located > 0 then
        options[#options + 1] = {
            type    = "section",
            name    = SECTION_DIVIDER,
            options = located,
        }
    end

    options[#options + 1] = {
        type    = "section",
        name    = SECTION_DIVIDER_2,
        options = { BuildSettingsSection() },
    }

    return options
end

RebuildContents = function()
    if not menu then return end

    pageState = {}

    pcall(function() menu:RemoveAllControls() end)
    menu:AddOptions(BuildOptions())
end

--------------------------------------------------
-- Menu Colour
--------------------------------------------------
local function PaintMenuEntry(entry)
    if not entry then return false end
    local data  = entry.data
    local addon = data and data.addon
    if not addon or addon.menuId ~= MENU_ID then return false end
    if entry.text == WHEREISIT_MENU_TITLE_COLORED then return false end

    entry.text = WHEREISIT_MENU_TITLE_COLORED
    if entry.SetText then entry:SetText(WHEREISIT_MENU_TITLE_COLORED) end
    addon.displayTitle = WHEREISIT_MENU_TITLE_COLORED
    return true
end

local function ApplyMenuColor()
    local changed = false

    if menu and menu.displayTitle ~= WHEREISIT_MENU_TITLE_COLORED then
        menu.displayTitle = WHEREISIT_MENU_TITLE_COLORED
        changed = true
    end

    if ZO_MENU_ENTRIES then
        for _, entry in ipairs(ZO_MENU_ENTRIES) do
            local subMenu = entry.subMenu or (entry.data and entry.data.subMenu)
            if subMenu then
                for _, child in ipairs(subMenu) do
                    changed = PaintMenuEntry(child) or changed
                end
            end
        end
    end

    if changed and MAIN_MENU_GAMEPAD and MAIN_MENU_GAMEPAD.RefreshMainList then
        MAIN_MENU_GAMEPAD:RefreshMainList()
    end

    return changed
end

local function HookTooltipColor()
    local lcm = LCM()
    if not lcm then return end
    if type(lcm.GetAddonManifestMeta) ~= "function" or lcm.whereIsItTooltipColorHook then return end

    lcm.whereIsItTooltipColorHook = lcm.GetAddonManifestMeta
    lcm.GetAddonManifestMeta = function(addon, ...)
        local meta = lcm.whereIsItTooltipColorHook(addon, ...)
        if meta and type(addon) == "table" and addon.menuId == MENU_ID then
            if meta.title and meta.title ~= "" then
                meta.title = WHEREISIT_MENU_TITLE_COLORED
            end
        end
        return meta
    end
end

local function HookMenuEntryColor()
    HookTooltipColor()

    local lcm = LCM()
    if lcm and type(lcm.InjectIntoAddonsMenu) == "function" and not lcm.whereIsItTitleColorHook then
        lcm.whereIsItTitleColorHook = lcm.InjectIntoAddonsMenu
        lcm.InjectIntoAddonsMenu = function(libSelf, ...)
            local result = lcm.whereIsItTitleColorHook(libSelf, ...)
            pcall(ApplyMenuColor)
            return result
        end
    end
end

local function PagedState()
    if not activePageId then return nil end

    local lcm = LCM()
    if not (menu and lcm and lcm.currentMenu == menu) then return nil end

    local state = pageState[activePageId]
    if not (state and (state.pageCount or 1) > 1) then return nil end

    return state
end

local function InstallPageKeybinds()
    if pageKeybinds then return end

    local lcm = LCM()
    local scrollList = lcm and lcm.scrollList
    local descriptor = scrollList and scrollList.keybindStripDescriptor
    if type(descriptor) ~= "table" then return end

    descriptor[#descriptor + 1] = {
        alignment    = KEYBIND_STRIP_ALIGN_RIGHT,
        name         = "Previous Page",
        keybind      = "UI_SHORTCUT_LEFT_SHOULDER",
        gamepadOrder = 4,
        callback     = function()
            local state = PagedState()
            if state then GoToPage(activePageId, (state.pageIndex or 1) - 1) end
        end,
        visible      = function()
            local state = PagedState()
            return state ~= nil and (state.pageIndex or 1) > 1
        end,
    }

    descriptor[#descriptor + 1] = {
        alignment    = KEYBIND_STRIP_ALIGN_RIGHT,
        name         = "Next Page",
        keybind      = "UI_SHORTCUT_RIGHT_SHOULDER",
        gamepadOrder = 3,
        callback     = function()
            local state = PagedState()
            if state then GoToPage(activePageId, (state.pageIndex or 1) + 1) end
        end,
        visible      = function()
            local state = PagedState()
            return state ~= nil and (state.pageIndex or 1) < state.pageCount
        end,
    }

    pageKeybinds = true
end

local function BuildMenu()
    if built then return end
    local lcm = LCM()
    if not lcm or type(lcm.CreateAddonMenu) ~= "function" then return end
    if not SV() then return end

    menu = lcm:CreateAddonMenu(MENU_ID, {
        title         = "Where Is It?",
        author        = "user562",
        version       = WhereIsIt.version,
        childrenAlign = "center",
    })
    if not menu then return end

    built = true
    InstallPageKeybinds()
    HookCenteredTooltip()
    HookMenuEntryColor()
    ApplyMenuColor()

    menu:AddOptions(BuildOptions())
end

--------------------------------------------------
-- Main Menu Integration
--------------------------------------------------
local function FindMenuInstance()
    local lcm = LCM()
    if not (lcm and lcm.menus) then return nil end
    for i = 1, #lcm.menus do
        if lcm.menus[i].menuId == MENU_ID then return lcm.menus[i] end
    end
    return nil
end

local function MenuIsOnScreen()
    local lcm = LCM()
    if not (lcm and lcm.currentMenu == menu) then return false end
    if not (SCENE_MANAGER and SCENE_MANAGER.IsShowing) then return true end
    return SCENE_MANAGER:IsShowing(LCM_SCENE) and true or false
end

local function RefreshOnEntry(force)
    if not (built and menu) then return end
    InstallPageKeybinds()
    if not force and MenuIsOnScreen() then return end
    RebuildContents()
end

local function SelectMenu()
    local lcm = LCM()
    local instance = FindMenuInstance()
    if not (lcm and instance) then return end
    instance:Select()
    if lcm.RefreshSceneHeader then lcm:RefreshSceneHeader() end
end

local function HookPreselect()
    local lcm = LCM()
    if preselectHooked or not (lcm and lcm.scene) then return end
    preselectHooked = true

    lcm.scene:RegisterCallback("StateChange", function(_, newState)
        if newState ~= SCENE_SHOWING or not pendingSelect then return end
        pendingSelect = false
        InstallPageKeybinds()
        RefreshOnEntry(true)
        SelectMenu()
    end)
end

function WhereIsIt.OpenMenu()
    BuildMenu()
    RefreshOnEntry()

    if not SCENE_MANAGER then return end

    pendingSelect = true
    HookPreselect()
    SCENE_MANAGER:Show(LCM_SCENE)

    if SCENE_MANAGER.IsShowing and SCENE_MANAGER:IsShowing(LCM_SCENE) then
        pendingSelect = false
        SelectMenu()
    end
end

local function AddToMainMenu()
    if addedToMainMenu or not ZO_MENU_ENTRIES then return end

    for i = 1, #ZO_MENU_ENTRIES do
        if ZO_MENU_ENTRIES[i].id == ENTRY_ID then
            addedToMainMenu = true
            return
        end
    end

    local title = WHEREISIT_MENU_TITLE_COLORED

    local entry = ZO_GamepadEntryData:New(title, ICON_LIST)
    entry:SetIconTintOnSelection(true)
    entry:SetIconDisabledTintOnSelection(true)
    entry.id = ENTRY_ID

    entry.data = {
        name  = title,
        id    = ENTRY_ID,
        scene = LCM_SCENE,

        onSelectedCallback = function()
            pendingSelect = true
            HookPreselect()
        end,

        onUnselectedCallback = function()
            pendingSelect = false
        end,
    }

    local insertIndex
    if ZO_MENU_MAIN_ENTRIES and ZO_MENU_MAIN_ENTRIES.INVENTORY then
        for i = 1, #ZO_MENU_ENTRIES do
            if ZO_MENU_ENTRIES[i].id == ZO_MENU_MAIN_ENTRIES.INVENTORY then
                insertIndex = i + 1
                break
            end
        end
    end

    if insertIndex then
        table.insert(ZO_MENU_ENTRIES, insertIndex, entry)
    else
        table.insert(ZO_MENU_ENTRIES, entry)
    end

    addedToMainMenu = true

    if MAIN_MENU_GAMEPAD then
        MAIN_MENU_GAMEPAD:RefreshLists()
        MAIN_MENU_GAMEPAD:UpdateEntryEnabledStates()
    end
end

--------------------------------------------------
-- Add-Ons Menu
--------------------------------------------------
local function RemoveFromAddonsMenu()
    if not HIDE_FROM_ADDONS or not ZO_MENU_ENTRIES then return end

    local removed = false
    for i = 1, #ZO_MENU_ENTRIES do
        local subMenu = ZO_MENU_ENTRIES[i].subMenu
        if subMenu then
            for j = #subMenu, 1, -1 do
                local data = subMenu[j].data
                if data and data.addon and data.addon.menuId == MENU_ID then
                    table.remove(subMenu, j)
                    removed = true
                end
            end
        end
    end

    if removed and MAIN_MENU_GAMEPAD then
        MAIN_MENU_GAMEPAD:RefreshLists()
        MAIN_MENU_GAMEPAD:UpdateEntryEnabledStates()
    end
end

--------------------------------------------------
-- Wiring
--------------------------------------------------
EVENT_MANAGER:RegisterForEvent("WhereIsIt_Menu", EVENT_PLAYER_ACTIVATED, function()
    BuildMenu()
    AddToMainMenu()
    EVENT_MANAGER:UnregisterForEvent("WhereIsIt_Menu", EVENT_PLAYER_ACTIVATED)
end)

if MAIN_MENU_GAMEPAD_SCENE then
    MAIN_MENU_GAMEPAD_SCENE:RegisterCallback("StateChange", function(_, newState)
        if newState ~= SCENE_SHOWING then return end
        BuildMenu()
        AddToMainMenu()
        HookPreselect()
        ApplyMenuColor()
        RemoveFromAddonsMenu()
        RefreshOnEntry()
    end)
end
