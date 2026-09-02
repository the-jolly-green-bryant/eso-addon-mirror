-- BetterBGSounds

--------------------------------------------------
-- DECLARAÇÃO CRUCIAL PARA SALVAR CONFIGURAÇÕES
--------------------------------------------------
BetterBGSoundsSV = BetterBGSoundsSV or {} -- Isso avisa o Windows/ESO para salvar o arquivo físico!

--------------------------------------------------
-- Inicializa as variáveis do addon
--------------------------------------------------
BetterBGSounds = {}
BetterBGSounds.name = "BetterBGSounds"

--------------------------------------------------
-- Configurações padrões do addon
--------------------------------------------------
BetterBGSounds.defaults = {
    muteMedals = true,
    killSoundEnabled = true,
    selectedKillSound = "DUEL_START",
    killBoost = 3,
}

--------------------------------------------------
-- Lista de Sons Selecionados
--------------------------------------------------
BetterBGSounds.soundChoices = {
    "ABILITY_COMPANION_ULTIMATE_READY",
    "ANTIQUITIES_FANFARE_COMPLETED",
    "ANTIQUITIES_FANFARE_FRAGMENT_DISCOVERED_FINAL",
    "CHALLENGE_DIFFICULTY_SELECTED_VETERAN",
    "CHAMPION_PENDING_POINTS_CLEARED",
    "DUEL_START",
    "HUD_ARMOR_BROKEN",
    "LOCKPICKING_BREAK",
    "LOCKPICKING_UNLOCKED",
    "SKILL_POINT_GAINED"
}

table.sort(BetterBGSounds.soundChoices)

--------------------------------------------------
-- SISTEMA DE MUTE (Medalhas do BG)
--------------------------------------------------
local originalPlaySound = PlaySound
PlaySound = function(soundName)
    if BetterBGSounds.savedVariables and BetterBGSounds.savedVariables.muteMedals and soundName == SOUNDS.BATTLEGROUND_MEDAL_RECEIVED then
        return 
    end
    originalPlaySound(soundName)
end

--------------------------------------------------
-- SISTEMA DE DETECÇÃO DE ABATES (PvP)
--------------------------------------------------
function BetterBGSounds.OnCombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log)
    if BetterBGSounds.savedVariables and BetterBGSounds.savedVariables.killSoundEnabled then
        if result == ACTION_RESULT_KILLING_BLOW and sourceType == COMBAT_UNIT_TYPE_PLAYER then
            local soundKey = BetterBGSounds.savedVariables.selectedKillSound
            local soundConstant = SOUNDS[soundKey]
            
            if soundConstant then
                for i = 1, (BetterBGSounds.savedVariables.killBoost or 1) do
                    originalPlaySound(soundConstant)
                end
            end
        end
    end
end

--------------------------------------------------
-- Inicializa variáveis salvas e eventos
--------------------------------------------------
function BetterBGSounds.Initialize()
    -- Conecta os dados salvos com a tabela física global do arquivo txt
    BetterBGSounds.savedVariables = ZO_SavedVars:NewAccountWide("BetterBGSoundsSV", 1, nil, BetterBGSounds.defaults)
    EVENT_MANAGER:RegisterForEvent(BetterBGSounds.name, EVENT_COMBAT_EVENT, BetterBGSounds.OnCombatEvent)
end

function BetterBGSounds.AddOnLoaded(event, addonName)
    if addonName == BetterBGSounds.name then
        BetterBGSounds.Initialize()
        BetterBGSounds.InitializeSettingsMenu()
        EVENT_MANAGER:UnregisterForEvent(BetterBGSounds.name, EVENT_ADD_ON_LOADED)
    end
end

EVENT_MANAGER:RegisterForEvent(BetterBGSounds.name, EVENT_ADD_ON_LOADED, BetterBGSounds.AddOnLoaded)

--------------------------------------------------
-- MENU DE CONFIGURAÇÕES
--------------------------------------------------
function BetterBGSounds.InitializeSettingsMenu()
    local LAM = LibAddonMenu2
    local panelName = "BetterBGSoundsSettingsPanel"

    local panelData = {
        type = "panel",
        name = "Better BG Sounds",
        displayName = "|c00E600Better BG Sounds|r",
        author = "@ToRUk72",
        version = "2.3",
        registerForRefresh = true
    }
    
    local panel = LAM:RegisterAddonPanel(panelName, panelData)

    local optionsData = {
        {
            type = "header",
            name = "Mute Medals Settings",
        },
        {
            type = "checkbox",
            name = "Mute BG Medals Sound Effect",
            tooltip = "Turn ON to silence the medal sounds, or OFF to hear them again.",
            getFunc = function() return BetterBGSounds.savedVariables.muteMedals end,
            setFunc = function(value) BetterBGSounds.savedVariables.muteMedals = value end,
            width = "full",
        },
        {
            type = "header",
            name = "KillSound Settings",
        },
        {
            type = "checkbox",
            name = "Enable Kill Sound",
            tooltip = "Plays a sound notification whenever you land a killing blow on a player.",
            getFunc = function() return BetterBGSounds.savedVariables.killSoundEnabled end,
            setFunc = function(val) BetterBGSounds.savedVariables.killSoundEnabled = val end,
            width = "full",
        },
        {
            type = "dropdown",
            name = "Kill Sound Effect",
            tooltip = "Choose the sound effect that plays when you eliminate a player.",
            choices = BetterBGSounds.soundChoices,
            getFunc = function() return BetterBGSounds.savedVariables.selectedKillSound end,
            setFunc = function(choice)
                BetterBGSounds.savedVariables.selectedKillSound = choice
                originalPlaySound(SOUNDS[choice])
            end,
            width = "full",
        },
        {
            type = "button",
            name = "Preview Kill Sound",
            tooltip = "Test how loud your selected Kill Sound will sound.",
            func = function()
                local key = BetterBGSounds.savedVariables.selectedKillSound
                if key and SOUNDS[key] then 
                    for i = 1, (BetterBGSounds.savedVariables.killBoost or 1) do
                        originalPlaySound(SOUNDS[key])
                    end
                end
            end,
            width = "half",
        },
        {
            type = "slider",
            name = "Kill Sound Volume Boost",
            tooltip = "How many times to stack the sound at once to increase its in-game volume.",
            min = 1, max = 10, step = 1,
            getFunc = function() return BetterBGSounds.savedVariables.killBoost end,
            setFunc = function(value) BetterBGSounds.savedVariables.killBoost = value end,
            width = "full",
        },
    }

    LAM:RegisterOptionControls(panelName, optionsData)
end
