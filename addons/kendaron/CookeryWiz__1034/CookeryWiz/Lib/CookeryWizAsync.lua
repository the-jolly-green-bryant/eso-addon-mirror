
CookeryWizAsync = CookeryWizUtils:class(function(a,name)
   a.name = name
end)

--local CookeryWizAsync = CookeryWizAsync2

CookeryWizAsync.startIndex = 1

CookeryWizAsync.maxLoopCounter = 100

CookeryWizAsync.timerInterval = 100

CookeryWizAsync.cancelAsync = false

CookeryWizAsync.count = 0

CookeryWizAsync.startTime = nil
CookeryWizAsync.endTime = nil

-- Enable to show how long till competion
CookeryWizAsync.showMetrics = false

-- Enable to show how long till competion
CookeryWizAsync.timeout = 300 * 1000

CookeryWizAsync.traceEnabled = true

local function trace(msg)
  if CookeryWizAsync.traceEnabled then
    CookeryWizAsync:Trace(msg)
  end
end

function CookeryWizAsync:Trace(msg)
  d(GetTimeString()..":"..msg)
end

function CookeryWizAsync:__tostring()
  return self.name
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
-- Function: SetStartIndex
--
-- This function sets the ending index
---------------------------------------------------------------------
function CookeryWizAsync:SetStartIndex(startIndex)
  self.startIndex = startIndex
end

---------------------------------------------------------------------
-- Function: Cancel
--
-- This function cancels the current task
---------------------------------------------------------------------
function CookeryWizAsync:Cancel()
  --trace("Cancelling..")
  self.cancelAsync = true
  
  if self.OnAsyncEnd then 
    self.OnAsyncEnd(self, self.count)      
  end
  
  --d("showMetrics["..tostring(self.showMetrics).."]")
  if self.showMetrics then
    local ms = GetGameTimeMilliseconds() - self.startTime
    local time = "Time to complete: "..FormatTimeMilliseconds(ms, TIME_FORMAT_STYLE_DURATION, TIME_FORMAT_PRECISION_SECONDS, TIME_FORMAT_DIRECTION_NONE)
    d(time )
  end
  
  -- can be used by a parent calling object
  if self.OnFinished then 
    self.OnFinished(self, self.count)      
  end  
  
end

---------------------------------------------------------------------
-- Function: Begin
--
-- This function begins the current task
---------------------------------------------------------------------
function CookeryWizAsync:Begin()
 
  self.cancelAsync = false
  self.count = 0
  self.startTime = GetGameTimeMilliseconds() 

  -- we could continue, but give a bit of breathing room
  if self.OnAsyncStart then 
    self.OnAsyncStart(self, 0)      
  end
  
  self:Loop(self.startIndex)
end

---------------------------------------------------------------------
-- Function: Loop
--
-- This function is the main loop for the task
---------------------------------------------------------------------
function CookeryWizAsync:Loop(fromIndex)  
  local toIndex = fromIndex + self.maxLoopCounter - 1
  
  local it = tostring(iteration)
  --trace("["..it.."] CookeryWizAsync:Loop")
  
  if self.cancelAsync then
    return
  else
    for i = fromIndex, toIndex do      
      
      if self.cancelAsync then
        return
      end
      
      self.count = self.count + 1
      if self.OnAsyncLoop then 
        self.OnAsyncLoop(self, i) 
      end       
    end
  
    -- schedule a call back to give the game time to process
    local function callLater()
      self:Loop(toIndex + 1)
    end    
  
    -- only process if we have not exceed max timout!
    if GetGameTimeMilliseconds() - self.startTime > self.timeout then
      if self.showMetrics then
        d("Timeout exceeded. Stopping")
      end
      self:Cancel()
    else
      zo_callLater(callLater, self.timerInterval)
    end  
  end
end

