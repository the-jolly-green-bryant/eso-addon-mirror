-- WifeyDPSPositions.lua
WifeyDPSPositions = WifeyDPSPositions or {}
local DDP = WifeyDPSPositions

function WifeyDPSPositions_TogglePanel()
    if DDP.UI and DDP.UI.Toggle then
        DDP.UI:Toggle()
    end
end

local function registerKeybinds()
    ZO_CreateStringId("SI_BINDING_NAME_WIFEYDPSPOSITIONS_PANEL_KEYBIND", "Open/Close PanelUI")
end

local hudFragment

local function hookSceneVisibility()
    if hudFragment or not DDP.UI or not DDP.UI.window then return end
    if not HUD_SCENE or not HUD_UI_SCENE then return end

    -- Keep the TopLevelControl parented to GuiRoot. The fragment controls visibility
    -- only while the panel is intentionally open, so other scenes (map, inventory,
    -- character, etc.) hide it automatically.
    hudFragment = ZO_HUDFadeSceneFragment:New(DDP.UI.window, nil, 0)
    DDP.UI.hudFragment = hudFragment
end

local function onGroupChanged(eventCode, unitTag, reason, name)
    if not DDP.UI or not DDP.UI.window or DDP.UI.window:IsHidden() then
        return
    end

    if GetGroupSize() == 0 then
        DDP.UI:ClearButtons()
        DDP.UI.panelOpen = false
        if DDP.UI.hudFragment then
            if HUD_SCENE then HUD_SCENE:RemoveFragment(DDP.UI.hudFragment) end
            if HUD_UI_SCENE then HUD_UI_SCENE:RemoveFragment(DDP.UI.hudFragment) end
        end
        DDP.UI.window:SetHidden(true)
		DDP.savedAssignments = {}
		DDP.freeAssignments = {}
		if DDP.SV then
			DDP.SV.savedAssignments = {}
			DDP.SV.freeAssignments = {}
		end
		DDP.lastMechanicShown = nil
		if DDP.ClearChatEntry then
			DDP.ClearChatEntry()
		end
        return
    end

    local currentZoneId = GetZoneId(GetUnitZoneIndex("player"))
    local zoneData = DDP.positions[currentZoneId]
    if not zoneData then return end

    if unitTag and DoesUnitExist(unitTag) then
        local role = GetGroupMemberSelectedRole(unitTag)
        if role ~= LFG_ROLE_TANK and role ~= LFG_ROLE_HEAL and role ~= LFG_ROLE_DPS then
            return
        end
    end

    local savedZone = DDP.savedAssignments and DDP.savedAssignments[currentZoneId]
    if not savedZone then return end

    local currentMechKey
    for key in pairs(savedZone) do currentMechKey = key break end
    if not currentMechKey then return end

    local mechPositions = zoneData.mechanics[currentMechKey]
    local msg = DDP.AssignToPositions(currentZoneId, currentMechKey, mechPositions)
    DDP.UI:PopulateMechanicList()
	
    if DDP.UI and DDP.UI.freeAssignmentsVisible then
        DDP.UI:PopulateFreeAssignments(currentZoneId)
    end
end

local function onAddonLoaded(event, addonName)
    if addonName ~= "WifeyDPSPositions" then return end

    math.randomseed(GetTimeStamp())
    for _ = 1, 3 do math.random() end

    DDP.SV = ZO_SavedVars:NewAccountWide("WifeyDPSPositions_SavedVars", 2, nil, {
        version = 2,
        panelPosition = {x = 500, y = 300},
        savedAssignments = {},
		freeAssignments = {},
    })
	
	if not DDP.SV.freeAssignments then
		DDP.SV.freeAssignments = {}
	end
	
    DDP.savedAssignments = DDP.SV.savedAssignments
	DDP.freeAssignments  = DDP.SV.freeAssignments

    if DDP.UI and DDP.UI.Create then DDP.UI:Create() end
    registerKeybinds()
    hookSceneVisibility()

    EVENT_MANAGER:RegisterForEvent("WifeyDPSPositions_GroupJoined", EVENT_GROUP_MEMBER_JOINED, onGroupChanged)
    EVENT_MANAGER:RegisterForEvent("WifeyDPSPositions_GroupLeave", EVENT_GROUP_MEMBER_LEFT, onGroupChanged)
    EVENT_MANAGER:RegisterForEvent("WifeyDPSPositions_GroupKick", EVENT_GROUP_MEMBER_KICKED, onGroupChanged)
    EVENT_MANAGER:RegisterForEvent("WifeyDPSPositions_RoleChanged", EVENT_GROUP_MEMBER_ROLE_CHANGED, onGroupChanged)
    EVENT_MANAGER:RegisterForEvent("WifeyDPSPositions_GroupOffline", EVENT_GROUP_MEMBER_CONNECTED_STATUS, onGroupChanged)

    EVENT_MANAGER:UnregisterForEvent("WifeyDPSPositions", EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent("WifeyDPSPositions", EVENT_ADD_ON_LOADED, onAddonLoaded)
