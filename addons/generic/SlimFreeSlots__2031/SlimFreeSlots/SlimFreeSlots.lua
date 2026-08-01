-- Name: SlimSlimFreeSlots
-- Author: generic
-- Description: Displays free inventory slots without opening the bag screen.
-- Inspired by FreeSlots, but basically recoded almost from scratch

local wm = GetWindowManager()
local em = GetEventManager()
--local print = d


SlimFreeSlots = {}
SlimFreeSlots.name = "SlimFreeSlots"
SlimFreeSlots.displayName = 'SlimFreeSlots'
SlimFreeSlots.version	= "1.0.2"
SlimFreeSlots.settingsVersion = 4
SlimFreeSlots.defaults = {
    wm = {
        x = 30,
        y = 1035,
        width = 180,
        height = 50
    },
    colorgood = { 0, 1, 0 },
    showbox = true,
    showalerts = true,
    thresholds = {
      [1] = {
        color = { 1, 0, 0 },
        amountmin = 5
      },
      [2] = {
        color = { 1, 0.5, 0 },
        amountmin = 10
      },
      [3] = {
        color = { 1 , 1, 0 },
        amountmin = 20
      },
      [4] = {
        color = { 0, 1, 0 },
        amountmin = 30
      },
    }
}
local ALERT_COLORS = {
    [1] = ZO_ColorDef:New(1, 1, 0, 1),
    [2] = ZO_ColorDef:New(1, 0.5, 0, 1),
    [3] = ZO_ColorDef:New(1, 0, 0, 1),
    [4] = ZO_ColorDef:New(1, 0, 0, 1)
}


local InventoryTextBox
function SlimFreeSlots:ApplyStyle()
    SlimFreeSlotsUI:SetAnchor( TOPLEFT, GuiRoot, TOPLEFT, SlimFreeSlots.savedVars.wm.x, SlimFreeSlots.savedVars.wm.y )
    SlimFreeSlotsUI:SetWidth( SlimFreeSlots.savedVars.wm.width )
    SlimFreeSlotsUI:SetHeight( SlimFreeSlots.savedVars.wm.height )
    SlimFreeSlotsUI:SetHidden(not SlimFreeSlots.savedVars.showbox)
    SlimFreeSlotsUITitle:SetText("  " .. GetString(SI_SFS_FREE_INV));
    SlimFreeSlotsUIBankSlots:SetText("  " .. GetString(SI_SFS_FREE_BANK));
    local sceneHud = SCENE_MANAGER:GetScene("hud")
    local sceneHudUI = SCENE_MANAGER:GetScene("hudui")
    if SlimFreeSlots.savedVars.showbox then
      sceneHud:AddFragment(InventoryTextBox)
      sceneHudUI:AddFragment(InventoryTextBox)
    else
      sceneHud:RemoveFragment(InventoryTextBox)
      sceneHudUI:RemoveFragment(InventoryTextBox)
    end
end
local function initialize( eventCode, addOnName )  
    
    if ( addOnName ~= SlimFreeSlots.name ) then
        return
    end
    EVENT_MANAGER:UnregisterForEvent( "SlimFreeSlots" )
    
    SlimFreeSlots.savedVars = ZO_SavedVars:New( "SlimFreeSlotsSettings" , SlimFreeSlots.settingsVersion, nil, SlimFreeSlots.defaults, nil )
    SlimFreeSlots:InitializeSettingsMenu()
    InventoryTextBox = ZO_SimpleSceneFragment:New(SlimFreeSlotsUI)
    SlimFreeSlots:ApplyStyle()
end

EVENT_MANAGER:RegisterForEvent( "SlimFreeSlots" , EVENT_ADD_ON_LOADED , initialize )

local function getBankSpaceToDisplay()
    bankSpace = 0
    bankSpace = GetNumBagFreeSlots(BAG_BANK) + GetNumBagFreeSlots(BAG_SUBSCRIBER_BANK)
    totBankSpace = GetBagSize(BAG_BANK) + GetBagSize(BAG_SUBSCRIBER_BANK)
    SlimFreeSlotsUIBankSlotsDisplay:SetText(string.format("%d / %d", bankSpace, totBankSpace))
    return bankSpace
end

local lastbagspace = -1
local lastalertlevel = 0


function SlimFreeSlots:ShowSlimFreeSlots()
    if self.savedVars == nil then return end --Bug when loading takes forever
    local currentcolor = self.savedVars.colorgood
    local totalslots = GetBagSize(BAG_BACKPACK)
    
    bagspace = 0
    alertlevel = 0
    threshold = 0
    for checkspace = totalslots, 1, -1 do -- less than 1 will always fit
        if CheckInventorySpaceSilently(checkspace) == true then
            bagspace = checkspace
            break
        end
    end
    
    for threshnum_fromback = 1, 4 do
      if bagspace <= self.savedVars.thresholds[5 - threshnum_fromback].amountmin then
        alertlevel = threshnum_fromback
        currentcolor = self.savedVars.thresholds[5 - threshnum_fromback].color
        threshold = self.savedVars.thresholds[5 - threshnum_fromback].amountmin
      end
    end
    if bagspace == 0 then
      alertlevel = 5
    end
    
    if bagspace < lastbagspace and alertlevel > lastalertlevel then
      if self.savedVars.showalerts then
        local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.NONE)
        local displaytext = ''
        if alertlevel == 5 then
          displaytext = GetString(SI_SFS_ALERT_FULL)
        else
          displaytext = (GetString(SI_SFS_ALERT_THRESHOLD_REACHED)):format(threshold)
        end
        local color = ZO_ColorDef:New(unpack(currentcolor)) 
        displaytext = color:Colorize(displaytext)
        messageParams:MarkShowImmediately()
        messageParams:SetText(displaytext)
        CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
       end
    end
    
    if lastbagspace ~= bagspace then
        --color = unpack(currentcolor)
        red = currentcolor[1] * 255
        green = currentcolor[2] * 255
        blue = currentcolor[3] * 255
        alpha = 255
        SlimFreeSlotsUIStatus:SetColor(red, green, blue, alpha)
        SlimFreeSlotsUIStatus:SetText(string.format("%d / %d", bagspace, totalslots))
    end
    
    lastbagspace = bagspace
    lastalertlevel = alertlevel
    
    getBankSpaceToDisplay()
    return
