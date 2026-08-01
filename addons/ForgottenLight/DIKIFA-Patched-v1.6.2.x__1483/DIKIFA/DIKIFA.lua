--__________________________________________________________________________--
--																			--
--				Wanda's - DO I KEEP IT FOR ALTS?	v 1.6.2					--
--					"who knows what?" tooltip addon for						--
--			Trophies, Fishes, Motifs, Recipes, Food and Drinks				--
--__________________________________________________________________________--
--																			--
--[[
-- v1.6.2.23: Patch: Added support for 4 new motifs: 93, 98, 103, 104
-- v1.6.2.22: Patch: Added support for 7 new motifs: 107, 108, 110, 111, 112, 113, 114
-- v1.6.2.21: Patch: Added support for 3 new motifs: 102, 105, 106
-- v1.6.2.20: Patch: Added support for 2 new motifs: 92, 99, 100, 101
-- v1.6.2.19: Patch: Added support for 2 new motifs: 95, 97
-- v1.6.2.18: Patch: Added support for 4 new motifs: 90, 91, 94, 96
-- v1.6.2.17: Patch: Added support for 2 new motifs: 85, 86
-- v1.6.2.16: Patch: Added support for 10 new motifs: 77, 78, 80, 81, 82, 83, 84, 87, 88, 89; Sorting of the list of characters by igx31
-- v1.6.2.15: Patch: Added support for 3 new motifs: 53, 68, 76
-- v1.6.2.14: Patch: Added support for 5 new motifs: 71, 72, 73, 74, 75
-- v1.6.2.13: Patch: Added support for 2 new motifs: 65, 70
-- v1.6.2.12: Patch: Added support for 4 new motifs: 63, 66, 67, 69;
-- v1.6.2.11: Patch: Added support for 2 new motifs: 58, 59;
-- v1.6.2.10: Patch: Added support for 3 new motifs: 61, 62, 64;
-- v1.6.2.9 : Patch: Fixed support for motifs: 49, 60;
-- v1.6.2.8 : Patch: Added support for 2 new motifs: 49, 60;
-- v1.6.2.7 : Patch: Added support for 4 new motifs: 54, 55, 56, 57;
-- v1.6.2.6 : Patch: Added support for 3 new motifs: 50, 51, 52;
-- v1.6.2.5 : Patch: Added support for 3 new motifs: 30, 47, 48;
-- v1.6.2.4 : Patch: Added support for 4 new motifs: 28, 37, 44, 45;
-- v1.6.2.3 : Patch: Added support for 2 new motifs: 42, 31;
-- v1.6.2.2 : Patch: Added support for 3 new motifs: 20, 37, 41;
-- v1.6.2.1 : Patch: Added support for 7 new motifs: 32, 33, 34, 35, 36, 39, 40; RU localization; Across All Acounts Saved Variables

-- v1.6.2 : add a screen achievement alert when getting a monster trophy
-- v1.6.1 : adds standard recipeListIndex and recipeIndex to the returned results of the API for cooking.
-- v1.6.0 : update for ESO 2.3
-- v1.5.1 : anti-doublons measures. ! savedvars wipe
-- v1.5.0b: fix for mercenary books (thanks ForgottenLight for keeping up the reports)! at this date mercenary books dont return the right value with book API functions. (if someone else got the issue)
-- v1.5.0a: fix the display of books registered without achievements (thanks ForgottenLight for the report)
-- v1.5.0 : update for ESO 2.2
-- v1.4.0 : update for ESO 2.1 changed trophies types even if not needed anymore. removed new keys as they are of the wrong type, added new and crown motifs.
-- PLEASE SEE BELOW HOW TO DISABLE TROPHIES AND FISHES FROM THE TOOLTIPS or use KHRILL'S SETTINGS (on the addon page click on more files to see the plugin)
-- v1.3.6d: fix for french api to be able to see manual a entry of "pommes fraîches et fromage⸗eidar"
-- v1.3.6c: sunday plumbing
-- v1.3.6b: removed the old global table for fish infos (see global functions to replace), removed a transitional way to collect infos for WKCP that should be unecessary by now.
-- added tooltip to Khrill's Hero in Disguise Consumable Mob Trophies. Because you can use them from his UI if you don't deactivate them in KHID options.
-- v1.3.6 : added features for WandalizeKCP DIKIFA:RecipeCountByResultName(foodname) returns now also integer foodlisttype, integer recipeindex from eso recipe tree (no filter)
-- v1.3.5b: Corrected a problem with a fish of StormHaven
-- v1.3.5 : Added some global functions to check the collection advancement of items account wide from other addons. and a version number to check the version easier.
------------Patched the display of Psijic Ambrosia Recipe Fragments so they dont display any info.
-- I ate all my trophies after v1.3.3 so i couldn't test them this time again. Pls report in Esoui comments if there are any problem
-- v1.3.4 : repaired something i broke last time. whoops. hope i didnt break anything else this time.
-- v1.3.3 : Wanda 1, typos from Eso translations 0.
-- Licence : suit yourself in the limits of Esoui rules of conduct and basic human rules of decency toward other's work.
-- This program is inspired from the tooltip of SousChef that I wished to be on every item. Now it is.]]

-----VERY VERY VERY GENERAL SETTINGS don't touch this.
DIKIFA = {}
local DIKI		= {}
local CharsList	= {}	-- list of usable alt characters - i.e. in the same World (EU or NA megaserver)
local livesHere	= {}	-- same *but* with names as _keys_, not value...
local myId
DIKI.name				= "DIKIFA"
DIKIFA.version			= 162		-- so you can use > for 1.3.5+ for version check
DIKI.knownstr			= {"en","fr","de","ru"}
DIKI.unknownstr			= {"en","fr","de","ru"}
DIKI.boundstr			= {"en","fr","de","ru"}
DIKI.TrophyIcon			= "/esoui/art/treeicons/store_indexicon_trophy_up.dds"
DIKI.CraftIcon			= "/esoui/art/icons/achievements_indexicon_crafting_up.dds"
DIKI.showTrophyMessage	= false
--DIKI.fishstr			= {en ="fishing", fr ="pêche", de ="fischen"}	-- needed only if new trophies cats are added in the achievement journal some day
--------------------------------------------------------------------------
---VERY GENERAL SETTINGS
------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------- You CAN EDIT this part carefully. Or Use Khrill's settings menu since he had the time to make one ----------------------------
------------------------------------- He thinks you need help with this. I said pfff, he said a menu is better ---------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------

--GLOBALS for Khrill to be able to play with them. Please if you use this to deactivate options or recolor because it's convenient
--for your published addon, just alert your users. If you tweak them here first you'll have your account settings directly in Khrill's panel. just to say.

DIKIFA.TrophiesOn			= 2		-- 0:OFF, 2:show auto (any positive decimal to show auto actually. 2 is nice, I like 2)
DIKIFA.MotifsOn				= 2		-- keep them all to 0 or positive, I'm not joking.
DIKIFA.RecipesOn			= 2		-- I said all. as in "every single one of them"
DIKIFA.FishesOn				= 2		-- I wont repeat, but it's lacking of green here (yeah my basic not-to-be-named text editor comments in green).
DIKIFA.FoodDrinkOn			= 2		-- seems redundant with recipes, but I like to see this for storing useful dishes for dailies.
DIKIFA.ShowAtCookingFire	= 2		-- self explanatory // independent from FoodDrinkOn - not logical but more possibilities.

------if you don't/want to see the header above the list of characters : ie 'known by', 'erlernt von', 'connu de' and the same for unknown : 'not yet known by' etc...
------if you want to do the maths for "who doesn't/know" by yourself because you have only 1 or 2 characters or any other reason that eludes me.
DIKIFA.ShowTitleKnown		= 0		-- new option v1.3.2
DIKIFA.ShowKnown			= 2		-- new option v1.3.2
DIKIFA.ShowTitleUnknown		= 0		-- new option v1.3.2
DIKIFA.ShowUnknown			= 2		-- 0 : hide the line for "who doesn't know", 2 : show the line

