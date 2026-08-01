local DBGN = DBGN
local l = DBGN.i18n

--
-- Section 0: Guild Record
--
local GuildSet = {
  Code = "GS",
  Name = "Guild Settings",
  Pref = "{GS",
  Suff = "}",
--  EncEd = {},
--  EncEx = {},
  UI_Ed = {CB = {},},
--GuildSet:UI_Ed_Init()
--GuildSet:UI_Ed_Upd()
--GuildSet:UI_Ed_GetVal()
--GuildSet:UI_Ed_Keybind(keybind)
}

--
-- Section 1: Initialize Record
--
local function InitRec(self)
  local r = self.r
  r.GuildType = 1
  r.Officer = 0
  r.ClearText = ""
end

--
-- Section 2: Decode note
--
local function DecodeStrV0(self)
  local r, n, a = self.r, self.n, 0
  r.GuildType = n[1]
  r.Officer, a = self:DecNumb(n[2],8)
end

--
-- Section 3: Encode note
--
local function EncodeStr(self)
  self:ClearN()
  local r, n, a, b = self.r, self.n, 0, 0
  n[1] = self:EncN1V(r.GuildType)
  n[2] = self:EncNumb(r.Officer,1,7)
--> Calc CRC
  n[3], n[4] = self:CalcCRC(2)
--
  local s = self.Pref .. self.EncArr[self.CurVers]
  for i = 1, 4 do s = s .. self.EncArr[n[i]] end
  self.CodeStr = s .. self.Suff
end

--
-- Section 4: Create encode/decode engine
--
function GuildSet:CreateEncDecEngine(len)
  local Enc = LibFLEncode(self.Pref, self.Suff, InitRec, EncodeStr, len)
  local Vers = {
    [0] = {CodeStrLen = 9, CRCLen = 2, Decode = DecodeStrV0,},
  }
  Enc:SetVersions(Vers)
  return Enc
end

--
-- Section 5: Initialize UI
--
function GuildSet.Get_GS_Str(e)
  return e:GetStrBeg() .. e.CodeStr .. e:GetStrEnd()
end

function GuildSet:ButtonCancelClik()
  DBGN:HideModalDialog(self.UI_Ed.Win)
end

function GuildSet:ButtonSaveClik()
  self:UI_Ed_GetVal()
  self.EncEd:Encode()
  if self.OutEB then self.OutEB:SetText(self.Get_GS_Str(self.EncEd)) end
  DBGN:HideModalDialog(self.UI_Ed.Win)
end

function GuildSet:UI_Ed_Keybind(keybind)
  if keybind == "DIALOG_PRIMARY" then
    self:ButtonSaveClik()
  elseif keybind == "DIALOG_NEGATIVE" then
    self:ButtonCancelClik()
  end
end

function GuildSet:UI_Ed_Init()
  DBGN_EditGSTitle:SetText(l.GS_Title)
  DBGN_EditGSGuildTypeTxt:SetText(l.GS_Type)
  DBGN_EditGSOfficerTxt:SetText(l.GS_Officer)

  local u = self.UI_Ed
  u.Win       = DBGN_EditGS
  u.GuildType = DBGN_EditGSGuildTypeVal
  u.Officer   = DBGN_EditGSOfficerVal
  u.bSave     = DBGN_EditGSButtonSave
  u.bCancel   = DBGN_EditGSButtonCancel
  u.CB = {}
  u.CB.GuildType = ZO_ComboBox_ObjectFromContainer(u.GuildType)
  u.CB.Officer = ZO_ComboBox_ObjectFromContainer(u.Officer)

  u.GuildType:SetDimensions(230, 31)
  u.Officer:SetDimensions(230, 31)
  local arr,AGT = {},DBGN.AvlGuildType
  for i = 1,AGT.MaxNumber do arr[i] = AGT[i].Code .. " - " .. AGT[i].Name end
  arr[AGT.MaxNumber+1] = AGT[0].Code .. " - " .. AGT[0].Name
  DBGN:InitCB(u.CB.GuildType, arr, AGT.MaxNumber+1)

  ZO_KeybindButtonTemplate_Setup(u.bSave,   "DIALOG_PRIMARY",  nil, GetString(SI_SAVE))
  ZO_KeybindButtonTemplate_Setup(u.bCancel, "DIALOG_NEGATIVE", nil, GetString(SI_CANCEL))
end

--
-- Section 6: Update UI
--
function GuildSet.Ld_GS_Str(e, s)
  e:InitRec()
  e.Str = s
  e:FindCodeStr()
  if e.CodeStrPresent then e:Decode() end
end

function GuildSet:UI_Ed_SetGSType(control)
  self.OutEB = control
  self.Ld_GS_Str(self.EncEd, control:GetText())
  local u = self.UI_Ed
  u.bSave:SetCallback(function(keybind) self:ButtonSaveClik(keybind) end)
  u.bCancel:SetCallback(function(keybind) self:ButtonCancelClik(keybind) end)
  u.bSave:SetKeybindEnabled(true)
  u.bCancel:SetKeybindEnabled(true)
end

function GuildSet:UI_Ed_Upd()
  local u,r = self.UI_Ed,self.EncEd.r

  local max = DBGN.AvlGuildType.MaxNumber+1
  DBGN:Set_CB_Val(u.CB.GuildType, r.GuildType, 1, max, max)

  local arr = {}
  local guildId = GUILD_ROSTER_MANAGER:GetGuildId()
  local numRanks = GetNumGuildRanks(guildId)
  if numRanks > 8 then numRanks = 8 end
  for i = 1,numRanks do arr[i] = GetFinalGuildRankName(guildId, i) end
  if r.Officer+1 > numRanks then r.Officer = numRanks-1 end
  DBGN:InitCB(u.CB.Officer, arr, numRanks, r.Officer+1)
end

--
-- Section 7: Get values from Edit UI
--
function GuildSet:UI_Ed_GetVal()
  local u = self.UI_Ed
  local r = self.EncEd.r
  local max = DBGN.AvlGuildType.MaxNumber
  r.GuildType = DBGN:Get_CB_Val(u.CB.GuildType, 1, max, 0)
  r.Officer  = DBGN:Get_CB_Val(u.CB.Officer, 1, 8, 1) - 1
end

--
-- Section 8: Get guild settings for regester
--
function DBGN.GetGuildSettingsRec(isMotD)
  if GuildSet.Initialized == nil then
    GuildSet:UI_Ed_Init()
    GuildSet.Initialized = true
  end
  local g = setmetatable(
    {EncEd = {},EncEx = {},},
    {__index = GuildSet}
  )
  local len = MAX_GUILD_DESCRIPTION_LENGTH
  if isMotD == true then len = MAX_GUILD_MOTD_LENGTH end
  g.EncEd = g:CreateEncDecEngine(len)
  g.EncEx = g:CreateEncDecEngine(len)
  return g
end