-- Common Works — LarvalTear build wheel and current-build display
--
-- A hold-to-open radial wheel of the character's LarvalTear builds, and a draggable
-- label naming the current one.
--
-- Read builds only on wheel open; refresh the label on pointer changes (HookLarvalTear).
-- Create nothing without LarvalTear.

CommonWorksUI = CommonWorksUI or {}
local CW = CommonWorksUI

local UI = CW.UI
local WM = WINDOW_MANAGER
local EM = EVENT_MANAGER

-- ZO_RadialMenu has no entry cap; 1-10 limits only its unused keybind display.
-- Widen the stock 300px wheel to keep fourteen slice centers ~100px apart.
-- Cancel takes one slice, leaving thirteen builds per page.
local MAX_SLICES = 14
local WHEEL_SIZE = 450
local SHEET_SIZE = MAX_SLICES - 1

-- A layer is addressed by its resolved name, not by the string id.
local WHEEL_LAYER = GetString(SI_KEYBINDINGS_LAYER_CW_LT_WHEEL)

-- One texture for every slice: LarvalTear builds carry no art of their own.
local SLICE_ICON = "EsoUI/Art/Inventory/inventory_tabIcon_armor_up.dds"
-- The last slice is always Cancel, so MAX_SLICES - 1 builds fit.
local CANCEL_ICON_UP   = "EsoUI/Art/HUD/radialIcon_cancel_up.dds"
local CANCEL_ICON_OVER = "EsoUI/Art/HUD/radialIcon_cancel_over.dds"

-- Tooltip dropper art tints well; the worn-slot silhouette is too dim.
-- Scale to 1.4x text height to offset its mostly empty 32px box.
local POISON_ICON = "EsoUI/Art/Tooltips/icon_poison.dds"
local POISON_SCALE = 1.4
local POISON_GAP = 4
local POISON_EVENT = "CommonWorks_LTPoisonIcon"

-- Inside the slice spacing, or neighbouring names overlap; longer ellipsises.
local ENTRY_LABEL_WIDTH = 120

-- Check LarvalTear entry points once; incompatible versions count as absent.
local function LT()
    local ltm = LarvalTearMod
    if type(ltm) ~= "table" then return nil end
    local store = ltm.Modules and ltm.Modules.BuildStore
    if type(store) ~= "table" then return nil end
    -- Validate every called method here so callers need no guards.
    if type(store.GetSelectedPageId) ~= "function"
        or type(store.GetRuntimeBuildEntriesForPage) ~= "function"
        or type(store.GetBuildById) ~= "function"
        or type(ltm.RunBuildById) ~= "function"
        or type(ltm.GetCurrentBuildCardState) ~= "function"
        or type(ltm.SetCurrentBuildCardState) ~= "function"
        or type(ltm.SyncSelectedBuildCardState) ~= "function" then return nil end
    return ltm, store
end

function CW.LarvalTearAvailable()
    return LT() ~= nil
end

local function DisplayEnabled()
    return CW.SavedVars.ltBuildDisplay
end

local function PoisonAlertEnabled()
    return CW.SavedVars.ltPoisonAlert
end

local function FontSize()
    return zo_clamp(CW.SavedVars.ltBuildFontSize, 14, 72)
end

-- UI.lua's equivalent helper is file-local there.
local function FontString(size)
    UI.RefreshFontChoices()
    local fonts = UI.FONTS
    local face = fonts[CW.SavedVars.ltBuildFontFace] or fonts[CW.defaults.ltBuildFontFace]
    return face .. "|" .. size .. "|soft-shadow-thick"
end

-- Its own range, well under the name's 14-72: these are captions, not a second headline.
local function SetsFontSize()
    return zo_clamp(CW.SavedVars.ltBuildSetsFontSize, 8, 14)
end

