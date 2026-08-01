-- local libScroll = LibStub:GetLibrary("LibScroll")

----------
-- DATA --
----------

LootAlert = {
    name            = "LootAlert",           -- Matches folder and Manifest file names.
    -- version         = "1.0",                -- A nuisance to match to the Manifest.
    author          = "Thyreos",
    color           = "7FD47F", --"DDFFEE",             -- Used in menu titles and so on.
    menuName        = "|c7FD47FLoot|r|cF5F5F5Alert!|r",   -- Unique identifier for menu object.
    -- Default settings.
    savedVariables = {
        enabled = true,
        overrideAll = false,
        alwaysChat = false,
        showReason = true,
        doAudio = true,
        doEmote = true,
        doEmoteStealthed = false,
        doChatOutput = true,
        doAlert = true,
        doAnnounce = true,
        watchEverything = false,
        watchTraitBS = false,
        watchTraitCloth = false,
        watchTraitJC = false,
        watchTraitWW = false,
        watchIntricates = false,
        watchMaps = true,
        watchRecipes = true,
        watchQuality = true,
        watchQualityLevel = ITEM_QUALITY_ARTIFACT, -- epic, purple
        watchItemIds = true,
        watchedItemId = "enter an itemId",
        watchedItemIds = {}, -- itemId -> name
        watchTrophyFish = true,
        watchMonsterTrophies = true,
        watchQuestItems = true,
        watchLorebooks = true,
    },
    whitesmoke = "F5F5F5",
    cornflowerblue = "6495ED",
    dayskyblue = "82CAFF",

    qualityColor = {
        [SI_ITEMQUALITY1] = "FFFFFF", -- normal, white
        [SI_ITEMQUALITY2] = "8BC34A", -- common, green
        [SI_ITEMQUALITY3] = "039BE5", -- superior, blue
        [SI_ITEMQUALITY4] = "8E24AA", -- epic, purple
        [SI_ITEMQUALITY5] = "FDD835", -- legendary, gold
    },
--    flag = true,

--    counter = 1,
    windowVisible = false,
--    windowInitialized = false,

    watchlistWindow = nil,
    scrollList = nil,

    lastLoot = nil,
    lastLootTime = 0,
    lastAchievement = nil,
}

-----------------------------------
---- RIGHT-CLICK CONTEXT MENUS ----
-----------------------------------

-- credit for unravelling how to do context menus belongs to
-- Tamriel Trade Center, Master Merchant, FCO Item Saver, probably others

-- overwrite mouse handler to add chat link context menu
function LootAlert.OverWriteLinkMouseUpHandler()
    local base = ZO_LinkHandler_OnLinkMouseUp
    ZO_LinkHandler_OnLinkMouseUp = function(link, button, control)
        base(link, button, control)
        
        if (button ~= MOUSE_BUTTON_INDEX_RIGHT or GetLinkType(link) ~= LINK_TYPE_ITEM) then
            return
        end

        local itemId = LootAlert.GetItemIDFromLink(link)
        if (LootAlert.savedVariables.watchedItemIds[itemId] ~= nil) then
            AddCustomMenuItem(GetString(SI_LOOTALERT_CONTEXT_MENU_REMOVE), function()
                LootAlert.RemoveWatchedItemId(itemId)
            end)
        else
            AddCustomMenuItem(GetString(SI_LOOTALERT_CONTEXT_MENU_ADD), function()
                LootAlert.AddWatchedItemIdFromBag(itemId, link)
            end)
        end
        ShowMenu(control)
    end
end

-- add bags and store context menu
function LootAlert.AddContextMenuOption(rowControl)
    local itemLink = nil
    local slotType = ZO_InventorySlot_GetType(rowControl)
    
    if slotType == SLOT_TYPE_ITEM or slotType == SLOT_TYPE_EQUIPMENT or slotType == SLOT_TYPE_BANK_ITEM or slotType == SLOT_TYPE_GUILD_BANK_ITEM or 
       slotType == SLOT_TYPE_TRADING_HOUSE_POST_ITEM or slotType == SLOT_TYPE_REPAIR or slotType == SLOT_TYPE_CRAFTING_COMPONENT or 
       slotType == SLOT_TYPE_PENDING_CRAFTING_COMPONENT or slotType == SLOT_TYPE_CRAFT_BAG_ITEM then
            local bagId, slotIndex = ZO_Inventory_GetBagAndIndex(rowControl)
            itemLink = GetItemLink(bagId, slotIndex, LINK_STYLE_DEFAULT)
    end
  
    if slotType == SLOT_TYPE_TRADING_HOUSE_ITEM_RESULT then
        itemLink = GetTradingHouseSearchResultItemLink(ZO_Inventory_GetSlotIndex(rowControl))
    end
    if slotType == SLOT_TYPE_TRADING_HOUSE_ITEM_LISTING then
        itemLink = GetTradingHouseListingItemLink(ZO_Inventory_GetSlotIndex(rowControl), LINK_STYLE_DEFAULT)
    end
    
    if itemLink ~= nil then
        local itemId = LootAlert.GetItemIDFromLink(itemLink)
        if (LootAlert.savedVariables.watchedItemIds[itemId] ~= nil) then
            AddCustomMenuItem(GetString(SI_LOOTALERT_CONTEXT_MENU_REMOVE), function()
                LootAlert.RemoveWatchedItemId(itemId)
            end)
        else
            AddCustomMenuItem(GetString(SI_LOOTALERT_CONTEXT_MENU_ADD), function()
                LootAlert.AddWatchedItemIdFromBag(itemId, itemLink)
            end)
        end
        ShowMenu(self)
    end
