if not PUGmo then
    PUGmo = {}
end
local PUG = PUGmo
local WM = WINDOW_MANAGER
local EM = EVENT_MANAGER
local SM = SCENE_MANAGER
local CM = CALLBACK_MANAGER
local CS = CHAT_SYSTEM

-------------------------------------------------------------------------
--- que a message for the alert box
-------------------------------------------------------------------------
function PUG:addAlert(text, iconPath, seconds)
    if not PUG.SV.alertOn then
        return
    end
    table.insert(PUG.alertBox.msgCache, { alert = text, icon = iconPath or "PUGmo/icons/alert.dds", delay = seconds or PUG.SV.alertTime.general })
    --- zero delay means there is not a message being displayed and we need to start the callback
    if PUG.alertBox.delay == 0 then
        EM:RegisterForUpdate(PUG.data.alertBoxCB, 500, function(...)
            local time = os.time()
            --- we have a message to display and there is not one being displayed
            if #PUG.alertBox.msgCache > 0 and PUG.alertBox.delay == 0 then
                PUG.alertBox.delay = PUG.alertBox.msgCache[1].delay + time
                PUGmoAlertBoxWindowLabel:SetText(PUG.alertBox.msgCache[1].alert)
                PUGmoAlertBoxWindowIcon:SetTexture(PUG.alertBox.msgCache[1].icon)
                --- remove the top one were are showing right now and turn it on
                table.remove(PUG.alertBox.msgCache, 1)
                local x, y = PUGmoAlertBoxWindowLabel:GetDimensions()
                PUGmoAlertBoxWindowLabelBg:SetDimensions(x + 16, y)
                PUGmoAlertBoxWindow:SetHidden(false)
                return

            elseif PUG.alertBox.confirm and not PUG.alertBox.pause then
                return

                --- pause if the reticule is hidden or waiting for confirmation
            elseif IsReticleHidden() and PUG.alertBox.pause then
                --- then double the fade time
                if PUG.alertBox.delay + PUG.SV.alertTime.general > time then
                    return
                else
                    PUG.alertBox.pause = false
                end

                --- are we still displaying it?
            elseif PUG.alertBox.delay > time then
                return
                --- no? then are there more?
            elseif #PUG.alertBox.msgCache == 0 then
                --- no? then turn off callback
                EM:UnregisterForUpdate(PUG.data.alertBoxCB)
            end
            --- turn off the alert box.
            PUG.alertBox.pause = true
            PUG.alertBox.confirm = false
            PUG.alertBox.delay = 0
            PUGmoAlertBoxWindow:SetHidden(true)
            PUGmoAlertBoxWindowConfirm:SetHidden(true)
            PUGmoAlertBoxWindowLabel:SetText("Test Alert Message")
            return
        end)
    end
end

-------------------------------------------------------------------------
