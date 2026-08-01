-- L is a convenience table so we don't have to write ZO_CreateStringId a bunch of times
local L = {}

-- Miscellanoues UI
L.DQT_TOGGLE_DISPLAY                 = "表示を切り替える"
L.DQT_TIME_UNTIL_RESET               = "リセットまでの時間"
L.DQT_CHARACTERS_HEADER              = "表示するキャラクタ"
L.DQT_SECTION_HEADER                 = "表示する部分"

-- Bindings
L.SI_BINDING_NAME_DTQ_TOGGLE_DISPLAY = "表示を切り替える"

-- Section Names
L.DQT_OTHER_TIMERS                   = "その他の時間"
L.DQT_CRAFTING                       = "クラフト"
L.DQT_UNDAUNTED_PLEDGE               = "アンドーンテッドの約束"
L.DQT_GUILD                          = "ギルド"
-- L.DQT_CYRODILIC_COLLECTIONS          = "シロディリックのコレクション"
-- L.DQT_RANDOM_DUNGEON                 = "ランダム ダンジョン"
-- L.DQT_RANDOM_BATTLEGROUNDS           = "ランダム バトルグラウンド"
-- L.DQT_MOUNT_TRAINING                 = "マウント トレーニング"
-- L.DQT_ELSWEYR_PROLOGUE               = "Elsweyr Prologue"
-- L.DQT_LOWER_CRAGLORN                 = "Lower Craglorn"
-- L.DQT_UPPER_CRAGLORN                 = "Upper Craglorn"
-- L.DQT_CYRODIIL_PVE                   = zo_strformat("<<1>>", GetZoneNameById(181)) .. " Settlements"
-- L.DQT_CYRODIIL_PVP                   = zo_strformat("<<1>>", GetZoneNameById(181)) .. " " .. GetString(SI_GUILDFOCUSATTRIBUTEVALUE5)

-- Quest Type Names
L.DQT_GROUP_BOSS                     = "グループボス"
L.DQT_DELVE                          = "探索"
L.DQT_GEYSERS                        = "ゲイザー"
L.DQT_ASHLANDER_HUNT                 = "アシュランダー狩り"
L.DQT_ASHLANDER_RELIC                = "アシュランダーのレリック"
L.DQT_FIGHTERS_GUILD                 = "戦士ギルド"
L.DQT_MAGES_GUILD                    = "魔術師ギルド"
L.DQT_UNDAUNTED_DELVE                = "アンドーンテッドの探索"
L.DQT_TARNISHED                      = "汚れた血"
L.DQT_BLACKFEATHER_COURT             = "黒い羽の宮廷"
L.DQT_RYES_REACQUISITIONS            = "ライの復活"
L.DQT_HEIST                          = "強奪"
L.DQT_GOLD_COAST_BOUNTY              = "賞金稼ぎ"
L.DQT_SACRAMENT                      = "聖餐"
L.DQT_ROOT_WHISPER                   = "根源の囁き"
-- L.DQT_NEW_MOON                       = "New Moon"
-- L.DQT_DRAGONHUNT                     = "Dragon Hunts"
L.DQT_HARROWSTORM                    = "喪心の嵐"
-- L.DQT_RESISTANCE                     = "Wayward Guardian"
L.DQT_VOLCANIC_VENTS                 = "火山の裂け目"
L.DQT_BRUMA                          = "ブルーマ"
L.DQT_CHEYDINHAL                     = "チェイディンホール"
L.DQT_CHORROL                        = "コロールとウェイノン修道院"
L.DQT_CROPSFORD                      = "クロップスフォード"
L.DQT_VLASTARUS                      = "ヴラスタルス"
L.DQT_CYRODIIL_FIGHTERS_GUILD        = "戦士ギルドの賞金稼ぎ"
-- L.DQT_CYRODIIL_BATTLE_MISSIONS       = "Battle Missions"
L.DQT_CYRODIIL_BOUNTY_MISSIONS       = "賞金稼ぎ"
-- L.DQT_CYRODIIL_SCOUTING_MISSIONS     = "Scouting Missions"
-- L.DQT_CYRODIIL_WARFRONT_MISSION      = "Warfront Missions"
-- L.DQT_CYRODIIL_ELDER_SCROLL          = "Elder Scrolls Missions" 
-- L.DQT_CYRODIIL_CONQUEST_MISSION      = "Conquest Missions"


--[[ Set these to the strings at the start of each quest, including
the leading space. The code will generate the display name by stripping
any of these values from the beginning of each quest name.
--]]

-- Undaunted Pledges
L.DQT_PLEDGE_PREFIX = "誓い: "

-- Vvardenfell Relics Quests
-- L.DQT_VVARDENFELL_QUESTS_RELICS_PREFIX_1	= "の遺物" -- its a sufix

