BSCWizardsPlugin = BSCWizardsPlugin or {}
local BSCWP = BSCWizardsPlugin
local LIB = LibBSCWizardBridge

if not LIB then return end

BSCWP.Name = "BSCs-WizardPlugin"
BSCWP.SavedVar = "BSCWPSave"
BSCWP.VersionDisplay = "1.0.2"

local CLIENT_ID = "BSCWP_PageRespec"
local PROVIDER_KEY = "WizardsWardrobe"

local defaultSV = {
    PAGE_LINKS = {},
}

local COLOR_RED   = "FF4444"
local COLOR_BLUE  = "4D7CFF"
local COLOR_GREEN = "44CC44"
local COLOR_GREY  = "AAAAAA"


----------------------------------------------------------------------------------
-- DialogWindow
----------------------------------------------------------------------------------
local DIALOG_NAME = "BSCWP_GENERIC_CONFIRM"
local function SetupGenericConfirmDialog()
    ZO_Dialogs_RegisterCustomDialog(DIALOG_NAME,
    {
        canQueue = true,

        gamepadInfo =
        {
            dialogType = GAMEPAD_DIALOGS.BASIC,
        },

        title =
        {
            text = "<<1>>",
        },

        mainText =
        {
            text = "<<1>>",
        },

        buttons =
        {
            {
                keybind = "DIALOG_PRIMARY",
                text = function(dialog)
                    local data = dialog.data
                    return (data and data.confirmText) or GetString(SI_DIALOG_CONFIRM)
                end,
                callback = function(dialog)
                    local data = dialog.data
                    if data and type(data.onConfirm) == "function" then
                        data.onConfirm(data)
                    end
                end,
            },
            {
                keybind = "DIALOG_NEGATIVE",
                text = function(dialog)
                    local data = dialog.data
                    return (data and data.cancelText) or GetString(SI_DIALOG_CANCEL)
                end,
                callback = function(dialog)
                    local data = dialog.data
                    if data and type(data.onCancel) == "function" then
                        data.onCancel(data)
                    end
                end,
            },
        },
    })
end

local function ShowGenericConfirmDialog(options)
    options = options or {}

    ZO_Dialogs_ShowPlatformDialog(DIALOG_NAME,
    {
        title = options.title or "Confirm",
        mainText = options.mainText or "Do you want to continue?",
        confirmText = options.confirmText,
        cancelText = options.cancelText,
        onConfirm = options.onConfirm,
        onCancel = options.onCancel,

        -- beliebige Zusatzdaten
        Preset = options.Preset,
        slotIndex = options.slotIndex,
        customData = options.customData,
        ctx = options.ctx,
        values = options.values,
    },
    {
        titleParams = {
            options.title or "Confirm",
        },
        mainTextParams = {
            options.mainText or "Do you want to continue?",
        },
    })
end
----------------------------------------------------------------------------------
-- Helper
----------------------------------------------------------------------------------

local function SafeNumber(v)
    return tonumber(v or 0) or 0
end

local function Colorize(hex, text)
    return string.format("|c%s%s|r", tostring(hex or "FFFFFF"), tostring(text or ""))
end

local function DeepCopy(v)
    if type(v) ~= "table" then return v end
    if ZO_DeepTableCopy then
        return ZO_DeepTableCopy(v)
    end

    local out = {}
    for k, val in pairs(v) do
        out[k] = DeepCopy(val)
    end
    return out
end

local function RefreshPageEditor(delayMs)
    local provider = LIB:GetProvider(PROVIDER_KEY)
    if not provider or type(provider.RefreshPageEditor) ~= "function" then
        return
    end

    local delay = SafeNumber(delayMs)
    if delay <= 0 then
        provider:RefreshPageEditor(true)
    else
        zo_callLater(function()
            provider:RefreshPageEditor(true)
        end, delay)
    end
end

local function getStore()
    BSCWP.SV = BSCWP.SV or {}
    BSCWP.SV.PAGE_LINKS = BSCWP.SV.PAGE_LINKS or {}
    return BSCWP.SV.PAGE_LINKS
end

local function Debug(msg)
    d(string.format("[BSCWP] %s", tostring(msg or "")))
end

----------------------------------------------------------------------------------
-- Attribute
----------------------------------------------------------------------------------
local function LoadAttributePreset(targetHealth, targetMagicka, targetStamina)
    targetHealth  = SafeNumber(targetHealth)
    targetMagicka = SafeNumber(targetMagicka)
    targetStamina = SafeNumber(targetStamina)

    if targetHealth < 0 or targetMagicka < 0 or targetStamina < 0 then
        return
    end

    local curHealth  = GetAttributeSpentPoints(ATTRIBUTE_HEALTH)
    local curMagicka = GetAttributeSpentPoints(ATTRIBUTE_MAGICKA)
    local curStamina = GetAttributeSpentPoints(ATTRIBUTE_STAMINA)
    local totalCurrent = SafeNumber(curHealth) + SafeNumber(curMagicka) + SafeNumber(curStamina) + SafeNumber(GetAttributeUnspentPoints())
    local totalTarget  = targetHealth + targetMagicka + targetStamina

    if totalTarget > totalCurrent then
        return
    end

    local dHealth  = targetHealth  - curHealth
    local dMagicka = targetMagicka - curMagicka
    local dStamina = targetStamina - curStamina

    if dHealth == 0 and dMagicka == 0 and dStamina == 0 then
        return
    end

    SendAttributePointAllocationRequest(RESPEC_PAYMENT_TYPE_GOLD, dHealth, dMagicka, dStamina)
end

local function GetCurrentAttributes()
    return {
        health = SafeNumber(GetAttributeSpentPoints(ATTRIBUTE_HEALTH)),
        magicka = SafeNumber(GetAttributeSpentPoints(ATTRIBUTE_MAGICKA)),
        stamina = SafeNumber(GetAttributeSpentPoints(ATTRIBUTE_STAMINA)),
    }
end

local function NormalizeAttributes(attrs)
    if type(attrs) ~= "table" then return nil end

    local out = {
        health = SafeNumber(attrs.health),
        magicka = SafeNumber(attrs.magicka),
        stamina = SafeNumber(attrs.stamina),
    }

    if out.health < 0 or out.magicka < 0 or out.stamina < 0 then
        return nil
    end

    return out
end

local function FormatAttributesInline(attrs)
    attrs = attrs or {}
    return string.format(
        "%s %s %s",
        Colorize(COLOR_RED, SafeNumber(attrs.health)),
        Colorize(COLOR_BLUE, SafeNumber(attrs.magicka)),
        Colorize(COLOR_GREEN, SafeNumber(attrs.stamina))
    )
end

local function IsAttributesPresetEmpty(attrs)
    attrs = attrs or {}
    local h = tonumber(attrs.health or 0) or 0
    local m = tonumber(attrs.magicka or 0) or 0
    local s = tonumber(attrs.stamina or 0) or 0

    return h == 0 and m == 0 and s == 0
end

local function AreAttributesEqual(a, b)
    a = a or {}
    b = b or {}

    return (tonumber(a.health or 0) or 0) == (tonumber(b.health or 0) or 0)
       and (tonumber(a.magicka or 0) or 0) == (tonumber(b.magicka or 0) or 0)
       and (tonumber(a.stamina or 0) or 0) == (tonumber(b.stamina or 0) or 0)
end
----------------------------------------------------------------------------------
-- Skills
----------------------------------------------------------------------------------
local function TableHasValue(t, value)
    for _, v in ipairs(t) do
        if v == value then
            return true
        end
    end
    return false
end

local function IsCraftedAbilitySkillSafe(skillType, skillLineIndex, skillIndex)
    if type(IsCraftedAbilitySkill) ~= "function" then
        return false
    end
    return IsCraftedAbilitySkill(skillType, skillLineIndex, skillIndex) == true
end

local function IsSkillAbilityAutoGrantSafe(skillType, skillLineIndex, skillIndex)
    if type(IsSkillAbilityAutoGrant) ~= "function" then
        return false
    end
    return IsSkillAbilityAutoGrant(skillType, skillLineIndex, skillIndex) == true
end

local function IsClassMasterySkillLineSafe(skillLineId)
    if not skillLineId or type(IsClassMasterySkillLine) ~= "function" then
        return false
    end

    return IsClassMasterySkillLine(skillLineId) == true
end

local function GetClassMasteryCostSafe(skillLineId)
    if not skillLineId or type(GetClassMasteryCostBySkillLineId) ~= "function" then
        return 0
    end

    return SafeNumber(GetClassMasteryCostBySkillLineId(skillLineId))
