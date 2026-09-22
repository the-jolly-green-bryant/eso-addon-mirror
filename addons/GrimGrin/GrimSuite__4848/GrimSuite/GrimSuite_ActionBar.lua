local GS = GrimSuite
GS.ActionBar = GS.ActionBar or {}
local ActionBar = GS.ActionBar

---------------------------------------------------------------------
-- GrimSuite Action Bar v1.2.1
--
-- Static two-row action bar:
--   * FRONT BAR is always the top row.
--   * BACK BAR is always the bottom row.
--   * Both rows are GrimSuite-owned visual displays.
--   * ESO's native action buttons remain present for actual input,
--     but their visual icon presentation is hidden to prevent ghosts.
--   * Weapon swapping changes the contents of the rows, never their
--     physical positions.
--   * Hotkeys and custom cooldown text are intentionally omitted.
---------------------------------------------------------------------

local WM = WINDOW_MANAGER
local EM = EVENT_MANAGER

local MIN_SLOT = 3
local MAX_SLOT = 7
local ULT_SLOT = 8
local SLOT_COUNT = 5
local HOTBAR_CATEGORIES = { HOTBAR_CATEGORY_PRIMARY, HOTBAR_CATEGORY_BACKUP }
local SLOT_SIZE = 65
local POTION_SIZE = 70
local SLOT_GAP = 3
local ROW_GAP = 3
local ULT_GAP = 10

local FRAME_EDGE = { 0.62, 0.62, 0.62, 0.88 }
local FRAME_EDGE_ACTIVE = { 0.62, 0.62, 0.62, 0.88 }
local FRAME_BG = { 0.008, 0.008, 0.008, 0.34 }
local FRAME_BG_ACTIVE = { 0.035, 0.035, 0.035, 0.50 }
local FRAME_EDGE_WIDTH = 2
local FRAME_EDGE_WIDTH_ACTIVE = 2
local INACTIVE_ALPHA = 0.72
local ACTIVE_ICON_ALPHA = 1.0
local UNUSABLE_ICON_ALPHA = 0.42
local UNUSABLE_DESATURATION = 0.65
local TIMER_FONT = "Univers 67|45|thick-outline"
local STACK_FONT = "Univers 67|45|thick-outline"
local TIMER_COLOR = { 1, 1, 1, 1 }
local STACK_COLOR = { 1, 1, 1, 1 }
local ULT_FONT = "Univers 67|35|thick-outline"
local ULT_COLOR = { 1, 1, 1, 1 }
local GLOW_COLOR = { 1.0, 0.78, 0.16, 0.92 }
local GLOW_EDGE_WIDTH = 8
local GLOW_OUTER_WIDTH = 12

local ROW_WIDTH = (SLOT_COUNT * SLOT_SIZE) + ((SLOT_COUNT - 1) * SLOT_GAP)
local TOTAL_WIDTH = ROW_WIDTH + ULT_GAP + SLOT_SIZE

ActionBar.enabled = true
ActionBar.staticBars = true
ActionBar.frontBarTop = true
ActionBar.showFrames = true
ActionBar.showCooldownText = true
ActionBar.showStackCount = true
-- GAB visual customization. Defaults intentionally match the current
-- GrimSuite look so existing users keep the same appearance.
ActionBar.iconSize = 65
ActionBar.slotGap = 3
ActionBar.rowGap = 3
ActionBar.backbarOpacity = 0.72
ActionBar.backbarDesaturation = 0.65
ActionBar.showUltimate = true
ActionBar.showQuickslot = true
ActionBar.showWeaponSwap = true
ActionBar.timerSize = 45
ActionBar.stackSize = 45
ActionBar.timerFont = "Univers 67"
ActionBar.stackFont = "Univers 67"
ActionBar.timerOutline = "thick-outline"
ActionBar.stackOutline = "thick-outline"
ActionBar.timerOffsetX = 0
ActionBar.timerOffsetY = 0
ActionBar.stackOffsetX = 0
ActionBar.stackOffsetY = 0
ActionBar.effectStacks = {}
ActionBar.bannerActive = false
ActionBar.initialized = false
ActionBar.frontRoot = nil
ActionBar.backbarRoot = nil
ActionBar.frontControls = {}
ActionBar.backbarControls = {}

-- LibAddonMenu configuration + saved layout position.
-- LibAddonMenu is a required dependency for GrimSuite's settings UI.
local POSITION_SV_NAME = "GrimSuiteActionBarSavedVars"
local POSITION_SV_VERSION = 1
local POSITION_DEFAULTS = {
    positionX = -38,
    positionY = -109,
    unlocked = false,
    iconSize = 65,
    slotGap = 3,
    rowGap = 3,
    backbarOpacity = 0.72,
    backbarDesaturation = 0.65,
    showUltimate = true,
    showQuickslot = true,
    showWeaponSwap = true,
    timerSize = 45,
    stackSize = 45,
    timerFont = "Univers 67",
    stackFont = "Univers 67",
    timerOutline = "thick-outline",
    stackOutline = "thick-outline",
    timerOffsetX = 0,
    timerOffsetY = 0,
    stackOffsetX = 0,
    stackOffsetY = 0,
}

local positionSV = nil
local LAM = nil
local dragState = {
    dragging = false,
    startMouseX = 0,
    startMouseY = 0,
    startX = 0,
    startY = 0,
}

local function GetIconSize()
    return math.max(40, math.min(100, tonumber(ActionBar.iconSize) or 65))
end

local function GetSlotGap()
    return math.max(0, math.min(20, tonumber(ActionBar.slotGap) or 3))
end

local function GetRowGap()
    return math.max(0, math.min(20, tonumber(ActionBar.rowGap) or 3))
end

local function GetBackbarOpacity()
    return math.max(0, math.min(1, tonumber(ActionBar.backbarOpacity) or 0.72))
end

local function GetBackbarDesaturation()
    return math.max(0, math.min(1, tonumber(ActionBar.backbarDesaturation) or 0.65))
end

local function GetRowWidth()
    local size = GetIconSize()
    local gap = GetSlotGap()
    return (SLOT_COUNT * size) + ((SLOT_COUNT - 1) * gap)
end

local function GetTotalWidth()
    return GetRowWidth() + ULT_GAP + GetIconSize()
end

-- ESO's SetFont() expects the actual font resource path rather than the
-- human-readable font name. Keep the names user-facing, but resolve them
-- to ESO's built-in font resources before building the SetFont string.
-- These resource paths are intentionally extensionless for current ESO font
-- handling.
local OVERLAY_FONT_PATHS = {
    -- Use ESO font macros here rather than raw file paths. Since Update 41,
    -- ESO's built-in fonts are rendered through the Slug system, and the
    -- macros resolve to the correct current font resource.
    ["Univers 57"] = "$(MEDIUM_FONT)",
    ["Univers 67"] = "$(BOLD_FONT)",
    ["ProseAntique"] = "$(ANTIQUE_FONT)",
    ["Trajan Pro"] = "$(STONE_TABLET_FONT)",
    ["Skyrim Handwritten"] = "$(HANDWRITTEN_FONT)",
    ["Futura Condensed Light"] = "$(GAMEPAD_LIGHT_FONT)",
    ["Futura Condensed"] = "$(GAMEPAD_MEDIUM_FONT)",
    ["Futura Condensed Bold"] = "$(GAMEPAD_BOLD_FONT)",
}


local function BuildOverlayFont(fontName, size, outline)
    fontName = tostring(fontName or "Univers 67")
    local fontPath = OVERLAY_FONT_PATHS[fontName] or OVERLAY_FONT_PATHS["Univers 67"]
    size = tonumber(size) or 45
    outline = tostring(outline or "thick-outline")
    return string.format("%s|%d|%s", fontPath, math.floor(size + 0.5), outline)
end

local function GetTimerFont()
    return BuildOverlayFont(ActionBar.timerFont, ActionBar.timerSize, ActionBar.timerOutline)
end

local function GetStackFont()
    return BuildOverlayFont(ActionBar.stackFont, ActionBar.stackSize, ActionBar.stackOutline)
end

local function ApplyOverlayTextStyles()
    local timerFont = GetTimerFont()
    local stackFont = GetStackFont()
    local timerX = tonumber(ActionBar.timerOffsetX) or 0
    local timerY = tonumber(ActionBar.timerOffsetY) or 0
    local stackX = tonumber(ActionBar.stackOffsetX) or 0
    local stackY = tonumber(ActionBar.stackOffsetY) or 0
    local roots = { ActionBar.frontControls, ActionBar.backbarControls }
    for _, controls in ipairs(roots) do
        for _, data in pairs(controls) do
            if data then
                if data.timer then
                    data.timer:SetFont(timerFont)
                    data.timer:ClearAnchors()
                    data.timer:SetAnchor(CENTER, data.frame, CENTER, timerX, timerY)
                end
                if data.stack then
                    data.stack:SetFont(stackFont)
                    data.stack:ClearAnchors()
                    data.stack:SetAnchor(CENTER, data.frame, CENTER, stackX, stackY)
                end
            end
        end
    end
end

-- Native controls that visually belong to the action bar.  We keep their
-- original screen positions as the reference and apply the same saved offset
-- used by GrimSuite's custom bars.
local nativeLayoutBase = {
    captured = false,
    weaponSwapLeft = nil,
    weaponSwapTop = nil,
    weaponSwapRight = nil,
}

local function MakeFrame(name, parent)
    local c = WM:CreateControl(name, parent, CT_BACKDROP)
    c:SetCenterColor(unpack(FRAME_BG))
    c:SetEdgeColor(unpack(FRAME_EDGE))
    c:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Border.dds", 16, 16, FRAME_EDGE_WIDTH, 0)
    c:SetDrawLevel(20)
    c:SetMouseEnabled(false)
    return c
end

local function GetButton(slot, category)
    local ok, button = pcall(ZO_ActionBar_GetButton, slot, category)
    if ok then return button end
    return nil
end

