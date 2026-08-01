-- -------------------------------------------------------------------------------
-- MAIN USER INTERFACE
-- -------------------------------------------------------------------------------

local UIControls = {}
local MS = nil
local TOPLEFT, TOPRIGHT, BOTTOMLEFT, BOTTOMRIGHT, LEFT, RIGHT, CENTER, TOP, BOTTOM =
    TOPLEFT, TOPRIGHT, BOTTOMLEFT, BOTTOMRIGHT, LEFT, RIGHT, CENTER, TOP, BOTTOM
local TEXT_ALIGN_LEFT, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER =
    TEXT_ALIGN_LEFT, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER

-- -------------------------------------------------------------------------------
-- UNIFIED UI CREATION FUNCTIONS
-- -------------------------------------------------------------------------------

local function CreateTopLevelControl(name, offsetY, isHidden, onMoveStopFunction)
    local control = CreateControl(name, GuiRoot, CT_TOPLEVELCONTROL)
    control:SetMouseEnabled(true)
    control:SetMovable(true)
    control:SetClampedToScreen(true)
    control:SetHidden(isHidden or false)
    control:SetAnchor(BOTTOM, GuiRoot, CENTER, 0, offsetY or 0)
    if onMoveStopFunction then
        control:SetHandler("OnMoveStop", function()
            if _G[onMoveStopFunction] then
                _G[onMoveStopFunction]()
            end
        end)
    end
    return control
end

local function CreateBackdrop(name, parent)
    local moduleName = name:match("MS_(%a+)UI_BG") or name:match("MS_(%a+)BG") or name:match("(%a+)BG")
    local alpha = 0.85
    if moduleName and _G.Meterskull and _G.Meterskull.db and _G.Meterskull.db[moduleName] then
        local bgColor = _G.Meterskull.db[moduleName].settings and _G.Meterskull.db[moduleName].settings.backgroundColor
        if bgColor and bgColor[4] then
            alpha = bgColor[4]
        end
    end
    local backdrop = CreateControl(name, parent, CT_BACKDROP)
    backdrop:SetAnchor(CENTER, parent, CENTER, 0, 0)
    backdrop:SetCenterColor(0, 0, 0., 0)
    backdrop:SetEdgeColor(0.6, 0.6, 0.6, 0.5)
    backdrop:SetEdgeTexture("", 2, 2, 2)
    backdrop:SetInsets(2, 2, -2, -2)
    function backdrop:SetDimensions(w, h)
        backdrop:SetWidth(w)
        backdrop:SetHeight(h)
    end
    return backdrop
end

local function CreateLabel(name, parent, text, color)
    local label = CreateControl(name, parent, CT_LABEL)
    if text then label:SetText(text) end
    if color then label:SetColor(unpack(color)) end
    label:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    return label
end

-- -------------------------------------------------------------------------------
-- LAYOUT FUNCTIONS
-- -------------------------------------------------------------------------------

local function ApplySingleRightLayout(controls, config)
    local UIConfig = _G.UILayoutConfig
    local margin = UIConfig and UIConfig.SPACING and UIConfig.SPACING.MARGIN or 10
    local spacing = UIConfig and UIConfig.SPACING and UIConfig.SPACING.LABEL_VALUE or 5
    local topOffset = -8
    local field = config.fields[1]
    local valueControl = controls[field.name]
    local labelControl = controls[field.name .. "Label"]
    labelControl:SetAnchor(RIGHT, controls.bg, RIGHT, -margin, topOffset)
    labelControl:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    valueControl:SetAnchor(RIGHT, labelControl, LEFT, -spacing, -topOffset)
    valueControl:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
end

