local ADDON_NAME = "KillSound"

KS_G = {
    name = ADDON_NAME,
    version = "1.5",
    savedVars = nil,
    defaults = {
        killSoundEnabled = true,
        selectedKillSound = "LOCKPICKING_SUCCESS_CELEBRATION",
        killBoost = 1,

        hitSoundEnabled = false,
        selectedHitSound = "LOCKPICKING_BREAK",
        hitBoost = 1,

        normalSoundEnabled = false,
        selectedNormalSound = "LOCKPICKING_BREAK",
        critSoundEnabled = false,
        selectedCritSound = "ABILITY_ULTIMATE_READY",

        debug = false
    },
}

KS_G.soundChoices = {
    "LOCKPICKING_SUCCESS_CELEBRATION",
    "LOCKPICKING_UNLOCKED",
    "ABILITY_ULTIMATE_READY",
    "COUNTDOWN_TICK",
    "NEW_NOTIFICATION",
    "LOCKPICKING_BREAK",

}

table.sort(KS_G.soundChoices)

function KS_G.OnCombatEvent(eventCode, result, isError, abilityName,
                            abilityGraphic, abilityActionSlotType, sourceName,
                            sourceType, targetName, targetType, hitValue,
                            powerType, damageType, log)

    if KS_G.savedVars.debug then
        d(string.format("[KS Debug] Constant: %s, Ability: %s, Damage: %s, Source: %s, Target: %s", tostring(result), abilityName, hitValue, sourceName, targetName))
    end

    local playerName = GetUnitName("player")

    if KS_G.savedVars.killSoundEnabled
       and (result == ACTION_RESULT_DIED_XP or result == ACTION_RESULT_DIED)
       and targetName and targetName ~= ""
       and string.find(sourceName or "", playerName) then

        local soundKey = KS_G.savedVars.selectedKillSound
        local soundConstant = SOUNDS[soundKey] or SOUNDS.LOCKPICKING_SUCCESS_CELEBRATION

        for i = 1, (KS_G.savedVars.killBoost or 1) do
            PlaySound(soundConstant)
        end
    end

    local isPlayerSource = targetName and targetName ~= "" and string.find(sourceName or "", playerName)

    if isPlayerSource then
        if KS_G.savedVars.normalSoundEnabled
           and (result == ACTION_RESULT_DAMAGE or result == ACTION_RESULT_DOT_TICK) then

            local soundKey = KS_G.savedVars.selectedNormalSound
            local soundConstant = SOUNDS[soundKey] or SOUNDS.LOCKPICKING_BREAK

            for i = 1, (KS_G.savedVars.hitBoost or 1) do
                PlaySound(soundConstant)
            end
        end

        if KS_G.savedVars.critSoundEnabled
           and (result == ACTION_RESULT_CRITICAL_DAMAGE or result == ACTION_RESULT_DOT_TICK_CRITICAL) then

            local soundKey = KS_G.savedVars.selectedCritSound
            local soundConstant = SOUNDS[soundKey] or SOUNDS.ABILITY_ULTIMATE_READY

            for i = 1, (KS_G.savedVars.hitBoost or 1) do
                PlaySound(soundConstant)
            end
        end
    end
end

local function OnAddOnLoaded(event, addonName)
    if addonName ~= ADDON_NAME then return end

    KS_G.savedVars = ZO_SavedVars:NewAccountWide("KillSoundSavedVariables", 1, nil, KS_G.defaults)

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_COMBAT_EVENT, KS_G.OnCombatEvent)
    KS_G.InitializeSettingsMenu()

    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

