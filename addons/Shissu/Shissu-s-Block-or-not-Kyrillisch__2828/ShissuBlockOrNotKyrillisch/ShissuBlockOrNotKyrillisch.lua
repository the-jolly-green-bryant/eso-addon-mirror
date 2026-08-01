-- Block or not kyrillisch (textfilter)
-- ------------------------------------
-- 
-- Desc:        Filterung von div. Textnachrichten; keine Einblendungen im Chat
-- Filename:    ShissuBlockOrNotKyrillisch.lua
-- Version:     1.1.1
-- Last Update: 19.11.2020
--
-- Written by Christian Flory (@Shissu, EU) - esoui@flory.one
-- Distribution without license is prohibited!

local _globals = ShissuFramework["globals"]
local setPanel = ShissuFramework["setPanel"]
local stdColor = _globals["stdColor"]
local white = _globals["white"]
local splitToArray = ShissuFramework["functions"]["datatypes"].splitToArray

local _addon = {}
_addon.Name	= "ShissuBlockOrNotKyrillisch"
_addon.Version = "1.1"
_addon.lastUpdate = "19.12.2020"
_addon.formattedName	= stdColor .. "Shissu" .. white .. "'s Block Or not Kyrillisch Chat" 
_addon.sFormattedName = stdColor .. "SBK"

_addon.settings = {
  ["guildAdvertising"] = true,
  ["itemAdvertising"] = true,
  ["achievments"] = true,
  ["kyrillisch"] = false,
  ["onlyKyrillisch"] = false,
  ["userFilter"] = false,
  ["userFilterText"] = false,
}

_addon.filter = {
  ["guildAdvertising"]  = { false,  {":guild", "neue mitspieler", "recruitment", "new players"}},
  ["itemAdvertising"]   = { false,  {":item", "wts", "sell", "buy", "wtb"}},
  ["achievments"]       = { false,  {":achievment"}},
  ["kyrillisch"]        = { false,  {"Б", "б", "в", "Г", "г", "Ж", "ж", "З", "з", "И", "и","Й","й","к", "Л", "л", "П", "п", "Ф" ,"ф","Ц", "ц", "Ч", "ч", "Ш", "ш", "Ш", "ш", "ъ", "Э", "э", "Ю", "ю","Я", "я"}},
  ["userFilter"]        = { false, {""}},
}

MEOWMEOW =_addon.filter 

local _L = ShissuFramework["func"]._L(_addon.Name)

_addon.panel = setPanel(_L("TITLE"), _addon.formattedName, _addon.Version, _addon.lastUpdate)
_addon.controls = {}

local ShissuChatFilter = ZO_SocialListKeyboard:Subclass()

TESTERTESTER = ShissuChatFilter

ShissuChatFilter.SORT_KEYS = {
  ["name"] = {},
}

function ShissuChatFilter:New(...)
  return ZO_SocialListKeyboard.New(self, ...)
end

function ShissuChatFilter:Initialize(control)     
  ZO_SocialListKeyboard.Initialize(self, control)

  control:SetHandler("OnEffectivelyHidden", function() self:OnEffectivelyHidden() end)

  ZO_ScrollList_AddDataType(self.list, 1, "ShissuChatFilterRow", 30, function(control, data) self:SetupRow(control, data) end)
  ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")
end

function ShissuChatFilter:BuildMasterList()
  self.masterList = {} 
  local len = #(_addon.protocol)
  local filter = ShissuChatFilter_FilterText:GetText()  or ""

  for i = 1, len do
    local data = {}

    data["name"] = _addon.protocol[i][1]
    data["text"] = _addon.protocol[i][2]

    if (filter == "" or string.find(data["name"], filter) or string.find(data["text"], filter)) then
      table.insert(self.masterList, data)
    end
  end  
end

function ShissuChatFilter:FilterScrollList()
  local scrollData = ZO_ScrollList_GetDataList(self.list)
  ZO_ClearNumericallyIndexedTable(scrollData)
  
  for i = 1, #self.masterList do
    if ((self.masterList[i].hidden == nil) or (self.masterList[i].hidden == false)) then
      local entry = self.masterList[i]
      table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1,  entry))
    end
  end
end

