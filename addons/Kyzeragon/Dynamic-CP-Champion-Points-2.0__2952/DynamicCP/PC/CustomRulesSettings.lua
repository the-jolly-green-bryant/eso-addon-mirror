local selectedRuleName = nil
-- /script d(DynamicCP.savedOptions.customRules.rules)

---------------------------------------------------------------------
-- Trigger dropdown
local triggerDisplays = {
    DynamicCP.TRIGGER_TRIAL,
    DynamicCP.TRIGGER_GROUP_ARENA,
    DynamicCP.TRIGGER_SOLO_ARENA,
    DynamicCP.TRIGGER_GROUP_DUNGEON,
    DynamicCP.TRIGGER_PUBLIC_INSTANCE,
    DynamicCP.TRIGGER_GROUP_INSTANCE,
    DynamicCP.TRIGGER_OVERLAND,
    DynamicCP.TRIGGER_CYRO,
    DynamicCP.TRIGGER_IC,
    DynamicCP.TRIGGER_HOUSE,
    DynamicCP.TRIGGER_ZONEID,
    DynamicCP.TRIGGER_MAPID,
    DynamicCP.TRIGGER_BOSSNAME,
    DynamicCP.TRIGGER_LEAVE_BOSSNAME,
    DynamicCP.TRIGGER_BOSS_DIED,
}

---------------------------------------------------------------------
-- Get string for preview
local triggerToPreview = {
    [DynamicCP.TRIGGER_TRIAL]                = "entering any trial",
    [DynamicCP.TRIGGER_GROUP_ARENA]          = "entering any group arena",
    [DynamicCP.TRIGGER_SOLO_ARENA]           = "entering any solo arena",
    [DynamicCP.TRIGGER_GROUP_DUNGEON]        = "entering any group dungeon",
    [DynamicCP.TRIGGER_PUBLIC_INSTANCE]      = "entering any public instance*",
    [DynamicCP.TRIGGER_GROUP_INSTANCE]       = "entering any group instance**",
    [DynamicCP.TRIGGER_OVERLAND]             = "entering any overland zone",
    [DynamicCP.TRIGGER_CYRO]                 = "entering Cyrodiil",
    [DynamicCP.TRIGGER_IC]                   = "entering Imperial City or Sewers",
    [DynamicCP.TRIGGER_HOUSE]                = "entering any player house",
    [DynamicCP.TRIGGER_ZONEID]               = "entering specific zone ID",
    [DynamicCP.TRIGGER_MAPID]                = "entering zone with specific map ID",
    [DynamicCP.TRIGGER_BOSSNAME]             = "encountering specific bosses with name",
    [DynamicCP.TRIGGER_LEAVE_BOSSNAME]       = "leaving specific bosses with name",
    [DynamicCP.TRIGGER_BOSS_DIED]            = "death of specific bosses with name",
}

local hasVet = {
    [DynamicCP.TRIGGER_TRIAL]                = true,
    [DynamicCP.TRIGGER_GROUP_ARENA]          = true,
    [DynamicCP.TRIGGER_SOLO_ARENA]           = true,
    [DynamicCP.TRIGGER_GROUP_DUNGEON]        = true,
    [DynamicCP.TRIGGER_PUBLIC_INSTANCE]      = false,
    [DynamicCP.TRIGGER_GROUP_INSTANCE]       = false,
    [DynamicCP.TRIGGER_OVERLAND]             = false,
    [DynamicCP.TRIGGER_CYRO]                 = false,
    [DynamicCP.TRIGGER_IC]                   = false,
    [DynamicCP.TRIGGER_HOUSE]                = false,
    [DynamicCP.TRIGGER_ZONEID]               = true,
    [DynamicCP.TRIGGER_MAPID]                = true,
    [DynamicCP.TRIGGER_BOSSNAME]             = true,
    [DynamicCP.TRIGGER_LEAVE_BOSSNAME]       = true,
    [DynamicCP.TRIGGER_BOSS_DIED]            = true,
}

local isBossTrigger = {
    [DynamicCP.TRIGGER_BOSSNAME] = true,
    [DynamicCP.TRIGGER_LEAVE_BOSSNAME] = true,
    [DynamicCP.TRIGGER_BOSS_DIED] = true,
}

local canReeval = {
    [DynamicCP.TRIGGER_BOSSNAME] = true,
    [DynamicCP.TRIGGER_LEAVE_BOSSNAME] = true,
    [DynamicCP.TRIGGER_BOSS_DIED] = true,
}

local function GetCurrentPreview()
    if (not selectedRuleName) then
        return ""
    end

    local rule = DynamicCP.savedOptions.customRules.rules[selectedRuleName]

    -- The main trigger of the rule
    local previewTrigger = triggerToPreview[rule.trigger]
    if (rule.param1 == "*") then
        previewTrigger = "entering any zone"
    end

    -- Build the extra info into a more readable string
    local triggerExtraInfo = ""
    if (rule.trigger == DynamicCP.TRIGGER_ZONEID and rule.param1 ~= "*") then
        local zoneIds = {}
        for str in string.gmatch(rule.param1, "([^%%]+)") do
            str = string.gsub(str, "^%s+", "")
            str = string.gsub(str, "%s+$", "")
            table.insert(zoneIds, string.format("%s (%s)", str, GetZoneNameById(tonumber(str))))
        end
        triggerExtraInfo = " " .. table.concat(zoneIds, ", ")
    elseif (isBossTrigger[rule.trigger] or rule.trigger == DynamicCP.TRIGGER_MAPID) then
        triggerExtraInfo = " " .. string.gsub(rule.param1, "%%", "|r or |c88FF88")
    end

    -- Add vet or not
    local difficultyString = ""
    if (hasVet[rule.trigger]) then
        if (rule.normal and rule.veteran) then
            difficultyString = " |c88FF88on any difficulty|r"
        elseif (rule.normal) then
            difficultyString = " |c88FF88on normal|r"
        elseif (rule.veteran) then
            difficultyString = " |c88FF88on vet|r"
        else
            difficultyString = " |cFF4444on neither difficulty|r"
        end
    end

    -- Add roles
    local roleString = ""
    if (rule.tank and rule.healer and rule.dps) then
        roleString = "any role"
    elseif (not rule.tank and not rule.healer and not rule.dps) then
        roleString = "|cFF4444no roles|r"
    else
        local roles = {}
        if (rule.tank) then
            table.insert(roles, "tank")
        end
        if (rule.healer) then
            table.insert(roles, "healer")
        end
        if (rule.dps) then
            table.insert(roles, "dps")
        end
        roleString = table.concat(roles, "/")
    end

    -- The result to actually do
    local result = "|c88FF88re-evaluate all rules|r for the current zone."
    if (not rule.reeval) then
        result = string.format("slot the following stars %s:",
            DynamicCP.savedOptions.customRules.overrideOrder and "in this specific order" or ", ignoring them if they are already slotted")
    end

    -- Format everything so far
    local preview = string.format("Upon |c88FF88%s%s|r%s as |c88FF88%s|r, %sautomatically %s",
        previewTrigger,
        triggerExtraInfo,
        difficultyString,
        roleString,
        DynamicCP.savedOptions.customRules.autoSlot and "" or "semi-",
        result
        )

    -- Add the stars
    if (not rule.reeval) then
        -- Show slot sets
        local trees = {
            ["Green"] = "a5d752",
            ["Blue"] = "59bae7",
            ["Red"] = "e46b2e",
        }
        for tree, color in pairs(trees) do
            local slotSetId = rule.stars[tree]
            if (slotSetId and slotSetId ~= -1) then
                local slotSet = DynamicCP.savedOptions.slotGroups[tree][slotSetId]
                local slotSetStars = ""
                for i = 1, 4 do
                    local skillId = slotSet[i]
                    if (skillId) then
                        local comma = ", "
                        if (slotSetStars == "") then comma = "" end
                        slotSetStars = zo_strformat("<<1>><<2>><<3>>", slotSetStars, comma, GetChampionSkillName(skillId))
                    end
                end
                preview = zo_strformat("<<1>>\n|c<<2>>Slottable set \"<<3>>\" (Current: <<4>>)|r", preview, color, slotSet.name, slotSetStars)
            end
        end

        for slotIndex, skillId in ipairs(rule.stars) do
            if (skillId ~= -1) then
                local color = "e46b2e" -- Red
                if (slotIndex <= 8) then color = "59bae7" end -- Blue
                if (slotIndex <= 4) then color = "a5d752" end -- Green
                preview = zo_strformat("<<1>>\n|c<<4>><<C:2>> in slot <<3>>|r", preview, GetChampionSkillName(skillId), slotIndex, color)
            end
        end
    end

    -- Add characters part
    local isAllChars = true
    local charNames = {}
    for index = 1, GetNumCharacters() do
        local name, _, _, _, _, _, id, _ = GetCharacterInfo(index)
        local hasChar = rule.chars[id]
        isAllChars = isAllChars and hasChar
        if (hasChar) then
            table.insert(charNames, zo_strformat("<<1>>", name))
        end
    end

    if (isAllChars) then
        preview = preview .. "\nThis rule will apply to |c88FF88all characters|r if the role also matches."
    else
        preview = preview .. "\nThis rule will apply to these characters if the role also matches: |c88FF88" .. table.concat(charNames, "|r, |c88FF88")
        preview = preview .. "|r"
    end

    return preview
