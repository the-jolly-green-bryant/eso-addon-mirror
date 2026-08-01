function DressingRoom:ToggleWindow()
--[[
  local stayInUIMode = SCENE_MANAGER:GetCurrentSceneName() ~= "hud"
  DressingRoomWin:ToggleHidden()
  SetGameCameraUIMode(not DressingRoomWin:IsHidden() or stayInUIMode)
--]]
  if not self.initialised then return end
  SCENE_MANAGER:ToggleTopLevel(DressingRoomWin)
end


local function getBindingName(keyStr)
  local layIdx, catIdx, actIdx = GetActionIndicesFromName(keyStr)
  local keyCode, mod1, mod2, mod3, mod4 = GetActionBindingInfo(layIdx, catIdx, actIdx, 1)
  if layIdx and keyCode > 0 then return ZO_Keybindings_GetBindingStringFromKeys(keyCode, mod1, mod2, mod3, mod4)
  else return '' end
end

local function CreateButton(name)
	local c = WINDOW_MANAGER:CreateControl(name, DressingRoomWin, CT_BUTTON)
	local b = WINDOW_MANAGER:CreateControl(name.."_BG", c, CT_BACKDROP)
	
	c:SetMouseEnabled(true)
	c:SetState(BSTATE_NORMAL)
	c:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
	c:SetVerticalAlignment(TEXT_ALIGN_CENTER)
	c:SetFont("$(MEDIUM_FONT)|"..DressingRoom.options.fontSize)
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
	c:SetPressedTexture("ESOUI/art/mainmenu/menubar_skills_down.dds")
	
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
    e:SetText(DressingRoom.ram.page.pages[DressingRoom.sv.page.current].customSetName[setId])
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
        DressingRoom.ram.page.pages[DressingRoom.sv.page.current].customSetName[setId] = nil
        local gearSet = DressingRoom.ram.page.pages[DressingRoom.sv.page.current].gearSet[setId]
        c:SetText(gearSet and "|cC8C8C8("..gearSet.name..")|r")
      else
        DressingRoom.ram.page.pages[DressingRoom.sv.page.current].customSetName[setId] = txt
        c:SetText(txt)
      end
--      DressingRoom:StorePage()
      DressingRoom:SetDirty(true)
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
    e:SetText(DressingRoom.ram.page.name[DressingRoom.sv.page.current])
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
      DressingRoom.ram.page.name[DressingRoom.sv.page.current] = txt
--      DressingRoom:StorePage()
      DressingRoom:SetDirty(true)
      c:SetText(string.format("|cFFCC99%s|r |c80664D(%d/%d)|r", txt, DressingRoom.sv.page.current, #DressingRoom.ram.page.pages))
    end
    e:SetHidden(true)
    c:SetHidden(false)
  end)
  e:SetHandler("OnEscape", function() keep = false e:LoseFocus() end)

  c.editbox = e
  return c
end

local function PageSelectorItemCallback(control, itemName, item, selectionChanged, oldItem)
  if not selectionChanged then return end
end

local function UpdatePageSelector(self)
  local dd = self.pageSelector.dropdown
  dd:ClearItems()
  for i = 1, #self.ram.page.pages do
    local entry = ZO_ComboBox:CreateItemEntry(self.ram.page.name[i], function() self:SelectPage(i) end)
    dd:AddItem(entry, ZO_COMBOBOX_SUPRESS_UPDATE)
  end
end

local function CreatePageSelector(self)
  local c = WINDOW_MANAGER:CreateControlFromVirtual("DressingRoomWin_Page", DressingRoomWin, "ZO_ComboBox")
  local dd = ZO_ComboBox_ObjectFromContainer(c)
  c.dropdown = dd
  return c
end

function DressingRoom:CreateNotificationArea()
  local w = WINDOW_MANAGER:CreateTopLevelWindow("DressingRoomNotificationArea")
  w:SetHidden(true)
  if not self.options.notificationAreaPos then
    w:SetAnchor(TOPLEFT, ZO_ActionBar1, TOPRIGHT, 16, 0)
    self.options.notificationAreaPos = {w:GetLeft(), w:GetTop()}
    w:ClearAnchors()
  end
  w:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, unpack(self.options.notificationAreaPos))
  w:SetDimensions(208, 48)
  w:SetMouseEnabled(false)
  w:SetClampedToScreen(true)
  w:SetMovable(false)

  local t = WINDOW_MANAGER:CreateControl("DressingRoomNotificationArea_Label", w, CT_LABEL)
  t:SetDrawLayer(1)
  t:SetAnchor(TOPLEFT, w, TOPLEFT, 0, 0)
  t:SetMouseEnabled(true)
  t:SetClampedToScreen(false)
  t:SetMovable(not self.options.lockNotificationArea)
  t:SetText("|cFFBA59Dressing Room"..string.format(" |t32:32:%s|t ", DressingRoom:GetRoleIconTexturePath(self.currentGroupRole)).."|r\n|cC8C8C8"..self.notificationAreaWelcomeText.."|r")
  t:SetFont("ZoFontWinH3")
  t:SetColor(1, 1, 1, 1)
  t:SetHidden(not self.options.showNotificationArea)
  t:SetHandler("OnMoveStop", function()
        w:ClearAnchors()
        self.options.notificationAreaPos = {t:GetLeft(), t:GetTop()}
        w:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, unpack(self.options.notificationAreaPos))
        t:ClearAnchors()
        t:SetAnchor(TOPLEFT, w, TOPLEFT, 0, 0)
      end)

  self.notificationArea = w
  self.notificationAreaLabel = t

  local fragment = ZO_SimpleSceneFragment:New(w)
  HUD_SCENE:AddFragment(fragment)
  HUD_UI_SCENE:AddFragment(fragment)
end

function DressingRoom:UpdateNotificationAreaLabel(text)
  if not self.initialised then return end
  local currentStatus = ""
  if (self.deferredLoad.skills[1] or self.deferredLoad.skills[2] or self.deferredLoad.gear) and IsUnitInCombat("player") then
    currentStatus = " - |cFF0000"..self._msg.waitingForOutOfCombat
  elseif self.weaponSwapNeeded then
    currentStatus = " - |cFF8000"..self._msg.waitingForWeaponSwap
  end
  local statusText = ""
  if text then
    statusText = text
  elseif self.currentSetName then
    statusText = self.currentSetName
    if self.currentSetIcon then statusText = self.currentSetIcon..statusText end
  else
    statusText = self.notificationAreaWelcomeText
  end
  self.notificationAreaLabel:SetText("|cFFBA59Dressing Room"..string.format(" |t32:32:%s|t ", DressingRoom:GetRoleIconTexturePath(self.currentGroupRole))..currentStatus.."|r\n|cC8C8C8"..statusText.."|r")
end

function DressingRoom:ShowConfirmDeletePageDialog()
  ZO_Dialogs_ShowDialog(DressingRoom.name.."_".."ConfirmPageDelete", nil, {mainTextParams = {self.ram.page.name[self.sv.page.current]}})
end

function DressingRoom:ShowEditPageNameDialog()
  ZO_Dialogs_ShowDialog(DressingRoom.name.."_".."EditPageName", nil, {mainTextParams = {self.ram.page.name[self.sv.page.current]}, initialEditText = self.ram.page.name[self.sv.page.current]})
end

function DressingRoom:ShowNotSavedWarningDialog()
  ZO_Dialogs_ShowDialog(DressingRoom.name.."_".."NotSavedWarning")
end

local function GetFriendlyRoleNames()
  return ({"Damage", "Tank", "Healer"})
end

local function GetFriendlyRoleName(groupRole)
  return GetFriendlyRoleNames()[groupRole]
end

