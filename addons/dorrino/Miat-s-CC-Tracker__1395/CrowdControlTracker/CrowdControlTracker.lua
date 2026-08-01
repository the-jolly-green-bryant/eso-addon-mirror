CCT={}
CCT.LAM2 = LibAddonMenu2
CCT.textVersion="1.48"
CCT.version=1.05
CCT.name = "CrowdControlTracker"

local PriorityOne, PriorityTwo, PriorityThree, PriorityFour, PrioritySix

local CCT_STAGGER_DURATION = 800
local CCT_AREA_DURATION=1100
local CCT_GRACE_TIME = 5

local CCT_ICON_FONT = "$(GAMEPAD_BOLD_FONT)|25|thick-outline"
local CCT_STAGGER_FONT = "$(GAMEPAD_BOLD_FONT)|36|thick-outline"
local CCT_ZOS_DEFAULT_ICON = "/esoui/art/icons/ability_mage_065.dds"

local CCT_DEFAULT_STUN_ICON = "/esoui/art/inventory/gamepad/gp_inventory_icon_apparel.dds"
local CCT_DEFAULT_FEAR_ICON = "/esoui/art/compass/ava_murderball_neutral.dds"
local CCT_DEFAULT_DISORIENT_ICON = "/esoui/art/ava/ava_rankicon64_grandoverlord.dds"
local CCT_DEFAULT_SILENCE_ICON = "/esoui/art/icons/heraldrycrests_misc_eye_01.dds"

local CCT_DEFAULT_IMMUNE_ICON = "/esoui/art/screens_app/load_ourosboros.dds"

local CCT_DEFAULT_ICONBORDER = "/esoui/art/actionbar/debuff_frame.dds"
local CCT_ICONBORDER = "CrowdControlTracker/img/border.dds"

local CCT_SET_SCALE_FROM_SV = true
local CCT_BREAK_FREE_ID = 16565
local CCT_NEGATE_MAGIC_ID = 47158
local CCT_NEGATE_MAGIC_1_ID = 51894
local CCT_ICON_MISSING="icon_missing"

local ACTION_RESULT_AREA_EFFECT=669966

local function d() end

CCT.controlTypes={
	ACTION_RESULT_STUNNED,
	ACTION_RESULT_FEARED,
	ACTION_RESULT_DISORIENTED,
	ACTION_RESULT_SILENCED,
	ACTION_RESULT_STAGGERED,
	ACTION_RESULT_AREA_EFFECT,
}

CCT.actionResults = {
	[ACTION_RESULT_STUNNED] = true,
	[ACTION_RESULT_FEARED] = true,
	[ACTION_RESULT_DISORIENTED] = true,
}

CCT.controlText={
	[ACTION_RESULT_STUNNED]		= "STUNNED",
	[ACTION_RESULT_FEARED]		= "FEARED",
	[ACTION_RESULT_DISORIENTED] = "DISORIENTED",
	[ACTION_RESULT_SILENCED]	= "SILENCED",
	[ACTION_RESULT_STAGGERED]	= "STAGGER",
	[ACTION_RESULT_IMMUNE]		= "IMMUNE",
	[ACTION_RESULT_DODGED]		= "DODGED",
	[ACTION_RESULT_BLOCKED]		= "BLOCKED",
	[ACTION_RESULT_BLOCKED_DAMAGE]	= "BLOCKED",
	[ACTION_RESULT_AREA_EFFECT] = "AREA DAMAGE",
}

CCT.aoeHitTypes={
	[ACTION_RESULT_BLOCKED]			= true,
	[ACTION_RESULT_BLOCKED_DAMAGE]		= true,
	[ACTION_RESULT_CRITICAL_DAMAGE]		= true,
	[ACTION_RESULT_DAMAGE]			= true,
	[ACTION_RESULT_DAMAGE_SHIELDED]		= true,
	[ACTION_RESULT_IMMUNE]			= true,
	[ACTION_RESULT_MISS]			= true,
	[ACTION_RESULT_PARTIAL_RESIST]		= true,
	[ACTION_RESULT_REFLECTED]		= true,
	[ACTION_RESULT_RESIST]			= true,
	[ACTION_RESULT_WRECKING_DAMAGE]		= true,
	[ACTION_RESULT_SNARED]	= true,
}

CCT.accountWideDefaults={
	accountWide=true
}

CCT.defaults={
	enabled=true,
	enabledOnlyInCyro=false,
	unlocked=true,
	controlScale=1.0,
	playAnimation=true,
	playSound=true,
	useAbilityName=true,
	showStaggered=true,
	showImmune=true,
	showAoe=true,
	showGCD=false,
	showImmuneOnlyInCyro=true,
	immuneDisplayTime=750,
	showOptions="all",
	offsetX=0,
	offsetY=0,
	colors={
		[ACTION_RESULT_STUNNED]={0.894118, 0.133333, 0.090196, 1},
		[ACTION_RESULT_DISORIENTED]={0.0313725509,0.6274510026,1, 1},
		[ACTION_RESULT_FEARED]={0.5607843137, 0.0352941176, 0.9254901961, 1},
		[ACTION_RESULT_SILENCED]={0, 1, 1, 1},
		[ACTION_RESULT_STAGGERED]={1,0.9490196109,0.1294117719,1},
		[ACTION_RESULT_IMMUNE]={1,1,1,1},
		[ACTION_RESULT_DODGED]={1,1,1,1},
		[ACTION_RESULT_BLOCKED]={1,1,1,1},
		[ACTION_RESULT_BLOCKED_DAMAGE]={1,1,1,1},
		[ACTION_RESULT_AREA_EFFECT]={1,0.69,0,1},
	}
}

CCT.aoeTypesId ={
	[159391] = 1, --Dark Convergence
	[85126] = 2, --Fiery Rage Ultimate
	[83682] = 3, --Eye of Flame Ultimate
	[83625] = 4, --Fire Storm Ultimate
	[85128] = 5, --Icy Rage Ultimate
	[83684] = 6, --Eye of Frost Ultimate
	[83628] = 7, --Ice Storm Ultimate
	[85130] = 8, --Thunderous Rage Ultimate
	[83686] = 9, --Eye of Lightning Ultimate
	[83630] = 10, --Thunder Storm Ultimate
	[86117] = 11, --Permafrost
	[86113] = 12, --Northern Storm
	[86109] = 13, --Sleet Storm
	[32947] = 14, --Standard of Might Ultimate
	[32958] = 15, --Shifting Standard Ultimate
	[28988] = 16, --Dragonknight Standard Ultimate
	[38931] = 17, --Devouring Swarm Ultimate
	[38932] = 18, --Clouding Swarm Ultimate
	[32624] = 19, --Bat Swarm Ultimate
	[21758] = 20, --Solar Disturbance Ultimate
	[21755] = 21, --Solar Prison Ultimate
	[21752] = 22, --Nova Ultimate
	[104007] = 23, -- Time Stop
	[104072] = 24, -- Borrowed Time
	[104082] = 25, -- Time Freeze
	[36485] = 26, --Veil of Blades Ultimate
	[40493] = 27, --Shooting Star Ultimate
	[40489] = 28, --Ice Comet Ultimate
	[16536] = 29, --Meteor Ultimate
}

function CC_Tracker_SavePosition()
	local coordX, coordY=CC_Tracker:GetCenter()
	CCT.SV.offsetX=coordX-(GuiRoot:GetWidth()/2)
	CCT.SV.offsetY=coordY-(GuiRoot:GetHeight()/2)
	CC_Tracker:ClearAnchors()
	CC_Tracker:SetAnchor(CENTER, GuiRoot, CENTER, CCT.SV.offsetX, CCT.SV.offsetY)
end

function CC_Tracker_OnUpdate(control)
	if CCT.Timer==0 or not CCT.Timer then return end

	local timeLeft = math.ceil(CCT.Timer - GetFrameTimeSeconds())
	if timeLeft>0 then
		CC_Tracker_Timer_Label:SetText(timeLeft)
	end
end

function CCT:OnProc(ccDuration, interval)
	self:OnAnimation(CC_Tracker, "proc")
	if self.SV.playSound then
		PlaySound(SOUNDS.DEATH_RECAP_KILLING_BLOW_SHOWN)
		PlaySound(SOUNDS.DEATH_RECAP_KILLING_BLOW_SHOWN)
	end
	self.Timer=GetFrameTimeSeconds()+(interval/1000)

	local remaining, duration, global = GetSlotCooldownInfo(1)
	if remaining>0 then
		CC_Tracker_IconFrame_GlobalCooldown:ResetCooldown()
		if self.SV.showGCD and CCT:IsInPVPZone() then
			CC_Tracker_IconFrame_GlobalCooldown:SetHidden(false)
			CC_Tracker_IconFrame_GlobalCooldown:StartCooldown(remaining, remaining, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_UNTIL, false)
			zo_callLater(function() CC_Tracker_IconFrame_GlobalCooldown:SetHidden(true) end, remaining)
		end
	end
	CC_Tracker_IconFrame_Cooldown:ResetCooldown()
	CC_Tracker_IconFrame_Cooldown:StartCooldown(interval, ccDuration, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_REMAINING, false)

	self:SetupDisplay("timer")
