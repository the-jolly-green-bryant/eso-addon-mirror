-- Shissu's Guildhome
-- ------------------
-- 
-- Version:     1.4.6
-- Last Update: 06.12.2020
--
-- Written by Christian Flory (@Shissu, EU) - esoui@flory.one
-- Distribution without license is prohibited!

-- *** GLOBALS, VARS
--------------------  
local _globals = ShissuFramework["globals"]
local stdColor = _globals["stdColor"]
local white = _globals["white"]
local red = _globals["red"]
local yellow = _globals["yellow"]

local setPanel = ShissuFramework["setPanel"]
local createLabel = ShissuFramework["interface"].createLabel
local setDefaultColor = ShissuFramework["interface"].setDefaultColor

local createColorButton = ShissuFramework["interface"].coloredButton

local createFlatWindow = ShissuFramework["interface"].createFlatWindow
local getWindowPosition = ShissuFramework["interface"].getWindowPosition
local saveWindowPosition = ShissuFramework["interface"].saveWindowPosition

local getRestKioskTime = ShissuFramework["functions"]["date"].getRestKioskTime

local correctness = 0
local frameClose = 0

local _addon = {}
_addon.Name	= "ShissuGuildHome"
_addon.formattedName	= stdColor .. "Shissu" .. white .. "'s Guildhome"
_addon.Version = "1.4.6"
_addon.lastUpdate = "17.12.2020"
_addon.buttons = {}

_addon.settings = {
  ["kiosk"] = true,
  ["motd"] = true,
  ["desc"] = true,
}

_addon.activeControls = {
  ["kiosk"] = false,
}

local _L = ShissuFramework["func"]._L(_addon.Name)

-- EINSTELLUNGEN
--------------------
_addon.panel = setPanel(_L("TITLE"), _addon.formattedName, _addon.Version, _addon.lastUpdate)
_addon.controls = {}

function _addon.createSettingMenu()
  local controls = ShissuFramework._settings[_addon.Name].controls
  
  controls[#controls+1] = {
    type = "title",
    name = stdColor .. _L("COLOR")
  }   
  
  controls[#controls+1] = {
    type = "description",
    text = "|cCEE3F6" .. _L("COLOR_INFO")
  }   
     
  controls[#controls+1] = {
    type = "checkbox",
    name = _L("COLOR_MOTD"),
    getFunc = shissuGuildHome["motd"],
    setFunc = function(_, value)
      shissuGuildHome["motd"] = value 
      
      if (value == true) then
        if (_addon.buttons.motd1 ~= nil) then
          _addon.motdSetHidden(false)
        else
          _addon.showColorsControls()
        end
      else
        _addon.motdSetHidden(true)
      end      
    end,
  } 

  controls[#controls+1] = {
    type = "checkbox",
    name = _L("COLOR_DESC"),
    getFunc = shissuGuildHome["desc"],
    setFunc = function(_, value)
      shissuGuildHome["desc"] = value 
      
      if (value == true) then
       if (_addon.buttons.desc1 ~= nil) then
          _addon.descSetHidden(false)
        else
          _addon.showColorsControls()
        end
      else
        _addon.descSetHidden(true)
      end      
    end,  
  }      
  
  controls[#controls+1] = {
    type = "title",
    name = stdColor .. _L("TRADER")
  }   
           
  controls[#controls+1] = {
    type = "checkbox",
    name = _L("KIOSK"),
    tooltip = _L("KIOSK_TT"),
    getFunc = shissuGuildHome["kiosk"],
    setFunc = function(_, value)
      shissuGuildHome["kiosk"] = value 
      
      if (value == true) then 
        _addon.initKioskTimer() 
        _addon.toogleControl(SGT_HomeTimer, false)
      else
        _addon.toogleControl(ShissuKioskTimer, true)
        _addon.toogleControl(SGT_HomeTimer, true)
      end
    end,
  } 
end

function _addon.toogleControl(control, bool)
  if (control ~= nil) then
    control:SetHidden(bool)
  end
end

