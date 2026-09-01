CombatFPSBooster = CombatFPSBooster or {}
CombatFPSBooster.L = CombatFPSBooster.L or {}

local function IsJapanese()
    local lang = GetCVar("language.2")
    if not lang or lang == "" then lang = GetCVar("Language.lang") end
    if (not lang or lang == "") and GetLanguage then lang = GetLanguage() end
    if lang then
        lang = string.lower(lang)
        return lang == "ja" or string.sub(lang, 1, 2) == "ja"
    end
    return false
end

if IsJapanese() then
    CombatFPSBooster.L.TITLE          = "Tetsu's Combat FPS Booster"
    CombatFPSBooster.L.HIDE_INSTANCE   = "ダンジョン中ずっとHUDを非表示"
    CombatFPSBooster.L.HIDE_INSTANCE_TT= "オンにすると、グループダンジョン、試練、アリーナ、無限アーカイブではコンパスとクエスト追跡を常に非表示にします。経験値・戦利品・告知は戦闘中のみ。デルヴと公共ダンジョンは対象外です。"
    CombatFPSBooster.L.HIDE_COMPASS   = "戦闘中にコンパスを非表示"
    CombatFPSBooster.L.HIDE_COMPASS_TT= "戦闘中に上部コンパスを完全に非表示にしてCPU負荷を軽減します。"
    CombatFPSBooster.L.HIDE_QUESTS    = "戦闘中にクエストを非表示"
    CombatFPSBooster.L.HIDE_QUESTS_TT = "戦闘中に画面右側のクエスト追跡を非表示にします。"
    CombatFPSBooster.L.HIDE_ALERTS    = "戦闘中に通知を非表示"
    CombatFPSBooster.L.HIDE_ALERTS_TT = "経験値・ゴールド・戦利品は戦闘中のみ非表示。ダンジョン全体モードでは戦闘の合間に出したままです。"
    CombatFPSBooster.L.FILTER_MASTER    = "ダンジョンでは必要なアドオンだけ"
    CombatFPSBooster.L.FILTER_MASTER_TT = "キャラクターごとに設定。グループダンジョン、試練、アリーナ、無限アーカイブ入場時に現在の構成を保存し、チェックしたアドオンだけ残してUIを再読み込みします。退出時に元へ戻します。デルヴと公共ダンジョンは対象外です。"
    CombatFPSBooster.L.FILTER_ITEM_TT   = "オン＝ダンジョンで残す。オフ＝ダンジョンで無効。上のオプションがオフのときは変更できません。"
    CombatFPSBooster.L.FILTER_EMPTY_WARN= "Combat FPS Booster: フィルターはオンですが、必要なアドオンがありません。変更しませんでした。"
    CombatFPSBooster.L.FILTER_APPLY     = "Combat FPS Booster: ダンジョン用セットを適用し、UIを再読み込みします。"
    CombatFPSBooster.L.FILTER_RESTORE   = "Combat FPS Booster: フィールド用セットを復元し、UIを再読み込みします。"
    CombatFPSBooster.L.FILTER_NOAPI     = "Combat FPS Booster: アドオン状態を変更できませんでした。再読み込みはしません。"
    CombatFPSBooster.L.FILTER_SECTION   = "ダンジョンのアドオン"
    CombatFPSBooster.L.FILTER_SECTION_TT= "ダンジョンや試練で有効のままにする導入済みアドオン。"
    CombatFPSBooster.L.PRESET_SELECT    = "プリセット"
    CombatFPSBooster.L.PRESET_SELECT_TT = "保存したアドオン構成。プリセットはアカウント共通です。"
    CombatFPSBooster.L.PRESET_NAME      = "プリセット名"
    CombatFPSBooster.L.PRESET_NAME_TT   = "保存する名前。同じ名前は上書きします。"
    CombatFPSBooster.L.PRESET_SAVE      = "プリセットを保存"
    CombatFPSBooster.L.PRESET_SAVE_BTN  = "保存"
    CombatFPSBooster.L.PRESET_SAVE_TT   = "現在のオン/オフをこの名前で保存します。"
    CombatFPSBooster.L.PRESET_DELETE    = "プリセットを削除"
    CombatFPSBooster.L.PRESET_DELETE_BTN= "削除"
    CombatFPSBooster.L.PRESET_DELETE_TT = "選択中のプリセットを削除します。最後の1つは削除できません。"
    CombatFPSBooster.L.PRESET_DIVIDER   = "──────── アドオン ────────"
    CombatFPSBooster.L.PRESET_SAVED     = "Combat FPS Booster: プリセットを保存しました: "
    CombatFPSBooster.L.PRESET_DELETED   = "Combat FPS Booster: プリセットを削除しました: "
    CombatFPSBooster.L.PRESET_LAST      = "Combat FPS Booster: 最後のプリセットは削除できません。"
    CombatFPSBooster.L.PRESET_NOW       = "Combat FPS Booster: 現在のプリセット: "
    CombatFPSBooster.L.HIDE_CSA       = "戦闘中にゲーム告知を非表示"
    CombatFPSBooster.L.HIDE_CSA_TT    = "画面中央の大きな告知は戦闘中のみ非表示。ダンジョン全体では隠しません。"

end
