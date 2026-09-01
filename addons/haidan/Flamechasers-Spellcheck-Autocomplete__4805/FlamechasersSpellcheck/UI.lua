local FSC = FlamechasersSpellcheck
local wm = WINDOW_MANAGER
local MOUSE_POLL_ACTIVE_MS = 16
local DECORATION_REFRESH_DELAY_MS = 28
local LIVE_DELETE_UNDERLINE_REFRESH_MS = 24
local LIVE_DELETE_UNDERLINE_MAX_TEXT = 1200
local MOUSE_POLL_NAME = "FlamechasersSpellcheckMousePoll"
local GLOBAL_MOUSE_DOWN_NAME = "FlamechasersSpellcheckGlobalMouseDown"
local GLOBAL_MOUSE_UP_NAME = "FlamechasersSpellcheckGlobalMouseUp"

local CARET_MARGIN = 12
local EXTRA_EDITOR_WIDTH = 48
local PCHAT_COPY_BUFFER_MAX = 20000
local AUTOCOMPLETE_BAR_HEIGHT = 22
local AUTOCOMPLETE_RESERVED_ROW_HEIGHT = 22
-- Keep a visible breathing gap above the native input without spending more
-- permanent chat-history height: the prediction bar overlaps the top few pixels
-- of the reserved row, and that overlap is faded into the history above.
local AUTOCOMPLETE_INPUT_GAP = 0
local AUTOCOMPLETE_RESERVED_ROW_GAP = 0
local AUTOCOMPLETE_CENTER_WEIGHT = 0.36
local AUTOCOMPLETE_SIDE_WEIGHT = 0.32
local AUTOCOMPLETE_LABEL_PADDING = 12
local AUTOCOMPLETE_SELECTION_MIN_WIDTH = 18
local AUTOCOMPLETE_SELECTION_MAX_WIDTH = 72
local AUTOCOMPLETE_MIN_TEXT_SCALE = 0.70
local AUTOCOMPLETE_DIVIDER_WIDTH = 1
local AUTOCOMPLETE_BAR_TEXTURE = "FlamechasersSpellcheck/media/autocomplete_lane_gradient.dds"
local AUTOCOMPLETE_DIVIDER_TEXTURE = "FlamechasersSpellcheck/media/autocomplete_divider.dds"
local AUTOCOMPLETE_BAR_LEFT_EXTEND = 8
local CHAT_HISTORY_GAP = 0
local STOCK_CHAT_SCROLLBAR_TOP_OFFSET = 60
local STOCK_CHAT_SCROLLBAR_BOTTOM_OFFSET = -80
local AUTOCOMPLETE_SCROLL_GUTTER = 6
local AUTOCOMPLETE_BOX_GAP = 8
local AUTOCOMPLETE_BOX_MIN_WIDTH = 68
local AUTOCOMPLETE_BOX_MAX_WIDTH = 190
local AUTOCOMPLETE_BOX_PADDING = 28
local AUTOCOMPLETE_BOX_RADIUS = 7
local AUTOCOMPLETE_BAR_BACKGROUND_TINT = 0.78
local AUTOCOMPLETE_BOX_BACKGROUND_TINT = 0.78
local WAVE_TILE_WIDTH = 8
local WAVE_HEIGHT = 4
local MOUSE_SELECTION_EDGE_ZONE = 22
local MOUSE_SELECTION_SCROLL_STEP = 16
local MOUSE_SELECTION_MAX_SCROLL_STEP = 54

-- Characters that should attach directly to a word. When autocomplete inserts its
-- convenience trailing space and the user immediately types one of these, the poller
-- removes only that generated space; user-authored spaces are never touched.
local AUTOCOMPLETE_ATTACHING_PUNCTUATION = {
    ["."] = true, [","] = true, ["!"] = true, ["?"] = true,
    [";"] = true, [":"] = true, [")"] = true, ["]"] = true, ["}"] = true,
}

FSC.visibleMarkers = FSC.visibleMarkers or {}
FSC.overlayState = "native chat overlay waiting"

local function NativeBox()
    return ZO_ChatWindowTextEntryEditBox
end

local function TextEntryControl()
    local native = NativeBox()
    return native and native:GetParent() and native:GetParent():GetParent() or nil
end

local function ChatWindowControl()
    return ZO_ChatWindow
end

local function AutocompleteHeight()
    return FSC:GetSuggestionHeight()
end

local function AutocompleteStyle()
    return FSC:GetSuggestionStyle()
end

local function AutocompleteReservedHeight()
    if not FSC:IsAutocompleteEnabled() then return 0 end
    -- Rounded boxes float over chat history instead of consuming a permanent row.
    if AutocompleteStyle() == "boxes" then return 0 end
    return AutocompleteHeight()
end

local function EnsureChatUtilityRow()
    if FSC.chatUtilityRow then return FSC.chatUtilityRow end
    local chat = ChatWindowControl()
    local textEntry = TextEntryControl()
    if not chat or not textEntry then return nil end

    -- The stock Mail/Friends/Notifications/Options bar stays in its original
    -- ESO position at the top. Prediction-bar mode reserves this invisible row;
    -- rounded-box mode collapses it to zero so the boxes can float over history.
    local row = wm:CreateControl("FlamechasersSpellcheckPredictionRow", chat, CT_CONTROL)
    row:SetMouseEnabled(false)
    row:SetHeight(AutocompleteReservedHeight())
    row:SetAnchor(BOTTOMLEFT, textEntry, TOPLEFT, 0, -AUTOCOMPLETE_RESERVED_ROW_GAP)
    row:SetAnchor(BOTTOMRIGHT, textEntry, TOPRIGHT, 0, -AUTOCOMPLETE_RESERVED_ROW_GAP)
    FSC.chatUtilityRow = row
    return row
end

local function GetChatUtilityControls()
    local chat = ChatWindowControl()
    if not chat then return nil end
    return {
        chat = chat,
        options = chat:GetNamedChild("Options"),
        divider = chat:GetNamedChild("Divider"),
        mail = chat:GetNamedChild("Mail"),
        mailLabel = chat:GetNamedChild("NumUnreadMail"),
        friends = chat:GetNamedChild("Friends"),
        friendsLabel = chat:GetNamedChild("NumOnlineFriends"),
        notifications = chat:GetNamedChild("Notifications"),
        notificationsLabel = chat:GetNamedChild("NumNotifications"),
        agent = chat:GetNamedChild("AgentChat"),
    }
end

function FSC:SetChatUtilitySuggestionMode(suggestionsVisible)
    -- Kept as a compatibility shim for the autocomplete session code. Suggestions
    -- no longer replace or hide ESO's stock utility controls.
    self.chatUtilitySuggestionsVisible = suggestionsVisible == true
end

local function RestoreStockChatUtilityLayout(c)
    if not c then return end

    -- These are ESO's native keyboard-chat anchors (API 101050). Explicitly
    -- restoring them also makes upgrading from v0.4.2-v0.4.6 clean after /reloadui.
    if c.divider then
        c.divider:SetParent(c.chat)
        c.divider:ClearAnchors()
        c.divider:SetAnchor(TOPLEFT, c.chat, TOPLEFT, 20, 39)
        c.divider:SetAnchor(TOPRIGHT, c.chat, TOPRIGHT, -20, 39)
        c.divider:SetHidden(false)
    end
    if c.options then
        c.options:SetParent(c.chat)
        c.options:ClearAnchors()
        c.options:SetAnchor(TOPRIGHT, c.chat, TOPRIGHT, -12, 7)
        c.options:SetHidden(false)
    end
    if c.mail then
        c.mail:SetParent(c.chat)
        c.mail:ClearAnchors()
        c.mail:SetAnchor(TOPLEFT, c.chat, TOPLEFT, 20, 7)
        c.mail:SetHidden(false)
    end
    if c.mailLabel and c.mail then
        c.mailLabel:SetParent(c.chat)
        c.mailLabel:ClearAnchors()
        c.mailLabel:SetAnchor(LEFT, c.mail, RIGHT, 2, 0)
        c.mailLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        c.mailLabel:SetHidden(false)
    end
    if c.friends and c.mailLabel then
        c.friends:SetParent(c.chat)
        c.friends:ClearAnchors()
        c.friends:SetAnchor(LEFT, c.mailLabel, RIGHT, 10, 0)
        c.friends:SetHidden(false)
    end
    if c.friendsLabel and c.friends then
        c.friendsLabel:SetParent(c.chat)
        c.friendsLabel:ClearAnchors()
        c.friendsLabel:SetAnchor(LEFT, c.friends, RIGHT, 2, 0)
        c.friendsLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        c.friendsLabel:SetHidden(false)
    end
    if c.notifications and c.friendsLabel then
        c.notifications:SetParent(c.chat)
        c.notifications:ClearAnchors()
        c.notifications:SetAnchor(LEFT, c.friendsLabel, RIGHT, 10, 0)
        c.notifications:SetHidden(false)
    end
    if c.notificationsLabel and c.notifications then
        c.notificationsLabel:SetParent(c.chat)
        c.notificationsLabel:ClearAnchors()
        c.notificationsLabel:SetAnchor(LEFT, c.notifications, RIGHT, 2, 0)
        c.notificationsLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        c.notificationsLabel:SetHidden(false)
    end
    if c.agent and c.notificationsLabel then
        c.agent:SetParent(c.chat)
        c.agent:ClearAnchors()
        c.agent:SetAnchor(LEFT, c.notificationsLabel, RIGHT, 10, 0)
        local agentActive = KEYBOARD_CHAT_SYSTEM.isAgentChatActive
        c.agent:SetHidden(not agentActive)
    end
end

