local Build = LibDataPacker.Extra.Build

local SLOT_NAMES = {
    [EQUIP_SLOT_HEAD]           = 'Head',       -- 0  
    [EQUIP_SLOT_CHEST]          = 'Chest',      -- 2
    [EQUIP_SLOT_SHOULDERS]      = 'Shoulders',  -- 3
    [EQUIP_SLOT_HAND]           = 'Hand',       -- 16
    [EQUIP_SLOT_WAIST]          = 'Waist',      -- 6
    [EQUIP_SLOT_LEGS]           = 'Legs',       -- 8
    [EQUIP_SLOT_FEET]           = 'Feet',       -- 9

    [EQUIP_SLOT_NECK]           = 'Neck',       -- 1
    [EQUIP_SLOT_RING1]          = 'Ring',       -- 11
    [EQUIP_SLOT_RING2]          = 'Ring',       -- 12

    [EQUIP_SLOT_MAIN_HAND]      = 'Front (R)',  -- 4
    [EQUIP_SLOT_OFF_HAND]       = 'Front (L)',  -- 5

    [EQUIP_SLOT_BACKUP_MAIN]    = 'Back (R)',   -- 20
    [EQUIP_SLOT_BACKUP_OFF]     = 'Back (L)',   -- 21
}

local DISCIPLINES = {
    CHAMPION_DISCIPLINE_TYPE_COMBAT,
    CHAMPION_DISCIPLINE_TYPE_CONDITIONING,
    CHAMPION_DISCIPLINE_TYPE_WORLD,
}

local CHAMPION_SKILL_DISCIPLINE_ICONS =
{
    [CHAMPION_DISCIPLINE_TYPE_WORLD] = 'EsoUI/Art/Champion/champion_points_stamina_icon.dds',
    [CHAMPION_DISCIPLINE_TYPE_COMBAT] = 'EsoUI/Art/Champion/champion_points_magicka_icon.dds',
    [CHAMPION_DISCIPLINE_TYPE_CONDITIONING] = 'EsoUI/Art/Champion/champion_points_health_icon.dds',
}

function LibDataPacker_Build_InitializeGearSlots(control)
    for _, gearSlot in ipairs(Build.GEAR_SLOTS) do
        local gearSlotControl = CreateControlFromVirtual('$(parent)Slot', control, 'LibDataPacker_Build_GearPeaceTemplate', gearSlot)
        local slotName = gearSlotControl:GetNamedChild('SlotName')

        slotName:SetText(SLOT_NAMES[gearSlot])
    end
end

function LibDataPacker_Build_InitializeDisciplineSlots(control)
    local previousControl

    for disciplineId, disciplineType in ipairs(DISCIPLINES) do
        local disciplineControl = CreateControlFromVirtual('$(parent)Discipline', control, 'LibDataPacker_Build_DisciplineTemplate', disciplineType)
        disciplineControl:GetNamedChild('Icon'):SetTexture(CHAMPION_SKILL_DISCIPLINE_ICONS[disciplineType])
        disciplineControl:GetNamedChild('Name'):SetText(GetChampionDisciplineName(disciplineId))

        if previousControl then
            disciplineControl:SetAnchor(TOPLEFT, previousControl, BOTTOMLEFT)
        end

        previousControl = disciplineControl

        for i = 1, 4 do
            local constellationControl = CreateControlFromVirtual('$(parent)Constellation', disciplineControl, 'LibDataPacker_Build_ConstellationTemplate', i)
            constellationControl:GetNamedChild('Icon'):SetTexture(ZO_GetChampionBarDisciplineTextures(disciplineType).slotted)
            constellationControl:GetNamedChild('IconBorder'):SetTexture(ZO_GetChampionBarDisciplineTextures(disciplineType).border)
            -- constellationControl:GetNamedChild('Name'):SetText(GetChampionSkillName(skillId))
            constellationControl:GetNamedChild('Name'):SetText('Unselected')

            constellationControl:SetAnchor(TOPLEFT, previousControl, BOTTOMLEFT)

            previousControl = constellationControl
        end
    end
end

-- ----------------------------------------------------------------------------

local function GetItemLinkQualityColor(itemLink)
    return GetItemQualityColor(GetItemLinkDisplayQuality(itemLink)):UnpackRGBA()
