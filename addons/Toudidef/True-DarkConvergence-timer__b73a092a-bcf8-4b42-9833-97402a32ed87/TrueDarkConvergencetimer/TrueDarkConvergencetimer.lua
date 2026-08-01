-- =========================================================================
--  TRUE DARK CONVERGENCE TIMER - VERSION SLIDERS (X/Y)
-- =========================================================================

TrueDarkConvergencetimer = {}
TrueDarkConvergencetimer.name = "TrueDarkConvergencetimer"

-- Variables par défaut
TrueDarkConvergencetimer.defaults = {
    fontSize = 40,
    offsetX = -450,
    offsetY = -250,
}

-- Liste des IDs (Dark Convergence et autres triggers)
TrueDarkConvergencetimer.targetIds = {
    [159385] = true, [159367] = true, [159387] = true, 
    [159392] = true, [153670] = true, [153671] = true,
}
TrueDarkConvergencetimer.timerDuration = 25000 
TrueDarkConvergencetimer.isTimerRunning = false
TrueDarkConvergencetimer.endTime = 0

-- Références UI
TrueDarkConvergencetimer.uiControl = nil
TrueDarkConvergencetimer.labelControl = nil

-- =========================================================================
--  1. CRÉATION DE L'INTERFACE (UI)
-- =========================================================================

function TrueDarkConvergencetimer.CreateUI()
    local tlw = WINDOW_MANAGER:CreateTopLevelWindow("TDCTimer_TLW")
    tlw:SetClampedToScreen(true)
    tlw:SetDimensions(300, 100)
    
    -- Application de la position initiale
    local x = TrueDarkConvergencetimer.savedVariables.offsetX
    local y = TrueDarkConvergencetimer.savedVariables.offsetY
    tlw:SetAnchor(BOTTOMRIGHT, GuiRoot, BOTTOMRIGHT, x, y)

    local label = WINDOW_MANAGER:CreateControl("TDCTimer_Label", tlw, CT_LABEL)
    label:SetFont("$(BOLD_FONT)|" .. TrueDarkConvergencetimer.savedVariables.fontSize .. "|soft-shadow-thick")
    label:SetAnchor(CENTER, tlw, CENTER, 0, 0)
    label:SetText("|c00FF00READY|r")
    
    TrueDarkConvergencetimer.uiControl = tlw
    TrueDarkConvergencetimer.labelControl = label

    -- Masquer dans les menus standards, mais visible dans HUD et HUDUI
    local fragment = ZO_HUDFadeSceneFragment:New(tlw)
    SCENE_MANAGER:GetScene("hud"):AddFragment(fragment)
    SCENE_MANAGER:GetScene("hudui"):AddFragment(fragment) 
end

-- Fonction utilitaire pour mettre à jour la position depuis le menu
function TrueDarkConvergencetimer.UpdatePosition()
    if TrueDarkConvergencetimer.uiControl then
        local saved = TrueDarkConvergencetimer.savedVariables
        TrueDarkConvergencetimer.uiControl:ClearAnchors()
        TrueDarkConvergencetimer.uiControl:SetAnchor(BOTTOMRIGHT, GuiRoot, BOTTOMRIGHT, saved.offsetX, saved.offsetY)
    end
end

-- =========================================================================
--  2. TIMER LOGIQUE
-- =========================================================================

function TrueDarkConvergencetimer.OnUpdate()
    local currentTime = GetGameTimeMilliseconds()
    local remaining = TrueDarkConvergencetimer.endTime - currentTime

    if remaining > 0 then
        -- Affichage du temps restant
        local secondsLeft = string.format("%.1f", remaining / 1000) -- Une décimale
        TrueDarkConvergencetimer.labelControl:SetText("|cFF0000WAIT : " .. secondsLeft .. "|r")
    else
        -- Timer terminé
        EVENT_MANAGER:UnregisterForUpdate(TrueDarkConvergencetimer.name .. "Loop")
        TrueDarkConvergencetimer.isTimerRunning = false
        TrueDarkConvergencetimer.labelControl:SetText("|c00FF00READY|r")
    end
end

function TrueDarkConvergencetimer.StartTimer()
    -- On écrase le timer précédent s'il y en a un (refresh du proc)
    TrueDarkConvergencetimer.isTimerRunning = true
    TrueDarkConvergencetimer.endTime = GetGameTimeMilliseconds() + TrueDarkConvergencetimer.timerDuration
    -- Lance la boucle du timer (mise à jour toutes les 100ms suffit ici)
    EVENT_MANAGER:RegisterForUpdate(TrueDarkConvergencetimer.name .. "Loop", 100, TrueDarkConvergencetimer.OnUpdate)
