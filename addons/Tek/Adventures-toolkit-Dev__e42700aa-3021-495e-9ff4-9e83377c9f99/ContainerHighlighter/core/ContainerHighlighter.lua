-- ============================================
-- MAIN INITIALIZATION & EVENT HANDLER
-- ============================================

-- Current savedVars schema version - increment when making breaking changes
local SAVED_VARS_VERSION = 2

-- Valid top-level keys in current schema (anything not in this list gets removed)
local VALID_SAVED_VAR_KEYS = {
    -- Schema tracking
    "savedVarsVersion",
    -- Feature flags
    "features",
    -- Net Worth settings
    "includeBank", "includeCraftBag", "includeFurnitureVault", "includeMyHousing",
    "includeCrownsAsGold", "crownToGoldRate", "lastFurnitureVaultValue",
    "myHousingValues", "myHousingCrownValues", "myHousingWVValues",
    "guildBankValues", "enabledGuildBanks", "savedTopItems", "furnitureCache",
    -- GST settings
    "gstGuildNames", "gstGuildEnabled", "gstGuildSnapshots", "gstCurrentGuild",
    -- Fishing
    "fishingEnabled", "fishingSessionFish", "fishingSessionStart",
    "fishingTotalFish", "fishingSessionRare", "fishingSessionPerfect",
    -- Housing
    "housingHudEnabled", "housingStats", "wishlist", "knownPlans",
    -- Plan Browser
    "planBrowser",
    -- Bookkeeper
    "bookkeeper",
    -- Gold Ledger
    "goldLedger",
    -- Loot Log
    "lootLog",
    -- Loot Radar
    "lootRadar",
    -- Debug
    "debugMode",
}

-- Build lookup table for fast checking
local VALID_KEYS_LOOKUP = {}
for _, key in ipairs(VALID_SAVED_VAR_KEYS) do
    VALID_KEYS_LOOKUP[key] = true
end

-- Migrate and clean up savedVars from older versions
local function MigrateSavedVars(sv)
    if not sv then return end
    
    local currentVersion = sv.savedVarsVersion or 0
    local cleanedCount = 0
    
    -- Remove any keys that aren't in our valid list (old/deprecated keys)
    for key, _ in pairs(sv) do
        if not VALID_KEYS_LOOKUP[key] then
            sv[key] = nil
            cleanedCount = cleanedCount + 1
        end
    end
    
    -- Version-specific migrations
    if currentVersion < 1 then
        -- v1: Initial cleanup - remove old session data that shouldn't be persisted
        sv.gstSales = nil
        sv.gstGuildSellers = nil
        sv.gstGuildItems = nil
        sv.gstItemCategories = nil
        sv.gstPriceAlerts = nil
        sv.planIconCache = nil
        sv.gstCumulative = nil
    end
    
    if currentVersion < 2 then
        -- v2: Clean up bookkeeper corrupted data
        if sv.bookkeeper then
            -- Clear potentially corrupted noteUpdates
            if type(sv.bookkeeper.noteUpdates) ~= "table" then
                sv.bookkeeper.noteUpdates = {}
            end
            -- Validate guild settings
            if type(sv.bookkeeper.guilds) == "table" then
                for guildId, gs in pairs(sv.bookkeeper.guilds) do
                    if type(gs) ~= "table" then
                        sv.bookkeeper.guilds[guildId] = nil
                    else
                        -- Clear corrupted payment data
                        if gs.memberPayments and type(gs.memberPayments) ~= "table" then
                            gs.memberPayments = {}
                        end
                        if gs.paymentHistory and type(gs.paymentHistory) ~= "table" then
                            gs.paymentHistory = {}
                        end
                    end
                end
            end
        end
    end
    
    -- Update version stamp
    sv.savedVarsVersion = SAVED_VARS_VERSION
end

