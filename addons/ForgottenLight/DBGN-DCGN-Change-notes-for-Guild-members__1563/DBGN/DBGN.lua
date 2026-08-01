local DBGN = DBGN
--
-- Section 1: Support functions and Links to variable
--
local nvl = DBGN.nvl
local msg = DBGN.msg
local BoolToStr = DBGN.BoolToStr
local BoolToNum = DBGN.BoolToNum
local RegisteredGuildTypes = {}
local GuildSettingsCache = {}
--
-- Section 1: Support function
--
function DBGN:CheckCodeStrInNote(txt)
  local f = false
  if txt ~= nil and txt ~= "" then
    for _, g in pairs(RegisteredGuildTypes) do
      if string.find(txt, g.Pref) ~= nil then
        f = true
        break
      end
    end
  end
  return f
end

function DBGN:LdMemberNote(data, e)
  e:InitRec()
  if data then
    local r = e.r
    r.guildId   = GUILD_ROSTER_MANAGER:GetGuildId()
    r.Name      = data.displayName
    e.Str       = data.note
    r.rankIndex = data.rankIndex
    r.OnLine    = (data.status ~= PLAYER_STATUS_OFFLINE)
    e:FindCodeStr()
    if e.CodeStrPresent then e:Decode() end
  end
end

function DBGN:SaveGuildNote(Enc)
  local r,s,a,l = Enc.r,"","",0
  if type(r.ClearText) == "string" and r.ClearText ~= "" then
    a = r.ClearText
    l = string.len(a)
  end
  local mcl = Enc.nMaxClearStrLen - Enc:GetCntVertLineS(a) - 1
  if l == 0 then
    s = Enc.CodeStr
  elseif l > mcl then
    s = string.sub(a, 1, mcl) .. Enc.CodeStr
  else
    s = a .. Enc.CodeStr
  end
  local n = GetNumGuildMembers(r.guildId)
  for i = 1, n do
    local mn = GetGuildMemberInfo(r.guildId, i)
    if mn == r.Name then
      SetGuildMemberNote(r.guildId, i, s)
    end
  end
end

function DBGN:GetGuildTypeFromCode(GuildCode)
  if type(GuildCode) == "string" then
    return self.AvlGuildType[GuildCode]
  end
  return nil
end

--
-- Section 2: Guild Settings Cache
--
function DBGN:GuildSettingsNew()
  local GS = {GuildType = 1, Officer = 0, CodeStr = "", }
  return GS
end

function DBGN:GuildSettingsCacheUpd(guildId)
  if guildId == nil then return end
  if type(GuildSettingsCache[guildId]) ~= "table" then
    GuildSettingsCache[guildId] = self:GuildSettingsNew()
  end
  local GS = GuildSettingsCache[guildId]
  local NeedUpdFltr = false

  local function Ld_GS(e, s)
    if type(e) ~= "table" then return false end
    e:InitRec()
    e.Str = s
    e:FindCodeStr()
    if e.CodeStrPresent == false then return false end
    if e.CodeStr == GS.CodeStr then return true end
    e:Decode()
    if e.Error ~= 0 then return false end
    NeedUpdFltr = GS.GuildType ~= e.r.GuildType
    GS.CodeStr = e.CodeStr
    GS.Officer = e.r.Officer
    GS.GuildType = e.r.GuildType
    return true
  end

  local function Ld_PredefinedGuild()
    local PW = self.PredefinedGuild[self.WorldName]
    if type(PW) ~= "table" then return false end
    local GN = GetGuildName(guildId)
    local PG = PW[GN]
    if type(PG) ~= "table" then return false end
    if type(PG.Type) == "number" then GS.GuildType = PG.Type end
    if type(PG.Officer) == "number" then GS.Officer = PG.Officer end
    return true
  end


  if Ld_GS(self.GS_Desc.EncEx, GetGuildDescription(guildId)) ~= true then
    if Ld_GS(self.GS_MotD.EncEx, GetGuildMotD(guildId)) ~= true then
      GS.CodeStr = ""
      GS.GuildType = 1
      GS.Officer = 0
      if Ld_PredefinedGuild() == true then
        NeedUpdFltr = GS.GuildType ~= 1
      end
    end
  end
  if NeedUpdFltr and (guildId == GUILD_ROSTER_MANAGER:GetGuildId()) then self.FB_Show_Init() end
end