end

function CCT:OnAnimation(control, animationType, param)
	self:SetupDisplay(animationType)
	if self.SV.playAnimation then
		if animationType=="immune" then
			self.immunePlaying=self:StartAnimation(control, animationType)
		elseif animationType=="breakfree" then
			self.breakFreePlaying=self:BreakFreeAnimation()
		else
			self.currentlyPlaying=self:StartAnimation(control, animationType)
		end
	elseif param then CC_Tracker:SetHidden(not self.SV.unlocked)
	end
end

function CCT:GeneratePriorityTable()
	self.aoeTypes = {}
	for k,v in pairs (self.aoeTypesId) do
		self.aoeTypes[GetAbilityName(k)] = v
	end
end

function CCT:AoePriority(abilityName, result)

	if self.aoeTypes[abilityName] and self.aoeHitTypes[result] and ((not self.aoeTypes[PrioritySix.abilityName]) or (self.aoeTypes[abilityName]<=self.aoeTypes[PrioritySix.abilityName])) then return true else return false end

end

function CCT:OnCombat(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, combat_log, sourceUnitId, targetUnitId, abilityId)

	local function StringEnd(String,End)
		return End=='' or string.sub(String,-string.len(End))==End
	end

	local function StringStart(String,Start)
	   return string.sub(String,1,string.len(Start))==Start
	end

	local malformedName

	if StringStart(abilityName, 'Major') or StringStart(abilityName, 'Minor') then return end

	if not StringEnd(self.playerName,'^Mx') and not StringEnd(self.playerName,'^Fx') then malformedName = true end

	if result==ACTION_RESULT_EFFECT_GAINED_DURATION and ((not malformedName and sourceName==self.playerName) or (malformedName and (sourceName==self.playerName..'^Mx' or sourceName==self.playerName..'^Fx'))) and (abilityName == "Break Free" or abilityName == GetAbilityName(CCT_BREAK_FREE_ID) or abilityId==CCT_BREAK_FREE_ID) then
		if self.SV.showOptions=="text" then self:StopDraw(true)	else self:StopDrawBreakFree() end return
	end

	--51894
	-----------------DISORIENT PROCESSING-------------------------------

	if result==ACTION_RESULT_EFFECT_FADED and ((not malformedName and targetName==self.playerName) or (malformedName and (targetName==self.playerName..'^Mx' or targetName==self.playerName..'^Fx'))) then
		if GetFrameTimeMilliseconds()<=(PriorityTwo.endTime+CCT_GRACE_TIME) and #self.fearsQueue~=0 then
			local found_k
			for k, v in pairs (self.fearsQueue) do
				if v==abilityId then found_k=k break end
			end
			if found_k then
				table.remove(self.fearsQueue, found_k)
				if #self.fearsQueue==0 then self:RemoveCC(2, PriorityTwo.endTime) end
			end
		elseif GetFrameTimeMilliseconds()<=(PriorityThree.endTime+CCT_GRACE_TIME) and #self.disorientsQueue~=0 then
			local found_k
			for k, v in pairs (self.disorientsQueue) do
				if v==abilityId then found_k=k break end
			end
			if found_k then
				table.remove(self.disorientsQueue, found_k)
				if #self.disorientsQueue==0 then self:RemoveCC(3, PriorityThree.endTime) end
			end
		end
	end

	------------------------------------------------
	if ((not malformedName and targetName~=self.playerName) or (malformedName and (targetName~=self.playerName..'^Mx' and targetName~=self.playerName..'^Fx'))) or targetName=="" or targetType~=1 or ((not malformedName and sourceName==self.playerName) or (malformedName and (sourceName==self.playerName..'^Mx' or sourceName==self.playerName..'^Fx'))) or sourceName=="" or sourceUnitId==0 or self.breakFreePlaying then return end

	if self.SV.showAoe and self:AoePriority(abilityName, result) then
		local currentEndTimeArea=GetFrameTimeMilliseconds()+CCT_AREA_DURATION
		PrioritySix={endTime = currentEndTimeArea, abilityId = abilityId, hitValue = hitValue, result=ACTION_RESULT_AREA_EFFECT, abilityName=abilityName}
		if PriorityOne.endTime==0 and PriorityTwo.endTime==0 and PriorityThree.endTime==0 and PriorityFour.endTime==0 then
			self.currentCC=6
			zo_callLater(function() self:RemoveCC(6, currentEndTimeArea) end, CCT_AREA_DURATION+CCT_GRACE_TIME)
			self:OnDraw(abilityId, CCT_AREA_DURATION, ACTION_RESULT_AREA_EFFECT, abilityName, CCT_AREA_DURATION)
		end
	end

	local validResults = {
		[ACTION_RESULT_EFFECT_GAINED_DURATION] = true,
		[ACTION_RESULT_STUNNED] = true,
		[ACTION_RESULT_FEARED] = true,
		[ACTION_RESULT_STAGGERED] = true,
		[ACTION_RESULT_IMMUNE] = true,
		[ACTION_RESULT_DODGED] = true,
		[ACTION_RESULT_BLOCKED] = true,
		[ACTION_RESULT_BLOCKED_DAMAGE] = true,
		[ACTION_RESULT_DISORIENTED] = true,
	}

	if not validResults[result] then return end

	-- if result == ACTION_RESULT_STUNNED then
		-- d('STUNNED after')
	-- end

	-- if result~=ACTION_RESULT_EFFECT_GAINED_DURATION and result~=ACTION_RESULT_STUNNED and result~=ACTION_RESULT_FEARED and result~=ACTION_RESULT_STAGGERED and result~=ACTION_RESULT_IMMUNE and result~=ACTION_RESULT_DISORIENTED then return end

	if abilityName=="Hiding Spot" then return end

	-------------STAGGERED EVENT TRIGGER--------------------
	if self.SV.showStaggered and result==ACTION_RESULT_STAGGERED and self.currentCC==0 then
		zo_callLater(function() self:RemoveCC(5, GetFrameTimeMilliseconds()) end, CCT_STAGGER_DURATION)
		self:OnDraw(abilityId, CCT_STAGGER_DURATION, result, abilityName, CCT_STAGGER_DURATION)
	end
	--------------------------------------------------------

	-------------IMMUNE EVENT TRIGGER-----------------------
	if self.SV.showImmune and (result==ACTION_RESULT_IMMUNE or (PVP_Alerts_Main_Table and (result==ACTION_RESULT_DODGED or result==ACTION_RESULT_BLOCKED or result == ACTION_RESULT_BLOCKED_DAMAGE) and PVP_Alerts_Main_Table.snipeId[abilityId])) and not (self.SV.showImmuneOnlyInCyro and not self:IsInPVPZone()) and (not self.currentlyPlaying) and self.currentCC==0 and GetAbilityIcon(abilityId)~=nil then
		self:OnDraw(abilityId, self.SV.immuneDisplayTime, result, abilityName, self.SV.immuneDisplayTime)
	end
	-------------------------------------------------------

	if not self.incomingCC then self.incomingCC = {} end

	if result == ACTION_RESULT_EFFECT_GAINED_DURATION then
		if (abilityName==GetAbilityName(CCT_NEGATE_MAGIC_ID) or abilityId==CCT_NEGATE_MAGIC_ID or abilityId==CCT_NEGATE_MAGIC_1_ID) then
			local currentEndTimeSilence=GetFrameTimeMilliseconds()+hitValue
			PriorityFour={endTime=currentEndTimeSilence, abilityId=abilityId, hitValue=hitValue, result=ACTION_RESULT_SILENCED, abilityName=abilityName}
			if PriorityOne.endTime==0 and PriorityTwo.endTime==0 and PriorityThree.endTime==0 then
				self.currentCC=4
				zo_callLater(function() self:RemoveCC(4, currentEndTimeSilence) end, hitValue+CCT_GRACE_TIME)
				self:OnDraw(abilityId, hitValue, ACTION_RESULT_SILENCED, abilityName, hitValue)
			end
		else
			-- d("EVENT " .. " DURATION " .. tostring(GetFrameTimeMilliseconds()))
			-- if self.incomingCC[ACTION_RESULT_FEARED] then
				-- d("FEAR DURATION " .. tostring(GetFrameTimeMilliseconds()))
			-- end
			local currentTime = GetFrameTimeMilliseconds()
			local currentEndTime = currentTime + hitValue
			if abilityId == self.incomingCC[ACTION_RESULT_STUNNED] and (currentEndTime+200) > PriorityOne.endTime then
				-- self.incomingCC[ACTION_RESULT_STUNNED] = nil
				-- CALLBACK_MANAGER:RegisterCallback("OnIncomingStun", function()
					if self.breakFreePlaying then return end
					PriorityOne = {endTime = (GetFrameTimeMilliseconds() + hitValue), abilityId = abilityId, hitValue = hitValue, result = ACTION_RESULT_STUNNED, abilityName = abilityName}
					self.currentCC = 1
					zo_callLater(function() self:RemoveCC(1, currentEndTime) end, hitValue + CCT_GRACE_TIME+1000)
					self:OnDraw(abilityId, hitValue, ACTION_RESULT_STUNNED, abilityName, hitValue)
				-- end)
				-- zo_callLater(function() CALLBACK_MANAGER:UnregisterAllCallbacks("OnIncomingStun") end, 1)
				self.incomingCC = {}
			elseif abilityId == self.incomingCC[ACTION_RESULT_FEARED] and (currentEndTime + 200) > PriorityOne.endTime and (currentEndTime + 200) > PriorityTwo.endTime then
				table.insert(self.fearsQueue, abilityId)
				PriorityTwo={endTime = currentEndTime, abilityId = abilityId, hitValue = hitValue, result = ACTION_RESULT_FEARED, abilityName = abilityName}
				if PriorityOne.endTime == 0 then
					self.currentCC = 2
					zo_callLater(function() self:RemoveCC(2, currentEndTime) end, hitValue + CCT_GRACE_TIME)
					self:OnDraw(abilityId, hitValue, ACTION_RESULT_FEARED, abilityName, hitValue)
				end
				self.incomingCC = {}
			elseif abilityId == self.incomingCC[ACTION_RESULT_DISORIENTED] and (currentEndTime + 200) > PriorityOne.endTime and (currentEndTime + 200) > PriorityTwo.endTime and currentEndTime > PriorityThree.endTime then
				-- self.incomingCC[ACTION_RESULT_DISORIENTED] == nil
				table.insert(self.disorientsQueue, abilityId)
				PriorityThree={endTime = currentEndTime, abilityId = abilityId, hitValue = hitValue, result = ACTION_RESULT_DISORIENTED, abilityName = abilityName}
				if PriorityOne.endTime == 0 and PriorityTwo.endTime == 0 then
					self.currentCC = 3
					zo_callLater(function() self:RemoveCC(3, currentEndTime) end, hitValue + CCT_GRACE_TIME)
					self:OnDraw(abilityId, hitValue, ACTION_RESULT_DISORIENTED, abilityName, hitValue)
				end
				self.incomingCC = {}
			else
				table.insert(self.effectsGained, {abilityId = abilityId, hitValue = hitValue, sourceUnitId = sourceUnitId, abilityGraphic = abilityGraphic})
			end
		end
	elseif #self.effectsGained>0 then
		local foundValue=self:FindEffectGained(abilityId, sourceUnitId, abilityGraphic)
		-- if not foundValue then return end

		if foundValue then
			local currentTime=GetFrameTimeMilliseconds()
			local currentEndTime=currentTime+foundValue.hitValue

			if result==ACTION_RESULT_FEARED and (currentEndTime+200)>PriorityOne.endTime and (currentEndTime+200)>PriorityTwo.endTime then
				table.insert(self.fearsQueue, abilityId)
				PriorityTwo={endTime=currentEndTime, abilityId=abilityId, hitValue=foundValue.hitValue, result=result, abilityName=abilityName}
				if PriorityOne.endTime==0 then
					self.currentCC=2
					zo_callLater(function() self:RemoveCC(2, currentEndTime) end, foundValue.hitValue+CCT_GRACE_TIME)
					self:OnDraw(abilityId, foundValue.hitValue, result, abilityName, foundValue.hitValue)
				end
			end
			self.effectsGained={}
		end
	end

	if self.actionResults[result] then
		self.incomingCC[result] = abilityId
		-- if result == ACTION_RESULT_FEARED then
			-- d("FEAR EVENT " .. tostring(GetFrameTimeMilliseconds()))
		-- end

		-- d("EVENT " .. tostring(result) .. " " .. tostring(GetFrameTimeMilliseconds()))
		-- return
	end



	-- else
		-- if #self.effectsGained>0 then
			-- local foundValue=self:FindEffectGained(abilityId, sourceUnitId, abilityGraphic)
			-- if not foundValue then return end

			-- local currentTime=GetFrameTimeMilliseconds()
			-- local currentEndTime=currentTime+foundValue.hitValue
			-- if result==ACTION_RESULT_STUNNED and (currentEndTime+200)>PriorityOne.endTime then
				-- CALLBACK_MANAGER:RegisterCallback("OnIncomingStun", function()
					-- if self.breakFreePlaying then return end
					-- PriorityOne={endTime=(GetFrameTimeMilliseconds()+foundValue.hitValue), abilityId=abilityId, hitValue=foundValue.hitValue, result=result, abilityName=abilityName}
					-- self.currentCC = 1
					-- zo_callLater(function() self:RemoveCC(1, currentEndTime) end, foundValue.hitValue+CCT_GRACE_TIME+1000)
					-- d('draw stun')
					-- self:OnDraw(abilityId, foundValue.hitValue, result, abilityName, foundValue.hitValue)
				-- end)
				-- zo_callLater(function() CALLBACK_MANAGER:UnregisterAllCallbacks("OnIncomingStun") end, 1)

			-- elseif result==ACTION_RESULT_FEARED and (currentEndTime+200)>PriorityOne.endTime and (currentEndTime+200)>PriorityTwo.endTime then
				-- table.insert(self.fearsQueue, abilityId)
				-- PriorityTwo={endTime=currentEndTime, abilityId=abilityId, hitValue=foundValue.hitValue, result=result, abilityName=abilityName}
				-- if PriorityOne.endTime==0 then
					-- self.currentCC=2
					-- zo_callLater(function() self:RemoveCC(2, currentEndTime) end, foundValue.hitValue+CCT_GRACE_TIME)
					-- self:OnDraw(abilityId, foundValue.hitValue, result, abilityName, foundValue.hitValue)
				-- end

			-- elseif result==ACTION_RESULT_DISORIENTED and (currentEndTime+200)>PriorityOne.endTime and (currentEndTime+200)>PriorityTwo.endTime and currentEndTime>PriorityThree.endTime then
				-- table.insert(self.disorientsQueue, abilityId)
				-- PriorityThree={endTime=currentEndTime, abilityId=abilityId, hitValue=foundValue.hitValue, result=result, abilityName=abilityName}
				-- if PriorityOne.endTime==0 and PriorityTwo.endTime==0 then
					-- self.currentCC=3
					-- zo_callLater(function() self:RemoveCC(3, currentEndTime) end, foundValue.hitValue+CCT_GRACE_TIME)
					-- self:OnDraw(abilityId, foundValue.hitValue, result, abilityName, foundValue.hitValue)
				-- end
			-- end
			-- self.effectsGained={}
		-- end
	-- end
