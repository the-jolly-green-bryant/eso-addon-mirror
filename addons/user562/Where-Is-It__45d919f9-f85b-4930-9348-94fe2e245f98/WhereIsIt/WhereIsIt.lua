
WhereIsIt = {}
WhereIsIt.name = "WhereIsIt"

--------------------------------------------------
-- Utility Functions
--------------------------------------------------
local function IsHouseBankUnavailable(bagId)
    return bagId >= BAG_HOUSE_BANK_ONE and bagId <= BAG_HOUSE_BANK_TEN
        and (GetCollectibleForBag(bagId) <= 0 or not IsOwnerOfCurrentHouse())
end

local function IsBankUnavailable(bagId)
    return (bagId == BAG_BANK or bagId == BAG_SUBSCRIBER_BANK) and not IsBankOpen()
end

local function IsVirtualBagUnavailable()
    return not IsBankOpen()
end

local function FormatNumber(n)
    if not n then return "0" end
    local s = tostring(math.floor(n))
    local result, len = "", #s
    for i = 1, len do
        if i > 1 and (len - i + 1) % 3 == 0 then result = result .. "," end
        result = result .. s:sub(i, i)
    end
    return result
end

local function Trim(s)
    return (s or ""):match("^%s*(.-)%s*$")
end

--------------------------------------------------
-- Currency Data
--------------------------------------------------
local CURRENCY_KEYS = {
    { key = "gold",           label = "Gold",            color = "FFCC00", icon = "/esoui/art/currency/gold_mipmap.dds"          },
    { key = "alliancePoints", label = "Alliance Points", color = "39FF14", icon = "/esoui/art/currency/alliancepoints.dds"        },
    { key = "telVar",         label = "Tel Var Stones",  color = "4499FF", icon = "/esoui/art/currency/telvar_mipmap.dds"         },
    { key = "writVouchers",   label = "Writ Vouchers",   color = "FFFFFF", icon = "/esoui/art/icons/icon_writvoucher.dds"         },
}

local CURRENCY_COLOR = {}
local CURRENCY_ICON  = {}
for _, c in ipairs(CURRENCY_KEYS) do
    CURRENCY_COLOR[c.label] = c.color
    CURRENCY_ICON[c.label]  = c.icon
end

--------------------------------------------------
-- Item Constants
--------------------------------------------------
local ARMOR_TYPE_LABEL = {
    [ARMORTYPE_NONE]   = "",
    [ARMORTYPE_LIGHT]  = "Light Armor",
    [ARMORTYPE_MEDIUM] = "Medium Armor",
    [ARMORTYPE_HEAVY]  = "Heavy Armor",
}

local EQUIP_TYPE_LABEL = {}
local QUALITY_COLOR    = {}
local QUALITY_LABEL    = {}

local function InitDetailConstants()
    local function SafeSet(tbl, key, val)
        if key ~= nil then tbl[key] = val end
    end
    SafeSet(EQUIP_TYPE_LABEL, EQUIP_TYPE_HEAD,      "Head")
    SafeSet(EQUIP_TYPE_LABEL, EQUIP_TYPE_CHEST,     "Chest")
    SafeSet(EQUIP_TYPE_LABEL, EQUIP_TYPE_SHOULDERS, "Shoulders")
    SafeSet(EQUIP_TYPE_LABEL, EQUIP_TYPE_HAND,      "Hands")
    SafeSet(EQUIP_TYPE_LABEL, EQUIP_TYPE_WAIST,     "Waist")
    SafeSet(EQUIP_TYPE_LABEL, EQUIP_TYPE_LEGS,      "Legs")
    SafeSet(EQUIP_TYPE_LABEL, EQUIP_TYPE_FEET,      "Feet")
    SafeSet(EQUIP_TYPE_LABEL, EQUIP_TYPE_NECK,      "Necklace")
    SafeSet(EQUIP_TYPE_LABEL, EQUIP_TYPE_RING,      "Ring")
    SafeSet(EQUIP_TYPE_LABEL, EQUIP_TYPE_MAIN_HAND, "Main Hand")
    SafeSet(EQUIP_TYPE_LABEL, EQUIP_TYPE_OFF_HAND,  "Off Hand")
    SafeSet(EQUIP_TYPE_LABEL, EQUIP_TYPE_TWO_HAND,  "Two Handed")
    SafeSet(EQUIP_TYPE_LABEL, EQUIP_TYPE_COSTUME,   "Costume")

    SafeSet(QUALITY_COLOR, ITEM_DISPLAY_QUALITY_TRASH,     "aaaaaa")
    SafeSet(QUALITY_COLOR, ITEM_DISPLAY_QUALITY_NORMAL,    "ffffff")
    SafeSet(QUALITY_COLOR, ITEM_DISPLAY_QUALITY_MAGIC,     "2dc50e")
    SafeSet(QUALITY_COLOR, ITEM_DISPLAY_QUALITY_ARCANE,    "3a92ff")
    SafeSet(QUALITY_COLOR, ITEM_DISPLAY_QUALITY_ARTIFACT,  "a02ee4")
    SafeSet(QUALITY_COLOR, ITEM_DISPLAY_QUALITY_LEGENDARY, "e4c027")

    SafeSet(QUALITY_LABEL, ITEM_DISPLAY_QUALITY_TRASH,     "Trash")
    SafeSet(QUALITY_LABEL, ITEM_DISPLAY_QUALITY_NORMAL,    "Normal")
    SafeSet(QUALITY_LABEL, ITEM_DISPLAY_QUALITY_MAGIC,     "Fine")
    SafeSet(QUALITY_LABEL, ITEM_DISPLAY_QUALITY_ARCANE,    "Superior")
    SafeSet(QUALITY_LABEL, ITEM_DISPLAY_QUALITY_ARTIFACT,  "Epic")
    SafeSet(QUALITY_LABEL, ITEM_DISPLAY_QUALITY_LEGENDARY, "Legendary")
end

--------------------------------------------------
-- Bag Scanner
--------------------------------------------------
local QUALITY_HEX = {
    [0] = "aaaaaa",  -- Trash
    [1] = "ffffff",  -- Normal
    [2] = "2dc50e",  -- Fine/Magic
    [3] = "3a92ff",  -- Superior/Arcane
    [4] = "a02ee4",  -- Epic/Artifact
    [5] = "e4c027",  -- Legendary
}

