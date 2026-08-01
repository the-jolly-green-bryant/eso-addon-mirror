-- RdK Group Tool Respawner
-- By @s0rdrak (PC / EU)

RdKGTool.toolbox = RdKGTool.toolbox or {}
local RdKGToolTB = RdKGTool.toolbox
RdKGToolTB.respawner = RdKGToolTB.respawner or {}
local RdKGToolRespawner = RdKGToolTB.respawner
RdKGTool.menu = RdKGTool.menu or {}
local RdKGToolMenu = RdKGTool.menu
RdKGTool.util = RdKGTool.util or {}
local RdKGToolUtil = RdKGTool.util
RdKGToolUtil.group = RdKGToolUtil.group or {}
local RdKGToolUtilGroup = RdKGToolUtil.group
RdKGToolUtil.cyrodiil = RdKGToolUtil.cyrodiil or {}
local RdKGToolCyro = RdKGToolUtil.cyrodiil

RdKGToolRespawner.constants = RdKGToolRespawner.constants or {}
RdKGToolRespawner.constants.TLW = "RdKGToolToolboxRespawnerTLW"
RdKGToolRespawner.constants.KEEP = "RdKGToolToolboxRespawnerKEEP"
RdKGToolRespawner.constants.CAMP = "RdKGToolToolboxRespawnerCAMP"

RdKGToolRespawner.callbackName = RdKGTool.addonName .. "Respawner"
RdKGToolRespawner.delayCallbackName = RdKGTool.addonName .. "RespawnerDelayInit"

RdKGToolRespawner.config = {}
RdKGToolRespawner.config.initDelay = 100
RdKGToolRespawner.config.updateInterval = 100

RdKGToolRespawner.controls = {}

RdKGToolRespawner.state = {}
RdKGToolRespawner.state.initialized = false
RdKGToolRespawner.state.alreadyEnabled = false
RdKGToolRespawner.state.updateLoopRunning = false

local wm = GetWindowManager()

function RdKGToolRespawner.Initialize()
	RdKGTool.profile.AddProfileChangeListener(RdKGToolRespawner.callbackName, RdKGToolRespawner.OnProfileChanged)
	ZO_CreateStringId("SI_BINDING_NAME_RDKGTOOL_DEATH_CAMP", RdKGToolRespawner.constants.KEYBINDING_RESPAWN_CAMP)
	ZO_CreateStringId("SI_BINDING_NAME_RDKGTOOL_DEATH_KEEP", RdKGToolRespawner.constants.KEYBINDING_RESPAWN_KEEP)
	RdKGToolRespawner.CreateUI()
	RdKGToolRespawner.state.initialized = true
	EVENT_MANAGER:RegisterForUpdate(RdKGToolRespawner.delayCallbackName, RdKGToolRespawner.config.initDelay, RdKGToolRespawner.DelayedInit)
end

--[[
/script tempHud = ZO_HUDFadeSceneFragment:New(RdKGTool.toolbox.respawner.controls.tlw)
/script HUD_SCENE:AddFragment(RdKGTool.toolbox.respawner.controls.hudControl)
/script HUD_UI_SCENE:AddFragment(RdKGTool.toolbox.respawner.controls.hudControl)
/script RdKGTool.toolbox.respawner.controls.hudControl:Show()
/script d(getmetatable(ZO_DeathAvA))
/script d(getmetatable(ZO_DeathAvAButtons))
/script d(DEATH.types["AvA"].buttons[1]:SetHidden(true))
/script RdKGTool.toolbox.respawner.controls.rootControl.keep:SetAnchor(TOPLEFT, GuiRoot,TOPLEFT,300,300)
/script RdKGTool.toolbox.respawner.controls.rootControl:SetAnchor(TOPLEFT, ZO_DeathAvAButtons, TOPLEFT, 0, 0)
]]
function RdKGToolRespawner.CreateUI()
	RdKGToolRespawner.controls.tlw = wm:CreateTopLevelWindow(RdKGToolRespawner.constants.TLW)
	RdKGToolRespawner.controls.tlw:SetHidden(true)
	RdKGToolRespawner.controls.rootControl = wm:CreateControl(nil, RdKGToolRespawner.controls.tlw, CT_CONTROL)
	local rootControl = RdKGToolRespawner.controls.rootControl
	
	rootControl.keep = wm:CreateControlFromVirtual(RdKGToolRespawner.constants.KEEP, rootControl, "ZO_KeybindButton")
	rootControl.keep:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, 0)
	rootControl.keep.nameLabel:SetText(RdKGToolRespawner.constants.RESPAWN_KEEP)
	rootControl.keep:SetKeybind('RDKGTOOL_DEATH_RESPAWN_KEEP')
	rootControl.keep:SetCallback(function() d("keep") end)
	
	rootControl.camp = wm:CreateControlFromVirtual(RdKGToolRespawner.constants.CAMP, rootControl, "ZO_KeybindButton")
	rootControl.camp:SetAnchor(TOPLEFT, rootControl, TOPRIGHT, 200, 0)
	rootControl.camp.nameLabel:SetText(RdKGToolRespawner.constants.RESPAWN_CAMP)
	rootControl.camp:SetKeybind('RDKGTOOL_DEATH_RESPAWN_CAMP')
	rootControl.camp:SetCallback(function() d("camp") end)
    
	
