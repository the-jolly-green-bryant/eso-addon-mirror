--[[
    Gotta Open 'em all!
    Automatically opens unidentified survey reports in your inventory.
]]--

local LAM2 = LibAddonMenu2

---------------------------------------------------------------------------
-- Addon table
---------------------------------------------------------------------------
GottaOpenEmAll = {
    name    = "GottaOpenEmAll",
    title   = "Gotta Open 'em all!",
    author  = "Paulo",
    version = "1.0.0",

    -- Known unidentified survey item IDs
    surveyIds = {
        [219849] = true, -- Unidentified Blacksmith Survey Report
        [219850] = true, -- Unidentified Clothier Survey Report
        [219851] = true, -- Unidentified Woodworker Survey Report
        [219852] = true, -- Unidentified Enchanter Survey Report
        [219853] = true, -- Unidentified Alchemist Survey Report
        [219854] = true, -- Unidentified Provisioner Survey Report
        [224707] = true, -- Sealed Survey Report Stack
    },

    containerItemTypes = {
        [ITEMTYPE_CONTAINER]           = true,
        [ITEMTYPE_CONTAINER_CURRENCY]  = true,
        [ITEMTYPE_CONTAINER_STACKABLE] = true,
    },

    state              = "stopped",
    queue              = {},
    containerSlots     = {},
    openedCount        = 0,
    lootReceived       = {},
    originalUpdateLoot = nil,
}

local addon = GottaOpenEmAll

---------------------------------------------------------------------------
-- Defaults
---------------------------------------------------------------------------
local defaults = {
    autoloot         = false,
    autolootDelay    = 2,
    reservedSlots    = 5,
    chatEnabled      = true,
    chatIcons        = true,
    chatSummary      = true,
    shortPrefix      = true,
}

---------------------------------------------------------------------------
-- Chat output
---------------------------------------------------------------------------
local function GetPrefix()
    if addon.settings.shortPrefix then
        return "|cFFCC00[GOEA]|r "
    else
        return "|cFFCC00[Gotta Open 'em all!]|r "
    end
end

function addon.Print(msg)
    if not addon.settings or not addon.settings.chatEnabled then return end
    d(GetPrefix() .. msg)
end

function addon.PrintAlways(msg)
    d(GetPrefix() .. msg)
end

---------------------------------------------------------------------------
-- Survey detection
---------------------------------------------------------------------------
function addon:IsSurveyItem(bagId, slotIndex)
    if bagId ~= BAG_BACKPACK then return false end

    local itemLink = GetItemLink(bagId, slotIndex)
    if not itemLink or itemLink == "" then return false end

    local itemId = GetItemLinkItemId(itemLink)
    if not self.surveyIds[itemId] then return false end

    local itemType = GetItemType(bagId, slotIndex)
    if not self.containerItemTypes[itemType] then return false end

    local usable, onlyFromActionSlot = IsItemUsable(bagId, slotIndex)
    if not usable or onlyFromActionSlot then return false end

    return true
end

function addon:IsSurveyLink(itemLink)
    if not itemLink then return false end
    local itemId = GetItemLinkItemId(itemLink)
    return self.surveyIds[itemId] == true
end

function addon:CountSurveysInBag()
    local count = 0
    for slotIndex, _ in pairs(self.containerSlots) do
        if self:IsSurveyItem(BAG_BACKPACK, slotIndex) then
            count = count + 1
        end
    end
    return count
end

---------------------------------------------------------------------------
-- Loot window suppression
---------------------------------------------------------------------------
local function SuppressLootWindow()
end