local function ScanBagIntoTable(bagId, tbl, location)
    local ok, size = pcall(GetBagSize, bagId)
    if not ok or not size or size == 0 then return end
    local startIndex = (bagId == BAG_FURNITURE_VAULT) and 1 or 0
    for slotIndex = startIndex, size - 1 + startIndex do
        local rawName = GetItemName(bagId, slotIndex)
        if rawName and rawName ~= "" then
            local itemName = ZO_CachedStrFormat(SI_TOOLTIP_ITEM_NAME, rawName)
            local count = select(2, GetItemInfo(bagId, slotIndex)) or 0
            if count > 0 then
                local itemLink = GetItemLink(bagId, slotIndex)
                local trait    = (itemLink and itemLink ~= "") and GetItemLinkTraitInfo(itemLink) or 0
                local icon     = (itemLink and itemLink ~= "") and GetItemLinkIcon(itemLink) or nil
                local quality  = (itemLink and itemLink ~= "") and GetItemLinkDisplayQuality(itemLink) or nil
                local qColor      = (quality ~= nil and QUALITY_HEX[quality]) or nil
                local rawSearchName = (itemLink and itemLink ~= "") and GetItemLinkName(itemLink) or rawName
                local key = zo_strlower(rawSearchName) .. "|" .. location .. "|" .. tostring(trait)
                if tbl[key] then
                    tbl[key].count = tbl[key].count + count
                else
                    tbl[key] = {
                        displayName = itemName,
                        searchName  = rawSearchName,
                        count       = count,
                        location    = location,
                        bagId       = bagId,
                        slotIndex   = slotIndex,
                        trait       = trait,
                        itemLink    = itemLink,
                        icon        = icon,
                        quality     = quality,
                        qColor      = qColor,
                    }
                end
            end
        end
    end
end

local function ScanVirtualBagIntoTable(tbl)
    local slotId = GetNextVirtualBagSlotId(nil)
    while slotId ~= nil do
        local rawName = GetItemName(BAG_VIRTUAL, slotId)
        if rawName and rawName ~= "" then
            local itemName = ZO_CachedStrFormat(SI_TOOLTIP_ITEM_NAME, rawName)
            local count = select(2, GetItemInfo(BAG_VIRTUAL, slotId)) or 0
            if count > 0 then
                local itemLink = GetItemLink(BAG_VIRTUAL, slotId)
                local trait    = (itemLink and itemLink ~= "") and GetItemLinkTraitInfo(itemLink) or 0
                local icon     = (itemLink and itemLink ~= "") and GetItemLinkIcon(itemLink) or nil
                local quality  = (itemLink and itemLink ~= "") and GetItemLinkDisplayQuality(itemLink) or nil
                local qColor      = (quality ~= nil and QUALITY_HEX[quality]) or nil
                local rawSearchName = (itemLink and itemLink ~= "") and GetItemLinkName(itemLink) or rawName
                local key = zo_strlower(rawSearchName) .. "|Craft Bag|" .. tostring(trait)
                if tbl[key] then
                    tbl[key].count = tbl[key].count + count
                else
                    tbl[key] = {
                        displayName = itemName,
                        searchName  = rawSearchName,
                        count       = count,
                        location    = "Craft Bag",
                        bagId       = BAG_VIRTUAL,
                        slotIndex   = slotId,
                        trait       = trait,
                        itemLink    = itemLink,
                        icon        = icon,
                        quality     = quality,
                        qColor      = qColor,
                    }
                end
            end
        end
        slotId = GetNextVirtualBagSlotId(slotId)
    end
end

function WhereIsIt:ScanCharacter()
    local charId   = tostring(GetCurrentCharacterId())
    local charName = GetUnitName("player")
    local sv       = self.savedVariables

    sv.characters[charId] = sv.characters[charId] or {}
    local slot = sv.characters[charId]
    slot.name  = charName
    slot.items = {}

    ScanBagIntoTable(BAG_BACKPACK, slot.items, "Inventory")
    ScanBagIntoTable(BAG_WORN,     slot.items, "Worn")

    slot.companion = {}
    if HasActiveCompanion and HasActiveCompanion() then
        ScanBagIntoTable(BAG_COMPANION_WORN, slot.companion, "Companion Worn")
    end

    slot.currencies = {
        gold           = GetCurrencyAmount(CURT_MONEY,           CURRENCY_LOCATION_CHARACTER),
        alliancePoints = GetCurrencyAmount(CURT_ALLIANCE_POINTS, CURRENCY_LOCATION_CHARACTER),
        telVar         = GetCurrencyAmount(CURT_TELVAR_STONES,   CURRENCY_LOCATION_CHARACTER),
        writVouchers   = GetCurrencyAmount(CURT_WRIT_VOUCHERS,   CURRENCY_LOCATION_CHARACTER),
    }
end

function WhereIsIt:ScanBank()
    local sv   = self.savedVariables
    sv.account = sv.account or {}
    local acct = sv.account
    acct.bank     = {}
    acct.craftBag = {}

    if not IsBankUnavailable(BAG_BANK) then
        ScanBagIntoTable(BAG_BANK,            acct.bank, "Bank")
        ScanBagIntoTable(BAG_SUBSCRIBER_BANK, acct.bank, "Bank")
        if not IsVirtualBagUnavailable() then
            ScanVirtualBagIntoTable(acct.craftBag)
        end
    end
end

function WhereIsIt:ScanHouseChests()
    if not (IsOwnerOfCurrentHouse and IsOwnerOfCurrentHouse()) then return end
    local sv   = self.savedVariables
    sv.account = sv.account or {}
    sv.account.house = {}

    for bagId = BAG_HOUSE_BANK_ONE, BAG_HOUSE_BANK_TEN do
        local collectibleId = GetCollectibleForBag(bagId)
        if collectibleId and collectibleId > 0 and IsCollectibleUnlocked(collectibleId) then
            local chestName = GetCollectibleNickname(collectibleId)
            if not chestName or chestName == "" then chestName = GetCollectibleName(collectibleId) end
            if not chestName or chestName == "" then chestName = "House Chest" end
            ScanBagIntoTable(bagId, sv.account.house, chestName)
        end
    end
