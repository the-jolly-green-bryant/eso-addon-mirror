--[[
    PvPTargetInfo_Target.lua

    担当は「敵の重要バフ(UI①)」「敵の重要デバフ(UI②)」の検出・表示。
    HP表示、処刑ライン警告、自分のバフ/デバフ表示、HPによる各種判定は廃止
    (自身のProc表示だけはPvPTargetInfo_Procs.luaが担当)。

    修正改定3: 「重要」の判定方式を変更。
      これまでは手動で登録(sv.watchedBuffs / sv.watchedDebuffs)した
      AbilityIdだけを表示する方式だったが、毎回の登録作業が煩わしいという
      要望を受け、以下の2階建てに変更した。

      ① 自動検知(既定でON, sv.autoDetect.enabled)
         ・デバフ側: ゲームエンジンが分類する状態異常の種類(statusEffectType)が
           スタン/サイレンス/根絶やし/移動速度低下/恐怖/幻惑/よろめき(Off Balance)
           などの「行動阻害系(CC)」に該当するものを自動的に重要デバフとして表示する。
           これはAbilityId(スキルごとに異なる番号)ではなく効果の種類そのもので
           判定しているため、新しいスキルやパッチでID体系が変わっても影響を受けにくい。
         ・バフ/デバフ共通: 効果名に "Major"/"Minor"(英語版)または
           日本語版の語尾表記 "(強)"/"(弱)" が含まれるものを自動的に
           重要として表示する(名前のどこにあってもよい部分一致判定。
           自動検知が有効な間はこの4語すべてを常に対象にする。個別に
           英語/日本語をON/OFFする案もv1.4.11で一度試したが、意味が
           ないとのことでv1.4.12で単純な1つのON/OFFに戻した)。
      ② 手動登録(任意, sv.watchedBuffs / sv.watchedDebuffs)
         自動検知では拾えない特定の効果(セット効果由来の特殊なバフ等)を
         追加で表示したい場合のための、あくまで補助的な機能として残している。

      内部的にはstatusEffectTypeの定数名をゲーム側の実際の定義から動的に
      引いているため(_G[定数名])、該当する定数が存在しない/名前が違う場合は
      単にその判定条件が働かないだけで、エラーにはならない安全な作りにしている。
      実機で意図通りに拾えているかは /pti learn target で確認できる。

    v1.4.1で修正:
      - パネルは「重要バフ/デバフが実際にある時だけ表示」だったのを、
        「有効になっている限り常時表示」に変更(中身が空なら案内を表示)。
      - 設定画面を開いたことを自動検知してプレビュー表示に切り替える仕組みは
        廃止し、sv.previewMode (設定画面のチェックボックス)で手動切替する
        方式にした。

    v1.4.3で追加(修正改定4): 表示順を「登場順/検出順」ではなく、
    戦闘上の重要度カテゴリ順に変更した。
      バフ: ①防御・ダメージ軽減 → ②回復・生存 → ③攻撃力・与ダメージ強化
            → ④クリティカル関連 → ⑤機動力・CC耐性 → ⑥その他の戦闘系
      デバフ: ①防御低下・被ダメージ増加 → ②回復阻害 → ③攻撃力・与ダメージ低下
              → ④CC・行動阻害 → ⑤強力なDoT → ⑥その他の戦闘系
      ただし残り時間がURGENT_REMAINING_THRESHOLD秒以下のものは、カテゴリに
      関わらず最優先で上位表示する(消える寸前の効果を見逃さないため)。
      分類は効果名のキーワード一致で行うため、ゲーム内表示言語が英語以外の
      場合はBUFF_CATEGORY_ORDER/DEBUFF_CATEGORY_ORDERのキーワードを
      書き換える必要がある(自動検知キーワードと同様の考え方)。

    v1.4.4で追加(修正改定6): 検出方式を全面的に見直した。
      ① プレイヤー判定を最優先にした。
         IsUnitPlayer("reticleover") でプレイヤーかどうかを最初に判定し、
         NPC・モンスター・衛兵や、壁・扉・通用口などのオブジェクトは
         一切反応しない(そもそも効果の収集自体を行わない)。
         ターゲットが変わるたびに EVENT_RETICLE_TARGET_CHANGED で再判定し、
         プレイヤー以外になった瞬間にUIへの反映を止める(表示自体は
         sv.holdDurationの間だけ直前のプレイヤー情報を保持する、③の
         「表示安定性」と同じ考え方)。
      ② 効果検知をポーリングからイベント駆動に変更した。
         これまでは0.1秒ごとにGetUnitBuffInfoで全バフを毎回読み直して
         いたが、EVENT_EFFECT_CHANGED(対象はreticleoverにフィルタ)を
         使い、効果の付与(GAINED)・更新(UPDATED相当、GAINEDが再度飛ぶ)・
         消失(FADED)をイベント単位で処理する方式にした。
         ・ターゲットを変更した瞬間は、その時点で既に付与されている
           効果がイベントとしては飛んでこない(イベントは「変化」にしか
           発火しないため)。そのため、ターゲット変更時にGetUnitBuffInfoで
           現在の全バフを1回だけ読み、キャッシュ(targetEffects)を
           作り直す「初期スキャン」を行った上で、以後はイベントだけで
           差分更新する。
         ・同じAbilityIdのエントリはtargetEffects[abilityId]という
           テーブルに1つしか存在できない構造にしているため、同じ効果が
           重複して表示されることはない。
         ・自動検知/手動登録の判定(重要かどうか)は、AbilityIdそのもの
           ではなく効果名・statusEffectTypeで行っている(既存のIsAutoImportant/
           手動登録は引き続きAbilityId基準)点は変更していない。
         ・自動検知キーワードや手動登録リストを設定画面で変更した場合は、
           PTI.Target.ForceRefresh()経由でtargetEffectsを再スキャンし、
           変更を即座に反映する。

    ターゲット解除後は、直前の情報を sv.holdDuration 秒だけ保持してから
    非表示にする(PvPの激しい動きでカーソルが一瞬外れても消えないように)。
    新しい敵をターゲットしたら保持中でも即座に新しい情報へ切り替える。
--]]

PvPTargetInfo = PvPTargetInfo or {}
local PTI = PvPTargetInfo
PTI.Target = PTI.Target or {}

local UPDATE_NAME = "PTI_TargetUpdate"
local UPDATE_INTERVAL_MS = 100 -- 残り時間による強調の切り替わりを見逃さないよう短めの間隔にしている

--------------------------------------------------------------------------
-- 検知パイプラインのデバッグログ(v1.4.6で追加)
--
-- sv.debug.pipelineTrace が true の間だけチャットに1行ずつ出力する。
-- 既定はOFFで、通常プレイでは呼び出されても何も起こらない
-- (dは一切呼ばれない)ため、実戦中にログでチャットが埋まる心配はない。
-- 学習モード(sv.procs.debugLearnModeTarget)とは完全に独立していて、
-- こちらは候補登録を一切行わない、純粋な経路確認用のログ。
--------------------------------------------------------------------------
local function DebugTrace(fmt, ...)
    if PTI.sv.debug and PTI.sv.debug.pipelineTrace then
        d("|c888888[PTI Debug]|r " .. string.format(fmt, ...))
    end
end

local function CountTable(t)
    local n = 0
    for _ in pairs(t) do n = n + 1 end
    return n
end

--------------------------------------------------------------------------
-- 自動検知①: 状態異常(CC)の種類による判定
--
-- ゲームバージョンによって定数の有無・名前が変わる可能性があるため、
-- 存在しない定数名は_G参照がnilになるだけで安全にスキップされる
-- (比較対象がnilになるだけで、エラーにはならない)。
--------------------------------------------------------------------------
local CC_STATUS_EFFECT_TYPES = {}
local function RegisterCCStatusType(constantName)
    local value = _G[constantName]
    if value ~= nil then
        CC_STATUS_EFFECT_TYPES[value] = true
    end
