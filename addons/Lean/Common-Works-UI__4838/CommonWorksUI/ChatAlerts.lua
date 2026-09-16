-- Common Works — chat pop-up
--
-- Mirrors group and whisper messages onto the HUD, newest first.
-- Labels are pooled; the update loop runs only while visible.
-- Idle cost is one table lookup per chat message.

CommonWorksUI = CommonWorksUI or {}
local CW = CommonWorksUI

local UI = CW.UI
local EM = EVENT_MANAGER
local WM = WINDOW_MANAGER

local NS_EVT  = CW.name .. "ChatAlerts"
local NS_TICK = CW.name .. "ChatAlertsTick"

-- CHAT_CHANNEL_WHISPER_SENT is deliberately absent; anything else of your own is
-- dropped in IsFromPlayer.
local WATCHED = {
    [CHAT_CHANNEL_PARTY]   = true,
    [CHAT_CHANNEL_WHISPER] = true,
}

-- Width follows the edge drag or slider; height follows the wrapped message stack.
local WIDTH_MIN = 150
local WIDTH_MAX = 1200
local HANDLE_PX = 8     -- edge grab width, live only while placing
local MAX_LINES = 8     -- pool size, and the point at which the oldest is retired
local TICK_MS   = 30    -- ~33Hz, and only while lines are on screen
local FADE_IN   = 120
local FADE_OUT  = 250   -- quick by design
local EASE      = 0.35  -- fraction of the remaining gap closed per tick
local DROP_IN   = 10    -- how far above its slot a new line starts

-- Newest first. Each entry: { label, name, text, y, height, born, expires, pinned }
local lines = {}
local pool  = {}

local frame
local backdrop
local frameH  = 0
local ticking = false
-- Requested and active placement differ because the gate can change a frame later;
-- see PlacementValid.
local placementRequested = false
local placing            = false
local nameHex, textHex = "|cffa640", "|cffffff"

local function Enabled()
    return CW.SavedVars.chatAlerts
end

local function Width()
    return zo_clamp(CW.SavedVars.chatAlertWidth, WIDTH_MIN, WIDTH_MAX)
end

local function PlacementValid()
    return Enabled() and placementRequested
        and UI.SettingsPanelOpen()
end

local function FontSize()
    return zo_clamp(CW.SavedVars.chatAlertFontSize, 12, 36)
end

local function FontString()
    UI.RefreshFontChoices()
    local face = UI.FONTS[CW.SavedVars.chatAlertFontFace] or UI.FONTS[CW.defaults.chatAlertFontFace]
    return face .. "|" .. FontSize() .. "|soft-shadow-thin"
end

-- Baked into the text, not set on the label: one line carries two colours.
local function RefreshHex()
    local function hex(c)
        -- Rounded explicitly: %x on a fractional number is not portable.
        return string.format("|c%02x%02x%02x",
            zo_round(c[1] * 255), zo_round(c[2] * 255), zo_round(c[3] * 255))
    end
    nameHex = hex(CW.SavedVars.chatAlertNameColor)
    textHex = hex(CW.SavedVars.chatAlertTextColor)
end

local function BuildFrame()
    if frame then return end

    frame = WM:CreateTopLevelWindow("CW_ChatAlerts")
    frame:SetDimensions(Width(), 1)
    frame:SetClampedToScreen(false)
    frame:SetDrawLayer(DL_OVERLAY)
    frame:SetMouseEnabled(false)
    frame:SetMovable(false)
    frame:SetResizeHandleSize(0)   -- no grab area at all outside placement mode
    frame:SetHidden(true)

    -- Something to aim at while placing; invisible the rest of the time.
    backdrop = WM:CreateControl("CW_ChatAlertsBg", frame, CT_BACKDROP)
    backdrop:SetAnchorFill(frame)
    backdrop:SetCenterColor(0, 0, 0, 0.35)
    backdrop:SetEdgeTexture(nil, 2, 2, 2, 0)
    backdrop:SetEdgeColor(1, 0.65, 0.20, 0.8)
    backdrop:SetDrawLevel(1)
    backdrop:SetHidden(true)

    frame:SetHandler("OnMoveStart", function(self) self:SetClampedToScreen(true) end)
    frame:SetHandler("OnMoveStop", function(self)
        UI.SaveChatAlertPosition()
        self:SetClampedToScreen(false)
    end)
    -- Height is pinned to the stack; only width can be dragged.
    frame:SetHandler("OnResizeStop", function(self)
        CW.SavedVars.chatAlertWidth = zo_clamp(zo_round(self:GetWidth()), WIDTH_MIN, WIDTH_MAX)
        UI.SaveChatAlertPosition()   -- dragging the LEFT edge moves the anchor too
        UI.ApplyChatAlertWidth()
    end)

    UI.ApplyChatAlertPosition()
    RefreshHex()
