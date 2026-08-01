---------------------------------------------------------------------
-- Constants
DynamicCP.TRIGGER_TRIAL                = "Trial"
DynamicCP.TRIGGER_GROUP_ARENA          = "Group Arena"
DynamicCP.TRIGGER_SOLO_ARENA           = "Solo Arena"
DynamicCP.TRIGGER_GROUP_DUNGEON        = "Group Dungeon"
DynamicCP.TRIGGER_PUBLIC_INSTANCE      = "Public Instance *"
DynamicCP.TRIGGER_GROUP_INSTANCE       = "Group Instance **"
DynamicCP.TRIGGER_OVERLAND             = "Overland"
DynamicCP.TRIGGER_CYRO                 = "Cyrodiil"
DynamicCP.TRIGGER_IC                   = "Imperial City"
DynamicCP.TRIGGER_ZONEID               = "Specific Zone ID"
DynamicCP.TRIGGER_MAPID                = "Specific Map ID"
DynamicCP.TRIGGER_ZONENAMEMATCH        = "Zone Name Match" -- tbd
DynamicCP.TRIGGER_HOUSE                = "Player House"
DynamicCP.TRIGGER_BOSSNAME             = "Specific Boss Name"
DynamicCP.TRIGGER_LEAVE_BOSSNAME       = "Leaving Specific Boss"
DynamicCP.TRIGGER_BOSS_DIED            = "Specific Boss Death"

local difficulties = {
    [DUNGEON_DIFFICULTY_NONE] = "NONE",
    [DUNGEON_DIFFICULTY_NORMAL] = "NORMAL",
    [DUNGEON_DIFFICULTY_VETERAN] = "VETERAN",
}

local sortedKeys = {}
local sortedKeyDisplays = {}

local lastZoneId = 0
local lastBossesHash = ""
local lastBosses = {}
local inCombat = false

local pendingRules = nil -- Boss rules that are pending if we are in combat
local pendingName = ""
local hasTemporarilyHiddenDialog = false

---------------------------------------------------------------------
-- First-time dialog box
---------------------------------------------------------------------
function DynamicCP.ShowFirstTimeDialog()
    local text = string.format("Welcome to Dynamic CP v%s!\n\nYou now have the ability to set custom rules for slottable stars. These are conditions that you can define to slot certain stars when you enter certain zones.\n\nThe current defaults demonstrate how to set up a general rule for green stars to slot upon entering a trial, as well as a rule only for DPS to slot blue and red stars upon entering a trial. If you are on a DPS character, both of these rules will be applied when you enter a trial.\n\nGo to the custom rules menu now to add, delete, or change rules?",
        DynamicCP.version
        )
    DynamicCP.ShowModelessPrompt(text, DynamicCP.OpenCustomRulesMenu)
end


---------------------------------------------------------------------
-- Data
---------------------------------------------------------------------
local function GetSortedKeys()
    return sortedKeys
end
DynamicCP.GetSortedKeys = GetSortedKeys

local function GetSortedKeyDisplays()
    return sortedKeyDisplays
end
DynamicCP.GetSortedKeyDisplays = GetSortedKeyDisplays

local function GetFlippedSlottables()
    local committed = DynamicCP.GetCommittedSlottables() -- [skillId] = index
    local flipped = {}
    for skillId, slotIndex in pairs(committed) do
        flipped[slotIndex] = skillId
    end
    return flipped
end


---------------------------------------------------------------------
-- Rules handling
---------------------------------------------------------------------
local function GetPlayerRole()
    local roles = {
        [LFG_ROLE_DPS] = "dps",
        [LFG_ROLE_HEAL] = "healer",
        [LFG_ROLE_TANK] = "tank",
    }
    return roles[GetSelectedLFGRole()]
end

