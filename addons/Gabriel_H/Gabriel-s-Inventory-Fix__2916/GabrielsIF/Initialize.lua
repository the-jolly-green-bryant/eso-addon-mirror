GabrielsIF  = {}
GIF		      = GabrielsIF
GIF.Name 	  = "GabrielsIF"

function GIF.OnAddOnLoaded(EventCode, AddonName)                                                                              -- On Load
	if AddonName ~= GIF.Name then return end
	GIF:Initialize()
  
end

function GIF:Initialize()                                                                                                     -- Initialize
  EVENT_MANAGER:UnregisterForEvent(GIF.Name, EVENT_ADD_ON_LOADED)                                                             -- Unregister Event to stop repeated attempts to load
  GIF.InGame = ZO_SavedVars:NewAccountWide("GIFInGame",  2,  "Variables",  GIF:InGameManager(), "Default")                    -- Set Saved Variables reference
  EVENT_MANAGER:RegisterForEvent(GIF.Name, EVENT_PLAYER_ACTIVATED, function() GIF:OnPlayerActivated() end)                    -- Initialization Routine
end

function GIF:InGameManager()                                                                                                  -- Default Values
  local InGame          = {
    InvMenu             = "Inventory",
    InvTab              = "TabsButton10",
    InvNum              = "10",
    InvSub              = {
      ["TabsButton0"]   = "SearchFiltersSubTabsButton1",
      ["TabsButton1"]   = "SearchFiltersSubTabsButton1",
      ["TabsButton2"]   = "SearchFiltersSubTabsButton1",
      ["TabsButton3"]   = "SearchFiltersSubTabsButton10",
      ["TabsButton4"]   = "SearchFiltersSubTabsButton6",
      ["TabsButton5"]   = "SearchFiltersSubTabsButton11",
      ["TabsButton6"]   = "SearchFiltersSubTabsButton12",
      ["TabsButton7"]   = "SearchFiltersSubTabsButton3",
      ["TabsButton8"]   = "SearchFiltersSubTabsButton5",
      ["TabsButton9"]   = "SearchFiltersSubTabsButton6",
      ["TabsButton10"]  = "SearchFiltersSubTabsButton1",},
    CftTab              = "TabsButton10",
    CftNum              = "10",
    CftSub              = {
      ["TabsButton0"]   = "SearchFiltersSubTabsButton1",
      ["TabsButton1"]   = "SearchFiltersSubTabsButton5",
      ["TabsButton2"]   = "SearchFiltersSubTabsButton3",
      ["TabsButton3"]   = "SearchFiltersSubTabsButton6",
      ["TabsButton4"]   = "SearchFiltersSubTabsButton5",
      ["TabsButton5"]   = "SearchFiltersSubTabsButton5",
      ["TabsButton6"]   = "SearchFiltersSubTabsButton6",
      ["TabsButton7"]   = "SearchFiltersSubTabsButton5",
      ["TabsButton8"]   = "SearchFiltersSubTabsButton5",
      ["TabsButton9"]   = "SearchFiltersSubTabsButton5",
      ["TabsButton10"]  = "SearchFiltersSubTabsButton1",},}
  return InGame
end