end

-- set up hook to allow additions to game's context menus
local function AddContextMenuOptionSoon(rowControl)
    zo_callLater(function() LootAlert.AddContextMenuOption(rowControl) end, 0)
end
ZO_PreHook("ZO_InventorySlot_ShowContextMenu", AddContextMenuOptionSoon)

-----------------------------
-- WATCHLIST SCROLL WINDOW --
-----------------------------

local libScroll = LibStub:GetLibrary("LibScroll")
 
local function GetScrollData()
    local dataItems = {}
    
    for k, v in pairs(LootAlert.savedVariables.watchedItemIds) do 
        local data = {
            itemLink = v,
            itemId = k,
            itemName = GetItemLinkName(itemId),
        }

        table.insert(dataItems, data)
    end
    return dataItems
end
 
-- This function creates a top level window to hold our scrollList
local function CreateMainWindow()
    -- Create a top level window:
    local tlw = WINDOW_MANAGER:CreateTopLevelWindow("TestScrollList")
    tlw:SetAnchor(CENTER, GuiRoot, CENTER)
    tlw:SetDimensions(450, 300)
    tlw:SetMovable(true)
    tlw:SetMouseEnabled(true)
    tlw:SetHidden(true)
    
    -- create a background for it (optional)
    tlw.bg = WINDOW_MANAGER:CreateControlFromVirtual("TestScrollListBg", tlw, "ZO_DefaultBackdrop")
    tlw.bg:SetAnchorFill()
    
    -- title
    local title = WINDOW_MANAGER:CreateControl("TestScrollListTitle", tlw, CT_LABEL)
    title:SetAnchor(TOPLEFT, tlw, TOPLEFT, 12, 10)
    title:SetFont("ZoFontHeader4")
    title:SetText("|c7FD47FLOOT|rALERT! Watchlist")    

    -- Subtitle
    local title = WINDOW_MANAGER:CreateControl("TestScrollListSubtitle", tlw, CT_LABEL)
    title:SetAnchor(TOPLEFT, tlw, TOPLEFT, 26, 35)
    title:SetFont("ZoFontHeader2")
    title:SetText("|cF5F5F5right-click|r |cB12525remove|r")    

    -- close
    local closeButton = WINDOW_MANAGER:GetControlByName("ZO_Loot_Control1", "")
    if (closeButton ~= nil) then return end
    local btn = WINDOW_MANAGER:CreateControlFromVirtual("TestScrollListCloseBtn", tlw, "ZO_DefaultTextButton")
    btn:SetAnchor(TOPRIGHT, tlw, TOPRIGHT, -14, 10)
    btn:SetNormalTexture("esoui/art/buttons/decline_up.dds")
    btn:SetMouseOverTexture("esoui/art/buttons/decline_over.dds")
    btn:SetPressedTexture("esoui/art/buttons/decline_down.dds")
    btn:SetWidth(24)
    btn:SetHandler("OnClicked" , function() LootAlert.ToggleWindow(); end)

    return tlw
end
 
-- Create the row selection function (if needed)
local function OnRowSelect(previouslySelectedData, selectedData, reselectingDuringRebuild)
    if not selectedData then return end
end
 
-- Create the sort function (if needed)
local function SortScrollList(objA, objB)
    return GetItemLinkName(objA.data.itemLink) < GetItemLinkName(objB.data.itemLink)
end
    
-- Create the row setup callback function
local function SetupDataRow(rowControl, data, scrollList)
    local icon, sellPrice, canUse, equipType, itemStyleId = GetItemLinkInfo(data.itemLink)
    local smIconText = zo_iconTextFormat(icon, 24, 24, " ")
    rowControl:SetText(smIconText.." "..data.itemLink)
    rowControl:SetFont("ZoFontWinH4")

    rowControl:SetHandler("OnMouseUp", function(self, button, upInside)
        if upInside then
            if button == 2 then -- right-click, left-click is 1
                LootAlert.RemoveWatchedItemId(data.itemId)
            end 
        end
    end)
end
 
-- Function that creates the scrollList 
local function CreateScrollList()
    -- Creates the top level window to hold our scrollList
    local mainWindow = CreateMainWindow()
    LootAlert.watchlistWindow = mainWindow
    
    -- Create the scrollData table for your scrollList
    local scrollData = {
        name = "EmoteScrollListTest",
        parent = mainWindow,
        
        width = 400,
        height = 200,
        rowHeight = 23,
        
        setupCallback = SetupDataRow,
        selectCallback  = OnRowSelect,
        dataTypeSelectSound = SOUNDS.INVENTORY_ITEM_JUNKED,
        sortFunction    = SortScrollList,
    }
    
    -- Call the libraries CreateScrollList
    local scrollList = libScroll:CreateScrollList(scrollData)
    -- Anchor it however you want
    scrollList:SetAnchor(TOPLEFT, mainWindow, TOPLEFT, 25, 75)
    
    return scrollList
end
 
