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
    statusEnabled = true,
    statusIcon = true,
    statusIconX = 0,
    statusIconY = 0,
    statusIconScale = 50,
    statusText = false,
    statusTextX = 0,
    statusTextY = 250,
    statusTextScale = 100,
    statusSound = true,
    statusSoundId = "duel",
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
    if T.savedVars.statusEnabled == nil then T.savedVars.statusEnabled = true end
    if T.savedVars.statusIcon == nil then T.savedVars.statusIcon = true end
    if T.savedVars.statusText == nil then T.savedVars.statusText = false end
    if T.savedVars.statusSound == nil then T.savedVars.statusSound = true end
    if T.savedVars.statusSoundId == nil or T.savedVars.statusSoundId == "quest" then
        T.savedVars.statusSoundId = "duel"
    end
    if T.savedVars.statusTextY == nil then T.savedVars.statusTextY = 250 end
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

    if T.RegisterSettings then
        T.RegisterSettings()
    end
    if T.SkillStart then
        T.SkillStart()
    end
    if T.StatusStart then
        T.StatusStart()
    end
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
