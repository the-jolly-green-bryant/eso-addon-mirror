

CookeryWizAsyncOld = {}

local CookeryWizAsync = CookeryWizAsyncOld
CookeryWizAsync.name = "CookeryWizAsync"

CookeryWizAsync.startIndex = 1
CookeryWizAsync.endIndex = 69000
CookeryWizAsync.currentIndex = nil

CookeryWizAsync.callback = nil

CookeryWizAsync.maxLoopCounter = 100

CookeryWizAsync.timerInterval = 100

CookeryWizAsync.cancelAsync = false

CookeryWizAsync.count = 0

CookeryWizAsync.traceEnabled = false

local function trace(msg)
  if CookeryWizAsync.traceEnabled then
    CookeryWizAsync:Trace(msg)
  end
end

function CookeryWizAsync:new(callback) 
  local o = {}
  o.data = {}
  o.callback = callback
  o.callbackKey = callbackKey
  setmetatable(o, self)
  self.__index = self
  return o  
end

function CookeryWizAsync:Trace(msg)
  d(GetTimeString()..":"..msg)
end




---------------------------------------------------------------------
-- Function: GetTimerInterval
--
-- This function gets the timer interval
---------------------------------------------------------------------
function CookeryWizAsync:GetTimerInterval()
  return self.timerInterval
end

---------------------------------------------------------------------
-- Function: SetTimerInterval
--
-- This function sets the timer interval
---------------------------------------------------------------------
function CookeryWizAsync:SetTimerInterval(timerInterval)
  self.timerInterval = timerInterval
end

---------------------------------------------------------------------
-- Function: GetMaxLoopCounter
--
-- This function gets the maximum loop amount per timeslice
---------------------------------------------------------------------
function CookeryWizAsync:GetMaxLoopCounter()
  return self.maxLoopCounter
end

---------------------------------------------------------------------
-- Function: SetMaxLoopCounter
--
-- This function sets the maximum loop amount per timeslice
---------------------------------------------------------------------
function CookeryWizAsync:SetMaxLoopCounter(max)
  self.maxLoopCounter = max
end

---------------------------------------------------------------------
-- Function: GetStartIndex
--
-- This function gets the starting index
---------------------------------------------------------------------
function CookeryWizAsync:GetStartIndex()
  return self.startIndex
end

---------------------------------------------------------------------
-- Function: SetStartIndex
--
-- This function sets the starting index
---------------------------------------------------------------------
function CookeryWizAsync:SetStartIndex(startIndex)
  self.startIndex = startIndex
end

---------------------------------------------------------------------
-- Function: GetEndIndex
--
-- This function gets the ending index
---------------------------------------------------------------------
function CookeryWizAsync:GetEndIndex()
  return self.endIndex
end

---------------------------------------------------------------------
-- Function: SetStartIndex
--
-- This function sets the ending index
---------------------------------------------------------------------
function CookeryWizAsync:SetStartIndex(endIndex)
  self.endIndex = endIndex
end

---------------------------------------------------------------------
-- Function: SetRange
--
-- This function sets the start and end index
---------------------------------------------------------------------
function CookeryWizAsync:SetRange(startIndex, endIndex)
  self.startIndex = startIndex
  if endIndex then
    self.endIndex = endIndex
  end
end

---------------------------------------------------------------------
-- Function: Cancel
--
-- This function cancels the current task
---------------------------------------------------------------------
function CookeryWizAsync:Cancel()
  trace("Cancelling")
  self.cancelAsync = true
end

---------------------------------------------------------------------
-- Function: Begin
--
-- This function begins the current task
---------------------------------------------------------------------
function CookeryWizAsync:Begin()
  if not self.endIndex then
    trace("An end index must be set")
    return
  end
  
  self.count = 0

  -- we could continue, but give a bit of breathing room
  if self.callback.OnAsyncStart then 
    self.callback:OnAsyncStart(self)      
  end
  
  self:Loop(self.startIndex)
end

---------------------------------------------------------------------
-- Function: Start
--
-- This function begins the current task
---------------------------------------------------------------------
function CookeryWizAsync:Start()
  return
end

---------------------------------------------------------------------
-- Function: Loop
--
-- This function is the main loop for the task
---------------------------------------------------------------------
function CookeryWizAsync:Loop(iteration)  
  local it = tostring(iteration)
  local toIndex = iteration + self.maxLoopCounter - 1
  trace("["..it.."] CookeryWizAsync:Loop")
  
  if self.cancelAsync then
      --trace("["..it.."] - Cancelling Async Task")
      self.cancelAsync = false
      if self.callback.OnAsyncEnd then 
        self.callback:OnAsyncEnd(self, self.count)      
      end
    return
  else
    -- go through a number of iterations
    local fromIndex = iteration

    if toIndex > self.endIndex then
      toIndex = self.endIndex
    end
    
    --trace("["..it.."] fromIndex["..fromIndex.."], toIndex ["..toIndex.."]")
    
    for i = fromIndex, toIndex do      
      if self.cancelAsync then
        if self.callback.OnAsyncEnd then 
          self.callback:OnAsyncEnd(self, self.count)      
        end       
        return
      end
      
      self.count = self.count + 1
      if self.callback.OnAsyncLoop then 
        self.callback:OnAsyncLoop(self, i)      
      end       
      
    end
    
    if toIndex >= self.endIndex then
      trace("Finished Async task. "..self.count.."")
      if self.callback.OnAsyncEnd then 
        self.callback:OnAsyncEnd(self, self.count)      
      end
      return
    end    
  end
    
  local function callLater()
    --trace("["..it.."] Calling Start - toIndex["..toIndex.."]")
    self:Loop(toIndex + 1)
  end    
  zo_callLater(callLater, self.timerInterval)

end