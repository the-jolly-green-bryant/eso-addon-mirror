function DressingRoom:ToggleWindow()
  DressingRoomWin:ToggleHidden()
  SetGameCameraUIMode(not DressingRoomWin:IsHidden())
end


local function getBindingName(keyStr)
  local layIdx, catIdx, actIdx = GetActionIndicesFromName(keyStr)
  local keyCode = GetActionBindingInfo(layIdx, catIdx, actIdx, 1)
	if layIdx and keyCode > 0 then return GetKeyName(keyCode)
	else return '' end
end

local function CreateButton(name)
	local c = WINDOW_MANAGER:CreateControl(name, DressingRoomWin, CT_BUTTON)
	local b = WINDOW_MANAGER:CreateControl(name.."_BG", c, CT_BACKDROP)

	c:SetMouseEnabled(true)
	c:SetState(BSTATE_NORMAL)
	c:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
	c:SetVerticalAlignment(TEXT_ALIGN_CENTER)
	c:SetFont("$(MEDIUM_FONT)|"..DressingRoom.sv.options.fontSize)
	c:SetHandler("OnMouseEnter", function(self)
      if self.text then ZO_Tooltips_ShowTextTooltip(self, RIGHT, self.text) end
      b:SetCenterColor(1, 0.73, 0.35, 0.25)
      b:SetEdgeColor(1, 0.73, 0.35, 1)
    end)
	c:SetHandler("OnMouseExit",function(self)
      ZO_Tooltips_HideTextTooltip()
      b:SetCenterColor(1, 0.73, 0.35, 0.05)
      b:SetEdgeColor(0.7, 0.7, 0.6, 1)
    end)
	c:SetNormalTexture("ESOUI/art/mainmenu/menubar_skills_up.dds")
	c:SetMouseOverTexture("ESOUI/art/mainmenu/menubar_skills_over.dds")

  b:SetAnchorFill()
	b:SetEdgeTexture("", 1, 1, 1)
	b:SetCenterColor(1, 0.73, 0.35, 0.05)
	b:SetEdgeColor(0.7, 0.7, 0.6, 1)

	return c
end

local function CreateSetLabel(setId)
	local b = WINDOW_MANAGER:CreateControl("DressingRoom_SetLabel_BG_"..setId, DressingRoomWin, CT_BACKDROP)
	local c = WINDOW_MANAGER:CreateControl("DressingRoom_SetLabel_"..setId, b, CT_LABEL)
  local e = WINDOW_MANAGER:CreateControlFromVirtual("DressingRoom_Editbox_"..setId, b, "ZO_DefaultEditForBackdrop")
  local keep

	b:SetEdgeTexture("", 1, 1, 1)
	b:SetCenterColor(1, 0.73, 0.35, 0.05)
	b:SetEdgeColor(0.7, 0.7, 0.6, 1)

  c:SetAnchorFill()
	c:SetMouseEnabled(true)
	c:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
	c:SetVerticalAlignment(TEXT_ALIGN_CENTER)
  c:SetColor(1, 0.73, 0.35, 1)
  c:SetHandler("OnMouseEnter", function(self)
      if self.text then ZO_Tooltips_ShowTextTooltip(self, RIGHT, self.text) end
    end)
  c:SetHandler("OnMouseExit", function(self) ZO_Tooltips_HideTextTooltip() end)
  c:SetHandler("OnMouseDown", function(self)
    e:SetText(self:GetText())
    c:SetHidden(true)
    e:SetHidden(false)
    keep = true
    e:TakeFocus()
  end)

