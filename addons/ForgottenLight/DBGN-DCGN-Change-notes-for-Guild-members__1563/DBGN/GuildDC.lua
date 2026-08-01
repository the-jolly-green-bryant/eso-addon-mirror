local DBGN = DBGN
local Ico  = DBGN.Icons
local Ic1  = DBGN.IconsDC
local l = DBGN.i18n
local m = DBGN.Markers
local g = DBGN.MarkersGr
local CTrials = DBGN.Colors.Trials
local CPvP = DBGN.Colors.PvP_DC
local LPad = DBGN.LPad
local msg = DBGN.msg
local nvl = DBGN.nvl
--
-- Section 0: Guild Record
--
local Guild = {
  Code = "DCGN",
  Name = "Domain Community",
  Pref = "{DCGN",
  Suff = "}",
  EncTT = {},
  EncEd = {},
  EncFl = {},
  EncEx = {},
  UI_TT = {},
  UI_Ed = {CB = {},},
  UI_Fl = {CB = {},},
--Guild:UI_TT_Init()
--Guild:UI_Ed_Init()
--Guild:UI_Fl_Init()
--Guild:UI_TT_Upd()
--Guild:UI_Ed_Upd()
--Guild:UI_Ed_GetVal()
--Guild.UI_Ed_Keybind(keybind)
--Guild:UI_Fl_Check() return bool
--Guild:UI_Fl_WinMove()
}

--
-- Section 1: Initialize Record
--
local function InitRec(self)
  local r = self.r
  r.Discord = false
  r.Vamp = false
  r.WW = false
--
  r.CraftBlk = false
  r.CraftWWr = false
  r.CraftClt = false
  r.CraftEnch = false
  r.CraftAlch = false
  r.CraftJew = false
  r.CraftProv = false
--  r.CraftAmbr = 0
--
  r.PvP_Rank = 0
  r.PvP_Duelist = false
  r.PvP_Emperor = false
  r.PvP_Duel = 0
  r.PvP_Raid = 0
--
  r.Solo_MSA = 0
  r.Solo_VH = 0
--
  r.AttestDD = 0
  r.AttestHeal = 0
  r.AttestTank = 0
  r.DPS = 0
--
  r.DD_AA = 0
  r.DD_SO = 0
  r.DD_HRC = 0
  r.DD_DSA = 0
  r.DD_HoF = 0
  r.DD_MoL = 0
  r.DD_BRP = 0
  r.DD_AS = 0
  r.DD_CR = 0
  r.DD_SS = 0
  r.DD_KA = 0
  r.DD_RG = 0
  r.DD_DSR = 0
  r.DD_SE = 0
  r.DD_LC = 0
  r.DD_OC = 0
--
  r.Heal_AA = 0
  r.Heal_SO = 0
  r.Heal_HRC = 0
  r.Heal_DSA = 0
  r.Heal_HoF = 0
  r.Heal_MoL = 0
  r.Heal_BRP = 0
  r.Heal_AS = 0
  r.Heal_CR = 0
  r.Heal_SS = 0
  r.Heal_KA = 0
  r.Heal_RG = 0
  r.Heal_DSR = 0
  r.Heal_SE = 0
  r.Heal_LC = 0
  r.Heal_OC = 0
--
  r.Tank_AA = 0
  r.Tank_SO = 0
  r.Tank_HRC = 0
  r.Tank_DSA = 0
  r.Tank_HoF = 0
  r.Tank_MoL = 0
  r.Tank_BRP = 0
  r.Tank_AS = 0
  r.Tank_CR = 0
  r.Tank_SS = 0
  r.Tank_KA = 0
  r.Tank_RG = 0
  r.Tank_DSR = 0
  r.Tank_SE = 0
  r.Tank_LC = 0
  r.Tank_OC = 0
--
  r.ClearText = ""
end

--
-- Section 2: Decode note
--
local function Chk_Trial_Max(r)
  local t = DBGN.Trial_Max
  local m = t.AS
  if r.DD_AS   > m then r.DD_AS = m end
  if r.Heal_AS > m then r.Heal_AS = m end
  if r.Tank_AS > m then r.Tank_AS = m end
  m = t.CR
  if r.DD_CR   > m then r.DD_CR = m end
  if r.Heal_CR > m then r.Heal_CR = m end
  if r.Tank_CR > m then r.Tank_CR = m end
  m = t.SS
  if r.DD_SS   > m then r.DD_SS = m end
  if r.Heal_SS > m then r.Heal_SS = m end
  if r.Tank_SS > m then r.Tank_SS = m end
  m = t.KA
  if r.DD_KA   > m then r.DD_KA = m end
  if r.Heal_KA > m then r.Heal_KA = m end
  if r.Tank_KA > m then r.Tank_KA = m end
  m = t.RG
  if r.DD_RG   > m then r.DD_RG = m end
  if r.Heal_RG > m then r.Heal_RG = m end
  if r.Tank_RG > m then r.Tank_RG = m end
  m = t.DSR
  if r.DD_DSR   > m then r.DD_DSR = m end
  if r.Heal_DSR > m then r.Heal_DSR = m end
  if r.Tank_DSR > m then r.Tank_DSR = m end
  m = t.SE
  if r.DD_SE   > m then r.DD_SE = m end
  if r.Heal_SE > m then r.Heal_SE = m end
  if r.Tank_SE > m then r.Tank_SE = m end
  m = t.LC
  if r.DD_LC   > m then r.DD_LC = m end
  if r.Heal_LC > m then r.Heal_LC = m end
  if r.Tank_LC > m then r.Tank_LC = m end
  m = t.OC
  if r.DD_OC   > m then r.DD_OC = m end
  if r.Heal_OC > m then r.Heal_OC = m end
  if r.Tank_OC > m then r.Tank_OC = m end
end
-- Add function to Guild interface
-- Guild.Chk_Trial_Max = Chk_Trial_Max
-- Add function to DBGN interface
DBGN.Chk_Trial_Max_DC = Chk_Trial_Max

local function DecodeStrV0(self)
  local r, n, a, b = self.r, self.n, 0, 0
  r.Vamp,   a = self:DecBool(n[1])
  r.WW,     a = self:DecBool(a)
  r.Discord,a = self:DecBool(a)
--
  r.CraftBlk,  a = self:DecBool(n[2])
  r.CraftWWr,  a = self:DecBool(a)
  r.CraftClt,  a = self:DecBool(a)
  r.CraftEnch, a = self:DecBool(a)
  r.CraftAlch, a = self:DecBool(a)
  r.CraftJew,  a = self:DecBool(a)
  r.CraftProv, a = self:DecBool(n[3])
--  r.CraftAmbr, a = self:DecNumb(a,4)
--
  r.PvP_Rank,    a = self:DecNumb(n[4],8)
  r.PvP_Duelist, a = self:DecBool(a)
  r.PvP_Emperor, a = self:DecBool(a)
  r.PvP_Duel = n[5] * 64 + n[6]
  r.PvP_Raid = n[7] * 64 + n[8]
--
  r.Solo_MSA, a = self:DecNumb(n[9],4)
  r.Solo_VH,  a = self:DecNumb(a,4)
--
  r.AttestDD,   a = self:DecNumb(n[10],4)
  r.AttestHeal, a = self:DecNumb(a,4)
  r.AttestTank, a = self:DecNumb(a,4)
  r.DPS = n[11] * 4096 + n[12] * 64 + n[13]
--
  r.DD_AA,    a = self:DecNumb(n[14],4)
  r.DD_SO,    a = self:DecNumb(a,4)
  r.DD_HRC,   a = self:DecNumb(a,4)
  r.DD_DSA,   a = self:DecNumb(n[15],4)
  r.DD_HoF,   a = self:DecNumb(a,4)
  r.DD_MoL,   a = self:DecNumb(a,4)
  r.DD_BRP,   a = self:DecNumb(n[16],4)
  _      ,    a = self:DecNumb(a,2)
  r.DD_SE,    a = self:DecNumb(a,8)
  r.DD_AS,    a = self:DecNumb(n[17],8)
  r.DD_CR,    a = self:DecNumb(a,8)
  r.DD_SS,    a = self:DecNumb(n[18],8)
  r.DD_KA,    a = self:DecNumb(a,8)
  r.DD_RG,    a = self:DecNumb(n[19],8)
  r.DD_DSR,   a = self:DecNumb(a,8)
--
  r.Heal_AA,  a = self:DecNumb(n[20],4)
  r.Heal_SO,  a = self:DecNumb(a,4)
  r.Heal_HRC, a = self:DecNumb(a,4)
  r.Heal_DSA, a = self:DecNumb(n[21],4)
  r.Heal_HoF, a = self:DecNumb(a,4)
  r.Heal_MoL, a = self:DecNumb(a,4)
  r.Heal_BRP, a = self:DecNumb(n[22],4)
  _        ,  a = self:DecNumb(a,2)
  r.Heal_SE,  a = self:DecNumb(a,8)
  r.Heal_AS,  a = self:DecNumb(n[23],8)
  r.Heal_CR,  a = self:DecNumb(a,8)
  r.Heal_SS,  a = self:DecNumb(n[24],8)
  r.Heal_KA,  a = self:DecNumb(a,8)
  r.Heal_RG,  a = self:DecNumb(n[25],8)
  r.Heal_DSR, a = self:DecNumb(a,8)
--
  r.Tank_AA,  a = self:DecNumb(n[26],4)
  r.Tank_SO,  a = self:DecNumb(a,4)
  r.Tank_HRC, a = self:DecNumb(a,4)
  r.Tank_DSA, a = self:DecNumb(n[27],4)
  r.Tank_HoF, a = self:DecNumb(a,4)
  r.Tank_MoL, a = self:DecNumb(a,4)
  r.Tank_BRP, a = self:DecNumb(n[28],4)
  _        ,  a = self:DecNumb(a,2)
  r.Tank_SE,  a = self:DecNumb(a,8)
  r.Tank_AS,  a = self:DecNumb(n[29],8)
  r.Tank_CR,  a = self:DecNumb(a,8)
  r.Tank_SS,  a = self:DecNumb(n[30],8)
  r.Tank_KA,  a = self:DecNumb(a,8)
  r.Tank_RG,  a = self:DecNumb(n[31],8)
  r.Tank_DSR, a = self:DecNumb(a,8)
  Chk_Trial_Max(r)
end

local function DecodeStrV1(self)
  local r, n, a, b = self.r, self.n, 0, 0
  r.Vamp,   a = self:DecBool(n[1])
  r.WW,     a = self:DecBool(a)
  r.Discord,a = self:DecBool(a)
--
  r.CraftBlk,  a = self:DecBool(n[2])
  r.CraftWWr,  a = self:DecBool(a)
  r.CraftClt,  a = self:DecBool(a)
  r.CraftEnch, a = self:DecBool(a)
  r.CraftAlch, a = self:DecBool(a)
  r.CraftJew,  a = self:DecBool(a)
  r.CraftProv, a = self:DecBool(n[3])
