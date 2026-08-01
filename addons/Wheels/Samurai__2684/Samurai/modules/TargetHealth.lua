SAMURAI = SAMURAI or { }
local sam = SAMURAI

local white = "FFFFFF"
local red = "FF0000"
local floor = math.floor
local format = string.format

local reactions = {
	[UNIT_REACTION_HOSTILE] = true,
	[UNIT_REACTION_NEUTRAL] = true,
}

local function healthHandler(event, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
	if not sam.savedVars.modules.targetHealth.show then return end
	if powerValue == 0 then
		sam.UI.targetHealth:SetHidden(true)
		return
	end
	local value = floor((powerValue / powerMax) * 100 + 0.5)
	local color = value > 25 and white or red
	sam.UI.targetHealthText:SetText(format("|c%s%d%%|r", color, value))
	sam.UI.targetHealth:SetHidden(false)
end

local function targetLostHandler(event)
	if GetUnitName('reticleover') == "" then
		sam.EM:UnregisterForEvent(sam.name.."TargetModuleHealth", EVENT_POWER_UPDATE)
		sam.UI.targetHealth:SetHidden(true)
	else
		if not reactions[GetUnitReaction('reticleover')] then
			sam.EM:UnregisterForEvent(sam.name.."TargetModuleHealth", EVENT_POWER_UPDATE)
			sam.UI.targetHealth:SetHidden(true)
			return
		end
		sam.EM:RegisterForEvent(sam.name.."TargetModuleHealth", EVENT_POWER_UPDATE, healthHandler)
		sam.EM:AddFilterForEvent(sam.name.."TargetModuleHealth", EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG, "reticleover", REGISTER_FILTER_POWER_TYPE, POWERTYPE_HEALTH)
	end
end

function sam.setupTargetHealthModule()
	sam.UI.targetHealth = TargetModuleHealth
	sam.UI.targetHealthText = TargetModuleHealth_Text

	sam.EM:RegisterForEvent(sam.name.."TargetModuleHealth", EVENT_RETICLE_TARGET_CHANGED, targetLostHandler)
end

