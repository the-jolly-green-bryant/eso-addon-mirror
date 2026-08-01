local strfmt = string.format
local zStrFmt = zo_strformat
local overviewGroupTabDescFmt = "%s %s|t26:26:%s|t %s|t26:26:%s|t %s|t26:26:%s|t / |t26:26:%s|t\n\n%s\n\n%s"
local overviewGroupTabDungIcon = "/esoui/art/icons/poi/poi_groupinstance_complete.dds"
local overviewGroupTabTrialIcon = "/esoui/art/icons/poi/poi_raiddungeon_complete.dds"
local overviewGroupTabArenaIconOne = "/esoui/art/icons/poi/poi_groupinstance_complete.dds"
local overviewGroupTabArenaIconTwo = "/esoui/art/icons/poi/poi_raiddungeon_complete.dds"

local stringsJP = {
	--TQG_CONFIRM_QUEST_ZONE_STORY = "ゾーンストーリー",
	--TQG_CONFIRM_QUEST_POI = "サイドクエスト",

	SI_BINDING_NAME_TQG_INTERACT_KEY = "クエストガイドの表示",
	SI_BINDING_NAME_TQG_INTERACT_GAMEPAD_KEY = zStrFmt("<<1>>(<<2>>)", "クエストガイドの表示", GetString(SI_GAMEPAD_SECTION_HEADER)),
	TQG_MENU_JOURNAL = "クエストガイド",

	TQG_OVERVIEW_CLASSIC_DESC = "次元融合編... タムリエル大陸を含むアービスにおける『ESO』オリジナルの物語です。メインストーリーに加えて、所属する同盟やギルドのストーリーを織り交ぜながら物語が進行していきます。同盟ストーリーは、初期エリアの島、次にオーリドン／グレナンブラ／ストンフォール、・・・といった具合に勢力ごとに並列していますが、コールドハーバーに到達する前に各勢力の同盟ストーリーを全て完了させる必要はありません。\n\n当初の同盟ストーリーの道筋は次のとおりです。\n・自分のキャラクターが所属する同盟の物語\n・メインストーリーのクリア後に、キャドウェルのシルバー／ゴールドとして開始される他の２つの同盟ストーリーの追体験",
	TQG_OVERVIEW_DLC_DESC = "DLCセクションでは、ダンジョンDLC、ゾーンDLC、チャプターの導入以降の主要なストーリーを網羅しています。表示順はデフォルトでリリース順になっています。\n\n主なイベントは以下の通りです。\n・荘厳な街区（帝都）\n・オルシニウムの再建\n・盗賊ギルド／闇の一党\n・デイドラ戦争\n・失われた遺産（マークマイア）\n・ドラゴンのシーズン\n・スカイリムの闇の中心\n・オブリビオンの門\n・ブレトンの伝統\n・モロウウィンドの影",
	TQG_OVERVIEW_GROUP_DESC = strfmt(overviewGroupTabDescFmt, "グループセクションには、これまでにインスタンス化されたグループコンテンツの大半が含まれています。", "ダンジョン: ", overviewGroupTabDungIcon, "試練: ", overviewGroupTabTrialIcon, "アリーナ: ", overviewGroupTabArenaIconOne, overviewGroupTabArenaIconTwo, "ノーマル、ベテラン、時にはハードモードもありますが、ノーマルモードのクエストのクリアが必要なメイルストローム・アリーナを除いて、このガイドではどの難易度のクエストをクリアしても問題ありません。", "クエストは、リリースされたコンテンツに関連付けられています。例えば、モー・オブ・ローカジュはリーパーズマーチにありますが、盗賊ギルドDLCでリリースされているので、後者にリストされています。"), 

	TQG_OVERVIEW_DLC_TITLE = "DLC + チャプター",
	TQG_OVERVIEW_GROUP_TITLE = "グループコンテンツ",

	TQG_CLASSIC_TAB = "ベースゲーム", -- 'The Base Game' is more familiar to Japanese players than translated word of 'Classic'.

	TQG_QUEST_BTN = "クエスト案内図",
	TQG_CRAGLORN_BTN = zStrFmt("<<1>>", GetZoneNameById(888)),

	TQG_IC_BTN = "DLC:インペリアルシティ",
	TQG_ORSINIUM_BTN = "DLC:オルシニウム",

	TQG_OVERVIEW_LINKS_TITLE = "便利なリンク",
	TQG_OVERVIEW_LINKS_TEXT = "リンク先ホームページの性質上、熟読するほどネタバレの可能性が高くなります。ご承知おきください...",
	TQG_OVERVIEW_OBJECTIVE_TEXT = "各コンテンツの必要人数は参加メンバーにより異なります。メイルストローム・アリーナはソロアリーナであり、一人でその恐怖に立ち向かうことになります。\n\n（原則として、ダンジョンクエストは再プレイ不可、試練クエストは毎週再プレイ可です。登録するには１度クリアする必要があります。）",

	TQG_PROLOGUE = "プロローグ",
	TQG_EPILOGUE = "エピローグ",
	TQG_PREREQ = "前提条件",

	TQG_ARENA = "アリーナ",

	TQG_ENTER = "に入る",
	TQG_SEEK = "を探す",
	
	TQG_PLANEMELD = "次元融合",

	TQG_GUILDS_AND_GLORY = "ギルドと栄光",
	TQG_DAEDRIC_WAR = "デイドラ戦争",
	TQG_MURKMIRE = zStrFmt("<<1>>: <<2>>", GetZoneNameById(726), "幕間"),
	TQG_CHAPTER_ELSWEYR = "ドラゴンのシーズン",
	TQG_CHAPTER_SKYRIM = "スカイリムの闇の中心",
	TQG_CHAPTER_BLACKWOOD = "オブリビオンの門",
	TQG_CHAPTER_HIGH_ISLE = "ブレトンの伝統",
	TQG_CHAPTER_SHADOW_MORROWIND = "モロウウィンドの影",
	TQG_CHAPTER_RECOLLECTION_ITHELIA = "イセリアの回想",
	TQG_CHAPTER_SEASON_WORM_CULT = "ワーム・カルトの四季",

	TQG_INVITATION = "招待",
	TQG_FIGHTERS_NAME = "戦士ギルド",
	TQG_FIGHTERS_DESC = '戦士ギルドは、第二紀321年に最高顧問ヴェルシデュ・シャイエにより採択されたギルド法案第4条に基づき設立された、帝国公認ギルドである。',
	TQG_MAGES_NAME = "魔術師ギルド",
	TQG_MAGES_DESC = '魔術師ギルドは、第二紀230年にヴァヌス・ガレリオンとライリスXII世によりサマーセット諸島で設立された。その後、最高顧問ヴェルシデュ・シャイエのギルド法案により帝国公認ギルドとして承認された。',
	TQG_DOSHIA_LAIR = "ドシアの隠れ家",
	TQG_BONUS_BALMORA = "番外: バルモラ",
	TQG_BONUS_BALMORA_DESC = 'モロウウィンドの統治者が第一紀の昔にモラグ・トングを公認してから今日にいたるまで、モラグ・トングの暗殺者たちは「名誉ある処刑令状」という契約制度を利用して、暗黙のうちに合法的な暗殺を行い続けている。',
}