end

local ARMOR_TYPE_COLOR = {
    [ARMORTYPE_NONE]    = {1, 1, 1},
    [ARMORTYPE_HEAVY]   = {GetInterfaceColor(INTERFACE_COLOR_TYPE_POWER, COMBAT_MECHANIC_FLAGS_HEALTH)},
    [ARMORTYPE_MEDIUM]  = {GetInterfaceColor(INTERFACE_COLOR_TYPE_POWER, COMBAT_MECHANIC_FLAGS_STAMINA)},
    [ARMORTYPE_LIGHT]   = {GetInterfaceColor(INTERFACE_COLOR_TYPE_POWER, COMBAT_MECHANIC_FLAGS_MAGICKA)},
}

local function GetArmorTypeColor(armorType)
    return unpack(ARMOR_TYPE_COLOR[armorType])
end

-- ----------------------------------------------------------------------------

local function LayoutGearSlot(slotControl, itemLink)
    local armorType = GetItemLinkArmorType(itemLink)
    slotControl:GetNamedChild('SlotName'):SetColor(GetArmorTypeColor(armorType))

    local level = GetItemLinkRequiredLevel(itemLink)
    local CPPoints = GetItemLinkRequiredChampionPoints(itemLink)

    if CPPoints > 0 then
        slotControl:GetNamedChild('Level'):SetText(CPPoints)
        slotControl:GetNamedChild('CPIcon'):SetHidden(false)
    else
        slotControl:GetNamedChild('Level'):SetText(level)
        slotControl:GetNamedChild('CPIcon'):SetHidden(true)
    end

    slotControl:GetNamedChild('GearName'):SetText(GetItemLinkName(itemLink))
    slotControl:GetNamedChild('GearName'):SetColor(GetItemLinkQualityColor(itemLink))

    local trait = GetItemLinkTraitInfo(itemLink)
    slotControl:GetNamedChild('Trait'):SetText(GetString('SI_ITEMTRAITTYPE', trait))

    -- local enchantmentSearchCategory = GetEnchantSearchCategoryType(gearPiece[4])
    -- slotControl:GetNamedChild('Enchantment'):SetText(GetString('SI_ENCHANTMENTSEARCHCATEGORYTYPE', enchantmentSearchCategory))

    local hasCharges, enchantHeader, enchantDescription = GetItemLinkEnchantInfo(itemLink)
    slotControl:GetNamedChild('Enchantment'):SetText(enchantHeader)
end

local function LayoutGear(build)
    local CONTROL = LibDataPacker_Build_TLCGear
    local gear = build[Build.GEAR]

    local previousGearSlotControl

    for _, slot in ipairs(Build.GEAR_SLOTS) do
        local slotControl = CONTROL:GetNamedChild('Slot'..slot)

        local gearPiece = gear[slot]
        if gearPiece[1] ~= 0 then
            local itemLink = ('|H1:item:%i:%i:50:%i:370:50:%i:0:0:0:0:0:0:0:2049:9:0:1:0:2900:0|h|h'):format(gearPiece[1], 359 + gearPiece[2], gearPiece[4], gearPiece[3])
            slotControl.itemLink = itemLink
            LayoutGearSlot(slotControl, itemLink)

            if previousGearSlotControl then
                slotControl:SetAnchor(TOPLEFT, previousGearSlotControl, BOTTOMLEFT, 0, 8)
            end

            previousGearSlotControl = slotControl
            slotControl:SetHidden(false)
        else
            slotControl:SetAnchor(TOPLEFT)
            slotControl:SetHidden(true)
        end
    end
end

-- ----------------------------------------------------------------------------

local function LayoutSkillSlot(hotbarControl, slotIndex, slotType, skillId)
    if not skillId then return end

    local abilityName, abilityIcon

    if slotType == ACTION_TYPE_CRAFTED_ABILITY then
        abilityName = GetCraftedAbilityDisplayName(skillId)
        abilityIcon = GetCraftedAbilityIcon(skillId)
    else
        abilityName = GetAbilityName(skillId)
        abilityIcon = GetAbilityIcon(skillId)
    end

    hotbarControl:GetNamedChild('Skill' .. slotIndex):SetTexture(abilityIcon)
end

