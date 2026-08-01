STL = {}
STL.ename = 'STL'
STL.ename2 = 'STLE'
STL.name = 'oJ_ShowTraitOnList' -- sugar daddy
STL.menuname = 'ShowTraitOnList'
STL.author = 'oJelly'
STL.version = '1.2.4'
STL.init = false
STL.savedata = {}
local WM = WINDOW_MANAGER
local EM = EVENT_MANAGER
local SM = SCENE_MANAGER
local CM = CALLBACK_MANAGER
local init_savedef = {
    iconSize = 20,
    iconPostionT = 33,
    iconPostionL = 0,
    eqiconSize = 20,
    eqiconPostionT = 33,
    eqiconPostionL = 0,
}
local debug_mode = false

local LAM2 = LibAddonMenu2
local lang = GetCVar("Language.2")

local ICON_PATH = {}
    ICON_PATH[ITEM_TRAIT_TYPE_ARMOR_STURDY] = 'crafting_runecrafter_plug_component_002'
    ICON_PATH[ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE] = 'crafting_jewelry_base_diamond_r3'
    ICON_PATH[ITEM_TRAIT_TYPE_ARMOR_REINFORCED] = 'crafting_enchantment_base_sardonyx_r2'
    ICON_PATH[ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED] = 'crafting_accessory_sp_names_002'
    ICON_PATH[ITEM_TRAIT_TYPE_ARMOR_TRAINING] = 'crafting_jewelry_base_emerald_r2'
    ICON_PATH[ITEM_TRAIT_TYPE_ARMOR_INFUSED] = 'crafting_enchantment_baxe_bloodstone_r2'
    ICON_PATH[ITEM_TRAIT_TYPE_ARMOR_EXPLORATION] = 'crafting_jewelry_base_garnet_r3'
    ICON_PATH[ITEM_TRAIT_TYPE_ARMOR_DIVINES] = 'crafting_accessory_sp_names_001'
    ICON_PATH[ITEM_TRAIT_TYPE_ARMOR_NIRNHONED] = 'crafting_potent_nirncrux_stone'

    ICON_PATH[ITEM_TRAIT_TYPE_WEAPON_POWERED] = 'crafting_runecrafter_potion_008'
    ICON_PATH[ITEM_TRAIT_TYPE_WEAPON_CHARGED] = 'crafting_jewelry_base_amethyst_r3'
    ICON_PATH[ITEM_TRAIT_TYPE_WEAPON_PRECISE] = 'crafting_jewelry_base_ruby_r3'
    ICON_PATH[ITEM_TRAIT_TYPE_WEAPON_INFUSED] = 'crafting_enchantment_base_jade_r3'
    ICON_PATH[ITEM_TRAIT_TYPE_WEAPON_DEFENDING] = 'crafting_jewelry_base_turquoise_r3'
    ICON_PATH[ITEM_TRAIT_TYPE_WEAPON_TRAINING] = 'crafting_runecrafter_armor_component_004'
    ICON_PATH[ITEM_TRAIT_TYPE_WEAPON_SHARPENED] = 'crafting_enchantment_base_fire_opal_r3'
    ICON_PATH[ITEM_TRAIT_TYPE_WEAPON_DECISIVE] = 'crafting_smith_potion__sp_names_003'
    ICON_PATH[ITEM_TRAIT_TYPE_WEAPON_NIRNHONED] = 'crafting_potent_nirncrux_dust'

    ICON_PATH[ITEM_TRAIT_TYPE_JEWELRY_ARCANE] = 'jewelrycrafting_trait_refined_cobalt'
    ICON_PATH[ITEM_TRAIT_TYPE_JEWELRY_HEALTHY] = 'jewelrycrafting_trait_refined_antimony'
    ICON_PATH[ITEM_TRAIT_TYPE_JEWELRY_ROBUST] = 'jewelrycrafting_trait_refined_zinc'
    ICON_PATH[ITEM_TRAIT_TYPE_JEWELRY_TRIUNE] = 'jewelrycrafting_trait_refined_dawnprism'
    ICON_PATH[ITEM_TRAIT_TYPE_JEWELRY_INFUSED] = 'crafting_enchantment_base_jade_r1'
    ICON_PATH[ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE] = 'crafting_runecrafter_armor_component_006'
    ICON_PATH[ITEM_TRAIT_TYPE_JEWELRY_SWIFT] = 'crafting_outfitter_plug_component_002'
    ICON_PATH[ITEM_TRAIT_TYPE_JEWELRY_HARMONY] = 'crafting_metals_tin'
    ICON_PATH[ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY] = 'crafting_enchantment_baxe_bloodstone_r1'

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
    STORE_BUYBACK = ZO_BuyBackList,
    STORE_REPAIR = ZO_RepairWindowList,
    HOUSE_BANK = ZO_HouseBankBackpack,
}
local MARK_EQTP = {
    EQUIP_TYPE_ONE_HAND,
    EQUIP_TYPE_TWO_HAND,
    EQUIP_TYPE_OFF_HAND,
    EQUIP_TYPE_MAIN_HAND,
    EQUIP_TYPE_HEAD,
    EQUIP_TYPE_CHEST,
    EQUIP_TYPE_WAIST,
    EQUIP_TYPE_SHOULDERS,
    EQUIP_TYPE_LEGS,
    EQUIP_TYPE_HAND,
    EQUIP_TYPE_FEET,
    EQUIP_TYPE_NECK,
    EQUIP_TYPE_RING,
}

