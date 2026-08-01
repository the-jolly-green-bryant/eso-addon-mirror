-- FlatDesign by @Shissu
local _interface = {}
local _L = ShissuFramework["func"]._L("ShissuFramework")

local _globals = ShissuFramework["globals"]
local stdColor = _globals["stdColor"]
local white = _globals["white"]

function _interface.getThemeColor(array)
  if ( shissuFramework ~= nil ) then
    if ( shissuFramework["color"] ~= nil ) then
      if ( array == true ) then
        return shissuFramework["color"]
      else
        return shissuFramework["color"][1],shissuFramework["color"][2],shissuFramework["color"][3],shissuFramework["color"][4]
      end
    end
  end

  if ( array == true ) then
    return { 0.1568627506, 0.8313725591, 1, 1 }
  end

  return 0.1568627506, 0.8313725591, 1, 1
end

-- Hauptfenster
function _interface.createFlatWindow(mainParent, mainParent2, dimensions, closeFunc, title, onlyBox)
  if ( onlyBox == nil ) then onlyBox = false end
  dimensions[1] = dimensions[1] + 10

  local backdrop = CreateControl(mainParent .. "BACKDROP", mainParent2, CT_BACKDROP)
  backdrop:SetDimensions(dimensions[1], dimensions[2] + 10)  
  backdrop:SetAnchor(TOPLEFT, nil, TOPLEFT, -10, -10)
  backdrop:SetCenterColor( 0, 0, 0, 0.66 )
  backdrop:SetEdgeColor( 0, 0, 0, 0.4 )
  backdrop:SetEdgeTexture("",1 ,1 ,2 )
  backdrop:SetPixelRoundingEnabled(true) 
  backdrop:SetExcludeFromResizeToFitExtents(true)
  
  if ( onlyBox == false ) then
    local blueTitle = CreateControl(mainParent .. "TOP", mainParent2, CT_BACKDROP)
    blueTitle:SetDimensions(dimensions[1], 5)  
    blueTitle:SetAnchor(TOPLEFT, nil, TOPLEFT, -10, -10)
    blueTitle:SetCenterColor( _interface.getThemeColor(true)[1], _interface.getThemeColor(true)[2], _interface.getThemeColor(true)[3], 0.3 )
    blueTitle:SetEdgeColor( _interface.getThemeColor(true)[1], _interface.getThemeColor(true)[2], _interface.getThemeColor(true)[3], 0.3 )
    blueTitle:SetEdgeTexture("", 1 , 1 , 2)
    blueTitle:SetExcludeFromResizeToFitExtents(true)
    
    if (closeFunc) then
      local closeButton = CreateControl(mainParent .. "_Close", mainParent2, CT_TEXTURE)
      closeButton:SetAnchor(TOPLEFT, backdrop, TOPRIGHT, -45, 10)
      closeButton:SetDimensions(28, 28)
      closeButton:SetTexture("ShissuFramework/textures/close.dds")
      closeButton:SetMouseEnabled(true)
      closeButton:SetColor(_interface.getThemeColor())
      closeButton:SetDrawLayer(2)

      closeButton:SetHandler("OnMouseEnter", function(self) 
        self:SetColor(1,1,1,1)
      end)     
      closeButton:SetHandler("OnMouseExit", function(self) 
        self:SetColor(_interface.getThemeColor())
      end)  
      
      closeButton:SetHandler("OnMouseUp", closeFunc)  
    end

    if (GetWorldName() == "EU Megaserver") then
      local feedbackButton = CreateControl(mainParent .. "_Feedback", mainParent2, CT_TEXTURE)
      feedbackButton:SetAnchor(TOPLEFT, backdrop, TOPRIGHT, -85, 10)
      feedbackButton:SetDimensions(28, 28)
      feedbackButton:SetTexture("ShissuFramework/textures/button_sgt.dds")
      feedbackButton:SetMouseEnabled(true)
      feedbackButton:SetColor(_interface.getThemeColor())
      feedbackButton:SetDrawLayer(2)

      feedbackButton:SetHandler("OnMouseEnter", function(self) 
        self:SetColor(1,1,1,1)
        ZO_Tooltips_ShowTextTooltip(self, TOPRIGHT,  _L("DONATE"))
      end)     
      feedbackButton:SetHandler("OnMouseExit", function(self) 
        self:SetColor(_interface.getThemeColor())
        ZO_Tooltips_HideTextTooltip()
      end)  
      feedbackButton:SetHandler("OnMouseUp", function() 
        local function PrepareMail()
          MAIL_SEND.to:SetText("@Shissu")
          MAIL_SEND.subject:SetText("Shissu's DonateFee - Donation")
          MAIL_SEND.body:SetText("")
          MAIL_SEND:SetMoneyAttachmentMode()
          MAIL_SEND:AttachMoney(0, 1000)
        end

        MAIL_SEND:ClearFields()

        if (MAIL_SEND:IsHidden()) then
					MAIN_MENU_KEYBOARD:ShowScene("mailSend")
          SCENE_MANAGER:CallWhen("mailSend", SCENE_SHOWN, PrepareMail)
        else
          PrepareMail()
        end
      end)
    end

    -- Titel
    local titleLine = _interface.createLine("TitleLine", {dimensions[1] - 40, 1}, mainParent, mainParent2, TOPLEFT, 8, 35, nil)
    titleLine:SetDrawLayer(2)

    local titleLabel = WINDOW_MANAGER:CreateControl(mainParent .. "_Title", mainParent2, CT_LABEL)
    titleLabel:SetAnchor(TOPLEFT, mainParent2, TOPLEFT, 5, 0)
    titleLabel:SetDimensions(dimensions[1] - 40, 32)
    titleLabel:SetHidden(false)
    titleLabel:SetFont('SF_LINEFONT')
    titleLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT) 
    titleLabel:SetText(title)
  end