end


function CCT:RemoveCC(ccType, currentEndTime)
	local stagger
	if (self.currentCC==0 and (ccType~=5)) or self.breakFreePlaying then return end
	local currentTime=GetFrameTimeMilliseconds()
	local secondInterval, thirdInterval, fourthInterval, sixthInterval = PriorityTwo.endTime-currentTime,PriorityThree.endTime-currentTime, PriorityFour.endTime-currentTime, PrioritySix.endTime-currentTime
----STUN-----
	if ccType==1 then
		if self.currentCC==1 and PriorityOne.endTime~=currentEndTime then return end
		PriorityOne={endTime=0, abilityId=0, hitValue=0, result=0, abilityName=""}
		if secondInterval>0 then
			self.currentCC=2
			zo_callLater(function() self:RemoveCC(2, PriorityTwo.endTime) end, secondInterval)
			self:OnDraw(PriorityTwo.abilityId, PriorityTwo.hitValue, PriorityTwo.result, PriorityTwo.abilityName, secondInterval)
			return
		elseif thirdInterval>0 then
			self.currentCC=3
			zo_callLater(function() self:RemoveCC(3, PriorityThree.endTime) end, thirdInterval)
			self:OnDraw(PriorityThree.abilityId, PriorityThree.hitValue, PriorityThree.result, PriorityThree.abilityName, thirdInterval)
			return
		elseif fourthInterval>0 then
			self.currentCC=4
			zo_callLater(function() self:RemoveCC(4, PriorityFour.endTime) end, fourthInterval)
			self:OnDraw(PriorityFour.abilityId, PriorityFour.hitValue, PriorityFour.result, PriorityFour.abilityName, fourthInterval)
			return
		elseif sixthInterval>0 then
			self.currentCC=6
			zo_callLater(function() self:RemoveCC(6, PriorityFour.endTime) end, sixthInterval)
			self:OnDraw(PrioritySix.abilityId, PrioritySix.hitValue, PrioritySix.result, PrioritySix.abilityName, sixthInterval)
			return
		end
