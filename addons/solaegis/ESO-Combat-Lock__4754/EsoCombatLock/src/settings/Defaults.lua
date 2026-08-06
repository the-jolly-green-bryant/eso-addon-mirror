-- EsoCombatLock - default SavedVariables

local ECL = EsoCombatLock

ECL.defaults = {
    guardEnabled = true,
    resummonEnabled = true,
    includeVanityPets = false,
    -- nil means "none": guard still reverts risky slots to lastSafe
    substitute = nil,
    alertVerbosity = "chat", -- none | chat | csa | both
    -- Center-screen text tier: 1 = small, 2 = large, 3 = major (ESO API has no finer control)
    alertTextSize = 2,
    debug = false,
    -- Probe-confirmed: empty quickslots are selectable. Flip to false via
    -- settings/probe if an API bump breaks no-op parking.
    emptySlotsSelectable = true,
    -- Prefer a slotted memento as a detectable no-op park over an empty slot.
    preferDetectableNoOp = true,
    -- HUD indicator: false = combat only, true = always visible
    indicatorAlwaysVisible = false,
    indicatorLocked = true,
    indicatorX = 0,
    indicatorY = -200,
    indicatorSize = 64,
    -- Q-press alerts during combat
    pressAlertsEnabled = true,
}

function ECL.ResetSettings()
    if not ECL.db then
        return
    end
    for key, value in pairs(ECL.defaults) do
        ECL.db[key] = value
    end
    ECL.db.substitute = nil
    ECL.db.indicatorEnabled = nil
end