end

function SlimFreeSlots:OnMoveStop( )
    SlimFreeSlots.savedVars.wm.x = self:GetLeft()
    SlimFreeSlots.savedVars.wm.y = self:GetTop()
    SlimFreeSlots.savedVars.wm.width = self:GetWidth()
    SlimFreeSlots.savedVars.wm.height = self:GetHeight()
end

function SlimFreeSlots:GetMinThreshold(threshnum)
  if num > 1 and num <= 4 then
    return math.max(self.savedVars.thresholds[threshnum].amountmin, self.savedVars.thresholds[threshnum - 1].amountmin)
  end
  return 0
end

function SlimFreeSlots:SanitizeThresholds()
  for threshnum = 2, 4 do
    SlimFreeSlots.savedVars.thresholds[threshnum].amountmin = math.max(SlimFreeSlots.savedVars.thresholds[threshnum].amountmin, SlimFreeSlots.savedVars.thresholds[threshnum - 1].amountmin) 
  end
end

function SlimFreeSlots:InitializeSettingsMenu()
  local menu = LibStub("LibAddonMenu-2.0")

  local panel = {
    type = "panel",
    name = SlimFreeSlots.name,
    displayName = SlimFreeSlots.displayName,
    author = SlimFreeSlots.author,
    version = SlimFreeSlots.version,
    --website = "http://www.esoui.com/downloads/info1851-GroupLeader.html",
    --slashCommand = "/sgl",
    registerForRefresh = true,
    registerForDefaults = true,
  }

  local options = {
    {
      type = "checkbox",
      name = SI_SFS_SETUP_SHOW_INVENTORYBOX,
      getFunc = function() return self.savedVars.showbox end,
      setFunc = function(value)
        self.savedVars.showbox = value
        SlimFreeSlots:ApplyStyle()
      end,
      default = true,
    },
    {
      type = "checkbox",
      name = SI_SFS_SETUP_SHOW_ALERTS,
      getFunc = function() return self.savedVars.showalerts end,
      setFunc = function(value)
        self.savedVars.showalerts = value
      end,
      default = true,
    },
    {
      type = "colorpicker",
      name = SI_SFS_SETUP_COLORGOOD,
      default = ZO_ColorDef:New(unpack(self.defaults.colorgood)),
      getFunc = function() return unpack(self.savedVars.colorgood) end,
      setFunc = function(r, g, b)
        self.savedVars.colorgood = {r, g, b}
        lastbagspace = -1
      end,
    }
    };
    for threshnum = 1, 4 do
      local option =  {
        type = "slider",
        name = function() return GetString(_G['SI_SFS_SETUP_THRESHOLD' .. threshnum]) end,
        tooltip = GetString(_G['SI_SFS_SETUP_THRESHOLD' .. threshnum .. '_DESC']),
        min = 0,
        max = 200,
        step = 1,
        decimals = 0,
        clampInput = true,
        getFunc = function() return self.savedVars.thresholds[threshnum].amountmin end,
        setFunc = function(value)
          self.savedVars.thresholds[threshnum].amountmin = value
          SlimFreeSlots:SanitizeThresholds()
          lastbagspace = -1
        end,
        default = self.defaults.thresholds[threshnum].amountmin,
        width = "half"
      }
      --if GetString('SI_SFS_SETUP_THRESHOLD' .. threshnum .. '_DESC') then
      --  option['tooltip'] = GetString(_G['SI_SFS_SETUP_THRESHOLD' .. threshnum .. '_DESC'])
      --end
      options[#options+1] = option
      option = {
        type = "colorpicker",
        default = ZO_ColorDef:New(unpack(self.defaults.thresholds[threshnum].color)),
        getFunc = function() return unpack(self.savedVars.thresholds[threshnum].color) end,
        setFunc = function(r, g, b)
          self.savedVars.thresholds[threshnum].color = {r, g, b}
          lastbagspace = -1
        end,
        width = "half"
      }
      options[#options+1] = option
    end
    menu:RegisterAddonPanel(self.name.."OptionsMenu", panel)
    menu:RegisterOptionControls(self.name.."OptionsMenu", options)
end


local BufferTable = {}

local function BufferReached(key, buffer)
    if key == nil then return end
    if BufferTable[key] == nil then BufferTable[key] = {} end
    BufferTable[key].buffer = buffer or 3
    BufferTable[key].now = GetFrameTimeSeconds()
    if BufferTable[key].last == nil then BufferTable[key].last = BufferTable[key].now end
    BufferTable[key].diff = BufferTable[key].now - BufferTable[key].last
    BufferTable[key].eval = BufferTable[key].diff >= BufferTable[key].buffer
    if BufferTable[key].eval then BufferTable[key].last = BufferTable[key].now end
    return BufferTable[key].eval
end

function SlimFreeSlots.OnUpdateHandler()
    if not BufferReached("slimfree", 1) then
        return
    end
    SlimFreeSlots:ShowSlimFreeSlots()
end
