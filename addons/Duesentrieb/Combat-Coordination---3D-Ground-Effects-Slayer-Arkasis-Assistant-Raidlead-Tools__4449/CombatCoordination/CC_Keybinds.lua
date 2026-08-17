local CC = CombatCoordination
local LAM2 = LibAddonMenu2

----------------------------------------------------------------------------------------------------
-- MODULE VARS AND SVARS
----------------------------------------------------------------------------------------------------
CC.Keybinds = {
    Default = {},
    ---@type table|any
    SV = {},
}

----------------------------------------------------------------------------------------------------
-- GENERAL
----------------------------------------------------------------------------------------------------
ZO_CreateStringId("SI_BINDING_NAME_COMBATCOORDINATION_ADDONMENU_TOGGLE", "Addon Menu: Open / Close")
function CC.Keybinds.AddonMenuToggle()
    if CC.Menu.PanelName and LAM2 then
        if not CC.Menu.PanelName:IsHidden() then
            SCENE_MANAGER:ShowBaseScene()
        else
            LAM2:OpenToPanel(CC.Menu.PanelName)
        end
    end
end

ZO_CreateStringId("SI_BINDING_NAME_COMBATCOORDINATION_DISPLAYPANEL_TOGGLE", "Display Panel: Open / Close")
function CC.Keybinds.DisplayPanelToggle()
    if not CC.SV.enableAddon then return end
    CC.DisplayPanel:Toggle()
end

ZO_CreateStringId("SI_BINDING_NAME_COMBATCOORDINATION_DEBUGCOMBATEVENT_TOGGLE", "Debug Combat Event: Toggle")
function CC.Keybinds.DebugCombatEventToggle()
    if not CC.SV.enableAddon then return end
    CC.Events:ToggleDebugCombatEvent()
end

----------------------------------------------------------------------------------------------------
-- RAIDLEAD TOOLS
----------------------------------------------------------------------------------------------------
ZO_CreateStringId("SI_BINDING_NAME_COMBATCOORDINATION_PULLTIMER_CUSTOM", "Pull Timer: Custom")
function CC.Keybinds.PullTimerCustom()
    CC.RaidleadTools:RequestPull(CC.RaidleadTools.SV.pullSeconds)
end

ZO_CreateStringId("SI_BINDING_NAME_COMBATCOORDINATION_PULLTIMER_TRASH", "Pull Timer: Trash (3 sec)")
function CC.Keybinds.PullTimerTrash()
    if not CC.SV.enableAddon then return end
    CC.RaidleadTools:RequestPull(3)
end

ZO_CreateStringId("SI_BINDING_NAME_COMBATCOORDINATION_PULLTIMER_BOSS", "Pull Timer: Boss (5 sec)")
function CC.Keybinds.PullTimerBoss()
    if not CC.SV.enableAddon then return end
    CC.RaidleadTools:RequestPull(5)
end

ZO_CreateStringId("SI_BINDING_NAME_COMBATCOORDINATION_PULLTIMER_PREBUFF", "Pull Timer: Prebuff (10 sec)")
function CC.Keybinds.PullTimerPrebuff()
    if not CC.SV.enableAddon then return end
    CC.RaidleadTools:RequestPull(10)
end

ZO_CreateStringId("SI_BINDING_NAME_COMBATCOORDINATION_BREAKTIMER_TOGGLE", "Break Timer: Start / Stop")
function CC.Keybinds.BreakTimerToggle()
    if not CC.SV.enableAddon or not CC.IsRaidlead() then return end
    if CC.DisplayNotification.breakEndTime > GetGameTimeSeconds() then
        CC.RaidleadTools:RequestBreak(0)
    else
        CC.RaidleadTools:RequestBreak(CC.RaidleadTools.SV.breakMinutes)
    end
end

ZO_CreateStringId("SI_BINDING_NAME_COMBATCOORDINATION_EXITINSTANCE_REQUEST", "Request Exit Instance")
function CC.Keybinds.RequestExitInstance()
    if not CC.SV.enableAddon then return end
    CC.RaidleadTools:RequestExitInstance()
end

ZO_CreateStringId("SI_BINDING_NAME_COMBATCOORDINATION_SLAYERASSISTANT_TOGGLE", "Slayer Assistant: Toggle")
function CC.Keybinds.SlayerAssistantToggle()
    if not CC.SV.enableAddon then return end
    CC.SlayerAssistant:SlayerTrigger(true)
end

ZO_CreateStringId("SI_BINDING_NAME_COMBATCOORDINATION_ARKASISASSISTANT_TOGGLE", "Arkasis Assistant: Toggle")
function CC.Keybinds.ArkasisAssistantToggle()
    if not CC.SV.enableAddon then return end
    CC.ArkasisAssistant:ArkasisTrigger(true)
end

----------------------------------------------------------------------------------------------------
-- DRAWING & MARKERS
----------------------------------------------------------------------------------------------------
ZO_CreateStringId("SI_BINDING_NAME_COMBATCOORDINATION_POINTER_TOGGLE", "Draw Pointer: Place / Cancel")
function CC.Keybinds.PointerToggle()
    if not CC.SV.enableAddon then return end
    CC.Pointer:ToggleAimMode()
end

----------------------------------------------------------------------------------------------------
-- PATH TRACKING
----------------------------------------------------------------------------------------------------
ZO_CreateStringId("SI_BINDING_NAME_COMBATCOORDINATION_PATHTRACKING_TOGGLE", "PathTracking: Toggle Target")
function CC.Keybinds.PathTrackingToggle()
    if not CC.SV.enableAddon then return end
    CC.PathTracking:ToggleCurrentTarget()
end

ZO_CreateStringId("SI_BINDING_NAME_COMBATCOORDINATION_PATHTRACKING_STOPALL", "PathTracking: Stop All")
function CC.Keybinds.PathTrackingStopAll()
    if not CC.SV.enableAddon then return end
    CC.PathTracking:StopAll()
end