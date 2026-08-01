local DBGN = DBGN
DBGN.Convert = {}
local Conv = DBGN.Convert
local RegisteredDstSrc = {}
local RegisteredSrcDst = {}
local MetaTblInd = {
   __index = function(self, key)
     if type(key) == "string" and key == "" then
       local i = DBGN.AvlGuildType[key]
       return i
     end
     return nil
  end
}

function Conv.RegisterConvert(g)
  if type(g) ~= "table" then return 1 end
  if type(g.Src) ~= "string" or g.Src == "" then return 2 end
  if type(g.Dst) ~= "string" or g.Dst == "" then return 3 end
  local nSrc = DBGN.AvlGuildType[g.Src]
  if nSrc == nil then return 4 end
  local nDst = DBGN.AvlGuildType[g.Dst]
  if nDst == nil then return 5 end
  if nSrc == nDst then return 6 end
  if type(g.Convert) ~= "function" then return 7 end
--
  if RegisteredDstSrc[nDst] ~= "table" then RegisteredDstSrc[nDst] = {} end
  RegisteredDstSrc[nDst][nSrc] = g
--
  if RegisteredSrcDst[nSrc] ~= "table" then RegisteredSrcDst[nSrc] = {} end
  RegisteredSrcDst[nSrc][nDst] = g
-- Ok
  return 0
end

function Conv.GetDstTbl(Dst)
  local n = Dst
  if type(n) == "string" and n ~= "" then
    n = DBGN.AvlGuildType[n]
  end
  if type(n) ~= "number" then
    return {}
  end
  local r = RegisteredDstSrc[n]
  if type(r) ~= "table" then
    return {}
  end
  return setmetatable(r, MetaTblInd)
end

function Conv.GetSrcTbl(Src)
  local n = Src
  if type(n) == "string" and n ~= "" then
    n = DBGN.AvlGuildType[n]
  end
  if type(n) ~= "number" then
    return {}
  end
  local r = RegisteredSrcDst[n]
  if type(r) ~= "table" then
    return {}
  end
  return setmetatable(r, MetaTblInd)
end

function Conv.CopySpecialField(s, d)
  if type(s) ~= "table" or type(d) ~= "table" then
    return
  end
  d.guildId   = s.guildId
  d.Name      = s.Name
  d.rankIndex = s.rankIndex
  d.OnLine    = s.OnLine
end

local function DBGN_to_DCGN(r_Src, e_Dst)
  if type(e_Dst) ~= "table" or type(r_Src) ~= "table" then
    return
  end
  local s = r_Src
  local d = e_Dst.r
--
  d.Discord = s.Discord
  d.Vamp = s.Vamp
  d.WW = s.WW
--d.House = s.House
--
  d.CraftBlk = s.IndWeaponsBl > 0 or s.IndArmorH > 0
  d.CraftWWr = s.IndWeaponsWp > 0 or s.IndArmorSh > 0
  d.CraftClt = s.IndArmorL > 0 or s.IndArmorM > 0
  d.CraftEnch = s.Enchant
  d.CraftAlch = s.Alchemy
  d.CraftJew = s.IndArmorJ > 0
  d.CraftProv = s.IndProvision > 0
--  d.CraftAmbr = 0
--
  if s.IndPvP >= 5 then d.PvP_Rank = 3
  elseif s.IndPvP >= 3 then d.PvP_Rank = 2
  elseif s.IndPvP >= 1 then d.PvP_Rank = 1
  end
  d.PvP_Duelist = s.Duelist
  d.PvP_Emperor = s.Emperor
  d.PvP_Duel = s.DuelRank
  d.PvP_Raid = s.RaidRank
--
  d.Solo_MSA = s.Solo_MSA
  d.Solo_VH  = s.Solo_VH
--
  if s.FlAttDD then d.AttestDD = 1 else d.AttestDD = 0 end
  if s.IndAttHeal >= 3 then d.AttestHeal = 3 else d.AttestHeal = s.IndAttHeal end
  if s.IndAttTank >= 3 then d.AttestTank = 3 else d.AttestTank = s.IndAttTank end
  d.DPS = s.DPS
--
  d.DD_AA  = s.DD_AA
  d.DD_SO  = s.DD_SO
  d.DD_HRC = s.DD_HRC
  d.DD_DSA = s.DD_DSA
  d.DD_HoF = s.DD_HoF
  d.DD_MoL = s.DD_MoL
  d.DD_BRP = s.DD_BRP
  d.DD_AS  = s.DD_AS
  d.DD_CR  = s.DD_CR
  d.DD_SS  = s.DD_SS
  d.DD_KA  = s.DD_KA
  d.DD_RG  = s.DD_RG
  d.DD_DSR = s.DD_DSR
  d.DD_SE  = s.DD_SE
  d.DD_LC  = s.DD_LC
  d.DD_OC  = s.DD_OC
--
  d.Heal_AA  = s.Heal_AA
  d.Heal_SO  = s.Heal_SO
  d.Heal_HRC = s.Heal_HRC
  d.Heal_DSA = s.Heal_DSA
  d.Heal_HoF = s.Heal_HoF
  d.Heal_MoL = s.Heal_MoL
  d.Heal_BRP = s.Heal_BRP
  d.Heal_AS  = s.Heal_AS
  d.Heal_CR  = s.Heal_CR
  d.Heal_SS  = s.Heal_SS
  d.Heal_KA  = s.Heal_KA
  d.Heal_RG  = s.Heal_RG
  d.Heal_DSR = s.Heal_DSR
  d.Heal_SE  = s.Heal_SE
  d.Heal_LC  = s.Heal_LC
  d.Heal_OC  = s.Heal_OC
