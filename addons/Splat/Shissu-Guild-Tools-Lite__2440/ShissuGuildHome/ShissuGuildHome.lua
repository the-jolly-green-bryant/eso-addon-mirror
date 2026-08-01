-- Shissu Guild Tools Addon
-- ShissuGuildHome
--
-- Version: v1.3.3
-- Last Update: 24.05.2019
-- Written by Christian Flory (@Shissu) - esoui@flory.one
-- Distribution without license is prohibited!
  
-- *** GLOBALS, VARS
--------------------  
local _globals = ShissuFramework["globals"]
local stdColor = _globals["stdColor"]
local white = _globals["white"]
local red = _globals["red"]
local blue = _globals["blue"]

local setPanel = ShissuFramework["setPanel"]
local createLabel = ShissuFramework["interface"].createLabel
local setDefaultColor = ShissuFramework["interface"].setDefaultColor
local createColorButton = ShissuFramework["interface"].createColorButton
                                                                                                                                                                                                                                         
local correctness = 0
local frameClose = 0

local _addon = {}
_addon.Name	= "ShissuGuildHome"
_addon.formattedName	= stdColor .. "Shissu" .. white .. "'s GuildHome"
_addon.Version = "1.3.3"
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

-- *** EINSTELLUNGEN
--------------------
_addon.panel = setPanel(_L("TITLE"), _addon.formattedName, _addon.Version)
_addon.controls = {}

