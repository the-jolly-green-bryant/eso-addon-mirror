if ESOAssistant == nil or ESOAssistant.internal == nil then assert(false, "Error on zone module startup: Main module missing!") end
---@type table
local egint = ESOAssistant.internal
local logger = egint.logger

local currentSetId
local function OpenSetLink()
    local urlSegments = "set/" .. currentSetId
    logger:Info("Trying OpenSetLink: %d", currentSetId)
    egint.ProcessLink(urlSegments)
end

local function GetSetId(itemlink)
    local setName = select(2, GetItemLinkSetInfo(itemlink))
    currentSetId = select(6, GetItemLinkSetInfo(itemlink))
    logger:Info("Current SetId: %d (%s)", currentSetId, setName)
end

local itemsetButtonsKeyboard = {
    alignment = KEYBIND_STRIP_ALIGN_CENTER,
    {
        name = GetString(SI_ESOASSISTANT_SHOW_ITEMSET),
        keybind = "UI_SHORTCUT_QUINARY",
        callback = OpenSetLink,
        visible = function()
            return true
        end,
        enabled = function()
            return true
        end,
    },
}

local itemsetButtonsGamepad = {
    alignment = KEYBIND_STRIP_ALIGN_LEFT,
    {
        name = GetString(SI_ESOASSISTANT_SHOW_ITEMSET),
        keybind = "UI_SHORTCUT_QUINARY",
        callback = OpenSetLink,
        visible = function()
            return true
        end,
        enabled = function()
            return true
        end,
    }
}


local keybindsEnabled = false
local function RemoveKeybindStripButton()
    if keybindsEnabled == false then return end
    if IsInGamepadPreferredMode() or ZO_IsConsoleUI() then
        KEYBIND_STRIP:RemoveKeybindButtonGroup(itemsetButtonsGamepad)
    else
        KEYBIND_STRIP:RemoveKeybindButtonGroup(itemsetButtonsKeyboard)
    end
    keybindsEnabled = false
    if egint.sv.openLink == false then egint.HideQR() end
    logger:Info("Remove Set Key Strip Binding.")
end

local keybindsEnabledTooltip = {}

local function AddKeybindStripButton(tooltipControl)
    if keybindsEnabled == true or currentSetId == nil or currentSetId == 0 then return end
    if IsInGamepadPreferredMode() or ZO_IsConsoleUI() then
        KEYBIND_STRIP:AddKeybindButtonGroup(itemsetButtonsGamepad)
        if tooltipControl then keybindsEnabledTooltip[tooltipControl:GetName()] = true end
    else
        KEYBIND_STRIP:AddKeybindButtonGroup(itemsetButtonsKeyboard)
    end

    logger:Info("Adding Set Key Strip Binding.")
    keybindsEnabled = true
end


local function GetItemSlotData(slot)    -- TODO: limit slot types, like MM ?
    local slotType = slot.slotType

    local itemLink

    if slotType == SLOT_TYPE_TRADING_HOUSE_ITEM_RESULT then
        itemLink = GetTradingHouseSearchResultItemLink(slot.slotIndex, LINK_STYLE_BRACKETS)
    elseif slotType == SLOT_TYPE_TRADING_HOUSE_ITEM_LISTING then
        itemLink = GetTradingHouseListingItemLink(slot.slotIndex, LINK_STYLE_BRACKETS)
    else
        itemLink = GetItemLink(slot.bagId, slot.slotIndex, LINK_STYLE_BRACKETS)
    end

    if itemLink and itemLink ~= "" then return itemLink end
end

local lastTooltipMouseoverControl

local function OnTooltipShow(tooltipControl, hidden)
    local itemControl = moc()
    if itemControl and lastTooltipMouseoverControl == itemControl then return end

    lastTooltipMouseoverControl = itemControl
    local itemLink

    if itemControl.dataEntry and itemControl.dataEntry.data then

        local slot = itemControl.dataEntry.data
        if slot.bagId and slot.slotIndex then
            itemLink = GetItemSlotData(slot)
        elseif slot.itemLink then -- for non inventory
            itemLink = slot.itemLink
        elseif slot.lootId then -- for loot window
            itemLink = GetLootItemLink(slot.lootId, LINK_STYLE_DEFAULT)
        end

    elseif itemControl.bagId and itemControl.slotIndex then
        itemLink = GetItemSlotData(itemControl)

    elseif TRADE_WINDOW:IsTrading() and itemControl.slotControlType == "listSlot" then

        local buttonControl = itemControl:GetNamedChild("Button")
        if buttonControl == nil then return end

        local slotType = buttonControl.slotType
        local slotIndex = buttonControl.slotIndex
        local who = (slotType == SLOT_TYPE_MY_TRADE and TRADE_ME) or (slotType == SLOT_TYPE_THEIR_TRADE and TRADE_THEM) or nil

        if who == nil or slotIndex == nil then return end

        itemLink = GetTradeItemLink(who, slotIndex, LINK_STYLE_DEFAULT)
    end

    if itemLink == nil  or itemLink == "" then return end
    GetSetId(itemLink)
    AddKeybindStripButton(nil)
end


local function OnTooltipShow_Gamepad(tooltipControl, itemLink, equipped, creatorName, forceFullDurability, previewValueToAdd, itemName, equipSlot, showPlayerLocked, tradeBoPData, extraData)
    GetSetId(itemLink)
    AddKeybindStripButton(tooltipControl)
end

local function OnTooltipHide()
    lastTooltipMouseoverControl = nil
    RemoveKeybindStripButton()
end

function OnTooltipHide_Gamepad(tooltipControl)
    if tooltipControl == nil or keybindsEnabledTooltip[tooltipControl:GetName()] ~= true then return end
    keybindsEnabledTooltip[tooltipControl:GetName()] = false
    RemoveKeybindStripButton()
end

local function applyTooltipHook(tooltip, method, callback)
    local orig = tooltip[method]

    tooltip[method] = function (self, ...)
        callback(self, ...)
        return orig(self, ...)
    end
end 

local initTooltips = {}

local function initTooltipHook(self, tooltipType)
    if initTooltips[tooltipType] then return end
    logger:Info("Init tooltipType: %s", tooltipType)
    
    local tooltip = GAMEPAD_TOOLTIPS:GetAndInitializeTooltipContainerTip(tooltipType).tooltip
    -- applyTooltipHook(tooltip, "LayoutBagItem", function(...) logger:Info("LayoutBagItem", ...) end)
    applyTooltipHook(tooltip, "LayoutItem", OnTooltipShow_Gamepad)
    applyTooltipHook(tooltip, "Reset", OnTooltipHide_Gamepad)
    initTooltips[tooltipType] = true
end


function egint.initItemSetsModule()
    ItemTooltip:SetHandler("OnUpdate", OnTooltipShow, CONTROL_HANDLER_ORDER_BEFORE)
    ItemTooltip:SetHandler("OnHide", OnTooltipHide, CONTROL_HANDLER_ORDER_BEFORE)
    ItemTooltip:SetHandler("OnCleared", OnTooltipHide, CONTROL_HANDLER_ORDER_BEFORE)

    SecurePostHook(GAMEPAD_TOOLTIPS, "GetTooltip", initTooltipHook)
end
