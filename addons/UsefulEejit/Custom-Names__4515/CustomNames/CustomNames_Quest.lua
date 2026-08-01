-- CustomNames_Quest.lua
-- Adjusts the focused quest tracker panel:
--   1. Moves it higher on screen (less NPC-face blocking)
--   2. Uses a slightly smaller font for tracker text
--
-- HOW THE TRACKER IS POSITIONED (from source):
--   ZO_EndDunHUDTracker (keyboard) is anchored:
--     TOPLEFT  → GuiRoot TOPRIGHT, offset (-230, 90)
--     TOPRIGHT → GuiRoot,          offset (0,   90)
--   ZO_FocusedQuestTrackerPanel hangs off its BOTTOMRIGHT.
--
--   We detach the quest panel from ZO_EndDunHUDTracker and anchor it
--   directly to GuiRoot TOPRIGHT with a smaller Y offset, so it sits
--   higher while the EndDun tracker (Endless Dungeon buff bar) remains
--   in its own place.
--
-- FONT:
--   ZoFontGameShadow = Bold 18pt with soft-shadow (the default).
--   We use the same typeface at 15pt, keeping the shadow style so text
--   remains readable against any background.

local CN = CustomNames

-- How far down from the top of the screen the quest tracker starts.
-- Default behaviour puts it at ~90px + EndDun tracker height (~30px).
-- 55 puts it roughly level with the top of the minimap compass area.
local QUEST_TRACKER_OFFSET_Y = 55

-- Font string used for all three keyboard tracker labels (header,
-- condition, subcategory). Must be a valid ESO font descriptor.
-- Format: "face|size|style"  — we keep the same bold face and shadow.
local QUEST_TRACKER_FONT = "$(BOLD_FONT)|15|soft-shadow-thin"

------------------------------------------------------------------------
-- Reanchor the tracker panel
------------------------------------------------------------------------

local function RepositionQuestTracker()
    local panel = ZO_FocusedQuestTrackerPanel
    if not panel then return end

    panel:ClearAnchors()
    -- Keyboard: pin TOPRIGHT of panel to TOPRIGHT of screen
    panel:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, 0, QUEST_TRACKER_OFFSET_Y)
end

------------------------------------------------------------------------
-- Restyle fonts on all active tracker label controls
------------------------------------------------------------------------

local function ApplyFontToLabel(label)
    if label and label.SetFont then
        label:SetFont(QUEST_TRACKER_FONT)
    end
end

local function RestyleTrackerFonts()
    -- The tracker tree uses pooled label controls. Walk active children
    -- of the QuestContainer to reach every visible label.
    local panel = ZO_FocusedQuestTrackerPanel
    if not panel then return end

    local container = panel:GetNamedChild("ContainerQuestContainer")
    if not container then
        -- Try the nested path from the XML:
        -- ZO_FocusedQuestTrackerPanel → Container → QuestContainer
        local mid = panel:GetNamedChild("Container")
        if mid then container = mid:GetNamedChild("QuestContainer") end
    end

    if not container then return end

    local function walkLabels(ctrl)
        if not ctrl then return end
        if ctrl:GetType() == CT_LABEL then
            ApplyFontToLabel(ctrl)
        end
        for i = 1, ctrl:GetNumChildren() do
            walkLabels(ctrl:GetChild(i))
        end
    end

    walkLabels(container)
end

------------------------------------------------------------------------
-- Hook ZO_Tracker header/condition SetFont calls so pooled controls
-- that are created AFTER our init also get the smaller font.
-- The tracker calls control:SetFont(constants.FONT_HEADER) etc. directly
-- on each label when building tree nodes. We patch the KEYBOARD_CONSTANTS
-- table so every subsequent pool allocation uses our font.
------------------------------------------------------------------------

local function PatchTrackerConstants()
    -- KEYBOARD_CONSTANTS is a local inside questtracker.lua, not global.
    -- We can't reach it directly. Instead we hook ZO_Tracker's
    -- InitializeQuestHeader and the condition/subcategory setup functions
    -- by wrapping the methods on the singleton after it initialises.

    if not ZO_FocusedQuestTracker then return end
    local tracker = ZO_FocusedQuestTracker  -- the ZO_Tracker instance

    -- Wrap CreateQuestHeader to restyle the label after creation
    local origCreate = tracker.CreateQuestHeader
    if origCreate then
        tracker.CreateQuestHeader = function(self, ...)
            local header = origCreate(self, ...)
            ApplyFontToLabel(header)
            return header
        end
    end

    -- Wrap SetupConditionLabel (called for each condition row)
    local origSetupCond = tracker.SetupConditionLabel
    if origSetupCond then
        tracker.SetupConditionLabel = function(self, control, ...)
            origSetupCond(self, control, ...)
            ApplyFontToLabel(control)
        end
    end

    -- Wrap SetupSubcategoryLabel if it exists
    local origSetupSub = tracker.SetupSubcategoryLabel
    if origSetupSub then
        tracker.SetupSubcategoryLabel = function(self, control, ...)
            origSetupSub(self, control, ...)
            ApplyFontToLabel(control)
        end
    end
end

------------------------------------------------------------------------
-- Init
------------------------------------------------------------------------

function CN.InitQuest()
    -- The quest tracker initialises during EVENT_ADD_ON_LOADED (it
    -- registers for that event internally). We wait for PLAYER_ACTIVATED
    -- which fires after all UI is built and the tracker is fully up.
    EVENT_MANAGER:RegisterForEvent(
        CN.ADDON_NAME .. "_QuestLayout",
        EVENT_PLAYER_ACTIVATED,
        function()
            RepositionQuestTracker()
            PatchTrackerConstants()
            RestyleTrackerFonts()
            -- Only need to run once
            EVENT_MANAGER:UnregisterForEvent(CN.ADDON_NAME .. "_QuestLayout", EVENT_PLAYER_ACTIVATED)
        end
    )
end
