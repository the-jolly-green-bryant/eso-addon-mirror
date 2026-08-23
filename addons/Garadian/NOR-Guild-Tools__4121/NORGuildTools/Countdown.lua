local NGT = NORGuildTools
NGT.Countdown = {}
local CD = NGT.Countdown

CD.active = true        -- you can toggle this later
CD.control = nil
CD.currentTimer = nil

------------------------------------------------------------
-- UI Creation
------------------------------------------------------------
local function CreateCountdownControl()
    if CD.control then return end

    CD.control = WINDOW_MANAGER:CreateControl("NOR_CountdownControl", GuiRoot, CT_LABEL)
    CD.control:SetFont("ZoFontCallout")
    CD.control:SetColor(1, 0.8, 0.2, 1)
    CD.control:SetAnchor(CENTER, GuiRoot, CENTER, 0, -200)
    CD.control:SetHidden(true)
end

------------------------------------------------------------
-- Countdown Logic
------------------------------------------------------------
local function StartCountdown(seconds)
    CreateCountdownControl()

    if CD.currentTimer then
        EVENT_MANAGER:UnregisterForUpdate("NOR_CountdownTick")
    end

    local remaining = seconds
    CD.control:SetHidden(false)
    CD.control:SetText(remaining)

    EVENT_MANAGER:RegisterForUpdate("NOR_CountdownTick", 1000, function()
        remaining = remaining - 1

        if remaining <= 0 then
            CD.control:SetText("GO!")
            PlaySound(SOUNDS.DUEL_START)   -- Final second sound
            zo_callLater(function()
                CD.control:SetHidden(true)
            end, 1200)

            EVENT_MANAGER:UnregisterForUpdate("NOR_CountdownTick")
            return
        end

        CD.control:SetText(remaining)
        PlaySound(SOUNDS.COUNTDOWN_TICK)
    end)
end

------------------------------------------------------------
-- Chat Detection
------------------------------------------------------------
local function OnChatMessage(_, messageType, from, text)
    if not CD.active then return end

    local msg = text:lower()

    -- Matches:
    -- "inc 5", "incoming 5", "inc in 5", "incoming in 5"
    local seconds =
        msg:match("inc%w*%s*in%s*(%d+)") or
        msg:match("inc%w*%s*(%d+)") or
        msg:match("incoming%s*(%d+)")

    seconds = tonumber(seconds)

    if seconds and seconds > 0 and seconds <= 10 then
        StartCountdown(seconds)
    end
end

------------------------------------------------------------
-- Enable / Disable
------------------------------------------------------------
function CD:Enable()
    if CD.active then return end
    CD.active = true
    EVENT_MANAGER:RegisterForEvent("NOR_CountdownChat", EVENT_CHAT_MESSAGE_CHANNEL, OnChatMessage)
end

function CD:Disable()
    CD.active = false
    EVENT_MANAGER:UnregisterForEvent("NOR_CountdownChat")
end

-- Auto-enable on load
EVENT_MANAGER:RegisterForEvent("NOR_CountdownInit", EVENT_ADD_ON_LOADED, function(_, addonName)
    if addonName ~= "NORGuildTools" then return end
    CD:Enable()
end)
