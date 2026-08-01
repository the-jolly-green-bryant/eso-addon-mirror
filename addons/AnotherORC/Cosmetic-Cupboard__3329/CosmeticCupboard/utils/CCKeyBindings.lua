CC_KeyBindings = {}

-- Create a new data handling object
function CC_KeyBindings:New()
  local class = {}
  setmetatable(class, self)
  self.__index = self
  return class
end

function CC_KeyBindings:Initialize()
  ZO_CreateStringId('SI_BINDING_NAME_CC_SHOW_WINDOW', 'Toggle Cosmetic Cupboards')
end