function DBGN.GuildSettingsCacheInit()
  for i=1, GetNumGuilds() do DBGN:GuildSettingsCacheUpd(GetGuildId(i)) end
end

function DBGN:GetGuildSettings(guildId)
  if guildId == nil then return self:GuildSettingsNew() end
  if type(GuildSettingsCache[guildId]) ~= "table" then
    self:GuildSettingsCacheUpd(guildId)
  end
  return GuildSettingsCache[guildId]
end

--
-- Section 3: Guild registration
--
function DBGN:GetGuildTypeRec(GuildType)
  if GuildType ~= nil and RegisteredGuildTypes[GuildType] ~= nil then
    return RegisteredGuildTypes[GuildType]
  end
  return RegisteredGuildTypes[1]
end

function DBGN:GetGuildTypeFromId(guildId)
  local GS = self:GetGuildSettings(guildId)
  return GS.GuildType
end

function DBGN:GetGuildTypeRecFromId(guildId)
  local GS = self:GetGuildSettings(guildId)
  return self:GetGuildTypeRec(GS.GuildType)
end

function DBGN:RegisterGuildType(g)
  if type(g) ~= "table" then return 1 end
  if type(g.Name) ~= "string" or g.Name == "" then return 2 end
  if type(g.Code) ~= "string" or g.Code == "" then return 3 end
  local k = self.AvlGuildType[g.Code]
  if k == nil then return 4 end
  if type(g.Pref) ~= "string" or g.Pref == "" then return 5 end
  if type(g.Suff) ~= "string" or g.Suff == "" then return 6 end
  if type(g.EncTT) ~= "table" then return 7 end
  if type(g.EncEd) ~= "table" then return 8 end
  if type(g.EncFl) ~= "table" then return 9 end
  if type(g.UI_TT_Upd) ~= "function" then return 10 end
  if type(g.UI_Ed_Upd) ~= "function" then return 11 end
  if type(g.UI_Ed_GetVal) ~= "function" then return 12 end
  if type(g.UI_Ed_Keybind) ~= "function" then return 13 end
  if type(g.UI_Fl_Check) ~= "function" then return 14 end
  RegisteredGuildTypes[k] = g
  local GS = self:GetGuildSettings(GUILD_ROSTER_MANAGER:GetGuildId())
  if GS.GuildType == k then self.FB_Show_Init() end
  return 0 -- Ok
end
-- Function for backward compatibility
function DBGN:RegisterGuild(g)
  self:RegisterGuildType(g)
end
--
-- Section 4: Filtering buttons
--
function DBGN.FB_Enabled_Change(control)
  local f,x = DBGN.SV.Filters, control.Status
  f.Enabled = x
  DBGN:RefreshRosterFilters(true)
end

function DBGN.FB_WithoutGN_Change(control)
  local f,x = DBGN.SV.Filters, control.Status
  f.WithoutGN = x
  DBGN:RefreshRosterFilters()
end

function DBGN.FB_Show_Change(control)
  local f,x = DBGN.SV.Filters, control.Status
  f.ShowFilters = x
  local GR = DBGN:GetGuildTypeRecFromId(GUILD_ROSTER_MANAGER:GetGuildId())
  if GR then
    local u = GR.UI_Fl
    if DBGN.CurrentFilterWin ~= nil and DBGN.CurrentFilterWin ~= u.Win then
      DBGN.CurrentFilterWin:SetHidden(true)
    end
    DBGN.CurrentFilterWin = u.Win
    if x then u.Win:SetHidden(false) else u.Win:SetHidden(true) end
  end
end

function DBGN.FB_SV_GuildRank(guildId)
  local f,fgr = DBGN.SV.Filters,{}
  if guildId ~= nil then
    if type(f.GuildRank) ~= "table" then f.GuildRank = {} end
    if type(f.GuildRank[guildId]) ~= "table" then f.GuildRank[guildId] = {} end
    fgr = f.GuildRank[guildId]
  end
  if type(fgr.Val) ~= "number" or fgr.Val < 1 then fgr.Val = 1 end
  if type(fgr.Cmp) ~= "number" or fgr.Cmp < 1 then fgr.Cmp = 1 end
  if fgr.Cmp > 4 then fgr.Cmp = 4 end
  return fgr
end