function STL:initializeHooks()
    local hookedSetupFunctions = {}
    
    local function newSetupCallback(rowControl, slot)
        local listViewName = rowControl:GetParent():GetParent():GetName()
        if hookedSetupFunctions[listViewName] then
            hookedSetupFunctions[listViewName](rowControl, slot)
        end
        STL:CreateMarkerControl(rowControl,'initHooks')
    end

    for _, list in pairs(LISTS) do
        hookedSetupFunctions[list:GetName()] = list.dataTypes[1].setupCallback
        list.dataTypes[1].setupCallback = newSetupCallback
    end
end

function STL:initializeEquipment()
    for i = 1, ZO_Character:GetNumChildren() do
        local child = ZO_Character:GetChild(i)
        if child and child:GetName():find("ZO_CharacterEquipmentSlots") then
            STL:CreateMarkerControl(ZO_Character:GetChild(i),'initEquipment')
        end
    end
end

function STL:CreateMarkerControl(itemcontrol,fromby)
    if not itemcontrol then return end
    local control = STL.CreateSTLShower(itemcontrol)
    if control == nil then return end
    local IitemLink, Itrait, Iequiptp
    local itemcontrolname = itemcontrol:GetName();
    local IequipLType = GetItemLinkEquipType(itemlink) -- EQUIP_TYPE_ (look below). Non gear items: 0 - INVALID, 11 - COSTUME, 15 - POISON 
    if itemcontrolname:find("ZO_Character") then
        IitemLink = GetItemLink(itemcontrol.bagId, itemcontrol.slotIndex, LINK_STYLE_BRACKETS)
    elseif itemcontrolname:find("ZO_BuyBackList") then
        IitemLink = GetBuybackItemLink(itemcontrol.dataEntry.data.slotIndex, LINK_STYLE_BRACKETS)
    elseif itemcontrolname:find("ZO_ListDialog1List1") then
        -- 彈出視窗不顯示
        return
    else
        IitemLink = GetItemLink(itemcontrol.dataEntry.data.bagId, itemcontrol.dataEntry.data.slotIndex, LINK_STYLE_BRACKETS)
    end
    Itrait = GetItemLinkTraitInfo(IitemLink)
    Iequiptp = GetItemLinkEquipType(IitemLink)
    if in_array( Iequiptp , MARK_EQTP ) then 

    else
        Itrait = 0
    end
    STL.SetSTLShowerImg(control,Itrait)
end
-- 裝備更換觸發
function STL.handleEquipmentChange(eventCode, bagId, slotId, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange)
    if bagId ~= BAG_WORN or isNewItem or inventoryUpdateReason ~= INVENTORY_UPDATE_REASON_DEFAULT then return end
    -- thank @Baertram code XD
    if IsUnderArrest() then return end
    if SCENE_MANAGER:GetCurrentScene() == STABLES_SCENE then return end
    if GetItemType(bagId, slotId) == ITEMTYPE_NONE then return end
    STL:initializeEquipment()