------color for known line (I know right, I shouldn't let Khrill play with this one... just wait and see.)
DIKIFA.rkn					= 0.5	-- red value for known characters : 0 <= rk <= 1	: take your R (red) from your favorite RGB decimal code and do R/255.
DIKIFA.gkn					= 1		-- same for green known
DIKIFA.bkn					= 0.5	-- same for blue known

------color for unknown line
DIKIFA.rukn					= 1		-- same for red unknown characters						wait!!! choose another color! (ikr, but sometimes...)
DIKIFA.gukn					= 0.5	-- same for green unknown
DIKIFA.bukn					= 0.5	-- same for blue unknown

---------------------------------------------- Here Khrill is gonna stop. But you can keep on with these strings. Just don't tell him, it's between us.
------ How to introduce the lists : 'en' is the default language to edit if you use a non-vanilla language. but special or non-latin characters may not display properly
DIKI.knownstr.en			= "Known By"
DIKI.knownstr.de			= "Erlernt von"
DIKI.knownstr.fr			= "Connu de"
DIKI.knownstr.ru			= "Известно"

DIKI.unknownstr.en			= "Not Yet Known By"
DIKI.unknownstr.de			= "Noch nicht erlernt von"
DIKI.unknownstr.fr			= "Pas encore connu de"
DIKI.unknownstr.ru			= "Еще Не Известно"
------------------------------------------------------------------------------------------------------------------------------------------------------------
----- /end of VERY GENERAL SETTINGS -------------- nothing of what follows is optional. no messing around pls.
------------------------------------------------------------------------------------------------------------------------------------------------------------

local kncolor = ZO_ColorDef:New(1,1,1,1)
local ukncolor = ZO_ColorDef:New(1,1,1,1)
function DIKIFA:SubmitSettings()										--From Global to local and apply
DIKI.TrophiesOn			= DIKIFA.TrophiesOn
DIKI.MotifsOn			= DIKIFA.MotifsOn
DIKI.RecipesOn			= DIKIFA.RecipesOn
DIKI.FishesOn			= DIKIFA.FishesOn
DIKI.FoodDrinkOn		= DIKIFA.FoodDrinkOn
DIKI.ShowTitleKnown		= DIKIFA.ShowTitleKnown
DIKI.ShowTitleUnknown	= DIKIFA.ShowTitleUnknown
DIKI.ShowKnown			= DIKIFA.ShowKnown
DIKI.ShowUnknown		= DIKIFA.ShowUnknown
DIKI.ShowAtCookingFire	= DIKIFA.ShowAtCookingFire
DIKI.rkn				= DIKIFA.rkn
DIKI.gkn				= DIKIFA.gkn
DIKI.bkn				= DIKIFA.bkn
DIKI.rukn				= DIKIFA.rukn
DIKI.gukn				= DIKIFA.gukn
DIKI.bukn				= DIKIFA.bukn
kncolor:SetRGB(DIKI.rkn,DIKI.gkn,DIKI.bkn)
ukncolor:SetRGB(DIKI.rukn,DIKI.gukn,DIKI.bukn)
-- fill the table of item types to enhance
DIKI.validtype = {}														--table to stock selected item types /note for later types as indexes bool as values
	if DIKI.TrophiesOn	> 0 then DIKI.validtype[ITEMTYPE_COLLECTIBLE]			= true end	-- changed in api 2.1
	if DIKI.FishesOn	> 0 then DIKI.validtype[ITEMTYPE_COLLECTIBLE]			= true end
	if DIKI.RecipesOn	> 0 then DIKI.validtype[ITEMTYPE_RECIPE]				= true end
	if DIKI.MotifsOn	> 0 then DIKI.validtype[ITEMTYPE_RACIAL_STYLE_MOTIF]	= true end
	if DIKI.FoodDrinkOn > 0 then
		DIKI.validtype[ITEMTYPE_FOOD]	= true
		DIKI.validtype[ITEMTYPE_DRINK]	= true
	end
--/end of record selected categories.
end
local function typeisvalid(itemtype)									--Check if type is included in the settings
		local isvalid = 0
		for k,v in pairs(DIKI.validtype) do
			if itemtype == k then isvalid = isvalid + 1 end
		end
	return isvalid
end

--[[--MOTIFS
format : ["achievement ID, index of the criterion"] = "book itemId" note that indexes are "randomly" imposed by the table order (alphabetic, itemid, whatever...)
future new books will be marked n/a until update.
list of achievements to check which one are unlocked - used in recordcraft. Written here for commodity.

alliance style, rare style, dwemer style, glass, xivkyn, ancient orc, merco, trinimac, malacath, akaviri, 3 x ava, outlaw
As for Eso2.2: 0 = full book, + 14 chapters. consecutive ids. Books aint recorded in the lore library automatically Oo]]
local DikiAchievstocheck = {1030,1043,1144,1319,1181,1341,1348,1318,1411,1412,1414,1415,1416,1417,1418,1422,1423,1545,1659,1424,1661,1662,1660,1676,1713,1714,1715,
							1795,1796,1797,1798,1932,1933,1934,1935,2023,2021,2022,2024,2098,2097,2044,2045,2120,2186,2187,2188,2285,2189,2190,2317,2318,2319,2359,
							2360,2361,2503,2504,2505,2506,2507,2630,2628,2629,2747,2748,2749,2750,2757,2761,2762,2763,2773,2776,2849,2850,2903,2904,2905,2926,2938,
							2959,2984,2991,2998,2999,3000,3001,3002,3094,3097,3098,3220,3228,3229,3258,3259,3260,}
local BooksWithoutAchievements = {71672,73838,73854}
DIKI.Styles = {
	["1030,0"]	= "alliance",
	["1030,7"]	= "16424",		-- 1  High Elves
	["1030,4"]	= "27245",		-- 2  Dark Elves
	["1030,8"]	= "16428",		-- 3  Wood Elves
	["1030,5"]	= "27244",		-- 4  Nords
	["1030,1"]	= "16425",		-- 5  Bretons
	["1030,2"]	= "16427",		-- 6  Redguards
	["1030,9"]	= "44698",		-- 7  Khajiit
	["1030,3"]	= "16426",		-- 8  Orcs
	["1030,6"]	= "27246",		-- 9  Argonians
	["1043,0"]	= "rares",
	["1043,2"]	= "54868",		-- 10 The Imperials
	["1043,1"]	= "51638",		-- 11 Ancient Elves
	["1043,3"]	= "51565",		-- 12 Barbaric
	["1043,4"]	= "51345",		-- 13 Primal
	["1043,5"]	= "51688",		-- 14 Daedric
	["1418,0"]	= "71765",		-- 29 Soul-shriven
}
-- Excluding 1..14, 29, 43, 46, 53
for i=0,14 do
	DIKI.Styles["1144,"..tostring(i)] = tostring(57572 + i)		-- 15 Dwemer
	DIKI.Styles["1319,"..tostring(i)] = tostring(64669 + i)		-- 16 Glass
	DIKI.Styles["1181,"..tostring(i)] = tostring(57834 + i)		-- 17 Xivkyn
	DIKI.Styles["1318,"..tostring(i)] = tostring(57590 + i)		-- 18 Akaviri
	DIKI.Styles["1348,"..tostring(i)] = tostring(64715 + i)		-- 19 Merco
	DIKI.Styles["1713,"..tostring(i)] = tostring(57605 + i)		-- 20 Yokudan
	DIKI.Styles["1341,"..tostring(i)] = tostring(69527 + i)		-- 21 Ancient Orc
	DIKI.Styles["1411,"..tostring(i)] = tostring(71550 + i)		-- 22 Trinimac
	DIKI.Styles["1412,"..tostring(i)] = tostring(71566 + i)		-- 23 Malacath
	DIKI.Styles["1417,"..tostring(i)] = tostring(71522 + i)		-- 24 Outlaw
	DIKI.Styles["1415,"..tostring(i)] = tostring(71688 + i)		-- 25 Dominion
	DIKI.Styles["1416,"..tostring(i)] = tostring(71704 + i)		-- 26 Covenant
	DIKI.Styles["1414,"..tostring(i)] = tostring(71720 + i)		-- 27 Pact
	DIKI.Styles["1797,"..tostring(i)] = tostring(71672 + i)		-- 28 Ra Gada
	DIKI.Styles["1933,"..tostring(i)] = tostring(73838 + i)		-- 30 Morag Tong
	DIKI.Styles["1676,"..tostring(i)] = tostring(73854 + i)		-- 31 Skinchanger
	DIKI.Styles["1422,"..tostring(i)] = tostring(74539 + i)		-- 32 Abah's Watch
	DIKI.Styles["1423,"..tostring(i)] = tostring(74555 + i)		-- 33 Thieves Guild
	DIKI.Styles["1424,"..tostring(i)] = tostring(76878 + i)		-- 34 Assassins League
	DIKI.Styles["1659,"..tostring(i)] = tostring(74652 + i)		-- 35 Dro-m'Athra
	DIKI.Styles["1661,"..tostring(i)] = tostring(82054 + i)		-- 36 Dark Brotherhood
	DIKI.Styles["1798,"..tostring(i)] = tostring(75228 + i)		-- 37 Ebony
	DIKI.Styles["1715,"..tostring(i)] = tostring(76894 + i)		-- 38 Draugr
	DIKI.Styles["1662,"..tostring(i)] = tostring(82071 + i)		-- 39 Minotaur
	DIKI.Styles["1660,"..tostring(i)] = tostring(82087 + i)		-- 40 Order of the Hour
	DIKI.Styles["1714,"..tostring(i)] = tostring(82006 + i)		-- 41 Celestial
	DIKI.Styles["1545,"..tostring(i)] = tostring(82022 + i)		-- 42 Hollowjack
-- 43 Grim Harlequin
	DIKI.Styles["1796,"..tostring(i)] = tostring(114967 + i)	-- 44 Silken Ring
	DIKI.Styles["1795,"..tostring(i)] = tostring(114951 + i)	-- 45 Mazzatun
-- 46 Frostcaster
	DIKI.Styles["1934,"..tostring(i)] = tostring(121316 + i)	-- 47 Buoyant Armiger
	DIKI.Styles["1932,"..tostring(i)] = tostring(124679 + i)	-- 48 Ashlander
	DIKI.Styles["1935,"..tostring(i)] = tostring(121348 + i)	-- 49 Militant Ordinator
	DIKI.Styles["2023,"..tostring(i)] = tostring(121332 + i)	-- 50 Telvanni
	DIKI.Styles["2021,"..tostring(i)] = tostring(129994 + i)	-- 51 Hlaalu
	DIKI.Styles["2022,"..tostring(i)] = tostring(130010 + i)	-- 52 Redoran
-- 53 Tsaesci
	DIKI.Styles["2098,"..tostring(i)] = tostring(132533 + i)	-- 54 Bloodforge
	DIKI.Styles["2097,"..tostring(i)] = tostring(132565 + i)	-- 55 Dreadhorn
	DIKI.Styles["2044,"..tostring(i)] = tostring(132549 + i)	-- 56 Apostle
	DIKI.Styles["2045,"..tostring(i)] = tostring(132581 + i)	-- 57 Ebonshadow
	DIKI.Styles["2190,"..tostring(i)] = tostring(134755 + i)	-- 58 Fang Lair
	DIKI.Styles["2189,"..tostring(i)] = tostring(134771 + i)	-- 59 Scalecaller
	DIKI.Styles["2120,"..tostring(i)] = tostring(134739 + i)	-- 60 Worm Cult
	DIKI.Styles["2186,"..tostring(i)] = tostring(137851 + i)	-- 61 Psijic
	DIKI.Styles["2187,"..tostring(i)] = tostring(137920 + i)	-- 62 Sapiarch
	DIKI.Styles["2188,"..tostring(i)] = tostring(140444 + i)	-- 63 Dremora
	DIKI.Styles["2285,"..tostring(i)] = tostring(140428 + i)	-- 64 Pyandonean
	DIKI.Styles["2317,"..tostring(i)] = tostring(140462 + i)	-- 65 Huntsman
	DIKI.Styles["2318,"..tostring(i)] = tostring(140478 + i)	-- 66 Silver Dawn
	DIKI.Styles["2319,"..tostring(i)] = tostring(140496 + i)	-- 67 Welkynar
	DIKI.Styles["2359,"..tostring(i)] = tostring(142186 + i)	-- 68 Honor Guard
	DIKI.Styles["2360,"..tostring(i)] = tostring(142202 + i)	-- 69 Dead-Water
	DIKI.Styles["2361,"..tostring(i)] = tostring(142218 + i)	-- 70 Elder Argonian
	DIKI.Styles["2503,"..tostring(i)] = tostring(147666 + i)	-- 71 Coldsnap
	DIKI.Styles["2504,"..tostring(i)] = tostring(147682 + i)	-- 72 Meridian
	DIKI.Styles["2505,"..tostring(i)] = tostring(147698 + i)	-- 73 Anequina
	DIKI.Styles["2506,"..tostring(i)] = tostring(147714 + i)	-- 74 Pellitine
	DIKI.Styles["2507,"..tostring(i)] = tostring(147730 + i)	-- 75 Sunspire
	DIKI.Styles["2630,"..tostring(i)] = tostring(156555 + i)	-- 76 Dragonguard
	DIKI.Styles["2629,"..tostring(i)] = tostring(156573 + i)	-- 77 Stags of Z'en
	DIKI.Styles["2628,"..tostring(i)] = tostring(156590 + i)	-- 78 Moongrave Fane
	DIKI.Styles["2024,"..tostring(i)] = tostring(130026 + i)	-- 79 Refabricated
	DIKI.Styles["2750,"..tostring(i)] = tostring(156627 + i)	-- 80 Shield of Senchal
	DIKI.Styles["2748,"..tostring(i)] = tostring(156608 + i)	-- 81 New Moon Priest
	DIKI.Styles["2747,"..tostring(i)] = tostring(157517 + i)	-- 82 Icereach Coven
	DIKI.Styles["2749,"..tostring(i)] = tostring(158291 + i)	-- 83 Pyre Watch
	DIKI.Styles["2757,"..tostring(i)] = tostring(160493 + i)	-- 84 Blackreach Vanguard
	DIKI.Styles["2761,"..tostring(i)] = tostring(160542 + i)	-- 85 Greymoor
	DIKI.Styles["2762,"..tostring(i)] = tostring(160559 + i)	-- 86 Sea Giant
	DIKI.Styles["2763,"..tostring(i)] = tostring(160576 + i)	-- 87 Ancestral Nord
	DIKI.Styles["2776,"..tostring(i)] = tostring(160610 + i)	-- 88 Ancestral Orc
	DIKI.Styles["2773,"..tostring(i)] = tostring(160593 + i)	-- 89 Ancestral High Elf
	DIKI.Styles["2849,"..tostring(i)] = tostring(166972 + i)	-- 90 Thorn Legion
	DIKI.Styles["2850,"..tostring(i)] = tostring(166989 + i)	-- 91 Hazardous Alchemy
	DIKI.Styles["2903,"..tostring(i)] = tostring(167173 + i)	-- 92 Ancestral Akaviri
	DIKI.Styles["2904,"..tostring(i)] = tostring(167190 + i)	-- 93 Ancestral Breton
	DIKI.Styles["2905,"..tostring(i)] = tostring(167270 + i)	-- 94 Ancestral Reach
	DIKI.Styles["2926,"..tostring(i)] = tostring(167943 + i)	-- 95 Nighthollow
	DIKI.Styles["2938,"..tostring(i)] = tostring(167960 + i)	-- 96 Arkthzand Armory
	DIKI.Styles["2998,"..tostring(i)] = tostring(167977 + i)	-- 97 Wayward Guardian
	DIKI.Styles["2959,"..tostring(i)] = tostring(170131 + i)	-- 98 House Hexos
	DIKI.Styles["2991,"..tostring(i)] = tostring(171580 + i)	-- 99 Waking Flame
	DIKI.Styles["2984,"..tostring(i)] = tostring(171551 + i)	-- 100 True-Sworn
	DIKI.Styles["3001,"..tostring(i)] = tostring(171895 + i)	-- 101 Ivory Brigade
	DIKI.Styles["3002,"..tostring(i)] = tostring(171912 + i)	-- 102 Sul-Xan
	DIKI.Styles["3000,"..tostring(i)] = tostring(171878 + i)	-- 103 Black Fin Legion
	DIKI.Styles["2999,"..tostring(i)] = tostring(171858 + i)	-- 104 Ancient Daedric
	DIKI.Styles["3094,"..tostring(i)] = tostring(176057 + i)	-- 105 Crimson Oath
	DIKI.Styles["3097,"..tostring(i)] = tostring(178504 + i)	-- 106 Silver Rose
	DIKI.Styles["3098,"..tostring(i)] = tostring(178528 + i)	-- 107 Annihilarch's
	DIKI.Styles["3220,"..tostring(i)] = tostring(178706 + i)	-- 108 Fargrave Guardian
-- 109
	DIKI.Styles["3228,"..tostring(i)] = tostring(181661 + i)	-- 110 Dreadsails
	DIKI.Styles["3229,"..tostring(i)] = tostring(181678 + i)	-- 111 Ascendant Order
	DIKI.Styles["3258,"..tostring(i)] = tostring(182520 + i)	-- 112 Syrabanic Marine
	DIKI.Styles["3259,"..tostring(i)] = tostring(182537 + i)	-- 113 Steadfast Society
	DIKI.Styles["3260,"..tostring(i)] = tostring(182554 + i)	-- 114 Systres Guardian
--	DIKI.Styles[","..tostring(i)] = tostring( + i)	--
-- Link for search new motifs :)
-- |H1:item:170137:5:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h
end
DIKI.CrownStyles = {
-- converts to normal table - to use the same check
	["64540"] = "16424",	-- 1  High Elf
	["64546"] = "27245",	-- 2  Dark Elf
	["64544"] = "16428",	-- 3  Wood Elf
	["64545"] = "27244",	-- 4  Nord
	["64541"] = "16425",	-- 5  Breton
	["64543"] = "16427",	-- 6  Redguard
	["64548"] = "44698",	-- 7  Khajiit
	["64542"] = "16426",	-- 8  Orc
	["64547"] = "27246",	-- 9  Argonian
	["64559"] = "54868",	-- 10 Imperial
	["64551"] = "51638",	-- 11 Ancient Elf
	["64550"] = "51565",	-- 12 Barbaric
	["64549"] = "51345",	-- 13 Primal
	["64552"] = "51688",	-- 14 Daedric
	["64553"] = "57572",	-- 15 Dwemer
	["64684"] = "64669",	-- 16 Glass
	["64556"] = "57834",	-- 17 Xivkyn
	["64554"] = "57590",	-- 18 Akaviri
	["64730"] = "64715",	-- 19 Mercenary
	["64555"] = "57605",	-- 20 Yokudan
	["69542"] = "69527",	-- 21 Ancient Orc
	["71565"] = "71550",	-- 22 Trinimac
	["71581"] = "71566",	-- 23 Malacath
	["71537"] = "71522",	-- 24 Outlaw
	["71703"] = "71688",	-- 25 Aldmeri Dominion
	["71719"] = "71704",	-- 26 Daggerfall Covenant
	["71735"] = "71720",	-- 27 Ebonheart Pact
	["71687"] = "71672",	-- 28 Ra Gada
-- 29 Soul-shriven
	["73853"] = "73838",	-- 30 Morag Tong
	["73869"] = "73854",	-- 31 Skinchanger
	["74554"] = "74539",	-- 32 Abah's Watch
	["74570"] = "74555",	-- 33 Thieves Guild
	["76893"] = "76878",	-- 34 Assassins League
	["74667"] = "74652",	-- 35 Dro-m'Athra
	["82069"] = "82054",	-- 36 Dark Brotherhood
	["75243"] = "75228",	-- 37 Ebony
	["76909"] = "76894",	-- 38 Draugr
	["82086"] = "82071",	-- 39 Minotaur
	["82102"] = "82087",	-- 40 Order Hour
	["82021"] = "82006",	-- 41 Celestial
-- 42 Hollowjack
--	["82053"] = "",	-- 43 Grim Harlequin
	["114982"] = "114967",	-- 44 Silken Ring
	["114966"] = "114951",	-- 45 Mazzatun
--	["96954"] = "",	-- 46 Frostcaster
	["121331"] = "121316",	-- 47 Buoyant Armiger
	["124694"] = "124679",	-- 48 Ashlander
	["121363"] = "121348",	-- 49 Militant Ordinator
	["121347"] = "121332",	-- 50 Telvanni
	["130009"] = "129994",	-- 51 Hlaalu
	["130025"] = "130010",	-- 52 Redoran
--	["132532"] = "",	-- 53 Tsaesci
	["132548"] = "132533",	-- 54 Bloodforge
	["132580"] = "132565",	-- 55 Dreadhorn
	["132564"] = "132549",	-- 56 Apostle
	["132596"] = "132581",	-- 57 Ebonshadow
	["134770"] = "134755",	-- 58 Fang Lair
	["134786"] = "134771",	-- 59 Scalecaller
	["134754"] = "134739",	-- 60 Worm Cult
	["137866"] = "137851",	-- 61 Psijic
	["137935"] = "137920",	-- 62 Sapiarch
	["140459"] = "140444",	-- 63 Dremora
	["139055"] = "140428",	-- 64 Pyandonean
	["140477"] = "140462",	-- 65 Huntsman
	["140493"] = "140478",	-- 66 Silver Dawn
	["140511"] = "140496",	-- 67 Welkynar
	["142201"] = "142186",	-- 68 Honor Guard
	["142217"] = "142202",	-- 69 Dead-Water
	["142233"] = "142218",	-- 70 Elder Argonian
	["147681"] = "147666",	-- 71 Coldsnap
	["147697"] = "147682",	-- 72 Meridian
	["147713"] = "147698",	-- 73 Anequina
	["147729"] = "147714",	-- 74 Pellitine
	["147745"] = "147730",	-- 75 Sunspire
	["156570"] = "156555",	-- 76 Dragonguard
	["156588"] = "156573",	-- 77 Stags of Z'en
	["156605"] = "156590",	-- 78 Moongrave Fane
	["130041"] = "130026",	-- 79 Refabricated
	["156642"] = "156627",	-- 80 Shield of Senchal
	["156623"] = "156608",	-- 81 New Moon Priest
	["157532"] = "157517",	-- 82 Icereach Coven
	["158306"] = "158291",	-- 83 Pyre Watch
	["160508"] = "160493",	-- 84 Blackreach Vanguard
	["160557"] = "160542",	-- 85 Greymoor
	["160574"] = "160559",	-- 86 Sea Giant
	["160591"] = "160576",	-- 87 Ancestral Nord
	["160625"] = "160610",	-- 88 Ancestral Orc
	["160608"] = "160593",	-- 89 Ancestral High Elf
	["166987"] = "166972",	-- 90 Thorn Legion
	["167004"] = "166989",	-- 91 Hazardous Alchemy
--	[""] = "",	-- 92 Ancestral Akaviri
	["167205"] = "167190",	-- 93 Ancestral Breton
	["167285"] = "167270",	-- 94 Ancestral Reach
	["167958"] = "167943",	-- 95 Nighthollow
	["167975"] = "167960",	-- 96 Arkthzand Armory
	["167992"] = "167977",	-- 97 Wayward Guardian
	["170146"] = "170131",	-- 98 House Hexos
	["171595"] = "171580",	-- 99 Waking Flame
	["171566"] = "171551",	-- 100 True-Sworn
	["171910"] = "171895",	-- 101 Ivory Brigade
	["171927"] = "171912",	-- 102 Sul-Xan
	["171893"] = "171878",	-- 103 Black Fin Legion
	["171873"] = "171858",	-- 104 Ancient Daedric
	["176072"] = "176057",	-- 105 Crimson Oath
	["178519"] = "178504",	-- 106 Silver Rose
	["178543"] = "178528",	-- 107 Annihilarch's
	["178721"] = "178706",	-- 108 Fargrave Guardian
--	[""] = "",	-- 109
	["181676"] = "181661", 	-- 110 Dreadsails
	["181693"] = "181678", 	-- 111 Ascendant Order
	["182535"] = "182520", 	-- 112 Syrabanic Marine
	["182552"] = "182537", 	-- 113 Steadfast Society
	["182569"] = "182554", 	-- 114 Systres Guardian
	[""] = "",	-- xx
}
for i = 1,14 do
	local a, b = 140267 + i, 140428 + i
	DIKI.CrownStyles["" .. a] = "" .. b	-- 64 Pyandonean Lists