end
local CC_STATUS_EFFECT_TYPE_NAMES = {
    "STATUS_EFFECT_TYPE_STUN",
    "STATUS_EFFECT_TYPE_SNARE",
    "STATUS_EFFECT_TYPE_ROOT",
    "STATUS_EFFECT_TYPE_SILENCE",
    "STATUS_EFFECT_TYPE_FEAR",
    "STATUS_EFFECT_TYPE_CHARM",
    "STATUS_EFFECT_TYPE_DISORIENT",
    "STATUS_EFFECT_TYPE_STAGGER",
    "STATUS_EFFECT_TYPE_OFFBALANCE",
    "STATUS_EFFECT_TYPE_UNSTABLE",
    "STATUS_EFFECT_TYPE_TRAPPED",
}
local ccUnresolvedNames = {}
for _, constantName in ipairs(CC_STATUS_EFFECT_TYPE_NAMES) do
    RegisterCCStatusType(constantName)
    if _G[constantName] == nil then
        table.insert(ccUnresolvedNames, constantName)
    end
end

--------------------------------------------------------------------------
-- 自動検知②: 効果名のキーワードによる判定
--
-- v1.4.7で修正(重要バグ修正): 日本語版ESOでは「Major/Minor」に相当する
-- 表示が英語版のような語頭(例: "Major Brutality")ではなく、
-- 「残忍(強)」「強固(弱)」のように語尾の "(強)"/"(弱)" になる。
-- これまでは前方一致(name:find(kw,1,true)==1、＝先頭からの一致のみ)で
-- 判定していたため、日本語表示では絶対に一致せず、自動検知が
-- 実質的に機能していなかった。部分一致(先頭に限らず、名前のどこかに
-- キーワードが含まれていればOK)に変更し、既定キーワードにも
-- 日本語版の "(強)"/"(弱)" を追加した。
--------------------------------------------------------------------------
-- v1.4.12で修正: 英語表記/日本語表記を個別にON/OFFできるようにしていたが、
-- 「意味がない」とのことで単純な固定リストに戻した。自動検知が有効な間は
-- 常にこの4語(英語版Major/Minor、日本語版(強)/(弱))すべてを対象にする。
local AUTO_DETECT_KEYWORDS = { "Major", "Minor", "(強)", "(弱)" }
local function GetAutoDetectKeywords()
    return AUTO_DETECT_KEYWORDS
end

-- 部分一致で判定する(plain=trueでパターンではなく単純文字列として比較)。
-- 英語版の "Major Brutality"(先頭一致)、日本語版の "残忍(強)"(末尾一致)の
-- どちらにも対応できるよう、名前中のどこかにキーワードが含まれていれば
-- 一致とみなす。
local function NameMatchesKeyword(name, keywords)
    for _, kw in ipairs(keywords) do
        if name:find(kw, 1, true) then return true end
    end
    return false
end

local function IsAutoImportant(kind, buffName, statusEffectType, keywords)
    if kind == "debuff" and CC_STATUS_EFFECT_TYPES[statusEffectType] then
        return true
    end
    return NameMatchesKeyword(buffName, keywords)
end

-- v1.4.23で追加: PvPTargetInfo_Procs.lua(Condition/旧Procパネル)から、
-- 「敵のDEBUFF自動検知と全く同じ判定方法」を使って、自分に付いている
-- デバフを検知できるようにするための公開ラッパー。
-- 判定基準(CC系statusEffectType、またはMajor/Minor・(強)/(弱)の
-- キーワード一致)は敵デバフの自動検知(①②)と完全に同一のロジックを
-- そのまま再利用している(判定式を重複実装しない)。
function PTI.Target.IsAutoImportantDebuff(buffName, statusEffectType)
    if type(buffName) ~= "string" or buffName == "" then return false end
    return IsAutoImportant("debuff", buffName, statusEffectType, GetAutoDetectKeywords())
end

--------------------------------------------------------------------------
-- 表示優先順位: カテゴリ分類(修正改定4)
--
-- 「基本は重要度(カテゴリ)順、ただし残り時間が短いものは優先して上位に
-- 表示する」という表示ルールを実現するための分類テーブル。
--
-- 判定は効果名の部分一致で行う。Major版とMinor版は数値が違うだけで
-- カテゴリは同じなので、接頭辞(Major/Minor)を含めず効果ファミリー名
-- (Resolve, Breachなど)だけをキーワードにしている。
--
-- 既定値は英語表記("Major"/"Minor"や日本語版の(強)/(弱)を自動検知する
-- 既定キーワードとは別物で、こちらはカテゴリ分類専用のキーワード)。日本語
-- 表示等、別のゲーム内表示言語でプレイしている場合は、下記キーワードを
-- 実際に表示される効果名に合わせて書き換えないと、表示自体はされるが
-- 並び順が「その他」扱いになる(表示の可否には影響しない)。
--------------------------------------------------------------------------

-- バフ側: 数字が小さいほど優先度が高い(上位表示)
-- v1.4.29で修正: 実際のツールチップ確認により、日本語版での呼び名の対応関係に
-- 誤りがあったことが判明。
--   ・"不屈"は防御(Resolve)ではなく回復・生存系(Fortitude、体力再生+効果)
--   ・防御(Resolve)の日本語名は"強固"
-- という対応が正しいため、"不屈"を①防御から外し②回復・生存へ移動、
-- ①防御には正しい呼び名"強固"を追加した。あわせて②回復・生存に
-- "治癒力"(Mending)、"耐久"(Endurance)、"知力"(Intellect)、
-- "頑強"(Toughness)の日本語名も追加している(英語表記のみでは日本語版
-- クライアントの表示名に一致せず、検知はされるが分類が「その他」行きに
-- なっていたため)。
-- 対応表: Resolve→強固 / Protection→防護 / Evasion→回避 (以上①防御)
--         Vitality→生命力 / Mending→治癒力 / Fortitude→不屈 /
--         Endurance→耐久 / Intellect→知力 / Toughness→頑強 (以上②回復・生存)
local BUFF_CATEGORY_ORDER = {
    -- ① 防御・ダメージ軽減
    { rank = 1, keywords = { "Resolve", "強固", "Evasion", "回避", "Protection", "防護" } },
    -- ② 回復・生存
    { rank = 2, keywords = { "Vitality", "生命力", "Mending", "治癒力", "Fortitude", "不屈", "Endurance", "耐久", "Intellect", "知力", "Lifesteal", "Toughness", "頑強" } },
    -- ③ 攻撃力・与ダメージ強化
    { rank = 3, keywords = { "Brutality", "Sorcery", "Berserk", "Courage", "Slayer", "Empower" } },
    -- ④ クリティカル関連
    { rank = 4, keywords = { "Prophecy", "Savagery", "Force" } },
    -- ⑤ 機動力・CC耐性
    { rank = 5, keywords = { "Expedition", "Gallop", "Heroism" } },
}
local BUFF_OTHER_RANK = 6 -- ⑥ その他の戦闘系(上記に該当しない重要バフ)

