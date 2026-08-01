local C = Conductor
C.SessionDialogs = C.SessionDialogs or {}
local Dialogs = C.SessionDialogs

Dialogs.DIALOG_NAME = "CONDUCTOR_VALIDATED_RAID_PLAN"

function Dialogs:Register()
    if self.registered or not ZO_Dialogs_RegisterCustomDialog then return end
    ZO_Dialogs_RegisterCustomDialog(self.DIALOG_NAME, {
        title = { text = "Conductor Raid Plan" },
        mainText = { text = function(dialog)
            local data = dialog.data or {}
            local snapshot = data.snapshot or {}
            return string.format("%s shared |cFFD447%s|r.\n\nTrial: %s\nDifficulty: %s\nObjective: %s\nStrategy: %s\nPlayers: %d\n\nThe Raid Plan has been received and validated. Press X to accept or Circle to decline.",
                tostring(data.sender or "Unknown host"), tostring(snapshot.teamName or "Raid Team"),
                tostring(snapshot.trial ~= "" and snapshot.trial or "Not selected"),
                tostring(snapshot.difficulty ~= "" and snapshot.difficulty or "Not selected"),
                tostring(snapshot.objective ~= "" and snapshot.objective or "Not selected"),
                tostring(snapshot.strategy ~= "" and snapshot.strategy or "Not selected"),
                #(snapshot.players or {}))
        end },
        buttons = {
            { text = SI_DIALOG_ACCEPT, keybind = "DIALOG_PRIMARY", callback = function() if C.SessionSharing then C.SessionSharing:AcceptPendingInvitation() end end },
            { text = SI_DIALOG_DECLINE, keybind = "DIALOG_NEGATIVE", callback = function() if C.SessionSharing then C.SessionSharing:DeclinePendingInvitation() end end },
        },
        canQueue = true,
    })
    self.registered = true
end

function Dialogs:Show(transfer)
    self:Register()
    local shown = false
    if IsInGamepadPreferredMode and IsInGamepadPreferredMode() and ZO_Dialogs_ShowGamepadDialog then
        shown = pcall(ZO_Dialogs_ShowGamepadDialog, self.DIALOG_NAME, transfer)
    end
    if not shown and ZO_Dialogs_ShowDialog then
        shown = pcall(ZO_Dialogs_ShowDialog, self.DIALOG_NAME, transfer)
    end
    return shown
end
