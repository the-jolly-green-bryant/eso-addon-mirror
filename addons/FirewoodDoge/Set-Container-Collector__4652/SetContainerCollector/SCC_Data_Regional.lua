SetContainerCollector = SetContainerCollector or {}
local SCC = SetContainerCollector
SCC.Data = SCC.Data or {}

local RS = SCC.Data.RegisterSets

-- Source: https://en.uesp.net/wiki/Online:Regional_Equipment_Vendors
local ZONE_BAGS = {
  { 118530, "Unknown Alik'r Desert Item", { 47, 283, 284 } },
  { 118531, "Unknown Auridon Item", { 86, 105, 36 } },
  { 118532, "Unknown Bangkorai Item", { 285, 286, 70 } },
  { 118533, "Unknown Coldharbour Item", { 26, 68, 94 } },
  { 118534, "Unknown Deshaan Item", { 292, 34, 293 } },
  { 118535, "Unknown Eastmarch Item", { 56, 27, 21 } },
  { 118536, "Unknown Glenumbra Item", { 65, 58, 107 } },
  { 118537, "Unknown Grahtwood Item", { 57, 69, 287 } },
  { 118538, "Unknown Greenshade Item", { 64, 106, 288 } },
  { 118539, "Unknown Malabal Tor Item", { 289, 99, 30 } },
  { 118540, "Unknown Reaper's March Item", { 290, 90, 114 } },
  { 118541, "Unknown Rift Item", { 294, 20, 135 } },
  { 118542, "Unknown Rivenspire Item", { 98, 60, 282 } },
  { 118543, "Unknown Shadowfen Item", { 66, 187, 62 } },
  { 118544, "Unknown Stonefalls Item", { 31, 49, 291 } },
  { 118545, "Unknown Stormhaven Item", { 22, 112, 93 } },
  { 118546, "Unknown Craglorn Item", { 147, 146, 145 } },
}

for _, entry in ipairs(ZONE_BAGS) do
  RS(entry[1], entry[2], entry[3])
end