local function InitializeScrollList()
    -- Create the scrollList
    LootAlert.scrollList = CreateScrollList()
    
    -- Get your data from wherever & update the scrollList
    local scrollData = GetScrollData()
    LootAlert.scrollList:Update(scrollData)
end
 
 
-----------------------
-- HELPERS FUNCTIONS --
-----------------------

function LootAlert.AddWatchedItemIdFromBag(itemId, itemLink)
    d(LootAlert.menuName..LootAlert.Colorize(" Now watching for "..itemLink.."!"))
    LootAlert.savedVariables.watchedItemIds[itemId] = itemLink
    LootAlert.scrollList:Update(GetScrollData())    
end    

function LootAlert.ToggleWindow()
    if LootAlert.windowVisible then 
        --LootAlertWindow:SetHidden(true) 
        LootAlert.watchlistWindow:SetHidden(true)
    else 
        --LootAlert.ShowWindow()
        LootAlert.watchlistWindow:SetHidden(false)
    end
    LootAlert.windowVisible = not LootAlert.windowVisible
end

-- from http://wiki.esoui.com/GetItemLinkFromItemId
function LootAlert.getItemLinkFromItemId(itemId) 
    local name = GetItemLinkName(ZO_LinkHandler_CreateLink("Test Trash", nil, ITEM_LINK_TYPE,itemId, 0, 26, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 10000, 0))
    if name == nil or name == '' then return nil end
    local link =ZO_LinkHandler_CreateLinkWithoutBrackets(zo_strformat("<<t:1>>",name), nil, ITEM_LINK_TYPE,itemId, 0, 26, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 10000, 0)
    local itemLink = string.match(link,"|H0:item:%d+:%d:%d%d:%d:%d:%d:%d:%d:%d:%d:%d:%d:%d:%d:%d:%d:%d:%d:%d:%d+:%d").."|h|h"
    return itemLink, name
end

-- from http://wiki.esoui.com/GetItemId
function LootAlert.GetItemIDFromLink(itemLink)    
    return tonumber((tostring(itemLink):match("|H%d:item:(%d+)") or -1))
end

function LootAlert.RemoveWatchedItemId(itemId)
    local itemLink = LootAlert.savedVariables.watchedItemIds[itemId]
    d(LootAlert.menuName..LootAlert.Colorize(" Stopped watching for "..itemLink))

    local newWatchlist = {} 
    for k, v in pairs(LootAlert.savedVariables.watchedItemIds) do
        if k ~= itemId then
            newWatchlist[k] = v
        end
    end
    LootAlert.savedVariables.watchedItemIds = newWatchlist
    LootAlert.scrollList:Update(GetScrollData())
end

function LootAlert.AddWatchedItemId(text)
    local itemId = tonumber(text)
    if itemId == nil or itemId == '' then
        LootAlert.savedVariables.watchedItemId = "invalid itemId"
        menuEnterItemId:UpdateValue()
        LootAlert.savedVariables.watchedItemId = "enter an itemId"
        return
    end

    local itemLink, name = LootAlert.getItemLinkFromItemId(itemId)
    if itemLink == nil then 
        LootAlert.savedVariables.watchedItemId = "invalid itemId"
        menuEnterItemId:UpdateValue()
        LootAlert.savedVariables.watchedItemId = "enter an itemId"
        return
    end

    if LootAlert.savedVariables.watchedItemIds[itemId] ~= nil then
        LootAlert.savedVariables.watchedItemId = "already watching for "..itemLink
        menuEnterItemId:UpdateValue()
        LootAlert.savedVariables.watchedItemId = "enter an itemId"
        return
    end

    LootAlert.savedVariables.watchedItemId = itemLink.." added!"
    menuEnterItemId:UpdateValue()
    LootAlert.savedVariables.watchedItemId = "enter an itemId"

    d(LootAlert.menuName..LootAlert.Colorize(" Now watching for "..itemLink.."!"))
    LootAlert.savedVariables.watchedItemIds[itemId] = itemLink -- some names are garbled

    LootAlert.scrollList:Update(GetScrollData())    
end

-- Wraps text with a color.
function LootAlert.Colorize(text, color)
    -- Default to addon's .color.
    if not color then color = LootAlert.color end
    text = "|c" .. color .. text .. "|r"
    return text
end

function LootAlert.Decolorize(text)
    local result = string.sub(text, 9, -3)
    return result
end

function LootAlert.GetColoredQualityString(itemQuality) -- e.g. ITEM_QUALITY_LEGENDARY
    local descriptor = GetString("SI_ITEMQUALITY", itemQuality)
    local color = GetItemQualityColor(itemQuality)
    local coloredDescriptor = color:Colorize(descriptor)
    --control.label:SetColor(ZO_DEFAULT_ENABLED_COLOR:UnpackRGBA())
    return coloredDescriptor
end

function LootAlert.ToggleEnable()
    if LootAlert.savedVariables.enabled then 
        LootAlert.Disable()
    else
        LootAlert.Enable()
    end
end

function LootAlert.ToggleOverrideAll()
    LootAlert.SetOverrideAllOnOff(not LootAlert.savedVariables.overrideAll)
end

function LootAlert.SetOverrideAllOnOff(value)
    LootAlert.savedVariables.overrideAll = value
    LootAlert.UpdateAllMenuControls()
    local text = ""
    if value then
        text = GetString(SI_LOOTALERT_OVERRIDE_ON)
    else
        text = GetString(SI_LOOTALERT_OVERRIDE_OFF)
    end
    local text = LootAlert.menuName.." "..LootAlert.Colorize(text)
    LootAlert.Notify(text)
