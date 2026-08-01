RengarusAntiquariansEye = {}
RengarusAntiquariansEye.name = "RengarusAntiquariansEye"
RengarusAntiquariansEye.version="1"

RengarusAntiquariansEye.Default = {
	autoUse = true,
	ignoreMovement = false
}

local LAM2 = LibAddonMenu2

--		SLOT INDEX
--			4
--		5		3
--	6				2
--		7		1
--			8

local previousSlot
local eyeSlot
local backupSlot

local isDigging = false

local function FindEye()
	eyeSlot = 0
	for i = 1, 8, 1 do 
		if GetSlotItemLink(i, HOTBAR_CATEGORY_QUICKSLOT_WHEEL) == "|H0:collectible:8006|h|h" then
			eyeSlot = i
		end
	end
end

local function SlotEye()
	if eyeSlot ~= 0 and GetSlotItemLink(GetCurrentQuickslot(), HOTBAR_CATEGORY_QUICKSLOT_WHEEL) ~= "|H0:collectible:8006|h|h" then
		previousSlot = GetCurrentQuickslot()
		SetCurrentQuickslot(eyeSlot)
	end
end

local function UnslotEye()
	if GetSlotItemLink(GetCurrentQuickslot(), HOTBAR_CATEGORY_QUICKSLOT_WHEEL) == "|H0:collectible:8006|h|h" then
		SetCurrentQuickslot(previousSlot)
	end
end

local function MainLoop()
	if not IsCollectibleBlocked(8006) then
		SlotEye()
		if not isDigging == true and RengarusAntiquariansEye.savedVariables.autoUse == true and GetCollectibleCooldownAndDuration(8006) == 0 and (not IsPlayerMoving() or RengarusAntiquariansEye.savedVariables.ignoreMovement) then
			UseCollectible(8006)
		end
	else
		UnslotEye()
	end
end

local function OnPlayerActivated()
	if GetMapContentType() ~= MAP_CONTENT_AVA and GetMapContentType() ~= MAP_CONTENT_BATTLEGROUND and GetMapContentType() ~= MAP_CONTENT_DUNGEON then
		EVENT_MANAGER:RegisterForUpdate(RengarusAntiquariansEye.name.."TickUpdate", 1000, function(gameTimeMs) MainLoop() end)
	else
		EVENT_MANAGER:UnregisterForUpdate(RengarusAntiquariansEye.name.."TickUpdate")
	end
end

local function UpdateSlots()
	FindEye()
	if GetCurrentQuickslot() ~= eyeSlot then
		previousSlot = GetCurrentQuickslot()
	end
end

local function OnHotbarUpdate()
	if eyeSlot ~= 0 then
		backupSlot = eyeSlot
	end
	UpdateSlots()
	if eyeSlot == previousSlot then
		previousSlot = backupSlot
	end
end

local function OnDiggingStart()
	isDigging = true
end

local function OnDiggingEnd(event, accept)
	isDigging = false
end

	--if IsBlockActive() then
		--isDigging = false
	--end

local function CreateSettingsWindow()
	local panelData = {
		type = "panel",
		name = "Rengaru's Antiquarian's Eye",
		displayName = "Rengaru's Antiquarian's Eye",
		author = "Rengaru",
		version = RengarusAntiquariansEye.version,
		registerForRefresh = true,
	} 
	local cntrlOptionsPanel = LAM2:RegisterAddonPanel("RengarusAntiquariansEye_SettingsPanel", panelData)
	local optionsData = {
		[1] = {
			type = "checkbox",
			name = "Auto-Eye",
			tooltip = "Automatically use the Antiquarian's Eye when standing still near a dig site.",
			default = true,
			getFunc = function() return RengarusAntiquariansEye.savedVariables.autoUse end,
			setFunc = function(newValue) RengarusAntiquariansEye.savedVariables.autoUse = newValue end,
		},
		[2] = {
			type = "checkbox",
			name = "Ignore Movement",
			tooltip = "Automatically use the Antiquarian's Eye even when moving.",
			disabled = function() return not RengarusAntiquariansEye.savedVariables.autoUse end,
			default = false,
			getFunc = function() return RengarusAntiquariansEye.savedVariables.ignoreMovement end,
			setFunc = function(newValue) RengarusAntiquariansEye.savedVariables.ignoreMovement = newValue end,
		},
	}
	LAM2:RegisterOptionControls("RengarusAntiquariansEye_SettingsPanel", optionsData)
end

local function OnAddOnLoaded(event, addonName)
	if addonName == RengarusAntiquariansEye.name then
		RengarusAntiquariansEye.savedVariables = ZO_SavedVars:NewAccountWide("RengarusAntiquariansEye_SavedVars", RengarusAntiquariansEye.version, nil, RengarusAntiquariansEye.Default)
		EVENT_MANAGER:RegisterForEvent(RengarusAntiquariansEye.name, EVENT_ACTIVE_QUICKSLOT_CHANGED, UpdateSlots)
		EVENT_MANAGER:RegisterForEvent(RengarusAntiquariansEye.name, EVENT_HOTBAR_SLOT_UPDATED, OnHotbarUpdate)
		EVENT_MANAGER:RegisterForEvent(RengarusAntiquariansEye.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
		EVENT_MANAGER:RegisterForEvent(RengarusAntiquariansEye.name, EVENT_ANTIQUITY_DIGGING_READY_TO_PLAY, OnDiggingStart)
		EVENT_MANAGER:RegisterForEvent(RengarusAntiquariansEye.name, EVENT_ANTIQUITY_DIGGING_EXIT_RESPONSE, OnDiggingEnd)
		CreateSettingsWindow()
		UpdateSlots()
	end
end

EVENT_MANAGER:RegisterForEvent(RengarusAntiquariansEye.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)