end
DIKI.thisHasNothingToDoHere = {
-- here they forgot that all keys were trophies and not collectibles and mixed it up again
	["64574"] = "Clawed Key",
	["64576"] = "Planar Key",
	["64568"] = "Ethereal Key",
	["64570"] = "Legionary Key",
	["64491"] = "Carved-Bone Key",
	["64572"] = "Monstrous Enamel Key",
}
DIKI.AchToFish = {
	["471,0"] = "glenumbra",
	["471,1"] = "42898",		--hag fen hagfish
	["471,2"] = "42899",		--cambray perch
	["471,3"] = "42900",		--brook trout
	["471,4"] = "42901",		--azurain flounder
	["471,5"] = "45384",		--rock bass
	["471,6"] = "45385",		--powen
	["471,7"] = "45422",		--catfish
	["471,8"] = "45423",		--warmouth
	["471,9"] = "45460",		--lamprey
	["471,10"] = "45461",		--dragonfish
	["471,11"] = "45498",		--tuna
	["471,12"] = "45499",		--finless sole
	["472,0"] = "stormhaven",
	["472,1"] = "42902",		--gray loach
	["472,2"] = "42903",		--alcaire pike
	["472,3"] = "42904",		--silver walleye
	["472,4"] = "42905",		--dreugh shrimp
	["472,5"] = "45400",		--yellow bass
	["472,6"] = "45401",		--barfish
	["472,7"] = "45438",		--river stingray
	["472,8"] = "45439",		--grass carp
	["472,9"] = "45476",		--yellow moray
	["472,10"] = "45477",		--sawfish
	["472,11"] = "45514",		--stormhaven flounder
	["472,12"] = "45515",		--dab
	["473,0"] = "rivenspire",
	["473,1"] = "42906",		--snakehead
	["473,2"] = "42907",		--ichory chub
	["473,3"] = "42908",		--ruby tench
	["473,4"] = "42909",		--northpoint cod
	["473,5"] = "45394",		--nase
	["473,6"] = "45395",		--rivenspire trout
	["473,7"] = "45432",		--turbot
	["473,8"] = "45433",		--stream catfish
	["473,9"] = "45470",		--writhing scrab
	["473,10"] = "45471",		--ribbon eel
	["473,11"] = "45508",		--hake
	["473,12"] = "45509",		--dusky grouper
	["474,0"] = "alik'r desert",
	["474,1"] = "42910",		--sand eel
	["474,2"] = "42911",		--desert pupfish
	["474,3"] = "42912",		--midget salmon
	["474,4"] = "42913",		--bonefish
	["474,5"] = "45368",		--saw belly
	["474,6"] = "45369",		--lungfish
	["474,7"] = "45406",		--banded killifish
	["474,8"] = "45407",		--driftfish
	["474,9"] = "45444",		--cutthroat eel
	["474,10"] = "45445",		--sand moray
	["474,11"] = "45482",		--alewife
	["474,12"] = "45483",		--sablefish
	["475,0"] = "bangkorai",
	["475,1"] = "42914",		--scaly lungfish
	["475,2"] = "42915",		--lake snapper
	["475,3"] = "42916",		--prickleback
	["475,4"] = "42917",		--bjoulsae hake
	["475,5"] = "45372",		--paddlefish
	["475,6"] = "45373",		--gar
	["475,7"] = "45410",		--lenok
	["475,8"] = "45411",		--pupfish
	["475,9"] = "45448",		--panga
	["475,10"] = "45487",		--morid cod
	["475,11"] = "45486",		--toadfish
	["475,12"] = "45449",		--swai
	["477,0"] = "stonefalls",
	["477,1"] = "42949",		--scum carp
	["477,2"] = "42879",		--rainbow zander
	["477,3"] = "42880",		--ash shad
	["477,4"] = "42881",		--akaviri wrasse
	["477,5"] = "45398",		--tench
	["477,6"] = "45399",		--lake chub
	["477,7"] = "45436",		--ricefish
	["477,8"] = "45437",		--thorny catfish
	["477,9"] = "54368",		--stinkfish
	["477,10"] = "45475",		--fungusfish
	["477,11"] = "45512",		--travally
	["477,12"] = "45513",		--armorhead
	["478,0"] = "deshaan",
	["478,1"] = "42882",		--mud lamprey
	["478,2"] = "42883",		--old man gar
	["478,3"] = "42884",		--toadstool tilapia
	["478,4"] = "42885",		--pikeblenny
	["478,5"] = "45380",		--ide
	["478,6"] = "45381",		--gourami
	["478,7"] = "45418",		--deshaan chub
	["478,8"] = "45419",		--cutthroat trout
	["478,9"] = "45456",		--mustard eel
	["478,10"] = "45457",		--mouthbrooder
	["478,11"] = "45494",		--gibberfish
	["478,12"] = "45495",		--monkfish
	["479,0"] = "shadowfen",
	["479,1"] = "42886",		--toxic xoach
	["479,2"] = "42887",		--histcarp
	["479,3"] = "42888",		--shark tadpole
	["479,4"] = "42889",		--coelacanth
	["479,5"] = "45396",		--zander
	["479,6"] = "45397",		--quillback
	["479,7"] = "45434",		--boga
	["479,8"] = "45435",		--hardyhead
	["479,9"] = "45472",		--pricklefish
	["479,10"] = "45474",		--eel-goby
	["479,11"] = "45510",		--orange roughy
	["479,12"] = "45511",		--opah
	["480,0"] = "eastmarch",
	["480,1"] = "42890",		--ice remora
	["480,2"] = "42891",		--king sturgeo
	["480,3"] = "42892",		--white river pickerel
	["480,4"] = "42893",		--ghost haddock
	["480,5"] = "45382",		--eastmarch pike
	["480,6"] = "45383",		--char
	["480,7"] = "45420",		--steelhead
	["480,8"] = "45421",		--ice fish
	["480,9"] = "45458",		--snipe eel
	["480,10"] = "45459",		--modoc sucker
	["480,11"] = "45496",		--golem shark
	["480,12"] = "45497",		--pigfish
	["481,0"] = "rift",
	["481,1"] = "42894",		--sulfursucker
	["481,2"] = "42895",		--ilinalta trout
	["481,3"] = "42896",		--muskellunge
	["481,4"] = "42897",		--white roughy
	["481,5"] = "45402",		--zebra oto
	["481,6"] = "45403",		--jarl salmon
	["481,7"] = "45440",		--sockeye salmon
	["481,8"] = "45441",		--grouper
	["481,9"] = "45478",		--bream
	["481,10"] = "45480",		--skate
	["481,11"] = "45516",		--skorrn
	["481,12"] = "45517",		--ice koi
	["483,0"] = "auridon",
	["483,1"] = "42918",		--blue monkfish
	["483,2"] = "42919",		--ilyadifish
	["483,3"] = "42920",		--shimmerpike
	["483,4"] = "42921",		--thrassian eel
	["483,5"] = "45370",		--barbel
	["483,6"] = "45371",		--sturgeon
	["483,7"] = "45408",		--blackspotted pike
	["483,8"] = "45409",		--muskie
	["483,9"] = "45446",		--bristlemouths
	["483,10"] = "45447",		--mudfish
	["483,11"] = "45484",		--eucla cod
	["483,12"] = "45485",		--mola
	["484,0"] = "grahtwood",
	["484,1"] = "42922",		--bilious catfish
	["484,2"] = "42923",		--stickleback
	["484,3"] = "42924",		--greater fangfin
	["484,4"] = "42925",		--magrove shark
	["484,5"] = "45386",		--koi
	["484,6"] = "45414",		--dreughfish
	["484,7"] = "45424",		--tiger perch
	["484,8"] = "45425",		--hog sucker
	["484,9"] = "45462",		--snapper eel
	["484,10"] = "45463",		--swamp eel
	["484,11"] = "45500",		--devil ray
	["484,12"] = "45501",		--mojarra
	["485,0"] = "greenshade",
	["485,1"] = "42926",		--viperfish
	["485,2"] = "42927",		--jungle bass
	["485,3"] = "42928",		--xylo piranha
	["485,4"] = "42929",		--zebra pompano
	["485,5"] = "45388",		--murray cod
	["485,6"] = "45389",		--archerfish
	["485,7"] = "45426",		--walleye
	["485,8"] = "45427",		--lyretail
	["485,9"] = "45464",		--wolf-eel
	["485,10"] = "45465",		--cusk eel
	["485,11"] = "45502",		--triggerfish
	["485,12"] = "45503",		--manefish
	["486,0"] = "malabal tor",
	["486,1"] = "42930",		--ouze toadfish
	["486,2"] = "42931",		--z'en's whitefish
	["486,3"] = "42932",		--strident leechfin
	["486,4"] = "42933",		--abecean halibut
	["486,5"] = "45390",		--inconnu
	["486,6"] = "45391",		--arowana
	["486,7"] = "45428",		--mrigal
	["486,8"] = "45429",		--stonefish
	["486,9"] = "45466",		--stargazer
	["486,10"] = "45467",		--ghastel bass
	["486,11"] = "45504",		--ono
	["486,12"] = "45505",		--sea bass
	["487,0"] = "reaper's march",
	["487,1"] = "42934",		--slimeslither
	["487,2"] = "42935",		--forest bream
	["487,3"] = "42936",		--strid shad
	["487,4"] = "42937",		--preposterous mackerel
	["487,5"] = "45392",		--ladyfish
	["487,6"] = "45393",		--brown trout
	["487,7"] = "45430",		--flying fish
	["487,8"] = "45431",		--sweetfish
	["487,9"] = "45468",		--reaper's eel
	["487,10"] = "45469",		--brotula
	["487,11"] = "45506",		--sheepshead
	["487,12"] = "45507",		--red gurnard
	["489,0"] = "cyrodiil",
	["489,1"] = "42938",		--sewer eel
	["489,2"] = "42939",		--runmare bream
	["489,3"] = "42940",		--nibenay trout
	["489,4"] = "42941",		--topal fanche
	["489,5"] = "45378",		--rainbow fish
	["489,6"] = "45379",		--yellow perch
	["489,7"] = "45416",		--glassfish
	["489,8"] = "45417",		--pirate perch
	["489,9"] = "45454",		--quillfish
	["489,10"] = "45455",		--pufferfish
	["489,11"] = "45492",		--emperor angelfish
	["489,12"] = "45493",		--jewel fish
	["490,0"] = "coldharbour",
	["490,1"] = "42942",		--moray leech
	["490,2"] = "42943",		--heinous gar
	["490,3"] = "42944",		--ghoulfish
	["490,4"] = "42945",		--stingerpike
	["490,5"] = "45374",		--plasm darter
	["490,6"] = "45375",		--azure eel
	["490,7"] = "45412",		--blue slimefish
	["490,8"] = "45413",		--harbour gar
	["490,9"] = "45450",		--bichir
	["490,10"] = "45451",		--cavefish
	["490,11"] = "45488",		--fang shark
	["490,12"] = "45489",		--venomfish
	["916,0"] = "craglorn",
	["916,1"] = "55264",		--glasshead barreleye
	["916,2"] = "55265",		--crag salmon
	["916,3"] = "55266",		--forlorn catfish
	["916,4"] = "55267",		--ghost knifefish
	["916,5"] = "55268",		--nirn flounder
	["916,6"] = "55269",		--spiny orcfish
	["916,7"] = "55270",		--yokudan cod
	["916,8"] = "55271",		--nedic eel
	["916,9"] = "55272",		--dragon goby
	["916,10"] = "55273",		--croaker
	["916,11"] = "55274",		--bitterling
	["916,12"] = "55275",		--mermouth
	["1186,0"] = "imperial city",
	["1186,1"] = "68146",		--aphotic batfish
	["1186,2"] = "68149",		--blobfin
	["1186,3"] = "68144",		--cannibal lancet
	["1186,4"] = "68147",		--flabby whalefish
	["1186,5"] = "68145",		--glow-spotted blenny
	["1186,6"] = "68153",		--guiyu
	["1186,7"] = "68151",		--hatchetfish
	["1186,8"] = "68154",		--humpback angler
	["1186,9"] = "68155",		--imperial loosejaw
	["1186,10"] = "68152",		--scabrous grenadier
	["1186,11"] = "68148",		--trapjaw eel
	["1186,12"] = "68150",		--wen loach
	["1340,0"] = "wrothgar",
	["1340,1"] = "68161",		--black scabbardfish
	["1340,2"] = "68159",		--blue-ringed octopus
	["1340,3"] = "68162",		--chinlea
	["1340,4"] = "68156",		--giant hammerjaw
	["1340,5"] = "68165",		--greater ashmouth
	["1340,6"] = "68160",		--hairy coffinfish
	["1340,7"] = "68166",		--lesser ashmouth
	["1340,8"] = "68158",		--matron eelpout
	["1340,9"] = "68164",		--nelma
	["1340,10"] = "68167",		--pariah lumpfish
	["1340,11"] = "68163",		--tum weever
	["1340,12"] = "68157",		--vorkhiposh
	["1351,0"] = "hew's bane",
	["1351,1"] = "71767",		--cichlid
	["1351,2"] = "71768",		--cherry barb
	["1351,3"] = "71769",		--bala shark
	["1351,4"] = "71770",		--sparking anglermouth
	["1351,5"] = "71771",		--crestfish
	["1351,6"] = "71772",		--begger shark",beggar // only typo in english
	["1351,7"] = "71773",		--glass catfish
	["1351,8"] = "71774",		--firemouth
	["1351,9"] = "71775",		--hew's rasbora
	["1351,10"] = "71776",		--keuppia
	["1351,11"] = "71777",		--fringed mudskipper
	["1351,12"] = "71778",		--daggertooth
------- ONE FISH/ACHIEV wrothgar/noob islands
	["1339,0"] = "71099",		--unique purple in wrothgar
	["1339,1"] = "71099",		--unique purple in wrothgar - has a criterion too
	["491,0"] = "stros m'kai",
	["491,1"] = "42946",		--eltheric grouper
	["492,0"] = "khenarthi's roost",
	["492,1"] = "42948",		--pyandonean ray
	["493,0"] = "bleakrock",
	["493,1"] = "42947",		--inner sea scalyfin
}
DIKI.AchToTrophy = {
	["838,0"] = "tamriel beast collector",
	["838,1"] = "54185",		--shimmering alit bezoar
	["838,2"] = "54184",		--magnificent bat pelt
	["838,3"] = "54186",		--gnarled bear claw
	["838,4"] = "54187",		--wolf's tooth necklace
	["838,5"] = "54188",		--cat's claw
	["838,6"] = "54189",		--inert egg
	["838,7"] = "54190",		--malformed kagouti tusk
	["838,8"] = "54195",		--huge mammoth's tooth
	["838,9"] = "54196",		--buzzing spine
	["838,10"] = "54197",		--bile gilt
	["838,11"] = "54198",		--cruel collar
	["838,12"] = "54338",		--scaly durzog hide
	["841,0"] = "undead hoarder",
	["841,1"] = "54199",		--hand of glory
	["841,2"] = "54200",		--chattering skull
	["841,3"] = "54201",		--wraith shackle
	["841,4"] = "54202",		--crypt jar
	["841,5"] = "54203",		--twitching draugr hand
	["841,6"] = "54204",		--ectoplasmic discharge
	["842,0"] = "chitin accumulator",
	["842,1"] = "54205",		--petrified spider egg
	["842,2"] = "54206",		--calcified cuttle
	["842,3"] = "54207",		--razor-edged mandible
	["842,4"] = "54208",		--luminous blood sac
	["842,5"] = "54209",		--polished shell shard
	["842,6"] = "54210",		--prized barb
	["842,7"] = "54211",		--multifaceted eye
	["842,8"] = "54212",		--gossamer winglet
	["843,0"] = "nature collector",
	["843,1"] = "54215",		--primal sproutling
	["843,2"] = "54216",		--lashing tentacle
	["843,3"] = "54217",		--brass anklets
	["843,4"] = "54218",		--imp's effigy
	["843,5"] = "54219",		--icebound vertebra
	["843,6"] = "54220",		--knotted heart
	["843,7"] = "54221",		--glowing remnant
	["844,0"] = "monstrous component collector",
	["844,1"] = "54222",		--werewolf's cameo
	["844,2"] = "54223",		--nose shackle
	["844,3"] = "54224",		--troll skull
	["844,4"] = "54225",		--ogre toe ring
	["844,5"] = "54226",		--stony heart
	["844,6"] = "54227",		--second skin
	["844,7"] = "54228",		--flawless tail feather
	["846,0"] = "dwarven secrets gatherer",
	["846,1"] = "54213",		--perfectly balanced gyro
	["846,2"] = "54214",		--whirring dynamo
	["847,0"] = "atronach element collector",
	["847,1"] = "54229",		--smoldering ember heart
	["847,2"] = "54230",		--fleshy symbiont
	["847,3"] = "54231",		--everfrost
	["847,4"] = "54232",		--crackling lodestone
	["848,0"] = "oblivion shard gatherer",
	["848,1"] = "54233",		--banekin horn
	["848,2"] = "54234",		--daedric dewclaw
	["848,3"] = "54235",		--burning daedroth eye
	["848,4"] = "54236",		--blighted iron collar
	["848,5"] = "54237",		--spider's crown
}

