-- Beltalowda Repair
-- Automatically repairs equipped gear using repair kits when condition drops below a threshold.
-- New module inspired by the Recharger pattern; uses ESO repair kit APIs.

Beltalowda = Beltalowda or {}
Beltalowda.Toolbox = Beltalowda.Toolbox or {}
Beltalowda.Toolbox.Repair = Beltalowda.Toolbox.Repair or {}

local Repair = Beltalowda.Toolbox.Repair

local CALLBACK_NAME = "BeltalowdaRepair"
local CHAT_PREFIX = "|c4592FF[Beltalowda]|r "

-- Equipment slots that can have durability
local EQUIPMENT_SLOTS = {
    EQUIP_SLOT_HEAD,
    EQUIP_SLOT_CHEST,
    EQUIP_SLOT_SHOULDERS,
    EQUIP_SLOT_HAND,
    EQUIP_SLOT_WAIST,
    EQUIP_SLOT_LEGS,
    EQUIP_SLOT_FEET,
    EQUIP_SLOT_MAIN_HAND,
    EQUIP_SLOT_OFF_HAND,
    EQUIP_SLOT_BACKUP_MAIN,
    EQUIP_SLOT_BACKUP_OFF,
}

-- Module state
Repair.initialized = false
Repair.enabled = false
Repair.noRepairKitsMessageShown = false

-- ============================================================================
-- Defaults
-- ============================================================================

function Repair.GetDefaults()
    return {
        enabled = false,
        sendChatMessages = true,
        percent = 10,             -- Repair when condition drops below this %
        checkInterval = 150,      -- Seconds between checks
        alerts = {
            login = true,         -- Warn on login if repair kits low
            empty = true,         -- Warn when out of repair kits
            threshold = true,     -- Warn when below threshold count
        },
        threshold = 14,           -- Repair kit count warning threshold
    }
end

-- ============================================================================
-- Inventory helpers
-- ============================================================================

--- Scans backpack for all repair kits (including Crown Store kits).
--- @return table Array of {slot, stack} entries
local function GetRepairKitsInventory()
    local kits = {}
    for slotIndex = 0, GetBagSize(BAG_BACKPACK) do
        if IsItemRepairKit(BAG_BACKPACK, slotIndex) then
            kits[#kits + 1] = {
                slot = slotIndex,
                stack = GetSlotStackSize(BAG_BACKPACK, slotIndex),
            }
        end
    end
    return kits
end

--- Picks the best repair kit for a given item — prefers the kit that would
--- repair the smallest amount above what's needed (waste the least).
--- Falls back to any available kit if none perfectly sized.
--- @param kits table from GetRepairKitsInventory()
--- @param itemBagId number bag ID of item to repair
--- @param itemSlotIndex number slot of item to repair
--- @return number|nil bag slot index of the chosen kit, or nil if none
local function GetBestRepairKit(kits, itemBagId, itemSlotIndex)
    if not kits or #kits == 0 then return nil end

    local bestSlot = nil
    local bestRepair = nil

    for i = 1, #kits do
        local repairAmount = GetAmountRepairKitWouldRepairItem(itemBagId, itemSlotIndex, BAG_BACKPACK, kits[i].slot)
        if repairAmount and repairAmount > 0 then
            -- Prefer the smallest sufficient repair to minimize waste
            if not bestRepair or repairAmount < bestRepair then
                bestRepair = repairAmount
                bestSlot = kits[i].slot
            end
        end
    end

    -- If no kit would provide any repair, just return the first available
    if not bestSlot and #kits > 0 then
        bestSlot = kits[1].slot
    end

    return bestSlot
end

--- Decrements the in-memory stack for a consumed kit.
--- @param kits table from GetRepairKitsInventory()
--- @param slot number bag slot index that was used
local function ConsumeRepairKit(kits, slot)
    for i = 1, #kits do
        if kits[i].slot == slot then
            kits[i].stack = kits[i].stack - 1
            if kits[i].stack <= 0 then
                table.remove(kits, i)
            end
            return
        end
    end
end

