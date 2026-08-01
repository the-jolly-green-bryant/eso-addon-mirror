TargetDummyTools = {
    name            = "TargetDummyTools",
    author          = "Written by @Phuein - Concept by @NordCarbon",
    color           = "AACC55",
    menuName        = "Target Dummy Tools",
}

-- Default settings.
TargetDummyTools.savedVars = {
    firstLoad = true, -- First time the addon is loaded ever.
}

TargetDummyTools.DummiesToReset = {} -- Controls global cooldown when iterating over dummies.

-- Displays a large center screen notification.
local function DisplayMessage(text, ms)
    local ms = ms or 2000

    local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT)
    messageParams:SetLifespanMS(ms)
    messageParams:SetText(text)
    -- messageParams:SetSound(SOUNDS.JUSTICE_STATE_CHANGED)
    CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
end

-- Make sure the Undo event is complete for the dummy,
-- by using a recursive callback with a delay.
-- Move on to next dummy on success / skip.
function TargetDummyTools.VerifyUndo(furnId, maxRetries, name)
    zo_callLater(function()
        local _, _, dataId = GetPlacedHousingFurnitureInfo(furnId)

        if dataId == 0 then
            if maxRetries > 0 then
                TargetDummyTools.VerifyUndo(furnId, maxRetries-1, name)
                return
            else
                d('Failed to restore ' .. name .. '. Skipping...')
            end
        end

        -- Next.
        TargetDummyTools.ResetSelectedDummies()
    end, 750)
end

-- Reset all globally selected dummies, recursively.
-- If not removed, then report failure and skip.
-- If not restored within maxRetries with delay, then report failure and skip.
function TargetDummyTools.ResetSelectedDummies()
    local maxRetries = 5

    -- d('dummies to reset: ' .. #TargetDummyTools.DummiesToReset)

    -- Finished.
    if #TargetDummyTools.DummiesToReset == 0 then
        -- d('Completed Dummy Reset!')
        DisplayMessage('Completed Dummy Reset!')
        return
    end

    -- Process next dummy.
    local furnId = table.remove(TargetDummyTools.DummiesToReset, 1)
    local name, _, dataId = GetPlacedHousingFurnitureInfo(furnId)

    local removed = HousingEditorRequestRemoveFurniture(furnId)

    -- Failed to remove, skip.
    if removed ~= HOUSING_REQUEST_RESULT_SUCCESS then
        d('Failed to remove ' .. name .. '. Skipping...')
        TargetDummyTools.ResetSelectedDummies() -- Next.
    end

    zo_callLater(function()
        UndoLastHousingEditorCommand() -- Call once.

        -- Verify undo is complete, and move to next dummy.
        TargetDummyTools.VerifyUndo(furnId, maxRetries-1, name)
    end, 750)
end

function TargetDummyTools.ResetDummy()
    -- Must be in selection mode to avoid errors.
    local m = GetHousingEditorMode()
    if (m ~= HOUSING_EDITOR_MODE_DISABLED) and (m ~= HOUSING_EDITOR_MODE_SELECTION) then
        -- Leave other modes.
        HousingEditorRequestModeChange(HOUSING_EDITOR_MODE_DISABLED)

        zo_callLater(function()
            TargetDummyTools.ResetDummy()
        end, 500)

        return
    end

    local resultMode = HousingEditorRequestModeChange(HOUSING_EDITOR_MODE_SELECTION)

    if resultMode ~= HOUSING_REQUEST_RESULT_SUCCESS then
        ZO_AlertEvent(EVENT_HOUSING_EDITOR_REQUEST_RESULT, resultMode)
        return
    end

    -- Wait for mode change.
    zo_callLater(function()
        -- Validate selection.
        -- if not HousingEditorCanSelectTargettedFurniture() then
        --     -- Exit the housing editor.
        --     HousingEditorRequestModeChange(HOUSING_EDITOR_MODE_DISABLED)
        --     return
        -- end

        local selectResult = HousingEditorSelectTargettedFurniture()
        -- if selectResult ~= HOUSING_REQUEST_RESULT_SUCCESS then
        --     return
        -- end

        local id = HousingEditorGetSelectedFurnitureId()
        -- d('selectedId:', id)
        HousingEditorRequestModeChange(HOUSING_EDITOR_MODE_DISABLED)

        if not id then
            return
        end

        TargetDummyTools.DummiesToReset = {id}
        TargetDummyTools.ResetSelectedDummies()
    end, 750)
end

function TargetDummyTools.ResetAllDummies()
    -- Avoid concurrency!
    if #TargetDummyTools.DummiesToReset > 0 then return end

    local furns = {}
    local furnId = nil
    -- SPECIALIZED_ITEMTYPE_FURNISHING_TARGET_DUMMY 214

    local function GetNextPlacedFurnitureIdIter(state, var1)
        return GetNextPlacedHousingFurnitureId(var1)
    end

    for furnId in GetNextPlacedFurnitureIdIter do
        local _, _, dataId = GetPlacedHousingFurnitureInfo(furnId)
        if dataId then
            local categoryId, subcategoryId = GetFurnitureDataCategoryInfo(dataId)

            if categoryId then
                local category = GetFurnitureCategoryName(categoryId)
                local subCategory = GetFurnitureCategoryName(subcategoryId)

                -- NOTE: No exposed globals for these values. Values may change after a game patch!
                -- if category == 'Services' and subCategory == 'Training Dummies' then
                if categoryId == 25 and subcategoryId == 98 then
                -- if categoryId == 11 and subcategoryId == 124 then -- Test with Braziers.
                    table.insert(furns, furnId)
                end
            end
        end
    end

    -- No dummies found.
    if #furns == 0 then
        -- d('No Target Dummies found.')
        DisplayMessage('No Target Dummies found.')
        return
    else
        -- d('Resetting all Target Dummies...')
        DisplayMessage('Resetting all Target Dummies...')
    end

    -- Reset each dummy, with a global cooldown.
    TargetDummyTools.DummiesToReset = furns
    TargetDummyTools.ResetSelectedDummies()
end

-- Only show the loading message on first load ever.
function TargetDummyTools.Activated(e)
    EVENT_MANAGER:UnregisterForEvent(TargetDummyTools.name, EVENT_PLAYER_ACTIVATED)

    if TargetDummyTools.savedVars.firstLoad then
        TargetDummyTools.savedVars.firstLoad = false
    end
end
-- When player is ready, after everything has been loaded.
EVENT_MANAGER:RegisterForEvent(TargetDummyTools.name, EVENT_PLAYER_ACTIVATED, TargetDummyTools.Activated)

function TargetDummyTools.OnAddOnLoaded(event, addonName)
    if addonName ~= TargetDummyTools.name then return end
    EVENT_MANAGER:UnregisterForEvent(TargetDummyTools.name, EVENT_ADD_ON_LOADED)

    -- Slash commands must be lowercase!!! Set to nil to disable.
    SLASH_COMMANDS["/dummyreset"] = TargetDummyTools.ResetDummy
    SLASH_COMMANDS["/dummyresetall"] = TargetDummyTools.ResetAllDummies
end
-- When any addon is loaded, but before UI (Chat) is loaded.
EVENT_MANAGER:RegisterForEvent(TargetDummyTools.name, EVENT_ADD_ON_LOADED, TargetDummyTools.OnAddOnLoaded)