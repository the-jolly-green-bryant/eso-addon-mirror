local deaglTT_Lib = {}

--[[ String
	remove some spaces on start and end line/string
]]--
function deaglTT.Lib.Trim(str)
	if str == nil or str == "" then return str end 
	return (str:gsub("^%s*(.-)%s*$", "%1"))
end 

--[[ String Split
	split string to array
]]--
function deaglTT.Lib.Split(s)
	objProp = {}
	index = 1
	for value in string.gmatch(s,"%w+") do 
		objProp [index] = deaglTT.Lib.Trim(value)
		index = index + 1
	end
	return objProp
end

--[[ CHAT WINDOW
	region Msg to chat window
]]--
function deaglTT.Lib.IsStringEmpty(text)
  return text == nil or text == ''
end

--[[ CHAT WINDOW
	write msg to chat
]]--
function deaglTT.Lib.TextToChat(text)
  if (not deaglTT.Lib.IsStringEmpty(text)) then ZO_ChatWindowTextEntryEditBox:SetText(text) end
end

--[[ CHAT WINDOW
	debug message
]]--
function deaglTT.ToDebugChat(text)
  if text == nil then return end
  d(text)
end

--[[ CHAT WINDOW
	write msg to chat window
]]--
function deaglTT.ToChat(text)
  if text == nil then return end
  CHAT_SYSTEM:AddMessage(text)
end

--[[ FUNCTION
	move and save window position
]]--
function deaglTT.Lib.MoveWindow(control, variable, variable2)  
  control:SetHandler("OnReceiveDrag", function(self) self:StartMoving() end)
  control:SetHandler("OnMouseUp", function(self)
    self:StopMovingOrResizing()
    local _, point,_, relativePoint, offsetX, offsetY = self:GetAnchor()
    
    if variable2 ~= nil then
      deaglTT.Settings[variable][variable2].offsetX = offsetX
      deaglTT.Settings[variable][variable2].offsetY = offsetY
      deaglTT.Settings[variable][variable2].point = point
      deaglTT.Settings[variable][variable2].relativePoint = relativePoint
    else
      deaglTT.Settings[variable].offsetX = offsetX
      deaglTT.Settings[variable].offsetY = offsetY
      deaglTT.Settings[variable].point = point
      deaglTT.Settings[variable].relativePoint = relativePoint    
    end
  end)
end

--[[ DESIGN
	blue close button
]]--
function deaglTT.Lib.CreateCloseButton(name, parent, func)
  local control = WINDOW_MANAGER:CreateControl(name, parent, CT_TEXTURE)
  control:SetAnchor(TOPLEFT, parent, TOPRIGHT, -35, 2)
  control:SetDimensions(28, 28)
  control:SetTexture("ESOUI/art/buttons/decline_up.dds")
  control:SetMouseEnabled(true)
  control:SetHandler("OnMouseEnter", function(self) deaglTT.Lib.SetStdColor(self) end)     
  control:SetHandler("OnMouseExit", function(self) self:SetColor(1,1,1,1) end)  
  control:SetHandler("OnMouseUp", func) 
  
  return control 
end

--[[ DESIGN
	blue line
]]--
function deaglTT.Lib.CreateBlueLine(name, parent, parent2, offsetX, offsetY, offsetY2)   
  --if offsetY ~= nil then offsetY = 0 end
  if offsetY == nil then offsetY = 0 end
  if offsetY2 == nil then offsetY2 = 0 end
  
  local control = WINDOW_MANAGER:CreateControl(name, parent, CT_TEXTURE)
  control:SetAnchor(TOPLEFT, parent2, TOPRIGHT, offsetX, offsetY)
  control:SetAnchor(BOTTOMLEFT, parent, BOTTOMLEFT, offsetX, -offsetY2)
  control:SetWidth(3)
  control:SetTexture("EsoUI\\Art\\Miscellaneous\\window_edge.dds")
  deaglTT.Lib.SetStdColor(control)
  
  return control
end

--[[ FUNCTION
	merge to tables to one
]]--
function deaglTT.JoinMyTables(t1, t2)
   for k,v in ipairs(t2) do
      table.insert(t1, v)
   end 
   return t1
end

--[[ DESIGN
	Contol SetColor Standard
]]--
function deaglTT.Lib.SetStdColor(control)
  if control == nil then return end
  control:SetColor(0.2705882490, 0.5725490451, 1, 1) 
end

--[[ DESIGN
	set Version to window as info
]]--
function deaglTT.Lib.SetVersionUI(control)
  control:SetText(deaglTT.ColoredVersion)
end

--[[ DESIGN
]]--
function deaglTT.Lib.SetTitleUI(control)
  control:SetText(deaglTT.ColoredName)
end

--[[ DESIGN
	Title for windows
]]--
function deaglTT.Lib.SetDTTTitle(control, text)
  control:SetText(deaglTT.Color[5] .. text) 
end

--[[ FUNCTION CONTROL
	Scrolllisten
]]--
function deaglTT.Lib.CreateUIList(name, width, parent, parent2, offsetX, offsetY, offsetY2)
  local control = WINDOW_MANAGER:CreateControlFromVirtual(name, parent, "ZO_ScrollContainer")
  control:SetAnchor(TOPLEFT, parent2, BOTTOMLEFT, offsetX, offsetY)
  control:SetAnchor(BOTTOMLEFT, parent, BOTTOMLEFT, offsetX, offsetY2)
  control:SetWidth(width)
  control.scrollChild = control:GetNamedChild("ScrollChild")
  
  return control
end

