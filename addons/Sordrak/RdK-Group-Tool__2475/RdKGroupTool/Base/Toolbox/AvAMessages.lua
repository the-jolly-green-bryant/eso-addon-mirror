-- RdK Group Tool AvA Messages
-- By @s0rdrak (PC / EU)

RdKGTool.toolbox = RdKGTool.toolbox or {}
local RdKGToolTB = RdKGTool.toolbox
RdKGTool.toolbox.am = RdKGTool.toolbox.am or {}
local RdKGToolAM = RdKGTool.toolbox.am
RdKGTool.menu = RdKGTool.menu or {}
local RdKGToolMenu = RdKGTool.menu
RdKGTool.util = RdKGTool.util or {}
local RdKGToolUtil = RdKGTool.util


RdKGToolAM.callbackName = RdKGTool.addonName .. "ToolboxAvAMessages"

RdKGToolAM.constants = {}
RdKGToolAM.constants.events = {}
RdKGToolAM.constants.events.CORONATE_EMPEROR = 1
RdKGToolAM.constants.events.DEPOSE_EMPEROR = 2
RdKGToolAM.constants.events.KEEP_GATE = 3
RdKGToolAM.constants.events.ARTIFACT_CONTROL = 4
RdKGToolAM.constants.events.REVENGE_KILL = 5
RdKGToolAM.constants.events.AVENGE_KILL = 6
RdKGToolAM.constants.events.QUEST_ADDED = 7
RdKGToolAM.constants.events.QUEST_COMPLETE = 8
RdKGToolAM.constants.events.QUEST_CONDITION_COUNTER_CHANGED = 9
RdKGToolAM.constants.events.DAEDRIC_ARTIFACT_OBJECTIVE_SPAWNED_BUT_NOT_REVEALED = 10
RdKGToolAM.constants.events.DAEDRIC_ARTIFACT_OBJECTIVE_STATE_CHANGED = 11

RdKGToolAM.state = {}
RdKGToolAM.state.initialized = false
RdKGToolAM.state.events = {}
RdKGToolAM.state.events[RdKGToolAM.constants.events.CORONATE_EMPEROR] = EVENT_CORONATE_EMPEROR_NOTIFICATION
RdKGToolAM.state.events[RdKGToolAM.constants.events.DEPOSE_EMPEROR] = EVENT_DEPOSE_EMPEROR_NOTIFICATION
RdKGToolAM.state.events[RdKGToolAM.constants.events.KEEP_GATE] = EVENT_KEEP_GATE_STATE_CHANGED
RdKGToolAM.state.events[RdKGToolAM.constants.events.ARTIFACT_CONTROL] = EVENT_ARTIFACT_CONTROL_STATE
RdKGToolAM.state.events[RdKGToolAM.constants.events.REVENGE_KILL] = EVENT_REVENGE_KILL
RdKGToolAM.state.events[RdKGToolAM.constants.events.AVENGE_KILL] = EVENT_AVENGE_KILL
RdKGToolAM.state.events[RdKGToolAM.constants.events.QUEST_ADDED] = EVENT_QUEST_ADDED
RdKGToolAM.state.events[RdKGToolAM.constants.events.QUEST_COMPLETE] = EVENT_QUEST_COMPLETE
RdKGToolAM.state.events[RdKGToolAM.constants.events.QUEST_CONDITION_COUNTER_CHANGED] = EVENT_QUEST_CONDITION_COUNTER_CHANGED
RdKGToolAM.state.events[RdKGToolAM.constants.events.DAEDRIC_ARTIFACT_OBJECTIVE_SPAWNED_BUT_NOT_REVEALED] = EVENT_DAEDRIC_ARTIFACT_OBJECTIVE_SPAWNED_BUT_NOT_REVEALED
RdKGToolAM.state.events[RdKGToolAM.constants.events.DAEDRIC_ARTIFACT_OBJECTIVE_STATE_CHANGED] = EVENT_DAEDRIC_ARTIFACT_OBJECTIVE_STATE_CHANGED

function RdKGToolAM.Initialize()
	RdKGTool.profile.AddProfileChangeListener(RdKGToolAM.callbackName, RdKGToolAM.OnProfileChanged)

	RdKGToolAM.HookMessages()
	
	RdKGToolAM.state.initialized = true
end

