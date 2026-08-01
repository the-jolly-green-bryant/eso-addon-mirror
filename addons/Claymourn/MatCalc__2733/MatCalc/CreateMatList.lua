--Create Table to store MatList
local MatList = {}
--Create Constants to make reading list easier
--Craft Type Constants
local CLOTHING = 0
local BLACKSMITHING = 1
local WOODWORKING = 2
local JEWELRY_CRAFTING = 3
local ENCHANTING = 4
local ALCHEMY = 5
local PROVISIONING = 6
local TRAIT_MATS = 7
local STYLE_MATS = 8
local FURNISHING_MATS = 9
--Equipment Mat Type Constants
local RAW_MAT = 0
local REFINED_MAT = 1
local IMPROVEMENT_MAT = 2
--ENCHANTING Mat Type Constants
local POTENCY = 0
local ESSENCE = 1
local ASPECT = 2
--ALCHEMY Mat Type Constants
local REAGENT = 0
local SOLVENT = 1
--PROVISIONING Mat Type Constants
local FOOD_INGREDIENTS = 0
local BEVERAGE_INGREDIENTS = 1
local OTHER_INGREDIENTS = 2
--Trait mat Type Constants
local WEAPON = 0
local ARMOR = 1
local JEWELRY = 2
--FURNISHING_MATS PLACEHOLDER
local PLACEHOLDER = 0

-- First, we create a namespace for our addon by declaring a top-level table that will hold everything else.
CreateMatList = {}
 
-- This isn't strictly necessary, but we'll use this string later when registering events.
-- Better to define it in a single place rather than retyping the same string.
CreateMatList.name = "CreateMatList"

function CreateMatList:GetMatList()
    return MatList
end