local function HideNativeVisuals(button)
    if not button then return end
    if button.buttonText then
        button.buttonText:SetHidden(true)
    end
    if button.icon then
        button.icon:SetAlpha(0)
    end
    if button.bg then
        button.bg:SetAlpha(0)
    end
    if button.slot then
        local backdrop = button.slot:GetNamedChild("Backdrop")
        if backdrop then backdrop:SetAlpha(0) end
        -- Keep the native slot alive for input, but make the entire native
        -- visual hierarchy transparent so ESO cannot leave ghost boxes/frames
        -- visible behind the GrimSuite display.
        button.slot:SetAlpha(0)
    end
end

local function GetAbilityForSlot(slot, category)
    local id = GetSlotBoundId(slot, category)
    if not id or id <= 0 then return 0 end

    -- Scribed skills return a craftedAbilityId (the Grimoire ID) from
    -- GetSlotBoundId(). Convert that to the real representative ability ID
    -- before asking ESO for the icon/name/effective ability.
    if GetSlotType(slot, category) == ACTION_TYPE_CRAFTED_ABILITY then
        local ok, realId = pcall(GetAbilityIdForCraftedAbilityId, id)
        if ok and realId and realId > 0 then
            id = realId
        end
    end

    local ok, effective = pcall(GetEffectiveAbilityIdForAbilityOnHotbar, id, category)
    if ok and effective and effective > 0 then
        id = effective
    end
    return id
end

local function CreateDisplayButton(root, x, key, prefix)
    local base = "GrimSuiteAB_" .. prefix .. "_" .. key
    local frame = MakeFrame(base .. "Frame", root)
    frame:SetDimensions(GetIconSize(), GetIconSize())
    frame:ClearAnchors()
    frame:SetAnchor(TOPLEFT, root, TOPLEFT, x, 0)

    local icon = WM:CreateControl(base .. "Icon", frame, CT_TEXTURE)
    icon:SetAnchor(TOPLEFT, frame, TOPLEFT, 2, 2)
    icon:SetAnchor(BOTTOMRIGHT, frame, BOTTOMRIGHT, -2, -2)
    icon:SetTextureCoords(0, 1, 0, 1)
    icon:SetDrawLevel(21)
    icon:SetMouseEnabled(false)

    local shade = WM:CreateControl(base .. "Shade", frame, CT_BACKDROP)
    shade:SetAnchorFill(icon)
    shade:SetCenterColor(0, 0, 0, 0.10)
    shade:SetEdgeColor(0, 0, 0, 0)
    shade:SetDrawLevel(22)
    shade:SetMouseEnabled(false)

    -- Short native-style "button pressed" feedback.  This is deliberately
    -- separate from the toggle/proc glow below: casting a skill briefly
    -- darkens/presses the custom button, then returns to its normal state.
    local pressed = WM:CreateControl(base .. "Pressed", frame, CT_BACKDROP)
    pressed:ClearAnchors()
    pressed:SetAnchor(TOPLEFT, frame, TOPLEFT, 2, 2)
    pressed:SetAnchor(BOTTOMRIGHT, frame, BOTTOMRIGHT, -2, -2)
    pressed:SetCenterColor(0, 0, 0, 0.28)
    pressed:SetEdgeColor(1, 1, 1, 0.22)
    pressed:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Border.dds", 16, 16, 2, 0)
    pressed:SetDrawLevel(27)
    pressed:SetHidden(true)
    pressed:SetMouseEnabled(false)

    -- Bright FAB-style state glow. ESO already provides the exact
    -- action-slot highlight texture FAB uses for toggled skills. Reuse it
    -- here so active toggles and ready ultimates have a very obvious
    -- luminous border instead of a subtle backdrop edge.
    local outerGlow = WM:CreateControl(base .. "OuterGlow", frame, CT_TEXTURE)
    outerGlow:ClearAnchors()
    outerGlow:SetAnchor(TOPLEFT, frame, TOPLEFT, 0, 0)
    outerGlow:SetAnchor(BOTTOMRIGHT, frame, BOTTOMRIGHT, 0, 0)
    outerGlow:SetTexture("EsoUI/Art/ActionBar/ActionSlot_toggledon.dds")
    outerGlow:SetTextureCoords(0, 1, 0, 1)
    outerGlow:SetColor(0.15, 0.85, 1.0, 0.50)
    outerGlow:SetDrawLevel(22)
    outerGlow:SetHidden(true)
    outerGlow:SetMouseEnabled(false)

    local glow = WM:CreateControl(base .. "Glow", frame, CT_TEXTURE)
    glow:ClearAnchors()
    glow:SetAnchor(TOPLEFT, frame, TOPLEFT, 0, 0)
    glow:SetAnchor(BOTTOMRIGHT, frame, BOTTOMRIGHT, 0, 0)
    glow:SetTexture("EsoUI/Art/ActionBar/ActionSlot_toggledon.dds")
    glow:SetTextureCoords(0, 1, 0, 1)
    glow:SetColor(0.20, 0.92, 1.0, 1.0)
    glow:SetDrawLevel(23)
    glow:SetHidden(true)
    glow:SetMouseEnabled(false)

    local timer = WM:CreateControl(base .. "Timer", frame, CT_LABEL)
    timer:SetFont(GetTimerFont())
    timer:SetAnchor(CENTER, frame, CENTER, tonumber(ActionBar.timerOffsetX) or 0, tonumber(ActionBar.timerOffsetY) or 0)
    timer:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    timer:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    timer:SetColor(unpack(TIMER_COLOR))
    timer:SetDrawLevel(24)
    timer:SetText("")
    timer:SetMouseEnabled(false)

    local stack = WM:CreateControl(base .. "Stack", frame, CT_LABEL)
    stack:SetFont(GetStackFont())
    stack:SetAnchor(CENTER, frame, CENTER, tonumber(ActionBar.stackOffsetX) or 0, tonumber(ActionBar.stackOffsetY) or 0)
    stack:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    stack:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    stack:SetColor(unpack(STACK_COLOR))
    stack:SetDrawLevel(25)
    stack:SetText("")
    stack:SetMouseEnabled(false)

    local ultValue = nil
    if key == "Ult" then
        ultValue = WM:CreateControl(base .. "UltValue", frame, CT_LABEL)
        ultValue:SetFont(ULT_FONT)
        ultValue:SetAnchor(CENTER, frame, TOP, 0, -15)
        ultValue:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        ultValue:SetVerticalAlignment(TEXT_ALIGN_BOTTOM)
        ultValue:SetColor(unpack(ULT_COLOR))
        ultValue:SetDrawLevel(26)
        ultValue:SetText("")
        ultValue:SetMouseEnabled(false)
    end

    return { frame = frame, icon = icon, shade = shade, pressed = pressed, glow = glow, outerGlow = outerGlow, timer = timer, stack = stack, ultValue = ultValue }
end

local function CreateRow(rootName, controls, prefix)
    local root = WM:CreateTopLevelWindow(rootName)
    root:SetDimensions(GetTotalWidth(), GetIconSize())
    root:SetMouseEnabled(false)
    root:SetMovable(false)
    root:SetClampedToScreen(true)
    root:SetDrawTier(DT_LOW)

    for i = MIN_SLOT, MAX_SLOT do
        local x = (i - MIN_SLOT) * (GetIconSize() + GetSlotGap())
        controls[i] = CreateDisplayButton(root, x, tostring(i), prefix)
    end

    controls[ULT_SLOT] = CreateDisplayButton(root, GetRowWidth() + ULT_GAP, "Ult", prefix)
    return root
end

local InstallDragHandlers

function ActionBar:CreateRows()
    if not self.frontRoot then
        self.frontRoot = CreateRow("GrimSuiteAB_FrontRoot", self.frontControls, "Front")
    end
    if not self.backbarRoot then
        self.backbarRoot = CreateRow("GrimSuiteAB_BackRoot", self.backbarControls, "Back")
    end

    -- Install the drag handlers after the roots actually exist.  The local
    -- function is defined later in the file, but CreateRows() is only called
    -- after the addon has finished loading.
    if InstallDragHandlers then
        InstallDragHandlers()
    end
end

local function StyleDisplay(data, active, hasAbility, usable)
    if not data then return end
    data.frame:SetHidden(not ActionBar.showFrames)
    if data.glow then
        data.glow:SetHidden(true)
    end
    if data.outerGlow then
        data.outerGlow:SetHidden(true)
    end

    if active then
        data.frame:SetCenterColor(unpack(FRAME_BG_ACTIVE))
        data.frame:SetEdgeColor(unpack(FRAME_EDGE_ACTIVE))
        data.frame:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Border.dds", 16, 16, FRAME_EDGE_WIDTH_ACTIVE, 0)
        if usable == false then
            data.icon:SetAlpha(UNUSABLE_ICON_ALPHA)
            data.icon:SetDesaturation(UNUSABLE_DESATURATION)
        else
            data.icon:SetAlpha(ACTIVE_ICON_ALPHA)
            data.icon:SetDesaturation(0)
        end
    else
        data.frame:SetCenterColor(unpack(FRAME_BG))
        data.frame:SetEdgeColor(unpack(FRAME_EDGE))
        data.frame:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Border.dds", 16, 16, FRAME_EDGE_WIDTH, 0)
        data.icon:SetAlpha(GetBackbarOpacity())
        -- Inactive rows stay desaturated at all times, including the backbar.
        -- This is a visual state of the row, not ESO usability state.
        data.icon:SetDesaturation(GetBackbarDesaturation())
    end

    if not hasAbility then
        data.timer:SetText("")
        data.stack:SetText("")
    end

    if hasAbility then
        data.icon:SetHidden(false)
        data.shade:SetHidden(false)
    else
        data.icon:SetTexture("")
        data.icon:SetHidden(true)
        data.shade:SetHidden(true)
    end
end

function ActionBar:UpdateNativeVisualSuppression()
    -- Keep ESO's controls alive for keyboard/mouse/gamepad input, but remove
    -- their visible icon/background so they cannot appear as ghost bars.
    for _, category in ipairs(HOTBAR_CATEGORIES) do
        for i = MIN_SLOT, ULT_SLOT do
            local button = GetButton(i, category)
            if button then HideNativeVisuals(button) end
        end
    end