function DIKI:RecordRecipes(mychar)
	local function AddIdRecipetoDB(itemname,foodlink)
		local shortid = select(4, ZO_LinkHandler_ParseLink(foodlink))
		DIKI.SavedVars.RecipesList[itemname]["id"] = shortid
	end
	for k,v in pairs (DIKI.SavedVars.RecipesList) do
		if v.recipeType then v.recipeType = nil end-- food or drink 1 or 2
		if v.recipeIndex then v.recipeIndex = nil end
	end
	local food = 1
	local drink = 1
	local numlists = GetNumRecipeLists()
	for i = 1,numlists,1 do
		local namelist,numrecipes = GetRecipeListInfo(i)
		for j=1,numrecipes,1 do
			local known = GetRecipeInfo(i,j)
			local recipename = GetRecipeResultItemInfo(i,j)
			recipename = string.lower(recipename)
			local itemLink = GetRecipeResultItemLink(i,j)
			local itemType = GetItemLinkItemType(itemLink)
			if known == true then	--checks if char list exists for that item
				if not DIKI.SavedVars.RecipesList[recipename] then DIKI.SavedVars.RecipesList[recipename] = {} end
				AddIdRecipetoDB(recipename,itemLink)
				if itemType == ITEMTYPE_FOOD then
					DIKI.SavedVars.RecipesList[recipename]["recipeType"] = 1
					DIKI.SavedVars.RecipesList[recipename]["recipeIndex"] = food
					food = food + 1
				end
				if itemType == ITEMTYPE_DRINK then
					DIKI.SavedVars.RecipesList[recipename]["recipeType"] = 2
					DIKI.SavedVars.RecipesList[recipename]["recipeIndex"] = drink
					drink = drink + 1
				end
				DIKI.SavedVars.RecipesList[recipename]["recipeListIndex"] = i
				DIKI.SavedVars.RecipesList[recipename]["recipeIndexByList"] = j
				--check if the achievement is already registered
				local isthere = 0
				for key,v in pairs(DIKI.SavedVars.RecipesList[recipename]) do
					if v == mychar then isthere = 1 end
				end
				--store if new
				if isthere == 0 then table.insert(DIKI.SavedVars.RecipesList[recipename], mychar)	end
			end
		end
	end
