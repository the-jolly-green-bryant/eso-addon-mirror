--- ESO-Skillfactory.com Build Export AddOn for http://www.eso-skillfactory.com
--- written by Keldor

----
--- Initialize global Variables
---
ESOSkillfactoryBuildExport = {}
ESOSkillfactoryBuildExport.Name = "ESOSkillfactoryBuildExport"
ESOSkillfactoryBuildExport.DisplayName = "ESO-Skillfactory.com Build Export"
ESOSkillfactoryBuildExport.AddonVersion = "1.2.12"
ESOSkillfactoryBuildExport.AddonIntVersion = 1212
ESOSkillfactoryBuildExport.Lang = "en"
ESOSkillfactoryBuildExport.WebsiteUrl = "https://www.eso-skillfactory.com/"
ESOSkillfactoryBuildExport.ImportBaseUrl = {
    en = "https://www.eso-skillfactory.com/en/import/?v=" .. ESOSkillfactoryBuildExport.AddonIntVersion .. "&d=",
    de = "https://www.eso-skillfactory.com/de/import/?v=" .. ESOSkillfactoryBuildExport.AddonIntVersion .. "&d=",
    fr = "https://www.eso-skillfactory.com/fr/import/?v=" .. ESOSkillfactoryBuildExport.AddonIntVersion .. "&d=",
}
ESOSkillfactoryBuildExport.BuildData = {
    Alliance = 0,
    Race = 0,
    Class = 0,
    Health = 0,
    Magicka = 0,
    Stamina = 0,
    Skills = "",
    Mundus = "",
    Sets = "",
    CP = {
        PointsHealth = 0,
        PointsMagicka = 0,
        PointsStamina = 0,
        Skills = "",
        Slots = "",
    },
    ActionBars = {
        HOTBAR_CATEGORY_PRIMARY = "",
        HOTBAR_CATEGORY_BACKUP = "",
    },
}
ESOSkillfactoryBuildExport.ActionBars = {
    HOTBAR_CATEGORY_PRIMARY,
    HOTBAR_CATEGORY_BACKUP,
    HOTBAR_CATEGORY_WEREWOLF, -- Currently not supported
}
ESOSkillfactoryBuildExport.GearSlots = {
    EQUIP_SLOT_HEAD,
    EQUIP_SLOT_SHOULDERS,
    EQUIP_SLOT_CHEST,
    EQUIP_SLOT_HAND,
    EQUIP_SLOT_WAIST,
    EQUIP_SLOT_LEGS,
    EQUIP_SLOT_FEET,
    EQUIP_SLOT_NECK,
    EQUIP_SLOT_RING1,
    EQUIP_SLOT_RING2,
    EQUIP_SLOT_MAIN_HAND,
    EQUIP_SLOT_OFF_HAND,
    EQUIP_SLOT_BACKUP_MAIN,
    EQUIP_SLOT_BACKUP_OFF,
    EQUIP_SLOT_POISON,
    EQUIP_SLOT_BACKUP_POISON,
}
ESOSkillfactoryBuildExport.GearSlotsPoison = {
    [EQUIP_SLOT_POISON] = true,
    [EQUIP_SLOT_BACKUP_POISON] = true,
}


function ESOSkillfactoryBuildExport.BaseInfoExport()
    ESOSkillfactoryBuildExport.BuildData.Alliance = GetUnitAlliance("player")
    ESOSkillfactoryBuildExport.BuildData.Race = GetUnitRaceId("player")
    ESOSkillfactoryBuildExport.BuildData.Class = GetUnitClassId("player")
    ESOSkillfactoryBuildExport.BuildData.Health = GetAttributeSpentPoints(ATTRIBUTE_HEALTH)
    ESOSkillfactoryBuildExport.BuildData.Magicka = GetAttributeSpentPoints(ATTRIBUTE_MAGICKA)
    ESOSkillfactoryBuildExport.BuildData.Stamina = GetAttributeSpentPoints(ATTRIBUTE_STAMINA)
end

function ESOSkillfactoryBuildExport.ExportAbilities()

    ESOSkillfactoryBuildExport.BuildData.Skills = ""

    for typeIndex = SKILL_TYPE_MIN_VALUE, SKILL_TYPE_MAX_VALUE do
        ESOSkillfactoryBuildExport.ExportType(typeIndex)
    end
