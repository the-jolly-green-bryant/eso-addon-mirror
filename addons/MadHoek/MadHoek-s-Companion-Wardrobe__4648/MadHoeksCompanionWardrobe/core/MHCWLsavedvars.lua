-- ============================================================================
-- Companion Wardrobe
-- SavedVariables and Shared Data Helpers
--
-- Responsibilities:
-- - Define SavedVariables defaults and addon timing constants.
-- - Initialize and migrate account-wide saved data.
-- - Provide companion/setup access helpers used across the addon.
-- - Keep loadout slot structure valid after creation, deletion, or import.
-- ============================================================================
if MHCWL == nil then MHCWL = {} end
local MHCWL = MHCWL

MHCWL.savedName = "CompanionWardrobeSV"
MHCWL.savedVersion = 1

MHCWL.SILHOUETTE_MODE_AUTO = "auto"
MHCWL.SILHOUETTE_MODE_COMPANION_ID = "companionId"
MHCWL.DEFAULT_COMPANION_SILHOUETTE = "silhouetteHumanFemale"

MHCWL.TOOLTIP_MODE_OFF = 0
MHCWL.TOOLTIP_MODE_SIMPLE = 1
MHCWL.TOOLTIP_MODE_TUTORIAL = 2

MHCWL.defaults = {
    addonVersion = MHCWL.version,
    companions = {},
    settings = {
        debug = false,
        debugMessages = false,
        debugTimingSafetyMs = 0,
        debugForceLockedSkills = false,
        debugShowSlot7InUltimate = false,
        tooltipMode = MHCWL.TOOLTIP_MODE_TUTORIAL,
        saveGear = true,
        loadGear = true,
        saveSkills = true,
        loadSkills = true,
        loadoutSortMode = "slot",
        favoriteLoadoutSortMode = "slot",
        silhouetteMode = MHCWL.SILHOUETTE_MODE_AUTO,
        showFavoriteLoadouts = true,
        showNormalLoadouts = true,
        activeHighlightColor = {1, 1, 1, 0.468},
        colorProfile = "standard",
        customLoadoutColorSlots = nil,
        window = {
            showWith = true,
            unlocked = false,
            left = 241,
            top = 276,
        },
        companionButton = {
            enabled = true,
            unlocked = false,
            left = 1340,
            top = 1160,
        },
        dialogs = {
            export = { left = nil, top = nil },
            import = { left = nil, top = nil },
        }
    },
}

MHCWL.TIMINGS = {
    gearLoadStep = 100,
    gearLoadFinish = 100,

    skillLoadFinish = 100,

    loadSetupFinish = 500,

    gearMoveStep = 100,
}