end

local labelCount = 0

local function TakeLabel()
    local label = pool[#pool]
    if label then
        pool[#pool] = nil
    else
        -- Named: at most MAX_LINES are ever created.
        labelCount = labelCount + 1
        label = WM:CreateControl("CW_ChatAlertLine" .. labelCount, frame, CT_LABEL)
        label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        label:SetVerticalAlignment(TEXT_ALIGN_TOP)
        label:SetFont(FontString())
    end
    label:SetHidden(false)
    return label
end

-- Every line is the full width, so only the wrapped height varies.
local function Measure(e)
    e.label:SetWidth(Width())
    e.height = math.max(e.label:GetTextHeight(), FontSize() + 4)
end

local function Release(index)
    local e = lines[index]
    if not e then return end
    table.remove(lines, index)
    e.label:SetHidden(true)
    pool[#pool + 1] = e.label
end

local function ReleaseAll()
    for i = #lines, 1, -1 do Release(i) end
end

-- One update for the whole display, torn down when the last line expires.
local StartTicking

local function Tick()
    -- Closing options with Esc hides an ancestor; ESO does not fire the child's OnHide.
    if placing and not PlacementValid() then UI.ApplyChatAlertVisibility() end

    local now = GetFrameTimeMilliseconds()

    -- Backwards: the oldest is last, and goes first.
    for i = #lines, 1, -1 do
        local e = lines[i]
        if not e.pinned and now >= e.expires then Release(i) end
    end

    -- Cumulative heights set target slots; inserting at 1 slides the existing stack down.
    local y = 0
    for i = 1, #lines do
        local e = lines[i]
        -- Snap near the target so easing stops re-anchoring settled lines at 33Hz.
        if math.abs(y - e.y) < 0.5 then e.y = y else e.y = e.y + (y - e.y) * EASE end
        if e.anchoredY ~= e.y then
            e.anchoredY = e.y
            e.label:ClearAnchors()
            e.label:SetAnchor(TOPLEFT, frame, TOPLEFT, 0, e.y)
        end

        local a = 1
        local since = now - e.born
        if since < FADE_IN then a = since / FADE_IN end
        if not e.pinned then
            local left = e.expires - now
            if left < FADE_OUT then a = math.min(a, left / FADE_OUT) end
        end
        e.label:SetAlpha(a)

        y = y + e.height
    end

    -- Even unchanged SetDimensions costs a layout pass; this runs 33 times a second.
    if y ~= frameH then
        frameH = y
        local h = math.max(y, 1)
        frame:SetDimensions(Width(), h)
        frame:SetDimensionConstraints(WIDTH_MIN, h, WIDTH_MAX, h)
    end

    if #lines == 0 then
        EM:UnregisterForUpdate(NS_TICK)
        ticking = false
        frame:SetHidden(not placing)
    end
end

StartTicking = function()
    if ticking then return end
    ticking = true
    EM:RegisterForUpdate(NS_TICK, TICK_MS, Tick)
end

-- Concatenate user text into SetText; string.format would interpret literal "%".
-- Pinned lines last until placement ends.
local function Push(name, text, pinned)
    BuildFrame()
    while #lines >= MAX_LINES do Release(#lines) end

    local label = TakeLabel()
    label:SetText(nameHex .. name .. ": " .. textHex .. text)

    local now = GetFrameTimeMilliseconds()
    local e = {
        label   = label,
        name    = name,
        text    = text,
        pinned  = pinned == true,
        y       = -DROP_IN,     -- slides down into its slot rather than snapping
        born    = now,
        expires = now + CW.SavedVars.chatAlertDuration * 1000,
    }
    -- Measured once: a line's size never changes after it is posted.
    Measure(e)
    table.insert(lines, 1, e)

    frame:SetHidden(false)
    StartTicking()
end

-- Names arrive wrapped in character-link markup, and a display name may or may not
-- carry its leading "@".
local function PlainName(name)
    if name == "" then return "" end
    local plain = zo_strformat("<<1>>", name)
    plain = plain:gsub("^@", "")
    return zo_strlower(plain)
end

-- Drop the player's echoed group messages; which name is filled varies by channel.
local function IsFromPlayer(fromName, fromDisplayName)
    local display = PlainName(fromDisplayName)
    if display ~= "" and display == PlainName(GetDisplayName()) then return true end

    local char = PlainName(fromName)
    return char ~= "" and char == PlainName(GetUnitName("player"))
end

local function OnChat(_, channel, fromName, text, _isCustomerService, fromDisplayName)
    -- Test mode: every channel, in or out of combat, without waiting on a group.
    local test = CW.SavedVars.chatAlertTestMode == true
    if not (test or WATCHED[channel]) then return end
    if IsFromPlayer(fromName, fromDisplayName) then return end
    -- CW.inCombat is a field the core maintains, not an API call per message.
    local alwaysWhisper = channel == CHAT_CHANNEL_WHISPER
                      and CW.SavedVars.chatAlertsWhisperAlways ~= false
    if not test and not alwaysWhisper
       and CW.SavedVars.chatAlertsCombatOnly ~= false and CW.inCombat ~= true then return end
    if text == "" then return end

    local name = fromDisplayName ~= "" and fromDisplayName or fromName
    name = zo_strformat("<<1>>", name)

    Push(name, text)

    CW.PlaySoundRepeated(CW.SavedVars.chatAlertSound, CW.SavedVars.chatAlertVolume)
end

function UI.ApplyChatAlertPosition()
    UI.ApplyWidgetPosition(frame, "chatAlertPosition")
end

function UI.SaveChatAlertPosition()
    UI.SaveWidgetPosition(frame, "chatAlertPosition")
end

-- Applies to the lines already up, not just the next one.
function UI.ApplyChatAlertStyle()
    if not frame then return end
    RefreshHex()
    local font = FontString()
    for _, label in ipairs(pool) do label:SetFont(font) end
    for _, e in ipairs(lines) do
        e.label:SetFont(font)
        -- Baked-in color changes require resetting and remeasuring text.
        e.label:SetText(nameHex .. e.name .. ": " .. textHex .. e.text)
        Measure(e)
    end
end

-- Called after an edge drag or a slider move: two ways of writing one value.
function UI.ApplyChatAlertWidth()
    if not frame then return end
    local w = Width()
    frame:SetWidth(w)
    for _, label in ipairs(pool) do label:SetWidth(w) end
    for _, e in ipairs(lines) do Measure(e) end
    frameH = -1   -- forces the next Tick to re-dimension and re-pin the height
end

-- Recheck placement after OnShow: its scene transition can leave the gate false,
-- so evaluating only in the setter would never unlock.
function UI.ApplyChatAlertVisibility()
    if not frame then return end
    local want = PlacementValid()
    if want == placing then return end
    placing = want

    ReleaseAll()
    frame:SetMouseEnabled(placing)
    frame:SetMovable(placing)
    frame:SetResizeHandleSize(placing and HANDLE_PX or 0)
    frame:SetHidden(not placing)
    if backdrop then backdrop:SetHidden(not placing) end

    if placing then
        -- Pinned, so a teardown hook that never fired cannot strand them on the HUD.
        Push("Group member", "drag me, or drag my left/right edge", true)
        Push("Someone", "newest arrives on top", true)
    end
end

function UI.SetChatAlertPlacementMode(on)
    placementRequested = on == true
    BuildFrame()
    UI.ApplyChatAlertVisibility()
end
CW.RegisterHudWidget(UI.SetChatAlertPlacementMode, UI.ApplyChatAlertVisibility, "chatAlerts")

-- Two samples through the real timing/sound path; test mode instead mirrors all chat.
function CW.TestChatAlert()
    BuildFrame()
    Push("Group member", "sample line -- incoming, stack on me")
    Push("Someone", "sample line -- this is what a chat pop-up looks like")
    CW.PlaySoundRepeated(CW.SavedVars.chatAlertSound, CW.SavedVars.chatAlertVolume)
end

function CW.PreviewChatAlertSound()
    CW.PlaySoundRepeated(CW.SavedVars.chatAlertSound, CW.SavedVars.chatAlertVolume)
end

-- Idempotent and re-runnable, like the other feature modules.
function CW.UpdateChatAlerts()
    EM:UnregisterForEvent(NS_EVT, EVENT_CHAT_MESSAGE_CHANNEL)

    if not Enabled() then
        if frame then
            -- PlacementValid() becomes false when disabled, triggering placement teardown.
            UI.ApplyChatAlertVisibility()
            ReleaseAll()
            frame:SetHidden(true)
        end
        return
    end

    BuildFrame()
    UI.ApplyChatAlertStyle()
    UI.ApplyChatAlertWidth()
    EM:RegisterForEvent(NS_EVT, EVENT_CHAT_MESSAGE_CHANNEL, OnChat)
end