end

function WhereIsIt:ScanFurnitureVault()
    if not (IsOwnerOfCurrentHouse and IsOwnerOfCurrentHouse()) then return end
    local sv   = self.savedVariables
    sv.account = sv.account or {}
    sv.account.furnitureVault = {}
    ScanBagIntoTable(BAG_FURNITURE_VAULT, sv.account.furnitureVault, "Furniture Vault")
end

function WhereIsIt:ScanGuildBank()
    local sv   = self.savedVariables
    sv.account = sv.account or {}
    sv.account.guildBank = {}

    local guildName = GetGuildName(GetSelectedGuildBankId and GetSelectedGuildBankId() or 0)
    local location  = (guildName and guildName ~= "") and ("Guild Bank: " .. guildName) or "Guild Bank"
    ScanBagIntoTable(BAG_GUILDBANK, sv.account.guildBank, location)
end

function WhereIsIt:ScanCompanion()
    local charId = tostring(GetCurrentCharacterId())
    local sv     = self.savedVariables
    sv.characters[charId] = sv.characters[charId] or {}
    local slot = sv.characters[charId]
    slot.companion = {}

    if HasActiveCompanion and HasActiveCompanion() then
        ScanBagIntoTable(BAG_COMPANION_WORN, slot.companion, "Companion Worn")
    end
end

--------------------------------------------------
-- Search
--------------------------------------------------
function WhereIsIt:Search(query)
    local results = {}
    local q = zo_strlower(Trim(query))
    if q == "" then return results end

    local sv = self.savedVariables

    local function searchTable(tbl, label)
        if not tbl then return end
        for _, item in pairs(tbl) do
            local searchKey = zo_strlower(item.searchName or item.displayName or "")
            if zo_strfind(searchKey, q, 1, true) then
                local r = {}
                for k, v in pairs(item) do r[k] = v end
                r.charName = label or ""
                table.insert(results, r)
            end
        end
    end

    local acct = sv.account or {}
    searchTable(acct.bank,           "Bank")
    searchTable(acct.craftBag,       "Craft Bag")
    searchTable(acct.house,          "House")
    searchTable(acct.guildBank,      "Guild Bank")
    searchTable(acct.furnitureVault, "Furniture Vault")

    for charId, data in pairs(sv.characters) do
        local charName = data.name or ("Char " .. charId)
        searchTable(data.items,     charName)
        searchTable(data.companion, charName)
    end

    table.sort(results, function(a, b)
        if a.displayName ~= b.displayName then return a.displayName < b.displayName end
        return a.charName < b.charName
    end)

    return results
end

--------------------------------------------------
-- Browse helpers  (no search query needed)
--------------------------------------------------

-- Returns all currency rows (same format as Search("currency"))
function WhereIsIt:BrowseCurrency()
    local results = {}
    local sv = self.savedVariables

    local liveBankAmounts = {
        gold           = GetCurrencyAmount(CURT_MONEY,           CURRENCY_LOCATION_BANK),
        alliancePoints = GetCurrencyAmount(CURT_ALLIANCE_POINTS, CURRENCY_LOCATION_BANK),
        telVar         = GetCurrencyAmount(CURT_TELVAR_STONES,   CURRENCY_LOCATION_BANK),
        writVouchers   = GetCurrencyAmount(CURT_WRIT_VOUCHERS,   CURRENCY_LOCATION_BANK),
    }
    for _, curr in ipairs(CURRENCY_KEYS) do
        local bankAmount = liveBankAmounts[curr.key] or 0
        if bankAmount > 0 then
            table.insert(results, {
                isCurrency  = true,
                charName    = "Bank",
                displayName = curr.label,
                count       = bankAmount,
                location    = "Bank",
            })
        end
    end

    for charId, data in pairs(sv.characters) do
        local charName = data.name or ("Char " .. charId)
        for _, curr in ipairs(CURRENCY_KEYS) do
            local amount = (data.currencies and data.currencies[curr.key]) or 0
            if amount > 0 then
                table.insert(results, {
                    isCurrency  = true,
                    charName    = charName,
                    displayName = curr.label,
                    count       = amount,
                    location    = charName,
                })
            end
        end
    end

    table.sort(results, function(a, b)
        if a.displayName ~= b.displayName then return a.displayName < b.displayName end
        return (a.charName or "") < (b.charName or "")
    end)
    return results
end

-- Returns a sorted list of { currencyLabel, rows[] } — one entry per currency type
function WhereIsIt:GetCurrencyPages()
    local sv = self.savedVariables
    local pages = {}

    -- Build a page per currency key
    for _, curr in ipairs(CURRENCY_KEYS) do
        local rows = {}

        -- Bank amount (live)
        local bankAmount = GetCurrencyAmount(
            curr.key == "gold"           and CURT_MONEY           or
            curr.key == "alliancePoints" and CURT_ALLIANCE_POINTS or
            curr.key == "telVar"         and CURT_TELVAR_STONES   or
            CURT_WRIT_VOUCHERS,
            CURRENCY_LOCATION_BANK
        )
        if bankAmount and bankAmount > 0 then
            table.insert(rows, {
                isCurrency  = true,
                charName    = "Bank",
                displayName = curr.label,
                count       = bankAmount,
                location    = "Bank",
            })
        end

        -- Per-character amounts
        for charId, data in pairs(sv.characters) do
            local charName = data.name or ("Char " .. charId)
            local amount = (data.currencies and data.currencies[curr.key]) or 0
            if amount > 0 then
                table.insert(rows, {
                    isCurrency  = true,
                    charName    = charName,
                    displayName = curr.label,
                    count       = amount,
                    location    = charName,
                })
            end
        end

        -- Sort rows by amount descending
        table.sort(rows, function(a, b) return a.count > b.count end)

        if #rows > 0 then
            table.insert(pages, { currencyLabel = curr.label, color = curr.color, rows = rows })
        end
    end

    return pages
end
function WhereIsIt:BrowseBank()
    local results = {}
    local acct = (self.savedVariables and self.savedVariables.account) or {}
    local function addTable(tbl, label)
        if not tbl then return end
        for _, item in pairs(tbl) do
            local r = {}
            for k, v in pairs(item) do r[k] = v end
            r.charName = label or ""
            table.insert(results, r)
        end
    end
    addTable(acct.bank, "Bank")
    table.sort(results, function(a, b) return (a.displayName or "") < (b.displayName or "") end)
    return results
