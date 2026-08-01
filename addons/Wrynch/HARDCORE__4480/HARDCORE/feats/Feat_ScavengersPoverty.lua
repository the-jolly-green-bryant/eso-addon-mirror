local HARDCORE = HARDCORE

local ID = "ScavengersPoverty"
local NS = "HARDCORE_ScavengersPoverty"

local ICON_SCAVENGERS_POVERTY = "/esoui/art/vendor/vendor_tabicon_sell_up.dds"

local Rule = {
    id = ID,
    title = "Scavenger's Poverty: no vendor economy",
    icon = ICON_SCAVENGERS_POVERTY,
    defaultEnabled = false
}

Rule.active = false
Rule._hooksInstalled = false
Rule._lastAlertMs = 0

local function IsHardcoreActive()
    return HARDCORE and HARDCORE.saved and HARDCORE.saved.isActive
end

local function IsRuleActive()
    return Rule.active and IsHardcoreActive()
end

local function AlertBlocked()
    local now = GetFrameTimeMilliseconds()
    if now - Rule._lastAlertMs > 1200 then
        HARDCORE.ShowAlertNoSuppression(UI_ALERT_CATEGORY_ALERT, SOUNDS.NEGATIVE_CLICK,
            "HARDCORE: Scavenger's Poverty forbids vendors, fences, buying, selling, and laundering.")
        Rule._lastAlertMs = now
    end
end

local function BlockEconomyAction()
    if IsRuleActive() then
        AlertBlocked()
        return true
    end
end

local function CloseEconomyInteraction()
    if not IsRuleActive() then
        return
    end

    AlertBlocked()
    CloseStore()
    EndInteraction(INTERACTION_VENDOR)
    EndInteraction(INTERACTION_STORE)
end

local function InstallHooks()
    if Rule._hooksInstalled then
        return
    end

    ZO_PreHook("BuyStoreItem", BlockEconomyAction)
    ZO_PreHook("BuybackItem", BlockEconomyAction)
    ZO_PreHook("SellInventoryItem", BlockEconomyAction)
    ZO_PreHook("SellAllJunk", BlockEconomyAction)
    ZO_PreHook("LaunderItem", BlockEconomyAction)

    Rule._hooksInstalled = true
end

local function RegisterEvents()
    EVENT_MANAGER:UnregisterForEvent(NS .. "_STORE", EVENT_OPEN_STORE)
    EVENT_MANAGER:UnregisterForEvent(NS .. "_FENCE", EVENT_OPEN_FENCE)

    EVENT_MANAGER:RegisterForEvent(NS .. "_STORE", EVENT_OPEN_STORE, CloseEconomyInteraction)
    EVENT_MANAGER:RegisterForEvent(NS .. "_FENCE", EVENT_OPEN_FENCE, CloseEconomyInteraction)
end

local function UnregisterEvents()
    EVENT_MANAGER:UnregisterForEvent(NS .. "_STORE", EVENT_OPEN_STORE)
    EVENT_MANAGER:UnregisterForEvent(NS .. "_FENCE", EVENT_OPEN_FENCE)
end

function Rule:OnEnable()
    self.active = true
    InstallHooks()
    RegisterEvents()
end

function Rule:OnDisable()
    self.active = false
    UnregisterEvents()
end

HARDCORE.RuleManager:RegisterRule(Rule)
