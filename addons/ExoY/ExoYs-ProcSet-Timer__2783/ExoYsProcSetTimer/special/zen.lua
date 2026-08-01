EPT = EPT or {}
local EPT = EPT

function EPT.InitializeZen(self)
    self.event:RegisterForEvent(self.name.."BossChange", EVENT_BOSSES_CHANGED, self.OnBossChange)
    self.OnBossChange()
    self.event:RegisterForUpdate(self.name.."ZenUpdate", 500, self.ZenUpdate)
end

function EPT.TerminateZen(self)
  self.event:UnregisterForEvent(self.name.."BossChange", EVENT_BOSSES_CHANGED)
  self.event:UnregisterForUpdate(self.name.."ZenUpdate")
end

function EPT.OnBossChange()
  local self = EPT
  for i = 1, MAX_BOSSES do
    local name = GetUnitName( "boss"..tostring(i) )
    if name ~= "" then
      self.bosses[i] = name
    else
      self.bosses.num = i - 1
      break
    end
  end
end

function EPT.ZenUpdate()
  local self = EPT
  local target
  local dots = 0
  local active = false
  if self.bosses.num == 1 and self.store.special.zen.focusOnBoss then
    target = "boss1"
  else
    target = "reticleover"
  end

  for i = 1, GetNumBuffs(target) do
    local buffName, start, finish, slot, stacks, icon, buffType, effectType, abilityType, statusEffectType, abilityId, canClickOff, castByPlayer = GetUnitBuffInfo( target, i )
    if castByPlayer and finish - start > 1 and abilityType == ABILITY_TYPE_DAMAGE then
      dots = dots + 1
    end
    if abilityId == self.procSets[455].abilityId then active = true end
  end
  if active then
    self.guiList[455].primaryInd.label:SetText( tostring(dots) )
    self:UpdateColor(self.guiList[455].primaryInd, self:GetValueStatus(dots,5))
  else
    self.guiList[455].primaryInd.label:SetText("")
    self.guiList[455].primaryInd.edge:SetCenterColor(0,0,0, 0.3)
  end
end

function EPT:SettingsZen()
  return {
    {
          type = "checkbox",
          name = EPT_SETTINGS_SPECIAL_ZEN_FOCUS_NAME,	--(optional)
          tooltip = EPT_SETTINGS_SPECIAL_ZEN_FOCUS_TOOLTIP,	--(optional)
          getFunc = function() return self.store.special.zen.focusOnBoss end,
          setFunc = function(bool)
            self.store.special.zen.focusOnBoss = bool
          end,
          width = "full",	--or "half" (optional)
      },
      {
            type = "description",
            --title = "My Title",	--(optional)
            title = nil,	--(optional)
            text = EPT_SETTINGS_SPECIAL_ZEN_FOCUS_HINT,
            width = "full",	--or "half" (optional)
        },

    {
          type = "description",
          --title = "My Title",	--(optional)
          title = nil,	--(optional)
          text = EPT_SETTINGS_SPECIAL_ZEN_FOCUS_NOTE,
          width = "full",	--or "half" (optional)
      },

  }
end

-- Toggle

ZO_CreateStringId("SI_BINDING_NAME_EPT_ZEN_TOGGLE", EPT_BINDING_ZEN_TOOGLE)

function EPT.ToggleZen()
  local self = EPT
  self.store.special.zen.focusOnBoss = not self.store.special.zen.focusOnBoss
end


SLASH_COMMANDS["/eptzen"] = EPT.ToggleZen
