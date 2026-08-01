-- ****************************************************************************
--                                  namespace
-- ****************************************************************************

local COLOR_HOTEP = "|c3366ff"
local COLOR_MSG = "|cff6633"
local COLOR_RED = "|cff0000"


HotepFood = {
  name = "HotepDinnerBell",
  savedVars = "HotepFoodVars",
  version = 1,
  notified = {},
  theLAMPanel = nil,
  title = "Hotep Dinner Bell",
  fancytitle = zo_strformat("<<1>>Hotep\194\174|r <<2>>Dinner Bell|r", COLOR_HOTEP, COLOR_MSG),
  displayVersion = "3.34d",
}


local Exclude = {"Power Surge", "Crit Surge"}




local HotepToolsLib = LibStub("HotepToolsLib", false)

local clone = HotepToolsLib.HotepCommonFuncs.clone
local explode = HotepToolsLib.HotepCommonFuncs.explode
local in_array = HotepToolsLib.HotepCommonFuncs.in_array
local array_key_exists = HotepToolsLib.HotepCommonFuncs.array_key_exists
local array_indexof = HotepToolsLib.HotepCommonFuncs.array_indexof
local array_without = HotepToolsLib.HotepCommonFuncs.array_without
local array_glob = HotepToolsLib.HotepCommonFuncs.array_glob
local uuid = HotepToolsLib.HotepCommonFuncs.uuid
local array_keys = HotepToolsLib.HotepCommonFuncs.array_keys
local spairs = HotepToolsLib.HotepCommonFuncs.spairs
local eyesort = HotepToolsLib.HotepCommonFuncs.eyesort



local Timer = HotepToolsLib.HotepUtilities.Timer


local LAM = LibStub("LibAddonMenu-2.0", false) or LibAddonMenu2



local function msgWithName(msg, color)
  if (type(color) == "nil") then color = COLOR_MSG end
  
  d(zo_strformat("[<<1>><<2>>|r] <<3>><<4>>|r", COLOR_HOTEP, HotepFood.name, color, msg))
end




-- ****************************************************************************
--                                  saved vars
-- ****************************************************************************

---@local AcctWideOpts @class AcctWideOpts
local AcctWideOpts

local Favorites
local Vars = {selected = nil, timelimit = nil, nochatloaded = nil, nochatwarning = nil, trackxp = nil}
local FavBuff
local Excludes
local EveryBuff

local WithoutFav = false


local SV_TOGGLE = 'ns_awide_opt'
local SV_CHAR = 'ns_perchar'
local SV_AWIDE = ''


local defaultVariables = {
  favs = {
    [" - none - "] = {
      consume = nil,
      buffName = nil,
    },
  },
  vars = {
    selected = " - none - ",
    timelimit = 35,
    nochatloaded = false,
    nochatwarning = false,
    trackxp = true,
  },
  excludes = {},
  everybuff = {},
}

local defaultToggleVars = {
  opts = {
    acct_wide = true
  },
}

local savedVariables = {vars = {favs = {}, vars = {}, excludes = {}, everybuff = {}}}

function savedVariables:Load()
  self.toggle = ZO_SavedVars:NewAccountWide(HotepFood.savedVars, HotepFood.version, SV_TOGGLE, defaultToggleVars)
  
  AcctWideOpts = self.toggle.opts
  
  if (AcctWideOpts.acct_wide) then
    self:Load_AWide()
  else
    self:Load_Char()
  end
  
  self:Set_Locals()
end

function savedVariables:Load_AWide()
  self.vars = ZO_SavedVars:NewAccountWide(HotepFood.savedVars, HotepFood.version, SV_AWIDE, defaultVariables)
end

function savedVariables:Load_Char()
  self.vars = ZO_SavedVars:NewCharacterIdSettings(HotepFood.savedVars, HotepFood.version, SV_CHAR, defaultVariables)
end

function savedVariables:Set_Locals()
  
  Favorites = self.vars.favs
  Vars = self.vars.vars
  
  if (not self.vars.vars.nochatloaded) then
    self.vars.vars.nochatloaded = false
  end
  
  if (not self.vars.vars.nochatwarning) then
    self.vars.vars.nochatwarning = false
  end
  
  if (type(Vars.trackxp) == "nil") then
    Vars.trackxp = true
  end
  
  if (not self.vars.excludes) then
    self.vars.excludes = {}
  end
  
  if (not self.vars.everybuff) then
    self.vars.everybuff = {}
  end
  
  Excludes = self.vars.excludes
  EveryBuff = self.vars.everybuff
  
  FavBuff = Favorites[Vars.selected]
