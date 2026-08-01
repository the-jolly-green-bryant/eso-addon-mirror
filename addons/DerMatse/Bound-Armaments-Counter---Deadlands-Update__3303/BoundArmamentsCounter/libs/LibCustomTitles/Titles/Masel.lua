local MY_MODULE_NAME = "Masel"
local MY_MODULE_VERSION = 11

local LCC = LibStub('LibCustomTitlesRN')
if not LCC then return end

local MY_MODULE = LCC:RegisterModule(MY_MODULE_NAME, MY_MODULE_VERSION)
if not MY_MODULE then return end

MY_MODULE:RegisterTitle("@Masel92", nil, 1330, {en = "The Clueless Conqueror"}, {color={"#00FFFF", "#FF8C00"}})
MY_MODULE:RegisterTitle("@Masel92", nil, 92, {en = "Housing Class Rep"}, {color={"#00FFFF", "#FF8C00"}})
MY_MODULE:RegisterTitle("@Porkjet", nil, 1330, {en = "OwO"}, {color={"#5500ff", "#9966ff"}})
MY_MODULE:RegisterTitle("@Guennwyvar", nil, 92, {en = "UwU"}, {color={"#5500ff", "#9966ff"}})
MY_MODULE:RegisterTitle("@Glorious", nil, 92, {en = "Potato Class Rep"}, {color="#8A2BE2"})
MY_MODULE:RegisterTitle("@NefasQS", nil, 92, {en = "Corrupt Class Rep"}, {color="#00CED1"})
MY_MODULE:RegisterTitle("@Quantum.V", nil, 92, {en = "Zerg Magnet"}, {color={"#B22222", "#FFD700"}})
MY_MODULE:RegisterTitle("@GandTheImpaler", nil, 92, {en = "Gand Bless"}, {color="#DAA520"})
MY_MODULE:RegisterTitle("@TheMadDaedra", nil, 92, {en = "Mad"}, {color="#8A2BE2"})