function KS_G.InitializeSettingsMenu()
    if not LibAddonMenu2 then
        d("KillSound: LibAddonMenu-2.0 not found; settings menu not created.")
        return
    end

    local panelData = {
        type = "panel",
        name = "Kill Sound",
        displayName = "Kill Sound Settings",
        author = "@BullsFuzz",
        version = KS_G.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    LibAddonMenu2:RegisterAddonPanel("KS_G_Panel", panelData)

    local optionsData = {
        {
            type = "checkbox",
            name = "Enable Kill Sound",
            getFunc = function() return KS_G.savedVars.killSoundEnabled end,
            setFunc = function(val) KS_G.savedVars.killSoundEnabled = val end,
            width = "full",
        },

        {
            type = "dropdown",
            name = "Kill Sound",
            tooltip = "Sound played when you kill an enemy",
            choices = KS_G.soundChoices,
            getFunc = function() return KS_G.savedVars.selectedKillSound end,
            setFunc = function(choice)
                KS_G.savedVars.selectedKillSound = choice
                PlaySound(SOUNDS[choice])
            end,
            width = "full",
        },

        {
            type = "button",
            name = "Preview Kill Sound",
            func = function()
                local key = KS_G.savedVars.selectedKillSound
                if key and SOUNDS[key] then 
                    for i = 1, (KS_G.savedVars.killBoost or 1) do
                        PlaySound(SOUNDS[key])
                    end
                end
            end,
            width = "half",
        },

        {
            type = "slider",
            name = "Kill Sound Boost",
            tooltip = "How many times to play the kill sound at once - Basically volume",
            min = 1, max = 10, step = 1,
            getFunc = function() return KS_G.savedVars.killBoost end,
            setFunc = function(value) KS_G.savedVars.killBoost = value end,
            width = "full",
        },

        {
            type = "checkbox",
            name = "Enable Normal Hit Sound",
            getFunc = function() return KS_G.savedVars.normalSoundEnabled end,
            setFunc = function(val) KS_G.savedVars.normalSoundEnabled = val end,
            width = "full",
        },

        {
            type = "dropdown",
            name = "Sound played when you deal non-critical damage",
            choices = KS_G.soundChoices,
            getFunc = function() return KS_G.savedVars.selectedNormalSound end,
            setFunc = function(choice)
                KS_G.savedVars.selectedNormalSound = choice
                PlaySound(SOUNDS[choice])
            end,
            width = "full",
        },

        {
            type = "button",
            name = "Preview Normal Hit Sound",
            func = function()
                local key = KS_G.savedVars.selectedNormalSound
                if key and SOUNDS[key] then 
                    for i = 1, (KS_G.savedVars.hitBoost or 1) do
                        PlaySound(SOUNDS[key])
                    end
                end
            end,
            width = "half",
        },

        {
            type = "checkbox",
            name = "Enable Crit Hit Sound",
            getFunc = function() return KS_G.savedVars.critSoundEnabled end,
            setFunc = function(val) KS_G.savedVars.critSoundEnabled = val end,
            width = "full",
        },

        {
            type = "dropdown",
            name = "Sound played when you deal critical damage",
            choices = KS_G.soundChoices,
            getFunc = function() return KS_G.savedVars.selectedCritSound end,
            setFunc = function(choice)
                KS_G.savedVars.selectedCritSound = choice
                PlaySound(SOUNDS[choice])
            end,
            width = "full",
        },
        
        {
            type = "button",
            name = "Preview Crit Hit Sound",
            func = function()
                local key = KS_G.savedVars.selectedCritSound
                if key and SOUNDS[key] then 
                    for i = 1, (KS_G.savedVars.hitBoost or 1) do
                        PlaySound(SOUNDS[key])
                    end
                end
            end,
            width = "half",
        },

        {
            type = "slider",
            name = "Hit Sound Boost",
            tooltip = "How many times to play the hit sound at once - Basically volume",
            min = 1, max = 10, step = 1,
            getFunc = function() return KS_G.savedVars.hitBoost end,
            setFunc = function(value) KS_G.savedVars.hitBoost = value end,
            width = "full",
        },

        {
            type = "checkbox",
            name = "Debug Mode",
            warning = "This option will spam combat info in chat",
            getFunc = function() return KS_G.savedVars.debug end,
            setFunc = function(val) KS_G.savedVars.debug = val end,
            width = "full",
        },
    }

    LibAddonMenu2:RegisterOptionControls("KS_G_Panel", optionsData)
end