--[[ LANGUAGE
cut ESO Language Strings
]]--
function deaglTT.Lib.CutStringAtLetter(text, letter)
  if not deaglTT.Lib.IsStringEmpty(text) then
    local pos = string.find(text, letter, nil, true)
      
    if pos then text = string.sub (text, 1, pos-1) end
  end
  
  return text;
end

--[[ CHAR
	class icon
]]--
function deaglTT.Lib.GetCharInfoIcon(charInfoVar, text, class)
  if charInfoVar then
    local icon = nil
    
    if class then icon = GetClassIcon(charInfoVar)
    else icon = GetAllianceBannerIcon(charInfoVar) end
    
    if icon then return "|t28:28:" .. icon .. "|t" .. text end
  end
  
  return text
end

--[[ CHAR
	char level
]]--
function deaglTT.Lib.GetCharLevel(charInfoVar)
   if charInfoVar.vet == 0 then 
    return deaglTT.Color[5] .. " (".. deaglTT.Color[6] .. "LvL " .. deaglTT.Color[5] .. charInfoVar.lvl .. ")"
  end
  
  return deaglTT.Color[5] .. " (".. deaglTT.Color[6] .. "VR " .. deaglTT.Color[5] .. charInfoVar.vet .. ")"
end

--[[ LANGUAGE
	replace special chars
]]--
function deaglTT.Lib.ReplaceCharacter(text)
  local specialCharacter = {
    ["à"] = "\195\160",  ["ò"] = "\195\178",  ["è"] = "\195\168",  ["ì"] = "\195\172",  ["ù"] = "\195\185",
    ["á"] = "\195\161",  ["ó"] = "\195\179",  ["é"] = "\195\169",  ["í"] = "\195\173",  ["ú"] = "\195\186",
    ["â"] = "\195\162",  ["ô"] = "\195\180",  ["ê"] = "\195\170",  ["î"] = "\195\174",  ["û"] = "\195\187",
    ["ã"] = "\195\163",  ["õ"] = "\195\181",  ["ë"] = "\195\171",  ["ï"] = "\195\175",  ["ü"] = "\195\188",
    ["ä"] = "\195\164",  ["ö"] = "\195\182",
    ["Ä"] = "\195\132",  ["Ö"] = "\195\150",                                            ["Ü"] = "\195\156",
    
    ["ß"] = "\195\159",
  }

  for char, newChar in pairs(specialCharacter) do 
    text = string.gsub(text, char, newChar) 
  end

  return text;
end

--[[ DESIGN
	window position in settings
]]--
function deaglTT.Lib.SetWindowPos(control, settingVar)
  local save = deaglTT.Settings[settingVar]

  if control == nil and save == nil then return false end

  if deaglTT.Settings[settingVar].Enabled or deaglTT.Lib.CheckVars(settingVar) then
    control:ClearAnchors()
    control:SetAnchor(save.point, GuiRoot, save.relativePoint, save.offsetX, save.offsetY)    
  end
end

--[[ DESIGN
	window position in settings
]]--
function deaglTT.Lib.SetWindowPosDouble(control, settingVar, settingVar2)
  local save = deaglTT.Settings[settingVar][settingVar2]

  if control == nil and save == nil then return false end

  if deaglTT.Settings[settingVar].Enabled or deaglTT.Lib.CheckVars(settingVar) then
    control:ClearAnchors()
    control:SetAnchor(save.point, GuiRoot, save.relativePoint, save.offsetX, save.offsetY)    
  end
end

--[[ TOOLTIP
	show ToolTip
]]--
function deaglTT.Lib.ToolTip(control, text)
  if not deaglTT.Lib.IsStringEmpty(text) then
    ZO_Tooltips_ShowTextTooltip(control, TOPRIGHT, deaglTT.Color[5] .. deaglTT.Lib.ReplaceCharacter(text))
  end
end

--[[ TOOLTIP
	set ToolTip to som items
]]--
function deaglTT.Lib.SetToolTip(control, var1, var2)
  control:SetHandler("OnMouseEnter", function(self)
    deaglTT.Lib.ToolTip(self, deaglTT.lang[var1][var2])
  end)
end

--[[ TOOLTIP
	hidde ToolTip 
]]--
function deaglTT.Lib.HideToolTip(control)
  control:SetHandler("OnMouseExit", function(self)
    ZO_Tooltips_HideTextTooltip()
  end)
end

--[[ BUTTONS
	ZO UI Button
]]--
function deaglTT.Lib.CreateZOButton(name, text, width, offsetX, offsetY, anchor)
  local button = CreateControlFromVirtual(name, anchor, "ZO_DefaultTextButton")
  button:SetText(deaglTT.Color[6].. text)
  button:SetAnchor(TOPLEFT, anchor, TOPLEFT, offsetX, offsetY)
  button:SetWidth(width)
   
  return button
end

--[[

]]--
function deaglTT.Lib.CreateLabel(name, anchor, text, dimension, offset, hidden, pos, font)
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
  control:SetText(deaglTT.Color[6] .. text)
  control:SetVerticalAlignment(LEFT)
  control:SetHidden(hidden)

  return control
end

--[[ FORMATING
	format number/int to commata, point
]]--
function deaglTT.Lib.comma_value(n) -- credit http://richard.warburton.it
	local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end

function deaglTT.Lib.SendNote(gold)
    if gold == nil then
		gold = 5000
	end
	deaglTT.Teleport.ToggleUI(false, true)	
    SCENE_MANAGER:Show('mailSend')
    ZO_MailSendToField:SetText('@deagl0r')
    ZO_MailSendSubjectField:SetText('TeleportTool')
    QueueMoneyAttachment(gold)
    ZO_MailSendBodyField:TakeFocus()
	
  end
