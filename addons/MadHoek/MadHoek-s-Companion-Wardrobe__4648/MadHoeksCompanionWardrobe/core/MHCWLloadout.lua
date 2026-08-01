-- ============================================================================
-- Companion Wardrobe
-- Loadout Management
--
-- Responsibilities:
-- - Save the current companion gear/skills into the active loadout.
-- - Load saved gear/skills back onto the active companion.
-- - Rename, delete, lock, favorite, and duplicate loadouts.
-- - Preserve user metadata such as colors, favorites, and lock state.
-- ============================================================================
if MHCWL == nil then MHCWL = {} end
local MHCWL = MHCWL

-- Return the currently active loadout for the active companion.
function MHCWL.GetActiveSetup()
    local companionData = MHCWL.GetActiveCompanionSavedData()
    if not companionData then
        MHCWL.Debug("No active companion.")
        return nil, nil
    end

    local count = MHCWL.GetSetupCount(companionData)
    if count == 0 then
        MHCWL.Debug("No saved setup.")
        return nil, companionData
    end

    local activeSetup = companionData.activeSetup or 0
    local setup = companionData.setups[activeSetup]

    if not setup then
        MHCWL.Debug("No saved setup.")
        return nil, companionData
    end

    return setup, companionData, activeSetup
end

-- Save currently equipped companion gear and/or slotted skills into the active loadout.
function MHCWL.SaveCurrent()
    if not HasActiveCompanion() then
        MHCWL.Debug("No active companion.")
        return
    end

    local companionData = MHCWL.GetActiveCompanionSavedData()
    if not companionData then
        MHCWL.Debug("No active companion.")
        return
    end

    if MHCWL.GetSetupCount(companionData) == 0 then
        MHCWL.AddSetup(companionData)
    end

    local activeSetup = companionData.activeSetup or 1
    local existingSetup = companionData.setups[activeSetup]

    if existingSetup and existingSetup.locked then
        MHCWL.Debug("Loadout is locked.")
        MHCWL.Notify(GetString(MHCWL_NOTIFY_LOCKED))
        return
    end

    local setup = {
        name = existingSetup and existingSetup.name or GetString(MHCWL_LOADOUT) .. tostring(activeSetup),
        locked = existingSetup and existingSetup.locked or false,
        isFavorite = existingSetup and existingSetup.isFavorite or false,
        nameColorSlot = existingSetup and existingSetup.nameColorSlot or nil,
        useColorWhenFavorite = existingSetup and existingSetup.useColorWhenFavorite or false,
        gear = {},
        skills = {},
    }

    if MHCWL.saved.settings.saveGear then
        for _, slot in ipairs(MHCWL.GEARSLOTS) do
            local link = GetItemLink(BAG_COMPANION_WORN, slot, LINK_STYLE_DEFAULT)
            local uniqueId = Id64ToString(GetItemUniqueId(BAG_COMPANION_WORN, slot))

            setup.gear[slot] = {
                id = uniqueId,
                link = link,
            }
        end
    else
        setup.gear = companionData.setups[activeSetup] and companionData.setups[activeSetup].gear or {}
    end

    if MHCWL.saved.settings.saveSkills then
        for _, slotIndex in ipairs(MHCWL.COMPANION_SKILL_SLOTS) do
            setup.skills[slotIndex] = GetSlotBoundId(slotIndex, HOTBAR_CATEGORY_COMPANION)
        end
    else
        setup.skills = companionData.setups[activeSetup] and companionData.setups[activeSetup].skills or {}
    end

    companionData.setups[activeSetup] = setup

    if not MHCWL.saved.settings.saveSkills and MHCWL.saved.settings.saveGear then 
        MHCWL.Debug("Saved Gear only: " .. tostring(activeSetup) .. " for " .. tostring(companionData.name))
        MHCWL.Notify(GetString(MHCWL_NOTIFY_SAVED_GEAR) .. tostring(setup.name))
    end

    if MHCWL.saved.settings.saveSkills and not MHCWL.saved.settings.saveGear then
        MHCWL.Debug("Saved Skills only: " .. tostring(activeSetup) .. " for " .. tostring(companionData.name))
        MHCWL.Notify(GetString(MHCWL_NOTIFY_SAVED_SKILLS) .. tostring(setup.name))
    end

    if MHCWL.saved.settings.saveSkills and MHCWL.saved.settings.saveGear then
        MHCWL.Debug("Saved setup " .. tostring(activeSetup) .. " for " .. tostring(companionData.name))
        MHCWL.Notify(GetString(MHCWL_NOTIFY_SAVED) .. tostring(setup.name))
    end
    MHCWL.RefreshOpenInspectWindow()
end

