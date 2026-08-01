LibAkaUtils = LibAkaUtils or {}

function LibAkaUtils.FireEvent(event, ...)
	if event == nil then return end
	local packed = table.pack(...)
	if LibAkaUtils.listeners[event] == nil then return end
	table.foreach(LibAkaUtils.listeners[event], function(_,func)
		func(unpack(packed))
	end)
end

function LibAkaUtils.AddListener(event, name, func)
	if event == nil then return end
	if name == nil then return end
	if func == nil then return end
	if LibAkaUtils.listeners[event] == nil then 
		LibAkaUtils.listeners[event] = {}
	end
	if LibAkaUtils.listeners[event][name] ~= nil then
		d("LibAkaUtils Error - Duplicate Event Listener: "..name)
		return
	end
	LibAkaUtils.listeners[event][name] = func
end

function LibAkaUtils.RemoveListener(event, name)
	if event == nil then return end
	if name == nil then return end
	if LibAkaUtils.listeners[event] == nil then return end
	LibAkaUtils.listeners[event][name] = nil
end

function LibAkaUtils.GetNumEventListeners(event)
	if event == nil then return 0 end
	if LibAkaUtils.listeners[event] == nil then return 0 end
	return table.getListSizeFilterNil(LibAkaUtils.listeners[event])
end