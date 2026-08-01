AST.Tracker = {}

local T = AST.Tracker
local em = EVENT_MANAGER
local wm = WINDOW_MANAGER
local tlw = nil

function T:Initialize(enabled)
    if not enabled then return; end

    T.TopLevelControl()
    T.BackdropControl()
    T.TrackerElements()

    T.UpdateElements()
    T.SetTrackerPosition()
    T.SetTrackerAlpha(AST.SV.alpha)
end

function T.TopLevelControl()
    tlw = wm:CreateTopLevelWindow("ASTGrid")
    tlw:SetResizeToFitDescendents(true)
    tlw:SetAnchor(CENTER, GuiRoot, CENTER, 0,0)
    tlw:SetMovable(true)
    tlw:SetMouseEnabled(true)
    tlw:SetHandler("OnMoveStop", function(control)
        AST.SV.left = ASTGrid:GetLeft()
	    AST.SV.top  = ASTGrid:GetTop()
    end)
end

function T.BackdropControl()
    local bdBackdrop = wm:CreateControl("$(parent)bdBackDrop", tlw, CT_BACKDROP)
    bdBackdrop:SetEdgeColor(0.4,0.4,0.4, 0)
    bdBackdrop:SetCenterColor(0, 0, 0)
    bdBackdrop:SetAnchor(TOPLEFT, tlw, TOPLEFT, 0, 0)
    bdBackdrop:SetAlpha(0.8)
    bdBackdrop:SetDrawLayer(0)
end

function T.Font(scale)
    local fontSize      = math.floor(18 * scale)
    local fontStyle     = "MEDIUM_FONT"        
    local fontWeight    = "thick-outline" 
    return string.format("$(%s)|$(KB_%s)|%s", fontStyle, fontSize, fontWeight)
end

function T.TrackerElements()
    local windowscale   = AST.SV.windowscale
    local astFont       = T.Font(windowscale)

    for k, v in ipairs(AST.Data.TrackerTimer) do
        local SynergyIcon = wm:CreateControl("$(parent)SynergyIcon"..k, tlw, CT_TEXTURE)
        SynergyIcon:SetScale(1)
        SynergyIcon:SetDrawLayer(1)
        SynergyIcon:SetTexture(AST.Data.SynergyTexture[k])
        SynergyIcon:SetDimensions(40,40)

        local SynergyTimer = wm:CreateControl("$(parent)SynergyTimer"..k, tlw, CT_LABEL)
        SynergyTimer:SetColor(255, 255, 255, 1)
        SynergyTimer:SetFont(astFont)
        SynergyTimer:SetScale(1.0)
        SynergyTimer:SetWrapMode(TEX_MODE_CLAMP)
        SynergyTimer:SetDrawLayer(1)
        SynergyTimer:SetText("0.0")
    end
end

function T.UpdateElements()
    local check = {
        [1] = AST.SV.orb,
        [2] = AST.SV.liq,
        [3] = AST.SV.pur,
        [4] = AST.SV.hea,
        [5] = AST.SV.bon,
        [6] = AST.SV.blo,
        [7] = AST.SV.tra,
        [8] = AST.SV.rad,
        [9] = AST.SV.cha,
        [10] = AST.SV.sha,
        [11] = AST.SV.imp,
        [12] = AST.SV.gra,
        [13] = AST.SV.hir,
        [14] = AST.SV.sol,
        [15] = AST.SV.rob,
        [16] = AST.SV.ago,
        --[[[17] = AST.SV.icy,]]--
    }
    local windowscale   = AST.SV.windowscale
    local counter       = 0
    
    for k, v in ipairs(check) do
        if v then
            ASTGrid:GetNamedChild("SynergyIcon"..k):SetHidden(false)
            ASTGrid:GetNamedChild("SynergyTimer"..k):SetHidden(false)
            T.SetIconPosition(ASTGrid, windowscale, counter, "SynergyIcon"..k)
            T.SetTimerPosition(ASTGrid, windowscale, counter, "SynergyTimer"..k, "SynergyIcon"..k)
            counter = counter + 1
        else 
            ASTGrid:GetNamedChild("SynergyIcon"..k):SetHidden(true)
            ASTGrid:GetNamedChild("SynergyTimer"..k):SetHidden(true)
        end
    end

    T.SetBackgroundDimensions(ASTGrid, windowscale, counter, "bdBackDrop")
end

function T.SetIconPosition(TopLevelControl, windowscale, counter, SynergyIcon)
    SynergyIcon = TopLevelControl:GetNamedChild(SynergyIcon)
    local bdBackDrop = TopLevelControl:GetNamedChild("bdBackDrop")

    if AST.SV.orientation == "vertical" then
        SynergyIcon:SetAnchor(TOPLEFT, bdBackDrop, TOPLEFT, 5 * windowscale, ( 5 + 45 * (counter) ) * windowscale )
    elseif AST.SV.orientation == "compact" then
        SynergyIcon:SetAnchor(TOPLEFT, bdBackDrop, TOPLEFT, ( 5 + 45 * (counter) ) * windowscale, 5 * windowscale)
    else
        SynergyIcon:SetAnchor(TOPLEFT, bdBackDrop, TOPLEFT, ( 5 + 90 * (counter) ) * windowscale, 5 * windowscale)
    end

    SynergyIcon:SetDimensions(40 * windowscale, 40 * windowscale)
end

function T.SetTimerPosition(TopLevelControl, windowscale, counter, SynergyTimer, SynergyIcon)
    SynergyIcon         = TopLevelControl:GetNamedChild(SynergyIcon)
    SynergyTimer        = TopLevelControl:GetNamedChild(SynergyTimer)
    local bdBackDrop    = TopLevelControl:GetNamedChild("bdBackDrop")

    if AST.SV.orientation == "vertical" then
        SynergyTimer:SetAnchor(CENTER, SynergyIcon, CENTER, 45 * windowscale, 0)
    elseif AST.SV.orientation == "compact" then
        SynergyTimer:SetAnchor(CENTER, SynergyIcon, CENTER, 0, 10 * windowscale)
    else
        SynergyTimer:SetAnchor(CENTER, SynergyIcon, CENTER, 45 * windowscale, 0)
    end

    local astFont = T.Font(windowscale)
    SynergyTimer:SetFont(astFont)
end

function T.SetBackgroundDimensions(TopLevelControl, windowscale, counter, bdBackDrop)
    if AST.SV.orientation == "vertical" then
        ASTGridbdBackDrop:SetDimensions(90 * windowscale,(5 + 45 * counter) * windowscale)
    elseif AST.SV.orientation == "compact" then
        ASTGridbdBackDrop:SetDimensions(5 + (45 * counter) * windowscale, 50 * windowscale)
    else
        ASTGridbdBackDrop:SetDimensions((10 + 90 * counter) * windowscale, 50 * windowscale)
    end
end

function T.SetTrackerPosition()
    local left = AST.SV.left
    local top = AST.SV.top
    ASTGrid:ClearAnchors()
    ASTGrid:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

function T.SetTrackerAlpha(value)
    ASTGridbdBackDrop:SetAlpha(value)
    
    if AST.SV.textures then
        for k, v in ipairs(AST.Data.TrackerTimer) do
            local icon = ASTGrid:GetNamedChild("SynergyIcon"..k)
            icon:SetAlpha(value)
        end
    else
        for k, v in ipairs(AST.Data.TrackerTimer) do
            local icon = ASTGrid:GetNamedChild("SynergyIcon"..k)
            icon:SetAlpha(1.0)
        end
    end
end