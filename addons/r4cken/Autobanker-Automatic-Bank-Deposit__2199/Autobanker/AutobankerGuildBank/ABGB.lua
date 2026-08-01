-- Create the global namespace for the addon
AutobankerGuildBank = AutobankerGuildBank or {}

-- Create a local shortcut for global
local ABGB = AutobankerGuildBank

-- AddOn information
ABGB.name = "AutobankerGuildBank"
ABGB.prefix = "ABGB"
ABGB.version = "2.1"
ABGB.author = "Muffins714"

-- menu actually reads values from this directly via the dflt
local defaults = ABGB.DefaultSettings.guildProfiles["default"]

--------------------------------------------
-- Guild Bank
--------------------------------------------
-- Settings
function ABGB.GetAccountSettings()
    if ABGB.SavedVars and ABGB.SavedVars.useGlobalSettings then
        return ABGB.GlobalSavedVars
    end
    return ABGB.SavedVars or {}
end

-- Recursively adds new template keys to old profiles without overwriting existing user choices
local function ABGB_FillMissingKeys(target, template)
    for k, v in pairs(template) do
        if type(v) == "table" then
            if type(target[k]) ~= "table" then
                target[k] = {}
            end
            ABGB_FillMissingKeys(target[k], v)
        elseif target[k] == nil then
            target[k] = v
        end
    end
end

function ABGB.GetProfile(guildId)
    if not guildId then return nil end
    local account = ABGB.GetAccountSettings()
    if not account.guildProfiles then
        account.guildProfiles = {}
    end
    local key = tostring(guildId)
    if not account.guildProfiles[key] then
        --For brand new guild, everything off
        account.guildProfiles[key] = ZO_DeepTableCopy(ABGB.DefaultSettings.guildProfiles["default"])
    end
    -- Backfills newly added keys into older profiles to prevent nil table errors in the menu
    ABGB_FillMissingKeys(account.guildProfiles[key], ABGB.DefaultSettings.guildProfiles["default"])

    return account.guildProfiles[key]
end

-- Returns the first real guild ID as a string pr nil if no guilds
function ABGB.GetFirstGuildId()
    if GetNumGuilds() > 0 then
        return tostring(GetGuildId(1))
    end
    return nil
end

-- Returns the active profile
function ABGB.GetSettings()
    if IsGuildBankOpen() then
        return ABGB.GetProfile(GetSelectedGuildBankId())
    end
    local account = ABGB.GetAccountSettings()
    local guildId = account.editProfileId
    if not guildId or guildId == "default" then
        guildId = ABGB.GetFirstGuildId()
    end
    return ABGB.GetProfile(guildId)
end

-- Notifications
function ABGB.ShouldNotify()
    local account = ABGB.GetAccountSettings()
    return account.notifications and
        (account.notifications.deposit or
            account.notifications.amount)
end

-- Switched to include account wide and removed IsItemCharacterBound
function ABGB.FilterUnwantedItems(itemData)
    local isStolen = itemData.stolen
    local isJunk = itemData.isJunk
    local isProtected = itemData.isPlayerLocked
    local isBoPTrade = itemData.isBoPTradeable
    local isBound = IsItemBound(itemData.bagId, itemData.slotIndex)

    if isStolen then return false end
    if isJunk then return false end
    if isProtected then return false end
    if isBoPTrade then return false end
    if isBound then return false end
    return true
end

-- Checks conditions in Autobanker Guild Bank settings and deposits if they are met
local specializedTypeSettingsMap = {

    [SPECIALIZED_ITEMTYPE_TROPHY_TREASURE_MAP]                      = "shouldDepositTreasureMap",
    [SPECIALIZED_ITEMTYPE_TROPHY_RECIPE_FRAGMENT]                   = "shouldDepositRecipeFragment",
    [SPECIALIZED_ITEMTYPE_TROPHY_RUNEBOX_FRAGMENT]                  = "shouldDepositRuneboxFragment",
    [SPECIALIZED_ITEMTYPE_RACIAL_STYLE_MOTIF_BOOK]                  = "shouldDepositMotifBook",
    [SPECIALIZED_ITEMTYPE_RACIAL_STYLE_MOTIF_CHAPTER]               = "shouldDepositMotifChapter",
    [SPECIALIZED_ITEMTYPE_COLLECTIBLE_STYLE_PAGE]                   = "shouldDepositStylePage",
    -- Furnishing Recipes
    [SPECIALIZED_ITEMTYPE_RECIPE_ALCHEMY_FORMULA_FURNISHING]        = "shouldDepositFurnishingRecipe",
    [SPECIALIZED_ITEMTYPE_RECIPE_BLACKSMITHING_DIAGRAM_FURNISHING]  = "shouldDepositFurnishingRecipe",
    [SPECIALIZED_ITEMTYPE_RECIPE_CLOTHIER_PATTERN_FURNISHING]       = "shouldDepositFurnishingRecipe",
    [SPECIALIZED_ITEMTYPE_RECIPE_ENCHANTING_SCHEMATIC_FURNISHING]   = "shouldDepositFurnishingRecipe",
    [SPECIALIZED_ITEMTYPE_RECIPE_JEWELRYCRAFTING_SKETCH_FURNISHING] = "shouldDepositFurnishingRecipe",
    [SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_DESIGN_FURNISHING]    = "shouldDepositFurnishingRecipe",
    [SPECIALIZED_ITEMTYPE_RECIPE_WOODWORKING_BLUEPRINT_FURNISHING]  = "shouldDepositFurnishingRecipe",
    -- Provisioning Recipes
    [SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_FOOD]        = "shouldDepositProvisioningRecipe",
    [SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_DRINK]       = "shouldDepositProvisioningRecipe",
}

