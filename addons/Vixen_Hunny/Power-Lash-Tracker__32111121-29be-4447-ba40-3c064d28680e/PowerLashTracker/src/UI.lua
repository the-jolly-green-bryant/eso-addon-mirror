PLT = PLT or {}
wm = WINDOW_MANAGER
PLT.UI = PLT.UI or {}
PLT.UI_STYLE = {
    containerWidth = 280,
    containerHeight = 115,
    frameWidth = 248,
    frameHeight = 26,
    barWidth = 236,
    barHeight = 14,
}
PLT.UI_THEME = {
    frameCenter = { 0.12, 0.02, 0.01, 0.94 },
    frameEdge = { 0.98, 0.42, 0.05, 1.0 },
    frameInner = { 0.3, 0.05, 0.01, 0.9 },
    innerEdge = { 0.95, 0.3, 0.04, 0.95 },
    gloss = { 1.0, 0.76, 0.28, 0.34 },
    ember = { 1.0, 0.3, 0.06, 0.22 },
    heatCore = { 1.0, 0.58, 0.1, 0.16 },
    stacksCenter = { 0.18, 0.03, 0.01, 0.72 },
    stacksEdge = { 1.0, 0.44, 0.09, 0.9 },
}
PLT.defaultSettings = {
    enabled = true,
    xPosition = 0,
    yPosition = 0,
    buffBarColor = { r = 1, g = 0.78, b = 0.24, a = 0.95 },
    cooldownBarColor = { r = 1, g = 0.33, b = 0.05, a = 0.96 },
    cooldownTextColor = "ff8a2a",
    buffTextColor = "ffd08a",
    uiScale = 1,
}
PLT.BuffTimerNow = PLT.BuffTimerNow or 0
PLT.CooldownTimerNow = PLT.CooldownTimerNow or 0

local function ApplyLabelStyle(labelControl, width, height)
    labelControl:SetDimensions(width, height)
    labelControl:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    labelControl:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    labelControl:SetFont("/esoui/common/fonts/univers67.otf|25|soft-shadow-thick")
end

local function GetExpiredBuffText()
    return string.format("|c%s< POWER LASH EXPIRED >|r", PLT.savedVariables.buffTextColor)
end

local function GetReadyText()
    return string.format("|c%sPOWER LASH READY|r", PLT.savedVariables.cooldownTextColor)
end

local function GetStacksText(currentStacks, maxStacks)
    return string.format("|c%s[%d/%d]|r |c%s STACKS|r", PLT.savedVariables.cooldownTextColor, currentStacks, maxStacks, PLT.savedVariables.buffTextColor)
end

function PLT:OnUpdate(abilityId, abilityType)
    if abilityType == "buff" then
        local now = GetFrameTimeMilliseconds()
            local seconds = ((now - PLT.BuffTimerNow) + PLT.PLBuffTimer) / 1000
            if string.format("%.1f", seconds) == "45.0" then
                PLT.BuffTimerNow = 0
                em:UnregisterForUpdate("PowerLashTracker".."Buff")
                PLT.UI.buffLabel:SetText(GetExpiredBuffText())
                return
            else
                PLT.UI.buffLabel:SetText(string.format("|c%s%.1f|r", PLT.savedVariables.buffTextColor, seconds) .. "s")
            end
    elseif abilityType == "cooldown" then
        local now = GetFrameTimeMilliseconds()
            local seconds = ((now - PLT.CooldownTimerNow) + PLT.PLCooldownTimer) / 1000
            if string.format("%.1f", seconds) == "20.0" then
                em:UnregisterForUpdate("PowerLashTracker".."Cooldown")
                 PLT.UI.BuffBar:SetValue(0)
                 PLT.UI.CooldownTimer:SetText(GetReadyText())
                 return
            else
                PLT.UI.CooldownTimer:SetText(string.format("|c%s%.1f|r", PLT.savedVariables.cooldownTextColor, seconds) .. "s")
                local percent = seconds / 20 * 100
                PLT.UI.BuffBar:SetValue(percent)
            end
    elseif abilityType == "stacks" then
        if PLT.StacksActive == 0 then
            PLT.StacksActive = 0
            PLT.PowerLashActive = false
            PLT.UI.Stacks:SetText(string.format(""))
            em:UnregisterForUpdate("PowerLashTracker".."Stacks")
            return
        
        else
            PLT.UI.Stacks:SetText(GetStacksText(PLT.StacksActive, 5))
        end


    end