local function LayoutSkills(build)
    -- TODO: move to init function
    local SKILLS_CONTROL = LibDataPacker_Build_TLCSkills
    local HOTBAR_CONTROLS = {
        [HOTBAR_CATEGORY_PRIMARY] = SKILLS_CONTROL:GetNamedChild('Primary'),
        [HOTBAR_CATEGORY_BACKUP] = SKILLS_CONTROL:GetNamedChild('Backup'),
    }

    for hotbar = HOTBAR_CATEGORY_PRIMARY, HOTBAR_CATEGORY_BACKUP do
        local hotbarControl = HOTBAR_CONTROLS[hotbar]
        for slotIndex = 3, 8 do
            local skillId = build:GetSlotBoundId(slotIndex, hotbar)
            local slotType = build:GetSlotType(slotIndex, hotbar)

            LayoutSkillSlot(hotbarControl, slotIndex, slotType, skillId)
        end
    end
end

-- ----------------------------------------------------------------------------

local function LayoutAttributes(build)
    local CONTROL = LibDataPacker_Build_TLCAttributes
    local attributes = build[Build.ATTRIBUTES]

    local ATTRIBUTES = {
        [ATTRIBUTE_HEALTH] = 'Health',
        [ATTRIBUTE_MAGICKA] = 'Magicka',
        [ATTRIBUTE_STAMINA] = 'Stamina',
    }
    for attributeGlobalIndex, attribute in pairs(ATTRIBUTES) do
        CONTROL:GetNamedChild(attribute):GetNamedChild('AttributeValue'):SetText(attributes[attributeGlobalIndex])
    end
end

-- ----------------------------------------------------------------------------

local function LayoutStats(build)
    local STATS = {
        [STAT_HEALTH_MAX] = LibDataPacker_Build_TLCAttributesHealthResourceValue,
        [STAT_MAGICKA_MAX] = LibDataPacker_Build_TLCAttributesMagickaResourceValue,
        [STAT_STAMINA_MAX] = LibDataPacker_Build_TLCAttributesStaminaResourceValue,

        [STAT_HEALTH_REGEN_COMBAT] = LibDataPacker_Build_TLCAttributesHealthRegenerationValue,
        [STAT_MAGICKA_REGEN_COMBAT] = LibDataPacker_Build_TLCAttributesMagickaRegenerationValue,
        [STAT_STAMINA_REGEN_COMBAT] = LibDataPacker_Build_TLCAttributesStaminaRegenerationValue,

        [STAT_POWER] = LibDataPacker_Build_TLCStatsPhysicalDamage,
        [STAT_SPELL_POWER] = LibDataPacker_Build_TLCStatsMagickalDamage,

        [STAT_CRITICAL_STRIKE] = LibDataPacker_Build_TLCStatsPhysicalCrit,
        [STAT_SPELL_CRITICAL] = LibDataPacker_Build_TLCStatsMagickalCrit,

        [STAT_PHYSICAL_PENETRATION] = LibDataPacker_Build_TLCStatsPhysicalPenetration,
        [STAT_SPELL_PENETRATION] = LibDataPacker_Build_TLCStatsMagickalPenetration,

        [STAT_PHYSICAL_RESIST] = LibDataPacker_Build_TLCStatsPhysicalResistance,
        [STAT_SPELL_RESIST] = LibDataPacker_Build_TLCStatsMagickalResistance,
    }

    local showPercents = {
        [STAT_CRITICAL_STRIKE] = true,
        [STAT_SPELL_CRITICAL] = true,

        -- [STAT_PHYSICAL_PENETRATION] = true,
        -- [STAT_SPELL_PENETRATION] = true,

        -- [STAT_PHYSICAL_RESIST] = true,
        -- [STAT_SPELL_RESIST] = true,
    }

    for statGlobalIndex, control in pairs(STATS) do
        local statValue = build:GetPlayerStat(statGlobalIndex)
        control:SetText(statValue)

        if showPercents[statGlobalIndex] then
            control:SetHandler('OnMouseEnter', function(control)
                InitializeTooltip(InformationTooltip, control, TOP, 0, 0)
                SetTooltipText(InformationTooltip, ('%.1f %%'):format(statValue / 219))
            end)
            control:SetHandler('OnMouseExit', function(control)
                ClearTooltip(InformationTooltip)
            end)
        end
    end
