-----------------------------------------------------------------------------
-- 					      									               --
-- 	Title:		 Tamriel Chronos                    					   --
--	Description: Tamriel Time and astronomical data                        --
--	Author: 	 Gandalf (@Gandalf2675)  								   --
-- 					      									               --
-----------------------------------------------------------------------------

TaChronos = TaChronos or {}
  	
TaChronos.ADDON_NAME     = "TamrielChronos"
TaChronos.ADDON_TITLE    = "Tamriel Chronos"
TaChronos.ADDON_AUTHOR   = LibAddonMgmt:GetAuthor(TaChronos.ADDON_NAME)
TaChronos.ADDON_VERSION  = LibAddonMgmt:GetVersion(TaChronos.ADDON_NAME)
TaChronos.RELEASESTRING  = "28.06.22 "..TaChronos.ADDON_VERSION
TaChronos.log            = false
TaChronos.hideClock      = false
TaChronos.zoomClock	     = false
TaChronos.playingToLong  = 0
TaChronos.clocks         = {}

-- Check for correct installation
LibAddonMgmt:IsInstalledCorrectly(TaChronos.ADDON_NAME)


function updatePerfStats(stats, value)
	if not stats then stats = {} end
	value = (GetGameTimeSeconds()-value)*1000
	stats.last = value
	if not stats.low  or stats.low  > value then stats.low  = value end
	if not stats.high or stats.high < value then stats.high = value end	
	return stats
end

function TaChronos:OnAddonLoaded(eventCode, addOnName)
	if addOnName == self.ADDON_NAME then
		self.cm:Initialize()
		EVENT_MANAGER:RegisterForEvent( self.ADDON_NAME, EVENT_PLAYER_ACTIVATED, function (...) self:OnPlayerActivated(...) end)	 
		EVENT_MANAGER:UnregisterForEvent(self.ADDON_NAME, EVENT_ADD_ON_LOADED) 
	end	
end

function TaChronos:OnPlayerActivated()
	if not self.initialized then-- initial load
		self:InitializeClocks()
		self.conv:Initialize()
		self.cal:Initialize()
		self.hol:Initialize()
		if self.cm.config.hide then
			self.hideClock = true
		end
		self:RefreshClocks()
		EVENT_MANAGER:UnregisterForEvent(self.ADDON_NAME, EVENT_PLAYER_ACTIVATED) 
		TaChronos.health:Initialize()
		self.initialized  = true
		EVENT_MANAGER:RegisterForUpdate(self.ADDON_NAME, 1000, function(...) self:Update(...) end)	
		self:Update() -- to avoid the 1 sec glitch
	end 
end

function TaChronos:InitializeClocks() 
	for k,clock in pairs(self.clocks) do
		clock:Initialize()
	end
end

function TaChronos:RefreshClocks() 
	for k,clock in pairs(self.clocks) do
		clock:Refresh()
	end
end

function TaChronos:Update()
	local msStart = GetGameTimeSeconds() 
	TaChronos.health:Update()
	local mode = TaChronos.cm:GetClockMode()
	if not self:IsClockHidden() then self.clocks[mode]:Update() end
	self.msUpdate = updatePerfStats(self.msUpdate, msStart)
end

function TaChronos:IsClockHidden()
	return self.hideClock
end

function TaChronos:ToggleClock()
	self.hideClock = not self.hideClock
	self:RefreshClocks()
end

function TaChronos:IsClockZoomed()
	return self.zoomClock
end

function TaChronos:ToggleZoom()
	local mode  = TaChronos.cm:GetClockMode()
	local clock = self.clocks[mode]

	self.zoomClock = not self.zoomClock
	if self.zoomClock then 
		clock:ZoomIn()
	else
		clock:ZoomOut()
	end
end

function TaChronos:ResetZoom()
	self.zoomClock = false
	local mode  = TaChronos.cm:GetClockMode()
	local clock = self.clocks[mode]
	clock:ZoomOut()
end

function TaChronos:ToggleConversion()
	if self.conv:IsHidden() then
		self.conv:ShowConv()
	else
		self.conv:HideConv()
	end
end

-- Hook initialization onto the ADD_ON_LOADED event
EVENT_MANAGER:RegisterForEvent(TaChronos.ADDON_NAME, EVENT_ADD_ON_LOADED, function(...) TaChronos:OnAddonLoaded(...) end)