end

local function GetClassMasteryPointsSafe(skillLineId)
    if not skillLineId or type(GetNumClassMasteryPointsBySkillLineId) ~= "function" then
        return 0
    end

    return SafeNumber(GetNumClassMasteryPointsBySkillLineId(skillLineId))
end

local function GetSkillLineDynamicFlagsSafe(skillType, skillLineIndex)
    if type(GetSkillLineDynamicInfo) ~= "function" then
        return false, false
    end

    local _, _, isActive, _, _, _, isClassMastery = GetSkillLineDynamicInfo(skillType, skillLineIndex)
    return isActive == true, isClassMastery == true
end

local function ShouldTrackSkill(skillType, skillLineIndex, skillIndex)
    if not skillType or not skillLineIndex or not skillIndex then
        return false
    end

    if not IsSkillAbilityPurchased(skillType, skillLineIndex, skillIndex) then
        return false
    end

    if IsCraftedAbilitySkillSafe(skillType, skillLineIndex, skillIndex) then
        return false
    end

    if IsSkillAbilityAutoGrantSafe(skillType, skillLineIndex, skillIndex) then
        return false
    end

    return true
end

local function CanReplaySkill(skillType, skillLineIndex, skillIndex)
    if not skillType or not skillLineIndex or not skillIndex then
        return false
    end

    if skillIndex < 1 or skillIndex > GetNumSkillAbilities(skillType, skillLineIndex) then
        return false
    end

    if IsCraftedAbilitySkillSafe(skillType, skillLineIndex, skillIndex) then
        return false
    end

    if IsSkillAbilityAutoGrantSafe(skillType, skillLineIndex, skillIndex) then
        return false
    end

    return true
end

local function ResolveActiveProgressionData(skillLineId, skillData)
    if type(skillData) ~= "table" then return nil end

    local skillType, skillLineIndex = GetSkillLineIndicesFromSkillLineId(skillLineId)
    if not skillType or not skillLineIndex then
        return nil
    end

    local skillIndex = SafeNumber(skillData.skillIndex)
    if skillIndex <= 0 or not CanReplaySkill(skillType, skillLineIndex, skillIndex) then
        return nil
    end

    if IsSkillAbilityPassive(skillType, skillLineIndex, skillIndex) then
        return nil
    end

    local progressionId = GetProgressionSkillProgressionId(skillType, skillLineIndex, skillIndex)
    if not progressionId or progressionId == 0 then
        return nil
    end

    local morphSlot = SafeNumber(skillData.morphSlot)
    if morphSlot == 0 then
        morphSlot = MORPH_SLOT_BASE
    end

    return progressionId, morphSlot, skillType, skillLineIndex, skillIndex
end

local function ResolvePassiveAbilityId(skillLineId, skillData)
    if type(skillData) ~= "table" then return nil end

    local skillType, skillLineIndex = GetSkillLineIndicesFromSkillLineId(skillLineId)
    if not skillType or not skillLineIndex then
        return nil
    end

    local skillIndex = SafeNumber(skillData.skillIndex)
    if skillIndex <= 0 or not CanReplaySkill(skillType, skillLineIndex, skillIndex) then
        return nil
    end

    if not IsSkillAbilityPassive(skillType, skillLineIndex, skillIndex) then
        return nil
    end

    local rank = SafeNumber(skillData.rank)
    if rank < 1 then
        rank = 1
    end

    local abilityId = select(1, GetSpecificSkillAbilityInfo(
        skillType,
        skillLineIndex,
        skillIndex,
        MORPH_SLOT_BASE,
        rank
    ))

    if not abilityId or abilityId == 0 then
        return nil
    end

    return abilityId, skillType, skillLineIndex, skillIndex, rank
end

local function AreSkillsEquivalent(currentSkill, targetSkill)
    if type(currentSkill) ~= "table" or type(targetSkill) ~= "table" then
        return false
    end

    if currentSkill.kind ~= targetSkill.kind then
        return false
    end

    if currentSkill.kind == "active" then
        return SafeNumber(currentSkill.skillIndex) == SafeNumber(targetSkill.skillIndex)
           and SafeNumber(currentSkill.morphSlot or MORPH_SLOT_BASE) == SafeNumber(targetSkill.morphSlot or MORPH_SLOT_BASE)
    end

    return SafeNumber(currentSkill.skillIndex) == SafeNumber(targetSkill.skillIndex)
       and SafeNumber(currentSkill.rank) == SafeNumber(targetSkill.rank)
end

local function AddSkillChangeForTargetState(skillLineId, currentSkill, targetSkill)
    if currentSkill and targetSkill and AreSkillsEquivalent(currentSkill, targetSkill) then
        return
    end

    if targetSkill then
        if targetSkill.kind == "active" then
            local progressionId, morphSlot = ResolveActiveProgressionData(skillLineId, targetSkill)
            if not progressionId then
                Debug(string.format("skip invalid active target on line %s", tostring(skillLineId)))
                return
            end

            AddActiveChangeToAllocationRequest(
                skillLineId,
                progressionId,
                morphSlot or MORPH_SLOT_BASE,
                true
            )
        else
            local abilityId = ResolvePassiveAbilityId(skillLineId, targetSkill)
            if not abilityId then
                Debug(string.format("skip invalid passive target on line %s", tostring(skillLineId)))
                return
            end

            AddPassiveChangeToAllocationRequest(
                skillLineId,
                abilityId,
                false
            )
        end
        return
    end

    if currentSkill then
        if currentSkill.kind == "active" then
            local progressionId, morphSlot = ResolveActiveProgressionData(skillLineId, currentSkill)
            if not progressionId then
                Debug(string.format("skip invalid active removal on line %s", tostring(skillLineId)))
                return
            end

            AddActiveChangeToAllocationRequest(
                skillLineId,
                progressionId,
                morphSlot or MORPH_SLOT_BASE,
                false
            )
        else
            local abilityId = ResolvePassiveAbilityId(skillLineId, currentSkill)
            if not abilityId then
                Debug(string.format("skip invalid passive removal on line %s", tostring(skillLineId)))
                return
            end

            AddPassiveChangeToAllocationRequest(
                skillLineId,
                abilityId,
                true
            )
        end
    end
end

function BSCWP:ApplySkillPreset(preset)
    if not preset or type(preset.lines) ~= "table" then
        return
    end

    local targetSwitchable = preset.activeSkillLineIds or {}
    local targetTracked    = preset.trackedSkillLineIds or targetSwitchable

    local currentPreset = self:GetCurrentSkillPreset()
    local currentSwitchable = currentPreset.activeSkillLineIds or {}

    local targetSwitchableSet = {}
    local currentSwitchableSet = {}

    for _, skillLineId in ipairs(targetSwitchable) do
        targetSwitchableSet[skillLineId] = true
    end

    for _, skillLineId in ipairs(currentSwitchable) do
        currentSwitchableSet[skillLineId] = true
    end

    local toDeactivate = {}
    local toActivate = {}

    for _, currentSkillLineId in ipairs(currentSwitchable) do
        if not targetSwitchableSet[currentSkillLineId] then
            table.insert(toDeactivate, currentSkillLineId)
        end
    end

    for _, targetSkillLineId in ipairs(targetSwitchable) do
        if not currentSwitchableSet[targetSkillLineId] then
            table.insert(toActivate, targetSkillLineId)
        end
    end

    StartSkillRespecFromUI()
    PrepareSkillPointAllocationRequest(SKILL_POINT_ALLOCATION_MODE_FULL, RESPEC_PAYMENT_TYPE_GOLD)

    if #toDeactivate > 0 then
        DeactivateSkillLinesInAllocationRequest(unpack(toDeactivate))
    end

    if #toActivate > 0 then
        ActivateSkillLinesInAllocationRequest(unpack(toActivate))
    end

    local unionLineIds = {}

    for _, skillLineId in ipairs(targetTracked) do
        unionLineIds[skillLineId] = true
    end

    for skillLineId in pairs(currentPreset.lines or {}) do
        if not currentSwitchableSet[skillLineId] then
            unionLineIds[skillLineId] = true
        end
    end

    for skillLineId in pairs(unionLineIds) do
        if not (currentSwitchableSet[skillLineId] and not targetSwitchableSet[skillLineId]) then
            local targetLine  = preset.lines[skillLineId] or { skills = {} }
            local currentLine = currentPreset.lines[skillLineId] or { skills = {} }

            local unionKeys = {}

            for key in pairs(currentLine.skills or {}) do
                unionKeys[key] = true
            end

            for key in pairs(targetLine.skills or {}) do
                unionKeys[key] = true
            end

            for key in pairs(unionKeys) do
                local currentSkill = currentLine.skills[key]
                local targetSkill  = targetLine.skills[key]
                AddSkillChangeForTargetState(skillLineId, currentSkill, targetSkill)
            end
        end
    end

    SendSkillPointAllocationRequest()
