TamrielRaces = TamrielRaces or {}
local TR = TamrielRaces

TR.State = TR.State or {}
local State = TR.State

function State:ResetTransient()
    self.route = {}
    self.currentIndex = 0
    self.running = false
    self.waitingAtStart = false
    self.startReady = false
    self.startTimeMs = nil
    self.splitTimes = {}
    self.lastResult = nil

    self.currentZoneName = nil
    self.currentZoneIndex = nil
    self.raceMapId = nil

    self.routeCreated = false
    self.routeInvalid = false

    self.countdownActive = false
    self.countdownEndsMs = nil
    self.preRaceMapCountdown = false
    self.preRaceMapEndsMs = nil

    self.transitionGraceActive = false
    self.transitionGraceEndsMs = nil
    self.fastTravelInteractionPending = false
    self.fastTravelInteractionStartedMs = nil
    self.fastTravelInteractionEndedMs = nil
    self.fastTravelViolation = false
    self.fastTravelViolationReason = nil
    self.fastTravelViolationConfirmedMs = nil

    self.gauntletActive = false
    self.gauntletEntryName = nil
    self.gauntletExitName = nil
    self.raceDifficulty = nil
    self.raceDifficultyName = nil
    self.raceMount = nil
    self.raceModeId = "point_to_point"
    self.raceModeName = "Point-to-Point"
    self.raceTypeId = "wayshrine_route"
    self.raceTypeName = "Wayshrine Route"
    self.raceStartedTimestamp = nil

    self.lastInteractableName = nil
    self.finalCheckpointReady = false
    self.finalCheckpointReadyMs = nil
    self.focusModeActive = false
    self.mapFilterSnapshot = nil
end

function State:Initialize()
    self:ResetTransient()
    self.initialized = true
end

function State:IsRaceActive()
    return self.running or self.countdownActive or self.waitingAtStart
end