end

function ESOSkillfactoryBuildExport.ExportType(typeIndex)

    local numSkillLines = GetNumSkillLines(typeIndex)
    if numSkillLines > 0 then
        for lineIndex = 1, numSkillLines do
            ESOSkillfactoryBuildExport.ExportSkills(typeIndex, lineIndex)
        end
    end
end

function ESOSkillfactoryBuildExport.ExportSkills(typeIndex, lineIndex)

    local numSkills = GetNumSkillAbilities(typeIndex, lineIndex)
    if numSkills > 0 then
        for skillIndex = 1, numSkills do
            local abilityId = GetSkillAbilityId(typeIndex, lineIndex, skillIndex, false)
            local isPurchased = IsSkillAbilityPurchased(typeIndex, lineIndex, skillIndex)
            local currentRank = GetSkillAbilityUpgradeInfo(typeIndex, lineIndex, skillIndex)
            local _, _, _, passive = GetSkillAbilityInfo(typeIndex, lineIndex, skillIndex)

            if isPurchased == true then

                if not currentRank or currentRank == 0 then
                    currentRank = 1
                end

                if passive then

                    if type(SKILLS_DATA_MANAGER.abilityIdToProgressionDataMap[abilityId]) == "nil" then
                        return
                    end

                    local skillProgressions = SKILLS_DATA_MANAGER.abilityIdToProgressionDataMap[abilityId].skillData.skillProgressions
                    abilityId = skillProgressions[1].abilityId
                end

                local internalSkillId = KeldorUtils:GetInternalSkillId(abilityId)
                if internalSkillId ~= nil then
                    ESOSkillfactoryBuildExport.BuildData.Skills = ESOSkillfactoryBuildExport.BuildData.Skills .. internalSkillId .. ":" .. currentRank .. ","
                end
            end
        end
    end
end

function ESOSkillfactoryBuildExport.ExportCP()

    ESOSkillfactoryBuildExport.BuildData.CP.Skills = ""
    ESOSkillfactoryBuildExport.BuildData.CP.Slots = ""

    local numDisciplines = GetNumChampionDisciplines()

    local numSpentPointsHealth = GetNumSpentChampionPoints(1)
    local numSpentPointsMagicka = GetNumSpentChampionPoints(2)
    local numSpentPointsStamina = GetNumSpentChampionPoints(3)
    local numSpentPoints = (numSpentPointsHealth + numSpentPointsMagicka + numSpentPointsStamina)

    ESOSkillfactoryBuildExport.BuildData.CP.PointsHealth = numSpentPointsHealth
    ESOSkillfactoryBuildExport.BuildData.CP.PointsMagicka = numSpentPointsMagicka
    ESOSkillfactoryBuildExport.BuildData.CP.PointsStamina = numSpentPointsStamina

    if numSpentPoints > 0 then
        for disciplineIndex = 1, numDisciplines do
            local numSkills = GetNumChampionDisciplineSkills(disciplineIndex)
            if numSkills > 0 then
                ESOSkillfactoryBuildExport.ExportCPSkills(disciplineIndex, numSkills)
            end
        end
    end

    -- Export CP slots
    local startSlotIndex, endSlotIndex = GetAssignableChampionBarStartAndEndSlots()
    for actionSlotIndex = startSlotIndex, endSlotIndex do
        local slotSkillId = GetSlotBoundId(actionSlotIndex, HOTBAR_CATEGORY_CHAMPION)
        if slotSkillId > 0 then
            local internalSkillId = KeldorUtils:GetInternalCPSkillId(slotSkillId)
            ESOSkillfactoryBuildExport.BuildData.CP.Slots = ESOSkillfactoryBuildExport.BuildData.CP.Slots .. actionSlotIndex .. ":" .. internalSkillId .. ","
        end
    end
end

function ESOSkillfactoryBuildExport.ExportCPSkills(disciplineIndex, numSkills)

    for skillIndex = 1, numSkills do

        local skillId = GetChampionSkillId(disciplineIndex, skillIndex)
        local numSpentPoints = GetNumPointsSpentOnChampionSkill(skillId)

        if numSpentPoints > 0 then
            local internalSkillId = KeldorUtils:GetInternalCPSkillId(skillId)
            if internalSkillId ~= nil then
                ESOSkillfactoryBuildExport.BuildData.CP.Skills = ESOSkillfactoryBuildExport.BuildData.CP.Skills .. internalSkillId .. ":" .. numSpentPoints .. ","
            end
        end
    end
