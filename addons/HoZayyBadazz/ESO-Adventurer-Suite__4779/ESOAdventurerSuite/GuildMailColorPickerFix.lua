-- ESO Adventurer Suite
-- Guild Mail Management subject/body color controls.
-- This is for ESO's actual Guild Mail Management composer, not normal player mail.

local EPC = ESOProgressionCoach
if not EPC or not WINDOW_MANAGER then return end
if EPC.guildMailColorPickerFix029694 then return end
EPC.guildMailColorPickerFix029694 = true

local WM = WINDOW_MANAGER
local NAME = (EPC.name or "ESOAdventurerSuite") .. "_GuildMailColor029694"
local RIGHT_MOUSE = rawget(_G, "MOUSE_BUTTON_INDEX_RIGHT") or 2
local DEFAULT_SUBJECT = "A020F0"
local DEFAULT_BODY = "8A2BE2"

local function safeHex(hex, fallback)
    local value = tostring(hex or ""):upper():gsub("[^0-9A-F]", "")
    if #value ~= 6 then value = tostring(fallback or "FFFFFF"):upper():gsub("[^0-9A-F]", "") end
    if #value ~= 6 then value = "FFFFFF" end
    return value
end

local function saved()
    if not EPC.saved then return nil end
    EPC.saved.mailColorPicker029677 = EPC.saved.mailColorPicker029677 or {}
    local sv = EPC.saved.mailColorPicker029677
    sv.subjectColor = safeHex(sv.subjectColor, DEFAULT_SUBJECT)
    sv.bodyColor = safeHex(sv.bodyColor, DEFAULT_BODY)
    if sv.guildSubjectEnabled == nil then sv.guildSubjectEnabled = false end
    if sv.guildBodyEnabled == nil then sv.guildBodyEnabled = false end
    return sv
end

local function field(kind)
    local manager = rawget(_G, "GUILD_MAIL_MANAGEMENT_KEYBOARD")
    if manager then
        local control = kind == "body" and manager.sendBody or manager.sendSubject
        if control then return control end
    end
    if kind == "body" then return WM:GetControlByName("ZO_GuildMailManagementSendBodyField") end
    return WM:GetControlByName("ZO_GuildMailManagementSendSubjectField")
end

local function strip(text)
    text = tostring(text or "")
    text = text:gsub("|c%x%x%x%x%x%x", "")
    text = text:gsub("|r", "")
    return text
end

local function colorFor(kind)
    local sv = saved()
    if not sv then return kind == "body" and DEFAULT_BODY or DEFAULT_SUBJECT end
    return safeHex(kind == "body" and sv.bodyColor or sv.subjectColor, kind == "body" and DEFAULT_BODY or DEFAULT_SUBJECT)
end

local function enabled(kind)
    local sv = saved()
    if not sv then return false end
    return kind == "body" and sv.guildBodyEnabled == true or kind ~= "body" and sv.guildSubjectEnabled == true
end

local function setEnabled(kind, value)
    local sv = saved()
    if not sv then return end
    if kind == "body" then sv.guildBodyEnabled = value == true else sv.guildSubjectEnabled = value == true end
end

local function maxChars(kind)
    return tonumber(rawget(_G, kind == "body" and "MAIL_MAX_BODY_CHARACTERS" or "MAIL_MAX_SUBJECT_CHARACTERS"))
end

local function utf8Prefix(text, maxCharacters)
    text = tostring(text or "")
    maxCharacters = tonumber(maxCharacters) or 0
    if maxCharacters <= 0 then return "" end
    local index, count, last = 1, 0, 0
    while index <= #text and count < maxCharacters do
        local byte = text:byte(index) or 0
        local width = byte >= 240 and 4 or byte >= 224 and 3 or byte >= 192 and 2 or 1
        if index + width - 1 > #text then break end
        last = index + width - 1
        index = index + width
        count = count + 1
    end
    return text:sub(1, last)
end

