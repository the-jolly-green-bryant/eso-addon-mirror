--[[
PS5 Container Opener
Version 1.3.1-fast2

Fast, background-friendly console container opener.

Commands:
  /opencontainers - Start opening backpack containers
  /cancelopen     - Stop the current run
]]

local ADDON = {
    name = "PS5ContainerOpener",
    version = "1.3.1-fast2",

    running = false,
    waitingForLoot = false,
    paused = false,
    pauseReason = nil,

    operationToken = 0,
    openedCount = 0,

    currentItemId = nil,
    currentCountBefore = 0,
    verificationAttempts = 0,

    -- Delays are intentionally aggressive. ESO's own item-use cooldown remains
    -- authoritative; the add-on does not and cannot bypass it.
    lootNudgeMs = 35,
    afterLootDelayMs = 0,
    useTimeoutMs = 850,
    retryDelayMs = 25,
    verificationDelayMs = 15,
    maxVerificationAttempts = 8,
    monitorIntervalMs = 100,

    monitorName = "PS5ContainerOpenerMonitor",
}

local BLOCKED_SCENES = {
    bank = true,
    gamepad_bank = true,
    guildBank = true,
    gamepad_guild_bank = true,
    gamepad_store = true,
    store = true,
    mailInbox = true,
    mailSend = true,
    gamepad_mail = true,
    tradingHouse = true,
    gamepad_trading_house = true,
    trade = true,
    gamepad_trade = true,
    smithing = true,
    gamepad_smithing = true,
    enchanting = true,
    gamepad_enchanting = true,
    alchemy = true,
    gamepad_alchemy = true,
    provisioning = true,
    gamepad_provisioner = true,
    retrait = true,
    gamepad_retrait = true,
    universalDeconstructionSceneGamepad = true,
    companionEquipmentGamepad = true,
}

local function ChatMessage(message)
    if CHAT_SYSTEM and d then
        d(string.format("|c00C0FF[OpenAll]|r %s", message))
    end
end

local function AlertMessage(message, sound)
    if ZO_Alert then
        ZO_Alert(
            UI_ALERT_CATEGORY_ALERT,
            sound or SOUNDS.GENERAL_ALERT_ERROR,
            message
        )
    end
    ChatMessage(message)
end

local function IsContainerSlot(bagId, slotIndex)
    local stackSize = GetSlotStackSize(bagId, slotIndex) or 0
    return stackSize > 0 and GetItemType(bagId, slotIndex) == ITEMTYPE_CONTAINER
end


local function GetContainerItemId(bagId, slotIndex)
    local link = GetItemLink(bagId, slotIndex) or ""
    if link ~= "" and GetItemLinkItemId then
        return GetItemLinkItemId(link)
    end
    return nil
end

local function CountContainerItem(itemId)
    if not itemId then
        return 0
    end

    local total = 0
    local bagSize = GetBagSize(BAG_BACKPACK) or 0
    for slotIndex = 0, bagSize - 1 do
        if IsContainerSlot(BAG_BACKPACK, slotIndex) then
            local slotItemId = GetContainerItemId(BAG_BACKPACK, slotIndex)
            if slotItemId == itemId then
                total = total + (GetSlotStackSize(BAG_BACKPACK, slotIndex) or 0)
            end
        end
    end
    return total
end

local function HideLootInterface()
    -- Loot first, then immediately hide the shared loot system. Calling both
    -- guarded variants covers keyboard and gamepad implementations.
    local lootSystem = nil
    if SYSTEMS and SYSTEMS.GetObject then
        lootSystem = SYSTEMS:GetObject("loot")
    end

    if lootSystem and lootSystem.Hide then
        pcall(function()
            lootSystem:Hide()
        end)
    end

    if LOOT_WINDOW and LOOT_WINDOW.Hide then
        pcall(function()
            LOOT_WINDOW:Hide()
        end)
    end
end

local function LootAndHide()
    if LootAll then
        pcall(LootAll)
    end

    HideLootInterface()

    -- The gamepad loot scene can finish showing one frame after EVENT_LOOT_UPDATED.
    -- Hide it again on the following frame to prevent the visible flash.
    zo_callLater(HideLootInterface, 0)
    zo_callLater(HideLootInterface, 15)
end

local function GetCurrentSceneName()
    if not SCENE_MANAGER or not SCENE_MANAGER.GetCurrentScene then
        return nil
    end

    local scene = SCENE_MANAGER:GetCurrentScene()
    if scene and scene.GetName then
        return scene:GetName()
    end

    return nil
end

