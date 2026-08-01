QCB = {}
QCB.ename = 'QCB'
QCB.ename2 = 'QCBE'
QCB.name = 'QualityColorBlind' -- sugar daddy
QCB.author = 'oJelly'
QCB.version = '1.3.0'
QCB.init = false
QCB.savedata = {}
local WM = WINDOW_MANAGER
local EM = EVENT_MANAGER
local SM = SCENE_MANAGER
local CM = CALLBACK_MANAGER
local init_savedef = {
    show_type = '0', --0 number , 1 english
    show_quality = {0,true,true,true,true,true},
}
local debug_mode = false

local QCBLastActiveRowControl = nil
local QCBCatchTooltipLink = nil

local LAM2 = LibStub:GetLibrary("LibAddonMenu-2.0")
local lang = GetCVar("Language.2")

local ICON_SHOW_TYPE_OPTS = { 
    QualityColorBlindLang[lang].ICON_SHOW_TYPE_OPT_1, 
    QualityColorBlindLang[lang].ICON_SHOW_TYPE_OPT_2 
}

local LISTS = {
    BACKPACK = ZO_PlayerInventoryList,
    QUICKSLOT = ZO_QuickSlotList,
    BANK = ZO_PlayerBankBackpack,
    GUILD_BANK = ZO_GuildBankBackpack,
    CRAFTBAG = ZO_CraftBagList,
    DECONSTRUCTION = ZO_SmithingTopLevelDeconstructionPanelInventoryBackpack,
    IMPROVEMENT = ZO_SmithingTopLevelImprovementPanelInventoryBackpack,
    ENCHANTING = ZO_EnchantingTopLevelInventoryBackpack,
    ALCHEMY = ZO_AlchemyTopLevelInventoryBackpack,
    LIST_DIALOG = ZO_ListDialog1List,
}

function QCB:initializeHooks()
    local hookedSetupFunctions = {}
    
    local function newSetupCallback(rowControl, slot)
        local listViewName = rowControl:GetParent():GetParent():GetName()
        if hookedSetupFunctions[listViewName] then
            hookedSetupFunctions[listViewName](rowControl, slot)
        end
        QCB:CreateMarkerControl(rowControl,'initHooks')
    end

    for _, list in pairs(LISTS) do
        hookedSetupFunctions[list:GetName()] = list.dataTypes[1].setupCallback
        list.dataTypes[1].setupCallback = newSetupCallback
    end
end


function QCB:CreateMarkerControl(parent,fromby)
    if not parent then return end
    local dataEntry = parent.dataEntry
    local bagId, slotIndex, Iquality, Iname

    local control = parent:GetNamedChild("QCBShower")
    if not control then
        control = WM:CreateControl(parent:GetName() .. "QCBShower", parent, CT_TEXTURE)
        control:SetDimensions(12, 12)
        control:SetDrawTier(DT_HIGH)
    end

    if not dataEntry then
        bagId = parent.bagId
        slotIndex = parent.slotIndex
        if fromby == 'initEquipment' then
            local IitemLink = GetItemLink(0, slotIndex, LINK_STYLE_BRACKETS)
            Iquality = GetItemLinkQuality(IitemLink)
            Iname = GetItemLinkName(IitemLink)
        end
    else
        bagId = dataEntry.data.bagId
        slotIndex = dataEntry.data.slotIndex
        Iquality = dataEntry.data.quality
        Iname = dataEntry.data.rawName
    end

    --case to handle list dialog, list dialog uses index instead of slotIndex
    --and bag instead of badId...?
    if dataEntry and not bagId and not slotIndex then
        bagId = dataEntry.data.bag
        slotIndex = dataEntry.data.index
    end

    -- 找貼圖的目標定位點
    local anchorTarget = parent:GetNamedChild("Button")
    if anchorTarget then
        anchorTarget = anchorTarget:GetNamedChild("Icon") --list control
    else
        anchorTarget = parent:GetNamedChild("Icon") --equipment control
    end
    if not anchorTarget then return end

    if not Iquality then return end
    --if QCB.savedata.show_quality[Iquality] == false then return end
    -- if Iquality ~= 1 then return end

    if QCB.savedata.show_type == '12345' then
        img = 'QualityColorBlind/img/n'..Iquality..'.dds'
    end
    if QCB.savedata.show_type == 'NFSEL' then
        img = 'QualityColorBlind/img/s'..Iquality..'.dds'
    end
    control:SetTexture(img)
    control:SetColor(1, 1, 1)
    control:ClearAnchors()
    control:SetAnchor(TOPLEFT, anchorTarget, BOTTOMLEFT, 0, -12)

    if QCB.savedata.show_quality[Iquality] == false then 
        control:SetHidden(true)
    else
        control:SetHidden(false)
    end
end