end

function ESOSkillfactoryBuildExport.ExportActionBars()

    for _, type in pairs(ESOSkillfactoryBuildExport.ActionBars) do

        ESOSkillfactoryBuildExport.BuildData.ActionBars[type] = ""

        local hbManager = ACTION_BAR_ASSIGNMENT_MANAGER:GetHotbar(type)
        for i = 1, 6 do
            local slotData = hbManager:GetSlotData(ACTION_BAR_FIRST_NORMAL_SLOT_INDEX + i)
            if slotData then

                local internalSkillId = KeldorUtils:GetInternalSkillId(slotData:GetActionId())
                if internalSkillId == nil then
                    internalSkillId = "0"
                end

                ESOSkillfactoryBuildExport.BuildData.ActionBars[type] = ESOSkillfactoryBuildExport.BuildData.ActionBars[type] .. internalSkillId .. ":"
            end
        end
    end
end

function ESOSkillfactoryBuildExport.ExportMundus()

    local numBuffs = GetNumBuffs("player")
    for i = 1, numBuffs do
        local _, _, _, _, _, _, _, _, _, _, id = GetUnitBuffInfo("player", i)

        if type(ESOSkillfactoryBuildExportDB.Mundus[id]) ~= "nil" then
            local intId = KeldorUtils:GetInternalMundusId(id)
            if intId ~= nil then
                ESOSkillfactoryBuildExport.BuildData.Mundus = ESOSkillfactoryBuildExport.BuildData.Mundus .. intId .. ","
            end
        end
    end
end

function ESOSkillfactoryBuildExport.ExportSets()

    local setsQueryData = ""

    for _, gearSlot in ipairs(ESOSkillfactoryBuildExport.GearSlots) do

        local itemLink = GetItemLink(BAG_WORN, gearSlot, LINK_STYLE_DEFAULT)
        local itemId = GetItemLinkItemId(itemLink)
        local hasSetInfo, _, _, _, _, itemSetId = GetItemLinkSetInfo(itemLink, false)
        local planerSlotIndex = KeldorUtils:GetSkillPlanerSetSlotIndex(gearSlot)

        if hasSetInfo == true and itemSetId > 0 then

            local internalSetId = KeldorUtils:GetInternalSetId(itemSetId)
            local quality = GetItemLinkDisplayQuality(itemLink)
            local enchantId = GetItemLinkFinalEnchantId(itemLink)
            local internalEnchantId = KeldorUtils:GetInternalEnchantmentId(enchantId)
            local traitId = GetItemLinkTraitInfo(itemLink)
            local internalTraitId = KeldorUtils:GetInternalTraitId(traitId)

            local armorType = GetItemLinkArmorType(itemLink)
            local weaponType = GetItemWeaponType(BAG_WORN, gearSlot)

            local typeValue = ""

            if armorType > 0 then
                typeValue = armorType
            elseif weaponType > 0 then
                typeValue = weaponType
            end

            -- Slot Index, Set Id, Armor Type, Quality, Trait, Enchantment
            setsQueryData = string.format("%s%s:%s:%s:%s:%s:%s,",
                setsQueryData,
                planerSlotIndex or "0",
                internalSetId or "0",
                typeValue or "0",
                quality or "0",
                internalTraitId or "0",
                internalEnchantId or "0"
            )

        -- Poison
        elseif ESOSkillfactoryBuildExport.GearSlotsPoison[gearSlot] and itemId > 0 then
            setsQueryData = string.format("%s%s:%s,",
                setsQueryData,
                planerSlotIndex,
                KeldorUtils:GetInternalPoisonId(itemId)
            )
        end
    end

    ESOSkillfactoryBuildExport.BuildData.Sets = setsQueryData
end