function GIF:OnPlayerActivated(EventCode, Initial)                                                                            -- Player Activated
  local Default = GIF:InGameManager()                                                                                         -- Reference for Default Values
  EVENT_MANAGER:UnregisterForEvent(GIF.Name, EVENT_PLAYER_ACTIVATED)                                                          -- Unregistering so it only fires at Initial Load/Reload
  GIF.InGame.InvMenu  = Default.InvMenu                                                                                       -- Set to Default Values on Load
  GIF.InGame.InvTab   = Default.InvTab                                                                       
  GIF.InGame.InvNum   = Default.InvNum
  GIF.InGame.CftTab   = Default.CftTab
  GIF.InGame.CftNum   = Default.CftNum
  
  for i = 0, 10 do
    GIF.InGame.InvSub["TabsButton"..i] = Default.InvSub["TabsButton"..i]
    GIF.InGame.CftSub["TabsButton"..i] = Default.CftSub["TabsButton"..i]
  end
    
  local function GIF_MouseClick(TabChange)                                                                                    -- Simulate Mouse clicks for Tab & SubTab Buttons
    local TabName = "TabsButton0"
    if GIF.InGame.InvMenu == "Inventory" then
      if TabChange then TabName = "TabsButton"..GIF.InGame.InvNum end
      ZO_MenuBarButtonTemplate_OnMouseUp(ZO_PlayerInventory:GetNamedChild(GIF.InGame.InvTab), MOUSE_BUTTON_INDEX_LEFT, true)
      ZO_MenuBarButtonTemplate_OnMouseUp(ZO_PlayerInventory:GetNamedChild(GIF.InGame.InvSub[TabName]), MOUSE_BUTTON_INDEX_LEFT, true)
      INVENTORY_MENU_BAR:UpdateInventoryKeybinds()                                                                            -- To counter error on opening consecutive containers etc.
    elseif GIF.InGame.InvMenu == "Craft" then
      if TabChange then TabName = "TabsButton"..GIF.InGame.CftNum end
      ZO_MenuBarButtonTemplate_OnMouseUp(ZO_CraftBag:GetNamedChild(GIF.InGame.CftTab), MOUSE_BUTTON_INDEX_LEFT, true)
      ZO_MenuBarButtonTemplate_OnMouseUp(ZO_CraftBag:GetNamedChild(GIF.InGame.CftSub[TabName]), MOUSE_BUTTON_INDEX_LEFT, true)
    end
  end
  
  local function GIF_MouseUp(Control, Button, UpInside, Type)
    ZO_MenuBarButtonTemplate_OnMouseUp(Control, Button, UpInside)                                                             -- Run original OnMouseUp Function. Must run first.
    if SCENE_MANAGER:GetCurrentSceneName() == "inventory" then                                                                -- Avoids tradinghouse etc. conflicts
      if Type == "Menu" and Control:GetName() == "ZO_PlayerInventoryMenuBarButton1" then
        GIF.InGame.InvMenu = "Inventory"
      elseif Type == "Menu" and Control:GetName() == "ZO_PlayerInventoryMenuBarButton2" then
        GIF.InGame.InvMenu = "Craft"
      elseif Type == "Menu" then
        GIF.InGame.InvMenu = ""
      elseif Type == "Tab" and GIF.InGame.InvMenu == "Inventory" then
        GIF.InGame.InvTab = string.gsub(Control:GetName(), "ZO_PlayerInventory", "")                                          -- Saves selected Tab Name
        GIF.InGame.InvNum = tostring(string.gsub(Control:GetName(), "ZO_PlayerInventoryTabsButton", ""))                      -- Saves selected Tab Number
      elseif Type == "Tab" and GIF.InGame.InvMenu == "Craft" then
        GIF.InGame.CftTab = string.gsub(Control:GetName(), "ZO_CraftBag", "")                                                 -- Saves selected Tab Name
        GIF.InGame.CftNum = tostring(string.gsub(Control:GetName(), "ZO_CraftBagTabsButton", ""))                             -- Saves selected Tab Number
      elseif Type == "SubTab" and GIF.InGame.InvMenu == "Inventory" then
        GIF.InGame.InvSub["TabsButton0"] = string.gsub(Control:GetName(), "ZO_PlayerInventory", "")                           -- Saves selected SubTab Name for Scene changing use
        GIF.InGame.InvSub["TabsButton"..GIF.InGame.InvNum] = string.gsub(Control:GetName(), "ZO_PlayerInventory", "")         -- Saves selected SubTab Name for Tab changing use
      elseif Type == "SubTab" and GIF.InGame.InvMenu == "Craft" then
        GIF.InGame.CftSub["TabsButton0"] = string.gsub(Control:GetName(), "ZO_CraftBag", "")                                  -- Saves selected SubTab Name for Scene changing use
        GIF.InGame.CftSub["TabsButton"..GIF.InGame.CftNum] = string.gsub(Control:GetName(), "ZO_CraftBag", "")                -- Saves selected SubTab Name for Tab changing use
      end
      if Type == "Menu" and GIF.InGame.InvMenu ~= "" then GIF_MouseClick(false) end                                           -- Simulates Mouse clicks
      if Type == "Tab" or Type == "SubTab" then GIF_MouseClick(true) end                                                      -- Simulates Mouse clicks
    end
  end
  
  local Ctrls = {
    [1]       = ZO_PlayerInventoryMenuBar,
    [2]       = ZO_PlayerInventoryTabs,
    [3]       = ZO_CraftBagTabs,
    [4]       = ZO_PlayerInventorySearchFiltersSubTabs,
    [5]       = ZO_CraftBagSearchFiltersSubTabs,}
  
  for Num, Ctrl in ipairs(Ctrls) do
    for i = 1, Ctrl:GetNumChildren() do
      local Child = Ctrl:GetChild(i)
      if string.find(Child:GetName(), "Button") ~= nil then 
        if Num == 1 then                                                                                                      -- Override OnMouseUp Function for Menu Buttons
          Child:SetHandler("OnMouseUp", function(Control, Button, UpInside) GIF_MouseUp(Control, Button, UpInside, "Menu") end)
        elseif Num == 2 or Num == 3 then                                                                                      -- Override OnMouseUp Function for Tab Buttons
          Child:SetHandler("OnMouseUp", function(Control, Button, UpInside) GIF_MouseUp(Control, Button, UpInside, "Tab") end)
        elseif Num == 4 or Num == 5 then                                                                                      -- Override OnMouseUp Function for SubTab Buttons
          Child:SetHandler("OnMouseUp", function(Control, Button, UpInside) GIF_MouseUp(Control, Button, UpInside, "SubTab") end) 
        end
      end
      if Num == 3 then ZO_MenuBarButtonTemplate_OnMouseUp(ZO_PlayerInventoryTabsButton6, MOUSE_BUTTON_INDEX_LEFT, true) end   -- Expose largest number of SubTabs to run SetHandler
      if Num == 4 then
        ZO_MenuBarButtonTemplate_OnMouseUp(ZO_PlayerInventoryTabsButton10, MOUSE_BUTTON_INDEX_LEFT, true)                     -- Reset to default inventory Tab
        ZO_MenuBarButtonTemplate_OnMouseUp(ZO_CraftBagTabsButton3, MOUSE_BUTTON_INDEX_LEFT, true)                             -- Expose largest number of SubTabs to run SetHandler
      end
      if Num == 5 then ZO_MenuBarButtonTemplate_OnMouseUp(ZO_CraftBagTabsButton10, MOUSE_BUTTON_INDEX_LEFT, true) end         -- Reset to default craft Tab
    end
  end
  
  INVENTORY_FRAGMENT:RegisterCallback("StateChange",                                                                          -- Register Callback for when Inventory is opened
    function(OldState, NewState)
      if NewState == SCENE_FRAGMENT_SHOWN then                                                                                -- Callback for opening Inventory only works on SHOWN
        if SCENE_MANAGER:GetCurrentSceneName() == "inventory" and GIF.InGame.InvMenu ~= "" then                               -- Avoids tradinghouse etc. conflicts
          GIF_MouseClick(false)                                                                                               -- Simulates Mouse clicks  
        end
      end
    end)
end

EVENT_MANAGER:RegisterForEvent(GIF.Name, EVENT_ADD_ON_LOADED, GIF.OnAddOnLoaded)                                              -- Register Addon Loading