end

-- Returns all items in the furniture vault
function WhereIsIt:BrowseFurnitureVault()
    local results = {}
    local acct = (self.savedVariables and self.savedVariables.account) or {}
    if acct.furnitureVault then
        for _, item in pairs(acct.furnitureVault) do
            local r = {}
            for k, v in pairs(item) do r[k] = v end
            r.charName = "Furniture Vault"
            table.insert(results, r)
        end
    end
    table.sort(results, function(a, b) return (a.displayName or "") < (b.displayName or "") end)
    return results
end

-- Returns a sorted list of { charId, charName, items[] } — one entry per character
function WhereIsIt:GetCharacterPages()
    local sv = self.savedVariables
    local pages = {}
    for charId, data in pairs(sv.characters) do
        local charName = data.name or ("Char " .. charId)
        local items = {}
        local function addTable(tbl)
            if not tbl then return end
            for _, item in pairs(tbl) do
                local r = {}
                for k, v in pairs(item) do r[k] = v end
                r.charName = charName
                table.insert(items, r)
            end
        end
        addTable(data.items)
        addTable(data.companion)
        table.sort(items, function(a, b) return (a.displayName or "") < (b.displayName or "") end)
        table.insert(pages, { charId = charId, charName = charName, items = items })
    end
    table.sort(pages, function(a, b) return a.charName < b.charName end)
    return pages
end

--------------------------------------------------
-- Gamepad Screen
--------------------------------------------------
local WhereIsIt_Screen = ZO_Gamepad_ParametricList_Screen:Subclass()

function WhereIsIt_Screen:New(control)
    local obj = ZO_Object.New(self)
    obj:Initialize(control)
    return obj
end

local MODE_HOME         = "home"
local MODE_SEARCH       = "search"
local MODE_BROWSE       = "browse"
local MODE_BROWSE_PAGED = "browse_paged"
local MODE_CHARACTERS   = "characters"
local MODE_CURRENCY     = "currency"  -- one currency per page

function WhereIsIt_Screen:Initialize(control)
    self.control        = control
    self.currentQuery   = ""
    self.currentResults = {}
    self.page           = 1
    self.totalPages     = 1
    self.mode           = MODE_HOME

    -- character-browse state
    self.charPages      = {}
    self.charPageIndex  = 1

    -- currency-browse state
    self.currencyPages     = {}
    self.currencyPageIndex = 1

    local fragment = ZO_FadeSceneFragment:New(control)
    local scene    = ZO_Scene:New("whereIsItGamepad", SCENE_MANAGER)
    scene:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
    scene:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_GAMEPAD_OPTIONS)
    scene:AddFragment(GAMEPAD_NAV_QUADRANT_1_BACKGROUND_FRAGMENT)
    scene:AddFragment(MINIMIZE_CHAT_FRAGMENT)
    scene:AddFragment(GAMEPAD_MENU_SOUND_FRAGMENT)
    scene:AddFragment(fragment)
    self.detailPanelFragment = ZO_FadeSceneFragment:New(WINDOW_MANAGER:GetControlByName("WhereIsIt_ScreenDetailPanel"))
    self.scene = scene

    ZO_Gamepad_ParametricList_Screen.Initialize(self, control, false, true, scene)
    self:InitializeKeybindStripDescriptors()
    self:InitializeHeader()
    self:InitializeDetailPanel()

    fragment:RegisterCallback("StateChange", function(oldState, newState)
        if newState == SCENE_FRAGMENT_SHOWING then
            self:ResetToHome()
            KEYBIND_STRIP:AddKeybindButtonGroup(self.keybindStripDescriptor)
            if self.header then
                ZO_GamepadGenericHeader_Refresh(self.header, { titleText = "|cFFCC00Where Is It?|r" })
            end
            self:HideDetailPanel()
        elseif newState == SCENE_FRAGMENT_HIDDEN then
            KEYBIND_STRIP:RemoveKeybindButtonGroup(self.keybindStripDescriptor)
            self:HideDetailPanel()
            if self.detailPanelFragment then
                SCENE_MANAGER:RemoveFragment(self.detailPanelFragment)
            end
        end
    end)
end

-- Reset back to the home browse menu
function WhereIsIt_Screen:ResetToHome()
    self.mode           = MODE_HOME
    self.currentQuery   = ""
    self.currentResults = {}
    self.page           = 1
    self.totalPages     = 1
    self.charPages         = {}
    self.charPageIndex     = 1
    self.currencyPages     = {}
    self.currencyPageIndex = 1
    if self.searchBoxText then
        self.searchBoxText:SetText("")
    end
    self:RefreshList()
    self:SetCurrentList(self.mainList)
    self:ActivateCurrentList()
end

local function LeftAlignEntrySetup(control, data, selected, selectedDuringRebuild, enabled, activated)
    ZO_SharedGamepadEntry_OnSetup(control, data, selected, selectedDuringRebuild, enabled, activated)
    if data and data.isSearchField then
        control:SetAlpha(0)
        return
    end
    control:SetAlpha(1)
    local label = control:GetNamedChild("Label")
    if label then
        label:ClearAnchors()
        label:SetAnchor(TOPLEFT,  control, TOPLEFT,  8, 0)
        label:SetAnchor(TOPRIGHT, control, TOPRIGHT, -8, 0)
        label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        label:SetWrapMode(TEXT_WRAP_MODE_WRAP)
    end
end

function WhereIsIt_Screen:SetupList(list)
    list:AddDataTemplate(
        "ZO_GamepadSubMenuEntryTemplate",
        LeftAlignEntrySetup,
        ZO_GamepadSubMenuEntryTemplateParametricListFunction
    )

    list:SetOnSelectedDataChangedCallback(function(list, selectedData)
        if selectedData and selectedData.resultData then
            self:ShowDetailPanel(selectedData.resultData)
        else
            self:HideDetailPanel()
        end
        if self.keybindStripDescriptor then
            KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybindStripDescriptor)
        end
    end)

    self.mainList = list
end