end

local function ReadPurchasedSkillsOfLine(skillLineId)
    local skillType, skillLineIndex = GetSkillLineIndicesFromSkillLineId(skillLineId)
    if not skillType or not skillLineIndex then
        return {}
    end

    local skills = {}

    for skillIndex = 1, GetNumSkillAbilities(skillType, skillLineIndex) do
        if ShouldTrackSkill(skillType, skillLineIndex, skillIndex) then
            if IsSkillAbilityPassive(skillType, skillLineIndex, skillIndex) then
                local rank = GetSkillAbilityUpgradeInfo(skillType, skillLineIndex, skillIndex)
                if not rank or rank < 1 then
                    rank = 1
                end

                local abilityId = select(1, GetSpecificSkillAbilityInfo(
                    skillType,
                    skillLineIndex,
                    skillIndex,
                    MORPH_SLOT_BASE,
                    rank
                ))

                if abilityId and abilityId ~= 0 then
                    skills["P:" .. tostring(skillIndex)] = {
                        kind = "passive",
                        skillIndex = skillIndex,
                        rank = rank,
                        abilityId = abilityId,
                    }
                end
            else
                local progressionId = GetProgressionSkillProgressionId(skillType, skillLineIndex, skillIndex)
                local morphSlot = GetProgressionSkillCurrentMorphSlot(progressionId)
                if not morphSlot or morphSlot == 0 then
                    morphSlot = MORPH_SLOT_BASE
                end

                if progressionId and progressionId ~= 0 then
                    skills["A:" .. tostring(skillIndex)] = {
                        kind = "active",
                        skillIndex = skillIndex,
                        progressionId = progressionId,
                        morphSlot = morphSlot,
                    }
                end
            end
        end
    end

    return skills
end

function BSCWP:GetCurrentSkillPreset()
    local preset = {
        activeSkillLineIds = {},
        trackedSkillLineIds = {},
        lines = {},
    }

    local seenTracked = {}
    local seenSwitchable = {}

    local function AddTrackedLine(skillLineId, classId, isSwitchable)
        if not skillLineId or seenTracked[skillLineId] then
            return
        end

        local skillType, skillLineIndex = GetSkillLineIndicesFromSkillLineId(skillLineId)
        if not skillType or not skillLineIndex then
            return
        end
        local isActive, isClassMastery = GetSkillLineDynamicFlagsSafe(skillType, skillLineIndex)
        isClassMastery = isClassMastery or IsClassMasterySkillLineSafe(skillLineId)

        local classMasteryPoints = isClassMastery and GetClassMasteryPointsSafe(skillLineId) or 0

        -- Normal subclassing/class lines must be active. ClassMastery is special:
        -- the line can live under SKILL_TYPE_CLASS but is not a switchable class line,
        -- and depending on API state it may not report as active. Therefore we read
        -- the selected purchased passive first and only skip it if nothing is selected.
        if not isClassMastery and not isActive then
            return
        end

        local skills = ReadPurchasedSkillsOfLine(skillLineId)
        if isClassMastery and next(skills) == nil then
            return
        end

        seenTracked[skillLineId] = true
        table.insert(preset.trackedSkillLineIds, skillLineId)

        preset.lines[skillLineId] = {
            skillLineId = skillLineId,
            classId = classId,
            isClassMastery = isClassMastery,
            classMasteryCost = isClassMastery and GetClassMasteryCostSafe(skillLineId) or 0,
            classMasteryPoints = classMasteryPoints,
            skills = skills,
        }

        -- ClassMastery is tracked for selected passives, but it is not one of the
        -- subclassing lines that should be activated/deactivated with the normal
        -- class-line switch request.
        if isSwitchable and not isClassMastery and not seenSwitchable[skillLineId] then
            seenSwitchable[skillLineId] = true
            table.insert(preset.activeSkillLineIds, skillLineId)
        end
    end

    local function ScanClass(classId)
        for classSkillLineIndex = 1, GetNumSkillLinesForClass(classId) do
            local skillLineId = GetSkillLineIdForClass(classId, classSkillLineIndex)
            AddTrackedLine(skillLineId, classId, true)
        end
    end

    local function ScanSkillLines()
        for skillType = 1, GetNumSkillTypes() do
            for skillLineIndex = 1, GetNumSkillLines(skillType) do
                local skillLineId = GetSkillLineId(skillType, skillLineIndex)

                if skillType ~= SKILL_TYPE_CLASS then
                    AddTrackedLine(skillLineId, nil, false)
                else
                    -- Do not import normal class lines a second time here; ScanClass()
                    -- already handles them. Only let ClassMastery through the class
                    -- filter, because Patch 50 exposes it below SKILL_TYPE_CLASS.
                    local _, isClassMastery = GetSkillLineDynamicFlagsSafe(skillType, skillLineIndex)
                    if isClassMastery or IsClassMasterySkillLineSafe(skillLineId) then
                        AddTrackedLine(skillLineId, nil, false)
                    end
                end
            end
        end
    end

    if HasAccessToSubclassing() then
        for classIndex = 1, GetNumClasses() do
            ScanClass(GetClassIdByIndex(classIndex))
        end
    else
        ScanClass(GetUnitClassId("player"))
    end

    ScanSkillLines()
	
    table.sort(preset.activeSkillLineIds)
    table.sort(preset.trackedSkillLineIds)

    return preset
end

local function NormalizeSkillPreset(preset)
    if type(preset) ~= "table" then return nil end
    if type(preset.activeSkillLineIds) ~= "table" then return nil end
    if type(preset.lines) ~= "table" then return nil end

    local out = DeepCopy(preset)
    out.trackedSkillLineIds = type(out.trackedSkillLineIds) == "table" and out.trackedSkillLineIds or DeepCopy(out.activeSkillLineIds)

    return out
end

local function AreIdListsEqualAsSet(a, b)
    a = type(a) == "table" and a or {}
    b = type(b) == "table" and b or {}

    local setA = {}
    local setB = {}

    for _, id in ipairs(a) do
        setA[SafeNumber(id)] = true
    end

    for _, id in ipairs(b) do
        setB[SafeNumber(id)] = true
    end

    for id in pairs(setA) do
        if not setB[id] then
            return false
        end
    end

    for id in pairs(setB) do
        if not setA[id] then
            return false
        end
    end

    return true
end

local function NormalizeSkillEntry(skill)
    if type(skill) ~= "table" then
        return nil
    end

    local kind = tostring(skill.kind or "")
    if kind == "active" then
        return {
            kind = "active",
            skillIndex = SafeNumber(skill.skillIndex),
            progressionId = SafeNumber(skill.progressionId),
            morphSlot = SafeNumber(skill.morphSlot),
        }
    elseif kind == "passive" then
        return {
            kind = "passive",
            skillIndex = SafeNumber(skill.skillIndex),
            abilityId = SafeNumber(skill.abilityId),
            rank = SafeNumber(skill.rank),
        }
    end

    return nil
end

local function AreSkillEntriesEqual(a, b)
    a = NormalizeSkillEntry(a)
    b = NormalizeSkillEntry(b)

    if a == nil and b == nil then
        return true
    end

    if a == nil or b == nil then
        return false
    end

    if a.kind ~= b.kind then
        return false
    end

    if a.kind == "active" then
        return a.skillIndex == b.skillIndex
           and a.progressionId == b.progressionId
           and a.morphSlot == b.morphSlot
    end

    return a.skillIndex == b.skillIndex
       and a.abilityId == b.abilityId
       and a.rank == b.rank
end

local function AreSkillMapsEqual(aSkills, bSkills)
    aSkills = type(aSkills) == "table" and aSkills or {}
    bSkills = type(bSkills) == "table" and bSkills or {}

    for key, aSkill in pairs(aSkills) do
        if not AreSkillEntriesEqual(aSkill, bSkills[key]) then
            return false
        end
    end

    for key, bSkill in pairs(bSkills) do
        if not AreSkillEntriesEqual(aSkills[key], bSkill) then
            return false
        end
    end

    return true
end

