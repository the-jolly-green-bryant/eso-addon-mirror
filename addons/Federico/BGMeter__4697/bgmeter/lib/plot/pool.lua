
BGMeter = BGMeter or {}
local BGMeter = BGMeter
BGMeter.Plot = BGMeter.Plot or {}

local Pool = {}
Pool.__index = Pool

function Pool.new(factory_fn, reset_fn)
    local self = setmetatable({}, Pool)
    self.zo = BGMeter.zenimax.ui.new_pool(function(p)
        return factory_fn(p)
    end, reset_fn)
    return self
end

function Pool:acquire()
    local obj, key = self.zo:AcquireObject()
    return obj, key
end

function Pool:release_all()
    self.zo:ReleaseAllObjects()
end

function Pool:release(key)
    self.zo:ReleaseObject(key)
end

function Pool:active_count()
    return self.zo:GetActiveObjectCount()
end

BGMeter.Plot.pool = Pool
