------------------------------------------------------------
-- RYTICTANK BLOCK HUD v3
-- Uses Hyper Tanking Tools' proven block-state pattern:
-- keep widget visible, toggle indicator opacity from IsBlockActive().
------------------------------------------------------------

RyticTank.Block = {}

local function GetBlockStats()
    local blockCost = 0
    local blockMit = 0

    if GetAdvancedStatValue then
        local _, costValue = GetAdvancedStatValue(1)
        local _, _, mitigationValue = GetAdvancedStatValue(7)
        blockCost = tonumber(costValue) or 0
        blockMit = tonumber(mitigationValue) or 0
    end

    return blockCost, blockMit
end

function RyticTank.Block.CreateHUD()
    local wm = WINDOW_MANAGER

    local window = wm:CreateTopLevelWindow("RyticTankBlockHUD")
    RyticTank.Block.window = window
    -- ESOUI HUD fragment: automatically hide this HUD when menus open.
    local hudFragment = ZO_HUDFadeSceneFragment:New(window, nil, 0)
    HUD_SCENE:AddFragment(hudFragment)
    HUD_UI_SCENE:AddFragment(hudFragment)
    RyticTank.Block.hudFragment = hudFragment
    window:SetDimensions(430, 92)
    window:ClearAnchors()
    window:SetAnchor(
        TOPLEFT, GuiRoot, TOPLEFT,
        RyticTank.saved.block.position.x,
        RyticTank.saved.block.position.y
    )
    window:SetClampedToScreen(true)

    -- This is the actual state indicator. Like HTT's shield:
    -- full alpha while blocking, low alpha while not blocking.
    local state = wm:CreateControl(nil, window, CT_LABEL)
    state:SetFont("ZoFontWinH2")
    state:SetDimensions(210, 40)
    state:SetAnchor(TOPLEFT, window, TOPLEFT, 0, 0)
    state:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    state:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    state:SetText("BLOCK")
    RyticTank.Block.state = state

    local stats = wm:CreateControl(nil, window, CT_LABEL)
    stats:SetFont("ZoFontGameBold")
    stats:SetDimensions(210, 40)
    stats:SetAnchor(LEFT, state, RIGHT, 10, 0)
    stats:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    stats:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    RyticTank.Block.stats = stats

    window:SetHandler("OnMoveStop", function()
        RyticTank.saved.block.position.x = window:GetLeft()
        RyticTank.saved.block.position.y = window:GetTop()
    end)

    RyticTank.Block.ApplyLock()
end

function RyticTank.Block.ApplyLock()
    local window = RyticTank.Block.window
    if not window then return end

    local movable = not RyticTank.saved.block.locked
    window:SetMovable(movable)
    window:SetMouseEnabled(movable)
    window:SetScale(RyticTank.saved.block.scale or 1.0)
end

function RyticTank.Block.Update()
    local window = RyticTank.Block.window
    if not window then return end

    local s = RyticTank.saved.block

    if not s.enabled then
        window:SetHidden(true)
        return
    end

    -- Keep the Block HUD visible whenever it is enabled.
    -- IsBlockActive() changes only the visual state.
    window:SetHidden(false)

    local blocking = IsBlockActive()
    local blockCost, blockMit = GetBlockStats()

    if blocking then
        RyticTank.Block.state:SetText("BLOCKING")

        -- Full mitigation: make BLOCKING bright green too.
        if blockMit >= 90 then
            RyticTank.Block.state:SetColor(0.10, 1.00, 0.15, 1)
            RyticTank.Block.stats:SetColor(0.10, 1.00, 0.15, 1)
        else
            RyticTank.Block.state:SetColor(1.00, 0.08, 0.08, 1)
            RyticTank.Block.stats:SetColor(1.00, 0.55, 0.55, 1)
        end
        RyticTank.Block.state:SetAlpha(1.0)

        RyticTank.Block.stats:SetAlpha(1.0)
    else
        -- Mimic HTT: still present, but clearly inactive/faded.
        RyticTank.Block.state:SetText("NOT BLOCKING")
        RyticTank.Block.state:SetColor(0.55, 0.55, 0.55, 1)
        RyticTank.Block.state:SetAlpha(0.20)

        if blockMit >= 90 then
            RyticTank.Block.stats:SetColor(0.10, 1.00, 0.15, 1)
            RyticTank.Block.stats:SetAlpha(1.0)
        else
            RyticTank.Block.stats:SetColor(0.55, 0.55, 0.55, 1)
            RyticTank.Block.stats:SetAlpha(0.35)
        end
    end

    RyticTank.Block.stats:SetText(
        string.format("BLOCK MIT %.0f%%", blockMit)
    )
end

function RyticTank.Block.Initialize()
    if not RyticTank.saved.block then
        RyticTank.saved.block = ZO_DeepTableCopy(RyticTank.defaults.block)
    end

    if not RyticTank.saved.block.position then
        RyticTank.saved.block.position = { x = 800, y = 500 }
    end

    RyticTank.Block.CreateHUD()

    -- Match HTT's continuously refreshed combat UI behavior.
    EVENT_MANAGER:RegisterForUpdate(
        "RyticTankBlockStateUpdate",
        50,
        RyticTank.Block.Update
    )

    RyticTank.Block.Update()
end