-- Convert the pending slottables into the request
local function ProcessAndCommitRules(sortedRuleNames, pendingSlottables, triggerString)
    local flipped = GetFlippedSlottables()
    local diffMessages = {}
    PrepareChampionPurchaseRequest(false)
    for slotIndex, skillId in pairs(pendingSlottables) do
        local unlocked = WouldChampionSkillNodeBeUnlocked(skillId, GetNumPointsSpentOnChampionSkill(skillId))
        local isSlottable = CanChampionSkillTypeBeSlotted(GetChampionSkillType(skillId))
        local color = "e46b2e" -- Red
        if (slotIndex <= 8) then color = "59bae7" end -- Blue
        if (slotIndex <= 4) then color = "a5d752" end -- Green
        local diffMessage = zo_strformat("|c<<1>><<2>> - <<C:3>> → <<C:4>>",
                color, slotIndex, GetChampionSkillName(flipped[slotIndex]), GetChampionSkillName(skillId))
        if (not isSlottable) then
            diffMessage = diffMessage .. " |cFF4444- not slottable"
            table.insert(diffMessages, diffMessage)
        elseif (unlocked) then
            if (flipped[slotIndex] == skillId) then
                -- If it's the same skill in the same slot, we can skip it
                -- DynamicCP.dbg("skipping " .. tostring(slotIndex))
            else
                -- Not the same
                AddHotbarSlotToChampionPurchaseRequest(slotIndex, skillId)
                table.insert(diffMessages, diffMessage)
            end
        else
            diffMessage = diffMessage .. " |cFF4444- not unlocked"
            table.insert(diffMessages, diffMessage)
        end
    end
    SendChampionPurchaseRequest()
    -- TODO: handle promptConflicts
    -- TODO: automatic filling. maybe also automatic filling even if no other slots are changed?

    if (DynamicCP.savedOptions.customRules.showInChat) then
        DynamicCP.msg(string.format("%s\n|cAAAAAAApplying rules %s:\n%s",
            triggerString,
            table.concat(sortedRuleNames, " < "),
            table.concat(diffMessages, "\n")))
    end

    if (DynamicCP.savedOptions.customRules.playSound) then
        PlaySound(SOUNDS.CHAMPION_POINTS_COMMITTED)
    end
end

-- Iterate through all rules and find any matching ones
-- Returns in the format {{name = name, priority = priority,}}
local function GetSortedRulesForTrigger(trigger, isVet, param1)
    local role = GetPlayerRole()
    local difficulty = isVet and "veteran" or "normal"
    local ruleNames = {}
    local charId = GetCurrentCharacterId()

    -- Iterate using sorted keys so we get them in prioritized order
    for _, name in ipairs(GetSortedKeys()) do
        local rule = DynamicCP.savedOptions.customRules.rules[name]
        if (rule.trigger == trigger) then
            if (rule[role] and rule[difficulty] and rule.chars[charId]) then
                if (param1 == nil) then
                    table.insert(ruleNames, {name = name, priority = rule.priority})
                else
                    if (rule.param1 == "*") then
                        table.insert(ruleNames, {name = name, priority = rule.priority})
                    else
                        -- Split param1 on pipe char and attempt to match each one
                        for str in string.gmatch(rule.param1, "([^%%]+)") do
                            str = string.gsub(str, "^%s+", "")
                            str = string.gsub(str, "%s+$", "")
                            if (param1 == str) then
                                table.insert(ruleNames, {name = name, priority = rule.priority})
                                break
                            end
                        end
                    end
                end
            end
        end
    end

    return ruleNames
end

-- Override the individual ids with the ids from the slot set, if applicable
local function CombineSlotSetStars(ruleStars)
    local newStars = {}
    for i = 1, 12 do
        newStars[i] = ruleStars[i]
    end

    local trees = { -- And their offsets
        ["Green"] = 0,
        ["Blue"] = 4,
        ["Red"] = 8,
    }

    -- Put in the stars from set
    for tree, offset in pairs(trees) do
        local slotSet = ruleStars[tree]
        if (slotSet and slotSet ~= -1) then
            for i = 1, 4 do
                local skillId = DynamicCP.savedOptions.slotGroups[tree][slotSet][i]
                if (skillId) then
                    newStars[i + offset] = skillId
                end
            end
        end
    end

    return newStars
end