function DBGN.FB_Show_Init()
  local arr,f = {}, DBGN.SV.Filters
  local guildId = GUILD_ROSTER_MANAGER:GetGuildId()
  local numRanks = GetNumGuildRanks(guildId)
  for i = 1,numRanks do arr[i] = GetFinalGuildRankName(guildId, i) end

  local GR = DBGN:GetGuildTypeRecFromId(guildId)
  if GR then
    local u = GR.UI_Fl
    if DBGN.CurrentFilterWin ~= nil and DBGN.CurrentFilterWin ~= u.Win then
      DBGN.CurrentFilterWin:SetHidden(true)
    end
    DBGN.CurrentFilterWin = u.Win
    if f.ShowFilters then u.Win:SetHidden(false) else u.Win:SetHidden(true) end
  end

  local u = DBGN.UI_FilterButton
  if u.CB then
    local fgr = DBGN.FB_SV_GuildRank(guildId)

    if fgr.Val > numRanks then fgr.Val = numRanks end

    DBGN:InitCB(u.CB.RankVal, arr, numRanks, fgr.Val,
      function(control, i, _)
        if i ~= fgr.Val then
          fgr.Val = i
          DBGN:RefreshRosterFilters(true)
        end
      end
    )
    DBGN:InitCB(u.CB.RankCmp, DBGN.MarkersGr.Cmp, 4, fgr.Cmp,
      function(control, i, _)
        if i ~= fgr.Cmp then
          fgr.Cmp = i
          DBGN:RefreshRosterFilters(true)
        end
      end
    )
  end
end

function DBGN:InitFilterButton()
  local u,i,l,v = self.UI_FilterButton, self.Icons.FltrBt, self.i18n, self.SV.Filters
  u.Win = CreateControlFromVirtual("DBGN_FilterButtonWin", ZO_GuildRoster, "DBGN_TmplFilterButton")
  u.Show = DBGN_FilterButtonWinShow
  u.Enabled = DBGN_FilterButtonWinEnabled
  u.WithoutGN = DBGN_FilterButtonWinWithoutGN
  DBGN_FilterButtonWinRankTxt:SetText(l.GuildRank)
  u.RankCmp = DBGN_FilterButtonWinRankCmp
  u.RankVal = DBGN_FilterButtonWinRankVal
  u.CB = {
    RankCmp = ZO_ComboBox_ObjectFromContainer(u.RankCmp),
    RankVal = ZO_ComboBox_ObjectFromContainer(u.RankVal),
  }
  if not v.SaveEnabled then v.Enabled = false end
  self:MoveFilterButtons(self.SV.BttFilters, self.SV.BttFiltersSh, self.SV.BttFiltersPP)
  self:InitOnOffButton(u.Show, i.ShowOn, i.ShowOff, l.TT_FB_Show, v.ShowFilters, self.FB_Show_Change)
  self:InitOnOffButton(u.Enabled, i.EnabledOn, i.EnabledOff, l.TT_FB_Enabled, v.Enabled, self.FB_Enabled_Change)
  self:InitOnOffButton(u.WithoutGN, i.WithoutGNOn, i.WithoutGNOff, l.TT_FB_WithoutGN, v.WithoutGN, self.FB_WithoutGN_Change)
  self.FB_Show_Init()
  CALLBACK_MANAGER:RegisterCallback("OnGuildSelected", self.FB_Show_Init)
end

--
-- Section 5: Guild home window buttons
--
function DBGN:GHButtonPositionFixPP()
  local h = self.UI_GHButton
  if h.MotD then
    h.MotD:SetAnchor(BOTTOMRIGHT, h.eMotD, TOPRIGHT, -56, -2)
  end
  if h.Desc then
    h.Desc:SetAnchor(BOTTOMRIGHT, h.eDesc, TOPRIGHT, -56, -2)
  end
end

function DBGN:CreateGHButton(parent, name, func)
  local i = self.Icons.Note.Alt
  local b = WINDOW_MANAGER:CreateControl(name, parent, CT_BUTTON)
  b:SetDimensions(40, 39)
  b:SetAnchor(BOTTOMRIGHT, parent, TOPRIGHT, 40, -2)
  b:SetNormalTexture(i.normal)
  b:SetPressedTexture(i.pressed)
  b:SetMouseOverTexture(i.mouseOver)
  b:SetHidden(false)
  if type(func) == "function" then
    b:SetHandler("OnClicked", func)
  end
  return b
end

function DBGN.GHButtonMotD_OnClicked(b)
  local g = DBGN.GS_MotD
  g:UI_Ed_SetGSType(DBGN.UI_GHButton.eMotD)
  g:UI_Ed_Upd()
  DBGN:ShowModalDialog(g.UI_Ed.Win,function(keybind) g:UI_Ed_Keybind(keybind) end)