end

function _interface.createLine(name, dimensions, mainParent, mainParent2, anchorPos, anchorX, anchorY, anchor2, color, vert)
  local control = CreateControl(mainParent .. "_" .. name, mainParent2, CT_TEXTURE) 
  control:SetTexture("ShissuFramework/textures/horizontal.dds")
  control:SetAnchor(anchorPos, mainParent2, anchorPos, anchorX, anchorY)
  control:SetHidden(false) 
    
  if (anchor2 == nil) then
    control:SetDimensions(dimensions[1], dimensions[2])
  end
  
  if (anchor2) then
    control:SetAnchor(anchor2[1], mainParent2, anchor2[1], anchor2[2], anchor2[3])
    control:SetWidth(dimensions[2])
  end
  
  if (vert) then
    control:SetTexture("ShissuFramework/textures/vertikal.dds")
  end

  control:SetColor(_interface.getThemeColor())
  
  if (color) then
    control:SetColor(color[1], color[2], color[3], 1) 
  end
                                                                      
  return control
end

function _interface.createFlatButton(name, parent, parentPos, dimensions, text, parentAnchor, color)
  if parentAnchor == nil then parentAnchor = BOTTOMLEFT end 
  if color == nil then color = _interface.getThemeColor(true) end
  
  local control = WINDOW_MANAGER:CreateControl(name, parent, CT_TEXTURE)
  control:SetAnchor(parentAnchor, parent, parentAnchor, parentPos[1], parentPos[2])
  control:SetDimensions(dimensions[1], dimensions[2])
  control:SetTexture("ShissuFramework/textures/button.dds")
  control:SetHidden(false)
  control:SetMouseEnabled(true)
  control:SetDrawLayer(1)
  
  control:SetHandler("OnMouseEnter", function(self) 
    self:SetColor(color[1],color[2],color[3], 1)
  end) 
  
  control:SetHandler("OnMouseExit", function(self) 
    self:SetColor(1, 1, 1, 1)   
  end) 
  
  control.label = WINDOW_MANAGER:CreateControl(name .. "_LABEL", parent, CT_LABEL)
  local label = control.label
  label:SetAnchor(parentAnchor, parent, parentAnchor, parentPos[1], parentPos[2]+4)
  label:SetDimensions(dimensions[1], dimensions[2])
  label:SetHidden(false)
  label:SetFont('SF_BUTTONFONT')
  label:SetHorizontalAlignment(TEXT_ALIGN_CENTER) 
  label:SetText(text)
  label:SetColor(color[1],color[2],color[3], 1)
  
  return control 
