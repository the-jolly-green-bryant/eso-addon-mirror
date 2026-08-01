BobbysSigilTracker = {
    -- Main info
    name = "BobbysSigilTracker",
    version = "1.1.3",
    author = "@Aaxc",
    timer = 0,
    duration = 5,
    lang = {}
}

-------------------------------------------------------------------------------------------------
-- OnAddOnLoaded  --
-------------------------------------------------------------------------------------------------
function BobbysSigilTracker.OnAddOnLoaded(event, addonName)
    -- Check if correct addon load event
    if addonName ~= BobbysSigilTracker.name then
        return
    end

    -- Load language string
    local langCode = GetCVar('language.2')
    if langCode == "de" then
        BobbysSigilTracker.lang = BobbysSigilTracker.de
    elseif langCode == "fr" then
        BobbysSigilTracker.lang = BobbysSigilTracker.fr
    else
        BobbysSigilTracker.lang = BobbysSigilTracker.en
    end
end

-------------------------------------------------------------------------------------------------
-- OnPlayerCombatState  --
-------------------------------------------------------------------------------------------------
function BobbysSigilTracker.CombatCallbacks(_, result, isError, aName, aGraphic, aActionSlotType, sName, sType, tName, tType, hitValue, pType, dType, log, sUnitId, tUnitId, abilityId)
    BobbysSigilTracker.checkSigils(BobbysSigilTracker.MAsigils, abilityId, sName, aName, sType)
    BobbysSigilTracker.checkSigils(BobbysSigilTracker.BRPsigils, abilityId, sName, aName, sType)
    BobbysSigilTracker.checkSigils(BobbysSigilTracker.VAsigils, abilityId, sName, aName, sType)

    BobbysSigilTracker.hide()
end

-------------------------------------------------------------------------------------------------
-- Check sigil usages  --
-------------------------------------------------------------------------------------------------
function BobbysSigilTracker.checkSigils(abilities, abilityId, sName, aName, sType)
    for index, value in ipairs(abilities) do
        if (value == abilityId and sName ~= nil and sName ~= '' and (sType == COMBAT_UNIT_TYPE_PLAYER or sType == COMBAT_UNIT_TYPE_GROUP )) then
            PlaySound(SOUNDS.DUEL_START)
            BobbysSigilTracker.ShowNotification(sName:sub(1, -4) .. " " .. BobbysSigilTracker.lang.used .. " " .. aName, GetAbilityIcon(abilityId), 5)
        end
    end
end

-------------------------------------------------------------------------------------------------
-- Show Notification  --
-------------------------------------------------------------------------------------------------
function BobbysSigilTracker.ShowNotification(label, icon, duration)
    BobbysSigilTrackerWindowLabel:SetText(label)
    BobbysSigilTrackerWindowIcon:SetTexture(icon)
    BobbysSigilTrackerWindow:SetHidden(false)
    BobbysSigilTracker.timer = tonumber(GetTimeStamp())
    BobbysSigilTracker.duration = duration
end

-------------------------------------------------------------------------------------------------
-- Hide Notification  --
-------------------------------------------------------------------------------------------------
function BobbysSigilTracker.hide()
    local current = tonumber(GetTimeStamp())

    if current > (BobbysSigilTracker.timer + BobbysSigilTracker.duration) then
        BobbysSigilTrackerWindow:SetHidden(true)
        BobbysSigilTracker.timer = 0
    end
end

-------------------------------------------------------------------------------------------------
-- General events and commands --
-------------------------------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(BobbysSigilTracker.name, EVENT_COMBAT_EVENT, BobbysSigilTracker.CombatCallbacks)
EVENT_MANAGER:RegisterForEvent(BobbysSigilTracker.name, EVENT_ADD_ON_LOADED, BobbysSigilTracker.OnAddOnLoaded)
