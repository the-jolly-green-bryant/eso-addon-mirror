local defId = FOB.DefIds.Bastian
local cid = GetCompanionCollectibleId(defId)
local name, _, icon = GetCollectibleInfo(cid)

FOB.Functions[defId] = {
    Sort = name,
    Dislikes = function(action, _, isCriminalInteract, additionalInfo)
        local isCriminal = isCriminalInteract

        if (FOB.Vars.PreventCriminalBastian) then
            if (isCriminal ~= true and action) then
                isCriminal = FOB.LC.PartialMatch(action, FOB.Illegal)
            end

            return isCriminal
        elseif (FOB.Vars.PreventPickpocketingBastian) then
            if (additionalInfo == ADDITIONAL_INTERACT_INFO_PICKPOCKET_CHANCE) then
                return true
            end
        end

        return false
    end,
    Settings = function(options)
        name = ZO_CachedStrFormat(SI_UNIT_NAME, name)

        local submenu = {
            [1] = {
                type = "checkbox",
                name = GetString(FOB_PREVENT_CRIMINAL),
                getFunc = function()
                    return FOB.Vars.PreventCriminalBastian
                end,
                setFunc = function(value)
                    FOB.Vars.PreventCriminalBastian = value
                end,
                width = "full"
            },
            [2] = {
                type = "checkbox",
                name = GetString(FOB_PREVENT_PICKPOCKETING),
                getFunc = function()
                    return FOB.Vars.PreventPickpocketingBastian or false
                end,
                setFunc = function(value)
                    FOB.Vars.PreventPickpocketingBastian = value
                end,
                disabled = function()
                    return FOB.Vars.PreventCriminalBastian
                end,
                width = "full"
            },
            [3] = {
                type = "checkbox",
                name = GetString(FOB_CHEESE_WARNING),
                getFunc = function()
                    return FOB.Vars.CheeseWarning
                end,
                setFunc = function(value)
                    FOB.Vars.CheeseWarning = value
                    CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", FOB.OptionsPanel)
                end,
                width = "full"
            },
            [4] = {
                type = "dropdown",
                name = GetString(FOB_ALERT_FONT),
                choices = FOB.Fonts,
                getFunc = function()
                    return FOB.Vars.CheeseFont
                end,
                setFunc = function(value)
                    FOB.Vars.CheeseFont = value
                    local font = FOB.GetFont(value, FOB.Vars.CheeseFontSize, FOB.Vars.CheeseFontShadow)
                    FOB.Alert.Label:SetFont(font)
                end,
                disabled = function()
                    return FOB.Vars.CheeseWarning == false
                end,
                width = "full"
            },
            [5] = {
                type = "colorpicker",
                name = GetString(FOB_ALERT_COLOUR),
                getFunc = function()
                    return FOB.Vars.CheeseFontColour.r, FOB.Vars.CheeseFontColour.g, FOB.Vars.CheeseFontColour.b,
                        FOB.Vars.CheeseFontColour.a
                end,
                setFunc = function(r, g, b, a)
                    FOB.Vars.CheeseFontColour = { r = r, g = g, b = b, a = a }
                    FOB.Alert.Label:SetColor(r, g, b, a)
                end,
                disabled = function()
                    return FOB.Vars.CheeseWarning == false
                end,
                width = "full"
            },
            [6] = {
                type = "checkbox",
                name = GetString(FOB_ALERT_SHADOW),
                getFunc = function()
                    return FOB.Vars.CheeseFontShadow
                end,
                setFunc = function(value)
                    FOB.Vars.CheeseFontShadow = value
                    local font = FOB.GetFont(FOB.Vars.CheeseFont, FOB.Vars.CheeseFontSize, FOB.Vars.CheeseFontShadow)
                    FOB.Alert.Label:SetFont(font)
                end,
                disabled = function()
                    return FOB.Vars.CheeseWarning == false
                end,
                width = "full"
            },
            [7] = {
                type = "iconpicker",
                name = GetString(FOB_ALERT_ICON),
                getFunc = function()
                    return FOB.Vars.CheeseIcon
                end,
                setFunc = function(value)
                    FOB.Vars.CheeseIcon = value
                    FOB.Alert.Texture:SetTexture(value)
                end,
                choices = FOB.CheeseIcons,
                disabled = function()
                    return FOB.Vars.CheeseWarning == false
                end,
                iconSize = 48,
                width = "full"
            }
        }

        options[#options + 1] = {
            type = "submenu",
            name = FOB.LC.Mustard:Colorize(name),
            controls = submenu,
            icon = icon
        }
    end
}
