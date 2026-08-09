-- EsoCombatLock - on-screen lock indicator facade

local ECL = EsoCombatLock
ECL.Indicator = ECL.Indicator or {}
local Indicator = ECL.Indicator
local State = Indicator.State

function Indicator.SetPlayerInCombat(inCombat)
    State.playerInCombat = inCombat == true
    if State.playerInCombat then
        Indicator.Reposition.Exit()
    end
    Indicator.Visibility.Refresh()
    Indicator.Icon.Refresh()
end

function Indicator.Initialize()
    Indicator.Frame.Initialize()
end

function Indicator.Register()
    Indicator.Visibility.Register()
end

function Indicator.OnArmed(collectibleId)
    Indicator.Icon.SetArmedCollectibleId(collectibleId)
    Indicator.Icon.Refresh()
    Indicator.Visibility.Refresh()
end

function Indicator.OnDisarmed()
    Indicator.Icon.ClearArmedCollectibleId()
    Indicator.Visibility.Refresh()
    Indicator.Icon.Refresh()
end

function Indicator.GetDebugState()
    return Indicator.Diagnostics.GetDebugState()
end

--- Forces the combat highlight on outside of combat so a missing effect can be
--- diagnosed as a draw problem rather than a combat-state problem.
function Indicator.ToggleForcedCombatHighlight()
    State.forceCombatHighlight = not State.forceCombatHighlight
    Indicator.Visibility.Refresh()
    return State.forceCombatHighlight
end

function Indicator.DescribeHighlightControls()
    return Indicator.Diagnostics.DescribeHighlightControls()
end

function Indicator.DescribeHaloTextures()
    return Indicator.Diagnostics.DescribeHaloTextures()
end

function Indicator.DescribeParkPreviewControl()
    return Indicator.Diagnostics.DescribeParkPreviewControl()
end

function Indicator.SetHaloTextureIndex(index)
    return Indicator.Halo.SetTextureIndex(index)
end

function Indicator.ClearHaloTextureOverride()
    return Indicator.Halo.ClearTextureOverride()
end

function Indicator.Refresh()
    Indicator.Visibility.Refresh()
end

function Indicator.ResetPosition()
    if not State.db() then
        return
    end
    State.db().indicatorX = ECL.defaults.indicatorX
    State.db().indicatorY = ECL.defaults.indicatorY
    Indicator.Frame.RestorePosition()
    ECL.Chat("Indicator location reset to default")
    Indicator.Visibility.Refresh()
end

function Indicator.TogglePositionLock()
    Indicator.Reposition.Toggle()
end
