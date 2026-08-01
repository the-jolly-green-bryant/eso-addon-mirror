FCOCO = FCOCO or  {}
local FCOCompanion = FCOCO
if not FCOCompanion.isCompanionUnlocked then return end
------------------------------------------------------------------------------------------------------------------------

function FCOCompanion.UpdateCompass()
    local settings = FCOCompanion.settingsVars.settings
    if not settings then return end

    --Hide/Show the companion's pin at the compass
    if settings.disableCompanionAtCompass == true then
        --Set the pin's alpha value to 0 so it is invisible
        COMPASS.container:SetAlphaDropoffBehavior(MAP_PIN_TYPE_ACTIVE_COMPANION, 0, 0, 0, 0)
    else
        COMPASS.container:SetAlphaDropoffBehavior(MAP_PIN_TYPE_ACTIVE_COMPANION, 1, 1, 1, 1)
    end

end