-- Validate and repair critical savedVars structures to prevent crashes
local function ValidateSavedVars(sv)
    if not sv then return end
    -- Ensure features table exists and is a table
    if type(sv.features) ~= "table" then sv.features = {} end
    -- Ensure bookkeeper table exists and is a table
    if type(sv.bookkeeper) ~= "table" then sv.bookkeeper = {} end
    if type(sv.bookkeeper.guilds) ~= "table" then sv.bookkeeper.guilds = {} end
    if type(sv.bookkeeper.noteUpdates) ~= "table" then sv.bookkeeper.noteUpdates = {} end
    -- Ensure other critical tables exist
    if type(sv.guildBankValues) ~= "table" then sv.guildBankValues = {} end
    if type(sv.savedTopItems) ~= "table" then sv.savedTopItems = {} end
    if type(sv.myHousingValues) ~= "table" then sv.myHousingValues = {} end
    if type(sv.wishlist) ~= "table" then sv.wishlist = { projects = { ["Default"] = {} }, activeProject = "Default" } end
    if type(sv.goldLedger) ~= "table" then sv.goldLedger = NWT.defaults.goldLedger end
    if type(sv.lootLog) ~= "table" then sv.lootLog = NWT.defaults.lootLog end
    -- Migrate old session-based lootLog to new daily-based structure
    if sv.lootLog and sv.lootLog.session and not sv.lootLog.today then
        sv.lootLog.today = { items = {}, goldLooted = 0, totalValue = 0, itemCount = 0 }
        sv.lootLog.lastResetTimestamp = GetTimeStamp()
        sv.lootLog.session = nil
    end
    if sv.lootLog and not sv.lootLog.today then
        sv.lootLog.today = { items = {}, goldLooted = 0, totalValue = 0, itemCount = 0 }
        sv.lootLog.lastResetTimestamp = 0
    end
    if type(sv.lootRadar) ~= "table" then sv.lootRadar = NWT.defaults.lootRadar end
end

