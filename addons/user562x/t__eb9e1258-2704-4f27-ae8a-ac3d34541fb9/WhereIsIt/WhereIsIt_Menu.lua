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

local menu
local built           = false
local addedToMainMenu = false
local preselectHooked = false
local pendingSelect   = false

local pageState = {}

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

local function BankCurrencyAmount(currency)
    if not (GetCurrencyAmount and CURRENCY_LOCATION_BANK) then return 0 end
    return GetCurrencyAmount(currency.currencyType, CURRENCY_LOCATION_BANK) or 0
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

local function SortItems(list)
    table.sort(list, function(a, b)
        local orderA = a.catOrder or 10
        local orderB = b.catOrder or 10
        if orderA ~= orderB then return orderA < orderB end
        local nameA = zo_strlower(a.displayName or a.searchName or "")
        local nameB = zo_strlower(b.displayName or b.searchName or "")
        if nameA ~= nameB then return nameA < nameB end
        return (a.location or "") < (b.location or "")
    end)
end

local function CollectItems(tables)
    local list = {}
    for i = 1, #tables do
        local tbl = tables[i]
        if type(tbl) == "table" then
            for _, item in pairs(tbl) do
                list[#list + 1] = item
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

local function AppendItemDetails(parts, link)
    local details = {}

    if GetItemLinkTraitType then
        local traitType = GetItemLinkTraitType(link)
        if traitType and traitType ~= 0 then
            AddTooltipLine(details, GetString("SI_ITEMTRAITTYPE", traitType))
        end
    end

    if GetItemLinkArmorType then
        local armorType = GetItemLinkArmorType(link)
        if armorType and armorType ~= 0 then
            AddTooltipLine(details, GetString("SI_ARMORTYPE", armorType))
        end
    end

    local championPoints = GetItemLinkRequiredChampionPoints and GetItemLinkRequiredChampionPoints(link) or 0
    local level          = GetItemLinkRequiredLevel and GetItemLinkRequiredLevel(link) or 0
    if championPoints > 0 then
        AddTooltipLine(details, "Champion " .. championPoints)
    elseif level > 0 then
        AddTooltipLine(details, "Level " .. level)
    end

    if #details > 0 then
        AddTooltipLine(parts, "")
        for i = 1, #details do
            parts[#parts + 1] = details[i]
        end
    end
end

local function AppendSetBonuses(parts, link)
    if not GetItemLinkSetInfo then return end

    local hasSet, setName, numBonuses = GetItemLinkSetInfo(link)
    if not hasSet then return end

    AddTooltipLine(parts, "")
    AddTooltipLine(parts, string.format("|cFFCC00%s|r", setName or ""))

    if not (GetItemLinkSetBonusInfo and numBonuses) then return end

    for bonusIndex = 1, numBonuses do
        local _, bonusDescription = GetItemLinkSetBonusInfo(link, false, bonusIndex)
        AddTooltipLine(parts, bonusDescription)
    end
end

local function BuildItemTooltip(item, contextName)
    local parts = {}

    if item.icon and item.icon ~= "" and zo_iconFormat then
        AddTooltipLine(parts, zo_iconFormat(item.icon, 64, 64))
    end

    AddTooltipLine(parts, string.format("|c%s%s|r",
        QualityHex(item.quality),
        item.displayName or item.searchName or ""))

    if contextName and contextName ~= "" then
        AddTooltipLine(parts, contextName .. " - " .. (item.location or ""))
    else
        AddTooltipLine(parts, item.location or "")
    end

    AddTooltipLine(parts, "Count: " .. FormatCount(item.count))

    local link = item.itemLink
    if link and link ~= "" then
        AppendItemDetails(parts, link)
        AppendSetBonuses(parts, link)
    end

    return table.concat(parts, "\n")
end

local function BuildCurrencyTooltip(currency, holderName, amount)
    local parts = {}

    if currency.icon and zo_iconFormat then
        AddTooltipLine(parts, zo_iconFormat(currency.icon, 64, 64))
    end

    AddTooltipLine(parts, string.format("|c%s%s|r", currency.hex, currency.label))
    AddTooltipLine(parts, holderName)
    AddTooltipLine(parts, FormatCount(amount))

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
        if not (menu and lcm and lcm.currentMenu == menu) then return false end

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

local function PopulatePage(submenu, pageId, getTables, contextName)
    local state = pageState[pageId]
    if not state or state.rowCount > 0 then return end

    local submenuIndex = FindControlIndex(submenu)
    if not submenuIndex then return end

    local items = CollectItems(getTables() or {})
    state.entryCount = #items

    local totalItems, totalSlots = 0, 0
    for i = 1, #items do
        totalItems = totalItems + (tonumber(items[i].count) or 0)
        totalSlots = totalSlots + (tonumber(items[i].slots) or 1)
    end
    state.itemCount = totalItems
    state.slotCount = totalSlots

    if #items == 0 then return end

    local grouped = {}
    local currentOrder

    for i = 1, #items do
        local item  = items[i]
        local order = item.catOrder or 10
        local label = string.format("|c%s%s|r  |c888888x%s|r",
            QualityHex(item.quality),
            item.displayName or item.searchName or "",
            FormatCount(item.count))

        if order ~= currentOrder then
            currentOrder = order
            grouped[#grouped + 1] = {
                type    = "section",
                name    = CategoryLabel(order),
                align   = "leftFlush",
                options = {},
            }
        end

        local section = grouped[#grouped].options
        section[#section + 1] = {
            type    = "button",
            name    = function() return label end,
            tooltip = function() return BuildItemTooltip(item, contextName) end,
            func    = function() end,
        }
    end

    local compiled = LCM():ConvertOptions(grouped)

    local ok = pcall(function()
        menu:AddControls(compiled, submenuIndex + 2)
    end)

    if ok then
        state.rowCount = #compiled
    end
end

local function DepopulatePage(submenu, pageId)
    local state = pageState[pageId]
    if not state or state.rowCount == 0 then return end

    local count = state.rowCount
    state.rowCount = 0

    zo_callLater(function()
        local submenuIndex = FindControlIndex(submenu)
        if not submenuIndex then return end
        pcall(function()
            menu:RemoveControls(submenuIndex + 2, count)
        end)
    end, 0)
end

local function ItemPage(pageId, name, icon, getTables, contextName)
    pageState[pageId] = { rowCount = 0, itemCount = 0, entryCount = 0, slotCount = 0 }
    local state = pageState[pageId]

    return {
        type          = "submenu",
        name          = name,
        icon          = icon,
        childrenAlign = "leftFlush",
        header        = { title = name },
        onEnter       = function(submenu) PopulatePage(submenu, pageId, getTables, contextName) end,
        onExit        = function(submenu) DepopulatePage(submenu, pageId) end,
        options = {
            {
                type     = "button",
                name     = function()
                    if state.rowCount > 0 then
                        return string.format("|c888888%s slots  -  %s items|r",
                            FormatCount(state.slotCount), FormatCount(state.itemCount))
                    end
                    return "|c888888Loading...|r"
                end,
                disabled = true,
                func     = function() end,
            },
        },
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

local function BuildCurrencySection()
    local sv = SV()
    if not sv or not sv.characters then return nil end

    local currencySubmenus = {}

    for c = 1, #CURRENCIES do
        local currency = CURRENCIES[c]
        local rows = {}

        rows[#rows + 1] = {
            type     = "button",
            disabled = true,
            name     = function()
                local total = BankCurrencyAmount(currency)
                for _, data in pairs(sv.characters) do
                    total = total + ((data.currencies and data.currencies[currency.key]) or 0)
                end
                return string.format("|c888888Total|r  |c%s%s|r", currency.hex, FormatCount(total))
            end,
            func     = function() end,
        }

        local bankAmount = BankCurrencyAmount(currency)
        if bankAmount > 0 then
            rows[#rows + 1] = {
                type    = "button",
                name    = function()
                    return string.format("Bank  |c%s%s|r", currency.hex, FormatCount(BankCurrencyAmount(currency)))
                end,
                tooltip = function()
                    return BuildCurrencyTooltip(currency, "Bank", BankCurrencyAmount(currency))
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
                        return string.format("%s  |c%s%s|r", charName, currency.hex, FormatCount(current))
                    end,
                    tooltip = function()
                        local current = (sv.characters[charId] and sv.characters[charId].currencies
                                         and sv.characters[charId].currencies[currency.key]) or 0
                        return BuildCurrencyTooltip(currency, charName, current)
                    end,
                    func    = function() end,
                }
            end
        end

        if #rows > 1 then
            currencySubmenus[#currencySubmenus + 1] = {
                type          = "submenu",
                name          = string.format("|c%s%s|r", currency.hex, currency.label),
                icon          = currency.icon,
                childrenAlign = "leftFlush",
                header        = { title = currency.label },
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
    local sv = SV()
    if not sv or not sv.characters then return nil end

    local options = {}
    local ids = SortedCharacterIds()

    for i = 1, #ids do
        local charId   = ids[i]
        local data     = sv.characters[charId]
        local charName = data.name or ("Char " .. charId)

        if HasEntries(data.items) or HasEntries(data.companion) then
            options[#options + 1] = ItemPage(
                "char:" .. charId,
                charName,
                ICON_INVENTORY,
                function()
                    local current = SV() and SV().characters and SV().characters[charId]
                    if not current then return {} end
                    return { current.items, current.companion }
                end,
                charName)
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
            nil)
    end

    return {
        type    = "submenu",
        name    = "Guild Banks",
        icon    = ICON_GUILD,
        options = options,
    }
end

local function BuildStorageSection()
    local sv = SV()
    local account = sv and sv.account
    if not account then return nil end

    local options = {}

    if HasEntries(account.house) then
        options[#options + 1] = ItemPage(
            "house",
            "House Chests",
            ICON_HOUSE,
            function() return { SV().account.house } end,
            nil)
    end

    if HasEntries(account.furnitureVault) then
        options[#options + 1] = ItemPage(
            "furnitureVault",
            "Furniture Vault",
            ICON_HOUSE,
            function() return { SV().account.furnitureVault } end,
            nil)
    end

    if #options == 0 then return nil end

    return {
        type    = "submenu",
        name    = "Storage",
        icon    = ICON_HOUSE,
        options = options,
    }
end

--------------------------------------------------
-- Menu Construction
--------------------------------------------------
local RebuildContents

local function BuildOptions()
    local sv = SV()
    local account = sv and sv.account
    local options = {}

    local function Append(section)
        if section then options[#options + 1] = section end
    end

    Append(BuildCurrencySection())
    Append(BuildCharacterSection())

    if account and HasEntries(account.bank) then
        Append(ItemPage("bank", "Bank", ICON_BANK,
            function() return { SV().account.bank } end, nil))
    end

    if account and HasEntries(account.craftBag) then
        Append(ItemPage("craftBag", "Craft Bag", ICON_CRAFTBAG,
            function() return { SV().account.craftBag } end, nil))
    end

    Append(BuildGuildSection())
    Append(BuildStorageSection())

    options[#options + 1] = {
        type    = "button",
        name    = "Refresh",
        tooltip = "Rebuilds the list of pages shown here.\n\n"
               .. "This does NOT rescan anything. Your items are always saved automatically "
               .. "when you log in a character, open your bank, enter a guild bank, or visit your house.\n\n"
               .. "Use this only if a page is missing - for example you opened a guild bank or "
               .. "logged in a new character while this menu was already built, and it has not "
               .. "appeared in the list yet.\n\n"
               .. "The menu also rebuilds itself every time you open the main menu.",
        func    = function() RebuildContents() end,
    }

    return options
end

RebuildContents = function()
    if not menu then return end

    pageState = {}

    pcall(function() menu:RemoveAllControls() end)
    menu:AddOptions(BuildOptions())
end

local function BuildMenu()
    if built then return end
    local lcm = LCM()
    if not lcm or type(lcm.CreateAddonMenu) ~= "function" then return end
    if not SV() then return end

    menu = lcm:CreateAddonMenu(MENU_ID, {
        title         = "Where Is It?",
        author        = "user562",
        version       = "1.3",
        childrenAlign = "center",
    })
    if not menu then return end

    built = true
    HookCenteredTooltip()

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
        SelectMenu()
    end)
end

local function AddToMainMenu()
    if addedToMainMenu or not ZO_MENU_ENTRIES then return end

    for i = 1, #ZO_MENU_ENTRIES do
        if ZO_MENU_ENTRIES[i].id == ENTRY_ID then
            addedToMainMenu = true
            return
        end
    end

    local title = "|cFFCC00Where Is It? (Menu)|r"

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
    for i = 1, #ZO_MENU_ENTRIES do
        if ZO_MENU_ENTRIES[i].id == 997 then
            insertIndex = i + 1
            break
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

        local lcm = LCM()
        if built and menu and not (lcm and lcm.currentMenu == menu) then
            RebuildContents()
        end
    end)
end
