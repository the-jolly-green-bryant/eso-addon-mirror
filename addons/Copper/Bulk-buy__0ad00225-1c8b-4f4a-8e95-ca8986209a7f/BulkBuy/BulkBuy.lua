--[[
BulkBuy
Version 1.8.2

PS5/gamepad vendor helper.
Adds a Square (UI_SHORTCUT_SECONDARY) keybind for the currently highlighted
vendor item and purchases the maximum quantity the player can afford and carry.
]]

BulkBuy = {}
local BB = BulkBuy

BB.name = "BulkBuy"
BB.version = "1.8.2"
BB.savedVarVersion = 3

local PLAYER_BAG = BAG_BACKPACK
local DIALOG_NAME = "BULKBUY_CONFIRM_DIALOG"

BB.defaults = {
    confirmBeforeBuy = true,
}

BB.targetStoreIndex = nil
BB.targetItemLink = nil
BB.targetItemId = nil
BB.targetItemName = nil
BB.targetEntryType = nil
BB.targetMeetsRequirements = true
BB.targetPrice = 0
BB.targetCurrencyType1 = 0
BB.targetCurrencyQuantity1 = 0
BB.targetCurrencyType2 = 0
BB.targetCurrencyQuantity2 = 0
BB.keybindDescriptor = nil
BB.keybindAdded = false
BB.sceneHooked = false
BB.selectionHooked = false

local function Msg(text)
    d("|c99FF99[BulkBuy]|r " .. tostring(text))
end

local function ClampNonNegativeInteger(value)
    value = tonumber(value) or 0
    if value < 0 then
        return 0
    end
    return math.floor(value)
end

function BB:OnAddOnLoaded(_, loadedName)
    if loadedName ~= BB.name then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(BB.name, EVENT_ADD_ON_LOADED)

    BB.savedVars = ZO_SavedVars:NewAccountWide(
        "BulkBuy_SavedVars",
        BB.savedVarVersion,
        nil,
        BB.defaults
    )

    BB:RegisterDialog()
    BB:HookStoreSelection()
    BB:HookScene()
    BB:RegisterSlashCommands()

    Msg(string.format("v%s loaded. Square bulk-buys the highlighted vendor item.", BB.version))
end

function BB:ClearTarget()
    BB.targetStoreIndex = nil
    BB.targetItemLink = nil
    BB.targetItemId = nil
    BB.targetItemName = nil
    BB.targetEntryType = nil
    BB.targetMeetsRequirements = true
    BB.targetPrice = 0
    BB.targetCurrencyType1 = 0
    BB.targetCurrencyQuantity1 = 0
    BB.targetCurrencyType2 = 0
    BB.targetCurrencyQuantity2 = 0
end

function BB:SetTargetFromBuyData(buyData)
    if not buyData or not buyData.slotIndex then
        BB:ClearTarget()
        BB:RefreshKeybind()
        return
    end

    local storeIndex = ClampNonNegativeInteger(buyData.slotIndex)
    if storeIndex <= 0 then
        BB:ClearTarget()
        BB:RefreshKeybind()
        return
    end

    local itemLink = ""
    if type(GetStoreItemLink) == "function" then
        itemLink = GetStoreItemLink(storeIndex) or ""
    end

    local itemName = nil
    if itemLink ~= "" and type(GetItemLinkName) == "function" then
        itemName = GetItemLinkName(itemLink)
    end
    if not itemName or itemName == "" then
        itemName = buyData.name or "Selected Item"
    end

    local itemId = nil
    if itemLink ~= "" and type(GetItemLinkItemId) == "function" then
        itemId = GetItemLinkItemId(itemLink)
    end

    local meetsRequirements = true
    if buyData.dataSource and buyData.dataSource.meetsRequirementsToBuy == false then
        meetsRequirements = false
    end

    BB.targetStoreIndex = storeIndex
    BB.targetItemLink = itemLink
    BB.targetItemId = itemId
    BB.targetItemName = itemName
    BB.targetEntryType = buyData.entryType
    BB.targetMeetsRequirements = meetsRequirements
    BB.targetPrice = ClampNonNegativeInteger(buyData.price)
    BB.targetCurrencyType1 = ClampNonNegativeInteger(buyData.currencyType1)
    BB.targetCurrencyQuantity1 = ClampNonNegativeInteger(buyData.currencyQuantity1)
    BB.targetCurrencyType2 = ClampNonNegativeInteger(buyData.currencyType2)
    BB.targetCurrencyQuantity2 = ClampNonNegativeInteger(buyData.currencyQuantity2)

    BB:AddKeybindToStrip()
    BB:RefreshKeybind()
