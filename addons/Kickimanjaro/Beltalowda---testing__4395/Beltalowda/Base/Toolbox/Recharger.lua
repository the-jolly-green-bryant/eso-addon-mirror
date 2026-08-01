-- Beltalowda Recharger
-- Automatically recharges weapons with soul gems when charge drops below a threshold.
-- Ported from RdK Group Tool Recharger by @s0rdrak, adapted to Beltalowda conventions.

Beltalowda = Beltalowda or {}
Beltalowda.Toolbox = Beltalowda.Toolbox or {}
Beltalowda.Toolbox.Recharger = Beltalowda.Toolbox.Recharger or {}

local Recharger = Beltalowda.Toolbox.Recharger

local CALLBACK_NAME = "BeltalowdaRecharger"
local CHAT_PREFIX = "|c4592FF[Beltalowda]|r "

-- Equipment slots to monitor for charge
local WEAPON_SLOTS = {
    EQUIP_SLOT_MAIN_HAND,
    EQUIP_SLOT_OFF_HAND,
    EQUIP_SLOT_BACKUP_MAIN,
    EQUIP_SLOT_BACKUP_OFF,
}

-- Module state
Recharger.initialized = false
Recharger.enabled = false
Recharger.noSoulGemsMessageShown = false

-- ============================================================================
-- Defaults
-- ============================================================================

function Recharger.GetDefaults()
    return {
        enabled = false,
        sendChatMessages = true,
        percent = 5,              -- Recharge when charge drops below this %
        checkInterval = 150,      -- Seconds between checks
        alerts = {
            login = true,         -- Warn on login if soul gems low
            empty = true,         -- Warn when out of soul gems
            threshold = true,     -- Warn when below threshold count
        },
        threshold = 100,          -- Soul gem count warning threshold
    }
end

-- ============================================================================
-- Inventory helpers
-- ============================================================================

--- Scans backpack for filled soul gems.
--- @return table Array of {slot, stack} entries
local function GetSoulGemsInventory()
    local gems = {}
    for slotIndex = 0, GetBagSize(BAG_BACKPACK) do
        if IsItemSoulGem(SOUL_GEM_TYPE_FILLED, BAG_BACKPACK, slotIndex) then
            gems[#gems + 1] = {
                slot = slotIndex,
                stack = GetSlotStackSize(BAG_BACKPACK, slotIndex),
            }
        end
    end
    return gems
end

--- Picks the soul gem slot with the smallest stack (use up partial stacks first).
--- @param gems table from GetSoulGemsInventory()
--- @return number|nil bag slot index, or nil if none available
local function GetNextSoulGemSlot(gems)
    if not gems or #gems == 0 then return nil end
    local bestSlot = gems[1].slot
    local bestStack = gems[1].stack
    for i = 2, #gems do
        if gems[i].stack < bestStack then
            bestSlot = gems[i].slot
            bestStack = gems[i].stack
        end
    end
    return bestSlot
end

--- Decrements the in-memory stack for a consumed gem (avoids re-scanning between charges).
--- @param gems table from GetSoulGemsInventory()
--- @param slot number bag slot index that was used
local function ConsumeSoulGem(gems, slot)
    for i = 1, #gems do
        if gems[i].slot == slot then
            gems[i].stack = gems[i].stack - 1
            if gems[i].stack <= 0 then
                table.remove(gems, i)
            end
            return
        end
    end
end

--- Total soul gem count across all stacks.
--- @param gems table from GetSoulGemsInventory()
--- @return number
local function GetTotalSoulGemCount(gems)
    local total = 0
    for i = 1, #gems do
        total = total + gems[i].stack
    end
    return total
end

-- ============================================================================
-- Chat helper
-- ============================================================================

local function SendChat(message)
    local vars = BeltalowdaVars and BeltalowdaVars.toolbox and BeltalowdaVars.toolbox.recharger
    if vars and vars.sendChatMessages then
        CHAT_SYSTEM:AddMessage(CHAT_PREFIX .. message)
    end
end