--- Total repair kit count across all stacks.
--- @param kits table from GetRepairKitsInventory()
--- @return number
local function GetTotalRepairKitCount(kits)
    local total = 0
    for i = 1, #kits do
        total = total + kits[i].stack
    end
    return total
end

-- ============================================================================
-- Chat helper
-- ============================================================================

local function SendChat(message)
    local vars = BeltalowdaVars and BeltalowdaVars.toolbox and BeltalowdaVars.toolbox.repair
    if vars and vars.sendChatMessages then
        CHAT_SYSTEM:AddMessage(CHAT_PREFIX .. message)
    end
end

-- ============================================================================
-- Core logic
-- ============================================================================

function Repair.OnUpdate()
    if IsUnitDead("player") then return end

    local vars = BeltalowdaVars and BeltalowdaVars.toolbox and BeltalowdaVars.toolbox.repair
    if not vars then return end

    local kits = GetRepairKitsInventory()
    local showNoKitsMessage = false
    local gearRepaired = false

    for _, slotId in ipairs(EQUIPMENT_SLOTS) do
        if DoesItemHaveDurability(BAG_WORN, slotId) then
            local condition = GetItemCondition(BAG_WORN, slotId)
            if condition < vars.percent then
                local kitSlot = GetBestRepairKit(kits, BAG_WORN, slotId)
                if kitSlot then
                    RepairItemWithRepairKit(BAG_WORN, slotId, BAG_BACKPACK, kitSlot)
                    ConsumeRepairKit(kits, kitSlot)
                    Repair.noRepairKitsMessageShown = false
                    gearRepaired = true
                    SendChat(string.format("Repaired %s (was at %d%% condition)", GetItemLink(BAG_WORN, slotId), condition))
                else
                    showNoKitsMessage = true
                    return -- No repair kits left
                end
            end
        end
    end

    -- Low-stock warning after a repair
    if gearRepaired and vars.alerts.threshold then
        local remaining = GetTotalRepairKitCount(kits)
        if remaining < vars.threshold then
            SendChat(string.format("|cFFFF00Warning:|r Repair kit count (%d) is below threshold (%d)", remaining, vars.threshold))
        end
    end

    -- Empty warning (only once until kits are refilled)
    if not Repair.noRepairKitsMessageShown and showNoKitsMessage and vars.alerts.empty then
        Repair.noRepairKitsMessageShown = true
        SendChat("|cFF0000Warning:|r No repair kits available for repairing!")
    end
end

function Repair.OnPlayerActivated(event)
    if event ~= EVENT_PLAYER_ACTIVATED then return end
    EVENT_MANAGER:UnregisterForEvent(CALLBACK_NAME, EVENT_PLAYER_ACTIVATED)

    local vars = BeltalowdaVars and BeltalowdaVars.toolbox and BeltalowdaVars.toolbox.repair
    if not vars or not vars.alerts or not vars.alerts.login then return end

    local kits = GetRepairKitsInventory()
    local count = GetTotalRepairKitCount(kits)
    if count < vars.threshold then
        SendChat(string.format("|cFFFF00Warning:|r Repair kit count (%d) is below threshold (%d)", count, vars.threshold))
    end
end

-- ============================================================================
-- Enable / Disable
-- ============================================================================

function Repair.SetEnabled(value)
    if not Repair.initialized then return end

    local vars = BeltalowdaVars and BeltalowdaVars.toolbox and BeltalowdaVars.toolbox.repair
    if not vars then return end

    vars.enabled = value

    if Repair.enabled then
        EVENT_MANAGER:UnregisterForUpdate(CALLBACK_NAME)
    end

    if value then
        EVENT_MANAGER:RegisterForUpdate(CALLBACK_NAME, vars.checkInterval * 1000, Repair.OnUpdate)
        Repair.enabled = true
    else
        Repair.enabled = false
    end
end

-- ============================================================================
-- Initialize
-- ============================================================================

function Repair.Initialize()
    if Repair.initialized then return end
    Repair.initialized = true

    local vars = BeltalowdaVars and BeltalowdaVars.toolbox and BeltalowdaVars.toolbox.repair
    if not vars then return end

    Repair.SetEnabled(vars.enabled)

    if vars.alerts and vars.alerts.login then
        EVENT_MANAGER:RegisterForEvent(CALLBACK_NAME, EVENT_PLAYER_ACTIVATED, Repair.OnPlayerActivated)
    end