--  r.CraftAmbr, a = self:DecNumb(a,4)
--
  r.PvP_Rank,    a = self:DecNumb(n[4],8)
  r.PvP_Duelist, a = self:DecBool(a)
  r.PvP_Emperor, a = self:DecBool(a)
  r.PvP_Duel = n[5] * 64 + n[6]
  r.PvP_Raid = n[7] * 64 + n[8]
--
  r.Solo_MSA, a = self:DecNumb(n[9],4)
  r.Solo_VH,  a = self:DecNumb(a,4)
--
  r.AttestDD,   a = self:DecNumb(n[10],4)
  r.AttestHeal, a = self:DecNumb(a,4)
  r.AttestTank, a = self:DecNumb(a,4)
  r.DPS = n[11] * 4096 + n[12] * 64 + n[13]
--
  r.DD_AA,    a = self:DecNumb(n[14],4)
  r.DD_SO,    a = self:DecNumb(a,4)
  r.DD_HRC,   a = self:DecNumb(a,4)
  r.DD_DSA,   a = self:DecNumb(n[15],4)
  r.DD_BRP,   a = self:DecNumb(a,4)
--_      ,    a = self:DecNumb(a,4)
  r.DD_MoL,   a = self:DecNumb(n[16],8)
  r.DD_HoF,   a = self:DecNumb(a,8)
  r.DD_CR,    a = self:DecNumb(n[17],16)
--_      ,    a = self:DecNumb(a,4)
  r.DD_AS,    a = self:DecNumb(n[18],8)
  r.DD_SS,    a = self:DecNumb(a,8)
  r.DD_KA,    a = self:DecNumb(n[19],8)
  r.DD_RG,    a = self:DecNumb(a,8)
  r.DD_DSR,   a = self:DecNumb(n[20],8)
  r.DD_SE,    a = self:DecNumb(a,8)
  r.DD_LC,    a = self:DecNumb(n[21],8)
  r.DD_OC,    a = self:DecNumb(a,8)
--
  r.Heal_AA,    a = self:DecNumb(n[22],4)
  r.Heal_SO,    a = self:DecNumb(a,4)
  r.Heal_HRC,   a = self:DecNumb(a,4)
  r.Heal_DSA,   a = self:DecNumb(n[23],4)
  r.Heal_BRP,   a = self:DecNumb(a,4)
--_      ,    a = self:DecNumb(a,4)
  r.Heal_MoL,   a = self:DecNumb(n[24],8)
  r.Heal_HoF,   a = self:DecNumb(a,8)
  r.Heal_CR,    a = self:DecNumb(n[25],16)
--_      ,    a = self:DecNumb(a,4)
  r.Heal_AS,    a = self:DecNumb(n[26],8)
  r.Heal_SS,    a = self:DecNumb(a,8)
  r.Heal_KA,    a = self:DecNumb(n[27],8)
  r.Heal_RG,    a = self:DecNumb(a,8)
  r.Heal_DSR,   a = self:DecNumb(n[28],8)
  r.Heal_SE,    a = self:DecNumb(a,8)
  r.Heal_LC,    a = self:DecNumb(n[29],8)
  r.Heal_OC,    a = self:DecNumb(a,8)
--
  r.Tank_AA,    a = self:DecNumb(n[30],4)
  r.Tank_SO,    a = self:DecNumb(a,4)
  r.Tank_HRC,   a = self:DecNumb(a,4)
  r.Tank_DSA,   a = self:DecNumb(n[31],4)
  r.Tank_BRP,   a = self:DecNumb(a,4)
--_      ,    a = self:DecNumb(a,4)
  r.Tank_MoL,   a = self:DecNumb(n[32],8)
  r.Tank_HoF,   a = self:DecNumb(a,8)
  r.Tank_CR,    a = self:DecNumb(n[33],16)
--_      ,    a = self:DecNumb(a,4)
  r.Tank_AS,    a = self:DecNumb(n[34],8)
  r.Tank_SS,    a = self:DecNumb(a,8)
  r.Tank_KA,    a = self:DecNumb(n[35],8)
  r.Tank_RG,    a = self:DecNumb(a,8)
  r.Tank_DSR,   a = self:DecNumb(n[36],8)
  r.Tank_SE,    a = self:DecNumb(a,8)
  r.Tank_LC,    a = self:DecNumb(n[37],8)
  r.Tank_OC,    a = self:DecNumb(a,8)
  Chk_Trial_Max(r)
end

--
-- Section 3: Encode note
--
local function EncodeStr(self)
  self:ClearN()
  local r, n, a, b, x = self.r, self.n, 0, 0, DBGN.Trial_Max
  n[1] = self:EncBool(r.Vamp,1) + self:EncBool(r.WW,2) + self:EncBool(r.Discord,4)
--
  n[2] = self:EncBool(r.CraftBlk,1) + self:EncBool(r.CraftWWr,2) + self:EncBool(r.CraftClt,4) + self:EncBool(r.CraftEnch,8) + self:EncBool(r.CraftAlch,16) + self:EncBool(r.CraftJew,32)
  n[3] = self:EncBool(r.CraftProv,1) -- + self:EncNumb(r.CraftAmbr,2,3)
--
  n[4] = self:EncNumb(r.PvP_Rank,1,6) + self:EncBool(r.PvP_Duelist,8) + self:EncBool(r.PvP_Emperor,16)
--
  n[5], n[6] = self:EncN2V(r.PvP_Duel)
  n[7], n[8] = self:EncN2V(r.PvP_Raid)
  n[9] = self:EncNumb(r.Solo_MSA,1,3) + self:EncNumb(r.Solo_VH,4,3)
--
  n[10] = self:EncNumb(r.AttestDD,1,3) + self:EncNumb(r.AttestHeal,4,3) + self:EncNumb(r.AttestTank,16,3)
  n[11],n[12],n[13] = self:EncN3V(r.DPS)
--
  n[14] = self:EncNumb(r.DD_AA,1,3) + self:EncNumb(r.DD_SO,4,3) + self:EncNumb(r.DD_HRC,16,3)
  n[15] = self:EncNumb(r.DD_DSA,1,3) + self:EncNumb(r.DD_BRP,4,3)
  n[16] = self:EncNumb(r.DD_MoL,1,x.MoL) + self:EncNumb(r.DD_HoF,8,x.HoF)
  n[17] = self:EncNumb(r.DD_CR,1,x.CR)
  n[18] = self:EncNumb(r.DD_AS,1,x.AS) + self:EncNumb(r.DD_SS,8,x.SS)
  n[19] = self:EncNumb(r.DD_KA,1,x.KA) + self:EncNumb(r.DD_RG,8,x.RG)
  n[20] = self:EncNumb(r.DD_DSR,1,x.DSR) + self:EncNumb(r.DD_SE,8,x.SE)
  n[21] = self:EncNumb(r.DD_LC,1,x.LC) + self:EncNumb(r.DD_OC,8,x.OC)
--
  n[22] = self:EncNumb(r.Heal_AA,1,3) + self:EncNumb(r.Heal_SO,4,3) + self:EncNumb(r.Heal_HRC,16,3)
  n[23] = self:EncNumb(r.Heal_DSA,1,3) + self:EncNumb(r.Heal_BRP,4,3)
  n[24] = self:EncNumb(r.Heal_MoL,1,x.MoL) + self:EncNumb(r.Heal_HoF,8,x.HoF)
  n[25] = self:EncNumb(r.Heal_CR,1,x.CR)
  n[26] = self:EncNumb(r.Heal_AS,1,x.AS) + self:EncNumb(r.Heal_SS,8,x.SS)
  n[27] = self:EncNumb(r.Heal_KA,1,x.KA) + self:EncNumb(r.Heal_RG,8,x.RG)
  n[28] = self:EncNumb(r.Heal_DSR,1,x.DSR) + self:EncNumb(r.Heal_SE,8,x.SE)
  n[29] = self:EncNumb(r.Heal_LC,1,x.LC) + self:EncNumb(r.Heal_OC,8,x.OC)
--
  n[30] = self:EncNumb(r.Tank_AA,1,3) + self:EncNumb(r.Tank_SO,4,3) + self:EncNumb(r.Tank_HRC,16,3)
  n[31] = self:EncNumb(r.Tank_DSA,1,3) + self:EncNumb(r.Tank_BRP,4,3)
  n[32] = self:EncNumb(r.Tank_MoL,1,x.MoL) + self:EncNumb(r.Tank_HoF,8,x.HoF)
  n[33] = self:EncNumb(r.Tank_CR,1,x.CR)
  n[34] = self:EncNumb(r.Tank_AS,1,x.AS) + self:EncNumb(r.Tank_SS,8,x.SS)
  n[35] = self:EncNumb(r.Tank_KA,1,x.KA) + self:EncNumb(r.Tank_RG,8,x.RG)
  n[36] = self:EncNumb(r.Tank_DSR,1,x.DSR) + self:EncNumb(r.Tank_SE,8,x.SE)
  n[37] = self:EncNumb(r.Tank_LC,1,x.LC) + self:EncNumb(r.Tank_OC,8,x.OC)
--> Calc CRC
  n[38], n[39] = self:CalcCRC(37)
--
  local s = self.Pref .. self.EncArr[self.CurVers]
  for i = 1, 39 do s = s .. self.EncArr[n[i]] end
  self.CodeStr = s .. self.Suff
end

--
-- Section 4: Create encode/decode engine
--
function Guild:CreateEncDecEngine()
  local Enc = LibFLEncode(self.Pref, self.Suff, InitRec, EncodeStr, 254)
  local Vers = {
    [0] = {CodeStrLen = 40, CRCLen = 31, Decode = DecodeStrV0,},
    [1] = {CodeStrLen = 46, CRCLen = 37, Decode = DecodeStrV1,},
  }
  Enc:SetVersions(Vers)
  return Enc
end

--
-- Section 5: Initialize UI
--
local function SetTextureOnOff(c, i, f)
  if f then c:SetTexture(i.On) else c:SetTexture(i.Off) end
end
--
-- Section 5.1: Initialize ToolTip UI
--
function Guild:UI_TT_Init()
  DCGN_TTWinVamp:SetText(l.Vamp)
  DCGN_TTWinWW:SetText(l.WW)
  DCGN_TTWinDiscord:SetText(l.Discord)
--
  DCGN_TTWinAttestHdr:SetText(l.AttestHdr)
  DCGN_TTWinCraftHdr:SetText(l.CraftHdr)
  DCGN_TTWinNoteHdr:SetText(l.NoteHdr)
  DCGN_TTWinNoteHdr:SetDimensions(120, 24)
