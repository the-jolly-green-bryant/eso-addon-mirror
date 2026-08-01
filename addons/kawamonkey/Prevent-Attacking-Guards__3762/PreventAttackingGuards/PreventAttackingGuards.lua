-- silence blocked attack alert
EsoStrings[SI_ACTIONRESULT3420] = ""

EVENT_MANAGER:RegisterForEvent(
    "PreventAttackingGuards",
    EVENT_RETICLE_TARGET_CHANGED,
    function()
		local isReticleOverInvulnerableGuard = IsUnitInvulnerableGuard("reticleover")
        SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_PREVENT_ATTACKING_INNOCENTS, tostring(isReticleOverInvulnerableGuard))
    end
)