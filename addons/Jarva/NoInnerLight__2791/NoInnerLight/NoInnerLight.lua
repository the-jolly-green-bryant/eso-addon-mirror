local NoInnerLight
do
  local _class_0
  local _base_0 = {
    name = "NoInnerLight",
    variableVersion = 1,
    defaults = {
      BlockInPvp = false
    },
    passiveSkills = {
      innerLight = 40478,
      camoHunter = 40195
    },
    onZoneChange = function()
      if not NoInnerLight.savedVariables.BlockInPvp and (IsPlayerInAvAWorld() or IsActiveWorldBattleground()) then
        LibSkillBlocker.UnregisterSkillBlock(NoInnerLight.name, NoInnerLight.passiveSkills.innerLight)
        LibSkillBlocker.UnregisterSkillBlock(NoInnerLight.name, NoInnerLight.passiveSkills.camoHunter)
      end
      LibSkillBlocker.RegisterSkillBlock(NoInnerLight.name, NoInnerLight.passiveSkills.innerLight)
      return LibSkillBlocker.RegisterSkillBlock(NoInnerLight.name, NoInnerLight.passiveSkills.camoHunter)
    end,
    Initialize = function(self)
      self.savedVariables = ZO_SavedVars:NewAccountWide(self.name .. "Vars", self.variableVersion, nil, self.defaults)
      EVENT_MANAGER:RegisterForEvent(NoInnerLight.name, EVENT_ZONE_CHANGED, NoInnerLight.onZoneChange)
      NoInnerLight.onZoneChange()
      local LAM = LibAddonMenu2
      local panelName = self.name .. "Panel"
      local panelData = {
        type = "panel",
        name = "No Inner Light",
        author = "@Jarva [EU]",
        registerForDefaults = true
      }
      LAM:RegisterAddonPanel(panelName, panelData)
      local optionsData = {
        [1] = {
          type = "description",
          text = "NoInnerLight blocks the usage of Inner Light and Camouflaged Hunter to save you GCDs and resources."
        },
        [2] = {
          type = "checkbox",
          name = "Block in PVP",
          getFunc = function()
            return self.savedVariables.BlockInPvp
          end,
          setFunc = function(value)
            self.savedVariables.BlockInPvp = value
            return self:onZoneChange()
          end
        }
      }
      return LAM:RegisterOptionControls(panelName, optionsData)
    end,
    onAddonLoaded = function(_, addonName)
      if addonName == NoInnerLight.name then
        EVENT_MANAGER:UnregisterForEvent(NoInnerLight.name, EVENT_ADD_ON_LOADED)
        return NoInnerLight:Initialize()
      end
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function() end,
    __base = _base_0,
    __name = "NoInnerLight"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  NoInnerLight = _class_0
end
return EVENT_MANAGER:RegisterForEvent(NoInnerLight.name, EVENT_ADD_ON_LOADED, NoInnerLight.onAddonLoaded)
