local min, floor = math.min, math.floor

local BankedCurrencyAnimation = {}

function BankedCurrencyAnimation.New(duration, cb, eventNamespace)
    local self = setmetatable({}, { __index = BankedCurrencyAnimation })

    self.startAmount = nil
    self.endAmount = nil
    self.startTime = nil
    self.endTime = nil

    self.playing = false
    self.duration = duration

    self.eventNamespace = eventNamespace
    self.cb = cb

    return self
end

function BankedCurrencyAnimation:Update()
    local currentTime = GetGameTimeMilliseconds()

    local elapsed = currentTime - self.startTime
    local progress = min(elapsed / self.duration, 1)

    local eased = 1 - (1 - progress)^3
    -- local eased = 1 - 2^(-10 * progress)

    local easedAmount = floor(self.startAmount + (self.endAmount - self.startAmount) * eased)

    self.cb(easedAmount)

    if progress >= 1 then
        EVENT_MANAGER:UnregisterForUpdate(self.eventNamespace)
        self.playing = false
    end
end

function BankedCurrencyAnimation:Start(startAmount, endAmount)
    self.startTime, self.startAmount, self.endAmount = GetGameTimeMilliseconds(), startAmount, endAmount

    if not self.playing then
        self.playing = true
        EVENT_MANAGER:RegisterForUpdate(self.eventNamespace, 16, function() self:Update() end)
    end
end

IMP_BankedCurrencyAnimation = BankedCurrencyAnimation