function FSC:ApplyChatUtilityBarLayout()
    local row = EnsureChatUtilityRow()
    local c = GetChatUtilityControls()
    local container = KEYBOARD_CHAT_SYSTEM.primaryContainer
    if not row or not c or not container then return end

    if KEYBOARD_CHAT_SYSTEM:IsMinimized() then
        row:SetHidden(true)
        return
    end
    row:SetHidden(false)
    row:SetHeight(AutocompleteReservedHeight())

    -- Put ESO's own utility strip back exactly where it belongs.
    RestoreStockChatUtilityLayout(c)

    -- Prediction-bar mode reserves a slim row above input. Rounded-box mode keeps
    -- this row at zero height, allowing chat history to extend underneath the
    -- floating boxes instead of leaving a blank strip.
    if container.windowContainer then
        container.windowContainer:ClearAnchors()
        container.windowContainer:SetAnchor(TOPRIGHT, container.scrollUpButton, TOPLEFT, 0, 0)
        container.windowContainer:SetAnchor(BOTTOMLEFT, row, TOPLEFT, 0, -CHAT_HISTORY_GAP)
    end

    -- Restore the stock scrollbar geometry too. Its down/end buttons naturally
    -- occupy the far-right edge beside the prediction row, so the strip leaves a
    -- small right gutter instead of shortening the scrollbar (important for very
    -- small/resized chat windows).
    if container.scrollbar then
        container.scrollbar:ClearAnchors()
        container.scrollbar:SetAnchor(TOPRIGHT, c.chat, TOPRIGHT, -23, STOCK_CHAT_SCROLLBAR_TOP_OFFSET)
        container.scrollbar:SetAnchor(BOTTOMRIGHT, c.chat, BOTTOMRIGHT, -23, STOCK_CHAT_SCROLLBAR_BOTTOM_OFFSET)
    end
end

function FSC:SetupChatUtilityBar()
    self:ApplyChatUtilityBarLayout()
    if self.chatUtilityHooksInstalled then return end

    SecurePostHook(KEYBOARD_CHAT_SYSTEM, "HideMinBar", function()
        zo_callLater(function() FSC:ApplyChatUtilityBarLayout() end, 0)
    end)
    SecurePostHook(KEYBOARD_CHAT_SYSTEM, "ShowMinBar", function()
        if FSC.chatUtilityRow then FSC.chatUtilityRow:SetHidden(true) end
        FSC:ResetAutocompleteSuggestionSession()
    end)
    self.chatUtilityHooksInstalled = true
end

local function BuildFontString(control)
    if control and control.GetFontFaceName and control.GetFontSize and control.GetFontStyle then
        local face = control:GetFontFaceName()
        local size = control:GetFontSize()
        local style = control:GetFontStyle()
        if face and face ~= "" and size and size > 0 then
            if style and style ~= "" and style ~= "none" then
                return string.format("%s|%d|%s", face, size, style)
            end
            return string.format("%s|%d", face, size)
        end
    end
    return "ZoFontEditChat"
end

local function EnsureMeasureLabel()
    if FSC.measureLabel then return FSC.measureLabel end
    local label = wm:CreateControl("FlamechasersSpellcheckMeasure", GuiRoot, CT_LABEL)
    label:SetHidden(true)
    label:SetDimensions(12000, 100)
    label:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE)
    FSC.measureLabel = label
    return label
end

local measureCache = { text = "", font = nil, widths = { [0] = 0 }, sentinelWidth = nil }