function _addon.descSetHidden(bool)
  if (_addon.buttons.desc1 ~= nil) then
    _addon.buttons.desc1:SetHidden(bool)
    _addon.buttons.desc2:SetHidden(bool)
    _addon.buttons.desc3:SetHidden(bool)
    _addon.buttons.desc4:SetHidden(bool)
    _addon.buttons.desc5:SetHidden(bool)
    _addon.buttons.descW:SetHidden(bool)       
    _addon.buttons.descANY:SetHidden(bool)   
  end
end

function _addon.motdSetHidden(bool)
  if (_addon.buttons.motd1 ~= nil) then
    _addon.buttons.motd1:SetHidden(bool)
    _addon.buttons.motd2:SetHidden(bool)
    _addon.buttons.motd3:SetHidden(bool)
    _addon.buttons.motd4:SetHidden(bool)
    _addon.buttons.motd5:SetHidden(bool)
    _addon.buttons.motdW:SetHidden(bool)       
    _addon.buttons.motdANY:SetHidden(bool)   
  end
end

-- * Einblenden der diversen Schaltflächen für die Farben
function _addon.showColorsControls()
  local buttonLabel
  local descWidth
  local editBox
  
  -- HINTERGRUNDINFORMATIONEN
  if (shissuGuildHome["desc"] == true and _addon.buttons.desc1 == nil) then    
    editBox = ZO_GuildHomeInfoDescriptionSavingEdit
    descWidth = editBox:GetWidth() - (editBox:GetWidth() * 0.40)
    buttonLabel = "SGT_GuildColor_Description"
    
    _addon.buttons.desc1 = createColorButton("1", editBox, "1", {-descWidth, -33}, buttonLabel, editBox)  
    _addon.buttons.desc2 = createColorButton("2", _addon.buttons.desc1, "2", nil, buttonLabel, editBox)  
    _addon.buttons.desc3 = createColorButton("3", _addon.buttons.desc2, "3", nil, buttonLabel, editBox)  
    _addon.buttons.desc4 = createColorButton("4", _addon.buttons.desc3, "4", nil, buttonLabel, editBox)  
    _addon.buttons.desc5 = createColorButton("5", _addon.buttons.desc4, "5", nil, buttonLabel, editBox)  
    _addon.buttons.descW = createColorButton("W", _addon.buttons.desc5, nil, nil, buttonLabel, editBox)  
    _addon.buttons.descANY = createColorButton("ANY", _addon.buttons.descW, nil, nil, buttonLabel, editBox)   

    _addon.descriptionLeft = createLabel("SGT_DescriptionLeftLabel", ZO_GuildHomeInfoDescriptionSavingEdit, stdColor .. "100/252", nil, {-55, -51}, false, TOPRIGHT)
    
    local orgZO_GuildHomeInfoDescriptionSavingEdit = ZO_GuildHomeInfoDescriptionSavingEdit:GetHandler("OnTextChanged")
    local orgZO_GuildHomeInfoDescriptionModify = ZO_GuildHomeInfoDescriptionModify:GetHandler("OnClicked")
    
    ZO_GuildHomeInfoDescriptionModify:SetHandler("OnClicked", function() 
      _addon.buttons.desc1:SetColor(shissuColor["c1"][1], shissuColor["c1"][2], shissuColor["c1"][3])  
      _addon.buttons.desc2:SetColor(shissuColor["c2"][1], shissuColor["c2"][2], shissuColor["c2"][3])  
      _addon.buttons.desc3:SetColor(shissuColor["c3"][1], shissuColor["c3"][2], shissuColor["c3"][3])  
      _addon.buttons.desc4:SetColor(shissuColor["c4"][1], shissuColor["c4"][2], shissuColor["c4"][3])  
      _addon.buttons.desc5:SetColor(shissuColor["c5"][1], shissuColor["c5"][2], shissuColor["c5"][3])  
  
      orgZO_GuildHomeInfoDescriptionModify()
    end)
      
    ZO_GuildHomeInfoDescriptionSavingEdit:SetHandler("OnTextChanged", function() 
      orgZO_GuildHomeInfoDescriptionSavingEdit()
      local control = ZO_GuildHomeInfoDescriptionSavingEdit
      local length = string.len(control:GetText())
      local color = white
  
      if length > 250 then
        color = red
      end
  
      SGT_DescriptionLeftLabel:SetText(color .. length .. stdColor .. "/" .. white .. "256")
    end)
  end
  
  -- NACHRICHT DES TAGES
  if (shissuGuildHome["motd"] == true and _addon.buttons.motd == nil) then         
    editBox = ZO_GuildHomeInfoMotDSavingEdit
    descWidth = editBox:GetWidth() - (editBox:GetWidth() * 0.40)
    buttonLabel = "SGT_GuildColor_motD"

    _addon.buttons.motd1 = createColorButton("1", editBox, "1", {-descWidth, -33}, buttonLabel, editBox)  
    _addon.buttons.motd2 = createColorButton("2", _addon.buttons.motd1, "2", nil, buttonLabel, editBox)  
    _addon.buttons.motd3 = createColorButton("3", _addon.buttons.motd2, "3", nil, buttonLabel, editBox)  
    _addon.buttons.motd4 = createColorButton("4", _addon.buttons.motd3, "4", nil, buttonLabel, editBox)  
    _addon.buttons.motd5 = createColorButton("5", _addon.buttons.motd4, "5", nil, buttonLabel, editBox)  
    _addon.buttons.motdW = createColorButton("W", _addon.buttons.motd5, nil, nil, buttonLabel, editBox)  
    _addon.buttons.motdANY = createColorButton("ANY", _addon.buttons.motdW, nil, nil, buttonLabel, editBox)   
    
    _addon.MotDLeft = createLabel("SGT_MotDLeftLabel", ZO_GuildHomeInfoMotDSavingEdit, stdColor .. "100/1000", nil, {-55, -51}, false, TOPRIGHT)
    
    local orgZO_GuildHomeInfoMotDSavingEdit = ZO_GuildHomeInfoMotDSavingEdit:GetHandler("OnTextChanged")
    local orgZO_GuildHomeInfoMotDModify = ZO_GuildHomeInfoMotDModify:GetHandler("OnClicked")
    
    ZO_GuildHomeInfoMotDModify:SetHandler("OnClicked", function() 
      _addon.buttons.motd1:SetColor(shissuColor["c1"][1], shissuColor["c1"][2], shissuColor["c1"][3])  
      _addon.buttons.motd2:SetColor(shissuColor["c2"][1], shissuColor["c2"][2], shissuColor["c2"][3])  
      _addon.buttons.motd3:SetColor(shissuColor["c3"][1], shissuColor["c3"][2], shissuColor["c3"][3])  
      _addon.buttons.motd4:SetColor(shissuColor["c4"][1], shissuColor["c4"][2], shissuColor["c4"][3])  
      _addon.buttons.motd5:SetColor(shissuColor["c5"][1], shissuColor["c5"][2], shissuColor["c5"][3])  
               
      orgZO_GuildHomeInfoMotDModify()
    end)
               
    ZO_GuildHomeInfoMotDSavingEdit:SetHandler("OnTextChanged", function() 
      orgZO_GuildHomeInfoMotDSavingEdit()                  
      local control = ZO_GuildHomeInfoMotDSavingEdit
      local length = string.len(control:GetText())          
      local color = white
  
      if length > 990 then
        color = red
      end
  
      _addon.MotDLeft:SetText(color .. length .. stdColor .. "/" .. white .. "1024")
    end)  
  end
