--[[customData = {
    type = "custom",
    reference = "MyAddonCustomControl", --(optional) unique name for your control to use as reference
    refreshFunc = function(customControl) end, --(optional) function to call when panel/controls refresh
    width = "full", --or "half" (optional)
} ]]

local widgetVersion = 1
local LAM = LibStub("LibAddonMenu-2.0")
if not LAM:RegisterWidget("LZTab", widgetVersion) then return end

local wm = WINDOW_MANAGER

local function UpdateDisabled(control)
    local disable = control.data.disabled
    if type(disable) == "function" then
        disable = disable()
    end
    control.LZTab:SetEnabled(not disable)
end

local function UpdateValue(control)    
    if control.data.isSelected then 
        control.LZTab:SetNormalFontColor(255,255,255, 1) 
    else
        control.LZTab:SetNormalFontColor(ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGBA()) 
    end
end

--controlName is optional
local MIN_HEIGHT = 28 -- default_button height
local HALF_WIDTH_LINE_SPACING = -50
function LAMCreateControl.LZTab(parent, buttonData, controlName)
    local control = LAM.util.CreateBaseControl(parent, buttonData, controlName)
    control:SetMouseEnabled(true)

    local width = control:GetWidth()
    if control.isHalfWidth then
        control:SetDimensions(width / 2, MIN_HEIGHT * 2 + HALF_WIDTH_LINE_SPACING)
    else
        control:SetDimensions(width, MIN_HEIGHT)
    end

    if buttonData.icon then
        control.LZTab = wm:CreateControl(nil, control, CT_BUTTON)
        control.LZTab:SetDimensions(26, 26)
        control.LZTab:SetNormalTexture(buttonData.icon)
        control.LZTab:SetPressedOffset(2, 2)
    else
        --control.button = wm:CreateControlFromVirtual(controlName.."Button", control, "ZO_DefaultButton")
        control.LZTab = wm:CreateControlFromVirtual(nil, control, "ZO_DefaultButton")
        control.LZTab:SetWidth(width / 2)
        control.LZTab:SetHeight(25)
        control.LZTab:SetText(LAM.util.GetStringFromValue(buttonData.name))
        if buttonData.isSelected then control.LZTab:SetNormalFontColor(255,255,255, 1) end
        if buttonData.isDangerous then control.LZTab:SetNormalFontColor(ZO_ERROR_COLOR:UnpackRGBA()) end
    end
    local button = control.LZTab
    button:SetAnchor(control.isHalfWidth and CENTER or RIGHT)
    button:SetClickSound("Click")
    button.data = {tooltipText = LAM.util.GetStringFromValue(buttonData.tooltip)}
    button:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
    button:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
    button:SetHandler("OnClicked", function(...)
        local args = {...}
        local function callback()
            buttonData.func(unpack(args))
            if buttonData.isSelected then control.LZTab:SetNormalFontColor(255,255,255, 1) end
            LAM.util.RequestRefreshIfNeeded(control)
        end
        if(buttonData.isDangerous) then
            local title = LAM.util.GetStringFromValue(buttonData.name)
            local body = LAM.util.GetStringFromValue(buttonData.warning)
            LAM.util.ShowConfirmationDialog(title, body, callback)
        else
            callback()
        end
    end)
    control.UpdateValue = UpdateValue

    if buttonData.warning ~= nil then
        control.warning = wm:CreateControlFromVirtual(nil, control, "ZO_Options_WarningIcon")
        control.warning:SetAnchor(RIGHT, button, LEFT, -5, 0)
        control.UpdateWarning = LAM.util.UpdateWarning
        control:UpdateWarning()
    end

    if buttonData.disabled ~= nil then
        control.UpdateDisabled = UpdateDisabled
        control:UpdateDisabled()
    end

    LAM.util.RegisterForRefreshIfNeeded(control)
    LAM.util.RegisterForReloadIfNeeded(control)

    return control
end
