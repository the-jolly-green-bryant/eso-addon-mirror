CC_Queue = ZO_Object:Subclass()

function CC_Queue:New(...)
  local ccQueue = ZO_Object.New(self)
  ccQueue:Initialize(...)
  return ccQueue
end

function CC_Queue:Initialize()
  self.first = 1
  self.last = 0
end

function CC_Queue:Add(fn)
  self[self.last + 1] = fn
  self.last = self.last + 1

end

function CC_Queue:Pop()
  -- Check to see if there is a value toreturn
  if self:IsEmpty() then return nil end

  local temp = self[self.first]
  self[self.first] = nil
  self.first = self.first + 1
  return temp
end

function CC_Queue:Run()
  if not self:IsEmpty() then
    local current = self:Pop()
    current()
  end
end

function CC_Queue:IsEmpty()
  return self.last < self.first
end

function CC_Queue:Clear()
  while not self:IsEmpty() do
    self:Pop()
  end
  self.first = 1
  self.last = 0
end