end

---------------------------------------------------------------------
-- Add the data for per-character toggles
local function AddOptionsForEachCharacter(ruleName)
    for index = 1, GetNumCharacters() do
        local _, _, _, _, _, _, id, _ = GetCharacterInfo(index)
        DynamicCP.savedOptions.customRules.rules[ruleName].chars[id] = true
    end
end
DynamicCP.AddOptionsForEachCharacter = AddOptionsForEachCharacter

---------------------------------------------------------------------
-- Add a new rule
local function CreateNewRule()
    local newIndex = 1
    while (DynamicCP.savedOptions.customRules.rules["Rule " .. tostring(newIndex)] ~= nil) do
        newIndex = newIndex + 1
    end
    local newName = "Rule " .. tostring(newIndex)

    local newRule = {
        name = newName,
        trigger = DynamicCP.TRIGGER_TRIAL,
        priority = 500,
        normal = true,
        veteran = true,
        reeval = false,
        stars = {
            [1] = -1,
            [2] = -1,
            [3] = -1,
            [4] = -1,
            [5] = -1,
            [6] = -1,
            [7] = -1,
            [8] = -1,
            [9] = -1,
            [10] = -1,
            [11] = -1,
            [12] = -1,
        },
        tank = true,
        healer = true,
        dps = true,
        chars = {},
        param1 = "",
        param2 = "",
    }

    DynamicCP.savedOptions.customRules.rules[newName] = newRule
    selectedRuleName = newName

    AddOptionsForEachCharacter(newName)

    DynamicCP.SortRuleKeys()
    local rulesDropdown = WINDOW_MANAGER:GetControlByName("DynamicCP#RulesDropdown")
    rulesDropdown:UpdateChoices(DynamicCP.GetSortedKeyDisplays(), DynamicCP.GetSortedKeys())
    rulesDropdown.dropdown:SetSelectedItem(selectedRuleName)
end

---------------------------------------------------------------------
-- Duplicate existing rule
local function DeepCopyRule(oldRule, newRule)
    newRule.name = oldRule.name
    newRule.trigger = oldRule.trigger
    newRule.priority = oldRule.priority
    newRule.normal = oldRule.normal
    newRule.veteran = oldRule.veteran
    newRule.tank = oldRule.tank
    newRule.healer = oldRule.healer
    newRule.dps = oldRule.dps
    newRule.param1 = oldRule.param1
    newRule.param2 = oldRule.param2
    newRule.reeval = oldRule.reeval or false

    newRule.stars = {}
    for k, v in pairs(oldRule.stars) do
        newRule.stars[k] = v
    end

    newRule.chars = {}
    if (oldRule.chars) then
        for id, value in pairs(oldRule.chars) do
            newRule.chars[id] = value
        end
    end
end

local function DuplicateRule()
    local oldName = selectedRuleName
    CreateNewRule()

    local newRule = DynamicCP.savedOptions.customRules.rules[selectedRuleName]
    local oldRule = DynamicCP.savedOptions.customRules.rules[oldName]

    DeepCopyRule(oldRule, newRule)
end

---------------------------------------------------------------------
-- Build the stars dropdown choices
local starDisplays = {}
local starValues = {}

local function UpdateStarsDropdowns()
    local dropdowns = {
        CraftStar1Dropdown = 1,
        CraftStar2Dropdown = 1,
        CraftStar3Dropdown = 1,
        CraftStar4Dropdown = 1,
        WarfareStar1Dropdown = 2,
        WarfareStar2Dropdown = 2,
        WarfareStar3Dropdown = 2,
        WarfareStar4Dropdown = 2,
        FitnessStar1Dropdown = 3,
        FitnessStar2Dropdown = 3,
        FitnessStar3Dropdown = 3,
        FitnessStar4Dropdown = 3,
    }

    for reference, disciplineIndex in pairs(dropdowns) do
        local dropdown = WINDOW_MANAGER:GetControlByName("DynamicCP#" .. reference)
        if (dropdown) then -- May not be initialized if menu hasn't been opened yet
            dropdown:UpdateChoices(starDisplays[disciplineIndex], starValues[disciplineIndex])
        end
    end
end
DynamicCP.UpdateStarsDropdowns = UpdateStarsDropdowns

local function BuildStarsDropdowns()
    DynamicCP.dbg("building stars dropdowns")
    starDisplays = {}
    starValues = {}

    local unlockedColor = {
        [1] = "a5d752",
        [2] = "59bae7",
        [3] = "e46b2e",
    }
    local unsortedStars = {}
    for disciplineIndex = 1, GetNumChampionDisciplines() do
        starDisplays[disciplineIndex] = {"--"}
        starValues[disciplineIndex] = {-1}
        for skillIndex = 1, GetNumChampionDisciplineSkills(disciplineIndex) do
            local skillId = GetChampionSkillId(disciplineIndex, skillIndex)
            if (CanChampionSkillTypeBeSlotted(GetChampionSkillType(skillId))) then
                local name = zo_strformat("<<C:1>>", GetChampionSkillName(skillId))
                local displayName = name
                local numPoints = GetNumPointsSpentOnChampionSkill(skillId)
                if (WouldChampionSkillNodeBeUnlocked(skillId, GetNumPointsSpentOnChampionSkill(skillId))) then
                    displayName = string.format("|c%s%s - %d/%d|r",
                        unlockedColor[disciplineIndex],
                        name,
                        numPoints,
                        GetChampionSkillMaxPoints(skillId))
                end
                table.insert(unsortedStars, {
                    disciplineIndex = disciplineIndex,
                    skillId = skillId,
                    name = name,
                    displayName = displayName,
                })
            end
        end
    end

    table.sort(unsortedStars, function(item1, item2)
            return item1.name < item2. name
        end)
    for _, data in ipairs(unsortedStars) do
        table.insert(starDisplays[data.disciplineIndex], data.displayName)
        table.insert(starValues[data.disciplineIndex], data.skillId)
    end