function ABGB.IsItemRightType(itemType, specializedItemType, settings)
    if not settings then return false end
    if settings.typesToDeposit and settings.typesToDeposit[itemType] then
        return true
    end
    if specializedTypeSettingsMap and specializedItemType then
        local specializedSettingKey =
            specializedTypeSettingsMap[specializedItemType]
        if specializedSettingKey and settings[specializedSettingKey] then
            return true
        end
    end
    return false
end

function ABGB.ItemMeetsConditions(bagId, slotIndex, itemType, specializedItemType, itemTrait, itemLink)
    local settings = ABGB.GetSettings()
    if not settings then return false end
    local itemId = GetItemLinkItemId(itemLink)
    if settings.itemIdsToDeposit and settings.itemIdsToDeposit[itemId] then
        return true
    end
    if ABGB.IsItemRightType(itemType, specializedItemType, settings) then
        return true
    end
    if settings.shouldDepositIntricate and settings.intricateType and
        settings.intricateType[itemTrait] then
        return true
    end
    if ABGB.IsSoulGemToDeposit(bagId, slotIndex, itemType, settings) then
        return true
    end

    if ABGB.IsRepairKitToDeposit(bagId, slotIndex, settings) then
        return true
    end
    return false
end

function ABGB.IsRepairKitToDeposit(bagId, slotIndex, settings)
    if settings.depositRepairKits and IsItemRepairKit(bagId, slotIndex) then
        return true
    end
    return false
end

function ABGB.IsSoulGemToDeposit(bagId, slotIndex, itemType, settings)
    if itemType ~= ITEMTYPE_SOUL_GEM then return false end
    if settings.depositFilledSoulGems and IsItemSoulGem(SOUL_GEM_TYPE_FILLED, bagId, slotIndex) then
        return true
    end
    if settings.depositEmptySoulGems and IsItemSoulGem(SOUL_GEM_TYPE_EMPTY, bagId, slotIndex) then
        return true
    end
    return false
end

function ABGB.ExecuteCurrencyDeposit()
    local settings = ABGB.GetSettings()
    local currency = settings.CURRENCY_DATA[CURT_MONEY]
    if not currency.deposit then return end
    local currentGold = GetCurrencyAmount(CURT_MONEY,
        CURRENCY_LOCATION_CHARACTER)

    local targetDeposit = currency.depositAmount or 0

    -- Cap so it doesn't try to deposit more than we have
    local amountToDeposit = (targetDeposit > currentGold) and currentGold or targetDeposit
    if amountToDeposit > 0 then
        if IsProtectedFunction("TransferCurrency") then
            CallSecureProtected("TransferCurrency", CURT_MONEY, amountToDeposit,
                CURRENCY_LOCATION_CHARACTER,
                CURRENCY_LOCATION_GUILD_BANK)
        else
            TransferCurrency(CURT_MONEY, amountToDeposit,
                CURRENCY_LOCATION_CHARACTER,
                CURRENCY_LOCATION_GUILD_BANK)
        end
        if ABGB.ShouldNotify() then
            local goldIcon = ZO_Currency_GetPlatformFormattedGoldIcon()
            ABGB.Print(GetString(ABGB_CURRENCY_DEPOSIT_FORMAT)
                .. ZO_CommaDelimitNumber(amountToDeposit)
                .. " " .. goldIcon)
        end
    end
end

-- Helper function to print branded messages to the chat
local autobankerguildbankInitializeColor = "EFFBBE"
function ABGB.Print(message) CHAT_SYSTEM:AddMessage(message) end

ABGB.TransferQueue = {}
ABGB.ItemsMovedThisRun = 0

