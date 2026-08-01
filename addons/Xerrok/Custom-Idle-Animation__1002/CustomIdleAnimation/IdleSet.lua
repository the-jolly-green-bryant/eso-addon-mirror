IdleSet = class(
	function (idleSet, title)
		idleSet.title = title
		idleSet.delay = 0
		idleSet.idles = {}
		idleSet.activeIdleIndex = 0
	end
)

function IdleSet.Copy(savedIdleSet)
	local self = IdleSet(savedIdleSet.title)

	if (savedIdleSet.delay ~= nil) then
		self.delay = savedIdleSet.delay
	end

	for _, idle in ipairs(savedIdleSet.idles) do
		table.insert(self.idles, Idle.Copy(idle))
	end

	return self
end

function IdleSet:Add(idle)
	table.insert(self.idles, idle)
end

function IdleSet:Remove(idle)
	local index = FindIndex(self.idles, idle)
	if (index ~= nil) then
		table.remove(self.idles, index)
		self.activeIdleIndex = 0
		self:SetActiveIdle()
	end
end

function IdleSet:Get(emoteSlashName)
	for _, idle in ipairs(self.idles) do
		if (idle.emoteSlashName == emoteSlashName) then
			return idle
		end
	end
end

function IdleSet:Start()
	if Length(self.idles) > 0 then
		self:SetActiveIdle()
	else
		self:Stop()
	end
end

function IdleSet:Stop()
	EVENT_MANAGER:UnregisterForUpdate("IdleSetPlayer")
	EVENT_MANAGER:UnregisterForUpdate("IdleSetDelayIdlePlayer")
	EVENT_MANAGER:UnregisterForUpdate("IdleSetRandomizer")
	EVENT_MANAGER:UnregisterForUpdate("IdleSetDelayedUpdateRegister")
end

function IdleSet:Update()
	if (IsBusy()) then
		self:SetActiveIdle()
	else
		self.idles[self.activeIdleIndex]:Play()
	end
end

function IdleSet:SetActiveIdle(ignoreDelay)
	self:Stop()
	
	if (IsBusy()) then
		EVENT_MANAGER:RegisterForUpdate("IdleSetRandomizer", 500, function() self:SetActiveIdle(ignoreDelay) end)
		return
	end
	
	if (ignoreDelay ~= true and self.delay > 0) then
		EVENT_MANAGER:RegisterForUpdate("IdleSetDelayIdlePlayer", self.delay * 1000, function() self:SetActiveIdle(true) end)
		return
	end

	self.activeIdleIndex = self:GetRandomIdleIndex()
	local playTime = self.idles[self.activeIdleIndex].minimumTime * 1000
	self:Update()
	EVENT_MANAGER:RegisterForUpdate("IdleSetRandomizer", playTime, function() self:SetActiveIdle(true) end)
	
	if (self.idles[self.activeIdleIndex].loop) then
		local counter = 1
		EVENT_MANAGER:RegisterForUpdate("IdleSetDelayedUpdateRegister", 100, function()
			if (IsBusy()) then
				EVENT_MANAGER:UnregisterForUpdate("IdleSetDelayedUpdateRegister")
				self:SetActiveIdle()
			elseif (counter >= 15) then
				EVENT_MANAGER:RegisterForUpdate("IdleSetPlayer", 500, function() self:Update() end)
				EVENT_MANAGER:UnregisterForUpdate("IdleSetDelayedUpdateRegister")
			else
				counter = counter + 1
			end
		end)
	end
end

function IdleSet:GetRandomIdleIndex()
	if (Length(self.idles) == 1) then
		return 1
	end

	local randMax = 0
	local idlesCount = Length(self.idles)
	for i=1, idlesCount do
		randMax = randMax + self.idles[i].priority
	end

	local rand = math.random(randMax)
	local puffer = 0
	for i=1, idlesCount do
		puffer = puffer + self.idles[i].priority
		if rand <= puffer then
			puffer = i
			break
		end
	end
	
	return puffer
end