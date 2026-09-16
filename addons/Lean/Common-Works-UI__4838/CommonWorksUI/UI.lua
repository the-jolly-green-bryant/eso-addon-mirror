-- Common Works — UI layer

CommonWorksUI = CommonWorksUI or {}
local CW = CommonWorksUI
CW.UI = CW.UI or {}
local UI = CW.UI

local WM = WINDOW_MANAGER
local EM = EVENT_MANAGER

-- Theme
-- Anything UI.SyncTheme computes is absent here: it runs before the first control
-- exists, so a seed for it would never be read.
local THEME = {
    -- Rows run to the panel edge; the backdrop sits 4px OUTSIDE it (UI.bg) and its
    -- template frame is another 16px of border art, so nothing overlaps the art.
    sideInset          = 0,
    endInset           = 12,
    -- The chrome buttons sit ABOVE the panel, so the top needs no reservation.
    padTop             = 4,

    sectionSpace       = 10,   -- total gap between top-level sections
    minWrappedH        = 20,
    questSpace         = 9,
    -- Smaller bottom padding keeps the attacker line tied to the keep above it.
    keepPadTop         = 6,
    keepPadBot         = 2,
    dividerGap         = 5,    -- between the rule and the header under it
    dividerTop         = 5,    -- between the rule and whatever sits above it
    zoneStoryIcon      = "EsoUI/Art/Icons/mapKey/mapKey_zoneStory.dds",
    guildDailyIcon     = "EsoUI/Art/Icons/mapKey/mapKey_u26_priest_of_arkay_complete.dds",
    undauntedIcon      = "EsoUI/Art/Icons/mapKey/mapKey_undaunted.dds",
    battlegroundIcon   = "EsoUI/Art/Icons/mapKey/mapKey_bg_banner.dds",
    avaDailyIcon       = "EsoUI/Art/Icons/poi/poi_keep_complete.dds",
    zoneDailyIcon      = "EsoUI/Art/Icons/mapKey/mapKey_groupBoss.dds",   -- Zone Dailies section
    houseIcon          = "EsoUI/Art/Icons/mapKey/mapKey_housing.dds",
    iconSpace          = 7,
    groupBtnSize       = 28, -- group show/hide checkmarks
    chromeBtnPx        = 22, -- every chrome-bar button: picker, last quest, gear, lock
    chromeBtnGap       = 6,  -- spacing between the chrome-bar buttons
    chromeBtnLeft      = 10, -- the bar's clearance in from the panel's left edge
    chromeBtnLift      = 15, -- and up off the content

    subRowIndent       = 8,    -- rows under a sub-header that has no icon to line up past
    -- Leads both Tomes headlines.
    tomeSeasonalIcon   = "EsoUI/Art/TamrielTomes/timedActivityCategory_seasonal_up.dds",
    tomeWeeklyIcon     = "EsoUI/Art/TamrielTomes/timedActivityCategory_weekly_down.dds",
    subGroupSpace      = 7,

    -- SyncTheme fills these before controls exist; only the destination tables need seeds.
    active             = {},
    queue              = {},
}

-- ESO font tokens, bundled paths or LibMediaProvider fonts; ApplyTheme adds size/style.
-- Bundled DM Sans defaults: SemiBold for panel, Bold for alerts.
-- Non-$(...) paths resolve relative to AddOns.
local DM_SANS = {
    { "DM Sans SemiBold", "CommonWorksUI/fonts/DMSans-SemiBold.slug" },
    { "DM Sans Bold",     "CommonWorksUI/fonts/DMSans-Bold.slug" },
    { "DM Sans Medium",   "CommonWorksUI/fonts/DMSans-Medium.slug" },
    { "DM Sans Regular",  "CommonWorksUI/fonts/DMSans-Regular.slug" },
}

-- Stock sans, bold and serif; LMP supplies others. Gamepad/Chat look like Default at these
-- sizes, and Handwritten is illegible below ~20px.
local BASE_FONTS = {
    ["Default"]       = "$(MEDIUM_FONT)",
    ["Bold"]          = "$(BOLD_FONT)",
    ["Prose Antique"] = "EsoUI/Common/Fonts/ProseAntiquePSMCP.otf",
}
local BASE_FONT_NAMES = { "Default", "Bold", "Prose Antique" }
for i, f in ipairs(DM_SANS) do
    BASE_FONTS[f[1]] = f[2]
    table.insert(BASE_FONT_NAMES, i, f[1])
end

-- That shared list is the only way fonts travel between add-ons. LMP is optional, and it
-- silently ignores a name somebody else registered.
local LMP = LibMediaProvider
if LMP then
    for _, f in ipairs(DM_SANS) do LMP:Register(LMP.MediaType.FONT, f[1], f[2]) end
end
UI.FONTS = {}
UI.FONT_NAMES = {}
local fontChoicesLoaded = false

