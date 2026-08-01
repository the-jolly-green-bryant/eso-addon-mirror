-----------------------------------------------------------
-- SetCollectionMarker
-- @author Kyzeragon
-----------------------------------------------------------

SetCollectionMarker = SetCollectionMarker or {}
local SCM = SetCollectionMarker
SCM.name = "SetCollectionMarker"
SCM.version = "3.0.0"

-- LibDebugLogger
if (LibDebugLogger) then
    SCM.logger = LibDebugLogger(SCM.name)
    SCM.logger:Debug("Addon loading...")
end

-- Location for the icon
SCM.LOCATION_BEFORE = 1 -- Before the item link
SCM.LOCATION_AFTER = 2 -- After the item link
SCM.LOCATION_BEGINNING = 3 -- At the beginning of the message (in front of timestamps if pChat)
SCM.LOCATION_END = 4 -- At the end of the message

SCM.locationString = {
    [SCM.LOCATION_BEFORE] = "Before",
    [SCM.LOCATION_AFTER] = "After",
    [SCM.LOCATION_BEGINNING] = "Beginning",
    [SCM.LOCATION_END] = "End",
}

SCM.stringLocation = {
    ["Before"] = SCM.LOCATION_BEFORE,
    ["After"] = SCM.LOCATION_AFTER,
    ["Beginning"] = SCM.LOCATION_BEGINNING,
    ["End"] = SCM.LOCATION_END,
}

-- Defaults
local defaultOptions = {
    iconSize = 36,
    iconOffset = 0,
    iconStoreOffset = 0,
    iconColor = {0.4, 1, 0.5},
    show = {
        bag = true,
        bank = true,
        housebank = true,
        guild = true,
        guildstore = true,
        crafting = true,
        transmute = true,
        trading = true,
    },
    chatMessageShow = true,
    chatMessageLocation = SCM.LOCATION_BEFORE,
    chatSystemShow = true,
    chatSystemLocation = SCM.LOCATION_BEGINNING,
    chatIconSize = 18,
    chatIconColor = {0.4, 1, 0.5},

    showRequestLink = true,
    requestPrefix = "Can I get",
    requestInWhisper = true,
    showTradeButton = true,
    showMailUI = true,
}

---------------------------------------------------------------------
-- Whether we should show an icon or not
function SCM.ShouldShowIcon(itemLink)
    -- Check that this is a candidate for set collection
    if (not IsItemLinkSetCollectionPiece(itemLink)) then
        return false
    end

    -- If it's already unlocked (collected), then skip
    if (IsItemSetCollectionPieceUnlocked(GetItemLinkItemId(itemLink))) then
        return false
    end

    return true
end

---------------------------------------------------------------------
-- Display icon to the right of item
local function AddUncollectedIndicator(control, bagID, slotIndex, itemLink, show, offset)
    -- d("checking " .. itemLink)
    local uncollectedControl = control:GetNamedChild("UncollectedControl")

    -- Use the item set collections tab icon
    local function CreateUncollectedControl(parent)
        local control = WINDOW_MANAGER:CreateControl(parent:GetName() .. "UncollectedControl", parent, CT_TEXTURE)
        control:SetDrawTier(DT_HIGH)
        control:SetTexture("/" .. SCM.iconTexture)
        return control
    end

    -- Create control if doesn't exist
    if (not uncollectedControl) then
        uncollectedControl = CreateUncollectedControl(control)
    end

    -- Icon should remain hidden if specified in settings
    -- Also check the item itself
    if (not show or not SCM.ShouldShowIcon(itemLink)) then
        uncollectedControl:SetHidden(true)
        return
    end

    -----------------------------------------------------------------
    -- Check for grid to set the anchor and offset
    local anchorControl = WINDOW_MANAGER:GetControlByName(control:GetName() .. 'Name')
    if (control.isGrid or (control:GetWidth() - control:GetHeight() < 5)) then
        uncollectedControl:SetAnchor(LEFT, control, BOTTOMLEFT, offset, -SCM.savedOptions.iconSize/2)
    else
        local anchorControl = WINDOW_MANAGER:GetControlByName(control:GetName() .. 'Name')
        uncollectedControl:SetAnchor(LEFT, anchorControl, RIGHT, offset)
    end

    -- Show the icon
    uncollectedControl:SetDimensions(SCM.savedOptions.iconSize, SCM.savedOptions.iconSize)
    uncollectedControl:SetColor(unpack(SCM.savedOptions.iconColor))
    uncollectedControl:SetHidden(false)
end


