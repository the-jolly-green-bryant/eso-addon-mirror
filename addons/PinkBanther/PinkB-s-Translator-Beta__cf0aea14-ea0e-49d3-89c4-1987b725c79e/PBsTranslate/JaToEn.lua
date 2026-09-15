-- PB's Translate -- Japanese to English, for what the player sends (prototype)
--
-- The other direction of the add-on, and a much narrower one. Japanese has no spaces, drops
-- its subjects and puts the verb last, so a general rule-based translator would produce
-- English nobody wants to read in zone chat. What is covered instead is what a player
-- actually needs to say in a hurry:
--
--   * fixed expressions        ありがとう -> ty, 了解 -> roger
--   * Cyrodiil callouts        チャルマン砦の正門が攻撃されている -> chal fd lit
--                              ブラックブート砦に集合 -> stack at bb
--
-- The sentence is cut into known pieces by longest match (T.JaSegment), and the pieces are read
-- as "noun phrase (+ particle) + predicate": the noun phrase is collected until a predicate
-- arrives, and the predicate's template says where the noun phrase goes in the English.
-- Anything not in the tables is reported back, never guessed.
--
-- The English side uses the short forms Cyrodiil chat itself uses (chal, brk, fd), because a
-- callout spelled out in full is a callout nobody reads in time.

PBsTranslate = PBsTranslate or {}
local T = PBsTranslate

-- ---------------------------------------------------------------------------------------
-- Tables
-- ---------------------------------------------------------------------------------------

-- Whole expressions. Matched as pieces, so "了解、向かってる" is two of them.
local EXPRESSIONS = {
	["ありがとうございます"] = "thank you", ["ありがとう"] = "ty", ["サンキュー"] = "ty",
	["グループありがとう"] = "ty for group", ["蘇生ありがとう"] = "ty for rez",
	["よろしくお願いします"] = "hi, nice to meet you", ["よろしく"] = "hi",
	["お疲れ様でした"] = "gg", ["お疲れさまでした"] = "gg", ["お疲れ様"] = "gg", ["おつかれ"] = "gg",
	["いい戦いでした"] = "gf", ["ナイス"] = "nice", ["ナイスプレイ"] = "wp",
	["こんにちは"] = "hello", ["こんばんは"] = "good evening", ["おはよう"] = "good morning",
	["おはようございます"] = "good morning", ["おやすみ"] = "good night", ["おやすみなさい"] = "good night",
	["またね"] = "cya", ["さようなら"] = "bye", ["また明日"] = "see you tomorrow",
	["ごめんなさい"] = "sorry", ["ごめん"] = "sorry", ["すみません"] = "sorry", ["私のミスです"] = "my bad",
	["了解"] = "roger", ["了解です"] = "roger", ["わかりました"] = "ok", ["分かりました"] = "ok", ["OK"] = "ok",
	["はい"] = "yes", ["いいえ"] = "no", ["大丈夫"] = "np", ["問題ない"] = "np",
	["ちょっと待って"] = "wait a sec", ["待って"] = "wait", ["すぐ戻ります"] = "brb", ["すぐ戻る"] = "brb",
	["離席"] = "afk", ["離席します"] = "afk", ["戻りました"] = "back", ["もう寝ます"] = "going to bed",
	["おめでとう"] = "gz", ["おめでとうございます"] = "congrats",
	["招待してください"] = "inv pls", ["招待して"] = "inv pls", ["グループ募集"] = "lfg",
	["グループメンバーを探している"] = "lfg", ["蘇生してください"] = "rez pls", ["蘇生して"] = "rez pls",
	["助けて"] = "help", ["助けてください"] = "help pls",
	["向かっている途中"] = "omw", ["向かっています"] = "omw", ["向かってる"] = "omw", ["今行きます"] = "omw",
	["破城槌に乗って"] = "ram on", ["突入"] = "go in", ["撤退"] = "retreat", ["後退"] = "fall back",
	["散開"] = "spread", ["固まって"] = "stack", ["集合"] = "stack", ["待機"] = "hold",
	["英語は話せません"] = "I don't speak English", ["英語は苦手です"] = "my English is not good",
	["日本人です"] = "I'm Japanese", ["翻訳アドオンを使っています"] = "I'm using a translation add-on",
}