end

function RdKGToolRespawner.GetDefaults()
	local defaults = {}
	defaults.enabled = true
	defaults.restrictedPort = true
	return defaults
end

function RdKGToolRespawner.SetEnabled(value)
	if RdKGToolRespawner.state.initialized == true and value ~= nil then
		RdKGToolRespawner.reVars.enabled = value
		if value == true and IsInCyrodiil() == true then
			if RdKGToolRespawner.state.alreadyEnabled == false then
				RdKGToolRespawner.controls.rootControl:SetParent(ZO_DeathAvAButtons)
				RdKGToolRespawner.controls.rootControl:ClearAnchors()
				RdKGToolRespawner.controls.rootControl:SetAnchor(TOPLEFT, ZO_DeathAvAButtons, TOPLEFT, -400, 0)
				RdKGToolRespawner.state.alreadyEnabled = true
				--EVENT_MANAGER:RegisterForUpdate(RdKGToolRespawner.callbackName, RdKGToolRespawner.config.updateInterval, RdKGToolRespawner.UpdateRespawn)
				EVENT_MANAGER:RegisterForEvent(RdKGToolRespawner.callbackName, EVENT_PLAYER_DEAD, RdKGToolRespawner.OnPlayerDead)
				EVENT_MANAGER:RegisterForEvent(RdKGToolRespawner.callbackName, EVENT_PLAYER_ALIVE, RdKGToolRespawner.OnPlayerAlive)
				if IsUnitDead("player") == true then
					RdKGToolRespawner.OnPlayerDead()
				end
			end
		else
			if RdKGToolRespawner.state.alreadyEnabled == true then
				RdKGToolRespawner.controls.rootControl:SetParent(RdKGToolRespawner.controls.tlw)
				RdKGToolRespawner.state.alreadyEnabled = false
				--EVENT_MANAGER:UnregisterForUpdate(RdKGToolRespawner.callbackName)
				EVENT_MANAGER:UnregisterForEvent(RdKGToolRespawner.callbackName, EVENT_PLAYER_DEAD)
				EVENT_MANAGER:UnregisterForEvent(RdKGToolRespawner.callbackName, EVENT_PLAYER_ALIVE)
				RdKGToolRespawner.DisableUpdateLoop()
			end
		end
	end
end

function RdKGToolRespawner.CombineKeepLists(keeps, outposts, villages)
	local keepEntries = {}
	for key, keep in pairs(keeps) do
		keepEntries[key] = keep
	end
	for key, keep in pairs(outposts) do
		keepEntries[key] = keep
	end
	for key, keep in pairs(villages) do
		keepEntries[key] = keep
	end
	return keepEntries
end

function RdKGToolRespawner.RetrieveAllRespawnKeeps()
	local keeps = {}
	RdKGToolCyro.AdjustKeepCoordinates()
	RdKGToolCyro.AdjustOutpostCoordinates()
	RdKGToolCyro.AdjustVillageCoordinates()
	local potentialRespawnKeeps = RdKGToolRespawner.CombineKeepLists(RdKGToolCyro.GetKeeps(), RdKGToolCyro.GetOutposts(), RdKGToolCyro.GetVillages())
	if potentialRespawnKeeps ~= nil then
		for key, keep in pairs(potentialRespawnKeeps) do
			if CanRespawnAtKeep(key) then
				table.insert(keeps, keep)
			end
		end
	end
	--CanRespawnAtKeep
	return keeps