-- Initialize account-wide SavedVariables and backfill settings added by later versions.
function MHCWL.InitializeSavedVars()
    MHCWL.saved = ZO_SavedVars:NewAccountWide(
        MHCWL.savedName,
        MHCWL.savedVersion,
        nil,
        MHCWL.defaults
    )

	if (MHCWL.saved.addonVersion == nil) or (MHCWL.saved.addonVersion ~= MHCWL.version) then
		-- migration: place something below, if necessary.

		-- mark migration/version as done
		MHCWL.saved.addonVersion = MHCWL.version
	end

    if MHCWL.saved.settings.debug                       == nil then MHCWL.saved.settings.debug                      = MHCWL.defaults.settings.debug                       end
    if MHCWL.saved.settings.debugMessages               == nil then MHCWL.saved.settings.debugMessages              = MHCWL.defaults.settings.debugMessages               end
    if MHCWL.saved.settings.debugTimingSafetyMs         == nil then MHCWL.saved.settings.debugTimingSafetyMs        = MHCWL.defaults.settings.debugTimingSafetyMs         end
    if MHCWL.saved.settings.debugForceLockedSkills      == nil then MHCWL.saved.settings.debugForceLockedSkills     = MHCWL.defaults.settings.debugForceLockedSkills      end
    if MHCWL.saved.settings.tooltipMode                 == nil then MHCWL.saved.settings.tooltipMode                = MHCWL.defaults.settings.tooltipMode                 end
    if MHCWL.saved.settings.saveGear                    == nil then MHCWL.saved.settings.saveGear                   = MHCWL.defaults.settings.saveGear                    end
    if MHCWL.saved.settings.loadGear                    == nil then MHCWL.saved.settings.loadGear                   = MHCWL.defaults.settings.loadGear                    end
    if MHCWL.saved.settings.saveSkills                  == nil then MHCWL.saved.settings.saveSkills                 = MHCWL.defaults.settings.saveSkills                  end
    if MHCWL.saved.settings.loadSkills                  == nil then MHCWL.saved.settings.loadSkills                 = MHCWL.defaults.settings.loadSkills                  end
    if MHCWL.saved.settings.loadoutSortMode             == nil then MHCWL.saved.settings.loadoutSortMode            = MHCWL.defaults.settings.loadoutSortMode             end
    if MHCWL.saved.settings.silhouetteMode              == nil then MHCWL.saved.settings.silhouetteMode             = MHCWL.defaults.settings.silhouetteMode              end
    if MHCWL.saved.settings.showFavoriteLoadouts        == nil then MHCWL.saved.settings.showFavoriteLoadouts       = MHCWL.defaults.settings.showFavoriteLoadouts        end
    if MHCWL.saved.settings.showNormalLoadouts          == nil then MHCWL.saved.settings.showNormalLoadouts         = MHCWL.defaults.settings.showNormalLoadouts          end
    if MHCWL.saved.settings.colorProfile                == nil then MHCWL.saved.settings.colorProfile               = MHCWL.defaults.settings.colorProfile                end

    if MHCWL.saved.settings.debugShowSlot7InUltimate == nil then
        MHCWL.saved.settings.debugShowSlot7InUltimate =
            MHCWL.defaults.settings.debugShowSlot7InUltimate
    end

    if MHCWL.saved.settings.loadoutColorSlots == nil then
        MHCWL.saved.settings.loadoutColorSlots =
            MHCWL.BuildStandardLoadoutColorSlots()
    end

    if MHCWL.saved.settings.customLoadoutColorSlots == nil then
        MHCWL.saved.settings.customLoadoutColorSlots =
            MHCWL.BuildCustomLoadoutColorSlots()
    end

    if MHCWL.saved.settings.activeHighlightColor == nil then
        MHCWL.saved.settings.activeHighlightColor =
            MHCWL.DeepCopy(MHCWL.defaults.settings.activeHighlightColor)
    end

    if MHCWL.saved.settings.window == nil then
        MHCWL.saved.settings.window = MHCWL.DeepCopy(MHCWL.defaults.settings.window)
    end
    if MHCWL.saved.settings.window.showWith     == nil then MHCWL.saved.settings.window.showWith    = MHCWL.defaults.settings.window.showWith   end
    if MHCWL.saved.settings.window.unlocked     == nil then MHCWL.saved.settings.window.unlocked    = MHCWL.defaults.settings.window.unlocked   end
    if MHCWL.saved.settings.window.left         == nil then MHCWL.saved.settings.window.left        = MHCWL.defaults.settings.window.left       end
    if MHCWL.saved.settings.window.top          == nil then MHCWL.saved.settings.window.top         = MHCWL.defaults.settings.window.top        end

    if MHCWL.saved.settings.companionButton == nil then
        MHCWL.saved.settings.companionButton = MHCWL.DeepCopy(MHCWL.defaults.settings.companionButton)
    end
    if MHCWL.saved.settings.companionButton.enabled     == nil then MHCWL.saved.settings.companionButton.enabled    = MHCWL.defaults.settings.companionButton.enabled   end
    if MHCWL.saved.settings.companionButton.unlocked    == nil then MHCWL.saved.settings.companionButton.unlocked   = MHCWL.defaults.settings.companionButton.unlocked  end
    if MHCWL.saved.settings.companionButton.left        == nil then MHCWL.saved.settings.companionButton.left       = MHCWL.defaults.settings.companionButton.left      end
    if MHCWL.saved.settings.companionButton.top         == nil then MHCWL.saved.settings.companionButton.top        = MHCWL.defaults.settings.companionButton.top       end

    if MHCWL.saved.settings.dialogs == nil then
        MHCWL.saved.settings.dialogs =
            MHCWL.DeepCopy(MHCWL.defaults.settings.dialogs or {})
    end

    if MHCWL.saved.settings.dialogs.export == nil then
        MHCWL.saved.settings.dialogs.export =
            MHCWL.DeepCopy(MHCWL.defaults.settings.dialogs.export or {})
    end

    if MHCWL.saved.settings.dialogs.import == nil then
        MHCWL.saved.settings.dialogs.import =
            MHCWL.DeepCopy(MHCWL.defaults.settings.dialogs.import or {})
    end
