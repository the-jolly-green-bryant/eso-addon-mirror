local defId = FOB.DefIds.Ember
local cid = GetCompanionCollectibleId(defId)
local name, _, icon = GetCollectibleInfo(cid)

FOB.Functions[defId] = {
    Sort = name,
    Dislikes = function(_, _, _, additionalInfo)
        if (FOB.Vars.PreventFishing) then
            if (additionalInfo == ADDITIONAL_INTERACT_INFO_FISHING_NODE) then
                INTERACTIVE_WHEEL_MANAGER:StopInteraction(ZO_INTERACTIVE_WHEEL_TYPE_FISHING)

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
                name = GetString(FOB_PREVENT_FISHING),
                getFunc = function()
                    return FOB.Vars.PreventFishing
                end,
                setFunc = function(value)
                    FOB.Vars.PreventFishing = value
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
