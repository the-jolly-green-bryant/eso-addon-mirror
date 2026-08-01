Reforged.Modules.register({
    id      = "champion",
    -- Only relevant when game is running in Portuguese (BR → EN translation)
    enabled = function()
        return GetCVar("language.2") == "br" and Reforged.Settings.ShowChampionTooltip ~= "br"
    end,
    activate = function()
        local rsd    = Reforged.Settings.Data
        local backup = Reforged.StringsBackup
        local COLOR  = Reforged.COLOR_SECONDARY

        local function buildName(brsName, abilityId)
            local enName = rsd.Abilities[abilityId]
            if not enName or not brsName then return brsName end
            local mode = Reforged.Settings.ShowChampionTooltip
            if mode == "bren" then
                return string.format("%s |ce1f7f5(%s)", brsName, enName)
            elseif mode == "enbr" then
                return string.format("%s |ce1f7f5(%s)", enName, brsName)
            elseif mode == "en" then
                return enName
            end
            return brsName
        end

        local function modifyTooltip(abilityId, brsName)
            local enName = rsd.Abilities[abilityId]
            if not enName or not brsName then return end
            local mode = Reforged.Settings.ShowChampionTooltip
            local finalName
            if mode == "bren" then
                finalName = string.format("%s \n%s(%s)", brsName, COLOR, enName)
            elseif mode == "enbr" then
                finalName = string.format("%s \n%s(%s)", enName, COLOR, brsName)
            elseif mode == "en" then
                finalName = enName
            end
            if finalName then
                SafeAddString(SI_ABILITY_TOOLTIP_NAME, finalName, 10)
            end
        end

        Reforged.Hooks.replace("GetChampionSkillName", function(orig)
            return function(...)
                local skillId  = ...
                local abilityId = GetChampionAbilityId(skillId)
                local brsName  = orig(...)
                return buildName(brsName, abilityId) or brsName
            end
        end)

        local function tooltipHook(tooltipCtrl, method, idFn)
            local origMethod = tooltipCtrl[method]
            tooltipCtrl[method] = function(self, ...)
                modifyTooltip(idFn(...))
                origMethod(self, ...)
                SafeAddString(SI_ABILITY_TOOLTIP_NAME, backup["SI_ABILITY_TOOLTIP_NAME"], 10)
            end
        end

        tooltipHook(ChampionSkillTooltip, "SetChampionSkill", function(skillId)
            local abilityId = GetChampionAbilityId(skillId)
            return abilityId, GetAbilityName(abilityId)
        end)
        tooltipHook(ChampionSkillTooltip, "SetAbilityId", function(abilityId)
            return abilityId, GetAbilityName(abilityId)
        end)

        Reforged.Hooks.pre(CHAMPION_PERKS, "LayoutRightTooltipChampionSkillAbility",
            function(_, ...) modifyTooltip(...) end)
        Reforged.Hooks.post(CHAMPION_PERKS, "LayoutRightTooltipChampionSkillAbility",
            function() SafeAddString(SI_ABILITY_TOOLTIP_NAME, backup["SI_ABILITY_TOOLTIP_NAME"], 10) end)
    end,
})
