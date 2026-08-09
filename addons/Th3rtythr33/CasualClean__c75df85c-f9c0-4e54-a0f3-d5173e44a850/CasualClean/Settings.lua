-- =============================================================================
-- CasualClean -- Settings.lua
-- =============================================================================
-- LibHarvensAddonSettings panel.
--
-- NO NIL-GUARD, BY DESIGN. LHAS is a hard `## DependsOn`, exposed as the plain
-- global LibHarvensAddonSettings (no LibStub, and it must never be vendored --
-- it errors if loaded twice). If it is missing the game disables this addon
-- before any of our code runs, so a fallback branch could only ever be dead
-- code. Same reasoning as UnderPressure/Settings.lua.
--
-- REGISTRATION TIMING IS LOAD-BEARING. LHAS initialises lazily on the first
-- Main Menu show and snapshots its addon list at that moment, so Init() must
-- be reached from EVENT_ADD_ON_LOADED or this addon never appears at all.
--
-- CONSOLE ENTRY POINT is an "Add-Ons" item injected into the gamepad Main
-- Menu (before Activity Finder), NOT Settings -> Add-Ons. It renames itself
-- "Add-Ons 2" if LibAddonMenu2 is also loaded, so the label a player sees
-- depends on their other addons.
--
-- FIELD NAMES differ from LibAddonMenu: getFunction/setFunction/label, not
-- getFunc/setFunc/name. There is no `decimals`; `format` replaces it and
-- governs the STORED value, not just the display, because the value goes
-- through tonumber(string.format(format, v)) before reaching setFunction.
-- Hence "%.0f" and never "%d" -- under Lua 5.1 %d truncates a float rather
-- than rounding, so a slider reading 64 can store 63.
--
-- Every selectable row carries a tooltip: a row without one blanks the whole
-- left tooltip quadrant when selected, which reads as broken next to its
-- neighbours.
--
-- SECTIONS ARE DRILL-DOWNS. Every ST_SECTION becomes a navigable sub-menu row
-- unless given `subMenu = false`, so the top-level screen is one arrow row
-- ("Mag/Stam Arcs") and the controls live one level down. Requested that way
-- 2026-08-08 even though there is currently only one section, so the shape is
-- already right when a second feature gets its own.
--
-- The consequence that constrains the copy below: on a drilled-down page the
-- header keeps showing the ADDON, and the section title is NOT redisplayed
-- anywhere. Every label therefore has to make sense with no section for
-- context -- which is why they all carry an explicit "Arc" or spell out
-- "magicka and stamina" rather than relying on the section name.
--
-- Reset to Defaults is worth knowing about: its keybind only appears once you
-- are INSIDE a section, which with this layout means it is always reachable,
-- but it resets ALL sections when pressed.
-- =============================================================================

CasualClean = CasualClean or {}
local CC = CasualClean
CC.Settings = {}

-- Resolved in Init() rather than at file scope. `## DependsOn` does guarantee
-- the library is parsed first, so a file-scope lookup would work; this is a
-- lookup, not a guard.
local LHAS

local function sv()
    return CC.sv
end

function CC.Settings.Init()
    LHAS = LibHarvensAddonSettings
    local Arcs = CC.MagStamArcs

    local panel = LHAS:AddAddon("CasualClean", {
        allowDefaults = true,
        -- Not LAM's registerForRefresh. LHAS refreshes on panel-show for
        -- free; allowRefresh re-runs EVERY control's getter whenever ANY
        -- control changes, which is only worth it for cross-control `disable`
        -- logic. There is none here, and its refresh path pushes into sliders
        -- without detaching OnValueChanged first.
        allowRefresh = false,
    })

    -- Built once here rather than inline in the setting, so the same table
    -- identity backs both the item list and the name lookup.
    local fillItems = {}
    for _, direction in ipairs({ Arcs.FILL_BOTTOM_UP, Arcs.FILL_TOP_DOWN, Arcs.FILL_CENTRE_OUT }) do
        fillItems[#fillItems + 1] = { name = Arcs.FILL_DIRECTION_NAMES[direction], data = direction }
    end

    panel:AddSettings({
        {
            -- No `subMenu = false`, so this renders as a drill-down row and
            -- everything after it lives on the sub-page it opens.
            type = LHAS.ST_SECTION,
            label = "Mag/Stam Arcs",
            tooltip = "The magicka and stamina arcs that flank your reticle.",
        },
        {
            -- On console ST_DROPDOWN is rendered as a ZO_GamepadHorizontalListRow
            -- (left/right on the d-pad), not a drop-down list -- which suits a
            -- three-way choice better than a menu would.
            type = LHAS.ST_DROPDOWN,
            label = "Arc fill direction",
            tooltip = "Which way the magicka and stamina arcs drain as you spend the resource. " ..
                      "Bottom-up is conventional; centre-out thins the arc symmetrically from the middle.",
            items = fillItems,
            -- Returns the item's NAME. LHAS matches the current value with
            -- FindIndexFromData(getFunction(), equalityFunction), and that
            -- equality function's first clause is `leftData == rightData.name`
            -- -- so a plain name string is what selects the right entry on
            -- panel open. Returning the enum number here would silently fall
            -- through to the default every time the panel is reopened.
            getFunction = function() return Arcs.GetFillDirectionName() end,
            setFunction = function(_, _, item) Arcs.SetFillDirection(item.data) end,
            default = Arcs.DEFAULT_FILL_DIRECTION,
        },
        {
            type = LHAS.ST_SLIDER,
            label = "Arc distance from centre",
            tooltip = ("How far each arc sits from the centre of the screen, in pixels. Default: %d.")
                :format(Arcs.DEFAULT_ARC_OFFSET_X),
            min = 32,
            max = 300,
            step = 2,
            unit = "px",
            format = "%.0f",
            getFunction = function() return sv().arcOffsetX end,
            setFunction = function(value) Arcs.SetArcOffsetX(value) end,
            default = Arcs.DEFAULT_ARC_OFFSET_X,
        },
        {
            type = LHAS.ST_SLIDER,
            label = "Arc height",
            tooltip = ("Height of each arc in pixels. The width scales with it, so the shape is " ..
                       "preserved. Default: %d."):format(Arcs.DEFAULT_ARC_HEIGHT),
            min = 64,
            max = 320,
            step = 4,
            unit = "px",
            format = "%.0f",
            getFunction = function() return sv().arcHeight end,
            setFunction = function(value) Arcs.SetArcHeight(value) end,
            default = Arcs.DEFAULT_ARC_HEIGHT,
        },
        {
            -- Deliberately last: it is the destructive-looking one, and it is
            -- the only control here that changes something outside this
            -- addon's own UI.
            --
            -- Magicka and stamina only, not health -- those are the two the
            -- arcs actually replace, and hiding health would leave it with no
            -- readout at all.
            type = LHAS.ST_CHECKBOX,
            label = "Hide default magicka and stamina bars",
            tooltip = "Hides ESO's own magicka and stamina bars, which the arcs replace. " ..
                      "Turn this off to show both at once. Your health bar is never affected. " ..
                      "Like the arcs themselves, this applies everywhere, including Cyrodiil, " ..
                      "Battlegrounds, Dungeons and Trials.",
            getFunction = function() return Arcs.GetHideDefaultBars() end,
            setFunction = function(value) Arcs.SetHideDefaultBars(value) end,
            default = Arcs.DEFAULT_HIDE_DEFAULT_BARS,
        },
    })
end