function ADDON:GetPauseReason()
    if IsUnitInCombat("player") then
        return "combat"
    end

    if IsPlayerDead and IsPlayerDead() then
        return "player is dead"
    end

    -- The loot scene briefly takes camera focus while this add-on is opening
    -- a container. Do not mistake our own loot interaction for a conflicting UI.
    if not self.waitingForLoot
        and IsGameCameraActive
        and not IsGameCameraActive()
    then
        return "another interface is open"
    end

    local sceneName = GetCurrentSceneName()
    if sceneName and BLOCKED_SCENES[sceneName] then
        return "another inventory interface is open"
    end

    return nil
end

function ADDON:FindNextContainer()
    local bagSize = GetBagSize(BAG_BACKPACK) or 0
    local bestEntry = nil

    for slotIndex = 0, bagSize - 1 do
        if IsContainerSlot(BAG_BACKPACK, slotIndex) then
            local name = GetItemName(BAG_BACKPACK, slotIndex) or ""
            if not bestEntry
                or name < bestEntry.name
                or (name == bestEntry.name and slotIndex < bestEntry.slot)
            then
                bestEntry = {
                    bag = BAG_BACKPACK,
                    slot = slotIndex,
                    name = name,
                }
            end
        end
    end

    return bestEntry
end

function ADDON:InvalidateCallbacks()
    self.operationToken = self.operationToken + 1
end

function ADDON:ClearCurrentItem()
    self.waitingForLoot = false
    self.currentItemId = nil
    self.currentCountBefore = 0
    self.verificationAttempts = 0
end

function ADDON:Schedule(delayMs, callback)
    local token = self.operationToken
    zo_callLater(function()
        if ADDON.running and token == ADDON.operationToken then
            callback()
        end
    end, delayMs)
end

function ADDON:SetPaused(reason)
    local shouldPause = reason ~= nil

    if shouldPause == self.paused and reason == self.pauseReason then
        return
    end

    self.paused = shouldPause
    self.pauseReason = reason

    if shouldPause then
        ChatMessage(string.format("Paused: %s.", reason))
    else
        ChatMessage("Resuming container opening...")
        if not self.waitingForLoot then
            self:Advance()
        end
    end
end

function ADDON:StartMonitor()
    EVENT_MANAGER:RegisterForUpdate(
        self.monitorName,
        self.monitorIntervalMs,
        function()
            if not ADDON.running then
                return
            end

            ADDON:SetPaused(ADDON:GetPauseReason())
        end
    )
end

function ADDON:StopMonitor()
    EVENT_MANAGER:UnregisterForUpdate(self.monitorName)
end

function ADDON:CallUseItem(bagId, slotIndex)
    if IsProtectedFunction and IsProtectedFunction("UseItem") then
        if not CallSecureProtected then
            return false, "secure item use is unavailable"
        end

        local callOk, protectedResult = pcall(
            CallSecureProtected,
            "UseItem",
            bagId,
            slotIndex
        )

        if not callOk then
            return false, protectedResult
        end

        if protectedResult == false then
            return false, "item use was rejected"
        end

        return true
    end

    if not UseItem then
        return false, "UseItem is unavailable"
    end

    local callOk, result = pcall(UseItem, bagId, slotIndex)
    if not callOk then
        return false, result
    end

    if result == false then
        return false, "item use was rejected"
    end

    return true
end

function ADDON:FinishCurrentItem()
    if not self.waitingForLoot then
        return
    end

    local countNow = CountContainerItem(self.currentItemId)

    -- Only count an opening after the backpack confirms that one copy of the
    -- container was consumed. This avoids counting rejected or timed-out uses.
    if countNow < self.currentCountBefore then
        self.openedCount = self.openedCount + 1
        self:ClearCurrentItem()
        self:InvalidateCallbacks()

        self:Schedule(self.afterLootDelayMs, function()
            ADDON:Advance()
        end)
        return
    end

    self.verificationAttempts = self.verificationAttempts + 1
    if self.verificationAttempts < self.maxVerificationAttempts then
        local token = self.operationToken
        zo_callLater(function()
            if ADDON.running
                and ADDON.waitingForLoot
                and token == ADDON.operationToken
            then
                ADDON:FinishCurrentItem()
            end
        end, self.verificationDelayMs)
        return
    end

    -- The item was not consumed. Do not increment the completed count; clear
    -- the state and retry the live backpack scan after ESO's cooldown settles.
    self:ClearCurrentItem()
    self:InvalidateCallbacks()
    self:Schedule(self.retryDelayMs, function()
        ADDON:Advance()
    end)
end

