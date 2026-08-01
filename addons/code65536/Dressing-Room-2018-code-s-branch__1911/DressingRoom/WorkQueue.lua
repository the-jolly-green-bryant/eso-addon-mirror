DVDWorkQueue = {}
DVDWorkQueue["__index"] = DVDWorkQueue


function DVDWorkQueue:new()
  local q = { first = 1, last = 0 }
  setmetatable(q, self)
  return q
end


function DVDWorkQueue:add(fn)
  self[self.last+1] = { run = fn }
  self.last = self.last + 1
end


function DVDWorkQueue:pop()
  local value = self[self.first]
  if not self:empty() then
    self[self.first] = nil
    self.first = self.first + 1
  end
  return value
end


function DVDWorkQueue:empty()
  return self.first > self.last
end


function DVDWorkQueue:run()
  if not self:empty() then
--    self.running = true
    item = self:pop()
    item.run()
--  else
--    self.running = false
  end
end


function DVDWorkQueue:clear()
  while not self:empty() do
    self:pop()
  end
end