---------------------------------------------------------------------
-- Set up hooks to display icons in bags, thanks TraitBuddy
local function SetupBagHooks()
    for _, inventory in pairs(SCM.inventories) do
        SecurePostHook(ZO_ScrollList_GetDataTypeTable(inventory.list, 1), "setupCallback", function(control, dataEntryData)
            local show = SCM.savedOptions.show[inventory.showKey]
            local itemLink = GetItemLink(control.dataEntry.data.bagId, control.dataEntry.data.slotIndex, LINK_STYLE_BRACKETS)
            AddUncollectedIndicator(control, control.dataEntry.data.bagId, control.dataEntry.data.slotIndex,
                itemLink, show, SCM.savedOptions.iconOffset)
        end)
    end
end

---------------------------------------------------------------------
-- Set up hooks to display icons in guild store, thanks Master Recipe List
local guildStoreHooked = false
local function OnStoreSearch()
    if (not guildStoreHooked) then
        ZO_PreHook(TRADING_HOUSE.searchResultsList.dataTypes[1], "setupCallback", function(...)
            local show = SCM.savedOptions.show.guildstore
            local control, data = ...
            if (control.slotControlType and control.slotControlType == 'listSlot' and data.slotIndex) then
                local itemLink = GetTradingHouseSearchResultItemLink(data.slotIndex, LINK_STYLE_BRACKETS)
                AddUncollectedIndicator(control, nil, nil, itemLink, show, SCM.savedOptions.iconStoreOffset)
            end
        end)
        ZO_PreHook(TRADING_HOUSE.postedItemsList.dataTypes[2], "setupCallback", function(...)
            local show = SCM.savedOptions.show.guildstore
            local control, data = ...
            if (control.slotControlType and control.slotControlType == 'listSlot' and data.slotIndex) then
                local itemLink = GetTradingHouseListingItemLink(data.slotIndex, LINK_STYLE_BRACKETS)
                AddUncollectedIndicator(control, nil, nil, itemLink, show, SCM.savedOptions.iconStoreOffset)
            end
        end)
        guildStoreHooked = true
    end

    -- Refresh immediately, because for some reason it doesn't show upon first opening
    -- If already hooked, it could have wrong offset
    ZO_ScrollList_RefreshVisible(ZO_TradingHouseBrowseItemsRightPaneSearchResults)
end

---------------------------------------------------------------------
-- Set up hooks to display icons in buyback tab, thanks Master Recipe List
local function HookBuyback()
    ZO_PreHook(ZO_BuyBackList.dataTypes[1], "setupCallback", function( ... )
        local control, data = ...
        if (control.slotControlType and control.slotControlType == 'listSlot' and data.slotIndex) then
            local itemLink = GetBuybackItemLink(data.slotIndex, LINK_STYLE_BRACKETS)
            local show = SCM.savedOptions.show.bag
            AddUncollectedIndicator(control, nil, nil, itemLink, show, SCM.savedOptions.iconOffset)
        end
    end)
end


---------------------------------------------------------------------
-- Listen for updates in the trade window and adjust icons accordingly
-- EVENT_TRADE_ITEM_ADDED (number eventCode, TradeParticipant who, number tradeIndex, ItemUISoundCategory itemSoundCategory)
-- EVENT_TRADE_ITEM_REMOVED (number eventCode, TradeParticipant who, number tradeIndex, ItemUISoundCategory itemSoundCategory)
-- EVENT_TRADE_ITEM_UPDATED (number eventCode, TradeParticipant who, number tradeIndex)
local function UpdateTradeIcon(eventCode, who, tradeIndex)
    local whoString = (who == TRADE_ME) and "My" or "Their"
    local control = WINDOW_MANAGER:GetControlByName(whoString .. "TradeWindowSlot" .. tostring(tradeIndex))
    -- Hide the icon too when an item is removed
    local show = SCM.savedOptions.show.trading and (eventCode ~= EVENT_TRADE_ITEM_REMOVED)
    AddUncollectedIndicator(control, nil, nil, GetTradeItemLink(who, tradeIndex), show, SCM.savedOptions.iconOffset)
end

-- Quick update of all trade slots to hide any leftover icons from previous trade
local function UpdateAllTradeIcons()
    UpdateTradeIcon(EVENT_TRADE_ITEM_ADDED, TRADE_ME, 1)
    UpdateTradeIcon(EVENT_TRADE_ITEM_ADDED, TRADE_ME, 2)
    UpdateTradeIcon(EVENT_TRADE_ITEM_ADDED, TRADE_ME, 3)
    UpdateTradeIcon(EVENT_TRADE_ITEM_ADDED, TRADE_ME, 4)
    UpdateTradeIcon(EVENT_TRADE_ITEM_ADDED, TRADE_ME, 5)
    UpdateTradeIcon(EVENT_TRADE_ITEM_ADDED, TRADE_THEM, 1)
    UpdateTradeIcon(EVENT_TRADE_ITEM_ADDED, TRADE_THEM, 2)
    UpdateTradeIcon(EVENT_TRADE_ITEM_ADDED, TRADE_THEM, 3)
    UpdateTradeIcon(EVENT_TRADE_ITEM_ADDED, TRADE_THEM, 4)
    UpdateTradeIcon(EVENT_TRADE_ITEM_ADDED, TRADE_THEM, 5)