--
  local u = self.UI_TT
  u.Win       = DCGN_TTWin
  u.OnLineIco = DCGN_TTWinOnLineIco
  u.Account   = DCGN_TTWinAccount
  u.RankIco   = DCGN_TTWinRankIco
  u.Rank      = DCGN_TTWinRank
  u.FlDiscord = DCGN_TTWinDiscord
  u.FlVamp    = DCGN_TTWinVamp
  u.FlWW      = DCGN_TTWinWW
--
  u.DDVal     = DCGN_TTWinAttestDDVal
  u.DDAdd     = DCGN_TTWinAttestDDAdd
  u.DDAd2     = DCGN_TTWinAttestDDAd2
  u.DDAd3     = DCGN_TTWinAttestDDAd3
  u.DPS       = DCGN_TTWinAttestDPS
  u.HealVal   = DCGN_TTWinAttestHealVal
  u.HealAdd   = DCGN_TTWinAttestHealAdd
  u.HealAd2   = DCGN_TTWinAttestHealAd2
  u.HealAd3   = DCGN_TTWinAttestHealAd3
  u.TankVal   = DCGN_TTWinAttestTankVal
  u.TankAdd   = DCGN_TTWinAttestTankAdd
  u.TankAd2   = DCGN_TTWinAttestTankAd2
  u.TankAd3   = DCGN_TTWinAttestTankAd3
  u.PvPVal    = DCGN_TTWinAttestPvPVal
  u.PvPAdd    = DCGN_TTWinAttestPvPAdd
  u.DuelVal   = DCGN_TTWinAttestDuelVal
  u.RaidVal   = DCGN_TTWinAttestRaidVal
  u.SoloAdd   = DCGN_TTWinAttestSoloAdd
--
  u.CraftBlk  = DCGN_TTWinCraftBlk
  u.CraftWWr  = DCGN_TTWinCraftWWr
  u.CraftClt  = DCGN_TTWinCraftClt
  u.CraftEnch = DCGN_TTWinCraftEnch
  u.CraftAlch = DCGN_TTWinCraftAlch
  u.CraftJew  = DCGN_TTWinCraftJew
  u.CraftProv = DCGN_TTWinCraftProv
  u.CraftAmbr = DCGN_TTWinCraftAmbr
--  u.CraftAmbT = DCGN_TTWinCraftAmbrTxt
  u.Note      = DCGN_TTWinNoteTxt
  u.Error     = DCGN_TTWinNoteError
end

--
-- Section 5.2: Initialize Edit UI
--
function Guild:UI_Ed_Init_TrialsL1(u, ctrl)
  u.AA  = GetControl(ctrl,"AA")
  u.SO  = GetControl(ctrl,"SO")
  u.HRC = GetControl(ctrl,"HRC")
  u.MoL = GetControl(ctrl,"MoL")
  u.HoF = GetControl(ctrl,"HoF")
  u.AS  = GetControl(ctrl,"AS")
  u.CR  = GetControl(ctrl,"CR")
  u.SS  = GetControl(ctrl,"SS")
  u.CB_AA  = ZO_ComboBox_ObjectFromContainer(u.AA)
  u.CB_SO  = ZO_ComboBox_ObjectFromContainer(u.SO)
  u.CB_HRC = ZO_ComboBox_ObjectFromContainer(u.HRC)
  u.CB_MoL = ZO_ComboBox_ObjectFromContainer(u.MoL)
  u.CB_HoF = ZO_ComboBox_ObjectFromContainer(u.HoF)
  u.CB_AS  = ZO_ComboBox_ObjectFromContainer(u.AS)
  u.CB_CR  = ZO_ComboBox_ObjectFromContainer(u.CR)
  u.CB_SS  = ZO_ComboBox_ObjectFromContainer(u.SS)

  local arr, x = {}, DBGN.Trial_Max
  arr[1] = l.None
  for i = 1,3 do arr[i+1] = g.AA[i]  end DBGN:InitCB(u.CB_AA,  arr, 4)
  for i = 1,3 do arr[i+1] = g.SO[i]  end DBGN:InitCB(u.CB_SO,  arr, 4)
  for i = 1,3 do arr[i+1] = g.HRC[i] end DBGN:InitCB(u.CB_HRC, arr, 4)
  for i = 1,x.MoL do arr[i+1] = g.MoL[i] end DBGN:InitCB(u.CB_MoL, arr, x.MoL+1)
  for i = 1,x.HoF do arr[i+1] = g.HoF[i] end DBGN:InitCB(u.CB_HoF, arr, x.HoF+1)
  for i = 1,x.AS  do arr[i+1] = g.AS[i]  end DBGN:InitCB(u.CB_AS,  arr, x.AS +1)
  for i = 1,x.CR  do arr[i+1] = g.CR[i]  end DBGN:InitCB(u.CB_CR,  arr, x.CR +1)
  for i = 1,x.SS  do arr[i+1] = g.SS[i]  end DBGN:InitCB(u.CB_SS,  arr, x.SS +1)
end

function Guild:UI_Ed_Init_TrialsL2(u, ctrl)
  u.KA  = GetControl(ctrl,"KA")
  u.RG  = GetControl(ctrl,"RG")
  u.DSR = GetControl(ctrl,"DSR")
  u.SE  = GetControl(ctrl,"SE")
  u.LC  = GetControl(ctrl,"LC")
  u.OC  = GetControl(ctrl,"OC")
  u.DSA = GetControl(ctrl,"DSA")
  u.BRP = GetControl(ctrl,"BRP")
  u.CB_KA  = ZO_ComboBox_ObjectFromContainer(u.KA)
  u.CB_RG  = ZO_ComboBox_ObjectFromContainer(u.RG)
  u.CB_DSR = ZO_ComboBox_ObjectFromContainer(u.DSR)
  u.CB_SE  = ZO_ComboBox_ObjectFromContainer(u.SE)
  u.CB_LC  = ZO_ComboBox_ObjectFromContainer(u.LC)
  u.CB_OC  = ZO_ComboBox_ObjectFromContainer(u.OC)
  u.CB_DSA = ZO_ComboBox_ObjectFromContainer(u.DSA)
  u.CB_BRP = ZO_ComboBox_ObjectFromContainer(u.BRP)

  local arr, x = {}, DBGN.Trial_Max
  arr[1] = l.None
  for i = 1,x.KA  do arr[i+1] = g.KA[i]  end DBGN:InitCB(u.CB_KA,  arr, x.KA +1)
  for i = 1,x.RG  do arr[i+1] = g.RG[i]  end DBGN:InitCB(u.CB_RG,  arr, x.RG +1)
  for i = 1,x.DSR do arr[i+1] = g.DSR[i] end DBGN:InitCB(u.CB_DSR, arr, x.DSR+1)
  for i = 1,x.SE  do arr[i+1] = g.SE[i]  end DBGN:InitCB(u.CB_SE,  arr, x.SE +1)
  for i = 1,x.LC  do arr[i+1] = g.LC[i]  end DBGN:InitCB(u.CB_LC,  arr, x.LC +1)
  for i = 1,x.OC  do arr[i+1] = g.OC[i]  end DBGN:InitCB(u.CB_OC,  arr, x.OC +1)
  for i = 1,2 do arr[i+1] = g.DSA[i] end DBGN:InitCB(u.CB_DSA, arr, 3)
  for i = 1,2 do arr[i+1] = g.BRP[i] end DBGN:InitCB(u.CB_BRP, arr, 3)
end

function Guild.ButtonCancelClik(keybind)
  DBGN:HideModalDialog(Guild.UI_Ed.Win)
end

function Guild.ButtonSaveClik(keybind)
  Guild:UI_Ed_GetVal()
  Guild.EncEd:Encode()
  DBGN:SaveGuildNote(Guild.EncEd)
  DBGN:HideModalDialog(Guild.UI_Ed.Win)
end

function Guild.UI_Ed_Keybind(keybind)
  if keybind == "DIALOG_PRIMARY" then
    Guild.ButtonSaveClik(keybind)
  elseif keybind == "DIALOG_NEGATIVE" then
    Guild.ButtonCancelClik(keybind)
  end
end

function Guild:InitCraftButton(c, i, tt, def)
  DBGN:InitOnOffButton(c, i.On, i.Off, tt, def, nil)
end

function Guild:UI_Ed_Init()
  DCGN_EdWinTitle:SetText(l.EditTitle)
  DCGN_EdWinMainFlHdr:SetText(l.MainFlHdr)
  DCGN_EdWinMainFlDiscordTxt:SetText(l.Discord)
  DCGN_EdWinMainFlVampTxt:SetText(l.Vamp)
  DCGN_EdWinMainFlWWTxt:SetText(l.WW)
--DCGN_EdWinMainFlHouseTxt:SetText(l.House)
--
  DCGN_EdWinCraftHdr:SetText(l.CraftHdr)
--DCGN_EdWinCraftAmbrIco:SetTexture(Ic1.Ambr.On)
--
  DCGN_EdWinAttestHdr:SetText(l.AttestHdr)
  DCGN_EdWinAttestDuelistTxt:SetText(l.Duelist)
  DCGN_EdWinAttestEmperorTxt:SetText(l.Emperor)
--
  DCGN_EdWinNoteHdr:SetText(l.NoteHdr)

  local u = self.UI_Ed
  u.Win       = DCGN_EdWin
  u.OnLineIco = DCGN_EdWinOnLineIco
  u.Account   = DCGN_EdWinAccount
  u.RankIco   = DCGN_EdWinRankIco
  u.Rank      = DCGN_EdWinRank
  u.FlDiscord = DCGN_EdWinMainFlDiscordChk
  u.FlVamp    = DCGN_EdWinMainFlVampChk
  u.FlWW      = DCGN_EdWinMainFlWWChk
--u.FlHouse   = DCGN_EdWinMainFlHouseChk
  u.Craft = {
    Blk  = DCGN_EdWinCraftBlk,
    WWr  = DCGN_EdWinCraftWWr,
    Clt  = DCGN_EdWinCraftClt,
    Ench = DCGN_EdWinCraftEnch,
    Alch = DCGN_EdWinCraftAlch,
    Jew  = DCGN_EdWinCraftJew,
    Prov = DCGN_EdWinCraftProv,
--  Ambr = DCGN_EdWinCraftAmbrVal,
  }
  u.DD       = {Val = DCGN_EdWinAttestDDVal, DPS = DCGN_EdWinAttestDPSText,}
  u.Heal     = {Val = DCGN_EdWinAttestHealVal,}
  u.Tank     = {Val = DCGN_EdWinAttestTankVal,}
  u.Solo     = {MSA = DCGN_EdWinAttestSoloMSA, VH = DCGN_EdWinAttestSoloVH,}
  u.PvP      = {Val = DCGN_EdWinAttestPvPVal, Duelist = DCGN_EdWinAttestDuelistChk, Emperor = DCGN_EdWinAttestEmperorChk,}
  u.DuelVal  = DCGN_EdWinAttestDuelValText
  u.RaidVal  = DCGN_EdWinAttestRaidValText
  u.bSave    = DCGN_EdWinButtonSave
  u.bCancel  = DCGN_EdWinButtonCancel
  u.ClearText= DCGN_EdWinNoteValText
