--------------------------------------------------------------------------------
--                   Zolan's Auto Repair (Repairer)
--------------------------------------------------------------------------------

local ZAR      = Zolan_AR
local Repairer = ZAR.Repairer
local Util     = ZAR.Util

-- ZO
local BAG_BACKPACK        = BAG_BACKPACK
local BAG_WORN            = BAG_WORN
local LINK_STYLE_BRACKETS = LINK_STYLE_DEFAULT
local GetBagSize          = GetBagSize
local GetItemCondition    = GetItemCondition
local GetItemLink         = GetItemLink
local GetItemName         = GetItemName
local GetItemRepairCost   = GetItemRepairCost
local GetRepairKitTier    = GetRepairKitTier
local GetAmountOfRepairKit= GetAmountRepairKitWouldRepairItem
local RepairItem          = RepairItem
local GetSlotStackSize    = GetSlotStackSize
local GetItemRequiredLevel= GetItemRequiredLevel
local ItemHasDurability   = DoesItemHaveDurability
local RepairItemWithKit   = RepairItemWithRepairKit
local IsItemRepairKit     = IsItemNonCrownRepairKit
local zo_strjoin          = zo_strjoin
-- Lua
local ipairs              = ipairs
local pairs               = pairs
local string              = string
local table               = table
local math                = math

function Repairer.repairItems()
    ZAR.debug("Repairer -> repairItems")

    if not ZAR.savedVars.enabled then return end

    local itemizedList,summaryData = Repairer.generateDetailsOfItemsToBeRepaired()

    if #itemizedList == 0 then
        if ZAR.savedVars.repairNotify then
            Util.sendMessageToChat(string.format(
                '%s%s No Items To Repair',
                ZAR.Vars.outputHeader,
                ZAR.Vars.defaultColor
            ))
        end
        return
    end

    local outputMessages = {}

    if ZAR.savedVars.repairNotify then
        table.insert(outputMessages, string.format(
            "%s%s Repairing Your Items",
            ZAR.Vars.outputHeader,
            ZAR.Vars.defaultColor
        ))
    end

    if ZAR.savedVars.showItemized then
        for _,itemizedData in ipairs(itemizedList) do
            table.insert(outputMessages, Repairer.generateItemizedOutput(itemizedData))
        end
    end

    if ZAR.savedVars.showSummary then
        table.insert(outputMessages, Repairer.generateSummaryOutput(summaryData))
    end

    Repairer.doRepairs(itemizedList)

    if #outputMessages > 0 then
        Util.sendMessageToChat(
            table.concat(outputMessages, "\n")
        )
    end
end

function Repairer.doRepairs(itemizedList)
    ZAR.debug("+_ Repairer -> doRepairs")

    local repaired = false;
    for _,itemizedData in ipairs(itemizedList) do
        repaired = false;
        if ZAR.savedVars.useKits then
            repaired = Repairer.repairItemUsingKits(itemizedData.bagID, itemizedData.slotID)
        end
        if not repaired then
            RepairItem(itemizedData.bagID, itemizedData.slotID)
        end
    end
end

local kits = {}
function Repairer.findKits()
    ZAR.debug("+_ Repairer -> findKits")
    kits = {}
    local bagID = BAG_BACKPACK
  
    for slotID = 0, GetBagSize(bagID) do
        if IsItemRepairKit(bagID, slotID) then
            local kitTier = GetRepairKitTier(bagID, slotID)
            if not kits[kitTier] then kits[kitTier] = {} end
            local count = (GetSlotStackSize(bagID, slotID))
            ZAR.debug("+_ found repair kit in slot " .. slotID .. " with tier " .. kitTier .. " and count " .. count)
            kits[kitTier][slotID] = count
        end
    end
    
    return kits
end

local function GetItemLevelTier(bagID, slotID)
    return math.floor(GetItemRequiredLevel(bagID, slotID) / 10) + 1
end

local function GetRepairKitSlot(kitTier)
    ZAR.debug("+_ GetRepairKitSlot")
    if kits[kitTier] then
        for slotID, count in pairs(kits[kitTier]) do
            ZAR.debug("+_ GetRepairKitSlot(1) slot " .. (slotID or "nil") .. ", count " .. (count or "nil").. ", tier " .. (kitTier or "nil"))
            return slotID, count, kitTier
        end
    else
        kitTier = 0
        while kitTier < 6 do
            kitTier = kitTier + 1
            if kits[kitTier] then
                for slotID, count in pairs(kits[kitTier]) do
                    ZAR.debug("+_ GetRepairKitSlot(2) slot " .. (slotID or "nil") .. ", count " .. (count or "nil").. ", tier " .. (kitTier or "nil"))
                    return slotID, count, kitTier
                end
            end
        end
    end
end

function Repairer.repairItemUsingKits(bagID, slotID)
    ZAR.debug("+_ Repairer -> repairItemUsingKits")
    
    local repaired = false;
    local kitTier = GetItemLevelTier(bagID, slotID)
    local condition = GetItemCondition(bagID, slotID)
    local oldCondition = condition
    ZAR.debug("+_ Repairer condition " .. (condition or "nil") .. ", tier " .. (kitTier or "nil"))
    while condition < 100 do
        local kitSlot, kitCount, kitTier = GetRepairKitSlot(kitTier)
        ZAR.debug("+_ Repairer kitSlot " .. (kitSlot or "nil") .. ", count " .. (kitCount or "nil").. ", tier " .. (kitTier or "nil"))
        if kitSlot then
            local kitAmount = GetAmountOfRepairKit(bagID, slotID, BAG_BACKPACK, kitSlot)
            ZAR.debug("+_ Repairer kitAmount " .. kitAmount)
            RepairItemWithKit(bagID, slotID, BAG_BACKPACK, kitSlot)
            condition = condition + kitAmount
            kits = Repairer.findKits()
            repaired = true
        else
            repaired = false
            break
        end
    end
    
    return repaired, condition