local function GetCharactersByClass(classId)
  classId = classId or GetUnitClassId("player")
  local t = {}
  local currentCharacterId = GetCurrentCharacterId()
  DressingRoom.charIdFromFancyName = {}
  for i = 1, GetNumCharacters() do
    local characterName, _, _, characterClassId, _, characterAlliance, characterId, _ = GetCharacterInfo(i)
    if characterClassId == classId and characterId ~= currentCharacterId then
      characterName = characterName:gsub("%^%a+$", "")
      local fancyName = "|t32:32:"..GetAllianceSymbolIcon(characterAlliance).."|t "..characterName
      table.insert(t, fancyName)
      DressingRoom.charIdFromFancyName[fancyName] = i
    end
  end
  return t
end

function DressingRoom:GetRoleIconTexturePath(groupRole, state, large)
  local names = {"dps", "tank", "healer"}
  if not names[groupRole] then return "ESOUI/art/icons/icon_missing.dds" end
  local states = {["up"] = true, ["over"] = true, ["down"] = true, ["down_over"] = true}
  if not states[state] then
    return string.format("ESOUI/art/lfg/lfg_icon_%s.dds", names[groupRole])
  else
    if large then
      return string.format("ESOUI/art/lfg/lfg_%s_%s_64.dds", names[groupRole], state)
    else
      return string.format("ESOUI/art/lfg/lfg_%s_%s.dds", names[groupRole], state)
    end
  end
end

function DressingRoom:SetRoleIconTexture(control, groupRole)
  if self.roleSpecificPresets then
    control:SetNormalTexture(DressingRoom:GetRoleIconTexturePath(groupRole, "up"))
    control:SetMouseOverTexture(DressingRoom:GetRoleIconTexturePath(groupRole, "over"))
    control:SetPressedTexture(DressingRoom:GetRoleIconTexturePath(groupRole, "down"))
  else
    control:SetTexture(DressingRoom:GetRoleIconTexturePath(groupRole))
  end
end

function DressingRoom:OnRoleButtonClicked(control)
  if not control then return end
  for i, v in ipairs(GetFriendlyRoleNames()) do
    local b = WINDOW_MANAGER:GetControlByName("DressingRoomSetupWin_"..v)
    if b == control then
      b:SetNormalTexture(DressingRoom:GetRoleIconTexturePath(b.role, "down", true))
      b:SetMouseOverTexture(DressingRoom:GetRoleIconTexturePath(b.role, "down_over", true))
      b:SetPressedTexture(DressingRoom:GetRoleIconTexturePath(b.role, "down", true))
    else
      b:SetNormalTexture(DressingRoom:GetRoleIconTexturePath(b.role, "up", true))
      b:SetMouseOverTexture(DressingRoom:GetRoleIconTexturePath(b.role, "over", true))
      b:SetPressedTexture(DressingRoom:GetRoleIconTexturePath(b.role, "down", true))
    end
  end
  self.selectedDefaultRole = control.role
end