end

local function GetNativeActionBarControls()
    local actionBar = GetControl("ZO_ActionBar1")
    if not actionBar then return nil, nil end

    local weaponSwap = actionBar:GetNamedChild("WeaponSwap")
    local potion = actionBar:GetNamedChild("PotionSlot")

    -- Be a little defensive about UI naming changes.
    if not potion then
        potion = actionBar:GetNamedChild("Potion")
    end
    if not potion then
        potion = actionBar:GetNamedChild("Quickslot")
    end
    if not potion then
        -- Current ESO uses QuickslotButton for the visible potion/quickslot
        -- control.  It may be exposed as a direct child or as a global control
        -- depending on the current UI layout.
        potion = actionBar:GetNamedChild("QuickslotButton")
    end
    if not potion then
        potion = GetControl("QuickslotButton")
    end

    return weaponSwap, potion
end

local function CaptureNativeLayoutBase()
    if nativeLayoutBase.captured then return true end

    local weaponSwap, potion = GetNativeActionBarControls()
    if not weaponSwap then return false end

    nativeLayoutBase.weaponSwapLeft = weaponSwap:GetLeft()
    nativeLayoutBase.weaponSwapTop = weaponSwap:GetTop()
    nativeLayoutBase.weaponSwapRight = weaponSwap:GetRight()

    nativeLayoutBase.captured = true
    return true
end

local function ApplyNativeLayoutOffset()
    if not CaptureNativeLayoutBase() then return end

    local posX = tonumber(ActionBar.positionX) or 0
    local posY = tonumber(ActionBar.positionY) or 0
    local weaponSwap, potion = GetNativeActionBarControls()

    if weaponSwap and nativeLayoutBase.weaponSwapLeft and nativeLayoutBase.weaponSwapTop then
        weaponSwap:ClearAnchors()
        weaponSwap:SetAnchor(
            TOPLEFT,
            GuiRoot,
            TOPLEFT,
            nativeLayoutBase.weaponSwapLeft + posX,
            nativeLayoutBase.weaponSwapTop + posY
        )
    end

    if potion and weaponSwap then
        potion:SetHidden(not ActionBar.showQuickslot)
        potion:ClearAnchors()

        -- QuickslotButton is the actual native potion/quickslot control.
        -- Scale the real control rather than an unrelated action-bar child.
        -- SetScale() is absolute, so repeated Refresh()/AnchorRows() calls
        -- cannot compound the scaling.
        local potionScale = POTION_SIZE / SLOT_SIZE
        potion:SetScale(potionScale)

        weaponSwap:SetScale(1)
        weaponSwap:SetHidden(not ActionBar.showWeaponSwap)

        -- Center the potion on the actual midpoint of the FULL TWO-ROW
        -- GrimSuite bar.  The back row begins at weaponSwap TOP, and the
        -- front row ends ROW_GAP pixels above that same point.
        --
        -- Using CENTER here is intentional: it makes the potion's center
        -- independent of POTION_SIZE.  The previous TOPRIGHT + calculated
        -- height approach could shift the visual center when ESO reported
        -- the native control's dimensions differently after scaling.
        local potionVisualSize = (potion:GetHeight() or SLOT_SIZE) * potionScale
        -- The potion should sit vertically centered on the weapon-swap icon.
        -- ESO's QuickslotButton is currently several pixels above the swap
        -- indicator, so give it a fixed downward correction.
        local barCenterY = 30 - (ROW_GAP * 0.5)

        -- Preserve the existing horizontal relationship: the potion's RIGHT
        -- edge sits 1px left of weaponSwap's LEFT edge.
        local potionCenterX = -1 - (potionVisualSize * 0.5)

        potion:SetAnchor(
            CENTER,
            weaponSwap,
            TOPLEFT,
            potionCenterX,
            barCenterY
        )
    end
end

function ActionBar:AnchorRows()
    -- Anchor both rows to ESO's weapon-swap control, not an action button.
    -- Action buttons can be repositioned/rebuilt during weapon swaps; the
    -- weapon-swap control is the stable visual reference.
    local actionBar = GetControl("ZO_ActionBar1")
    local weaponSwap = actionBar and actionBar:GetNamedChild("WeaponSwap")
    if not weaponSwap then return end

    self.frontRoot:ClearAnchors()
    self.backbarRoot:ClearAnchors()

    -- Keep both rows on the same stable weapon-swap reference. The front row
    -- sits just above it by ROW_GAP; the back row starts at the reference.
    -- Do not include SLOT_SIZE in the offset: the BOTTOMLEFT anchor already
    -- positions the bottom edge of the front row.
    -- Move the native weapon-swap/potion controls first.  The GrimSuite
    -- rows then follow the moved weapon-swap control, so one saved position
    -- moves the entire action-bar composition together.
    ApplyNativeLayoutOffset()

    -- The native weapon-swap control is now the physical position anchor.
    -- Do not apply positionX/positionY a second time here.
    local rowGap = GetRowGap()
    self.frontRoot:SetAnchor(BOTTOMLEFT, weaponSwap, RIGHT, 0, -rowGap)
    self.backbarRoot:SetAnchor(TOPLEFT, weaponSwap, RIGHT, 0, 0)

    -- Keep the ultimate beside the bars, centered vertically across the
    -- combined two-row block.  Anchor both ult controls to the same stable
    -- weapon-swap reference so the position does not move when weapon bars
    -- are swapped.  Only the active ult is made visible in UpdateRow().
    local ultX = GetRowWidth() + ULT_GAP
    local ultY = -(GetIconSize() + GetRowGap()) * 0.5

    local frontUlt = self.frontControls[ULT_SLOT]
    if frontUlt and frontUlt.frame then
        frontUlt.frame:ClearAnchors()
        frontUlt.frame:SetAnchor(TOPLEFT, weaponSwap, RIGHT, ultX, ultY)
    end

    local backUlt = self.backbarControls[ULT_SLOT]
    if backUlt and backUlt.frame then
        backUlt.frame:ClearAnchors()
        backUlt.frame:SetAnchor(TOPLEFT, weaponSwap, RIGHT, ultX, ultY)
    end
end

---------------------------------------------------------------------
-- Small FAB-style effect layer
--
-- FAB has a large effect database and reconciliation engine. GrimSuite only
-- needs the two pieces that matter visually here:
--   1) ESO's action-slot effect duration/time-remaining for real slot timers.
--   2) Player effect stack changes for matching slotted abilities.
--
-- No FancyActionBar dependency. No copied FAB effect database.
---------------------------------------------------------------------

local function ClearEffectDisplay(data)
    if not data then return end
    data.timer:SetText("")
    data.stack:SetText("")
end

-- Small standalone stack map. These are the same stack-tracker relationships
-- used by the FAB/CombatMetronome source we inspected, but kept deliberately
-- local so GrimSuite does not depend on FAB.
--
-- key   = slotted ability
-- value = player-effect ability that carries the actual stack count
-- Shared Crux is handled separately so it can only appear on Fatecarver.
local STACK_EFFECT_BY_ABILITY = {
    -- Molten Whip / Seething Fury
    [20805] = 122658,
    -- Bound Armaments
    [24165] = 203447,
    -- Grim Focus / Merciless Resolve / Relentless Focus
    [61902] = 122585,
    [61919] = 122586,
    [61927] = 122587,
    -- Flame Skull / Ricochet Skull / Venom Skull
    [114108] = 114131,
    [123683] = 114131,
    [123685] = 114131,
    [117637] = 117638,
    [123718] = 117638,
    [123719] = 117638,
    [117624] = 117625,
    [123699] = 117625,
    [123704] = 117625,
    -- Ruinous Scythe
    [125750] = 125749,
    -- Fetcher Infection
    [86027] = 91416,
    -- Arcanist Crux is intentionally handled separately below.
    -- Only Fatecarver and its morphs should display the Crux stack count.

}

local CRUX_EFFECT_ID = 184220

-- Crux is a shared resource, not a stack counter that belongs on every
-- Arcanist skill that generates or consumes it. GrimSuite only displays the
-- Crux count on Fatecarver and its two morphs.
local function IsFatecarverAbility(abilityId)
    if not abilityId or abilityId <= 0 or not GetAbilityName then
        return false
    end

    local ok, name = pcall(GetAbilityName, abilityId)
    if not ok or not name then
        return false
    end

    name = zo_strlower(tostring(name))
    return string.find(name, "fatecarver", 1, true) ~= nil
end

local NIGHTBLADE_STACK_EFFECTS = {
    [122585] = true, -- Grim Focus
    [122586] = true, -- Merciless Resolve
    [122587] = true, -- Relentless Focus
}

-- Necromancer Skull uses a player-effect row whose live stack count is
-- reliable through GetUnitBuffInfo(), but the normal GrimSuite cache does not
-- consistently retain the row. Track the live buff directly for the glow.
local NECRO_SKULL_STACK_EFFECTS = {
    [114131] = true, -- Flame Skull
    [117638] = true, -- Ricochet Skull
    [117625] = true, -- Venom Skull
}

local function IsNecroSkullAbility(abilityId)
    return abilityId == 114108 or abilityId == 123683 or abilityId == 123685
        or abilityId == 117637 or abilityId == 123718 or abilityId == 123719
        or abilityId == 117624 or abilityId == 123699 or abilityId == 123704
end

local function GetLivePlayerStack(effectId, trackedEffects)
    if not trackedEffects[effectId] then
        return nil
    end

    -- GetUnitBuffInfo() is authoritative for the currently-present player
    -- buff. Do NOT reject a positive stack count based on endTime here: ESO
    -- can leave an effect row present for a short period around expiration,
    -- and the diagnostic proved the row itself is carrying the correct stack.
    for i = 1, GetNumBuffs("player") do
        local _, _, _, _, stackCount, _, _, _, _, _, buffAbilityId = GetUnitBuffInfo("player", i)
        if buffAbilityId == effectId then
            local stacks = tonumber(stackCount) or 0
            return stacks > 0 and stacks or nil
        end
    end

    return nil
