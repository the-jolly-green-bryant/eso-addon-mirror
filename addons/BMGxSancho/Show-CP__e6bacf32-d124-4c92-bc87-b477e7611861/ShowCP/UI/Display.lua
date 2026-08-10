local SC = ShowCP
SC.Display = SC.Display or {}
local Display = SC.Display

local MODULE_ORDER = { "blue", "red", "green" }
local LINE_HEIGHT = 28
local WIDTH = 420
local HEIGHT = LINE_HEIGHT * 4
local VISIBILITY_REASON = "ShowCPModuleDisabled"

local function AddHudFragment(fragment)
    if HUD_SCENE then
        HUD_SCENE:AddFragment(fragment)
    end
    if HUD_UI_SCENE then
        HUD_UI_SCENE:AddFragment(fragment)
    end
end

function Display:Initialize()
    self.controls = self.controls or {}

    for _, moduleKey in ipairs(MODULE_ORDER) do
        local module = SC.Modules[moduleKey]
        local control = WINDOW_MANAGER:CreateTopLevelWindow("ShowCP_" .. moduleKey)
        control:SetDimensions(WIDTH, HEIGHT)
        control:SetClampedToScreen(true)
        control:SetMouseEnabled(false)
        control:SetMovable(false)
        control:SetDrawLayer(DL_OVERLAY)
        control:SetDrawTier(DT_HIGH)

        local labels = {}
        for i = 1, 4 do
            local label = WINDOW_MANAGER:CreateControl("ShowCP_" .. moduleKey .. "_Line" .. i, control, CT_LABEL)
            label:SetFont("ZoFontGamepad34")
            label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
            label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
            label:SetColor(unpack(module.color))
            label:SetDimensions(WIDTH, LINE_HEIGHT)
            if i == 1 then
                label:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
            else
                label:SetAnchor(TOPLEFT, labels[i - 1], BOTTOMLEFT, 0, 0)
            end
            label:SetText("-")
            labels[i] = label
        end

        local fragment = ZO_HUDFadeSceneFragment:New(control, nil, 0)
        AddHudFragment(fragment)

        self.controls[moduleKey] = {
            control = control,
            labels = labels,
            fragment = fragment,
        }

        self:ApplyPlacement(moduleKey)
    end

    self:RefreshVisibility()
end

function Display:ApplyPlacement(moduleKey)
    local entry = self.controls and self.controls[moduleKey]
    local saved = SC.saved and SC.saved[moduleKey]
    if not entry or not saved then return end

    local control = entry.control
    control:ClearAnchors()
    control:SetAnchor(CENTER, GuiRoot, CENTER, saved.x or 0, saved.y or 0)
    control:SetScale(saved.scale or 1)
end

function Display:RefreshVisibility(moduleKey)
    if not self.controls or not SC.saved then return end

    local function Apply(key)
        local entry = self.controls[key]
        local saved = SC.saved[key]
        if not entry or not saved or not entry.fragment then return end

        local shouldHide = not (SC.saved.enabled and saved.enabled)
        entry.fragment:SetHiddenForReason(VISIBILITY_REASON, shouldHide, 0, 0)
    end

    if moduleKey then
        Apply(moduleKey)
    else
        for _, key in ipairs(MODULE_ORDER) do
            Apply(key)
        end
    end
end

function Display:SetModuleLines(moduleKey, names)
    local entry = self.controls and self.controls[moduleKey]
    if not entry then return end

    for i = 1, 4 do
        local text = names and names[i]
        entry.labels[i]:SetText((text and text ~= "") and text or "-")
    end
end