----FEAR----
	elseif ccType==2 then
		if (self.currentCC==1 or self.currentCC==2) and PriorityTwo.endTime~=currentEndTime then return end
		PriorityTwo={endTime=0, abilityId=0, hitValue=0, result=0, abilityName=""}
		if PriorityOne.endTime>0 and self.currentCC==1 then return end
		if thirdInterval>0 then
			self.currentCC=3
			zo_callLater(function() self:RemoveCC(3, PriorityThree.endTime) end, thirdInterval)
			self:OnDraw(PriorityThree.abilityId, PriorityThree.hitValue, PriorityThree.result, PriorityThree.abilityName, thirdInterval)
			return
		elseif fourthInterval>0 then
			self.currentCC=4
			zo_callLater(function() self:RemoveCC(4, PriorityFour.endTime) end, fourthInterval)
			self:OnDraw(PriorityFour.abilityId, PriorityFour.hitValue, PriorityFour.result, PriorityFour.abilityName, fourthInterval)
			return
		elseif sixthInterval>0 then
			self.currentCC=6
			zo_callLater(function() self:RemoveCC(6, PriorityFour.endTime) end, sixthInterval)
			self:OnDraw(PrioritySix.abilityId, PrioritySix.hitValue, PrioritySix.result, PrioritySix.abilityName, sixthInterval)
			return
		end
----DISORIENT----
	elseif ccType==3 then
		if (self.currentCC>0 and self.currentCC<4) and PriorityThree.endTime~=currentEndTime then --d("DISORIENT discarded")
			return
		end
		PriorityThree={endTime=0, abilityId=0, hitValue=0, result=0, abilityName=""}
		if (PriorityOne.endTime>0 and self.currentCC==1) or (PriorityTwo.endTime>0 and self.currentCC==2) then return end
		if fourthInterval>0 then
			self.currentCC=4
			zo_callLater(function() self:RemoveCC(4, PriorityFour.endTime) end, fourthInterval)
			self:OnDraw(PriorityFour.abilityId, PriorityFour.hitValue, PriorityFour.result, PriorityFour.abilityName, thirdInterval)
			return
		elseif sixthInterval>0 then
			self.currentCC=6
			zo_callLater(function() self:RemoveCC(6, PriorityFour.endTime) end, sixthInterval)
			self:OnDraw(PrioritySix.abilityId, PrioritySix.hitValue, PrioritySix.result, PrioritySix.abilityName, sixthInterval)
			return
		end
----SILENCE----
	elseif ccType==4 then
		if self.currentCC~=0 and PriorityFour.endTime~=currentEndTime then return end
		PriorityFour={endTime=0, abilityId=0, hitValue=0, result=0, abilityName=""}
		if (PriorityOne.endTime>0 and self.currentCC==1) or (PriorityTwo.endTime>0 and self.currentCC==2) or (PriorityThree.endTime>0 and self.currentCC==3) then return end
		elseif sixthInterval>0 then
			self.currentCC=6
			zo_callLater(function() self:RemoveCC(6, PriorityFour.endTime) end, sixthInterval)
			self:OnDraw(PrioritySix.abilityId, PrioritySix.hitValue, PrioritySix.result, PrioritySix.abilityName, sixthInterval)
		return
----STAGGER----
	elseif ccType==5 then
		if self.currentCC~=0 then
			return
		else
			stagger=true
		end
----AOE----
	elseif ccType==6 then
		if self.currentCC~=0 and PrioritySix.endTime~=currentEndTime then return end
		PrioritySix={endTime=0, abilityId=0, hitValue=0, result=0, abilityName=""}
		if (PriorityOne.endTime>0 and self.currentCC==1) or (PriorityTwo.endTime>0 and self.currentCC==2) or (PriorityThree.endTime>0 and self.currentCC==3) or (PriorityFour.endTime>0 and self.currentCC==4) then return end
	end

	if self.SV.showOptions=="text" then stagger=true end
	self:StopDraw(stagger)
end

function CCT:OnStunnedState(eventCode, playerStunned)
	-- d('playerStunned: '..tostring(playerStunned))
	if not playerStunned then
		-- d("PriorityOne.endTime", PriorityOne.endTime)
		if PriorityOne.endTime~=0 then
			self:RemoveCC(1, PriorityOne.endTime)
		end
	else
		-- CALLBACK_MANAGER:FireCallbacks("OnIncomingStun")
	end
end

function CCT:GetDefaultIcon(ccType)
	if ccType==ACTION_RESULT_STUNNED then return CCT_DEFAULT_STUN_ICON
	elseif ccType==ACTION_RESULT_FEARED then return CCT_DEFAULT_FEAR_ICON
	elseif ccType==ACTION_RESULT_DISORIENTED then return CCT_DEFAULT_DISORIENT_ICON
	elseif ccType==ACTION_RESULT_SILENCED then return CCT_DEFAULT_SILENCE_ICON
	elseif ccType==ACTION_RESULT_AREA_EFFECT then return CCT_ZOS_DEFAULT_ICON
	elseif ccType==ACTION_RESULT_IMMUNE then return CCT_DEFAULT_IMMUNE_ICON
	elseif ccType==ACTION_RESULT_DODGED then return CCT_DEFAULT_IMMUNE_ICON
	elseif ccType==ACTION_RESULT_BLOCKED then return CCT_DEFAULT_IMMUNE_ICON
	elseif ccType==ACTION_RESULT_BLOCKED_DAMAGE then return CCT_DEFAULT_IMMUNE_ICON
	end
end


function CCT:OnDraw(abilityId, ccDuration, result, abilityName, interval)

	if result==ACTION_RESULT_STAGGERED then self:OnAnimation(CC_Tracker, "stagger")	return end

	local wasDefault
	local abilityIcon = GetAbilityIcon(abilityId)
	if abilityIcon==CCT_ZOS_DEFAULT_ICON then
		abilityIcon=self:GetDefaultIcon(result)
		wasDefault=true
	end

	local ccText
	if self.SV.useAbilityName then
		ccText=zo_strformat(SI_ABILITY_NAME, abilityName)
	else
		ccText=self.controlText[result]
	end

	self:SetupInfo(ccText, self.SV.colors[result], abilityIcon, wasDefault)

	if result==ACTION_RESULT_SILENCED or result==ACTION_RESULT_AREA_EFFECT then
		if self.SV.showOptions=="text" then
			self:OnAnimation(CC_Tracker_TextFrame, "silence")
		else
			self:OnAnimation(CC_Tracker_IconFrame, "silence")
		end
	elseif result==ACTION_RESULT_IMMUNE or result==ACTION_RESULT_DODGED or result==ACTION_RESULT_BLOCKED or result == ACTION_RESULT_BLOCKED_DAMAGE then
		self:OnAnimation(CC_Tracker, "immune")
		if wasDefault then CC_Tracker_IconFrame_Icon:SetTextureCoords(0.2,0.8,0.2,0.8) end
	else
		self:OnProc(ccDuration, interval)
	end
end

function CCT:IconHidden(hidden)
	if self.SV.showOptions=="text" then
		CC_Tracker_IconFrame:SetHidden(true)
	else
		CC_Tracker_IconFrame:SetHidden(hidden)
	end
end

function CCT:TimerHidden(hidden)
	if self.SV.showOptions=="text" then
		CC_Tracker_Timer:SetHidden(true)
	else
		CC_Tracker_Timer:SetHidden(hidden)
	end
end

function CCT:TextHidden(hidden)
	if self.SV.showOptions=="icon" then
		CC_Tracker_TextFrame:SetHidden(true)
	else
		CC_Tracker_TextFrame:SetHidden(hidden)
	end
end

function CCT:BreakFreeHidden(hidden)
	if self.SV.showOptions=="text" then
		CC_Tracker_BreakFreeFrame:SetHidden(true)
	else
		CC_Tracker_BreakFreeFrame:SetHidden(hidden)
	end
end

function CCT:SetupInfo(ccText, ccColor, abilityIcon, wasDefault)
	CC_Tracker_TextFrame_Label:SetFont(CCT_ICON_FONT)
	CC_Tracker_TextFrame_Label:SetText(ccText)
	CC_Tracker_TextFrame_Label:SetColor(unpack(ccColor))
	CC_Tracker_IconFrame_Icon:SetTexture(abilityIcon)

	if wasDefault then
		CC_Tracker_IconFrame_Icon:SetColor(unpack(ccColor))
	else
		CC_Tracker_IconFrame_Icon:SetColor(1,1,1,1)
	end

	CC_Tracker_IconFrame_IconBG:SetColor(unpack(ccColor))

	CC_Tracker_IconFrame_IconBorder:SetColor(unpack(ccColor))
	CC_Tracker_IconFrame_IconBorderHighlight:SetColor(unpack(ccColor))

	CC_Tracker_Timer_Label:SetColor(unpack(ccColor))