end

local function FindTrackedStack(abilityId)
    local effectId = STACK_EFFECT_BY_ABILITY[abilityId]
    if not effectId and IsFatecarverAbility(abilityId) then
        effectId = CRUX_EFFECT_ID
    end
    if not effectId then return nil end

    -- Nightblade spectral-bow counters use the live player buff directly.
    -- This intentionally bypasses the ActionBar cache for display; the cache
    -- remains available for the existing tracking/glow machinery.
    local liveStack = GetLivePlayerStack(effectId, NIGHTBLADE_STACK_EFFECTS)
    if liveStack ~= nil then
        return liveStack
    end

    -- Necromancer Skull has the same cache problem: ESO reports the live
    -- stack correctly, but the normal ActionBar effect cache can remain nil.
    -- Read the authoritative player buff directly for Skull only.
    local liveSkullStack = GetLivePlayerStack(effectId, NECRO_SKULL_STACK_EFFECTS)
    if liveSkullStack ~= nil then
        return liveSkullStack
    end

    local entry = ActionBar.effectStacks[effectId]
    if not entry then return nil end
    local now = GetGameTimeSeconds()
    if entry.endTime and entry.endTime > 0 and entry.endTime <= now then
        ActionBar.effectStacks[effectId] = nil
        return nil
    end
    return entry.stack
end

-- FAB treats Banner Bearer effects as one shared toggle state. Keep the
-- relevant effect IDs local so GrimSuite can reproduce that visible behavior
-- without importing FAB's full effect engine.
local BANNER_BEARER_EFFECTS = {
    [217699] = true, [227085] = true, [227600] = true, [230289] = true,
    [217704] = true, [217705] = true, [217706] = true,
    [227003] = true, [227004] = true, [227007] = true, [227008] = true,
    [227009] = true, [227029] = true, [227030] = true, [227066] = true,
    [227067] = true, [227069] = true, [227070] = true, [227071] = true,
    [227073] = true, [227082] = true, [227086] = true, [227087] = true,
    [227088] = true, [227089] = true, [227091] = true, [227092] = true,
    [227093] = true, [227094] = true, [227095] = true, [227096] = true,
    [227101] = true, [227102] = true, [227103] = true, [227104] = true,
    [227106] = true, [227107] = true, [227108] = true, [227109] = true,
    [227110] = true, [227111] = true, [227112] = true, [227113] = true,
    [227115] = true, [227116] = true, [227120] = true, [227123] = true,
    [230293] = true, [231753] = true,
}

local function ReconcileBannerState()
    local active = false
    local now = GetGameTimeSeconds()
    for i = 1, GetNumBuffs("player") do
        local _, _, endTime, _, _, _, _, _, _, _, abilityId = GetUnitBuffInfo("player", i)
        if abilityId and BANNER_BEARER_EFFECTS[abilityId] then
            if not endTime or endTime == 0 or endTime > now then
                active = true
                break
            end
        end
    end
    ActionBar.bannerActive = active
end

local function IsSlotToggleActive(slot, category)
    local ok, toggled = pcall(IsSlotToggled, slot, category)
    if ok and toggled then
        return true
    end

    local abilityId = GetAbilityForSlot(slot, category)
    return ActionBar.bannerActive and BANNER_BEARER_EFFECTS[abilityId] == true
end

-- Stack thresholds for abilities that become directly usable when their
-- tracked stacks are full. Keep this separate from STACK_EFFECT_BY_ABILITY
-- because many tracked stacks are informational and should NOT glow when full.
local READY_PROC_STACKS = {
    -- Bound Armaments: fire at 4 stacks
    [24165] = 4,
    -- Grim Focus / Merciless Resolve: spectral bow at 5 stacks
    [61902] = 5,
    [61919] = 5,
    -- Relentless Focus: spectral bow at 4 stacks
    [61927] = 4,
    -- Skull's empowered third cast is ready after two qualifying casts.
    [114108] = 2,
    [123683] = 2,
    [123685] = 2,
    [117637] = 2,
    [123718] = 2,
    [123719] = 2,
    [117624] = 2,
    [123699] = 2,
    [123704] = 2,
}

local function GetSlotEffectRemaining(slot, category)
    if not GetActionSlotEffectDuration or not GetActionSlotEffectTimeRemaining then
        return nil
    end

    local okDuration, durationMs = pcall(GetActionSlotEffectDuration, slot, category)
    local okRemain, remainMs = pcall(GetActionSlotEffectTimeRemaining, slot, category)
    if not okDuration or not okRemain then return nil end

    durationMs = tonumber(durationMs) or 0
    remainMs = tonumber(remainMs) or 0
    if durationMs <= 0 or remainMs <= 0 then return nil end

    local duration = durationMs / 1000
    local remain = remainMs / 1000
    if remain > math.max(duration, 0.1) + 0.25 then return nil end
    return remain
end

local function IsStackProcReady(abilityId)
    -- Fatecarver becomes ready to cast at 3 Crux. Crux is a shared resource,
    -- so it is handled separately from the normal per-ability stack map.
    if IsFatecarverAbility(abilityId) then
        local stacks = FindTrackedStack(abilityId)
        return stacks ~= nil and stacks >= 3
    end

    local required = READY_PROC_STACKS[abilityId]
    if not required then return false end
    local stacks = FindTrackedStack(abilityId)
    return stacks ~= nil and stacks >= required
end

-- Simmering Frenzy (often referred to as "Shimmering Frenzy") is a toggle
-- whose active state should remain visible on the custom action bar even when
-- the weapon bar containing it is inactive.  The other toggle glows remain
-- active-bar-only so we do not change their existing behavior.
local function IsSimmeringFrenzyAbility(abilityId)
    if not abilityId or abilityId <= 0 or not GetAbilityName then
        return false
    end

    local ok, name = pcall(GetAbilityName, abilityId)
    if not ok or not name then
        return false
    end

    name = zo_strlower(tostring(name))
    return string.find(name, "simmering frenzy", 1, true) ~= nil
        or string.find(name, "shimmering frenzy", 1, true) ~= nil
end

local function UpdateSlotGlow(data, slot, category, active, ultimateReady)
    if not data or not data.glow then return end
    local abilityId = GetAbilityForSlot(slot, category)
    local procReady = abilityId > 0 and IsStackProcReady(abilityId)
    local persistentToggle = abilityId > 0
        and IsSimmeringFrenzyAbility(abilityId)
        and IsSlotToggleActive(slot, category)
    local shouldGlow = (active and IsSlotToggleActive(slot, category))
        or persistentToggle
        or ultimateReady
        or procReady

    data.glow:SetHidden(not shouldGlow)
    if data.outerGlow then
        data.outerGlow:SetHidden(not shouldGlow)
    end
    if shouldGlow then
        data.glow:SetAlpha(ultimateReady and 1.0 or 0.95)
        if data.outerGlow then
            data.outerGlow:SetAlpha(ultimateReady and 0.75 or 0.58)
        end
    end
end

local function UpdateFatecarverGlowForBar(controls, category)
    if not controls then return end

    for slot = MIN_SLOT, MAX_SLOT do
        local data = controls[slot]
        if data and data.glow then
            local abilityId = GetAbilityForSlot(slot, category)
            if IsFatecarverAbility(abilityId) then
                -- Unlike normal toggle/proc glows, this must also be refreshed
                -- while the weapon bar is inactive so the Beam is visibly ready
                -- on either bar as soon as 3 Crux are available.
                UpdateSlotGlow(data, slot, category, false, false)
            end
        end
    end
end

local function FlashPressed(data)
    if not data or not data.pressed then return end

    data.pressed:SetHidden(false)
    data.pressed:SetAlpha(1.0)

    if data.pressedTimer then
        data.pressedTimer = data.pressedTimer + 1
    else
        data.pressedTimer = 1
    end

    local token = data.pressedTimer
    zo_callLater(function()
        if data.pressed and data.pressedTimer == token then
            data.pressed:SetHidden(true)
        end
    end, 110)
end

local function GetUltimateState(slot, category)
    local okPower, power = pcall(GetUnitPower, "player", COMBAT_MECHANIC_FLAGS_ULTIMATE)
    if not okPower then return nil end

    local okCost, slotCost = pcall(GetSlotAbilityCost, slot, COMBAT_MECHANIC_FLAGS_ULTIMATE, category)
    if not okCost then return nil end

    local current = math.floor(tonumber(power) or 0)
    local cost = math.floor(tonumber(slotCost) or 0)
    return current, cost, cost > 0 and current >= cost
end

local function UpdateUltimateDisplay(data, slot, category, active)
    if not data or not data.ultValue then return end
    data.ultValue:SetText("")
    if not active then return end

    local current, cost, ready = GetUltimateState(slot, category)
    if not current or not cost or cost <= 0 then return end

    if ready then
        data.ultValue:SetText(tostring(current))
        data.ultValue:SetColor(1.0, 0.86, 0.25, 1.0)
    else
        data.ultValue:SetText(string.format("%d/%d", current, cost))
        data.ultValue:SetColor(unpack(ULT_COLOR))
    end
end

local function UpdateSlotEffectDisplay(data, slot, category, active)
    ClearEffectDisplay(data)
    if not data then return end

    local abilityId = GetAbilityForSlot(slot, category)
    if abilityId <= 0 then return end

    -- Stack/proc abilities use their stack counter instead of an effect timer.
    -- Fatecarver is the one special case for the shared Crux effect.
    -- Showing the action-slot effect duration here makes instant abilities such
    -- as Bound Armaments / Skull procs visually fight with the stack number.
    local suppressTimer = STACK_EFFECT_BY_ABILITY[abilityId] ~= nil or IsFatecarverAbility(abilityId)

    -- ESO exposes the exact action-slot effect duration and remaining time.
    -- This is the compact equivalent of the useful part of FAB's timer path.
    if not suppressTimer then
        local remain = GetSlotEffectRemaining(slot, category)
        if remain then
            if remain <= 5 then
                data.timer:SetText(string.format("%.1f", remain))
            else
                data.timer:SetText(string.format("%d", math.ceil(remain)))
            end
            data.timer:SetColor(unpack(TIMER_COLOR))
        end
    end

    if ActionBar.showStackCount and not IsNecroSkullAbility(abilityId) then
        local stacks = FindTrackedStack(abilityId)
        if stacks and stacks > 0 then
            data.stack:SetText(tostring(stacks))
            data.stack:SetColor(unpack(STACK_COLOR))
        end
    end