-- Mark a loadout as active without loading it yet.
function MHCWL.SetActiveSetup(index)
    index = tonumber(index)

    local companionData = MHCWL.GetActiveCompanionSavedData()
    if not companionData then
        MHCWL.Debug("No active companion.")
        return
    end

    MHCWL.EnsureCompanionSetups(companionData)

    local maxSlot = MHCWL.GetSetupCount(companionData)

    if maxSlot == 0 then
        MHCWL.Debug("No loadouts yet.")
        return
    end

    if not index or index < 1 or index > maxSlot then
        MHCWL.Debug("Invalid loadout slot. Use 1-" .. tostring(maxSlot) .. ".")
        return
    end

    companionData.activeSetup = index
    MHCWL.EnsureCompanionSetups(companionData)

    local setup = companionData.setups[index]
    MHCWL.Debug("Selected loadout " .. tostring(index) .. ": " .. tostring(setup.name))
end

function MHCWL.AddLoadout()
    local companionData = MHCWL.GetActiveCompanionSavedData()
    if not companionData then
        MHCWL.Debug("No active companion.")
        return
    end

    local index = MHCWL.AddSetup(companionData)
    if not index then
        MHCWL.Debug("Maximum loadout count reached.")
        return
    end
    companionData.activeSetup = index
    companionData.activePage = math.ceil(index / MHCWL.LOADOUTS_PER_PAGE)

    MHCWL.Debug("Added loadout " .. tostring(index) .. ".")

    MHCWL.RebuildWindowContent()
end

-- Apply one saved loadout to the active companion according to load settings.
function MHCWL.LoadSetup(callback)
    local setup = MHCWL.GetActiveSetup()
    if not setup then return end

    local function finish()
        zo_callLater(function()
            if callback then
                callback()
            end
        end, MHCWL.GetDelay(MHCWL.TIMINGS.loadSetupFinish))
    end

    if MHCWL.saved.settings.loadGear then
        MHCWL.LoadGearAll(function()
            if MHCWL.saved.settings.loadSkills then
                MHCWL.LoadSkillsAll()
            end

            finish()
        end)
    else
        if MHCWL.saved.settings.loadSkills then
            MHCWL.LoadSkillsAll()
        end

        finish()
    end
end

-- Load the active setup and verify the result after ESO has processed the changes.
function MHCWL.LoadAndVerify()
    local setup = MHCWL.GetActiveSetup()
    if not setup then return end

    MHCWL.Debug("Starting load + verify sequence...")

    MHCWL.LoadSetup(function()
        MHCWL.Debug("Running delayed verification...")
        MHCWL.VerifySetup()
    end)
end

function MHCWL.ListSetups()
    local companionData = MHCWL.GetActiveCompanionSavedData()
    if not companionData then
        MHCWL.Debug("No active companion.")
        return
    end

    MHCWL.EnsureCompanionSetups(companionData)

    local count = MHCWL.GetSetupCount(companionData)

    MHCWL.Debug("Loadouts for " .. tostring(companionData.name) .. ":")

    if count == 0 then
        MHCWL.Debug("No loadouts.")
        return
    end

    for i = 1, count do
        local setup = companionData.setups[i]
        local marker = (companionData.activeSetup == i) and "*" or " "

        MHCWL.Debug(string.format(
            "%s %s: %s",
            marker,
            tostring(i),
            tostring(setup and setup.name or (GetString(MHCWL_LOADOUT) .. tostring(i)))
        ))
    end
end

function MHCWL.RenameSetup(index, name)
    index = tonumber(index)

    local companionData = MHCWL.GetActiveCompanionSavedData()
    if not companionData then
        MHCWL.Debug("No active companion.")
        return
    end

    MHCWL.EnsureCompanionSetups(companionData)

    local maxSlot = MHCWL.GetSetupCount(companionData)

    if not index or index < 1 or index > maxSlot then
        MHCWL.Debug("Invalid loadout slot. Use 1-" .. tostring(maxSlot) .. ".")
        return
    end

    local setup = companionData.setups[index]

    if setup.locked then
        MHCWL.Debug("Loadout is locked.")
        MHCWL.Notify(GetString(MHCWL_NOTIFY_LOCKED))
        return
    end

    name = tostring(name or "")
    name = zo_strtrim(name)

    if name == "" then
        MHCWL.Debug("Missing name. Usage: /mhcwl rename 1 My Build")
        return
    end

    companionData.setups[index].name = name

    MHCWL.Debug("Renamed loadout " .. tostring(index) .. " to: " .. name)
    MHCWL.RefreshOpenInspectWindow()
end

