local DEBUG =
-- function() end
d

if not InventoryManager then InventoryManager = {} end
local IM = InventoryManager

local _Pending = nil
local _Delay = nil

-- function _Loop_fn(entry)
local _Loop_fn = nil

-- function _Finish_fn(finished_ok)
local _Finish_fn = nil

local _Event_Next = nil
local _Event_Abort = nil
local _Event_Filter_fn = nil

-- Simple processing loop, call next element after delay
local function ProcessLoop()
	if not _Pending or #_Pending == 0 then
		if _Finish_fn then _Finish_fn(true) end
		return
	end

	local entry = _Pending[#_Pending]
	_Pending[#_Pending] = nil
	_Loop_fn(entry)
	
	zo_callLater(ProcessLoop, _Delay)
end

-- Event driven processing loop, called directly for first element,
-- then is fired by _Loop_fn's completion for the subsequent ones.
local function EventProcessLoop(eventCode, a1, a2, a3, a4, a5, a6, a7, a8)
	-- Bail out if this event is not meant for us.
	if _Event_Filter_fn then
		if not _Event_Filter_fn(eventCode, a1, a2, a3, a4, a5, a6, a7, a8) then return end
	end
	
	if not _Pending or #_Pending == 0 then
		if _Event_Next then
			EVENT_MANAGER:UnregisterForEvent("IMEventProcessLoop", _Event_Next)
		end
		if _Event_Abort then
			EVENT_MANAGER:UnregisterForEvent("IMEventProcessLoop", _Event_Abort)
		end
		
		if _Finish_fn then _Finish_fn(true, eventCode, a1, a2, a3, a4, a5, a6, a7, a8) end
		return
	end

	local entry = _Pending[#_Pending]
	_Pending[#_Pending] = nil

	zo_callLater(function() _Loop_fn(entry, eventCode, a1, a2, a3, a4, a5, a6, a7, a8) end, _Delay)
end

local function EventProcessLoopAbort()
	if _Event_Next then
		EVENT_MANAGER:UnregisterForEvent("IMEventProcessLoop", _Event_Next)
	end
	if _Event_Abort then
		EVENT_MANAGER:UnregisterForEvent("IMEventProcessLoop", _Event_Abort)
	end

	if _Finish_fn then _Finish_fn(false) end
end

function IM:DoEventProcessing(list, loop_fn, finish_fn, loop_event, abort_event, run_delay, event_filter_fn)
	_Pending = list
	_Loop_fn = loop_fn
	_Finish_fn = finish_fn
	_Delay = run_delay or 1
	_Event_Next = loop_event
	_Event_Abort = abort_event
	_Event_Filter_fn = event_filter_fn
	
	if _Event_Next then
		EVENT_MANAGER:RegisterForEvent("IMEventProcessLoop", _Event_Next, EventProcessLoop)
	end
	if _Event_Abort then
		EVENT_MANAGER:RegisterForEvent("IMEventProcessLoop", _Event_Abort, EventProcessLoopAbort)
	end
	
	zo_callLater(function() EventProcessLoop() end, _Delay)
end

function IM:DoDelayedProcessing(list, loop_fn, finish_fn, run_delay, init_delay)
	_Pending = list
	_Loop_fn = loop_fn
	_Finish_fn = finish_fn
	_Delay = run_delay or 1

	local _Init_Delay = init_delay or _Delay
	
	zo_callLater(ProcessLoop, _Init_Delay)
end

function IM:CreateInventoryList(bagId, action, filter_fn, list)
	self:SetCurrentInventory(bagId)
	if not list then list = { }
	else
		for i = 1, #list / 2, 1 do
			local tmp = list[i]
			list[i] = list[(#list+1) - i]
			list[(#list+1) - i] = tmp
		end
	end
	
	for i,_ in pairs(self.currentInventory) do
		if #list > 90 then break end
		local data = self:GetItemData(i)
		data.action, data.index, data.text = self.currentRuleset:Match(data, action)

		if ((not action) or data.action == action) and filter_fn(data) then
			list[#list + 1] = data
		end
	end

	for i = 1, #list / 2, 1 do
		local tmp = list[i]
		list[i] = list[(#list+1) - i]
		list[(#list+1) - i] = tmp
	end

	return list
end

function IM:ProcessBag(bagId, action, filter_fn, loop_fn, finish_fn, run_delay, init_delay)
	local list = IM:CreateInventoryList(bagId, action, filter_fn)
	
	self:DoDelayedProcessing(list, loop_fn, finish_fn, run_delay, init_delay)
end

function IM:EventProcessBag(bagId, action, filter_fn, loop_fn, finish_fn, loop_event, abort_event, run_delay, event_filter_fn)
	local list = IM:CreateInventoryList(bagId, action, filter_fn)
	
	self:DoEventProcessing(list, loop_fn, finish_fn, loop_event, abort_event, run_delay, event_filter_fn)
end

function IM:AbortProcessing()
	_Pending = nil
end