end

function DBGN.GHButtonDesc_OnClicked(b)
  local g = DBGN.GS_Desc
  g:UI_Ed_SetGSType(DBGN.UI_GHButton.eDesc)
  g:UI_Ed_Upd()
  DBGN:ShowModalDialog(g.UI_Ed.Win,function(keybind) g:UI_Ed_Keybind(keybind) end)
end

function DBGN:InitGHButton()
  local h = self.UI_GHButton
  h.eMotD = ZO_GuildHomeInfoMotDSavingEdit
  h.eDesc = ZO_GuildHomeInfoDescriptionSavingEdit
  h.MotD = self:CreateGHButton(h.eMotD, "DBGN_GHButtonMotD", self.GHButtonMotD_OnClicked)
  h.Desc = self:CreateGHButton(h.eDesc, "DBGN_GHButtonDesc", self.GHButtonDesc_OnClicked)
end

--
-- Section 6: Addon initialization
--
function DBGN:InitRoster()
  local dataType = GUILD_ROSTER_KEYBOARD.list.dataTypes[GUILD_MEMBER_DATA]
  self.HoldRosterCallback = dataType.setupCallback
  if self.HoldRosterCallback then
    dataType.setupCallback = function(...)
      local row, data = ...
--      DBGN.ChangeRosterInfo(row, data)
      DBGN.HoldRosterCallback(...)
      zo_callLater(function() DBGN.ChangeRosterInfo(row, data) end, 25)
    end
  end
end

function DBGN:DetectPPixel()
  if type(PP) == "table" and PP.ADDON_NAME == "PerfectPixel" then
    self.isPerfectPixel = true
    self:GHButtonPositionFixPP()
    self:MoveFilterButtons(self.SV.BttFilters, self.SV.BttFiltersSh, self.SV.BttFiltersPP)
    for _, g in pairs(RegisteredGuildTypes) do
      if type(g.UI_Fl_WinMove) == "function" then
        g:UI_Fl_WinMove()
      end
    end
  end
end

function DBGN:DetectShissu()
  if self.isPerfectPixel ~= true then
    if type(ShissuFramework) == "table" and type(ShissuFramework._settings) == "table" then
      local SSM = ShissuFramework._settings
      if SSM["ShissuRoster"] ~= nil then
        self.isShissuRoster = true
      end
    end
    if self.isShissuRoster ~= true and type(Shissu_SuiteManager) == "table" and type(Shissu_SuiteManager._settings) == "table" then
      local SSM = Shissu_SuiteManager._settings
      if SSM["ShissuRoster"] ~= nil then
        self.isShissuRoster = true
      end
    end
    if self.isShissuRoster == true then
      self:MoveFilterButtons(self.SV.BttFilters, self.SV.BttFiltersSh, self.SV.BttFiltersPP)
      for _, g in pairs(RegisteredGuildTypes) do
        if type(g.UI_Fl_WinMove) == "function" then
          g:UI_Fl_WinMove()
        end
      end
    end
  end
end

function DBGN:Initialize()
  local DefXY = self.DefXY
  self:LoadTbColors()
-- Detect addon: Shissu Guild Roster
  self.isPerfectPixel = false
  self.isShissuRoster = false
  zo_callLater(function() self:DetectPPixel() end, 200)
  zo_callLater(function() self:DetectShissu() end, 300)