-- TRANSFER QUEUE & EXECUTION
function ABGB.ProcessNextGuildBankTransfer()
    if not IsGuildBankOpen() then return end
    if #ABGB.TransferQueue == 0 then
        ABGB.isTransferring = false
        if ABGB.ItemsMovedThisRun > 0 and ABGB.ShouldNotify() then
            local account = ABGB.GetAccountSettings()
            if account.notifications and account.notifications.deposit then
                ABGB.Print(zo_strformat(GetString(ABGB_TRANSFER_FORMAT), ABGB.ItemsMovedThisRun))
            end
        end
        ABGB.ItemsMovedThisRun = 0
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, GetString(ABGB_TRANSFER_FINISHED)) -- ALWAYS show on screen. If you guys want to comment it out you can but I hardcoded since people think it's not working. -Muffins714
        return
    end
    local itemData = table.remove(ABGB.TransferQueue, 1)
    local itemLink = GetItemLink(BAG_BACKPACK, itemData.slot)
    if itemLink == "" then
        ABGB.ProcessNextGuildBankTransfer()
        return
    end
    -- mark a transfer as in bound and stamp it with a unique token
    ABGB.isTransferring = true
    ABGB.transferToken = ABGB.transferToken + 1
    local myToken = ABGB.transferToken
    if IsProtectedFunction("TransferToGuildBank") then
        CallSecureProtected("TransferToGuildBank", BAG_BACKPACK, itemData.slot)
    else
        TransferToGuildBank(BAG_BACKPACK, itemData.slot)
    end

    -- ALWAYS count what actually moved, regardless of notification settings
    ABGB.ItemsMovedThisRun = ABGB.ItemsMovedThisRun + itemData.count

    -- separate decide what to print.
    if ABGB.ShouldNotify() then
        local account = ABGB.GetAccountSettings()
        local showAmount = account.notifications and account.notifications.amount
        if showAmount then
            ABGB.Print(zo_strformat(GetString(ABGB_TRANSACTION_FORMAT), itemLink, itemData.count))
        end
    end

    -- 3 sec watchdog skips dropped server confirmation by using incremented tokens to safely ignore late responses
    zo_callLater(function()
        if ABGB.transferToken == myToken and ABGB.isTransferring then
            ABGB.isTransferring = false
            ABGB.ProcessNextGuildBankTransfer()
        end
    end, 3000)
end

-- server confirmation triggers the next deposit preventing timed queue disconnects
function ABGB.OnGuildBankItemAdded(eventCode, slotId, addedByLocalPlayer, soundCategory, isLastUpdateForMessage)
    if not addedByLocalPlayer then return end
    if not isLastUpdateForMessage then return end
    if not ABGB.isTransferring then return end
    ABGB.isTransferring = false
    ABGB.ProcessNextGuildBankTransfer()
end

-- Fires when the server rejects a guild bank transfer like full, no permission, etc.
function ABGB.OnGuildBankTransferError(eventCode, reason)
    if reason == GUILD_BANK_NO_SPACE_LEFT
        or reason == GUILD_BANK_NO_DEPOSIT_PERMISSION
        or reason == GUILD_BANK_GUILD_TOO_SMALL then
        ABGB.TransferQueue = {}
    end
end

-- Scan the backpack and builds the transfer queue
function ABGB.TriggerAutobankerGuildBank()
    local bankingBag = GetBankingBag()

    -- Block depositing into Furniture Vault and Housing Coffers
    if IsFurnitureVault(bankingBag) then return end
    if IsHouseBankBag(bankingBag) then return end

    if not IsGuildBankOpen() then return end

    -- Per guild master switch if this guild is disabled do nothing.
    local profile = ABGB.GetSettings()
    if not profile or not profile.enabled then
        if ABGB.ShouldNotify() then
            ABGB.Print(GetString(ABGB_GUILD_DISABLED))
        end
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, GetString(ABGB_GUILD_DISABLED)) -- ALWAYS show on screen. If you guys want to comment it out you can but I hardcoded since people think it's not working. -Muffins714

        return
    end

    ABGB.ExecuteCurrencyDeposit()

    local bagCache = SHARED_INVENTORY:GenerateFullSlotData(ABGB.FilterUnwantedItems, BAG_BACKPACK)
    ABGB.TransferQueue = {}
    ABGB.ItemsMovedThisRun = 0
    ABGB.isTransferring = false
    ABGB.transferToken = 0

    local queueCount = 0

    for _, data in pairs(bagCache) do
        if queueCount >= 50 then break end
        local itemLink = GetItemLink(BAG_BACKPACK, data.slotIndex)
        local itemType, specializedItemType = GetItemType(BAG_BACKPACK, data.slotIndex)
        local itemTrait = GetItemTrait(BAG_BACKPACK, data.slotIndex)

        if ABGB.ItemMeetsConditions(BAG_BACKPACK, data.slotIndex, itemType, specializedItemType, itemTrait, itemLink) then
            table.insert(ABGB.TransferQueue, { slot = data.slotIndex, count = data.stackCount })
            queueCount = queueCount + 1
        end
    end

    if #ABGB.TransferQueue > 0 then
        zo_callLater(ABGB.ProcessNextGuildBankTransfer, 100)
    else
        if ABGB.ShouldNotify() then
            ABGB.Print(GetString(ABGB_NO_ELIGIBLE))
        end
    end