end

-- MISC Interface Elements...
function _interface.checkBoxLabel(control, var)
  local ESOIcons = {
    Online = GetPlayerStatusIcon(PLAYER_STATUS_ONLINE),
    Offline = GetPlayerStatusIcon(PLAYER_STATUS_OFFLINE),
    Aldmeri = GetAllianceSymbolIcon(ALLIANCE_ALDMERI_DOMINION),
    Ebonheart = GetAllianceSymbolIcon(ALLIANCE_EBONHEART_PACT),
    Daggerfall = GetAllianceSymbolIcon(ALLIANCE_DAGGERFALL_COVENANT),    
    Gold = "/esoui/art/guild/guild_tradinghouseaccess.dds",
    Item = "/esoui/art/guild/guild_bankaccess.dds",
  }
  
  ZO_CheckButton_SetChecked(control)
  ZO_CheckButton_SetLabelText(control, zo_iconFormat(ESOIcons[var], 24, 24))
end

function _interface.createLabel(name, anchor, text, dimension, offset, hidden, pos, font)
  if(not text) then text = "" end
  if(not dimension) or dimension == 0 then dimension = {100, 30} end
  if(not offset) then offset = {0, 0} end
  if (hidden == nil) then hidden = true end
  if(not pos) then pos = RIGHT end
  if(not font) then font = "ZoFontGame" end
  
  local control = WINDOW_MANAGER:CreateControl(name, anchor, CT_LABEL)
  
  control:SetFont(font)
  control:SetDimensions(dimension[1], dimension[2])
  control:SetAnchor(LEFT, anchor, pos, offset[1], offset[2])
  control:SetText(stdColor .. text)
  control:SetVerticalAlignment(LEFT)
  control:SetHidden(hidden)

  return control
end

function _interface.createZOButton(name, text, width, offsetX, offsetY, anchor)
  local button = CreateControlFromVirtual(name, anchor, "ZO_DefaultTextButton")
  button:SetText(text)
  button:SetAnchor(TOPLEFT, anchor, TOPLEFT, offsetX, offsetY)
  button:SetWidth(width)
   
  return button
end

function _interface.setDefaultColor(control) 
  if (control == nil) then return end
  control:SetColor(_interface.getThemeColor())  
end

function _interface.saveWindowPosition(control, settings)
  control:SetHandler("OnReceiveDrag", function(self) self:StartMoving() end)
  control:SetHandler("OnMouseUp", function(self)
    self:StopMovingOrResizing()
    local _, point, _, relativePoint, offsetX, offsetY = self:GetAnchor()
    
    if settings == nil then settings = {} end

    settings.offsetX = offsetX
    settings.offsetY = offsetY
    settings.point = point
    settings.relativePoint = relativePoint
  end)
end

function _interface.getWindowPosition(control, settings)
  if settings == nil then return end

  control:ClearAnchors()
  control:SetAnchor(settings.point, parent, settings.relativePoint, settings.offsetX, settings.offsetY)
end

---- NOTEBOOK
function _interface.createScrollContainer(name, width, parent, parent2, offsetX, offsetY, offsetY2)
  local control = WINDOW_MANAGER:CreateControlFromVirtual(name, parent, "ZO_ScrollContainer")
  control:SetAnchor(TOPLEFT, parent2, BOTTOMLEFT, offsetX, offsetY)
  control:SetAnchor(BOTTOMLEFT, parent, BOTTOMLEFT, offsetX, offsetY2)
  control:SetWidth(width)
  control.scrollChild = control:GetNamedChild("ScrollChild")
  
  return control