local function ApplyDualHorizontalLayout(controls, config)
    local UIConfig = _G.UILayoutConfig
    local margin = UIConfig and UIConfig.SPACING and UIConfig.SPACING.MARGIN or 10
    local spacing = UIConfig and UIConfig.SPACING and UIConfig.SPACING.LABEL_VALUE or 5
    local topOffset = -8
    local leftField = config.fields[1]
    local rightField = config.fields[2]
    controls[leftField.name]:SetAnchor(LEFT, controls.bg, LEFT, margin, 0)
    controls[leftField.name]:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    controls[leftField.name .. "Label"]:SetAnchor(LEFT, controls[leftField.name], RIGHT, spacing, topOffset)
    controls[leftField.name .. "Label"]:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    controls[rightField.name .. "Label"]:SetAnchor(RIGHT, controls.bg, RIGHT, -margin, topOffset)
    controls[rightField.name .. "Label"]:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    controls[rightField.name]:SetAnchor(RIGHT, controls[rightField.name .. "Label"], LEFT, -spacing, -topOffset)
    controls[rightField.name]:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
end

local function ApplyDualStackedLayout(controls, config)
    local UIConfig = _G.UILayoutConfig
    local margin = UIConfig and UIConfig.SPACING and UIConfig.SPACING.MARGIN or 10
    local spacing = UIConfig and UIConfig.SPACING and UIConfig.SPACING.LABEL_VALUE or 5
    local verticalSpacing = 20
    local topOffset = -8
    local topField = config.fields[1]
    local bottomField = config.fields[2]

    -- Upper value (anchored to the right, at the top)
    controls[topField.name .. "Label"]:SetAnchor(RIGHT, controls.bg, RIGHT, -margin, -verticalSpacing + topOffset)
    controls[topField.name .. "Label"]:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    controls[topField.name]:SetAnchor(RIGHT, controls[topField.name .. "Label"], LEFT, -spacing, -topOffset)
    controls[topField.name]:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)

    -- Lower value (anchored to the right, at the bottom)
    controls[bottomField.name .. "Label"]:SetAnchor(RIGHT, controls.bg, RIGHT, -margin, verticalSpacing + topOffset)
    controls[bottomField.name .. "Label"]:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    controls[bottomField.name]:SetAnchor(RIGHT, controls[bottomField.name .. "Label"], LEFT, -spacing, -topOffset)
    controls[bottomField.name]:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
end

local function ApplyLayout(controls, config)
    local UIConfig = _G.UILayoutConfig
    if not UIConfig or not UIConfig.LAYOUTS then return end
    if config.layout == UIConfig.LAYOUTS.SINGLE_RIGHT then
        ApplySingleRightLayout(controls, config)
    elseif config.layout == UIConfig.LAYOUTS.DUAL_HORIZONTAL then
        ApplyDualHorizontalLayout(controls, config)
    elseif config.layout == UIConfig.LAYOUTS.DUAL_STACKED then
        ApplyDualStackedLayout(controls, config)
    end
end

-- Scale-aware versions of layout functions
local function ApplySingleRightLayoutWithScale(controls, config, scaleFactor)
    local UIConfig = _G.UILayoutConfig
    local margin = (UIConfig and UIConfig.SPACING and UIConfig.SPACING.MARGIN or 10) * scaleFactor
    local spacing = (UIConfig and UIConfig.SPACING and UIConfig.SPACING.LABEL_VALUE or 5) * scaleFactor
    local topOffset = -8 * scaleFactor
    local field = config.fields[1]
    local valueControl = controls[field.name]
    local labelControl = controls[field.name .. "Label"]
    labelControl:SetAnchor(RIGHT, controls.bg, RIGHT, -margin, topOffset)
    labelControl:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    valueControl:SetAnchor(RIGHT, labelControl, LEFT, -spacing, -topOffset)
    valueControl:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
end

local function ApplyDualHorizontalLayoutWithScale(controls, config, scaleFactor)
    local UIConfig = _G.UILayoutConfig
    local margin = (UIConfig and UIConfig.SPACING and UIConfig.SPACING.MARGIN or 10) * scaleFactor
    local spacing = (UIConfig and UIConfig.SPACING and UIConfig.SPACING.LABEL_VALUE or 5) * scaleFactor
    local topOffset = -8 * scaleFactor
    local leftField = config.fields[1]
    local rightField = config.fields[2]
    controls[leftField.name]:SetAnchor(LEFT, controls.bg, LEFT, margin, 0)
    controls[leftField.name]:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    controls[leftField.name .. "Label"]:SetAnchor(LEFT, controls[leftField.name], RIGHT, spacing, topOffset)
    controls[leftField.name .. "Label"]:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    controls[rightField.name .. "Label"]:SetAnchor(RIGHT, controls.bg, RIGHT, -margin, topOffset)
    controls[rightField.name .. "Label"]:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    controls[rightField.name]:SetAnchor(RIGHT, controls[rightField.name .. "Label"], LEFT, -spacing, -topOffset)
    controls[rightField.name]:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