end

function LootAlert.Enable()
    LootAlert.savedVariables.enabled = true
    LootAlert.UpdateAllMenuControls()
    EVENT_MANAGER:RegisterForEvent(LootAlert.name, EVENT_LOOT_RECEIVED, LootAlert.OnLootReceived)
    --EVENT_MANAGER:RegisterForEvent(LootAlert.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, LootAlert.OnInventoryUpdated)
    EVENT_MANAGER:RegisterForEvent(LootAlert.name, EVENT_LORE_BOOK_LEARNED, LootAlert.OnLoreBookLearned)
    local text = LootAlert.menuName.." "..LootAlert.Colorize(GetString(SI_LOOTALERT_ENABLED))
    LootAlert.Notify(text)
end

function LootAlert.Disable()
    LootAlert.savedVariables.enabled = false
    LootAlert.UpdateAllMenuControls()
    EVENT_MANAGER:UnregisterForEvent(LootAlert.name, EVENT_LOOT_RECEIVED) 
    --EVENT_MANAGER:UnregisterForEvent(LootAlert.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE) 
    EVENT_MANAGER:UnregisterForEvent(LootAlert.name, EVENT_LORE_BOOK_LEARNED)
    local text = LootAlert.menuName.." "..LootAlert.Colorize(GetString(SI_LOOTALERT_DISABLED))
    LootAlert.Notify(text)
end

function LootAlert.SetAudioOnOff(value)
    LootAlert.savedVariables.doAudio = value
    LootAlert.NotifyByAudio()
end

function LootAlert.SetEmoteOnOff(value)
    LootAlert.savedVariables.doEmote = value
    LootAlert.NotifyByEmote()
end

function LootAlert.SetEmoteStealthedOnOff(value)
    LootAlert.savedVariables.doEmoteStealthed = value
    if value and (GetUnitStealthState("player") ~= STEALTH_STATE_NONE) then 
        LootAlert.NotifyByEmote()
    end
end

function LootAlert.SetAlertsOnOff(value)
    LootAlert.savedVariables.doAlert = value
    local verb = ""
    if value then
        verb = GetString(SI_LOOTALERT_ENABLED)
    else
        verb = GetString(SI_LOOTALERT_DISABLED)
    end
    local text = LootAlert.menuName.." "..LootAlert.Colorize(GetString(SI_LOOTALERT_ALERTS).." "..verb)
    LootAlert.NotifyByAlert(text)
end

function LootAlert.SetAnnouncementsOnOff(value)
    LootAlert.savedVariables.doAnnounce = value
    local verb = ""
    if value then
        verb = GetString(SI_LOOTALERT_ENABLED)
    else
        verb = GetString(SI_LOOTALERT_DISABLED)
    end
    local text = LootAlert.menuName.." "..LootAlert.Colorize(GetString(SI_LOOTALERT_ANNOUNCEMENTS).." "..verb)
    LootAlert.NotifyByAnnouncement(text)
end

function LootAlert.SetChatOnOff(value)
    LootAlert.savedVariables.doChatOutput = value
    local verb = ""
    if value then
        verb = GetString(SI_LOOTALERT_ENABLED)
    else
        verb = GetString(SI_LOOTALERT_DISABLED)
    end
    local text = LootAlert.menuName.." "..LootAlert.Colorize(GetString(SI_LOOTALERT_CHAT).." "..verb)
    LootAlert.NotifyByChat(text)
end

function LootAlert.UpdateAllMenuControls()
    -- only need to do this for actions that happen outside of the menu system
    -- e.g. hotkeys that toggle a setting that is also toggleable in the menu

    -- update values
    -- only need to update the menu values for things that can be changed outside the menu system
    -- e.g. via the enable hotkey
    menuAddonEnabled:UpdateValue()
    menuCarpeDiem:UpdateValue()

    -- disabled state
    -- everything menu item that should get disabled by something like the enabled hotkey
    -- needs to have it's UpdateDisabled() called
    -- so, basically, every menu control
    menuCarpeDiem:UpdateDisabled()
    menuAlwaysChat:UpdateDisabled()
    menuNotifyAudio:UpdateDisabled()
    menuNotifyEmote:UpdateDisabled()
    menuNotifyEmoteStealted:UpdateDisabled()
    menuNotifyAlerts:UpdateDisabled()
    menuNotifyAnnouncements:UpdateDisabled()
    menuNotifyChat:UpdateDisabled()
    menuWatchEverything:UpdateDisabled()
    menuWatchIntricate:UpdateDisabled()
    menuWatchMaps:UpdateDisabled()
    menuWatchRecipes:UpdateDisabled()
    menuWatchTraitBS:UpdateDisabled()
    menuWatchTraitCloth:UpdateDisabled()
    menuWatchTraitJC:UpdateDisabled()
    menuWatchTraitWW:UpdateDisabled()
    menuWatchQuality:UpdateDisabled()
    menuWatchQualityLevel:UpdateDisabled()
    menuWatchItemIds:UpdateDisabled()
    menuRemoveItemId:UpdateDisabled()
    menuEnterItemId:UpdateDisabled()
    menuWatchTrophyFish:UpdateDisabled()
    menuWatchMonsterTrophies:UpdateDisabled()
    menuWatchQuestItems:UpdateDisabled()
    menuWatchLorebooks:UpdateDisabled()
    menuShowReason:UpdateDisabled()