end
-- 交易公會開啟觸發
function STL.showTraitOnTradingHouse(eventCode, responseType, result)
    ZO_PreHook(ZO_TradingHouseBrowseItemsRightPaneSearchResults.dataTypes[1], "setupCallback", function( ... )
        local control, data = ...
        if ( control.slotControlType and control.slotControlType == 'listSlot' and control.dataEntry.data.slotIndex ) then
            local IitemLink = control.dataEntry.data.itemLink
            local Itrait = GetItemLinkTraitInfo(IitemLink)
            local Iequiptp = GetItemLinkEquipType(IitemLink)
            local control = STL.CreateSTLShower(control)
            if control == nil then return end
            if in_array( Iequiptp , MARK_EQTP ) then 

            else
                Itrait = 0
            end
            STL.SetSTLShowerImg(control,Itrait)
        end
    end)
    ZO_PreHook(ZO_TradingHousePostedItemsList.dataTypes[2], "setupCallback", function( ... )
        local control, data = ...
        if ( control.slotControlType and control.slotControlType == 'listSlot' and control.dataEntry.data.slotIndex ) then
            local IitemLink = control.dataEntry.data.itemLink
            local Itrait = GetItemLinkTraitInfo(IitemLink)
            local Iequiptp = GetItemLinkEquipType(IitemLink)
            local control = STL.CreateSTLShower(control)
            if control == nil then return end
            if in_array( Iequiptp , MARK_EQTP ) then 

            else
                Itrait = 0
            end
            STL.SetSTLShowerImg(control,Itrait)
        end
    end)
end

-- 建立放 icon 的地方
function STL.CreateSTLShower(tar)
    -- 建目標
    local control = tar:GetNamedChild("STLShower")
    if not control then
        control = WM:CreateControl(tar:GetName() .. "STLShower", tar, CT_TEXTURE)
        control:SetDrawTier(DT_HIGH)
    end
    if tar:GetName():find("ZO_Character") then
        control:SetDimensions(STL.savedata.eqiconSize, STL.savedata.eqiconSize)
    else
        control:SetDimensions(STL.savedata.iconSize, STL.savedata.iconSize)
    end

    -- 找貼圖的目標定位點
    local anchorTarget = tar:GetNamedChild("Button")
    if anchorTarget then
        anchorTarget = anchorTarget:GetNamedChild("Icon") --list control
    else
        anchorTarget = tar:GetNamedChild("Icon") --equipment control
    end
    if not anchorTarget then 
        return nil
    end

    control:SetColor(1, 1, 1)
    control:ClearAnchors()
    if tar:GetName():find("ZO_Character") then
        control:SetAnchor(TOPLEFT, anchorTarget, TOPLEFT, STL.savedata.eqiconPostionL, STL.savedata.eqiconPostionT)
    else
        control:SetAnchor(TOPLEFT, anchorTarget, TOPLEFT, STL.savedata.iconPostionL, STL.savedata.iconPostionT)
    end
    
    control:SetHidden(true)

    return control;
end
-- 設定放 icon 的 img
function STL.SetSTLShowerImg(control,Itrait)
    if Itrait ~= 0 and Itrait ~= nil then
        if ICON_PATH[Itrait] ~= nil then
            local img = '/esoui/art/icons/'..ICON_PATH[Itrait]..'.dds'
            control:SetTexture(img)
            control:SetHidden(false)
        else
            control:SetHidden(true)
        end
    else
        control:SetHidden(true)
    end
end
----------------------------------------
-- function
----------------------------------------
function in_array( val , arr )
    local findstatus = false
    for k,v in pairs(arr) do
        if v == val then
            findstatus = true
      return findstatus
        end
    end
    return findstatus
