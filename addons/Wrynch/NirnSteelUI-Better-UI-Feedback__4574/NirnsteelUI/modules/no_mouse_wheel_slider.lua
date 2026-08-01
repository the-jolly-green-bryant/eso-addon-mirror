Nirnsteel_UI = Nirnsteel_UI or {}
local Nirnsteel_UI = Nirnsteel_UI

local NoMouseWheelSlider = {}
Nirnsteel_UI.NoMouseWheelSlider = NoMouseWheelSlider

local WIDGET_TYPE = "nirnsteelNoMouseWheelSlider"
local LAM_SLIDER_HANDLER_NAMESPACE = "LAM2_Slider"

local function DisableMouseWheel(control)
    if control and control.slider then
        control.slider:SetHandler("OnMouseWheel", nil, LAM_SLIDER_HANDLER_NAMESPACE)
        control.slider:SetHandler("OnMouseWheel", nil)
    end
end

function NoMouseWheelSlider:Register(LAM)
    if not LAM or not LAM.RegisterWidget or not LAMCreateControl or not LAMCreateControl.slider then
        return false
    end

    if LAMCreateControl[WIDGET_TYPE] then
        return true
    end

    if not LAM:RegisterWidget(WIDGET_TYPE, 1) then
        return LAMCreateControl[WIDGET_TYPE] ~= nil
    end

    LAMCreateControl[WIDGET_TYPE] = function(parent, sliderData, controlName)
        local control = LAMCreateControl.slider(parent, sliderData, controlName)
        DisableMouseWheel(control)

        if control and control.slider and ZO_PostHookHandler then
            ZO_PostHookHandler(control.slider, "OnMouseEnter", function() DisableMouseWheel(control) end)
            ZO_PostHookHandler(control.slider, "OnMouseUp", function()
                zo_callLater(function() DisableMouseWheel(control) end, 0)
            end)
        end

        if control and control.slidervalue and ZO_PostHookHandler then
            ZO_PostHookHandler(control.slidervalue, "OnFocusGained", function() DisableMouseWheel(control) end)
            ZO_PostHookHandler(control.slidervalue, "OnFocusLost", function() DisableMouseWheel(control) end)
        end

        return control
    end

    return true
end

function NoMouseWheelSlider:UseForSliderOptions(options)
    if not options then
        return
    end

    for _, option in ipairs(options) do
        if option.type == "slider" then
            option.type = WIDGET_TYPE
        end

        if option.controls then
            self:UseForSliderOptions(option.controls)
        end
    end
end
