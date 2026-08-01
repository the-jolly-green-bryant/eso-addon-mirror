local ADK = AntiDK2
local M   = {}
ADK.UI.PowerLashStacks = M

-- Power Lash row in main panel at Y=200
-- Stacks count DOWN from 5 to 0 (5 = freshly empowered = danger)
local Y_START    = 200
local MAX_STACKS = 5
local barLbl, countLbl

local function StackBar(n)
    local filled = math.min(n, MAX_STACKS)
    local empty  = MAX_STACKS - filled
    local color  = (filled >= MAX_STACKS) and "|cFF2020" or "|c5BCEFA"
    return string.rep(color .. "I|r", filled) .. string.rep("|c444455.|r", empty)
end

function M.Init()
    local panel = ADK.UI.MainPanel
    local c     = ADK.COLORS
    local bf    = ADK.UI.BoldFont

    local lbl = ADK.UI.MakeLabel("AntiDK2PLbl", panel, bf(13),
        c.GREY[1], c.GREY[2], c.GREY[3])
    lbl:SetText("Power Lash")
    lbl:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    lbl:SetAnchor(TOPLEFT, panel, TOPLEFT, 0, Y_START)

    barLbl = ADK.UI.MakeLabel("AntiDK2PLBar", panel, bf(14),
        c.WHITE[1], c.WHITE[2], c.WHITE[3])
    barLbl:SetText(StackBar(0))
    barLbl:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    barLbl:SetAnchor(TOPLEFT, panel, TOPLEFT, 90, Y_START)

    countLbl = ADK.UI.MakeLabel("AntiDK2PLCount", panel, bf(18),
        c.LIGHT_BLUE[1], c.LIGHT_BLUE[2], c.LIGHT_BLUE[3])
    countLbl:SetText("")
    countLbl:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    countLbl:SetAnchor(TOPRIGHT, panel, TOPRIGHT, 0, Y_START)
end

-- stacks = { [name] = { count = N } }
function M.Refresh(stacks)
    local maxCount = 0
    for _, e in pairs(stacks) do
        if e.count > maxCount then maxCount = e.count end
    end

    barLbl:SetText(StackBar(maxCount))

    if maxCount >= MAX_STACKS then
        countLbl:SetText("|cFF2020LASH READY|r")
        countLbl:SetFont(ADK.UI.BoldFont(13))
    elseif maxCount > 0 then
        countLbl:SetText(maxCount .. "/" .. MAX_STACKS)
        countLbl:SetFont(ADK.UI.BoldFont(18))
    else
        countLbl:SetText("")
    end
    ADK.UI.SetPanelFlag("powerLash", maxCount > 0)
end
