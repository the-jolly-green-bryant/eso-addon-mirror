
function QDRH_InitSettings(self)
    local settings = LibHarvensAddonSettings:AddAddon("Dreadsail Helper")

    settings:AddSetting{
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Enable Addon",
        default = true,
        getFunction = function() return self.savedVars.enabled end,
        setFunction = function(v) self.savedVars.enabled=v end
    }
end