end


---------------------------------------------------------------------
-- When the collection updates or settings change, we should refresh the view so the icons immediately update
function SCM.OnSetCollectionUpdated()
    ZO_ScrollList_RefreshVisible(ZO_PlayerInventoryList)
    ZO_ScrollList_RefreshVisible(ZO_PlayerBankBackpack)
    ZO_ScrollList_RefreshVisible(ZO_HouseBankBackpack)
    ZO_ScrollList_RefreshVisible(ZO_GuildBankBackpack)
    ZO_ScrollList_RefreshVisible(ZO_SmithingTopLevelDeconstructionPanelInventoryBackpack)
    ZO_ScrollList_RefreshVisible(ZO_SmithingTopLevelImprovementPanelInventoryBackpack)
end

---------------------------------------------------------------------
-- Initialize
local function Initialize()
    -- Settings and saved variables
    SCM.savedOptions = ZO_SavedVars:NewAccountWide("SetCollectionMarkerSavedVariables", 1, "Options", defaultOptions)

    EVENT_MANAGER:RegisterForEvent(SCM.name .. "CollectionUpdate", EVENT_ITEM_SET_COLLECTION_UPDATED, SCM.OnSetCollectionUpdated)
    EVENT_MANAGER:RegisterForEvent(SCM.name .. "StoreSearch", EVENT_TRADING_HOUSE_RESPONSE_RECEIVED, OnStoreSearch)

    -- Not sure why hooking ZO_BuyBackList with the other bags results in your worn items instead
    EVENT_MANAGER:RegisterForEvent(SCM.name .. "Buyback", EVENT_OPEN_STORE, HookBuyback, true) -- Hook only once

    -- Hook trading window
    EVENT_MANAGER:RegisterForEvent(SCM.name .. "TradeStarted", EVENT_TRADE_INVITE_ACCEPTED, UpdateAllTradeIcons)
    EVENT_MANAGER:RegisterForEvent(SCM.name .. "TradeAdded", EVENT_TRADE_ITEM_ADDED, UpdateTradeIcon)
    EVENT_MANAGER:RegisterForEvent(SCM.name .. "TradeRemoved", EVENT_TRADE_ITEM_REMOVED, UpdateTradeIcon)
    EVENT_MANAGER:RegisterForEvent(SCM.name .. "TradeUpdated", EVENT_TRADE_ITEM_UPDATED, UpdateTradeIcon)

    -- Inventories to show icons in, thanks TraitBuddy
    SCM.inventories = {
        bag = {
            list = ZO_PlayerInventoryList,
            showKey = "bag",
        },
        bank = {
            list = ZO_PlayerBankBackpack,
            showKey = "bank",
        },
        housebank = {
            list = ZO_HouseBankBackpack,
            showKey = "housebank",
        },
        guild = {
            list = ZO_GuildBankBackpack,
            showKey = "guild",
        },
        deconstruction = {
            list = ZO_SmithingTopLevelDeconstructionPanelInventoryBackpack,
            showKey = "crafting",
        },
        improvement = {
            list = ZO_SmithingTopLevelImprovementPanelInventoryBackpack,
            showKey = "crafting",
        },
        deconassistant = {
            list = ZO_UniversalDeconstructionTopLevel_KeyboardPanelInventoryBackpack,
            showKey = "crafting",
        },
        transmute = {
            list = ZO_RETRAIT_KEYBOARD.inventory.list,
            showKey = "transmute",
        },
    }

    SCM.iconTexture = "esoui/art/collections/collections_tabIcon_itemSets_down.dds"

    -- Update the icon string with the current style
    SCM.Chat.UpdateIconString()

    -- Create settings
    SCM.CreateSettingsMenu()

    SetupBagHooks()
    SCM.Whisper.Initialize()

    -- Keybind
    ZO_CreateStringId("SI_BINDING_NAME_SCM_ADDTOTRADE", "Add Requested to Trade")

    EVENT_MANAGER:RegisterForEvent(SCM.name .. "Activated", EVENT_PLAYER_ACTIVATED, SCM.Chat.OnPlayerActivated)
end


---------------------------------------------------------------------
-- On load
local function OnAddOnLoaded(_, addonName)
    if addonName == SCM.name then
        EVENT_MANAGER:UnregisterForEvent(SCM.name, EVENT_ADD_ON_LOADED)
        Initialize()
    end
end
 
EVENT_MANAGER:RegisterForEvent(SCM.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

