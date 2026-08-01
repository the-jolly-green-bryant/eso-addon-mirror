local ls = LibStub
if not ls then return end

local MY_MODULE_NAME = "Titles"
local MY_MODULE_VERSION = 9

local LCC = LibStub('LibCustomTitlesRN')
if not LCC then return end

local MY_MODULE = LCC:RegisterModule(MY_MODULE_NAME, MY_MODULE_VERSION)
if not MY_MODULE then return end

MY_MODULE:RegisterTitle("@sepleen", nil, 1836, {en = "God Gamer"}, {color={"#02AAB0", "#00CDAC"}})
MY_MODULE:RegisterTitle("@JustFrog", nil, 1838, {en = "С фрогом проведешься, трифект наберешься"}, {color={"#E58D40","#FFE60C"}})