-- Initialization of saved variables
  local defaults = {
    WinFilters = {
      X = DefXY.WinFN.X,
      Y = DefXY.WinFN.Y,
    },
    WinFiltersSh = {
      X = DefXY.WinFS.X,
      Y = DefXY.WinFS.Y,
    },
    WinFiltersPP = {
      X = DefXY.WinFP.X,
      Y = DefXY.WinFP.Y,
    },
    BttFilters = {
      X = DefXY.BttN.X,
      Y = DefXY.BttN.Y,
    },
    BttFiltersSh = {
      X = DefXY.BttS.X,
      Y = DefXY.BttS.Y,
    },
    BttFiltersPP = {
      X = DefXY.BttP.X,
      Y = DefXY.BttP.Y,
    },
    OutUncomplTrial = true,
    DropNotificationsMotD = false,
    Filters = {
-- Common variables
      ShowFilters = true,
      SaveEnabled = false,
      Enabled = false,
      WithoutGN = false,
      GuildRank = {},
-- Main flags
      Forum = 1,
      TS    = 1,
      Discord = 1,
      Vamp  = 1,
      WW    = 1,
      House = 1,
-- Trials
      TrlDung = 1,
      TrlCmp = 1,
      TrlVal = 1,
      TrlDD   = false,
      TrlHeal = false,
      TrlTank = false,
-- Attestation
      HealCmp = 1,
      HealVal = 1,
      TankCmp = 1,
      TankVal = 1,
      PvPCmp = 1,
      PvPVal = 1,
      DDFrom = "",
      DDTo = "",
      DuelFrom = "",
      DuelTo = "",
      RaidFrom = "",
      RaidTo = "",
-- Craft
      WBlVal = 1,
      WWpVal = 1,
      ShldVal = 1,
      EnchVal = 1,
      AlchVal = 1,
      ArmLVal = 1,
      ArmMVal = 1,
      ArmHVal = 1,
      JewVal = 1,
      ProvCmp = 1,
      ProvVal = 1,
    },
  }
  self.SV = ZO_SavedVars:NewAccountWide("DBGNSavedVars", 1, nil, defaults)
--
  local defaults_dc = {
    WinFilters = {
      X = DefXY.WinFN.X,
      Y = DefXY.WinFN.Y,
    },
    WinFiltersSh = {
      X = DefXY.WinFS.X,
      Y = DefXY.WinFS.Y,
    },
    WinFiltersPP = {
      X = DefXY.WinFP.X,
      Y = DefXY.WinFP.Y,
    },
    Filters = {
-- Main flags
      Discord = 1,
      Vamp  = 1,
      WW    = 1,
--    House = 1,
-- Craft
      BlkVal = 1,
      WWrVal = 1,
      CltVal = 1,
      JewVal = 1,
      EnchVal = 1,
      AlchVal = 1,
      ProvVal = 1,
      AmbrVal = 1,
-- Trials
      TrlDung = 1,
      TrlCmp = 1,
      TrlVal = 1,
      TrlDD   = false,
      TrlHeal = false,
      TrlTank = false,
-- Attestation
      DDCmp = 1,
      DDVal = 1,
      HealCmp = 1,
      HealVal = 1,
      TankCmp = 1,
      TankVal = 1,
      PvPCmp = 1,
      PvPVal = 1,
      DPSFrom = "",
      DPSTo = "",
      DuelFrom = "",
      DuelTo = "",
      RaidFrom = "",
      RaidTo = "",
    },
  }
  self.SV_DC = ZO_SavedVars:NewAccountWide("DCGNSavedVars", 1, nil, defaults_dc)
--
-- Register main guild
  self.RegGuildResultDB = self:RegisterGuildType(self.GetGuildDB())
  self.RegGuildResultDC = self:RegisterGuildType(self.GetGuildDC())
  self.GS_Desc = self.GetGuildSettingsRec(false)
  self.GS_MotD = self.GetGuildSettingsRec(true)
  self.RegConvDB2DC = self.Convert.Reg_DBGN_to_DCGN()
  self.RegConvDC2DB = self.Convert.Reg_DCGN_to_DBGN()
--
  self:InitRoster()
  zo_callLater(function()
    if GUILD_ROSTER_KEYBOARD.GuildRosterRow_OnMouseUp ~= self.GuildRosterRow_OnMouseUp then
      self.HoldGuildRosterRow_OnMouseUp = GUILD_ROSTER_KEYBOARD.GuildRosterRow_OnMouseUp
      GUILD_ROSTER_KEYBOARD.GuildRosterRow_OnMouseUp = self.GuildRosterRow_OnMouseUp
    end
    if GUILD_ROSTER_MANAGER.IsMatch ~= self.GuildRosterManager_IsMatch then
      self.HoldGuildRosterManager_IsMatch = GUILD_ROSTER_MANAGER.IsMatch
      GUILD_ROSTER_MANAGER.IsMatch = self.GuildRosterManager_IsMatch
    end
    if GUILD_ROSTER_KEYBOARD.searchBox.GetText ~= self.GuildRosterKB_SearchBoxGT then
      self.HoldGuildRosterKB_SearchBoxGT = GUILD_ROSTER_KEYBOARD.searchBox.GetText
      GUILD_ROSTER_KEYBOARD.searchBox.GetText = self.GuildRosterKB_SearchBoxGT
    end
  end, 2000);
