-----------------------------------------------------------------------------------
-- Addon Name: Rulebased Inventory - Rulebased GuildStore
-- Creator: otac0n
-- Addon Description: AwesomeGuildStore integration
--
-- File Name: RulebasedGuildStore.lua
-- Load Order Requirements: Last
-----------------------------------------------------------------------------------
local RbI = RulebasedInventory

ZO_CreateStringId("AGS_RULE_BASED_SEARCH", "Rulebased Search")
RulebasedGuildStore = {
    EVENT_KEY = "RulebasedGuildStore",
    RULE_NAME = "GuildSearchFilter",
    TASK_NAME = "SearchGuildStore",
}

EVENT_MANAGER:RegisterForEvent(RulebasedGuildStore.EVENT_KEY, EVENT_ADD_ON_LOADED, function (eventCode, name)
    if RulebasedGuildStore:Initialize() then
        EVENT_MANAGER:UnregisterForEvent(RulebasedGuildStore.EVENT_KEY, EVENT_ADD_ON_LOADED)
    end
end)

function RulebasedGuildStore:Initialize()
    local AGS = AwesomeGuildStore
    if not AGS or AGS.GetAPIVersion == nil then
        return false
    elseif AGS.GetAPIVersion() ~= 4 then
        -- skip initialization for unsupported versions
        return true
    end

    local ruleEnv = RbI.ruleEnvironment
    local ctx = RbI.executionEnv.ctx

    local FilterBase = AGS.class.FilterBase
    local TextFilter = AGS.class.TextFilter
    local TextFilterFragment = AGS.class.TextFilterFragment
    local SimpleInputBox = AGS.class.SimpleInputBox

    local FILTER_ID = AGS:GetFilterIds()
    if not FILTER_ID.RULEBASED_INVENTORY then
        FILTER_ID.RULEBASED_INVENTORY = 107
    end

    local RulebasedFilter = TextFilter:Subclass()
    RulebasedGuildStore.RulebasedFilter = RulebasedFilter
    RulebasedFilter.ApplyToSearch = FilterBase.ApplyToSearch
    RulebasedFilter.PrepareForSearch = FilterBase.PrepareForSearch

    function RulebasedFilter:Initialize(searchManager)
        FilterBase.Initialize(self, FILTER_ID.RULEBASED_INVENTORY, FilterBase.GROUP_SERVER, GetString(AGS_RULE_BASED_SEARCH))
        self.text = ""
    end

    function TextFilter:SetText(text)
        self.text = text
        self:HandleChange(text)
    end

    function RulebasedFilter:SetUpLocalFilter(text)
        if self:IsDefault(text) then
            self.rule = nil
            return false
        else
            if not self.rule or self.rule.content ~= text then
                self.rule = RbI.BaseRule(RulebasedGuildStore.RULE_NAME, true, text)
            end
            return true
        end
    end

    local NOT_A_BAG_SLOT = -1
    function RulebasedFilter:FilterLocalResult(itemData)
        if not self.rule then return false end
        local cache = self.rule.cache
        if not cache then
            cache = {}
            self.rule.cache = cache
        end

        local itemLink = itemData.itemLink
        local cacheKey = itemLink .. "@" .. itemData.purchasePrice .. "/" .. itemData.stackCount
        local cached = cache[cacheKey]
        if cached ~= nil then
            return cached
        end

        RbI.testrun = true
        ctx.amountHelper = {}
        ctx.amountHelper.count = {}
        ctx.buyInfo = {
            currency = CURT_MONEY,
            stackPrice = itemData.purchasePrice,
            stackCount = itemData.stackCount,
            stackCountMax = itemData.stackCount,
        }
        local status, result = ruleEnv.RunRuleWithItem(self.rule, NOT_A_BAG_SLOT, NOT_A_BAG_SLOT, itemLink, RulebasedGuildStore.TASK_NAME)
        ctx.buyInfo = nil
        RbI.testrun = false
        if not status then self.rule = nil end
        cached = (status and result and true) or false
        cache[cacheKey] = cached
        return cached
    end

    local RulebasedFilterFragment = TextFilterFragment:Subclass()
    RulebasedGuildStore.RulebasedFilterFragment = RulebasedFilterFragment

    function RulebasedFilterFragment:InitializeControls()
        local container = self:GetContainer()

        local inputContainer = CreateControlFromVirtual("$(parent)Input", container, "AwesomeGuildStoreTextSearchInputTemplate")
        inputContainer:SetAnchor(TOPLEFT, container, TOPLEFT, 5, 4)
        inputContainer:SetAnchor(TOPRIGHT, container, TOPRIGHT, -5, 4)

        self.input = SimpleInputBox:New(inputContainer:GetNamedChild("Input"))
        self.input:SetMaxInputChars(30000)
    end

    function RulebasedFilterFragment:InitializeHandlers()
        local input = self.input
        local fromCallback = false

        local function OnInputChanged(input, value)
            if(fromCallback) then return end
            self.filter:SetText(value)
        end

        local function OnFilterChanged(self, text)
            fromCallback = true
            input:SetValue(text)
            fromCallback = false
        end

        input.OnValueChanged = OnInputChanged
        self.OnValueChanged = OnFilterChanged
    end

    AGS:RegisterCallback(AGS.callback.AFTER_FILTER_SETUP, function(...)
        AGS:RegisterFilter(RulebasedFilter:New())
        AGS:RegisterFilterFragment(RulebasedFilterFragment:New(FILTER_ID.RULEBASED_INVENTORY))
    end)

    return true
end