end
DynamicCP.BuildStarsDropdowns = BuildStarsDropdowns


---------------------------------------------------------------------
-- Build the slottable set dropdown choices
local slotSetDisplays = {}
local slotSetValues = {}

local function UpdateSlotSetDropdowns()
    local dropdowns = {
        CraftSlotSetDropdown = "Green",
        WarfareSlotSetDropdown = "Blue",
        FitnessSlotSetDropdown = "Red",
    }

    for reference, tree in pairs(dropdowns) do
        local dropdown = WINDOW_MANAGER:GetControlByName("DynamicCP#" .. reference)
        if (dropdown) then -- May not be initialized if menu hasn't been opened yet
            dropdown:UpdateChoices(slotSetDisplays[tree], slotSetValues[tree])
        end
    end
end
DynamicCP.UpdateSlotSetDropdowns = UpdateSlotSetDropdowns

local function BuildSlotSetDropdowns()
    DynamicCP.dbg("building slot set dropdowns")
    slotSetDisplays = {}
    slotSetValues = {}

    local treeToColor = {
        ["Green"] = "a5d752",
        ["Blue"] = "59bae7",
        ["Red"] = "e46b2e",
    }
    local unsortedSets = {}
    for tree, color in pairs(treeToColor) do
        slotSetDisplays[tree] = {"--"}
        slotSetValues[tree] = {-1}
        for id, setData in pairs(DynamicCP.savedOptions.slotGroups[tree]) do
            local displayName = string.format("|c%s%s|r", color, setData.name)
            table.insert(unsortedSets, {
                tree = tree,
                name = setData.name,
                id = id,
                displayName = displayName,
            })
        end
    end

    table.sort(unsortedSets, function(item1, item2)
            return item1.name < item2.name
        end)
    for _, data in ipairs(unsortedSets) do
        table.insert(slotSetDisplays[data.tree], data.displayName)
        table.insert(slotSetValues[data.tree], data.id)
    end
end
DynamicCP.BuildSlotSetDropdowns = BuildSlotSetDropdowns


---------------------------------------------------------------------
-- Build the per-character toggles in advanced options
local function ToggleCharacterCheckboxes(matchingClassId)
    -- First pass checks if any of the relevant ones are off
    local shouldToggleOn = false
    for index = 1, GetNumCharacters() do
        local _, _, _, classId, _, _, id, _ = GetCharacterInfo(index)
        if (not matchingClassId or matchingClassId == classId) then
            if (not DynamicCP.savedOptions.customRules.rules[selectedRuleName].chars[id]) then
                shouldToggleOn = true
                break
            end
        end
    end

    -- Second pass turns them whichever way
    for index = 1, GetNumCharacters() do
        local name, _, _, classId, _, _, id, _ = GetCharacterInfo(index)
        if (not matchingClassId or matchingClassId == classId) then
            DynamicCP.savedOptions.customRules.rules[selectedRuleName].chars[id] = shouldToggleOn
        end
    end
end

local function MakeCheckboxesForEachCharacter()
    local controls = {
        {
            type = "description",
            title = nil,
            text = "You can choose to only apply this rule on certain characters. The role conditions will still apply.",
            width = "full",
        },
        -- idk, they take up a lot of space
        -- {
        --     type = "button",
        --     name = "Toggle Dragonknights",
        --     tooltip = "Toggle all dragonknights on or off",
        --     func = function() ToggleCharacterCheckboxes(1) end,
        --     width = "full",
        -- },
        -- {
        --     type = "button",
        --     name = "Toggle Sorcerers",
        --     tooltip = "Toggle all sorcerers on or off",
        --     func = function() ToggleCharacterCheckboxes(2) end,
        --     width = "full",
        -- },
        -- {
        --     type = "button",
        --     name = "Toggle Nightblades",
        --     tooltip = "Toggle all nightblades on or off",
        --     func = function() ToggleCharacterCheckboxes(3) end,
        --     width = "full",
        -- },
        -- {
        --     type = "button",
        --     name = "Toggle Templars",
        --     tooltip = "Toggle all templars on or off",
        --     func = function() ToggleCharacterCheckboxes(6) end,
        --     width = "full",
        -- },
        -- {
        --     type = "button",
        --     name = "Toggle Wardens",
        --     tooltip = "Toggle all wardens on or off",
        --     func = function() ToggleCharacterCheckboxes(4) end,
        --     width = "full",
        -- },
        -- {
        --     type = "button",
        --     name = "Toggle Necromancers",
        --     tooltip = "Toggle all necromancers on or off",
        --     func = function() ToggleCharacterCheckboxes(5) end,
        --     width = "full",
        -- },
        {
            type = "button",
            name = "Toggle All",
            tooltip = "Toggle all characters on or off",
            func = function() ToggleCharacterCheckboxes() end,
            width = "full",
        },
    }

    for index = 1, GetNumCharacters() do
        local name, _, _, classId, _, _, id, _ = GetCharacterInfo(index)
        local _, _, _, _, _, _, icon = GetClassInfo(GetClassIndexById(classId))
        name = zo_strformat("|t28:28:<<2>>|t <<1>>", name, icon)
        local checkboxControl = {
            type = "checkbox",
            name = name,
            tooltip = "Apply this rule if you are on " .. name,
            default = true,
            getFunc = function()
                return selectedRuleName ~= nil and DynamicCP.savedOptions.customRules.rules[selectedRuleName].chars[id] or false
            end,
            setFunc = function(value)
                if (not selectedRuleName) then return end
                DynamicCP.savedOptions.customRules.rules[selectedRuleName].chars[id] = value
            end,
            width = "full",
        }
        table.insert(controls, checkboxControl)
    end

    return controls
end

