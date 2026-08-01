-- RdK Group Tool Crown
-- By @s0rdrak (PC / EU)

RdKGTool.group.crown = RdKGTool.group.crown or {}
local RdKGToolCrown = RdKGTool.group.crown

RdKGTool.menu = RdKGTool.menu or {}
local RdKGToolMenu = RdKGTool.menu
RdKGTool.util = RdKGTool.util or {}
local RdKGToolUtil = RdKGTool.util
RdKGToolUtil.chatSystem = RdKGToolUtil.chatSystem or {}
local RdKGToolChat = RdKGToolUtil.chatSystem

RdKGToolCrown.callbackName = RdKGTool.addonName .. "Crown"
RdKGToolCrown.crownVars = nil

RdKGToolCrown.constants = {}
RdKGToolCrown.constants.PREFIX = "Crown"

RdKGToolCrown.config = {}
RdKGToolCrown.config.crowns = {}
RdKGToolCrown.config.crowns[1] = {}
RdKGToolCrown.config.crowns[1].dds = "EsoUI/Art/Compass/groupleader.dds"
RdKGToolCrown.config.crowns[2] = {}
RdKGToolCrown.config.crowns[2].dds = "RdKGroupTool/Art/Crowns/Pfeilweiss.dds"
RdKGToolCrown.config.crowns[3] = {}
RdKGToolCrown.config.crowns[3].dds = "RdKGroupTool/Art/Crowns/Pfeilblau.dds"
RdKGToolCrown.config.crowns[4] = {}
RdKGToolCrown.config.crowns[4].dds = "RdKGroupTool/Art/Crowns/Pfeilhellblau.dds"
RdKGToolCrown.config.crowns[5] = {}
RdKGToolCrown.config.crowns[5].dds = "RdKGroupTool/Art/Crowns/Pfeilgelb.dds"
RdKGToolCrown.config.crowns[6] = {}
RdKGToolCrown.config.crowns[6].dds = "RdKGroupTool/Art/Crowns/Pfeilhellgruen.dds"
RdKGToolCrown.config.crowns[7] = {}
RdKGToolCrown.config.crowns[7].dds = "RdKGroupTool/Art/Crowns/Pfeilrot.dds"
RdKGToolCrown.config.crowns[8] = {}
RdKGToolCrown.config.crowns[8].dds = "RdKGroupTool/Art/Crowns/Pfeilpink.dds"
RdKGToolCrown.config.crowns[9] = {}
RdKGToolCrown.config.crowns[9].dds = "RdKGroupTool/Art/Crowns/Krone.dds"
RdKGToolCrown.config.crowns[10] = {}
RdKGToolCrown.config.crowns[10].dds = "RdKGroupTool/Art/Crowns/RdKWhite.dds"

RdKGToolCrown.state = {}

function RdKGToolCrown.Initialize()
	RdKGTool.profile.AddProfileChangeListener(RdKGToolCrown.callbackName, RdKGToolCrown.OnProfileChanged)
	
	
	local bodyText= RdKGToolChat.GetBodyColorHex()
	if QAddon ~= nil and QAddon.name == "PapaCrown" then
		RdKGToolChat.SendChatMessage(RdKGToolCrown.constants.PAPA_CROWN_DETECTED, RdKGToolCrown.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_WARNING)
		return
	end
	if RO ~= nil and RO.name == "SanctsUltimateOrganiser" then
		RdKGToolChat.SendChatMessage(RdKGToolCrown.constants.SANCTS_ULTIMATE_ORGANIZER_DETECTED, RdKGToolCrown.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_WARNING)
		return
	end
	if CrownOfCyrodiil ~= nil and CrownOfCyrodiil.name == "CrownOfCyrodiil" then
		RdKGToolChat.SendChatMessage(RdKGToolCrown.constants.CROWN_OF_CYRODIIL_DETECTED, RdKGToolCrown.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_WARNING)
		return
	end
	if RdKGToolCrown.crownVars.enabled then
		EVENT_MANAGER:RegisterForEvent(RdKGToolCrown.callbackName, EVENT_PLAYER_ACTIVATED, RdKGToolCrown.OnPlayerActivated)
	end
end


function RdKGToolCrown.OnPlayerActivated()
	--d("OnPlayerActivated")
	--/script SetFloatingMarkerInfo(MAP_PIN_TYPE_GROUP_LEADER, 64, "RdKGroupTool/Art/Crowns/Pfeilpink.dds")
	if RdKGToolCrown.crownVars.enabled and (RdKGToolCrown.crownVars.pvponly == false or (RdKGToolCrown.crownVars.pvponly == true and RdKGToolUtil.IsInPvPArea() == true)) then
		if RdKGToolCrown.crownVars.selectedMode == 1 then
			if RdKGToolCrown.crownVars.customDDS == true then
				SetFloatingMarkerInfo(MAP_PIN_TYPE_GROUP_LEADER, RdKGToolCrown.crownVars.size, RdKGToolCrown.crownVars.customDDSPath--[[, "EsoUI/Art/Comapss/groupleader_door.dds"]])
			else
				SetFloatingMarkerInfo(MAP_PIN_TYPE_GROUP_LEADER, RdKGToolCrown.crownVars.size, RdKGToolCrown.config.crowns[RdKGToolCrown.crownVars.selectedCrown].dds --[[, "EsoUI/Art/Comapss/groupleader_door.dds"]])
			end
		end
	else
		SetFloatingMarkerInfo(MAP_PIN_TYPE_GROUP_LEADER)
	end
end