end

function BB:HookStoreSelection()
    if BB.selectionHooked then
        return
    end

    if type(ZO_GamepadStoreBuy) ~= "table" or type(ZO_GamepadStoreBuy.OnSelectedItemChanged) ~= "function" then
        Msg("|cFF3333Could not hook the gamepad vendor buy list.|r")
        return
    end

    BB.selectionHooked = true
    ZO_PostHook(ZO_GamepadStoreBuy, "OnSelectedItemChanged", function(_, buyData)
        BB:SetTargetFromBuyData(buyData)
    end)
end

local function GetCurrencyAffordableCount(currencyType, unitCost)
    currencyType = ClampNonNegativeInteger(currencyType)
    unitCost = ClampNonNegativeInteger(unitCost)

    if currencyType <= 0 or unitCost <= 0 or
       type(GetCurrencyAmount) ~= "function" or
       type(GetCurrencyPlayerStoredLocation) ~= "function" then
        return nil
    end

    local location = GetCurrencyPlayerStoredLocation(currencyType)
    local amount = ClampNonNegativeInteger(GetCurrencyAmount(currencyType, location))
    return math.floor(amount / unitCost)
end

-- Uses both ESO's built-in maximum and an independent currency calculation.
-- The independent calculation protects against console cases where the built-in
-- value is stale or does not reflect every currency shown on the vendor row.
local function GetAffordableCount(storeIndex, price, currencyType1, currencyQuantity1, currencyType2, currencyQuantity2)
    if not storeIndex then
        return 0
    end

    -- Refresh the costs directly from the live vendor entry whenever possible.
    if type(GetStoreEntryInfo) == "function" then
        local _, _, _, livePrice, _, _, _, _, _, liveCurrencyType1, liveCurrencyQuantity1,
            liveCurrencyType2, liveCurrencyQuantity2 = GetStoreEntryInfo(storeIndex)

        price = livePrice or price
        currencyType1 = liveCurrencyType1 or currencyType1
        currencyQuantity1 = liveCurrencyQuantity1 or currencyQuantity1
        currencyType2 = liveCurrencyType2 or currencyType2
        currencyQuantity2 = liveCurrencyQuantity2 or currencyQuantity2
    end

    local limits = {}

    if type(GetStoreEntryMaxBuyable) == "function" then
        local apiMaximum = ClampNonNegativeInteger(GetStoreEntryMaxBuyable(storeIndex))
        if apiMaximum > 0 then
            limits[#limits + 1] = apiMaximum
        end
    end

    local goldLimit = GetCurrencyAffordableCount(CURT_MONEY, price)
    if goldLimit ~= nil then
        limits[#limits + 1] = goldLimit
    end

    local currencyLimit1 = GetCurrencyAffordableCount(currencyType1, currencyQuantity1)
    if currencyLimit1 ~= nil then
        limits[#limits + 1] = currencyLimit1
    end

    local currencyLimit2 = GetCurrencyAffordableCount(currencyType2, currencyQuantity2)
    if currencyLimit2 ~= nil then
        limits[#limits + 1] = currencyLimit2
    end

    if #limits == 0 then
        return 0
    end

    local affordable = limits[1]
    for i = 2, #limits do
        affordable = math.min(affordable, limits[i])
    end

    return ClampNonNegativeInteger(affordable)
end

local function HasCraftBagAccess()
    local subscribed = type(IsESOPlusSubscriber) == "function" and IsESOPlusSubscriber()
    local freeTrial = type(IsOnESOPlusFreeTrial) == "function" and IsOnESOPlusFreeTrial()
    return subscribed == true or freeTrial == true
end

-- Build the Craft Bag item-type set by constant name so the add-on remains
-- compatible if a particular constant is unavailable on an older API build.
local CRAFT_BAG_ITEM_TYPES = {}
local CRAFT_BAG_ITEM_TYPE_NAMES = {
    "ITEMTYPE_ALCHEMY_BASE",
    "ITEMTYPE_ARMOR_TRAIT",
    "ITEMTYPE_BLACKSMITHING_BOOSTER",
    "ITEMTYPE_BLACKSMITHING_MATERIAL",
    "ITEMTYPE_BLACKSMITHING_RAW_MATERIAL",
    "ITEMTYPE_CLOTHIER_BOOSTER",
    "ITEMTYPE_CLOTHIER_MATERIAL",
    "ITEMTYPE_CLOTHIER_RAW_MATERIAL",
    "ITEMTYPE_ENCHANTING_RUNE_ASPECT",
    "ITEMTYPE_ENCHANTING_RUNE_ESSENCE",
    "ITEMTYPE_ENCHANTING_RUNE_POTENCY",
    "ITEMTYPE_INGREDIENT",
    "ITEMTYPE_JEWELRYCRAFTING_BOOSTER",
    "ITEMTYPE_JEWELRYCRAFTING_MATERIAL",
    "ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER",
    "ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL",
    "ITEMTYPE_JEWELRY_RAW_TRAIT",
    "ITEMTYPE_JEWELRY_TRAIT",
    "ITEMTYPE_POISON_BASE",
    "ITEMTYPE_POTION_BASE",
    "ITEMTYPE_RAW_MATERIAL",
    "ITEMTYPE_REAGENT",
    "ITEMTYPE_STYLE_MATERIAL",
    "ITEMTYPE_WEAPON_TRAIT",
    "ITEMTYPE_WOODWORKING_BOOSTER",
    "ITEMTYPE_WOODWORKING_MATERIAL",
    "ITEMTYPE_WOODWORKING_RAW_MATERIAL",
}

for _, constantName in ipairs(CRAFT_BAG_ITEM_TYPE_NAMES) do
    local itemTypeValue = _G[constantName]
    if itemTypeValue ~= nil then
        CRAFT_BAG_ITEM_TYPES[itemTypeValue] = true
    end
end

local function IsCraftBagMaterial(itemType)
    return itemType ~= nil and CRAFT_BAG_ITEM_TYPES[itemType] == true
end

-- Calculates room for the selected item, including partial stacks.
-- GetSlotStackSize returns both the current stack count and the maximum
-- stack size for that specific inventory stack. This is more reliable on
-- console than depending on GetItemLinkMaxStackSize.
-- Collectibles do not consume backpack slots, so affordability is their cap.
-- Crafting materials purchased while Craft Bag access is active bypass the
-- backpack-space limit because they are deposited into BAG_VIRTUAL.
local function GetCarryCapacity(itemLink, itemId, entryType, affordable)
    if entryType == STORE_ENTRY_TYPE_COLLECTIBLE then
        return affordable
    end

    local itemType = nil
    if itemLink and itemLink ~= "" and type(GetItemLinkItemType) == "function" then
        itemType = GetItemLinkItemType(itemLink)
    end

    if IsCraftBagMaterial(itemType) and HasCraftBagAccess() then
        return affordable
    end

    local freeSlots = ClampNonNegativeInteger(GetNumBagFreeSlots(PLAYER_BAG))

    if not itemLink or itemLink == "" or not itemId or
       type(GetBagSize) ~= "function" or
       type(GetItemLink) ~= "function" or
       type(GetItemLinkItemId) ~= "function" or
       type(GetSlotStackSize) ~= "function" then
        return freeSlots
    end

    local bagSize = ClampNonNegativeInteger(GetBagSize(PLAYER_BAG))
    local partialStackRoom = 0
    local detectedMaxStack = 0

    for slotIndex = 0, bagSize - 1 do
        local slotLink = GetItemLink(PLAYER_BAG, slotIndex)
        if slotLink and slotLink ~= "" and GetItemLinkItemId(slotLink) == itemId then
            local stackSize, maxStackSize = GetSlotStackSize(PLAYER_BAG, slotIndex)
            stackSize = ClampNonNegativeInteger(stackSize)
            maxStackSize = ClampNonNegativeInteger(maxStackSize)

            if maxStackSize > detectedMaxStack then
                detectedMaxStack = maxStackSize
            end

            if maxStackSize > stackSize then
                partialStackRoom = partialStackRoom + (maxStackSize - stackSize)
            end
        end
    end

    -- If there is already a matching stack, use its reported maximum for every
    -- empty backpack slot. If there is no matching stack yet, try the optional
    -- item-link API and otherwise use one item per slot as a safe fallback.
    if detectedMaxStack <= 0 and type(GetItemLinkMaxStackSize) == "function" then
        detectedMaxStack = ClampNonNegativeInteger(GetItemLinkMaxStackSize(itemLink))
    end

    -- Some console/store item links do not provide a usable max stack size until
    -- the player already owns a matching stack. Potions and poisons are the most
    -- visible examples, so use conservative game stack limits as targeted fallbacks.
    -- Existing backpack stack data always takes priority over these values.
    if detectedMaxStack <= 0 and itemType ~= nil then
        if itemType == ITEMTYPE_POTION then
            detectedMaxStack = 100
        elseif itemType == ITEMTYPE_POISON then
            detectedMaxStack = 1000
        elseif IsCraftBagMaterial(itemType) then
            -- Vendor crafting materials generally use 200-item stacks. This
            -- fallback is only used when neither a matching backpack stack nor
            -- the vendor item link reports a usable maximum.
            detectedMaxStack = 200
        end
    end

    if detectedMaxStack <= 0 then
        detectedMaxStack = 1
    end

    return partialStackRoom + (freeSlots * detectedMaxStack)
end

function BB:GetMaxBuyable()
    if not BB.targetStoreIndex or not BB.targetMeetsRequirements then
        return 0
    end

    local affordable = GetAffordableCount(
        BB.targetStoreIndex,
        BB.targetPrice,
        BB.targetCurrencyType1,
        BB.targetCurrencyQuantity1,
        BB.targetCurrencyType2,
        BB.targetCurrencyQuantity2
    )
    if affordable <= 0 then
        return 0
    end

    local carryable = GetCarryCapacity(
        BB.targetItemLink,
        BB.targetItemId,
        BB.targetEntryType,
        affordable
    )

    return math.min(affordable, carryable)
end

function BB:AttemptBulkBuy()
    if not BB.targetStoreIndex then
        return
    end

    local quantity = BB:GetMaxBuyable()
    if quantity < 2 then
        return
    end

    -- Snapshot the selected row so moving the highlight while the dialog is open
    -- cannot purchase a different item.
    local purchaseData = {
        storeIndex = BB.targetStoreIndex,
        itemLink = BB.targetItemLink,
        itemId = BB.targetItemId,
        itemName = BB.targetItemName,
        entryType = BB.targetEntryType,
        quantity = quantity,
        price = BB.targetPrice,
        currencyType1 = BB.targetCurrencyType1,
        currencyQuantity1 = BB.targetCurrencyQuantity1,
        currencyType2 = BB.targetCurrencyType2,
        currencyQuantity2 = BB.targetCurrencyQuantity2,
    }

    if BB.savedVars.confirmBeforeBuy then
        ZO_Dialogs_ShowGamepadDialog(
            DIALOG_NAME,
            purchaseData,
            {
                titleParams = { purchaseData.itemName or "Selected Item", tostring(quantity) },
                mainTextParams = { purchaseData.itemName or "Selected Item", tostring(quantity) },
            }
        )
    else
        BB:DoPurchase(purchaseData)
    end
end

function BB:GetMaxBuyableForPurchase(purchaseData)
    if not purchaseData or not purchaseData.storeIndex then
        return 0
    end

    local affordable = GetAffordableCount(
        purchaseData.storeIndex,
        purchaseData.price,
        purchaseData.currencyType1,
        purchaseData.currencyQuantity1,
        purchaseData.currencyType2,
        purchaseData.currencyQuantity2
    )
    if affordable <= 0 then
        return 0
    end

    local carryable = GetCarryCapacity(
        purchaseData.itemLink,
        purchaseData.itemId,
        purchaseData.entryType,
        affordable
    )

    return math.min(affordable, carryable)
end

function BB:DoPurchase(purchaseData)
    if not purchaseData or type(BuyStoreItem) ~= "function" then
        return
    end

    local quantity = math.min(
        ClampNonNegativeInteger(purchaseData.quantity),
        BB:GetMaxBuyableForPurchase(purchaseData)
    )

    if quantity <= 0 then
        Msg("|cFF3333Purchase cancelled: the quantity is no longer available.|r")
        return
    end

    BuyStoreItem(purchaseData.storeIndex, quantity)
    Msg(string.format("Purchase requested: x%d %s.", quantity, purchaseData.itemName or "item"))

    zo_callLater(function()
        BB:RefreshKeybind()
    end, 250)
end

function BB:RegisterDialog()
    ZO_Dialogs_RegisterCustomDialog(DIALOG_NAME, {
        canQueue = true,
        gamepadInfo = {
            dialogType = GAMEPAD_DIALOGS.BASIC,
        },
        title = {
            text = "Bulk Purchase",
        },
        mainText = {
            text = "Buy <<1>> x<<2>>?",
        },
        buttons = {
            {
                keybind = "DIALOG_PRIMARY",
                text = SI_DIALOG_ACCEPT,
                clickSound = SOUNDS.DIALOG_ACCEPT,
                callback = function(dialog)
                    BB:DoPurchase(dialog and dialog.data)
                end,
            },
            {
                keybind = "DIALOG_NEGATIVE",
                text = SI_DIALOG_CANCEL,
                clickSound = SOUNDS.DIALOG_DECLINE,
            },
        },
        mustChoose = true,
    })
end

function BB:BuildKeybindDescriptor()
    if BB.keybindDescriptor then
        return BB.keybindDescriptor
    end

    BB.keybindDescriptor = {
        alignment = KEYBIND_STRIP_ALIGN_RIGHT,
        {
            name = function()
                return zo_strformat(
                    "Bulk Buy <<1>> x<<2>>",
                    BB.targetItemName or "Item",
                    BB:GetMaxBuyable()
                )
            end,
            keybind = "UI_SHORTCUT_SECONDARY",
            callback = function()
                BB:AttemptBulkBuy()
            end,
            visible = function()
                return BB.targetStoreIndex ~= nil and BB:GetMaxBuyable() >= 2
            end,
        },
    }

    return BB.keybindDescriptor
end

function BB:AddKeybindToStrip()
    if not BB.keybindAdded then
        KEYBIND_STRIP:AddKeybindButtonGroup(BB:BuildKeybindDescriptor())
        BB.keybindAdded = true
    end
end

function BB:RefreshKeybind()
    if BB.keybindAdded and BB.keybindDescriptor then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(BB.keybindDescriptor)
    end
end

function BB:RemoveKeybindFromStrip()
    if BB.keybindAdded and BB.keybindDescriptor then
        KEYBIND_STRIP:RemoveKeybindButtonGroup(BB.keybindDescriptor)
        BB.keybindAdded = false
    end
end

function BB:OnSceneStateChange(_, newState)
    if newState == SCENE_SHOWN then
        -- The selection hook supplies the current row. A short refresh handles
        -- cases where the initial selection was established before scene shown.
        BB:AddKeybindToStrip()
        zo_callLater(function()
            BB:RefreshKeybind()
        end, 100)
    elseif newState == SCENE_HIDING or newState == SCENE_HIDDEN then
        BB:RemoveKeybindFromStrip()
        BB:ClearTarget()
    end
end

function BB:HookScene()
    if BB.sceneHooked then
        return
    end

    local vendorScene = SCENE_MANAGER:GetScene("gamepad_store")
    if not vendorScene then
        Msg("|cFF3333Could not find the gamepad vendor scene.|r")
        return
    end

    BB.sceneHooked = true
    vendorScene:RegisterCallback("StateChange", function(oldState, newState)
        BB:OnSceneStateChange(oldState, newState)
    end)
end

function BB:RegisterSlashCommands()
    SLASH_COMMANDS["/bbconfirm"] = function(text)
        text = zo_strlower(zo_strtrim(text or ""))

        if text == "on" or text == "true" or text == "1" then
            BB.savedVars.confirmBeforeBuy = true
        elseif text == "off" or text == "false" or text == "0" then
            BB.savedVars.confirmBeforeBuy = false
        else
            Msg("Usage: /bbconfirm on|off")
            return
        end

        Msg("Confirmation is now " .. (BB.savedVars.confirmBeforeBuy and "on" or "off") .. ".")
    end
end

EVENT_MANAGER:RegisterForEvent(BB.name, EVENT_ADD_ON_LOADED, function(eventCode, loadedName)
    BB:OnAddOnLoaded(eventCode, loadedName)
end)
