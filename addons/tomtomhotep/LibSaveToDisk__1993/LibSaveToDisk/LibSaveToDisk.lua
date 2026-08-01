---@local lib @classdef LibSaveToDisk
local lib = LibStub:NewLibrary("LibSaveToDisk", 6)

if not lib then
  return    -- already loaded and no upgrade necessary
end



lib.name = "LibSaveToDisk"
lib.ver = 1
lib.savedVars = "LibSaveToDiskVars"
lib.displayVersion = "1.3g r6"


lib.defaultVars = {
  Settings = {
    RMLdelay = 5,
    CritMin = 0,
    NoncritMin = 0,
    NumNonsBeforeNote = 10,
  }
}


local COLOR_MSG = "|cff6633"
local COLOR_RED = "|cff0000"







lib.initialized = false

local SavedVariables
local Settings = {
  RMLdelay = 5,              -- When you click "Remind Me Later", the reminder will show again in this many minutes
  CritMin = 0,               -- Minimum time between Warnings, in minutes
  NoncritMin = 0,            -- Minimum time between Warnings, in minutes
  NumNonsBeforeNote = 10,
}



---------------------------------------------------------- Timer
--  calls a function after x minutes
---------------------------------------

local Timers = {}
local Timer = {}


function Timer:New(minutes, callback, params, deferred, once)
  local timer = {
    time = minutes * 60000,
    start = 0,
    current = 0,
    triggered = false,
    stopped = true,
    callback = callback,
    params = params,
    once = once
  }
  setmetatable(timer, { __index = Timer })
  table.insert(Timers, timer)
  
  if (not callback) then
    error(zo_strformat("Invalid callback (type <<1>>) in Timer:New()", type(callback)))
  end

  if (not deferred) then
    timer:Start()
  end

  return timer
end

setmetatable(Timer, { __call = Timer.New })


function Timer:Once(minutes, callback, params, deferred)
  return Timer(minutes, callback, params, deferred, true)
end


function Timer:Stop()
  self.stopped = true
end


function Timer:Continue()
  if ((self.triggered == false) and (self.stopped == true)) then
    local paused = (GetGameTimeMilliseconds() - self.current)
    self.start = self.start + paused
    self.stopped = false
    return paused
  end
  
  return false
end


function Timer:Start(newMinutes)
  
  if (type(newMinutes) == "number") then self.time = newMinutes * 60000 end
  
  if (not lib.initialized) then
    error("LibSaveToDisk must be initialized before use by calling :Init()")
  end
  
  self.start = GetGameTimeMilliseconds()
  self.triggered = false
  self.stopped = false
end


function Timer:Update(i)
  if (self.stopped or self.triggered) then
    return false
  end
  
  if (type(i) ~= "number") then i = 0 end
  
  self.current = GetGameTimeMilliseconds()
  
  if ((self.current - self.start) > self.time) then
    self.stopped = true
    self.triggered = true
    local k = 250 + (50 * i)
    zo_callLater(function () self.callback(self.params) end, k)
    if (self.once == true) then self:Destroy() end
    return true
  end
  
  return false
end


function Timer:Destroy()
  self.stopped = true

  local i = 0

  for j,timer in pairs(Timers) do
    if ((timer.start == self.start) and (timer.time == self.time)) then
      i = j
      break
    end
  end

  if (i > 0) then
    table.remove(Timers, i)
  end
end



function lib.OnUpdateEvent()
  for i, timer in pairs(Timers) do
    timer:Update(i)
  end
end


---------------------------------------------------------- end Timer


local LAM = LibStub("LibAddonMenu-2.0")

local theLAMPanel