end

function RdKGToolRespawner.RetrieveNearestKeep()
	local nearestKeep = nil
	RdKGToolCyro.AdjustKeepCoordinates()
	RdKGToolCyro.AdjustOutpostCoordinates()
	RdKGToolCyro.AdjustVillageCoordinates()
	local potentialRespawnKeeps = RdKGToolRespawner.CombineKeepLists(RdKGToolCyro.GetKeeps(), RdKGToolCyro.GetOutposts(), RdKGToolCyro.GetVillages())
	if potentialRespawnKeeps ~= nil then
		local playerX, playerY = GetMapPlayerPosition("player")
		for key, keep in pairs(potentialRespawnKeeps) do
			keep.customData = keep.customData or {}
			keep.customData.distance = math.sqrt((playerX - keep.x) * (playerX - keep.x) + (playerY - keep.y) * (playerY - keep.y))
			if nearestKeep == nil or keep.customData.distance < nearestKeep.customData.distance then
				nearestKeep = keep
			end
		end
	end
	return nearestKeep
end

function RdKGToolRespawner.RetrieveNearbyCamps()
	local camps = {}
	local numCamps = GetNumForwardCamps(BGQUERY_LOCAL)
	for i = 1, numCamps do
		local camp = {}
		camp.id = i
		camp.pinType, camp.x, camp.y, camp.radius, camp.useable = GetForwardCampPinInfo(BGQUERY_LOCAL, i)
		if camp.useable == true then
			table.insert(camps, camp)
		end
	end	
	return camps
end

function RdKGToolRespawner.RespawnAtCamp()
	if RdKGToolRespawner.reVars.enabled == true and IsInCyrodiil() == true then
		--d("respawn at camp")
		local camps = RdKGToolRespawner.RetrieveNearbyCamps()
		if #camps > 0 then
			if #camps == 1 then
				RespawnAtForwardCamp(camps[1].id)
			else
				--calculate
				local leader = RdKGToolUtilGroup.GetLeaderUnit()
				if leader ~= nil and leader.coordinates ~= nil and leader.coordinates.localX ~= nil and leader.coordinates.localY ~= nil then
					local localX = leader.coordinates.localX
					local localY = leader.coordinates.localY
					for i = 1, #camps do
						local x = camps[i].x
						local y = camps[i].y
						camps[i].distanceToLeader = math.sqrt((localX - x) * (localX - x) + (localY - y) * (localY - y))
					end
					local camp = camps[1]
					for i = 1, #camps do
						if camps[i].distanceToLeader < camp.distanceToLeader then
							camp = camps[i]
						end
					end
					RespawnAtForwardCamp(camp.id)
				else
					RespawnAtForwardCamp(camps[1].id)
				end
			end
		end
	end
end

function RdKGToolRespawner.RespawnAtKeep()
	if RdKGToolRespawner.reVars.enabled == true and IsInCyrodiil() == true then
		--d("respawn at keep")
		if RdKGToolRespawner.reVars.restrictedPort == false then
			local keeps = RdKGToolRespawner.RetrieveAllRespawnKeeps()
			if #keeps > 0 then
				local playerX, playerY = GetMapPlayerPosition("player")
				for i = 1, #keeps do
					local keep = keeps[i]
					keep.customData = keep.customData or {}
					keep.customData.distance = math.sqrt((playerX - keep.x) * (playerX - keep.x) + (playerY - keep.y) * (playerY - keep.y))
				end
				local keep = keeps[1]
				for i = 1, #keeps do
					if keeps[i].customData.distance < keep.customData.distance then
						keep =  keeps[i]
					end
				end
				RespawnAtKeep(keep.id)
			end
		else
			local keep = RdKGToolRespawner.RetrieveNearestKeep()
			if keep ~= nil and CanRespawnAtKeep(keep.id) == true then
				RespawnAtKeep(keep.id)
			end
		end
	end
end

function RdKGToolRespawner.KeybindingPlaceholder()
end

function RdKGToolRespawner.EnabledUpdateLoop()
	if RdKGToolRespawner.state.updateLoopRunning == false then
		RdKGToolUtilGroup.AddFeature(RdKGToolRespawner.callbackName, RdKGToolUtilGroup.features.FEATURE_GROUP_COORDINATES, RdKGToolRespawner.config.updateInterval)
		EVENT_MANAGER:RegisterForUpdate(RdKGToolRespawner.callbackName, RdKGToolRespawner.config.updateInterval, RdKGToolRespawner.UpdateRespawn)
		RdKGToolRespawner.state.updateLoopRunning = true
	end