end

function _interface.createCloseButton(name, parent, func)
  local control = WINDOW_MANAGER:CreateControl(name, parent, CT_TEXTURE)
  control:SetAnchor(TOPLEFT, parent, TOPRIGHT, -35, 2)
  control:SetDimensions(28, 28)
  control:SetTexture("ESOUI/art/buttons/decline_up.dds")
  control:SetMouseEnabled(true)
  control:SetHandler("OnMouseEnter", function(self) _lib.setDefaultColor(self) end)     
  control:SetHandler("OnMouseExit", function(self) self:SetColor(1,1,1,1) end)  
  control:SetHandler("OnMouseUp", func) 
  
  return control 
end

function _interface.createBlueLine(name, parent, parent2, offsetX, offsetY)   
  if offsetY ~= nil then offsetY = 0 end
  
  local control = WINDOW_MANAGER:CreateControl(name, parent, CT_TEXTURE)
  control:SetAnchor(TOPLEFT, parent2, TOPRIGHT, offsetX, offsetY)
  control:SetAnchor(BOTTOMLEFT, parent, BOTTOMLEFT, offsetX, offsetY)
  control:SetWidth(3)
  control:SetTexture("EsoUI\\Art\\Miscellaneous\\window_edge.dds")
  _lib.setDefaultColor(control)
  
  return control
end

function _interface.createBackdropBackground(mainParent, mainParent2, dimensions, tex)
  if (tex == nil) then tex = "" end
  
  local control = CreateControl(mainParent .. "_BG", mainParent2, CT_TEXTURE)
	control:SetTexture("ShissuFramework/textures/backdrop" .. tex .. ".dds")
	control:SetDimensions(dimensions[1], dimensions[2])  
	control:SetAnchor(TOPLEFT, mainParent2, TOPLEFT, 0, 0)
	control:SetDrawLayer(1)
	--control:SetExcludeFromResizeToFitExtents(true)        
end

function _interface.createColorButton(controlName, parent, colorNumber, XY, buttonLabel, editBox)
  if ( XY == nil ) then XY = {40, 0} end
  
  local color = { 1, 1, 1, 1 }

  if ( colorNumber ~= nil and shissuColor ~= nil ) then
    color = shissuColor["c" .. colorNumber]
  end 

  local control = CreateControl(buttonLabel .. controlName, parent, CT_TEXTURE)  
  control:SetAnchor(TOPRIGHT, parent, TOPRIGHT, XY[1], XY[2])
  control:SetDimensions(30, 20)
  control:SetMouseEnabled(true)
  control:SetColor(color[1], color[2], color[3], color[4])  
  control:SetDrawLevel(100)
  
  if (controlName == "ANY" ) then
    control.label = CreateControl(nil, control, CT_LABEL)
    control.label:SetFont("ZoFontGame")     
    control.label:SetAnchor(TOPLEFT, control, TOPLEFT, 100, -3)
    control.label:SetText("|c000000  ?")
  	control.label:SetWidth(20)  
    control.label:SetAnchor(TOPLEFT)
  end
   
  local ZOS_BUTTON = ESO_Dialogs.COLOR_PICKER["buttons"][1].callback  

  control:SetHandler("OnMouseUp", function()        
    local color =  string.gsub(control:GetName(), buttonLabel, "")   
    local cache = editBox:GetText()

    if color == "ANY" then
      ESO_Dialogs.COLOR_PICKER["buttons"][1].callback = function(self)
        local r, g, b = COLOR_PICKER.colorSelect:GetColorAsRGB()
        local htmlString = ShissuFramework["func"].RGBtoHex(r, g, b)

        editBox:SetText(cache .. htmlString .. _L("TEXT") .. "|r")
        ESO_Dialogs.COLOR_PICKER["buttons"][1].callback = ZOS_BUTTON
      end       
                                                            
      COLOR_PICKER:Show()      
    else     
      if ( color == "W" ) then            
        color = "|ceeeeee"
      else
        if (shissuColor == nil) then 
          color = "|ceeeeee" 
        end

        color =  ShissuFramework["func"].RGBtoHex(shissuColor["c" .. color][1], shissuColor["c" .. color][2], shissuColor["c" .. color][3])
      end
      
      editBox:SetText(cache .. color .. _L("TEXT") .. "|r")        
    end
  end)
  
  return control