local function CreateAddonMenu()
  
  local paneldata = {
    type = "panel",
    name = lib.name,
    displayName = "|c3366ffLib|r |cff6633Save To Disk|r",
    author = "|cff6633@tomtom|r|c3366ffhotep|r",
    version = lib.displayVersion,
    registerForRefresh = true,
  }
  
  
  local mainOptions = {
    
    {
      type = "slider",
      name = '"Remind Me Later" delay',
      tooltip = 'When you click "Remind Me Later", the reminder will show again in this many minutes.',
      min = 1,
      max = 60,
      step = 1,
      decimals = 0,
      getFunc = function () return Settings.RMLdelay end,
      setFunc = function (n) Settings.RMLdelay = n end,
    },
    
    {
      type = "slider",
      name = "Critical Warning Limit",
      tooltip = "Minimum time between Critical Warnings, in minutes.",
      min = 0,
      max = 10,
      step = 1,
      decimals = 0,
      getFunc = function () return Settings.CritMin end,
      setFunc = function (n) Settings.CritMin = n end,
    },
    
    {
      type = "slider",
      name = "Non-critical Warning Limit",
      tooltip = "Minimum time between Non-critical Warnings, in minutes.",
      min = 0,
      max = 120,
      step = 1,
      decimals = 0,
      getFunc = function () return Settings.NoncritMin end,
      setFunc = function (n) Settings.NoncritMin = n end,
    },
    
    {
      type = "slider",
      name = "Minimum Non-critical changes",
      tooltip = "Minimum number of Non-critical changes to your saved variables before you are prompted to Save them.",
      min = 1,
      max = 40,
      step = 1,
      decimals = 0,
      getFunc = function () return Settings.NumNonsBeforeNote end,
      setFunc = function (n) Settings.NumNonsBeforeNote = n end,
    },
    
  }
  
  
  theLAMPanel = LAM:RegisterAddonPanel(lib.name, paneldata)
  LAM:RegisterOptionControls(lib.name, mainOptions)
end
-- end CreateAddonMenu()


LibSaveToDisk_UI_Funcs = {}

local UI = LibSaveToDisk_UI_Funcs

local Addons = {}

local Manage = {
  numCrit = {addons = 0, count = 0},
  numNon = {addons = 0, count = 0},
  names = {},
  objects = {},
  lastCrit = 0,    -- timestamp of last notification
  lastNon = 0,     -- timestamp of last notification
  timer = false,
  later = false,   -- remind me later?
  shown = false,   -- warning is on screen now
}


function Addons:New(addonname, crit)
  local addon = {
    name = addonname,
    crit = crit,
    count = 1,
    when = GetTimeStamp(),
  }
  setmetatable(addon, { __index = Addons })
  table.insert(Manage.names, addon.name)
  
  if (crit) then
    Manage.numCrit.addons = Manage.numCrit.addons + 1
  else
    Manage.numNon.addons = Manage.numNon.addons + 1
  end
  
  return addon
end


function Manage.Process()
  
  if ((Manage.numCrit.count + Manage.numNon.count) == 0) then
    Manage.timer = false
    return
  end
  
  if (Manage.shown) then return end
  
  if (IsUnitInCombat("player")) then
    Manage.timer:Start()
    return
  end
  
  if (Manage.numCrit.count > 0) then
    if (GetDiffBetweenTimeStamps(GetTimeStamp(), Manage.lastCrit) > (Settings.CritMin * 60)) then
      if (not Manage.later or (GetDiffBetweenTimeStamps(GetTimeStamp(), Manage.lastCrit) > (Settings.RMLdelay * 60))) then
        Manage.lastCrit = GetTimeStamp()
        Manage.later = false
        UI:Warning(true)
        Manage.timer = false
        return
      end
    end
  elseif (Manage.numNon.count >= Settings.NumNonsBeforeNote) then
    if (GetDiffBetweenTimeStamps(GetTimeStamp(), Manage.lastNon) > (Settings.NoncritMin * 60)) then
      if (not Manage.later or (GetDiffBetweenTimeStamps(GetTimeStamp(), Manage.lastNon) > (Settings.RMLdelay * 60))) then
        Manage.lastNon = GetTimeStamp()
        Manage.later = false
        UI:Warning(false)
        Manage.timer = false
        return
      end
    end
  end
  
  Manage.timer:Start()
end

function Manage:Start()
  self.timer = Timer:New(0.25, Manage.Process)
end

