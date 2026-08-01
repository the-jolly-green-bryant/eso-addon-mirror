local addonId = "LibCopyWindow"
local addon = ZO_Object:Subclass()

function addon:New(...)
    local instance = ZO_Object.New(self)
    instance:initialize(...)
    return instance
end

function addon:initialize(name)
    self.name = name

    self.control = LibCopyWindowContainer
    self.outputBox = self.control:GetNamedChild("OutputBox")
    self.outputBox:SetHandler("OnTextChanged", function(control)
        control:SelectAll()
    end)
    self.outputBox:SetHandler("OnFocusLost", function()
        self.control:SetHidden(true)
        self.outputBox:SetText("")
    end)
end

function addon:Show(text)
    self.outputBox:SetText(text)
    self.control:SetHidden(false)
    self.outputBox:TakeFocus()
end

EVENT_MANAGER:RegisterForEvent(addonId, EVENT_ADD_ON_LOADED, function(event, addonName)
    if addonName ~= addonId then
        return
    end
    assert(not _G[addonId], string.format("'%s' has already been loaded", addonId))
    _G[addonId] = addon:New(addonId)
    EVENT_MANAGER:UnregisterForEvent(addonId, EVENT_ADD_ON_LOADED)
end)
