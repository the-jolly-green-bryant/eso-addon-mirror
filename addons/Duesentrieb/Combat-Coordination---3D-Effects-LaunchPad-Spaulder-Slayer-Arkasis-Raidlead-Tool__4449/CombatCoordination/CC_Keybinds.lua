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
-- KEYBINDS (ALPHABETICAL)
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

ZO_CreateStringId("SI_BINDING_NAME_COMBATCOORDINATION_ARKASISASSISTANT_TOGGLE", "Arkasis Assistant: Toggle")
function CC.Keybinds.ArkasisAssistantToggle()
    if not CC.SV.enableAddon then return end
    CC.ArkasisAssistant:ArkasisTrigger(true)
end

ZO_CreateStringId("SI_BINDING_NAME_COMBATCOORDINATION_DISPLAYPANEL_TOGGLE", "Display Panel: Open / Close")
function CC.Keybinds.DisplayPanelToggle()
    if not CC.SV.enableAddon then return end
    CC.DisplayPanel:Toggle()
end

ZO_CreateStringId("SI_BINDING_NAME_COMBATCOORDINATION_POINTER_TOGGLE", "Draw Pointer: Place / Cancel")
function CC.Keybinds.PointerToggle()
    if not CC.SV.enableAddon then return end
    CC.Pointer:ToggleAimMode()
end

ZO_CreateStringId("SI_BINDING_NAME_COMBATCOORDINATION_FAST_TRAVEL_PRIMARY", "Fast Travel: Primary Residence")
function CC.Keybinds.FastTravelPrimary()
    if not CC.SV.enableAddon then return end
    local houseId = GetHousingPrimaryHouse()

    if houseId and houseId > 0 then
        local collectibleId = GetCollectibleIdForHouse(houseId)
        local houseName = "Primary Residence"

        if collectibleId and collectibleId > 0 then
            houseName = zo_strformat("<<1>>", GetCollectibleName(collectibleId))
        end

        d(string.format("%s Porting to: %s", CC.CHAT, CC.ColorString("[" .. houseName .. "]", "GN")))
        RequestJumpToHouse(houseId)
    else
        d(string.format("%s %s", CC.CHAT, CC.ColorString("No primary residence set.", "RD")))
    end
end

ZO_CreateStringId("SI_BINDING_NAME_COMBATCOORDINATION_PATHTRACKING_TOGGLE", "PathTracking: Toggle CT")
function CC.Keybinds.PathTrackingToggle()
    if not CC.SV.enableAddon then return end
    CC.PathTracking:ToggleCurrentTarget()
end

ZO_CreateStringId("SI_BINDING_NAME_COMBATCOORDINATION_PATHTRACKING_STOPALL", "PathTracking: Stop All")
function CC.Keybinds.PathTrackingStopAll()
    if not CC.SV.enableAddon then return end
    CC.PathTracking:StopAll()
end

ZO_CreateStringId("SI_BINDING_NAME_COMBATCOORDINATION_EXITINSTANCE_REQUEST", "Request: P-T-E")
function CC.Keybinds.RequestExitInstance()
    if not CC.SV.enableAddon then return end
    CC.RaidleadTools:RequestExitInstance()
end

ZO_CreateStringId("SI_BINDING_NAME_COMBATCOORDINATION_PORT_IN_PLEASE", "Request: Port In Please")
function CC.Keybinds.PortInPlease()
    if not CC.SV.enableAddon then return end
    CC.RaidleadTools:RequestPortIn()
end

ZO_CreateStringId("SI_BINDING_NAME_COMBATCOORDINATION_WIPE_PLEASE", "Request: Wipe Please")
function CC.Keybinds.WipePlease()
    if not CC.SV.enableAddon then return end
    CC.RaidleadTools:RequestWipe()
end

ZO_CreateStringId("SI_BINDING_NAME_COMBATCOORDINATION_RESET_INSTANCE", "Reset Instance")
function CC.Keybinds.ResetInstance()
    if not CC.SV.enableAddon then return end
    CC.RaidleadTools:ResetInstance()
end

ZO_CreateStringId("SI_BINDING_NAME_COMBATCOORDINATION_SLAYERASSISTANT_TOGGLE", "Slayer Assistant: Toggle")
function CC.Keybinds.SlayerAssistantToggle()
    if not CC.SV.enableAddon then return end
    CC.SlayerAssistant:SlayerTrigger(true)
end

ZO_CreateStringId("SI_BINDING_NAME_COMBATCOORDINATION_SPAULDER_TOGGLE", "Spaulder: Stack & Save")
function CC.Keybinds.SpaulderToggle()
    if not CC.SV.enableAddon then return end
    CC.SpaulderOfRuin:SpaulderTrigger(true)
end

ZO_CreateStringId("SI_BINDING_NAME_COMBATCOORDINATION_SPAULDER_REINVITE", "Spaulder: Reinvite")
function CC.Keybinds.SpaulderReinvite()
    if not CC.SV.enableAddon then return end
    CC.SpaulderOfRuin:Reinvite()
end

ZO_CreateStringId("SI_BINDING_NAME_COMBATCOORDINATION_SPAULDER_KICK_REINVITE", "Spaulder: Kick & Reinvite")
function CC.Keybinds.SpaulderKickReinvite()
    if not CC.SV.enableAddon then return end
    CC.SpaulderOfRuin:KickAndReinvite()
end

ZO_CreateStringId("SI_BINDING_NAME_COMBATCOORDINATION_BREAKTIMER_TOGGLE", "Timer: Break Start / Stop")
function CC.Keybinds.BreakTimerToggle()
    if not CC.SV.enableAddon or not CC.IsRaidlead() then return end
    if CC.DisplayNotification.breakEndTime > GetGameTimeSeconds() then
        CC.RaidleadTools:RequestBreak(0)
    else
        CC.RaidleadTools:RequestBreak(CC.RaidleadTools.SV.breakMinutes)
    end
end

ZO_CreateStringId("SI_BINDING_NAME_COMBATCOORDINATION_PULLTIMER_TRASH", "Timer: Pull Trash (3 sec)")
function CC.Keybinds.PullTimerTrash()
    if not CC.SV.enableAddon then return end
    CC.RaidleadTools:RequestPull(3)
end

ZO_CreateStringId("SI_BINDING_NAME_COMBATCOORDINATION_PULLTIMER_BOSS", "Timer: Pull Boss (5 sec)")
function CC.Keybinds.PullTimerBoss()
    if not CC.SV.enableAddon then return end
    CC.RaidleadTools:RequestPull(5)
end

ZO_CreateStringId("SI_BINDING_NAME_COMBATCOORDINATION_PULLTIMER_PREBUFF", "Timer: Pull Prebuff (10 sec)")
function CC.Keybinds.PullTimerPrebuff()
    if not CC.SV.enableAddon then return end
    CC.RaidleadTools:RequestPull(10)
end

ZO_CreateStringId("SI_BINDING_NAME_COMBATCOORDINATION_PULLTIMER_CUSTOM", "Timer: Pull Custom")
function CC.Keybinds.PullTimerCustom()
    if not CC.SV.enableAddon then return end
    CC.RaidleadTools:RequestPull(CC.RaidleadTools.SV.pullSeconds)
end