end

-- notify all channels with same text message as settings permit
-- let the specialized functions handle whether they should or shouldn't fire
function LootAlert.Notify(text)
    LootAlert.NotifyByAnnouncement(text)
    LootAlert.NotifyByAlert(text)
    LootAlert.NotifyByChat(text)
    LootAlert.NotifyByEmote()
    LootAlert.NotifyByAudio()
end

--Returns: number TradeskillType tradeskillType
function LootAlert.GetTradeskillType(itemLink)
    -- doesn't appear to be a data driven way to find what tradeskill a piece of gear belongs to
    -- e.g. only raw materials and boosters return a crafting type
    -- or alkahest returns alchemy, etc. - but no way to find what something deconstructs as
    -- commence sleuthing

    local skillType = CRAFTING_TYPE_INVALID
    local traitType, traitDescription = GetItemLinkTraitInfo(itemLink)
    local traitCategory = GetItemTraitTypeCategory(traitType)

    -- since we only care about things with traits (for now) we can cheat a little
    -- if we care about non-traited things one day, we'll have to resort to equip slots or something
    if traitCategory == ITEM_TRAIT_TYPE_CATEGORY_JEWELRY then
        skillType = CRAFTING_TYPE_JEWELRYCRAFTING
    end

    if traitCategory == ITEM_TRAIT_TYPE_CATEGORY_ARMOR then
        local armorType = GetItemLinkArmorType(itemLink)
        if armorType == ARMORTYPE_LIGHT or armorType == ARMORTYPE_MEDIUM then
            skillType = CRAFTING_TYPE_CLOTHIER
        end
        if armorType == ARMORTYPE_HEAVY then
            skillType = CRAFTING_TYPE_BLACKSMITHING
        end
    end

    local soundCategory = GetItemSoundCategoryFromLink(itemLink)
    if soundCategory == ITEM_SOUND_CATEGORY_SHIELD or soundCategory == ITEM_SOUND_CATEGORY_STAFF or soundCategory == ITEM_SOUND_CATEGORY_BOW then
        skillType = CRAFTING_TYPE_WOODWORKING
    end

    -- all that's left are metal weapons
    -- until ZOS adds whips made by clothiers or something...
    if traitCategory == ITEM_TRAIT_TYPE_CATEGORY_WEAPON and skillType ~= CRAFTING_TYPE_WOODWORKING then
        skillType = CRAFTING_TYPE_BLACKSMITHING
    end

    return skillType
end

-------------------------------------
-- LOOT ALERT LOGIC AND PROCESSING --
-------------------------------------