function WhereIsIt_Screen:InitializeHeader()
    local headerControl = self.control:GetNamedChild("HeaderContainer")
    if headerControl and headerControl.header then
        self.header = headerControl.header
        ZO_GamepadGenericHeader_Initialize(self.header)
    end
    self.pageLabel = self.control:GetNamedChild("PageLabel")

    self.searchLabel   = self.control:GetNamedChild("SearchLabel")
    self.searchBoxText = self.control:GetNamedChild("SearchBoxText")

    if self.searchLabel then
        self.searchLabel:SetText("Search Everywhere")
    end

    if self.searchBoxText then
        self.searchBoxText:SetHandler("OnTextChanged", function()
            local query = self.searchBoxText:GetText()
            self.currentQuery = query
            if Trim(query) == "" then
                -- Cleared search — go back to home menu
                self:ResetToHome()
            else
                self.mode           = MODE_SEARCH
                self.currentResults = WhereIsIt:Search(query)
                self.page           = 1
                self.totalPages     = 1  -- search uses simple paging
                self:RefreshList()
            end
        end)
    end
end

--------------------------------------------------
-- Detail Panel
--------------------------------------------------
function WhereIsIt_Screen:InitializeDetailPanel()
    InitDetailConstants()
    self.detailPanel = self.control:GetNamedChild("DetailPanel")
    if not self.detailPanel then return end

    self.detailIcon      = self.detailPanel:GetNamedChild("Icon")
    self.detailName      = self.detailPanel:GetNamedChild("Name")
    self.detailQuality   = self.detailPanel:GetNamedChild("Quality")
    self.detailType      = self.detailPanel:GetNamedChild("Type")
    self.detailArmorType = self.detailPanel:GetNamedChild("ArmorType")
    self.detailTrait     = self.detailPanel:GetNamedChild("Trait")
    self.detailSet       = self.detailPanel:GetNamedChild("Set")
    self.detailChar      = self.detailPanel:GetNamedChild("Char")
    self.detailLocation  = self.detailPanel:GetNamedChild("Location")
    self.detailCount     = self.detailPanel:GetNamedChild("Count")
end

function WhereIsIt_Screen:HideDetailPanel()
    if self.detailPanel then
        self.detailPanel:SetHidden(true)
    end
    if self.detailPanelFragment then
        SCENE_MANAGER:RemoveFragment(self.detailPanelFragment)
    end
end

local function SetLabelText(label, text)
    if label then
        label:SetText(text or "")
        label:SetHidden(not text or text == "")
    end
end

function WhereIsIt_Screen:ShowDetailPanel(r)
    if not self.detailPanel then return end
    self.detailPanel:SetHidden(false)
    if self.detailPanelFragment then
        SCENE_MANAGER:AddFragment(self.detailPanelFragment)
    end

    if r.isCurrency then
        local cc   = CURRENCY_COLOR[r.displayName] or "FFFFFF"
        local icon = CURRENCY_ICON[r.displayName]
        if self.detailIcon then
            if icon and icon ~= "" then
                self.detailIcon:SetTexture(icon)
                self.detailIcon:SetColor(1, 1, 1, 1)
                self.detailIcon:SetDesaturation(0)
                self.detailIcon:SetHidden(false)
            else
                self.detailIcon:SetHidden(true)
            end
        end
        SetLabelText(self.detailName,      "|c" .. cc .. (r.displayName or "") .. "|r")
        SetLabelText(self.detailQuality,   "")
        SetLabelText(self.detailType,      "Currency")
        SetLabelText(self.detailArmorType, "")
        SetLabelText(self.detailTrait,     "")
        SetLabelText(self.detailSet,       "")
        SetLabelText(self.detailChar,      "")
        SetLabelText(self.detailLocation,  "|c888888Location:|r  |cFF6600" .. (r.location or "") .. "|r")
        SetLabelText(self.detailCount,     "|c888888Amount:|r  |c" .. cc .. FormatNumber(r.count) .. "|r")
        return
    end

    local itemLink = r.itemLink
    if (not itemLink or itemLink == "") and r.bagId and r.slotIndex then
        itemLink = GetItemLink(r.bagId, r.slotIndex)
    end

    local icon = r.icon
    if (not icon or icon == "") and itemLink and itemLink ~= "" then
        icon = GetItemLinkIcon(itemLink)
    end
    if self.detailIcon then
        if icon and icon ~= "" then
            self.detailIcon:SetTexture(icon)
            self.detailIcon:SetColor(1, 1, 1, 1)
            self.detailIcon:SetDesaturation(0)
            self.detailIcon:SetHidden(false)
        else
            self.detailIcon:SetHidden(true)
        end
    end

    local qColor = r.qColor
    if not qColor then
        local quality = r.quality
        if quality == nil and itemLink and itemLink ~= "" then
            quality = GetItemLinkDisplayQuality(itemLink)
        end
        qColor = (quality ~= nil and (QUALITY_COLOR[quality] or QUALITY_HEX[quality])) or "ffffff"
    end
    local quality = r.quality
    SetLabelText(self.detailName, "|c" .. qColor .. (r.displayName or "") .. "|r")

    local qLabel = quality and QUALITY_LABEL[quality] or nil
    SetLabelText(self.detailQuality, qLabel and ("|c" .. qColor .. qLabel .. "|r") or nil)

    local equipType = itemLink and GetItemLinkEquipType(itemLink) or nil
    local equipLabel = equipType and EQUIP_TYPE_LABEL[equipType] or nil
    SetLabelText(self.detailType, equipLabel)

    local armorType = itemLink and GetItemLinkArmorType(itemLink) or nil
    local armorLabel = (armorType and armorType ~= ARMORTYPE_NONE) and ARMOR_TYPE_LABEL[armorType] or nil
    SetLabelText(self.detailArmorType, armorLabel)

    local trait = itemLink and GetItemLinkTraitInfo(itemLink) or nil
    local traitName = (trait and trait ~= ITEM_TRAIT_TYPE_NONE) and GetString("SI_ITEMTRAITTYPE", trait) or nil
    SetLabelText(self.detailTrait, traitName and ("|c888888Trait:|r  " .. traitName) or nil)

    local hasSet, setName = false, nil
    if itemLink then
        hasSet, setName = GetItemLinkSetInfo(itemLink, false)
    end
    SetLabelText(self.detailSet, (hasSet and setName and setName ~= "") and ("|c888888Set:|r  " .. setName) or nil)

    if itemLink then
        local lvl  = GetItemLinkRequiredLevel(itemLink)
        local cp   = GetItemLinkRequiredChampionPoints(itemLink)
        if cp and cp > 0 then
            SetLabelText(self.detailChar, "|c888888Req. CP:|r  " .. tostring(cp))
        elseif lvl and lvl > 0 then
            SetLabelText(self.detailChar, "|c888888Req. Level:|r  " .. tostring(lvl))
        else
            SetLabelText(self.detailChar, nil)
        end
    else
        SetLabelText(self.detailChar, "|c888888Character:|r  " .. (r.charName or ""))
    end

    local locDisplay = r.location
    if r.location == "Inventory" or r.location == "Worn" then
        locDisplay = r.location .. " (" .. (r.charName or "") .. ")"
    end
    SetLabelText(self.detailLocation, "|c888888Location:|r  |cFF6600" .. (locDisplay or "") .. "|r")
    SetLabelText(self.detailCount,    "|c888888Count:|r  |cFFCC00" .. FormatNumber(r.count) .. "|r")
