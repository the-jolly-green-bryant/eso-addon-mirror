local tbug = TBUG or SYSTEMS:GetSystem("merTorchbug")


--Color picker
local function colorPickerCallback(r, g, b, a, inspectorObject, rowControl, rowData)
    local oldValue = rowData.value
    rowData.value = string.format("\"%s\"", tostring(rowData.prop.getFormatedRGBA(rowData, r, g, b, a)))
    tbug.setEditValueFromContextMenu(inspectorObject, rowControl, rowData, oldValue)

    --Enable the mouse again. The dialog closing changed to "movemenet" mode
    zo_callLater(function() tbug.env.sm:OnToggleHUDUIBinding() end, 50)
end

function tbug.showColorPickerAtRow(inspectorObject, rowControl, rowData)
    local currentColor = tbug.parseColorDef(rowData.value)
    local r, g, b, a = currentColor:UnpackRGBA()
    if IsInGamepadPreferredMode() then
        COLOR_PICKER_GAMEPAD:Show(function(p_r, p_g, p_b, p_a) colorPickerCallback(p_r, p_g, p_b, p_a, inspectorObject, rowControl, rowData) end, r, g, b, a)
    else
        COLOR_PICKER:Show(function(p_r, p_g, p_b, p_a) colorPickerCallback(p_r, p_g, p_b, p_a, inspectorObject, rowControl, rowData) end, r, g, b, a)
    end
end