end

function RdKGToolRespawner.DisableUpdateLoop()
	if RdKGToolRespawner.state.updateLoopRunning == true then
		EVENT_MANAGER:UnregisterForUpdate(RdKGToolRespawner.callbackName)
		RdKGToolUtilGroup.RemoveFeature(RdKGToolRespawner.callbackName, RdKGToolUtilGroup.features.FEATURE_GROUP_COORDINATES)
		RdKGToolRespawner.state.updateLoopRunning = false
	end
end

--callbacks
function RdKGToolRespawner.OnProfileChanged(currentProfile)
	if currentProfile ~= nil then
		RdKGToolRespawner.reVars = currentProfile.toolbox.respawner
		if RdKGToolRespawner.state.initialized == true then
			RdKGToolRespawner.SetEnabled(RdKGToolRespawner.reVars.enabled)
		end
	end
end

function RdKGToolRespawner.DelayedInit()
	EVENT_MANAGER:UnregisterForUpdate(RdKGToolRespawner.delayCallbackName)
	EVENT_MANAGER:RegisterForEvent(RdKGToolRespawner.callbackName, EVENT_PLAYER_ACTIVATED, RdKGToolRespawner.OnPlayerActivated)
	RdKGToolRespawner.OnPlayerActivated()
end

function RdKGToolRespawner.OnPlayerActivated()
	RdKGToolRespawner.SetEnabled(RdKGToolRespawner.reVars.enabled)
end

function RdKGToolRespawner.OnPlayerDead()
	RdKGToolRespawner.EnabledUpdateLoop()
end

function RdKGToolRespawner.OnPlayerAlive()
	RdKGToolRespawner.DisableUpdateLoop()
end

function RdKGToolRespawner.UpdateRespawn()
	--camps
	--d("update loop")
	local camps = RdKGToolRespawner.RetrieveNearbyCamps()
	if #camps > 0 then
		RdKGToolRespawner.controls.rootControl.camp:SetEnabled(true)
	else
		RdKGToolRespawner.controls.rootControl.camp:SetEnabled(false)
	end
	
	--keeps
	if RdKGToolRespawner.reVars.restrictedPort == false then
		local keeps = RdKGToolRespawner.RetrieveAllRespawnKeeps()
		if #keeps > 0 then
			RdKGToolRespawner.controls.rootControl.keep:SetEnabled(true)
		else
			RdKGToolRespawner.controls.rootControl.keep:SetEnabled(false)
		end
	else
		local keep = RdKGToolRespawner.RetrieveNearestKeep()
		if keep ~= nil and CanRespawnAtKeep(keep.id) == true then
			RdKGToolRespawner.controls.rootControl.keep:SetEnabled(true)
		else
			RdKGToolRespawner.controls.rootControl.keep:SetEnabled(false)
		end
	end
end

--menu interactions
function RdKGToolRespawner.GetMenu()
	local menu = {
		[1] = {
			type = "submenu",
			name = RdKGToolMenu.constants.RESPAWNER_HEADER,
			controls = {
				[1] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.RESPAWNER_ENABLED,
					getFunc = RdKGToolRespawner.GetRespawnerEnabled,
					setFunc = RdKGToolRespawner.SetRespawnerEnabled
				},
				[2] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.RESPAWNER_RESTRICTED_PORT,
					getFunc = RdKGToolRespawner.GetRespawnerRestrictedPort,
					setFunc = RdKGToolRespawner.SetRespawnerRestrictedPort
				}
			}
		}
	}
	return menu
end

function RdKGToolRespawner.GetRespawnerEnabled()
	return RdKGToolRespawner.reVars.enabled
end

function RdKGToolRespawner.SetRespawnerEnabled(value)
	RdKGToolRespawner.SetEnabled(value)
end

function RdKGToolRespawner.GetRespawnerRestrictedPort()
	return RdKGToolRespawner.reVars.restrictedPort
end

function RdKGToolRespawner.SetRespawnerRestrictedPort(value)
	RdKGToolRespawner.reVars.restrictedPort = value
end