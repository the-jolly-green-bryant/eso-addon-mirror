-- ============================================================================
--  Addon Insights  -  main logic (console / gamepad UI)
-- ----------------------------------------------------------------------------
--  Helps you review your add-on setup, presented in the standard gamepad
--  two-panel layout:
--    * LEFT  column  - the three tabs, navigated with the D-pad / left stick
--                      (up / down). Selecting a tab updates the right column.
--          1. Startup CPU       - per-add-on load time during this startup
--          2. Orphaned Libraries - enabled libs nothing depends on
--          3. Addons             - every installed add-on, with tags
--    * RIGHT column  - the contents of the selected tab, free-scrolled with
--                      the RIGHT stick.
--
--  Three ways to open the window:
--    * Settings > Add-ons menu  (button, via LibAddonMenu-2.0 if installed)
--    * the /addoninsights chat command (works on console too -- open chat to type)
--    * a keybind you map under Controls > Keybindings
--
--  Console-conformant: ".addon" manifest, alphanumeric add-on name, controls
--  built from the shared gamepad widgets (parametric list + scroll container),
--  lean on the shared 100 MB / ~1s-per-frame budget.
--
--  GAMEPAD ONLY: this window is built for gamepad-preferred mode (console and
--  PC-with-controller). It is not designed for keyboard/mouse mode.
--
--  Startup-time caveat: we can only time add-ons that load AFTER us. Any that
--  load earlier are listed as "not measured".
-- ============================================================================

AddonInsights = {}
local AI = AddonInsights

-- Internal add-on name = manifest file name without extension = folder name.
AI.name        = "AddonInsights"
AI.displayName = "Addon Insights"

-- A namespace for EVENT_MANAGER registrations (just needs to be unique).
local NS = "AddonInsights"

-- Keybinding display names (looked up as SI_BINDING_NAME_<ACTION> by the menu).
-- The keybind opens the Add-ons settings panel (the tabbed view); the legacy
-- window is reached from the panel button or the /triage chat command.
ZO_CreateStringId("SI_BINDING_NAME_ADDONINSIGHTS_TOGGLE", "Open Addon Insights menu")

-- ----------------------------------------------------------------------------
--  SECTION 1: startup timing capture (runs as the file loads)
-- ----------------------------------------------------------------------------

AI.loadEvents        = {}
AI.loadStartMs       = GetGameTimeMilliseconds()
AI.playerActivatedMs = nil