function DressingRoom:OpenKeyBindings()
  local function openKeyBindingsMenu()
    local gameMenu = ZO_GameMenu_InGame.gameMenu
    local controlsMenu = gameMenu.headerControls[GetString(SI_GAME_MENU_CONTROLS)]
    if not controlsMenu then return end
    local children = controlsMenu:GetChildren()
    local node
    for i = 1, (children and #children or 0) do
      local childNode = children[i]
      local data = childNode:GetData()
      if not data then return end
      if data.name == GetString(SI_GAME_MENU_KEYBINDINGS) then
        node = childNode
      end
    end
    if not node then return end
    node:GetTree():SelectNode(node)
    local listControl = KEYBINDING_MANAGER.list.list
    local dataList = ZO_ScrollList_GetDataList(listControl)
    for k, v in pairs(dataList) do
      if type(v) == "table" and type(v.data) == "table" and v.data.categoryName == "Dressing Room" then
        ZO_ScrollList_ScrollRelative(listControl, v.data.dataEntry.top - listControl.scrollbar:GetValue(), nil, true)
        return
      end
    end
  end
  if SCENE_MANAGER:GetScene("gameMenuInGame"):GetState() == SCENE_SHOWN then
    openKeyBindingsMenu()
  else
    SCENE_MANAGER:CallWhen("gameMenuInGame", SCENE_SHOWN, openKeyBindingsMenu)
    SCENE_MANAGER:Show("gameMenuInGame")
  end
end

function DressingRoom:CreateSetupWindow()
  local w = WINDOW_MANAGER:CreateTopLevelWindow("DressingRoomSetupWin")
  SCENE_MANAGER:RegisterTopLevel(w, false)
  w:SetDrawLayer(0)
  w:SetHidden(true)
  w:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
  w:SetMouseEnabled(true)
  w:SetMovable(false)
  WINDOW_MANAGER:CreateControlFromVirtual("DressingRoomSetupWin_BG", DressingRoomSetupWin, "ZO_DefaultBackdrop")
  w:SetDimensions(288, 288)
  local AcceptSelectedRole = function()
        EVENT_MANAGER:UnregisterForEvent(DressingRoom.name, EVENT_KEYBINDING_SET)
        EVENT_MANAGER:UnregisterForEvent(DressingRoom.name, EVENT_KEYBINDING_CLEARED)
        EVENT_MANAGER:UnregisterForEvent(DressingRoom.name, EVENT_KEYBINDINGS_LOADED)
        w:SetHandler("OnHide", function() end)
        SCENE_MANAGER:HideTopLevel(w)
        self:Initialize()
      end
  w:SetHandler("OnHide", function()
        self.setupWindowHideCount = (self.setupWindowHideCount or 0) + 1
        if self.setupWindowHideCount < 5 then
          SCENE_MANAGER:ShowTopLevel(w)
        else
          AcceptSelectedRole()
        end
      end)

  local t = WINDOW_MANAGER:CreateControl("DressingRoomSetupWin_Title", DressingRoomSetupWin, CT_LABEL)
  t:SetText("|cFFBA59Dressing Room|r")
  t:SetFont("ZoFontWinH3")
  t:SetColor(1, 1, 1, 1)
  t:SetAnchor(TOP, DressingRoomSetupWin, TOP, 0, 2)

  t = WINDOW_MANAGER:CreateControl("DressingRoomSetupWin_Text", DressingRoomSetupWin, CT_LABEL)
  t:SetText(string.format("|cFFFFCC%s|r", self._msg.setupWindowText))
  t:SetFont("ZoFontWinT1")
  t:SetColor(1, 1, 1, 1)
  t:SetAnchor(TOPLEFT, DressingRoomSetupWin, TOPLEFT, 16, 32)
  t:SetWidth(256)

  local bttnDamage = WINDOW_MANAGER:CreateControl("DressingRoomSetupWin_Damage", DressingRoomSetupWin, CT_BUTTON)
  bttnDamage:SetDimensions(64, 64)
  bttnDamage:SetAnchor(TOPLEFT, DressingRoomSetupWin, TOPLEFT, 24, 80)
  bttnDamage:SetState(BSTATE_NORMAL)
  bttnDamage:SetHandler("OnClicked", function(...) self:OnRoleButtonClicked(...) end)
  bttnDamage.role = 1

  local bttnTank = WINDOW_MANAGER:CreateControl("DressingRoomSetupWin_Tank", DressingRoomSetupWin, CT_BUTTON)
  bttnTank:SetDimensions(64, 64)
  bttnTank:SetAnchor(TOP, DressingRoomSetupWin, TOP, 0, 80)
  bttnTank:SetState(BSTATE_NORMAL)
  bttnTank:SetHandler("OnClicked", function(...) self:OnRoleButtonClicked(...) end)
  bttnTank.role = 2

  local bttnHealer = WINDOW_MANAGER:CreateControl("DressingRoomSetupWin_Healer", DressingRoomSetupWin, CT_BUTTON)
  bttnHealer:SetDimensions(64, 64)
  bttnHealer:SetAnchor(TOPRIGHT, DressingRoomSetupWin, TOPRIGHT, -24, 80)
  bttnHealer:SetState(BSTATE_NORMAL)
  bttnHealer:SetHandler("OnClicked", function(...) self:OnRoleButtonClicked(...) end)
  bttnHealer.role = 3

  self:OnRoleButtonClicked(({bttnDamage, bttnTank, bttnHealer})[self:GetGroupRoleFromLFGTool()])

  t = WINDOW_MANAGER:CreateControl("DressingRoomSetupWin_Text2", DressingRoomSetupWin, CT_LABEL)
  t:SetText(string.format("|c999999(%s)|r", self._msg.setupWindowText2))
  t:SetFont("ZoFontWinT2")
  t:SetColor(1, 1, 1, 1)
  t:SetAnchor(TOPLEFT, DressingRoomSetupWin, TOPLEFT, 16, 147)
  t:SetWidth(256)

  t = WINDOW_MANAGER:CreateControl("DressingRoomSetupWin_Text3", DressingRoomSetupWin, CT_LABEL)
  local function UpdateBindingLabel()
    t:SetText(string.format("%s: |cC8C8C8<%s>|r", GetString(SI_BINDING_NAME_DRESSINGROOM_TOGGLE), ZO_Keybindings_GetBindingStringFromAction("DRESSINGROOM_TOGGLE")))
  end
  UpdateBindingLabel()
  EVENT_MANAGER:RegisterForEvent(DressingRoom.name, EVENT_KEYBINDING_SET, UpdateBindingLabel)
  EVENT_MANAGER:RegisterForEvent(DressingRoom.name, EVENT_KEYBINDING_CLEARED, UpdateBindingLabel)
  EVENT_MANAGER:RegisterForEvent(DressingRoom.name, EVENT_KEYBINDINGS_LOADED, UpdateBindingLabel)
  t:SetFont("ZoFontWinT1")
  t:SetColor(1, 1, 1, 1)
  t:SetAnchor(LEFT, DressingRoomSetupWin, TOPLEFT, 16, 212)
  t:SetWidth(256)

  local bttnOpenKeyBindingsMenu = WINDOW_MANAGER:CreateControlFromVirtual(nil, DressingRoomSetupWin, "ZO_DefaultButton")
  bttnOpenKeyBindingsMenu:SetText(GetString(SI_GAME_MENU_KEYBINDINGS))
  bttnOpenKeyBindingsMenu:SetAnchor(TOPLEFT, DressingRoomSetupWin, TOPLEFT, 16, 240)
  bttnOpenKeyBindingsMenu:SetWidth(128)
  bttnOpenKeyBindingsMenu:SetHandler("OnClicked", function() self:OpenKeyBindings() end)

  local bttnDone = WINDOW_MANAGER:CreateControlFromVirtual(nil, DressingRoomSetupWin, "ZO_DefaultButton")
  bttnDone:SetText(GetString(SI_OK))
  bttnDone:SetAnchor(TOPRIGHT, DressingRoomSetupWin, TOPRIGHT, -16, 240)
  bttnDone:SetWidth(128)
  bttnDone:SetHandler("OnClicked", function() AcceptSelectedRole() end)

  SCENE_MANAGER:ShowTopLevel(w)
end

function DressingRoom:CreateWindow()
 if not self.useOldUI then
  ESO_Dialogs[DressingRoom.name.."_ConfirmPageDelete"] = {
    canQueue = true,
    uniqueIdentifier = DressingRoom.name.."_ConfirmPageDelete",
    title = {text = "Dressing Room"},
    mainText = {text = self._msg.confirmDeletePagePrompt},
    buttons = {
      [1] = {
        text = SI_DIALOG_CONFIRM,
        callback = function() self:DeleteCurrentPage() end,
      },
      [2] = {
        text = SI_DIALOG_CANCEL,
        callback = function() end,
      },
    },
    setup = function() end,
  }
  ESO_Dialogs[DressingRoom.name.."_EditPageName"] = {
    canQueue = true,
    uniqueIdentifier = DressingRoom.name.."_EditPageName",
    title = {text = "Dressing Room"},
    mainText = {text = self._msg.editPageNamePrompt},
    editBox = {},
    buttons = {
      [1] = {
        text = SI_DIALOG_CONFIRM,
        callback = function(dialog)
            local txt = ZO_Dialogs_GetEditBoxText(dialog)
            if txt == "" then txt = GetUnitZone("player") end
            DressingRoom.ram.page.name[DressingRoom.sv.page.current] = txt
--            DressingRoom:StorePage()
            DressingRoom:SetDirty(true)
            self:RefreshWindowData()
          end,
      },
      [2] = {
        text = SI_DIALOG_CANCEL,
        callback = function() end,
      },
    },
    setup = function() end,
  }
  ESO_Dialogs[DressingRoom.name.."_NotSavedWarning"] = {
    canQueue = true,
    uniqueIdentifier = DressingRoom.name.."_NotSavedWarning",
    title = {text = "Dressing Room"},
    mainText = {text = self._msg.notSavedWarning},
    buttons = {
      [1] = {
        text = SI_DIALOG_DISMISS,
        callback = function() end,
      },
    },
    setup = function() end,
  }
 end

  -- main window
  local w = WINDOW_MANAGER:CreateTopLevelWindow("DressingRoomWin")
  SCENE_MANAGER:RegisterTopLevel(w, false)
  w:SetDrawLayer(1)
  w:SetHidden(true)
  if self.options.window_pos then
    w:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, unpack(self.options.window_pos))
  else
    w:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
  end
  w:SetMouseEnabled(true)
  w:SetClampedToScreen(true)
  w:SetMovable(not self.options.lockWindowPosition)
  w:SetHandler("OnMoveStop", function(w) self.options.window_pos = { w:GetLeft(), w:GetTop() } end)
  w:SetHandler("OnHide", function() if self.options.autoSaveChangesOnClose then self:StoreAll() end end)
  
  -- main window background
  WINDOW_MANAGER:CreateControlFromVirtual("DressingRoomWin_BG", DressingRoomWin, "ZO_DefaultBackdrop")
  
  -- close button
  local c = WINDOW_MANAGER:CreateControl("DressingRoomWin_Close", DressingRoomWin, CT_BUTTON)
  c:SetDimensions(25, 25)
  c:SetAnchor(TOPRIGHT, DressingRoomWin, TOPRIGHT, -3, 3)
  c:SetState(BSTATE_NORMAL)
  c:SetHandler("OnClicked", function() SCENE_MANAGER:HideTopLevel(DressingRoomWin) end)
  c:SetNormalTexture("ESOUI/art/buttons/decline_up.dds")
  c:SetMouseOverTexture("ESOUI/art/buttons/decline_over.dds")
  c:SetPressedTexture("ESOUI/art/buttons/decline_down.dds")

  local bttnUndress = WINDOW_MANAGER:CreateControl("DressingRoomWin_Undress", DressingRoomWin, CT_BUTTON)
  bttnUndress:SetDimensions(32, 32)
  bttnUndress:SetAnchor(RIGHT, c, LEFT, 0, 0)
  bttnUndress:SetState(BSTATE_NORMAL)
  bttnUndress:SetNormalTexture("ESOUI/art/icons/marking_body_unisex_all_cleanslatenomarkings.dds")
  bttnUndress:SetHandler("OnMouseEnter", function(control)
    ZO_Tooltips_ShowTextTooltip(control, BOTTOMRIGHT, self._msg.bttnUndressText)
  end)
  bttnUndress:SetHandler("OnMouseExit", function()
    ZO_Tooltips_HideTextTooltip()
  end)
  bttnUndress:SetHandler("OnClicked", function()
    DressingRoom:Undress()
  end)

  local bttnReloadUI = WINDOW_MANAGER:CreateControl("DressingRoomWin_ReloadUI", DressingRoomWin, CT_BUTTON)
  bttnReloadUI:SetDimensions(32, 32)
  bttnReloadUI:SetAnchor(RIGHT, bttnUndress, LEFT, 0, 0)
  bttnReloadUI:SetState(BSTATE_NORMAL)
  bttnReloadUI:SetNormalTexture("ESOUI/art/help/help_tabicon_feedback_up.dds")
  bttnReloadUI:SetMouseOverTexture("ESOUI/art/help/help_tabicon_feedback_over.dds")
  bttnReloadUI:SetPressedTexture("ESOUI/art/help/help_tabicon_feedback_down.dds")
  bttnReloadUI:SetHandler("OnMouseEnter", function(control)
    ZO_Tooltips_ShowTextTooltip(control, BOTTOMRIGHT, self._msg.options.reloadUI)
  end)
  bttnReloadUI:SetHandler("OnMouseExit", function()
    ZO_Tooltips_HideTextTooltip()
  end)
  bttnReloadUI:SetHandler("OnClicked", function()
    ReloadUI()
  end)

  local showSettingsMenu = SLASH_COMMANDS["/dressingroom"]
  local bttnSettings
  if type(showSettingsMenu) == "function" then
    bttnSettings = WINDOW_MANAGER:CreateControl("DressingRoomWin_Settings", DressingRoomWin, CT_BUTTON)
    bttnSettings:SetDimensions(32, 32)
    bttnSettings:SetAnchor(RIGHT, bttnReloadUI, LEFT, 0, 0)
    bttnSettings:SetState(BSTATE_NORMAL)
    bttnSettings:SetNormalTexture("ESOUI/art/skillsadvisor/advisor_tabicon_settings_up.dds")
    bttnSettings:SetMouseOverTexture("ESOUI/art/skillsadvisor/advisor_tabicon_settings_over.dds")
    bttnSettings:SetPressedTexture("ESOUI/art/skillsadvisor/advisor_tabicon_settings_down.dds")
    bttnSettings:SetHandler("OnClicked", function() SCENE_MANAGER:ToggleTopLevel(DressingRoomWin) showSettingsMenu() end)
  end

  local bttnSave = WINDOW_MANAGER:CreateControl("DressingRoomWin_Save", DressingRoomWin, CT_BUTTON)
  bttnSave:SetDimensions(32, 32)
  bttnSave:SetAnchor(RIGHT, bttnUndress, LEFT, 0, 0)
  bttnSave:SetState(BSTATE_NORMAL)
  bttnSave:SetNormalTexture("ESOUI/art/buttons/edit_save_up.dds")
  bttnSave:SetMouseOverTexture("ESOUI/art/buttons/edit_save_over.dds")
  bttnSave:SetPressedTexture("ESOUI/art/buttons/edit_save_down.dds")
  bttnSave:SetHandler("OnMouseEnter", function(control)
    ZO_Tooltips_ShowTextTooltip(control, BOTTOMRIGHT, self._msg.changesSave)
  end)
  bttnSave:SetHandler("OnMouseExit", function()
    ZO_Tooltips_HideTextTooltip()
  end)
  bttnSave:SetHandler("OnClicked", function()
    self:StoreAll()
  end)

  local bttnUndo = WINDOW_MANAGER:CreateControl("DressingRoomWin_Undo", DressingRoomWin, CT_BUTTON)
  bttnUndo:SetDimensions(32, 32)
  if self.numCols == 1 then
    bttnUndo:SetAnchor(RIGHT, bttnSave, LEFT, 0, 0)
  else
    bttnUndo:SetAnchor(RIGHT, bttnSettings, LEFT, 0, 0)
  end
