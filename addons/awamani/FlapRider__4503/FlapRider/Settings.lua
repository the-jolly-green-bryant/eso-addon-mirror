-- ==================================================================================================
-- Global addon table (shared with FlapRider.lua)
FlapRider = FlapRider or {}

local WING_TYPES = {
    {name = "Butterfly", texture = "FlapRider/wings/ButterflyWing.dds"},
    {name = "Angel", texture = "FlapRider/wings/AngelWing.dds"},
    {name = "Fly", texture = "FlapRider/wings/FlyWing.dds"},
    {name = "Wasp", texture = "FlapRider/wings/WaspWing.dds"}
}

local SAVED_VARS_DEFAULTS = {
    wing = {texture = WING_TYPES[1].texture, tint = {1, 1, 1, 1}},
    showWings = true
}

-- ==================================================================================================
-- Saved Variables init (fired from FlapRider.lua during addon load)
CALLBACK_MANAGER:RegisterCallback(
    "OnFlapRiderInitializing",
    function()
        FlapRider.savedVars = ZO_SavedVars:NewAccountWide("FlapRiderSavedVars", 2, GetWorldName(), SAVED_VARS_DEFAULTS)
    end
)

-- ==================================================================================================
-- Find dropdown index matching saved texture
local function GetWingTypeIndex()
    local saved = FlapRider.savedVars.wing.texture
    for i, wing in ipairs(WING_TYPES) do
        if wing.texture == saved then
            return i
        end
    end
    return 1
end

-- ==================================================================================================
-- Toggle settings panel
function FlapRider.ToggleSettings()
    local isOpen = FlapRider_Settings:IsHidden()
    FlapRider_Settings:SetHidden(not isOpen)
    SetGameCameraUIMode(isOpen)
    if isOpen then
        if FlapRider.wingDropdown then
            FlapRider.wingDropdown:SelectItemByIndex(GetWingTypeIndex())
        end
        if FlapRider.showWingsToggle then
            FlapRider.showWingsToggle:SetChecked(FlapRider.savedVars.showWings)
        end
        if FlapRider.tintPicker then
            FlapRider.tintPicker:UpdateColor()
        end
    end
end

-- ==================================================================================================
-- Hotkey callback: read count to decide action
CALLBACK_MANAGER:RegisterCallback(
    "FlapRider_Hotkey",
    function(count)
        if count == 1 then
            return FlapRider:ToggleWings()
        end

        if count >= 2 then
            return FlapRider.ToggleSettings()
        end
    end
)

-- ==================================================================================================
-- Settings form
local function CreateForm()
    local panel = FlapRider_Settings

    -- Title
    local title = WINDOW_MANAGER:CreateControl("$(parent)_title", panel, CT_LABEL)
    title:SetFont("$(BOLD_FONT)|24|outline")
    title:SetColor(1, 1, 1, 1)
    title:SetText("FlapRider")
    title:SetAnchor(TOPLEFT, panel, TOPLEFT, 20, 15)

    -- Divider
    local divider = CreateControlFromVirtual("$(parent)_divider", panel, "ZO_Options_Divider")
    divider:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 2)
    divider:SetDimensions(300, 4)

    -- Show Wings toggle
    local showToggle =
        FlapRiderCommon.CreateToggle("$(parent)_showWings", panel, FlapRider.savedVars, "showWings", "Show Wings")
    showToggle:SetAnchor(TOPLEFT, divider, BOTTOMLEFT, 0, 12)
    showToggle:SetHandler(
        "OnMouseDown",
        function(self)
            FlapRider:ToggleWings()
            self:SetChecked(FlapRider.savedVars.showWings)
        end
    )
    FlapRider.showWingsToggle = showToggle

    local LABEL_WIDTH = 100

    -- Wing Type label
    local dropdownLabel = WINDOW_MANAGER:CreateControl("$(parent)_dropLabel", panel, CT_LABEL)
    dropdownLabel:SetFont("$(BOLD_FONT)|16|outline")
    dropdownLabel:SetColor(1, 1, 1, 1)
    dropdownLabel:SetText("Wing Type")
    dropdownLabel:SetDimensions(LABEL_WIDTH, 30)
    dropdownLabel:SetAnchor(TOPLEFT, showToggle, BOTTOMLEFT, 0, 12)

    -- Wing Type dropdown
    local comboBoxControl = CreateControlFromVirtual("$(parent)_wingDropdown", panel, "ZO_ComboBox")
    comboBoxControl:SetDimensions(200, 30)
    comboBoxControl:SetAnchor(LEFT, dropdownLabel, RIGHT, 0, 0)

    local combo = ZO_ComboBox_ObjectFromContainer(comboBoxControl)
    combo:SetSortsItems(false)
    combo:SetFont("$(BOLD_FONT)|16|outline")

    for _, wing in ipairs(WING_TYPES) do
        local entry =
            combo:CreateItemEntry(
            wing.name,
            function()
                FlapRider.savedVars.wing.texture = wing.texture
                FlapRider:UpdateWingAppearance()
            end
        )
        combo:AddItem(entry)
    end

    combo:SelectItemByIndex(GetWingTypeIndex())
    FlapRider.wingDropdown = combo

    -- Wing Tint
    local tintPicker =
        FlapRiderCommon.CreateColorPicker("$(parent)_tint", panel, FlapRider.savedVars.wing, "tint", "Wing Tint")
    tintPicker:SetAnchor(TOPLEFT, dropdownLabel, BOTTOMLEFT, 0, 12)
    FlapRider.tintPicker = tintPicker

    -- Close button
    local closeButton = CreateControlFromVirtual("$(parent)_closeBtn", panel, "ZO_DialogButton")
    closeButton:SetAnchor(BOTTOMRIGHT, panel, BOTTOMRIGHT, -15, -12)
    ZO_KeybindButtonTemplate_Setup(
        closeButton,
        "TOGGLE_SYSTEM",
        function()
            FlapRider.ToggleSettings()
        end,
        "Close"
    )

    -- Update wings when settings change
    CALLBACK_MANAGER:RegisterCallback(
        "FlapRider_Reset",
        function()
            FlapRider:UpdateWingAppearance()
        end
    )

    -- Escape key closes settings
    ZO_PreHook(
        "ZO_SceneManager_ToggleGameMenuBinding",
        function()
            if not panel:IsHidden() then
                FlapRider.ToggleSettings()
                return true
            end
            return false
        end
    )
end

EVENT_MANAGER:RegisterForEvent(
    "FlapRider_Settings",
    EVENT_PLAYER_ACTIVATED,
    function()
        CreateForm()
        EVENT_MANAGER:UnregisterForEvent("FlapRider_Settings", EVENT_PLAYER_ACTIVATED)
    end
)
