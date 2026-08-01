    -- *** CraftingHouse ***
     
    CraftingHouse = {}
    CraftingHouse.name = "CraftingHouse"
    ------------------------
    function CraftingHouse.Port()
     
       d("Porting to the crafting house.")
       JumpToSpecificHouse("@NoMamesGuey", 47)
    end
     
    function CraftingHouse.OnAddOnLoaded(event, addonName)
      if addonName == CraftingHouse.name then
        SLASH_COMMANDS["/crafting"] = CraftingHouse.Port
       
        EVENT_MANAGER:UnregisterForEvent(CraftingHouse.name, EVENT_ADD_ON_LOADED)
      end
    end
     
    ZO_CreateStringId("SI_BINDING_NAME_CRAFTINGHOUSE_PORT", "Travel to Crafting House")
    EVENT_MANAGER:RegisterForEvent(CraftingHouse.name, EVENT_ADD_ON_LOADED, CraftingHouse.OnAddOnLoaded)