end

function DIKI:RecordFishes(categorie,mychar)
	local function GetFishingAchievements()
		DIKI.FishesAchievs = {1340,1186,1351,1339}	--DLCs
		local TrophyCatId = nil
		local NumSubCat = 0
		local NumAchCats = GetNumAchievementCategories()
		for i = 1, NumAchCats, 1 do
			local CurrentCatIcon = GetAchievementCategoryKeyboardIcons(i)
			if CurrentCatIcon == categorie then
				TrophyCatId = i
			break
			end
		end
		if TrophyCatId == nil then return end
		-- Record Fishes
		local _,NumSubCat,numach = GetAchievementCategoryInfo(TrophyCatId)
		for i = 1, NumSubCat, 1 do
		local subname,NumSubCatAch = GetAchievementSubCategoryInfo(TrophyCatId,i)
			for j = 1, NumSubCatAch, 1 do
				local id = GetAchievementId(TrophyCatId,i,j)
				table.insert(DIKI.FishesAchievs,id)
			end
		end	-- all fishing achievs must be in the table at that point.
	end
	if DIKI.FishesAchievs == nil then GetFishingAchievements() end	--only once at startup
	--we gonna record the itemID like for the books.
	local idach = 0
	local dummy = ""
	local desc,completed,required = "",0,0
	for i=1, #DIKI.FishesAchievs do
		idach = DIKI.FishesAchievs[i]
		local numcrit = GetAchievementNumCriteria(idach)
		for j = 0, numcrit do
			if j == 0 then
				if IsAchievementComplete(idach) == true then completed = 1 end
			end
			if j > 0 then desc,completed,required = GetAchievementCriterion(idach,j) end
			if (completed == 1) then					--if the achievement has been completed already
			dummy = tostring(idach)..","..tostring(j)
			if DIKI.AchToFish[dummy] then	-- for early release if ach don't exist yet
				if not (DIKI.SavedVars.FishesList[DIKI.AchToFish[dummy]]) then DIKI.SavedVars.FishesList[DIKI.AchToFish[dummy]] = {} end		--checks if char list exists for that item
					local isthere = 0	--check if the achievement is already registered
					for k,v in pairs(DIKI.SavedVars.FishesList[DIKI.AchToFish[dummy]]) do
						if v == mychar then isthere = 1 end
					end
					if isthere == 0 then table.insert(DIKI.SavedVars.FishesList[DIKI.AchToFish[dummy]], mychar) end	-- add only if new. reduce possible mix up at startup. drawback: character deletion.
				end--/if achievement completed
			end
		end--/criteria browser
	end	--/end browse relevant achievements