end




-- ****************************************************************************
--                                  main code
-- ****************************************************************************


HotepFood_MyDynDropdown = nil
HotepFood_ExcludeSubmenu = nil


function HotepFood.CreateExclusions()
  
  local chk = function (buffName)
    return {
      type = "checkbox",
      name = buffName,
      tooltip = "ON to EXCLUDE.  OFF to INCLUDE.",
      getFunc = function () return in_array(buffName, Excludes) end,
      setFunc = function (x)
                  if (x and not in_array(buffName, Excludes)) then
                    table.insert(Excludes, buffName)
                  elseif (not x and in_array(buffName, Excludes)) then
                    array_without(Excludes, buffName)
                  end
                end,
    }
  end
  
  
  local data = {}
  
  for _,buffName in ipairs(EveryBuff) do
    table.insert(data, chk(buffName))
  end
  
  
  return data
end


function HotepFood:CreateAddonMenu()
  
  local paneldata = {
    type = "panel",
    name = HotepFood.title,
    displayName = HotepFood.fancytitle,
    author = "|cff6633@tomtom|r|c3366ffhotep|r",
    version = HotepFood.displayVersion,
    registerForRefresh = true,
  }
  
  
  local setfav = function (f)
    Vars.selected = f
    FavBuff = Favorites[f]
  end
  
  
  local exclusionsData = HotepFood.CreateExclusions()
  
  
  local mainOptions = {
    
    {
      type = "checkbox",
      name = "Account-Wide Settings?",
      tooltip = "no means separate settings per character",
      warning = "This option will not take effect until a reload or character change",
      getFunc = function () return AcctWideOpts.acct_wide end,
      setFunc = function (x) AcctWideOpts.acct_wide = x end,
    },
    
    {
      type = "slider",
      name = "Warning time (seconds)",
      tooltip = "You will be warned that your food or drink is expiring this many seconds ahead of time.",
      min = 30,
      max = 300,
      step = 1,
      decimals = 0,
      getFunc = function () return Vars.timelimit end,
      setFunc = function (n) Vars.timelimit = n end,
    },
    
    {
      type = "dropdown",
      name = "Favorite Buff",
      tooltip = "The food or drink you use most.",
      choices = array_keys(Favorites),
      getFunc = function () return Vars.selected end,
      setFunc = setfav,
      reference = "HotepFood_MyDynDropdown",
    },
    
    {
      type = "checkbox",
      name = "Track XP buffs?",
      getFunc = function () return Vars.trackxp end,
      setFunc = function (x) Vars.trackxp = x end,
    },
    
    {
      type = "submenu",
      name = "Exclusions",
      tooltip = "If you want to exclude certain buffs from being recognized by this addon, use these options.",
      controls = exclusionsData,
      reference = "HotepFood_ExcludeSubmenu",
    },
    
    {
      type = "checkbox",
      name = "Disable chat message on load?",
      getFunc = function () return Vars.nochatloaded end,
      setFunc = function (x) Vars.nochatloaded = x end,
    },
    
    {
      type = "checkbox",
      name = "Disable chat warnings on low/no buff?",
      getFunc = function () return Vars.nochatwarning end,
      setFunc = function (x) Vars.nochatwarning = x end,
    },
    
    
    
    {
      type = "description",
      text = "Hotep\194\174 is a registered trademark of Simple Designs Software LLC. All Rights Reserved.",
    },
  }
  
  
  HotepFood.theLAMPanel = LAM:RegisterAddonPanel(HotepFood.name, paneldata)
  LAM:RegisterOptionControls(HotepFood.name, mainOptions)
  CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", HotepFood.MyLAMWasOpened)
end


function HotepFood.MyLAMWasOpened(panel)
  if (panel == HotepFood.theLAMPanel) then
    CALLBACK_MANAGER:UnregisterCallback("LAM-PanelControlsCreated", HotepFood.MyLAMWasOpened)
    
    HotepFood_MyDynDropdown:UpdateChoices(array_keys(Favorites))
    HotepFood_MyDynDropdown:UpdateValue()
    
--    HotepFood_ExcludeSubmenu.data.controls = HotepFood.CreateExclusions()
--    CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", HotepFood.theLAMPanel)
  end
end



