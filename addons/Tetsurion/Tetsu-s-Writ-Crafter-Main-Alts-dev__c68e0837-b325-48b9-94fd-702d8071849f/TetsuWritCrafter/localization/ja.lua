TetsuWritCrafter = TetsuWritCrafter or {}

local function IsJapanese()
    local lang = GetCVar("language.2")
    if not lang or lang == "" then lang = GetCVar("Language.lang") end
    if (not lang or lang == "") and GetLanguage then lang = GetLanguage() end
    if lang then
        lang = string.lower(lang)
        return lang == "ja" or lang == "jp" or string.sub(lang, 1, 2) == "ja"
    end
    return false
end

if IsJapanese() then
    local L = TetsuWritCrafter.L
    L.TITLE                   = "|cFFD700Tetsu's|r Writ Crafter"
    L.ALTS_SECTION_LABEL      = "デイリークラフト用キャラクター"
    L.ALTS_SECTION_TT         = "デイリークラフトに参加するキャラクターを有効/無効にします。"
    L.CHAR_ENABLED_TT         = "<<1>> の事前作成を有効にする。"
    
    L.KEYBIND_CRAFT_ALL       = "|c00FF00[R3]|r 全員分を作成 (<<1>> 個)"
    L.CONFIRM_TITLE           = "デイリークラフト一括作成"
    L.CONFIRM_PROMPT          = "すべてのアクティブなキャラクター用に <<1>> 個作成しますか？"
    
    L.PROGRESS_CRAFTING       = "デイリークラフト作成中..."
    L.PROGRESS_BANK_DEPOSIT   = "銀行：アイテムと報酬を預入中..."
    L.PROGRESS_BANK_WITHDRAW  = "銀行：依頼アイテムを引き出し中..."
    L.PROGRESS_STATUS         = "処理中: <<1>> / <<2>>"
    
    L.ERR_NOT_ENOUGH_BANK     = "銀行の空きスロットが不足しています！必要: <<1>>、空き: <<2>>。"
    L.ERR_BAG_FULL            = "インベントリの空きが不足しています！必要: <<1>>、空き: <<2>>。"
    L.ERR_NOT_ENOUGH_MATS     = "クラフト材料が不足しています！"
    
    L.SYNC_STATUS             = "同期完了: |c00FF00<<1>> / <<2>>|r。ログインが必要: |cFFFF00<<3>>|r"
    L.READY_BRIEFING          = "準備完了！パターン: |cFFD700<<1>>|r。作成対象サブキャラ: |cFFD700<<2>>|r。"
end