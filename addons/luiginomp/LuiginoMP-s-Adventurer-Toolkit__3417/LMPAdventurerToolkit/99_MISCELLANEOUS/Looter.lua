LOOTER = {}
local systemName = "Looter"

function LOOTER.GetName() return systemName end

function LOOTER.GetAutoLootStatus()
    local activeStatus = MAIN.accountVariables.autoLoot
    if activeStatus == true then d("Auto-looting is active.")
    elseif activeStatus == false then d("Auto-looting is inactive.")
    else
        d("WARNING - unkown status for Auto-looting: "..activeStatus)
        SOUNDS.PlayError()
    end
end

local function GetUnopenedContainers()
    local backpackSlots = GetNumBagFreeSlots(BAG_BACKPACK) + GetNumBagUsedSlots(BAG_BACKPACK)
    local containers = {}
    local counter = 0
    for slotIndex = 1, backpackSlots do
        local itemLink = GetItemLink(BAG_BACKPACK, slotIndex, LINK_STYLE_DEFAULT)
        if IsItemLinkContainer(itemLink) == true then
            containers[slotIndex] = itemLink
            counter = counter + 1
        end
    end
    return counter, containers
end

local function ProcessUnopenedContainers()
    local containerCount, containers = GetUnopenedContainers()
    if containerCount > 0 then
        for containerIndex, containerLink in pairs(containers) do
            d("Preparing to loot "..containerLink..".")
            CallSecureProtected("UseItem", BAG_BACKPACK, containerIndex)
            break
        end
    end
end

local receivedReward = false
local speakingToNPC = false
function LOOTER.SetAutoLootStatus(isActive)
    MAIN.accountVariables.autoLoot = isActive
    if MAIN.accountVariables.autoLoot == true then
        EVENT_MANAGER:RegisterForEvent(systemName, EVENT_CHATTER_BEGIN, function(eventCode, optionCount) d("EVENT_CHATTER_BEGIN") speakingToNPC = true end)
        EVENT_MANAGER:RegisterForEvent(systemName, EVENT_LOOT_CLOSED, function(eventCode) d("EVENT_LOOT_CLOSED") ProcessUnopenedContainers() end)
        EVENT_MANAGER:RegisterForEvent(systemName, EVENT_LOOT_ITEM_FAILED, function(eventCode, reason, itemName) d("EVENT_LOOT_ITEM_FAILED") SOUNDS.PlayAlert() end)
        EVENT_MANAGER:RegisterForEvent(systemName, EVENT_LOOT_RECEIVED, function(eventCode, receivedBy, itemName, quantity, soundCategory, lootType, self, isPickpocketLoot, questItemIcon, itemId, isStolen)
            if speakingToNPC == true then
                receivedReward = true
            end
        end)
        EVENT_MANAGER:RegisterForEvent(systemName, EVENT_LOOT_UPDATED, function(eventCode) LootAll(MAIN.characterVariables.ignoreStolen) end)
        EVENT_MANAGER:RegisterForEvent(systemName, EVENT_CHATTER_END, function(eventCode)
            d("EVENT_CHATTER_END")
            if receivedReward == true then
                ProcessUnopenedContainers()
                receivedReward = false
            end
            speakingToNPC = false
        end)
    elseif MAIN.accountVariables.autoLoot == false then
        EVENT_MANAGER:UnregisterForEvent(systemName, EVENT_LOOT_CLOSED)
        EVENT_MANAGER:UnregisterForEvent(systemName, EVENT_LOOT_ITEM_FAILED)
        EVENT_MANAGER:UnregisterForEvent(systemName, EVENT_LOOT_RECEIVED)
        EVENT_MANAGER:UnregisterForEvent(systemName, EVENT_LOOT_UPDATED)
        EVENT_MANAGER:UnregisterForEvent(systemName, EVENT_CHATTER_END)
    end
    LOOTER.GetAutoLootStatus()
end

function LOOTER.GetIgnoreStolenItemsStatus()
    local activeStatus = MAIN.characterVariables.ignoreStolen
    if activeStatus == true then d("Ignoring stolen items.")
    elseif activeStatus == false then d("Looting stolen items.")
    else
        d("WARNING - unkown status for stolen items: "..activeStatus)
        SOUNDS.PlayError()
    end
end

function LOOTER.SetIgnoreStolenItemsStatus(isActive)
    MAIN.characterVariables.ignoreStolen = isActive
    LOOTER.GetIgnoreStolenItemsStatus()
end

function DisplayUnopenedContainers()
    local containerCount, containers = GetUnopenedContainers()
    if containerCount > 0 then
        d(containerCount.." unopened loot container(s):")
        SOUNDS.PlayAlert()
        for containerIndex, containerLink in pairs(containers) do
            d("Slot "..containerIndex..": "..containerLink)
        end
    else d("No unopened containers found.")
    end
end

function LOOTER.Initialize()
    if MAIN.accountVariables.autoLoot == nil then LOOTER.SetAutoLootStatus(false)
    else LOOTER.SetAutoLootStatus(MAIN.accountVariables.autoLoot) end
    if MAIN.characterVariables.ignoreStolen == nil then LOOTER.SetIgnoreStolenItemsStatus(true)
    else LOOTER.SetIgnoreStolenItemsStatus(MAIN.characterVariables.ignoreStolen) end
    DisplayUnopenedContainers()
end

MAIN.AddToInitializeSystemsList(LOOTER)

SLASH_COMMANDS["/looteropencontainers"] = ProcessUnopenedContainers

SLASH_COMMANDS["/looteron"] = function()
    LOOTER.SetAutoLootStatus(true)
    SOUNDS.PlayAddonActivated()
end
SLASH_COMMANDS["/looteroff"] = function()
    LOOTER.SetAutoLootStatus(false)
    SOUNDS.PlayAddonDeactivated()
end
SLASH_COMMANDS["/looterstatus"] = function() LOOTER.GetAutoLootStatus() end
SLASH_COMMANDS["/looterignorestolenon"] = function()
    LOOTER.SetIgnoreStolenItemsStatus(true)
    SOUNDS.PlayAddonActivated()
end
SLASH_COMMANDS["/looterignorestolenoff"] = function()
    LOOTER.SetIgnoreStolenItemsStatus(false)
    SOUNDS.PlayAddonDeactivated()
end
SLASH_COMMANDS["/looterignorestolenstatus"] = function() LOOTER.GetIgnoreStolenItemsStatus() end
SLASH_COMMANDS["/looterdisplayunopenedcontainers"] = DisplayUnopenedContainers