end

function CCT:SetupDisplay(displayType)
	if displayType=="silence" then
		CC_Tracker_IconFrame_Cooldown:SetHidden(true)
		CC_Tracker_IconFrame_GlobalCooldown:SetHidden(true)
		CC_Tracker_IconFrame_IconBorderHighlight:SetHidden(false)

		CC_Tracker_IconFrame_Icon:SetTextureCoords(0,1,0,1)
		self:IconHidden(false)

		self:TextHidden(false)

		self:TimerHidden(true)

		self:BreakFreeHidden(true)

		CC_Tracker:SetHidden(false)

	elseif displayType=="immune" then
		CC_Tracker_IconFrame_Cooldown:SetHidden(true)
		CC_Tracker_IconFrame_GlobalCooldown:SetHidden(true)
		CC_Tracker_IconFrame_IconBorderHighlight:SetHidden(true)

		CC_Tracker_IconFrame_Icon:SetTextureCoords(0,1,0,1)
		CC_Tracker_IconFrame_IconBG:SetColor(0,0,0)
		self:IconHidden(false)

		self:TextHidden(false)

		self:TimerHidden(true)

		self:BreakFreeHidden(true)

		CC_Tracker:SetHidden(false)

	elseif displayType=="stagger" then
		CC_Tracker_TextFrame_Label:SetText(CCT.controlText[ACTION_RESULT_STAGGERED])
		CC_Tracker_TextFrame_Label:SetColor(unpack(self.SV.colors[ACTION_RESULT_STAGGERED]))
		CC_Tracker_TextFrame_Label:SetFont(CCT_STAGGER_FONT)
		self:TextHidden(false)


		self:IconHidden(true)
		self:TimerHidden(true)

		self:BreakFreeHidden(true)

		CC_Tracker:SetHidden(false)

	elseif displayType=="breakfree" then
		self:IconHidden(true)

		self:TextHidden(true)

		self:TimerHidden(true)

		self:BreakFreeHidden(false)

		CC_Tracker:SetHidden(false)

	elseif displayType=="timer" then
		CC_Tracker_IconFrame_Cooldown:SetHidden(false)
	elseif displayType=="end" then
		CC_Tracker_IconFrame_IconBorderHighlight:SetHidden(false)

		CC_Tracker_IconFrame_Icon:SetTextureCoords(0,1,0,1)
		CC_Tracker_IconFrame_Cooldown:SetHidden(false)
		CC_Tracker_IconFrame_GlobalCooldown:SetHidden(true)
		self:IconHidden(false)

		self:TextHidden(false)

		self:TimerHidden(true)

		self:BreakFreeHidden(true)

		CC_Tracker:SetHidden(false)
	elseif displayType=="endstagger" then
		self:SetupDisplay("end")
		self:IconHidden(true)
	elseif displayType=="proc" then
		CC_Tracker_IconFrame_Icon:SetTextureCoords(0,1,0,1)
		CC_Tracker_IconFrame_IconBorderHighlight:SetHidden(false)

		self:IconHidden(false)

		self:TextHidden(false)

		self:TimerHidden(false)

		self:BreakFreeHidden(true)

		CC_Tracker:SetHidden(false)
	end
end


function CCT:StopDraw(isTextOnly)
	if self.breakFreePlaying and not self.breakFreePlayingDraw then
		-- d("Stop Draw breakfree returned")
		return
	end
	self:VarReset()
	if isTextOnly then self:OnAnimation(CC_Tracker, "endstagger", true)
	else
		self:OnAnimation(CC_Tracker, "end", true)
	end
end


function CCT:StopDrawBreakFree()
	local breakFreeIcon
	local currentCCIcon=CCT_ICON_MISSING
	local currentCC=self.currentCC


	if currentCC~=0 and currentCC~=4 and currentCC~=6 then
		local currentResult=self:CCPriority(currentCC).result
		local currentAbilityId=self:CCPriority(currentCC).abilityId
		local currentColor=self.SV.colors[currentResult]

		currentCCIcon=GetAbilityIcon(currentAbilityId)

		CC_Tracker_BreakFreeFrame_Left_IconBG:SetColor(unpack(currentColor))
		CC_Tracker_BreakFreeFrame_Right_IconBG:SetColor(unpack(currentColor))
		CC_Tracker_BreakFreeFrame_Left_IconBorder:SetColor(unpack(currentColor))
		CC_Tracker_BreakFreeFrame_Left_IconBorderHighlight:SetColor(unpack(currentColor))
		CC_Tracker_BreakFreeFrame_Right_IconBorder:SetColor(unpack(currentColor))
		CC_Tracker_BreakFreeFrame_Right_IconBorderHighlight:SetColor(unpack(currentColor))
	end

	self:VarReset()
	self.breakFreePlaying=true

	if not currentCCIcon:find(CCT_ICON_MISSING) then
		breakFreeIcon=currentCCIcon
	else
		self:VarReset()
		self.breakFreePlaying=true
		self.breakFreePlayingDraw=true
		zo_callLater(function() self.breakFreePlayingDraw=nil self.breakFreePlaying=nil end, 450)
		CC_Tracker:SetHidden(true)
		return
	end

	if breakFreeIcon == CCT_ZOS_DEFAULT_ICON then
		breakFreeIcon=self:GetDefaultIcon(currentResult)
		CC_Tracker_BreakFreeFrame_Left_Icon:SetColor(unpack(self.SV.colors[self.controlTypes[currentCC]]))
		CC_Tracker_BreakFreeFrame_Right_Icon:SetColor(unpack(self.SV.colors[self.controlTypes[currentCC]]))
	else
		CC_Tracker_BreakFreeFrame_Left_Icon:SetColor(1,1,1,1)
		CC_Tracker_BreakFreeFrame_Right_Icon:SetColor(1,1,1,1)
	end
	CC_Tracker_BreakFreeFrame_Left_Icon:SetTexture(breakFreeIcon)
	CC_Tracker_BreakFreeFrame_Left_Icon:SetTextureCoords(0,0.5,0,1)
	CC_Tracker_BreakFreeFrame_Right_Icon:SetTexture(breakFreeIcon)
	CC_Tracker_BreakFreeFrame_Right_Icon:SetTextureCoords(0.5,1,0,1)
	self:OnAnimation(nil, "breakfree", true)
end

function CCT:FindEffectGained(abilityId, sourceUnitId, abilityGraphic)
	local foundValue
	for k, v in pairs (self.effectsGained) do
		if v.abilityId == abilityId and v.sourceUnitId == sourceUnitId and v.abilityGraphic == abilityGraphic then
			foundValue=v
			break
		end
	end
	return foundValue
end

function CCT:CCPriority(ccType)
	local priority
		if ccType == 1 then priority=PriorityOne
		elseif ccType == 2 then priority=PriorityTwo
		elseif ccType == 3 then priority=PriorityThree
		elseif ccType == 4 then priority=PriorityFour
		elseif ccType == 6 then priority=PrioritySix
		end
	return priority
end

function CCT:BreakFreeAnimation()
	if self.currentlyPlaying then self.currentlyPlaying:Stop() end
	if self.immunePlaying then self.immunePlaying:Stop() end

	local leftSide, rightSide=CC_Tracker_BreakFreeFrame_Left, CC_Tracker_BreakFreeFrame_Right

	CC_Tracker:SetScale(self.SV.controlScale)
	leftSide:ClearAnchors()
	leftSide:SetAnchor(RIGHT, CC_Tracker_BreakFreeFrame_Middle, LEFT, 1-20, 0)
	rightSide:ClearAnchors()
	rightSide:SetAnchor(LEFT, CC_Tracker_BreakFreeFrame_Middle, RIGHT, -1+20, 0)

	leftSide:SetAlpha(1)
	rightSide:SetAlpha(1)

	local timeline = ANIMATION_MANAGER:CreateTimeline()

	local animDuration=300
	local animDelay=150

	self:InsertAnimationType(timeline, ANIMATION_SCALE, leftSide, animDelay, 0, ZO_EaseOutCubic, 1.0, 2)
	self:InsertAnimationType(timeline, ANIMATION_SCALE, rightSide, animDelay, 0, ZO_EaseOutCubic, 1.0, 2)

	self:InsertAnimationType(timeline, ANIMATION_SCALE, leftSide, animDuration, animDelay, ZO_EaseOutCubic, 1.8, 0.1)
	self:InsertAnimationType(timeline, ANIMATION_SCALE, rightSide, animDuration, animDelay, ZO_EaseOutCubic, 1.8, 0.1)

	self:InsertAnimationType(timeline, ANIMATION_ALPHA, leftSide, animDuration, animDelay, ZO_EaseInOutQuintic, 1, 0)
	self:InsertAnimationType(timeline, ANIMATION_ALPHA, rightSide, animDuration, animDelay, ZO_EaseInOutQuintic, 1, 0)

	self:InsertAnimationType(timeline, ANIMATION_TRANSLATE, leftSide, animDuration, animDelay, ZO_EaseOutCubic, 0, 0, -550, 0)
	self:InsertAnimationType(timeline, ANIMATION_TRANSLATE, rightSide, animDuration, animDelay, ZO_EaseOutCubic, 0, 0, 550, 0)

	timeline:SetHandler('OnStop', function()
		leftSide:ClearAnchors()
		leftSide:SetAnchor(LEFT, CC_Tracker_BreakFreeFrame, LEFT, 0, 0)
		leftSide:SetScale(1)
		rightSide:ClearAnchors()
		rightSide:SetAnchor(RIGHT, CC_Tracker_BreakFreeFrame, RIGHT, 0, 0)
		rightSide:SetScale(1)
		self.breakFreePlaying=nil
	end)

	timeline:PlayFromStart()

	return timeline