function ADDON:UseContainer(entry)
    local pauseReason = self:GetPauseReason()
    if pauseReason then
        self:SetPaused(pauseReason)
        return
    end

    if not IsContainerSlot(entry.bag, entry.slot) then
        self:Schedule(self.afterLootDelayMs, function()
            ADDON:Advance()
        end)
        return
    end

    self.currentItemId = GetContainerItemId(entry.bag, entry.slot)
    self.currentCountBefore = CountContainerItem(self.currentItemId)
    self.verificationAttempts = 0
    self.waitingForLoot = true
    self:InvalidateCallbacks()
    local token = self.operationToken

    local success = self:CallUseItem(entry.bag, entry.slot)
    if not success then
        self:ClearCurrentItem()

        -- ESO can temporarily reject UseItem while its item-use cooldown is
        -- active. Rescan and retry instead of stopping the entire run.
        self:Schedule(self.retryDelayMs, function()
            ADDON:Advance()
        end)
        return
    end

    zo_callLater(function()
        if ADDON.running
            and ADDON.waitingForLoot
            and token == ADDON.operationToken
        then
            LootAndHide()
        end
    end, self.lootNudgeMs)

    -- Auto-looted and empty containers may not fire a normal loot-close event.
    zo_callLater(function()
        if ADDON.running
            and ADDON.waitingForLoot
            and token == ADDON.operationToken
        then
            ADDON:FinishCurrentItem()
        end
    end, self.useTimeoutMs)
end

function ADDON:Advance()
    if not self.running or self.waitingForLoot or self.paused then
        return
    end

    local pauseReason = self:GetPauseReason()
    if pauseReason then
        self:SetPaused(pauseReason)
        return
    end

    local entry = self:FindNextContainer()
    if not entry then
        local total = self.openedCount
        self.running = false
        self:StopMonitor()
        self:InvalidateCallbacks()

        if total == 1 then
            AlertMessage("Done. Opened 1 container.", SOUNDS.GENERAL_ALERT)
        else
            AlertMessage(
                string.format("Done. Opened %d containers.", total),
                SOUNDS.GENERAL_ALERT
            )
        end
        return
    end

    self:UseContainer(entry)
end

function ADDON:Start()
    if self.running then
        AlertMessage("Container opening is already running.")
        return
    end

    if not self:FindNextContainer() then
        AlertMessage("No containers found in your backpack.")
        return
    end

    self.running = true
    self.waitingForLoot = false
    self.paused = false
    self.pauseReason = nil
    self.openedCount = 0
    self:InvalidateCallbacks()
    self:StartMonitor()

    local pauseReason = self:GetPauseReason()
    if pauseReason then
        self:SetPaused(pauseReason)
        AlertMessage("Container opening started in the background.", SOUNDS.GENERAL_ALERT)
        return
    end

    AlertMessage("Opening containers in the background...", SOUNDS.GENERAL_ALERT)
    self:Advance()
end

function ADDON:Cancel()
    if not self.running then
        AlertMessage("No container-opening run is active.")
        return
    end

    self.running = false
    self.paused = false
    self.pauseReason = nil
    self:ClearCurrentItem()
    self:InvalidateCallbacks()
    self:StopMonitor()
    AlertMessage("Container opening canceled.")
end

local function OnLootUpdated()
    if ADDON.running and ADDON.waitingForLoot then
        LootAndHide()
    end
end

local function OnLootClosed()
    if ADDON.running and ADDON.waitingForLoot then
        HideLootInterface()
        ADDON:FinishCurrentItem()
    end
end

local function OnPlayerActivated()
    if ADDON.running then
        ADDON:SetPaused(ADDON:GetPauseReason())
        if not ADDON.paused and not ADDON.waitingForLoot then
            ADDON:Advance()
        end
    end
end

local function OnPlayerDeactivated()
    if ADDON.running then
        ADDON:SetPaused("loading or changing zones")
    end
end

SLASH_COMMANDS = SLASH_COMMANDS or {}

SLASH_COMMANDS["/opencontainers"] = function()
    ADDON:Start()
end

SLASH_COMMANDS["/cancelopen"] = function()
    ADDON:Cancel()
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= ADDON.name then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(ADDON.name, EVENT_ADD_ON_LOADED)
    EVENT_MANAGER:RegisterForEvent(ADDON.name, EVENT_LOOT_UPDATED, OnLootUpdated)
    EVENT_MANAGER:RegisterForEvent(ADDON.name, EVENT_LOOT_CLOSED, OnLootClosed)
    EVENT_MANAGER:RegisterForEvent(ADDON.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
    EVENT_MANAGER:RegisterForEvent(ADDON.name, EVENT_PLAYER_DEACTIVATED, OnPlayerDeactivated)

    ChatMessage("Loaded. Use /opencontainers to start and /cancelopen to stop.")
end

EVENT_MANAGER:RegisterForEvent(
    ADDON.name,
    EVENT_ADD_ON_LOADED,
    OnAddOnLoaded
)
