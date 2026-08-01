local MY_MODULE_NAME = "Wheels"
local MY_MODULE_VERSION = 2

local LCC = LibStub('LibCustomTitlesRN')
if not LCC then return end

local MY_MODULE = LCC:RegisterModule(MY_MODULE_NAME, MY_MODULE_VERSION)
if not MY_MODULE then return end

--                      Account   Character  Override    English      German       French   Extra (e.g. color, hidden)
MY_MODULE:RegisterTitle("@Wheel5", nil, 992, {en = "Send Elk"}, {color={"#1BB716", "#137CD8"}})
MY_MODULE:RegisterTitle("@Wheel5", nil, 1921, {en = "Stamblade For Hire"}, {color="#D82912"})
MY_MODULE:RegisterTitle("@Wheel5", nil, 2043, {en = "Will DPS For Potions"}, {color={"#33CCFF","#66FF33"}})
MY_MODULE:RegisterTitle("@Wheel5", nil, 2079, {en = "Immortal Memer"}, {color={"#DCE006","#FCAF14"}})
MY_MODULE:RegisterTitle("@Mapurr", nil, 1728, {en = "Cartographer"}, {color={"#AD99F7", "#9DDCE8"}})
MY_MODULE:RegisterTitle("@Mapurr", nil, 2075, {en = "Cartographer"}, {color={"#AD99F7", "#9DDCE8"}})
--MY_MODULE:RegisterTitle("@Inig0", nil, 92, {en = "Señor"}, {color="#FA8072"})
MY_MODULE:RegisterTitle("@RTG1", nil, 94, {en = "Poggers"}, {color="#3D992D"})

