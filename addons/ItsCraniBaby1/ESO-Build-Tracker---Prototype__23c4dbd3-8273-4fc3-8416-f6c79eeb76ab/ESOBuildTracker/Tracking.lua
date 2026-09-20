local A = ESOBuildTracker

function A.Normalize(value)
    local text = tostring(value or ""):gsub("|c%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("%^.*$", "")
    text = text:gsub("%s+", " "):match("^%s*(.-)%s*$")
    return zo_strlower and zo_strlower(text) or string.lower(text)
end

function A.ActiveBuild()
    for _, build in ipairs(A.saved and A.saved.builds or {}) do
        if build.id == A.saved.activeBuildId then return build end
    end
end

function A.FindItem(snapshot, key)
    for _, item in ipairs(snapshot and snapshot.equipment or {}) do
        if item.key == key then return item end
    end
end

function A.GearGoal(item)
    if not item or item.status ~= "equipped" then return nil end
    return {
        status = "equipped", setId = item.set and item.set.id or (item.noSet and 0 or nil),
        setName = item.set and item.set.name or nil, trait = item.trait,
        quality = item.quality, armorType = item.armorType ~= ARMORTYPE_NONE and item.armorType or nil,
        weaponType = item.weaponType ~= WEAPONTYPE_NONE and item.weaponType or nil,
        enchantName = item.enchantReadComplete and (item.enchantName or "") or nil,
        requiredCP = item.requiredCP, requiredLevel = item.requiredLevel,
    }
end

function A.SkillGoal(skill)
    if not skill or skill.status ~= "slotted" then return nil end
    return { status = "slotted", name = skill.name, actionType = skill.actionType,
        boundId = skill.boundId, abilityId = skill.abilityId, morph = skill.morph,
        craftedAbilityId = skill.craftedAbilityId, scripts = A.Copy(skill.scripts) }
end

function A.CreateBuild(name, snapshot)
    if #A.saved.builds >= A.maxBuilds then return nil, "Ten builds are already saved. Delete a build before creating another." end
    if snapshot and snapshot.coreDataComplete == false then return nil, "Cannot copy a capture with unreadable gear or bars." end
    name = tostring(name or ""):match("^%s*(.-)%s*$")
    if name == "" then name = "Build " .. A.saved.nextBuildNumber end
    local build = { id = A.saved.nextBuildNumber, name = name, schemaVersion = 1,
        gear = {}, skills = { {}, {} }, stats = {}, notes = "" }
    A.saved.nextBuildNumber = A.saved.nextBuildNumber + 1
    if snapshot then
        for _, item in ipairs(snapshot.equipment) do build.gear[item.key] = A.GearGoal(item) end
        for barIndex, bar in ipairs(snapshot.bars) do
            for index, skill in ipairs(bar.slots) do build.skills[barIndex][index] = A.SkillGoal(skill) end
        end
    end
    table.insert(A.saved.builds, build)
    A.saved.activeBuildId = build.id
    return build
end

function A.DeleteBuild(id)
    for i, build in ipairs(A.saved.builds) do
        if build.id == id then
            table.remove(A.saved.builds, i)
            if A.saved.activeBuildId == id then A.saved.activeBuildId = nil end
            return true
        end
    end
    return false
end

local function Result(status, issues)
    return { status = status, issues = issues or {} }
end

function A.CompareGear(item, goal)
    if not goal then return Result("Untracked") end
    if not item or item.status == "unavailable" then return Result("Unknown", { "Equipment could not be read." }) end
    if goal.status == "empty" then
        return item.status == "empty" and Result("Match") or Result("Needs changes", { "This slot should be empty." })
    end
    if item.status == "empty" then return Result("Missing", { "Equip an item that meets this slot's target." }) end
    local issues, unknown = {}, false
    local function Check(label, actual, expected, minimum)
        if expected == nil then return end
        if actual == nil then unknown = true; issues[#issues + 1] = label .. ": unavailable"
        elseif minimum and actual < expected or not minimum and actual ~= expected then
            issues[#issues + 1] = label .. ": needs change"
        end
    end
    if goal.setId ~= nil then
        Check("Set", item.set and item.set.id or (item.noSet and 0 or nil), goal.setId)
    elseif goal.setName ~= nil then
        Check("Set", item.set and A.Normalize(item.set.name) or (item.noSet and "" or nil), A.Normalize(goal.setName))
    end
    Check("Trait", item.trait, goal.trait)
    Check("Quality", item.quality, goal.quality, true)
    Check("Armor weight", item.armorType, goal.armorType)
    Check("Weapon type", item.weaponType, goal.weaponType)
    Check("CP requirement", item.requiredCP, goal.requiredCP, true)
    Check("Level requirement", item.requiredLevel, goal.requiredLevel, true)
    if goal.enchantName ~= nil then
        Check("Enchantment type", item.enchantReadComplete and A.Normalize(item.enchantName) or nil, A.Normalize(goal.enchantName))
    end
    if #issues == 0 then return Result("Match") end
    return Result(unknown and "Unknown" or "Needs changes", issues)
end

function A.CompareSkill(skill, goal)
    if not goal then return Result("Untracked") end
    if not skill or skill.status == "unavailable" then return Result("Unknown", { "Skill slot could not be read." }) end
    if goal.status == "empty" then
        return skill.status == "empty" and Result("Match") or Result("Needs changes", { "This skill slot should be empty." })
    end
    if skill.status == "empty" then return Result("Missing", { "Slot " .. (goal.name or "the target skill") .. "." }) end
    local matches
    if goal.craftedAbilityId then
        matches = skill.craftedAbilityId == goal.craftedAbilityId
    elseif goal.boundId then
        matches = skill.actionType == goal.actionType and skill.boundId == goal.boundId
        -- Normal ability IDs can vary with rank. Compare their progression and
        -- the requested morph, while retaining explicit IDs for special actions.
        if not matches and goal.actionType == ACTION_TYPE_ABILITY and skill.actionType == ACTION_TYPE_ABILITY and goal.morph ~= nil then
            local ok1, p1 = A.Call(nil, "GetAbilityProgressionXPInfoFromAbilityId", goal.boundId)
            local ok2, p2 = A.Call(nil, "GetAbilityProgressionXPInfoFromAbilityId", skill.boundId)
            matches = ok1 and ok2 and p1 == p2 and skill.morph == goal.morph
        end
    else
        matches = A.Normalize(skill.name) == A.Normalize(goal.name)
    end
    if not matches then return Result("Needs changes", { "Target skill: " .. (goal.name or "Unavailable") }) end
    for index, script in pairs(goal.scripts or {}) do
        local current = skill.scripts and skill.scripts[index]
        if not current or current.id ~= script.id then
            return Result("Needs changes", { "Scribed skill scripts differ from the target." })
        end
    end
    return Result("Match")
end

function A.StatBarKey(snapshot)
    if snapshot and snapshot.activeHotbarCategory == HOTBAR_CATEGORY_PRIMARY then return "front" end
    if snapshot and snapshot.activeHotbarCategory == HOTBAR_CATEGORY_BACKUP then return "back" end
end

function A.CompareStat(value, minimum)
    if minimum == nil then return Result("Untracked") end
    if value == nil then return Result("Unknown") end
    return value >= minimum and Result("Match") or Result("Below target", { "Need " .. tostring(minimum - value) .. " more at this capture." })
end

function A.Progress(snapshot, build)
    local counts = { total = 0, matched = 0, missing = 0, change = 0, unknown = 0 }
    if not snapshot or not build then return counts end
    local function Count(result)
        if result.status == "Untracked" then return end
        counts.total = counts.total + 1
        if result.status == "Match" then counts.matched = counts.matched + 1
        elseif result.status == "Missing" then counts.missing = counts.missing + 1
        elseif result.status == "Unknown" then counts.unknown = counts.unknown + 1
        else counts.change = counts.change + 1 end
    end
    for key, goal in pairs(build.gear) do Count(A.CompareGear(A.FindItem(snapshot, key), goal)) end
    for barIndex, goals in ipairs(build.skills) do
        for index, goal in pairs(goals) do Count(A.CompareSkill(snapshot.bars[barIndex].slots[index], goal)) end
    end
    -- Stats are context-dependent; show them separately, not as permanent
    -- completion of a gear/skill build.
    return counts
end

function A.GearGoalText(goal)
    if not goal then return "No target for this slot. Select the row to set one." end
    if goal.status == "empty" then return "Target: leave this slot empty." end
    local lines = { "TARGET" }
    if goal.setId == 0 then lines[#lines + 1] = "Set: no set"
    elseif goal.setName then lines[#lines + 1] = "Set: " .. goal.setName end
    if goal.trait ~= nil then lines[#lines + 1] = "Trait: " .. A.EnumName("SI_ITEMTRAITTYPE", goal.trait) end
    if goal.quality ~= nil then lines[#lines + 1] = "Quality: at least " .. A.EnumName("SI_ITEMQUALITY", goal.quality) end
    if goal.armorType then lines[#lines + 1] = "Weight: " .. A.EnumName("SI_ARMORTYPE", goal.armorType) end
    if goal.weaponType then lines[#lines + 1] = "Weapon: " .. A.EnumName("SI_WEAPONTYPE", goal.weaponType) end
    if goal.enchantName ~= nil then lines[#lines + 1] = "Enchantment type: " .. (goal.enchantName == "" and "None" or goal.enchantName) end
    if goal.requiredCP and goal.requiredCP > 0 then lines[#lines + 1] = "Minimum CP requirement: " .. goal.requiredCP end
    if goal.requiredLevel and goal.requiredLevel > 0 then lines[#lines + 1] = "Minimum level requirement: " .. goal.requiredLevel end
    if #lines == 1 then lines[#lines + 1] = "Any equipped item; no other requirements." end
    return table.concat(lines, "\n")
end

function A.SetCatalog()
    if A.setCatalog then return A.setCatalog end
    local choices, seen, last = {}, {}, nil
    for _ = 1, 4096 do
        local id = A.Call(nil, "GetNextItemSetCollectionId", last)
        if not id or id == 0 or seen[id] then break end
        seen[id], last = true, id
        local name = A.Call(nil, "GetItemSetName", id)
        if name and name ~= "" then choices[#choices + 1] = { id = id, name = A.CleanName(name) } end
    end
    table.sort(choices, function(a, b) return A.Normalize(a.name) < A.Normalize(b.name) end)
    A.setCatalog = choices
    return choices
end

function A.SkillCatalog(ultimate)
    local choices, seen = {}, {}
    for skillType = 1, A.Call(nil, "GetNumSkillTypes") or 0 do
        for line = 1, A.Call(nil, "GetNumSkillLines", skillType) or 0 do
            for index = 1, A.Call(nil, "GetNumSkillAbilities", skillType, line) or 0 do
                local _, _, _, passive, isUltimate = A.Call(nil, "GetSkillAbilityInfo", skillType, line, index)
                if passive == false and isUltimate == ultimate then
                    for morph = 0, 2 do
                        local id = A.Call(nil, "GetSpecificSkillAbilityInfo", skillType, line, index, morph, 4)
                        if id and id > 0 and not seen[id] then
                            local name = A.Call(nil, "GetAbilityName", id, "player")
                            if name and name ~= "" then
                                seen[id] = true
                                choices[#choices + 1] = { name = A.CleanName(name), status = "slotted", boundId = id,
                                    abilityId = id, actionType = ACTION_TYPE_ABILITY, morph = morph }
                            end
                        end
                    end
                end
            end
        end
    end
    table.sort(choices, function(a, b) return A.Normalize(a.name) < A.Normalize(b.name) end)
    return choices
end
