-- lua5.4 generator.lua > ContainerDataProvider-new.lua
package.path="/mnt/c/Users/aleks/Documents/Elder Scrolls Online/live/SavedVariables/?.lua;"..package.path

require "LibItemDatabase"

local function printItems(checker)
    if type(checker) ~= "function" then
        checker = function(itemData)
            return true
        end
    end

    local items = {}
    for _, itemData in pairs(LibItemDatabaseData.items) do
        if checker(itemData) then
            table.insert(items, itemData)
        end
    end

    table.sort(items, function(a, b)
        return a.id < b.id
    end)

    for _, itemData in ipairs(items) do
        print(string.format("        --[%d] = true, -- %s", itemData.id, itemData.name))
    end

end

print([[local class = ZO_InitializingObject:Subclass()
rewardsTrackerContainerDataProvider = class

function class:Initialize(owner)
    self.owner = owner
    self.name = string.format("%sContainerDataProvider", self.owner.name)]])

-- container/container
print([[

    self.containers = {]])
printItems(function(itemData)
    return itemData.itemType == 18 and itemData.specializedItemType == 850
end)
print([[
    }]])

-- container/event container
print([[

    self.eventContainers = {]])
printItems(function(itemData)
    return itemData.itemType == 18 and itemData.specializedItemType == 851
end)
print([[
    }]])

-- currency container/currency container
print([[

    self.currencyContainers = {]])
printItems(function(itemData)
    return itemData.itemType == 70 and itemData.specializedItemType == 875
end)
print([[
    }]])

-- fish/fish
print([[

    self.fishes = {]])
printItems(function(itemData)
    return itemData.itemType == 54 and itemData.specializedItemType == 2450
end)
print([[
    }]])

print([[
end
]])

print([[
function class:GetContainers()
    return self.containers
end

function class:GetEventContainers()
    return self.eventContainers
end

function class:GetCurrencyContainers()
    return self.currencyContainers
end

function class:GetFishes()
    return self.fishes
end]])
