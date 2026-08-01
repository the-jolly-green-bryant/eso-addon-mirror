local lib = LibNeuralNetworks
local math = lib.math

-- Multilayer perceptron class
local MultilayerPerceptron = {}
MultilayerPerceptron.__index = MultilayerPerceptron

-- Constructor, it takes an array of integers representing the number of neurons in each layer
function MultilayerPerceptron.new(structureArray, compactFunctions)
    assert(type(structureArray) == "table", "structureArray must be a table")
    assert(#structureArray > 1, "structureArray must have at least 2 elements")
    local self = setmetatable({}, MultilayerPerceptron)
    self.structureArray = structureArray
    self.weights = {}
    self.biases = {}
    self.numberInputs = structureArray[1]
    self.numberOutputs = structureArray[#structureArray]

    -- Initialize compact functions
    if type(compactFunctions) == "table" then
        self.compactFunctions = compactFunctions
    elseif type(compactFunctions) == "string" then
        if compactFunctions == "sigmoid" then
            self.compactFunctions = {math.sigmoid, math.deltaSigmoid, math.randomNormal}
        elseif compactFunctions == "relu" then
            self.compactFunctions = {math.leakyRelu, math.leakyDeltaRelu, function() return math.heRandom(self.numberInputs, self.numberOutputs) end}
        else
            error("compactFunctions must be either 'sigmoid' or 'relu'")
        end
    else
        error("compactFunctions must be a table or a string")
    end

    -- Initialize weights
    for i = 1, #structureArray - 1 do
        assert(structureArray[i] > 0, "structureArray must contain only positive numbers")
        self.weights[i] = math.randomMatrix(structureArray[i + 1], structureArray[i], self.compactFunctions[3])
        self.biases[i] = math.randomVector(structureArray[i + 1], self.compactFunctions[3])
    end

    return self
end

-- Randomize the weights and biases between 0 and 1
function MultilayerPerceptron:randomize()
    for i = 1, #self.structureArray - 1 do
        self.weights[i] = math.randomMatrix(self.structureArray[i + 1], self.structureArray[i], self.compactFunctions[3])
        self.biases[i] = math.randomVector(self.structureArray[i + 1], self.compactFunctions[3])
    end
end

-- Get the weights
function MultilayerPerceptron:getWeights()
    return self.weights
end

-- Get the biases
function MultilayerPerceptron:getBiases()
    return self.biases
end

-- Set the weights
function MultilayerPerceptron:setWeights(weights)
    assert(type(weights) == "table", "weights must be a table")
    assert(#weights == #self.weights, "weights must have the same number of elements as the number of layers")

    for i = 1, #weights do
        assert(#weights[i] == #self.weights[i], "weights must have the same number of elements as the number of neurons in the layer")
        for j = 1, #weights[i] do
            assert(#weights[i][j] == #self.weights[i][j], "weights must have the same number of elements as the number of neurons in the previous layer")
            for k = 1, #weights[i][j] do
                self.weights[i][j][k] = weights[i][j][k]
            end
        end
    end
end

-- Set the biases
function MultilayerPerceptron:setBiases(biases)
    assert(type(biases) == "table", "biases must be a table")
    assert(#biases == #self.biases, "biases must have the same number of elements as the number of layers")

    for i = 1, #biases do
        assert(#biases[i] == #self.biases[i], "biases must have the same number of elements as the number of neurons in the layer")
        for j = 1, #biases[i] do
            self.biases[i][j] = biases[i][j]
        end
    end
end

-- Serialize current model to an array
function MultilayerPerceptron:serialize()
    local serialized = {#self.structureArray}
    for i = 1, #self.structureArray do
        table.insert(serialized, self.structureArray[i])
    end

    for i = 1, #self.weights do
        for j = 1, #self.weights[i] do
            for k = 1, #self.weights[i][j] do
                table.insert(serialized, self.weights[i][j][k])
            end
        end
    end

    for i = 1, #self.biases do
        for j = 1, #self.biases[i] do
            table.insert(serialized, self.biases[i][j])
        end
    end

    return serialized
end

-- Load a model from a serialized array
function MultilayerPerceptron:deserialize(serialized)

    assert(type(serialized) == "table", "serialized must be a table")

    -- Expected size is 1 plus the ammount of elements in the structure Array plus the ammount of elements in the weights plus the ammount of elements in the biases
    local expectedSize = 1 + #self.structureArray
    
    -- Add the number of biases which is the sum of the elements in the structureArray except the first one
    for i = 2, #self.structureArray do
        expectedSize = expectedSize + self.structureArray[i]
        expectedSize = expectedSize + self.structureArray[i - 1] * self.structureArray[i]
    end

    assert(#serialized == expectedSize, "serialized must have the correct size " .. expectedSize .. " but has " .. #serialized .. " elements")

    local index = 1
    local numLayers = serialized[index]
    index = index + 1
    for i = 1, numLayers do
        assert(self.structureArray[i] == serialized[index], "structureArray must have the same number of elements as the input layer")
        index = index + 1
    end

    for i = 1, #self.weights do
        for j = 1, #self.weights[i] do
            for k = 1, #self.weights[i][j] do
                self.weights[i][j][k] = serialized[index]
                index = index + 1
            end
        end
    end

    for i = 1, #self.biases do
        for j = 1, #self.biases[i] do
            self.biases[i][j] = serialized[index]
            index = index + 1
        end
    end

    return self
end

-- Get the mean squared error of the model
function MultilayerPerceptron:getMeanSquaredError(inputs, targets)
    assert(type(inputs) == "table", "inputs must be a table")
    assert(type(targets) == "table", "targets must be a table")
    assert(#inputs == #targets, "inputs and targets must have the same number of elements")

    local err = 0
    for i = 1, #inputs do
        local prediction = self:predict(inputs[i])
        local diff = math.subtractVectors(prediction, targets[i])
        err = err + math.dotProduct(diff, diff)
    end

    return err / #inputs
end

-- Train the model
function MultilayerPerceptron:train(inputs, targets, learningRate)
    assert(type(inputs) == "table", "inputs must be a table")
    assert(type(targets) == "table", "targets must be a table")
    assert(type(learningRate) == "number", "learningRate must be a number")
    assert(#inputs == #targets, "inputs and targets must have the same number of elements")

    local gradients = {}

    for i = 1, #inputs do
        local gradient = self:calculateGradient(inputs[i], targets[i])
        table.insert(gradients, gradient)
    end

    local avgGradient = math.averageVectors(gradients)
    self:gradientDescent(avgGradient, learningRate)
end

-- Make a prediction
function MultilayerPerceptron:feedForward(inputs)
    assert(type(inputs) == "table", "inputs must be a table")
    assert(#inputs == self.structureArray[1], "inputs must have the same number of elements as the input layer")

    local outputs = {}
    local weightedSums = {}
    outputs[1] = inputs
    weightedSums[1] = inputs
    for i = 1, #self.weights do
        weightedSums[i+1] = math.addVectors(math.multiplyMatrixByVector(self.weights[i], outputs[i]), self.biases[i])
        outputs[i+1] = math.mapVector(weightedSums[i+1], self.compactFunctions[1])
    end

    return outputs, weightedSums
end

function MultilayerPerceptron:predict(inputs)
    return self:feedForward(inputs)[#self.structureArray]
end

-- Gradient descent
function MultilayerPerceptron:gradientDescent(gradient, learningRate)

    assert(type(gradient) == "table", "gradient must be a table")
    assert(type(learningRate) == "number", "learningRate must be a number")

    local index = 1
    for i = 1, #self.weights do
        for j = 1, #self.weights[i] do
            for k = 1, #self.weights[i][j] do
                self.weights[i][j][k] = self.weights[i][j][k] - learningRate * gradient[index]
                index = index + 1
            end
        end
    end

    for i = 1, #self.biases do
        for j = 1, #self.biases[i] do
            self.biases[i][j] = self.biases[i][j] - learningRate * gradient[index]
            index = index + 1
        end
    end

end

-- Calculates the gradient of a single trainning example
function MultilayerPerceptron:calculateGradient(inputs, targets)
    
    assert(type(inputs) == "table", "inputs must be a table")
    assert(#inputs == self.structureArray[1], "inputs must have the same number of elements as the input layer")
    assert(type(targets) == "table", "targets must be a table")
    assert(#targets == self.structureArray[#self.structureArray], "targets must have the same number of elements as the output layer")

    local outputs, weightedSums = self:feedForward(inputs)

    local gradientWeights = {}
    local gradientBiases = {}
    local errors = {}
    
    -- Calculate the error of the output layer 
    local delta = math.mapVector(weightedSums[#weightedSums], self.compactFunctions[2])
    local diff = math.subtractVectors(outputs[#outputs], targets)
    errors[#self.structureArray] = math.multiplyVectorComponents(diff, delta)
    
    -- Calculate the error of the hidden layers
    for i = #self.structureArray - 1, 2, -1 do
        local delta = math.mapVector(weightedSums[i], self.compactFunctions[2])
        local weightedError = math.multiplyMatrixByVector(math.transposeMatrix(self.weights[i]), errors[i + 1])
        errors[i] = math.multiplyVectorComponents(weightedError, delta)
    end

    -- Calculate the error of the biases
    for i = 2, #self.structureArray do
        gradientBiases[i-1] = errors[i]
    end

    -- Get the error of the weights
    for i = 1, #self.weights do
        gradientWeights[i] = math.outerProduct(errors[i + 1], outputs[i])
    end

    -- Squish the gradients into a 1D array
    local gradient = {}
    for i = 1, #self.weights do
        for j = 1, #self.weights[i] do
            for k = 1, #self.weights[i][j] do
                table.insert(gradient, gradientWeights[i][j][k])
            end
        end
    end

    for i = 1, #self.biases do
        for j = 1, #self.biases[i] do
            table.insert(gradient, gradientBiases[i][j])
        end
    end

    return gradient, gradientWeights, gradientBiases

end


-- Expose the class
lib.MultilayerPerceptron = MultilayerPerceptron