end

function CCT:StartAnimation(control, animType, test)
	if self.currentlyPlaying then self.currentlyPlaying:Stop() end
	if self.immunePlaying then self.immunePlaying:Stop() end

	local _, point, relativeTo, relativePoint, offsetX, offsetY = control:GetAnchor()
	control:ClearAnchors()
	control:SetAnchor(point, relativeTo, relativePoint, offsetX, offsetY)

    local timeline = ANIMATION_MANAGER:CreateTimeline()

	if animType=="proc" then
		if control:GetAlpha()==0 then
			self:InsertAnimationType(timeline, ANIMATION_ALPHA, control, 100, 0, ZO_EaseInQuadratic, 0, 1)
		else
			control:SetAlpha(1)
		end
		self:InsertAnimationType(timeline, ANIMATION_SCALE, control, 100,   0, ZO_EaseInQuadratic,   1, 2.2, CCT_SET_SCALE_FROM_SV)
		self:InsertAnimationType(timeline, ANIMATION_SCALE, control, 200, 200, ZO_EaseOutQuadratic, 2.2,   1, CCT_SET_SCALE_FROM_SV)

	elseif animType=="end" or animType=="endstagger" then
		local currentAlpha=control:GetAlpha()
		self:InsertAnimationType(timeline, ANIMATION_ALPHA, control, 150,   0, ZO_EaseOutQuadratic,  currentAlpha,   0)

	elseif animType=="silence" then
		if CC_Tracker:GetAlpha()<1 then
			self:InsertAnimationType(timeline, ANIMATION_ALPHA, CC_Tracker, 100,   0, ZO_EaseInQuadratic,	 0,   1)
			self:InsertAnimationType(timeline, ANIMATION_SCALE, control, 100,   0, ZO_EaseInQuadratic,    1, 2.5, CCT_SET_SCALE_FROM_SV)
			self:InsertAnimationType(timeline, ANIMATION_SCALE, control, 200, 200, ZO_EaseOutQuadratic, 2.5,   1, CCT_SET_SCALE_FROM_SV)
		else
			CC_Tracker:SetAlpha(1)
			self:InsertAnimationType(timeline, ANIMATION_SCALE, control, 250,   0, ZO_EaseInQuadratic,    1, 1.5, CCT_SET_SCALE_FROM_SV)
			self:InsertAnimationType(timeline, ANIMATION_SCALE, control, 250, 250, ZO_EaseOutQuadratic, 1.5,   1, CCT_SET_SCALE_FROM_SV)
		end

	elseif animType=="stagger" then
		self:InsertAnimationType(timeline, ANIMATION_ALPHA, control, 50,  0, ZO_EaseInQuadratic,    0,	 1)
		self:InsertAnimationType(timeline, ANIMATION_SCALE, control, 50,  0, ZO_EaseInQuadratic,    1, 1.5, CCT_SET_SCALE_FROM_SV)
		self:InsertAnimationType(timeline, ANIMATION_SCALE, control, 50, 100, ZO_EaseOutQuadratic, 1.5,	  1, CCT_SET_SCALE_FROM_SV)

	elseif animType=="immune" then
		control:SetScale(self.SV.controlScale*1)
		self:InsertAnimationType(timeline, ANIMATION_ALPHA, control, 10, 0, ZO_EaseInQuadratic, 0, 0.6)
		self:InsertAnimationType(timeline, ANIMATION_ALPHA, control, self.SV.immuneDisplayTime, 100, ZO_EaseInOutQuadratic, 0.6, 0)
	end

    timeline:SetHandler('OnStop', function()
		control:SetScale(self.SV.controlScale)
	control:ClearAnchors()
		control:SetAnchor(point, relativeTo, relativePoint, offsetX, offsetY)
		self.currentlyPlaying=nil
		self.immunePlaying=nil
	end)

    timeline:PlayFromStart()
	return timeline
end

function CCT:InsertAnimationType(animHandler, animType, control, animDuration, animDelay, animEasing, ...)
	if not animHandler then return end
	if animType==ANIMATION_SCALE then
		local animationScale, startScale, endScale, scaleFromSV = animHandler:InsertAnimation(ANIMATION_SCALE, control, animDelay), ...
		if scaleFromSV then
			startScale=startScale*self.SV.controlScale
			endScale=endScale*self.SV.controlScale
		end
		animationScale:SetScaleValues(startScale, endScale)
		animationScale:SetDuration(animDuration)
		animationScale:SetEasingFunction(animEasing)
	elseif animType==ANIMATION_ALPHA then
		local animationAlpha, startAlpha, endAlpha = animHandler:InsertAnimation(ANIMATION_ALPHA, control, animDelay), ...
		animationAlpha:SetAlphaValues(startAlpha, endAlpha)
		animationAlpha:SetDuration(animDuration)
		animationAlpha:SetEasingFunction(animEasing)
	elseif animType==ANIMATION_TRANSLATE then
		local animationTranslate, startX, startY, offsetX, offsetY = animHandler:InsertAnimation(ANIMATION_TRANSLATE, control, animDelay), ...
		animationTranslate:SetTranslateOffsets(startX, startY, offsetX, offsetY)
		animationTranslate:SetDuration(animDuration)
		animationTranslate:SetEasingFunction(animEasing)
	end
end

function CCT:IsInPVPZone()
	return IsUnitPvPFlagged('player')
end

function CCT:OnOff()
	if self.SV.enabled and not (self.SV.enabledOnlyInCyro and not CCT:IsInPVPZone()) then
		if not self.addonEnabled then
			self.addonEnabled=true
			EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, self.Activated)
			EVENT_MANAGER:RegisterForEvent(self.name, EVENT_COMBAT_EVENT, function(...) self:OnCombat(...) end)
			EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_STUNNED_STATE_CHANGED, function(...) self:OnStunnedState(...) end)
			EVENT_MANAGER:RegisterForEvent(self.name, EVENT_UNIT_DEATH_STATE_CHANGED, function(eventCode, unitTag, isDead) if isDead then self:FullReset() end end)
			EVENT_MANAGER:AddFilterForEvent(self.name, EVENT_UNIT_DEATH_STATE_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
			self:GeneratePriorityTable()
			self.Activated()
		end
	else
		if self.addonEnabled then
			self.addonEnabled=false
			EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_PLAYER_ACTIVATED)
			EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_COMBAT_EVENT)
			EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_PLAYER_STUNNED_STATE_CHANGED)
			EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_UNIT_DEATH_STATE_CHANGED)
			CC_Tracker:SetHidden(true)
		end
	end
end

