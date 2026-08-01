CBH = CBH or {}

--Default setting for addon. When new user defined values are saved, these values are ignored by the game
local defaults = {
	["notificationOption"] = 1,
	["autoTeleportation"] = true,
	["includePreviewHouses"] = true,
	["includeOtherPlayersHouses"] = true,
	["wasInHouse"] = false,
	["playerIsAGuest"] = false,
	["house"] = {
		["id"] = 0,
		["owner"] = "",
		["name"] = "",
	},
}

local name = "ComingBackHome"
local author = "vexaiv"
local version = "1.5.1"

local TLW = nil -- TopLevelWindow for notifications
local WM = GetWindowManager() --reference to game's WindowManager

local function saveHouseInfo(id, owner, asGuest)
	CBH.savedVars.playerIsAGuest = asGuest
	CBH.savedVars.house.id = id
	if id ~= 0 then
		local collectibleId = GetCollectibleIdForHouse(id)
		CBH.savedVars.house.name = GetCollectibleName(collectibleId)
	end
	CBH.savedVars.house.owner = owner
end

local function updateCurrentHouseInfo()
	if IsUnitInDungeon("player") then return end

	if GetCurrentZoneHouseId() ~= 0 then
		CBH.savedVars.wasInHouse = true
		local currentHouseId = GetCurrentZoneHouseId()
		local currentOwner = GetCurrentHouseOwner()
		if IsOwnerOfCurrentHouse() then --if it's player's house then save it
			saveHouseInfo(currentHouseId, GetUnitDisplayName("player"), false)
		elseif currentOwner == "" then
			if CBH.savedVars.includePreviewHouses then
				saveHouseInfo(currentHouseId, "Preview", false)
			end
		else
			if CBH.savedVars.includeOtherPlayersHouses then
				saveHouseInfo(currentHouseId, currentOwner, true)
			end
		end
	else
		CBH.savedVars.wasInHouse = false
	end
end

local function unitInCombatNotification()
	if CBH.savedVars.notificationOption == 1 then
		TLW:SetHidden(false)
		CBH_Label:SetText(GetString(COMINGBACKHOME_UI_WAITING_FOR_COMBAT_END))
		zo_callLater(function() TLW:SetHidden(true) end, 3000)
	else
		d(GetString(COMINGBACKHOME_UI_WAITING_FOR_COMBAT_END))
	end
end

local function teleportNow()
	if CBH.savedVars.house.id == 0 then
		--print in chat that there's no last house data saved
		d(GetString(COMINGBACKHOME_NO_HOUSE_TO_TELEPORT))
		return
	end
	
	if IsUnitInCombat("player") then
		unitInCombatNotification()
		zo_callLater(function() teleportNow() end, 5000)
		return
	end
	
	StopAllMovement()
	local houseId = CBH.savedVars.house.id
	local owner = CBH.savedVars.house.owner
	--ESO has two options:
	--for player's house (or preview)...
	if owner == GetUnitDisplayName("player") or owner == "Preview" then
		RequestJumpToHouse(houseId)
	--...and some specific player's house
	else
		JumpToSpecificHouse(owner, houseId)
	end
	if CBH.savedVars.notificationOption == 1 then
		TLW:SetHidden(false) --make 'TopLevelWindow' (a parent of our label control) visible
		CBH_Label:SetText(zo_strformat(GetString(COMINGBACKHOME_UI_COMING_BACK_TO), "\n", CBH.savedVars.house.name, owner))
		zo_callLater(function() TLW:SetHidden(true) end, 3000) --hide label after some time
	elseif CBH.savedVars.notificationOption == 2 then
		d(zo_strformat("CBH: ", GetString(COMINGBACKHOME_UI_COMING_BACK_TO), " ",  CBH.savedVars.house.name, owner))
	end
end

local function countdown(count)
	if count == 0 then
		TLW:SetHidden(true) --hide label in the end of countdown
		teleportNow()
		return
	end
	
	if CBH.savedVars.notificationOption == 1 then
		TLW:SetHidden(false) --make 'TopLevelWindow' (a parent of our label control) visible
		CBH_Label:SetText(zo_strformat(GetString(COMINGBACKHOME_UI_COMING_BACK_TO), "\n", CBH.savedVars.house.name, CBH.savedVars.house.owner, "\n", count))
	elseif CBH.savedVars.notificationOption == 2 then
		d(zo_strformat("CBH: ", GetString(COMINGBACKHOME_UI_COMING_BACK_TO), " ",  CBH.savedVars.house.name, CBH.savedVars.house.owner, " ", count))
	end
	
	zo_callLater(function() countdown(count - 1) end, 1000)
