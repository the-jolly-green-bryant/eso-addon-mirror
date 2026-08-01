local ItemConditionAlert = {}
ItemConditionAlert = _G["ItemConditionAlert"]

local Items = {}
local EnableMove = false
local Initialized = false

function ItemConditionAlert:Init()

  self:LoadVars()
  --self:SetLanguage()
  ItemConditionAlert.Menu.CreateOptions()
  
  local MoveBG=WINDOW_MANAGER:CreateControl( "ItemConditionAlertMoveBg",  ItemConditionAlertTopControl, CT_BACKDROP)  
  ItemConditionAlertMoveBg:SetHidden(true)
  ItemConditionAlertMoveBg:SetAnchor(BOTTOMRIGHT, ItemConditionAlertTopControl, BOTTOMRIGHT, 0, 0)
  ItemConditionAlertMoveBg:SetAnchorFill(ItemConditionAlertTopControl)
  ItemConditionAlertMoveBg:SetCenterColor( 0,0,0,0.3 )
  ItemConditionAlertMoveBg:SetCenterTexture("",8,1,2)
  ItemConditionAlertMoveBg:SetEdgeColor( 0,0,0,0 )
  ItemConditionAlertMoveBg:SetEdgeTexture("",8,1,2)
  
  ItemConditionAlert.SlotItem:UpdateThresholds()
  Items = ItemConditionAlert.Layouter:getItemsLayout(ItemConditionAlert.sv.Layout)
  self:UpdateState()
  self:UpdateTopAnchor(ItemConditionAlert.sv.AnchorPosition)
  
  EnableMove = ItemConditionAlert.sv.Movable
  if EnableMove then self:EnableMove() end
  
  self:RegisterCommands()
  self:RegisterEvents()
  
  Initialized = true
  
  self:Redraw()
  
end


function ItemConditionAlert:LoadVars()
  ItemConditionAlert.sv = ZO_SavedVars:NewAccountWide(ItemConditionAlert.SvName,ItemConditionAlert.ConfigVersion, ItemConditionAlert.Name, ItemConditionAlert.SvDefaults)
end


function ItemConditionAlert:UpdateState()
  for k,v in pairs(Items) do
    v.State, v.Condition = ItemConditionAlert.SlotItem:GetState(v.Slot)
  end
end

function ItemConditionAlert:Update()

  if not Initialized then return end

  self:UpdateState()
  self:Redraw() 
  
end

function ItemConditionAlert:UpdateTopAnchor(position)
  if (position == nil) then position = TOPLEFT end
  ItemConditionAlertTopControl:ClearAnchors()
  ItemConditionAlertTopControl:SetAnchor(position, GuiRoot, position, ItemConditionAlert.sv.OffsetX, ItemConditionAlert.sv.OffsetY)
  ItemConditionAlertTopControl:SetScale(ItemConditionAlert.sv.Scale)
  ItemConditionAlertTopControl:SetDimensions(ItemConditionAlert.sv.DimX, ItemConditionAlert.sv.DimY)
end

function ItemConditionAlert:Redraw()  
  for k, v in pairs(Items) do
    local icon, _, _, _, _, _, _, _ = GetItemInfo(BAG_WORN, v.Slot)
    ItemConditionAlert.Drawer:Draw(icon, string.format("ItemConditionAlert_%s",v.Name), v.X, v.Y, v.State, v.Slot, v.Condition, v.Type, v.Ignoreautoswitch);
  end
end

function ItemConditionAlert:OnMoveStop()
  ItemConditionAlert.sv.AnchorPosition = TOPLEFT
  ItemConditionAlert.sv.OffsetX = ItemConditionAlertTopControl:GetLeft()
  ItemConditionAlert.sv.OffsetY = ItemConditionAlertTopControl:GetTop()
  self:UpdateTopAnchor(ItemConditionAlert.sv.AnchorPosition)
end

function ItemConditionAlert:SetScale(scale)
  if (not scale) then return end
  --d("ItemConditionAlert: Scale Set to ".. scale)
  ItemConditionAlert.sv.Scale = scale
  self:UpdateTopAnchor(ItemConditionAlert.sv.AnchorPosition)
  self:Update()
