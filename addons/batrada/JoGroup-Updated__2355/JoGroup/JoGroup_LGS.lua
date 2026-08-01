JoGroup = JoGroup or {}
local Jo = JoGroup
local LGS = LibStub:GetLibrary("LibGroupSocket", true)

if LGS then
	local handler = LGS:GetHandler(LGS.MESSAGE_TYPE_RESOURCES)

	if handler then
		Jo.lgsIsEnabled = true
		handler:RegisterForResourcesChanges(function(unitTag, magickaCurrent, magickaMaximum, staminaCurrent, staminaMaximum, isSelf)
			local sf = 1/GetSetting(SETTING_TYPE_UI, UI_SETTING_CUSTOM_SCALE)
			local unit = Jo.unit[unitTag]
			local frame = Jo.frame[unitTag]
			local barHeight = Jo.lgsBarHeight

			frame.bar:SetHeight(Jo.statusBarHeight-(5*sf)-barHeight)
			frame.gloss:SetHeight(frame.bar:GetHeight())

			frame.lgs:SetHeight(barHeight)
			frame.lgs:SetDimensions(frame.bar:GetWidth(), barHeight)
			frame.lgsMagBar:SetHeight(barHeight)
			frame.lgsStaBar:SetHeight(barHeight)

			if staminaMaximum == magickaMaximum or Jo.savedVars.lgsShowBoth then
				frame.lgsMagBar:SetWidth((frame.bar:GetWidth()/2)-sf)
				frame.lgsStaBar:SetWidth(frame.bar:GetWidth()/2)
				frame.lgsMagBar:SetBarAlignment(1)
				frame.lgsMagBarGloss:SetBarAlignment(1)

			elseif staminaMaximum > magickaMaximum then
				frame.lgsMagBar:SetWidth(0)
				frame.lgsStaBar:SetWidth(frame.bar:GetWidth())
			else
				frame.lgsMagBar:SetWidth(frame.bar:GetWidth())
				frame.lgsStaBar:SetWidth(0)
				frame.lgsMagBar:SetBarAlignment(0)
				frame.lgsMagBarGloss:SetBarAlignment(0)
			end

			ZO_StatusBar_SmoothTransition(frame.lgsMagBar, magickaCurrent, magickaMaximum)
			ZO_StatusBar_SmoothTransition(frame.lgsStaBar, staminaCurrent, staminaMaximum)
			ZO_StatusBar_SmoothTransition(frame.lgsMagBarGloss, magickaCurrent, magickaMaximum)
			ZO_StatusBar_SmoothTransition(frame.lgsStaBarGloss, staminaCurrent, staminaMaximum)

			unit.lgsUpdate = GetFrameTimeSeconds()
		end)
	end
end
