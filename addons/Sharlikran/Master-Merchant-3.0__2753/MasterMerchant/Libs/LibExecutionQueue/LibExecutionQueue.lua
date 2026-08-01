local libName, libVersion = "LibExecutionQueue", 202

LEQ_WAIT_TIME_IN_MILLISECONDS_DEFAULT = 40

local lib = {
  name = libName,
  version = libVersion,
  Queue = {},
  Wait = LEQ_WAIT_TIME_IN_MILLISECONDS_DEFAULT,
}

local paused

local function setPaused(self, value)
  paused = value
  self.Paused = value
end

local function isPaused()
  return paused == true
end

local function cancelPendingTask(self)
  if self.NextTaskCallLaterId then
    zo_removeCallLater(self.NextTaskCallLaterId)
    self.NextTaskCallLaterId = nil
  end
end

function lib:new(_wait)
  -- This is a singleton

  self.Queue = self.Queue or {}
  if paused == nil then
    setPaused(self, true)
  end
  self.Wait = _wait or self.Wait or LEQ_WAIT_TIME_IN_MILLISECONDS_DEFAULT

  return lib
end

function lib:addTask(func, name)
  table.insert(self.Queue, 1, { func, name })
end

function lib:continueWith(func, name)
  table.insert(self.Queue, { func, name })
  self:start()
end

function lib:start()
  if isPaused() then
    setPaused(self, false)
    self:executeNextTask()
  end
end

function lib:executeNextTask()
  if isPaused() then
    return
  end
  local nextFunc = table.remove(self.Queue)
  if nextFunc then
    nextFunc[1]()
    if isPaused() then
      return
    end
    cancelPendingTask(self)
    self.NextTaskCallLaterId = zo_callLater(function(callLaterId)
      if self.NextTaskCallLaterId == callLaterId then
        self.NextTaskCallLaterId = nil
      end
      self:executeNextTask()
    end, self.Wait)
  else
    -- Queue empty so pausing
    cancelPendingTask(self)
    setPaused(self, true)
  end
end

function lib:pause()
  setPaused(self, true)
  cancelPendingTask(self)
end

LibExecutionQueue = lib