end

MHCWL.DEFAULT_SETUP_SLOTS = 0
MHCWL.MAX_SETUP_SLOTS = 100
MHCWL.LOADOUTS_PER_PAGE = 10

-- Apply the optional debug timing buffer to queued addon actions.
function MHCWL.GetDelay(baseDelay)
    local safety =
        MHCWL.saved
        and MHCWL.saved.settings
        and tonumber(MHCWL.saved.settings.debugTimingSafetyMs)
        or 0

    return baseDelay + safety
end

function MHCWL.GetActiveCompanionSavedData()
    if not HasActiveCompanion() then return nil end
    return MHCWL.GetCompanionSavedData(GetActiveCompanionDefId())
end

-- Ensure a companion has a valid setup table, active setup, and page state.
function MHCWL.EnsureCompanionSetups(companionData)
    companionData.setups = companionData.setups or {}
    companionData.activeSetup = companionData.activeSetup or 0
    companionData.activePage = companionData.activePage or 1

    for _, setup in ipairs(companionData.setups) do
        setup.locked = setup.locked or false
        setup.isFavorite = setup.isFavorite or false
        setup.useColorWhenFavorite = setup.useColorWhenFavorite or false
        setup.gear = setup.gear or {}
        setup.skills = setup.skills or {}
    end
end

function MHCWL.GetSetupCount(companionData)
    if not companionData or not companionData.setups then return 0 end

    local count = 0
    for i, _ in ipairs(companionData.setups) do
        count = i
    end

    return count
end

-- Create a new empty loadout slot for the active companion data.
function MHCWL.AddSetup(companionData)
    if not companionData then return nil end

    MHCWL.EnsureCompanionSetups(companionData)

    local index = MHCWL.GetSetupCount(companionData) + 1
    if index > MHCWL.MAX_SETUP_SLOTS then
        return nil
    end

    companionData.setups[index] = {
        name = GetString(MHCWL_LOADOUT) .. tostring(index),
        locked = false,
        isFavorite = false,
        gear = {},
        skills = {},
    }

    companionData.activeSetup = index

    return index
end

function MHCWL.GetCompanionSavedData(companionId)
    if not companionId then return nil end

    MHCWL.saved.companions[companionId] =
        MHCWL.saved.companions[companionId] or {
            name = MHCWL.GetCompanionDisplayName(companionId),
            activeSetup = 1,
            activePage = 1,
            setups = {},
        }

    local companionData = MHCWL.saved.companions[companionId]

    companionData.name = MHCWL.GetCompanionDisplayName(companionId)
    companionData.activeSetup = companionData.activeSetup or 1

    MHCWL.EnsureCompanionSetups(companionData)

    return companionData
end

-- Remove a loadout slot and compact the remaining setup indexes.
function MHCWL.RemoveSetup(companionData, index)
    if not companionData then return false end

    local count = MHCWL.GetSetupCount(companionData)
    if index < 1 or index > count then return false end

    table.remove(companionData.setups, index)

    local newCount = MHCWL.GetSetupCount(companionData)

    if newCount == 0 then
        companionData.activeSetup = 0
    elseif companionData.activeSetup > newCount then
        companionData.activeSetup = newCount
    elseif companionData.activeSetup < 1 then
        companionData.activeSetup = 1
    end

    return true
end