end

local function ApplyDualStackedLayoutWithScale(controls, config, scaleFactor)
    local UIConfig = _G.UILayoutConfig
    local margin = (UIConfig and UIConfig.SPACING and UIConfig.SPACING.MARGIN or 10) * scaleFactor
    local spacing = (UIConfig and UIConfig.SPACING and UIConfig.SPACING.LABEL_VALUE or 5) * scaleFactor
    local verticalSpacing = 20 * scaleFactor
    local topOffset = -8 * scaleFactor
    local topField = config.fields[1]
    local bottomField = config.fields[2]

    -- Upper value (anchored to the right, at the top)
    controls[topField.name .. "Label"]:SetAnchor(RIGHT, controls.bg, RIGHT, -margin, -verticalSpacing + topOffset)
    controls[topField.name .. "Label"]:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    controls[topField.name]:SetAnchor(RIGHT, controls[topField.name .. "Label"], LEFT, -spacing, -topOffset)
    controls[topField.name]:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)

    -- Lower value (anchored to the right, at the bottom)
    controls[bottomField.name .. "Label"]:SetAnchor(RIGHT, controls.bg, RIGHT, -margin, verticalSpacing + topOffset)
    controls[bottomField.name .. "Label"]:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    controls[bottomField.name]:SetAnchor(RIGHT, controls[bottomField.name .. "Label"], LEFT, -spacing, -topOffset)
    controls[bottomField.name]:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
end

local function ApplyLayoutWithScale(controls, config, scaleFactor)
    local UIConfig = _G.UILayoutConfig
    if not UIConfig or not UIConfig.LAYOUTS then return end
    scaleFactor = scaleFactor or 1.0
    if config.layout == UIConfig.LAYOUTS.SINGLE_RIGHT then
        ApplySingleRightLayoutWithScale(controls, config, scaleFactor)
    elseif config.layout == UIConfig.LAYOUTS.DUAL_HORIZONTAL then
        ApplyDualHorizontalLayoutWithScale(controls, config, scaleFactor)
    elseif config.layout == UIConfig.LAYOUTS.DUAL_STACKED then
        ApplyDualStackedLayoutWithScale(controls, config, scaleFactor)
    end
end

-- -------------------------------------------------------------------------------
-- GENERIC MODULE UI CREATION FUNCTION
-- -------------------------------------------------------------------------------

local function CreateModuleUI(moduleName, config, offsetY, isHidden)
    local baseName = "MS_" .. string.gsub(moduleName, "^%l", string.upper) .. "UI"
    local saveFunction = "MS_" .. string.gsub(moduleName, "^%l", string.upper) .. "UI_SaveLocation"
    local mainControl = CreateTopLevelControl(baseName, offsetY, isHidden, saveFunction)
    mainControl:SetDimensions(config.baseSize.w, config.baseSize.h)
    local bg = CreateBackdrop(baseName .. "BG", mainControl)
    bg:SetDimensions(config.baseSize.w, config.baseSize.h)
    local controls = {
        main = mainControl,
        bg = bg
    }
    for _, field in ipairs(config.fields) do
        local valueControl = CreateLabel(baseName .. field.name, mainControl, nil, nil)
        controls[field.name] = valueControl
        local labelControl = CreateLabel(baseName .. field.name .. "Label", mainControl, field.label, {0.5, 0.5, 0.5, 1})
        controls[field.name .. "Label"] = labelControl
    end
    ApplyLayout(controls, config)
    UIControls[moduleName] = controls
    return mainControl
end

