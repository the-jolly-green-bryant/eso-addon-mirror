CraftAutoLoot = {}
 
CraftAutoLoot.name = "CraftAutoLoot+Key"

function CraftAutoLoot:Initialize()
    ZO_ReticleContainerInteract:SetHandler("OnShow", function()
      local action, container, _, _, additionalInfo, _ = GetGameCameraInteractableActionInfo() 
  	
        if 
        action == "Mine" or action == "Collect" or action == "Cut" or action == "Take" or action == "Fish" or action == "Reel In" then 
        SetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT, 1)
      
        elseif action == "Abbauen" or action == "Nehmen" or action == "Hacken" or action == "Einfangen" or action == "Fischen" or action == "Einholen" then 
        SetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT, 1)
		
	elseif
        IsShiftKeyDown(action == "Search") then 
        SetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT, 1)

        elseif
        IsShiftKeyDown(action == "Durchsuchen") then 
        SetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT, 1)
      
        else
        SetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT, 0) 
      end
   end)
end




function CraftAutoLoot.OnAddOnLoaded(event, addonName)
  if (addonName ~= CraftAutoLoot.name) then 
    CraftAutoLoot:Initialize()
   end
end
   


EVENT_MANAGER:RegisterForEvent(CraftAutoLoot.name, EVENT_ADD_ON_LOADED, CraftAutoLoot.OnAddOnLoaded)

