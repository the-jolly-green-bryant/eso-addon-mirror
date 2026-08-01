local HARDCORE = HARDCORE

local Rule = {
    id = "NoSoulGems",
    title = "No Soul Gems (no recharging)",
    icon = "/esoui/art/inventory/inventory_tabicon_soulgem_down.dds",
    defaultEnabled = true
}

local NS = "HARDCORE_NoSoulGems"
Rule.active = false
Rule._hooksInstalled = false
Rule._lastAlertMs = 0

local function ShouldThrottleAlert()
    local now = GetFrameTimeMilliseconds()
    if (now - Rule._lastAlertMs) > 1200 then
        Rule._lastAlertMs = now
        return false
    end
    return true
end

local function AlertBlocked()
    if ShouldThrottleAlert() then
        return
    end
    HARDCORE.ShowAlert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NEGATIVE_CLICK, "HARDCORE: Recharging with Soul Gems is disabled.")
end

local function InstallHooks()
    if Rule._hooksInstalled then
        return
    end

    ZO_PreHook("ChargeItemWithSoulGem", function(itemBag, itemSlot, gemBag, gemSlot)
        if Rule.active then
            AlertBlocked()
            return true
        end
    end)

    Rule._hooksInstalled = true
end

function Rule:OnEnable()
    self.active = true
    InstallHooks()
end

function Rule:OnDisable()
    self.active = false
end

HARDCORE.RuleManager:RegisterRule(Rule)
