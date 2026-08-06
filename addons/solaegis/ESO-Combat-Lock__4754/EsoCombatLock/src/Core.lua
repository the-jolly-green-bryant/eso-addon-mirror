-- EsoCombatLock - Core namespace, constants, and helpers

EsoCombatLock = EsoCombatLock or {}
local ECL = EsoCombatLock

ECL.NAME = "EsoCombatLock"
ECL.DISPLAY_NAME = "ESO Combat Lock"
ECL.VERSION = "1.0.1"
ECL.AUTHOR = "solaegis"

-- LAM panel links (solaegis addon scaffold; update website/feedback after ESOUI publish)
ECL.WEBSITE_URL = "https://github.com/solaegis/eso-combat-lock"
ECL.FEEDBACK_URL = "https://github.com/solaegis/eso-combat-lock/issues"
ECL.DONATION_URL = "https://www.buymeacoffee.com/lewisvavasw"
ECL.DONATION_ACCOUNT = "@solaegis"
ECL.DONATION_GOLD_DEFAULT = 5000

ECL.SV_NAME = "EsoCombatLockSettings"
ECL.SV_VERSION = 2

-- Modern ESO quickslot wheel uses 1 .. ACTION_BAR_UTILITY_BAR_SIZE with
-- HOTBAR_CATEGORY_QUICKSLOT_WHEEL. Confirmed by AUI / ActionDurationReminder
-- usage of GetCurrentQuickslot() + HOTBAR_CATEGORY_QUICKSLOT_WHEEL.
-- /eclprobe dumps both bases so this can be re-verified after API bumps.
ECL.HOTBAR = HOTBAR_CATEGORY_QUICKSLOT_WHEEL

ECL.NONE_KEY = "__none__"

ECL.ALERT_NONE = "none"
ECL.ALERT_CHAT = "chat"
ECL.ALERT_CSA = "csa"
ECL.ALERT_BOTH = "both"

ECL.db = nil
ECL.defaults = nil

------------------------------------------------------------
-- Logging / announcements
------------------------------------------------------------

local function chatPrefix()
    return "|c7EC8E3[ECL]|r "
end

function ECL.Chat(message)
    d(chatPrefix() .. tostring(message))
end

local ALERT_TEXT_CATEGORIES = {
    CSA_CATEGORY_SMALL_TEXT,
    CSA_CATEGORY_LARGE_TEXT,
    CSA_CATEGORY_MAJOR_TEXT,
}

function ECL.GetAlertTextSize()
    local size = (ECL.db and ECL.db.alertTextSize) or (ECL.defaults and ECL.defaults.alertTextSize) or 2
    if size < 1 then
        return 1
    end
    if size > 3 then
        return 3
    end
    return size
end

local function getAlertTextCategory()
    return ALERT_TEXT_CATEGORIES[ECL.GetAlertTextSize()] or CSA_CATEGORY_LARGE_TEXT
end

local function showCenterScreenAnnounce(text)
    if not CENTER_SCREEN_ANNOUNCE or not CENTER_SCREEN_ANNOUNCE.CreateMessageParams then
        return false
    end
    local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(getAlertTextCategory(), SOUNDS.NONE)
    params:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_DISPLAY_ANNOUNCEMENT)
    params:SetText(text)
    if params.SetLifespanMS then
        params:SetLifespanMS(3000)
    end
    if params.MarkShowImmediately then
        params:MarkShowImmediately()
    end
    if params.MarkQueueImmediately then
        params:MarkQueueImmediately()
    end
    CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
    return true
end

function ECL.Announce(message, forceChat)
    local mode = (ECL.db and ECL.db.alertVerbosity) or ECL.ALERT_CHAT
    local text = tostring(message)

    if forceChat or mode == ECL.ALERT_CHAT or mode == ECL.ALERT_BOTH then
        ECL.Chat(text)
    end

    if mode == ECL.ALERT_CSA or mode == ECL.ALERT_BOTH then
        showCenterScreenAnnounce(text)
    end
end

function ECL.AnnounceCenterScreen(message)
    return showCenterScreenAnnounce(tostring(message))
end

function ECL.Debug(message)
    if ECL.db and ECL.db.debug then
        ECL.Chat("|cAAAAAA" .. tostring(message) .. "|r")
    end
end

------------------------------------------------------------
-- Settings accessors
------------------------------------------------------------

function ECL.IsGuardEnabled()
    return ECL.db == nil or ECL.db.guardEnabled ~= false
end

function ECL.IsResummonEnabled()
    return ECL.db == nil or ECL.db.resummonEnabled ~= false
end

function ECL.IncludeVanityPets()
    return ECL.db and ECL.db.includeVanityPets == true
end

function ECL.GetSubstitute()
    if not ECL.db then
        return nil
    end
    local sub = ECL.db.substitute
    if not sub or not sub.actionType or not sub.actionId then
        return nil
    end
    return sub
end

function ECL.SetSubstitute(actionType, actionId, displayName)
    if not ECL.db then
        return
    end
    if actionType == nil or actionId == nil then
        ECL.db.substitute = nil
        return
    end
    ECL.db.substitute = {
        actionType = actionType,
        actionId = actionId,
        displayName = displayName or "Unknown",
    }
end

function ECL.IsIndicatorAlwaysVisible()
    return ECL.db ~= nil and ECL.db.indicatorAlwaysVisible == true
end

function ECL.IsIndicatorLocked()
    return ECL.db == nil or ECL.db.indicatorLocked ~= false
end

function ECL.IsPressAlertsEnabled()
    return ECL.db == nil or ECL.db.pressAlertsEnabled ~= false
end

function ECL.PreferDetectableNoOp()
    return ECL.db == nil or ECL.db.preferDetectableNoOp ~= false
end