---------------------------------------------------------------------------
-- Box opening
---------------------------------------------------------------------------
function addon:OpenSingle(slotIndex)

    local itemLink = GetItemLink(BAG_BACKPACK, slotIndex)
    if not itemLink or itemLink == "" then
        self:OnOpenFailed(slotIndex)
        return
    end

    if IsLooting() then
        EVENT_MANAGER:RegisterForUpdate(self.name .. "_Retry", 1000, function()
            EVENT_MANAGER:UnregisterForUpdate(self.name .. "_Retry")
            self:OpenSingle(slotIndex)
        end)
        return true
    end

    local interactionType = GetInteractionType()
    if interactionType ~= 0 then
        EVENT_MANAGER:RegisterForUpdate(self.name .. "_Retry", 1000, function()
            EVENT_MANAGER:UnregisterForUpdate(self.name .. "_Retry")
            self:OpenSingle(slotIndex)
        end)
        return true
    end

    if not CanInteractWithItem(BAG_BACKPACK, slotIndex) then
        EVENT_MANAGER:RegisterForUpdate(self.name .. "_Retry", 1000, function()
            EVENT_MANAGER:UnregisterForUpdate(self.name .. "_Retry")
            self:OpenSingle(slotIndex)
        end)
        return true
    end

    local remaining, duration = GetItemCooldownInfo(BAG_BACKPACK, slotIndex)
    if remaining > 0 and duration > 0 then
        EVENT_MANAGER:RegisterForUpdate(self.name .. "_Retry", remaining + 50, function()
            EVENT_MANAGER:UnregisterForUpdate(self.name .. "_Retry")
            self:OpenSingle(slotIndex)
        end)
        return true
    end

    self:CleanupLootEvents()

    local itemType = GetItemType(BAG_BACKPACK, slotIndex)
    local isStackable = (itemType == ITEMTYPE_CONTAINER_STACKABLE)
    local stacks = GetSlotStackSize(BAG_BACKPACK, slotIndex)

    EVENT_MANAGER:RegisterForEvent(self.name .. "_LootReceived", EVENT_LOOT_RECEIVED,
        function(eventCode, receivedBy, lootItemLink, quantity, itemSound, lootType, lootedBySelf)
            table.insert(self.lootReceived, {
                itemLink     = lootItemLink,
                quantity     = quantity,
                lootType     = lootType,
                lootedBySelf = lootedBySelf,
            })
            if isStackable then
                self:CleanupLootEvents()
                self:OnOpenSuccess(slotIndex, itemLink)
                if stacks and stacks > 1 then
                    EVENT_MANAGER:RegisterForUpdate(self.name .. "_NextStack", 800, function()
                        EVENT_MANAGER:UnregisterForUpdate(self.name .. "_NextStack")
                        self:OpenSingle(slotIndex)
                    end)
                end
            end
        end)

    if not isStackable then
        EVENT_MANAGER:RegisterForEvent(self.name .. "_LootUpdated", EVENT_LOOT_UPDATED,
            function()
                EVENT_MANAGER:UnregisterForEvent(self.name .. "_LootUpdated", EVENT_LOOT_UPDATED)
                EVENT_MANAGER:RegisterForUpdate(self.name .. "_LootTimeout", 1000,
                    function()
                        EVENT_MANAGER:UnregisterForUpdate(self.name .. "_LootTimeout")
                        self:LootAllAndProceed(slotIndex, itemLink)
                    end)
                self:LootAllAndProceed(slotIndex, itemLink)
            end)

        EVENT_MANAGER:RegisterForEvent(self.name .. "_LootClosed", EVENT_LOOT_CLOSED,
            function()
                self:CleanupLootEvents()
                if self.originalUpdateLoot then
                    local lootWindow = SYSTEMS:GetObject("loot")
                    lootWindow.UpdateLootWindow = self.originalUpdateLoot
                    self.originalUpdateLoot = nil
                end
                self:OnOpenSuccess(slotIndex, itemLink)
            end)
    end

    if not self.originalUpdateLoot then
        local lootWindow = SYSTEMS:GetObject("loot")
        self.originalUpdateLoot = lootWindow.UpdateLootWindow
        lootWindow.UpdateLootWindow = SuppressLootWindow
    end

    if CallSecureProtected("UseItem", BAG_BACKPACK, slotIndex) then
        return true
    end

    self:CleanupLootEvents()
    if self.originalUpdateLoot then
        local lootWindow = SYSTEMS:GetObject("loot")
        lootWindow.UpdateLootWindow = self.originalUpdateLoot
        self.originalUpdateLoot = nil
    end
    PlaySound(SOUNDS.NEGATIVE_CLICK)
    self.Print(zo_strformat(GetString(SI_GOEA_FAILED), itemLink))
    self:OnOpenFailed(slotIndex)