-- デバフ側: 数字が小さいほど優先度が高い(上位表示)
-- 「CC・行動阻害」(rank=4)は効果名ではなく既存のCC_STATUS_EFFECT_TYPES
-- (statusEffectType)で判定するため、このテーブルには含めていない。
local DEBUFF_CATEGORY_ORDER = {
    -- ① 防御低下・被ダメージ増加
    { rank = 1, keywords = { "Breach", "Vulnerability", "Brittle" } },
    -- ② 回復阻害
    { rank = 2, keywords = { "Defile" } },
    -- ③ 攻撃力・与ダメージ低下
    { rank = 3, keywords = { "Maim", "Cowardice", "Uncertainty" } },
    -- ⑤ 強力なDoT
    -- v1.4.27で追加: DKリワーク(U49)の新DoT「Wildfire Embers」用に"Embers"を追加。
    { rank = 5, keywords = { "Poison", "Disease", "Burning", "Bleed", "Deep Wound", "Sundered", "Embers" } },
}
local DEBUFF_CC_RANK = 4    -- ④ CC・行動阻害(statusEffectTypeで判定)
local DEBUFF_OTHER_RANK = 6 -- ⑥ その他の戦闘系(上記に該当しない重要デバフ)

-- 残り時間がこの秒数以下になったら、カテゴリ順位に関わらず上位表示する。
-- UI①・UI②の強調色ティア(黄色以上、残り5秒以内)と揃えてある。
local URGENT_REMAINING_THRESHOLD = 5

local function LookupCategoryRank(order, name)
    for _, group in ipairs(order) do
        for _, kw in ipairs(group.keywords) do
            if name:find(kw, 1, true) then
                return group.rank
            end
        end
    end
    return nil
end

-- 表示中の1件について、表示優先度用のカテゴリ順位を返す(数字が小さいほど上位)。
-- 手動登録した効果も、名前が上記キーワードに一致すれば同様に分類され、
-- 一致しなければ「その他の戦闘系」として最下位カテゴリに入る
-- (表示すること自体は登録時点で保証されているため、順位が最下位でも
-- 表示対象から外れることはない)。
local function GetCategoryRank(kind, buffName, statusEffectType)
    if kind == "debuff" and CC_STATUS_EFFECT_TYPES[statusEffectType] then
        return DEBUFF_CC_RANK
    end
    local order = (kind == "debuff") and DEBUFF_CATEGORY_ORDER or BUFF_CATEGORY_ORDER
    return LookupCategoryRank(order, buffName) or ((kind == "debuff") and DEBUFF_OTHER_RANK or BUFF_OTHER_RANK)
end

--------------------------------------------------------------------------
-- 手動登録リスト(任意)
-- 形式: sv.watchedBuffs[abilityId] = { name = "表示名", enabled = true }
--       sv.watchedDebuffs[abilityId] = { name = "表示名", enabled = true }
-- enabled=false のエントリは「登録はされているが今は非表示」の状態になる。
--------------------------------------------------------------------------

local function GetWatchTable(kind)
    return kind == "debuff" and PTI.sv.watchedDebuffs or PTI.sv.watchedBuffs
end

function PTI.Target.AddWatch(kind, abilityId, name)
    abilityId = tonumber(abilityId)
    if not abilityId then return false end
    local t = GetWatchTable(kind)
    t[abilityId] = { name = name or ("ability " .. tostring(abilityId)), enabled = true }
    if PTI.Target.ForceRefresh then PTI.Target.ForceRefresh() end
    return true
end

function PTI.Target.RemoveWatch(kind, abilityId)
    abilityId = tonumber(abilityId)
    if not abilityId then return false end
    local t = GetWatchTable(kind)
    if not t[abilityId] then return false end
    t[abilityId] = nil
    if PTI.Target.ForceRefresh then PTI.Target.ForceRefresh() end
    return true
end

function PTI.Target.SetWatchEnabled(kind, abilityId, enabled)
    abilityId = tonumber(abilityId)
    local t = GetWatchTable(kind)
    if not t or not t[abilityId] then return false end
    t[abilityId].enabled = enabled
    if PTI.Target.ForceRefresh then PTI.Target.ForceRefresh() end
    return true
end

function PTI.Target.ClearWatch(kind)
    ZO_ClearTable(GetWatchTable(kind))
    if PTI.Target.ForceRefresh then PTI.Target.ForceRefresh() end
end

function PTI.Target.IsWatchListEmpty(kind)
    return next(GetWatchTable(kind)) == nil
end

-- LAM2の手動編集欄・チャットコマンドのlist表示用に、abilityIdでソートした配列で取得する。
function PTI.Target.GetWatchListSorted(kind)
    local t = GetWatchTable(kind)
    local ids = {}
    for id in pairs(t) do table.insert(ids, id) end
    table.sort(ids)
    local list = {}
    for _, id in ipairs(ids) do
        table.insert(list, { id = id, name = t[id].name, enabled = t[id].enabled })
    end
    return list
end

--------------------------------------------------------------------------
-- v1.4.27/v1.4.28で追加: クラスリワーク対応(初回のみ自動登録)
--
-- Major/Minorも(強)/(弱)も名乗らないため自動検知の対象外になる、
-- しかし戦闘判断上重要な新効果を、初回起動時にだけ手動登録リストへ
-- 追加する。AbilityIdはesoui.com配布のLuiData(v7227)から確認したもの。
-- 版を追うごとに追加できるよう、SEED_STEPSに版数ごとのリストを積み
-- 上げていく方式にしている(sv.seedVersionより新しい版だけを適用し、
-- 適用後は最も新しい版数まで一気に引き上げる)。
--
-- v1(v1.4.27): DKリワーク(U49) / ウェアウルフリワーク(U50)の固有効果
-- v2(v1.4.28): 全7クラス共通の「クラスマスタリー・アビリティ」(U49〜U50頃に
--   全クラスへ追加された新パッシブ群、各クラス5種)のうち、(強)/(弱)を
--   名乗らずMajor/Minorキーワードに引っかからない自己強化バフ。
--   (強)/(弱)を名乗るもの(前線からの指揮の狂戦士(強)/防護(強)、
--   氷河の執念が使う勇壮(強)等)は既存の自動検知で拾えるため対象外。
--
-- 名前はGetAbilityNameで実機のゲーム内表示言語(日本語)から取り直す
-- ため、ここでの名前は「見つからなかった場合の保険」に過ぎない。
-- 一度追加した後にユーザーが手動で削除しても、その版数は適用済み扱いに
-- なるため再追加されない。
--------------------------------------------------------------------------
local SEED_STEPS = {
    {
        version = 1,
        buffs = {
            { id = 122658, name = "Seething Fury" },      -- DK: Molten Whipのスタックバフ(U49)
            { id = 267744, name = "Blood Hunger" },       -- WW: Roar系モーフの吸血スタック(U50)
            { id = 268571, name = "Insatiable Hunger" },  -- WW: デボア発動中の回復状態(U50)
            { id = 267425, name = "Enduring Rampage" },   -- WW: Rampageアルティメットのモーフ(U50)
        },
        debuffs = {
            { id = 263208, name = "Wildfire Embers" }, -- DK: 継続ダメージ持続効果(U49)
        },
    },
    {
        version = 2,
        buffs = {
            { id = 263220, name = "Resolute Defense" },        -- DK: 堅固な防御(ガード累積バフ)
            { id = 263247, name = "Lead from the Front" },     -- DK: 前線からの指揮(発動マーカー)
            { id = 29463,  name = "Landslide" },                -- DK: 地滑り(スタックバフ, rank1)
            { id = 44984,  name = "Landslide" },                -- DK: 地滑り(スタックバフ, rank2)
            { id = 263603, name = "Nocturnal Inspiration" },   -- NB: ノクターナルの閃き
            { id = 263606, name = "Cutthroat's Focus" },       -- NB: 殺し屋の集中
            { id = 263871, name = "Font of Power" },           -- ソーサラー: 力の泉
            { id = 263873, name = "Calculated Defense" },      -- ソーサラー: 計算された防御
            { id = 263587, name = "Bright Harbinger" },        -- テンプラー: 輝く導き手
            { id = 263588, name = "Judgment's Brand" },        -- テンプラー: 審判の烙印
            { id = 263521, name = "Glacial Obstinance" },      -- ウォーデン: 氷河の執念
            { id = 263509, name = "Cycle Unending" },          -- ネクロマンサー: 終わらない循環
            { id = 263448, name = "Nothing Wasted" },          -- ネクロマンサー: 無駄なし
            { id = 263316, name = "Abyssal Emergence" },       -- アルカニスト: 深淵からの登場
        },
        debuffs = {},
    },
}