function ShissuChatFilter:SetupRow(control, data)
  control.data = data

  local nameControl = control:GetNamedChild('Name')
  nameControl:SetText(data.name) 

  local textControl = control:GetNamedChild('Text')
  textControl:SetText(data.text) 
end

function ShissuChatFilter:UnlockSelection()
  ZO_SortFilterList.UnlockSelection(self)
  self:RefreshVisible()
end

function ShissuChatFilter:OnEffectivelyHidden()
  ClearMenu()
end

function ShissuChatFilter:Refresh()
  ShissuChatFilter:BuildMasterList()
  self:RefreshData()
end
                                                                              
function ShissuChatFilter_OnInitialized(self)
  ShissuChatFilter = ShissuChatFilter:New(self)
end

function ShissuChatFilterRowName_OnMouseUp(self)
  local parent = self:GetParent()
  local data = ZO_ScrollList_GetData(parent)

  ShissuChatFilter:Refresh()
  ShissuChatFilter:BuildMasterList()
  ShissuChatFilter:Refresh()   
end

function ShissuChatFilterRowEnter(self)
  local parent = self:GetParent()
  local data = ZO_ScrollList_GetData(parent)

  self.cacheName = self:GetText()
  self:SetText(self.cacheName)

  ZO_Tooltips_ShowTextTooltip(self, TOPRIGHT, data["name"] .. "\n".. data["text"])
end

function ShissuChatFilterRowExit(self)
  self:SetText(self.cacheName)

  ZO_Tooltips_HideTextTooltip()
end

function _addon.createControls()
  local controls = _addon.controls 
  controls[#controls+1] = {
    type = "title",
    name = _L("GENERAL"),
  }

  controls[#controls+1] = {
    type = "description",
    text = _L("CMD"),
  }

  controls[#controls+1] = {
    type = "checkbox", 
    name = _L("GUILD"),
    getFunc = shissuBlockOrNotKyrillisch["guildAdvertising"],
    setFunc = function(_, value)
      shissuBlockOrNotKyrillisch["guildAdvertising"] = value
      _addon.filter["guildAdvertising"][1] = value
    end,
  }       
  
  controls[#controls+1] = {
    type = "checkbox", 
    name = _L("ITEMS"),
    getFunc = shissuBlockOrNotKyrillisch["itemAdvertising"],
    setFunc = function(_, value)
      shissuBlockOrNotKyrillisch["itemAdvertising"] = value
      _addon.filter["itemAdvertising"][1] = value
    end,
  }      

  controls[#controls+1] = {
    type = "checkbox", 
    name = _L("ACHIEVMENT"),
    getFunc = shissuBlockOrNotKyrillisch["achievments"],
    setFunc = function(_, value)
      shissuBlockOrNotKyrillisch["achievments"] = value
      _addon.filter["achievments"][1] = value
    end,
  }     
  
  controls[#controls+1] = {
    type = "title",
    name = _L("CYRILLIC"),
  }

  controls[#controls+1] = {
    type = "description",
    text = _L("DESC"),
  }

  controls[#controls+1] = {
    type = "checkbox", 
    name = _L("SET"),
    getFunc = shissuBlockOrNotKyrillisch["kyrillisch"],
    setFunc = function(_, value)
      shissuBlockOrNotKyrillisch["kyrillisch"] = value
      _addon.filter["kyrillisch"][1] = value
    end,
  }        

  controls[#controls+1] = {
    type = "checkbox", 
    name = _L("SET2"),
    getFunc = shissuBlockOrNotKyrillisch["onlyKyrillisch"],
    setFunc = function(_, value)
      shissuBlockOrNotKyrillisch["onlyKyrillisch"] = value
    end,
  }
  
  controls[#controls+1] = {
    type = "title",
    name = _L("USER"),
  }
  
  controls[#controls+1] = {
    type = "description",
    text = _L("USERHELP"),
  }

  controls[#controls+1] = {
    type = "description",
    text = "\n" .. _L("USEREXAMPLE") .. "\n",
  }

  controls[#controls+1] = {
    type = "checkbox", 
    name = _L("USER"),
    tooltip = _L("USER_TT"),
    getFunc = shissuBlockOrNotKyrillisch["userFilter"],
    setFunc = function(_, value)
      shissuBlockOrNotKyrillisch["userFilter"] = value
      _addon.filter["userFilter"][1] = value
    end,
  }       

  controls[#controls+1] = {
    type = "editbox",
    name = _L("USER_2"),
    getFunc = shissuBlockOrNotKyrillisch["userFilterText"],
    setFunc = function(value)
      shissuBlockOrNotKyrillisch["userFilterText"] = value 

      local data = splitToArray(value, ";")
      _addon.filter["userFilter"][2] = data
    end,
  }

  controls[#controls+1] = {
    type = "title",
    name = _L("PROTOCOL"),
  }

  controls[#controls+1] = {
    type = "checkbox", 
    name = _L("SAVE"),
    tooltip = _L("SAVE_TT"),
    getFunc = shissuBlockOrNotKyrillisch["saveProtocol"] or true,
    setFunc = function(_, value)
      shissuBlockOrNotKyrillisch["saveProtocol"] = value
    end,
  }     

  controls[#controls+1] = {
    type = "slider", 
    name = _L("COUNT"),
    tooltip = _L("COUNT_TT"),
    minimum=10,
    maximum=100,
    steps=1,
    getFunc = shissuBlockOrNotKyrillisch["saveCount"] or 20,
    setFunc = function(value)
      shissuBlockOrNotKyrillisch["saveCount"] = value
    end,
  }
