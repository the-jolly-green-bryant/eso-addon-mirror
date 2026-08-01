--[[reminderData = {
    type = "reminder",
    name = "My Reminder", -- or string id or function returning a string
    getFunc = function() return db.text end,
    setFunc = function(text) db.text = text doStuff() end,
    func = function() end,
    isMultiline = true, -- boolean (optional)
    default = defaults.text, -- default value or function that returns the default value (optional)
    helpUrl = "https://www.esoui.com/portal.php?id=218&a=faq", -- a string URL or a function that returns the string URL (optional)
    reference = "MyAddonReminder" -- unique global reference to control (optional)
} ]]


local widgetVersion = 1
local LAM = LibAddonMenu2
if not LAM:RegisterWidget("reminder", widgetVersion) then return end

local wm = WINDOW_MANAGER


local function UpdateDisabled(control)
    local disable
    disable = control.data.getFunc() == nil
    if disable then
        control:SetHeight(0)
        control:SetAlpha(0)
        control:SetHidden(true)
    else
        control:SetHeight(control.divider:GetHeight() + control.reminder:GetHeight() + 16)
        control:SetAlpha(1)
        control:SetHidden(false)
    end
    -- control.data.disabled = disable
    -- control.reminder:SetEditEnabled(not disable)
    -- control.reminder:UpdateDisabled()
end

local function UpdateValue(control, forceDefault, value)
    if not value then
        value = control.data.getFunc()
        control.reminder.label:SetText(BreakReminder.GetLabel(value))
    end
    control:UpdateDisabled()
end


function LAMCreateControl.reminder(parent, reminderData, controlName)
    local control = LAM.util.CreateBaseControl(parent, reminderData, controlName)

    control.divider = wm:CreateControlFromVirtual(nil, control, "ZO_Options_Divider")
    local divider = control.divider
    divider:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)

    control.reminder = LAMCreateControl.editbox(control, {
        type = "editbox",
        name = reminderData.name,
        isMultiline = reminderData.isMultiline,
        default = reminderData.default,
        getFunc = function()
            local i = reminderData.getFunc()
            return i and i.note or ""
         end,
        setFunc = function(note)
            local i = reminderData.getFunc()
            i.note = note
         end,
    }, controlName)
    local reminder = control.reminder
    reminder:SetAnchor(TOPLEFT, divider, BOTTOMLEFT, 0, 10)

    control.button = wm:CreateControlFromVirtual(nil, control, "ZO_DefaultButton")
    local button = control.button
    button:SetWidth(control:GetWidth() / 3)
    button:SetText(LAM.util.GetStringFromValue(SI_NOTIFICATIONS_DELETE))
    button:SetAnchor(BOTTOMLEFT, control, BOTTOMLEFT, 0, 0)
    button:SetClickSound("Click")
    button.data = {}
    button:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
    button:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
    button:SetHandler("OnClicked", function(...)
        local args = {...}
        local function callback()
            reminderData.func(unpack(args))
            LAM.util.RequestRefreshIfNeeded(control)
        end
        callback()
    end)

    control:SetDimensionConstraints(control:GetWidth(), 0, control:GetWidth(), divider:GetHeight() + reminder:GetHeight() + 16)

    control.UpdateDisabled = UpdateDisabled
    control.UpdateValue = UpdateValue
    control:UpdateValue()
    control:UpdateDisabled()

    LAM.util.RegisterForRefreshIfNeeded(control)
    return control
end