--
  self:InitGHButton()
  self:InitFilterButton()
  self.GuildSettingsCacheInit()
  EVENT_MANAGER:RegisterForEvent(self.Name, EVENT_GUILD_SELF_JOINED_GUILD, function(_, guildId, displayName) self:GuildSettingsCacheUpd(guildId) end)
  EVENT_MANAGER:RegisterForEvent(self.Name, EVENT_GUILD_MOTD_CHANGED, function(_, guildId) self:GuildSettingsCacheUpd(guildId) end)
  EVENT_MANAGER:RegisterForEvent(self.Name, EVENT_GUILD_DESCRIPTION_CHANGED, function(_, guildId) self:GuildSettingsCacheUpd(guildId) end)
  if self.SV.DropNotificationsMotD then
    EVENT_MANAGER:UnregisterForEvent("KeyboardNotifications",EVENT_GUILD_MOTD_CHANGED)
    EVENT_MANAGER:UnregisterForEvent("KeyboardNotifications",EVENT_GUILD_DESCRIPTION_CHANGED)
  end
end
--
-- Section 7: Event functions
-- Function header in this section must use "." instead ":".
-- Also inside the function can not be used "self".
-- Instead, it must explicitly specify the variable
--
function DBGN.ChangeRosterInfo(control, data)
  if data == nil then return end
  local note = control:GetNamedChild("Note")
  if note then
    local ico = {}
    if DBGN:CheckCodeStrInNote(data.note) then
      ico = DBGN.Icons.Note.Alt
    else
      ico = DBGN.Icons.Note.Original
    end
    note:SetNormalTexture(ico.normal)
    note:SetPressedTexture(ico.pressed)
    note:SetMouseOverTexture(ico.mouseOver)
  end
end

function DBGN.OnAddOnLoaded(event, addonName)
  if addonName == DBGN.Name then
    DBGN:Initialize()
    DBGN:CreateOptionsPanel()
    EVENT_MANAGER:UnregisterForEvent(DBGN.Name, EVENT_ADD_ON_LOADED)
  end
end

--
-- Section 8: Overload ZOS functions
--
--GUILD_ROSTER_KEYBOARD.searchBox.GetText(control)
function DBGN.GuildRosterKB_SearchBoxGT(control)
  local txt = DBGN.HoldGuildRosterKB_SearchBoxGT(control)
  if txt ~= nil and txt ~= "" then return txt end
  local fgr = DBGN.FB_SV_GuildRank(GUILD_ROSTER_MANAGER:GetGuildId())
  if not (DBGN.SV.Filters.Enabled or fgr.Cmp > 1) then return txt end
  return "#DBGN#"
end

--GUILD_ROSTER_MANAGER:IsMatch(searchTerm, data)
function DBGN.GuildRosterManager_IsMatch(self, searchTerm, data)
  if DBGN.HoldGuildRosterManager_IsMatch then
    local Txt = ""
    if searchTerm ~= "#DBGN#" then
      Txt = searchTerm
    end
    if not DBGN.HoldGuildRosterManager_IsMatch(self, Txt, data) then
      return false
    end
  end
  if type(data) == "table" then
    local f,guildId = DBGN.SV.Filters,GUILD_ROSTER_MANAGER:GetGuildId()
    local fgr = DBGN.FB_SV_GuildRank(guildId)
    local function check_numb_cmp(val, fcmp, fval)
      if val ~= nil and fval ~= nil and fcmp > 1 then
        if     fcmp == 2 then return val == fval
        elseif fcmp == 3 then return val >= fval
        else                  return val <= fval
        end
      end
      return true
    end
    if not check_numb_cmp(data.rankIndex, fgr.Cmp, fgr.Val) then return false end
    if f.Enabled then
      if data.note == nil or data.note == "" then
        return f.WithoutGN
      end
      local GT = DBGN:GetGuildTypeFromId(guildId)
      local GR = DBGN:GetGuildTypeRec(GT)
      if GR then
        local e = GR.EncFl
        DBGN:LdMemberNote(data, e)
        if not e.CodeStrPresent then
          local Conv = DBGN.Convert
          local ctb = Conv.GetDstTbl(GT)
          local fl = false
          for i, v in pairs(ctb) do
            local GR1 = DBGN:GetGuildTypeRec(i)
            local e1 = GR1.EncFl
            e1:InitRec()
            e1.Str = data.note
            Conv.CopySpecialField(e.r, e1.r)
            e1:FindCodeStr()
            if e1.CodeStrPresent then
              e1:Decode()
              v.Convert(e1.r, e)
              --e.Str = e1:GetStrClear()
              fl = true
              break
            end
          end
          if fl == false then
            return f.WithoutGN
          end
        end
        return GR:UI_Fl_Check()
      end
    end
  end
  return true
