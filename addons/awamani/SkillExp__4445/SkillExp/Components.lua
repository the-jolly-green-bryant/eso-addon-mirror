local components = {}

-- ───────────────────────────────────────────────────────────────────────────────
-- Label
-- ───────────────────────────────────────────────────────────────────────────────
local function CreateLabel(id, parent, text, font, color, w, h)
    local label = WINDOW_MANAGER:CreateControl(id, parent, CT_LABEL)
    label:SetFont(font or "ZoFontGame")
    label:SetText(text or "")
    if color then
        label:SetColor(unpack(color))
    end
    if w and h then
        label:SetDimensions(w, h)
    end
    return label
end

-- ───────────────────────────────────────────────────────────────────────────────
-- Form
-- ───────────────────────────────────────────────────────────────────────────────
local function CreateForm(id, parent, title, w, h)
    local form = WINDOW_MANAGER:CreateControl(id, parent, CT_CONTROL)
    form:SetDimensions(w, h)
    form:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    form:SetMouseEnabled(true)
    form:SetMovable(true)
    form:SetClampedToScreen(true)
    form:SetHidden(true)

    local bg = WINDOW_MANAGER:CreateControl(id .. "BG", form, CT_BACKDROP)
    bg:SetAnchorFill()
    ApplyTemplateToControl(bg, "ZO_DefaultBackdrop")

    if title then
        local titleLabel = CreateLabel(id .. "Title", form, title, "ZoFontWinH2", { 1, 1, 1, 1 })
        titleLabel:SetAnchor(TOP, form, TOP, 0, 10)
        titleLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    end

    return form
end

-- ───────────────────────────────────────────────────────────────────────────────
-- CheckBox
-- ───────────────────────────────────────────────────────────────────────────────
local function CreateCheckBox(id, parent, data, key, text, tooltip, w, h)
    local container = WINDOW_MANAGER:CreateControl(id, parent, CT_CONTROL)
    container:SetDimensions(w or 250, h or 28)
    container:SetMouseEnabled(true)

    local cb = WINDOW_MANAGER:CreateControl(id .. "Box", container, CT_TEXTURE)
    cb:SetDimensions(24, 24)
    cb:SetAnchor(LEFT, container, LEFT, 0, 0)

    local label = CreateLabel(id .. "Label", container, text, "ZoFontGame", { 1, 1, 1, 1 })
    label:SetAnchor(LEFT, cb, RIGHT, 8, 0)

    local function refresh()
        if data[key] then
            cb:SetTexture("EsoUI/Art/Inventory/Gamepad/gp_inventory_icon_equipped.dds")
        else
            cb:SetTexture("EsoUI/Art/Miscellaneous/Gamepad/gp_bullet.dds")
        end
    end

    container:SetHandler("OnMouseUp", function()
        data[key] = not data[key]
        refresh()
    end)

    if tooltip then
        container:SetHandler("OnMouseEnter", function()
            ZO_Tooltips_ShowTextTooltip(container, RIGHT, tooltip)
        end)
        container:SetHandler("OnMouseExit", function()
            ZO_Tooltips_HideTextTooltip()
        end)
    end

    refresh()
    container.Refresh = refresh
    return container
end

-- ───────────────────────────────────────────────────────────────────────────────
-- Toggle (MapRadar-style)
-- ───────────────────────────────────────────────────────────────────────────────
local function CreateToggle(id, parent, data, key, text, tooltip, w, h)
    local control = WINDOW_MANAGER:CreateControl(id, parent, CT_CONTROL)
    control:SetMouseEnabled(true)
    control:SetDimensions(w or 150, h or 35)

    control.checkbox = WINDOW_MANAGER:CreateControl(id .. "_tgl", control, CT_TEXTURE)
    control.checkbox:SetDimensions(35, 35)
    control.checkbox:SetAnchor(TOPLEFT, control, TOPLEFT)

    control.label = CreateLabel(id .. "_label", control, text, "$(BOLD_FONT)|16|outline", { 1, 1, 1, 1 })
    control.label:SetAnchor(LEFT, control.checkbox, RIGHT, 5, 1)

    control.SetChecked = function(self, value)
        data[key] = value
        self.checkbox:SetTexture(value and "SkillExp/textures/toggle-on.dds" or "SkillExp/textures/toggle-off.dds")
        self.checkbox:SetColor(.5, value and .9 or .5, .5, value and .8 or .8)
    end

    control:SetHandler("OnMouseDown", function(self)
        self:SetChecked(not data[key])
    end)

    if tooltip then
        control:SetHandler("OnMouseEnter", function()
            ZO_Tooltips_ShowTextTooltip(control, RIGHT, tooltip)
        end)
        control:SetHandler("OnMouseExit", function()
            ZO_Tooltips_HideTextTooltip()
        end)
    end

    control:SetChecked(data[key])
    return control
end

-- ───────────────────────────────────────────────────────────────────────────────
-- Debouncer
-- ───────────────────────────────────────────────────────────────────────────────
local Debouncer = {}
Debouncer.__index = Debouncer

function Debouncer:New(callback, waitTime)
    local obj = setmetatable({}, self)
    obj.callback = callback
    obj.waitTime = waitTime or 300
    obj.count = 0
    obj.callId = 0
    return obj
end

function Debouncer:Invoke()
    self.count = self.count + 1
    self.callId = self.callId + 1
    local myCallId = self.callId

    zo_callLater(function()
        if myCallId == self.callId then
            local count = self.count
            self.count = 0
            self.callback(count)
        end
    end, self.waitTime)
end

-- ───────────────────────────────────────────────────────────────────────────────
-- Exports
-- ───────────────────────────────────────────────────────────────────────────────
components.CreateLabel = CreateLabel
components.CreateCheckBox = CreateCheckBox
components.CreateToggle = CreateToggle
components.CreateForm = CreateForm
components.Debouncer = Debouncer

SkillExpComponents = components
