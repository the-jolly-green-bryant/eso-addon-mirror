local CC = CombatCoordination

-- THIS IS WORK IN PROGRESS

----------------------------------------------------------------------------------------------------
-- MODULE VARS AND SVARS
----------------------------------------------------------------------------------------------------
local Module = {
    name = "DisplayBorder",
    Parent = nil,

    Default = {},
    ---@type table|any
    SV = {},
}

----------------------------------------------------------------------------------------------------
-- PARENT AND RAYCAM
----------------------------------------------------------------------------------------------------
function Module:Create()
    if self.Parent then return end

    -- THX ExoY FOR TEACHING ME THIS
    local Fragment = ZO_HUDFadeSceneFragment:New(self.Parent)
    HUD_SCENE:AddFragment(Fragment)
    HUD_UI_SCENE:AddFragment(Fragment)
end

----------------------------------------------------------------------------------------------------
-- TEST
----------------------------------------------------------------------------------------------------
SLASH_COMMANDS["/cc_border"] = function()
    d("Echo: /cc_border")
end

----------------------------------------------------------------------------------------------------
-- EXPORT MODULE
----------------------------------------------------------------------------------------------------
CC[Module.name] = Module
--table.insert(CC.Modules, Module)