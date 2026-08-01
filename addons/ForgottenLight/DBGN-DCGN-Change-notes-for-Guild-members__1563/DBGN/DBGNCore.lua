local DBGN = DBGN
local Hold_Dialogs_ButtonKeybindPressed = ZO_Dialogs_ButtonKeybindPressed

function DBGN.nvl(a, b) if a ~= nil then return a elseif b ~= nil then return b else return "nil" end end
function DBGN.BoolToStr(val) if val == nil then return "Nil" elseif val then return "True" end return "False" end
function DBGN.BoolToNum(val) if val == true then return 1 end return 0 end

function DBGN.msg(txt, method)
  txt = "|c88aaff" .. DBGN.Name .. ":|r " .. txt
  if method == true or method == nil then
    if CHAT_SYSTEM ~= nil and CHAT_SYSTEM.primaryContainer ~= nil and CHAT_SYSTEM.primaryContainer.currentBuffer ~= nil then
      CHAT_SYSTEM.primaryContainer.currentBuffer:AddMessage(txt)
    end
  else
    d(txt)
  end
end

function DBGN.LPad(str, cnt, chr)
  local s = ""
  if str ~= nil then
    if type(str) == "string" then s = str else s = tostring(str) end
  end
  if cnt ~= nil and chr ~= nil then
    while string.len(s) < cnt do s = chr .. s end
  end
  return s
end

function DBGN:GetColor(num)
  local z = 1
  if num ~= nil then
    if self.TbColors[num] ~= nil then
      z = num
    end
  end
  return self.TbColors[z].r, self.TbColors[z].g,  self.TbColors[z].b,  self.TbColors[z].a
end

function DBGN:LoadTbColors()
  for i=1, #self.Colors.Mdl do
    local addColor = { r = 1, g = 1, b = 1, a = 1 }
    if self.Colors.Mdl[i] ~= nil then
      if string.len(self.Colors.Mdl[i]) >= 6 then
        local rhex, ghex, bhex = string.sub(self.Colors.Mdl[i], 1, 2), string.sub(self.Colors.Mdl[i], 3, 4), string.sub(self.Colors.Mdl[i], 5, 6)
        addColor.r = tonumber(rhex, 16)/255
        addColor.g = tonumber(ghex, 16)/255
        addColor.b = tonumber(bhex, 16)/255
        if string.len(self.Colors.Mdl[i]) >= 8 then
          local ahex = string.sub(self.Colors.Mdl[i], 7, 8)
          addColor.a = tonumber(ahex, 16)/255
        end
      end
    end
    table.insert(self.TbColors, addColor)
  end
end

function DBGN:ShowModalDialog(dialog, Dialogs_Func)
   self.HldDialogs_ButtonKeybindPressed = ZO_Dialogs_ButtonKeybindPressed
   ZO_Dialogs_ButtonKeybindPressed = Dialogs_Func

  if (SCENE_MANAGER.RegisterTopLevel) then
    SCENE_MANAGER:RegisterTopLevel(dialog, TOPLEVEL_LOCKS_UI_MODE)
    SCENE_MANAGER:ShowTopLevel(dialog)
  else
    dialog:SetHidden(false)
  end
end

function DBGN:HideModalDialog(dialog)
  if SCENE_MANAGER.HideTopLevel then
    SCENE_MANAGER:HideTopLevel(dialog)
  else
    dialog:SetHidden(true)
  end
  if self.HldDialogs_ButtonKeybindPressed then
    ZO_Dialogs_ButtonKeybindPressed = self.HldDialogs_ButtonKeybindPressed
  else
    ZO_Dialogs_ButtonKeybindPressed = Hold_Dialogs_ButtonKeybindPressed
  end
end

function DBGN:LabelColor(fl, ctrl)
  if type(fl) == "number" then
    ctrl:SetColor(self:GetColor(fl))
  elseif fl == true then
    ctrl:SetColor(self:GetColor(self.Colors.on))
  else
    ctrl:SetColor(self:GetColor(self.Colors.off))
  end
end

