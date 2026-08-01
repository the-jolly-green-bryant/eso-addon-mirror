LibAkaUtils = LibAkaUtils or {}
LibAkaUtils.ticking = false

local TYPE_STOPWATCH = 0
local TYPE_TIMER = 1

function LibAkaUtils.RegisterTicker()
	if LibAkaUtils.ticking == true then return end
	EVENT_MANAGER:RegisterForUpdate(LibAkaUtils.name.."Ticker", 1000, LibAkaUtils.Tick)
	LibAkaUtils.ticking = true
end

function LibAkaUtils.UnregisterTicker()
	if LibAkaUtils.ticking == false then return end
	EVENT_MANAGER:UnregisterForUpdate(LibAkaUtils.name.."Ticker")
	LibAkaUtils.ticking = false
end

function LibAkaUtils.Tick()
	local size = 0
	table.foreach(LibAkaUtils.watches, function(id, data)
		if data == nil then return end
		if data.finished == true then return end
		local time = os.time()
		local tickData = 0
		if data.type == TYPE_TIMER then
			if data.time <= time then
				data.onDone()
				LibAkaUtils.watches[id].finished = true
				return
			end
			tickData = data.time - time
		else
			tickData = time - data.time
		end
		size = size + 1
		if data.onTick == nil then return end
		data.onTick(tickData)
	end)
	if size == 0 then
		LibAkaUtils.UnregisterTicker()
	end
end

function LibAkaUtils.InsertTimer(type, time, onTick, onDone)
	LibAkaUtils.RegisterTicker()
	local id = LibAkaUtils.uuid()
	LibAkaUtils.watches[id] = {
		type = type,
		time = time,
		onTick = onTick,
		finished = false
	}
	if onDone ~= nil then
		LibAkaUtils.watches[id].onDone = onDone
	end
	return id
end

function LibAkaUtils.Timer(endTime, onTick, onDone)
	return LibAkaUtils.InsertTimer(TYPE_TIMER, endTime, onTick, onDone)
end

function LibAkaUtils.StartStopwatch(onTick)
	return LibAkaUtils.InsertTimer(TYPE_STOPWATCH, os.time(), onTick)
end

function LibAkaUtils.StopById(id)
	if id == nil then return nil end
	if LibAkaUtils.watches[id] == nil then return nil end
	if LibAkaUtils.watches[id].finished == true then return LibAkaUtils.watches[id] end
	LibAkaUtils.watches[id].finished = true
	return LibAkaUtils.watches[id]
end

function LibAkaUtils.StopAllWatches()
	table.foreach(LibAkaUtils.watches, function(id)
		LibAkaUtils.StopById(id)
	end)
end

function LibAkaUtils.GetStopwatch(id)
	if id == nil then return nil end
	if LibAkaUtils.watches[id] == nil then return nil end
	if LibAkaUtils.watches[id].finished == true then return 0 end
	return os.time() - LibAkaUtils.watches[id].time
end

function LibAkaUtils.FormatSecondsToHMS(seconds)
	if seconds == nil then return 0,0,0 end
	local s = seconds % 60
	local m = ((seconds - s) / 60) % 60
	local h = (((seconds - s) / 60) - m) / 60
	return h,m,s
end

function LibAkaUtils.FormatSecondsToHMSString(seconds)
	if seconds == nil then return "" end
	local h,m,s = LibAkaUtils.FormatSecondsToHMS(seconds)
	return h.."h "..m.."m "..s.."s"
end

function LibAkaUtils.hmsStringToSeconds(str)
	return LibAkaUtils.GetValue(str,"s") + LibAkaUtils.GetValue(str,"m") * 60 + LibAkaUtils.GetValue(str,"h") * 3600
end

function LibAkaUtils.GetValue(str, unitChar)
	local out = "0"
	string.replace(str, "([0-9]+)"..unitChar, function (value)
		out = value
		return ""
	end)
	return tonumber(out)
end