-- -------------------------------------------------------------------------------
-- MODULE UI CREATION
-- -------------------------------------------------------------------------------

local function CreateArmorskullUI()
    local config = _G.ModuleUIConfig and _G.ModuleUIConfig.armorskull
    if not config then return nil end
    return CreateModuleUI("armorskull", config, 100, false)
end
local function CreateHybridArmorskullUI()
    local config = _G.ModuleUIConfig and _G.ModuleUIConfig.hybridarmorskull
    if not config then return nil end
    return CreateModuleUI("hybridarmorskull", config, 200, false)
end
local function CreatePowerskullUI()
    local config = _G.ModuleUIConfig and _G.ModuleUIConfig.powerskull
    if not config then return nil end
    return CreateModuleUI("powerskull", config, 300, false)
end
local function CreateCritskullUI()
    local config = _G.ModuleUIConfig and _G.ModuleUIConfig.critskull
    if not config then return nil end
    return CreateModuleUI("critskull", config, 400, false)
end
local function CreatePenskullUI()
    local config = _G.ModuleUIConfig and _G.ModuleUIConfig.penskull
    if not config then return nil end
    return CreateModuleUI("penskull", config, 500, false)
end
local function CreateHealthskullUI()
    local config = _G.ModuleUIConfig and _G.ModuleUIConfig.healthskull
    if not config then return nil end
    return CreateModuleUI("healthskull", config, 600, true)
end
local function CreateMagskullUI()
    local config = _G.ModuleUIConfig and _G.ModuleUIConfig.magskull
    if not config then return nil end
    return CreateModuleUI("magskull", config, 700, true)
end
local function CreateStamskullUI()
    local config = _G.ModuleUIConfig and _G.ModuleUIConfig.stamskull
    if not config then return nil end
    return CreateModuleUI("stamskull", config, 800, true)
end
local function CreateCritresiskullUI()
    local config = _G.ModuleUIConfig and _G.ModuleUIConfig.critresiskull
    if not config then return nil end
    return CreateModuleUI("critresiskull", config, 900, true)
end

-- -------------------------------------------------------------------------------
-- UI INITIALIZATION
-- -------------------------------------------------------------------------------

function InitializeUI(Meterskull)
    if MS then return end
    MS = Meterskull
    CreateArmorskullUI()
    CreateHybridArmorskullUI()
    CreatePowerskullUI()
    CreateCritskullUI()
    CreatePenskullUI()
    CreateHealthskullUI()
    CreateMagskullUI()
    CreateStamskullUI()
    CreateCritresiskullUI()
    for moduleName, controls in pairs(UIControls) do
        local baseName = "MS_" .. string.gsub(moduleName, "^%l", string.upper) .. "UI"
        _G[baseName] = controls.main
        _G[baseName .. "BG"] = controls.bg
        local config = _G.ModuleUIConfig and _G.ModuleUIConfig[moduleName]
        if config then
            for _, field in ipairs(config.fields) do
                _G[baseName .. field.name] = controls[field.name]
                _G[baseName .. field.name .. "Label"] = controls[field.name .. "Label"]
            end
        end
    end
end

-- -------------------------------------------------------------------------------
-- UI REFERENCES AND MANAGEMENT
-- -------------------------------------------------------------------------------

local UIRefs = {}
local function PopulateUIRefs()
    UIRefs = {}
    for moduleName, controls in pairs(UIControls) do
        UIRefs[moduleName] = controls
    end
    if MS and MS.modules then
        for moduleName, controls in pairs(UIRefs) do
            if MS.modules[moduleName] then
                MS.modules[moduleName].uiRefs = controls
            end
        end
    end
end

function UpdateUILockState()
    if not MS or not MS.db then return end
    local lock = MS.db.sharedSettings.uiLocked
    for _, controls in pairs(UIControls) do
        if controls.main then
            controls.main:SetMovable(not lock)
            controls.main:SetMouseEnabled(not lock)
        end
    end
end

