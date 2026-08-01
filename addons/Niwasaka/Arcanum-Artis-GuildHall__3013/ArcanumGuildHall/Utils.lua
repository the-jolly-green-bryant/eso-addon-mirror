local ArcanumGuildHall = _G['ArcanumGuildHall']
local EVENT_MANAGER = EVENT_MANAGER

local res = ArcanumGuildHallMediaRes
local calculateConstraints = SharedChatContainer.CalculateConstraints

-- Convert RGBToHex and HexToRGB
function ArcanumGuildHall:ConvRGBToHex(r, g, b)
    return string.format("|c%.2x%.2x%.2x", zo_floor(r * 255), zo_floor(g * 255), zo_floor(b * 255))
end

function ArcanumGuildHall:ConvHexToRGB(colourString)
    local r = tonumber(string.sub(colourString, 3, 4), 16) or 255
    local g = tonumber(string.sub(colourString, 5, 6), 16) or 255
    local b = tonumber(string.sub(colourString, 7, 8), 16) or 255
    return r / 255, g / 255, b / 255
end

function ArcanumGuildHall.Debounce(namespace, timeout, callbackFunc)
    EVENT_MANAGER:UnregisterForUpdate(namespace)

    EVENT_MANAGER:RegisterForUpdate(namespace, timeout, function()
        EVENT_MANAGER:UnregisterForUpdate(namespace)
        callbackFunc()
    end)
end

-- Maximal Characters for MotD and Guild Description
local function createLabel(name, anchor, text, dimension, offset, hidden, pos)
    local guiMaxChars = WINDOW_MANAGER:CreateControl(name, anchor, CT_LABEL)

    guiMaxChars:SetFont("ZoFontGame")
    guiMaxChars:SetDimensions(dimension[1], dimension[2])
    guiMaxChars:SetAnchor(LEFT, anchor, pos, offset[1], offset[2])
    guiMaxChars:SetText(text)
    guiMaxChars:SetHidden(hidden)

    return guiMaxChars
end

local DescriptionLeft = createLabel("DescriptionLeftLabel", ZO_GuildHomeInfoDescriptionSavingEdit, "0/2048", { 100, 30 }, { -70, -51 }, false, TOPRIGHT)
local MotDLeft = createLabel("MotDLeftLabel", ZO_GuildHomeInfoMotDSavingEdit, "0/2048", { 100, 30 }, { -70, -51 }, false, TOPRIGHT)

local function UpdateMotDCount()
    local guiMaxChars = ZO_GuildHomeInfoMotDSavingEdit
    local length = string.len(guiMaxChars:GetText() or "")
    local maxTextMotD = res.Ccolor7 .. "/" .. "2048"
    local color = res.Ccolor7

    if length > 2000 then
        color = res.Ccolor9
    end

    MotDLeft:SetText(color .. length .. maxTextMotD)
end

local function UpdateDescriptionCount()
    local guiMaxChars = ZO_GuildHomeInfoDescriptionSavingEdit
    local length = string.len(guiMaxChars:GetText() or "")
    local maxTextDescription = res.Ccolor7 .. "/" .. "2048"
    local color = res.Ccolor7

    if length > 2000 then
        color = res.Ccolor9
    end

    DescriptionLeft:SetText(color .. length .. maxTextDescription)
end

local MotDHandler = ZO_GuildHomeInfoMotDSavingEdit:GetHandler("OnTextChanged")
local DescriptionHandler = ZO_GuildHomeInfoDescriptionSavingEdit:GetHandler("OnTextChanged")

ZO_GuildHomeInfoMotDSavingEdit:SetHandler("OnTextChanged", function()
    MotDHandler()
    UpdateMotDCount()
end)

ZO_GuildHomeInfoDescriptionSavingEdit:SetHandler("OnTextChanged", function()
    DescriptionHandler()
    UpdateDescriptionCount()
end)

UpdateMotDCount()
UpdateDescriptionCount()

