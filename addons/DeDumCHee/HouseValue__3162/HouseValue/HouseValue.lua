DV = {}
DV.name = "HouseValue"

local houseCosts = {}
houseCosts[1] = 3000 --Mara's Kiss Public House
houseCosts[2] = 3000 --The Rosy Lion
houseCosts[3] = 3000 --The Ebony Flask Inn Room
houseCosts[4] = 11000 --Barbed Hook Private Room
houseCosts[5] = 12000 --Sisters of the Sands Apartment
houseCosts[6] = 13000 --Flaming Nix Deluxe Garret
houseCosts[7] = 54000 --Black Vine Villa
houseCosts[8] = 255000 --Cliffshade
houseCosts[9] = 1025000 --Mathiisen Manor
houseCosts[10] = 40000 --Humblemud
houseCosts[11] = 195000 --The Ample Domicile
houseCosts[12] = 760000 --Stay-Moist Mansion
houseCosts[13] = 45000 --Snugpod
houseCosts[14] = 190000 --Bouldertree Refuge
houseCosts[15] = 780000 --The Gorinir Estate
houseCosts[16] = 56000 --Captain Margaux's Place
houseCosts[17] = 260000 --Ravenhurst
houseCosts[18] = 1015000 --Gardner House
houseCosts[19] = 69000 --Kragenhome
houseCosts[20] = 323000 --Velothi Reverie
houseCosts[21] = 1265000 --Quondam Indorilia
houseCosts[22] = 50000 --Moonmirth House
houseCosts[23] = 335000 --Sleek Creek House
houseCosts[24] = 1275000 --Dawnshadow
houseCosts[25] = 71000 --Cyrodilic Jungle House
houseCosts[26] = 295000 --Domus Phrasticus
houseCosts[27] = 1280000 --Strident Springs Demesne
houseCosts[28] = 60000 --Autumn's-Gate
houseCosts[29] = 280000 --Grymharth's Woe
houseCosts[30] = 1020000 --Old Mistveil Manor
houseCosts[31] = 65000 --Hammerdeath Bungalow
houseCosts[32] = 325000 --Mournoth Keep
houseCosts[33] = 1285000 --Forsaken Stronghold
houseCosts[34] = 73000 --Twin Arches
houseCosts[35] = 320000 --House of the Silent Magnifico
houseCosts[36] = 1295000 --Hunding's Palatial Hall
houseCosts[37] = 3775000 --Serenity Falls Estate
houseCosts[38] = 3780000 --Daggerfall Overlook
houseCosts[39] = 3785000 --Ebonheart Chateau
houseCosts[40] = 0 --Grand Topal Hideaway ***
houseCosts[41] = 0 --Earthtear Cavern ***
houseCosts[42] = 3000 --Saint Delyn Penthouse (Morrowind Chapter)
houseCosts[43] = 1300000 --Amaya Lake Lodge (Morrowind Chapter)
houseCosts[44] = 322000 --Ald Velothi Harbor House (Morrowind Chapter)
houseCosts[45] = 0 --Tel Galen (Morrowind Chapter) ***
houseCosts[46] = 0 --Linchal Grand Manor (Dark Brotherhood DLC) ***
houseCosts[47] = 1000000 --Coldharbour Surreal Estate
houseCosts[48] = 3800000 --Hakkvild’s High Hall (Horns of the Reach DLC)
houseCosts[49] = 250000 --Exorcised Coven Cottage (Witches Festival)
houseCosts[54] = 0 --Pariah's Pinnacle (Orsinium DLC) ***
houseCosts[55] = 0 --The Orbservatory Prior (Clockwork City DLC) ***
houseCosts[56] = 0 --The Erstwhile Sanctuary (Dark Brotherhood DLC) ***
houseCosts[57] = 0 --Princely Dawnlight Palace (Thieves Guild DLC)
houseCosts[58] = 3000 --Golden Gryphon Garret (Summerset Chapter)
houseCosts[59] = 1025000 --Alinor Crest Townhouse (Summerset Chapter)
houseCosts[60] = 0 --Colossal Aldmeri Grotto (Summerset Chapter) ***
houseCosts[61] = 0 --Hunter's Glade (Wolfhunter DLC) ***
houseCosts[62] = 0 --Grand Psijic Villa ***
houseCosts[63] = 0 --Enchanted Snow Globe Home (New Life Festival) ***
houseCosts[64] = 0 --Lakemire Xanmeer Manor (Murkmire DLC) ***
houseCosts[65] = 0 --Frostvault Chasm (Wrathstone DLC) ***
houseCosts[66] = 0 --Elinhir Private Arena (Wrathstone DLC) ***
houseCosts[68] = 3000 --Sugar Bowl Suite (Elsweyr Chapter)
houseCosts[69] = 0 --Jode's Embrace (Elsweyr Chapter) ***
houseCosts[70] = 0 --Hall of the Lunar Champion (Elsweyr Main Story)
houseCosts[71] = 0 --Moon-Sugar Meadow (Scalebreaker DLC) ***
houseCosts[72] = 0 --Wraithhome (Scalebreaker DLC) ***
houseCosts[73] = 0 --Lucky Cat Landing (Dragonhold DLC) ***
houseCosts[74] = 0 --Potentate's Retreat (Dragonhold DLC) ***
houseCosts[75] = 0 --Forgemaster Falls (Harrowstorm DLC) ***
houseCosts[76] = 0 --Thieves' Oasis (Harrowstorm DLC) ***
houseCosts[77] = 3000 --Snowmelt Suite (Greymoor Chapter)
houseCosts[78] = 1050000 --Proudspire Manor (Greymoor Chapter)
houseCosts[79] = 0 --Bastion Sanguinaris ***
houseCosts[80] = 0 --Stillwaters Retreat ***
houseCosts[81] = 0 --Antiquarian's Alpine Gallery
houseCosts[82] = 0 --Shalidor's Shrouded Realm ***
houseCosts[83] = 0 --Stone Eagle Aerie ***
houseCosts[85] = 0 --Kushalit Sanctuary***
houseCosts[86] = 0 --Varlaisvea Ayleid Ruins ***
houseCosts[87] = 3000 --Pilgrim's Rest
houseCosts[88] = 1055000 --Water's Edge
houseCosts[89] = 0 --Pantherfang Chapel ***?