end

function DBGN.GuildRosterRow_OnMouseUp(self, control, button, upInside)
  if DBGN.HoldGuildRosterRow_OnMouseUp then
    DBGN.HoldGuildRosterRow_OnMouseUp(self, control, button, upInside)
  end
  if (button ~= MOUSE_BUTTON_INDEX_RIGHT or not upInside) then return end
  local data = ZO_ScrollList_GetData(control)
  if type(data) == "table" then
    local GT = DBGN:GetGuildTypeFromId(GUILD_ROSTER_MANAGER:GetGuildId())
    local GR = DBGN:GetGuildTypeRec(GT)
    if GR then
      local e = GR.EncEd
      DBGN:LdMemberNote(data, e)
      if not e.CodeStrPresent and type(data.note) == "string" and data.note ~= "" then
        local Conv = DBGN.Convert
        local ctb = Conv.GetDstTbl(GT)
        for i, v in pairs(ctb) do
          local GR1 = DBGN:GetGuildTypeRec(i)
          local e1 = GR1.EncEd
          e1:InitRec()
          e1.Str = data.note
          Conv.CopySpecialField(e.r, e1.r)
          e1:FindCodeStr()
          if e1.CodeStrPresent then
            e1:Decode()
            v.Convert(e1.r, e)
            e.Str = e1:GetStrClear()
            break
          end
        end
      end
      if (DoesPlayerHaveGuildPermission(e.r.guildId, GUILD_PERMISSION_NOTE_EDIT)) then
        AddMenuItem("|c77FF77" .. GR.Code .. "|r " .. GetString(SI_SOCIAL_MENU_EDIT_NOTE),
          function()
            GR:UI_Ed_Upd()
            DBGN:ShowModalDialog(GR.UI_Ed.Win,GR.UI_Ed_Keybind)
          end)
        self:ShowMenu(control)
      end
    end
  end
end

local function ShowTT_Win(Win, control)
  local c = ZO_GuildRosterSearchLabel:GetParent()
  local h,y,rh,ry,wh = GuiRoot:GetHeight(), control:GetTop(), c:GetHeight(), c:GetTop(), Win:GetHeight()
--d("h=" .. h .. ", y=" .. y .. ", rh=" .. rh .. ", ry=" .. ry .. ", wh=" .. wh)
  local q = (y - ry)/rh
  local dy = h-ry-30-wh
  local ny = dy * q + ry
--d("q=" .. q .. ", dy=" .. dy .. ", ny=" .. ny)
  DBGN.Hold_GR_UI_TT_Win = Win
  InitializeTooltip(Win, control, TOPRIGHT, -5, ny-y, TOPLEFT)
end

local HoldGuildRosterRowNote_OnMouseEnter = ZO_KeyboardGuildRosterRowNote_OnMouseEnter
function ZO_KeyboardGuildRosterRowNote_OnMouseEnter(control)
--> control = the guild note icon in the roster UI
  local data = ZO_ScrollList_GetData(control:GetParent())
  local GT = DBGN:GetGuildTypeFromId(GUILD_ROSTER_MANAGER:GetGuildId())
  local GR = DBGN:GetGuildTypeRec(GT)
  if GR ~= nil and type(data) == "table" and type(data.note) == "string" and data.note ~= "" then
    local e = GR.EncTT
    DBGN:LdMemberNote(data, e)
    if e.CodeStrPresent then
      GR:UI_TT_Upd()
      ShowTT_Win(GR.UI_TT.Win, control)
    else
      local Conv = DBGN.Convert
      local ctb = Conv.GetDstTbl(GT)
      local fl = false
      for i, v in pairs(ctb) do
        local GR1 = DBGN:GetGuildTypeRec(i)
        local e1 = GR1.EncTT
        e1:InitRec()
        e1.Str = data.note
        Conv.CopySpecialField(e.r, e1.r)
        e1:FindCodeStr()
        if e1.CodeStrPresent then
          e1:Decode()
          v.Convert(e1.r, e)
          e.Str = e1:GetStrClear()
          fl = true
          break
        end
      end
      if fl == false then
        HoldGuildRosterRowNote_OnMouseEnter(control)
      else
        GR:UI_TT_Upd()
        ShowTT_Win(GR.UI_TT.Win, control)
      end
    end
  else
    HoldGuildRosterRowNote_OnMouseEnter(control)
  end
