local Addon = 
{
	Name = "ImmersiveOverlays",
	NameSpaced = "Immersive Overlays",
	Author = "Anumaril",
	Version = "0.0.1",
	VariableVersion = "1",
}

-- LEGEND (as it works in KCD)
-- Blood UI Overlay: appears starting at 50% health, increasing opacity up to 100%
-- Blood red tint: appears starting 10% health, increasing opacity up to maybe 15%
-- Blood normal hit: attacks of 5–10% health triggers blood hit left/right randomly for 1.5s
-- Blood critical hit: attacks of 10–15% health triggers blood critical for 3s
-- Stamina UI Overlay: appears starting at 30% stamina, increasing opacity up to 100%
-- Stamina desaturation: desaturates screen starting at 30% stamina, up to maximum desaturation (presumably)
-- Stamina blur: blurs everything except 10cm diameter circle in centre of screen starting at 5% stamina, up to maximum blur (would require testing depending on how it's implemented in games)
-- NOTE: Stam blur layers UNDER stam UI overlay; Blood red tint layers UNDER all the blood splatter overlays

-- ToDo
-- 1. Make the resolution of the textures dynamic based on the player's screen resolution
-- 2. Implement blur effect for stamina and magicka

local function HideOverlays()
	BloodUIOverlay:SetAlpha(0.0)
	BloodUITint:SetAlpha(0.0)
	StaminaUIOverlay:SetAlpha(0.0)
	StaminaUITint:SetAlpha(0.0)
	MagickaUIOverlay:SetAlpha(0.0)
end

-- ZO_CharacterFramingBlur = ZO_NormalizedPointFragment:Subclass()

-- function OnNormalizedPointChanged(normalizedX, normalizedY)
--     SetFullscreenEffect(FULLSCREEN_EFFECT_CHARACTER_FRAMING_BLUR, normalizedX, normalizedY)
-- end

-- function ZO_CharacterFramingBlur:New(normalizedPointCallback)
--     fragment = ZO_NormalizedPointFragment.New(self, normalizedPointCallback, OnNormalizedPointChanged)
--     return fragment
-- end

-- function CalculateCenteredFramingTarget()
-- 	screenWidth, screenHeight = GuiRoot:GetDimensions()
-- 	return screenWidth / 2, .55 * screenHeight
-- end

-- IO_BLUR_FRAGMENT = ZO_CharacterFramingBlur:New(CalculateCenteredFramingTarget)
--HUD_SCENE:AddFragment(IO_BLUR_FRAGMENT)

function OnAddOnLoaded(event, addonName)
	local screenWidth, screenHeight = GuiRoot:GetDimensions()
	BloodUIOverlay:SetDimensions(screenWidth, screenHeight)
	BloodUIHitCritical:SetDimensions(screenWidth, screenHeight)
	BloodUIHitRight:SetDimensions(screenWidth, screenHeight)
	BloodUIHitLeft:SetDimensions(screenWidth, screenHeight)
	BloodUITint:SetDimensions(screenWidth, screenHeight)
	StaminaUIOverlay:SetDimensions(screenWidth, screenHeight)
	StaminaUITint:SetDimensions(screenWidth, screenHeight)
	MagickaUIOverlay:SetDimensions(screenWidth, screenHeight)
end

local oldValue = {}
oldValue['health'] =  GetUnitPower("player", COMBAT_MECHANIC_FLAGS_HEALTH)

local function OnPowerUpdate(eventCode, unitTag, powerIndex, powerType, powerValue, powerMax, powertypeOrCombatMechanicFlag, newValue)
	if powerType == POWERTYPE_HEALTH and unitTag == "player" then
		if IsUnitDeadOrReincarnating("player") then --upon death, hide all overlays to clear the screen
			HideOverlays()
			return
		end

		local healthLost = oldValue['health'] - powerValue
		local healthLostPercent = healthLost / powerMax
		local animation = ANIMATION_MANAGER:CreateTimelineFromVirtual("HitFadeAnimation")
		local alphaAnimation = animation:GetFirstAnimation()

		if healthLostPercent >= 0.15 then
			animation:ApplyAllAnimationsToControl(BloodUIHitCritical)
			animation:PlayFromStart()
		end

		local chance = math.random(0, 1)
		if healthLostPercent >= 0.05 and healthLostPercent < 0.15 then
			alphaAnimation:SetDuration(1500)

			if chance == 0 then
				animation:ApplyAllAnimationsToControl(BloodUIHitRight)
			else
				animation:ApplyAllAnimationsToControl(BloodUIHitLeft)
			end

			animation:PlayFromStart()
		end
		
		oldValue['health'] = powerValue

		if powerValue > 0 then
			healthPercent = powerValue / powerMax --defines healthPercent
		end

		if healthPercent <= 0.55 then --at or under 55% health the blood splattered ui gradually appears, up to maximum of 100% opacity
			BloodUIOverlay:SetAlpha((1.4 / 0.55) * (0.55 - healthPercent)) --140% opacity at 0% health, otherwise meaning that at 15% health opacity will have reached its max of 100%
		else
			BloodUIOverlay:SetAlpha(0.0)
			BloodUITint:SetAlpha(0.0) --needs to be here otherwise the game isn't quick enough to catch it only using the below function with sudden huge heals; Overlay has a higher threshold, so if it shouldn't be shown, by necessity neither should the tint
			return
		end

		if healthPercent <= 0.45 then --at or under 45% health the red tint gradually appears, up to maximum of 25% opacity (desired opacity is 20%, but that's never reached since it would only show up at 0% health, so 25% to correct this)
			BloodUITint:SetAlpha((0.25 / 0.45) * (0.45 - healthPercent))
		else
			BloodUITint:SetAlpha(0.0)
			return
		end
	end

	if powerType == POWERTYPE_STAMINA and unitTag == "player" then
		if IsUnitDeadOrReincarnating("player") then --upon death, hide all overlays to clear the screen
			HideOverlays()
			return
		end

		if powerValue > 0 then
			staminaPercent = powerValue / powerMax --defines staminaPercent
		end

		-- if staminaPercent <= 0.5 then
		-- 	IO_BLUR_FRAGMENT:Show()
        -- else
        --     IO_BLUR_FRAGMENT:Hide()
        -- end

		if staminaPercent <= 0.55 then --at or under 55% stamina the stamina exhaustion overlay gradually appears, up to maximum of 100% opacity
			StaminaUIOverlay:SetAlpha((1.222 / 0.55) * (0.55 - staminaPercent)) --122.2% opacity at 0% stamina, otherwise meaning that at 10% stamina opacity will have reached its max of 100%
		else
			StaminaUIOverlay:SetAlpha(0.0)
			StaminaUITint:SetAlpha(0.0) --needs to be here otherwise the game isn't quick enough to catch it only using the below function with sudden huge increases; Overlay has a higher threshold, so if it shouldn't be shown, by necessity neither should the tint
			return
		end

		if staminaPercent <= 0.375 then --at 37.5% stamina the desaturation tint gradually appears, up to maximum of 20% opacity
			StaminaUITint:SetAlpha((0.2 / 0.375) * (0.375 - staminaPercent))
		else
			StaminaUITint:SetAlpha(0.0)
			return
		end
	end

	if powerType == POWERTYPE_MAGICKA and unitTag == "player" then
		if IsUnitDeadOrReincarnating("player") then --upon death, hide all overlays to clear the screen
			HideOverlays()
			return
		end

		if powerValue > 0 then
			magickaPercent = powerValue / powerMax --defines magickaPercent
		end

		if magickaPercent <= 0.45 then --at or under 45% magicka the magicka exhaustion overlay gradually appears, up to maximum of 100% opacity
			MagickaUIOverlay:SetAlpha((1.0 / 0.45) * (0.45 - magickaPercent)) --100% opacity at 0% magicka
		else
			MagickaUIOverlay:SetAlpha(0.0)
			return
		end
	end
end

-- Register event handlers function to be called when the proper event occurs
EVENT_MANAGER:RegisterForEvent(Addon.Name, EVENT_POWER_UPDATE, OnPowerUpdate)
EVENT_MANAGER:RegisterForEvent(Addon.Name, EVENT_PLAYER_DEAD, HideOverlays)
EVENT_MANAGER:RegisterForEvent(Addon.Name, EVENT_PLAYER_ALIVE, HideOverlays)
EVENT_MANAGER:RegisterForEvent(Addon.Name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)