function CreateMatList.CreateMatList()
    --This is going to be long and painful.
    --start of CLOTHING
    MatList[CLOTHING] = {}
    --start of CLOTHING/RAW_MAT
    MatList[CLOTHING][RAW_MAT] = {}
    --start of RAW_MAT light
    --Raw Jute
    MatList[CLOTHING][RAW_MAT][0] = "812"
    --Raw Flax
    MatList[CLOTHING][RAW_MAT][1] = "4464"
    --Raw Cotton
    MatList[CLOTHING][RAW_MAT][2] = "23129"
    --Raw Spidersilk
    MatList[CLOTHING][RAW_MAT][3] = "23130"
    --Raw Ebonthread
    MatList[CLOTHING][RAW_MAT][4] = "23131"
    --Raw Kreshweed
    MatList[CLOTHING][RAW_MAT][5] = "33217"
    --Raw Ironweed
    MatList[CLOTHING][RAW_MAT][6] = "33218"
    --Raw Silverweed
    MatList[CLOTHING][RAW_MAT][7] = "33219"
    --Raw Void Bloom
    MatList[CLOTHING][RAW_MAT][8] = "33220"
    --Raw Ancestor Silk
    MatList[CLOTHING][RAW_MAT][9] = "71200"
    --end of RAW_MAT light
    --start of RAW_MAT medium
    --Rawhide scraps
    MatList[CLOTHING][RAW_MAT][10] = "793"
    --Hide scraps
    MatList[CLOTHING][RAW_MAT][11] = "4448"
    --Leather scraps
    MatList[CLOTHING][RAW_MAT][12] = "23095"
    --Thick leather scraps
    MatList[CLOTHING][RAW_MAT][13] = "6020"
    --Fell hide scraps
    MatList[CLOTHING][RAW_MAT][14] = "23097"
    --Topgrain hide scraps
    MatList[CLOTHING][RAW_MAT][15] = "23142"
    --Iron hide scraps
    MatList[CLOTHING][RAW_MAT][16] = "23143"
    --Superb hide scraps
    MatList[CLOTHING][RAW_MAT][17] = "800"
    --Shadowhide scraps
    MatList[CLOTHING][RAW_MAT][18] = "4478"
    --Rubedo hide scraps
    MatList[CLOTHING][RAW_MAT][19] = "71239"
    --end of RAW_MAT medium
    --end of CLOTHING/RAW_MAT
    --CLOTHING/REFINED_MAT
    MatList[CLOTHING][REFINED_MAT] = {}
    --start of REFINED_MAT light
    --Jute
    MatList[CLOTHING][REFINED_MAT][0] = "811"
    --Flax
    MatList[CLOTHING][REFINED_MAT][1] = "4463"
    --Cotton
    MatList[CLOTHING][REFINED_MAT][2] = "23125"
    --Spidersilk
    MatList[CLOTHING][REFINED_MAT][3] = "23126"
    --Ebonthread
    MatList[CLOTHING][REFINED_MAT][4] = "23127"
    --Kreshweed
    MatList[CLOTHING][REFINED_MAT][5] = "46131"
    --Ironweed
    MatList[CLOTHING][REFINED_MAT][6] = "46132"
    --Silverweed
    MatList[CLOTHING][REFINED_MAT][7] = "46133"
    --Void Bloom
    MatList[CLOTHING][REFINED_MAT][8] = "46134"
    --Ancestor Silk
    MatList[CLOTHING][REFINED_MAT][9] = "64504"
    --end of REFINED_MAT light
    --start of REFINED_MAT medium
    --Rawhide
    MatList[CLOTHING][REFINED_MAT][10] = "794"
    --Hide
    MatList[CLOTHING][REFINED_MAT][11] = "4447"
    --Leather
    MatList[CLOTHING][REFINED_MAT][12] = "23099"
    --Thick Leather
    MatList[CLOTHING][REFINED_MAT][13] = "23100"
    --Fell Hide
    MatList[CLOTHING][REFINED_MAT][14] = "23101"
    --Topgrain Hide
    MatList[CLOTHING][REFINED_MAT][15] = "46135"
    --Iron Hide
    MatList[CLOTHING][REFINED_MAT][16] = "46136"
    --Superb Hide
    MatList[CLOTHING][REFINED_MAT][17] = "46137"
    --Shadowhide
    MatList[CLOTHING][REFINED_MAT][18] = "46138"
    --Rubedo Leather
    MatList[CLOTHING][REFINED_MAT][19] = "64506"
    --end of REFINED_MAT medium
    --end of CLOTHING/REFINED_MAT
    --CLOTHING/IMPROVEMENT_MAT
    MatList[CLOTHING][IMPROVEMENT_MAT] = {}
    --start of IMPROVEMENT_MAT
    --Hemming
    MatList[CLOTHING][IMPROVEMENT_MAT][0] = "54174"
    --Embroidery
    MatList[CLOTHING][IMPROVEMENT_MAT][1] = "54175"
    --Elegant Lining
    MatList[CLOTHING][IMPROVEMENT_MAT][2] = "54176"
    --Dreugh Wax
    MatList[CLOTHING][IMPROVEMENT_MAT][3] = "54177"
    --end of CLOTHING/IMPROVEMENT_MAT
    --end of CLOTHING

    --start of BLACKSMITHING
    MatList[BLACKSMITHING] = {}
    --start of BLACKSMITHING/RAW_MAT
    MatList[BLACKSMITHING][RAW_MAT] = {}
    --Iron ore
    MatList[BLACKSMITHING][RAW_MAT][0] = "808"
    --High Iron ore
    MatList[BLACKSMITHING][RAW_MAT][1] = "5820"
    --Orichalcum ore
    MatList[BLACKSMITHING][RAW_MAT][2] = "23103"
    --Dwarven ore
    MatList[BLACKSMITHING][RAW_MAT][3] = "23104"
    --Ebony ore
    MatList[BLACKSMITHING][RAW_MAT][4] = "23105"
    --Calcinium ore
    MatList[BLACKSMITHING][RAW_MAT][5] = "4482"
    --Galatite ore
    MatList[BLACKSMITHING][RAW_MAT][6] = "23133"
    --Quicksilver ore
    MatList[BLACKSMITHING][RAW_MAT][7] = "23134"
    --Voidstone ore
    MatList[BLACKSMITHING][RAW_MAT][8] = "23135"
    --Rubedite ore
    MatList[BLACKSMITHING][RAW_MAT][9] = "71198"
    --end of BLACKSMITHING/RAW_MAT
    --start of BLACKSMITHING/REFINED_MAT
    MatList[BLACKSMITHING][REFINED_MAT] = {}
    --Iron Ingot
    MatList[BLACKSMITHING][REFINED_MAT][0] = "5413"
    --Steel Ingot
    MatList[BLACKSMITHING][REFINED_MAT][1] = "4487"
    --Orichalcum Ingot
    MatList[BLACKSMITHING][REFINED_MAT][2] = "23107"
    --Dwarven Ingot
    MatList[BLACKSMITHING][REFINED_MAT][3] = "6000"
    --Ebony Ingot
    MatList[BLACKSMITHING][REFINED_MAT][4] = "6001"
    --Calcinium Ingot
    MatList[BLACKSMITHING][REFINED_MAT][5] = "46127"
    --Galatite Ingot
    MatList[BLACKSMITHING][REFINED_MAT][6] = "46128"
    --Quicksilver Ingot
    MatList[BLACKSMITHING][REFINED_MAT][7] = "46129"
    --Voidstone Ingot
    MatList[BLACKSMITHING][REFINED_MAT][8] = "46130"
    --Rubedite Ingot
    MatList[BLACKSMITHING][REFINED_MAT][9] = "64489"
    --end of BLACKSMITHING/REFINED_MAT
    --start of BLACKSMITHING/IMPROVEMENT_MAT
    MatList[BLACKSMITHING][IMPROVEMENT_MAT] = {}
    --Honing Stone
    MatList[BLACKSMITHING][IMPROVEMENT_MAT][0] = "54170"
    --Dwarven Oil
    MatList[BLACKSMITHING][IMPROVEMENT_MAT][1] = "54171"
    --Grain SOLVENT
    MatList[BLACKSMITHING][IMPROVEMENT_MAT][2] = "54172"
    --Tempering Alloy
    MatList[BLACKSMITHING][IMPROVEMENT_MAT][3] = "54173"
    --end of BLACKSMITHING/IMPROVEMENT_MAT
    --end of BLACKSMITHING

    --start of WOODWORKING
    MatList[WOODWORKING] = {}
    --start of WOODWORKING/RAW_MAT
    MatList[WOODWORKING][RAW_MAT] = {}
    --Rough Maple
    MatList[WOODWORKING][RAW_MAT][0] = "802"
    --Rough Oak
    MatList[WOODWORKING][RAW_MAT][1] = "521"
    --Rough Beech
    MatList[WOODWORKING][RAW_MAT][2] = "23117"
    --Rough Hickory
    MatList[WOODWORKING][RAW_MAT][3] = "23118"
    --Rough Yew
    MatList[WOODWORKING][RAW_MAT][4] = "23119"
    --Rouch Birch
    MatList[WOODWORKING][RAW_MAT][5] = "818"
    --Rough Ash
    MatList[WOODWORKING][RAW_MAT][6] = "4439"
    --Rough Mahogany
    MatList[WOODWORKING][RAW_MAT][7] = "23137"
    --Rough Nightwood
    MatList[WOODWORKING][RAW_MAT][8] = "23138"
    --Rough Ruby Ash
    MatList[WOODWORKING][RAW_MAT][9] = "71199"
    --end of WOODWORKING/RAW_MAT
    --start of WOODWORKING/REFINED_MAT
    MatList[WOODWORKING][REFINED_MAT] = {}
    --Sanded Maple
    MatList[WOODWORKING][REFINED_MAT][0] = "803"
    --Sanded Oak
    MatList[WOODWORKING][REFINED_MAT][1] = "533"
    --Sanded Beech
    MatList[WOODWORKING][REFINED_MAT][2] = "23121"
    --Sanded Hickory
    MatList[WOODWORKING][REFINED_MAT][3] = "23122"
    --Sanded Yew
    MatList[WOODWORKING][REFINED_MAT][4] = "23123"
    --Sanded Birch
    MatList[WOODWORKING][REFINED_MAT][5] = "46139"
    --Sanded Ash
    MatList[WOODWORKING][REFINED_MAT][6] = "46140"
    --Sanded Mahogany
    MatList[WOODWORKING][REFINED_MAT][7] = "46141"
    --Sanded Nightwood
    MatList[WOODWORKING][REFINED_MAT][8] = "46142"
    --Sanded Ruby Ash
    MatList[WOODWORKING][REFINED_MAT][9] = "64502"
    --end of WOODWORKING/REFINED_MAT
    --start of WOODWORKING/IMPROVEMENT_MAT
    MatList[WOODWORKING][IMPROVEMENT_MAT] = {}
    --Pitch
    MatList[WOODWORKING][IMPROVEMENT_MAT][0] = "54178"
    --Turpen
    MatList[WOODWORKING][IMPROVEMENT_MAT][1] = "54179"
    --Mastic
    MatList[WOODWORKING][IMPROVEMENT_MAT][2] = "54180"
    --Rosin
    MatList[WOODWORKING][IMPROVEMENT_MAT][3] = "54181"
    --end of WOODWORKING/IMPROVEMENT_MAT
    --end of WOODWORKING

    --start of JEWELRY_CRAFTING
    MatList[JEWELRY_CRAFTING] = {}
    --start of JEWELRY_CRAFTING/RAW_MAT
    MatList[JEWELRY_CRAFTING][RAW_MAT] = {}
    --Pewter Dust
    MatList[JEWELRY_CRAFTING][RAW_MAT][0] = "135137"
    --Copper Dust
    MatList[JEWELRY_CRAFTING][RAW_MAT][1] = "135139"
    --Silver Dust
    MatList[JEWELRY_CRAFTING][RAW_MAT][2] = "135141"
    --Electrum Dust
    MatList[JEWELRY_CRAFTING][RAW_MAT][3] = "135143"
    --Platinum Dust
    MatList[JEWELRY_CRAFTING][RAW_MAT][4] = "135145"
    --end of JEWELRY_CRAFTING/RAW_MAT
    --start of JEWELRY_CRAFTING/REFINED_MAT
    MatList[JEWELRY_CRAFTING][REFINED_MAT] = {}
    --Pewter Ounce
    MatList[JEWELRY_CRAFTING][REFINED_MAT][0] = "135138"
    --Copper Ounce
    MatList[JEWELRY_CRAFTING][REFINED_MAT][1] = "135140"
    --Silver Ounce
    MatList[JEWELRY_CRAFTING][REFINED_MAT][2] = "135142"
    --Electrum Ounce
    MatList[JEWELRY_CRAFTING][REFINED_MAT][3] = "135144"
    --Platinum Ounce
    MatList[JEWELRY_CRAFTING][REFINED_MAT][4] = "135146"
    --end of JEWELRY_CRAFTING/REFINED_MAT
    --start of JEWELRY_CRAFTING/IMPROVEMENT_MAT
    MatList[JEWELRY_CRAFTING][IMPROVEMENT_MAT] = {}
    --Terne Grains
    MatList[JEWELRY_CRAFTING][IMPROVEMENT_MAT][0] = "135151"
    --Iridium Grains
    MatList[JEWELRY_CRAFTING][IMPROVEMENT_MAT][1] = "135152"
    --Zircon Grains
    MatList[JEWELRY_CRAFTING][IMPROVEMENT_MAT][2] = "135153"
    --Chromium Grains
    MatList[JEWELRY_CRAFTING][IMPROVEMENT_MAT][3] = "135154"
    --Terne Plating
    MatList[JEWELRY_CRAFTING][IMPROVEMENT_MAT][4] = "135147"
    --Iridium Plating
    MatList[JEWELRY_CRAFTING][IMPROVEMENT_MAT][5] = "135148"
    --Zircon Plating
    MatList[JEWELRY_CRAFTING][IMPROVEMENT_MAT][6] = "135149"
    --Chromium Plating
    MatList[JEWELRY_CRAFTING][IMPROVEMENT_MAT][7] = "135150"
    --end of JEWELRY_CRAFTING/IMPROVEMENT_MAT
    --end of JEWELRY_CRAFTING

    --start of ENCHANTING
    MatList[ENCHANTING] = {}
    --start of ENCHANTING/POTENCY
    MatList[ENCHANTING][POTENCY] = {}
    --Positive Runes
    --Jora
    MatList[ENCHANTING][POTENCY][0] = "45855"
    --Porade
    MatList[ENCHANTING][POTENCY][1] = "45856"
    --Jera
    MatList[ENCHANTING][POTENCY][2] = "45856"
    --Jejora
    MatList[ENCHANTING][POTENCY][3] = "45806"
    --Odra
    MatList[ENCHANTING][POTENCY][4] = "45807"
    --Pojora
    MatList[ENCHANTING][POTENCY][5] = "45808"
    --Edora
    MatList[ENCHANTING][POTENCY][6] = "45809"
    --Jaera
    MatList[ENCHANTING][POTENCY][7] = "45810"
    --Pora
    MatList[ENCHANTING][POTENCY][8] = "45811"
    --Denara
    MatList[ENCHANTING][POTENCY][9] = "45812"
    --Rera
    MatList[ENCHANTING][POTENCY][10] = "45813"
    --Derado
    MatList[ENCHANTING][POTENCY][11] = "45814"
    --Rekura
    MatList[ENCHANTING][POTENCY][12] = "45815"
    --Kura
    MatList[ENCHANTING][POTENCY][13] = "45816"
    --Rejera
    MatList[ENCHANTING][POTENCY][14] = "64509"
    --Repora
    MatList[ENCHANTING][POTENCY][15] = "68341"
    --Negative Runes
    --Jode
    MatList[ENCHANTING][POTENCY][16] = "45817"
    --Notade
    MatList[ENCHANTING][POTENCY][17] = "45818"
    --Ode
    MatList[ENCHANTING][POTENCY][18] = "45819"
    --Tade
    MatList[ENCHANTING][POTENCY][19] = "45820"
    --Jayde
    MatList[ENCHANTING][POTENCY][20] = "45821"
    --Edode
    MatList[ENCHANTING][POTENCY][21] = "45822"
    --Pojode
    MatList[ENCHANTING][POTENCY][22] = "45823"
    --Rekude
    MatList[ENCHANTING][POTENCY][23] = "45824"
    --Hade
    MatList[ENCHANTING][POTENCY][24] = "45825"
    --Idode
    MatList[ENCHANTING][POTENCY][25] = "45826"
    --Pode
    MatList[ENCHANTING][POTENCY][26] = "45827"
    --Kedeko
    MatList[ENCHANTING][POTENCY][27] = "45828"
    --Rede
    MatList[ENCHANTING][POTENCY][28] = "45829"
    --Kude
    MatList[ENCHANTING][POTENCY][29] = "45830"
    --Jehade
    MatList[ENCHANTING][POTENCY][30] = "64508"
    --Itade
    MatList[ENCHANTING][POTENCY][31] = "68340"
    --end of ENCHANTING/POTENCY
    --start of ENCHANTING/ESSENCE
    MatList[ENCHANTING][ESSENCE] = {}
    --Oko
    MatList[ENCHANTING][ESSENCE][0] = "45831"
    --Makko
    MatList[ENCHANTING][ESSENCE][1] = "45832"
    --Deni
    MatList[ENCHANTING][ESSENCE][2] = "45833"
    --Okoma
    MatList[ENCHANTING][ESSENCE][3] = "45834"
    --Makkoma
    MatList[ENCHANTING][ESSENCE][4] = "45835"
    --Denima
    MatList[ENCHANTING][ESSENCE][5] = "45836"
    --Kuoko
    MatList[ENCHANTING][ESSENCE][6] = "45837"
    --Rakeipa
    MatList[ENCHANTING][ESSENCE][7] = "45838"
    --Dekeipa
    MatList[ENCHANTING][ESSENCE][8] = "45839"
    --Meip
    MatList[ENCHANTING][ESSENCE][9] = "45840"
    --Haoko
    MatList[ENCHANTING][ESSENCE][10] = "45841"
    --Deteri
    MatList[ENCHANTING][ESSENCE][11] = "45842"
    --Okori
    MatList[ENCHANTING][ESSENCE][12] = "45843"
    --Oru
    MatList[ENCHANTING][ESSENCE][13] = "45846"
    --Taderi
    MatList[ENCHANTING][ESSENCE][14] = "45847"
    --Makderi
    MatList[ENCHANTING][ESSENCE][15] = "45848"
    --Kaderi
    MatList[ENCHANTING][ESSENCE][16] = "45849"
    --Hakeijo
    MatList[ENCHANTING][ESSENCE][17] = "68342"
    --end of ENCHANTING/ESSENCE
    --start of ENCHANTING/ASPECT
    MatList[ENCHANTING][ASPECT] = {}
    --Ta
    MatList[ENCHANTING][ASPECT][0] = "45850"
    --Jejota
    MatList[ENCHANTING][ASPECT][1] = "45851"
    --Denata
    MatList[ENCHANTING][ASPECT][2] = "45852"
    --Rekuta
    MatList[ENCHANTING][ASPECT][3] = "45853"
    --Kuta
    MatList[ENCHANTING][ASPECT][4] = "45854"
    --end of ENCHANTING/ASPECT
    --end of ENCHANTING

    --start of ALCHEMY
    MatList[ALCHEMY] = {}
    --start of ALCHEMY/REAGENT
    MatList[ALCHEMY][REAGENT] = {}
    --Blue Entoloma
    MatList[ALCHEMY][REAGENT][0] = "30148"
    --Stinkhorn
    MatList[ALCHEMY][REAGENT][1] = "30149"
    --Emetic Russula
    MatList[ALCHEMY][REAGENT][2] = "30151"
    --Violet Coprinus
    MatList[ALCHEMY][REAGENT][3] = "30152"
    --Namiras Rot
    MatList[ALCHEMY][REAGENT][4] = "30153"
    --White Cap
    MatList[ALCHEMY][REAGENT][5] = "30154"
    --Luminous Russula
    MatList[ALCHEMY][REAGENT][6] = "30155"
    --Imp Stool
    MatList[ALCHEMY][REAGENT][7] = "30156"
    --Blessed Thistle
    MatList[ALCHEMY][REAGENT][8] = "30157"
    --Ladys Smock
    MatList[ALCHEMY][REAGENT][9] = "30158"
    --Wormwood
    MatList[ALCHEMY][REAGENT][10] = "30159"
    --Bugloss
    MatList[ALCHEMY][REAGENT][11] = "30160"
    --Corn Flower
    MatList[ALCHEMY][REAGENT][12] = "30161"
    --Dragonthorn
    MatList[ALCHEMY][REAGENT][13] = "30162"
    --Mountain Flower
    MatList[ALCHEMY][REAGENT][14] = "30163"
    --Columbine
    MatList[ALCHEMY][REAGENT][15] = "30164"
    --Nirnroot
    MatList[ALCHEMY][REAGENT][16] = "30165"
    --Water Hyacinth
    MatList[ALCHEMY][REAGENT][17] = "30166"
    --Torchbug Thorax
    MatList[ALCHEMY][REAGENT][18] = "77581"
    --Beetle Scuttle
    MatList[ALCHEMY][REAGENT][19] = "77583"
    --Spider Egg
    MatList[ALCHEMY][REAGENT][20] = "77584"
    --Butterfly Wing
    MatList[ALCHEMY][REAGENT][21] = "77585"
    --Fleshfly Larva
    MatList[ALCHEMY][REAGENT][22] = "77587"
    --Scrib Jelly
    MatList[ALCHEMY][REAGENT][23] = "77589"
    --Nightshade
    MatList[ALCHEMY][REAGENT][24] = "77590"
    --Mudcrab Chitin
    MatList[ALCHEMY][REAGENT][25] = "77591"
    --Powdered Mother of Pearl
    MatList[ALCHEMY][REAGENT][26] = "139019"
    --Clam Gall
    MatList[ALCHEMY][REAGENT][27] = "139020"
    --Charus Egg
    MatList[ALCHEMY][REAGENT][28] = "150669"
    --Vile Coagulant
    MatList[ALCHEMY][REAGENT][29] = "150670"
    --Dragon Rheum
    MatList[ALCHEMY][REAGENT][30] = "150671"
    --Crimson Nirnroot
    MatList[ALCHEMY][REAGENT][31] = "150672"
    --Dragons Blood
    MatList[ALCHEMY][REAGENT][32] = "150731"
    --Dragons Bile
    MatList[ALCHEMY][REAGENT][33] = "150789"
    --Chaurus Egg
    MatList[ALCHEMY][REAGENT][34] = "150669"
    --end of ALCHEMY/REAGENT
    --start of ALCHEMY/SOLVENT
    MatList[ALCHEMY][SOLVENT] = {}
    --Potion SOLVENT
    --Natural Water
    MatList[ALCHEMY][SOLVENT][0] = "883"
    --Clear Water
    MatList[ALCHEMY][SOLVENT][1] = "1187"
    --Pristine Water
    MatList[ALCHEMY][SOLVENT][2] = "4570"
    --Cleansed Water
    MatList[ALCHEMY][SOLVENT][3] = "23265"
    --Filtered Water
    MatList[ALCHEMY][SOLVENT][4] = "23266"
    --Purified Water
    MatList[ALCHEMY][SOLVENT][5] = "23267"
    --Cloud Mist
    MatList[ALCHEMY][SOLVENT][6] = "23268"
    --Star Dew
    MatList[ALCHEMY][SOLVENT][7] = "64500"
    --Lorkhans Tears
    MatList[ALCHEMY][SOLVENT][8] = "64501"
    --Poison SOLVENT
    --Grease
    MatList[ALCHEMY][SOLVENT][9] = "75357"
    --Ichor
    MatList[ALCHEMY][SOLVENT][10] = "75358"
    --Slime
    MatList[ALCHEMY][SOLVENT][11] = "75359"
    --Gall
    MatList[ALCHEMY][SOLVENT][12] = "75360"
    --Terebinthine
    MatList[ALCHEMY][SOLVENT][13] = "75361"
    --Pitch-Bile
    MatList[ALCHEMY][SOLVENT][14] = "75362"
    --Tarblack
    MatList[ALCHEMY][SOLVENT][15] = "75363"
    --Night-Oil
    MatList[ALCHEMY][SOLVENT][16] = "75364"
    --Alkahest
    MatList[ALCHEMY][SOLVENT][17] = "75365"
    --end of ALCHEMY/SOLVENT
    --end of ALCHEMY

    --start of PROVISIONING
    MatList[PROVISIONING] = {}
    --start of PROVISIONING/FOOD_INGREDIENTS
    MatList[PROVISIONING][FOOD_INGREDIENTS] = {}
    --Fish
    MatList[PROVISIONING][FOOD_INGREDIENTS][0] = "33753"
    --Game
    MatList[PROVISIONING][FOOD_INGREDIENTS][1] = "28609"
    --Poultry
    MatList[PROVISIONING][FOOD_INGREDIENTS][2] = "34321"
    --Red Meat
    MatList[PROVISIONING][FOOD_INGREDIENTS][3] = "33752"
    --Small Game
    MatList[PROVISIONING][FOOD_INGREDIENTS][4] = "33756"
    --White Meat
    MatList[PROVISIONING][FOOD_INGREDIENTS][5] = "33754"
    --Apples
    MatList[PROVISIONING][FOOD_INGREDIENTS][6] = "34311"
    --Bananas
    MatList[PROVISIONING][FOOD_INGREDIENTS][7] = "33755"
    --Jazbay Grapes
    MatList[PROVISIONING][FOOD_INGREDIENTS][8] = "28610"
    --Melon
    MatList[PROVISIONING][FOOD_INGREDIENTS][9] = "34308"
    --Pumpkin
    MatList[PROVISIONING][FOOD_INGREDIENTS][10] = "34305"
    --Tomato
    MatList[PROVISIONING][FOOD_INGREDIENTS][11] = "28603"
    --Beets
    MatList[PROVISIONING][FOOD_INGREDIENTS][12] = "34309"
    --Carrots
    MatList[PROVISIONING][FOOD_INGREDIENTS][13] = "34324"
    --Corn
    MatList[PROVISIONING][FOOD_INGREDIENTS][14] = "34323"
    --Greens
    MatList[PROVISIONING][FOOD_INGREDIENTS][15] = "28604"
    --Potato
    MatList[PROVISIONING][FOOD_INGREDIENTS][16] = "33758"
    --Radish
    MatList[PROVISIONING][FOOD_INGREDIENTS][17] = "34307"
    --Cheese
    MatList[PROVISIONING][FOOD_INGREDIENTS][18] = "27057"
    --Flour
    MatList[PROVISIONING][FOOD_INGREDIENTS][19] = "27100"
    --Garlic
    MatList[PROVISIONING][FOOD_INGREDIENTS][20] = "26954"
    --Millet
    MatList[PROVISIONING][FOOD_INGREDIENTS][21] = "27064"
    --Saltrice
    MatList[PROVISIONING][FOOD_INGREDIENTS][22] = "27063"
    --Seasoning
    MatList[PROVISIONING][FOOD_INGREDIENTS][23] = "27058"
    --Frost Mirriam
    MatList[PROVISIONING][FOOD_INGREDIENTS][24] = "26802"
    --end of PROVISIONING/FOOD_INGREDIENTS
    --start of PROVISIONING/BEVERAGE_INGREDIENTS
    MatList[PROVISIONING][BEVERAGE_INGREDIENTS] = {}
    --Barley
    MatList[PROVISIONING][BEVERAGE_INGREDIENTS][0] = "34329"
    --Rice
    MatList[PROVISIONING][BEVERAGE_INGREDIENTS][1] = "29030"
    --Rye
    MatList[PROVISIONING][BEVERAGE_INGREDIENTS][2] = "28639"
    --Surilie Grapes
    MatList[PROVISIONING][BEVERAGE_INGREDIENTS][3] = "34345"
    --Wheat
    MatList[PROVISIONING][BEVERAGE_INGREDIENTS][4] = "34348"
    --Yeast
    MatList[PROVISIONING][BEVERAGE_INGREDIENTS][5] = "33774"
    --Bittergreen
    MatList[PROVISIONING][BEVERAGE_INGREDIENTS][6] = "34334"
    --Comberry
    MatList[PROVISIONING][BEVERAGE_INGREDIENTS][7] = "33768"
    --Jasmine
    MatList[PROVISIONING][BEVERAGE_INGREDIENTS][8] = "33771"
    --Lotus
    MatList[PROVISIONING][BEVERAGE_INGREDIENTS][9] = "34330"
    --Mint
    MatList[PROVISIONING][BEVERAGE_INGREDIENTS][10] = "33773"
    --Rose
    MatList[PROVISIONING][BEVERAGE_INGREDIENTS][11] = "28636"
    --Acai Berry
    MatList[PROVISIONING][BEVERAGE_INGREDIENTS][12] = "34349"
    --Coffee
    MatList[PROVISIONING][BEVERAGE_INGREDIENTS][13] = "33772"
    --Ginkgo
    MatList[PROVISIONING][BEVERAGE_INGREDIENTS][14] = "34346"
    --Ginseng
    MatList[PROVISIONING][BEVERAGE_INGREDIENTS][15] = "34347"
    --Guarana
    MatList[PROVISIONING][BEVERAGE_INGREDIENTS][16] = "34333"
    --Yerba Mate
    MatList[PROVISIONING][BEVERAGE_INGREDIENTS][17] = "34335"
    --Ginger
    MatList[PROVISIONING][BEVERAGE_INGREDIENTS][18] = "27052"
    --Honey
    MatList[PROVISIONING][BEVERAGE_INGREDIENTS][19] = "27043"
    --Isinglass
    MatList[PROVISIONING][BEVERAGE_INGREDIENTS][20] = "27035"
    --Lemon
    MatList[PROVISIONING][BEVERAGE_INGREDIENTS][21] = "27049"
    --Metheglin
    MatList[PROVISIONING][BEVERAGE_INGREDIENTS][22] = "27048"
    --Seaweed
    MatList[PROVISIONING][BEVERAGE_INGREDIENTS][23] = "28666"
    --Bervez Juice
    MatList[PROVISIONING][BEVERAGE_INGREDIENTS][24] = "27059"
    --end of PROVISIONING/BEVERAGE_INGREDIENTS
    --start of PROVISIONING/OTHER_INGREDIENTS
    MatList[PROVISIONING][OTHER_INGREDIENTS] =  {}
    --Perfect Roe
    MatList[PROVISIONING][OTHER_INGREDIENTS][0] = "64222"
    --Diminished Aetherial Dust
    MatList[PROVISIONING][OTHER_INGREDIENTS][1] = "120078"
    --Aetherial Dust
    MatList[PROVISIONING][OTHER_INGREDIENTS][2] = "115026"
    --end of PROVISIONING/OTHER_INGREDIENTS
    --end of PROVISIONING

    --start of TRAIT_MATS
    MatList[TRAIT_MATS] = {}
    --start of TRAIT_MATS/WEAPON
    MatList[TRAIT_MATS][WEAPON] = {}
    --Chysolite
    MatList[TRAIT_MATS][WEAPON][0] = "23203"
    --Amethyst
    MatList[TRAIT_MATS][WEAPON][1] = "23204"
    --Ruby
    MatList[TRAIT_MATS][WEAPON][2] = "4486"
    --Jade
    MatList[TRAIT_MATS][WEAPON][3] = "810"
    --Turquoise
    MatList[TRAIT_MATS][WEAPON][4] = "813"
    --Carnelian
    MatList[TRAIT_MATS][WEAPON][5] = "23165"
    --Fire Opal
    MatList[TRAIT_MATS][WEAPON][6] = "23149"
    --Citrine
    MatList[TRAIT_MATS][WEAPON][7] = "16291"
    --Potent Nirncrux
    MatList[TRAIT_MATS][WEAPON][8] = "56863"
    --end of TRAIT_MATS/WEAPON
    --start of TRAIT_MATS/ARMOR
    MatList[TRAIT_MATS][ARMOR] = {}
    --Quartz
    MatList[TRAIT_MATS][ARMOR][0] = "4456"
    --Diamond
    MatList[TRAIT_MATS][ARMOR][1] = "23219"
    --Sardonyx
    MatList[TRAIT_MATS][ARMOR][2] = "30221"
    --Almandine
    MatList[TRAIT_MATS][ARMOR][3] = "23221"
    --Emerald
    MatList[TRAIT_MATS][ARMOR][4] = "4442"
    --Bloodstone
    MatList[TRAIT_MATS][ARMOR][5] = "30219"
    --Garnet
    MatList[TRAIT_MATS][ARMOR][6] = "23171"
    --Sapphire
    MatList[TRAIT_MATS][ARMOR][7] = "23173"
    --Fortified Nirncrux
    MatList[TRAIT_MATS][ARMOR][8] = "56862"
    --end of TRAIT_MATS/ARMOR
    --start of TRAIT_MATS/JEWELRY
    MatList[TRAIT_MATS][JEWELRY] = {}
    --Cobalt
    MatList[TRAIT_MATS][JEWELRY][0] = "135155"
    --Antimony
    MatList[TRAIT_MATS][JEWELRY][1] = "135156"
    --Zinc
    MatList[TRAIT_MATS][JEWELRY][2] = "135157"
    --Pulverized Cobalt
    MatList[TRAIT_MATS][JEWELRY][3] = "135158"
    --Pulverized Antimony
    MatList[TRAIT_MATS][JEWELRY][4] = "135159"
    --Pulverized Zinc
    MatList[TRAIT_MATS][JEWELRY][5] = "135160"
    --Dawn-Prism
    MatList[TRAIT_MATS][JEWELRY][6] = "139409"
    --Titanium
    MatList[TRAIT_MATS][JEWELRY][7] = "139410"
    --Aurbic Amber
    MatList[TRAIT_MATS][JEWELRY][8] = "139411"
    --Gilding Wax
    MatList[TRAIT_MATS][JEWELRY][9] = "139412"
    --Dibellium
    MatList[TRAIT_MATS][JEWELRY][10] = "139413"
    --Slaughterstone
    MatList[TRAIT_MATS][JEWELRY][11] = "139414"
    --Pulverized Dawn-Prism
    MatList[TRAIT_MATS][JEWELRY][12] = "139415"
    --Pulverized Titanium
    MatList[TRAIT_MATS][JEWELRY][13] = "139416"
    --Pulverized Aurbic Amber
    MatList[TRAIT_MATS][JEWELRY][14] = "139417"
    --Pulverized Gilding Wax
    MatList[TRAIT_MATS][JEWELRY][15] = "139418"
    --Pulverized Dibellium
    MatList[TRAIT_MATS][JEWELRY][16] = "139419"
    --Pulverized Slaughterstone
    MatList[TRAIT_MATS][JEWELRY][17] = "139420"
    --end of TRAIT_MATS/JEWELRY
    --end of TRAIT_MATS

    --start of STYLE_MATS
    MatList[STYLE_MATS] = {}
    --start of STYLE_MATS/RAW_MAT
    MatList[STYLE_MATS][RAW_MAT] = {}
    --Dwemer Scrap
    MatList[STYLE_MATS][RAW_MAT][0] = "57665"
    --Ancient Scale
    MatList[STYLE_MATS][RAW_MAT][1] = "64688"
    --Malachite Shard
    MatList[STYLE_MATS][RAW_MAT][2] = "64690"
    --Ashes of Remorse
    MatList[STYLE_MATS][RAW_MAT][3] = "59923"
    --Cassiterite Sand
    MatList[STYLE_MATS][RAW_MAT][4] = "69556"
    --Coarse Chalk
    MatList[STYLE_MATS][RAW_MAT][5] = "75371"
    --Dried Blood
    MatList[STYLE_MATS][RAW_MAT][6] = "76911"
    --Oxblood Fungus Spore
    MatList[STYLE_MATS][RAW_MAT][7] = "81995"
    --Grain of Pearl Sand
    MatList[STYLE_MATS][RAW_MAT][8] = "81997"
    --Viridian Dust
    MatList[STYLE_MATS][RAW_MAT][9] = "121521"
    --Pliant Ferrofungus
    MatList[STYLE_MATS][RAW_MAT][10] = "121522"
    --Dull Sphalerite
    MatList[STYLE_MATS][RAW_MAT][11] = "121523"
    --Raw Bonemold Resin
    MatList[STYLE_MATS][RAW_MAT][12] = "130058"
    --Scarab Elytra
    MatList[STYLE_MATS][RAW_MAT][13] = "130062"
    --end of STYLE_MATS/RAW_MAT
    --start of STYLE_MATS/REFINED_MAT
    MatList[STYLE_MATS][REFINED_MAT] = {}
    --Adamantite
    MatList[STYLE_MATS][REFINED_MAT][0] = "33252"
    --Aeonstone Shard
    MatList[STYLE_MATS][REFINED_MAT][1] = "156624"
    --Amber Marble
    MatList[STYLE_MATS][REFINED_MAT][2] = "82000"
    --Ancient Sandstone
    MatList[STYLE_MATS][REFINED_MAT][3] = "71736"
    --Argentum
    MatList[STYLE_MATS][REFINED_MAT][4] = "46150"
    --Argent Pelt
    MatList[STYLE_MATS][REFINED_MAT][5] = "141821"
    --Ash Canvas
    MatList[STYLE_MATS][REFINED_MAT][6] = "125476"
    --Auric Tusk
    MatList[STYLE_MATS][REFINED_MAT][7] = "71582"
    --Auroran Dust
    MatList[STYLE_MATS][REFINED_MAT][8] = "151908"
    --Azure Plasm
    MatList[STYLE_MATS][REFINED_MAT][9] = "71766"
    --Black Beeswax
    MatList[STYLE_MATS][REFINED_MAT][10] = "79304"
    --Blood of Sahrotnax
    MatList[STYLE_MATS][REFINED_MAT][11] = "156606"
    --Bloodscent Dew
    MatList[STYLE_MATS][REFINED_MAT][12] = "141820"
    --Bloodroot Flux
    MatList[STYLE_MATS][REFINED_MAT][13] = "132620"
    --Boiled Carapace
    MatList[STYLE_MATS][REFINED_MAT][14] = "79305"
    --Bone
    MatList[STYLE_MATS][REFINED_MAT][15] = "33194"
    --Bronze
    MatList[STYLE_MATS][REFINED_MAT][16] = "46149"
    --Carmine Shieldsilk
    MatList[STYLE_MATS][REFINED_MAT][17] = "156643"
    --Cassiterite
    MatList[STYLE_MATS][REFINED_MAT][18] = "69555"
    --Charcoal of Remorse
    MatList[STYLE_MATS][REFINED_MAT][19] = "59922"
    --Corundum
    MatList[STYLE_MATS][REFINED_MAT][20] = "33256"
    --Crocodile Leather
    MatList[STYLE_MATS][REFINED_MAT][21] = "145532"
    --Crown Mimic Stone
    MatList[STYLE_MATS][REFINED_MAT][22] = "71668"
    --Consecrated Myrrh
    MatList[STYLE_MATS][REFINED_MAT][23] = "158307"
    --Culanda Lacquer
    MatList[STYLE_MATS][REFINED_MAT][24] = "137953"
    --Daedra Heart
    MatList[STYLE_MATS][REFINED_MAT][25] = "46151"
    --Defiled Whiskers
    MatList[STYLE_MATS][REFINED_MAT][26] = "79672"
    --Desecrated Grave Soil
    MatList[STYLE_MATS][REFINED_MAT][27] = "134798"
    --Distilled Slowsilver
    MatList[STYLE_MATS][REFINED_MAT][28] = "114983"
    --Dragonthread
    MatList[STYLE_MATS][REFINED_MAT][29] = "151622"
    --Dragon Bone
    MatList[STYLE_MATS][REFINED_MAT][30] = "137958"
    --Dragon Scute
    MatList[STYLE_MATS][REFINED_MAT][31] = "71740"
    --Dwemer Frame
    MatList[STYLE_MATS][REFINED_MAT][32] = "57587"
    --Eagle Feather
    MatList[STYLE_MATS][REFINED_MAT][33] = "71738"
    --Etched Adamantite
    MatList[STYLE_MATS][REFINED_MAT][34] = "160609"
    --Etched Corundum
    MatList[STYLE_MATS][REFINED_MAT][35] = "160592"
    --Etched Manganese
    MatList[STYLE_MATS][REFINED_MAT][36] = "160626"
    --Ferrous Salts
    MatList[STYLE_MATS][REFINED_MAT][37] = "64685"
    --Fine Chalk
    MatList[STYLE_MATS][REFINED_MAT][38] = "75370"
    --Flint
    MatList[STYLE_MATS][REFINED_MAT][39] = "33150"
    --Frost Embers
    MatList[STYLE_MATS][REFINED_MAT][40] = "152235"
    --Fire Salts
    MatList[STYLE_MATS][REFINED_MAT][41] = "156571"
    --Gloomspore Chitin
    MatList[STYLE_MATS][REFINED_MAT][42] = "160509"
    --Goblin-Cloth Scrap
    MatList[STYLE_MATS][REFINED_MAT][43] = "151907"
    --Goldscale
    MatList[STYLE_MATS][REFINED_MAT][44] = "64687"
    --Grinstones
    MatList[STYLE_MATS][REFINED_MAT][45] = "82002"
    --Gryphon Plume
    MatList[STYLE_MATS][REFINED_MAT][46] = "141740"
    --Hackwing Plumage
    MatList[STYLE_MATS][REFINED_MAT][47] = "145533"
    --Infected Flesh
    MatList[STYLE_MATS][REFINED_MAT][48] = "137961"
    --Laurel
    MatList[STYLE_MATS][REFINED_MAT][49] = "64713"
    --Leviathan Scrimshaw
    MatList[STYLE_MATS][REFINED_MAT][50] = "114984"
    --Lion Fang
    MatList[STYLE_MATS][REFINED_MAT][51] = "71742"
    --Lustrous Sphalerite
    MatList[STYLE_MATS][REFINED_MAT][52] = "121520"
    --Malachite
    MatList[STYLE_MATS][REFINED_MAT][53] = "64689"
    --Manganese
    MatList[STYLE_MATS][REFINED_MAT][54] = "33257"
    --Minotaur Bezoar
    MatList[STYLE_MATS][REFINED_MAT][55] = "132619"
    --Molybdenum
    MatList[STYLE_MATS][REFINED_MAT][56] = "33251"
    --Moonstone
    MatList[STYLE_MATS][REFINED_MAT][57] = "33255"
    --Nickel
    MatList[STYLE_MATS][REFINED_MAT][58] = "33254"
    --Night Pumice
    MatList[STYLE_MATS][REFINED_MAT][59] = "82004"
    --Oath Cord
    MatList[STYLE_MATS][REFINED_MAT][60] = "156589"
    --Obsidian
    MatList[STYLE_MATS][REFINED_MAT][61] = "33253"
    --Oxblood Fungus
    MatList[STYLE_MATS][REFINED_MAT][62] = "81994"
    --Palladium
    MatList[STYLE_MATS][REFINED_MAT][63] = "46152"
    --Pearl Sand
    MatList[STYLE_MATS][REFINED_MAT][64] = "81996"
    --Polished Rivets
    MatList[STYLE_MATS][REFINED_MAT][65] = "130061"
    --Polished Shilling
    MatList[STYLE_MATS][REFINED_MAT][66] = "76914"
    --Potash
    MatList[STYLE_MATS][REFINED_MAT][67] = "71584"
    --Polished Scarab Elytra
    MatList[STYLE_MATS][REFINED_MAT][68] = "130060"
    --Pristine Shroud
    MatList[STYLE_MATS][REFINED_MAT][69] = "75373"
    --Red Diamond Seal
    MatList[STYLE_MATS][REFINED_MAT][70] = "147288"
    --Refined Bonemold Resin
    MatList[STYLE_MATS][REFINED_MAT][71] = "130059"
    --Roogues Soot
    MatList[STYLE_MATS][REFINED_MAT][72] = "71538"
    --Sea Serpent Hide
    MatList[STYLE_MATS][REFINED_MAT][73] = "140267"
    --Shimmering Sand
    MatList[STYLE_MATS][REFINED_MAT][74] = "151621"
    --Snake Fang
    MatList[STYLE_MATS][REFINED_MAT][75] = "134687"
    --Stalhrim Shard
    MatList[STYLE_MATS][REFINED_MAT][76] = "114283"
    --Starmetal
    MatList[STYLE_MATS][REFINED_MAT][77] = "33258"
    --Star Sapphire
    MatList[STYLE_MATS][REFINED_MAT][78] = "81998"
    --Tainted Blood
    MatList[STYLE_MATS][REFINED_MAT][79] = "76910"
    --Tempered Brass
    MatList[STYLE_MATS][REFINED_MAT][80] = "132617"
    --Tenebrous Cord
    MatList[STYLE_MATS][REFINED_MAT][81] = "132618"
    --Vitrified Malondo
    MatList[STYLE_MATS][REFINED_MAT][82] = "137951"
    --Volcanic Viridian
    MatList[STYLE_MATS][REFINED_MAT][83] = "121518"
    --Warriors Heart Ashes
    MatList[STYLE_MATS][REFINED_MAT][84] = "137957"
    --Wolfsbane Incense
    MatList[STYLE_MATS][REFINED_MAT][85] = "96388"
    --Wrought Ferrofungus
    MatList[STYLE_MATS][REFINED_MAT][86] = "121519"
    --end of STYLE_MATS/REFINED_MAT
    --end of STYLE_MATS

    --start of FURNISHING_MATS
    MatList[FURNISHING_MATS] = {}
    --start of FURNISHING_MATS/PLACEHOLDER
    --need the PLACEHOLDER to make sure it aligns with everything else
    MatList[FURNISHING_MATS][PLACEHOLDER] = {}
    --Regulus
    MatList[FURNISHING_MATS][PLACEHOLDER][0] = "114889"
    --Bast
    MatList[FURNISHING_MATS][PLACEHOLDER][1] = "114890"
    --Clean Pelt
    MatList[FURNISHING_MATS][PLACEHOLDER][2] = "114891"
    --Mundane Rune
    MatList[FURNISHING_MATS][PLACEHOLDER][3] = "114892"
    --Alchemical Resin
    MatList[FURNISHING_MATS][PLACEHOLDER][4] = "114893"
    --Decorative Wax
    MatList[FURNISHING_MATS][PLACEHOLDER][5] = "114894"
    --Heartwood
    MatList[FURNISHING_MATS][PLACEHOLDER][6] = "114895"
    --Ochre
    MatList[FURNISHING_MATS][PLACEHOLDER][7] = "135161"
end

function CreateMatList:Initialize()
    --Creat the MatList to filter later
    MatCalcTest.CreateMatList()
    --Clicking on mail triggers this, and the rest of the addon.
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_MAIL_READABLE, MatCalcTest.OnMailReadable)
end

function CreateMatList.OnAddOnLoaded(event, addonName)
  -- The event fires each time *any* addon loads - but we only care about when our own addon loads.
  if addonName == CreateMatList.name then
    CreateMatList:Initialize()
  end
  --I should probably unregister the load event here.
end

--Run Initialize function on load
EVENT_MANAGER:RegisterForEvent(CreateMatList.name, EVENT_ADD_ON_LOADED, CreateMatList.OnAddOnLoaded)