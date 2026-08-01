-- ============================================================================
-- Companion Wardrobe
-- Shared Colors and Loadout Color Profiles
--
-- Responsibilities:
-- - Define addon UI colors.
-- - Manage loadout color categories.
-- - Provide color profile handling.
-- - Resolve loadout name colors for UI display.
--
-- Notes:
-- - Color slot names are localization-aware.
-- - Profiles rebuild available color slots dynamically.
-- ============================================================================
if MHCWL == nil then MHCWL = {} end
local MHCWL = MHCWL

MHCWL.UI_COLORS = {
    active = {0.3, 1, 0.4, 1},
    favorite = {1, 0.88, 0.55, 1},
    normal = {1, 1, 1, 1},
    white = {1, 1, 1, 1},
    disabled = {0.6, 0.6, 0.6, 1},

    tabActive = {1.0, 0.82, 0.25, 1},
    tabInactive = {1, 1, 1, 1},

    buttonOver = {1, 1, 1, 1},
    buttonDown = {0.7, 0.8, 1, 1},
    pressedBlue = {0.5, 0.7, 1, 1},
    downBlue = {0.75, 0.85, 1, 1},
    hoverBlue = {0.8, 0.9, 1, 1},

    softYellow = {1, 1, 0.8, 1},

    dragRed = {1, 0.25, 0.25, 1},
    dragRedOver = {1, 0.35, 0.35, 1},
    dragRedDown = {1, 0.2, 0.2, 1},

    panelCenter = {0, 0, 0, 0.35},
    panelEdge = {0.35, 0.35, 0.35, 0.7},
    dropdownCenter = {0, 0, 0, 0.85},
    dropdownEdge = {0.4, 0.4, 0.4, 1},

    lockedGold = {1, 0.85, 0.35, 1},
    unlockedGrey = {0.7, 0.7, 0.7, 1},

    favoriteGold = {1, 0.85, 0.25, 1},
    favoriteInactive = {0.75, 0.80, 0.85, 0.35},
    favoriteOver = {0.9, 0.95, 1, 0.8},

    inactiveGrey = {0.65, 0.65, 0.65, 1},

    warningGold = {1, 0.8, 0.2, 1},
    warningGoldOver = {1, 1, 0.4, 1},
    warningGoldDown = {1, 0.6, 0.1, 1},

    blockedSlotRed = {1, 0.25, 0.25, 0.85},

    windowUnlockedHeaderCenter = {0.25, 0, 0, 0.45},
    windowUnlockedHeaderEdge = {0.8, 0.2, 0.2, 0.9},

    filterEnabled = {0.8, 0.9, 1, 1},
    filterDisabled = {0.75, 0.80, 0.85, 0.25},

    deleteRed = {1, 0.45, 0.45, 1},
    deleteRedOver = {1, 0.75, 0.75, 1},
    deleteRedDown = {1, 0.2, 0.2, 1},

    dialogCenter = {0, 0, 0, 0.92},
    dialogEdge = {0.4, 0.4, 0.4, 1},

    editBoxCenter = {0.22, 0.22, 0.22, 0.95},
    editBoxEdge = {0.50, 0.50, 0.50, 1},
}

MHCWL.ICON_BUTTON_COLORS = {
    normal = MHCWL.UI_COLORS.white,
    over = MHCWL.UI_COLORS.white,
    down = MHCWL.UI_COLORS.downBlue,
}

MHCWL.STANDARD_BUTTON_COLORS = {
    normal = MHCWL.UI_COLORS.white,
    over = MHCWL.UI_COLORS.hoverBlue,
    down = MHCWL.UI_COLORS.pressedBlue,
}

MHCWL.FILTER_BUTTON_COLORS = {
    over = MHCWL.UI_COLORS.white,
    down = MHCWL.UI_COLORS.pressedBlue,
}

MHCWL.TEXT_COLORS = {
    warning = "FF4444",
    skill = "B3E6FF",
}

function MHCWL.GetLoadoutListColor(setup, isActive)
-- Future idea:
-- Optional setting to use active font coloring:
-- use active loadout font coloring instead of highlight texture.
    --[[
    if isActive then
        return unpack(MHCWL.UI_COLORS.active)
    end
]]-- Active Loadout Color

    if setup and setup.isFavorite then
        if setup.useColorWhenFavorite then
            return MHCWL.GetLoadoutNameColor(setup)
        end

        return unpack(MHCWL.UI_COLORS.favorite)
    end

    return MHCWL.GetLoadoutNameColor(setup)
end

function MHCWL.GetActiveHighlightColor()
    local color =
        MHCWL.saved
        and MHCWL.saved.settings
        and MHCWL.saved.settings.activeHighlightColor
        or MHCWL.defaults.settings.activeHighlightColor

    return color[1] or 1, color[2] or 1, color[3] or 1, color[4] or 0.468
end

