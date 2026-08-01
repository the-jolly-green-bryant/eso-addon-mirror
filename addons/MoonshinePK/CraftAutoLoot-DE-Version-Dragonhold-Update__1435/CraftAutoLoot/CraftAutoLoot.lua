CraftAutoLoot = {}

CraftAutoLoot.name = "CraftAutoLoot"

function CraftAutoLoot:Initialize()
   ZO_ReticleContainerInteract:SetHandler("OnShow", function()
      local action, container, _, _, additionalInfo, _ = GetGameCameraInteractableActionInfo()
      if action == "Abbauen" or action == "Nehmen" or action == "Hacken" or action == "Einfangen" or ((container == "Apfelkorb" or container == "Traubenkorb" or container == "Apfelkiste" or container == "Fass" or container == "F\195\164sser" or container == "Korb" or container == "Garderobe" or container == "Korb mit Mais" or container == "Kiste" or container == "Kisten" or container == "Kassette" or container == "Mehlsack" or container == "Salatkorb" or container == "Melonenkorb" or container == "Hirsesack" or container == "Sack" or container == "Salzreissack" or container == "Gew\195\188rzsack" or container == "Tomatenkiste" or container == "Rucksack" or container == "Schwerer Sack") and action == "Durchsuchen") or ((container == "Schwere Kiste") and action == "\195\150ffnen") or ((container == "Trinkschlauch") and action == "Umf\195\188llen") then
         SetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT, 1)
      else
	 SetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT, 0)
      end
   end)
end

function CraftAutoLoot.OnAddOnLoaded(event, addonName)
  if addonName == CraftAutoLoot.name then
    CraftAutoLoot:Initialize()
  end
end

EVENT_MANAGER:RegisterForEvent(CraftAutoLoot.name, EVENT_ADD_ON_LOADED, CraftAutoLoot.OnAddOnLoaded)