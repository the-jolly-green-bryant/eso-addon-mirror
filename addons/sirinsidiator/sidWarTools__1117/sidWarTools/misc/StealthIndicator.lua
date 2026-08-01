local RegisterForCombatResult = sidWarTools.RegisterForCombatResult
local function RefreshStealthIndicatorColors() end

local function Initialize(saveData)
	if(saveData.stealthIndicator) then
		local container = ZO_ReticleContainer

		local function CreateStateIndicator(name, angle)
			local indicator = container:CreateControl(name, CT_TEXTURE)
			indicator:SetTexture("sidWarTools/images/StealthIndicator.dds")
			indicator:SetDimensions(128, 128)
			indicator:SetTextureRotation(angle)
			indicator:SetAnchor(CENTER)
			return indicator
		end

		local hiddenIndicator = CreateStateIndicator("$(parent)HiddenIndicator", math.pi / 2)
		local stealthedIndicator = CreateStateIndicator("$(parent)StealthedIndicator", -math.pi / 2)

		RefreshStealthIndicatorColors = function()
			hiddenIndicator:SetColor(unpack(saveData.stealthIndicatorHiddenColor))
			hiddenIndicator:SetAlpha(saveData.stealthIndicatorAlpha / 100)
			stealthedIndicator:SetColor(unpack(saveData.stealthIndicatorStealthedColor))
			stealthedIndicator:SetAlpha(saveData.stealthIndicatorAlpha / 100)
		end
		RefreshStealthIndicatorColors()

		local isHidden, isStealthed, hasVanished = false, false, false
		local function UpdateHiddenIndicator()
			hiddenIndicator:SetHidden(not isHidden)
		end
		local function UpdateStealthedIndicator()
			stealthedIndicator:SetHidden(not isStealthed and not hasVanished)
		end
		UpdateHiddenIndicator()
		UpdateStealthedIndicator()

		local characterName = GetRawUnitName("player")
		local HIDDEN_ABILITY = GetAbilityName(20309)
		local CLOAK_ABILITIES = {
			[GetAbilityName(25375)] = true, -- Shadow Cloak
			[GetAbilityName(25377)] = true, -- Dark Cloak
			[GetAbilityName(25380)] = true, -- Shadowy Disguise
		}
		local VANISH_ABILITY = GetAbilityName(24687)
		RegisterForCombatResult(ACTION_RESULT_EFFECT_GAINED, function(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log)
			if(targetName ~= characterName) then return end
			if(not isHidden and abilityName == HIDDEN_ABILITY) then
				isHidden = true
				UpdateHiddenIndicator()
			end
			if(not hasVanished and abilityName == VANISH_ABILITY) then
				hasVanished = true
				UpdateStealthedIndicator()
			end
		end)
		RegisterForCombatResult(ACTION_RESULT_EFFECT_GAINED_DURATION, function(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log)
			if(targetName ~= characterName) then return end
			if(not isStealthed and CLOAK_ABILITIES[abilityName]) then
				isStealthed = true
				UpdateStealthedIndicator()
			end
		end)
		RegisterForCombatResult(ACTION_RESULT_EFFECT_FADED, function(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log)
			if(targetName ~= characterName) then return end
			if(isHidden and abilityName == HIDDEN_ABILITY) then
				isHidden = false
				UpdateHiddenIndicator()
			elseif(isStealthed and CLOAK_ABILITIES[abilityName]) then
				isStealthed = false
				UpdateStealthedIndicator()
			elseif(hasVanished and abilityName == VANISH_ABILITY) then
				hasVanished = false
				UpdateStealthedIndicator()
			end
		end)
	end
end

sidWarTools.RefreshStealthIndicatorColors = function() RefreshStealthIndicatorColors() end
sidWarTools.InitializeStealthIndicator = Initialize