-- construct texts and call specialized notify functions
-- let the specialized functions handle whether they should or shouldn't fire
function LootAlert.GotLoot(itemLink, quantity, itemId, lootType) --, questItemIcon)
    local now = GetGameTimeMilliseconds()

    local icon, sellPrice, canUse, equipType, itemStyleId = GetItemLinkInfo(itemLink)

    -- credit to Ayantir for figuring out how to get quest item icons in LootDrop
    -- the problem is that itemLinks for quest items are/can be just names instead
    -- trying to get the link from the id didn't work either
    -----------------------------------------------------------------------------
    if lootType == LOOT_TYPE_QUEST_ITEM then
        -- searching for item in questCache to get its icon
        for journalIndex, questData in pairs(SHARED_INVENTORY.questCache) do
            for itemIndex, itemData in pairs (questData) do
                if itemData.name == zo_strformat(SI_TOOLTIP_ITEM_NAME, itemLink) then
                    icon = itemData.iconFile
                    break
                end
            end
        end    
        if ( (not icon) or (icon == '') or (icon == [[/esoui/art/icons/icon_missing.dds]])) then
            icon = [[/esoui/art/inventory/inventory_tabicon_quest_down.dds]]
        end    
    end
    ------------------------------------------------------------------------------

    local smIconText = zo_iconTextFormat(icon, 24, 24, " ")
    local mdIconText = zo_iconTextFormat(icon, 32, 32, " ")
    local lgIconText = zo_iconTextFormat(icon, 48, 48, " ")
    local bagCount, bankCount, craftBagCount = GetItemLinkStacks(itemLink)
    local totalCount = bagCount + bankCount + craftBagCount

    local traitTxt = ''
    local itemTrait = GetItemLinkTraitInfo(itemLink)
    if itemTrait ~= ITEM_TRAIT_TYPE_NONE then
        local itemTraitString = GetString("SI_ITEMTRAITTYPE", itemTrait)
        traitTxt = LootAlert.Colorize(itemTraitString, LootAlert.dayskyblue)
    end

    local header = LootAlert.menuName
    local amountTxt = ''
    local totalTxt = ''
    if IsItemLinkStackable(itemLink) then
        if quantity > 1 then amountTxt = LootAlert.Colorize(quantity.."x", LootAlert.whitesmoke) end
        if totalCount > 1 then totalTxt = LootAlert.Colorize("("..totalCount..")") end
    end

    -- now that we know evertyhng about this loot, do we care?
    local notifyUser = false
    local notifyReason = ""
    local showTrait = false

    -- OVERRIDES
    if LootAlert.savedVariables.overrideAll then
        notifyUser = true
        notifyReason = ""
    end
    if LootAlert.savedVariables.watchEverything then
        notifyUser = true
        notifyReason = ""
    end

    -- strategy:
    -- go from least specific to most
    -- let notify reason get overwriten by most interesting reason

    -- QUEST items (perhaps should go further down the list, but this entails quest rewards as well...i think)
    if LootAlert.savedVariables.watchQuestItems and lootType == LOOT_TYPE_QUEST_ITEM then
        notifyUser = true
        notifyReason = "Quest Item!"
    end

    -- QUALITY
    if LootAlert.savedVariables.watchQuality then
        local quality = GetItemLinkQuality(itemLink)
        if quality >= LootAlert.savedVariables.watchQualityLevel then
            notifyUser = true
            notifyReason = LootAlert.GetColoredQualityString(quality).." Quality!"
        end
    end

    -- INTRICATES
    local itemTraitInfo = GetItemTraitInformationFromItemLink(itemLink)
    if LootAlert.savedVariables.watchIntricates then
        if itemTraitInfo == ITEM_TRAIT_INFORMATION_INTRICATE then
            notifyUser = true
            notifyReason = zo_strformat("<<1>> Item!", LootAlert.Colorize("Intricate!",LootAlert.dayskyblue))
            showTrait = true
        end
    end

    -- RESEARCHABLE TRAITS
    local skillType = LootAlert.GetTradeskillType(itemLink)
    if itemTraitInfo == ITEM_TRAIT_INFORMATION_CAN_BE_RESEARCHED then
        if  (LootAlert.savedVariables.watchTraitBS and skillType == CRAFTING_TYPE_BLACKSMITHING) or
            (LootAlert.savedVariables.watchTraitWW and skillType == CRAFTING_TYPE_WOODWORKING) or
            (LootAlert.savedVariables.watchTraitJC and skillType == CRAFTING_TYPE_JEWELRYCRAFTING) or
            (LootAlert.savedVariables.watchTraitCloth and skillType == CRAFTING_TYPE_CLOTHIER) then
            notifyUser = true
            notifyReason = "Researchable Trait!"
            showTrait = true
        end
    end

    -- RECIPES
    local itemType, itemSpecialType = GetItemLinkItemType(itemLink)
    if LootAlert.savedVariables.watchRecipes and itemType == ITEMTYPE_RECIPE then 
        if not IsItemLinkRecipeKnown(itemLink) then
            notifyUser = true
            notifyReason = "Unknown Recipe!"
        end
    end

    -- TREASURE MAPS
    if LootAlert.savedVariables.watchMaps then
        if itemSpecialType == SPECIALIZED_ITEMTYPE_TROPHY_SURVEY_REPORT then
            notifyUser = true
            notifyReason = "Survey Report!"
        end
        if itemSpecialType == SPECIALIZED_ITEMTYPE_TROPHY_TREASURE_MAP then
            notifyUser = true
            notifyReason = "Treasure Map!"
        end
    end

    -- TROPHY FISH
    if LootAlert.savedVariables.watchTrophyFish and LootAlert.IsTrophyFish(itemLink) then
        if LootAlert.lastAchievement == nil then
            LootAlert.lastLoot = itemLink
            LootAlert.lastLootTime = now
        else
            LootAlert.lastAchievement = nil
            notifyUser = true
            notifyReason = "New Trophy Fish!"
        end
    end

    -- MONSTER TROPHY
    if LootAlert.savedVariables.watchMonsterTrophies and LootAlert.IsMonsterTrophy(itemLink) then
        if LootAlert.lastAchievement == nil then
            LootAlert.lastLoot = itemLink
            LootAlert.lastLootTime = now
        else
            LootAlert.lastAchievement = nil
            notifyUser = true
            notifyReason = "New Monster Trophy!"
        end
    end

    -- WATCHED ITEMS (by Id)
    if LootAlert.savedVariables.watchItemIds then
        if LootAlert.savedVariables.watchedItemIds[itemId] ~= nil then
            notifyUser = true
            notifyReason = "Watchlist Item!"
        end
    end

    -- construct text messages
    if not showTrait then traitTxt = "" end
    if not LootAlert.savedVariables.showReason then notifyReason = "" end

    local alertText = zo_strformat("<<1>><<2>> <<3>> <<4>>! <<5>>", amountTxt, mdIconText, traitTxt, itemLink, totalTxt)
    local announceText = zo_strformat("<<1>><<2>> <<3>> <<4>>! <<5>>", amountTxt, lgIconText, traitTxt, itemLink, totalTxt)
    local chatText = zo_strformat("<<1>><<2>> <<3>> <<4>> <<5>>", amountTxt, smIconText, traitTxt, itemLink, totalTxt)

    local alertText = zo_strformat("<<1>> <<2>>", notifyReason, alertText)
    local announceText = zo_strformat("<<1>> <<2>>", announceText, notifyReason)
    local chatText = zo_strformat("<<1>> <<2>> <<3>>", header, notifyReason, chatText)

    -- if we ALWAYS CHAT
    if not notifyUser then 
        if LootAlert.savedVariables.alwaysChat then
            LootAlert.NotifyByChat(chatText)
        end
        return
    end

    LootAlert.NotifyByEmote()
    LootAlert.NotifyByAudio()
    LootAlert.NotifyByAnnouncement(announceText)
    LootAlert.NotifyByAlert(alertText)
    LootAlert.NotifyByChat(chatText)