end

function _interface.getColor(color)
  if (shissuColor == nil) then 
    return "|ceeeeee" 
  end

  return "|c" .. ShissuFramework["func"].RGBtoHex2(shissuColor["c" .. color][1], shissuColor["c" .. color][2], shissuColor["c" .. color][3])
end

-- CHATBOX Button
-- Initialize ChatButton
-- /script ShissuFramework["interface"].initChatButton()
function _interface.initChatButton()
  if (SGT_Notebook or ShissuTeleporter) then
    ZO_ChatWindowOptions:SetAnchor(TOPRIGHT, ZO_ChatWindow, TOPRIGHT, -50, 6 )
    SGT_ZO_ToogleButton:SetParent(ZO_ChatWindowOptions:GetParent() )

    local buttonText = ""
      
    if (SGT_Notebook ~= nil) then
      buttonText = stdColor .. _L("LEFT") .. white .. " - " .. "Notizbuch"
    end
      
    if (ShissuTeleporter ~= nil) then                                                                  
      if (string.len(buttonText) > 2) then
        buttonText = buttonText .. "\n"
      end
        
      buttonText = buttonText .. stdColor .. _L("RIGHT") .. white .. " - " .. "Teleporter"
    end

    if (string.len(buttonText) > 2) then
      SGT_ZO_ToogleButton:SetHandler("OnMouseEnter", function() 
        ZO_Tooltips_ShowTextTooltip(SGT_ZO_ToogleButton, TOPRIGHT, white .. " " .. buttonText)
      end)
      
      SGT_ZO_ToogleButton:SetHandler("OnMouseExit", ZO_Tooltips_HideTextTooltip)
      SGT_ZO_ToogleButton:SetHandler("OnMouseUp", function(_, button) _interface.chatButton(button) end)
    end
  end
end

function _interface.chatButton(button)
   if (button == 1) then
    if (SGT_Notebook) then
      if (SGT_Notebook:IsHidden()) then
        SGT_Notebook:SetHidden(false)
        
        if (  SGT_Notebook_Color1g ~= nil ) then
          SGT_Notebook_Color1:SetColor(shissuColor["c1"][1], shissuColor["c1"][2], shissuColor["c1"][3], shissuColor["c1"][4])  
          SGT_Notebook_Color2:SetColor(shissuColor["c2"][1], shissuColor["c2"][2], shissuColor["c2"][3], shissuColor["c2"][4])  
          SGT_Notebook_Color3:SetColor(shissuColor["c3"][1], shissuColor["c3"][2], shissuColor["c3"][3], shissuColor["c3"][4])  
          SGT_Notebook_Color4:SetColor(shissuColor["c4"][1], shissuColor["c4"][2], shissuColor["c4"][3], shissuColor["c4"][4])  
          SGT_Notebook_Color5:SetColor(shissuColor["c5"][1], shissuColor["c5"][2], shissuColor["c5"][3], shissuColor["c5"][4])  
        end


        if (SGT_Notebook_MessagesRecipient) then
          SGT_Notebook_MessagesRecipient:SetHidden(false)
        end
      else
        SGT_Notebook:SetHidden(true)
        
        if (SGT_Notebook_MessagesRecipient) then
          SGT_Notebook_MessagesRecipient:SetHidden(true)
        end
      end
    end
   elseif (button == 2) then
    if (ShissuTeleporter) then
      if (ShissuTeleporter:IsHidden()) then
        ShissuTeleporter:SetHidden(false)
      else
        ShissuTeleporter:SetHidden(true)
      end
    end
  end  
end

ShissuFramework["interface"] = _interface