for id, stringVar in pairs(stringsJP) do
   ZO_CreateStringId(id, stringVar)
   SafeAddVersion(id, 1)
end

local DLCTooltipFmt = "<<1>>, <<2>>: <<3>>\n(<<5>> <<4>>)"
local function SetupDLCTooltip(str1, str2, zoneId, str4, str5)
	return zStrFmt(DLCTooltipFmt, str1, str2, GetZoneNameById(zoneId), str4, str5)
end

TQG.DLCQuestIdToTooltip = {
	[5935] = SetupDLCTooltip(GetString(TQG_PROLOGUE), "1/1", 849, GetString(TQG_SEEK), "'レア・オパカリウス'"),
	[6023] = SetupDLCTooltip(GetString(TQG_PROLOGUE), "1/1", 980, GetString(TQG_SEEK), "'目の騎士団の派遣'"),
	[6097] = SetupDLCTooltip(GetString(TQG_PROLOGUE), "1/1", 1011, GetString(TQG_SEEK), "'ヴァヌス・ガレリオン'"),
	[6226] = SetupDLCTooltip(GetString(TQG_PROLOGUE), "1/2", 726, GetString(TQG_SEEK), "'シロディール・コレクションにご協力を！'"),
	[6242] = SetupDLCTooltip(GetString(TQG_PROLOGUE), "2/2", 726, GetString(TQG_SEEK), "'コンコルディア・メルシウス'"),
	[6299] = SetupDLCTooltip(GetString(TQG_PROLOGUE), "1/2", 1086, GetString(TQG_SEEK), "'アナイス・ダヴォー'"),
	[6306] = SetupDLCTooltip(GetString(TQG_PROLOGUE), "2/2", 1086, GetString(TQG_SEEK), "'アブナー・サルン'"),
	[6395] = SetupDLCTooltip(GetString(TQG_PROLOGUE), "1/2", 1133, GetString(TQG_SEEK), "'ヒンズール'"),
	[6398] = SetupDLCTooltip(GetString(TQG_PROLOGUE), "2/2", 1133, "を訪れる", "'剣の渓谷'"),
}

local groupTooltipFmt = "<<1>>: (<<3>> <<2>>)"
local function SetupGroupTooltip(str1, str2, zoneIdOrName)
	local str3

	if type(zoneIdOrName) == "number" then str3 = GetZoneNameById(zoneId)
	elseif type(zoneIdOrName) == "string" then str3 = zoneIdOrName end

	return zStrFmt(groupTooltipFmt, str1, str2, str3)
end

TQG.GroupQuestIdToTooltip = {
	[5554] = SetupGroupTooltip(GetString(TQG_TRIAL), GetString(TQG_SEEK), "バクーム"),

	[6000] = SetupGroupTooltip(GetString(TQG_TRIAL), GetString(TQG_SEEK), "デイニロ・レサル"),
	[6193] = SetupGroupTooltip(GetString(TQG_TRIAL), GetString(TQG_SEEK), "ヴァンドリル"),

	[6354] = SetupGroupTooltip(GetString(TQG_TRIAL), GetString(TQG_SEEK), "ナトラダ"),

	[6504] = SetupGroupTooltip(GetString(TQG_TRIAL), GetString(TQG_SEEK), "ティルヴェラ"),

	[6597] = SetupGroupTooltip(GetString(TQG_ARENA), GetString(TQG_SEEK), "アンガイル"),

	[6655] = SetupGroupTooltip(GetString(TQG_TRIAL), GetString(TQG_SEEK), "マロスザ"),

	[6784] = SetupGroupTooltip(GetString(TQG_TRIAL), GetString(TQG_SEEK), "ヨーマン・ゲリーン"),

	[7032] = SetupGroupTooltip(GetString(TQG_TRIAL), GetString(TQG_SEEK), "アンシェ研究員"),
}