--
  d.Tank_AA  = s.Tank_AA
  d.Tank_SO  = s.Tank_SO
  d.Tank_HRC = s.Tank_HRC
  d.Tank_DSA = s.Tank_DSA
  d.Tank_HoF = s.Tank_HoF
  d.Tank_MoL = s.Tank_MoL
  d.Tank_BRP = s.Tank_BRP
  d.Tank_AS  = s.Tank_AS
  d.Tank_CR  = s.Tank_CR
  d.Tank_SS  = s.Tank_SS
  d.Tank_KA  = s.Tank_KA
  d.Tank_RG  = s.Tank_RG
  d.Tank_DSR = s.Tank_DSR
  d.Tank_SE  = s.Tank_SE
  d.Tank_LC  = s.Tank_LC
  d.Tank_OC  = s.Tank_OC
--
  DBGN.Chk_Trial_Max_DC(d)
end

local function DCGN_to_DBGN(r_Src, e_Dst)
  if type(e_Dst) ~= "table" or type(r_Src) ~= "table" then
    return
  end
  local s = r_Src
  local d = e_Dst.r
--
  d.Discord = s.Discord
  d.Vamp = s.Vamp
  d.WW = s.WW
--d.House = s.House
--
  if s.CraftBlk == true then
    d.IndWeaponsBl = 1
    d.IndArmorH = 1
  end
  if s.CraftWWr == true then
    d.IndWeaponsWp = 1
    d.IndArmorSh = 1
  end
  if s.CraftClt == true then
    d.IndArmorL = 1
    d.IndArmorM = 1
  end
  if s.CraftJew == true then
    d.IndArmorJ = 1
  end
  d.Enchant = s.CraftEnch
  d.Alchemy = s.CraftAlch
  if s.CraftProv == true then
--  s.CraftAmbr
    d.IndProvision = 1
  end
--
  if s.PvP_Rank >= 3 then d.IndPvP = 5
  else d.IndPvP = s.PvP_Rank
  end
  d.Duelist = s.PvP_Duelist
  d.Emperor = s.PvP_Emperor
  d.IndAttHeal = s.AttestHeal
  d.IndAttTank = s.AttestTank
  d.FlAttDD = s.AttestDD > 0

  d.DPS = s.DPS
  d.DuelRank = s.PvP_Duel
  d.RaidRank = s.PvP_Raid
--
  d.DD_AA  = s.DD_AA
  d.DD_SO  = s.DD_SO
  d.DD_HRC = s.DD_HRC
  d.DD_DSA = s.DD_DSA
  d.DD_HoF = s.DD_HoF
  d.DD_MoL = s.DD_MoL
  d.DD_BRP = s.DD_BRP
  d.DD_AS  = s.DD_AS
  d.DD_CR  = s.DD_CR
  d.DD_SS  = s.DD_SS
  d.DD_KA  = s.DD_KA
  d.DD_RG  = s.DD_RG
  d.DD_DSR = s.DD_DSR
  d.DD_SE  = s.DD_SE
  d.DD_LC  = s.DD_LC
  d.DD_OC  = s.DD_OC
--
  d.Heal_AA  = s.Heal_AA
  d.Heal_SO  = s.Heal_SO
  d.Heal_HRC = s.Heal_HRC
  d.Heal_DSA = s.Heal_DSA
  d.Heal_HoF = s.Heal_HoF
  d.Heal_MoL = s.Heal_MoL
  d.Heal_BRP = s.Heal_BRP
  d.Heal_AS  = s.Heal_AS
  d.Heal_CR  = s.Heal_CR
  d.Heal_SS  = s.Heal_SS
  d.Heal_KA  = s.Heal_KA
  d.Heal_RG  = s.Heal_RG
  d.Heal_DSR = s.Heal_DSR
  d.Heal_SE  = s.Heal_SE
  d.Heal_LC  = s.Heal_LC
  d.Heal_OC  = s.Heal_OC
--
  d.Tank_AA  = s.Tank_AA
  d.Tank_SO  = s.Tank_SO
  d.Tank_HRC = s.Tank_HRC
  d.Tank_DSA = s.Tank_DSA
  d.Tank_HoF = s.Tank_HoF
  d.Tank_MoL = s.Tank_MoL
  d.Tank_BRP = s.Tank_BRP
  d.Tank_AS  = s.Tank_AS
  d.Tank_CR  = s.Tank_CR
  d.Tank_SS  = s.Tank_SS
  d.Tank_KA  = s.Tank_KA
  d.Tank_RG  = s.Tank_RG
  d.Tank_DSR = s.Tank_DSR
  d.Tank_SE  = s.Tank_SE
  d.Tank_LC  = s.Tank_LC
  d.Tank_OC  = s.Tank_OC
--
  d.Solo_MSA = s.Solo_MSA
  d.Solo_VH  = s.Solo_VH
--
  DBGN.Chk_Trial_Max_DB(d)
end

function Conv.Reg_DBGN_to_DCGN()
  local g = {}
  g.Src = "DBGN"
  g.Dst = "DCGN"
  g.Convert = DBGN_to_DCGN
  return Conv.RegisterConvert(g)
end

function Conv.Reg_DCGN_to_DBGN()
  local g = {}
  g.Src = "DCGN"
  g.Dst = "DBGN"
  g.Convert = DCGN_to_DBGN
  return Conv.RegisterConvert(g)
end