end
function PLT:CreateUI()
    local style = PLT.UI_STYLE
    local theme = PLT.UI_THEME
    PLT.UI.Container = _G["PLTContainer"] or wm:CreateTopLevelWindow("PLTContainer")
    PLT.UI.Container:SetDimensions(style.containerWidth, style.containerHeight)
    PLT.UI.Container:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, PLT.savedVariables.xPosition, PLT.savedVariables.yPosition)
    PLT.UI.Container:SetMouseEnabled(false)

    PLT.UI.BarFrame = wm:CreateControl("$(parent)BarFrame", PLT.UI.Container, CT_BACKDROP)
    PLT.UI.BarFrame:SetDimensions(style.frameWidth, style.frameHeight)
    PLT.UI.BarFrame:SetAnchor(TOP, PLT.UI.Container, TOP, 0, 34)
    PLT.UI.BarFrame:SetCenterColor(theme.frameCenter[1], theme.frameCenter[2], theme.frameCenter[3], theme.frameCenter[4])
    PLT.UI.BarFrame:SetEdgeTexture("/esoui/art/miscellaneous/white.dds", 2, 2, 2, 0)
    PLT.UI.BarFrame:SetEdgeColor(theme.frameEdge[1], theme.frameEdge[2], theme.frameEdge[3], theme.frameEdge[4])

    PLT.UI.BarInner = wm:CreateControl("$(parent)BarInner", PLT.UI.Container, CT_BACKDROP)
    PLT.UI.BarInner:SetDimensions(style.barWidth + 4, style.barHeight + 4)
    PLT.UI.BarInner:SetAnchor(CENTER, PLT.UI.BarFrame, CENTER, 0, 0)
    PLT.UI.BarInner:SetCenterColor(theme.frameInner[1], theme.frameInner[2], theme.frameInner[3], theme.frameInner[4])
    PLT.UI.BarInner:SetEdgeTexture("/esoui/art/miscellaneous/white.dds", 1, 1, 1, 0)
    PLT.UI.BarInner:SetEdgeColor(theme.innerEdge[1], theme.innerEdge[2], theme.innerEdge[3], theme.innerEdge[4])

    PLT.UI.BuffBar = wm:CreateControl("$(parent)BuffBar", PLT.UI.Container, CT_STATUSBAR)
    PLT.UI.BuffBar:SetDimensions(style.barWidth, style.barHeight)
    PLT.UI.BuffBar:SetAnchor(CENTER, PLT.UI.BarInner, CENTER, 0, 0)
    PLT.UI.BuffBar:SetTexture("/esoui/art/miscellaneous/progressbar_genericfill.dds")
    PLT.UI.BuffBar:SetColor(PLT.savedVariables.cooldownBarColor.r, PLT.savedVariables.cooldownBarColor.g, PLT.savedVariables.cooldownBarColor.b, PLT.savedVariables.cooldownBarColor.a)
    PLT.UI.BuffBar:SetMinMax(0, 100)
    PLT.UI.BuffBar:SetValue(0)

    PLT.UI.BarEmber = wm:CreateControl("$(parent)BarEmber", PLT.UI.Container, CT_TEXTURE)
    PLT.UI.BarEmber:SetAnchor(TOPLEFT, PLT.UI.BuffBar, TOPLEFT, 0, 0)
    PLT.UI.BarEmber:SetDimensions(style.barWidth, style.barHeight)
    PLT.UI.BarEmber:SetTexture("/esoui/art/miscellaneous/white.dds")
    PLT.UI.BarEmber:SetColor(theme.ember[1], theme.ember[2], theme.ember[3], theme.ember[4])

    PLT.UI.BarHeat = wm:CreateControl("$(parent)BarHeat", PLT.UI.Container, CT_TEXTURE)
    PLT.UI.BarHeat:SetAnchor(CENTER, PLT.UI.BuffBar, CENTER, 0, 0)
    PLT.UI.BarHeat:SetDimensions(style.barWidth - 8, style.barHeight - 4)
    PLT.UI.BarHeat:SetTexture("/esoui/art/miscellaneous/white.dds")
    PLT.UI.BarHeat:SetColor(theme.heatCore[1], theme.heatCore[2], theme.heatCore[3], theme.heatCore[4])

    PLT.UI.BarGloss = wm:CreateControl("$(parent)BarGloss", PLT.UI.Container, CT_TEXTURE)
    PLT.UI.BarGloss:SetAnchor(TOPLEFT, PLT.UI.BuffBar, TOPLEFT, 0, 0)
    PLT.UI.BarGloss:SetDimensions(style.barWidth, 6)
    PLT.UI.BarGloss:SetTexture("/esoui/art/miscellaneous/white.dds")
    PLT.UI.BarGloss:SetColor(theme.gloss[1], theme.gloss[2], theme.gloss[3], theme.gloss[4])

    PLT.UI.buffLabel = wm:CreateControl("$(parent)BuffTimer", PLT.UI.Container, CT_LABEL)
    PLT.UI.buffLabel:SetAnchor(BOTTOM, PLT.UI.BarFrame, TOP, 0, -8)
    ApplyLabelStyle(PLT.UI.buffLabel, style.containerWidth, 34)
    PLT.UI.buffLabel:SetText("|c"..PLT.savedVariables.buffTextColor.."POWER LASH BUFF EXPIRED|r")

    PLT.UI.CooldownTimer = wm:CreateControl("$(parent)CooldownTimer", PLT.UI.Container, CT_LABEL)
    PLT.UI.CooldownTimer:SetAnchor(CENTER, PLT.UI.BarFrame, CENTER, 0, 0)
    PLT.UI.CooldownTimer:SetColor(PLT.savedVariables.cooldownBarColor.r, PLT.savedVariables.cooldownBarColor.g, PLT.savedVariables.cooldownBarColor.b, PLT.savedVariables.cooldownBarColor.a)
    ApplyLabelStyle(PLT.UI.CooldownTimer, style.containerWidth, 34)
    PLT.UI.CooldownTimer:SetText("|c"..PLT.savedVariables.cooldownTextColor.."POWER LASH READY|r")

    PLT.UI.StacksFrame = wm:CreateControl("$(parent)StacksFrame", PLT.UI.Container, CT_BACKDROP)
    PLT.UI.StacksFrame:SetDimensions(style.frameWidth - 44, 24)
    PLT.UI.StacksFrame:SetAnchor(TOP, PLT.UI.BarFrame, BOTTOM, 0, 9)
    PLT.UI.StacksFrame:SetCenterColor(theme.stacksCenter[1], theme.stacksCenter[2], theme.stacksCenter[3], theme.stacksCenter[4])
    PLT.UI.StacksFrame:SetEdgeTexture("/esoui/art/miscellaneous/white.dds", 1, 1, 1, 0)
    PLT.UI.StacksFrame:SetEdgeColor(theme.stacksEdge[1], theme.stacksEdge[2], theme.stacksEdge[3], theme.stacksEdge[4])

    PLT.UI.Stacks = wm:CreateControl("$(parent)Stacks", PLT.UI.Container, CT_LABEL)
    PLT.UI.Stacks:SetAnchor(CENTER, PLT.UI.StacksFrame, CENTER, 0, 0)
    ApplyLabelStyle(PLT.UI.Stacks, style.containerWidth, 28)

    PLT.UI.Container:SetScale(PLT.savedVariables.uiScale)