function _addon.createSettingMenu()
  local controls = ShissuFramework._settings[_addon.Name].controls
  
  controls[#controls+1] = {
    type = "title",
    name = blue .. _L("COLOR")
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
    name = blue .. _L("TRADER")
  }   
           
  controls[#controls+1] = {
    type = "checkbox",
    name = _L("KIOSK"),
    tooltip = _L("KIOSK_TT"),
    getFunc = shissuGuildHome["kiosk"],
    setFunc = function(_, value)
      shissuGuildHome["kiosk"] = value 
      
      if (value == true) then _addon.initKioskTimer() end
    end,
  } 
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

    _addon.descriptionLeft = createLabel("SGT_DescriptionLeftLabel", ZO_GuildHomeInfoDescriptionSavingEdit, blue .. "100/252", nil, {-55, -51}, false, TOPRIGHT)
    
    local orgZO_GuildHomeInfoDescriptionSavingEdit = ZO_GuildHomeInfoDescriptionSavingEdit:GetHandler("OnTextChanged")
    local orgZO_GuildHomeInfoDescriptionModify = ZO_GuildHomeInfoDescriptionModify:GetHandler("OnClicked")
    
    ZO_GuildHomeInfoDescriptionModify:SetHandler("OnClicked", function() 
      _addon.buttons.desc1:SetColor(shissuColor["c1"][1], shissuColor["c1"][2], shissuColor["c1"][3], shissuColor["c1"][4])  
      _addon.buttons.desc2:SetColor(shissuColor["c2"][1], shissuColor["c2"][2], shissuColor["c2"][3], shissuColor["c2"][4])  
      _addon.buttons.desc3:SetColor(shissuColor["c3"][1], shissuColor["c3"][2], shissuColor["c3"][3], shissuColor["c3"][4])  
      _addon.buttons.desc4:SetColor(shissuColor["c4"][1], shissuColor["c4"][2], shissuColor["c4"][3], shissuColor["c4"][4])  
      _addon.buttons.desc5:SetColor(shissuColor["c5"][1], shissuColor["c5"][2], shissuColor["c5"][3], shissuColor["c5"][4])  
  
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
  
      SGT_DescriptionLeftLabel:SetText(color .. length .. blue .. "/" .. white .. "256")
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
    
    _addon.MotDLeft = createLabel("SGT_MotDLeftLabel", ZO_GuildHomeInfoMotDSavingEdit, blue .. "100/1000", nil, {-55, -51}, false, TOPRIGHT)
    
    local orgZO_GuildHomeInfoMotDSavingEdit = ZO_GuildHomeInfoMotDSavingEdit:GetHandler("OnTextChanged")
    local orgZO_GuildHomeInfoMotDModify = ZO_GuildHomeInfoMotDModify:GetHandler("OnClicked")
    
    ZO_GuildHomeInfoMotDModify:SetHandler("OnClicked", function() 
      _addon.buttons.motd1:SetColor(shissuColor["c1"][1], shissuColor["c1"][2], shissuColor["c1"][3], shissuColor["c1"][4])  
      _addon.buttons.motd2:SetColor(shissuColor["c2"][1], shissuColor["c2"][2], shissuColor["c2"][3], shissuColor["c2"][4])  
      _addon.buttons.motd3:SetColor(shissuColor["c3"][1], shissuColor["c3"][2], shissuColor["c3"][3], shissuColor["c3"][4])  
      _addon.buttons.motd4:SetColor(shissuColor["c4"][1], shissuColor["c4"][2], shissuColor["c4"][3], shissuColor["c4"][4])  
      _addon.buttons.motd5:SetColor(shissuColor["c5"][1], shissuColor["c5"][2], shissuColor["c5"][3], shissuColor["c5"][4])  
               
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
  
      _addon.MotDLeft:SetText(color .. length .. blue .. "/" .. white .. "1024")
    end)  
  end
end

-- *** GILDENHÄNDLER
--------------------
-- Sekunden in die Form: XXX Tage XX Stunden umrechnen
function _addon.secsToTime(time, complete)
  local day = math.floor(time / 86400)
  local hours = math.floor(time / 3600) - (day * 24)
  local minutes = math.floor(time / 60) - (day * 1440) - (hours * 60)
  local seconds = time % 60

  if complete then return ("%dd %dh %dmin %ds"):format(day, hours, minutes, seconds) end
  
  -- mehr als 1 Tag
  if(day >= 1) then return ("%dd %dh"):format(day, hours) end
  
  -- Spieler sind weniger als 1d Offline
  if(hours >= 1) then return ("%dh %dmin"):format(hours, minutes) end
  
  -- Spieler sind weniger als 1h Offline
  if(minutes >= 1) then return ("%dmin %ds"):format(minutes, seconds) end
  
  -- Spieler sind weniger als 1m Offline
  return ("%ds"):format(seconds)
end

function _addon.getKioskTime(which)     
  local hourSeconds = 60 * 60
  local daySeconds = 60 * 60 *24
  local weekSeconds = 7 * daySeconds
  
  -- Erste Woche 1970 beginnt Donnerstag -> Verschiebung auf Gebotsende
  local firstWeek = 1 + (5 * daySeconds) + (14 * hourSeconds)

  local currentTime = _addon.currentTime()                                

  -- Anzahl der Wochen seit 01.01.1970
  local week = math.floor(currentTime / weekSeconds)
  local beginnKiosk = firstWeek + (weekSeconds * week) + 60 *60
  
  -- Gebots Ende 
  if (which == 1) then
    beginnKiosk = beginnKiosk - 300
  -- Ersatzhändler
  elseif (which == 2) then
    beginnKiosk = beginnKiosk + 300                                                     
  end
                              
  -- Restliche Zeit in der Woche
  local restWeekTime = beginnKiosk - currentTime

  if restWeekTime < 0 then
    restWeekTime = restWeekTime + weekSeconds
  end

  return restWeekTime
end

function _addon.initKioskTimer()
  if _addon.activeControls["kiosk"] == true then return false end
  
  _addon.activeControls["kiosk"] = true
        
  -- Fensterelement
  _addon.time = CreateControlFromVirtual("SGT_HomeTimer", ZO_GuildHome, "ZO_DefaultTextButton")
  _addon.time:SetAnchor(TOPLEFT, ZO_GuildHome, TOPLEFT, 32, 590)
  _addon.time:SetWidth(180)
  _addon.time:SetHeight(100)
  _addon.time:SetHidden(false)  
  _addon.time:SetHandler("OnMouseEnter", function(self)
    ZO_Tooltips_ShowTextTooltip(self, TOPRIGHT, white.. _addon.secsToTime(_addon.getKioskTime(), true))
  end)                                                                          
  _addon.time:SetHandler("OnMouseExit", function(self)
    ZO_Tooltips_HideTextTooltip()
  end)  
  
  _addon.time:SetHandler("OnMouseUp", function(self) SGT_KioskTime:SetHidden(false) end) 
  
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
    local leftTime  = ZO_FormatTimeLargestTwo(_addon.getKioskTime(), TIME_FORMAT_STYLE_DESCRIPTIVE)
    _addon.time:SetText("|t36:36:EsoUI/Art/Guild/ownership_icon_guildtrader.dds|t" .."\n" .. stdColor .. _L("LEFTTIME") .. "\n" .. white .. leftTime)

    if (frameClose == 0 and _addon.currentTime() > _addon.currentTime() + _addon.getKioskTime() - 900 ) then
      SGT_KioskTime:SetHidden(false)
    end

    if (SGT_KioskTime:IsHidden() == false) then
      SGT_KioskTime_NextKioskCount:SetText(_addon.secsToTime(_addon.getKioskTime(), true))
      SGT_KioskTime_LastBidCount:SetText(red .. _addon.secsToTime(_addon.getKioskTime(1), true))
      SGT_KioskTime_ReplacementBidCount:SetText(blue .. _addon.secsToTime(_addon.getKioskTime(2), true))
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
                                        
  -- Gildenhändler
  SGT_KioskTime_Version:SetText(_addon.formattedName .. " " .. _addon.Version)
  setDefaultColor(SGT_KioskTime_Line)
  
  local closeTeleportButton = WINDOW_MANAGER:CreateControl(SGT_KioskTime_Close, SGT_KioskTime, CT_TEXTURE)
  closeTeleportButton:SetAnchor(TOPLEFT, parent, TOPRIGHT, -35, 2)
  closeTeleportButton:SetDimensions(28, 28)
  closeTeleportButton:SetTexture("ESOUI/art/buttons/decline_up.dds")
  closeTeleportButton:SetMouseEnabled(true)
  closeTeleportButton:SetHandler("OnMouseEnter", function(self) self:SetColor(0.2705882490, 0.5725490451, 1, 1) end)     
  closeTeleportButton:SetHandler("OnMouseExit", function(self) self:SetColor(1,1,1,1) end)  
  closeTeleportButton:SetHandler("OnMouseUp", function(self) 
    SGT_KioskTime:SetHidden(true) 
    frameClose = 1
  end) 
  
  -- Localization
  SGT_KioskTime_Title:SetText(_L("TRADER"))
  SGT_KioskTime_NextKiosk:SetText(_L("NEWKIOSK") .. ":")
  SGT_KioskTime_LastBid:SetText(_L("BIDEND") .. ":")
  SGT_KioskTime_ReplacementBid:SetText(_L("REPLACE") .. ":")
    
  if shissuGuildHome["kiosk"] then _addon.initKioskTimer() end
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