local function addCommas(oldPrice)
  local newPrice = tostring(math.floor(oldPrice)):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
  return newPrice
end

local function numPlaced()

  local fNum = GetNumHouseFurnishingsPlaced(HOUSING_FURNISHING_LIMIT_TYPE_LOW_IMPACT_ITEM)
  if fNum ~= 0 then
    d(fNum)
  else
    d("You are not in a house!")
  end

  -- LibPrice
end

local function getNext()
    local furnitureCost = 0
    local unknownPrices = 0
    local lastID = nil
    for i=0,GetNumHouseFurnishingsPlaced(HOUSING_FURNISHING_LIMIT_TYPE_LOW_IMPACT_ITEM) do
      local nextID = GetNextPlacedHousingFurnitureId(lastID)
      local nextFurnishing = GetPlacedHousingFurnitureInfo(nextID)
      local newLink = GetPlacedFurnitureLink(GetNextPlacedHousingFurnitureId(nextID),LinkStyle)
      local result = LibPrice.ItemLinkToPriceData(newLink)
      lastID = nextID
      if result.ttc ~= nil then
        furnitureCost = furnitureCost + result.ttc.Avg
      else
        unknownPrices = unknownPrices + 1
        --d(nextFurnishing)
      end
    end

    d("Current House: " .. GetCurrentHouseOwner() .. "'s " .. GetZoneNameById(GetHouseZoneId(GetCurrentZoneHouseId())))
    d("House Cost: " .. addCommas(houseCosts[GetCurrentZoneHouseId()]))
    d("Furnishings Cost: ".. addCommas(furnitureCost) .. ". There were " .. unknownPrices .. " items with an unknown price.")
    d("Total Cost: " .. addCommas(houseCosts[GetCurrentZoneHouseId()]+furnitureCost))
end

-- Credit to s0rdrak and PTF for this function
local function CreateHouseList()
    local data = ZO_COLLECTIBLE_DATA_MANAGER:GetAllCollectibleDataObjects() 
    local retHouses = {}
    for i = 1, #data do
      if data[i]:IsHouse() == true then 
        retHouses[data[i]:GetReferenceId()] = data[i]:GetFormattedName()
      end
    end
    return retHouses
end

-- Credit to s0rdrak and PTF for this function
local function listHouses()
  for key, house in pairs(CreateHouseList()) do
    if house ~= nil then
      d(string.format("%d: %s", key, house))
    end
  end
end
SLASH_COMMANDS["/num"] = numPlaced
SLASH_COMMANDS["/gn"] = getNext
SLASH_COMMANDS["/houseids"] = listHouses

local function getHousePrice()
  d(DTPrices.getHouseCost(GetCurrentZoneHouseId()))
end