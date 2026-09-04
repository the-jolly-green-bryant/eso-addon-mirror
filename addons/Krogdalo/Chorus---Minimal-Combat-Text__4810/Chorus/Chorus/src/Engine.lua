local Engine = Chorus.Engine
local F = Chorus.Format

Engine.DEFAULTS = {
    window = 20000, minSamples = 8, history = 200, coalesce = 120,
    fadeIn = 80, dwell = 900, dwellWeight = 600, critDwell = 250, fadeOut = 300,
    maxVisible = 7, nameThreshold = 0.9,
    summaryMin = 5000, summaryDwell = 4000,
}

local Instance = {}
Instance.__index = Instance

function Engine.New(opts)
    local self = setmetatable({}, Instance)
    self.opts = {}
    for k, v in pairs(Engine.DEFAULTS) do self.opts[k] = v end
    for k, v in pairs(opts or {}) do self.opts[k] = v end
    self:Clear()
    self.samples = {}
    self.history = {}
    self.fight = nil
    self.summary = nil
    return self
end

function Instance:Configure(opts) for k, v in pairs(opts or {}) do self.opts[k] = v end end

function Instance:Clear()
    self.entries = {}
    self.slots = {}
end

local function prune(self, now)
    local s, cutoff = self.samples, now - self.opts.window
    local i = 1
    while s[i] and s[i].t < cutoff do i = i + 1 end
    if i > 1 then
        local kept = {}
        for j = i, #s do kept[#kept + 1] = s[j] end
        self.samples = kept
    end
end

local function rank(amount, list, get)
    local below = 0
    for _, x in ipairs(list) do if get(x) < amount then below = below + 1 end end
    return below / #list
end

local function weightOf(self, amount)
    local min = self.opts.minSamples
    if #self.samples >= min then return rank(amount, self.samples, function(x) return x.amount end) end
    if #self.history >= min then return rank(amount, self.history, function(x) return x end) end
    return 0.5
end

local function dwellOf(self, entry)
    local d = self.opts.dwell + self.opts.dwellWeight * entry.weight
    if entry.crit then d = d + self.opts.critDwell end
    return d
end

local function refresh(self, entry, now)
    entry.weight = weightOf(self, entry.amount)
    entry.dwell = dwellOf(self, entry)
    entry.updated = now
end

local function fightHit(self, now, hit)
    if hit.kind == "heal" then return end
    if not self.fight then self.fight = { start = now, total = 0, byName = {} } end
    local f = self.fight
    f.total = f.total + hit.amount
    f.byName[hit.name] = (f.byName[hit.name] or 0) + hit.amount
    f.last = now
end

function Instance:CombatState(now, inCombat)
    if inCombat then
        if not self.fight then self.fight = { start = now, total = 0, byName = {} } end
        return
    end
    local f = self.fight
    self.fight = nil
    if not f or f.total == 0 then return end
    local duration = now - f.start
    if duration < self.opts.summaryMin then return end
    local topName, topAmount = nil, 0
    for name, amount in pairs(f.byName) do
        if amount > topAmount then topName, topAmount = name, amount end
    end
    self.summary = { at = now, duration = duration, dps = math.floor(f.total / (duration / 1000) + 0.5),
        total = f.total, top = { name = topName, share = topAmount / f.total } }
end

local function placeHit(self, now, hit)

    local key = hit.kind .. ":" .. tostring(hit.id)
    if hit.tick then
        local slot = self.slots[key]
        if slot and slot.alive then
            slot.amount = hit.amount
            slot.crit = hit.crit == true
            slot.count = 1
            refresh(self, slot, now)
            return slot
        end
    else

        for i = #self.entries, 1, -1 do
            local e = self.entries[i]
            if e.key == key and not e.tick and now - e.updated <= self.opts.coalesce then
                e.amount = e.amount + hit.amount
                e.count = e.count + 1
                e.crit = e.crit or hit.crit == true
                refresh(self, e, now)
                return e
            end
            if now - e.spawn > self.opts.coalesce then break end
        end
    end

    local entry = { key = key, id = hit.id, name = hit.name, kind = hit.kind, amount = hit.amount,
        crit = hit.crit == true, tick = hit.tick == true, count = 1, spawn = now, alive = true }
    refresh(self, entry, now)
    self.entries[#self.entries + 1] = entry
    if hit.tick then self.slots[key] = entry end
    while #self.entries > self.opts.maxVisible do
        table.remove(self.entries, 1).alive = false
    end
    return entry
end

function Instance:Hit(now, hit)
    hit.kind = hit.kind or "damage"
    prune(self, now)
    fightHit(self, now, hit)
    local entry = placeHit(self, now, hit)
    self.samples[#self.samples + 1] = { t = now, amount = hit.amount }
    self.history[#self.history + 1] = hit.amount
    if #self.history > self.opts.history then table.remove(self.history, 1) end
    return entry
end

local function alphaOf(self, e, now)
    local o = self.opts
    local sinceSpawn, sinceUpdate = now - e.spawn, now - e.updated
    local a = 1
    if o.fadeIn > 0 and sinceSpawn < o.fadeIn then a = sinceSpawn / o.fadeIn end
    if sinceUpdate > e.dwell then
        if o.fadeOut <= 0 then return nil end
        local f = (sinceUpdate - e.dwell) / o.fadeOut
        if f >= 1 then return nil end
        a = math.min(a, 1 - f)
    end
    return a
end

function Instance:Tick(now)
    local out, kept = {}, {}
    for _, e in ipairs(self.entries) do
        local a = alphaOf(self, e, now)
        if a then kept[#kept + 1] = e else e.alive = false end
    end
    self.entries = kept
    for i = #kept, 1, -1 do
        local e = kept[i]
        out[#out + 1] = {
            text = F.Amount(e.amount), name = e.name, kind = e.kind, amount = e.amount,
            weight = e.weight, crit = e.crit, count = e.count, tick = e.tick,
            alpha = a, age = now - e.updated, dwell = e.dwell,
            showName = e.weight >= self.opts.nameThreshold,
            index = #out + 1,
        }
        out[#out].alpha = alphaOf(self, e, now)
    end
    local summary
    if self.summary then
        local age = now - self.summary.at
        if age < self.opts.summaryDwell then
            summary = { duration = self.summary.duration, dps = self.summary.dps, total = self.summary.total,
                top = self.summary.top, age = age }
        else
            self.summary = nil
        end
    end
    return { entries = out, summary = summary }
end
