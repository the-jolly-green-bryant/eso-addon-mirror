-- L is a convenience table so we don't have to write ZO_CreateStringId a bunch of times
local L = {}

-- Miscellanoues UI
L.SI_DQT_TOGGLE_DISPLAY = "表示を切り替える"
L.SI_DQT_TIME_UNTIL_RESET = "リセットまでの時間"
L.SI_DQT_CHARACTERS_HEADER = "表示するキャラクタ"
L.SI_DQT_SECTION_HEADER = "表示する部分"

-- Section Names
L.SI_DQT_CRAFTING = "クラフト"
L.SI_DQT_UNDAUNTED_PLEDGE = "アンドーンテッドの約束"
L.SI_DQT_SUMMERSET = "サマーセット"
L.SI_DQT_VVARDENFELL = "ヴァーデンフェル"
L.SI_DQT_GUILD = "ギルド"
L.SI_DQT_CYRODILIC_COLLECTIONS = "シロディリックのコレクション"
L.SI_DQT_CLOCKWORK_CITY = "クロックワークシティ"
L.SI_DQT_WROTHGAR = "ロスガー"
L.SI_DQT_THIEVES_GUILD = "盗賊ギルド"
L.SI_DQT_DARK_BROTHERHOOD = "闇の一党"
L.SI_DQT_MURKMIRE = "マークマイア"
L.SI_DQT_OTHER_TIMERS = "その他の時間"
L.SI_DQT_RANDOM_DUNGEON = "ランダム ダンジョン"
L.SI_DQT_RANDOM_BATTLEGROUNDS	= "ランダム バトルグラウンド"
L.SI_DQT_MOUNT_TRAINING = "マウント トレーニング"
L.SI_DQT_ELSWEYR_PROLOGUE			= "Elsweyr Prologue"
L.SI_DQT_ELSWEYR					= "Elsweyr"
L.SI_DQT_DRAGONHOLD					= "Dragonhold" -- Added by DarkPhalanx
L.SI_DQT_WESTERN_SKYRIM				= "Western Skyrim" -- Added by DarkPhalanx
L.SI_DQT_IMPERIAL_CITY				= "Imperial City" -- Added by DarkPhalanx
L.SI_DQT_THE_REACH					= "The Reach" -- Added by DarkPhalanx
L.SI_DQT_LOWER_CRAGLORN				= "Lower Craglorn" -- Added by DarkPhalanx
L.SI_DQT_UPPER_CRAGLORN				= "Upper Craglorn" -- Added by DarkPhalanx
L.SI_DQT_BLACKWOOD					= "Blackwood" -- Added by DarkPhalanx

-- Quest Type Names
L.SI_DQT_GROUP_BOSS = "グループボス"
L.SI_DQT_DELVE = "探索"
L.SI_DQT_GEYSERS = "ゲイザー"
L.SI_DQT_ASHLANDER_HUNT = "アシュランダー狩り"
L.SI_DQT_ASHLANDER_RELIC = "アシュランダーのレリック"
L.SI_DQT_FIGHTERS_GUILD = "戦士ギルド"
L.SI_DQT_MAGES_GUILD = "魔術師ギルド"
L.SI_DQT_UNDAUNTED_DELVE = "アンドーンテッドの探索"
L.SI_DQT_TARNISHED = "汚れた血"
L.SI_DQT_BLACKFEATHER_COURT = "黒い羽の宮廷"
L.SI_DQT_RYES_REACQUISITIONS = "ライの復活"
L.SI_DQT_HEIST = "強盗"
L.SI_DQT_GOLD_COAST_BOUNTY = "賞金稼ぎ"
L.SI_DQT_SACRAMENT = "聖餐"
L.SI_DQT_ROOT_WHISPER = "根源の囁き"
L.SI_DQT_NEW_MOON					= "New Moon" -- Added by DarkPhalanx
L.SI_DQT_DRAGONHUNT					= "Dragon Hunts" -- Added by DarkPhalanx
L.SI_DQT_HARROWSTORM				= "Harrowstorms" -- Added by DarkPhalanx
L.SI_DQT_PVP						= "PVP" -- Added by DarkPhalanx
L.SI_DQT_RESISTANCE					= "Resistance" -- Added by DarkPhalanx

L.SI_DQT_CLOTHING = "縫製"
L.SI_DQT_BLACKSMITHING = "鍛冶"
L.SI_DQT_WOODWORKING = "木工"
L.SI_DQT_JEWELRY = "宝飾"
L.SI_DQT_ALCHEMY = "錬金術"
L.SI_DQT_ENCHANTING = "付呪"
L.SI_DQT_PROVISIONING = "調理"

--[[ Set these to the strings at the start of each quest, including
the leading space. The code will generate the display name by stripping
any of these values from the beginning of each quest name.
--]]

-- Undaunted Pledges
L.SI_DQT_PLEDGE_PREFIX					= ""

-- Vvardenfell Relics Quests
L.SI_DQT_VVARDENFELL_QUESTS_RELICS_PREFIX_1	= ""
L.SI_DQT_VVARDENFELL_QUESTS_RELICS_PREFIX_2	= "" -- placeholder for other languages

