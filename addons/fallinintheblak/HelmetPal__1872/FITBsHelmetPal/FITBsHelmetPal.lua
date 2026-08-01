local FITBsHelmetPal = {}
FITBsHelmetPal.name = "FITBsHelmetPal"
FITBsHelmetPal.version = "0.3"--a
FITBsHelmetPal.inCombat = false
         
function FITBsHelmetPal.CombatStateChanged(event, combatState)
    FITBsHelmetPal.inCombat = combatState
    if FITBsHelmetPal.inCombat then
		FITBsHelmetPal.ToggleHelmet(0)
		--SetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_HELM, 0)
    else
			FITBsHelmetPal.ToggleHelmet(1)
		--SetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_HELM, 1)
    end
end
   
function FITBsHelmetPal.OnAddOnLoaded(event, addonName)
    if addonName == FITBsHelmetPal.name then    
        FITBsHelmetPal.inCombat = IsUnitInCombat("player")    
        EVENT_MANAGER:RegisterForEvent("FITBsHelmetPal", EVENT_PLAYER_COMBAT_STATE, FITBsHelmetPal.CombatStateChanged)
        EVENT_MANAGER:UnregisterForEvent("FITBsHelmetPal", EVENT_ADD_ON_LOADED)		
    end
end

function FITBsHelmetPal.ToggleHelmet(value)
	--d("Toggling helmet.")
	if not value or value == "" then
		local before = GetSetting( SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_HELM )
		SetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_HELM, 1 - before)
	else
		SetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_HELM, value)
	end
end

function FITBsHelmetPal.HelpMe(command)
	--if not value or value == "" then
		d("HelmetPal Help: ")
	    d("|ce5e1b4/helm <value>:|r |cffffffToggle helmet visibility. Value can be 0, 1, or blank.|r")
		d("|ce5e1b4/hphelp:|r |cffffffShows this menu.|r")	
end		
        
EVENT_MANAGER:RegisterForEvent("FITBsHelmetPal", EVENT_ADD_ON_LOADED, FITBsHelmetPal.OnAddOnLoaded)
SLASH_COMMANDS["/helm"] = FITBsHelmetPal.ToggleHelmet
SLASH_COMMANDS["/hphelp"] = FITBsHelmetPal.HelpMe