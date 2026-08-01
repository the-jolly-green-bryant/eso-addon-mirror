-- ============================================================================
-- Companion Wardrobe
-- Companion State and Companion Menu Integration
--
-- Responsibilities:
-- - Detect the active companion and companion identity.
-- - Integrate Companion Wardrobe with ESO's companion menu.
-- - Manage the companion menu toggle button.
-- - Close addon UI when companion context changes or closes.
-- ============================================================================
if MHCWL == nil then MHCWL = {} end
local MHCWL = MHCWL

function MHCWL.GetCompanionDisplayName(companionId)
    if not companionId then return GetString(MHCWL_UNKNOWN) end

    local rawName = GetCompanionName(companionId) or GetString(MHCWL_UNKNOWN)
    return zo_strformat("<<1>>", rawName)
end

function MHCWL.GetActiveCompanionDisplayName()
    if not HasActiveCompanion() then return nil end
    return MHCWL.GetCompanionDisplayName(GetActiveCompanionDefId())
end

function MHCWL.RegisterCompanionEvents()
    EVENT_MANAGER:RegisterForEvent(
        MHCWL.name .. "CompanionMenuOpen",
        EVENT_OPEN_COMPANION_MENU,
        function()
            MHCWL.OnCompanionMenuOpened()
        end
    )

    EVENT_MANAGER:RegisterForEvent(
        MHCWL.name .. "CompanionState",
        EVENT_ACTIVE_COMPANION_STATE_CHANGED,
        function(_, newState, oldState)
            MHCWL.Debug("Companion state changed: " .. tostring(oldState) .. " -> " .. tostring(newState))

            MHCWL.ClearLoadoutRows()
            MHCWL.CloseWindows()
            MHCWL.CloseDropdowns()
            MHCWL.CloseDialogs()

            if newState == COMPANION_STATE_ACTIVE then
                zo_callLater(function()
                    if MHCWL.window and not MHCWL.window:IsHidden() then
                        MHCWL.RebuildWindowContent()
                    end
                end, 500)
            else
                if MHCWL.window then
                    MHCWL.window:SetHidden(true)
                end
            end
        end
    )

    EVENT_MANAGER:RegisterForEvent(
        MHCWL.name .. "BankOpenGearFetch",
        EVENT_OPEN_BANK,
        function()
            MHCWL.OnBankOpenedForGearFetch()
        end
    )
end

function MHCWL.StartCompanionMenuWatcher()
    EVENT_MANAGER:RegisterForUpdate(MHCWL.name .. "CompanionMenuWatcher", 250, function()
        if not IsInteractingWithMyCompanion() then
            EVENT_MANAGER:UnregisterForUpdate(MHCWL.name .. "CompanionMenuWatcher")

            MHCWL.CloseWindows()
            MHCWL.CloseDropdowns()
            MHCWL.CloseDialogs()

            MHCWL.Debug("Companion menu closed.")
        end
    end)
end

MHCWL.COMPANION_SILHOUETTES = {
    [1] = "silhouetteHumanMale",      -- Bastian
    [2] = "silhouetteHumanFemale",    -- Mirri
    [5] = "silhouetteKhajiitFemale",  -- Ember
    [6] = "silhouetteHumanFemale",    -- Isobel
    [8] = "silhouetteArgonianMale",   -- Sharp
    [9] = "silhouetteHumanMale",      -- Azandar
    [12] = "silhouetteHumanFemale",   -- Tanlorin
    [13] = "silhouetteKhajiitMale",   -- Zerith-var
}

function MHCWL.GetCompanionSilhouetteByRaceGender(companionDefId)
    local race = GetCompanionRace(companionDefId)
    local gender = GetCompanionGender(companionDefId)

    if race == 9 then -- Khajiit
        return gender == 2
            and MHCWL.TEXTURES.silhouetteKhajiitMale
            or MHCWL.TEXTURES.silhouetteKhajiitFemale
    end

    if race == 6 then -- Argonian
        return gender == 2
            and MHCWL.TEXTURES.silhouetteArgonianMale
            or MHCWL.TEXTURES.silhouetteArgonianFemale
    end

    return gender == 2
        and MHCWL.TEXTURES.silhouetteHumanMale
        or MHCWL.TEXTURES.silhouetteHumanFemale
end

function MHCWL.GetCompanionSilhouetteTexture(companionDefId)
    if not companionDefId then
        return MHCWL.TEXTURES[MHCWL.DEFAULT_COMPANION_SILHOUETTE]
    end

    local mode =
        MHCWL.saved
        and MHCWL.saved.settings
        and MHCWL.saved.settings.silhouetteMode
        or MHCWL.SILHOUETTE_MODE_AUTO

    if mode == MHCWL.SILHOUETTE_MODE_COMPANION_ID then
        local iconKey = MHCWL.COMPANION_SILHOUETTES[companionDefId]

        if iconKey and MHCWL.TEXTURES[iconKey] then
            return MHCWL.TEXTURES[iconKey]
        end
    end

    return MHCWL.GetCompanionSilhouetteByRaceGender(companionDefId)
end