HelmetToggle = {}
HelmetToggle.name = 'HelmetToggle'
HelmetToggleTypes = {["auto"] = true, ["show"] = true, ["hide"] = true}

function HelmetToggle:Initialize()
  self.savedVariables = ZO_SavedVars:New("HelmetToggleSavedVariables", 1, nil, {})
  HelmetToggle.GetFunctionType()

  self.inCombat = IsUnitInCombat("player")
  HelmetToggle.SetHelmetVisibility(self.inCombat)

  EVENT_MANAGER:RegisterForEvent(HelmetToggle.name, EVENT_PLAYER_COMBAT_STATE, HelmetToggle.onPlayerCombatState)
  SLASH_COMMANDS["/ht"] = HelmetToggle.ChangeType
  SLASH_COMMANDS["/helmettoggle"] = HelmetToggle.ChangeType
end

function HelmetToggle.OnAddOnLoaded(event, addonName)
  if addonName == HelmetToggle.name then
    HelmetToggle:Initialize()
  end
end

function HelmetToggle.onPlayerCombatState(event, inCombat)
  if inCombat ~= HelmetToggle.inCombat then
    HelmetToggle.inCombat = inCombat
    HelmetToggle.SetHelmetVisibility(inCombat)
  end
end

function HelmetToggle.SetHelmetVisibility(Visible)
  if HelmetToggle.type == "auto" then
    if Visible then
      SetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_HELM, 0)
    else
      SetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_HELM, 1)
    end
  elseif HelmetToggle.type == "hide" then
    SetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_HELM, 1)
  else
    SetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_HELM, 0)
  end
end

function HelmetToggle.SetFunctionType(Type)
  HelmetToggle.savedVariables.type = Type
  HelmetToggle.SetHelmetVisibility(HelmetToggle.inCombat)
end

function HelmetToggle.GetFunctionType()
  if HelmetToggle.savedVariables.type == nil then
    HelmetToggle.savedVariables.type = "auto"
  end
  HelmetToggle.type = HelmetToggle.savedVariables.type
end

function HelmetToggle.ChangeType(extra)
  if HelmetToggleTypes[extra] then
    HelmetToggle.SetFunctionType(extra)
	HelmetToggle.GetFunctionType()
	HelmetToggle.SetHelmetVisibility(HelmetToggle.inCombat)
    d("Changed setting to: " .. extra)
  else
    d(extra .. " is not an available type please use auto, show or hide")
  end
end

EVENT_MANAGER:RegisterForEvent(HelmetToggle.name, EVENT_ADD_ON_LOADED, HelmetToggle.OnAddOnLoaded)