end

function addon:LootAllAndProceed(slotIndex, itemLink)
    EVENT_MANAGER:UnregisterForUpdate(self.name .. "_LootTimeout")
    EVENT_MANAGER:UnregisterForEvent(self.name .. "_LootUpdated", EVENT_LOOT_UPDATED)

    local slotsNeeded = 0
    local autoCraftBag = GetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_ADD_TO_CRAFT_BAG) == "1" and HasCraftBagAccess()

    for lootIndex = 1, GetNumLootItems() do
        local lootId = GetLootItemInfo(lootIndex)
        local lootLink = GetLootItemLink(lootId)
        local lootItemType = GetLootItemType(lootId)
        if lootItemType == LOOT_TYPE_ITEM and (not autoCraftBag or not CanItemLinkBeVirtual(lootLink)) then
            slotsNeeded = slotsNeeded + 1
        end
    end

    if not CheckInventorySpaceAndWarn(slotsNeeded) then
        self.PrintAlways(GetString(SI_GOEA_NOT_ENOUGH_SPACE))
        self:CleanupLootEvents()
        if IsLooting() then EndLooting() end
        self:Stop()
        return
    end

    LOOT_SHARED:LootAllItems()
end

function addon:CleanupLootEvents()
    EVENT_MANAGER:UnregisterForUpdate(self.name .. "_Retry")
    EVENT_MANAGER:UnregisterForUpdate(self.name .. "_LootTimeout")
    EVENT_MANAGER:UnregisterForUpdate(self.name .. "_NextStack")
    EVENT_MANAGER:UnregisterForEvent(self.name .. "_LootReceived", EVENT_LOOT_RECEIVED)
    EVENT_MANAGER:UnregisterForEvent(self.name .. "_LootUpdated", EVENT_LOOT_UPDATED)
    EVENT_MANAGER:UnregisterForEvent(self.name .. "_LootClosed", EVENT_LOOT_CLOSED)
    if IsLooting() then EndLooting() end
end

function addon:OnOpenSuccess(slotIndex, itemLink)
    self.openedCount = self.openedCount + 1
    self.lootReceived = {}

    if self.settings.chatEnabled then
        local display = itemLink
        if self.settings.chatIcons then
            display = string.format("|t90%%:90%%:%s|t%s", GetItemLinkIcon(itemLink), itemLink)
        end
        self.Print(zo_strformat(GetString(SI_GOEA_OPENED), display))
    end

    self:ProcessNext()
end

function addon:OnOpenFailed(slotIndex)
    self:ProcessNext()
end

---------------------------------------------------------------------------
-- Queue management
---------------------------------------------------------------------------
function addon:QueueAllSurveys()
    self.queue = {}
    for slotIndex, _ in pairs(self.containerSlots) do
        if self:IsSurveyItem(BAG_BACKPACK, slotIndex)
           and CanInteractWithItem(BAG_BACKPACK, slotIndex)
           and select(4, GetItemInfo(BAG_BACKPACK, slotIndex))
        then
            table.insert(self.queue, {
                slotIndex = slotIndex,
                itemLink  = GetItemLink(BAG_BACKPACK, slotIndex),
            })
        end
    end
end

function addon:ProcessNext()
    EVENT_MANAGER:UnregisterForUpdate(self.name .. "_ProcessNext")

    if self.state ~= "active" then return end

    if #self.queue == 0 then
        self:Stop()
        return
    end

    local freeSlots = GetNumBagFreeSlots(BAG_BACKPACK)
    if freeSlots <= self.settings.reservedSlots then
        self.PrintAlways(GetString(SI_GOEA_NOT_ENOUGH_SPACE))
        self:Stop()
        return
    end

    if self:ShouldPause() then
        self.state = "paused"
        self.Print(GetString(SI_GOEA_PAUSED))
        return
    end

    local item = table.remove(self.queue, 1)

    if not self:IsSurveyItem(BAG_BACKPACK, item.slotIndex) then
        self:ProcessNext()
        return
    end

    local delay = 40
    local remaining, duration = GetItemCooldownInfo(BAG_BACKPACK, item.slotIndex)
    if remaining > 0 and duration > 0 then
        delay = delay + remaining
    end

    EVENT_MANAGER:RegisterForUpdate(self.name .. "_ProcessNext", delay, function()
        EVENT_MANAGER:UnregisterForUpdate(self.name .. "_ProcessNext")
        self:OpenSingle(item.slotIndex)
    end)