function Manage:Add(addonname, crit)
  if (not self.objects[addonname] or (crit and not self.objects[addonname].crit)) then
    self.objects[addonname] = Addons:New(addonname, crit)
  else
    self.objects[addonname].count = self.objects[addonname].count + 1
  end
  
  if (crit) then
    self.numCrit.count = self.numCrit.count + 1
  else
    self.numNon.count = self.numNon.count + 1
  end
  
  if (not self.timer) then
    self:Start()
  end
end

function Manage:ToolTip()
  
  local txt = ""
  
  for name,obj in pairs(self.objects) do
    local count = obj.count
    local when = ZO_FormatDurationAgo(GetDiffBetweenTimeStamps(GetTimeStamp(), obj.when))
    txt = txt .. zo_strformat("<<1>><<2>>|r: <<3>> changes <<4>>.\n", COLOR_MSG, name, count, when)
  end
  
  return txt
end





--[[  ***********  Library API  ***********  ]]


function lib.CriticalChange(addonname)
  Manage:Add(addonname, true)
end

function lib.NonCriticalChange(addonname)
  Manage:Add(addonname, false)
end


--[[  *********  End Library API  *********  ]]





--  ***********  UI  ***********  


function UI:Warning(crit)
  
  Manage.shown = true
  
  local c = ""
  local a, n
  
  if (crit) then
    Manage.lastCrit = GetTimeStamp()
    c = "Critical"
    a = Manage.numCrit.addons
    n = Manage.numCrit.count
  else
    Manage.lastNon = GetTimeStamp()
    c = "non-critical"
    a = Manage.numNon.addons
    n = Manage.numNon.count
  end
  
  local msg = [[
%d Add-Ons have made %d %s changes to their Saved Variables.
These changes are %sONLY STORED IN MEMORY|r, and if your game crashes before you log out, %sTHEY WILL BE LOST!|r
]]
  
  msg = string.format(msg, a, n, c, COLOR_RED, COLOR_RED)
  
  LibSaveToDisk_UI_Message:SetText(msg)
  LibSaveToDisk_UI_Message.ToolTipText = Manage:ToolTip()
  
  SCENE_MANAGER:ShowTopLevel(LibSaveToDisk_UI)
end


function UI:SaveNow()
  SCENE_MANAGER:HideTopLevel(LibSaveToDisk_UI)
  ReloadUI("ingame")
end

function UI:Later()
  SCENE_MANAGER:HideTopLevel(LibSaveToDisk_UI)
  Manage.later = true
  Manage.shown = false
  Manage:Start()
end

function UI:Cancel()
  SCENE_MANAGER:HideTopLevel(LibSaveToDisk_UI)
  Manage.names = {}
  Manage.objects = {}
  Manage.numCrit.addons = 0
  Manage.numCrit.count = 0
  Manage.numNon.addons = 0
  Manage.numNon.count = 0
  Manage.shown = false
  Manage:Start()
end






function UI:Init()
  SCENE_MANAGER:RegisterTopLevel(LibSaveToDisk_UI, false)
  LibSaveToDisk_UI:SetDrawTier(2)
end



--  ***********  Init  ***********  


local function OnActivated()
  EVENT_MANAGER:UnregisterForEvent(lib.name, EVENT_PLAYER_ACTIVATED)
  
  CreateAddonMenu()
  UI:Init()
end



function lib:Init()
  
  if (lib.initialized) then return end
  
  lib.initialized = true
  
  SavedVariables = ZO_SavedVars:NewAccountWide(lib.savedVars, lib.ver, nil, lib.defaultVars)
  Settings = SavedVariables.Settings
  
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, OnActivated)
  EVENT_MANAGER:RegisterForUpdate(self.name, 250, self.OnUpdateEvent)
end





function lib.OnAddOnLoaded(event, addonName)
  if (addonName == lib.name) then
    EVENT_MANAGER:UnregisterForEvent(lib.name, EVENT_ADD_ON_LOADED)
    lib:Init()
  end
end


EVENT_MANAGER:RegisterForEvent(lib.name, EVENT_ADD_ON_LOADED, lib.OnAddOnLoaded)

