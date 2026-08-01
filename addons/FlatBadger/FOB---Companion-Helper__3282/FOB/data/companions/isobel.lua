local defId = FOB.DefIds.Isobel
local cid = GetCompanionCollectibleId(defId)
local name, _, icon = GetCollectibleInfo(cid)

FOB.Functions[defId] = {
    Sort = name,
    Dislikes = function(action, interactableName, isCriminalInteract)
        local isCriminal = isCriminalInteract

        if (FOB.Vars.PreventCriminalIsobel) then
            if (isCriminal ~= true and action) then
                isCriminal = FOB.LC.PartialMatch(action, FOB.Illegal)
            end

            return isCriminal
        end

        if (FOB.Vars.PreventOutlawsRefuge) then
            if (action == FOB.Actions.Open) then
                if (FOB.LC.PartialMatch(interactableName, FOB.OutlawsRefuge) and (not FOB.Exceptions[interactableName])) then
                    return true
                end
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
                    return FOB.Vars.PreventCriminalIsobel
                end,
                setFunc = function(value)
                    FOB.Vars.PreventCriminalIsobel = value
                end,
                width = "full"
            },
            [2] = {
                type = "checkbox",
                name = GetString(FOB_PREVENT_OUTLAW),
                getFunc = function()
                    return FOB.Vars.PreventOutlawsRefuge
                end,
                setFunc = function(value)
                    FOB.Vars.PreventOutlawsRefuge = value
                end,
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
