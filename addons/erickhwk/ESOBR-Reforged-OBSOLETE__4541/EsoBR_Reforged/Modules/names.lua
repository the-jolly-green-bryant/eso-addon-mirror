Reforged.Modules.register({
    id      = "names",
    enabled = function() return Reforged.Settings.ShowNPC ~= "br" end,
    activate = function()
        local npc = Reforged.Data.NPC
        local COLOR = Reforged.COLOR_SECONDARY
        local RESET = Reforged.COLOR_RESET

        Reforged.Hooks.replace("GetUnitName", function(orig)
            return function(target)
                local name = orig(target)
                if target == "player" or name == nil then return name end
                if target == "reticleover" then
                    if not DoesUnitExist("reticleover") or IsUnitPlayer("reticleover") then
                        return name
                    end
                end
                local enName = npc[zo_strlower(name)]
                if enName == nil then return name end
                local mode = Reforged.Settings.ShowNPC
                if mode == "bren" then return name .. " (" .. enName .. ")"
                elseif mode == "enbr" then return enName .. " (" .. name .. ")"
                elseif mode == "en"  then return enName
                end
                return name
            end
        end)

        Reforged.Hooks.replace("GetMapLocationTooltipLineInfo", function(orig)
            return function(...)
                local icon, name, groupingId, categoryName = orig(...)
                if name == nil then return icon, name, groupingId, categoryName end
                local enName = npc[zo_strlower(name)]
                if enName then
                    local mode = Reforged.Settings.ShowNPC
                    if mode == "bren" then
                        name = name .. "\n" .. COLOR .. enName .. RESET
                    elseif mode == "enbr" then
                        name = enName .. "\n" .. COLOR .. name .. RESET
                    elseif mode == "en" then
                        name = enName
                    end
                end
                return icon, name, groupingId, categoryName
            end
        end)
    end,
})