-- ============================================================================
-- Core logic
-- ============================================================================

function Recharger.OnUpdate()
    if IsUnitDead("player") then return end

    local vars = BeltalowdaVars and BeltalowdaVars.toolbox and BeltalowdaVars.toolbox.recharger
    if not vars then return end

    local gems = GetSoulGemsInventory()
    local showNoGemsMessage = false
    local weaponCharged = false

    for _, slotId in ipairs(WEAPON_SLOTS) do
        local charges, maxCharges = GetChargeInfoForItem(BAG_WORN, slotId)
        if maxCharges and maxCharges > 0 then
            local pct = (charges / maxCharges) * 100
            if pct <= vars.percent then
                local gemSlot = GetNextSoulGemSlot(gems)
                if gemSlot then
                    ChargeItemWithSoulGem(BAG_WORN, slotId, BAG_BACKPACK, gemSlot)
                    ConsumeSoulGem(gems, gemSlot)
                    Recharger.noSoulGemsMessageShown = false
                    weaponCharged = true
                    SendChat(string.format("Recharged %s (was at %.0f%%)", GetItemLink(BAG_WORN, slotId), pct))
                else
                    showNoGemsMessage = true
                    return -- No point checking more weapons
                end
            end
        end
    end

    -- Low-stock warning after a charge
    if weaponCharged and vars.alerts.threshold then
        local remaining = GetTotalSoulGemCount(gems)
        if remaining < vars.threshold then
            SendChat(string.format("|cFFFF00Warning:|r Soul gem count (%d) is below threshold (%d)", remaining, vars.threshold))
        end
    end

    -- Empty warning (only once until gems are refilled)
    if not Recharger.noSoulGemsMessageShown and showNoGemsMessage and vars.alerts.empty then
        Recharger.noSoulGemsMessageShown = true
        SendChat("|cFF0000Warning:|r No filled soul gems available for recharging!")
    end
end

function Recharger.OnPlayerActivated(event)
    if event ~= EVENT_PLAYER_ACTIVATED then return end
    EVENT_MANAGER:UnregisterForEvent(CALLBACK_NAME, EVENT_PLAYER_ACTIVATED)

    local vars = BeltalowdaVars and BeltalowdaVars.toolbox and BeltalowdaVars.toolbox.recharger
    if not vars or not vars.alerts or not vars.alerts.login then return end

    local gems = GetSoulGemsInventory()
    local count = GetTotalSoulGemCount(gems)
    if count < vars.threshold then
        SendChat(string.format("|cFFFF00Warning:|r Soul gem count (%d) is below threshold (%d)", count, vars.threshold))
    end
end

-- ============================================================================
-- Enable / Disable
-- ============================================================================

function Recharger.SetEnabled(value)
    if not Recharger.initialized then return end

    local vars = BeltalowdaVars and BeltalowdaVars.toolbox and BeltalowdaVars.toolbox.recharger
    if not vars then return end

    vars.enabled = value

    if Recharger.enabled then
        EVENT_MANAGER:UnregisterForUpdate(CALLBACK_NAME)
    end

    if value then
        EVENT_MANAGER:RegisterForUpdate(CALLBACK_NAME, vars.checkInterval * 1000, Recharger.OnUpdate)
        Recharger.enabled = true
    else
        Recharger.enabled = false
    end
end

-- ============================================================================
-- Initialize
-- ============================================================================

function Recharger.Initialize()
    if Recharger.initialized then return end
    Recharger.initialized = true

    local vars = BeltalowdaVars and BeltalowdaVars.toolbox and BeltalowdaVars.toolbox.recharger
    if not vars then return end

    Recharger.SetEnabled(vars.enabled)

    if vars.alerts and vars.alerts.login then
        EVENT_MANAGER:RegisterForEvent(CALLBACK_NAME, EVENT_PLAYER_ACTIVATED, Recharger.OnPlayerActivated)
    end
end

-- ============================================================================
-- Settings Controls
-- ============================================================================

