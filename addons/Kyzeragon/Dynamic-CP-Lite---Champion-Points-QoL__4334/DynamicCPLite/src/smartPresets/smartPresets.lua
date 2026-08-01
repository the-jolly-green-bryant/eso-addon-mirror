local TREE_TO_DISCIPLINE = {
    Green = 1,
    Blue = 2,
    Red = 3,
}


-----------------------------------------------------------
-- Apply the preset??
-----------------------------------------------------------
-- returns: fatecarverUnlocked, isStamHigher, isPragmatic, craftingMaxed, jabsUnlocked, isHABuild, blightedBlastbonesUnlocked
local function GetDecisions()
    -- Whether skills are unlocked
    local fatecarverUnlocked = false
    local jabsUnlocked = false
    local blightedBlastbonesUnlocked = false
    local pragmatic = false
    for skillLineIndex = 1, GetNumSkillLines(SKILL_TYPE_CLASS) do
        local skillLineId = GetSkillLineId(SKILL_TYPE_CLASS, skillLineIndex)
        local _, _, isActive = GetSkillLineDynamicInfo(SKILL_TYPE_CLASS, skillLineIndex)
        -- Aedric Spear and Herald of the Tome and Grave Lord
        if (isActive and skillLineId == 22 or skillLineId == 218 or skillLineId == 131) then
            for skillIndex = 1, GetNumSkillAbilities(SKILL_TYPE_CLASS, skillLineIndex) do
                local progressionId = GetProgressionSkillProgressionId(SKILL_TYPE_CLASS, skillLineIndex, skillIndex)

                -- Fatecarver
                if (progressionId == 535) then
                    local _, _, _, _, _, purchased = GetSkillAbilityInfo(SKILL_TYPE_CLASS, skillLineIndex, skillIndex)
                    if (purchased) then
                        fatecarverUnlocked = true
                        local morph = GetProgressionSkillCurrentMorphSlot(progressionId)
                        if (morph == MORPH_SLOT_MORPH_2) then
                            pragmatic = true
                        end
                    end
                    break

                -- Jabs
                elseif (progressionId == 43) then
                    local _, _, _, _, _, purchased = GetSkillAbilityInfo(SKILL_TYPE_CLASS, skillLineIndex, skillIndex)
                    if (purchased) then
                        jabsUnlocked = true
                    end
                    break

                -- Blastbones
                elseif (progressionId == 444) then
                    local _, _, _, _, _, purchased = GetSkillAbilityInfo(SKILL_TYPE_CLASS, skillLineIndex, skillIndex)
                    if (purchased) then
                        local morph = GetProgressionSkillCurrentMorphSlot(progressionId)
                        if (morph == MORPH_SLOT_MORPH_1) then
                            blightedBlastbonesUnlocked = true
                        end
                    end
                    break
                end
            end
        end
    end

    -- Whether stam or mag is higher
    local _, maxStam, effectiveMaxStam = GetUnitPower("player", COMBAT_MECHANIC_FLAGS_STAMINA)
    local _, maxMag, effectiveMaxMag = GetUnitPower("player", COMBAT_MECHANIC_FLAGS_MAGICKA)

    -- Whether all crafting lines are maxed
    local craftingMaxed = true
    for skillLineIndex = 1, GetNumSkillLines(SKILL_TYPE_TRADESKILL) do
        local rank = GetSkillLineDynamicInfo(SKILL_TYPE_TRADESKILL, skillLineIndex)
        if (rank < 50) then
            craftingMaxed = false
            break
        end
    end

    -- Whether this is a "heavy attack" build: look for Sergeant's Mail and lightning staff
    local isHABuild = false
    local _, _, _, numSergeant = GetItemSetInfo(29)
    if (numSergeant >= 3) then
        local function IsLightning(slot)
            local itemLink = GetItemLink(BAG_WORN, slot)
            return GetItemLinkWeaponType(itemLink) == WEAPONTYPE_LIGHTNING_STAFF
        end
        isHABuild = IsLightning(EQUIP_SLOT_MAIN_HAND) or IsLightning(EQUIP_SLOT_BACKUP_MAIN)
    end

    return fatecarverUnlocked, maxStam > maxMag, pragmatic, craftingMaxed, jabsUnlocked, isHABuild, blightedBlastbonesUnlocked