function QCB:initializeEquipment()
    for i = 1, ZO_Character:GetNumChildren() do
        local child = ZO_Character:GetChild(i)
        if child and child:GetName():find("ZO_CharacterEquipmentSlots") then
            QCB:CreateMarkerControl(ZO_Character:GetChild(i),'initEquipment')
        end
    end
end

----------------------------------------
-- Tooltip
----------------------------------------
function QCB:getMouseoverLink()
    local data
    local mouseOverControl = moc()
    
    if not mouseOverControl then return end
    
    local name = nil

    if mouseOverControl:GetParent() then
        name = mouseOverControl:GetParent():GetName()
    else
        name = mouseOverControl:GetName()
    end

    if  name == 'ZO_CraftBagListContents' or
        name == 'ZO_EnchantingTopLevelInventoryBackpackContents' or
        name == 'ZO_GuildBankBackpackContents' or
        name == 'ZO_PlayerBankBackpackContents' or
        name == 'ZO_PlayerInventoryListContents' or
        name == 'ZO_QuickSlotListContents' or
        name == 'ZO_SmithingTopLevelDeconstructionPanelInventoryBackpackContents' or
        name == 'ZO_SmithingTopLevelImprovementPanelInventoryBackpackContents' or
        name == 'ZO_SmithingTopLevelRefinementPanelInventoryBackpackContents' or
        name == 'ZO_PlayerInventoryBackpackContents' then
        
        if not mouseOverControl.dataEntry then return end
        
        data = mouseOverControl.dataEntry.data
        return GetItemLink(data.bagId, data.slotIndex, LINK_STYLE_BRACKETS)

    elseif name == "ZO_LootAlphaContainerListContents" then                     -- is loot item
        if not mouseOverControl.dataEntry then return end
        data = mouseOverControl.dataEntry.data
        return GetLootItemLink(data.lootId, LINK_STYLE_BRACKETS)

    elseif name == "ZO_InteractWindowRewardArea" then                           -- is reward item
        return GetQuestRewardItemLink(mouseOverControl.index, LINK_STYLE_BRACKETS)

    elseif name == "ZO_Character" then                                          -- is worn item
        return QCB:GetEquippedItemLink(mouseOverControl)

    elseif name == "ZO_StoreWindowListContents" then                            -- is store item
        return GetStoreItemLink(mouseOverControl.index, LINK_STYLE_BRACKETS)

    elseif name == "ZO_BuyBackListContents" then                                -- is buyback item
        return GetBuybackItemLink(mouseOverControl.index, LINK_STYLE_BRACKETS)

    -- following 4 if's derived directly from MasterMerchant
    elseif string.sub(name, 1, 14) == "MasterMerchant" then
        local mocGPGP = mouseOverControl:GetParent():GetParent()
        if mocGPGP then
            name = mocGPGP:GetName()
            if  name == 'MasterMerchantWindowListContents' or
                name == 'MasterMerchantWindowList' or
                name == 'MasterMerchantGuildWindowListContents' then
                if mouseOverControl.GetText then
                    return mouseOverControl:GetText()
                end
            end
        end
    elseif name == 'ZO_LootAlphaContainerListContents' then
        return GetLootItemLink(mouseOverControl.dataEntry.data.lootId)
    elseif name == 'ZO_MailInboxMessageAttachments' then
        return GetAttachedItemLink(MAIL_INBOX:GetOpenMailId(), mouseOverControl.id, LINK_STYLE_DEFAULT)
    elseif name == 'ZO_MailSendAttachments' then
        return GetMailQueuedAttachmentLink(mouseOverControl.id, LINK_STYLE_DEFAULT)

    elseif name == "ZO_MailInboxMessageAttachments" then
        return nil

    -- elseif name == "IIFA_GUI_ListHolder" then
    --     -- falls out, returns default current link

    -- elseif name:sub(1, 13) == "IIFA_ListItem" then
    --     return mouseOverControl.itemLink

    elseif name:sub(1, 44) == "ZO_TradingHouseItemPaneSearchResultsContents" then
        data = mouseOverControl.dataEntry
        if data then data = data.data end
        -- The only thing with 0 time remaining should be guild tabards, no
        -- stats on those!
        if not data or data.timeRemaining == 0 then return nil end
        return GetTradingHouseSearchResultItemLink(data.slotIndex)

    elseif name == "ZO_TradingHousePostedItemsListContents" then
        return GetTradingHouseListingItemLink(mouseOverControl.dataEntry.data.slotIndex)

    elseif name == 'ZO_TradingHouseLeftPanePostItemFormInfo' then
        if mouseOverControl.slotIndex and mouseOverControl.bagId then
            return GetItemLink(mouseOverControl.bagId, mouseOverControl.slotIndex)
        end

    else
        -- d("Tooltip not processed - '" .. name .. "'")
        if QCBCatchTooltipLink then
            -- d("Current Link - " .. QCBCatchTooltipLink)
        end

        return nil
    end
    return QCBCatchTooltipLink