end

function ItemConditionAlert:ResetAddon()
  ItemConditionAlert.FLAG_REDRAW = true
  
  for k, v in pairs(ItemConditionAlert.SvDefaults) do
    ItemConditionAlert.sv[k] = v
  end
  Items = ItemConditionAlert.Layouter:getItemsLayout(ItemConditionAlert.sv.Layout)
  self:UpdateTopAnchor(ItemConditionAlert.sv.AnchorPosition)
  self:Update()
  ItemConditionAlert.FLAG_REDRAW = false
end

function ItemConditionAlert:EnableMove()
  d(ItemConditionAlert.Name.. ": Unlocked!")
  EnableMove = true
  ItemConditionAlert.sv.Movable = EnableMove
  ItemConditionAlertTopControl:SetMovable(true)
  ItemConditionAlertTopControl:SetMouseEnabled(true)
  ItemConditionAlertTopControl:SetAlpha(1)
  ItemConditionAlertMoveBg:SetHidden(false)
end

function ItemConditionAlert:DisableMove()
  d(ItemConditionAlert.Name.. ": Locked!")
  EnableMove = false
  ItemConditionAlert.sv.Movable = EnableMove
  ItemConditionAlertTopControl:SetMovable(false)
  ItemConditionAlertTopControl:SetMouseEnabled(false)
  ItemConditionAlertMoveBg:SetHidden(true)
end

function ItemConditionAlert:ToggleThreshold()
  d(ItemConditionAlert.Name.. ": Toggled visibility threshold!")
  ItemConditionAlert.sv.Nothreshold = not ItemConditionAlert.sv.Nothreshold
  self:Update()
end

function ItemConditionAlert:TogglePercentage()
  d(ItemConditionAlert.Name.. ": Toggled percentage display!")
  ItemConditionAlert.sv.Percentage = not ItemConditionAlert.sv.Percentage
  self:Update()
end

function ItemConditionAlert:SetLayout(layout)
  ItemConditionAlert.FLAG_REDRAW = true
  ItemConditionAlert.sv.Layout = layout
  Items= ItemConditionAlert.Layouter:getItemsLayout(ItemConditionAlert.sv.Layout)
  self:UpdateTopAnchor(ItemConditionAlert.sv.AnchorPosition)
  self:Update()
  ItemConditionAlert.FLAG_REDRAW = false
end


function ItemConditionAlert:SetVisibilityThreshold(threshold)
  ItemConditionAlert.sv.VisibilityThreshold = threshold
  self:Update()
end

function ItemConditionAlert:SetWeaponVisibThreshold(threshold)
  ItemConditionAlert.sv.WeaponVisibThreshold = threshold
  self:Update()
end

function ItemConditionAlert:Hide()
  ItemConditionAlertTopControl:SetHidden(true)
end

function ItemConditionAlert:Show()
  ItemConditionAlertTopControl:SetHidden(false)
end

