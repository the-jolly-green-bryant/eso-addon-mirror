-- CCTrackerFloats.lua
-- Handles UI elements for CC effects in CCTracker
CCTracker = CCTracker or {}

-- Define the icon grid layout (3 columns, up to 4 rows)
local iconGrid = {
    ["Charm"] = {col=1, row=1},
    ["Disoriented"] = {col=1, row=2},
    ["Fear"] = {col=1, row=3},
    ["Knockback"] = {col=1, row=4},
    ["Levitating"] = {col=2, row=1},
    ["Offbalance"] = {col=2, row=2},
    ["Root"] = {col=2, row=3},
    ["Silence"] = {col=2, row=4},
    ["Snare"] = {col=3, row=1},
    ["Stagger"] = {col=3, row=2},
    ["Stun"] = {col=3, row=3},
}

-- Helper functions
function CCTracker:CropZOSString(str)
    if not str then return "" end
    str = tostring(str)
    str = string.gsub(str, "%^.*", "")
    return str
end

function CCTracker:AbilityInList(aId, list)
    for i, entry in ipairs(list) do
        if entry.id == aId then return true, i end
    end
    return false, 0
end

function CCTracker:SnareRootCheck(aId, num, aName)
    if self.ccActive[num].type == "root" then
        table.insert(self.couldBeRoot, aId)
    elseif self.ccActive[num].type == 10 then
        table.insert(self.couldJustBeSnare, aId)
    end
end

function CCTracker:ClearSubeffects(aId, time)
    for _, entry in ipairs(self.ccActive) do
        if entry.isSubeffect and entry.id == aId then
            entry.endTime = time
        end
    end
end

function CCTracker:ClearCCThatIsNotBuff()
    self.ccActive = {}
    self:CCChanged()
end

function CCTracker:ClearAllCC()
    self.ccActive = {}
    self:CCChanged()
end

function CCTracker:PrintIgnoreLink(aName, aId)
end

function CCTracker:IsRoot(aId)
    return self.constants.possibleRoots[aId] or self.constants.definiteRoots[aId]
end

function CCTracker:DoesBreakFreeWork()
    return true
end

function CCTracker:RolldodgeDetected()
    self.status.immunityToImmobilization = true
end

function CCTracker:BreakFreeDetected()
    self:ClearAllCC()
end

-- Initialize XML-based UI elements
function CCTracker:InitializeFloatingIndicators()
    self.floatingIndicators = self.floatingIndicators or {}
    self.container = _G["CCTrackerContainer"]
    if not self.container then
        return
    end
    self.container:SetDrawLayer(DL_OVERLAY)
    self.container:SetDrawTier(DT_HIGH)
    self.container:SetDrawLevel(10000)
    self.container:SetAlpha(1.0)
    self.container:SetInheritAlpha(false)
    self.container:SetClampedToScreen(true)
    self.container:SetHidden(false)
    self.container:SetMouseEnabled(false)

    for _, entry in pairs(self.ccVariables) do
        local name = entry.name
        local controlName = "CCTrackerContainer_" .. name .. "_Indicator"
        local control = _G[controlName]
        if control then
            control:SetDrawLayer(DL_OVERLAY)
            control:SetDrawTier(DT_HIGH)
            control:SetDrawLevel(10001)
            control:SetAlpha(1.0)
            control:SetInheritAlpha(false)
            control:SetClampedToScreen(true)
            control:SetHidden(true)
            self.floatingIndicators[name] = { control = control, type = "texture" }
        else
            self.floatingIndicators[name] = { fallback = true, name = name }
        end
    end
    self:UpdateIconPositions()
end

-- Update icon positions and sizes based on settings
function CCTracker:UpdateIconPositions()
    local SV = CCTrackerSettings and CCTrackerSettings.savedVars or { baseX = 500, baseY = 520, iconScale = 1.0 }
    local baseX = SV.baseX or 500
    local baseY = SV.baseY or 520
    local scale = SV.iconScale or 1.0
    local spacingX = 100
    local spacingY = 90

    if not self.container or not self.floatingIndicators then
        return
    end

    for name, data in pairs(self.floatingIndicators) do
        local gridPos = iconGrid[name]
        if gridPos and data.control then
            local col = gridPos.col
            local row = gridPos.row
            local xOffset = baseX + (col - 1) * spacingX
            local yOffset = baseY + (row - 1) * spacingY
            data.control:SetDimensions(80 * scale, 80 * scale)
            data.control:ClearAnchors()
            data.control:SetAnchor(TOPLEFT, self.container, TOPLEFT, xOffset, yOffset)
        end
    end
end

-- Update UI elements
function CCTracker:UpdateFloatingIndicators()
    for name, data in pairs(self.floatingIndicators) do
        if not data.fallback then
            data.control:SetHidden(true)
        end
    end
    for _, entry in ipairs(self.ccActive) do
        local name = self.ccVariables[entry.type].name
        if self.floatingIndicators[name] and not self.floatingIndicators[name].fallback then
            self.floatingIndicators[name].control:SetHidden(false)
        end
    end
end

-- CCChanged: Updates UI when CC states change
function CCTracker:CCChanged(playSound)
    if playSound then
    end
    self:UpdateFloatingIndicators()
end

-- Initialize on addon load
EVENT_MANAGER:RegisterForEvent("CCTrackerFloatsInit", EVENT_ADD_ON_LOADED, function(eventCode, addOnName)
    if addOnName == "CCTracker" then
        zo_callLater(function()
            CCTracker:InitializeFloatingIndicators()
        end, 5000)
    end
end)
