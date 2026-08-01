local HUD = Reforged.UI.HUD

function HUD.setLanguage(lang)
    if GetCVar("language.2") ~= lang then
        SetCVar("language.2", lang)
    else
        ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, "Você já está neste idioma.")
    end
end