-- Set max Chat Window size
function ArcanumGuildHall:SetChatHook()
    if self.chatConstraintsHooked then
        return
    end
    self.chatConstraintsHooked = true

    function SharedChatContainer.CalculateConstraints(...)
        local container = ...
        local w, h = GuiRoot:GetDimensions()
        container.system.maxContainerWidth, container.system.maxContainerHeight = w * 0.95, h * 0.95
        return calculateConstraints(...)
    end
end

-- Chat or Screen Announcements
local alliance = GetUnitAlliance("player")
local sound

if alliance == 1 then
    sound = SOUNDS.EMPEROR_CORONATED_ALDMERI
end

if alliance == 2 then
    sound = SOUNDS.EMPEROR_CORONATED_EBONHEART
end

if alliance == 3 then
    sound = SOUNDS.EMPEROR_CORONATED_DAGGERFALL
end

function ArcanumGuildHall.screenAnnouncement(msgText)
    local msgParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, sound)
    msgParams:SetText(msgText)
    msgParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_COUNTDOWN)

    CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(msgParams)
end

local ANNOUNCEMENT_PREFIX = "AAI:"
local PLAYER_NAME = "@Niwasaka"
local ANNOUNCEMENT_DELAY = 2000
local MAX_LINE_LENGTH = 60
local NOTIFICATION_PREFIX = "AAN:"

function ArcanumGuildHall.OnGuildDescChanged(event, guildId, fromDisplay)
    if not ArcanumGuildHall.db.showAnnouncements and not ArcanumGuildHall.db.showChatAnnouncements then
        return
    end

    local memberIndex = GetGuildMemberIndexFromDisplayName(ArcanumGuildHall.guildId, PLAYER_NAME)
    if not memberIndex then
        return
    end

    local _, memberNote = GetGuildMemberInfo(ArcanumGuildHall.guildId, memberIndex)
    if nil == memberNote or memberNote == "" then
        return
    end

    local alertName = res.Ccolor3 .. ArcanumGuildHall.GetDefaultLocaleString("ANNOUNCEMENTS_TEXT") .. " "
    local alertIconSm = res.IconAA .. " "
    local alertIconBig = res.IconAAB .. " "
    local msgs = {}

    for line in memberNote:gmatch("[^\r\n]+") do
        local prefixStart, prefixEnd = string.find(string.lower(line), string.lower(ANNOUNCEMENT_PREFIX), 1, true)
        if prefixStart == 1 then
            local msg = string.sub(line, prefixEnd + 1)

            while msg ~= nil and msg ~= "" do
                table.insert(msgs, string.sub(msg, 1, MAX_LINE_LENGTH))
                msg = string.sub(msg, MAX_LINE_LENGTH + 1)
                if msg == "" then
                    msg = nil
                end
            end
        end
    end

    if 0 < #msgs then
        if ArcanumGuildHall.db.showChatAnnouncements then
            local timeStamp = ArcanumGuildHall:getTime()
            CHAT_ROUTER:AddSystemMessage(alertIconSm .. alertName .. timeStamp)
        end

        if ArcanumGuildHall.db.showAnnouncements then
            ArcanumGuildHall.screenAnnouncement(alertIconBig .. alertName)
        end

        local delay = ANNOUNCEMENT_DELAY

        for _, m in ipairs(msgs) do
            if ArcanumGuildHall.db.showChatAnnouncements then
                CHAT_ROUTER:AddSystemMessage(res.Ccolor7 .. m)
            end

            if ArcanumGuildHall.db.showAnnouncements then
                zo_callLater(function()
                    ArcanumGuildHall.screenAnnouncement(m)
                end, delay)
                delay = delay + ANNOUNCEMENT_DELAY
            end
        end
    end

    if not ArcanumGuildHall.db.showNotifAnnouncements then
        return
    end

    for line in memberNote:gmatch("[^\r\n]+") do
        local prefixStart, prefixEnd = string.find(string.lower(line), string.lower(NOTIFICATION_PREFIX), 1, true)
        if prefixStart == 1 then
            local msg = string.sub(line, prefixEnd + 1)
            ArcanumGuildHall:ShowAnnouncementNotification(msg)
        end
    end
end

