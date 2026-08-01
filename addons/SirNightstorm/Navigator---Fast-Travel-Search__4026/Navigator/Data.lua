local Nav = Navigator
local Data = Nav.Data or {}

Nav.ZONE_TAMRIEL = 2
Nav.ZONE_CYRODIIL = 181
Nav.ZONE_IMPERIALCITY = 584
Nav.ZONE_IMPERIALSEWERS = 643
Nav.ZONE_ATOLLOFIMMOLATION = 1272
Nav.ZONE_FARGRAVE = 1282
Nav.ZONE_BLACKREACH = 1191
Nav.ZONE_BLACKREACH_ARKTHZANDCAVERN = 1208
Nav.ZONE_BLACKREACH_GREYMOORCAVERNS = 1161
Nav.ZONE_INFINITE_ARCHIVE = 1436
Nav.MAPID_BLACKREACH = 1782

Nav.POI_TRIAL = 1
Nav.POI_ARENA = 2
Nav.POI_WAYSHRINE = 6
Nav.POI_GROUP_DUNGEON = 7

Nav.COLOUR_WHITE = "FFFFFF"
Nav.COLOUR_DISABLED = "666666"
Nav.COLOUR_NORMAL = "C5C29E"
Nav.COLOUR_FRIEND = "E5CC00"
Nav.COLOUR_JUMPABLE = "80C3CA"
Nav.COLOUR_POI = "AAAAAA"
Nav.COLOUR_SUFFIX_NORMAL = "82826F"
Nav.COLOUR_SUFFIX_POI = "777777"
Nav.COLOUR_SUFFIX_DISABLED = "444444"
Nav.COLOUR_COIN = "FFCC33"
Nav.COLOUR_REPEATABLE = "70B8B0"

Nav.REFRESH_NONE = 0
Nav.REFRESH_EXISTING = 1
Nav.REFRESH_REBUILD = 2

--- @class Menu
--- @field items table[]
Nav.Menu = ZO_Object:Subclass()

function Nav.Menu:New()
    local obj = ZO_Object.New(self)
    obj.items = {}
    return obj
end

--- @field labelText string
--- @field callback function
--- @field yPad integer
function Nav.Menu:AddItem(labelText, callback, yPad)
    table.insert(self.items, {
        labelText = labelText,
        callback = callback,
        yPad = yPad
    })
end


-- Trader Locations, copied from Faster Travel by SimonIllyan, XanDDemoX, upyachka, Valandil
---@type table<integer, integer>
Data.traderCounts = { -- nodeIndex -> traders_count
    [  1] = 1, -- Wyrd Tree Wayshrine
    [  6] = 1, -- Lion Guard Redoubt Wayshrine
    [  9] = 1, -- Oldgate Wayshrine
    [ 14] = 1, -- Koeglin Village Wayshrine
    [ 16] = 1, -- Firebrand Keep Wayshrine
    [ 25] = 1, -- Muth Gnaar Hills Wayshrine
    [ 28] = 7, -- Mournhold Wayshrine
    [ 29] = 1, -- Tal'Deic Grounds Wayshrine
    [ 33] = 5, -- Evermore Wayshrine
    [ 36] = 1, -- Bangkorai Pass Wayshrine
    [ 38] = 1, -- Hallin's Stand Wayshrine
    [ 42] = 1, -- Morwha's Bounty Wayshrine
    [ 43] = 5, -- Sentinel Wayshrine
    [ 44] = 1, -- Bergama Wayshrine
    [ 48] = 5, -- Stormhold Wayshrine
    [ 52] = 1, -- Hissmir Wayshrine
    [ 55] = 5, -- Shornhelm Wayshrine
    [ 56] = 7, -- Wayrest Wayshrine
    [ 62] = 5, -- Daggerfall Wayshrine
    [ 65] = 1, -- Davon's Watch Wayshrine
    [ 67] = 5, -- Ebonheart Wayshrine
    [ 76] = 1, -- Kragenmoor Wayshrine
    [ 78] = 1, -- Venomous Fens Wayshrine
    [ 84] = 1, -- Hoarfrost Downs Wayshrine
    [ 87] = 5, -- Windhelm Wayshrine
    [ 90] = 1, -- Voljar Meadery Wayshrine
    [ 92] = 1, -- Fort Amol Wayshrine
    [101] = 1, -- Dra'bul Wayshrine
    [106] = 5, -- Baandari Post Wayshrine
    [107] = 1, -- Valeguard Wayshrine
    [110] = 5, -- Skald's Retreat Wayshrine
    [114] = 1, -- Fallowstone Hall Wayshrine
    [118] = 1, -- Nimalten Wayshrine
    [121] = 5, -- Skywatch Wayshrine
    [131] = 4, -- Hollow City Wayshrine
    [135] = 1, -- Haj Uxith Wayshrine
    [138] = 1, -- Port Hunding Wayshrine
    [142] = 2, -- Mistral Wayshrine
    [143] = 5, -- Marbruk Wayshrine
    [144] = 1, -- Vinedusk Wayshrine
    [146] = 1, -- Court of Contempt Wayshrine
    [147] = 1, -- Greenheart Wayshrine
    [151] = 1, -- Verrant Morass Wayshrine
    [159] = 1, -- Dune Wayshrine
    [162] = 5, -- Rawl'kha Wayshrine
    [167] = 1, -- Southpoint Wayshrine
    [168] = 1, -- Cormount Wayshrine
    [172] = 1, -- Bleakrock Wayshrine
    [173] = 1, -- Dhalmora Wayshrine
    [175] = 1, -- Firsthold Wayshrine
    [177] = 1, -- Vulkhel Guard Wayshrine
    [181] = 1, -- Stonetooth Wayshrine
    [214] = 7, -- Elden Root Wayshrine
    [220] = 7, -- Belkarth Wayshrine
    [240] = 4, -- Morkul Plain Wayshrine
    [244] = 6, -- Orsinium Wayshrine
    [251] = 3, -- Anvil Wayshrine
    [252] = 3, -- Kvatch Wayshrine
    [255] = 7, -- Abah's Landing Wayshrine
    [275] = 3, -- Balmora Wayshrine
    [281] = 3, -- Sadrith Mora Wayshrine
    [284] = 6, -- Vivec City Wayshrine
    [337] = 6, -- Brass Fortress Wayshrine
    [350] = 3, -- Shimmerene Wayshrine
    [355] = 6, -- Alinor Wayshrine
    [356] = 3, -- Lillandril Wayshrine
    [374] = 6, -- Lilmoth Wayshrine
    [382] = 6, -- Rimmen Wayshrine
    [402] = 6, -- Senchal Wayshrine
    [421] = 6, -- Solitude Wayshrine
    [449] = 6, -- Markarth Wayshrine 
    [458] = 6, -- Leyawiin Wayshrine
	[493] = 6, -- Fargrave Wayshrine
    [513] = 6, -- Gonfalon Square Wayshrine
    [529] = 6, -- Vastyr Wayshrine
	[536] = 6, -- Necrom Wayshrine
	[558] = 6, -- Skingrad City Wayshrine
    [598] = 6, -- Sunport Wayshrine
}

Nav.Data = Data