-- Nouns, with the English chat uses for them.
local NOUNS = {
	-- keeps, outposts, towns
	["チャルマン砦"] = "chal", ["アリウス砦"] = "arrius", ["キングクレスト砦"] = "kc", ["ファラガット砦"] = "farra",
	["ブルーロード砦"] = "brk", ["ドレイクロー砦"] = "drake", ["セヤヌス基地"] = "sej", ["ハルルン基地"] = "ho",
	["ブラックブート砦"] = "bb", ["ブラッドメイン砦"] = "bm", ["フェアユール砦"] = "fare", ["ローベック砦"] = "roe",
	["アレッシア砦"] = "alessia", ["ブリンドル砦"] = "brindle", ["ニケリ基地"] = "nikel", ["カーマラ基地"] = "carmala",
	["ウォーデン砦"] = "warden", ["レイレス砦"] = "rayles", ["グレイドミスト砦"] = "glade", ["アッシュ砦"] = "ash",
	["アレスウェル砦"] = "ales", ["ドラゴンクロー砦"] = "dragon", ["侵入者の基地"] = "bleaks",
	["ウィンターズ・ピークス基地"] = "wp", ["ブルーマの街"] = "bruma", ["ブルーマ"] = "bruma",
	["クロップスの街"] = "cropsford", ["ヴラスタルスの街"] = "vlastarus", ["インペリアルシティ"] = "ic",
	["チャルマン"] = "chal", ["アリウス"] = "arrius", ["キングクレスト"] = "kc", ["ファラガット"] = "farra",
	["ブルーロード"] = "brk", ["ドレイクロー"] = "drake", ["ブラックブート"] = "bb", ["ブラッドメイン"] = "bm",
	["フェアユール"] = "fare", ["ローベック"] = "roe", ["アレッシア"] = "alessia", ["ブリンドル"] = "brindle",
	["グレイドミスト"] = "glade", ["アレスウェル"] = "ales", ["ドラゴンクロー"] = "dragon",
	-- keep structure and resources
	["正門"] = "fd", ["裏門"] = "bd", ["内門"] = "inner", ["内郭の扉"] = "ifd", ["外壁"] = "outer",
	["通用門"] = "postern", ["壁"] = "wall", ["門"] = "door", ["旗"] = "flag",
	["資源"] = "rss", ["リソース"] = "rss", ["農場"] = "farm", ["鉱山"] = "mine", ["製材所"] = "lm",
	["鉱山サイド"] = "ms", ["製材所サイド"] = "ls", ["農場サイド"] = "fs", ["マイルゲート"] = "milegate", ["橋"] = "bridge",
	-- siege and camps
	["破城槌"] = "rams", ["燃え盛る油"] = "oils", ["油"] = "oils", ["攻城兵器"] = "siege",
	["カタパルト"] = "catas", ["トレビュシェット"] = "trebs", ["バリスタ"] = "ballistas", ["肉袋"] = "meatbags",
	["前線キャンプ"] = "camp", ["テント"] = "camp", ["キャンプ"] = "camp", ["修理キット"] = "repair kits",
	["塁壁石工修理キット"] = "wall repair kits", ["扉維持用木工修理キット"] = "door repair kits",
	-- the war
	["皇帝"] = "emp", ["星霜の書"] = "scroll", ["ヴォレンドラング"] = "hammer", ["トランシタスの祠"] = "transitus",
	["大集団"] = "zerg", ["ボールグループ"] = "ball group", ["敵"] = "enemy", ["ボマー"] = "bomber",
	["ガンカー"] = "ganker", ["ドミニオン"] = "ad", ["カバナント"] = "dc", ["パクト"] = "ep",
	["アルドメリ・ドミニオン"] = "ad", ["ダガーフォール・カバナント"] = "dc", ["エボンハート・パクト"] = "ep",
	["グループリーダー"] = "crown", ["クラウン"] = "crown", ["リーダー"] = "crown",
	-- roles and group
	["タンク"] = "tank", ["ヒーラー"] = "healer", ["DPS"] = "dps", ["グループ"] = "group", ["みんな"] = "everyone",
	["私"] = "me", ["ここ"] = "here", ["そこ"] = "there",
}

