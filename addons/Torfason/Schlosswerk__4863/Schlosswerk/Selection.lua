local SW = Schlosswerk

function SW:SanitizeSettings()
    local db = self.db
    if not db then
        return
    end


    if db.selectionMode ~= "fixed" and db.selectionMode ~= "random" then
        db.selectionMode = self.defaultSettings.selectionMode
    end

    if not self:IsValidStyle(db.fixedStyle) then
        db.fixedStyle = self.defaultSettings.fixedStyle
    end

    if type(db.pinLights) ~= "boolean" then
        db.pinLights = self.defaultSettings.pinLights
    end

    if type(db.avoidImmediateRepeat) ~= "boolean" then
        db.avoidImmediateRepeat = self.defaultSettings.avoidImmediateRepeat
    end

    if type(db.randomPool) ~= "table" then
        db.randomPool = {}
    end

    for _, styleId in ipairs(self.styleOrder) do
        if type(db.randomPool[styleId]) ~= "boolean" then
            db.randomPool[styleId] = self.defaultSettings.randomPool[styleId] == true
        end
    end

    if db.lastRandomStyle ~= nil and not self:IsValidStyle(db.lastRandomStyle) then
        db.lastRandomStyle = nil
    end
end

function SW:GetRandomCandidates()
    local candidates = {}
    for _, styleId in ipairs(self.styleOrder) do
        if self.db.randomPool[styleId] then
            candidates[#candidates + 1] = styleId
        end
    end

    if #candidates == 0 then
        candidates[1] = "original"
    end

    return candidates
end

function SW:ChooseRandomStyle()
    local candidates = self:GetRandomCandidates()

    if self.db.avoidImmediateRepeat and #candidates > 1 and self.db.lastRandomStyle then
        local filtered = {}
        for _, styleId in ipairs(candidates) do
            if styleId ~= self.db.lastRandomStyle then
                filtered[#filtered + 1] = styleId
            end
        end
        if #filtered > 0 then
            candidates = filtered
        end
    end

    local selected = candidates[math.random(1, #candidates)]
    self.db.lastRandomStyle = selected
    return selected
end

function SW:ChooseStyleForAttempt()
    if self.db.selectionMode == "random" then
        return self:ChooseRandomStyle()
    end

    if self:IsValidStyle(self.db.fixedStyle) then
        return self.db.fixedStyle
    end

    return "original"
end

function SW:OnBeginLockpick()
    local styleId = self:ChooseStyleForAttempt()
    self:ApplyStyle(styleId)

    if zo_callLater then
        zo_callLater(function()
            SW:ApplyStyle(styleId)
            SW:ApplyPinLighting()
        end, 0)
    else
        self:ApplyPinLighting()
    end
end
