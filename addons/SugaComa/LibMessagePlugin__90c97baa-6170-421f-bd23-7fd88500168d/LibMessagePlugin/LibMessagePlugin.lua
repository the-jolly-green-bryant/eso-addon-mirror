--------------------------------------------------------------
-- LibMessagePlugin.lua
-- Author: SugaComa (Rik Sprint)
-- Version: 1.1.0
-- Purpose:
--   Lightweight message + alert helper for console-safe addons.
--   Provides unified wrappers for chat, alerts, and center-screen
--   announcements with optional sound and color helpers.
-- 
-- Usage:
--   local MP = LibMessagePlugin
--   MP:Chat("Hello world!")
--   MP:Alert("Top-right alert", MP.SOUNDS.info)
--   MP:Center("Center message!", MP.SOUNDS.warning, MP.COLORS.red)
--------------------------------------------------------------

LibMessagePlugin = LibMessagePlugin or {}
local MP = LibMessagePlugin

MP.name    = "LibMessagePlugin"
MP.version = "1.1.0"

--------------------------------------------------------------
-- Color Helpers
--------------------------------------------------------------
MP.COLORS = {
    red     = "|cFF0000",
    yellow  = "|cFFFF00",
    green   = "|c00FF00",
    cyan    = "|c00FFFF",
    magenta = "|cFF00FF",
    white   = "|cFFFFFF",
    gray    = "|cAAAAAA",
    endc    = "|r",
}

--------------------------------------------------------------
-- Sound Helpers
--------------------------------------------------------------
MP.SOUNDS = {
    info     = SOUNDS.POSITIVE_CLICK,
    warning  = SOUNDS.ABILITY_ULTIMATE_READY,
    error    = SOUNDS.NEGATIVE_CLICK,
    ding     = SOUNDS.DUEL_START,
}

--------------------------------------------------------------
-- Internal Utility: Safe message timing
--------------------------------------------------------------
local MESSAGE_DELAY = 1000
local lastMessageMs = 0

local function delayCall(func)
    local now = GetFrameTimeMilliseconds()
    local delay = math.max(0, (lastMessageMs + MESSAGE_DELAY) - now)
    zo_callLater(function()
        func()
        lastMessageMs = GetFrameTimeMilliseconds()
    end, delay)
end

--------------------------------------------------------------
-- Chat Message
--------------------------------------------------------------
function MP:Chat(msg, color)
    if not msg or msg == "" then return end
    local text = string.format("%s[%s]%s %s",
        color or MP.COLORS.cyan, self.name, MP.COLORS.endc, tostring(msg))
    delayCall(function()
        if CHAT_ROUTER and CHAT_ROUTER.AddSystemMessage then
            CHAT_ROUTER:AddSystemMessage(text)
        else
            d(text)
        end
    end)
end

--------------------------------------------------------------
-- Alert (top-right)
--------------------------------------------------------------
function MP:Alert(msg, sound)
    if not msg or msg == "" then return end
    delayCall(function()
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, sound or SOUNDS.POSITIVE_CLICK, msg)
    end)
end

--------------------------------------------------------------
-- Center Screen Announcement
--------------------------------------------------------------
function MP:Center(msg, sound, color)
    if not msg or msg == "" then return end
    local CSA = CENTER_SCREEN_ANNOUNCE
    delayCall(function()
        if CSA and CSA.CreateMessageParams then
            local params = CSA:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, sound or SOUNDS.POSITIVE_CLICK)
            params:SetText(string.format("%s%s%s", color or MP.COLORS.white, msg, MP.COLORS.endc))
            CSA:DisplayMessage(params)
        else
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, sound or SOUNDS.POSITIVE_CLICK, msg)
        end
    end)
end

--------------------------------------------------------------
-- Debug helper (togglable print)
--------------------------------------------------------------
MP.debug = false

function MP:Debug(msg)
    if self.debug then
        self:Chat("|c888888[DEBUG]|r " .. tostring(msg))
    end
end

--------------------------------------------------------------
-- Ready notification
--------------------------------------------------------------
MP:Chat(string.format("%s v%s loaded.", MP.name, MP.version), MP.COLORS.magenta)
