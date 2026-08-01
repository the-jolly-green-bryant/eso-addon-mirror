Reforged.Modules.register({
    id      = "abilities",
    enabled = function()
        return GetCVar("language.2") == "br"
            and (Reforged.Settings.ShowAbilitiesMenu ~= "br" or Reforged.Settings.ShowAbilitiesTooltip ~= "br")
    end,
    activate = function()
        local rsd    = Reforged.Settings.Data
        local backup = Reforged.StringsBackup
        local mr     = Reforged.Strings.magicReplace
        local COLOR  = Reforged.COLOR_SECONDARY

        local function resolveEnName(abilityId)
            local brsName = GetAbilityName(abilityId)
            local key     = ZO_CachedStrFormat("<<z:1>>", brsName)
            return rsd.CraftAbilities[key] or rsd.Abilities[abilityId], brsName
        end

        -- Skill menu entries
        if Reforged.Settings.ShowAbilitiesMenu == "en" then
            local origSkillSetup = ZO_Skills_AbilityEntry_Setup
            ZO_Skills_AbilityEntry_Setup = function(control, skillData)
                origSkillSetup(control, skillData)
                local abilityId = skillData:GetPointAllocator():GetProgressionData():GetAbilityId()
                local enName, brsName = resolveEnName(abilityId)
                if enName then
                    local nameCtrl = control:GetNamedChild("Name")
                    nameCtrl:SetText(mr(nameCtrl:GetText(), brsName, enName))
                end
            end

            local origCompSetup = ZO_Skills_CompanionSkillEntry_Setup
            ZO_Skills_CompanionSkillEntry_Setup = function(control, skillData)
                origCompSetup(control, skillData)
                local abilityId = skillData:GetPointAllocator():GetProgressionData():GetAbilityId()
                if rsd.Abilities[abilityId] then
                    local nameCtrl = control:GetNamedChild("Name")
                    nameCtrl:SetText(mr(nameCtrl:GetText(), GetAbilityName(abilityId), rsd.Abilities[abilityId]))
                end
            end

            ZO_SkillsConfirmDialog:SetHandler("OnShow", function()
                local abilityId = ZO_SkillsConfirmDialog.data:GetAbilityId()
                if rsd.Abilities[abilityId] then
                    local ctrl = ZO_SkillsConfirmDialog:GetNamedChild("AbilityName")
                    ctrl:SetText(mr(ctrl:GetText(), GetAbilityName(abilityId), rsd.Abilities[abilityId]))
                end
            end)

            ZO_SkillsMorphDialog:SetHandler("OnShow", function()
                local abilityId = ZO_SkillsMorphDialog:GetNamedChild("BaseAbility").skillProgressionData:GetAbilityId()
                if rsd.Abilities[abilityId] then
                    ZO_SkillsMorphDialog.desc:SetText(zo_strformat(SI_SKILLS_SELECT_MORPH, rsd.Abilities[abilityId]))
                end
            end)

            local origAdvisor = ZO_SKILLS_ADVISOR_SUGGESTION_WINDOW.SetupAbilityEntry
            ZO_SKILLS_ADVISOR_SUGGESTION_WINDOW.SetupAbilityEntry = function(manager, control, skillProgressionData)
                origAdvisor(manager, control, skillProgressionData)
                local abilityId = skillProgressionData:GetAbilityId()
                if rsd.Abilities[abilityId] then
                    local nameCtrl = control:GetNamedChild("Name")
                    nameCtrl:SetText(mr(nameCtrl:GetText(), GetAbilityName(abilityId), rsd.Abilities[abilityId]))
                end
            end

            -- Gamepad: replace GetName/GetFormattedName on skill progression data
            local origGetName = ZO_SkillProgressionData_Base.GetName
            function ZO_SkillProgressionData_Base:GetName()
                if rsd.Abilities[self:GetAbilityId()] and IsInGamepadPreferredMode() then
                    return rsd.Abilities[self:GetAbilityId()]
                end
                return origGetName(self)
            end

            local origGetFormattedName = ZO_SkillProgressionData_Base.GetFormattedName
            function ZO_SkillProgressionData_Base:GetFormattedName(formatter)
                if rsd.Abilities[self:GetAbilityId()] and IsInGamepadPreferredMode() then
                    return ZO_CachedStrFormat(formatter or SI_ABILITY_NAME, rsd.Abilities[self:GetAbilityId()])
                end
                return origGetFormattedName(self)
            end
        end

        -- Tooltip helpers
        local function buildTooltipName(finalName, brsName)
            local mode = Reforged.Settings.ShowAbilitiesTooltip
            if mode == "bren" then
                return string.format("%s \n%s(%s)", brsName, COLOR, finalName)
            elseif mode == "enbr" then
                return string.format("%s \n%s(%s)", finalName, COLOR, brsName)
            end
            return finalName  -- "en"
        end

        local function applyAbilityStrings(finalName, brsName)
            if not finalName or not brsName then return end
            local combined = buildTooltipName(finalName, brsName)
            SafeAddString(SI_ABILITY_NAME_AND_RANK, GetString(SI_ABILITY_NAME_AND_RANK):gsub("<<1>>", combined), 10)
            SafeAddString(SI_ABILITY_TOOLTIP_NAME, combined, 10)
        end

        local function restoreAbilityStrings()
            SafeAddString(SI_ABILITY_NAME_AND_RANK, backup["SI_ABILITY_NAME_AND_RANK"], 10)
            SafeAddString(SI_ABILITY_TOOLTIP_NAME,  backup["SI_ABILITY_TOOLTIP_NAME"], 10)
        end

        local function modifyTooltip(isPassive, isNew, ...)
            if Reforged.Settings.ShowAbilitiesTooltip == "br" then return end
            local abilityId
            if isPassive then
                local st, sl, si, rank = ...
                abilityId = GetSpecificSkillAbilityInfo(st, sl, si, 0, rank)
            elseif isNew then
                local st, sl, si = ...
                abilityId = GetSpecificSkillAbilityInfo(st, sl, si, 0, 1)
            else
                local st, sl, si, morph, _, _, _, _, _, _, _, _, _, overrideId = ...
                abilityId = overrideId or GetSpecificSkillAbilityInfo(st, sl, si, morph, 1)
            end
            if abilityId and rsd.Abilities[abilityId] then
                applyAbilityStrings(rsd.Abilities[abilityId], GetAbilityName(abilityId))
            end
        end

        local function modifyTooltipCompanion(abilityId)
            if Reforged.Settings.ShowAbilitiesTooltip == "br" or not abilityId then return end
            local brsName = GetAbilityName(abilityId)
            local key     = ZO_CachedStrFormat("<<z:1>>", brsName)
            local enName  = rsd.CraftAbilities[key] or rsd.Abilities[abilityId]
            if enName then applyAbilityStrings(enName, brsName) end
        end

        local function abilityTooltipHook(tooltipCtrl, method, isPassive, isNew, isCompanion)
            local origMethod = tooltipCtrl[method]
            tooltipCtrl[method] = function(self, ...)
                if isCompanion then
                    modifyTooltipCompanion(...)
                else
                    modifyTooltip(isPassive, isNew, ...)
                end
                origMethod(self, ...)
                restoreAbilityStrings()
            end
        end

        abilityTooltipHook(SkillTooltip, "SetActiveSkill",   false, false, false)
        abilityTooltipHook(SkillTooltip, "SetPassiveSkill",  true,  false, false)
        abilityTooltipHook(SkillTooltip, "SetSkillAbility",  false, true,  false)
        abilityTooltipHook(SkillTooltip, "SetCompanionSkill",false, false, true)
        abilityTooltipHook(SkillTooltip, "SetAbilityId",     false, false, true)
    end,
})
