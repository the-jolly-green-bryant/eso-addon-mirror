-- ==================================================================================================
-- Keybind string IDs (must exist before Bindings.xml is parsed)
ZO_CreateStringId("SI_BINDING_NAME_FLAPRIDER", "FlapRider")
ZO_CreateStringId("SI_BINDING_NAME_FLAPRIDER_TOGGLE", "Toggle Wings / Settings")

-- ==================================================================================================
-- Local generation methods
local function CreateLabel(name, parent, text)
    local label = CreateControl(name, parent, CT_LABEL)
    label:SetFont("$(BOLD_FONT)|16|outline")
    label:SetColor(1, 1, 1, 1)

    if text ~= nil then
        label:SetText(text)
    end

    return label;
end

-- ==================================================================================================
-- Label stack
local LabelStack = {}
function LabelStack:New(name, parent, count)
    local control = CreateLabel(name, parent, " ") -- Empty space forces to render table text and calc its bottom position for anchors

    control.SetFontBase = control.SetFont
    control.SetColorBase = control.SetColor
    control.name = name
    control.count = count
    control.labels = {}

    local label = CreateLabel("$(parent)placeholder", control)
    label:SetAnchor(TOPLEFT, control, TOPRIGHT)

    -- Create list of label controls here and anchor them together
    for i = 1, count do
        local nextLabel = CreateLabel("$(parent)Label" .. i, control)
        nextLabel:SetAnchor(TOPLEFT, label, TOPRIGHT, 10)
        nextLabel:SetAnchor(BOTTOMLEFT, label, BOTTOMRIGHT, 10)
        control.labels[i] = nextLabel
        label = nextLabel
    end

    control.SetText = function(self, text)
        -- puch all label texts further 
        for i = self.count, 2, -1 do
            self.labels[i]:SetText(self.labels[i - 1]:GetText())
        end
        self.labels[1]:SetText(text)
    end

    control.SetFont = function(self, ...)
        self:SetFontBase(...)
        for i = 1, count do
            control.labels[i]:SetFont(...)
        end
    end

    control.SetColor = function(self, ...)
        self:SetColorBase(...)
        for i = 1, count do
            control.labels[i]:SetColor(...)
        end
    end

    return control
end

-- ==================================================================================================
-- Data form
local DataForm = {}
function DataForm:New(id, parent)
    local control = CreateControl("$(parent)DataAnchor" .. id, parent, CT_CONTROL)
    local lastTextLabel = {}

    control.labels = {}

    control.AddLabel = function(self, text, dataFunc)
        local index = table.maxn(self.labels) + 1

        local textLabel = CreateLabel("$(parent)TextLabel" .. index, self, text)
        local dataLabel = CreateLabel("$(parent)DataLabel" .. index, self)

        if (index == 1) then
            textLabel:SetAnchor(TOPRIGHT, self, TOPLEFT, -10)
            dataLabel:SetAnchor(TOPLEFT, self, TOPRIGHT, 10)
        else
            textLabel:SetAnchor(TOPRIGHT, lastTextLabel, BOTTOMRIGHT)
            dataLabel:SetAnchor(TOPLEFT, control.labels[index - 1].control, BOTTOMLEFT)
        end

        self.labels[index] = {
            control = dataLabel,
            fetch = dataFunc
         }

        local baseWidth, baseHeight = self:GetDimensions()
        local labelWidth, labelHeight = textLabel:GetDimensions()

        self:SetDimensions(baseWidth, baseHeight + labelHeight)

        lastTextLabel = textLabel
    end

    control.AddStack = function(self, text, dataFunc)
        -- TODO: Unify two methods

        local index = table.maxn(self.labels) + 1

        local textLabel = CreateLabel("$(parent)TextLabel" .. index, self, text)
        local dataLabel = FlapRiderCommon.LabelStack:New("$(parent)DataLabel" .. index, self, 5)
        dataLabel:SetFont("$(BOLD_FONT)|16|outline")
        dataLabel:SetColor(1, 1, 1, 1)

        if (index == 1) then
            textLabel:SetAnchor(TOPRIGHT, self, TOPLEFT, -10)
            dataLabel:SetAnchor(TOPLEFT, self, TOPRIGHT, 10)
        else
            textLabel:SetAnchor(TOPRIGHT, lastTextLabel, BOTTOMRIGHT)
            dataLabel:SetAnchor(TOPLEFT, control.labels[index - 1].control, BOTTOMLEFT)
        end

        self.labels[index] = {
            control = dataLabel,
            fetch = dataFunc
         }

        local baseWidth, baseHeight = self:GetDimensions()
        local labelWidth, labelHeight = textLabel:GetDimensions()

        self:SetDimensions(baseWidth, baseHeight + labelHeight)

        lastTextLabel = textLabel
    end

    control.SetColor = function(self, ...)
        for key, label in pairs(self.labels) do
            label.control:SetColor(...)
        end
    end

    control.Update = function(self)
        for k, dataLabel in pairs(self.labels) do
            dataLabel.control:SetText(dataLabel.fetch() or " ")
        end
    end

    return control
