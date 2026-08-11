local SC = ShowCP
SC.Display = SC.Display or {}
local Display = SC.Display

local MODULE_ORDER = { "blue", "red", "green" }
local LINE_HEIGHT = 28
local WIDTH = 420
local HEIGHT = LINE_HEIGHT * 4

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

        -- The scene root is owned only by ESO scene visibility. The child control
        -- owns Show CP's module enabled/disabled state so scene transitions can
        -- never override a disabled module.
        local sceneRoot = WINDOW_MANAGER:CreateTopLevelWindow("ShowCP_" .. moduleKey .. "_SceneRoot")
        sceneRoot:SetDimensions(WIDTH, HEIGHT)
        sceneRoot:SetClampedToScreen(true)
        sceneRoot:SetMouseEnabled(false)
        sceneRoot:SetMovable(false)
        sceneRoot:SetDrawLayer(DL_OVERLAY)
        sceneRoot:SetDrawTier(DT_HIGH)

        local control = WINDOW_MANAGER:CreateControl("ShowCP_" .. moduleKey, sceneRoot, CT_CONTROL)
        control:SetAnchorFill(sceneRoot)
        control:SetMouseEnabled(false)

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

        local fragment = ZO_HUDFadeSceneFragment:New(sceneRoot, nil, 0)
        AddHudFragment(fragment)

        self.controls[moduleKey] = {
            sceneRoot = sceneRoot,
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

    local sceneRoot = entry.sceneRoot
    sceneRoot:ClearAnchors()
    sceneRoot:SetAnchor(CENTER, GuiRoot, CENTER, saved.x or 0, saved.y or 0)
    sceneRoot:SetScale(saved.scale or 1)
end

function Display:RefreshVisibility(moduleKey)
    if not self.controls or not SC.saved then return end

    local function Apply(key)
        local entry = self.controls[key]
        local saved = SC.saved[key]
        if not entry or not saved or not entry.control then return end

        -- Module visibility is independent from the HUD scene fragment.
        entry.control:SetHidden(not (SC.saved.enabled and saved.enabled))
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