end

-- play an AUDIO notification if settings permit
function LootAlert.NotifyByAudio()
    if not LootAlert.savedVariables.enabled then return end

    if LootAlert.savedVariables.overrideAll or LootAlert.savedVariables.doAudio then
        PlaySound(SOUNDS.BOOK_ACQUIRED)
    end
end

-- play a cheerful EMOTE if settings permit
function LootAlert.NotifyByEmote()
    if not LootAlert.savedVariables.enabled then return end

    local emote = false
    if LootAlert.savedVariables.overrideAll then
        emote = true
    else
        if LootAlert.savedVariables.doEmote then
            if LootAlert.savedVariables.doEmoteStealthed or (GetUnitStealthState("player") == STEALTH_STATE_NONE) then
                emote = true
            end
        end
    end

    if emote then SLASH_COMMANDS["/cheer"]() end
end

-- ALERT: trigger a top-right notification if settings permit
function LootAlert.NotifyByAlert(alertText)
    if LootAlert.savedVariables.overrideAll or LootAlert.savedVariables.doAlert then
        ZO_AlertNoSuppression(UI_ALERT_CATEGORY_ALERT, nil, alertText)
    end
end

-- ANNOUNCE: trigger a center screen announcement if settings permit
function LootAlert.NotifyByAnnouncement(announceText)
    if LootAlert.savedVariables.overrideAll or LootAlert.savedVariables.doAnnounce then
        local params = nil
        --params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_MAJOR_TEXT)
        --params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT)
        params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT)
        --params:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_ACHIEVEMENT_AWARDED)
        params:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_QUEST_ADDED)
        params:SetText(announceText)
        CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
    end
end

-- CHAT: send output to chat if settings permit
function LootAlert.NotifyByChat(chatText)
    if LootAlert.savedVariables.overrideAll or LootAlert.savedVariables.alwaysChat or LootAlert.savedVariables.doChatOutput then
        d(chatText)
    end
end

--------------------
-- EVENT HANDLERS --
--------------------

--function LootAlert.OnLootReceived(e, lootedBy, itemLink, quantity, itemSound, lootType, isStolen)
function LootAlert.OnLootReceived(eventCode, receivedBy, itemLink, quantity, itemSound, lootType, self, isPickpocketLoot, questItemIcon, itemId, isStolen)
    if not LootAlert.savedVariables.enabled then return end

    -- only worry about the player's own loot (for now)
    if not self then return end

    LootAlert.GotLoot(itemLink, quantity, itemId, lootType)
end

--[[function LootAlert.OnInventoryUpdated(e, bagId, slotIndex, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange)
    if not LootAlert.savedVariables.enabled then return end
    if bagId ~= BAG_BACKPACK then return end
    if not isNewItem then return end

    local filterId = GetItemFilterTypeInfo(bagId, slotIndex)
    local descriptor = GetString("SI_ITEMFILTERTYPE", filterId)

    local itemLink = GetItemLink(bagId, slotIndex, LINK_STYLE_DEFAULT)
end]]

function LootAlert.OnLoreBookLearned(eventCode, categoryIndex, collectionIndex, bookIndex, guildIndex, isMaxRank)
    if not LootAlert.savedVariables.enabled then return end

    local categoryName, numCollections, categoryId = GetLoreCategoryInfo(categoryIndex)
    local collectionName, collectionDescription, numKnownBooks, totalBooks, hidden, gamepadIcon, collectionId = GetLoreCollectionInfo(categoryIndex, collectionIndex)
    local bookTitle, bookIcon, bookKnown, bookId = GetLoreBookInfo(categoryIndex, collectionIndex, bookIndex)

    -- TODO: code duplication of logic and code from GotLoot - refactor
    --------------------------------------------------
    local notifyUser = false
    if LootAlert.savedVariables.watchLorebooks or LootAlert.savedVariables.overrideAll then
        notifyUser = true;
    end

    -- announcement will have 2 or 4 parts
    -- notify reason, book icon and title
    -- and if part of a colelction: collection icon and title, number of known/unknown in the collection
    local notifyReason = "New Book!"

    local smIconBookText = zo_strformat("<<1>> <<2>>", zo_iconTextFormat(bookIcon, 24, 24, " "), bookTitle)
    local mdIconBookText = zo_strformat("<<1>> <<2>>", zo_iconTextFormat(bookIcon, 32, 32, " "), bookTitle)
    local lgIconBookText = zo_strformat("<<1>> <<2>>", zo_iconTextFormat(bookIcon, 48, 48, " "), bookTitle)

    -- collection icon options
    -- white lorebook icon: art/treeicons/gamepad/gp_lorelibrary_categoryicon_literature.dds
    -- bronze book stack: art/tutorial/journal_tabicon_lorelibrary_up.dds
    -- white stacks: art/tutorial/gamepad/gp_playermenu_icon_lorelibrary.dds
    -- stack white backglow esoui/art/journal/journal_tabicon_lorelibrary_down.dds
    local quantitiesTxt = ""
    if totalBooks ~= nill and totalBooks > 0 then
        quantitiesTxt = LootAlert.Colorize(zo_strformat("(<<1>>/<<2>>)", numKnownBooks, totalBooks))
    end
    collectionIcon = "esoui/art/journal/journal_tabicon_lorelibrary_down.dds"

    if not LootAlert.savedVariables.showReason then notifyReason = "" end
    local smCollectionTxt = zo_strformat("<<1>> <<2>> <<3>>", zo_iconTextFormat(collectionIcon, 24, 24, " "), collectionName, quantitiesTxt)
    local mdCollectionTxt = zo_strformat("<<1>> <<2>> <<3>>", zo_iconTextFormat(collectionIcon, 32, 32, " "), collectionName, quantitiesTxt)
    local lgCollectionTxt = zo_strformat("<<1>> <<2>> <<3>>", zo_iconTextFormat(collectionIcon, 48, 48, " "), collectionName, quantitiesTxt)

    local header = LootAlert.menuName
    local alertText = zo_strformat("<<1>> <<2>> <<3>>", notifyReason, mdIconBookText, mdCollectionTxt)
    local announceText = zo_strformat("<<1>> <<2>> <<3>>", lgIconBookText, lgCollectionTxt, notifyReason)
    local chatText = zo_strformat("<<1>> <<2>> <<3>> <<4>>", header, notifyReason, smIconBookText, smCollectionTxt)

    if not notifyUser then 
        if LootAlert.savedVariables.alwaysChat then
            LootAlert.NotifyByChat(chatText)
        end
        return
    end

    LootAlert.NotifyByEmote()
    LootAlert.NotifyByAudio()
    LootAlert.NotifyByAnnouncement(announceText)
    LootAlert.NotifyByAlert(alertText)
    LootAlert.NotifyByChat(chatText)
    ---------------------------------------------------
