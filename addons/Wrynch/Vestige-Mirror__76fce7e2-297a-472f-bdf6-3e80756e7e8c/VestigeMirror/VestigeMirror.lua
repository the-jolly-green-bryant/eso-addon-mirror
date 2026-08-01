VestigeMirror = VestigeMirror or {}

local ADDON_NAME = "VestigeMirror"

ZO_CreateStringId("SI_BINDING_NAME_VESTIGE_MIRROR_TOGGLE", "Open Vestige Mirror")

function VestigeMirror:Initialize()
    if self.initialized then
        return
    end

    self.Data:Initialize()
    self.Preview:Initialize()
    self.UI:Initialize(VestigeMirrorWindow)
    self.Scene:Initialize()

    SLASH_COMMANDS["/vestigemirror"] = function(arguments) self:HandleCommand(arguments) end
    SLASH_COMMANDS["/vm"] = function(arguments) self:HandleCommand(arguments) end

    self.initialized = true
end

function VestigeMirror:HandleCommand(arguments)
    if arguments and arguments ~= "" then
        return
    end

    self:Toggle()
end

function VestigeMirror:Toggle()
    if not self.initialized then
        return
    end

    if self.Scene:IsShowing() then
        self:Hide()
    else
        self:Show()
    end
end

function VestigeMirror:Show()
    if not self.initialized then
        return
    end

    self.Scene:Show()
end

function VestigeMirror:Hide()
    if not self.initialized then
        return
    end

    self.Scene:Hide()
end

function VestigeMirror_OnInitialized(control)
    VestigeMirror.window = control
end

function VestigeMirror_Toggle()
    VestigeMirror:Toggle()
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= ADDON_NAME then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
    VestigeMirror:Initialize()
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