function RdKGToolAM.GetDefaults()
	local defaults = {}
	defaults.pvpOnly = true
	defaults.events = {}
	defaults.events[RdKGToolAM.constants.events.CORONATE_EMPEROR] = true
	defaults.events[RdKGToolAM.constants.events.DEPOSE_EMPEROR] = true
	defaults.events[RdKGToolAM.constants.events.KEEP_GATE] = true
	defaults.events[RdKGToolAM.constants.events.ARTIFACT_CONTROL] = true
	defaults.events[RdKGToolAM.constants.events.REVENGE_KILL] = true
	defaults.events[RdKGToolAM.constants.events.AVENGE_KILL] = true
	defaults.events[RdKGToolAM.constants.events.QUEST_ADDED] = true
	defaults.events[RdKGToolAM.constants.events.QUEST_COMPLETE] = true
	defaults.events[RdKGToolAM.constants.events.QUEST_CONDITION_COUNTER_CHANGED] = true
	defaults.events[RdKGToolAM.constants.events.DAEDRIC_ARTIFACT_OBJECTIVE_SPAWNED_BUT_NOT_REVEALED] = true
	defaults.events[RdKGToolAM.constants.events.DAEDRIC_ARTIFACT_OBJECTIVE_STATE_CHANGED] = true
	
	defaults.questProgress = true
	return defaults
end

function RdKGToolAM.HookMessages()
	for i = 1, #RdKGToolAM.state.events do
		RdKGToolUtil.AddConditionalPreHook(RdKGToolAM.callbackName .. RdKGToolAM.state.events[i], ZO_CenterScreenAnnounce_GetEventHandlers(), RdKGToolAM.state.events[i], function(...) return RdKGToolAM.MessageHook(RdKGToolAM.state.events[i], ...) end, nil)
	end
	
	RdKGToolUtil.AddConditionalPreHook(RdKGToolAM.callbackName .. ".AddMessageWithParamsHook", CENTER_SCREEN_ANNOUNCE, "AddMessageWithParams", RdKGToolAM.AddMessageWithParamsHook, nil)
	--for i = 125000, 140000 do
	--	if i ~= 131279 then
	--		RdKGToolUtil.AddConditionalPreHook(RdKGToolAM.callbackName .. i, ZO_CenterScreenAnnounce_GetEventHandlers(), i, function(...) return RdKGToolAM.MessageHook(i, ...) end, nil)
	--	end
	--end
end

function RdKGToolAM.MessageHook(event, ...)
	--d(event)
	if RdKGToolAM.amVars.pvpOnly == false or (RdKGToolAM.amVars.pvpOnly == true and RdKGToolUtil.IsInPvPArea() == true) then
		for i = 1, #RdKGToolAM.state.events do
			if RdKGToolAM.state.events[i] == event then
				--d(RdKGToolAM.amVars.events[i])
				return RdKGToolAM.amVars.events[i]
			end
		end
	end
	return true
end

function RdKGToolAM.AddMessageWithParamsHook(object, message)
	--d(message)
	if RdKGToolAM.amVars.pvpOnly == false or (RdKGToolAM.amVars.pvpOnly == true and RdKGToolUtil.IsInPvPArea() == true) then
		if message ~= nil and message.csaType == CENTER_SCREEN_ANNOUNCE_TYPE_QUEST_PROGRESSION_CHANGED then
			return RdKGToolAM.amVars.questProgress
		end
	end
	return true
end

--callbacks
function RdKGToolAM.OnProfileChanged(currentProfile)
	if currentProfile ~= nil then
		RdKGToolAM.amVars = currentProfile.toolbox.am
		if RdKGToolAM.state.initialized == true then
			
		end
	end
end

