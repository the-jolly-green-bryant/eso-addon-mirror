-- LibArmorInsulation_Settings.lua
-- Builds the LibAddonMenu-2.0 settings panel.
--
-- LibAddonMenu-2.0 (LAM) API used:
--   LibAddonMenu2:RegisterAddonPanel(panelId, panelData)
--   LibAddonMenu2:RegisterOptionControls(panelId, optionsTable)
-- Ref: https://wiki.esoui.com/LibAddonMenu
--
-- OVERRIDE EDITOR (staggered tier system, v2.6.0+)
-- Overrides are set by picking one of the eleven fixed tiers from a dropdown
-- (see TIER_CHOICES below) rather than typing an arbitrary 0-100 number. This
-- guarantees an override can never drift off the tier ladder. The stored tier
-- is always a FULL-BODY reference value; the actual per-slot contribution for
-- armor/outfit pieces is still calculated from it based on which slot the
-- item occupies (see LibArmorInsulation.Calc.ComputeSlotInsulation /
-- ComputeOutfitSlotInsulation). Costume overrides are used directly as the
-- total, unadjusted, since costumes cover the whole body at once.

LibArmorInsulation = LibArmorInsulation or {}
LibArmorInsulation.Settings = {}
local Settings = LibArmorInsulation.Settings

-- Forward declarations (filled in by LibArmorInsulation.lua at init time)
Settings.sv     = nil   -- saved variables table
Settings.panelId = "LibArmorInsulationPanel"

-- ─────────────────────────────────────────────────────────────────────────────
-- Tier dropdown choices
-- ─────────────────────────────────────────────────────────────────────────────
-- Built once at file load — LibArmorInsulation.Data.TIER_VALUES/TierInfo are
-- static tables defined in LibArmorInsulation_StyleData.lua, which loads
-- before this file per LibArmorInsulation.txt's load order, so no dependency
-- on EVENT_ADD_ON_LOADED is needed here.
local TIER_CHOICES         = {}   -- ordered list of display strings for the dropdown
local CLEAR_CHOICE         = "(no override)"
local choiceToTierValue    = {}   -- display string -> tier integer (nil entry excluded)
local tierValueToChoice    = {}   -- tier integer -> display string

