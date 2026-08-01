SetContainerCollector = SetContainerCollector or {}
local SCC = SetContainerCollector
SCC.Data = SCC.Data or {}

local R = SCC.Data.RegisterSet
local HEAD = EQUIP_TYPE_HEAD
local SHOULDER = EQUIP_TYPE_SHOULDERS

-- Source: https://en.uesp.net/wiki/Online:Elite_Gear_Vendors
local ELITE_SETS = {
  { 87710, "Unidentified Blessing of the Potentates Item", 128 },
  { 87711, "Unidentified Deadly Strike Item", 127 },
  { 87712, "Unidentified Alessian Order Item", 39 },
  { 87713, "Unidentified Durok's Bane Item", 71 },
  { 87714, "Unidentified Crest of Cyrodiil Item", 113 },
  { 87715, "Unidentified Bastion of the Heartland Item", 131 },
  { 87716, "Unidentified Beckoning Steel Item", 52 },
  { 87717, "Unidentified The Juggernaut Item", 63 },
  { 87718, "Unidentified Armor of Truth Item", 96 },
  { 87719, "Unidentified Soldier of Anguish Item", 420 },
  { 87720, "Unidentified Ravager Item", 108 },
  { 87721, "Unidentified Battalion Defender Item", 422 },
  { 87722, "Unidentified Elf Bane Item", 83 },
  { 87723, "Unidentified Wrath of the Imperium Item", 125 },
  { 87724, "Unidentified Grace of the Ancients Item", 126 },
  { 87725, "Unidentified Desert Rose Item", 25 },
  { 87726, "Unidentified Prayer Shawl Item", 55 },
  { 87727, "Unidentified Robes of Onslaught Item", 66 },
  { 87728, "Unidentified Curse Eater Item", 104 },
  { 87729, "Unidentified Almalexia's Mercy Item", 85 },
  { 87730, "Unidentified Noble Duelist's Silks Item", 46 },
  { 87731, "Unidentified Robes of Transmutation Item", 235 },
  { 87732, "Unidentified The Arch-Mage Item", 97 },
  { 87733, "Unidentified Light of Cyrodiil Item", 109 },
  { 87734, "Unidentified Buffer of the Swift Item", 133 },
  { 87735, "Unidentified Eagle Eye Item", 130 },
  { 87736, "Unidentified Vengeance Leech Item", 129 },
  { 87737, "Unidentified Twin Sisters Item", 105 },
  { 87738, "Unidentified Barkskin Item", 28 },
  { 87739, "Unidentified Shield of the Valiant Item", 132 },
  { 87740, "Unidentified Shadow Walker Item", 67 },
  { 87741, "Unidentified Crusader Item", 77 },
  { 87742, "Unidentified Hawk's Eye Item", 100 },
  { 87743, "Unidentified The Morag Tong Item", 50 },
  { 87744, "Unidentified Kyne's Kiss Item", 59 },
  { 87745, "Unidentified Ward of Cyrodiil Item", 111 },
  { 87746, "Unidentified Sentry Item", 89 },
}

for _, entry in ipairs(ELITE_SETS) do
  R(entry[1], entry[2], entry[3])
end

local ELITE_MONSTER = {
  { 198713, "Unidentified Colovian Highlands General Mask", 711, HEAD },
  { 199142, "Unidentified Colovian Highlands General Shoulders", 711, SHOULDER },
  { 198798, "Unidentified Jerall Mountains Warchief Mask", 712, HEAD },
  { 199141, "Unidentified Jerall Mountains Warchief Shoulders", 712, SHOULDER },
  { 198854, "Unidentified Nibenay Bay Battlereeve Mask", 713, HEAD },
  { 199140, "Unidentified Nibenay Bay Battlereeve Shoulders", 713, SHOULDER },
}

for _, entry in ipairs(ELITE_MONSTER) do
  R(entry[1], entry[2], entry[3], entry[4])
end
