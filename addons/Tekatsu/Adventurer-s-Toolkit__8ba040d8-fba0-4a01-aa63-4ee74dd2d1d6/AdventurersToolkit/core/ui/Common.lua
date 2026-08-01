-- ============================================
-- COMMON UI COMPONENTS
-- ============================================

function NWT.ShowReloadUIDialog(eventCount)
    if not ESO_Dialogs["ATK_RELOAD_UI_DIALOG"] then
        ESO_Dialogs["ATK_RELOAD_UI_DIALOG"] = {
            gamepadInfo = { dialogType = GAMEPAD_DIALOGS.BASIC },
            canQueue = true,
            title = { text = "SCAN COMPLETE" },
            mainText = { text = "Scan complete!\nRefresh UI to scan other guilds." },
            buttons = {
                { text = "Reload UI", keybind = "DIALOG_PRIMARY", callback = function() ReloadUI() end },
                { text = "Later", keybind = "DIALOG_NEGATIVE" },
            },
        }
    end
NWT.Debug("|c00FF00[GST]|r Scan complete! " .. (eventCount or 0) .. " sales found.")
    if IsInGamepadPreferredMode() then ZO_Dialogs_ShowGamepadDialog("ATK_RELOAD_UI_DIALOG")
    else ZO_Dialogs_ShowDialog("ATK_RELOAD_UI_DIALOG") end
end

function NWT.CloseReloadDialog()
    if ATK_ReloadDialog then ATK_ReloadDialog:SetHidden(true) end
end
