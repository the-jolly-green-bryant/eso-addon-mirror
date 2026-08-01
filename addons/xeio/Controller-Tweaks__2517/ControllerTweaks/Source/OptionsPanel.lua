local CT = ControllerTweaks

local OptionsPanel = {
    options = {}
}

local panelData = {
    type = "panel",
    name = "Controller Tweaks",
    displayName = "Controller Tweaks Options",
    author = "Xeio",
    version = "1.0",
    slashCommand = "/controllertweaks",
    registerForRefresh = true,
    registerForDefaults = true,
}

function OptionsPanel:AddOption(option)
    table.insert(self.options, option)
end

function OptionsPanel:RegisterOptions()
    LibAddonMenu2:RegisterAddonPanel("ControllerTweaks", panelData)
    LibAddonMenu2:RegisterOptionControls("ControllerTweaks", self.options)
end

CT.OptionsPanel = OptionsPanel