--menu interaction
function RdKGToolAM.GetMenu()
	local menu = {
		[1] = {
			type = "submenu",
			name = RdKGToolMenu.constants.AM_HEADER,
			controls = {
				[1] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.AM_PVP_ONLY,
					getFunc = RdKGToolAM.GetAmPvpOnly,
					setFunc = RdKGToolAM.SetAmPvpOnly
				},
				[2] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.AM_CORONATE_EMPEROR,
					getFunc = function() return RdKGToolAM.GetAmVarEnabled(RdKGToolAM.constants.events.CORONATE_EMPEROR) end,
					setFunc = function(value) RdKGToolAM.SetAmVarEnabled(RdKGToolAM.constants.events.CORONATE_EMPEROR, value) end
				},
				[3] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.AM_DEPOSE_EMPEROR,
					getFunc = function() return RdKGToolAM.GetAmVarEnabled(RdKGToolAM.constants.events.DEPOSE_EMPEROR) end,
					setFunc = function(value) RdKGToolAM.SetAmVarEnabled(RdKGToolAM.constants.events.DEPOSE_EMPEROR, value) end
				},
				[4] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.AM_KEEP_GATE,
					getFunc = function() return RdKGToolAM.GetAmVarEnabled(RdKGToolAM.constants.events.KEEP_GATE) end,
					setFunc = function(value) RdKGToolAM.SetAmVarEnabled(RdKGToolAM.constants.events.KEEP_GATE, value) end
				},
				[5] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.AM_ARTIFACT_CONTROL,
					getFunc = function() return RdKGToolAM.GetAmVarEnabled(RdKGToolAM.constants.events.ARTIFACT_CONTROL) end,
					setFunc = function(value) RdKGToolAM.SetAmVarEnabled(RdKGToolAM.constants.events.ARTIFACT_CONTROL, value) end
				},
				[6] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.AM_REVENGE_KILL,
					getFunc = function() return RdKGToolAM.GetAmVarEnabled(RdKGToolAM.constants.events.REVENGE_KILL) end,
					setFunc = function(value) RdKGToolAM.SetAmVarEnabled(RdKGToolAM.constants.events.REVENGE_KILL, value) end
				},
				[7] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.AM_AVENGE_KILL,
					getFunc = function() return RdKGToolAM.GetAmVarEnabled(RdKGToolAM.constants.events.AVENGE_KILL) end,
					setFunc = function(value) RdKGToolAM.SetAmVarEnabled(RdKGToolAM.constants.events.AVENGE_KILL, value) end
				},
				[8] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.AM_QUEST_ADDED,
					getFunc = function() return RdKGToolAM.GetAmVarEnabled(RdKGToolAM.constants.events.QUEST_ADDED) end,
					setFunc = function(value) RdKGToolAM.SetAmVarEnabled(RdKGToolAM.constants.events.QUEST_ADDED, value) end
				},
				[9] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.AM_QUEST_COMPLETE,
					getFunc = function() return RdKGToolAM.GetAmVarEnabled(RdKGToolAM.constants.events.QUEST_COMPLETE) end,
					setFunc = function(value) RdKGToolAM.SetAmVarEnabled(RdKGToolAM.constants.events.QUEST_COMPLETE, value) end
				},
				[10] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.AM_QUEST_CONDITION_COUNTER_CHANGED,
					getFunc = function() return RdKGToolAM.GetAmVarEnabled(RdKGToolAM.constants.events.QUEST_CONDITION_COUNTER_CHANGED) end,
					setFunc = function(value) RdKGToolAM.SetAmVarEnabled(RdKGToolAM.constants.events.QUEST_CONDITION_COUNTER_CHANGED, value) end
				},
				[11] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.AM_QUEST_CONDITION_CHANGED,
					getFunc = RdKGToolAM.GetAmQuestConditionChanged,
					setFunc = RdKGToolAM.SetAmQuestConditionChanged
				},
				[12] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.AM_DAEDRIC_ARTIFACT_OBJECTIVE_SPAWNED_BUT_NOT_REVEALED,
					getFunc = function() return RdKGToolAM.GetAmVarEnabled(RdKGToolAM.constants.events.DAEDRIC_ARTIFACT_OBJECTIVE_SPAWNED_BUT_NOT_REVEALED) end,
					setFunc = function(value) RdKGToolAM.SetAmVarEnabled(RdKGToolAM.constants.events.DAEDRIC_ARTIFACT_OBJECTIVE_SPAWNED_BUT_NOT_REVEALED, value) end
				},
				[13] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.AM_DAEDRIC_ARTIFACT_OBJECTIVE_STATE_CHANGED,
					getFunc = function() return RdKGToolAM.GetAmVarEnabled(RdKGToolAM.constants.events.DAEDRIC_ARTIFACT_OBJECTIVE_STATE_CHANGED) end,
					setFunc = function(value) RdKGToolAM.SetAmVarEnabled(RdKGToolAM.constants.events.DAEDRIC_ARTIFACT_OBJECTIVE_STATE_CHANGED, value) end
				},
			}
		}
	}
	return menu
end

function RdKGToolAM.GetAmPvpOnly()
	return RdKGToolAM.amVars.pvpOnly
end

function RdKGToolAM.SetAmPvpOnly(value)
	RdKGToolAM.amVars.pvpOnly = value
end

function RdKGToolAM.GetAmVarEnabled(index)
	return RdKGToolAM.amVars.events[index]
end

function RdKGToolAM.SetAmVarEnabled(index, value)
	RdKGToolAM.amVars.events[index] = value
end

function RdKGToolAM.GetAmQuestConditionChanged()
	return RdKGToolAM.amVars.questProgress
end

function RdKGToolAM.SetAmQuestConditionChanged(value)
	RdKGToolAM.amVars.questProgress = value
end