function ESOSkillfactoryBuildExport.GetBuildUrl()

    local url = ESOSkillfactoryBuildExport.ImportBaseUrl[ESOSkillfactoryBuildExport.Lang]
    local bd = ESOSkillfactoryBuildExport.BuildData
    local queryData = ""

    -- Base info
    queryData = queryData .. bd.Alliance .. ","
    queryData = queryData .. bd.Race .. ","
    queryData = queryData .. bd.Class .. ","

    -- Attributes
    queryData = queryData .. bd.Health .. "," .. bd.Magicka .. "," .. bd.Stamina .. "-"

    -- Skills
    queryData = queryData .. KeldorUtils:removeLastChar(bd.Skills) .. "-"

    -- ActionBars
    queryData = queryData .. bd.ActionBars[HOTBAR_CATEGORY_PRIMARY] .. "-"
    queryData = queryData .. bd.ActionBars[HOTBAR_CATEGORY_BACKUP] .. "-"

    -- CP
    queryData = queryData .. KeldorUtils:removeLastChar(bd.CP.Skills) .. "-"
    queryData = queryData .. bd.CP.PointsHealth .. "," .. bd.CP.PointsMagicka .. "," .. bd.CP.PointsStamina .. "-"
    queryData = queryData .. KeldorUtils:removeLastChar(bd.CP.Slots) .. "-"

    -- Mundus
    queryData = queryData .. KeldorUtils:removeLastChar(bd.Mundus) .. "-"

    -- Sets
    queryData = queryData .. KeldorUtils:removeLastChar(bd.Sets)

    return url .. queryData
end


function ESOSkillfactoryBuildExport.HandleCommand(...)

    local optionStr = select(1, ...)
    local options = KeldorUtils:split(optionStr, " ")

    if type(options[1]) == "nil" or options[1] == "" then
        local msg = GetString(ESFBE_VERSION) .. " " .. ESOSkillfactoryBuildExport.AddonVersion .. "\n"
        msg = msg .. "|c009900/skillfactory version|r - " .. GetString(ESFBE_CMD_VERSION) .. "\n"
        msg = msg .. "|c009900/skillfactory export|r - " .. GetString(ESFBE_CMD_EXPORT) .. "\n"
        msg = msg .. "|c009900/skillfactory website|r - " .. GetString(ESFBE_CMD_WEBSITE) .. "\n"

        CHAT_SYSTEM:AddMessage("[|c2080D0" .. ESOSkillfactoryBuildExport.DisplayName .. "|r] " .. msg)

    elseif options[1] == "export" then
        ESOSkillfactoryBuildExport.BaseInfoExport()
        ESOSkillfactoryBuildExport.ExportActionBars()
        ESOSkillfactoryBuildExport.ExportAbilities()
        ESOSkillfactoryBuildExport.ExportCP()
        ESOSkillfactoryBuildExport.ExportMundus()
        ESOSkillfactoryBuildExport.ExportSets()

        RequestOpenUnsafeURL(ESOSkillfactoryBuildExport.GetBuildUrl())

    elseif options[1] == "version" then
        CHAT_SYSTEM:AddMessage("[|c2080D0" .. ESOSkillfactoryBuildExport.DisplayName .. "|r] " .. GetString(ESFBE_VERSION) .. " " .. ESOSkillfactoryBuildExport.AddonVersion)

    elseif options[1] == "website" then
        RequestOpenUnsafeURL(ESOSkillfactoryBuildExport.WebsiteUrl .. ESOSkillfactoryBuildExport.Lang .. "/")
    end
end

----
--- This function is called when the user's interface loads and their
--- character is activated after logging in or performing a reload of the UI.
----
function ESOSkillfactoryBuildExport.PlayerActivated()
    ESOSkillfactoryBuildExport.Lang = string.lower(GetCVar("Language.2"))
end

----
--- OnAddOnLoaded
----
function ESOSkillfactoryBuildExport.OnAddOnLoaded(_, addonName)

	if addonName ~= ESOSkillfactoryBuildExport.Name then return end

	EVENT_MANAGER:UnregisterForEvent(ESOSkillfactoryBuildExport.Name, EVENT_ADD_ON_LOADED)
	EVENT_MANAGER:RegisterForEvent(ESOSkillfactoryBuildExport.Name, EVENT_PLAYER_ACTIVATED, ESOSkillfactoryBuildExport.PlayerActivated)
end


----
--- AddOn init
----
EVENT_MANAGER:RegisterForEvent(ESOSkillfactoryBuildExport.Name, EVENT_ADD_ON_LOADED, ESOSkillfactoryBuildExport.OnAddOnLoaded)

SLASH_COMMANDS["/skillfactory"] = ESOSkillfactoryBuildExport.HandleCommand