end

function addon:ShouldPause()
    if IsUnitInCombat("player") then return true end
    if IsUnitSwimming("player") then return true end
    if IsUnitDeadOrReincarnating("player") then return true end
    local interactionType = GetInteractionType()
    if interactionType ~= 0 then return true end
    return false
end

---------------------------------------------------------------------------
-- Start / Stop / Toggle
---------------------------------------------------------------------------
function addon.OpenAll()
    local self = addon

    if self.state == "active" or self.state == "paused" then
        self:Stop()
        return true
    end

    self:QueueAllSurveys()

    if #self.queue == 0 then
        self.PrintAlways(GetString(SI_GOEA_NONE_FOUND))
        return false
    end

    self.openedCount = 0
    self.state = "active"

    self:ProcessNext()
    return true
end

function addon:Stop()
    self:CleanupLootEvents()
    EVENT_MANAGER:UnregisterForUpdate(self.name .. "_ProcessNext")
    EVENT_MANAGER:UnregisterForUpdate(self.name .. "_AutoOpen")

    if self.originalUpdateLoot then
        local lootWindow = SYSTEMS:GetObject("loot")
        lootWindow.UpdateLootWindow = self.originalUpdateLoot
        self.originalUpdateLoot = nil
    end

    local wasActive = (self.state == "active" or self.state == "paused")
    self.state = "stopped"
    self.queue = {}

    if wasActive and self.settings.chatSummary and self.openedCount > 0 then
        self.PrintAlways(zo_strformat(GetString(SI_GOEA_COMPLETE), self.openedCount))
    end

    self.openedCount = 0
    self:RefreshKeybind()
end

function addon:IsActive()
    return self.state == "active" or self.state == "paused"
end

function addon:HasSurveysInBag()
    for slotIndex, _ in pairs(self.containerSlots) do
        if self:IsSurveyItem(BAG_BACKPACK, slotIndex) then
            return true
        end
    end
    return false
end

---------------------------------------------------------------------------
-- Keybind strip
---------------------------------------------------------------------------
function addon:GetKeybindName()
    if self:IsActive() then
        return GetString(SI_GOEA_CANCEL)
    else
        return GetString(SI_GOEA_OPEN_ALL)
    end
end

function addon:RefreshKeybind()
    if self.keybindButton then
        self.keybindButton.name = self:GetKeybindName()
        KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybindGroup)
    end
end

function addon:SetupKeybind()
    self.keybindButton = {
        keybind  = "OPEN_ALL_SURVEYS",
        enabled  = true,
        visible  = function() return self:HasSurveysInBag() end,
        order    = 100,
        callback = self.OpenAll,
    }
    self.keybindGroup = {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
        self.keybindButton,
    }
    BACKPACK_MENU_BAR_LAYOUT_FRAGMENT:RegisterCallback("StateChange", function(oldState, newState)
        if newState == SCENE_SHOWN then
            self.keybindButton.name = self:GetKeybindName()
            KEYBIND_STRIP:AddKeybindButtonGroup(self.keybindGroup)
        elseif newState == SCENE_HIDING then
            KEYBIND_STRIP:RemoveKeybindButtonGroup(self.keybindGroup)
        end
    end)
    INVENTORY_FRAGMENT:RegisterCallback("StateChange", function(oldState, newState)
        if newState == SCENE_SHOWING then
            KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybindGroup)
        end
    end)
end

---------------------------------------------------------------------------
-- Inventory tracking
---------------------------------------------------------------------------
function addon:TrackSlot(bagId, slotIndex)
    if bagId ~= BAG_BACKPACK then return end
    local itemType = GetItemType(bagId, slotIndex)
    if self.containerItemTypes[itemType] then
        self.containerSlots[slotIndex] = true
    else
        self.containerSlots[slotIndex] = nil
    end
