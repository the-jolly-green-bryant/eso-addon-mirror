-- Ocular - press a key (or /ocular) to toggle a floating magnifier of the icon under your mouse.
-- Pure UI: it only reads the texture of the control you're hovering and draws a bigger copy.

Ocular = {}
local Ocular = Ocular   -- local speed-up reference: avoids a _G lookup on every access (Baertram)

local WM        = WINDOW_MANAGER
local EM        = EVENT_MANAGER
local ADDON     = "Ocular"
local UPDATE    = "Ocular_Zoom"
local POLL_MS   = 100    -- polled ONLY while active; and each tick does nothing unless the hovered cell changed
local SIZES     = { 96, 128, 192 }   -- preview sizes cycled by the size keybind
local DEFAULT_SIZE = 128
local OFFSET    = 32     -- gap between the cursor and the preview
local MAX_DEPTH = 3      -- how deep to search a hovered tile for its icon (icon is shallow)

Ocular.active = false

-- Current preview size (from SavedVariables; falls back to the default if unset or invalid,
-- e.g. an old saved size that's no longer offered).
local function curSize()
    local s = Ocular.sv and Ocular.sv.size
    for i = 1, #SIZES do
        if SIZES[i] == s then return s end
    end
    return DEFAULT_SIZE
end

-- Build the floating preview once (lazy).
local function EnsureFrame()
    if Ocular.frame then return end

    local sz = curSize()
    local f = WM:CreateTopLevelWindow("Ocular_Frame")
    f:SetDimensions(sz + 8, sz + 8)
    f:SetDrawLayer(DL_OVERLAY)
    f:SetDrawTier(DT_HIGH)
    f:SetMouseEnabled(false)      -- never intercept clicks
    f:SetClampedToScreen(true)
    f:SetHidden(true)

    local bg = WM:CreateControl("Ocular_FrameBG", f, CT_BACKDROP)
    bg:SetAnchor(TOPLEFT, f, TOPLEFT, 0, 0)
    bg:SetAnchor(BOTTOMRIGHT, f, BOTTOMRIGHT, 0, 0)
    bg:SetCenterColor(0, 0, 0, 0.88)
    bg:SetEdgeColor(0.65, 0.55, 0.25, 1)

    local ic = WM:CreateControl("Ocular_Icon", f, CT_TEXTURE)
    ic:SetDimensions(sz, sz)
    ic:SetAnchor(CENTER, f, CENTER, 0, 0)

    Ocular.frame = f
    Ocular.icon  = ic
end

-- Chrome textures we must never zoom (hover highlight, selection glow, backdrops, edges).
local function isChrome(name, file)
    local s = ((name or "") .. "|" .. (file or "")):lower()
    return s:find("highlight") or s:find("glow") or s:find("background")
        or s:find("mouseover") or s:find("edge") or s:find("frame") or s:find("_bg")
end

-- Preferred: a descendant control whose NAME contains "Icon" - ESO's convention for the real
-- icon (e.g. ...Control44Icon). This is what makes it hit outfit/costume/collectible cells.
local function findNamedIcon(ctrl, depth)
    if not ctrl or depth > MAX_DEPTH then return nil end
    if ctrl.GetTextureFileName and ctrl.GetName then
        local nm = ctrl:GetName() or ""
        if nm:find("Icon") and not isChrome(nm, nil) then
            local ok, f = pcall(ctrl.GetTextureFileName, ctrl)
            if ok and f and f ~= "" then return f end
        end
    end
    if ctrl.GetNumChildren then
        for i = 1, ctrl:GetNumChildren() do
            local r = findNamedIcon(ctrl:GetChild(i), depth + 1)
            if r then return r end
        end
    end
    return nil
end

-- Fallback: the biggest NON-chrome texture (for panels without an "Icon"-named control).
local function biggestIcon(ctrl, depth, best)
    best = best or { file = nil, area = 0 }
    if not ctrl or depth > MAX_DEPTH then return best end
    if ctrl.GetTextureFileName then
        local ok, f = pcall(ctrl.GetTextureFileName, ctrl)
        if ok and f and f ~= "" and not isChrome((ctrl.GetName and ctrl:GetName()) or "", f) then
            local w, h = ctrl:GetDimensions()
            local area = (w or 0) * (h or 0)
            if area > best.area then best.file, best.area = f, area end
        end
    end
    if ctrl.GetNumChildren then
        for i = 1, ctrl:GetNumChildren() do biggestIcon(ctrl:GetChild(i), depth + 1, best) end
    end
    return best
end

-- Only zoom real item/collectible/gear/style icons - they live under .../art/icons/.
-- This keeps out HUD chrome, menu icons, latency bars, etc.
local function isRealIcon(f)
    return f ~= nil and f:lower():find("/icons/") ~= nil
end

-- Resolve the icon for a given control: prefer an "Icon"-named texture, else the biggest
-- non-chrome one; walk up a couple of parents if the cell itself has nothing.
local function resolveIcon(c)
    for _ = 1, 3 do
        if not c then break end
        local f = findNamedIcon(c, 0)
        if isRealIcon(f) then return f end
        f = biggestIcon(c, 0).file
        if isRealIcon(f) then return f end
        c = c.GetParent and c:GetParent() or nil
    end
    return nil
end

-- Polled while active, but does real work ONLY when the hovered control CHANGES. So while your
-- cursor sits on a cell, each tick is just one GetMouseOverControl() call, then it returns.
-- The preview is placed next to the cursor when you ENTER a cell (it doesn't trail the cursor
-- within the cell = lighter, no per-frame re-anchor).
local lastCtrl

local function onUpdate()
    local c = WM:GetMouseOverControl()
    if c == lastCtrl then return end   -- same cell -> nothing to do
    lastCtrl = c
    local file = resolveIcon(c)
    if not file then
        Ocular.frame:SetHidden(true)
        return
    end
    Ocular.icon:SetTexture(file)
    local mx, my = GetUIMousePosition()
    Ocular.frame:ClearAnchors()
    Ocular.frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, mx + OFFSET, my + OFFSET)
    Ocular.frame:SetHidden(false)