function CCT:InitControls()
	CC_Tracker:ClearAnchors()
	CC_Tracker:SetAnchor(CENTER, GuiRoot, CENTER, self.SV.offsetX, self.SV.offsetY)
	CC_Tracker:SetScale(self.SV.controlScale)
	CC_Tracker_TextFrame_Label:SetFont(CCT_ICON_FONT)
	if self.SV.unlocked then
		CC_Tracker_TextFrame_Label:SetText("Unlocked")
	else
		CC_Tracker_TextFrame_Label:SetText("")
	end
	self:TextHidden(false)

	CC_Tracker_IconFrame_IconBorder:SetTexture(CCT_ICONBORDER)
	CC_Tracker_IconFrame_IconBorderHighlight:SetTexture(CCT_ICONBORDER)
	CC_Tracker_IconFrame_IconBorder:SetHidden(false)
	CC_Tracker_IconFrame_IconBorderHighlight:SetHidden(false)


	CC_Tracker_IconFrame_Cooldown:ResetCooldown()
	CC_Tracker_IconFrame_Cooldown:SetHidden(true)
	CC_Tracker_IconFrame_GlobalCooldown:ResetCooldown()
	CC_Tracker_IconFrame_GlobalCooldown:SetHidden(true)
	CC_Tracker_IconFrame_Icon:SetTexture(CCT_DEFAULT_IMMUNE_ICON)
	CC_Tracker_IconFrame_Icon:SetTextureCoords(0.2,0.8,0.2,0.8)
	CC_Tracker_IconFrame_IconBG:SetColor(1,1,1)
	CC_Tracker_IconFrame_Icon:SetColor(1,1,1)
	self:IconHidden(false)

	CC_Tracker_IconFrame_IconBorder:SetColor(1,1,1)
	CC_Tracker_IconFrame_IconBorderHighlight:SetColor(1,1,1)
	CC_Tracker_TextFrame_Label:SetColor(1,1,1)

	CC_Tracker:SetMouseEnabled(self.SV.unlocked)
	CC_Tracker:SetMovable(self.SV.unlocked)
	CC_Tracker:SetAlpha(1)


	CC_Tracker_BreakFreeFrame_Left_IconBorder:SetTexture(CCT_ICONBORDER)
	CC_Tracker_BreakFreeFrame_Left_IconBorderHighlight:SetTexture(CCT_ICONBORDER)
	CC_Tracker_BreakFreeFrame_Left_IconBorder:SetTextureCoords(0,0.5,0,1)
	CC_Tracker_BreakFreeFrame_Left_IconBorderHighlight:SetTextureCoords(0,0.5,0,1)

	CC_Tracker_BreakFreeFrame_Right_IconBorder:SetTexture(CCT_ICONBORDER)
	CC_Tracker_BreakFreeFrame_Right_IconBorderHighlight:SetTexture(CCT_ICONBORDER)
	CC_Tracker_BreakFreeFrame_Right_IconBorder:SetTextureCoords(0.5,1,0,1)
	CC_Tracker_BreakFreeFrame_Right_IconBorderHighlight:SetTextureCoords(0.5,1,0,1)

	CC_Tracker_BreakFreeFrame_Left_Icon:SetTexture(CCT_DEFAULT_DISORIENT_ICON)
	CC_Tracker_BreakFreeFrame_Left_Icon:SetTextureCoords(0,0.5,0,1)
	CC_Tracker_BreakFreeFrame_Right_Icon:SetTexture(CCT_DEFAULT_DISORIENT_ICON)
	CC_Tracker_BreakFreeFrame_Right_Icon:SetTextureCoords(0.5,1,0,1)

	self:BreakFreeHidden(true)

	self:TimerHidden(not self.SV.unlocked)
	CC_Tracker_Timer_Label:SetText("69")
	CC_Tracker_Timer_Label:SetColor(1,1,1,1)
	CC_Tracker:SetHidden(not self.SV.unlocked)
end

function CCT:FullReset()
	self:VarReset()
	if self.currentlyPlaying then self.currentlyPlaying:Stop() end

	if self.breakFreePlaying then
		if not self.breakFreePlayingDraw then
			self.breakFreePlaying:Stop() end
		else
			self.breakFreePlayingDraw=nil
			self.breakFreePlaying=nil
		end
	if self.immunePlaying then self.immunePlaying:Stop() end
	self:InitControls()
end


function CCT:VarReset()
	self.effectsGained={}
	self.disorientsQueue={}
	self.fearsQueue={}
	self.currentCC=0
	PriorityOne = {endTime=0, abilityId=0, hitValue=0, result=0, abilityName=""}
	PriorityTwo = {endTime=0, abilityId=0, hitValue=0, result=0, abilityName=""}
	PriorityThree = {endTime=0, abilityId=0, hitValue=0, result=0, abilityName=""}
	PriorityFour = {endTime=0, abilityId=0, hitValue=0, result=0, abilityName=""}
	PrioritySix = {endTime=0, abilityId=0, hitValue=0, result=0, abilityName=""}
	self.Timer=0
end

