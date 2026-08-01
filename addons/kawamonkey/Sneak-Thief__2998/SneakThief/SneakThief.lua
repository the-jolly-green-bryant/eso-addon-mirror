local lightFingersBonuses = { 10, 20, 35, 50 }

local function OnReticleTargetChanged()
	-- don't change reticle if Bandit UI is active and player is in combat
	if BUI and IsUnitInCombat("player") then return end

	if IsUnitInvulnerableGuard("reticleover") then
		RETICLE.reticleTexture:SetColor(1, 0.647, 0)
		RETICLE.stealthIcon.stealthEyeTexture:SetColor(1, 0.647, 0)
		UNIT_FRAMES.staticFrames.reticleover.nameLabel:SetColor(1, 0.647, 0)
	else
		RETICLE.reticleTexture:SetColor(ZO_WHITE:UnpackRGBA())
		RETICLE.stealthIcon.stealthEyeTexture:SetColor(ZO_WHITE:UnpackRGBA())
	end
end

local function GetPreviousAttempts(difficulty, percentChance, isInBonus)
	-- remove Khajiit's Cutpurse skill bonus
	if GetUnitRaceId("player") == 9 and GetUnitLevel("player") >= 5 then
		percentChance = percentChance - 5
	end

	-- get Light Fingers rank
	lightFingersPurchased, _, lightFingersRank = select(6, GetSkillAbilityInfo(SKILL_TYPE_WORLD, 2, 2))

	-- remove Light Fingers bonus
	if lightFingersPurchased then
		percentChance = percentChance - lightFingersBonuses[lightFingersRank]
	end

	-- compensate for zeroing
	if percentChance == 0 then
		-- medium chance can be 0% in edge cases with 4th and 5th attempts in Vvardenfell
		if difficulty == PICKPOCKET_DIFFICULTY_MEDIUM then
			percentChance = 10
		elseif difficulty == PICKPOCKET_DIFFICULTY_HARD then
			percentChance = -10
		end
	-- remove timed bonus
	elseif isInBonus then
		if difficulty == PICKPOCKET_DIFFICULTY_EASY then
			percentChance = percentChance - 25
		elseif difficulty == PICKPOCKET_DIFFICULTY_MEDIUM then
			-- bonus chance can be less than 20% in edge cases with 4th and 5th attempts in Vvardenfell
			if percentChance > 20 then
				percentChance = percentChance - 20
			else
				percentChance = 10
			end
		elseif difficulty == PICKPOCKET_DIFFICULTY_HARD then
			percentChance = percentChance - 20
		end
	end

	-- calculate previous attempt count
	if difficulty == PICKPOCKET_DIFFICULTY_EASY then
		return (50 - percentChance) / 5
	elseif difficulty == PICKPOCKET_DIFFICULTY_MEDIUM then
		return (30 - percentChance) / 10
	elseif difficulty == PICKPOCKET_DIFFICULTY_HARD then
		return (20 - percentChance) / 15
	end
end

local function TryHandlingInteraction(self, interactionPossible)
	if not interactionPossible then
		return
	end

    local action, _, _, isOwned, additionalInteractInfo, _, _, isCriminalInteract = GetGameCameraInteractableActionInfo()
	local isPickpocketing = additionalInteractInfo == ADDITIONAL_INTERACT_INFO_PICKPOCKET_CHANCE
	local isInBonus, _, percentChance, difficulty, isEmpty, prospectiveResult = GetGameCameraPickpocketingBonusInfo()
	local stealthState = GetUnitStealthState("player")

	-- only mark criminal action as red if seen
	if stealthState ~= STEALTH_STATE_NONE and stealthState ~= STEALTH_STATE_DETECTED and stealthState ~= STEALTH_STATE_HIDING then
		if isOwned or isCriminalInteract then
			self.interactKeybindButton:SetNormalTextColor(ZO_NORMAL_TEXT)
		elseif isPickpocketing then
			self.interactKeybindButton:SetNormalTextColor(ZO_NORMAL_TEXT)
		end
	end

	-- display NPC difficulty
	if isPickpocketing then
		local difficultyType = GetString("SI_PICKPOCKETDIFFICULTYTYPE", difficulty)
		local successChance = zo_strformat(SI_PICKPOCKET_SUCCESS_CHANCE, self.percentChance)
		local attemptNumber = 1 + GetPreviousAttempts(difficulty, percentChance, isInBonus)
		self.additionalInfo:SetText(zo_strformat("<<1>>, #<<2>>, <<3>>", successChance, attemptNumber, difficultyType))
	end

	-- mark empty NPCs as empty rather than anything else
	if isEmpty and isPickpocketing and prospectiveResult ~= PROSPECTIVE_PICKPOCKET_RESULT_CAN_ATTEMPT then
		self.interactKeybindButton:SetText(zo_strformat(SI_GAME_CAMERA_TARGET_ADDITIONAL_INFO, action, GetString(SI_JUSTICE_PICKPOCKET_TARGET_EMPTY)))
	end
end

-- fix for suspicious NPCs being reported as being empty
local function SuspiciousResultFix()
	local handlers = ZO_AlertText_GetHandlers()
	local orgEventClientInteractResultHandler = handlers[EVENT_CLIENT_INTERACT_RESULT]
	handlers[EVENT_CLIENT_INTERACT_RESULT] = function(result, interactTargetName)
		if result == 11 then
			local isEmpty = select(5, GetGameCameraPickpocketingBonusInfo())

			-- use correct result ID
			if not isEmpty then
				result = 12
			end
		end

		return orgEventClientInteractResultHandler(result, interactTargetName)
	end
end

local function OnAddOnLoaded(eventCode, addOnName)
    if addOnName == "SneakThief" then
		-- mark guards
		EVENT_MANAGER:RegisterForEvent("SneakThief", EVENT_RETICLE_TARGET_CHANGED, OnReticleTargetChanged)
	end
end

EVENT_MANAGER:RegisterForEvent("SneakThief", EVENT_ADD_ON_LOADED, OnAddOnLoaded)

-- hook onto reticle interaction
ZO_PostHook(RETICLE, "TryHandlingInteraction", TryHandlingInteraction)

SuspiciousResultFix()