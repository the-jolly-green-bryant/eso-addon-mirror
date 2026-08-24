CombatFPSBooster = CombatFPSBooster or {}
local L = CombatFPSBooster.L or {}

local clientLang = GetCVar("Language.lang")
if clientLang == "ja" then
    L.TITLE           = "Combat FPS Booster"
    L.HIDE_COMPASS    = "戦闘中にコンパスを非表示"
    L.HIDE_COMPASS_TT = "戦闘中にコンパスバーを非表示にし、CPUの負荷を軽減します。"
    L.HIDE_QUESTS     = "戦闘中にクエスト追跡を非表示"
    L.HIDE_QUESTS_TT  = "戦闘中に画面右側のアクティブクエスト表示を非表示にします。"
    L.HIDE_ALERTS     = "戦闘中に経験値/ゴールド通知を非表示"
    L.HIDE_ALERTS_TT  = "戦闘中の経験値、ゴールド、戦利品のポップアップ通知を非表示にしてカクつきを防ぎます。"
end

CombatFPSBooster.L = L