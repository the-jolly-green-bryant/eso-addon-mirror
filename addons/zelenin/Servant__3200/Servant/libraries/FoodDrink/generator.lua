-- lua5.4 generator.lua > DataProvider.lua
package.path="/mnt/c/Users/aleks/Documents/Elder Scrolls Online/live/SavedVariables/?.lua;"..package.path

require "LibItemDatabase"
require "CookingUI"

local function OrderedIterator(t)
    local indexes = {}
    for k, v in pairs(t) do
        table.insert(indexes, k)
    end

    table.sort(indexes)

    local i = 0
    local count = #indexes

    return function()
        if i < count then
            i = i + 1
            return indexes[i], t[indexes[i]]
        end
    end
end

local knownItems = {}
local categories = {}
for _, recipeList in ipairs(CookingUIDataProviderData.recipeLists) do
    if recipeList.craftingStationTypes[5] == true and (recipeList.specialIngredientTypes[1] == true or recipeList.specialIngredientTypes[2] == true) then
        local category = {
            name = recipeList.name,
            items = {}
        }
        for _, recipe in pairs(recipeList.recipes) do
            if recipe.resultItemId > 0 then
                category.items[recipe.resultItemId] = true
                knownItems[recipe.resultItemId] = true
            end
        end
        table.insert(categories, category)
    end
end

local category = {
    name = "Other",
    items = {}
}

for _, itemData in pairs(LibItemDatabaseData.items) do
    if itemData.itemType == 4 or itemData.itemType == 12 then
        if knownItems[itemData.id] ~= true then
            category.items[itemData.id] = true
            knownItems[itemData.id] = true
        end
    end
end

table.insert(categories, category)



print([[local class = ZO_InitializingObject:Subclass()
servantFoodDrinkDataProvider = class

function class:Initialize()
    self.data = {]])

for _, category in ipairs(categories) do
    print("        -- " .. category.name)
    for itemId, _ in OrderedIterator(category.items) do
        print(string.format("        [%d] = true, -- %s", itemId, LibItemDatabaseData.items[itemId].name))
    end
end

print([[
    }
end]])

print([[

function class:GetData()
    return self.data
end]])
