-- EsoCombatLock - Core namespace, constants, and helpers

EsoCombatLock = EsoCombatLock or {}
local ECL = EsoCombatLock

ECL.NAME = "EsoCombatLock"
ECL.DISPLAY_NAME = "ESO Combat Lock"
ECL.VERSION = "1.1.0"
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

--- Quickslot-press alerts only (PressWatch + /ecl test*).
function ECL.Announce(message)
    if not ECL.IsPressAlertsEnabled() then
        return
    end
    ECL.Chat(tostring(message))
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
