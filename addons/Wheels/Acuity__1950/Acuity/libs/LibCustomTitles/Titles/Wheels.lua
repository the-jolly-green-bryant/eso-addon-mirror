local MY_MODULE_NAME = "Wheels"
local MY_MODULE_VERSION = 6

local LCC = LibStub('LibCustomTitlesRN')
if not LCC then return end

local MY_MODULE = LCC:RegisterModule(MY_MODULE_NAME, MY_MODULE_VERSION)
if not MY_MODULE then return end

--                      Account   Character  Override    English      German       French   Extra (e.g. color, hidden)
MY_MODULE:RegisterTitle("@Wheel5", nil, 1836, {en = "The Dynamo"}, {color={"#02AAB0", "#00CDAC"}})
MY_MODULE:RegisterTitle("@Wheel5", nil, 992, {en = "Will Code For Gold"}, {color={"#1BB716", "#137CD8"}})
MY_MODULE:RegisterTitle("@Wheel5", nil, 1921, {en = "Stamblade For Hire"}, {color="#D82912"})
MY_MODULE:RegisterTitle("@Wheel5", nil, 2043, {en = "Will DPS For Potions"}, {color={"#33CCFF","#66FF33"}})
MY_MODULE:RegisterTitle("@Wheel5", nil, 2079, {en = "Immortal Memer"}, {color={"#DCE006","#FCAF14"}})
MY_MODULE:RegisterTitle("@Wheel5", nil, 2136, {en = "Bringer of Light"}, {color={"#5625F7","#B825F7"}})
MY_MODULE:RegisterTitle("@Wheel5", nil, 1838, {en = "Tic-Tac Tormentor"}, {color={"#E58D40","#FFE60C"}})
MY_MODULE:RegisterTitle("@Wheel5", nil, 2368, {en = "The Unchained"}, {color={"#db3e0f","#f28a1a"}})
MY_MODULE:RegisterTitle("@Mapurr", nil, 92, {en = "Cartographer"}, {color={"#AD99F7", "#9DDCE8"}})
MY_MODULE:RegisterTitle("@Mapurr", nil, 2075, {en = "Cartographer"}, {color={"#AD99F7", "#9DDCE8"}})
MY_MODULE:RegisterTitle("@RTG1", nil, 1330, {en = "Poggers"}, {color="#3D992D"})
MY_MODULE:RegisterTitle("@LikoXie", nil, 2139, {en = "Ice Poseidon"}, {color="#00FFFF"})