---------------------------------------------------------------------
local function MakeImportButtons()
    local controls = {
        {
            type = "description",
            title = nil,
            text = "You can import a full set of example rules to get you started. These are the rules that I personally use at the time of writing. All of these rules can also be found separately below, if you're curious about exactly what they do. |cFF4444This will overwrite ALL of your current rules!|r",
            width = "full",
        },
        {
            type = "button",
            name = "Import Kyzer's Rules",
            tooltip = "Import example set of custom rules. This will overwrite ALL of your current rules!",
            func = function()
                DynamicCP.savedOptions.customRules.rules = {}
                selectedRuleName = nil

                for name, data in pairs(DynamicCP.exampleRules) do
                    for ruleName, rule in pairs(data.rules) do
                        DynamicCP.savedOptions.customRules.rules[ruleName] = {}
                        DeepCopyRule(rule, DynamicCP.savedOptions.customRules.rules[ruleName])
                        DynamicCP.AddOptionsForEachCharacter(ruleName)
                    end
                end
                for name, data in pairs(DynamicCP.exampleBossRules) do
                    for ruleName, rule in pairs(data.rules) do
                        DynamicCP.savedOptions.customRules.rules[ruleName] = {}
                        DeepCopyRule(rule, DynamicCP.savedOptions.customRules.rules[ruleName])
                        DynamicCP.AddOptionsForEachCharacter(ruleName)
                    end
                end

                DynamicCP.SortRuleKeys()
                local rulesDropdown = WINDOW_MANAGER:GetControlByName("DynamicCP#RulesDropdown")
                rulesDropdown:UpdateChoices(DynamicCP.GetSortedKeyDisplays(), DynamicCP.GetSortedKeys())
                rulesDropdown.dropdown:SetSelectedItem(selectedRuleName)
            end,
            warning = "Import example set of custom rules. This will overwrite your current rules!",
            isDangerous = true,
            width = "half",
        },
        {
            type = "button",
            name = "Delete All Rules",
            tooltip = "Delete all rules. This cannot be undone!",
            func = function()
                DynamicCP.savedOptions.customRules.rules = {}
                selectedRuleName = nil

                DynamicCP.SortRuleKeys()
                local rulesDropdown = WINDOW_MANAGER:GetControlByName("DynamicCP#RulesDropdown")
                rulesDropdown:UpdateChoices(DynamicCP.GetSortedKeyDisplays(), DynamicCP.GetSortedKeys())
                rulesDropdown.dropdown:SetSelectedItem(selectedRuleName)
            end,
            warning = "Delete all rules. This cannot be undone!",
            isDangerous = true,
            width = "half",
        },
        {
            type = "description",
            title = nil,
            text = "These are sets of example rules for general triggers, along with their descriptions. All of these are included in the full set above. This will overwrite any rules that have the same name!",
            width = "full",
        },
    }

    -- Add buttons for each of the examples
    for name, data in pairs(DynamicCP.exampleRules) do
        local button = {
            type = "button",
            name = name,
            tooltip = data.description,
            func = function()
                for ruleName, rule in pairs(data.rules) do
                    DynamicCP.savedOptions.customRules.rules[ruleName] = {}
                    DeepCopyRule(rule, DynamicCP.savedOptions.customRules.rules[ruleName])
                    DynamicCP.AddOptionsForEachCharacter(ruleName)
                end

                DynamicCP.SortRuleKeys()
                local rulesDropdown = WINDOW_MANAGER:GetControlByName("DynamicCP#RulesDropdown")
                rulesDropdown:UpdateChoices(DynamicCP.GetSortedKeyDisplays(), DynamicCP.GetSortedKeys())
                rulesDropdown.dropdown:SetSelectedItem(selectedRuleName)
            end,
            width = "half",
        }
        table.insert(controls, button)
    end

    -- Add the boss rules
    table.insert(controls,
        {
            type = "description",
            title = nil,
            text = "Finally, these are advanced example rules that trigger on specific zones or specific bosses. These differences can be due to special mechanics, the ability or inability to flank those bosses for Backstabber, etc. All of these are included in the full set above. This will overwrite any rules that have the same name!",
            width = "full",
        })
    for name, data in pairs(DynamicCP.exampleBossRules) do
        local button = {
            type = "button",
            name = name,
            tooltip = data.description,
            func = function()
                for ruleName, rule in pairs(data.rules) do
                    DynamicCP.savedOptions.customRules.rules[ruleName] = {}
                    DeepCopyRule(rule, DynamicCP.savedOptions.customRules.rules[ruleName])
                    DynamicCP.AddOptionsForEachCharacter(ruleName)
                end

                DynamicCP.SortRuleKeys()
                local rulesDropdown = WINDOW_MANAGER:GetControlByName("DynamicCP#RulesDropdown")
                rulesDropdown:UpdateChoices(DynamicCP.GetSortedKeyDisplays(), DynamicCP.GetSortedKeys())
                rulesDropdown.dropdown:SetSelectedItem(selectedRuleName)
            end,
            width = "half",
        }
        table.insert(controls, button)
    end

    return controls
end