end

-- Ultimate timers are special: GrimSuite only renders one ultimate slot,
-- but an active ultimate effect can have been cast from either weapon bar.
-- Prefer the current bar's ultimate timer; if it has none, fall back to the
-- other bar so an active back-bar ultimate (e.g. Goliath) remains visible
-- after swapping to the front bar. This matches FAB+'s intended behavior.
local function UpdateUltimateTimerDisplay()
    local activeCategory = GetActiveHotbarCategory()
    local activeData = nil
    local activeTimer = nil

    if activeCategory == HOTBAR_CATEGORY_PRIMARY then
        activeData = ActionBar.frontControls[ULT_SLOT]
        activeTimer = ActionBar.backbarControls[ULT_SLOT]
    elseif activeCategory == HOTBAR_CATEGORY_BACKUP then
        activeData = ActionBar.backbarControls[ULT_SLOT]
        activeTimer = ActionBar.frontControls[ULT_SLOT]
    else
        return
    end

    if not activeData or not activeData.timer then return end

    activeData.timer:SetText("")
    if activeTimer and activeTimer.timer then
        activeTimer.timer:SetText("")
    end

    -- Prefer an active effect on the currently selected ultimate. If there
    -- isn't one, show the still-active ultimate from the other weapon bar.
    local remain = GetSlotEffectRemaining(ULT_SLOT, activeCategory)
    if not remain then
        local otherCategory = activeCategory == HOTBAR_CATEGORY_PRIMARY
            and HOTBAR_CATEGORY_BACKUP or HOTBAR_CATEGORY_PRIMARY
        remain = GetSlotEffectRemaining(ULT_SLOT, otherCategory)
    end

    if remain then
        if remain <= 5 then
            activeData.timer:SetText(string.format("%.1f", remain))
        else
            activeData.timer:SetText(string.format("%d", math.ceil(remain)))
        end
        activeData.timer:SetColor(unpack(TIMER_COLOR))
    end
end

local function UpdateEffectDisplays()
    if not ActionBar.initialized then return end

    for _, category in ipairs(HOTBAR_CATEGORIES) do
        local controls = category == HOTBAR_CATEGORY_PRIMARY
            and ActionBar.frontControls or ActionBar.backbarControls
        for slot = MIN_SLOT, MAX_SLOT do
            UpdateSlotEffectDisplay(controls[slot], slot, category, false)
        end

        local ult = controls[ULT_SLOT]
        if ult and ult.timer then
            ult.timer:SetText("")
        end
    end

    -- Ultimate is a shared visual slot in GrimSuite. Its timer may come from
    -- either weapon bar, so render it only after checking both categories.
    UpdateUltimateTimerDisplay()
end

local function UpdateActiveBarGlows()
    local activeCategory = GetActiveHotbarCategory()
    if activeCategory ~= HOTBAR_CATEGORY_PRIMARY and activeCategory ~= HOTBAR_CATEGORY_BACKUP then
        return
    end

    local controls = activeCategory == HOTBAR_CATEGORY_PRIMARY
        and ActionBar.frontControls or ActionBar.backbarControls
    local _, _, ultimateReady = GetUltimateState(ULT_SLOT, activeCategory)
    ultimateReady = ultimateReady == true

    for slot = MIN_SLOT, ULT_SLOT do
        local data = controls[slot]
        if data then
            if slot == ULT_SLOT then
                UpdateUltimateDisplay(data, ULT_SLOT, activeCategory, true)
            end
            UpdateSlotGlow(data, slot, activeCategory, true, slot == ULT_SLOT and ultimateReady)
        end
    end

    -- Crux is shared between bars. Keep Fatecarver synchronized on the inactive
    -- bar as well.
    UpdateFatecarverGlowForBar(ActionBar.frontControls, HOTBAR_CATEGORY_PRIMARY)
    UpdateFatecarverGlowForBar(ActionBar.backbarControls, HOTBAR_CATEGORY_BACKUP)

    -- Simmering/Shimmering Frenzy is a persistent toggle: keep its glow
    -- synchronized even when the row containing it is inactive.
    for _, entry in ipairs({
        { controls = ActionBar.frontControls, category = HOTBAR_CATEGORY_PRIMARY },
        { controls = ActionBar.backbarControls, category = HOTBAR_CATEGORY_BACKUP },
    }) do
        for slot = MIN_SLOT, MAX_SLOT do
            local data = entry.controls[slot]
            if data and data.glow then
                local abilityId = GetAbilityForSlot(slot, entry.category)
                if IsSimmeringFrenzyAbility(abilityId) then
                    UpdateSlotGlow(data, slot, entry.category, false, false)
                end
            end
        end
    end
end