local function SeedReworkWatchEntries()
    local currentVersion = PTI.sv.seedVersion or 0
    local highestApplied = currentVersion

    local function seedInto(kind, list)
        local t = GetWatchTable(kind)
        for _, entry in ipairs(list) do
            if t[entry.id] == nil then
                -- 実機のゲーム内表示名が取れればそちらを使う(日本語版なら
                -- 日本語名になる)。取れない場合は上記の仮名称のままにする。
                local resolvedName = GetAbilityName and GetAbilityName(entry.id)
                t[entry.id] = { name = (resolvedName ~= nil and resolvedName ~= "") and resolvedName or entry.name, enabled = true }
            end
        end
    end

    for _, step in ipairs(SEED_STEPS) do
        if step.version > currentVersion then
            seedInto("buff", step.buffs)
            seedInto("debuff", step.debuffs)
            if step.version > highestApplied then highestApplied = step.version end
        end
    end

    if highestApplied ~= currentVersion then
        PTI.sv.seedVersion = highestApplied
    end
end

--------------------------------------------------------------------------
-- ① プレイヤー判定
--
-- reticleoverが「存在し、かつプレイヤーである」場合だけ有効な対象として
-- 扱う。NPC・モンスター・衛兵は当然IsUnitPlayerがfalseになるため除外され、
-- 通用口・壁・扉・篝火などの相互作用可能なオブジェクトはそもそも
-- reticleoverのユニットとして存在しない(DoesUnitExistがfalse)か、
-- 存在してもプレイヤーではないため、いずれにせよここで弾かれる。
--
local function IsValidEnemyTarget()
    if not (DoesUnitExist("reticleover") and IsUnitPlayer("reticleover")) then
        return false
    end
    return true
end

--------------------------------------------------------------------------
-- ①' 敵プレイヤーのみ表示フィルタ(v1.4.37で復活、表示専用)
--
-- 「①②の対象を敵プレイヤーのみに限定する」設定(PTI.sv.targetEnemyOnly、
-- 既定OFF)は、v1.4.36で一度撤去したが、シロディールで味方プレイヤーを
-- ターゲットしても①②が反応してしまう不満は依然として残っているため、
-- 実装方式を変えて復活させた。
--
-- v1.4.36までの実装は、この判定をIsValidEnemyTarget()自体に混ぜ込み、
-- RescanCurrentTargetEffects/OnReticleEffectChangedという「検知・キャッシュ
-- 構築そのもの」のゲートに直結させていた。GetUnitReactionはバトルグラウンド
-- (対戦相手も内部的には同じアライアンス扱いになる)や、ターゲット直後の
-- 一瞬の同期遅延で不正確な値を返すことがあり、これが初期スキャンの時点で
-- falseと評価されるとtargetEffectsが二度と作られず、「検知ロジックは
-- 正常なのにBUFFが一切出ない」という実機不具合につながっていた
-- (v1.4.36削除時の実機検証で確認済み)。
--
-- v1.4.37では、GetUnitReactionによる敵味方判定を検知パイプラインから
-- 完全に切り離し、OnUpdate内の「表示直前」だけで使う独立フィルタとした。
-- RescanCurrentTargetEffects/OnReticleEffectChangedは一切呼び出さず、
-- targetEffectsキャッシュの構築・BUFF/DEBUFFの分類・優先順位判定
-- (EvaluateEffect/UpsertTargetEffect/GetCategoryRank等)には何の影響も
-- 与えない。OnUpdateは0.1秒ごとに走るため、GetUnitReactionが一時的に
-- 不正確な値を返しても、次のティックで正しい値に戻り次第自動的に
-- 表示へ復帰する(検知データ自体は最初から失われていないため)。
-- GetUnitReactionは1回のAPI呼び出しのみで、ループや追加のメモリ確保は
-- 発生しないため、0.1秒間隔で呼んでも負荷・メモリ使用量への影響はない。
--
-- 引数なしでreticleoverの存在自体をDoesUnitExistで確認してから呼ぶことで、
-- ユニットが存在しない状態でのGetUnitReaction呼び出し(想定外の戻り値)を
-- あらかじめ避けている。
local function PassesEnemyOnlyDisplayFilter()
    if not PTI.sv.targetEnemyOnly then
        return true
    end
    if not DoesUnitExist("reticleover") then
        return false
    end
    local reaction = GetUnitReaction("reticleover")
    if reaction == nil then
        return false
    end
    return reaction == UNIT_REACTION_HOSTILE
end

--------------------------------------------------------------------------
-- ② 効果キャッシュ(修正改定6)
--
-- targetEffects[abilityId] = { kind=, name=, stackCount=, endTime=, categoryRank= }
-- 「現在ターゲット中のプレイヤーが持つ、重要と判定された効果」だけを
-- 保持する。キーがAbilityIdなので同じ効果が重複して入ることはない。
--------------------------------------------------------------------------
local targetEffects = {}

-- v1.4.31で追加: ターゲット取得直後、ESO側の効果データ(GetUnitBuffInfo)が
-- まだ完全に同期されていない一瞬に初期スキャンが走ってしまい、本来ついている
-- はずのBUFFが0件のまま取りこぼされることがある(実機確認済み。カーソルを
-- 一度外して再度合わせると表示されることから、読み込みのタイムラグが原因と
-- 判明)。対策として、ターゲット変更時に即時スキャンへ加えて150ms後にもう
-- 一度だけ保険のスキャンを行う。ループ・毎フレーム処理ではなく単発タイマー
-- 1つだけで、対象が既に切り替わっていれば何もせず捨てる(世代番号で判定)。
local RESCAN_RETRY_DELAY_MS = 150
-- v1.4.34で追加: 150ms保険スキャンだけでは追いつかない混雑時
-- (シロディール/BG)向けに、400ms後の2段目保険スキャンを追加する。
-- 既存の150ms版・検知ロジック・世代チェックの仕組みには一切手を
-- 加えず、同じ構造をもう1本(単発タイマー)追加するだけ。
local RESCAN_RETRY2_DELAY_MS = 400
local targetGeneration = 0

-- 効果1件について、現在の設定(自動検知/手動登録)で重要と判定されるかどうかを返す。
-- 重要でなくなった場合(手動登録が削除された等)も呼び出し元でtargetEffectsから
-- 除去できるよう、判定結果だけを返す純粋な関数にしてある。
-- v1.4.14で修正: 従来は「重要かどうか(isManual or isAuto)」がそのまま
-- 「表示するかどうか」だったが、全表示モードのために両者を分離した。
-- 戻り値はisImportant(自動検知/手動登録で重要と判定されたか)とdisplayName。
-- 「表示するかどうか」の最終判定はUpsertTargetEffect側で行う
-- (全表示モードでは、重要でなくても背景バフでなければ表示する)。
local function EvaluateEffect(kind, abilityId, buffName, statusEffectType)
    local watch = GetWatchTable(kind)[abilityId]
    local isManual = watch ~= nil and watch.enabled
    local isAuto = (not isManual) and PTI.sv.autoDetect.enabled
        and IsAutoImportant(kind, buffName, statusEffectType, GetAutoDetectKeywords())
    local isImportant = isManual or isAuto
    local displayName = buffName
    if isManual and watch.name ~= "" then displayName = watch.name end
    return isImportant, displayName