-- Register events and PreHooks
function ItemConditionAlert:RegisterEvents()
  EVENT_MANAGER:RegisterForEvent(ItemConditionAlert.Name, EVENT_RETICLE_HIDDEN_UPDATE, function (...) self:OnReticleHidden(...) end)
  EVENT_MANAGER:RegisterForEvent(ItemConditionAlert.Name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function () self:Update() end)
  EVENT_MANAGER:RegisterForEvent(ItemConditionAlert.Name, EVENT_ACTIVE_WEAPON_PAIR_CHANGED, function () self:Update() end)
  
  ZO_PreHookHandler(ZO_CraftingResultsTopLevel, 'OnShow', function () self:Hide() end)
  ZO_PreHookHandler(ZO_CraftingResultsTopLevel, 'OnHide', function () self:Show() end)
  ZO_PreHookHandler(ZO_InteractWindow, 'OnShow', function () self:Hide() end)
  ZO_PreHookHandler(ZO_InteractWindow, 'OnHide', function () self:Show() end)
  ZO_PreHookHandler(ZO_PlayerBank, 'OnShow', function () self:Hide() end)
  ZO_PreHookHandler(ZO_PlayerBank, 'OnHide', function () self:Show() end)
  ZO_PreHookHandler(ZO_GuildBank, 'OnShow', function () self:Hide() end)
  ZO_PreHookHandler(ZO_GuildBank, 'OnHide', function () self:Show() end)
  ZO_PreHookHandler(ZO_TradingHouse, 'OnShow', function () self:Hide() end)
  ZO_PreHookHandler(ZO_TradingHouse, 'OnHide', function () self:Show() end)
  ZO_PreHookHandler(ZO_MainMenuCategoryBar, 'OnShow', function () self:Hide() end)
  ZO_PreHookHandler(ZO_MainMenuCategoryBar, 'OnHide', function () self:Show() end)
  ZO_PreHookHandler(ZO_LoreReader, 'OnShow', function () self:Hide() end)
  ZO_PreHookHandler(ZO_LoreReader, 'OnHide', function () self:Show() end)
  ZO_PreHookHandler(ZO_GameMenu_InGame, 'OnShow', function () self:Hide() end)
  ZO_PreHookHandler(ZO_GameMenu_InGame, 'OnHide', function () self:Show() end)
end

-- Define Handlers for events
function ItemConditionAlert:OnReticleHidden(eventCode, hidden)
  if (EnableMove) then return end

  if (hidden) then
    ItemConditionAlertTopControl:SetAlpha(ItemConditionAlert.sv.FadedAlpha)
  else
    ItemConditionAlertTopControl:SetAlpha(ItemConditionAlert.sv.Alpha)
  end
end

function ItemConditionAlert:RegisterCommands()

  SLASH_COMMANDS[ItemConditionAlert.Command] = function (...) self:commandHandler(...) end

end

function ItemConditionAlert:commandHandler( text )


  local funct = {
    ["?"] = _G["ItemConditionAlert"]["ShowHelp"],
    ["lock"] = _G["ItemConditionAlert"]["DisableMove"],
    ["unlock"] = _G["ItemConditionAlert"]["EnableMove"],
    ["threshold"] = _G["ItemConditionAlert"]["ToggleThreshold"],
    ["show"] = _G["ItemConditionAlert"]["Show"],
    ["percent"] = _G["ItemConditionAlert"]["TogglePercentage"],
    ["update"] = _G["ItemConditionAlert"]["Update"],
    ["reset"] = _G["ItemConditionAlert"]["ResetAddon"],
  }

  if (funct[text] == nil) then 
    
    d( ItemConditionAlert.Name.. ": Unrecognised Command: ".. text )
    self.ShowHelp()
    
  else
    
    funct[text](self)
    
  end 
  
end

--Displays help containing all available commands in the chat window
function ItemConditionAlert:ShowHelp()

    d( ItemConditionAlert.Name.. " V"..ItemConditionAlert.Version )
    d( "Commands: " )
    d( "    ".. ItemConditionAlert.Command.. " ?             -- ".. ItemConditionAlert.wordlist.CMD_HELP )
    d( "    ".. ItemConditionAlert.Command.. " lock          -- ".. ItemConditionAlert.wordlist.CMD_LOCK)
    d( "    ".. ItemConditionAlert.Command.. " unlock        -- ".. ItemConditionAlert.wordlist.CMD_UNLOCK)
    d( "    ".. ItemConditionAlert.Command.. " percent       -- ".. ItemConditionAlert.wordlist.CMD_PERCENT)
    d( "    ".. ItemConditionAlert.Command.. " threshold     -- ".. ItemConditionAlert.wordlist.CMD_THRESHOLD)
    d( "    ".. ItemConditionAlert.Command.. " show          -- ".. ItemConditionAlert.wordlist.CMD_SHOW)
    d( "    ".. ItemConditionAlert.Command.. " reset         -- ".. ItemConditionAlert.wordlist.CMD_RESET)
    
end