end

local function startCountdown()
	countdown(5)
end

local function onKickTimerUpdate(eventCode, timeRemainingMs)
	if CBH.savedVars.house.id ~= 0 and CBH.savedVars.wasInHouse and CBH.savedVars.autoTeleportation then
		--jumping back to last house when not in a group anymore
		startCountdown()
	end
end

--[[
Doesn't work, because jumping from PvP areas is forbidden////
local function onBGStateChanged(eventCode, previousState, currentState)
	if currentState == BATTLEGROUND_STATE_POSTGAME and CBH.savedVars.house.id ~= 0 and CBH.savedVars.wasInHouse and CBH.savedVars.autoTeleportation then
		startTeleportation()
	end
end
]]--

--label control for notifications
local function createControl()
	TLW = WM:CreateTopLevelWindow("CBH_TLW")
	TLW:SetDimensions(600,120)
	TLW:SetResizeToFitDescendents(true)
	TLW:SetAnchor(CENTER, GuiRoot, CENTER, 0, 110)
	TLW:SetMovable(false)
	TLW:SetMouseEnabled(false)
	TLW:SetClampedToScreen(true)
	TLW:SetTopmost(true)
	TLW:SetHidden(true)

	CreateControl("CBH_Label", TLW, CT_LABEL)
	CBH_Label:SetColor(0.9, 0.9, 0.9, 1)
	CBH_Label:SetFont("ZoFontAlert")
	CBH_Label:SetScale(1)
	CBH_Label:SetMaxLineCount(3)
	CBH_Label:SetWrapMode(TEX_MODE_CLAMP)
	CBH_Label:SetDrawLayer(1)
	CBH_Label:SetAnchor(CENTER, TLW, CENTER, 0, 110)
	CBH_Label:SetDimensions(600,120)
	CBH_Label:SetHorizontalAlignment(1)
end

local function onAddOnLoaded(event, addonName)
	if addonName ~= name then return end
	EVENT_MANAGER:UnregisterForEvent(name, EVENT_ADD_ON_LOADED)
	
	-- Register our keybinding names
	ZO_CreateStringId("SI_BINDING_NAME_COMING_BACK_HOME", GetString(COMINGBACKHOME_KEYBINDING))
	
	--slash command and function which is called with this command
	SLASH_COMMANDS["/cbh"] = teleportNow
	
	--get or create account-wide saved variables
	CBH.savedVars = ZO_SavedVars:NewAccountWide("ComingBackHomeSavedVariables", 1.5, nil, defaults)
	
	if not CBH.savedVars.useAccountWide then
		--get or create character-wide with name change support
		CBH.savedVars = ZO_SavedVars:NewCharacterNameSettings("ComingBackHomeSavedVariables", 1.5, nil, defaults)
	end
	
	if CBH.savedVars.notificationOption == 1 then
		createControl() --notification label control
	end
	
	CBHMenu.createSettingsMenu() --in ComingBackHomeMenu.lua file (needs LibAddonMenu-2.0)
	
	--EVENT_PLAYER_ACTIVATED occurs after every loading screen, addon will check current zone then
	EVENT_MANAGER:RegisterForEvent(name, EVENT_PLAYER_ACTIVATED, updateCurrentHouseInfo)
	--EVENT_INSTANCE_KICK_TIME_UPDATE occurs when player left a group in dungeon/trial, addon will teleport the player to house then
	EVENT_MANAGER:RegisterForEvent(name, EVENT_INSTANCE_KICK_TIME_UPDATE, onKickTimerUpdate)
	--////Doesn't work in PvP areas
	--BattlegroundStateChanged returns "PostGame" when match is over, addon will teleport the player to house then
	--EVENT_MANAGER:RegisterForEvent(name, EVENT_BATTLEGROUND_STATE_CHANGED, onBGStateChanged)
	--////
end

EVENT_MANAGER:RegisterForEvent(name, EVENT_ADD_ON_LOADED, onAddOnLoaded)

CBH = {
	name = name,
	author = author,
	version = version,
	savedVars = savedVars,
	teleportNow = teleportNow,
	countdown = countdown,
}