end

-- v1.4.14で追加: 全表示モードで、食事バフ・マウント速度・ギルドバフのような
-- 「常時付いていて今更確認する必要のない」背景バフを除外するための判定。
-- duration(効果の全長、秒)がnil(=無期限・永続効果)、または設定した
-- 閾値(既定120秒)を超える場合に「背景バフ」とみなす。
-- APIの想定外の戻り値(durationが数値でない等)にも安全側(背景バフ扱い=除外)
-- で倒すようにしている。
local function IsBackgroundBuff(duration)
    if type(duration) ~= "number" then return true end
    local threshold = (PTI.sv.showAll and PTI.sv.showAll.hideLongerThan) or 120
    if type(threshold) ~= "number" or threshold <= 0 then threshold = 120 end
    return duration > threshold
end

-- 効果1件をtargetEffectsへ反映する(重要でなければ削除、重要なら追加/更新)。
-- EVENT_EFFECT_CHANGEDのGAINED、および初期スキャンの両方から呼ばれる共通処理。
--
-- v1.4.9で追加: beginTimeを受け取り、endTimeとの差からduration(効果の
-- 全長)を算出してキャッシュする。UI側の残り時間バー(下部の薄いバー)を
-- 「remaining / duration」で描画するために必要(beginTimeまたはendTimeが
-- 無効/取得できない場合はduration=nilとし、バーは常時満タン表示になる)。
local function UpsertTargetEffect(kind, abilityId, buffName, statusEffectType, beginTime, endTime, stackCount)
    -- APIの更新が1ティック遅れて「終了時刻は過ぎているのにまだ返ってくる」
    -- 端境期のデータは、消える直前に一瞬古い表示へ戻るのを防ぐため除外する。
    local isStaleExpired = type(endTime) == "number" and endTime > 0
        and (endTime - GetGameTimeSeconds()) <= 0
    if isStaleExpired then
        targetEffects[abilityId] = nil
        return
    end

    local isImportant, displayName = EvaluateEffect(kind, abilityId, buffName, statusEffectType)

    local duration = nil
    if type(beginTime) == "number" and type(endTime) == "number" and endTime > beginTime then
        duration = endTime - beginTime
    end

    -- v1.4.14で追加: 検知方式が「全表示」の場合、重要でない効果も
    -- 背景バフ(食事バフ・マウント速度等)でない限り表示対象にする。
    -- 重要と判定された効果(CC/Major-Minor/手動登録)は、全表示モードでも
    -- 通常モードでも、背景バフ判定に関わらず必ず表示する(見逃し防止)。
    local matters
    if isImportant then
        matters = true
    elseif PTI.sv.detectionMode == "all" then
        matters = not IsBackgroundBuff(duration)
    else
        matters = false
    end

    if not matters then
        targetEffects[abilityId] = nil
        return
    end

    targetEffects[abilityId] = {
        kind = kind,
        name = displayName,
        stackCount = stackCount,
        endTime = (type(endTime) == "number" and endTime > 0) and endTime or nil,
        duration = duration,
        -- 分類は手動登録時の表示名(displayName)ではなく、ゲーム側の
        -- 実際の効果名(buffName)で判定する(表示名だとキーワードが
        -- 含まれず「その他」に落ちてしまうため)。優先順位ルールは
        -- 全表示モードでも自動検知モードと完全に同じものを使う。
        categoryRank = GetCategoryRank(kind, buffName, statusEffectType),
    }
end

-- ターゲットを変更した直後の「初期スキャン」。
-- イベント駆動だけでは、ターゲットした時点で既に付与されている効果を
-- 拾えない(イベントは変化にしか発火しないため)ので、GetUnitBuffInfoで
-- 現在の全バフを1回だけ読み、targetEffectsを作り直す。
local function RescanCurrentTargetEffects()
    ZO_ClearTable(targetEffects)
    if not IsValidEnemyTarget() then
        DebugTrace("①対象取得: reticleoverが無効(NPC/オブジェクト/対象なし) → スキャンしない")
        return
    end

    local targetLabel = GetUnitName("reticleover") or "?"
    local numBuffs = GetNumBuffs("reticleover")
    DebugTrace("①対象取得: %s をプレイヤーとして確認 → 初期スキャン開始(全%d件の効果)", targetLabel, numBuffs)

    for i = 1, numBuffs do
        local buffName, startTime, endTime, buffSlot, stackCount, iconFile,
              buffType, effectType, abilityType, statusEffectType, abilityId,
              canClickOff = GetUnitBuffInfo("reticleover", i)

        if type(abilityId) == "number" and buffName and buffName ~= "" then
            local kind = (effectType == BUFF_EFFECT_TYPE_DEBUFF) and "debuff" or "buff"
            UpsertTargetEffect(kind, abilityId, buffName, statusEffectType, startTime, endTime, stackCount)
        end
    end

    DebugTrace("初期スキャン完了 → 重要と判定されたのは%d件(この後はイベント駆動で差分更新)", CountTable(targetEffects))
end

-- targetEffectsから、UI描画用のbuff配列/debuff配列を組み立てる。
local function BuildEntryArrays()
    local buffEntries, debuffEntries = {}, {}
    for abilityId, e in pairs(targetEffects) do
        local entry = {
            abilityId = abilityId,
            name = e.name,
            stackCount = e.stackCount,
            endTime = e.endTime,
            duration = e.duration,
            categoryRank = e.categoryRank,
        }
        if e.kind == "debuff" then
            table.insert(debuffEntries, entry)
        else
            table.insert(buffEntries, entry)
        end
    end
    return buffEntries, debuffEntries
end

-- 表示順のルール:
--   1. 残り時間がURGENT_REMAINING_THRESHOLD秒以下の「緊急」枠は、カテゴリに
--      関わらず最優先で上位に来る。緊急枠同士は残り時間が短い順。
--   2. 緊急枠でないものは、カテゴリ順位(categoryRank、小さいほど上位)の順。
--   3. 同じカテゴリ内では、残り時間が短いものほど先。残り時間不明
--      (永続等)は一番後ろに回す。
local function SortEntries(entries)
    local now = GetGameTimeSeconds()
    table.sort(entries, function(a, b)
        local ra = a.endTime and (a.endTime - now) or math.huge
        local rb = b.endTime and (b.endTime - now) or math.huge
        local aUrgent = ra <= URGENT_REMAINING_THRESHOLD
        local bUrgent = rb <= URGENT_REMAINING_THRESHOLD

        if aUrgent ~= bUrgent then
            return aUrgent
        end
        if aUrgent then
            -- 緊急枠同士: 残り時間が短い順
            return ra < rb
        end
        -- 通常枠: カテゴリ順位 → 残り時間の順
        local rankA, rankB = a.categoryRank or math.huge, b.categoryRank or math.huge
        if rankA ~= rankB then
            return rankA < rankB
        end
        return ra < rb
    end)
end

-- 「自動検知OFF」かつ「手動登録も0件」の場合だけ表示する案内行。
-- 自動検知ONの状態は、今その瞬間に該当する効果が無いだけの正常な状態なので
-- ヒントは出さない(常時ヒントが出ているとかえって邪魔になるため)。
local function HintEntry(kind)
    local label = (kind == "debuff") and "DEBUFF" or "BUFF"
    return { isHint = true, name = string.format("(%s: 自動検知OFF・登録なし。設定で有効にしてください)", label) }
end

