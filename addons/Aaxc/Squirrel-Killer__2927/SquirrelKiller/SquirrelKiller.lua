SquirrelKiller = {
    -- Main info
    name = "SquirrelKiller",
    version = "1.0.2",
    author = "@Aaxc",
    squirrel = "Squirrel",
    timer = 0,
    duration = 2
}

-------------------------------------------------------------------------------------------------
-- OnPlayerCombatState  --
-------------------------------------------------------------------------------------------------
function SquirrelKiller.CombatCallbacks(_, result, isError, aName, aGraphic, aActionSlotType, sName, sType, tName, tType, hitValue, pType, dType, log, sUnitId, tUnitId, abilityId)
    -- Check kill event
    if (tName == SquirrelKiller.squirrel) then
        PlaySound(SOUNDS.CROWN_CRATES_GEM_ITEM)
        SquirrelKiller.ShowNotification(sName:sub(1, -4) .. " killed a " .. SquirrelKiller.squirrel, GetAbilityIcon(abilityId), SquirrelKiller.duration)
    end

    SquirrelKiller.hide()
end

-------------------------------------------------------------------------------------------------
-- Show Notification  --
-------------------------------------------------------------------------------------------------
function SquirrelKiller.ShowNotification(label, icon, duration)
    SquirrelKillerWindowLabel:SetText(label)
    SquirrelKillerWindowIcon:SetTexture(icon)
    SquirrelKillerWindow:SetHidden(false)
    SquirrelKiller.timer = tonumber(GetTimeStamp())
    SquirrelKiller.duration = duration
end

-------------------------------------------------------------------------------------------------
-- Hide Notification  --
-------------------------------------------------------------------------------------------------
function SquirrelKiller.hide()
    local current = tonumber(GetTimeStamp())

    if current > (SquirrelKiller.timer + SquirrelKiller.duration) then
        SquirrelKillerWindow:SetHidden(true)
        SquirrelKiller.timer = 0
    end
end

-------------------------------------------------------------------------------------------------
-- General events and commands --
-------------------------------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(SquirrelKiller.name, EVENT_COMBAT_EVENT, SquirrelKiller.CombatCallbacks)
