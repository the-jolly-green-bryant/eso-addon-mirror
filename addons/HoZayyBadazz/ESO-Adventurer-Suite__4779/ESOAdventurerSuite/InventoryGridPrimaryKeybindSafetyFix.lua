-- ESO Adventurer Suite
-- v0.29.648 - Inventory PRIMARY keybind secure isolation.
-- Suite-created inventory cells must never register UI_SHORTCUT_PRIMARY on ESO's
-- global KEYBIND_STRIP. Outfit Styles uses the same protected PRIMARY path for
-- previewing styles, and sharing that descriptor can contaminate the secure call.

local EPC = ESOProgressionCoach
local G = rawget(_G, "EASInventoryGrid")
if not EPC or not G then return end

-- If an older in-session descriptor somehow exists, remove only the exact Suite
-- descriptor once during addon initialization. No scene/keybind-strip hooks are added.
if G.primaryKeybind029364 and KEYBIND_STRIP and type(KEYBIND_STRIP.RemoveKeybindButton) == "function" then
    pcall(KEYBIND_STRIP.RemoveKeybindButton, KEYBIND_STRIP, G.primaryKeybind029364)
end
G.primaryKeybind029364 = nil

-- Preserve hover tracking for tooltips/visuals, but never touch KEYBIND_STRIP.
function G:EnsurePrimaryKeybind029364()
    return nil
end

function G:SetHoveredCell(control)
    self.hoveredCell = control
end

function G:ClearHoveredCell(control)
    if control ~= nil and self.hoveredCell ~= control then return end
    self.hoveredCell = nil
end

-- Keep this helper for callers that inspect it, but it no longer creates or
-- registers a global PRIMARY action. Mouse/context-menu interaction stays native.
function G:GetPrimaryActionName(control)
    if not control then return "Select" end
    if self.quickslotAssignTarget and control.bagId ~= nil then return "Assign" end
    return "Actions"
end

EPC._inventoryPrimaryKeybindSecure029648 = true