local function RenderEntries(key, entries)
    local sv = (key == "buff") and PTI.sv.buffUI or PTI.sv.debuffUI
    local maxRows = sv.maxRows or 6
    local now = GetGameTimeSeconds()
    local index = 0

    for _, entry in ipairs(entries) do
        if index >= maxRows then break end
        index = index + 1
        local row = PTI.UI.AcquireRow(key, index)

        if entry.isHint then
            row.nameLabel:SetFont(PTI.UI.RowFont(key))
            row.nameLabel:SetColor(0.55, 0.57, 0.6, 1)
            row.nameLabel:SetText(entry.name)
            row.timeLabel:SetFont(PTI.UI.RowFont(key))
            row.timeLabel:SetText("")
            PTI.UI.SetRowBar(row, nil) -- 案内行には残り時間バーを出さない
        else
            local remaining = entry.endTime and (entry.endTime - now) or nil
            local displaySeconds = remaining and zo_ceil(remaining) or nil
            local tier = PTI.UI.GetImportantTier(key, displaySeconds)
            local font = PTI.UI.BuildTierFont(key, tier.sizeDelta, tier.outline)

            local displayName = tier.prefix .. entry.name
            if type(entry.stackCount) == "number" and entry.stackCount > 1 then
                displayName = string.format("%s x%d", displayName, entry.stackCount)
            end

            row.nameLabel:SetFont(font)
            row.nameLabel:SetText(displayName)
            row.nameLabel:SetColor(tier.color[1], tier.color[2], tier.color[3], tier.color[4])

            row.timeLabel:SetFont(font)
            row.timeLabel:SetColor(tier.color[1], tier.color[2], tier.color[3], tier.color[4])
            row.timeLabel:SetText(displaySeconds and (displaySeconds .. "s") or "")

            -- v1.4.9で追加: 下部の残り時間バー。durationが分かる効果は
            -- 「remaining / duration」の比率で減っていく。durationが
            -- 不明(永続効果、または初回付与時にbeginTimeが取れなかった等)の
            -- 場合は満タンのまま固定表示にする(数字が消える寸前まで見た目上
            -- 減っていく効果は、正しい全長が分かる時だけ出す)。
            local percent = 1
            if remaining and entry.duration and entry.duration > 0 then
                percent = remaining / entry.duration
            end
            PTI.UI.SetRowBar(row, percent, tier.color)
        end
    end

    PTI.UI.ReleaseUnusedRows(key, index + 1)
    return index
end

--------------------------------------------------------------------------
-- プレビューモード(sv.previewMode)用のダミーデータ
-- 設定画面の「プレビュー表示」をONにすると、実際のターゲットが無くても
-- UI①・UI②の位置・大きさ・強調色の見え方を確認できる。8秒周期でティア
-- (色)が一巡するサンプル行を出す。
--------------------------------------------------------------------------
local function BuildPreviewEntries(nameA, nameB, nameC)
    local now = GetGameTimeSeconds()
    local function fakeRemaining(phaseOffset)
        return 8 - ((now + phaseOffset) % 8)
    end
    return {
        { name = nameA, stackCount = nil, endTime = now + fakeRemaining(0), duration = 8 },
        { name = nameB, stackCount = 2,   endTime = now + fakeRemaining(3), duration = 8 },
        { name = nameC, stackCount = nil, endTime = now + fakeRemaining(6), duration = 8 },
    }
end

--------------------------------------------------------------------------
-- ③ 表示安定性(ホールド表示用キャッシュ)
--
-- reticleoverが一瞬外れただけ(あるいは一瞬だけNPCに重なった等)で
-- パネルが消えたり中身が空になったりしないよう、有効なプレイヤーを
-- 最後に見ていた時点のスナップショットをsv.holdDuration秒だけ保持する。
-- targetEffects自体はターゲット変更のたびに作り直されるため、この
-- スナップショット(cachedBuffEntries/cachedDebuffEntries)を別に
-- 持っておくことで、保持中も直前の表示内容が維持される。
--------------------------------------------------------------------------
local lastTargetSeenTime = nil   -- 有効なプレイヤーが最後に対象だったゲーム内時刻
local cachedTargetName = "---"
local cachedBuffEntries = {}
local cachedDebuffEntries = {}

-- v1.4.32で追加: 非戦闘中はUI①②③を非表示にするための戦闘状態追跡。
-- 検知(targetEffects等)には一切関与せず、表示のON/OFFにのみ使う。
local isInCombat = false

-- ⑥UI描画のデバッグログ用。OnUpdateは0.1秒ごとに走るため、内容が変わって
-- いない限りログを出さないようにして、デバッグON中でもチャットが埋まり
-- すぎないようにする。
local lastRenderDebugSignature = nil

local function OnUpdate()
    if not PTI.sv.enabled then
        PTI.UI.SetWindowVisible("buff")
        PTI.UI.SetWindowVisible("debuff")
        return
    end

    -- v1.4.32で追加: 非戦闘中はUI①②③を非表示にする(既定ON)。
    -- BuildEntryArrays/RenderEntriesまで丸ごとスキップするため、非戦闘中の
    -- 負荷軽減にもなる。ただしtargetEffectsの更新(RescanCurrentTargetEffects/
    -- OnReticleEffectChanged)はこことは無関係にバックグラウンドで動き続ける
    -- ため、検知そのものには一切影響しない。
    if PTI.sv.combatOnly and not isInCombat and not PTI.sv.previewMode then
        PTI.UI.SetWindowVisible("buff")
        PTI.UI.SetWindowVisible("debuff")
        return
    end

    local buffWin = PTI.UI.GetWindow("buff")
    local debuffWin = PTI.UI.GetWindow("debuff")

    if PTI.sv.previewMode then
        buffWin.titleLabel:SetText("BUFF (プレビュー)")
        debuffWin.titleLabel:SetText("DEBUFF (プレビュー)")
        RenderEntries("buff", BuildPreviewEntries("勇気の炎", "集中攻撃", "不屈の意志"))
        RenderEntries("debuff", BuildPreviewEntries("よろめき", "出血", "束縛"))
        PTI.UI.SetWindowVisible("buff")
        PTI.UI.SetWindowVisible("debuff")
        return
    end

    local now = GetGameTimeSeconds()
    -- ①プレイヤー判定: NPC・モンスター・衛兵・オブジェクトはここで弾かれる
    -- (検知・キャッシュ構築側と完全に同じ判定、v1.4.37でも変更なし)
    local hasTarget = IsValidEnemyTarget()

    -- v1.4.37で追加: 「敵プレイヤーのみ表示」は、あくまで①②の表示可否だけを
    -- 決める独立フィルタ。hasTarget(検知パイプライン用の判定)そのものは
    -- 書き換えず、表示用の変数(displayTarget)だけに反映する。
    local displayTarget = hasTarget and PassesEnemyOnlyDisplayFilter()

    if displayTarget then
        lastTargetSeenTime = now

        -- v1.4.3で修正: キャラクター名ではなく、オンラインID(@表示名)を表示する。
        -- ターゲットダミー等、表示名を持たないユニットの場合は空文字が返るため、
        -- その場合だけキャラクター名にフォールバックする。
        local targetName = GetUnitDisplayName("reticleover")
        if not targetName or targetName == "" then
            targetName = GetUnitName("reticleover")
        end
        cachedTargetName = targetName

        cachedBuffEntries, cachedDebuffEntries = BuildEntryArrays()
        SortEntries(cachedBuffEntries)
        SortEntries(cachedDebuffEntries)
    end

    local holdSec = PTI.sv.holdDuration or 1.0
    local withinHold = (not displayTarget) and lastTargetSeenTime and ((now - lastTargetSeenTime) <= holdSec)
    local shouldKeepShowing = displayTarget or withinHold

    if not shouldKeepShowing then
        -- 保持時間も過ぎたので、次にターゲットし直したときに古い情報が
        -- 一瞬だけ表示されてしまわないようキャッシュを空にする。
        cachedBuffEntries, cachedDebuffEntries, cachedTargetName = {}, {}, "---"
        lastTargetSeenTime = nil
    end

    buffWin.titleLabel:SetText((cachedTargetName ~= "---") and ("BUFF: " .. cachedTargetName) or "BUFF")
    debuffWin.titleLabel:SetText((cachedTargetName ~= "---") and ("DEBUFF: " .. cachedTargetName) or "DEBUFF")

    local buffCount = RenderEntries("buff", cachedBuffEntries)
    if buffCount == 0 and PTI.sv.detectionMode ~= "all" and not PTI.sv.autoDetect.enabled and PTI.Target.IsWatchListEmpty("buff") then
        RenderEntries("buff", { HintEntry("buff") })
    end

    local debuffCount = RenderEntries("debuff", cachedDebuffEntries)
    if debuffCount == 0 and PTI.sv.detectionMode ~= "all" and not PTI.sv.autoDetect.enabled and PTI.Target.IsWatchListEmpty("debuff") then
        RenderEntries("debuff", { HintEntry("debuff") })
    end

    -- ⑥UI描画: 表示データ(cachedBuffEntries/cachedDebuffEntries)が実際に
    -- 何件UIへ渡ったかを確認する。内容が変わった時だけ出力する。
    if PTI.sv.debug and PTI.sv.debug.pipelineTrace then
        local sig = string.format("%s|%d|%d|%s|%s", cachedTargetName, buffCount, debuffCount,
            PTI.sv.enabled and "enabled" or "disabled", PTI.sv.buffUI.enabled ~= false and PTI.sv.debuffUI.enabled ~= false and "win_on" or "win_off")
        if sig ~= lastRenderDebugSignature then
            lastRenderDebugSignature = sig
            DebugTrace("⑥UI描画: 対象=%s → UI①(buff)=%d件 / UI②(debuff)=%d件 をパネルに反映(アドオン有効=%s)",
                cachedTargetName, buffCount, debuffCount, tostring(PTI.sv.enabled))
        end
    end

    -- パネルは中身の有無に関わらず、有効になっている限り常に表示する
    PTI.UI.SetWindowVisible("buff")
    PTI.UI.SetWindowVisible("debuff")
