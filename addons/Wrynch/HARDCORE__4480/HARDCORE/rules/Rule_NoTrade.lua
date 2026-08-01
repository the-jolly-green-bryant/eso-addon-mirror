local HARDCORE = HARDCORE

local Rule = {
    id = "NoTrade",
    title = "No trading (players)",
    icon = "/esoui/art/icons/emotes/emotecategoryicon_social.dds",
    defaultEnabled = true,
}

local NS = "HARDCORE_NoTrade"
Rule.active = false
Rule._hooksInstalled = false
Rule._lastAlertMs = 0

local function Throttle()
    local now = GetFrameTimeMilliseconds()
    if (now - Rule._lastAlertMs) > 1200 then
        Rule._lastAlertMs = now
        return false
    end
    return true
end

local function Announce()
    if Throttle() then return end
    HARDCORE.ShowAlert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NEGATIVE_CLICK, "HARDCORE: Trading with other players is disabled.")
end

local function SafeHideTrade()
    zo_callLater(function()
        if TradeCancel then TradeCancel() end
        if SCENE_MANAGER and SCENE_MANAGER:GetCurrentScene() and SCENE_MANAGER:GetCurrentScene():GetName() == "trade" then
            SCENE_MANAGER:ShowBaseScene()
        end
    end, 50)
end

local function InstallHooks()
    if Rule._hooksInstalled then return end

    if TradeInvite then
        ZO_PreHook("TradeInvite", function(target)
            if Rule.active then
                Announce()
                return true
            end
        end)
    end
    if TradeInviteByName then
        ZO_PreHook("TradeInviteByName", function(playerName)
            if Rule.active then
                Announce()
                return true
            end
        end)
    end

    if TradeInviteAccept then
        ZO_PreHook("TradeInviteAccept", function()
            if Rule.active then
                Announce()
                if TradeInviteDecline then TradeInviteDecline() end
                return true
            end
        end)
    end

    if EVENT_TRADE_INVITE_CONSIDERING then
        EVENT_MANAGER:RegisterForEvent(NS .. "_INVITE", EVENT_TRADE_INVITE_CONSIDERING, function(_, inviterCharacterName, inviterDisplayName)
            if Rule.active and TradeInviteDecline then
                TradeInviteDecline()
                Announce()
            end
        end)
    end

    if TradeSetMoney then
        ZO_PreHook("TradeSetMoney", function(amount)
            if Rule.active then
                Announce()
                return true
            end
        end)
    end
    if TradeEdit then
        ZO_PreHook("TradeEdit", function()
            if Rule.active then
                Announce()
                return true
            end
        end)
    end
    if TradeRemoveItem then
        ZO_PreHook("TradeRemoveItem", function(idx)
            if Rule.active then
                Announce()
                return true
            end
        end)
    end

    local tradeScene = SCENE_MANAGER and SCENE_MANAGER:GetScene("trade")
    if tradeScene then
        tradeScene:RegisterCallback("StateChange", function(_, newState)
            if Rule.active and newState == SCENE_SHOWING then
                Announce()
                SafeHideTrade()
            end
        end)
    end

    Rule._hooksInstalled = true
end

function Rule:OnEnable()
    self.active = true
    InstallHooks()
    SafeHideTrade()
end

function Rule:OnDisable()
    self.active = false
end

HARDCORE.RuleManager:RegisterRule(Rule)
