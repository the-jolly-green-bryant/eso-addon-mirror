SugasTestZoneBBTCadence = SugasTestZoneBBTCadence or {}
local Project = SugasTestZoneBBTCadence

Project.State = Project.State or {}
local State = Project.State

local function NewBar()
    local bar = {}
    for slot = Project.Config.firstSlot, Project.Config.lastSlot do
        bar[slot] = {
            slot = slot,
            id = 0,
            name = "",
            icon = "",
            durationMs = 0,
            endTimeMs = 0,
            active = false,
            alerted = false,
            source = "",
        }
    end
    return bar
end

function State:Reset()
    self.bars = {
        [HOTBAR_CATEGORY_PRIMARY] = NewBar(),
        [HOTBAR_CATEGORY_BACKUP] = NewBar(),
    }
    self.pending = {}
    self.inCombat = false
    self.blockWasActive = false
    self.blockCadenceStartedMs = nil
    self.lightCadenceStartedMs = nil
    self.blockLastPulse = -1
    self.lightLastPulse = -1
    self.blockPulseUntilMs = 0
    self.lightPulseUntilMs = 0
    self.clusterAlerted = {}
end

function State:GetRecord(hotbar, slot)
    local bar = self.bars and self.bars[hotbar]
    return bar and bar[slot] or nil
end

function State:ClearCadence()
    self.blockWasActive = false
    self.blockCadenceStartedMs = nil
    self.lightCadenceStartedMs = nil
    self.blockLastPulse = -1
    self.lightLastPulse = -1
    self.blockPulseUntilMs = 0
    self.lightPulseUntilMs = 0
end