end

function Repairer.repairDamagedItems()
    ZAR.debug("+_ Repairer -> repairDamagedItems")
    
    kits = Repairer.findKits()
    local bagID = BAG_WORN
    local somethingToRepair = false
    for slotID = 0, GetBagSize(bagID) do
        if ItemHasDurability(bagID, slotID) then
            somethingToRepair = true
            local name = GetItemName(bagID, slotID)
            if name ~= "" then
                local itemLink   = GetItemLink(bagID, slotID, LINK_STYLE_BRACKETS)
                if ZAR.savedVars.repairNotify then
                    local repaired, condition = Repairer.repairItemUsingKits(bagID, slotID)
                    if repaired then
                        Util.sendMessageToChat(string.format(
                            '%s repaired using repair kits',
                            Util.formatItemLink(itemLink)
                        ))
                    elseif condition >= 100 then
                        Util.sendMessageToChat(string.format(
                            '%s is already repaired',
                            Util.formatItemLink(itemLink)
                        ))
                    else
                        Util.sendMessageToChat(string.format(
                            '%s could not be repaired using repair kits',
                            Util.formatItemLink(itemLink)
                        ))                    
                    end
                end
            end
        end
    end
    
    if not somethingToRepair and ZAR.savedVars.repairNotify then
        Util.sendMessageToChat(string.format(
            '%s%s No Items To Repair',
            ZAR.Vars.outputHeader,
            ZAR.Vars.defaultColor
        ))    
    end
end

function Repairer.checkArmorStats()
    ZAR.debug("+_ Repairer -> checkArmorStats")
    local bagID = BAG_WORN
    
    for slotID = 0, GetBagSize(bagID) do
        if ItemHasDurability(bagID, slotID) then
            local name = GetItemName(bagID, slotID)
            local itemLink   = GetItemLink(bagID, slotID, LINK_STYLE_BRACKETS)
            local condition = GetItemCondition(bagID, slotID)
            
            Util.sendMessageToChat(string.format(
                '%s%s %s has condition %d',
                ZAR.Vars.outputHeader,
                ZAR.Vars.defaultColor,
                Util.formatItemLink(itemLink),
                condition
            ))
        end
    end
end

function Repairer.generateDetailsOfItemsToBeRepaired()
    ZAR.debug("+_ Repairer -> generateDetailsOfItemsToBeRepaired")

    local bagsToScan = { BAG_WORN }
    if not ZAR.savedVars.repairEquippedOnly then
        table.insert(bagsToScan, BAG_BACKPACK)
    end

    local totalItemCount  = 0
    local totalRepairCost = 0
    local itemizedList    = {}

    for _,bagID in pairs(bagsToScan) do
        for slotID = 0, GetBagSize(bagID) do
            local itemName      = GetItemName(bagID, slotID)
            local itemCondition = GetItemCondition(bagID, slotID)
            if itemName ~= '' and itemCondition < 100 then
                local repairCost = GetItemRepairCost(bagID, slotID)
                local itemLink   = GetItemLink(bagID, slotID, LINK_STYLE_BRACKETS)

                totalItemCount  = totalItemCount  + 1
                totalRepairCost = totalRepairCost + repairCost

                table.insert(itemizedList, {
                    ["itemLink"]       = Util.formatItemLink(itemLink),
                    ["itemCondition"]  = itemCondition,
                    ["repairCost"]     = repairCost,
                    ["bagID"]          = bagID,
                    ["slotID"]         = slotID
                })
            end
        end
    end

    local summaryData = { ["totalItemCount"] = totalItemCount, ["totalRepairCost"] = totalRepairCost }

    return itemizedList, summaryData
end

function Repairer.getConditionColor(itemCondition)
    ZAR.debug("   +_ Repairer -> getConditionColor")
    if itemCondition >= 0 and itemCondition < 25 then
        return '|cFF0000' -- EMERGENCY
    elseif itemCondition >= 25 and itemCondition < 50 then
        return '|cFF8800' -- WARNING
    elseif itemCondition >= 50 and itemCondition < 75 then
        return '|cFFFF00' -- NOTICE
    else
        return '|c00FF00' -- GOOD
    end
end

function Repairer.generateItemizedOutput(itemizedData)
    ZAR.debug("+_ Repairer -> generateItemizedOutput")
    return string.format(
        "%sRepaired %s%s. Condition was %s%s%%%s and cost %s%s gold%s to repair.",
        ZAR.Vars.defaultColor,
        itemizedData.itemLink,
        ZAR.Vars.defaultColor,
        Repairer.getConditionColor(itemizedData.itemCondition),
        itemizedData.itemCondition,
        ZAR.Vars.defaultColor,
        ZAR.Vars.currencyColor,
        itemizedData.repairCost,
        ZAR.Vars.defaultColor
    )
end

function Repairer.generateSummaryOutput(summaryData)
    ZAR.debug("+_ Repairer -> generateSummaryOutput")
    return string.format(
        "%sSummary:%s Repaired %s items at a total cost of %s%s gold %s.",
        ZAR.Vars.headerColor,
        ZAR.Vars.defaultColor,
        summaryData.totalItemCount,
        ZAR.Vars.currencyColor,
        summaryData.totalRepairCost,
        ZAR.Vars.defaultColor
    )
end