end

-- 設定変更直後など、次のティックを待たずに即座に再評価したい場合に使う。
-- 自動検知キーワードや手動登録リストの変更は、現在ターゲット中の
-- 効果の重要度判定を変えうるため、表示更新の前に必ず初期スキャンを
-- やり直して targetEffects を最新の判定基準で作り直す。
function PTI.Target.ForceRefresh()
    RescanCurrentTargetEffects()
    OnUpdate()
end

function PTI.Target.RefreshFonts(key)
    PTI.UI.RefreshRowLayout(key)
end

--------------------------------------------------------------------------
-- ② EVENT_EFFECT_CHANGED によるイベント駆動の差分更新
--
-- reticleoverにフィルタしたEVENT_EFFECT_CHANGEDを常時購読し、対象の
-- 効果が付与・更新・消失するたびにtargetEffectsを直接更新する。
-- GAINEDは初回付与時だけでなく、残り時間・スタック数が変わった際の
-- 「更新」でも再度飛んでくるため、UpsertTargetEffectを呼ぶだけで
-- 開始・更新の両方に対応できる。
--------------------------------------------------------------------------
local seenTargetAbilityIds = {}
PTI.Target.seenTargetAbilityIds = seenTargetAbilityIds -- 学習モードON時にリセットできるよう公開

-- 学習モードで見つかった登録候補。バフ/デバフでリストを分けておくことで、
-- LAM2の設定パネルからもそれぞれ独立して選択・登録できるようにする。
local pendingCandidates = {
    buff = {},   -- 配列: { {id=, name=}, ... }
    debuff = {},
}
local pendingIndexById = {
    buff = {},   -- abilityId -> pendingCandidates[kind]内のindex
    debuff = {},
}

local function RefreshPendingUI()
    if PTI.Settings and PTI.Settings.RefreshWatchPendingDropdowns then
        PTI.Settings.RefreshWatchPendingDropdowns()
    end
end

-- LAM2のドロップダウン用: 表示ラベルの配列とAbilityIdの配列を返す
function PTI.Target.GetPendingChoices(kind)
    local labels, values = {}, {}
    for _, entry in ipairs(pendingCandidates[kind]) do
        table.insert(labels, string.format("%s (%d)", entry.name, entry.id))
        table.insert(values, entry.id)
    end
    return labels, values
end

-- 候補リストからAbilityIdを指定して手動登録する(名前の入力は不要)
function PTI.Target.RegisterPendingById(kind, abilityId)
    abilityId = tonumber(abilityId)
    local index = abilityId and pendingIndexById[kind][abilityId]
    if not index then return false end
    local entry = pendingCandidates[kind][index]

    PTI.Target.AddWatch(kind, entry.id, entry.name)

    table.remove(pendingCandidates[kind], index)
    pendingIndexById[kind][abilityId] = nil
    -- 削除した要素より後ろのインデックスを詰め直す
    for i = index, #pendingCandidates[kind] do
        pendingIndexById[kind][pendingCandidates[kind][i].id] = i
    end
    RefreshPendingUI()
    return true, entry.name
end

function PTI.Target.ClearPendingCandidates()
    ZO_ClearTable(pendingCandidates.buff)
    ZO_ClearTable(pendingCandidates.debuff)
    ZO_ClearTable(pendingIndexById.buff)
    ZO_ClearTable(pendingIndexById.debuff)
    RefreshPendingUI()
end

-- reticleoverの効果変化を一手に処理する(①のキャッシュ更新と、②の学習モード
-- ログ出力を兼ねる)。プレイヤー以外(NPC等)が対象の場合は、そもそも
-- targetEffectsを汚染しないよう即座に無視する。
local function OnReticleEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag,
    beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType,
    statusEffectType, unitName, unitId, abilityId, sourceType)

    if unitTag ~= "reticleover" then return end

    -- ②対象取得: このイベントはreticleoverに乗っている「何か」の効果変化なら
    -- NPC・モンスターであっても飛んでくる。プレイヤーでなければここで捨てる。
    if not IsValidEnemyTarget() then
        DebugTrace("②イベント発火: %s (id=%s) → reticleover対象がプレイヤーではないため無視",
            tostring(effectName), tostring(abilityId))
        return
    end

    local kind = (effectType == BUFF_EFFECT_TYPE_DEBUFF) and "debuff" or "buff"

    if changeType == EFFECT_RESULT_FADED then
        targetEffects[abilityId] = nil
        DebugTrace("③④⑤ [%s] %s (id=%s) → FADED、表示データから削除 (残り%d件)",
            kind, tostring(effectName), tostring(abilityId), CountTable(targetEffects))
    else
        -- GAINED(新規付与・更新のどちらでも飛んでくる)
        local existedBefore = targetEffects[abilityId] ~= nil
        UpsertTargetEffect(kind, abilityId, effectName or "", statusEffectType, beginTime, endTime, stackCount)
        local existsAfter = targetEffects[abilityId] ~= nil

        local judgement
        if existsAfter then
            judgement = existedBefore and "更新(表示データに反映済み)" or "重要と判定→表示データに追加"
        else
            judgement = "重要と判定されず(自動検知OFF or キーワード/CC種別に不一致、手動登録もなし)"
        end
        DebugTrace("③④⑤ [%s] %s (id=%s) statusEffectType=%s → %s (表示データ=%d件)",
            kind, tostring(effectName), tostring(abilityId), tostring(statusEffectType), judgement, CountTable(targetEffects))
    end

    -- 学習モード(/pti learn target)がONのときだけ、AbilityId特定用の
    -- ログと登録候補リストへの追加を行う。表示自体には影響しない。
    if PTI.sv.procs.debugLearnModeTarget and changeType == EFFECT_RESULT_GAINED
        and not seenTargetAbilityIds[abilityId] then
        seenTargetAbilityIds[abilityId] = true

        local alreadyAuto = PTI.sv.autoDetect.enabled
            and IsAutoImportant(kind, effectName or "", statusEffectType, GetAutoDetectKeywords())

        d(string.format("|c55CCFF[PTI Learn:Target]|r [%s] %s / abilityId=%s / statusEffectType=%s / duration=%.1fs / 自動検知=%s",
            kind, effectName or "?", tostring(abilityId), tostring(statusEffectType),
            (endTime or 0) - (beginTime or 0), alreadyAuto and "対象(登録不要)" or "対象外"))

        if not alreadyAuto then
            d(string.format("|c55CCFF[PTI Learn:Target]|r 追加で表示したい場合: /pti watch %s use %s (または設定パネルの候補から選択)",
                kind, tostring(abilityId)))

            if type(abilityId) == "number" and not pendingIndexById[kind][abilityId] then
                table.insert(pendingCandidates[kind], { id = abilityId, name = effectName or ("ability " .. tostring(abilityId)) })
                pendingIndexById[kind][abilityId] = #pendingCandidates[kind]
                RefreshPendingUI()
            end
        end
    end
