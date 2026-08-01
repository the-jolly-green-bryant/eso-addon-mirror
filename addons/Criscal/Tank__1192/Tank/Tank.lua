-- EVENT_COMBAT_EVENT:
-- Felder 14, 15 und 16: 14 Attacker ID?, 15: Target ID?
-- ComputeStringDistance(string source, string target, integer maxDistance)

local addon_name = "Tank"
local saved_name = "Tank_SavedVariables"

local RED = ZO_ColorDef:New("FF0000")
local GREEN = ZO_ColorDef:New("00FF00")
local YELLOW = ZO_ColorDef:New("FFEF00")

local FONT_EASY = "ZoFontGame"
local FONT_NORMAL = "ZoFontGame"
local FONT_HARD = "ZoFontWinH3" 
local FONT_DEADLY = "ZoFontWinH1"
local FONT_LARGER = "ZoFontWinH5"

local wm = WINDOW_MANAGER

local player_name = UndecorateDisplayName(GetDisplayName())
local syslang = GetCVar("language.2")

Tank = ZO_Object:Subclass()
local Tank = Tank

function Tank:AssureSettings()
  if (self.savedVars.show_untaunted_mobs == nil) then
    d("Assure untaunted")
    self.savedVars.show_untaunted_mobs = TankSettings.show_untaunted_mobs
  end
end

function Tank:Init(event, name)
  if name ~= addon_name then return end
  self.savedVars = ZO_SavedVars:New(saved_name, 1, nil, TankSettings.defaults, nil)
  EVENT_MANAGER:RegisterForEvent(addon_name, EVENT_RETICLE_TARGET_CHANGED, function(...) Tank:OnTargetChanged() end)
  EVENT_MANAGER:AddFilterForEvent(addon_name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, 'reticleover')
  EVENT_MANAGER:RegisterForEvent(addon_name, EVENT_EFFECT_CHANGED,         function(...) Tank:OnTargetChanged() end)
  TankSettings:initializeOptions()
  EVENT_MANAGER:UnregisterForEvent(addon_name, EVENT_ADD_ON_LOADED)
  
  -- GetActionInfo
  --EVENT_MANAGER:RegisterForEvent(addon_name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, "Taunt") -- CONSTANT for TAUNT 38254?
  -- TODO: add filter for taunt if possible
end

--function Tank:CombatEvent(result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceid, targetid, abilityid)
--  if (abilityName == "Taunt") then
--    d(abilityid)
--  end
--end

function Tank:UpdateCounter()
  if (TankControlCounter ~= nil) then
    if (self.ending ~= nil) then
      local duration = zo_roundToNearest(self.ending - GetFrameTimeSeconds(), 1)

      TankControlCounter:SetFont(FONT_NORMAL)
      if (duration > 0) then
        if (duration < 6) then
          if (duration < 3) then
            TankControlCounter:SetColor(RED:UnpackRGBA())
          else
            TankControlCounter:SetColor(YELLOW:UnpackRGBA())
          end
        else
          TankControlCounter:SetColor(GREEN:UnpackRGBA())
        end

        TankControlCounter:SetText(duration)
        return
      end
    end
    self:UntauntedCheck()
  end
end

function Tank:Start()
  TankControl:SetHandler("OnUpdate", function() Tank:UpdateCounter() end)
end

function Tank:GetUntauntedFontSize()
  difficulty = GetUnitDifficulty("reticleover")
  if (difficulty == MONSTER_DIFFICULTY_HARD) then
    return FONT_HARD
  elseif (difficulty == MONSTER_DIFFICULTY_DEADLY) then
    return FONT_DEADLY
  else
    return FONT_LARGER
  end
end

function Tank:UntauntedCheck()
  if TankControlCounter ~= nil then
    if self.savedVars ~= nil and self.savedVars.show_untaunted_mobs and IsUnitInCombat('player') and DoesUnitExist('reticleover') and not IsUnitPlayer('reticleover') then
      TankControlCounter:SetColor(RED:UnpackRGBA())
      TankControlCounter:SetFont(self:GetUntauntedFontSize())
      TankControlCounter:SetText("0")
    else
      TankControlCounter:SetText("")
    end
  end
end

function Tank:OnTargetChanged()
  -- IsGameCameraPreferredTargetValid
  -- CycleGameCameraPreferredEnemyTarget
  -- IsBlockActive
--      if(IsGameCameraPreferredTargetValid()) then
--        ClearGameCameraPreferredTarget()
--        return
--    end
  
  local tag = 'reticleover'
  self.ending = nil
  if (DoesUnitExist(tag) and not IsUnitPlayer(tag)) then
    local num_buffs = GetNumBuffs(tag)
    if (num_buffs > 0) then
      for buff = 1, num_buffs do
        --local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType = GetUnitBuffInfo('reticleover', buff)
        local buffName, timeStarted, timeEnding, _, stackCount, _, buffType, effectType, abilityType, _, abilityId, _  = GetUnitBuffInfo('reticleover', buff)
        if (abilityId == 38254) then
          local duration_left = timeEnding - GetFrameTimeSeconds()
          self.ending = timeEnding
          if (self.dbg(1)) then self:debug(buffName .. " on " .. GetUnitName('reticleover') .. " b:" .. buffType .. " e:" .. effectType .. " a:" .. abilityId  .. " start:" .. timeStarted .. " end: " .. timeEnding) end
          --d("Taunt on :" .. GetUnitName(tag) .. " for " .. duration_left .. " seconds still. ")
          break
        end
        --if (self.dbg(1)) then self:debug(buffName .. " on " .. GetUnitName('reticleover') .. " b:" .. buffType .. " e:" .. effectType .. " a:" .. abilityType .. " start:" .. timeStarted .. " end: " .. timeEnding) end
      end
    else
      self:UntauntedCheck()
    end
  end
  self:UpdateCounter()
end

function Tank:TargetNextSameName()
  local name = GetUnitName('reticleover')
  -- store the name of the target
  if (name) then
    self.storedName = name
  elseif (self.storedName ~= nil) then
    name = self.storedName
  end
end

--function Tank:OnEffectChanged(change, arg2, buff, name, start, finish, stack, icon, arg9, arg10, abilityType, try1, target_name, try2, try3)
--  -- name = 'reticleover'
--  -- arg2 = buffslot?
--  -- arg9 = buffType?
--  -- arg10 == EffectType?
--  -- try1 war immer 0?
--  -- try2 ist target id?
--  -- try3 ist Spieler Id?
--  if (buff == "Taunt Counter") then
--    d("Effect " .. (change == EFFECT_RESULT_FADED and "faded" or "added/updated") .. " arg2: " .. arg2 .. " change:" .. change .. " name:" .. name .. " buff: " .. buff .. " start:" .. start .. " finish:" .. finish .. " stack:" .. stack .. " arg9:" .. arg9 .. " arg10:" .. arg10  .. " type:" .. abilityType .. " target:" .. target_name)
--    --d(try1)
--    --d(try2)
--    --d(try3)
--  end
--end

function Tank:dbg(level)
  return false
end

function Tank:debug(text)
  d(text)
end

--EVENT_MANAGER:RegisterForEvent("Tank", EVENT_COMBAT_EVENT , function (...)  Tank:CombatEvent(...) end)
EVENT_MANAGER:RegisterForEvent(addon_name, EVENT_ADD_ON_LOADED , function (...)  Tank:Init(...) end)