-- Delete one loadout and keep active page/setup indexes valid.
function MHCWL.DeleteLoadout(index)
    if MHCWL.inspectIndex == index and MHCWL.inspectWindow then
        MHCWL.inspectWindow:SetHidden(true)
    end
    index = tonumber(index)

    local companionData = MHCWL.GetActiveCompanionSavedData()
    if not companionData then
        MHCWL.Debug("No active companion.")
        return
    end

    local setup = companionData.setups[index]

    if not setup then
        MHCWL.Debug("Invalid loadout.")
        return
    end

    if setup.locked then
        MHCWL.Debug("Loadout is locked.")
        MHCWL.Notify(GetString(MHCWL_NOTIFY_LOCKED))
        return
    end

    local removedName = setup.name

    local success = MHCWL.RemoveSetup(companionData, index)

    if not success then
        MHCWL.Debug("Could not delete loadout.")
        return
    end

    MHCWL.Debug("Deleted loadout: " .. tostring(removedName))

    MHCWL.RebuildWindowContent()
end

function MHCWL.ToggleSetupLock(index)
    index = tonumber(index)

    local companionData = MHCWL.GetActiveCompanionSavedData()
    if not companionData then
        MHCWL.Debug("No active companion.")
        return
    end

    local setup = companionData.setups[index]
    if not setup then
        MHCWL.Debug("Invalid loadout.")
        return
    end

    setup.locked = not setup.locked

    local stateText = setup.locked and "Locked" or "Unlocked"

    MHCWL.Debug(tostring(setup.name) .. " " .. zo_strlower(stateText) .. ".")

    MHCWL.RebuildWindowContent()
    MHCWL.RefreshOpenInspectWindow()
end

function MHCWL.ToggleSetupFavorite(index)
    index = tonumber(index)

    local companionData = MHCWL.GetActiveCompanionSavedData()
    if not companionData then
        MHCWL.Debug("No active companion.")
        return
    end

    local setup = companionData.setups[index]
    if not setup then
        MHCWL.Debug("Invalid loadout.")
        return
    end

    setup.isFavorite = not setup.isFavorite

    local stateText =
        setup.isFavorite
        and "Favorited"
        or "Unfavorited"

    MHCWL.Debug(tostring(setup.name) .. " " .. zo_strlower(stateText) .. ".")

    MHCWL.RebuildWindowContent()
    MHCWL.RefreshOpenInspectWindow()
end

-- Generic table copy helper used when duplicating or resetting nested loadout data.
function MHCWL.DeepCopy(value)
    if type(value) ~= "table" then
        return value
    end

    local copy = {}

    for key, child in pairs(value) do
        copy[MHCWL.DeepCopy(key)] = MHCWL.DeepCopy(child)
    end

    return copy
end

function MHCWL.GetDuplicateLoadoutName(companionData, sourceName)
    sourceName = tostring(sourceName or GetString(MHCWL_LOADOUT))
    sourceName = zo_strtrim(sourceName)

    local baseName = string.match(sourceName, "^(.-)%s*%(%d+%)$") or sourceName
    baseName = zo_strtrim(baseName)

    local function NameExists(name)
        for _, setup in ipairs(companionData.setups) do
            if setup and tostring(setup.name or "") == name then
                return true
            end
        end

        return false
    end

    local index = 1
    local newName = baseName .. " (" .. tostring(index) .. ")"

    while NameExists(newName) do
        index = index + 1
        newName = baseName .. " (" .. tostring(index) .. ")"
    end

    return newName
end

-- Create a full copy of an existing loadout, including metadata and saved content.
function MHCWL.DuplicateLoadout(index)
    index = tonumber(index)

    local companionData = MHCWL.GetActiveCompanionSavedData()
    if not companionData then return end

    MHCWL.EnsureCompanionSetups(companionData)

    local source = companionData.setups[index]
    if not source then return end

    local newIndex = MHCWL.GetSetupCount(companionData) + 1

    if newIndex > MHCWL.MAX_SETUP_SLOTS then
        MHCWL.Notify(GetString(MHCWL_NOTIFY_IMPORT_MAX_LOADOUT_COUNT))
        return
    end

    local copy = MHCWL.DeepCopy(source)

    copy.name = MHCWL.GetDuplicateLoadoutName(companionData, source.name)
    copy.locked = false

    companionData.setups[newIndex] = copy
    companionData.activeSetup = newIndex
    companionData.activePage = math.ceil(newIndex / MHCWL.LOADOUTS_PER_PAGE)

    MHCWL.Debug("Duplicated loadout " .. tostring(index) .. " to slot " .. tostring(newIndex) .. ".")
    MHCWL.Notify(GetString(MHCWL_NOTIFY_DUPLICATED) .. tostring(copy.name))

    MHCWL.RebuildWindowContent()
    MHCWL.RefreshOpenInspectWindow()
end