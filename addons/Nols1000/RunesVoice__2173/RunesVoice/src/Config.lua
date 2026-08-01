-- Initalize RunesVoice to use as Table to store
-- the Addon in it.
if RunesVoice == nil then RunesVoice = {} end

-- Reset SavedVariables to default
function RunesVoice:resetAddonMenu()
  RunesVoice:debug("info", "Reset config to default.")
  self.variables.saved = self.variables.defaults
end

-- Get SavedVariable by key
function RunesVoice:getConfigValue(key)
  return self.variables.saved[key]
end

-- Get SavedVariable default value by key
function RunesVoice:getDefaultConfigValue(key)
  RunesVoice:debug("info", "Get Variable: "..tostring(key).." : "..tostring(self.variables.defaults[key]))
  return self.variables.defaults[key]
end

-- Set SavedVariable to value by key
function RunesVoice:setConfigValue(key, value)
  self.variables.saved[key] = value
  RunesVoice:debug("info", "Set Variable: "..key.." : "..tostring(value).." : after "..tostring(self.variables.defaults[key]))
end