function MHCWL.GetInspectTextTabColor(mode)
    local color = MHCWL.inspectTextMode == mode
        and MHCWL.UI_COLORS.tabActive
        or MHCWL.UI_COLORS.tabInactive

    return {
        normal = color,
        over = MHCWL.UI_COLORS.buttonOver,
        down = MHCWL.UI_COLORS.buttonDown,
    }
end

MHCWL.COLOR_PROFILE_STANDARD = "standard"
MHCWL.COLOR_PROFILE_ROLE = "role"
MHCWL.COLOR_PROFILE_CUSTOM = "custom"

-- Ensure saved color slot data exists and remains compatible with current versions.
function MHCWL.EnsureLoadoutColorSlots()
    MHCWL.saved.settings.loadoutColorSlots =
        MHCWL.saved.settings.loadoutColorSlots or {}

    local slots = MHCWL.saved.settings.loadoutColorSlots
    local defaults = MHCWL.BuildStandardLoadoutColorSlots()

    for index = 0, 10 do
        slots[index] = slots[index] or MHCWL.DeepCopy(defaults[index])

        slots[index].name = slots[index].name or defaults[index].name
        slots[index].color = slots[index].color or MHCWL.DeepCopy(defaults[index].color)

        if slots[index].active == nil then
            slots[index].active = defaults[index].active ~= false
        end

        if index == 0 then
            slots[index].locked = true
            slots[index].active = true
        end
    end
end

function MHCWL.GetLoadoutColorSlot(index)
    MHCWL.EnsureLoadoutColorSlots()

    index = tonumber(index) or 0

    local slots =
        MHCWL.saved
        and MHCWL.saved.settings
        and MHCWL.saved.settings.loadoutColorSlots

    if not slots then
        return nil
    end

    return slots[index] or slots[0]
end

function MHCWL.GetLoadoutColorSlotColor(index)
    local slot = MHCWL.GetLoadoutColorSlot(index)
    return slot and slot.color or MHCWL.UI_COLORS.white
end

function MHCWL.GetLoadoutColorSlotName(index)
    local slot = MHCWL.GetLoadoutColorSlot(index)
    return slot and slot.name or GetString(MHCWL_COLOR_DEFAULT)
end

function MHCWL.GetSetupColorSlotIndex(setup)
    return setup and tonumber(setup.nameColorSlot) or 0
end

function MHCWL.SetSetupColorSlot(setup, slotIndex)
    if not setup then return end

    slotIndex = tonumber(slotIndex) or 0

    if slotIndex == 0 then
        setup.nameColorSlot = nil
    else
        setup.nameColorSlot = slotIndex
    end
end

-- Resolve the final display color used for a loadout name.
function MHCWL.GetLoadoutNameColor(setup)
    local slotIndex = MHCWL.GetSetupColorSlotIndex(setup)
    return unpack(MHCWL.GetLoadoutColorSlotColor(slotIndex))
end

-- Default color profile used by new installations.
function MHCWL.BuildStandardLoadoutColorSlots()
    return {
        [0] = { name = GetString(MHCWL_COLOR_DEFAULT), color = {1, 1, 1, 1}, active = true, locked = true },

        [1] = { name = GetString(MHCWL_COLOR_RED),    color = {1, 0.35, 0.35, 1}, active = true },
        [2] = { name = GetString(MHCWL_COLOR_ORANGE), color = {1, 0.55, 0.20, 1}, active = true },
        [3] = { name = GetString(MHCWL_COLOR_YELLOW), color = {1, 0.85, 0.25, 1}, active = true },
        [4] = { name = GetString(MHCWL_COLOR_GREEN),  color = {0.35, 1, 0.45, 1}, active = true },
        [5] = { name = GetString(MHCWL_COLOR_BLUE),   color = {0.45, 0.75, 1, 1}, active = true },
        [6] = { name = GetString(MHCWL_COLOR_PURPLE), color = {0.75, 0.45, 1, 1}, active = true },

        [7]  = { name = GetString(MHCWL_COLOR_CUSTOM) .. " 7",  color = {1, 1, 1, 1}, active = false },
        [8]  = { name = GetString(MHCWL_COLOR_CUSTOM) .. " 8",  color = {1, 1, 1, 1}, active = false },
        [9]  = { name = GetString(MHCWL_COLOR_CUSTOM) .. " 9",  color = {1, 1, 1, 1}, active = false },
        [10] = { name = GetString(MHCWL_COLOR_CUSTOM) .. " 10", color = {1, 1, 1, 1}, active = false },
    }
end

