--[[
    ______  ___              ________            ______    ________       _____
    ___   |/  /_____ __________  ___/___________ ___  /_______  __ \_____ __  /______ _
    __  /|_/ /_  __ `/__  __ \____ \_  ___/  __ `/_  /_  _ \_  / / /  __ `/  __/  __ `/
    _  /  / / / /_/ /__  /_/ /___/ // /__ / /_/ /_  / /  __/  /_/ // /_/ // /_ / /_/ /
    /_/  /_/  \__,_/ _  .___//____/ \___/ \__,_/ /_/  \___//_____/ \__,_/ \__/ \__,_/
                    /_/

    =======================================
               Map Scale Data
            Proudly Sponsored By
            N'wah Leaf Importers
	=======================================
           @Undyne Keith Mitchell
]]--=======================================
--[[
    Version 1.0 2018-07-24
    Scaling Data for 99 overland maps
    =================================================================
    See Documentation.lua for a deep dive into this data.
]]

-------------------------------
-- Namespace table

MapScaleData = {}

-------------------------------
-- Map Scale Data and Functions

local map_scale_data = 
{
    ["alikr"] = 
    {
        ["alikr_base"] = 1.66812,
        ["sentinel_base"] = 8.10199,
        ["bergama_base"] = 12.55117,
        ["kozanset_base"] = 13.29994,
    },
    ["auridon"] = 
    {
        ["auridon_base"] = 1.69529,
        ["skywatch_base"] = 9.86424,
        ["vulkhelguard_base"] = 8.38130,
        ["khenarthisroost_base"] = 3.34511,
        ["mistral_base"] = 12.30750,
    },
    ["bangkorai"] = 
    {
        ["bangkorai_base"] = 2.06233,
        ["evermore_base"] = 11.95268,
        ["hallinsstand_base"] = 9.50082,
    },
    ["bleakrock"] = 
    {
        ["bleakrockvillage_base"] = 14.74917,
    },
    ["craglorn"] = 
    {
        ["craglorn_base"] = 1.90954,
        ["belkarth_base"] = 13.59135,
        ["craglorn_dragonstar"] = 19.27231,
    },
    ["cyrodiil"] = 
    {
        ["ava_whole"] = 0.66996,
        ["northmorrowgate_base"] = 9.50542,
        ["southmorrowgate_base"] = 9.49598,
        ["northhighrockgate_base"] = 12.43886,
        ["southhighrockgate_base"] = 13.45721,
        ["eastelsweyrgate_base"] = 10.98918,
        ["westelsweyrgate_base"] = 14.79420,
        ["imperialcity_base"] = 6.27587,
    },
    ["darkbrotherhood"] = 
    {
        ["anvilcity_base"] = 11.84699,
        ["kvatchcity_base"] = 15.35481,
        ["goldcoast_base"] = 2.66750,
    },
    ["deshaan"] = 
    {
        ["deshaan_base"] = 1.66297,
        ["mournhold_base"] = 8.11272,
        ["narsis_base"] = 14.06356,
    },
    ["eastmarch"] = 
    {
        ["windhelm_base"] = 12.55584,
        ["eastmarch_base"] = 1.66762,
        ["fortamol_base"] = 13.57423,
    },
    ["glenumbra"] = 
    {
        ["glenumbra_base"] = 1.80448,
        ["daggerfall_base"] = 8.77175,
        ["aldcroft_base"] = 13.44029,
        ["crosswych_base"] = 10.79515,
        ["strosmkai_base"] = 4.46051,
        ["porthunding_base"] = 10.67706,
        ["betnihk_base"] = 3.98794,
        ["stonetoothfortress_base"] = 11.96764,
    },
    ["grahtwood"] = 
    {
        ["grahtwood_base"] = 1.93204,
        ["eldenrootgroundfloor_base"] = 8.83832,
        ["eldenrootservices_base"] = 30.63275,
        ["eldenrootcrafting_base"] = 36.63666,
        ["haven_base"] = 9.50194,
        ["redfurtradingpost_base"] = 18.84020,
    },
    ["greenshade"] = 
    {
        ["greenshade_base"] = 2.28266,
        ["marbruk_base"] = 15.09091,
        ["woodhearth_base"] = 8.73157,
    },
    ["malabaltor"] = 
    {
        ["malabaltor_base"] = 2.05675,
        ["baandaritradingpost_base"] = 14.04253,
        ["vulkwasten_base"] = 12.51298,
        ["velynharbor_base"] = 9.02624,
    },
    ["murkmire"] = 
    {
        ["murkmire_base"] = 2.64469,
        ["lilmothcity_base"] = 9.90269,
        ["brightthroatvillage_base"] = 24.90971,
        ["deadwatervillage_base"] = 16.30243,
        ["rootwhisper_base"] = 16.47651,
    },
    ["reapersmarch"] = 
    {
        ["reapersmarch_base"] = 2.01936,
        ["rawlkha_base"] = 16.00689,
        ["dune_base"] = 10.24452,
        ["arenthia_base"] = 10.75641,
    },
    ["rivenspire"] = 
    {
        ["rivenspire_base"] = 2.20031,
        ["shornhelm_base"] = 14.23813,
        ["hoarfrost_base"] = 22.68366,
        ["northpoint_base"] = 14.11560,
    },
    ["shadowfen"] = 
    {
        ["shadowfen_base"] = 2.22380,
        ["stormhold_base"] = 14.02599,
        ["altencorimont_base"] = 10.99511,
    },
    ["stonefalls"] = 
    {
        ["bleakrock_base"] = 4.44110,
        ["stonefalls_base"] = 1.87164,
        ["davonswatch_base"] = 9.36359,
        ["ebonheart_base"] = 8.89103,
        ["kragenmoor_base"] = 11.18996,
        ["dhalmora_base"] = 22.55969,
        ["balfoyen_base"] = 5.34065,
    },
    ["stormhaven"] = 
    {
        ["stormhaven_base"] = 1.91167,
        ["wayrest_base"] = 9.66857,
        ["alcairecastle_base"] = 15.33224,
        ["koeglinvillage_base"] = 16.25256,
    },
    ["summerset"] = 
    {
        ["summerset_base"] = 1.21137,
        ["alinor_base"] = 11.68988,
        ["shimmerene_base"] = 8.18430,
        ["lillandrill_base"] = 13.28053,
        ["artaeum_base"] = 4.31084,
    },
    ["therift"] = 
    {
        ["therift_base"] = 1.66852,
        ["riften_base"] = 11.82526,
        ["nimalten_base"] = 9.51310,
        ["shorsstone_base"] = 11.88283,
    },
    ["thievesguild"] = 
    {
        ["hewsbane_base"] = 2.64238,
        ["abahslanding_base"] = 7.54794,
    },
    ["vvardenfell"] = 
    {
        ["vvardenfell_base"] = 1.48353,
        ["viviccity_base"] = 8.44914,
        ["balmora_base"] = 15.51960,
        ["sadrithmora_base"] = 14.59097,
    },
    ["wrothgar"] = 
    {
        ["wrothgar_base"] = 1.90817,
        ["orsinium_base"] = 9.98873,
        ["morkul_base"] = 18.62641,
    },
}

function MapScaleData.hasMapScale(zone, subzone)
    if map_scale_data[zone] and map_scale_data[zone][subzone] then
         return true
    end
    return false
end

function MapScaleData.getMapScale(zone, subzone)
    if type(zone) == "string" and type(subzone) == "string" and map_scale_data[zone] and map_scale_data[zone][subzone] then
        return map_scale_data[zone][subzone]
    end
    return nil
end

-------------------------------
-- Raw Data Functions

function MapScaleData.appendRawData(data_object, zone, subzone, data)
    data_object[zone] = data_object[zone] or {}
    data_object[zone][subzone] = data_object[zone][subzone] or {}
    local _arr = data_object[zone][subzone]
    _arr[#_arr+1] = data
    data_object[zone][subzone] = _arr
end

function MapScaleData.getRawDataCountAndAverage(data_object, zone, subzone)
    data_object[zone] = data_object[zone] or {}
    data_object[zone][subzone] = data_object[zone][subzone] or {}
    local _arr = data_object[zone][subzone]
    local count = 0
    local sum = 0
    for i = 1, #_arr do
        if (type(_arr[i]) == "number") and (_arr[i] > 0) then
            count = count + 1
            sum = sum + _arr[i]
        end
    end
    return count, sum / count
end
