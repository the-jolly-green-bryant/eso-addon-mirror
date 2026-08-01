-----------------------------------------------------------------------------
-- 					      									               --
-- 	Title:		 Tamriel Chronos                    					   --
--	Description: Tamriel Time and astronomical data                        --
--	Author: 	 Gandalf (@Gandalf2675)									   --
-- 					      									               --
-----------------------------------------------------------------------------

TaChronos.health = TaChronos.health or {}
local health     = TaChronos.health
  	

function health:Initialize()
	self.playingSince  = GetTimeStamp()
	self.playingToLong = 0
	self.cycles        = 0
	self.initialized   = true
end

local function AlertPlayer(msg)
	local icon                         = zo_iconFormat("/esoui/art/tutorial/timer_icon.dds",42,42)
	local sound                        = SOUNDS.RAID_TRIAL_COUNTER_UPDATE
	-- CSA_CATEGORY_SMALL_TEXT         = 1
	-- CSA_CATEGORY_LARGE_TEXT         = 2
	-- CSA_CATEGORY_NO_TEXT            = 3
	-- CSA_CATEGORY_RAID_COMPLETE_TEXT = 4
	-- CSA_CATEGORY_MAJOR_TEXT         = 5
	-- CSA_CATEGORY_COUNTDOWN_TEXT     = 6 
 	local category                     = CSA_CATEGORY_SMALL_TEXT 
    local params                       = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(category)

	params:SetSound(sound)
	params:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_POI_DISCOVERED)
	params:SetLifespanMS(5000)
	params:SetText(icon.." "..msg)
	
	CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
end

function health:Update()
	local limit = TaChronos.cm:GetTimeLimit()
	if limit == 0 then return end
	if GetDiffBetweenTimeStamps(GetTimeStamp(), self.playingSince) > limit*60 then
		if self.playingToLong <= 100 then
			if self.playingToLong % 20 == 0 then
				if self.playingToLong == 100 then
					self.playingSince  = GetTimeStamp()
					self.playingToLong = 0
					self.cycles        = self.cycles+1
					AlertPlayer(zo_strformat(SI_TACHRONOS_PLAYER_ALERT_FINAL, limit))
					return
				else
					AlertPlayer(zo_strformat(SI_TACHRONOS_PLAYER_ALERT, limit))	
				end
			end		
			self.playingToLong = self.playingToLong + 1
		end
	end
end

function health:GetTimePlayed()
	local secs = 0
	local diff = 0
	local limit = TaChronos.cm:GetTimeLimit()
	if limit > 0 then
		diff = GetDiffBetweenTimeStamps(GetTimeStamp(), self.playingSince) 
		secs = diff + (self.cycles * (limit*60 +100)) -- diff plus the cycles times limit+alert periode
	end
	return secs
end