local function CommonPrefixLength(a, b)
    local limit = math.min(#a, #b)
    local i = 1
    while i <= limit and a:byte(i) == b:byte(i) do i = i + 1 end
    return i - 1
end

local function PrepareMeasureCache(text)
    text = text or ""
    local label = EnsureMeasureLabel()
    local font = BuildFontString(NativeBox())
    if measureCache.font ~= font then
        measureCache.font = font
        measureCache.text = ""
        measureCache.widths = { [0] = 0 }
        measureCache.sentinelWidth = nil
        label:SetFont(font)
    end
    if measureCache.text ~= text then
        local keepThrough = CommonPrefixLength(measureCache.text or "", text)
        for index in pairs(measureCache.widths) do
            if index > keepThrough then measureCache.widths[index] = nil end
        end
        measureCache.text = text
    end
    return label
end

local function MeasurePrefix(text, index)
    text = text or ""
    index = math.max(0, math.min(#text, tonumber(index) or #text))
    local label = PrepareMeasureCache(text)
    local cached = measureCache.widths[index]
    if cached ~= nil then return cached end

    local prefix = index > 0 and text:sub(1, index) or ""
    local width
    if prefix ~= "" and prefix:sub(-1):match("%s") then
        -- ESO labels do not reliably include trailing whitespace in GetTextWidth().
        -- Underline starts are measured immediately before a word, so a run of spaces
        -- there used to disappear from x1 while the same spaces were counted inside x2,
        -- making the wave cover the whitespace. Append a visible sentinel so trailing
        -- spaces become internal, then subtract only the sentinel's own width. Because
        -- the character before it is whitespace there is no kerning boundary to skew it.
        if measureCache.sentinelWidth == nil then
            label:SetText("M")
            measureCache.sentinelWidth = label:GetTextWidth() or 0
        end
        label:SetText(prefix .. "M")
        width = math.max(0, (label:GetTextWidth() or 0) - measureCache.sentinelWidth)
    else
        label:SetText(prefix)
        width = label:GetTextWidth() or 0
    end
    measureCache.widths[index] = width
    return width
end

local function MeasureText(text)
    text = text or ""
    return MeasurePrefix(text, #text)
end

local function CaptureNativeLayout()
    if FSC.nativeLayoutCaptured then return end
    local native = NativeBox()
    if not native then return end

    FSC.nativeOriginalParent = native:GetParent()
    FSC.nativeOriginalAnchors = {}
    local count = native:GetNumAnchors() or 0
    for index = 0, count - 1 do
        local valid, point, relativeTo, relativePoint, offsetX, offsetY, constrains = native:GetAnchor(index)
        if valid then
            FSC.nativeOriginalAnchors[#FSC.nativeOriginalAnchors + 1] = {
                point = point,
                relativeTo = relativeTo,
                relativePoint = relativePoint,
                offsetX = offsetX,
                offsetY = offsetY,
                constrains = constrains,
            }
        end
    end
    FSC.nativeOriginalParentAutoClip = FSC.nativeOriginalParent
        and FSC.nativeOriginalParent.GetAutoRectClipChildren
        and FSC.nativeOriginalParent:GetAutoRectClipChildren() or false
    FSC.nativeLayoutCaptured = true
end

local function EnsureNativeOverlay()
    if FSC.nativeOverlay then return FSC.nativeOverlay end
    local native = NativeBox()
    if not native then return nil end
    CaptureNativeLayout()

    -- The overlay is a sibling of ESO's real EditBox and is anchored to the
    -- EditBox's ORIGINAL visible rectangle. The native EditBox itself remains
    -- the only keyboard/Enter control; we never replace, reparent, or attach a
    -- handler to it.
    local parent = native:GetParent()
    local overlay = wm:CreateControl("FlamechasersSpellcheckNativeOverlay", parent, CT_CONTROL)
    -- Pure geometry/drawing host: never participate in mouse or keyboard hit-testing.
    -- CT_SCROLL was unnecessary here and could sit above the real EditBox in ESO's
    -- hit-test stack even with mouse disabled.
    overlay:SetMouseEnabled(false)
    if overlay.SetKeyboardEnabled then overlay:SetKeyboardEnabled(false) end
    overlay:SetHidden(true)
    overlay:SetDrawTier(native:GetDrawTier())
    overlay:SetDrawLayer(native:GetDrawLayer())
    overlay:SetDrawLevel(math.max(0, native:GetDrawLevel() - 1))

    local anchored = false
    for _, anchor in ipairs(FSC.nativeOriginalAnchors or {}) do
        overlay:SetAnchor(anchor.point, anchor.relativeTo, anchor.relativePoint,
            anchor.offsetX, anchor.offsetY, anchor.constrains)
        anchored = true
    end
    if not anchored then
        overlay:SetAnchorFill(parent)
    end

    -- Clip the widened native EditBox at the stock edit-backdrop boundary. The
    -- stock Box has only a few pixels of inset, while the overlay independently
    -- clips underlines to the exact original Box rectangle.
    if parent and parent.SetAutoRectClipChildren then
        parent:SetAutoRectClipChildren(true)
    end

    FSC.nativeOverlay = overlay
    return overlay
end

local function SyncOverlayGeometry()
    local native = NativeBox()
    local overlay = EnsureNativeOverlay()
    if not native or not overlay then return end
    local tier = native:GetDrawTier()
    local layer = native:GetDrawLayer()
    local level = math.max(0, native:GetDrawLevel() - 1)
    local state = FSC.overlayDrawState
    if state and state.tier == tier and state.layer == layer and state.level == level then return end
    overlay:SetDrawTier(tier)
    overlay:SetDrawLayer(layer)
    overlay:SetDrawLevel(level)
    FSC.overlayDrawState = { tier = tier, layer = layer, level = level }
end

local function RestoreNativeLayout()
    local native = NativeBox()
    if not native or not FSC.nativeLayoutCaptured then return end
    native:ClearAnchors()
    if native.ClearDimensions then native:ClearDimensions() end
    local anchored = false
    for _, anchor in ipairs(FSC.nativeOriginalAnchors or {}) do
        native:SetAnchor(anchor.point, anchor.relativeTo, anchor.relativePoint,
            anchor.offsetX, anchor.offsetY, anchor.constrains)
        anchored = true
    end
    if not anchored and FSC.nativeOriginalParent then
        native:SetAnchorFill(FSC.nativeOriginalParent)
    end
    if FSC.nativeOriginalParent and FSC.nativeOriginalParent.SetAutoRectClipChildren then
        FSC.nativeOriginalParent:SetAutoRectClipChildren(FSC.nativeOriginalParentAutoClip == true)
    end
    FSC.nativeEditorGeometryState = nil
    FSC.overlayDrawState = nil
end

local function ApplyNativeEditorGeometry(text, viewWidth, scrollX, measuredTextWidth)
    local native = NativeBox()
    local overlay = EnsureNativeOverlay()
    if not native or not overlay then return 0 end

    local textWidth = measuredTextWidth or MeasureText(text)
    local editorWidth = math.max(viewWidth, textWidth + EXTRA_EDITOR_WIDTH)
    local editorHeight = math.max(1, overlay:GetHeight() or native:GetHeight() or 1)
    local maxScroll = math.max(0, editorWidth - viewWidth)
    scrollX = math.max(0, math.min(maxScroll, scrollX or 0))
    FSC.editorScrollX = scrollX

    local state = FSC.nativeEditorGeometryState
    local unchanged = state
        and state.overlay == overlay
        and state.scrollX == scrollX
        and state.editorWidth == editorWidth
        and state.editorHeight == editorHeight
    if not unchanged then
        native:ClearAnchors()
        if native.ClearDimensions then native:ClearDimensions() end
        native:SetAnchor(TOPLEFT, overlay, TOPLEFT, -scrollX, 0)
        native:SetDimensions(editorWidth, editorHeight)
        FSC.nativeEditorGeometryState = {
            overlay = overlay, scrollX = scrollX,
            editorWidth = editorWidth, editorHeight = editorHeight,
        }
    end
    return scrollX, maxScroll
end

local function ApplyExactNativeScroll(text, cursor, viewWidth)
    local native = NativeBox()
    local overlay = EnsureNativeOverlay()
    if not native or not overlay then return 0 end

    local textWidth = MeasureText(text)
    local cursorX = MeasurePrefix(text, math.max(0, math.min(#text, cursor)))

    -- Same geometry that made the pre-v0.3 native replacement accurate: make
    -- the real EditBox wider than all of its text so ESO never needs its hidden
    -- single-line horizontal scroll, then move the whole control ourselves.
    -- The crucial difference is that this is ESO's ORIGINAL EditBox, so Enter
    -- remains on the stock secure XML handler.
    local scrollX = FSC.editorScrollX or 0
    local relativeCursorX = cursorX - scrollX
    if relativeCursorX > viewWidth - CARET_MARGIN then
        scrollX = cursorX - (viewWidth - CARET_MARGIN)
    elseif relativeCursorX < CARET_MARGIN then
        scrollX = cursorX - CARET_MARGIN
    end
    return ApplyNativeEditorGeometry(text, viewWidth, scrollX, textWidth)
end

local function SyncUnderlineDrawOrder(control)
    local native = NativeBox()
    if not control or not native then return end
    control:SetDrawTier(native:GetDrawTier())
    control:SetDrawLayer(native:GetDrawLayer())
    control:SetDrawLevel(native:GetDrawLevel() + 11)
end

local function EnsureUnderline(index)
    FSC.underlinePool = FSC.underlinePool or {}
    if FSC.underlinePool[index] then return FSC.underlinePool[index] end
    local overlay = EnsureNativeOverlay()
    if not overlay then return nil end

    local line = wm:CreateControl("FlamechasersSpellcheckUnderline" .. index, overlay, CT_CONTROL)
    line.waveTiles = {}
    SyncUnderlineDrawOrder(line)
    line:SetMouseEnabled(false)
    line:SetHidden(true)
    FSC.underlinePool[index] = line
    return line
end

local function UpdateWaveTiles(line, width)
    if not line then return end
    local underlineAlpha = FSC:GetUnderlineAlpha()
    local ur, ug, ub, ua = 1, 0.12, 0.12, 1
    ur, ug, ub, ua = FSC:GetUnderlineColor()
    local tileCount = math.max(1, math.ceil(width / WAVE_TILE_WIDTH))
    for i = 1, tileCount do
        local tile = line.waveTiles[i]
        if not tile then
            tile = wm:CreateControl(line:GetName() .. "Tile" .. i, line, CT_TEXTURE)
            tile:SetTexture("FlamechasersSpellcheck/media/underline.dds")
            tile:SetMouseEnabled(false)
            SyncUnderlineDrawOrder(tile)
            line.waveTiles[i] = tile
        end
        tile:SetColor(ur, ug, ub, underlineAlpha * (ua or 1))
        local remaining = math.max(1, width - ((i - 1) * WAVE_TILE_WIDTH))
        local tileWidth = math.min(WAVE_TILE_WIDTH, remaining)
        tile:ClearAnchors()
        tile:SetAnchor(TOPLEFT, line, TOPLEFT, (i - 1) * WAVE_TILE_WIDTH, 0)
        tile:SetDimensions(tileWidth, WAVE_HEIGHT)
        tile:SetHidden(false)
    end
    for i = tileCount + 1, #line.waveTiles do
        line.waveTiles[i]:SetHidden(true)
    end
end

local function SetChipBackgroundColor(chip, r, g, b, a)
    for _, part in ipairs(chip and chip.backgroundParts or {}) do
        part:SetColor(r, g, b, a)
    end
end

function FSC:ApplyAppearanceSettings()
    local underlineAlpha = self:GetUnderlineAlpha()
    local ur, ug, ub, ua = self:GetUnderlineColor()
    for _, line in ipairs(self.underlinePool or {}) do
        for _, tile in ipairs(line.waveTiles or {}) do
            tile:SetColor(ur, ug, ub, underlineAlpha * (ua or 1))
        end
    end

    local style = AutocompleteStyle()
    local backgroundOpacity = self:GetSuggestionBackgroundOpacity()
    local bar = self.autocompleteBar
    if bar then
        bar:SetHeight(AutocompleteHeight())
        if bar.background then
            bar.background:SetColor(AUTOCOMPLETE_BAR_BACKGROUND_TINT, AUTOCOMPLETE_BAR_BACKGROUND_TINT, AUTOCOMPLETE_BAR_BACKGROUND_TINT, 1)
            bar.background:SetAlpha(backgroundOpacity)
            bar.background:SetHidden(style ~= "bar")
        end
        for _, divider in ipairs(bar.dividers or {}) do
            divider:SetColor(0.92, 0.90, 0.84, self:GetSuggestionDividerAlpha())
            if style ~= "bar" then divider:SetHidden(true) end
        end
    end
    for _, chip in ipairs(self.autocompleteChips or {}) do
        if chip.label then
            chip.label:SetFont(self:GetSuggestionFont())
            chip.label:SetScale(self:GetSuggestionTextScale())
        end
        if chip.backgroundParts then
            for _, part in ipairs(chip.backgroundParts) do part:SetHidden(style ~= "boxes") end
            if style == "boxes" then SetChipBackgroundColor(chip, AUTOCOMPLETE_BOX_BACKGROUND_TINT, AUTOCOMPLETE_BOX_BACKGROUND_TINT, AUTOCOMPLETE_BOX_BACKGROUND_TINT, 0.96 * backgroundOpacity) end
        end
    end
    self:RefreshAutocompleteKeyboardSelection()
end

local function HideUnderlines(first)
    for i = first, #(FSC.underlinePool or {}) do
        FSC.underlinePool[i]:SetHidden(true)
    end
end

local function MouseIsInsideControl(control)
    if not control or control:IsHidden() then return false end
    local x, y = GetUIMousePosition()
    if not x or not y then return false end
    local left, right = control:GetLeft(), control:GetRight()
    local top, bottom = control:GetTop(), control:GetBottom()
    if not left or not right or not top or not bottom then return false end
    return x >= left and x <= right and y >= top and y <= bottom
end

-- Convert the current mouse X coordinate into the nearest EditBox cursor index.
-- The native box is widened and shifted by editorScrollX, so the visible mouse
-- position maps directly back into the same measured text coordinate system used
-- by the underline renderer.
local function CursorPositionFromMouse()
    local native = NativeBox()
    local overlay = FSC.nativeOverlay or EnsureNativeOverlay()
    if not native or not overlay then return nil end

    local mouseX = GetUIMousePosition()
    local left = overlay:GetLeft() or 0
    if not mouseX then return nil end

    local text = native:GetText() or ""
    local targetX = math.max(0, mouseX - left + (FSC.editorScrollX or 0))
    if targetX <= 0 or text == "" then return 0 end

    local fullWidth = MeasureText(text)
    if targetX >= fullWidth then return #text end

    -- Find the first character boundary whose measured prefix reaches the mouse.
    local low, high = 0, #text
    while low < high do
        local mid = math.floor((low + high) / 2)
        if MeasurePrefix(text, mid) < targetX then
            low = mid + 1
        else
            high = mid
        end
    end

    local rightIndex = low
    local leftIndex = math.max(0, rightIndex - 1)
    local leftWidth = MeasurePrefix(text, leftIndex)
    local rightWidth = MeasurePrefix(text, rightIndex)
    if math.abs(targetX - leftWidth) <= math.abs(rightWidth - targetX) then
        return leftIndex
    end
    return rightIndex
end

function FSC:BeginMouseTextSelection()
    local native = NativeBox()
    if not native then return end
    local position = CursorPositionFromMouse()
    if position == nil then return end

    -- A new mouse action takes ownership of the caret/viewport immediately.
    -- Any lock left behind by a completed drag-selection is no longer relevant.
    self.mouseSelectionViewportLock = nil

    IgnoreMouseDownEditFocusLoss()
    native:TakeFocus()
    native:ClearSelection()
    native:SetCursorPosition(position)

    self.nativeMouseEditing = true
    self.mouseSelectionAnchor = position
    self.mouseSelectionPosition = position
    self:HideAutocompleteBar()
end

function FSC:UpdateMouseTextSelection()
    if not self.nativeMouseEditing then return end
    local native = NativeBox()
    local overlay = self.nativeOverlay or EnsureNativeOverlay()
    if not native or not overlay then return end

    -- ESO's native single-line EditBox would normally scroll while a selection drag
    -- reaches an edge. Spellcheck deliberately disables that hidden scroll by widening
    -- and shifting the real EditBox, so reproduce only the edge-scroll portion here.
    -- This keeps selection native while allowing the mouse to continue through text
    -- that is currently clipped off either side of the input field.
    local mouseX = GetUIMousePosition()
    local left, right = overlay:GetLeft(), overlay:GetRight()
    local viewWidth = overlay:GetWidth() or 0
    if mouseX and left and right and viewWidth > 0 then
        local delta = 0
        if mouseX >= right - MOUSE_SELECTION_EDGE_ZONE then
            local outside = math.max(0, mouseX - right)
            delta = math.min(MOUSE_SELECTION_MAX_SCROLL_STEP,
                MOUSE_SELECTION_SCROLL_STEP + (outside * 0.55))
        elseif mouseX <= left + MOUSE_SELECTION_EDGE_ZONE then
            local outside = math.max(0, left - mouseX)
            delta = -math.min(MOUSE_SELECTION_MAX_SCROLL_STEP,
                MOUSE_SELECTION_SCROLL_STEP + (outside * 0.55))
        end
        if delta ~= 0 then
            local text = native:GetText() or ""
            local textWidth = MeasureText(text)
            local selectionMaxScroll = math.max(0, textWidth - viewWidth + CARET_MARGIN)
            local requested = math.max(0, math.min(selectionMaxScroll, (self.editorScrollX or 0) + delta))
            ApplyNativeEditorGeometry(text, viewWidth, requested, textWidth)
        end
    end

    local position = CursorPositionFromMouse()
    if position == nil or position == self.mouseSelectionPosition then return end

    self.mouseSelectionPosition = position
    local anchor = self.mouseSelectionAnchor or position
    if position == anchor then
        native:ClearSelection()
        native:SetCursorPosition(position)
    else
        native:SetSelection(math.min(anchor, position), math.max(anchor, position))
    end
end

function FSC:EndMouseTextSelection()
    if not self.nativeMouseEditing then return end
    self:UpdateMouseTextSelection()

    local native = NativeBox()
    if native and native:HasSelection() then
        -- SetSelection keeps the native selection correctly, but ESO reports the caret
        -- at one selection endpoint after mouse-up. A normal caret-follow refresh would
        -- then scroll that endpoint into view and make a completed leftward selection
        -- snap all the way back to the right. Preserve the exact viewport where the
        -- drag ended until the user actually changes this selection/caret/text.
        self.mouseSelectionViewportLock = {
            text = native:GetText() or "",
            anchor = self.mouseSelectionAnchor,
            position = self.mouseSelectionPosition,
            scrollX = self.editorScrollX or 0,
        }
    else
        self.mouseSelectionViewportLock = nil
    end

    self.nativeMouseEditing = false
    self.mouseSelectionAnchor = nil
    self.mouseSelectionPosition = nil
    if native and not native:HasFocus() then native:TakeFocus() end
    self:ScheduleRefresh(0)
end

function FSC:HideAutocompleteBar()
    self.autocompleteState = nil
    self.autocompleteKeyboardIndex = nil
    self.autocompleteCenterOnly = false
    if self.autocompleteBar then self.autocompleteBar:SetHidden(true) end
    for _, chip in ipairs(self.autocompleteChips or {}) do chip:SetHidden(true) end

    -- Once predictions have appeared during the current chat-entry session, keep
    -- the utility row in suggestion mode until the user actually leaves chat.
    -- Candidate lists naturally dip to zero for a frame while tokens/spaces are
    -- changing; restoring the stock icons at those moments causes distracting
    -- icon/prediction flicker even though nothing is functionally wrong.
    self:SetChatUtilitySuggestionMode(self.autocompleteSuggestionSessionActive == true)
end

function FSC:ResetAutocompleteSuggestionSession()
    self.autocompleteSuggestionSessionActive = false
    self:HideAutocompleteBar()
end

local function FormatAutocompleteWord(context, word)
    if not context or not word then return word end
    if context.rawPrefix and context.rawPrefix ~= "" then
        return FSC:ApplyCase(context.rawPrefix, word)
    end
    local before = (context.text or ""):sub(1, math.max(0, (context.tokenStart or 1) - 1))
    if before:match("^%s*$") or before:match("[%.%!%?]%s*$") then
        return string.upper(word:sub(1, 1)) .. word:sub(2)
    end
    return word
end

local function RefreshAutocompleteChipVisual(chip)
    if not chip or not chip.label then return end
    local selected = FSC.autocompleteKeyboardIndex == chip.index
    local hovered = chip.mouseHovered == true
    local nr, ng, nb, na = 0.82, 0.82, 0.82, 1
    local sr, sg, sb, sa = 1.00, 0.84, 0.40, 1
    nr, ng, nb, na = FSC:GetSuggestionTextColor()
    sr, sg, sb, sa = FSC:GetSuggestionSelectedColor()

    if selected then
        chip.label:SetColor(sr, sg, sb, sa)
    elseif hovered then
        chip.label:SetColor(
            nr + (sr - nr) * 0.20,
            ng + (sg - ng) * 0.20,
            nb + (sb - nb) * 0.20,
            math.max(na, 0.90)
        )
    else
        chip.label:SetColor(nr, ng, nb, na)
    end

    if chip.backgroundParts then
        local opacity = FSC:GetSuggestionBackgroundOpacity()
        local alpha = selected and 1.00 or (hovered and 0.98 or 0.96)
        SetChipBackgroundColor(chip, AUTOCOMPLETE_BOX_BACKGROUND_TINT, AUTOCOMPLETE_BOX_BACKGROUND_TINT, AUTOCOMPLETE_BOX_BACKGROUND_TINT, alpha * opacity)
    end

    if chip.selectionLine then
        chip.selectionLine:SetHidden(not selected)
        chip.selectionLine:SetColor(sr, sg, sb, sa)
        if selected then
            local textWidth = chip.label.GetTextWidth and chip.label:GetTextWidth() or 0
            local maxWidth = math.max(AUTOCOMPLETE_SELECTION_MIN_WIDTH, (chip:GetWidth() or 0) - 28)
            local width = math.max(AUTOCOMPLETE_SELECTION_MIN_WIDTH, math.min(AUTOCOMPLETE_SELECTION_MAX_WIDTH, textWidth + 6, maxWidth))
            chip.selectionLine:SetWidth(width)
        end
    end
end

function FSC:RefreshAutocompleteKeyboardSelection()
    for _, chip in ipairs(self.autocompleteChips or {}) do
        RefreshAutocompleteChipVisual(chip)
    end
end

function FSC:CycleAutocompleteSuggestion()
    local state = self.autocompleteState
    local suggestions = state and state.suggestions
    if not suggestions then return end
    if self.autocompleteCenterOnly then
        self.autocompleteKeyboardIndex = 2
        self:RefreshAutocompleteKeyboardSelection()
        return
    end
    local order = { 2, 3, 1 } -- center -> right -> left
    local current = self.autocompleteKeyboardIndex or 2
    local currentPos = 0
    for i = 1, #order do
        if order[i] == current then currentPos = i break end
    end
    for step = 1, #order do
        local pos = ((currentPos + step - 1) % #order) + 1
        local slot = order[pos]
        if suggestions[slot] then
            self.autocompleteKeyboardIndex = slot
            self:RefreshAutocompleteKeyboardSelection()
            return
        end
    end
end

local function NativeAutocompleteIsOpen()
    local entry = CHAT_SYSTEM.textEntry
    if entry.targetAutoComplete and entry.targetAutoComplete.IsOpen and entry.targetAutoComplete:IsOpen() then return true end
    if entry.slashCommandAutoComplete and entry.slashCommandAutoComplete.IsOpen and entry.slashCommandAutoComplete:IsOpen() then return true end
    return false
end

local function CanUseAutocompleteKeyboard()
    if not FSC:IsAutocompleteEnabled() then return false end
    local native = NativeBox()
    if not FSC.customActive or FSC.menuOpen or not native or not native:HasFocus() then return false end
    local state = FSC.autocompleteState
    local suggestions = state and state.suggestions
    if not suggestions or not (suggestions[1] or suggestions[2] or suggestions[3]) then return false end
    if NativeAutocompleteIsOpen() then return false end
    return true
end

function FSC:HandleAcceptSuggestionKeybind()
    if not CanUseAutocompleteKeyboard() then return false end
    self:AcceptAutocompleteSuggestion(self.autocompleteKeyboardIndex or 2)
    return true
end

function FSC:HandleNavigateSuggestionKeybind()
    if not CanUseAutocompleteKeyboard() then return false end
    self:CycleAutocompleteSuggestion()
    return true
end

function FSC:PollAutocompleteControlKey()
    local ctrlDown = IsControlKeyDown()
    local native = NativeBox()

    if not self.customActive or not native then
        self.autocompleteCtrlWasDown = ctrlDown
        self.autocompleteCtrlStartText = nil
        self.autocompleteCtrlStartCursor = nil
        self.autocompleteCtrlStartedWithSelection = nil
        return
    end

    if ctrlDown and not self.autocompleteCtrlWasDown then
        -- Delay the action until Ctrl is RELEASED. That lets normal Ctrl+A/V/Z
        -- change the text/selection first; those combinations then cancel the
        -- suggestion cycle instead of stealing a modifier shortcut.
        self.autocompleteCtrlStartText = native:GetText() or ""
        self.autocompleteCtrlStartCursor = native:GetCursorPosition() or 0
        self.autocompleteCtrlStartedWithSelection = native:HasSelection()
    elseif not ctrlDown and self.autocompleteCtrlWasDown then
        local unchanged = (native:GetText() or "") == (self.autocompleteCtrlStartText or "")
            and (native:GetCursorPosition() or 0) == (self.autocompleteCtrlStartCursor or 0)
            and not native:HasSelection()
            and not self.autocompleteCtrlStartedWithSelection

        if unchanged
            and not IsShiftKeyDown()
            and not IsAltKeyDown()
            and CanUseAutocompleteKeyboard() then
            self:CycleAutocompleteSuggestion()
        end

        self.autocompleteCtrlStartText = nil
        self.autocompleteCtrlStartCursor = nil
        self.autocompleteCtrlStartedWithSelection = nil
    end

    self.autocompleteCtrlWasDown = ctrlDown
end

local function KeepNativeFocus()
    IgnoreMouseDownEditFocusLoss()
    zo_callLater(function()
        local native = NativeBox()
        if native and CHAT_SYSTEM:IsTextEntryOpen() and not native:HasFocus() then
            native:TakeFocus()
        end
    end, 0)
end

local function CreateAutocompleteBar()
    if FSC.autocompleteBar then return end
    local bar = wm:CreateTopLevelWindow("FlamechasersSpellcheckAutocompleteBar")
    bar:SetHeight(AutocompleteHeight())
    bar:SetMouseEnabled(true)
    bar:SetHidden(true)
    bar:SetDrawTier(DT_HIGH)
    bar:SetDrawLayer(DL_OVERLAY)
    bar:SetDrawLevel(50)
    FSC.autocompleteBar = bar
    FSC.autocompleteChips = {}

    -- One real alpha-gradient texture instead of stacked tinted bands. ESO can
    -- clip/fade the built-in tooltip-center texture unpredictably, which made the
    -- previous transition almost invisible. This custom DXT5 texture starts fully
    -- transparent at the history edge, reaches a slightly darker lane tint around
    -- the upper third, then stays constant behind the suggestion labels.
    local background = wm:CreateControl(bar:GetName() .. "Background", bar, CT_TEXTURE)
    background:SetAnchorFill(bar)
    background:SetTexture(AUTOCOMPLETE_BAR_TEXTURE)
    background:SetTextureCoords(0, 1, 0, 1)
    background:SetColor(AUTOCOMPLETE_BAR_BACKGROUND_TINT, AUTOCOMPLETE_BAR_BACKGROUND_TINT, AUTOCOMPLETE_BAR_BACKGROUND_TINT, 1)
    background:SetMouseEnabled(false)
    background:SetDrawLevel(bar:GetDrawLevel())
    background:SetAlpha(FSC:GetSuggestionBackgroundOpacity())
    bar.background = background

    bar.dividers = {}
    for i = 1, 2 do
        local divider = wm:CreateControl(bar:GetName() .. "Divider" .. i, bar, CT_TEXTURE)
        divider:SetTexture(AUTOCOMPLETE_DIVIDER_TEXTURE)
        divider:SetTextureCoords(0, 1, 0, 1)
        divider:SetColor(0.92, 0.90, 0.84, FSC:GetSuggestionDividerAlpha())
        divider:SetWidth(AUTOCOMPLETE_DIVIDER_WIDTH)
        divider:SetMouseEnabled(false)
        divider:SetDrawLevel(bar:GetDrawLevel() + 1)
        bar.dividers[i] = divider
    end

    bar:SetHandler("OnMouseDown", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then KeepNativeFocus() end
    end)

    for index = 1, 3 do
        local chip = wm:CreateControl("FlamechasersSpellcheckAutocompleteChip" .. index, bar, CT_CONTROL)
        chip:SetMouseEnabled(true)
        chip:SetHidden(true)
        chip.index = index
        chip:SetDrawTier(bar:GetDrawTier())
        chip:SetDrawLayer(bar:GetDrawLayer())
        chip:SetDrawLevel(bar:GetDrawLevel() + 2)

        -- Rounded-box mode reuses the same suggestion controls and interaction
        -- logic. These seven fixed-radius pieces are simply hidden in bar mode.
        chip.backgroundParts = {}
        local function AddBackgroundPart(suffix, texture)
            local part = wm:CreateControl(chip:GetName() .. suffix, chip, CT_TEXTURE)
            part:SetTexture(texture or "FlamechasersSpellcheck/media/suggestion_bg.dds")
            part:SetMouseEnabled(false)
            part:SetHidden(AutocompleteStyle() ~= "boxes")
            chip.backgroundParts[#chip.backgroundParts + 1] = part
            return part
        end

        local center = AddBackgroundPart("BackgroundCenter")
        center:SetAnchor(TOPLEFT, chip, TOPLEFT, AUTOCOMPLETE_BOX_RADIUS, 0)
        center:SetAnchor(BOTTOMRIGHT, chip, BOTTOMRIGHT, -AUTOCOMPLETE_BOX_RADIUS, 0)

        local left = AddBackgroundPart("BackgroundLeft")
        left:SetAnchor(TOPLEFT, chip, TOPLEFT, 0, AUTOCOMPLETE_BOX_RADIUS)
        left:SetAnchor(BOTTOMLEFT, chip, BOTTOMLEFT, 0, -AUTOCOMPLETE_BOX_RADIUS)
        left:SetWidth(AUTOCOMPLETE_BOX_RADIUS)

        local right = AddBackgroundPart("BackgroundRight")
        right:SetAnchor(TOPRIGHT, chip, TOPRIGHT, 0, AUTOCOMPLETE_BOX_RADIUS)
        right:SetAnchor(BOTTOMRIGHT, chip, BOTTOMRIGHT, 0, -AUTOCOMPLETE_BOX_RADIUS)
        right:SetWidth(AUTOCOMPLETE_BOX_RADIUS)

        local corners = {
            { "BackgroundTL", "FlamechasersSpellcheck/media/suggestion_corner_tl.dds", TOPLEFT },
            { "BackgroundTR", "FlamechasersSpellcheck/media/suggestion_corner_tr.dds", TOPRIGHT },
            { "BackgroundBL", "FlamechasersSpellcheck/media/suggestion_corner_bl.dds", BOTTOMLEFT },
            { "BackgroundBR", "FlamechasersSpellcheck/media/suggestion_corner_br.dds", BOTTOMRIGHT },
        }
        for _, spec in ipairs(corners) do
            local corner = AddBackgroundPart(spec[1], spec[2])
            corner:SetAnchor(spec[3], chip, spec[3], 0, 0)
            corner:SetDimensions(AUTOCOMPLETE_BOX_RADIUS, AUTOCOMPLETE_BOX_RADIUS)
        end

        local label = wm:CreateControl(chip:GetName() .. "Label", chip, CT_LABEL)
        -- Keep the labels optically centered in the compact lane while preserving
        -- enough horizontal padding that long predictions never crowd the dividers.
        label:SetAnchor(TOPLEFT, chip, TOPLEFT, AUTOCOMPLETE_LABEL_PADDING, 0)
        label:SetAnchor(BOTTOMRIGHT, chip, BOTTOMRIGHT, -AUTOCOMPLETE_LABEL_PADDING, -4)
        label:SetFont(FSC:GetSuggestionFont())
        label:SetScale(FSC:GetSuggestionTextScale())
        label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        label:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE)
        label:SetMouseEnabled(false)
        chip.label = label

        local selectionLine = wm:CreateControl(chip:GetName() .. "Selection", chip, CT_TEXTURE)
        selectionLine:SetAnchor(BOTTOM, chip, BOTTOM, 0, 0)
        selectionLine:SetDimensions(AUTOCOMPLETE_SELECTION_MIN_WIDTH, 2)
        selectionLine:SetTexture("EsoUI/Art/Tooltips/UI-Tooltip-Center.dds")
        selectionLine:SetColor(1.00, 0.72, 0.26, 1.00)
        selectionLine:SetHidden(true)
        selectionLine:SetMouseEnabled(false)
        chip.selectionLine = selectionLine

        chip:SetHandler("OnMouseEnter", function(self)
            self.mouseHovered = true
            RefreshAutocompleteChipVisual(self)
        end)
        chip:SetHandler("OnMouseExit", function(self)
            self.mouseHovered = false
            RefreshAutocompleteChipVisual(self)
        end)
        chip:SetHandler("OnMouseDown", function(self, button)
            if button ~= MOUSE_BUTTON_INDEX_LEFT then return end
            KeepNativeFocus()
            FSC:AcceptAutocompleteSuggestion(self.index)
        end)
        FSC.autocompleteChips[index] = chip
    end
end

function FSC:RefreshAutocompleteBar(text, cursor)
    if not self:IsAutocompleteEnabled() then
        self:HideAutocompleteBar()
        return
    end
    local native = NativeBox()
    local bar = self.autocompleteBar
    if not native or not bar or not self.customActive or self.menuOpen or native:HasSelection() then
        self:HideAutocompleteBar()
        return
    end

    local ranked, context = self:GetAutocompleteSuggestions(text, cursor, 3)
    if not ranked or #ranked == 0 then
        self:HideAutocompleteBar()
        return
    end

    -- Keep the strongest prediction in the middle, matching the dominant mobile
    -- prediction-bar convention. The keyboard navigation order remains center -> right -> left.
    local suggestions = { [2] = ranked[1], [1] = ranked[2], [3] = ranked[3] }
    local oldState = self.autocompleteState
    local contextChanged = not oldState or not oldState.context
        or oldState.context.tokenStart ~= context.tokenStart
        or oldState.context.prefix ~= context.prefix
        or oldState.context.previousWord ~= context.previousWord
        or oldState.context.previousPreviousWord ~= context.previousPreviousWord
    self.autocompleteState = { suggestions = suggestions, context = context, text = text, cursor = cursor }
    if contextChanged or not self.autocompleteKeyboardIndex or not suggestions[self.autocompleteKeyboardIndex] then
        self.autocompleteKeyboardIndex = 2
    end

    local row = self.chatUtilityRow or EnsureChatUtilityRow()
    local editBackdrop = native:GetParent()
    if not row or not editBackdrop then
        self:HideAutocompleteBar()
        return
    end

    -- Prediction-bar mode uses a reserved row. Rounded boxes instead sit at the
    -- same visual position while the history extends behind them, so no blank bar
    -- remains when that style is selected.
    local height = AutocompleteHeight()
    local style = AutocompleteStyle()
    local stripWidth = math.max(1, (editBackdrop:GetWidth() or row:GetWidth() or 1) + AUTOCOMPLETE_BAR_LEFT_EXTEND - AUTOCOMPLETE_SCROLL_GUTTER)

    bar:SetHeight(height)
    local wasHidden = bar:IsHidden()
    bar:SetHidden(false)
    self.autocompleteSuggestionSessionActive = true
    if wasHidden then bar:BringWindowToTop() end
    if bar.background then
        bar.background:SetHidden(style ~= "bar")
        bar.background:SetColor(AUTOCOMPLETE_BAR_BACKGROUND_TINT, AUTOCOMPLETE_BAR_BACKGROUND_TINT, AUTOCOMPLETE_BAR_BACKGROUND_TINT, 1)
        bar.background:SetAlpha(self:GetSuggestionBackgroundOpacity())
    end

    local display = {}
    local visibleCount = 0
    for index = 1, 3 do
        local word = suggestions[index]
        local chip = self.autocompleteChips[index]
        if word then
            display[index] = FormatAutocompleteWord(context, word)
            visibleCount = visibleCount + 1
            if chip and chip.label and chip.fscDisplayText ~= display[index] then
                chip.label:SetText(display[index])
                chip.fscDisplayText = display[index]
            end
        end
        if chip and not word then chip.fscDisplayText = nil end
        if chip and chip.backgroundParts then
            for _, part in ipairs(chip.backgroundParts) do part:SetHidden(style ~= "boxes") end
        end
    end

    if style == "boxes" then
        for _, divider in ipairs(bar.dividers or {}) do divider:SetHidden(true) end

        local maxChipWidth = math.max(AUTOCOMPLETE_BOX_MIN_WIDTH,
            math.min(AUTOCOMPLETE_BOX_MAX_WIDTH, (stripWidth - AUTOCOMPLETE_BOX_GAP * 2) / 3))
        local centerLabel = self.autocompleteChips[2] and self.autocompleteChips[2].label
        local centerTextWidth = centerLabel and centerLabel:GetTextWidth() or 0
        local centerOnly = visibleCount == 1
            or stripWidth < (AUTOCOMPLETE_BOX_MIN_WIDTH * 3 + AUTOCOMPLETE_BOX_GAP * 2)
            or (display[2] and centerTextWidth > ((maxChipWidth - AUTOCOMPLETE_BOX_PADDING) / AUTOCOMPLETE_MIN_TEXT_SCALE))

        self.autocompleteCenterOnly = centerOnly
        if centerOnly then
            self.autocompleteKeyboardIndex = 2
            for index = 1, 3 do
                local chip = self.autocompleteChips[index]
                if chip then chip:SetHidden(index ~= 2 or not display[2]) end
            end
            local chip = self.autocompleteChips[2]
            if chip and display[2] then
                local desired = math.max(AUTOCOMPLETE_BOX_MIN_WIDTH,
                    math.min(stripWidth, AUTOCOMPLETE_BOX_MAX_WIDTH, (chip.label:GetTextWidth() or 0) + AUTOCOMPLETE_BOX_PADDING))
                bar:ClearAnchors()
                bar:SetAnchor(BOTTOM, editBackdrop, TOP, -1, -AUTOCOMPLETE_INPUT_GAP)
                bar:SetDimensions(desired, height)
                chip:ClearAnchors()
                chip:SetAnchorFill(bar)
                chip.mouseHovered = false
                chip:SetHidden(false)
                RefreshAutocompleteChipVisual(chip)
            end
            return
        end

        self.autocompleteCenterOnly = false
        local visible = {}
        local totalWidth = 0
        for index = 1, 3 do
            local chip = self.autocompleteChips[index]
            if chip and display[index] then
                local measured = chip.label:GetTextWidth() or 0
                local width = math.max(AUTOCOMPLETE_BOX_MIN_WIDTH,
                    math.min(maxChipWidth, measured + AUTOCOMPLETE_BOX_PADDING))
                visible[#visible + 1] = { chip = chip, width = width }
                totalWidth = totalWidth + width
            elseif chip then
                chip:SetHidden(true)
            end
        end
        if #visible > 1 then totalWidth = totalWidth + AUTOCOMPLETE_BOX_GAP * (#visible - 1) end

        bar:ClearAnchors()
        bar:SetAnchor(BOTTOM, editBackdrop, TOP, -1, -AUTOCOMPLETE_INPUT_GAP)
        bar:SetDimensions(math.max(1, totalWidth), height)

        local x = 0
        for _, item in ipairs(visible) do
            local chip = item.chip
            chip:ClearAnchors()
            chip:SetAnchor(TOPLEFT, bar, TOPLEFT, x, 0)
            chip:SetDimensions(item.width, height)
            chip.mouseHovered = false
            chip:SetHidden(false)
            RefreshAutocompleteChipVisual(chip)
            x = x + item.width + AUTOCOMPLETE_BOX_GAP
        end
        return
    end

    -- Integrated prediction-bar mode.
    bar:ClearAnchors()
    bar:SetAnchor(BOTTOMLEFT, editBackdrop, TOPLEFT, -AUTOCOMPLETE_BAR_LEFT_EXTEND, -AUTOCOMPLETE_INPUT_GAP)
    bar:SetAnchor(BOTTOMRIGHT, editBackdrop, TOPRIGHT, -AUTOCOMPLETE_SCROLL_GUTTER, -AUTOCOMPLETE_INPUT_GAP)
    bar:SetHeight(height)

    local usableWidth = math.max(1, stripWidth - AUTOCOMPLETE_DIVIDER_WIDTH * 2)
    local leftWidth = math.floor(usableWidth * AUTOCOMPLETE_SIDE_WEIGHT)
    local centerWidth = math.floor(usableWidth * AUTOCOMPLETE_CENTER_WEIGHT)
    local rightWidth = usableWidth - centerWidth - leftWidth
    local centerLabel = self.autocompleteChips[2] and self.autocompleteChips[2].label
    local centerTextWidth = centerLabel and centerLabel:GetTextWidth() or 0
    local centerTextAvailable = math.max(1, centerWidth - AUTOCOMPLETE_LABEL_PADDING * 2)
    local centerOnly = visibleCount == 1
        or (display[2] and centerTextWidth > (centerTextAvailable / AUTOCOMPLETE_MIN_TEXT_SCALE))

    self.autocompleteCenterOnly = centerOnly
    if centerOnly then
        self.autocompleteKeyboardIndex = 2
        for index = 1, 3 do
            local chip = self.autocompleteChips[index]
            if chip then chip:SetHidden(index ~= 2 or not display[2]) end
        end
        local chip = self.autocompleteChips[2]
        if chip and display[2] then
            chip:ClearAnchors()
            chip:SetAnchorFill(bar)
            chip.mouseHovered = false
            chip:SetHidden(false)
            RefreshAutocompleteChipVisual(chip)
        end
        for _, divider in ipairs(bar.dividers or {}) do divider:SetHidden(true) end
        return
    end

    local widths = { leftWidth, centerWidth, rightWidth }
    local x = 0
    for index = 1, 3 do
        local chip = self.autocompleteChips[index]
        if chip then
            chip:ClearAnchors()
            chip:SetAnchor(TOPLEFT, bar, TOPLEFT, x, 0)
            chip:SetDimensions(widths[index], height)
            chip.mouseHovered = false
            if display[index] then
                chip:SetHidden(false)
                RefreshAutocompleteChipVisual(chip)
            else
                chip:SetHidden(true)
            end
        end
        x = x + widths[index]
        if index < 3 then x = x + AUTOCOMPLETE_DIVIDER_WIDTH end
    end

    if bar.dividers then
        local firstX = leftWidth
        local secondX = leftWidth + AUTOCOMPLETE_DIVIDER_WIDTH + centerWidth
        local positions = { firstX, secondX }
        local dividerAlpha = self:GetSuggestionDividerAlpha()
        for i, divider in ipairs(bar.dividers) do
            divider:ClearAnchors()
            divider:SetAnchor(TOPLEFT, bar, TOPLEFT, positions[i], 4)
            divider:SetAnchor(BOTTOMLEFT, bar, BOTTOMLEFT, positions[i], -4)
            divider:SetHidden(dividerAlpha <= 0)
        end
    end
end

function FSC:AcceptAutocompleteSuggestion(index)
    local state = self.autocompleteState
    local native = NativeBox()
    if not state or not native or not self.customActive then return end
    local word = state.suggestions and state.suggestions[index]
    if not word then return end

    local text = native:GetText() or ""
    local cursor = native:GetCursorPosition() or #text
    local context = self:GetAutocompleteContext(text, cursor)
    local old = state.context
    if context.suppressed or not old
        or context.tokenStart ~= old.tokenStart
        or context.prefix ~= old.prefix
        or context.previousWord ~= old.previousWord
        or context.previousPreviousWord ~= old.previousPreviousWord then
        self:RefreshCustomLayout()
        return
    end

    local replacement = FormatAutocompleteWord(context, word)
    local replaceStart, replaceEnd = context.tokenStart, context.tokenEnd
    local before = text:sub(1, replaceStart - 1)
    local after = replaceEnd >= replaceStart and text:sub(replaceEnd + 1) or text:sub(cursor + 1)
    local newText = before .. replacement .. after
    local newCursor = #before + #replacement
    local appendedAutomaticSpace = false
    if after == "" then
        newText = newText .. " "
        newCursor = newCursor + 1
        appendedAutomaticSpace = true
    end

    local maximum = native:GetMaxInputChars() or 350
    if #newText <= maximum then
        self:RecordAutocompleteAcceptance(context.previousWord, word, context.previousPreviousWord, context.previousThirdWord)
        native:SetText(newText)
        native:SetCursorPosition(math.max(0, math.min(#newText, newCursor)))
        native:TakeFocus()
        if appendedAutomaticSpace then
            self.autocompletePendingSpace = { text = newText, spaceIndex = newCursor }
        else
            self.autocompletePendingSpace = nil
        end
    end
    self:RefreshCustomLayout()
end

function FSC:InvalidateInputLayoutCaches()
    self.cachedMisspellingText = nil
    self.cachedMisspellings = nil
    self.cachedMisspellingDictionaryRevision = nil
end

local function GetCachedMisspellings(self, text)
    if not self:IsSpellcheckEnabled() then return {} end
    local revision = self.dictionaryStateRevision or 0
    if self.cachedMisspellingText == text
        and self.cachedMisspellingDictionaryRevision == revision
        and self.cachedMisspellings then
        return self.cachedMisspellings
    end
    local results = self:FindMisspellings(text)
    self.cachedMisspellingText = text
    self.cachedMisspellingDictionaryRevision = revision
    self.cachedMisspellings = results
    return results
end

function FSC:RefreshEditorViewport(text, cursor)
    local native = NativeBox()
    local overlay = EnsureNativeOverlay()
    if not self.customActive or not native or not overlay then return 0 end
    overlay:SetHidden(false)

    text = text ~= nil and text or (native:GetText() or "")
    cursor = cursor ~= nil and cursor or (native:GetCursorPosition() or #text)
    local viewWidth = math.max(1, overlay:GetWidth() or 1)
    local lock = self.mouseSelectionViewportLock
    local preserveMouseSelectionViewport = lock
        and native:HasSelection()
        and text == lock.text
        and (cursor == lock.anchor or cursor == lock.position)

    if preserveMouseSelectionViewport then
        return ApplyNativeEditorGeometry(text, viewWidth, lock.scrollX, MeasureText(text))
    end
    self.mouseSelectionViewportLock = nil
    return ApplyExactNativeScroll(text, cursor, viewWidth)
end

function FSC:RefreshUnderlineLayout(text, scrollX)
    local native = NativeBox()
    local overlay = EnsureNativeOverlay()
    if not self.customActive or not native or not overlay then return end

    text = text ~= nil and text or (native:GetText() or "")
    scrollX = scrollX ~= nil and scrollX or (self.editorScrollX or 0)
    local viewWidth = math.max(1, overlay:GetWidth() or 1)
    local misspellings = GetCachedMisspellings(self, text)
    self.visibleMarkers = {}
    local viewLeft = overlay:GetLeft() or 0
    local viewTop = overlay:GetTop() or 0
    local viewBottom = overlay:GetBottom() or (viewTop + (overlay:GetHeight() or 0))
    local lineIndex = 1
    for _, marker in ipairs(misspellings) do
        local x1 = MeasurePrefix(text, marker.startIndex - 1) - scrollX
        local x2 = MeasurePrefix(text, marker.endIndex) - scrollX
        if x2 < x1 then x1, x2 = x2, x1 end
        if x2 >= 0 and x1 <= viewWidth then
            local cx1, cx2 = math.max(0, x1), math.min(viewWidth, x2)
            local insetL = cx1 > 0 and 3 or 0
            local insetR = cx2 < viewWidth and 3 or 0
            local line = EnsureUnderline(lineIndex)
            if line then
                local underlineX = cx1 + insetL
                local underlineWidth = math.max(1, (cx2 - cx1) - insetL - insetR)
                if line.fscUnderlineX ~= underlineX then
                    line:ClearAnchors()
                    line:SetAnchor(BOTTOMLEFT, overlay, BOTTOMLEFT, underlineX, -1)
                    line.fscUnderlineX = underlineX
                end
                if line.fscUnderlineWidth ~= underlineWidth then
                    line:SetDimensions(underlineWidth, WAVE_HEIGHT)
                    UpdateWaveTiles(line, underlineWidth)
                    line.fscUnderlineWidth = underlineWidth
                end
                line:SetHidden(false)
                lineIndex = lineIndex + 1
            end
            marker.absoluteX1 = viewLeft + cx1
            marker.absoluteX2 = viewLeft + cx2
            marker.absoluteY1 = viewTop
            marker.absoluteY2 = viewBottom
            self.visibleMarkers[#self.visibleMarkers + 1] = marker
        end
    end
    HideUnderlines(lineIndex)
    self.lastUnderlineRenderedText = text
    self.lastUnderlineRenderedDictionaryRevision = self.dictionaryStateRevision or 0
end

function FSC:RefreshCustomLayout()
    local native = NativeBox()
    local overlay = EnsureNativeOverlay()
    if not self.customActive or not native or not overlay then return end
    SyncOverlayGeometry()
    overlay:SetHidden(false)

    local text = native:GetText() or ""
    local cursor = native:GetCursorPosition() or #text
    local scrollX = self:RefreshEditorViewport(text, cursor)

    self:RefreshUnderlineLayout(text, scrollX)
    self:RefreshAutocompleteBar(text, cursor)
    self.overlayState = string.format("native secure editor + exact spellcheck | offset %.1f", scrollX)
end

function FSC:HideTooltip()
    -- v0.3.15: hover correction tooltips were intentionally removed. Keep this
    -- cleanup helper only so an old tooltip cannot survive a /reloadui upgrade.
    if InformationTooltip then ClearTooltip(InformationTooltip) end
end

function FSC:GetMarkerAtMouse()
    if not self.customActive then return nil end
    local x, y = GetUIMousePosition()
    if not x or not y then return nil end
    for _, marker in ipairs(self.visibleMarkers or {}) do
        if x >= marker.absoluteX1 and x <= marker.absoluteX2 and y >= marker.absoluteY1 and y <= marker.absoluteY2 then
            return marker
        end
    end
end

function FSC:FindMarkerAtCaret()
    if not self:IsSpellcheckEnabled() then return nil end
    local native = NativeBox()
    if not native then return nil end
    local text = native:GetText() or ""
    local cursor = native:GetCursorPosition() or 0
    for _, marker in ipairs(GetCachedMisspellings(self, text)) do
        if cursor + 1 >= marker.startIndex and cursor + 1 <= marker.endIndex + 1 then return marker end
    end
end

function FSC:ReplaceMarker(marker, replacement)
    local native = NativeBox()
    if not native or not marker or not replacement then return end
    local text = native:GetText() or ""
    local current = text:sub(marker.startIndex, marker.endIndex)
    if self:NormalizeWord(current) ~= marker.normalized then return end
    replacement = self:ApplyCase(current, replacement)
    local newText = text:sub(1, marker.startIndex - 1) .. replacement .. text:sub(marker.endIndex + 1)
    local cursor = marker.startIndex - 1 + #replacement
    native:SetText(newText)
    native:SetCursorPosition(cursor)
    native:TakeFocus()
    self:RefreshCustomLayout()
end

function FSC:AddUserWord(word)
    local normalized = self:NormalizeWord(word)
    if normalized == "" then return end
    self.saved.userWords[normalized] = true
    self:InvalidateAutocompleteCaches()
    self:InvalidateInputLayoutCaches()
    self:RefreshCustomLayout()
end

function FSC:IgnoreForSession(word)
    local normalized = self:NormalizeWord(word)
    if normalized == "" then return end
    self.sessionIgnored[normalized] = true
    self:InvalidateInputLayoutCaches()
    self:RefreshCustomLayout()
end

function FSC:DismissCorrectionMenu()
    if not self.menuOpen then return end
    self.menuOpen = false
    self.menuDismissing = true
    IgnoreMouseDownEditFocusLoss()
    if ZO_Menu and not ZO_Menu:IsHidden() then ZO_Menu:SetHidden(true) end
    zo_callLater(function()
        FSC.menuDismissing = false
        KeepNativeFocus()
        FSC:RefreshCustomLayout()
    end, 0)
end

function FSC:ShowCorrectionMenu(marker)
    local native = NativeBox()
    if not native or not marker then return end
    self:HideTooltip()
    self:HideAutocompleteBar()
    IgnoreMouseDownEditFocusLoss()
    ClearMenu()
    local correctionContext = self:GetCorrectionContext(native:GetText() or "", marker.startIndex, marker.endIndex)
    local suggestions = self:GetSuggestions(marker.raw, 5, correctionContext)
    if #suggestions > 0 then
        for _, suggestion in ipairs(suggestions) do
            AddCustomMenuItem(self:ApplyCase(marker.raw, suggestion), function()
                FSC.menuOpen = false
                FSC:RecordCorrectionAcceptance(marker.raw, suggestion, correctionContext)
                FSC:ReplaceMarker(marker, suggestion)
            end)
        end
    else
        AddCustomMenuItem("|c888888No correction found|r", function()
            FSC.menuOpen = false
            KeepNativeFocus()
        end)
    end
    AddCustomMenuItem("Add \"" .. marker.raw .. "\" to dictionary", function()
        FSC.menuOpen = false
        FSC:AddUserWord(marker.raw)
        KeepNativeFocus()
    end)
    AddCustomMenuItem("Ignore for this session", function()
        FSC.menuOpen = false
        FSC:IgnoreForSession(marker.raw)
        KeepNativeFocus()
    end)
    self.menuOpen = true
    ShowMenu(native)
end

function FSC:ArmPChatCopyBuffer()
    if self.pChatCopyBufferArmed or not pChat or not pChat.CONSTANTS then return end
    local native = NativeBox()
    if not native then return end
    self.pChatCopyBufferArmed = true
    self.pChatOriginalMaxChatCharCount = pChat.CONSTANTS.maxChatCharCount
    -- Preserve the true ESO limit across repeated pChat copy-line operations in the
    -- same open chat session. A previous long copy may intentionally still have the
    -- native box expanded to PCHAT_COPY_BUFFER_MAX.
    if self.pChatOriginalNativeMaxInputChars == nil then
        self.pChatOriginalNativeMaxInputChars = native:GetMaxInputChars()
    end
    pChat.CONSTANTS.maxChatCharCount = math.max(PCHAT_COPY_BUFFER_MAX, self.pChatOriginalMaxChatCharCount or 0)
    native:SetMaxInputChars(math.max(PCHAT_COPY_BUFFER_MAX, self.pChatOriginalNativeMaxInputChars or 0))
end

function FSC:ReleasePChatCopyBuffer(keepNativeLimit)
    if self.pChatOriginalMaxChatCharCount ~= nil and pChat and pChat.CONSTANTS then
        pChat.CONSTANTS.maxChatCharCount = self.pChatOriginalMaxChatCharCount
    end
    self.pChatOriginalMaxChatCharCount = nil
    self.pChatCopyBufferArmed = false
    if not keepNativeLimit then
        local native = NativeBox()
        if native and self.pChatOriginalNativeMaxInputChars ~= nil then
            native:SetMaxInputChars(self.pChatOriginalNativeMaxInputChars)
        end
        self.pChatOriginalNativeMaxInputChars = nil
    end
end

function FSC:RestorePChatNativeCopyLimit()
    local native = NativeBox()
    if native and self.pChatOriginalNativeMaxInputChars ~= nil then
        native:SetMaxInputChars(self.pChatOriginalNativeMaxInputChars)
    end
    self.pChatOriginalNativeMaxInputChars = nil
end

function FSC:HasEnabledInputFeatures()
    return self:IsSpellcheckEnabled() or self:IsAutocompleteEnabled()
end

function FSC:ScheduleRefresh(delayMs)
    local revision = (self.refreshRevision or 0) + 1
    self.refreshRevision = revision
    zo_callLater(function()
        if FSC.refreshRevision == revision and FSC.customActive then FSC:RefreshCustomLayout() end
    end, delayMs or 20)
end

function FSC:ScheduleLiveDeleteUnderlineRefresh()
    if not self:IsSpellcheckEnabled() then return end
    -- Held Backspace/Delete can change the native EditBox faster than the normal
    -- decoration debounce can settle. Do not make the heavy autocomplete/full-layout
    -- path run at key-repeat speed; instead keep just the inexpensive underline layer
    -- live at a capped cadence. Normal typing never enters this path.
    if self.liveDeleteUnderlineRefreshPending then return end
    self.liveDeleteUnderlineRefreshPending = true
    zo_callLater(function()
        FSC.liveDeleteUnderlineRefreshPending = false
        if not FSC.customActive then return end
        local native = NativeBox()
        if not native then return end
        local text = native:GetText() or ""
        if #text > LIVE_DELETE_UNDERLINE_MAX_TEXT then return end
        local revision = FSC.dictionaryStateRevision or 0
        if FSC.lastUnderlineRenderedText == text
            and FSC.lastUnderlineRenderedDictionaryRevision == revision then
            return
        end
        if text == "" then
            FSC.visibleMarkers = {}
            HideUnderlines(1)
            FSC.lastUnderlineRenderedText = ""
            FSC.lastUnderlineRenderedDictionaryRevision = revision
            return
        end
        FSC:RefreshUnderlineLayout(text, FSC.editorScrollX or 0)
    end, LIVE_DELETE_UNDERLINE_REFRESH_MS)
end

function FSC:SetMousePollInterval(intervalMs)
    if self.mousePollInterval == intervalMs then return end
    EVENT_MANAGER:UnregisterForUpdate(MOUSE_POLL_NAME)
    self.mousePollInterval = intervalMs
    if intervalMs then
        EVENT_MANAGER:RegisterForUpdate(MOUSE_POLL_NAME, intervalMs, function() FSC:OnMousePoll() end)
    end
end

local function ConsumeAutocompleteSpaceBeforePunctuation(self, native, text, cursor)
    local pending = self.autocompletePendingSpace
    if not pending then return text, cursor end

    local baseText = pending.text or ""
    local spaceIndex = tonumber(pending.spaceIndex)
    if not spaceIndex or spaceIndex < 1 or baseText:sub(spaceIndex, spaceIndex) ~= " " then
        self.autocompletePendingSpace = nil
        return text, cursor
    end

    -- Nothing has been typed yet. Keep the pending state only while the caret remains
    -- directly after our generated space; moving the caret means the user has taken
    -- control of that whitespace and we leave it alone.
    if text == baseText then
        if cursor ~= spaceIndex then self.autocompletePendingSpace = nil end
        return text, cursor
    end

    -- Autocomplete only creates this pending space at the end of the input. Accept
    -- appended text only if the exact generated base is still intact; edits/pastes
    -- elsewhere immediately retire the state rather than risking user text.
    if text:sub(1, #baseText) ~= baseText or #text <= #baseText then
        self.autocompletePendingSpace = nil
        return text, cursor
    end

    local firstTyped = text:sub(#baseText + 1, #baseText + 1)
    self.autocompletePendingSpace = nil
    if not AUTOCOMPLETE_ATTACHING_PUNCTUATION[firstTyped] then return text, cursor end

    local updated = text:sub(1, spaceIndex - 1) .. text:sub(spaceIndex + 1)
    local updatedCursor = math.max(0, (cursor or #text) - 1)
    native:SetText(updated)
    native:SetCursorPosition(math.min(#updated, updatedCursor))
    native:TakeFocus()
    return updated, math.min(#updated, updatedCursor)
end

function FSC:DeactivateChatInputUI()
    if self.customActive then
        self.customActive = false
        self.visibleMarkers = {}
        self:HideTooltip()
        HideUnderlines(1)
        self:ResetAutocompleteSuggestionSession()
        if self.nativeOverlay then self.nativeOverlay:SetHidden(true) end
        RestoreNativeLayout()
        self.editorScrollX = 0
        self.nativeEditorGeometryState = nil
        self.mouseSelectionViewportLock = nil
        self.autocompletePendingSpace = nil
        self.overlayState = "native chat overlay idle"
    end
    -- If pChat's temporary copy buffer was armed, restore both pChat's own
    -- maxChatCharCount and ESO's native EditBox limit even if chat closes before
    -- the normal mouse-up cleanup fires. This prevents cross-addon state leakage.
    if self.pChatCopyBufferArmed or self.pChatOriginalMaxChatCharCount ~= nil then
        self:ReleasePChatCopyBuffer(false)
    else
        self:RestorePChatNativeCopyLimit()
    end
    self:SetMousePollInterval(nil)
    self:UnregisterGlobalMouseEvents()
end

function FSC:OnMousePoll()
    local native = NativeBox()
    local open = CHAT_SYSTEM:IsTextEntryOpen() and native

    -- When both visible features are disabled, leave ESO's editor completely stock:
    -- no widened geometry, no 16 ms poller, and no global mouse callbacks.
    if not open or not self:HasEnabledInputFeatures() then
        self:DeactivateChatInputUI()
        return
    end

    self:PollAutocompleteControlKey()

    if not self.customActive then
        self.customActive = true
        self.autocompleteSuggestionSessionActive = false
        self:SetChatUtilitySuggestionMode(false)
        -- Explicitly restore the stock EditBox as the mouse target. Older builds
        -- temporarily disabled it while using a cloned editor; the secure/native
        -- architecture must always leave the real box clickable.
        native:SetMouseEnabled(true)
        local nativeParent = native:GetParent()
        if nativeParent and nativeParent.SetAutoRectClipChildren then
            nativeParent:SetAutoRectClipChildren(true)
        end
        self.autocompleteCtrlWasDown = IsControlKeyDown()
        self.lastPolledText = nil
        self.lastPolledCursor = nil
        self.editorScrollX = 0
        self.mouseSelectionViewportLock = nil
        self.autocompletePendingSpace = nil
    end

    if self.menuOpen and ZO_Menu and ZO_Menu:IsHidden() then
        self.menuOpen = false
        KeepNativeFocus()
    end

    local text = native:GetText() or ""
    local cursor = native:GetCursorPosition() or 0
    text, cursor = ConsumeAutocompleteSpaceBeforePunctuation(self, native, text, cursor)

    -- A long pChat copy may need the native box temporarily expanded while that text
    -- remains in the editor. As soon as the text fits the original ESO limit again,
    -- restore it instead of keeping the relaxed limit for the rest of the chat session.
    if not self.pChatCopyBufferArmed
        and self.pChatOriginalNativeMaxInputChars ~= nil
        and #text <= self.pChatOriginalNativeMaxInputChars then
        self:RestorePChatNativeCopyLimit()
    end
    if text ~= self.lastPolledText or cursor ~= self.lastPolledCursor then
        local previousText = self.lastPolledText
        local textChanged = text ~= previousText
        local textShrank = textChanged and previousText ~= nil and #text < #previousText
        self.lastPolledText = text
        self.lastPolledCursor = cursor
        -- Keep the real EditBox's caret/viewport path immediate and cheap. Spellcheck
        -- underlines and prediction rendering are coalesced separately, so they cannot
        -- delay the native-feeling horizontal scroll while typing or editing.
        if not self.nativeMouseEditing then
            self:RefreshEditorViewport(text, cursor)
            if textShrank then self:ScheduleLiveDeleteUnderlineRefresh() end
            self:ScheduleRefresh(DECORATION_REFRESH_DELAY_MS)
        end
    end

    -- Mouse selection is handled explicitly because the widened/shifted native
    -- EditBox geometry can prevent ESO's built-in hit testing from placing the
    -- caret correctly. SetSelection is still performed on ESO's original EditBox.
    if self.nativeMouseEditing then
        self:UpdateMouseTextSelection()
    end
end

local function OnGlobalMouseDown(_, button)
    if button ~= MOUSE_BUTTON_INDEX_LEFT then return end
    if FSC.customActive and FSC.nativeOverlay and MouseIsInsideControl(FSC.nativeOverlay) then
        -- Use ESO's native EditBox selection API, but calculate the character
        -- position ourselves from the exact visual scroll geometry.
        FSC:BeginMouseTextSelection()
    end
    if pChat and not FSC.menuOpen and ZO_Menu and not ZO_Menu:IsHidden() and MouseIsOver(ZO_Menu) then
        FSC:ArmPChatCopyBuffer()
    end
    if FSC.menuOpen and ZO_Menu and not ZO_Menu:IsHidden() and not MouseIsOver(ZO_Menu) then
        FSC:DismissCorrectionMenu()
    end
end

local function OnGlobalMouseUp(_, button)
    if button == MOUSE_BUTTON_INDEX_LEFT and FSC.nativeMouseEditing then
        FSC:EndMouseTextSelection()
    end

    if button == MOUSE_BUTTON_INDEX_LEFT and FSC.pChatCopyBufferArmed then
        zo_callLater(function()
            local current = NativeBox()
            local originalLimit = FSC.pChatOriginalNativeMaxInputChars or 350
            local keepNative = CHAT_SYSTEM:IsTextEntryOpen() and current
                and #(current:GetText() or "") > originalLimit
            FSC:ReleasePChatCopyBuffer(keepNative)
        end, 0)
        return
    end

    if button ~= MOUSE_BUTTON_INDEX_RIGHT or not FSC.customActive then return end
    if FSC.nativeOverlay and MouseIsInsideControl(FSC.nativeOverlay) then
        IgnoreMouseDownEditFocusLoss()
        local marker = FSC:GetMarkerAtMouse() or FSC:FindMarkerAtCaret()
        if marker then FSC:ShowCorrectionMenu(marker) end
    end
end

function FSC:RegisterGlobalMouseEvents()
    if self.globalMouseEventsRegistered then return end
    EVENT_MANAGER:RegisterForEvent(GLOBAL_MOUSE_DOWN_NAME, EVENT_GLOBAL_MOUSE_DOWN, OnGlobalMouseDown)
    EVENT_MANAGER:RegisterForEvent(GLOBAL_MOUSE_UP_NAME, EVENT_GLOBAL_MOUSE_UP, OnGlobalMouseUp)
    self.globalMouseEventsRegistered = true
end

function FSC:UnregisterGlobalMouseEvents()
    if not self.globalMouseEventsRegistered then return end
    EVENT_MANAGER:UnregisterForEvent(GLOBAL_MOUSE_DOWN_NAME, EVENT_GLOBAL_MOUSE_DOWN)
    EVENT_MANAGER:UnregisterForEvent(GLOBAL_MOUSE_UP_NAME, EVENT_GLOBAL_MOUSE_UP)
    self.globalMouseEventsRegistered = false
end

function FSC:UpdateChatInputActivity()
    local native = NativeBox()
    if not CHAT_SYSTEM:IsTextEntryOpen() or not native or not self:HasEnabledInputFeatures() then
        self:DeactivateChatInputUI()
        return
    end
    self:RegisterGlobalMouseEvents()
    self:SetMousePollInterval(MOUSE_POLL_ACTIVE_MS)
    self:OnMousePoll()
end

function FSC:InitializeUI()
    EnsureMeasureLabel()
    EnsureNativeOverlay()
    CreateAutocompleteBar()
    self:SetupChatUtilityBar()
    local native = NativeBox()
    if not native then return end
    native:SetMouseEnabled(true)

    -- IMPORTANT: Do not create, clone, reparent, replace, or attach handlers to
    -- the chat EditBox. We only widen/re-anchor the ORIGINAL ZOS EditBox for exact
    -- visual scrolling; Enter stays on its original stock XML script.
    -- Only Tab is pre-hooked at the standalone global helper so our prediction can
    -- consume it before ESO rotates whisper targets. This helper is not in the
    -- Enter/SubmitTextEntry call chain.
    if not self.chatTabHooked then
        ZO_PreHook("ZO_ChatTextEntry_Tab", function(control)
            if not CanUseAutocompleteKeyboard() then return false end
            if IsShiftKeyDown() or IsAltKeyDown() or IsControlKeyDown() then return false end
            local expected = TextEntryControl()
            if control ~= expected then return false end
            FSC:AcceptAutocompleteSuggestion(FSC.autocompleteKeyboardIndex or 2)
            return true
        end)
        self.chatTabHooked = true
    end

    -- Keyboard chat opens through StartTextEntry. Wake the fast poller only for
    -- an active text-entry session; OnMousePoll unregisters it when chat closes.
    if not self.chatOpenHooked then
        SecurePostHook(KEYBOARD_CHAT_SYSTEM, "StartTextEntry", function()
            FSC:UpdateChatInputActivity()
        end)
        self.chatOpenHooked = true
    end
    -- Global mouse callbacks are registered only while keyboard chat input is open.
    -- This keeps Spellcheck completely off the gameplay mouse path otherwise.
    self:UpdateChatInputActivity()
end
