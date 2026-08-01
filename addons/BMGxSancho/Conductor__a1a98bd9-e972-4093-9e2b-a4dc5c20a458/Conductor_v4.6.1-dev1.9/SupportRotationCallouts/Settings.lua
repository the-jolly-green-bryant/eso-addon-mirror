local SRC = SupportRotationCallouts

SRC.Settings = SRC.Settings or {}
local Settings = SRC.Settings

function Settings:RefreshOpeningDisplay()
    if SRC.ColossusRotation and SRC.ColossusRotation.RefreshOpeningDisplay then
        SRC.ColossusRotation:RefreshOpeningDisplay()
    end
end

function Settings:ApplyDisplaySettings()
    if SRC.Display and SRC.Display.ApplySettings then
        SRC.Display:ApplySettings()
    end
end

function Settings:ApplyDisplayMode()
    if SRC.Display and SRC.Display.ApplyMode then
        SRC.Display:ApplyMode()
    end
end

function Settings:SetRotationAccount(position, value)
    SRC.saved.rotation[position] = SRC:NormalizeAccountName(value or "")
    if SRC.OnAssignmentSettingsChanged then SRC:OnAssignmentSettingsChanged("ColossusRotation") end
    self:RefreshOpeningDisplay()
end

function Settings:AddDiagnostic(message)
    if SRC.Diagnostics and SRC.Diagnostics.Add then
        SRC.Diagnostics:Add("SETTINGS", message)
    end
end


function Settings:SetModuleAccount(rotationKey, position, value)
    SRC.saved[rotationKey][position] = SRC:NormalizeAccountName(value or "")
    local moduleKey = rotationKey == "warhornRotation" and "WarhornRotation" or "BarrierRotation"
    if SRC.OnAssignmentSettingsChanged then SRC:OnAssignmentSettingsChanged(moduleKey) end
end


function Settings:NudgeDashboard(dx, dy)
    SRC.saved.offsetX = zo_clamp((SRC.saved.offsetX or 0) + (dx or 0), -1600, 1600)
    SRC.saved.offsetY = zo_clamp((SRC.saved.offsetY or 0) + (dy or 0), -900, 900)
    self:ApplyDisplaySettings()
end

function Settings:ResetDashboardPosition()
    SRC.saved.offsetX = 0
    SRC.saved.offsetY = -180
    self:ApplyDisplaySettings()
end


function Settings:NudgeBuffsDebuffs(dx, dy)
    SRC.saved.buffsDebuffsOffsetX = zo_clamp((SRC.saved.buffsDebuffsOffsetX or 430) + (dx or 0), -1600, 1600)
    SRC.saved.buffsDebuffsOffsetY = zo_clamp((SRC.saved.buffsDebuffsOffsetY or -120) + (dy or 0), -900, 900)
    self:ApplyDisplaySettings()
end

function Settings:ResetBuffsDebuffsPosition()
    SRC.saved.buffsDebuffsOffsetX = 430
    SRC.saved.buffsDebuffsOffsetY = -120
    self:ApplyDisplaySettings()
end