end

-- ==================================================================================================
-- Debouncer
local Debouncer = {}
function Debouncer:New(callback, waitTimeMs)
    local instance = {
        callback = callback,
        debounce = false,
        timeout = 0,
        count = 0,
        waitTimeMs = waitTimeMs or 300
     }

    local function waitForTimeout(self)
        self.timeout = self.timeout - 100

        if self.timeout > 0 then
            zo_callLater(
                function()
                    waitForTimeout(self)
                end, 100)
        else
            self.callback(self.count)
            self.debounce = false
            self.count = 0
        end
    end

    instance.Invoke = function(self)
        self.timeout = self.waitTimeMs
        self.count = self.count + 1
        if self.debounce then
            return
        end
        self.debounce = true

        waitForTimeout(self)
    end

    return instance
end

-- ==================================================================================================
-- CheckBox
local function CreateCheckBox(id, parent, data, key, text, tooltip, w, h)
    local control = WINDOW_MANAGER:CreateControl(id, parent, CT_CONTROL)
    control:SetMouseEnabled(true)
    control:SetDimensions(w or 150, h or 35)

    control.checkbox = WINDOW_MANAGER:CreateControl("$(parent)_cbx", control, CT_TEXTURE)
    control.checkbox:SetDimensions(35, 35)
    control.checkbox:SetAnchor(TOPLEFT, control, TOPLEFT)

    control.label = FlapRiderCommon.CreateLabel("$(parent)_label", control, text)
    control.label:SetAnchor(LEFT, control.checkbox, RIGHT, 0, 1)

    control.SetChecked = function(self, value)
        data[key] = value
        self.checkbox:SetTexture(value and "esoui/art/cadwell/checkboxicon_checked.dds" or "esoui/art/cadwell/checkboxicon_unchecked.dds")
    end

    control:SetHandler(
        "OnMouseEnter", function(self)
            if tooltip then
                ZO_Tooltips_ShowTextTooltip(self, BOTTOM, tooltip)
            end
        end)
    control:SetHandler(
        "OnMouseExit", function(self)
            if tooltip then
                ZO_Tooltips_HideTextTooltip()
            end
        end)
    control:SetHandler(
        "OnMouseDown", function(self, button, ctrl, alt, shift)
            self:SetChecked(not data[key])
            CALLBACK_MANAGER:FireCallbacks("FlapRider_Reset")
        end)

    -- Init state
    control:SetChecked(data[key])
    return control
end

