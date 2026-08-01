-- RdK Group Tool Campaign Joiner
-- By @s0rdrak (PC / EU)

RdKGTool.toolbox = RdKGTool.toolbox or {}
local RdKGToolTB = RdKGTool.toolbox
RdKGTool.toolbox.caj = RdKGTool.toolbox.caj or {}
local RdKGToolCaj = RdKGTool.toolbox.caj
RdKGTool.menu = RdKGTool.menu or {}
local RdKGToolMenu = RdKGTool.menu

RdKGToolCaj.callbackName = RdKGTool.addonName .. "ToolboxCampaignJoiner"

RdKGToolCaj.constants = {}

RdKGToolCaj.state = {}
RdKGToolCaj.state.initialized = false
RdKGToolCaj.state.registredConsumers = false

RdKGToolCaj.config = {}
RdKGToolCaj.config.joinDelay = 5000

function RdKGToolCaj.Initialize()
	RdKGTool.profile.AddProfileChangeListener(RdKGToolCaj.callbackName, RdKGToolCaj.OnProfileChanged)

	
	RdKGToolCaj.state.initialized = true
	RdKGToolCaj.SetEnabled(RdKGToolCaj.cajVars.enabled)
end

function RdKGToolCaj.GetDefaults()
	local defaults = {}
	defaults.enabled = false
	return defaults
end

function RdKGToolCaj.SetEnabled(value)
	if RdKGToolCaj.state.initialized == true and value ~= nil then
		RdKGToolCaj.cajVars.enabled = value
		if value == true then
			if RdKGToolCaj.state.registredConsumers == false then
				EVENT_MANAGER:RegisterForEvent(RdKGToolCaj.callbackName, EVENT_CAMPAIGN_QUEUE_STATE_CHANGED, RdKGToolCaj.OnCampaignQueueStateChanged)
			end
			RdKGToolCaj.state.registredConsumers = true
		else
			if RdKGToolCaj.state.registredConsumers == true then
				EVENT_MANAGER:UnregisterForEvent(RdKGToolCaj.callbackName, EVENT_CAMPAIGN_QUEUE_STATE_CHANGED)
			end
			RdKGToolCaj.state.registredConsumers = false
		end
	end
end

--callbacks
function RdKGToolCaj.OnProfileChanged(currentProfile)
	if currentProfile ~= nil then
		RdKGToolCaj.cajVars = currentProfile.toolbox.caj
		if RdKGToolCaj.state.initialized == true then
	
		end
	end
end

function RdKGToolCaj.OnCampaignQueueStateChanged(eventId, campaignId, isGroup, state)
	if state == CAMPAIGN_QUEUE_REQUEST_STATE_CONFIRMING then
		zo_callLater(function() ConfirmCampaignEntry(campaignId, isGroup, true) end, RdKGToolCaj.config.joinDelay)
		
	end 
end

--menu interaction
function RdKGToolCaj.GetMenu()
	local menu = {
		[1] = {
			type = "submenu",
			name = RdKGToolMenu.constants.CAJ_HEADER,
			controls = {
				[1] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.CAJ_ENABLED,
					getFunc = RdKGToolCaj.GetCajEnabled,
					setFunc = RdKGToolCaj.SetCajEnabled
				}
			}
		},
	}
	return menu
end

function RdKGToolCaj.GetCajEnabled()
	return RdKGToolCaj.cajVars.enabled
end

function RdKGToolCaj.SetCajEnabled(value)
	RdKGToolCaj.SetEnabled(value)
end