function UI.RefreshFontChoices()
    if fontChoicesLoaded then return UI.FONT_NAMES end
    local fonts, names, seen = UI.FONTS, UI.FONT_NAMES, {}
    local function add(name, path)
        if seen[name] then return end
        seen[name] = true
        fonts[name] = path
        names[#names + 1] = name
    end

    for _, name in ipairs(BASE_FONT_NAMES) do
        add(name, BASE_FONTS[name])
    end

    if LMP then
        for _, name in ipairs(LMP:List(LMP.MediaType.FONT)) do
            add(name, LMP:Fetch(LMP.MediaType.FONT, name))
        end
    end

    fontChoicesLoaded = true
    return UI.FONT_NAMES
end

-- ESO sizes "100%" inline glyphs to font height, so they follow size sliders without rebuilding.
local CHECK_TEX = "EsoUI/Art/Miscellaneous/check_icon_32.dds"
local CHECK = zo_iconFormat(CHECK_TEX, "100%", "100%")
local CHECK_INHERIT = zo_iconFormatInheritColor(CHECK_TEX, "100%", "100%")
-- Native unaccepted-repeatable compass pin, matching daily/weekly quest icons.
-- Inherit color so |c can gray it out; zo_iconFormat preserves stock colors.
local AVAILABLE_TEX = "EsoUI/Art/Compass/repeatableQuest_available_icon.dds"
local AVAILABLE = zo_iconFormat(AVAILABLE_TEX, "100%", "100%")
local AVAILABLE_INHERIT = zo_iconFormatInheritColor(AVAILABLE_TEX, "100%", "100%")
local BULLET = GetString(SI_BULLET)
-- What the block is a queue for. The three battleground brackets share the banner and
-- both tribute ladders the service pin; the campaign queue is the only non-finder one.
local QUEUE_ICONS = {
    dungeon  = "EsoUI/Art/Icons/mapKey/mapKey_dungeon.dds",
    bg       = "EsoUI/Art/Icons/mapKey/mapKey_bg_banner.dds",
    tribute  = "EsoUI/Art/Icons/servicemappins/servicepin_talesoftribute.dds",
    campaign = "EsoUI/Art/Icons/mapKey/mapKey_keep.dds",
}
-- A dropdown glyph marks clickable filters; inherit the header tint and avoid font-dependent arrows.
local DOWN_ARROW = zo_iconFormatInheritColor("EsoUI/Art/Buttons/scrollbox_downarrow_up.dds",
    "100%", "100%")

-- ESO |c markup supports RGB only. Composite alpha against the black panel backdrop.
local function HexOf(c)
    local a = c[4] or 1
    return string.format("%02x%02x%02x", c[1] * a * 255, c[2] * a * 255, c[3] * a * 255)
end
local function ColorText(c, text) return string.format("|c%s%s|r", HexOf(c), text or "") end

local function GreenCheck() return ColorText(THEME.active.finished, CHECK_INHERIT) end
local function GreyAvailable() return ColorText(THEME.muted.body, AVAILABLE_INHERIT) end
local function GreyBullet() return ColorText(THEME.muted.body, BULLET) end

-- Tint AvA glyphs: saturation is 0.03-0.12 for mapKey and 0.05-0.09 for alliance badges,
-- below icon-scan.py's 0.15 cutoff. Use 120% to preserve thin strokes in 64px art on ~21px
-- rows; leading provides room, and ICON_BOOST does the same for pooled textures.
local AVA_GLYPH_PX = "120%"
local function Glyph(path)
    return path and zo_iconFormatInheritColor(path, AVA_GLYPH_PX, AVA_GLYPH_PX) or ""
end

-- Enlarge detailed Undaunted art; shrink Priest of Arkay's edge-to-edge art.
-- All panel icons use 2px size steps to stay centered on whole pixels.
local ICON_SCALE = {
    ["EsoUI/Art/Icons/mapKey/mapKey_undaunted.dds"] = 1.2,
    ["EsoUI/Art/Icons/mapKey/mapKey_u26_priest_of_arkay_complete.dds"] = 0.9,
    -- 67% art inside its texture against the weekly glyph's 92%, right beside it.
    ["EsoUI/Art/TamrielTomes/timedActivityCategory_seasonal_up.dds"] = 1.2,
}
local function IconPx(path)
    local px = THEME.questIconPx
    local scale = ICON_SCALE[path]
    return scale and px + 2 * zo_round(px * (scale - 1) / 2) or px
end

-- An icon at the left margin, a title past it. Rows line up with the title, not the
-- icon, so both halves are asked for by name.
local function SectionLineH() return math.max(THEME.titleRow, THEME.questIconPx) end
local function SectionTextLeft() return THEME.sideInset + THEME.questIconPx + THEME.iconSpace end

function UI.GetContentIndent() return SectionTextLeft() end

local function SetChromeControl(ctrl, available, visibleAlpha)
    if available == false then
        ctrl:SetHidden(true)
        ctrl:SetMouseEnabled(false)
        return
    end

    local on = UI.chromeHovered == true
    ctrl:SetHidden(false)
    ctrl:SetAlpha(on and visibleAlpha or 0)
    -- chromeNonInteractive: fades with the chrome, never a mouse target. A handler-less
    -- label with a hit-rect over the footer buttons steals their hover.
    ctrl:SetMouseEnabled(on and not ctrl.chromeNonInteractive)
end

-- The bar's buttons rest a little see-through and come up full under the cursor; the
-- last-quest button stays at half while its quest is already the active one.
local CHROME_IDLE_ALPHA = 0.6
local function ChromeButtonAlpha(btn, hovered)
    return btn.isActive and 0.5 or hovered and 1 or CHROME_IDLE_ALPHA
end

-- Only while the bar is up: switching the chrome off disables the mouse, which can fire an
-- exit that would otherwise bring a hidden button back.
local function SetChromeButtonHover(btn, hovered)
    if UI.chromeHovered then btn:SetAlpha(ChromeButtonAlpha(btn, hovered)) end
end

-- If so, hover changes the panel's HEIGHT (the restore strip appears), so a re-alpha
-- is not enough.
function UI.HasHiddenGroups()
    local hidden = CW.SavedVars.groupHidden
    for _, g in ipairs(UI.toggleGroups) do
        if hidden[g.id] then return true end
    end
    return false
end

-- Hover
--
-- One hover region includes the panel and left gutter, including gaps between checkmarks.
-- Poll to end hover: OnMouseExit may not fire when mouse mode ends, the panel hides,
-- or layout moves a control away from a stationary cursor.
local CHROME_WATCH = CW.name .. "ChromeHover"
local CHROME_WATCH_MS = 100

local function MouseIsOnChrome()
    local panel = UI.panel
    if panel:IsHidden() then return false end
    -- No mouse mode means no cursor, so nothing can be hovering anything.
    if not HUD_UI_SCENE:IsShowing() then return false end
    -- Keep hover while a panel menu is open, even with the cursor outside the panel.
    if not ZO_Menu:IsHidden() then return true end

    -- Widest the gutter gets: BackdropGutterGap's step-out plus the box. The chrome
    -- button row sits in the same kind of strip above the top edge.
    local gutter = 16 + THEME.groupBtnSize
    local x, y = GetUIMousePosition()
    return x >= panel:GetLeft() - gutter and x <= panel:GetRight()
       and y >= panel:GetTop() - (16 + THEME.chromeBtnLift + THEME.chromeBtnPx)
       and y <= panel:GetBottom()
end

local function SetChromeHovered(on)
    if UI.chromeHovered == on then return end
    UI.chromeHovered = on
    if on then
        EM:RegisterForUpdate(CHROME_WATCH, CHROME_WATCH_MS, function()
            if not MouseIsOnChrome() then SetChromeHovered(false) end
        end)
    else
        EM:UnregisterForUpdate(CHROME_WATCH)
    end
    -- Refresh includes ApplyChromeVisibility; only needed when restore-strip height changes.
    if UI.HasHiddenGroups() then UI.Redraw() else UI.ApplyChromeVisibility() end
end

-- For where the panel loses the cursor with no event of its own: hiding, and the HUD
-- scene changes in Core.lua.
function UI.ClearChromeHover()
    SetChromeHovered(false)
end

-- Rechecked on layout and hover: journal indices shuffle.
function UI.RefreshLastQuestButton()
    local btn = UI.lastQuestBtn

    local index, name = CW.ResolveLastProgressedQuest()
    btn.questIndex = index
    btn.questName = name
    -- Already assisted: nothing left for a click to do.
    btn.isActive = index ~= nil and index == (CW.AssistedQuestIndex())
    return index ~= nil
end

function UI.ApplyChromeVisibility()
    -- A redraw under a stationary cursor must not drop the hovered button back to idle.
    local over = WM:GetMouseOverControl()
    SetChromeControl(UI.lock, true, ChromeButtonAlpha(UI.lock, over == UI.lock))
    SetChromeControl(UI.gear, true, ChromeButtonAlpha(UI.gear, over == UI.gear))
    local available = UI.RefreshLastQuestButton()
    SetChromeControl(UI.lastQuestBtn, available,
        ChromeButtonAlpha(UI.lastQuestBtn, over == UI.lastQuestBtn))
    SetChromeControl(UI.questPickerBtn, true,
        ChromeButtonAlpha(UI.questPickerBtn, over == UI.questPickerBtn))
    -- Group show/hide checkmarks — the only per-group control the panel has.
    for _, g in ipairs(UI.toggleGroups) do
        SetChromeControl(g.button, not g.button.groupUnavailable, 1)
    end
end

-- Alliance colour and iconography for keep rows.
--
-- Keep palette colors as {r,g,b,a} to avoid allocating a ZO_ColorDef per row per layout.

-- Siege faction icons use 100% font height, versus 120% for other AvA glyphs.
-- Only fielded alliances reach this; ALLIANCE_NONE has no icon (sharedtextures.lua).
local function AllianceGlyph(alliance)
    return zo_iconFormatInheritColor(ZO_GetLargeAllianceSymbolIcon(alliance), "100%", "100%")
end

-- GetAllianceColor returns neutral gray for ALLIANCE_NONE (defaultcolordefs.lua),
-- so unowned keeps use that color. Only an absent alliance returns nil here.
local function AllianceTint(alliance)
    if not alliance then return nil end
    local r, g, b, a = GetAllianceColor(alliance):UnpackRGBA()
    return { r, g, b, a }
end

-- `amount` is how far to push toward white.
local function Lighten(c, amount)
    return {
        c[1] + (1 - c[1]) * amount,
        c[2] + (1 - c[2]) * amount,
        c[3] + (1 - c[3]) * amount,
        c[4] or 1,
    }
end

-- `keep` is the fraction of brightness left standing.
local function Dim(c, keep)
    return { c[1] * keep, c[2] * keep, c[3] * keep, c[4] or 1 }
end

-- Toward `into` by `amount`, alpha untouched.
local function Blend(c, into, amount)
    return {
        c[1] + (into[1] - c[1]) * amount,
        c[2] + (into[2] - c[2]) * amount,
        c[3] + (into[3] - c[3]) * amount,
        c[4] or 1,
    }
end

-- Group show/hide checkmarks
--
-- Use the Cadwell pair: checkbox_checked.dds has no matching unchecked texture,
-- and ZO_CheckButton's empty unchecked state would look like a missing icon.
local function SetGroupToggleTextures(btn, shown)
    local base = shown and "EsoUI/Art/Cadwell/checkboxIcon_checked"
        or "EsoUI/Art/Cadwell/checkboxIcon_unchecked"
    btn:SetNormalTexture(base .. ".dds")
    btn:SetPressedTexture(base .. ".dds")
    btn:SetMouseOverTexture(base .. ".dds")
end

-- Groups default on unless UI.toggleGroups marks defaultHidden.
-- Keep defaults out of CW.defaults: ZO_SavedVars would restore cleared keys on load.
function UI.GroupShown(id)
    local saved = CW.SavedVars.groupHidden[id]
    if saved == nil then return not UI.groupById[id].defaultHidden end
    return not saved
end

-- Check in scan as well as visible: Refresh scans before testing visibility,
-- so disabled groups must skip the journal walk (#11).
local function GroupOn(id)
    return UI.GroupShown(id) and not CW.ExtraQuestGroupsHidden()
end

-- The caller refreshes. Same explicit `false` the checkmark handler writes: nil means
-- "never chosen".
function UI.ShowGroup(id)
    CW.SavedVars.groupHidden[id] = false
end

-- Step-out for anything anchored outside the panel edge: enough to clear the backdrop's
-- 4px overhang (UI.bg) when it is showing.
local function BackdropGutterGap()
    return (CW.SavedVars.backdropAlpha > 0 and 4 or 0) + 2
end

-- Center on the headline at y and clear groupUnavailable.
-- Groups whose layout never runs retain that flag and stay hidden.
local function PlaceGroupToggle(id, y, lineH)
    local g = UI.groupById[id]
    g.button.groupUnavailable = false
    SetGroupToggleTextures(g.button, true)
    g.button:ClearAnchors()
    g.button:SetAnchor(RIGHT, UI.panel, TOPLEFT, -BackdropGutterGap(),
        y + (lineH or THEME.groupBtnSize) / 2)
end

-- The chrome bar wears gamepad art: white, heavily outlined, and one state per icon where
-- the keyboard set is tan and ships _up/_over/_down. Every button state takes the one file.
local function SetButtonArt(btn, path)
    btn:SetNormalTexture(path)
    btn:SetPressedTexture(path)
    btn:SetMouseOverTexture(path)
end

-- 32px, where the keyboard lock is 16 stretched to the button.
local LOCK_ART = "EsoUI/Art/Miscellaneous/Gamepad/gp_icon_locked32.dds"
local UNLOCK_ART = "EsoUI/Art/Miscellaneous/Gamepad/gp_icon_unlocked32.dds"

-- Accept right-click too, matching the game's context menus.
local function IsMenuClick(button, upInside)
    return upInside and (button == MOUSE_BUTTON_INDEX_LEFT or button == MOUSE_BUTTON_INDEX_RIGHT)
end

local function CreateSubHeader(name)
    local label = WM:CreateControl(name, UI.panel, CT_LABEL)
    label:SetFont(THEME.headFont)
    label:SetColor(unpack(THEME.subHead))
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    label:SetDrawLevel(2)
    return label
end

-- Tome sub-group filters
-- Both Tome sub-groups use a dropdown for the same three named filter buckets.
local TOME_FILTERS = {
    { id = "incomplete", label = "Incomplete" },
    { id = "inProgress", label = "In-progress" },
    { id = "all",        label = "All" },
}

local function TomeFilterLabel(id)
    for _, f in ipairs(TOME_FILTERS) do
        if f.id == id then return f.label end
    end
    return TOME_FILTERS[1].label
end

-- Validated on every read: a saved id from another build must fall back to a real
-- bucket rather than leave the layout with nothing to draw.
function UI.TomeFilter(key)
    local saved = CW.SavedVars.tomeFilter[key]
    for _, f in ipairs(TOME_FILTERS) do
        if f.id == saved then return saved end
    end
    return TOME_FILTERS[1].id
end

local function SetTomeFilter(key, id)
    CW.SavedVars.tomeFilter[key] = id
    UI.Redraw()
end

local function ShowTomeFilterMenu(control, key)
    local current = UI.TomeFilter(key)
    ClearMenu()
    for _, f in ipairs(TOME_FILTERS) do
        -- Check-marked so the menu shows where you are, not just where you can go.
        -- Inherit-color so it tints with the menu's own text.
        local text = (f.id == current) and (CHECK_INHERIT .. " " .. f.label) or f.label
        AddMenuItem(text, function() SetTomeFilter(key, f.id) end)
    end
    ShowMenu(control)
end

local function CreateTomeFilter(key, groupId)
    local control = CreateSubHeader("CW_TomeFilter_" .. key)
    -- A control, not a heading: it shares the header's row and should not compete
    -- with the words it sits beside.
    control:SetFont(THEME.filterFont)
    control.groupId = groupId
    control:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    control:SetMouseEnabled(true)
    control:SetHandler("OnMouseUp", function(self, button, upInside)
        if IsMenuClick(button, upInside) then
            ShowTomeFilterMenu(self, key)
        end
    end)
    control:SetHandler("OnMouseEnter", function(self)
        self:SetColor(unpack(THEME.arrowHot))
    end)
    control:SetHandler("OnMouseExit", function(self)
        self:SetColor(unpack(self.restColor or THEME.subHead))
    end)
    return control
end

-- Quest menus
--
-- Share the five quest actions between panel titles and quest-picker rows.
-- LibCustomMenu provides submenus; stock ZO_Menu supports only flat lists.

-- BeamMeUp resolves friend/guild/group ports, falls back to paid wayshrines,
-- and reports unreachable zones. Omit the entry if its API is absent.
local function GetBMU()
    return (BMU and BMU.sc_porting and BMU.findExactQuestLocation) and BMU or nil
end

local function QuestZoneId(questIndex)
    local _, _, zoneIndex = GetJournalQuestLocationInfo(questIndex)
    return GetZoneId(zoneIndex)
end

-- findExactQuestLocation reads steps for the target delve/dungeon/sub-zone, beyond the
-- journal's filing zone; mirror BeamMeUp's portToTrackedQuestZone (core/List.lua:3513).
local function PortToQuest(questIndex)
    local bmu = GetBMU()
    bmu.sc_porting(bmu.findExactQuestLocation(questIndex))
end

-- `Submenu:AddItem` reads { label, callback, visible } off each.
function UI.QuestActionEntries(questIndex)
    local focused = CW.AssistedQuestIndex()
    local tracked = CW.IsQuestTracked(questIndex)

    local function act(fn)
        return function()
            fn()
            UI.Redraw()
        end
    end

    return {
        -- Hide Make Primary for the already-assisted quest.
        { label = CW.L.MAKE_PRIMARY_QUEST,
          visible = questIndex ~= focused,
          callback = act(function() CW.SetAssisted(questIndex) end) },
        -- Tracking unhides this initially hidden group so the new entry is visible.
        -- Untracking never re-hides it.
        { label = tracked and CW.L.UNTRACK_QUEST or CW.L.TRACK_QUEST,
          callback = act(function()
              CW.SetQuestTracked(questIndex, not tracked)
              if not tracked then UI.ShowGroup("trackedQuests") end
          end) },
        -- Use the client's language for the three base-game actions.
        { label = GetString(SI_QUEST_JOURNAL_SHOW_ON_MAP),
          callback = act(function() ZO_WorldMap_ShowQuestOnMap(questIndex) end) },
        -- Zone 0 leaves BeamMeUp no location to resolve; hide the entry.
        { label = CW.L.PORT_TO_QUEST,
          visible = GetBMU() ~= nil and QuestZoneId(questIndex) ~= 0,
          callback = act(function() PortToQuest(questIndex) end) },
        -- Omit Share while solo. In groups, keep it listed for unshareable quests;
        -- ShareQuestInteractive reports the reason.
        { label = GetString(SI_QUEST_JOURNAL_SHARE),
          visible = GetGroupSize() > 1,
          callback = act(function() CW.PromptQuestShare(questIndex) end) },
        -- Routes through the game's own confirmation dialog (CW.DropQuest).
        { label = GetString(SI_QUEST_JOURNAL_ABANDON),
          callback = act(function() CW.DropQuest(questIndex) end) },
    }
end

-- Menu for a single quest, opened from its title in the panel.
function UI.ShowQuestActionMenu(questIndex, anchor)
    ClearMenu()
    for _, e in ipairs(UI.QuestActionEntries(questIndex)) do
        if e.visible ~= false then AddCustomMenuItem(e.label, e.callback) end
    end
    ShowMenu(anchor)
end

-- Every quest in the journal, each with the same action flyout. Clicking the name makes
-- it primary, the common case; hovering opens the rest.
function UI.ShowQuestPickerMenu(anchor)
    -- The journal's own list, in its order -- zones, then quest types, then General -- and
    -- rebuilt by the journal on every quest change.
    local quests = QUEST_JOURNAL_MANAGER:GetQuestList()
    ClearMenu()
    if #quests == 0 then
        AddCustomMenuItem(CW.L.NO_JOURNAL_QUESTS, function() end)
        ShowMenu(anchor)
        return
    end
    local category
    for _, q in ipairs(quests) do
        if q.categoryName ~= category then
            -- The line closes the group above rather than underlining the one below.
            if category then AddCustomMenuItem(LibCustomMenu.DIVIDER) end
            category = q.categoryName
            -- Disabled rows still highlight on hover; force both colors gray and hide the highlight.
            AddCustomMenuItem(category, nil, MENU_ADD_OPTION_LABEL, nil, ZO_DISABLED_TEXT,
                ZO_DISABLED_TEXT, nil, nil, nil, function() ZO_MenuHighlight:SetHidden(true) end,
                nil, false)
        end
        local index = q.questIndex
        -- Check-marked when tracked, so the menu shows what is already on the panel; the
        -- rest are indented under their category instead.
        local label = zo_strformat(SI_QUEST_JOURNAL_QUEST_NAME_FORMAT, q.name)
        label = (CW.IsQuestTracked(index) and CHECK_INHERIT .. " " or "       ") .. label
        AddCustomSubMenuItem(label,
            function() return UI.QuestActionEntries(index) end,
            nil, nil, nil, nil,
            function()
                CW.SetAssisted(index)
                UI.Redraw()
            end)
    end
    ShowMenu(anchor)
end

-- Shared HUD widget plumbing
-- CW.hudWidgets registers independent frames for shared placement handling.
-- `tab` selects the CW.settingsTabs page allowed to preview each widget;
-- no tab means no preview. Restricting previews avoids overlapping stand-ins.
CW.hudWidgets = {}

function CW.RegisterHudWidget(setPlacementMode, applyVisibility, tab)
    CW.hudWidgets[#CW.hudWidgets + 1] =
        { setPlacementMode = setPlacementMode, applyVisibility = applyVisibility, tab = tab }
end

-- `tabKey` is the tab now on screen; nil places none, which is what closing the panel
-- and entering gameplay both do.
function CW.SetHudPlacementMode(on, tabKey)
    for _, w in ipairs(CW.hudWidgets) do
        w.setPlacementMode(on == true and w.tab ~= nil and w.tab == tabKey)
    end
end

-- Entering gameplay drops placement mode, so no preview is left on screen; leaving it
-- only re-evaluates visibility.
function CW.RefreshHudPlacement()
    for _, w in ipairs(CW.hudWidgets) do
        if CW.inGameplay then w.setPlacementMode(false) else w.applyVisibility() end
    end
end

function UI.ApplyWidgetPosition(frame, key)
    local p = CW.SavedVars[key]
    frame:ClearAnchors()
    frame:SetAnchor(p.point, GuiRoot, p.relativePoint, p.x, p.y)
end

function UI.SaveWidgetPosition(frame, key)
    local _, point, _, relativePoint, offsetX, offsetY = frame:GetAnchor(0)
    CW.SavedVars[key] = { point = point, relativePoint = relativePoint, x = offsetX, y = offsetY }
end

-- No edge texture or insets: an exact solid rectangle.
-- ZO_DefaultBackdrop's edge would consume pixels and misalign bars with text.
function UI.CreateSolidBar(name, parent, drawLevel)
    local bar = WM:CreateControl(name, parent, CT_BACKDROP)
    bar:SetEdgeTexture("", 1, 1, 0, 0)
    bar:SetInsets(0, 0, 0, 0)
    bar:SetEdgeColor(0, 0, 0, 0)
    bar:SetDrawLayer(DL_OVERLAY)
    bar:SetDrawLevel(drawLevel)
    return bar
end

-- Draggable only while the settings panel is open, so placement mode can never leave
-- one grabbing mouse input during gameplay.
function UI.SettingsPanelOpen()
    return CW.settingsOpen == true
end

-- Queue pop
-- The swell behind a block nobody has answered yet: an unanswered ready check, or a
-- campaign holding its confirmation window open.
local QUEUE_POP_MS = 380
local QUEUE_POP_ALPHA = 0.35   -- white; any denser and it swallows the text it is under

local function BuildQueuePop(panel)
    local bar = UI.CreateSolidBar("CW_QueuePop", panel, 1)
    bar:SetCenterColor(1, 1, 1, 1)
    -- Use the panel's default layer (background 0, dividers 1, labels 2).
    -- CreateSolidBar's HUD-widget DL_OVERLAY would cover the text.
    bar:SetDrawLayer(DL_CONTROLS)
    bar:SetAlpha(0)
    bar:SetHidden(true)
    UI.queuePop = bar

    local pulse = ANIMATION_MANAGER:CreateTimeline()
    pulse:SetPlaybackType(ANIMATION_PLAYBACK_LOOP, LOOP_INDEFINITELY)
    local grow = pulse:InsertAnimation(ANIMATION_SCALE, bar, 0)
    grow:SetScaleValues(1, 1.5)
    grow:SetDuration(QUEUE_POP_MS * 2)
    grow:SetEasingFunction(ZO_EaseOutQuadratic)
    local fade = pulse:InsertAnimation(ANIMATION_ALPHA, bar, 0)
    fade:SetAlphaValues(QUEUE_POP_ALPHA, 0)
    fade:SetDuration(QUEUE_POP_MS * 2)
    UI.queuePopPulse = pulse
end

function UI.StopQueuePop()
    if not UI.queuePopPulse:IsPlaying() then return end
    UI.queuePopPulse:Stop()
    UI.queuePop:SetHidden(true)
end

-- `on` is the scan's `urgent`: whichever block is still waiting on the player.
function UI.PlaceQueuePop(y, h, on)
    if not on then return UI.StopQueuePop() end
    local w = THEME.panelW - THEME.sideInset * 2
    -- Centre-anchored, so it swells around the block, not out of one corner.
    UI.queuePop:SetDimensions(w, h)
    UI.queuePop:ClearAnchors()
    UI.queuePop:SetAnchor(CENTER, UI.panel, TOPLEFT, THEME.sideInset + w / 2, y + h / 2)
    UI.queuePop:SetHidden(false)

    if UI.queuePopPulse:IsPlaying() then return end
    UI.queuePopPulse:PlayFromStart()
end

-- Build
function UI.Create()
    -- Before any control is created. This early call only computes THEME; the re-font
    -- pass is a no-op until UI.panel exists.
    UI.SyncTheme(false)

    local panel = WM:CreateTopLevelWindow("CW_Panel")
    panel:SetDimensions(THEME.panelW, 80)
    panel:SetMovable(not CW.SavedVars.pinned)
    panel:SetMouseEnabled(true)
    -- Clamp only while dragging: resizing a clamped panel near an edge moves it.
    -- TOPLEFT keeps the top fixed as sections grow downward.
    panel:SetClampedToScreen(false)
    UI.panel = panel
    UI.chromeHovered = false

    -- Built-in ZO_DefaultBackdrop renders on install without the restart a new .dds needs.
    -- Clear its preset anchor before positioning.
    local bg = WM:CreateControlFromVirtual("CW_BG", panel, "ZO_DefaultBackdrop")
    bg:ClearAnchors()
    bg:SetCenterColor(0, 0, 0, 1)
    bg:SetEdgeColor(0, 0, 0, 1)
    bg:SetAlpha(CW.SavedVars.backdropAlpha)
    bg:SetAnchor(TOPLEFT, panel, TOPLEFT, -4, -4)
    bg:SetAnchor(BOTTOMRIGHT, panel, BOTTOMRIGHT, 4, 4)
    bg:SetDrawLevel(0)
    UI.bg = bg

    -- Each layout owns its headers and dividers; section entries only route scans and drawing.
    UI.sections = {
        { id = "quests", layout = UI.LayoutQuestList,
          visible = function()
              -- In an Alliance War zone the quest section stays in full, whatever the
              -- instance-hiding setting says.
              if CW.PvpFocusMode() then return true end
              if not (CW.QuestContentHiddenInInstance()) then
                  return true
              end
              return CW.ShowActiveQuestInHiddenTracker() and CW.AssistedQuestIndex() ~= nil
          end },
        -- Only where these quests can be done, so ExtraQuestGroupsHidden does not apply.
        { id = "avaDailies", layout = UI.LayoutAvaDailies,
          scan = function()
              return CW.PvpFocusMode() and UI.GroupShown("avaDailies") and CW.ReadAvaDailies() or nil
          end,
          visible = function(dailies) return dailies ~= nil and dailies.count > 0 end },
        -- Replace repeatables below quests in Cyrodiil/IC; Battlegrounds use the docked native HUD.
        { id = "pvp", layout = UI.LayoutAva,
          visible = CW.PvpFocusMode },
        -- Open-field fights, under the keeps and above the history.
        { id = "battles", layout = UI.LayoutBattles,
          visible = CW.PvpFocusMode },
        -- Must stay AFTER both sections above: their layouts fill UI.pvpRecent.
        { id = "pvpRecent", layout = UI.LayoutRecentAction,
          visible = CW.PvpFocusMode },
        { id = "guildDailies", layout = UI.LayoutGuildDailies,
          scan = function() return GroupOn("guildDailies") and CW.ReadGuildDailies() or nil end,
          visible = function(dailies)
              return GroupOn("guildDailies") and dailies.count > 0
          end },
        -- Like guild dailies, show only while an accepted quest remains.
        { id = "zoneDailies", layout = UI.LayoutZoneDailies,
          scan = function() return GroupOn("zoneDailies") and CW.ReadZoneDailies() or nil end,
          visible = function(dailies)
              return GroupOn("zoneDailies") and dailies.count > 0
          end },
        { id = "undaunted", layout = UI.LayoutUndaunted,
          scan = function() return GroupOn("undaunted") and CW.ReadPledges() or nil end,
          visible = function(pledges)
              return GroupOn("undaunted") and pledges ~= nil
                  and pledges.hasCharacterActivity == true
          end },
        -- Keep empty BG dailies visible as a pickup reminder.
        { id = "battleground", layout = UI.LayoutBattleground,
          scan = function() return GroupOn("battleground") and CW.ReadBattlegroundDailies() or nil end,
          visible = function(bg) return GroupOn("battleground") and bg ~= nil end },
        -- Unchecking both sub-groups leaves the section with nothing to draw, so it goes
        -- away entirely; both boxes wait in the restore strip.
        { id = "tomes", layout = UI.LayoutTomeList,
          visible = function() return GroupOn("tomeSeasonal") or GroupOn("tomeWeekly") end },
        { id = "house", layout = UI.LayoutHouse,
          scan = CW.ReadHouse,
          visible = function(house) return house ~= nil end },
        { id = "queue", layout = UI.LayoutQueue,
          scan = CW.ReadQueue,
          visible = function(queues) return queues ~= nil end },
    }

    -- Restore-strip order. Section groups use visible gates; Tome sub-groups
    -- are skipped by UI.LayoutTomeList.
    UI.toggleGroups = {
        -- Default-hidden: the list starts empty until the player chooses quests.
        { id = "trackedQuests", defaultHidden = true,
          label = function() return CW.L.TRACKED_QUESTS end },
        { id = "undaunted",    label = function() return CW.L.UNDAUNTED     end },
        { id = "guildDailies", label = function() return CW.L.GUILD_DAILIES end },
        { id = "zoneDailies",  label = function() return CW.L.ZONE_DAILIES  end },
        { id = "battleground", label = function() return CW.L.BATTLEGROUND        end },
        { id = "avaDailies",   label = function() return CW.L.AVA_DAILIES   end },
        -- Prefix Tomes labels so they remain clear away from their header in the restore strip.
        { id = "tomeSeasonal", label = function()
            return CW.L.TOME_HEADER .. " " .. CW.L.TOME_SEASONAL end },
        { id = "tomeWeekly",   label = function()
            return CW.L.TOME_HEADER .. " " .. CW.L.TOME_WEEKLY end },
    }
    -- Build this map before buttons ask UI.GroupShown for defaultHidden.
    UI.groupById = {}
    for _, g in ipairs(UI.toggleGroups) do UI.groupById[g.id] = g end
    for _, g in ipairs(UI.toggleGroups) do
        local btn = WM:CreateControl("CW_GroupBtn_" .. g.id, panel, CT_BUTTON)
        btn:SetDimensions(THEME.groupBtnSize, THEME.groupBtnSize)
        btn:SetMouseEnabled(true)
        btn:SetDrawLevel(3)
        -- Unavailable until a layout places it; see PlaceGroupToggle.
        btn.groupUnavailable = true
        SetGroupToggleTextures(btn, UI.GroupShown(g.id))
        btn:SetHandler("OnClicked", function()
            local want = UI.GroupShown(g.id)   -- shown -> hide it
            -- An explicit boolean, not nil: nil means "never chosen", which for a
            -- default-hidden group reads back as hidden.
            CW.SavedVars.groupHidden[g.id] = want
            SetGroupToggleTextures(btn, not want)
            UI.Redraw()
        end)
        btn:SetHandler("OnMouseEnter", function(self)
            InitializeTooltip(InformationTooltip, self, BOTTOMLEFT, 0, -2)
            SetTooltipText(InformationTooltip, g.label())
        end)
        btn:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip) end)
        g.button = btn
    end

    UI.tomeFilters = {
        seasonal = CreateTomeFilter("seasonal", "tomeSeasonal"),
        weekly = CreateTomeFilter("weekly", "tomeWeekly"),
    }
    UI.groupHeaders = {
        tracked = CreateSubHeader("CW_QuestHdr_tracked"),
        keeps = CreateSubHeader("CW_PvpHdr_keeps"),
        battles = CreateSubHeader("CW_PvpHdr_battles"),
        recent = CreateSubHeader("CW_PvpHdr_recent"),
    }
    UI.groupHeaders.tracked.groupId = "trackedQuests"

    -- keepId -> { t = when it joined the list (ms), name, owner } (see UI.LayoutAva).
    UI.pvpSeen = {}
    -- The same shape for the open-field battles, keyed by CW.ReadBattles's synthetic
    -- key: a kill location has no id of its own.
    UI.battleSeen = {}
    -- Both of the above for things that have LEFT their list, where t is when it
    -- dropped off.
    UI.pvpRecent = {}

    local lock = WM:CreateControl("CW_Lock", panel, CT_BUTTON)
    lock:SetDimensions(THEME.chromeBtnPx, THEME.chromeBtnPx)
    lock:SetMouseEnabled(true)
    -- Footer labels sit at level 2; keep buttons above them for painting and hit tests.
    lock:SetDrawLevel(3)
    lock:SetHandler("OnClicked", function()
        CW.SavedVars.pinned = not CW.SavedVars.pinned
        UI.SyncLock()
    end)
    lock:SetHandler("OnMouseEnter", function(self)
        SetChromeButtonHover(self, true)
        InitializeTooltip(InformationTooltip, self, BOTTOMLEFT, 0, -2)
        SetTooltipText(InformationTooltip, CW.L[CW.SavedVars.pinned and "PANEL_UNLOCK" or "PANEL_LOCK"])
    end)
    lock:SetHandler("OnMouseExit", function(self)
        SetChromeButtonHover(self, false)
        ClearTooltip(InformationTooltip)
    end)
    UI.lock = lock

    -- Gear jumps to our own LAM panel, not the add-on menu root.
    local gear = WM:CreateControl("CW_Gear", panel, CT_BUTTON)
    gear:SetDimensions(THEME.chromeBtnPx, THEME.chromeBtnPx)
    gear:SetMouseEnabled(true)
    gear:SetDrawLevel(3)
    -- The gamepad main menu's Settings cog.
    SetButtonArt(gear, "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_settings.dds")
    gear:SetHandler("OnClicked", function() UI.ShowSettings() end)
    gear:SetHandler("OnMouseEnter", function(self)
        SetChromeButtonHover(self, true)
        InitializeTooltip(InformationTooltip, self, BOTTOMLEFT, 0, -2)
        SetTooltipText(InformationTooltip, CW.L.OPEN_SETTINGS)
    end)
    gear:SetHandler("OnMouseExit", function(self)
        SetChromeButtonHover(self, false)
        ClearTooltip(InformationTooltip)
    end)
    UI.gear = gear

    -- Re-assists the last quest that progressed (accepting one doesn't count).
    -- Grayed, not hidden, when already assisted so it doesn't vanish under the cursor.
    local lastQuest = WM:CreateControl("CW_LastQuest", panel, CT_BUTTON)
    lastQuest:SetDimensions(THEME.chromeBtnPx, THEME.chromeBtnPx)
    lastQuest:SetMouseEnabled(true)
    lastQuest:SetDrawLevel(3)
    SetButtonArt(lastQuest, "EsoUI/Art/Miscellaneous/Gamepad/spinner_arrow_right_up.dds")
    lastQuest:SetHandler("OnClicked", function(self)
        if self.isActive then return end
        if self.questIndex then CW.SetAssisted(self.questIndex) end
        -- Active quest and button state both changed.
        UI.Redraw()
    end)
    lastQuest:SetHandler("OnMouseEnter", function(self)
        -- On hover: the journal can have changed since the last layout.
        if not UI.RefreshLastQuestButton() then return end
        SetChromeButtonHover(self, true)
        InitializeTooltip(InformationTooltip, self, BOTTOMLEFT, 0, -2)
        if self.isActive then
            SetTooltipText(InformationTooltip,
                string.format('%s: "%s"', CW.L.ALREADY_ACTIVE_QUEST, self.questName))
            return
        end
        SetTooltipText(InformationTooltip,
            string.format('%s "%s"', CW.L.SET_ACTIVE_QUEST, self.questName))
    end)
    lastQuest:SetHandler("OnMouseExit", function(self)
        SetChromeButtonHover(self, false)
        ClearTooltip(InformationTooltip)
    end)
    lastQuest:SetHidden(true)
    UI.lastQuestBtn = lastQuest

    -- Quest picker with the same action flyouts as titles; also adds quests to the tracked list.
    local picker = WM:CreateControl("CW_QuestPicker", panel, CT_BUTTON)
    picker:SetDimensions(THEME.chromeBtnPx, THEME.chromeBtnPx)
    picker:SetMouseEnabled(true)
    picker:SetDrawLevel(3)
    -- Gamepad Quests matches the Settings cog; the tracked-quest icon has a 50% thicker outline.
    SetButtonArt(picker, "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_quests.dds")
    picker:SetHandler("OnClicked", function(self)
        -- The tooltip would sit on top of the menu about to open.
        ClearTooltip(InformationTooltip)
        UI.ShowQuestPickerMenu(self)
    end)
    picker:SetHandler("OnMouseEnter", function(self)
        SetChromeButtonHover(self, true)
        InitializeTooltip(InformationTooltip, self, BOTTOMLEFT, 0, -2)
        SetTooltipText(InformationTooltip, CW.L.ALL_QUESTS)
    end)
    picker:SetHandler("OnMouseExit", function(self)
        SetChromeButtonHover(self, false)
        ClearTooltip(InformationTooltip)
    end)
    UI.questPickerBtn = picker

    BuildQueuePop(panel)

    UI.rows  = {}
    UI.icons = {}
    UI.dividers = {}

    -- Text height lags SetText by a frame; StampRow measures with a separate, hidden control.
    local measure = WM:CreateControl("CW_Measure", panel, CT_LABEL)
    measure:SetFont(THEME.bodyFont)
    measure:SetMaxLineCount(0)
    measure:SetAlpha(0)
    measure:SetMouseEnabled(false)
    measure:SetDrawLevel(0)
    measure:SetAnchor(TOPLEFT, panel, TOPLEFT, 0, 0)
    UI.measure = measure

    -- Clamp during drag only to avoid release snaps and resize-induced movement.
    panel:SetHandler("OnMouseEnter", function() SetChromeHovered(true) end)
    panel:SetHandler("OnMoveStart", function() panel:SetClampedToScreen(true) end)
    panel:SetHandler("OnMoveStop", function()
        UI.StoreAnchor()
        panel:SetClampedToScreen(false)
    end)
    UI.SyncAnchor()
    UI.SyncLock()
    UI.ApplyChromeVisibility()
    UI.BuildMountSprintIcon()
    UI.BuildOffBalanceTracker()
    UI.BuildHealthAlert()
    UI.BuildIncomingAlert()
    UI.BuildCcImmunity()
    UI.BuildNegateAlert()
    UI.BuildPoisonAlert()
    UI.BuildLaStats()
    UI.BuildGcdAlert()
    UI.BuildExpireReminder()
    UI.SetPanelHidden(CW.SavedVars.stowed)
end

-- Pools
local rowsUsed, iconsUsed, usedDividers = 0, 0, 0

-- Lets DrawDivider tell "above a header" from "at the very top of the panel", where
-- there is nothing to divide from.
local contentTop = 0

local function TakeRow()
    rowsUsed = rowsUsed + 1
    local row = UI.rows[rowsUsed]
    -- Translate animations retain their offsets; stop them and clear the stamp so
    -- SetAnchor runs even when the row returns to the same slot.
    if row and row.slide and row.slide:IsPlaying() then
        row.slide:Stop()
        row.stamp = nil
    end
    if not row then
        row = WM:CreateControl("CW_Row" .. rowsUsed, UI.panel, CT_LABEL)
        row:SetMaxLineCount(1)
        row:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
        row:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        row:SetDrawLevel(2)
        -- Titles open the action menu, with Make Primary first.
        row:SetHandler("OnMouseUp", function(self, button, upInside)
            if IsMenuClick(button, upInside) and self.questIndex then
                UI.ShowQuestActionMenu(self.questIndex, self)
            end
        end)
        -- Both paint outside StampRow, so the stamp no longer describes the row.
        row:SetHandler("OnMouseEnter", function(self)
            if self.questIndex and self.hoverColor then
                self:SetColor(unpack(self.hoverColor))
                self.stamp = nil
            end
        end)
        row:SetHandler("OnMouseExit", function(self)
            if self.baseColor then
                self:SetColor(unpack(self.baseColor))
                self.stamp = nil
            end
        end)
        UI.rows[rowsUsed] = row
    end
    row:SetHidden(false)
    row.questIndex = nil
    -- Per-row: a pooled row keeps the hover it was handed last time.
    row.baseColor, row.hoverColor = nil, nil
    row:SetFont(THEME.bodyFont)          -- reset the font too (the keep age row shrinks it)
    row:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    row:SetMaxLineCount(1)              -- one line again; only placeholders ask to wrap
    row:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    row:SetMouseEnabled(false)
    return row
end

-- Clear the stamp for manual row writes so the next StampRow reapplies every field.
local function TakeRawRow()
    local row = TakeRow()
    row.stamp = nil
    return row
end

-- CT_BACKDROP, not a texture: a solid fill needs no art, and a bundled .dds would not
-- register until the client was restarted.
local function TakeDivider()
    usedDividers = usedDividers + 1
    local line = UI.dividers[usedDividers]
    if not line then
        -- With no edge texture, a backdrop draws its centre fill and nothing else.
        line = WM:CreateControl("CW_Divider" .. usedDividers, UI.panel, CT_BACKDROP)
        line:SetDrawLevel(1)
        UI.dividers[usedDividers] = line
    end
    -- Opacity on the control, not the centre colour: a backdrop's centre alpha is not
    -- reliably honoured, control alpha always is.
    local c = THEME.rule
    line:SetCenterColor(c[1], c[2], c[3], 1)
    line:SetAlpha(c[4] or 1)
    line:SetHidden(false)
    return line
end

-- Returns the y the header starts at, so a height of 0 costs nothing: no control, no
-- gap, no spacing change.
local function DrawDivider(y)
    local h = THEME.ruleH
    if h <= 0 or THEME.underline or y <= contentTop then return y end
    y = y + THEME.dividerTop
    local line = TakeDivider()
    -- TOP CENTRE, so it stays centred at any width and a width over 100% overhangs.
    -- Nothing clips it: only CT_SCROLL clips its children, and the panel is a TLC.
    line:SetDimensions((THEME.panelW - THEME.sideInset * 2) * THEME.dividerPct, h)
    line:ClearAnchors()
    line:SetAnchor(TOP, UI.panel, TOP, 0, y)
    return y + h + THEME.dividerGap
end

-- Measure with the header label, then restore its text; the shared measure uses the row font.
local function LabelTextWidth(label, text)
    local had = label:GetText()
    label:SetText(text)
    local w = math.ceil(label:GetTextWidth())
    label:SetText(had)
    return w
end

-- Underline at header-end y; return the next y. `left` is the header's x.
-- Measure the label to avoid the Tome filter; `title` and `prefix` exclude
-- inline icons and the Ready for turn-in tail.
-- `force` underlines guild-daily zones independently of header underline mode.
local function DrawUnderline(label, left, y, title, prefix, force)
    local h = THEME.ruleH
    if h <= 0 or not (THEME.underline or force) then return y end
    if prefix then left = left + LabelTextWidth(label, prefix) end
    local w = title and LabelTextWidth(label, title) or math.ceil(label:GetTextWidth())
    -- A title long enough to be ellipsized still measures full width, which would run
    -- the rule off the panel.
    w = math.min(w, THEME.panelW - THEME.sideInset - left)
    local line = TakeDivider()
    line:SetDimensions(w, h)
    line:ClearAnchors()
    -- 2px above the row's bottom edge, closer to the text; spacing below is unchanged.
    line:SetAnchor(TOPLEFT, UI.panel, TOPLEFT, left, y - 2)
    return y + h + THEME.dividerGap
end

local function TakeIcon(size)
    iconsUsed = iconsUsed + 1
    local icon = UI.icons[iconsUsed]
    if not icon then
        icon = WM:CreateControl("CW_Icon" .. iconsUsed, UI.panel, CT_TEXTURE)
        icon:SetDrawLevel(2)
        UI.icons[iconsUsed] = icon
    end
    -- Pooled and reused at different sizes across sections, so the size is set on every
    -- acquire, not once at creation.
    icon:SetDimensions(size, size)
    icon:SetHidden(false)
    return icon
end

-- Each of these lays out one section and hands back the y it stopped at.


-- Use the persistent measure label: same-frame GetTextHeight on a shown row is unreliable.
-- Cache synchronous text layouts; SyncTheme invalidates measurements when fonts change.
local wrappedHeights = {}
local function WrappedHeight(text, width, font)
    local m = UI.measure
    local key = (font or THEME.bodyFont) .. "\031" .. width .. "\031" .. text
    local cached = wrappedHeights[key]
    if cached then return cached end

    m:SetWidth(width)
    if font then m:SetFont(font) end
    m:SetText(text)
    local h = m:GetTextHeight()
    if font then m:SetFont(THEME.bodyFont) end
    h = h < THEME.minWrappedH and THEME.minWrappedH or math.ceil(h)
    wrappedHeights[key] = h
    return h
end

-- Inline icons included. The measure control is given room not to wrap, so the width is
-- the text's own, not the column's.
local function MeasureTextWidth(text)
    local m = UI.measure
    m:SetWidth(4096)
    m:SetText(text)
    return math.ceil(m:GetTextWidth())
end

-- Stamp control state to skip unchanged setters and their layout cost.
-- Manual writes must use TakeRawRow; SyncTheme clears all stamps.
local function StampRow(row, text, color, w, h, x, y)
    local s = row.stamp
    if not s then s = {}; row.stamp = s end
    if s.w ~= w or s.h ~= h then
        row:SetDimensions(w, h)
        s.w, s.h = w, h
    end
    if s.color ~= color then
        row:SetColor(unpack(color))
        s.color = color
    end
    row.baseColor = color
    if s.text ~= text then
        row:SetText(text)
        s.text = text
    end
    if s.x ~= x or s.y ~= y then
        row:ClearAnchors()
        row:SetAnchor(TOPLEFT, UI.panel, TOPLEFT, x, y)
        s.x, s.y = x, y
    end
end

-- `indent` is where the text starts; the row runs from there to the panel edge. A
-- wrapping row grows to fit but is never shorter than `minH`; a plain one is that tall.
local function DrawRow(text, color, y, indent, minH, wrap)
    local row = TakeRow()
    -- The backdrop is anchored 14px beyond the edge on every side, so a row clears the
    -- frame without a margin of its own.
    local w = THEME.panelW - indent
    local h = minH
    if wrap then
        row:SetMaxLineCount(0)
        h = math.max(WrappedHeight(text, w), minH)
    end
    StampRow(row, text, color, w, h, indent, y)
    return row
end

-- Separate glyph and text columns keep wrapped lines aligned with text.
-- Use one width for every glyph; the availability marker is widest.
local leadW, leadFont
local function LeadWidth()
    if leadFont ~= THEME.bodyFont then
        leadW = math.max(MeasureTextWidth(BULLET .. " "), MeasureTextWidth(CHECK .. " "),
            MeasureTextWidth(AVAILABLE_INHERIT .. " ")) - 2
        leadFont = THEME.bodyFont
    end
    return leadW
end

-- Return the row and text x: at the margin for empty `lead`, past the glyph otherwise.
local function DrawLedRow(lead, text, color, y, indent, minH)
    if lead == "" then return DrawRow(text, color, y, indent, minH, true), indent end
    local w = LeadWidth()
    local row = DrawRow(text, color, y, indent + w, minH, true)
    -- After the text row, so the glyph is not the control a later resize catches.
    StampRow(TakeRow(), lead, color, w, minH, indent, y)
    return row, indent + w
end

-- Extract the API-matching count from condition text ("Gather Supplies: 2/7")
-- into a separately colored trailing "(2/7)"; leave other wording intact.
-- Use byte ranges: the live separator is a non-breaking space (UTF-8 194 160),
-- whose %w/%s/%p classification varies by client locale.
local COUNT_TAIL = "[^0-9A-Za-z]*([0-9]+)[^0-9A-Za-z]+([0-9]+)[^0-9A-Za-z]*$"

-- What the native tracker heads its two side-line groups with.
local SIDE_STEP_HEADER = {
    [QUEST_STEP_VISIBILITY_OPTIONAL] = GetString(SI_QUEST_OPTIONAL_STEPS_DESCRIPTION),
    [QUEST_STEP_VISIBILITY_HINT]     = GetString(SI_QUEST_HINT_STEP_HEADER),
}

local function CondText(cond, p)
    if (cond.max or 0) <= 1 then return cond.text end
    -- Only when the pair is the count the API reported, so "Reach Rank 2/7 Camp" and a
    -- condition worded any other way keep their numbers.
    local head = cond.text:gsub(COUNT_TAIL, function(a, b)
        return (tonumber(a) == cond.cur and tonumber(b) == cond.max) and "" or nil
    end)
    return string.format("%s (|c%s%d/%d|r)", head, HexOf(p.count), cond.cur, cond.max)
end

-- Return next y and row; solo conditions omit bullets but retain status checkmarks.
local function DrawCond(cond, p, y, solo)
    local color, lead, text
    if cond.complete then
        color, lead, text = p.finished, CHECK, CondText(cond, p)
    else
        color, lead, text = p.body, solo and "" or GreyBullet(), CondText(cond, p)
    end
    local row = DrawLedRow(lead, text, color, y, SectionTextLeft(), THEME.objRow)
    return y + row:GetHeight(), row
end

-- Type icon, clickable title and objectives; return height used.
-- List position identifies the primary quest, so all quests share colors.
local function DrawQuestBlock(quest, y)
    local startY = y
    local pal = THEME.active

    -- Blended rather than replaced, so the title keeps its own colour and hover.
    local titleColor = quest.recurs and Blend(pal.title, THEME.recurring, 0.65) or pal.title

    -- Icons share a pool with section icons, so clear any tint they left.
    local path = CW.GetQuestIcon(quest)
    local icon = TakeIcon(IconPx(path))
    icon:SetTexture(path)
    icon:SetAlpha(1)
    icon:SetColor(1, 1, 1, 1)
    -- Half a title row down, so icon and title stay level whatever their sizes.
    icon:ClearAnchors()
    icon:SetAnchor(LEFT, UI.panel, TOPLEFT, THEME.sideInset, y + THEME.titleRow / 2)

    local title = TakeRawRow()
    title:SetFont(THEME.headFont)
    title:SetMaxLineCount(0)
    title:SetColor(unpack(titleColor))
    title.baseColor = titleColor
    title.hoverColor = THEME.arrowHot
    title.questIndex = quest.index
    title:SetMouseEnabled(true)
    title:SetText(quest.name)

    -- No action buttons: the title opens a menu with all five (UI.ShowQuestActionMenu),
    -- so it gets the full width.
    local titleW = THEME.panelW - THEME.sideInset * 2 - THEME.questIconPx - THEME.iconSpace
    -- Measured in the title's own font, which the shared measure label does not wear.
    local titleH = math.max(THEME.titleRow,
        WrappedHeight(quest.name, titleW, THEME.headFont))
    title:SetDimensions(titleW, titleH)
    title:ClearAnchors()
    local titleLeft = THEME.sideInset + THEME.questIconPx + THEME.iconSpace
    title:SetAnchor(TOPLEFT, UI.panel, TOPLEFT, titleLeft, y)

    y = y + titleH
    -- The assisted quest heads the panel with no sub-header, so in underline mode its
    -- title is the section's header. The tracked list below has a real one.
    if quest.focused then y = DrawUnderline(title, titleLeft, y) end

    local rows = 0
    for _, step in ipairs(quest.steps) do rows = rows + #step.conds end
    local heading
    for _, step in ipairs(quest.steps) do
        -- The scan groups the side lines after the main step, so each group's header is
        -- due the first time its visibility turns up.
        if step.visibility ~= heading then
            heading = step.visibility
            y = y + DrawRow(SIDE_STEP_HEADER[heading], THEME.muted.body, y,
                SectionTextLeft(), THEME.objRow):GetHeight()
        end
        if step.choice then
            y = y + DrawRow(GetString(SI_QUEST_OR_DESCRIPTION), THEME.muted.body, y,
                SectionTextLeft(), THEME.objRow):GetHeight()
        end
        for _, cond in ipairs(step.conds) do
            local condRow
            y, condRow = DrawCond(cond, pal, y, rows == 1)
            -- Objectives belong to the title's block, so the whole entry opens the menu.
            condRow.questIndex = quest.index
            condRow:SetMouseEnabled(true)
        end
    end

    return y - startY
end

-- The empty-state line for a section. Wraps as far as the text needs.
local function DrawPlaceholder(text, y)
    return y + DrawRow(text, THEME.empty, y, THEME.sideInset, 0, true):GetHeight()
end

-- In the text column the rows use, with no icon of its own.
local function DrawTomeMessage(text, y)
    return y + DrawRow(text, THEME.empty, y, SectionTextLeft(), THEME.objRow, true):GetHeight()
end

-- Align rows under the headline's title; its shared type icon needs no repetition.
local function DrawTomeRow(t, y, solo)
    local color = t.complete and THEME.active.finished or THEME.active.body
    local lead, text = solo and "" or GreyBullet(), t.text
    if t.complete then
        lead = CHECK
    elseif t.max > 1 then
        -- Appended, not lifted out: unlike a quest condition the activity name carries
        -- no count of its own.
        text = string.format("%s (|c%s%d/%d|r)", t.text,
            HexOf(THEME.active.count), t.cur, t.max)
    end
    -- The Tome Points this challenge grants.
    if t.reward > 0 then
        text = string.format("%s  +%d", text, t.reward)
    end
    return DrawLedRow(lead, text, color, y, SectionTextLeft(), THEME.objRow):GetHeight()
end

-- Show recent claim receipts under their sub-group while CW.RecentTomeClaims retains them.
-- Gray without a leading icon, like PvP history.
local function DrawTomeClaimRow(e, y)
    -- Say "claimed": a checkmark also appears on finished challenges whose reward is unclaimed.
    local text = string.format("%s (%s) %s", CHECK_INHERIT, CW.L.TOME_CLAIMED, e.name)
    if e.reward > 0 then
        text = string.format("%s  +%d", text, e.reward)
    end
    return DrawRow(text, THEME.empty, y, SectionTextLeft(), THEME.objRow, true):GetHeight()
end

-- Called with nonempty lists; renderFn returns each item's height.
local function LayoutGroup(header, label, items, gap, y, renderFn)
    y = DrawDivider(y)
    header:SetHidden(false)
    header:SetText(label)
    header:ClearAnchors()
    header:SetAnchor(TOPLEFT, UI.panel, TOPLEFT, THEME.sideInset, y)
    header:SetHeight(THEME.titleRow)
    if header.groupId then PlaceGroupToggle(header.groupId, y, THEME.titleRow) end
    y = DrawUnderline(header, THEME.sideInset, y + THEME.titleRow)

    for _, item in ipairs(items) do
        y = y + renderFn(item, y) + gap
    end
    return y - gap
end

local function CountCompleted(items)
    local done = 0
    for _, item in ipairs(items) do
        if item.complete then done = done + 1 end
    end
    return done, #items
end

-- `groupId` places the gutter checkmark beside the headline icon.
-- `title` / `prefix` keep the underline off Ready for turn-in tails and availability markers.
local function DrawSectionIcon(iconPath, y, tint, groupId, text, title, prefix)
    y = DrawDivider(y)
    local size = IconPx(iconPath)
    local lineH = SectionLineH()
    if groupId then PlaceGroupToggle(groupId, y, lineH) end
    local icon = TakeIcon(size)
    icon:SetTexture(iconPath)
    if tint then
        icon:SetColor(unpack(tint))
    else
        icon:SetColor(1, 1, 1, 1)
    end
    icon:SetAlpha(1)
    icon:ClearAnchors()
    icon:SetAnchor(LEFT, UI.panel, TOPLEFT, THEME.sideInset, y + lineH / 2)

    local left = SectionTextLeft()
    local status = DrawRow(text, THEME.active.body, y, left, lineH)
    status:SetFont(THEME.headFont)
    return DrawUnderline(status, left, y + lineH, title, prefix), y
end

-- Seasonal/Weekly headline, filter and matching challenges.
-- `key` selects the saved filter and empty-list noun; header color is per sub-group.
local function LayoutFilteredTomes(control, key, labelText, list, color, y, lastGroup)
    if #list == 0 then return y end

    -- Every unfinished challenge; only the started ones (any progress or a claim already
    -- taken); the lot.
    local filter = UI.TomeFilter(key)
    local rows = list
    if filter ~= "all" then
        rows = {}
        for _, t in ipairs(list) do
            if not t.complete then
                if filter == "incomplete"
                or t.cur > 0 or t.claimed > 0 then
                    rows[#rows + 1] = t
                end
            end
        end
    end

    local headerY
    y, headerY = DrawSectionIcon(key == "seasonal" and THEME.tomeSeasonalIcon or THEME.tomeWeeklyIcon,
        y, color, control.groupId, ColorText(color, labelText), labelText)
    local lineH = SectionLineH()
    control:SetHidden(false)
    control:SetText(TomeFilterLabel(filter) .. " " .. DOWN_ARROW)
    control:ClearAnchors()
    control:SetAnchor(RIGHT, UI.panel, TOPRIGHT, -THEME.sideInset, headerY + lineH / 2)
    control:SetDimensions(116, lineH)
    control.restColor = color
    control:SetColor(unpack(color))

    -- Drawn regardless of the filter: under "incomplete", the default, a challenge
    -- vanishes the instant it is claimed and the receipt is the only trace left.
    local claims = CW.RecentTomeClaims(key == "seasonal")

    if #rows == 0 then
        -- "all" cannot land here: an empty list returned above.
        if filter == "inProgress" then
            y = DrawTomeMessage("No " .. key .. " challenges in progress", y)
        else
            y = DrawTomeMessage("All " .. key .. " challenges complete", y)
        end
    end

    for _, t in ipairs(rows) do
        y = y + DrawTomeRow(t, y, #rows == 1)
    end
    for _, e in ipairs(claims) do
        y = y + DrawTomeClaimRow(e, y)
    end
    return lastGroup and y or (y + THEME.subGroupSpace)
end

-- Slide in newly attacked friendly keeps; cache the timeline per pooled row.
-- x,y are the row's anchor offsets: ANIMATION_TRANSLATE uses absolute offsets,
-- so the slide must end at that position.
local PVP_INDENT = THEME.sideInset + THEME.subRowIndent
local SLIDE_DISTANCE, SLIDE_MS = 48, 1000
-- How long a keep or battle stays in Recent action after it goes quiet, and the most
-- entries that section draws.
local RECENT_MS, RECENT_MAX = 5 * 60 * 1000, 10
local function SlideIn(control, x, y)
    if not control.slide then
        local anim, timeline = CreateSimpleAnimation(ANIMATION_TRANSLATE, control, 0)
        anim:SetAnchorIndex(0)
        anim:SetDuration(SLIDE_MS)
        anim:SetEasingFunction(ZO_EaseOutQuintic)
        control.slide, control.slideAnim = timeline, anim
    end
    control.slideAnim:SetTranslateOffsets(x + SLIDE_DISTANCE, y, x, y)
    control.slide:PlayFromStart()
end

-- "(3m ago)", right-aligned against the panel's right padding. Grey brackets around
-- white in the live sections, all grey in the history one.
local function DrawAge(ageMin, y, allGrey, color)
    if ageMin < 1 then return end
    local dim = HexOf(THEME.empty)
    local text = string.format(CW.L.KEEP_AGE, ageMin)
    local age = TakeRawRow()
    age:SetFont(THEME.keepAgeFont)
    age:SetHeight(THEME.titleRow)
    age:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    age:SetColor(unpack(color))
    age.baseColor = color
    age:SetText(allGrey and string.format("(%s)", text)
        or string.format("|c%s(|r|cffffff%s|r|c%s)|r", dim, text, dim))
    age:SetWidth(THEME.panelW - THEME.sideInset * 2)
    age:ClearAnchors()
    age:SetAnchor(TOPRIGHT, UI.panel, TOPRIGHT, -THEME.sideInset, y)
    return age
end

-- Text on the left at `x`, the age right-aligned on the same line, both sliding in
-- together when the row announces itself. Keeps and battles differ only in the text.
local function DrawPvpLine(text, color, x, y, ageMin, alert)
    local row = DrawRow(text, color, y, x, THEME.titleRow)
    if alert then SlideIn(row, x, y) end
    local age = DrawAge(ageMin, y, false, color)
    if age and alert then SlideIn(age, -THEME.sideInset, y) end
    return row
end

-- Preserve live ages, retire missing entries with a fresh clock, and restore returning ones.
-- Never pass a nil scan; see CW.ReadBattles.
local function ReconcileSeen(prev, rows, now, keyOf, retire)
    local seen = {}
    for _, r in ipairs(rows) do
        local key = keyOf(r)
        local was = prev[key]
        seen[key] = was or { t = now }
        r.ageMin = math.floor((now - ((was and was.t) or now)) / 60000)
        r.wasNew = (was == nil)
        UI.pvpRecent[key] = nil
    end
    for key in pairs(prev) do
        if not seen[key] then UI.pvpRecent[key] = retire(key, now) end
    end
    for key, e in pairs(UI.pvpRecent) do
        if now - e.t > RECENT_MS then UI.pvpRecent[key] = nil end
    end
    return seen
end

-- Glyph shape identifies resource/keep type; inherited alliance tint identifies ownership.
-- Art saturation is below 0.15 (dev/icon-scan.py), suitable for tinting.
local KEEP_GLYPH = {
    [KEEPTYPE_KEEP]    = "EsoUI/Art/Icons/mapKey/mapKey_keep.dds",
    [KEEPTYPE_OUTPOST] = "EsoUI/Art/Icons/mapKey/mapKey_outpost.dds",
    [KEEPTYPE_TOWN]    = "EsoUI/Art/Icons/mapKey/mapKey_avaTown.dds",
    [KEEPTYPE_ARTIFACT_KEEP] = "EsoUI/Art/Icons/mapKey/mapKey_temple.dds",
    -- A border keep carries siege, so it can turn up here. Bridges, milegates, artifact
    -- gates and IC districts cannot take one and get no glyph.
    [KEEPTYPE_BORDER_KEEP] = "EsoUI/Art/Icons/mapKey/mapKey_borderkeep.dds",
}
local RESOURCE_GLYPH = {
    [RESOURCETYPE_FOOD] = "EsoUI/Art/Icons/mapKey/mapKey_farm.dds",
    [RESOURCETYPE_ORE]  = "EsoUI/Art/Icons/mapKey/mapKey_mine.dds",
    [RESOURCETYPE_WOOD] = "EsoUI/Art/Icons/mapKey/mapKey_lumbermill.dds",
}

local function KeepGlyph(keep)
    return Glyph(RESOURCE_GLYPH[keep.resourceType] or KEEP_GLYPH[keep.keepType])
end

local SCROLL_GLYPH = "EsoUI/Art/Icons/mapKey/mapKey_elderscroll.dds"
local CUTOFF_GLYPH = "EsoUI/Art/Icons/poi/poi_battlefield_complete.dds"

-- Trailing the name: whether you can travel there, the one tag to act on, then the
-- scroll. A glyph in front of each separates the run without counting spaces.
local function KeepTags(keep)
    local tags = {}
    local function tag(color, icon, text)
        tags[#tags + 1] = ColorText(color, Glyph(icon) .. " " .. text)
    end

    if keep.noTravel then tag(THEME.pvpBad, CUTOFF_GLYPH, CW.L.NO_TRAVEL) end
    -- A scroll in the building, whichever kind of keep it is; or, only a temple can say
    -- this, its own scroll gone.
    if keep.scrollHere then
        tag(THEME.header, SCROLL_GLYPH, CW.L.SCROLL_HERE)
    elseif keep.scrollGone then
        tag(THEME.pvpBad, SCROLL_GLYPH, GetString(SI_TOOLTIP_ARTIFACT_TAKEN))
    end

    if #tags == 0 then return "" end
    return " " .. table.concat(tags, " ")
end

-- Alliance-tinted title and status tags, then per-alliance siege counts; return height used.
local function DrawKeepBlock(keep, y)
    local startY = y
    -- Pad inside each block; inter-item gaps cannot clear the first/last keep's neighbors.
    y = y + THEME.keepPadTop

    -- Measure the possibly empty type glyph so the siege line clears it;
    -- siege counts retain alliance symbols to identify each force.
    local iconRun = KeepGlyph(keep)
    if iconRun ~= "" then iconRun = iconRun .. " " end
    local nameIndent = MeasureTextWidth(iconRun)
    local title = iconRun .. keep.name .. KeepTags(keep)

    local oc = AllianceTint(keep.owner) or THEME.active.title
    -- Ours gets a brighter title colour, and slides in the first time it appears
    -- (keep.alert, see LayoutPvp).
    if keep.owned then oc = Lighten(oc, 0.35) end

    -- Age since joining this list, not since the siege began.
    DrawPvpLine(title, oc, PVP_INDENT, y, keep.ageMin, keep.alert)

    y = y + THEME.titleRow

    -- Siege counts substitute for unavailable player counts, our alliance first.
    -- A keep can be under attack without siege; omit the line then.
    if #keep.siegeMine > 0 then
        -- One row of markup rather than a control per faction: each badge and its count
        -- share a |c run, so both come out in that faction's colour.
        local parts = { ColorText(THEME.footerLabel, CW.L.SIEGE) }
        for _, s in ipairs(keep.siegeMine) do
            parts[#parts + 1] = ColorText(AllianceTint(s.alliance) or THEME.active.body,
                AllianceGlyph(s.alliance) .. " " .. s.n)
        end
        DrawRow(table.concat(parts, "   "), THEME.active.body,
                y, PVP_INDENT + nameIndent, THEME.objRow)
        y = y + THEME.objRow
    end

    return y + THEME.keepPadBot - startY
end

-- Every contested keep, most-contested first, below quests in an Alliance War zone.
function UI.LayoutAva(section, y)
    local m = CW.ReadAvaObjectives()

    -- Preserve first-seen times for friendly-keep slides, ages and Recent action.
    -- A later attack restarts both clocks.
    local now = GetFrameTimeMilliseconds()
    local prev = UI.pvpSeen
    UI.pvpSeen = ReconcileSeen(prev, m.rows, now,
        function(r) return r.keepId end,
        function(id, t)
            local was = prev[id]
            return { t = t, name = was.name, owner = was.owner,
                     keepType = was.keepType, resourceType = was.resourceType }
        end)
    for _, r in ipairs(m.rows) do
        local e = UI.pvpSeen[r.keepId]
        -- The scan is gone when history draws, so the glyph inputs ride along.
        e.name, e.owner = r.name, r.owner
        e.keepType, e.resourceType = r.keepType, r.resourceType
        -- Animate only new attacks; PvP relayouts every few seconds.
        r.alert = r.owned and r.wasNew
    end

    -- Header even with no rows, or "All calm." reads as a stray line.
    y = LayoutGroup(UI.groupHeaders.keeps, CW.L.CONTESTED, m.rows, 0, y, DrawKeepBlock)
    if #m.rows == 0 then y = DrawPlaceholder(CW.L.NO_KEEPS, y) end
    return y
end

-- "<icon> large near Chalman", shared by the live Battles section and the history, so a
-- fight reads identically in both.
local function BattleLabel(e)
    local tier = CW.L.BATTLE_TIERS[e.tier]
    local text = e.near and string.format(CW.L.BATTLE_NEAR, e.near, tier)
        or string.format("(%s)", tier)
    return zo_iconFormat(e.icon, "100%", "100%") .. " " .. text
end

-- The same shape as a keep's title line: pin icon, size tier, nearest landmark, age.
local function DrawBattleRow(b, y)
    -- Same self-padding as a keep block, and indented the way items under a sub-header
    -- are elsewhere: a battle is not an objective.
    y = y + THEME.keepPadTop
    DrawPvpLine(BattleLabel(b), THEME.active.title, PVP_INDENT, y, b.ageMin, false)
    return THEME.keepPadTop + THEME.titleRow + THEME.keepPadBot
end

-- A nil CW.ReadBattles means untrusted map coordinates; preserve previous state.
function UI.LayoutBattles(section, y)
    local rows = CW.ReadBattles()
    if not rows then return y end

    local now = GetFrameTimeMilliseconds()
    local prev = UI.battleSeen
    UI.battleSeen = ReconcileSeen(prev, rows, now,
        function(r) return r.key end,
        function(key, t)
            local was = prev[key]
            return { t = t, kind = "battle", icon = was.icon, tier = was.tier, near = was.near }
        end)
    -- Retain the row for history; the scan model is gone by then.
    for _, r in ipairs(rows) do
        local e = UI.battleSeen[r.key]
        e.icon, e.tier, e.near = r.icon, r.tier, r.near
    end

    if #rows == 0 then return y end
    return LayoutGroup(UI.groupHeaders.battles, CW.L.BATTLES, rows, 0, y, DrawBattleRow)
end

-- History uses live fonts in gray, with time since activity ended;
-- keep glyphs retain alliance color to identify the former owner.
local function DrawRecentRow(e, y)
    local text
    if e.kind == "battle" then
        text = BattleLabel(e)
    else
        local icon = KeepGlyph(e)
        text = icon ~= "" and
            (ColorText(AllianceTint(e.owner) or THEME.empty, icon) .. " " .. e.name)
            or e.name
    end
    DrawRow(text, THEME.empty, y, PVP_INDENT, THEME.objRow)
    DrawAge(e.ageMin, y, true, THEME.empty)
    return THEME.objRow
end

-- UI.pvpRecent is filled and expired by the live layouts, so no separate timer is needed.
-- Draw newest first with an entry cap.
function UI.LayoutRecentAction(section, y)
    local now = GetFrameTimeMilliseconds()
    local rows = {}
    for _, e in pairs(UI.pvpRecent) do
        -- Everything DrawRecentRow reads, including both of KeepGlyph's inputs.
        rows[#rows + 1] = { kind = e.kind, name = e.name, owner = e.owner,
                            keepType = e.keepType, resourceType = e.resourceType,
                            icon = e.icon, tier = e.tier, near = e.near, t = e.t,
                            ageMin = math.floor((now - e.t) / 60000) }
    end
    if #rows == 0 then return y end
    table.sort(rows, function(a, b) return a.t > b.t end)
    for i = #rows, RECENT_MAX + 1, -1 do rows[i] = nil end
    return LayoutGroup(UI.groupHeaders.recent, CW.L.RECENT_ACTION, rows, 0, y, DrawRecentRow)
end

-- Leads the Quests section whenever the assist cycle lands on the zone story. Stands
-- in for ZO_ZoneStoryTracker, which we keep hidden.
local function DrawZoneStory(zg, y)
    local icon = TakeIcon(THEME.questIconPx)
    icon:SetTexture(THEME.zoneStoryIcon)
    icon:SetColor(1, 1, 1, 1)
    icon:SetAlpha(1)
    icon:ClearAnchors()
    icon:SetAnchor(LEFT, UI.panel, TOPLEFT, THEME.sideInset, y + THEME.titleRow / 2)

    local title = TakeRawRow()
    title:SetFont(THEME.headFont)
    title:SetHeight(THEME.titleRow)
    title:SetColor(unpack(THEME.active.title))
    title.baseColor = THEME.active.title
    title:SetText(string.format("|c%s%s:|r %s", HexOf(THEME.header), CW.L.ZONE_STORY, zg.name))
    title:SetWidth(THEME.panelW - THEME.sideInset * 2 - THEME.questIconPx - THEME.iconSpace)
    title:ClearAnchors()
    local titleLeft = THEME.sideInset + THEME.questIconPx + THEME.iconSpace
    title:SetAnchor(TOPLEFT, UI.panel, TOPLEFT, titleLeft, y)
    y = DrawUnderline(title, titleLeft, y + THEME.titleRow)

    if zg.desc then
        y = y + DrawRow(zg.desc, THEME.active.body, y, SectionTextLeft(), 0, true):GetHeight()
    end

    return y
end

function UI.LayoutQuestList(section, y)
    -- Cyrodiil / IC are exempt from the instance collapse: the whole quest section leads
    -- the panel there, keeps below it.
    local activeOnly = CW.QuestContentHiddenInInstance()
        and not (CW.PvpFocusMode())
    -- Mirror the native assist cycle: Zone Guide replaces the active quest;
    -- the tracked list stays.
    local zoneGuide = not activeOnly and CW.ReadZoneStory()

    -- The assisted quest, with all of its objectives.
    local primary = CW.ReadAssistedQuest()
    if primary then
        primary.focused = true
    end

    -- The player's own picks. Its own checkmark governs it and it starts hidden; in an
    -- instance with quest hiding on, and in a Battleground, only the primary shows.
    local tracked = {}
    if not activeOnly and not CW.IsBattleground() and UI.GroupShown("trackedQuests") then
        tracked = CW.ReadTrackedList()
    end

    if not (zoneGuide or primary or #tracked > 0) then
        return DrawPlaceholder(CW.L.QUESTS_EMPTY, y)
    end

    local drewPrimary = true
    if zoneGuide then
        y = DrawZoneStory(zoneGuide, y)
    elseif primary then
        y = y + DrawQuestBlock(primary, y)
    else
        drewPrimary = false
    end

    if #tracked > 0 then
        if drewPrimary then y = y + THEME.questSpace end
        -- Apply trackedTomeHeaderColor here on each layout so its picker color persists.
        UI.groupHeaders.tracked:SetColor(unpack(THEME.trackedTomeHeader))
        y = LayoutGroup(UI.groupHeaders.tracked, CW.L.TRACKED_QUESTS,
            tracked, THEME.questSpace, y, DrawQuestBlock)
    end
    return y
end

function UI.LayoutTomeList(section, y)
    local tomes = CW.ReadTomes()
    local seasonal, weekly = {}, {}
    for _, t in ipairs(tomes) do
        if t.type == TIMED_ACTIVITY_TYPE_SEASONAL then
            seasonal[#seasonal + 1] = t
        else
            weekly[#weekly + 1] = t
        end
    end

    if #tomes == 0 then
        return DrawPlaceholder(CW.L.TOMES_EMPTY, y)
    end

    local seasonalDone, seasonalTotal = CountCompleted(seasonal)
    local weeklyDone, weeklyTotal = CountCompleted(weekly)
    local seasonalLabel = string.format("%s (%d/%d)", CW.L.TOME_SEASONAL, seasonalDone, seasonalTotal)
    local weeklyLabel = string.format("%s (%d/%d)", CW.L.TOME_WEEKLY, weeklyDone, weeklyTotal)

    local showSeasonal = UI.GroupShown("tomeSeasonal")
    local showWeekly   = UI.GroupShown("tomeWeekly")

    -- Each nonempty subgroup places its own toggle beside the headline.
    if showSeasonal then
        y = LayoutFilteredTomes(UI.tomeFilters.seasonal, "seasonal", seasonalLabel,
            seasonal, THEME.trackedTomeHeader, y,
            #weekly == 0 or not showWeekly)
    end

    if showWeekly then
        y = LayoutFilteredTomes(UI.tomeFilters.weekly, "weekly", weeklyLabel,
            weekly, THEME.trackedTomeHeader, y, true)
    end
    return y
end

-- One row for every repeatable section. Only the pledge scan sets `accepted`, and only it
-- lists a quest the player has not picked up yet.
local function DrawRepeatableRow(rowData, y, solo)
    local name = rowData.label or rowData.name
    -- Battleground objectives stand alone; guild and zone labels provide a prefix.
    if rowData.objective and (not rowData.ready or not rowData.label) then
        local objective = CondText(rowData.objective, THEME.active)
        name = rowData.label and name ~= "" and name .. ": " .. objective or objective
    end
    local lead, text, prefix
    local base = THEME.active.body
    -- Check completed first: turned-in pledges leave the journal but must not show as available.
    if rowData.completed or rowData.ready then
        -- Keep the check inline: a separate lead-column texture stopped drawing in c546c75,
        -- while character bullets still worked.
        prefix = GreenCheck() .. " "
        lead, text = "", prefix .. ColorText(THEME.active.finished, name)
        -- Ready rows need their own turn-in cue; the headline speaks only when all are ready.
        if not rowData.completed then
            text = string.format("%s (%s)", text,
                ColorText(THEME.active.finished, CW.L.READY_FOR_TURN_IN))
        end
    elseif rowData.accepted == false then
        -- Gray marks quests available for pickup.
        lead, text, base = GreyAvailable(), ColorText(THEME.muted.body, name), THEME.muted.body
    else
        -- The scanner supplies the title span so it needs no parsing here.
        local title = rowData.labelUnderline or ""
        local tinted = title ~= "" and name:sub(1, #title) == title
            and ColorText(THEME.active.title, title)
                .. ColorText(THEME.active.body, name:sub(#title + 1))
        lead, text = solo and "" or GreyBullet(), tinted or ColorText(THEME.active.body, name)
    end

    -- Under the headline's title, not its icon: lining them up with the icon read as no
    -- indent at all.
    local row, textLeft = DrawLedRow(lead, text, base, y, SectionTextLeft(), THEME.objRow)
    row.hoverColor = THEME.active.title
    row.questIndex = rowData.index
    row:SetMouseEnabled(row.questIndex ~= nil)
    local bottom = y + row:GetHeight()
    -- Underline only the title, starting in the text column after the glyph.
    -- Use first-line depth because the objective can wrap.
    if rowData.labelUnderline and rowData.labelUnderline ~= "" then
        local lineH = math.min(row:GetHeight(),
            WrappedHeight(rowData.labelUnderline, THEME.panelW))
        -- A wrapped row already has room under its rule; a single-line one gains the gap.
        bottom = math.max(bottom, DrawUnderline(row, textLeft, y + lineH,
            rowData.labelUnderline, prefix, true))
    end
    return bottom
end

-- Return display text and bare title; the underline excludes checkmarks and turn-in status.
local function SectionHeadline(label, progress, total, allReady, allCompleted)
    if allCompleted then
        return string.format("%s %s", ColorText(THEME.active.body, label), GreenCheck()), label
    end
    if allReady then
        return string.format("%s %s (%s)", ColorText(THEME.active.body, label), GreenCheck(),
            ColorText(THEME.active.finished, CW.L.READY_FOR_TURN_IN)), label
    end
    local text = string.format("%s (%d/%d)", label, progress, total)
    return text, text
end

-- Collapse finished or turn-in-ready groups to their headline; Zone Dailies has its own layout.
local function DrawRepeatableSection(icon, color, id, label, model, total, y)
    local completed, progress = model.completed or 0, model.progress
    local allCompleted = total > 0 and completed >= total
    local allReady = total > 0 and progress >= total
    local statusText, titleText = SectionHeadline(label, progress, total, allReady, allCompleted)
    y = DrawSectionIcon(icon, y, color, id, statusText, titleText)
    if allReady or allCompleted then return y end
    local rows = model.rows
    for _, row in ipairs(rows) do
        y = DrawRepeatableRow(row, y, #rows == 1)
    end
    return y
end

function UI.LayoutGuildDailies(section, y, dailies)
    return DrawRepeatableSection(THEME.guildDailyIcon, THEME.recurring, "guildDailies",
        CW.L.GUILD_DAILIES, dailies, dailies.count, y)
end

function UI.LayoutAvaDailies(section, y, dailies)
    return DrawRepeatableSection(THEME.avaDailyIcon, THEME.recurring, "avaDailies",
        CW.L.AVA_DAILIES, dailies, dailies.count, y)
end

-- With none accepted, show gray availability like pledges; keep the pickup reminder visible.
function UI.LayoutBattleground(section, y, bg)
    local label = CW.L.BATTLEGROUND
    if bg.count == 0 then
        local statusText = GreyAvailable() .. " " .. ColorText(THEME.muted.body, label)
        return DrawSectionIcon(THEME.battlegroundIcon, y, THEME.muted.body, "battleground",
            statusText, label, GreyAvailable() .. " ")
    end
    return DrawRepeatableSection(THEME.battlegroundIcon, THEME.recurring, "battleground",
        label, bg, bg.count, y)
end

-- Use quest-title color for the zone name; the unbulleted row already separates the group.
local function DrawZoneDailyGroupHeader(zoneName, y, ready)
    local text = ready
        and string.format("%s %s (%s)", zoneName, GreenCheck(),
            ColorText(THEME.active.finished, CW.L.READY_FOR_TURN_IN))
        or zoneName
    DrawRow(text, THEME.active.title, y, SectionTextLeft(), THEME.objRow)
    return y + THEME.objRow
end

-- Accepted-only like the Guild Dailies section, but bucketed under a zone name: a
-- character can carry dailies from several zones at once.
function UI.LayoutZoneDailies(section, y, dailies)
    -- The visible gate requires rows. With no day cache, turn-ins leave the journal
    -- and the section shrinks away.
    local count, progress = dailies.count, dailies.progress
    local allReady = count > 0 and progress >= count
    local statusText, titleText = SectionHeadline(CW.L.ZONE_DAILIES, progress, count, allReady)
    y = DrawSectionIcon(THEME.zoneDailyIcon, y, THEME.recurring, "zoneDailies",
        statusText, titleText)
    if allReady then return y end

    for _, group in ipairs(dailies.groups) do
        -- Unresolved zones have no header to carry status; always list their quests.
        local headed = group.zone ~= ""
        if headed then y = DrawZoneDailyGroupHeader(group.zone, y, group.allReady) end
        if not (headed and group.allReady) then
            for _, row in ipairs(group.rows) do
                y = DrawRepeatableRow(row, y, #group.rows == 1)
            end
        end
    end
    return y
end

function UI.LayoutUndaunted(section, y, pledges)
    return DrawRepeatableSection(THEME.undauntedIcon, nil, "undaunted",
        CW.L.UNDAUNTED_DAILIES, pledges, pledges.total, y)
end

-- The status on its own; the clock trails it as an aside, bracketed the way an
-- objective's count is: time waited, or time left to answer.
function UI.QueueStatusText(entry)
    local now = GetFrameTimeMilliseconds()
    local ms = entry.expiresAt and zo_max(entry.expiresAt - now, 0)
        or entry.queuedAt and now - entry.queuedAt
    if not ms then return entry.status end
    local clock = ZO_FormatTimeMilliseconds(ms, TIME_FORMAT_STYLE_COLONS,
        TIME_FORMAT_PRECISION_TWELVE_HOUR)
    if entry.status == "" then return clock end
    return string.format("%s (%s)", entry.status, clock)
end

local QUEUE_TIMER_UPDATE = CW.name .. "QueueTimer"

-- One update for every live clock the section drew. Each redraw hands over fresh rows,
-- and rows only move during a redraw, so a held row cannot fall to another section.
local function SetQueueClocks(clocks)
    UI.queueClocks = clocks
    EM:UnregisterForUpdate(QUEUE_TIMER_UPDATE)
    if not clocks then return end
    -- The named update exists only while a clock is on screen, so it needs no gate.
    EM:RegisterForUpdate(QUEUE_TIMER_UPDATE, 1000, function()
        for _, c in ipairs(UI.queueClocks) do
            c.row:SetText(UI.QueueStatusText(c.entry))
        end
    end)
end

-- Hover buttons above the panel, outside the text column, so they cost no content height.
function UI.LayoutChromeBar()
    local gap = BackdropGutterGap()
    local leftW = 0

    local function place(control, available)
        if not available then return end
        control:ClearAnchors()
        control:SetAnchor(BOTTOMLEFT, UI.panel, TOPLEFT,
            THEME.sideInset + THEME.chromeBtnLeft + leftW, -(gap + THEME.chromeBtnLift))
        leftW = leftW + THEME.chromeBtnPx + THEME.chromeBtnGap
    end

    -- Always shown; an empty journal gets a menu saying so.
    place(UI.questPickerBtn, true)

    -- Hidden when nothing we recorded is still in the journal.
    place(UI.lastQuestBtn, UI.RefreshLastQuestButton())
    place(UI.gear, true)
    place(UI.lock, true)
end

-- Colored like the queue: both are live state rather than a to-do list.
function UI.LayoutHouse(section, y, house)
    y = DrawSectionIcon(THEME.houseIcon, y, THEME.queue.name, nil,
        ColorText(THEME.queue.name, house.name), house.name)
    DrawRow(house.population, THEME.queue.status, y, SectionTextLeft(), THEME.objRow)
    y = y + THEME.objRow
    if house.owner then
        DrawRow(house.owner, THEME.active.body, y, SectionTextLeft(), THEME.objRow)
        y = y + THEME.objRow
    end
    return y
end

-- One block per queue the player is in.
function UI.LayoutQueue(section, y, queues)
    local top, clocks, urgent = y, nil, false
    UI.queueDrawn = true
    for i, entry in ipairs(queues) do
        local title = entry.title
        if (entry.count or 0) > 1 then
            title = string.format("%s (%s)", title,
                zo_strformat(CW.L.QUEUE_COUNT, entry.count))
        end
        y = DrawSectionIcon(QUEUE_ICONS[entry.kind], y, THEME.queue.name,
            nil, ColorText(THEME.queue.name, title), title)

        local row = DrawRow(UI.QueueStatusText(entry), THEME.queue.status, y,
            SectionTextLeft(), THEME.objRow)
        y = y + THEME.objRow
        if entry.queuedAt or entry.expiresAt then
            clocks = clocks or {}
            clocks[#clocks + 1] = { row = row, entry = entry }
        end
        urgent = urgent or entry.urgent
    end
    SetQueueClocks(clocks)
    UI.PlaceQueuePop(top, y - top, urgent)
    return y
end

-- Hidden-group restore strip
--
-- Hidden groups return through hover-only titles and unchecked boxes.
-- SetChromeHovered refreshes when groups are hidden because the strip changes height.
-- Append after the footer so the panel grows downward without moving hovered controls.
function UI.LayoutHiddenGroupStrip(y)
    if not UI.chromeHovered then return y end

    local first = true
    for _, g in ipairs(UI.toggleGroups) do
        if not UI.GroupShown(g.id) then
            if first then
                y = y + THEME.sectionSpace
                first = false
            end
            -- Tall enough for the box, so consecutive restore rows do not crowd it.
            local lineH = math.max(THEME.objRow, THEME.groupBtnSize)

            -- Reuse the headline's checkmark in the same gutter; the placements are mutually exclusive.
            g.button.groupUnavailable = false
            SetGroupToggleTextures(g.button, false)
            g.button:ClearAnchors()
            g.button:SetAnchor(RIGHT, UI.panel, TOPLEFT, -BackdropGutterGap(), y + lineH / 2)

            DrawRow(g.label(), THEME.muted.title, y, THEME.sideInset, lineH)
            y = y + lineH
        end
    end
    return y
end

-- Lay the sections out from the top, then size the panel to what they used.
function UI.Redraw()
    if CW.ShouldHideTracker() then
        UI.SetPanelHidden(true)
        return
    end
    UI.panel:SetHidden(false)

    rowsUsed, iconsUsed, usedDividers = 0, 0, 0
    local y = THEME.padTop

    -- Hover buttons, in their own strip above the panel.
    UI.LayoutChromeBar()
    -- Everything from here down can carry a divider; the first thing drawn cannot.
    contentTop = y

    -- Fixed controls start hidden; each layout shows what it needs.
    for _, control in pairs(UI.tomeFilters) do control:SetHidden(true) end
    for _, header in pairs(UI.groupHeaders) do header:SetHidden(true) end
    -- Each layout claims its group's checkmark; the restore strip claims the rest.
    for _, g in ipairs(UI.toggleGroups) do g.button.groupUnavailable = true end
    -- Nothing else stops the queue clock and pop when no queue draws.
    UI.queueDrawn = false

    for _, s in ipairs(UI.sections) do
        local model = s.scan and s.scan()
        -- A gated-out section adds no rows and no gap.
        if not (s.visible and not s.visible(model)) then
            y = s.layout(s, y, model)
            y = y + THEME.sectionSpace
        end
    end

    if not UI.queueDrawn then
        SetQueueClocks(nil)
        UI.StopQueuePop()
    end

    -- Take back the gap the last section left behind.
    y = y - THEME.sectionSpace
    -- Last: it only exists while hovered, so anything after it would jump.
    y = UI.LayoutHiddenGroupStrip(y)

    for i = rowsUsed + 1, #UI.rows do UI.rows[i]:SetHidden(true) end
    for i = iconsUsed + 1, #UI.icons do UI.icons[i]:SetHidden(true) end
    for i = usedDividers + 1, #UI.dividers do UI.dividers[i]:SetHidden(true) end

    -- Height alone: anchored TOPLEFT, the panel never moves under the cursor.
    UI.panel:SetHeight(y + THEME.endInset)
    UI.SyncBackdrop()
    UI.ApplyChromeVisibility()

    -- The panel has its height now, so the BG HUD can sit under it.
    CW.PlaceBattlegroundHud()
    -- After SetHeight: CW.SuppressNativeExtras also docks, but runs before the re-size.
    CW.DockActivityTracker()
end

-- Helpers
function UI.SetPanelHidden(hidden)
    if hidden then
        -- The panel vanishing under the cursor fires no OnMouseExit.
        UI.ClearChromeHover()
        -- No layout runs while hidden to stop the queue clock and pop.
        SetQueueClocks(nil)
        UI.StopQueuePop()
        -- Restore ESO's ready-check placement so hiding our panel cannot take it off-screen.
        CW.UndockActivityTracker()
    end
    UI.panel:SetHidden(hidden)
end

-- The settings window is a menu-scene fragment and would otherwise cover the tracker
-- and the HUD widgets being placed; each widget is its own top-level window.
function UI.SetAboveMenus(on)
    local tier = on and DT_HIGH or DT_MEDIUM
    UI.panel:SetDrawTier(tier)
    for _, w in ipairs(UI.widgetWindows) do w:SetDrawTier(tier) end
end

function UI.SyncLock()
    local locked = CW.SavedVars.pinned
    UI.panel:SetMovable(not locked)
    SetButtonArt(UI.lock, locked and LOCK_ART or UNLOCK_ART)
end

-- The gear button, straight to our own LAM panel. Its open callback places the selected
-- tab's widgets.
function UI.ShowSettings()
    LibAddonMenu2:OpenToPanel(CW.settingsPanel)
end

-- Writes straight to the fixed controls; pooled rows take the new values at their next
-- layout. Build calls this before any control exists, so it computes THEME and stops.
-- relayout=false skips the Refresh at the end.
function UI.SyncTheme(relayout)
    local t = CW.SavedVars.appearance

    UI.RefreshFontChoices()
    -- A font another add-on registered can be gone this session.
    local face  = UI.FONTS[t.typeface] or UI.FONTS[CW.defaults.appearance.typeface]
    -- Normal is "": the font string then ends at its size rather than a trailing pipe.
    local style = t.fontStyle
    if style ~= "" then style = "|" .. style end
    local titlePt, bodyPt = t.pt.title, t.pt.body

    THEME.headFont = string.format("%s|%d%s", face, titlePt, style)
    THEME.filterFont = string.format("%s|%d%s", face, math.max(10, zo_round(titlePt * 0.8)), style)
    THEME.bodyFont = string.format("%s|%d%s", face, bodyPt,  style)
    -- Two points under the row font: an aside, without turning into noise at the
    -- smallest row sizes, hence the floor.
    THEME.keepAgeFont = string.format("%s|%d%s", face, math.max(10, bodyPt - 2), style)

    THEME.panelW = t.panelWidth

    -- Fixed leading gives smaller fonts proportionally more space; slider minima of
    -- 14 and 12 make a floor unnecessary.
    THEME.titleRow   = titlePt + 6
    THEME.objRow     = bodyPt + 6
    -- titleRow - questIconPx must stay even: DrawQuestBlock centres on titleRow / 2, and
    -- an odd difference filters the texture across two rows of screen pixels.
    THEME.questIconPx = titlePt + 10

    -- Palette colors without pickers; individual overrides follow below.
    local pal = CW.GetPalette(t.preset)

    THEME.subHead          = pal.accentSoft
    THEME.arrowHot         = pal.accentBright
    THEME.footerLabel      = pal.footerLabel
    THEME.empty            = Dim(pal.footerLabel, 0.88)
    THEME.queue.name       = pal.accent

    -- Meaning, not decoration -- but each theme states it in its own colors.
    THEME.recurring     = pal.recurring
    -- The queue's status line reads as a live count, so it takes the counter color.
    THEME.queue.status  = pal.count
    THEME.pvpBad        = pal.pvpBad

    THEME.header           = t.headerColor
    THEME.active.title     = t.activeTitleColor
    THEME.active.body      = t.activeObjColor
    THEME.active.finished  = t.activeDoneColor
    THEME.active.count     = t.activeCountColor
    THEME.trackedTomeHeader = t.trackedTomeHeaderColor
    THEME.rule          = t.dividerColor
    THEME.ruleH         = t.dividerHeight
    -- Stored as a percentage, which is what the slider shows; the renderer wants a
    -- fraction.
    THEME.dividerPct    = t.dividerWidthPct / 100
    THEME.underline     = t.dividerUnderline == true

    -- Availability rows (unaccepted quests, empty BG dailies, restore strip) blend
    -- toward quiet text, preserving their hue. Derive each time to follow the color pickers.
    local function Muted(c) return Blend(c, pal.footerLabel, 0.55) end
    THEME.muted = { title = Muted(THEME.active.title), body = Muted(THEME.active.body) }

    if not UI.panel then return end   -- the Build call: THEME is all there is yet

    UI.panel:SetWidth(THEME.panelW)

    -- Fonts, colors and sizes all just moved; drop the caches rather than work out
    -- which entries survived.
    ZO_ClearTable(wrappedHeights)
    for _, row in ipairs(UI.rows) do row.stamp = nil end

    for _, control in pairs(UI.tomeFilters) do control:SetFont(THEME.filterFont) end
    for _, header in pairs(UI.groupHeaders) do header:SetFont(THEME.headFont) end

    -- Repaint fixed footer labels here; pooled rows pick up colors during layout.
    UI.measure:SetFont(THEME.bodyFont)
    UI.ApplyOffBalanceTrackerStyle()
    UI.ApplyHealthAlertStyle()

    if relayout ~= false then UI.Redraw() end
end

-- The panel's text is a sibling of the backdrop rather than a child, so this only ever
-- touches the frame.
function UI.SyncBackdrop()
    UI.bg:SetAlpha(CW.SavedVars.backdropAlpha)
end

-- The saved anchor is always normalized to TOPLEFT/TOPLEFT by NormalizeAnchor below.
function UI.SyncAnchor()
    local p = CW.SavedVars.anchor
    UI.panel:ClearAnchors()
    UI.panel:SetAnchor(p.point, GuiRoot, p.relativePoint, p.x, p.y)
end

-- Pins the panel by its top-left corner, wherever it sits.
--
-- TOPLEFT keeps the panel fixed as sections grow downward. ESO re-anchors dragged
-- windows to the nearest corner, so normalize instead of saving GetAnchor directly.
-- Read live edges to change the anchor without moving the panel.
local function NormalizeAnchor()
    local x, y = UI.panel:GetLeft(), UI.panel:GetTop()
    UI.panel:ClearAnchors()
    UI.panel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
    local p = CW.SavedVars.anchor
    p.point, p.relativePoint, p.x, p.y = TOPLEFT, TOPLEFT, x, y
end

function UI.StoreAnchor()
    NormalizeAnchor()
end