function UpdateUIVisibility()
    if not MS or not MS.db then return end

    for moduleName, mod in pairs(MS.modules) do
        local settingKey = "show" .. string.gsub(moduleName, "^%l", string.upper)
        if MS.db.sharedSettings[settingKey] then
            mod:ToggleVisibility(true)
        else
            mod:ToggleVisibility(false)
        end
    end
end

local LAM_PREVIEW_CONFIG = {
    COLUMN_WIDTH = 220,
    RIGHT_MARGIN = 50,
    TOP_MARGIN = 150,
    ROW_HEIGHT = 70,
}

local fixedPositions = {
    -- Column 1
    armorskull       = { column = 2, row = 1 },
    hybridarmorskull = { column = 2, row = 2 },
    powerskull       = { column = 2, row = 3 },
    critskull        = { column = 2, row = 4 },
    penskull         = { column = 2, row = 5 },
    -- Column 2
    healthskull      = { column = 1, row = 1 },
    magskull         = { column = 1, row = 2 },
    stamskull        = { column = 1, row = 3 },
    critresiskull    = { column = 1, row = 4 },
}

function SetPositionForLAMPreview(control, posConfig)
    local screenWidth  = GuiRoot:GetWidth()
    local cfg = LAM_PREVIEW_CONFIG

    local pixelX = screenWidth - cfg.RIGHT_MARGIN - (posConfig.column * cfg.COLUMN_WIDTH)
    local pixelY = cfg.TOP_MARGIN + ((posConfig.row - 1) * cfg.ROW_HEIGHT)

    control:ClearAnchors()
    control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, pixelX, pixelY)
end

function OnLAMPanelOpened()
    if not MS or not MS.db then return end
    for moduleName, controls in pairs(UIControls) do
        if controls.main and fixedPositions[moduleName] then
            SetPositionForLAMPreview(controls.main, fixedPositions[moduleName])
            local settingKey = "show" .. string.gsub(moduleName, "^%l", string.upper)
            controls.main:SetHidden(not MS.db.sharedSettings[settingKey])
            controls.main:SetMovable(false)
            controls.main:SetMouseEnabled(false)
        end
    end
end

function OnLAMPanelClosed()
    if not MS or not MS.db then return end

    local currentScene = SCENE_MANAGER:GetCurrentScene()
    local isInGame = currentScene and (currentScene:GetName() == "hud" or currentScene:GetName() == "hudui")

    for moduleName, controls in pairs(UIControls) do
        if controls.main and MS.db[moduleName] then
            controls.main:ClearAnchors()
            controls.main:SetAnchor(
                TOPLEFT,
                GuiRoot,
                TOPLEFT,
                MS.db[moduleName].location.x,
                MS.db[moduleName].location.y
            )
            local settingKey = "show" .. string.gsub(moduleName, "^%l", string.upper)
            if isInGame and MS.db.sharedSettings[settingKey] then
                controls.main:SetHidden(false)
            else
                controls.main:SetHidden(true)
            end
        end
    end
    UpdateUILockState()
end

-- -------------------------------------------------------------------------------
-- SAVE LOCATION FUNCTIONS
-- -------------------------------------------------------------------------------

function MS_ArmorskullUI_SaveLocation()
    if MS and MS.modules and MS.modules.armorskull then
        MS.modules.armorskull:SaveLocation()
    end
end
function MS_HybridArmorskullUI_SaveLocation()
    if MS and MS.modules and MS.modules.hybridarmorskull then
        MS.modules.hybridarmorskull:SaveLocation()
    end
end
function MS_PowerskullUI_SaveLocation()
    if MS and MS.modules and MS.modules.powerskull then
        MS.modules.powerskull:SaveLocation()
    end
end
function MS_CritskullUI_SaveLocation()
    if MS and MS.modules and MS.modules.critskull then
        MS.modules.critskull:SaveLocation()
    end
end
function MS_PenskullUI_SaveLocation()
    if MS and MS.modules and MS.modules.penskull then
        MS.modules.penskull:SaveLocation()
    end
end
function MS_HealthskullUI_SaveLocation()
    if MS and MS.modules and MS.modules.healthskull then
        MS.modules.healthskull:SaveLocation()
    end
