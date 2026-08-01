LootTrackerSolution.LootStorageModule = {}

local LSM = LootTrackerSolution.LootStorageModule

function LSM:GetGeneralSetting(settingName)
    return LSM.savedVariables["GeneralSettings"][settingName]
end

function LSM:SetGeneralSetting(settingName, value)
    LSM.savedVariables["GeneralSettings"][settingName] = value
end

function LSM:AddLoot(categoryName, itemLink, quantity, priceInfo)
    local loot = LSM.savedVariables["LootData"]["Loot"]
    local category = loot[categoryName]    
    local item = category[itemLink]
    if item == nil then
        item = {
            ["Amount"] = 0,
        }
    end
    if(item["Price"] == nil) then
        item["Price"] = {
            ["TTC"] = {
                ["Average"] = 0,
                ["Min"] = 0,
                ["Max"] = 0,
                ["SuggestedPrice"] = 0,
            },
            ["Vendor"] = 0,
            ["MasterMerchant"] = 0,
        }
    end

    item["Amount"] = item["Amount"] + quantity

    item["Price"]["TTC"]["Average"] = priceInfo["TTC"]["Average"]
    item["Price"]["TTC"]["Min"] = priceInfo["TTC"]["Min"]
    item["Price"]["TTC"]["Max"] = priceInfo["TTC"]["Max"]
    item["Price"]["TTC"]["SuggestedPrice"] = priceInfo["TTC"]["SuggestedPrice"]
    item["Price"]["Vendor"] = priceInfo["Vendor"]
    item["Price"]["MasterMerchant"] = priceInfo["MasterMerchant"]

    category[itemLink] = item
end

function LSM:AddGold(category, priceInfo, quantity)
    local lootData = LSM.savedVariables["LootData"]
    local professionGold = lootData["ProfessionGold"]

    local categoryGold = professionGold[category]
    local totalGold = lootData["TotalGold"]

    local function updateGoldValues(target, source)
        target["TTC"]["Average"] = math.floor(target["TTC"]["Average"] + source["TTC"]["Average"] * quantity)
        target["TTC"]["Min"] = math.floor(target["TTC"]["Min"] + source["TTC"]["Min"] * quantity)
        target["TTC"]["Max"] = math.floor(target["TTC"]["Max"] + source["TTC"]["Max"] * quantity)
        target["TTC"]["SuggestedPrice"] = math.floor(target["TTC"]["SuggestedPrice"] + source["TTC"]["SuggestedPrice"] * quantity)
        target["Vendor"] = math.floor(target["Vendor"] + source["Vendor"] * quantity)
        target["MasterMerchant"] = math.floor(target["MasterMerchant"] + source["MasterMerchant"] * quantity)
    end

    updateGoldValues(categoryGold, priceInfo)
    updateGoldValues(totalGold, priceInfo)
end

function LSM:GetTotalGold()
    local totalGold = LSM.savedVariables["LootData"]["TotalGold"]
    return totalGold
end

function LSM:GetCategoryGold(categoryName)
    local gold = LSM.savedVariables["LootData"]["ProfessionGold"][categoryName]
    return gold
end

function LSM:GetLoot(categoryName)
    if categoryName == nil then
        return LSM.savedVariables["LootData"]["Loot"]
    elseif categoryName ~= nil then
        return LSM.savedVariables["LootData"]["Loot"][categoryName]
    end
end

function LSM:GetStatisticSetting(settingName)
    return LSM.savedVariables["StatisticSettings"][settingName]
end

function LSM:SetStatisticSetting(settingName, value)
    LSM.savedVariables["StatisticSettings"][settingName] = value
end

local function DefaultData()
    return {
        GeneralSettings = {
            ["ShowTime"] = true,
            ["PriceSource"] = 1, 
            ["PriceType"] = 1, 
            ["EnableItemStacking"] = true,
            ["NotifyOnLegendary"] = true,
            ["NotifyOnNirncrux"] = true,
            ["TextNotify"] = true,
            ["NotificationSound"] = 1, 
            ["SortListParametr"] = 1, 
            ["SortListDirection"] = 2, 
            ["AutoLootAfterStart"] = false,
            ["AutoLootDefault"] = false,
            ["InventorySpaceType"] = 1, 
            ["MainWindowAlpha"] = 100,
            ["MainWindowIsHidden"] = true,
            ["MainWindowPosition"] = { 200, 200 },
        },
        LootData = {
            ["Loot"] = {
                ["Blacksmithing"] = {},
                ["Clothing"] = {},
                ["Woodworking"] = {},
                ["Alchemy"] = {},
                ["Enchanting"] = {},
                ["Provisioning"] = {},
                ["Jewelry Crafting"] = {},
                ["Other"] = {},
            },
            ["ProfessionGold"] = {
                ["Blacksmithing"] = { TTC = { Average = 0, Min = 0, Max = 0, SuggestedPrice = 0 }, Vendor = 0, MasterMerchant = 0 },
                ["Clothing"] = { TTC = { Average = 0, Min = 0, Max = 0, SuggestedPrice = 0 }, Vendor = 0, MasterMerchant = 0 },
                ["Woodworking"] = { TTC = { Average = 0, Min = 0, Max = 0, SuggestedPrice = 0 }, Vendor = 0, MasterMerchant = 0 },
                ["Alchemy"] = { TTC = { Average = 0, Min = 0, Max = 0, SuggestedPrice = 0 }, Vendor = 0, MasterMerchant = 0 },
                ["Enchanting"] = { TTC = { Average = 0, Min = 0, Max = 0, SuggestedPrice = 0 }, Vendor = 0, MasterMerchant = 0 },
                ["Provisioning"] = { TTC = { Average = 0, Min = 0, Max = 0, SuggestedPrice = 0 }, Vendor = 0, MasterMerchant = 0 },
                ["Jewelry Crafting"] = { TTC = { Average = 0, Min = 0, Max = 0, SuggestedPrice = 0 }, Vendor = 0, MasterMerchant = 0 },
                ["Other"] = { TTC = { Average = 0, Min = 0, Max = 0, SuggestedPrice = 0 }, Vendor = 0, MasterMerchant = 0 },
            },
            ["TotalGold"] = { TTC = { Average = 0, Min = 0, Max = 0, SuggestedPrice = 0 }, Vendor = 0, MasterMerchant = 0 },
        },
        StatisticSettings = {
            ["SortType"] = 1, 
            ["SortDirection"] = false, 
            ["SelectedCategory"] = 1, 
            ["StatisticPriceType"] = 1, 
            ["StatisticGoldType"] = 1, 
            ["SearchText"] = "",
            ["ShowOnlyMaterials"] = false,
        },
    }
end

function LSM:Initialize()
    LSM.savedVariables = ZO_SavedVars:NewAccountWide("LootTrackerSolutionSavedVariables", 1, nil, DefaultData())
end