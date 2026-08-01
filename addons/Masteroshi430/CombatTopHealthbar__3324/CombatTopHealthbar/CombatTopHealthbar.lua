CombatTopHealthbar = {}
CombatTopHealthbar.name = "CombatTopHealthbar"

-- Localize hot globals: local lookups are faster than global-table lookups,
-- and this file's function runs on every reticle/combat/stealth event.
local IsPlayerActivated = IsPlayerActivated
local ZO_UnitFrames_GetUnitFrame = ZO_UnitFrames_GetUnitFrame
local GetUnitType = GetUnitType
local IsUnitInCombat = IsUnitInCombat
local GetUnitReaction = GetUnitReaction
local IsUnitInvulnerableGuard = IsUnitInvulnerableGuard
local GetUnitDifficulty = GetUnitDifficulty
local GetUnitAlliance = GetUnitAlliance
local GetUnitStealthState = GetUnitStealthState
local GetBounty = GetBounty
local IsGuildMate = IsGuildMate
local GetUnitDisplayName = GetUnitDisplayName
local IsPlayerInAvAWorld = IsPlayerInAvAWorld
local IsActiveWorldBattleground = IsActiveWorldBattleground
local IsUnitInDungeon = IsUnitInDungeon
local IsPlayerInRaid = IsPlayerInRaid
local IsInstanceEndlessDungeon = IsInstanceEndlessDungeon

-- "reticleover" is a persistent singleton frame control (same object every call)
-- and its animate-show-hide setting never changes, so both are set up lazily
-- once instead of being redone on every event.
local cachedUnitFrame = nil

function CombatTopHealthbar.go()
 if not IsPlayerActivated() then return end
 if not UNIT_FRAMES then return end

 if not cachedUnitFrame then
    cachedUnitFrame = ZO_UnitFrames_GetUnitFrame("reticleover")
    if not cachedUnitFrame then return end -- frame may not exist yet (e.g. right after UI load)
    CombatTopHealthbar.unitFrame = cachedUnitFrame
    cachedUnitFrame:SetAnimateShowHide(false) -- avoids faded healthbar
 end
 local unitFrame = cachedUnitFrame

 local currentHealth, maxHealth = unitFrame:GetHealth()
 currentHealth = currentHealth or 0
 if currentHealth == 0 then unitFrame:SetHiddenForReason("disabled", true) return end -- hides healthbar if target is dead

 -- cache repeated lookups instead of recomputing them below
 local unitType = GetUnitType("reticleover")
 local isDoorOrSiege = (unitType == 4 or unitType == 6)

 if isDoorOrSiege and currentHealth == maxHealth then unitFrame:SetHiddenForReason("disabled", true) return end -- don't show doors & walls if 100%

 --d(GetRawUnitName("reticleover").." "..unitType)
 -- 1 players
 -- 2 NPC / animals / companions / bosses / foes
 -- 4 keep door/wall/milegate/bridge
 -- 6 siege weapon

 local isInvulnGuard = IsUnitInvulnerableGuard("reticleover")

 if (IsUnitInCombat("player") and GetUnitReaction("reticleover") == UNIT_REACTION_HOSTILE) or -- shows hostile if in combat
    ((isInvulnGuard or (GetUnitDifficulty("reticleover") > 1 and GetUnitAlliance("reticleover") ~= GetUnitAlliance("player"))) and GetUnitStealthState("player") ~= STEALTH_STATE_NONE) or -- shows guards & bosses if crouched
    (isInvulnGuard and (GetBounty() or 0) > 0) or -- shows guards if you have a bounty
    isDoorOrSiege or -- shows repairable doors & walls / siege weapons
    (not IsPlayerInAvAWorld() and not IsActiveWorldBattleground() and not IsUnitInDungeon("player") and not IsPlayerInRaid() and not IsInstanceEndlessDungeon() and IsGuildMate(GetUnitDisplayName("reticleover"))) then -- shows guildies

    unitFrame:SetHiddenForReason("disabled", false)
 else
    unitFrame:SetHiddenForReason("disabled", true)
 end

end

EVENT_MANAGER:RegisterForEvent(CombatTopHealthbar.name, EVENT_RETICLE_TARGET_CHANGED, CombatTopHealthbar.go)
EVENT_MANAGER:RegisterForEvent(CombatTopHealthbar.name, EVENT_PLAYER_COMBAT_STATE, CombatTopHealthbar.go)
EVENT_MANAGER:RegisterForEvent(CombatTopHealthbar.name, EVENT_STEALTH_STATE_CHANGED, CombatTopHealthbar.go)
