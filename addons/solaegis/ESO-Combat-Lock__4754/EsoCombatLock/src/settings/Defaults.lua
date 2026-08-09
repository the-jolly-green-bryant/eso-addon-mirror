-- EsoCombatLock - default SavedVariables

local ECL = EsoCombatLock

ECL.defaults = {
    guardEnabled = true,
    resummonEnabled = true,
    includeVanityPets = false,
    -- nil means "none": guard still reverts risky slots to lastSafe
    substitute = nil,
    debug = false,
    -- Probe-confirmed: empty quickslots are selectable. Flip to false via
    -- settings/probe if an API bump breaks no-op parking.
    emptySlotsSelectable = true,
    -- Legacy (pre-parkPriority). Kept for one-time migration only; resolver
    -- reads parkPriority after Init.MigrateParkPriorityFromLegacy.
    preferDetectableNoOp = true,
    -- Ordered park tiers (deep-copied on reset — never assign by reference).
    parkPriority = {
        "last_safe",
        "blocked_memento",
        "memento",
        "empty",
        "unusable_safe",
        "consumable_safe",
        "substitute",
    },
    -- HUD indicator: false = combat only, true = always visible
    indicatorAlwaysVisible = false,
    indicatorLocked = true,
    indicatorX = 0,
    indicatorY = -200,
    indicatorSize = 64,
    -- Combat halo around the lock indicator (additive gold ring by default)
    haloEnabled = true,
    haloColorR = 1.0,
    haloColorG = 0.88,
    haloColorB = 0.38,
    haloIntensity = 100, -- percent; pulse alpha scale (25..150)
    -- Q-press alerts during combat
    pressAlertsEnabled = true,
}

function ECL.ResetSettings()
    if not ECL.db then
        return
    end
    for key, value in pairs(ECL.defaults) do
        if key == "parkPriority" then
            ECL.db.parkPriority = ECL.CopyParkPriorityDefaults()
        else
            ECL.db[key] = value
        end
    end
    ECL.db.substitute = nil
    ECL.db.indicatorEnabled = nil
    ECL.db.parkPriorityMigrated = true
end
