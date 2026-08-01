local CT = ControllerTweaks

CT_Plugin = ZO_Object:Subclass()

function CT_Plugin:Init()
    --Override for any necessary initialization
end

function CT_Plugin:AddSettingsAndOptions(optionsPanel)
    if self.options then
        for i, option in ipairs(self.options) do
            if not option.getFunc then
                option.getFunc = function()
                    return CT.Settings[option.settingKey] 
                end
            end
            if not option.setFunc then
                option.setFunc = function(var) 
                    CT.Settings[option.settingKey] = var
                end
            end
            CT.Settings[option.settingKey] = option.default
    
            optionsPanel:AddOption(option)
        end
    end
end