end
function QCB:getLastLink(tooltip)
    local ret = nil
    if tooltip == QCB_POPUP_TOOLTIP then
        ret = QCBCatchTooltipLink
    elseif tooltip == QCB_ITEM_TOOLTIP then
        ret = QCB:getMouseoverLink()
    end
    if (not ret) then
        if not QCBLastActiveRowControl then return ret end
        ret = QCBLastActiveRowControl:GetText()
    end
    return ret
end
function QCB:UpdateTooltip(tooltip)
    local itemLink = QCB:getLastLink(tooltip)
    local itemQuality = GetItemLinkQuality(itemLink)
    local showQualityTxt = ''

    if QCB.savedata.show_type == '12345' then
        showQualityTxt = 'Quality : '..itemQuality
    end

    if QCB.savedata.show_type == 'NFSEL' then
        showQualityTxt = 'Quality : '..GetString('SI_ITEMQUALITY',GetItemLinkQuality(itemLink))
    end

    local parentTooltip = nil
    if tooltip == QCB_POPUP_TOOLTIP then parentTooltip = PopupTooltip end
    if tooltip == QCB_ITEM_TOOLTIP then parentTooltip = ItemTooltip end

    tooltip:ClearLines()
    tooltip:AddLine(showQualityTxt)
    tooltip:SetHidden(false)

    -- tooltip:GetNamedChild('txt'):SetText(showQualityTxt)
    -- tooltip:SetHeight(0)
    -- tooltip:SetWidth(parentTooltip:GetWidth())
    --tooltip:AddLine(showQualityTxt)
end
function QCBTooltipOnTwitch(control, eventNum)
    if eventNum == 7 then
        if control == ItemTooltip then
            -- item tooltips appear where mouse is
            return QCB:UpdateTooltip(QCB_ITEM_TOOLTIP)
        elseif control == PopupTooltip then
            -- popup tooltips have the X in the corner and usually pop up in center screen
            QCBCatchTooltipLink = PopupTooltip.lastLink
            return QCB:UpdateTooltip(QCB_POPUP_TOOLTIP)
        end
    end
end
function QCBHideTooltip(control, ...)
    if control == ItemTooltip then
        QCB_ITEM_TOOLTIP:SetHidden(true)
    elseif control == PopupTooltip then
        QCB_POPUP_TOOLTIP:SetHidden(true)
    end
end
-- copy IIfA
function QCB:GetEquippedItemLink(mouseOverControl)
    local fullSlotName = mouseOverControl:GetName()
    local slotName = string.gsub(fullSlotName, "ZO_CharacterEquipmentSlots", "")
    local index = 0
    if      (slotName == "Head")        then index = 0
    elseif  (slotName == "Neck")        then index = 1
    elseif  (slotName == "Chest")       then index = 2
    elseif  (slotName == "Shoulder")    then index = 3
    elseif  (slotName == "MainHand")    then index = 4
    elseif  (slotName == "OffHand")     then index = 5
    elseif  (slotName == "Belt")        then index = 6
    elseif  (slotName == "Costume")     then index = 7
    elseif  (slotName == "Leg")         then index = 8
    elseif  (slotName == "Foot")        then index = 9
    elseif  (slotName == "Ring1")       then index = 11
    elseif  (slotName == "Ring2")       then index = 12
    elseif  (slotName == "Glove")       then index = 16
    elseif  (slotName == "BackupMain")  then index = 20
    elseif  (slotName == "BackupOff")   then index = 20
    end
    -- debug for bag stuff
    --[[ for bagSlot = 1    , (GetBagSize and GetBagSize(bagId_WORN) or select(2, GetBagInfo(bagId_WORN))), 1 do
        if (GetItemLink(0, bagSlot) ~= "") then
            d(bagIdSlot .. ": " .. GetItemLink(0, bagSlot))
        end
    end]]

    local itemLink = GetItemLink(0, index, LINK_STYLE_BRACKETS)
    return itemLink