-- ==================================================================================================
-- Toggle
local function CreateToggle(id, parent, data, key, text, tooltip, w, h)
    local control = WINDOW_MANAGER:CreateControl(id, parent, CT_CONTROL)
    control:SetMouseEnabled(true)
    control:SetDimensions(w or 150, h or 35)

    control.checkbox = WINDOW_MANAGER:CreateControl("$(parent)_tgl", control, CT_TEXTURE)
    control.checkbox:SetDimensions(35, 35)
    control.checkbox:SetAnchor(TOPLEFT, control, TOPLEFT)

    control.label = FlapRiderCommon.CreateLabel("$(parent)_label", control, text)
    control.label:SetAnchor(LEFT, control.checkbox, RIGHT, 5, 1)

    control.SetChecked = function(self, value)
        data[key] = value
        self.checkbox:SetTexture(value and "FlapRider/textures/toggle-on.dds" or "FlapRider/textures/toggle-off.dds")
        self.checkbox:SetColor(.5, value and .9 or .5, .5, value and .8 or .8)
    end

    control:SetHandler(
        "OnMouseEnter", function(self)
            if tooltip then
                ZO_Tooltips_ShowTextTooltip(self, BOTTOM, tooltip)
            end
        end)
    control:SetHandler(
        "OnMouseExit", function(self)
            if tooltip then
                ZO_Tooltips_HideTextTooltip()
            end
        end)
    control:SetHandler(
        "OnMouseDown", function(self, button, ctrl, alt, shift)
            self:SetChecked(not data[key])
            CALLBACK_MANAGER:FireCallbacks("FlapRider_Reset")
        end)

    -- Init state
    control:SetChecked(data[key])
    return control
end

-- ==================================================================================================
-- Slider
local function CreateSlider(id, parent, data, key, text, tooltip, w, h)
    local control = WINDOW_MANAGER:CreateControl(id, parent, CT_CONTROL)
    control:SetMouseEnabled(true)
    control:SetDimensions(w or 500, h or 35)

    control.label = FlapRiderCommon.CreateLabel("$(parent)_label", control, text)
    control.label:SetAnchor(TOPLEFT, control, TOPLEFT)
    control.label:SetDimensions(100, 30)

    control.slider = WINDOW_MANAGER:CreateControlFromVirtual("$(parent)_slider", control, "ZO_Slider")
    control.slider:SetAnchor(TOPLEFT, control.label, TOPRIGHT, 5, 0)

    control.slider:SetBackgroundBottomTexture("FlapRider/textures/slider-bg-bottom.dds")
    control.slider:SetBackgroundTopTexture("FlapRider/textures/slider-bg-top.dds")
    control.slider:SetBackgroundMiddleTexture("FlapRider/textures/slider-bg-mid.dds")
    control.slider:SetThumbTexture(
        "FlapRider/textures/slider-thumb.dds", "FlapRider/textures/slider-thumb.dds", "FlapRider/textures/slider-thumb.dds", 20, 20)

    control.SetMinMaxStep = function(self, min, max, step)
        self.slider:SetValueStep(step)
        self.slider:SetMinMax(min, max)

        self.slider:SetValue(data[key])
        self.value:SetText(data[key])
    end

    control.SetLabelDimensions = function(self, w, h)
        self.label:SetDimensions(w, h)
    end

    -- Value label
    control.value = CreateLabel("$(parent)_valueLabel", control, text)
    control.value:SetAnchor(LEFT, control.slider, RIGHT, 10)

    control.slider:SetHandler(
        "OnValueChanged", function(self, value, eventReason)
            -- This gets fired on some internal creation or something else and provides minimum value. Need to ignore it then
            if eventReason == EVENT_REASON_SOFTWARE then
                return
            end
            control.value:SetText(value)
            data[key] = value
            CALLBACK_MANAGER:FireCallbacks("FlapRider_Reset")
        end)

    control.slider:SetHandler(
        "OnSliderReleased", function(self, value)

        end)

    -- Tooltip
    control:SetHandler(
        "OnMouseEnter", function(self)
            if tooltip then
                ZO_Tooltips_ShowTextTooltip(self, BOTTOM, tooltip)
            end
        end)
    control:SetHandler(
        "OnMouseExit", function(self)
            if tooltip then
                ZO_Tooltips_HideTextTooltip()
            end
        end)

    -- Init values
    control:SetMinMaxStep(0, 100, 1)

    return control
end

