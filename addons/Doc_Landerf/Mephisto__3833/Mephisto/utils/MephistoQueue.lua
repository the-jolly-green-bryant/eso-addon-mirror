Mephisto = Mephisto or {}
local MP = Mephisto

MP.queue = {}
local MPQ = MP.queue
MPQ.list = { first = 0, last = -1 }
local MPL = MPQ.list

function MPQ.Init()
	MPQ.name = MP.name .. "Queue"
	MPQ.queueRunning = false
	EVENT_MANAGER:RegisterForEvent( MPQ.name, EVENT_PLAYER_COMBAT_STATE, MPQ.StartQueue )
	EVENT_MANAGER:RegisterForEvent( MPQ.name, EVENT_PLAYER_REINCARNATED, MPQ.StartQueue ) -- no longer ghost
	EVENT_MANAGER:RegisterForEvent( MPQ.name, EVENT_PLAYER_ALIVE, MPQ.StartQueue )     -- revive at wayshrine
end

function MPQ.Run()
	if MPQ.queueRunning then
		return
	end

	MPQ.queueRunning = true
	while MPQ.Size() > 0
		and not IsUnitInCombat( "player" )
		and not IsUnitDeadOrReincarnating( "player" ) do
		local task = MPQ.Pop()
		task()
	end
	MPQ.queueRunning = false
end

function MPQ.Push( task, delay )
	if delay and delay > 0 then
		local delayedFunction = function()
			zo_callLater( task, delay )
		end
		MPQ.Push( delayedFunction )
		return
	end

	local last = MPL.last + 1
	MPL.last = last
	MPL[ last ] = task

	MPQ.Run()
end

function MPQ.Pop()
	if MPQ.Size() < 1 then return nil end
	local first = MPL.first
	local task = MPL[ first ]
	MPL[ first ] = nil
	MPL.first = first + 1
	return task
end

function MPQ.Size()
	return MPL.last - MPL.first + 1
end

function MPQ.Reset()
	MPL = { first = 0, last = -1 }
end

function MPQ.StartQueue()
	zo_callLater( function()
					  if MPQ.Size() > 0 and not IsUnitInCombat( "player" ) then
						  MPQ.Run()
					  end
				  end, 800 )
end