local function AreSkillLinesEqual(aLines, bLines)
    aLines = type(aLines) == "table" and aLines or {}
    bLines = type(bLines) == "table" and bLines or {}

    for skillLineId, aLine in pairs(aLines) do
        local bLine = bLines[skillLineId]
        if type(bLine) ~= "table" then
            return false
        end

        if not AreSkillMapsEqual(aLine.skills, bLine.skills) then
            return false
        end
    end

    for skillLineId in pairs(bLines) do
        if type(aLines[skillLineId]) ~= "table" then
            return false
        end
    end

    return true
end

local function AreSkillPresetsEqual(currentPreset, savedPreset)
    currentPreset = NormalizeSkillPreset(currentPreset)
    savedPreset = NormalizeSkillPreset(savedPreset)

    if currentPreset == nil and savedPreset == nil then
        return true
    end

    if currentPreset == nil or savedPreset == nil then
        return false
    end

    if not AreIdListsEqualAsSet(currentPreset.activeSkillLineIds, savedPreset.activeSkillLineIds) then
        return false
    end

    if not AreIdListsEqualAsSet(currentPreset.trackedSkillLineIds, savedPreset.trackedSkillLineIds) then
        return false
    end

    if not AreSkillLinesEqual(currentPreset.lines, savedPreset.lines) then
        return false
    end

    return true
end

local function IsSkillPresetEmpty(preset)
    preset = NormalizeSkillPreset(preset)
    if preset == nil then
        return true
    end

    if type(preset.lines) ~= "table" then
        return true
    end

    for _, lineData in pairs(preset.lines) do
        if type(lineData) == "table" and type(lineData.skills) == "table" and next(lineData.skills) ~= nil then
            return false
        end
    end

    return true
end

local function GetSkillLineNameSafe(skillLineId)
    if not skillLineId then
        return "Unknown"
    end

    local name = GetSkillLineNameById(skillLineId)
    if name and name ~= "" then
        return zo_strformat("<<1>>", name)
    end

    return string.format("SkillLine %s", tostring(skillLineId))
end