function Recharger.GetSettingsControls()
    return {
        {
            type = "submenu",
            name = "|c4592FFRecharge|r",
            tooltip = "Automatically recharge weapons with soul gems when charge drops below a threshold.",
            controls = {
                {
                    type = "description",
                    text = "Consumes filled soul gems from your inventory to automatically recharge equipped weapons when their charge falls below a configurable percentage.",
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Enable Recharge",
                    tooltip = "Automatically recharge weapons when their charge drops below the threshold.",
                    getFunc = function()
                        return BeltalowdaVars.toolbox.recharger.enabled
                    end,
                    setFunc = function(value)
                        Recharger.SetEnabled(value)
                    end,
                    width = "full",
                    default = false,
                },
                {
                    type = "checkbox",
                    name = "Chat Notifications",
                    tooltip = "Show chat messages when weapons are recharged or soul gem warnings trigger.",
                    getFunc = function()
                        return BeltalowdaVars.toolbox.recharger.sendChatMessages
                    end,
                    setFunc = function(value)
                        BeltalowdaVars.toolbox.recharger.sendChatMessages = value
                    end,
                    width = "full",
                    default = true,
                },
                {
                    type = "slider",
                    name = "Charge Threshold (%)",
                    tooltip = "Recharge weapons when their charge percentage falls to or below this value.",
                    min = 0,
                    max = 99,
                    step = 1,
                    getFunc = function()
                        return BeltalowdaVars.toolbox.recharger.percent
                    end,
                    setFunc = function(value)
                        BeltalowdaVars.toolbox.recharger.percent = value
                    end,
                    width = "full",
                    default = 5,
                },
                {
                    type = "slider",
                    name = "Check Interval (seconds)",
                    tooltip = "How often to check weapon charge levels.",
                    min = 1,
                    max = 300,
                    step = 1,
                    getFunc = function()
                        return BeltalowdaVars.toolbox.recharger.checkInterval
                    end,
                    setFunc = function(value)
                        BeltalowdaVars.toolbox.recharger.checkInterval = value
                        -- Re-register with new interval if enabled
                        if Recharger.enabled then
                            Recharger.SetEnabled(true)
                        end
                    end,
                    width = "full",
                    default = 150,
                },
                {
                    type = "checkbox",
                    name = "Warn When Out of Soul Gems",
                    tooltip = "Show a warning when you run out of filled soul gems during a recharge attempt.",
                    getFunc = function()
                        return BeltalowdaVars.toolbox.recharger.alerts.empty
                    end,
                    setFunc = function(value)
                        BeltalowdaVars.toolbox.recharger.alerts.empty = value
                    end,
                    width = "full",
                    default = true,
                },
                {
                    type = "checkbox",
                    name = "Low Soul Gem Warning",
                    tooltip = "Show a warning when your soul gem count drops below the threshold after recharging.",
                    getFunc = function()
                        return BeltalowdaVars.toolbox.recharger.alerts.threshold
                    end,
                    setFunc = function(value)
                        BeltalowdaVars.toolbox.recharger.alerts.threshold = value
                    end,
                    width = "full",
                    default = true,
                },
                {
                    type = "slider",
                    name = "Soul Gem Warning Threshold",
                    tooltip = "Warn when your filled soul gem count drops below this number.",
                    min = 0,
                    max = 1000,
                    step = 1,
                    getFunc = function()
                        return BeltalowdaVars.toolbox.recharger.threshold
                    end,
                    setFunc = function(value)
                        BeltalowdaVars.toolbox.recharger.threshold = value
                    end,
                    width = "full",
                    default = 100,
                },
                {
                    type = "checkbox",
                    name = "Login Warning",
                    tooltip = "Show a low soul gem warning when you log in or reload UI.",
                    getFunc = function()
                        return BeltalowdaVars.toolbox.recharger.alerts.login
                    end,
                    setFunc = function(value)
                        BeltalowdaVars.toolbox.recharger.alerts.login = value
                    end,
                    width = "full",
                    default = true,
                },
            },
        },
    }
end