end

function addon:UntrackSlot(bagId, slotIndex)
    if bagId ~= BAG_BACKPACK then return end
    self.containerSlots[slotIndex] = nil
end

function addon:CreateSlotCallbacks()
    SHARED_INVENTORY:RegisterCallback("SlotAdded", function(bagId, slotIndex, slotData)
        self:TrackSlot(bagId, slotIndex)
    end)
    SHARED_INVENTORY:RegisterCallback("SlotUpdated", function(bagId, slotIndex, slotData)
        self:TrackSlot(bagId, slotIndex)
    end)
    SHARED_INVENTORY:RegisterCallback("SlotRemoved", function(bagId, slotIndex)
        self:UntrackSlot(bagId, slotIndex)
    end)
end

---------------------------------------------------------------------------
-- Auto-open on pickup
---------------------------------------------------------------------------
function addon:SetupAutoOpen()
    EVENT_MANAGER:RegisterForEvent(self.name .. "_AutoDetect", EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
        function(eventCode, bagId, slotIndex, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange)
            if not self.settings.autoloot then return end
            if self:IsActive() then return end

            local itemType = GetItemType(bagId, slotIndex)
            if not self.containerItemTypes[itemType] then return end
            if not self:IsSurveyItem(bagId, slotIndex) then return end

            local delay = math.max(40, self.settings.autolootDelay * 1000)
            EVENT_MANAGER:UnregisterForUpdate(self.name .. "_AutoOpen")
            EVENT_MANAGER:RegisterForUpdate(self.name .. "_AutoOpen", delay, function()
                EVENT_MANAGER:UnregisterForUpdate(self.name .. "_AutoOpen")
                if not self:IsActive() then
                    self.OpenAll()
                end
            end)
        end)
    EVENT_MANAGER:AddFilterForEvent(self.name .. "_AutoDetect", EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
        REGISTER_FILTER_BAG_ID, BAG_BACKPACK)
    EVENT_MANAGER:AddFilterForEvent(self.name .. "_AutoDetect", EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
        REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)
    EVENT_MANAGER:AddFilterForEvent(self.name .. "_AutoDetect", EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
        REGISTER_FILTER_IS_NEW_ITEM, true)
end

---------------------------------------------------------------------------
-- Pause/unpause listeners
---------------------------------------------------------------------------
function addon:SetupPauseListeners()
    EVENT_MANAGER:RegisterForEvent(self.name .. "_Combat", EVENT_PLAYER_COMBAT_STATE,
        function()
            if self.state == "active" and IsUnitInCombat("player") then
                self.state = "paused"
                self:CleanupLootEvents()
            elseif self.state == "paused" and not self:ShouldPause() and #self.queue > 0 then
                self.state = "active"
                self:ProcessNext()
            end
        end)

    EVENT_MANAGER:RegisterForEvent(self.name .. "_Death", EVENT_PLAYER_DEAD,
        function()
            if self.state == "active" then
                self.state = "paused"
                self:CleanupLootEvents()
            end
        end)

    local function TryResume()
        if self.state == "paused" and not self:ShouldPause() and #self.queue > 0 then
            self.state = "active"
            self:ProcessNext()
        end
    end

    EVENT_MANAGER:RegisterForEvent(self.name .. "_Alive", EVENT_PLAYER_ALIVE, TryResume)
    EVENT_MANAGER:RegisterForEvent(self.name .. "_Reincarnated", EVENT_PLAYER_REINCARNATED, TryResume)
end