-- Every slot that can carry a set, both bars included.
local SET_SLOTS = {
    EQUIP_SLOT_HEAD, EQUIP_SLOT_NECK, EQUIP_SLOT_CHEST, EQUIP_SLOT_SHOULDERS,
    EQUIP_SLOT_MAIN_HAND, EQUIP_SLOT_OFF_HAND, EQUIP_SLOT_WAIST, EQUIP_SLOT_LEGS,
    EQUIP_SLOT_FEET, EQUIP_SLOT_RING1, EQUIP_SLOT_RING2, EQUIP_SLOT_HAND,
    EQUIP_SLOT_BACKUP_MAIN, EQUIP_SLOT_BACKUP_OFF,
}

-- Count both bars; GetItemLinkSetInfo counts only the active bar.
-- Two-handers count twice and leave the off hand empty; mythics (maxEquipped 1) need no count.
local function SetLines()
    local sets, order = {}, {}
    for _, slot in ipairs(SET_SLOTS) do
        local link = GetItemLink(BAG_WORN, slot)
        local hasSet, setName, _, _, maxEquipped, setId = GetItemLinkSetInfo(link, false)
        if hasSet then
            -- Merge perfected ids into the base set for one line per set;
            -- 0 means no perfected version, so retain the piece's own id and name.
            local baseId = GetItemSetUnperfectedSetId(setId)
            if baseId > 0 then
                setId, setName = baseId, GetItemSetName(baseId)
            end
            local e = sets[setId]
            if not e then
                e = { n = 0, max = maxEquipped, name = zo_strformat("<<C:1>>", setName) }
                sets[setId] = e
                order[#order + 1] = e
            end
            local _, _, _, equipType = GetItemLinkInfo(link)
            e.n = e.n + (equipType == EQUIP_TYPE_TWO_HAND and 2 or 1)
        end
    end
    -- Biggest bonus first, so the five-pieces head the list and a monster set tails it.
    table.sort(order, function(a, b)
        if a.n ~= b.n then return a.n > b.n end
        return a.name < b.name
    end)

    local mythic, lines = nil, {}
    for _, e in ipairs(order) do
        if e.max == 1 then
            mythic = e.name
        else
            lines[#lines + 1] = zo_strformat(CW.L.LT_SET_LINE, e.n, e.name)
        end
    end
    if mythic then table.insert(lines, 1, mythic) end
    return table.concat(lines, "\n")
end

local display, label, setsLabel, poisonIcon
local currentName
local placementRequested = false

-- Warn about missing poison only for builds named as PvP.
local function ApplyPoisonIcon()
    if HasItemInSlot(BAG_WORN, EQUIP_SLOT_POISON) or HasItemInSlot(BAG_WORN, EQUIP_SLOT_BACKUP_POISON) then
        poisonIcon:SetColor(unpack(CW.SavedVars.ltBuildColor))
        poisonIcon:SetHidden(false)
    elseif currentName and currentName:lower():find("pvp", 1, true) then
        poisonIcon:SetColor(0.90, 0.20, 0.20, 1)
        poisonIcon:SetHidden(false)
    else
        poisonIcon:SetHidden(true)
    end
end

-- Size the drag target to the name only; set lines hang below it.
-- Including them shifts the name around its saved anchor (center by default) on gear or scene changes,
-- since GetTextHeight returns 0 for hidden labels.
local function Resize()
    ApplyPoisonIcon()
    local shown = not poisonIcon:IsHidden()
    local size = zo_round(FontSize() * POISON_SCALE)
    local iw = shown and size + POISON_GAP or 0
    local w = math.max(label:GetTextWidth() + iw, 40)
    local h = math.max(label:GetTextHeight(), FontSize() + 4, shown and size or 0)
    poisonIcon:SetDimensions(size, size)
    -- Centred together, so the label slides left by half the icon as it appears
    -- rather than the whole box jumping.
    label:SetAnchor(CENTER, display, CENTER, -iw / 2, 0)
    display:SetDimensions(w + 8, h + 4)
end

local function BuildDisplay()
    if display then return end

    display = WM:CreateTopLevelWindow("CW_LTBuild")
    display:SetClampedToScreen(false)
    display:SetDrawLayer(DL_OVERLAY)
    display:SetMouseEnabled(false)
    display:SetMovable(false)
    display:SetHidden(true)
    display:SetHandler("OnMoveStart", function(self) self:SetClampedToScreen(true) end)
    display:SetHandler("OnMoveStop", function(self)
        UI.SaveLarvalTearBuildPosition()
        self:SetClampedToScreen(false)
    end)

    label = WM:CreateControl("CW_LTBuildLabel", display, CT_LABEL)
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    label:SetDrawLevel(3)

    setsLabel = WM:CreateControl("CW_LTBuildSets", display, CT_LABEL)
    setsLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    setsLabel:SetVerticalAlignment(TEXT_ALIGN_TOP)
    setsLabel:SetMaxLineCount(0)        -- one line per set
    setsLabel:SetAnchor(TOP, label, BOTTOM, 0, 0)
    setsLabel:SetDrawLevel(3)
    setsLabel:SetHidden(true)

    poisonIcon = WM:CreateControl("CW_LTBuildPoison", display, CT_TEXTURE)
    poisonIcon:SetTexture(POISON_ICON)
    -- Edge-midpoint to edge-midpoint, so the icon stays centred on the text however
    -- tall either gets.
    poisonIcon:SetAnchor(LEFT, label, RIGHT, POISON_GAP, 0)
    poisonIcon:SetDrawLevel(3)
    poisonIcon:SetHidden(true)

    UI.ApplyLarvalTearBuildPosition()
end

function UI.ApplyLarvalTearBuildPosition()
    UI.ApplyWidgetPosition(display, "ltBuildPosition")
end

function UI.SaveLarvalTearBuildPosition()
    UI.SaveWidgetPosition(display, "ltBuildPosition")
end

function UI.ApplyLarvalTearBuildStyle()
    if not label then return end
    label:SetFont(FontString(FontSize()))
    label:SetColor(unpack(CW.SavedVars.ltBuildColor))
    setsLabel:SetFont(FontString(SetsFontSize()))
    setsLabel:SetColor(unpack(CW.SavedVars.ltBuildSetsColor))
    Resize()
end

-- Draggable whenever visible. CW.inGameplay follows the action bar,
-- so the label hides with the HUD in stores, skills and map scenes.
function UI.ApplyLarvalTearBuildVisibility()
    if not display then return end
    local enabled = DisplayEnabled()
    local placing = enabled and placementRequested and UI.SettingsPanelOpen()
    local showing = enabled and currentName ~= nil and CW.inGameplay

    -- SetText, never string.format: a build can be named anything, "50%" included.
    label:SetText(currentName or (placing and CW.L.LT_NO_BUILD or ""))

    -- Read off the worn bag, not the build: what is actually on beats what was applied.
    local sets = currentName and CW.SavedVars.ltBuildSets and SetLines() or ""
    setsLabel:SetText(sets)
    setsLabel:SetHidden(sets == "")
    Resize()

    local shown = showing or placing
    display:SetHidden(not shown)
    display:SetMouseEnabled(shown)
    display:SetMovable(shown)
end

function UI.SetLarvalTearBuildPlacementMode(on)
    placementRequested = on == true
    if display then UI.ApplyLarvalTearBuildVisibility() end
end
-- No tab: already movable whenever it is up, so placement mode has nothing to add.
CW.RegisterHudWidget(UI.SetLarvalTearBuildPlacementMode, UI.ApplyLarvalTearBuildVisibility)

-- A build carries no poison, so applying one leaves whichever bar you last poisoned.
local function PoisonText()
    local front = HasItemInSlot(BAG_WORN, EQUIP_SLOT_POISON)
    local back  = HasItemInSlot(BAG_WORN, EQUIP_SLOT_BACKUP_POISON)
    if front and back then return CW.L.LT_POISON_BOTH end
    if front then return CW.L.LT_POISON_FRONT end
    if back then return CW.L.LT_POISON_BACK end
    return CW.L.LT_POISON_NONE
end

-- All build-application paths hit these hooks, but loading does not; this means "just applied".
local function OnBuildApplied()
    if PoisonAlertEnabled() then UI.ShowPoisonAlert(PoisonText()) end
    CW.RefreshLarvalTearBuild()
end

-- LarvalTear falls back from its in-memory build to the saved selection after reload.
function CW.RefreshLarvalTearBuild()
    if not (display and DisplayEnabled()) then return end
    local ltm, store = LT()
    local name
    if ltm then
        local state = ltm:GetCurrentBuildCardState()
        local build = state and state.buildId and store:GetBuildById(state.buildId)
        name = build and build.displayName
    end
    currentName = name
    UI.ApplyLarvalTearBuildVisibility()
end

local controller, wheelFrame, sheetLabel
local sheet, sheetCount = 1, 1

local function Apply(buildId, pageId)
    local ltm = LT()
    if not ltm then return end
    -- RunBuildById does not update the current-build pointer;
    -- apply then sync, matching LarvalTear's keybind path.
    ltm:RunBuildById(buildId, function() CW.RefreshLarvalTearBuild() end,
        { pageId = pageId, source = "commonworks_wheel" })
    ltm:SetCurrentBuildCardState(buildId, pageId)
    ltm:SyncSelectedBuildCardState(buildId, pageId)
    CW.RefreshLarvalTearBuild()
end

local function Wheel()
    if controller then return controller end

    -- Full-screen: the menu anchors inside it and the sweep is measured from its centre.
    wheelFrame = WM:CreateTopLevelWindow("CW_LTWheel")
    wheelFrame:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    wheelFrame:SetDimensions(GuiRoot:GetWidth(), GuiRoot:GetHeight())
    -- Found by the controller as <parent name> .. "Menu".
    local menu = WM:CreateControlFromVirtual("CW_LTWheelMenu", wheelFrame, "ZO_RadialMenuTemplate")
    -- Entry positions, and so the gap between names, derive from these. The centre
    -- dead zone is 35% of the radius.
    menu:SetDimensions(WHEEL_SIZE, WHEEL_SIZE)
    menu:SetHidden(true)

    -- Stay below the template's centered Action label, within the dead zone.
    sheetLabel = WM:CreateControl("CW_LTWheelSheet", menu, CT_LABEL)
    sheetLabel:SetFont("ZoFontGameShadow")
    sheetLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    sheetLabel:SetAnchor(CENTER, menu, CENTER, 0, 100)
    sheetLabel:SetHidden(true)

    local cls = ZO_InteractiveRadialMenuController:Subclass()

    -- The stock third argument is an item-count badge; the template has no name label.
    -- Avoid the field `label`: ZO_RadialMenu re-anchors it on pooled controls' second layout.
    function cls:SetupEntryControl(entryControl, data)
        ZO_SetupSelectableItemRadialMenuEntryTemplate(entryControl, false)
        local lbl = entryControl.cwLabel
        if not lbl then
            lbl = WM:CreateControl(nil, entryControl, CT_LABEL)
            lbl:SetFont("ZoFontGameShadow")
            lbl:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
            lbl:SetVerticalAlignment(TEXT_ALIGN_TOP)
            lbl:SetDimensions(ENTRY_LABEL_WIDTH, 24)
            lbl:SetMaxLineCount(1)
            lbl:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)   -- truncate, never wrap
            lbl:SetInheritScale(false)
            lbl:SetAnchor(TOP, entryControl, BOTTOM, 0, 2)
            entryControl.cwLabel = lbl
        end
        lbl:SetText(data.displayName or "")
    end

    -- Read builds on every open to pick up changes without cache invalidation.
    function cls:PopulateMenu()
        local _, store = LT()
        if not store then return end
        local pageId = store:GetSelectedPageId()
        local entries = pageId and store:GetRuntimeBuildEntriesForPage(pageId)
        if not entries then return end

        sheetCount = zo_max(zo_ceil(#entries / SHEET_SIZE), 1)
        sheetLabel:SetText(string.format(CW.L.LT_WHEEL_SHEET, sheet, sheetCount))
        sheetLabel:SetHidden(sheetCount < 2)

        local first = (sheet - 1) * SHEET_SIZE + 1
        for i = first, zo_min(first + SHEET_SIZE - 1, #entries) do
            local e = entries[i]
            local buildId = e.buildId
            self.menu:AddEntry(e.displayName or buildId, SLICE_ICON, SLICE_ICON,
                function() Apply(buildId, e.pageId or pageId) end, e)
        end
        -- A nil callback closes ZO_RadialMenu without applying a build.
        local cancel = GetString(SI_RADIAL_MENU_CANCEL_BUTTON)
        self.menu:AddEntry(cancel, CANCEL_ICON_UP, CANCEL_ICON_OVER, nil,
            { displayName = cancel })
    end

    -- RadialMenu is the stock layer, blocking attack and block; ours carries the paging
    -- binds. ZO_RadialMenu pushes and removes both.
    controller = cls:New(wheelFrame, "ZO_SelectableItemRadialMenuEntryTemplate",
        "DefaultRadialMenuAnimation", "SelectableItemRadialMenuEntryAnimation",
        { "RadialMenu", WHEEL_LAYER })
    return controller
end

-- Release on Cancel, or inside the dead zone, to apply nothing.
function CW.LarvalTearWheelDown()
    if not CW.SavedVars.ltWheel then return end
    if not CW.LarvalTearAvailable() then return end
    sheet = 1
    Wheel():ShowMenu()
end

function CW.LarvalTearWheelUp()
    if controller then controller:StopInteraction() end
end

-- Return false to preserve camera zoom with nothing to page, including while the
-- closing animation still holds the layer. ResetData/Refresh repopulates the open menu;
-- ShowMenu would push the layers twice.
function CW.LarvalTearWheelPage(delta)
    if not (controller and controller:IsInteracting() and sheetCount > 1) then return false end
    sheet = (sheet - 1 + delta) % sheetCount + 1
    controller.menu:ResetData()
    controller:PopulateMenu()
    controller.menu:Refresh()   -- recentres the sweep, so paging never picks for you
    return true
end

-- LarvalTear has no callbacks; hook both pointer setters to cover window, keybinds and wheel.
local hooked = false

local function HookLarvalTear()
    if hooked then return end
    local ltm = LT()
    if not ltm then return end
    hooked = true
    for _, name in ipairs({ "SetCurrentBuildCardState", "SyncSelectedBuildCardState" }) do
        ZO_PostHook(ltm, name, OnBuildApplied)
    end
end

-- Poisons get used up and re-equipped between swaps. There is no slot filter.
local function OnWornSlot(_, _, slot)
    if slot == EQUIP_SLOT_POISON or slot == EQUIP_SLOT_BACKUP_POISON then Resize() end
end

local function WatchWornSlots(on)
    if not on then
        EM:UnregisterForEvent(POISON_EVENT, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
        return
    end
    EM:RegisterForEvent(POISON_EVENT, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnWornSlot)
    EM:AddFilterForEvent(POISON_EVENT, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN)
end

-- Called at load and again in-world, by which point the build store is populated.
function CW.UpdateLarvalTear()
    if not CW.LarvalTearAvailable() then return end

    -- Both features listen through the same hooks, so either alone earns them.
    if DisplayEnabled() or PoisonAlertEnabled() then HookLarvalTear() end
    WatchWornSlots(DisplayEnabled())

    if not DisplayEnabled() then
        if display then
            currentName = nil
            UI.ApplyLarvalTearBuildVisibility()
        end
        return
    end

    BuildDisplay()
    UI.ApplyLarvalTearBuildStyle()
    CW.RefreshLarvalTearBuild()
end
