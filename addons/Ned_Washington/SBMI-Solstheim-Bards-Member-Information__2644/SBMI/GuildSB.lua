local SBMI = SBMI
local DBGN = DBGN
local Ic0  = SBMI.Icons
local Ic1  = DBGN.Icons
local l = SBMI.i18n
local m = DBGN.Markers
local g = DBGN.MarkersGr
local q = SBMI.MarkersGr
local CTrials = DBGN.Colors.Trials
local LPad = DBGN.LPad
local msg = DBGN.msg
local nvl = DBGN.nvl
--
-- Section 0: Guild Record
--
local Guild = {
  Code = "SBMI",
  Name = "Solstheim bards",
  Pref = "{SBMI",
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
  r.Forum = false
  r.Discord = false
  r.Vamp = false
  r.WW = false
  r.House = false
  r.Proff = false
  r.Melody = 0
  r.MelodyClc = 0
--
  r.CntBardSupr = 0
  r.CntBardImpt = 0
  r.BardImptD = 0
  r.BardImptM = 0
  r.VacationD = 0
  r.VacationM = 0
  r.KickD = 0
  r.KickM = 0
  r.Penalty = 0
  r.BustDiscord = 0
--
  r.CraftBlk = false
  r.CraftWWr = false
  r.CraftClt = false
  r.CraftEnch = false
  r.CraftAlch = false
  r.CraftJew = false
  r.CraftProv = false
  r.CraftAmbr = 0
--
  r.PvP_RL = false
  r.PvP_Stat = 0
  r.PvP_Emperor = false
  r.PvP_Rank = 0
--
  r.PvE_RL = false
  r.PvE_Stat = 0
  r.PvE_DD = false
  r.PvE_Heal = false
  r.PvE_Tank = false
  r.PvE_Spec = 0
  r.PvE_MSA = 0
  r.PvE_VH = 0
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
--
  if type(r.Dung) ~= "table" then r.Dung = {} end
  for i = 1, SBMI.DungCount do r.Dung[i] = 0 end
end

--
-- Section 2: Decode note
--
local function Max2n(a, b)
  if a > b then return a end
  return b
end

local function Max3n(a, b, c)
  if a > b then return Max2n(a, c) end
  return Max2n(b, c)
end

local function CalcPoints(a, z)
  local n = z[a]
  if n == nil then return 0 end
  return n
end

local function CalcMelody(r)
  local MC = SBMI.MelodyCosts
  local n =
    CalcPoints(Max3n(r.DD_DSA, r.Heal_DSA, r.Tank_DSA), MC.DSA) +
    CalcPoints(Max3n(r.DD_BRP, r.Heal_BRP, r.Tank_BRP), MC.BRP) +
    CalcPoints(Max3n(r.DD_AA,  r.Heal_AA,  r.Tank_AA), MC.Crag) +
    CalcPoints(Max3n(r.DD_SO,  r.Heal_SO,  r.Tank_SO), MC.Crag) +
    CalcPoints(Max3n(r.DD_HRC, r.Heal_HRC, r.Tank_HRC), MC.Crag) +
    CalcPoints(Max3n(r.DD_MoL, r.Heal_MoL, r.Tank_MoL), MC.MoL) +
    CalcPoints(Max3n(r.DD_HoF, r.Heal_HoF, r.Tank_HoF), MC.HoF) +
    CalcPoints(Max3n(r.DD_AS,  r.Heal_AS,  r.Tank_AS), MC.AS) +
    CalcPoints(Max3n(r.DD_CR,  r.Heal_CR,  r.Tank_CR), MC.CR) +
    CalcPoints(Max3n(r.DD_SS,  r.Heal_SS,  r.Tank_SS), MC.SS) +
    CalcPoints(Max3n(r.DD_KA,  r.Heal_KA,  r.Tank_KA), MC.KA) +
    CalcPoints(Max3n(r.DD_RG,  r.Heal_RG,  r.Tank_RG), MC.RG) +
    CalcPoints(Max3n(r.DD_DSR, r.Heal_DSR, r.Tank_DSR), MC.DSR) +
    CalcPoints(Max3n(r.DD_SE,  r.Heal_SE,  r.Tank_SE), MC.SE) +
    CalcPoints(Max3n(r.DD_LC,  r.Heal_LC,  r.Tank_LC), MC.LC) +
    CalcPoints(Max3n(r.DD_OC,  r.Heal_OC,  r.Tank_OC), MC.OC)

  for i = 1, SBMI.DungCount do
    if type(r.Dung[i]) == "number" and r.Dung[i] > 0 then
      n = n + CalcPoints(r.Dung[i], MC.Dng)
    end
  end
  return n
end

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
-- Add function to SBMI interface
SBMI.Chk_Trial_Max = Chk_Trial_Max


local function DecodeStrV0(self)
  local r, n, a, b = self.r, self.n, 0, 0
  r.Forum,  a = self:DecBool(n[1])
  r.Discord,a = self:DecBool(a)
  r.Vamp,   a = self:DecBool(a)
  r.WW,     a = self:DecBool(a)
  r.House,  a = self:DecBool(a)
  r.Proff = (a>0)
  b, a = self:DecNumb(n[4],4)
  r.Melody = b * 4096 + n[3] * 64 + n[2]
--
  r.CntBardSupr = n[5]
  r.CntBardImpt = n[6]
  if n[7]  < 1 or n[7]  > 31 then r.BardImptD = 0 else r.BardImptD = n[7] end
  if n[8]  < 1 or n[8]  > 12 then r.BardImptM = 0 else r.BardImptM = n[8] end
  if n[9]  < 1 or n[9]  > 31 then r.VacationD = 0 else r.VacationD = n[9] end
  if n[10] < 1 or n[10] > 12 then r.VacationM = 0 else r.VacationM = n[10] end
  if n[11] < 1 or n[11] > 31 then r.KickD = 0 else r.KickD = n[11] end
  if n[12] < 1 or n[12] > 12 then r.KickM = 0 else r.KickM = n[12] end
  r.Penalty,     a = self:DecNumb(n[13],8)
  r.BustDiscord, a = self:DecNumb(a,4)
--
  r.CraftBlk,  a = self:DecBool(n[14])
  r.CraftWWr,  a = self:DecBool(a)
  r.CraftClt,  a = self:DecBool(a)
  r.CraftEnch, a = self:DecBool(a)
  r.CraftAlch, a = self:DecBool(a)
  r.CraftJew,  a = self:DecBool(a)
  r.CraftProv, a = self:DecBool(n[15])
  r.CraftAmbr, a = self:DecNumb(a,4)
--
  r.PvP_RL,     a = self:DecBool(n[16])
  r.PvP_Stat,   a = self:DecNumb(a,4)
  r.PvP_Emperor,a = self:DecBool(a)
  r.PvP_Rank,   a = self:DecNumb(n[17],8)
--
  r.PvE_RL,     a = self:DecBool(n[18])
  r.PvE_Stat,   a = self:DecNumb(a,4)
  r.PvE_DD,     a = self:DecBool(a)
  r.PvE_Heal,   a = self:DecBool(a)
  r.PvE_Tank,   a = self:DecBool(a)
  r.PvE_Spec,   a = self:DecNumb(n[19],4)
  r.PvE_MSA,    a = self:DecNumb(a,4)
  r.PvE_VH,     a = self:DecNumb(a,4)
--
  r.AttestDD,   a = self:DecNumb(n[20],4)
  r.AttestHeal, a = self:DecNumb(a,4)
  r.AttestTank, a = self:DecNumb(a,4)
  r.DPS = n[23] * 4096 + n[22] * 64 + n[21]
--
  r.DD_AA,    a = self:DecNumb(n[24],4)
  r.DD_SO,    a = self:DecNumb(a,4)
  r.DD_HRC,   a = self:DecNumb(a,4)
  r.DD_DSA,   a = self:DecNumb(n[25],4)
  r.DD_HoF,   a = self:DecNumb(a,4)
  r.DD_MoL,   a = self:DecNumb(a,4)
  r.DD_BRP,   a = self:DecNumb(n[26],4)
  r.DD_RG,    a = self:DecNumb(a,8)
  r.DD_AS,    a = self:DecNumb(n[27],8)
  r.DD_CR,    a = self:DecNumb(a,8)
  r.DD_SS,    a = self:DecNumb(n[28],8)
  r.DD_KA,    a = self:DecNumb(a,8)
--
  r.Heal_AA,  a = self:DecNumb(n[29],4)
  r.Heal_SO,  a = self:DecNumb(a,4)
  r.Heal_HRC, a = self:DecNumb(a,4)
  r.Heal_DSA, a = self:DecNumb(n[30],4)
  r.Heal_HoF, a = self:DecNumb(a,4)
  r.Heal_MoL, a = self:DecNumb(a,4)
  r.Heal_BRP, a = self:DecNumb(n[31],4)
  r.Heal_RG,  a = self:DecNumb(a,8)
  r.Heal_AS,  a = self:DecNumb(n[32],8)
  r.Heal_CR,  a = self:DecNumb(a,8)
  r.Heal_SS,  a = self:DecNumb(n[33],8)
  r.Heal_KA,  a = self:DecNumb(a,8)
--
  r.Tank_AA,  a = self:DecNumb(n[34],4)
  r.Tank_SO,  a = self:DecNumb(a,4)
  r.Tank_HRC, a = self:DecNumb(a,4)
  r.Tank_DSA, a = self:DecNumb(n[35],4)
  r.Tank_HoF, a = self:DecNumb(a,4)
  r.Tank_MoL, a = self:DecNumb(a,4)
  r.Tank_BRP, a = self:DecNumb(n[36],4)
  r.Tank_RG,  a = self:DecNumb(a,8)
  r.Tank_AS,  a = self:DecNumb(n[37],8)
  r.Tank_CR,  a = self:DecNumb(a,8)
  r.Tank_SS,  a = self:DecNumb(n[38],8)
  r.Tank_KA,  a = self:DecNumb(a,8)
  Chk_Trial_Max(r)
--
  if type(r.Dung) ~= "table" then r.Dung = {} end
  r.Dung[1],  a = self:DecNumb(n[39],2)
  for i = 2, 6 do
    r.Dung[i],  a = self:DecNumb(a,2)
  end
  for i = 0, 3 do
    r.Dung[7+i*3],  a = self:DecNumb(n[40+i],4)
    r.Dung[8+i*3],  a = self:DecNumb(a,4)
    r.Dung[9+i*3],  a = self:DecNumb(a,4)
  end
--
  r.MelodyClc = r.Melody + CalcMelody(r)
end

local function DecodeStrV1(self)
  local r, n, a, b = self.r, self.n, 0, 0
  r.Forum,  a = self:DecBool(n[1])
  r.Discord,a = self:DecBool(a)
  r.Vamp,   a = self:DecBool(a)
  r.WW,     a = self:DecBool(a)
  r.House,  a = self:DecBool(a)
  r.Proff = (a>0)
  b, a = self:DecNumb(n[4],4)
  r.Melody = b * 4096 + n[3] * 64 + n[2]
--
  r.CntBardSupr = n[5]
  r.CntBardImpt = n[6]
  if n[7]  < 1 or n[7]  > 31 then r.BardImptD = 0 else r.BardImptD = n[7] end
  if n[8]  < 1 or n[8]  > 12 then r.BardImptM = 0 else r.BardImptM = n[8] end
  if n[9]  < 1 or n[9]  > 31 then r.VacationD = 0 else r.VacationD = n[9] end
  if n[10] < 1 or n[10] > 12 then r.VacationM = 0 else r.VacationM = n[10] end
  if n[11] < 1 or n[11] > 31 then r.KickD = 0 else r.KickD = n[11] end
  if n[12] < 1 or n[12] > 12 then r.KickM = 0 else r.KickM = n[12] end
  r.Penalty,     a = self:DecNumb(n[13],8)
  r.BustDiscord, a = self:DecNumb(a,4)
--
  r.CraftBlk,  a = self:DecBool(n[14])
  r.CraftWWr,  a = self:DecBool(a)
  r.CraftClt,  a = self:DecBool(a)
  r.CraftEnch, a = self:DecBool(a)
  r.CraftAlch, a = self:DecBool(a)
  r.CraftJew,  a = self:DecBool(a)
  r.CraftProv, a = self:DecBool(n[15])
  r.CraftAmbr, a = self:DecNumb(a,4)
--
  r.PvP_RL,     a = self:DecBool(n[16])
  r.PvP_Stat,   a = self:DecNumb(a,4)
  r.PvP_Emperor,a = self:DecBool(a)
  r.PvP_Rank,   a = self:DecNumb(n[17],8)
--
  r.PvE_RL,     a = self:DecBool(n[18])
  r.PvE_Stat,   a = self:DecNumb(a,4)
  r.PvE_DD,     a = self:DecBool(a)
  r.PvE_Heal,   a = self:DecBool(a)
  r.PvE_Tank,   a = self:DecBool(a)
  r.PvE_Spec,   a = self:DecNumb(n[19],4)
  r.PvE_MSA,    a = self:DecNumb(a,4)
  r.PvE_VH,     a = self:DecNumb(a,4)
--
  r.AttestDD,   a = self:DecNumb(n[20],4)
  r.AttestHeal, a = self:DecNumb(a,4)
  r.AttestTank, a = self:DecNumb(a,4)
  r.DPS = n[23] * 4096 + n[22] * 64 + n[21]
--
  r.DD_AA,    a = self:DecNumb(n[24],4)
  r.DD_SO,    a = self:DecNumb(a,4)
  r.DD_HRC,   a = self:DecNumb(a,4)
  r.DD_DSA,   a = self:DecNumb(n[25],4)
  r.DD_HoF,   a = self:DecNumb(a,4)
  r.DD_MoL,   a = self:DecNumb(a,4)
  r.DD_BRP,   a = self:DecNumb(n[26],4)
  _      ,    a = self:DecNumb(a,2)
  r.DD_SE,    a = self:DecNumb(a,8)
  r.DD_AS,    a = self:DecNumb(n[27],8)
  r.DD_CR,    a = self:DecNumb(a,8)
  r.DD_SS,    a = self:DecNumb(n[28],8)
  r.DD_KA,    a = self:DecNumb(a,8)
  r.DD_RG,    a = self:DecNumb(n[29],8)
  r.DD_DSR,   a = self:DecNumb(a,8)
--
  r.Heal_AA,  a = self:DecNumb(n[30],4)
  r.Heal_SO,  a = self:DecNumb(a,4)
  r.Heal_HRC, a = self:DecNumb(a,4)
  r.Heal_DSA, a = self:DecNumb(n[31],4)
  r.Heal_HoF, a = self:DecNumb(a,4)
  r.Heal_MoL, a = self:DecNumb(a,4)
  r.Heal_BRP, a = self:DecNumb(n[32],4)
  _        ,  a = self:DecNumb(a,2)
  r.Heal_SE,  a = self:DecNumb(a,8)
  r.Heal_AS,  a = self:DecNumb(n[33],8)
  r.Heal_CR,  a = self:DecNumb(a,8)
  r.Heal_SS,  a = self:DecNumb(n[34],8)
  r.Heal_KA,  a = self:DecNumb(a,8)
  r.Heal_RG,  a = self:DecNumb(n[35],8)
  r.Heal_DSR, a = self:DecNumb(a,8)
--
  r.Tank_AA,  a = self:DecNumb(n[36],4)
  r.Tank_SO,  a = self:DecNumb(a,4)
  r.Tank_HRC, a = self:DecNumb(a,4)
  r.Tank_DSA, a = self:DecNumb(n[37],4)
  r.Tank_HoF, a = self:DecNumb(a,4)
  r.Tank_MoL, a = self:DecNumb(a,4)
  r.Tank_BRP, a = self:DecNumb(n[38],4)
  _        ,  a = self:DecNumb(a,2)
  r.Tank_SE,  a = self:DecNumb(a,8)
  r.Tank_AS,  a = self:DecNumb(n[39],8)
  r.Tank_CR,  a = self:DecNumb(a,8)
  r.Tank_SS,  a = self:DecNumb(n[40],8)
  r.Tank_KA,  a = self:DecNumb(a,8)
  r.Tank_RG,  a = self:DecNumb(n[41],8)
  r.Tank_DSR, a = self:DecNumb(a,8)
  Chk_Trial_Max(r)
--
  if type(r.Dung) ~= "table" then r.Dung = {} end
  r.Dung[1],  a = self:DecNumb(n[42],2)
  for i = 2, 6 do
    r.Dung[i],  a = self:DecNumb(a,2)
  end
  for i = 0, 5 do
    r.Dung[7+i*3],  a = self:DecNumb(n[43+i],4)
    r.Dung[8+i*3],  a = self:DecNumb(a,4)
    r.Dung[9+i*3],  a = self:DecNumb(a,4)
  end
--
  r.MelodyClc = r.Melody + CalcMelody(r)
end

local function DecodeStrV2(self)
  local r, n, a, b = self.r, self.n, 0, 0
  r.Forum,  a = self:DecBool(n[1])
  r.Discord,a = self:DecBool(a)
  r.Vamp,   a = self:DecBool(a)
  r.WW,     a = self:DecBool(a)
  r.House,  a = self:DecBool(a)
  r.Proff = (a>0)
  b, a = self:DecNumb(n[4],4)
  r.Melody = b * 4096 + n[3] * 64 + n[2]
--
  r.CntBardSupr = n[5]
  r.CntBardImpt = n[6]
  if n[7]  < 1 or n[7]  > 31 then r.BardImptD = 0 else r.BardImptD = n[7] end
  if n[8]  < 1 or n[8]  > 12 then r.BardImptM = 0 else r.BardImptM = n[8] end
  if n[9]  < 1 or n[9]  > 31 then r.VacationD = 0 else r.VacationD = n[9] end
  if n[10] < 1 or n[10] > 12 then r.VacationM = 0 else r.VacationM = n[10] end
  if n[11] < 1 or n[11] > 31 then r.KickD = 0 else r.KickD = n[11] end
  if n[12] < 1 or n[12] > 12 then r.KickM = 0 else r.KickM = n[12] end
  r.Penalty,     a = self:DecNumb(n[13],8)
  r.BustDiscord, a = self:DecNumb(a,4)
--
  r.CraftBlk,  a = self:DecBool(n[14])
  r.CraftWWr,  a = self:DecBool(a)
  r.CraftClt,  a = self:DecBool(a)
  r.CraftEnch, a = self:DecBool(a)
  r.CraftAlch, a = self:DecBool(a)
  r.CraftJew,  a = self:DecBool(a)
  r.CraftProv, a = self:DecBool(n[15])
  r.CraftAmbr, a = self:DecNumb(a,4)
--
  r.PvP_RL,     a = self:DecBool(n[16])
  r.PvP_Stat,   a = self:DecNumb(a,4)
  r.PvP_Emperor,a = self:DecBool(a)
  r.PvP_Rank,   a = self:DecNumb(n[17],8)
--
  r.PvE_RL,     a = self:DecBool(n[18])
  r.PvE_Stat,   a = self:DecNumb(a,4)
  r.PvE_DD,     a = self:DecBool(a)
  r.PvE_Heal,   a = self:DecBool(a)
  r.PvE_Tank,   a = self:DecBool(a)
  r.PvE_Spec,   a = self:DecNumb(n[19],4)
  r.PvE_MSA,    a = self:DecNumb(a,4)
  r.PvE_VH,     a = self:DecNumb(a,4)
--
  r.AttestDD,   a = self:DecNumb(n[20],4)
  r.AttestHeal, a = self:DecNumb(a,4)
  r.AttestTank, a = self:DecNumb(a,4)
  r.DPS = n[23] * 4096 + n[22] * 64 + n[21]
--
  r.DD_AA,    a = self:DecNumb(n[24],4)
  r.DD_SO,    a = self:DecNumb(a,4)
  r.DD_HRC,   a = self:DecNumb(a,4)
  r.DD_DSA,   a = self:DecNumb(n[25],4)
  r.DD_BRP,   a = self:DecNumb(a,4)
--_      ,    a = self:DecNumb(a,4)
  r.DD_MoL,   a = self:DecNumb(n[26],8)
  r.DD_HoF,   a = self:DecNumb(a,8)
  r.DD_CR,    a = self:DecNumb(n[27],16)
--_      ,    a = self:DecNumb(a,4)
  r.DD_AS,    a = self:DecNumb(n[28],8)
  r.DD_SS,    a = self:DecNumb(a,8)
  r.DD_KA,    a = self:DecNumb(n[29],8)
  r.DD_RG,    a = self:DecNumb(a,8)
  r.DD_DSR,   a = self:DecNumb(n[30],8)
  r.DD_SE,    a = self:DecNumb(a,8)
  r.DD_LC,    a = self:DecNumb(n[31],8)
  r.DD_OC,    a = self:DecNumb(a,8)
--
  r.Heal_AA,  a = self:DecNumb(n[32],4)
  r.Heal_SO,  a = self:DecNumb(a,4)
  r.Heal_HRC, a = self:DecNumb(a,4)
  r.Heal_DSA, a = self:DecNumb(n[33],4)
  r.Heal_BRP, a = self:DecNumb(a,4)
--_        ,  a = self:DecNumb(a,4)
  r.Heal_MoL, a = self:DecNumb(n[34],8)
  r.Heal_HoF, a = self:DecNumb(a,8)
  r.Heal_CR,  a = self:DecNumb(n[35],16)
--_        ,  a = self:DecNumb(a,4)
  r.Heal_AS,  a = self:DecNumb(n[36],8)
  r.Heal_SS,  a = self:DecNumb(a,8)
  r.Heal_KA,  a = self:DecNumb(n[37],8)
  r.Heal_RG,  a = self:DecNumb(a,8)
  r.Heal_DSR, a = self:DecNumb(n[38],8)
  r.Heal_SE,  a = self:DecNumb(a,8)
  r.Heal_LC,  a = self:DecNumb(n[39],8)
  r.Heal_OC,  a = self:DecNumb(a,8)
--
  r.Tank_AA,    a = self:DecNumb(n[40],4)
  r.Tank_SO,    a = self:DecNumb(a,4)
  r.Tank_HRC,   a = self:DecNumb(a,4)
  r.Tank_DSA,   a = self:DecNumb(n[41],4)
  r.Tank_BRP,   a = self:DecNumb(a,4)
--_        ,    a = self:DecNumb(a,4)
  r.Tank_MoL,   a = self:DecNumb(n[42],8)
  r.Tank_HoF,   a = self:DecNumb(a,8)
  r.Tank_CR,    a = self:DecNumb(n[43],16)
--_        ,    a = self:DecNumb(a,4)
  r.Tank_AS,    a = self:DecNumb(n[44],8)
  r.Tank_SS,    a = self:DecNumb(a,8)
  r.Tank_KA,    a = self:DecNumb(n[45],8)
  r.Tank_RG,    a = self:DecNumb(a,8)
  r.Tank_DSR,   a = self:DecNumb(n[46],8)
  r.Tank_SE,    a = self:DecNumb(a,8)
  r.Tank_LC,    a = self:DecNumb(n[47],8)
  r.Tank_OC,    a = self:DecNumb(a,8)
  Chk_Trial_Max(r)
--
  if type(r.Dung) ~= "table" then r.Dung = {} end
  r.Dung[1],  a = self:DecNumb(n[48],2)
  for i = 2, 6 do
    r.Dung[i],  a = self:DecNumb(a,2)
  end
  for i = 0, 7 do
    r.Dung[7+i*3],  a = self:DecNumb(n[49+i],4)
    r.Dung[8+i*3],  a = self:DecNumb(a,4)
    r.Dung[9+i*3],  a = self:DecNumb(a,4)
  end
--
  r.MelodyClc = r.Melody + CalcMelody(r)
end

--
-- Section 3: Encode note
--
local function EncodeStr(self)
  self:ClearN()
  local r, n, a, b, x = self.r, self.n, 0, 0, DBGN.Trial_Max
  n[1] = self:EncBool(r.Forum,1) + self:EncBool(r.Discord,2) + self:EncBool(r.Vamp,4) + self:EncBool(r.WW,8) + self:EncBool(r.House,16) + self:EncBool(r.Proff,32)
  n[4],n[3],n[2] = self:EncN3V(r.Melody)
--n[4]=n[4]+Reserv
--
  n[5] = self:EncNumb(r.CntBardSupr,1,63)
  n[6] = self:EncNumb(r.CntBardImpt,1,63)
  n[7], n[8]  = self:EncDDMM(r.BardImptD,r.BardImptM)
  n[9], n[10] = self:EncDDMM(r.VacationD,r.VacationM)
  n[11],n[12] = self:EncDDMM(r.KickD,r.KickM)
  n[13] = self:EncNumb(r.Penalty,1,4) + self:EncNumb(r.BustDiscord,8,3)
--
  n[14] = self:EncBool(r.CraftBlk,1) + self:EncBool(r.CraftWWr,2) + self:EncBool(r.CraftClt,4) + self:EncBool(r.CraftEnch,8) + self:EncBool(r.CraftAlch,16) + self:EncBool(r.CraftJew,32)
  n[15] = self:EncBool(r.CraftProv,1) + self:EncNumb(r.CraftAmbr,2,3)
--
  n[16] = self:EncBool(r.PvP_RL,1) + self:EncNumb(r.PvP_Stat,2,3) + self:EncBool(r.PvP_Emperor,8)
  n[17] = self:EncNumb(r.PvP_Rank,1,7)
--
  n[18] = self:EncBool(r.PvE_RL,1) + self:EncNumb(r.PvE_Stat,2,3) + self:EncBool(r.PvE_DD,8) + self:EncBool(r.PvE_Heal,16) + self:EncBool(r.PvE_Tank,32)
  n[19] = self:EncNumb(r.PvE_Spec,1,3) + self:EncNumb(r.PvE_MSA,4,3) + self:EncNumb(r.PvE_VH,16,3)
--
  n[20] = self:EncNumb(r.AttestDD,1,3) + self:EncNumb(r.AttestHeal,4,3) + self:EncNumb(r.AttestTank,16,3)
  n[23],n[22],n[21] = self:EncN3V(r.DPS)
--
  n[24] = self:EncNumb(r.DD_AA,1,3) + self:EncNumb(r.DD_SO,4,3) + self:EncNumb(r.DD_HRC,16,3)
  n[25] = self:EncNumb(r.DD_DSA,1,3) + self:EncNumb(r.DD_BRP,4,3)
  n[26] = self:EncNumb(r.DD_MoL,1,x.MoL) + self:EncNumb(r.DD_HoF,8,x.HoF)
  n[27] = self:EncNumb(r.DD_CR,1,x.CR)
  n[28] = self:EncNumb(r.DD_AS,1,x.AS) + self:EncNumb(r.DD_SS,8,x.SS)
  n[29] = self:EncNumb(r.DD_KA,1,x.KA) + self:EncNumb(r.DD_RG,8,x.RG)
  n[30] = self:EncNumb(r.DD_DSR,1,x.DSR) + self:EncNumb(r.DD_SE,8,x.SE)
  n[31] = self:EncNumb(r.DD_LC,1,x.LC) + self:EncNumb(r.DD_OC,8,x.OC)
--
  n[32] = self:EncNumb(r.Heal_AA,1,3) + self:EncNumb(r.Heal_SO,4,3) + self:EncNumb(r.Heal_HRC,16,3)
  n[33] = self:EncNumb(r.Heal_DSA,1,3) + self:EncNumb(r.Heal_BRP,4,3)
  n[34] = self:EncNumb(r.Heal_MoL,1,x.MoL) + self:EncNumb(r.Heal_HoF,8,x.HoF)
  n[35] = self:EncNumb(r.Heal_CR,1,x.CR)
  n[36] = self:EncNumb(r.Heal_AS,1,x.AS) + self:EncNumb(r.Heal_SS,8,x.SS)
  n[37] = self:EncNumb(r.Heal_KA,1,x.KA) + self:EncNumb(r.Heal_RG,8,x.RG)
  n[38] = self:EncNumb(r.Heal_DSR,1,x.DSR) + self:EncNumb(r.Heal_SE,8,x.SE)
  n[39] = self:EncNumb(r.Heal_LC,1,x.LC) + self:EncNumb(r.Heal_OC,8,x.OC)
--
  n[40] = self:EncNumb(r.Tank_AA,1,3) + self:EncNumb(r.Tank_SO,4,3) + self:EncNumb(r.Tank_HRC,16,3)
  n[41] = self:EncNumb(r.Tank_DSA,1,3) + self:EncNumb(r.Tank_BRP,4,3)
  n[42] = self:EncNumb(r.Tank_MoL,1,x.MoL) + self:EncNumb(r.Tank_HoF,8,x.HoF)
  n[43] = self:EncNumb(r.Tank_CR,1,x.CR)
  n[44] = self:EncNumb(r.Tank_AS,1,x.AS) + self:EncNumb(r.Tank_SS,8,x.SS)
  n[45] = self:EncNumb(r.Tank_KA,1,x.KA) + self:EncNumb(r.Tank_RG,8,x.RG)
  n[46] = self:EncNumb(r.Tank_DSR,1,x.DSR) + self:EncNumb(r.Tank_SE,8,x.SE)
  n[47] = self:EncNumb(r.Tank_LC,1,x.LC) + self:EncNumb(r.Tank_OC,8,x.OC)
--
  local d = r.Dung
  n[48] = self:EncNumb(d[1],1,1) + self:EncNumb(d[2],2,1) + self:EncNumb(d[3],4,1) + self:EncNumb(d[4],8,1) + self:EncNumb(d[5],16,1) + self:EncNumb(d[6],32,1)
  for i = 0, 7 do
    n[49+i] = self:EncNumb(d[7+i*3],1,3) + self:EncNumb(d[8+i*3],4,3) + self:EncNumb(d[9+i*3],16,3)
  end
--  n[] = 0 -- RESERVED
--> Calc CRC
  n[57], n[58] = self:CalcCRC(56)
--
  local s = self.Pref .. self.EncArr[self.CurVers]
  for i = 1, 58 do s = s .. self.EncArr[n[i]] end
  self.CodeStr = s .. self.Suff
end

--
-- Section 4: Create encode/decode engine
--
function Guild:CreateEncDecEngine()
  local Enc = LibFLEncode(self.Pref, self.Suff, InitRec, EncodeStr, 254)
  local Vers = {
    [0] = {CodeStrLen = 52, CRCLen = 43, Decode = DecodeStrV0,},
    [1] = {CodeStrLen = 58, CRCLen = 49, Decode = DecodeStrV1,},
    [2] = {CodeStrLen = 65, CRCLen = 56, Decode = DecodeStrV2,},
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
  SBMI_TTWinVamp:SetText(l.Vamp)
  SBMI_TTWinWW:SetText(l.WW)
  SBMI_TTWinForum:SetText(l.Forum)
  SBMI_TTWinProff:SetText(l.Proff)
  SBMI_TTWinDiscord:SetText(l.Discord)
  SBMI_TTWinHouse:SetText(l.House)
  SBMI_TTWinStatusHdr:SetText(l.StatusHdr)
  SBMI_TTWinAttestHdr:SetText(l.AttestHdr)
  SBMI_TTWinPvPHdr:SetText(l.PvPHdr)
  SBMI_TTWinPvEHdr:SetText(l.PvEHdr)
  SBMI_TTWinCraftHdr:SetText(l.CraftHdr)
  SBMI_TTWinNoteHdr:SetText(l.NoteHdr)
  SBMI_TTWinDungHdr:SetText(l.DungHdr)
  SBMI_TTWinNoteHdr:SetDimensions(120, 24)
--
  local u = self.UI_TT
  u.Win       = SBMI_TTWin
  u.GuildIco  = SBMI_TTWinGuildIco
  u.OnLineIco = SBMI_TTWinOnLineIco
  u.Account   = SBMI_TTWinAccount
  u.RankIco   = SBMI_TTWinRankIco
  u.Rank      = SBMI_TTWinRank
  u.MelodyIco = SBMI_TTWinMelodyIco
  u.MelodyTxt = SBMI_TTWinMelodyTxt
  u.FlForum   = SBMI_TTWinForum
  u.FlProff   = SBMI_TTWinProff
  u.FlDiscord = SBMI_TTWinDiscord
  u.FlVamp    = SBMI_TTWinVamp
  u.FlWW      = SBMI_TTWinWW
  u.FlHouse   = SBMI_TTWinHouse
  u.Penalty   = SBMI_TTWinStatusPenalty
  u.BardImpt  = SBMI_TTWinStatusBardImpt
  u.Vacation  = SBMI_TTWinStatusVacation
  u.Kick      = SBMI_TTWinStatusKick
  u.BustDiscord = SBMI_TTWinStatusBustDiscord
  u.CntBardSupr = SBMI_TTWinStatusCntBardSupr
  u.CntBardImpt = SBMI_TTWinStatusCntBardImpt
  u.PvP_RL    = SBMI_TTWinPvPRL
  u.PvP_Stat  = SBMI_TTWinPvPStat
  u.PvP_Emperor = SBMI_TTWinPvPEmperor
  u.PvP_Rank  = SBMI_TTWinPvPRank
  u.PvE_RL    = SBMI_TTWinPvERL
  u.PvE_DD    = SBMI_TTWinPvEDD
  u.PvE_Heal  = SBMI_TTWinPvEHeal
  u.PvE_Tank  = SBMI_TTWinPvETank
  u.PvE_Spec  = SBMI_TTWinPvESpec
  u.PvE_Stat  = SBMI_TTWinPvEStat
  u.MSA       = SBMI_TTWinPvEMSA
  u.VH        = SBMI_TTWinPvEVH
  u.DDVal     = SBMI_TTWinAttestDDVal
  u.DDAdd     = SBMI_TTWinAttestDDAdd
  u.DDAd2     = SBMI_TTWinAttestDDAd2
  u.DDAd3     = SBMI_TTWinAttestDDAd3
  u.DDRT      = SBMI_TTWinAttestDDRT
  u.HealVal   = SBMI_TTWinAttestHealVal
  u.HealAdd   = SBMI_TTWinAttestHealAdd
  u.HealAd2   = SBMI_TTWinAttestHealAd2
  u.HealAd3   = SBMI_TTWinAttestHealAd3
  u.TankVal   = SBMI_TTWinAttestTankVal
  u.TankAdd   = SBMI_TTWinAttestTankAdd
  u.TankAd2   = SBMI_TTWinAttestTankAd2
  u.TankAd3   = SBMI_TTWinAttestTankAd3
  u.PvPVal    = SBMI_TTWinAttestPvPVal
  u.PvPAdd    = SBMI_TTWinAttestPvPAdd
  u.DuelVal   = SBMI_TTWinAttestDuelVal
  u.RaidVal   = SBMI_TTWinAttestRaidVal
  u.CraftBlk  = SBMI_TTWinCraftBlk
  u.CraftWWr  = SBMI_TTWinCraftWWr
  u.CraftClt  = SBMI_TTWinCraftClt
  u.CraftEnch = SBMI_TTWinCraftEnch
  u.CraftAlch = SBMI_TTWinCraftAlch
  u.CraftJew  = SBMI_TTWinCraftJew
  u.CraftProv = SBMI_TTWinCraftProv
  u.CraftAmbr = SBMI_TTWinCraftAmbr
  u.CraftAmbT = SBMI_TTWinCraftAmbrTxt
  u.Dung      = SBMI_TTWinDungTxt
  u.Note      = SBMI_TTWinNoteTxt
  u.Error     = SBMI_TTWinNoteError
--
  u.PvP_RL:SetText(l.RL)
  u.PvP_Emperor:SetText(l.Emperor)
  u.PvE_RL:SetText(l.RL)
  u.PvE_DD:SetText(l.DD)
  u.PvE_Heal:SetText(l.Heal)
  u.PvE_Tank:SetText(l.Tank)
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
  SBMI_EdWinTitle:SetText(l.EditTitle)
  SBMI_EdWinSAScrollChildMainFlHdr:SetText(l.MainFlHdr)
  SBMI_EdWinSAScrollChildMainFlForumTxt:SetText(l.Forum)
  SBMI_EdWinSAScrollChildMainFlProffTxt:SetText(l.Proff)
  SBMI_EdWinSAScrollChildMainFlDiscordTxt:SetText(l.Discord)
  SBMI_EdWinSAScrollChildMainFlVampTxt:SetText(l.Vamp)
  SBMI_EdWinSAScrollChildMainFlWWTxt:SetText(l.WW)
  SBMI_EdWinSAScrollChildMainFlHouseTxt:SetText(l.House)
  SBMI_EdWinSAScrollChildMainFlMelodyIco:SetTexture(Ic0.Melody.On)
--
  SBMI_EdWinSAScrollChildStatusHdr:SetText(l.StatusHdr)
  SBMI_EdWinSAScrollChildStatusBardImptTxt:SetText(l.BardImpt)
  SBMI_EdWinSAScrollChildStatusVacationTxt:SetText(l.Vacation)
  SBMI_EdWinSAScrollChildStatusKickTxt:SetText(l.Kick)
  SBMI_EdWinSAScrollChildStatusPenaltyTxt:SetText(l.Penalty)
  SBMI_EdWinSAScrollChildStatusBustDiscordTxt:SetText(l.BustDiscord)
  SBMI_EdWinSAScrollChildStatusCntBardSuprLbl:SetText(l.CntBardSupr)
  SBMI_EdWinSAScrollChildStatusCntBardImptLbl:SetText(l.CntBardImpt)
--
  SBMI_EdWinSAScrollChildCraftHdr:SetText(l.CraftHdr)
  SBMI_EdWinSAScrollChildCraftAmbrIco:SetTexture(Ic0.Ambr.On)
--
  SBMI_EdWinSAScrollChildPvPHdr:SetText(l.PvPHdr)
  SBMI_EdWinSAScrollChildPvPRLTxt:SetText(l.RL)
  SBMI_EdWinSAScrollChildPvPEmperorTxt:SetText(l.Emperor)
  SBMI_EdWinSAScrollChildPvPStatTxt:SetText(l.Stat)
  SBMI_EdWinSAScrollChildPvPRankTxt:SetText(l.Rank)
--
  SBMI_EdWinSAScrollChildPvEHdr:SetText(l.PvEHdr)
  SBMI_EdWinSAScrollChildPvERLTxt:SetText(l.RL)
  SBMI_EdWinSAScrollChildPvEStatTxt:SetText(l.Stat)
  SBMI_EdWinSAScrollChildPvEDDTxt:SetText(l.DD)
  SBMI_EdWinSAScrollChildPvEHealTxt:SetText(l.Heal)
  SBMI_EdWinSAScrollChildPvETankTxt:SetText(l.Tank)
  SBMI_EdWinSAScrollChildPvESpecTxt:SetText(l.Spec)
--
  SBMI_EdWinSAScrollChildAttestHdr:SetText(l.AttestHdr)
--
  SBMI_EdWinSAScrollChildNoteHdr:SetText(l.NoteHdr)
--
  SBMI_EdWinSAScrollChildDungHdr:SetText(l.DungHdr)


  local u = self.UI_Ed
  u.Win       = SBMI_EdWin
  u.OnLineIco = SBMI_EdWinOnLineIco
  u.Account   = SBMI_EdWinAccount
  u.RankIco   = SBMI_EdWinRankIco
  u.Rank      = SBMI_EdWinRank
  u.FlForum   = SBMI_EdWinSAScrollChildMainFlForumChk
  u.FlProff   = SBMI_EdWinSAScrollChildMainFlProffChk
  u.FlDiscord = SBMI_EdWinSAScrollChildMainFlDiscordChk
  u.FlVamp    = SBMI_EdWinSAScrollChildMainFlVampChk
  u.FlWW      = SBMI_EdWinSAScrollChildMainFlWWChk
  u.FlHouse   = SBMI_EdWinSAScrollChildMainFlHouseChk
  u.Melody    = SBMI_EdWinSAScrollChildMainFlMelodyText
  u.VacMM     = SBMI_EdWinSAScrollChildStatusVacationMM
  u.VacDD     = SBMI_EdWinSAScrollChildStatusVacationDD
  u.BrdMM     = SBMI_EdWinSAScrollChildStatusBardImptMM
  u.BrdDD     = SBMI_EdWinSAScrollChildStatusBardImptDD
  u.KicMM     = SBMI_EdWinSAScrollChildStatusKickMM
  u.KicDD     = SBMI_EdWinSAScrollChildStatusKickDD
  u.Pnlty     = SBMI_EdWinSAScrollChildStatusPenaltyVal
  u.BustD     = SBMI_EdWinSAScrollChildStatusBustDiscordVal
  u.CntBS     = SBMI_EdWinSAScrollChildStatusCntBardSuprText
  u.CntBI     = SBMI_EdWinSAScrollChildStatusCntBardImptText
  u.Craft = {
    Blk  = SBMI_EdWinSAScrollChildCraftBlk,
    WWr  = SBMI_EdWinSAScrollChildCraftWWr,
    Clt  = SBMI_EdWinSAScrollChildCraftClt,
    Ench = SBMI_EdWinSAScrollChildCraftEnch,
    Alch = SBMI_EdWinSAScrollChildCraftAlch,
    Jew  = SBMI_EdWinSAScrollChildCraftJew,
    Prov = SBMI_EdWinSAScrollChildCraftProv,
    Ambr = SBMI_EdWinSAScrollChildCraftAmbrVal,
  }
  u.PvP = {
    RL   = SBMI_EdWinSAScrollChildPvPRLChk,
    Empr = SBMI_EdWinSAScrollChildPvPEmperorChk,
    Stat = SBMI_EdWinSAScrollChildPvPStatVal,
    Rank = SBMI_EdWinSAScrollChildPvPRankVal,
  }
  u.PvE = {
    RL   = SBMI_EdWinSAScrollChildPvERLChk,
    Stat = SBMI_EdWinSAScrollChildPvEStatVal,
    DD   = SBMI_EdWinSAScrollChildPvEDDChk,
    Tank = SBMI_EdWinSAScrollChildPvETankChk,
    Heal = SBMI_EdWinSAScrollChildPvEHealChk,
    Spec = SBMI_EdWinSAScrollChildPvESpecVal,
    MSA  = SBMI_EdWinSAScrollChildPvEMSAVal,
    VH   = SBMI_EdWinSAScrollChildPvEVHVal,
  }
  u.DD       = {Val = SBMI_EdWinSAScrollChildAttestDDVal, DPS = SBMI_EdWinSAScrollChildAttestDPSText,}
  u.Heal     = {Val = SBMI_EdWinSAScrollChildAttestHealVal,}
  u.Tank     = {Val = SBMI_EdWinSAScrollChildAttestTankVal,}
  u.bSave    = SBMI_EdWinButtonSave
  u.bCancel  = SBMI_EdWinButtonCancel
  u.ClearText= SBMI_EdWinSAScrollChildNoteValText
  u.Dung = {
    Win = SBMI_EdWinSAScrollChildDung,
    Chk = {},
    Val = {},
    CB  = {},
  }
  for i = 1,6 do
    local dg = GetControl(u.Dung.Win, tostring(i))
    GetControl(dg, "Txt"):SetText(l.Dungeons[i].S)
    u.Dung.Chk[i] = GetControl(dg, "Chk")
  end
  for i = 7,SBMI.DungCount do
    local dg = GetControl(u.Dung.Win, tostring(i))
    GetControl(dg, "Txt"):SetText(l.Dungeons[i].S)
    u.Dung.Val[i] = GetControl(dg, "Val")
    u.Dung.CB[i] = ZO_ComboBox_ObjectFromContainer(u.Dung.Val[i])
  end
--
  u.CB.VacMM = ZO_ComboBox_ObjectFromContainer(u.VacMM)
  u.CB.VacDD = ZO_ComboBox_ObjectFromContainer(u.VacDD)
  u.CB.BrdMM = ZO_ComboBox_ObjectFromContainer(u.BrdMM)
  u.CB.BrdDD = ZO_ComboBox_ObjectFromContainer(u.BrdDD)
  u.CB.KicMM = ZO_ComboBox_ObjectFromContainer(u.KicMM)
  u.CB.KicDD = ZO_ComboBox_ObjectFromContainer(u.KicDD)
  u.CB.Pnlty = ZO_ComboBox_ObjectFromContainer(u.Pnlty)
  u.CB.BustD = ZO_ComboBox_ObjectFromContainer(u.BustD)
  u.CB.Ambr  = ZO_ComboBox_ObjectFromContainer(u.Craft.Ambr)
  u.CB.PvPStat = ZO_ComboBox_ObjectFromContainer(u.PvP.Stat)
  u.CB.PvPRank = ZO_ComboBox_ObjectFromContainer(u.PvP.Rank)
  u.CB.PvEStat = ZO_ComboBox_ObjectFromContainer(u.PvE.Stat)
  u.CB.PvESpec = ZO_ComboBox_ObjectFromContainer(u.PvE.Spec)
  u.CB.PvEMSA  = ZO_ComboBox_ObjectFromContainer(u.PvE.MSA)
  u.CB.PvEVH   = ZO_ComboBox_ObjectFromContainer(u.PvE.VH)
--
  u.DD.CB_Val = ZO_ComboBox_ObjectFromContainer(u.DD.Val)
  u.Heal.CB_Val = ZO_ComboBox_ObjectFromContainer(u.Heal.Val)
  u.Tank.CB_Val = ZO_ComboBox_ObjectFromContainer(u.Tank.Val)
--
  self:UI_Ed_Init_TrialsL1(u.DD,   SBMI_EdWinSAScrollChildAttestDD1)
  self:UI_Ed_Init_TrialsL1(u.Heal, SBMI_EdWinSAScrollChildAttestHeal1)
  self:UI_Ed_Init_TrialsL1(u.Tank, SBMI_EdWinSAScrollChildAttestTank1)
  self:UI_Ed_Init_TrialsL2(u.DD,   SBMI_EdWinSAScrollChildAttestDD2)
  self:UI_Ed_Init_TrialsL2(u.Heal, SBMI_EdWinSAScrollChildAttestHeal2)
  self:UI_Ed_Init_TrialsL2(u.Tank, SBMI_EdWinSAScrollChildAttestTank2)
--
  self:InitCraftButton(u.Craft.Blk , Ic0.Blk , l.CraftTT.Blk )
  self:InitCraftButton(u.Craft.WWr , Ic0.WWr , l.CraftTT.WWr )
  self:InitCraftButton(u.Craft.Clt , Ic0.Clt , l.CraftTT.Clt )
  self:InitCraftButton(u.Craft.Ench, Ic0.Ench, l.CraftTT.Ench)
  self:InitCraftButton(u.Craft.Alch, Ic0.Alch, l.CraftTT.Alch)
  self:InitCraftButton(u.Craft.Jew , Ic0.Jew , l.CraftTT.Jew )
  self:InitCraftButton(u.Craft.Prov, Ic0.Prov, l.CraftTT.Prov)
--
  local arr = {}
  arr[1] = l.None
  for i = 1,2 do arr[i+1] = q.DgQv[i] end for i = 7,SBMI.DungCount do DBGN:InitCB(u.Dung.CB[i],arr, 3) end
  for i = 1,3 do arr[i+1] = q.Ambr[i] end DBGN:InitCB(u.CB.Ambr,arr, 4)
  for i = 1,2 do arr[i+1] = q.Stat[i] end DBGN:InitCB(u.CB.PvPStat,arr, 3) DBGN:InitCB(u.CB.PvEStat,arr, 3)
  for i = 1,7 do arr[i+1] = q.PvPR[i] end DBGN:InitCB(u.CB.PvPRank,arr, 8)
  for i = 1,3 do arr[i+1] = q.PvES[i] end DBGN:InitCB(u.CB.PvESpec,arr, 4)
  for i = 1,3 do arr[i+1] = g.MSA[i]  end DBGN:InitCB(u.CB.PvEMSA, arr, 4)
  for i = 1,3 do arr[i+1] = g.VH[i]   end DBGN:InitCB(u.CB.PvEVH,  arr, 4)
  for i = 1,3 do arr[i+1] = q.DD[i]   end DBGN:InitCB(u.DD.CB_Val, arr, 4)
  for i = 1,3 do arr[i+1] = g.Heal[i] end DBGN:InitCB(u.Heal.CB_Val, arr, 4)
  for i = 1,3 do arr[i+1] = g.Tank[i] end DBGN:InitCB(u.Tank.CB_Val, arr, 4)

  for i = 1,3 do arr[i] = tostring(i) end
  arr[4] = " "
  DBGN:InitCB(u.CB.BustD, arr, 4)
  arr[4] = "4"
  arr[5] = " "
  DBGN:InitCB(u.CB.Pnlty, arr, 5)
  for i = 5,12 do arr[i] = tostring(i) end
  arr[13] = " "
  DBGN:InitCB(u.CB.VacMM, arr, 13)
  DBGN:InitCB(u.CB.BrdMM, arr, 13)
  DBGN:InitCB(u.CB.KicMM, arr, 13)
  for i = 13,31 do arr[i] = tostring(i) end
  arr[32] = " "
  DBGN:InitCB(u.CB.VacDD, arr, 32)
  DBGN:InitCB(u.CB.BrdDD, arr, 32)
  DBGN:InitCB(u.CB.KicDD, arr, 32)
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
  if control == u.DDFrom then
    if s ~= f.DDFrom then r, f.DDFrom = true, s end
  elseif control == u.DDTo then
    if s ~= f.DDTo then r, f.DDTo = true, s end
  elseif control == u.M1From then
    if s ~= f.M1From then r, f.M1From = true, s end
  elseif control == u.M1To then
    if s ~= f.M1To then r, f.M1To = true, s end
  elseif control == u.M2From then
    if s ~= f.M2From then r, f.M2From = true, s end
  elseif control == u.M2To then
    if s ~= f.M2To then r, f.M2To = true, s end
  end
  if r then DBGN:RefreshRosterFilters() end
end

local function UI_Fl_OnCBChanged(control, c, f, i)
  local r = false
-- Main flags
  if control == c.Forum then
    if i ~= f.Forum then r, f.Forum = true, i end
  elseif control == c.Proff then
    if i ~= f.Proff then r, f.Proff = true, i end
  elseif control == c.Discord then
    if i ~= f.Discord then r, f.Discord = true, i end
  elseif control == c.Vamp then
    if i ~= f.Vamp then r, f.Vamp = true, i end
  elseif control == c.WW then
    if i ~= f.WW then r, f.WW = true, i end
  elseif control == c.House then
    if i ~= f.House then r, f.House = true, i end
-- Status
  elseif control == c.PenaltyCmp then
    if i ~= f.PenaltyCmp then r, f.PenaltyCmp = true, i end
  elseif control == c.PenaltyVal then
    if i ~= f.PenaltyVal then r, f.PenaltyVal = true, i end
-- PvE
  elseif control == c.PvE_RL then
    if i ~= f.PvE_RL then r, f.PvE_RL = true, i end
  elseif control == c.PvE_DD then
    if i ~= f.PvE_DD then r, f.PvE_DD = true, i end
  elseif control == c.PvE_Heal then
    if i ~= f.PvE_Heal then r, f.PvE_Heal = true, i end
  elseif control == c.PvE_Tank then
    if i ~= f.PvE_Tank then r, f.PvE_Tank = true, i end
  elseif control == c.PvE_Stat then
    if i ~= f.PvE_Stat then r, f.PvE_Stat = true, i end
-- Trials
  elseif control == c.TrlDung then
    if i ~= f.TrlDung then r, f.TrlDung = true, i end
  elseif control == c.TrlCmp then
    if i ~= f.TrlCmp then r, f.TrlCmp = true, i end
  elseif control == c.TrlVal then
    if i ~= f.TrlVal then r, f.TrlVal = true, i end
-- Dungeons
  elseif control == c.DungSel then
    if i ~= f.DungSel then r, f.DungSel = true, i end
  elseif control == c.DungCmp then
    if i ~= f.DungCmp then r, f.DungCmp = true, i end
  elseif control == c.DungVal then
    if i ~= f.DungVal then r, f.DungVal = true, i end
-- Attestation
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
  DBGN:MoveWinFilters(self.UI_Fl, SBMI.SV.WinFilters, SBMI.SV.WinFiltersSh, SBMI.SV.WinFiltersPP)
end

function Guild:UI_Fl_Init()
  local u = self.UI_Fl
  local f = SBMI.SV.Filters
  local arr = {}
--> SBMI_FlWin
  u.Win = CreateControlFromVirtual("SBMI_FlWin", ZO_GuildRoster, "SBMI_TmplFlWin")
  u.Win:SetHidden(true)
  DBGN:MoveWinFilters(u, SBMI.SV.WinFilters, SBMI.SV.WinFiltersSh, SBMI.SV.WinFiltersPP)
  SBMI_FlWinTitle:SetText(l.FilterHdr)
--> SBMI_FlWinSAScrollChild->Main
  SBMI_FlWinSAScrollChildMainHdr:SetText(l.MainFlHdr)
  SBMI_FlWinSAScrollChildMainForumTxt:SetText(l.Forum)
  SBMI_FlWinSAScrollChildMainProffTxt:SetText(l.Proff)
  SBMI_FlWinSAScrollChildMainDiscordTxt:SetText(l.Discord)
  SBMI_FlWinSAScrollChildMainVampTxt:SetText(l.Vamp)
  SBMI_FlWinSAScrollChildMainWWTxt:SetText(l.WW)
  SBMI_FlWinSAScrollChildMainHouseTxt:SetText(l.House)
  u.Forum    = SBMI_FlWinSAScrollChildMainForumVal
  u.Proff    = SBMI_FlWinSAScrollChildMainProffVal
  u.Discord  = SBMI_FlWinSAScrollChildMainDiscordVal
  u.Vamp     = SBMI_FlWinSAScrollChildMainVampVal
  u.WW       = SBMI_FlWinSAScrollChildMainWWVal
  u.House    = SBMI_FlWinSAScrollChildMainHouseVal
  u.CB.Forum = ZO_ComboBox_ObjectFromContainer(u.Forum)
  u.CB.Proff = ZO_ComboBox_ObjectFromContainer(u.Proff)
  u.CB.Discord = ZO_ComboBox_ObjectFromContainer(u.Discord)
  u.CB.Vamp  = ZO_ComboBox_ObjectFromContainer(u.Vamp )
  u.CB.WW    = ZO_ComboBox_ObjectFromContainer(u.WW   )
  u.CB.House = ZO_ComboBox_ObjectFromContainer(u.House)
--> SBMI_FlWinSAScrollChild->Status
  SBMI_FlWinSAScrollChildStatusHdr:SetText(l.StatusHdr)
  SBMI_FlWinSAScrollChildStatusM1Ico:SetTexture(Ic0.Melody.On)
  SBMI_FlWinSAScrollChildStatusM2Ico:SetTexture(Ic0.Melody.Off)
  u.M1From     = SBMI_FlWinSAScrollChildStatusM1FromText
  u.M1To       = SBMI_FlWinSAScrollChildStatusM1ToText
  u.M2From     = SBMI_FlWinSAScrollChildStatusM2FromText
  u.M2To       = SBMI_FlWinSAScrollChildStatusM2ToText
  u.PenaltyCmp = SBMI_FlWinSAScrollChildStatusPenaltyCmp
  u.PenaltyVal = SBMI_FlWinSAScrollChildStatusPenaltyVal
  SBMI_FlWinSAScrollChildStatusPenaltyTxt:SetText(l.Penalty)
  u.M1From:SetText(f.M1From)
  u.M1To:SetText(f.M1To)
  u.M2From:SetText(f.M2From)
  u.M2To:SetText(f.M2To)
  u.M1From:SetHandler("OnTextChanged", function(control) UI_Fl_OnTextChanged(control, u, f) end)
  u.M1To:SetHandler("OnTextChanged", function(control) UI_Fl_OnTextChanged(control, u, f) end)
  u.M2From:SetHandler("OnTextChanged", function(control) UI_Fl_OnTextChanged(control, u, f) end)
  u.M2To:SetHandler("OnTextChanged", function(control) UI_Fl_OnTextChanged(control, u, f) end)
  u.CB.PenaltyCmp = ZO_ComboBox_ObjectFromContainer(u.PenaltyCmp)
  u.CB.PenaltyVal = ZO_ComboBox_ObjectFromContainer(u.PenaltyVal)
--> SBMI_FlWinSAScrollChild->Craft
  SBMI_FlWinSAScrollChildCraftHdr:SetText(l.CraftHdr)
  SBMI_FlWinSAScrollChildCraftBlkIco:SetTexture(Ic0.Blk.On)
  SBMI_FlWinSAScrollChildCraftWWrIco:SetTexture(Ic0.WWr.On)
  SBMI_FlWinSAScrollChildCraftCltIco:SetTexture(Ic0.Clt.On)
  SBMI_FlWinSAScrollChildCraftJewIco:SetTexture(Ic0.Jew.On)
  SBMI_FlWinSAScrollChildCraftEnchIco:SetTexture(Ic0.Ench.On)
  SBMI_FlWinSAScrollChildCraftAlchIco:SetTexture(Ic0.Alch.On)
  SBMI_FlWinSAScrollChildCraftProvIco:SetTexture(Ic0.Prov.On)
  SBMI_FlWinSAScrollChildCraftAmbrIco:SetTexture(Ic0.Ambr.On)
  u.BlkVal  = SBMI_FlWinSAScrollChildCraftBlkVal
  u.WWrVal  = SBMI_FlWinSAScrollChildCraftWWrVal
  u.CltVal  = SBMI_FlWinSAScrollChildCraftCltVal
  u.JewVal  = SBMI_FlWinSAScrollChildCraftJewVal
  u.EnchVal = SBMI_FlWinSAScrollChildCraftEnchVal
  u.AlchVal = SBMI_FlWinSAScrollChildCraftAlchVal
  u.ProvVal = SBMI_FlWinSAScrollChildCraftProvVal
  u.AmbrVal = SBMI_FlWinSAScrollChildCraftAmbrVal
  u.CB.BlkVal  = ZO_ComboBox_ObjectFromContainer(u.BlkVal)
  u.CB.WWrVal  = ZO_ComboBox_ObjectFromContainer(u.WWrVal)
  u.CB.CltVal  = ZO_ComboBox_ObjectFromContainer(u.CltVal)
  u.CB.JewVal  = ZO_ComboBox_ObjectFromContainer(u.JewVal)
  u.CB.EnchVal = ZO_ComboBox_ObjectFromContainer(u.EnchVal)
  u.CB.AlchVal = ZO_ComboBox_ObjectFromContainer(u.AlchVal)
  u.CB.ProvVal = ZO_ComboBox_ObjectFromContainer(u.ProvVal)
  u.CB.AmbrVal = ZO_ComboBox_ObjectFromContainer(u.AmbrVal)
--> SBMI_FlWinSAScrollChild->PvE
  SBMI_FlWinSAScrollChildPvEHdr:SetText(l.PvEHdr)
  SBMI_FlWinSAScrollChildPvERLTxt:SetText(l.RL)
  SBMI_FlWinSAScrollChildPvEDDTxt:SetText(l.DD)
  SBMI_FlWinSAScrollChildPvEHealTxt:SetText(l.Heal)
  SBMI_FlWinSAScrollChildPvETankTxt:SetText(l.Tank)
  SBMI_FlWinSAScrollChildPvEStatTxt:SetText(l.Stat)
  u.PvE_RL    = SBMI_FlWinSAScrollChildPvERLVal
  u.PvE_DD    = SBMI_FlWinSAScrollChildPvEDDVal
  u.PvE_Heal  = SBMI_FlWinSAScrollChildPvEHealVal
  u.PvE_Tank  = SBMI_FlWinSAScrollChildPvETankVal
  u.PvE_Stat  = SBMI_FlWinSAScrollChildPvEStatVal
  u.CB.PvE_RL = ZO_ComboBox_ObjectFromContainer(u.PvE_RL)
  u.CB.PvE_DD = ZO_ComboBox_ObjectFromContainer(u.PvE_DD)
  u.CB.PvE_Heal = ZO_ComboBox_ObjectFromContainer(u.PvE_Heal)
  u.CB.PvE_Tank = ZO_ComboBox_ObjectFromContainer(u.PvE_Tank)
  u.CB.PvE_Stat = ZO_ComboBox_ObjectFromContainer(u.PvE_Stat)
--> SBMI_FlWinSAScrollChild->Attest
  SBMI_FlWinSAScrollChildAttestHdr:SetText(l.AttestHdr)
  SBMI_FlWinSAScrollChildAttestDDTxt:SetText(l.DD)
  u.DDFrom   = SBMI_FlWinSAScrollChildAttestDDValFromText
  u.DDTo     = SBMI_FlWinSAScrollChildAttestDDValToText
  SBMI_FlWinSAScrollChildAttestHealTxt:SetText(l.Heal)
  u.HealCmp = SBMI_FlWinSAScrollChildAttestHealCmp
  u.HealVal = SBMI_FlWinSAScrollChildAttestHealVal
  u.CB.HealCmp = ZO_ComboBox_ObjectFromContainer(u.HealCmp)
  u.CB.HealVal = ZO_ComboBox_ObjectFromContainer(u.HealVal)
  SBMI_FlWinSAScrollChildAttestTankTxt:SetText(l.Tank)
  u.TankCmp = SBMI_FlWinSAScrollChildAttestTankCmp
  u.TankVal = SBMI_FlWinSAScrollChildAttestTankVal
  u.CB.TankCmp = ZO_ComboBox_ObjectFromContainer(u.TankCmp)
  u.CB.TankVal = ZO_ComboBox_ObjectFromContainer(u.TankVal)
--> SBMI_FlWinSAScrollChild->Trials
  SBMI_FlWinSAScrollChildTrialsHdr:SetText(l.TrialsHdr)
  SBMI_FlWinSAScrollChildTrialsDDTxt:SetText(l.DD)
  SBMI_FlWinSAScrollChildTrialsHealTxt:SetText(l.Heal)
  SBMI_FlWinSAScrollChildTrialsTankTxt:SetText(l.Tank)
  u.TrlDD   = SBMI_FlWinSAScrollChildTrialsDDChk
  u.TrlHeal = SBMI_FlWinSAScrollChildTrialsHealChk
  u.TrlTank = SBMI_FlWinSAScrollChildTrialsTankChk
  u.TrlDung = SBMI_FlWinSAScrollChildTrialsDungSel
  u.TrlCmp  = SBMI_FlWinSAScrollChildTrialsDungCmp
  u.TrlVal  = SBMI_FlWinSAScrollChildTrialsDungVal
  u.CB.TrlDung = ZO_ComboBox_ObjectFromContainer(u.TrlDung)
  u.CB.TrlCmp  = ZO_ComboBox_ObjectFromContainer(u.TrlCmp )
  u.CB.TrlVal  = ZO_ComboBox_ObjectFromContainer(u.TrlVal )
--> SBMI_FlWinSAScrollChild->Dungeons
  SBMI_FlWinSAScrollChildDungeonsHdr:SetText(l.DungHdr)
  u.DungSel = SBMI_FlWinSAScrollChildDungeonsDungSel
  u.DungCmp = SBMI_FlWinSAScrollChildDungeonsDungCmp
  u.DungVal = SBMI_FlWinSAScrollChildDungeonsDungVal
  u.CB.DungSel = ZO_ComboBox_ObjectFromContainer(u.DungSel)
  u.CB.DungCmp = ZO_ComboBox_ObjectFromContainer(u.DungCmp)
  u.CB.DungVal = ZO_ComboBox_ObjectFromContainer(u.DungVal)
--
  ZO_CheckButton_SetCheckState(u.TrlDD  , f.TrlDD  )
  ZO_CheckButton_SetCheckState(u.TrlHeal, f.TrlHeal)
  ZO_CheckButton_SetCheckState(u.TrlTank, f.TrlTank)
  ZO_CheckButton_SetToggleFunction(u.TrlDD  , function(control, checked) f.TrlDD   = checked; DBGN:RefreshRosterFilters() end)
  ZO_CheckButton_SetToggleFunction(u.TrlHeal, function(control, checked) f.TrlHeal = checked; DBGN:RefreshRosterFilters() end)
  ZO_CheckButton_SetToggleFunction(u.TrlTank, function(control, checked) f.TrlTank = checked; DBGN:RefreshRosterFilters() end)
--
  u.DDFrom:SetText(f.DDFrom)
  u.DDTo:SetText(f.DDTo)
  u.DDFrom:SetHandler("OnTextChanged", function(control) UI_Fl_OnTextChanged(control, u, f) end)
  u.DDTo:SetHandler("OnTextChanged", function(control) UI_Fl_OnTextChanged(control, u, f) end)
--Guild:InitUI_Fl_CB(c, f, ctrl, arr, val, max)
  self:InitUI_Fl_CB(u.CB, f, u.CB.Forum  , g.AnyYesNo, f.Forum  , 3)
  self:InitUI_Fl_CB(u.CB, f, u.CB.Proff  , g.AnyYesNo, f.Proff  , 3)
  self:InitUI_Fl_CB(u.CB, f, u.CB.Discord, g.AnyYesNo, f.Discord, 3)
  self:InitUI_Fl_CB(u.CB, f, u.CB.Vamp   , g.AnyYesNo, f.Vamp   , 3)
  self:InitUI_Fl_CB(u.CB, f, u.CB.WW     , g.AnyYesNo, f.WW     , 3)
  self:InitUI_Fl_CB(u.CB, f, u.CB.House  , g.AnyYesNo, f.House  , 3)
--
  self:InitUI_Fl_CB(u.CB, f, u.CB.TrlDung, g.TrlDung , f.TrlDung, #g.TrlDung)
  self:InitUI_Fl_CB(u.CB, f, u.CB.TrlVal , g.TrlVal  , f.TrlVal , 4)
  self:InitUI_Fl_CB(u.CB, f, u.CB.TrlCmp , g.Cmp     , f.TrlCmp , 4)
  self:InitUI_Fl_CB(u.CB, f, u.CB.HealCmp, g.Cmp     , f.HealCmp, 4)
  self:InitUI_Fl_CB(u.CB, f, u.CB.TankCmp, g.Cmp     , f.TankCmp, 4)
--
  self:InitUI_Fl_CB(u.CB, f, u.CB.PenaltyCmp, g.Cmp  , f.PenaltyCmp, 4)
  for i = 1,5 do
    arr[i] = ""
    for j = 1,4 do
      if i <= j then
        arr[i] = arr[i] .. DBGN.IcoPref24 .. Ic0.Cross.Off .. DBGN.IcoSuff
      else
        arr[i] = arr[i] .. DBGN.IcoPref24 .. Ic0.Cross.On .. DBGN.IcoSuff
      end
    end
  end
  self:InitUI_Fl_CB(u.CB, f, u.CB.PenaltyVal, arr, f.PenaltyVal, 5)
--
  for i = 1,SBMI.DungCount do arr[i] = l.Dungeons[i].S end self:InitUI_Fl_CB(u.CB, f, u.CB.DungSel, arr, f.DungSel, SBMI.DungCount)
  self:InitUI_Fl_CB(u.CB, f, u.CB.DungVal , q.DungVal , f.DungVal , 4)
  self:InitUI_Fl_CB(u.CB, f, u.CB.DungCmp , g.Cmp     , f.DungCmp , 4)
--
  self:InitUI_Fl_CB(u.CB, f, u.CB.PvE_RL  , g.AnyYesNo, f.PvE_RL  , 3)
  self:InitUI_Fl_CB(u.CB, f, u.CB.PvE_DD  , g.AnyYesNo, f.PvE_DD  , 3)
  self:InitUI_Fl_CB(u.CB, f, u.CB.PvE_Heal, g.AnyYesNo, f.PvE_Heal, 3)
  self:InitUI_Fl_CB(u.CB, f, u.CB.PvE_Tank, g.AnyYesNo, f.PvE_Tank, 3)
  self:InitUI_Fl_CB(u.CB, f, u.CB.PvE_Stat, q.SttF, f.PvE_Stat, 4)
--
  self:InitUI_Fl_CB(u.CB, f, u.CB.BlkVal , g.AnyYesNo, f.BlkVal , 3)
  self:InitUI_Fl_CB(u.CB, f, u.CB.WWrVal , g.AnyYesNo, f.WWrVal , 3)
  self:InitUI_Fl_CB(u.CB, f, u.CB.CltVal , g.AnyYesNo, f.CltVal , 3)
  self:InitUI_Fl_CB(u.CB, f, u.CB.JewVal , g.AnyYesNo, f.JewVal , 3)
  self:InitUI_Fl_CB(u.CB, f, u.CB.EnchVal, g.AnyYesNo, f.EnchVal, 3)
  self:InitUI_Fl_CB(u.CB, f, u.CB.AlchVal, g.AnyYesNo, f.AlchVal, 3)
  self:InitUI_Fl_CB(u.CB, f, u.CB.ProvVal, g.AnyYesNo, f.ProvVal, 3)
  self:InitUI_Fl_CB(u.CB, f, u.CB.AmbrVal, q.AmbF, f.AmbrVal, 4)
  for i = 0,3 do arr[i+1] = g.Heal[i] end self:InitUI_Fl_CB(u.CB, f, u.CB.HealVal, arr, f.HealVal, 4)
  for i = 0,3 do arr[i+1] = g.Tank[i] end self:InitUI_Fl_CB(u.CB, f, u.CB.TankVal, arr, f.TankVal, 4)
--  for i = 0,5 do arr[i+1] = g.PvP[i] end  self:InitUI_Fl_CB(u.CB, f, u.CB.PvPVal , arr, f.PvPVal , 6)
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

local function GetYear()
  local DateTimeTable = os.date('*t')
  local dateTime = DateTimeTable.year
  return dateTime
end

local function SetDTLblTxt(control, fl, t1, mm, dd, year)
  if fl then
    control:SetText(t1 .. LPad(dd,2,"0") .. "-" .. LPad(mm,2,"0") .. "-" .. LPad(GetYear(),4,"0"))
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
  u.GuildIco:SetTexture(SBMI.RankIcons[r.rankIndex])
  if r.OnLine then
    u.OnLineIco:SetTexture(Ic1.OnLine)
  else
    u.OnLineIco:SetTexture(Ic1.OffLine)
  end
-->
  DBGN:LabelColor(r.Forum,  u.FlForum)
  DBGN:LabelColor(r.Discord,u.FlDiscord)
  DBGN:LabelColor(r.Vamp,   u.FlVamp)
  DBGN:LabelColor(r.WW,     u.FlWW)
  DBGN:LabelColor(r.House,  u.FlHouse)
  DBGN:LabelColor(r.Proff,  u.FlProff)
  SetTextureOnOff(u.MelodyIco, Ic0.Melody, r.MelodyClc > 0)
  s = r.MelodyClc .. DBGN:AddColorToStr(" (" .. r.Melody .. ")", 1)
  u.MelodyTxt:SetText(s)
-->
  SetDTLblTxt(u.BardImpt, r.BardImptD ~= 0 and r.BardImptM ~= 0, l.BardImpt .. " ", r.BardImptM, r.BardImptD)
  SetDTLblTxt(u.Vacation, r.VacationD ~= 0 and r.VacationM ~= 0, l.Vacation .. " ", r.VacationM, r.VacationD)
  SetDTLblTxt(u.Kick, r.KickD ~= 0 and r.KickM ~= 0, l.Kick .. " ", r.KickM, r.KickD)
  SetLabelTxt(u.BustDiscord, r.BustDiscord > 0, l.BustDiscord .. ": ", r.BustDiscord)
  SetLabelTxt(u.CntBardSupr, r.CntBardSupr > 0, l.CntBardSupr .. ": ", r.CntBardSupr)
  SetLabelTxt(u.CntBardImpt, r.CntBardImpt > 0, l.CntBardImpt .. ": ", r.CntBardImpt)
  s = ""
  for i = 1,4 do
    s = s .. DBGN.IcoPref24
    if r.Penalty >= i then s = s .. Ic0.Cross.On else s = s .. Ic0.Cross.Off end
    s = s .. DBGN.IcoSuff
  end
  u.Penalty:SetText(s)
--> Craft
  SetTextureOnOff(u.CraftBlk , Ic0.Blk , r.CraftBlk )
  SetTextureOnOff(u.CraftWWr , Ic0.WWr , r.CraftWWr )
  SetTextureOnOff(u.CraftClt , Ic0.Clt , r.CraftClt )
  SetTextureOnOff(u.CraftEnch, Ic0.Ench, r.CraftEnch)
  SetTextureOnOff(u.CraftAlch, Ic0.Alch, r.CraftAlch)
  SetTextureOnOff(u.CraftJew , Ic0.Jew , r.CraftJew )
  SetTextureOnOff(u.CraftProv, Ic0.Prov, r.CraftProv)
  SetTextureOnOff(u.CraftAmbr, Ic0.Ambr, r.CraftAmbr > 0)
  if r.CraftAmbr > 0 then
    u.CraftAmbT:SetText(q.Ambr[r.CraftAmbr])
  else
    u.CraftAmbT:SetText("")
  end
-->
  DBGN:LabelColor(r.PvP_RL, u.PvP_RL)
  DBGN:LabelColor(r.PvP_Emperor, u.PvP_Emperor)
  SetLabelTxt(u.PvP_Stat, r.PvP_Stat > 0, l.Stat .. ": ", q.Stat[r.PvP_Stat])
  SetLabelTxt(u.PvP_Rank, r.PvP_Rank > 0, l.Rank .. ": ", q.PvPR[r.PvP_Rank])
-->
  DBGN:LabelColor(r.PvE_RL, u.PvE_RL)
  DBGN:LabelColor(r.PvE_DD, u.PvE_DD)
  DBGN:LabelColor(r.PvE_Heal, u.PvE_Heal)
  DBGN:LabelColor(r.PvE_Tank, u.PvE_Tank)
  SetLabelTxt(u.PvE_Stat, r.PvE_Stat > 0, l.Stat .. ": ", q.Stat[r.PvE_Stat])
  SetLabelTxt(u.PvE_Spec, q.PvEC[r.PvE_Spec], q.PvES[r.PvE_Spec])
  u.MSA:SetText(DBGN:AddTrialStr(r.PvE_MSA, g.MSA, "", CTrials.All))
  u.VH:SetText(DBGN:AddTrialStr(r.PvE_VH, g.VH, "", CTrials.All))
-->
  if r.DPS == 0 then
    u.DDVal:SetText("")
    u.DDRT:SetText("")
  else
    u.DDVal:SetText(r.DPS)
    DBGN:LabelColor(q.DDRT[r.AttestDD], u.DDVal)
    u.DDRT:SetText(q.DD[r.AttestDD])
    DBGN:LabelColor(false, u.DDRT)
  end
  u.HealVal:SetText(g.Heal[r.AttestHeal])
  DBGN:LabelColor((r.AttestHeal>0), u.HealVal)
  u.TankVal:SetText(g.Tank[r.AttestTank])
  DBGN:LabelColor((r.AttestTank>0), u.TankVal)
--
  u.DDAdd:SetText(  CreateTrialSt1(r.DD_AA  ,r.DD_SO  ,r.DD_HRC  ,r.DD_MoL  ,r.DD_HoF  ,r.DD_AS  ,r.DD_CR  ,r.DD_SS  ))
  u.HealAdd:SetText(CreateTrialSt1(r.Heal_AA,r.Heal_SO,r.Heal_HRC,r.Heal_MoL,r.Heal_HoF,r.Heal_AS,r.Heal_CR,r.Heal_SS))
  u.TankAdd:SetText(CreateTrialSt1(r.Tank_AA,r.Tank_SO,r.Tank_HRC,r.Tank_MoL,r.Tank_HoF,r.Tank_AS,r.Tank_CR,r.Tank_SS))
  u.DDAd2:SetText(  CreateTrialSt2(r.DD_KA  ,r.DD_RG  ,r.DD_DSR  ,r.DD_SE  ,r.DD_LC  ,r.DD_OC  ))
  u.HealAd2:SetText(CreateTrialSt2(r.Heal_KA,r.Heal_RG,r.Heal_DSR,r.Heal_SE,r.Heal_LC,r.Heal_OC))
  u.TankAd2:SetText(CreateTrialSt2(r.Tank_KA,r.Tank_RG,r.Tank_DSR,r.Tank_SE,r.Tank_LC,r.Tank_OC))
  u.DDAd3:SetText(  CreateTrialSt3(r.DD_DSA  ,r.DD_BRP  ))
  u.HealAd3:SetText(CreateTrialSt3(r.Heal_DSA,r.Heal_BRP))
  u.TankAd3:SetText(CreateTrialSt3(r.Tank_DSA,r.Tank_BRP))
-->
  local dc = SBMI.DungColor
  s = ""
  for i = 1,SBMI.DungCount do
    if i > 1 then s = s .. ", " end
    s = s .. DBGN:AddColorToStr(l.Dungeons[i].S, dc[r.Dung[i]])
  end
  u.Dung:SetText(s)
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
    u.OnLineIco:SetTexture(Ic1.OnLine)
  else
    u.OnLineIco:SetTexture(Ic1.OffLine)
  end
--
  ZO_CheckButton_SetCheckState(u.FlForum, r.Forum)
  ZO_CheckButton_SetCheckState(u.FlDiscord, r.Discord)
  ZO_CheckButton_SetCheckState(u.FlVamp , r.Vamp)
  ZO_CheckButton_SetCheckState(u.FlWW   , r.WW)
  ZO_CheckButton_SetCheckState(u.FlHouse, r.House)
  ZO_CheckButton_SetCheckState(u.FlProff, r.Proff)
  if r.Melody == nil or r.Melody == 0 then u.Melody:SetText("") else u.Melody:SetText(r.Melody) end
--
  DBGN:Set_CB_Val(u.CB.VacDD, r.VacationD, 1, 31, 32)
  DBGN:Set_CB_Val(u.CB.VacMM, r.VacationM, 1, 12, 13)
  DBGN:Set_CB_Val(u.CB.BrdDD, r.BardImptD, 1, 31, 32)
  DBGN:Set_CB_Val(u.CB.BrdMM, r.BardImptM, 1, 12, 13)
  DBGN:Set_CB_Val(u.CB.KicDD, r.KickD, 1, 31, 32)
  DBGN:Set_CB_Val(u.CB.KicMM, r.KickM, 1, 12, 13)
  DBGN:Set_CB_Val(u.CB.Pnlty, r.Penalty, 1, 4, 5)
  DBGN:Set_CB_Val(u.CB.BustD, r.BustDiscord, 1, 3, 4)
  if r.CntBardSupr == nil or r.CntBardSupr == 0 then u.CntBS:SetText("") else u.CntBS:SetText(r.CntBardSupr) end
  if r.CntBardImpt == nil or r.CntBardImpt == 0 then u.CntBI:SetText("") else u.CntBI:SetText(r.CntBardImpt) end
--
  u.Craft.Blk:SetStatus(r.CraftBlk)
  u.Craft.WWr:SetStatus(r.CraftWWr)
  u.Craft.Clt:SetStatus(r.CraftClt)
  u.Craft.Ench:SetStatus(r.CraftEnch)
  u.Craft.Alch:SetStatus(r.CraftAlch)
  u.Craft.Jew:SetStatus(r.CraftJew)
  u.Craft.Prov:SetStatus(r.CraftProv)
  DBGN:Set_CB_Val(u.CB.Ambr, r.CraftAmbr + 1, 1, 4, 1)
--
  ZO_CheckButton_SetCheckState(u.PvP.RL,   r.PvP_RL)
  ZO_CheckButton_SetCheckState(u.PvP.Empr, r.PvP_Emperor)
  DBGN:Set_CB_Val(u.CB.PvPStat, r.PvP_Stat + 1, 1, 3, 1)
  DBGN:Set_CB_Val(u.CB.PvPRank, r.PvP_Rank + 1, 1, 8, 1)
--
  ZO_CheckButton_SetCheckState(u.PvE.RL, r.PvE_RL)
  ZO_CheckButton_SetCheckState(u.PvE.DD, r.PvE_DD)
  ZO_CheckButton_SetCheckState(u.PvE.Heal, r.PvE_Heal)
  ZO_CheckButton_SetCheckState(u.PvE.Tank, r.PvE_Tank)
  DBGN:Set_CB_Val(u.CB.PvEStat, r.PvE_Stat + 1, 1, 3, 1)
  DBGN:Set_CB_Val(u.CB.PvESpec, r.PvE_Spec + 1, 1, 4, 1)
  DBGN:Set_CB_Val(u.CB.PvEMSA,  r.PvE_MSA + 1, 1, 4, 1)
  DBGN:Set_CB_Val(u.CB.PvEVH,   r.PvE_VH  + 1, 1, 4, 1)
--
  if r.DPS == nil or r.DPS == 0 then u.DD.DPS:SetText("") else u.DD.DPS:SetText(r.DPS) end
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
  for i = 1,6  do ZO_CheckButton_SetCheckState(u.Dung.Chk[i], r.Dung[i] > 0) end
  for i = 7,SBMI.DungCount do DBGN:Set_CB_Val(u.Dung.CB[i], r.Dung[i] + 1, 1, 3, 1) end
--
  u.ClearText:SetText(e:GetStrClear())
end

--
-- Section 7.1: Get values from Edit UI
--
function Guild:UI_Ed_GetVal()
  local u,r,x = self.UI_Ed,self.EncEd.r,DBGN.Trial_Max
  r.Forum   = ZO_CheckButton_IsChecked(u.FlForum)
  r.Discord = ZO_CheckButton_IsChecked(u.FlDiscord)
  r.Vamp    = ZO_CheckButton_IsChecked(u.FlVamp)
  r.WW      = ZO_CheckButton_IsChecked(u.FlWW)
  r.House   = ZO_CheckButton_IsChecked(u.FlHouse)
  r.Proff   = ZO_CheckButton_IsChecked(u.FlProff)
  r.Melody  = DBGN:StrToNum(u.Melody:GetText(), 0, 10000, 0)
--
  r.BardImptD = DBGN:Get_CB_Val(u.CB.BrdDD, 1, 31, 0)
  r.BardImptM = DBGN:Get_CB_Val(u.CB.BrdMM, 1, 12, 0)
  r.VacationD = DBGN:Get_CB_Val(u.CB.VacDD, 1, 31, 0)
  r.VacationM = DBGN:Get_CB_Val(u.CB.VacMM, 1, 12, 0)
  r.KickD = DBGN:Get_CB_Val(u.CB.KicDD, 1, 31, 0)
  r.KickM = DBGN:Get_CB_Val(u.CB.KicMM, 1, 12, 0)
  r.Penalty = DBGN:Get_CB_Val(u.CB.Pnlty, 1, 4, 0)
  r.BustDiscord = DBGN:Get_CB_Val(u.CB.BustD, 1, 3, 0)
  r.CntBardSupr = DBGN:StrToNum(u.CntBS:GetText(), 0, 63, 0)
  r.CntBardImpt = DBGN:StrToNum(u.CntBI:GetText(), 0, 63, 0)
--
  r.CraftBlk  = u.Craft.Blk.Status
  r.CraftWWr  = u.Craft.WWr.Status
  r.CraftClt  = u.Craft.Clt.Status
  r.CraftEnch = u.Craft.Ench.Status
  r.CraftAlch = u.Craft.Alch.Status
  r.CraftJew  = u.Craft.Jew.Status
  r.CraftProv = u.Craft.Prov.Status
  r.CraftAmbr = DBGN:Get_CB_Val(u.CB.Ambr, 1, 4, 1) - 1
--
  r.PvP_RL = ZO_CheckButton_IsChecked(u.PvP.RL)
  r.PvP_Stat = DBGN:Get_CB_Val(u.CB.PvPStat, 1, 3, 1) - 1
  r.PvP_Emperor = ZO_CheckButton_IsChecked(u.PvP.Empr)
  r.PvP_Rank = DBGN:Get_CB_Val(u.CB.PvPRank, 1, 8, 1) - 1
--
  r.PvE_RL = ZO_CheckButton_IsChecked(u.PvE.RL)
  r.PvE_Stat = DBGN:Get_CB_Val(u.CB.PvEStat, 1, 3, 1) - 1
  r.PvE_DD = ZO_CheckButton_IsChecked(u.PvE.DD)
  r.PvE_Heal = ZO_CheckButton_IsChecked(u.PvE.Heal)
  r.PvE_Tank = ZO_CheckButton_IsChecked(u.PvE.Tank)
  r.PvE_Spec = DBGN:Get_CB_Val(u.CB.PvESpec, 1, 4, 1) - 1
  r.PvE_MSA  = DBGN:Get_CB_Val(u.CB.PvEMSA, 1, 4, 1) - 1
  r.PvE_VH   = DBGN:Get_CB_Val(u.CB.PvEVH,  1, 4, 1) - 1
--
  r.DPS  = DBGN:StrToNum(u.DD.DPS:GetText(), 0, 262143, 0)
--
  local b = u.DD
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
  for i = 1,6 do
    local f = ZO_CheckButton_IsChecked(u.Dung.Chk[i])
    if f then r.Dung[i] = 1 else r.Dung[i] = 0 end
  end
  for i = 7,SBMI.DungCount do
    r.Dung[i] = DBGN:Get_CB_Val(u.Dung.CB[i], 1, 3, 1) - 1
  end
--
  r.ClearText = u.ClearText:GetText()
end

--
-- Section 8: UI Roster Filters
--
function Guild:UI_Fl_Check()
  local r,f=self.EncFl.r,SBMI.SV.Filters
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
    if     f.TrlDung == 17 then return r.PvE_MSA
    elseif f.TrlDung == 18 then return r.PvE_VH
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
  if not check_yes_no(r.Forum, f.Forum) then return false end
  if not check_yes_no(r.Proff, f.Proff) then return false end
  if not check_yes_no(r.Discord, f.Discord) then return false end
  if not check_yes_no(r.Vamp , f.Vamp ) then return false end
  if not check_yes_no(r.WW   , f.WW   ) then return false end
  if not check_yes_no(r.House, f.House) then return false end
--> d("Status")
  if not check_numb_min_max(r.MelodyClc, f.M1From, f.M1To) then return false end
  if not check_numb_min_max(r.Melody, f.M2From, f.M2To) then return false end
  if f.PenaltyCmp > 1 then
    if not check_numb_cmp(r.Penalty, f.PenaltyCmp, f.PenaltyVal) then return false end
  end
--> PvE
  if not check_yes_no(r.PvE_RL, f.PvE_RL) then return false end
  if not check_yes_no(r.PvE_DD, f.PvE_DD) then return false end
  if not check_yes_no(r.PvE_Heal, f.PvE_Heal) then return false end
  if not check_yes_no(r.PvE_Tank, f.PvE_Tank) then return false end
  if not check_numb_eqv(r.PvE_Stat+1, f.PvE_Stat) then return false end
--> Attestation
  if not check_numb_min_max(r.DPS, f.DDFrom,  f.DDTo)       then return false end
  if not check_numb_cmp(r.AttestHeal, f.HealCmp, f.HealVal) then return false end
  if not check_numb_cmp(r.AttestTank, f.TankCmp, f.TankVal) then return false end
--  if not check_numb_cmp(r.IndPvP    , f.PvPCmp , f.PvPVal)  then return false end
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
--> d("Dungeons")
  if f.DungCmp > 1 then
    if not check_numb_cmp(r.Dung[f.DungSel], f.DungCmp, f.DungVal) then return false end
  end
--> d("Craft")
  if not check_yes_no(r.CraftBlk , f.BlkVal) then return false end
  if not check_yes_no(r.CraftWWr , f.WWrVal) then return false end
  if not check_yes_no(r.CraftClt , f.CltVal) then return false end
  if not check_yes_no(r.CraftJew , f.JewVal) then return false end
  if not check_yes_no(r.CraftEnch, f.EnchVal) then return false end
  if not check_yes_no(r.CraftAlch, f.AlchVal) then return false end
  if not check_yes_no(r.CraftProv, f.ProvVal) then return false end
  if not check_numb_eqv(r.CraftAmbr, f.AmbrVal) then return false end
  return true
end

--
-- Section 9: Get guild for regester
--
function SBMI.GetGuildSB()
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