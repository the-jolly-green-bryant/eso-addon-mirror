local class = ZO_InitializingObject:Subclass()
unknownInsightThirdParty = class

function class:Initialize(owner)
    self.owner = owner
    self.name = string.format("%sThirdParty", self.owner.name)

    self:ags()
end

function class:ags()
    if AwesomeGuildStore == nil or AwesomeGuildStore.GetAPIVersion() ~= 4 then
        return
    end

    local owner = self.owner

    AwesomeGuildStore:RegisterCallback(AwesomeGuildStore.callback.AFTER_FILTER_SETUP, function()
        AwesomeGuildStore.data.FILTER_ID.UNKNOWN_INSIGHT_FILTER = 394

        local UnknownInsightFilter = AwesomeGuildStore.class.MultiChoiceFilterBase:Subclass()
        AwesomeGuildStore.class.UnknownInsightFilter = UnknownInsightFilter

        function UnknownInsightFilter:New(...)
            return AwesomeGuildStore.class.MultiChoiceFilterBase.New(self, ...)
        end

        function UnknownInsightFilter:Initialize()
            AwesomeGuildStore.class.MultiChoiceFilterBase.Initialize(self, AwesomeGuildStore.data.FILTER_ID.UNKNOWN_INSIGHT_FILTER, AwesomeGuildStore.class.FilterBase.GROUP_LOCAL, "Unknown Insight", {
                {
                    id = true,
                    label = "Known by all",
                    icon = "esoui/art/collections/collections_categoryicon_unlocked_%s.dds",
                },
                {
                    id = false,
                    label = "Unknown by any",
                    icon = "esoui/art/collections/collections_tabIcon_itemSets_%s.dds",
                },
            })
            self:SetEnabledSubcategories({
                [AwesomeGuildStore.data.SUB_CATEGORY_ID.CONSUMABLE_RECIPE] = true,
                [AwesomeGuildStore.data.SUB_CATEGORY_ID.CONSUMABLE_MOTIF] = true,
            })
        end

        function UnknownInsightFilter:FilterLocalResult(itemData)
            local id = not owner:IsUnknownByAnyone(itemData.itemLink)
            local value = self.valueById[id]
            return self.localSelection[value]
        end

        AwesomeGuildStore:RegisterFilter(AwesomeGuildStore.class.UnknownInsightFilter:New())
        AwesomeGuildStore:RegisterFilterFragment(AwesomeGuildStore.class.MultiButtonFilterFragment:New(AwesomeGuildStore.data.FILTER_ID.UNKNOWN_INSIGHT_FILTER))
    end)
end
