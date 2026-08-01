-----------------------------------------------------------------------------------
-- Addon Name: Dolgubon's Lazy Writ Crafter
-- Creator: Dolgubon (Joseph Heinzle)
-- Addon Ideal: Simplifies Crafting Writs as much as possible
-- Addon Creation Date: March 14, 2016
--
-- File Name: DailyAlchemyKRPatch.lua
-- File Description: Korean Localization
-- Load Order Requirements: None
--
-----------------------------------------------------------------------------------

-----------------------------------------------------------------------------------
--
-- TRANSLATION NOTES - PLEASE READ
--
-- If you are not looking to translate the addon you can ignore this. :D
--
-- If you ARE looking to translate this to something else then anything with a comment of Vital beside it is
-- REQUIRED for the addon to function properly. These strings MUST BE TRANSLATED EXACTLY!
-- If only going for functionality, ctrl+f for Vital. Otherwise, you should just translate everything. Note that some strings
-- Note that if you are going for a full translation, you must also translate defualt.lua and paste it into your localization file.
--
-- For languages that do not use the Latin Alphabet, there is also an optional langParser() function. IF the language you are translating
-- requires some changes to the WritCreater.parser() function then write the optional langParser() function here, and the addon
-- will use that instead. Just below is a commented out langParser for English. Be sure to remove the comments if rewriting it. [[  ]]
--
-- If you run into problems, please feel free to contact me on ESOUI.
--
-----------------------------------------------------------------------------------
--
if EsoKR and EsoKR:isKorean() then
	WritCreater = WritCreater or {}

	function WritCreater.langParser(str)  -- Optional overwrite function for language translations
		local seperater = "[ ]+"

		str = EsoKR:removeIndex(str)
		str = string.gsub(str,EsoKR:E("을"),"") --을
		str = string.gsub(str,EsoKR:E("를"),"") --를
		str = string.gsub(str,"_"," ") --를

		local params = {}
		local i = 1
		local searchResult1, searchResult2  = string.find(str,seperater)
		if searchResult1 == 1 then
			str = string.sub(str, searchResult2+1)
			searchResult1, searchResult2  = string.find(str,seperater)
		end

		while searchResult1 do

			params[i] = string.sub(str, 1, searchResult1-1)
			str = string.sub(str, searchResult2+1)
			searchResult1, searchResult2  = string.find(str,seperater)
			i=i+1
		end
		params[i] = str
		return params

	end


	function WritCreater.langWritNames() -- Vital
		-- Exact!!!  I know for german alchemy writ is Alchemistenschrieb - so ["G"] = schrieb, and ["A"]=Alchemisten
		local names = {
			["G"] = EsoKR:E("의뢰서를 확인한다."),
			[CRAFTING_TYPE_ENCHANTING] = EsoKR:E("마법부여가"),
			[CRAFTING_TYPE_BLACKSMITHING] = EsoKR:E("대장장이"),
			[CRAFTING_TYPE_CLOTHIER] = EsoKR:E("재봉사"),
			[CRAFTING_TYPE_PROVISIONING] = EsoKR:E("요리사"),
			[CRAFTING_TYPE_WOODWORKING] = EsoKR:E("목세공사"),
			[CRAFTING_TYPE_ALCHEMY] = EsoKR:E("연금술사"),
			[CRAFTING_TYPE_JEWELRYCRAFTING] = EsoKR:E("장신구"),
		}
		return names
	end

	function WritCreater.langMasterWritNames() -- Vital
		local names = {
			["M"] 							= EsoKR:E("거장의"),
			["M1"]							= EsoKR:E("master"),
			[CRAFTING_TYPE_ALCHEMY]			= EsoKR:E("혼합물"),
			[CRAFTING_TYPE_ENCHANTING]		= EsoKR:E("글리프"),
			[CRAFTING_TYPE_PROVISIONING]	= EsoKR:E("성찬"),
			["plate"]						= EsoKR:E("방어구"),
			["tailoring"]					= EsoKR:E("재단"),
			["leatherwear"]					= EsoKR:E("가죽 장비"),
			["weapon"]						= EsoKR:E("무기"),
			["shield"]						= EsoKR:E("방패"),
		}
		return names
	end

	function WritCreater.writCompleteStrings() -- Vital for translation
		local strings = {
			["place"] = EsoKR:E("<물건을 상자에 넣는다.>"),
			["sign"] = EsoKR:E("<화물 목록에 서명합니다.>"),
			["masterPlace"] = EsoKR:E("작업을 끝냈습니다."),
			["masterSign"] = EsoKR:E("<일을 끝마친다.>"),
			["masterStart"] = EsoKR:E("<계약을 받아들인다.>"),
			["Rolis Hlaalu"] = EsoKR:E("롤리스 흐랄루"), -- This is the same in most languages but ofc chinese and japanese
			["Deliver"] = EsoKR:E("배달하기"),
		}
		return strings
	end


	function WritCreater.languageInfo() -- Vital

		local craftInfo =
		{
			[ CRAFTING_TYPE_CLOTHIER] =
			{
				["pieces"] = --exact!!
				{
					[1] = EsoKR:E("로브"), -- "robe",
					[2] = EsoKR:E("조끼"), -- "jerkin",
					[3] = EsoKR:E("신발"), -- "shoes",
					[4] = EsoKR:E("장갑"), -- "gloves",
					[5] = EsoKR:E("모자"), -- "hat",
					[6] = EsoKR:E("바지"), -- "breeches",
					[7] = EsoKR:E("어깨장식"), -- "epaulet",
					[8] = EsoKR:E("허리띠"), -- "sash",
					[9] = EsoKR:E("가죽 갑옷"), -- "jack",
					[10]= EsoKR:E("장화"), -- "boots",
					[11]= EsoKR:E("팔목보호대"), -- "bracers",
					[12]= EsoKR:E("머리보호대"), -- "helmet",
					[13]= EsoKR:E("다리보호대"), -- "guards",
					[14]= EsoKR:E("어깨보호대"), -- "cops",
					[15]= EsoKR:E("벨트"), -- "belt",
				},
				["match"] = --exact!!! This is not the material, but rather the prefix the material gives to equipment. e.g. Homespun Robe, Linen Robe
				{
					[1] = EsoKR:E("수제"), -- "Homespun", --lvtier one of mats
					[2] = EsoKR:E("아마포"), -- "Linen",	
					[3] = EsoKR:E("면포"), -- "Cotton",
					[4] = EsoKR:E("거미 비단"), -- "Spidersilk",
					[5] = EsoKR:E("에본실"), -- "Ebonthread",
					[6] = EsoKR:E("크레시"), -- "Kresh",
					[7] = EsoKR:E("철실"), -- "Ironthread",
					[8] = EsoKR:E("은섬유"), -- "Silverweave",
					[9] = EsoKR:E("그림자 천"), -- "Shadowspun",
					[10]= EsoKR:E("선조"), -- "Ancestor",
					[11]= EsoKR:E("생가죽"), -- "Rawhide",
					[12]= EsoKR:E("가죽"), -- "Hide",
					[13]= EsoKR:E("가공 가죽"), -- "Leather",
					[14]= EsoKR:E("그레인"), -- "Full-Leather",
					[15]= EsoKR:E("모피"), -- "Fell",
					[16]= EsoKR:E("브리간딘"), -- "Brigandine",
					[17]= EsoKR:E("철 가죽"), -- "Ironhide",
					[18]= EsoKR:E("최상급"), -- "Superb",
					[19]= EsoKR:E("그림자가죽"), -- "Shadowhide",
					[20]= EsoKR:E("루베도"), -- "Rubedo",
				},

			},
			[CRAFTING_TYPE_BLACKSMITHING] =
			{
				["pieces"] = --exact!!
				{
					[1] = EsoKR:E("도끼"), -- "axe",
					[2] = EsoKR:E("둔기"), -- "mace",
					[3] = EsoKR:E("검"), -- "sword",
					[4] = EsoKR:E("전투도끼"), -- "battle",
					[5] = EsoKR:E("전투망치"), -- "maul",
					[6] = EsoKR:E("대검"), -- "greatsword",
					[7] = EsoKR:E("단검"), -- "dagger",
					[8] = EsoKR:E("흉갑"), -- "cuirass",
					[9] = EsoKR:E("쇠구두"), -- "sabatons",
					[10] = EsoKR:E("건틀렛"), -- "gauntlets",
					[11] = EsoKR:E("투구"), -- "helm",
					[12] = EsoKR:E("각갑"), -- "greaves",
					[13] = EsoKR:E("견갑"), -- "pauldron",
					[14] = EsoKR:E("복대"), -- "girdle",
				},
				["match"] = --exact!!! This is not the material, but rather the prefix the material gives to equipment. e.g. Iron Axe, Steel Axe
				{
					[1] = EsoKR:E("철"), -- "Iron",
					[2] = EsoKR:E("강철"), -- "Steel",
					[3] = EsoKR:E("오리할쿰"), -- "Orichalc",
					[4] = EsoKR:E("드워븐"), -- "Dwarven",
					[5] = EsoKR:E("에보니"), -- "Ebon",
					[6] = EsoKR:E("칼시니움"), -- "Calcinium",
					[7] = EsoKR:E("갈라타이트"), -- "Galatite",
					[8] = EsoKR:E("수은"), -- "Quicksilver",
					[9] = EsoKR:E("공허강"), -- "Voidsteel",
					[10]= EsoKR:E("루비다이트"), -- "Rubedite",
				},

			},
			[CRAFTING_TYPE_WOODWORKING] =
			{
				["pieces"] = --Exact!!!
				{
					[1] = EsoKR:E("활"), -- "bow",
					[3] = EsoKR:E("화염"), -- "inferno",
					[4] = EsoKR:E("냉기"), -- "ice",
					[5] = EsoKR:E("전격"), -- "lightning",
					[6] = EsoKR:E("치유"), -- "restoration",
					[2] = EsoKR:E("방패"), -- "shield",
				},
				["match"] = --exact!!! This is not the material, but rather the prefix the material gives to equipment. e.g. Maple Bow. Oak Bow.
				{
					[1] = EsoKR:E("단풍나무"), -- "Maple",
					[2] = EsoKR:E("참나무"), -- "Oak",
					[3] = EsoKR:E("너도밤나무"), -- "Beech",
					[4] = EsoKR:E("히코리"), -- "Hickory",
					[5] = EsoKR:E("주목"), -- "Yew",
					[6] = EsoKR:E("자작나무"), -- "Birch",
					[7] = EsoKR:E("물푸레나무"), -- "Ash",
					[8] = EsoKR:E("마호가니"), -- "Mahogany",
					[9] = EsoKR:E("깊은밤나무"), -- "Nightwood",
					[10] = EsoKR:E("루비"), -- "Ruby",
				},

			},
			[CRAFTING_TYPE_JEWELRYCRAFTING] =
			{
				["pieces"] = --Exact!!!
				{
					[1] = EsoKR:E("반지"), -- "ring",
					[2] = EsoKR:E("목걸이"), -- "necklace",

				},
				["match"] = --exact!!! This is not the material, but rather the prefix the material gives to equipment. e.g. Maple Bow. Oak Bow.
				{
					[1] = EsoKR:E("백랍"), -- "Pewter", -- 1
					[2] = EsoKR:E("구리"), -- "Copper", -- 26
					[3] = EsoKR:E("은"), -- "Silver", -- CP10
					[4] = EsoKR:E("호박금"), -- "Electrum", --CP80
					[5] = EsoKR:E("백금"), -- "Platinum", -- CP150
				},

			},
			[CRAFTING_TYPE_ENCHANTING] =
			{
				["pieces"] = --exact!!
				{ --{String Identifier, ItemId, positive or negative}
					{EsoKR:E("질병 저항"), 45841,2},
					{EsoKR:E("역병"), 45841,1},
					{EsoKR:E("스태미나 흡수"), 45833,2},
					{EsoKR:E("매지카 흡수"), 45832,2},
					{EsoKR:E("체력 흡수"), 45831,2},
					{EsoKR:E("냉기 저항"),45839,2},
					{EsoKR:E("냉기"),45839,1},
					{EsoKR:E("행동 소비 감소"), 45836,2},
					{EsoKR:E("스태미나 재생"), 45836,1},
					{EsoKR:E("경화"), 45842,1},
					{EsoKR:E("분쇄"), 45842,2},
					{EsoKR:E("프리즘 맹습"), 68342,2},
					{EsoKR:E("프리즘 방어"), 68342,1},
					{EsoKR:E("방어"),45849,2},
					{EsoKR:E("강타"),45849,1},
					{EsoKR:E("독 저항"),45837,2},
					{EsoKR:E("독"),45837,1},
					{EsoKR:E("마법 피해 감소"),45848,2},
					{EsoKR:E("마법 피해 증가"),45848,1},
					{EsoKR:E("매지카 재생"), 45835,1},
					{EsoKR:E("주문 소비 감소"), 45835,2},
					{EsoKR:E("전격 저항"),45840,2},
					{EsoKR:E("전격"),45840,1},
					{EsoKR:E("체력 재생"),45834,1},
					{EsoKR:E("체력 감소"),45834,2},
					{EsoKR:E("쇠약"),45843,2},
					{EsoKR:E("무기 피해"),45843,1},
					{EsoKR:E("물약 강화"),45846,1},
					{EsoKR:E("물약 속도 상승"),45846,2},
					{EsoKR:E("화염 저항"),45838,2},
					{EsoKR:E("화염"),45838,1},
					{EsoKR:E("물리 피해 감소"), 45847,2},
					{EsoKR:E("물리 피해 증가"), 45847,1},
					{EsoKR:E("스태미나"),45833,1}, -- stamina
					{EsoKR:E("체력"),45831,1}, -- health
					{EsoKR:E("매지카"),45832,1} -- magicka
				},
				["match"] = --exact!!! The names of glyphs. The prefix (in English) So trifling glyph of magicka, for example
				{
					[1] = {EsoKR:E("티끌만한"),45855}, -- trifling
					[2] = {EsoKR:E("열등한"),45856}, -- inferior
					[3] = {EsoKR:E("하찮은"),45857}, -- petty
					[4] = {EsoKR:E("미약한"),45806}, -- slight
					[5] = {EsoKR:E("아담한"),45807}, -- minor
					[6] = {EsoKR:E("하등한"),45808}, -- lesser
					[7] = {EsoKR:E("일반적인"),45809}, -- moderate
					[8] = {EsoKR:E("평균적인"),45810}, -- average
					[9] = {EsoKR:E("강력한"),45811}, -- strong
					[10]= {EsoKR:E("우수한"),45812}, -- major
					[11]= {EsoKR:E("대단한"),45813}, -- greater
					[12]= {EsoKR:E("강대한"),45814}, -- grand
					[13]= {EsoKR:E("탁월한"),45815}, -- splendid
					[14]= {EsoKR:E("기념적인"),45816}, -- monumental
					[15]= {EsoKR:E("초월적인"),{68341,68340,},}, -- truly 160
					[16]= {EsoKR:E("최상급"),{64509,64508,},}, -- superb 150

				},
				["quality"] =
				{
					{EsoKR:E("기본적인"),45850}, -- normal
					{EsoKR:E("좋은"),45851}, -- fine
					{EsoKR:E("우수한"),45852}, -- superior
					{EsoKR:E("유물의"),45853}, -- epic
					{EsoKR:E("전설적인"),45854}, -- legendary
					{"", 45850} -- default, if nothing is mentioned. Default should be Ta.
				}
			},
		}

		return craftInfo

	end

	function WritCreater.masterWritQuality() -- Vital . This is probably not necessary, but it stays for now because it works
		return {{EsoKR:E("유물의"),4},{EsoKR:E("전설적인"),5}}
	end

	function WritCreater.langEssenceNames() -- Vital

		local essenceNames =
		{
			[1] = EsoKR:E("오코"), -- "Oko", --health
			[2] = EsoKR:E("데니"), -- "Deni", --stamina
			[3] = EsoKR:E("마코"), -- "Makko", --magicka
		}
		return essenceNames
	end

	function WritCreater.langPotencyNames() -- Vital
		--exact!! Also, these are all the positive runestones - no negatives needed.
		local potencyNames =
		{
			[1] = EsoKR:E("조라"), -- "Jora", --Lowest potency stone lvl
			[2] = EsoKR:E("포라데"), -- "Porade",
			[3] = EsoKR:E("제라"), -- "Jera",
			[4] = EsoKR:E("제조라"), -- "Jejora",
			[5] = EsoKR:E("오드라"), -- "Odra",
			[6] = EsoKR:E("포조라"), -- "Pojora",
			[7] = EsoKR:E("에도라"), -- "Edora",
			[8] = EsoKR:E("제에라"), -- "Jaera",
			[9] = EsoKR:E("포라"), -- "Pora",
			[10]= EsoKR:E("데나라"), -- "Denara",
			[11]= EsoKR:E("레라"), -- "Rera",
			[12]= EsoKR:E("데라도"), -- "Derado",
			[13]= EsoKR:E("레쿠라"), -- "Rekura",
			[14]= EsoKR:E("쿠라"), -- "Kura",
			[15]= EsoKR:E("레제라"), -- "Rejera",
			[16]= EsoKR:E("레포라"), -- "Repora", --v16 potency stone

		}
		return potencyNames
	end

	local exceptions =
	{
		[1] =
		{
			["original"] = EsoKR:E("강철"), --강철
			["corrected"] = "Steel", --Steel
		},
		[2] =
		{
			["original"] = EsoKR:E("루비 물푸레나무"), --루비 물푸레나무
			["corrected"] = EsoKR:E("루비"), --루비
		},
	}

	function WritCreater.questExceptions(condition)
		condition = string.gsub(condition, " "," ")
		return condition
	end

	function WritCreater.enchantExceptions(condition)

		condition = string.gsub(condition, " "," ")
		return condition
	end

	function WritCreater.exceptions(condition)
		condition = string.gsub(condition, " "," ")
		condition = string.lower(condition)

		for i = 1, #exceptions do

			if string.find(condition, exceptions[i]["original"]) then
				condition = string.gsub(condition, exceptions[i]["original"],exceptions[i]["corrected"])
			end
		end
		return condition
	end

	function WritCreater.langTutorial(i)
		local t = {
			[5]="There's also a few things you should know.\nFirst, /dailyreset is a slash command that will tell you\nhow long until the next daily server reset.",
			[4]="Finally, you can also choose to deactivate or\nactivate this addon for each profession.\nBy default, all applicable crafts are on.\nIf you wish to turn some off, please check the settings.",
			[3]="Next, you need to choose if you wish to see this\nwindow when using a crafting station.\nThe window will tell you how many mats the writ will require, as well as how many you currently have.",
			[2]="The first setting to choose is if you\nwant to useAutoCraft.\nIf on, when you enter a crafting station, the addon will start crafting.",
			[1]="Welcome to Dolgubon's Lazy Writ Crafter!\nThere are a few settings you should choose first.\n You can change the settings at any\n time in the settings menu.",
		}
		return t[i]
	end

	function WritCreater.langTutorialButton(i,onOrOff) -- sentimental and short please. These must fit on a small button
		local tOn =
		{
			[1]=EsoKR:E("기본값 사용"),
			[2]=EsoKR:E("켜기"),
			[3]=EsoKR:E("표시"),
			[4]=EsoKR:E("계속"),
			[5]=EsoKR:E("완료"),
		}
		local tOff=
		{
			[1]=EsoKR:E("계속"),
			[2]=EsoKR:E("끄기"),
			[3]=EsoKR:E("다시 표시 안함"),
		}
		if onOrOff then
			return tOn[i]
		else
			return tOff[i]
		end
	end

	function WritCreater.langStationNames()
		return
		{[EsoKR:E("대장기술 제작대")] = 1, [EsoKR:E("재봉 제작대")] = 2,
		 [EsoKR:E("마법부여 제작대")] = 3,[EsoKR:E("연금술 제작대")] = 4, [EsoKR:E("요리용 화로")] = 5, [EsoKR:E("목공 제작대")] = 6, [EsoKR:E("장신구 제작대")] = 7, }
	end

	function WritCreater.langWritRewardBoxes () return {
		[CRAFTING_TYPE_ALCHEMY] = EsoKR:E("연금술사의 용기"), -- "Alchemist's Vessel",
		[CRAFTING_TYPE_ENCHANTING] = EsoKR:E("마법부여가의 궤짝"), -- "Enchanter's Coffer",
		[CRAFTING_TYPE_PROVISIONING] = EsoKR:E("요리사의 꾸러미"), -- "Provisioner's Pack",
		[CRAFTING_TYPE_BLACKSMITHING] = EsoKR:E("대장장이의 상자"), -- "Blacksmith's Crate",
		[CRAFTING_TYPE_CLOTHIER] = EsoKR:E("재봉사의 가방"), -- "Clothier's Satchel",
		[CRAFTING_TYPE_WOODWORKING] = EsoKR:E("목세공사의 상자"), -- "Woodworker's Case",
		[CRAFTING_TYPE_JEWELRYCRAFTING] = EsoKR:E("보석 공예가의 상자"), -- "Jewelry Crafter's Coffer",
		[8] = EsoKR:E("적하물"), -- "Shipment",
		[10] = "Shipment", -- "Shipment",
	}
	end

	function WritCreater.getTaString()
		return EsoKR:E("타") -- ta
	end

	WritCreater.lang = EsoKR:getLanguage()
	WritCreater.langIsMasterWritSupported = true

	WritCreater.strings["moreStyle"] 					= EsoKR:E("|cf60000사용 가능한 스타일 재료 없음.\n인벤토리나 설정을 확인|r")
end