local function BuildSkillLineListText(skillLineIds)
    if type(skillLineIds) ~= "table" or #skillLineIds == 0 then
        return Colorize(COLOR_GREY, "none")
    end

    local parts = {}
    for i = 1, #skillLineIds do
		if SKILL_TYPE_CLASS == GetSkillLineIndicesFromSkillLineId(skillLineIds[i]) then
			parts[#parts + 1] = GetSkillLineNameSafe(skillLineIds[i])
		end
    end

    return table.concat(parts, ", ")
end

local function CountPurchasedSkillsInPreset(preset)
    if type(preset) ~= "table" or type(preset.lines) ~= "table" then
        return 0
    end

    local count = 0
    for _, lineData in pairs(preset.lines) do
        if type(lineData) == "table" and type(lineData.skills) == "table" then
            for _ in pairs(lineData.skills) do
                count = count + 1
            end
        end
    end
    return count
end

local function BuildSkillSummary(prefix, preset)
    if type(preset) ~= "table" then
        return string.format("%s %s", tostring(prefix or ""), Colorize(COLOR_GREY, "none"))
    end

    local lineIds = preset.trackedSkillLineIds or preset.activeSkillLineIds or {}
    local lineCount = #lineIds
    local skillCount = CountPurchasedSkillsInPreset(preset)
    local linesText = BuildSkillLineListText(lineIds)

    return string.format(
        "%s %s |cFFFFFF(%d lines / %d skills)|r",
        tostring(prefix or ""),
        linesText,
        lineCount,
        skillCount
    )
end

local function GetSkillDisplayNameSafe(skillLineId, skillData)
    if type(skillData) ~= "table" then
        return "Unknown"
    end

    local skillType, skillLineIndex = GetSkillLineIndicesFromSkillLineId(skillLineId)
    local skillIndex = SafeNumber(skillData.skillIndex)
    if not skillType or not skillLineIndex or skillIndex <= 0 then
        return string.format("Skill %s", tostring(skillIndex))
    end

    local function CleanName(name)
        if name and name ~= "" then
            return zo_strformat("<<1>>", name)
        end
        return nil
    end

    local function ResolveAbilityName(abilityId)
        if abilityId and abilityId ~= 0 then
            local resolved = CleanName(GetAbilityName(abilityId))
            if resolved then
                return resolved
            end
        end
        return nil
    end

    local baseName = CleanName(select(1, GetSkillAbilityInfo(skillType, skillLineIndex, skillIndex)))

    if tostring(skillData.kind) == "active" then
        local progressionId = SafeNumber(skillData.progressionId)
        local morphSlot = SafeNumber(skillData.morphSlot)
        if morphSlot == 0 then
            morphSlot = MORPH_SLOT_BASE
        end

        local abilityId = nil
        if progressionId > 0 then
            abilityId = GetProgressionSkillMorphSlotAbilityId(progressionId, morphSlot)
        end

        if not abilityId or abilityId == 0 then
            local rank = GetSkillLineProgressionAbilityRank(skillType, skillLineIndex, skillIndex, morphSlot)
            if not rank or rank < 1 then
                rank = 1
            end
            abilityId = select(1, GetSpecificSkillAbilityInfo(skillType, skillLineIndex, skillIndex, morphSlot, rank))
        end

        local morphName = ResolveAbilityName(abilityId)
        if morphName then
            return morphName
        end

        local progressionName = CleanName(GetProgressionSkillProgressionName(skillType, skillLineIndex, skillIndex))
        if progressionName then
            return progressionName
        end

        if baseName then
            return baseName
        end

        return string.format("Active Skill %d", skillIndex)
    end

    local passiveAbilityId = SafeNumber(skillData.abilityId)
    local passiveName = ResolveAbilityName(passiveAbilityId)
    if passiveName then
        return passiveName
    end

    local rank = SafeNumber(skillData.rank)
    if rank < 1 then
        rank = 1
    end

    local specificAbilityId = select(1, GetSpecificSkillAbilityInfo(skillType, skillLineIndex, skillIndex, MORPH_SLOT_BASE, rank))
    local rankedName = ResolveAbilityName(specificAbilityId)
    if rankedName then
        return rankedName
    end

    if baseName then
        return baseName
    end

    return string.format("Passive Skill %d", skillIndex)
end

local function IsClassMasteryLineData(skillLineId, lineData)
    if type(lineData) == "table" and lineData.isClassMastery == true then
        return true
    end

    return IsClassMasterySkillLineSafe(SafeNumber(skillLineId))
end

local function GetClassMasterySelectedLines(preset)
    preset = NormalizeSkillPreset(preset)
    local selectedLines = {}

    if preset == nil or type(preset.lines) ~= "table" then
        return selectedLines
    end

    for skillLineId, lineData in pairs(preset.lines) do
        if type(lineData) == "table" and IsClassMasteryLineData(skillLineId, lineData) then
            local selectedSkills = {}

            for _, skillData in pairs(lineData.skills or {}) do
                if type(skillData) == "table" and tostring(skillData.kind) == "passive" then
                    selectedSkills[#selectedSkills + 1] = skillData
                end
            end

            table.sort(selectedSkills, function(a, b)
                local aIndex = SafeNumber(a and a.skillIndex)
                local bIndex = SafeNumber(b and b.skillIndex)
                if aIndex ~= bIndex then
                    return aIndex < bIndex
                end

                return SafeNumber(a and a.abilityId) < SafeNumber(b and b.abilityId)
            end)

            if #selectedSkills > 0 then
                selectedLines[#selectedLines + 1] = {
                    skillLineId = SafeNumber(skillLineId),
                    classId = lineData.classId,
                    classMasteryCost = SafeNumber(lineData.classMasteryCost),
                    classMasteryPoints = SafeNumber(lineData.classMasteryPoints),
                    skills = selectedSkills,
                }
            end
        end
    end

    table.sort(selectedLines, function(a, b)
        local aName = GetSkillLineNameSafe(a.skillLineId)
        local bName = GetSkillLineNameSafe(b.skillLineId)
        if aName ~= bName then
            return aName < bName
        end

        return SafeNumber(a.skillLineId) < SafeNumber(b.skillLineId)
    end)

    return selectedLines
end

local function IsClassMasteryPresetEmpty(preset)
    return #GetClassMasterySelectedLines(preset) == 0
end

local function BuildClassMasterySummary(prefix, preset)
    local selectedLines = GetClassMasterySelectedLines(preset)
    if #selectedLines == 0 then
        return string.format("%s %s", tostring(prefix or "ClassMastery:"), Colorize(COLOR_GREY, "none"))
    end

    local lineParts = {}
    for _, lineData in ipairs(selectedLines) do
        local skillNames = {}
        for _, skillData in ipairs(lineData.skills or {}) do
            skillNames[#skillNames + 1] = GetSkillDisplayNameSafe(lineData.skillLineId, skillData)
        end

        if #skillNames == 0 then
            skillNames[#skillNames + 1] = Colorize(COLOR_GREY, "none selected")
        end

        lineParts[#lineParts + 1] = string.format(
            "%s: %s",
            GetSkillLineNameSafe(lineData.skillLineId),
            table.concat(skillNames, ", ")
        )
    end

    return string.format("%s %s", tostring(prefix or "ClassMastery:"), table.concat(lineParts, "  "))
end

local function BuildClassMasteryCompareMap(preset)
    local map = {}
    local selectedLines = GetClassMasterySelectedLines(preset)

    for _, lineData in ipairs(selectedLines) do
        for _, skillData in ipairs(lineData.skills or {}) do
            local key = string.format(
                "%d:%d",
                SafeNumber(lineData.skillLineId),
                SafeNumber(skillData.skillIndex)
            )

            map[key] = string.format(
                "%d:%d",
                SafeNumber(skillData.abilityId),
                SafeNumber(skillData.rank)
            )
        end
    end

    return map
end

local function AreClassMasteryPresetsEqual(a, b)
    local mapA = BuildClassMasteryCompareMap(a)
    local mapB = BuildClassMasteryCompareMap(b)

    for key, value in pairs(mapA) do
        if mapB[key] ~= value then
            return false
        end
    end

    for key, value in pairs(mapB) do
        if mapA[key] ~= value then
            return false
        end
    end

    return true
end

local function BuildClassMasteryDiffTooltip(currentPreset, preset)
    local parts = {}
    parts[#parts + 1] = BuildClassMasterySummary("Current ", currentPreset)
    parts[#parts + 1] = BuildClassMasterySummary("Preset ", preset)

    if AreClassMasteryPresetsEqual(currentPreset, preset) then
        parts[#parts + 1] = ""
        parts[#parts + 1] = Colorize(COLOR_GREEN, "No ClassMastery differences.")
    end

    return table.concat(parts, "\n")
end

local function BuildClassMasterySnapshot(preset)
    local selectedLines = GetClassMasterySelectedLines(preset)
    if #selectedLines == 0 then
        return nil
    end

    local snapshot = {
        lines = {},
    }

    for _, lineData in ipairs(selectedLines) do
        snapshot.lines[lineData.skillLineId] = {
            skillLineId = lineData.skillLineId,
            classId = lineData.classId,
            name = GetSkillLineNameSafe(lineData.skillLineId),
            classMasteryCost = lineData.classMasteryCost,
            classMasteryPoints = lineData.classMasteryPoints,
            skills = DeepCopy(lineData.skills or {}),
        }
    end

    return snapshot
end

local function GetSkillEntryLabel(skillData)
    if type(skillData) ~= "table" then
        return "Skill"
    end

    local skillIndex = SafeNumber(skillData.skillIndex)
    local prefix = tostring(skillData.kind) == "passive" and "Passive" or "Active"
    return string.format("%s", prefix)
end

local function BuildSortedIdListFromSet(idSet)
    local out = {}
    for id in pairs(idSet or {}) do
        out[#out + 1] = SafeNumber(id)
    end
    table.sort(out)
    return out
end

local function BuildSkillDiffTooltip(currentPreset, preset)
    currentPreset = NormalizeSkillPreset(currentPreset)
    preset = NormalizeSkillPreset(preset)

    local parts = {}
    parts[#parts + 1] = BuildSkillSummary("Current Skills:", currentPreset)
    parts[#parts + 1] = BuildSkillSummary("Preset Skills:", preset)

    if currentPreset == nil and preset == nil then
        return table.concat(parts, "\n")
    end

    if currentPreset == nil then
        parts[#parts + 1] = ""
        parts[#parts + 1] = Colorize(COLOR_RED, "Current skill state unavailable.")
        return table.concat(parts, "\n")
    end

    if preset == nil or IsSkillPresetEmpty(preset) then
        parts[#parts + 1] = ""
        parts[#parts + 1] = Colorize(COLOR_GREY, "No saved preset skills.")
        return table.concat(parts, "\n")
    end

    local currentLineSet = {}
    local presetLineSet = {}
    for _, lineId in ipairs(currentPreset.trackedSkillLineIds or currentPreset.activeSkillLineIds or {}) do
        currentLineSet[SafeNumber(lineId)] = true
    end
    for _, lineId in ipairs(preset.trackedSkillLineIds or preset.activeSkillLineIds or {}) do
        presetLineSet[SafeNumber(lineId)] = true
    end

    local currentOnlySet = {}
    local presetOnlySet = {}
    local sharedLineSet = {}

    for lineId in pairs(currentLineSet) do
        if presetLineSet[lineId] then
            sharedLineSet[lineId] = true
        else
            currentOnlySet[lineId] = true
        end
    end
    for lineId in pairs(presetLineSet) do
        if not currentLineSet[lineId] then
            presetOnlySet[lineId] = true
        end
    end

    local currentOnly = BuildSortedIdListFromSet(currentOnlySet)
    local presetOnly = BuildSortedIdListFromSet(presetOnlySet)
    local sharedLines = BuildSortedIdListFromSet(sharedLineSet)

    if #currentOnly > 0 or #presetOnly > 0 then
        parts[#parts + 1] = ""
        parts[#parts + 1] = "|cFFFFFFDifferent skill lines:|r"
        if #currentOnly > 0 then
            parts[#parts + 1] = string.format("- Current only: %s", table.concat((function(ids)
                local names = {}
                for i = 1, #ids do
                    names[#names + 1] = GetSkillLineNameSafe(ids[i])
                end
                return names
            end)(currentOnly), ", "))
        end
        if #presetOnly > 0 then
            parts[#parts + 1] = string.format("- Preset only: %s", table.concat((function(ids)
                local names = {}
                for i = 1, #ids do
                    names[#names + 1] = GetSkillLineNameSafe(ids[i])
                end
                return names
            end)(presetOnly), ", "))
        end
    end

    local skillDiffLines = {}
    for _, lineId in ipairs(sharedLines) do
        local currentLine = type(currentPreset.lines[lineId]) == "table" and currentPreset.lines[lineId] or { skills = {} }
        local presetLine = type(preset.lines[lineId]) == "table" and preset.lines[lineId] or { skills = {} }

        local allKeys = {}
        for key in pairs(currentLine.skills or {}) do
            allKeys[key] = true
        end
        for key in pairs(presetLine.skills or {}) do
            allKeys[key] = true
        end

        local sortedKeys = {}
        for key in pairs(allKeys) do
            sortedKeys[#sortedKeys + 1] = key
        end
        table.sort(sortedKeys, function(a, b)
            local aPrefix, aIndex = tostring(a):match("^(%u):(%d+)$")
            local bPrefix, bIndex = tostring(b):match("^(%u):(%d+)$")
            local aWeight = (aPrefix == "A" and 1) or (aPrefix == "P" and 2) or 3
            local bWeight = (bPrefix == "A" and 1) or (bPrefix == "P" and 2) or 3
            if aWeight ~= bWeight then
                return aWeight < bWeight
            end
            aIndex = tonumber(aIndex) or 9999
            bIndex = tonumber(bIndex) or 9999
            if aIndex ~= bIndex then
                return aIndex < bIndex
            end
            return tostring(a) < tostring(b)
        end)

        local lineParts = {}
        for _, key in ipairs(sortedKeys) do
            local currentSkill = currentLine.skills and currentLine.skills[key] or nil
            local presetSkill = presetLine.skills and presetLine.skills[key] or nil
            if not AreSkillEntriesEqual(currentSkill, presetSkill) then
                local label = GetSkillEntryLabel(currentSkill or presetSkill)
                local currentName = currentSkill and GetSkillDisplayNameSafe(lineId, currentSkill) or Colorize(COLOR_GREY, "none")
                local presetName = presetSkill and GetSkillDisplayNameSafe(lineId, presetSkill) or Colorize(COLOR_GREY, "none")
                lineParts[#lineParts + 1] = string.format("  - %s: %s -> %s", label, currentName, presetName)
            end
        end

        if #lineParts > 0 then
            skillDiffLines[#skillDiffLines + 1] = string.format("|cFFFFFF%s|r", GetSkillLineNameSafe(lineId))
            for i = 1, #lineParts do
                skillDiffLines[#skillDiffLines + 1] = lineParts[i]
            end
        end
    end

    if #skillDiffLines > 0 then
        parts[#parts + 1] = ""
        parts[#parts + 1] = "|cFFFFFFDifferent skills in matching lines:|r"
        for i = 1, #skillDiffLines do
            parts[#parts + 1] = skillDiffLines[i]
        end
    end

    if #currentOnly == 0 and #presetOnly == 0 and #skillDiffLines == 0 then
        parts[#parts + 1] = ""
        parts[#parts + 1] = Colorize(COLOR_GREEN, "No differences.")
    end

    return table.concat(parts, "\n")
end

----------------------------------------------------------------------------------
-- Get Active Mundus Stones
----------------------------------------------------------------------------------
local function GetCurrentMundusStones()
    local result = {}
    local activeMundusStoneBuffIndices = { GetUnitActiveMundusStoneBuffIndices("player") }
    local numActiveMundusStoneBuffs = #activeMundusStoneBuffIndices
    local numMundusSlots = GetNumAvailableMundusStoneSlots()

    for i = 1, numMundusSlots do
        if numActiveMundusStoneBuffs >= i then
            local buffName, _, _, _, _, _, _, _, _, _, abilityId = GetUnitBuffInfo("player", activeMundusStoneBuffIndices[i])
            local mundusStoneIndex = GetAbilityMundusStoneType(abilityId)

            result[i] = {
				abilityId = abilityId,
				mundusStoneIndex = mundusStoneIndex,
                name = zo_strformat(SI_STATS_MUNDUS_FORMATTER, buffName),
                icon = ZO_STAT_MUNDUS_ICONS[mundusStoneIndex],
            }	
		elseif numMundusSlots >= i then			
            result[i] = {
				abilityId = 0,
				mundusStoneIndex = 0,
                name = GetString("SI_MUNDUSSTONE", MUNDUS_STONE_INVALID),
                icon = ZO_STAT_MUNDUS_ICONS[MUNDUS_STONE_INVALID],
			}
        end
    end

    return result
end
local function FormatMundusInline(mundus)
    if not mundus then
        return "Mundus |cAAAAAANone|r"
    end

    local icon = mundus.icon or "/esoui/art/icons/ability_mundusstones_001.dds"
    local name = mundus.name or "Unknown"

    return string.format("|t20:20:%s|t %s", icon, name)
end
local function FormatMundusListInline(mundusList)
    if type(mundusList) ~= "table" or next(mundusList) == nil then
        return "Mundus |cAAAAAANone|r"
    end

    local parts = {}
    for i = 1, #mundusList do
        local mundus = mundusList[i]
        if mundus then
            parts[#parts + 1] = FormatMundusInline(mundus)
        end
    end

    return table.concat(parts, "  ")
end
local function AreMundusStonesEqual(a, b)
    a = type(a) == "table" and a or {}
    b = type(b) == "table" and b or {}

    local maxSlots = math.max(#a, #b, GetNumAvailableMundusStoneSlots() or 0)

    for i = 1, maxSlots do
        local ma = a[i] or {}
        local mb = b[i] or {}

        local aStone = tonumber(ma.mundusStoneIndex or 0) or 0
        local bStone = tonumber(mb.mundusStoneIndex or 0) or 0

        local aAbility = tonumber(ma.abilityId or 0) or 0
        local bAbility = tonumber(mb.abilityId or 0) or 0

        if aStone ~= bStone then
            return false
        end

        if aAbility ~= bAbility then
            return false
        end
    end

    return true
end
local function IsMundusPresetEmpty(mundusList)
    if type(mundusList) ~= "table" or next(mundusList) == nil then
        return true
    end

    for i = 1, #mundusList do
        local mundus = mundusList[i]
        if mundus then
            local stoneIndex = tonumber(mundus.mundusStoneIndex or 0) or 0
            local abilityId = tonumber(mundus.abilityId or 0) or 0

            if stoneIndex ~= 0 or abilityId ~= 0 then
                return false
            end
        end
    end

    return true
end
----------------------------------------------------------------------------------
-- Lib Client Helper
----------------------------------------------------------------------------------
local function GetStoredPayload(context)
    return LIB:GetPayload(CLIENT_ID, PROVIDER_KEY, context) or {}
end

local function SaveAttributesToPage(context, payload)
    payload = type(payload) == "table" and payload or GetStoredPayload(context)
    payload.attributes = GetCurrentAttributes()
	payload.mundusStones = DeepCopy(GetCurrentMundusStones())

    LIB:SetPayload(CLIENT_ID, PROVIDER_KEY, context, payload)
    RefreshPageEditor(0)
end

local function LoadAttributesFromPage(context, payload)
    payload = type(payload) == "table" and payload or GetStoredPayload(context)
    local attrs = NormalizeAttributes(payload.attributes)
    if not attrs then return end

    LoadAttributePreset(attrs.health, attrs.magicka, attrs.stamina)
    --RefreshPageEditor(750)
end

local function SaveSkillsToPage(context, payload)
    payload = type(payload) == "table" and payload or GetStoredPayload(context)

    local currentSkillPreset = BSCWP:GetCurrentSkillPreset()
    payload.classSkills = DeepCopy(currentSkillPreset)
    payload.classMastery = BuildClassMasterySnapshot(currentSkillPreset)
	payload.CurseType = GetPlayerCurseType()
	payload.mundusStones = DeepCopy(GetCurrentMundusStones())

    LIB:SetPayload(CLIENT_ID, PROVIDER_KEY, context, payload)
    RefreshPageEditor(0)
end

local function LoadSkillsFromPage(context, payload)
    payload = type(payload) == "table" and payload or GetStoredPayload(context)
    local preset = NormalizeSkillPreset(payload.classSkills)
    if not preset then return end

    BSCWP:ApplySkillPreset(preset)
    --RefreshPageEditor(1000)
end

local function SaveAllToPage(context, payload)
    payload = type(payload) == "table" and payload or GetStoredPayload(context)

    local currentSkillPreset = BSCWP:GetCurrentSkillPreset()
    payload.attributes = GetCurrentAttributes()
    payload.classSkills = DeepCopy(currentSkillPreset)
    payload.classMastery = BuildClassMasterySnapshot(currentSkillPreset)
	payload.CurseType = GetPlayerCurseType()
	payload.mundusStones = DeepCopy(GetCurrentMundusStones())

    LIB:SetPayload(CLIENT_ID, PROVIDER_KEY, context, payload)
    RefreshPageEditor(0)
end


local function HasSavedAttributesOrSkills(payload)
    payload = type(payload) == "table" and payload or {}

    local hasAttributes = not IsAttributesPresetEmpty(payload.attributes)
    local hasSkills = not IsSkillPresetEmpty(NormalizeSkillPreset(payload.classSkills))
    local hasClassMastery = not IsClassMasteryPresetEmpty(NormalizeSkillPreset(payload.classSkills))

    return hasAttributes or hasSkills or hasClassMastery, hasAttributes, hasSkills
end

local function IsSaveAllUnchanged(payload)
    payload = type(payload) == "table" and payload or {}

    local currentAttrs = GetCurrentAttributes()
    local currentPreset = BSCWP:GetCurrentSkillPreset()
    local currentCurseType = GetPlayerCurseType()
    local currentMundus = GetCurrentMundusStones()

    local savedPreset = NormalizeSkillPreset(payload.classSkills)
    local savedCurseType = payload.CurseType or CURSE_TYPE_NONE
    local savedMundus = payload.mundusStones

    return AreAttributesEqual(currentAttrs, payload.attributes)
       and AreSkillPresetsEqual(currentPreset, savedPreset)
       and AreClassMasteryPresetsEqual(currentPreset, savedPreset)
       and SafeNumber(savedCurseType) == SafeNumber(currentCurseType)
       and AreMundusStonesEqual(currentMundus, savedMundus)
end

local function HasAnythingSavedForPage(context)
    local payload = GetStoredPayload(context)

    local hasAttributes = not IsAttributesPresetEmpty(payload and payload.attributes)
    local hasSkills = not IsSkillPresetEmpty(payload and payload.classSkills)
    local hasClassMastery = not IsClassMasteryPresetEmpty(payload and payload.classSkills)
    local hasMundus = not IsMundusPresetEmpty(payload and payload.mundusStones)

    local hasCurse = false
    if payload then
        local curseType = payload.CurseType
        if curseType == nil then
            curseType = payload.curseType
        end
        hasCurse = tonumber(curseType or 0) ~= 0
    end

    return hasAttributes or hasSkills or hasClassMastery or hasMundus or hasCurse
end

local function ClearPagePresets(context)
    if not context or not context.zoneTag or not context.pageId then
        return false
    end

    LIB:DeletePayload(CLIENT_ID, PROVIDER_KEY, context)
    RefreshPageEditor(0)
    return true
end

local function normalizePayload(payload)
    if type(payload) ~= "table" then
        return nil
    end

    local out = {}

    local attrs = NormalizeAttributes(payload.attributes)
    if attrs then
        out.attributes = attrs
    end

    local preset = NormalizeSkillPreset(payload.classSkills)
    if preset then
        out.classSkills = preset
        out.classMastery = BuildClassMasterySnapshot(preset)
    elseif type(payload.classMastery) == "table" then
        out.classMastery = DeepCopy(payload.classMastery)
    end

    if payload.CurseType ~= nil then
        out.CurseType = SafeNumber(payload.CurseType)
    end

    if type(payload.mundusStones) == "table" then
        out.mundusStones = DeepCopy(payload.mundusStones)
    end
	
    if next(out) == nil then
        return nil
    end

    return out
end

local function getEditorFields(context, payload)
    payload = payload or {}

    return {	
        {
			type = "label",
			key = "CurrentMundusLabel",
			reference = "CurrentMundusLabel",
			text = function(_, values)
				local mundusList = values and values.mundusStones or payload.mundusStones
				local currentM = GetCurrentMundusStones()
				
				if IsMundusPresetEmpty(currentM) then 
					return Colorize(COLOR_GREY, "Current Mundus: " .. FormatMundusListInline(currentM))
				elseif AreMundusStonesEqual(mundusList, currentM)  then
					return Colorize(COLOR_GREEN, "Current Mundus: " .. FormatMundusListInline(currentM))
				else
					return Colorize(COLOR_RED, "Current Mundus: " .. FormatMundusListInline(currentM))
				end
			end,
		},
		{
			type = "label",
			key = "PresetMundusLabel",
			reference = "PresetMundusLabel",
			text = function(_, values)
				local mundusList = values and values.mundusStones or payload.mundusStones
				
				if IsMundusPresetEmpty(mundusList) then 
					return Colorize(COLOR_GREY, "Preset Mundus: " .. FormatMundusListInline(mundusList))
				elseif AreMundusStonesEqual(mundusList, GetCurrentMundusStones())  then
					return Colorize(COLOR_GREEN, "Preset Mundus: " .. FormatMundusListInline(mundusList))
				else
					return Colorize(COLOR_RED, "Preset Mundus: " .. FormatMundusListInline(mundusList))
				end
			end,
		},
        {
            type = "spacer",
            key = "Divider",
        },
        {
            type = "label",
            key = "CurrentCurseTypeLabel",
            reference = "CurrentCurseTypeLabel",
            text = function(_, values)
				local CType = values and values.CurseType or payload.CurseType or CURSE_TYPE_NONE
				local CCType = GetPlayerCurseType()
				
				if CType == CCType then
					return Colorize(COLOR_GREEN, zo_strformat("Current Curse: <<1>>", GetString("SI_CURSETYPE", CCType)))
				--elseif CType == CURSE_TYPE_NONE then					
				else
					return Colorize(COLOR_RED, zo_strformat("Current Curse: <<1>>", GetString("SI_CURSETYPE", CCType)))
				end                
            end,
        },
        {
            type = "label",
            key = "PresetCurseTypeLabel",
            reference = "PresetCurseTypeLabel",
            text = function(_, values)
				local CType = values and values.CurseType or payload.CurseType or CURSE_TYPE_NONE
				local CCType = GetPlayerCurseType()
				
				--if CType == CURSE_TYPE_NONE then
				--	return Colorize(COLOR_GREY, zo_strformat("Preset Curse: <<1>>", GetString("SI_CURSETYPE", CType)))
				if CType == CCType then
					return Colorize(COLOR_GREEN, zo_strformat("Preset Curse: <<1>>", GetString("SI_CURSETYPE", CType)))
				else 
					return Colorize(COLOR_RED, zo_strformat("Preset Curse: <<1>>", GetString("SI_CURSETYPE", CType)))
				end
            end,
        },
        {
            type = "spacer",
            key = "Divider0",
        },
        {
            type = "label",
            key = "CurrentAttributesLabel",
            reference = "CurrentAttributesLabel",
            text = function(ctx, values)
				local currentAttrs = GetCurrentAttributes()
				local payload = GetStoredPayload(ctx)
				local presetAttrs = payload and payload.attributes or nil
				if AreAttributesEqual(currentAttrs, presetAttrs) then
					return Colorize(COLOR_GREEN, "Current Attributes: ") .. FormatAttributesInline(currentAttrs)
				else
					return Colorize(COLOR_RED, "Current Attributes: ") .. FormatAttributesInline(currentAttrs)
				end
            end,
            width = "half",
        },
        {
            type = "button",
            key = "SaveAttributesButton",
            text = "Save Attributes",
            width = "half",
			onClick = function(ctx, values)
				local currentAttrs = GetCurrentAttributes()
				local payload = GetStoredPayload(ctx)
				local presetAttrs = payload and payload.attributes or nil

				-- Wenn aktueller Stand und Preset identisch sind: nichts tun
				if AreAttributesEqual(currentAttrs, presetAttrs) then
					return
				end

				-- Wenn schon etwas anderes gespeichert ist: nachfragen
				if not IsAttributesPresetEmpty(presetAttrs) then
					ShowGenericConfirmDialog({
						title = "Overwrite Attributes?",
						mainText = string.format(
							"Preset: %d / %d / %d\nCurrent: %d / %d / %d\n\nDo you want to overwrite the saved attributes?",
							tonumber(presetAttrs.health or 0) or 0,
							tonumber(presetAttrs.magicka or 0) or 0,
							tonumber(presetAttrs.stamina or 0) or 0,
							tonumber(currentAttrs.health or 0) or 0,
							tonumber(currentAttrs.magicka or 0) or 0,
							tonumber(currentAttrs.stamina or 0) or 0
						),
						confirmText = "Overwrite",
						cancelText = "Cancel",
						ctx = ctx,
						values = values,
						onConfirm = function(data)
							SaveAttributesToPage(data.ctx, data.values)
						end,
					})
					return
				end

				-- Wenn leer: direkt speichern
				SaveAttributesToPage(ctx, values)
			end,
        },
        {
            type = "label",
            key = "PresetAttributesLabel",
            text = function(_, values)
				local currentAttrs = GetCurrentAttributes()
                local attrs = NormalizeAttributes(values and values.attributes) or NormalizeAttributes(payload.attributes) or {}
				
				if IsAttributesPresetEmpty(attrs) then
					return Colorize(COLOR_GREY, "Preset Attributes: ") .. FormatAttributesInline(attrs)
				elseif AreAttributesEqual(currentAttrs, attrs) then
					return Colorize(COLOR_GREEN, "Preset Attributes: ") .. FormatAttributesInline(attrs)
				else
					return Colorize(COLOR_RED, "Preset Attributes: ") .. FormatAttributesInline(attrs)
				end
            end,
            width = "half",
        },
        {
            type = "button",
            key = "LoadAttributesButton",
            text = "Load Attributes",
            width = "half",
            onClick = function(ctx, values)
				if IsRaidInProgress() then return end			
				local currentAttrs = GetCurrentAttributes()
				local payload = GetStoredPayload(ctx)
				local presetAttrs = payload and payload.attributes or nil
				-- Wenn aktueller Stand und Preset identisch sind: nichts tun
				if AreAttributesEqual(currentAttrs, presetAttrs) then return end				
                LoadAttributesFromPage(ctx, values)
            end,
        },
        {
            type = "spacer",
            key = "Divider1",
        },
        {
            type = "label",
            key = "CurrentClassMasteryLabel",
            reference = "CurrentClassMasteryLabel",
            text = function(_, values)
                local currentPreset = BSCWP:GetCurrentSkillPreset()
                local preset = NormalizeSkillPreset(values and values.classSkills) or NormalizeSkillPreset(payload.classSkills)

                if IsClassMasteryPresetEmpty(preset) then
                    return Colorize(COLOR_GREY, BuildClassMasterySummary("Current ", currentPreset))
                elseif AreClassMasteryPresetsEqual(currentPreset, preset) then
                    return Colorize(COLOR_GREEN, BuildClassMasterySummary("Current ", currentPreset))
                else
                    return Colorize(COLOR_RED, BuildClassMasterySummary("Current ", currentPreset))
                end
            end,
            width = 670,
            tooltip = function(_, values)
                local currentPreset = BSCWP:GetCurrentSkillPreset()
                local preset = NormalizeSkillPreset(values and values.classSkills) or NormalizeSkillPreset(payload.classSkills)
                return BuildClassMasteryDiffTooltip(currentPreset, preset)
            end,
        },
        {
            type = "label",
            key = "PresetClassMasteryLabel",
            reference = "PresetClassMasteryLabel",
            text = function(_, values)
                local currentPreset = BSCWP:GetCurrentSkillPreset()
                local preset = NormalizeSkillPreset(values and values.classSkills) or NormalizeSkillPreset(payload.classSkills)

                if IsClassMasteryPresetEmpty(preset) then
                    return Colorize(COLOR_GREY, BuildClassMasterySummary("Preset ", preset))
                elseif AreClassMasteryPresetsEqual(currentPreset, preset) then
                    return Colorize(COLOR_GREEN, BuildClassMasterySummary("Preset ", preset))
                else
                    return Colorize(COLOR_RED, BuildClassMasterySummary("Preset ", preset))
                end
            end,
            width = 670,
            tooltip = function(_, values)
                local currentPreset = BSCWP:GetCurrentSkillPreset()
                local preset = NormalizeSkillPreset(values and values.classSkills) or NormalizeSkillPreset(payload.classSkills)
                return BuildClassMasteryDiffTooltip(currentPreset, preset)
            end,
        },
        {
            type = "spacer",
            key = "DividerClassMastery",
        },
        {
            type = "label",
            key = "CurrentSkillsLabel",
            reference = "CurrentSkillsLabel",
            text = function(_, values)
                local currentPreset = BSCWP:GetCurrentSkillPreset()
                local preset = NormalizeSkillPreset(values and values.classSkills) or NormalizeSkillPreset(payload.classSkills)

                if IsSkillPresetEmpty(preset) then
                    return Colorize(COLOR_GREY, BuildSkillSummary("Current Skills:", currentPreset))
                elseif AreSkillPresetsEqual(currentPreset, preset) then
                    return Colorize(COLOR_GREEN, BuildSkillSummary("Current Skills:", currentPreset))
                else
                    return Colorize(COLOR_RED, BuildSkillSummary("Current Skills:", currentPreset))
                end
            end,
            width = 470,
            tooltip = function(_, values)
                local currentPreset = BSCWP:GetCurrentSkillPreset()
                local preset = NormalizeSkillPreset(values and values.classSkills) or NormalizeSkillPreset(payload.classSkills)
                return BuildSkillDiffTooltip(currentPreset, preset)
            end,
        },
        {
            type = "button",
            key = "SaveSkillsButton",
            text = "Save Skills",
            width = 200,
            onClick = function(ctx, values)
                local currentPreset = BSCWP:GetCurrentSkillPreset()
                local preset = NormalizeSkillPreset(values and values.classSkills) or NormalizeSkillPreset(payload.classSkills)

                if AreSkillPresetsEqual(currentPreset, preset) then
                    return
                end

                if not IsSkillPresetEmpty(preset) then
                    ShowGenericConfirmDialog({
                        title = "Overwrite Skills?",
                        mainText = "This page already has saved skills. Do you want to overwrite them?",
                        confirmText = "Overwrite",
                        cancelText = "Cancel",
                        onConfirm = function()
                            SaveSkillsToPage(ctx, values)
                        end,
                    })
                    return
                end

                SaveSkillsToPage(ctx, values)
            end,
        },
        {
            type = "label",
            key = "PresetSkillsLabel",
            text = function(_, values)
                local currentPreset = BSCWP:GetCurrentSkillPreset()
                local preset = NormalizeSkillPreset(values and values.classSkills) or NormalizeSkillPreset(payload.classSkills)

                if IsSkillPresetEmpty(preset) then
                    return Colorize(COLOR_GREY, BuildSkillSummary("Preset Skills:", preset))
                elseif AreSkillPresetsEqual(currentPreset, preset) then
                    return Colorize(COLOR_GREEN, BuildSkillSummary("Preset Skills:", preset))
                else
                    return Colorize(COLOR_RED, BuildSkillSummary("Preset Skills:", preset))
                end
            end,
            width = 470,
            tooltip = function(_, values)
                local currentPreset = BSCWP:GetCurrentSkillPreset()
                local preset = NormalizeSkillPreset(values and values.classSkills) or NormalizeSkillPreset(payload.classSkills)
                return BuildSkillDiffTooltip(currentPreset, preset)
            end,
        },
        {
            type = "button",
            key = "LoadSkillsButton",
            text = "Load Skills",
            width = 200,
            onClick = function(ctx, values)
				if IsRaidInProgress() then return end
				
                local currentPreset = BSCWP:GetCurrentSkillPreset()
                local preset = NormalizeSkillPreset(values and values.classSkills) or NormalizeSkillPreset(payload.classSkills)

                if IsSkillPresetEmpty(preset) then
                    return
                end

                if AreSkillPresetsEqual(currentPreset, preset) then
                    return
                end
								
				local CType = values and values.CurseType or payload.CurseType or CURSE_TYPE_NONE
				local CCType = GetPlayerCurseType()
				
				if CType ~= CCType then
                    ShowGenericConfirmDialog({
                        title = "Curse Type do not Match to Load Skills",
                        mainText = "Please get the Same Curse Type: ".. GetString("SI_CURSETYPE", CType),
                        confirmText = "Cancel",
                        cancelText = "Cancel",
                    })
                    return
				end
                LoadSkillsFromPage(ctx, values)
            end,
        },
        {
            type = "spacer",
            key = "Divider2",
        },
        {
            type = "button",
            key = "SaveAllButton",
            text = "Save All",
			width = "half",
            onClick = function(ctx, values)
                local payload = GetStoredPayload(ctx)

                if IsSaveAllUnchanged(payload) then
                    return
                end

                local hasSaved = HasSavedAttributesOrSkills(payload)
                if hasSaved then
                    ShowGenericConfirmDialog({
                        title = "Overwrite Presets?",
                        mainText = "This page already has saved attributes and/or skills. Do you want to overwrite the existing presets?",
                        confirmText = "Overwrite",
                        cancelText = "Cancel",
                        onConfirm = function()
                            SaveAllToPage(ctx, values)
                        end,
                    })
                    return
                end

                SaveAllToPage(ctx, values)
            end,
        },
		{
			type = "button",
			key = "ClearAllButton",
			text = "Clear",
			width = "half",
			onClick = function(ctx, values)
				local payload = GetStoredPayload(ctx)

				local hasAttributes = not IsAttributesPresetEmpty(payload and payload.attributes)
				local hasSkills = not IsSkillPresetEmpty(payload and payload.classSkills)

				if not hasAttributes and not hasSkills then
					ClearPagePresets(ctx)
					return
				end

				ShowGenericConfirmDialog({
					title = "Delete Presets?",
					mainText = "This page has saved attributes and/or skills. Do you really want to delete them?",
					confirmText = "Delete",
					cancelText = "Cancel",
					onConfirm = function()
						ClearPagePresets(ctx)
					end,
				})
			end,
		},
    }
end

function BSCWP:RegisterWWClient()
    if self._wwClientRegistered then
        return
    end

    LIB:RegisterClient({
        id = CLIENT_ID,
        provider = PROVIDER_KEY,
        displayName = "BSC Wizzard Plugin",
        storageScope = LIB.SCOPE_PAGE,
        getStore = getStore,
        getEditorFields = getEditorFields,
        normalizePayload = normalizePayload,
    })

    self._wwClientRegistered = true
end

local function AttributeRespecResult(_, result)
    if result == RESPEC_RESULT_SUCCESS then
		RefreshPageEditor(0)
    end
end

local function SkillRespecResult(_, result)
    if result == RESPEC_RESULT_SUCCESS then
		RefreshPageEditor(0)
    end
end

function BSCWP.init(event, addonName)
    if addonName ~= BSCWP.Name then
        return
    end
    EVENT_MANAGER:UnregisterForEvent(BSCWP.Name, EVENT_ADD_ON_LOADED)

    BSCWP.SV = ZO_SavedVars:NewCharacterNameSettings(BSCWP.SavedVar, 1, nil, defaultSV)

    EVENT_MANAGER:RegisterForEvent(BSCWP.Name, EVENT_ATTRIBUTE_RESPEC_RESULT, AttributeRespecResult)
    EVENT_MANAGER:RegisterForEvent(BSCWP.Name, EVENT_SKILL_RESPEC_RESULT, SkillRespecResult)

	SetupGenericConfirmDialog()
    BSCWP:RegisterWWClient()
end
EVENT_MANAGER:RegisterForEvent(BSCWP.Name, EVENT_ADD_ON_LOADED, BSCWP.init)