end

-- ----------------------------------------------------------------------------

local function LayoutBasicInfo(build)
    local CONTROL = LibDataPacker_Build_TLCBasicInfo

    local cp = build[Build.CP]
    local race = build[Build.RACE]
    local class = build[Build.CLASS]
    local alliance = build[Build.ALLIANCE]
    local ava_rank = build[Build.AVA_RANK]

    CONTROL:GetNamedChild('ChampionPoints'):SetText(cp)
    CONTROL:GetNamedChild('RaceAndClass'):SetText(('%s %s'):format(GetRaceName(nil, race), GetClassName(nil, class)))

    CONTROL:GetNamedChild('AllianceIcon'):SetTexture(GetLargeAllianceSymbolIcon(alliance))
    CONTROL:GetNamedChild('AllianceIcon'):SetColor(GetAllianceColor(alliance):UnpackRGBA())

    CONTROL:GetNamedChild('AVARank'):SetText(ava_rank)
    CONTROL:GetNamedChild('AVARankIcon'):SetTexture(GetLargeAvARankIcon(ava_rank))
    CONTROL:GetNamedChild('AVARankLabel'):SetText(('(%s)'):format(GetAvARankName(nil, ava_rank)))
end

local function LayoutShortBasicInfo(shortBuild)
    local CONTROL = LibDataPacker_Build_TLCBasicInfo

    local race = shortBuild[Build.RACE]
    local class = shortBuild[Build.CLASS]

    CONTROL:GetNamedChild('RaceAndClass'):SetText(('%s %s'):format(GetRaceName(nil, race), GetClassName(nil, class)))

    CONTROL:GetNamedChild('AllianceIcon'):SetTexture(GetLargeAllianceSymbolIcon(alliance))
    CONTROL:GetNamedChild('AllianceIcon'):SetColor(GetAllianceColor(alliance):UnpackRGBA())
end

-- ----------------------------------------------------------------------------

local DISCIPLINE_TYPE_TO_ID = {
    [CHAMPION_DISCIPLINE_TYPE_COMBAT] = 1,
    [CHAMPION_DISCIPLINE_TYPE_CONDITIONING] = 2,
    [CHAMPION_DISCIPLINE_TYPE_WORLD] = 3,
}

local function LayoutConstellations(build)
    local championDisciplines = {
        [CHAMPION_DISCIPLINE_TYPE_COMBAT] = {},
        [CHAMPION_DISCIPLINE_TYPE_CONDITIONING] = {},
        [CHAMPION_DISCIPLINE_TYPE_WORLD] = {},
    }

    -- there is faster way to split it like 1-4, 5-8, 9-12
    -- it will correspond to 2, 0, 1 disciplineType respectfully

    for slotIndex = 1, 12 do
        local championSkillId = build:GetSlotBoundId(slotIndex, HOTBAR_CATEGORY_CHAMPION)
        local currentDisciplineId = GetRequiredChampionDisciplineIdForSlot(slotIndex, HOTBAR_CATEGORY_CHAMPION)
        local disciplineType = GetChampionDisciplineType(currentDisciplineId)
        table.insert(championDisciplines[disciplineType], championSkillId)
    end

    local CONTROL = LibDataPacker_Build_TLCDisciplines
    local previousControl

    for championDiscipline, skills in pairs(championDisciplines) do
        local disciplineControl = CONTROL:GetNamedChild('Discipline' .. championDiscipline)
        disciplineControl:GetNamedChild('Icon'):SetTexture(CHAMPION_SKILL_DISCIPLINE_ICONS[championDiscipline])
        disciplineControl:GetNamedChild('Name'):SetText(GetChampionDisciplineName(DISCIPLINE_TYPE_TO_ID[championDiscipline]))

        if previousControl then
            disciplineControl:SetAnchor(TOPLEFT, previousControl, BOTTOMLEFT, 0, 6)
        end

        previousControl = disciplineControl

        for i = 1, #skills do
            local skillId = skills[i]
            local constellationControl = disciplineControl:GetNamedChild('Constellation' .. i)

            if skillId > 0 then
                constellationControl:SetHidden(false)
                constellationControl:SetAnchor(TOPLEFT, previousControl, BOTTOMLEFT)
                previousControl = constellationControl

                constellationControl:GetNamedChild('Icon'):SetTexture(ZO_GetChampionBarDisciplineTextures(championDiscipline).slotted)
                constellationControl:GetNamedChild('IconBorder'):SetTexture(ZO_GetChampionBarDisciplineTextures(championDiscipline).border)

                constellationControl:GetNamedChild('Name'):SetText(GetChampionSkillName(skillId))
            else
                constellationControl:SetHidden(true)
            end
        end
    end