end

function DIKI:RecordTrophies(categorie,mychar)
	local function GetTrophiesAchievements()
		DIKI.TrophiesAchievs = {}	--DLCs
		local TrophyCatId = nil
		local NumSubCat = 0
		local NumAchCats = GetNumAchievementCategories()
		for i = 1, NumAchCats, 1 do
			local CurrentCatIcon = GetAchievementCategoryKeyboardIcons(i)
			if CurrentCatIcon == categorie then
				TrophyCatId = i
			break
			end
		end
		if TrophyCatId == nil then return end
		-- Record Trophies achievement ids
		local _,_,numach = GetAchievementCategoryInfo(TrophyCatId)
		for i = 1, numach, 1 do
			local idach = GetAchievementId(TrophyCatId,nil,i)			-- achievs in the main branch of that tree = general tab = mob trophies for now.
			table.insert(DIKI.TrophiesAchievs,idach)
		end
	end
	local function callback(icon, text)	-- thx votan in RFT
		-- launch an alert
		CENTER_SCREEN_ANNOUNCE:AddMessage(EVENT_SKILL_XP_UPDATE, CSA_EVENT_SMALL_TEXT, SOUNDS.QUEST_OBJECTIVE_INCREMENT, zo_strformat("<<1>> <<2>>", icon, text))
	end
	if DIKI.TrophiesAchievs == nil then GetTrophiesAchievements() end	--only once at startup
	local idach = 0
	local dummy = ""
	local desc,completed,required = "",0,0
	local iconSize = 30
	for i=1, #DIKI.TrophiesAchievs do
		idach = DIKI.TrophiesAchievs[i]
		local numcrit = GetAchievementNumCriteria(idach)
		local _, _, _, icon = GetAchievementInfo(idach)
		for j = 0, numcrit do
			if j == 0 then
				if IsAchievementComplete(idach) == true then completed = 1 end
			end
			if j > 0 then desc,completed,required = GetAchievementCriterion(idach,j) end
			if (completed == 1) then					--if the achievement has been completed already
			dummy = tostring(idach)..","..tostring(j)
			if DIKI.AchToTrophy[dummy] then	-- for early release if ach don't exist yet
				if not (DIKI.SavedVars.TrophiesList[DIKI.AchToTrophy[dummy]]) then DIKI.SavedVars.TrophiesList[DIKI.AchToTrophy[dummy]] = {} end		--checks if char list exists for that item
					local isthere = 0	--check if the achievement is already registered
					for k,v in pairs(DIKI.SavedVars.TrophiesList[DIKI.AchToTrophy[dummy]]) do
						if v == mychar then isthere = 1 end
					end
					if isthere == 0 then
						table.insert(DIKI.SavedVars.TrophiesList[DIKI.AchToTrophy[dummy]], mychar)
						if DIKI.showTrophyMessage then
							callback(zo_iconFormat(icon, iconSize, iconSize), desc)
							DIKI.showTrophyMessage = false
						end
					end	-- add only if new. reduce possible mix up at startup. drawback: character deletion.
				end--/if achievement completed
			end
		end--/criteria browser
	end	--/end browse relevant achievements
end

function DIKI:RecordCraft(mychar)
	local idach = 0
	local dummy = ""
	local desc,completed,required = "",0,0
	for i=1, #DikiAchievstocheck do
		idach = DikiAchievstocheck[i]
		local numcrit = GetAchievementNumCriteria(idach)
		for j = 0, numcrit do
			if j == 0 then
				if IsAchievementComplete(idach) == true then completed = 1 end
			end
			if j > 0 then desc,completed,required = GetAchievementCriterion(idach,j) end
			if (completed == 1) then					--if the achievement has been completed already
			dummy = tostring(idach)..","..tostring(j)
			if DIKI.Styles[dummy] then	-- for early release if achievement doesn't exist yet
				if not (DIKI.SavedVars.Books[DIKI.Styles[dummy]]) then DIKI.SavedVars.Books[DIKI.Styles[dummy]] = {} end		--checks if char list exists for that item
					local isthere = 0	--check if the achievement is already registered
					for k,v in pairs(DIKI.SavedVars.Books[DIKI.Styles[dummy]]) do
						if v == mychar then isthere = 1 end
					end
					if isthere == 0 then table.insert(DIKI.SavedVars.Books[DIKI.Styles[dummy]], mychar) end	-- add only if new. reduce possible mix up at startup. drawback: character deletion.
				end--/if achievement completed
			end
		end--/criteria browser
	end	--/end browse relevant achievements
	for key,val in pairs(BooksWithoutAchievements) do
		local TotalBooksKnownInSerie = 0
		for i=1,14 do
			local id = val + i
			local dummylink = zo_strformat("|H0:item:<<1>>:25:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", id)
			if IsItemLinkBookKnown(dummylink) == true then													-- doesn't work with full book (i=0)
			TotalBooksKnownInSerie = TotalBooksKnownInSerie + 1
				if not DIKI.SavedVars.Books[tostring(id)] then DIKI.SavedVars.Books[tostring(id)] = {} end
				local isthere = 0	--check if the achievement is already registered
				for k,v in pairs(DIKI.SavedVars.Books[tostring(id)]) do
					if v == mychar then isthere = 1 end
				end
				if isthere == 0 then table.insert(DIKI.SavedVars.Books[tostring(id)], mychar) end
			end
		end
		if TotalBooksKnownInSerie == 14 then																	-- recap full books
			if not DIKI.SavedVars.Books[tostring(val)] then DIKI.SavedVars.Books[tostring(val)] = {} end
			local isthere = 0	--check if the achievement is already registered
			for k,v in pairs(DIKI.SavedVars.Books[tostring(val)]) do
				if v == mychar then isthere = 1 end
			end
			if isthere == 0 then table.insert(DIKI.SavedVars.Books[tostring(val)], mychar) end
		end
	end
end



function DIKI.UpdateMotifs()
	DIKI:RecordCraft(GetUnitName("player"))								--Motifs	-- in case no achiev
end
function DIKI.UpdateRecipes()
	DIKI:RecordRecipes(GetUnitName("player"))
end
function DIKI.UpdateCollectibles(event, achId)
	if DIKI.AchToFish[tostring(achId)..",0"] then
		DIKI:RecordFishes(DIKI.TrophyIcon,GetUnitName("player"))
	end
	if DIKI.AchToTrophy[tostring(achId)..",0"] then
		DIKI.showTrophyMessage = true
		DIKI:RecordTrophies(DIKI.TrophyIcon,GetUnitName("player"))
	end
end

