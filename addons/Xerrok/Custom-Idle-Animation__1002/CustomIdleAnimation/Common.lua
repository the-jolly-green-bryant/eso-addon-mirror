math.randomseed(os.time())

function class(base, init)
	local c = {}
	if not init and type(base) == 'function' then
		init = base
		base = nil
	elseif type(base) == 'table' then
		for i,v in pairs(base) do
			c[i] = v
		end
		c._base = base
	end
	c.__index = c

	local mt = {}
	mt.__call = function(class_tbl, ...)
		local obj = {}
		setmetatable(obj,c)
		if init then
			init(obj,...)
		else
			if base and base.init then
				base.init(obj, ...)
			end
		end
		return obj
	end
	c.init = init
	c.is_a = function(self, klass)
		local m = getmetatable(self)
		while m do 
			if m == klass then return true end
			m = m._base
		end
		return false
	end
	setmetatable(c, mt)
	return c
end

function Random(number)
	local number = number * math.random()
	if number - math.floor(number) < 0.5 then
		return math.floor(number)
	else
		return math.ceil(number)
	end
end

function Length(t)
	local count = 0
	for _ in pairs(t) do count = count + 1 end
	return count
end

function FindIndex(t, e)
	for k, v in pairs(t) do
		if (v == e) then
			return k
		end
	end
end

function IsBusy()
	return not ArePlayerWeaponsSheathed() or
		(IsGameCameraUIModeActive() and DoesGameHaveFocus()) or
		IsPlayerMoving() or
		IsPlayerTryingToMove() or
		IsInteracting() or
		IsPlayerInteractingWithObject() or
		IsPlayerStunned() or
		IsInteractionPending() or
		GetInteractionType() ~= 0 or
		IsUnitInCombat("player") or
		GetUnitStealthState("player") ~= 0 or
		IsUnitSwimming("player") or
		IsMounted() or
		IsBlockActive() or
		IsUnitDeadOrReincarnating("player") or
		IsLooting()
end