-- ==================================================================================================
-- Counter List
local CounterList = {}
function CounterList:New(id, parent)
    local control = CreateControl("$(parent)CounterList" .. id, parent, CT_CONTROL)

    control.lastTextLabel = {}
    control.lastCountLabel = {}
    control.records = {}
    control.labelPool = ZO_ControlPool:New("LabelTemplate", control, "ZoneName")
    control.labelCountPool = ZO_ControlPool:New("LabelTemplate", control, "Count")

    control.AddOrUpdateCounter = function(self, key, text, count)

        if (self.records[key] == nil) then
            local label, labelKey = self.labelPool:AcquireObject()
            label.objkey = labelKey

            local countLabel, countLabelKey = self.labelCountPool:AcquireObject()
            label.objkey = countLabelKey

            -- TODO: add option to expand upwards!

            if (table.maxn(self.records) == 0) then
                label:SetAnchor(TOPRIGHT, self, TOPLEFT, -10)
                countLabel:SetAnchor(TOPLEFT, self, TOPRIGHT, 10)
            else
                label:SetAnchor(TOPRIGHT, self.lastTextLabel, BOTTOMRIGHT)
                countLabel:SetAnchor(TOPLEFT, self.lastCountLabel, BOTTOMLEFT)
            end

            self.records[key] = {
                label = label,
                count = countLabel
             }

            self.lastTextLabel = label
            self.lastCountLabel = countLabel
        end

        self.records[key].label:SetText(text)
        self.records[key].count:SetText(count)
    end

    control.Clear = function(self)
        self.labelPool:ReleaseAllObjects()
        self.labelCountPool:ReleaseAllObjects()

        for i, v in pairs(self.records) do
            self.records[i] = nil
        end

        self.lastTextLabel = {}
        self.lastCountLabel = {}
    end

    return control
end

-- ==================================================================================================
-- Color Picker
local function CreateColorPicker(id, parent, data, key, text, tooltip, w, h)
    local control = WINDOW_MANAGER:CreateControl(id, parent, CT_CONTROL)
    control:SetMouseEnabled(false)
    control:SetDimensions(w or 250, h or 35)

    control.label = CreateLabel("$(parent)_label", control, text)
    control.label:SetAnchor(LEFT, control, LEFT)
    control.label:SetDimensions(100, 30)

    -- Border frame
    local border = WINDOW_MANAGER:CreateControl("$(parent)_border", control, CT_BACKDROP)
    border:SetDimensions(38, 38)
    border:SetAnchor(LEFT, control.label, RIGHT, 0, 0)
    border:SetCenterColor(0, 0, 0, 1)
    border:SetEdgeColor(0.6, 0.6, 0.6, 1)
    border:SetEdgeTexture("", 1, 1, 1)
    border:SetMouseEnabled(false)

    -- Color swatch
    control.swatch = WINDOW_MANAGER:CreateControl("$(parent)_swatch", control, CT_TEXTURE)
    control.swatch:SetDimensions(32, 32)
    control.swatch:SetAnchor(CENTER, border, CENTER)
    control.swatch:SetMouseEnabled(true)

    control.UpdateColor = function(self)
        local c = data[key]
        self.swatch:SetColor(c[1], c[2], c[3], c[4])
    end

    local function OpenPicker()
        local c = data[key]
        COLOR_PICKER:Show(function(r, g, b)
            data[key] = { r, g, b, c[4] or 1 }
            control:UpdateColor()
            CALLBACK_MANAGER:FireCallbacks("FlapRider_Reset")
        end, c[1], c[2], c[3])
    end

    control.swatch:SetHandler("OnMouseDown", OpenPicker)

    control:UpdateColor()
    return control
end

-- ==================================================================================================
-- namespace to export class to public
FlapRiderCommon = {
    -- simple constructor methods
    CreateLabel = CreateLabel,
    CreateCheckBox = CreateCheckBox,
    CreateToggle = CreateToggle,
    CreateSlider = CreateSlider,
    CreateColorPicker = CreateColorPicker,

    -- components
    LabelStack = LabelStack,
    DataForm = DataForm,
    Debouncer = Debouncer,
    CounterList = CounterList
 }
