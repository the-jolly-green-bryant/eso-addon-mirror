local internal = Medic.internal

local BaseModule = ZO_Object:Subclass()
internal.class.BaseModule = BaseModule

function BaseModule:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function BaseModule:Initialize()
    self.id = "invalid"
    self.optionLabel = "Not Set"
    self.optionTooltip = nil
    self.requiresReload = true
    self.minAPIVersion = nil
    self.maxAPIVersion = nil
end

function BaseModule:GetId()
    return self.id
end

function BaseModule:ShouldLoad(currentAPIVersion)
    return not ((self.minAPIVersion and currentAPIVersion < self.minAPIVersion)
        or (self.maxAPIVersion and currentAPIVersion > self.maxAPIVersion))
end

function BaseModule:Load(saveData, newSaveData)
    if saveData[self.id] == nil then
        saveData[self.id] = true
    end
    newSaveData[self.id] = saveData[self.id]
    self.saveData = newSaveData
end

function BaseModule:Unload(saveData)
    saveData[self.id] = nil
end

function BaseModule:CreateSettings(optionsData)
    optionsData[#optionsData + 1] = {
        type = "checkbox",
        name = self.optionLabel,
        tooltip = self.optionTooltip,
        getFunc = function() return self.saveData[self.id] end,
        setFunc = function(value)
            if(not self.requiresReload and self.saveData[self.id] ~= value) then
                if(not value) then
                    internal.TryDisable(self)
                else
                    internal.TryEnable(self)
                end
            end
            self.saveData[self.id] = value
        end,
        requiresReload = self.requiresReload,
        default = true
    }
end

function BaseModule:IsEnabled()
    return self.saveData[self.id] == true
end

function BaseModule:Enable()
-- overwrite if needed
end

function BaseModule:Disable()
-- overwrite if needed
end
