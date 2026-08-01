    -- *** BowsHouse ***
     
    BowsHouse = {}
    BowsHouse.name = "BowsHouse"
    ------------------------
    function BowsHouse.Port()
     
       d("Porting to Bow's house.")
       JumpToSpecificHouse("@BowProc", 104)
    end
     
    function BowsHouse.OnAddOnLoaded(event, addonName)
      if addonName == BowsHouse.name then
        SLASH_COMMANDS["/bows"] = BowsHouse.Port
       
        EVENT_MANAGER:UnregisterForEvent(BowsHouse.name, EVENT_ADD_ON_LOADED)
      end
    end
     
    ZO_CreateStringId("SI_BINDING_NAME_BOWSHOUSE_PORT", "Travel to Bow's House")
    EVENT_MANAGER:RegisterForEvent(BowsHouse.name, EVENT_ADD_ON_LOADED, BowsHouse.OnAddOnLoaded)