-- Predicates. {np} is where the noun phrase goes; a template without {np} ignores it.
-- The polite and casual endings players actually type are listed as separate keys.
local PREDICATES = {}

local function Predicate(template, ...)
	for index = 1, select("#", ...) do
		PREDICATES[select(index, ...)] = template
	end
end

Predicate("{np} lit", "攻撃されている", "攻撃されています", "攻撃されてる", "攻撃中", "攻撃を受けている", "攻撃を受けています")
Predicate("{np} ua", "奇襲", "奇襲されている", "奇襲されています")
Predicate("{np} down", "破られた", "破られました", "破られている", "破られています", "壊れた", "壊れました", "壊れています")
Predicate("{np} inc", "インカミング", "来る", "来ます", "来てる", "来ています", "向かってきている", "向かってきます")
Predicate("{np} lost", "奪われた", "奪われました", "取られた", "取られました")
Predicate("stack at {np}", "集合", "集合して", "集合してください", "集まって", "集まってください")
Predicate("push {np}", "攻めて", "攻めてください", "攻める", "攻めます", "攻めろ", "押して")
Predicate("def {np}", "防衛", "防衛して", "防衛してください", "守って", "守ってください", "防衛お願いします")
Predicate("need {np}", "必要", "必要です", "が必要", "が必要です", "欲しい", "欲しいです", "募集")
Predicate("omw to {np}", "向かっている", "向かっています", "向かってる", "向かっている途中", "向かいます")
Predicate("port to {np}", "ポートして", "ポートしてください", "テレポートして", "テレポートしてください")
Predicate("go {np}", "行って", "行ってください", "行こう", "行きます")
Predicate("repair {np}", "修理して", "修理してください", "直して", "直してください")
Predicate("drop {np}", "置いて", "置いてください", "出して", "出してください")
Predicate("retake {np}", "取り戻して", "取り戻してください", "奪還")
Predicate("{np} open", "開いた", "開いています")
Predicate("follow {np}", "についていって", "について行って", "についてきて", "についてきてください")

-- Pieces that carry no meaning of their own in a callout.
local PARTICLES = { ["が"] = true, ["を"] = true, ["に"] = true, ["へ"] = true, ["は"] = true, ["で"] = true, ["から"] = true, ["の"] = "of" }
local FILLERS = {
	["です"] = true, ["ます"] = true, ["ください"] = true, ["よ"] = true, ["ね"] = true, ["！"] = true, ["？"] = true,
	["!"] = true, ["?"] = true, ["。"] = "break", ["、"] = "break", ["，"] = "break", ["．"] = "break", ["・"] = true,
	[" "] = true, ["　"] = true, ["お願いします"] = true, ["お願い"] = true,
}