end

--------------------------------------------------
-- Keybinds
--------------------------------------------------
function WhereIsIt_Screen:InitializeKeybindStripDescriptors()
    self.keybindStripDescriptor = {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,

        -- A button: activate search box OR select browse menu item
        {
            keybind  = "UI_SHORTCUT_PRIMARY",
            name     = "Select",
            visible  = function()
                if not self.mainList then return false end
                local selected = self.mainList:GetTargetData()
                if not selected then return false end
                return selected.isSearchField == true or selected.isBrowseMenu == true
            end,
            callback = function()
                if not self.mainList then return end
                local selected = self.mainList:GetTargetData()
                if not selected then return end
                if selected.isSearchField then
                    if self.searchBoxText then
                        self.searchBoxText:TakeFocus()
                    end
                elseif selected.isBrowseMenu then
                    self:ActivateBrowseOption(selected.browseKey)
                end
            end,
            sound = SOUNDS.GAMEPAD_MENU_FORWARD,
        },

        -- B button: back (go home if browsing, else exit)
        {
            keybind  = "UI_SHORTCUT_NEGATIVE",
            name     = GetString(SI_GAMEPAD_BACK_OPTION),
            callback = function()
                if self.mode ~= MODE_HOME then
                    self:ResetToHome()
                else
                    SCENE_MANAGER:HideCurrentScene()
                end
            end,
            sound = SOUNDS.GAMEPAD_MENU_BACK,
        },

        -- LB: prev page (search/browse paging) OR prev character OR prev currency
        {
            keybind  = "UI_SHORTCUT_LEFT_SHOULDER",
            name     = function()
                if self.mode == MODE_CHARACTERS then return "Prev Character"
                elseif self.mode == MODE_CURRENCY then return "Prev Currency"
                else return "Prev Page" end
            end,
            visible  = function()
                if self.mode == MODE_SEARCH or self.mode == MODE_BROWSE_PAGED then
                    return self.page > 1
                elseif self.mode == MODE_CHARACTERS then
                    return self.charPageIndex > 1
                elseif self.mode == MODE_CURRENCY then
                    return self.currencyPageIndex > 1
                end
                return false
            end,
            callback = function()
                if self.mode == MODE_SEARCH or self.mode == MODE_BROWSE_PAGED then
                    self.page = self.page - 1
                    self:RefreshList()
                elseif self.mode == MODE_CHARACTERS then
                    self.charPageIndex = self.charPageIndex - 1
                    self:RefreshList()
                elseif self.mode == MODE_CURRENCY then
                    self.currencyPageIndex = self.currencyPageIndex - 1
                    self:RefreshList()
                end
            end,
        },

        -- RB: next page OR next character OR next currency
        {
            keybind  = "UI_SHORTCUT_RIGHT_SHOULDER",
            name     = function()
                if self.mode == MODE_CHARACTERS then return "Next Character"
                elseif self.mode == MODE_CURRENCY then return "Next Currency"
                else return "Next Page" end
            end,
            visible  = function()
                if self.mode == MODE_SEARCH or self.mode == MODE_BROWSE_PAGED then
                    return self.page < self.totalPages
                elseif self.mode == MODE_CHARACTERS then
                    return self.charPageIndex < #self.charPages
                elseif self.mode == MODE_CURRENCY then
                    return self.currencyPageIndex < #self.currencyPages
                end
                return false
            end,
            callback = function()
                if self.mode == MODE_SEARCH or self.mode == MODE_BROWSE_PAGED then
                    self.page = self.page + 1
                    self:RefreshList()
                elseif self.mode == MODE_CHARACTERS then
                    self.charPageIndex = self.charPageIndex + 1
                    self:RefreshList()
                elseif self.mode == MODE_CURRENCY then
                    self.currencyPageIndex = self.currencyPageIndex + 1
                    self:RefreshList()
                end
            end,
        },
    }
end

--------------------------------------------------
-- Browse option activation
--------------------------------------------------
local RESULTS_PER_PAGE = 8

local BROWSE_MENU_ITEMS = {
    { key = "currency",       label = "|cFFCC00Currency|r"       },
    { key = "bank",           label = "|c88CCFFBank|r"           },
    { key = "furnitureVault", label = "|cFF4444Furniture Vault|r" },
    { key = "characters",     label = "|cFF66BBCharacters|r"     },
}

