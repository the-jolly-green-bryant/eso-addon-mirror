local DBGN = DBGN
local Ico  = DBGN.Icons
local l = DBGN.i18n
local m = DBGN.Markers
local g = DBGN.MarkersGr
local CTrials = DBGN.Colors.Trials
local LPad = DBGN.LPad
local msg = DBGN.msg

--
-- Section 0: Guild Record
--
local Guild = {
  Code = "DBGN",
  Name = "Daggerfall Bandits",
  Pref = "{DBGN",
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
  r.TS = false
  r.Discord = false
  r.Vamp = false
  r.WW = false
  r.Protect = false
  r.House = false
  r.VacationD = 0
  r.VacationM = 0
  r.VacationY = 0
  r.IndWeaponsBl = 0
  r.IndWeaponsWp = 0
  r.IndArmorJ = 0
  r.IndArmorSh = 0
  r.IndArmorL = 0
  r.IndArmorM = 0
  r.IndArmorH = 0
  r.Enchant = false
  r.Alchemy = false
  r.IndProvision = 0
  r.IndPvP = 0
  r.Duelist = false
  r.Emperor = false
  r.IndAttHeal = 0
  r.IndAttTank = 0
  r.FlAttDD = false
  r.DPS = 0
  r.DuelRank = 0
  r.RaidRank = 0
--
  r.DD_AA = 0
  r.DD_SO = 0
  r.DD_HRC = 0
  r.DD_DSA = 0
  r.DD_BRP = 0
  r.DD_HoF = 0
  r.DD_AS = 0
  r.DD_CR = 0
  r.DD_MoL = 0
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
  r.Heal_BRP = 0
  r.Heal_HoF = 0
  r.Heal_AS = 0
  r.Heal_CR = 0
  r.Heal_MoL = 0
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
  r.Tank_BRP = 0
  r.Tank_HoF = 0
  r.Tank_AS = 0
  r.Tank_CR = 0
  r.Tank_MoL = 0
  r.Tank_SS = 0
  r.Tank_KA = 0
  r.Tank_RG = 0
  r.Tank_DSR = 0
  r.Tank_SE = 0
  r.Tank_LC = 0
  r.Tank_OC = 0
--
  r.Solo_MSA = 0
  r.Solo_VH = 0
  r.ClearText = ""
end

--
-- Section 2: Decode note
--
local function Chk_Trial_Max(r)
  local t = DBGN.Trial_Max
  local m = t.MoL
  if r.DD_MoL   > m then r.DD_MoL   = m end
  if r.Heal_MoL > m then r.Heal_MoL = m end
  if r.Tank_MoL > m then r.Tank_MoL = m end
  m = t.HoF
  if r.DD_HoF   > m then r.DD_HoF   = m end
  if r.Heal_HoF > m then r.Heal_HoF = m end
  if r.Tank_HoF > m then r.Tank_HoF = m end
  m = t.AS
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
--Guild.Chk_Trial_Max = Chk_Trial_Max
-- Add function to DBGN interface
DBGN.Chk_Trial_Max_DB = Chk_Trial_Max

local function Chg_Trial_v3_to_v4(r)
  local t = DBGN.Trial_v3_to_v4
  r.DD_AS   = t.AS[r.DD_AS]
  r.DD_CR   = t.CR[r.DD_CR]
  r.DD_SS   = t.SS[r.DD_SS]
  r.Heal_AS = t.AS[r.Heal_AS]
  r.Heal_CR = t.CR[r.Heal_CR]
  r.Heal_SS = t.SS[r.Heal_SS]
  r.Tank_AS = t.AS[r.Tank_AS]
  r.Tank_CR = t.CR[r.Tank_CR]
  r.Tank_SS = t.SS[r.Tank_SS]
end

local function DecodeStrV0(self)
  local r, n, a, b = self.r, self.n, 0, 0
  r.Forum,  a = self:DecBool(n[1])
  r.TS,     a = self:DecBool(a)
  r.Vamp,   a = self:DecBool(a)
  r.WW,     a = self:DecBool(a)
  r.Protect,a = self:DecBool(a)
  r.House     = (a>0)
  if n[2] < 1 or n[2] > 31 then r.VacationD = 0 else r.VacationD = n[2] end
  if n[3] < 1 or n[3] > 12 then r.VacationM = 0 else r.VacationM = n[3] end
  if n[4] < 1 or n[4] > 30 then r.VacationY = 0 else r.VacationY = n[4] end
  r.IndWeaponsBl, a = self:DecNumb(n[5],4)
  r.IndWeaponsWp, a = self:DecNumb(a,4)
  r.IndArmorSh,   a = self:DecNumb(a,4)
  r.IndArmorL,    a = self:DecNumb(n[6],4)
  r.IndArmorM,    a = self:DecNumb(a,4)
  r.IndArmorH,    a = self:DecNumb(a,4)
  r.Enchant,      a = self:DecBool(n[7])
  r.Alchemy,      a = self:DecBool(a)
  r.IndProvision, a = self:DecNumb(a,4)
  r.IndPvP,       a = self:DecNumb(n[8],8)
  r.Duelist,      a = self:DecBool(a)
  r.Emperor,      a = self:DecBool(a)
  r.IndAttHeal,   a = self:DecNumb(n[9],4)
  r.IndAttTank,   a = self:DecNumb(a,4)
  r.FlAttDD,      a = self:DecBool(a)
  r.DPS = n[10] * 4096 + n[11] * 64 + n[12]
  r.DD_AA,    a = self:DecNumb(n[13],4)
  r.DD_SO,    a = self:DecNumb(a,4)
  r.DD_HRC,   a = self:DecNumb(a,4)
  r.DD_DSA,   a = self:DecNumb(n[14],4)
  r.Solo_MSA, a = self:DecNumb(a,4)
  r.DD_MoL,   a = self:DecNumb(a,4)
  r.Heal_AA,  a = self:DecNumb(n[15],4)
  r.Heal_SO,  a = self:DecNumb(a,4)
  r.Heal_HRC, a = self:DecNumb(a,4)
  r.Heal_DSA, a = self:DecNumb(n[16],4)
  b,            a = self:DecNumb(a,4)
  r.Heal_MoL, a = self:DecNumb(a,4)
  r.Tank_AA,  a = self:DecNumb(n[17],4)
  r.Tank_SO,  a = self:DecNumb(a,4)
  r.Tank_HRC, a = self:DecNumb(a,4)
  r.Tank_DSA, a = self:DecNumb(n[18],4)
  b,            a = self:DecNumb(a,4)
  r.Tank_MoL, a = self:DecNumb(a,4)
end

local function DecodeStrV1(self)
  local r, n, a, b = self.r, self.n, 0, 0
  r.Forum,  a = self:DecBool(n[1])
  r.TS,     a = self:DecBool(a)
  r.Vamp,   a = self:DecBool(a)
  r.WW,     a = self:DecBool(a)
  r.Protect,a = self:DecBool(a)
  r.House     = (a>0)
  if n[2] < 1 or n[2] > 31 then r.VacationD = 0 else r.VacationD = n[2] end
  if n[3] < 1 or n[3] > 12 then r.VacationM = 0 else r.VacationM = n[3] end
  if n[4] < 1 or n[4] > 30 then r.VacationY = 0 else r.VacationY = n[4] end
  r.IndWeaponsBl, a = self:DecNumb(n[5],4)
  r.IndWeaponsWp, a = self:DecNumb(a,4)
  r.IndArmorSh,   a = self:DecNumb(a,4)
  r.IndArmorL,    a = self:DecNumb(n[6],4)
  r.IndArmorM,    a = self:DecNumb(a,4)
  r.IndArmorH,    a = self:DecNumb(a,4)
  r.Enchant,      a = self:DecBool(n[7])
  r.Alchemy,      a = self:DecBool(a)
  r.IndProvision, a = self:DecNumb(a,4)
  r.IndPvP,       a = self:DecNumb(n[8],8)
  r.Duelist,      a = self:DecBool(a)
  r.Emperor,      a = self:DecBool(a)
  r.DuelRank = n[9] * 64 + n[10]
  r.Solo_MSA,   a = self:DecNumb(n[11],4)
  r.IndAttHeal,   a = self:DecNumb(n[12],4)
  r.IndAttTank,   a = self:DecNumb(a,4)
  r.FlAttDD,      a = self:DecBool(a)
  r.DPS = n[13] * 4096 + n[14] * 64 + n[15]
  r.DD_AA,    a = self:DecNumb(n[16],4)
  r.DD_SO,    a = self:DecNumb(a,4)
  r.DD_HRC,   a = self:DecNumb(a,4)
  r.DD_DSA,   a = self:DecNumb(n[17],4)
  r.DD_HoF,   a = self:DecNumb(a,4)
  r.DD_MoL,   a = self:DecNumb(a,4)
  r.Heal_AA,  a = self:DecNumb(n[18],4)
  r.Heal_SO,  a = self:DecNumb(a,4)
  r.Heal_HRC, a = self:DecNumb(a,4)
  r.Heal_DSA, a = self:DecNumb(n[19],4)
  r.Heal_HoF, a = self:DecNumb(a,4)
  r.Heal_MoL, a = self:DecNumb(a,4)
  r.Tank_AA,  a = self:DecNumb(n[20],4)
  r.Tank_SO,  a = self:DecNumb(a,4)
  r.Tank_HRC, a = self:DecNumb(a,4)
  r.Tank_DSA, a = self:DecNumb(n[21],4)
  r.Tank_HoF, a = self:DecNumb(a,4)
  r.Tank_MoL, a = self:DecNumb(a,4)
end

local function DecodeStrV2(self)
  local r, n, a, b = self.r, self.n, 0, 0
  r.Forum,  a = self:DecBool(n[1])
  r.TS,     a = self:DecBool(a)
  r.Vamp,   a = self:DecBool(a)
  r.WW,     a = self:DecBool(a)
  r.Protect,a = self:DecBool(a)
  r.House     = (a>0)
  if n[2] < 1 or n[2] > 31 then r.VacationD = 0 else r.VacationD = n[2] end
  if n[3] < 1 or n[3] > 12 then r.VacationM = 0 else r.VacationM = n[3] end
  if n[4] < 1 or n[4] > 30 then r.VacationY = 0 else r.VacationY = n[4] end
  r.IndWeaponsBl, a = self:DecNumb(n[5],4)
  r.IndWeaponsWp, a = self:DecNumb(a,4)
  r.IndArmorSh,   a = self:DecNumb(a,4)
  r.IndArmorL,    a = self:DecNumb(n[6],4)
  r.IndArmorM,    a = self:DecNumb(a,4)
  r.IndArmorH,    a = self:DecNumb(a,4)
  r.Enchant,      a = self:DecBool(n[7])
  r.Alchemy,      a = self:DecBool(a)
  r.IndProvision, a = self:DecNumb(a,4)
  r.IndArmorJ,    a = self:DecNumb(a,4)
  r.IndPvP,       a = self:DecNumb(n[8],8)
  r.Duelist,      a = self:DecBool(a)
  r.Emperor,      a = self:DecBool(a)
  r.DuelRank = n[9] * 64 + n[10]
  r.Solo_MSA,   a = self:DecNumb(n[11],4)
  r.IndAttHeal,   a = self:DecNumb(n[12],4)
  r.IndAttTank,   a = self:DecNumb(a,4)
  r.FlAttDD,      a = self:DecBool(a)
  r.DPS = n[13] * 4096 + n[14] * 64 + n[15]
  r.DD_AA,    a = self:DecNumb(n[16],4)
  r.DD_SO,    a = self:DecNumb(a,4)
  r.DD_HRC,   a = self:DecNumb(a,4)
  r.DD_DSA,   a = self:DecNumb(n[17],4)
  r.DD_HoF,   a = self:DecNumb(a,4)
  r.DD_MoL,   a = self:DecNumb(a,4)
  r.DD_AS,    a = self:DecNumb(n[18],4)
  r.DD_CR,    a = self:DecNumb(a,4)
  r.DD_BRP,   a = self:DecNumb(a,4)
  r.Heal_AA,  a = self:DecNumb(n[19],4)
  r.Heal_SO,  a = self:DecNumb(a,4)
  r.Heal_HRC, a = self:DecNumb(a,4)
  r.Heal_DSA, a = self:DecNumb(n[20],4)
  r.Heal_HoF, a = self:DecNumb(a,4)
  r.Heal_MoL, a = self:DecNumb(a,4)
  r.Heal_AS,  a = self:DecNumb(n[21],4)
  r.Heal_CR,  a = self:DecNumb(a,4)
  r.Heal_BRP, a = self:DecNumb(a,4)
  r.Tank_AA,  a = self:DecNumb(n[22],4)
  r.Tank_SO,  a = self:DecNumb(a,4)
  r.Tank_HRC, a = self:DecNumb(a,4)
  r.Tank_DSA, a = self:DecNumb(n[23],4)
  r.Tank_HoF, a = self:DecNumb(a,4)
  r.Tank_MoL, a = self:DecNumb(a,4)
  r.Tank_AS,  a = self:DecNumb(n[24],4)
  r.Tank_CR,  a = self:DecNumb(a,4)
  r.Tank_BRP, a = self:DecNumb(a,4)
  Chg_Trial_v3_to_v4(r)
end

local function DecodeStrV3(self)
  local r, n, a, b = self.r, self.n, 0, 0
  r.Forum,  a = self:DecBool(n[1])
  r.TS,     a = self:DecBool(a)
  r.Vamp,   a = self:DecBool(a)
  r.WW,     a = self:DecBool(a)
  r.Protect,a = self:DecBool(a)
  r.House     = (a>0)
  if n[2] < 1 or n[2] > 31 then r.VacationD = 0 else r.VacationD = n[2] end
  if n[3] < 1 or n[3] > 12 then r.VacationM = 0 else r.VacationM = n[3] end
  if n[4] < 1 or n[4] > 30 then r.VacationY = 0 else r.VacationY = n[4] end
  r.IndWeaponsBl, a = self:DecNumb(n[5],4)
  r.IndWeaponsWp, a = self:DecNumb(a,4)
  r.IndArmorSh,   a = self:DecNumb(a,4)
  r.IndArmorL,    a = self:DecNumb(n[6],4)
  r.IndArmorM,    a = self:DecNumb(a,4)
  r.IndArmorH,    a = self:DecNumb(a,4)
  r.Enchant,      a = self:DecBool(n[7])
  r.Alchemy,      a = self:DecBool(a)
  r.IndProvision, a = self:DecNumb(a,4)
  r.IndArmorJ,    a = self:DecNumb(a,4)
  r.IndPvP,       a = self:DecNumb(n[8],8)
  r.Duelist,      a = self:DecBool(a)
  r.Emperor,      a = self:DecBool(a)
  r.DuelRank = n[9] * 64 + n[10]
  r.Solo_MSA,   a = self:DecNumb(n[11],4)
  r.IndAttHeal,   a = self:DecNumb(n[12],4)
  r.IndAttTank,   a = self:DecNumb(a,4)
  r.FlAttDD,      a = self:DecBool(a)
  r.DPS = n[13] * 4096 + n[14] * 64 + n[15]
  r.DD_AA,    a = self:DecNumb(n[16],4)
  r.DD_SO,    a = self:DecNumb(a,4)
  r.DD_HRC,   a = self:DecNumb(a,4)
  r.DD_DSA,   a = self:DecNumb(n[17],4)
  r.DD_HoF,   a = self:DecNumb(a,4)
  r.DD_MoL,   a = self:DecNumb(a,4)
  r.DD_AS,    a = self:DecNumb(n[18],4)
  r.DD_CR,    a = self:DecNumb(a,4)
  r.DD_BRP,   a = self:DecNumb(a,4)
  r.DD_SS,    a = self:DecNumb(n[19],4)
  r.Heal_AA,  a = self:DecNumb(n[20],4)
  r.Heal_SO,  a = self:DecNumb(a,4)
  r.Heal_HRC, a = self:DecNumb(a,4)
  r.Heal_DSA, a = self:DecNumb(n[21],4)
  r.Heal_HoF, a = self:DecNumb(a,4)
  r.Heal_MoL, a = self:DecNumb(a,4)
  r.Heal_AS,  a = self:DecNumb(n[22],4)
  r.Heal_CR,  a = self:DecNumb(a,4)
  r.Heal_BRP, a = self:DecNumb(a,4)
  r.Heal_SS,  a = self:DecNumb(n[23],4)
  r.Tank_AA,  a = self:DecNumb(n[24],4)
  r.Tank_SO,  a = self:DecNumb(a,4)
  r.Tank_HRC, a = self:DecNumb(a,4)
  r.Tank_DSA, a = self:DecNumb(n[25],4)
  r.Tank_HoF, a = self:DecNumb(a,4)
  r.Tank_MoL, a = self:DecNumb(a,4)
  r.Tank_AS,  a = self:DecNumb(n[26],4)
  r.Tank_CR,  a = self:DecNumb(a,4)
  r.Tank_BRP, a = self:DecNumb(a,4)
  r.Tank_SS,  a = self:DecNumb(n[27],4)
  Chg_Trial_v3_to_v4(r)
end

local function DecodeStrV4(self)
  local r, n, a, b = self.r, self.n, 0, 0
  r.Forum,  a = self:DecBool(n[1])
  r.TS,     a = self:DecBool(a)
  r.Vamp,   a = self:DecBool(a)
  r.WW,     a = self:DecBool(a)
  r.Protect,a = self:DecBool(a)
  r.House     = (a>0)
  if n[2] < 1 or n[2] > 31 then r.VacationD = 0 else r.VacationD = n[2] end
  if n[3] < 1 or n[3] > 12 then r.VacationM = 0 else r.VacationM = n[3] end
  if n[4] < 1 or n[4] > 30 then r.VacationY = 0 else r.VacationY = n[4] end
  r.IndWeaponsBl, a = self:DecNumb(n[5],4)
  r.IndWeaponsWp, a = self:DecNumb(a,4)
  r.IndArmorSh,   a = self:DecNumb(a,4)
  r.IndArmorL,    a = self:DecNumb(n[6],4)
  r.IndArmorM,    a = self:DecNumb(a,4)
  r.IndArmorH,    a = self:DecNumb(a,4)
  r.Enchant,      a = self:DecBool(n[7])
  r.Alchemy,      a = self:DecBool(a)
  r.IndProvision, a = self:DecNumb(a,4)
  r.IndArmorJ,    a = self:DecNumb(a,4)
  r.IndPvP,       a = self:DecNumb(n[8],8)
  r.Duelist,      a = self:DecBool(a)
  r.Emperor,      a = self:DecBool(a)
  r.Discord,      a = self:DecBool(a)
  r.DuelRank = n[9] * 64 + n[10]
  r.RaidRank = n[11]* 64 + n[12]
  r.Solo_MSA,   a = self:DecNumb(n[13],4)
  r.Solo_VH,    a = self:DecNumb(a,4)
  r.IndAttHeal,   a = self:DecNumb(n[14],4)
  r.IndAttTank,   a = self:DecNumb(a,4)
  r.FlAttDD,      a = self:DecBool(a)
  r.DPS = n[15] * 4096 + n[16] * 64 + n[17]
--
  r.DD_AA,    a = self:DecNumb(n[18],4)
  r.DD_SO,    a = self:DecNumb(a,4)
  r.DD_HRC,   a = self:DecNumb(a,4)
  r.DD_DSA,   a = self:DecNumb(n[19],4)
  r.DD_HoF,   a = self:DecNumb(a,4)
  r.DD_MoL,   a = self:DecNumb(a,4)
  r.DD_BRP,   a = self:DecNumb(n[20],4)
  r.DD_RG,    a = self:DecNumb(a,8)
  r.DD_AS,    a = self:DecNumb(n[21],8)
  r.DD_CR,    a = self:DecNumb(a,8)
  r.DD_SS,    a = self:DecNumb(n[22],8)
  r.DD_KA,    a = self:DecNumb(a,8)
--
  r.Heal_AA,  a = self:DecNumb(n[23],4)
  r.Heal_SO,  a = self:DecNumb(a,4)
  r.Heal_HRC, a = self:DecNumb(a,4)
  r.Heal_DSA, a = self:DecNumb(n[24],4)
  r.Heal_HoF, a = self:DecNumb(a,4)
  r.Heal_MoL, a = self:DecNumb(a,4)
  r.Heal_BRP, a = self:DecNumb(n[25],4)
  r.Heal_RG,  a = self:DecNumb(a,8)
  r.Heal_AS,  a = self:DecNumb(n[26],8)
  r.Heal_CR,  a = self:DecNumb(a,8)
  r.Heal_SS,  a = self:DecNumb(n[27],8)
  r.Heal_KA,  a = self:DecNumb(a,8)
--
  r.Tank_AA,  a = self:DecNumb(n[28],4)
  r.Tank_SO,  a = self:DecNumb(a,4)
  r.Tank_HRC, a = self:DecNumb(a,4)
  r.Tank_DSA, a = self:DecNumb(n[29],4)
  r.Tank_HoF, a = self:DecNumb(a,4)
  r.Tank_MoL, a = self:DecNumb(a,4)
  r.Tank_BRP, a = self:DecNumb(n[30],4)
  r.Tank_RG,  a = self:DecNumb(a,8)
  r.Tank_AS,  a = self:DecNumb(n[31],8)
  r.Tank_CR,  a = self:DecNumb(a,8)
  r.Tank_SS,  a = self:DecNumb(n[32],8)
  r.Tank_KA,  a = self:DecNumb(a,8)
--
  Chk_Trial_Max(r)
end

local function DecodeStrV5(self)
  local r, n, a, b = self.r, self.n, 0, 0
  r.Forum,  a = self:DecBool(n[1])
  r.TS,     a = self:DecBool(a)
  r.Vamp,   a = self:DecBool(a)
  r.WW,     a = self:DecBool(a)
  r.Protect,a = self:DecBool(a)
  r.House     = (a>0)
  if n[2] < 1 or n[2] > 31 then r.VacationD = 0 else r.VacationD = n[2] end
  if n[3] < 1 or n[3] > 12 then r.VacationM = 0 else r.VacationM = n[3] end
  if n[4] < 1 or n[4] > 30 then r.VacationY = 0 else r.VacationY = n[4] end
  r.IndWeaponsBl, a = self:DecNumb(n[5],4)
  r.IndWeaponsWp, a = self:DecNumb(a,4)
  r.IndArmorSh,   a = self:DecNumb(a,4)
  r.IndArmorL,    a = self:DecNumb(n[6],4)
  r.IndArmorM,    a = self:DecNumb(a,4)
  r.IndArmorH,    a = self:DecNumb(a,4)
  r.Enchant,      a = self:DecBool(n[7])
  r.Alchemy,      a = self:DecBool(a)
  r.IndProvision, a = self:DecNumb(a,4)
  r.IndArmorJ,    a = self:DecNumb(a,4)
  r.IndPvP,       a = self:DecNumb(n[8],8)
  r.Duelist,      a = self:DecBool(a)
  r.Emperor,      a = self:DecBool(a)
  r.Discord,      a = self:DecBool(a)
  r.DuelRank = n[9] * 64 + n[10]
  r.RaidRank = n[11]* 64 + n[12]
  r.Solo_MSA,   a = self:DecNumb(n[13],4)
  r.Solo_VH,    a = self:DecNumb(a,4)
  r.IndAttHeal,   a = self:DecNumb(n[14],4)
  r.IndAttTank,   a = self:DecNumb(a,4)
  r.FlAttDD,      a = self:DecBool(a)
  r.DPS = n[15] * 4096 + n[16] * 64 + n[17]
--
  r.DD_AA,    a = self:DecNumb(n[18],4)
  r.DD_SO,    a = self:DecNumb(a,4)
  r.DD_HRC,   a = self:DecNumb(a,4)
  r.DD_DSA,   a = self:DecNumb(n[19],4)
  r.DD_HoF,   a = self:DecNumb(a,4)
  r.DD_MoL,   a = self:DecNumb(a,4)
  r.DD_BRP,   a = self:DecNumb(n[20],4)
  _        ,    a = self:DecNumb(a,2)
  r.DD_SE,    a = self:DecNumb(a,8)
  r.DD_AS,    a = self:DecNumb(n[21],8)
  r.DD_CR,    a = self:DecNumb(a,8)
  r.DD_SS,    a = self:DecNumb(n[22],8)
  r.DD_KA,    a = self:DecNumb(a,8)
  r.DD_RG,    a = self:DecNumb(n[23],8)
  r.DD_DSR,   a = self:DecNumb(a,8)
--
  r.Heal_AA,  a = self:DecNumb(n[24],4)
  r.Heal_SO,  a = self:DecNumb(a,4)
  r.Heal_HRC, a = self:DecNumb(a,4)
  r.Heal_DSA, a = self:DecNumb(n[25],4)
  r.Heal_HoF, a = self:DecNumb(a,4)
  r.Heal_MoL, a = self:DecNumb(a,4)
  r.Heal_BRP, a = self:DecNumb(n[26],4)
  _          ,  a = self:DecNumb(a,2)
  r.Heal_SE,  a = self:DecNumb(a,8)
  r.Heal_AS,  a = self:DecNumb(n[27],8)
  r.Heal_CR,  a = self:DecNumb(a,8)
  r.Heal_SS,  a = self:DecNumb(n[28],8)
  r.Heal_KA,  a = self:DecNumb(a,8)
  r.Heal_RG,  a = self:DecNumb(n[29],8)
  r.Heal_DSR, a = self:DecNumb(a,8)
--
  r.Tank_AA,  a = self:DecNumb(n[30],4)
  r.Tank_SO,  a = self:DecNumb(a,4)
  r.Tank_HRC, a = self:DecNumb(a,4)
  r.Tank_DSA, a = self:DecNumb(n[31],4)
  r.Tank_HoF, a = self:DecNumb(a,4)
  r.Tank_MoL, a = self:DecNumb(a,4)
  r.Tank_BRP, a = self:DecNumb(n[32],4)
  _          ,  a = self:DecNumb(a,2)
  r.Tank_SE,  a = self:DecNumb(a,8)
  r.Tank_AS,  a = self:DecNumb(n[33],8)
  r.Tank_CR,  a = self:DecNumb(a,8)
  r.Tank_SS,  a = self:DecNumb(n[34],8)
  r.Tank_KA,  a = self:DecNumb(a,8)
  r.Tank_RG,  a = self:DecNumb(n[35],8)
  r.Tank_DSR, a = self:DecNumb(a,8)
--
  Chk_Trial_Max(r)
end

local function DecodeStrV6(self)
  local r, n, a, b = self.r, self.n, 0, 0
  r.Forum,  a = self:DecBool(n[1])
  r.TS,     a = self:DecBool(a)
  r.Vamp,   a = self:DecBool(a)
  r.WW,     a = self:DecBool(a)
  r.Protect,a = self:DecBool(a)
  r.House     = (a>0)
  if n[2] < 1 or n[2] > 31 then r.VacationD = 0 else r.VacationD = n[2] end
  if n[3] < 1 or n[3] > 12 then r.VacationM = 0 else r.VacationM = n[3] end
  if n[4] < 1 or n[4] > 30 then r.VacationY = 0 else r.VacationY = n[4] end
  r.IndWeaponsBl, a = self:DecNumb(n[5],4)
  r.IndWeaponsWp, a = self:DecNumb(a,4)
  r.IndArmorSh,   a = self:DecNumb(a,4)
  r.IndArmorL,    a = self:DecNumb(n[6],4)
  r.IndArmorM,    a = self:DecNumb(a,4)
  r.IndArmorH,    a = self:DecNumb(a,4)
  r.Enchant,      a = self:DecBool(n[7])
  r.Alchemy,      a = self:DecBool(a)
  r.IndProvision, a = self:DecNumb(a,4)
  r.IndArmorJ,    a = self:DecNumb(a,4)
  r.IndPvP,       a = self:DecNumb(n[8],8)
  r.Duelist,      a = self:DecBool(a)
  r.Emperor,      a = self:DecBool(a)
  r.Discord,      a = self:DecBool(a)
  r.DuelRank = n[9] * 64 + n[10]
  r.RaidRank = n[11]* 64 + n[12]
  r.Solo_MSA,   a = self:DecNumb(n[13],4)
  r.Solo_VH,    a = self:DecNumb(a,4)
  r.IndAttHeal,   a = self:DecNumb(n[14],4)
  r.IndAttTank,   a = self:DecNumb(a,4)
  r.FlAttDD,      a = self:DecBool(a)
  r.DPS = n[15] * 4096 + n[16] * 64 + n[17]
--
  r.DD_AA,    a = self:DecNumb(n[18],4)
  r.DD_SO,    a = self:DecNumb(a,4)
  r.DD_HRC,   a = self:DecNumb(a,4)
  r.DD_DSA,   a = self:DecNumb(n[19],4)
  r.DD_BRP,   a = self:DecNumb(a,4)
--_        ,    a = self:DecNumb(a,4)
  r.DD_MoL,   a = self:DecNumb(n[20],8)
  r.DD_HoF,   a = self:DecNumb(a,8)
  r.DD_CR,    a = self:DecNumb(n[21],16)
--_        ,    a = self:DecNumb(a,4)
  r.DD_AS,    a = self:DecNumb(n[22],8)
  r.DD_SS,    a = self:DecNumb(a,8)
  r.DD_KA,    a = self:DecNumb(n[23],8)
  r.DD_RG,    a = self:DecNumb(a,8)
  r.DD_DSR,   a = self:DecNumb(n[24],8)
  r.DD_SE,    a = self:DecNumb(a,8)
--
  r.Heal_AA,  a = self:DecNumb(n[25],4)
  r.Heal_SO,  a = self:DecNumb(a,4)
  r.Heal_HRC, a = self:DecNumb(a,4)
  r.Heal_DSA, a = self:DecNumb(n[26],4)
  r.Heal_BRP, a = self:DecNumb(a,4)
--_        ,    a = self:DecNumb(a,4)
  r.Heal_MoL, a = self:DecNumb(n[27],8)
  r.Heal_HoF, a = self:DecNumb(a,8)
  r.Heal_CR,  a = self:DecNumb(n[28],16)
--_        ,    a = self:DecNumb(a,4)
  r.Heal_AS,  a = self:DecNumb(n[29],8)
  r.Heal_SS,  a = self:DecNumb(a,8)
  r.Heal_KA,  a = self:DecNumb(n[30],8)
  r.Heal_RG,  a = self:DecNumb(a,8)
  r.Heal_DSR, a = self:DecNumb(n[31],8)
  r.Heal_SE,  a = self:DecNumb(a,8)
--
  r.Tank_AA,  a = self:DecNumb(n[32],4)
  r.Tank_SO,  a = self:DecNumb(a,4)
  r.Tank_HRC, a = self:DecNumb(a,4)
  r.Tank_DSA, a = self:DecNumb(n[33],4)
  r.Tank_BRP, a = self:DecNumb(a,4)
--_        ,    a = self:DecNumb(a,4)
  r.Tank_MoL, a = self:DecNumb(n[34],8)
  r.Tank_HoF, a = self:DecNumb(a,8)
  r.Tank_CR,  a = self:DecNumb(n[35],16)
--_        ,    a = self:DecNumb(a,4)
  r.Tank_AS,  a = self:DecNumb(n[36],8)
  r.Tank_SS,  a = self:DecNumb(a,8)
  r.Tank_KA,  a = self:DecNumb(n[37],8)
  r.Tank_RG,  a = self:DecNumb(a,8)
  r.Tank_DSR, a = self:DecNumb(n[38],8)
  r.Tank_SE,  a = self:DecNumb(a,8)
--
  Chk_Trial_Max(r)
end

local function DecodeStrV7(self)
  local r, n, a, b = self.r, self.n, 0, 0
  r.Forum,  a = self:DecBool(n[1])
  r.TS,     a = self:DecBool(a)
  r.Vamp,   a = self:DecBool(a)
  r.WW,     a = self:DecBool(a)
  r.Protect,a = self:DecBool(a)
  r.House     = (a>0)
  if n[2] < 1 or n[2] > 31 then r.VacationD = 0 else r.VacationD = n[2] end
  if n[3] < 1 or n[3] > 12 then r.VacationM = 0 else r.VacationM = n[3] end
  if n[4] < 1 or n[4] > 30 then r.VacationY = 0 else r.VacationY = n[4] end
  r.IndWeaponsBl, a = self:DecNumb(n[5],4)
  r.IndWeaponsWp, a = self:DecNumb(a,4)
  r.IndArmorSh,   a = self:DecNumb(a,4)
  r.IndArmorL,    a = self:DecNumb(n[6],4)
  r.IndArmorM,    a = self:DecNumb(a,4)
  r.IndArmorH,    a = self:DecNumb(a,4)
  r.Enchant,      a = self:DecBool(n[7])
  r.Alchemy,      a = self:DecBool(a)
  r.IndProvision, a = self:DecNumb(a,4)
  r.IndArmorJ,    a = self:DecNumb(a,4)
  r.IndPvP,       a = self:DecNumb(n[8],8)
  r.Duelist,      a = self:DecBool(a)
  r.Emperor,      a = self:DecBool(a)
  r.Discord,      a = self:DecBool(a)
  r.DuelRank = n[9] * 64 + n[10]
  r.RaidRank = n[11]* 64 + n[12]
  r.Solo_MSA,   a = self:DecNumb(n[13],4)
  r.Solo_VH,    a = self:DecNumb(a,4)
  r.IndAttHeal,   a = self:DecNumb(n[14],8)
  r.IndAttTank,   a = self:DecNumb(a,8)
  r.FlAttDD,      a = self:DecBool(n[15])
  r.DPS = n[16] * 4096 + n[17] * 64 + n[18]
--
  r.DD_AA,    a = self:DecNumb(n[19],4)
  r.DD_SO,    a = self:DecNumb(a,4)
  r.DD_HRC,   a = self:DecNumb(a,4)
  r.DD_DSA,   a = self:DecNumb(n[20],4)
  r.DD_BRP,   a = self:DecNumb(a,4)
--_        ,    a = self:DecNumb(a,4)
  r.DD_MoL,   a = self:DecNumb(n[21],8)
  r.DD_HoF,   a = self:DecNumb(a,8)
  r.DD_CR,    a = self:DecNumb(n[22],16)
--_        ,    a = self:DecNumb(a,4)
  r.DD_AS,    a = self:DecNumb(n[23],8)
  r.DD_SS,    a = self:DecNumb(a,8)
  r.DD_KA,    a = self:DecNumb(n[24],8)
  r.DD_RG,    a = self:DecNumb(a,8)
  r.DD_DSR,   a = self:DecNumb(n[25],8)
  r.DD_SE,    a = self:DecNumb(a,8)
  r.DD_LC,    a = self:DecNumb(n[26],8)
  r.DD_OC,    a = self:DecNumb(a,8)
--
  r.Heal_AA,  a = self:DecNumb(n[27],4)
  r.Heal_SO,  a = self:DecNumb(a,4)
  r.Heal_HRC, a = self:DecNumb(a,4)
  r.Heal_DSA, a = self:DecNumb(n[28],4)
  r.Heal_BRP, a = self:DecNumb(a,4)
--_        ,    a = self:DecNumb(a,4)
  r.Heal_MoL, a = self:DecNumb(n[29],8)
  r.Heal_HoF, a = self:DecNumb(a,8)
  r.Heal_CR,  a = self:DecNumb(n[30],16)
--_        ,    a = self:DecNumb(a,4)
  r.Heal_AS,  a = self:DecNumb(n[31],8)
  r.Heal_SS,  a = self:DecNumb(a,8)
  r.Heal_KA,  a = self:DecNumb(n[32],8)
  r.Heal_RG,  a = self:DecNumb(a,8)
  r.Heal_DSR, a = self:DecNumb(n[33],8)
  r.Heal_SE,  a = self:DecNumb(a,8)
  r.Heal_LC,  a = self:DecNumb(n[34],8)
  r.Heal_OC,  a = self:DecNumb(a,8)
--
  r.Tank_AA,  a = self:DecNumb(n[35],4)
  r.Tank_SO,  a = self:DecNumb(a,4)
  r.Tank_HRC, a = self:DecNumb(a,4)
  r.Tank_DSA, a = self:DecNumb(n[36],4)
  r.Tank_BRP, a = self:DecNumb(a,4)
--_        ,    a = self:DecNumb(a,4)
  r.Tank_MoL, a = self:DecNumb(n[37],8)
  r.Tank_HoF, a = self:DecNumb(a,8)
  r.Tank_CR,  a = self:DecNumb(n[38],16)
--_        ,    a = self:DecNumb(a,4)
  r.Tank_AS,  a = self:DecNumb(n[39],8)
  r.Tank_SS,  a = self:DecNumb(a,8)
  r.Tank_KA,  a = self:DecNumb(n[40],8)
  r.Tank_RG,  a = self:DecNumb(a,8)
  r.Tank_DSR, a = self:DecNumb(n[41],8)
  r.Tank_SE,  a = self:DecNumb(a,8)
  r.Tank_LC,  a = self:DecNumb(n[42],8)
  r.Tank_OC,  a = self:DecNumb(a,8)
--
  Chk_Trial_Max(r)
end

--
-- Section 3: Encode note
--
local function EncodeStr(self)
  self:ClearN()
  local r, n, a, b, x = self.r, self.n, 0, 0, DBGN.Trial_Max
  n[1] = self:EncBool(r.Forum,1) + self:EncBool(r.TS,2) + self:EncBool(r.Vamp,4) + self:EncBool(r.WW,8) + self:EncBool(r.Protect,16) + self:EncBool(r.House,32)
  if r.VacationD < 1 or r.VacationM < 1 then
    n[2] = 0
    n[3] = 0
    n[4] = 0
  else
    n[2] = self:EncNumb(r.VacationD,1,31)
    n[3] = self:EncNumb(r.VacationM,1,12)
    n[4] = self:EncNumb(r.VacationY,1,30)
  end
  n[5]  = self:EncNumb(r.IndWeaponsBl,1,3) + self:EncNumb(r.IndWeaponsWp,4,3) + self:EncNumb(r.IndArmorSh,16,3)
  n[6]  = self:EncNumb(r.IndArmorL,1,3) + self:EncNumb(r.IndArmorM,4,3) + self:EncNumb(r.IndArmorH,16,3)
  n[7]  = self:EncBool(r.Enchant,1) + self:EncBool(r.Alchemy,2) + self:EncNumb(r.IndProvision,4,3) + self:EncNumb(r.IndArmorJ,16,3)
  n[8]  = self:EncNumb(r.IndPvP,1,6) + self:EncBool(r.Duelist,8) + self:EncBool(r.Emperor,16) + self:EncBool(r.Discord,32)
  n[9], n[10] = self:EncN2V(r.DuelRank)
  n[11],n[12] = self:EncN2V(r.RaidRank)
  n[13] = self:EncNumb(r.Solo_MSA,1,3) + self:EncNumb(r.Solo_VH,4,3)
  n[14] = self:EncNumb(r.IndAttHeal,1,4) + self:EncNumb(r.IndAttTank,8,4)
  n[15] = self:EncBool(r.FlAttDD,1)
  n[16],n[17],n[18] = self:EncN3V(r.DPS)
--
  n[19] = self:EncNumb(r.DD_AA,1,3) + self:EncNumb(r.DD_SO,4,3) + self:EncNumb(r.DD_HRC,16,3)
  n[20] = self:EncNumb(r.DD_DSA,1,3) + self:EncNumb(r.DD_BRP,4,3)
  n[21] = self:EncNumb(r.DD_MoL,1,x.MoL) + self:EncNumb(r.DD_HoF,8,x.HoF)
  n[22] = self:EncNumb(r.DD_CR,1,x.CR)
  n[23] = self:EncNumb(r.DD_AS,1,x.AS) + self:EncNumb(r.DD_SS,8,x.SS)
  n[24] = self:EncNumb(r.DD_KA,1,x.KA) + self:EncNumb(r.DD_RG,8,x.RG)
  n[25] = self:EncNumb(r.DD_DSR,1,x.DSR) + self:EncNumb(r.DD_SE,8,x.SE)
  n[26] = self:EncNumb(r.DD_LC,1,x.LC) + self:EncNumb(r.DD_OC,8,x.OC)
--
  n[27] = self:EncNumb(r.Heal_AA,1,3) + self:EncNumb(r.Heal_SO,4,3) + self:EncNumb(r.Heal_HRC,16,3)
  n[28] = self:EncNumb(r.Heal_DSA,1,3) + self:EncNumb(r.Heal_BRP,4,3)
  n[29] = self:EncNumb(r.Heal_MoL,1,x.MoL) + self:EncNumb(r.Heal_HoF,8,x.HoF)
  n[30] = self:EncNumb(r.Heal_CR,1,x.CR)
  n[31] = self:EncNumb(r.Heal_AS,1,x.AS) + self:EncNumb(r.Heal_SS,8,x.SS)
  n[32] = self:EncNumb(r.Heal_KA,1,x.KA) + self:EncNumb(r.Heal_RG,8,x.RG)
  n[33] = self:EncNumb(r.Heal_DSR,1,x.DSR) + self:EncNumb(r.Heal_SE,8,x.SE)
  n[34] = self:EncNumb(r.Heal_LC,1,x.LC) + self:EncNumb(r.Heal_OC,8,x.OC)
--
  n[35] = self:EncNumb(r.Tank_AA,1,3) + self:EncNumb(r.Tank_SO,4,3) + self:EncNumb(r.Tank_HRC,16,3)
  n[36] = self:EncNumb(r.Tank_DSA,1,3) + self:EncNumb(r.Tank_BRP,4,3)
  n[37] = self:EncNumb(r.Tank_MoL,1,x.MoL) + self:EncNumb(r.Tank_HoF,8,x.HoF)
  n[38] = self:EncNumb(r.Tank_CR,1,x.CR)
  n[39] = self:EncNumb(r.Tank_AS,1,x.AS) + self:EncNumb(r.Tank_SS,8,x.SS)
  n[40] = self:EncNumb(r.Tank_KA,1,x.KA) + self:EncNumb(r.Tank_RG,8,x.RG)
  n[41] = self:EncNumb(r.Tank_DSR,1,x.DSR) + self:EncNumb(r.Tank_SE,8,x.SE)
  n[42] = self:EncNumb(r.Tank_LC,1,x.LC) + self:EncNumb(r.Tank_OC,8,x.OC)
--> Calc CRC
  n[43], n[44] = self:CalcCRC(42)
--
  local s = self.Pref .. self.EncArr[self.CurVers]
  for i = 1, 44 do s = s .. self.EncArr[n[i]] end
  self.CodeStr = s .. self.Suff
end

--
-- Section 4: Create encode/decode engine
--
function Guild:CreateEncDecEngine()
  local Enc = LibFLEncode(self.Pref, self.Suff, InitRec, EncodeStr, 254)
  -- Version 1 and version 2 initially had an incorrect length of CRC. This should be left for compatibility.
  local Vers = {
    [0] = {CodeStrLen = 27, CRCLen = 18, Decode = DecodeStrV0,},
    [1] = {CodeStrLen = 30, CRCLen = 18, Decode = DecodeStrV1,},
    [2] = {CodeStrLen = 33, CRCLen = 18, Decode = DecodeStrV2,},
    [3] = {CodeStrLen = 36, CRCLen = 27, Decode = DecodeStrV3,},
    [4] = {CodeStrLen = 41, CRCLen = 32, Decode = DecodeStrV4,},
    [5] = {CodeStrLen = 44, CRCLen = 35, Decode = DecodeStrV5,},
    [6] = {CodeStrLen = 47, CRCLen = 38, Decode = DecodeStrV6,},
    [7] = {CodeStrLen = 51, CRCLen = 42, Decode = DecodeStrV7,},
  }
  Enc:SetVersions(Vers)
  return Enc
end

--
-- Section 5: Initialize UI
-- Section 5.1: Initialize ToolTip UI
--
function Guild:UI_TT_Init()
  DBGN_AltTTVamp:SetText(l.Vamp)
  DBGN_AltTTWW:SetText(l.WW)
  DBGN_AltTTForum:SetText(l.Forum)
  --DBGN_AltTTTS:SetText(l.TS)
  DBGN_AltTTDiscord:SetText(l.Discord)
  DBGN_AltTTHouse:SetText(l.House)
  DBGN_AltTTVacationHdr:SetText(l.VacationHdr)
  DBGN_AltTTAttestHdr:SetText(l.AttestHdr)
  DBGN_AltTTCraftHdr:SetText(l.CraftHdr)
  DBGN_AltTTNoteHdr:SetText(l.NoteHdr)
  DBGN_AltTTNoteHdr:SetDimensions(120, 24)

  local u = self.UI_TT
  u.Win       = DBGN_AltTT
  u.OnLineIco = DBGN_AltTTOnLineIco
  u.Account   = DBGN_AltTTAccount
  u.RankIco   = DBGN_AltTTRankIco
  u.Rank      = DBGN_AltTTRank
  u.FlForum   = DBGN_AltTTForum
  --u.FlTS      = DBGN_AltTTTS
  u.FlDiscord = DBGN_AltTTDiscord
  u.FlVamp    = DBGN_AltTTVamp
  u.FlWW      = DBGN_AltTTWW
  u.FlHouse   = DBGN_AltTTHouse
  u.Vacation  = DBGN_AltTTVacationTxt
  u.DDVal     = DBGN_AltTTAttestDDVal
  u.DDAdd     = DBGN_AltTTAttestDDAdd
  u.DDAd2     = DBGN_AltTTAttestDDAd2
  u.DDAd3     = DBGN_AltTTAttestDDAd3
  u.HealVal   = DBGN_AltTTAttestHealVal
  u.HealAdd   = DBGN_AltTTAttestHealAdd
  u.HealAd2   = DBGN_AltTTAttestHealAd2
  u.HealAd3   = DBGN_AltTTAttestHealAd3
  u.TankVal   = DBGN_AltTTAttestTankVal
  u.TankAdd   = DBGN_AltTTAttestTankAdd
  u.TankAd2   = DBGN_AltTTAttestTankAd2
  u.TankAd3   = DBGN_AltTTAttestTankAd3
  u.PvPVal    = DBGN_AltTTAttestPvPVal
  u.PvPAdd    = DBGN_AltTTAttestPvPAdd
  u.DuelVal   = DBGN_AltTTAttestDuelVal
  u.RaidVal   = DBGN_AltTTAttestRaidVal
  u.SoloAdd   = DBGN_AltTTAttestSoloAdd
  u.CraftATxt = DBGN_AltTTCraftArmTxt
  u.CraftBTxt = DBGN_AltTTCraftBagTxt
  u.CraftWTxt = DBGN_AltTTCraftWeapTxt
  u.CraftAIco = DBGN_AltTTCraftArmIco
  u.CraftBTco = DBGN_AltTTCraftBagIco
  u.CraftWTco = DBGN_AltTTCraftWeapIco
  u.Note      = DBGN_AltTTNoteTxt
  u.Error     = DBGN_AltTTNoteError
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
  u.CB.AA  = ZO_ComboBox_ObjectFromContainer(u.AA)
  u.CB.SO  = ZO_ComboBox_ObjectFromContainer(u.SO)
  u.CB.HRC = ZO_ComboBox_ObjectFromContainer(u.HRC)
  u.CB.MoL = ZO_ComboBox_ObjectFromContainer(u.MoL)
  u.CB.HoF = ZO_ComboBox_ObjectFromContainer(u.HoF)
  u.CB.AS  = ZO_ComboBox_ObjectFromContainer(u.AS)
  u.CB.CR  = ZO_ComboBox_ObjectFromContainer(u.CR)
  u.CB.SS  = ZO_ComboBox_ObjectFromContainer(u.SS)

  local arr, x = {}, DBGN.Trial_Max
  arr[1] = l.None
  for i = 1,3 do arr[i+1] = g.AA[i]  end DBGN:InitCB(u.CB.AA,  arr, 4)
  for i = 1,3 do arr[i+1] = g.SO[i]  end DBGN:InitCB(u.CB.SO,  arr, 4)
  for i = 1,3 do arr[i+1] = g.HRC[i] end DBGN:InitCB(u.CB.HRC, arr, 4)
  for i = 1,x.MoL do arr[i+1] = g.MoL[i] end DBGN:InitCB(u.CB.MoL, arr, x.MoL+1)
  for i = 1,x.HoF do arr[i+1] = g.HoF[i] end DBGN:InitCB(u.CB.HoF, arr, x.HoF+1)
  for i = 1,x.AS  do arr[i+1] = g.AS[i]  end DBGN:InitCB(u.CB.AS,  arr, x.AS +1)
  for i = 1,x.CR  do arr[i+1] = g.CR[i]  end DBGN:InitCB(u.CB.CR,  arr, x.CR +1)
  for i = 1,x.SS  do arr[i+1] = g.SS[i]  end DBGN:InitCB(u.CB.SS,  arr, x.SS +1)
end

function Guild:UI_Ed_Init_TrialsL2(u, ctrl)
  u.KA  = GetControl(ctrl,"KA")
  u.RG  = GetControl(ctrl,"RG")
  u.DSR = GetControl(ctrl,"DSR")
  u.SE = GetControl(ctrl,"SE")
  u.LC = GetControl(ctrl,"LC")
  u.OC = GetControl(ctrl,"OC")
  u.DSA = GetControl(ctrl,"DSA")
  u.BRP = GetControl(ctrl,"BRP")
  u.CB.KA  = ZO_ComboBox_ObjectFromContainer(u.KA)
  u.CB.RG  = ZO_ComboBox_ObjectFromContainer(u.RG)
  u.CB.DSR = ZO_ComboBox_ObjectFromContainer(u.DSR)
  u.CB.SE = ZO_ComboBox_ObjectFromContainer(u.SE)
  u.CB.LC = ZO_ComboBox_ObjectFromContainer(u.LC)
  u.CB.OC = ZO_ComboBox_ObjectFromContainer(u.OC)
  u.CB.DSA = ZO_ComboBox_ObjectFromContainer(u.DSA)
  u.CB.BRP = ZO_ComboBox_ObjectFromContainer(u.BRP)

  local arr, x = {}, DBGN.Trial_Max
  arr[1] = l.None
  for i = 1,x.KA  do arr[i+1] = g.KA[i]  end DBGN:InitCB(u.CB.KA,  arr, x.KA +1)
  for i = 1,x.RG  do arr[i+1] = g.RG[i]  end DBGN:InitCB(u.CB.RG,  arr, x.RG +1)
  for i = 1,x.DSR do arr[i+1] = g.DSR[i] end DBGN:InitCB(u.CB.DSR, arr, x.DSR+1)
  for i = 1,x.SE  do arr[i+1] = g.SE[i]  end DBGN:InitCB(u.CB.SE,  arr, x.SE +1)
  for i = 1,x.LC  do arr[i+1] = g.LC[i]  end DBGN:InitCB(u.CB.LC,  arr, x.LC +1)
  for i = 1,x.OC  do arr[i+1] = g.OC[i]  end DBGN:InitCB(u.CB.OC,  arr, x.OC +1)
  for i = 1,2 do arr[i+1] = g.DSA[i] end DBGN:InitCB(u.CB.DSA, arr, 3)
  for i = 1,2 do arr[i+1] = g.BRP[i] end DBGN:InitCB(u.CB.BRP, arr, 3)
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

function Guild:UI_Ed_Init()
  local ico = Ico.Craft
  DBGN_EditTTTitle:SetText(l.EditTitle)
  DBGN_EditTTMainFlHdr:SetText(l.MainFlHdr)
  DBGN_EditTTMainFlForumTxt:SetText(l.Forum)
  --DBGN_EditTTMainFlTSTxt:SetText(l.TS)
  DBGN_EditTTMainFlDiscordTxt:SetText(l.Discord)
  DBGN_EditTTMainFlVampTxt:SetText(l.Vamp)
  DBGN_EditTTMainFlWWTxt:SetText(l.WW)
  DBGN_EditTTMainFlHouseTxt:SetText(l.House)
  DBGN_EditTTVacationHdr:SetText(l.VacationHdr)
  DBGN_EditTTVacationProtectTxt:SetText(l.Protect)
  DBGN_EditTTVacationTxt:SetText(l.Vacation)
  DBGN_EditTTAttestHdr:SetText(l.AttestHdr)
  DBGN_EditTTAttestDuelistTxt:SetText(l.Duelist)
  DBGN_EditTTAttestEmperorTxt:SetText(l.Emperor)
  DBGN_EditTTCraftHdr:SetText(l.CraftHdr)
  DBGN_EditTTCraftWeapIco:SetTexture(ico.Weap)
  DBGN_EditTTCraftWBlIco:SetTexture(ico.WBl)
  DBGN_EditTTCraftWWpIco:SetTexture(ico.WWp)
  DBGN_EditTTCraftArmIco:SetTexture(ico.Arm)
  DBGN_EditTTCraftJewIco:SetTexture(ico.Jew)
  DBGN_EditTTCraftShldIco:SetTexture(ico.Shld)
  DBGN_EditTTCraftBagIco:SetTexture(ico.Bag)
  DBGN_EditTTCraftEnchIco:SetTexture(ico.Ench)
  DBGN_EditTTCraftAlchIco:SetTexture(ico.Alch)
  DBGN_EditTTCraftProvIco:SetTexture(ico.Prov)
  DBGN_EditTTCraftLTxt:SetText(l.ArmL)
  DBGN_EditTTCraftMTxt:SetText(l.ArmM)
  DBGN_EditTTCraftHTxt:SetText(l.ArmH)
  DBGN_EditTTNoteHdr:SetText(l.NoteHdr)

  local u = self.UI_Ed
  u.Win       = DBGN_EditTT
  u.OnLineIco = DBGN_EditTTOnLineIco
  u.Account   = DBGN_EditTTAccount
  u.RankIco   = DBGN_EditTTRankIco
  u.Rank      = DBGN_EditTTRank
  u.FlForum   = DBGN_EditTTMainFlForumChk
  --u.FlTS      = DBGN_EditTTMainFlTSChk
  u.FlDiscord = DBGN_EditTTMainFlDiscordChk
  u.FlVamp    = DBGN_EditTTMainFlVampChk
  u.FlWW      = DBGN_EditTTMainFlWWChk
  u.FlHouse   = DBGN_EditTTMainFlHouseChk
  u.Protect   = DBGN_EditTTVacationProtectChk
  u.VacYY     = DBGN_EditTTVacationYY
  u.VacMM     = DBGN_EditTTVacationMM
  u.VacDD     = DBGN_EditTTVacationDD
  u.DD        = {CB={},Val = DBGN_EditTTAttestDDValText,}
  u.Heal      = {CB={},Val = DBGN_EditTTAttestHealVal,}
  u.Tank      = {CB={},Val = DBGN_EditTTAttestTankVal,}
  u.PvP       = {CB={},Val = DBGN_EditTTAttestPvPVal, Duelist = DBGN_EditTTAttestDuelistChk, Emperor = DBGN_EditTTAttestEmperorChk,}
  u.Duel      = {CB={},Val = DBGN_EditTTAttestDuelValText,}
  u.Raid      = {CB={},Val = DBGN_EditTTAttestRaidValText,}
  u.Solo      = {CB={},MSA = DBGN_EditTTAttestSoloMSA, VH = DBGN_EditTTAttestSoloVH,}
  u.Craft     = {
    CB={},
    WBl   = DBGN_EditTTCraftWBlChk,
    WWp   = DBGN_EditTTCraftWWpChk,
    ArmL  = DBGN_EditTTCraftLChk,
    ArmM  = DBGN_EditTTCraftMChk,
    ArmH  = DBGN_EditTTCraftHChk,
    Shld  = DBGN_EditTTCraftShldChk,
    Jew   = DBGN_EditTTCraftJewChk,
    Ench  = DBGN_EditTTCraftEnchChk,
    Alch  = DBGN_EditTTCraftAlchChk,
    Prov  = DBGN_EditTTCraftProvVal,
  }
  u.bSave     = DBGN_EditTTButtonSave
  u.bCancel   = DBGN_EditTTButtonCancel
  u.ClearText = DBGN_EditTTNoteValText
--
  u.CB.YY = ZO_ComboBox_ObjectFromContainer(u.VacYY)
  u.CB.MM = ZO_ComboBox_ObjectFromContainer(u.VacMM)
  u.CB.DD = ZO_ComboBox_ObjectFromContainer(u.VacDD)
  u.Heal.CB.Val = ZO_ComboBox_ObjectFromContainer(u.Heal.Val) -- DBGN_EditTTAttestHealVal
  u.Tank.CB.Val = ZO_ComboBox_ObjectFromContainer(u.Tank.Val)
  u.PvP.CB.Val  = ZO_ComboBox_ObjectFromContainer(u.PvP.Val)
  u.Solo.CB.MSA = ZO_ComboBox_ObjectFromContainer(u.Solo.MSA)
  u.Solo.CB.VH  = ZO_ComboBox_ObjectFromContainer(u.Solo.VH)
  u.Craft.CB.Prov = ZO_ComboBox_ObjectFromContainer(u.Craft.Prov) -- DBGN_EditTTCraftProvVal

  self:UI_Ed_Init_TrialsL1(u.DD,   DBGN_EditTTAttestDD1)
  self:UI_Ed_Init_TrialsL1(u.Heal, DBGN_EditTTAttestHeal1)
  self:UI_Ed_Init_TrialsL1(u.Tank, DBGN_EditTTAttestTank1)
  self:UI_Ed_Init_TrialsL2(u.DD,   DBGN_EditTTAttestDD2)
  self:UI_Ed_Init_TrialsL2(u.Heal, DBGN_EditTTAttestHeal2)
  self:UI_Ed_Init_TrialsL2(u.Tank, DBGN_EditTTAttestTank2)

  local arr = {}
  arr[1] = l.None

  for i = 1,3 do arr[i+1] = g.MSA[i] end  DBGN:InitCB(u.Solo.CB.MSA, arr, 4)
  for i = 1,3 do arr[i+1] = g.VH[i] end   DBGN:InitCB(u.Solo.CB.VH, arr, 4)
  for i = 1,3 do arr[i+1] = g.Prov[i] end DBGN:InitCB(u.Craft.CB.Prov,arr, 4)
  for i = 1,4 do arr[i+1] = g.Heal[i] end DBGN:InitCB(u.Heal.CB.Val, arr, 5)
  for i = 1,4 do arr[i+1] = g.Tank[i] end DBGN:InitCB(u.Tank.CB.Val, arr, 5)
  for i = 1,5 do arr[i+1] = g.PvP[i] end  DBGN:InitCB(u.PvP.CB.Val,  arr, 6)

  DBGN:InitCB(u.CB.YY, DBGN.ArrayYY, 4)
  for i = 1, 12 do arr[i] = tostring(i) end
  arr[13] = " "
  DBGN:InitCB(u.CB.MM, arr, 13)
  for i = 13, 31 do arr[i] = tostring(i) end
  arr[32] = " "
  DBGN:InitCB(u.CB.DD, arr, 32)

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
  if control == c.Forum then
    if i ~= f.Forum then r, f.Forum = true, i end
--  elseif control == c.TS then
--    if i ~= f.TS then r, f.TS = true, i end
  elseif control == c.Discord then
    if i ~= f.Discord then r, f.Discord = true, i end
  elseif control == c.Vamp then
    if i ~= f.Vamp then r, f.Vamp = true, i end
  elseif control == c.WW then
    if i ~= f.WW then r, f.WW = true, i end
  elseif control == c.House then
    if i ~= f.House then r, f.House = true, i end
-- Trials
  elseif control == c.TrlDung then
    if i ~= f.TrlDung then r, f.TrlDung = true, i end
  elseif control == c.TrlCmp then
    if i ~= f.TrlCmp then r, f.TrlCmp = true, i end
  elseif control == c.TrlVal then
    if i ~= f.TrlVal then r, f.TrlVal = true, i end
-- Attestation
  elseif control == c.HealCmp then
    if i ~= f.HealCmp then r, f.HealCmp = true, i end
  elseif control == c.HealVal then
    if i ~= f.HealVal then r, f.HealVal = true, i end
  elseif control == c.TankCmp then
    if i ~= f.TankCmp then r, f.TankCmp = true, i end
  elseif control == c.TankVal then
    if i ~= f.TankVal then r, f.TankVal = true, i end
  elseif control == c.PvPCmp then
    if i ~= f.PvPCmp then r, f.PvPCmp = true, i end
  elseif control == c.PvPVal then
    if i ~= f.PvPVal then r, f.PvPVal = true, i end
-- Craft
  elseif control == c.ProvCmp then
    if i ~= f.ProvCmp then r, f.ProvCmp = true, i end
  elseif control == c.ProvVal then
    if i ~= f.ProvVal then r, f.ProvVal = true, i end
  elseif control == c.WBlVal then
    if i ~= f.WBlVal then r, f.WBlVal = true, i end
  elseif control == c.WWpVal then
    if i ~= f.WWpVal then r, f.WWpVal = true, i end
  elseif control == c.ShldVal then
    if i ~= f.ShldVal then r, f.ShldVal = true, i end
  elseif control == c.JewVal then
    if i ~= f.JewVal then r, f.JewVal = true, i end
  elseif control == c.EnchVal then
    if i ~= f.EnchVal then r, f.EnchVal = true, i end
  elseif control == c.AlchVal then
    if i ~= f.AlchVal then r, f.AlchVal = true, i end
  elseif control == c.ArmLVal then
    if i ~= f.ArmLVal then r, f.ArmLVal = true, i end
  elseif control == c.ArmMVal then
    if i ~= f.ArmMVal then r, f.ArmMVal = true, i end
  elseif control == c.ArmHVal then
    if i ~= f.ArmHVal then r, f.ArmHVal = true, i end
  end
  if r then DBGN:RefreshRosterFilters() end
end

function Guild:InitUI_Fl_CB(c, f, ctrl, arr, val, max)
--InitCB(control, array, cnt, val, func)
  DBGN:InitCB(ctrl, arr, max, val, function(control, i, v) UI_Fl_OnCBChanged(control, c, f, i) end)
end

function Guild:UI_Fl_WinMove()
  DBGN:MoveWinFilters(self.UI_Fl, DBGN.SV.WinFilters, DBGN.SV.WinFiltersSh, DBGN.SV.WinFiltersPP)
end

function Guild:UI_Fl_Init()
  local u = self.UI_Fl
  local f = DBGN.SV.Filters
  local o = Ico.Craft
  local arr = {}
--> DBGN_FilterWin
  u.Win = CreateControlFromVirtual("DBGN_FilterWin", ZO_GuildRoster, "DBGN_TmplFilterWin")
  u.Win:SetHidden(true)
  DBGN_FilterWinTitle:SetText(l.FilterHdr)
  DBGN:MoveWinFilters(u, DBGN.SV.WinFilters, DBGN.SV.WinFiltersSh, DBGN.SV.WinFiltersPP)
--> DBGN_FilterWin->Main
  DBGN_FilterWinMainHdr:SetText(l.MainFlHdr)
  DBGN_FilterWinMainForumTxt:SetText(l.Forum)
--  DBGN_FilterWinMainTSTxt:SetText(l.TS)
  DBGN_FilterWinMainDiscordTxt:SetText(l.Discord)
  DBGN_FilterWinMainVampTxt:SetText(l.Vamp)
  DBGN_FilterWinMainWWTxt:SetText(l.WW)
  DBGN_FilterWinMainHouseTxt:SetText(l.House)
  u.Forum    = DBGN_FilterWinMainForumVal
--  u.TS       = DBGN_FilterWinMainTSVal
  u.Discord  = DBGN_FilterWinMainDiscordVal
  u.Vamp     = DBGN_FilterWinMainVampVal
  u.WW       = DBGN_FilterWinMainWWVal
  u.House    = DBGN_FilterWinMainHouseVal
  u.CB.Forum = ZO_ComboBox_ObjectFromContainer(u.Forum)
--  u.CB.TS    = ZO_ComboBox_ObjectFromContainer(u.TS   )
  u.CB.Discord = ZO_ComboBox_ObjectFromContainer(u.Discord)
  u.CB.Vamp  = ZO_ComboBox_ObjectFromContainer(u.Vamp )
  u.CB.WW    = ZO_ComboBox_ObjectFromContainer(u.WW   )
  u.CB.House = ZO_ComboBox_ObjectFromContainer(u.House)
--> DBGN_FilterWin->Craft
  DBGN_FilterWinCraftHdr:SetText(l.CraftHdr)
  DBGN_FilterWinCraftWBlIco:SetTexture(o.WBl)
  DBGN_FilterWinCraftWWpIco:SetTexture(o.WWp)
  DBGN_FilterWinCraftJewIco:SetTexture(o.Jew)
  DBGN_FilterWinCraftShldIco:SetTexture(o.Shld)
  DBGN_FilterWinCraftEnchIco:SetTexture(o.Ench)
  DBGN_FilterWinCraftAlchIco:SetTexture(o.Alch)
  DBGN_FilterWinCraftArmLTxt:SetText(l.ArmL)
  DBGN_FilterWinCraftArmMTxt:SetText(l.ArmM)
  DBGN_FilterWinCraftArmHTxt:SetText(l.ArmH)
  DBGN_FilterWinCraftProvIco:SetTexture(o.Prov)
  u.WBlVal  = DBGN_FilterWinCraftWBlVal
  u.WWpVal  = DBGN_FilterWinCraftWWpVal
  u.JewVal  = DBGN_FilterWinCraftJewVal
  u.ShldVal = DBGN_FilterWinCraftShldVal
  u.EnchVal = DBGN_FilterWinCraftEnchVal
  u.AlchVal = DBGN_FilterWinCraftAlchVal
  u.ArmLVal = DBGN_FilterWinCraftArmLVal
  u.ArmMVal = DBGN_FilterWinCraftArmMVal
  u.ArmHVal = DBGN_FilterWinCraftArmHVal
  u.ProvVal = DBGN_FilterWinCraftProvVal
  u.ProvCmp = DBGN_FilterWinCraftProvCmp
  u.CB.WBlVal  = ZO_ComboBox_ObjectFromContainer(u.WBlVal)
  u.CB.WWpVal  = ZO_ComboBox_ObjectFromContainer(u.WWpVal)
  u.CB.JewVal  = ZO_ComboBox_ObjectFromContainer(u.JewVal)
  u.CB.ShldVal = ZO_ComboBox_ObjectFromContainer(u.ShldVal)
  u.CB.EnchVal = ZO_ComboBox_ObjectFromContainer(u.EnchVal)
  u.CB.AlchVal = ZO_ComboBox_ObjectFromContainer(u.AlchVal)
  u.CB.ArmLVal = ZO_ComboBox_ObjectFromContainer(u.ArmLVal)
  u.CB.ArmMVal = ZO_ComboBox_ObjectFromContainer(u.ArmMVal)
  u.CB.ArmHVal = ZO_ComboBox_ObjectFromContainer(u.ArmHVal)
  u.CB.ProvVal = ZO_ComboBox_ObjectFromContainer(u.ProvVal)
  u.CB.ProvCmp = ZO_ComboBox_ObjectFromContainer(u.ProvCmp)
--> DBGN_FilterWin->Attest
  DBGN_FilterWinAttestHdr:SetText(l.AttestHdr)
  DBGN_FilterWinAttestDDTxt:SetText(l.DD)
  u.DDFrom   = DBGN_FilterWinAttestDDValFromText
  u.DDTo     = DBGN_FilterWinAttestDDValToText
  DBGN_FilterWinAttestDuelTxt:SetText(l.Duel)
  u.DuelFrom = DBGN_FilterWinAttestDuelValFromText
  u.DuelTo   = DBGN_FilterWinAttestDuelValToText
  DBGN_FilterWinAttestRaidTxt:SetText(l.Raid)
  u.RaidFrom = DBGN_FilterWinAttestRaidValFromText
  u.RaidTo   = DBGN_FilterWinAttestRaidValToText
  DBGN_FilterWinAttestHealTxt:SetText(l.Heal)
  u.HealCmp = DBGN_FilterWinAttestHealCmp
  u.HealVal = DBGN_FilterWinAttestHealVal
  u.CB.HealCmp = ZO_ComboBox_ObjectFromContainer(u.HealCmp)
  u.CB.HealVal = ZO_ComboBox_ObjectFromContainer(u.HealVal)
  DBGN_FilterWinAttestTankTxt:SetText(l.Tank)
  u.TankCmp = DBGN_FilterWinAttestTankCmp
  u.TankVal = DBGN_FilterWinAttestTankVal
  u.CB.TankCmp = ZO_ComboBox_ObjectFromContainer(u.TankCmp)
  u.CB.TankVal = ZO_ComboBox_ObjectFromContainer(u.TankVal)
  DBGN_FilterWinAttestPvPTxt:SetText(l.PvP)
  u.PvPCmp = DBGN_FilterWinAttestPvPCmp
  u.PvPVal = DBGN_FilterWinAttestPvPVal
  u.CB.PvPCmp = ZO_ComboBox_ObjectFromContainer(u.PvPCmp)
  u.CB.PvPVal = ZO_ComboBox_ObjectFromContainer(u.PvPVal)
--> DBGN_FilterWin->Trials
  DBGN_FilterWinTrialsHdr:SetText(l.TrialsHdr)
  DBGN_FilterWinTrialsDDTxt:SetText(l.DD)
  DBGN_FilterWinTrialsHealTxt:SetText(l.Heal)
  DBGN_FilterWinTrialsTankTxt:SetText(l.Tank)
  u.TrlDD   = DBGN_FilterWinTrialsDDChk
  u.TrlHeal = DBGN_FilterWinTrialsHealChk
  u.TrlTank = DBGN_FilterWinTrialsTankChk
  u.TrlDung = DBGN_FilterWinTrialsDung
  u.TrlCmp  = DBGN_FilterWinTrialsCmp
  u.TrlVal  = DBGN_FilterWinTrialsVal
  u.CB.TrlDung = ZO_ComboBox_ObjectFromContainer(u.TrlDung)
  u.CB.TrlCmp  = ZO_ComboBox_ObjectFromContainer(u.TrlCmp )
  u.CB.TrlVal  = ZO_ComboBox_ObjectFromContainer(u.TrlVal )
--
  ZO_CheckButton_SetCheckState(u.TrlDD    , f.TrlDD  )
  ZO_CheckButton_SetCheckState(u.TrlHeal  , f.TrlHeal)
  ZO_CheckButton_SetCheckState(u.TrlTank  , f.TrlTank)
  ZO_CheckButton_SetToggleFunction(u.TrlDD  ,   function(control, checked) f.TrlDD   = checked;   DBGN:RefreshRosterFilters() end)
  ZO_CheckButton_SetToggleFunction(u.TrlHeal,   function(control, checked) f.TrlHeal = checked;   DBGN:RefreshRosterFilters() end)
  ZO_CheckButton_SetToggleFunction(u.TrlTank,   function(control, checked) f.TrlTank = checked;   DBGN:RefreshRosterFilters() end)
--
  u.DDFrom:SetText(f.DDFrom)
  u.DDTo:SetText(f.DDTo)
  u.DDFrom:SetHandler("OnTextChanged", function(control) UI_Fl_OnTextChanged(control, u, f) end)
  u.DDTo:SetHandler("OnTextChanged", function(control) UI_Fl_OnTextChanged(control, u, f) end)
  u.DuelFrom:SetText(f.DuelFrom)
  u.DuelTo:SetText(f.DuelTo)
  u.DuelFrom:SetHandler("OnTextChanged", function(control) UI_Fl_OnTextChanged(control, u, f) end)
  u.DuelTo:SetHandler("OnTextChanged", function(control) UI_Fl_OnTextChanged(control, u, f) end)
  u.RaidFrom:SetText(f.RaidFrom)
  u.RaidTo:SetText(f.RaidTo)
  u.RaidFrom:SetHandler("OnTextChanged", function(control) UI_Fl_OnTextChanged(control, u, f) end)
  u.RaidTo:SetHandler("OnTextChanged", function(control) UI_Fl_OnTextChanged(control, u, f) end)
--
--Guild:InitUI_Fl_CB(c, f, ctrl, arr, val, max)
  self:InitUI_Fl_CB(u.CB, f, u.CB.Forum  , g.AnyYesNo, f.Forum  , 3)
--  self:InitUI_Fl_CB(u.CB, f, u.CB.TS     , g.AnyYesNo, f.TS     , 3)
  self:InitUI_Fl_CB(u.CB, f, u.CB.Discord, g.AnyYesNo, f.Discord, 3)
  self:InitUI_Fl_CB(u.CB, f, u.CB.Vamp   , g.AnyYesNo, f.Vamp   , 3)
  self:InitUI_Fl_CB(u.CB, f, u.CB.WW     , g.AnyYesNo, f.WW     , 3)
  self:InitUI_Fl_CB(u.CB, f, u.CB.House  , g.AnyYesNo, f.House  , 3)
  self:InitUI_Fl_CB(u.CB, f, u.CB.TrlDung, g.TrlDung , f.TrlDung, #g.TrlDung)
  self:InitUI_Fl_CB(u.CB, f, u.CB.TrlVal , g.TrlVal  , f.TrlVal , 4)
  self:InitUI_Fl_CB(u.CB, f, u.CB.TrlCmp , g.Cmp     , f.TrlCmp , 4)
  self:InitUI_Fl_CB(u.CB, f, u.CB.HealCmp, g.Cmp     , f.HealCmp, 4)
  self:InitUI_Fl_CB(u.CB, f, u.CB.TankCmp, g.Cmp     , f.TankCmp, 4)
  self:InitUI_Fl_CB(u.CB, f, u.CB.PvPCmp , g.Cmp     , f.PvPCmp , 4)
  self:InitUI_Fl_CB(u.CB, f, u.CB.ProvCmp, g.Cmp     , f.ProvCmp, 4)

  self:InitUI_Fl_CB(u.CB, f, u.CB.WBlVal , g.AnyYesNo, f.WBlVal , 3)
  self:InitUI_Fl_CB(u.CB, f, u.CB.WWpVal , g.AnyYesNo, f.WWpVal , 3)
  self:InitUI_Fl_CB(u.CB, f, u.CB.JewVal , g.AnyYesNo, f.JewVal , 3)
  self:InitUI_Fl_CB(u.CB, f, u.CB.ShldVal, g.AnyYesNo, f.ShldVal, 3)
  self:InitUI_Fl_CB(u.CB, f, u.CB.EnchVal, g.AnyYesNo, f.EnchVal, 3)
  self:InitUI_Fl_CB(u.CB, f, u.CB.AlchVal, g.AnyYesNo, f.AlchVal, 3)
  self:InitUI_Fl_CB(u.CB, f, u.CB.ArmLVal, g.AnyYesNo, f.ArmLVal, 3)
  self:InitUI_Fl_CB(u.CB, f, u.CB.ArmMVal, g.AnyYesNo, f.ArmMVal, 3)
  self:InitUI_Fl_CB(u.CB, f, u.CB.ArmHVal, g.AnyYesNo, f.ArmHVal, 3)

  for i = 0,4 do arr[i+1] = g.Heal[i] end self:InitUI_Fl_CB(u.CB, f, u.CB.HealVal, arr, f.HealVal, 5)
  for i = 0,4 do arr[i+1] = g.Tank[i] end self:InitUI_Fl_CB(u.CB, f, u.CB.TankVal, arr, f.TankVal, 5)
  for i = 0,5 do arr[i+1] = g.PvP[i] end  self:InitUI_Fl_CB(u.CB, f, u.CB.PvPVal , arr, f.PvPVal , 6)
  for i = 0,3 do arr[i+1] = g.Prov[i] end self:InitUI_Fl_CB(u.CB, f, u.CB.ProvVal, arr, f.ProvVal, 4)
end

--
-- Section 6: Update UI
-- Section 6.1: Update ToolTip UI
--
local function AddCraftStr(Ind, Mark, Str)
  if Ind < 1 then return Str end
  local s = Mark
  if DBGN.TraitsEnabled then
    s = s .. "-" .. Ind
  end
  if Str == "" then return s end
  return Str .. ", " .. s
end

local function CreateTrialSt1(IndAA, IndSO, IndHRC, IndMoL, IndHoF, IndAS, IndCR)
  local s = ""
  s = DBGN:AddTrialStr(IndAA,  g.AA,  s, CTrials.All)
  s = DBGN:AddTrialStr(IndSO,  g.SO,  s, CTrials.All)
  s = DBGN:AddTrialStr(IndHRC, g.HRC, s, CTrials.All)
  s = DBGN:AddTrialStr(IndMoL, g.MoL, s, CTrials.All)
  s = DBGN:AddTrialStr(IndHoF, g.HoF, s, CTrials.All)
  s = DBGN:AddTrialStr(IndAS,  g.AS,  s, CTrials.AS)
  s = DBGN:AddTrialStr(IndCR,  g.CR,  s, CTrials.CR)
  return s
end

local function CreateTrialSt2(IndSS, IndKA, IndRG, IndDSR, IndSE, IndLC, IndOC)
  local s = ""
  s = DBGN:AddTrialStr(IndSS,  g.SS,  s, CTrials.SS)
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

function Guild:UI_TT_Upd()
  local u,e = self.UI_TT, self.EncTT
  local s,c,r = "",Ico.Craft,e.r
  u.Account:SetText(r.Name)
  u.Rank:SetText(GetFinalGuildRankName(r.guildId, r.rankIndex))
  u.RankIco:SetTexture(GetFinalGuildRankTextureSmall(r.guildId, r.rankIndex))
  if r.OnLine then
    u.OnLineIco:SetTexture(Ico.OnLine)
  else
    u.OnLineIco:SetTexture(Ico.OffLine)
  end
-->
  DBGN:LabelColor(r.Forum,  u.FlForum)
--  DBGN:LabelColor(r.TS,     u.FlTS)
  DBGN:LabelColor(r.Discord,u.FlDiscord)
  DBGN:LabelColor(r.Vamp,   u.FlVamp)
  DBGN:LabelColor(r.WW,     u.FlWW)
  DBGN:LabelColor(r.House,  u.FlHouse)
-->
  if r.Protect == true then s = l.NotDel end
  if r.VacationD ~= 0 and r.VacationM ~= 0 then
    if s ~= "" then s = s .. ", " end
    s = s .. l.VacUntil .. LPad(r.VacationY,2,"0") .. "-" .. LPad(r.VacationM,2,"0") .. "-" .. LPad(r.VacationD,2,"0")
  end
  u.Vacation:SetText(s)
--> Weapon
  s = AddCraftStr(r.IndWeaponsBl, m.WBl, "")
  s = AddCraftStr(r.IndWeaponsWp, m.WWp, s)
  u.CraftWTxt:SetText(s)
  if s ~= "" then
    u.CraftWTco:SetTexture(c.Weap)
  else
    u.CraftWTco:SetTexture(c.Wea1)
  end
--> Armor
  s = AddCraftStr(r.IndArmorL,  l.ArmL, "")
  s = AddCraftStr(r.IndArmorM,  l.ArmM, s)
  s = AddCraftStr(r.IndArmorH,  l.ArmH, s)
  s = AddCraftStr(r.IndArmorSh, m.Shld, s)
  s = AddCraftStr(r.IndArmorJ,  m.Jew, s)
  u.CraftATxt:SetText(s)
  if s ~= "" then
    u.CraftAIco:SetTexture(c.Arm)
  else
    u.CraftAIco:SetTexture(c.Arm1)
  end
--> Bag
  s = ""
  if r.Enchant == true then s = s .. m.Ench end
  if r.Alchemy == true then if s ~= "" then s = s .. ", " end s = s .. m.Alch end
  if r.IndProvision > 0 then
    if s ~= "" then s = s .. ", " end
    s = s .. m.Prov
    if r.IndProvision > 1 then
      s = s .. ": " .. g.Prov[r.IndProvision]
    end
  end
  u.CraftBTxt:SetText(s)
  if s ~= "" then
    u.CraftBTco:SetTexture(c.Bag)
  else
    u.CraftBTco:SetTexture(c.Bag1)
  end
-->
  u.PvPVal:SetText(g.PvP[r.IndPvP])
  DBGN:LabelColor((r.IndPvP>0),u.PvPVal)
  s = ""
  if r.Duelist == true then s = l.Duelist end
  if r.Emperor == true then
    if s ~= "" then s = s .. ", " end
    s = s .. l.Emperor
  end
  u.PvPAdd:SetText(s)
--
  DBGN:LabelColor(r.FlAttDD, u.DDVal)
  if r.FlAttDD ~= true then
    u.DDVal:SetText(l.None)
  elseif r.DPS > 0 then
    u.DDVal:SetText(r.DPS)
  else
    u.DDVal:SetText(l.Unkn)
  end
  u.HealVal:SetText(g.Heal[r.IndAttHeal])
  DBGN:LabelColor((r.IndAttHeal>0), u.HealVal)
  u.TankVal:SetText(g.Tank[r.IndAttTank])
  DBGN:LabelColor((r.IndAttTank>0), u.TankVal)
--
  u.DDAdd:SetText(  CreateTrialSt1(r.DD_AA  ,r.DD_SO  ,r.DD_HRC  ,r.DD_MoL  ,r.DD_HoF  ,r.DD_AS  ,r.DD_CR  ))
  u.HealAdd:SetText(CreateTrialSt1(r.Heal_AA,r.Heal_SO,r.Heal_HRC,r.Heal_MoL,r.Heal_HoF,r.Heal_AS,r.Heal_CR))
  u.TankAdd:SetText(CreateTrialSt1(r.Tank_AA,r.Tank_SO,r.Tank_HRC,r.Tank_MoL,r.Tank_HoF,r.Tank_AS,r.Tank_CR))
  u.DDAd2:SetText(  CreateTrialSt2(r.DD_SS  ,r.DD_KA  ,r.DD_RG  ,r.DD_DSR  ,r.DD_SE  ,r.DD_LC  ,r.DD_OC  ))
  u.HealAd2:SetText(CreateTrialSt2(r.Heal_SS,r.Heal_KA,r.Heal_RG,r.Heal_DSR,r.Heal_SE,r.Heal_LC,r.Heal_OC))
  u.TankAd2:SetText(CreateTrialSt2(r.Tank_SS,r.Tank_KA,r.Tank_RG,r.Tank_DSR,r.Tank_SE,r.Tank_LC,r.Tank_OC))
  u.DDAd3:SetText(  CreateTrialSt3(r.DD_DSA  ,r.DD_BRP  ))
  u.HealAd3:SetText(CreateTrialSt3(r.Heal_DSA,r.Heal_BRP))
  u.TankAd3:SetText(CreateTrialSt3(r.Tank_DSA,r.Tank_BRP))
  u.SoloAdd:SetText(CreateSoloStr(r.Solo_MSA, r.Solo_VH))

  if r.DuelRank == nil or r.DuelRank == 0 then u.DuelVal:SetText("") else u.DuelVal:SetText(r.DuelRank) end
  if r.RaidRank == nil or r.RaidRank == 0 then u.RaidVal:SetText("") else u.RaidVal:SetText(r.RaidRank) end
--
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
  ZO_CheckButton_SetCheckState(u.FlForum, r.Forum)
--  ZO_CheckButton_SetCheckState(u.FlTS   , r.TS)
  ZO_CheckButton_SetCheckState(u.FlDiscord, r.Discord)
  ZO_CheckButton_SetCheckState(u.FlVamp , r.Vamp)
  ZO_CheckButton_SetCheckState(u.FlWW   , r.WW)
  ZO_CheckButton_SetCheckState(u.FlHouse, r.House)
  ZO_CheckButton_SetCheckState(u.Protect, r.Protect)

  DBGN:Set_CB_Val(u.CB.DD, r.VacationD, 1, 31, 32)
  DBGN:Set_CB_Val(u.CB.MM, r.VacationM, 1, 12, 13)
  DBGN:Set_CB_Val(u.CB.YY, r.VacationY - DBGN.YY_Shift, 1, 3, 4)

  if r.FlAttDD then u.DD.Val:SetText(r.DPS) else u.DD.Val:SetText("") end
  if r.DuelRank == nil or r.DuelRank == 0 then u.Duel.Val:SetText("") else u.Duel.Val:SetText(r.DuelRank) end
  if r.RaidRank == nil or r.RaidRank == 0 then u.Raid.Val:SetText("") else u.Raid.Val:SetText(r.RaidRank) end

  local b = u.DD.CB
  DBGN:Set_CB_Val(b.AA , r.DD_AA  + 1, 2, 4, 1)
  DBGN:Set_CB_Val(b.SO , r.DD_SO  + 1, 2, 4, 1)
  DBGN:Set_CB_Val(b.HRC, r.DD_HRC + 1, 2, 4, 1)
  DBGN:Set_CB_Val(b.DSA, r.DD_DSA + 1, 2, 3, 1)
  DBGN:Set_CB_Val(b.BRP, r.DD_BRP + 1, 2, 3, 1)
  DBGN:Set_CB_Val(b.MoL, r.DD_MoL + 1, 2, x.MoL+1, 1)
  DBGN:Set_CB_Val(b.HoF, r.DD_HoF + 1, 2, x.HoF+1, 1)
  DBGN:Set_CB_Val(b.CR , r.DD_CR  + 1, 2, x.CR +1, 1)
  DBGN:Set_CB_Val(b.AS , r.DD_AS  + 1, 2, x.AS +1, 1)
  DBGN:Set_CB_Val(b.SS,  r.DD_SS  + 1, 2, x.SS +1, 1)
  DBGN:Set_CB_Val(b.KA,  r.DD_KA  + 1, 2, x.KA +1, 1)
  DBGN:Set_CB_Val(b.RG,  r.DD_RG  + 1, 2, x.RG +1, 1)
  DBGN:Set_CB_Val(b.DSR, r.DD_DSR + 1, 2, x.DSR+1, 1)
  DBGN:Set_CB_Val(b.SE,  r.DD_SE  + 1, 2, x.SE +1, 1)
  DBGN:Set_CB_Val(b.LC,  r.DD_LC  + 1, 2, x.LC +1, 1)
  DBGN:Set_CB_Val(b.OC,  r.DD_OC  + 1, 2, x.OC +1, 1)

  b = u.Heal.CB
  DBGN:Set_CB_Val(b.Val, r.IndAttHeal + 1, 2, 5, 1)
  DBGN:Set_CB_Val(b.AA , r.Heal_AA  + 1, 2, 4, 1)
  DBGN:Set_CB_Val(b.SO , r.Heal_SO  + 1, 2, 4, 1)
  DBGN:Set_CB_Val(b.HRC, r.Heal_HRC + 1, 2, 4, 1)
  DBGN:Set_CB_Val(b.DSA, r.Heal_DSA + 1, 2, 3, 1)
  DBGN:Set_CB_Val(b.BRP, r.Heal_BRP + 1, 2, 3, 1)
  DBGN:Set_CB_Val(b.MoL, r.Heal_MoL + 1, 2, x.MoL+1, 1)
  DBGN:Set_CB_Val(b.HoF, r.Heal_HoF + 1, 2, x.HoF+1, 1)
  DBGN:Set_CB_Val(b.CR , r.Heal_CR  + 1, 2, x.CR +1, 1)
  DBGN:Set_CB_Val(b.AS , r.Heal_AS  + 1, 2, x.AS +1, 1)
  DBGN:Set_CB_Val(b.SS,  r.Heal_SS  + 1, 2, x.SS +1, 1)
  DBGN:Set_CB_Val(b.KA,  r.Heal_KA  + 1, 2, x.KA +1, 1)
  DBGN:Set_CB_Val(b.RG,  r.Heal_RG  + 1, 2, x.RG +1, 1)
  DBGN:Set_CB_Val(b.DSR, r.Heal_DSR + 1, 2, x.DSR+1, 1)
  DBGN:Set_CB_Val(b.SE,  r.Heal_SE  + 1, 2, x.SE +1, 1)
  DBGN:Set_CB_Val(b.LC,  r.Heal_LC  + 1, 2, x.LC +1, 1)
  DBGN:Set_CB_Val(b.OC,  r.Heal_OC  + 1, 2, x.OC +1, 1)

  b = u.Tank.CB
  DBGN:Set_CB_Val(b.Val, r.IndAttTank + 1, 2, 5, 1)
  DBGN:Set_CB_Val(b.AA , r.Tank_AA  + 1, 2, 4, 1)
  DBGN:Set_CB_Val(b.SO , r.Tank_SO  + 1, 2, 4, 1)
  DBGN:Set_CB_Val(b.HRC, r.Tank_HRC + 1, 2, 4, 1)
  DBGN:Set_CB_Val(b.DSA, r.Tank_DSA + 1, 2, 3, 1)
  DBGN:Set_CB_Val(b.BRP, r.Tank_BRP + 1, 2, 3, 1)
  DBGN:Set_CB_Val(b.MoL, r.Tank_MoL + 1, 2, x.MoL+1, 1)
  DBGN:Set_CB_Val(b.HoF, r.Tank_HoF + 1, 2, x.HoF+1, 1)
  DBGN:Set_CB_Val(b.CR , r.Tank_CR  + 1, 2, x.CR +1, 1)
  DBGN:Set_CB_Val(b.AS , r.Tank_AS  + 1, 2, x.AS +1, 1)
  DBGN:Set_CB_Val(b.SS,  r.Tank_SS  + 1, 2, x.SS +1, 1)
  DBGN:Set_CB_Val(b.KA,  r.Tank_KA  + 1, 2, x.KA +1, 1)
  DBGN:Set_CB_Val(b.RG,  r.Tank_RG  + 1, 2, x.RG +1, 1)
  DBGN:Set_CB_Val(b.DSR, r.Tank_DSR + 1, 2, x.DSR+1, 1)
  DBGN:Set_CB_Val(b.SE,  r.Tank_SE  + 1, 2, x.SE +1, 1)
  DBGN:Set_CB_Val(b.LC,  r.Tank_LC  + 1, 2, x.LC +1, 1)
  DBGN:Set_CB_Val(b.OC,  r.Tank_OC  + 1, 2, x.OC +1, 1)

  DBGN:Set_CB_Val(u.PvP.CB.Val, r.IndPvP + 1, 2, 6, 1)
  DBGN:Set_CB_Val(u.Solo.CB.MSA,r.Solo_MSA + 1, 2, 4, 1)
  DBGN:Set_CB_Val(u.Solo.CB.VH, r.Solo_VH  + 1, 2, 4, 1)

  ZO_CheckButton_SetCheckState(u.PvP.Duelist, r.Duelist)
  ZO_CheckButton_SetCheckState(u.PvP.Emperor, r.Emperor)

  ZO_CheckButton_SetCheckState(u.Craft.WBl , r.IndWeaponsBl)
  ZO_CheckButton_SetCheckState(u.Craft.WWp , r.IndWeaponsWp)
  ZO_CheckButton_SetCheckState(u.Craft.ArmL, r.IndArmorL   )
  ZO_CheckButton_SetCheckState(u.Craft.ArmM, r.IndArmorM   )
  ZO_CheckButton_SetCheckState(u.Craft.ArmH, r.IndArmorH   )
  ZO_CheckButton_SetCheckState(u.Craft.Shld, r.IndArmorSh  )
  ZO_CheckButton_SetCheckState(u.Craft.Jew , r.IndArmorJ   )

  ZO_CheckButton_SetCheckState(u.Craft.Ench, r.Enchant)
  ZO_CheckButton_SetCheckState(u.Craft.Alch, r.Alchemy)
  DBGN:Set_CB_Val(u.Craft.CB.Prov, r.IndProvision + 1, 2, 4, 1)

  u.ClearText:SetText(e:GetStrClear())
end

--
-- Section 7.1: Get values from Edit UI
--
local function Get_Craft_Chk_Val(control, old)
  if ZO_CheckButton_IsChecked(control) then
    if old > 0 and old < 4 then
      return old
    end
    return DBGN.CraftTraitDef
  end
  return 0
end

function Guild:UI_Ed_GetVal()
  local u,r,x = self.UI_Ed,self.EncEd.r,DBGN.Trial_Max
  r.Forum   = ZO_CheckButton_IsChecked(u.FlForum)
--  r.TS      = ZO_CheckButton_IsChecked(u.FlTS)
  r.Discord = ZO_CheckButton_IsChecked(u.FlDiscord)
  r.Vamp    = ZO_CheckButton_IsChecked(u.FlVamp)
  r.WW      = ZO_CheckButton_IsChecked(u.FlWW)
  r.House   = ZO_CheckButton_IsChecked(u.FlHouse)
  r.Protect = ZO_CheckButton_IsChecked(u.Protect)

  r.VacationD = DBGN:Get_CB_Val(u.CB.DD, 1, 31, 0)
  r.VacationM = DBGN:Get_CB_Val(u.CB.MM, 1, 12, 0)
  r.VacationY = DBGN:Get_CB_Val(u.CB.YY, 1, 3,  0)
  if r.VacationY > 0 then r.VacationY = r.VacationY + DBGN.YY_Shift end

  r.FlAttDD = (u.DD.Val:GetText() ~= "")
  if r.FlAttDD then r.DPS = tonumber(u.DD.Val:GetText()) else r.DPS = 0 end

  if u.Duel.Val:GetText() ~= "" then r.DuelRank = tonumber(u.Duel.Val:GetText()) else r.DuelRank = 0 end
  if u.Raid.Val:GetText() ~= "" then r.RaidRank = tonumber(u.Raid.Val:GetText()) else r.RaidRank = 0 end

  r.DD_AA  = DBGN:Get_CB_Val(u.DD.CB.AA,  1, 4, 1) - 1
  r.DD_SO  = DBGN:Get_CB_Val(u.DD.CB.SO,  1, 4, 1) - 1
  r.DD_HRC = DBGN:Get_CB_Val(u.DD.CB.HRC, 1, 4, 1) - 1
  r.DD_DSA = DBGN:Get_CB_Val(u.DD.CB.DSA, 1, 3, 1) - 1
  r.DD_BRP = DBGN:Get_CB_Val(u.DD.CB.BRP, 1, 3, 1) - 1
  r.DD_MoL = DBGN:Get_CB_Val(u.DD.CB.MoL, 1, x.MoL+1, 1) - 1
  r.DD_HoF = DBGN:Get_CB_Val(u.DD.CB.HoF, 1, x.HoF+1, 1) - 1
  r.DD_CR  = DBGN:Get_CB_Val(u.DD.CB.CR,  1, x.CR +1, 1) - 1
  r.DD_AS  = DBGN:Get_CB_Val(u.DD.CB.AS,  1, x.AS +1, 1) - 1
  r.DD_SS  = DBGN:Get_CB_Val(u.DD.CB.SS,  1, x.SS +1, 1) - 1
  r.DD_KA  = DBGN:Get_CB_Val(u.DD.CB.KA,  1, x.KA +1, 1) - 1
  r.DD_RG  = DBGN:Get_CB_Val(u.DD.CB.RG,  1, x.RG +1, 1) - 1
  r.DD_DSR = DBGN:Get_CB_Val(u.DD.CB.DSR, 1, x.DSR+1, 1) - 1
  r.DD_SE  = DBGN:Get_CB_Val(u.DD.CB.SE,  1, x.SE +1, 1) - 1
  r.DD_LC  = DBGN:Get_CB_Val(u.DD.CB.LC,  1, x.LC +1, 1) - 1
  r.DD_OC  = DBGN:Get_CB_Val(u.DD.CB.OC,  1, x.OC +1, 1) - 1

  r.IndAttHeal = DBGN:Get_CB_Val(u.Heal.CB.Val, 1, 5, 1) - 1

  r.Heal_AA  = DBGN:Get_CB_Val(u.Heal.CB.AA,  1, 4, 1) - 1
  r.Heal_SO  = DBGN:Get_CB_Val(u.Heal.CB.SO,  1, 4, 1) - 1
  r.Heal_HRC = DBGN:Get_CB_Val(u.Heal.CB.HRC, 1, 4, 1) - 1
  r.Heal_DSA = DBGN:Get_CB_Val(u.Heal.CB.DSA, 1, 3, 1) - 1
  r.Heal_BRP = DBGN:Get_CB_Val(u.Heal.CB.BRP, 1, 3, 1) - 1
  r.Heal_MoL = DBGN:Get_CB_Val(u.Heal.CB.MoL, 1, x.MoL+1, 1) - 1
  r.Heal_HoF = DBGN:Get_CB_Val(u.Heal.CB.HoF, 1, x.HoF+1, 1) - 1
  r.Heal_CR  = DBGN:Get_CB_Val(u.Heal.CB.CR,  1, x.CR +1, 1) - 1
  r.Heal_AS  = DBGN:Get_CB_Val(u.Heal.CB.AS,  1, x.AS +1, 1) - 1
  r.Heal_SS  = DBGN:Get_CB_Val(u.Heal.CB.SS,  1, x.SS +1, 1) - 1
  r.Heal_KA  = DBGN:Get_CB_Val(u.Heal.CB.KA,  1, x.KA +1, 1) - 1
  r.Heal_RG  = DBGN:Get_CB_Val(u.Heal.CB.RG,  1, x.RG +1, 1) - 1
  r.Heal_DSR = DBGN:Get_CB_Val(u.Heal.CB.DSR, 1, x.DSR+1, 1) - 1
  r.Heal_SE  = DBGN:Get_CB_Val(u.Heal.CB.SE,  1, x.SE +1, 1) - 1
  r.Heal_LC  = DBGN:Get_CB_Val(u.Heal.CB.LC,  1, x.LC +1, 1) - 1
  r.Heal_OC  = DBGN:Get_CB_Val(u.Heal.CB.OC,  1, x.OC +1, 1) - 1

  r.IndAttTank = DBGN:Get_CB_Val(u.Tank.CB.Val, 1, 5, 1) - 1

  r.Tank_AA  = DBGN:Get_CB_Val(u.Tank.CB.AA,  1, 4, 1) - 1
  r.Tank_SO  = DBGN:Get_CB_Val(u.Tank.CB.SO,  1, 4, 1) - 1
  r.Tank_HRC = DBGN:Get_CB_Val(u.Tank.CB.HRC, 1, 4, 1) - 1
  r.Tank_DSA = DBGN:Get_CB_Val(u.Tank.CB.DSA, 1, 3, 1) - 1
  r.Tank_BRP = DBGN:Get_CB_Val(u.Tank.CB.BRP, 1, 3, 1) - 1
  r.Tank_MoL = DBGN:Get_CB_Val(u.Tank.CB.MoL, 1, x.MoL+1, 1) - 1
  r.Tank_HoF = DBGN:Get_CB_Val(u.Tank.CB.HoF, 1, x.HoF+1, 1) - 1
  r.Tank_CR  = DBGN:Get_CB_Val(u.Tank.CB.CR,  1, x.CR +1, 1) - 1
  r.Tank_AS  = DBGN:Get_CB_Val(u.Tank.CB.AS,  1, x.AS +1, 1) - 1
  r.Tank_SS  = DBGN:Get_CB_Val(u.Tank.CB.SS,  1, x.SS +1, 1) - 1
  r.Tank_KA  = DBGN:Get_CB_Val(u.Tank.CB.KA,  1, x.KA +1, 1) - 1
  r.Tank_RG  = DBGN:Get_CB_Val(u.Tank.CB.RG,  1, x.RG +1, 1) - 1
  r.Tank_DSR = DBGN:Get_CB_Val(u.Tank.CB.DSR, 1, x.DSR+1, 1) - 1
  r.Tank_SE  = DBGN:Get_CB_Val(u.Tank.CB.SE,  1, x.SE +1, 1) - 1
  r.Tank_LC  = DBGN:Get_CB_Val(u.Tank.CB.LC,  1, x.LC +1, 1) - 1
  r.Tank_OC  = DBGN:Get_CB_Val(u.Tank.CB.OC,  1, x.OC +1, 1) - 1

  r.IndPvP = DBGN:Get_CB_Val(u.PvP.CB.Val, 1, 6, 1) - 1
  r.Solo_MSA = DBGN:Get_CB_Val(u.Solo.CB.MSA, 1, 4, 1) - 1
  r.Solo_VH  = DBGN:Get_CB_Val(u.Solo.CB.VH,  1, 4, 1) - 1

  r.Duelist = ZO_CheckButton_IsChecked(u.PvP.Duelist)
  r.Emperor = ZO_CheckButton_IsChecked(u.PvP.Emperor)

  r.IndWeaponsBl = Get_Craft_Chk_Val(u.Craft.WBl , r.IndWeaponsBl)
  r.IndWeaponsWp = Get_Craft_Chk_Val(u.Craft.WWp , r.IndWeaponsWp)
  r.IndArmorL    = Get_Craft_Chk_Val(u.Craft.ArmL, r.IndArmorL   )
  r.IndArmorM    = Get_Craft_Chk_Val(u.Craft.ArmM, r.IndArmorM   )
  r.IndArmorH    = Get_Craft_Chk_Val(u.Craft.ArmH, r.IndArmorH   )
  r.IndArmorSh   = Get_Craft_Chk_Val(u.Craft.Shld, r.IndArmorSh  )
  r.IndArmorJ    = Get_Craft_Chk_Val(u.Craft.Jew , r.IndArmorJ   )

  r.Enchant = ZO_CheckButton_IsChecked(u.Craft.Ench)
  r.Alchemy = ZO_CheckButton_IsChecked(u.Craft.Alch)

  r.IndProvision = DBGN:Get_CB_Val(u.Craft.CB.Prov, 1, 4, 1) - 1
  r.ClearText = u.ClearText:GetText()
end

--
-- Section 8: UI Roster Filters
--
function Guild:UI_Fl_Check()
  local r,f=self.EncFl.r,DBGN.SV.Filters
  local function check_yes_no(val, fltr)
    return fltr == 1 or (fltr == 2 and val) or (fltr == 3 and not val)
  end
  local function check_yes_no_n(val, fltr)
    return fltr == 1 or (fltr == 2 and val>0) or (fltr == 3 and val==0)
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
    elseif f.TrlDung == 4 then return tff.MoL[r.DD_MoL]
    elseif f.TrlDung == 5 then return tff.HoF[r.DD_HoF]
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
    elseif f.TrlDung == 4 then return tff.MoL[r.Heal_MoL]
    elseif f.TrlDung == 5 then return tff.HoF[r.Heal_HoF]
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
    elseif f.TrlDung == 4 then return tff.MoL[r.Tank_MoL]
    elseif f.TrlDung == 5 then return tff.HoF[r.Tank_HoF]
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
--> Main Flags
  if not check_yes_no(r.Forum, f.Forum) then return false end
--  if not check_yes_no(r.TS   , f.TS   ) then return false end
  if not check_yes_no(r.Discord, f.Discord) then return false end
  if not check_yes_no(r.Vamp , f.Vamp ) then return false end
  if not check_yes_no(r.WW   , f.WW   ) then return false end
  if not check_yes_no(r.House, f.House) then return false end
--> Attestation
  if not check_numb_min_max(r.DPS, f.DDFrom,  f.DDTo)       then return false end
  if not check_numb_min_max(r.DuelRank,f.DuelFrom,f.DuelTo) then return false end
  if not check_numb_min_max(r.RaidRank,f.RaidFrom,f.RaidTo) then return false end
  if not check_numb_cmp(r.IndAttHeal, f.HealCmp, f.HealVal) then return false end
  if not check_numb_cmp(r.IndAttTank, f.TankCmp, f.TankVal) then return false end
  if not check_numb_cmp(r.IndPvP    , f.PvPCmp , f.PvPVal)  then return false end
--> Trials
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
--> Craft
  if not check_yes_no(r.Enchant, f.EnchVal) then return false end
  if not check_yes_no(r.Alchemy, f.AlchVal) then return false end
  if not check_yes_no_n(r.IndWeaponsBl, f.WBlVal ) then return false end
  if not check_yes_no_n(r.IndWeaponsWp, f.WWpVal ) then return false end
  if not check_yes_no_n(r.IndArmorSh  , f.ShldVal) then return false end
  if not check_yes_no_n(r.IndArmorJ   , f.JewVal ) then return false end
  if not check_yes_no_n(r.IndArmorL   , f.ArmLVal) then return false end
  if not check_yes_no_n(r.IndArmorM   , f.ArmMVal) then return false end
  if not check_yes_no_n(r.IndArmorH   , f.ArmHVal) then return false end
  if not check_numb_cmp(r.IndProvision, f.ProvCmp, f.ProvVal) then return false end
  return true
end

--
-- Section 9: Get guild for regester
--
function DBGN.GetGuildDB()
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