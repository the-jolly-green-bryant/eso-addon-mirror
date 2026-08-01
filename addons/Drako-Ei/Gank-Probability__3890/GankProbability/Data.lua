local GP = GankProbability
local LNN = LibNeuralNetworks
local internal = GP.internal

function internal.initializeModel()
    local model = GP.savedVars.predictionModels[GP.savedVars.activeModel]
    internal.model = model
    internal.neuralNetwork = LNN.MultilayerPerceptron.new(model.structure, model.activation)
    internal.neuralNetwork:deserialize(model.weights)
end

function internal.registerGankAttempt(player, success)

    if not GP.savedVars.dataCollection then return end

    local maxStoragePerClass = GP.savedVars.maxStoragePerClass
    local gankList = GP.savedVars.gankAttempts[player.class]
    player.result = success and 1 or 0

    if #gankList >= maxStoragePerClass then
        local index = math.random(1, #gankList)
        gankList[index] = player
    else
        table.insert(gankList, player)
    end

end

function internal.inputMapper(target)
    return {
        target.class == 1 and 1 or 0,
        target.class == 2 and 1 or 0,
        target.class == 3 and 1 or 0,
        target.class == 4 and 1 or 0,
        target.class == 5 and 1 or 0,
        target.class == 6 and 1 or 0,
        target.class == 117 and 1 or 0,
        target.race == 1 and 1 or 0,
        target.race == 2 and 1 or 0,
        target.race == 3 and 1 or 0,
        target.race == 4 and 1 or 0,
        target.race == 5 and 1 or 0,
        target.race == 6 and 1 or 0,
        target.race == 7 and 1 or 0,
        target.race == 8 and 1 or 0,
        target.race == 9 and 1 or 0,
        target.race == 10 and 1 or 0,
        target.level == 50 and 1 or 0,
        target.cp/3600,
        target.maxHealth/100000
    }
end

function internal.outputMapper(outputs)
    local total = outputs[1] + outputs[2]
    return outputs[1] / total * 100
end

function internal.getGankProbability(player)
    local input = internal.inputMapper(player)
    local output = internal.neuralNetwork:predict(input)
    return internal.outputMapper(output)
end

function internal.getTargettedPlayer(unit)
    local currentHealth, maxHealth = GetUnitPower(unit, POWERTYPE_HEALTH)
    local rank, subRank = GetUnitAvARank(unit)
    return {
        name = GetUnitName(unit),
        class = GetUnitClassId(unit),
        race = GetUnitRaceId(unit),
        level = GetUnitLevel(unit),
        gender = GetUnitGender(unit),
        cp = GetUnitChampionPoints(unit),
        alliance = GetUnitAlliance(unit),
        currentHealth = currentHealth,
        maxHealth = maxHealth,
        isInCombat = IsUnitInCombat(unit) and 1 or 0,
        isStealthed = GetUnitStealthState(unit) and 1 or 0,
        pvpPoints = GetUnitAvARankPoints(unit),
        pvpRank = rank,
        pvpSubRank = subRank,
        result = nil
    }
end