end

function _addon.initKioskTimer()
  if _addon.activeControls["kiosk"] == true then return false end
  
  _addon.activeControls["kiosk"] = true
        
  -- Fensterelement
  _addon.time = CreateControlFromVirtual("SGT_HomeTimer", ZO_GuildHome, "ZO_DefaultTextButton")
  _addon.time:SetAnchor(TOPLEFT, ZO_GuildHome, TOPLEFT, 32, 560)
  _addon.time:SetWidth(180)
  _addon.time:SetHeight(100)
  _addon.time:SetHidden(false)  
  
  _addon.time:SetHandler("OnMouseEnter", function(self)
    local nextKiosk, _, _ = getRestKioskTime(true)
    ZO_Tooltips_ShowTextTooltip(self, TOPRIGHT, white.. nextKiosk)
  end)        

  _addon.time:SetHandler("OnMouseExit", function(self)
    ZO_Tooltips_HideTextTooltip()
  end)  
  
  _addon.time:SetHandler("OnMouseUp", function(self) 
    ShissuKioskTimer:SetHidden(false) 
  end) 
  
  _addon.kioskTimeUpdate(1000) 
end

function _addon.currentTime()
  local correction = GetSecondsSinceMidnight() - (GetTimeStamp() % 86400)
  if correction < -12*60*60 then correction = correction + 86400 end

  return GetTimeStamp() + correction