function CCT:InitializeAddonMenu()
	local panelData = {
		type = "panel",
		name = "Miat's CC Tracker",
		displayName = "Miat's CC Tracker",
		author = "Dorrino",
		version = self.textVersion,
		slashCommand = "/cc_tracker",
		registerForRefresh = true,
		registerForDefaults = true,
		resetFunc = function()
			self.SV.offsetX=0 self.SV.offsetY=0 self:FullReset()
		end
	}

	local optionsPanel = self.LAM2:RegisterAddonPanel("Crowdcontrol_Tracker", panelData)

	local optionsData = {}


	table.insert(optionsData, {
		type = "header",
		name = "Position lock/unlock",
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Turn OFF when satisfied with icon's position",
		tooltip = "ON - icon can me moved on the screen by left clicking and dragging, OFF - icon is locked in place and can not be moved",
		default = self.defaults.unlocked,
		disabled = function() return not self.SV.enabled end,
		getFunc = function() return self.SV.unlocked end,
		setFunc = function(newValue) self.SV.unlocked = newValue if newValue then self:SetupDisplay("draw") end self:InitControls() end,
	})
	table.insert(optionsData, {
		type = "header",
		name = "Crowdcontrol Tracker options",
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "ADDON ENABLED",
		tooltip = "ON - enabled, OFF - disabled",
		default = self.defaults.enabled,
		getFunc = function() return self.SV.enabled end,
		setFunc = function(newValue) self.SV.enabled = newValue self:OnOff() end,
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Enabled only in PVP",
		tooltip = "ON - enabled in PVP only, OFF - enabled everywhere",
		default = self.defaults.enabledOnlyInCyro,
		disabled = function() return not self.SV.enabled end,
		getFunc = function() return self.SV.enabledOnlyInCyro end,
		setFunc = function(newValue) self.SV.enabledOnlyInCyro = newValue self:OnOff() end,
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Same settings for all characters",
		tooltip = "ON - Each character has the same set of settings, OFF - Separate settings for each character",
		default = self.accountWideDefaults.accountWide,
		disabled = function() return not self.SV.enabled end,
		getFunc = function() return self.DS.accountWide end,
		setFunc = function(newValue) self.DS.accountWide = newValue ReloadUI() end,
		warning = "Triggering this options with reload the UI",
	})
	table.insert(optionsData, {
		type = "header",
		name = "Display options",
	})
	table.insert(optionsData, {
		type = "dropdown",
		name = "Choose display style:",
		tooltip = '"Icon" to show only the icon, "text" to show just the text and "Both icon and text" to show both icon and text',
		choices = {"Both icon and text", "Icon only", "Text only"},
		getFunc = function()
			if self.SV.showOptions=="all" then
				return "Both icon and text"
			elseif self.SV.showOptions=="icon" then
				return "Icon only"
			elseif self.SV.showOptions=="text" then
				return "Text only"
			end
		end,
		setFunc = function(newValue)
			if newValue=="Both icon and text" then
				self.SV.showOptions="all"
			elseif newValue=="Icon only" then
				self.SV.showOptions="icon"
			elseif newValue=="Text only" then
				self.SV.showOptions="text"
			end
				self:InitControls()
		end,
			default = "Both icon and text",
			disabled = function() return not self.SV.enabled end,
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Use ability name as crowd control text",
		tooltip = 'ON - ability name that produced the crowd control is shown, OFF - Crowd control type ("STUNNED", "FEARED" etc) text is shown',
		default = self.defaults.useAbilityName,
		disabled = function() return (not self.SV.enabled) or (self.SV.showOptions=="icon") end,
		getFunc = function() return self.SV.useAbilityName end,
		setFunc = function(newValue) self.SV.useAbilityName = newValue self:InitControls() end,
	})
	table.insert(optionsData, {
		type = "slider",
		name = "Set icon and text scale (%)",
		tooltip = "Icon and text scale goes from 20% to 200% of original scale",
		default = tonumber(string.format("%.0f", 100*self.defaults.controlScale)),
		disabled = function() return not self.SV.enabled end,
		min	= 20,
	max	= 200,
	step	= 1,
		getFunc = function() return tonumber(string.format("%.0f", 100*self.SV.controlScale)) end,
		setFunc = function(newValue) self.SV.controlScale = newValue/100 self:InitControls() end,
	})
	table.insert(optionsData, {
		type = "header",
		name = "Misc options",
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Play sound on crowd control",
		tooltip = "ON - play sound, OFF - do not play sound",
		default = self.defaults.playSound,
		disabled = function() return not self.SV.enabled end,
		getFunc = function() return self.SV.playSound end,
		setFunc = function(newValue) self.SV.playSound = newValue
			self:InitControls()
		end,
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Show staggered crowd control (text only)",
		tooltip = "ON - show staggered crowd control, OFF - do not show staggered crowd control",
		default = self.defaults.showStaggered,
		disabled = function() return not self.SV.enabled end,
		getFunc = function() return self.SV.showStaggered end,
		setFunc = function(newValue) self.SV.showStaggered = newValue
			self:InitControls()
		end,
	})
	table.insert(optionsData, {
		type = "header",
		name = "Immuned state options",
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Show immuned",
		tooltip = "ON - show the icon for incoming abilities you had been immuned to , OFF - don't not show immune icon",
		default = self.defaults.showImmune,
		disabled = function() return (not self.SV.enabled) end,
		getFunc = function() return self.SV.showImmune end,
		setFunc = function(newValue) self.SV.showImmune = newValue
			self:InitControls()
		end,
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Show immuned only in Cyrodiil",
		tooltip = "ON - show immuned crowd controls only in Cyrodiil , OFF - show immuned everywhere",
		default = self.defaults.showImmuneOnlyInCyro,
		disabled = function() return (not self.SV.enabled) or (not self.SV.showImmune) end,
		getFunc = function() return self.SV.showImmuneOnlyInCyro end,
		setFunc = function(newValue) self.SV.showImmuneOnlyInCyro = newValue
			self:InitControls()
		end,
	})
	table.insert(optionsData, {
		type = "slider",
		name = "Set immuned display time (ms)",
		tooltip = "Set display time for immuned events. 750ms is the recommended default value.",
		default = self.defaults.immuneDisplayTime,
		disabled = function() return (not self.SV.enabled) or (not self.SV.showImmune) end,
		min	= 100,
	max	= 1500,
	step	= 1,
		getFunc = function() return self.SV.immuneDisplayTime end,
		setFunc = function(newValue) self.SV.immuneDisplayTime = newValue self:InitControls() end,
	})
	table.insert(optionsData, {
		type = "header",
		name = "Colors options",
	})
	table.insert(optionsData, {
		type = "colorpicker",
		name = "Pick color for STUNNED state",
		tooltip = "Pick color of CC text, timer and icon border for STUNNED crowd control state",
	default = ZO_ColorDef:New(unpack(self.defaults.colors[ACTION_RESULT_STUNNED])),
		disabled = function() return not self.SV.enabled end,
	getFunc = function() return unpack(self.SV.colors[ACTION_RESULT_STUNNED]) end,
		setFunc = function(r,g,b,a)
	    self.SV.colors[ACTION_RESULT_STUNNED] = {r,g,b,a}
			self:InitControls()
	end,
	})
	table.insert(optionsData, {
		type = "colorpicker",
		name = "Pick color for DISORIENTED state",
		tooltip = "Pick color of CC text, timer and icon border for DISORIENTED crowd control state",
	default = ZO_ColorDef:New(unpack(self.defaults.colors[ACTION_RESULT_DISORIENTED])),
		disabled = function() return not self.SV.enabled end,
	getFunc = function() return unpack(self.SV.colors[ACTION_RESULT_DISORIENTED]) end,
		setFunc = function(r,g,b,a)
	    self.SV.colors[ACTION_RESULT_DISORIENTED] = {r,g,b,a}
			self:InitControls()
	end,
	})
	table.insert(optionsData, {
		type = "colorpicker",
		name = "Pick color for SILENCED state",
		tooltip = "Pick color of CC text and icon border for SILENCED crowd control state",
	default = ZO_ColorDef:New(unpack(self.defaults.colors[ACTION_RESULT_SILENCED])),
		disabled = function() return not self.SV.enabled end,
	getFunc = function() return unpack(self.SV.colors[ACTION_RESULT_SILENCED]) end,
		setFunc = function(r,g,b,a)
	    self.SV.colors[ACTION_RESULT_SILENCED] = {r,g,b,a}
			self:InitControls()
	end,
	})
	table.insert(optionsData, {
		type = "colorpicker",
		name = "Pick color for FEARED state",
		tooltip = "Pick color of CC text, timer and icon border for FEARED crowd control",
	default = ZO_ColorDef:New(unpack(self.defaults.colors[ACTION_RESULT_FEARED])),
		disabled = function() return not self.SV.enabled end,
	getFunc = function() return unpack(self.SV.colors[ACTION_RESULT_FEARED]) end,
		setFunc = function(r,g,b,a)
	    self.SV.colors[ACTION_RESULT_FEARED] = {r,g,b,a}
			self:InitControls()
	end,
	})
	table.insert(optionsData, {
		type = "colorpicker",
		name = "Pick color for STAGGERED state",
		tooltip = "Pick color of CC text for STAGGERED crowd control",
	default = ZO_ColorDef:New(unpack(self.defaults.colors[ACTION_RESULT_STAGGERED])),
		disabled = function() return not self.SV.enabled end,
	getFunc = function() return unpack(self.SV.colors[ACTION_RESULT_STAGGERED]) end,
		setFunc = function(r,g,b,a)
	    self.SV.colors[ACTION_RESULT_STAGGERED] = {r,g,b,a}
			self:InitControls()
	end,
	})
	table.insert(optionsData, {
		type = "colorpicker",
		name = "Pick color for IMMUNE state",
		tooltip = "Pick color of CC text for IMMUNE crowd control",
	default = ZO_ColorDef:New(unpack(self.defaults.colors[ACTION_RESULT_IMMUNE])),
		disabled = function() return not self.SV.enabled end,
	getFunc = function() return unpack(self.SV.colors[ACTION_RESULT_IMMUNE]) end,
		setFunc = function(r,g,b,a)
	    self.SV.colors[ACTION_RESULT_IMMUNE] = {r,g,b,a}
	    self.SV.colors[ACTION_RESULT_DODGED] = {r,g,b,a}
	    self.SV.colors[ACTION_RESULT_BLOCKED] = {r,g,b,a}
	    self.SV.colors[ACTION_RESULT_BLOCKED_DAMAGE] = {r,g,b,a}
			self:InitControls()
	end,
	})
	table.insert(optionsData, {
		type = "header",
		name = "Beta features",
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Show Area Effects",
		tooltip = "ON - show the icon when damaged by specific AOE spells , OFF - don't not show AOE icon",
		default = self.defaults.showAoe,
		disabled = function() return (not self.SV.enabled) end,
		getFunc = function() return self.SV.showAoe end,
		setFunc = function(newValue) self.SV.showAoe = newValue
			self:InitControls()
		end,
	})
	table.insert(optionsData, {
		type = "colorpicker",
		name = "Pick color for AREA DAMAGE EFFECT state",
		tooltip = "Pick color of CC text and icon border for AREA DAMAGE EFFECT crowd control state",
	default = ZO_ColorDef:New(unpack(self.defaults.colors[ACTION_RESULT_AREA_EFFECT])),
		disabled = function() return not self.SV.enabled end,
	getFunc = function() return unpack(self.SV.colors[ACTION_RESULT_AREA_EFFECT]) end,
		setFunc = function(r,g,b,a)
	    self.SV.colors[ACTION_RESULT_AREA_EFFECT] = {r,g,b,a}
			self:InitControls()
	end,
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Show Global Cooldown",
		tooltip = "ON - show the cooldown animation if cc-ed while on global cooldown (Cyrodiil only) , OFF - don't not show global cooldown animation",
		default = self.defaults.showGCD,
		disabled = function() return (not self.SV.enabled) end,
		getFunc = function() return self.SV.showGCD end,
		setFunc = function(newValue) self.SV.showGCD = newValue
			self:InitControls()
		end,
	})
	self.LAM2:RegisterOptionControls("Crowdcontrol_Tracker", optionsData)
end

function CCT.Activated()
	CCT:OnOff()
	if CCT.SV.enabled then
		CCT.playerName=GetRawUnitName('player')
		CCT.currentlyPlaying=nil
		CCT.breakFreePlaying=nil
		CCT.immunePlaying=nil
		CCT:FullReset()
	end
end

function CCT.OnLoad(eventCode, addonName)
	if addonName~=CCT.name then return end
	EVENT_MANAGER:UnregisterForEvent(CCT.name, EVENT_ADD_ON_LOADED, CCT.OnLoad)
	CCT.DS = ZO_SavedVars:NewAccountWide("CrowdControlTrackerSettings", 999, "AccountWide", CCT.accountWideDefaults)
	--thanks Baertram!
	if CCT.DS.accountWide then
		CCT.SV = ZO_SavedVars:NewAccountWide("CrowdControlTrackerSettings", CCT.version, "Settings", CCT.defaults)
	else
		CCT.SV = ZO_SavedVars:New("CrowdControlTrackerSettings", CCT.version, "Settings", CCT.defaults)
	end
	CCT:InitializeAddonMenu()
	EVENT_MANAGER:RegisterForEvent(CCT.name, EVENT_PLAYER_ACTIVATED, CCT.Activated)
end

EVENT_MANAGER:RegisterForEvent(CCT.name, EVENT_ADD_ON_LOADED, CCT.OnLoad)