---------------------------------------------------------------------------
-- Settings panel (LibAddonMenu2)
---------------------------------------------------------------------------
function addon:SetupSettings()
    local panelData = {
        type               = "panel",
        name               = GetString(SI_GOEA),
        displayName        = GetString(SI_GOEA_COLORED),
        author             = self.author,
        version            = self.version,
        slashCommand       = "/gottaopenemall",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local optionsTable = {
        {
            type    = "checkbox",
            name    = GetString(SI_GOEA_AUTOLOOT),
            tooltip = GetString(SI_GOEA_AUTOLOOT_TOOLTIP),
            getFunc = function() return self.settings.autoloot end,
            setFunc = function(v) self.settings.autoloot = v end,
            default = defaults.autoloot,
        },
        {
            type    = "slider",
            name    = GetString(SI_GOEA_AUTOLOOT_DELAY),
            tooltip = GetString(SI_GOEA_AUTOLOOT_DELAY_TOOLTIP),
            min     = 0,
            max     = 20,
            getFunc = function() return self.settings.autolootDelay end,
            setFunc = function(v) self.settings.autolootDelay = v end,
            default = defaults.autolootDelay,
            disabled = function() return not self.settings.autoloot end,
        },
        {
            type    = "slider",
            name    = GetString(SI_GOEA_RESERVED_SLOTS),
            tooltip = GetString(SI_GOEA_RESERVED_SLOTS_TOOLTIP),
            min     = 0,
            max     = 200,
            step    = 1,
            clampInput = true,
            getFunc = function() return self.settings.reservedSlots end,
            setFunc = function(v) self.settings.reservedSlots = v end,
            default = defaults.reservedSlots,
        },
        { type = "divider" },
        {
            type    = "checkbox",
            name    = GetString(SI_GOEA_SHORT_PREFIX),
            tooltip = GetString(SI_GOEA_SHORT_PREFIX_TOOLTIP),
            getFunc = function() return self.settings.shortPrefix end,
            setFunc = function(v) self.settings.shortPrefix = v end,
            default = defaults.shortPrefix,
        },
        {
            type    = "checkbox",
            name    = GetString(SI_GOEA_CHAT_ENABLED),
            tooltip = GetString(SI_GOEA_CHAT_ENABLED_TOOLTIP),
            getFunc = function() return self.settings.chatEnabled end,
            setFunc = function(v) self.settings.chatEnabled = v end,
            default = defaults.chatEnabled,
        },
        {
            type     = "checkbox",
            name     = GetString(SI_GOEA_CHAT_ICONS),
            tooltip  = GetString(SI_GOEA_CHAT_ICONS_TOOLTIP),
            getFunc  = function() return self.settings.chatIcons end,
            setFunc  = function(v) self.settings.chatIcons = v end,
            default  = defaults.chatIcons,
            disabled = function() return not self.settings.chatEnabled end,
        },
        {
            type    = "checkbox",
            name    = GetString(SI_GOEA_CHAT_SUMMARY),
            tooltip = GetString(SI_GOEA_CHAT_SUMMARY_TOOLTIP),
            getFunc = function() return self.settings.chatSummary end,
            setFunc = function(v) self.settings.chatSummary = v end,
            default = defaults.chatSummary,
        },
    }

    LAM2:RegisterAddonPanel(self.name .. "Options", panelData)
    LAM2:RegisterOptionControls(self.name .. "Options", optionsTable)
end

---------------------------------------------------------------------------
-- Saved variables
---------------------------------------------------------------------------
function addon:SetupSavedVars()
    self.settings = ZO_SavedVars:NewAccountWide("GottaOpenEmAll_Account", 1, nil, defaults)
end

---------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------
local function OnPlayerActivated()
    EVENT_MANAGER:UnregisterForEvent(addon.name, EVENT_PLAYER_ACTIVATED)
    addon:CreateSlotCallbacks()
    SHARED_INVENTORY:PerformFullUpdateOnBagCache(BAG_BACKPACK)
end

local function OnAddonLoaded(event, name)
    if name ~= addon.name then return end
    EVENT_MANAGER:UnregisterForEvent(addon.name, EVENT_ADD_ON_LOADED)

    addon:SetupSavedVars()
    addon:SetupKeybind()
    addon:SetupAutoOpen()
    addon:SetupPauseListeners()
    addon:SetupSettings()

    SLASH_COMMANDS["/goea"]    = function() addon.OpenAll() end
    SLASH_COMMANDS["/surveys"] = function() addon.OpenAll() end

    EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
end

EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