-- Role-based color profile (Tank, Healer, DPS, Support).
function MHCWL.BuildRoleLoadoutColorSlots()
    return {
        [0] = { name = GetString(MHCWL_COLOR_DEFAULT),      color = {1, 1, 1, 1}, active = true, locked = true },
        [1] = { name = GetString(MHCWL_COLOR_ROLE_TANK),    color = {1, 0.35, 0.35, 1}, active = true },
        [2] = { name = GetString(MHCWL_COLOR_ROLE_HEALER),  color = {0.35, 1, 0.45, 1}, active = true },
        [3] = { name = GetString(MHCWL_COLOR_ROLE_DPS),     color = {1, 0.85, 0.25, 1}, active = true },
        [4] = { name = GetString(MHCWL_COLOR_ROLE_SUPPORT), color = {0.45, 0.75, 1, 1}, active = true },
    }
end

-- Fully customizable color profile exposing all user-defined slots.
function MHCWL.BuildCustomLoadoutColorSlots()
    local slots = {
        [0] = { name = GetString(MHCWL_COLOR_DEFAULT), color = {1, 1, 1, 1}, active = true, locked = true },
    }

    for index = 1, 10 do
        slots[index] = {
            name = GetString(MHCWL_COLOR_CUSTOM) .. " " .. tostring(index),
            color = {1, 1, 1, 1},
            active = true,
        }
    end

    return slots
end

-- Ensure the persistent Custom color profile storage exists and matches the
-- current slot structure. Unlike the active profile slots, this table is owned
-- by the user and must survive switching between Standard, Roles, and Custom.
function MHCWL.EnsureCustomLoadoutColorSlots()
    MHCWL.saved.settings.customLoadoutColorSlots =
        MHCWL.saved.settings.customLoadoutColorSlots
        or MHCWL.BuildCustomLoadoutColorSlots()

    local customSlots = MHCWL.saved.settings.customLoadoutColorSlots
    local defaults = MHCWL.BuildCustomLoadoutColorSlots()

    for index = 0, 10 do
        customSlots[index] = customSlots[index] or MHCWL.DeepCopy(defaults[index])

        customSlots[index].name =
            customSlots[index].name
            or defaults[index].name

        customSlots[index].color =
            customSlots[index].color
            or MHCWL.DeepCopy(defaults[index].color)

        if customSlots[index].active == nil then
            customSlots[index].active = defaults[index].active == true
        end

        if index == 0 then
            customSlots[index].locked = true
            customSlots[index].active = true
        end
    end
end

-- Persist the currently active color slots as the Custom profile before leaving
-- Custom mode. This preserves user-edited names, colors, and enabled states so
-- switching to another profile does not destroy Custom configuration.
function MHCWL.SaveCurrentLoadoutColorSlotsAsCustom()
    if not MHCWL.saved
    or not MHCWL.saved.settings
    or not MHCWL.saved.settings.loadoutColorSlots then
        return
    end

    MHCWL.EnsureCustomLoadoutColorSlots()

    local slots = MHCWL.saved.settings.loadoutColorSlots
    local customSlots = MHCWL.saved.settings.customLoadoutColorSlots

    for index = 0, 10 do
        if slots[index] then
            customSlots[index] = MHCWL.DeepCopy(slots[index])
        end

        if index == 0 and customSlots[index] then
            customSlots[index].locked = true
            customSlots[index].active = true
        end
    end
end

-- Rebuild available color slots according to the selected profile.
function MHCWL.ApplyLoadoutColorProfile(profile)
    MHCWL.EnsureLoadoutColorSlots()
    MHCWL.EnsureCustomLoadoutColorSlots()

    profile = profile or MHCWL.COLOR_PROFILE_STANDARD

    local previousProfile =
        MHCWL.saved.settings.colorProfile
        or MHCWL.COLOR_PROFILE_STANDARD

    if previousProfile == MHCWL.COLOR_PROFILE_CUSTOM then
        MHCWL.SaveCurrentLoadoutColorSlotsAsCustom()
    end

    MHCWL.saved.settings.colorProfile = profile

    local slots = MHCWL.saved.settings.loadoutColorSlots

    local profileSlots

    if profile == MHCWL.COLOR_PROFILE_ROLE then
        profileSlots = MHCWL.BuildRoleLoadoutColorSlots()
    elseif profile == MHCWL.COLOR_PROFILE_CUSTOM then
        profileSlots = MHCWL.saved.settings.customLoadoutColorSlots
    else
        profileSlots = MHCWL.BuildStandardLoadoutColorSlots()
    end

    for index = 0, 10 do
        local source = profileSlots[index] or {
            name = GetString(MHCWL_COLOR_COLOR) .. " " .. tostring(index),
            color = {1, 1, 1, 1},
            active = false,
        }

        slots[index].name = source.name
        slots[index].color = MHCWL.DeepCopy(source.color)
        slots[index].active = source.active == true

        if index == 0 then
            slots[index].locked = true
            slots[index].active = true
        else
            slots[index].locked = source.locked == true
        end
    end

    MHCWL.RefreshLoadoutColorDropdown()
    MHCWL.RefreshWindow()
    MHCWL.RefreshOpenInspectWindow()
end