-- Apply the stars from this rule
local function ApplyRules(sortedRuleNames, triggerString)
    if (not sortedRuleNames) then return end

    local doReeval = false
    local reevalRuleName = ""

    -- First pass collects them into pending, overwriting lower priority rules
    local pendingSlottables = {}
    for _, ruleName in ipairs(sortedRuleNames) do
        local rule = DynamicCP.savedOptions.customRules.rules[ruleName]
        if (rule.reeval) then
            doReeval = true
            reevalRuleName = ruleName
            break
        end

        -- "Inject" the slot set stars into this
        local starsToApply = CombineSlotSetStars(rule.stars)
        for slotIndex, skillId in pairs(starsToApply) do
            if (skillId ~= -1) then
                -- If smart detection is on, we check if the user's max stam or mag is higher, and change the skill accordingly
                if (DynamicCP.savedOptions.customRules.autoDetectStamMag and (skillId == 47 or skillId == 48)) then
                    local _, maxStam, effectiveMaxStam = GetUnitPower("player", COMBAT_MECHANIC_FLAGS_STAMINA)
                    local _, maxMag, effectiveMaxMag = GetUnitPower("player", COMBAT_MECHANIC_FLAGS_MAGICKA)
                    local newSkillId = skillId
                    if (maxStam < maxMag) then
                        newSkillId = 47
                    else
                        newSkillId = 48
                    end
                    DynamicCP.dbg(zo_strformat("|c44FF44max mag <<1>> / max stam <<2>> - <<C:3>> → <<C:4>>|r",
                        maxMag, maxStam, GetChampionSkillName(skillId), GetChampionSkillName(newSkillId)))
                    DynamicCP.dbg(zo_strformat("|c44FF44effective max mag <<1>> / effective max stam <<2>>|r",
                        effectiveMaxMag, effectiveMaxStam))
                    skillId = newSkillId
                end

                pendingSlottables[slotIndex] = skillId
            end
        end
    end

    -- If ANY of the rules triggers a reeval, do that only and ignore everything else
    if (doReeval) then
        DynamicCP.dbg("|cFF8888Re-evaluating according to " .. reevalRuleName)
        DynamicCP.ReEval()
        return
    end

    -- Second pass checks if all of the stars are already slotted, or if they're all in the same slots
    local committed = DynamicCP.GetCommittedSlottables() -- [skillId] = slotIndex
    local hasUnslotted = false
    local hasDifferentSlot = false
    for slotIndex, skillId in pairs(pendingSlottables) do
        if (not committed[skillId]) then
            hasUnslotted = true
            break
        elseif (committed[skillId] ~= slotIndex) then
            hasDifferentSlot = true
        end
    end
    if (not hasUnslotted) then
        if (hasDifferentSlot) then -- If there are stars in different slots, check override
            DynamicCP.dbg("Stars are already slotted in different order")
            if (not DynamicCP.savedOptions.customRules.overrideOrder) then
                -- If not overriding, then we're done here
                return
            end
        else
            if (DynamicCP.savedOptions.customRules.showInChat) then
                DynamicCP.msg(triggerString .. "\n|cAAAAAAAll stars are already slotted from rules: " .. table.concat(sortedRuleNames, " < "))
            end
            return
        end
    end

    -- If autoslotting then we can just do it immediately, no need for dialog
    if (DynamicCP.savedOptions.customRules.autoSlot) then
        ProcessAndCommitRules(sortedRuleNames, pendingSlottables, triggerString)
    else
        -- Third pass to generate text for the dialog. Not the most efficient probably...
        local flipped = GetFlippedSlottables()
        local diffMessages = {}

        -- Sort the keys by slot index so they're not all ugly out of order
        local pendingSlotIndices = {}
        for slotIndex, _ in pairs(pendingSlottables) do
            table.insert(pendingSlotIndices, slotIndex)
        end
        table.sort(pendingSlotIndices)

        for _, slotIndex in ipairs(pendingSlotIndices) do
            local skillId = pendingSlottables[slotIndex]
            local unlocked = WouldChampionSkillNodeBeUnlocked(skillId,
                GetNumPointsSpentOnChampionSkill(skillId))
            local isSlottable = CanChampionSkillTypeBeSlotted(GetChampionSkillType(skillId))
            local color = "e46b2e" -- Red
            if (slotIndex <= 8) then color = "59bae7" end -- Blue
            if (slotIndex <= 4) then color = "a5d752" end -- Green
            local diffMessage = zo_strformat("|c<<1>><<2>> - <<C:3>> → <<C:4>>",
                    color, slotIndex, GetChampionSkillName(flipped[slotIndex]), GetChampionSkillName(skillId))
            if (not isSlottable) then
                diffMessage = diffMessage .. " |cFF4444- not slottable"
                table.insert(diffMessages, diffMessage)
            elseif (not unlocked) then
                diffMessage = diffMessage .. " |cFF4444- not unlocked"
                table.insert(diffMessages, diffMessage)
            elseif (unlocked and flipped[slotIndex] ~= skillId) then
                -- Not the same
                table.insert(diffMessages, diffMessage)
            end
        end

        -- It's possible for there to be no changes here if all potential changes aren't unlocked
        if (#diffMessages == 0) then
            if (DynamicCP.savedOptions.customRules.showInChat) then
                DynamicCP.msg(triggerString .. "\n|cAAAAAAAll stars are already slotted from rules: " .. table.concat(sortedRuleNames, " < "))
            end
            return
        end

        local text = string.format("%s\nSlot these stars according to the custom rules: %s?\n\n%s",
            triggerString,
            table.concat(sortedRuleNames, " < "),
            table.concat(diffMessages, "\n"))

        DynamicCP.ShowModelessPrompt(text, function()
            ProcessAndCommitRules(sortedRuleNames, pendingSlottables, triggerString)
        end)
    end
end


---------------------------------------------------------------------
-- Events
-- Params: initial - true if first time entering, false if going through door etc.
---------------------------------------------------------------------

------------
-- Any trial
local function OnEnteredTrial(initial)
    if (not initial) then return {} end
    DynamicCP.dbg("|cFF4444Entered a TRIAL difficulty "
        .. difficulties[GetCurrentZoneDungeonDifficulty()] .. "|r")

    return GetSortedRulesForTrigger(DynamicCP.TRIGGER_TRIAL, GetCurrentZoneDungeonDifficulty() == DUNGEON_DIFFICULTY_VETERAN)
end
DynamicCP.OnEnteredTrial = OnEnteredTrial -- For testing /script DynamicCP.OnEnteredTrial(true)

------------------
-- Any group arena
local function OnEnteredGroupArena(initial)
    if (not initial) then return {} end
    DynamicCP.dbg("|cFF4444Entered a GROUP ARENA difficulty "
        .. difficulties[GetCurrentZoneDungeonDifficulty()] .. "|r")

    return GetSortedRulesForTrigger(DynamicCP.TRIGGER_GROUP_ARENA, GetCurrentZoneDungeonDifficulty() == DUNGEON_DIFFICULTY_VETERAN)
end

-----------------
-- Any solo arena
local function OnEnteredSoloArena(initial)
    if (not initial) then return {} end
    DynamicCP.dbg("|cFF4444Entered a SOLO ARENA difficulty "
        .. difficulties[GetCurrentZoneDungeonDifficulty()] .. "|r")

    return GetSortedRulesForTrigger(DynamicCP.TRIGGER_SOLO_ARENA, GetCurrentZoneDungeonDifficulty() == DUNGEON_DIFFICULTY_VETERAN)
end

--------------------
-- Any group dungeon
local function OnEnteredGroupDungeon(initial)
    if (not initial) then return {} end
    DynamicCP.dbg("|cFF4444Entered a GROUP DUNGEON difficulty "
        .. difficulties[GetCurrentZoneDungeonDifficulty()] .. "|r")

    return GetSortedRulesForTrigger(DynamicCP.TRIGGER_GROUP_DUNGEON, GetCurrentZoneDungeonDifficulty() == DUNGEON_DIFFICULTY_VETERAN)
end

------------------------------------------
-- Any public dungeon or delve or instance
local function OnEnteredPublicInstance(initial)
    if (not initial) then return {} end
    DynamicCP.dbg("|cFF4444Entered a PUBLIC INSTANCE|r")

    return GetSortedRulesForTrigger(DynamicCP.TRIGGER_PUBLIC_INSTANCE, false)
end

--------------------------------------------------------------------
-- Any group instance - heists and sacraments, craglorn group delves
local function OnEnteredGroupInstance(initial)
    if (not initial) then return {} end
    DynamicCP.dbg("|cFF4444Entered a GROUP INSTANCE|r")

    return GetSortedRulesForTrigger(DynamicCP.TRIGGER_GROUP_INSTANCE, false)
end

--------------
-- Any IC zone
local function OnEnteredImperialCity(initial)
    if (not initial) then return {} end
    DynamicCP.dbg("|cFF4444Entered IMPERIAL CITY|r")

    return GetSortedRulesForTrigger(DynamicCP.TRIGGER_IC, false)
end

-----------
-- Cyrodiil
local function OnEnteredCyrodiil(initial)
    if (not initial) then return {} end
    DynamicCP.dbg("|cFF4444Entered CYRODIIL|r")

    return GetSortedRulesForTrigger(DynamicCP.TRIGGER_CYRO, false)
end

------------
-- Any house
local function OnEnteredPlayerHouse(initial)
    if (not initial) then return {} end
    DynamicCP.dbg("|cFF4444Entered PLAYER HOUSE|r")

    return GetSortedRulesForTrigger(DynamicCP.TRIGGER_HOUSE, false)
end

--------------------
-- Any overland zone
local function OnEnteredOverland(initial)
    if (not initial) then return {} end
    DynamicCP.dbg("|cFF4444Entered OVERLAND|r")

    return GetSortedRulesForTrigger(DynamicCP.TRIGGER_OVERLAND, false)
end

--------------------
-- Zone ID
local function OnEnteredZoneID(initial)
    if (not initial) then return {} end

    -- GetSortedRulesForTrigger(trigger, isVet, param1, param2)
    return GetSortedRulesForTrigger(DynamicCP.TRIGGER_ZONEID,
        GetCurrentZoneDungeonDifficulty() == DUNGEON_DIFFICULTY_VETERAN,
        tostring(GetZoneId(GetUnitZoneIndex("player"))))
end

--------------------
-- Map ID
local function OnEnteredZoneWithMapID(initial)
    -- Do NOT check for initial, because we want this to trigger on same zone
    -- if (not initial) then return {} end
    DynamicCP.dbg(string.format("|cFF4444Entered Map ID %d|r", GetCurrentMapId()))

    -- GetSortedRulesForTrigger(trigger, isVet, param1, param2)
    return GetSortedRulesForTrigger(DynamicCP.TRIGGER_MAPID,
        GetCurrentZoneDungeonDifficulty() == DUNGEON_DIFFICULTY_VETERAN,
        tostring(GetCurrentMapId()))
end


---------------------------------------------------------------------
-- Mappings
---------------------------------------------------------------------
local triggerDisplayNames = {
    [DynamicCP.TRIGGER_TRIAL]           = "You entered trial",
    [DynamicCP.TRIGGER_GROUP_ARENA]     = "You entered group arena",
    [DynamicCP.TRIGGER_SOLO_ARENA]      = "You entered solo arena",
    [DynamicCP.TRIGGER_GROUP_DUNGEON]   = "You entered group dungeon",
    [DynamicCP.TRIGGER_PUBLIC_INSTANCE] = "You entered public instance",
    [DynamicCP.TRIGGER_GROUP_INSTANCE]  = "You entered group instance",
    [DynamicCP.TRIGGER_IC]              = "You entered Imperial City:",
    [DynamicCP.TRIGGER_CYRO]            = "You entered Cyrodiil:",
    [DynamicCP.TRIGGER_HOUSE]           = "You entered player house",
    [DynamicCP.TRIGGER_OVERLAND]        = "You entered overland zone",
    [DynamicCP.TRIGGER_ZONEID]          = "You entered zone",
    [DynamicCP.TRIGGER_MAPID]           = "You entered zone (mapId trigger)",
    [DynamicCP.TRIGGER_BOSSNAME]        = "You entered boss area in",
    [DynamicCP.TRIGGER_LEAVE_BOSSNAME]  = "You left boss area in",
    [DynamicCP.TRIGGER_BOSS_DIED]       = "Boss died in",
}

local triggerToFunction = {
    [DynamicCP.TRIGGER_TRIAL]           = OnEnteredTrial,
    [DynamicCP.TRIGGER_GROUP_ARENA]     = OnEnteredGroupArena,
    [DynamicCP.TRIGGER_SOLO_ARENA]      = OnEnteredSoloArena,
    [DynamicCP.TRIGGER_GROUP_DUNGEON]   = OnEnteredGroupDungeon,
    [DynamicCP.TRIGGER_PUBLIC_INSTANCE] = OnEnteredPublicInstance,
    [DynamicCP.TRIGGER_GROUP_INSTANCE]  = OnEnteredGroupInstance,
    [DynamicCP.TRIGGER_IC]              = OnEnteredImperialCity,
    [DynamicCP.TRIGGER_CYRO]            = OnEnteredCyrodiil,
    [DynamicCP.TRIGGER_HOUSE]           = OnEnteredPlayerHouse,
    [DynamicCP.TRIGGER_OVERLAND]        = OnEnteredOverland,
    [DynamicCP.TRIGGER_ZONEID]          = OnEnteredZoneID,
    [DynamicCP.TRIGGER_MAPID]           = OnEnteredZoneWithMapID,
}


---------------------------------------------------------------------
-- Entry point
---------------------------------------------------------------------
local function SortAndApplyAllRules(allRules, triggerDisplayName)
    pendingRules = nil
    pendingName = ""
    -- Now sort
    local sortedRules = {}
    for name, priority in pairs(allRules) do
        table.insert(sortedRules, {name = name, priority = priority})
    end
    table.sort(sortedRules, function(item1, item2)
        return item1.priority < item2.priority
    end)

    if (#sortedRules == 0) then
        DynamicCP.dbg("|cFF4444No rules to apply.")
        return
    end

    local sortedRuleNames = {}
    for _, data in ipairs(sortedRules) do
        table.insert(sortedRuleNames, data.name)
    end

    -- Apply the rules
    ApplyRules(sortedRuleNames, zo_strformat("<<3>> <<C:1>> (zone id <<2>>).",
        GetPlayerActiveZoneName(),
        GetZoneId(GetUnitZoneIndex("player")),
        triggerDisplayName))
end

---------------------------------------------------------------------
local function GetTriggersForZoneId(zoneId)
    local groupOwnable = IsActiveWorldGroupOwnable()
    local inDungeon = IsUnitInDungeon("player")

    local triggers = {DynamicCP.TRIGGER_ZONEID, DynamicCP.TRIGGER_MAPID}
    local initialSize = #triggers

    if (DynamicCP.TRIAL_ZONEIDS[tostring(zoneId)]) then
        table.insert(triggers, DynamicCP.TRIGGER_TRIAL)
    elseif (DynamicCP.DUNGEON_ZONEIDS[tostring(zoneId)]) then
        table.insert(triggers, DynamicCP.TRIGGER_GROUP_DUNGEON)
    elseif (DynamicCP.GROUP_ARENA_ZONEIDS[tostring(zoneId)]) then
        table.insert(triggers, DynamicCP.TRIGGER_GROUP_ARENA)
    elseif (DynamicCP.SOLO_ARENA_ZONEIDS[tostring(zoneId)]) then
        table.insert(triggers, DynamicCP.TRIGGER_SOLO_ARENA)
    elseif (GetCurrentZoneHouseId() ~= 0) then
        -- Do not trigger for housing preview
        if (GetCurrentHouseOwner() ~= "") then
            table.insert(triggers, DynamicCP.TRIGGER_HOUSE)
        end
    elseif (not groupOwnable and inDungeon) then
        -- Anything that's not group ownable but is a dungeon and not a solo arena is things like public dungeons and delves,
        -- but also outlaws refuges, quest instances, etc.
        table.insert(triggers, DynamicCP.TRIGGER_PUBLIC_INSTANCE)
    elseif (not groupOwnable and not inDungeon) then
        -- TODO: is this true?
        table.insert(triggers, DynamicCP.TRIGGER_OVERLAND)
    elseif (groupOwnable and inDungeon) then
        -- Anything that's not a group trial/dungeon/arena but is group ownable and a dungeon is things like
        -- heist and sacrament areas, as well as Craglorn group delves
        -- Underground Sepulcher (764) The Hideaway (770) Secluded Sewers (763) Deadhollow Halls (767) Glittering Grotto (771)
        table.insert(triggers, DynamicCP.TRIGGER_GROUP_INSTANCE)
    end

    -- These not in the main if/else because Cyrodiil delves can trigger both public instances and Cyro
    if (IsInImperialCity()) then
        -- TODO: sewers etc are likely different zones, initial needs fixing
        -- Imperial Sewers 643 Imperial City 584
        table.insert(triggers, DynamicCP.TRIGGER_IC)
    elseif (IsInAvAZone()) then
        table.insert(triggers, DynamicCP.TRIGGER_CYRO)
    end

    if (#triggers == initialSize) then
        DynamicCP.dbg("|cFF0000UNHANDLED ZONE " .. GetPlayerActiveZoneName() .. " (" .. tostring(zoneId) .. ")|r")
        return nil
    end

    return triggers
end

---------------------------------------------------------------------
local function SortRuleKeys()
    -- Sort the rules
    local sortedRules = {}
    for name, rule in pairs(DynamicCP.savedOptions.customRules.rules) do
        table.insert(sortedRules, {name = name, priority = rule.priority})
    end

    table.sort(sortedRules, function(item1, item2)
        if (item1.priority == item2.priority) then
            return item1.name < item2.name
        end
        return item1.priority < item2.priority
    end)

    -- And convert them to the dropdown values
    sortedKeys = {}
    for _, data in ipairs(sortedRules) do
        table.insert(sortedKeys, data.name)
    end

    -- Get all the rules for triggers of the current zone
    local allRules = {}
    local triggers = GetTriggersForZoneId(GetZoneId(GetUnitZoneIndex("player")))
    if (triggers) then
        for _, trigger in ipairs(triggers) do
            local rules = triggerToFunction[trigger](true)
            for _, value in pairs(rules) do
                allRules[value.name] = value.priority
            end
        end
    end

    -- This loop must be done after getting the rules for the current zone
    -- because the sortedKeys are used in iterating through the rules
    sortedKeyDisplays = {}
    for _, data in ipairs(sortedRules) do
        if (allRules[data.name]) then
            table.insert(sortedKeyDisplays, string.format("|c3bdb5e%d: %s|r", data.priority, data.name))
        else
            table.insert(sortedKeyDisplays, string.format("%d: %s", data.priority, data.name))
        end
    end
    local rulesDropdown = WINDOW_MANAGER:GetControlByName("DynamicCP#RulesDropdown")
    if (rulesDropdown) then
        rulesDropdown:UpdateChoices(DynamicCP.GetSortedKeyDisplays(), DynamicCP.GetSortedKeys())
    end
end
DynamicCP.SortRuleKeys = SortRuleKeys

---------------------------------------------------------------------
local function OnPlayerActivated()
    DynamicCP.OnModelessCancel()
    lastBossesHash = ""
    local purchaseAvailability = GetChampionPurchaseAvailability()
    if (purchaseAvailability == CHAMPION_PURCHASE_IN_NOCP_CAMPAIGN
        or purchaseAvailability == CHAMPION_PURCHASE_IN_NOCP_BATTLEGROUND
        or purchaseAvailability == CHAMPION_PURCHASE_CP_DISABLED) then
        DynamicCP.dbg("champion points are not active")
        return
    end

    DynamicCP.dbg(string.format("IsActiveWorldGroupOwnable: %s IsUnitInDungeon: %s",
        tostring(IsActiveWorldGroupOwnable()),
        tostring(IsUnitInDungeon("player"))
    ))
    local zoneId = GetZoneId(GetUnitZoneIndex("player"))
    local initial = zoneId ~= lastZoneId
    lastZoneId = zoneId

    local triggers = GetTriggersForZoneId(zoneId)

    if (not triggers) then
        return
    end

    -- End trigger collection
    -------------------------

    -- Get all the rules for the triggers, deduping them
    local allRules = {}
    for _, trigger in ipairs(triggers) do
        -- TODO: do something about initial
        local rules = triggerToFunction[trigger](initial)

        -- Add all
        for _, value in pairs(rules) do
            allRules[value.name] = value.priority
        end
    end

    if (DynamicCP.IsOnCooldown()) then
        if (DynamicCP.savedOptions.customRules.applyOnCooldownEnd) then
            pendingRules = allRules
            pendingName = triggerDisplayNames[triggers[#triggers]]
            if (DynamicCP.savedOptions.customRules.extraChat) then
                DynamicCP.msg("Waiting for cooldown to end before applying pending rules...")
            end
        else
            if (DynamicCP.savedOptions.customRules.extraChat) then
                DynamicCP.msg("Did not apply rules because player is on cooldown.")
            end
        end
    elseif (inCombat) then
        -- This should only happen on a "leave boss" if player leaves boss area while in combat
        pendingRules = allRules
        pendingName = triggerDisplayNames[triggers[#triggers]]
        if (DynamicCP.savedOptions.customRules.extraChat) then
            DynamicCP.msg("Waiting for combat to end before evaluating rules...")
        end
    else
        SortAndApplyAllRules(allRules, triggerDisplayNames[triggers[#triggers]])
    end
end

---------------------------------------------------------------------
-- Upon entering or leaving boss areas
-- TODO: boss deaths will be handled separately, but a thing to think about... boss dies and then usually leaving boss area triggers a little later
local function OnBossesChanged()
    local bossesHash = ""
    local currentBosses = {}

    -- Slightly more efficient to check first if the bosses even changed
    for i = 1, BOSS_RANK_ITERATION_END do
        local name = GetUnitName("boss" .. tostring(i))
        if (name and name ~= "") then
            currentBosses[i] = name
            bossesHash = bossesHash .. name
        end
    end

    -- DynamicCP.dbg("|c44FF44BOSSES CHANGED " .. table.concat(currentBosses, ", ") .. "|r")

    -- If not, don't even match for rules
    if (bossesHash == lastBossesHash) then
        return
    end
    lastBossesHash = bossesHash

    -- At this point, this is a change from having a boss to no boss
    if (bossesHash == "") then
        DynamicCP.dbg("|cFF4444Checking leave boss(es) " .. table.concat(lastBosses, ", ") .. "|r")
    else
        DynamicCP.dbg("|cFF4444Checking encountered boss(es) " .. table.concat(currentBosses, ", ") .. "|r")
    end

    local allRules = {}
    local numRules = 0
    local trigger = bossesHash ~= "" and DynamicCP.TRIGGER_BOSSNAME or DynamicCP.TRIGGER_LEAVE_BOSSNAME
    -- Get the rules
    for i = 1, BOSS_RANK_ITERATION_END do
        local name = bossesHash ~= "" and GetUnitName("boss" .. tostring(i)) or lastBosses[i]
        if (name and name ~= "") then
            local rules = GetSortedRulesForTrigger(
                trigger,
                GetCurrentZoneDungeonDifficulty() == DUNGEON_DIFFICULTY_VETERAN,
                name)

            -- Add all
            for _, value in pairs(rules) do
                allRules[value.name] = value.priority
                numRules = numRules + 1
            end
        end
    end
    lastBosses = currentBosses

    if (numRules == 0) then
        DynamicCP.dbg("No rules to apply on boss.")
        return
    end


    if (inCombat) then
        if (DynamicCP.savedOptions.customRules.applyBossOnCombatEnd) then
            pendingRules = allRules
            pendingName = triggerDisplayNames[trigger]
            if (DynamicCP.savedOptions.customRules.extraChat) then
                DynamicCP.msg("Waiting for combat to end before applying pending boss rules...")
            end
        else
            if (DynamicCP.savedOptions.customRules.extraChat) then
                DynamicCP.msg("Did not apply boss rule because player is in combat.")
            end
        end
    elseif (DynamicCP.IsOnCooldown()) then
        if (DynamicCP.savedOptions.customRules.applyOnCooldownEnd) then
            pendingRules = allRules
            pendingName = triggerDisplayNames[trigger]
            if (DynamicCP.savedOptions.customRules.extraChat) then
                DynamicCP.msg("Waiting for cooldown to end before applying pending boss rules...")
            end
        else
            if (DynamicCP.savedOptions.customRules.extraChat) then
                DynamicCP.msg("Did not apply boss rule because player is on cooldown.")
            end
        end
    else
        SortAndApplyAllRules(allRules, triggerDisplayNames[trigger])
    end
end


---------------------------------------------------------------------
local function OnDeathStateChanged(_, unitTag, isDead)
    if (not isDead) then return end
    if (not string.find(unitTag, "^boss")) then return end

    local name = GetUnitName(unitTag)
    DynamicCP.dbg("|cFF4444Checking boss died " .. name .. "|r")

    local allRules = {}
    local numRules = 0
    -- Get the rules
    if (name and name ~= "") then
        local rules = GetSortedRulesForTrigger(
            DynamicCP.TRIGGER_BOSS_DIED,
            GetCurrentZoneDungeonDifficulty() == DUNGEON_DIFFICULTY_VETERAN,
            name)

        -- Add all
        for _, value in pairs(rules) do
            allRules[value.name] = value.priority
            numRules = numRules + 1
        end
    end

    if (numRules == 0) then
        DynamicCP.dbg("No rules to apply on boss death.")
        return
    end


    if (inCombat) then
        if (DynamicCP.savedOptions.customRules.applyBossOnCombatEnd) then
            pendingRules = allRules
            pendingName = triggerDisplayNames[DynamicCP.TRIGGER_BOSS_DIED]
            if (DynamicCP.savedOptions.customRules.extraChat) then
                DynamicCP.msg("Waiting for combat to end before applying pending boss death rules...")
            end
        else
            if (DynamicCP.savedOptions.customRules.extraChat) then
                DynamicCP.msg("Did not apply boss death rule because player is in combat.")
            end
        end
    elseif (DynamicCP.IsOnCooldown()) then
        if (DynamicCP.savedOptions.customRules.applyOnCooldownEnd) then
            pendingRules = allRules
            pendingName = triggerDisplayNames[DynamicCP.TRIGGER_BOSS_DIED]
            if (DynamicCP.savedOptions.customRules.extraChat) then
                DynamicCP.msg("Waiting for cooldown to end before applying pending boss death rules...")
            end
        else
            if (DynamicCP.savedOptions.customRules.extraChat) then
                DynamicCP.msg("Did not apply boss death rule because player is on cooldown.")
            end
        end
    else
        SortAndApplyAllRules(allRules, triggerDisplayNames[DynamicCP.TRIGGER_BOSS_DIED])
    end
end


---------------------------------------------------------------------
local function OnCombatStateChanged(_, combat)
    inCombat = combat
    if (not inCombat) then
        if (pendingRules) then
            -- Wait 1 second after combat ends because it might fire at the same time as boss death
            -- Kinda hacky but not sure what else could be done...
            -- DynamicCP.dbg("|cFFAAAADelaying ApplyPendingRules by 1 second|r")
            EVENT_MANAGER:RegisterForUpdate(DynamicCP.name .. "CustomDelay", 1000, function()
                    EVENT_MANAGER:UnregisterForUpdate(DynamicCP.name .. "CustomDelay")
                    DynamicCP.dbg("|cFFAAAAApplying the 1s delay pending rules|r")
                    DynamicCP.ApplyPendingRules()
                end)
        elseif (hasTemporarilyHiddenDialog) then
            DynamicCP.dbg("unhiding temporarily hidden dialog")
            DynamicCPModelessDialog:SetHidden(false)
        end
        hasTemporarilyHiddenDialog = false
    else
        if (DynamicCP.TemporarilyHideModelessPrompt()) then
            hasTemporarilyHiddenDialog = true
            DynamicCP.dbg("hiding dialog due to combat")
        end
    end
end

function ApplyPendingRules()
    if (pendingRules ~= nil) then
        if (inCombat) then
            DynamicCP.dbg("further delaying rule " .. pendingName .. " because in combat")
            return
        elseif (DynamicCP.IsOnCooldown()) then
            DynamicCP.dbg("further delaying rule " .. pendingName .. " because on cooldown")
            return
        end
        -- pendingRules will be zeroed by this call
        DynamicCP.dbg("delayed rule " .. pendingName)
        SortAndApplyAllRules(pendingRules, pendingName)
    end
end
DynamicCP.ApplyPendingRules = ApplyPendingRules

function DynamicCP.ReEval()
    lastZoneId = 0
    OnPlayerActivated()
end

---------------------------------------------------------------------
-- Init
function DynamicCP.InitCustomRules()
    SortRuleKeys()
    EVENT_MANAGER:RegisterForEvent(DynamicCP.name .. "CustomActivated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
    EVENT_MANAGER:RegisterForEvent(DynamicCP.name .. "CustomBossesChanged", EVENT_BOSSES_CHANGED, OnBossesChanged)
    EVENT_MANAGER:RegisterForEvent(DynamicCP.name .. "CustomBossDied", EVENT_UNIT_DEATH_STATE_CHANGED, OnDeathStateChanged)
    EVENT_MANAGER:RegisterForEvent(DynamicCP.name .. "CustomCombatState", EVENT_PLAYER_COMBAT_STATE, OnCombatStateChanged)
    lastZoneId = GetZoneId(GetUnitZoneIndex("player"))

    DynamicCP.RegisterCooldownListener("CustomRules", function()
        DynamicCP.BuildStarsDropdowns()
        DynamicCP.UpdateStarsDropdowns()
        DynamicCP.BuildSlotSetDropdowns()
        DynamicCP.UpdateSlotSetDropdowns()
    end, nil, ApplyPendingRules)
end