--
--u.CB.Ambr  = ZO_ComboBox_ObjectFromContainer(u.Craft.Ambr)
--
  u.DD.CB_Val   = ZO_ComboBox_ObjectFromContainer(u.DD.Val)
  u.Heal.CB_Val = ZO_ComboBox_ObjectFromContainer(u.Heal.Val)
  u.Tank.CB_Val = ZO_ComboBox_ObjectFromContainer(u.Tank.Val)
  u.PvP.CB_Val  = ZO_ComboBox_ObjectFromContainer(u.PvP.Val)
  u.Solo.CB_MSA = ZO_ComboBox_ObjectFromContainer(u.Solo.MSA)
  u.Solo.CB_VH  = ZO_ComboBox_ObjectFromContainer(u.Solo.VH)
--
  self:UI_Ed_Init_TrialsL1(u.DD,   DCGN_EdWinAttestDD1)
  self:UI_Ed_Init_TrialsL1(u.Heal, DCGN_EdWinAttestHeal1)
  self:UI_Ed_Init_TrialsL1(u.Tank, DCGN_EdWinAttestTank1)
  self:UI_Ed_Init_TrialsL2(u.DD,   DCGN_EdWinAttestDD2)
  self:UI_Ed_Init_TrialsL2(u.Heal, DCGN_EdWinAttestHeal2)
  self:UI_Ed_Init_TrialsL2(u.Tank, DCGN_EdWinAttestTank2)
--
  self:InitCraftButton(u.Craft.Blk , Ic1.Blk , l.CraftTT.Blk )
  self:InitCraftButton(u.Craft.WWr , Ic1.WWr , l.CraftTT.WWr )
  self:InitCraftButton(u.Craft.Clt , Ic1.Clt , l.CraftTT.Clt )
  self:InitCraftButton(u.Craft.Ench, Ic1.Ench, l.CraftTT.Ench)
  self:InitCraftButton(u.Craft.Alch, Ic1.Alch, l.CraftTT.Alch)
  self:InitCraftButton(u.Craft.Jew , Ic1.Jew , l.CraftTT.Jew )
  self:InitCraftButton(u.Craft.Prov, Ic1.Prov, l.CraftTT.Prov)
--
  local arr = {}
  arr[1] = l.None
--for i = 1,3 do arr[i+1] = g.Ambr[i] end DBGN:InitCB(u.CB.Ambr,arr, 4)
  for i = 1,3 do arr[i+1] = g.MSA[i] end DBGN:InitCB(u.Solo.CB_MSA, arr, 4)
  for i = 1,3 do arr[i+1] = g.VH[i]  end DBGN:InitCB(u.Solo.CB_VH,  arr, 4)
  for i = 1,3 do arr[i+1] = g.DC_Rank[i] end
  DBGN:InitCB(u.DD.CB_Val,   arr, 4)
  DBGN:InitCB(u.Heal.CB_Val, arr, 4)
  DBGN:InitCB(u.Tank.CB_Val, arr, 4)
  for i = 1,5 do arr[i+1] = g.DC_PvP[i] end DBGN:InitCB(u.PvP.CB_Val,  arr, 6)

  ZO_KeybindButtonTemplate_Setup(u.bSave,   "DIALOG_PRIMARY",  self.ButtonSaveClik,   GetString(SI_SAVE))
  ZO_KeybindButtonTemplate_Setup(u.bCancel, "DIALOG_NEGATIVE", self.ButtonCancelClik, GetString(SI_CANCEL))
  u.bSave:SetKeybindEnabled(true)
  u.bCancel:SetKeybindEnabled(true)
end

--
-- Section 5.3: Initialize Filter UI
--
local function UI_Fl_OnTextChanged(control, u, f)
  local s = control:GetText()
  local r = false
  if control == u.DPSFrom then
    if s ~= f.DPSFrom then r, f.DPSFrom = true, s end
  elseif control == u.DPSTo then
    if s ~= f.DPSTo then r, f.DPSTo = true, s end
  elseif control == u.DuelFrom then
    if s ~= f.DuelFrom then r, f.DuelFrom = true, s end
  elseif control == u.DuelTo then
    if s ~= f.DuelTo then r, f.DuelTo = true, s end
  elseif control == u.RaidFrom then
    if s ~= f.RaidFrom then r, f.RaidFrom = true, s end
  elseif control == u.RaidTo then
    if s ~= f.RaidTo then r, f.RaidTo = true, s end
  end
  if r then DBGN:RefreshRosterFilters() end
end

local function UI_Fl_OnCBChanged(control, c, f, i)
  local r = false
-- Main flags
  if control == c.Discord then
    if i ~= f.Discord then r, f.Discord = true, i end
  elseif control == c.Vamp then
    if i ~= f.Vamp then r, f.Vamp = true, i end
  elseif control == c.WW then
    if i ~= f.WW then r, f.WW = true, i end
--  elseif control == c.House then
--    if i ~= f.House then r, f.House = true, i end
-- Trials
  elseif control == c.TrlDung then
    if i ~= f.TrlDung then r, f.TrlDung = true, i end
  elseif control == c.TrlCmp then
    if i ~= f.TrlCmp then r, f.TrlCmp = true, i end
  elseif control == c.TrlVal then
    if i ~= f.TrlVal then r, f.TrlVal = true, i end
-- Attestation
  elseif control == c.DDCmp then
    if i ~= f.DDCmp then r, f.DDCmp = true, i end
  elseif control == c.DDVal then
    if i ~= f.DDVal then r, f.DDVal = true, i end
  elseif control == c.HealCmp then
    if i ~= f.HealCmp then r, f.HealCmp = true, i end
  elseif control == c.HealVal then
    if i ~= f.HealVal then r, f.HealVal = true, i end
  elseif control == c.TankCmp then
    if i ~= f.TankCmp then r, f.TankCmp = true, i end
  elseif control == c.TankVal then
    if i ~= f.TankVal then r, f.TankVal = true, i end
-- Craft
  elseif control == c.BlkVal then
    if i ~= f.BlkVal then r, f.BlkVal = true, i end
  elseif control == c.WWrVal then
    if i ~= f.WWrVal then r, f.WWrVal = true, i end
  elseif control == c.CltVal then
    if i ~= f.CltVal then r, f.CltVal = true, i end
  elseif control == c.JewVal then
    if i ~= f.JewVal then r, f.JewVal = true, i end
  elseif control == c.EnchVal then
    if i ~= f.EnchVal then r, f.EnchVal = true, i end
  elseif control == c.AlchVal then
    if i ~= f.AlchVal then r, f.AlchVal = true, i end
  elseif control == c.ProvVal then
    if i ~= f.ProvVal then r, f.ProvVal = true, i end
  elseif control == c.AmbrVal then
    if i ~= f.AmbrVal then r, f.AmbrVal = true, i end
  end
  if r then DBGN:RefreshRosterFilters() end
end

function Guild:InitUI_Fl_CB(c, f, ctrl, arr, val, max)
--InitCB(control, array, cnt, val, func)
  DBGN:InitCB(ctrl, arr, max, val, function(control, i, v) UI_Fl_OnCBChanged(control, c, f, i) end)
end

function Guild:UI_Fl_WinMove()
  DBGN:MoveWinFilters(self.UI_Fl, DBGN.SV_DC.WinFilters, DBGN.SV_DC.WinFiltersSh, DBGN.SV_DC.WinFiltersPP)
end

function Guild:UI_Fl_Init()
  local u = self.UI_Fl
  local f = DBGN.SV_DC.Filters
  local arr = {}
--> DCGN_FlWin
  u.Win = CreateControlFromVirtual("DCGN_FlWin", ZO_GuildRoster, "DCGN_TmplFlWin")
  u.Win:SetHidden(true)
  DBGN:MoveWinFilters(u, DBGN.SV_DC.WinFilters, DBGN.SV_DC.WinFiltersSh, DBGN.SV_DC.WinFiltersPP)
  DCGN_FlWinTitle:SetText(l.FilterHdrDC)
--> DCGN_FlWin->Main
  DCGN_FlWinMainHdr:SetText(l.MainFlHdr)
  DCGN_FlWinMainDiscordTxt:SetText(l.Discord)
  DCGN_FlWinMainVampTxt:SetText(l.Vamp)
  DCGN_FlWinMainWWTxt:SetText(l.WW)
--DCGN_FlWinMainHouseTxt:SetText(l.House)
  u.Discord  = DCGN_FlWinMainDiscordVal
  u.Vamp     = DCGN_FlWinMainVampVal
  u.WW       = DCGN_FlWinMainWWVal
--u.House    = DCGN_FlWinMainHouseVal
  u.CB.Discord = ZO_ComboBox_ObjectFromContainer(u.Discord)
  u.CB.Vamp  = ZO_ComboBox_ObjectFromContainer(u.Vamp )
  u.CB.WW    = ZO_ComboBox_ObjectFromContainer(u.WW   )
--u.CB.House = ZO_ComboBox_ObjectFromContainer(u.House)
--> DCGN_FlWin->Craft
  DCGN_FlWinCraftHdr:SetText(l.CraftHdr)
  DCGN_FlWinCraftBlkIco:SetTexture(Ic1.Blk.On)
  DCGN_FlWinCraftWWrIco:SetTexture(Ic1.WWr.On)
  DCGN_FlWinCraftCltIco:SetTexture(Ic1.Clt.On)
  DCGN_FlWinCraftJewIco:SetTexture(Ic1.Jew.On)
  DCGN_FlWinCraftEnchIco:SetTexture(Ic1.Ench.On)
  DCGN_FlWinCraftAlchIco:SetTexture(Ic1.Alch.On)
  DCGN_FlWinCraftProvIco:SetTexture(Ic1.Prov.On)
--DCGN_FlWinCraftAmbrIco:SetTexture(Ic1.Ambr.On)
  u.BlkVal  = DCGN_FlWinCraftBlkVal
  u.WWrVal  = DCGN_FlWinCraftWWrVal
  u.CltVal  = DCGN_FlWinCraftCltVal
  u.JewVal  = DCGN_FlWinCraftJewVal
  u.EnchVal = DCGN_FlWinCraftEnchVal
  u.AlchVal = DCGN_FlWinCraftAlchVal
  u.ProvVal = DCGN_FlWinCraftProvVal
