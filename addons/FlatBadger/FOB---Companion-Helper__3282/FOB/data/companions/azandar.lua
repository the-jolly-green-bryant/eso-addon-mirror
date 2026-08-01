local defId = FOB.DefIds.Azander
local cid = GetCompanionCollectibleId(defId)
local name, _, icon = GetCollectibleInfo(cid)

FOB.Functions[defId] = {
    Sort = name,
    Dislikes = function(action, interactableName)
        if (FOB.Vars.PreventMushroom) then
            if (action == FOB.Actions.Collect) then
                local ignoreMushrooms = FOB.Mushrooms[interactableName] or false

                if (FOB.UsingRuEso) then
                    ignoreMushrooms = FOB.LC.PartialMatch(interactableName, FOB.Mushrooms)
                end

                return ignoreMushrooms
            end
        end

        return false
    end,
    Settings = function(options)
        name = ZO_CachedStrFormat(SI_UNIT_NAME, name)

        local submenu = {
            [1] = {
                type = "checkbox",
                name = GetString(FOB_PREVENT_MUSHROOM),
                getFunc = function()
                    return FOB.Vars.PreventMushroom
                end,
                setFunc = function(value)
                    FOB.Vars.PreventMushroom = value
                end,
                width = "full"
            },
            [2] = {
                type = "checkbox",
                name = GetString(FOB_COFFEE_WARNING),
                getFunc = function()
                    return FOB.Vars.CoffeeWarning
                end,
                setFunc = function(value)
                    FOB.Vars.CoffeeWarning = value
                    CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", FOB.OptionsPanel)
                end,
                width = "full"
            },
            [3] = {
                type = "dropdown",
                name = GetString(FOB_ALERT_FONT),
                choices = FOB.Fonts,
                getFunc = function()
                    return FOB.Vars.CoffeeFont
                end,
                setFunc = function(value)
                    FOB.Vars.CoffeeFont = value

                    local font = FOB.GetFont(value, FOB.Vars.CoffeeFontSize, FOB.Vars.CoffeeFontShadow)

                    FOB.CoffeeAlert.Label:SetFont(font)
                end,
                disabled = function()
                    return FOB.Vars.CoffeeWarning == false
                end,
                width = "full"
            },
            [4] = {
                type = "colorpicker",
                name = GetString(FOB_ALERT_COLOUR),
                getFunc = function()
                    return FOB.Vars.CoffeeFontColour.r, FOB.Vars.CoffeeFontColour.g, FOB.Vars.CoffeeFontColour.b,
                        FOB.Vars.CoffeeFontColour.a
                end,
                setFunc = function(r, g, b, a)
                    FOB.Vars.CoffeeFontColour = { r = r, g = g, b = b, a = a }
                    FOB.CoffeeAlert.Label:SetColor(r, g, b, a)
                end,
                disabled = function()
                    return FOB.Vars.CoffeeWarning == false
                end,
                width = "full"
            },
            [5] = {
                type = "checkbox",
                name = GetString(FOB_ALERT_SHADOW),
                getFunc = function()
                    return FOB.Vars.CoffeeFontShadow
                end,
                setFunc = function(value)
                    FOB.Vars.CofeeFontShadow = value

                    local font = FOB.GetFont(FOB.Vars.CoffeeFont, FOB.Vars.CoffeeFontSize, FOB.Vars.CoffeeFontShadow)

                    FOB.CoffeeAlert.Label:SetFont(font)
                end,
                disabled = function()
                    return FOB.Vars.CoffeeWarning == false
                end,
                width = "full"
            },
            [6] = {
                type = "iconpicker",
                name = GetString(FOB_ALERT_ICON),
                getFunc = function()
                    return FOB.Vars.CoffeeIcon
                end,
                setFunc = function(value)
                    FOB.Vars.CoffeeIcon = value
                    FOB.CoffeeAlert.Texture:SetTexture(value)
                end,
                choices = FOB.CoffeeIcons,
                disabled = function()
                    return FOB.Vars.CoffeeWarning == false
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
