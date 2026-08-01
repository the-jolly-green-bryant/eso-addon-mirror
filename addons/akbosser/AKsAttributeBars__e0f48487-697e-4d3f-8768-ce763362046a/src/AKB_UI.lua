-- ============================================================================
-- AKsAttributeBars - Main UI Orchestrator Module
-- ============================================================================
-- Orchestrates the UI modules and provides backward compatibility

local AKB = AKsAttributeBars

-- Create UI namespace
AKB.UI = AKB.UI or {}

function AKB.UI.Initialize()
    -- Initialize shield events
    AKB.UI.Manager.InitializeShieldEvents()
    -- Initialize stat change events for live updates
    AKB.UI.Manager.InitializeStatEvents()
end

-- Backward compatibility functions - delegate to Manager module
function AKB.UI.CreatePlayerAttributeBars()
    return AKB.UI.Manager.CreatePlayerAttributeBars()
end

function AKB.UI.UpdateAllBars()
    return AKB.UI.Manager.UpdateAllBars()
end

function AKB.UI.UpdateBarColors()
    return AKB.UI.Manager.UpdateBarColors()
end

function AKB.UI.DestroyPlayerAttributeBars()
    return AKB.UI.Manager.DestroyPlayerAttributeBars()
end

function AKB.UI.SetCustomBarsVisibility(visible)
    return AKB.UI.Manager.SetCustomBarsVisibility(visible)
end

function AKB.UI.GetPlayerBars()
    return AKB.UI.Manager.GetPlayerBars()
end

function AKB.UI.UpdateBarVisibility()
    return AKB.UI.Manager.UpdateBarVisibility()
end

function AKB.UI.HideAllBars()
    return AKB.UI.Manager.HideAllBars()
end

function AKB.UI.ShowAllBars()
    return AKB.UI.Manager.ShowAllBars()
end

function AKB.UI.AreAllAttributesFull()
    return AKB.UI.Manager.AreAllAttributesFull()
end

-- Legacy functions for Bars module (kept for any external references)
function AKB.UI.CreateBarLabel(uniqueName, xPos, yPos, isCompact, bgY, actualBarHeight)
    return AKB.UI.Bars.CreateBarLabel(uniqueName, xPos, yPos, isCompact, bgY, actualBarHeight)
end

function AKB.UI.CreateBarObject(barType, powerType, color, barWindow, labelWindow, barBackground, barFill, barLabel, actualBarHeight, shieldBar, percentLabel, regenLine, degenLine)
    return AKB.UI.Bars.CreateBarObject(barType, powerType, color, barWindow, labelWindow, barBackground, barFill, barLabel, actualBarHeight, shieldBar, percentLabel, regenLine, degenLine)
end

-- Legacy functions for NameLabel module (kept for any external references)
function AKB.UI.CreatePlayerNameLabel(healthXOffset, healthYOffset)
    return AKB.UI.NameLabel.CreatePlayerNameLabel(healthXOffset, healthYOffset)
end

function AKB.UI.CreateNameLabel(nameWindow, playerName, playerLevel)
    return AKB.UI.NameLabel.CreateNameLabel(nameWindow, playerName, playerLevel)
end

function AKB.UI.CreateChampionInfo(nameWindow, nameLabel, playerName, playerLevel)
    return AKB.UI.NameLabel.CreateChampionInfo(nameWindow, nameLabel, playerName, playerLevel)
end

function AKB.UI.CreateClassIcon(nameWindow)
    return AKB.UI.NameLabel.CreateClassIcon(nameWindow)
end
