local L = CookeryWizLanguage.language


CookeryWizRegistrations = {}
CookeryWizRegistrations.events = nil
CookeryWizRegistrations.enabled = true
CookeryWizRegistrations.callbackRegistrations = nil
CookeryWizRegistrations.currentCallbackIndex = 0
CookeryWizRegistrations.currentCallback = nil

CookeryWizRegistrations.traceEnabled = false

local function trace(msg)
    if CookeryWizRegistrations.traceEnabled then
      d(GetTimeString()..":"..msg)
    end
end

---------------------------------------------------------------------
-- Main CookeryWizRegistrations functions
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Function: new
--
-- This function is called to construct a new instance
---------------------------------------------------------------------
function CookeryWizRegistrations:new()
  local o = {}
  setmetatable(o, self)
  o.callbackRegistrations = {}
  self.__index = self
  return o  
end

---------------------------------------------------------------------
-- Function: GetNextCallback
--
-- Gets the next callback object 
---------------------------------------------------------------------
function CookeryWizRegistrations:GetNextCallback()
  trace("GetNextCallback["..self.currentCallbackIndex.."/"..#self.callbackRegistrations.."]")
  if self.currentCallbackIndex == #self.callbackRegistrations then
    self.currentCallbackIndex = 0
    self.currentCallback = nil
  else
    self.currentCallbackIndex = self.currentCallbackIndex + 1
    self.currentCallback = self.callbackRegistrations[self.currentCallbackIndex]    
    trace("-returning "..self.currentCallback.key)
  end
  return self.currentCallback  
end

---------------------------------------------------------------------
-- Function: GetCurrentCallback
--
-- Gets the current callback object 
---------------------------------------------------------------------
function CookeryWizRegistrations:GetCurrentCallback()
  return self.currentCallback  
end


---------------------------------------------------------------------
-- Function: ResetNextCallback
--
-- Resets the current callback
---------------------------------------------------------------------
function CookeryWizRegistrations:ResetNextCallback()
  self.currentCallbackIndex = 0
  self.currentCallback = nil    
end

---------------------------------------------------------------------
-- Function: GetCount
--
-- Gets the count of registrations
---------------------------------------------------------------------
function CookeryWizRegistrations:GetCount()
  if not #self.callbackRegistrations then
    return 0
  end

  return #self.callbackRegistrations
end

---------------------------------------------------------------------
-- Function: Enumerate
--
-- This function is called to enumerate the registrations
---------------------------------------------------------------------
function CookeryWizRegistrations:Enumerate(matchFunction)  
  local callback
  for i = 1, #self.callbackRegistrations do
    callback = self.callbackRegistrations[i]
    if not matchFunction then
      -- callback on the unregister events
      if callback.object.OnEnumerate then
        if callback.object:OnEnumerate(i, callback) then
          break
        end        
      end               
    else 
      matchFunction(callback)
    end
  end    
end

function CookeryWizRegistrations:Dump()
  for i = 1, #self.callbackRegistrations do
    local callback = self.callbackRegistrations[i]
    trace("key["..callback.key.."]")
  end  
end
---------------------------------------------------------------------
-- Function: Register
--
-- This function is called to register an object for a callback
-- The key provided should be alphanumeric
---------------------------------------------------------------------
function CookeryWizRegistrations:Register(key, object, matchFunction)
  local callback
  
  if not object then
    d("CookeryWizRegistrations:A callback object must be passed")
    return
  end
  
  -- check that this does not exist
  trace("Scanning "..#self.callbackRegistrations.." registration objects")
  self:Dump()
  for i = 1, #self.callbackRegistrations do
    callback = self.callbackRegistrations[i]
    if callback.key == key then
      if not matchFunction or matchFunction(callback) then
        d("CookeryWizRegistrations:This key already exists. Choose another")
        return
      end
    end
  end
  
  callback  = {}
  callback.key = key
  callback.object = object
  
  local index = #self.callbackRegistrations + 1
  self.callbackRegistrations[index] = callback
  
  trace("Checking if OnRegister exists")
  if object.OnRegister then 
    trace("Calling OnRegister exists")
    object:OnRegister(index, object)
  end   
  return callback
end

---------------------------------------------------------------------
-- Function: Unregister
--
-- This function is called to unregister an object for a callback
-- The key provided should be alphanumeric and the same as passed
-- for the Register function
---------------------------------------------------------------------
function CookeryWizRegistrations:Unregister(key, matchFunction)
  local callback
  for i = 1, #self.callbackRegistrations do
    callback = self.callbackRegistrations[i]
    if callback.key == key then
      if not matchFunction or matchFunction(callback) then
        self.callbackRegistrations[i] = nil
        -- callback on the unregister events
        if callback.object.OnUnregister then 
          callback.object:OnUnregister(#self.callbackRegistrations, callback)
        end     
      end
    end
  end   
end