function HotepFood.AddToFavList(consume, buffName)
  
  local newname = zo_strformat("(<<1>>) <<2>>", consume, buffName)
  
  if (array_key_exists(newname, Favorites)) then return end
  
  Favorites[newname] = {
    consume = consume,
    buffName = buffName,
  }
  
  if (HotepFood_MyDynDropdown) then
    HotepFood_MyDynDropdown:UpdateChoices(array_keys(Favorites))
    HotepFood_MyDynDropdown:UpdateValue()
  end
end



function HotepFood.Scan(debugging)
  
  local n = GetNumBuffs("player")
  
  
  local t = {}   -- all currently active food/drink buffs
  
  local k = 0
  
  local without = (not (not FavBuff.consume))  -- true if a favorite is selected
  local hasafav = (not (not FavBuff.consume))  -- true if a favorite is selected
  
  
  for i = 1,n do
    local buffName, timeStarted, timeEnding, buffSlot, stackCount, 
          iconFilename, buffType, effectType, abilityType, 
          statusEffectType, abilityId, canClickOff, castByPlayer = GetUnitBuffInfo("player", i)
    
--    if (debugging) then
--      msgWithName(i, COLOR_RED)
--      d({buffName = buffName, timeStarted = timeStarted, timeEnding = timeEnding, buffSlot = buffSlot, stackCount = stackCount, 
--          iconFilename = iconFilename, buffType = buffType, effectType = effectType, abilityType = abilityType,
--          statusEffectType = statusEffectType, abilityId = abilityId, canClickOff = canClickOff, castByPlayer = castByPlayer})
--      msgWithName('===================', COLOR_RED)
--    end
    
    if ((buffName == "Witchmother's Brew") or (buffName == "Pelinal's Ferocity") or 
        (((buffName == "Increased Experience") or (buffType == "Increased Experience")) and Vars.trackxp) or
        ((effectType == BUFF_EFFECT_TYPE_BUFF) and (statusEffectType == STATUS_EFFECT_TYPE_NONE) and ((timeEnding - timeStarted) > 0)
            and (in_array(abilityType, {ABILITY_TYPE_NONE, ABILITY_TYPE_BONUS})) and canClickOff
            and not in_array(buffName, Exclude) and not in_array(buffName, Excludes))) then
      
--    if (debugging) then
--      msgWithName(i, COLOR_RED)
--      d({buffName = buffName, timeStarted = timeStarted, timeEnding = timeEnding, buffSlot = buffSlot, stackCount = stackCount, 
--          iconFilename = iconFilename, buffType = buffType, effectType = effectType, abilityType = abilityType,
--          statusEffectType = statusEffectType, abilityId = abilityId, canClickOff = canClickOff, castByPlayer = castByPlayer})
--      msgWithName('===================', COLOR_RED)
--      msgWithName((timeEnding - (GetGameTimeMilliseconds() / 1000)), COLOR_RED)
--      msgWithName('===================', COLOR_RED)
--    end
    
      if (not in_array(buffName, EveryBuff)) then
        table.insert(EveryBuff, buffName)
--        if (HotepFood_ExcludeSubmenu) then
--          HotepFood_ExcludeSubmenu.data.controls = HotepFood.CreateExclusions()
--          CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", HotepFood.theLAMPanel)
--        end
      end
      
      local timeLeft = (timeEnding - (GetGameTimeMilliseconds() / 1000))
      
      local consume = "Food"
      if (abilityType == ABILITY_TYPE_NONE) then consume = "Drink" end
      if ((buffName == "Increased Experience") or (buffType == "Increased Experience")) then consume = "XP" end
      
--      msgWithName('======~~~~~~======', COLOR_RED)
--      msgWithName(zo_strformat('<<1>>(<<2>>): <<3>>(<<4>>) - <<5>> sec left.', 
--                        i, abilityId, buffName, consume, timeLeft), COLOR_RED)
--      msgWithName('======~~~~~~======', COLOR_RED)
      HotepFood.AddToFavList(consume, buffName)
      
      if (without) then
        if ((FavBuff.buffName == buffName) and (FavBuff.consume == consume)) then
          without = false
        end
      end
      
      table.insert(t, abilityId)
      
      if ((timeLeft < Vars.timelimit) and (not in_array(abilityId, HotepFood.notified))) then
        
        table.insert(HotepFood.notified, abilityId)
        
        k = k + 1
        
