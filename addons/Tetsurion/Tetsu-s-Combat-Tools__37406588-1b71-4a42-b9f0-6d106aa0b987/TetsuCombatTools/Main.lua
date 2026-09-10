local ADDON_NAME = "TetsuCombatTools"
TetsuCombatTools = TetsuCombatTools or {}
local T = TetsuCombatTools

local defaultAccountVars = {
    skillEnabled = true,
    skillSlots = 6,
    skillScale = 100,
    skillOffsetX = 0,
    skillOffsetY = 330,
    skillShow = "combat",
    skillHideAfter = 8,
    skillLightAttacks = false,
    skillShowGcd = true,
    skillShowWeave = true,
    statusEnabled = true,
    statusIcon = true,
    statusIconX = 0,
    statusIconY = 0,
    statusIconScale = 50,
    statusIconAlpha = 50,
    statusText = false,
    statusTextX = 0,
    statusTextY = 250,
    statusTextScale = 100,
    statusSound = true,
    statusSoundId = "duel",
    consEnabled = true,
    consOffsetX = 0,
    consOffsetY = 220,
    consScale = 100,
    consFoodWarn = 5,
    consPotWarn = 10,
    consPotCombat = false,
    consShowFood = true,
    consShowPot = true,
    consFoodSound = false,
    consPotSound = false,
    consEndSoundId = "alert",
    consMsgEnabled = false,
    consMsgFood = false,
    consMsgPot = false,
    consMsgX = 0,
    consMsgY = -200,
    consMsgScale = 100,
    timerEnabled = false,
    timerDungeon = true,
    timerTrial = true,
    timerArena = true,
    timerGoal = true,
    timerOffsetX = 0,
    timerOffsetY = -280,
    timerScale = 100,
}

local function OnAddOnLoaded(_, addonName)
    if addonName ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    T.savedVars = ZO_SavedVars:NewAccountWide(
        "TetsuCombatToolsSavedVars",
        1,
        nil,
        defaultAccountVars
    )

    if T.savedVars.skillSlots == nil then T.savedVars.skillSlots = 6 end
    if T.savedVars.skillShow == nil then T.savedVars.skillShow = "combat" end
    if T.savedVars.skillHideAfter == nil then T.savedVars.skillHideAfter = 8 end
    if T.savedVars.skillShowGcd == nil then T.savedVars.skillShowGcd = true end
    if T.savedVars.skillShowWeave == nil then T.savedVars.skillShowWeave = true end
    if T.savedVars.statusEnabled == nil then T.savedVars.statusEnabled = true end
    if T.savedVars.statusIcon == nil then T.savedVars.statusIcon = true end
    if T.savedVars.statusText == nil then T.savedVars.statusText = false end
    if T.savedVars.statusSound == nil then T.savedVars.statusSound = true end
    if T.savedVars.statusSoundId == nil or T.savedVars.statusSoundId == "quest" then
        T.savedVars.statusSoundId = "duel"
    end
    if T.savedVars.statusTextY == nil then T.savedVars.statusTextY = 250 end
    if T.savedVars.statusIconAlpha == nil then T.savedVars.statusIconAlpha = 50 end
    if T.savedVars.statusIconScaleRev == nil then
        local sc = tonumber(T.savedVars.statusIconScale)
        if sc == nil or sc == 100 then
            T.savedVars.statusIconScale = 50
        end
        T.savedVars.statusIconScaleRev = 1
    end
    -- Old default Y was 0 (reticle). New default sits above the action bar.
    if T.savedVars.skillPosRev == nil then
        if (tonumber(T.savedVars.skillOffsetY) or 0) == 0 then
            T.savedVars.skillOffsetY = 330
        end
        T.savedVars.skillPosRev = 1
    end

    if T.savedVars.timerDefRev == nil then
        T.savedVars.timerEnabled = false
        T.savedVars.timerDefRev = 1
    end
    if T.savedVars.timerDungeon == nil then T.savedVars.timerDungeon = true end
    if T.savedVars.timerTrial == nil then T.savedVars.timerTrial = true end
    if T.savedVars.timerArena == nil then T.savedVars.timerArena = true end
    if T.savedVars.timerGoal == nil then T.savedVars.timerGoal = true end
    if T.savedVars.timerOffsetY == nil then T.savedVars.timerOffsetY = -280 end
    if T.savedVars.timerScale == nil then T.savedVars.timerScale = 100 end
    if T.savedVars.consShowFood == nil then T.savedVars.consShowFood = true end
    if T.savedVars.consShowPot == nil then T.savedVars.consShowPot = true end
    if T.savedVars.consPotSound == nil then T.savedVars.consPotSound = false end
    if T.savedVars.consEndSoundId == nil then T.savedVars.consEndSoundId = "alert" end
    if T.savedVars.consAlertRev == nil then
        T.savedVars.consFoodSound = false
        T.savedVars.consPotSound = false
        T.savedVars.consMsgEnabled = false
        T.savedVars.consMsgFood = false
        T.savedVars.consMsgPot = false
        T.savedVars.consAlertRev = 1
    end
    if T.savedVars.consMsgY == nil then T.savedVars.consMsgY = -200 end
    if T.savedVars.consMsgScale == nil then T.savedVars.consMsgScale = 100 end

    if T.RegisterSettings then
        T.RegisterSettings()
    end
    if T.SkillStart then
        T.SkillStart()
    end
    if T.StatusStart then
        T.StatusStart()
    end
    if T.ConsStart then
        T.ConsStart()
    end
    if T.TimerStart then
        T.TimerStart()
    end
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
