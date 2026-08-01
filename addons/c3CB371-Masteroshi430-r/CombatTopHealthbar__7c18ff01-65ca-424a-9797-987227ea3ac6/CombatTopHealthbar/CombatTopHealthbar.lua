CombatTopHealthbar = {}
CombatTopHealthbar.name = "CombatTopHealthbar"

function CombatTopHealthbar.go() 
 if not IsPlayerActivated() then return end
 if not UNIT_FRAMES then return end

 CombatTopHealthbar.unitFrame = ZO_UnitFrames_GetUnitFrame("reticleover")
 CombatTopHealthbar.unitFrame:SetAnimateShowHide(false) -- avoids faded healthbar

 local currentHealth, maxHealth =  CombatTopHealthbar.unitFrame:GetHealth()
 currentHealth = currentHealth or 0
 if currentHealth == 0  then CombatTopHealthbar.unitFrame:SetHiddenForReason("disabled", true) return end  -- hides healthbar if target is dead
 if (GetUnitType("reticleover") == 4 or GetUnitType("reticleover") == 6) and currentHealth == maxHealth then CombatTopHealthbar.unitFrame:SetHiddenForReason("disabled", true) return end -- don't show doors & walls if 100%
 
 --d(GetRawUnitName("reticleover").." "..GetUnitType("reticleover"))
 -- 1 players
 -- 2 NPC / animals / companions / bosses / foes 
 -- 4 keep door/wall/milegate/bridge
 -- 6 siege weapon

 if (IsUnitInCombat("player") and GetUnitReaction("reticleover") == UNIT_REACTION_HOSTILE) or -- shows hostile if in combat 
    ((IsUnitInvulnerableGuard("reticleover") or (GetUnitDifficulty("reticleover") > 1 and GetUnitAlliance("reticleover") ~= GetUnitAlliance("player"))) and GetUnitStealthState("player") ~= STEALTH_STATE_NONE) or -- shows guards & bosses if crouched
	(IsUnitInvulnerableGuard("reticleover") and GetBounty() ~= nil and GetBounty() > 0) or -- shows guards if you have a bounty
	 GetUnitType("reticleover") == 4 or -- shows repairable doors & walls
	 GetUnitType("reticleover") == 6 or -- shows repairable siege weapons
	 (IsGuildMate(GetUnitDisplayName("reticleover")) and not IsPlayerInAvAWorld() and not IsActiveWorldBattleground() and not IsUnitInDungeon("player") and not IsPlayerInRaid() and not IsInstanceEndlessDungeon() ) then -- shows guildies  

    CombatTopHealthbar.unitFrame:SetHiddenForReason("disabled", false)
 else
    CombatTopHealthbar.unitFrame:SetHiddenForReason("disabled", true)
 end

end

EVENT_MANAGER:RegisterForEvent(CombatTopHealthbar.name, EVENT_RETICLE_TARGET_CHANGED, CombatTopHealthbar.go)
EVENT_MANAGER:RegisterForEvent(CombatTopHealthbar.name, EVENT_PLAYER_COMBAT_STATE, CombatTopHealthbar.go)
EVENT_MANAGER:RegisterForEvent(CombatTopHealthbar.name, EVENT_STEALTH_STATE_CHANGED, CombatTopHealthbar.go)
