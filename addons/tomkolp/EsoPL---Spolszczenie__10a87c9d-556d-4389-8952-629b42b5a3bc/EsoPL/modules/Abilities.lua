local ADDON_NAME = "EsoPL"

local function GetMode()
    if not EsoPL or not EsoPL.GetAbilitiesMode then
        return "pl"
    end
    return EsoPL.GetAbilitiesMode()
end

local function GetENTable()
    -- Czytamy z wbudowanej bazy z PC:
    if EsoPL_SkillDB_EN and EsoPL_SkillDB_EN.Abilities then
        return EsoPL_SkillDB_EN.Abilities
    end
    return nil
end

-- Finalna nazwa wg trybu: pl / en / plen / enpl
local function GetDisplayName(abilityId)
    local mode    = GetMode()
    local polName = GetAbilityName(abilityId) or ""
    local rsdEN   = GetENTable()
    local enName

    if rsdEN and rsdEN[abilityId] then
        enName = rsdEN[abilityId]
    end

    -- jeśli brak EN w bazie, pokazujemy PL
    if not enName or enName == "" then
        return polName
    end

    if mode == "en" then
        return enName
    elseif mode == "plen" then
        return string.format("%s (%s)", polName, enName)
    elseif mode == "enpl" then
        return string.format("%s (%s)", enName, polName)
    else
        return polName
    end
end

----------------------------------------------------------------
-- Hook: drzewko skilli (mysz)
----------------------------------------------------------------

local function HookSkillsAbilityEntry()
    if not ZO_Skills_AbilityEntry_Setup then
        return
    end

    local orig = ZO_Skills_AbilityEntry_Setup

    ZO_Skills_AbilityEntry_Setup = function(control, skillData)
        orig(control, skillData)

        local mode = GetMode()
        if mode == "pl" then
            return
        end

        if not GetENTable() then
            return
        end

        if not control or not skillData then return end

        local spa = skillData:GetPointAllocator()
        if not spa then return end

        local spd = spa:GetProgressionData()
        if not spd then return end

        local abilityId = spd:GetAbilityId()
        if not abilityId or abilityId == 0 then return end

        local finalName = GetDisplayName(abilityId)
        local polName   = GetAbilityName(abilityId)

        local nameControl = control:GetNamedChild("Name")
        if nameControl and polName and polName ~= "" then
            local current = nameControl:GetText() or ""
            if EsoPL and EsoPL.MagicReplace then
                nameControl:SetText(EsoPL:MagicReplace(current, polName, finalName))
            else
                nameControl:SetText(finalName)
            end
        end
    end
end

----------------------------------------------------------------
-- Hook: skille kompana (mysz)
----------------------------------------------------------------

local function HookCompanionSkills()
    if not ZO_Skills_CompanionSkillEntry_Setup then
        return
    end

    local orig = ZO_Skills_CompanionSkillEntry_Setup

    ZO_Skills_CompanionSkillEntry_Setup = function(control, skillData)
        orig(control, skillData)

        local mode = GetMode()
        if mode == "pl" then
            return
        end

        if not GetENTable() then
            return
        end

        if not control or not skillData then return end

        local spa = skillData:GetPointAllocator()
        if not spa then return end

        local spd = spa:GetProgressionData()
        if not spd then return end

        local abilityId = spd:GetAbilityId()
        if not abilityId or abilityId == 0 then return end

        local finalName = GetDisplayName(abilityId)
        local polName   = GetAbilityName(abilityId)

        local nameControl = control:GetNamedChild("Name")
        if nameControl and polName and polName ~= "" then
            local current = nameControl:GetText() or ""
            if EsoPL and EsoPL.MagicReplace then
                nameControl:SetText(EsoPL:MagicReplace(current, polName, finalName))
            else
                nameControl:SetText(finalName)
            end
        end
    end
end

----------------------------------------------------------------
-- Hook: gamepad – GetName / GetFormattedName
----------------------------------------------------------------

local function HookGamepadNames()
    if not ZO_SkillProgressionData_Base or not ZO_SkillProgressionData_Base.GetName then
        return
    end

    local oldGetName          = ZO_SkillProgressionData_Base.GetName
    local oldGetFormattedName = ZO_SkillProgressionData_Base.GetFormattedName

    function ZO_SkillProgressionData_Base:GetName()
        local mode = GetMode()
        if not IsInGamepadPreferredMode() or mode == "pl" then
            return oldGetName(self)
        end

        if not GetENTable() then
            return oldGetName(self)
        end

        local abilityId = self:GetAbilityId()
        if abilityId and abilityId ~= 0 then
            return GetDisplayName(abilityId)
        end

        return oldGetName(self)
    end

    if oldGetFormattedName then
        function ZO_SkillProgressionData_Base:GetFormattedName(formatter)
            local mode = GetMode()
            if not IsInGamepadPreferredMode() or mode == "pl" then
                return oldGetFormattedName(self, formatter)
            end

            if not GetENTable() then
                return oldGetFormattedName(self, formatter)
            end

            local abilityId = self:GetAbilityId()
            if abilityId and abilityId ~= 0 then
                local finalName = GetDisplayName(abilityId)
                return ZO_CachedStrFormat(formatter or SI_ABILITY_NAME, finalName)
            end

            return oldGetFormattedName(self, formatter)
        end
    end
end

----------------------------------------------------------------
-- API modułu – wywoływane z EsoPL.lua
----------------------------------------------------------------

function EsoPL.InitAbilities()
    HookSkillsAbilityEntry()
    HookCompanionSkills()
    HookGamepadNames()
    d(ADDON_NAME .. ": moduł skilli zainicjalizowany (czyta z EsoPL_SkillDB_EN.Abilities).")
end