---------------------------------------------------------------------
function DynamicCP.CreateCustomRulesMenu()
    DynamicCP.SortRuleKeys()
    BuildStarsDropdowns()
    BuildSlotSetDropdowns()

    local LAM = LibAddonMenu2
    local panelData = {
        type = "panel",
        name = "Dynamic CP - Custom Rules",
        displayName = "|c3bdb5eDynamic CP - Custom Rules|r",
        author = "Kyzeragon",
        version = DynamicCP.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local optionsData = {
        {
            type = "header",
            name = "General Settings",
            width = "full",
        },
        {
            type = "checkbox",
            name = "Play sound",
            tooltip = "Play the champion points committed sound when slotting stars",
            default = true,
            getFunc = function() return DynamicCP.savedOptions.customRules.playSound end,
            setFunc = function(value)
                DynamicCP.savedOptions.customRules.playSound = value
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Show message in chat",
            tooltip = "Show a message in chatbox when slotting stars",
            default = true,
            getFunc = function() return DynamicCP.savedOptions.customRules.showInChat end,
            setFunc = function(value)
                DynamicCP.savedOptions.customRules.showInChat = value
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Show extra messages in chat",
            tooltip = "Show extra messages in chatbox when rule evaluation is delayed due to being in combat, on cooldown, etc.",
            default = true,
            getFunc = function() return DynamicCP.savedOptions.customRules.extraChat end,
            setFunc = function(value)
                DynamicCP.savedOptions.customRules.extraChat = value
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Override different order",
            tooltip = "Re-slot the stars in the specified order, even if they are already slotted in a different order",
            default = true,
            getFunc = function()
                return DynamicCP.savedOptions.customRules.overrideOrder
            end,
            setFunc = function(value)
                DynamicCP.savedOptions.customRules.overrideOrder = value
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Slot automatically",
            tooltip = "Automatically commit the stars instead of asking if you want to slot them",
            default = false,
            getFunc = function()
                return DynamicCP.savedOptions.customRules.autoSlot
            end,
            setFunc = function(value)
                DynamicCP.savedOptions.customRules.autoSlot = value
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Wait for combat on boss",
            tooltip = "If you are in combat when a boss rule is triggered, setting this to ON will delay the star slotting to when you exit combat. Setting this to OFF means the rule(s) will not be applied",
            default = true,
            getFunc = function()
                return DynamicCP.savedOptions.customRules.applyBossOnCombatEnd
            end,
            setFunc = function(value)
                DynamicCP.savedOptions.customRules.applyBossOnCombatEnd = value
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Wait for cooldown",
            tooltip = "If you are on ZOS's 30-second cooldown when a rule is triggered, setting this to ON will delay the star slotting to when the cooldown is over. Setting this to OFF means the rule(s) will not be applied",
            default = true,
            getFunc = function()
                return DynamicCP.savedOptions.customRules.applyOnCooldownEnd
            end,
            setFunc = function(value)
                DynamicCP.savedOptions.customRules.applyOnCooldownEnd = value
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Automatically detect stamina or magicka dps",
            tooltip = "For rules that will slot either Bloody Renewal or Siphoning Spells, check your character's max resources. If max stam is higher, Bloody Renewal will be slotted; if max mag is higher, Siphoning Spells will be slotted, regardless of which one is specified in the rule. To force the rule to follow the exact star instead, turn this OFF",
            default = true,
            getFunc = function()
                return DynamicCP.savedOptions.customRules.autoDetectStamMag
            end,
            setFunc = function(value)
                DynamicCP.savedOptions.customRules.autoDetectStamMag = value
            end,
            width = "full",
        },
        -- {
        --     type = "checkbox",
        --     name = "Prompt conflicts",
        --     tooltip = "If you don't have the specified star unlocked, or if there is no specified star for that slot, Dynamic CP will automatically slot other stars in its place to avoid an empty slot.\n\nIf ON, this setting will override the automatic slotting and instead show a prompt. So if you want to have automatic slotting when there are no problems, but get a confirmation dialog when there are problems, then set \"Slot automatically\" ON and \"Prompt conflicts\" ON",
        --     default = true,
        --     getFunc = function()
        --         return DynamicCP.savedOptions.customRules.promptConflicts
        --     end,
        --     setFunc = function(value)
        --         DynamicCP.savedOptions.customRules.promptConflicts = value
        --     end,
        --     width = "full",
        --     disabled = function() return not DynamicCP.savedOptions.customRules.autoSlot end
        -- },
        {
            type = "submenu",
            name = "Import",
            controls = MakeImportButtons(),
        },
        {
            type = "header",
            name = "|c3bdb5eCustom Rules|r",
            width = "full",
        },
        {
            type = "description",
            title = nil,
            text = "Here, you can specify which CP stars to automatically slot in specific instances. ALL matching rules are applied, in the specified order, so the rule applied last can override the previous rules. Choose a rule below or press the \"New Rule\" button to get started.",
            width = "full",
        },
        {
            type = "dropdown",
            name = "Select rule to edit",
            tooltip = "Choose a rule to edit. Rules that would apply for your current conditions (zone, role, character) are highlighted in |c3bdb5egreen|r (may not update immediately).",
            choices = DynamicCP.GetSortedKeyDisplays(),
            choicesValues = DynamicCP.GetSortedKeys(),
            getFunc = function()
                return selectedRuleName
            end,
            setFunc = function(name)
                DynamicCP.dbg("selected " .. tostring(name))
                selectedRuleName = name
            end,
            width = "full",
            reference = "DynamicCP#RulesDropdown"
        },
        {
            type = "button",
            name = "New Rule",
            tooltip = "Add a new rule and edit it",
            func = CreateNewRule,
            width = "full",
        },
        {
            type = "button",
            name = "Duplicate Rule",
            tooltip = "Add a new rule with the same settings as the currently selected",
            func = DuplicateRule,
            width = "full",
            disabled = function() return selectedRuleName == nil end,
        },
        {
            type = "button",
            name = "Delete Rule",
            tooltip = "Delete this rule. This cannot be undone!",
            func = function()
                DynamicCP.dbg("Deleting " .. selectedRuleName)
                DynamicCP.savedOptions.customRules.rules[selectedRuleName] = nil
                selectedRuleName = nil

                DynamicCP.SortRuleKeys()
                local rulesDropdown = WINDOW_MANAGER:GetControlByName("DynamicCP#RulesDropdown")
                rulesDropdown:UpdateChoices(DynamicCP.GetSortedKeyDisplays(), DynamicCP.GetSortedKeys())
            end,
            warning = "Delete this rule. This cannot be undone!",
            isDangerous = true,
            width = "full",
            disabled = function() return selectedRuleName == nil end,
        },
---------------------------------------------------------------------
-- EDIT RULE
        {
            type = "header",
            name = function()
                return selectedRuleName ~= nil and "|c3bdb5eEdit Rule|r" or "|cFF4444Edit Rule|r"
            end,
            width = "full",
        },
        {
            type = "description",
            title = nil,
            text = function()
                if (selectedRuleName) then
                    return "Customize the rule by first selecting when you want it to trigger. Different options are available for different triggers."
                else
                    return "|cFF4444Select a rule to edit in the dropdown above first!|r"
                end
            end,
            width = "full",
        },
        {
            type = "editbox",
            name = "Name",
            tooltip = "The name of the rule",
            getFunc = function() return selectedRuleName end,
            setFunc = function(name)
                if (not name or name == selectedRuleName) then return end
                if (DynamicCP.savedOptions.customRules.rules[name]) then
                    WINDOW_MANAGER:GetControlByName("DynamicCP#NameEditBox").editbox:SetText(selectedRuleName)
                    DynamicCP.msg("|cFF4444Error: There is already a rule named " .. name)
                    return
                end
                DynamicCP.dbg("Renaming to " .. name)
                DynamicCP.savedOptions.customRules.rules[name] = DynamicCP.savedOptions.customRules.rules[selectedRuleName]
                DynamicCP.savedOptions.customRules.rules[name].name = name
                DynamicCP.savedOptions.customRules.rules[selectedRuleName] = nil
                selectedRuleName = name

                DynamicCP.SortRuleKeys()
                local rulesDropdown = WINDOW_MANAGER:GetControlByName("DynamicCP#RulesDropdown")
                rulesDropdown:UpdateChoices(DynamicCP.GetSortedKeyDisplays(), DynamicCP.GetSortedKeys())
                rulesDropdown.dropdown:SetSelectedItem(selectedRuleName)
            end,
            isMultiline = false,
            isExtraWide = false,
            width = "full",
            disabled = function() return selectedRuleName == nil end,
            reference = "DynamicCP#NameEditBox"
        },
        {
            type = "slider",
            name = "Priority Order",
            tooltip = "The priority order at which this rule should be applied. Smaller numbers will be applied first, so larger numbers have the \"final say.\"",
            default = 500,
            min = 0,
            max = 1000,
            step = 10,
            getFunc = function()
                return selectedRuleName ~= nil and DynamicCP.savedOptions.customRules.rules[selectedRuleName].priority or 100
            end,
            setFunc = function(value)
                if (not selectedRuleName) then return end
                DynamicCP.savedOptions.customRules.rules[selectedRuleName].priority = value
                DynamicCP.SortRuleKeys()

                local rulesDropdown = WINDOW_MANAGER:GetControlByName("DynamicCP#RulesDropdown")
                rulesDropdown:UpdateChoices(DynamicCP.GetSortedKeyDisplays(), DynamicCP.GetSortedKeys())
                rulesDropdown.dropdown:SetSelectedItem(selectedRuleName)
            end,
            width = "full",
            disabled = function() return selectedRuleName == nil end,
        },
        {
            type = "description",
            title = "Preview",
            text = GetCurrentPreview,
            width = "full",
            disabled = function() return selectedRuleName == nil end,
        },
---------------------------------------------------------------------
        {
            type = "header",
            name = function()
                return selectedRuleName ~= nil and "Condition" or "|c555555Condition|r"
            end,
            width = "full",
        },
        {
            type = "description",
            title = nil,
            text = "What conditions should this rule apply to?",
            disabled = function() return selectedRuleName == nil end,
            width = "full",
        },
        {
            type = "dropdown",
            name = "Trigger",
            tooltip = "When to apply the rule",
            choices = triggerDisplays,
            getFunc = function() return selectedRuleName ~= nil and DynamicCP.savedOptions.customRules.rules[selectedRuleName].trigger or nil end,
            setFunc = function(name)
                if (not selectedRuleName) then return end
                DynamicCP.savedOptions.customRules.rules[selectedRuleName].trigger = name
            end,
            width = "full",
            disabled = function() return selectedRuleName == nil end,
        },
        {
            type = "checkbox",
            name = "Apply for normal",
            tooltip = "Whether this rule should apply for normal difficulty",
            getFunc = function()
                return selectedRuleName ~= nil and DynamicCP.savedOptions.customRules.rules[selectedRuleName].normal or false
            end,
            setFunc = function(value)
                if (not selectedRuleName) then return end
                DynamicCP.savedOptions.customRules.rules[selectedRuleName].normal = value
            end,
            width = "full",
            disabled = function() return selectedRuleName == nil or not hasVet[DynamicCP.savedOptions.customRules.rules[selectedRuleName].trigger] end,
        },
        {
            type = "checkbox",
            name = "Apply for veteran",
            tooltip = "Whether this rule should apply for veteran difficulty",
            getFunc = function()
                return selectedRuleName ~= nil and DynamicCP.savedOptions.customRules.rules[selectedRuleName].veteran or false
            end,
            setFunc = function(value)
                if (not selectedRuleName) then return end
                DynamicCP.savedOptions.customRules.rules[selectedRuleName].veteran = value
            end,
            width = "full",
            disabled = function() return selectedRuleName == nil or not hasVet[DynamicCP.savedOptions.customRules.rules[selectedRuleName].trigger] end,
        },
        {
            type = "editbox",
            name = "Extra info",
            tooltip = "Unused for this trigger",
            getFunc = function()
                return selectedRuleName ~= nil and tostring(DynamicCP.savedOptions.customRules.rules[selectedRuleName].param1) or ""
            end,
            setFunc = function(zoneId)
                if (not selectedRuleName) then return end
                DynamicCP.savedOptions.customRules.rules[selectedRuleName].param1 = zoneId
            end,
            isExtraWide = true,
            isMultiline = true,
            width = "full",
            disabled = function()
                -- Hacky, but the name and tooltip don't get refreshed otherwise
                local param1Line = WINDOW_MANAGER:GetControlByName("DynamicCP#Param1")
                if (selectedRuleName) then
                    local trigger = DynamicCP.savedOptions.customRules.rules[selectedRuleName].trigger
                    if (trigger == DynamicCP.TRIGGER_ZONEID) then
                        param1Line.label:SetText("Zone IDs")
                        param1Line.data.tooltipText = "The specific zone ID(s) to match. Your current zone ID is " .. tostring(GetZoneId(GetUnitZoneIndex("player"))) .. " (" .. GetPlayerActiveZoneName() .. "). You can set this to trigger on multiple zone IDs by separating them with percentage sign %. To match ANY zone ID, put only * in this box"
                        return false
                    elseif (trigger == DynamicCP.TRIGGER_MAPID) then
                        param1Line.label:SetText("Map IDs")
                        param1Line.data.tooltipText = "The specific map ID(s) to match. Your current map ID is " .. tostring(GetCurrentMapId()) .. ". This is triggered only upon loading, similar to the zone ID rule; it does not trigger when moving without loadscreens from one map to another. You can set this to trigger on multiple map IDs by separating them with percentage sign %. To match ANY map ID, put only * in this box\n\nSome map IDs that may be of interest:\n2418 (EA Cycle boss room)\n2419 (EA Tho'at Boss room)\n2424 (Aramril's Theater of War)"
                        return false
                    elseif (isBossTrigger[trigger]) then
                        param1Line.label:SetText("Boss names")
                        param1Line.data.tooltipText = "The specific boss name to match. You can set this to trigger on multiple bosses by separating them with percentage sign %. To match ANY boss name, put only * in this box"
                        return false
                    end
                end
                param1Line.data.tooltipText = "Unused for this trigger"
                param1Line.label:SetText("Extra info")
                return true
            end,
            reference = "DynamicCP#Param1",
        },
        {
            type = "description",
            title = nil,
            text = "* Public instances include public dungeons and delves, but also include outlaws refuges and quest instances such as Nighthollow Keep. Cyrodiil delves will trigger both Cyrodiil and Public Instance rules.\n** Group instances are heist and sacrament zones, as well as Craglorn group delves. Group dungeons, trials, and arenas are not included in this.",
            disabled = function() return selectedRuleName == nil end,
            width = "full",
        },
---------------------------------------------------------------------
-- Advanced options
        {
            type = "submenu",
            name = "Role Conditions",
            disabled = function() return selectedRuleName == nil end,
            controls = {
                {
                    type = "description",
                    title = nil,
                    text = "You can choose to only apply this rule on certain roles. This is defined as the role you have set in the Group Finder.",
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Apply for tanks",
                    tooltip = "Apply this rule if you are on a tank, as defined in Group Finder",
                    default = true,
                    getFunc = function()
                        return selectedRuleName ~= nil and DynamicCP.savedOptions.customRules.rules[selectedRuleName].tank or false
                    end,
                    setFunc = function(value)
                        if (not selectedRuleName) then return end
                        DynamicCP.savedOptions.customRules.rules[selectedRuleName].tank = value
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Apply for healers",
                    tooltip = "Apply this rule if you are on a healer, as defined in Group Finder",
                    default = true,
                    getFunc = function()
                        return selectedRuleName ~= nil and DynamicCP.savedOptions.customRules.rules[selectedRuleName].healer or false
                    end,
                    setFunc = function(value)
                        if (not selectedRuleName) then return end
                        DynamicCP.savedOptions.customRules.rules[selectedRuleName].healer = value
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Apply for DPS",
                    tooltip = "Apply this rule if you are on a DPS, as defined in Group Finder",
                    default = true,
                    getFunc = function()
                        return selectedRuleName ~= nil and DynamicCP.savedOptions.customRules.rules[selectedRuleName].dps or false
                    end,
                    setFunc = function(value)
                        if (not selectedRuleName) then return end
                        DynamicCP.savedOptions.customRules.rules[selectedRuleName].dps = value
                    end,
                    width = "full",
                },
            },
        },
        {
            type = "submenu",
            name = "Character Conditions",
            disabled = function() return selectedRuleName == nil end,
            controls = MakeCheckboxesForEachCharacter(),
        },
---------------------------------------------------------------------
-- Stars
        {
            type = "header",
            name = function()
                return selectedRuleName ~= nil and "Result" or "|c555555Result|r"
            end,
            width = "full",
        },
        {
            type = "description",
            title = nil,
            text = "What result should happen if the conditions are met?",
            disabled = function() return selectedRuleName == nil end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Re-evaluate instead of slotting stars",
            tooltip = "This is only available for triggers within the same zone.\nSet to ON to trigger a re-evaluation of the other rules. For example, if you attach this to a trigger for leaving a certain boss, setting this to ON will try to re-apply rules for the zone you are in when you leave the boss.\nThis will always override other stars, regardless of priority",
            default = true,
            getFunc = function()
                return selectedRuleName ~= nil and DynamicCP.savedOptions.customRules.rules[selectedRuleName].reeval
            end,
            setFunc = function(value)
                if (not selectedRuleName) then return end
                DynamicCP.savedOptions.customRules.rules[selectedRuleName].reeval = value
            end,
            disabled = function() return selectedRuleName == nil or not canReeval[DynamicCP.savedOptions.customRules.rules[selectedRuleName].trigger] end,
            width = "full",
        },
        {
            type = "description",
            title = function()
                return selectedRuleName ~= nil and "|ca5d752Craft|r" or "|c555555Craft|r"
            end,
            width = "full",
        },
        {
            type = "dropdown",
            name = "Craft Slottable Set",
            tooltip = "You can reuse a Slottable Set here, so changes to the Set can be used across different rules, instead of individual slottable stars.",
            choices = slotSetDisplays["Green"],
            choicesValues = slotSetValues["Green"],
            getFunc = function()
                return selectedRuleName ~= nil and DynamicCP.savedOptions.customRules.rules[selectedRuleName].stars["Green"] or -1
            end,
            setFunc = function(value)
                if (not selectedRuleName) then return end
                DynamicCP.dbg("selected " .. tostring(value))
                if (value == -1) then value = nil end
                DynamicCP.savedOptions.customRules.rules[selectedRuleName].stars["Green"] = value
                DynamicCP.savedOptions.customRules.rules[selectedRuleName].stars[1] = -1
                DynamicCP.savedOptions.customRules.rules[selectedRuleName].stars[2] = -1
                DynamicCP.savedOptions.customRules.rules[selectedRuleName].stars[3] = -1
                DynamicCP.savedOptions.customRules.rules[selectedRuleName].stars[4] = -1
            end,
            width = "full",
            disabled = function() return selectedRuleName == nil or DynamicCP.savedOptions.customRules.rules[selectedRuleName].reeval end,
            reference = "DynamicCP#CraftSlotSetDropdown"
        },
        {
            type = "dropdown",
            name = "Craft Star 1",
            tooltip = "Which star to slot in slot 1 of the Craft tree",
            choices = starDisplays[1],
            choicesValues = starValues[1],
            getFunc = function()
                return selectedRuleName ~= nil and DynamicCP.savedOptions.customRules.rules[selectedRuleName].stars[1] or -1
            end,
            setFunc = function(value)
                if (not selectedRuleName) then return end
                DynamicCP.dbg("selected " .. tostring(value))
                DynamicCP.savedOptions.customRules.rules[selectedRuleName].stars[1] = value
            end,
            width = "full",
            disabled = function() return selectedRuleName == nil or DynamicCP.savedOptions.customRules.rules[selectedRuleName].reeval or DynamicCP.savedOptions.customRules.rules[selectedRuleName].stars["Green"] ~= nil end,
            reference = "DynamicCP#CraftStar1Dropdown"
        },
        {
            type = "dropdown",
            name = "Craft Star 2",
            tooltip = "Which star to slot in slot 2 of the Craft tree",
            choices = starDisplays[1],
            choicesValues = starValues[1],
            getFunc = function()
                return selectedRuleName ~= nil and DynamicCP.savedOptions.customRules.rules[selectedRuleName].stars[2] or -1
            end,
            setFunc = function(value)
                if (not selectedRuleName) then return end
                DynamicCP.dbg("selected " .. tostring(value))
                DynamicCP.savedOptions.customRules.rules[selectedRuleName].stars[2] = value
            end,
            width = "full",
            disabled = function() return selectedRuleName == nil or DynamicCP.savedOptions.customRules.rules[selectedRuleName].reeval or DynamicCP.savedOptions.customRules.rules[selectedRuleName].stars["Green"] ~= nil end,
            reference = "DynamicCP#CraftStar2Dropdown"
        },
        {
            type = "dropdown",
            name = "Craft Star 3",
            tooltip = "Which star to slot in slot 3 of the Craft tree",
            choices = starDisplays[1],
            choicesValues = starValues[1],
            getFunc = function()
                return selectedRuleName ~= nil and DynamicCP.savedOptions.customRules.rules[selectedRuleName].stars[3] or -1
            end,
            setFunc = function(value)
                if (not selectedRuleName) then return end
                DynamicCP.dbg("selected " .. tostring(value))
                DynamicCP.savedOptions.customRules.rules[selectedRuleName].stars[3] = value
            end,
            width = "full",
            disabled = function() return selectedRuleName == nil or DynamicCP.savedOptions.customRules.rules[selectedRuleName].reeval or DynamicCP.savedOptions.customRules.rules[selectedRuleName].stars["Green"] ~= nil end,
            reference = "DynamicCP#CraftStar3Dropdown"
        },
        {
            type = "dropdown",
            name = "Craft Star 4",
            tooltip = "Which star to slot in slot 4 of the Craft tree",
            choices = starDisplays[1],
            choicesValues = starValues[1],
            getFunc = function()
                return selectedRuleName ~= nil and DynamicCP.savedOptions.customRules.rules[selectedRuleName].stars[4] or -1
            end,
            setFunc = function(value)
                if (not selectedRuleName) then return end
                DynamicCP.dbg("selected " .. tostring(value))
                DynamicCP.savedOptions.customRules.rules[selectedRuleName].stars[4] = value
            end,
            width = "full",
            disabled = function() return selectedRuleName == nil or DynamicCP.savedOptions.customRules.rules[selectedRuleName].reeval or DynamicCP.savedOptions.customRules.rules[selectedRuleName].stars["Green"] ~= nil end,
            reference = "DynamicCP#CraftStar4Dropdown"
        },
        {
            type = "description",
            title = function()
                return selectedRuleName ~= nil and "|c59bae7Warfare|r" or "|c555555Warfare|r"
            end,
            width = "full",
            disabled = function() return selectedRuleName == nil or DynamicCP.savedOptions.customRules.rules[selectedRuleName].reeval end,
        },
        {
            type = "dropdown",
            name = "Warfare Slottable Set",
            tooltip = "You can reuse a Slottable Set here, so changes to the Set can be used across different rules, instead of individual slottable stars.",
            choices = slotSetDisplays["Blue"],
            choicesValues = slotSetValues["Blue"],
            getFunc = function()
                return selectedRuleName ~= nil and DynamicCP.savedOptions.customRules.rules[selectedRuleName].stars["Blue"] or -1
            end,
            setFunc = function(value)
                if (not selectedRuleName) then return end
                DynamicCP.dbg("selected " .. tostring(value))
                if (value == -1) then value = nil end
                DynamicCP.savedOptions.customRules.rules[selectedRuleName].stars["Blue"] = value
                DynamicCP.savedOptions.customRules.rules[selectedRuleName].stars[5] = -1
                DynamicCP.savedOptions.customRules.rules[selectedRuleName].stars[6] = -1
                DynamicCP.savedOptions.customRules.rules[selectedRuleName].stars[7] = -1
                DynamicCP.savedOptions.customRules.rules[selectedRuleName].stars[8] = -1
            end,
            width = "full",
            disabled = function() return selectedRuleName == nil or DynamicCP.savedOptions.customRules.rules[selectedRuleName].reeval end,
            reference = "DynamicCP#WarfareSlotSetDropdown"
        },
        {
            type = "dropdown",
            name = "Warfare Star 1",
            tooltip = "Which star to slot in slot 1 of the Warfare tree",
            choices = starDisplays[2],
            choicesValues = starValues[2],
            getFunc = function()
                return selectedRuleName ~= nil and DynamicCP.savedOptions.customRules.rules[selectedRuleName].stars[5] or -1
            end,
            setFunc = function(value)
                if (not selectedRuleName) then return end
                DynamicCP.dbg("selected " .. tostring(value))
                DynamicCP.savedOptions.customRules.rules[selectedRuleName].stars[5] = value
            end,
            width = "full",
            disabled = function() return selectedRuleName == nil or DynamicCP.savedOptions.customRules.rules[selectedRuleName].reeval or DynamicCP.savedOptions.customRules.rules[selectedRuleName].stars["Blue"] ~= nil end,
            reference = "DynamicCP#WarfareStar1Dropdown"
        },
        {
            type = "dropdown",
            name = "Warfare Star 2",
            tooltip = "Which star to slot in slot 2 of the Warfare tree",
            choices = starDisplays[2],
            choicesValues = starValues[2],
            getFunc = function()
                return selectedRuleName ~= nil and DynamicCP.savedOptions.customRules.rules[selectedRuleName].stars[6] or -1
            end,
            setFunc = function(value)
                if (not selectedRuleName) then return end
                DynamicCP.dbg("selected " .. tostring(value))
                DynamicCP.savedOptions.customRules.rules[selectedRuleName].stars[6] = value
            end,
            width = "full",
            disabled = function() return selectedRuleName == nil or DynamicCP.savedOptions.customRules.rules[selectedRuleName].reeval or DynamicCP.savedOptions.customRules.rules[selectedRuleName].stars["Blue"] ~= nil end,
            reference = "DynamicCP#WarfareStar2Dropdown"
        },
        {
            type = "dropdown",
            name = "Warfare Star 3",
            tooltip = "Which star to slot in slot 3 of the Warfare tree",
            choices = starDisplays[2],
            choicesValues = starValues[2],
            getFunc = function()
                return selectedRuleName ~= nil and DynamicCP.savedOptions.customRules.rules[selectedRuleName].stars[7] or -1
            end,
            setFunc = function(value)
                if (not selectedRuleName) then return end
                DynamicCP.dbg("selected " .. tostring(value))
                DynamicCP.savedOptions.customRules.rules[selectedRuleName].stars[7] = value
            end,
            width = "full",
            disabled = function() return selectedRuleName == nil or DynamicCP.savedOptions.customRules.rules[selectedRuleName].reeval or DynamicCP.savedOptions.customRules.rules[selectedRuleName].stars["Blue"] ~= nil end,
            reference = "DynamicCP#WarfareStar3Dropdown"
        },
        {
            type = "dropdown",
            name = "Warfare Star 4",
            tooltip = "Which star to slot in slot 4 of the Warfare tree",
            choices = starDisplays[2],
            choicesValues = starValues[2],
            getFunc = function()
                return selectedRuleName ~= nil and DynamicCP.savedOptions.customRules.rules[selectedRuleName].stars[8] or -1
            end,
            setFunc = function(value)
                if (not selectedRuleName) then return end
                DynamicCP.dbg("selected " .. tostring(value))
                DynamicCP.savedOptions.customRules.rules[selectedRuleName].stars[8] = value
            end,
            width = "full",
            disabled = function() return selectedRuleName == nil or DynamicCP.savedOptions.customRules.rules[selectedRuleName].reeval or DynamicCP.savedOptions.customRules.rules[selectedRuleName].stars["Blue"] ~= nil end,
            reference = "DynamicCP#WarfareStar4Dropdown"
        },
        {
            type = "description",
            title = function()
                return selectedRuleName ~= nil and "|ce46b2eFitness|r" or "|c555555Fitness|r"
            end,
            width = "full",
        },
        {
            type = "dropdown",
            name = "Fitness Slottable Set",
            tooltip = "You can reuse a Slottable Set here, so changes to the Set can be used across different rules, instead of individual slottable stars.",
            choices = slotSetDisplays["Red"],
            choicesValues = slotSetValues["Red"],
            getFunc = function()
                return selectedRuleName ~= nil and DynamicCP.savedOptions.customRules.rules[selectedRuleName].stars["Red"] or -1
            end,
            setFunc = function(value)
                if (not selectedRuleName) then return end
                DynamicCP.dbg("selected " .. tostring(value))
                if (value == -1) then value = nil end
                DynamicCP.savedOptions.customRules.rules[selectedRuleName].stars["Red"] = value
                DynamicCP.savedOptions.customRules.rules[selectedRuleName].stars[9] = -1
                DynamicCP.savedOptions.customRules.rules[selectedRuleName].stars[10] = -1
                DynamicCP.savedOptions.customRules.rules[selectedRuleName].stars[11] = -1
                DynamicCP.savedOptions.customRules.rules[selectedRuleName].stars[12] = -1
            end,
            width = "full",
            disabled = function() return selectedRuleName == nil or DynamicCP.savedOptions.customRules.rules[selectedRuleName].reeval end,
            reference = "DynamicCP#FitnessSlotSetDropdown"
        },
        {
            type = "dropdown",
            name = "Fitness Star 1",
            tooltip = "Which star to slot in slot 1 of the Fitness tree",
            choices = starDisplays[3],
            choicesValues = starValues[3],
            getFunc = function()
                return selectedRuleName ~= nil and DynamicCP.savedOptions.customRules.rules[selectedRuleName].stars[9] or -1
            end,
            setFunc = function(value)
                if (not selectedRuleName) then return end
                DynamicCP.dbg("selected " .. tostring(value))
                DynamicCP.savedOptions.customRules.rules[selectedRuleName].stars[9] = value
            end,
            width = "full",
            disabled = function() return selectedRuleName == nil or DynamicCP.savedOptions.customRules.rules[selectedRuleName].reeval or DynamicCP.savedOptions.customRules.rules[selectedRuleName].stars["Red"] ~= nil end,
            reference = "DynamicCP#FitnessStar1Dropdown"
        },
        {
            type = "dropdown",
            name = "Fitness Star 2",
            tooltip = "Which star to slot in slot 2 of the Fitness tree",
            choices = starDisplays[3],
            choicesValues = starValues[3],
            getFunc = function()
                return selectedRuleName ~= nil and DynamicCP.savedOptions.customRules.rules[selectedRuleName].stars[10] or -1
            end,
            setFunc = function(value)
                if (not selectedRuleName) then return end
                DynamicCP.dbg("selected " .. tostring(value))
                DynamicCP.savedOptions.customRules.rules[selectedRuleName].stars[10] = value
            end,
            width = "full",
            disabled = function() return selectedRuleName == nil or DynamicCP.savedOptions.customRules.rules[selectedRuleName].reeval or DynamicCP.savedOptions.customRules.rules[selectedRuleName].stars["Red"] ~= nil end,
            reference = "DynamicCP#FitnessStar2Dropdown"
        },
        {
            type = "dropdown",
            name = "Fitness Star 3",
            tooltip = "Which star to slot in slot 3 of the Fitness tree",
            choices = starDisplays[3],
            choicesValues = starValues[3],
            getFunc = function()
                return selectedRuleName ~= nil and DynamicCP.savedOptions.customRules.rules[selectedRuleName].stars[11] or -1
            end,
            setFunc = function(value)
                if (not selectedRuleName) then return end
                DynamicCP.dbg("selected " .. tostring(value))
                DynamicCP.savedOptions.customRules.rules[selectedRuleName].stars[11] = value
            end,
            width = "full",
            disabled = function() return selectedRuleName == nil or DynamicCP.savedOptions.customRules.rules[selectedRuleName].reeval or DynamicCP.savedOptions.customRules.rules[selectedRuleName].stars["Red"] ~= nil end,
            reference = "DynamicCP#FitnessStar3Dropdown"
        },
        {
            type = "dropdown",
            name = "Fitness Star 4",
            tooltip = "Which star to slot in slot 4 of the Fitness tree",
            choices = starDisplays[3],
            choicesValues = starValues[3],
            getFunc = function()
                return selectedRuleName ~= nil and DynamicCP.savedOptions.customRules.rules[selectedRuleName].stars[12] or -1
            end,
            setFunc = function(value)
                if (not selectedRuleName) then return end
                DynamicCP.dbg("selected " .. tostring(value))
                DynamicCP.savedOptions.customRules.rules[selectedRuleName].stars[12] = value
            end,
            width = "full",
            disabled = function() return selectedRuleName == nil or DynamicCP.savedOptions.customRules.rules[selectedRuleName].reeval or DynamicCP.savedOptions.customRules.rules[selectedRuleName].stars["Red"] ~= nil end,
            reference = "DynamicCP#FitnessStar4Dropdown"
        },
    }

    DynamicCP.customRulesPanel = LAM:RegisterAddonPanel(DynamicCP.name .. "CustomRules", panelData)
    LAM:RegisterOptionControls(DynamicCP.name .. "CustomRules", optionsData)

    CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened",
        function(currentPanel)
            if (currentPanel == DynamicCP.customRulesPanel) then
                DynamicCP.SortRuleKeys()
                local rulesDropdown = WINDOW_MANAGER:GetControlByName("DynamicCP#RulesDropdown")
                if (rulesDropdown) then
                    rulesDropdown:UpdateChoices(DynamicCP.GetSortedKeyDisplays(), DynamicCP.GetSortedKeys())
                end
            end
        end)
end

function DynamicCP.OpenCustomRulesMenu()
    LibAddonMenu2:OpenToPanel(DynamicCP.customRulesPanel)
end
