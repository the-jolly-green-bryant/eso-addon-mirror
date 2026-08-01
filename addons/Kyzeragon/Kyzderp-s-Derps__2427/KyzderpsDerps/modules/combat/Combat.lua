local KD = KyzderpsDerps
KD.Combat = {}
local KDC = KD.Combat

local function OnPlayerActivated()
    if (KD.savedOptions.combat.satiateHunger) then
        KD:dbg("setting priority for insatiable hunger")
        SetSynergyPriorityOverride(33208, 10)
    end
end

function KDC.Initialize()
    EVENT_MANAGER:RegisterForEvent(KD.name .. "CombatActivated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
end

function KDC.GetSettings()
    return {
        {
            type = "checkbox",
            name = "Lower Insatiable Hunger priority",
            tooltip = "Sets werewolf's Insatiable Hunger synergy priority to 10, meaning it's lower priority than other default synergy priorities, so you stop randomly devouring corpses when you just want your damage buff. This should NOT be used alongside other synergy priority addons!",
            default = false,
            getFunc = function() return KD.savedOptions.combat.satiateHunger end,
            setFunc = function(value)
                    KyzderpsDerps.savedOptions.combat.satiateHunger = value
                    if (value) then
                        OnPlayerActivated()
                    else
                        ClearSynergyPriorityOverride(33208)
                    end
                end,
            width = "full",
        },
    }
end
