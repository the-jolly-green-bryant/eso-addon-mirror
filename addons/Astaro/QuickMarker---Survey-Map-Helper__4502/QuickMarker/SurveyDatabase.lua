-- Survey locations database
-- Coordinates are in centimeters (ESO standard)
-- Format: { x, y, z, name, craft }

local SurveyDatabase = {
    surveys = {
        -- Coordinates collected via /qmcoords command
        -- BANGKORAI (Zone ID: 92)
        { zoneId = 92, x = 143149, y = 10148, z = 198042, name = "Alchemist Survey: Bangkorai", craft = "alchemist", zone = "Bangkorai" },
        { zoneId = 92, x = 180786, y = 7302, z = 273532, name = "Blacksmith Survey: Bangkorai", craft = "blacksmith", zone = "Bangkorai" },
        { zoneId = 92, x = 215050, y = 14914, z = 195174, name = "Clothier Survey: Bangkorai", craft = "clothier", zone = "Bangkorai" },
        { zoneId = 92, x = 197622, y = 10108, z = 125454, name = "Enchanter Survey: Bangkorai", craft = "enchanting", zone = "Bangkorai" },
        { zoneId = 92, x = 178583, y = 7009, z = 298533, name = "Jewelry Crafting Survey: Bangkorai", craft = "jewelry", zone = "Bangkorai" },
        { zoneId = 92, x = 244605, y = 6699, z = 301231, name = "Woodworker Survey: Bangkorai", craft = "woodworking", zone = "Bangkorai" },
		
        -- ALIK'R DESERT (Zone ID: 104)
        { zoneId = 104, x = 277958, y = 12884, z = 206081, name = "Alchemist Survey: Alik'r", craft = "alchemist", zone = "Alik'r" },
        { zoneId = 104, x = 170870, y = 10263, z = 145782, name = "Blacksmith Survey: Alik'r", craft = "blacksmith", zone = "Alik'r" },
		{ zoneId = 104, x = 357484, y = 10794, z = 197167, name = "Clothier Survey: Alik'r", craft = "clothier", zone = "Alik'r" },
        { zoneId = 104, x = 425060, y = 16465, z = 96749, name = "Enchanter Survey: Alik'r", craft = "enchanting", zone = "Alik'r" },
        { zoneId = 104, x = 471585, y = 17984, z = 166377, name = "Jewelry Crafting Survey: Alik'r", craft = "jewelry", zone = "Alik'r" },
        { zoneId = 104, x = 345781, y = 12239, z = 104944, name = "Woodworker Survey: Alik'r", craft = "woodworking", zone = "Alik'r" },

        -- AURIDON (Zone ID: 381)
        { zoneId = 381, x = 207718, y = 11724, z = 160638, name = "Alchemist Survey: Auridon", craft = "alchemist", zone = "Auridon" },
        { zoneId = 381, x = 243663, y = 14350, z = 316714, name = "Blacksmith Survey: Auridon", craft = "blacksmith", zone = "Auridon" },
        { zoneId = 381, x = 152303, y = 10272, z = 318131, name = "Clothier Survey: Auridon", craft = "clothier", zone = "Auridon" },
        { zoneId = 381, x = 168389, y = 17928, z = 155134, name = "Enchanter Survey: Auridon", craft = "enchanting", zone = "Auridon" },
        { zoneId = 381, x = 150666, y = 10268, z = 283324, name = "Jewelry Crafting Survey: Auridon", craft = "jewelry", zone = "Auridon" },
        { zoneId = 381, x = 209041, y = 12555, z = 224720, name = "Woodworker Survey: Auridon", craft = "woodworking", zone = "Auridon" },

        -- BLACKWOOD (Zone ID: 1261)
        { zoneId = 1261, x = 346054, y = 25518, z = 422220, name = "Alchemist Survey: Blackwood", craft = "alchemist", zone = "Blackwood" },
        { zoneId = 1261, x = 234469, y = 30217, z = 348376, name = "Blacksmith Survey: Blackwood", craft = "blacksmith", zone = "Blackwood" },
        { zoneId = 1261, x = 207721, y = 27692, z = 250064, name = "Clothier Survey: Blackwood", craft = "clothier", zone = "Blackwood" },
        { zoneId = 1261, x = 256699, y = 30200, z = 100841, name = "Enchanter Survey: Blackwood", craft = "enchanting", zone = "Blackwood" },
        { zoneId = 1261, x = 338919, y = 26466, z = 303004, name = "Jewelry Crafting Survey: Blackwood", craft = "jewelry", zone = "Blackwood" },
        { zoneId = 1261, x = 159970, y = 29406, z = 121993, name = "Woodworker Survey: Blackwood", craft = "woodworking", zone = "Blackwood" },

        -- DESHAAN (Zone ID: 57)
        { zoneId = 57, x = 93334, y = 13796, z = 221402, name = "Alchemist Survey: Deshaan", craft = "alchemist", zone = "Deshaan" },
        { zoneId = 57, x = 224479, y = 14502, z = 190951, name = "Blacksmith Survey: Deshaan", craft = "blacksmith", zone = "Deshaan" },
        { zoneId = 57, x = 129089, y = 14343, z = 214935, name = "Clothier Survey: Deshaan", craft = "clothier", zone = "Deshaan" },
        { zoneId = 57, x = 349316, y = 10590, z = 185302, name = "Enchanter Survey: Deshaan", craft = "enchanting", zone = "Deshaan" },
        { zoneId = 57, x = 228266, y = 16493, z = 268735, name = "Jewelry Crafting Survey: Deshaan", craft = "jewelry", zone = "Deshaan" },
        { zoneId = 57, x = 288005, y = 10606, z = 242629, name = "Woodworker Survey: Deshaan", craft = "woodworking", zone = "Deshaan" },

        -- EASTMARCH (Zone ID: 101)
        { zoneId = 101, x = 191807, y = 13165, z = 249768, name = "Alchemist Survey: Eastmarch", craft = "alchemist", zone = "Eastmarch" },
        { zoneId = 101, x = 181085, y = 13626, z = 123255, name = "Blacksmith Survey: Eastmarch", craft = "blacksmith", zone = "Eastmarch" },
        { zoneId = 101, x = 311974, y = 13390, z = 252957, name = "Clothier Survey: Eastmarch", craft = "clothier", zone = "Eastmarch" },
        { zoneId = 101, x = 252710, y = 16525, z = 173761, name = "Enchanter Survey: Eastmarch", craft = "enchanting", zone = "Eastmarch" },
        { zoneId = 101, x = 196893, y = 15406, z = 282686, name = "Jewelry Crafting Survey: Eastmarch", craft = "jewelry", zone = "Eastmarch" },
        { zoneId = 101, x = 221064, y = 12833, z = 207306, name = "Woodworker Survey: Eastmarch", craft = "woodworking", zone = "Eastmarch" },

        -- GLENUMBRA (Zone ID: 3)
        { zoneId = 3, x = 127773, y = 11895, z = 218083, name = "Alchemist Survey: Glenumbra", craft = "alchemist", zone = "Glenumbra" },
        { zoneId = 3, x = 135227, y = 10580, z = 344504, name = "Blacksmith Survey: Glenumbra", craft = "blacksmith", zone = "Glenumbra" },
        { zoneId = 3, x = 154003, y = 14687, z = 255981, name = "Clothier Survey: Glenumbra", craft = "clothier", zone = "Glenumbra" },
        { zoneId = 3, x = 265642, y = 12829, z = 148247, name = "Enchanter Survey: Glenumbra", craft = "enchanting", zone = "Glenumbra" },
        { zoneId = 3, x = 82417, y = 10155, z = 225551, name = "Jewelry Crafting Survey: Glenumbra", craft = "jewelry", zone = "Glenumbra" },
        { zoneId = 3, x = 239980, y = 10217, z = 221766, name = "Woodworker Survey: Glenumbra", craft = "woodworking", zone = "Glenumbra" },

        -- GRAHTWOOD (Zone ID: 383)
        { zoneId = 383, x = 252319, y = 13998, z = 186811, name = "Alchemist Survey: Grahtwood", craft = "alchemist", zone = "Grahtwood" },
        { zoneId = 383, x = 305940, y = 14783, z = 216838, name = "Blacksmith Survey: Grahtwood", craft = "blacksmith", zone = "Grahtwood" },
        { zoneId = 383, x = 199205, y = 10874, z = 327413, name = "Clothier Survey: Grahtwood", craft = "clothier", zone = "Grahtwood" },
        { zoneId = 383, x = 149149, y = 10080, z = 256657, name = "Enchanter Survey: Grahtwood", craft = "enchanting", zone = "Grahtwood" },
        { zoneId = 383, x = 175338, y = 18575, z = 191008, name = "Jewelry Crafting Survey: Grahtwood", craft = "jewelry", zone = "Grahtwood" },
        { zoneId = 383, x = 187868, y = 18137, z = 146895, name = "Woodworker Survey: Grahtwood", craft = "woodworking", zone = "Grahtwood" },

        -- GREENSHADE (Zone ID: 108)
        { zoneId = 108, x = 303531, y = 14694, z = 330051, name = "Alchemist Survey: Greenshade", craft = "alchemist", zone = "Greenshade" },
        { zoneId = 108, x = 255086, y = 10419, z = 272116, name = "Blacksmith Survey: Greenshade", craft = "blacksmith", zone = "Greenshade" },
        { zoneId = 108, x = 242579, y = 12068, z = 204241, name = "Clothier Survey: Greenshade", craft = "clothier", zone = "Greenshade" },
        { zoneId = 108, x = 225973, y = 12334, z = 172817, name = "Enchanter Survey: Greenshade", craft = "enchanting", zone = "Greenshade" },
        { zoneId = 108, x = 147489, y = 10066, z = 205663, name = "Jewelry Crafting Survey: Greenshade", craft = "jewelry", zone = "Greenshade" },
        { zoneId = 108, x = 166980, y = 10923, z = 326699, name = "Woodworker Survey: Greenshade", craft = "woodworking", zone = "Greenshade" },

        -- HIGH ISLE (Zone ID: 1318)
        { zoneId = 1318, x = 295529, y = 22956, z = 326633, name = "Alchemist Survey: High Isle", craft = "alchemist", zone = "High Isle" },
        { zoneId = 1318, x = 359037, y = 26493, z = 186867, name = "Blacksmith Survey: High Isle", craft = "blacksmith", zone = "High Isle" },
        { zoneId = 1318, x = 467235, y = 20997, z = 203334, name = "Clothier Survey: High Isle", craft = "clothier", zone = "High Isle" },
        { zoneId = 1318, x = 176365, y = 32759, z = 219862, name = "Enchanter Survey: High Isle", craft = "enchanting", zone = "High Isle" },
        { zoneId = 1318, x = 237406, y = 20118, z = 412399, name = "Jewelry Crafting Survey: High Isle", craft = "jewelry", zone = "High Isle" },
        { zoneId = 1318, x = 152371, y = 28183, z = 279379, name = "Woodworker Survey: High Isle", craft = "woodworking", zone = "High Isle" },

        -- MALABAL TOR (Zone ID: 58)
        { zoneId = 58, x = 352563, y = 18958, z = 99295, name = "Alchemist Survey: Malabal Tor", craft = "alchemist", zone = "Malabal Tor" },
        { zoneId = 58, x = 362401, y = 16078, z = 205017, name = "Blacksmith Survey: Malabal Tor", craft = "blacksmith", zone = "Malabal Tor" },
        { zoneId = 58, x = 182986, y = 14920, z = 248248, name = "Clothier Survey: Malabal Tor", craft = "clothier", zone = "Malabal Tor" },
        { zoneId = 58, x = 282802, y = 14000, z = 302071, name = "Enchanter Survey: Malabal Tor", craft = "enchanting", zone = "Malabal Tor" },
        { zoneId = 58, x = 226613, y = 9552, z = 258454, name = "Jewelry Crafting Survey: Malabal Tor", craft = "jewelry", zone = "Malabal Tor" },
        { zoneId = 58, x = 282030, y = 13188, z = 235011, name = "Woodworker Survey: Malabal Tor", craft = "woodworking", zone = "Malabal Tor" },

        -- NORTHERN ELSWEYR (Zone ID: 1086)
        { zoneId = 1086, x = 300587, y = 36331, z = 190899, name = "Alchemist Survey: Northern Elsweyr", craft = "alchemist", zone = "Northern Elsweyr" },
        { zoneId = 1086, x = 224688, y = 40087, z = 199842, name = "Blacksmith Survey: Northern Elsweyr", craft = "blacksmith", zone = "Northern Elsweyr" },
        { zoneId = 1086, x = 247277, y = 28294, z = 254854, name = "Clothier Survey: Northern Elsweyr", craft = "clothier", zone = "Northern Elsweyr" },
        { zoneId = 1086, x = 306397, y = 34437, z = 175494, name = "Enchanter Survey: Northern Elsweyr", craft = "enchanting", zone = "Northern Elsweyr" },
        { zoneId = 1086, x = 388337, y = 26466, z = 295986, name = "Jewelry Crafting Survey: Northern Elsweyr", craft = "jewelry", zone = "Northern Elsweyr" },
        { zoneId = 1086, x = 330629, y = 27831, z = 313385, name = "Woodworker Survey: Northern Elsweyr", craft = "woodworking", zone = "Northern Elsweyr" },

        -- REAPER'S MARCH (Zone ID: 382)
        { zoneId = 382, x = 76721, y = 12392, z = 130122, name = "Alchemist Survey: Reaper's March", craft = "alchemist", zone = "Reaper's March" },
        { zoneId = 382, x = 191512, y = 18129, z = 82838, name = "Blacksmith Survey: Reaper's March", craft = "blacksmith", zone = "Reaper's March" },
        { zoneId = 382, x = 173427, y = 19692, z = 181996, name = "Clothier Survey: Reaper's March", craft = "clothier", zone = "Reaper's March" },
        { zoneId = 382, x = 87534, y = 16932, z = 252221, name = "Enchanter Survey: Reaper's March", craft = "enchanting", zone = "Reaper's March" },
        { zoneId = 382, x = 59157, y = 16667, z = 186256, name = "Jewelry Crafting Survey: Reaper's March", craft = "jewelry", zone = "Reaper's March" },
        { zoneId = 382, x = 120616, y = 17496, z = 290784, name = "Woodworker Survey: Reaper's March", craft = "woodworking", zone = "Reaper's March" },

        -- RIVENSPIRE (Zone ID: 20)
        { zoneId = 20, x = 341198, y = 10214, z = 154021, name = "Alchemist Survey: Rivenspire", craft = "alchemist", zone = "Rivenspire" },
        { zoneId = 20, x = 306743, y = 18635, z = 243671, name = "Blacksmith Survey: Rivenspire", craft = "blacksmith", zone = "Rivenspire" },
        { zoneId = 20, x = 186521, y = 14111, z = 249032, name = "Clothier Survey: Rivenspire", craft = "clothier", zone = "Rivenspire" },
        { zoneId = 20, x = 283266, y = 17020, z = 184306, name = "Enchanter Survey: Rivenspire", craft = "enchanting", zone = "Rivenspire" },
        { zoneId = 20, x = 301294, y = 10069, z = 89506, name = "Jewelry Crafting Survey: Rivenspire", craft = "jewelry", zone = "Rivenspire" },
        { zoneId = 20, x = 261446, y = 18483, z = 249462, name = "Woodworker Survey: Rivenspire", craft = "woodworking", zone = "Rivenspire" },

        -- SHADOWFEN (Zone ID: 117)
        { zoneId = 117, x = 186323, y = 10099, z = 114371, name = "Alchemist Survey: Shadowfen", craft = "alchemist", zone = "Shadowfen" },
        { zoneId = 117, x = 318058, y = 11222, z = 290237, name = "Blacksmith Survey: Shadowfen", craft = "blacksmith", zone = "Shadowfen" },
        { zoneId = 117, x = 303834, y = 10156, z = 163624, name = "Clothier Survey: Shadowfen", craft = "clothier", zone = "Shadowfen" },
        { zoneId = 117, x = 199456, y = 11113, z = 243624, name = "Enchanter Survey: Shadowfen", craft = "enchanting", zone = "Shadowfen" },
        { zoneId = 117, x = 345484, y = 10558, z = 240641, name = "Jewelry Crafting Survey: Shadowfen", craft = "jewelry", zone = "Shadowfen" },
        { zoneId = 117, x = 252158, y = 10714, z = 238298, name = "Woodworker Survey: Shadowfen", craft = "woodworking", zone = "Shadowfen" },

        -- SOLSTICE (Zone ID: 1502)
        { zoneId = 1502, x = 349583, y = 43078, z = 285058, name = "Alchemist Survey: Solstice", craft = "alchemist", zone = "Solstice" },
        { zoneId = 1502, x = 323447, y = 42556, z = 334629, name = "Blacksmith Survey: Solstice", craft = "blacksmith", zone = "Solstice" },
        { zoneId = 1502, x = 295596, y = 44658, z = 414803, name = "Clothier Survey: Solstice", craft = "clothier", zone = "Solstice" },
        { zoneId = 1502, x = 328213, y = 45046, z = 430965, name = "Enchanter Survey: Solstice", craft = "enchanting", zone = "Solstice" },
        { zoneId = 1502, x = 307530, y = 47405, z = 389397, name = "Jewelry Crafting Survey: Solstice", craft = "jewelry", zone = "Solstice" },
        { zoneId = 1502, x = 264517, y = 44131, z = 248305, name = "Woodworker Survey: Solstice", craft = "woodworking", zone = "Solstice" },

        -- STORMHAVEN (Zone ID: 19)
        { zoneId = 19, x = 338652, y = 10398, z = 208967, name = "Alchemist Survey: Stormhaven", craft = "alchemist", zone = "Stormhaven" },
        { zoneId = 19, x = 179517, y = 12688, z = 232209, name = "Blacksmith Survey: Stormhaven", craft = "blacksmith", zone = "Stormhaven" },
        { zoneId = 19, x = 154287, y = 14667, z = 145050, name = "Clothier Survey: Stormhaven", craft = "clothier", zone = "Stormhaven" },
        { zoneId = 19, x = 181027, y = 15381, z = 154536, name = "Enchanter Survey: Stormhaven", craft = "enchanting", zone = "Stormhaven" },
        { zoneId = 19, x = 152099, y = 11780, z = 194139, name = "Jewelry Crafting Survey: Stormhaven", craft = "jewelry", zone = "Stormhaven" },
        { zoneId = 19, x = 181027, y = 15381, z = 154536, name = "Woodworker Survey: Stormhaven", craft = "woodworking", zone = "Stormhaven" },

        -- STONEFALLS (Zone ID: 41)
        { zoneId = 41, x = 251658, y = 10300, z = 190434, name = "Alchemist Survey: Stonefalls", craft = "alchemist", zone = "Stonefalls" },
        { zoneId = 41, x = 291819, y = 11765, z = 255547, name = "Blacksmith Survey: Stonefalls", craft = "blacksmith", zone = "Stonefalls" },
        { zoneId = 41, x = 163697, y = 13774, z = 206645, name = "Clothier Survey: Stonefalls", craft = "clothier", zone = "Stonefalls" },
        { zoneId = 41, x = 181027, y = 15381, z = 154536, name = "Enchanter Survey: Stonefalls", craft = "enchanting", zone = "Stonefalls" },
        { zoneId = 41, x = 295335, y = 15235, z = 279018, name = "Jewelry Crafting Survey: Stonefalls", craft = "jewelry", zone = "Stonefalls" },
        { zoneId = 41, x = 109520, y = 17500, z = 249735, name = "Woodworker Survey: Stonefalls", craft = "woodworking", zone = "Stonefalls" },

        -- THE RIFT (Zone ID: 103)
        { zoneId = 103, x = 253470, y = 24704, z = 168935, name = "Alchemist Survey: The Rift", craft = "alchemist", zone = "The Rift" },
        { zoneId = 103, x = 372099, y = 26019, z = 222837, name = "Blacksmith Survey: The Rift", craft = "blacksmith", zone = "The Rift" },
        { zoneId = 103, x = 338000, y = 24813, z = 143240, name = "Clothier Survey: The Rift", craft = "clothier", zone = "The Rift" },
        { zoneId = 103, x = 147034, y = 25278, z = 118617, name = "Enchanter Survey: The Rift", craft = "enchanting", zone = "The Rift" },
        { zoneId = 103, x = 407847, y = 20774, z = 168204, name = "Jewelry Crafting Survey: The Rift", craft = "jewelry", zone = "The Rift" },
        { zoneId = 103, x = 285131, y = 25887, z = 134408, name = "Woodworker Survey: The Rift", craft = "woodworking", zone = "The Rift" },

        -- WESTERN SKYRIM (Zone ID: 1160)
        { zoneId = 1160, x = 267113, y = 22178, z = 217800, name = "Alchemist Survey: Western Skyrim", craft = "alchemist", zone = "Western Skyrim" },
        { zoneId = 1160, x = 172763, y = 25636, z = 138859, name = "Blacksmith Survey: Western Skyrim", craft = "blacksmith", zone = "Western Skyrim" },
        { zoneId = 1160, x = 270841, y = 25196, z = 296145, name = "Clothier Survey: Western Skyrim", craft = "clothier", zone = "Western Skyrim" },
        { zoneId = 1160, x = 117033, y = 40314, z = 193218, name = "Enchanter Survey: Western Skyrim", craft = "enchanting", zone = "Western Skyrim" },
        { zoneId = 1160, x = 216699, y = 25546, z = 255038, name = "Jewelry Crafting Survey: Western Skyrim", craft = "jewelry", zone = "Western Skyrim" },
        { zoneId = 1160, x = 344508, y = 23760, z = 251631, name = "Woodworker Survey: Western Skyrim", craft = "woodworking", zone = "Western Skyrim" },

        -- WEST WEALD (Zone ID: 1443)
        { zoneId = 1443, x = 338477, y = 18445, z = 241239, name = "Alchemist Survey: West Weald", craft = "alchemist", zone = "West Weald" },
        { zoneId = 1443, x = 352747, y = 27626, z = 160204, name = "Blacksmith Survey: West Weald", craft = "blacksmith", zone = "West Weald" },
        { zoneId = 1443, x = 196453, y = 22154, z = 291494, name = "Clothier Survey: West Weald", craft = "clothier", zone = "West Weald" },
        { zoneId = 1443, x = 308318, y = 12156, z = 399720, name = "Enchanter Survey: West Weald", craft = "enchanting", zone = "West Weald" },
        { zoneId = 1443, x = 544793, y = 11719, z = 341268, name = "Jewelry Crafting Survey: West Weald", craft = "jewelry", zone = "West Weald" },
        { zoneId = 1443, x = 366280, y = 16247, z = 325983, name = "Woodworker Survey: West Weald", craft = "woodworking", zone = "West Weald" },

        -- VVARDENFELL (Zone ID: 849)
        { zoneId = 849, x = 130443, y = 12737, z = 254826, name = "Alchemist Survey: Vvardenfell", craft = "alchemist", zone = "Vvardenfell" },
        { zoneId = 849, x = 302323, y = 12229, z = 390678, name = "Blacksmith Survey: Vvardenfell", craft = "blacksmith", zone = "Vvardenfell" },
        { zoneId = 849, x = 378601, y = 12923, z = 437849, name = "Clothier Survey: Vvardenfell", craft = "clothier", zone = "Vvardenfell" },
        { zoneId = 849, x = 198170, y = 10961, z = 218441, name = "Enchanter Survey: Vvardenfell", craft = "enchanting", zone = "Vvardenfell" },
        { zoneId = 849, x = 78483, y = 10993, z = 293274, name = "Jewelry Crafting Survey: Vvardenfell", craft = "jewelry", zone = "Vvardenfell" },
        { zoneId = 849, x = 151431, y = 11025, z = 456964, name = "Woodworker Survey: Vvardenfell", craft = "woodworking", zone = "Vvardenfell" },

        -- COLDHARBOUR I (Zone ID: 347)
        { zoneId = 347, x = 215485, y = 9813, z = 339013, name = "Alchemist Survey: Coldharbour I", craft = "alchemist", zone = "Coldharbour" },
        { zoneId = 347, x = 354819, y = 13657, z = 292230, name = "Blacksmith Survey: Coldharbour I", craft = "blacksmith", zone = "Coldharbour" },
        { zoneId = 347, x = 324339, y = 14385, z = 332814, name = "Clothier Survey: Coldharbour I", craft = "clothier", zone = "Coldharbour" },
        { zoneId = 347, x = 145548, y = 14284, z = 274124, name = "Enchanter Survey: Coldharbour I", craft = "enchanting", zone = "Coldharbour" },
        { zoneId = 347, x = 271049, y = 12210, z = 324123, name = "Jewelry Crafting Survey: Coldharbour I", craft = "jewelry", zone = "Coldharbour" },
        { zoneId = 347, x = 232040, y = 17754, z = 225269, name = "Woodworker Survey: Coldharbour I", craft = "woodworking", zone = "Coldharbour" },

        -- COLDHARBOUR II (Zone ID: 347)
        { zoneId = 347, x = 220974, y = 12047, z = 307755, name = "Alchemist Survey: Coldharbour II", craft = "alchemist", zone = "Coldharbour" },
        { zoneId = 347, x = 348547, y = 13917, z = 308685, name = "Blacksmith Survey: Coldharbour II", craft = "blacksmith", zone = "Coldharbour" },
        { zoneId = 347, x = 306566, y = 12711, z = 306765, name = "Clothier Survey: Coldharbour II", craft = "clothier", zone = "Coldharbour" },
        { zoneId = 347, x = 152645, y = 12794, z = 298247, name = "Enchanter Survey: Coldharbour II", craft = "enchanting", zone = "Coldharbour" },
        { zoneId = 347, x = 215504, y = 10364, z = 354667, name = "Jewelry Crafting Survey: Coldharbour II", craft = "jewelry", zone = "Coldharbour" },
        { zoneId = 347, x = 272691, y = 18183, z = 201394, name = "Woodworker Survey: Coldharbour II", craft = "woodworking", zone = "Coldharbour" },

        -- CRAGLORN I (Zone ID: 888)
        { zoneId = 888, x = 205329, y = 28406, z = 230847, name = "Alchemist Survey: Craglorn I", craft = "alchemist", zone = "Craglorn" },
        { zoneId = 888, x = 323806, y = 35744, z = 164876, name = "Blacksmith Survey: Craglorn I", craft = "blacksmith", zone = "Craglorn" },
        { zoneId = 888, x = 246901, y = 31487, z = 220989, name = "Clothier Survey: Craglorn I", craft = "clothier", zone = "Craglorn" },
        { zoneId = 888, x = 289866, y = 31822, z = 216490, name = "Enchanter Survey: Craglorn I", craft = "enchanting", zone = "Craglorn" },
        { zoneId = 888, x = 348392, y = 31867, z = 196109, name = "Jewelry Crafting Survey: Craglorn I", craft = "jewelry", zone = "Craglorn" },
        { zoneId = 888, x = 117071, y = 34461, z = 151489, name = "Woodworker Survey: Craglorn I", craft = "woodworking", zone = "Craglorn" },

        -- CRAGLORN II (Zone ID: 888)
        { zoneId = 888, x = 274040, y = 31539, z = 205067, name = "Alchemist Survey: Craglorn II", craft = "alchemist", zone = "Craglorn" },
        { zoneId = 888, x = 248526, y = 37564, z = 150398, name = "Blacksmith Survey: Craglorn II", craft = "blacksmith", zone = "Craglorn" },
        { zoneId = 888, x = 225213, y = 32804, z = 202480, name = "Clothier Survey: Craglorn II", craft = "clothier", zone = "Craglorn" },
        { zoneId = 888, x = 142656, y = 33828, z = 166866, name = "Enchanter Survey: Craglorn II", craft = "enchanting", zone = "Craglorn" },
        { zoneId = 888, x = 240340, y = 31188, z = 269853, name = "Jewelry Crafting Survey: Craglorn II", craft = "jewelry", zone = "Craglorn" },
        { zoneId = 888, x = 314391, y = 35631, z = 162990, name = "Woodworker Survey: Craglorn II", craft = "woodworking", zone = "Craglorn" },

        -- CRAGLORN III (Zone ID: 888)
        { zoneId = 888, x = 155684, y = 33165, z = 176982, name = "Alchemist Survey: Craglorn III", craft = "alchemist", zone = "Craglorn" },
        { zoneId = 888, x = 238794, y = 35830, z = 189923, name = "Blacksmith Survey: Craglorn III", craft = "blacksmith", zone = "Craglorn" },
        { zoneId = 888, x = 194011, y = 37795, z = 194234, name = "Clothier Survey: Craglorn III", craft = "clothier", zone = "Craglorn" },
        { zoneId = 888, x = 322276, y = 33862, z = 184545, name = "Enchanter Survey: Craglorn III", craft = "enchanting", zone = "Craglorn" },
        { zoneId = 888, x = 208966, y = 30755, z = 223158, name = "Jewelry Crafting Survey: Craglorn III", craft = "jewelry", zone = "Craglorn" },
        { zoneId = 888, x = 233968, y = 31976, z = 211761, name = "Woodworker Survey: Craglorn III", craft = "woodworking", zone = "Craglorn" },

        -- WROTHGAR I (Zone ID: 684)
        { zoneId = 684, x = 196744, y = 15348, z = 295441, name = "Alchemist Survey: Wrothgar I", craft = "alchemist", zone = "Wrothgar" },
        { zoneId = 684, x = 276626, y = 16942, z = 253719, name = "Blacksmith Survey: Wrothgar I", craft = "blacksmith", zone = "Wrothgar" },
        { zoneId = 684, x = 161329, y = 18642, z = 313080, name = "Clothier Survey: Wrothgar I", craft = "clothier", zone = "Wrothgar" },
        { zoneId = 684, x = 186024, y = 21785, z = 334411, name = "Enchanter Survey: Wrothgar I", craft = "enchanting", zone = "Wrothgar" },
        { zoneId = 684, x = 402623, y = 29485, z = 254061, name = "Jewelry Crafting Survey: Wrothgar I", craft = "jewelry", zone = "Wrothgar" },
        { zoneId = 684, x = 326657, y = 14697, z = 161985, name = "Woodworker Survey: Wrothgar I", craft = "woodworking", zone = "Wrothgar" },

        -- WROTHGAR II (Zone ID: 684)
        { zoneId = 684, x = 389763, y = 20314, z = 143749, name = "Alchemist Survey: Wrothgar II", craft = "alchemist", zone = "Wrothgar" },
        { zoneId = 684, x = 291372, y = 24106, z = 274116, name = "Blacksmith Survey: Wrothgar II", craft = "blacksmith", zone = "Wrothgar" },
        { zoneId = 684, x = 281867, y = 15426, z = 241291, name = "Clothier Survey: Wrothgar II", craft = "clothier", zone = "Wrothgar" },
        { zoneId = 684, x = 267265, y = 22522, z = 282497, name = "Enchanter Survey: Wrothgar II", craft = "enchanting", zone = "Wrothgar" },
        { zoneId = 684, x = 269884, y = 15682, z = 254424, name = "Jewelry Crafting Survey: Wrothgar II", craft = "jewelry", zone = "Wrothgar" },
        { zoneId = 684, x = 305203, y = 14736, z = 230214, name = "Woodworker Survey: Wrothgar II", craft = "woodworking", zone = "Wrothgar" },

        -- WROTHGAR III (Zone ID: 684)
        { zoneId = 684, x = 180362, y = 23198, z = 330278, name = "Alchemist Survey: Wrothgar III", craft = "alchemist", zone = "Wrothgar" },
        { zoneId = 684, x = 333303, y = 14490, z = 140642, name = "Blacksmith Survey: Wrothgar III", craft = "blacksmith", zone = "Wrothgar" },
        { zoneId = 684, x = 396869, y = 24263, z = 187018, name = "Clothier Survey: Wrothgar III", craft = "clothier", zone = "Wrothgar" },
        { zoneId = 684, x = 355454, y = 22757, z = 203827, name = "Enchanter Survey: Wrothgar III", craft = "enchanting", zone = "Wrothgar" },
        { zoneId = 684, x = 181941, y = 15838, z = 286544, name = "Jewelry Crafting Survey: Wrothgar III", craft = "jewelry", zone = "Wrothgar" },
        { zoneId = 684, x = 401826, y = 27500, z = 156232, name = "Woodworker Survey: Wrothgar III", craft = "woodworking", zone = "Wrothgar" },

        -- APOCRYPHA (Zone ID: 1413) - Only Alchemy, Clothier, Enchanting
        { zoneId = 1413, x = 239577, y = 71097, z = 193082, name = "Alchemist Survey: Apocrypha", craft = "alchemist", zone = "Apocrypha" },
        { zoneId = 1413, x = 401181, y = 64349, z = 321569, name = "Clothier Survey: Apocrypha", craft = "clothier", zone = "Apocrypha" },
        { zoneId = 1413, x = 358910, y = 64918, z = 198559, name = "Enchanter Survey: Apocrypha", craft = "enchanting", zone = "Apocrypha" },

        -- TELVANNI PENINSULA (Zone ID: 1414) - Only Blacksmith, Jewelry, Woodworking
        { zoneId = 1414, x = 345177, y = 11282, z = 290824, name = "Blacksmith Survey: Telvanni Peninsula", craft = "blacksmith", zone = "Telvanni Peninsula" },
        { zoneId = 1414, x = 275013, y = 14411, z = 350117, name = "Jewelry Crafting Survey: Telvanni Peninsula", craft = "jewelry", zone = "Telvanni Peninsula" },
        { zoneId = 1414, x = 306386, y = 12913, z = 278222, name = "Woodworker Survey: Telvanni Peninsula", craft = "woodworking", zone = "Telvanni Peninsula" },

    },

    -- Detection radius in centimeters (20 meters = 2000 cm)
    detectionRadius = 2000,
}

