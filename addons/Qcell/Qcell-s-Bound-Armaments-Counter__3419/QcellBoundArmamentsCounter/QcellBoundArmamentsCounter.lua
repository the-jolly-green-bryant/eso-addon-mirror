QBAC = QBAC or {}
local QBAC = QBAC

QBAC.name = "QcellBoundArmamentsCounter"
QBAC.version = "0.8"
QBAC.author = "@Qcell"

QBAC.data = {
  BOUND_ARMAMENTS_SKILL_ID = 130318,
  -- {EFFECT_GAINED} : Bound Armaments (130293) : [4]",
  BOUND_ARMAMENTS_EFFECT_ID = 130293,
  -- {EFFECT_GAINED} : Bound Armaments (24165) : [1]",
    -- {EFFECT_GAINED_DURATION} : Bound Armaments (24165) : [40000]",
  BOUND_ARMAMENTS_BUFF_ID = 24165, -- shown on the buffs when activating it
  BOUND_ARMAMENTS_BLOCK_ID = 130291, -- id when having stacks

    -- GetAbilityIcon(BOUND_ARMAMENTS_SKILL_ID)
  BOUND_ARMAMENTS_ICON = "/esoui/art/icons/ability_sorcerer_bound_armaments_proc.dds",
  CLASS_SORC_ID = 2,
}

QBAC.status = {
  hidden = false,
  lastArmamentsCast = 0,
  stacks = 0,
}

QBAC.settings = {
  uiCustomScale = 1,
  textureAlpha = 0.85,
  simpleMode = false,
  unblockHPThreshold = 15,
}

function QBAC.HasLSB()
  return LibSkillBlocker ~= nil
end

function QBAC.BlockCast()
  if QBAC.HasLSB() and QBAC.savedVariables.blockCastLessThanFour then
    LibSkillBlocker.RegisterSkillBlock(QBAC.name, QBAC.data.BOUND_ARMAMENTS_BLOCK_ID)
  end
end

function QBAC.UnblockCast()
  if QBAC.HasLSB() and QBAC.savedVariables.blockCastLessThanFour then
    LibSkillBlocker.UnregisterSkillBlock(QBAC.name, QBAC.data.BOUND_ARMAMENTS_BLOCK_ID)
  end
end

function QBAC.ForceUnblockCast()
  if QBAC.HasLSB() then
    LibSkillBlocker.UnregisterSkillBlock(QBAC.name, QBAC.data.BOUND_ARMAMENTS_BLOCK_ID)
  end
end

function QBAC.GetTargetHealth()
  local currentTargetHP, maxTargetHP, effectiveMax = GetUnitPower("reticleover", POWERTYPE_HEALTH)
  return currentTargetHP / maxTargetHP
end

function QBAC.CombatEventStacks(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
  if result == ACTION_RESULT_EFFECT_GAINED then
    QBAC.ChangeStacks(hitValue)
  end

  if result == ACTION_RESULT_EFFECT_FADED then
    QBAC.ChangeStacks(0)
  end
end

function QBAC.CombatEventBuff(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
  local timeSec = GetGameTimeSeconds()
  if result == ACTION_RESULT_EFFECT_GAINED then
    QBAC.status.lastArmamentsCast = timeSec
    QBAC.TurnOn()
  end

  -- When recasting, it throws GAINED > FADED immediately after.
  if result == ACTION_RESULT_EFFECT_FADED and timeSec - QBAC.status.lastArmamentsCast > 0.05 then
    QBAC.TurnOff()
  end
end

function QBAC.PlayerActivated()
  QBACUI:SetHidden(true)
  QBAC.status.hidden = true
  if GetUnitClassId("player") ~= QBAC.data.CLASS_SORC_ID then -- Only for sorc
    return
  end
  QBACUI:SetHidden(false)
  QBAC.status.hidden = false
  QBAC.TurnOff()

  EVENT_MANAGER:UnregisterForEvent(QBAC.name .. "CombatEventStacks", EVENT_COMBAT_EVENT )
  EVENT_MANAGER:RegisterForEvent(QBAC.name .. "CombatEventStacks", EVENT_COMBAT_EVENT, QBAC.CombatEventStacks)
  EVENT_MANAGER:AddFilterForEvent(QBAC.name .. "CombatEventStacks", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, QBAC.data.BOUND_ARMAMENTS_EFFECT_ID)
  EVENT_MANAGER:AddFilterForEvent(QBAC.name .. "CombatEventStacks", EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

  EVENT_MANAGER:UnregisterForEvent(QBAC.name .. "CombatEventBuff", EVENT_COMBAT_EVENT )
  EVENT_MANAGER:RegisterForEvent(QBAC.name .. "CombatEventBuff", EVENT_COMBAT_EVENT, QBAC.CombatEventBuff)
  EVENT_MANAGER:AddFilterForEvent(QBAC.name .. "CombatEventBuff", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, QBAC.data.BOUND_ARMAMENTS_BUFF_ID)
  EVENT_MANAGER:AddFilterForEvent(QBAC.name .. "CombatEventBuff", EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
  
end

function QBAC.OnAddonLoaded(event, addonName)
  if addonName ~= QBAC.name then
    return
  end
  QBAC.savedVariables = ZO_SavedVars:NewAccountWide("QcellBoundArmamentsCounterSavedVariables", 2, nil, QBAC.settings)
  QBAC.RestorePosition()
  QBAC.Menu.AddonMenu()

  EVENT_MANAGER:UnregisterForEvent(QBAC.name, EVENT_ADD_ON_LOADED )
  EVENT_MANAGER:RegisterForEvent(QBAC.name .. "PlayerActive", EVENT_PLAYER_ACTIVATED, QBAC.PlayerActivated)
end

EVENT_MANAGER:RegisterForEvent( QBAC.name, EVENT_ADD_ON_LOADED, QBAC.OnAddonLoaded )
