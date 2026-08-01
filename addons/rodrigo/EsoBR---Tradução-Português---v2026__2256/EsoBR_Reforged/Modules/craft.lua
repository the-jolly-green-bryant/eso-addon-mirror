Reforged.Modules.register({
    id      = "craft",
    enabled = function()
        return Reforged.Settings.ShowNPC ~= "br" or Reforged.Settings.ShowCraft ~= "br"
    end,
    activate = function()
        local npc    = Reforged.Data.NPC
        local COLOR  = Reforged.COLOR_SECONDARY
        local RESET  = Reforged.COLOR_RESET
        local prevBr, prevEn = "", ""

        Reforged.Hooks.replace("GetGameCameraInteractableActionInfo", function(orig)
            return function(...)
                if Reforged.craftingStationActive then return orig() end
                local action, name, blocked, owned, extra, ctx, ctxLink, criminal = orig()
                local interactionType, modeSetting

                if action == GetString(SI_GAMECAMERAACTIONTYPE2)
                or action == GetString(SI_GAMECAMERAACTIONTYPE21)
                or action == GetString(SI_GAMECAMERAACTIONTYPE1)
                or action == GetString(SI_GAMECAMERAACTIONTYPE7) then
                    interactionType = "npc"
                    modeSetting = Reforged.Settings.ShowNPC
                elseif action == GetString(SI_GAMECAMERAACTIONTYPE5) then
                    interactionType = "craft"
                    modeSetting = Reforged.Settings.ShowCraft
                end

                if not modeSetting or modeSetting == "br" or name == nil then
                    return action, name, blocked, owned, extra, ctx, ctxLink, criminal
                end

                if interactionType == "npc" then
                    local enName
                    if name == prevBr then
                        enName = prevEn
                    else
                        enName = npc[zo_strlower(name)]
                        if enName == nil then
                            return action, name, blocked, owned, extra, ctx, ctxLink, criminal
                        end
                        prevEn = enName
                        prevBr = name
                    end
                    if enName ~= name then
                        if modeSetting == "bren" then
                            name = ZO_CachedStrFormat(SI_ZONE_NAME, name) .. "\n" .. enName
                        elseif modeSetting == "enbr" then
                            name = enName .. "\n" .. ZO_CachedStrFormat(SI_ZONE_NAME, name)
                        else
                            name = enName
                        end
                    end

                elseif interactionType == "craft" then
                    local brName = string.match(name, "%((.*)%)$")
                    local enName
                    if name == prevBr then
                        enName = prevEn
                    else
                        if brName then
                            enName = Reforged.Settings.Data.SetsNames[zo_strlower(brName)]
                        end
                        if enName == nil then
                            return action, name, blocked, owned, extra, ctx, ctxLink, criminal
                        end
                        prevEn = enName
                        prevBr = name
                    end
                    if enName ~= name and brName then
                        local firstPart = string.match(name, "^(.*) %(")
                        if modeSetting == "bren" then
                            name = string.format("%s (%s) %s(%s)%s", firstPart, brName, COLOR, enName, RESET)
                        elseif modeSetting == "enbr" then
                            name = string.format("%s (%s) %s(%s)%s", firstPart, enName, COLOR, brName, RESET)
                        else
                            name = string.format("%s (%s)", firstPart, enName)
                        end
                    end
                end

                return action, name, blocked, owned, extra, ctx, ctxLink, criminal
            end
        end)
    end,
})
