-- ESO Adventurer Suite
-- Mail compose color chooser.
-- Adds Suite-native subject/body color swatches without replacing ESO's SendMail path.

local EPC = ESOProgressionCoach
if not EPC or not WINDOW_MANAGER then return end

local WM = WINDOW_MANAGER
local NAME = (EPC.name or "ESOAdventurerSuite") .. "_MailColorPicker029677"

EPC.MailColorPicker = EPC.MailColorPicker or {}
local M = EPC.MailColorPicker

local DEFAULT_SUBJECT = "A020F0"
local DEFAULT_BODY = "8A2BE2"

local function safeHex(hex, fallback)
    hex = tostring(hex or fallback or "FFFFFF"):upper():gsub("[^0-9A-F]", "")
    if #hex ~= 6 then hex = tostring(fallback or "FFFFFF") end

    -- Match the Suite Group Finder hardening: avoid three identical consecutive
    -- hex digits because some ESO text validators sanitize those patterns.
    local out, previous, run = {}, nil, 0
    for i = 1, #hex do
        local c = hex:sub(i, i)
        if c == previous then run = run + 1 else run = 1 end
        if run > 2 then
            local n = tonumber(c, 16) or 0
            c = string.format("%X", (n + 1) % 16)
            run = 1
        end
        out[#out + 1] = c
        previous = c
    end
    return table.concat(out)
end

local function getSaved()
    if not EPC.saved then return nil end
    EPC.saved.mailColorPicker029677 = EPC.saved.mailColorPicker029677 or {}
    local sv = EPC.saved.mailColorPicker029677
    sv.subjectColor = safeHex(sv.subjectColor, DEFAULT_SUBJECT)
    sv.bodyColor = safeHex(sv.bodyColor, DEFAULT_BODY)
    return sv
end

local function getField(kind)
    if kind == "body" then
        return WM:GetControlByName("ZO_MailSendBodyField")
    end
    return WM:GetControlByName("ZO_MailSendSubjectField")
end

local function stripColorMarkup(text)
    text = tostring(text or "")
    text = text:gsub("|c%x%x%x%x%x%x", ""):gsub("|r", "")
    return text
end

local function fieldHex(kind)
    local sv = getSaved()
    if not sv then return kind == "body" and DEFAULT_BODY or DEFAULT_SUBJECT end
    return safeHex(kind == "body" and sv.bodyColor or sv.subjectColor, kind == "body" and DEFAULT_BODY or DEFAULT_SUBJECT)
end

local function hexRGB(hex)
    local color = ZO_ColorDef and ZO_ColorDef:New(safeHex(hex, "FFFFFF")) or nil
    if color and type(color.UnpackRGB) == "function" then
        return color:UnpackRGB()
    end
    return 1, 1, 1
end

function M:RefreshSwatch(kind)
    local button = self[kind .. "Button"]
    local swatch = button and button.easMailSwatch029677
    if not swatch then return end
    local r, g, b = hexRGB(fieldHex(kind))
    swatch:SetCenterColor(r, g, b, 1)
end

function M:ApplyColor(kind)
    local field = getField(kind)
    if not field or type(field.GetText) ~= "function" or type(field.SetText) ~= "function" then return false end

    local text = stripColorMarkup(field:GetText())
    if text == "" then return false end

    local maxChars
    if kind == "body" then
        maxChars = tonumber(rawget(_G, "MAIL_MAX_BODY_CHARACTERS"))
    else
        maxChars = tonumber(rawget(_G, "MAIL_MAX_SUBJECT_CHARACTERS"))
    end

    local hex = fieldHex(kind)
    local prefix, suffix = "|c" .. hex, "|r"
    if maxChars and maxChars > 0 then
        local room = math.max(0, maxChars - #prefix - #suffix)
        if #text > room then text = text:sub(1, room) end
    end

    field:SetText(prefix .. text .. suffix)
    return true
end

function M:ShowColorPicker(kind)
    local sv = getSaved()
    if not sv or not COLOR_PICKER or not ZO_ColorDef then return end

    local current = ZO_ColorDef:New(fieldHex(kind))
    COLOR_PICKER:Show(function(r, g, b)
        local hex = ZO_ColorDef:New(r, g, b):ToHex():upper():sub(1, 6)
        hex = safeHex(hex, kind == "body" and DEFAULT_BODY or DEFAULT_SUBJECT)
        if kind == "body" then sv.bodyColor = hex else sv.subjectColor = hex end
        M:RefreshSwatch(kind)
        M:ApplyColor(kind)
    end, current:UnpackRGB())
end

local function createSwatch(kind, field)
    if not field then return nil end
    local controlName = "EAS_MailColorPicker_" .. kind
    local existing = WM:GetControlByName(controlName)
    if existing then return existing end

    local button = WM:CreateControl(controlName, field:GetParent(), CT_BUTTON)
    button:SetDimensions(24, 24)
    button:SetMouseEnabled(true)

    if kind == "body" then
        button:SetAnchor(TOPRIGHT, field, TOPLEFT, -7, 0)
    else
        button:SetAnchor(RIGHT, field, LEFT, -7, 0)
    end

    local swatch = WM:CreateControl(nil, button, CT_BACKDROP)
    swatch:SetAnchor(TOPLEFT, button, TOPLEFT, 3, 3)
    swatch:SetAnchor(BOTTOMRIGHT, button, BOTTOMRIGHT, -3, -3)
    swatch:SetMouseEnabled(false)
    swatch:SetEdgeTexture(nil, 1, 1, 1)
    swatch:SetEdgeColor(0.85, 0.82, 0.68, 1)
    button.easMailSwatch029677 = swatch

    button:SetHandler("OnMouseEnter", function(control)
        if type(InitializeTooltip) == "function" and InformationTooltip then
            InitializeTooltip(InformationTooltip, control, RIGHT, 5, 0)
            SetTooltipText(InformationTooltip, kind == "body" and "Choose mail message color" or "Choose mail subject color")
        end
    end)
    button:SetHandler("OnMouseExit", function()
        if type(ClearTooltip) == "function" and InformationTooltip then ClearTooltip(InformationTooltip) end
    end)
    button:SetHandler("OnClicked", function()
        M:ShowColorPicker(kind)
    end)

    return button
end

function M:CreateControls()
    local subject = getField("subject")
    local body = getField("body")
    if not subject or not body then return false end

    self.subjectButton = self.subjectButton or createSwatch("subject", subject)
    self.bodyButton = self.bodyButton or createSwatch("body", body)
    self:RefreshSwatch("subject")
    self:RefreshSwatch("body")
    return self.subjectButton ~= nil and self.bodyButton ~= nil
end

local function initialize()
    getSaved()
    M:CreateControls()

    -- Mail controls may be instantiated after addon load depending on scene order.
    if type(zo_callLater) == "function" then
        zo_callLater(function() M:CreateControls() end, 300)
        zo_callLater(function() M:CreateControls() end, 1200)
    end

    if MAIL_SEND_SCENE and type(MAIL_SEND_SCENE.RegisterCallback) == "function" and not M.sceneHooked029677 then
        M.sceneHooked029677 = true
        MAIL_SEND_SCENE:RegisterCallback("StateChange", function(_, newState)
            if newState == SCENE_SHOWING or newState == SCENE_SHOWN then
                if type(zo_callLater) == "function" then
                    zo_callLater(function() M:CreateControls() end, 0)
                else
                    M:CreateControls()
                end
            end
        end)
    end
end

if EVENT_MANAGER and rawget(_G, "EVENT_ADD_ON_LOADED") then
    EVENT_MANAGER:RegisterForEvent(NAME, EVENT_ADD_ON_LOADED, function(_, addonName)
        if addonName ~= (EPC.name or "ESOAdventurerSuite") then return end
        EVENT_MANAGER:UnregisterForEvent(NAME, EVENT_ADD_ON_LOADED)
        if type(zo_callLater) == "function" then zo_callLater(initialize, 0) else initialize() end
    end)
else
    initialize()
end

EPC.mailColorPicker029677 = true