function RdKGToolCrown.GetDefaults()
	local defaults = {}
	defaults.customDDS = false
	defaults.enabled = false
	defaults.size = 64
	defaults.pvponly = false
	defaults.selectedMode = 1
	defaults.selectedCrown = 1
	defaults.customDDSPath = "RdKGroupTool/Art/Crowns/pfeil_pink.dds"
	return defaults
end

function RdKGToolCrown.SlashCmd(param)

end

--profile synchronization
function RdKGToolCrown.OnProfileChanged(currentProfile)
	--d(currentProfile)
	if currentProfile ~= nil then
		RdKGToolCrown.crownVars = currentProfile.group.crown
	end
end

--Menu Interaction
function RdKGToolCrown.GetMenu()
	local menu = {
		[1] = {
			type = "submenu",
			name = RdKGToolMenu.constants.CROWN_HEADER,
			--width = "full",
			--requiresReload = true
			controls = {

				[1] = {
					type = "description",
					title = nil,
					text = RdKGToolMenu.constants.CROWN_WARNING,
					width = "full"
				},
				[2] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.CROWN_CHK_GROUP_CROWN_ENABLED,
					getFunc = RdKGToolCrown.GetGroupCrownState,
					setFunc = RdKGToolCrown.SetGroupCrownState,
					--requiresReload = true
				},
				[3] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.CROWN_PVP_ONLY,
					getFunc = RdKGToolCrown.GetCrownPvpOnly,
					setFunc = RdKGToolCrown.SetCrownPvpOnly,
					--requiresReload = true
				},
				[4] = {
					type = "dropdown",
					name = RdKGToolMenu.constants.CROWN_SELECTED_MODE,
					choices = RdKGToolCrown.GetAvailableCrownModes(),
					getFunc = RdKGToolCrown.GetSelectedCrownMode,
					setFunc = RdKGToolCrown.SetSelectedCrownMode,
					width = "full",
					--requiresReload = true
				},
				[5] = {
					type = "dropdown",
					name = RdKGToolMenu.constants.CROWN_SELECTED_CROWN,
					choices = RdKGToolCrown.GetAvailableCrowns(),
					getFunc = RdKGToolCrown.GetSelectedCrown,
					setFunc = RdKGToolCrown.SetSelectedCrown,
					width = "full",
					--requiresReload = true
				},
				[6] = {
					type = "slider",
					name = RdKGToolMenu.constants.CROWN_SIZE,
					min = 10,
					max = 512,
					step = 1,
					getFunc = RdKGToolCrown.GetCrownSize,
					setFunc = RdKGToolCrown.SetCrownSize,
					width = "full",
					default = 64,
					--requiresReload = true
				}
			}
		}
	}
	return menu
end

function RdKGToolCrown.GetGroupCrownState()
	return RdKGToolCrown.crownVars.enabled
end

function RdKGToolCrown.SetGroupCrownState(value)
	RdKGToolCrown.crownVars.enabled = value
	RdKGToolCrown.OnPlayerActivated()
end


function RdKGToolCrown.GetAvailableCrownModes()
	local modes = { RdKGTool.menu.constants.CROWN_MODE[1] }
	return modes
end

function RdKGToolCrown.GetSelectedCrownMode()
	return RdKGTool.menu.constants.CROWN_MODE[RdKGToolCrown.crownVars.selectedMode]
end

function RdKGToolCrown.SetSelectedCrownMode(value)
	for i = 1, #RdKGTool.menu.constants.CROWN_MODE do
		if RdKGTool.menu.constants.CROWN_MODE[i] == value then
			RdKGToolCrown.crownVars.selectedMode = i
			break
		end
	end
	RdKGToolCrown.OnPlayerActivated()
end

function RdKGToolCrown.GetAvailableCrowns()
	--ugly bug fix cause through menu entry in libaddonmenu... wtf?
	if RdKGToolCrown.crownVars == nil then
		RdKGToolCrown.crownVars = RdKGTool.profile.GetSelectedProfile().group.crown
	end
	if RdKGToolCrown.crownVars.selectedMode == 1 then
		local crowns = { RdKGToolCrown.config.crowns[1].name, 
						 RdKGToolCrown.config.crowns[2].name,
						 RdKGToolCrown.config.crowns[3].name,
						 RdKGToolCrown.config.crowns[4].name,
						 RdKGToolCrown.config.crowns[5].name,
						 RdKGToolCrown.config.crowns[6].name,
						 RdKGToolCrown.config.crowns[7].name,
						 RdKGToolCrown.config.crowns[8].name,
						 RdKGToolCrown.config.crowns[9].name,
						 RdKGToolCrown.config.crowns[10].name
		}
		return crowns
	else
		RdKGToolChat.SendChatMessage("Invalid Crown Mode", RdKGToolCrown.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_DEBUG)
	end
end

function RdKGToolCrown.GetSelectedCrown()
	return RdKGToolCrown.config.crowns[RdKGToolCrown.crownVars.selectedCrown].name
end

function RdKGToolCrown.SetSelectedCrown(value)
	for i = 1, #RdKGToolCrown.config.crowns do
		if RdKGToolCrown.config.crowns[i].name == value then
			RdKGToolCrown.crownVars.selectedCrown = i
			break
		end
	end
	RdKGToolCrown.OnPlayerActivated()
end

function RdKGToolCrown.GetCrownSize()
	return RdKGToolCrown.crownVars.size
end

function RdKGToolCrown.SetCrownSize(value)
	RdKGToolCrown.crownVars.size = value
	RdKGToolCrown.OnPlayerActivated()
end

function RdKGToolCrown.GetCrownPvpOnly()
	return RdKGToolCrown.crownVars.pvponly
end

function RdKGToolCrown.SetCrownPvpOnly(value)
	RdKGToolCrown.crownVars.pvponly = value
	RdKGToolCrown.OnPlayerActivated()
end
