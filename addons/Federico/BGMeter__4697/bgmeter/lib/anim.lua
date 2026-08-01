
BGMeter = BGMeter or {}
local BGMeter = BGMeter

local Anim = {}
local EM = EVENT_MANAGER
local UPDATE_NAME = "BGMeterAnim"

local active = {}
local running = false

local function now()
    return BGMeter.zenimax.api.now_ms()
end

local function ease_out_cubic(t)
    local u = 1 - t
    return 1 - u * u * u
end

local function tick()
    local t_now = now()
    for i = #active, 1, -1 do
        local a = active[i]
        local raw = (a.dur > 0) and ((t_now - a.start) / a.dur) or 1
        if raw < 0 then raw = 0 elseif raw > 1 then raw = 1 end
        local eased = a.ease(raw)
        pcall(a.on_update, eased)
        if raw >= 1 then
            if a.on_done then pcall(a.on_done) end
            table.remove(active, i)
        end
    end
    if #active == 0 and running then
        EM:UnregisterForUpdate(UPDATE_NAME)
        running = false
    end
end

function Anim.start(duration_ms, on_update, on_done, ease)
    active[#active + 1] = {
        start = now(), dur = duration_ms or 300,
        on_update = on_update, on_done = on_done,
        ease = ease or ease_out_cubic,
    }
    if not running then
        EM:RegisterForUpdate(UPDATE_NAME, 0, tick)
        running = true
    end
end

function Anim.value(from, to, duration_ms, setter, on_done)
    Anim.start(duration_ms, function(t)
        setter(from + (to - from) * t)
    end, on_done)
end

function Anim.clear()
    for i = #active, 1, -1 do active[i] = nil end
    if running then
        EM:UnregisterForUpdate(UPDATE_NAME)
        running = false
    end
end

BGMeter.Anim = Anim