local function TrackPlayerEffect(eventCode, change, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
    if unitTag ~= "player" then return end
    if not abilityId or abilityId <= 0 then return end

    -- Crux is a shared player effect. Track it directly by its effect ID,
    -- rather than requiring Crux itself to be the slotted ability.
    if abilityId == CRUX_EFFECT_ID then
        local now = GetGameTimeSeconds()
        if change == EFFECT_RESULT_FADED or (endTime and endTime > 0 and endTime <= now) then
            ActionBar.effectStacks[CRUX_EFFECT_ID] = nil
            return
        end

        local stacks = tonumber(stackCount) or 0
        if stacks > 0 then
            ActionBar.effectStacks[CRUX_EFFECT_ID] = {
                stack = stacks,
                beginTime = beginTime or now,
                endTime = endTime or 0,
            }
        elseif change == EFFECT_RESULT_UPDATED or change == EFFECT_RESULT_GAINED then
            ActionBar.effectStacks[CRUX_EFFECT_ID] = nil
        end
        return
    end

    local matched = false
    local trackedEffectId = nil
    for _, category in ipairs(HOTBAR_CATEGORIES) do
        for slot = MIN_SLOT, ULT_SLOT do
            local slottedAbility = GetAbilityForSlot(slot, category)
            if slottedAbility > 0 then
                local effectId = STACK_EFFECT_BY_ABILITY[slottedAbility] or slottedAbility
                if abilityId == slottedAbility or abilityId == effectId then
                    matched = true
                    trackedEffectId = effectId
                    break
                end
            end
        end
        if matched then break end
    end
    if not matched then return end

    local now = GetGameTimeSeconds()
    if change == EFFECT_RESULT_FADED or (endTime and endTime > 0 and endTime <= now) then
        ActionBar.effectStacks[trackedEffectId or abilityId] = nil
        return
    end

    local stacks = tonumber(stackCount) or 0
    if stacks > 0 then
        ActionBar.effectStacks[trackedEffectId or abilityId] = {
            stack = stacks,
            beginTime = beginTime or now,
            endTime = endTime or 0,
        }
    elseif change == EFFECT_RESULT_UPDATED or change == EFFECT_RESULT_GAINED then
        -- Keep the entry alive for non-stackable effects; the timer path is
        -- independent. A zero stack count means simply don't draw a counter.
        ActionBar.effectStacks[trackedEffectId or abilityId] = nil
    end
end

local function ReconcilePlayerStacks()
    if not ActionBar.initialized then return end
    local now = GetGameTimeSeconds()
    local seen = {}
    for i = 1, GetNumBuffs("player") do
        local _, beginTime, endTime, _, stackCount, _, _, _, _, _, buffAbilityId = GetUnitBuffInfo("player", i)
        if buffAbilityId == CRUX_EFFECT_ID and stackCount and stackCount > 0 then
            seen[CRUX_EFFECT_ID] = true
            ActionBar.effectStacks[CRUX_EFFECT_ID] = { stack = tonumber(stackCount) or 0, beginTime = beginTime or now, endTime = endTime or 0 }
        elseif buffAbilityId and buffAbilityId > 0 and stackCount and stackCount > 0 then
            for _, category in ipairs(HOTBAR_CATEGORIES) do
                for slot = MIN_SLOT, ULT_SLOT do
                    local slottedAbility = GetAbilityForSlot(slot, category)
                    if slottedAbility > 0 then
                        local mappedEffect = STACK_EFFECT_BY_ABILITY[slottedAbility]
                        if buffAbilityId == slottedAbility or buffAbilityId == mappedEffect then
                            local effectId = mappedEffect or slottedAbility
                            seen[effectId] = true
                            ActionBar.effectStacks[effectId] = { stack = tonumber(stackCount) or 0, beginTime = beginTime or now, endTime = endTime or 0 }
                        end
                    end
                end
            end
        end
    end
    for effectId in pairs(ActionBar.effectStacks) do
        if not seen[effectId] then ActionBar.effectStacks[effectId] = nil end
    end
end

function ActionBar:UpdateRow(controls, category, active)
    for i = MIN_SLOT, MAX_SLOT do
        local data = controls[i]
        local id = GetAbilityForSlot(i, category)
        if id > 0 then
            data.icon:SetTexture(GetAbilityIcon(id))
        end

        -- FAB's important swap-time step is syncActionButton(), which calls
        -- HandleSlotChanged() on the native ESO button BEFORE it reads/uses
        -- the button state. That is what makes ESO rebuild the button's state
        -- for the newly active hotbar. We need the same step here.
        local usable = nil
        if active then
            local button = GetButton(i, category)
            if button then
                if button.HandleSlotChanged then
                    button:HandleSlotChanged(category)
                end
                usable = button.usable
            end
        end

        StyleDisplay(data, active, id > 0, usable)
        UpdateSlotGlow(data, i, category, active, false)
    end

    local ult = controls[ULT_SLOT]
    local ultId = GetAbilityForSlot(ULT_SLOT, category)
    if ultId > 0 then
        ult.icon:SetTexture(GetAbilityIcon(ultId))
    end

    local ultUsable = nil
    if active then
        local button = GetButton(ULT_SLOT, category)
        if button then
            if button.HandleSlotChanged then
                button:HandleSlotChanged(category)
            end
            ultUsable = button.usable
        end
    end
    StyleDisplay(ult, active, ultId > 0, ultUsable)

    -- Main rows remain visible in both weapon-bar states, but only the
    -- currently active bar's ultimate icon should be visible.
    ult.frame:SetHidden(not (ActionBar.showFrames and ActionBar.showUltimate and active and ultId > 0))

    UpdateUltimateDisplay(ult, ULT_SLOT, category, active)
    local ultimateReady = false
    if active then
        local _, _, ready = GetUltimateState(ULT_SLOT, category)
        ultimateReady = ready == true
    end
    UpdateSlotGlow(ult, ULT_SLOT, category, active, ultimateReady)
end

local function SetDragEnabled(enabled)
    if not ActionBar.frontRoot or not ActionBar.backbarRoot then return end

    ActionBar.frontRoot:SetMouseEnabled(enabled)
    ActionBar.backbarRoot:SetMouseEnabled(enabled)
    ActionBar.frontRoot:SetMovable(false)
    ActionBar.backbarRoot:SetMovable(false)

    for _, controls in ipairs({ ActionBar.frontControls, ActionBar.backbarControls }) do
        local ult = controls[ULT_SLOT]
        if ult and ult.frame then
            -- The row roots receive mouse input even when the pointer is over
            -- a child display control.  Keep the children themselves passive.
            ult.frame:SetMouseEnabled(false)
        end
    end
end

local function SavePosition()
    if not positionSV then return end
    positionSV.positionX = tonumber(ActionBar.positionX) or 0
    positionSV.positionY = tonumber(ActionBar.positionY) or 0
end

local function BeginActionBarDrag()
    if not ActionBar.positionUnlocked then return end
    local x, y = GetUIMousePosition()
    if not x or not y then return end

    dragState.dragging = true
    dragState.startMouseX = x
    dragState.startMouseY = y
    dragState.startX = tonumber(ActionBar.positionX) or 0
    dragState.startY = tonumber(ActionBar.positionY) or 0
end

local function EndActionBarDrag()
    if not dragState.dragging then return end
    dragState.dragging = false
    SavePosition()
end

local function UpdateActionBarDrag()
    if not dragState.dragging or not ActionBar.positionUnlocked then return end

    local x, y = GetUIMousePosition()
    if not x or not y then return end

    ActionBar.positionX = dragState.startX + (x - dragState.startMouseX)
    ActionBar.positionY = dragState.startY + (y - dragState.startMouseY)
    ActionBar:AnchorRows()
end

InstallDragHandlers = function()
    if not ActionBar.frontRoot or not ActionBar.backbarRoot then return end

    local function bind(root)
        root:SetHandler("OnMouseDown", function(_, button)
            if button == MOUSE_BUTTON_INDEX_LEFT then
                BeginActionBarDrag()
            end
        end)

        root:SetHandler("OnMouseUp", function(_, button)
            if button == MOUSE_BUTTON_INDEX_LEFT then
                EndActionBarDrag()
            end
        end)
    end

    bind(ActionBar.frontRoot)
    bind(ActionBar.backbarRoot)

    EM:UnregisterForUpdate(GS.name .. "_AB_Drag")
    EM:RegisterForUpdate(GS.name .. "_AB_Drag", 16, UpdateActionBarDrag)
end

local function LayoutDisplayButton(data, parent, x, size)
    if not data or not data.frame then return end

    data.frame:SetDimensions(size, size)
    data.frame:ClearAnchors()
    data.frame:SetAnchor(TOPLEFT, parent, TOPLEFT, x, 0)

    data.icon:ClearAnchors()
    data.icon:SetAnchor(TOPLEFT, data.frame, TOPLEFT, 2, 2)
    data.icon:SetAnchor(BOTTOMRIGHT, data.frame, BOTTOMRIGHT, -2, -2)

    data.pressed:ClearAnchors()
    data.pressed:SetAnchor(TOPLEFT, data.frame, TOPLEFT, 2, 2)
    data.pressed:SetAnchor(BOTTOMRIGHT, data.frame, BOTTOMRIGHT, -2, -2)
end

local function ApplyGABCustomization()
    if not ActionBar.initialized then return end

    local size = GetIconSize()
    local gap = GetSlotGap()
    local rowWidth = GetRowWidth()
    local totalWidth = GetTotalWidth()

    local roots = { ActionBar.frontRoot, ActionBar.backbarRoot }
    for _, root in ipairs(roots) do
        if root then
            root:SetDimensions(totalWidth, size)
            root:SetScale(1)
        end
    end

    local function resizeControls(controls)
        for i = MIN_SLOT, MAX_SLOT do
            local data = controls[i]
            if data and data.frame then
                local x = (i - MIN_SLOT) * (size + gap)
                LayoutDisplayButton(data, data.frame:GetParent(), x, size)
            end
        end

        local ult = controls[ULT_SLOT]
        if ult and ult.frame then
            LayoutDisplayButton(ult, ult.frame:GetParent(), rowWidth + ULT_GAP, size)
        end
    end

    resizeControls(ActionBar.frontControls)
    resizeControls(ActionBar.backbarControls)
    ApplyOverlayTextStyles()
    ActionBar:AnchorRows()

    local weaponSwap, potion = GetNativeActionBarControls()
    if weaponSwap then weaponSwap:SetScale(1) end
    if potion then potion:SetScale(POTION_SIZE / SLOT_SIZE) end

    ActionBar:Refresh()
end

local function CenterOnThirdSlot()
    local actionBar = GetControl("ZO_ActionBar1")
    local weaponSwap = actionBar and actionBar:GetNamedChild("WeaponSwap")
    if not weaponSwap then return end

    -- The actual ESO "third skill slot" in the displayed five-skill bar
    -- is hotbar slot 5 (slots 3, 4, 5, 6, 7).
    -- Center the midpoint of displayed slot 5 on the exact horizontal
    -- midpoint of the screen.
    CaptureNativeLayoutBase()

    local screenCenterX = GuiRoot:GetWidth() * 0.5
    local displayedSlot3Index = 3
    local slot5CenterOffset = ((displayedSlot3Index - 1) * (GetIconSize() + GetSlotGap())) + (GetIconSize() * 0.5)
    local desiredRootLeft = screenCenterX - slot5CenterOffset
    local referenceRight = nativeLayoutBase.weaponSwapRight or weaponSwap:GetRight()

    -- positionX is the shared offset applied to the native anchor and the
    -- GrimSuite bars.  Calculate it from the native control's original
    -- position so the center button remains exact.
    ActionBar.positionX = desiredRootLeft - referenceRight
    SavePosition()
    ActionBar:AnchorRows()
end

local function ResetPosition()
    ActionBar.positionX = 0
    ActionBar.positionY = 0
    SavePosition()
    ActionBar:AnchorRows()
end

local GAB_SETTING_KEYS = {
    "iconSize", "slotGap", "rowGap",
    "backbarOpacity", "backbarDesaturation",
    "showUltimate", "showQuickslot", "showWeaponSwap",
    "timerSize", "stackSize", "timerFont", "stackFont",
    "timerOutline", "stackOutline",
    "timerOffsetX", "timerOffsetY", "stackOffsetX", "stackOffsetY",
}

local function SaveGABSetting(key, value)
    ActionBar[key] = value
    if positionSV then
        positionSV[key] = value
    end
end

local function ResetGABCustomization()
    for _, key in ipairs(GAB_SETTING_KEYS) do
        SaveGABSetting(key, POSITION_DEFAULTS[key])
    end
    ApplyGABCustomization()
end

local function RegisterLibAddonMenu()
    LAM = LibAddonMenu2

    -- Saved vars are normally initialized during ActionBar:Initialize(), so
    -- position persistence does not depend on LibAddonMenu's load order.
    if not positionSV then
        positionSV = ZO_SavedVars:NewAccountWide(POSITION_SV_NAME, POSITION_SV_VERSION, nil, POSITION_DEFAULTS)
    end

    local panelName = GS.name .. "_ActionBar_Settings"
    local panelData = {
        type = "panel",
        name = "GrimSuite Action Bar",
        displayName = "GrimSuite Action Bar",
        author = "@GrimGrin94",
        version = GS.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local options = {
        {
            type = "description",
            text = "Position and movement controls for the GrimSuite action bar.",
        },
        {
            type = "header",
            name = "GAB Customization",
        },
        {
            type = "slider",
            name = "Icon Size",
            tooltip = "Changes the size of the skill, ultimate, and backbar icons.",
            min = 40, max = 100, step = 1,
            getFunc = function() return GetIconSize() end,
            setFunc = function(value)
                SaveGABSetting("iconSize", tonumber(value) or POSITION_DEFAULTS.iconSize)
                ApplyGABCustomization()
            end,
            default = POSITION_DEFAULTS.iconSize,
        },
        {
            type = "slider",
            name = "Icon Spacing",
            tooltip = "Horizontal spacing between skill icons.",
            min = 0, max = 20, step = 1,
            getFunc = function() return GetSlotGap() end,
            setFunc = function(value)
                SaveGABSetting("slotGap", tonumber(value) or POSITION_DEFAULTS.slotGap)
                ApplyGABCustomization()
            end,
            default = POSITION_DEFAULTS.slotGap,
        },
        {
            type = "slider",
            name = "Bar Spacing",
            tooltip = "Vertical spacing between the front and back bars.",
            min = 0, max = 20, step = 1,
            getFunc = function() return GetRowGap() end,
            setFunc = function(value)
                SaveGABSetting("rowGap", tonumber(value) or POSITION_DEFAULTS.rowGap)
                ApplyGABCustomization()
            end,
            default = POSITION_DEFAULTS.rowGap,
        },
        {
            type = "slider",
            name = "Backbar Opacity",
            tooltip = "Controls the opacity of icons on the inactive backbar.",
            min = 0, max = 1, step = 0.05,
            getFunc = function() return GetBackbarOpacity() end,
            setFunc = function(value)
                SaveGABSetting("backbarOpacity", tonumber(value) or POSITION_DEFAULTS.backbarOpacity)
                ActionBar:Refresh()
            end,
            default = POSITION_DEFAULTS.backbarOpacity,
        },
        {
            type = "slider",
            name = "Backbar Desaturation",
            tooltip = "Controls how gray the inactive backbar icons appear.",
            min = 0, max = 1, step = 0.05,
            getFunc = function() return GetBackbarDesaturation() end,
            setFunc = function(value)
                SaveGABSetting("backbarDesaturation", tonumber(value) or POSITION_DEFAULTS.backbarDesaturation)
                ActionBar:Refresh()
            end,
            default = POSITION_DEFAULTS.backbarDesaturation,
        },
        {
            type = "header",
            name = "Timer & Stack Text",
        },
        {
            type = "slider",
            name = "Timer Horizontal Position",
            tooltip = "Moves timer text left or right relative to the center of its icon.",
            min = -20, max = 20, step = 1,
            getFunc = function() return tonumber(ActionBar.timerOffsetX) or POSITION_DEFAULTS.timerOffsetX end,
            setFunc = function(value)
                SaveGABSetting("timerOffsetX", tonumber(value) or POSITION_DEFAULTS.timerOffsetX)
                ApplyOverlayTextStyles()
            end,
            default = POSITION_DEFAULTS.timerOffsetX,
        },
        {
            type = "slider",
            name = "Timer Vertical Position",
            tooltip = "Moves timer text up or down relative to the center of its icon.",
            min = -20, max = 20, step = 1,
            getFunc = function() return tonumber(ActionBar.timerOffsetY) or POSITION_DEFAULTS.timerOffsetY end,
            setFunc = function(value)
                SaveGABSetting("timerOffsetY", tonumber(value) or POSITION_DEFAULTS.timerOffsetY)
                ApplyOverlayTextStyles()
            end,
            default = POSITION_DEFAULTS.timerOffsetY,
        },
        {
            type = "slider",
            name = "Timer Size",
            tooltip = "Changes the size of cooldown/effect timer text on skill and ultimate slots.",
            min = 10, max = 80, step = 1,
            getFunc = function() return tonumber(ActionBar.timerSize) or POSITION_DEFAULTS.timerSize end,
            setFunc = function(value)
                SaveGABSetting("timerSize", tonumber(value) or POSITION_DEFAULTS.timerSize)
                ApplyOverlayTextStyles()
            end,
            default = POSITION_DEFAULTS.timerSize,
        },
        {
            type = "dropdown",
            name = "Timer Font",
            tooltip = "Font used for cooldown/effect timer text.",
            choices = { "Univers 67", "Univers 57", "ProseAntique", "Trajan Pro", "Skyrim Handwritten", "Futura Condensed Light", "Futura Condensed", "Futura Condensed Bold" },
            getFunc = function() return ActionBar.timerFont end,
            setFunc = function(value)
                SaveGABSetting("timerFont", tostring(value))
                ApplyOverlayTextStyles()
            end,
            default = POSITION_DEFAULTS.timerFont,
        },
        {
            type = "dropdown",
            name = "Timer Outline",
            tooltip = "Outline style used for cooldown/effect timer text.",
            choices = { "none", "outline", "thick-outline", "soft-shadow-thick-outline", "shadow" },
            getFunc = function() return ActionBar.timerOutline end,
            setFunc = function(value)
                SaveGABSetting("timerOutline", tostring(value))
                ApplyOverlayTextStyles()
            end,
            default = POSITION_DEFAULTS.timerOutline,
        },
        {
            type = "slider",
            name = "Stack Horizontal Position",
            tooltip = "Moves stack-count text left or right relative to the center of its icon.",
            min = -20, max = 20, step = 1,
            getFunc = function() return tonumber(ActionBar.stackOffsetX) or POSITION_DEFAULTS.stackOffsetX end,
            setFunc = function(value)
                SaveGABSetting("stackOffsetX", tonumber(value) or POSITION_DEFAULTS.stackOffsetX)
                ApplyOverlayTextStyles()
            end,
            default = POSITION_DEFAULTS.stackOffsetX,
        },
        {
            type = "slider",
            name = "Stack Vertical Position",
            tooltip = "Moves stack-count text up or down relative to the center of its icon.",
            min = -20, max = 20, step = 1,
            getFunc = function() return tonumber(ActionBar.stackOffsetY) or POSITION_DEFAULTS.stackOffsetY end,
            setFunc = function(value)
                SaveGABSetting("stackOffsetY", tonumber(value) or POSITION_DEFAULTS.stackOffsetY)
                ApplyOverlayTextStyles()
            end,
            default = POSITION_DEFAULTS.stackOffsetY,
        },
        {
            type = "slider",
            name = "Stack Size",
            tooltip = "Changes the size of stack-count text on skill slots.",
            min = 10, max = 80, step = 1,
            getFunc = function() return tonumber(ActionBar.stackSize) or POSITION_DEFAULTS.stackSize end,
            setFunc = function(value)
                SaveGABSetting("stackSize", tonumber(value) or POSITION_DEFAULTS.stackSize)
                ApplyOverlayTextStyles()
            end,
            default = POSITION_DEFAULTS.stackSize,
        },
        {
            type = "dropdown",
            name = "Stack Font",
            tooltip = "Font used for stack-count text.",
            choices = { "Univers 67", "Univers 57", "ProseAntique", "Trajan Pro", "Skyrim Handwritten", "Futura Condensed Light", "Futura Condensed", "Futura Condensed Bold" },
            getFunc = function() return ActionBar.stackFont end,
            setFunc = function(value)
                SaveGABSetting("stackFont", tostring(value))
                ApplyOverlayTextStyles()
            end,
            default = POSITION_DEFAULTS.stackFont,
        },
        {
            type = "dropdown",
            name = "Stack Outline",
            tooltip = "Outline style used for stack-count text.",
            choices = { "none", "outline", "thick-outline", "soft-shadow-thick-outline", "shadow" },
            getFunc = function() return ActionBar.stackOutline end,
            setFunc = function(value)
                SaveGABSetting("stackOutline", tostring(value))
                ApplyOverlayTextStyles()
            end,
            default = POSITION_DEFAULTS.stackOutline,
        },
        {
            type = "checkbox",
            name = "Show Ultimate",
            tooltip = "Show the active ultimate icon.",
            getFunc = function() return ActionBar.showUltimate == true end,
            setFunc = function(value)
                SaveGABSetting("showUltimate", value == true)
                ActionBar:Refresh()
            end,
            default = POSITION_DEFAULTS.showUltimate,
        },
        {
            type = "checkbox",
            name = "Show Quickslot",
            tooltip = "Show the ESO quickslot/potion control beside GAB.",
            getFunc = function() return ActionBar.showQuickslot == true end,
            setFunc = function(value)
                SaveGABSetting("showQuickslot", value == true)
                ActionBar:AnchorRows()
            end,
            default = POSITION_DEFAULTS.showQuickslot,
        },
        {
            type = "checkbox",
            name = "Show Weapon Swap",
            tooltip = "Show the ESO weapon-swap indicator beside GAB.",
            getFunc = function() return ActionBar.showWeaponSwap == true end,
            setFunc = function(value)
                SaveGABSetting("showWeaponSwap", value == true)
                ActionBar:AnchorRows()
            end,
            default = POSITION_DEFAULTS.showWeaponSwap,
        },
        {
            type = "button",
            name = "Reset GAB Customization",
            tooltip = "Restore the original GrimSuite GAB size, spacing, scale, backbar appearance, and element visibility.",
            func = ResetGABCustomization,
            width = "half",
        },
        {
            type = "checkbox",
            name = "Unlock Action Bar",
            tooltip = "When enabled, drag anywhere on either GrimSuite bar to move the entire layout.",
            getFunc = function()
                return ActionBar.positionUnlocked == true
            end,
            setFunc = function(value)
                ActionBar.positionUnlocked = value == true
                if positionSV then positionSV.unlocked = ActionBar.positionUnlocked end
                SetDragEnabled(ActionBar.positionUnlocked)
            end,
            default = POSITION_DEFAULTS.unlocked,
            width = "full",
        },
        {
            type = "button",
            name = "Center Horizontally (Skill Slot 3)",
            tooltip = "Centers the middle of the third displayed skill (ESO hotbar slot 5) on the exact center of the screen.",
            func = CenterOnThirdSlot,
            width = "half",
        },
        {
            type = "button",
            name = "Reset Position",
            tooltip = "Returns the action bar to its original ESO-relative position.",
            func = ResetPosition,
            width = "half",
        },
    }

    LAM:RegisterAddonPanel(panelName, panelData)
    LAM:RegisterOptionControls(panelName, options)
end

function ActionBar:SetHUDVisible(visible)
    visible = visible == true

    if self.frontRoot then
        self.frontRoot:SetHidden(not (visible and self.showFrames))
    end
    if self.backbarRoot then
        self.backbarRoot:SetHidden(not (visible and self.showFrames))
    end
end

function ActionBar:Refresh()
    if not self.initialized then return end

    self:CreateRows()
    self:AnchorRows()
    local activeCategory = GetActiveHotbarCategory()
    if activeCategory ~= HOTBAR_CATEGORY_PRIMARY and activeCategory ~= HOTBAR_CATEGORY_BACKUP then
        activeCategory = HOTBAR_CATEGORY_PRIMARY
    end

    -- Physical rows are permanently tied to the two weapon bars.
    -- The FRONT BAR is always the top row and the BACK BAR is always the
    -- bottom row. Weapon swapping changes only which row is active; it never
    -- changes which abilities belong to either physical row.
    local frontCategory = HOTBAR_CATEGORY_PRIMARY
    local backCategory = HOTBAR_CATEGORY_BACKUP
    self:UpdateRow(self.frontControls, frontCategory, activeCategory == HOTBAR_CATEGORY_PRIMARY)
    self:UpdateRow(self.backbarControls, backCategory, activeCategory == HOTBAR_CATEGORY_BACKUP)

    -- HandleSlotChanged() above can make the native button visible again, so
    -- suppress native visuals AFTER the sync/paint pass, just like a final
    -- presentation step.
    self:UpdateNativeVisualSuppression()
    UpdateEffectDisplays()
end

function ActionBar:Initialize()
    if self.initialized then return end
    self.initialized = true

    -- Load the position independently of LibAddonMenu.  LAM is only the
    -- settings UI; the actual saved position must be available immediately
    -- so /reloadui cannot briefly rebuild the bar at the default location.
    if not positionSV then
        positionSV = ZO_SavedVars:NewAccountWide(POSITION_SV_NAME, POSITION_SV_VERSION, nil, POSITION_DEFAULTS)
    end

    self.positionX = tonumber(positionSV.positionX) or 0
    self.positionY = tonumber(positionSV.positionY) or 0
    self.positionUnlocked = positionSV.unlocked == true

    self.iconSize = tonumber(positionSV.iconSize) or POSITION_DEFAULTS.iconSize
    self.slotGap = tonumber(positionSV.slotGap) or POSITION_DEFAULTS.slotGap
    self.rowGap = tonumber(positionSV.rowGap) or POSITION_DEFAULTS.rowGap
    self.backbarOpacity = tonumber(positionSV.backbarOpacity) or POSITION_DEFAULTS.backbarOpacity
    self.backbarDesaturation = tonumber(positionSV.backbarDesaturation) or POSITION_DEFAULTS.backbarDesaturation
    self.showUltimate = positionSV.showUltimate ~= false
    self.showQuickslot = positionSV.showQuickslot ~= false
    self.showWeaponSwap = positionSV.showWeaponSwap ~= false
    self.timerSize = tonumber(positionSV.timerSize) or POSITION_DEFAULTS.timerSize
    self.stackSize = tonumber(positionSV.stackSize) or POSITION_DEFAULTS.stackSize
    self.timerFont = tostring(positionSV.timerFont or POSITION_DEFAULTS.timerFont)
    self.stackFont = tostring(positionSV.stackFont or POSITION_DEFAULTS.stackFont)
    self.timerOutline = tostring(positionSV.timerOutline or POSITION_DEFAULTS.timerOutline)
    self.stackOutline = tostring(positionSV.stackOutline or POSITION_DEFAULTS.stackOutline)
    self.timerOffsetX = tonumber(positionSV.timerOffsetX) or POSITION_DEFAULTS.timerOffsetX
    self.timerOffsetY = tonumber(positionSV.timerOffsetY) or POSITION_DEFAULTS.timerOffsetY
    self.stackOffsetX = tonumber(positionSV.stackOffsetX) or POSITION_DEFAULTS.stackOffsetX
    self.stackOffsetY = tonumber(positionSV.stackOffsetY) or POSITION_DEFAULTS.stackOffsetY

    RegisterLibAddonMenu()
    SetDragEnabled(self.positionUnlocked)

    EM:RegisterForEvent(GS.name .. "_AB_PlayerActivated", EVENT_PLAYER_ACTIVATED, function()
        -- Let ESO finish establishing the native action-bar layout, then
        -- reapply the saved position without recapturing the native reference.
        -- The captured reference is the original ESO-relative baseline used by
        -- the saved position; recapturing during activation can capture an
        -- intermediate layout state.
        zo_callLater(function() self:Refresh() end, 100)
    end)

    -- ESO can re-show/re-anchor ZO_ActionBar1 after scene/zone transitions.
    -- Azurah handles this by restoring the user's action-bar position from
    -- the action bar's OnShow lifecycle rather than relying only on
    -- EVENT_PLAYER_ACTIVATED.  Do the same repair here, while leaving all
    -- existing GrimSuite geometry and saved-position math untouched.
    if ZO_ActionBar1 then
        ZO_PreHookHandler(ZO_ActionBar1, "OnShow", function()
            if not self.initialized then return end
            zo_callLater(function()
                if self.initialized then
                    self:Refresh()
                end
            end, 0)
        end)
    end

    -- This is the authoritative action-slot update event used by ESO/FAB.
    -- IMPORTANT: the first boolean only tells us whether the ACTIVE hotbar
    -- changed. The second boolean tells us whether the ability assignments
    -- changed. Wizard-style setup/loadout swaps can change both bars while
    -- keeping the same weapon/gear setup, so didActiveHotbarChange can be
    -- false even though every skill icon needs to be repainted.
    EM:RegisterForEvent(GS.name .. "_AB_HotbarUpdated", EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED, function(_, didActiveHotbarChange, shouldUpdateAbilityAssignments, activeHotbarCategory)
        if not didActiveHotbarChange and not shouldUpdateAbilityAssignments then
            return
        end
        if activeHotbarCategory ~= HOTBAR_CATEGORY_PRIMARY and activeHotbarCategory ~= HOTBAR_CATEGORY_BACKUP then
            return
        end

        -- Let ESO finish publishing the new slot assignments before we read
        -- them. This is particularly important when a setup changes skills
        -- without changing the active weapon pair.
        zo_callLater(function()
            if not self.initialized then return end
            local currentCategory = GetActiveHotbarCategory()
            if currentCategory ~= HOTBAR_CATEGORY_PRIMARY and currentCategory ~= HOTBAR_CATEGORY_BACKUP then
                return
            end

            self:CreateRows()
            self:AnchorRows()
            self:UpdateRow(self.frontControls, HOTBAR_CATEGORY_PRIMARY, currentCategory == HOTBAR_CATEGORY_PRIMARY)
            self:UpdateRow(self.backbarControls, HOTBAR_CATEGORY_BACKUP, currentCategory == HOTBAR_CATEGORY_BACKUP)
            self:UpdateNativeVisualSuppression()
        end, 0)
    end)

    -- Some setup/loadout systems can update both hotbars without changing the
    -- active-hotbar state. This event is the explicit all-bars assignment
    -- notification, so use it as a lightweight repaint fallback.
    if EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED then
        EM:RegisterForEvent(GS.name .. "_AB_AllHotbarsUpdated", EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED, function()
            zo_callLater(function()
                if self.initialized then
                    self:Refresh()
                end
            end, 0)
        end)
    end

    -- ESO reports the actual skill activation here.  Flash only the
    -- corresponding GrimSuite button on the currently active bar.
    EM:RegisterForEvent(GS.name .. "_AB_PressedFeedback", EVENT_ACTION_SLOT_ABILITY_USED, function(_, slot)
        if slot < MIN_SLOT or slot > ULT_SLOT then return end

        local category = GetActiveHotbarCategory()
        local controls = category == HOTBAR_CATEGORY_PRIMARY and self.frontControls or self.backbarControls
        local data = controls and controls[slot]
        if data then
            FlashPressed(data)
        end
    end)

    -- Slot assignment changes repaint the affected rows.
    EM:RegisterForEvent(GS.name .. "_AB_SlotUpdate", EVENT_HOTBAR_SLOT_UPDATED, function()
        self:Refresh()
    end)

    -- FAB only responds to usability state changes for the CURRENT active bar.
    -- Do the same here instead of rebuilding/caching usability ourselves.
    EM:RegisterForEvent(GS.name .. "_AB_Usability", EVENT_HOTBAR_SLOT_STATE_UPDATED, function(_, slot, hotbar)
        if slot < MIN_SLOT or slot > ULT_SLOT then return end
        if hotbar ~= GetActiveHotbarCategory() then return end

        local controls = hotbar == HOTBAR_CATEGORY_PRIMARY and self.frontControls or self.backbarControls
        local data = controls[slot]
        local button = GetButton(slot, hotbar)
        if not data or not button then return end

        local id = GetAbilityForSlot(slot, hotbar)
        StyleDisplay(data, true, id > 0, button.usable)

        -- Re-evaluate the state glow immediately so active toggles and ready
        -- procs/ultimates do not briefly disappear while ESO updates the slot.
        local currentUlt, costUlt = 0, 0
        local ultimateReady = false
        if slot == ULT_SLOT then
            local okPower, power = pcall(GetUnitPower, "player", COMBAT_MECHANIC_FLAGS_ULTIMATE)
            local okCost, cost = pcall(GetSlotAbilityCost, ULT_SLOT, COMBAT_MECHANIC_FLAGS_ULTIMATE, hotbar)
            if okPower then currentUlt = tonumber(power) or 0 end
            if okCost then costUlt = tonumber(cost) or 0 end
            ultimateReady = costUlt > 0 and currentUlt >= costUlt
        end
        UpdateSlotGlow(data, slot, hotbar, true, ultimateReady)
    end)

    -- Player effect changes provide stack counts. We deliberately only retain
    -- effects whose ability is actually slotted on one of GrimSuite's bars.
    EM:RegisterForEvent(GS.name .. "_AB_Effects", EVENT_EFFECT_CHANGED, TrackPlayerEffect)

    -- Action-slot effects are the authoritative source for timers. Update at
    -- a modest rate so the text moves smoothly without rebuilding the bars.
    EM:RegisterForUpdate(GS.name .. "_AB_EffectDisplay", 100, function()
        if self.initialized then
            ReconcilePlayerStacks()
            ReconcileBannerState()
            UpdateEffectDisplays()
            UpdateActiveBarGlows()
        end
    end)

    -- ESO can repaint native action-button visuals during weapon swaps. Keep
    -- the real controls available for input while suppressing their visuals.
    EM:RegisterForUpdate(GS.name .. "_AB_NativeSuppress", 16, function()
        if self.initialized then
            self:UpdateNativeVisualSuppression()
        end
    end)

    -- No periodic Refresh(): FAB is event-driven for bar/usability presentation.
    -- This avoids re-reading a stale native usability flag between ESO events.
    zo_callLater(function() self:Refresh() end, 250)
end