end

_addon.protocol = {}

function _addon.addProtocol(from, text)
  if (text == nil) then return end

  local len = #(_addon.protocol)
  local max = shissuBlockOrNotKyrillisch["saveCount"] or 20

  if (len == max) then
    for i=2, len do
      _addon.protocol[i-1] = _addon.protocol[i]
    end

    _addon.protocol[max] = {from, text}
  else
    table.insert(_addon.protocol, {from, text})
    ShissuChatFilter:Refresh()
  end

  if (shissuBlockOrNotKyrillisch["saveProtocol"] == true or shissuBlockOrNotKyrillisch["saveProtocol"] == nil) then
    shissuBlockOrNotKyrillisch["protocol"] = _addon.protocol
  end
end

--function _addon.textFilter(text, rawText) 
local ChannelInfo = ZO_ChatSystem_GetChannelInfo()

function _addon.textFilter(messageType, fromName, text, isFromCustomerService, fromDisplayName, rawText)
  if (text == nil) then return end

  -- Den Filter nicht auf den Gilden, Flüstern und Gruppen anwenden.
  if ((messageType >= CHAT_CHANNEL_GUILD_1 and messageType <= CHAT_CHANNEL_GUILD_5) or messageType == CHAT_CHANNEL_WHISPER or messageType == CHAT_CHANNEL_PARTY) then
    return text
  end
  local cutStringAtLetter = ShissuFramework["functions"]["datatypes"].cutStringAtLetter
  local filteredTextFound = false
  local fromName = cutStringAtLetter(fromName, "^")
  fromName = white .. "[" .. stdColor .. zo_strformat(SI_UNIT_NAME, fromName) .. white .. "]"

  for filterName, filterData in pairs(_addon.filter) do
    local enabled = filterData[1]

    if (filterName == "kyrillisch" and shissuBlockOrNotKyrillisch["onlyKyrillisch"] == true) then enabled = true end

    if (enabled == true) then
      local filterText = filterData[2]

      for i=1, #filterText do
        if (string.find(text, filterText[i])) then
          if (shissuBlockOrNotKyrillisch["onlyKyrillisch"] == false) then
            _addon.addProtocol(fromName, rawText)
          end
          
          filteredTextFound = true
          break
        end
      end

      if (filteredTextFound == true) then break end
    end
  end

  if (filteredTextFound and shissuBlockOrNotKyrillisch["onlyKyrillisch"]) then
    return text
  elseif (filteredTextFound == false and shissuBlockOrNotKyrillisch["onlyKyrillisch"] == false) then
    return text
  end

  _addon.addProtocol(fromName, rawText)
end

