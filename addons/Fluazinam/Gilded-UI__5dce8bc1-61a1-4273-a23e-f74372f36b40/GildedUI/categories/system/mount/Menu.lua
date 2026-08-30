if not GildedUI then return end

local Addon = GildedUI

function Addon:BuildStayMountedMenu(H)
    local sv = self.state.sv
    return {
        type = "submenu",
        name = "Stay Mounted",
        options = {
            H.Toggle(
                "Enable Stay Mounted",
                function() return sv.stayMounted end,
                function(v) sv.stayMounted = v end,
                Addon.defaults.stayMounted
            ),
            {
                type = "checklist",
                name = "Allowed Interactions",
                tooltip = "While mounted, only these interactions are allowed. Leave empty to block all.",
                choices = {
                    { name = GetString(SI_GAMECAMERAACTIONTYPE5), value = Addon.STAY_MOUNTED_ACTION_USE },
                    { name = GetString(SI_GAMECAMERAACTIONTYPE13), value = Addon.STAY_MOUNTED_ACTION_OPEN },
                    { name = GetString(SI_GAMECAMERAACTIONTYPE2), value = Addon.STAY_MOUNTED_ACTION_TALK },
                    { name = GetString(SI_GAMECAMERAACTIONTYPE16), value = Addon.STAY_MOUNTED_ACTION_FISH },
                },
                getFunc = function()
                    return sv.stayMountedAllowedInteractions
                end,
                setFunc = function(values)
                    sv.stayMountedAllowedInteractions = values or {}
                end,
                default = Addon.defaults.stayMountedAllowedInteractions,
                noSelectionText = "No interactions selected",
                selectionTextFormat = "<<1[$d interaction selected/$d interactions selected]>>",
                disabled = function()
                    return not sv.stayMounted
                end,
            },
            H.Toggle(
                "Block Actions",
                function() return sv.stayMountedBlockActions end,
                function(v)
                    sv.stayMountedBlockActions = v
                    Addon:SyncStayMountedActionLayers()
                end,
                Addon.defaults.stayMountedBlockActions
            ),
            {
                type = "checklist",
                name = "Allowed Actions",
                tooltip = "While mounted with Block Actions on, only these action slots remain usable. Leave empty to block all.",
                choices = {
                    { name = "Action 1", value = Addon.STAY_MOUNTED_SLOT_ACTION1 },
                    { name = "Action 2", value = Addon.STAY_MOUNTED_SLOT_ACTION2 },
                    { name = "Action 3", value = Addon.STAY_MOUNTED_SLOT_ACTION3 },
                    { name = "Action 4", value = Addon.STAY_MOUNTED_SLOT_ACTION4 },
                    { name = "Action 5", value = Addon.STAY_MOUNTED_SLOT_ACTION5 },
                    { name = "Ultimate", value = Addon.STAY_MOUNTED_SLOT_ULTIMATE },
                    { name = "Quick Slot", value = Addon.STAY_MOUNTED_SLOT_QUICKSLOT },
                },
                getFunc = function()
                    return sv.stayMountedAllowedActions
                end,
                setFunc = function(values)
                    sv.stayMountedAllowedActions = values or {}
                    Addon:SyncStayMountedActionLayers()
                end,
                default = Addon.defaults.stayMountedAllowedActions,
                noSelectionText = "No actions selected",
                selectionTextFormat = "<<1[$d action selected/$d actions selected]>>",
                disabled = function()
                    return not sv.stayMountedBlockActions
                end,
            },
            H.Toggle(
                "Block Special Moves",
                function() return sv.stayMountedBlockSpecialMoves end,
                function(v)
                    sv.stayMountedBlockSpecialMoves = v
                    Addon:SyncStayMountedActionLayers()
                end,
                Addon.defaults.stayMountedBlockSpecialMoves
            ),
            {
                type = "checklist",
                name = "Allowed Special Moves",
                tooltip = "While mounted with Block Special Moves on, only these moves remain usable. Leave empty to block all.",
                choices = {
                    { name = "Blocking", value = Addon.STAY_MOUNTED_SPECIAL_BLOCK },
                    { name = "Attacking", value = Addon.STAY_MOUNTED_SPECIAL_ATTACK },
                    { name = "Bashing", value = Addon.STAY_MOUNTED_SPECIAL_BASH },
                    { name = "Crouching", value = Addon.STAY_MOUNTED_SPECIAL_CROUCH },
                },
                getFunc = function()
                    return sv.stayMountedAllowedSpecialMoves
                end,
                setFunc = function(values)
                    sv.stayMountedAllowedSpecialMoves = values or {}
                    Addon:SyncStayMountedActionLayers()
                end,
                default = Addon.defaults.stayMountedAllowedSpecialMoves,
                noSelectionText = "No special moves selected",
                selectionTextFormat = "<<1[$d special move selected/$d special moves selected]>>",
                disabled = function()
                    return not sv.stayMountedBlockSpecialMoves
                end,
            },
        },
    }
end
