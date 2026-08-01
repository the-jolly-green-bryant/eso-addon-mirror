local ADK = AntiDK2
local M   = {}
ADK.UI.MoltenStacks = M

-- Molten Whip row in main panel at Y=176
-- Stacks 0-3: danger at 3 (empowered whip ready)
local Y_START    = 176
local MAX_STACKS = 3
local barLbl, countLbl, statusLbl

local function StackBar(n)
    local filled = math.min(n, MAX_STACKS)
    local empty  = MAX_STACKS - filled
    local color  = (filled >= MAX_STACKS) and "|cFF2020" or "|cF5A9B8"
    return string.rep(color .. "I|r", filled) .. string.rep("|c444455.|r", empty)
end

function M.Init()
    local panel = ADK.UI.MainPanel
    local c     = ADK.COLORS
    local bf    = ADK.UI.BoldFont

    local lbl = ADK.UI.MakeLabel("AntiDK2MoltenLbl", panel, bf(13),
        c.GREY[1], c.GREY[2], c.GREY[3])
    lbl:SetText("Molten Whip")
    lbl:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    lbl:SetAnchor(TOPLEFT, panel, TOPLEFT, 0, Y_START)

    barLbl = ADK.UI.MakeLabel("AntiDK2MoltenBar", panel, bf(14),
        c.WHITE[1], c.WHITE[2], c.WHITE[3])
    barLbl:SetText(StackBar(0))
    barLbl:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    barLbl:SetAnchor(TOPLEFT, panel, TOPLEFT, 90, Y_START)

    countLbl = ADK.UI.MakeLabel("AntiDK2MoltenCount", panel, bf(18),
        c.PINK[1], c.PINK[2], c.PINK[3])
    countLbl:SetText("")
    countLbl:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    countLbl:SetAnchor(TOPRIGHT, panel, TOPRIGHT, 0, Y_START)
end

-- stacks = { [name] = { count = N } }
function M.Refresh(stacks)
    -- Find the highest-stack enemy (most dangerous)
    local maxCount = 0
    for _, e in pairs(stacks) do
        if e.count > maxCount then maxCount = e.count end
    end


    if maxCount >= MAX_STACKS then
        countLbl:SetText("|cFF2020EMPOWERED|r")
        countLbl:SetFont(ADK.UI.BoldFont(13))
        barLbl:SetText(StackBar(maxCount))
    elseif maxCount > 0 then
        countLbl:SetText(maxCount .. "/" .. MAX_STACKS)
        countLbl:SetFont(ADK.UI.BoldFont(18))
        barLbl:SetText(StackBar(maxCount))
    elseif maxCount == 0 then
        countLbl:SetText("")
        barLbl:SetText(StackBar(0))
    elseif maxCount < 0 then
        countLbl:SetText("")
        barLbl:SetText(StackBar(maxCount))
    end
    ADK.UI.SetPanelFlag("molten", maxCount > 0)
end
