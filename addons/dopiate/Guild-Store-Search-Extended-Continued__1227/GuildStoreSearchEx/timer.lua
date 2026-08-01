-- Author      : LintyDruid
-- Timer Array


local function add(name, millisecs, callback, maxevents)
	if (name==nil) then name="tempTimerLD"..GetGameTimeMilliseconds() end
	
	if (ld_timers[name]== nil) then ld_timers[name]={} end
	
	ld_timers[name].lastevent=GetGameTimeMilliseconds()
	ld_timers[name].millisecs=millisecs
	ld_timers[name].count=0
	ld_timers[name].callback=callback
	ld_timers[name].maxevents=maxevents
	ld_timers[name].params=nil
end

local function addWithData(name, millisecs, callback, maxevents,data)

	if ld_timers == nil then
		ld_timers={}
	end
		
	if (ld_timers[name]== nil) then ld_timers[name]={} end
	
	ld_timers[name].lastevent=GetGameTimeMilliseconds()
	ld_timers[name].millisecs=millisecs
	ld_timers[name].count=0
	ld_timers[name].callback=callback
	ld_timers[name].maxevents=maxevents
	ld_timers[name].params=data

end

local function exists(name)

	if (ld_timers[name]== nil) then 
		return false
	else
		return true
	end
	

end

local function start()

	ld_timer.tick()

end

local function tick()

	
	
	 if ld_timer.start~=start then  --- no longer using this version
		--d("timer disabled");
		return -- Kill call backs for this version
	end
	
	
	for name,tmr in pairs(ld_timers) do
		--d("tick: "..name)
		if ld_timers[name].maxevents~=-2 then -- not disabled
			if ld_timers[name].lastevent+ld_timers[name].millisecs<GetGameTimeMilliseconds() then
			
				if ld_timers[name].maxevents>0 then -- only track count if is not infinite
					ld_timers[name].count=ld_timers[name].count+1
				end
			
				if ld_timers[name].maxevents>0 and ld_timers[name].count>=ld_timers[name].maxevents then
					ld_timers[name].maxevents=-2 -- Disable
				end
				
				ld_timers[name].lastevent=GetGameTimeMilliseconds()
				
				if (ld_timers[name].params~=nil) then
					ld_timers[name].callback(name,ld_timers[name].params)
				else
					ld_timers[name].callback(name)
				end
			
			end
						
		end
	
	end
	
	zo_callLater(ld_timer.tick, 500) -- run again in 500 ms

end

------ Create/update object


if ld_timers == nil then
	ld_timers={}
end

local ldTimer_ver=0.3

-- Manage alternate versions

if ld_timer==nil or ld_timer.ver<ldTimer_ver then -- new version overwrite but preserve any data save call backs
	--	ld_timer=nil
		if ld_timer==nil then ld_timer={} end
		
		
		ld_timer.start=start;
		ld_timer.addWithData=addWithData;
		ld_timer.add=add;
		ld_timer.tick=tick;
		ld_timer.stop=stop;
		ld_timer.exists=exists;
		ld_timer.ver=ldTimer_ver;
		ld_timer.start();
		
else
	return --- better version do not overwrite
end

