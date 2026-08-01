KyzderpsDerps = KyzderpsDerps or {}
KyzderpsDerps.Fashion = KyzderpsDerps.Fashion or {}
local Fashion = KyzderpsDerps.Fashion
local Spud = KyzderpsDerps.AntiSpud

---------------------------------------------------------------------
-- Helper for whether mounting is allowed
-- This is to be used to avoid stick horses in mountable content
---------------------------------------------------------------------
local function IsMountingAllowed()
    local zoneId = GetZoneId(GetUnitZoneIndex("player"))

    if (zoneId == 636 -- HRC
        or zoneId == 176 -- CoA1
        or zoneId == 681 -- CoA2
        or zoneId == 973 -- BRF
        ) then
        return true
    end

    if (IsUnitInDungeon("player")) then
        return false
    end

    if (IsActiveWorldBattleground()) then
        return false
    end

    if (GetUnitBattlegroundTeam("player") ~= nil and GetUnitBattlegroundTeam("player") ~= 0) then
        return false
    end

    if (zoneId == 643) then -- Sewers
        return false
    end

    if (IsInImperialCity()) then
        return true
    end

    return true
end


---------------------------------------------------------------------
-- Saving and activating mount
---------------------------------------------------------------------
local mountTries = 0
local function TryEquipMount(collectibleToUse, isTrample)
    KyzderpsDerps:dbg(string.format("Trying to equip |H1:collectible:%d|h|h", collectibleToUse))
    if (IsUnitInCombat("player")) then
        KyzderpsDerps:dbg("Not changing mount because in combat")
        return
    end

    UseCollectible(collectibleToUse)

    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "AwaitMountCollectibleResult" .. tostring(collectibleToUse), EVENT_COLLECTIBLE_USE_RESULT, function(_, result)
        EVENT_MANAGER:UnregisterForEvent(KyzderpsDerps.name .. "AwaitMountCollectibleResult" .. tostring(collectibleToUse), EVENT_COLLECTIBLE_USE_RESULT)
        if (result == COLLECTIBLE_USAGE_BLOCK_REASON_ON_COOLDOWN) then
            if (mountTries > 5) then
                KyzderpsDerps:msg("Couldn't change trample mount after several retries; collectibles on cooldown?")
                return
            end
            mountTries = mountTries + 1
            zo_callLater(function() TryEquipMount(collectibleToUse, isTrample) end, 2000)
        elseif (result == COLLECTIBLE_USAGE_BLOCK_REASON_NOT_BLOCKED) then
            if (isTrample) then
                KyzderpsDerps:msg(string.format("Equipped |H1:collectible:%d|h|h. Happy trampling!", collectibleToUse))
            else
                KyzderpsDerps:msg(string.format("Restoring |H1:collectible:%d|h|h.", collectibleToUse))
            end
        end
    end)
end

local function ActivateMount(collectibleId, isTrample)
    if (IsCollectibleActive(collectibleId)) then
        KyzderpsDerps:dbg("Not changing mount; it's already correct")
        return
    end

    mountTries = 0
    TryEquipMount(collectibleId, isTrample)
end

-- Save the current mount to restore later. This is NOT always called
-- before changing mount, because it's possible to go, e.g., from PvE
-- to PvP, so the PvE mount should not be saved, but only if the PvE
-- setting is on
local function SaveMount()
    KyzderpsDerps:dbg("Saving mount...")
    KyzderpsDerps.savedOptions.fashion.oldMount = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_MOUNT)
end

-- 1 ~ num
local function GetRandomNumber(num)
    return math.floor(math.random() * num + 1)
end

