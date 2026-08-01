SetCollectionMarker = SetCollectionMarker or {}
local SCM = SetCollectionMarker
SCM.Trade = SCM.Trade or {}

---------------------------------------------------------------------
--[[
When a player whispers us with item links, store the item links for
some amount of time. When we initiate a trade with the player, either
automatically add the items or show a button that will add those
items to the trade window.
Once the item is traded, remove it from the list, in case they trade
again. We also need to deal with not putting duplicate items, and
checking that player's list for duplicate items.
]]

---------------------------------------------------------------------
-- Common
---------------------------------------------------------------------
-- Currently trading recipient
local otherCharacterName = ""
local otherDisplayName = ""

-- Correct "key" for trading recipient. Should usually be the display name, but could be character?
local currentlyTradingName = ""


---------------------------------------------------------------------
-- The data could be saved with either @name or character name, maybe
---------------------------------------------------------------------
local function UpdateTraderDataName()
    local wantedItems = SCM.Whisper.GetWantedItems()

    -- Check both the display name and the character name
    if (wantedItems[otherDisplayName]) then
        currentlyTradingName = otherDisplayName
    else
        currentlyTradingName = otherCharacterName
    end
end


---------------------------------------------------------------------
-- Keybind string
---------------------------------------------------------------------
local function GetKeybindString()
    -- Get all binds to show a nice string
    -- The keybind piggybacks off of Cycle Focused Quest
    local layerIndex, categoryIndex, actionIndex = GetActionIndicesFromName("SCM_ADDTOTRADE")
    local binds = {}
    for i = 1, 4 do
        local keyCode, mod1, mod2, mod3, mod4 = GetActionBindingInfo(layerIndex, categoryIndex, actionIndex, i)
        if (keyCode and keyCode ~= KEY_INVALID) then
            local keybindString = ZO_Keybindings_GetBindingStringFromKeys(keyCode, mod1, mod2, mod3, mod4)
            table.insert(binds, "|c08BD1D[ " .. keybindString .. " ]|r")
        end
    end
    local bindStrings = "|c08BD1D[ Not bound ]|r"
    if (#binds > 0) then
        bindStrings = table.concat(binds, " or ")
    end
    return string.format("Use keybind for \"%s\" to add to trade:\n%s",
        GetString(SI_BINDING_NAME_ASSIST_NEXT_TRACKED_QUEST),
        bindStrings)
end


---------------------------------------------------------------------
-- Showing in keybind strip
---------------------------------------------------------------------
local keybindGroup = {
    {
        name = "Add Requested to Trade",
        keybind = "SCM_ADDTOTRADE",
        callback = function() SCM.Trade.AddItemsToTrade() end,
        enabled = function() return #SCM.Whisper.GetMatchingItems(currentlyTradingName, true) > 0 end,
        alignment = KEYBIND_STRIP_ALIGN_CENTER,
    },
}

local function AddToKeybindStrip()
    KEYBIND_STRIP:AddKeybindButtonGroup(keybindGroup)
    InsertNamedActionLayerAbove("Set Collection Marker", GetString(SI_KEYBINDINGS_LAYER_USER_INTERFACE_SHORTCUTS))
end

local function RemoveFromKeybindStrip()
    RemoveActionLayerByName("Set Collection Marker")
    KEYBIND_STRIP:RemoveKeybindButtonGroup(keybindGroup)
end

local function UpdateKeybind()
    KEYBIND_STRIP:UpdateKeybindButtonGroup(keybindGroup)
end


---------------------------------------------------------------------
-- Gamepad trade
---------------------------------------------------------------------
local function ShowGamepadTrade()
    if (#SCM.Whisper.GetMatchingItems(currentlyTradingName, true) < 1) then
        SCM_GamepadTrade:SetHidden(true)
        return
    end
    SCM_GamepadTrade:SetParent(ZO_Trade_Gamepad)
    SCM_GamepadTrade:SetHidden(false)

    SCM_GamepadTradeLabel:SetText(SCM.Trade.GetTradeButtonTooltip())

    SCM_GamepadTrade:SetDimensions(800, 800)
    local width = SCM_GamepadTradeLabel:GetTextWidth()
    local height = SCM_GamepadTradeLabel:GetTextHeight()
    SCM_GamepadTrade:SetDimensions(width + 4, height + 8)
    SCM_GamepadTrade:ClearAnchors()
    SCM_GamepadTrade:SetAnchor(TOP, GuiRoot, TOP, 0, 20)
end


---------------------------------------------------------------------
-- Trade Inventory Button
---------------------------------------------------------------------
local matches = {}
local itemsString = ""

local function UpdateTradeButton()
    UpdateTraderDataName()
    matches, itemsString = SCM.Whisper.GetMatchingItems(currentlyTradingName, true)

    -- In gamepad UI, just display a box with the requested items
    if (IsInGamepadPreferredMode() and SCM.savedOptions.showTradeButton) then
        ShowGamepadTrade()
    end

    UpdateKeybind()
end
SCM.Trade.UpdateTradeButton = UpdateTradeButton

local function AddItemsToTrade()
    if (not currentlyTradingName or currentlyTradingName == "") then
        -- d("not currently trading")
        return
    end

    -- * TradeAddItem(*[Bag|#Bag]* _bagId_, *integer* _slotIndex_, *luaindex:nilable* _tradeIndex_)
    for tradeIndex = 1, 5 do
        local bagId = GetTradeItemBagAndSlot(TRADE_ME, tradeIndex)
        if (not bagId and #matches > 0) then
            local slotIndex = table.remove(matches, 1) -- TODO: maybe don't remove until it's traded away
            local itemLink = GetItemLink(BAG_BACKPACK, slotIndex, LINK_STYLE_BRACKETS)
            local itemId = GetItemLinkItemId(itemLink)
            SCM.Whisper.GetWantedItems()[currentlyTradingName].items[itemId] = nil -- Also remove it from the original

            -- If the item is already in the window we get an alert back, but it should be ok
            d(string.format("Adding %s to slot %d", itemLink, tradeIndex))
            TradeAddItem(BAG_BACKPACK, slotIndex, tradeIndex)
        end
    end
    UpdateTradeButton()
    SCM.Mail.UpdateMailUI()
end
SCM.Trade.AddItemsToTrade = AddItemsToTrade

local function GetTradeButtonTooltip()
    return string.format("%s wants:%s\n\n%s", currentlyTradingName, itemsString, GetKeybindString())
end
SCM.Trade.GetTradeButtonTooltip = GetTradeButtonTooltip


---------------------------------------------------------------------
-- Trading
---------------------------------------------------------------------
local function OnTrade()
    -- d(string.format("Trading with %s / %s", otherCharacterName, otherDisplayName))
    -- Add keybind
    RemoveFromKeybindStrip()
    AddToKeybindStrip()

    SCM_TradeButton:SetParent(ZO_TradeMyControls)
    SCM_TradeButton:ClearAnchors()
    SCM_TradeButton:SetAnchor(RIGHT, ZO_TradeMyControlsMoney, LEFT, -10, 0)

    UpdateTradeButton()
end

-- Either being invited or inviting someone else, doesn't matter
local function OnTradeInvite(_, characterName, displayName)
    otherCharacterName = zo_strformat("<<1>>", characterName)
    otherDisplayName = displayName
end

-- Cleanup
local function OnTradeExit()
    otherCharacterName = ""
    otherDisplayName = ""
    currentlyTradingName = ""
    RemoveFromKeybindStrip()
end


---------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------
function SCM.Trade.Initialize()
    -- It would be easier if these events just provided the names with the confirm event...
    EVENT_MANAGER:RegisterForEvent(SCM.name .. "TradeConsidering", EVENT_TRADE_INVITE_CONSIDERING, OnTradeInvite)
    EVENT_MANAGER:RegisterForEvent(SCM.name .. "TradeWaiting", EVENT_TRADE_INVITE_WAITING, OnTradeInvite)
    EVENT_MANAGER:RegisterForEvent(SCM.name .. "TradeAccepted", EVENT_TRADE_INVITE_ACCEPTED, OnTrade)
    EVENT_MANAGER:RegisterForEvent(SCM.name .. "TradeSucceeded", EVENT_TRADE_SUCCEEDED, OnTradeExit)
    EVENT_MANAGER:RegisterForEvent(SCM.name .. "TradeCancelled", EVENT_TRADE_CANCELED, OnTradeExit)

    SCM_TradeButtonAddItems:SetHidden(not SCM.savedOptions.showTradeButton)
end

