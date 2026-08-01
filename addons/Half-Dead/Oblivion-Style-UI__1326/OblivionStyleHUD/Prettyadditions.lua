local MyTexture = WINDOW_MANAGER:CreateControl("Character", ZO_StatsPanel, CT_TEXTURE)   
MyTexture:SetDimensions(1700,100) 
MyTexture:SetAnchor(TOPLEFT, ZO_StatsPanelTitleSection, TOPLEFT, -100, -20) 
MyTexture:SetTexture("/OblivionStyleHud/media/details/inv_tab3.dds")  

local MyTexture = WINDOW_MANAGER:CreateControl("Inventory", ZO_PlayerInventory, CT_TEXTURE)   
MyTexture:SetDimensions(1330,75) 
MyTexture:SetAnchor(TOPLEFT, ZO_StatsPanelTitleSection, TOPLEFT, -15, 30) 
MyTexture:SetTexture("/OblivionStyleHud/media/details/inv_tab.dds")  

local MyTexture = WINDOW_MANAGER:CreateControl("Inventory2", ZO_CraftBag, CT_TEXTURE)   
MyTexture:SetDimensions(1330,75) 
MyTexture:SetAnchor(TOPLEFT, ZO_StatsPanelTitleSection, TOPLEFT, -15, 30) 
MyTexture:SetTexture("/OblivionStyleHud/media/details/inv_tab3.dds")  


local MyTexture = WINDOW_MANAGER:CreateControl("Inventory3", ZO_InventoryWallet, CT_TEXTURE)   
MyTexture:SetDimensions(1330,75) 
MyTexture:SetAnchor(TOPLEFT, ZO_StatsPanelTitleSection, TOPLEFT, -15, 30) 
MyTexture:SetTexture("/OblivionStyleHud/media/details/inv_tab3.dds")  


local MyTexture = WINDOW_MANAGER:CreateControl("Inventory4", ZO_QuickSlot, CT_TEXTURE)   
MyTexture:SetDimensions(1330,75) 
MyTexture:SetAnchor(TOPLEFT, ZO_StatsPanelTitleSection, TOPLEFT, -15, 30) 
MyTexture:SetTexture("/OblivionStyleHud/media/details/inv_tab3.dds")   


local MyTexture = WINDOW_MANAGER:CreateControl("Skills", ZO_Skills, CT_TEXTURE) 
MyTexture:SetDimensions(500,500)
MyTexture:SetAnchor(TOPLEFT, ZO_StatsPanelTitleSection, TOPLEFT, 150, 335) 
MyTexture:SetTexture("/OblivionStyleHud/media/details/skills.dds") 

local MyTexture = WINDOW_MANAGER:CreateControl("Map", ZO_WorldMapQuests, CT_TEXTURE) 
MyTexture:SetDimensions(550,550) 
MyTexture:SetAnchor(TOPLEFT, ZO_StatsPanelTitleSection, TOPLEFT, 200, 265)  
MyTexture:SetTexture("/OblivionStyleHud/media/details/map.dds")  

local MyTexture = WINDOW_MANAGER:CreateControl("Map2", ZO_WorldMapLocations, CT_TEXTURE) 
MyTexture:SetDimensions(550,550) 
MyTexture:SetAnchor(TOPLEFT, ZO_StatsPanelTitleSection, TOPLEFT, 200, 265)  
MyTexture:SetTexture("/OblivionStyleHud/media/details/map.dds")  

local MyTexture = WINDOW_MANAGER:CreateControl("Map3", ZO_WorldMapKey, CT_TEXTURE) 
MyTexture:SetDimensions(550,550) 
MyTexture:SetAnchor(TOPLEFT, ZO_StatsPanelTitleSection, TOPLEFT, 200, 265)  
MyTexture:SetTexture("/OblivionStyleHud/media/details/map.dds")  

local MyTexture = WINDOW_MANAGER:CreateControl("Map4", ZO_WorldMapFilters, CT_TEXTURE) 
MyTexture:SetDimensions(550,550) 
MyTexture:SetAnchor(TOPLEFT, ZO_StatsPanelTitleSection, TOPLEFT, 200, 265)  
MyTexture:SetTexture("/OblivionStyleHud/media/details/map.dds")  

local MyTexture = WINDOW_MANAGER:CreateControl("Journal", ZO_QuestJournal, CT_TEXTURE) 
MyTexture:SetDimensions(500,500)
MyTexture:SetAnchor(TOPLEFT, ZO_StatsPanelTitleSection, TOPLEFT, 150, 345) 
MyTexture:SetTexture("/OblivionStyleHud/media/details/journal.dds") 

--- Gamepad ---

local MyTexture = WINDOW_MANAGER:CreateControl("GamepadChar", ZO_MainMenu_Gamepad, CT_TEXTURE)   
MyTexture:SetDimensions(900,1700) 
MyTexture:SetAnchor(TOP, ZO_MainMenu_Gamepad, TOP, -200, -65) 
MyTexture:SetTexture("/OblivionStyleHud/media/interface/ob_main_background_gamepad.dds")  

local MyTexture = WINDOW_MANAGER:CreateControl("GamepadInv", ZO_GamepadInventoryTopLevel, CT_TEXTURE)   
MyTexture:SetDimensions(900,1700) 
MyTexture:SetAnchor(TOP, ZO_MainMenu_Gamepad, TOP, -200, -65) 
MyTexture:SetTexture("/OblivionStyleHud/media/interface/ob_main_background_gamepad.dds")  

local MyTexture = WINDOW_MANAGER:CreateControl("GamepadCollections", ZO_GamepadCollections, CT_TEXTURE)   
MyTexture:SetDimensions(900,1700) 
MyTexture:SetAnchor(TOP, ZO_MainMenu_Gamepad, TOP, -200, -65) 
MyTexture:SetTexture("/OblivionStyleHud/media/interface/ob_main_background_gamepad.dds")  

local MyTexture = WINDOW_MANAGER:CreateControl("Gamepadstats", ZO_GamepadStatsTopLevel, CT_TEXTURE)   
MyTexture:SetDimensions(900,1700) 
MyTexture:SetAnchor(TOP, ZO_MainMenu_Gamepad, TOP, -200, -65) 
MyTexture:SetTexture("/OblivionStyleHud/media/interface/ob_main_background_gamepad.dds")  

local MyTexture = WINDOW_MANAGER:CreateControl("GamepadSkills", ZO_GamepadSkillsTopLevel, CT_TEXTURE)   
MyTexture:SetDimensions(900,1700) 
MyTexture:SetAnchor(TOP, ZO_MainMenu_Gamepad, TOP, -200, -65) 
MyTexture:SetTexture("/OblivionStyleHud/media/interface/ob_main_background_gamepad.dds")  

local MyTexture = WINDOW_MANAGER:CreateControl("GamepadPvP", ZO_CampaignBrowser_GamepadTopLevel, CT_TEXTURE)   
MyTexture:SetDimensions(900,1700) 
MyTexture:SetAnchor(TOP, ZO_MainMenu_Gamepad, TOP, -200, -65) 
MyTexture:SetTexture("/OblivionStyleHud/media/interface/ob_main_background_gamepad.dds")  