-- Every key, longest first, so that 攻撃されています wins over 攻撃されている.
local KEYS = {}
do
	local seen = {}
	local function Collect(tableOfKeys, kind)
		for key, value in pairs(tableOfKeys) do
			if not seen[key] then
				seen[key] = true
				KEYS[#KEYS + 1] = { key = key, kind = kind, value = value }
			end
		end
	end
	Collect(PREDICATES, "predicate")
	Collect(EXPRESSIONS, "expression")
	Collect(NOUNS, "noun")
	Collect(PARTICLES, "particle")
	Collect(FILLERS, "filler")
	table.sort(KEYS, function(a, b)
		if #a.key ~= #b.key then
			return #a.key > #b.key
		end
		return a.key < b.key
	end)
end

-- Byte length of the UTF-8 character starting at i.
local function CharLength(text, i)
	local byte = text:byte(i)
	if not byte or byte < 0x80 then
		return 1
	elseif byte >= 0xF0 then
		return 4
	elseif byte >= 0xE0 then
		return 3
	elseif byte >= 0xC0 then
		return 2
	end
	return 1
end

-- Cut the text into pieces: { kind = "noun"|"predicate"|"expression"|"particle"|"filler"|"ascii"|"unknown", key, value }
function T.JaSegment(text)
	local pieces = {}
	local i, length = 1, #text
	while i <= length do
		local matched
		for _, candidate in ipairs(KEYS) do
			local key = candidate.key
			if text:sub(i, i + #key - 1) == key then
				matched = candidate
				break
			end
		end
		if matched then
			pieces[#pieces + 1] = { kind = matched.kind, key = matched.key, value = matched.value }
			i = i + #matched.key
		else
			local c = text:sub(i, i)
			if c:match("[A-Za-z0-9%+%-]") then
				-- ASCII words pass through as themselves: "vMA", "2", "x"
				local run = text:match("^[A-Za-z0-9%+%-]+", i)
				pieces[#pieces + 1] = { kind = "ascii", key = run, value = run }
				i = i + #run
			else
				local size = CharLength(text, i)
				local last = pieces[#pieces]
				local char = text:sub(i, i + size - 1)
				if last and last.kind == "unknown" then
					last.key = last.key .. char
				else
					pieces[#pieces + 1] = { kind = "unknown", key = char }
				end
				i = i + size
			end
		end
	end
	return pieces
end

-- Translate. Returns the English, and a list of the Japanese it could not read (empty when
-- everything was understood).
function T.TranslateJaToEn(text)
	local out, unknown = {}, {}
	local phrase = {}
	-- A noun phrase closed by に/で/へ (where) or から (from), kept until the predicate says
	-- whether it is the target ("bbに集合" -> stack at bb) or a place for another object
	-- ("正門に破城槌が必要" -> need rams at fd).
	local place, placeWord

	local function FlushPhrase()
		if place then
			out[#out + 1] = (placeWord == "from" and "from " or "") .. place
			place, placeWord = nil, nil
		end
		if #phrase > 0 then
			out[#out + 1] = table.concat(phrase, " ")
			phrase = {}
		end
	end

	for _, piece in ipairs(T.JaSegment(tostring(text or ""))) do
		local kind = piece.kind
		if kind == "noun" or kind == "ascii" then
			phrase[#phrase + 1] = piece.value
		elseif kind == "particle" and (piece.key == "に" or piece.key == "で" or piece.key == "へ" or piece.key == "から") then
			if #phrase > 0 then
				place = table.concat(phrase, " ")
				placeWord = piece.key == "から" and "from" or "at"
				phrase = {}
			end
		elseif kind == "predicate" then
			local np = table.concat(phrase, " ")
			local extra = ""
			if np == "" and place then
				np = place
				if placeWord == "from" then
					np = "from " .. np
				end
			elseif place then
				extra = " " .. placeWord .. " " .. place
			end
			phrase, place, placeWord = {}, nil, nil
			local english = piece.value:gsub("{np}", np) .. extra
			english = english:gsub("^ +", ""):gsub(" +$", ""):gsub(" +", " ")
			-- "to" or "at" with nothing after it: "omw to" -> "omw"
			english = english:gsub(" to$", ""):gsub(" at$", "")
			english = english:gsub(" at here", " here"):gsub(" to here", " here"):gsub(" at there", " there"):gsub(" to there", " there")
			english = english:gsub("^stack at crown", "stack on crown"):gsub(" to from ", " from "):gsub(" at from ", " from ")
			out[#out + 1] = english
		elseif kind == "expression" then
			FlushPhrase()
			out[#out + 1] = piece.value
		elseif kind == "filler" and piece.value == "break" then
			FlushPhrase()
		elseif kind == "unknown" then
			unknown[#unknown + 1] = piece.key
		end
		-- other particles and fillers carry nothing into callout English
	end
	FlushPhrase()

	-- One callout per clause, joined the way chat joins them.
	return table.concat(out, ", "), unknown
end
