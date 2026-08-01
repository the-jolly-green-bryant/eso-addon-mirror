local TributeWinrateStats = {}
TributeWinrateStats.__index = TributeWinrateStats

function TributeWinrateStats.New()
    local instance = setmetatable({}, TributeWinrateStats)

    instance:Clear()

    return instance
end

function TributeWinrateStats:Clear()
    self.totalGames = 0

    self.totalFP = 0
    self.totalSP = 0

    self.totalWonFP = 0
    self.totalLostFP = 0

    self.totalWonSP = 0
    self.totalLostSP = 0

    self.lastProceededIndex = -1
end

function TributeWinrateStats:AddGame(index, data)
    if index <= self.lastProceededIndex then return end
    self.lastProceededIndex = index

    self.totalGames = self.totalGames + 1

    if data.win then
        if data.fp then
            self.totalWonFP = self.totalWonFP + 1
            self.totalFP = self.totalFP + 1
        else
            self.totalWonSP = self.totalWonSP + 1
            self.totalSP = self.totalSP + 1
        end
    else
        if data.fp then
            self.totalLostFP = self.totalLostFP + 1
            self.totalFP = self.totalFP + 1
        else
            self.totalLostSP = self.totalLostSP + 1
            self.totalSP = self.totalSP + 1
        end
    end
end

function TributeWinrateStats:GetWinrate()
    local totalWinrate = (self.totalWonFP + self.totalWonSP) / self.totalGames
    local FPWinrate = self.totalWonFP / self.totalFP
    local SPWinrate = self.totalWonSP / self.totalSP

    return totalWinrate, FPWinrate, SPWinrate
end

-- ----------------------------------------------------------------------------

local TributeStatsManager = {}
TributeStatsManager.__index = TributeStatsManager

function TributeStatsManager.New()
    local instance = setmetatable({}, TributeStatsManager)

    instance.totalStats = TributeWinrateStats.New()
    instance.opponentStats = {}

    instance.highestRank = 100000

    return instance
end

function TributeStatsManager:AddGame(index, data)
    local rank = data.player.atEnd.rank
    if rank ~= 0 then
        if rank < self.highestRank then
            self.highestRank = rank
        end
    end

    self.totalStats:AddGame(index, data)

    if not self.opponentStats[data.opponent.name] then
        self.opponentStats[data.opponent.name] = TributeWinrateStats.New()
    end

    self.opponentStats[data.opponent.name]:AddGame(index, data)
end

function TributeStatsManager:Clear()
    self.totalStats:Clear()
end

function TributeStatsManager:GetTotalStats()
    return self.totalStats.totalGames, self.totalStats:GetWinrate()
end

function TributeStatsManager:GetStatsVS(name)
    if not self.opponentStats[name] then return end
    return self.opponentStats[name].totalGames, self.opponentStats[name]:GetWinrate()
end

-- ----------------------------------------------------------------------------

IMP_STATS_TRIBUTE_STATS_MANAGER = TributeStatsManager.New()