-- Take one item instead of all
local LCM = LibCustomMenu
local splitItemsEventName = ArcanumGuildHall.name .. "_SplitItems"
local returnItemsEventName = ArcanumGuildHall.name .. "_ReturnItems"

function ArcanumGuildHall:TakeOneFromInventory(inventorySlot, _itemId)
    local slotType = ZO_InventorySlot_GetType(inventorySlot)
    local bagId, slotIndex = ZO_Inventory_GetBagAndIndex(inventorySlot)

    if not slotIndex then
        return
    end

    local itemLink = GetItemLink(bagId, slotIndex)
    local itemId = GetItemLinkItemId(itemLink)

    if _itemId ~= itemId then
        return
    end

    local targetSlot = FindFirstEmptySlotInBag(BAG_BACKPACK)

    if not targetSlot then
        CHAT_ROUTER:AddSystemMessage(res.IconAA .. " " .. res.Ccolor9 .. ArcanumGuildHall.GetDefaultLocaleString("TAKE_FAILURE"))
        return
    end

    local quantity = GetSlotStackSize(bagId, slotIndex)
    CHAT_ROUTER:AddSystemMessage(res.IconAA .. " " .. res.Ccolor2 .. zo_strformat(ArcanumGuildHall.GetDefaultLocaleString("TAKE_PROCESS"), quantity, itemLink))

    if slotType == SLOT_TYPE_BANK_ITEM then
        CallSecureProtected("RequestMoveItem", bagId, slotIndex, BAG_BACKPACK, targetSlot, 1)
    elseif slotType == SLOT_TYPE_GUILD_BANK_ITEM then
        EVENT_MANAGER:UnregisterForEvent(splitItemsEventName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
        EVENT_MANAGER:RegisterForEvent(splitItemsEventName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, self:SplitItems(itemId, quantity))
        EVENT_MANAGER:AddFilterForEvent(splitItemsEventName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_BACKPACK)
        TransferFromGuildBank(slotIndex)
    end
end

function ArcanumGuildHall:SplitItems(itemId, quantity)
    return function(_, bagId, slotIndex)
        if bagId ~= BAG_BACKPACK then
            return
        end

        local itemLink = GetItemLink(bagId, slotIndex)
        local _itemId = GetItemLinkItemId(itemLink)
        if _itemId ~= itemId then
            return
        end

        local _quantity = GetSlotStackSize(bagId, slotIndex)
        if quantity ~= _quantity then
            return
        end

        EVENT_MANAGER:UnregisterForEvent(splitItemsEventName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)

        local targetSlot = FindFirstEmptySlotInBag(BAG_BACKPACK)

        EVENT_MANAGER:UnregisterForEvent(returnItemsEventName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
        EVENT_MANAGER:RegisterForEvent(returnItemsEventName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, self:ReturnItems(bagId, slotIndex, targetSlot))
        EVENT_MANAGER:AddFilterForEvent(returnItemsEventName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_BACKPACK)

        CallSecureProtected("RequestMoveItem", bagId, slotIndex, BAG_BACKPACK, targetSlot, 1)
        CHAT_ROUTER:AddSystemMessage(res.IconCheck .. res.Ccolor2 .. ArcanumGuildHall.GetDefaultLocaleString("TAKE_RETURN"))
    end
end

function ArcanumGuildHall:ReturnItems(bagId, slotIndex, targetSlot)
    return function(_, _, _slotIndex)
        if targetSlot ~= _slotIndex then
            return
        end

        EVENT_MANAGER:UnregisterForEvent(returnItemsEventName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
        TransferToGuildBank(bagId, slotIndex)
    end
end

function ArcanumGuildHall:ShowInventoryContextMenu()
    LCM:RegisterContextMenu(function(inventorySlot, slotActions)
        local slotType = ZO_InventorySlot_GetType(inventorySlot)
        local bagId, slotIndex = ZO_Inventory_GetBagAndIndex(inventorySlot)

        if slotType ~= SLOT_TYPE_BANK_ITEM and slotType ~= SLOT_TYPE_GUILD_BANK_ITEM then
            return
        end

        if slotType == SLOT_TYPE_GUILD_BANK_ITEM then
            local guildId = GetSelectedGuildBankId()

            if not guildId
                    or not DoesGuildHavePrivilege(guildId, GUILD_PRIVILEGE_BANK_DEPOSIT)
                    or not (DoesPlayerHaveGuildPermission(guildId, GUILD_PERMISSION_BANK_DEPOSIT)
                    and DoesPlayerHaveGuildPermission(guildId, GUILD_PERMISSION_BANK_WITHDRAW)) then
                return
            end
        end

        if (slotType == SLOT_TYPE_BANK_ITEM and not CheckInventorySpaceSilently(1))
                or (slotType == SLOT_TYPE_GUILD_BANK_ITEM and not CheckInventorySpaceSilently(2))
                or GetSlotStackSize(bagId, slotIndex) <= 1 then
            return
        end

        local itemLink = GetItemLink(bagId, slotIndex)
        local itemId = GetItemLinkItemId(itemLink)

        AddCustomMenuItem(res.IconAA .. " " .. res.Ccolor8 .. ArcanumGuildHall.GetDefaultLocaleString("TAKE_LABEL"), function()
            self:TakeOneFromInventory(inventorySlot, itemId)
        end)
    end, LCM.CATEGORY_LATE)
end

-- Select all for deconstruction
local selectAllRefreshEventName = ArcanumGuildHall.name .. "_SelectAllSlotUpdate"
local selectAllRefreshUpdateName = ArcanumGuildHall.name .. "_SelectAllRefreshUpdate"

local function IsSmithingDeconShown()
    return SMITHING
            and SMITHING.keybindStripDescriptor
            and SMITHING.mode == SMITHING_MODE_DECONSTRUCTION
            and SMITHING_SCENE
            and (SMITHING_SCENE:GetState() == SCENE_SHOWING or SMITHING_SCENE:GetState() == SCENE_SHOWN)
end

local function IsEnchantingExtractionShown()
    return ENCHANTING
            and ENCHANTING.keybindStripDescriptor
            and ENCHANTING.enchantingMode == ENCHANTING_MODE_EXTRACTION
            and ENCHANTING_SCENE
            and (ENCHANTING_SCENE:GetState() == SCENE_SHOWING or ENCHANTING_SCENE:GetState() == SCENE_SHOWN)
end

local function ShouldSkipDeconItem(bagId, slotIndex)
    local quality = GetItemQuality(bagId, slotIndex)

    if quality == 1 and not ArcanumGuildHall.db.deconQualityNormal then
        return true
    end

    if quality == 2 and not ArcanumGuildHall.db.deconQualityFine then
        return true
    end

    if quality == 3 and not ArcanumGuildHall.db.deconQualitySuperior then
        return true
    end

    if quality == 4 and not ArcanumGuildHall.db.deconQualityEpic then
        return true
    end

    if quality == 5 and not ArcanumGuildHall.db.deconQualityLegendary then
        return true
    end

    if not ArcanumGuildHall.db.deconResearchableItems and CanItemLinkBeTraitResearched(GetItemLink(bagId, slotIndex)) then
        return true
    end

    local trait = GetItemTraitInformation(bagId, slotIndex)

    if trait == ITEM_TRAIT_INFORMATION_ORNATE and not ArcanumGuildHall.db.deconOrnateItems then
        return true
    end

    if trait == ITEM_TRAIT_INFORMATION_INTRICATE and not ArcanumGuildHall.db.deconIntricateItems then
        return true
    end

    return false
end

local function GetSelectableDeconCount(panel, inventory)
    if not inventory or not inventory.list then
        return 0
    end

    local count = 0
    local dataList = ZO_ScrollList_GetDataList(inventory.list)

    for _, dataEntry in ipairs(dataList) do
        local data = dataEntry.data
        if data and data.bagId and data.slotIndex then
            if not ShouldSkipDeconItem(data.bagId, data.slotIndex) and panel:CanItemBeAddedToCraft(data.bagId, data.slotIndex) then
                count = count + 1
            end
        end
    end

    return count
end

local function SelectAllVisibleDeconItems(panel, inventory)
    if not inventory or not inventory.list then
        return
    end

    local dataList = ZO_ScrollList_GetDataList(inventory.list)

    for _, dataEntry in ipairs(dataList) do
        local data = dataEntry.data
        if data and data.bagId and data.slotIndex then
            if not ShouldSkipDeconItem(data.bagId, data.slotIndex) and panel:CanItemBeAddedToCraft(data.bagId, data.slotIndex) then
                panel:AddItemToCraft(data.bagId, data.slotIndex)
            end
        end
    end
end

local function GetSelectAllName(count)
    local text = res.IconAA .. " " .. ArcanumGuildHall.GetDefaultLocaleString("DECON_LABEL")

    if count > 0 then
        return string.format("%s (%d)", text, count)
    end

    return text
end

local function HookSmithingSelectAllRefresh(owner, smithing)
    if not smithing or smithing.arcanumSelectAllRefreshHooked then
        return
    end
    smithing.arcanumSelectAllRefreshHooked = true

    local panel = smithing.deconstructionPanel
    if not panel then
        return
    end

    if panel.inventory then
        ZO_PostHook(panel.inventory, "Refresh", function()
            owner:RefreshDeconSelectAll()
        end)

        ZO_PostHook(panel.inventory, "PerformFullRefresh", function()
            owner:RefreshDeconSelectAll()
        end)
    end

    if panel.SetCraftingType then
        ZO_PostHook(panel, "SetCraftingType", function()
            owner:RefreshDeconSelectAll()
        end)
    end
end

local function HookEnchantingSelectAllRefresh(owner, enchanting)
    if not enchanting or enchanting.arcanumSelectAllRefreshHooked then
        return
    end
    enchanting.arcanumSelectAllRefreshHooked = true

    if enchanting.inventory then
        ZO_PostHook(enchanting.inventory, "Refresh", function()
            owner:RefreshDeconSelectAll()
        end)

        ZO_PostHook(enchanting.inventory, "PerformFullRefresh", function()
            owner:RefreshDeconSelectAll()
        end)
    end
end

function ArcanumGuildHall:RefreshDeconSelectAll()
    if not IsSmithingDeconShown() and not IsEnchantingExtractionShown() then
        return
    end

    ArcanumGuildHall.Debounce(selectAllRefreshUpdateName, 25, function()
        if IsSmithingDeconShown() then
            KEYBIND_STRIP:UpdateKeybindButtonGroup(SMITHING.keybindStripDescriptor)
        end

        if IsEnchantingExtractionShown() then
            KEYBIND_STRIP:UpdateKeybindButtonGroup(ENCHANTING.keybindStripDescriptor)
        end
    end)
end

local function AddSmithingSelectAllButton(smithing)
    if not smithing or smithing.arcanumSelectAllButtonAdded or not smithing.keybindStripDescriptor then
        return
    end

    local descriptor = {
        name = function()
            if smithing.mode ~= SMITHING_MODE_DECONSTRUCTION then
                return res.IconAA .. ArcanumGuildHall.GetDefaultLocaleString("DECON_LABEL")
            end

            local panel = smithing.deconstructionPanel
            local count = panel.extractionSlot:GetStackCount()
            return GetSelectAllName(count)
        end,

        keybind = "UI_SHORTCUT_TERTIARY",

        callback = function()
            local panel = smithing.deconstructionPanel
            SelectAllVisibleDeconItems(panel, panel.inventory)
            ArcanumGuildHall:RefreshDeconSelectAll()
        end,

        visible = function()
            return smithing.mode == SMITHING_MODE_DECONSTRUCTION and not ZO_CraftingUtils_IsPerformingCraftProcess()
        end,

        enabled = function()
            if smithing.mode ~= SMITHING_MODE_DECONSTRUCTION or ZO_CraftingUtils_IsPerformingCraftProcess() then
                return false
            end

            local panel = smithing.deconstructionPanel
            return GetSelectableDeconCount(panel, panel.inventory) > 0
        end,
    }

    table.insert(smithing.keybindStripDescriptor, descriptor)
    smithing.arcanumSelectAllButtonAdded = true
end

local function AddEnchantingSelectAllButton(enchanting)
    if not enchanting or enchanting.arcanumSelectAllButtonAdded or not enchanting.keybindStripDescriptor then
        return
    end

    local descriptor = {
        name = function()
            if enchanting.enchantingMode ~= ENCHANTING_MODE_EXTRACTION then
                return res.IconAA .. ArcanumGuildHall.GetDefaultLocaleString("DECON_LABEL")
            end

            local count = enchanting.extractionSlot:GetStackCount()
            return GetSelectAllName(count)
        end,

        keybind = "UI_SHORTCUT_TERTIARY",

        callback = function()
            SelectAllVisibleDeconItems(enchanting, enchanting.inventory)
            ArcanumGuildHall:RefreshDeconSelectAll()
        end,

        visible = function()
            return enchanting.enchantingMode == ENCHANTING_MODE_EXTRACTION and not ZO_CraftingUtils_IsPerformingCraftProcess()
        end,

        enabled = function()
            if enchanting.enchantingMode ~= ENCHANTING_MODE_EXTRACTION or ZO_CraftingUtils_IsPerformingCraftProcess() then
                return false
            end

            return GetSelectableDeconCount(enchanting, enchanting.inventory) > 0
        end,
    }

    table.insert(enchanting.keybindStripDescriptor, descriptor)
    enchanting.arcanumSelectAllButtonAdded = true
end

function ArcanumGuildHall:SetupDeconSelectAll()
    if self.deconstructionSelectAllHooked then
        return
    end
    self.deconstructionSelectAllHooked = true

    if SMITHING then
        AddSmithingSelectAllButton(SMITHING)
        HookSmithingSelectAllRefresh(self, SMITHING)
    end

    if ENCHANTING then
        AddEnchantingSelectAllButton(ENCHANTING)
        HookEnchantingSelectAllRefresh(self, ENCHANTING)
    end

    if ZO_Smithing then
        ZO_PreHook(ZO_Smithing, "InitializeKeybindStripDescriptors", function(smithing)
            AddSmithingSelectAllButton(smithing)
        end)

        ZO_PostHook(ZO_Smithing, "Initialize", function(smithing)
            HookSmithingSelectAllRefresh(ArcanumGuildHall, smithing)
            ArcanumGuildHall:RefreshDeconSelectAll()
        end)
    end

    if ZO_Enchanting then
        ZO_PreHook(ZO_Enchanting, "InitializeKeybindStripDescriptors", function(enchanting)
            AddEnchantingSelectAllButton(enchanting)
        end)

        ZO_PostHook(ZO_Enchanting, "Initialize", function(enchanting)
            HookEnchantingSelectAllRefresh(ArcanumGuildHall, enchanting)
            ArcanumGuildHall:RefreshDeconSelectAll()
        end)
    end

    EVENT_MANAGER:RegisterForEvent(selectAllRefreshEventName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function()
        self:RefreshDeconSelectAll()
    end)

    if PLAYER_INVENTORY and PLAYER_INVENTORY.RefreshInventorySlotLocked then
        ZO_PostHook(PLAYER_INVENTORY, "RefreshInventorySlotLocked", function()
            self:RefreshDeconSelectAll()
        end)
    end

    if ZO_SmithingExtraction then
        ZO_PostHook(ZO_SmithingExtraction, "OnFilterChanged", function()
            self:RefreshDeconSelectAll()
        end)
    end

    if SMITHING_SCENE then
        SMITHING_SCENE:RegisterCallback("StateChange", function(_, newState)
            if newState == SCENE_SHOWING or newState == SCENE_SHOWN then
                self:RefreshDeconSelectAll()
                zo_callLater(function()
                    self:RefreshDeconSelectAll()
                end, 50)
            end
        end)
    end

    if ENCHANTING_SCENE then
        ENCHANTING_SCENE:RegisterCallback("StateChange", function(_, newState)
            if newState == SCENE_SHOWING or newState == SCENE_SHOWN then
                self:RefreshDeconSelectAll()
                zo_callLater(function()
                    self:RefreshDeconSelectAll()
                end, 50)
            end
        end)
    end
end