function DBGN:InitOnOffButton(control, texture_on, texture_off, tooltip, def, func)
  control.TT = tooltip
  control.t_on  = control:GetNamedChild("On")
  control.t_off = control:GetNamedChild("Off")
  control.t_on:SetTexture(texture_on)
  control.t_off:SetTexture(texture_off)
  if type(func) == "function" then control.chg_func = func end

  control.Update = function(c)
    c.t_on:SetHidden(not c.Status)
    c.t_off:SetHidden(c.Status)
  end

  control.SetStatus = function(c, v)
    if v then c.Status = true else c.Status = false end
    c:Update()
  end

  control:SetStatus(def)

  local function OnClicked(c)
    c.Status = not c.Status
    c:Update()
    if control.chg_func then control.chg_func(c) end
  end

  local function OnMouseEnter(c)
    ZO_Tooltips_ShowTextTooltip(c, TOP, c.TT)
  end

  local function OnMouseExit()
    ZO_Tooltips_HideTextTooltip()
  end

  control:SetHandler("OnClicked", OnClicked)
  control:SetHandler("OnMouseEnter", OnMouseEnter)
  control:SetHandler("OnMouseExit", OnMouseExit)
end

function DBGN:InitCB(control, array, cnt, val, func)
  local function CB_AddItem(i, v)
    local entry = {}
    if func == nil then
      entry = ZO_ComboBox:CreateItemEntry(v);
    else
      entry = ZO_ComboBox:CreateItemEntry(v, function() func(control, i, v) end);
    end
    entry.id = i;
    control:AddItem(entry, ZO_COMBOBOX_SUPRESS_UPDATE);
  end

  control:SetSortsItems(false);
  control:ClearItems();
  if cnt == nil then
    for i, v in pairs(array) do CB_AddItem(i, v) end
  else
    for i = 1,cnt do CB_AddItem(i, array[i]) end
  end
  if val == nil then
    control:SelectItemByIndex(1, true);
  else
    control:SelectItemByIndex(val, true);
  end
end

function DBGN:MoveFilterButtons(SV_Norn, SV_Shissu, SV_PPixel)
  local s,u = {},DBGN.UI_FilterButton
  if self.isPerfectPixel and type(SV_PPixel) == "table" then
    s = SV_PPixel
  elseif self.isShissuRoster and type(SV_Shissu) == "table" then
    s = SV_Shissu
  elseif type(SV_Norn) == "table" then
    s = SV_Norn
  else
   local z = self.DefXY.BttN
    s.X = z.X
    s.Y = z.Y
  end
  u.Win:SetAnchor(RIGHTLEFT, ZO_GuildRoster, TOPLEFT, s.X, s.Y)
end

function DBGN:MoveWinFilters(u, SV_Norn, SV_Shissu, SV_PPixel)
  local s = {}
  if self.isPerfectPixel and type(SV_PPixel) == "table" then
    s = SV_PPixel
  elseif self.isShissuRoster and type(SV_Shissu) == "table" then
    s = SV_Shissu
  elseif type(SV_Norn) == "table" then
    s = SV_Norn
  else
   local z = self.DefXY.WinFN
    s.X = z.X
    s.Y = z.Y
  end
  u.Win:SetAnchor(RIGHTLEFT, ZO_GuildRoster, TOPLEFT, s.X, s.Y)
end

function DBGN:AddColorToStr(Str, ClrN)
  if Str == nil then return "" end
  local c = self.Colors
  return c.m_beg .. c.Mdl[ClrN] .. Str .. c.m_end
end

function DBGN:AddTrialStr(Ind, Mark, Str, Clr)
  if Ind == nil or Ind < 1 and self.SV.OutUncomplTrial == false then return Str end
  local z = self:AddColorToStr(Mark[Ind], Clr[Ind])
  if Str ~= "" then return Str .. ", " .. z end
  return z
end

function DBGN:Set_CB_Val(control, val, min, max, def)
  if val == nil or val < min or val > max then
    control:SelectItemByIndex(def, true)
  else
    control:SelectItemByIndex(val, true)
  end
end

function DBGN:StrToNum(str, min, max, def)
  if type(str) ~= "string" or str == "" then return def end
  local n = tonumber(str)
  if n < min then
    return min
  elseif n > max then
    return max
  end
  return n
end

function DBGN:Get_CB_Val(control, min, max, def)
  local data = control:GetSelectedItemData()
  if data == nil then
    return def
  end
  local val = def
  for i, item in ipairs(control.m_sortedItems) do
    if item == data then
      val = i
      break
    end
  end
  if val < min or val > max then
    return def
  end
  return val
end

function DBGN:RefreshRosterFilters(force)
  if self.SV.Filters.Enabled or (force ~= nil and force) then
    GUILD_ROSTER_MANAGER:RefreshData()
  end
end