--      msgWithName('===================', COLOR_RED)
--      msgWithName('~~~   NOTIFY!   ~~~', COLOR_RED)
--      msgWithName('===================', COLOR_RED)
        Timer:Once((k * 0.07), HotepFood.Notify, {consume = consume, buffName = buffName})
        
      elseif ((timeLeft > 340) and (in_array(abilityId, HotepFood.notified))) then
        array_without(HotepFood.notified, abilityId)
      end
    end
  end
  
  
  WithoutFav = (hasafav and without)
  
  
  -- remove expired buffs from .notified
  
  local x = {}
  
  for _,id in pairs(HotepFood.notified) do
    if (not in_array(id, t)) then
      table.insert(x, id)
    end
  end
  
  for _,id in pairs(x) do
    array_without(HotepFood.notified, id)
  end
  
  
  Timer:Once(0.1, HotepFood.Scan)
end


function HotepFood.Notify(p)
  
  if (not Vars.nochatwarning) then
    msgWithName(zo_strformat("Your <<1>> buff is about to expire!", p.consume))
  end
  
  
--  OLD WAY:
--  --------
--  CENTER_SCREEN_ANNOUNCE:AddMessage(999, CSA_EVENT_COMBINED_TEXT,
--    SOUNDS.CHAMPION_POINTS_COMMITTED, zo_strformat("Your <<1>> buff is about to expire!", p.consume), zo_strformat("[<<1>>]", p.buffName),
--    nil, nil, nil, nil, 4420)
  
  
  -- NEW WAY (since api 100019 - "Update 14 - Morrowind")
  -- -------------------
  local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.CHAMPION_POINTS_COMMITTED)
  params:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_ACHIEVEMENT_AWARDED)
  params:SetText(zo_strformat("Your <<1>> buff is about to expire!", p.consume), zo_strformat("[<<1>>]", p.buffName))
  params:SetLifespanMS(4420)
  params:SetPriority(999)
  CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
end


function HotepFood.NotifyWithoutFav()
  
  if (not WithoutFav) then return end
  
  local p = FavBuff
  
  if (not Vars.nochatwarning) then
    msgWithName(zo_strformat("You don't have your favorite <<1>> buff!!", p.consume))
  end
  
  
--  CENTER_SCREEN_ANNOUNCE:AddMessage(999, CSA_EVENT_COMBINED_TEXT,
--    SOUNDS.CHAMPION_POINTS_COMMITTED, zo_strformat("You don't have your favorite <<1>> buff!!", p.consume), zo_strformat("[<<1>>]", p.buffName),
--    nil, nil, nil, nil, 4420)
  
  local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.CHAMPION_POINTS_COMMITTED)
  params:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_ACHIEVEMENT_AWARDED)
  params:SetText(zo_strformat("You don't have your favorite <<1>> buff!!", p.consume), zo_strformat("[<<1>>]", p.buffName))
  params:SetLifespanMS(4420)
  params:SetPriority(999)
  CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
end


function HotepFood.Fooooo()
  Timer:Once(0.02, HotepFood.NotifyWithoutFav)
end




-- ****************************************************************************
--                              event handling
-- ****************************************************************************



function HotepFood.Initialize()
  
  EVENT_MANAGER:UnregisterForEvent(HotepFood.name, EVENT_PLAYER_ACTIVATED)
  
  HotepToolsLib:Init()
  
  savedVariables:Load()
  
  if (not Vars.nochatloaded) then
    msgWithName("Loaded")
  end
  
  HotepFood:CreateAddonMenu()
  
  HotepFood.Scan()
  
  HotepFood.Fooooo()
  
  SLASH_COMMANDS['/hotep99'] = function ()
    HotepFood.Scan(true)
  end
  
  EVENT_MANAGER:RegisterForEvent(HotepFood.name, EVENT_PLAYER_ACTIVATED, HotepFood.Fooooo)
end





function HotepFood.OnAddOnLoaded(event, addonName)
  if addonName == HotepFood.name then
    math.randomseed(GetTimeStamp())
    
    EVENT_MANAGER:UnregisterForEvent(HotepFood.name, EVENT_ADD_ON_LOADED)
    
    EVENT_MANAGER:RegisterForEvent(HotepFood.name, EVENT_PLAYER_ACTIVATED, HotepFood.Initialize)
  end
end


EVENT_MANAGER:RegisterForEvent(HotepFood.name, EVENT_ADD_ON_LOADED, HotepFood.OnAddOnLoaded)