local function MakeStrKnown(tab)
	local t, p, f = {}, GetUnitName("player"), false
	for k,v in pairs(tab) do
		if p==v then f=true else t[#t+1]=v end
	end
	table.sort(t)
	if f then return ("|cBBFFBB" .. p .. "|r, " .. table.concat(t, ", ")) end
	return table.concat(t, ", ")
end
local function MakeStrUnKnown(tab)
	local t, p, f = {}, GetUnitName("player"), false
	for k,v in pairs(tab) do
		if (v) then
			if p==k then f=true else t[#t+1]=k end
		end
	end
	table.sort(t)
	if f then return ("|cFFBBBB" .. p .. "|r, " .. table.concat(t, ", ")) end
	return table.concat(t, ", ")
end

--[[local function strtocompare(varstr)										-- transform string into pattern for comparison w/ gender and number, not used anymore but can be handy
	local magictab = {"^","$","(",")","%",".","[","]","*","+","-","?",}		--magic characters
	for k,v in pairs(magictab) do
		v = "%"..v
		varstr = string.gsub(varstr, v, "%%"..v)
	end
	varstr = "^"..varstr.."%^?p?s?f?m?n?s?p?$"
	return varstr
end]]

local function GetKnownInfo(itemid,itemType)							-- Lists to display
	local charswhoknow = {nodata = "nodata"}							--in case of new sub category
	local shortid = select(4, ZO_LinkHandler_ParseLink(itemid))
	local itemname = ""
	-- if (itemType == ITEMTYPE_TROPHY) then		-- why are they still here, and not under collectibles? pb with treasure maps and dungeon trophies // now they are under collectibles API 2.1
	if itemType == ITEMTYPE_COLLECTIBLE then
		if (DIKI.thisHasNothingToDoHere[shortid]) then return "null","null" end	-- keys and other gizmos
		charswhoknow = {}

		local itemlvl = select(6, ZO_LinkHandler_ParseLink(itemid))
		itemlvl = tonumber(itemlvl)

		if itemlvl > 1 then		-- former mob TROPHIES lvl 4 min.
			if DIKI.TrophiesOn <= 0 then return "null","null" end
			local isreferenced = 0
			for k,v in pairs(DIKI.AchToTrophy) do
				if v == shortid then isreferenced = isreferenced + 1 end
			end
			if isreferenced == 0 then return "nodata","nodata" end		-- if new items are added, display n/a instead of unknown by all.
			if (DIKI.SavedVars.TrophiesList[shortid]) then
				for k,v in pairs(DIKI.SavedVars.TrophiesList[shortid]) do
					charswhoknow[k] = v
				end
			end
		end
		if itemlvl == 1 then	-- fishes still lvl 1
			if DIKI.FishesOn <= 0 then return "null","null" end
			local isfishreferenced = 0
			for k,v in pairs(DIKI.AchToFish) do
				if v == shortid then isfishreferenced = isfishreferenced + 1 end
			end
			if isfishreferenced == 0 then return "nodata","nodata" end		-- if new fishes are added, display n/a instead of unknown by all.
			if (DIKI.SavedVars.FishesList[shortid]) then
				for k,v in pairs(DIKI.SavedVars.FishesList[shortid]) do
					charswhoknow[k] = v
				end
			end
		end
	end

	if (itemType == ITEMTYPE_RECIPE) then								--recipes are activated or we wouldnt be there
		itemname = string.lower(GetItemLinkName(GetItemLinkRecipeResultItemLink(itemid)))
		charswhoknow = {}
		if (DIKI.SavedVars.RecipesList[itemname]) then
			for k,v in pairs(DIKI.SavedVars.RecipesList[itemname]) do
				if type(k) ~= "string" then charswhoknow[k] = v end
			end
		end
	end
	if (itemType == ITEMTYPE_FOOD or itemType == ITEMTYPE_DRINK) then	--food&drink activated or we wouldn't be there.
		itemname = string.lower(GetItemLinkName(itemid))
		charswhoknow = {}
		if (DIKI.SavedVars.RecipesList[itemname]) then
			for k,v in pairs(DIKI.SavedVars.RecipesList[itemname]) do
				if type(k) ~= "string" then charswhoknow[k] = v end
			end
		end
	end
	if (itemType == ITEMTYPE_RACIAL_STYLE_MOTIF) then					--motifs are activated or we wouldnt be there
		local isbookreferenced = 0
		if DIKI.CrownStyles[shortid] then shortid = DIKI.CrownStyles[shortid] end	-- crown books
		for k,v in pairs(DIKI.Styles) do
			if v == shortid then isbookreferenced = isbookreferenced + 1 end
		end
		for _,v in pairs(BooksWithoutAchievements) do
			if tonumber(shortid) >= v and tonumber(shortid) <= v+14 then isbookreferenced = isbookreferenced + 1 end
		end
		if isbookreferenced == 0 then return "nodata","nodata" end		-- if new books are added, display n/a instead of unknown.
		charswhoknow = {}
		if (DIKI.SavedVars.Books[shortid]) then
			for k,v in pairs(DIKI.SavedVars.Books[shortid]) do
				charswhoknow[k] = v
			end
		end
	end
	local listcharstemp = {}
	if (charswhoknow.nodata) then listcharstemp = {nodata = 1} else		--this to avoid potential new subcategorie of trophies to be registerded as unknown instead of N/A.
		for k,v in pairs(CharsList) do
			listcharstemp[v] = 1
		end
		for k,v in pairs(charswhoknow) do
			if not livesHere[v] then charswhoknow[k] = nil end
		end
		for k,v in pairs(charswhoknow) do
			listcharstemp[v] = nil
		end
	end
	return MakeStrKnown(charswhoknow), MakeStrUnKnown(listcharstemp)
end

function sameMegaServer(id1, id2)
	-- old indexes are (small) numbers
	-- new indexes are ( big ) numbers, converted to string (character ids)
	-- I know no way of checking on which megaserver is another
	-- character, so, since ids on NA seem to be within
	-- [8796000000000000..8797999999999999], and ids on EU within
	-- [8798000000000000..8799999999999999], we'll be doing a little
	-- math to try to guess if both id belong to the same megaserver...
	id1 = math.floor(tonumber(id1) / 2000000000000)
	id2 = math.floor(tonumber(id2) / 2000000000000)
	return (id1 == 0) or (id2 == 0) or (id1 == id2)
end

function DIKI:Initialize()
--default vars
	local defaults = {
		CharsList = {},
		TrophiesList = {},
		RecipesList = {},
		FishesList = {},
		Books = {},
	}

	--DIKI.SavedVars = ZO_SavedVars:NewAccountWide("DIKIVars", 2, nil, defaults)
	DIKI.SavedVars = ZO_SavedVars:NewAccountWide("DIKIVars", 2, nil, defaults, nil, "AcrossAllAcounts")
	--DIKI.SavedVars = ZO_SavedVars:NewAccountWide("DIKIVars", 2, nil, defaults, nil, "AcrossAllAcounts" .. string.sub(GetWorldName(),1,2))

--set language to current setting if not en.
	DIKI.lg = "en"
	local lang = GetCVar("Language.2")
	if lang == "fr" or lang == "de" or lang == "ru" then
		DIKI.lg = lang
	end
--Add character to CharsList if not done already
	local addName = true
	local myIndex
	myId = GetCurrentCharacterId()
	for k, v in pairs(DIKI.SavedVars.CharsList) do
		if GetUnitName("player") == v then
			addName = false
			myIndex = k
		end
		if sameMegaServer(myId, k) then
			table.insert(CharsList, v)
			livesHere[v] = true
		end
	end
	if addName then
		DIKI.SavedVars.CharsList[myId] = GetUnitName("player")
	elseif type(myIndex) == "number" then	-- old format
		DIKI.SavedVars.CharsList[myIndex] = nil
		DIKI.SavedVars.CharsList[myId] = GetUnitName("player")
	end
--Record Entries for our char
	DIKI:RecordFishes(DIKI.TrophyIcon,GetUnitName("player"))		--check on the texture : thanks to Rare Fish tracker's authors (katkat42 and Votan)
	DIKI:RecordTrophies(DIKI.TrophyIcon,GetUnitName("player"))
	DIKI:RecordCraft(GetUnitName("player"))							--Motifs we gonna check only specifics Achievements by their ID (fixed value)
	DIKI:RecordRecipes(GetUnitName("player"))
end	--/end initialize
function DIKI:ComeGlobalsInMYTable()								--Put the settings from Global to local once the player is activated to buy Khrill some time to set up his panel.
	DIKIFA:SubmitSettings()
	DIKI:Initialize()						--I need to do this after because I could use the settings when I record entries by categories (i.e a potential new trophy categorie)
	DIKI:PanTooltips()
	DIKI:PanEvents()						-- To update a few things when a new entry is done
	EVENT_MANAGER:UnregisterForEvent("DIKIFA_Init", EVENT_PLAYER_ACTIVATED)
end
function DIKI.Loaded(event, addonName)
	if addonName ~= DIKI.name then return end
	EVENT_MANAGER:RegisterForEvent("DIKIFA_Init", EVENT_PLAYER_ACTIVATED, DIKI.ComeGlobalsInMYTable)
	EVENT_MANAGER:UnregisterForEvent(DIKI.name, EVENT_ADD_ON_LOADED)
end
local function AddDikiInfo_Gamepad(control,kn,ukn)
	if DIKI.ShowTitleUnknown + DIKI.ShowTitleKnown + DIKI.ShowKnown + DIKI.ShowUnknown == 0 then return end
	if kn == "nodata" or kn == "null" then return end
	local mystyleknown = { fontSize = 22, fontFace = "Univers67.otf", customSpacing = 5, }	--horizontalAlignment = 1 for center but not TEXT_ALIGN_CENTER, not CENTER? may have made a typo when testing.
	local mystyleunknown = { fontSize = 22, fontFace = "Univers67.otf", customSpacing = 5, }
	local mystyleneutral = { fontSize = 24, fontFace = "Univers67.otf", uppercase = true, }
	if DIKI.ShowTitleKnown		> 0 then control:AddLine(DIKI.knownstr[DIKI.lg], mystyleneutral, ZO_TOOLTIP_STYLES.bodySection) end
	if DIKI.ShowKnown			> 0 then control:AddLine("|c"..kncolor:ToHex()..kn.."|r", mystyleknown, ZO_TOOLTIP_STYLES.bodySection) end
	if DIKI.ShowTitleUnknown	> 0 then control:AddLine(DIKI.unknownstr[DIKI.lg], mystyleneutral, ZO_TOOLTIP_STYLES.bodySection) end
	if DIKI.ShowUnknown			> 0 then control:AddLine("|c"..ukncolor:ToHex()..ukn.."|r", mystyleunknown, ZO_TOOLTIP_STYLES.bodySection) end
end
local function EditTipKnownBy(varknown,varunknown,control)
	if DIKI.ShowTitleUnknown + DIKI.ShowTitleKnown + DIKI.ShowKnown + DIKI.ShowUnknown == 0 then return end
	if varknown ~= "null" then
		ZO_Tooltip_AddDivider(control)
		if DIKI.ShowTitleKnown		> 0 then control:AddLine(DIKI.knownstr[DIKI.lg], "ZoFontWinH5", 1,1,1, BOTTOM, MODIFY_TEXT_TYPE_UPPERCASE,TEXT_ALIGN_CENTER,true) end
		if varknown	== "nodata"			then
			control:AddLine("n/a", "ZoFontWinH5", DIKI.rukn,DIKI.gukn,DIKI.bukn, BOTTOM,MODIFY_TEXT_TYPE_NONE,TEXT_ALIGN_CENTER,true)
			return
		end
		if DIKI.ShowKnown			> 0 then control:AddLine(varknown, "ZoFontWinH5", DIKI.rkn,DIKI.gkn,DIKI.bkn, BOTTOM,MODIFY_TEXT_TYPE_NONE,TEXT_ALIGN_CENTER,true) end
		if DIKI.ShowTitleUnknown	> 0 then control:AddLine(DIKI.unknownstr[DIKI.lg], "ZoFontWinH5", 1,1,1, BOTTOM, MODIFY_TEXT_TYPE_UPPERCASE,TEXT_ALIGN_CENTER,true) end
		if DIKI.ShowUnknown			> 0 then control:AddLine(varunknown, "ZoFontWinH5", DIKI.rukn,DIKI.gukn,DIKI.bukn, BOTTOM,MODIFY_TEXT_TYPE_NONE,TEXT_ALIGN_CENTER,true) end
	end
end



local function hookthemall(aimedtooltip, originalmethod, functiontogetlink)
	local functioncopy = aimedtooltip[originalmethod]
	aimedtooltip[originalmethod] = function(control,...)
		functioncopy(control,...)
		local itemLink = functiontogetlink(...)
		local itemType = GetItemLinkItemType(itemLink)
		if typeisvalid(itemType) > 0 then
			if originalmethod == "SetProvisionerResultItem" then
				if DIKI.ShowAtCookingFire <= 0 then return end
				if (itemType ~= ITEMTYPE_FOOD and itemType ~= ITEMTYPE_DRINK) then return end	--in case the popup is used for something else. very improbable. but still.
			end
			local kn, ukn = GetKnownInfo(itemLink,itemType)
			if originalmethod == "LayoutItem" then
				AddDikiInfo_Gamepad(control,kn,ukn)
				return
			end
			EditTipKnownBy(kn, ukn, control)
		end
	end
end
local function SetLinkTreatment(itemLink)
	return itemLink
end
function DIKI:PanTooltips()													-- HOOKS		-- check here to enable Gamepad TOOLTIPS
	hookthemall(ItemTooltip,"SetBagItem",GetItemLink)
	hookthemall(ItemTooltip,"SetLink",SetLinkTreatment)	--rft and other possible custom using these
	hookthemall(PopupTooltip,"SetLink",SetLinkTreatment)
	hookthemall(ItemTooltip,"SetLootItem",GetLootItemLink)
	hookthemall(ItemTooltip,"SetTradeItem",GetTradeItemLink)
	hookthemall(ItemTooltip,"SetStoreItem", GetStoreItemLink)	-- writ recipes sold at merchants now
	hookthemall(ItemTooltip,"SetBuybackItem",GetBuybackItemLink)
	hookthemall(ItemTooltip,"SetQuestReward",GetQuestRewardItemLink)	-- quest rewards in Wrothgar
	hookthemall(ItemTooltip,"SetAttachedMailItem",GetAttachedItemLink)
	hookthemall(ItemTooltip,"SetTradingHouseListing", GetTradingHouseListingItemLink)
	hookthemall(ItemTooltip,"SetTradingHouseItem", GetTradingHouseSearchResultItemLink)
	hookthemall(ZO_ProvisionerTopLevelTooltip,"SetProvisionerResultItem", GetRecipeResultItemLink)
	-- hookthemall(GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_LEFT_TOOLTIP), "LayoutItem", SetLinkTreatment)	-- uncomment these 3 lines for gamepad UI. I won't do any support on this UI though.
	-- hookthemall(GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_RIGHT_TOOLTIP), "LayoutItem", SetLinkTreatment)
	-- hookthemall(GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_MOVABLE_TOOLTIP), "LayoutItem", SetLinkTreatment)