-- Add survey to database
function SurveyDatabase:Add(zoneId, x, y, z, name, craft, zone)
    table.insert(self.surveys, {
        zoneId = zoneId,
        x = x,
        y = y,
        z = z,
        name = name,
        craft = craft,
        zone = zone
    })
    d("|c00FF00[QuickMarker]|r Survey added: " .. name)
end

-- Find survey near given coordinates
function SurveyDatabase:FindNearby(zoneId, x, y, z)
    local radius2 = self.detectionRadius * self.detectionRadius
    local found = {}

    for _, survey in ipairs(self.surveys) do
        if survey.zoneId == zoneId then
            local dx = x - survey.x
            local dy = y - survey.y
            local dz = z - survey.z
            local distance2 = dx * dx + dy * dy + dz * dz

            if distance2 <= radius2 then
                local distance = math.sqrt(distance2) / 100 -- convert to meters
                table.insert(found, {
                    survey = survey,
                    distance = distance
                })
            end
        end
    end

    -- Sort by distance
    table.sort(found, function(a, b) return a.distance < b.distance end)

    return found
end

-- Get survey info by name
function SurveyDatabase:GetByName(name)
    for _, survey in ipairs(self.surveys) do
        if survey.name == name then
            return survey
        end
    end
    return nil
end

-- Get all surveys for a zone
function SurveyDatabase:GetByZone(zoneId)
    local result = {}
    for _, survey in ipairs(self.surveys) do
        if survey.zoneId == zoneId then
            table.insert(result, survey)
        end
    end
    return result
end

_G["QuickMarker_SurveyDatabase"] = SurveyDatabase