local function OnAnyAddOnLoaded(_, addOnName)
    AI.loadEvents[#AI.loadEvents + 1] = { name = addOnName, time = GetGameTimeMilliseconds() }
end
EVENT_MANAGER:RegisterForEvent(NS .. "_Timing", EVENT_ADD_ON_LOADED, OnAnyAddOnLoaded)

-- ----------------------------------------------------------------------------
--  Helpers
-- ----------------------------------------------------------------------------

local function Clean(str)
    if not str or str == "" then return "" end
    str = string.gsub(str, "|[cC]%x%x%x%x%x%x", "")
    str = string.gsub(str, "|[rR]", "")
    str = string.gsub(str, "|[tT].-|[tT]", "")
    return str
end

local function Colour(hex, text) return "|c" .. hex .. text .. "|r" end
local C_GREEN, C_RED, C_YELLOW = "44DD44", "FF5555", "FFCC44"
local C_GREY, C_BLUE,  C_WHITE = "999999", "66BBFF", "FFFFFF"

-- Format a SavedVariables disk figure (in MB) for display, picking a sensible
-- unit and a colour that flags the heavier hitters.
local function FormatSize(mb)
    if type(mb) ~= "number" then return Colour(C_GREY, "  --") end
    local hex = C_GREY
    if mb >= 25 then hex = C_RED elseif mb >= 5 then hex = C_YELLOW end
    local text
    if mb <= 0 then
        text = "0 MB"
    elseif mb < 0.1 then
        text = string.format("%d KB", math.max(1, math.floor(mb * 1024 + 0.5)))
    elseif mb < 10 then
        text = string.format("%.1f MB", mb)
    else
        text = string.format("%d MB", math.floor(mb + 0.5))
    end
    return Colour(hex, text)
end

-- ----------------------------------------------------------------------------
--  SECTION 2: gather addon data from the game
-- ----------------------------------------------------------------------------

function AI.GatherAddonData()
    local manager    = GetAddOnManager()
    local addons     = {}
    local referenced = {}

    local count = manager:GetNumAddOns()
    for i = 1, count do
        -- GetAddOnInfo -> name, title, author, description, enabled, state, isOutOfDate, isLibrary
        local name, title, _, _, enabled, _, isOutOfDate, isLibrary = manager:GetAddOnInfo(i)

        local record = {
            name        = name,
            title       = Clean(title) ~= "" and Clean(title) or name,
            enabled     = enabled,
            isLibrary   = isLibrary,
            isOutOfDate = isOutOfDate,
        }

        -- Size on disk: the ESO sandbox can't read an add-on's code / asset
        -- files, so the only per-add-on disk figure the API exposes is the
        -- SavedVariables (settings + stored data) footprint, in MB. Guarded
        -- with pcall because the signature varies across API versions / hasn't
        -- always existed -- a miss just leaves svMB nil and the column blank.
        local okSize, mb = pcall(function()
            return manager:GetUserAddOnSavedVariablesDiskUsageMB(i)
        end)
        if okSize and type(mb) == "number" then
            record.svMB = mb
        end

        local ok, numDeps = pcall(function() return manager:GetAddOnNumDependencies(i) end)
        if ok and numDeps then
            for d = 1, numDeps do
                -- GetAddOnDependencyInfo -> name, exists, active, minVersion, version
                local depName = manager:GetAddOnDependencyInfo(i, d)
                if depName and depName ~= "" and enabled then
                    referenced[depName] = true
                end
            end
        end

        addons[#addons + 1] = record
    end

    local timeByName, prev = {}, AI.loadStartMs
    for _, ev in ipairs(AI.loadEvents) do
        local delta = ev.time - prev
        if delta < 0 then delta = 0 end
        timeByName[ev.name] = delta
        prev = ev.time
    end
    for _, a in ipairs(addons) do
        a.loadMs = timeByName[a.name]
    end

    for _, a in ipairs(addons) do
        a.isOrphanLibrary = a.isLibrary and a.enabled and not referenced[a.name]
    end

    return addons
end

-- ----------------------------------------------------------------------------
--  SECTION 3: build page content as arrays of lines
-- ----------------------------------------------------------------------------

local function BuildAddonsLines(addons)
    table.sort(addons, function(a, b)
        if a.enabled ~= b.enabled then return a.enabled end
        return string.lower(a.title) < string.lower(b.title)
    end)

    local enabledCount, totalMB, haveSizes = 0, 0, false
    for _, a in ipairs(addons) do
        if a.enabled then enabledCount = enabledCount + 1 end
        if type(a.svMB) == "number" then
            totalMB   = totalMB + a.svMB
            haveSizes = true
        end
    end

    local lines = {}
    lines[#lines + 1] = Colour(C_WHITE, "Installed: " .. #addons .. "   ") .. Colour(C_GREEN, enabledCount .. " enabled")
    lines[#lines + 1] = Colour(C_GREY, "[LIB] library    [OUT] out of date")
    if haveSizes then
        lines[#lines + 1] = Colour(C_GREY, "Size = SavedVariables data on disk   ")
            .. Colour(C_GREY, "(total ") .. FormatSize(totalMB) .. Colour(C_GREY, ")")
    end
    lines[#lines + 1] = " "
    for _, a in ipairs(addons) do
        local dot   = a.enabled and Colour(C_GREEN, "[on] ") or Colour(C_GREY, "[off]")
        local title = a.enabled and Colour(C_WHITE, a.title) or Colour(C_GREY, a.title)
        local size  = haveSizes and ("  " .. FormatSize(a.svMB)) or ""
        local tags  = ""
        if a.isLibrary   then tags = tags .. " " .. Colour(C_BLUE,   "[LIB]") end
        if a.isOutOfDate then tags = tags .. " " .. Colour(C_YELLOW, "[OUT]") end
        lines[#lines + 1] = dot .. " " .. title .. tags .. size
    end
    return lines
end

local function BuildLibsLines(addons)
    local orphans = {}
    for _, a in ipairs(addons) do if a.isOrphanLibrary then orphans[#orphans + 1] = a end end
    table.sort(orphans, function(a, b) return string.lower(a.title) < string.lower(b.title) end)

    local lines = {}
    lines[#lines + 1] = Colour(C_WHITE, "Orphaned libraries: " .. #orphans)
    lines[#lines + 1] = Colour(C_GREY, "Enabled libraries no enabled addon depends on.")
    lines[#lines + 1] = " "
    if #orphans == 0 then
        lines[#lines + 1] = Colour(C_GREEN, "None found.")
    else
        for _, a in ipairs(orphans) do
            lines[#lines + 1] = Colour(C_YELLOW, "  - " .. a.title) .. Colour(C_GREY, "  (" .. a.name .. ")")
        end
        lines[#lines + 1] = " "
        lines[#lines + 1] = Colour(C_GREY, "Disable one at a time and confirm")
        lines[#lines + 1] = Colour(C_GREY, "nothing breaks before removing.")
    end
    return lines
end

local function BuildCpuLines(addons)
    local measured, unmeasured = {}, {}
    for _, a in ipairs(addons) do
        if a.enabled then
            if a.loadMs ~= nil then measured[#measured + 1] = a else unmeasured[#unmeasured + 1] = a end
        end
    end
    table.sort(measured,   function(a, b) return a.loadMs > b.loadMs end)
    table.sort(unmeasured, function(a, b) return string.lower(a.title) < string.lower(b.title) end)

    local total = 0
    for _, a in ipairs(measured) do total = total + a.loadMs end

    local lines = {}
    lines[#lines + 1] = Colour(C_WHITE, "Startup load time (slowest first)")
    if AI.playerActivatedMs then
        lines[#lines + 1] = Colour(C_GREY, "To world: ") .. Colour(C_BLUE, (AI.playerActivatedMs - AI.loadStartMs) .. " ms")
    end
    lines[#lines + 1] = Colour(C_GREY, "Measured total: ") .. Colour(C_BLUE, total .. " ms")

    lines[#lines + 1] = " "
    for _, a in ipairs(measured) do
        local hex = C_GREEN
        if a.loadMs >= 100 then hex = C_RED elseif a.loadMs >= 25 then hex = C_YELLOW end
        lines[#lines + 1] = Colour(hex, string.format("%5d ms", a.loadMs)) .. "  " .. Colour(C_WHITE, a.title)
    end
    if #unmeasured > 0 then
        lines[#lines + 1] = " "
        lines[#lines + 1] = Colour(C_GREY, "Not measured (loaded before us): " .. #unmeasured)
        for _, a in ipairs(unmeasured) do
            lines[#lines + 1] = Colour(C_GREY, "  " .. a.title)
        end
    end
    return lines
end

-- Parallel-load view: each add-on's "load time" is the elapsed ms from when we
-- started measuring (loadStartMs) to its ADD_ON_LOADED event -- i.e. treating
-- every add-on as if it began loading at the same instant, rather than charging
-- it only the gap since the previous one (which is the Startup CPU view). We sum
-- these so the total can be compared against the console 1000 ms budget.
local function BuildParallelLines(addons)
    local elapsedByName = {}
    for _, ev in ipairs(AI.loadEvents) do
        local e = ev.time - AI.loadStartMs
        if e < 0 then e = 0 end
        elapsedByName[ev.name] = e
    end

    local rows, unmeasured, sum = {}, 0, 0
    for _, a in ipairs(addons) do
        if a.enabled then
            local e = elapsedByName[a.name]
            if e ~= nil then
                rows[#rows + 1] = { title = a.title, ms = e }
                sum = sum + e
            else
                unmeasured = unmeasured + 1
            end
        end
    end
    table.sort(rows, function(a, b) return a.ms > b.ms end)

    local lines = {}
    lines[#lines + 1] = Colour(C_WHITE, "Load elapsed from measure start")
    lines[#lines + 1] = Colour(C_GREY, "Each addon: ms from when Addon Insights")
    lines[#lines + 1] = Colour(C_GREY, "started measuring to its load event.")
    lines[#lines + 1] = Colour(C_GREY, "(Parallel-load model -- see README.)")

    local sumHex = (sum >= 1000) and C_RED or ((sum >= 750) and C_YELLOW or C_GREEN)
    lines[#lines + 1] = Colour(C_GREY, "Sum of elapsed: ") .. Colour(sumHex, sum .. " ms")
        .. Colour(C_GREY, "  / 1000 ms budget")
    lines[#lines + 1] = " "
    for _, r in ipairs(rows) do
        local hex = C_GREEN
        if r.ms >= 100 then hex = C_RED elseif r.ms >= 25 then hex = C_YELLOW end
        lines[#lines + 1] = Colour(hex, string.format("%5d ms", r.ms)) .. "  " .. Colour(C_WHITE, r.title)
    end
    if unmeasured > 0 then
        lines[#lines + 1] = " "
        lines[#lines + 1] = Colour(C_GREY, "Not measured (loaded before us): " .. unmeasured)
    end
    return lines
end

-- ----------------------------------------------------------------------------
--  SECTION 4: the gamepad two-panel screen (built from primitives)
-- ----------------------------------------------------------------------------
--  Built entirely from CT_BACKDROP / CT_LABEL controls -- the same primitives
--  the earlier overlay used successfully on console -- so it has no dependency
--  on native virtual templates (an earlier build crashed because
--  CreateControlFromVirtual("...ParametricScrollList") referenced a template
--  name that doesn't exist in the live API).
--
--  Left  = three tab labels with a highlight bar; the LEFT stick moves the
--          selection up / down.
--  Right = one multi-line label showing a scrollable window of lines; the
--          RIGHT stick scrolls it line by line.
--  A ZO_Scene + keybind strip give it standard show/hide, the B/Circle back
--  button, L1/R1 tab navigation, and L2/R2 scrolling.
-- ----------------------------------------------------------------------------

AI.tabs      = { "cpu", "libs", "addons", "parallel" }
AI.tabLabels = {
    addons   = "Addons",
    libs     = "Orphaned Libraries",
    cpu      = "Startup CPU",
    parallel = "Parallel Load Times",
}
AI.tabIndex     = 1
AI.currentLines = {}
AI.scrollLine   = 0
AI.linesPerPage = 16
AI.tabRows      = nil
AI.keybindGroup = nil
AI.scene        = nil

local SCENE_NAME      = "AddonInsightsGamepad"

local function CurrentTab() return AI.tabs[AI.tabIndex] end

-- Show the visible window of lines for the current scroll offset.
local function RenderSlice()
    if not AI.contentLabel then return end
    local lines  = AI.currentLines or {}
    local total  = #lines
    local per    = AI.linesPerPage
    local maxTop = math.max(0, total - per)
    if AI.scrollLine > maxTop then AI.scrollLine = maxTop end
    if AI.scrollLine < 0       then AI.scrollLine = 0 end

    local slice = {}
    for i = AI.scrollLine + 1, math.min(total, AI.scrollLine + per) do
        slice[#slice + 1] = lines[i]
    end
    AI.contentLabel:SetText(table.concat(slice, "\n"))

    if AI.scrollHint then
        if total > per then
            AI.scrollHint:SetText(string.format(
                "lines %d-%d / %d   -   L2/R2 to scroll",
                AI.scrollLine + 1, math.min(total, AI.scrollLine + per), total))
        else
            AI.scrollHint:SetText("")
        end
    end
end

-- Rebuild the line array for the active tab and reset the scroll position.
local function RenderContent()
    local addons = AI.GatherAddonData()
    local tab    = CurrentTab()
    if tab == "libs" then
        AI.currentLines = BuildLibsLines(addons)
    elseif tab == "cpu" then
        AI.currentLines = BuildCpuLines(addons)
    elseif tab == "parallel" then
        AI.currentLines = BuildParallelLines(addons)
    else
        AI.currentLines = BuildAddonsLines(addons)
    end
    AI.scrollLine = 0
    RenderSlice()
end

-- Restyle the tab labels and move the highlight bar to the selected one.
local function UpdateTabVisuals()
    if not AI.tabRows then return end
    for i, row in ipairs(AI.tabRows) do
        if i == AI.tabIndex then
            row:SetColor(1, 1, 1, 1)
            row:SetFont("ZoFontGamepadBold34")
        else
            row:SetColor(0.52, 0.52, 0.47, 1)
            row:SetFont("ZoFontGamepad34")
        end
    end
    local sel = AI.tabRows[AI.tabIndex]
    if AI.highlight and sel then
        AI.highlight:ClearAnchors()
        AI.highlight:SetAnchor(TOPLEFT,     sel, TOPLEFT,     -12, -2)
        AI.highlight:SetAnchor(BOTTOMRIGHT, sel, BOTTOMRIGHT,  12,  2)
        AI.highlight:SetHidden(false)
    end
end

local function SetSelection(index)
    local n = #AI.tabs
    AI.tabIndex = ((index - 1) % n) + 1
    UpdateTabVisuals()
    RenderContent()
end

-- UpdateDirectionalInput removed: DIRECTIONAL_INPUT:GetXY internally calls the
-- private 'IsKeyDown' function, which is rejected on console when add-on code
-- is anywhere on the callstack ("untrusted" callstack).  Navigation and
-- scrolling are now handled through the keybind strip instead (see BuildPanel).

local function BuildPanel()
    local wm = WINDOW_MANAGER
    if not wm then error("WINDOW_MANAGER is not available during BuildPanel") end

    local w = wm:CreateTopLevelWindow("AddonInsightsWindow")
    w:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 0, 0)
    w:SetAnchor(BOTTOMRIGHT, GuiRoot, BOTTOMRIGHT, 0, 0)
    w:SetHidden(true)
    w:SetMouseEnabled(false)
    w:SetMovable(false)
    AI.window = w

    local screenW = GuiRoot:GetWidth()
    local screenH = GuiRoot:GetHeight()

    local listX, listY = screenW * 0.085, screenH * 0.20
    local listW        = screenW * 0.26
    local paneX, paneY = screenW * 0.40,  screenH * 0.20
    local paneW, paneH = screenW * 0.56,  screenH * 0.62

    AI.linesPerPage = math.max(6, math.floor(paneH / 40))

    -- Two dark panels (primitive backdrops -- reliable on console).
    local panelTop = listY - 80
    local panelBot = paneY + paneH + 24
    local bgL = wm:CreateControl("AddonInsightsBgL", w, CT_BACKDROP)
    bgL:SetAnchor(TOPLEFT,     w, TOPLEFT, listX - 24, panelTop)
    bgL:SetAnchor(BOTTOMRIGHT, w, TOPLEFT, listX + listW + 24, panelBot)
    bgL:SetCenterColor(0, 0, 0, 0.85)
    bgL:SetEdgeColor(0.42, 0.36, 0.21, 1)

    local bgR = wm:CreateControl("AddonInsightsBgR", w, CT_BACKDROP)
    bgR:SetAnchor(TOPLEFT,     w, TOPLEFT, paneX - 20, panelTop)
    bgR:SetAnchor(BOTTOMRIGHT, w, TOPLEFT, paneX + paneW + 20, panelBot)
    bgR:SetCenterColor(0, 0, 0, 0.85)
    bgR:SetEdgeColor(0.42, 0.36, 0.21, 1)

    -- Title + divider over the left column.
    local title = wm:CreateControl("AddonInsightsTitle", w, CT_LABEL)
    title:SetAnchor(BOTTOMLEFT, w, TOPLEFT, listX, listY - 18)
    title:SetFont("ZoFontGamepadBold34")
    title:SetColor(0.79, 0.66, 0.41, 1)
    title:SetText(AI.displayName)
    AI.titleLabel = title

    -- Divider as a thin backdrop bar (no texture path to get wrong).
    local divider = wm:CreateControl("AddonInsightsDivider", w, CT_BACKDROP)
    divider:SetAnchor(TOPLEFT, w, TOPLEFT, listX, listY - 12)
    divider:SetDimensions(listW, 3)
    divider:SetCenterColor(0.42, 0.36, 0.21, 1)
    divider:SetEdgeColor(0, 0, 0, 0)

    -- Highlight bar (created before the rows so it draws behind them).
    local hl = wm:CreateControl("AddonInsightsHighlight", w, CT_BACKDROP)
    hl:SetCenterColor(0.79, 0.66, 0.41, 0.16)
    hl:SetEdgeColor(0, 0, 0, 0)
    hl:SetHidden(true)
    AI.highlight = hl

    -- LEFT: three tab labels.
    AI.tabRows = {}
    local rowH = screenH * 0.075
    for i, tab in ipairs(AI.tabs) do
        local row = wm:CreateControl("AddonInsightsTab" .. i, w, CT_LABEL)
        row:SetAnchor(TOPLEFT, w, TOPLEFT, listX + 14, listY + 12 + (i - 1) * rowH)
        row:SetWidth(listW - 14)
        row:SetFont("ZoFontGamepad34")
        row:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        row:SetText(AI.tabLabels[tab])
        AI.tabRows[i] = row
    end

    local navHint = wm:CreateControl("AddonInsightsNavHint", w, CT_LABEL)
    navHint:SetAnchor(BOTTOMLEFT, w, TOPLEFT, listX, panelBot - 10)
    navHint:SetFont("ZoFontGamepad18")
    navHint:SetColor(0.55, 0.55, 0.5, 1)
    navHint:SetText("D-pad: choose tab")

    -- RIGHT: scrollable content label.
    local content = wm:CreateControl("AddonInsightsContent", w, CT_LABEL)
    content:SetAnchor(TOPLEFT, w, TOPLEFT, paneX, paneY)
    content:SetDimensions(paneW, paneH)
    content:SetFont("ZoFontGamepad24")
    content:SetVerticalAlignment(TEXT_ALIGN_TOP)
    content:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    content:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    AI.contentLabel = content

    local scrollHint = wm:CreateControl("AddonInsightsScrollHint", w, CT_LABEL)
    scrollHint:SetAnchor(BOTTOMLEFT, w, TOPLEFT, paneX, panelBot - 10)
    scrollHint:SetFont("ZoFontGamepad18")
    scrollHint:SetColor(0.55, 0.55, 0.5, 1)
    AI.scrollHint = scrollHint

    -- Scene: SCENE_MANAGER handles show/hide and the gamepad back button.
    local scene = ZO_Scene:New(SCENE_NAME, SCENE_MANAGER)
    scene:AddFragment(ZO_FadeSceneFragment:New(w))
    AI.scene = scene

    -- Keybind strip: Back / Refresh / tab navigation (L1 / R1) / scroll (L2 / R2).
    -- Navigation and scrolling are handled here rather than via
    -- DIRECTIONAL_INPUT:GetXY because GetXY internally calls the private
    -- 'IsKeyDown' function, which is blocked on console when add-on code is on
    -- the callstack.  Keybind callbacks are dispatched from ZOS trusted code and
    -- do not have that restriction.
    AI.keybindGroup = {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
        {
            name     = "Back",
            keybind  = "UI_SHORTCUT_NEGATIVE",
            callback = function() SCENE_MANAGER:Hide(SCENE_NAME) end,
        },
        {
            name     = "Refresh",
            keybind  = "UI_SHORTCUT_SECONDARY",
            callback = function() RenderContent() end,
        },
        {
            name     = "Prev Tab",
            keybind  = "UI_SHORTCUT_LEFT_SHOULDER",
            callback = function() SetSelection(AI.tabIndex - 1) end,
        },
        {
            name     = "Next Tab",
            keybind  = "UI_SHORTCUT_RIGHT_SHOULDER",
            callback = function() SetSelection(AI.tabIndex + 1) end,
        },
        {
            name     = "Scroll Up",
            keybind  = "UI_SHORTCUT_LEFT_TRIGGER",
            callback = function()
                AI.scrollLine = AI.scrollLine - 1
                RenderSlice()
            end,
        },
        {
            name     = "Scroll Down",
            keybind  = "UI_SHORTCUT_RIGHT_TRIGGER",
            callback = function()
                AI.scrollLine = AI.scrollLine + 1
                RenderSlice()
            end,
        },
    }

    scene:RegisterCallback("StateChange", function(_, newState)
        if newState == SCENE_SHOWING then
            -- Enter UI mode so the game stops feeding input to the character
            -- (no movement / camera) and routes it to our keybind strip + the
            -- d-pad / right-stick handlers instead. Guarded for safety.
            if SetGameCameraUIMode then SetGameCameraUIMode(true) end
            UpdateTabVisuals()
            RenderContent()
        elseif newState == SCENE_SHOWN then
            KEYBIND_STRIP:AddKeybindButtonGroup(AI.keybindGroup)
        elseif newState == SCENE_HIDING then
            KEYBIND_STRIP:RemoveKeybindButtonGroup(AI.keybindGroup)
            -- Hand control back to the game (or to whatever scene we return to,
            -- which re-establishes its own UI mode).
            if SetGameCameraUIMode then SetGameCameraUIMode(false) end
        end
    end)
end

-- ----------------------------------------------------------------------------
--  SECTION 5: open / keybind handlers / slash command
-- ----------------------------------------------------------------------------

function AddonInsights_Open()
    if not AI.scene then return end
    if not IsInGamepadPreferredMode() then
        d("|cFFCC44Addon Insights|r is a gamepad-mode window. Switch to gamepad/controller UI mode to open it.")
        return
    end
    SCENE_MANAGER:Show(SCENE_NAME)
end

function AddonInsights_Keybind_Toggle()
    if not AI.scene then return end
    if AI.scene:GetState() == SCENE_SHOWN or AI.scene:GetState() == SCENE_SHOWING then
        SCENE_MANAGER:Hide(SCENE_NAME)
    else
        AddonInsights_Open()
    end
end

-- Open the Add-ons settings panel (the tabbed view). Falls back to the legacy
-- window if LibAddonMenu / the OpenToPanel API isn't available, so the keybind
-- and command always do something useful.
function AddonInsights_OpenSettings()
    local LAM = LibAddonMenu2
    if not LAM and LibStub then
        local ok, lib = pcall(function() return LibStub("LibAddonMenu-2.0") end)
        if ok then LAM = lib end
    end
    if LAM and AI.lamPanel and LAM.OpenToPanel then
        LAM:OpenToPanel(AI.lamPanel)
    else
        AddonInsights_Open()
    end
end

-- ----------------------------------------------------------------------------
--  SECTION 6: LibAddonMenu-2.0 settings panel (the Add-ons menu entry)
-- ----------------------------------------------------------------------------
--  This panel IS the main UI. In gamepad mode LibAddonMenu renders it as the
--  native two-column settings screen: the controls list on the left, and the
--  focused control's tooltip on the right. So each tab is a button whose name
--  shows in the left list and whose tooltip (built on demand) shows that tab's
--  contents in the right pane when it's highlighted. A header acts as the
--  divider, and below it the button opens the legacy overlay.
-- ----------------------------------------------------------------------------

-- Render a tab's lines into one string for the panel's right (tooltip) pane.
local function TabContentText(which)
    local addons = AI.GatherAddonData()
    local lines
    if which == "libs" then
        lines = BuildLibsLines(addons)
    elseif which == "cpu" then
        lines = BuildCpuLines(addons)
    elseif which == "parallel" then
        lines = BuildParallelLines(addons)
    else
        lines = BuildAddonsLines(addons)
    end
    return table.concat(lines, "\n")
end

-- Registers the LAM panel. Returns true if it found LAM and registered, false
-- if LAM isn't available yet (so the caller can defer and retry).
local function RegisterMenu()
    if AI.lamPanel then return true end   -- already registered
    local LAM = LibAddonMenu2
    if not LAM and LibStub then
        local ok, lib = pcall(function() return LibStub("LibAddonMenu-2.0") end)
        if ok then LAM = lib end
    end
    if not LAM then return false end

    local panelData = {
        type    = "panel",
        name    = AI.displayName,
        author  = "spoqster",
        version = "1.8.0",
    }
    -- Keep the panel handle so the keybind / command can open straight to it.
    AI.lamPanel = LAM:RegisterAddonPanel("AddonInsightsPanel", panelData)

    -- Tab buttons are display-only: the content is in the tooltip (right pane),
    -- shown when the row is highlighted. Pressing A does nothing on purpose --
    -- the legacy window (full scrollable view) is launched from its own button
    -- below, or with /triage.
    local function noop() end

    local options = {
        {
            type = "description",
            text = "Highlight a tab to preview its contents on the right. For the full scrollable view, open the legacy window below or type /triage in chat.",
        },
        {
            type    = "button",
            name    = "Addons",
            tooltip = function() return TabContentText("addons") end,
            func    = noop,
            width   = "full",
        },
        {
            type    = "button",
            name    = "Orphaned Libraries",
            tooltip = function() return TabContentText("libs") end,
            func    = noop,
            width   = "full",
        },
        {
            type    = "button",
            name    = "Startup CPU (load times)",
            tooltip = function() return TabContentText("cpu") end,
            func    = noop,
            width   = "full",
        },
        {
            type    = "button",
            name    = "Parallel Load Times",
            tooltip = function() return TabContentText("parallel") end,
            func    = noop,
            width   = "full",
        },
        {
            type = "header",
            name = "Legacy interface",
        },
        {
            type    = "button",
            name    = "Open legacy window",
            tooltip = "Opens the legacy Addon Insights overlay (also available with the /triage chat command).",
            func    = function() AddonInsights_Open() end,
            width   = "full",
        },
    }
    LAM:RegisterOptionControls("AddonInsightsPanel", options)
    return true
end

-- ----------------------------------------------------------------------------
--  SECTION 7: initialisation
-- ----------------------------------------------------------------------------

local function OnSelfLoaded(_, addOnName)
    if addOnName ~= AI.name then return end
    EVENT_MANAGER:UnregisterForEvent(NS, EVENT_ADD_ON_LOADED)

    AI.sv = ZO_SavedVars:NewAccountWide("AddonInsightsSavedVars", 1, nil, { lastTab = 1 })
    AI.tabIndex = AI.sv.lastTab or 1

    local ok, err = pcall(BuildPanel)
    if not ok then
        d("|cFF5555Addon Insights|r error during init: " .. tostring(err))
        return
    end
    -- Register the LAM panel as soon as LAM is available: now if it already
    -- loaded, otherwise when LibAddonMenu-2.0 fires its own load event. We no
    -- longer declare an OptionalDependsOn (so we load earlier and start timing
    -- sooner), which means LAM may load before or after us.
    if not RegisterMenu() then
        EVENT_MANAGER:RegisterForEvent(NS .. "_LAM", EVENT_ADD_ON_LOADED, function()
            EVENT_MANAGER:UnregisterForEvent(NS .. "_LAM", EVENT_ADD_ON_LOADED)
            RegisterMenu()
        end)
        EVENT_MANAGER:AddFilterForEvent(NS .. "_LAM", EVENT_ADD_ON_LOADED,
            REGISTER_FILTER_ADDON_NAME, "LibAddonMenu-2.0")
    end

    -- /addoninsights opens the tabbed settings panel; /triage opens the legacy
    -- overlay (also available from the panel's "Open legacy window" button).
    SLASH_COMMANDS["/addoninsights"] = AddonInsights_OpenSettings
    SLASH_COMMANDS["/triage"]        = AddonInsights_Keybind_Toggle

    d("|c66BBFFAddon Insights|r loaded. Open the menu via the Add-ons menu, |cFFFFFF/addoninsights|r, or a keybind. Legacy window: |cFFFFFF/triage|r.")
end

local function OnPlayerActivated()
    AI.playerActivatedMs = GetGameTimeMilliseconds()
    EVENT_MANAGER:UnregisterForEvent(NS .. "_Activated", EVENT_PLAYER_ACTIVATED)
    EVENT_MANAGER:UnregisterForEvent(NS .. "_Timing", EVENT_ADD_ON_LOADED)
end

local function SaveTab()
    if AI.sv then AI.sv.lastTab = AI.tabIndex end
end

EVENT_MANAGER:RegisterForEvent(NS, EVENT_ADD_ON_LOADED, OnSelfLoaded)
EVENT_MANAGER:AddFilterForEvent(NS, EVENT_ADD_ON_LOADED, REGISTER_FILTER_ADDON_NAME, AI.name)
EVENT_MANAGER:RegisterForEvent(NS .. "_Activated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
EVENT_MANAGER:RegisterForEvent(NS .. "_Logout", EVENT_PLAYER_DEACTIVATED, SaveTab)