local function BuildTierChoices()
    TIER_CHOICES = { CLEAR_CHOICE }
    for _, tierValue in ipairs(LibArmorInsulation.Data.TIER_VALUES) do
        local info = LibArmorInsulation.Data.TierInfo[tierValue]
        local choiceStr = string.format("%d — %s", tierValue, info and info.label or "?")
        TIER_CHOICES[#TIER_CHOICES + 1] = choiceStr
        choiceToTierValue[choiceStr] = tierValue
        tierValueToChoice[tierValue] = choiceStr
    end
end
BuildTierChoices()

-- ─────────────────────────────────────────────────────────────────────────────
-- Helper: build the "current insulation" section rows dynamically
-- This is called whenever the panel is opened or the refresh button is pressed.
-- ─────────────────────────────────────────────────────────────────────────────
local function BuildCurrentInsulationLabel()
    local breakdown = LibArmorInsulation.Calc.GetInsulationBreakdown(
        Settings.sv and Settings.sv.overrides or nil
    )
    local Calc = LibArmorInsulation.Calc
    local lines = {}
    lines[#lines + 1] = string.format("Source: %s", breakdown.source)
    lines[#lines + 1] = string.format("Total insulation: %d  (~%s)", breakdown.total, Calc.GetTierLabel(Calc.SnapToTier(breakdown.total, true)))
    lines[#lines + 1] = " "

    for slotKey, slotData in pairs(breakdown.slots) do
        local label = LibArmorInsulation.Calc.GetSlotLabel(slotKey)
        local extra = (slotData.flavorNote and slotData.flavorNote ~= "")
                      and (" (" .. slotData.flavorNote .. ")") or ""
        -- Prefer whichever resolved name is available. Both styleName
        -- (armor, from the game's own GetItemStyleName/StyleNameById map)
        -- and name (outfit/costume/polymorph, from GetCollectibleName) come
        -- straight from the ESO API, so they're populated even when the
        -- style/collectible isn't one of the entries LibArmorInsulation's
        -- own data tables recognize -- only a genuinely empty slot or an
        -- ID the game itself can't name at all falls back to "?".
        local displayName = slotData.name or slotData.styleName or "?"
        local idLabel
        if slotData.collectibleId then
            idLabel = string.format("collectible %d, %s", slotData.collectibleId, displayName)
        elseif slotData.styleId and slotData.styleId ~= 0 then
            idLabel = string.format("style %d, %s", slotData.styleId, displayName)
        else
            idLabel = "—"
        end
        local fallback = slotData.armorFallback and " [armor]" or ""
        local tierStr  = slotData.tier and string.format(", tier %d %s", slotData.tier, Calc.GetTierLabel(slotData.tier)) or ""
        local pctStr   = slotData.slotPercentage and string.format(" x %d%%", math.floor(slotData.slotPercentage * 100 + 0.5)) or ""
        lines[#lines + 1] = string.format(
            "  %s: %d  [%s, %s%s]%s%s",
            label,
            slotData.insulation,
            idLabel,
            slotData.material,
            tierStr,
            pctStr,
            extra
        )
    end

    return table.concat(lines, "\n")
end

--- Resolves a human-readable name for a saved override key ("style_N",
--- "outfit_N", or "costume_N"), independent of whether LibArmorInsulation's
--- own data tables recognize that ID -- armor style names come from the
--- game's own GetItemStyleName/StyleNameById map (built for every valid
--- style ID, not just ones with a curated data entry), and outfit/costume
--- names come from GetCollectibleName, which likewise resolves any valid
--- collectible ID regardless of data-table recognition. Mirrors how the
--- Current Insulation display above resolves names.
--- Returns nil if the key doesn't parse or the game can't name that ID.
local function ResolveOverrideName(key)
    local styleId = key:match("^style_(%d+)$")
    if styleId then
        return LibArmorInsulation.Data.StyleNameById[tonumber(styleId)]
    end
    local collectibleId = key:match("^outfit_(%d+)$") or key:match("^costume_(%d+)$")
    if collectibleId then
        return GetCollectibleName and GetCollectibleName(tonumber(collectibleId))
    end
    return nil
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Override editor state
-- ─────────────────────────────────────────────────────────────────────────────
-- The override UI lets the user enter a style/outfit/costume ID and pick a
-- tier from the dropdown. Stored as Settings.sv.overrides[key] = tierValue.

local pendingStyleId      = 0
local pendingTierChoice   = CLEAR_CHOICE
local pendingOverrideType = "Armor style"

-- Maps an override idType ("style"/"outfit"/"costume") to its matching
-- "Override type" dropdown choice string.
local idTypeToOverrideTypeChoice = {
    style   = "Armor style",
    outfit  = "Outfit collectible",
    costume = "Costume",
}

-- ─────────────────────────────────────────────────────────────────────────────
-- "Prefill from" Layer / Slot dropdowns
-- ─────────────────────────────────────────────────────────────────────────────
-- A previous version of this UI tried to auto-detect "whatever's currently
-- winning" into a single pre-built list, refreshed via a background poll.
-- That didn't reliably work: LAM re-reads a control's displayed VALUE (via
-- getFunc) whenever the panel refreshes, but a dropdown's CHOICES are baked
-- in at registration time and don't live-update just because the underlying
-- list changed — the choices only change once something explicitly
-- re-registers the whole options table.
--
-- This version sidesteps that entirely: the LAYER ("Costume / Polymorph",
-- "Outfit", "Armor") and SLOT ("Head", "Chest", ...) dropdowns are fixed,
-- static lists that never need to change. Picking either one does a FRESH
-- live lookup right then (via Calc.ResolveCostumeOrPolymorph /
-- Calc.ResolveOutfitSlot / Calc.ResolveArmorSlot in the Calculator module —
-- each independent of ESO's visual precedence, so e.g. picking "Armor" still
-- shows your real worn armor style even while a costume is currently
-- displayed instead) and copies the result into the Override Type/ID/Tier
-- fields below. If that layer/slot has nothing active right now (e.g. no
-- costume equipped, or an empty outfit slot), a placeholder tier and a
-- explanatory note are shown instead, so there's always something sensible
-- to look at and, if desired, manually adjust an ID for.

local LAYER_CHOICES = { "Costume / Polymorph", "Outfit", "Armor" }
local SLOT_CHOICES  = { "Head", "Shoulders", "Chest", "Hands", "Waist", "Legs", "Feet" }

-- Slot display label -> canonical slot key ("head", "chest", ...) used by
-- LibArmorInsulation.Data.EquipSlotByKey/OutfitSlotByKey and by
-- Calc.ResolveOutfitSlot()/Calc.ResolveArmorSlot().
local slotChoiceToKey = {
    Head = "head", Shoulders = "shoulders", Chest = "chest", Hands = "hands",
    Waist = "waist", Legs = "legs", Feet = "feet",
}

local pendingLayer = "Armor"
local pendingSlot  = "Chest"

-- Looks up live data for the CURRENT Layer/Slot selection — a fresh call to
-- the Calculator every time, never a cached/pre-built list — and normalises
-- whichever resolver answered into a common shape.
local function ResolveCurrentSelection()
    local Calc      = LibArmorInsulation.Calc
    local overrides = Settings.sv and Settings.sv.overrides or nil

    if pendingLayer == "Costume / Polymorph" then
        local info = Calc.ResolveCostumeOrPolymorph(overrides)
        return {
            active = info.active, idType = "costume",
            id = info.collectibleId, name = info.collectibleName,
            tier = info.tier, note = info.note,
        }
    end

    local slotKey = slotChoiceToKey[pendingSlot] or "chest"

    if pendingLayer == "Outfit" then
        local info = Calc.ResolveOutfitSlot(slotKey, overrides)
        return {
            active = info.active, idType = "outfit",
            id = info.collectibleId, name = info.name,
            tier = info.tier, note = info.note,
        }
    end

    -- Armor
    local info = Calc.ResolveArmorSlot(slotKey, overrides)
    return {
        active = info.active, idType = "style",
        id = info.styleId, name = info.styleName,
        tier = info.tier, note = info.note,
    }
end

-- Copies the current Layer/Slot selection's live data into the Override
-- Type / ID / Tier fields. Called immediately whenever Layer or Slot
-- changes, and again from the "Refresh Preview" button for when the SAME
-- layer/slot's underlying gear changed without touching either dropdown.
local function ApplyCurrentSelectionToFields()
    local sel = ResolveCurrentSelection()
    pendingOverrideType = idTypeToOverrideTypeChoice[sel.idType] or pendingOverrideType
    if sel.active and sel.id then
        pendingStyleId = sel.id
    else
        -- Placeholder case — there's no real ID to prefill, so leave it at 0
        -- and let the user type one in (e.g. from /costumeids, /outfitids,
        -- /styleids) if they want to override something not currently worn.
        pendingStyleId = 0
    end
    pendingTierChoice = (sel.tier and tierValueToChoice[sel.tier]) or pendingTierChoice
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Register the panel with LAM
-- ─────────────────────────────────────────────────────────────────────────────
function Settings.Initialize(sv)
    Settings.sv = sv

    local LAM = LibAddonMenu2
    if not LAM then
        -- LAM failed to load; settings panel will not be available.
        -- The library itself still functions.
        return
    end

    -- Panel descriptor
    local panelData = {
        type            = "panel",
        name            = "LibArmorInsulation",
        displayName     = "|cFFD700LibArmorInsulation|r",
        author          = "@Kreksar5 and Claude.ai",
        version         = LibArmorInsulation.VERSION,
        website         = "",
        keywords        = "insulation armor temperature style",
        registerForDefaults  = false,
        registerForRefresh   = true,
    }

    LAM:RegisterAddonPanel(Settings.panelId, panelData)

    -- Prefill the Override Type/ID/Tier fields from the default Layer/Slot
    -- selection (Armor — Chest) before the controls below are constructed,
    -- so they show real, live data the very first time the panel opens.
    ApplyCurrentSelectionToFields()

    -- ── Options table ────────────────────────────────────────────────────────
    -- LAM control types used here:
    --   "description" – read-only text block
    --   "button"      – clickable button
    --   "editbox"     – text/number input
    --   "header"      – section divider
    -- All are confirmed LAM-2.0 control types.
    -- Ref: https://github.com/sirinsidiator/ESO-LibAddonMenu/wiki

    -- IMPORTANT: `optionsTable` must be declared on its own line BEFORE the
    -- table constructor below, not as `local optionsTable = { ... }`. Lua's
    -- scoping rule is that a local variable's scope begins only AFTER its
    -- declaration statement finishes — so any closure written INSIDE the
    -- table constructor that refers to `optionsTable` (e.g. the Refresh/
    -- Apply Override/Reset buttons calling
    -- `LAM:RegisterOptionControls(Settings.panelId, optionsTable)`) would
    -- resolve to a global of that name (nil) rather than this local, and
    -- every one of those calls would silently pass nil. This was a genuine
    -- pre-existing bug (present since before the tier-system rewrite) and is
    -- almost certainly the real reason Settings-panel refreshes weren't
    -- taking effect. Forward-declaring the local first, then assigning the
    -- table to it in a separate statement, makes the closures correctly
    -- capture this same local as an upvalue.
    local optionsTable
    optionsTable = {

        -- ── Section 1: Current Insulation Display ───────────────────────────
        {
            type = "header",
            name = "Current Insulation",
        },
        {
            type    = "description",
            name    = "",
            text    = function()
                return BuildCurrentInsulationLabel()
            end,
        },
        {
            type    = "button",
            name    = "Refresh",
            tooltip = "Re-calculate insulation from your current equipment, and re-check the Layer/Slot preview below.",
            func    = function()
                -- LAM description controls re-evaluate their text function when
                -- the panel is re-opened or when RegisterForRefresh fires, so
                -- BuildCurrentInsulationLabel() above updates on its own; this
                -- also re-syncs the Override Type/ID/Tier fields to whatever
                -- the current Layer/Slot selection resolves to right now.
                ApplyCurrentSelectionToFields()
                LAM:RegisterOptionControls(Settings.panelId, optionsTable)
            end,
        },

        -- ── Section 2: Override Editor ──────────────────────────────────────
        {
            type = "header",
            name = "Manual Overrides",
        },
        {
            type = "description",
            name = "",
            text = "Override the insulation tier of any armor style, outfit piece, or costume/polymorph.\n\n" ..
                   "ARMOR STYLE: enter ITEM_STYLE_* id — use /styleids for your current armor.\n" ..
                   "OUTFIT: enter collectible ID — use /outfitids for your current outfit.\n" ..
                   "COSTUME: enter collectible ID — use /costumeids for the active costume (also used for polymorphs).\n\n" ..
                   "For armor styles and outfit pieces, the tier you pick is a FULL-BODY reference " ..
                   "value — the actual insulation contributed by a single slot (helmet, gloves, etc.) " ..
                   "is calculated from it based on how much of the body that slot covers. A full " ..
                   "matching set reproduces the chosen tier exactly as your total.\n\n" ..
                   "For costumes/polymorphs the tier IS the total, unadjusted, since they cover the " ..
                   "whole body at once.\n\n" ..
                   "|cFFD700── TIER LADDER ──|r\n" ..
                   "  |c0D47A1 -10|r  Magically Cooled — refrigeration-grade enchantment\n" ..
                   "  |c1976D2   0|r  No Insulation\n" ..
                   "  |c42A5F5  10|r  Minimal — underwear/swimwear\n" ..
                   "  |c90CAF9  20|r  Light — silks, thin fabrics, minimal coverage\n" ..
                   "  |cBBDEFB  30|r  Coarse Light — linens, coarser fabrics, light leather\n" ..
                   "  |cE3F2FD  40|r  Layered/Leather — thick/many-layered fabrics, majority leather\n" ..
                   "  |cFFFFFF  50|r  ← NEUTRAL — full leather, mild metal, thick layered fabric\n" ..
                   "  |cFFE0B2  60|r  Heavy Leather/Fur — heavy leather, mild fur, moderate metal\n" ..
                   "  |cFFB74D  70|r  Full Fur/Metal — full coverage fur or metal\n" ..
                   "  |cFB8C00  80|r  Heavy Fur/Metal — full coverage heavy fur and/or metal\n" ..
                   "  |cE65100  90|r  Magically Heated — enchanted heat-generating equipment\n",
        },
        {
            type    = "dropdown",
            name    = "Layer",
            tooltip = "Which layer to pull live data from: the active Costume/Polymorph (whole body, " ..
                      "no slot), your equipped Outfit (per slot), or your worn Armor (per slot) — " ..
                      "regardless of which one is currently visible on your character.",
            choices = LAYER_CHOICES,
            getFunc = function() return pendingLayer end,
            setFunc = function(value)
                pendingLayer = value
                ApplyCurrentSelectionToFields()
            end,
        },
        {
            type     = "dropdown",
            name     = "Slot",
            tooltip  = "Which body slot to look up. Ignored for Costume/Polymorph, which is whole-body.",
            choices  = SLOT_CHOICES,
            disabled = function() return pendingLayer == "Costume / Polymorph" end,
            getFunc  = function() return pendingSlot end,
            setFunc  = function(value)
                pendingSlot = value
                ApplyCurrentSelectionToFields()
            end,
        },
        {
            type = "description",
            name = "",
            text = function()
                local sel = ResolveCurrentSelection()
                if sel.active then
                    local idStr = sel.id and string.format("  (id %d)", sel.id) or ""
                    return string.format(
                        "Currently: %s%s  →  tier %d (%s)",
                        sel.name or "Unknown", idStr,
                        sel.tier, LibArmorInsulation.Calc.GetTierLabel(sel.tier)
                    )
                end
                return string.format(
                    "%s Override Type/ID/Tier below have been set to a placeholder (tier %d, %s) " ..
                    "— enter an ID manually (see /costumeids, /outfitids, /styleids) if you want to " ..
                    "override something not currently worn/active.",
                    sel.note or "Nothing active for this layer/slot.",
                    sel.tier, LibArmorInsulation.Calc.GetTierLabel(sel.tier)
                )
            end,
        },
        {
            type    = "button",
            name    = "Refresh Preview",
            tooltip = "Re-check the current Layer/Slot selection's live data and re-fill the fields " ..
                      "below — use this if you changed gear without touching the Layer/Slot dropdowns.",
            func    = function()
                ApplyCurrentSelectionToFields()
            end,
        },
        {
            type    = "dropdown",
            name    = "Override type",
            tooltip = "Whether the ID below refers to an armor style, an outfit collectible, or a costume/polymorph.",
            choices = { "Armor style", "Outfit collectible", "Costume" },
            getFunc = function() return pendingOverrideType end,
            setFunc = function(value) pendingOverrideType = value end,
        },
        {
            type         = "editbox",
            name         = "Style / Collectible ID",
            tooltip      = "Numeric ID. For armor: ITEM_STYLE_* integer (use /styleids). For outfit: collectible ID (use /outfitids). For costume/polymorph: collectible ID (use /costumeids).",
            getFunc      = function() return tostring(pendingStyleId) end,
            setFunc      = function(value)
                local n = tonumber(value)
                pendingStyleId = n and math.floor(n) or 0
            end,
            isMultiline  = false,
            maxChars     = 8,
        },
        {
            type    = "dropdown",
            name    = "Insulation tier",
            tooltip = "Pick the tier to assign this ID. \"(no override)\" clears an existing override for this ID.",
            choices = TIER_CHOICES,
            getFunc = function() return pendingTierChoice end,
            setFunc = function(value) pendingTierChoice = value end,
        },
        {
            type    = "button",
            name    = "Apply Override",
            tooltip = "Save the chosen tier for the entered ID.",
            func    = function()
                if not pendingStyleId or pendingStyleId == 0 then
                    CHAT_SYSTEM:AddMessage("|cFFD700LibArmorInsulation:|r Enter a valid ID first.")
                    return
                end
                if Settings.sv.overrides == nil then Settings.sv.overrides = {} end
                local key
                if pendingOverrideType == "Outfit collectible" then
                    key = "outfit_" .. tostring(pendingStyleId)
                elseif pendingOverrideType == "Costume" then
                    key = "costume_" .. tostring(pendingStyleId)
                else
                    key = "style_" .. tostring(pendingStyleId)
                end
                if pendingTierChoice == CLEAR_CHOICE then
                    Settings.sv.overrides[key] = nil
                    CHAT_SYSTEM:AddMessage(string.format(
                        "|cFFD700LibArmorInsulation:|r Override removed for %s.", key
                    ))
                else
                    local tierValue = choiceToTierValue[pendingTierChoice]
                    Settings.sv.overrides[key] = tierValue
                    CHAT_SYSTEM:AddMessage(string.format(
                        "|cFFD700LibArmorInsulation:|r Override set: %s → tier %d (%s)",
                        key, tierValue, LibArmorInsulation.Calc.GetTierLabel(tierValue)
                    ))
                end
                -- Re-check the preview so the description above reflects the
                -- override that was just applied/removed immediately.
                ApplyCurrentSelectionToFields()
                LAM:RegisterOptionControls(Settings.panelId, optionsTable)
            end,
        },

        -- ── Section 3: List Current Overrides ───────────────────────────────
        {
            type = "header",
            name = "Active Overrides",
        },
        {
            type  = "description",
            name  = "",
            text  = function()
                if not Settings.sv or not Settings.sv.overrides then
                    return "No overrides set."
                end
                local lines = {}
                for key, value in pairs(Settings.sv.overrides) do
                    local resolvedName = ResolveOverrideName(key)
                    local nameSuffix = resolvedName and (" (" .. resolvedName .. ")") or ""
                    lines[#lines + 1] = string.format(
                        "  %s%s → tier %d (%s)",
                        key, nameSuffix, value, LibArmorInsulation.Calc.GetTierLabel(value)
                    )
                end
                if #lines == 0 then
                    return "No overrides set."
                end
                return table.concat(lines, "\n")
            end,
        },

        -- ── Section 4: Reset ─────────────────────────────────────────────────
        {
            type = "header",
            name = "Reset",
        },
        {
            type    = "button",
            name    = "Reset All Overrides",
            tooltip = "Remove every manual override and return to database defaults.",
            func    = function()
                if Settings.sv then
                    Settings.sv.overrides = {}
                    CHAT_SYSTEM:AddMessage("|cFFD700LibArmorInsulation:|r All overrides have been reset.")
                    ApplyCurrentSelectionToFields()
                    LAM:RegisterOptionControls(Settings.panelId, optionsTable)
                end
            end,
            warning = "This will remove ALL your custom insulation overrides. This cannot be undone.",
        },

    }

    LAM:RegisterOptionControls(Settings.panelId, optionsTable)
end