end

-- ----------------------------------------------------------------------------

local function LayoutSkillLines(build)
    local CONTROL = LibDataPacker_Build_TLCSkillLines

    local skillLines = build[Build.CLASS_SKILL_LINES]
    for i = 1, #skillLines do
        local skillLineId = skillLines[i]

        local skillLineControl = CONTROL:GetNamedChild('SkillLine' .. i)
        skillLineControl:SetText(GetSkillLineNameById(skillLineId))

        local skillType, skillLineIndex = GetSkillLineIndicesFromSkillLineId(skillLineId)
        local classId = GetSkillLineClassId(skillType, skillLineIndex)

        skillLineControl:GetNamedChild('ClassName'):SetText(('(%s)'):format(GetClassName(nil, classId)))
    end
end

-- ----------------------------------------------------------------------------

local function LayoutBoon(control, boon)
    if boon > 0 then
        control:GetNamedChild('Icon'):SetTexture(ZO_STAT_MUNDUS_ICONS[boon])
        control:GetNamedChild('Name'):SetText(GetString('SI_MUNDUSSTONE', boon))
        control:SetHidden(false)
    else
        control:SetHidden(true)
    end
end

local function LayoutBoons(build)
    local CONTROL = LibDataPacker_Build_TLCBoons

    LayoutBoon(CONTROL:GetNamedChild('Main'), GetAbilityMundusStoneType(build[Build.FIRST_BOON]))
    LayoutBoon(CONTROL:GetNamedChild('Secondary'), GetAbilityMundusStoneType(build[Build.SECOND_BOON]))
end

-- ----------------------------------------------------------------------------

local function LayoutAbilityBuff(control, abilityId)
    if abilityId then
        control:GetNamedChild('Icon'):SetTexture(GetAbilityIcon(abilityId))
        control:GetNamedChild('Name'):SetText(GetAbilityName(abilityId))
        control:SetHidden(false)
    else
        control:SetHidden(true)
    end
end

local function LayoutFood(build)
    LayoutAbilityBuff(LibDataPacker_Build_TLCFood, build[Build.FOOD])
end

local function LayoutVampireOrWWBuff(build)
    LayoutAbilityBuff(LibDataPacker_Build_TLCVampWW, build[Build.WW_VAMP_BUFF])
end

-- ----------------------------------------------------------------------------

function LibDataPacker_Build_LayoutBuild(build)
    build = build or Build.GetLocalPlayerBuild()

    if type(build) == 'string' then
        build = Build.UnpackBuild(build)
    end

    LayoutBasicInfo(build)
    LayoutGear(build)
    LayoutSkills(build)
    LayoutAttributes(build)
    LayoutStats(build)
    LayoutConstellations(build)
    LayoutSkillLines(build)
    LayoutBoons(build)
    LayoutFood(build)
    LayoutVampireOrWWBuff(build)

    LibDataPacker_Build_TLC:SetHidden(false)
end

function LibDataPacker_Build_LayoutShortBuild(shortBuild)
    shortBuild = shortBuild or Build.GetLocalPlayerShortBuild()

    if type(shortBuild) == 'string' then
        shortBuild = Build.UnpackShortBuild(shortBuild)
    end

    LayoutShortBasicInfo(shortBuild)
    LayoutGear(shortBuild)
    LayoutSkills(shortBuild)
    -- LayoutAttributes(shortBuild)
    -- LayoutStats(shortBuild)
    LayoutConstellations(shortBuild)
    LayoutSkillLines(shortBuild)
    LayoutBoons(shortBuild)
    LayoutFood(shortBuild)
    LayoutVampireOrWWBuff(shortBuild)

    LibDataPacker_Build_TLC:SetHidden(false)
end

-- do
--     zo_callLater(function() LibDataPacker_Build_LayoutBuild() end, 2000)
-- end