end

-- ============================================================================
-- Settings Controls
-- ============================================================================

function Repair.GetSettingsControls()
    return {
        {
            type = "submenu",
            name = "|c4592FFRepair|r",
            tooltip = "Automatically repair equipped gear using repair kits when condition drops below a threshold.",
            controls = {
                {
                    type = "description",
                    text = "Consumes repair kits from your inventory to automatically repair equipped gear when its condition falls below a configurable percentage.",
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Enable Auto-Repair",
                    tooltip = "Automatically repair gear when its condition drops below the threshold.",
                    getFunc = function()
                        return BeltalowdaVars.toolbox.repair.enabled
                    end,
                    setFunc = function(value)
                        Repair.SetEnabled(value)
                    end,
                    width = "full",
                    default = false,
                },
                {
                    type = "checkbox",
                    name = "Chat Notifications",
                    tooltip = "Show chat messages when gear is repaired or repair kit warnings trigger.",
                    getFunc = function()
                        return BeltalowdaVars.toolbox.repair.sendChatMessages
                    end,
                    setFunc = function(value)
                        BeltalowdaVars.toolbox.repair.sendChatMessages = value
                    end,
                    width = "full",
                    default = true,
                },
                {
                    type = "slider",
                    name = "Condition Threshold (%)",
                    tooltip = "Repair gear when its condition falls below this percentage.",
                    min = 0,
                    max = 99,
                    step = 1,
                    getFunc = function()
                        return BeltalowdaVars.toolbox.repair.percent
                    end,
                    setFunc = function(value)
                        BeltalowdaVars.toolbox.repair.percent = value
                    end,
                    width = "full",
                    default = 10,
                },
                {
                    type = "slider",
                    name = "Check Interval (seconds)",
                    tooltip = "How often to check gear condition.",
                    min = 1,
                    max = 300,
                    step = 1,
                    getFunc = function()
                        return BeltalowdaVars.toolbox.repair.checkInterval
                    end,
                    setFunc = function(value)
                        BeltalowdaVars.toolbox.repair.checkInterval = value
                        if Repair.enabled then
                            Repair.SetEnabled(true)
                        end
                    end,
                    width = "full",
                    default = 150,
                },
                {
                    type = "checkbox",
                    name = "Warn When Out of Repair Kits",
                    tooltip = "Show a warning when you have no repair kits available during a repair attempt.",
                    getFunc = function()
                        return BeltalowdaVars.toolbox.repair.alerts.empty
                    end,
                    setFunc = function(value)
                        BeltalowdaVars.toolbox.repair.alerts.empty = value
                    end,
                    width = "full",
                    default = true,
                },
                {
                    type = "checkbox",
                    name = "Low Repair Kit Warning",
                    tooltip = "Show a warning when your repair kit count drops below the threshold after repairing.",
                    getFunc = function()
                        return BeltalowdaVars.toolbox.repair.alerts.threshold
                    end,
                    setFunc = function(value)
                        BeltalowdaVars.toolbox.repair.alerts.threshold = value
                    end,
                    width = "full",
                    default = true,
                },
                {
                    type = "slider",
                    name = "Repair Kit Warning Threshold",
                    tooltip = "Warn when your repair kit count drops below this number.",
                    min = 0,
                    max = 200,
                    step = 1,
                    getFunc = function()
                        return BeltalowdaVars.toolbox.repair.threshold
                    end,
                    setFunc = function(value)
                        BeltalowdaVars.toolbox.repair.threshold = value
                    end,
                    width = "full",
                    default = 14,
                },
                {
                    type = "checkbox",
                    name = "Login Warning",
                    tooltip = "Show a low repair kit warning when you log in or reload UI.",
                    getFunc = function()
                        return BeltalowdaVars.toolbox.repair.alerts.login
                    end,
                    setFunc = function(value)
                        BeltalowdaVars.toolbox.repair.alerts.login = value
                    end,
                    width = "full",
                    default = true,
                },
            },
        },
    }
end
