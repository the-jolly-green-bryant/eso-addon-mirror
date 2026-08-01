-----------------------------------------------------------------------------------
-- Library Name: LibDynamicMail (LTF)
-- Creator: Saranicole1980 (Sara Jarjoura)
-- Library Ideal: Advanced Text Formatting and Parsing
-- Library Creation Date: February, 2026
-- Publication Date: TBD
--
-- File Name: LibDynamicMail.lua
-- File Description: Contains the main functions of LTF
-- Load Order Requirements: After all other library files
--
-----------------------------------------------------------------------------------

LibDynamicMail = ZO_DeferredInitializingObject:Subclass()

local LDM = LibDynamicMail

function LDM:SaveToVars(key, value)
  self.savedVars[key] = value
end

function LDM:ListVars()
  return self.savedVars
end

function LDM:GetVar(key)
  return self.savedVars[key]
end

function LDM:GetVarByValue(key, value)
  if not self.savedVars[key] then return false end
  for k, v in pairs(self.savedVars[key]) do
    if value == k then
      return v
    end
  end
  return nil
end

function LDM:New(...)
  local object = ZO_Object.New(self)
  object:Initialize(...)
  return object
end

function LDM:Initialize(vars, formatter)
  self.savedVars = vars
  if formatter and next(formatter) then
    self.formatter = formatter
  end
  self.savedVars.InboxCallbacks = {}
end
