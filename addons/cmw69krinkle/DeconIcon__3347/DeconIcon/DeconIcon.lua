--------------------------------------------------------------------------------
-- DeconIcon.lua
-- Author: cmw69krinkle
--
-- This is the addon's main file.
-- It handles the Addon registration and hooks into the UI creation callback for
-- given inventory screens and puts an immmediately visible icon. No more 
-- hovering over items to see if they're in the bank. (This was written before
-- any "Include Banked Items" check box)
--
--------------------------------------------------------------------------------

DeconIconAddon = {}

local IIT = DeconIconAddon
IIT.addonVersion = "1.0.0"
IIT.addonName = "DeconIcon"

local em = GetEventManager()

-- This is the list of screens we care to mess with.
local LISTS = {
    --BACKPACK = ZO_PlayerInventoryList,
    --QUICKSLOT = ZO_QuickSlotList,
    --BANK = ZO_PlayerBankBackpack,
    --GUILD_BANK = ZO_GuildBankBackpack,
    --CRAFTBAG = ZO_CraftBagList,
    DECONSTRUCTION = ZO_SmithingTopLevelDeconstructionPanelInventoryBackpack,
    IMPROVEMENT = ZO_SmithingTopLevelImprovementPanelInventoryBackpack,
    ENCHANTING = ZO_EnchantingTopLevelInventoryBackpack,
    ALCHEMY = ZO_AlchemyTopLevelInventoryBackpack,
    LIST_DIALOG = ZO_ListDialog1List,
}

local textureNameBag  = "esoui/art/tooltips/icon_bag.dds"
local textureNameBank = "esoui/art/icons/servicemappins/servicepin_bank.dds"

--------------------------------------------------------------------------------
-- Get the bagId and slotIndex for an item in the given row
--------------------------------------------------------------------------------

local function getInfoFromRowControl(rowControl)
    if not rowControl then
        return
    end

    local dataEntry = rowControl.dataEntry
    local bagId, slotIndex

    -- case to handle equiped items
    if not dataEntry then
        bagId = rowControl.bagId
        slotIndex = rowControl.slotIndex
    else
        bagId = dataEntry.data.bagId
        slotIndex = dataEntry.data.slotIndex
    end

    -- case to handle list dialog, list dialog uses index instead of slotIndex
    -- and bag instead of badId...?
    if dataEntry and not bagId and not slotIndex then
        bagId = dataEntry.data.bag
        slotIndex = dataEntry.data.index
    end

    return bagId, slotIndex
end

--------------------------------------------------------------------------------
-- Create and show/hide the bank or bag icon.
--------------------------------------------------------------------------------

local function createMarkerControl(parent)
    -- create a icon control for inv list
    local control = parent:GetNamedChild("DeconIconCtrl")

    if not control then
        control = WINDOW_MANAGER:CreateControl(parent:GetName() .. "DeconIconCtrl", parent, CT_TEXTURE)
        control:SetDimensions(24, 24)
        control:SetDrawTier(DT_HIGH)
    end

    local bagId, _ = getInfoFromRowControl(parent)

    -- BAG_WORN = 0
    -- BAG_BACKPACK = 1
    -- BAG_BANK = 2
    -- BAG_GUILDBANK = 3
    -- BAG_BUYBACK = 4
    -- BAG_TRANSFER = 5
    -- BAG_SUBSCRIBER_BANK = 6
    -- BAG_DELETE = 255

    -- figure out the texture to use for the icon. bag or bank
    local texturePath
    local isHidden = false

    if bagId == BAG_BACKPACK then
        texturePath = textureNameBag
        isHidden = not DeconIconAddon.settings.showBagIcon
    elseif bagId == BAG_BANK or bagId == BAG_SUBSCRIBER_BANK then
        texturePath = textureNameBank
        isHidden = not DeconIconAddon.settings.showBankIcon
    else
        isHidden = true
    end

    local anchorTarget = parent:GetNamedChild("TraitInfo")

    if anchorTarget then
        control:SetHidden(isHidden)
        control:SetTexture(texturePath)
        control:SetColor(255, 255, 255)
        control:ClearAnchors()
        control:SetAnchor(TOPLEFT, anchorTarget, TOPLEFT, -24, 0)
    end
end

--------------------------------------------------------------------------------
-- Setup the hooks to do it's normal setup plus add our icon marker control
--------------------------------------------------------------------------------

local function initializeHooks()
    --add marker initialization to slot setup callbacks
    local hookedSetupFunctions = {}

    local function newSetupCallback(rowControl, slot)
        local listViewName = rowControl:GetParent():GetParent():GetName()

        if hookedSetupFunctions[listViewName] then
            hookedSetupFunctions[listViewName](rowControl, slot)
        end

        createMarkerControl(rowControl)
    end

    -- list hooks
    for _, list in pairs(LISTS) do
        hookedSetupFunctions[list:GetName()] = list.dataTypes[1].setupCallback
        list.dataTypes[1].setupCallback = newSetupCallback
    end

end

--------------------------------------------------------------------------------
-- AddOn Loaded Event Handler
--------------------------------------------------------------------------------

local function DeconIcon_Loaded(eventCode, addonName)
    if addonName ~= IIT.addonName then
        return
    end

    em:UnregisterForEvent(IIT.addonName, EVENT_ADD_ON_LOADED)

    --initialize settings
    IIT.settings = IIT_Settings:New()
    IIT.settings:CreatePanel()

    --setup hooks
    initializeHooks()
end

em:RegisterForEvent(IIT.addonName, EVENT_ADD_ON_LOADED, DeconIcon_Loaded)