end
function MS_MagskullUI_SaveLocation()
    if MS and MS.modules and MS.modules.magskull then
        MS.modules.magskull:SaveLocation()
    end
end
function MS_StamskullUI_SaveLocation()
    if MS and MS.modules and MS.modules.stamskull then
        MS.modules.stamskull:SaveLocation()
    end
end
function MS_CritresiskullUI_SaveLocation()
    if MS and MS.modules and MS.modules.critresiskull then
        MS.modules.critresiskull:SaveLocation()
    end
end

-- -------------------------------------------------------------------------------
-- SCALE-AWARE LAYOUT FUNCTIONS
-- -------------------------------------------------------------------------------

-- Calculates the scale factor from a customScale value (0-100)
local function CalculateScaleFactor(customScale)
    if not customScale then return 1.0 end
    local UIConfig = _G.UILayoutConfig
    local scaleConfig = UIConfig and UIConfig.SCALE_FORMULA
    if scaleConfig then
        local defaultValue = scaleConfig.DEFAULT_VALUE or 20
        if customScale == defaultValue then
            return 1.0
        elseif customScale < defaultValue then
            local ratio = customScale / defaultValue
            return scaleConfig.MIN_SCALE + (1.0 - scaleConfig.MIN_SCALE) * ratio
        else
            local ratio = (customScale - defaultValue) / (100 - defaultValue)
            return 1.0 + (scaleConfig.MAX_SCALE - 1.0) * ratio
        end
    else
        return 0.5 + (customScale * 2.5 / 100)
    end
end

-- Recalculates the layout of a specific module based on the scale
function RecalculateModuleLayout(moduleName, customScale)
    if not UIControls[moduleName] then return end

    local controls = UIControls[moduleName]
    local config = _G.ModuleUIConfig and _G.ModuleUIConfig[moduleName]
    if not config then return end

    local scaleFactor = CalculateScaleFactor(customScale)

    -- Remove all existing anchors for field controls
    for _, field in ipairs(config.fields) do
        local valueControl = controls[field.name]
        local labelControl = controls[field.name .. "Label"]
        if valueControl then valueControl:ClearAnchors() end
        if labelControl then labelControl:ClearAnchors() end
    end

    -- Reapply the layout with proportional scaling
    ApplyLayoutWithScale(controls, config, scaleFactor)
end

-- Recalculates the layout of all modules
function RecalculateAllModuleLayouts()
    if not MS or not MS.db then return end

    for moduleName, controls in pairs(UIControls) do
        local moduleDB = MS.db[moduleName]
        if moduleDB and moduleDB.settings and moduleDB.settings.customScale then
            RecalculateModuleLayout(moduleName, moduleDB.settings.customScale)
        end
    end
end

_G.PopulateUIRefs = PopulateUIRefs
_G.InitializeUI = InitializeUI
_G.UpdateUILockState = UpdateUILockState
_G.UpdateUIVisibility = UpdateUIVisibility
_G.OnLAMPanelOpened = OnLAMPanelOpened
_G.OnLAMPanelClosed = OnLAMPanelClosed
_G.RecalculateModuleLayout = RecalculateModuleLayout
_G.RecalculateAllModuleLayouts = RecalculateAllModuleLayouts
_G.MS_ArmorskullUI_SaveLocation = MS_ArmorskullUI_SaveLocation
_G.MS_HybridArmorskullUI_SaveLocation = MS_HybridArmorskullUI_SaveLocation
_G.MS_PowerskullUI_SaveLocation = MS_PowerskullUI_SaveLocation
_G.MS_CritskullUI_SaveLocation = MS_CritskullUI_SaveLocation
_G.MS_PenskullUI_SaveLocation = MS_PenskullUI_SaveLocation
_G.MS_HealthskullUI_SaveLocation = MS_HealthskullUI_SaveLocation
_G.MS_MagskullUI_SaveLocation = MS_MagskullUI_SaveLocation
_G.MS_StamskullUI_SaveLocation = MS_StamskullUI_SaveLocation
_G.MS_CritresiskullUI_SaveLocation = MS_CritresiskullUI_SaveLocation

return UIControls