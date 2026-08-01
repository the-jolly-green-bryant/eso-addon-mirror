local MY_MODULE_NAME = "mattiellosa"
local MY_MODULE_VERSION = 6

local LCC = LibStub('LibCustomTitlesRN')
if not LCC then return end

local MY_MODULE = LCC:RegisterModule(MY_MODULE_NAME, MY_MODULE_VERSION)
if not MY_MODULE then return end

--                      Account           Character  Override    English                                German                                  French                                        Extra (e.g. color, hidden)

MY_MODULE:RegisterTitle("@mattiellosa",     nil,      1892,     {en = "Khajiit Master"                                                                                                  },    {color={"#e3ff00", "#ff0000"}})
MY_MODULE:RegisterTitle("@UnrealEnvy",      nil,      1330,     {en = "Crippling Depression"                                                                                            },    {color={"#2DCAED", "#EFC509"}})
MY_MODULE:RegisterTitle("@UnrealEnvy",      nil,      1140,     {en = "Crippling Depression"                                                                                            },    {color={"#2DCAED", "#EFC509"}})
MY_MODULE:RegisterTitle("@UnrealEnvy",      nil,        92,     {en = "Crippling Depression"                                                                                            },    {color={"#2DCAED", "#EFC509"}})
MY_MODULE:RegisterTitle("@Svhirs",          nil,      1810,     {en = "Rawr xD"                                                                                                         },    {color={"#62D0FF", "#006F9F"}})
MY_MODULE:RegisterTitle("@NotaBob",         nil,        92,     {en = "Pope of Bobianity"                                                                                               },    {color={"#FF84D8", "#E5009C"}})
MY_MODULE:RegisterTitle("@Weea",            nil,        92,     {en = "Vegan God"                                                                                                       },    {color={"#167E16", "#449744"}})
MY_MODULE:RegisterTitle("@Lana_Lane",       nil,        94,     {en = "WonderWoman"                                                                                                     },    {color={"#ffb81c", "#fae100"}})
MY_MODULE:RegisterTitle("@G4l4zon",         nil,        92,     {en = "Mr Long Slong"                                                                                                   },    {color={"#0072ce", "#41b6e6"}})
MY_MODULE:RegisterTitle("@MirkoZ_99",       nil,        92,     {en = "Larss is my lover"                                                                                               },    {color={"#f44242", "#ab3434"}})
MY_MODULE:RegisterTitle("@strepsels",       nil,        92,     {en = "Bannerlord"                                                                                                      },    {color={"#bd3d3d", "#bd3d3d"}})
MY_MODULE:RegisterTitle("@HalfSaw",         nil,        92,     {en = "Pesky Hornet"                                                                                                    },    {color={"#E5E500", "#FFFF00"}})
MY_MODULE:RegisterTitle("@Ellarden",        nil,        2075,   {en = "Immortal Redeemer"                                                                                               },    {color={"#FFFF00", "#FF0000"}})

