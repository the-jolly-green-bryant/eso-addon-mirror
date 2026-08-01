    HideMeterBackground = {}
    HideMeterBackground.name = "HideMeterBackground"
     
        local function Addon_Loaded(eventCode, addOnName)
            if (addOnName == "HideMeterBackground") then
				ZO_PerformanceMetersBg:SetAlpha(0)
            end
        end
		        
         EVENT_MANAGER:RegisterForEvent("HideMeterBackground", EVENT_ADD_ON_LOADED, Addon_Loaded)