end

function TrueDarkConvergencetimer.OnCombatEvent(_, result, _, _, _, _, _, _, _, _, _, _, _, _, _, _, abilityId)
    -- Vérifie si l'ID correspond à la liste
    if TrueDarkConvergencetimer.targetIds[abilityId] then
        TrueDarkConvergencetimer.StartTimer()
    end
end

-- =========================================================================
--  3. MENU SETTINGS (LibAddonMenu)
-- =========================================================================

function TrueDarkConvergencetimer.BuildMenu()
    local LAM = LibAddonMenu2
    if not LAM then return end

    local panelData = {
        type = "panel",
        name = "True Dark Convergence",
        displayName = "|cFF0000True Dark Convergence|r Timer",
        author = "Moi",
        version = "4.0",
        registerForRefresh = true,
    }

    local optionsData = {
        {
            type = "header",
            name = "Position",
        },
        {
            type = "description",
            text = "Change position X and Y.",
        },
        {
            type = "slider",
            name = "Position X",
            tooltip = "Change position X.",
            min = -2000, max = 500, step = 10, -- Large plage pour s'adapter aux écrans
            getFunc = function() return TrueDarkConvergencetimer.savedVariables.offsetX end,
            setFunc = function(value) 
                TrueDarkConvergencetimer.savedVariables.offsetX = value
                TrueDarkConvergencetimer.UpdatePosition()
            end,
        },
        {
            type = "slider",
            name = "Position Y",
            tooltip = "Change position Y.",
            min = -1500, max = 500, step = 10,
            getFunc = function() return TrueDarkConvergencetimer.savedVariables.offsetY end,
            setFunc = function(value) 
                TrueDarkConvergencetimer.savedVariables.offsetY = value
                TrueDarkConvergencetimer.UpdatePosition()
            end,
        },
        {
            type = "button",
            name = "Reset position",
            func = function() 
                TrueDarkConvergencetimer.savedVariables.offsetX = -450
                TrueDarkConvergencetimer.savedVariables.offsetY = -250
                TrueDarkConvergencetimer.UpdatePosition()
            end,
        },
        {
            type = "header",
            name = "Size and Tests",
        },
        {
            type = "slider",
            name = "Size",
            min = 20, max = 70, step = 1,
            getFunc = function() return TrueDarkConvergencetimer.savedVariables.fontSize end,
            setFunc = function(value)
                TrueDarkConvergencetimer.savedVariables.fontSize = value
                if TrueDarkConvergencetimer.labelControl then
                    TrueDarkConvergencetimer.labelControl:SetFont("$(BOLD_FONT)|" .. value .. "|soft-shadow-thick")
                end
            end,
        },
        {
            type = "button",
            name = "Test",
            tooltip = "Display timer.",
            func = function() TrueDarkConvergencetimer.StartTimer() end,
        },
    }

    LAM:RegisterAddonPanel("TDC_Options", panelData)
    LAM:RegisterOptionControls("TDC_Options", optionsData)
end

-- =========================================================================
--  4. INITIALISATION
-- =========================================================================

function TrueDarkConvergencetimer.OnAddOnLoaded(event, addonName)
    if addonName ~= TrueDarkConvergencetimer.name then return end
    EVENT_MANAGER:UnregisterForEvent(TrueDarkConvergencetimer.name, EVENT_ADD_ON_LOADED)

    TrueDarkConvergencetimer.savedVariables = ZO_SavedVars:NewAccountWide("TrueDarkConvergencetimerVars", 1, nil, TrueDarkConvergencetimer.defaults)

    TrueDarkConvergencetimer.CreateUI()
    TrueDarkConvergencetimer.BuildMenu()
    
    EVENT_MANAGER:RegisterForEvent(TrueDarkConvergencetimer.name, EVENT_COMBAT_EVENT, TrueDarkConvergencetimer.OnCombatEvent)
    
    d("[TDC] Addon Loaded (Slider Version).")
end

EVENT_MANAGER:RegisterForEvent(TrueDarkConvergencetimer.name, EVENT_ADD_ON_LOADED, TrueDarkConvergencetimer.OnAddOnLoaded)