end
function PLT:UpdateUI()
    local style = PLT.UI_STYLE
    local theme = PLT.UI_THEME
    local container = _G["PLTContainer"]
    if not container then
        return
    end

    container:SetDimensions(style.containerWidth, style.containerHeight)
    container:SetHidden(not PLT.savedVariables.enabled)
    container:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, PLT.savedVariables.xPosition, PLT.savedVariables.yPosition)
    PLT.UI.Container:SetScale(PLT.savedVariables.uiScale)

    if PLT.UI.BarFrame then
        PLT.UI.BarFrame:SetCenterColor(theme.frameCenter[1], theme.frameCenter[2], theme.frameCenter[3], theme.frameCenter[4])
        PLT.UI.BarFrame:SetEdgeColor(theme.frameEdge[1], theme.frameEdge[2], theme.frameEdge[3], theme.frameEdge[4])
    end

    if PLT.UI.BarInner then
        PLT.UI.BarInner:SetCenterColor(theme.frameInner[1], theme.frameInner[2], theme.frameInner[3], theme.frameInner[4])
        PLT.UI.BarInner:SetEdgeColor(theme.innerEdge[1], theme.innerEdge[2], theme.innerEdge[3], theme.innerEdge[4])
    end

    if PLT.UI.BarEmber then
        PLT.UI.BarEmber:SetColor(theme.ember[1], theme.ember[2], theme.ember[3], theme.ember[4])
    end

    if PLT.UI.BarHeat then
        PLT.UI.BarHeat:SetColor(theme.heatCore[1], theme.heatCore[2], theme.heatCore[3], theme.heatCore[4])
    end

    if PLT.UI.BarGloss then
        PLT.UI.BarGloss:SetColor(theme.gloss[1], theme.gloss[2], theme.gloss[3], theme.gloss[4])
    end

    if PLT.UI.StacksFrame then
        PLT.UI.StacksFrame:SetCenterColor(theme.stacksCenter[1], theme.stacksCenter[2], theme.stacksCenter[3], theme.stacksCenter[4])
        PLT.UI.StacksFrame:SetEdgeColor(theme.stacksEdge[1], theme.stacksEdge[2], theme.stacksEdge[3], theme.stacksEdge[4])
    end

    _G["PLTContainerBuffBar"]:SetColor(PLT.savedVariables.cooldownBarColor.r, PLT.savedVariables.cooldownBarColor.g, PLT.savedVariables.cooldownBarColor.b, PLT.savedVariables.cooldownBarColor.a)

    if PLT.BuffTimerNow == 0 then
        PLT.UI.buffLabel:SetText(GetExpiredBuffText())
    end
    if PLT.CooldownTimerNow == 0 then
        PLT.UI.CooldownTimer:SetText(GetReadyText())
    end
end
-- 🔥