local defId = FOB.DefIds.Sharp
local cid = GetCompanionCollectibleId(defId)
local name, _, icon = GetCollectibleInfo(cid)

FOB.Functions[defId] = {
    Sort = name,
    Dislikes = function(action, interactableName, _, additionalInfo)
        if (FOB.Vars.PreventOutfit) then
            if (action == FOB.Actions.Use) then
                if (interactableName == ZO_CachedStrFormat("<<C:1>>", GetString(SI_RESTYLE_STATION_MENU_ROOT_TITLE))) then
                    return true
                end
            end
        end

        if (FOB.Vars.PreventPickpocketingSharp) then
            if (additionalInfo == ADDITIONAL_INTERACT_INFO_PICKPOCKET_CHANCE) then
                return FOB.AllowPickPocketing()
            end
        end

        return false
    end,
    Settings = function(options)
        name = ZO_CachedStrFormat(SI_UNIT_NAME, name)

        local submenu = {
            [1] = {
                type = "checkbox",
                name = GetString(FOB_PREVENT_OUTFIT),
                getFunc = function()
                    return FOB.Vars.PreventOutfit
                end,
                setFunc = function(value)
                    FOB.Vars.PreventOutfit = value
                end,
                width = "full"
            },
            [2] = {
                type = "checkbox",
                name = GetString(FOB_WARN_BROKEN),
                getFunc = function()
                    return FOB.Vars.CheckDamage
                end,
                setFunc = function(value)
                    FOB.Vars.CheckDamage = value
                end,
                width = "full"
            },
            [3] = {
                type = "checkbox",
                name = GetString(FOB_PREVENT_PICKPOCKETING),
                tooltip = GetString(FOB_PREVENT_SPECIFIC_TT),
                getFunc = function()
                    return FOB.Vars.PreventPickpocketingSharp or false
                end,
                setFunc = function(value)
                    FOB.Vars.PreventPickpocketingSharp = value
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
    end,
    OnSingleSlotInventoryUpdate = function()
        if (FOB.Vars) then
            if (FOB.Vars.CheckDamage and FOB.ActiveCompanionDefId == defId) then
                local minDamage, itemName = FOB.CheckDurability()

                if (minDamage < 5) then
                    local announce = true
                    local previousTime = FOB.Vars.PreviousAnnounceTime or (os.time() - 301)
                    local debounceTime = 300

                    if (os.time() - previousTime <= debounceTime) then
                        announce = false
                    end

                    if (announce == true) then
                        FOB.Vars.PreviousAnnounceTime = os.time()
                        FOB.LC.ScreenAnnounce(
                            FOB.LC.Red:Colorize(GetString(FOB_WARNING)),
                            zo_strformat(
                                GetString(FOB_DAMAGED),
                                FOB.LC.ZOSGold:Colorize(itemName),
                                ZO_CachedStrFormat(
                                    SI_UNIT_NAME,
                                    GetCollectibleInfo(GetCompanionCollectibleId(defId))
                                )
                            )
                        )
                    end
                end
            end
        end
    end
}

if (IsCollectibleUsable(GetCompanionCollectibleId(defId), GAMEPLAY_ACTOR_CATEGORY_PLAYER)) then
    -- handle damaged item tracking
    SHARED_INVENTORY:RegisterCallback("SingleSlotInventoryUpdate", FOB.Functions[defId].OnSingleSlotInventoryUpdate)
end

FOB.NoPickPocketing[defId] = {
    [MONSTER_SOCIAL_CLASS_BEGGAR] = true,
    [MONSTER_SOCIAL_CLASS_FISHER] = true,
    [MONSTER_SOCIAL_CLASS_LABORER] = true
}
