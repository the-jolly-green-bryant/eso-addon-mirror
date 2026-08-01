local MyTexture = WINDOW_MANAGER:CreateControl("Compass_left", ZO_CompassFrame, CT_TEXTURE)   
MyTexture:SetDimensions(32,25) 
MyTexture:SetAnchor(CENTER, ZO_CompassFrame, LEFT, -12, 0) 
MyTexture:SetTexture("/SkyrimStyleUI/media/compass_left.dds")  

local MyTexture = WINDOW_MANAGER:CreateControl("Compass_right", ZO_CompassFrame, CT_TEXTURE)   
MyTexture:SetDimensions(32,25) 
MyTexture:SetAnchor(CENTER, ZO_CompassFrame, RIGHT, 12, 0)  
MyTexture:SetTexture("/SkyrimStyleUI/media/compass_right.dds")  