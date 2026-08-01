local Addon = LarvalTearMod
local QuickslotGate = Addon.Modules.QuickslotGate

function QuickslotGate:CanApply()
    if type(IsUnitInCombat) == "function" and IsUnitInCombat("player") == true then
        return false, "player_in_combat"
    end

    if type(IsInGamepadPreferredMode) == "function" and IsInGamepadPreferredMode() == true then
        return false, "gamepad_not_supported"
    end

    if type(Addon) == "table" and type(Addon.activeApplyRun) == "table" then
        return false, "build_apply_running"
    end

    if type(Addon.Modules.QuickslotApply) == "table" and Addon.Modules.QuickslotApply.running == true then
        return false, "quickslot_apply_running"
    end

    return true
end