end

-- We don't care about existing points, i.e. overwrite anything
-- So just go down the data list and allocate as many as max points allow
-- params: tree name as color string, the struct with the preset, total points (for testing) or nil
local function ApplySmartPreset(tree, preset, totalPoints)
    local disciplineIndex = TREE_TO_DISCIPLINE[tree]
    if (not totalPoints) then
        local disciplineId = GetChampionDisciplineId(disciplineIndex)
        totalPoints = GetNumSpentChampionPoints(disciplineId) + GetNumUnspentChampionPoints(disciplineId)
    end
    DynamicCP.dbg(tree .. " using totalPoints " .. tostring(totalPoints))

    local fatecarverUnlocked, isStamHigher, isPragmatic, craftingMaxed, jabsUnlocked, isHABuild, blightedBlastbonesUnlocked = GetDecisions()
    DynamicCP.dbg(string.format("%s; %s; %s; %s; %s; %s; %s",
        fatecarverUnlocked and "fatecarver available" or "no fatecarver",
        isStamHigher and "stam higher" or "mag higher",
        isPragmatic and "is pragmatic" or "not pragmatic",
        craftingMaxed and "crafting maxed" or "crafting not maxed",
        jabsUnlocked and "jabs" or "no jabs",
        isHABuild and "HA" or "not HA",
        blightedBlastbonesUnlocked and "blastbones" or "no bones"))

    local currentTotalPoints = 0
    local pendingPoints = {} -- {[10] = 10,}
    local slottables = {}
    local deprioritizedSlottables = {}
    local pendingCP = {
        [disciplineIndex] = pendingPoints,
        slottables = slottables,
    }
    for _, node in ipairs(preset.nodes) do
        local id, stage
        if (node.id) then
            id = node.id
        elseif (node.flex) then
            local hasAoeSpammable = fatecarverUnlocked or jabsUnlocked or blightedBlastbonesUnlocked
            id = preset.GetFlex(hasAoeSpammable, isHABuild, isPragmatic, craftingMaxed, node.flex, totalPoints)
        elseif (node.passive) then
            id = preset.GetPassive(isStamHigher, node.passive)
        end
        stage = node.stage -- can be nil

        -- id -1 means skip. Likely used for Inspiration Boost flex
        if (id ~= -1) then
            -- Get number of points to use, including previous partial opens
            local existingPoints = pendingPoints[id] or 0
            local desiredPoints
            if (stage) then
                desiredPoints = select(stage + 1, GetChampionSkillJumpPoints(id)) -- 0, 10, 20
            else
                desiredPoints = GetChampionSkillMaxPoints(id)
            end
            local pointsToAllocate = desiredPoints - existingPoints

            -- Not enough CP, spend the last bit
            if (currentTotalPoints + pointsToAllocate > totalPoints) then
                DynamicCP.dbg("Ran out of points at " .. GetChampionSkillName(id))
                local overflow = currentTotalPoints + pointsToAllocate - totalPoints
                desiredPoints = desiredPoints - overflow
                pointsToAllocate = totalPoints - currentTotalPoints
            end

            -- "Put" the points in
            DynamicCP.dbg(string.format("Putting %d points into %s", pointsToAllocate, GetChampionSkillName(id)))
            pendingPoints[id] = desiredPoints
            currentTotalPoints = currentTotalPoints + pointsToAllocate

            -- If it's slottable, put it in desired slottables in order of maxing
            if (#slottables < 4 and CanChampionSkillTypeBeSlotted(GetChampionSkillType(id))) then
                if (desiredPoints == GetChampionSkillMaxPoints(id)) then
                    if (node.deprioritizeSlotting) then
                        table.insert(deprioritizedSlottables, id)
                    else
                        table.insert(slottables, id)
                    end
                elseif (WouldChampionSkillNodeBeUnlocked(id, desiredPoints)) then
                    -- Or if it's not maxed, deprioritize it
                    table.insert(deprioritizedSlottables, id)
                end
            end

            -- Not enough points to continue
            if (currentTotalPoints >= totalPoints) then
                -- If there were deprioritizeSlotting slottables, they can be slotted if there is still space
                for _, id in ipairs(deprioritizedSlottables) do
                    if (#slottables >= 4) then
                        break
                    end
                    table.insert(slottables, id)
                end

                return pendingCP
            end
        end
    end
    DynamicCP.dbg("Finished all desired nodes")
    return pendingCP
end
DynamicCP.ApplySmartPreset = ApplySmartPreset -- /script DynamicCP.ApplySmartPreset(67)

-----------------------------------------------------------
-- To be called from presets
-----------------------------------------------------------
local ROLE_ICONS = {
    [LFG_ROLE_TANK] = "|t100%:100%:esoui/art/lfg/lfg_tank_down_no_glow_64.dds|t",
    [LFG_ROLE_HEAL] = "|t100%:100%:esoui/art/lfg/lfg_healer_down_no_glow_64.dds|t",
    [LFG_ROLE_DPS] = "|t100%:100%:esoui/art/lfg/lfg_dps_down_no_glow_64.dds|t",
}

-- "apply" is a misnomer; it just returns the CP table with the desired points
DynamicCP.SMART_PRESETS = {
    Green = {
        ["DEFAULT_SMART_GREEN_COMBAT"] = {
            name = function()
                return "Auto Combat |t100%:100%:esoui/art/icons/mapkey/mapkey_raiddungeon.dds|t"
            end,
            applyFunc = DynamicCP.SmartPresets.ApplyGreenCombat,
        },
        ["DEFAULT_SMART_GREEN_LOOT_GOBLIN"] = {
            name = function()
                return "Auto Craft/Loot |t80%:80%:esoui/art/icons/ability_tradecraft_005.dds|t"
            end,
            applyFunc = DynamicCP.SmartPresets.ApplyGreenLootGoblin,
        },
        ["DEFAULT_SMART_GREEN_THIEVING"] = {
            name = function()
                return "Auto Thieving |t100%:100%:esoui/art/icons/crowncrate_sweetroll.dds|t"
            end,
            applyFunc = DynamicCP.SmartPresets.ApplyGreenThieving,
        },
    },
    Blue = {
        ["DEFAULT_SMART_BLUE_PVE"] = {
            name = function()
                local fatecarverUnlocked, isStamHigher, isPragmatic, craftingMaxed, jabsUnlocked, isHABuild, blightedBlastbonesUnlocked = GetDecisions()
                local build
                if (isHABuild) then
                    build = " |t80%:80%:esoui/art/icons/death_recap_shock_ranged.dds|t"
                elseif (fatecarverUnlocked) then
                    build = " |t80%:80%:esoui/art/icons/ability_arcanist_002.dds|t"
                elseif (jabsUnlocked) then
                    build = " |t80%:80%:esoui/art/icons/ability_templar_trained_attacker.dds|t"
                elseif (blightedBlastbonesUnlocked) then
                    build = " |t80%:80%:esoui/art/icons/ability_necromancer_002_a.dds|t"
                else
                    build = ""
                end
                return string.format("Auto PvE %s%s%s",
                    ROLE_ICONS[GetSelectedLFGRole()] or "?",
                    build,
                    isStamHigher and "|t100%:100%:esoui/art/characterwindow/gamepad/gp_charactersheet_staminaicon.dds|t" or "|t100%:100%:esoui/art/characterwindow/gamepad/gp_charactersheet_magickaicon.dds|t"
                    )
            end,
            applyFunc = DynamicCP.SmartPresets.ApplyBluePVE,
        },
    },
    Red = {
        ["DEFAULT_SMART_RED_PVE"] = {
            name = function()
                local fatecarverUnlocked, isStamHigher, isPragmatic = GetDecisions()
                return string.format("Auto PvE %s%s",
                    ROLE_ICONS[GetSelectedLFGRole()] or "?",
                    isPragmatic and " |t80%:80%:esoui/art/icons/ability_arcanist_002_b.dds|t" or ""
                    )
            end,
            applyFunc = DynamicCP.SmartPresets.ApplyRedPVE,
        },
    },
}


---------------------------------------------------------------------
-- Apply, yoinked from presets.lua
---------------------------------------------------------------------
local isRespeccing = false

local HOTBAR_OFFSET = {
    Green = 0,
    Blue = 4,
    Red = 8,
}

-- Apply the slottables
local function ApplySlottables(tree, presetName)
    local slottablesResult

    -- From smart preset
    slottablesResult = DynamicCP.SMART_PRESETS[tree][presetName].applyFunc().slottables


    local offset = HOTBAR_OFFSET[tree]
    for i = 1, 4 do
        local skillId = slottablesResult[i] or -1
        DynamicCP.SetSlottableInIndex(i + offset, skillId)
        DynamicCP.dbg(zo_strformat("adding <<C:1>> to slot <<2>>", GetChampionSkillName(skillId), i + offset))
    end
end

-- When apply button is clicked
local function ApplyPreset(tree, presetName)
    DynamicCP.dbg("Attempting to apply \"" .. presetName .. "\" to the " .. tree .. " tree.")

    -- Use smart preset
    local cp = DynamicCP.SMART_PRESETS[tree][presetName].applyFunc()


    local currentCP = DynamicCP.GetCommittedCP()

    -- First find all of the slottable skillIds to check them later
    local currentHotbar = {}
    for slotIndex = 1, 12 do
        local skillId = GetSlotBoundId(slotIndex, HOTBAR_CATEGORY_CHAMPION)
        currentHotbar[skillId] = slotIndex
    end

    if (not isRespeccing) then
        DynamicCP.ClearPendingCP()
        DynamicCP.ClearPendingSlottables()
        isRespeccing = true
    end

    -- Apply all stars within the tree
    local disciplineIndex = TREE_TO_DISCIPLINE[tree]
    local hasOverMaxPoints = false
    for skillIndex = 1, GetNumChampionDisciplineSkills(disciplineIndex) do
        local skillId = GetChampionSkillId(disciplineIndex, skillIndex)
        local numPoints = 0
        if (cp[disciplineIndex] and cp[disciplineIndex][skillId] ~= nil) then
            local maxPoints = GetChampionSkillMaxPoints(skillId)
            if (cp[disciplineIndex][skillId] > maxPoints) then
                numPoints = maxPoints
                hasOverMaxPoints = true
            else
                numPoints = cp[disciplineIndex][skillId]
            end
        else
            DynamicCP.dbg("else" .. GetChampionSkillName(skillId))
            numPoints = 0
        end

        -- Unslot slottables that are no longer slottable because of not enough points
        -- We still do this even though slottables are replaced later because user could have slotStars setting off [TODO: is this still needed?]
        if (currentHotbar[skillId] and not WouldChampionSkillNodeBeUnlocked(skillId, numPoints)) then
            DynamicCP.dbg("unslotting" .. GetChampionSkillName(skillId))
            DynamicCP.SetSlottableInIndex(currentHotbar[skillId], -1)
        end

        DynamicCP.SetStarPoints(disciplineIndex, skillId, numPoints)
    end

    -- Slottables
    ApplySlottables(tree, presetName)
end

local function RefreshSmartPresets(green, blue, red)
    DynamicCP.ClearPendingCP()
    DynamicCP.ClearPendingSlottables()

    if (green and green ~= "NONE") then
        ApplyPreset("Green", green)
    end
    if (blue and blue ~= "NONE") then
        ApplyPreset("Blue", blue)
    end
    if (red and red ~= "NONE") then
        ApplyPreset("Red", red)
    end
end
DynamicCP.RefreshSmartPresetsApplicationFromSettings = RefreshSmartPresets

local function ConfirmPresets()
    local needsRespec = DynamicCP.NeedsRespec()
    DynamicCP.dbg("needs respec? " .. (needsRespec and "yes" or "no"))

    PrepareChampionPurchaseRequest(needsRespec)
    DynamicCP.ConvertPendingPointsToPurchase()
    DynamicCP.ConvertPendingSlottablesToPurchase()
    SendChampionPurchaseRequest()

    DynamicCP.ClearPendingCP()
    DynamicCP.ClearPendingSlottables()
    isRespeccing = false
end
DynamicCP.ConfirmSmartPresetsFromSettings = ConfirmPresets
