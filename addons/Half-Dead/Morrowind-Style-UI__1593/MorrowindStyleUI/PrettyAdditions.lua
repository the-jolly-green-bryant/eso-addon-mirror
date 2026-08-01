local MyTexture = WINDOW_MANAGER:CreateControl("Inventory", ZO_PlayerInventory, CT_TEXTURE)   
MyTexture:SetDimensions(7,830) 
MyTexture:SetAnchor(TOPLEFT, ZO_StatsPanelTitleSection, CENTER, 337, -85) 
MyTexture:SetTexture("/MorrowindStyleUI/media/border.dds")  

local MyTexture = WINDOW_MANAGER:CreateControl("CharacterWindow", ZO_CharacterWindowStats, CT_TEXTURE)   
MyTexture:SetDimensions(7,588) 
MyTexture:SetAnchor(CENTER, ZO_CharacterWindowStats, CENTER, -358, -10) 
MyTexture:SetTexture("/MorrowindStyleUI/media/border.dds")  

local MyTexture = WINDOW_MANAGER:CreateControl("TopBar", ZO_TopBar, CT_TEXTURE)   
MyTexture:SetDimensions(900,80) 
MyTexture:SetAnchor(CENTER, ZO_TopBar, CENTER, -35, 6) 
MyTexture:SetTexture("/MorrowindStyleUI/media/topbar.dds")  


