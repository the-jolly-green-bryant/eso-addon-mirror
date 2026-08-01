local class = ZO_InitializingObject:Subclass()
servantFoodDrinkThirdParty = class

function class:Initialize(owner)
    self.owner = owner
    self:ags()
end

function class:ags()
    if AwesomeGuildStore == nil or AwesomeGuildStore.GetAPIVersion() ~= 4 then
        return
    end

    local owner = self.owner

    AwesomeGuildStore:RegisterCallback(AwesomeGuildStore.callback.AFTER_FILTER_SETUP, function()
        AwesomeGuildStore.data.FILTER_ID.FOOD_DRINK_KNOWLEDGE_FILTER = 299

        local FoodDrinkKnowledgeFilter = AwesomeGuildStore.class.MultiChoiceFilterBase:Subclass()
        AwesomeGuildStore.class.FoodDrinkKnowledgeFilter = FoodDrinkKnowledgeFilter

        function FoodDrinkKnowledgeFilter:New(...)
            return AwesomeGuildStore.class.MultiChoiceFilterBase.New(self, ...)
        end

        function FoodDrinkKnowledgeFilter:Initialize()
            AwesomeGuildStore.class.MultiChoiceFilterBase.Initialize(self, AwesomeGuildStore.data.FILTER_ID.FOOD_DRINK_KNOWLEDGE_FILTER, AwesomeGuildStore.class.FilterBase.GROUP_LOCAL, "FoodDrink", {
                {
                    id = true,
                    label = "Known",
                    icon = "esoui/art/collections/collections_categoryicon_unlocked_%s.dds",
                },
                {
                    id = false,
                    label = "Unknown",
                    icon = "esoui/art/collections/collections_tabIcon_itemSets_%s.dds",
                },
            })
            self:SetEnabledSubcategories({
                --[AwesomeGuildStore.data.SUB_CATEGORY_ID.CONSUMABLE_ALL] = true,
                [AwesomeGuildStore.data.SUB_CATEGORY_ID.CONSUMABLE_FOOD] = true,
                [AwesomeGuildStore.data.SUB_CATEGORY_ID.CONSUMABLE_DRINK] = true,
            })
        end

        function FoodDrinkKnowledgeFilter:FilterLocalResult(itemData)
            local itemId = GetItemLinkItemId(itemData.itemLink)
            if owner.dataProvider:GetData()[itemId] ~= true then
                return false
            end

            local id = owner.data[itemId] ~= nil
            local value = self.valueById[id]

            return self.localSelection[value]
        end

        AwesomeGuildStore:RegisterFilter(AwesomeGuildStore.class.FoodDrinkKnowledgeFilter:New())
        AwesomeGuildStore:RegisterFilterFragment(AwesomeGuildStore.class.MultiButtonFilterFragment:New(AwesomeGuildStore.data.FILTER_ID.FOOD_DRINK_KNOWLEDGE_FILTER))
    end)
end
