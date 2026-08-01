-- DDPositions.lua
DDPositions = DDPositions or {}
local DDP = DDPositions

function DDPositions_TogglePanel()
    if DDP.UI and DDP.UI.Toggle then
        DDP.UI:Toggle()
    end
end

local function registerKeybinds()
    ZO_CreateStringId("SI_BINDING_NAME_DDPOSITIONS_PANEL_KEYBIND", "Open/Close PanelUI")
end

local function hookSceneVisibility()
    local wasVisible = false
    for sceneName, scene in pairs(SCENE_MANAGER.scenes) do
        if scene and not scene.DDPositionsCallbackRegistered then
            scene:RegisterCallback("StateChange", function(_, newState)
                if not (DDP.UI and DDP.UI.window) then return end
                local currentZoneId = GetZoneId(GetUnitZoneIndex("player"))
                local validZone = DDP.positions[currentZoneId] ~= nil

                if newState == SCENE_SHOWING then
                    if sceneName ~= "hud" and sceneName ~= "hudui" then
                        if not DDP.UI.window:IsHidden() then
                            wasVisible = true
                            DDP.UI.window:SetHidden(true)
                        end
                    elseif wasVisible then
                        if validZone then
                            DDP.UI.window:SetHidden(false)
                        end
                        wasVisible = false
                    end
                end
            end)
            scene.DDPositionsCallbackRegistered = true
        end
    end
end

local function onGroupChanged(eventCode, unitTag, reason, name)
    if not DDP.UI or not DDP.UI.window or DDP.UI.window:IsHidden() then
        return
    end

    if GetGroupSize() == 0 then
        DDP.UI:ClearButtons()
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
    if addonName ~= "DDPositions" then return end

    math.randomseed(GetTimeStamp())
    for _ = 1, 3 do math.random() end

    DDP.SV = ZO_SavedVars:NewAccountWide("DDPositions_SavedVars", 2, nil, {
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

    EVENT_MANAGER:RegisterForEvent("DDPositions_GroupJoined", EVENT_GROUP_MEMBER_JOINED, onGroupChanged)
    EVENT_MANAGER:RegisterForEvent("DDPositions_GroupLeave", EVENT_GROUP_MEMBER_LEFT, onGroupChanged)
    EVENT_MANAGER:RegisterForEvent("DDPositions_GroupKick", EVENT_GROUP_MEMBER_KICKED, onGroupChanged)
    EVENT_MANAGER:RegisterForEvent("DDPositions_RoleChanged", EVENT_GROUP_MEMBER_ROLE_CHANGED, onGroupChanged)
    EVENT_MANAGER:RegisterForEvent("DDPositions_GroupOffline", EVENT_GROUP_MEMBER_CONNECTED_STATUS, onGroupChanged)

    EVENT_MANAGER:UnregisterForEvent("DDPositions", EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent("DDPositions", EVENT_ADD_ON_LOADED, onAddonLoaded)