function _addon.getSaves()
  _addon.filter["guildAdvertising"][1] = shissuBlockOrNotKyrillisch["guildAdvertising"]
  _addon.filter["itemAdvertising"][1] = shissuBlockOrNotKyrillisch["itemAdvertising"]
  _addon.filter["achievments"][1] = shissuBlockOrNotKyrillisch["achievments"]
  _addon.filter["kyrillisch"][1] = shissuBlockOrNotKyrillisch["kyrillisch"]
  _addon.filter["userFilter"][1] = shissuBlockOrNotKyrillisch["userFilter"] 

  if (shissuBlockOrNotKyrillisch["userFilterText"]) then
    local userFilterData = splitToArray(shissuBlockOrNotKyrillisch["userFilterText"], ";")
    _addon.filter["userFilter"][2] = userFilterData
  end

  if (shissuBlockOrNotKyrillisch["saveProtocol"] == true and shissuBlockOrNotKyrillisch["protocol"]) then 
    _addon.protocol = shissuBlockOrNotKyrillisch["protocol"]
  end
end

function _addon.initializedUI()
  local createFlatWindow = ShissuFramework["interface"].createFlatWindow
  local getWindowPosition = ShissuFramework["interface"].getWindowPosition
  local saveWindowPosition = ShissuFramework["interface"].saveWindowPosition

  local control = GetControl("ShissuChatFilter")

  if (shissuBlockOrNotKyrillisch["position"] == nil) then shissuBlockOrNotKyrillisch["position"] = {} end
  saveWindowPosition(control, shissuBlockOrNotKyrillisch["position"])

  if (shissuBlockOrNotKyrillisch["position"] ~= {}) then
    getWindowPosition(control, shissuBlockOrNotKyrillisch["position"])
  end

  createFlatWindow(
    "ShissuChatFilter",
    control,  
    {500, 300}, 
    function() ShissuChatFilter_FilterText:SetText("") control:SetHidden(true) end,
    "Chat-Filter"
  ) 
  
  ShissuChatFilter_Version:SetText(_addon.formattedName .. " " .. _addon.Version)

  ShissuChatFilter_FilterText:SetHandler("OnTextChanged", function()  
    ShissuChatFilter:BuildMasterList()
    ShissuChatFilter:Refresh()       
  end) 
  ShissuChatFilter_FilterText:SetDrawLayer(1)
  ShissuChatFilter_FilterText:SetHandler("OnMouseEnter", function() 
    ZO_Tooltips_ShowTextTooltip(ShissuChatFilter_FilterText, TOPRIGHT, white .. _L("FILTER_TT"))
  end)
  ShissuChatFilter_FilterText:SetHandler("OnMouseExit", ZO_Tooltips_HideTextTooltip)


  ShissuChatFilter = ShissuChatFilter:New(control)
  ShissuChatFilter:Refresh()   
  ShissuChatFilter:BuildMasterList()
  ShissuChatFilter:Refresh()     
end

function _addon.toggleWindow()
  local control = GetControl("ShissuChatFilter")
  if (control) then
    if (control:IsHidden()) then
      control:SetHidden(false)
    else
      control:SetHidden(true)
    end
  end
end

function _addon.initialized() 
  _addon.createControls()
  _addon.getSaves()
  _addon.initializedUI()
  
  ShissuFramework["interface"].initChatButton()

  ShissuFramework._bindings.sbkToogle = function() 
    local _P = ShissuFramework["functions"]["chat"].print

    if (_addon.filter["kyrillisch"][1] == true) then
      _addon.filter["kyrillisch"][1] = false
      shissuBlockOrNotKyrillisch["kyrillisch"] = false

      _P(_L("OFF"), nil, _addon.sFormattedName)
    else
      _addon.filter["kyrillisch"][1] = true
      shissuBlockOrNotKyrillisch["kyrillisch"] = true

      _P(_L("ON"), nil, _addon.sFormattedName)
    end
  end

  SLASH_COMMANDS["/chatfilter"] = _addon.toggleWindow
  
  local registerTextFilter = ShissuFramework["functions"]["chat"].registerTextFilter 
  registerTextFilter(_addon.Name, _addon.textFilter)
end

function _addon.EVENT_ADD_ON_LOADED(_, addOnName)
  if addOnName ~= _addon.Name then return end

  shissuBlockOrNotKyrillisch = shissuBlockOrNotKyrillisch or _addon.settings 

  if (shissuBlockOrNotKyrillisch == {} or (shissuBlockOrNotKyrillisch["enable"])) then
    shissuBlockOrNotKyrillisch = _addon.settings 
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