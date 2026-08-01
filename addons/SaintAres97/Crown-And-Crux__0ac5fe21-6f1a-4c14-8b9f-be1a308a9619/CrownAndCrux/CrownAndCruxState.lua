local M = {}
CrownAndCruxState = M  -- assign it to the global name

M.stacks = 0
M.maxStacks = 3
M.prevStacks = 0

-- Set the number of stacks and remember the previous value
function M:SetStacks(count)
    self.prevStacks = self.stacks  -- track last value
    self.stacks = count
end

--- Get the current stack count
--- @return number
function M:GetStacks()
    return self.stacks
end

--- Clear all stacks
function M:ClearStacks()
    self.prevStacks = self.stacks
    self.stacks = 0
end


