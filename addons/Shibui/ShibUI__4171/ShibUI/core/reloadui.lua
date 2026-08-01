--------------------------------------------------
-- ShibUI Reload UI Module
--------------------------------------------------
local SUI = SUI
local sv

SUI.ReloadUI = SUI.ReloadUI or {}
local ReloadUI = SUI.ReloadUI

local Log = function(...) SUI.Debug:Log(...) end

--------------------------------------------------
-- Helper Functions for Reload UI
-- Optional confirmation dialog before reloading.
--------------------------------------------------
local function RegisterDialogs()
    ZO_Dialogs_RegisterCustomDialog("RELOADUI_CONFIRM_DIALOG", {
        title = { text = "Reload UI" },
        mainText = { text = "Are you sure you want to reload the UI?" },
        buttons = {
            {
                text = SI_DIALOG_ACCEPT,
                callback = function()
                    _G.ReloadUI()
                end,
            },
            {
                text = SI_DIALOG_CANCEL,
            },
        },
    })
end

--------------------------------------------------
-- Reload UI Functionality
--------------------------------------------------
function ReloadUI:PerformReload()
    if self.enabled then
        ZO_Dialogs_ShowDialog("RELOADUI_CONFIRM_DIALOG")
    else
        _G.ReloadUI()
    end
end

function ReloadUI:OnKeybind()
    self:PerformReload()
end


--------------------------------------------------
-- Initialize Reload UI Module
--------------------------------------------------
function ReloadUI:Initialize()
    self.enabled = SUI.SavedVars.saved and SUI.SavedVars.saved.confirmReload
    RegisterDialogs()
    ZO_CreateStringId("SI_BINDING_NAME_RELOAD_UI_KEYBIND", "Reload UI")
    Log("ReloadUI", "Initialized")
end