local function OnAddonLoaded(eventCode, addonName)
    if addonName ~= NWT.name then return end
    EVENT_MANAGER:UnregisterForEvent(NWT.name, EVENT_ADD_ON_LOADED)
    
    -- Load Saved Variables with pcall to catch any load errors
    local loadSuccess, loadError = pcall(function()
        NWT.savedVars = ZO_SavedVars:NewAccountWide("NetWorthTracker_Data", 1, nil, NWT.defaults)
    end)
    
    if not loadSuccess or not NWT.savedVars then
        NWT.savedVars = ZO_DeepTableCopy(NWT.defaults)
    end
    
    -- Validate and repair any corrupted structures
    ValidateSavedVars(NWT.savedVars)
    
    -- Run migrations to clean up old/deprecated savedVars
    MigrateSavedVars(NWT.savedVars)
    
    -- Initialize Session Data (never persisted)
    NWT.sessionData = {
        gstSales = {},
        gstGuildSellers = {},
        gstGuildItems = {},
        gstItemCategories = {},
        gstPriceAlerts = {},
        planIconCache = {},
    }
    
    -- Authorization Check
    NWT.CheckAuthorization()
    
    -- Helper to check if feature is enabled (with defensive access)
    local function IsEnabled(feature)
        if type(NWT.savedVars.features) ~= "table" then return true end
        return NWT.savedVars.features[feature] ~= false
    end
    
    -- Initialize Net Worth
    if IsEnabled("netWorth") then
        SLASH_COMMANDS["/nw"] = function(args)
            local cmd = args and args:lower():match("^%s*(%S*)") or ""
            if cmd == "clear" then
                NWT.savedVars.savedTopItems = {}
                NWT.savedVars.myHousingValues = {}
                NWT.savedVars.myHousingCrownValues = {}
                NWT.savedVars.myHousingWVValues = {}
            else
                NWT.ShowNetWorthInChat()
            end
        end
        if NWT.hookGamepadTooltips then NWT.hookGamepadTooltips() end
        EVENT_MANAGER:RegisterForEvent(NWT.name .. "_NetWorth", EVENT_PLAYER_ACTIVATED, function()
            NWT.CalculateNetWorth()
            NWT.initialized = true
        end)
        EVENT_MANAGER:RegisterForEvent(NWT.name .. "_GuildBank", EVENT_GUILD_BANK_ITEMS_READY, function()
            if not IsGuildBankOpen() then return end
            local gId = GetSelectedGuildBankId()
            if gId then
                NWT.savedVars.guildBankValues[gId] = NWT.ScanGuildBank()
            end
        end)
    end
    
    -- Authorized Features
    if NWT.isAuthorized then
        if IsEnabled("guildSalesTracker") then
            SLASH_COMMANDS["/gst"] = function(args) if NWT.GSTCommand then NWT.GSTCommand(args) end end
            NWT.InitGuildSalesTracker()
        end
        
        if IsEnabled("housingDashboard") then
            SLASH_COMMANDS["/nwf"] = function(args) if NWT.FurnitureFinderCommand then NWT.FurnitureFinderCommand(args) end end
            EVENT_MANAGER:RegisterForEvent(NWT.name .. "_Housing", EVENT_PLAYER_ACTIVATED, NWT.OnPlayerActivatedHousing)
            EVENT_MANAGER:RegisterForEvent(NWT.name .. "_HousingHUDLayerPush", EVENT_ACTION_LAYER_PUSHED, function() NWT.UpdateHousingLimitUI() end)
            EVENT_MANAGER:RegisterForEvent(NWT.name .. "_HousingHUDLayerPop", EVENT_ACTION_LAYER_POPPED, function() NWT.UpdateHousingLimitUI() end)
            if NWT.SetupHousingWishlistKeybinds then NWT.SetupHousingWishlistKeybinds() end
            if NWT.InitCrownCapture then NWT.InitCrownCapture() end
            if NWT.SetupCrownCaptureKeybinds then NWT.SetupCrownCaptureKeybinds() end
        end
        
        if IsEnabled("planBrowser") then
            SLASH_COMMANDS["/pb"] = function() NWT.OpenPlanBrowser() end
            SLASH_COMMANDS["/plans"] = SLASH_COMMANDS["/pb"]
            SLASH_COMMANDS["/planbrowser"] = SLASH_COMMANDS["/pb"]
            NWT.InitPlanBrowser()
        end
        
        if IsEnabled("housingDashboard") then
            SLASH_COMMANDS["/planner"] = function() NWT.OpenPlanner() end
        end
        
        if IsEnabled("goldLedger") then
            EVENT_MANAGER:RegisterForEvent(NWT.name .. "_GoldLedger", EVENT_MONEY_UPDATE, NWT.OnMoneyUpdate)
            EVENT_MANAGER:RegisterForEvent(NWT.name .. "_GoldLedgerPurchase", EVENT_TRADING_HOUSE_CONFIRM_ITEM_PURCHASE, NWT.OnTradingHouseConfirmPendingPurchase)
            -- Trade partner tracking for player-to-player trades
            EVENT_MANAGER:RegisterForEvent(NWT.name .. "_TradeInviteConsidering", EVENT_TRADE_INVITE_CONSIDERING, NWT.OnTradeInviteConsidering)
            EVENT_MANAGER:RegisterForEvent(NWT.name .. "_TradeInviteWaiting", EVENT_TRADE_INVITE_WAITING, NWT.OnTradeInviteWaiting)
            EVENT_MANAGER:RegisterForEvent(NWT.name .. "_TradeCanceled", EVENT_TRADE_CANCELED, NWT.OnTradeCanceled)
            EVENT_MANAGER:RegisterForEvent(NWT.name .. "_TradeInviteDeclined", EVENT_TRADE_INVITE_DECLINED, NWT.OnTradeInviteDeclined)
            EVENT_MANAGER:RegisterForEvent(NWT.name .. "_TradeInviteCanceled", EVENT_TRADE_INVITE_CANCELED, NWT.OnTradeInviteCanceled)
            -- Guild sale item name tracking from mail
            EVENT_MANAGER:RegisterForEvent(NWT.name .. "_MailTakeMoney", EVENT_MAIL_TAKE_ATTACHED_MONEY_SUCCESS, NWT.OnMailTakeAttachedMoneySuccess)
        end
        
        if IsEnabled("lootLog") then
            NWT.CheckLootLogDailyReset()
            EVENT_MANAGER:RegisterForEvent(NWT.name .. "_LootLog", EVENT_LOOT_RECEIVED, NWT.OnLootReceivedForLog)
            EVENT_MANAGER:RegisterForEvent(NWT.name .. "_LootLogGold", EVENT_MONEY_UPDATE, NWT.OnLootGoldForLog)
            EVENT_MANAGER:RegisterForEvent(NWT.name .. "_LootLogMail", EVENT_MAIL_TAKE_ATTACHED_ITEM_SUCCESS, NWT.OnMailItemTakenForLog)
        end
        
        if IsEnabled("lootRadar") then
            EVENT_MANAGER:RegisterForEvent(NWT.name .. "_LootRadar", EVENT_RETICLE_TARGET_CHANGED, NWT.OnReticleTargetChanged)
            NWT.StartRadarUpdates()
        end
        
        if IsEnabled("fishingTracker") then
            NWT.savedVars.fishingEnabled = true  -- Enable fishing tracking
            EVENT_MANAGER:RegisterForEvent(NWT.name .. "_Fishing", EVENT_LOOT_RECEIVED, NWT.OnFishingLootReceived)
            EVENT_MANAGER:RegisterForEvent(NWT.name .. "_FishingInv", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, NWT.OnFishingInventoryUpdate)
            EVENT_MANAGER:RegisterForEvent(NWT.name .. "_FishingCast", EVENT_FISHING_LURE_SET, NWT.OnFishingLureSet)
            EVENT_MANAGER:RegisterForEvent(NWT.name .. "_FishingLayerPush", EVENT_ACTION_LAYER_PUSHED, NWT.OnActionLayerChanged)
            EVENT_MANAGER:RegisterForEvent(NWT.name .. "_FishingLayerPop", EVENT_ACTION_LAYER_POPPED, NWT.OnActionLayerChanged)
            NWT.StartFishingUIUpdates()
        end
        
        if IsEnabled("bookkeeper") then
            SLASH_COMMANDS["/bookkeeper"] = function() NWT.OpenBookkeeper() end
            SLASH_COMMANDS["/bk"] = SLASH_COMMANDS["/bookkeeper"]
            if NWT.SetupBookkeeperTradingHouseKeybinds then
                NWT.SetupBookkeeperTradingHouseKeybinds()
            end
        end
        
        if IsEnabled("raffle") then
            SLASH_COMMANDS["/raffle"] = function() NWT.OpenRaffle() end
            SLASH_COMMANDS["/rf"] = SLASH_COMMANDS["/raffle"]
        end
        
        if IsEnabled("pvpDashboard") then
            NWT.InitPVPData()
            NWT.RegisterPVPEvents()
            NWT.RegisterPVPSlashCommands()
        end
        
        -- Endless Archive Tracker
        if NWT.InitEndlessArchiveData then
            NWT.InitEndlessArchiveData()
            NWT.RegisterEndlessArchiveEvents()
        end
        
        -- Item Finder - auto-cache on login
        if NWT.InitItemFinderEvents then
            NWT.InitItemFinderEvents()
        end
        
        -- Bookkeeper - check for pending scan after reload
        if NWT.CheckPendingBookkeeperScan then
            NWT.CheckPendingBookkeeperScan()
        end
        
        NWT.CreateSettingsMenu()
    end
    
    -- Main Menu Integration (works on console AND PC gamepad mode)
    if IsConsoleUI() or IsInGamepadPreferredMode() then
        if NWT.AddCustomMenuEntry then NWT.AddCustomMenuEntry() end
    end
    
    -- Global Slash Commands
    SLASH_COMMANDS["/atk"] = function(args)
        local arg = string.lower(args or "")
        local featureMap = {
            ["networth"] = "netWorth", ["net"] = "netWorth", ["nw"] = "netWorth",
            ["guild"] = "guildSalesTracker", ["gst"] = "guildSalesTracker",
            ["plan"] = "planBrowser", ["plans"] = "planBrowser", ["pb"] = "planBrowser",
            ["housing"] = "housingDashboard", ["house"] = "housingDashboard",
            ["lootlog"] = "lootLog", ["loot"] = "lootLog",
            ["goldledger"] = "goldLedger", ["gold"] = "goldLedger", ["ledger"] = "goldLedger",
            ["fishing"] = "fishingTracker", ["fish"] = "fishingTracker",
            ["radar"] = "lootRadar", ["bookkeeper"] = "bookkeeper", ["bk"] = "bookkeeper",
            ["raffle"] = "raffle", ["rf"] = "raffle",
        }
        local key = featureMap[arg]
        if key then
            NWT.savedVars.features[key] = not (NWT.savedVars.features[key] ~= false)
        else
        end
    end
    
    SLASH_COMMANDS["/promote"] = function()
        local msg = "Try Adventurer's Toolkit! Net Worth, Guild Sales, Bookkeeper, Housing Dashboard, Plan Browser, Fishing Tracker & Loot Radar. Search 'Adventurer's Toolkit'!"
        CHAT_ROUTER:AddSystemMessage("|cFFD700[ATK]|r Sending promo...")
        StartChatInput(msg, CHAT_CHANNEL_ZONE)
    end
    
    SLASH_COMMANDS["/tmdebug"] = function()
        NWT.savedVars.debugMode = not NWT.savedVars.debugMode
    end
end

EVENT_MANAGER:RegisterForEvent(NWT.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
