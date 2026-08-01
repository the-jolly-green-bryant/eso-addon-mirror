local sqrt = math.sqrt

local meter = {}
meter.__index = meter

function meter.New(capacity)
    local self = setmetatable({}, meter)

    self.capacity = capacity or 1000
    self.stages = {}          -- [stage] = { values = {…} }
    self.results = nil

    return self
end

function meter:AddMeasurement(stage, duration)
    -- Safety check: ignore non‑numeric durations
    if type(duration) ~= "number" then return end

    local s = self.stages[stage]
    if not s then
        s = { values = {} }
        self.stages[stage] = s
    end
    local v = s.values
    v[#v + 1] = duration

    while #v > self.capacity do
        table.remove(v, 1)
    end
end

function meter:Calculate()
    local results = {}
    for stage, s in pairs(self.stages) do
        local values = s.values
        local n = #values
        if n == 0 then
            results[stage] = { avg = 0, std = 0, min = 0, max = 0, unit = "us" }
        else
            local sum, sumSq, minV, maxV = 0, 0, math.huge, -math.huge
            for i = 1, n do
                local v = values[i]

                sum = sum + v
                sumSq = sumSq + v * v
                if v < minV then minV = v end
                if v > maxV then maxV = v end
            end
            local avg = sum / n
            local variance = (n > 1) and (sumSq - n * avg * avg) / (n - 1) or 0
            local std = sqrt(variance)

            local scale, unit
            if avg < 1e-4 then
                scale, unit = 1e6, "us"
            elseif avg < 0.1 then
                scale, unit = 1e3, "ms"
            else
                scale, unit = 1, "s"
            end

            results[stage] = {
                avg = avg * scale,
                std = std * scale,
                min = minV * scale,
                max = maxV * scale,
                unit = unit,
            }
        end
    end
    self.results = results
    return results
end


PerformanceMeter = meter