--[[
  if bttnSettings then
    bttnUndo:SetAnchor(RIGHT, bttnSettings, LEFT, 0, 0)
    bttnSettings:SetHandler("OnHide", function() bttnUndo:ClearAnchors() bttnUndo:SetAnchor(RIGHT, bttnUndress, LEFT, 0, 0) end)
    bttnSettings:SetHandler("OnShow", function() bttnUndo:ClearAnchors() bttnUndo:SetAnchor(RIGHT, bttnSettings, LEFT, 0, 0) end)
  else
    bttnUndo:SetAnchor(RIGHT, bttnReloadUI, LEFT, 0, 0)
    bttnReloadUI:SetHandler("OnHide", function() bttnUndo:ClearAnchors() bttnUndo:SetAnchor(RIGHT, bttnUndress, LEFT, 0, 0) end)
    bttnReloadUI:SetHandler("OnShow", function() bttnUndo:ClearAnchors() bttnUndo:SetAnchor(RIGHT, bttnReloadUI, LEFT, 0, 0) end)
  end
--]]
  bttnUndo:SetState(BSTATE_NORMAL)
  bttnUndo:SetNormalTexture("ESOUI/art/buttons/edit_cancel_up.dds")
  bttnUndo:SetMouseOverTexture("ESOUI/art/buttons/edit_cancel_over.dds")
  bttnUndo:SetPressedTexture("ESOUI/art/buttons/edit_cancel_down.dds")
  bttnUndo:SetHandler("OnMouseEnter", function(control)
    ZO_Tooltips_ShowTextTooltip(control, BOTTOMRIGHT, self._msg.changesUndo)
  end)
  bttnUndo:SetHandler("OnMouseExit", function()
    ZO_Tooltips_HideTextTooltip()
  end)
  bttnUndo:SetHandler("OnClicked", function()
    self:UndoAll()
  end)

  bttnSave:SetHidden(true)
  bttnUndo:SetHidden(true)

  DressingRoom.SetDirty = function(self, dirty)
    self.dirty = dirty
    if bttnSettings and self.numCols == 1 then
      bttnSettings:SetHidden(dirty)
    end
    bttnReloadUI:SetHidden(dirty)
    bttnUndo:SetHidden(not dirty)
    bttnSave:SetHidden(not dirty)
  end

  -- window title
  local t = WINDOW_MANAGER:CreateControl("DressingRoomWin_Title", DressingRoomWin, CT_LABEL)
  if self.numCols > 1 then
    t:SetText("|cFFBA59Dressing Room|r")
  end
  t:SetFont("ZoFontWinH3")
  t:SetColor(1, 1, 1, 1)
  t:SetAnchor(TOP, DressingRoomWin, TOP, 0, 2)

  local roleIcon
  if self.roleSpecificPresets then
    roleIcon = WINDOW_MANAGER:CreateControl("DressingRoomWin_RoleIcon", DressingRoomWin, CT_BUTTON)
    roleIcon:SetState(BSTATE_NORMAL)
    roleIcon:SetHandler("OnClicked", function() self:ToggleGroupRole() end)
  else
    roleIcon = WINDOW_MANAGER:CreateControl("DressingRoomWin_RoleIcon", DressingRoomWin, CT_TEXTURE)
  end
  roleIcon:SetDimensions(25, 25)
  roleIcon:SetAnchor(TOPLEFT, DressingRoomWin, TOPLEFT, 3, 3)
  self:SetRoleIconTexture(roleIcon, self.currentGroupRole)

  if self.enablePages then
   if self.useOldUI then
    local bttnPrev = WINDOW_MANAGER:CreateControl("DressingRoomWin_Previous", DressingRoomWin, CT_BUTTON)
    bttnPrev:SetDimensions(25, 25)
    --bttnPrev:SetAnchor(LEFT, t, RIGHT, 0, 0)
    bttnPrev:SetAnchor(LEFT, roleIcon, RIGHT, 3, 0)
    bttnPrev:SetState(BSTATE_NORMAL)
    bttnPrev:SetHandler("OnClicked", function() self:SelectPreviousPage() end)
    bttnPrev:SetNormalTexture("ESOUI/art/miscellaneous/Gamepad/spinner_arrow_left_up.dds")
    bttnPrev:SetMouseOverTexture("ESOUI/art/miscellaneous/Gamepad/spinner_arrow_left_down.dds")
    bttnPrev:SetPressedTexture("ESOUI/art/miscellaneous/Gamepad/spinner_arrow_left_disabled.dds")

    local bttnAdd = WINDOW_MANAGER:CreateControl("DressingRoomWin_Add", DressingRoomWin, CT_BUTTON)
    local bttnDel = WINDOW_MANAGER:CreateControl("DressingRoomWin_Delete", DressingRoomWin, CT_BUTTON)
    local bttnNext = WINDOW_MANAGER:CreateControl("DressingRoomWin_Next", DressingRoomWin, CT_BUTTON)
    local lblDeletePrompt = WINDOW_MANAGER:CreateControl("DressingRoomWin_DeletePrompt", DressingRoomWin, CT_LABEL)
    local bttnDeleteConfirm = WINDOW_MANAGER:CreateControl("DressingRoomWin_DeleteConfirm", DressingRoomWin, CT_BUTTON)
    local bttnDeleteCancel = WINDOW_MANAGER:CreateControl("DressingRoomWin_DeleteCancel", DressingRoomWin, CT_BUTTON)

    bttnAdd:SetDimensions(32, 32)
    bttnAdd:SetAnchor(LEFT, bttnPrev, RIGHT, 0, 0)
    bttnAdd:SetState(BSTATE_NORMAL)
    bttnAdd:SetHandler("OnClicked", function()
      self:AddPage()
      self:SelectPage(#self.ram.page.pages)
      self:RefreshWindowData()
    end)
    bttnAdd:SetNormalTexture("ESOUI/art/buttons/plus_up.dds")
    bttnAdd:SetMouseOverTexture("ESOUI/art/buttons/plus_over.dds")
    bttnAdd:SetPressedTexture("ESOUI/art/buttons/plus_down.dds")

    bttnDel:SetDimensions(32, 32)
    bttnDel:SetAnchor(LEFT, bttnAdd, RIGHT, 0, 0)
    bttnDel:SetState(BSTATE_NORMAL)
    bttnDel:SetHandler("OnClicked", function()
      if self.sv.page.current == 1 then return end
      if self.options.confirmPageDelete then
        bttnPrev:SetHidden(true)
        bttnAdd:SetHidden(true)
        bttnDel:SetHidden(true)
        bttnNext:SetHidden(true)
        lblDeletePrompt:SetHidden(false)
        bttnDeleteConfirm:SetHidden(false)
        bttnDeleteCancel:SetHidden(false)
        self.isDeletingPage = true
      else
        self:DeleteCurrentPage()
      end
    end)
    bttnDel:SetNormalTexture("ESOUI/art/buttons/minus_up.dds")
    bttnDel:SetMouseOverTexture("ESOUI/art/buttons/minus_over.dds")
    bttnDel:SetPressedTexture("ESOUI/art/buttons/minus_down.dds")

    bttnNext:SetDimensions(25, 25)
    bttnNext:SetAnchor(LEFT, bttnDel, RIGHT, 0, 0)
    bttnNext:SetState(BSTATE_NORMAL)
    bttnNext:SetHandler("OnClicked", function() self:SelectNextPage() end)
    bttnNext:SetNormalTexture("ESOUI/art/miscellaneous/Gamepad/spinner_arrow_right_up.dds")
    bttnNext:SetMouseOverTexture("ESOUI/art/miscellaneous/Gamepad/spinner_arrow_right_down.dds")
    bttnNext:SetPressedTexture("ESOUI/art/miscellaneous/Gamepad/spinner_arrow_right_disabled.dds")

    self.pageTitle = CreatePageTitle()
    self.pageTitle:SetAnchor(LEFT, bttnNext, RIGHT, 0, 0)

    lblDeletePrompt:SetText("|cFF0000".. self._msg.confirmDeletePagePromptOld .."|r")
    lblDeletePrompt:SetFont("ZoFontWinH3")
    lblDeletePrompt:SetColor(1, 1, 1, 1)
    lblDeletePrompt:SetAnchor(TOPLEFT, roleIcon, BOTTOMLEFT, 0, 0)
    lblDeletePrompt:SetHidden(true)

    bttnDeleteConfirm:SetDimensions(25, 25)
    bttnDeleteConfirm:SetAnchor(LEFT, lblDeletePrompt, RIGHT, 0, 0)
    bttnDeleteConfirm:SetState(BSTATE_NORMAL)
    bttnDeleteConfirm:SetHandler("OnClicked", function()
      bttnPrev:SetHidden(false)
      bttnAdd:SetHidden(false)
      bttnDel:SetHidden(false)
      bttnNext:SetHidden(false)
      lblDeletePrompt:SetHidden(true)
      bttnDeleteConfirm:SetHidden(true)
      bttnDeleteCancel:SetHidden(true)
      DressingRoom:DeleteCurrentPage()
      self.isDeletingPage = false
    end)
    bttnDeleteConfirm:SetNormalTexture("ESOUI/art/buttons/accept_up.dds")
    bttnDeleteConfirm:SetMouseOverTexture("ESOUI/art/buttons/accept_over.dds")
    bttnDeleteConfirm:SetPressedTexture("ESOUI/art/buttons/accept_down.dds")
    bttnDeleteConfirm:SetHidden(true)

    bttnDeleteCancel:SetDimensions(25, 25)
    bttnDeleteCancel:SetAnchor(LEFT, bttnDeleteConfirm, RIGHT, 0, 0)
    bttnDeleteCancel:SetState(BSTATE_NORMAL)
    bttnDeleteCancel:SetHandler("OnClicked", function()
      bttnPrev:SetHidden(false)
      bttnAdd:SetHidden(false)
      bttnDel:SetHidden(false)
      bttnNext:SetHidden(false)
      lblDeletePrompt:SetHidden(true)
      bttnDeleteConfirm:SetHidden(true)
      bttnDeleteCancel:SetHidden(true)
      self.isDeletingPage = false
    end)
    bttnDeleteCancel:SetNormalTexture("ESOUI/art/buttons/decline_up.dds")
    bttnDeleteCancel:SetMouseOverTexture("ESOUI/art/buttons/decline_over.dds")
    bttnDeleteCancel:SetPressedTexture("ESOUI/art/buttons/decline_down.dds")
    bttnDeleteCancel:SetHidden(true)
   else
    self.pageSelector = CreatePageSelector(self)
    self.pageSelector:SetAnchor(LEFT, roleIcon, RIGHT, 3, 0)

    local bttnAdd = WINDOW_MANAGER:CreateControl("DressingRoomWin_Add", DressingRoomWin, CT_BUTTON)
    local bttnEdit = WINDOW_MANAGER:CreateControl("DressingRoomWin_Edit", DressingRoomWin, CT_BUTTON)
    local bttnDel = WINDOW_MANAGER:CreateControl("DressingRoomWin_Delete", DressingRoomWin, CT_BUTTON)

    bttnAdd:SetDimensions(32, 32)
    bttnAdd:SetAnchor(LEFT, self.pageSelector, RIGHT, 0, 0)
    bttnAdd:SetState(BSTATE_NORMAL)
    bttnAdd:SetHandler("OnClicked", function()
      self:AddPage()
      self:SelectPage(#self.ram.page.pages)
      self:RefreshWindowData()
    end)
    bttnAdd:SetNormalTexture("ESOUI/art/buttons/plus_up.dds")
    bttnAdd:SetMouseOverTexture("ESOUI/art/buttons/plus_over.dds")
    bttnAdd:SetPressedTexture("ESOUI/art/buttons/plus_down.dds")

    bttnEdit:SetDimensions(32, 32)
    bttnEdit:SetAnchor(LEFT, bttnAdd, RIGHT, 0, 0)
    bttnEdit:SetState(BSTATE_NORMAL)
    bttnEdit:SetHandler("OnClicked", function()
      self:ShowEditPageNameDialog()
      self:RefreshWindowData()
    end)
    bttnEdit:SetNormalTexture("ESOUI/art/buttons/edit_up.dds")
    bttnEdit:SetMouseOverTexture("ESOUI/art/buttons/edit_over.dds")
    bttnEdit:SetPressedTexture("ESOUI/art/buttons/edit_down.dds")

    bttnDel:SetDimensions(32, 32)
    bttnDel:SetAnchor(LEFT, bttnEdit, RIGHT, 0, 0)
    bttnDel:SetState(BSTATE_NORMAL)
    bttnDel:SetHandler("OnClicked", function()
      if self.sv.page.current == 1 then return end
      if self.options.confirmPageDelete then
        self:ShowConfirmDeletePageDialog()
      else
        self:DeleteCurrentPage()
      end
    end)
    bttnDel:SetNormalTexture("ESOUI/art/buttons/minus_up.dds")
    bttnDel:SetMouseOverTexture("ESOUI/art/buttons/minus_over.dds")
    bttnDel:SetPressedTexture("ESOUI/art/buttons/minus_down.dds")

   end
  end

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
      b:SetHidden(self.options.activeBarOnly and bar ~= activePair)
      self.barBtn[setId][bar] = b
      
      -- skills border
      b = WINDOW_MANAGER:CreateControl('DressingRoom_SkillBorder_'..setId.."_"..bar, DressingRoomWin, CT_BACKDROP)
      b:SetAnchor(LEFT, self.skillBtn[setId][bar][1], LEFT, -1, 0)
      b:SetEdgeTexture("", 1, 1, 1)
      b:SetCenterColor(1, 0.73, 0.35, 0.05)
      b:SetEdgeColor(0.7, 0.7, 0.6, 1)
    end
    
    -- gear set button
    local b = CreateButton("DressingRoom_GearBtn_"..setId)
    b:SetAnchor(BOTTOM, self.barBtn[setId][1], TOP, 0, -2)
    b:SetNormalTexture("ESOUI/art/guild/tabicon_heraldry_up.dds")
    b:SetMouseOverTexture("ESOUI/art/guild/tabicon_heraldry_over.dds")
    b:SetPressedTexture("ESOUI/art/guild/tabicon_heraldry_down.dds")
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
    b:SetPressedTexture("")
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
          self.barBtn[setId][bar]:SetHidden(self.options.activeBarOnly and bar ~= activePair)
        end
      end
    end)
  self:ResizeWindow()
end

function DressingRoom:ResizeWindow()
  local sbtnSize = self.options.btnSize
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
        if self.options.columnMajorOrder then
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

  if self.pageSelector then
    if self.numCols > 1 then
      self.pageSelector:SetWidth(math.min(DressingRoomWin:GetWidth() / 2 - 192, 256))
    else
      self.pageSelector:SetWidth(math.min(DressingRoomWin:GetWidth() - 256, 256))
    end
  end
end


function DressingRoom:RefreshWindowData()
  local roleIcon = WINDOW_MANAGER:GetControlByName("DressingRoomWin_RoleIcon")
  if roleIcon then
    self:SetRoleIconTexture(roleIcon, self.currentGroupRole)
  end

  if self.enablePages then
   if self.useOldUI then
    if self.numCols > 1 then
      self.pageTitle:SetText(string.format("|cFFCC99%s|r |c80664D(%d/%d)|r", self.ram.page.name[self.sv.page.current], self.sv.page.current, #self.ram.page.pages))
    else
      self.pageTitle:SetText(string.format("|c80664D(%d/%d)|r", self.sv.page.current, #self.ram.page.pages))
    end
   else
    UpdatePageSelector(self)
    self.pageSelector.dropdown:SelectItemByIndex(self.sv.page.current, true)
   end
  end
  local activePair = GetActiveWeaponPairInfo()
  for setId = 1, self:numSets() do
    self.setBtn[setId]:SetFont("$(MEDIUM_FONT)|"..self.options.fontSize)
    local gearSet = self.ram.page.pages[self.sv.page.current].gearSet[setId]
    self.setLabel[setId]:SetFont("$(MEDIUM_FONT)|"..self.options.fontSize)
    self.setLabel[setId].editbox:SetFont("$(MEDIUM_FONT)|"..self.options.fontSize)
    if gearSet then
      if gearSet.outfitIndex then
        local outfitName = GetOutfitName(gearSet.outfitIndex)
        if outfitName == "" then outfitName = "Outfit "..gearSet.outfitIndex end
        self.setLabel[setId].text = gearSet.text.."\n("..outfitName..")"
      else
        self.setLabel[setId].text = gearSet.text
      end
      self.setLabel[setId]:SetText("|cC8C8C8("..gearSet.name..")|r")
    else
      self.setLabel[setId].text = nil
      self.setLabel[setId]:SetText("")
    end
    if self.ram.page.pages[self.sv.page.current].customSetName[setId] then self.setLabel[setId]:SetText(self.ram.page.pages[self.sv.page.current].customSetName[setId]) end
    for bar = 1, 2 do
      local skillBar = self.ram.page.pages[self.sv.page.current].skillSet[setId][bar]
      self.barBtn[setId][bar]:SetHidden(self.options.activeBarOnly and bar ~= activePair)
      for sk = 1, 6 do
        local btn = self.skillBtn[setId][bar][sk]
        if skillBar[sk] then
          local type, line = GetSkillLineIndicesFromSkillId(skillBar[sk].skillLineId)
          local name, texture = GetSkillAbilityInfo(type, line, skillBar[sk].ability)
          btn:SetNormalTexture(texture)
          btn:SetAlpha(1)
          btn.text = zo_strformat(SI_ABILITY_NAME, name)
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
      SCENE_MANAGER:ShowTopLevel(DressingRoomWin)
      if onShow then onShow(...) end
    end)
    control:SetHandler("OnHide", function(...)
      SCENE_MANAGER:HideTopLevel(DressingRoomWin)
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
  if not LAM then return end
  
  local panelData = {
    type = "panel",
    name = "Dressing Room",
    author = "|cffff99@Toloache|r, code65536, dividee",
    version = DressingRoom.version,
    slashCommand = "/dressingroom",
    registerForRefresh = true,
    website = "https://www.esoui.com/downloads/fileinfo.php?id=2138",
    feedback = "https://www.esoui.com/downloads/fileinfo.php?id=2138#comments",
  }
  
  LAM:RegisterAddonPanel("DressingRoomOptions", panelData)
  
  local txt = self._msg.options
  local defaults = self.default_options
  
  local function GetAlphaGearImportButtonTooltip()
    local alphaGearInstalledVersion = DressingRoom:DetectAlphaGear()
    local alphaGearCompatibleVersion = DressingRoom:GetCompatibleAlphaGearVersion()
    if not alphaGearInstalledVersion then
      return txt.importAlphaGearNotDetected
    end
    local versionMismatchWarning = ""
    if alphaGearInstalledVersion ~= alphaGearCompatibleVersion then
      versionMismatchWarning = "\n|cff0000"..txt.importAlphaGearVersionMismatchWarning.."\n'AlphaGear 2 "..alphaGearInstalledVersion.."'|r"
    end
    return string.format(txt.importAlphaGearWarning, alphaGearCompatibleVersion, versionMismatchWarning)
  end
  
  local optionsData = {
    {
      type = "checkbox",
      name = txt.accountWideSettings.name,
      tooltip = txt.accountWideSettings.tooltip,
      default = false,
      getFunc = function() return self.svAccWide.accountWideSettings end,
      setFunc = function(value) self.svAccWide.accountWideSettings = value end,
      warning = txt.reloadUIWarning,
    },
    {
      type = "header",
      name = txt.sectionBehaviour,
    },
    {
      type = "checkbox",
      name = txt.autoRechargeWeapons.name,
      tooltip = txt.autoRechargeWeapons.tooltip,
      default = defaults.autoRechargeWeapons,      
      getFunc = function() return self.options.autoRechargeWeapons end,
      setFunc = function(value) self.options.autoRechargeWeapons = value end,
    },
    {
      type = "checkbox",
      name = txt.clearEmptyGear.name,
      tooltip = txt.clearEmptyGear.tooltip,
      default = defaults.clearEmptyGear,      
      getFunc = function() return self.options.clearEmptyGear end,
      setFunc = function(value) self.options.clearEmptyGear = value end,
    },
    {
      type = "checkbox",
      name = txt.clearEmptyPoisons.name,
      tooltip = txt.clearEmptyPoisons.tooltip,
      default = defaults.clearEmptyPoisons,      
      getFunc = function() return self.options.clearEmptyPoisons or self.options.clearEmptyGear end,
      setFunc = function(value) self.options.clearEmptyPoisons = value end,
      disabled = function() return self.options.clearEmptyGear end,
    },
    {
      type = "checkbox",
      name = txt.clearEmptySkill.name,
      tooltip = txt.clearEmptySkill.tooltip,
      default = defaults.clearEmptySkill,
      getFunc = function() return self.options.clearEmptySkill end,
      setFunc = function(value) self.options.clearEmptySkill = value end,
    },
    {
      type = "checkbox",
      name = txt.ignoreAppearanceSlot.name,
      tooltip = txt.ignoreAppearanceSlot.tooltip,
      default = defaults.ignoreAppearanceSlot,
      getFunc = function() return self.options.ignoreAppearanceSlot end,
      setFunc = function(value) self.options.ignoreAppearanceSlot = value end,
    },
    {
      type = "checkbox",
      name = txt.enableOutfits.name,
      tooltip = txt.enableOutfits.tooltip,
      default = defaults.enableOutfits,
      getFunc = function() return self.options.enableOutfits end,
      setFunc = function(value) self.options.enableOutfits = value end,
    },
    {
      type = "checkbox",
      name = txt.disableInCombat.name,
      tooltip = txt.disableInCombat.tooltip,
      default = defaults.disableInCombat,
      getFunc = function() return self.options.disableInCombat end,
      setFunc = function(value) self.options.disableInCombat = value end,
    },
    {
      type = "checkbox",
      name = txt.roleSpecificPresets.name..
        " |t32:32:ESOUI/art/lfg/lfg_dps_up.dds|t"..
        "|t32:32:ESOUI/art/lfg/lfg_tank_up.dds|t"..
        "|t32:32:ESOUI/art/lfg/lfg_healer_up.dds|t",
      tooltip = txt.roleSpecificPresets.tooltip,
      default = defaults.roleSpecificPresets,
      getFunc = function() return self.options.roleSpecificPresets end,
      setFunc = function(value) self.options.roleSpecificPresets = value end,
      warning = txt.reloadUIWarning,
    },
    {
      type = "checkbox",
      name = txt.roleFromLFGTool.name,
      tooltip = txt.roleFromLFGTool.tooltip,
      default = defaults.roleFromLFGTool,
      getFunc = function() return self.options.roleFromLFGTool end,
      setFunc = function(value) self.options.roleFromLFGTool = value self:SetUpdateSelectedLFGRoleHook(value) end,
      disabled = function() return not self.roleSpecificPresets end,
    },
    {
      type = "checkbox",
      name = txt.autoSaveChangesOnClose.name,
      tooltip = txt.autoSaveChangesOnClose.tooltip,
      default = defaults.autoSaveChangesOnClose,
      getFunc = function() return self.options.autoSaveChangesOnClose end,
      setFunc = function(value) self.options.autoSaveChangesOnClose = value end,
    },
    {
      type = "button",
      name = GetString(SI_GAME_MENU_KEYBINDINGS),
      func = function() self:OpenKeyBindings() end
    },
    {
      type = "header",
      name = txt.sectionUI,
    },
    {
      type = "checkbox",
      name = txt.showNotificationArea.name,
      tooltip = txt.showNotificationArea.tooltip,
      default = defaults.showNotificationArea,
      getFunc = function() return self.options.showNotificationArea end,
      setFunc = function(value) self.options.showNotificationArea = value DressingRoomNotificationArea_Label:SetHidden(not value) end,
    },
    {
      type = "checkbox",
      name = txt.lockNotificationArea.name,
      tooltip = txt.lockNotificationArea.tooltip,
      default = defaults.lockNotificationArea,
      getFunc = function() return self.options.lockNotificationArea end,
      setFunc = function(value) self.options.lockNotificationArea = value DressingRoomNotificationArea_Label:SetMovable(not value) end,
    },
    { 
      type = "checkbox",
      name = txt.activeBarOnly.name,
      tooltip = txt.activeBarOnly.tooltip,
      default = defaults.activeBarOnly,
      getFunc = function() return self.options.activeBarOnly end,
      setFunc = function(value) self.options.activeBarOnly = value; self:RefreshWindowData() end,
    },
    {
      type = "checkbox",
      name = txt.lockWindowPosition.name,
      tooltip = txt.lockWindowPosition.tooltip,
      default = defaults.lockWindowPosition,
      getFunc = function() return self.options.lockWindowPosition end,
      setFunc = function(value) self.options.lockWindowPosition = value DressingRoomWin:SetMovable(not value) end,
    },
    {
      type = "slider",
      name = txt.fontSize.name,
      tooltip = txt.fontSize.tooltip,
      min = 12,
      max = 24,
      default = defaults.fontSize,
      getFunc = function() return self.options.fontSize end,
      setFunc = function(value) self.options.fontSize = value; self:RefreshWindowData() end,
    },
    {
      type = "slider",
      name = txt.btnSize.name,
      tooltip = txt.btnSize.tooltip,
      min = 20,
      max = 64,
      default = defaults.btnSize,
      getFunc = function() return self.options.btnSize end,
      setFunc = function(value) self.options.btnSize = value; self:ResizeWindow() end,
    },
    {
      type = "checkbox",
      name = txt.columnMajorOrder.name,
      tooltip = txt.columnMajorOrder.tooltip,
      default = defaults.columnMajorOrder,
      getFunc = function() return self.options.columnMajorOrder end,
      setFunc = function(value) self.options.columnMajorOrder = value; self:ResizeWindow() end,
    },
    {
      type = "checkbox",
      name = txt.showChatMessages.name,
      tooltip = txt.showChatMessages.tooltip,
      default = defaults.showChatMessages,
      getFunc = function() return self.options.showChatMessages end,
      setFunc = function(value) self.options.showChatMessages = value end,
    },
    {
      type = "checkbox",
      name = txt.openWithSkillsWindow.name,
      tooltip = txt.openWithSkillsWindow.tooltip,
      default = defaults.openWithSkillsWindow,
      getFunc = function() return self.options.openWithSkillsWindow end,
      setFunc = function(value) self.options.openWithSkillsWindow = value; self:OpenWith(ZO_Skills, value) end,
    },
    {
      type = "checkbox",
      name = txt.openWithInventoryWindow.name,
      tooltip = txt.openWithInventoryWindow.tooltip,
      default = defaults.openWithInventoryWindow,
      getFunc = function() return self.options.openWithInventoryWindow end,
      setFunc = function(value) self.options.openWithInventoryWindow = value; self:OpenWith(ZO_PlayerInventory, value) end,
    },
    {
      type = "checkbox",
      name = txt.singleBarToCurrent.name,
      tooltip = txt.singleBarToCurrent.tooltip,
      default = defaults.singleBarToCurrent,
      getFunc = function() return self.options.singleBarToCurrent end,
      setFunc = function(value) self.options.singleBarToCurrent = value end,
    },
    {
      type = "slider",
      name = txt.numRows.name,
      tooltip = txt.numRows.tooltip,
      min = 1,
      max = 6,
      default = defaults.numRows,
      getFunc = function() return self.options.numRows end,
      setFunc = function(value) self.options.numRows = value end,
      warning = txt.reloadUIWarning,
    },
    {
      type = "slider",
      name = txt.numCols.name,
      tooltip = txt.numCols.tooltip,
      min = 1,
      max = 4,
      default = defaults.numCols,
      getFunc = function() return self.options.numCols end,
      setFunc = function(value) self.options.numCols = value end,
      warning = txt.reloadUIWarning,
    },
    {
      type = "checkbox",
      name = txt.autoCloseOnMovement.name,
      tooltip = txt.autoCloseOnMovement.tooltip,
      default = defaults.autoCloseOnMovement,
      getFunc = function() return self.options.autoCloseOnMovement end,
      setFunc = function(value) self.options.autoCloseOnMovement = value DressingRoom:SetUpAutoCloseOnMovement(value) end,
    },
    {
      type = "checkbox",
      name = txt.enablePages.name,
      tooltip = txt.enablePages.tooltip,
      default = defaults.enablePages,
      getFunc = function() return self.options.enablePages end,
      setFunc = function(value) self.options.enablePages = value end,
      warning = txt.reloadUIWarning,
    },
    {
      type = "checkbox",
      name = txt.confirmPageDelete.name,
      tooltip = txt.confirmPageDelete.tooltip,
      default = defaults.confirmPageDelete,
      getFunc = function() return self.options.confirmPageDelete and self.enablePages end,
      setFunc = function(value) self.options.confirmPageDelete = value end,
      disabled = function() return not self.enablePages end,
    },
    {
      type = "checkbox",
      name = txt.alwaysChangePageOnZoneChanged.name,
      tooltip = txt.alwaysChangePageOnZoneChanged.tooltip,
      default = defaults.alwaysChangePageOnZoneChanged,
      getFunc = function() return self.options.alwaysChangePageOnZoneChanged and self.enablePages end,
      setFunc = function(value) self.options.alwaysChangePageOnZoneChanged = value end,
      disabled = function() return not self.enablePages end,
    },
    {
      type = "checkbox",
      name = txt.useOldUI.name,
      tooltip = txt.useOldUI.tooltip,
      default = defaults.useOldUI,
      getFunc = function() return self.options.useOldUI end,
      setFunc = function(value) self.options.useOldUI = value end,
      warning = txt.reloadUIWarning,
    },
    {
      type = "button",
      name = txt.reloadUI,
      func = function() ReloadUI() end
    },
    {
      type = "header",
      name = txt.expertFeatures,
    },
    {
      type = "checkbox",
      name = txt.enableExpertFeatures.name,
      tooltip = txt.enableExpertFeatures.tooltip,
      getFunc = function() return self.enableExpertFeatures end,
      setFunc = function(value) self.enableExpertFeatures = value end,
    },
    {
      type = "dropdown",
      name = txt.changeDefaultRole.name,
      tooltip = txt.changeDefaultRole.tooltip,
      choices = GetFriendlyRoleNames(),
      default = GetFriendlyRoleName(self.sv.defaultRole),
      getFunc = function() return ({"Damage", "Tank", "Healer"})[self.sv.defaultRole] end,
      setFunc = function(value) DressingRoom:ChangeDefaultRole(value, self.exchangePages) end,
      disabled = function() return not self.enableExpertFeatures end,
      warning = txt.autoReloadUIWarning,
    },
    {
      type = "checkbox",
      name = txt.exchangePages.name,
      tooltip = string.format(txt.exchangePages.tooltip, GetFriendlyRoleName(self.sv.defaultRole)),
      getFunc = function() return self.exchangePages end,
      setFunc = function(value) self.exchangePages = value end,
      disabled = function() return not self.enableExpertFeatures end,
    },
    {
      type = "button",
      name = txt.purgeCharacterData.name,
      tooltip = txt.purgeCharacterData.tooltip,
      func = function() DressingRoom:PurgeCharacterData() end,
      disabled = function() return not self.enableExpertFeatures end,
      warning = txt.autoReloadUIWarning,
    },
    {
      type = "dropdown",
      name = txt.importPresetsFromCharacter.name,
      tooltip = txt.importPresetsFromCharacter.tooltip,
      choices = GetCharactersByClass(),
      getFunc = function() return "" end,
      setFunc = function(value) DressingRoom:ImportPresetsFromCharacter(self.charIdFromFancyName[value], self.purgePresetsBeforeImporting) end,
      disabled = function() return not self.enableExpertFeatures end,
      warning = txt.autoReloadUIWarning,
    },
    {
      type = "checkbox",
      name = txt.purgePresetsBeforeImporting.name,
      tooltip = txt.purgePresetsBeforeImporting.tooltip,
      getFunc = function() return self.purgePresetsBeforeImporting end,
      setFunc = function(value) self.purgePresetsBeforeImporting = value end,
      disabled = function() return not self.enableExpertFeatures end,
    },
    {
      type = "button",
      name = txt.importAlphaGear,
      tooltip = GetAlphaGearImportButtonTooltip(),
      func = function() DressingRoom:ImportAlphaGear(self.importAlphaGearRebindKeys) end,
      disabled = function() return not DressingRoom:DetectAlphaGear() or not self.enableExpertFeatures end,
      warning = GetAlphaGearImportButtonTooltip(),
    },
    {
      type = "checkbox",
      name = txt.importAlphaGearRebindKeys.name,
      tooltip = txt.importAlphaGearRebindKeys.tooltip,
      getFunc = function() return self.importAlphaGearRebindKeys end,
      setFunc = function(value) self.importAlphaGearRebindKeys = value end,
      disabled = function() return not DressingRoom:DetectAlphaGear() or not self.enableExpertFeatures end,
    },
  }
  
  LAM:RegisterOptionControls("DressingRoomOptions", optionsData)  
  CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", function(panel)
      if panel:GetName() ~= "DressingRoomOptions" then return end
      local bttnToggleWindow = WINDOW_MANAGER:CreateControlFromVirtual(nil, panel, "ZO_DefaultButton")
      bttnToggleWindow:SetText(GetString(SI_BINDING_NAME_DRESSINGROOM_TOGGLE))
      bttnToggleWindow:SetAnchor(TOPRIGHT, panel, TOPRIGHT, -60, -4)
      bttnToggleWindow:SetWidth(230)
      bttnToggleWindow:SetHandler("OnClicked", function() SCENE_MANAGER:ToggleTopLevel(DressingRoomWin) end)
    end)
end
