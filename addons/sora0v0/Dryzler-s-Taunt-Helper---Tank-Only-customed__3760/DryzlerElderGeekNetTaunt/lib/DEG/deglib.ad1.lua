local DEG_ADDON = _G["DEG_CURRENT_ADDON"]
if _G[DEG_ADDON.PACKAGE_NAME].libs == nil then _G[DEG_ADDON.PACKAGE_NAME].libs = {} end

local deglib = {
  name = "ad1",
  version = 1,
  initialized = false,
}

function deglib:initialize()
    if self.initialized then return self end

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, function(...) self:onEVENT_PLAYER_ACTIVATED(...) end)  
         
    self.initialized = true
    
    return self
end

function deglib:onEVENT_PLAYER_ACTIVATED(intEventCode, bInitial)
  local addon = _G[DEG_ADDON.PACKAGE_NAME].plugins[DEG_ADDON.ADDON_NAME_SHORT]
        
  if not addon.savedVariablesAccount then
    d("savedVariablesAccountNotFound()" + DEG_ADDON.ADDON_NAME_SHORT)
    savedVariablesAccountNotFound()
  end
  
  if addon.savedVariablesAccount.degad1 then return end               
    
  addon.savedVariablesAccount.degad1 = true
  
  local LINK_MOUSE_OVER_COLOR = ZO_ColorDef:New("B8B8D3")
  
  local tlc = WINDOW_MANAGER:CreateControl("DegAd1", GuiRoot, CT_TOPLEVELCONTROL)
  tlc:SetMouseEnabled(true)
  tlc:SetMovable(false)
  tlc:SetClampedToScreen(true)  
  tlc:SetDimensions(750, 400)
  tlc:SetAnchor(CENTER)  
    
  local bd = WINDOW_MANAGER:CreateControl("DegAd1Backdrop", tlc, CT_BACKDROP)
  WINDOW_MANAGER:ApplyTemplateToControl(bd, "ZO_DefaultBackdrop")
  
  local lbl1 = WINDOW_MANAGER:CreateControl("DegAd1Label1", tlc, CT_LABEL)
  lbl1:SetFont("ZoFontAnnounceMedium")
  lbl1:SetText(GetString(SI_DEG_SI_AD1_HEADER))
  lbl1:SetAnchor(TOP, PARENT, TOP)
  
  local div1 = WINDOW_MANAGER:CreateControl("DegAd1TopDivider1", lbl1, CT_TEXTURE)
  div1:SetTexture("/esoui/art/miscellaneous/horizontaldivider.dds")
  div1:SetDimensions(800,4)
  div1:SetAnchor(TOP, PARENT, BOTTOM, 0, 0)
  --div1:SetDrawTier(DT_HIGH)
  
  local btn1 = WINDOW_MANAGER:CreateControl("DegAd1TopButton1", tlc, CT_BUTTON)
  btn1:SetDimensions(40,40)
  btn1:SetAnchor(TOPRIGHT, PARENT, TOPRIGHT, 15)
  btn1:SetNormalTexture("EsoUI/Art/Buttons/closebutton_up.dds")
  btn1:SetMouseOverTexture("EsoUI/Art/Buttons/closebutton_mouseover.dds")
  btn1:SetDisabledTexture("EsoUI/Art/Buttons/closebutton_disabled.dds")
  btn1:SetHandler("OnClicked", function() tlc:SetHidden(true) end)
  
  local lbl2 = WINDOW_MANAGER:CreateControl("DegAd1Label2", tlc, CT_LABEL)
  lbl2:SetFont("ZoFontAnnounceMedium")
  lbl2:SetText(GetString(SI_DEG_SI_LBL2_HEADER))
  lbl2:SetAnchor(TOP, PARENT, TOP, 0, 50)
  
  local lbl3 = WINDOW_MANAGER:CreateControl("DegAd1Label3", tlc, CT_LABEL)
  lbl3:SetFont("ZoFontAnnounceMedium")
  lbl3:SetText(GetString(SI_DEG_SI_LBL3_HEADER))
  lbl3:SetAnchor(TOP, PARENT, TOP, 0, 90)  
  
  local t1 = WINDOW_MANAGER:CreateControl("DegAd1Gardonme", tlc, CT_BUTTON)
  t1:SetNormalTexture(DEG_ADDON.ADDON_NAME .. "/lib/DEG/img/gardonme.dds")
  t1:SetDimensions(100,100)
  t1:SetAnchor(TOP, PARENT, TOP, -150, 150)
  t1:SetHandler("OnClicked", function() RequestOpenUnsafeURL("https://gardon.me") end)
  if (GetCVar("language.2") == "de") then
    t1:SetHandler("OnClicked", function() RequestOpenUnsafeURL("https://gardonme.de") end)
  end  
  
  local t2 = WINDOW_MANAGER:CreateControl("DegAd1Wikivotes", tlc, CT_BUTTON)
  t2:SetNormalTexture(DEG_ADDON.ADDON_NAME .. "/lib/DEG/img/wikivotes.dds")
  t2:SetDimensions(100,100)
  t2:SetAnchor(TOP, PARENT, TOP, 150, 150)
  t2:SetHandler("OnClicked", function() RequestOpenUnsafeURL("https://wikivotes.org") end)
  
  local lblt1 = WINDOW_MANAGER:CreateControl("DegAd1LabelT1", tlc, CT_BUTTON)
  lblt1:SetFont("ZoFontAnnounceMedium")
  lblt1:SetText("https://gardon.me")
  lblt1:SetAnchor(TOP, t1, BOTTOM, 0, 5)    
  lblt1:SetHandler("OnClicked", function() RequestOpenUnsafeURL("https://gardon.me") end)
  if (GetCVar("language.2") == "de") then
    lblt1:SetHandler("OnClicked", function() RequestOpenUnsafeURL("https://gardonme.de") end)
  end
  lblt1:SetDimensions(lblt1:GetLabelControl():GetTextDimensions())
  lblt1:SetMouseOverFontColor(LINK_MOUSE_OVER_COLOR:UnpackRGBA())
  
  local lblt2 = WINDOW_MANAGER:CreateControl("DegAd1LabelT2", tlc, CT_BUTTON)
  lblt2:SetFont("ZoFontAnnounceMedium")
  lblt2:SetText("https://wikivotes.org")
  lblt2:SetAnchor(TOP, t2, BOTTOM, 0, 5)  
  lblt2:SetHandler("OnClicked", function() RequestOpenUnsafeURL("https://wikivotes.org") end)
  lblt2:SetDimensions(lblt2:GetLabelControl():GetTextDimensions())
  lblt2:SetMouseOverFontColor(LINK_MOUSE_OVER_COLOR:UnpackRGBA())
    
  
  
  tlc:SetHidden(false)
end


degLibRegisterLib(deglib.name, deglib.version, deglib)