DYN = DYN or {}
DYN.Combat = {}
local Combat = DYN.Combat

local wasWindowOpen = false

function Combat:Initialize(savedVars, showFunc, hideFunc)
    EVENT_MANAGER:RegisterForEvent(AddonName, EVENT_PLAYER_COMBAT_STATE, function(_, inCombat)
        if not savedVars.closeOnCombat then 
            -- Si l'option est désactivée, on s'assure de ne pas laisser un état "était ouvert" en suspens
            wasWindowOpen = false
            return 
        end

        if inCombat then
            -- hideFunc retournera true si la fenêtre était visible et est maintenant cachée
            local isWindowVisibleAndNowHidden = hideFunc() 
            if isWindowVisibleAndNowHidden then
                wasWindowOpen = true
            end
        else -- Hors combat
            if wasWindowOpen then
                showFunc()
                wasWindowOpen = false
            end
        end
    end)
end