end
----------------------------------------
-- setting
----------------------------------------
local function createLAM2Panel()
    local treasureMapIcon
    local langarray = ShowTraitOnListLang[lang]
    local panelData = {
        type = "panel",
        name = STL.menuname,
        displayName = ZO_HIGHLIGHT_TEXT:Colorize(STL.menuname),
        author = "|cFFAA33"..STL.author.."|r",
        version = STL.version,
        registerForRefresh = true,
    }

    local optionsData = {
        [1] = {
            type = "slider",
            name = langarray.ICON_SIZE,
            min = 0,
            max = 50,
            step = 1,
            getFunc = function() 
                return STL.savedata.iconSize
            end,
            setFunc = function(val)
                STL.savedata.iconSize = val
                STL:initializeHooks()
                STL:initializeEquipment()
            end,
            default = STL.savedata.iconSize,
        },
        [2] = {
            type = "slider",
            name = langarray.ICON_POSTION_TOP,
            min = -20,
            max = 60,
            step = 1,
            getFunc = function() 
                return STL.savedata.iconPostionT
            end,
            setFunc = function(val)
                STL.savedata.iconPostionT = val
                STL:initializeHooks()
                STL:initializeEquipment()
            end,
            default = STL.savedata.iconPostionT,
        },
        [3] = {
            type = "slider",
            name = langarray.ICON_POSTION_LEFT,
            min = -20,
            max = 60,
            step = 1,
            getFunc = function() 
                return STL.savedata.iconPostionL
            end,
            setFunc = function(val)
                STL.savedata.iconPostionL = val
                STL:initializeHooks()
                STL:initializeEquipment()
            end,
            default = STL.savedata.iconPostionL,
        },
        [4] = {
            type = "slider",
            name = langarray.ICON_EQSIZE,
            min = 0,
            max = 50,
            step = 1,
            getFunc = function() 
                return STL.savedata.eqiconSize
            end,
            setFunc = function(val)
                STL.savedata.eqiconSize = val
                STL:initializeHooks()
                STL:initializeEquipment()
            end,
            default = STL.savedata.eqiconSize,
        },
        [5] = {
            type = "slider",
            name = langarray.ICON_EQPOSTION_TOP,
            min = -20,
            max = 60,
            step = 1,
            getFunc = function() 
                return STL.savedata.eqiconPostionT
            end,
            setFunc = function(val)
                STL.savedata.eqiconPostionT = val
                STL:initializeHooks()
                STL:initializeEquipment()
            end,
            default = STL.savedata.eqiconPostionT,
        },
        [6] = {
            type = "slider",
            name = langarray.ICON_EQPOSTION_LEFT,
            min = -20,
            max = 60,
            step = 1,
            getFunc = function() 
                return STL.savedata.eqiconPostionL
            end,
            setFunc = function(val)
                STL.savedata.eqiconPostionL = val
                STL:initializeHooks()
                STL:initializeEquipment()
            end,
            default = STL.savedata.eqiconPostionL,
        },
    }
    LAM2:RegisterAddonPanel(STL.menuname.."LAM2Options", panelData)
    LAM2:RegisterOptionControls(STL.menuname.."LAM2Options", optionsData)
end
----------------------------------------
-- INIT
----------------------------------------
function STL:Initialize()
    STL.savedata = ZO_SavedVars:NewAccountWide('STL_savedata',1,nil,init_savedef)
    for k,v in pairs(STL.savedata) do
        if v == nil then
            STL.savedata[k] = init_savedef[k]
        end
    end

	--setup hooks
	STL:initializeHooks()
    --setup equipment
    STL:initializeEquipment()
    EVENT_MANAGER:RegisterForEvent(STL.ename2, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, STL.handleEquipmentChange)
    --交易公會無法再未打開前自動綁定
    EVENT_MANAGER:RegisterForEvent(STL.ename2, EVENT_OPEN_TRADING_HOUSE, STL.showTraitOnTradingHouse)
    
    -- setting page
    createLAM2Panel()

    SLASH_COMMANDS["/ojs"] = function()
        d('STL OnAddOnLoaded')
    end
end
function STL.OnAddOnLoaded(event, addonName)
	if addonName ~= STL.name then return end
	EM:UnregisterForEvent(STL.ename,EVENT_ADD_ON_LOADED)
	STL:Initialize()
end
EM:RegisterForEvent(STL.ename, EVENT_ADD_ON_LOADED, STL.OnAddOnLoaded);