end

-- PLAYER ACTIVATION
local function OnPlayerActivated()
    EVENT_MANAGER:UnregisterForEvent(ABGB.name, EVENT_PLAYER_ACTIVATED)
    ABGB.CreateSettingsMenu()
    -- Branded initialization message
    ABGB.Print(zo_strformat("|c<<1>><<2>>|r", autobankerguildbankInitializeColor, GetString(ABGB_INIT)))
end


-- KEYBINDING & BUTTON STRIP
local keybindDescriptor

local function InitializeKeybindStrip()
    keybindDescriptor = {
        alignment = IsInGamepadPreferredMode() and KEYBIND_STRIP_ALIGN_LEFT or
            KEYBIND_STRIP_ALIGN_CENTER,
        {
            name = GetString(ABGB_KEYBIND_NAME),
            keybind = "AUTO_DEPOSIT",
            callback = function() ABGB.TriggerAutobankerGuildBank() end,
            visible = function() return IsGuildBankOpen() end
        }
    }
end

local function OnOpenGuildBank()
    local guildId = GetSelectedGuildBankId()
    if guildId and guildId ~= 0 then
        -- Opening a bank never changes which guild settings menu you are editing
        local profile = ABGB.GetProfile(guildId)
        local account = ABGB.GetAccountSettings()

        if account.autoMode and profile.enabled and not ABGB.autoFiredThisOpen then
            ABGB.autoFiredThisOpen = true
            zo_callLater(function()
                if IsGuildBankOpen() then
                    ABGB.TriggerAutobankerGuildBank()
                end
            end, 500)
        end
    end

    if not KEYBIND_STRIP:HasKeybindButtonGroup(keybindDescriptor) then
        KEYBIND_STRIP:AddKeybindButtonGroup(keybindDescriptor)
    end
end

local function OnCloseGuildBank()
    if KEYBIND_STRIP:HasKeybindButtonGroup(keybindDescriptor) then
        KEYBIND_STRIP:RemoveKeybindButtonGroup(keybindDescriptor)
        ABGB.autoFiredThisOpen = false
    end
end

-- ADDON INITIALIZATION
local function OnAddOnLoaded(event, addon)
    if addon ~= ABGB.name then return end
    EVENT_MANAGER:UnregisterForEvent(ABGB.name, EVENT_ADD_ON_LOADED)
    -- Load saved variables for account wide and character
    ABGB.GlobalSavedVars = ZO_SavedVars:NewAccountWide("AutobankerGBGlobalSavedVars", 2, nil, ABGB.DefaultSettings,
        GetWorldName())
    ABGB.SavedVars = ZO_SavedVars:NewCharacterIdSettings("AutobankerGBSavedVars", 2, nil, ABGB.DefaultSettings,
        GetWorldName())

    -- Default to account-wide settings
    if ABGB.GlobalSavedVars.useGlobalSettings == nil then
        ABGB.GlobalSavedVars.useGlobalSettings = true
    end
    if ABGB.GlobalSavedVars.useGlobalSettings then
        ABGB.SavedVars = ABGB.GlobalSavedVars
    end
    InitializeKeybindStrip()
    ZO_CreateStringId("SI_BINDING_NAME_AUTO_DEPOSIT", GetString(ABGB_KEYBIND_NAME))

    -- RegisterForEvent
    EVENT_MANAGER:RegisterForEvent(ABGB.name, EVENT_GUILD_BANK_ITEM_ADDED, ABGB.OnGuildBankItemAdded)
    EVENT_MANAGER:RegisterForEvent(ABGB.name, EVENT_GUILD_BANK_TRANSFER_ERROR, ABGB.OnGuildBankTransferError)
    EVENT_MANAGER:RegisterForEvent(ABGB.name, EVENT_OPEN_GUILD_BANK, OnOpenGuildBank)
    EVENT_MANAGER:RegisterForEvent(ABGB.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
    EVENT_MANAGER:RegisterForEvent(ABGB.name, EVENT_GUILD_BANK_SELECTED, OnOpenGuildBank)
    EVENT_MANAGER:RegisterForEvent(ABGB.name, EVENT_CLOSE_GUILD_BANK, OnCloseGuildBank)
end

-- Register for the loading of our addon
EVENT_MANAGER:RegisterForEvent(ABGB.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