local function hexRGB(hex)
    if ZO_ColorDef then
        local c = ZO_ColorDef:New(safeHex(hex, "FFFFFF"))
        if c and type(c.UnpackRGB) == "function" then return c:UnpackRGB() end
    end
    return 1, 1, 1
end

local G = {}
EPC.GuildMailColorPicker029694 = G

function G:RefreshButton(kind)
    local button = self[kind .. "Button"]
    if not button then return end
    local swatch = button.easSwatch029694
    local label = button.easLabel029694
    if not swatch then return end
    local r, g, b = hexRGB(colorFor(kind))
    local on = enabled(kind)
    swatch:SetCenterColor(r, g, b, on and 1 or 0.35)
    swatch:SetEdgeColor(on and 1 or 0.45, on and 0.82 or 0.45, on and 0.20 or 0.45, on and 1 or 0.8)
    if label then label:SetAlpha(on and 1 or 0.5) end
end

function G:Apply(kind)
    local control = field(kind)
    if not control or type(control.GetText) ~= "function" or type(control.SetText) ~= "function" then return false end

    local original = tostring(control:GetText() or "")
    local clean = strip(original)
    if clean == "" then
        if original ~= "" then control:SetText("") end
        return true
    end

    if not enabled(kind) then
        if original ~= clean then control:SetText(clean) end
        return true
    end

    local prefix, suffix = "|c" .. colorFor(kind), "|r"
    local limit = maxChars(kind)
    if limit and limit > 0 then
        local room = math.max(0, limit - #prefix - #suffix)
        clean = utf8Prefix(clean, room)
    end

    local colored = prefix .. clean .. suffix
    if original ~= colored then control:SetText(colored) end
    return true
end

function G:StripForEditing(kind)
    local control = field(kind)
    if not control or type(control.GetText) ~= "function" or type(control.SetText) ~= "function" then return end
    local original = tostring(control:GetText() or "")
    local clean = strip(original)
    if original ~= clean then control:SetText(clean) end
end

function G:SetEnabled(kind, value)
    setEnabled(kind, value)
    self:RefreshButton(kind)
    self:Apply(kind)
end

function G:Toggle(kind)
    self:SetEnabled(kind, not enabled(kind))
end

function G:ShowPicker(kind)
    local sv = saved()
    if not sv or not COLOR_PICKER or not ZO_ColorDef then return end
    local current = ZO_ColorDef:New(colorFor(kind))
    COLOR_PICKER:Show(function(r, g, b)
        local hex = safeHex(ZO_ColorDef:New(r, g, b):ToHex():upper():sub(1, 6), kind == "body" and DEFAULT_BODY or DEFAULT_SUBJECT)
        if kind == "body" then
            sv.bodyColor = hex
            sv.guildBodyEnabled = true
        else
            sv.subjectColor = hex
            sv.guildSubjectEnabled = true
        end
        G:RefreshButton(kind)
        G:Apply(kind)
    end, current:UnpackRGB())
end

local function tooltip(kind)
    local name = kind == "body" and "Guild Mail Message / Description Color" or "Guild Mail Subject Color"
    return string.format("%s: %s\nLeft-click: choose color\nRight-click: turn color on/off", name, enabled(kind) and "ON" or "OFF")
end

local function makeButton(kind, edit)
    if not edit then return nil end
    local name = "EAS_GuildMailColor_" .. kind
    local existing = WM:GetControlByName(name)
    if existing then return existing end

    local button = WM:CreateControl(name, edit:GetParent(), CT_BUTTON)
    button:SetDimensions(28, 24)
    button:SetMouseEnabled(true)
    if kind == "body" then
        button:SetAnchor(TOPRIGHT, edit, TOPLEFT, -7, 0)
    else
        button:SetAnchor(RIGHT, edit, LEFT, -7, 0)
    end

    local swatch = WM:CreateControl(nil, button, CT_BACKDROP)
    swatch:SetAnchor(TOPLEFT, button, TOPLEFT, 2, 2)
    swatch:SetAnchor(BOTTOMRIGHT, button, BOTTOMRIGHT, -2, -2)
    swatch:SetEdgeTexture(nil, 1, 1, 1)
    swatch:SetMouseEnabled(false)
    button.easSwatch029694 = swatch

    local label = WM:CreateControl(nil, button, CT_LABEL)
    label:SetAnchor(CENTER, button, CENTER, 0, 0)
    label:SetFont("ZoFontGameSmall")
    label:SetText(kind == "body" and "M" or "S")
    label:SetColor(1, 1, 1, 1)
    label:SetMouseEnabled(false)
    button.easLabel029694 = label

    button:SetHandler("OnMouseEnter", function(control)
        if InitializeTooltip and InformationTooltip then
            InitializeTooltip(InformationTooltip, control, RIGHT, 5, 0)
            if SetTooltipText then SetTooltipText(InformationTooltip, tooltip(kind)) end
        end
    end)
    button:SetHandler("OnMouseExit", function() if ClearTooltip and InformationTooltip then ClearTooltip(InformationTooltip) end end)
    button:SetHandler("OnClicked", function() G:ShowPicker(kind) end)
    button:SetHandler("OnMouseUp", function(_, mouseButton, upInside)
        if mouseButton == RIGHT_MOUSE and upInside ~= false then G:Toggle(kind) end
    end)
    return button
end

local function hookField(kind, edit)
    if not edit or edit.easGuildMailColorHook029694 then return end
    edit.easGuildMailColorHook029694 = true
    if type(ZO_PostHookHandler) == "function" then
        ZO_PostHookHandler(edit, "OnFocusGained", function() G:StripForEditing(kind) end)
        ZO_PostHookHandler(edit, "OnFocusLost", function() G:Apply(kind) end)
    end
end

function G:CreateControls()
    local subject = field("subject")
    local body = field("body")
    if not subject or not body then return false end

    self.subjectButton = self.subjectButton or makeButton("subject", subject)
    self.bodyButton = self.bodyButton or makeButton("body", body)
    hookField("subject", subject)
    hookField("body", body)
    self:RefreshButton("subject")
    self:RefreshButton("body")
    self:Apply("subject")
    self:Apply("body")
    return self.subjectButton ~= nil and self.bodyButton ~= nil
end

-- Ensure the color markup is present before ESO's native guild-mail method reads
-- the two edit controls. The original RequestSendGuildMail path remains untouched.
if type(ZO_PreHook) == "function" and rawget(_G, "ZO_GuildMailManagement_Keyboard") then
    ZO_PreHook(ZO_GuildMailManagement_Keyboard, "TrySendMail", function()
        G:Apply("subject")
        G:Apply("body")
        return false
    end)

    ZO_PostHook(ZO_GuildMailManagement_Keyboard, "OnShowing", function()
        if zo_callLater then zo_callLater(function() G:CreateControls() end, 0) else G:CreateControls() end
    end)

    ZO_PostHook(ZO_GuildMailManagement_Keyboard, "OnDeferredInitialize", function()
        if zo_callLater then zo_callLater(function() G:CreateControls() end, 0) else G:CreateControls() end
    end)
end

local function initialize()
    saved()
    G:CreateControls()
    if zo_callLater then
        zo_callLater(function() G:CreateControls() end, 500)
        zo_callLater(function() G:CreateControls() end, 1500)
    end
end

if EVENT_MANAGER and rawget(_G, "EVENT_ADD_ON_LOADED") then
    EVENT_MANAGER:RegisterForEvent(NAME, EVENT_ADD_ON_LOADED, function(_, addonName)
        if addonName ~= (EPC.name or "ESOAdventurerSuite") then return end
        EVENT_MANAGER:UnregisterForEvent(NAME, EVENT_ADD_ON_LOADED)
        if zo_callLater then zo_callLater(initialize, 0) else initialize() end
    end)
else
    initialize()
end
