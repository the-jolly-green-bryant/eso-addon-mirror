
function LeoTrainer_Launcher_OnMouseEnter(control)
    InitializeTooltip(InformationTooltip, control, RIGHT, 0, 0)
    SetTooltipText(InformationTooltip, LeoTrainer.displayName)
end

function LeoTrainer_Launcher_OnMouseClicked(control)
    LeoTrainer.ui.ToggleUI()
end

LeoTrainer_Launcher = ZO_Object:Subclass()

function LeoTrainer_Launcher:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function LeoTrainer_Launcher:Initialize()
    self.launcher = {}
    self.launcher = CreateControlFromVirtual("$(parent)LeoTrainerLauncher", ZO_SmithingTopLevel, "LeoTrainer_Launcher")
    self.launcher:SetAnchor(BOTTOMRIGHT, ZO_SmithingTopLevelCreationPanel, TOPLEFT, 20, -50)
end

function LeoTrainer_Launcher:SetState(state)
    self.launcher:SetState(state)
end

function LeoTrainer_Launcher:GetControl()
    return self.launcher
end

function LeoTrainer_Launcher:SetHidden(bHidden)
    return self.launcher:SetHidden(bHidden)
end