-- Fighters Guild Quests
L.SI_DQT_GUILD_DAILY_QUESTS_FIGHTERS_GUILD_DAILY_QUESTS_PREFIX_1 = ""
L.SI_DQT_GUILD_DAILY_QUESTS_FIGHTERS_GUILD_DAILY_QUESTS_PREFIX_2 = "" -- placeholder for other languages
L.SI_DQT_GUILD_DAILY_QUESTS_FIGHTERS_GUILD_DAILY_QUESTS_PREFIX_3 = "" -- placeholder for other languages
L.SI_DQT_GUILD_DAILY_QUESTS_FIGHTERS_GUILD_DAILY_QUESTS_PREFIX_4 = "" -- placeholder for other languages

-- Mages Guild Quests
L.SI_DQT_GUILD_DAILY_QUESTS_MAGES_GUILD_DAILY_QUESTS_PREFIX_1 = ""
L.SI_DQT_GUILD_DAILY_QUESTS_MAGES_GUILD_DAILY_QUESTS_PREFIX_2 = "" -- placeholder for other languages
L.SI_DQT_GUILD_DAILY_QUESTS_MAGES_GUILD_DAILY_QUESTS_PREFIX_3 = "" -- placeholder for other languages
L.SI_DQT_GUILD_DAILY_QUESTS_MAGES_GUILD_DAILY_QUESTS_PREFIX_4 = "" -- placeholder for other languages

-- Thieves Guild Heist Quests
L.SI_DQT_THIEVES_GUILD_LARCENY_QUESTS_HEISTS_PREFIX_1 = ""
L.SI_DQT_THIEVES_GUILD_LARCENY_QUESTS_HEISTS_PREFIX_2 = "" -- placeholder for other languages

-- Dark Brotherhood Sacrament Quests
L.SI_DQT_GOLD_COAST_QUESTS_DARK_BROTHERHOOD_SACRAMENTS_PREFIX = ""

--[[ Alternate display names
--]]
-- Summerset Bounty Quests (World Boss)	
L.SI_DQT_SUMMERSET_QUESTS_BOUNTY_01_DISPLAY = "深淵の錬金術師"
L.SI_DQT_SUMMERSET_QUESTS_BOUNTY_02_DISPLAY = "同類"
L.SI_DQT_SUMMERSET_QUESTS_BOUNTY_03_DISPLAY = "不朽"
L.SI_DQT_SUMMERSET_QUESTS_BOUNTY_04_DISPLAY = "座礁"
L.SI_DQT_SUMMERSET_QUESTS_BOUNTY_05_DISPLAY = "病んだ海"
L.SI_DQT_SUMMERSET_QUESTS_BOUNTY_06_DISPLAY = "野生の馴致"

-- Vvardenfell Bounty Quests (World Boss)	
L.SI_DQT_VVARDENFELL_QUESTS_BOUNTY_01_DISPLAY = "不安な見習い"
L.SI_DQT_VVARDENFELL_QUESTS_BOUNTY_02_DISPLAY = "這い寄るハンガー"
L.SI_DQT_VVARDENFELL_QUESTS_BOUNTY_03_DISPLAY = "群れの間引き"
L.SI_DQT_VVARDENFELL_QUESTS_BOUNTY_04_DISPLAY = "オックスを見つけた"
L.SI_DQT_VVARDENFELL_QUESTS_BOUNTY_05_DISPLAY = "サロサンの呪い"
L.SI_DQT_VVARDENFELL_QUESTS_BOUNTY_06_DISPLAY = "セイレーンの歌"

-- Wrothgar Group Boss Quests	
L.SI_DQT_WROTHGAR_QUESTS_GROUP_BOSS_DAILIES_01_DISPLAY = "無知という異端"
L.SI_DQT_WROTHGAR_QUESTS_GROUP_BOSS_DAILIES_02_DISPLAY = "大衆のための肉"
L.SI_DQT_WROTHGAR_QUESTS_GROUP_BOSS_DAILIES_03_DISPLAY = "自然の恵み"
L.SI_DQT_WROTHGAR_QUESTS_GROUP_BOSS_DAILIES_04_DISPLAY = "悪い遊びの臭い"
L.SI_DQT_WROTHGAR_QUESTS_GROUP_BOSS_DAILIES_05_DISPLAY = "学問的救出"
L.SI_DQT_WROTHGAR_QUESTS_GROUP_BOSS_DAILIES_06_DISPLAY = "雪と蒸気"

-- Dark Brotherhood Bounty Quests
L.SI_DQT_GOLD_COAST_QUESTS_BOUNTIES_01_DISPLAY = "埋められた悪"
L.SI_DQT_GOLD_COAST_QUESTS_BOUNTIES_02_DISPLAY = "公共の利益"
L.SI_DQT_GOLD_COAST_QUESTS_BOUNTIES_03_DISPLAY = "忍び寄る影"
L.SI_DQT_GOLD_COAST_QUESTS_BOUNTIES_04_DISPLAY = "群衆のどよめき"

-- Clockwork City Bounty Quests
L.SI_DQT_CLOCKWORK_CITY_QUESTS_BOUNTY_01_DISPLAY = "華麗なる羽根の敵"
L.SI_DQT_CLOCKWORK_CITY_QUESTS_BOUNTY_02_DISPLAY = "〈不完全〉の扇動"

for stringId, translation in pairs(L) do
	SafeAddString(_G[stringId], translation, 0)
end