end

function LootAlert.IsTrophyFish(itemLink)
    local itemType, itemSpecialType = GetItemLinkItemType(itemLink)
    local isTrophyFIsh = false
    if itemType == ITEMTYPE_COLLECTIBLE and itemSpecialType == SPECIALIZED_ITEMTYPE_COLLECTIBLE_RARE_FISH then
        isTrophyFIsh = true
    end
    return isTrophyFIsh
end

function LootAlert.IsMonsterTrophy(itemLink)
    local itemType, itemSpecialType = GetItemLinkItemType(itemLink)
    local isMonsterTrophy = false
    if itemType == ITEMTYPE_COLLECTIBLE and itemSpecialType == SPECIALIZED_ITEMTYPE_COLLECTIBLE_MONSTER_TROPHY then
        isMonsterTrophy = true
    end
    return isMonsterTrophy
end

function LootAlert.OnAchievementUpdated(e, id)
    local now = GetGameTimeMilliseconds()
    local tlIndex, categoryIndex, achievementIndex, offsetFromParent = GetCategoryInfoFromAchievementId(id)
    if  (tlIndex == 6 and categoryIndex == 8) or     -- exploration, fishing -> trophy fish
        (tlIndex == 1 and categoryIndex == 5) then   -- character, trophies  -> monster trophies
        LootAlert.lastAchievement = id
        if LootAlert.lastLoot == nil then 
            return
        end

        if LootAlert.IsTrophyFish(LootAlert.lastLoot) or LootAlert.IsMonsterTrophy(LootAlert.lastLoot) then
            -- check how old this loot is
            if now - LootAlert.lastLootTime < 3000 then -- plenty of time. these events should happen back to back
                LootAlert.GotLoot(LootAlert.lastLoot)
                LootAlert.lastLoot = nil
                LootAlert.lastLootTime = 0
            end
        end
    end
end
EVENT_MANAGER:RegisterForEvent(LootAlert.name, EVENT_ACHIEVEMENT_UPDATED, LootAlert.OnAchievementUpdated)

function LootAlert.OnAddOnLoaded(event, addonName)
    if addonName ~= LootAlert.name then return end
    EVENT_MANAGER:UnregisterForEvent(LootAlert.name, EVENT_ADD_ON_LOADED)

    LootAlert.savedVariables = ZO_SavedVars:New("LootAlertSavedVariables", 1, nil, LootAlert.savedVariables)
    
    -- Settings menu in Settings.lua.
    LootAlert.LoadSettings()
    LootAlert.OverWriteLinkMouseUpHandler()
    InitializeScrollList()
 
    -- Slash commands must be lowercase. Set to nil to disable.
    --SLASH_COMMANDS["/lootalert"] = LootAlert.AnimateText()
    -- Reset autocomplete cache to update it.
    SLASH_COMMAND_AUTO_COMPLETE:InvalidateSlashCommandCache()

    if LootAlert.savedVariables.enabled then
        EVENT_MANAGER:RegisterForEvent(LootAlert.name, EVENT_LOOT_RECEIVED, LootAlert.OnLootReceived)
        --EVENT_MANAGER:RegisterForEvent(LootAlert.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, LootAlert.OnInventoryUpdated)
        EVENT_MANAGER:RegisterForEvent(LootAlert.name, EVENT_LORE_BOOK_LEARNED, LootAlert.OnLoreBookLearned)
    end
end
-- When any addon is loaded, but before UI (Chat) is loaded.
EVENT_MANAGER:RegisterForEvent(LootAlert.name, EVENT_ADD_ON_LOADED, LootAlert.OnAddOnLoaded)