end

-- Guardrail: the instant you're back at the gameplay HUD - in EITHER reticle mode (HUD_SCENE)
-- OR cursor mode (HUD_UI_SCENE), i.e. any time you're not in a menu - Ocular switches itself
-- off so nothing runs outside menus. Event-driven, and only registered while active.
local function onHudShown(_, newState)
    if newState == SCENE_SHOWN then Ocular.StopZoom() end
end

-- True when you're at the gameplay HUD (reticle OR cursor) - i.e. NOT inside a menu.
local function atGameplayHud()
    return (HUD_SCENE and HUD_SCENE:IsShowing()) or (HUD_UI_SCENE and HUD_UI_SCENE:IsShowing())
end

function Ocular.StartZoom()
    -- No point outside menus: refuse to turn on at the gameplay HUD.
    if atGameplayHud() then
        d("Ocular: only works inside menus (inventory, outfit station, collections...)")
        return
    end
    EnsureFrame()
    if Ocular.active then return end
    Ocular.active = true
    EM:RegisterForUpdate(UPDATE, POLL_MS, onUpdate)
    if HUD_SCENE then HUD_SCENE:RegisterCallback("StateChange", onHudShown) end
    if HUD_UI_SCENE then HUD_UI_SCENE:RegisterCallback("StateChange", onHudShown) end
    onUpdate()   -- show immediately, don't wait for the first tick
end

function Ocular.StopZoom()
    Ocular.active = false
    EM:UnregisterForUpdate(UPDATE)
    if HUD_SCENE then HUD_SCENE:UnregisterCallback("StateChange", onHudShown) end
    if HUD_UI_SCENE then HUD_UI_SCENE:UnregisterCallback("StateChange", onHudShown) end
    lastCtrl = nil
    if Ocular.frame then Ocular.frame:SetHidden(true) end
end

-- Toggle on/off - used by the /ocular slash command and the toggle keybind.
function Ocular.Toggle()
    if Ocular.active then Ocular.StopZoom() else Ocular.StartZoom() end
end

-- Apply + persist a size, resizing the (possibly hidden) preview live.
local function applySize(px)
    if Ocular.sv then Ocular.sv.size = px end
    EnsureFrame()
    Ocular.frame:SetDimensions(px + 8, px + 8)
    Ocular.icon:SetDimensions(px, px)
    d("Ocular: preview size = " .. px .. " px")
end

-- Set an exact offered size (used by /ocular s|m|l).
function Ocular.SetSize(px)
    for i = 1, #SIZES do
        if SIZES[i] == px then applySize(px); return end
    end
end

-- Second keybind: cycle the preview size (96 -> 128 -> 192 -> back). Saved + applied live.
function Ocular.CycleSize()
    local cur = curSize()
    local idx = 1
    for i = 1, #SIZES do
        if SIZES[i] == cur then idx = i; break end
    end
    applySize(SIZES[(idx % #SIZES) + 1])
end

-- Register the keybinds' display NAMES the proper ESO way. A plain
-- "SI_BINDING_NAME_X = ..." Lua global is NOT picked up by the keybind system - it must be a
-- registered string id via ZO_CreateStringId (this is what makes the category show in Controls).
-- Done at file load, before Bindings.xml is parsed.
ZO_CreateStringId("SI_BINDING_NAME_OCULAR_ZOOM", "Toggle magnifier (on/off)")
ZO_CreateStringId("SI_BINDING_NAME_OCULAR_CYCLE_SIZE", "Cycle magnifier size")

local function onLoaded(_, name)
    if name ~= ADDON then return end
    EM:UnregisterForEvent(ADDON, EVENT_ADD_ON_LOADED)
    -- Server-dependent (GetWorldName as namespace) so NA / EU / PTS don't overwrite each other.
    Ocular.sv = ZO_SavedVars:NewAccountWide("Ocular_Settings", 1, GetWorldName(), { size = DEFAULT_SIZE })
    -- Chat command (works without a keybind): /ocular = on/off, /ocular s|m|l = size.
    SLASH_COMMANDS["/ocular"] = function(arg)
        arg = (arg or ""):lower():gsub("%s", "")
        if arg == "" then Ocular.Toggle()
        elseif arg == "s" then Ocular.SetSize(96)
        elseif arg == "m" then Ocular.SetSize(128)
        elseif arg == "l" then Ocular.SetSize(192)
        else d("Ocular: /ocular = on/off  |  /ocular s|m|l = size (96 / 128 / 192)") end
    end
end
EM:RegisterForEvent(ADDON, EVENT_ADD_ON_LOADED, onLoaded)