--  e:SetAnchorFill()
  e:SetColor(1, 0.73, 0.35, 1)
  e:SetMaxInputChars(200)
  e:SetHidden(true)
  e:SetHandler("OnFocusLost", function ()
    if keep then
      local txt = e:GetText()
      if txt == "" then
        DressingRoom.sv.page.pages[DressingRoom.sv.page.current].customSetName[setId] = nil
        local gearSet = DressingRoom.sv.page.pages[DressingRoom.sv.page.current].gearSet[setId]
        c:SetText(gearSet and gearSet.name)
      else
        DressingRoom.sv.page.pages[DressingRoom.sv.page.current].customSetName[setId] = txt
        c:SetText(txt)
      end
    end
    e:SetHidden(true)
    c:SetHidden(false)
  end)
	e:SetHandler("OnEscape", function() keep = false e:LoseFocus() end)

  c.bg = b
  c.editbox = e
	return c
end

local function CreatePageTitle()
  local c = WINDOW_MANAGER:CreateControl("DressingRoomWin_Page", DressingRoomWin, CT_LABEL)
  local e = WINDOW_MANAGER:CreateControlFromVirtual("DressingRoomWin_Page_Edit", DressingRoomWin, "ZO_DefaultEditForBackdrop")
  local keep

  c:SetMouseEnabled(true)
  c:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
  c:SetVerticalAlignment(TEXT_ALIGN_CENTER)

  c:SetFont("ZoFontWinH3")
  c:SetColor(1, 1, 1, 1)

  c:SetHandler("OnMouseDown", function(self)
    e:SetText(DressingRoom.sv.page.pages[DressingRoom.sv.page.current].name)
    c:SetHidden(true)
    e:SetHidden(false)
    keep = true
    e:TakeFocus()
  end)

  e:SetMaxInputChars(30)
  e:SetHidden(true)

  e:SetFont("ZoFontWinH3")
  e:SetColor(1, 1, 1, 1)
  e:SetAnchor(TOPLEFT, c, TOPLEFT, 0, 0)

  e:SetHandler("OnFocusLost", function ()
    if keep then
      local txt = e:GetText()
      if txt == "" then txt = GetUnitZone("player") end
      DressingRoom.sv.page.pages[DressingRoom.sv.page.current].name = txt
      c:SetText(string.format("|cFFCC99%s|r |c80664D(%d/%d)|r", txt, DressingRoom.sv.page.current, #DressingRoom.sv.page.pages))
    end
    e:SetHidden(true)
    c:SetHidden(false)
  end)
  e:SetHandler("OnEscape", function() keep = false e:LoseFocus() end)

  c.editbox = e
  return c
end

function DressingRoom:CreateWindow()
  -- main window
  local w = WINDOW_MANAGER:CreateTopLevelWindow("DressingRoomWin")
  w:SetDrawLayer(1)
  w:SetHidden(true)
  if self.sv.window_pos then
    w:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, unpack(self.sv.window_pos))
  else
    w:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
  end
  w:SetMouseEnabled(true)
  w:SetClampedToScreen(true)
  w:SetMovable(true)
  w:SetHandler("OnMoveStop", function(w) self.sv.window_pos = { w:GetLeft(), w:GetTop() } end)

  -- main window background
  WINDOW_MANAGER:CreateControlFromVirtual("DressingRoomWin_BG", DressingRoomWin, "ZO_DefaultBackdrop")

  -- close button
  local c = WINDOW_MANAGER:CreateControl("DressingRoomWin_Close", DressingRoomWin, CT_BUTTON)
  c:SetDimensions(25, 25)
  c:SetAnchor(TOPRIGHT, DressingRoomWin, TOPRIGHT, -3, 3)
  c:SetState(BSTATE_NORMAL)
  c:SetHandler("OnClicked", function() DressingRoomWin:SetHidden(true) end)
  c:SetNormalTexture("ESOUI/art/buttons/decline_up.dds")
  c:SetMouseOverTexture("ESOUI/art/buttons/decline_over.dds")

  -- window title
  local t = WINDOW_MANAGER:CreateControl("DressingRoomWin_Title", DressingRoomWin, CT_LABEL)
  t:SetText("|cFFBA59Dressing Room|r")
  t:SetFont("ZoFontWinH3")
  t:SetColor(1, 1, 1, 1)
  t:SetAnchor(TOP, DressingRoomWin, TOP, 0, 2)

  --TODO select presets from dropdown
  local bttnPrev = WINDOW_MANAGER:CreateControl("DressingRoomWin_Previous", DressingRoomWin, CT_BUTTON)
  bttnPrev:SetDimensions(25, 25)
  --bttnPrev:SetAnchor(LEFT, t, RIGHT, 0, 0)
  bttnPrev:SetAnchor(TOPLEFT, DressingRoomWin, TOPLEFT, 3, 3)
  bttnPrev:SetState(BSTATE_NORMAL)
  bttnPrev:SetHandler("OnClicked", function()
    if DressingRoom.sv.page.current > 1 then
      DressingRoom.sv.page.current = DressingRoom.sv.page.current - 1
      DressingRoom.manualPageChange = true
    end
    DressingRoom:RefreshWindowData()
  end)
  bttnPrev:SetNormalTexture("ESOUI/art/miscellaneous/Gamepad/spinner_arrow_left_up.dds")
  bttnPrev:SetMouseOverTexture("ESOUI/art/miscellaneous/Gamepad/spinner_arrow_left_down.dds")

  local bttnAdd = WINDOW_MANAGER:CreateControl("DressingRoomWin_Add", DressingRoomWin, CT_BUTTON)
  bttnAdd:SetDimensions(25, 25)
  bttnAdd:SetAnchor(LEFT, bttnPrev, RIGHT, 0, 0)
  bttnAdd:SetState(BSTATE_NORMAL)
  bttnAdd:SetHandler("OnClicked", function()
    DressingRoom:AddPage()
    DressingRoom.sv.page.current = #DressingRoom.sv.page.pages
    DressingRoom.manualPageChange = true
    DressingRoom:RefreshWindowData()
  end)
  bttnAdd:SetNormalTexture("ESOUI/art/buttons/plus_up.dds")
  bttnAdd:SetMouseOverTexture("ESOUI/art/buttons/plus_over.dds")

  local bttnDel = WINDOW_MANAGER:CreateControl("DressingRoomWin_Delete", DressingRoomWin, CT_BUTTON)
  bttnDel:SetDimensions(25, 25)
  bttnDel:SetAnchor(LEFT, bttnAdd, RIGHT, 0, 0)
  bttnDel:SetState(BSTATE_NORMAL)
  bttnDel:SetHandler("OnClicked", function()
    if DressingRoom.sv.page.current == 1 then return end
    for i = DressingRoom.sv.page.current, #DressingRoom.sv.page.pages do
      DressingRoom.sv.page.pages[i] = DressingRoom.sv.page.pages[i + 1]
    end
    if DressingRoom.sv.page.current > #DressingRoom.sv.page.pages then
      DressingRoom.sv.page.current = #DressingRoom.sv.page.pages
    end
    DressingRoom.manualPageChange = true
    DressingRoom:RefreshWindowData()
  end)
  bttnDel:SetNormalTexture("ESOUI/art/buttons/minus_up.dds")
  bttnDel:SetMouseOverTexture("ESOUI/art/buttons/minus_over.dds")

  local bttnNext = WINDOW_MANAGER:CreateControl("DressingRoomWin_Next", DressingRoomWin, CT_BUTTON)
  bttnNext:SetDimensions(25, 25)
  bttnNext:SetAnchor(LEFT, bttnDel, RIGHT, 0, 0)
  bttnNext:SetState(BSTATE_NORMAL)
  bttnNext:SetHandler("OnClicked", function()
    if DressingRoom.sv.page.current < #DressingRoom.sv.page.pages then
      DressingRoom.sv.page.current = DressingRoom.sv.page.current + 1
      DressingRoom.manualPageChange = true
    end
    DressingRoom:RefreshWindowData()
  end)
  bttnNext:SetNormalTexture("ESOUI/art/miscellaneous/Gamepad/spinner_arrow_right_up.dds")
  bttnNext:SetMouseOverTexture("ESOUI/art/miscellaneous/Gamepad/spinner_arrow_right_down.dds")

  self.pageTitle = CreatePageTitle()
  self.pageTitle:SetAnchor(LEFT, bttnNext, RIGHT, 0, 0)

  -- buttons
  self.skillBtn = {}
  self.barBtn = {}
  self.gearBtn = {}
  self.setBtn = {}
  self.setLabel = {}
  local activePair = GetActiveWeaponPairInfo()
  for setId = 1, self:numSets() do
    self.skillBtn[setId] = {}
    self.barBtn[setId] = {}
    for bar = 1, 2 do

      -- skill buttons
      self.skillBtn[setId][bar] = {}
      for sk = 1, 6 do
        local b = WINDOW_MANAGER:CreateControl("DressingRoom_SkillBtn_"..(setId*12+bar*6+sk), DressingRoomWin, CT_BUTTON)
        b:SetMouseEnabled(true)
        b:SetHandler("OnMouseEnter", function(self)
            if self.text ~= nil then ZO_Tooltips_ShowTextTooltip(self, TOP, self.text) end
          end)
        b:SetHandler("OnMouseExit", function(self) ZO_Tooltips_HideTextTooltip() end)
        self.skillBtn[setId][bar][sk] = b
      end

      -- bar equip button
      local b = CreateButton("DressingRoom_BarBtn_"..setId.."_"..bar)
      b:SetAnchor(LEFT, self.skillBtn[setId][bar][6], RIGHT, 3, 0)
      b.text = self._msg.barBtnText
      b:SetHandler("OnMouseDown", function(self, btn, ctrl, alt, shift)
          if shift == true then DressingRoom:SaveSkills(setId, bar)
          elseif ctrl == true then DressingRoom:DeleteSkills(setId, bar)
          else DressingRoom:LoadSkills(setId, bar) end
        end)
      b:SetHidden(self.sv.options.activeBarOnly and bar ~= activePair)
      self.barBtn[setId][bar] = b

      -- skills border
      b = WINDOW_MANAGER:CreateControl('DressingRoom_SkillBorder_'..setId.."_"..bar, DressingRoomWin, CT_BACKDROP)
      b:SetAnchor(LEFT, DressingRoom.skillBtn[setId][bar][1], LEFT, -1, 0)
      b:SetEdgeTexture("", 1, 1, 1)
      b:SetCenterColor(1, 0.73, 0.35, 0.05)
      b:SetEdgeColor(0.7, 0.7, 0.6, 1)
    end

    -- gear set button
    local b = CreateButton("DressingRoom_GearBtn_"..setId)
    b:SetAnchor(BOTTOM, DressingRoom.barBtn[setId][1], TOP, 0, -2)
    b:SetNormalTexture("ESOUI/art/guild/tabicon_heraldry_up.dds")
    b:SetMouseOverTexture("ESOUI/art/guild/tabicon_heraldry_over.dds")
    b.text = self._msg.gearBtnText
    b.setId = setId
    b:SetHandler("OnMouseDown", function(self, btn, ctrl, alt, shift)
        if shift == true then DressingRoom:SaveGear(self.setId)
        elseif ctrl == true then DressingRoom:DeleteGear(self.setId)
        else DressingRoom:LoadGear(self.setId) end
      end)
    self.gearBtn[setId] = b

    -- full gear & item set button
    b = CreateButton("DressingRoom_SetBtn_"..setId)
    b:SetAnchor(TOPRIGHT, self.skillBtn[setId][1][1], TOPLEFT, -3, -1)
    local keyName = getBindingName('DRESSINGROOM_SET_'..setId)
    b:SetText("SET "..setId.."\n"..keyName)
    b:SetNormalTexture("")
    b:SetMouseOverTexture("")
    b:SetNormalFontColor(0.7, 0.7, 0.6, 1)
    b:SetMouseOverFontColor(1, 0.73, 0.35, 1)
    b.text = self._msg.setBtnText
    b.setId = setId
    b:SetHandler("OnClicked", function(self) DressingRoom:LoadSet(self.setId) end)
    self.setBtn[setId] = b

    -- set label
    b = CreateSetLabel(setId)
    b.bg:SetAnchor(RIGHT, self.gearBtn[setId], LEFT, -2, 0)
    self.setLabel[setId] = b
  end
  EVENT_MANAGER:RegisterForEvent(nil, EVENT_ACTIVE_WEAPON_PAIR_CHANGED,
    function (eventCode, activePair, locked)
      for setId = 1, self:numSets() do
        for bar = 1,2 do
          self.barBtn[setId][bar]:SetHidden(self.sv.options.activeBarOnly and bar ~= activePair)
        end
      end
    end)
  self:ResizeWindow()
end

function DressingRoom:ResizeWindow()
  local sbtnSize = self.sv.options.btnSize
  local sbtnVSpacing = sbtnSize + 5
  local sbtnHSpacing = sbtnSize + 3
  local skillBorderWidth = sbtnHSpacing * 5 + sbtnSize + 2
  local setBtnSize = sbtnVSpacing + sbtnSize + 2
  local offsetH = sbtnVSpacing + sbtnSize + 10
  local offsetV = sbtnVSpacing + 40
  local colSize = setBtnSize + skillBorderWidth + sbtnSize + 16
  local rowSize = setBtnSize + sbtnVSpacing + 8

  -- main window
  DressingRoomWin:SetDimensions(colSize * self.numCols + 1, rowSize * self.numRows + 38)

  -- buttons
  for setId = 1, self:numSets() do
    for bar = 1, 2 do
      -- skill buttons
      for sk = 1, 6 do
        local b = self.skillBtn[setId][bar][sk]
        b:SetDimensions(sbtnSize, sbtnSize)
        local row, col
        if self.sv.options.columnMajorOrder then
          col, row = math.modf((setId - 1) / self.numRows)
          row = row * self.numRows
        else
          row, col = math.modf((setId - 1) / self.numCols)
          col = col * self.numCols
        end
        b:ClearAnchors()
        b:SetAnchor(TOPLEFT, DressingRoomWin, TOPLEFT,
          offsetH + col * colSize + (sk - 1) * sbtnHSpacing,
          offsetV + row * rowSize + (bar - 1) * sbtnVSpacing)
      end

      -- bar equip button
      self.barBtn[setId][bar]:SetDimensions(sbtnSize+2, sbtnSize+2)

      -- skills border
      local b = WINDOW_MANAGER:GetControlByName('DressingRoom_SkillBorder_'..setId.."_"..bar)
      b:SetDimensions(skillBorderWidth, sbtnSize + 2)
    end

    -- gear set button
    self.gearBtn[setId]:SetDimensions(sbtnSize+2, sbtnSize+2)

    -- full gear & item set button
    self.setBtn[setId]:SetDimensions(setBtnSize, setBtnSize)

    -- set label
    self.setLabel[setId].bg:SetDimensions(skillBorderWidth + setBtnSize + 2, sbtnSize + 2)
  end
end


function DressingRoom:SetButton(btn, abilityId)
  btn:SetNormalTexture(GetAbilityIcon(abilityId))
  btn:SetAlpha(1)
  btn.text = zo_strformat(SI_ABILITY_NAME, GetAbilityName(abilityId))
end


function DressingRoom:RefreshWindowData()
  self.pageTitle:SetText(string.format("|cFFCC99%s|r |c80664D(%d/%d)|r", self.sv.page.pages[self.sv.page.current].name, DressingRoom.sv.page.current, #DressingRoom.sv.page.pages))
  local activePair = GetActiveWeaponPairInfo()
  for setId = 1, self:numSets() do
    self.setBtn[setId]:SetFont("$(MEDIUM_FONT)|"..self.sv.options.fontSize)
    local gearSet = self.sv.page.pages[DressingRoom.sv.page.current].gearSet[setId]
    self.setLabel[setId]:SetFont("$(MEDIUM_FONT)|"..self.sv.options.fontSize)
    self.setLabel[setId].editbox:SetFont("$(MEDIUM_FONT)|"..self.sv.options.fontSize)
    if gearSet then
      self.setLabel[setId].text = gearSet.text
      self.setLabel[setId]:SetText(gearSet.name)
    else
      self.setLabel[setId].text = nil
      self.setLabel[setId]:SetText("")
    end
    if self.sv.page.pages[DressingRoom.sv.page.current].customSetName[setId] then self.setLabel[setId]:SetText(self.sv.page.pages[DressingRoom.sv.page.current].customSetName[setId]) end
    for bar = 1, 2 do
      local skillBar = self.sv.page.pages[DressingRoom.sv.page.current].skillSet[setId][bar]
      self.barBtn[setId][bar]:SetHidden(self.sv.options.activeBarOnly and bar ~= activePair)
      for sk = 1, 6 do
        local btn = self.skillBtn[setId][bar][sk]
        local abilityId = skillBar[sk]
        if abilityId then
          if type(abilityId) == "string" then
            abilityId = select(3, zo_strsplit(":", abilityId))
            abilityId = tonumber(abilityId)
          end
          self:SetButton(btn, abilityId)
        else
          btn:SetNormalTexture("ESOUI/art/actionbar/quickslotbg.dds")
          btn:SetAlpha(0.3)
          btn.text = nil
        end
      end
    end
  end
end

function DressingRoom:OpenWith(control, active)
  if active and not self.savedHandlers[control] then
    local onShow = control:GetHandler("OnShow")
    local onHide = control:GetHandler("OnHide")
    control:SetHandler("OnShow", function(...)
      DressingRoomWin:SetHidden(false)
      if onShow then onShow(...) end
    end)
    control:SetHandler("OnHide", function(...)
      DressingRoomWin:SetHidden(true)
      if onHide then onHide(...) end
    end)
    -- save old handlers to be able to restore them if needed
    self.savedHandlers[control] = { onShow = onShow, onHide = onHide }
  else
    local handlers = self.savedHandlers[control]
    if handlers then
      control:SetHandler("OnShow", handlers.onShow)
      control:SetHandler("OnHide", handlers.onHide)
      self.savedHandlers[control] = nil
    end
  end
end


function DressingRoom:CreateAddonMenu()
  local LAM = LibAddonMenu2

  local panelData = {
    type = "panel",
    name = "Dressing Room",
    author = "dividee, code65536, Toloache",
    version = "0.11",
    slashCommand = "/dressingroom",
  }

  LAM:RegisterAddonPanel("DressingRoomOptions", panelData)

  local txt = self._msg.options
  local defaults = self.default_options

  local optionsData = {
    {
      type = "checkbox",
      name = txt.clearEmptyGear.name,
      tooltip = txt.clearEmptyGear.tooltip,
      default = defaults.clearEmptyGear,
      getFunc = function() return self.sv.options.clearEmptyGear end,
      setFunc = function(value) self.sv.options.clearEmptyGear = value end,
    },
    {
      type = "checkbox",
      name = txt.clearEmptySkill.name,
      tooltip = txt.clearEmptySkill.tooltip,
      default = defaults.clearEmptySkill,
      getFunc = function() return self.sv.options.clearEmptySkill end,
      setFunc = function(value) self.sv.options.clearEmptySkill = value end,
    },
    {
      type = "checkbox",
      name = txt.activeBarOnly.name,
      tooltip = txt.activeBarOnly.tooltip,
      default = defaults.activeBarOnly,
      getFunc = function() return self.sv.options.activeBarOnly end,
      setFunc = function(value) self.sv.options.activeBarOnly = value; self:RefreshWindowData() end,
    },
    {
      type = "slider",
      name = txt.fontSize.name,
      tooltip = txt.fontSize.tooltip,
      min = 12,
      max = 24,
      default = defaults.fontSize,
      getFunc = function() return self.sv.options.fontSize end,
      setFunc = function(value) self.sv.options.fontSize = value; self:RefreshWindowData() end,
    },
    {
      type = "slider",
      name = txt.btnSize.name,
      tooltip = txt.btnSize.tooltip,
      min = 20,
      max = 64,
      default = defaults.btnSize,
      getFunc = function() return self.sv.options.btnSize end,
      setFunc = function(value) self.sv.options.btnSize = value; self:ResizeWindow() end,
    },
    {
      type = "checkbox",
      name = txt.columnMajorOrder.name,
      tooltip = txt.columnMajorOrder.tooltip,
      default = defaults.columnMajorOrder,
      getFunc = function() return self.sv.options.columnMajorOrder end,
      setFunc = function(value) self.sv.options.columnMajorOrder = value; self:ResizeWindow() end,
    },
    {
      type = "checkbox",
      name = txt.showChatMessages.name,
      tooltip = txt.showChatMessages.tooltip,
      default = defaults.showChatMessages,
      getFunc = function() return self.sv.options.showChatMessages end,
      setFunc = function(value) self.sv.options.showChatMessages = value end,
    },
    {
      type = "checkbox",
      name = txt.openWithSkillsWindow.name,
      tooltip = txt.openWithSkillsWindow.tooltip,
      default = defaults.openWithSkillsWindow,
      getFunc = function() return self.sv.options.openWithSkillsWindow end,
      setFunc = function(value) self.sv.options.openWithSkillsWindow = value; self:OpenWith(ZO_Skills, value) end,
    },
    {
      type = "checkbox",
      name = txt.openWithInventoryWindow.name,
      tooltip = txt.openWithInventoryWindow.tooltip,
      default = defaults.openWithInventoryWindow,
      getFunc = function() return self.sv.options.openWithInventoryWindow end,
      setFunc = function(value) self.sv.options.openWithInventoryWindow = value; self:OpenWith(ZO_PlayerInventory, value) end,
    },
    {
      type = "checkbox",
      name = txt.singleBarToCurrent.name,
      tooltip = txt.singleBarToCurrent.tooltip,
      default = defaults.singleBarToCurrent,
      getFunc = function() return self.sv.options.singleBarToCurrent end,
      setFunc = function(value) self.sv.options.singleBarToCurrent = value end,
    },
    {
      type = "slider",
      name = txt.numRows.name,
      tooltip = txt.numRows.tooltip,
      min = 1,
      max = 6,
      default = defaults.numRows,
      getFunc = function() return self.sv.options.numRows end,
      setFunc = function(value) self.sv.options.numRows = value end,
      warning = txt.reloadUIWarning,
    },
    {
      type = "slider",
      name = txt.numCols.name,
      tooltip = txt.numCols.tooltip,
      min = 1,
      max = 4,
      default = defaults.numCols,
      getFunc = function() return self.sv.options.numCols end,
      setFunc = function(value) self.sv.options.numCols = value end,
      warning = txt.reloadUIWarning,
    },
    {
      type = "checkbox",
      name = txt.alwaysChangePageOnZoneChanged.name,
      tooltip = txt.alwaysChangePageOnZoneChanged.tooltip,
      default = defaults.alwaysChangePageOnZoneChanged,
      getFunc = function() return self.sv.options.alwaysChangePageOnZoneChanged end,
      setFunc = function(value) self.sv.options.alwaysChangePageOnZoneChanged = value end,
    },
    {
      type = "button",
      name = txt.reloadUI,
      func = function() ReloadUI() end
    },
  }

  LAM:RegisterOptionControls("DressingRoomOptions", optionsData)
end
