-- ESO Adventurer Suite
-- v0.29.565 - combat-end / killing-blow frame performance fix.
-- ESO commonly leaves combat immediately after the final enemy dies. The base
-- Combat:EndFight() performs report sorting/aggregation and downstream report
-- callbacks synchronously, which can hitch the exact frame the enemy dies.
-- Defer that finalization until the player has remained out of combat briefly.

local EPC = ESOProgressionCoach
if not EPC or not EPC.Combat then return end

local C = EPC.Combat
local DEFER_MS = 650
local generation = 0

local function playerInCombat()
    if type(IsUnitInCombat) ~= "function" then return C.inCombat == true end
    local ok, value = pcall(IsUnitInCombat, "player")
    return ok and value == true
end

if type(C.OnCombatState) == "function" and type(C.EndFight) == "function" and not C._easCombatEndDeferred029565 then
    C._easCombatEndDeferred029565 = true

    local baseOnCombatState = C.OnCombatState
    local baseEndFight = C.EndFight

    -- Guard the original OnCombatState from invoking EndFight synchronously.
    -- BeginFight remains native/base behavior so combat starts immediately.
    function C:OnCombatState(inCombat)
        generation = generation + 1
        local myGeneration = generation

        if inCombat == true then
            self._easPendingCombatEnd029565 = false
            if not self.inCombat then
                return baseOnCombatState(self, true)
            end
            return
        end

        if not self.inCombat or not self.current then
            self.inCombat = false
            return
        end

        -- Keep the active fight object intact during the short grace window so
        -- combat that resumes immediately continues the same encounter instead
        -- of finalizing/restarting between closely spaced enemies.
        self._easPendingCombatEnd029565 = true

        local function finalizeIfStillIdle()
            if myGeneration ~= generation then return end
            if not self._easPendingCombatEnd029565 then return end
            if playerInCombat() then return end
            self._easPendingCombatEnd029565 = false
            baseEndFight(self)
        end

        if type(zo_callLater) == "function" then
            zo_callLater(finalizeIfStillIdle, DEFER_MS)
        elseif EVENT_MANAGER then
            local key = (EPC.name or "ESOAdventurerSuite") .. "_CombatEnd029565"
            EVENT_MANAGER:UnregisterForUpdate(key)
            EVENT_MANAGER:RegisterForUpdate(key, DEFER_MS, function()
                EVENT_MANAGER:UnregisterForUpdate(key)
                finalizeIfStillIdle()
            end)
        else
            finalizeIfStillIdle()
        end
    end
end