end
----------------------------------------
-- setting
----------------------------------------
local function createLAM2Panel()
    local treasureMapIcon
    local langarray = QualityColorBlindLang[lang]
    local panelData = {
        type = "panel",
        name = QCB.name,
        displayName = ZO_HIGHLIGHT_TEXT:Colorize(QCB.name),
        author = "|cFFAA33"..QCB.author.."|r",
        version = QCB.version,
        registerForRefresh = true,
    }

    local optionsData = {
        [1] = {
            type = "dropdown",
            name = langarray.ICON_SHOW_TYPE,
            tooltip = langarray.ICON_SHOW_TYPE_TIP,
            choices = ICON_SHOW_TYPE_OPTS,
            getFunc = function() 
                return QCB.savedata.show_type
            end,
            setFunc = function(val)
                QCB.savedata.show_type = val
                QCB:initializeHooks()
            end,
            default = QCB.savedata.show_type,
            --reference = "InventoryGridViewSettingsSkinDropdown",
        },
        [2] = {
            type = "checkbox",
            name = langarray.ICON_SHOW_OPT1,
            tooltip = langarray.ICON_SHOW_OPT1_TIP,
            getFunc = function() 
                return QCB.savedata.show_quality[1]
            end,
            setFunc = function(val) 
                QCB.savedata.show_quality[1] = val
                QCB:initializeHooks()
            end,
            default = QCB.savedata.show_quality[1],
        },
        [3] = {
            type = "checkbox",
            name = langarray.ICON_SHOW_OPT2,
            tooltip = langarray.ICON_SHOW_OPT2_TIP,
            getFunc = function() 
                return QCB.savedata.show_quality[2]
            end,
            setFunc = function(val) 
                QCB.savedata.show_quality[2] = val
                QCB:initializeHooks()
            end,
            default = QCB.savedata.show_quality[2],
        },
        [4] = {
            type = "checkbox",
            name = langarray.ICON_SHOW_OPT3,
            tooltip = langarray.ICON_SHOW_OPT3_TIP,
            getFunc = function() 
                return QCB.savedata.show_quality[3]
            end,
            setFunc = function(val) 
                QCB.savedata.show_quality[3] = val
                QCB:initializeHooks()
            end,
            default = QCB.savedata.show_quality[3],
        },
        [5] = {
            type = "checkbox",
            name = langarray.ICON_SHOW_OPT4,
            tooltip = langarray.ICON_SHOW_OPT4_TIP,
            getFunc = function() 
                return QCB.savedata.show_quality[4]
            end,
            setFunc = function(val) 
                QCB.savedata.show_quality[4] = val
                QCB:initializeHooks()
            end,
            default = QCB.savedata.show_quality[4],
        },
        [6] = {
            type = "checkbox",
            name = langarray.ICON_SHOW_OPT5,
            tooltip = langarray.ICON_SHOW_OPT5_TIP,
            getFunc = function() 
                return QCB.savedata.show_quality[5]
            end,
            setFunc = function(val) 
                QCB.savedata.show_quality[5] = val
                QCB:initializeHooks()
            end,
            default = QCB.savedata.show_quality[5],
        },
    }
    local myPanel = LAM2:RegisterAddonPanel(QCB.name.."LAM2Options", panelData)
    LAM2:RegisterOptionControls(QCB.name.."LAM2Options", optionsData)
end
----------------------------------------
-- INIT
----------------------------------------
function QCB:Initialize()

    QCB.savedata = ZO_SavedVars:NewAccountWide('QCB_savedata',1,nil,init_savedef)

	--setup hooks
	QCB:initializeHooks()
    --setup equipment
    QCB:initializeEquipment()

    -- copy and learn @ IIfA
    WM:CreateControlFromVirtual("QCB_ITEM_TOOLTIP", ItemTooltipTopLevel, "QCB_ITEM_TOOLTIP")
    WM:CreateControlFromVirtual("QCB_POPUP_TOOLTIP", ItemTooltipTopLevel, "QCB_POPUP_TOOLTIP")
    ZO_PreHookHandler(PopupTooltip, 'OnAddGameData', QCBTooltipOnTwitch)
    ZO_PreHookHandler(PopupTooltip, 'OnHide', QCBHideTooltip)
    ZO_PreHookHandler(ItemTooltip, 'OnAddGameData', QCBTooltipOnTwitch)
    ZO_PreHookHandler(ItemTooltip, 'OnHide', QCBHideTooltip)
    ZO_PreHook("ZO_PopupTooltip_SetLink", function(itemLink) QCBCatchTooltipLink = itemLink end)

    -- setting page
    createLAM2Panel()

    -- 一些 SLASH COMMANDS 視窗問題
    SLASH_COMMANDS["/qcbtest"] = function()
        d(QCB.savedata);
    end
end


function QCB.OnAddOnLoaded(event, addonName)
	if addonName ~= QCB.name then return end
	EM:UnregisterForEvent(QCB.ename,EVENT_ADD_ON_LOADED)
	QCB:Initialize()
end
EM:RegisterForEvent(QCB.ename, EVENT_ADD_ON_LOADED, QCB.OnAddOnLoaded);

function QCB.handleEquipmentChange(eventCode, bagId, slotIndex, isNewItem, itemSoundCategory, inventoryUpdateReason)
    if bagId ~= BAG_WORN or isNewItem or inventoryUpdateReason ~= 0 then return end
    QCB:initializeEquipment()
end
EVENT_MANAGER:RegisterForEvent(QCB.ename2, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, QCB.handleEquipmentChange)