end


function DIKI:PanEvents()
	EVENT_MANAGER:RegisterForEvent("DIKI_UpdateCollectibles", EVENT_ACHIEVEMENT_UPDATED, DIKI.UpdateCollectibles)	--"." not ":" and no () //or, function() my:function() end
	EVENT_MANAGER:RegisterForEvent("DIKI_UpdateRecipes", EVENT_RECIPE_LEARNED, DIKI.UpdateRecipes)
	EVENT_MANAGER:RegisterForEvent("DIKI_UpdateMotifs", EVENT_STYLE_LEARNED, DIKI.UpdateMotifs)
end


EVENT_MANAGER:RegisterForEvent(DIKI.name, EVENT_ADD_ON_LOADED, DIKI.Loaded)


--------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------GLOBAL FUNCTIONS TO RETRIEVE THE NUMBER OF CHARS WHO KNOW SOMETHING------------- RETURN : numcharwhoknow,numchartotal & more sometimes------
------FISHES
function DIKIFA:FishCountByJournalId(achievId,criteriumIndex)
-- returns also the itemID as 3rd result
	criteriumIndex = criteriumIndex or 0	-- use no criteriumIndex or 0 for unique purple fish or region achievs
	local num = 0
	if (DIKI.SavedVars.FishesList[DIKI.AchToFish[tostring(achievId)..","..tostring(criteriumIndex)]]) then num = #DIKI.SavedVars.FishesList[DIKI.AchToFish[tostring(achievId)..","..tostring(criteriumIndex)]] end
	return num, #CharsList, DIKI.AchToFish[tostring(achievId)..","..tostring(criteriumIndex)]
end
function DIKIFA:FishCountByJournalDesc(descAchiev)
-- raw data only. too many typos in french to manage manual entries. possible but i wont do it.
--!! will return only one result on doublons!
	local fishid = ""
	local desc,_ = "",nil
	descAchiev = descAchiev:lower()
	for k,v in pairs(DIKI.AchToFish) do
		local ach,crit = k:match("(%d+),(%d+)")
		if tonumber(crit) == 0 then _,desc = GetAchievementInfo(tonumber(ach)) end
		if tonumber(crit) > 0 then desc = GetAchievementCriterion(tonumber(ach),tonumber(crit)) end
		desc = desc:lower()
		if desc == descAchiev then fishid = v end
	end
	local num = 0
	if fishid ~= "" and (DIKI.SavedVars.FishesList[fishid]) then num = #DIKI.SavedVars.FishesList[fishid] end
	return num, #CharsList
end
function DIKIFA:FishCountByFishLink(itemLinkOrItemID)
	local itemLink = tostring(itemLinkOrItemID)
	local shortid = itemLink
	if not itemLink:match("^%d*$") then shortid = select(4, ZO_LinkHandler_ParseLink(itemLink)) end
	local num = 0
	if (DIKI.SavedVars.FishesList[shortid]) then num = #DIKI.SavedVars.FishesList[shortid] end
	return num, #CharsList
end
function DIKIFA:FishCountByTooltipName(tooltipname)
-- raw data or manual entry
--!! will return only one result on doublons!
	local fishid = ""
	tooltipname = tooltipname:lower()
	for _,v in pairs(DIKI.AchToFish) do
		local itemLink = zo_strformat("|H0:item:<<1>>:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|htemp|h", v)
		local rawname = GetItemLinkName(itemLink)
		local formattedname = zo_strformat(SI_LINK_FORMAT_ITEM_NAME, rawname)
		formattedname = formattedname:lower()
		rawname = rawname:lower()
		if tooltipname == rawname or tooltipname == formattedname then fishid = v end
	end
	local num = 0
	if fishid ~= "" and (DIKI.SavedVars.FishesList[fishid]) then num = #DIKI.SavedVars.FishesList[fishid] end
	return num, #CharsList
end
------TROPHIES
function DIKIFA:TrophyCountByJournalId(achievId,criteriumIndex)
-- returns also the itemID as 3rd result
-- use no criteriumIndex or 0 for unique purple fish or region achievs
	criteriumIndex = criteriumIndex or 0
	local num = 0
	if (DIKI.SavedVars.TrophiesList[DIKI.AchToTrophy[tostring(achievId)..","..tostring(criteriumIndex)]]) then num = #DIKI.SavedVars.TrophiesList[DIKI.AchToTrophy[tostring(achievId)..","..tostring(criteriumIndex)]] end
	return num, #CharsList, DIKI.AchToTrophy[tostring(achievId)..","..tostring(criteriumIndex)]
end
function DIKIFA:TrophyCountByJournalDesc(descAchiev)
-- raw data only.
--!! will return only one result on doublons!
	local trophyid = ""
	local desc,_ = "",nil
	descAchiev = descAchiev:lower()
	for k,v in pairs(DIKI.AchToTrophy) do
		local ach,crit = k:match("(%d+),(%d+)")
		if tonumber(crit) == 0 then _,desc = GetAchievementInfo(tonumber(ach)) end
		if tonumber(crit) > 0 then desc = GetAchievementCriterion(tonumber(ach),tonumber(crit)) end
		desc = desc:lower()
		if desc == descAchiev then trophyid = v end
	end
	local num = 0
	if trophyid ~= "" and (DIKI.SavedVars.TrophiesList[trophyid]) then num = #DIKI.SavedVars.TrophiesList[trophyid] end
	return num, #CharsList
end
function DIKIFA:TrophyCountByTrophyLink(itemLinkOrItemID)
-- dont forget to test if the item is consumable to exclude treasure maps and cie. Especially if you make tests / 0 value.
	local itemLink = tostring(itemLinkOrItemID)
	local shortid = itemLink
	if not itemLink:match("^%d*$") then shortid = select(4, ZO_LinkHandler_ParseLink(itemLink)) end
	local num = 0
	if (DIKI.SavedVars.TrophiesList[shortid]) then num = #DIKI.SavedVars.TrophiesList[shortid] end
	return num, #CharsList
end
function DIKIFA:TrophyCountByTooltipName(tooltipname)
-- raw data or manual entry
--!! will return only one result on doublons!
	local trophyid = ""
	tooltipname = tooltipname:lower()
	for _,v in pairs(DIKI.AchToTrophy) do
		local itemLink = zo_strformat("|H0:item:<<1>>:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|htemp|h", v)
		local rawname = GetItemLinkName(itemLink)
		local formattedname = zo_strformat(SI_LINK_FORMAT_ITEM_NAME, rawname)
		formattedname = formattedname:lower()
		rawname = rawname:lower()
		if tooltipname == rawname or tooltipname == formattedname then trophyid = v end
	end
	local num = 0
	if trophyid ~= "" and (DIKI.SavedVars.TrophiesList[trophyid]) then num = #DIKI.SavedVars.TrophiesList[trophyid] end
	return num, #CharsList
end
------STYLES
function DIKIFA:StyleCountByBookLink(itemLink)
	local shortid = select(4, ZO_LinkHandler_ParseLink(itemLink))
	local num = 0
	if (DIKI.SavedVars.Books[shortid]) then num = #DIKI.SavedVars.Books[shortid] end
	return num, #CharsList
end
function DIKIFA:StyleCountByJournalId(achievId,criteriumIndex)
	criteriumIndex = criteriumIndex or 0
	if achievId ~= 1030 and achievId ~= 1043 and achievId ~= 1144 then d("DIKIFA : please use the following Styles Achievements for accurate data : 1030 (Alliance), 1043 (Rare) or 1144 (Dwemer)") end
	local num = 0
	if (DIKI.SavedVars.Books[DIKI.Styles[tostring(achievId)..","..tostring(criteriumIndex)]]) then num = #DIKI.SavedVars.Books[DIKI.Styles[tostring(achievId)..","..tostring(criteriumIndex)]] end
	return num, #CharsList, DIKI.SavedVars.Books[DIKI.Styles[tostring(achievId)..","..tostring(criteriumIndex)]]
end
------RECIPES
function DIKIFA:RecipeCountByRecipeLink(itemLink)
-- Link of the recipe
	local itemname = string.lower(GetItemLinkName(GetItemLinkRecipeResultItemLink(itemLink)))
	local num = 0
	if (DIKI.SavedVars.RecipesList[itemname]) then num = #DIKI.SavedVars.RecipesList[itemname] end
	return num, #CharsList
end
function DIKIFA:RecipeCountByResultLink(itemLink)
-- Link of the crafted food or drink
	local itemname = string.lower(GetItemLinkName(itemLink))
	local num = 0
	if (DIKI.SavedVars.RecipesList[itemname]) then num = #DIKI.SavedVars.RecipesList[itemname] end
	return num, #CharsList
end
function DIKIFA:RecipeCountByResultName(foodname)
-- You can use this with the raw tooltip name or a manual entry in any language
	local itemname = string.lower(foodname)
	itemname = string.gsub(itemname,("%^.*"),"")
	if DIKI.lg == "fr" then
		itemname = string.gsub(itemname, "\194\171 ", "\194\171\194\160")
		itemname = string.gsub(itemname, " \194\187", "\194\160\194\187")
	end
	local num = 0
	local shortid = ""
	local specialIngredient = 0
	local specialIngredientType = 0
	local recipeListIndex = nil
	local recipeIndex = nil
		for k,v in pairs(DIKI.SavedVars.RecipesList) do
			local texttocheck = k:gsub("%^.*","")
			texttocheck = texttocheck:gsub("⸗"," ")
			if itemname == string.gsub(k,("%^.*"),"") or itemname == texttocheck then
			num = #v
			if (v.id) then shortid = v.id end
			if (v.recipeType) then specialIngredientType = v.recipeType end
			if (v.recipeIndex) then listIndex = v.recipeIndex end
			if (v.recipeListIndex) then recipeListIndex = v.recipeListIndex end
			if (v.recipeIndexByList) then recipeIndex = v.recipeIndexByList end
			break
			end
		end
	return num, #CharsList, shortid, specialIngredientType, listIndex, recipeListIndex, recipeIndex	-- listIndex : order by type with full list with no filters, obsolete.
	--Got no light way to do this without relying on yet another addon (which already has these tools so.. no point there)
	--shortid is the one of the crafted food item.
end
---------------------------------------------------------------------------------------------------------------------------------------------------------------