--u.AmbrVal = DCGN_FlWinCraftAmbrVal
  u.CB.BlkVal  = ZO_ComboBox_ObjectFromContainer(u.BlkVal)
  u.CB.WWrVal  = ZO_ComboBox_ObjectFromContainer(u.WWrVal)
  u.CB.CltVal  = ZO_ComboBox_ObjectFromContainer(u.CltVal)
  u.CB.JewVal  = ZO_ComboBox_ObjectFromContainer(u.JewVal)
  u.CB.EnchVal = ZO_ComboBox_ObjectFromContainer(u.EnchVal)
  u.CB.AlchVal = ZO_ComboBox_ObjectFromContainer(u.AlchVal)
  u.CB.ProvVal = ZO_ComboBox_ObjectFromContainer(u.ProvVal)
--u.CB.AmbrVal = ZO_ComboBox_ObjectFromContainer(u.AmbrVal)
--> DCGN_FlWin->Attest
  DCGN_FlWinAttestHdr:SetText(l.AttestHdr)
--
  DCGN_FlWinAttestDDTxt:SetText(l.DD)
  u.DDCmp = DCGN_FlWinAttestDDCmp
  u.DDVal = DCGN_FlWinAttestDDVal
  u.CB.DDCmp = ZO_ComboBox_ObjectFromContainer(u.DDCmp)
  u.CB.DDVal = ZO_ComboBox_ObjectFromContainer(u.DDVal)
--
  DCGN_FlWinAttestDPSTxt:SetText(l.DPS)
  u.DPSFrom   = DCGN_FlWinAttestDPSValFromText
  u.DPSTo     = DCGN_FlWinAttestDPSValToText
--
  DCGN_FlWinAttestHealTxt:SetText(l.Heal)
  u.HealCmp = DCGN_FlWinAttestHealCmp
  u.HealVal = DCGN_FlWinAttestHealVal
  u.CB.HealCmp = ZO_ComboBox_ObjectFromContainer(u.HealCmp)
  u.CB.HealVal = ZO_ComboBox_ObjectFromContainer(u.HealVal)
--
  DCGN_FlWinAttestTankTxt:SetText(l.Tank)
  u.TankCmp = DCGN_FlWinAttestTankCmp
  u.TankVal = DCGN_FlWinAttestTankVal
  u.CB.TankCmp = ZO_ComboBox_ObjectFromContainer(u.TankCmp)
  u.CB.TankVal = ZO_ComboBox_ObjectFromContainer(u.TankVal)
--
  DCGN_FlWinAttestPvPTxt:SetText(l.PvP)
  u.PvPCmp = DCGN_FlWinAttestPvPCmp
  u.PvPVal = DCGN_FlWinAttestPvPVal
  u.CB.PvPCmp = ZO_ComboBox_ObjectFromContainer(u.PvPCmp)
  u.CB.PvPVal = ZO_ComboBox_ObjectFromContainer(u.PvPVal)
--
  DCGN_FlWinAttestDuelTxt:SetText(l.Duel)
  u.DuelFrom   = DCGN_FlWinAttestDuelValFromText
  u.DuelTo     = DCGN_FlWinAttestDuelValToText
--
  DCGN_FlWinAttestRaidTxt:SetText(l.Raid)
  u.RaidFrom   = DCGN_FlWinAttestRaidValFromText
  u.RaidTo     = DCGN_FlWinAttestRaidValToText
--> DCGN_FlWin->Trials
  DCGN_FlWinTrialsHdr:SetText(l.TrialsHdr)
  DCGN_FlWinTrialsDDTxt:SetText(l.DD)
  DCGN_FlWinTrialsHealTxt:SetText(l.Heal)
  DCGN_FlWinTrialsTankTxt:SetText(l.Tank)
  u.TrlDD   = DCGN_FlWinTrialsDDChk
  u.TrlHeal = DCGN_FlWinTrialsHealChk
  u.TrlTank = DCGN_FlWinTrialsTankChk
  u.TrlDung = DCGN_FlWinTrialsDungSel
  u.TrlCmp  = DCGN_FlWinTrialsDungCmp
  u.TrlVal  = DCGN_FlWinTrialsDungVal
  u.CB.TrlDung = ZO_ComboBox_ObjectFromContainer(u.TrlDung)
  u.CB.TrlCmp  = ZO_ComboBox_ObjectFromContainer(u.TrlCmp )
  u.CB.TrlVal  = ZO_ComboBox_ObjectFromContainer(u.TrlVal )
--
  ZO_CheckButton_SetCheckState(u.TrlDD  , f.TrlDD  )
  ZO_CheckButton_SetCheckState(u.TrlHeal, f.TrlHeal)
  ZO_CheckButton_SetCheckState(u.TrlTank, f.TrlTank)
  ZO_CheckButton_SetToggleFunction(u.TrlDD  , function(control, checked) f.TrlDD   = checked; DBGN:RefreshRosterFilters() end)
  ZO_CheckButton_SetToggleFunction(u.TrlHeal, function(control, checked) f.TrlHeal = checked; DBGN:RefreshRosterFilters() end)
  ZO_CheckButton_SetToggleFunction(u.TrlTank, function(control, checked) f.TrlTank = checked; DBGN:RefreshRosterFilters() end)
--
  u.DPSFrom:SetText(f.DPSFrom)
  u.DPSTo:SetText(f.DPSTo)
  u.DPSFrom:SetHandler("OnTextChanged", function(control) UI_Fl_OnTextChanged(control, u, f) end)
  u.DPSTo:SetHandler("OnTextChanged", function(control) UI_Fl_OnTextChanged(control, u, f) end)
  u.DuelFrom:SetText(f.DuelFrom)
  u.DuelTo:SetText(f.DuelTo)
  u.DuelFrom:SetHandler("OnTextChanged", function(control) UI_Fl_OnTextChanged(control, u, f) end)
  u.DuelTo:SetHandler("OnTextChanged", function(control) UI_Fl_OnTextChanged(control, u, f) end)
  u.RaidFrom:SetText(f.RaidFrom)
  u.RaidTo:SetText(f.RaidTo)
  u.RaidFrom:SetHandler("OnTextChanged", function(control) UI_Fl_OnTextChanged(control, u, f) end)
  u.RaidTo:SetHandler("OnTextChanged", function(control) UI_Fl_OnTextChanged(control, u, f) end)
--Guild:InitUI_Fl_CB(c, f, ctrl, arr, val, max)
  self:InitUI_Fl_CB(u.CB, f, u.CB.Discord, g.AnyYesNo, f.Discord, 3)
  self:InitUI_Fl_CB(u.CB, f, u.CB.Vamp   , g.AnyYesNo, f.Vamp   , 3)
  self:InitUI_Fl_CB(u.CB, f, u.CB.WW     , g.AnyYesNo, f.WW     , 3)