-- Fighters Guild Quests
-- L.DQT_GUILD_DAILY_QUESTS_FIGHTERS_GUILD_DAILY_QUESTS_PREFIX_1 = "のダークアンカー" -- its a sufix

-- Mages Guild Quests
-- L.DQT_GUILD_DAILY_QUESTS_MAGES_GUILD_DAILY_QUESTS_PREFIX_1 = "の狂気" -- its a sufix

-- Thieves Guild Heist Quests
L.DQT_THIEVES_GUILD_LARCENY_QUESTS_HEISTS_PREFIX_1 = "強奪: "

-- Dark Brotherhood Sacrament Quests
L.DQT_GOLD_COAST_QUESTS_DARK_BROTHERHOOD_SACRAMENTS_PREFIX = "聖餐: "

-- Elsweyr Prologue Quests
L.DQT_NORTHERN_ELSWEYR_DEFENSE_FORCE_QUESTS_PREFIX_1 = "ドラゴン伝承: "

-- Fighters Guild Bounty Quests
L.DQT_CYRODIIL_FIGHTERS_GUILD_BOUNTY_QUESTS_PREFIX = "賞金: "

-- Necrom Bastion Nymic Quests
L.DQT_NECROM_QUESTS_BASTION_NYMIC_PREFIX = "ニミック砦 - "

--[[ Alternate display names
--]]
-- Summerset Bounty Quests (World Boss)
L.DQT_SUMMERSET_QUESTS_BOUNTY_01_DISPLAY = "深淵の錬金術師"
L.DQT_SUMMERSET_QUESTS_BOUNTY_02_DISPLAY = "同類"
L.DQT_SUMMERSET_QUESTS_BOUNTY_03_DISPLAY = "不朽"
L.DQT_SUMMERSET_QUESTS_BOUNTY_04_DISPLAY = "座礁"
L.DQT_SUMMERSET_QUESTS_BOUNTY_05_DISPLAY = "病んだ海"
L.DQT_SUMMERSET_QUESTS_BOUNTY_06_DISPLAY = "野生の馴致"

-- Vvardenfell Bounty Quests (World Boss)
L.DQT_VVARDENFELL_QUESTS_BOUNTY_01_DISPLAY = "不安な見習い"
L.DQT_VVARDENFELL_QUESTS_BOUNTY_02_DISPLAY = "這い寄るハンガー"
L.DQT_VVARDENFELL_QUESTS_BOUNTY_03_DISPLAY = "群れの間引き"
L.DQT_VVARDENFELL_QUESTS_BOUNTY_04_DISPLAY = "オックスを見つけた"
L.DQT_VVARDENFELL_QUESTS_BOUNTY_05_DISPLAY = "サロサンの呪い"
L.DQT_VVARDENFELL_QUESTS_BOUNTY_06_DISPLAY = "セイレーンの歌"

-- Wrothgar Group Boss Quests
L.DQT_WROTHGAR_QUESTS_GROUP_BOSS_DAILIES_01_DISPLAY = "無知という異端"
L.DQT_WROTHGAR_QUESTS_GROUP_BOSS_DAILIES_02_DISPLAY = "大衆のための肉"
L.DQT_WROTHGAR_QUESTS_GROUP_BOSS_DAILIES_03_DISPLAY = "自然の恵み"
L.DQT_WROTHGAR_QUESTS_GROUP_BOSS_DAILIES_04_DISPLAY = "悪い遊びの臭い"
L.DQT_WROTHGAR_QUESTS_GROUP_BOSS_DAILIES_05_DISPLAY = "学問的救出"
L.DQT_WROTHGAR_QUESTS_GROUP_BOSS_DAILIES_06_DISPLAY = "雪と蒸気"

-- Dark Brotherhood Bounty Quests
L.DQT_GOLD_COAST_QUESTS_BOUNTIES_01_DISPLAY = "埋められた悪"
L.DQT_GOLD_COAST_QUESTS_BOUNTIES_02_DISPLAY = "公共の利益"
L.DQT_GOLD_COAST_QUESTS_BOUNTIES_03_DISPLAY = "忍び寄る影"
L.DQT_GOLD_COAST_QUESTS_BOUNTIES_04_DISPLAY = "群衆のどよめき"

-- Clockwork City Bounty Quests
L.DQT_CLOCKWORK_CITY_QUESTS_BOUNTY_01_DISPLAY = "華麗なる羽根の敵"
L.DQT_CLOCKWORK_CITY_QUESTS_BOUNTY_02_DISPLAY = "〈不完全〉の扇動"

for stringId, translation in pairs(L) do
	SafeAddString(_G[stringId], translation, 0)
end
