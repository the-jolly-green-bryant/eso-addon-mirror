local MY_MODULE_NAME = "Floliroy"
local MY_MODULE_VERSION = 10

local LCC = LibStub('LibCustomTitlesRN')
if not LCC then return end

local MY_MODULE = LCC:RegisterModule(MY_MODULE_NAME, MY_MODULE_VERSION)
if not MY_MODULE then return end


MY_MODULE:RegisterTitle("@Floliroy", nil, 2075, {en = "Godplar"}, {color={"#F9E259", "#FE2008"}})
MY_MODULE:RegisterTitle("@Floliroy", nil, 92, {en = "Send Nudes"}, {color={"#C71585", "#800080"}})
MY_MODULE:RegisterTitle("@Nixir", nil, 2079, {en = "God's Mercenary", de = "Söldner der Götter", fr ="Mercenaire des Dieux"})
MY_MODULE:RegisterTitle("@Panaa", nil, 92, {en = "|c0000CDTormen|r|cFFFFFFted By Ti|r|cFF0000ck Tock|r", fr = "|c4169E1 Le Handicap Est Ma Passion|r", de = "|cFFFF00Ich mag Schokoladen Kuchen|r"})
MY_MODULE:RegisterTitle("@Panaa", nil, 2136, {en = "|c0000CDBag|r|cFFFFFFuet|r|cFF0000te!|r"})
MY_MODULE:RegisterTitle("@Renard7", nil, 92, {en = "Legendary Renard"}, {color={"#CC6600", "#222222"}})
MY_MODULE:RegisterTitle("@Renard7", nil, 1330, {en = "Guardian of the Galaxy"}, {color={"#73F9E7", "#D5003F"}})
MY_MODULE:RegisterTitle("@KarinFlory", nil, 1838, {en = "Tick-Tock Tormentor", de = "Die Tick-Tack-Peinigerin", fr = "Tourmenteuse des Tic-tac"}, {color={"#FF5625", "#2BE5FB"}})