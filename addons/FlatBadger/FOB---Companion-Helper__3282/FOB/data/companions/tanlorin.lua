local defId = FOB.DefIds.Tanlorin
local cid = GetCompanionCollectibleId(defId)
local name, _, icon = GetCollectibleInfo(cid)

FOB.Functions[defId] = {
    Sort = name,
    Dislikes = function(action, interactableName)
        if (FOB.Vars.PreventNirnroot) then
            if (action == FOB.Actions.Collect) then
                if (FOB.LC.PartialMatch(interactableName, { [FOB.Nirnroot] = true })) then
                    return true
                end
            end
        end

        if (FOB.Vars.PreventMagesGuild) then
            if (action == FOB.Actions.Open) then
                if (interactableName == FOB.MagesGuild) then
                    return true
                end
            end
        end

        if (FOB.Vars.PreventLorebooks) then
            -- examine
            if (action == FOB.Actions.Examine) then
                if (FOB.IsFromShalidorsLibrary(interactableName)) then
                    return true
                end
            end

            -- search - block bookshelves, just in case
            if (FOB.Vars.PreventBookshelves) then
                if (action == FOB.Actions.Search and FOB.LC.PartialMatch(interactableName, { [FOB.Bookshelf] = true })) then
                    return true
                end
            end
        end

        if (FOB.Vars.PreventPsijic) then
            if (action == FOB.Actions.Loot and FOB.LC.PartialMatch(interactableName, { [FOB.PsijicPortal] = true })) then
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
                name = GetString(FOB_PREVENT_NIRNROOT),
                getFunc = function()
                    return FOB.Vars.PreventNirnroot
                end,
                setFunc = function(value)
                    FOB.Vars.PreventNirnroot = value
                end,
                width = "full"
            },
            [2] = {
                type = "checkbox",
                name = GetString(FOB_PREVENT_MAGES_GUILD),
                getFunc = function()
                    return FOB.Vars.PreventMagesGuild
                end,
                setFunc = function(value)
                    FOB.Vars.PreventMagesGuild = value
                end,
                width = "full"
            },
            [3] = {
                type = "checkbox",
                name = GetString(FOB_PREVENT_LOREBOOKS),
                getFunc = function()
                    return FOB.Vars.PreventLorebooks
                end,
                setFunc = function(value)
                    FOB.Vars.PreventLorebooks = value
                end,
                width = "full"
            },
            [4] = {
                type = "checkbox",
                name = GetString(FOB_PREVENT_BOOKSHELVES),
                getFunc = function()
                    return FOB.Vars.PreventBookshelves
                end,
                setFunc = function(value)
                    FOB.Vars.PreventBookshelves = value
                end,
                width = "full",
                disabled = function()
                    return not FOB.Vars.PreventLorebooks
                end
            },
            [5] = {
                type = "checkbox",
                name = GetString(FOB_PREVENT_BLADE_OF_WOE),
                getFunc = function()
                    return FOB.Vars.PreventBladeOfWoeTanlorin
                end,
                setFunc = function(value)
                    FOB.Vars.PreventBladeOfWoeTanlorin = value

                    if (value) then
                        FOB.RegisterForBladeOfWoe(defId)
                    else
                        FOB.UnregisterForBladeOfWoe(defId)
                    end
                end,
                width = "full"
            },
            [6] = {
                type = "checkbox",
                name = GetString(FOB_PREVENT_PSIJIC),
                getFunc = function()
                    return FOB.Vars.PreventPsijic
                end,
                setFunc = function(value)
                    FOB.Vars.PreventPsijic = value
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
