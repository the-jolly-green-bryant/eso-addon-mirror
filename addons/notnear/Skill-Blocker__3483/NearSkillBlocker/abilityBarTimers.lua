NEAR_SB.AbilityBarTimers = {}
-------------------------------------------------------------------------------------------------------------------------------------------------------------------

local originalActionButton_SetTimer = ActionButton["SetTimer"]

local function myActionButton_SetTimer(self, durationMS)
	self.endTimeMS = GetFrameTimeMilliseconds() + durationMS
	self.timerText:SetHidden(true) -- changed to true from original to keep text hidden
	local slotNum = self:GetSlot()
	local hotbarCategory = self:GetHotbarCategory()
	local actionType = GetSlotType(slotNum, hotbarCategory)
	local abilityId = GetSlotBoundId(slotNum, hotbarCategory)
	if actionType == ACTION_TYPE_ABILITY and ShouldAbilityShowAsUsableWithDuration(abilityId) then
		self.timerOverlay:SetHidden(true)
	else
		self.timerOverlay:SetHidden(false)
	end
	self.slot:SetHandler("OnUpdate", function() self:UpdateTimer() end, "TimerUpdate")
end

function NEAR_SB.AbilityBarTimers.Init()
	local hide = NEAR_SB.ASV.abilityBarHideTimers
	if hide then
		ActionButton["SetTimer"] = myActionButton_SetTimer
	else
		ActionButton["SetTimer"] = originalActionButton_SetTimer
	end
end
