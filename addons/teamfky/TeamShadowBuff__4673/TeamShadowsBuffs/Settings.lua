TeamShadowsBuffs = TeamShadowsBuffs or {}
local TSB = TeamShadowsBuffs
local SETTINGS_PANEL_NAME = "TeamShadowsBuffsOptions"

local function OpenManagerFromSettings()
    zo_callLater(function()
        if SCENE_MANAGER then
            SCENE_MANAGER:Hide("gameMenuInGame")
        end
        if TSB.OpenManager then
            if TSB.SafeCall then
                TSB.SafeCall("Manager", "OpenManager", TSB.OpenManager)
            else
                TSB.OpenManager()
            end
        elseif TSB.Chat then
            TSB.Chat("La fenêtre Team Shadows Manager n'est pas disponible.")
        end
    end, 0)
end

function TSB.RegisterSettingsPanel()
    local LAM = LibAddonMenu2 or LibAddonMenu
    if not LAM then
        if TSB.Chat then
            TSB.Chat("LibAddonMenu-2.0 manquante : utilise /tsb pour ouvrir la fenêtre.")
        end
        return
    end

    local panelData = {
        type = "panel",
        name = TSB.displayName or "TeamShadowsBuffs",
        displayName = "|c55AAFFTeam Shadows Buffs|r",
        author = "TeamFF - EyrOn",
        version = TSB.version,
        registerForRefresh = false,
        registerForDefaults = false,
    }

    local panel = LAM:RegisterAddonPanel(SETTINGS_PANEL_NAME, panelData)
    TSB.settingsPanel = panel

    -- Aucun réglage LAM : l'entrée Extensions sert uniquement de raccourci.
    LAM:RegisterOptionControls(SETTINGS_PANEL_NAME, {})

    if panel and CALLBACK_MANAGER and not TSB.settingsPanelCallbackRegistered then
        TSB.settingsPanelCallbackRegistered = true
        CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", function(openedPanel)
            if openedPanel == panel then OpenManagerFromSettings() end
        end)
    end
end

function TSB.OpenSettingsPanel()
    if TSB.OpenManager then
        TSB.OpenManager()
        return
    end

    local LAM = LibAddonMenu2 or LibAddonMenu
    if LAM and LAM.OpenToPanel and TSB.settingsPanel then
        LAM:OpenToPanel(TSB.settingsPanel)
    elseif TSB.Chat then
        TSB.Chat("Utilise /tsb pour ouvrir la fenêtre Team Shadows Buffs.")
    end
end