end


-- Gildenfenster, UPDATE EVENT
function _addon.kioskTimeUpdate(time)
  EVENT_MANAGER:UnregisterForUpdate("ShissuGT_KioskTimer")  
  
  EVENT_MANAGER:RegisterForUpdate("ShissuGT_KioskTimer", time, function()
    local nextKiosk, lastBid, replacementKiosk = getRestKioskTime()
    local leftTime  = ZO_FormatTimeLargestTwo(nextKiosk, TIME_FORMAT_STYLE_DESCRIPTIVE)
    _addon.time:SetText("|t64:64:EsoUI/Art/Guild/ownership_icon_guildtrader.dds|t" .."\n\n" .. stdColor .. _L("LEFTTIME") .. "\n" .. white .. leftTime)

    if (frameClose == 0 and _addon.currentTime() > _addon.currentTime() + nextKiosk - 900 ) then
      ShissuKioskTimer:SetHidden(false)
    end

    if (ShissuKioskTimer:IsHidden() == false) then
      local nextKiosk, lastBid, replacementKiosk = getRestKioskTime(true)
  
      ShissuKioskTimer_NextKioskCount:SetText(yellow .. nextKiosk)
      ShissuKioskTimer_LastBidCount:SetText(red .. lastBid)
      ShissuKioskTimer_ReplacementBidCount:SetText(stdColor .. replacementKiosk)
    end
    
     _addon.kioskTimeUpdate(1000) 
  end)
end

-- *** INITIALISIERUNG
----------------------
function _addon.initialized()
  _addon.createSettingMenu()  
  
  if (shissuColor ~= nil and(shissuGuildHome["motd"] or shissuGuildHome["desc"])) then   
    _addon.showColorsControls()
  end

  -- Mausclicks in den EditBoxen (MotD, Rest Standard) erlauben
  GUILD_HOME.motd.editBackdrop:SetDrawLayer(1)
                                        
  if shissuGuildHome["kiosk"] then 
    _addon.window_kioskTimer()
    _addon.initKioskTimer() 
  end  
end             

function _addon.window_kioskTimer()
  local control = GetControl("ShissuKioskTimer")

  createFlatWindow(
    "ShissuKioskTimer",
    control,  
    {330, 160}, 
    function() control:SetHidden(true) end,
    _L("TRADER")
  ) 

  ShissuKioskTimer_Version:SetText(_addon.formattedName .. " " .. _addon.Version)
  ShissuKioskTimer_NextKiosk:SetText(_L("NEWKIOSK") .. ":")
  ShissuKioskTimer_LastBid:SetText(_L("BIDEND") .. ":")
  ShissuKioskTimer_ReplacementBid:SetText(_L("REPLACE") .. ":")

  saveWindowPosition(control, shissuGuildHome["position"])
  getWindowPosition(control, shissuGuildHome["position"])
end

function _addon.EVENT_ADD_ON_LOADED(_, addOnName)
  if addOnName ~= _addon.Name then return end

  shissuGuildHome = shissuGuildHome or {}
    
  if shissuGuildHome["kiosk"] == nil then
    shissuGuildHome["kiosk"] = true
    shissuGuildHome["motd"] = true
    shissuGuildHome["desc"] = true
  end                      

  zo_callLater(function()              
    ShissuFramework._settings[_addon.Name] = {}
    ShissuFramework._settings[_addon.Name].panel = _addon.panel                                       
    ShissuFramework._settings[_addon.Name].controls = _addon.controls  

    ShissuFramework.initAddon(_addon.Name, _addon.initialized)
  end, 150) 
                                 
  EVENT_MANAGER:UnregisterForEvent(_addon.Name, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(_addon.Name, EVENT_ADD_ON_LOADED, _addon.EVENT_ADD_ON_LOADED)