function WhereIsIt_Screen:ActivateBrowseOption(key)
    if key == "currency" then
        self.mode              = MODE_CURRENCY
        self.currencyPages     = WhereIsIt:GetCurrencyPages()
        self.currencyPageIndex = 1
        self:RefreshList()

    elseif key == "bank" then
        self.mode           = MODE_BROWSE_PAGED
        self.currentResults = WhereIsIt:BrowseBank()
        self.page           = 1
        self.totalPages     = math.max(1, math.ceil(#self.currentResults / RESULTS_PER_PAGE))
        self:RefreshList()

    elseif key == "furnitureVault" then
        self.mode           = MODE_BROWSE_PAGED
        self.currentResults = WhereIsIt:BrowseFurnitureVault()
        self.page           = 1
        self.totalPages     = math.max(1, math.ceil(#self.currentResults / RESULTS_PER_PAGE))
        self:RefreshList()

    elseif key == "characters" then
        self.mode          = MODE_CHARACTERS
        self.charPages     = WhereIsIt:GetCharacterPages()
        self.charPageIndex = 1
        self:RefreshList()
    end

end

--------------------------------------------------
-- List Refresh
--------------------------------------------------
function WhereIsIt_Screen:RefreshList()
    local list = self.mainList
    list:Clear()

    -- Always show the (invisible) search field dummy at position 0
    local searchDummy = ZO_GamepadEntryData:New("")
    searchDummy.isSearchField = true
    list:AddEntry("ZO_GamepadSubMenuEntryTemplate", searchDummy)

    if self.mode == MODE_HOME then
        -- Show browse menu items
        for _, item in ipairs(BROWSE_MENU_ITEMS) do
            local entry = ZO_GamepadEntryData:New(item.label)
            entry.isBrowseMenu = true
            entry.browseKey    = item.key
            list:AddEntry("ZO_GamepadSubMenuEntryTemplate", entry)
        end

        if self.pageLabel then self.pageLabel:SetHidden(true) end

    elseif self.mode == MODE_SEARCH then
        -- Paged search results (same as original)
        local total = #self.currentResults
        self.totalPages = math.max(1, math.ceil(total / RESULTS_PER_PAGE))
        if self.page > self.totalPages then self.page = self.totalPages end

        if total == 0 then
            if self.currentQuery ~= "" then
                local entry = ZO_GamepadEntryData:New("|cCC4444No results for: " .. self.currentQuery .. "|r")
                list:AddEntry("ZO_GamepadSubMenuEntryTemplate", entry)
            end
        else
            local startIdx = (self.page - 1) * RESULTS_PER_PAGE + 1
            local endIdx   = math.min(startIdx + RESULTS_PER_PAGE - 1, total)
            for i = startIdx, endIdx do
                self:AddResultEntry(list, self.currentResults[i])
            end
        end

        if self.pageLabel then
            if self.totalPages > 1 then
                self.pageLabel:SetText(string.format("Page %d / %d", self.page, self.totalPages))
                self.pageLabel:SetHidden(false)
            else
                self.pageLabel:SetHidden(true)
            end
        end

    elseif self.mode == MODE_CURRENCY then
        -- One currency type per page, all holders listed on that page
        if #self.currencyPages == 0 then
            local entry = ZO_GamepadEntryData:New("|cCC4444No currency data found.|r")
            list:AddEntry("ZO_GamepadSubMenuEntryTemplate", entry)
            if self.pageLabel then self.pageLabel:SetHidden(true) end
        else
            if self.currencyPageIndex > #self.currencyPages then self.currencyPageIndex = #self.currencyPages end
            local currPage = self.currencyPages[self.currencyPageIndex]

            for i = 1, #currPage.rows do
                self:AddResultEntry(list, currPage.rows[i])
            end

            if self.pageLabel then
                local label = string.format("|c%s%s|r  |c888888(%d / %d)|r",
                    currPage.color, currPage.currencyLabel,
                    self.currencyPageIndex, #self.currencyPages)
                self.pageLabel:SetText(label)
                self.pageLabel:SetHidden(false)
            end
        end

    elseif self.mode == MODE_BROWSE then
        -- All results, no paging (currency only)
        local total = #self.currentResults
        if total == 0 then
            local entry = ZO_GamepadEntryData:New("|cCC4444No data found. Visit the location first to scan it.|r")
            list:AddEntry("ZO_GamepadSubMenuEntryTemplate", entry)
        else
            for i = 1, total do
                self:AddResultEntry(list, self.currentResults[i])
            end
        end
        if self.pageLabel then self.pageLabel:SetHidden(true) end

    elseif self.mode == MODE_BROWSE_PAGED then
        -- Paged browse (bank / furniture vault)
        local total = #self.currentResults
        self.totalPages = math.max(1, math.ceil(total / RESULTS_PER_PAGE))
        if self.page > self.totalPages then self.page = self.totalPages end

        if total == 0 then
            local entry = ZO_GamepadEntryData:New("|cCC4444No data found. Visit the location first to scan it.|r")
            list:AddEntry("ZO_GamepadSubMenuEntryTemplate", entry)
        else
            local startIdx = (self.page - 1) * RESULTS_PER_PAGE + 1
            local endIdx   = math.min(startIdx + RESULTS_PER_PAGE - 1, total)
            for i = startIdx, endIdx do
                self:AddResultEntry(list, self.currentResults[i])
            end
        end

        if self.pageLabel then
            if self.totalPages > 1 then
                self.pageLabel:SetText(string.format("Page %d / %d", self.page, self.totalPages))
                self.pageLabel:SetHidden(false)
            else
                self.pageLabel:SetHidden(true)
            end
        end

    elseif self.mode == MODE_CHARACTERS then
        -- One character per "page", shoulder buttons switch characters
        if #self.charPages == 0 then
            local entry = ZO_GamepadEntryData:New("|cCC4444No character data found.|r")
            list:AddEntry("ZO_GamepadSubMenuEntryTemplate", entry)
            if self.pageLabel then self.pageLabel:SetHidden(true) end
        else
            if self.charPageIndex > #self.charPages then self.charPageIndex = #self.charPages end
            local charPage = self.charPages[self.charPageIndex]
            local items    = charPage.items

            if #items == 0 then
                local entry = ZO_GamepadEntryData:New("|cCC4444" .. charPage.charName .. " has no items.|r")
                list:AddEntry("ZO_GamepadSubMenuEntryTemplate", entry)
            else
                for i = 1, #items do
                    self:AddResultEntry(list, items[i])
                end
            end

            -- Page label shows character name + index
            if self.pageLabel then
                local label = string.format("|cFFCC00%s|r  |c888888(%d / %d)|r",
                    charPage.charName, self.charPageIndex, #self.charPages)
                self.pageLabel:SetText(label)
                self.pageLabel:SetHidden(false)
            end
        end
    end

    list:Commit()

    if self.keybindStripDescriptor then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybindStripDescriptor)
    end

    if self.header then
        ZO_GamepadGenericHeader_Refresh(self.header, { titleText = "|cFFCC00Where Is It?|r" })
    end
end

-- Shared helper to add a single result row to the list
function WhereIsIt_Screen:AddResultEntry(list, r)
    local nameColor = "ffffff"
    if not r.isCurrency then
        if r.qColor then
            nameColor = r.qColor
        else
            local q = r.quality
            if q == nil and r.bagId and r.slotIndex then
                local link = GetItemLink(r.bagId, r.slotIndex)
                if link and link ~= "" then
                    q = GetItemLinkDisplayQuality(link)
                end
            end
            nameColor = (q ~= nil and (QUALITY_COLOR[q] or QUALITY_HEX[q])) or "ffffff"
        end
    end
    local cc   = r.isCurrency and (CURRENCY_COLOR[r.displayName] or "FFFFFF") or nil
    local text = string.format("|c%s%s|r", cc or nameColor, r.displayName)
    local entry = ZO_GamepadEntryData:New(text)
    entry.resultData = r
    list:AddEntry("ZO_GamepadSubMenuEntryTemplate", entry)
end

function WhereIsIt_Screen:PerformUpdate()
end

function WhereIsIt_Screen_OnInitialized(control)
    WhereIsIt.screen = WhereIsIt_Screen:New(control)
end

--------------------------------------------------
-- Main Menu Integration
--------------------------------------------------
local function AddToMainMenu()
    local ICON = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_activityFinder.dds"
    local entry = ZO_GamepadEntryData:New("|cFFCC00Where Is It?|r", ICON)
    entry:SetIconTintOnSelection(true)
    entry:SetIconDisabledTintOnSelection(true)
    entry.id   = 997
    entry.data = { name = "|cFFCC00Where Is It?|r", id = 997, scene = "whereIsItGamepad" }

    local insertIndex = nil
    for i, v in ipairs(ZO_MENU_ENTRIES) do
        if v.id == ZO_MENU_MAIN_ENTRIES.INVENTORY then
            insertIndex = i + 1
            break
        end
    end
    if insertIndex then
        table.insert(ZO_MENU_ENTRIES, insertIndex, entry)
    else
        table.insert(ZO_MENU_ENTRIES, entry)
    end

    if MAIN_MENU_GAMEPAD then
        MAIN_MENU_GAMEPAD:RefreshLists()
        MAIN_MENU_GAMEPAD:UpdateEntryEnabledStates()
    end
end

--------------------------------------------------
-- Addon Loaded
--------------------------------------------------
local function OnAddonLoaded(event, addonName)
    if addonName ~= WhereIsIt.name then return end

    WhereIsIt.savedVariables = ZO_SavedVars:NewAccountWide(
        "WhereIsIt_SavedVars", 4, nil,
        { characters = {}, account = { bank = {}, craftBag = {}, guildBank = {}, house = {}, furnitureVault = {} } }
    )

    EVENT_MANAGER:RegisterForEvent(
        WhereIsIt.name .. "_Activate",
        EVENT_PLAYER_ACTIVATED,
        function()
            WhereIsIt:ScanCharacter()
            AddToMainMenu()
            EVENT_MANAGER:UnregisterForEvent(WhereIsIt.name .. "_Activate", EVENT_PLAYER_ACTIVATED)
        end
    )

    EVENT_MANAGER:RegisterForEvent(
        WhereIsIt.name .. "_HouseEnter",
        EVENT_PLAYER_ACTIVATED,
        function()
            if IsOwnerOfCurrentHouse and IsOwnerOfCurrentHouse() then
                WhereIsIt:ScanHouseChests()
                WhereIsIt:ScanFurnitureVault()
            end
        end
    )

    local scanPending = false
    EVENT_MANAGER:RegisterForEvent(
        WhereIsIt.name .. "_InvUpdate",
        EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
        function(eventCode, bagId)
            if bagId == BAG_BACKPACK or bagId == BAG_WORN or bagId == BAG_COMPANION_WORN then
                if not scanPending then
                    scanPending = true
                    zo_callLater(function()
                        WhereIsIt:ScanCharacter()
                        scanPending = false
                    end, 2000)
                end
            end
        end
    )

    EVENT_MANAGER:RegisterForEvent(
        WhereIsIt.name .. "_Bank",
        EVENT_OPEN_BANK,
        function() WhereIsIt:ScanBank() end
    )

    EVENT_MANAGER:RegisterForEvent(
        WhereIsIt.name .. "_House",
        EVENT_HOUSING_EDITOR_MODE_CHANGED,
        function()
            WhereIsIt:ScanHouseChests()
            WhereIsIt:ScanFurnitureVault()
        end
    )

    EVENT_MANAGER:RegisterForEvent(
        WhereIsIt.name .. "_GuildBankReady",
        EVENT_GUILD_BANK_ITEMS_READY,
        function() WhereIsIt:ScanGuildBank() end
    )

    EVENT_MANAGER:RegisterForEvent(
        WhereIsIt.name .. "_GuildBankAdded",
        EVENT_GUILD_BANK_ITEM_ADDED,
        function() WhereIsIt:ScanGuildBank() end
    )

    EVENT_MANAGER:RegisterForEvent(
        WhereIsIt.name .. "_GuildBankRemoved",
        EVENT_GUILD_BANK_ITEM_REMOVED,
        function() WhereIsIt:ScanGuildBank() end
    )

    EVENT_MANAGER:RegisterForEvent(
        WhereIsIt.name .. "_CompanionOn",
        EVENT_COMPANION_ACTIVATED,
        function() WhereIsIt:ScanCompanion() end
    )

    EVENT_MANAGER:RegisterForEvent(
        WhereIsIt.name .. "_CompanionOff",
        EVENT_COMPANION_DEACTIVATED,
        function()
            local charId = tostring(GetCurrentCharacterId())
            local sv = WhereIsIt.savedVariables
            if sv.characters[charId] then
                sv.characters[charId].companion = {}
            end
        end
    )

    EVENT_MANAGER:RegisterForEvent(
        WhereIsIt.name .. "_Deactivate",
        EVENT_PLAYER_DEACTIVATED,
        function() WhereIsIt:ScanCharacter() end
    )

    SLASH_COMMANDS["/wii"] = function()
        SCENE_MANAGER:Show("whereIsItGamepad")
    end

    EVENT_MANAGER:UnregisterForEvent(WhereIsIt.name, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(WhereIsIt.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