end

-- ①ターゲット変更時の再判定。
-- reticleoverが変わるたびに発火するので、ここでプレイヤー判定と
-- targetEffectsの初期スキャンをやり直す(イベント駆動の効果検知は
-- 「変化」にしか反応できないため、切り替わった瞬間の状態はここで
-- 明示的に読み直す必要がある)。
--
-- v1.4.31で追加: 即時スキャンに加えて、150ms後に保険のスキャンを
-- 1回だけ追加でスケジュールする(取得直後のデータ未同期対策)。
-- targetGenerationを進めておき、遅延スキャンが発火する時点で対象が
-- 既に変わっていれば(=世代番号が一致しなければ)何もしない。
-- タイマーは単発(zo_callLater)で、ループや毎フレーム処理は発生しない。
local function OnReticleTargetChanged()
    targetGeneration = targetGeneration + 1
    local myGeneration = targetGeneration
    RescanCurrentTargetEffects()
    zo_callLater(function()
        if myGeneration ~= targetGeneration then return end
        -- zo_callLaterの内部実装はコールバック側でエラーが起きた場合に
        -- タイマーが解除されず暴走する既知の仕様があるため、pcallで保護する。
        local ok, err = pcall(RescanCurrentTargetEffects)
        if not ok then
            d("|cFF5555[PvPTargetInfo]|r 保険スキャンでエラー: " .. tostring(err))
        end
    end, RESCAN_RETRY_DELAY_MS)

    -- v1.4.34で追加: 400ms後の2段目保険スキャン。
    -- 150ms版と全く同じ構造(同じmyGeneration/targetGenerationの世代チェック、
    -- 同じpcall保護)で、混雑時に150msでもまだ同期していなかった場合だけ
    -- もう一度だけ拾う。単発タイマーで、ループ・常時ポーリングではない。
    zo_callLater(function()
        if myGeneration ~= targetGeneration then return end
        local ok, err = pcall(RescanCurrentTargetEffects)
        if not ok then
            d("|cFF5555[PvPTargetInfo]|r 保険スキャン(2段目)でエラー: " .. tostring(err))
        end
    end, RESCAN_RETRY2_DELAY_MS)
end

function PTI.Target.Initialize()
    -- v1.4.32で追加: 非戦闘中はUI①②③を非表示にする設定用に、プレイヤーの
    -- 戦闘状態を追跡する。検知ロジックとは無関係で、表示のON/OFFにのみ使う。
    local function OnCombatStateChanged(eventCode, inCombat)
        isInCombat = inCombat
        if PTI.UI then PTI.UI.hiddenByCombat = PTI.sv.combatOnly and not isInCombat end
        if PTI.UI and PTI.UI.RefreshVisibility then PTI.UI.RefreshVisibility() end
    end
    isInCombat = IsUnitInCombat and IsUnitInCombat("player") or false
    if PTI.UI then PTI.UI.hiddenByCombat = PTI.sv.combatOnly and not isInCombat end
    EVENT_MANAGER:RegisterForEvent(PTI.name .. "CombatState", EVENT_PLAYER_COMBAT_STATE, OnCombatStateChanged)

    -- v1.4.30で修正: SeedReworkWatchEntries()内で万一エラーが起きた場合、
    -- 従来はここでInitialize()全体が止まり、この後に続くEVENT_EFFECT_CHANGED /
    -- EVENT_RETICLE_TARGET_CHANGED / OnUpdateの登録が一切行われず、
    -- ①②(敵バフ/デバフ)自体が丸ごと動かなくなる恐れがあった。
    -- pcallで囲み、エラーが起きても必ず後続の初期化(イベント登録)が
    -- 実行されるようにした(切り分けやすいようエラー内容はチャットに出す)。
    local seedOk, seedErr = pcall(SeedReworkWatchEntries)
    if not seedOk then
        d("|cFF5555[PvPTargetInfo]|r クラスリワーク自動登録(SeedReworkWatchEntries)でエラー: " .. tostring(seedErr))
    end

    -- 状態異常(CC)の定数が実際にいくつ解決できたかを起動時に1回だけ報告する。
    -- ここが0件だと「Major/Minor」以外のCC系デバフの自動検知が丸ごと
    -- 機能しなくなるため、実戦ログでチャットが埋まる心配がない起動時のみ、
    -- デバッグ設定に関わらず常に表示する(検知不良の切り分けに直結するため)。
    local resolvedCount = CountTable(CC_STATUS_EFFECT_TYPES)
    if resolvedCount < #CC_STATUS_EFFECT_TYPE_NAMES then
        d(string.format(
            "|cFFAA00[PvPTargetInfo]|r 状態異常(CC)の自動検知: %d/%d 種類のみ認識できました(未解決: %s)。これらはMajor/Minorキーワードにも一致しない限り自動検知の対象外になります。",
            resolvedCount, #CC_STATUS_EFFECT_TYPE_NAMES, table.concat(ccUnresolvedNames, ", ")))
    end

    EVENT_MANAGER:RegisterForUpdate(UPDATE_NAME, UPDATE_INTERVAL_MS, OnUpdate)

    local effectEventName = PTI.name .. "TargetEffect"
    EVENT_MANAGER:RegisterForEvent(effectEventName, EVENT_EFFECT_CHANGED, OnReticleEffectChanged)
    EVENT_MANAGER:AddFilterForEvent(effectEventName, EVENT_EFFECT_CHANGED,
        REGISTER_FILTER_UNIT_TAG, "reticleover")

    local targetChangedEventName = PTI.name .. "ReticleTargetChanged"
    EVENT_MANAGER:RegisterForEvent(targetChangedEventName, EVENT_RETICLE_TARGET_CHANGED, OnReticleTargetChanged)

    -- 起動直後、既にreticleover上にプレイヤーが乗っている状態(UIリロード直後等)
    -- にも対応できるよう、初期化時にも一度スキャンしておく。
    RescanCurrentTargetEffects()
end