end

local HoldGuildRosterRowNote_OnMouseExit = ZO_KeyboardGuildRosterRowNote_OnMouseExit
function ZO_KeyboardGuildRosterRowNote_OnMouseExit(control)
--> control = the guild note icon in the roster UI
  if DBGN.Hold_GR_UI_TT_Win then
    ClearTooltip(DBGN.Hold_GR_UI_TT_Win)
    DBGN.Hold_GR_UI_TT_Win = nil
  else
    local GR = DBGN:GetGuildTypeRecFromId(GUILD_ROSTER_MANAGER:GetGuildId())
    if GR then
      ClearTooltip(GR.UI_TT.Win)
    end
  end
  HoldGuildRosterRowNote_OnMouseExit(control)
end

local HoldGuildRosterRowNote_OnClicked = ZO_KeyboardGuildRosterRowNote_OnClicked
function ZO_KeyboardGuildRosterRowNote_OnClicked(control)
--> control = the guild note icon in the roster UI
  local GT = DBGN:GetGuildTypeFromId(GUILD_ROSTER_MANAGER:GetGuildId())
  local GR = DBGN:GetGuildTypeRec(GT)
  local data = ZO_ScrollList_GetData(control:GetParent())
  if GR ~= nil and type(data) == "table" and type(data.note) == "string" and data.note ~= "" then
    local e = GR.EncEd
    DBGN:LdMemberNote(data, e)
    local fl = e.CodeStrPresent
    if not fl then
      local Conv = DBGN.Convert
      local ctb = Conv.GetDstTbl(GT)
      for i, v in pairs(ctb) do
        local GR1 = DBGN:GetGuildTypeRec(i)
        local e1 = GR1.EncEd
        e1:InitRec()
        e1.Str = data.note
        Conv.CopySpecialField(e.r, e1.r)
        e1:FindCodeStr()
        if e1.CodeStrPresent then
          e1:Decode()
          v.Convert(e1.r, e)
          e.Str = e1:GetStrClear()
          fl = true
          break
        end
      end
    end
    if fl then
      GR:UI_Ed_Upd()
      DBGN:ShowModalDialog(GR.UI_Ed.Win,GR.UI_Ed_Keybind)
    else
      HoldGuildRosterRowNote_OnClicked(control)
    end
  else
    HoldGuildRosterRowNote_OnClicked(control)
  end
end

--
-- Section 9: Interface function
--
function DBGN:GetGuildMemberInfo(MemberName, GuildCode)
  local GT = self:GetGuildTypeFromCode(GuildCode)
  if GT ~= nil then
    local GR = self:GetGuildTypeRec(GT)
    local Conv = DBGN.Convert
    local ctb = Conv.GetDstTbl(GT)
    for i=1, GetNumGuilds() do
      local guildId=GetGuildId(i)
      local GS = self:GetGuildSettings(guildId)
      if GS.GuildType == GT or ctb[GS.GuildType] ~= nil then
        for memberId=1, GetNumGuildMembers(guildId) do
          local accName,note,rankIndex,playerStatus=GetGuildMemberInfo(guildId, memberId)
          if MemberName==accName then
            local data={displayName=accName,note=note,rankIndex=rankIndex,status=playerStatus,}
            local e = GR.EncEx
            self:LdMemberNote(data, e)
            local fl = e.CodeStrPresent and e.Error==0
            if not fl then
              for i, v in pairs(ctb) do
                local GR1 = DBGN:GetGuildTypeRec(i)
                local e1 = GR1.EncEx
                e1:InitRec()
                e1.Str = note
                Conv.CopySpecialField(e.r, e1.r)
                e1:FindCodeStr()
                if e1.CodeStrPresent then
                  e1:Decode()
                  v.Convert(e1.r, e)
                  e.Str = e1:GetStrClear()
                  fl = true
                  break
                end
              end
            end
            if fl then
              return ZO_ShallowTableCopy({},e.r)
            end
          end
        end
      end
    end
  end
  return nil
end

--
-- Section 10: Regester addon
--
EVENT_MANAGER:RegisterForEvent(DBGN.Name, EVENT_ADD_ON_LOADED, DBGN.OnAddOnLoaded)