--self:InitUI_Fl_CB(u.CB, f, u.CB.House  , g.AnyYesNo, f.House  , 3)
--
  self:InitUI_Fl_CB(u.CB, f, u.CB.TrlDung, g.TrlDung , f.TrlDung, #g.TrlDung)
  self:InitUI_Fl_CB(u.CB, f, u.CB.TrlVal , g.TrlVal  , f.TrlVal , 4)
  self:InitUI_Fl_CB(u.CB, f, u.CB.TrlCmp , g.Cmp     , f.TrlCmp , 4)
  self:InitUI_Fl_CB(u.CB, f, u.CB.DDCmp  , g.Cmp     , f.DDCmp  , 4)
  self:InitUI_Fl_CB(u.CB, f, u.CB.HealCmp, g.Cmp     , f.HealCmp, 4)
  self:InitUI_Fl_CB(u.CB, f, u.CB.TankCmp, g.Cmp     , f.TankCmp, 4)
--
  self:InitUI_Fl_CB(u.CB, f, u.CB.BlkVal , g.AnyYesNo, f.BlkVal , 3)
  self:InitUI_Fl_CB(u.CB, f, u.CB.WWrVal , g.AnyYesNo, f.WWrVal , 3)
  self:InitUI_Fl_CB(u.CB, f, u.CB.CltVal , g.AnyYesNo, f.CltVal , 3)
  self:InitUI_Fl_CB(u.CB, f, u.CB.JewVal , g.AnyYesNo, f.JewVal , 3)
  self:InitUI_Fl_CB(u.CB, f, u.CB.EnchVal, g.AnyYesNo, f.EnchVal, 3)
  self:InitUI_Fl_CB(u.CB, f, u.CB.AlchVal, g.AnyYesNo, f.AlchVal, 3)
  self:InitUI_Fl_CB(u.CB, f, u.CB.ProvVal, g.AnyYesNo, f.ProvVal, 3)
--  self:InitUI_Fl_CB(u.CB, f, u.CB.AmbrVal, g.AmbF, f.AmbrVal, 4)
--
  for i = 0,3 do arr[i+1] = g.DC_Rank[i] end
  self:InitUI_Fl_CB(u.CB, f, u.CB.DDVal,   arr, f.DVal, 4)
  self:InitUI_Fl_CB(u.CB, f, u.CB.HealVal, arr, f.HealVal, 4)
  self:InitUI_Fl_CB(u.CB, f, u.CB.TankVal, arr, f.TankVal, 4)
  for i = 0,5 do arr[i+1] = g.DC_PvP[i] end self:InitUI_Fl_CB(u.CB, f, u.CB.PvPVal , arr, f.PvPVal , 6)
end

--
-- Section 6: Update UI
-- Section 6.1: Update ToolTip UI
--
local function AddS(s)
  if s ~= "" then return s .. ", " end
  return ""
end

local function CreateTrialSt1(IndAA, IndSO, IndHRC, IndMoL, IndHoF, IndAS, IndCR, IndSS)
  local s = ""
  s = DBGN:AddTrialStr(IndAA,  g.AA,  s, CTrials.All)
  s = DBGN:AddTrialStr(IndSO,  g.SO,  s, CTrials.All)
  s = DBGN:AddTrialStr(IndHRC, g.HRC, s, CTrials.All)
  s = DBGN:AddTrialStr(IndMoL, g.MoL, s, CTrials.All)
  s = DBGN:AddTrialStr(IndHoF, g.HoF, s, CTrials.All)
  s = DBGN:AddTrialStr(IndAS,  g.AS,  s, CTrials.AS)
  s = DBGN:AddTrialStr(IndCR,  g.CR,  s, CTrials.CR)
  s = DBGN:AddTrialStr(IndSS,  g.SS,  s, CTrials.SS)
  return s
end

local function CreateTrialSt2(IndKA, IndRG, IndDSR, IndSE, IndLC, IndOC)
  local s = ""
  s = DBGN:AddTrialStr(IndKA,  g.KA,  s, CTrials.KA)
  s = DBGN:AddTrialStr(IndRG,  g.RG,  s, CTrials.RG)
  s = DBGN:AddTrialStr(IndDSR, g.DSR, s, CTrials.DSR)
  s = DBGN:AddTrialStr(IndSE,  g.SE,  s, CTrials.SE)
  s = DBGN:AddTrialStr(IndLC,  g.LC,  s, CTrials.LC)
  s = DBGN:AddTrialStr(IndOC,  g.OC,  s, CTrials.OC)
  return s
end

local function CreateTrialSt3(IndDSA, IndBRP)
  local s = ""
  s = DBGN:AddTrialStr(IndDSA, g.DSA, s, CTrials.All)
  s = DBGN:AddTrialStr(IndBRP, g.BRP, s, CTrials.All)
  return s
end

local function CreateSoloStr(IndMSA, IndVH)
  local s = ""
  s = DBGN:AddTrialStr(IndMSA, g.MSA, s, CTrials.All)
  s = DBGN:AddTrialStr(IndVH,  g.VH,  s, CTrials.All)
  return s
end

local function SetLabelTxt(control,fl,t1,t2)
  if type(fl) == "number" then
    control:SetText(t1 .. nvl(t2,""))
    control:SetColor(DBGN:GetColor(fl))
  elseif fl then
    control:SetText(t1 .. nvl(t2,""))
    control:SetColor(DBGN:GetColor(2))
  else
    control:SetText(t1)
    control:SetColor(DBGN:GetColor(1))
  end
end

function Guild:UI_TT_Upd()
  local u,e = self.UI_TT, self.EncTT
  local s,r = "",e.r
  u.Account:SetText(r.Name)
  u.Rank:SetText(GetFinalGuildRankName(r.guildId, r.rankIndex))
  u.RankIco:SetTexture(GetFinalGuildRankTextureSmall(r.guildId, r.rankIndex))
  if r.OnLine then
    u.OnLineIco:SetTexture(Ico.OnLine)
  else
    u.OnLineIco:SetTexture(Ico.OffLine)
  end
-->
  DBGN:LabelColor(r.Discord,u.FlDiscord)
  DBGN:LabelColor(r.Vamp,   u.FlVamp)
  DBGN:LabelColor(r.WW,     u.FlWW)
--DBGN:LabelColor(r.House,  u.FlHouse)
--> Craft
  SetTextureOnOff(u.CraftBlk , Ic1.Blk , r.CraftBlk )
  SetTextureOnOff(u.CraftWWr , Ic1.WWr , r.CraftWWr )
  SetTextureOnOff(u.CraftClt , Ic1.Clt , r.CraftClt )
  SetTextureOnOff(u.CraftEnch, Ic1.Ench, r.CraftEnch)
  SetTextureOnOff(u.CraftAlch, Ic1.Alch, r.CraftAlch)
  SetTextureOnOff(u.CraftJew , Ic1.Jew , r.CraftJew )
  SetTextureOnOff(u.CraftProv, Ic1.Prov, r.CraftProv)
--  SetTextureOnOff(u.CraftAmbr, Ic1.Ambr, r.CraftAmbr > 0)
--  if r.CraftAmbr > 0 then u.CraftAmbT:SetText(q.Ambr[r.CraftAmbr]) else u.CraftAmbT:SetText("") end
-->
  u.PvPVal:SetText(g.DC_PvP[r.PvP_Rank])
  DBGN:LabelColor(CPvP[r.PvP_Rank],u.PvPVal)
  s = ""
  if r.PvP_Duelist == true then s = l.Duelist end
  if r.PvP_Emperor == true then
    if s ~= "" then s = s .. ", " end
    s = s .. l.Emperor
  end
  u.PvPAdd:SetText(s)
-->
  if r.DPS == 0 then
    u.DPS:SetText("")
  else
    u.DPS:SetText(r.DPS)
    --DBGN:LabelColor((r.AttestDD>0), u.DPS)
  end
  u.DDVal:SetText(g.DC_Rank[r.AttestDD])
  DBGN:LabelColor(CTrials.All[r.AttestDD], u.DDVal)
  u.HealVal:SetText(g.DC_Rank[r.AttestHeal])
  DBGN:LabelColor(CTrials.All[r.AttestHeal], u.HealVal)
  u.TankVal:SetText(g.DC_Rank[r.AttestTank])
  DBGN:LabelColor(CTrials.All[r.AttestTank], u.TankVal)
--
  u.DDAdd:SetText(  CreateTrialSt1(r.DD_AA  ,r.DD_SO  ,r.DD_HRC  ,r.DD_MoL  ,r.DD_HoF  ,r.DD_AS  ,r.DD_CR  ,r.DD_SS  ))
  u.HealAdd:SetText(CreateTrialSt1(r.Heal_AA,r.Heal_SO,r.Heal_HRC,r.Heal_MoL,r.Heal_HoF,r.Heal_AS,r.Heal_CR,r.Heal_SS))
  u.TankAdd:SetText(CreateTrialSt1(r.Tank_AA,r.Tank_SO,r.Tank_HRC,r.Tank_MoL,r.Tank_HoF,r.Tank_AS,r.Tank_CR,r.Tank_SS))
  u.DDAd2:SetText(  CreateTrialSt2(r.DD_KA  ,r.DD_RG  ,r.DD_DSR  ,r.DD_SE  ,r.DD_LC  ,r.DD_OC  ))
  u.HealAd2:SetText(CreateTrialSt2(r.Heal_KA,r.Heal_RG,r.Heal_DSR,r.Heal_SE,r.Heal_LC,r.Heal_OC))
  u.TankAd2:SetText(CreateTrialSt2(r.Tank_KA,r.Tank_RG,r.Tank_DSR,r.Tank_SE,r.Tank_LC,r.Tank_OC))
  u.DDAd3:SetText(  CreateTrialSt2(r.DD_DSA  ,r.DD_BRP  ))
  u.HealAd3:SetText(CreateTrialSt2(r.Heal_DSA,r.Heal_BRP))
  u.TankAd3:SetText(CreateTrialSt2(r.Tank_DSA,r.Tank_BRP))
  u.SoloAdd:SetText(CreateSoloStr(r.Solo_MSA, r.Solo_VH))

  if r.PvP_Duel == nil or r.PvP_Duel == 0 then u.DuelVal:SetText("") else u.DuelVal:SetText(r.PvP_Duel) end
  if r.PvP_Raid == nil or r.PvP_Raid == 0 then u.RaidVal:SetText("") else u.RaidVal:SetText(r.PvP_Raid) end
-->
  if e.Error > 0 and DBGN.DecError[e.Error] ~= nil then
    u.Error:SetText(DBGN.DecError[e.Error])
  else
    u.Error:SetText("")
  end
  u.Note:SetText(e:GetStrClear())
end

--
-- Section 6.2: Update Edit UI
--
function Guild:UI_Ed_Upd()
  local u,e,r,x = self.UI_Ed,self.EncEd,self.EncEd.r,DBGN.Trial_Max
  u.Account:SetText(r.Name)
  u.Rank:SetText(GetFinalGuildRankName(r.guildId, r.rankIndex))
  u.RankIco:SetTexture(GetFinalGuildRankTextureSmall(r.guildId, r.rankIndex))
  if r.OnLine then
    u.OnLineIco:SetTexture(Ico.OnLine)
  else
    u.OnLineIco:SetTexture(Ico.OffLine)
  end
--
  ZO_CheckButton_SetCheckState(u.FlVamp , r.Vamp)
  ZO_CheckButton_SetCheckState(u.FlWW   , r.WW)
  ZO_CheckButton_SetCheckState(u.FlDiscord, r.Discord)
--ZO_CheckButton_SetCheckState(u.FlHouse, r.House)
--
  u.Craft.Blk:SetStatus(r.CraftBlk)
  u.Craft.WWr:SetStatus(r.CraftWWr)
  u.Craft.Clt:SetStatus(r.CraftClt)
  u.Craft.Ench:SetStatus(r.CraftEnch)
  u.Craft.Alch:SetStatus(r.CraftAlch)
  u.Craft.Jew:SetStatus(r.CraftJew)
  u.Craft.Prov:SetStatus(r.CraftProv)
--  DBGN:Set_CB_Val(u.CB.Ambr, r.CraftAmbr + 1, 1, 4, 1)
--
  DBGN:Set_CB_Val(u.Solo.CB_MSA, r.Solo_MSA + 1, 1, 4, 1)
  DBGN:Set_CB_Val(u.Solo.CB_VH,  r.Solo_VH  + 1, 1, 4, 1)
--
  if r.DPS == nil or r.DPS == 0 then u.DD.DPS:SetText("") else u.DD.DPS:SetText(r.DPS) end
  if r.PvP_Duel == nil or r.PvP_Duel == 0 then u.DuelVal:SetText("") else u.DuelVal:SetText(r.PvP_Duel) end
  if r.PvP_Raid == nil or r.PvP_Raid == 0 then u.RaidVal:SetText("") else u.RaidVal:SetText(r.PvP_Raid) end
  ZO_CheckButton_SetCheckState(u.PvP.Duelist, r.PvP_Duelist)
  ZO_CheckButton_SetCheckState(u.PvP.Emperor, r.PvP_Emperor)
  DBGN:Set_CB_Val(u.PvP.CB_Val, r.PvP_Rank + 1, 2, 6, 1)
--
  local b = u.DD
  DBGN:Set_CB_Val(b.CB_Val, r.AttestDD + 1, 2, 4, 1)
  DBGN:Set_CB_Val(b.CB_AA , r.DD_AA  + 1, 2, 4, 1)
  DBGN:Set_CB_Val(b.CB_SO , r.DD_SO  + 1, 2, 4, 1)
  DBGN:Set_CB_Val(b.CB_HRC, r.DD_HRC + 1, 2, 4, 1)
  DBGN:Set_CB_Val(b.CB_DSA, r.DD_DSA + 1, 2, 3, 1)
  DBGN:Set_CB_Val(b.CB_BRP, r.DD_BRP + 1, 2, 3, 1)
  DBGN:Set_CB_Val(b.CB_MoL, r.DD_MoL + 1, 2, x.MoL+1, 1)
  DBGN:Set_CB_Val(b.CB_HoF, r.DD_HoF + 1, 2, x.HoF+1, 1)
  DBGN:Set_CB_Val(b.CB_CR , r.DD_CR  + 1, 2, x.CR +1, 1)
  DBGN:Set_CB_Val(b.CB_AS , r.DD_AS  + 1, 2, x.AS +1, 1)
  DBGN:Set_CB_Val(b.CB_SS,  r.DD_SS  + 1, 2, x.SS +1, 1)
  DBGN:Set_CB_Val(b.CB_KA , r.DD_KA  + 1, 2, x.KA +1, 1)
  DBGN:Set_CB_Val(b.CB_RG , r.DD_RG  + 1, 2, x.RG +1, 1)
  DBGN:Set_CB_Val(b.CB_DSR, r.DD_DSR + 1, 2, x.DSR+1, 1)
  DBGN:Set_CB_Val(b.CB_SE,  r.DD_SE  + 1, 2, x.SE +1, 1)
  DBGN:Set_CB_Val(b.CB_LC,  r.DD_LC  + 1, 2, x.LC +1, 1)
  DBGN:Set_CB_Val(b.CB_OC,  r.DD_OC  + 1, 2, x.OC +1, 1)
--
  b = u.Heal
  DBGN:Set_CB_Val(b.CB_Val, r.AttestHeal + 1, 2, 4, 1)
  DBGN:Set_CB_Val(b.CB_AA , r.Heal_AA  + 1, 2, 4, 1)
  DBGN:Set_CB_Val(b.CB_SO , r.Heal_SO  + 1, 2, 4, 1)
  DBGN:Set_CB_Val(b.CB_HRC, r.Heal_HRC + 1, 2, 4, 1)
  DBGN:Set_CB_Val(b.CB_DSA, r.Heal_DSA + 1, 2, 3, 1)
  DBGN:Set_CB_Val(b.CB_BRP, r.Heal_BRP + 1, 2, 3, 1)
  DBGN:Set_CB_Val(b.CB_MoL, r.Heal_MoL + 1, 2, x.MoL+1, 1)
  DBGN:Set_CB_Val(b.CB_HoF, r.Heal_HoF + 1, 2, x.HoF+1, 1)
  DBGN:Set_CB_Val(b.CB_CR , r.Heal_CR  + 1, 2, x.CR +1, 1)
  DBGN:Set_CB_Val(b.CB_AS , r.Heal_AS  + 1, 2, x.AS +1, 1)
  DBGN:Set_CB_Val(b.CB_SS,  r.Heal_SS  + 1, 2, x.SS +1, 1)
  DBGN:Set_CB_Val(b.CB_KA , r.Heal_KA  + 1, 2, x.KA +1, 1)
  DBGN:Set_CB_Val(b.CB_RG , r.Heal_RG  + 1, 2, x.RG +1, 1)
  DBGN:Set_CB_Val(b.CB_DSR, r.Heal_DSR + 1, 2, x.DSR+1, 1)
  DBGN:Set_CB_Val(b.CB_SE,  r.Heal_SE  + 1, 2, x.SE +1, 1)
  DBGN:Set_CB_Val(b.CB_LC,  r.Heal_LC  + 1, 2, x.LC +1, 1)
  DBGN:Set_CB_Val(b.CB_OC,  r.Heal_OC  + 1, 2, x.OC +1, 1)
--
  b = u.Tank
  DBGN:Set_CB_Val(b.CB_Val, r.AttestTank + 1, 2, 4, 1)
  DBGN:Set_CB_Val(b.CB_AA , r.Tank_AA  + 1, 2, 4, 1)
  DBGN:Set_CB_Val(b.CB_SO , r.Tank_SO  + 1, 2, 4, 1)
  DBGN:Set_CB_Val(b.CB_HRC, r.Tank_HRC + 1, 2, 4, 1)
  DBGN:Set_CB_Val(b.CB_DSA, r.Tank_DSA + 1, 2, 3, 1)
  DBGN:Set_CB_Val(b.CB_BRP, r.Tank_BRP + 1, 2, 3, 1)
  DBGN:Set_CB_Val(b.CB_MoL, r.Tank_MoL + 1, 2, x.MoL+1, 1)
  DBGN:Set_CB_Val(b.CB_HoF, r.Tank_HoF + 1, 2, x.HoF+1, 1)
  DBGN:Set_CB_Val(b.CB_CR , r.Tank_CR  + 1, 2, x.CR +1, 1)
  DBGN:Set_CB_Val(b.CB_AS , r.Tank_AS  + 1, 2, x.AS +1, 1)
  DBGN:Set_CB_Val(b.CB_SS,  r.Tank_SS  + 1, 2, x.SS +1, 1)
  DBGN:Set_CB_Val(b.CB_KA , r.Tank_KA  + 1, 2, x.KA +1, 1)
  DBGN:Set_CB_Val(b.CB_RG , r.Tank_RG  + 1, 2, x.RG +1, 1)
  DBGN:Set_CB_Val(b.CB_DSR, r.Tank_DSR + 1, 2, x.DSR+1, 1)
  DBGN:Set_CB_Val(b.CB_SE,  r.Tank_SE  + 1, 2, x.SE +1, 1)
  DBGN:Set_CB_Val(b.CB_LC,  r.Tank_LC  + 1, 2, x.LC +1, 1)
  DBGN:Set_CB_Val(b.CB_OC,  r.Tank_OC  + 1, 2, x.OC +1, 1)
--
  u.ClearText:SetText(e:GetStrClear())
end

--
-- Section 7.1: Get values from Edit UI
--
function Guild:UI_Ed_GetVal()
  local u,r,x = self.UI_Ed,self.EncEd.r,DBGN.Trial_Max
  r.Discord = ZO_CheckButton_IsChecked(u.FlDiscord)
  r.Vamp    = ZO_CheckButton_IsChecked(u.FlVamp)
  r.WW      = ZO_CheckButton_IsChecked(u.FlWW)
--r.House   = ZO_CheckButton_IsChecked(u.FlHouse)
--
  r.CraftBlk  = u.Craft.Blk.Status
  r.CraftWWr  = u.Craft.WWr.Status
  r.CraftClt  = u.Craft.Clt.Status
  r.CraftEnch = u.Craft.Ench.Status
  r.CraftAlch = u.Craft.Alch.Status
  r.CraftJew  = u.Craft.Jew.Status
  r.CraftProv = u.Craft.Prov.Status
--r.CraftAmbr = DBGN:Get_CB_Val(u.CB.Ambr, 1, 4, 1) - 1
--
  r.PvP_Duel = DBGN:StrToNum(u.DuelVal:GetText(), 0, 4095, 0)
  r.PvP_Raid = DBGN:StrToNum(u.RaidVal:GetText(), 0, 4095, 0)
--
  local b = u.PvP
  r.PvP_Rank = DBGN:Get_CB_Val(b.CB_Val, 1, 6, 1) - 1
  r.PvP_Duelist = ZO_CheckButton_IsChecked(b.Duelist)
  r.PvP_Emperor = ZO_CheckButton_IsChecked(b.Emperor)
--
  b = u.Solo
  r.Solo_MSA = DBGN:Get_CB_Val(b.CB_MSA, 1, 4, 1) - 1
  r.Solo_VH  = DBGN:Get_CB_Val(b.CB_VH,  1, 4, 1) - 1
--
  b = u.DD
  r.DPS = DBGN:StrToNum(b.DPS:GetText(), 0, 262143, 0)
  r.AttestDD=DBGN:Get_CB_Val(b.CB_Val, 1, 4, 1) - 1
  r.DD_AA  = DBGN:Get_CB_Val(b.CB_AA,  1, 4, 1) - 1
  r.DD_SO  = DBGN:Get_CB_Val(b.CB_SO,  1, 4, 1) - 1
  r.DD_HRC = DBGN:Get_CB_Val(b.CB_HRC, 1, 4, 1) - 1
  r.DD_DSA = DBGN:Get_CB_Val(b.CB_DSA, 1, 3, 1) - 1
  r.DD_BRP = DBGN:Get_CB_Val(b.CB_BRP, 1, 3, 1) - 1
  r.DD_MoL = DBGN:Get_CB_Val(b.CB_MoL, 1, x.MoL+1, 1) - 1
  r.DD_HoF = DBGN:Get_CB_Val(b.CB_HoF, 1, x.HoF+1, 1) - 1
  r.DD_CR  = DBGN:Get_CB_Val(b.CB_CR,  1, x.CR +1, 1) - 1
  r.DD_AS  = DBGN:Get_CB_Val(b.CB_AS,  1, x.AS +1, 1) - 1
  r.DD_SS  = DBGN:Get_CB_Val(b.CB_SS,  1, x.SS +1, 1) - 1
  r.DD_KA  = DBGN:Get_CB_Val(b.CB_KA,  1, x.KA +1, 1) - 1
  r.DD_RG  = DBGN:Get_CB_Val(b.CB_RG,  1, x.RG +1, 1) - 1
  r.DD_DSR = DBGN:Get_CB_Val(b.CB_DSR, 1, x.DSR+1, 1) - 1
  r.DD_SE  = DBGN:Get_CB_Val(b.CB_SE,  1, x.SE +1, 1) - 1
  r.DD_LC  = DBGN:Get_CB_Val(b.CB_LC,  1, x.LC +1, 1) - 1
  r.DD_OC  = DBGN:Get_CB_Val(b.CB_OC,  1, x.OC +1, 1) - 1
--
  b = u.Heal
  r.AttestHeal=DBGN:Get_CB_Val(b.CB_Val, 1, 4, 1) - 1
  r.Heal_AA  = DBGN:Get_CB_Val(b.CB_AA,  1, 4, 1) - 1
  r.Heal_SO  = DBGN:Get_CB_Val(b.CB_SO,  1, 4, 1) - 1
  r.Heal_HRC = DBGN:Get_CB_Val(b.CB_HRC, 1, 4, 1) - 1
  r.Heal_DSA = DBGN:Get_CB_Val(b.CB_DSA, 1, 3, 1) - 1
  r.Heal_BRP = DBGN:Get_CB_Val(b.CB_BRP, 1, 3, 1) - 1
  r.Heal_MoL = DBGN:Get_CB_Val(b.CB_MoL, 1, x.MoL+1, 1) - 1
  r.Heal_HoF = DBGN:Get_CB_Val(b.CB_HoF, 1, x.HoF+1, 1) - 1
  r.Heal_CR  = DBGN:Get_CB_Val(b.CB_CR,  1, x.CR +1, 1) - 1
  r.Heal_AS  = DBGN:Get_CB_Val(b.CB_AS,  1, x.AS +1, 1) - 1
  r.Heal_SS  = DBGN:Get_CB_Val(b.CB_SS,  1, x.SS +1, 1) - 1
  r.Heal_KA  = DBGN:Get_CB_Val(b.CB_KA,  1, x.KA +1, 1) - 1
  r.Heal_RG  = DBGN:Get_CB_Val(b.CB_RG,  1, x.RG +1, 1) - 1
  r.Heal_DSR = DBGN:Get_CB_Val(b.CB_DSR, 1, x.DSR+1, 1) - 1
  r.Heal_SE  = DBGN:Get_CB_Val(b.CB_SE,  1, x.SE +1, 1) - 1
  r.Heal_LC  = DBGN:Get_CB_Val(b.CB_LC,  1, x.LC +1, 1) - 1
  r.Heal_OC  = DBGN:Get_CB_Val(b.CB_OC,  1, x.OC +1, 1) - 1
--
  b = u.Tank
  r.AttestTank=DBGN:Get_CB_Val(b.CB_Val, 1, 4, 1) - 1
  r.Tank_AA  = DBGN:Get_CB_Val(b.CB_AA,  1, 4, 1) - 1
  r.Tank_SO  = DBGN:Get_CB_Val(b.CB_SO,  1, 4, 1) - 1
  r.Tank_HRC = DBGN:Get_CB_Val(b.CB_HRC, 1, 4, 1) - 1
  r.Tank_DSA = DBGN:Get_CB_Val(b.CB_DSA, 1, 3, 1) - 1
  r.Tank_BRP = DBGN:Get_CB_Val(b.CB_BRP, 1, 3, 1) - 1
  r.Tank_MoL = DBGN:Get_CB_Val(b.CB_MoL, 1, x.MoL+1, 1) - 1
  r.Tank_HoF = DBGN:Get_CB_Val(b.CB_HoF, 1, x.HoF+1, 1) - 1
  r.Tank_CR  = DBGN:Get_CB_Val(b.CB_CR,  1, x.CR +1, 1) - 1
  r.Tank_AS  = DBGN:Get_CB_Val(b.CB_AS,  1, x.AS +1, 1) - 1
  r.Tank_SS  = DBGN:Get_CB_Val(b.CB_SS,  1, x.SS +1, 1) - 1
  r.Tank_KA  = DBGN:Get_CB_Val(b.CB_KA,  1, x.KA +1, 1) - 1
  r.Tank_RG  = DBGN:Get_CB_Val(b.CB_RG,  1, x.RG +1, 1) - 1
  r.Tank_DSR = DBGN:Get_CB_Val(b.CB_DSR, 1, x.DSR+1, 1) - 1
  r.Tank_SE  = DBGN:Get_CB_Val(b.CB_SE,  1, x.SE +1, 1) - 1
  r.Tank_LC  = DBGN:Get_CB_Val(b.CB_LC,  1, x.LC +1, 1) - 1
  r.Tank_OC  = DBGN:Get_CB_Val(b.CB_OC,  1, x.OC +1, 1) - 1
--
  r.ClearText = u.ClearText:GetText()
end

--
-- Section 8: UI Roster Filters
--
function Guild:UI_Fl_Check()
  local r,f=self.EncFl.r,DBGN.SV_DC.Filters
  local function check_yes_no(val, fltr)
    return fltr == 1 or (fltr == 2 and val) or (fltr == 3 and not val)
  end
  local function check_yes_no_n(val, fltr)
    return fltr == 1 or (fltr == 2 and val>0) or (fltr == 3 and val==0)
  end
  local function check_numb_eqv(val, fltr)
    return fltr == 1 or fltr == val+1
  end
  local function check_numb_min_max(val, fmin, fmax)
    if fmin ~= nil and fmin ~= "" and val < tonumber(fmin) then return false end
    if fmax ~= nil and fmax ~= "" and val > tonumber(fmax) then return false end
    return true
  end
  local function check_numb_cmp(val, fcmp, fval)
    if val ~= nil and fcmp > 1 then
      if     fcmp == 2 then return val+1 == fval
      elseif fcmp == 3 then return val+1 >= fval
      else                  return val+1 <= fval
      end
    end
    return true
  end
-- TrlDung: 1-AA, 2-SO, 3-HRC, 4-MoL, 5-HoF, 6-AS, 7-CR, 8-SS, 9-KA, 10-RG, 11-DSR, 12-SE, 13-LC, 14-OC, 15-DSA, 16-BRP, 17-MSA, 18-VH
  local tff = DBGN.Trial_for_filter
  local function get_dung_solo_val()
    if     f.TrlDung == 17 then return r.Solo_MSA
    elseif f.TrlDung == 18 then return r.Solo_VH
    end
    return nil
  end
  local function get_dung_dd_val()
    if     f.TrlDung == 1 then return r.DD_AA
    elseif f.TrlDung == 2 then return r.DD_SO
    elseif f.TrlDung == 3 then return r.DD_HRC
    elseif f.TrlDung == 4 then return r.DD_MoL
    elseif f.TrlDung == 5 then return r.DD_HoF
    elseif f.TrlDung == 6 then return tff.AS[r.DD_AS]
    elseif f.TrlDung == 7 then return tff.CR[r.DD_CR]
    elseif f.TrlDung == 8 then return tff.SS[r.DD_SS]
    elseif f.TrlDung == 9 then return tff.KA[r.DD_KA]
    elseif f.TrlDung ==10 then return tff.RG[r.DD_RG]
    elseif f.TrlDung ==11 then return tff.DSR[r.DD_DSR]
    elseif f.TrlDung ==12 then return tff.SE[r.DD_SE]
    elseif f.TrlDung ==13 then return tff.LC[r.DD_LC]
    elseif f.TrlDung ==14 then return tff.OC[r.DD_OC]
    elseif f.TrlDung ==15 then return r.DD_DSA
    elseif f.TrlDung ==16 then return r.DD_BRP
    end
    return nil
  end
  local function get_dung_heal_val()
    if     f.TrlDung == 1 then return r.Heal_AA
    elseif f.TrlDung == 2 then return r.Heal_SO
    elseif f.TrlDung == 3 then return r.Heal_HRC
    elseif f.TrlDung == 4 then return r.Heal_MoL
    elseif f.TrlDung == 5 then return r.Heal_HoF
    elseif f.TrlDung == 6 then return tff.AS[r.Heal_AS]
    elseif f.TrlDung == 7 then return tff.CR[r.Heal_CR]
    elseif f.TrlDung == 8 then return tff.SS[r.Heal_SS]
    elseif f.TrlDung == 9 then return tff.KA[r.Heal_KA]
    elseif f.TrlDung ==10 then return tff.RG[r.Heal_RG]
    elseif f.TrlDung ==11 then return tff.DSR[r.Heal_DSR]
    elseif f.TrlDung ==12 then return tff.SE[r.Heal_SE]
    elseif f.TrlDung ==13 then return tff.LC[r.Heal_LC]
    elseif f.TrlDung ==14 then return tff.OC[r.Heal_OC]
    elseif f.TrlDung ==15 then return r.Heal_DSA
    elseif f.TrlDung ==16 then return r.Heal_BRP
    end
    return nil
  end
  local function get_dung_tank_val()
    if     f.TrlDung == 1 then return r.Tank_AA
    elseif f.TrlDung == 2 then return r.Tank_SO
    elseif f.TrlDung == 3 then return r.Tank_HRC
    elseif f.TrlDung == 4 then return r.Tank_MoL
    elseif f.TrlDung == 5 then return r.Tank_HoF
    elseif f.TrlDung == 6 then return tff.AS[r.Tank_AS]
    elseif f.TrlDung == 7 then return tff.CR[r.Tank_CR]
    elseif f.TrlDung == 8 then return tff.SS[r.Tank_SS]
    elseif f.TrlDung == 9 then return tff.KA[r.Tank_KA]
    elseif f.TrlDung ==10 then return tff.RG[r.Tank_RG]
    elseif f.TrlDung ==11 then return tff.DSR[r.Tank_DSR]
    elseif f.TrlDung ==12 then return tff.SE[r.Tank_SE]
    elseif f.TrlDung ==13 then return tff.LC[r.Tank_LC]
    elseif f.TrlDung ==14 then return tff.OC[r.Tank_OC]
    elseif f.TrlDung ==15 then return r.Tank_DSA
    elseif f.TrlDung ==16 then return r.Tank_BRP
    end
    return nil
  end
--> d("Main Flags")
  if not check_yes_no(r.Discord, f.Discord) then return false end
  if not check_yes_no(r.Vamp , f.Vamp ) then return false end
  if not check_yes_no(r.WW   , f.WW   ) then return false end
--if not check_yes_no(r.House, f.House) then return false end
--> Attestation
  if not check_numb_min_max(r.DPS, f.DPSFrom, f.DPSTo) then return false end
  if not check_numb_min_max(r.PvP_Duel, f.DuelFrom, f.DuelTo) then return false end
  if not check_numb_min_max(r.PvP_Raid, f.RaidFrom, f.RaidTo) then return false end
  if not check_numb_cmp(r.AttestDD,   f.DDCmp,   f.DDVal)   then return false end
  if not check_numb_cmp(r.AttestHeal, f.HealCmp, f.HealVal) then return false end
  if not check_numb_cmp(r.AttestTank, f.TankCmp, f.TankVal) then return false end
  if not check_numb_cmp(r.PvP_Rank,   f.PvPCmp , f.PvPVal)  then return false end
--> d("Trials")
  if f.TrlCmp > 1 then
    if f.TrlDung >= 16 then
      if not check_numb_cmp(get_dung_solo_val(), f.TrlCmp, f.TrlVal) then return false end
    elseif not f.TrlDD and not f.TrlHeal and not f.TrlTank then
      if not (check_numb_cmp(get_dung_dd_val(), f.TrlCmp, f.TrlVal) or
              check_numb_cmp(get_dung_heal_val(), f.TrlCmp, f.TrlVal) or
              check_numb_cmp(get_dung_tank_val(), f.TrlCmp, f.TrlVal)
             )  then return false end
    else
      if f.TrlDD   and not check_numb_cmp(get_dung_dd_val(), f.TrlCmp, f.TrlVal)   then return false end
      if f.TrlHeal and not check_numb_cmp(get_dung_heal_val(), f.TrlCmp, f.TrlVal) then return false end
      if f.TrlTank and not check_numb_cmp(get_dung_tank_val(), f.TrlCmp, f.TrlVal) then return false end
    end
  end
--> d("Craft")
  if not check_yes_no(r.CraftBlk , f.BlkVal) then return false end
  if not check_yes_no(r.CraftWWr , f.WWrVal) then return false end
  if not check_yes_no(r.CraftClt , f.CltVal) then return false end
  if not check_yes_no(r.CraftJew , f.JewVal) then return false end
  if not check_yes_no(r.CraftEnch, f.EnchVal) then return false end
  if not check_yes_no(r.CraftAlch, f.AlchVal) then return false end
  if not check_yes_no(r.CraftProv, f.ProvVal) then return false end
--if not check_numb_eqv(r.CraftAmbr, f.AmbrVal) then return false end
  return true
end

--
-- Section 9: Get guild for regester
--
function DBGN.GetGuildDC()
  if Guild.Initialized == nil then
    Guild.EncTT = Guild:CreateEncDecEngine()
    Guild.EncEd = Guild:CreateEncDecEngine()
    Guild.EncFl = Guild:CreateEncDecEngine()
    Guild.EncEx = Guild:CreateEncDecEngine()
    Guild:UI_TT_Init()
    Guild:UI_Ed_Init()
    Guild:UI_Fl_Init()
    Guild.Initialized = true
  end
  return Guild
end