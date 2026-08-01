
function HealerHelper.AreHotKeysVisible()
	return not ZO_ActionBar_GetButton(3).buttonText:IsHidden()
end

HealerHelper.HudCanBeDisplayed = false
HealerHelper.HudHitEdgeOfScreen = false

function HealerHelper.InitialiseHud()

	if FancyActionBar == nil and HealerHelper.savedVars.enableHudWithoutFancyActionBar == false then -- HUD can only be turned on when FAB is running
		HealerHelper.HudCanBeDisplayed = false
		return
	end

	HealerHelper.HudCanBeDisplayed = true -- we can display the HUD

end

function HealerHelper.DeinitialiseHud()

end
