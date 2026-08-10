-- Console pause menu integration (no LibHarvensAddonSettings / LibVotans required).
-- Registers Dolmen Runner under Pause -> Settings.

local PauseMenu = {}
local DR = DolmenRunner
local PANEL_ID = 87501
local panelRegistered = false
local menuFragment = nil

function PauseMenu:IsRegistered()
    return panelRegistered
end

function PauseMenu:Register()
    if panelRegistered or not IsConsoleUI() then
        return false
    end
    if type(ZO_GameMenu_AddSettingPanel) ~= "function" or not DolmenRunnerSettingsWindow then
        return false
    end

    menuFragment = ZO_FadeSceneFragment:New(DolmenRunnerSettingsWindow)

    local panelData = {
        id = PANEL_ID,
        name = DR.displayName,
        callback = function()
            SCENE_MANAGER:AddFragment(menuFragment)
            if DR.ui and DR.ui.OnPauseMenuOpen then
                DR.ui:OnPauseMenuOpen()
            end
        end,
        unselectedCallback = function()
            if DR.ui and DR.ui.OnPauseMenuClose then
                DR.ui:OnPauseMenuClose()
            end
            SCENE_MANAGER:RemoveFragment(menuFragment)
        end,
    }

    ZO_GameMenu_AddSettingPanel(panelData)
    panelRegistered = true
    return true
end

function PauseMenu:Initialize()
    if not IsConsoleUI() then
        return
    end
    self:Register()
end

DolmenRunner.pauseMenu = PauseMenu
