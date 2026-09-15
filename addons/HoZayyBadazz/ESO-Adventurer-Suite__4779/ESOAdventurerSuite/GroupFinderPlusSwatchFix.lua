-- ESO Adventurer Suite
-- v0.29.671 - Group Finder Plus native color swatch presentation fix.
-- ESO's Group Finder font does not render the Unicode square glyph reliably;
-- replace it with a real backdrop so the selected color is always visible.

local EPC = ESOProgressionCoach
if not EPC or not WINDOW_MANAGER then return end
local GF = EPC.GroupFinderPlus
if type(GF) ~= "table" then return end
local WM = WINDOW_MANAGER

local function colorRGB(kind)
    local sv = type(GF.GetSV) == "function" and GF:GetSV() or nil
    local hex = sv and ((kind == "description") and sv.descriptionColor or sv.titleColor) or "FFFFFF"
    hex = tostring(hex or "FFFFFF"):upper():gsub("[^0-9A-F]", "")
    if #hex ~= 6 then hex = "FFFFFF" end
    local color = ZO_ColorDef and ZO_ColorDef:New(hex) or nil
    if color and type(color.UnpackRGB) == "function" then
        return color:UnpackRGB()
    end
    return 1, 1, 1
end

local function ensureSwatch(kind)
    local button = WM:GetControlByName("EAS_GroupFinderPlus_" .. tostring(kind) .. "Color")
    if not button then return false end

    if type(button.SetText) == "function" then button:SetText("") end

    local swatch = button.epcColorSwatch029671
    if not swatch then
        swatch = WM:CreateControl(nil, button, CT_BACKDROP)
        swatch:SetAnchor(TOPLEFT, button, TOPLEFT, 4, 4)
        swatch:SetAnchor(BOTTOMRIGHT, button, BOTTOMRIGHT, -4, -4)
        swatch:SetMouseEnabled(false)
        swatch:SetEdgeTexture(nil, 1, 1, 1)
        swatch:SetEdgeColor(0.85, 0.82, 0.68, 1)
        button.epcColorSwatch029671 = swatch
    end

    local r, g, b = colorRGB(kind)
    swatch:SetCenterColor(r, g, b, 1)
    return true
end

local function refreshSwatches()
    ensureSwatch("title")
    ensureSwatch("description")
end

if type(GF.CreateNativeEnhancementButtons) == "function" and not GF._easSwatchCreateWrapped029671 then
    GF._easSwatchCreateWrapped029671 = true
    local baseCreate = GF.CreateNativeEnhancementButtons
    function GF:CreateNativeEnhancementButtons(...)
        local result = baseCreate(self, ...)
        refreshSwatches()
        return result
    end
end

if type(GF.ApplyColorToField) == "function" and not GF._easSwatchApplyWrapped029671 then
    GF._easSwatchApplyWrapped029671 = true
    local baseApply = GF.ApplyColorToField
    function GF:ApplyColorToField(kind, ...)
        local result = baseApply(self, kind, ...)
        ensureSwatch(kind)
        return result
    end
end

local function applyNow()
    if type(GF.CreateNativeEnhancementButtons) == "function" then
        GF:CreateNativeEnhancementButtons()
    end
    refreshSwatches()
end

if type(zo_callLater) == "function" then
    zo_callLater(applyNow, 0)
    zo_callLater(applyNow, 500)
else
    applyNow()
end

if EVENT_MANAGER and rawget(_G, "EVENT_PLAYER_ACTIVATED") then
    local key = (EPC.name or "ESOAdventurerSuite") .. "_GroupFinderPlusSwatch029671"
    EVENT_MANAGER:RegisterForEvent(key, EVENT_PLAYER_ACTIVATED, function()
        if type(zo_callLater) == "function" then zo_callLater(applyNow, 200) else applyNow() end
    end)
end

EPC.groupFinderPlusSwatchFix029671 = true