local function RandomizeMount()
    KyzderpsDerps:dbg("Randomizing mount...")

    local trampleMounts = KyzderpsDerps.savedOptions.fashion.trampleMounts

    -- Filter out stick mounts if applicable
    if (KyzderpsDerps.savedOptions.fashion.excludeStickMountsInMountable and IsMountingAllowed()) then
        KyzderpsDerps:dbg("mounting is allowed")
        local stickMounts = {
            [5870] = true, -- Novelty Stick Horse
            [5879] = true, -- Novelty Stick Guar
            [5880] = true, -- Novelty Stick Dragon
            [7291] = true, -- Nightmare Stick Horse
            [9829] = true, -- Stitchedwell Stick Guar
        }
        local newMounts = {}
        for _, id in ipairs(trampleMounts) do
            if (not stickMounts[id]) then
                table.insert(newMounts, id)
            end
        end
        trampleMounts = newMounts
    end

    -- Could be left with none
    if (#trampleMounts == 0) then
        KyzderpsDerps:msg("No valid mounts set for trampling purposes! Add some in the settings.")
        return
    end

    -- Too lazy to make it random but different... for now
    local newIndex = GetRandomNumber(#trampleMounts)
    ActivateMount(trampleMounts[newIndex], true)
end

local function RestoreMount()
    local oldMount = KyzderpsDerps.savedOptions.fashion.oldMount
    KyzderpsDerps:msg("Restoring mount to " .. GetCollectibleName(oldMount))
    ActivateMount(oldMount, false)
end


---------------------------------------------------------------------
-- State change checks
---------------------------------------------------------------------
local function IsStateTrample(state)
    local usePve = KyzderpsDerps.savedOptions.fashion.pveUseTrampleMount
    local usePvp = KyzderpsDerps.savedOptions.fashion.pvpUseTrampleMount

    if (usePve and state == Spud.PVE) then
        return true
    elseif (usePvp and state == Spud.PVP) then
        return true
    end
    return false
end

local function OnPlayerActivated()
    local zoneId = GetZoneId(GetUnitZoneIndex("player"))
    local charId = GetCurrentCharacterId()
    if (not KyzderpsDerps.savedOptions.fashion.prevTramples[charId]) then
        KyzderpsDerps.savedOptions.fashion.prevTramples[charId] = {
            prevZoneId = 0,
            prevState = Spud.NONE,
        }
    end

    local prevData = KyzderpsDerps.savedOptions.fashion.prevTramples[charId]
    -- Only continue if zone is different. That means not re-randomizing if queueing
    -- into the same dungeon, but whatevs
    if (prevData.prevZoneId == zoneId) then
        return
    end
    prevData.prevZoneId = zoneId

    -- Get current state
    local checkedState
    if (Spud.IsDoingGroupPVE(zoneId)) then
        checkedState = Spud.PVE
    elseif (Spud.IsDoingPVP()) then
        checkedState = Spud.PVP
    else
        checkedState = Spud.NONE
    end

    local isPrevStateTrample = IsStateTrample(prevData.prevState)
    local isNewStateTrample = IsStateTrample(checkedState)

    prevData.prevState = checkedState

    -- If restoring, don't do anything else
    if (isPrevStateTrample and not isNewStateTrample) then
        RestoreMount()
        return
    end

    -- Basically whether to save (see comment for SaveMount())
    -- It's fine to save a bit excessively, even if we aren't changing mounts
    if (not isPrevStateTrample) then
        SaveMount()
    end

    -- Even if the state is the same, it could be different content, so still randomize
    if (isNewStateTrample) then
        RandomizeMount()
    end
end


---------------------------------------------------------------------
-- Init
---------------------------------------------------------------------
local function InitializeTrampleMount()
    KyzderpsDerps:dbg("    Trampling...")
    if (KyzderpsDerps.savedOptions.fashion.pveUseTrampleMount
        or KyzderpsDerps.savedOptions.fashion.pvpUseTrampleMount) then
        EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "TrampleActivated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
        OnPlayerActivated()
    end
end
Fashion.InitializeTrampleMount = InitializeTrampleMount

local function UninitializeTrampleMount()
    EVENT_MANAGER:UnregisterForEvent(KyzderpsDerps.name .. "TrampleActivated", EVENT_PLAYER_ACTIVATED)
end


---------------------------------------------------------------------
-- Settings
---------------------------------------------------------------------
local function IndexOf(idList, id)
    for k, v in ipairs(idList) do
        if (v == id) then
            return k
        end
    end
    return -1
end

local selectedMountIds = {}
local selectedMountNames = {}
local availableMountIds = {}
local availableMountNames = {}
local function BuildAvailableMounts()
    selectedMountIds = {}
    selectedMountNames = {}
    availableMountIds = {}
    availableMountNames = {}

    local nameToId = {}
    for index = 1, GetTotalCollectiblesByCategoryType(COLLECTIBLE_CATEGORY_TYPE_MOUNT) do
        local collectibleId = GetCollectibleIdFromType(COLLECTIBLE_CATEGORY_TYPE_MOUNT, index)
        if (IsCollectibleUnlocked(collectibleId)) then
            local collectibleName = zo_strformat("<<1>>", GetCollectibleName(collectibleId))
            if (IndexOf(KyzderpsDerps.savedOptions.fashion.trampleMounts, collectibleId) > 0) then
                table.insert(selectedMountNames, collectibleName)
            else
                table.insert(availableMountNames, collectibleName)
            end
            nameToId[collectibleName] = collectibleId
        end
    end

    table.sort(selectedMountNames)
    for _, name in ipairs(selectedMountNames) do
        table.insert(selectedMountIds, nameToId[name])
    end

    table.sort(availableMountNames)
    for _, name in ipairs(availableMountNames) do
        table.insert(availableMountIds, nameToId[name])
    end
end

-- Description for trample section, with updated list of mounts
local function GetCurrentDescription()
    local text = "The following settings are intended to help you maximize your Trample fashion per second. You can choose to equip a random selected mount when you enter a PvE or PvP area, and then when you leave, your previous mount will be restored. So you can have trampling mammoths. Or stick horses.\n\n|c3bdb5eSelected mounts:|r"

    for _, id in ipairs(KyzderpsDerps.savedOptions.fashion.trampleMounts) do
        text = text .. "\n" .. GetCollectibleName(id)
    end

    return text
end

local selectedSelectedMount
local selectedAvailableMount
function Fashion.GetTrampleSettings()
    return {
        {
            type = "description",
            title = "Trample Mount",
            text = GetCurrentDescription,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Change mount in PvE",
            tooltip = "When you enter a dungeon or trial, automatically equip a random mount from the selected list below",
            default = false,
            getFunc = function() return KyzderpsDerps.savedOptions.fashion.pveUseTrampleMount end,
            setFunc = function(value)
                KyzderpsDerps.savedOptions.fashion.pveUseTrampleMount = value
                UninitializeTrampleMount()
                InitializeTrampleMount()
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Change mount in PvP",
            tooltip = "When you enter Cyrodiil, Imperial City, or a battleground, automatically equip a random mount from the selected list below",
            default = false,
            getFunc = function() return KyzderpsDerps.savedOptions.fashion.pvpUseTrampleMount end,
            setFunc = function(value)
                KyzderpsDerps.savedOptions.fashion.pvpUseTrampleMount = value
                UninitializeTrampleMount()
                InitializeTrampleMount()
            end,
            width = "full",
        },
        {
            type = "dropdown",
            name = "Selected mounts",
            tooltip = "Possible mounts that should be equipped when you enter a PvE or PvP area, according to your settings",
            scrollable = 20, -- number of lines on the second open, probably a LAM bug
            choices = {},
            choicesValues = {},
            getFunc = function()
                BuildAvailableMounts()
                KyzderpsDerps_TrampleMount_Selected:UpdateChoices(selectedMountNames, selectedMountIds)
            end,
            setFunc = function(value)
                selectedSelectedMount = value
            end,
            width = "half",
            reference = "KyzderpsDerps_TrampleMount_Selected",
            disabled = function() return not KyzderpsDerps.savedOptions.fashion.pveUseTrampleMount and not KyzderpsDerps.savedOptions.fashion.pvpUseTrampleMount end,
        },
        {
            type = "button",
            name = "Remove",
            tooltip = "Remove the selected mount from the Trample list",
            func = function()
                if (selectedSelectedMount) then
                    local index = IndexOf(KyzderpsDerps.savedOptions.fashion.trampleMounts, selectedSelectedMount)
                    table.remove(KyzderpsDerps.savedOptions.fashion.trampleMounts, index)
                end
            end,
            width = "half",
            disabled = function() return not KyzderpsDerps.savedOptions.fashion.pveUseTrampleMount and not KyzderpsDerps.savedOptions.fashion.pvpUseTrampleMount end,
        },
        {
            type = "dropdown",
            name = "Available mounts",
            tooltip = "Available mounts to add to the list",
            scrollable = 20, -- number of lines on the second open, probably a LAM bug
            choices = {},
            choicesValues = {},
            getFunc = function()
                BuildAvailableMounts()
                KyzderpsDerps_TrampleMount_Available:UpdateChoices(availableMountNames, availableMountIds)
            end,
            setFunc = function(value)
                selectedAvailableMount = value
            end,
            width = "half",
            reference = "KyzderpsDerps_TrampleMount_Available",
            disabled = function() return not KyzderpsDerps.savedOptions.fashion.pveUseTrampleMount and not KyzderpsDerps.savedOptions.fashion.pvpUseTrampleMount end,
        },
        {
            type = "button",
            name = "Add",
            tooltip = "Add the selected mount to the Trample list",
            func = function()
                if (selectedAvailableMount) then
                    table.insert(KyzderpsDerps.savedOptions.fashion.trampleMounts, selectedAvailableMount)
                end
            end,
            width = "half",
            disabled = function() return not KyzderpsDerps.savedOptions.fashion.pveUseTrampleMount and not KyzderpsDerps.savedOptions.fashion.pvpUseTrampleMount end,
        },
        {
            type = "checkbox",
            name = "Exclude stick mounts in valid areas",
            tooltip = "If you have stick mounts selected as trample mounts, and you enter a trample-valid zone that you are able to mount in, such as HRC, IC, or Cyrodiil, exclude stick mounts from the selection",
            default = true,
            getFunc = function() return KyzderpsDerps.savedOptions.fashion.excludeStickMountsInMountable end,
            setFunc = function(value)
                KyzderpsDerps.savedOptions.fashion.excludeStickMountsInMountable = value
            end,
            width = "full",
        },
    }
end
