HousingFPSBooster = HousingFPSBooster or {}
HousingFPSBooster.L = HousingFPSBooster.L or {}

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
    HousingFPSBooster.L.TITLE                = "Tetsu's Housing FPS Booster"
    HousingFPSBooster.L.ENABLE_BOOSTER       = "ハウジングブースターを有効化"
    HousingFPSBooster.L.ENABLE_BOOSTER_TT    = "住宅内のUI、コンパス、バーを最適化してFPSを向上させます。"
    HousingFPSBooster.L.HIDE_COMBAT_BARS     = "アクションバーとステータスを非表示"
    HousingFPSBooster.L.HIDE_COMBAT_BARS_TT  = "住宅内の非戦闘時にスキルバーとリソースバーを非表示にします。"
end